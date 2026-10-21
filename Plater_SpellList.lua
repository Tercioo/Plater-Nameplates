
local addonId, platerInternal = ...

local Plater = Plater

---@type detailsframework
local detailsFramework = DetailsFramework

local _

local IS_WOW_PROJECT_MIDNIGHT_API_WITH_AURA_CONTAINERS = C_XMLUtil and C_XMLUtil.GetTemplateInfo and C_XMLUtil.GetTemplateInfo("CustomAuraContainerTemplate") and true or false

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
---@field ColorDropdown df_dropdown
---@field PandemicColorDropdown df_dropdown
---@field ByNameCheckbox df_checkbox
---@field OnlyMineCheckbox df_checkbox
---@field MoveUpButton df_button
---@field MoveDownButton df_button
---@field RemoveColor df_button

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
local DB_AURA_COLORS

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
    DB_AURA_COLORS = profile.aura_colors
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

    --while auras are secret no spells are captured, the list only holds the per aura healthbar colors.
    --source, type, tracking, special auras and scripts have nothing to work with there
    if (IS_WOW_PROJECT_MIDNIGHT_API_WITH_AURA_CONTAINERS) then
        headerTable = {
            {text = "", width = 20},
            {text = "Spell ID", width = 54},
            {text = "Spell Name", width = 330},
            {text = "Add to Blacklist", width = 100},
            {text = "Health Bar Color", width = 175},
            {text = "Pandemic Color", width = 175},
            {text = "By Name", width = 50},
            {text = "Only Mine", width = 55},
            {text = "Priority", width = 45},
            {text = "", width = 20},
        }
    end

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

        if (type(self.SpellID) == "number") then
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

    --blacklists the aura of a row. it has no aura type, so it goes to both lists.
    --an aura added by name is blacklisted by name, one added by spell id only with that id
    local lineAddIgnorelistBySpellKey = function(self)
        local spellKey = self:GetCapsule().SpellID
        local isSpellName = type(spellKey) == "string"
        local spellId = spellKey

        if (isSpellName) then
            --the blacklist is keyed by spell id, by name it uses the name of that spell
            local spellIds = Plater.db.profile.aura_tracker.spell_name_cache[spellKey] or Plater.SpellCaches.allIDsByName[spellKey]
            spellId = spellIds and spellIds[1]
        end

        if (not spellId) then
            Plater:Msg("Spell not found: " .. spellKey)
            return
        end

        Plater.db.profile.aura_tracker.buff_banned[spellId] = isSpellName
        Plater.db.profile.aura_tracker.debuff_banned[spellId] = isSpellName
        Plater.UpdateAuraCache()
        Plater:Msg(isSpellName and "Aura added to the blacklist by name." or "Aura added to the blacklist.")
    end

    --keeps the text of a row entry, it can be selected and copied but not changed
    local keepEntryText = function(editbox, byUser, capsule)
        if (byUser) then
            editbox:SetText(capsule.readOnlyText)
            editbox:HighlightText()
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

    --returns the aura color settings of a spell, creates them with the defaults when the spell has none
    local getAuraColorTable = function(spellKey)
        local colorTable = DB_AURA_COLORS[spellKey]
        if (not colorTable) then
            --a new aura is placed at the top of the list, which is the highest priority
            local highestPriority = 0
            for _, otherColorTable in pairs(DB_AURA_COLORS) do
                highestPriority = math.max(highestPriority, otherColorTable[5])
            end

            --enabled, color, track by name, only mine, priority, pandemic color
            colorTable = {false, "white", false, true, highestPriority + 1, false}
            DB_AURA_COLORS[spellKey] = colorTable
        end

        return colorTable
    end

    --rebuilds the list data, used when a row is added or removed
    local rebuildSpellList = function()
        local spellsScroll = auraLastEventFrame.spellsScroll
        spellsScroll.LastRefresh = nil
        spellsScroll:GetScript("OnShow")(spellsScroll)
    end

    --holds the cached options of the pandemic color dropdowns. the options carry their click handler, so they can't share the cache of the color dropdowns
    local pandemicColorOptions = {}

    --applies a changed aura color to the nameplates and refreshes the rows
    local onAuraColorChanged = function()
        --both kinds of color dropdown cache their options
        auraLastEventFrame.cachedColorTable = nil
        pandemicColorOptions.cachedColorTable = nil
        Plater.UpdateAuraCache()

        --the cached rows hold the sort order, which depends on the aura colors
        local spellsScroll = auraLastEventFrame.spellsScroll
        spellsScroll.CachedTable = nil
        spellsScroll.SearchCachedTable = nil
        spellsScroll:Refresh()
    end

    local hasRequestedSpellCache = false

    --refreshes the rows once the spell cache is built, auras added by name get their name and icon then
    local onSpellCacheReady = function()
        local spellsScroll = auraLastEventFrame.spellsScroll
        if (spellsScroll:IsVisible()) then
            spellsScroll.CachedTable = nil
            spellsScroll.SearchCachedTable = nil
            spellsScroll:Refresh()
        end
    end

    --returns name and icon of a row. an aura color can be keyed by spell name, which is resolved by the spell cache of the aura system
    local getSpellNameAndIcon = function(spellKey)
        if (type(spellKey) == "number") then
            local spellName, _, spellIcon = GetSpellInfo(spellKey)
            return spellName, spellIcon
        end

        local spellIds = Plater.db.profile.aura_tracker.spell_name_cache[spellKey] or Plater.SpellCaches.allIDsByName[spellKey]
        if (spellIds) then
            local spellName, _, spellIcon = GetSpellInfo(spellIds[1])
            return spellName, spellIcon
        end

        --not resolved yet: build the spell cache and refresh the list when it is ready
        if (not hasRequestedSpellCache and not platerInternal.Auras.spellCachesLoaded) then
            hasRequestedSpellCache = true
            platerInternal.Auras.InitSpellCache(onSpellCacheReady)
        end

        return spellKey, [[Interface\ICONS\INV_Misc_QuestionMark]]
    end

    --a color was selected in the dropdown of a row
    local lineSelectAuraColor = function(self, spellKey, color)
        local colorTable = getAuraColorTable(spellKey)
        colorTable[1] = color ~= platerInternal.RemoveColor
        colorTable[2] = colorTable[1] and color or "white"
        onAuraColorChanged()
    end

    --builds the options of the color dropdown of a row
    local lineRefreshAuraColorDropdown = function(self)
        return platerInternal.RefreshColorDropdown(auraLastEventFrame, self, DB_AURA_COLORS, lineSelectAuraColor, "spellId", 1, 2)
    end

    --a pandemic color was selected in the dropdown of a row, "no color" removes it
    local lineSelectPandemicColor = function(self, spellKey, color)
        getAuraColorTable(spellKey)[6] = color ~= platerInternal.RemoveColor and color or false
        onAuraColorChanged()
    end

    --builds the options of the pandemic color dropdown of a row. the helper only uses its first argument to store the option list
    local lineRefreshPandemicColorDropdown = function(self)
        return platerInternal.RefreshColorDropdown(pandemicColorOptions, self, DB_AURA_COLORS, lineSelectPandemicColor, "spellId", 6, 6)
    end

    --the "By Name" checkbox of a row was clicked
    local lineToggleByName = function(self, spellKey, value)
        getAuraColorTable(spellKey)[3] = value
        onAuraColorChanged()
    end

    --the "Only Mine" checkbox of a row was clicked
    local lineToggleOnlyMine = function(self, spellKey, value)
        getAuraColorTable(spellKey)[4] = value
        onAuraColorChanged()
    end

    --an arrow of a row was clicked, 'direction' is 1 to move the aura up and -1 to move it down.
    --the aura swaps places with its neighbor and all auras are numbered again, the top one has the highest priority
    local lineMoveAuraColor = function(self, mouseButton, spellKey, direction)
        local spellKeys = {}
        for otherSpellKey in pairs(DB_AURA_COLORS) do
            spellKeys[#spellKeys+1] = otherSpellKey
        end

        --the same order as the list, equal priorities from older settings are ordered by the spell key
        table.sort(spellKeys, function(spellKey1, spellKey2)
            local priority1 = DB_AURA_COLORS[spellKey1][5]
            local priority2 = DB_AURA_COLORS[spellKey2][5]
            if (priority1 ~= priority2) then
                return priority1 > priority2
            end

            return tostring(spellKey1) < tostring(spellKey2)
        end)

        local index = tIndexOf(spellKeys, spellKey)
        local neighborIndex = index - direction
        if (not spellKeys[neighborIndex]) then
            return
        end

        spellKeys[index], spellKeys[neighborIndex] = spellKeys[neighborIndex], spellKeys[index]
        for priorityIndex, otherSpellKey in ipairs(spellKeys) do
            DB_AURA_COLORS[otherSpellKey][5] = #spellKeys - priorityIndex + 1
        end

        onAuraColorChanged()
    end

    --the remove button of a row was clicked
    local lineRemoveAuraColor = function(self)
        DB_AURA_COLORS[self:GetCapsule().SpellID] = nil
        onAuraColorChanged()
        rebuildSpellList()
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

        local colorDropdown, pandemicColorDropdown, byNameCheckbox, onlyMineCheckbox, moveUpButton, moveDownButton, removeColorButton
        if (IS_WOW_PROJECT_MIDNIGHT_API_WITH_AURA_CONTAINERS) then
            --the widgets of the columns this list doesn't have stay hidden
            sourceNameEntry:Hide()
            spellTypeLabel:Hide()
            addTracklistButton:Hide()
            addSpecialButton:Hide()
            addScriptTriggerDropdown:Hide()

            spellNameEntry.width = headerTable[3].width
            spellNameEntry:SetHook("OnTextChanged", keepEntryText)
            addIgnorelistButton.width = headerTable[4].width
            addIgnorelistButton:SetClickFunction(lineAddIgnorelistBySpellKey)

            colorDropdown = detailsFramework:CreateDropDown(line, lineRefreshAuraColorDropdown, 1, headerTable[5].width, 20, nil, nil, detailsFramework:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))
            pandemicColorDropdown = detailsFramework:CreateDropDown(line, lineRefreshPandemicColorDropdown, 1, headerTable[6].width, 20, nil, nil, detailsFramework:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))
            byNameCheckbox = detailsFramework:CreateSwitch(line, lineToggleByName, false, _, _, _, _, "ByNameCheckbox", "$parentByNameToggle" .. index, _, _, _, nil, detailsFramework:GetTemplate("switch", "OPTIONS_CHECKBOX_BRIGHT_TEMPLATE"))
            byNameCheckbox:SetAsCheckBox()
            onlyMineCheckbox = detailsFramework:CreateSwitch(line, lineToggleOnlyMine, false, _, _, _, _, "OnlyMineCheckbox", "$parentOnlyMineToggle" .. index, _, _, _, nil, detailsFramework:GetTemplate("switch", "OPTIONS_CHECKBOX_BRIGHT_TEMPLATE"))
            onlyMineCheckbox:SetAsCheckBox()
            moveUpButton = detailsFramework:CreateButton(line, lineMoveAuraColor, 20, 20, "", nil, 1, nil, nil, nil, nil, detailsFramework:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE"))
            --the arrows fill only part of their textures, the texture coordinates cut them out. false keeps the button from growing to fit a text
            moveUpButton:SetIcon([[Interface\BUTTONS\Arrow-Up-Up]], 14, 9, "overlay", {0, 1, 6/16, 1}, nil, nil, -1, nil, false)
            moveUpButton.tooltip = "Raise the priority, the aura at the top of the list colors the health bar first."
            moveDownButton = detailsFramework:CreateButton(line, lineMoveAuraColor, 20, 20, "", nil, -1, nil, nil, nil, nil, detailsFramework:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE"))
            moveDownButton:SetIcon([[Interface\BUTTONS\Arrow-Down-Up]], 14, 9, "overlay", {0, 1, 0, 10/16}, nil, nil, -1, nil, false)
            moveDownButton.tooltip = "Lower the priority."
            removeColorButton = detailsFramework:CreateButton(line, lineRemoveAuraColor, headerTable[10].width, 20, "x", -1, nil, nil, nil, nil, nil, detailsFramework:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE"), detailsFramework:GetTemplate("font", "PLATER_BUTTON"))
        end

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
        if (colorDropdown) then
            line:AddFrameToHeaderAlignment(addIgnorelistButton)
            line:AddFrameToHeaderAlignment(colorDropdown)
            line:AddFrameToHeaderAlignment(pandemicColorDropdown)
            line:AddFrameToHeaderAlignment(byNameCheckbox)
            line:AddFrameToHeaderAlignment(onlyMineCheckbox)
            line:AddFrameToHeaderAlignment(moveUpButton)
            line:AddFrameToHeaderAlignment(removeColorButton)
        else
            line:AddFrameToHeaderAlignment(sourceNameEntry)
            line:AddFrameToHeaderAlignment(spellTypeLabel)
            line:AddFrameToHeaderAlignment(addTracklistButton)
            line:AddFrameToHeaderAlignment(addIgnorelistButton)
            line:AddFrameToHeaderAlignment(addSpecialButton)
            line:AddFrameToHeaderAlignment(addScriptTriggerDropdown)
            line:AddFrameToHeaderAlignment(fromLastCombatLabel)
        end

        --line:AddFrameToHeaderAlignment(create_aura)

        line:AlignWithHeader(auraLastEventFrame.Header, "left")

        --the down arrow shares the priority column with the up arrow
        if (moveDownButton) then
            moveDownButton:SetPoint("left", moveUpButton, "right", 2, 0)
        end

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
        line.ColorDropdown = colorDropdown
        line.PandemicColorDropdown = pandemicColorDropdown
        line.ByNameCheckbox = byNameCheckbox
        line.OnlyMineCheckbox = onlyMineCheckbox
        line.MoveUpButton = moveUpButton
        line.MoveDownButton = moveDownButton
        line.RemoveColor = removeColorButton

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
                    local spellName = getSpellNameAndIcon(spellID)
                    local spellTable = thisData[2]

                    if (spellName) then
                        if (spellName:lower():find(sIsSearchingFor)) then
                            --rows with an aura color are sorted to the top by priority, above the ones from the last combat
                            local sortWeight = lastCombatNpcs[spellTable.source] and 2 or 0
                            local colorTable = DB_AURA_COLORS[spellID]
                            if (colorTable) then
                                sortWeight = 3 + colorTable[5]
                            end

                            dataInOrder [#dataInOrder+1] = {i, data[i], spellName, sortWeight}
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
                    local spellName = getSpellNameAndIcon(spellID)
                    local spellTable = data[i][2]
                    if (spellName) then
                        --rows with an aura color are sorted to the top by priority, above the ones from the last combat
                        local sortWeight = lastCombatNpcs[spellTable.source] and 2 or 0
                        local colorTable = DB_AURA_COLORS[spellID]
                        if (colorTable) then
                            sortWeight = 3 + colorTable[5]
                        end

                        dataInOrder [#dataInOrder+1] = {i, data[i], spellName, sortWeight}
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

                local spellName, spellIcon = getSpellNameAndIcon(spellId)

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
                    line.SpellName.readOnlyText = spellName
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

                    --an aura added by name has no spell id, the grey text says why "By Name" is locked on this row
                    if (type(spellId) == "string") then
                        line.SpellIDEntry:SetText("|cFF808080name only|r")
                    else
                        line.SpellIDEntry:SetText(spellId)
                    end


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

                    if (line.ColorDropdown) then
                        local colorTable = DB_AURA_COLORS[spellId]
                        local isSpellName = type(spellId) == "string"

                        --the tracking button is shown again above for every aura, this list has no tracking column
                        line.AddTrackList:Hide()

                        if (bIsCast) then
                            --colors are for auras only
                            line.ColorDropdown:Hide()
                            line.PandemicColorDropdown:Hide()
                            line.ByNameCheckbox:Hide()
                            line.OnlyMineCheckbox:Hide()
                            line.MoveUpButton:Hide()
                            line.MoveDownButton:Hide()
                        else
                            line.ColorDropdown:Show()
                            line.ColorDropdown.spellId = spellId
                            line.ColorDropdown:SetFixedParameter(spellId)
                            line.ColorDropdown:Select(colorTable and colorTable[1] and colorTable[2] or platerInternal.NoColor)

                            line.PandemicColorDropdown:Show()
                            line.PandemicColorDropdown.spellId = spellId
                            line.PandemicColorDropdown:SetFixedParameter(spellId)
                            line.PandemicColorDropdown:Select(colorTable and colorTable[6] or platerInternal.NoColor)

                            --a locked checkbox ignores SetValue and hides its check mark, so it is unlocked to set the value
                            line.ByNameCheckbox:Show()
                            line.ByNameCheckbox:SetFixedParameter(spellId)
                            line.ByNameCheckbox:Enable()
                            line.ByNameCheckbox:SetValue(isSpellName or colorTable and colorTable[3] or false)

                            --an aura added by name is always tracked by name
                            if (isSpellName) then
                                line.ByNameCheckbox:Disable()
                                line.ByNameCheckbox.checked_texture:Show()
                            end

                            line.OnlyMineCheckbox:Show()
                            line.OnlyMineCheckbox:SetFixedParameter(spellId)
                            --a row without settings shows the default, which is only mine
                            line.OnlyMineCheckbox:SetValue(not colorTable or colorTable[4])

                            --only an aura with settings has a place in the priority order
                            line.MoveUpButton:SetShown(colorTable and true or false)
                            line.MoveUpButton:SetParameters(spellId)
                            line.MoveDownButton:SetShown(colorTable and true or false)
                            line.MoveDownButton:SetParameters(spellId)
                        end

                        line.RemoveColor.SpellID = spellId
                        line.RemoveColor:SetShown(colorTable and true or false)
                    end

                    --manual tracking doesn't have a black list
                    if (Plater.db.profile.aura_tracker.track_method == 0x1) then
                        --the aura colors have no aura type, they are blacklisted by spell id or name
                        if (spellData.type or IS_WOW_PROJECT_MIDNIGHT_API_WITH_AURA_CONTAINERS) then
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

    --row data of a spell which was added by hand and never captured, it has no source and no aura type
    local manualSpellTable = {source = ""}

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

        --aura colors which were added by hand and aren't in the captured list
        for spellKey in pairs(DB_AURA_COLORS) do
            if (not DB_CAPTURED_SPELLS[spellKey]) then
                tinsert(newData, {spellKey, manualSpellTable, 0})
            end
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

    --the captured spell list isn't filled while auras are secret, so there is nothing to clear or to look up
    local clearListButton
    if (not IS_WOW_PROJECT_MIDNIGHT_API_WITH_AURA_CONTAINERS) then
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
        clearListButton = detailsFramework:CreateButton(auraLastEventFrame, wipeSpellList, 160, 20, "Clear List", -1, nil, nil, nil, nil, nil, detailsFramework:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE"), detailsFramework:GetTemplate("font", "PLATER_BUTTON"))
        clearListButton:SetPoint("right", openSpellListButton, "left", -6, 0)
    end

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
    if (clearListButton) then
        auraSearchTextentry:SetPoint("right", clearListButton, "left", -6, 0)
    else
        auraSearchTextentry:SetPoint("bottomright", latestSpellsScroll, "topright", 0, 24)
    end

    auraSearchTextentry:SetHook("OnChar",		auraLastEventFrame.OnSearchBoxTextChanged)
    auraSearchTextentry:SetHook("OnTextChanged", 	auraLastEventFrame.OnSearchBoxTextChanged)
    auraSearchTextentry:SetAsSearchBox()

    local auraSearchLabel = detailsFramework:CreateLabel(auraLastEventFrame, "Search:", detailsFramework:GetTemplate("font", "ORANGE_FONT_TEMPLATE"))
    auraSearchLabel:SetPoint("right", auraSearchTextentry, "left", -2, 0)

    --adds the spell name or spell id typed into the search box as an aura color row
    if (IS_WOW_PROJECT_MIDNIGHT_API_WITH_AURA_CONTAINERS) then
        --a spell id is used as is, a spell name is the key and is resolved by the spell cache of the aura system
        local addAuraColor = function()
            local text = strtrim(auraSearchTextentry:GetText() or ""):lower()
            local spellKey = tonumber(text) or text
            local isSpellName = type(spellKey) == "string"
            local isUnknownSpellId = not isSpellName and not GetSpellInfo(spellKey)

            if (text == "" or isUnknownSpellId) then
                Plater:Msg("Type a spell name or spell ID into the search box first.")
                return
            end

            auraSearchTextentry:SetText("")
            auraSearchTextentry:ClearFocus()
            getAuraColorTable(spellKey)[3] = isSpellName

            if (isSpellName) then
                platerInternal.Auras.InitSpellCache(function()
                    --the name isn't a spell, drop the row
                    if (DB_AURA_COLORS[spellKey] and not Plater.SpellCaches.allIDsByName[spellKey]) then
                        DB_AURA_COLORS[spellKey] = nil
                        Plater:Msg("Spell not found: " .. spellKey)
                        onAuraColorChanged()
                        rebuildSpellList()
                    end
                end)
            end

            rebuildSpellList()
        end

        local addAuraButton = detailsFramework:CreateButton(auraLastEventFrame, addAuraColor, 70, 20, "Add Aura", -1, nil, nil, nil, nil, nil, options_button_template, detailsFramework:GetTemplate("font", "PLATER_BUTTON"))
        addAuraButton:SetPoint("right", auraSearchLabel, "left", -10, 0)
        addAuraButton.tooltip = "Adds the spell name or spell ID typed in the search box to the list, then pick a health bar color for it."

        --bad threat colors take priority over the aura colors, the change applies to the shown nameplates at once
        local onToggleNoOverrideThreat = function(_, _, value)
            Plater.db.profile.aura_colors_no_override_bad_threat = value
            for _, plateFrame in ipairs(Plater.GetAllShownPlates()) do
                platerInternal.Auras.UpdateAuraColorThreat(plateFrame.unitFrame)
            end
        end

        local noOverrideThreatSwitch = detailsFramework:CreateSwitch(auraLastEventFrame, onToggleNoOverrideThreat, Plater.db.profile.aura_colors_no_override_bad_threat, _, _, _, _, _, "$parentNoOverrideThreatToggle", _, _, _, nil, options_switch_template)
        noOverrideThreatSwitch:SetAsCheckBox()
        noOverrideThreatSwitch:SetSize(20, 20)
        noOverrideThreatSwitch:SetPoint("right", addAuraButton, "left", -10, 0)
        noOverrideThreatSwitch.tooltip = "Bad threat states (losing or missing aggro) will have priority over aura colors."

        --two lines, the row is shared with the description
        local noOverrideThreatLabel = detailsFramework:CreateLabel(auraLastEventFrame, "Don't override bad\nThreat colors", options_text_template)
        noOverrideThreatLabel.align = "right"
        noOverrideThreatLabel:SetPoint("right", noOverrideThreatSwitch, "left", -2, 0)
    end

    --create the description
    local descriptionText = IS_WOW_PROJECT_MIDNIGHT_API_WITH_AURA_CONTAINERS
        and "Color the health bar while a listed aura is on the unit. Type a spell name or spell ID into the search box and click Add Aura."
        or "Quick way to manage auras from a recent raid boss or dungeon run."
    auraLastEventFrame.TitleDescText = Plater:CreateLabel(auraLastEventFrame, descriptionText, 10, "silver")
    auraLastEventFrame.TitleDescText:SetPoint("bottomleft", latestSpellsScroll, "topleft", 0, 26)
end
