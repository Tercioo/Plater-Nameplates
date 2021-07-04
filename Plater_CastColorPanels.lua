local Plater = Plater
local GameCooltip = GameCooltip2
local DF = DetailsFramework
local _

--get templates
local options_text_template = DF:GetTemplate ("font", "OPTIONS_FONT_TEMPLATE")
local options_dropdown_template = DF:GetTemplate ("dropdown", "OPTIONS_DROPDOWN_TEMPLATE")
local options_switch_template = DF:GetTemplate ("switch", "OPTIONS_CHECKBOX_TEMPLATE")
local options_slider_template = DF:GetTemplate ("slider", "OPTIONS_SLIDER_TEMPLATE")
local options_button_template = DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE")

local DB_CAST_COLORS
local DB_NPCID_CACHE
local DB_CAPTURED_SPELLS

local CONST_INDEX_ENABLED = 1
local CONST_INDEX_COLOR = 2

local CONST_CASTINFO_ENABLED = 1
local CONST_CASTINFO_COLOR = 2
local CONST_CASTINFO_SPELLID = 3
local CONST_CASTINFO_SPELLNAME = 4
local CONST_CASTINFO_SPELLICON = 5
local CONST_CASTINFO_SOURCENAME = 6
local CONST_CASTINFO_NPCID = 7
local CONST_CASTINFO_NPCLOCATION = 8

local on_refresh_db = function()
	local profile = Plater.db.profile
	DB_CAST_COLORS = profile.cast_colors
    DB_NPCID_CACHE = profile.npc_cache
    DB_CAPTURED_SPELLS = profile.captured_spells
end
Plater.RegisterRefreshDBCallback(on_refresh_db)

function Plater.CreateCastColorOptionsFrame(castColorFrame)

    local castFrame = CreateFrame("frame", castColorFrame:GetName() .. "ColorFrame", castColorFrame)
    castFrame:SetPoint("topleft", castColorFrame, "topleft", 5, -140)
    castFrame:SetSize(1060, 600)

    --options
    local scroll_width = 1050
    local scroll_height = 442
    local scroll_lines = 20
    local scroll_line_height = 20
    local backdrop_color = {.2, .2, .2, 0.2}
    local backdrop_color_on_enter = {.8, .8, .8, 0.4}
    local y = startY or 5
    local headerY = y - 20
    local scrollY = headerY - 20

    DB_CAST_COLORS = Plater.db.profile.cast_colors
    DB_NPCID_CACHE = Plater.db.profile.npc_cache
    DB_CAPTURED_SPELLS = Plater.db.profile.captured_spells

    --header
    local headerTable = {
        {text = "Enabled", width = 50},
        {text = "Icon", width = 32},
        {text = "Spell Id", width = 70},
        {text = "Spell Name", width = 140},
        {text = "Npc Name", width = 120},
        {text = "Npc Id", width = 70},
        {text = "Location", width = 120},
        {text = "Color", width = 200},
    }
    local headerOptions = {
        padding = 2,
    }

    castFrame.Header = DF:CreateHeader(castFrame, headerTable, headerOptions)
    castFrame.Header:SetPoint("topleft", castFrame, "topleft", 10, headerY)

    --store npcID = checkbox object
    --this is used when selecting the color from the dropdown, it'll automatically enable the color and need to set the checkbox to checked for feedback
    castFrame.CheckBoxCache = {}

    --line scripts
    local line_onenter = function(self)
        self:SetBackdropColor (unpack (backdrop_color_on_enter))
        if (self.spellId) then
            GameTooltip:SetOwner (self, "ANCHOR_TOPLEFT")
            GameTooltip:SetSpellByID (self.spellId)
            GameTooltip:AddLine (" ")
            GameTooltip:Show()
        end
    end
    local line_onleave = function(self)
        self:SetBackdropColor(unpack (self.backdrop_color))
        GameTooltip:Hide()
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

        if (state) then
            self:GetParent():RefreshColor(DB_CAST_COLORS[spellId][CONST_INDEX_COLOR])
        else
            self:GetParent():RefreshColor()
        end

        Plater.RefreshDBLists()
        Plater.UpdateAllNameplateColors()
        Plater.ForceTickOnAllNameplates()
    end

    local line_select_color_dropdown = function (self, spellId, color)
        if (not DB_CAST_COLORS[spellId]) then
            DB_CAST_COLORS[spellId] = {true, "blue"}
        end

        DB_CAST_COLORS[spellId][CONST_INDEX_ENABLED] = true
        DB_CAST_COLORS[spellId][CONST_INDEX_COLOR] = color

        --o que é este checkbox cache
        local checkBox = castFrame.CheckBoxCache[spellId]
        if (checkBox) then
            checkBox:SetValue(true)
        end

        self:GetParent():RefreshColor(color)

        Plater.RefreshDBLists()
        Plater.ForceTickOnAllNameplates()

        --o que é esses dois caches
        castFrame.cachedColorTable = nil
        castFrame.cachedColorTableNameplate = nil
    end

    local function hex (num)
        local hexstr = '0123456789abcdef'
        local s = ''
        while num > 0 do
            local mod = math.fmod(num, 16)
            s = string.sub(hexstr, mod+1, mod+1) .. s
            num = math.floor(num / 16)
        end
        if s == '' then s = '00' end
        if (string.len (s) == 1) then
            s = "0"..s
        end
        return s
    end

    local function sort_color (t1, t2)
        return t1[1][CONST_INDEX_COLOR] > t2[1][CONST_INDEX_COLOR]
    end

    local line_refresh_color_dropdown = function(self)
        if (not self.spellId) then
            return {}
        end

        if (not castFrame.cachedColorTable) then
            local colorsAdded = {}
            local colorsAddedT = {}
            local t = {}

            --add colors already in use first
            --get colors that are already in use and pull them to be the first colors in the dropdown
            for spellId, castColorTable in pairs(DB_CAST_COLORS) do
                local color = castColorTable[CONST_INDEX_COLOR]
                if (not colorsAdded[color]) then
                    colorsAdded[color] = true
                    local r, g, b = DF:ParseColors(color)
                    tinsert(colorsAddedT, {{r, g, b}, color, hex (r * 255) .. hex (g * 255) .. hex (b * 255)})
                end
            end
            table.sort (colorsAddedT, sort_color)

            for index, colorTable in ipairs (colorsAddedT) do
                local colortable = colorTable[1]
                local colorname = colorTable[2]
                tinsert (t, {label = " " .. colorname, value = colorname, color = colortable, onclick = line_select_color_dropdown,
                statusbar = [[Interface\Tooltips\UI-Tooltip-Background]],
                icon = [[Interface\AddOns\Plater\media\star_empty_64]],
                iconcolor = {1, 1, 1, .6},
                })
            end

            --all colors
            local allColors = {}
            for colorName, colorTable in pairs (DF:GetDefaultColorList()) do
                if (not colorsAdded [colorName]) then
                    tinsert (allColors, {colorTable, colorName, hex (colorTable[1]*255) .. hex (colorTable[2]*255) .. hex (colorTable[3]*255)})
                end
            end
            table.sort (allColors, sort_color)

            for index, colorTable in ipairs (allColors) do
                local colortable = colorTable[1]
                local colorname = colorTable[2]
                tinsert (t, {label = colorname, value = colorname, color = colortable, onclick = line_select_color_dropdown})
            end

            castFrame.cachedColorTable = t
            return t
        else
            return castFrame.cachedColorTable
        end
    end

    --line
    local scroll_createline = function (self, index)

        local line = CreateFrame ("button", "$parentLine" .. index, self, BackdropTemplateMixin and "BackdropTemplate")
        line:SetPoint ("topleft", self, "topleft", 1, -((index-1)*(scroll_line_height+1)) - 1)
        line:SetSize (scroll_width - 3, scroll_line_height)
        line:SetScript ("OnEnter", line_onenter)
        line:SetScript ("OnLeave", line_onleave)

        line.RefreshColor = refresh_line_color

        line:SetBackdrop({bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
        line:SetBackdropColor(unpack (backdrop_color))

        DF:Mixin (line, DF.HeaderFunctions)

        --enabled check box
        local enabledCheckBox = DF:CreateSwitch(line, onToggleEnabled, true, _, _, _, _, "EnabledCheckbox", "$parentEnabledToggle" .. index, _, _, _, nil, DF:GetTemplate ("switch", "OPTIONS_CHECKBOX_BRIGHT_TEMPLATE"))
        enabledCheckBox:SetAsCheckBox()

        --spell icon
        local spellIconTexture = DF:CreateImage(line, "", scroll_line_height-2, scroll_line_height-2)
        spellIconTexture:SetTexCoord(.1, .9, .1, .9)
        line.spellIconTexture = spellIconTexture

        --spell Id
        local spellIdEntry = DF:CreateTextEntry(line, function()end, headerTable[3].width, 20, "spellIdEntry", nil, nil, DF:GetTemplate ("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))
        spellIdEntry:SetHook ("OnEditFocusGained", oneditfocusgained_spellid)
        spellIdEntry:SetJustifyH("left")

        --spell Name
        local spellNameEntry = DF:CreateTextEntry(line, function()end, headerTable[4].width, 20, "spellNameEntry", nil, nil, DF:GetTemplate ("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))
        spellNameEntry:SetHook("OnEditFocusGained", oneditfocusgained_spellid)
        spellNameEntry:SetJustifyH("left")

        --npc name
        local npcNameLabel = DF:CreateLabel(line, "", 10, "white", nil, "npcNameLabel")

        --npc Id
        local npcIdLabel = DF:CreateLabel(line, "", 10, "white", nil, "npcIdLabel")

        --location
        local npcLocationLabel = DF:CreateLabel(line, "", 10, "white", nil, "npcLocationLabel")

        --color
        local colorDropdown = DF:CreateDropDown(line, line_refresh_color_dropdown, 1, headerTable[7].width + 68, 20, "ColorDropdown", nil, DF:GetTemplate ("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))

        enabledCheckBox:SetHook ("OnEnter", widget_onenter)
        enabledCheckBox:SetHook ("OnLeave", widget_onleave)
        spellIdEntry:SetHook ("OnEnter", widget_onenter)
        spellIdEntry:SetHook ("OnLeave", widget_onleave)
        spellNameEntry:SetHook ("OnEnter", widget_onenter)
        spellNameEntry:SetHook ("OnLeave", widget_onleave)
        colorDropdown:SetHook ("OnEnter", widget_onenter)
        colorDropdown:SetHook ("OnLeave", widget_onleave)

        line:AddFrameToHeaderAlignment (enabledCheckBox)
        line:AddFrameToHeaderAlignment (spellIconTexture)
        line:AddFrameToHeaderAlignment (spellIdEntry)
        line:AddFrameToHeaderAlignment (spellNameEntry)
        line:AddFrameToHeaderAlignment (npcNameLabel)
        line:AddFrameToHeaderAlignment (npcIdLabel)
        line:AddFrameToHeaderAlignment (npcLocationLabel)
        line:AddFrameToHeaderAlignment (colorDropdown)

        line:AlignWithHeader (castFrame.Header, "left")

        return line
    end

    local sort_enabled_colors = function (t1, t2)
        if (t1[2] < t2[2]) then --color
            return true
        elseif (t1[2] > t2[2]) then --color
            return false
        else
            return t1[4] < t2[4] --alphabetical
        end
    end

    local sortOrder4R = function(t1, t2)
        return t1[4] < t2[4]
    end

    --refresh scroll
    local IsSearchingFor
    local scroll_refresh = function (self, data, offset, totalLines)
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

                    if (spellName:lower():find(IsSearchingFor) or sourceName:lower():find(IsSearchingFor) or npcLocation:lower():find(IsSearchingFor)) then
                        if (isEnabled) then
                            enabledTable[#enabledTable+1] = {true, color, spellId, spellName, spellIcon, sourceName, npcId, npcLocation}
                        else
                            dataInOrder[#dataInOrder+1] = {false, color, spellId, spellName, spellIcon, sourceName, npcId, npcLocation}
                        end
                    end
                end

                table.sort (enabledTable, sort_enabled_colors)
                table.sort (dataInOrder, sortOrder4R) --spell name

                for i = #enabledTable, 1, -1 do
                    tinsert (dataInOrder, 1, enabledTable[i])
                end

                self.SearchCachedTable = dataInOrder
                self.SearchCachedTable.SearchTerm = IsSearchingFor
            end
        else
            if (not self.CachedTable) then
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

                    if (isEnabled) then
                        enabledTable[#enabledTable+1] = {true, color, spellId, spellName, spellIcon, sourceName, npcId, npcLocation}
                    else
                        dataInOrder[#dataInOrder+1] = {false, color, spellId, spellName, spellIcon, sourceName, npcId, npcLocation}
                    end
                end

                self.CachedTable = dataInOrder

                table.sort (enabledTable, sort_enabled_colors)
                table.sort (dataInOrder, sortOrder4R) --spell name

                for i = #enabledTable, 1, -1 do
                    tinsert (dataInOrder, 1, enabledTable[i])
                end
            end

            dataInOrder = self.CachedTable
        end

        --
        if (#dataInOrder > 6) then
            castFrame.EmptyText:Hide()
        end
        --

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

                line.value = spellInfo
                line.spellId = nil

                if (spellName) then
                    local colorOption = color
                    line.spellId = spellId

                    line.ColorDropdown.spellId = spellId
                    line.ColorDropdown:SetFixedParameter(spellId)

                    line.spellIconTexture:SetTexture(spellIcon)

                    line.spellIdEntry:SetText(spellId)
                    line.spellNameEntry:SetText(spellName)
                    line.npcNameLabel:SetText(npcLocation)

                    line.npcNameLabel:SetText(sourceName)
                    line.npcIdLabel:SetText(npcId)
                    line.npcLocationLabel:SetText(npcLocation)

                    castFrame.CheckBoxCache[spellId] = line.EnabledCheckbox

                    if (colorOption) then
                        --causing lag in the scroll - might be an issue with dropdown:Select
                        --Select: is calling a dispatch making it to rebuild the entire color table, may be caching the color table might save performance
                        line.EnabledCheckbox:SetValue(isEnabled)
                        line.ColorDropdown:Select(color)

                        if (isEnabled) then
                            line:RefreshColor(color)
                        else
                            line:RefreshColor()
                        end
                    else
                        line.EnabledCheckbox:SetValue(false)
                        line.ColorDropdown:Select("white")

                        line:RefreshColor()
                    end

                    line.EnabledCheckbox:SetFixedParameter(spellId)
                else
                    line:Hide()
                end
            end
        end
    end

    --create scroll
    local spells_scroll = DF:CreateScrollBox (castFrame, "$parentColorsScroll", scroll_refresh, {}, scroll_width, scroll_height, scroll_lines, scroll_line_height)
    DF:ReskinSlider (spells_scroll)
    spells_scroll:SetPoint ("topleft", castFrame, "topleft", 10, scrollY)

    spells_scroll:SetScript("OnShow", function(self)
        if (self.LastRefresh and self.LastRefresh+0.5 > GetTime()) then
            return
        end
        self.LastRefresh = GetTime()

        local newData = {}
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

        for spellId, spellTable in pairs (DB_CAPTURED_SPELLS) do
            if (spellTable.event == "SPELL_CAST_SUCCESS" or spellTable.event == "SPELL_CAST_START") then
                local spellName, _, spellIcon = GetSpellInfo(spellId)
                if (spellName) then
                    local isEnabled = DB_CAST_COLORS[spellId] and DB_CAST_COLORS[spellId][CONST_INDEX_ENABLED] or false
                    local color = DB_CAST_COLORS[spellId] and DB_CAST_COLORS[spellId][CONST_INDEX_COLOR] or "white"

                    local castInfo = {isEnabled, color, spellId, spellName, spellIcon, spellTable.source or "", spellTable.npcId or 0}

                    local npcInfo = DB_NPCID_CACHE[spellTable.npcId]
                    if (npcInfo) then
                        if (not castInfo[CONST_CASTINFO_SOURCENAME]) then
                            castInfo[CONST_CASTINFO_SOURCENAME]  = npcInfo[1] or "" --npc name
                        end
                        castInfo[CONST_CASTINFO_NPCLOCATION] = npcInfo[2] or "" --npc location

                    else
                        castInfo[CONST_CASTINFO_SOURCENAME]  = "" --npc name
                        castInfo[CONST_CASTINFO_NPCLOCATION] = "" --npc location
                    end
                    tinsert (newData, castInfo)
                end
            end
        end

        self.CachedTable = nil
        self.SearchCachedTable = nil

        self:SetData(newData)
        self:Refresh()
    end)

    --create lines
    for i = 1, scroll_lines do 
        spells_scroll:CreateLine (scroll_createline)
    end
    
    --create search box
        function castFrame.OnSearchBoxTextChanged()
            local text = castFrame.AuraSearchTextEntry:GetText()
            if (text and string.len (text) > 0) then
                IsSearchingFor = text:lower()
            else
                IsSearchingFor = nil
            end
            spells_scroll:Refresh()
        end

        local aura_search_textentry = DF:CreateTextEntry (castFrame, function()end, 150, 20, "AuraSearchTextEntry", _, _, options_dropdown_template)
        aura_search_textentry:SetPoint ("bottomright", castFrame, "topright", 0, 5)
        aura_search_textentry:SetHook ("OnChar",		castFrame.OnSearchBoxTextChanged)
        aura_search_textentry:SetHook ("OnTextChanged", 	castFrame.OnSearchBoxTextChanged)
        local aura_search_label = DF:CreateLabel (aura_search_textentry, "search", DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"))
        aura_search_label:SetPoint ("left", aura_search_textentry, "left", 4, 0)
        aura_search_label.fontcolor = "gray"
        aura_search_label.color = {.5, .5, .5, .3}
        aura_search_textentry.tooltip = "|cFFFFFF00Npc Name|r or |cFFFFFF00Zone Name|r"
        aura_search_textentry:SetFrameLevel (castFrame.Header:GetFrameLevel() + 20)
        
        --clear search button
        local clear_search_button = DF:CreateButton (castFrame, function() aura_search_textentry:SetText(""); aura_search_textentry:ClearFocus() end, 20, 20, "", -1)
        clear_search_button:SetPoint ("right", aura_search_textentry, "right", 5, 0)
        clear_search_button:SetAlpha (.7)
        clear_search_button:SetIcon ([[Interface\Glues\LOGIN\Glues-CheckBox-Check]])
        clear_search_button.icon:SetDesaturated (true)
        clear_search_button:SetFrameLevel (castFrame.Header:GetFrameLevel() + 21)
    
        function castFrame.RefreshScroll (refreshSpeed)
            spells_scroll:Hide()
            C_Timer.After (refreshSpeed or .01, function() spells_scroll:Show() end)
        end

    --help button
        local help_button = DF:CreateButton (castFrame, function()end, 70, 20, "help", -1, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
        help_button:SetPoint ("right", aura_search_textentry, "left", -2, 0)
        help_button.tooltip = "|cFFFFFF00Help:|r\n\n- Spell are filled as they are seen.\n\n- Colors set in scripts and hooks override colors set here.\n\n- |TInterface\\AddOns\\Plater\\media\\star_empty_64:16:16|t icon indicates the color is favorite, so you can use it across all spells to keep color consistency."
        help_button:SetFrameLevel (castFrame.Header:GetFrameLevel() + 20)
        
    --refresh button
        local refresh_button = DF:CreateButton (castFrame, function() castFrame.RefreshScroll() end, 70, 20, "refresh", -1, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
        refresh_button:SetPoint ("right", help_button, "left", -2, 0)
        refresh_button.tooltip = "refresh the list the npcs"
        refresh_button:SetFrameLevel (castFrame.Header:GetFrameLevel() + 20)
        
        local create_import_box = function (parent, mainFrame)
            --import and export string text editor
            
            local edit_script_size = {620, 431}
            --text editor
            local luaeditor_backdrop_color = {.2, .2, .2, .5}
            local luaeditor_border_color = {0, 0, 0, 1}
            local edit_script_size = {620, 431}
            local buttons_size = {120, 20}

            local import_text_editor = DF:NewSpecialLuaEditorEntry (parent, edit_script_size[1], edit_script_size[2], "ImportEditor", "$parentImportEditor", true)
            import_text_editor:SetBackdrop ({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
            import_text_editor:SetBackdropBorderColor (unpack (luaeditor_border_color))
            import_text_editor:SetBackdropColor (.3, .3, .3, 1)
            import_text_editor:Hide()
            import_text_editor:SetFrameLevel (parent:GetFrameLevel()+100)
            DF:ReskinSlider (import_text_editor.scroll)
            
            local bg = import_text_editor:CreateTexture (nil, "background")
            bg:SetColorTexture (0.1, 0.1, 0.1, .9)
            bg:SetAllPoints()
            
            local block_mouse_frame = CreateFrame ("frame", nil, import_text_editor, BackdropTemplateMixin and "BackdropTemplate")
            block_mouse_frame:SetFrameLevel (block_mouse_frame:GetFrameLevel()-5)
            block_mouse_frame:SetAllPoints()
            block_mouse_frame:SetScript ("OnMouseDown", function()
                import_text_editor:SetFocus (true)
            end)
            
            --hide the code editor when the import text editor is shown
            import_text_editor:SetScript ("OnShow", function()
                --mainFrame.CodeEditorLuaEntry:Hide()
            end)
            
            --show the code editor when the import text editor is hide
            import_text_editor:SetScript ("OnHide", function()
                --mainFrame.CodeEditorLuaEntry:Show()
            end)
            
            mainFrame.ImportTextEditor = import_text_editor
            
            --import info
            local info_import_label = DF:CreateLabel (import_text_editor, "", DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"))
            info_import_label:SetPoint ("bottomleft", import_text_editor, "topleft", 0, 2)
            mainFrame.ImportTextEditor.TextInfo = info_import_label
            
            --import button
            local okay_import_button = DF:CreateButton (import_text_editor, mainFrame.ImportColors, buttons_size[1], buttons_size[2], "Okay", -1, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
            okay_import_button:SetIcon ([[Interface\BUTTONS\UI-Panel-BiggerButton-Up]], 20, 20, "overlay", {0.1, .9, 0.1, .9})
            okay_import_button:SetPoint ("topright", import_text_editor, "bottomright", 0, 1)
            
            --cancel button
            local cancel_import_button = DF:CreateButton (import_text_editor, function() mainFrame.ImportTextEditor:Hide() end, buttons_size[1], buttons_size[2], "Cancel", -1, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
            cancel_import_button:SetIcon ([[Interface\BUTTONS\UI-Panel-MinimizeButton-Up]], 20, 20, "overlay", {0.1, .9, 0.1, .9})
            cancel_import_button:SetPoint ("right", okay_import_button, "left", -2, 0)
            
            import_text_editor.OkayButton = okay_import_button
            import_text_editor.CancelButton = cancel_import_button
        end			 
        
        -- ~importcolor
        function castFrame.ImportColors()
            --get the colors from the text field and code it to import

            if (castFrame.IsImporting) then
                local text = castFrame.ImportEditor:GetText()
                text = DF:Trim (text)
                local colorData = Plater.DecompressData (text, "print")
            
                --exported npc colors has this member to identify the exported data
                if (colorData and colorData.NpcColor) then
                    --store which npcs has a color enabled
                    local dbColors = Plater.db.profile.npc_colors
                    --table storing all npcs already detected inside dungeons and raids
                    local allNpcsDetectedTable = Plater.db.profile.npc_cache

                    --the uncompressed table is a numeric table of tables
                    for i, colorTable in pairs (colorData) do
                        --check integrity
                        if (type (colorTable) == "table") then
                            local npcID, scriptOnly, colorID, npcName, zoneName = unpack (colorTable)
                            if (npcID and colorID and npcName and zoneName) then
                                if (type (colorID) == "string" and type (npcName) == "string" and type (zoneName) == "string") then
                                    if (type (npcID) == "number" and type (scriptOnly) == "boolean") then
                                        dbColors [npcID] = dbColors [npcID] or {}
                                        dbColors [npcID] [1] = true --the color for the npc is enabled
                                        dbColors [npcID] [2] = scriptOnly --the color is only used in scripts
                                        dbColors [npcID] [3] = colorID --string with the color name
                                        
                                        --add this npcs in the npcs detected table as well
                                        allNpcsDetectedTable [npcID] = allNpcsDetectedTable [npcID] or {}
                                        allNpcsDetectedTable [npcID] [1] = npcName
                                        allNpcsDetectedTable [npcID] [2] = zoneName
                                    end
                                end
                            end
                        end
                    end
                    
                    castFrame.RefreshScroll()
                    Plater:Msg ("npc colors imported.")
                else
                    if (colorData.NpcNames) then
                        Plater:Msg ("this import look like Script, try importing in the Scripting tab.")
                    
                    elseif (colorData.LoadConditions) then
                        Plater:Msg ("this import look like a Mod, try importing in the Modding tab.")
                    end

                    Plater:Msg ("failed to import color data table.")
                end
            end
            
            castFrame.ImportEditor:Hide()
            
        end
        
    --import and export buttons
        local import_func = function()
            if (not castFrame.ImportEditor) then
                create_import_box (castFrame, castFrame)
            end
            
            castFrame.IsExporting = nil
            castFrame.IsImporting = true
            
            castFrame.ImportEditor:Show()
            castFrame.ImportEditor:SetPoint ("topleft", castFrame.Header, "topleft")
            castFrame.ImportEditor:SetPoint ("bottomright", castFrame, "bottomright", -17, 37)
            
            castFrame.ImportEditor:SetText ("")
            C_Timer.After (.1, function()
                castFrame.ImportEditor.editbox:HighlightText()
                castFrame.ImportEditor.editbox:SetFocus (true)
            end)
        end
        local import_button = DF:CreateButton (castFrame, import_func, 70, 20, "import", -1, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
        import_button:SetPoint ("right", refresh_button, "left", -2, 0)
        import_button:SetFrameLevel (castFrame.Header:GetFrameLevel() + 20)
        
        local export_func = function()
            if (not castFrame.ImportEditor) then
                create_import_box (castFrame, castFrame)
            end
            
            --build the list of colors to be exported
            --~exportcolor ~export color table to string
            --this is the table which will be compress with libdeflate
            local exportedTable = {
                NpcColor = true, --identify this table as a npc color table
            }
            
            --check if the user is searching npcs, build the export table only using the npcs shown in the result
            if (IsSearchingFor and IsSearchingFor ~= "" and spells_scroll.SearchCachedTable) then
                local dbColors = Plater.db.profile.npc_colors
                
                for i, searchResult in ipairs (spells_scroll.SearchCachedTable) do
                
                    local _, _, npcName, zoneName, npcID = unpack (searchResult)
                    local infoTable = dbColors [npcID]

                    if (infoTable) then
                        local enabled1 = infoTable [1] --boolean, this is the overall enabled
                        local enabled2 = infoTable [2] --boolean, if this is true, this color is only used for scripts
                        local colorID = infoTable [3] --string, the color name

                        --build a table to store one the npc and insert the table inside the main table which will be compressed
                        --only add the npc if it is enabled in the color panel
                        if (enabled1) then
                                                --number   | boolean     | string   | string      | string
                            tinsert (exportedTable, {npcID, enabled2, colorID, npcName, zoneName})
                        end
                    end
                end
            
            else
                --table storing all npcs already detected inside dungeons and raids, need it to get the zone name
                local allNpcsDetectedTable = Plater.db.profile.npc_cache
                
                --make the list
                for npcID, infoTable in pairs (Plater.db.profile.npc_colors) do
                    local enabled1 = infoTable [1] --boolean, this is the overall enabled
                    local enabled2 = infoTable [2] --boolean, if this is true, this color is only used for scripts
                    local colorID = infoTable [3] --string, the color name
                    
                    local npcName = allNpcsDetectedTable [npcID] and allNpcsDetectedTable [npcID] [1]
                    local zoneName = allNpcsDetectedTable [npcID] and allNpcsDetectedTable [npcID] [2]

                    --build a table to store one the npc and insert the table inside the main table which will be compressed
                    --only add the npc if it is enabled in the color panel
                    if (enabled1 and npcName and zoneName) then
                                            --number   | boolean     | string   | string      | string
                        tinsert (exportedTable, {npcID, enabled2, colorID, npcName, zoneName})
                    end
                end
            end
            
            --check if there's at least 1 npc
            if (#exportedTable < 1) then
                Plater:Msg ("There's nothing to export.")
                return
            end
            
            castFrame.IsExporting = true
            castFrame.IsImporting = nil
            
            castFrame.ImportEditor:Show()
            castFrame.ImportEditor:SetPoint ("topleft", castFrame.Header, "topleft")
            castFrame.ImportEditor:SetPoint ("bottomright", castFrame, "bottomright", -17, 37)
            
            --compress data and show it in the text editor
            local data = Plater.CompressData (exportedTable, "print")
            castFrame.ImportEditor:SetText (data or "failed to export color table")
            
            C_Timer.After (.1, function()
                castFrame.ImportEditor.editbox:HighlightText()
                castFrame.ImportEditor.editbox:SetFocus (true)
            end)
        end
        
        local export_button = DF:CreateButton (castFrame, export_func, 70, 20, "export", -1, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
        export_button:SetPoint ("right", import_button, "left", -2, 0)
        export_button:SetFrameLevel (castFrame.Header:GetFrameLevel() + 20)
    
    --disable all button
        local disableAllColors = function()
            for spellId, colorTable in pairs(Plater.db.profile.cast_colors) do
                colorTable[CONST_INDEX_ENABLED] = false
            end
            castFrame.RefreshScroll()
        end

        local disableall_button = DF:CreateButton (castFrame, disableAllColors, 140, 20, "Disable All Colors", -1, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
        disableall_button:SetPoint ("bottomleft", spells_scroll, "bottomleft", 1, 0)
        disableall_button:SetFrameLevel (castFrame.Header:GetFrameLevel() + 20)

    -- buttons backdrop
        local backdropFoot = CreateFrame ("frame", nil, spells_scroll, BackdropTemplateMixin and "BackdropTemplate")
        backdropFoot:SetHeight (20)
        backdropFoot:SetPoint ("bottomleft", spells_scroll, "bottomleft", 0, 0)
        backdropFoot:SetPoint ("bottomright", castFrame, "bottomright", -3, 0)
        backdropFoot:SetBackdrop ({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
        backdropFoot:SetBackdropColor (.52, .52, .52, .7)
        backdropFoot:SetBackdropBorderColor (0, 0, 0, 1)
        backdropFoot:SetFrameLevel (castFrame.Header:GetFrameLevel() + 19)
    
    --empty label
        local empty_text = DF:CreateLabel (castFrame, "this list is automatically filled when\nyou see enemies inside a dungeon or raid\n\nthen you may select colors here or directly\nin the dropdown below the nameplate")
        empty_text.fontsize = 24
        empty_text.align = "|"
        empty_text:SetPoint ("center", spells_scroll, "center", -250, 0)
        castFrame.EmptyText = empty_text
        
    --create the title
    castFrame.TitleDescText = Plater:CreateLabel (castFrame, "For raid and dungeon npcs, they are added into the list after you see them for the first time", 10, "silver")
    castFrame.TitleDescText:SetPoint ("bottomleft", spells_scroll, "topleft", 0, 26)
    castFrame.TitleText = Plater:CreateLabel (castFrame, "Npc Color", 14, "orange")
    castFrame.TitleText:SetPoint ("bottomleft", castFrame.TitleDescText, "topleft", 0, 2)
    
    castFrame:SetScript ("OnHide", function()
        if (castFrame.ImportEditor) then
            castFrame.ImportEditor:Hide()
            castFrame.ImportEditor.IsExporting = nil
            castFrame.ImportEditor.IsImporting = nil
        end
    end)

end