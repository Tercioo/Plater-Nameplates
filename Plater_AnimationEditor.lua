

local Plater = Plater
local GameCooltip = GameCooltip2
local DF = DetailsFramework
local _
local GetSpellInfo = GetSpellInfo or function(spellID) if not spellID then return nil end local si = C_Spell.GetSpellInfo(spellID) if si then return si.name, nil, si.iconID, si.castTime, si.minRange, si.maxRange, si.spellID, si.originalIconID end end

--get templates
local options_text_template = DF:GetTemplate ("font", "OPTIONS_FONT_TEMPLATE")
local options_dropdown_template = DF:GetTemplate ("dropdown", "OPTIONS_DROPDOWN_TEMPLATE")
local options_switch_template = DF:GetTemplate ("switch", "OPTIONS_CHECKBOX_TEMPLATE")
local options_slider_template = DF:GetTemplate ("slider", "OPTIONS_SLIDER_TEMPLATE")
local options_button_template = DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE")

local scrollbox_size = {201, 405}
local scrollbox_lines = 11
local scrollbox_line_height = 28.7
local scrollbox_line_backdrop_color = {0, 0, 0, 0.5}
local scrollbox_line_backdrop_color_selected = {.6, .6, .1, 0.7}
local buttons_size = {120, 20}
local luaeditor_backdrop_color = {.2, .2, .2, .5}
local luaeditor_border_color = {0, 0, 0, 1}

local debugmode = false

local PLATER_OPTIONS_ANIMATION_TAB = 20

function Plater.CreateSpellAnimationPanel()

	local f = PlaterOptionsPanelFrame
	local mainFrame = PlaterOptionsPanelContainer
	local animationFrame = mainFrame.AllFrames [PLATER_OPTIONS_ANIMATION_TAB]

	--store which animation is being edited
	local currentAnimation
	local currentCopy
	local previewEnabled = true
	local previewLoopTime = 1

	animationFrame.CurrentIndex = 1
	animationFrame.SearchString = ""
	animationFrame.AvailableSpells = {}

	--set points
	local startX = 10
	local startY = -220 --menu and settings panel
	local startYGeneralSettings = -150

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	local CLEUFrame = CreateFrame ("frame")
	CLEUFrame.SpellCaptured = {}
	CLEUFrame.PlayerSerial = UnitGUID ("player")
	CLEUFrame:SetScript ("OnEvent", function (self, event)
		local time, token, hidding, sourceGUID, sourceName, sourceFlag, sourceFlag2, targetGUID, targetName, targetFlag, targetFlag2, spellID, spellName, spellType, amount, overKill, school, resisted, blocked, absorbed, isCritical = CombatLogGetCurrentEventInfo()

		if (token == "SPELL_DAMAGE" or token == "SPELL_PERIODIC_DAMAGE") then
			if (CLEUFrame.PlayerSerial == sourceGUID) then
				if (not CLEUFrame.SpellCaptured [spellID]) then
					CLEUFrame.SpellCaptured [spellID] = {Token = token, Name = spellName, ID =  spellID}
					animationFrame.SelectSpellDropdown:Refresh()
				end
			end
		end
	end)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> logic

	function animationFrame.LoopPreview()
		--simulate a hit in the nameplate
		if (currentAnimation and #currentAnimation > 0) then
			local spellName = GetSpellInfo (currentAnimation.info.spellid)
			if (spellName and Plater.SPELL_WITH_ANIMATIONS [spellName]) then
				for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
					Plater.DoNameplateAnimation (plateFrame, Plater.SPELL_WITH_ANIMATIONS [spellName], spellName, false)
				end
			end
		end
	end

	function animationFrame.StopPreview()
		if (animationFrame.PreviewTicker) then
			animationFrame.PreviewTicker:Cancel()
		end
	end

	function animationFrame.UpdatePreview (newLoopTime)
		if (animationFrame.PreviewTicker) then
			animationFrame.PreviewTicker:Cancel()
		end

		previewLoopTime = newLoopTime or previewLoopTime

		if (previewEnabled) then
			animationFrame.PreviewTicker = C_Timer.NewTicker (previewLoopTime, animationFrame.LoopPreview)
		end
	end

	animationFrame:HookScript ("OnShow", function()
		animationFrame.BuildAnimationDataForScroll()
		CLEUFrame:RegisterEvent ("COMBAT_LOG_EVENT_UNFILTERED")
		Plater.RefreshIsEditingAnimations (true)

		if (previewEnabled) then
			animationFrame.UpdatePreview()
		end
	end)

	animationFrame:HookScript ("OnHide", function()
		CLEUFrame:UnregisterEvent ("COMBAT_LOG_EVENT_UNFILTERED")
		Plater.RefreshIsEditingAnimations (false)
		animationFrame.StopPreview()
	end)

	function animationFrame.GetAnimation (spellID)
		return Plater.db.profile.spell_animation_list [spellID]
	end

	--runs when clicking in the add animation button
	function animationFrame.AddNewAnimation()
		--get the option selected in the dropdown
		local spellID = animationFrame.SelectSpellDropdown.value
		if (not spellID or type (spellID) ~= "number") then
			return
		end

		--check if there's an animation for this spell
		local db = Plater.db.profile.spell_animation_list
		if (db [spellID]) then
			Plater:Msg ("an animation for this spell already exists.")
			return
		end

		local _, playerClass = UnitClass ("player")

		--add the spell to the animation list
		local newAnimationTable = {
			info = {
				time = time(),
				desc = "",
				class = playerClass,
				spellid = spellID,
			}
		}

		db [spellID] = newAnimationTable

		--refresh the scrollbox
		animationFrame.BuildAnimationDataForScroll()

		--start editing this new animation
		animationFrame.EditAnimation (spellID)
	end

	function animationFrame.ShowImportTextField()
		animationFrame.ImportAnimation()
	end

	--when a text in the searchi field is changed, get the text and update the animation list
	function animationFrame.OnSearchBoxTextChanged()
		local text = animationFrame.AnimationSearchTextEntry:GetText()
		animationFrame.SearchString = text:lower()
		animationFrame.AnimationScrollBox:Refresh()
	end

	--build an index table to be used in the scroll selection
	function animationFrame.BuildAnimationDataForScroll()
		local db = Plater.db.profile.spell_animation_list
		local t = {}

		--get the player class and only show animations that is used on its class
		local _, playerClass = UnitClass ("player")
		for spellID, animationTable in pairs (db) do
			if (animationTable.info.class == playerClass) then
				tinsert (t, animationTable)
			end
		end

		animationFrame.AnimationScrollBox:SetData (t)
		animationFrame.AnimationScrollBox:Refresh()
	end

	--sort by name, index 5 holds the name:lower()
	function animationFrame.SortScroll (t1, t2)
		return t1[5] < t2[5]
	end

	--update the scroll list in the left side
	function animationFrame.RefreshAnimationSelectScrollBox (self, data, offset, total_lines)

		--animationFrame.SearchString
		local dataInOrder = {}

		if (animationFrame.SearchString ~= "") then
			for i = 1, #data do
				local animationTable = data[i]
				local spellID = animationTable.info.spellid
				local spellName, _, spellIcon = GetSpellInfo (spellID)

				if (spellName) then
					local spellNameLower = spellName:lower()
					if (spellNameLower:find (animationFrame.SearchString)) then
						dataInOrder [#dataInOrder+1] = {spellID, data[i], spellName, spellIcon, spellNameLower}
					end
				end
			end
		else
			for i = 1, #data do
				local animationTable = data[i]
				local spellID = animationTable.info.spellid
				local spellName, _, spellIcon = GetSpellInfo (spellID)

				if (spellName) then
					local spellNameLower = spellName:lower()
					dataInOrder [#dataInOrder+1] = {spellID, data[i], spellName, spellIcon, spellNameLower}
				end
			end
		end

		table.sort (dataInOrder, animationFrame.SortScroll)

		--update the scroll
		for i = 1, total_lines do
			local index = i + offset
			local t = dataInOrder [index]
			if (t) then
				--get the data
				local spellID = t[1]
				local data = t[2]
				local spellName = t[3]
				local spellIcon = t[4]

				--update the line
				local line = self:GetLine (i)
				line:UpdateLine (spellID, data, spellName, spellIcon)

				if (data == currentAnimation) then
					line:SetBackdropColor (unpack (scrollbox_line_backdrop_color_selected))
				else
					line:SetBackdropColor (unpack (scrollbox_line_backdrop_color))
				end
			end
		end
	end

	function animationFrame.OnEnterScrollSelectionLine (self)
		self:SetBackdropColor (.3, .3, .3, .6)
	end

	function animationFrame.OnLeaveScrollSelectionLine (self)
		--check if the hover overed button is the current animation being edited
		if (currentAnimation == self.Data) then
			self:SetBackdropColor (unpack (scrollbox_line_backdrop_color_selected))
		else
			self:SetBackdropColor (unpack (scrollbox_line_backdrop_color))
		end
	end

	function animationFrame.EditAnimation (spellID)
		local animationObject = animationFrame.GetAnimation (spellID)

		if (not animationObject) then
			Plater:Msg ("animation not found")
			return
		end

		currentAnimation = animationObject

		--refresh the spell selection box
		animationFrame.AnimationScrollBox:Refresh()

		--update the editing animation
		--animationFrame:HideAllConfigFrames()
		animationFrame.EffectSelectionDropdown:Refresh()
		animationFrame.EffectSelectionDropdown:Select (1, true)
		animationFrame.OnSelectEffect (_, _, 1)
		animationFrame.RefreshAddAnimationButtons()

		if (animationFrame.IsExporting or animationFrame.IsImporting) then
			animationFrame.HideStringField()
		end
	end

	--user selected 'paste' in the context menu of 'self'
	--copy the settings from the 'currentCopy' variable into the animation table for this widget
	function animationFrame.PasteAnimationSettings (self)
		if (not currentCopy or #currentCopy == 0) then
			Plater:Msg ("there's no animation to paste.")
			return
		end

		local spellID = self.SpellID
		if (spellID) then
			local animationObject = animationFrame.GetAnimation (spellID)
			if (animationObject) then
				--iterate among all copied animations
				for i = 1, #currentCopy do
					local thisCopiedEffect = currentCopy [i]
					local copiedEffectType = thisCopiedEffect.animation_type
					--below it iterates among all animation in the target animation object, if it doesn't find an effect table like the copied one, it needs to add it then
					local shouldAdd = true

					for i = 1, #animationObject do
						local animationEffect = animationObject [i]
						if (animationEffect.animation_type == copiedEffectType) then
							--replace the effect settings
							DF.table.copy (animationEffect, thisCopiedEffect)
							shouldAdd = false
							break
						end
					end

					--if it fails to find a similar effect, add it
					if (shouldAdd) then
						tinsert (animationObject, DF.table.copy ({}, thisCopiedEffect))
					end
				end

				animationFrame.EditAnimation (spellID)

				Plater.RefreshDBUpvalues()
				Plater:Msg ("settings applied!")
			else
				Plater:Msg ("animation net found")
			end
		else
			Plater:Msg ("invalid spellID")
		end
	end

	function animationFrame.OnClickMenuLine (self, spellID, option, value)

		if (option == "editanimation") then
			animationFrame.EditAnimation (spellID)

		elseif (option == "copy") then
			local animationObject = animationFrame.GetAnimation (self.SpellID)

			--make a new table for the copied effects
			currentCopy = {}

			--animations stay in the indexed part of the animtion object
			--copy the settings of these indexes into the copy table
			for i = 1, #animationObject do
				local effect = animationObject [i]
				tinsert (currentCopy, DF.table.copy ({}, effect))
			end

			local spellName = GetSpellInfo (spellID)
			if (spellName) then
				Plater:Msg (spellName .. " copied.")
			end

		elseif (option == "export") then
			animationFrame.ExportAnimation (self)

		elseif (option == "paste") then
			animationFrame.PasteAnimationSettings (self)

		elseif (option == "remove") then
			animationFrame.RemoveAnimation (self)

		elseif (option == "export_table") then
			animationFrame.ExportAnimation (self, true)

		end

		GameCooltip:Hide()

	end

	function animationFrame.OnClickScrollSelectionLine (self, button)
		local spellID = self.SpellID
		if (spellID) then
			if (button == "LeftButton") then
				animationFrame.EditAnimation (spellID)

			elseif (button == "RightButton") then
				--open menu
				GameCooltip:Preset (2)
				GameCooltip:SetType ("menu")
				GameCooltip:SetOption ("TextSize", 10)
				GameCooltip:SetOption ("FixedWidth", 200)
				GameCooltip:SetOption ("ButtonsYModSub", -1)
				GameCooltip:SetOption ("YSpacingModSub", -4)
				GameCooltip:SetOwner (self, "topleft", "topright", 2, 0)
				GameCooltip:SetFixedParameter (spellID)

				GameCooltip:AddLine ("Edit Animation")
				GameCooltip:AddMenu (1, animationFrame.OnClickMenuLine, "editanimation")
				GameCooltip:AddIcon ([[Interface\BUTTONS\UI-GuildButton-PublicNote-Up]], 1, 1, 16, 16)

				GameCooltip:AddLine ("Copy Settings")
				GameCooltip:AddMenu (1, animationFrame.OnClickMenuLine, "copy")
				GameCooltip:AddIcon ([[Interface\AddOns\Plater\images\icons]], 1, 1, 16, 16, 3/512, 21/512, 215/512, 233/512)

				if (currentCopy) then
					GameCooltip:AddLine ("Paste Settings")
					GameCooltip:AddMenu (1, animationFrame.OnClickMenuLine, "paste")
					GameCooltip:AddIcon ([[Interface\AddOns\Plater\images\icons]], 1, 1, 16, 16, 3/512, 21/512, 215/512, 233/512)
				else
					GameCooltip:AddLine ("Paste Settings", "", 1, "gray")
					GameCooltip:AddMenu (1, animationFrame.OnClickMenuLine, "paste")
					GameCooltip:AddIcon ([[Interface\AddOns\Plater\images\icons]], 1, 1, 16, 16, 3/512, 21/512, 215/512, 233/512, false, false, true)
				end

				GameCooltip:AddLine ("Export As a Text String", "", 1)
				GameCooltip:AddIcon ([[Interface\BUTTONS\UI-GuildButton-MOTD-Up]], 1, 1, 16, 16, 1, 0, 0, 1)
				GameCooltip:AddMenu (1, animationFrame.OnClickMenuLine, "export")

				GameCooltip:AddLine ("Remove")
				GameCooltip:AddMenu (1, animationFrame.OnClickMenuLine, "remove")
				GameCooltip:AddIcon ([[Interface\AddOns\Plater\images\icons]], 1, 1, 16, 16, 3/512, 21/512, 235/512, 257/512)

				--dev tool to export in database format
				if (GetRealmName() == "Azralon") then
					GameCooltip:AddLine ("$div")
					GameCooltip:AddLine ("Export To Table (dev)", "", 1)
					GameCooltip:AddIcon ([[Interface\BUTTONS\UI-GuildButton-MOTD-Up]], 1, 1, 16, 16, 1, 0, 0, 1)
					GameCooltip:AddMenu (1, animationFrame.OnClickMenuLine, "export_table")
				end

				GameCooltip:Show()
			end
		end
	end

	--update a single line in the scroll list
	function animationFrame.UpdateScrollLine (self, spellID, data, spellName, spellIcon)
		self.Icon:SetTexture (spellIcon)
		self.Icon:SetTexCoord (.1, .9, .1, .9)
		self.AnimationName:SetText (spellName)
		self.SpellID = spellID
		self.Data = data
	end

	function animationFrame:HideAllConfigFrames()
		for _, frame in pairs (animationFrame.AllConfigFrames) do
			frame:Hide()
		end
	end

	function animationFrame.OnSelectEffect (self, _, effectIndex)
		if (not currentAnimation [effectIndex]) then
			animationFrame.DisableOptions()
			return
		else
			animationFrame.EnableOptions()
		end

		animationFrame.CurrentIndex = effectIndex
		animationFrame:HideAllConfigFrames()

		local animationData = currentAnimation [animationFrame.CurrentIndex]
		local configFrame = animationFrame.AllConfigFrames [animationData.animation_type]
		configFrame.Data = animationData
		configFrame:RefreshOptions()
		configFrame:Show()
	end

	function animationFrame.RefreshEffectListDropdown (self)
		local t = {}
		if (currentAnimation) then
			for animationIndex, animationTable in ipairs (currentAnimation) do
				tinsert (t, {label = " #" .. animationIndex .. " " .. animationTable.animation_type, value = animationIndex, onclick = animationFrame.OnSelectEffect})
			end
		end
		return t
	end

	function animationFrame.AddNewShakeEffect()
		if (currentAnimation) then
			tinsert (currentAnimation, {
					enabled = true,
					animation_type = "frameshake",
					scaleX = .1,
					scaleY = 1,
					absolute_sineX = false,
					absolute_sineY = false,
					duration = 0.1,
					amplitude = 3,
					frequency = 1,
					fade_in = 0.01,
					fade_out = 0.09,
					cooldown = 0.5,
					critical_scale = 1.05,
				})

			animationFrame.EffectSelectionDropdown:Refresh()

			animationFrame.CurrentIndex = #currentAnimation
			animationFrame.EffectSelectionDropdown:Select (#currentAnimation, true)
			animationFrame.OnSelectEffect (_, _, #currentAnimation)
			animationFrame.RefreshAddAnimationButtons()
		end
	end

	function animationFrame.AddNewScaleEffect()
		if (currentAnimation) then
			tinsert (currentAnimation, {
				enabled = true,
				duration = 0.05, --seconds
				animation_type = "scale",
				cooldown = 0.75, --seconds
				scale_upX = 1.03,
				scale_upY = 1.03,
				scale_downX = 0.97,
				scale_downY = 0.97,
			})

			animationFrame.EffectSelectionDropdown:Refresh()

			animationFrame.CurrentIndex = #currentAnimation
			animationFrame.EffectSelectionDropdown:Select (#currentAnimation, true)
			animationFrame.OnSelectEffect (_, _, #currentAnimation)
			animationFrame.RefreshAddAnimationButtons()
		end
	end

	function animationFrame.RefreshAddAnimationButtons()
		animationFrame.AddShakeButton:Enable()
		animationFrame.AddScaleButton:Enable()

		if (not currentAnimation) then
			animationFrame.AddShakeButton:Disable()
			animationFrame.AddScaleButton:Disable()
			return
		end

		for animationIndex, animationTable in ipairs (currentAnimation) do
			if (animationTable.animation_type == "scale") then
				animationFrame.AddScaleButton:Disable()
			end
			if (animationTable.animation_type == "frameshake") then
				animationFrame.AddShakeButton:Disable()
			end
		end
	end

	local cooltipInjectionScrollLine = function (self, fixed_parameter)
		GameCooltip:Preset (2)
		GameCooltip:SetOption ("TextSize", 10)
		GameCooltip:SetOption ("FixedWidth", 200)

		local animationObject = animationFrame.GetAnimation (self.SpellID)
		local lastEdited = date ("%d/%m/%Y", animationObject.info.time)

		local spellName, _, spellIcon = GetSpellInfo (self.SpellID)

		GameCooltip:AddLine (spellName, nil, 1, "yellow", "yellow", 11, "Friz Quadrata TT", "OUTLINE")
		GameCooltip:AddIcon (spellIcon, 1, 1, 18, 18, .1, .9, .1, .9)

		GameCooltip:AddLine ("Last Edited:", lastEdited)

		if (animationObject.info.desc and animationObject.info.desc ~= "") then
			GameCooltip:AddLine (animationObject.info.desc, "", 1, "gray")
		end
	end

	local cooltipInjectionTable_ScrollLine = {
		Type = "tooltip",
		BuildFunc = cooltipInjectionScrollLine,
		ShowSpeed = 0.016,
		MyAnchor = "topleft",
		HisAnchor = "topright",
		X = 10,
		Y = 0,
	}

	function animationFrame.RemoveAnimation (self)
		local spellID = self.SpellID
		if (spellID) then
			--is removing the animation which is currently being edited?
			if (currentAnimation == Plater.db.profile.spell_animation_list [spellID]) then
				animationFrame.DisableOptions()
				animationFrame.AddShakeButton:Disable()
				animationFrame.AddScaleButton:Disable()
				currentAnimation = nil
				animationFrame.EffectSelectionDropdown:Refresh()
			end

			Plater.db.profile.spell_animation_list [spellID] = nil

			Plater.RefreshDBUpvalues()
			animationFrame.BuildAnimationDataForScroll()
		end
	end

	function animationFrame.ImportAnimation()
		animationFrame.IsExporting = nil
		animationFrame.IsImporting = true

		animationFrame.ImportStringField:Show()
		animationFrame.AnimationConfigFrame:Hide()

		animationFrame.ImportStringField:SetText ("")
		animationFrame.ImportStringField:SetFocus (true)
	end

	function animationFrame.ExportDev (self)

		local spellID = self.SpellID
		local animationToExport = animationFrame.GetAnimation (spellID)

		local copy = DF.table.copy ({}, animationToExport)
		copy = {
			[spellID] = copy
		}

		local spellName = GetSpellInfo (spellID)
		local class = UnitClass ("player")

		animationFrame.ImportStringField:SetText ("--" .. spellName .. " (" .. class .. ")\n" .. DF.table.dump (copy))
		animationFrame.ImportStringField:SetFocus (true)
		animationFrame.ImportStringField.editbox:HighlightText()
		animationFrame.AnimationConfigFrame:Hide()
		return
	end

	function animationFrame.ExportAnimation (self, isDev)
		animationFrame.IsExporting = true
		animationFrame.IsImporting = nil
		animationFrame.ImportStringField:Show()

		if (isDev) then
			animationFrame.ExportDev (self)
			return
		end

		local spellID = self.SpellID
		local animationToExport = animationFrame.GetAnimation (spellID)

		if (animationToExport) then
			--export to string
			animationFrame.ImportStringField:SetText (Plater.CompressData (animationToExport, "print") or "failed to export")

			C_Timer.After (.1, function()
				animationFrame.ImportStringField:SetFocus (true)
				animationFrame.ImportStringField.editbox:HighlightText()
			end)

			animationFrame.AnimationConfigFrame:Hide()
		end
	end

	function animationFrame.DoImportAnimation (animationObject)
		local spellID = tonumber(animationObject.info.spellid)
		local spellName = GetSpellInfo (spellID)
		if not spellName then return end

		local db = Plater.db.profile.spell_animation_list
		db [spellID] = animationObject

		Plater:Msg ("animation for spell " .. spellName .. " added!")

		local _, class = UnitClass ("player")
		if (class ~= animationObject.info.class) then
			Plater:Msg ("this animation is for " .. animationObject.info.class .. " and won't show on this character.")
		end

		animationFrame.EditAnimation (spellID)

		animationFrame.BuildAnimationDataForScroll()
		Plater.RefreshDBUpvalues()
	end

	function animationFrame.ConfirmImportAnimation()
		if (animationFrame.IsExporting) then
			animationFrame.HideStringField()
			return
		end

		local text = animationFrame.ImportStringField:GetText()
		local animationObject = Plater.DecompressData (text, "print")
		animationFrame.HideStringField()

		if (animationObject) then
			local db = Plater.db.profile.spell_animation_list
			local spellID = tonumber(animationObject.info.spellid)

			if (not spellID) then
				Plater:Msg ("invalid animation.")
				return
			end

			local spellName = GetSpellInfo (spellID)
			if (not spellName) then
				Plater:Msg ("the spell for this animation doesn't exists.")
				return
			end

			--already have
			if (db [spellID]) then
				--show a box to confirm
				DF:ShowPromptPanel ("Animation for " .. spellName .. " already exists, overwrite?", function()
					--true
					animationFrame.DoImportAnimation (animationObject)
				end,
				function()
					return
				end)
			else
				animationFrame.DoImportAnimation (animationObject)
			end
		else
			Plater:Msg ("invalid animation.")
		end
	end

	function animationFrame.HideStringField()
		animationFrame.IsExporting = nil
		animationFrame.IsImporting = nil

		animationFrame.ImportStringField:Hide()
		animationFrame.ImportStringField:SetText ("")

		animationFrame.AnimationConfigFrame:Show()
	end


------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> build the frames
	local optionsTable = {
		{type = "label", get = function() return "General Settings:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "toggle",
			get = function() return Plater.db.profile.spell_animations end,
			set = function (self, fixedparam, value)
				Plater.db.profile.spell_animations = value
				Plater.RefreshDBUpvalues()
			end,
			name = "Spell Animations Enabled",
			desc = "If enabled some of your abilities will cause the nameplate to shake or play a special effect when the ability hits the enemy.\n\nCustomize each animation in the Animations tab.",
		},
		{
			type = "range",
			get = function() return Plater.db.profile.spell_animations_scale end,
			set = function (self, fixedparam, value)
				Plater.db.profile.spell_animations_scale = value
			end,
			min = 0.75,
			max = 2.75,
			step = 0.1,
			name = "Overall Intensity",
			desc = "Overall intensity scale of the spell animations.",
			thumbscale = 1.8,
			usedecimals = true,
		},
	}

	DF:BuildMenu (animationFrame, optionsTable, 10, startYGeneralSettings, 330, true, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template, animationFrame.OnDataChange)

	local scrollBoxHeight = 396 - 70

	--dropdown select spell to add
	local buildAddSpellOptions = function()
		local t = {}
		local db = Plater.db.profile.spell_animation_list
		for spellID, spellInfo in pairs (CLEUFrame.SpellCaptured) do
			if (not db [spellInfo.ID]) then
				local _, _, spellIcon = GetSpellInfo (spellInfo.ID)
				if (spellIcon) then
					tinsert (t, {label = spellInfo.Name, value = spellInfo.ID, onclick = function()end, desc = "Spell ID: " .. spellInfo.ID, icon = spellIcon, texcoord = {.1, .9, .1, .9}})
				end
			end
		end
		return t
	end

	local selectSpellLabel = DF:CreateLabel (animationFrame, "Select Spell to Add Animation:", DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"))
	local selectSpellDropdown = DF:CreateDropDown (animationFrame, buildAddSpellOptions, 1, 130, 20, "SelectSpellDropdown", _, DF:GetTemplate ("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))
	selectSpellDropdown:SetPoint ("topleft", selectSpellLabel, "bottomleft", 0, -2)

	--button add spell
	local addSpellButton = DF:CreateButton (animationFrame, animationFrame.AddNewAnimation, 40, 20, "Add", -1, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
	addSpellButton:SetPoint ("left", selectSpellDropdown, "right", 2, 0)
	addSpellButton.tooltip = function()
		if (not next (CLEUFrame.SpellCaptured)) then
			return "No spells to add?\n\nHit any npc with spells while this window is open to fill the dropdown with options."
		else
			return "Add animation for the selected spell."
		end
	end

	--button import animation
	local importButton = DF:CreateButton (animationFrame, animationFrame.ShowImportTextField, 26, 20, "", -1, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
	importButton:SetIcon ([[Interface\AddOns\Plater\images\icons]], 16, 16, "overlay", {5/512, 19/512, 195/512, 210/512}, {1, .8, .2}, nil, nil, nil, false)
	importButton:SetPoint ("left", addSpellButton, "right", 2, 0)
	importButton:HookScript ("OnEnter", function()
		GameCooltip:Preset (2)
		GameCooltip:SetOption ("TextSize", 10)
		GameCooltip:SetOption ("FixedWidth", 200)
		GameCooltip:SetOwner  (importButton.widget)

		GameCooltip:AddLine ("Import Animation", "", 1, "yellow", "yellow", 12, nil, "OUTLINE")
		GameCooltip:AddLine ("Add an animation from a string.\n\nYou can export to string by right clicking an animation in the menu below.")

		GameCooltip:Show()
	end)
	importButton:HookScript ("OnLeave", function()
		GameCooltip:Hide()
	end)

	--search box
	local searchLabel = DF:CreateLabel (animationFrame, "Search:", DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"))
	searchLabel:SetPoint ("topleft", selectSpellDropdown, "bottomleft", 0, -5)

	local searchAnimationTextEntry = DF:CreateTextEntry (animationFrame, function()end, 200, 20, "AnimationSearchTextEntry", _, _, options_dropdown_template)
	searchAnimationTextEntry:SetHook ("OnChar", animationFrame.OnSearchBoxTextChanged)
	searchAnimationTextEntry:SetHook ("OnTextChanged", animationFrame.OnSearchBoxTextChanged)
	searchAnimationTextEntry:SetPoint ("topleft", searchLabel, "bottomleft", 0, -2)

	--scrollbox to select the spell animation to edit
	local spellLabel = DF:CreateLabel (animationFrame, "Spell Animations", DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"))
	spellLabel:SetPoint ("topleft", searchAnimationTextEntry, "bottomleft", 0, -5)

	local animationSelectScrollBox = DF:CreateScrollBox (animationFrame, "$parentScrollBox", animationFrame.RefreshAnimationSelectScrollBox, {}, 200, scrollBoxHeight, scrollbox_lines, scrollbox_line_height)
	animationSelectScrollBox:SetPoint ("topleft", spellLabel.widget, "bottomleft", 0, -2)
	DF:ReskinSlider (animationSelectScrollBox)
	animationFrame.AnimationScrollBox = animationSelectScrollBox

	local createNewLineFunc = function (self, index)
		--create a new line
		local line = CreateFrame ("button", "$parentLine" .. index, self, BackdropTemplateMixin and "BackdropTemplate")

		--set its parameters
		line:SetPoint ("topleft", self, "topleft", 1, -((index-1) * (scrollbox_line_height+1)) - 1)
		line:SetSize (scrollbox_size[1]-2, scrollbox_line_height)
		line:RegisterForClicks ("LeftButtonDown", "RightButtonDown")

		line:SetScript ("OnEnter",	animationFrame.OnEnterScrollSelectionLine)
		line:SetScript ("OnLeave",	animationFrame.OnLeaveScrollSelectionLine)
		line:SetScript ("OnClick",	animationFrame.OnClickScrollSelectionLine)

		line.CoolTip = cooltipInjectionTable_ScrollLine
		GameCooltip:CoolTipInject (line)

		line:SetBackdrop ({bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true, edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1})
		line:SetBackdropColor (unpack (scrollbox_line_backdrop_color))
		line:SetBackdropBorderColor (0, 0, 0, 1)

		local icon = line:CreateTexture ("$parentIcon", "overlay")
		icon:SetSize (scrollbox_line_height-4, scrollbox_line_height-4)

		local animationName = DF:CreateLabel (line, "", DF:GetTemplate ("font", "PLATER_SCRIPTS_NAME"))

		--setup anchors
		icon:SetPoint ("left", line, "left", 2, 0)
		animationName:SetPoint ("topleft", icon, "topright", 2, -2)

		line.Icon = icon
		line.AnimationName = animationName
		line.UpdateLine = animationFrame.UpdateScrollLine

		return line
	end

	--create the scrollbox lines
	for i = 1, scrollbox_lines do
		animationSelectScrollBox:CreateLine (createNewLineFunc)
	end

	--import box
		--text editor
		local luaeditor_backdrop_color = {.2, .2, .2, .5}
		local luaeditor_border_color = {0, 0, 0, 1}
		local edit_script_size = {620, 431}
		local buttons_size = {120, 20}

		local importStringField = DF:NewSpecialLuaEditorEntry (animationFrame, 825, edit_script_size[2] - 75, "ImportEditor", "$parentImportEditor", true)
		importStringField:SetBackdrop ({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
		importStringField:SetBackdropBorderColor (unpack (luaeditor_border_color))
		importStringField:SetBackdropColor (unpack (luaeditor_backdrop_color))
		importStringField:Hide()
		animationFrame.ImportStringField = importStringField
		DF:ReskinSlider (importStringField.scroll)

		--import button
		local okayButton = DF:CreateButton (importStringField, animationFrame.ConfirmImportAnimation, buttons_size[1], buttons_size[2], "Okay", -1, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
		okayButton:SetIcon ([[Interface\BUTTONS\UI-Panel-BiggerButton-Up]], 20, 20, "overlay", {0.1, .9, 0.1, .9})

		--cancel button
		local cancelButton = DF:CreateButton (importStringField, animationFrame.HideStringField, buttons_size[1], buttons_size[2], "Cancel", -1, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
		cancelButton:SetIcon ([[Interface\BUTTONS\UI-Panel-MinimizeButton-Up]], 20, 20, "overlay", {0.1, .9, 0.1, .9})
		okayButton:SetPoint ("topright", importStringField, "bottomright", 0, -7)
		cancelButton:SetPoint ("right", okayButton, "left", -20, 0)

	--editing settings of the animation
	local animationConfigFrame = CreateFrame ("frame", "$parentAnimationConfig", animationFrame, BackdropTemplateMixin and "BackdropTemplate")
	DF:ApplyStandardBackdrop (animationConfigFrame)
	animationConfigFrame:SetPoint ("topleft", animationSelectScrollBox, "topright", 45, 53 + 70)
	animationConfigFrame:SetSize (825, scrollBoxHeight + 53 + 5)
	animationFrame.AnimationConfigFrame = animationConfigFrame

	local animationPreviewFrame = CreateFrame ("frame", "$parentPreviewConfig", animationFrame, BackdropTemplateMixin and "BackdropTemplate")
	DF:ApplyStandardBackdrop (animationPreviewFrame)
	animationPreviewFrame:SetPoint ("topleft", animationConfigFrame, "bottomleft", 0, -5)
	animationPreviewFrame:SetPoint ("topright", animationConfigFrame, "bottomright", 0, -5)
	animationPreviewFrame:SetHeight (60)
	animationFrame.AnimationPreviewFrame = animationPreviewFrame

	local previewHeaderLabel = DF:CreateLabel (animationPreviewFrame, "Preview Settings:", DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"))
	previewHeaderLabel:SetPoint ("topleft", animationPreviewFrame, "topleft", 5, -5)

	--select effect dropdown (scale, shake)
	local effectSelectionLabel = DF:CreateLabel (animationConfigFrame, "Effect:", DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"))
	local effectSelectionDropdown = DF:CreateDropDown (animationConfigFrame, animationFrame.RefreshEffectListDropdown, 1, 160, 20, "EffectSelectionDropdown", _, DF:GetTemplate ("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))
	effectSelectionDropdown:SetPoint ("left", effectSelectionLabel, "right", 2, 0)
	animationFrame.EffectSelectionDropdown = effectSelectionDropdown

	--add shake effect
	local addShakeButton = DF:CreateButton (animationConfigFrame, animationFrame.AddNewShakeEffect, 120, 20, "Add Shake Effect", -1, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
	animationFrame.AddShakeButton = addShakeButton

	--add scale effect
	local addScaleButton = DF:CreateButton (animationConfigFrame, animationFrame.AddNewScaleEffect, 120, 20, "Add Scale Effect", -1, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
	addScaleButton:SetPoint ("left", addShakeButton, "right", 2, 0)
	animationFrame.AddScaleButton = addScaleButton

	animationFrame.AllConfigFrames = {}
	local scaleOptionsFrame = CreateFrame ("frame", "$parentScaleFrame", animationConfigFrame, BackdropTemplateMixin and "BackdropTemplate")
	scaleOptionsFrame:Hide()
	animationFrame.AllConfigFrames ["scale"] = scaleOptionsFrame
	local shakeOptionsFrame = CreateFrame ("frame", "$parentShakeFrame", animationConfigFrame, BackdropTemplateMixin and "BackdropTemplate")
	animationFrame.AllConfigFrames ["frameshake"] = shakeOptionsFrame

	function animationFrame.DisableOptions()
		for _, widget in ipairs (scaleOptionsFrame.widget_list) do
			if (widget.Disable) then
				widget:Disable()
			end
		end
		for _, widget in ipairs (shakeOptionsFrame.widget_list) do
			if (widget.Disable) then
				widget:Disable()
			end
		end
	end

	function animationFrame.EnableOptions()
		for _, widget in ipairs (scaleOptionsFrame.widget_list) do
			if (widget.Enable) then
				widget:Enable()
			end
		end
		for _, widget in ipairs (shakeOptionsFrame.widget_list) do
			if (widget.Enable) then
				widget:Enable()
			end
		end
	end

	for _, frame in pairs (animationFrame.AllConfigFrames) do
		frame:SetSize (460, 250)
		frame:SetPoint ("topleft", animationConfigFrame, "topleft", 5, -5)
		--frame:Hide()
		frame.Data = {}
	end



	local scaleOptionsTable = {
		{
			type = "toggle",
			get = function() return scaleOptionsFrame.Data.enabled end,
			set = function (self, fixedparam, value)
				scaleOptionsFrame.Data.enabled = value
			end,
			name = "Enabled",
		},

		{type = "blank"},


		{
			type = "range",
			get = function() return scaleOptionsFrame.Data.duration end,
			set = function (self, fixedparam, value)
				scaleOptionsFrame.Data.duration = value
			end,
			min = 0.05,
			max = 1,
			step = 0.05,
			usedecimals = true,
			name = "Duration",
		},

		{type = "blank"},

		{
			type = "range",
			get = function() return scaleOptionsFrame.Data.scale_upX end,
			set = function (self, fixedparam, value)
				scaleOptionsFrame.Data.scale_upX = value
			end,
			min = 0,
			max = 20,
			step = 0.05,
			usedecimals = true,
			name = "Scale Up X",
		},
		{
			type = "range",
			get = function() return scaleOptionsFrame.Data.scale_upY end,
			set = function (self, fixedparam, value)
				scaleOptionsFrame.Data.scale_upY = value
			end,
			min = 0,
			max = 20,
			step = 0.05,
			usedecimals = true,
			name = "Scale Up Y",
		},
		{
			type = "range",
			get = function() return scaleOptionsFrame.Data.scale_downX end,
			set = function (self, fixedparam, value)
				scaleOptionsFrame.Data.scale_downX = value
			end,
			min = 0,
			max = 20,
			step = 0.05,
			usedecimals = true,
			name = "Scale Down X",
		},
		{
			type = "range",
			get = function() return scaleOptionsFrame.Data.scale_downY end,
			set = function (self, fixedparam, value)
				scaleOptionsFrame.Data.scale_downY = value
			end,
			min = 0,
			max = 20,
			step = 0.05,
			usedecimals = true,
			name = "Scale Down Y",
		},

		{type = "blank"},

		{
			type = "range",
			get = function() return scaleOptionsFrame.Data.cooldown end,
			set = function (self, fixedparam, value)
				scaleOptionsFrame.Data.cooldown = value
			end,
			min = 0,
			max = 20,
			step = 0.05,
			usedecimals = true,
			name = "Cooldown",
		},

		{type = "blank"},

		{
			type = "range",
			get = function() return scaleOptionsFrame.Data.critical_scale end,
			set = function (self, fixedparam, value)
				scaleOptionsFrame.Data.critical_scale = value
			end,
			min = 1,
			max = 2,
			step = 0.05,
			usedecimals = true,
			name = "Critical Hit Scale",
		},
	}

	local shakeOptionsTable = {
		{
			type = "toggle",
			get = function() return shakeOptionsFrame.Data.enabled end,
			set = function (self, fixedparam, value)
				shakeOptionsFrame.Data.enabled = value
			end,
			name = "Enabled",
		},

		{type = "blank"},


		{
			type = "range",
			get = function() return shakeOptionsFrame.Data.duration end,
			set = function (self, fixedparam, value)
				shakeOptionsFrame.Data.duration = value
			end,
			min = 0.05,
			max = 1,
			step = 0.05,
			usedecimals = true,
			name = "Duration",
			desc = "Animation duration time.",
		},

		{
			type = "range",
			get = function() return shakeOptionsFrame.Data.amplitude end,
			set = function (self, fixedparam, value)
				shakeOptionsFrame.Data.amplitude = value
			end,
			min = 0,
			max = 50,
			step = 0.05,
			usedecimals = true,
			name = "Amplitude",
			desc =  "Scale the strength of the animation.",
		},
		{
			type = "range",
			get = function() return shakeOptionsFrame.Data.frequency end,
			set = function (self, fixedparam, value)
				shakeOptionsFrame.Data.frequency = value
			end,
			min = 0,
			max = 200,
			step = 0.05,
			usedecimals = true,
			name = "Frequency",
			desc =  "Scale how fast and often the animation plays within its duration time.",
		},

		{type = "blank"},

		{
			type = "range",
			get = function() return shakeOptionsFrame.Data.scaleX end,
			set = function (self, fixedparam, value)
				shakeOptionsFrame.Data.scaleX = value
			end,
			min = -50,
			max = 50,
			step = 0.05,
			usedecimals = true,
			name = "Scale X",
			desc = "Scale the animation on its horizontal axis.",
		},
		{
			type = "range",
			get = function() return shakeOptionsFrame.Data.scaleY end,
			set = function (self, fixedparam, value)
				shakeOptionsFrame.Data.scaleY = value
			end,
			min = -50,
			max = 50,
			step = 0.05,
			usedecimals = true,
			name = "Scale Y",
			desc = "Scale the animation on its vertical axis.",
		},

		{
			type = "toggle",
			get = function() return shakeOptionsFrame.Data.absolute_sineX end,
			set = function (self, fixedparam, value)
				shakeOptionsFrame.Data.absolute_sineX = value
			end,
			name = "Absolute Sine X",
			desc = "Makes the sine wave of the animation to not use its negative part making it always to the right side.\n\nIf the |cFFFFFF00Scale X|r option has a negative value the animation goes to the left side.",
		},
		{
			type = "toggle",
			get = function() return shakeOptionsFrame.Data.absolute_sineY end,
			set = function (self, fixedparam, value)
				shakeOptionsFrame.Data.absolute_sineY = value
			end,
			name = "Absolute Sine Y",
			desc = "Makes the sine wave of the animation to not use its negative part making it always to go up.\n\nIf the |cFFFFFF00Scale Y|r option has a negative value the animation goes down instead.",
		},

		{type = "blank"},

		{
			type = "range",
			get = function() return shakeOptionsFrame.Data.fade_in end,
			set = function (self, fixedparam, value)
				shakeOptionsFrame.Data.fade_in = value
			end,
			min = 0,
			max = 2,
			step = 0.05,
			usedecimals = true,
			name = "Fade In Time",
			desc = "Time the animation takes to go from not playing at all to its full effect strength.\n\nThis time is within the animation duration time.",
		},
		{
			type = "range",
			get = function() return shakeOptionsFrame.Data.fade_out end,
			set = function (self, fixedparam, value)
				shakeOptionsFrame.Data.fade_out = value
			end,
			min = 0,
			max = 2,
			step = 0.05,
			usedecimals = true,
			name = "Fade Out Time",
			desc = "Time the animation takes to go from playing its full effect to not playing at all.\n\nThis time is within the animation duration time.",
		},

		{type = "blank"},

		{
			type = "range",
			get = function() return shakeOptionsFrame.Data.cooldown end,
			set = function (self, fixedparam, value)
				shakeOptionsFrame.Data.cooldown = value
			end,
			min = 0,
			max = 20,
			step = 0.05,
			usedecimals = true,
			name = "Cooldown",
			desc = "Won't play this animation again while its cooldown time isn't passed.",
		},

		{type = "blank"},

		{
			type = "range",
			get = function() return scaleOptionsFrame.Data.critical_scale end,
			set = function (self, fixedparam, value)
				scaleOptionsFrame.Data.critical_scale = value
			end,
			min = 1,
			max = 2,
			step = 0.05,
			usedecimals = true,
			name = "Critical Hit Scale",
		},
	}

	--the callback function seems to be firing before the OnValueChanged function in the widget
	--delaying the update a little bit fixes this
	local updateAnimationOnPlater = function()
		Plater.RefreshDBLists()
		--invalidate the timer
		animationFrame.RefreshTimer:Cancel()
	end
	function animationFrame.OnDataChange()
		if (animationFrame.RefreshTimer) then
			if (not animationFrame.RefreshTimer._cancelled) then
				return
			end
		end
		animationFrame.RefreshTimer = C_Timer.NewTimer (.1, updateAnimationOnPlater)
	end

	DF:BuildMenu (scaleOptionsFrame, scaleOptionsTable, 0, 0, 330, true, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template, animationFrame.OnDataChange)
	DF:BuildMenu (shakeOptionsFrame, shakeOptionsTable, 0, 0, 330, true, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template, animationFrame.OnDataChange)

	local animationPreviewOptionsTable = {
		{
			type = "toggle",
			get = function() return previewEnabled end,
			set = function (self, fixedparam, value)
				previewEnabled = value
				animationFrame.UpdatePreview()
			end,
			name = "Enabled",
		},
		{
			type = "range",
			get = function() return previewLoopTime end,
			set = function (self, fixedparam, value)
				animationFrame.UpdatePreview (value)
			end,
			min = .1,
			max = 10,
			step = 0.05,
			usedecimals = true,
			name = "Loop Time",
		},
	}
	DF:BuildMenu (animationPreviewFrame, animationPreviewOptionsTable, 5, -25, 10, true, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template, animationFrame.OnDataChange)

	animationFrame.DisableOptions()

	selectSpellLabel:SetPoint ("topleft", animationFrame, "topleft", startX, startY)

	effectSelectionLabel:SetPoint ("bottomleft", animationConfigFrame, "topleft", 0, 8)
	addShakeButton:SetPoint ("left", effectSelectionDropdown, "right", 2, 0)

	importStringField:SetPoint ("topleft", animationSelectScrollBox, "topright", 45, 53 + 70)

	animationFrame.RefreshAddAnimationButtons()
	animationFrame.BuildAnimationDataForScroll()

end

-- endd doo thend thens ends elses