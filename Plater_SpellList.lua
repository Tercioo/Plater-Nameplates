
local addonId, platerInternal = ...

local Plater = Plater

---@type detailsframework
local detailsFramework = DetailsFramework

local _

---@class spelllist_scrolldata : table
---@field [1] spellid
---@field [2] plater_spelldata

local startX, startY, heightSize = 10, platerInternal.optionsYStart, 755
local highlightColorLastCombat = {1, 1, .2, .25}

local GameTooltip = GameTooltip

--db upvalues
---@type plater_spelldata[]
local DB_CAPTURED_SPELLS = {}
local DB_CAPTURED_CASTS
local DB_NPCID_CACHE
local DB_NPCID_COLORS
local DB_AURA_ALPHA
local DB_AURA_ENABLED
local DB_AURA_SEPARATE_BUFFS

local GetSpellInfo = GetSpellInfo or function(spellID) if not spellID then return nil end local si = C_Spell.GetSpellInfo(spellID) if si then return si.name, nil, si.iconID, si.castTime, si.minRange, si.maxRange, si.spellID, si.originalIconID end end

local on_refresh_db = function()
	local profile = Plater.db.profile
	DB_CAPTURED_SPELLS = PlaterDB.captured_spells
	DB_CAPTURED_CASTS = PlaterDB.captured_casts
	DB_NPCID_CACHE = profile.npc_cache
	DB_NPCID_COLORS = profile.npc_colors
	DB_AURA_ALPHA = profile.aura_alpha
	DB_AURA_ENABLED = profile.aura_enabled
	DB_AURA_SEPARATE_BUFFS = Plater.db.profile.buffs_on_aura2
end

Plater.RegisterRefreshDBCallback(on_refresh_db)

--------------------------------------------------------------------------------------------------------------------------------------------------------------
--> last event auras ~listbuff ~bufflist


function Plater.CreateAuraLastEventOptionsFrame(auraLastEventFrame)
    --options
    local scroll_width = 1050
    local scroll_height = 442
    local scroll_lines = 21
    local scroll_line_height = 20
    local backdrop_color = {.2, .2, .2, 0.2}
    local backdrop_color_on_enter = {.8, .8, .8, 0.4}
    local y = startY
    local headerY = y - 20
    local scrollY = headerY - 20

    --templates
    local options_text_template = detailsFramework:GetTemplate("font", "OPTIONS_FONT_TEMPLATE")
    local options_dropdown_template = detailsFramework:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE")
    local options_switch_template = detailsFramework:GetTemplate("switch", "OPTIONS_CHECKBOX_TEMPLATE")
    local options_slider_template = detailsFramework:GetTemplate("slider", "OPTIONS_SLIDER_TEMPLATE")
    local options_button_template = detailsFramework:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE")

    --header
    local headerTable = {
        {text = "Icon", width = 32},
        {text = "Spell ID", width = 74},
        {text = "Spell Name", width = 162},
        {text = "Source", width = 130},
        {text = "Spell Type", width = 70},
        {text = "Add to Tracklist", width = 100},
        {text = "Add to Blacklist", width = 100},
        {text = "Add to Special Auras", width = 120},
        {text = "Add to Script", width = 120},
        {text = "From Last Combat", width = 120}, --, icon = _G.WeakAuras and [[Interface\AddOns\WeakAuras\Media\Textures\icon]] or ""
    }
    local headerOptions = {
        padding = 2,
    }

    auraLastEventFrame.Header = detailsFramework:CreateHeader(auraLastEventFrame, headerTable, headerOptions)
    auraLastEventFrame.Header:SetPoint("topleft", auraLastEventFrame, "topleft", 10, headerY)

    --line scripts
    local lineOnEnter = function(self)
        if (self.hasHighlight) then
            local r, g, b, a = unpack(highlightColorLastCombat)
            self:SetBackdropColor(r, g, b, a+0.2)
        else
            self:SetBackdropColor(unpack(backdrop_color_on_enter))
        end

        if (self.SpellID) then
            GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
            GameTooltip:SetSpellByID(self.SpellID)
            GameTooltip:AddLine(" ")
            GameTooltip:Show()
        end
    end

    local lineOnLeave = function(self)
        if (self.hasHighlight) then
            self:SetBackdropColor(unpack(highlightColorLastCombat))
        else
            self:SetBackdropColor(unpack(backdrop_color))
        end
        GameTooltip:Hide()
    end

    local widgetOnEnter = function(self)
        local line = self:GetParent()
        line:GetScript("OnEnter")(line)
    end
    local widgetOnLeave = function(self)
        local line = self:GetParent()
        line:GetScript("OnLeave")(line)
    end

    local lineAddTracklist = function(self)
        self = self:GetCapsule()

        if (self.AuraType == "BUFF") then
            if (Plater.db.profile.aura_tracker.track_method == 0x1) then
                Plater.db.profile.aura_tracker.buff_tracked [self.SpellID] = true
                Plater:Msg("Aura added to buff tracking.")

            elseif (Plater.db.profile.aura_tracker.track_method == 0x2) then
                local added = detailsFramework.table.addunique(Plater.db.profile.aura_tracker.buff, self.SpellID)
                if (added) then
                    Plater:Msg("Aura added to manual buff tracking.")
                else
                    Plater:Msg("Aura not added: already on track.")
                end
            end

        elseif (self.AuraType == "DEBUFF") then
            if (Plater.db.profile.aura_tracker.track_method == 0x1) then
                Plater.db.profile.aura_tracker.debuff_tracked [self.SpellID] = true
                Plater:Msg("Aura added to debuff tracking.")

            elseif (Plater.db.profile.aura_tracker.track_method == 0x2) then
                local added = detailsFramework.table.addunique(Plater.db.profile.aura_tracker.debuff, self.SpellID)
                if (added) then
                    Plater:Msg("Aura added to manual debuff tracking.")
                else
                    Plater:Msg("Aura not added: already on track.")
                end
            end
        end
    end

    local lineAddIgnorelist = function(self)
        self = self:GetCapsule()

        if (self.AuraType == "BUFF") then
            if (Plater.db.profile.aura_tracker.track_method == 0x1) then
                Plater.db.profile.aura_tracker.buff_banned [self.SpellID] = true
                Plater:Msg("Aura added to buff blacklist.")
            end

        elseif (self.AuraType == "DEBUFF") then
            if (Plater.db.profile.aura_tracker.track_method == 0x1) then
                Plater.db.profile.aura_tracker.debuff_banned [self.SpellID] = true
                Plater:Msg("Aura added to debuff blacklist.")
            end
        end
    end

    local lineAddSpecial = function(self)
        self = self:GetCapsule()

        local added = detailsFramework.table.addunique(Plater.db.profile.extra_icon_auras, self.SpellID)
        if (added) then
            Plater:Msg("Aura added to the special aura container.")
        else
            Plater:Msg("Aura not added: already on the special container.")
        end
    end

    local lineOnClickTriggerDropdownOption = function(self, fixedValue, scriptID)
        local scriptObject = Plater.GetScriptObject(scriptID, "script")
        local spellName = GetSpellInfo(self.SpellID)

        if (scriptObject and spellName) then
            if (scriptObject.ScriptType == 1 or scriptObject.ScriptType == 2) then
                --add the trigger
                local added = detailsFramework.table.addunique(scriptObject.SpellIds, self.SpellID)
                if (added) then
                    --reload all scripts
                    Plater.WipeAndRecompileAllScripts("script")
                    Plater:Msg("Trigger added to script.")
                else
                    Plater:Msg("Script already have this trigger.")
                end

                --refresh and select no option
                self:Refresh()
                self:Select(0, true)
            end
        end
    end

    local lineRefreshTriggerDropdown = function(self)
        if (not self.SpellID) then
            return {}
        end

        local listOfOptions = {}

        local scripts = Plater.GetAllScripts("script")
        for i = 1, #scripts do
            local scriptObject = scripts[i]
            if (scriptObject.ScriptType == 1 or scriptObject.ScriptType == 2) then
                tinsert(listOfOptions, {0, 0, scriptObject.Name, scriptObject.Enabled and 1 or 0, 0, label = scriptObject.Name, value = i, color = scriptObject.Enabled and "white" or "red", onclick = lineOnClickTriggerDropdownOption, desc = scriptObject.Desc})
            end
        end

        table.sort(listOfOptions, Plater.SortScripts)
        return listOfOptions
    end

    local lineCreateAura = function(self)
        self = self:GetCapsule()

        if (Details) then
            local spellName, _, spellIcon = GetSpellInfo(self.SpellID)
            local encounterID = self.EncounterID

            Details:OpenAuraPanel(self.SpellID, spellName, spellIcon, encounterID, self.AuraType == "BUFF" and 5 or self.AuraType == "DEBUFF" and 1 or self.IsCast and 7 or 2, 1)
            PlaterOptionsPanelFrame:Hide()
        else
            Plater:Msg("Details! Damage Meter not found, install it from the Twitch App!")
        end
    end

    local onEditFocusGained_SpellIdEntry = function(self, capsule)
        self:HighlightText(0)
    end

    --line
    local scrollCreateLine = function(self, index)
        local line = CreateFrame("button", "$parentLine" .. index, self, BackdropTemplateMixin and "BackdropTemplate")
        line:SetPoint("topleft", self, "topleft", 1, -((index-1)*(scroll_line_height+1)) - 1)
        line:SetSize(scroll_width - 2, scroll_line_height)
        line:SetScript("OnEnter", lineOnEnter)
        line:SetScript("OnLeave", lineOnLeave)

        line:SetBackdrop({bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
        line:SetBackdropColor(unpack(backdrop_color))

        detailsFramework:Mixin(line, detailsFramework.HeaderFunctions)

        local icon = line:CreateTexture("$parentSpellIcon", "overlay")
        icon:SetSize(scroll_line_height - 2, scroll_line_height - 2)

        local spellIdTextEntry = detailsFramework:CreateTextEntry(line, function()end, headerTable[2].width, 20, nil, nil, nil, detailsFramework:GetTemplate("dropdown", "PLATER_DROPDOWN_OPTIONS"))
        spellIdTextEntry:SetHook("OnEditFocusGained", onEditFocusGained_SpellIdEntry)
        spellIdTextEntry:SetJustifyH("left")

        local spellNameLabel = detailsFramework:CreateLabel(line, "", detailsFramework:GetTemplate("font", "PLATER_SCRIPTS_NAME"))
        local sourceNameLabel = detailsFramework:CreateLabel(line, "", detailsFramework:GetTemplate("font", "PLATER_SCRIPTS_NAME"))
        local spellTypeLabel = detailsFramework:CreateLabel(line, "", detailsFramework:GetTemplate("font", "PLATER_SCRIPTS_NAME"))

        local addTracklistButton = detailsFramework:CreateButton(line, lineAddTracklist, headerTable[6].width, 20, "Add", -1, nil, nil, nil, nil, nil, detailsFramework:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE"), detailsFramework:GetTemplate("font", "PLATER_BUTTON"))
        local addIgnorelistButton = detailsFramework:CreateButton(line, lineAddIgnorelist, headerTable[7].width, 20, "Add", -1, nil, nil, nil, nil, nil, detailsFramework:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE"), detailsFramework:GetTemplate("font", "PLATER_BUTTON"))
        local addSpecialButton = detailsFramework:CreateButton(line, lineAddSpecial, headerTable[8].width, 20, "Add", -1, nil, nil, nil, nil, nil, detailsFramework:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE"), detailsFramework:GetTemplate("font", "PLATER_BUTTON"))

        local addScriptTriggerDropdown = detailsFramework:CreateDropDown(line, lineRefreshTriggerDropdown, 1, headerTable[9].width, 20, nil, nil, detailsFramework:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))

        local createAuraButton = detailsFramework:CreateButton(line, lineCreateAura, headerTable[10].width, 20, "Create", -1, nil, nil, nil, nil, nil, detailsFramework:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE"), detailsFramework:GetTemplate("font", "PLATER_BUTTON"))

        local fromLastCombatLabel = detailsFramework:CreateLabel(line, "", detailsFramework:GetTemplate("font", "PLATER_SCRIPTS_NAME"))

        spellIdTextEntry:SetHook("OnEnter", widgetOnEnter)
        spellIdTextEntry:SetHook("OnLeave", widgetOnLeave)

        addTracklistButton:SetHook("OnEnter", widgetOnEnter)
        addTracklistButton:SetHook("OnLeave", widgetOnLeave)

        addIgnorelistButton:SetHook("OnEnter", widgetOnEnter)
        addIgnorelistButton:SetHook("OnLeave", widgetOnLeave)

        addSpecialButton:SetHook("OnEnter", widgetOnEnter)
        addSpecialButton:SetHook("OnLeave", widgetOnLeave)

        addScriptTriggerDropdown:SetHook("OnEnter", widgetOnEnter)
        addScriptTriggerDropdown:SetHook("OnLeave", widgetOnLeave)

        createAuraButton:SetHook("OnEnter", widgetOnEnter)
        createAuraButton:SetHook("OnLeave", widgetOnLeave)

        line:AddFrameToHeaderAlignment(icon)
        line:AddFrameToHeaderAlignment(spellIdTextEntry)
        line:AddFrameToHeaderAlignment(spellNameLabel)
        line:AddFrameToHeaderAlignment(sourceNameLabel)
        line:AddFrameToHeaderAlignment(spellTypeLabel)
        line:AddFrameToHeaderAlignment(addTracklistButton)
        line:AddFrameToHeaderAlignment(addIgnorelistButton)
        line:AddFrameToHeaderAlignment(addSpecialButton)
        line:AddFrameToHeaderAlignment(addScriptTriggerDropdown)
        line:AddFrameToHeaderAlignment(fromLastCombatLabel)
        --line:AddFrameToHeaderAlignment(create_aura)

        line:AlignWithHeader(auraLastEventFrame.Header, "left")

        line.Icon = icon
        line.SpellIDEntry = spellIdTextEntry
        line.SpellName = spellNameLabel
        line.SourceName = sourceNameLabel
        line.SpellType = spellTypeLabel
        line.AddTrackList = addTracklistButton
        line.AddIgnoreList = addIgnorelistButton
        line.AddSpecial = addSpecialButton
        line.AddTrigger = addScriptTriggerDropdown
        line.CreateAura = createAuraButton
        line.FromLastCombat = fromLastCombatLabel

        return line
    end

    --refresh scroll

    local sortOrder4 = function(t1, t2)
        return t1[4] > t2[4]
    end

    local sIsSearchingFor

    ---@param self df_scrollbox
    ---@param data spelllist_scrolldata[]
    ---@param offset number
    ---@param totalLines number
    local scrollRefresh = function(self, data, offset, totalLines)
        local dataInOrder = {}
        --buff list tab
        local lastCombatNpcs = Plater.LastCombat.npcNames or {}

        if (sIsSearchingFor and sIsSearchingFor ~= "") then
            if (self.SearchCachedTable and sIsSearchingFor == self.SearchCachedTable.SearchTerm) then
                dataInOrder = self.SearchCachedTable
            else
                for i = 1, #data do
                    local thisData = data[i]
                    local spellID = thisData[1]
                    local spellName = GetSpellInfo(spellID)
                    local spellTable = thisData[2]

                    if (spellName) then
                        if (spellName:lower():find(sIsSearchingFor)) then
                            dataInOrder [#dataInOrder+1] = {
                                i,
                                data[i],
                                spellName,
                                lastCombatNpcs[spellTable.source] and 2 or 0
                            }
                        end
                    end
                end

                self.SearchCachedTable = dataInOrder
                self.SearchCachedTable.SearchTerm = sIsSearchingFor
            end
        else
            if (not self.CachedTable) then
                for i = 1, #data do
                    local spellID = data[i] [1]
                    local spellName = GetSpellInfo(spellID)
                    local spellTable = data[i][2]
                    if (spellName) then
                        dataInOrder [#dataInOrder+1] = {i, data[i], spellName, lastCombatNpcs[spellTable.source] and 2 or 0}
                    end
                end
                self.CachedTable = dataInOrder
            end

            dataInOrder = self.CachedTable
        end

        table.sort(dataInOrder, detailsFramework.SortOrder3R)
        table.sort(dataInOrder, sortOrder4)

        data = dataInOrder

        for i = 1, totalLines do
            local index = i + offset
            local spellTable = data [index] and data [index] [2]

            if (spellTable) then
                local line = self:GetLine(i)
                local spellID = spellTable[1]
                ---@type plater_spelldata
                local spellData = spellTable[2]

                local spellName, _, spellIcon = GetSpellInfo(spellID)

                local fullData = data[index]
                local isFromLastSegment = fullData[4] == 2
                line.hasHighlight = isFromLastSegment

                if (line.hasHighlight) then
                    line:SetBackdropColor(unpack(highlightColorLastCombat))
                    line.FromLastCombat.text = "       YES"
                else
                    line:SetBackdropColor(unpack(backdrop_color))
                    line.FromLastCombat.text = ""
                end

                line.value = spellTable

                if (spellName) then
                    line.Icon:SetTexture(spellIcon)
                    line.Icon:SetTexCoord(.1, .9, .1, .9)

                    line.SpellName:SetTextTruncated(spellName, headerTable [3].width)
                    line.SourceName:SetTextTruncated(spellData.source, headerTable [4].width)

                    local isCast = spellData.event == "SPELL_CAST_START" or spellData.event == "SPELL_CAST_SUCCESS"

                    if (spellData.type == "BUFF") then
                        line.SpellType.color = "PLATER_BUFF"

                    elseif (spellData.type == "DEBUFF") then
                        line.SpellType.color = "PLATER_DEBUFF"

                    elseif (isCast) then
                        line.SpellType.color = "PLATER_CAST"

                    end

                    line.SpellID = spellID

                    line.SpellIDEntry:SetText(spellID)

                    --{event = token, source = sourceName, type = auraType, npcID = Plater:GetNpcIdFromGuid(sourceGUID or "")}
                    line.SpellType:SetText(isCast and "Spell Cast" or spellData.event == "SPELL_AURA_APPLIED" and spellData.type)

                    line.AddTrackList.SpellID = spellID
                    line.AddTrackList.AuraType = spellData.type
                    line.AddTrackList.EncounterID = spellData.encounterID

                    line.AddIgnoreList.SpellID = spellID
                    line.AddIgnoreList.AuraType = spellData.type
                    line.AddIgnoreList.EncounterID = spellData.encounterID

                    line.AddSpecial.SpellID = spellID
                    line.AddSpecial.AuraType = spellData.type
                    line.AddSpecial.EncounterID = spellData.encounterID

                    if (spellData.type) then
                        line.AddTrackList:Enable()
                        line.AddIgnoreList:Enable()
                        line.AddSpecial:Enable()
                    else
                        line.AddTrackList:Disable()
                        line.AddIgnoreList:Disable()
                        line.AddSpecial:Disable()
                    end

                    line.CreateAura.SpellID = spellID
                    line.CreateAura.AuraType = spellData.type
                    line.CreateAura.IsCast = spellData.event == "SPELL_CAST_START"
                    line.CreateAura.EncounterID = spellData.encounterID

                    line.AddTrigger.SpellID = spellID
                    line.AddTrigger:Refresh()

                    --manual tracking doesn't have a black list
                    if (Plater.db.profile.aura_tracker.track_method == 0x1) then
                        if (spellData.type) then
                            line.AddIgnoreList:Enable()
                        end

                    elseif (Plater.db.profile.aura_tracker.track_method == 0x2) then
                        line.AddIgnoreList:Disable()

                    end

                else
                    line:Hide()
                end
            end
        end
    end

    --create scroll
    local latestSpellsScroll = detailsFramework:CreateScrollBox(auraLastEventFrame, "$parentSpellScroll", scrollRefresh, {}, scroll_width, scroll_height, scroll_lines, scroll_line_height)
    detailsFramework:ReskinSlider(latestSpellsScroll)
    latestSpellsScroll:SetPoint("topleft", auraLastEventFrame, "topleft", 10, scrollY)

    latestSpellsScroll:SetScript("OnShow", function(self)
        if (self.LastRefresh and self.LastRefresh+0.5 > GetTime()) then
            return
        end
        self.LastRefresh = GetTime()

        ---@type spelllist_scrolldata[]
        local newData = {}

        for spellID, spellTable in pairs(DB_CAPTURED_SPELLS) do
            tinsert(newData, {spellID, spellTable})
        end

        --if spellTable has 'isChanneled' entry, it means is a cast or channeling
        --if spellTable has 'type' entry, it means if a buff or debuff

        self.CachedTable = nil
        self.SearchCachedTable = nil

        self:SetData(newData)
        self:Refresh()
    end)

    --create lines
    for i = 1, scroll_lines do
        latestSpellsScroll:CreateLine(scrollCreateLine)
    end

    --create button to open spell list on Details!
    local openDetailsSpellList = function()
        if (Details) then
            Details.OpenForge()
            PlaterOptionsPanelFrame:Hide()
            --select all spells in the details! all spells panel
            if (DetailsForgePanel and DetailsForgePanel.SelectModule) then
                -- module 2 is the All Spells
                DetailsForgePanel.SelectModule(_, _, 1)
            end
        else
            Plater:Msg("Details! Damage Meter is required and isn't installed, get it on Twitch App!")
        end
    end

    ---@type df_button
    local openSpellListButton = detailsFramework:CreateButton(auraLastEventFrame, openDetailsSpellList, 160, 20, "Open Full Spell List", -1, nil, nil, nil, nil, nil, detailsFramework:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE"), detailsFramework:GetTemplate("font", "PLATER_BUTTON"))
    openSpellListButton:SetPoint("bottomright", latestSpellsScroll, "topright", 0, 24)

    --create the clean list button
    local wipeSpellList = function()
        wipe(DB_CAPTURED_SPELLS)
        latestSpellsScroll:Hide()
        C_Timer.After(0.016, function() latestSpellsScroll:Show(); latestSpellsScroll:Refresh() end)
    end

    ---@type df_button
    local clearListButton = detailsFramework:CreateButton(auraLastEventFrame, wipeSpellList, 160, 20, "Clear List", -1, nil, nil, nil, nil, nil, detailsFramework:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE"), detailsFramework:GetTemplate("font", "PLATER_BUTTON"))
    clearListButton:SetPoint("right", openSpellListButton, "left", -6, 0)

    --create search box
    function auraLastEventFrame.OnSearchBoxTextChanged()
        local text = auraLastEventFrame.AuraSearchTextEntry:GetText()
        if (text and string.len(text) > 0) then
            sIsSearchingFor = text:lower()
        else
            sIsSearchingFor = nil
        end
        latestSpellsScroll:Refresh()
    end

    local auraSearchTextentry = detailsFramework:CreateTextEntry(auraLastEventFrame, function()end, 160, 20, "AuraSearchTextEntry", _, _, options_dropdown_template)
    auraSearchTextentry:SetPoint("right", clearListButton, "left", -6, 0)
    auraSearchTextentry:SetHook("OnChar",		auraLastEventFrame.OnSearchBoxTextChanged)
    auraSearchTextentry:SetHook("OnTextChanged", 	auraLastEventFrame.OnSearchBoxTextChanged)
    auraSearchTextentry:SetAsSearchBox()

    local auraSearchLabel = detailsFramework:CreateLabel(auraLastEventFrame, "Search:", detailsFramework:GetTemplate("font", "ORANGE_FONT_TEMPLATE"))
    auraSearchLabel:SetPoint("right", auraSearchTextentry, "left", -2, 0)

    --create the description
    auraLastEventFrame.TitleDescText = Plater:CreateLabel(auraLastEventFrame, "Quick way to manage auras from a recent raid boss or dungeon run.", 10, "silver")
    auraLastEventFrame.TitleDescText:SetPoint("bottomleft", latestSpellsScroll, "topleft", 0, 26)
end
