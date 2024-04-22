local addonName, platerInternal = ...

local Plater = _G.Plater
local DF = DetailsFramework
local _
local GetSpellInfo = GetSpellInfo or function(spellID) if not spellID then return nil end local si = C_Spell.GetSpellInfo(spellID) if si then return si.name, nil, si.iconID, si.castTime, si.minRange, si.maxRange, si.spellID, si.originalIconID end end

local IS_WOW_PROJECT_MAINLINE = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
local IS_WOW_PROJECT_NOT_MAINLINE = WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE
local IS_WOW_PROJECT_CLASSIC_ERA = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
local IS_WOW_PROJECT_CLASSIC_TBC = WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC

local ghostAuraFrame

local y = platerInternal.optionsYStart - 40
local optionsStartX = 300
local optionsStartY = y

local scrollBoxWidth = 280
local scrollBoxHeight = 442
local scrollBoxLinesHeight = 21
local scrollAmoutLines = floor(scrollBoxHeight / scrollBoxLinesHeight)
local scrollbox_line_backdrop_color = {.8, .8, .8, 0.2}
local scrollbox_line_backdrop_color_hightlight = {.8, .8, .8, 0.4}

local options_text_template = DF:GetTemplate ("font", "OPTIONS_FONT_TEMPLATE")
local options_dropdown_template = DF:GetTemplate ("dropdown", "OPTIONS_DROPDOWN_TEMPLATE")
local options_switch_template = DF:GetTemplate ("switch", "OPTIONS_CHECKBOX_TEMPLATE")
local options_slider_template = DF:GetTemplate ("slider", "OPTIONS_SLIDER_TEMPLATE")
local options_button_template = DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE")

--SetSpec is called when this tab is shown and also if the player change its spec while this tab is shown
--this function get the spell list of ghost auras from db and update the scrollbox to show these spells
function Plater.Auras.GhostAuras.SetSpec()
    local specIndex, specId, specName = Plater.Auras.GhostAuras.GetPlayerSpecInfo()

    if (specIndex) then
        if (specId and specName) then
            ghostAuraFrame.auraScrollLabel.text = "Auras for specialization: " .. specName
        else
            ghostAuraFrame.auraScrollLabel.text = "no specialization to show"
        end

        local auraList = Plater.Auras.GhostAuras.GetAuraListForCurrentSpec()

        --order by name
        local spellIndexTable = {}
        for spellId in pairs(auraList) do
            local spellName, _, spellIcon = GetSpellInfo(spellId)
            if (spellName) then
                spellIndexTable[#spellIndexTable+1] = {spellId, spellName, spellIcon}
            end
        end

        table.sort(spellIndexTable, DF.SortOrder2R)

        ghostAuraFrame.spellScrollBox:SetData(spellIndexTable)
        ghostAuraFrame.spellScrollBox:Refresh()
    end
end

function Plater.Auras.GhostAuras.ApplyAppearance(auraIconFrame, spellName, spellIcon, spellId)
    local profile = Plater.db.profile
    local ghostAurasSettings = profile.ghost_auras

    auraIconFrame.Icon:SetDesaturated(ghostAurasSettings.desaturated)

    if (ghostAurasSettings.width ~= 0) then
        auraIconFrame:SetWidth(ghostAurasSettings.width)
		auraIconFrame.Icon:SetWidth (ghostAurasSettings.width-2)
    else
        auraIconFrame:SetWidth(profile.aura_width)
		auraIconFrame.Icon:SetWidth (profile.aura_width-2)
    end

    if (ghostAurasSettings.height ~= 0) then
        auraIconFrame:SetHeight(ghostAurasSettings.height)
		auraIconFrame.Icon:SetHeight(ghostAurasSettings.height-2)
    else
        auraIconFrame:SetHeight(profile.aura_height)
		auraIconFrame.Icon:SetHeight(profile.aura_height-2)
    end

    auraIconFrame:SetAlpha(ghostAurasSettings.alpha)
end

function Plater.Auras.BuildGhostAurasOptionsTab(frame)

    --this support frame is just to align widgets more easily
    local supportFrame = CreateFrame("frame", "$parentSupportFrame", frame, "BackdropTemplate")
    supportFrame:SetPoint("topleft", frame, "topleft", 5, 0)
    supportFrame:SetSize(frame:GetSize())

    ghostAuraFrame = supportFrame
    ghostAuraFrame:SetBackdrop(nil)

    --text above the scroll frame
    ghostAuraFrame.auraScrollLabel = DF:CreateLabel(ghostAuraFrame, "Auras for specialization") --localize-me
    ghostAuraFrame.auraScrollLabel.fontcolor = "orange"
    ghostAuraFrame.auraScrollLabel.fontsize = 11
    ghostAuraFrame.auraScrollLabel:SetPoint("topleft", ghostAuraFrame, "topleft", 5, y+16)

    --create the description
    ghostAuraFrame.TitleDescText = Plater:CreateLabel (ghostAuraFrame, "Add an icon as a reminder that a debuff you can cast directly is missing on the enemy.", 10, "silver") --localize-me
    ghostAuraFrame.TitleDescText:SetPoint ("bottomleft", ghostAuraFrame.auraScrollLabel, "topleft", 0, 10)

    --scroll frame
    local refreshAuraList = function(self, data, offset, totalLines)
        for i = 1, totalLines do
            local index = i + offset
            local spellData = data[index]
            if (spellData) then
                local line = self:GetLine(i)
                if (line) then
                    local spellId, spellName, spellIcon = spellData[1], spellData[2], spellData[3]
                    line.spellId = spellId
                    line.removeButton.spellId = spellId
                    line.spellName:SetText(spellName)
                    line.spellIcon:SetTexture(spellIcon)
                    line.spellIcon:SetTexCoord(.1, .9, .1, .9)
                end
            end
        end
    end

    local spellScrollBox = DF:CreateScrollBox(ghostAuraFrame, "$parentSpellsScroll", refreshAuraList, {}, scrollBoxWidth, scrollBoxHeight, scrollAmoutLines, scrollBoxLinesHeight)
    ghostAuraFrame.spellScrollBox = spellScrollBox
    DF:ReskinSlider(spellScrollBox)
    spellScrollBox:SetPoint("topleft", ghostAuraFrame.auraScrollLabel.widget, "bottomleft", 0, -5)
    --spellScrollBox:SetBackdrop(nil)
    spellScrollBox.__background:SetAlpha(0.4)

	local onRemoveSpellMouseDown = function(self)
		self:GetNormalTexture():SetPoint("center", 1, -1)
	end
	local onRemoveSpellMouseUp = function(self)
		self:GetNormalTexture():SetPoint("center", 0, 0)
	end
	local onClickRemoveSpell = function(self)
		local spellId = self.spellId
        Plater.Auras.GhostAuras.RemoveGhostAura(spellId)
        --refresh the scroll frame
        Plater.Auras.GhostAuras.SetSpec()
	end
    local onEnterLine = function(self)
        self:SetBackdropColor(unpack(scrollbox_line_backdrop_color_hightlight))
    end
    local onLeaveLine = function(self)
        self:SetBackdropColor(unpack(scrollbox_line_backdrop_color))
    end

    --create scroll lines
    local createLine = function(self, index)
        local line = CreateFrame("button", "$parentLine" .. index, self, "BackdropTemplate")
        line:SetPoint("topleft", self, "topleft", 0, -((index-1) * (scrollBoxLinesHeight+1)) - 1)
        line:SetSize(scrollBoxWidth, scrollBoxLinesHeight)
        line:RegisterForClicks("LeftButtonDown", "RightButtonDown")
        DF:ApplyStandardBackdrop(line)

        line:SetScript("OnEnter", onEnterLine)
        line:SetScript("OnLeave", onLeaveLine)

        line.index = index

        --spell icon
        local spellIcon = line:CreateTexture("$parentIcon", "overlay")
        spellIcon:SetSize(scrollBoxLinesHeight-4, scrollBoxLinesHeight-4)
        spellIcon:SetPoint("left", line, "left", 2, 0)
        line.spellIcon = spellIcon

        --spell name
        local spellName = line:CreateFontString(nil, "overlay", "GameFontNormal")
        spellName:SetPoint("left", spellIcon, "right", 2, 0)
        DF:SetFontSize(spellName, 11)

        --remove spell button
		local removeButton = CreateFrame("button", nil, line, "BackdropTemplate")
		removeButton:SetPoint("right", line, "right", -3, 0)
		removeButton:SetSize(16, 16)
		removeButton:SetScript("OnClick", onClickRemoveSpell)
		removeButton:SetScript("OnMouseDown", onRemoveSpellMouseDown)
		removeButton:SetScript("OnMouseUp", onRemoveSpellMouseUp)
		removeButton:SetNormalTexture([[Interface\GLUES\LOGIN\Glues-CheckBox-Check]])
		removeButton:GetNormalTexture():ClearAllPoints()
		removeButton:GetNormalTexture():SetPoint("center", 0, 0)

        line.spellIcon = spellIcon
        line.spellName = spellName
        line.removeButton = removeButton

        return line
    end

    --create the scrollbox lines
    for i = 1, scrollAmoutLines do
        spellScrollBox:CreateLine(createLine, i)
    end

    ghostAuraFrame:SetScript("OnShow", function()
        Plater.Auras.GhostAuras.SetSpec()
        DF:LoadSpellCache(Plater.SpellHashTable, Plater.SpellIndexTable, Plater.SpellSameNameTable)
    end)
    ghostAuraFrame:SetScript("OnHide", function()
        DF:UnloadSpellCache()
    end)

    --Plater.Auras.GhostAuras.SetSpec() --debug, will update then the plater options is opened instead when the tab is opened

    local newAuraLabel = DF:CreateLabel(ghostAuraFrame, "Add Ghost Aura", DF:GetTemplate("font", "ORANGE_FONT_TEMPLATE"))
    DF:SetFontSize(newAuraLabel, 12)

    local newAuraEntry = DF:CreateTextEntry(ghostAuraFrame, function()end, 200, 20, "NewGhostAuraTextBox", _, _, options_dropdown_template)
    newAuraEntry.tooltip = "Enter the spell ID or the spell name"
    newAuraEntry:SetJustifyH("left")

    newAuraEntry:SetHook("OnEditFocusGained", function(self)
        newAuraEntry.SpellAutoCompleteList = Plater.SpellIndexTable
        newAuraEntry:SetAsAutoComplete("SpellAutoCompleteList", nil, true)
    end)

    local newAuraButton = DF:CreateButton(ghostAuraFrame, function()
        local text = newAuraEntry.text
        newAuraEntry:SetText("")
        newAuraEntry:ClearFocus()

        if (text ~= "") then
            --get the spellId
            local spellId = tonumber(text)
            if (not spellId) then
                spellId = select(7, GetSpellInfo(text))
                if (not spellId) then
                    Plater:Msg("SpellId not found.")
                    return
                end
            end

            Plater.Auras.GhostAuras.AddGhostAura(spellId)

            --refresh
            Plater.Auras.GhostAuras.SetSpec()
        else
            Plater:Msg("SpellId not found.")
        end
    end, 100, 20, "Add Aura", nil, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"))

    newAuraEntry:SetPoint ("topleft",  spellScrollBox, "topright", 40, 0)
    newAuraLabel:SetPoint ("bottomleft", newAuraEntry, "topleft", 0, 2)
    newAuraButton:SetPoint ("topleft", newAuraEntry, "bottomleft", 0, -2)
    newAuraButton.tooltip = "Add the aura to be tracked."

    --image showing ghost aura example
    ghostAuraFrame.ExampleImageDesc = DF:CreateLabel (ghostAuraFrame, "Ghost auras look like this:", 14)
    ghostAuraFrame.ExampleImageDesc:SetPoint (325, -240)
    ghostAuraFrame.ExampleImage = DF:CreateImage (ghostAuraFrame, [[Interface\AddOns\Plater\images\ghostauras_example]], 256*0.8, 128*0.8)
    ghostAuraFrame.ExampleImage:SetPoint (325, -254)
    ghostAuraFrame.ExampleImage:SetAlpha (.834)

    local optionsTable = {
        {type = "blank"},
        {type = "blank"},
        {type = "blank"},
        {type = "blank"},
        {type = "blank"},
        {type = "blank"},
        {type = "blank"},
        {type = "blank"},
        {type = "blank"},
        {type = "blank"},
        {type = "blank"},

        {type = "label", get = function() return "General Settings:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")}, --localize-me

		{
			type = "toggle",
			get = function() return Plater.db.profile.ghost_auras.enabled end,
			set = function (self, fixedparam, value)
				Plater.db.profile.ghost_auras.enabled = value
                Plater.RefreshAuraCache()
                Plater.UpdateAuraCache()
				--call an update on auras to remove the ghost auras currently shown
			end,
			name = "Enabled",
			desc = "Enabled",
		},

        {type = "blank"},

		{
			type = "range",
			get = function() return Plater.db.profile.ghost_auras.width end,
			set = function (self, fixedparam, value)
				Plater.db.profile.ghost_auras.width = value
			end,
			min = 0,
			max = 32,
			step = 1,
			name = "Width",
			desc = "Use zero to match the size of other auras",
		},

		{
			type = "range",
			get = function() return Plater.db.profile.ghost_auras.height end,
			set = function (self, fixedparam, value)
				Plater.db.profile.ghost_auras.height = value
			end,
			min = 0,
			max = 32,
			step = 1,
			name = "Height",
			desc = "Use zero to match the size of other auras",
		},

		{
			type = "range",
			get = function() return Plater.db.profile.ghost_auras.alpha end,
			set = function (self, fixedparam, value)
				Plater.db.profile.ghost_auras.alpha = value
			end,
			min = 0,
			max = 1,
			step = 0.1,
            usedecimals = true,
			name = "Alpha",
			desc = "Alpha",
		},

		{
			type = "toggle",
			get = function() return Plater.db.profile.ghost_auras.desaturated end,
			set = function (self, fixedparam, value)
				Plater.db.profile.ghost_auras.desaturated = value
				--call an update on auras to remove the ghost auras currently shown
			end,
			name = "Desaturated",
			desc = "Desaturated",
		},


    }

    local globalCallback = function()
        Plater.UpdateAllPlates()
    end

    _G.C_Timer.After(1.8, function() --~delay
        DF:BuildMenu(ghostAuraFrame, optionsTable, 325, -157, 800, true, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template, globalCallback)
    end)
end
