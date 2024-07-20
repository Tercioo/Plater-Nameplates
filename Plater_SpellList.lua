
local addonId, platerInternal = ...

local Plater = Plater

---@type detailsframework
local detailsFramework = DetailsFramework

local _

---@class spelllist_scrolldata : table
---@field [1] spellid
---@field [2] plater_spelldata

---@class plater_spelllist_line : frame, df_headerfunctions
---@field value spelllist_scrolldata
---@field hasHighlight boolean
---@field SpellID number
---@field Icon texture
---@field SpellIDEntry df_textentry
---@field SpellName df_textentry
---@field SourceName df_textentry
---@field SpellType df_label
---@field AddTrackList df_button
---@field SelectAudioDropdown df_dropdown
---@field AddIgnoreList df_button
---@field AddSpecial df_button
---@field AddTrigger df_dropdown
---@field CreateAura df_button
---@field FromLastCombat df_label

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
local DB_CAST_AUDIOCUES

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
    DB_CAST_AUDIOCUES = profile.cast_audiocues
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
        {text = "", width = 20},
        {text = "Spell ID", width = 54},
        {text = "Spell Name", width = 130},
        {text = "Source", width = 130},
        {text = "Spell Type", width = 75},
        {text = "", width = 140},
        {text = "Add to Blacklist", width = 100},
        {text = "Add to Special Auras", width = 120},
        {text = "Add to Script", width = 120},
        {text = "From Last Combat", width = 100}, --, icon = _G.WeakAuras and [[Interface\AddOns\WeakAuras\Media\Textures\icon]] or ""
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

    --audio cues - this is a copy paste from the dropdown existing in the Cast Colors Panels
    local line_select_audio_dropdown = function (self, spellId, audioFilePath)
        DB_CAST_AUDIOCUES[spellId] = audioFilePath
        auraLastEventFrame.spellsScroll.CachedTable = nil
        auraLastEventFrame.spellsScroll:Refresh()
    end

    local audioFileNameToCueName = {}
    local colorNoValue = {1, 1, 1, 0.5}

    local audioCueSort = function(t1, t2)
        if (t1[4] and not t2[4]) then
            return true

        elseif (not t1[4] and t2[4]) then
            return false

        elseif (t1[4] and t2[4]) then
            return t1[3] < t2[3]
        else
            return t1[3] < t2[3]
        end
    end

    local dropdownIconColor = {1, 1, 1, .6}

    ---@param self df_dropdown
    local createAudioCueList = function(self, fullRefresh)
        local audioCueList = {
            {
                label = " select audio",
                value = nil,
                color = colorNoValue,
                statusbar = [[Interface\Tooltips\UI-Tooltip-Background]],
                statusbarcolor = {.1, .1, .1, .92},
                icon = [[Interface\AddOns\Plater\media\audio_cue_icon]],
                iconcolor = {1, 1, 1, .4},
                onclick = line_select_audio_dropdown
            }
        }

        local cuesInUse = {}
        for spellId, cueFile in pairs(DB_CAST_AUDIOCUES) do
            cuesInUse[cueFile] = true
        end

        local audioCues = _G.LibStub:GetLibrary("LibSharedMedia-3.0"):HashTable("sound")
        local audioListInOrder = {}
        for cueName, cueFile in pairs(audioCues) do
            audioListInOrder[#audioListInOrder+1] = {cueName, cueFile, cueName:lower(), cuesInUse[cueFile] or false}
            audioFileNameToCueName[cueFile] = cueName
        end

        table.sort(audioListInOrder, audioCueSort)

        --table.sort(audioListInOrder, function(t1, t2) return t1[3] < t2[3] end) --alphabetical
        --table.sort(audioListInOrder, function(t1, t2) return t1[4] > t2[4] end) --in use

        local currentSelected = self:GetValue()
        if (type(currentSelected) == "string") then
            currentSelected = currentSelected
        else
            currentSelected = nil
        end

        for i = 1, #audioListInOrder do
            local cueName, cueFile, lowerName, cueInUse = unpack(audioListInOrder[i])
            audioCueList[#audioCueList+1] = {
                label = " " .. cueName,
                value = cueFile,
                audiocue = cueFile,
                color = "white",
                statusbar = platerInternal.Defaults.dropdownStatusBarTexture,
                statusbarcolor = cueInUse and {.3, .3, .3, .8} or platerInternal.Defaults.dropdownStatusBarColor,
                iconcolor = dropdownIconColor,
                icon = [[Interface\AddOns\Plater\media\audio_cue_icon]],
                onclick = line_select_audio_dropdown,
                --desc = desc, --
            }
        end

        auraLastEventFrame.AudioCueListCache = audioCueList
    end

    local line_refresh_audio_dropdown = function(self)
        createAudioCueList(self, true)
        return auraLastEventFrame.AudioCueListCache
    end

    --line
    local scrollCreateLine = function(self, index)
        ---@type plater_spelllist_line
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

        local spellNameEntry = detailsFramework:CreateTextEntry(line, function()end, headerTable[4].width, 20, "spellNameEntry", nil, nil, detailsFramework:GetTemplate("dropdown", "PLATER_DROPDOWN_OPTIONS"))
        spellNameEntry:SetHook("OnEditFocusGained", onEditFocusGained_SpellIdEntry)
        spellNameEntry:SetJustifyH("left")
        --local spellNameLabel = detailsFramework:CreateLabel(line, "", detailsFramework:GetTemplate("font", "PLATER_SCRIPTS_NAME"))

        local sourceNameEntry = detailsFramework:CreateTextEntry(line, function()end, headerTable[4].width, 20, "spellSourceEntry", nil, nil, detailsFramework:GetTemplate("dropdown", "PLATER_DROPDOWN_OPTIONS"))
        sourceNameEntry:SetHook("OnEditFocusGained", onEditFocusGained_SpellIdEntry)
        sourceNameEntry:SetJustifyH("left")
        --local sourceNameLabel = detailsFramework:CreateLabel(line, "", detailsFramework:GetTemplate("font", "PLATER_SCRIPTS_NAME"))

        local spellTypeLabel = detailsFramework:CreateLabel(line, "", detailsFramework:GetTemplate("font", "PLATER_SCRIPTS_NAME"))

        --these are the three buttons shown when the spell is an aura
        local addTracklistButton = detailsFramework:CreateButton(line, lineAddTracklist, headerTable[6].width, 20, "Track Aura", -1, nil, nil, nil, nil, nil, detailsFramework:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE"), detailsFramework:GetTemplate("font", "PLATER_BUTTON"))
        local addIgnorelistButton = detailsFramework:CreateButton(line, lineAddIgnorelist, headerTable[7].width, 20, "Blacklist Aura", -1, nil, nil, nil, nil, nil, detailsFramework:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE"), detailsFramework:GetTemplate("font", "PLATER_BUTTON"))
        local addSpecialButton = detailsFramework:CreateButton(line, lineAddSpecial, headerTable[8].width, 20, "Add To Buff Special", -1, nil, nil, nil, nil, nil, detailsFramework:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE"), detailsFramework:GetTemplate("font", "PLATER_BUTTON"))

        --select audio dropdown when the spell is a cast
        local selectAudioDropdown = detailsFramework:CreateDropDown(line, line_refresh_audio_dropdown, 1, headerTable[6].width - 1, 20, "SelectAudioDropdown", nil, detailsFramework:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))
        selectAudioDropdown:SetFrameLevel(line:GetFrameLevel()+2)
        selectAudioDropdown:Hide() --hide by default, only show when the spell is a cast, need to hide the addTracklistButton when this dropdown is shown

        --trick: the dropdown cannot be inserted in the header, so it's inserted in the line and aligned with the header
        --to get the xOffSet, the sum of all widths of the previous headers is used
        local xOffSet = headerTable[1].width + headerTable[2].width + headerTable[3].width + headerTable[4].width + headerTable[5].width
        xOffSet = xOffSet + 10 --padding
        selectAudioDropdown:SetPoint("topleft", line, "topleft", xOffSet, 0)

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
        line:AddFrameToHeaderAlignment(spellNameEntry)
        line:AddFrameToHeaderAlignment(sourceNameEntry)
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
        line.SpellName = spellNameEntry
        line.SourceName = sourceNameEntry
        line.SpellType = spellTypeLabel
        line.AddTrackList = addTracklistButton
        line.SelectAudioDropdown = selectAudioDropdown
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

    local audioUpdateScheduled = {}
    local updateAudioSelector = function(line, selectedAudioCue)
        if (selectedAudioCue)then
            --this spell has an audio cue
            line.SelectAudioDropdown:Select(selectedAudioCue)
        else
            line.SelectAudioDropdown:Select(1, true)
        end
    end

    local sIsSearchingFor

    ---@param self df_scrollbox
    ---@param data spelllist_scrolldata[]
    ---@param offset number
    ---@param totalLines number
    local scrollRefresh = function(self, data, offset, totalLines) --~refresh
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
            local spellTable = data[index] and data[index][2]

            if (spellTable) then
                local line = self:GetLine(i)
                ---@cast line plater_spelllist_line

                local spellId = spellTable[1]
                ---@type plater_spelldata
                local spellData = spellTable[2]

                local spellName, _, spellIcon = GetSpellInfo(spellId)

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

                    --line.SpellName:SetTextTruncated(spellName, headerTable [3].width)
                    line.SpellName:SetText(spellName)
                    --line.SourceName:SetTextTruncated(spellData.source, headerTable [4].width)
                    line.SourceName:SetText(spellData.source)

                    local bIsCast = spellData.event == "SPELL_CAST_START" or spellData.event == "SPELL_CAST_SUCCESS"

                    if (spellData.type == "BUFF") then
                        line.SpellType.color = "PLATER_BUFF"

                    elseif (spellData.type == "DEBUFF") then
                        line.SpellType.color = "PLATER_DEBUFF"

                    elseif (bIsCast) then
                        line.SpellType.color = "PLATER_CAST"

                    end

                    line.SpellID = spellId

                    line.SpellIDEntry:SetText(spellId)

                    --{event = token, source = sourceName, type = auraType, npcID = Plater:GetNpcIdFromGuid(sourceGUID or "")}
                    line.SpellType:SetText(bIsCast and "Spell Cast" or spellData.event == "SPELL_AURA_APPLIED" and spellData.type or "")

                    line.AddTrackList.SpellID = spellId
                    line.AddTrackList.AuraType = spellData.type
                    line.AddTrackList.EncounterID = spellData.encounterID

                    line.AddIgnoreList.SpellID = spellId
                    line.AddIgnoreList.AuraType = spellData.type
                    line.AddIgnoreList.EncounterID = spellData.encounterID

                    line.AddSpecial.SpellID = spellId
                    line.AddSpecial.AuraType = spellData.type
                    line.AddSpecial.EncounterID = spellData.encounterID

                    if (bIsCast) then
                        line.AddTrackList:Hide()
                        line.AddIgnoreList:Disable()
                        line.AddSpecial:Disable()
                        line.SelectAudioDropdown:Show()
                        line.SelectAudioDropdown.spellId = spellId
                        line.SelectAudioDropdown:SetFixedParameter(spellId)
                        local selectedAudioCue = DB_CAST_AUDIOCUES[spellId]

                        if (audioUpdateScheduled[line] and not audioUpdateScheduled[line]:IsCancelled()) then
                            audioUpdateScheduled[line]:Cancel()
                        end
                        audioUpdateScheduled[line] = detailsFramework.Schedules.NewTimer(0.085, updateAudioSelector, line, selectedAudioCue)

                    elseif (spellData.type) then
                        line.SelectAudioDropdown:Hide()
                        line.AddTrackList:Show()
                        line.AddTrackList:Enable()
                        line.AddIgnoreList:Enable()
                        line.AddSpecial:Enable()
                    else
                        line.SelectAudioDropdown:Hide()
                        line.AddTrackList:Show()
                        line.AddTrackList:Disable()
                        line.AddIgnoreList:Disable()
                        line.AddSpecial:Disable()
                    end

                    line.CreateAura.SpellID = spellId
                    line.CreateAura.AuraType = spellData.type
                    line.CreateAura.IsCast = spellData.event == "SPELL_CAST_START"
                    line.CreateAura.EncounterID = spellData.encounterID

                    line.AddTrigger.SpellID = spellId
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
    auraLastEventFrame.spellsScroll = latestSpellsScroll

    latestSpellsScroll:SetScript("OnShow", function(self)
        if (self.LastRefresh and self.LastRefresh+0.5 > GetTime()) then
            return
        end
        self.LastRefresh = GetTime()

        ---@type spelllist_scrolldata[]
        local newData = {}

        for spellID, spellTable in pairs(DB_CAPTURED_SPELLS) do
            --if spellTable has 'isChanneled' entry, it means is a cast or channeling
            --if spellTable has 'type' entry, it means if a buff or debuff
            local sortWeight = spellTable.isChanneled ~= nil and 2 or 0
            sortWeight = sortWeight + (spellTable.type == "BUFF" and 1 or 0)
            tinsert(newData, {spellID, spellTable, sortWeight})
        end

        table.sort(newData, function(t1, t2)
            return t1[3] > t2[3]
        end)

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
