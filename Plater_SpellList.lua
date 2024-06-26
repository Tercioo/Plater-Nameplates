
local addonId, platerInternal = ...

local Plater = Plater
---@type detailsframework
local DF = DetailsFramework
local _

local startX, startY, heightSize = 10, platerInternal.optionsYStart, 755
local highlightColorLastCombat = {1, 1, .2, .25}

--db upvalues
local DB_CAPTURED_SPELLS
local DB_CAPTURED_CASTS
local DB_NPCID_CACHE
local DB_NPCID_COLORS
local DB_AURA_ALPHA
local DB_AURA_ENABLED
local DB_AURA_SEPARATE_BUFFS

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
    local options_text_template = DF:GetTemplate ("font", "OPTIONS_FONT_TEMPLATE")
    local options_dropdown_template = DF:GetTemplate ("dropdown", "OPTIONS_DROPDOWN_TEMPLATE")
    local options_switch_template = DF:GetTemplate ("switch", "OPTIONS_CHECKBOX_TEMPLATE")
    local options_slider_template = DF:GetTemplate ("slider", "OPTIONS_SLIDER_TEMPLATE")
    local options_button_template = DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE")

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

    auraLastEventFrame.Header = DF:CreateHeader (auraLastEventFrame, headerTable, headerOptions)
    auraLastEventFrame.Header:SetPoint ("topleft", auraLastEventFrame, "topleft", 10, headerY)

    --line scripts
    local line_onenter = function (self)
        if (self.hasHighlight) then
            local r, g, b, a = unpack(highlightColorLastCombat)
            self:SetBackdropColor(r, g, b, a+0.2)
        else
            self:SetBackdropColor (unpack (backdrop_color_on_enter))
        end

        if (self.SpellID) then
            GameTooltip:SetOwner (self, "ANCHOR_TOPLEFT")
            GameTooltip:SetSpellByID (self.SpellID)
            GameTooltip:AddLine (" ")
            GameTooltip:Show()
        end
    end

    local line_onleave = function (self)
        if (self.hasHighlight) then
            self:SetBackdropColor(unpack(highlightColorLastCombat))
        else
            self:SetBackdropColor(unpack(backdrop_color))
        end
        GameTooltip:Hide()
    end

    local widget_onenter = function (self)
        local line = self:GetParent()
        line:GetScript ("OnEnter")(line)
    end
    local widget_onleave = function (self)
        local line = self:GetParent()
        line:GetScript ("OnLeave")(line)
    end

    local line_add_tracklist = function (self)
        self = self:GetCapsule()

        if (self.AuraType == "BUFF") then
            if (Plater.db.profile.aura_tracker.track_method == 0x1) then
                Plater.db.profile.aura_tracker.buff_tracked [self.SpellID] = true
                Plater:Msg ("Aura added to buff tracking.")

            elseif (Plater.db.profile.aura_tracker.track_method == 0x2) then
                local added = DF.table.addunique (Plater.db.profile.aura_tracker.buff, self.SpellID)
                if (added) then
                    Plater:Msg ("Aura added to manual buff tracking.")
                else
                    Plater:Msg ("Aura not added: already on track.")
                end

            end

        elseif (self.AuraType == "DEBUFF") then
            if (Plater.db.profile.aura_tracker.track_method == 0x1) then
                Plater.db.profile.aura_tracker.debuff_tracked [self.SpellID] = true
                Plater:Msg ("Aura added to debuff tracking.")

            elseif (Plater.db.profile.aura_tracker.track_method == 0x2) then
                local added = DF.table.addunique (Plater.db.profile.aura_tracker.debuff, self.SpellID)
                if (added) then
                    Plater:Msg ("Aura added to manual debuff tracking.")
                else
                    Plater:Msg ("Aura not added: already on track.")
                end

            end
        end
    end

    local line_add_ignorelist = function (self)
        self = self:GetCapsule()

        if (self.AuraType == "BUFF") then
            if (Plater.db.profile.aura_tracker.track_method == 0x1) then
                Plater.db.profile.aura_tracker.buff_banned [self.SpellID] = true
                Plater:Msg ("Aura added to buff blacklist.")
            end

        elseif (self.AuraType == "DEBUFF") then
            if (Plater.db.profile.aura_tracker.track_method == 0x1) then
                Plater.db.profile.aura_tracker.debuff_banned [self.SpellID] = true
                Plater:Msg ("Aura added to debuff blacklist.")
            end
        end
    end

    local line_add_special = function (self)
        self = self:GetCapsule()

        local added = DF.table.addunique (Plater.db.profile.extra_icon_auras, self.SpellID)
        if (added) then
            Plater:Msg ("Aura added to the special aura container.")
        else
            Plater:Msg ("Aura not added: already on the special container.")
        end
    end

    local line_onclick_trigger_dropdown = function (self, fixedValue, scriptID)
        local scriptObject = Plater.GetScriptObject (scriptID, "script")
        local spellName = GetSpellInfo (self.SpellID)

        if (scriptObject and spellName) then
            if (scriptObject.ScriptType == 1 or scriptObject.ScriptType == 2) then
                --add the trigger
                local added = DF.table.addunique (scriptObject.SpellIds, self.SpellID)
                if (added) then
                    --reload all scripts
                    Plater.WipeAndRecompileAllScripts ("script")
                    Plater:Msg ("Trigger added to script.")
                else
                    Plater:Msg ("Script already have this trigger.")
                end

                --refresh and select no option
                self:Refresh()
                self:Select (0, true)
            end
        end
    end

    local line_refresh_trigger_dropdown = function (self)
        if (not self.SpellID) then
            return {}
        end

        local t = {}
        local spellName = GetSpellInfo (self.SpellID)

        local scripts = Plater.GetAllScripts ("script")
        for i = 1, #scripts do
            local scriptObject = scripts [i]
            if (scriptObject.ScriptType == 1 or scriptObject.ScriptType == 2) then
                tinsert (t, {0, 0, scriptObject.Name, scriptObject.Enabled and 1 or 0, 0, label = scriptObject.Name, value = i, color = scriptObject.Enabled and "white" or "red", onclick = line_onclick_trigger_dropdown, desc = scriptObject.Desc})
            end
        end

        table.sort (t, Plater.SortScripts)
        return t
    end

    local line_create_aura = function (self)
        self = self:GetCapsule()

        if (Details) then
            local spellName, _, spellIcon = GetSpellInfo (self.SpellID)
            local encounterID = self.EncounterID

            Details:OpenAuraPanel (self.SpellID, spellName, spellIcon, encounterID, self.AuraType == "BUFF" and 5 or self.AuraType == "DEBUFF" and 1 or self.IsCast and 7 or 2, 1)
            PlaterOptionsPanelFrame:Hide()
        else
            Plater:Msg ("Details! Damage Meter not found, install it from the Twitch App!")
        end
    end

    local oneditfocusgained_spellid = function (self, capsule)
        self:HighlightText (0)
    end

    --line
    local scroll_createline = function (self, index)

        local line = CreateFrame ("button", "$parentLine" .. index, self, BackdropTemplateMixin and "BackdropTemplate")
        line:SetPoint ("topleft", self, "topleft", 1, -((index-1)*(scroll_line_height+1)) - 1)
        line:SetSize (scroll_width - 2, scroll_line_height)
        line:SetScript ("OnEnter", line_onenter)
        line:SetScript ("OnLeave", line_onleave)

        line:SetBackdrop ({bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
        line:SetBackdropColor (unpack (backdrop_color))

        DF:Mixin (line, DF.HeaderFunctions)

        local icon = line:CreateTexture ("$parentSpellIcon", "overlay")
        icon:SetSize (scroll_line_height - 2, scroll_line_height - 2)

        local spell_id = DF:CreateTextEntry (line, function()end, headerTable[2].width, 20, nil, nil, nil, DF:GetTemplate ("dropdown", "PLATER_DROPDOWN_OPTIONS"))
        spell_id:SetHook ("OnEditFocusGained", oneditfocusgained_spellid)
        spell_id:SetJustifyH("left")

        local spell_name = DF:CreateLabel (line, "", DF:GetTemplate ("font", "PLATER_SCRIPTS_NAME"))
        local source_name = DF:CreateLabel (line, "", DF:GetTemplate ("font", "PLATER_SCRIPTS_NAME"))
        local spell_type = DF:CreateLabel (line, "", DF:GetTemplate ("font", "PLATER_SCRIPTS_NAME"))

        local add_tracklist = DF:CreateButton (line, line_add_tracklist, headerTable[6].width, 20, "Add", -1, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
        local add_ignorelist = DF:CreateButton (line, line_add_ignorelist, headerTable[7].width, 20, "Add", -1, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
        local add_special = DF:CreateButton (line, line_add_special, headerTable[8].width, 20, "Add", -1, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))

        local add_script_trigger = DF:CreateDropDown (line, line_refresh_trigger_dropdown, 1, headerTable[9].width, 20, nil, nil, DF:GetTemplate ("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))

        local create_aura = DF:CreateButton (line, line_create_aura, headerTable[10].width, 20, "Create", -1, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))

        local fromLastCombat = DF:CreateLabel (line, "", DF:GetTemplate ("font", "PLATER_SCRIPTS_NAME"))

        spell_id:SetHook ("OnEnter", widget_onenter)
        spell_id:SetHook ("OnLeave", widget_onleave)

        add_tracklist:SetHook ("OnEnter", widget_onenter)
        add_tracklist:SetHook ("OnLeave", widget_onleave)

        add_ignorelist:SetHook ("OnEnter", widget_onenter)
        add_ignorelist:SetHook ("OnLeave", widget_onleave)

        add_special:SetHook ("OnEnter", widget_onenter)
        add_special:SetHook ("OnLeave", widget_onleave)

        add_script_trigger:SetHook ("OnEnter", widget_onenter)
        add_script_trigger:SetHook ("OnLeave", widget_onleave)

        create_aura:SetHook ("OnEnter", widget_onenter)
        create_aura:SetHook ("OnLeave", widget_onleave)

        line:AddFrameToHeaderAlignment (icon)
        line:AddFrameToHeaderAlignment (spell_id)
        line:AddFrameToHeaderAlignment (spell_name)
        line:AddFrameToHeaderAlignment (source_name)
        line:AddFrameToHeaderAlignment (spell_type)
        line:AddFrameToHeaderAlignment (add_tracklist)
        line:AddFrameToHeaderAlignment (add_ignorelist)
        line:AddFrameToHeaderAlignment (add_special)
        line:AddFrameToHeaderAlignment (add_script_trigger)
        line:AddFrameToHeaderAlignment (fromLastCombat)
        --line:AddFrameToHeaderAlignment (create_aura)

        line:AlignWithHeader (auraLastEventFrame.Header, "left")

        line.Icon = icon
        line.SpellIDEntry = spell_id
        line.SpellName = spell_name
        line.SourceName = source_name
        line.SpellType = spell_type
        line.AddTrackList = add_tracklist
        line.AddIgnoreList = add_ignorelist
        line.AddSpecial = add_special
        line.AddTrigger = add_script_trigger
        line.CreateAura = create_aura
        line.FromLastCombat = fromLastCombat

        return line
    end

    --refresh scroll

    local sortOrder4 = function(t1, t2)
        return t1[4] > t2[4]
    end

    local IsSearchingFor
    local scroll_refresh = function (self, data, offset, total_lines)

        local dataInOrder = {}
        --buff list tab
        local lastCombatNpcs = Plater.LastCombat.npcNames or {}

        if (IsSearchingFor and IsSearchingFor ~= "") then
            if (self.SearchCachedTable and IsSearchingFor == self.SearchCachedTable.SearchTerm) then
                dataInOrder = self.SearchCachedTable
            else
                for i = 1, #data do
                    local spellID = data[i] [1]
                    local spellName, _, spellIcon = GetSpellInfo (spellID)
                    local spellTable = data[i][2]
                    if (spellName) then
                        if (spellName:lower():find (IsSearchingFor)) then
                            dataInOrder [#dataInOrder+1] = {i, data[i], spellName, lastCombatNpcs[spellTable.source] and 2 or 0}
                        end
                    end
                end

                self.SearchCachedTable = dataInOrder
                self.SearchCachedTable.SearchTerm = IsSearchingFor
            end
        else
            if (not self.CachedTable) then
                for i = 1, #data do
                    local spellID = data[i] [1]
                    local spellName, _, spellIcon = GetSpellInfo (spellID)
                    local spellTable = data[i][2]
                    if (spellName) then
                        dataInOrder [#dataInOrder+1] = {i, data[i], spellName, lastCombatNpcs[spellTable.source] and 2 or 0}
                    end
                end
                self.CachedTable = dataInOrder
            end

            dataInOrder = self.CachedTable
        end

        table.sort (dataInOrder, DF.SortOrder3R)
        table.sort (dataInOrder, sortOrder4)

        data = dataInOrder

        for i = 1, total_lines do
            local index = i + offset
            local spellTable = data [index] and data [index] [2]

            if (spellTable) then
                local line = self:GetLine (i)
                local spellID = spellTable [1]
                local spellData = spellTable [2]

                local spellName, _, spellIcon = GetSpellInfo (spellID)

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
                    line.Icon:SetTexture (spellIcon)
                    line.Icon:SetTexCoord (.1, .9, .1, .9)

                    line.SpellName:SetTextTruncated (spellName, headerTable [3].width)
                    line.SourceName:SetTextTruncated (spellData.source, headerTable [4].width)

                    local isCast = spellData.event == "SPELL_CAST_START" or spellData.event == "SPELL_CAST_SUCCESS"

                    if (spellData.type == "BUFF") then
                        line.SpellType.color = "PLATER_BUFF"

                    elseif (spellData.type == "DEBUFF") then
                        line.SpellType.color = "PLATER_DEBUFF"

                    elseif (isCast) then
                        line.SpellType.color = "PLATER_CAST"

                    end

                    line.SpellID = spellID

                    line.SpellIDEntry:SetText (spellID)

                    --{event = token, source = sourceName, type = auraType, npcID = Plater:GetNpcIdFromGuid (sourceGUID or "")}
                    line.SpellType:SetText (isCast and "Spell Cast" or spellData.event == "SPELL_AURA_APPLIED" and spellData.type)

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
    local spells_scroll = DF:CreateScrollBox (auraLastEventFrame, "$parentSpellScroll", scroll_refresh, {}, scroll_width, scroll_height, scroll_lines, scroll_line_height)
    DF:ReskinSlider (spells_scroll)
    spells_scroll:SetPoint ("topleft", auraLastEventFrame, "topleft", 10, scrollY)

    spells_scroll:SetScript ("OnShow", function (self)
        if (self.LastRefresh and self.LastRefresh+0.5 > GetTime()) then
            return
        end
        self.LastRefresh = GetTime()

        local newData = {}

        for spellID, spellTable in pairs (DB_CAPTURED_SPELLS) do
            tinsert (newData, {spellID, spellTable})
        end

        self.CachedTable = nil
        self.SearchCachedTable = nil

        self:SetData (newData)
        self:Refresh()
    end)

    --create lines
    for i = 1, scroll_lines do
        spells_scroll:CreateLine (scroll_createline)
    end

    --create button to open spell list on Details!
    local openDetailsSpellList = function()
        if (Details) then
            Details.OpenForge()
            PlaterOptionsPanelFrame:Hide()
            --select all spells in the details! all spells panel
            if (DetailsForgePanel and DetailsForgePanel.SelectModule) then
                -- module 2 is the All Spells
                DetailsForgePanel.SelectModule (_, _, 1)
            end
        else
            Plater:Msg ("Details! Damage Meter is required and isn't installed, get it on Twitch App!")
        end
    end

    local open_spell_list_button = DF:CreateButton (auraLastEventFrame, openDetailsSpellList, 160, 20, "Open Full Spell List", -1, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
    open_spell_list_button:SetPoint ("bottomright", spells_scroll, "topright", 0, 24)

    --create the clean list button
        local wipe_spell_list = function()
            wipe (DB_CAPTURED_SPELLS)
            spells_scroll:Hide()
            C_Timer.After (0.016, function() spells_scroll:Show(); spells_scroll:Refresh() end)
        end
        local clear_list_button = DF:CreateButton (auraLastEventFrame, wipe_spell_list, 160, 20, "Clear List", -1, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
        clear_list_button:SetPoint ("right", open_spell_list_button, "left", -6, 0)

    --create search box
        function auraLastEventFrame.OnSearchBoxTextChanged()
            local text = auraLastEventFrame.AuraSearchTextEntry:GetText()
            if (text and string.len (text) > 0) then
                IsSearchingFor = text:lower()
            else
                IsSearchingFor = nil
            end
            spells_scroll:Refresh()
        end

        local aura_search_textentry = DF:CreateTextEntry (auraLastEventFrame, function()end, 160, 20, "AuraSearchTextEntry", _, _, options_dropdown_template)
        aura_search_textentry:SetPoint ("right", clear_list_button, "left", -6, 0)
        aura_search_textentry:SetHook ("OnChar",		auraLastEventFrame.OnSearchBoxTextChanged)
        aura_search_textentry:SetHook ("OnTextChanged", 	auraLastEventFrame.OnSearchBoxTextChanged)
        local aura_search_label = DF:CreateLabel (auraLastEventFrame, "Search:", DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"))
        aura_search_label:SetPoint ("right", aura_search_textentry, "left", -2, 0)

    --create the description
    auraLastEventFrame.TitleDescText = Plater:CreateLabel (auraLastEventFrame, "Quick way to manage auras from a recent raid boss or dungeon run", 10, "silver")
    auraLastEventFrame.TitleDescText:SetPoint ("bottomleft", spells_scroll, "topleft", 0, 26)

end
