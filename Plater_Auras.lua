

local Plater = _G.Plater
local DF = _G.DetailsFramework

local IS_WOW_PROJECT_MAINLINE = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
local IS_WOW_PROJECT_NOT_MAINLINE = WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE

--stop yellow lines on my editor
local tinsert = _G.tinsert
local min = _G.min
local max = _G.max
local abs = _G.abs
local CreateFrame = _G.CreateFrame
local unpack = _G.unpack
local CooldownFrame_Set = _G.CooldownFrame_Set
local GetTime = _G.GetTime
local UnitClass = _G.UnitClass
local UnitPlayerControlled = _G.UnitPlayerControlled
local UnitName = _G.UnitName
local wipe = _G.wipe
local UnitIsUnit = _G.UnitIsUnit
local UnitGUID = _G.UnitGUID
local GetSpellInfo = _G.GetSpellInfo
local floor = _G.floor
local UnitAuraSlots = _G.UnitAuraSlots
local UnitAuraBySlot = _G.UnitAuraBySlot
local UnitAura = _G.UnitAura
local BackdropTemplateMixin = _G.BackdropTemplateMixin
local NamePlateTooltip = _G.NamePlateTooltip
local BUFF_MAX_DISPLAY = _G.BUFF_MAX_DISPLAY
local _

local DB_AURA_GROW_DIRECTION
local DB_AURA_GROW_DIRECTION2
local DB_AURA_PADDING
local DB_AURA_SEPARATE_BUFFS
local DB_SHOW_PURGE_IN_EXTRA_ICONS
local DB_SHOW_ENRAGE_IN_EXTRA_ICONS
local DB_DEBUFF_BANNED
local DB_AURA_SHOW_IMPORTANT
local DB_AURA_SHOW_BYPLAYER
local DB_BUFF_BANNED
local DB_AURA_SHOW_DISPELLABLE
local DB_AURA_SHOW_ENRAGE
local DB_AURA_SHOW_BYUNIT
local DB_AURA_ALPHA

local DebuffTypeColor = _G.DebuffTypeColor

--> As accessible translator map (where nil needs to resemble "NONE") for modding/scripting to be published in .AuraType:
local AURA_TYPES = {
	[""] = "enrage",
	["Magic"] = "magic",
	["Poison"] = "poison",
	["Curse"] = "curse",
	["nil"] = "none",
}

--> Aura types for usage in AddAura / AddExtraIcon checks
local AURA_TYPE_ENRAGE = "" -- yes, 'enrage' is just empty string for Blizzard...
local AURA_TYPE_MAGIC = "Magic"
local AURA_TYPE_DISEASE = "Disease"
local AURA_TYPE_POISON = "Poison"
local AURA_TYPE_CURSE = "Curse"
local AURA_TYPE_UNKNOWN = nil

local MEMBER_UNITID = "namePlateUnitToken"

local PLATER_REFRESH_ID = 1
function Plater.IncreaseRefreshID_Auras()
    PLATER_REFRESH_ID = PLATER_REFRESH_ID + 1
end

local SCRIPT_AURA = Plater.ScriptAura
local SCRIPT_CASTBAR = Plater.ScriptCastBar
local SCRIPT_UNIT = Plater.ScriptUnit

--caches auras for crowd control, offensives and defensives to determine the border color for special auras, if the aura is in this table, the border will be colored with the respective color
local CROWDCONTROL_AURA_IDS = {}
local OFFENSIVE_AURA_IDS = {}
local DEFENSIVE_AURA_IDS = {}
--list of auras Plater added automatically to special auras, automatic added auras passes throught black list filters while auras manually added by the user do no
local SPECIAL_AURAS_AUTO_ADDED = {}
--list of auras the user added into the track list for special auras, _MINE caches the auras where the user checked the 'Only Mine' checkbox
local SPECIAL_AURAS_USER_LIST = {}
local SPECIAL_AURAS_USER_LIST_MINE = {}

--store aura names to manually track
local MANUAL_TRACKING_BUFFS = {}
local MANUAL_TRACKING_DEBUFFS = {}
local AUTO_TRACKING_EXTRA_BUFFS = {}
local AUTO_TRACKING_EXTRA_DEBUFFS = {}



--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> aura buffs and debuffs ~aura ~buffs ~debuffs ~auras

	--> show the tooltip in the aura icon
	function Plater.OnEnterAura (iconFrame) --private
		NamePlateTooltip:SetOwner (iconFrame, "ANCHOR_LEFT")
		NamePlateTooltip:SetUnitAura (iconFrame:GetParent().unit, iconFrame:GetID(), iconFrame.filter)
		iconFrame.UpdateTooltip = Plater.OnEnterAura
	end

	function Plater.OnLeaveAura (iconFrame) --private
		NamePlateTooltip:Hide()
	end
	
	--called from the options panel, request a refresh on all auras shown
	function Plater.RefreshAuras() --private
		for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
			Plater.NameplateTick (plateFrame.OnTickFrame, 1)
		end
		if Plater.Masque then
			Plater.Masque.AuraFrame1:ReSkin()
			Plater.Masque.AuraFrame2:ReSkin()
			Plater.Masque.BuffSpecial:ReSkin()
			Plater.Masque.BossModIconFrame:ReSkin()
		end
	end
	
	--stack auras with the same name and change the stack text above the icon to indicate how many auras with the same name the unit has
	--self is BuffFrame
	function Plater.ConsolidateAuraIcons (self)
		--get the table where all icon frames are stored in
		local iconFrameContainer = self.PlaterBuffList
		
		--get the amount of auras shown in the frame, this variable should be always reliable
		local amountFramesShown = self.amountAurasShown
		--store icon frames with the same name
		local aurasDuplicated = {}
		
		for i = 1, amountFramesShown do
			local iconFrame = iconFrameContainer [i]
			local texture = iconFrame.texture
			local spellName = iconFrame.SpellName
			local index = spellName .. texture

			if (aurasDuplicated [index]) then
				tinsert (aurasDuplicated [index], {iconFrame, iconFrame.RemainingTime})
			else
				aurasDuplicated [index] = {
					{iconFrame, iconFrame.RemainingTime}
				}
			end
		end

		for index, iconFramesTable in pairs (aurasDuplicated) do
			--how many auras with the same name the unit has
			local amountOfSimilarAuras = #iconFramesTable
			local totalStacks = iconFramesTable [1][1].Stacks > 0 and iconFramesTable [1][1].Stacks or 1
			
			if (amountOfSimilarAuras > 1) then
				--sort order: the aura with the least time left is shown by default
				if (Plater.db.profile.aura_consolidate_timeleft_lower) then
					table.sort (iconFramesTable, DF.SortOrder2R)
				else
					table.sort (iconFramesTable, DF.SortOrder2)
				end
				
				--hide all auras except for the first occurrence of this aura
				for i = 2, amountOfSimilarAuras do
					local iconFrame = iconFramesTable [i][1]
					iconFrame.ShowAnimation:Stop()
					iconFrame:Hide()
					iconFrame.InUse = false
					
					totalStacks = totalStacks + (iconFrame.Stacks > 0 and iconFrame.Stacks or 1)
					
					--decrease the amount of auras shown on the buff frame
					self.amountAurasShown = self.amountAurasShown - 1
				end
				
				--set the stack amount number to indicate how many auras similar to this the unit has
				local stackLabel = iconFramesTable [1][1].StackText
				stackLabel:SetText (totalStacks)
				stackLabel:Show()
			end
		end
	end
	
	
	--sort aura icons according to this function. default is time remaining hight to low (l->r) with 0-duration on the left
	function Plater.AuraIconsSortFunction (aura1, aura2)
		return (aura1.Duration == 0 and 99999999 or aura1.RemainingTime or 0) < (aura2.Duration == 0 and 99999999 or aura2.RemainingTime or 0)
		--return (aura1.Duration == 0 and 99999999 or aura1.RemainingTime or 0) > (aura2.Duration == 0 and 99999999 or aura2.RemainingTime or 0)
	end
	
	--align the aura frame icons currently shown in buff container
	--this function is called after Plater complete the aura update loop
	--at this point, icons shown are reliable icons that has auras that are shown above the nameplate
	--hidden icons aren't in use and should be ignored
	--self is the buff container
	--~align
	function Plater.AlignAuraFrames (self)

		if (self.isNameplate) then
			local profile = Plater.db.profile
			local horizontalLength = 1
			local curRowLength = 0
			local verticalHeight = 1
			local firstIcon
		
			if (Plater.db.profile.aura_consolidate) then
				Plater.ConsolidateAuraIcons (self)
			end
			
			--get the table where all icon frames are stored in
			local iconFrameContainer = self.PlaterBuffList
			--get the amount of auras shown in the frame; iterate over all if not sorting
			local amountFramesShown = #iconFrameContainer
			
			if (profile.aura_sort) then
				local iconFrameContainerCopy = {}
				local index = 0
				for _, icon in pairs(iconFrameContainer) do
					if icon:IsShown() then
						index = index + 1
						iconFrameContainerCopy[index] = icon
					end
				end
				iconFrameContainer = iconFrameContainerCopy
				table.sort (iconFrameContainer, Plater.AuraIconsSortFunction)
				--when sorted, this is reliable
				amountFramesShown = index
			end
		
			local growDirection
			local anchorSide
			local auras_per_row

			--> get the grow direction for the buff frame
			if (self.Name == "Main") then
				growDirection = DB_AURA_GROW_DIRECTION
				anchorSide = profile.aura_frame1_anchor.side
				auras_per_row = profile.auras_per_row_amount
				
			elseif (self.Name == "Secondary") then
				growDirection = DB_AURA_GROW_DIRECTION2
				anchorSide = profile.aura_frame2_anchor.side
				auras_per_row = profile.auras_per_row_amount2
			
			else
				return
			end
			
			if (growDirection ~= 2) then --it's growing to left or right
			
				--debug where the buffFrame anchors are
				--self:SetSize (5, 5)
				--self:SetBackdrop ({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1})
				--self:SetBackdropBorderColor (1, 0, 0, 1)
			
				local aurasPerRow = (not profile.auras_per_row_auto and floor(auras_per_row) or Plater.MaxAurasPerRow)
				local curAurasRowCount = aurasPerRow + 1
				local rowGrowthDirectionUp = (anchorSide < 3 or anchorSide > 5)
				local lineBreakMult = rowGrowthDirectionUp and 1 or -1
				
				--which slot index is being manipulated within the icon loop
				--if an icon is hidden it won't be used and the slot won't increase
				--the slot 1 is guaranteed to always be in use
				local slotId = 1
				
				--which was the last shown and valid icon attached into the visible icon row
				local lastIconUsed
				local relIconPoint
				local relIconPointTo
				local relRowIconPoint
				local relFirstIconPoint
				local paddingMult
				
				--left to right
				if (growDirection == 3) then
					relIconPoint = rowGrowthDirectionUp and "bottomleft" or "topleft"
					relIconPointTo = rowGrowthDirectionUp and "bottomright" or "topright"
					relRowIconPoint = rowGrowthDirectionUp and "topleft" or "bottomleft"
					relFirstIconPoint = rowGrowthDirectionUp and "bottomleft" or "topleft"
					paddingMult = 1
				
				-- <-- right to left
				elseif (growDirection == 1) then
					relIconPoint = rowGrowthDirectionUp and "bottomright" or "topright"
					relIconPointTo = rowGrowthDirectionUp and "bottomleft" or "topleft"
					relRowIconPoint = rowGrowthDirectionUp and "topright" or "bottomright"
					relFirstIconPoint = rowGrowthDirectionUp and "bottomright" or "topright"
					paddingMult = -1
				end
				
				--iterate among all icon frames
				for i = 1, amountFramesShown do
					--get the icon id from the icon frame container
					local iconFrame = iconFrameContainer [i]
					if (iconFrame:IsShown()) then
						iconFrame:ClearAllPoints()
						
						if not firstIcon then
							--set the point of the first icon
							iconFrame:ClearAllPoints()
							iconFrame:SetPoint (relFirstIconPoint, self, relFirstIconPoint, 0, 0)
							firstIcon = iconFrame
							verticalHeight = firstIcon:GetHeight()
						else
							if (slotId == curAurasRowCount) then
								iconFrame:SetPoint (relIconPoint, firstIcon, relRowIconPoint, 0, profile.aura_breakline_space * lineBreakMult)
								curAurasRowCount = curAurasRowCount + aurasPerRow
								--update the first icon to be the first icon in the second row
								firstIcon = iconFrame
								verticalHeight = verticalHeight + profile.aura_breakline_space + firstIcon:GetHeight()
								
							else
								iconFrame:SetPoint (relIconPoint, lastIconUsed, relIconPointTo, DB_AURA_PADDING * paddingMult, 0)
							end
						end
						
						lastIconUsed = iconFrame
						slotId = slotId + 1
					end
				end
				
				horizontalLength = 1 + DB_AURA_PADDING
				
			else --it's growing from center
				
				local previousIcon

				--iterate among all icons in the aura frame
				--set the point of the first icon in the bottom left of the buff frame
				--set the point of all other icons to the right of the previous icon and update the size of the buff frame
				for i = 1, amountFramesShown do
					local iconFrame = iconFrameContainer [i]
					if (iconFrame:IsShown()) then
						curRowLength = curRowLength + iconFrame:GetWidth() + DB_AURA_PADDING
						iconFrame:ClearAllPoints()
						
						if (not firstIcon) then
							firstIcon = iconFrame
							firstIcon:SetPoint ("bottomleft", self, "bottomleft", 0, 0)
							previousIcon = firstIcon
							verticalHeight = firstIcon:GetHeight()
							horizontalLength = curRowLength
							
						else
							iconFrame:SetPoint ("bottomleft", previousIcon, "bottomright", DB_AURA_PADDING, 0)
							previousIcon = iconFrame
						end
					end
				end
				
			end
			
			if (not firstIcon) then
				return
			end
			
			if curRowLength > horizontalLength then
				horizontalLength = curRowLength
			end
			
			--remove 1 icon padding value
			horizontalLength = horizontalLength - DB_AURA_PADDING
			--set the size of the buff frame
			self:SetWidth (horizontalLength)
			self:SetHeight (verticalHeight)
		end
	end

	--adjust the texcoord of the texture by the size of the icon
	--if the icon is more of a retangular shape, it'll cut the top and bottom sides of the texture giving a wide view
	function Plater.UpdateIconAspecRatio (auraIconFrame)
		local width, height = auraIconFrame:GetSize()
		local ratio = width > height and min (max (abs (width / height - 2) + 0.05, 0.6), 1) or .95
		auraIconFrame.Icon:SetTexCoord (.05, .95, .09, ratio)
	end

	function Plater.CreateAuraIcon (parent, name) --private
		local newIcon = CreateFrame ("Button", name, parent, BackdropTemplateMixin and "BackdropTemplate")
		newIcon:Hide()
		newIcon:SetSize (20, 16)
		
		newIcon:SetScript ("OnEnter", Plater.OnEnterAura)
		newIcon:SetScript ("OnLeave", Plater.OnLeaveAura)
		
		newIcon:SetMouseClickEnabled (false)
		
		newIcon.Border = newIcon:CreateTexture (nil, "background")
		newIcon.Border:SetAllPoints()
		newIcon.Border:SetColorTexture (0, 0, 0)
		
		newIcon.Icon = newIcon:CreateTexture (nil, "BORDER")
		newIcon.Icon:SetSize (18, 12)
		newIcon.Icon:SetPoint ("center")
		newIcon.Icon:SetTexCoord (.05, .95, .1, .6)
		
		newIcon.Cooldown = CreateFrame ("cooldown", "$parentCooldown", newIcon, "CooldownFrameTemplate, BackdropTemplate")
		newIcon.Cooldown:SetPoint ("center", 0, -1)
		newIcon.Cooldown:SetAllPoints()
		newIcon.Cooldown:EnableMouse (false)
		newIcon.Cooldown:SetHideCountdownNumbers (true)
		newIcon.Cooldown:Hide()
		
		newIcon.Cooldown.noCooldownCount = Plater.db.profile.disable_omnicc_on_auras
		
		--newIcon.Cooldown:SetSwipeColor (0, 0, 0) --not working
		--newIcon.Cooldown:SetDrawSwipe (false)
		--newIcon.Cooldown:SetSwipeTexture ("Interface\\Garrison\\Garr_TimerFill")
		--newIcon.Cooldown:SetEdgeTexture ("Interface\\Cooldown\\edge-LoC");
		--newIcon.Cooldown:SetReverse (true)
		--newIcon.Cooldown:SetCooldownUNIX (startTime, buildDuration);
		
		newIcon.CountFrame = CreateFrame ("frame", "$parentCountFrame", newIcon, BackdropTemplateMixin and "BackdropTemplate")
		newIcon.CountFrame:SetAllPoints()
		newIcon.CountFrame:EnableMouse (false)
		newIcon.CountFrame.Count = newIcon.CountFrame:CreateFontString (nil, "artwork", "NumberFontNormalSmall")
		newIcon.CountFrame.Count:SetJustifyH ("right")
		newIcon.CountFrame.Count:SetPoint ("bottomright", 3, -2)
		
		--expose to scripts
		newIcon.StackText = newIcon.CountFrame.Count
		
		newIcon.Cooldown.Timer = newIcon.Cooldown:CreateFontString (nil, "overlay", "NumberFontNormal")
		newIcon.Cooldown.Timer:SetPoint ("center")
		newIcon.TimerText = newIcon.Cooldown.Timer

		return newIcon
	end
	
	--create the animation when the icon is shown above the nameplate
	function Plater.CreateShowAuraIconAnimation (iconFrame)
		local showAnimationOnPlay = function()
			
		end
		local showAnimationOnStop = function()
			iconFrame:SetScale(1)
		end
		
		local iconShowInAnimation = {}
	
		local iconShowInAnimationIcon = DF:CreateAnimationHub (iconFrame.Icon, showAnimationOnPlay, showAnimationOnStop)
		DF:CreateAnimation (iconShowInAnimationIcon, "Scale", 1, .05, .7, .7, 1.1, 1.1)
		DF:CreateAnimation (iconShowInAnimationIcon, "Scale", 2, .05, 1.1, 1.1, 1, 1)
		
		local iconShowInAnimationBorder = DF:CreateAnimationHub (iconFrame.Border, showAnimationOnPlay, showAnimationOnStop)
		DF:CreateAnimation (iconShowInAnimationBorder, "Scale", 1, .05, .7, .7, 1.1, 1.1)
		DF:CreateAnimation (iconShowInAnimationBorder, "Scale", 2, .05, 1.1, 1.1, 1, 1)
		
		iconShowInAnimation.iconShowInAnimationIcon = iconShowInAnimationIcon
		iconShowInAnimation.iconShowInAnimationBorder = iconShowInAnimationBorder
		
		function iconShowInAnimation.Play(iconShowInAnimation)
			iconShowInAnimation.iconShowInAnimationIcon:Play()
			iconShowInAnimation.iconShowInAnimationBorder:Play()
		end
		function iconShowInAnimation.Stop(iconShowInAnimation)
			iconShowInAnimation.iconShowInAnimationIcon:Stop()
			iconShowInAnimation.iconShowInAnimationBorder:Stop()
		end
		
		iconFrame.ShowAnimation = iconShowInAnimation
	end
	
	local function aura_icon_on_hide_callback (self)
		self.ShowAnimation:Stop()
		self:OnHideWidget()
	end
	
	--an aura is about to be added in the nameplate, need to get an icon for it ~geticonaura
	function Plater.GetAuraIcon (self, isBuff)
		--self parent = NamePlate_X_UnitFrame
		--self = BuffFrame
		
		local curBuffFrame = 1
		if (isBuff and DB_AURA_SEPARATE_BUFFS) then
			self = self.BuffFrame2
			curBuffFrame = 2
		end
		
		local i = self.NextAuraIcon
		
		if (not self.PlaterBuffList[i]) then
			local newFrameIcon = Plater.CreateAuraIcon (self, self.unitFrame:GetName() .. "Plater" .. self.Name .. "AuraIcon" .. i)
			newFrameIcon.unitFrame = self.unitFrame
			newFrameIcon.spellId = 0
			newFrameIcon.ID = i
			newFrameIcon.RefreshID = 0
			newFrameIcon.IsPersonal = -1 --place holder
			
			self.PlaterBuffList[i] = newFrameIcon
			
			newFrameIcon:SetBackdrop ({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1})
		
			local auraWidth
			local auraHeight
			if curBuffFrame == 2 then
				auraWidth = Plater.db.profile.aura_width2
				auraHeight = Plater.db.profile.aura_height2
			else
				auraWidth = Plater.db.profile.aura_width
			    auraHeight = Plater.db.profile.aura_height
			end
			newFrameIcon:SetSize (auraWidth, auraHeight)
			newFrameIcon.Icon:SetSize (auraWidth-2, auraHeight-2)
			
			--mixin the meta functions for scripts
			DF:Mixin (newFrameIcon, Plater.ScriptMetaFunctions)
			newFrameIcon.IsAuraIcon = true
			newFrameIcon:HookScript ("OnHide", aura_icon_on_hide_callback)
			
			--create the animation for when the icon is shown
			Plater.CreateShowAuraIconAnimation (newFrameIcon)
			
			--masque support
			if (Plater.Masque) then
				if (self.Name == "Main") then
					local t = {
						FloatingBG = nil, --false,
						Icon = newFrameIcon.Icon,
						Cooldown = newFrameIcon.Cooldown,
						Flash = nil, --false,
						Pushed = nil, --false,
						Normal = nil, --false,
						Disabled = nil, --false,
						Checked = nil, --false,
						Border = nil, --newFrameIcon.Border,
						AutoCastable = nil, --false,
						Highlight = nil, --false,
						HotKey = nil, --false,
						Count = false,
						Name = nil, --false,
						Duration = false,
						Shine = nil, --false,
					}
					newFrameIcon.Border:Hide() --let Masque handle the border...
					Plater.Masque.AuraFrame1:AddButton (newFrameIcon, t)
					Plater.Masque.AuraFrame1:ReSkin()
					
				elseif (self.Name == "Secondary") then
					local t = {
						FloatingBG = nil, --false,
						Icon = newFrameIcon.Icon,
						Cooldown = newFrameIcon.Cooldown,
						Flash = nil, --false,
						Pushed = nil, --false,
						Normal = nil, --false,
						Disabled = nil, --false,
						Checked = nil, --false,
						Border = nil, --newFrameIcon.Border,
						AutoCastable = nil, --false,
						Highlight = nil, --false,
						HotKey = nil, --false,
						Count = false,
						Name = nil, --false,
						Duration = false,
						Shine = nil, --false,
					}
					newFrameIcon.Border:Hide() --let Masque handle the border...
					Plater.Masque.AuraFrame2:AddButton (newFrameIcon, t)
					Plater.Masque.AuraFrame2:ReSkin()
					
				end
			end
		end
		
		local auraIconFrame = self.PlaterBuffList [i]
		self.NextAuraIcon = self.NextAuraIcon + 1
		
		return auraIconFrame, self
    end
    

    	
	--update the aura icon, this icon is getted with GetAuraIcon -
	--actualAuraType is the UnitAura return value for the auraType ("" is enrage, nil/"none" for unspecified and "Disease", "Poison", "Curse", "Magic" for other types. -Continuity/Ariani
	            
	function Plater.AddAura (self, auraIconFrame, i, spellName, texture, count, auraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId, isBuff, isShowAll, isDebuff, isPersonal, actualAuraType)
		auraIconFrame:SetID (i)
		local curBuffFrame = self.Name == "Secondary" and 2 or 1

		-- ensure playing show animation if necessary
		if (not auraIconFrame.InUse) then
			auraIconFrame.ShowAnimation:Play()
		end
		
		--> check if the icon is showing a different aura
		if (auraIconFrame.spellId ~= spellId) then
			
			--> update the texture
			auraIconFrame.Icon:SetTexture (texture)
			
			--> update members
			auraIconFrame.spellId = spellId
			auraIconFrame.texture = texture
			auraIconFrame.layoutIndex = auraIconFrame.ID
			auraIconFrame.IsShowingBuff = false
			auraIconFrame.CanStealOrPurge = false
			auraIconFrame.AuraType = AURA_TYPES[actualAuraType] or "none"

			if (auraType == "DEBUFF") then
				auraIconFrame.filter = "HARMFUL"
				auraIconFrame:GetParent().HasDebuff = true
				
			elseif (auraType == "BUFF") then
				auraIconFrame.filter = "HELPFUL"
				auraIconFrame:GetParent().HasBuff = true
				
			else
				auraIconFrame.filter = ""
			end
		end
		
		--> caching the profile for performance
		local profile = Plater.db.profile
		
		self.AuraCache [spellId] = true
		self.AuraCache [spellName] = true
		
		--> check if a full refresh is required
		if (auraIconFrame.RefreshID < PLATER_REFRESH_ID) then

			--stack counter
			local stackLabel = auraIconFrame.CountFrame.Count
			DF:SetFontSize (stackLabel, profile.aura_stack_size)
			
			--DF:SetFontOutline (stackLabel, profile.aura_stack_shadow)
			Plater.SetFontOutlineAndShadow (stackLabel, profile.aura_stack_outline, profile.aura_stack_shadow_color, profile.aura_stack_shadow_color_offset[1], profile.aura_stack_shadow_color_offset[2])
			
			DF:SetFontColor (stackLabel, profile.aura_stack_color)
			DF:SetFontFace (stackLabel, profile.aura_stack_font)
			Plater.SetAnchor (stackLabel, profile.aura_stack_anchor)
			
			--timer
			local timerLabel = auraIconFrame.Cooldown.Timer
			DF:SetFontSize (timerLabel, profile.aura_timer_text_size)
			
			--DF:SetFontOutline (timerLabel, profile.aura_timer_text_shadow)
			Plater.SetFontOutlineAndShadow (timerLabel, profile.aura_timer_text_outline, profile.aura_timer_text_shadow_color, profile.aura_timer_text_shadow_color_offset[1], profile.aura_timer_text_shadow_color_offset[2])
			
			DF:SetFontFace (timerLabel, profile.aura_timer_text_font)
			DF:SetFontColor (timerLabel, profile.aura_timer_text_color)
			Plater.SetAnchor (timerLabel, profile.aura_timer_text_anchor)
			
			auraIconFrame.RefreshID = PLATER_REFRESH_ID
			
			--icon size
			if (isPersonal) then
				local auraWidth = profile.aura_width_personal
				local auraHeight = profile.aura_height_personal
				auraIconFrame:SetSize (auraWidth, auraHeight)
				auraIconFrame.Icon:SetSize (auraWidth-2, auraHeight-2)
			else
				if curBuffFrame == 2 then
					local auraWidth = profile.aura_width2
					local auraHeight = profile.aura_height2
					auraIconFrame:SetSize (auraWidth, auraHeight)
					auraIconFrame.Icon:SetSize (auraWidth-2, auraHeight-2)
				else
					local auraWidth = profile.aura_width
					local auraHeight = profile.aura_height
					auraIconFrame:SetSize (auraWidth, auraHeight)
					auraIconFrame.Icon:SetSize (auraWidth-2, auraHeight-2)
				end
			end
			
			auraIconFrame.Cooldown:SetEdgeTexture (profile.aura_cooldown_edge_texture)
			auraIconFrame.Cooldown:SetReverse (profile.aura_cooldown_reverse)
			auraIconFrame.Cooldown:SetDrawSwipe (profile.aura_cooldown_show_swipe)

			Plater.UpdateIconAspecRatio (auraIconFrame)
			
			--if tooltip enabled
			auraIconFrame:EnableMouse (profile.aura_show_tooltip)
			auraIconFrame:SetMouseClickEnabled (false)
		end

		--icon size repeated due to:
		--when the size is changed in the options it doesnt change the IsPersonal flag
		--when it changes the isPersonal flag it change locally without increasing the refresh ID
		--> update the icon size depending on where it is shown
		if (auraIconFrame.IsPersonal ~= isPersonal or auraIconFrame.BuffFrame ~= curBuffFrame) then
			if (isPersonal) then
				local auraWidth = profile.aura_width_personal
				local auraHeight = profile.aura_height_personal
				auraIconFrame:SetSize (auraWidth, auraHeight)
				auraIconFrame.Icon:SetSize (auraWidth-2, auraHeight-2)
			else
				if curBuffFrame == 2 then
					local auraWidth = profile.aura_width2
					local auraHeight = profile.aura_height2
					auraIconFrame:SetSize (auraWidth, auraHeight)
					auraIconFrame.Icon:SetSize (auraWidth-2, auraHeight-2)
				else
					local auraWidth = profile.aura_width
					local auraHeight = profile.aura_height
					auraIconFrame:SetSize (auraWidth, auraHeight)
					auraIconFrame.Icon:SetSize (auraWidth-2, auraHeight-2)
				end
			end
			
			Plater.UpdateIconAspecRatio (auraIconFrame)
		end
		auraIconFrame.IsPersonal = isPersonal
		auraIconFrame.BuffFrame = self.Name == "Secondary" and 2 or 1

		if (count > 1) then
			local stackLabel = auraIconFrame.CountFrame.Count
			stackLabel:SetText (count)
			stackLabel:Show()
		else
			auraIconFrame.CountFrame.Count:Hide()
		end
		
		--border colors
		if (canStealOrPurge) then
			auraIconFrame:SetBackdropBorderColor (unpack (profile.aura_border_colors.steal_or_purge))
			auraIconFrame.CanStealOrPurge = true
		
		elseif (Plater.db.profile.aura_border_colors_by_type) then
			-- use Blizzards color global 'DebuffTypeColor' for the actual color:
			local color = DebuffTypeColor[actualAuraType or "none"] or {r=0,b=0,g=0, a=0}
			auraIconFrame:SetBackdropBorderColor (color.r, color.g, color.b, color.a or 1)
		
		elseif (CROWDCONTROL_AURA_IDS [spellId]) then 
			--> CC effects
			auraIconFrame:SetBackdropBorderColor (unpack (profile.aura_border_colors.crowdcontrol))
		
		elseif (OFFENSIVE_AURA_IDS [spellId]) then 
			--> offensive CDs
			auraIconFrame:SetBackdropBorderColor (unpack (profile.aura_border_colors.offensive))
		
		elseif (DEFENSIVE_AURA_IDS [spellId]) then 
			--> defensive CDs
			auraIconFrame:SetBackdropBorderColor (unpack (profile.aura_border_colors.defensive))
			
		elseif (isBuff) then
			auraIconFrame:SetBackdropBorderColor (unpack (profile.aura_border_colors.is_buff))
			auraIconFrame.IsShowingBuff = true
		
		elseif (isDebuff) then
			--> for debuffs on the player for the personal bar
			auraIconFrame:SetBackdropBorderColor (1, 0, 0, 1)
		
		elseif (actualAuraType == AURA_TYPE_ENRAGE) then 
			--> enrage effects
			auraIconFrame:SetBackdropBorderColor (unpack (profile.aura_border_colors.enrage))
		
		elseif (isShowAll) then
			auraIconFrame:SetBackdropBorderColor (unpack (profile.aura_border_colors.is_show_all))
				
		else
			auraIconFrame:SetBackdropBorderColor (0, 0, 0, 0)
			
		end

		CooldownFrame_Set (auraIconFrame.Cooldown, expirationTime - duration, duration, duration > 0, true)
		local timeLeft = expirationTime-GetTime()
		
		if (profile.aura_timer and timeLeft > 0) then
			--> update the aura timer
			local timerLabel = auraIconFrame.Cooldown.Timer
		
			timerLabel:SetText (Plater.FormatTime (timeLeft))
			timerLabel:Show()
		else
			auraIconFrame.Cooldown.Timer:Hide()
		end
		
		--check if the aura icon frame is already shown
		if (auraIconFrame:IsShown()) then
			--is was showing a different aura, simulate a OnHide()
			if (auraIconFrame.SpellName ~= spellName) then
				aura_icon_on_hide_callback(auraIconFrame)
			end
		end
		
		--> spell name must be update here and cannot be cached due to scripts
		auraIconFrame.SpellName = spellName
		auraIconFrame.SpellId = spellId
		auraIconFrame.InUse = true
		auraIconFrame.RemainingTime = max (expirationTime - GetTime(), 0)
		auraIconFrame.Duration = duration
		auraIconFrame.Stacks = count
		auraIconFrame.ExpirationTime = expirationTime
		auraIconFrame.Caster = caster
		auraIconFrame:Show()
		
		--get the script object of the aura which will be showing in this icon frame
		local globalScriptObject = SCRIPT_AURA [spellName]
		
		--check if this aura has a custom script
		if (globalScriptObject) then
			--stored information about scripts
			local scriptContainer = auraIconFrame:ScriptGetContainer()
			
			--get the info about this particularly script
			local scriptInfo = auraIconFrame:ScriptGetInfo (globalScriptObject, scriptContainer)
			
			--set the aura information on the script env
			local scriptEnv = scriptInfo.Env
			scriptEnv._SpellID = spellId
			scriptEnv._UnitID = caster
			scriptEnv._SpellName = spellName
			scriptEnv._Texture = texture
			scriptEnv._Caster = caster
			scriptEnv._StackCount = count
			scriptEnv._Duration = duration
			scriptEnv._StartTime = expirationTime - duration
			scriptEnv._EndTime = expirationTime
			scriptEnv._RemainingTime = max (expirationTime - GetTime(), 0)
			scriptEnv._CanStealOrPurge = canStealOrPurge
			scriptEnv._AuraType = AURA_TYPES[actualAuraType] or "none"
			
			--run onupdate script
			auraIconFrame:ScriptRunOnUpdate (scriptInfo)
		end	
		
		--Plater.Masque.AuraFrame1:ReSkin()

		--auraIconFrame.Icon:Hide()
		--auraIconFrame.Cooldown:SetBackdrop (nil)
		--print (auraIconFrame.Border:GetObjectType())
		--print (auraIconFrame.Icon:GetAlpha())
		
		--print (self:GetName(), self:GetSize(), self:IsShown())
		
		return true
	end

	--> check both buff frames for aura icons which aren't in use and hide them
	Plater.HideNonUsedAuraIcons = function (self)
	
		--aura frame 1
		local nextAuraIndex = self.NextAuraIcon
		for i = nextAuraIndex, #self.PlaterBuffList do
			local icon = self.PlaterBuffList [i]
			if (icon and icon.InUse and icon:IsShown()) then
				icon.ShowAnimation:Stop()
				icon:Hide()
				icon.InUse = false
			end
		end
		
		--save the amount of auras shown
		--used to move up the resource frame when it is shown on current target
		--also used on the aura align function
		self.amountAurasShown = self.NextAuraIcon - 1
		
		--aura frame 2
		if (DB_AURA_SEPARATE_BUFFS) then
			--secondary buff frame
			local buffFrame2 = self.BuffFrame2

			local nextAuraIndex = buffFrame2.NextAuraIcon
			for i = nextAuraIndex, #buffFrame2.PlaterBuffList do
				local icon = buffFrame2.PlaterBuffList [i]
				if (icon and icon.InUse and icon:IsShown()) then
					icon.ShowAnimation:Stop()
					icon:Hide()
					icon.InUse = false
				end
			end
			
			--save the amount of auras shown
			buffFrame2.amountAurasShown = buffFrame2.NextAuraIcon - 1
		end
		
		--move up the resource frame if shown
		Plater.UpdateResourceFrameAnchor (self)
	end

	--~special ~auraspecial
	function Plater.AddExtraIcon (self, spellName, texture, count, debuffType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId, filter, id)
		local _, casterClass = UnitClass(caster or "")
		local casterName
		if (casterClass and UnitPlayerControlled(caster)) then
			--adding only the name for players in case the player used a stun
			casterName = UnitName(caster)
		end
		
		local borderColor
		
		if (canStealOrPurge) then
			borderColor = Plater.db.profile.extra_icon_show_purge_border
			
		elseif (Plater.db.profile.extra_icon_use_blizzard_border_color) then
			-- use blizzard border colors
			local color = DebuffTypeColor[actualAuraType or "none"] or {r=0,b=0,g=0, a=0} --actualAuraType is a global? it have been not passed
			borderColor = {color.r, color.g, color.b, color.a or 1}
			
		elseif (CROWDCONTROL_AURA_IDS [spellId]) then
			borderColor = Plater.db.profile.debuff_show_cc_border
		
		elseif (DEFENSIVE_AURA_IDS [spellId]) then 
			--> defensive effects
			borderColor = Plater.db.profile.extra_icon_show_defensive_border
		
		elseif (OFFENSIVE_AURA_IDS [spellId]) then 
			--> offensive effects
			borderColor = Plater.db.profile.extra_icon_show_offensive_border
		
		elseif (debuffType == AURA_TYPE_ENRAGE) then 
			--> enrage effects
			borderColor = Plater.db.profile.extra_icon_show_enrage_border
		
		else
			borderColor = Plater.db.profile.extra_icon_border_color
			
		end
		
		--spellId, borderColor, startTime, duration, forceTexture, descText
		local iconFrame = self.ExtraIconFrame:SetIcon (spellId, borderColor, expirationTime - duration, duration, false, casterName and {text = casterName, text_color = casterClass} or false, count, debuffType, caster, canStealOrPurge)
		
		-- tooltip info
		iconFrame:SetID (id)
		iconFrame.filter = filter
		iconFrame:SetScript ("OnEnter", Plater.OnEnterAura)
		iconFrame:SetScript ("OnLeave", Plater.OnLeaveAura)
		iconFrame:EnableMouse (Plater.db.profile.aura_show_tooltip)
		
		
		--add the spell into the cache
		self.ExtraIconFrame.AuraCache [spellId] = true
		self.ExtraIconFrame.AuraCache [spellName] = true
		
		--check if Masque is enabled on Plater and reskin the aura icon
		if (Plater.Masque and not iconFrame.Masqued) then
			local t = {
				FloatingBG = nil, --false,
				Icon = iconFrame.Texture,
				Cooldown = iconFrame.Cooldown,
				Flash = nil, --false,
				Pushed = nil, --false,
				Normal = false,
				Disabled = nil, --false,
				Checked = nil, --false,
				Border = nil, --iconFrame.Border,
				AutoCastable = nil, --false,
				Highlight = nil, --false,
				HotKey = nil, --false,
				Count = false,
				Name = nil, --false,
				Duration = false,
				Shine = nil, --false,
			}
			iconFrame.Border:Hide() --let Masque handle the border...
			Plater.Masque.BuffSpecial:AddButton (iconFrame, t)
			Plater.Masque.BuffSpecial:ReSkin()
			iconFrame.Masqued = true
		end
	end
	
	--> reset both buff frames to make them ready to receive an aura update
	function Plater.ResetAuraContainer (self)
		--> reset the extra icon frame
		self.ExtraIconFrame:ClearIcons()

		--> reset next aura icon to use
		self.NextAuraIcon = 1
		self.BuffFrame2.NextAuraIcon = 1
		
		--> reset auras
		self.HasBuff = false
		self.HasDebuff = false
		
		--> second buff anchor
		self.BuffFrame2.HasBuff = false 
		self.BuffFrame2.HasDebuff = false
		
		--> wipe the cache
		wipe (self.AuraCache)
		wipe (self.BuffFrame2.AuraCache)
		wipe (self.ExtraIconFrame.AuraCache)
		wipe (self.unitFrame.AuraCache)
		
	end

	
	-- ~auras ~aura
	--receives a hash table with spell names keys and true as the value
	--used when the user selects manual aura tracking
	function Plater.TrackSpecificAuras (self, unit, isBuff, aurasToCheck, isPersonal, noSpecial)
		local unitAuraCache = self.unitFrame.AuraCache

		if (isBuff) then
			--> buffs
			local buffIndex = 0
			local continuationToken
			repeat -- until continuationToken == nil
				local numSlots = 0
				local slots
				if IS_WOW_PROJECT_MAINLINE then
					slots = { UnitAuraSlots(unit, "HELPFUL", BUFF_MAX_DISPLAY, continuationToken) }
					continuationToken = slots[1]
					numSlots = #slots
				else
					numSlots = BUFF_MAX_DISPLAY + 1
				end
				
				for i=2, numSlots do
					local name, texture, count, actualAuraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, isCastByPlayer, nameplateShowAll
					if IS_WOW_PROJECT_MAINLINE then
						local slot = slots[i]
						name, texture, count, actualAuraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, isCastByPlayer, nameplateShowAll = UnitAuraBySlot(unit, slot)
					else
						name, texture, count, actualAuraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId = UnitAura(unit, i-1, "HELPFUL")
						if not name then
							break
						end
					end
					
					buffIndex = buffIndex + 1
					
					unitAuraCache[name] = true
					unitAuraCache[spellId] = true
					unitAuraCache.canStealOrPurge = unitAuraCache.canStealOrPurge or canStealOrPurge
					unitAuraCache.hasEnrage = unitAuraCache.hasEnrage or actualAuraType == AURA_TYPE_ENRAGE
					
					local auraType = "BUFF"
					--verify is this aura is in the table passed
					if (aurasToCheck [name] or aurasToCheck [spellId]) then
						local auraIconFrame, buffFrame = Plater.GetAuraIcon (self, true)
						Plater.AddAura (buffFrame, auraIconFrame, buffIndex, name, texture, count, auraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId, true, false, false, isPersonal, actualAuraType)
					end
					
					--> check if is a special aura
					if (not noSpecial) then
						--> check for special auras auto added by setting like 'show crowd control' or 'show dispellable'
						--> SPECIAL_AURAS_AUTO_ADDED has a list of crowd control not do not have a list of dispellable, so check if canStealOrPurge.
						--> in addition, we want to check if enrage tracking is enabled and show enrage effects
						if (SPECIAL_AURAS_AUTO_ADDED [name] or SPECIAL_AURAS_AUTO_ADDED [spellId] or (DB_SHOW_PURGE_IN_EXTRA_ICONS and canStealOrPurge) or (DB_SHOW_ENRAGE_IN_EXTRA_ICONS and actualAuraType == AURA_TYPE_ENRAGE)) then
							Plater.AddExtraIcon (self, name, texture, count, actualAuraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId, "HELPFUL", buffIndex)
						
						--> check for special auras added by the user it self
						elseif (((SPECIAL_AURAS_USER_LIST [name] or SPECIAL_AURAS_USER_LIST [spellId]) and not (SPECIAL_AURAS_USER_LIST_MINE [name] or SPECIAL_AURAS_USER_LIST_MINE [spellId])) or ((SPECIAL_AURAS_USER_LIST_MINE [name] or SPECIAL_AURAS_USER_LIST_MINE [spellId]) and caster and (UnitIsUnit (caster, "player") or UnitIsUnit (caster, "pet")))) then
							Plater.AddExtraIcon (self, name, texture, count, actualAuraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId, "HELPFUL", buffIndex)
							
						end
					end
				end
			until continuationToken == nil
		else
			--> debuffs
			local debuffIndex = 0
			local continuationToken
			repeat -- until continuationToken == nil
				local numSlots = 0
				local slots
				if IS_WOW_PROJECT_MAINLINE then
					slots = { UnitAuraSlots(unit, "HARMFUL", BUFF_MAX_DISPLAY, continuationToken) }
					continuationToken = slots[1]
					numSlots = #slots
				else
					numSlots = BUFF_MAX_DISPLAY + 1
				end
				
				for i=2, numSlots do
					local name, texture, count, actualAuraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, isCastByPlayer, nameplateShowAll
					if IS_WOW_PROJECT_MAINLINE then
						local slot = slots[i]
						name, texture, count, actualAuraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, isCastByPlayer, nameplateShowAll = UnitAuraBySlot(unit, slot)
					else
						name, texture, count, actualAuraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId = UnitAura(unit, i-1, "HARMFUL")
						if not name then
							break
						end
					end
					
					debuffIndex = debuffIndex + 1
					
					unitAuraCache[name] = true
					unitAuraCache[spellId] = true
					unitAuraCache.canStealOrPurge = unitAuraCache.canStealOrPurge or canStealOrPurge
					unitAuraCache.hasEnrage = unitAuraCache.hasEnrage or actualAuraType == AURA_TYPE_ENRAGE
					
					local auraType = "DEBUFF"
					--checking here if the debuff is placed by the player
					--if (caster and aurasToCheck [name] and UnitIsUnit (caster, "player")) then --this doesn't track the pet, so auras like freeze from mage frost elemental won't show
					if (caster and (aurasToCheck [name] or aurasToCheck [spellId]) and (UnitIsUnit (caster, "player") or UnitIsUnit (caster, "pet"))) then
					--if (aurasToCheck [name]) then
						local auraIconFrame, buffFrame = Plater.GetAuraIcon (self)
						Plater.AddAura (buffFrame, auraIconFrame, debuffIndex, name, texture, count, auraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId, false, false, false, isPersonal, actualAuraType)
					end
					
					--> check if is a special aura
					if (not noSpecial) then
						--> check for special auras auto added by setting like 'show crowd control' or 'show dispellable'
						--> SPECIAL_AURAS_AUTO_ADDED has a list of crowd control not do not have a list of dispellable, so check if canStealOrPurge
						--> in addition, we want to check if enrage tracking is enabled and show enrage effects
						if (SPECIAL_AURAS_AUTO_ADDED [name] or SPECIAL_AURAS_AUTO_ADDED [spellId] or (DB_SHOW_PURGE_IN_EXTRA_ICONS and canStealOrPurge) or (DB_SHOW_ENRAGE_IN_EXTRA_ICONS and actualAuraType == AURA_TYPE_ENRAGE)) then
							Plater.AddExtraIcon (self, name, texture, count, actualAuraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId, "HARMFUL", debuffIndex)
						
						--> check for special auras added by the user it self
						elseif (((SPECIAL_AURAS_USER_LIST [name] or SPECIAL_AURAS_USER_LIST [spellId]) and not (SPECIAL_AURAS_USER_LIST_MINE [name] or SPECIAL_AURAS_USER_LIST_MINE [spellId])) or ((SPECIAL_AURAS_USER_LIST_MINE [name] or SPECIAL_AURAS_USER_LIST_MINE [spellId]) and caster and (UnitIsUnit (caster, "player") or UnitIsUnit (caster, "pet")))) then
							Plater.AddExtraIcon (self, name, texture, count, actualAuraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId, "HARMFUL", debuffIndex)
							
						end
					end
				end
			until continuationToken == nil
		end
		
		return true
	end
	
	function Plater.UpdateAuras_Manual (self, unit, isPersonal)
		Plater.StartLogPerformanceCore("Plater-Core", "Update", "UpdateAuras_Manual")
		
		Plater.ResetAuraContainer (self)
		
		if isPersonal then
			if (Plater.db.profile.aura_show_debuffs_personal) then
				Plater.TrackSpecificAuras (self, unit, false, MANUAL_TRACKING_DEBUFFS, isPersonal)
			end
			if (Plater.db.profile.aura_show_buffs_personal) then
				Plater.TrackSpecificAuras (self, unit, true, MANUAL_TRACKING_BUFFS, isPersonal)
			end
		else
			Plater.TrackSpecificAuras (self, unit, false, MANUAL_TRACKING_DEBUFFS, isPersonal)
			Plater.TrackSpecificAuras (self, unit, true, MANUAL_TRACKING_BUFFS, isPersonal)
		end

		--> hide not used aura frames
		Plater.HideNonUsedAuraIcons (self)
		
		Plater.EndLogPerformanceCore("Plater-Core", "Update", "UpdateAuras_Manual")
	end

	--> track auras automatically when the user has automatic aura tracking selected in the options panel
	function Plater.UpdateAuras_Automatic (self, unit)
		Plater.StartLogPerformanceCore("Plater-Core", "Update", "UpdateAuras_Automatic")
		
		Plater.ResetAuraContainer (self)
		local unitAuraCache = self.unitFrame.AuraCache
		
		--> debuffs
			local debuffIndex = 0
			local continuationToken
			repeat -- until continuationToken == nil
				local numSlots = 0
				local slots
				if IS_WOW_PROJECT_MAINLINE then
					slots = { UnitAuraSlots(unit, "HARMFULL", BUFF_MAX_DISPLAY, continuationToken) }
					continuationToken = slots[1]
					numSlots = #slots
				else
					numSlots = BUFF_MAX_DISPLAY + 1
				end
				
				for i=2, numSlots do
					local name, texture, count, actualAuraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, isCastByPlayer, nameplateShowAll
					if IS_WOW_PROJECT_MAINLINE then
						local slot = slots[i]
						name, texture, count, actualAuraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, isCastByPlayer, nameplateShowAll = UnitAuraBySlot(unit, slot)
					else
						name, texture, count, actualAuraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId = UnitAura(unit, i-1, "HARMFUL")
						if not name then
							break
						end
					end
					
					debuffIndex = debuffIndex + 1
					
					--start as false, during the checks can be changed to true, if is true this debuff is added on the nameplate
					local can_show_this_debuff
					local auraType = "DEBUFF"
					
					unitAuraCache[name] = true
					unitAuraCache[spellId] = true
					unitAuraCache.canStealOrPurge = unitAuraCache.canStealOrPurge or canStealOrPurge
					unitAuraCache.hasEnrage = unitAuraCache.hasEnrage or actualAuraType == AURA_TYPE_ENRAGE

					--check if the debuff isn't filtered out
					if (not DB_DEBUFF_BANNED [name] and not DB_DEBUFF_BANNED [spellId]) then
				
						--> if true it'll show all auras - this can be called from scripts to debug aura things
						if (Plater.DebugAuras) then
							if (duration and duration < 60) then
								can_show_this_debuff = true
							end
						end
				
						--> important aura
						if (DB_AURA_SHOW_IMPORTANT and (nameplateShowAll or isBossDebuff)) then
							can_show_this_debuff = true
						
						--> is casted by the player
						elseif (DB_AURA_SHOW_BYPLAYER and caster and (UnitIsUnit (caster, "player") or UnitIsUnit (caster, "pet") or Plater.PlayerPetCache[UnitGUID(caster)])) then
							can_show_this_debuff = true
							
						--> user added this buff to track in the buff tracking tab
						elseif (AUTO_TRACKING_EXTRA_DEBUFFS [name] or AUTO_TRACKING_EXTRA_DEBUFFS [spellId]) then
							can_show_this_debuff = true
						end
						
						--> check for special auras auto added by setting like 'show crowd control' or 'show dispellable'
						--> SPECIAL_AURAS_AUTO_ADDED has a list of crowd control not do not have a list of dispellable, so check if canStealOrPurge
						--> in addition, we want to check if enrage tracking is enabled and show enrage effects
						if (SPECIAL_AURAS_AUTO_ADDED [name] or SPECIAL_AURAS_AUTO_ADDED [spellId] or (DB_SHOW_PURGE_IN_EXTRA_ICONS and canStealOrPurge) or (DB_SHOW_ENRAGE_IN_EXTRA_ICONS and actualAuraType == AURA_TYPE_ENRAGE)) then
							Plater.AddExtraIcon (self, name, texture, count, actualAuraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId, "HARMFUL", debuffIndex)
							can_show_this_debuff = false
						end
					end
					
					--> check for special auras added by the user it self
					if (can_show_this_debuff ~= false and (((SPECIAL_AURAS_USER_LIST [name] or SPECIAL_AURAS_USER_LIST [spellId]) and not (SPECIAL_AURAS_USER_LIST_MINE [name] or SPECIAL_AURAS_USER_LIST_MINE [spellId])) or ((SPECIAL_AURAS_USER_LIST_MINE [name] or SPECIAL_AURAS_USER_LIST_MINE [spellId]) and caster and (UnitIsUnit (caster, "player") or UnitIsUnit (caster, "pet"))))) then
						Plater.AddExtraIcon (self, name, texture, count, actualAuraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId, "HARMFUL", debuffIndex)
						can_show_this_debuff = false
					end
					
					if (can_show_this_debuff) then
						--get the icon to be used by this aura
						local auraIconFrame, buffFrame = Plater.GetAuraIcon (self)
						Plater.AddAura (buffFrame, auraIconFrame, debuffIndex, name, texture, count, auraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId, nil, nil, nil, nil, actualAuraType)
					end
				end
			until continuationToken == nil
		
		--> buffs
			local buffIndex = 0
			local continuationToken
			repeat -- until continuationToken == nil
				local numSlots = 0
				local slots
				if IS_WOW_PROJECT_MAINLINE then
					slots = { UnitAuraSlots(unit, "HELPFUL", BUFF_MAX_DISPLAY, continuationToken) }
					continuationToken = slots[1]
					numSlots = #slots
				else
					numSlots = BUFF_MAX_DISPLAY + 1
				end
				
				for i=2, numSlots do
					local name, texture, count, actualAuraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, isCastByPlayer, nameplateShowAll
					if IS_WOW_PROJECT_MAINLINE then
						local slot = slots[i]
						name, texture, count, actualAuraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, isCastByPlayer, nameplateShowAll = UnitAuraBySlot(unit, slot)
					else
						name, texture, count, actualAuraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId = UnitAura(unit, i-1, "HELPFUL")
						if not name then
							break
						end
					end
					
					buffIndex = buffIndex + 1
					
					local auraType = "BUFF"
					
					unitAuraCache[name] = true
					unitAuraCache[spellId] = true
					unitAuraCache.canStealOrPurge = unitAuraCache.canStealOrPurge or canStealOrPurge
					unitAuraCache.hasEnrage = unitAuraCache.hasEnrage or actualAuraType == AURA_TYPE_ENRAGE
					
					--> check for special auras added by the user it self
					if (((SPECIAL_AURAS_USER_LIST [name] or SPECIAL_AURAS_USER_LIST [spellId]) and not (SPECIAL_AURAS_USER_LIST_MINE [name] or SPECIAL_AURAS_USER_LIST_MINE [spellId])) or ((SPECIAL_AURAS_USER_LIST_MINE [name] or SPECIAL_AURAS_USER_LIST_MINE [spellId]) and caster and (UnitIsUnit (caster, "player") or UnitIsUnit (caster, "pet")))) then
						Plater.AddExtraIcon (self, name, texture, count, actualAuraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId, "HELPFUL", buffIndex)
						
					elseif (not DB_BUFF_BANNED [name] and not DB_BUFF_BANNED [spellId]) then
						--> if true it'll show all auras - this can be called from scripts to debug aura things
						if (Plater.DebugAuras) then
							if (duration and duration < 60) then
								local auraIconFrame, buffFrame = Plater.GetAuraIcon (self, true)
								Plater.AddAura (buffFrame, auraIconFrame, buffIndex, name, texture, count, auraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId, true, nil, nil, nil, actualAuraType)
							end
						end
						
						--> this special aura check is inside the 'buff banned' prevented because they are automatic added
						--> check for special auras auto added by setting like 'show crowd control' or 'show dispellable'
						--> SPECIAL_AURAS_AUTO_ADDED has a list of crowd control not do not have a list of dispellable, so check if canStealOrPurge
						--> in addition, we want to check if enrage tracking is enabled and show enrage effects
						if (SPECIAL_AURAS_AUTO_ADDED [name] or SPECIAL_AURAS_AUTO_ADDED [spellId] or (DB_SHOW_PURGE_IN_EXTRA_ICONS and canStealOrPurge) or (DB_SHOW_ENRAGE_IN_EXTRA_ICONS and actualAuraType == AURA_TYPE_ENRAGE)) then
							Plater.AddExtraIcon (self, name, texture, count, actualAuraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId, "HELPFUL", buffIndex)
						else
							--> important aura
							if (DB_AURA_SHOW_IMPORTANT and (nameplateShowAll or isBossDebuff)) then
								local auraIconFrame, buffFrame = Plater.GetAuraIcon (self, true)
								Plater.AddAura (buffFrame, auraIconFrame, buffIndex, name, texture, count, auraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId, false, true, nil, nil, actualAuraType)
							
							--> is dispellable or can be steal
							elseif (DB_AURA_SHOW_DISPELLABLE and canStealOrPurge) then
								local auraIconFrame, buffFrame = Plater.GetAuraIcon (self, true)
								Plater.AddAura (buffFrame, auraIconFrame, buffIndex, name, texture, count, auraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId, nil, nil, nil, nil, actualAuraType)
                                
							--> is enrage
							elseif (DB_AURA_SHOW_ENRAGE and actualAuraType == AURA_TYPE_ENRAGE) then
								local auraIconFrame, buffFrame = Plater.GetAuraIcon (self, true)
								Plater.AddAura (buffFrame, auraIconFrame, buffIndex, name, texture, count, auraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId, nil, nil, nil, nil, actualAuraType)
							
							--> is casted by the player
							elseif (DB_AURA_SHOW_BYPLAYER and caster and UnitIsUnit (caster, "player")) then
								local auraIconFrame, buffFrame = Plater.GetAuraIcon (self, true)
								Plater.AddAura (buffFrame, auraIconFrame, buffIndex, name, texture, count, auraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId, nil, nil, nil, nil, actualAuraType)
							
							--> is casted by the unit it self
							elseif (DB_AURA_SHOW_BYUNIT and caster and UnitIsUnit (caster, unit) and not isCastByPlayer) then
								local auraIconFrame, buffFrame = Plater.GetAuraIcon (self, true)
								Plater.AddAura (buffFrame, auraIconFrame, buffIndex, name, texture, count, auraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId, true, nil, nil, nil, actualAuraType)
							
							--> user added this buff to track in the buff tracking tab
							elseif (AUTO_TRACKING_EXTRA_BUFFS [name] or AUTO_TRACKING_EXTRA_BUFFS [spellId]) then
								local auraIconFrame, buffFrame = Plater.GetAuraIcon (self, true)
								Plater.AddAura (buffFrame, auraIconFrame, buffIndex, name, texture, count, auraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId, true, nil, nil, nil, actualAuraType)
								
							end
						end

					end
				end
			until continuationToken == nil
		
		--hide non used icons
			Plater.HideNonUsedAuraIcons (self)
			
		Plater.EndLogPerformanceCore("Plater-Core", "Update", "UpdateAuras_Automatic")
	end

	--used in scripts to get a specific buff from the unit, return full information
	--can be used with spellId or spellName
	function Plater.GetAura(unitId, spellName) --alias
		return Plater.GetBuff(unitId, spellName)
	end
	function Plater.GetBuff(unitId, spellName)
		if (type(spellName) == "number") then
			spellName = GetSpellInfo(spellName)
		end

		if (not spellName) then
			return
		end

		spellName =  spellName:lower()

		local continuationToken
		repeat
			local slots = { UnitAuraSlots(unitId, "HELPFUL", BUFF_MAX_DISPLAY, continuationToken) }
			continuationToken = slots[1]
			for i=2, #slots do
				local slot = slots[i];
				local name, texture, count, actualAuraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, isCastByPlayer, nameplateShowAll = UnitAuraBySlot(unitId, slot)
				if (name) then
					if (name:lower()  == spellName) then
						return name, texture, count, actualAuraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, isCastByPlayer, nameplateShowAll
					end
				end
			end
		until not continuationToken

		local continuationToken
		repeat
			local slots = { UnitAuraSlots(unitId, "HARMFUL", BUFF_MAX_DISPLAY, continuationToken) }
			continuationToken = slots[1]
			for i=2, #slots do
				local slot = slots[i];
				local name, texture, count, actualAuraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, isCastByPlayer, nameplateShowAll = UnitAuraBySlot(unitId, slot)
				if (name) then
					if (name:lower()  == spellName) then
						return name, texture, count, actualAuraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, isCastByPlayer, nameplateShowAll
					end
				end
			end
		until not continuationToken
	end

	function Plater.UpdateAuras_Self_Automatic (self)
		Plater.StartLogPerformanceCore("Plater-Core", "Update", "UpdateAuras_Self_Automatic")
		
		Plater.ResetAuraContainer (self)
		local unitAuraCache = self.unitFrame.AuraCache
		local noBuffDurationLimitation = Plater.db.profile.aura_show_all_duration_buffs_personal
		
		--> debuffs
		if (Plater.db.profile.aura_show_debuffs_personal) then
			local debuffIndex = 0
			local continuationToken
			repeat -- until continuationToken == nil
				local numSlots = 0
				local slots
				if IS_WOW_PROJECT_MAINLINE then
					slots = { UnitAuraSlots("player", "HARMFUL", BUFF_MAX_DISPLAY, continuationToken) }
					continuationToken = slots[1]
					numSlots = #slots
				else
					numSlots = BUFF_MAX_DISPLAY + 1
				end
				
				for i=2, numSlots do
					local name, texture, count, actualAuraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, isCastByPlayer, nameplateShowAll
					if IS_WOW_PROJECT_MAINLINE then
						local slot = slots[i]
						name, texture, count, actualAuraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, isCastByPlayer, nameplateShowAll = UnitAuraBySlot("player", slot)
					else
						name, texture, count, actualAuraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId = UnitAura("player", i-1, "HARMFUL")
						if not name then
							break
						end
					end

					debuffIndex = debuffIndex + 1
					
					local auraType = "DEBUFF"
					
					unitAuraCache[name] = true
					unitAuraCache[spellId] = true
					unitAuraCache.canStealOrPurge = unitAuraCache.canStealOrPurge or canStealOrPurge
					unitAuraCache.hasEnrage = unitAuraCache.hasEnrage or actualAuraType == AURA_TYPE_ENRAGE
						
					if (not DB_DEBUFF_BANNED [name] and not DB_DEBUFF_BANNED [spellId]) then
						local auraIconFrame, buffFrame = Plater.GetAuraIcon (self)
						Plater.AddAura (buffFrame, auraIconFrame, debuffIndex, name, texture, count, auraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId, false, false, true, true, actualAuraType)
						
						--> check for special auras auto added by setting like 'show crowd control' or 'show dispellable'
						--> SPECIAL_AURAS_AUTO_ADDED has a list of crowd control not do not have a list of dispellable, so check if canStealOrPurge
						--> in addition, we want to check if enrage tracking is enabled and show enrage effects
						if (SPECIAL_AURAS_AUTO_ADDED [name] or SPECIAL_AURAS_AUTO_ADDED [spellId] or (DB_SHOW_PURGE_IN_EXTRA_ICONS and canStealOrPurge) or (DB_SHOW_ENRAGE_IN_EXTRA_ICONS and actualAuraType == AURA_TYPE_ENRAGE)) then
							Plater.AddExtraIcon (self, name, texture, count, actualAuraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId, "HARMFUL", debuffIndex)
						end
					end
					
					--> check for special auras added by the user it self
					if (((SPECIAL_AURAS_USER_LIST [name] or SPECIAL_AURAS_USER_LIST [spellId]) and not (SPECIAL_AURAS_USER_LIST_MINE [name] or SPECIAL_AURAS_USER_LIST_MINE [spellId])) or ((SPECIAL_AURAS_USER_LIST_MINE [name] or SPECIAL_AURAS_USER_LIST_MINE [spellId]) and caster and (UnitIsUnit (caster, "player") or UnitIsUnit (caster, "pet")))) then
						Plater.AddExtraIcon (self, name, texture, count, actualAuraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId, "HARMFUL", debuffIndex)
					end
					
				end
			until continuationToken == nil
		end
		
		--> buffs
		local buffIndex = 0
		if (Plater.db.profile.aura_show_buffs_personal) then
			local continuationToken
			repeat -- until continuationToken == nil
				local numSlots = 0
				local slots
				if IS_WOW_PROJECT_MAINLINE then
					slots = { UnitAuraSlots("player", "HELPFUL|PLAYER", BUFF_MAX_DISPLAY, continuationToken) }
					continuationToken = slots[1]
					numSlots = #slots
				else
					numSlots = BUFF_MAX_DISPLAY + 1
				end
				
				for i=2, numSlots do
					local name, texture, count, actualAuraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, isCastByPlayer, nameplateShowAll
					if IS_WOW_PROJECT_MAINLINE then
						local slot = slots[i]
						name, texture, count, actualAuraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, isCastByPlayer, nameplateShowAll = UnitAuraBySlot("player", slot)
					else
						name, texture, count, actualAuraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId = UnitAura("player", i-1, "HELPFUL|PLAYER")
						if not name then
							break
						end
					end

					buffIndex = buffIndex + 1
					
					local auraType = "BUFF"

					unitAuraCache[name] = true
					unitAuraCache[spellId] = true
					unitAuraCache.canStealOrPurge = unitAuraCache.canStealOrPurge or canStealOrPurge
					unitAuraCache.hasEnrage = unitAuraCache.hasEnrage or actualAuraType == AURA_TYPE_ENRAGE
					
					--> only show buffs casted by the player it self and less than 1 minute in duration
					if ((not DB_BUFF_BANNED [name] and not DB_BUFF_BANNED [spellId]) and (noBuffDurationLimitation or (duration and (duration > 0 and duration < 60)) and (caster and UnitIsUnit (caster, "player")))) then
						local auraIconFrame, buffFrame = Plater.GetAuraIcon (self, true)
						Plater.AddAura (buffFrame, auraIconFrame, buffIndex, name, texture, count, auraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId, false, false, false, true, actualAuraType)

					end
					
					--> there is no special auras for buffs in the personal bar
				end
			until continuationToken == nil
		end	
		
		--> hide not used aura frames
		Plater.HideNonUsedAuraIcons (self)
		
		Plater.EndLogPerformanceCore("Plater-Core", "Update", "UpdateAuras_Self_Automatic")
    end
    


    --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> aura test - when the options panel is opened at the buff settings

	function Plater.CreateAuraTesting()

		local auraOptionsFrame = _G.PlaterOptionsPanelContainer.AllFrames[9]

		auraOptionsFrame.OnUpdateFunc = function (self, deltaTime)
			
			auraOptionsFrame.NextTime = auraOptionsFrame.NextTime - deltaTime
			DB_AURA_ENABLED = false
			Plater.DisableAuraTrackingForAuraTest()
			
			if (auraOptionsFrame.NextTime <= 0) then
				auraOptionsFrame.NextTime = 0.016
				
				for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
					if plateFrame.unitFrame.PlaterOnScreen then

						local buffFrame = plateFrame.unitFrame.BuffFrame
						local buffFrame2 = plateFrame.unitFrame.BuffFrame2
						local unitAuraCache = plateFrame.unitFrame.AuraCache
						
						buffFrame:SetAlpha (DB_AURA_ALPHA)
						buffFrame2:SetAlpha (DB_AURA_ALPHA)
						
						--> reset next aura icon to use
						buffFrame.NextAuraIcon = 1
						buffFrame2.NextAuraIcon = 1
					
						if (not DB_AURA_SEPARATE_BUFFS) then
							for index, auraTable in ipairs (auraOptionsFrame.AuraTesting.DEBUFF) do
								local auraIconFrame = Plater.GetAuraIcon (buffFrame)
								if (not auraTable.ApplyTime or auraTable.ApplyTime+auraTable.Duration < GetTime()) then
									auraTable.ApplyTime = GetTime() + math.random (3, 12)
								end
								
								if (not UnitIsUnit (plateFrame.unitFrame [MEMBER_UNITID], "player")) then
									Plater.AddAura (buffFrame, auraIconFrame, index, auraTable.SpellName, auraTable.SpellTexture, auraTable.Count, "DEBUFF", auraTable.Duration, auraTable.ApplyTime+auraTable.Duration, "player", false, false, auraTable.SpellID, nil, nil, nil, nil, auraTable.Type)
								else
									Plater.AddAura (buffFrame, auraIconFrame, index, auraTable.SpellName, auraTable.SpellTexture, auraTable.Count, "DEBUFF", auraTable.Duration, auraTable.ApplyTime+auraTable.Duration, "player", false, false, auraTable.SpellID, false, false, true, true, auraTable.Type)
								end
								
								unitAuraCache[auraTable.SpellName] = true
								unitAuraCache[auraTable.SpellID] = true
								
								Plater.UpdateIconAspecRatio (auraIconFrame)
							end
							
							for index, auraTable in ipairs (auraOptionsFrame.AuraTesting.BUFF) do
								local auraIconFrame = Plater.GetAuraIcon (buffFrame)
								if (not auraTable.ApplyTime or auraTable.ApplyTime+auraTable.Duration < GetTime()) then
									auraTable.ApplyTime = GetTime() + math.random (3, 12)
								end
								
								if (not UnitIsUnit (plateFrame.unitFrame [MEMBER_UNITID], "player")) then
									Plater.AddAura (buffFrame, auraIconFrame, index, auraTable.SpellName, auraTable.SpellTexture, auraTable.Count, "DEBUFF", auraTable.Duration, auraTable.ApplyTime+auraTable.Duration, "player", false, false, auraTable.SpellID, true, nil, nil, nil, auraTable.Type)
								else
									Plater.AddAura (buffFrame, auraIconFrame, index, auraTable.SpellName, auraTable.SpellTexture, auraTable.Count, "DEBUFF", auraTable.Duration, auraTable.ApplyTime+auraTable.Duration, "player", false, false, auraTable.SpellID, false, false, false, true, auraTable.Type)
								end
								
								unitAuraCache[auraTable.SpellName] = true
								unitAuraCache[auraTable.SpellID] = true
								
								Plater.UpdateIconAspecRatio (auraIconFrame)
							end
							
							--hide icons on the second buff frame
							for i = 1, #buffFrame2.PlaterBuffList do
								local icon = buffFrame2.PlaterBuffList [i]
								if (icon) then
									icon.ShowAnimation:Stop()
									icon:Hide()
									icon.InUse = false
								end
							end
						end
						
						if (DB_AURA_SEPARATE_BUFFS) then

							for index, auraTable in ipairs (auraOptionsFrame.AuraTesting.DEBUFF) do
								local auraIconFrame = Plater.GetAuraIcon (buffFrame)
								if (not auraTable.ApplyTime or auraTable.ApplyTime+auraTable.Duration < GetTime()) then
									auraTable.ApplyTime = GetTime() + math.random (3, 12)
								end
								
								if (not UnitIsUnit (plateFrame.unitFrame [MEMBER_UNITID], "player")) then
									Plater.AddAura (buffFrame, auraIconFrame, index, auraTable.SpellName, auraTable.SpellTexture, auraTable.Count, "DEBUFF", auraTable.Duration, auraTable.ApplyTime+auraTable.Duration, "player", false, false, auraTable.SpellID, nil, nil, nil, nil, auraTable.Type)
								else
									Plater.AddAura (buffFrame, auraIconFrame, index, auraTable.SpellName, auraTable.SpellTexture, auraTable.Count, "DEBUFF", auraTable.Duration, auraTable.ApplyTime+auraTable.Duration, "player", false, false, auraTable.SpellID, false, false, true, true, auraTable.Type)
								end
								
								unitAuraCache[auraTable.SpellName] = true
								unitAuraCache[auraTable.SpellID] = true
								unitAuraCache.hasEnrage = unitAuraCache.hasEnrage or auraTable.Type == AURA_TYPE_ENRAGE
							end
							
							for index, auraTable in ipairs (auraOptionsFrame.AuraTesting.BUFF) do
								local auraIconFrame, frame = Plater.GetAuraIcon (buffFrame, true)
								if (not auraTable.ApplyTime or auraTable.ApplyTime+auraTable.Duration < GetTime()) then
									auraTable.ApplyTime = GetTime() + math.random (3, 12)
								end
								
								if (not UnitIsUnit (plateFrame.unitFrame [MEMBER_UNITID], "player")) then
									Plater.AddAura (frame, auraIconFrame, index, auraTable.SpellName, auraTable.SpellTexture, auraTable.Count, "BUFF", auraTable.Duration, auraTable.ApplyTime+auraTable.Duration, "player", false, false, auraTable.SpellID, true, nil, nil, nil, auraTable.Type)
								else
									Plater.AddAura (frame, auraIconFrame, index, auraTable.SpellName, auraTable.SpellTexture, auraTable.Count, "BUFF", auraTable.Duration, auraTable.ApplyTime+auraTable.Duration, "player", false, false, auraTable.SpellID, true, false, false, false, auraTable.Type)
									--Plater.AddAura (frame, auraIconFrame, index, auraTable.SpellName, auraTable.SpellTexture, auraTable.Count, "BUFF", auraTable.Duration, auraTable.ApplyTime+auraTable.Duration, "player", false, false, auraTable.SpellID, false, false, false, true, auraTable.Type)
								end
								
								unitAuraCache[auraTable.SpellName] = true
								unitAuraCache[auraTable.SpellID] = true
								unitAuraCache.hasEnrage = unitAuraCache.hasEnrage or auraTable.Type == AURA_TYPE_ENRAGE
							end
						end
						
						Plater.HideNonUsedAuraIcons (buffFrame)
						Plater.AlignAuraFrames (buffFrame)
						
						if (DB_AURA_SEPARATE_BUFFS) then
							Plater.AlignAuraFrames (buffFrame.BuffFrame2)
						end
					end
				end
			end
		end

		auraOptionsFrame.EnableAuraTest = function()
			DB_AURA_ENABLED = false
			Plater.DisableAuraTrackingForAuraTest()
			auraOptionsFrame.NextTime = 0.2
			auraOptionsFrame:SetScript ("OnUpdate", auraOptionsFrame.OnUpdateFunc)
		end
		auraOptionsFrame.DisableAuraTest = function()
			Plater.RefreshDBUpvalues()
			auraOptionsFrame:SetScript ("OnUpdate", nil)
		end

		auraOptionsFrame:SetScript ("OnShow", function()
			if (not Plater.DisableAuraTest) then
				auraOptionsFrame.EnableAuraTest()
			end
		end)

		auraOptionsFrame:SetScript ("OnHide", function()
			auraOptionsFrame.DisableAuraTest()
		end)
	end


    -------------------------------------------------------------------------------------------------------------------
    --> aura caches -- ~db
    
    function Plater.RefreshAuraDBUpvalues()
        local profile = Plater.db.profile

		DB_SHOW_PURGE_IN_EXTRA_ICONS = profile.extra_icon_show_purge
		DB_SHOW_ENRAGE_IN_EXTRA_ICONS = profile.extra_icon_show_enrage

		--list of auras the user added into the track list for special auras
		wipe (SPECIAL_AURAS_USER_LIST)
		wipe (SPECIAL_AURAS_USER_LIST_MINE)
		
		--list of auras Plater added automatically to special auras
        wipe (SPECIAL_AURAS_AUTO_ADDED)

		--cached spells for the border in the special auras
		wipe (CROWDCONTROL_AURA_IDS)
		wipe (OFFENSIVE_AURA_IDS)
		wipe (DEFENSIVE_AURA_IDS)

		--build the crowd control list
		if (profile.debuff_show_cc) then
			for spellId, _ in pairs (DF.CrowdControlSpells) do
				local spellName = GetSpellInfo (spellId)
				if (spellName) then
					--SPECIAL_AURAS_AUTO_ADDED [spellName] = true
					SPECIAL_AURAS_AUTO_ADDED [spellId] = true
					CROWDCONTROL_AURA_IDS [spellId] = true
				end
			end
        end
        
		--build the offensive cd list
		if (profile.extra_icon_show_offensive) then
			for spellId, _ in pairs (DF.CooldownsAttack) do
				local spellName = GetSpellInfo (spellId)
				if (spellName) then
					--SPECIAL_AURAS_AUTO_ADDED [spellName] = true
					SPECIAL_AURAS_AUTO_ADDED [spellId] = true
					OFFENSIVE_AURA_IDS [spellId] = true
				end
			end
        end
        
		--build the defensive cd list
		if (profile.extra_icon_show_defensive) then
			for spellId, _ in pairs (DF.CooldownsAllDeffensive) do
				local spellName = GetSpellInfo (spellId)
				if (spellName) then
					--SPECIAL_AURAS_AUTO_ADDED [spellName] = true
					SPECIAL_AURAS_AUTO_ADDED [spellId] = true
					DEFENSIVE_AURA_IDS [spellId] = true
				end
			end
        end
        
		--> add auras added by the player into the special aura container
		for index, spellId in ipairs (profile.extra_icon_auras) do
			local spellName = GetSpellInfo (spellId)
			if (spellName) or type(spellId) == "string" then -- either valid ID or name
				SPECIAL_AURAS_USER_LIST [spellId] = true
			end
        end
        
		for spellId, state in pairs (profile.extra_icon_auras_mine) do
			if (state) then
				local spellName = GetSpellInfo (spellId)
				if (spellName) or type(spellId) == "string" then -- either valid ID or name
					--> mine list only store if the user checked the 'only mine' box
					--> if the user remove the spell, that spell isn't removed from the 'only mine' list
					--> so need to check if the spell on 'only mine' list is included in the special aura list
					if (SPECIAL_AURAS_USER_LIST [spellId]) then
						SPECIAL_AURAS_USER_LIST_MINE [spellId] = true
					end
				end
			end
		end
    end

	function Plater.RefreshAuraCache()
		local profile = Plater.db.profile
		
		DB_AURA_ENABLED = profile.aura_enabled
		DB_AURA_ALPHA = profile.aura_alpha
		
		DB_AURA_SEPARATE_BUFFS = Plater.db.profile.buffs_on_aura2

		DB_AURA_SHOW_IMPORTANT = profile.aura_show_important
		DB_AURA_SHOW_DISPELLABLE = profile.aura_show_dispellable
		DB_AURA_SHOW_ENRAGE = profile.aura_show_enrage
		DB_AURA_SHOW_BYPLAYER = profile.aura_show_aura_by_the_player
		DB_AURA_SHOW_BYUNIT = profile.aura_show_buff_by_the_unit
		DB_AURA_PADDING = profile.aura_padding

		DB_AURA_GROW_DIRECTION = profile.aura_grow_direction
		DB_AURA_GROW_DIRECTION2 = profile.aura2_grow_direction
		
		Plater.MaxAurasPerRow = floor (profile.plate_config.enemynpc.health_incombat[1] / (profile.aura_width + DB_AURA_PADDING))
    end
    
    function Plater.UpdateAuraCache()
		local profile = Plater.db.profile
		--manual tracking has an indexed table to store what to track
		--the extra auras for automatic tracking has a hash table with spellIds
		
		--manual aura tracking
			local manualBuffsToTrack = profile.aura_tracker.buff
			local manualDebuffsToTrack = profile.aura_tracker.debuff

			wipe (MANUAL_TRACKING_DEBUFFS)
			wipe (MANUAL_TRACKING_BUFFS)
			
			for i = 1, #manualDebuffsToTrack do
				local spellName = GetSpellInfo (manualDebuffsToTrack [i])
				if (spellName) then
					MANUAL_TRACKING_DEBUFFS [spellName] = true
				else
					--add the entry in case there's a spell name instead of a spellId in the list (for back compatibility)
					MANUAL_TRACKING_DEBUFFS [manualDebuffsToTrack [i]] = true
				end
			end

			for i = 1, #manualBuffsToTrack do
				local spellName = GetSpellInfo (manualBuffsToTrack [i])
				if (spellName) then
					MANUAL_TRACKING_BUFFS [spellName] = true
				else
					--add the entry in case there's a spell name instead of a spellId in the list (for back compatibility)
					MANUAL_TRACKING_BUFFS [manualBuffsToTrack [i]]= true
				end
			end

		--extra auras to track on automatic aura tracking
			local extraBuffsToTrack = profile.aura_tracker.buff_tracked
			local extraDebuffsToTrack = profile.aura_tracker.debuff_tracked
			
			wipe (AUTO_TRACKING_EXTRA_BUFFS)
			wipe (AUTO_TRACKING_EXTRA_DEBUFFS)
			
			CAN_TRACK_EXTRA_BUFFS = false
			CAN_TRACK_EXTRA_DEBUFFS = false

			for spellId, flag in pairs (extraBuffsToTrack) do
				local spellName = GetSpellInfo (spellId)
				if (spellName) then
					if flag then
						AUTO_TRACKING_EXTRA_BUFFS [spellName] = true
					else
						AUTO_TRACKING_EXTRA_BUFFS [spellId] = true
					end
					CAN_TRACK_EXTRA_BUFFS = true
				end
			end
			
			for spellId, flag in pairs (extraDebuffsToTrack) do
				local spellName = GetSpellInfo (spellId)
				if (spellName) then
					if flag then
						AUTO_TRACKING_EXTRA_DEBUFFS [spellName] = true
					else
						AUTO_TRACKING_EXTRA_DEBUFFS [spellId] = true
					end
					CAN_TRACK_EXTRA_DEBUFFS = true
				end
			end
			
			if (profile.aura_show_crowdcontrol and DF.CrowdControlSpells) then
				for spellId, _ in pairs (DF.CrowdControlSpells) do
					local spellName = GetSpellInfo (spellId)
					if (spellName) then
						--AUTO_TRACKING_EXTRA_DEBUFFS [spellName] = true
						AUTO_TRACKING_EXTRA_DEBUFFS [spellId] = true
						CROWDCONTROL_AURA_IDS [spellId] = true
						CAN_TRACK_EXTRA_BUFFS = true
					end
				end
			end
			
			if (profile.aura_show_offensive_cd and DF.CooldownsAttack) then
				for spellId, _ in pairs (DF.CooldownsAttack) do
					local spellName = GetSpellInfo (spellId)
					if (spellName) then
						--AUTO_TRACKING_EXTRA_BUFFS [spellName] = true
						AUTO_TRACKING_EXTRA_BUFFS [spellId] = true
						OFFENSIVE_AURA_IDS [spellId] = true
						CAN_TRACK_EXTRA_BUFFS = true
					end
				end
			end
			
			if (profile.aura_show_defensive_cd and DF.CooldownsAllDeffensive) then
				for spellId, _ in pairs (DF.CooldownsAllDeffensive) do
					local spellName = GetSpellInfo (spellId)
					if (spellName) then
						--AUTO_TRACKING_EXTRA_BUFFS [spellName] = true
						AUTO_TRACKING_EXTRA_BUFFS [spellId] = true
						DEFENSIVE_AURA_IDS [spellId] = true
						CAN_TRACK_EXTRA_BUFFS = true
					end
				end
			end
			
			--> load spells filtered out, use the spellname instead of the spellId
			if (not DB_BUFF_BANNED) then
				DB_BUFF_BANNED = {}
				DB_DEBUFF_BANNED = {}
			else
				wipe (DB_BUFF_BANNED)
				wipe (DB_DEBUFF_BANNED)
			end
		
			for spellId, state in pairs (profile.aura_tracker.buff_banned) do
				local spellName = GetSpellInfo (spellId)
				if (spellName) then
					if state then
						DB_BUFF_BANNED [spellName] = true
					else
						DB_BUFF_BANNED [spellId] = true
					end
				end
			end
			
			for spellId, state in pairs (profile.aura_tracker.debuff_banned) do
				local spellName = GetSpellInfo (spellId)
				if (spellName) then
					if state then
						DB_DEBUFF_BANNED [spellName] = true
					else
						DB_DEBUFF_BANNED [spellId] = true
					end
				end
			end
	end