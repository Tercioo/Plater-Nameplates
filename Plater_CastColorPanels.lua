local Plater = Plater
local addonId, platerInternal = ...
local GameCooltip = GameCooltip2
---@type detailsframework
local DF = DetailsFramework
local GetSpellInfo = GetSpellInfo or function(spellID) if not spellID then return nil end local si = C_Spell.GetSpellInfo(spellID) if si then return si.name, nil, si.iconID, si.castTime, si.minRange, si.maxRange, si.spellID, si.originalIconID end end
local _

---@alias spellid number
---@alias soundpath string

local bitAnd = bit.band

local unpack = table.unpack or _G.unpack

--localization
local LOC = DF.Language.GetLanguageTable(addonId)

local LibSharedMedia = LibStub:GetLibrary("LibSharedMedia-3.0")

--get templates
local options_text_template = DF:GetTemplate("font", "OPTIONS_FONT_TEMPLATE")
local options_dropdown_template = DF:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE")
local options_switch_template = DF:GetTemplate("switch", "OPTIONS_CHECKBOX_TEMPLATE")
local options_slider_template = DF:GetTemplate("slider", "OPTIONS_SLIDER_TEMPLATE")
local options_button_template = DF:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE")

local dropdownStatusBarTexture = platerInternal.Defaults.dropdownStatusBarTexture
local dropdownStatusBarColor = platerInternal.Defaults.dropdownStatusBarColor

local colorNoValue = {1, 1, 1, 0.5}
local dropdownIconColor = {1, 1, 1, .6}
local scrollRefreshCallback

local DB_CAST_COLORS
---@type table<spellid, soundpath>
local DB_CAST_AUDIOCUES
local DB_NPCIDS_CACHE
local DB_CAPTURED_SPELLS
local DB_CAPTURED_CASTS

local CONST_INDEX_ENABLED = 1
local CONST_INDEX_COLOR = 2
local CONST_INDEX_NAME = 3

local CONST_CASTINFO_ENABLED = 1
local CONST_CASTINFO_COLOR = 2
local CONST_CASTINFO_SPELLID = 3
local CONST_CASTINFO_SPELLNAME = 4
local CONST_CASTINFO_SPELLICON = 5
local CONST_CASTINFO_SOURCENAME = 6
local CONST_CASTINFO_NPCID = 7
local CONST_CASTINFO_NPCLOCATION = 8
local CONST_CASTINFO_ENCOUNTERNAME = 9
local CONST_CASTINFO_CUSTOMSPELLNAME = 10

local spellIndicators = {
    ["edited_name"] = {
		texture = [[Interface\AddOns\Plater\images\spell_indicators_1]],
		coords = {0, 0.125, 0, 1},
		scale = 1,
		shown = false,
		id = "edited_name",
		width = 12,
		height = 12,
		name = "Name Changed Indicator",
		alpha = 1,
		type = "spell_indicators",
	},

    ["edited_audio"] = {
		texture = [[Interface\AddOns\Plater\images\spell_indicators_1]],
		coords = {0.125, 0.25, 0, 1},
		scale = 1,
		shown = false,
		id = "edited_audio",
		width = 12,
		height = 12,
		name = "Audio Changed Indicator",
		alpha = 1,
		type = "spell_indicators",
	},

    ["edited_color"] = {
		texture = [[Interface\AddOns\Plater\images\spell_indicators_1]],
		coords = {0.25, 0.375, 0, 1},
		scale = 1,
		shown = false,
		id = "edited_color",
		width = 12,
		height = 12,
		name = "Color Changed Indicator",
		alpha = 1,
		type = "spell_indicators",
	},

    ["edited_script"] = {
		texture = [[Interface\AddOns\Plater\images\spell_indicators_1]],
		coords = {0.375, 0.5, 0, 1},
		scale = 1,
		shown = false,
		id = "edited_script",
		width = 12,
		height = 12,
		name = "Script Changed Indicator",
		alpha = 1,
		type = "spell_indicators",
	},
}

local on_refresh_db = function()
	local profile = Plater.db.profile
	DB_CAST_AUDIOCUES = profile.cast_audiocues
	DB_CAST_COLORS = profile.cast_colors
    DB_NPCIDS_CACHE = profile.npc_cache
    DB_CAPTURED_SPELLS = PlaterDB.captured_spells
    DB_CAPTURED_CASTS = PlaterDB.captured_casts

    DB_CAPTURED_CASTS[116] = {npcID = 188027}
end
Plater.RegisterRefreshDBCallback(on_refresh_db)

function platerInternal.Data.GetSpellRenameData(spellId)
    if (spellId) then
        local spellTable = Plater.db.profile.cast_colors[spellId]
        if (spellTable) then
            --index 3 is the spell name renamed by the user
            return spellTable[3]
        end
    else
        return Plater.db.profile.cast_colors
    end
end

function platerInternal.Data.GetSpellColorData(spellId)
    if (spellId) then
        local spellTable = Plater.db.profile.cast_colors[spellId]
        if (spellTable) then
            --index 2 is the color
            return spellTable[2]
        end
    else
        return Plater.db.profile.cast_colors
    end
end

function platerInternal.Data.SetSpellRenameData(spellId, newName)
    if (spellId) then
        local spellTable = Plater.db.profile.cast_colors[spellId]
        if (spellTable) then
            spellTable[1] = true --index one is the enabled flag
            spellTable[3] = newName --index 3 is the spell name renamed by the user
        else
            Plater.db.profile.cast_colors[spellId] = {true, "white", newName}
        end
    end
end

function platerInternal.Data.SetSpellColorData(spellId, color)
    if (spellId) then
        local spellTable = Plater.db.profile.cast_colors[spellId]
        if (spellTable) then
            --index 2 is the color
            spellTable[1] = true
            spellTable[2] = color
        else
            Plater.db.profile.cast_colors[spellId] = {true, color, ""}
        end
    end
end

function Plater.GetSpellCustomColor(spellId) --exposed
    local customColorTable = Plater.db.profile.cast_colors[spellId]
    if (customColorTable) then
        return customColorTable[2] and (customColorTable[2] ~= "white") and customColorTable[2] or nil
    end
end

--priority for user cast color >> can't interrupt color >> script color
function Plater.SetCastBarColorForScript(castBar, canUseScriptColor, scriptColor, envTable) --exposed
    --user set cast bar color into the Cast Colors tab in the options panel
    local colorByUser = Plater.GetSpellCustomColor(envTable._SpellID)
    if (colorByUser) then
        castBar:SetColor(Plater:ParseColors(colorByUser))
        return
    end

    --don't change the color of non-interruptible casts
    if (not envTable._CanInterrupt) then
        castBar:SetColor(Plater:ParseColors(Plater.db.profile.cast_statusbar_color_nointerrupt))
        return
    end

    --if is interruptible and don't have a custom user color, set the script color
    if (canUseScriptColor and scriptColor) then
        if (type(scriptColor) == "table") then
            castBar:SetColor(Plater:ParseColors(scriptColor))
        end
    end
end

function Plater.CreateCastColorOptionsFrame(castColorFrame)
    local castFrame = CreateFrame("frame", castColorFrame:GetName() .. "ColorFrame", castColorFrame)
    castFrame:SetPoint("topleft", castColorFrame, "topleft", 5, -140)
    castFrame:SetSize(1060, 495)

    --options
    local scroll_width = 1050
    local scroll_height = 442
    local scroll_lines = 20
    local scroll_line_height = 20
    local backdrop_color = {.2, .2, .2, 0.2}
    local backdrop_color_on_enter = {.8, .8, .8, 0.4}
    local y = -20
    local headerY = y - 20
    local scrollY = headerY - 15

    ----platerInternal.optionsYStart or

    local luaeditor_border_color = {0, 0, 0, 1}
    local importbox_size = {620, 300}
    local buttons_size = {120, 20}

    DB_CAST_COLORS = Plater.db.profile.cast_colors
    DB_NPCIDS_CACHE = Plater.db.profile.npc_cache --[npcId] = {npc name, npc zone}
    DB_CAPTURED_CASTS = PlaterDB.captured_casts --[spellId] = {[npcID] = 000000}
    DB_CAPTURED_SPELLS = PlaterDB.captured_spells --[spellId] = {[npcID] = 000000}

    --header
    local headerTable = {
        {text = "", width = 40}, --1
        {text = "", width = 20}, --2
        {text = "Spell Id", width = 50}, --3
        {text = "Spell Name", width = 140}, --4
        {text = "Rename To", width = 110}, --5
        {text = "Npc Name", width = 110}, --6
        {text = "Send To Raid", width = 80}, --7
        {text = "Play Sound", width = 110}, --8
        {text = "Color", width = 110}, --9
        {text = "Add Animation", width = 270}, --10
    }

    local headerOptions = {
        padding = 2,
    }

    castFrame.Header = DF:CreateHeader(castFrame, headerTable, headerOptions)
    castFrame.Header:SetPoint("topleft", castFrame, "topleft", 5, headerY+5)

    --store npcID = checkbox object
    --this is used when selecting the color from the dropdown, it'll automatically enable the color and need to set the checkbox to checked for feedback
    castFrame.CheckBoxCache = {}

    --line scripts
    local line_onenter = function(self)
        if (castColorFrame.lastLineEntered) then
            castColorFrame.lastLineEntered:SetBackdropColor(unpack (castColorFrame.lastLineEntered.backdrop_color or backdrop_color))
        end

        self:SetBackdropColor (unpack (backdrop_color_on_enter or backdrop_color))
        if (self.spellId) then
            GameTooltip:SetOwner (self, "ANCHOR_TOPLEFT")
            GameTooltip:SetSpellByID (self.spellId)
            GameTooltip:AddLine (" ")
            GameTooltip:Show()

            castColorFrame.latestSpellId = self.spellId
            castColorFrame.optionsFrame.previewCastBar.UpdateAppearance()

            castColorFrame.SelectScriptForSpellId(self.spellId)
            castColorFrame.currentSpellId = self.spellId
        end
    end

    local line_onleave = function(self)
        --self:SetBackdropColor(unpack (self.backdrop_color or backdrop_color))
        GameTooltip:Hide()
        castColorFrame.lastLineEntered = self
        --castColorFrame.currentSpellId = nil
    end

    local widget_onenter = function(self)
        local line = self:GetParent()
        line:GetScript ("OnEnter")(line)
    end
    local widget_onleave = function(self)
        local line = self:GetParent()
        line:GetScript ("OnLeave")(line)
    end

    local oneditfocusgained_spellid = function(self, capsule)
        self:HighlightText (0)
    end

    local refresh_line_color = function(self, color)
        color = color or backdrop_color
        local r, g, b = DF:ParseColors(color)
        local a = 0.2
        self:SetBackdropColor (r, g, b, a)
        self.backdrop_color = self.backdrop_color or {}
        self.backdrop_color[1] = r
        self.backdrop_color[2] = g
        self.backdrop_color[3] = b
        self.backdrop_color[4] = a
        self.ColorDropdown:Select (color)
    end

    local onToggleEnabled = function(self, spellId, state)
        if (not DB_CAST_COLORS[spellId]) then
            DB_CAST_COLORS[spellId] = {false, "blue"}
        end
        DB_CAST_COLORS[spellId][CONST_INDEX_ENABLED] = state

        --clean the refresh scroll cache
        castFrame.spellsScroll.CachedTable = nil
        castFrame.spellsScroll.SearchCachedTable = nil

        if (state) then
            self:GetParent():RefreshColor(DB_CAST_COLORS[spellId][CONST_INDEX_COLOR])
            castColorFrame.latestSpellId = spellId
            castColorFrame.optionsFrame.previewCastBar.UpdateAppearance()
        else
            self:GetParent():RefreshColor()
        end

        Plater.RefreshDBLists()
        Plater.UpdateAllNameplateColors()
        Plater.ForceTickOnAllNameplates()

        castFrame.RefreshScroll(0)
    end

    --audio cues
    local line_select_audio_dropdown = function (self, spellId, audioFilePath)
        DB_CAST_AUDIOCUES[spellId] = audioFilePath
        castFrame.spellsScroll.CachedTable = nil
        castFrame.RefreshScroll(0)
    end

    local audioFileNameToCueName = {}

    local createAudioCueList = function(fullRefresh)
        if (castFrame.AudioCueListCache and not fullRefresh) then
            --return
        end

        local audioCueList = {
            {
                label = " no audio",
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

        table.sort(audioListInOrder, function(t1, t2) --alphabetical
            if (t1[4] and not t2[4]) then
                return true

            elseif (not t1[4] and t2[4]) then
                return false

            elseif (t1[4] and t2[4]) then
                return t1[3] < t2[3]
            else
                return t1[3] < t2[3]
            end
        end)

        --table.sort(audioListInOrder, function(t1, t2) return t1[3] < t2[3] end) --alphabetical
        --table.sort(audioListInOrder, function(t1, t2) return t1[4] > t2[4] end) --in use

        for i = 1, #audioListInOrder do
            local cueName, cueFile, lowerName, cueInUse = unpack(audioListInOrder[i])
            audioCueList[#audioCueList+1] = {
                label = " " .. cueName,
                value = cueFile,
                audiocue = cueFile,
                color = "white",
                statusbar = dropdownStatusBarTexture,
                statusbarcolor = cueInUse and {.3, .3, .3, .8} or dropdownStatusBarColor,
                iconcolor = dropdownIconColor,
                icon = [[Interface\AddOns\Plater\media\audio_cue_icon]],
                onclick = line_select_audio_dropdown,
            }
        end

        castFrame.AudioCueListCache = audioCueList
    end

    local line_refresh_audio_dropdown = function(self)
        createAudioCueList(true)
        return castFrame.AudioCueListCache
    end

    --cast color
    local line_select_color_dropdown = function (self, spellId, color)
        local bNeedRefresh = false

        if (color == platerInternal.RemoveColor) then
            if (DB_CAST_COLORS[spellId]) then
                DB_CAST_COLORS[spellId] = nil
                local enableColorCheckbox = castFrame.CheckBoxCache[spellId]
                if (enableColorCheckbox) then
                    enableColorCheckbox:SetValue(false)
                end
            end
        else
            if (not DB_CAST_COLORS[spellId]) then
                DB_CAST_COLORS[spellId] = {true, "blue", ""}
            end

            local bOldColorWasEnabled = self.colorTable and self.colorTable[1]
            local oldColorName = self.colorTable and self.colorTable[2]

            DB_CAST_COLORS[spellId][CONST_INDEX_ENABLED] = true
            DB_CAST_COLORS[spellId][CONST_INDEX_COLOR] = color

            --if the shift key is pressed, change the color of all castbars with this color
            if (IsShiftKeyDown() and bOldColorWasEnabled and type(oldColorName) == "string") then
                for thisSpellId, castColorTable in pairs(DB_CAST_COLORS) do
                    if (castColorTable[1] and castColorTable[2] == oldColorName) then
                        castColorTable[2] = color
                        bNeedRefresh = true
                    end
                end
            end

            local enableColorCheckbox = castFrame.CheckBoxCache[spellId]
            if (enableColorCheckbox) then
                enableColorCheckbox:SetValue(true)
            end
        end

        --clean the refresh scroll cache
        castFrame.spellsScroll.CachedTable = nil
        castFrame.spellsScroll.SearchCachedTable = nil

        self:GetParent():RefreshColor(color)

        Plater.RefreshDBLists()
        Plater.ForceTickOnAllNameplates()

        --o que é esses dois caches
        castFrame.cachedColorTable = nil
        castFrame.cachedColorTableNameplate = nil

        castFrame.RefreshScroll(0)
        castColorFrame.latestSpellId = spellId
        castColorFrame.optionsFrame.previewCastBar.UpdateAppearance()

        if (bNeedRefresh) then
            --refresh the scrollbox showing all the spell colors
            castFrame.spellsScroll:Refresh()
        end
    end

    local line_refresh_color_dropdown = function(self)
        local colorEnabledIndexOnDB = 1
        local colorIndexOnDB = 2
        return platerInternal.RefreshColorDropdown(castFrame, self, DB_CAST_COLORS, line_select_color_dropdown, "spellId", colorEnabledIndexOnDB, colorIndexOnDB)
    end

    --line
    local scroll_createline = function (self, index) --~create

        local line = CreateFrame ("button", "$parentLine" .. index, self, BackdropTemplateMixin and "BackdropTemplate")
        line:SetPoint ("topleft", self, "topleft", 1, -((index-1)*(scroll_line_height+1)) - 1)
        line:SetSize (scroll_width - 3, scroll_line_height)
        line:SetScript ("OnEnter", line_onenter)
        line:SetScript ("OnLeave", line_onleave)

        line.RefreshColor = refresh_line_color

        line:SetBackdrop({bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
        line:SetBackdropColor(unpack (backdrop_color))

        DF:Mixin (line, DF.HeaderFunctions)

        local indicatorsSettings = {
            icon_width = 16,
            icon_height = 16,
            show_text = false,
            stack_text = true,
            cooldown_swipe_enabled = false,
            surpress_blizzard_cd_timer = true,
            show_cooldown = false,
            stack_text_color = {1, 1, 0, 1},
            swipe_brightness = 0,
        }

        local spellIndicatorsFrame = DF:CreateIconRowGeneric(line, "$parentIndicators", indicatorsSettings)
        spellIndicatorsFrame:SetSize(16, 16)
        line.IconRow = spellIndicatorsFrame

        --spell icon
        local spellIconTexture = DF:CreateImage(line, "", scroll_line_height-2, scroll_line_height-2)
        spellIconTexture:SetTexCoord(.1, .9, .1, .9)
        line.spellIconTexture = spellIconTexture

        --spell Id
        local spellIdEntry = DF:CreateTextEntry(line, function()end, headerTable[3].width, 20, "spellIdEntry", nil, nil, DF:GetTemplate("dropdown", "PLATER_DROPDOWN_OPTIONS"))
        spellIdEntry:SetHook ("OnEditFocusGained", oneditfocusgained_spellid)
        spellIdEntry:SetJustifyH("left")

        --spell Name
        local spellNameEntry = DF:CreateTextEntry(line, function()end, headerTable[4].width, 20, "spellNameEntry", nil, nil, DF:GetTemplate("dropdown", "PLATER_DROPDOWN_OPTIONS"))
        spellNameEntry:SetHook("OnEditFocusGained", oneditfocusgained_spellid)
        spellNameEntry:SetJustifyH("left")

        local spellRenameEntry = DF:CreateTextEntry(line, function()end, headerTable[5].width, 20, "spellRenameEntry", nil, nil, DF:GetTemplate("dropdown", "PLATER_DROPDOWN_OPTIONS"))
        spellRenameEntry:SetHook("OnEditFocusGained", oneditfocusgained_spellid)
        spellRenameEntry:SetJustifyH("left")

        spellRenameEntry:SetHook("OnEditFocusLost", function(widget, capsule, text)
            local castColors = Plater.db.profile.cast_colors
            local spellId = capsule.spellId
            capsule.text = castColors[spellId] and castColors[spellId][CONST_INDEX_NAME] or ""
        end)

        spellRenameEntry:SetHook("OnEnterPressed", function(widget, capsule, text)
            local castColors = Plater.db.profile.cast_colors
            local spellId = capsule.spellId
            local castColor = castColors[spellId]

            if (text == "") then
                if (castColor) then
                    castColor[CONST_INDEX_NAME] = ""
                end
            else
                if (castColor) then
                    castColor[CONST_INDEX_NAME] = text
                else
                    castColors[spellId] = {true, "white", text}
                end
            end

            Plater.UpdateAllPlates()
        end)

        --npc name
        local npcNameEntry = DF:CreateTextEntry(line, function()end, headerTable[6].width, 20, "npcNameEntry", nil, nil, DF:GetTemplate("dropdown", "PLATER_DROPDOWN_OPTIONS"))
        npcNameEntry:SetHook("OnEditFocusGained", oneditfocusgained_spellid)
        npcNameEntry:SetJustifyH("left")

        --npc Id
        --local npcIdLabel = DF:CreateLabel(line, "", 10, "white", nil, "npcIdLabel")

        --send to raid button
        local sendToRaidButton = DF:CreateButton(line, function()end, headerTable[7].width - 15, 20, "Send to Raid", -1, nil, nil, nil, nil, nil, DF:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate("font", "PLATER_BUTTON"))
        line.sendToRaidButton = sendToRaidButton

        --location
        --local npcLocationLabel = DF:CreateLabel(line, "", 10, "white", nil, "npcLocationLabel")
        local selectAudioDropdown = DF:CreateDropDown(line, line_refresh_audio_dropdown, 1, headerTable[8].width - 1, 20, "SelectAudioDropdown", nil, DF:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))
        selectAudioDropdown:SetFrameLevel(line:GetFrameLevel()+2)

        --encounter
        local encounterNameLabel = DF:CreateLabel(line, "", 10, "white", nil, "encounterNameLabel") --not in use, got replaced by spell name rename

        --color enabled check box
            local enabledCheckBox = DF:CreateSwitch(line, onToggleEnabled, true, _, _, _, _, "EnabledCheckbox", "$parentEnabledToggle" .. index, _, _, _, nil, DF:GetTemplate("switch", "OPTIONS_CHECKBOX_BRIGHT_TEMPLATE"))
            enabledCheckBox:SetAsCheckBox()
        --color dropdown
            local colorDropdown = DF:CreateDropDown(line, line_refresh_color_dropdown, 1, headerTable[8].width - 1, 20, "ColorDropdown", nil, DF:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))
            colorDropdown:SetFrameLevel(line:GetFrameLevel()+2)

        enabledCheckBox:SetHook ("OnEnter", widget_onenter)
        enabledCheckBox:SetHook ("OnLeave", widget_onleave)
        spellIdEntry:SetHook ("OnEnter", widget_onenter)
        spellIdEntry:SetHook ("OnLeave", widget_onleave)
        spellNameEntry:SetHook ("OnEnter", widget_onenter)
        spellNameEntry:SetHook ("OnLeave", widget_onleave)
        spellRenameEntry:SetHook ("OnEnter", widget_onenter)
        spellRenameEntry:SetHook ("OnLeave", widget_onleave)
        colorDropdown:SetHook ("OnEnter", widget_onenter)
        colorDropdown:SetHook ("OnLeave", widget_onleave)
        selectAudioDropdown:SetHook("OnEnter", widget_onenter)
        selectAudioDropdown:SetHook("OnLeave", widget_onleave)

        line:AddFrameToHeaderAlignment (spellIndicatorsFrame)
        line:AddFrameToHeaderAlignment (spellIconTexture)
        line:AddFrameToHeaderAlignment (spellIdEntry)
        line:AddFrameToHeaderAlignment (spellNameEntry)
        line:AddFrameToHeaderAlignment (spellRenameEntry)
        line:AddFrameToHeaderAlignment (npcNameEntry)
        line:AddFrameToHeaderAlignment (sendToRaidButton)
        --line:AddFrameToHeaderAlignment (npcIdLabel)
        line:AddFrameToHeaderAlignment (selectAudioDropdown)
        --line:AddFrameToHeaderAlignment (encounterNameLabel)
        line:AddFrameToHeaderAlignment (enabledCheckBox)
        colorDropdown:SetPoint("left", enabledCheckBox, "right", 2, 0)
        --line:AddFrameToHeaderAlignment (colorDropdown)

        line:AlignWithHeader (castFrame.Header, "left")

        return line
    end

    local onChangeOption = function()
        --when a setting if changed
        Plater.RefreshDBUpvalues()
        Plater.UpdateAllPlates()
        --optionsspFrameFrame.previewCastBar.UpdateAppearance()
    end

    --> build scripts preview to add the cast to a script
    local scriptPreviewFrame = CreateFrame("frame", castFrame:GetName() .. "ScriptPreviewPanel", castFrame, "BackdropTemplate")
    local spFrame = scriptPreviewFrame
    spFrame:SetPoint("topright", castFrame, "topright", 23, -56)
    spFrame:SetPoint("bottomright", castFrame, "bottomright", -10, 35)
    spFrame:SetWidth(250)
    spFrame:SetFrameLevel(castFrame:GetFrameLevel()+10)

    DF:ApplyStandardBackdrop(spFrame)
    spFrame:SetBackdropBorderColor(0, 0, 0, 0)
    spFrame:EnableMouse(true)

    local CONST_PREVIEW_SPELLID = 116
    local allPreviewFrames = {}
    castColorFrame.allPreviewFrames = allPreviewFrames

    local hasScriptWithPreviewSpellId = function(spellId)
        local previewSpellId = spellId or CONST_PREVIEW_SPELLID
        local defaultCastScripts = platerInternal.Scripts.DefaultCastScripts
        local GetScriptObjectByName = platerInternal.Scripts.GetScriptObjectByName
        local find = DF.table.find

        for i = 1, #defaultCastScripts do
            local scriptName = defaultCastScripts[i]
            local scriptObject = GetScriptObjectByName(scriptName)
            if (scriptObject) then
                local index = find(scriptObject.SpellIds, previewSpellId)
                if (index) then
                    return true
                end
            end
        end
    end

    local castBarPreviewTexture = [[Interface\AddOns\Plater\Images\cast_bar_scripts_preview]]
    local eachCastBarButtonHeight = PlaterOptionsPanelContainerCastColorManagementColorFrameScriptPreviewPanel:GetHeight() / #platerInternal.Scripts.DefaultCastScripts

    local scriptsToShow = {}
    for i = 1, #platerInternal.Scripts.DefaultCastScripts do
        local scriptName = platerInternal.Scripts.DefaultCastScripts[i]

        local scriptObject = platerInternal.Scripts.GetScriptObjectByName(scriptName)
        if (scriptObject) then
            scriptsToShow[#scriptsToShow + 1] = scriptName
        end
    end

    for i = 1, #scriptsToShow do
        local scriptName = scriptsToShow[i]

        local scriptObject = platerInternal.Scripts.GetScriptObjectByName(scriptName)
        if (scriptObject) then

            local previewFrame = CreateFrame("button", nil, spFrame, BackdropTemplateMixin and "BackdropTemplate")
            previewFrame:SetSize(spFrame:GetWidth()-5, eachCastBarButtonHeight) --270
            previewFrame:SetPoint("topleft", spFrame, "topleft", 5, (-eachCastBarButtonHeight * (i - 1)) -5)
            DF:ApplyStandardBackdrop(previewFrame)
            previewFrame.scriptName = scriptName

            local scriptNameText = previewFrame:CreateFontString(nil, "overlay", "GameFontNormal")
            scriptNameText:SetPoint("topright", previewFrame, "topright", -2, -1)
            scriptNameText:SetJustifyH("right")
            scriptNameText:SetText(scriptName)
            scriptNameText:SetAlpha(0.5)
            DF:SetFontSize(scriptNameText, 9)
            previewFrame.scriptNameText = scriptNameText

            local widthEnd = 282/512
            local textureHeight = 46.54 --increasing reduces the preview texture height

            local scriptPreviewTexture = previewFrame:CreateTexture(nil, "overlay", nil, 3)
            scriptPreviewTexture:SetTexture(castBarPreviewTexture)
            scriptPreviewTexture:SetTexCoord(0, widthEnd, textureHeight * (i-1) / 512, textureHeight * i / 512)
            scriptPreviewTexture:SetPoint("topleft", previewFrame, "topleft", 1, -1)
            scriptPreviewTexture:SetPoint("bottomright", previewFrame, "bottomright", -1, 1)
            scriptPreviewTexture:SetAlpha(1)
            --scriptPreviewTexture:SetBlendMode("ADD")

            local scriptPreviewTexture2 = previewFrame:CreateTexture(nil, "overlay", nil, 2)
            scriptPreviewTexture2:SetTexture(castBarPreviewTexture)
            scriptPreviewTexture2:SetTexCoord(0, widthEnd, textureHeight * (i-1) / 512, textureHeight * i / 512)
            scriptPreviewTexture2:SetPoint("topleft", previewFrame, "topleft", 1, -1)
            scriptPreviewTexture2:SetPoint("bottomright", previewFrame, "bottomright", -1, 1)
            scriptPreviewTexture2:SetAlpha(0.2)
            scriptPreviewTexture2:SetBlendMode("ADD")
            previewFrame.selectedHighlight = scriptPreviewTexture2

            local selectedScript = previewFrame:CreateTexture(nil, "overlay", nil, 1)
            selectedScript:SetPoint("topleft", previewFrame, "topleft", 0, 0)
            selectedScript:SetPoint("bottomright", previewFrame, "bottomright", 0, 0)
            selectedScript:SetTexture([[Interface\AddOns\Plater\images\overlay_indicator_3]])
            selectedScript:Hide()
            previewFrame.selectedScript = selectedScript

            platerInternal.Scripts.RemoveSpellFromScriptTriggers(scriptObject, CONST_PREVIEW_SPELLID)

            previewFrame:EnableMouse(false)
            allPreviewFrames[#allPreviewFrames+1] = previewFrame

            previewFrame:SetScript("OnEnter", function(castBar)
                GameCooltip:Reset()
                GameCooltip:AddLine("Script:", previewFrame.scriptName)
                GameCooltip:AddLine("Click to use this animation when the cast start")
                GameCooltip:AddLine("Having enemy npcs near you, make their nameplates to preview this animation")

                local scriptObject = platerInternal.Scripts.GetScriptObjectByName(previewFrame.scriptName)
                if (scriptObject) then
                    GameCooltip:AddLine(" ")
                    GameCooltip:AddLine(scriptObject.Desc, "", 1, "yellow")
                end

                GameCooltip:SetOption("FixedWidth", 320)
                GameCooltip:SetOwner(previewFrame)
                GameCooltip:Show(previewFrame)
                previewFrame:SetBackdropBorderColor(1, .7, .1, 1)
                spFrame.StartCastBarPreview(previewFrame)
            end)

            previewFrame:SetScript("OnLeave", function(castBar)
                GameCooltip:Hide()
                previewFrame:SetBackdropBorderColor(0, 0, 0, 0)
                spFrame.StopCastBarPreview(previewFrame)
            end)

            previewFrame:SetScript("OnClick", function() --~onclick õnclick
                local spellId = castColorFrame.currentSpellId
                local scriptName = previewFrame.scriptName
                local scriptObject = platerInternal.Scripts.GetScriptObjectByName(scriptName)
                if (scriptObject) then
                    --already have this trigger?
                    local index = DF.table.find(scriptObject.SpellIds, spellId)
                    if (index) then
                        spFrame.RemoveTriggerFromAllScriptsBySpellID(spellId)

                    else
                        spFrame.RemoveTriggerFromAllScriptsBySpellID(spellId)
                        platerInternal.Scripts.AddSpellToScriptTriggers(scriptObject, spellId)

                    end

                    castColorFrame.SelectScriptForSpellId(spellId)
                    castFrame.RefreshScroll()
                end
            end)
        end
    end

    function castColorFrame.SelectScriptForSpellId(spellId)
        local foundScriptWithThisSpellId = false
        for i = 1, #platerInternal.Scripts.DefaultCastScripts do
            local scriptName = platerInternal.Scripts.DefaultCastScripts[i]
            local scriptObject = platerInternal.Scripts.GetScriptObjectByName(scriptName)
            if (scriptObject) then
                local hasTrigger = platerInternal.Scripts.DoesScriptHasTrigger(scriptObject, spellId)
                if (hasTrigger) then
                    for o = 1, #allPreviewFrames do
                        local previewFrame = allPreviewFrames[o]
                        if (previewFrame.scriptName == scriptName) then
                            previewFrame.selectedScript:Show()
                            previewFrame.scriptNameText:SetAlpha(0.9)
                            previewFrame.selectedHighlight:Show()
                            foundScriptWithThisSpellId = true
                        else
                            previewFrame.selectedScript:Hide()
                            previewFrame.scriptNameText:SetAlpha(0.5)
                            previewFrame.selectedHighlight:Hide()
                        end
                    end
                end
            end
        end

        --no script has been found using this spellId as trigger
        if (not foundScriptWithThisSpellId) then
            for o = 1, #allPreviewFrames do
                local previewFrame = allPreviewFrames[o]
                previewFrame.selectedScript:Hide()
                previewFrame.scriptNameText:SetAlpha(0.5)
                previewFrame.selectedHighlight:Hide()
            end
        end
    end

    function spFrame.StartCastBarPreview(previewFrame)
        if (Plater.IsTestRunning) then
            Plater.StopCastBarTest()
        end

        local scriptName = previewFrame.scriptName
        local scriptObject = platerInternal.Scripts.GetScriptObjectByName(scriptName)

        if (scriptObject) then
            spFrame.RemovePreviewTriggerFromAllScripts()

            platerInternal.Scripts.AddSpellToScriptTriggers(scriptObject, CONST_PREVIEW_SPELLID)

            Plater.StartCastBarTest(true, 2)
        end
    end

    --on leave castBar area
    function spFrame.StopCastBarPreview(previewFrame)
        Plater.StopCastBarTest()

        local scriptName = previewFrame.scriptName
        local scriptObject = platerInternal.Scripts.GetScriptObjectByName(scriptName)
        if (not scriptObject) then
            Plater:Msg("[StopCastBarPreview] script not found:", scriptName)
            return
        end

        spFrame.RemovePreviewTriggerFromAllScripts()
    end

    function spFrame.RemoveTriggerFromAllScriptsBySpellID(spellId)
        spellId = spellId or CONST_PREVIEW_SPELLID
        local noRecompile = true
        local scriptData = Plater.db.profile.script_data
        local spellRemoved = false
        for i, scriptObject in pairs(scriptData) do
            platerInternal.Scripts.RemoveSpellFromScriptTriggers(scriptObject, spellId, noRecompile)
            spellRemoved = true
        end

        if (spellRemoved) then
            Plater.WipeAndRecompileAllScripts("script")
        end
    end

    function spFrame.RemovePreviewTriggerFromAllScripts()
        for i = 1, #platerInternal.Scripts.DefaultCastScripts do
            local scriptName = platerInternal.Scripts.DefaultCastScripts[i]
            local scriptObject = platerInternal.Scripts.GetScriptObjectByName(scriptName)
            if (scriptObject) then
                platerInternal.Scripts.RemoveSpellFromScriptTriggers(scriptObject, CONST_PREVIEW_SPELLID)
            end
        end
    end

    spFrame:HookScript("OnShow", function()
        if (not spFrame.LoopPreviewTimer) then
            --spFrame.LoopPreviewTimer = DF.Schedules.NewTicker(2, startCasting)
        end
    end)

    spFrame.OnHide = function()
        if (Plater.IsTestRunning) then
            C_Timer.After(0.05, spFrame.OnHide)
        else
            spFrame.RemovePreviewTriggerFromAllScripts()
        end
    end

    spFrame:HookScript("OnHide", function()
        spFrame.OnHide()
    end)

------------------------------------------------------------------------------------------------------------
        --> build the ~options panel
        local optionsFrame = CreateFrame("frame", castFrame:GetName() .. "OptionsPanel", castFrame, "BackdropTemplate")
        optionsFrame:SetPoint("topright", castFrame, "topright", 28, -56)
        optionsFrame:SetPoint("bottomright", castFrame, "bottomright", 0, 18)
        optionsFrame:SetWidth(250)
        optionsFrame:SetFrameLevel(castFrame:GetFrameLevel()+20)
        optionsFrame:Hide() --hidden by default

        DF:ApplyStandardBackdrop(optionsFrame)
        --optionsFrame:SetBackdropBorderColor(0, 0, 0, 0)
        optionsFrame:EnableMouse(true)

        local onChangeOption = function()
            --when a setting if changed
            Plater.RefreshDBUpvalues()
            Plater.UpdateAllPlates()
            optionsFrame.previewCastBar.UpdateAppearance()
        end

        local layerNames = {
            "Background",
            "Artwork",
            "Overlay",
        }

        local buildLayerMenu = function()
            local t = {}
            for i = 1, #layerNames do
                tinsert (t, {
                    label = layerNames[i],
                    value = layerNames[i],
                    onclick = function (_, _, value)
                        Plater.db.profile.cast_color_settings.layer = value
                        onChangeOption()
                    end
                })
            end
            return t
        end

        --anchor table
        local anchorNames = Plater.AnchorNames

        local build_anchor_side_table = function()
            local t = {}
            for i = 1, 13 do
                tinsert (t, {
                    label = anchorNames[i],
                    value = i,
                    onclick = function (_, _, value)
                        Plater.db.profile.cast_color_settings.anchor.side = value
                        onChangeOption()
                    end
                })
            end
            return t
        end

        local optionsTable = {
            {
                type = "toggle",
                get = function() return Plater.db.profile.cast_color_settings.enabled end,
                set = function (self, fixedparam, value)
                    Plater.db.profile.cast_color_settings.enabled = value
                end,
                name = "Enable Original Cast Color",
                desc = "Show a small indicator showing the original color of the cast.",
            },
            {
                type = "range",
                get = function() return Plater.db.profile.cast_color_settings.alpha end,
                set = function (self, fixedparam, value)
                    Plater.db.profile.cast_color_settings.alpha = value
                end,
                min = 0,
                max = 1,
                step = 0.1,
                usedecimals = true,
                name = "Alpha",
            },
            {
                type = "range",
                get = function() return Plater.db.profile.cast_color_settings.width end,
                set = function (self, fixedparam, value)
                    Plater.db.profile.cast_color_settings.width = value
                end,
                min = 1,
                max = 200,
                step = 1,
                name = "Width",
            },
            {
                type = "range",
                get = function() return Plater.db.profile.cast_color_settings.height_offset end,
                set = function (self, fixedparam, value)
                    Plater.db.profile.cast_color_settings.height_offset = value
                end,
                min = -30,
                max = 30,
                step = 1,
                name = "Height Offset",
            },
            {
                type = "select",
                get = function() return Plater.db.profile.cast_color_settings.layer end,
                values = function() return buildLayerMenu() end,
                name = "Layer",
            },
            {
                type = "select",
                get = function() return Plater.db.profile.cast_color_settings.anchor.side end,
                values = function() return build_anchor_side_table() end,
                name = LOC["OPTIONS_ANCHOR"],
            },
            {
                type = "range",
                get = function() return Plater.db.profile.cast_color_settings.anchor.x end,
                set = function (self, fixedparam, value)
                    Plater.db.profile.cast_color_settings.anchor.x = value
                end,
                min = -200,
                max = 200,
                step = 1,
                usedecimals = true,
                name = LOC["OPTIONS_XOFFSET"],
            },
            {
                type = "range",
                get = function() return Plater.db.profile.cast_color_settings.anchor.y end,
                set = function (self, fixedparam, value)
                    Plater.db.profile.cast_color_settings.anchor.y = value
                end,
                min = -200,
                max = 200,
                step = 1,
                usedecimals = true,
                name = LOC["OPTIONS_YOFFSET"],
            },

        }

        local startX, startY, heightSize = 2, -10, optionsFrame:GetHeight()
        _G.C_Timer.After(0.5, function() --~delay
            DF:BuildMenu(optionsFrame, optionsTable, startX, startY, heightSize, true, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template, onChangeOption)
        end)

    -->  ~preview window (not in use as the script choise frame is over this one)
        local previewWindow = CreateFrame("frame", optionsFrame:GetName() .. "previewWindown", optionsFrame, "BackdropTemplate")
        previewWindow:SetSize(250, 40)
        previewWindow:SetPoint("topleft", optionsFrame, "topleft", 0, -240)
        --previewWindow:SetBackdrop({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
        --previewWindow:SetBackdropBorderColor(0, 0, 0, .6)
        --previewWindow:SetBackdropColor(0.1, 0.1, 0.1, 0.4)

        local previewLabel = Plater:CreateLabel(previewWindow, "Quick Preview", 10)
        previewLabel:SetPoint("bottomleft", previewWindow, "topleft", 0, 14)
        local castLabel = Plater:CreateLabel(previewWindow, "Cast a spell, refresh, than add a color for it", 10)
        castLabel:SetPoint("topleft", previewLabel, "bottomleft", 0, -2)

        previewLabel.textcolor = "gray"
        castLabel.textcolor = "gray"

        local settingsOverride = {
            FadeInTime = 0.02,
            FadeOutTime = 0.66,
            SparkHeight = 20,
            LazyUpdateCooldown = 0.1,
        }

        local previewCastBar = DF:CreateCastBar(previewWindow, previewWindow:GetName() .. "CastBar", settingsOverride)
        optionsFrame.previewCastBar = previewCastBar
        castColorFrame.optionsFrame = optionsFrame

        previewCastBar:SetSize(230, 20)
        previewCastBar:SetPoint("center", previewWindow, "center", 0, 0)
        previewCastBar:SetUnit("player")
        previewCastBar:Show()

        previewCastBar.percentText:SetText("1.5")
        previewCastBar:SetMinMaxValues(0, 1)
        previewCastBar.value = 0.6
        previewCastBar.maxValue = 1
        previewCastBar:OnTick_Casting(0.016)
        previewCastBar.Spark:Show()

        local spellName, _, spellIcon = GetSpellInfo(CONST_PREVIEW_SPELLID)
        previewCastBar.Text:SetText(spellName)
        previewCastBar.Icon:SetTexture(spellIcon)
        previewCastBar.Icon:SetAlpha(1)
        previewCastBar.Icon:Show()
        previewCastBar.Icon:SetSize(previewCastBar:GetHeight()-2, previewCastBar:GetHeight()-2)
        previewCastBar.Icon:SetTexCoord(.1, .9, .1, .9)

        previewCastBar.Spark:SetTexture(Plater.db.profile.cast_statusbar_spark_texture)
        previewCastBar.Spark:SetVertexColor(unpack (Plater.db.profile.cast_statusbar_spark_color))
        previewCastBar.Spark:SetAlpha(Plater.db.profile.cast_statusbar_spark_alpha)
        previewCastBar:SetColor(Plater.db.profile.cast_statusbar_color)
        previewCastBar:SetStatusBarTexture(LibSharedMedia:Fetch("statusbar", Plater.db.profile.cast_statusbar_texture))

        previewCastBar.castColorTexture = previewCastBar:CreateTexture("$parentCastColor", "background", nil, -6)

        local hookEventCast = function(self, event, unit, ...)
            local isEnabled = DB_CAST_COLORS[self.spellID] and DB_CAST_COLORS[self.spellID][CONST_INDEX_ENABLED]
            if (isEnabled) then
                previewCastBar.castColorTexture:SetColorTexture(unpack(Plater.db.profile.cast_statusbar_color))
            end
        end
        hooksecurefunc(previewCastBar, "UNIT_SPELLCAST_START", hookEventCast)
        hooksecurefunc(previewCastBar, "UNIT_SPELLCAST_CHANNEL_START", hookEventCast)

        function previewCastBar.UpdateAppearance()
            local profile = Plater.db.profile

            --original cast color
            local isEnabled = profile.cast_color_settings.enabled
            if (isEnabled) then
                previewCastBar.castColorTexture:SetColorTexture(unpack(Plater.db.profile.cast_statusbar_color))
                previewCastBar.castColorTexture:SetHeight(previewCastBar:GetHeight() + profile.cast_color_settings.height_offset)
                previewCastBar.castColorTexture:SetWidth(profile.cast_color_settings.width)
                previewCastBar.castColorTexture:SetAlpha(profile.cast_color_settings.alpha)
                previewCastBar.castColorTexture:SetDrawLayer(profile.cast_color_settings.layer, -6)
                Plater.SetAnchor(previewCastBar.castColorTexture, profile.cast_color_settings.anchor)
                previewCastBar.castColorTexture:Show()
            else
                previewCastBar.castColorTexture:Hide()
            end

            --cast color
            local latestSpellId = castColorFrame.latestSpellId
            if (latestSpellId) then
                local castColor = DB_CAST_COLORS[latestSpellId]
                if (castColor) then
                    local color = castColor[CONST_INDEX_COLOR]
                    if (color and color ~= "white") then
                        previewCastBar:SetColor(color)
                    else
                        previewCastBar:SetColor(Plater.db.profile.cast_statusbar_color)
                        previewCastBar.castColorTexture:Hide()
                    end
                else
                    previewCastBar:SetColor(Plater.db.profile.cast_statusbar_color)
                    previewCastBar.castColorTexture:Hide()
                end
            else
                previewCastBar:SetColor(Plater.db.profile.cast_statusbar_color)
                previewCastBar.castColorTexture:Hide()
            end
        end

        previewCastBar.UpdateAppearance()

    --end preview

    local sort_enabled_colors = function (t1, t2)
        if (t1[2] < t2[2]) then --color
            return true
        elseif (t1[2] > t2[2]) then --color
            return false
        else
            return t1[4] < t2[4] --alphabetical
        end
    end

    local sortByEnabledColor = function (t1, t2)
        if (t1[1] and not t2[1]) then --color
            return true
        elseif (not t1[1] and t2[1]) then --color
            return false
        else
            return t1[4] < t2[4] --alphabetical
        end
    end

    local sort_enabled_animation = function (t1, t2)
        if (t1[11] and not t2[11]) then
            return true
        elseif (not t1[11] and t2[11]) then
            return false
        else
            return t1[4] < t2[4] --alphabetical
        end
    end

    local sort_has_audio_cue = function(t1, t2)
        if (t1[12] and not t2[12]) then
            return true
        elseif (not t1[12] and t2[12]) then
            return false
        else
            return t1[4] < t2[4] --alphabetical
        end
    end

    local sortOrder4R = function(t1, t2)
        return t1[4] < t2[4]
    end

    local getPriority = function()

    end

    --callback from have clicked in the 'Share With Raid' button
    local latestMenuClicked = false
    local onSendToRaidButtonClicked = function(self, button, spellId)
        if (spellId == latestMenuClicked and GameCooltip:IsShown()) then
            GameCooltip:Hide()
            latestMenuClicked = false
            return
        end

        latestMenuClicked = spellId

        GameCooltip:Preset(2)
        GameCooltip:SetOwner(self)
        GameCooltip:SetType("menu")
        GameCooltip:SetFixedParameter(spellId)

        local bAutoAccept = false

        GameCooltip:AddMenu(1, platerInternal.Comms.SendCastInfoToGroup, bAutoAccept, "castcolor", "", "Send Color", nil, true)
        GameCooltip:AddIcon([[Interface\BUTTONS\JumpUpArrow]], 1, 1, 14, 14)

        GameCooltip:AddMenu(1, platerInternal.Comms.SendCastInfoToGroup, bAutoAccept, "castrename", "", "Send Rename", nil, true)
        GameCooltip:AddIcon([[Interface\BUTTONS\JumpUpArrow]], 1, 1, 14, 14)

        GameCooltip:AddMenu(1, platerInternal.Comms.SendCastInfoToGroup, bAutoAccept, "castscript", "", "Send Script", nil, true)
        GameCooltip:AddIcon([[Interface\BUTTONS\JumpUpArrow]], 1, 1, 14, 14)

        GameCooltip:AddMenu(1, platerInternal.Comms.SendCastInfoToGroup, bAutoAccept, "resetcast", "", "Send Reset", nil, true)
        GameCooltip:AddIcon([[Interface\BUTTONS\UI-MicroStream-Red]], 1, 1, 14, 14)

        GameCooltip:AddLine("$div")
        bAutoAccept = true

        GameCooltip:AddMenu(1, platerInternal.Comms.SendCastInfoToGroup, bAutoAccept, "castcolor", "", "Send Color (auto accept)", nil, true)
        GameCooltip:AddIcon([[Interface\BUTTONS\JumpUpArrow]], 1, 1, 14, 14)

        GameCooltip:AddMenu(1, platerInternal.Comms.SendCastInfoToGroup, bAutoAccept, "castrename", "", "Send Rename (auto accept)", nil, true)
        GameCooltip:AddIcon([[Interface\BUTTONS\JumpUpArrow]], 1, 1, 14, 14)

        GameCooltip:AddMenu(1, platerInternal.Comms.SendCastInfoToGroup, bAutoAccept, "castscript", "", "Send Script (auto accept)", nil, true)
        GameCooltip:AddIcon([[Interface\BUTTONS\JumpUpArrow]], 1, 1, 14, 14)

        GameCooltip:AddMenu(1, platerInternal.Comms.SendCastInfoToGroup, bAutoAccept, "resetcast", "", "Send Reset (auto accept)", nil, true)
        GameCooltip:AddIcon([[Interface\BUTTONS\UI-MicroStream-Red]], 1, 1, 14, 14)

        --GameCooltip:AddLine("$div")

        GameCooltip:Show()
    end

    local audioUpdateScheduled = {}
    --local lastScrollRefreshTime = GetTime()
    --local scrollRefreshSchedule

    local updateAudioSelector = function(line, selectedAudioCue)
        if (selectedAudioCue)then
            --this spell has an audio cue
            line.SelectAudioDropdown:Select(selectedAudioCue)
        else
            line.SelectAudioDropdown:Select(1, true)
        end
    end

    --refresh scroll
    local IsSearchingFor
    scrollRefreshCallback = function (self, data, offset, totalLines)
        local dataInOrder = {}

        if (IsSearchingFor and IsSearchingFor ~= "") then
            if (self.SearchCachedTable and IsSearchingFor == self.SearchCachedTable.SearchTerm) then
                dataInOrder = self.SearchCachedTable
            else
                local enabledTable = {}

                for i = 1, #data do
                    local thisData = data[i]

                    local isEnabled = thisData[CONST_CASTINFO_ENABLED]
                    local color = thisData[CONST_CASTINFO_COLOR]
                    local spellId = thisData[CONST_CASTINFO_SPELLID]
                    local spellName = thisData[CONST_CASTINFO_SPELLNAME]
                    local spellIcon = thisData[CONST_CASTINFO_SPELLICON]
                    local sourceName = thisData[CONST_CASTINFO_SOURCENAME]
                    local npcId = thisData[CONST_CASTINFO_NPCID]
                    local npcLocation = thisData[CONST_CASTINFO_NPCLOCATION]
                    local encounterName = thisData[CONST_CASTINFO_ENCOUNTERNAME]
                    local customSpellName = thisData[CONST_CASTINFO_CUSTOMSPELLNAME]

                    local isTriggerOfAnyPreviewScript = hasScriptWithPreviewSpellId(spellId)

                    local priority = 0 + (isEnabled and 0x8 or 0) + (isTriggerOfAnyPreviewScript and 0x2 or 0) + (DB_CAST_AUDIOCUES[spellId] and 0x4 or 0) + (customSpellName and customSpellName ~= "" and 0x1 or 0)

                    local bFoundBySpellName = spellName:lower():find(IsSearchingFor)
                    local bFoundBySourceName = sourceName:lower():find(IsSearchingFor)
                    local bFoundByNpcLocation = npcLocation:lower():find(IsSearchingFor)
                    local bFoundByEncounterName = encounterName:lower():find(IsSearchingFor)
                    local bFoundBySpellId = tostring(spellId):find(IsSearchingFor)

                    local bFoundByAudioName
                    if (DB_CAST_AUDIOCUES[spellId]) then --path
                        local audioFileName = DB_CAST_AUDIOCUES[spellId]
                        bFoundByAudioName = tostring(audioFileName):lower():find(IsSearchingFor)

                        if (not bFoundByAudioName) then
                            local audioNameString = tostring(audioFileNameToCueName[audioFileName])
                            bFoundByAudioName = audioNameString:lower():find(IsSearchingFor)
                        end
                    end

                    local bFoundByCustomSpellName
                    if (customSpellName and customSpellName ~= "") then
                        bFoundByCustomSpellName = customSpellName:lower():find(IsSearchingFor)
                    end

                    if (bFoundBySpellName or bFoundBySourceName or bFoundByNpcLocation or bFoundByEncounterName or bFoundBySpellId or bFoundByCustomSpellName or bFoundByAudioName) then
                        dataInOrder[#dataInOrder+1] = {
                            isEnabled, --1
                            color, --2
                            spellId, --3
                            spellName, --4
                            spellIcon, --5
                            sourceName, --6
                            npcId, --7
                            npcLocation, --8
                            encounterName, --9
                            customSpellName, --10
                            isTriggerOfAnyPreviewScript or false, --11
                            DB_CAST_AUDIOCUES[spellId] or false, --12
                            priority --13
                        }
                    end
                end

                table.sort(dataInOrder, function(t1, t2) return t1[13] > t2[13] end)
                self.SearchCachedTable = dataInOrder
                self.SearchCachedTable.SearchTerm = IsSearchingFor
            end
        else
            if (not self.CachedTable) then
                local allSpells_WithPriority = {}

                for i = 1, #data do
                    local thisData = data[i]

                    local isEnabled = thisData[CONST_CASTINFO_ENABLED]
                    local color = thisData[CONST_CASTINFO_COLOR]
                    local spellId = thisData[CONST_CASTINFO_SPELLID]
                    local spellName = thisData[CONST_CASTINFO_SPELLNAME]
                    local spellIcon = thisData[CONST_CASTINFO_SPELLICON]
                    local sourceName = thisData[CONST_CASTINFO_SOURCENAME]
                    local npcId = thisData[CONST_CASTINFO_NPCID]
                    local npcLocation = thisData[CONST_CASTINFO_NPCLOCATION]
                    local encounterName = thisData[CONST_CASTINFO_ENCOUNTERNAME]
                    local customSpellName = thisData[CONST_CASTINFO_CUSTOMSPELLNAME]

                    local isTriggerOfAnyPreviewScript = hasScriptWithPreviewSpellId(spellId) --123ms
                    local priority = 0 + (isEnabled and 0x8 or 0) + (isTriggerOfAnyPreviewScript and 0x2 or 0) + (DB_CAST_AUDIOCUES[spellId] and 0x4 or 0) + (customSpellName and customSpellName ~= "" and 0x1 or 0)

                    allSpells_WithPriority[#allSpells_WithPriority+1] = {
                        isEnabled, --1
                        color, --2
                        spellId, --3
                        spellName, --4
                        spellIcon, --5
                        sourceName, --6
                        npcId, --7
                        npcLocation, --8
                        encounterName, --9
                        customSpellName, --10
                        isTriggerOfAnyPreviewScript or false, --11
                        DB_CAST_AUDIOCUES[spellId], --12
                        priority, --13
                    }
                end

                self.CachedTable = allSpells_WithPriority
                table.sort(allSpells_WithPriority, function(t1, t2) return t1[13] > t2[13] end) --21ms
            end

            dataInOrder = self.CachedTable
        end

        --hide the empty text if there's enough results
        if (#dataInOrder > 6) then
            castFrame.EmptyText:Hide()
        end

        data = dataInOrder

        for i = 1, totalLines do
            local index = i + offset
            local spellInfo = data[index]
            if (spellInfo) then
                local line = self:GetLine(i)

                local isEnabled = spellInfo[CONST_CASTINFO_ENABLED]
                local color = spellInfo[CONST_CASTINFO_COLOR]
                local spellId = spellInfo[CONST_CASTINFO_SPELLID]
                local spellName = spellInfo[CONST_CASTINFO_SPELLNAME]
                local spellIcon = spellInfo[CONST_CASTINFO_SPELLICON]
                local sourceName = spellInfo[CONST_CASTINFO_SOURCENAME]
                local npcId = spellInfo[CONST_CASTINFO_NPCID]
                local npcLocation = spellInfo[CONST_CASTINFO_NPCLOCATION]
                local encounterName = spellInfo[CONST_CASTINFO_ENCOUNTERNAME]
                local customSpellName = spellInfo[CONST_CASTINFO_CUSTOMSPELLNAME]

                line.value = spellInfo
                line.spellId = nil

                if (spellName) then --~refresh
                    local colorOption = color
                    line.spellId = spellId

                    line.ColorDropdown.spellId = spellId
                    line.ColorDropdown:SetFixedParameter(spellId)

                    line.SelectAudioDropdown.spellId = spellId
                    line.SelectAudioDropdown:SetFixedParameter(spellId)
                    local selectedAudioCue = DB_CAST_AUDIOCUES[spellId]

                    if (audioUpdateScheduled[line] and not audioUpdateScheduled[line]:IsCancelled()) then
                        audioUpdateScheduled[line]:Cancel()
                    end
                    audioUpdateScheduled[line] = DF.Schedules.NewTimer(0.085, updateAudioSelector, line, selectedAudioCue)

                    line.sendToRaidButton.spellId = spellId
                    line.sendToRaidButton:SetClickFunction(onSendToRaidButtonClicked, spellId)
                    line.spellRenameEntry.spellId = spellId

                    line.spellIconTexture:SetTexture(spellIcon)
                    line.spellIdEntry:SetText(spellId)
                    line.spellNameEntry:SetText(spellName)
                    line.spellRenameEntry:SetText(customSpellName)
                    line.npcNameEntry:SetText(sourceName)
                    --line.npcIdLabel:SetText(npcId)
                    --line.npcLocationLabel:SetText(npcLocation)
                    line.encounterNameLabel:SetText(encounterName)

                    castFrame.CheckBoxCache[spellId] = line.EnabledCheckbox

                    if (colorOption) then
                        --causing lag in the scroll - might be an issue with dropdown:Select
                        --Select: is calling a dispatch making it to rebuild the entire color table, may be caching the color table might save performance
                        line.EnabledCheckbox:SetValue(isEnabled)
                        line.ColorDropdown:Select(color)
                        line.ColorDropdown.colorTable = {isEnabled, color}

                        if (isEnabled) then
                            line:RefreshColor(color)
                        else
                            line:RefreshColor()
                        end
                    else
                        line.EnabledCheckbox:SetValue(false)
                        line.ColorDropdown.colorTable = nil
                        line.ColorDropdown:Select(platerInternal.NoColor)
                        line:RefreshColor()
                    end

                    local priority = spellInfo[13]
                    line.IconRow:ClearIcons()

                    if (priority > 0) then
                        if (bitAnd(priority, 0x8) ~= 0) then
                            line.IconRow:AddSpecificIconWithTemplate(spellIndicators.edited_color)
                        end
                        if (bitAnd(priority, 0x4) ~= 0) then
                            line.IconRow:AddSpecificIconWithTemplate(spellIndicators.edited_audio)
                        end
                        if (bitAnd(priority, 0x2) ~= 0) then
                            line.IconRow:AddSpecificIconWithTemplate(spellIndicators.edited_script)
                        end
                        if (bitAnd(priority, 0x1) ~= 0) then
                            line.IconRow:AddSpecificIconWithTemplate(spellIndicators.edited_name)
                        end
                    end

                    line.IconRow:Show()
                    line.IconRow:AlignAuraIcons()

                    line.EnabledCheckbox:SetFixedParameter(spellId)
                else
                    line:Hide()
                end
            end
        end
    end

    --create scroll
    local spells_scroll = DF:CreateScrollBox (castFrame, "$parentColorsScroll", scrollRefreshCallback, {}, scroll_width, scroll_height, scroll_lines, scroll_line_height)
    DF:ReskinSlider(spells_scroll)
    spells_scroll:SetPoint ("topleft", castFrame, "topleft", 5, scrollY)
    castFrame.spellsScroll = spells_scroll

    spells_scroll.ScrollBar:SetPoint("TOPLEFT", spells_scroll, "TOPRIGHT", -236, -18)
    spells_scroll.ScrollBar:SetPoint("BOTTOMLEFT", spells_scroll, "BOTTOMRIGHT", -236, 36)
    spells_scroll.ScrollBar:SetFrameLevel(spells_scroll:GetFrameLevel()+10)
    spells_scroll.ScrollBar.ThumbTexture:SetSize(14, 16)

    spells_scroll:SetScript("OnShow", function(self)
        if (self.LastRefresh and self.LastRefresh+0.5 > GetTime()) then
            return
        end
        self.LastRefresh = GetTime()

        local newData = {}
        local addedSpells = {}
        --[=[
        --captured_spells
        [205762] = {
            ["source"] = "Wastewander Tracker",
            ["event"] = "SPELL_CAST_SUCCESS",
            ["npcID"] = 154461,
        },

        --npc_cache
            [135475] = {
                "Kula the Butcher", -- [1] Npc Name
                "Kings' Rest", -- [2] Location
            },
        --]=]

        for spellId, spellTable in pairs(DB_CAPTURED_CASTS) do
            local spellName, _, spellIcon = GetSpellInfo(spellId)
            if (spellName) then
                --build the castInfo table for this spell
                local npcId = spellTable.npcID
                local isEnabled = DB_CAST_COLORS[spellId] and DB_CAST_COLORS[spellId][CONST_INDEX_ENABLED] or false
                local color = DB_CAST_COLORS[spellId] and DB_CAST_COLORS[spellId][CONST_INDEX_COLOR] or platerInternal.NoColor
                local customSpellName = DB_CAST_COLORS[spellId] and DB_CAST_COLORS[spellId][CONST_INDEX_NAME] or ""

                local castInfo = {
                    isEnabled,
                    color,
                    spellId,
                    spellName,
                    spellIcon,
                    DB_NPCIDS_CACHE[npcId] and DB_NPCIDS_CACHE[npcId][1] or "", --npc name
                    npcId,
                    DB_NPCIDS_CACHE[npcId] and DB_NPCIDS_CACHE[npcId][2] or "", --npc location
                    spellTable.encounterName or "",
                    customSpellName,
                }

                tinsert(newData, castInfo)
                addedSpells[spellId] = true
            end
        end

        -- add SPELLS as well, if not yet added.
        for spellId, spellTable in pairs(DB_CAPTURED_SPELLS) do
            local spellName, _, spellIcon, castTime = GetSpellInfo(spellId)
            if (spellName and not addedSpells[spellId] and (castTime > 0 or spellTable.isChanneled) and spellTable.event == "SPELL_CAST_SUCCESS") then -- and spellTable.event ~= "SPELL_AURA_APPLIED" ?
                --build the castInfo table for this spell
                local npcId = spellTable.npcID
                local isEnabled = DB_CAST_COLORS[spellId] and DB_CAST_COLORS[spellId][CONST_INDEX_ENABLED] or false
                local color = DB_CAST_COLORS[spellId] and DB_CAST_COLORS[spellId][CONST_INDEX_COLOR] or "white"
                local customSpellName = DB_CAST_COLORS[spellId] and DB_CAST_COLORS[spellId][CONST_INDEX_NAME] or ""

                local castInfo = {
                    isEnabled,
                    color,
                    spellId,
                    spellName,
                    spellIcon,
                    DB_NPCIDS_CACHE[npcId] and DB_NPCIDS_CACHE[npcId][1] or "", --npc name
                    npcId,
                    DB_NPCIDS_CACHE[npcId] and DB_NPCIDS_CACHE[npcId][2] or "", --npc location
                    spellTable.encounterName or "",
                    customSpellName,
                }

                tinsert(newData, castInfo)
            end
        end

        self.CachedTable = nil
        self.SearchCachedTable = nil

        self:SetData(newData)
        self:Refresh()
    end)

    --create lines
    for i = 1, scroll_lines do
        spells_scroll:CreateLine(scroll_createline)
    end

    --create search box
    local latestSearchUpdate = 0
        function castFrame.OnSearchBoxTextChanged()
            local text = castFrame.AuraSearchTextEntry:GetText()
            if (text and string.len (text) > 0) then
                IsSearchingFor = text:lower()
            else
                IsSearchingFor = nil
            end

            if (latestSearchUpdate + 0.01 > GetTime()) then
                DF.Schedules.AfterById(0.05, castFrame.OnSearchBoxTextChanged, "castFrame.OnSearchBoxTextChanged")
                return
            end

            latestSearchUpdate = GetTime()
            spells_scroll.offset = 0
            spells_scroll:OnVerticalScroll(spells_scroll.offset)
            spells_scroll:Refresh()
        end

        local auraSearchTextEntry = DF:CreateTextEntry(castFrame, function()end, 150, 20, "AuraSearchTextEntry", _, _, options_dropdown_template)
        auraSearchTextEntry:SetPoint("bottomright", castFrame, "topright", 14, -28)
        auraSearchTextEntry:SetHook("OnChar", castFrame.OnSearchBoxTextChanged)
        auraSearchTextEntry:SetHook("OnTextChanged", castFrame.OnSearchBoxTextChanged)
        auraSearchTextEntry:SetAsSearchBox()
        auraSearchTextEntry.tooltip = "- Spell Name\n- Npc Name\n- Zone Name\n- Encounter Name\n- SpellID\n- Custom Spell Name\n- Sound Name\n- Audio"
        auraSearchTextEntry:SetFrameLevel(castFrame.Header:GetFrameLevel() + 20)
        auraSearchTextEntry:SetBackdropColor(0.1, 0.1, 0.1, 0.9)

        function castFrame.RefreshScroll(refreshSpeed)
            if (refreshSpeed and refreshSpeed == 0) then
                spells_scroll:Hide()
                spells_scroll:Show()
            else
                spells_scroll:Hide()
                C_Timer.After(refreshSpeed or .01, function() spells_scroll:Show() end)
            end
        end

    --refresh button
        local refreshButton = DF:CreateButton(castFrame, function() castFrame.RefreshScroll() end, 70, 20, _G["REFRESH"] or "Refresh", -1, nil, nil, nil, nil, nil, DF:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate("font", "PLATER_BUTTON"))
        refreshButton:SetPoint("bottomleft", spells_scroll, "bottomleft", 1, 0)
        refreshButton:SetFrameLevel(castFrame.Header:GetFrameLevel() + 20)

        local createImportBox = function(parent, mainFrame)
            --create the text editor
            local importTextEditor = DF:NewSpecialLuaEditorEntry(parent, importbox_size[1], importbox_size[2], "ImportEditor", "$parentImportEditor", true)
            importTextEditor:SetBackdrop({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
            importTextEditor:SetBackdropBorderColor(unpack (luaeditor_border_color))
            importTextEditor:SetBackdropColor(.3, .3, .3, 1)
            importTextEditor:Hide()
            importTextEditor:SetFrameLevel(parent:GetFrameLevel()+100)
            DF:ReskinSlider(importTextEditor.scroll)

            --background to for the Cancel and Okay buttons
            local footerFrame = CreateFrame("frame", "$parentFooter", importTextEditor)
            footerFrame:SetPoint("topleft", importTextEditor, "bottomleft", 0, 0)
            footerFrame:SetPoint("topright", importTextEditor, "bottomright", 0, 0)
            footerFrame:SetHeight(20)
            footerFrame:SetFrameLevel(importTextEditor:GetFrameLevel()+1)
            footerFrame.Texture = footerFrame:CreateTexture(nil, "overlay")
            footerFrame.Texture:SetAllPoints()
            footerFrame.Texture:SetColorTexture(.03, .03, .03, 1)

            --background color
            local bg = importTextEditor:CreateTexture(nil, "background")
            bg:SetColorTexture(0.1, 0.1, 0.1, .9)
            bg:SetAllPoints()

            local blockMouseFrame = CreateFrame("frame", nil, importTextEditor, BackdropTemplateMixin and "BackdropTemplate")
            blockMouseFrame:SetFrameLevel(blockMouseFrame:GetFrameLevel()-5)
            blockMouseFrame:SetAllPoints()
            blockMouseFrame:SetScript("OnMouseDown", function()
                importTextEditor:SetFocus(true)
            end)

            mainFrame.ImportTextEditor = importTextEditor

            --import button
            local okayImportButton = DF:CreateButton(footerFrame, mainFrame.ImportColors, buttons_size[1], buttons_size[2], "Okay", -1, nil, nil, nil, nil, nil, DF:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate("font", "PLATER_BUTTON"))
            okayImportButton:SetIcon([[Interface\BUTTONS\UI-Panel-BiggerButton-Up]], 20, 20, "overlay", {0.1, .9, 0.1, .9})
            okayImportButton:SetPoint("topright", importTextEditor, "bottomright", 0, 1)
            mainFrame.OkayImportButton = okayImportButton

            --cancel button
            local cancelImportButton = DF:CreateButton(footerFrame, function() mainFrame.ImportTextEditor:Hide() end, buttons_size[1], buttons_size[2], "Cancel", -1, nil, nil, nil, nil, nil, DF:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate("font", "PLATER_BUTTON"))
            cancelImportButton:SetIcon([[Interface\BUTTONS\UI-Panel-MinimizeButton-Up]], 20, 20, "overlay", {0.1, .9, 0.1, .9})
            cancelImportButton:SetPoint("right", okayImportButton, "left", -2, 0)

            importTextEditor.OkayButton = okayImportButton
            importTextEditor.CancelButton = cancelImportButton
        end

        -- ~import sounds
        function castFrame.ImportCastSounds()
            --get the sounds from the text field and code it to import

            if (castFrame.IsImporting) then
                local text = castFrame.ImportEditor:GetText()
                text = DF:Trim(text)
                local soundData = Plater.DecompressData(text, "print")

                --exported cast colors has this member to identify the exported data
                if (soundData and soundData[Plater.Export_CastSoundAlerts]) then
                    --the uncompressed table is a numeric table of tables
                    for i, soundTable in pairs(soundData) do
                        --check integrity
                        if (type(soundTable) == "table") then
                            local spellId, audioName = unpack(soundTable)

                            --check integrity
                            spellId = tonumber(spellId)
                            audioName = tostring(audioName) -- may be nil

                            if (spellId) then
                                --add into the audio data
                                local filePath = LibSharedMedia:Fetch("sound", audioName)
                                if (filePath and type(filePath) == "string") then
                                    DB_CAST_AUDIOCUES[spellId] = filePath
                                else
                                    Plater:Msg("Audio not installed:", audioName)
                                end
                            end
                        end
                    end

                    castFrame.RefreshScroll()
                    Plater:Msg("data imported.")
                else
                    Plater.SendScriptTypeErrorMsg(soundData)
                end
            end

            castFrame.ImportEditor:Hide()
        end

        -- ~importcolor
        function castFrame.ImportColors()
            --get the colors from the text field and code it to import

            if (castFrame.IsImporting) then
                local text = castFrame.ImportEditor:GetText()
                text = DF:Trim(text)
                local colorData = Plater.DecompressData(text, "print")

                --exported cast colors has this member to identify the exported data
                if (colorData and colorData[Plater.Export_CastColors]) then

                    --the uncompressed table is a numeric table of tables
                    for i, colorTable in pairs(colorData) do
                        --check integrity
                        if (type(colorTable) == "table") then

                            local spellId, color, npcId, sourceName, npcLocation, encounterName, customSpellName, audioCue = unpack(colorTable)

                            --check integrity
                            spellId = tonumber(spellId)
                            color = tostring(color or "white")
                            npcId = tonumber(npcId)
                            sourceName = tostring(sourceName or "")
                            npcLocation = tostring(npcLocation or "")
                            encounterName = tostring(encounterName or "")
                            customSpellName = tostring(customSpellName or "")
                            audioCue = tostring(audioCue) -- may be nil

                            if (spellId and (color or customSpellName)) then
                                --add into the cast_colors data
                                DB_CAST_COLORS[spellId] = DB_CAST_COLORS[spellId] or {}
                                DB_CAST_COLORS[spellId][CONST_INDEX_COLOR] = color
                                DB_CAST_COLORS[spellId][CONST_INDEX_ENABLED] = true
                                DB_CAST_COLORS[spellId][CONST_INDEX_NAME] = customSpellName

                                DB_CAST_AUDIOCUES[spellId] = audioCue

                                --add into the discoreved spell cache
                                if (not DB_CAPTURED_SPELLS[spellId]) then
                                    DB_CAPTURED_SPELLS[spellId] = {
                                        event = "SPELL_CAST_SUCCESS",
                                        source = sourceName,
                                        npcID = npcId,
                                        encounterName = encounterName,
                                    }
                                end

                                --add into the npc cache
                                if (npcId and npcId ~= 0 and sourceName and sourceName ~= "" and npcLocation and npcLocation ~= "") then
                                    if (not DB_NPCIDS_CACHE[npcId]) then
                                        DB_NPCIDS_CACHE[npcId] = {
                                            sourceName,
                                            npcLocation
                                        }
                                    end
                                end
                            end
                        end
                    end

                    castFrame.RefreshScroll()
                    Plater:Msg ("cast colors imported.")
                else
                    Plater.SendScriptTypeErrorMsg(colorData)
                end
            end

            castFrame.ImportEditor:Hide()
        end

    --import and export buttons
        local importColorsFunc = function()
            if (not castFrame.ImportEditor) then
                createImportBox(castFrame, castFrame)
            end

            castFrame.IsExporting = nil
            castFrame.IsImporting = true

            castFrame.ImportEditor:Show()
            castFrame.ImportEditor:SetPoint("topleft", castFrame.Header, "topleft")
            castFrame.ImportEditor:SetPoint("bottomright", castFrame, "bottomright", 25, 37)
            --castFrame.ImportEditor.scroll:SetAlpha(0)

            castFrame.ImportEditor:SetText("")
            C_Timer.After(.1, function()
                castFrame.ImportEditor.editbox:HighlightText()
                castFrame.ImportEditor.editbox:SetFocus(true)
            end)

            castFrame.OkayImportButton:SetClickFunction(castFrame.ImportColors)
        end

        local importColorsButton = DF:CreateButton(castFrame, importColorsFunc, 70, 20, LOC["IMPORT_CAST_COLORS"], -1, nil, nil, nil, nil, nil, DF:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate("font", "PLATER_BUTTON"))
        importColorsButton:SetPoint("right", auraSearchTextEntry, "left", -2, 0)
        importColorsButton:SetFrameLevel(castFrame.Header:GetFrameLevel() + 20)
        importColorsButton:SetIcon([[Interface\AddOns\Plater\images\import_indicators_1.png]], 15, 14, "overlay", {0.25, 0.375, 0, 1})

        local exportColorsFunc = function()
            if (not castFrame.ImportEditor) then
                createImportBox(castFrame, castFrame)
            end

            --build the list of colors to be exported
            --~exportcolor ~export color table to string
            --this is the table which will be compress with libdeflate
            local exportedTable = {
                [Plater.Export_CastColors] = true, --identify this table as a cast color table
            }

            --[=[
			["cast_colors"] = {
				[325727] = {
					true, -- [1]
					"greenyellow", -- [2]
				},
			},
            --]=]
            --check if the user is searching npcs, build the export table only using the cast colors shown in the result
            if (IsSearchingFor and IsSearchingFor ~= "" and spells_scroll.SearchCachedTable) then
                local dbColors = Plater.db.profile.cast_colors

                for i, searchResult in ipairs(spells_scroll.SearchCachedTable) do
                    local spellId = searchResult[CONST_CASTINFO_SPELLID]
                    local sourceName = searchResult[CONST_CASTINFO_SOURCENAME]
                    local npcId = searchResult[CONST_CASTINFO_NPCID]
                    local npcLocation = searchResult[CONST_CASTINFO_NPCLOCATION]
                    local encounterName = searchResult[CONST_CASTINFO_ENCOUNTERNAME]
                    local customSpellName = searchResult[CONST_CASTINFO_CUSTOMSPELLNAME] or ""
                    local audioCue = DB_CAST_AUDIOCUES[spellId]

                    local castColor = dbColors[spellId]

                    if (castColor) then
                        local isEnabled = castColor[CONST_INDEX_ENABLED]
                        local color = castColor[CONST_INDEX_COLOR]
                        if (isEnabled) then
                            tinsert (exportedTable, {spellId, color, npcId, sourceName, npcLocation, encounterName, customSpellName, audioCue})
                        end
                    end
                end
            else
                for spellId, castColor in pairs(Plater.db.profile.cast_colors) do
                    local isEnabled = castColor[CONST_INDEX_ENABLED]
                    local color = castColor[CONST_INDEX_COLOR]
                    local npcId, sourceName, npcLocation, encounterName
                    local customSpellName = castColor[CONST_INDEX_NAME] or ""
                    local audioCue = DB_CAST_AUDIOCUES[spellId]

                    --this db gives source, npcID, event, encounterName
                    local capturedSpell = DB_CAPTURED_SPELLS[spellId] or DB_CAPTURED_CASTS[spellId]
                    if (capturedSpell) then
                        npcId = capturedSpell.npcID or 0

                        --this db give npc name, npc location
                        local npcInfo = DB_NPCIDS_CACHE[npcId]
                        if (npcInfo) then
                            sourceName = npcInfo[1] or ""
                            npcLocation = npcInfo[2] or ""
                        end
                    end

                    npcId = npcId or 0
                    sourceName = sourceName or ""
                    npcLocation = npcLocation or ""
                    encounterName = capturedSpell and capturedSpell.encounterName or ""

                    if (isEnabled) then
                        tinsert (exportedTable, {spellId, color, npcId, sourceName, npcLocation, encounterName, customSpellName, audioCue})
                    end
                end
            end

            --check if there's at least 1 color being exported
            if (#exportedTable < 1) then
                Plater:Msg(LOC["OPTIONS_NOTHING_TO_EXPORT"])
                return
            end

            castFrame.IsExporting = true
            castFrame.IsImporting = nil

            castFrame.ImportEditor:Show()
            castFrame.ImportEditor:SetPoint("topleft", castFrame.Header, "topleft")
            castFrame.ImportEditor:SetPoint("bottomright", castFrame, "bottomright", 25, 37)
            --castFrame.ImportEditor.scroll:SetAlpha(1)

            --compress data and show it in the text editor
            local data = Plater.CompressData(exportedTable, "print")
            castFrame.ImportEditor:SetText(data or "failed to export.")

            C_Timer.After(.1, function()
                castFrame.ImportEditor.editbox:HighlightText()
                castFrame.ImportEditor.editbox:SetFocus(true)
            end)
        end

        local exportColorsButton = DF:CreateButton(castFrame, exportColorsFunc, 70, 20, LOC["EXPORT_CAST_COLORS"], -1, nil, nil, nil, nil, nil, DF:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate("font", "PLATER_BUTTON"))
        exportColorsButton:SetPoint("right", importColorsButton, "left", -2, 0)
        exportColorsButton:SetFrameLevel(castFrame.Header:GetFrameLevel() + 20)
        exportColorsButton:SetIcon([[Interface\AddOns\Plater\images\import_indicators_1.png]], 15, 14, "overlay", {0.5, 0.625, 0, 1})

        --import cast sounds button
        local importCastSoundsFunc = function()
            if (not castFrame.ImportEditor) then
                createImportBox(castFrame, castFrame)
            end

            castFrame.IsExporting = nil
            castFrame.IsImporting = true

            castFrame.ImportEditor:Show()
            castFrame.ImportEditor:SetPoint("topleft", castFrame.Header, "topleft")
            castFrame.ImportEditor:SetPoint("bottomright", castFrame, "bottomright", 25, 37)
            --castFrame.ImportEditor.scroll:SetAlpha(0)

            castFrame.ImportEditor:SetText("")
            C_Timer.After(.1, function()
                castFrame.ImportEditor.editbox:HighlightText()
                castFrame.ImportEditor.editbox:SetFocus(true)
            end)

            castFrame.OkayImportButton:SetClickFunction(castFrame.ImportCastSounds)
        end

        local importCastSoundsButton = DF:CreateButton(castFrame, importCastSoundsFunc, 70, 20, LOC["IMPORT_CAST_SOUNDS"], -1, nil, nil, nil, nil, nil, DF:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate("font", "PLATER_BUTTON"))
        importCastSoundsButton:SetPoint("right", exportColorsButton, "left", -2, 0)
        importCastSoundsButton:SetFrameLevel(castFrame.Header:GetFrameLevel() + 20)
        importCastSoundsButton:SetIcon([[Interface\AddOns\Plater\images\import_indicators_1.png]], 15, 14, "overlay", {0.125, 0.25, 0, 1})

        --export cast sounds button
        local exportCastSoundsFunc = function()
            if (not castFrame.ImportEditor) then
                createImportBox(castFrame, castFrame)
            end
            --~exportsound ~export sound table to string
            local exportedTable = {
                [Plater.Export_CastSoundAlerts] = true, --identify this table as a cast color table
            }

            local allSounds = LibSharedMedia:HashTable("sound")

            for spellId, audioPath in pairs(DB_CAST_AUDIOCUES) do
                --find the sound name
                local soundName

                for thisSoundName, path in pairs(allSounds) do
                    if (path == audioPath) then
                        soundName = thisSoundName
                    end
                end

                if (soundName) then
                    table.insert(exportedTable, {spellId, soundName})
                end
            end

            --dumpt(exportedTable)

            --check if there's at least 1 color being exported
            if (#exportedTable < 1) then
                Plater:Msg(LOC["OPTIONS_NOTHING_TO_EXPORT"])
                return
            end

            castFrame.IsExporting = true
            castFrame.IsImporting = nil

            castFrame.ImportEditor:Show()
            castFrame.ImportEditor:SetPoint("topleft", castFrame.Header, "topleft")
            castFrame.ImportEditor:SetPoint("bottomright", castFrame, "bottomright", 25, 37)
            --castFrame.ImportEditor.scroll:SetAlpha(1)

            --compress data and show it in the text editor
            local data = Plater.CompressData(exportedTable, "print")
            castFrame.ImportEditor:SetText(data or "failed to export.")

            C_Timer.After(.1, function()
                castFrame.ImportEditor.editbox:HighlightText()
                castFrame.ImportEditor.editbox:SetFocus(true)
            end)
        end

        local exportCastSoundsButton = DF:CreateButton(castFrame, exportCastSoundsFunc, 70, 20, LOC["EXPORT_CAST_SOUNDS"], -1, nil, nil, nil, nil, nil, DF:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate("font", "PLATER_BUTTON"))
        exportCastSoundsButton:SetPoint("right", importCastSoundsButton, "left", -2, 0)
        exportCastSoundsButton:SetFrameLevel(castFrame.Header:GetFrameLevel() + 20)
        exportCastSoundsButton:SetIcon([[Interface\AddOns\Plater\images\import_indicators_1.png]], 15, 14, "overlay", {0.625, 0.75, 0, 1})

    --disable all button
        local disableAllColors = function()
            for spellId, colorTable in pairs(Plater.db.profile.cast_colors) do
                colorTable[CONST_INDEX_ENABLED] = false
            end
            castFrame.RefreshScroll()
        end

        local disableAllColorsButton = DF:CreateButton(castFrame, disableAllColors, 140, 20, LOC["OPTIONS_CASTCOLORS_DISABLECOLORS"], -1, nil, nil, nil, nil, nil, DF:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate("font", "PLATER_BUTTON"))
        disableAllColorsButton:SetPoint("left", refreshButton, "right", 2, 0)
        disableAllColorsButton:SetFrameLevel(castFrame.Header:GetFrameLevel() + 20)

    --toggle options button
        castFrame.showingScriptSelection = true
        local toggleScriptSelectionAndOptionsFrame = function()
            if (castFrame.showingScriptSelection) then
                spFrame:Hide()
                optionsFrame:Show()
                castFrame.toggleOptionsButton:SetText(LOC["OPTIONS_SHOWSCRIPTS"])
            else
                spFrame:Show()
                optionsFrame:Hide()
                castFrame.toggleOptionsButton:SetText(LOC["OPTIONS_SHOWOPTIONS"])
            end

            castFrame.showingScriptSelection = not castFrame.showingScriptSelection
        end

        local toggleOptionsButton = DF:CreateButton(castFrame, toggleScriptSelectionAndOptionsFrame, 70, 20, LOC["OPTIONS_SHOWOPTIONS"], -1, nil, nil, nil, nil, nil, DF:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate("font", "PLATER_BUTTON"))
        toggleOptionsButton:SetPoint("left", disableAllColorsButton, "right", 2, 0)
        toggleOptionsButton:SetFrameLevel(castFrame.Header:GetFrameLevel() + 20)
        castFrame.toggleOptionsButton = toggleOptionsButton

    -- buttons backdrop
        local backdropFoot = CreateFrame("frame", nil, spells_scroll, BackdropTemplateMixin and "BackdropTemplate")
        backdropFoot:SetHeight(20)
        backdropFoot:SetPoint("bottomleft", spells_scroll, "bottomleft", 0, 0)
        backdropFoot:SetPoint("bottomright", castFrame, "bottomright", -3, 0)
        backdropFoot:SetBackdrop({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
        backdropFoot:SetBackdropColor(.52, .52, .52, .7)
        backdropFoot:SetBackdropBorderColor(0, 0, 0, 1)
        backdropFoot:SetFrameLevel(castFrame.Header:GetFrameLevel() + 19)

    --empty label
        local empty_text = DF:CreateLabel(castFrame, "this list is automatically filled when\nyou see enemies casting spells inside a dungeons and raids\n\nthen you may select colors here.")
        empty_text.fontsize = 24
        empty_text.align = "|"
        empty_text:SetPoint("center", spells_scroll, "center", -130, 0)
        castFrame.EmptyText = empty_text

    --create the description
    castFrame.TitleDescText = Plater:CreateLabel(castFrame, "For raid and dungeon npcs, they are added into the list after you see them for the first time", 10, "silver")
    castFrame.TitleDescText:SetPoint("bottomleft", spells_scroll, "topleft", 0, 26)

    castFrame:SetScript("OnHide", function()
        if (castFrame.ImportEditor) then
            castFrame.ImportEditor:Hide()
            castFrame.ImportEditor.IsExporting = nil
            castFrame.ImportEditor.IsImporting = nil
        end
    end)

end