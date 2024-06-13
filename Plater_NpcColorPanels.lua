
local addonId, platerInternal = ...

local Plater = Plater
---@type detailsframework
local DF = DetailsFramework
local _

local IsShiftKeyDown = IsShiftKeyDown
local unpack = unpack
local CreateFrame = CreateFrame

local startX, startY, heightSize = 10, platerInternal.optionsYStart, 755
local highlightColorLastCombat = {1, 1, .2, .25}

--options
local scroll_width = 1050
local scroll_height = 442
local scroll_lines = 20
local scroll_line_height = 20
local backdrop_color = {.2, .2, .2, 0.2}
local backdrop_color_on_enter = {.8, .8, .8, 0.4}
local y = startY
local headerY = y - 20
local scrollY = headerY - 20

local DB_NPCID_CACHE
local DB_NPCID_COLORS

--templates
local options_dropdown_template = DF:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE")

--members
local MEMBER_NPCID = "namePlateNpcId"
local MEMBER_NAME = "namePlateUnitName"

--header
local headerTable = {
    {text = "Enabled", width = 50},
    {text = "Npc ID", width = 64},
    {text = "Npc Name", width = 162},
    {text = "Rename To", width = 140},
    {text = "Zone Name", width = 142},
    {text = "Select Color", width = 110},
    {text = "Send to Raid", width = 100},
    {text = "Casts", width = 30},
    {text = "", width = 270}, --filler
}

local headerOptions = {
    padding = 2,
}

local onRefreshDBCallback = function()
    local profile = Plater.db.profile
	DB_NPCID_CACHE = profile.npc_cache
	DB_NPCID_COLORS = profile.npc_colors
end
Plater.RegisterRefreshDBCallback(onRefreshDBCallback)

function Plater.CreateNpcColorOptionsFrame(colorsFrame)
    local L = DF.Language.GetLanguageTable(addonId)

    colorsFrame.Header = DF:CreateHeader(colorsFrame, headerTable, headerOptions)
    colorsFrame.Header:SetPoint("topleft", colorsFrame, "topleft", 10, headerY)

    colorsFrame.ModelFrame = CreateFrame("PlayerModel", nil, colorsFrame, "ModelWithControlsTemplate, BackdropTemplate")
    colorsFrame.ModelFrame:SetSize(250, 440)
    colorsFrame.ModelFrame:EnableMouse(true)
    colorsFrame.ModelFrame:SetPoint("topleft", colorsFrame.Header, "topright", -265, -scroll_line_height - 1)
    colorsFrame.ModelFrame:SetBackdrop({bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
    colorsFrame.ModelFrame:SetBackdropColor(.4, .4, .4, 1)
    colorsFrame.ModelFrame:SetScript("OnEnter", nil)
    colorsFrame.ModelFrame.zoomLevel = 0.1
    colorsFrame.ModelFrame.minZoom = 0.01
    colorsFrame.ModelFrame.maxZoom = 1

    --store npcID = checkbox object
    --this is used when selecting the color from the dropdown, it'll automatically enable the color and need to set the checkbox to checked for feedback
    colorsFrame.CheckBoxCache = {}

    --line scripts
    local lineOnEnter = function(self)
        if (self.hasHighlight) then
            local r, g, b, a = unpack(highlightColorLastCombat)
            self:SetBackdropColor(r, g, b, a+0.2)
        else
            self:SetBackdropColor(unpack(backdrop_color_on_enter))
        end

        if (self.npcID) then
            colorsFrame.ModelFrame:SetCreature(self.npcID)
        end
    end

    local lineOnLeave = function(self)
        if (self.hasHighlight) then
            self:SetBackdropColor(unpack(highlightColorLastCombat))
        else
            self:SetBackdropColor(unpack(self.backdrop_color))
        end

        GameTooltip:Hide()
        colorsFrame.ModelFrame:SetCreature(1)
    end

    local widgetOnEnter = function(self)
        local line = self:GetParent()
        line:GetScript("OnEnter")(line)
    end

    local widgetOnLeave = function(self)
        local line = self:GetParent()
        line:GetScript("OnLeave")(line)
    end

    local onEditFocusGained_SpellId = function(self, capsule)
        self:HighlightText(0)
    end

    local refreshLineColor = function(self, color)
        color = color or backdrop_color
        local r, g, b = DF:ParseColors(color)
        local a = 0.2
        self:SetBackdropColor(r, g, b, a)
        self.backdrop_color = self.backdrop_color or {}
        self.backdrop_color[1] = r
        self.backdrop_color[2] = g
        self.backdrop_color[3] = b
        self.backdrop_color[4] = a

        self.ColorDropdown:Select(color)
    end

    local onToggleEnabled = function(self, npcID, state)
        if (not DB_NPCID_COLORS[npcID]) then
            --[1] enabled [2] only script [3] color
            DB_NPCID_COLORS[npcID] = {false, false, "blue"}
        end
        DB_NPCID_COLORS[npcID][1] = state

        if (state) then
            self:GetParent():RefreshColor(DB_NPCID_COLORS[npcID][3])
        else
            self:GetParent():RefreshColor()
            --disable only for scripts
            DB_NPCID_COLORS[npcID][2] = false
        end

        Plater.RefreshDBLists()
        Plater.UpdateAllNameplateColors()
        Plater.ForceTickOnAllNameplates()

        colorsFrame.RefreshDropdowns()
    end

    local lineOnSelectColorDropdown = function(self, npcID, color)
        local bNeedRefresh = false

        if (color == platerInternal.RemoveColor) then
            if (DB_NPCID_COLORS[npcID]) then
                DB_NPCID_COLORS[npcID] = nil
                local enableColorCheckbox = colorsFrame.CheckBoxCache[npcID]
                if (enableColorCheckbox) then
                    enableColorCheckbox:SetValue(false)
                end
            end
        else
            if (not DB_NPCID_COLORS[npcID]) then
                DB_NPCID_COLORS[npcID] = {true, false, "blue"}
            end

            local bOldColorWasEnabled = self.colorTable and self.colorTable[1]
            local oldColorName = self.colorTable and self.colorTable[3]

            DB_NPCID_COLORS[npcID][1] = true
            DB_NPCID_COLORS[npcID][3] = color

            --if the shift key is pressed, change the color of all npcs with this color
            if (IsShiftKeyDown() and bOldColorWasEnabled and type(oldColorName) == "string") then
                for _, npcColorTable in pairs(DB_NPCID_COLORS) do
                    --[1] enabled [2] only script [3] color
                    if (npcColorTable[1] and npcColorTable[3] == oldColorName) then
                        npcColorTable[3] = color
                        bNeedRefresh = true
                    end
                end
            end

            local checkBox = colorsFrame.CheckBoxCache[npcID]
            if (checkBox) then
                checkBox:SetValue(true)
            end
        end

        self:GetParent():RefreshColor(color)

        Plater.RefreshDBLists()
        Plater.ForceTickOnAllNameplates()

        colorsFrame.cachedColorTable = nil
        colorsFrame.cachedColorTableNameplate = nil
        colorsFrame.RefreshDropdowns()

        if (bNeedRefresh) then
            --refresh the scrollbox showing all the npc colors
            colorsFrame.SpellsScroll:Refresh()
        end
    end

    local lineRefreshColorDropdown = function(self)
        local colorEnabledIndexOnDB = 1
        local colorIndexOnDB = 3
        return platerInternal.RefreshColorDropdown(colorsFrame, self, DB_NPCID_COLORS, lineOnSelectColorDropdown, "npcID", colorEnabledIndexOnDB, colorIndexOnDB)
    end

    --callback from have clicked in the 'Send To Raid' button
    local latestMenuClicked = false
    local onSendToRaidButtonClicked = function(self, button, npcId)
        if (npcId == latestMenuClicked and GameCooltip:IsShown()) then
            GameCooltip:Hide()
            latestMenuClicked = false
            return
        end

        latestMenuClicked = npcId

        GameCooltip:Preset(2)
        GameCooltip:SetOwner(self)
        GameCooltip:SetType("menu")
        GameCooltip:SetFixedParameter(npcId)

        local bAutoAccept = false

        --send npc color to raid with accept button
        --parameters: npcId, auto accept
        GameCooltip:AddMenu(1, platerInternal.Comms.SendNpcInfoToGroup, bAutoAccept, "npccolor", "", "Send Color", nil, true)
        GameCooltip:AddIcon([[Interface\BUTTONS\JumpUpArrow]], 1, 1, 14, 14)

        --send npc name to raid with accept button
        GameCooltip:AddMenu(1, platerInternal.Comms.SendNpcInfoToGroup, bAutoAccept, "npcrename", "", "Send Rename", nil, true)
        GameCooltip:AddIcon([[Interface\BUTTONS\JumpUpArrow]], 1, 1, 14, 14)

        --send a signal to set the color and rename to default
        GameCooltip:AddMenu(1, platerInternal.Comms.SendNpcInfoToGroup, bAutoAccept, "resetnpc", "", "Send Reset", nil, true)
        GameCooltip:AddIcon([[Interface\BUTTONS\UI-GROUPLOOT-PASS-DOWN]], 1, 1, 14, 14)

        GameCooltip:AddLine("$div")
        bAutoAccept = true

        GameCooltip:Show()
    end

    --line
    local scrollBox_CreateLine = function(self, index)
        local line = CreateFrame("button", "$parentLine" .. index, self, BackdropTemplateMixin and "BackdropTemplate")
        line:SetPoint("topleft", self, "topleft", 1, -((index-1) * (scroll_line_height+1)) - 1)
        line:SetSize(scroll_width - colorsFrame.ModelFrame:GetWidth() + 19, scroll_line_height)
        line:SetScript("OnEnter", lineOnEnter)
        line:SetScript("OnLeave", lineOnLeave)

        line.RefreshColor = refreshLineColor

        line:SetBackdrop({bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
        line:SetBackdropColor(unpack(backdrop_color))

        DF:Mixin(line, DF.HeaderFunctions)

        --enabled check box
        local enabledCheckBox = DF:CreateSwitch(line, onToggleEnabled, true, _, _, _, _, "EnabledCheckbox", "$parentEnabledToggle" .. index, _, _, _, nil, DF:GetTemplate("switch", "OPTIONS_CHECKBOX_BRIGHT_TEMPLATE"))
        enabledCheckBox:SetAsCheckBox()

        --npc ID
        local npcIDEntry = DF:CreateTextEntry(line, function()end, headerTable[2].width, 20, "NpcIDEntry", nil, nil, DF:GetTemplate("dropdown", "PLATER_DROPDOWN_OPTIONS"))
        npcIDEntry:SetHook("OnEditFocusGained", onEditFocusGained_SpellId)
        npcIDEntry:SetJustifyH("left")

        --npc Name
        local npcNameEntry = DF:CreateTextEntry(line, function()end, headerTable[3].width, 20, "NpcNameEntry", nil, nil, DF:GetTemplate("dropdown", "PLATER_DROPDOWN_OPTIONS"))
        npcNameEntry:SetHook("OnEditFocusGained", onEditFocusGained_SpellId)
        npcNameEntry:SetJustifyH("left")

        --rename box
        local npcRenameEntry = DF:CreateTextEntry(line, function()end, headerTable[4].width, 20, "NpcRenameEntry", nil, nil, DF:GetTemplate("dropdown", "PLATER_DROPDOWN_OPTIONS"))
        npcRenameEntry:SetHook("OnEditFocusGained", onEditFocusGained_SpellId)
        npcRenameEntry:SetJustifyH("left")

        npcRenameEntry:SetHook("OnEditFocusLost", function(widget, capsule, text)
            local npcsRenamed = Plater.db.profile.npcs_renamed
            local npcID = capsule.npcID
            capsule.text = npcsRenamed[npcID] or ""
        end)

        npcRenameEntry:SetHook("OnEnterPressed", function(widget, capsule, text)
            local npcsRenamed = Plater.db.profile.npcs_renamed
            local npcID = capsule.npcID
            if (text == "") then
                npcsRenamed[npcID] = nil
            else
                npcsRenamed[npcID] = text
            end

            Plater.UpdateAllPlates()
        end)

        --zone name
        local zoneNameLabel = DF:CreateLabel(line, "", 10, "white", nil, "ZoneNameLabel")

        --color
        local colorDropdown = DF:CreateDropDown(line, lineRefreshColorDropdown, 1, headerTable[6].width, 20, "ColorDropdown", nil, DF:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))
        colorDropdown:SetFrameLevel(line:GetFrameLevel()+2)

        --send to raid button
        local sendToRaidButton = DF:CreateButton(line, onSendToRaidButtonClicked, headerTable[7].width, 20, "Click to Select", -1, nil, nil, nil, nil, nil, DF:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate("font", "PLATER_BUTTON"))
        line.sendToRaidButton = sendToRaidButton

        --this button select the casts colors tab and search for the npc name there
        local gotoCastColorsTab = DF:CreateButton(line, function(self, fixedParameter, param1) Plater.OpenCastColorsPanel(param1) end, 20, 20)
        gotoCastColorsTab:SetIcon([[Interface\Buttons\UI-Panel-BiggerButton-Up]], 18, 18, "overlay", {0.2, 0.8, 0.2, 0.8}, {1, 1, 1, 0.834})
        line.gotoCastColorsTab = gotoCastColorsTab

        --set hooks
        enabledCheckBox:SetHook("OnEnter", widgetOnEnter)
        enabledCheckBox:SetHook("OnLeave", widgetOnLeave)
        npcIDEntry:SetHook("OnEnter", widgetOnEnter)
        npcIDEntry:SetHook("OnLeave", widgetOnLeave)
        npcNameEntry:SetHook("OnEnter", widgetOnEnter)
        npcNameEntry:SetHook("OnLeave", widgetOnLeave)
        npcRenameEntry:SetHook("OnEnter", widgetOnEnter)
        npcRenameEntry:SetHook("OnLeave", widgetOnLeave)
        colorDropdown:SetHook("OnEnter", widgetOnEnter)
        colorDropdown:SetHook("OnLeave", widgetOnLeave)

        line:AddFrameToHeaderAlignment(enabledCheckBox)
        line:AddFrameToHeaderAlignment(npcIDEntry)
        line:AddFrameToHeaderAlignment(npcNameEntry)
        line:AddFrameToHeaderAlignment(npcRenameEntry)
        line:AddFrameToHeaderAlignment(zoneNameLabel)
        line:AddFrameToHeaderAlignment(colorDropdown)
        line:AddFrameToHeaderAlignment(sendToRaidButton)
        line:AddFrameToHeaderAlignment(gotoCastColorsTab)

        line:AlignWithHeader(colorsFrame.Header, "left")

        return line
    end

    local sortEnabledColors = function(t1, t2)
        if (t1[2] < t2[2]) then --color
            return true

        elseif (t1[2] > t2[2]) then --color
            return false

        else
            return t1[3] < t2[3] --alphabetical
        end
    end

    --refresh scroll
    local sSearchingFor
    local scrollBox_Refresh = function(self, data, offset, total_lines) --~refresh
        --data has all npcIDs from dungeons
        local dataInOrder = {}

        local canSortByLastCombat = false
        local lastCombatNpcs = Plater.LastCombat.npcNames
        if (next(lastCombatNpcs)) then
            canSortByLastCombat = true
        end

        if (sSearchingFor and sSearchingFor ~= "") then
            if (self.SearchCachedTable and sSearchingFor == self.SearchCachedTable.SearchTerm) then
                dataInOrder = self.SearchCachedTable
            else
                local enabledTable = {}
                local npcsRenamed = Plater.db.profile.npcs_renamed

                for i = 1, #data do
                    local npcID = data[i][1]
                    local npcName = data[i][2] or "UNKNOWN"
                    local zoneName = data[i][3] or "UNKNOWN"
                    local color = DB_NPCID_COLORS[npcID] and DB_NPCID_COLORS[npcID][1] and DB_NPCID_COLORS[npcID][3] or "white" --has | is enabled | color
                    local rename = npcsRenamed[npcID] and npcsRenamed[npcID]:lower()
                    local selectedColorName = DB_NPCID_COLORS[npcID] and DB_NPCID_COLORS[npcID][3]

                    if (
                        (tostring(npcID) or ""):find(sSearchingFor) or
                        npcName:lower():find(sSearchingFor) or
                        zoneName:lower():find(sSearchingFor) or
                        (rename and rename:find(sSearchingFor)) or
                        (selectedColorName and selectedColorName:find(sSearchingFor))
                    ) then
                        if (DB_NPCID_COLORS[npcID] and DB_NPCID_COLORS[npcID][1]) then
                            enabledTable[#enabledTable+1] = {1, color, npcName, zoneName, npcID}
                        else
                            dataInOrder[#dataInOrder+1] = {0, color, npcName, zoneName, npcID}
                        end
                    end
                end

                table.sort(enabledTable, sortEnabledColors)
                table.sort(dataInOrder, DF.SortOrder3R) --npc name

                for i = #enabledTable, 1, -1 do
                    table.insert(dataInOrder, 1, enabledTable[i])
                end

                self.SearchCachedTable = dataInOrder
                self.SearchCachedTable.SearchTerm = sSearchingFor
            end
        else
            if (not self.CachedTable) then
                local enabledTable = {}
                local lastCombatNpcsList = {}

                for i = 1, #data do
                    local npcID = data[i][1]
                    local npcName = data[i][2]
                    local zoneName = data[i][3]
                    local color = DB_NPCID_COLORS[npcID] and DB_NPCID_COLORS[npcID][1] and DB_NPCID_COLORS[npcID][3] or "white" --has | is enabled | color

                    if (canSortByLastCombat and lastCombatNpcs[npcName]) then
                        lastCombatNpcsList[#lastCombatNpcsList+1] = {2, color, npcName, zoneName, npcID}

                    elseif (DB_NPCID_COLORS[npcID] and DB_NPCID_COLORS[npcID][1]) then
                        enabledTable[#enabledTable+1] = {1, color, npcName, zoneName, npcID}

                    else
                        dataInOrder[#dataInOrder+1] = {0, color, npcName, zoneName, npcID}
                    end
                end

                self.CachedTable = dataInOrder

                table.sort(enabledTable, sortEnabledColors)
                table.sort(dataInOrder, DF.SortOrder3R) --npc name

                --add enabled
                for i = #enabledTable, 1, -1 do
                    table.insert(dataInOrder, 1, enabledTable[i])
                end
                --add from last combat
                for i = #lastCombatNpcsList, 1, -1 do
                    table.insert(dataInOrder, 1, lastCombatNpcsList[i])
                end
            end

            dataInOrder = self.CachedTable
        end

        if (#dataInOrder > 6) then
            colorsFrame.EmptyText:Hide()
        end
        --

        data = dataInOrder

        if (#data == 1) then
            local npcId = data[1][5]
            if (npcId) then
                colorsFrame.ModelFrame:SetCreature(npcId)
            end
        end

        local npcsRenamed = Plater.db.profile.npcs_renamed

        for i = 1, total_lines do
            local index = i + offset
            local npcTable = data[index]

            if (npcTable) then
                local line = self:GetLine(i)
                local npcID = npcTable[5]
                local npcName = npcTable[3]
                local zoneName = npcTable[4]
                local isFromLastCombat = npcTable[1] == 2

                line.value = npcTable
                line.npcID = nil

                if (npcName) then
                    local colorOption = DB_NPCID_COLORS[npcID]

                    line.npcID = npcID

                    line.ColorDropdown.npcID = npcID
                    line.ColorDropdown:SetFixedParameter(npcID)

                    line.NpcIDEntry:SetText(npcID)
                    line.NpcNameEntry:SetText(npcName)
                    line.NpcRenameEntry:SetText(npcsRenamed[npcID] or "")
                    line.NpcRenameEntry.npcID = npcID
                    line.ZoneNameLabel:SetText(zoneName)
                    line.hasHighlight = nil

                    line.sendToRaidButton.npcId = npcID
                    line.sendToRaidButton:SetClickFunction(onSendToRaidButtonClicked, npcID)

                    line.gotoCastColorsTab.param1 = npcName

                    colorsFrame.CheckBoxCache[npcID] = line.EnabledCheckbox

                    if (colorOption) then
                        --causing lag in the scroll - might be an issue with dropdown:Select
                        --Select: is calling a dispatch making it to rebuild the entire color table, may be caching the color table might save performance
                        --it is caching now, performance fixed
                        line.EnabledCheckbox:SetValue(colorOption[1])
                        line.ColorDropdown.colorTable = colorOption
                        line.ColorDropdown:Select(colorOption[3])

                        if (colorOption[1]) then
                            line:RefreshColor(colorOption[3])
                        else
                            line:RefreshColor()
                        end
                    else
                        line.EnabledCheckbox:SetValue(false)
                        line.ColorDropdown.colorTable = nil
                        line.ColorDropdown:Select(platerInternal.NoColor)

                        line:RefreshColor()

                        if (isFromLastCombat) then
                            line.hasHighlight = true
                            line:SetBackdropColor(unpack(highlightColorLastCombat))
                        end
                    end

                    line.EnabledCheckbox:SetFixedParameter(npcID)
                else
                    line:Hide()
                end
            end
        end
    end

    --create scroll
    local spells_scroll = DF:CreateScrollBox(colorsFrame, "$parentColorsScroll", scrollBox_Refresh, {}, scroll_width, scroll_height, scroll_lines, scroll_line_height) --name is ColorsScroll but variable is spells_scroll
    DF:ReskinSlider(spells_scroll)
    spells_scroll:SetPoint("topleft", colorsFrame, "topleft", 10, scrollY)
    colorsFrame.SpellsScroll = spells_scroll

    colorsFrame.ModelFrame:SetFrameLevel(spells_scroll:GetFrameLevel() + 20)

    spells_scroll:SetScript("OnShow", function(self)
        if (self.LastRefresh and self.LastRefresh+0.5 > GetTime()) then
            return
        end
        self.LastRefresh = GetTime()

        local newData = {}

        for npcID, npcIDTable in pairs(DB_NPCID_CACHE) do
            table.insert(newData, {
                npcID,
                npcIDTable[1], --name
                npcIDTable[2], --zone
            })
        end

        self.CachedTable = nil
        self.SearchCachedTable = nil

        self:SetData(newData)
        self:Refresh()
    end)

    --create lines
    for i = 1, scroll_lines do
        spells_scroll:CreateLine(scrollBox_CreateLine)
    end

    --create search box
        local latestSearchUpdate = 0
        function colorsFrame.OnSearchBoxTextChanged()
            local text = colorsFrame.AuraSearchTextEntry:GetText()
            if (text and string.len(text) > 0) then
                sSearchingFor = text:lower()
            else
                sSearchingFor = nil
            end

            if (latestSearchUpdate + 0.01 > GetTime()) then
                DF.Schedules.AfterById(0.05, colorsFrame.OnSearchBoxTextChanged, "colorsFrame.OnSearchBoxTextChanged")
                return
            end

            latestSearchUpdate = GetTime()
            spells_scroll.offset = 0
            spells_scroll:OnVerticalScroll(spells_scroll.offset)
            spells_scroll:Refresh()
        end

        local aura_search_textentry = DF:CreateTextEntry(colorsFrame, function()end, 150, 20, "AuraSearchTextEntry", _, _, options_dropdown_template)
        aura_search_textentry:SetPoint("bottomright", colorsFrame.ModelFrame, "topright", 0, 21)
        aura_search_textentry:SetHook("OnChar",		colorsFrame.OnSearchBoxTextChanged)
        aura_search_textentry:SetHook("OnTextChanged", 	colorsFrame.OnSearchBoxTextChanged)
        local aura_search_label = DF:CreateLabel(aura_search_textentry, "search", DF:GetTemplate("font", "ORANGE_FONT_TEMPLATE"))
        aura_search_label:SetPoint("left", aura_search_textentry, "left", 4, 0)
        aura_search_label.fontcolor = "gray"
        aura_search_label.color = {.5, .5, .5, .3}
        aura_search_textentry.tooltip = "|cFFFFFF00Npc Name|r or |cFFFFFF00Zone Name|r"
        aura_search_textentry:SetFrameLevel(colorsFrame.Header:GetFrameLevel() + 20)

        --clear search button
        local clear_search_button = DF:CreateButton(colorsFrame, function() aura_search_textentry:SetText(""); aura_search_textentry:ClearFocus() end, 20, 20, "", -1)
        clear_search_button:SetPoint("right", aura_search_textentry, "right", 5, 0)
        clear_search_button:SetAlpha(.7)
        clear_search_button:SetIcon([[Interface\Glues\LOGIN\Glues-CheckBox-Check]])
        clear_search_button.icon:SetDesaturated(true)
        clear_search_button:SetFrameLevel(colorsFrame.Header:GetFrameLevel() + 21)

        function colorsFrame.RefreshScroll(refreshSpeed)
            spells_scroll:Hide()
            C_Timer.After(refreshSpeed or .01, function() spells_scroll:Show() end)
        end

    --help button
        local help_button = DF:CreateButton(colorsFrame, function()end, 70, 20, "help", -1, nil, nil, nil, nil, nil, DF:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate("font", "PLATER_BUTTON"))
        help_button:SetPoint("right", aura_search_textentry, "left", -2, 0)
        help_button.tooltip = "|cFFFFFF00Help:|r\n\n- Run dungeons and raids to fill the npc list.\n\n- |cFFFFEE00Scripts Only|r aren't automatically applied, scripts can import the color set here using |cFFFFEE00local colorTable = Plater.GetNpcColor(unitFrame)|r.\n\n- Colors set here override threat colors.\n\n- Colors set in scripts override colors set here.\n\n- |TInterface\\AddOns\\Plater\\media\\star_empty_64:16:16|t icon indicates the color is favorite, so you can use it across dungeons to keep color consistency."
        help_button:SetFrameLevel(colorsFrame.Header:GetFrameLevel() + 20)

    --refresh button
        local refresh_button = DF:CreateButton(colorsFrame, function() colorsFrame.RefreshScroll() end, 70, 20, "refresh", -1, nil, nil, nil, nil, nil, DF:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate("font", "PLATER_BUTTON"))
        refresh_button:SetPoint("right", help_button, "left", -2, 0)
        refresh_button.tooltip = "refresh the list the npcs"
        refresh_button:SetFrameLevel(colorsFrame.Header:GetFrameLevel() + 20)

        local create_import_box = function(parent, mainFrame)
            --import and export string text editor

            local edit_script_size = {620, 431}
            --text editor
            local luaeditor_backdrop_color = {.2, .2, .2, .5}
            local luaeditor_border_color = {0, 0, 0, 1}
            local edit_script_size = {620, 431}
            local buttons_size = {120, 20}

            local import_text_editor = DF:NewSpecialLuaEditorEntry(parent, edit_script_size[1], edit_script_size[2], "ImportEditor", "$parentImportEditor", true)
            import_text_editor:SetBackdrop({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
            import_text_editor:SetBackdropBorderColor(unpack(luaeditor_border_color))
            import_text_editor:SetBackdropColor(.3, .3, .3, 1)
            import_text_editor:Hide()
            import_text_editor:SetFrameLevel(parent:GetFrameLevel()+100)
            DF:ReskinSlider(import_text_editor.scroll)

            local bg = import_text_editor:CreateTexture(nil, "background")
            bg:SetColorTexture(0.1, 0.1, 0.1, .9)
            bg:SetAllPoints()

            local block_mouse_frame = CreateFrame("frame", nil, import_text_editor, BackdropTemplateMixin and "BackdropTemplate")
            block_mouse_frame:SetFrameLevel(block_mouse_frame:GetFrameLevel()-5)
            block_mouse_frame:SetAllPoints()
            block_mouse_frame:SetScript("OnMouseDown", function()
                import_text_editor:SetFocus(true)
            end)

            --hide the code editor when the import text editor is shown
            import_text_editor:SetScript("OnShow", function()
                --mainFrame.CodeEditorLuaEntry:Hide()
            end)

            --show the code editor when the import text editor is hide
            import_text_editor:SetScript("OnHide", function()
                --mainFrame.CodeEditorLuaEntry:Show()
            end)

            mainFrame.ImportTextEditor = import_text_editor

            --import info
            local info_import_label = DF:CreateLabel(import_text_editor, "", DF:GetTemplate("font", "ORANGE_FONT_TEMPLATE"))
            info_import_label:SetPoint("bottomleft", import_text_editor, "topleft", 0, 2)
            mainFrame.ImportTextEditor.TextInfo = info_import_label

            --import button
            local okay_import_button = DF:CreateButton(import_text_editor, mainFrame.ImportColors, buttons_size[1], buttons_size[2], "Okay", -1, nil, nil, nil, nil, nil, DF:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate("font", "PLATER_BUTTON"))
            okay_import_button:SetIcon([[Interface\BUTTONS\UI-Panel-BiggerButton-Up]], 20, 20, "overlay", {0.1, .9, 0.1, .9})
            okay_import_button:SetPoint("topright", import_text_editor, "bottomright", 0, 1)

            --cancel button
            local cancel_import_button = DF:CreateButton(import_text_editor, function() mainFrame.ImportTextEditor:Hide() end, buttons_size[1], buttons_size[2], "Cancel", -1, nil, nil, nil, nil, nil, DF:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate("font", "PLATER_BUTTON"))
            cancel_import_button:SetIcon([[Interface\BUTTONS\UI-Panel-MinimizeButton-Up]], 20, 20, "overlay", {0.1, .9, 0.1, .9})
            cancel_import_button:SetPoint("right", okay_import_button, "left", -2, 0)

            import_text_editor.OkayButton = okay_import_button
            import_text_editor.CancelButton = cancel_import_button
        end

        -- ~importcolor
        function colorsFrame.ImportColors()
            --get the colors from the text field and code it to import

            if (colorsFrame.IsImporting) then
                local text = colorsFrame.ImportEditor:GetText()
                text = DF:Trim(text)
                local importedColorData = Plater.DecompressData(text, "print")

                --exported npc colors has this member to identify the exported data
                if (importedColorData and importedColorData.NpcColor) then
                    --this variable stores which npcs has a color enabled
                    local dbColors = Plater.db.profile.npc_colors
                    --table storing all npcs already detected inside dungeons and raids
                    local allNpcsDetectedTable = Plater.db.profile.npc_cache
                    local allNpcsRenamed = Plater.db.profile.npcs_renamed

                    --the uncompressed table is a numeric table of tables
                    for i, colorTable in pairs(importedColorData) do
                        --check integrity
                        if (type(colorTable) == "table") then
                            local npcID, scriptOnly, colorName, npcName, zoneName, renamedName = unpack(colorTable)
                            --check values integrity
                            if (npcID and colorName and npcName and zoneName) then
                                if (type(colorName) == "string" and type(npcName) == "string" and type(zoneName) == "string") then
                                    if (type(npcID) == "number" and type(scriptOnly) == "boolean") then
                                        local colorTable = dbColors[npcID]
                                        if (not colorTable) then
                                            colorTable = {}
                                            dbColors[npcID] = colorTable
                                        end

                                        dbColors[npcID][1] = true --the color for the npc is enabled
                                        dbColors[npcID][2] = false --the color is only used in scripts(deprecated)
                                        dbColors[npcID][3] = colorName --string with the color name

                                        --add this npcs in the npcs detected table as well
                                        local npcInfoTable = allNpcsDetectedTable[npcID]
                                        if (not npcInfoTable) then
                                            npcInfoTable = {}
                                            allNpcsDetectedTable[npcID] = npcInfoTable
                                        end

                                        allNpcsDetectedTable[npcID][1] = allNpcsDetectedTable[npcID][1] or npcName
                                        allNpcsDetectedTable[npcID][2] = allNpcsDetectedTable[npcID][2] or zoneName

                                        allNpcsRenamed[npcID] = renamedName
                                    end
                                end
                            end
                        end
                    end

                    colorsFrame.RefreshScroll()
                    Plater:Msg("npc colors imported.")

                else
                    Plater.SendScriptTypeErrorMsg(importedColorData)
                end
            end

            colorsFrame.ImportEditor:Hide()

        end

    --import and export buttons
        local import_func = function()
            if (not colorsFrame.ImportEditor) then
                create_import_box(colorsFrame, colorsFrame)
            end

            colorsFrame.IsExporting = nil
            colorsFrame.IsImporting = true

            colorsFrame.ImportEditor:Show()
            colorsFrame.ImportEditor:SetPoint("topleft", colorsFrame.Header, "topleft")
            colorsFrame.ImportEditor:SetPoint("bottomright", colorsFrame, "bottomright", -17, 37)

            colorsFrame.ImportEditor:SetText("")
            C_Timer.After(.1, function()
                colorsFrame.ImportEditor.editbox:HighlightText()
                colorsFrame.ImportEditor.editbox:SetFocus(true)
            end)
        end
        local import_button = DF:CreateButton(colorsFrame, import_func, 70, 20, L["IMPORT"], -1, nil, nil, nil, nil, nil, DF:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate("font", "PLATER_BUTTON"))
        import_button:SetPoint("right", refresh_button, "left", -2, 0)
        import_button:SetFrameLevel(colorsFrame.Header:GetFrameLevel() + 20)

        local export_func = function()
            if (not colorsFrame.ImportEditor) then
                create_import_box(colorsFrame, colorsFrame)
            end

            --build the list of colors to be exported
            --~exportcolor ~export color table to string
            --this is the table which will be compress with libdeflate
            local exportedTable = {
                NpcColor = true, --identify this table as a npc color table
            }

            --check if the user is searching npcs, build the export table only using the npcs shown in the result
            if (sSearchingFor and sSearchingFor ~= "" and spells_scroll.SearchCachedTable) then
                local dbColors = Plater.db.profile.npc_colors

                for i, searchResult in ipairs(spells_scroll.SearchCachedTable) do

                    local _, _, npcName, zoneName, npcID = unpack(searchResult)
                    local infoTable = dbColors[npcID]

                    if (infoTable) then
                        local enabled1 = infoTable[1] --boolean, this is the overall enabled
                        local enabled2 = infoTable[2] --boolean, if this is true, this color is only used for scripts
                        local colorID = infoTable[3] --string, the color name

                        --build a table to store one the npc and insert the table inside the main table which will be compressed
                        --only add the npc if it is enabled in the color panel
                        if (enabled1) then
                            local renamedName = Plater.db.profile.npcs_renamed[npcID]
                                                    --number| boolean |string  |string  |string   |string
                            table.insert(exportedTable, {npcID, enabled2, colorID, npcName, zoneName, renamedName})
                        end
                    end
                end

            else
                --table storing all npcs already detected inside dungeons and raids, need it to get the zone name
                local allNpcsDetectedTable = Plater.db.profile.npc_cache

                --make the list
                for npcID, infoTable in pairs(Plater.db.profile.npc_colors) do
                    local enabled1 = infoTable[1] --boolean, this is the overall enabled
                    local enabled2 = infoTable[2] --boolean, if this is true, this color is only used for scripts
                    local colorID = infoTable[3] --string, the color name

                    local npcName = allNpcsDetectedTable[npcID] and allNpcsDetectedTable[npcID][1]
                    local zoneName = allNpcsDetectedTable[npcID] and allNpcsDetectedTable[npcID][2]

                    --build a table to store one the npc and insert the table inside the main table which will be compressed
                    --only add the npc if it is enabled in the color panel
                    if (enabled1 and npcName and zoneName) then
                        local renamedName = Plater.db.profile.npcs_renamed[npcID]
                                                    --number| boolean |string  |string  |string   |string
                            table.insert(exportedTable, {npcID, enabled2, colorID, npcName, zoneName, renamedName})
                    end
                end
            end

            --check if there's at least 1 npc
            if (#exportedTable < 1) then
                Plater:Msg(L["OPTIONS_NOTHING_TO_EXPORT"])
                return
            end

            colorsFrame.IsExporting = true
            colorsFrame.IsImporting = nil

            colorsFrame.ImportEditor:Show()
            colorsFrame.ImportEditor:SetPoint("topleft", colorsFrame.Header, "topleft")
            colorsFrame.ImportEditor:SetPoint("bottomright", colorsFrame, "bottomright", -17, 37)

            --compress data and show it in the text editor
            local data = Plater.CompressData(exportedTable, "print")
            colorsFrame.ImportEditor:SetText(data or "failed to export color table")

            C_Timer.After(.1, function()
                colorsFrame.ImportEditor.editbox:HighlightText()
                colorsFrame.ImportEditor.editbox:SetFocus(true)
            end)
        end

        local exportButton = DF:CreateButton(colorsFrame, export_func, 70, 20, L["EXPORT"], -1, nil, nil, nil, nil, nil, DF:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate("font", "PLATER_BUTTON"))
        exportButton:SetPoint("right", import_button, "left", -2, 0)
        exportButton:SetFrameLevel(colorsFrame.Header:GetFrameLevel() + 20)

    --disable all button
        local disableAllColors = function()
            DF:ShowPromptPanel("Confirm disable all colors?", function()
                for npcId, colorTable in pairs(Plater.db.profile.npc_colors) do
                    colorTable[1] = false
                    colorTable[2] = false
                end
                colorsFrame.RefreshScroll()
            end,
            function()end, true, 400, "PLATER_DISABLE_ALL_COLORS")
        end

        local disableall_button = DF:CreateButton(colorsFrame, disableAllColors, 140, 20, "Disable All Colors", -1, nil, nil, nil, nil, nil, DF:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate("font", "PLATER_BUTTON"))
        disableall_button:SetPoint("bottomleft", spells_scroll, "bottomleft", 1, 0)
        disableall_button:SetFrameLevel(colorsFrame.Header:GetFrameLevel() + 20)

    --set all scripts only
        local setAllAsScriptOnly = function()
            for npcId, colorTable in pairs(Plater.db.profile.npc_colors) do
                if (colorTable[1]) then
                    colorTable[2] = true
                end
            end
            colorsFrame.RefreshScroll()
        end

        local scriptsall_button = DF:CreateButton(colorsFrame, setAllAsScriptOnly, 200, 20, "Set All Enabled as 'Scripts Only'", -1, nil, nil, nil, nil, nil, DF:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate("font", "PLATER_BUTTON"))
        scriptsall_button:SetPoint("left", disableall_button, "right", 0, 0)
        scriptsall_button:SetFrameLevel(colorsFrame.Header:GetFrameLevel() + 20)
        scriptsall_button:Hide()

        local addnpc_text = DF:CreateLabel(scriptsall_button, "Use '/plater addnpc' to add a npc in open world.")
        addnpc_text.fontsize = 12
        addnpc_text.fontcolor = "gray"
        addnpc_text:SetPoint("left", scriptsall_button, "right", 10, 0)

    -- buttons backdrop
        local backdropFoot = CreateFrame("frame", nil, spells_scroll, BackdropTemplateMixin and "BackdropTemplate")
        backdropFoot:SetHeight(20)
        backdropFoot:SetPoint("bottomleft", spells_scroll, "bottomleft", 0, 0)
        backdropFoot:SetPoint("bottomright", colorsFrame.ModelFrame, "bottomleft", -3, 0)
        backdropFoot:SetBackdrop({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
        backdropFoot:SetBackdropColor(.52, .52, .52, .7)
        backdropFoot:SetBackdropBorderColor(0, 0, 0, 1)
        backdropFoot:SetFrameLevel(colorsFrame.Header:GetFrameLevel() + 19)

    --empty label
        local empty_text = DF:CreateLabel(colorsFrame, "this list is automatically filled when\nyou see enemies inside a dungeon or raid\n\nthen you may select colors here or directly\nin the dropdown below the nameplate")
        empty_text.fontsize = 24
        empty_text.align = "|"
        empty_text:SetPoint("center", spells_scroll, "center", -colorsFrame.ModelFrame:GetWidth() / 2, 0)
        colorsFrame.EmptyText = empty_text

    --create the description
    colorsFrame.TitleDescText = Plater:CreateLabel(colorsFrame, "For raid and dungeon npcs, they are added into the list after you see them for the first time", 10, "silver")
    colorsFrame.TitleDescText:SetPoint("bottomleft", spells_scroll, "topleft", 0, 26)

    function colorsFrame.RefreshDropdowns()
        colorsFrame.cachedColorTable = nil
        colorsFrame.cachedColorTableNameplate = nil

        for _, plateFrame in ipairs(Plater.GetAllShownPlates()) do
            if (plateFrame.unitFrame.colorSelectionDropdown) then
                --if (Plater.ZoneInstanceType ~= "party" and Plater.ZoneInstanceType ~= "raid") then
                --	plateFrame.unitFrame.colorSelectionDropdown:Hide()
                --else
                    local npcID = plateFrame.unitFrame.colorSelectionDropdown:GetParent()[MEMBER_NPCID]
                    plateFrame.unitFrame.colorSelectionDropdown:Select(DB_NPCID_COLORS[npcID] and DB_NPCID_COLORS[npcID][1] and DB_NPCID_COLORS[npcID][3] or "white")
                    plateFrame.unitFrame.colorSelectionDropdown:Show()
                --end
            end
        end
    end

    colorsFrame:SetScript("OnShow", function()
        local function hex(num)
            local hexstr = '0123456789abcdef'
            local s = ''
            while num > 0 do
                local mod = math.fmod(num, 16)
                s = string.sub(hexstr, mod+1, mod+1) .. s
                num = math.floor(num / 16)
            end
            if s == '' then s = '00' end
            if (string.len(s) == 1) then
                s = "0"..s
            end
            return s
        end

        local function sort_color(t1, t2)
            return t1[1][3] > t2[1][3]
        end

        local make_dropdown = function(plateFrame)
            local line_select_color_dropdown = function(self, npcID, color)

                local unitFrame = self:GetParent()
                local npcID = unitFrame[MEMBER_NPCID]

                if (npcID) then
                    if (not DB_NPCID_CACHE[npcID]) then
                        DB_NPCID_CACHE[npcID] = {unitFrame.PlateFrame[MEMBER_NAME], Plater.ZoneName}

                        if (PlaterOptionsPanelFrame and PlaterOptionsPanelFrame:IsShown()) then
                            PlaterOptionsPanelContainerColorManagementColorsScroll:Hide()
                            C_Timer.After(.2, function()
                                PlaterOptionsPanelContainerColorManagementColorsScroll:Show()
                            end)
                        end
                    end

                    if (not DB_NPCID_COLORS[npcID]) then
                        DB_NPCID_COLORS[npcID] = {true, false, "blue"}
                    end

                    DB_NPCID_COLORS[npcID][1] = true
                    DB_NPCID_COLORS[npcID][3] = color

                    local checkBox = colorsFrame.CheckBoxCache[npcID]
                    if (checkBox) then
                        checkBox:SetValue(true)
                        checkBox:GetParent():RefreshColor(color)
                    end

                    Plater.RefreshDBLists()
                    Plater.ForceTickOnAllNameplates()

                    colorsFrame.RefreshDropdowns()

                    colorsFrame.RefreshScroll()
                end
            end

            local line_refresh_color_dropdown = function(self)
                if (not self:GetParent()[MEMBER_NPCID]) then
                    return {}
                end
                --dropdrop down below a nameplate when the Npc Colors tab is open
                if (not colorsFrame.cachedColorTableNameplate) then
                    local colorsAdded = {}
                    local colorsAddedT = {}
                    local t = {}

                    --add colors already in use first
                    --get colors that are already in use and pull them to be the first colors in the dropdown
                    for npcID, npcColorTable in pairs(DB_NPCID_COLORS) do
                        local color = npcColorTable[3]
                        if (not colorsAdded[color]) then
                            colorsAdded[color] = true
                            local r, g, b = DF:ParseColors(color)
                            table.insert(colorsAddedT, {{r, g, b}, color, hex(r * 255) .. hex(g * 255) .. hex(b * 255)})
                        end
                    end
                    --table.sort(colorsAddedT, sort_color)

                    for index, colorTable in ipairs(colorsAddedT) do
                        local colortable = colorTable[1]
                        local colorname = colorTable[2]
                        table.insert(t, {label = " " .. colorname, value = colorname, color = colortable, onclick = line_select_color_dropdown,
                        statusbar = [[Interface\Tooltips\UI-Tooltip-Background]],
                        icon = [[Interface\AddOns\Plater\media\star_empty_64]],
                        iconcolor = {1, 1, 1, .6},
                        })
                    end

                    --all colors
                    local allColors = {}
                    for colorName, colorTable in pairs(DF:GetDefaultColorList()) do
                        if (not colorsAdded[colorName]) then
                            table.insert(allColors, {colorTable, colorName, hex(colorTable[1]*255) .. hex(colorTable[2]*255) .. hex(colorTable[3]*255)})
                        end
                    end
                    --table.sort(allColors, sort_color)

                    for index, colorTable in ipairs(allColors) do
                        local colortable = colorTable[1]
                        local colorname = colorTable[2]
                        table.insert(t, {label = colorname, value = colorname, color = colortable, onclick = line_select_color_dropdown})
                    end

                    colorsFrame.cachedColorTableNameplate = t
                    return t
                else
                    return colorsFrame.cachedColorTableNameplate
                end

            end

            local dropdown = DF:CreateDropDown(plateFrame.unitFrame, line_refresh_color_dropdown, 1, headerTable[5].width, 20, nil, nil, DF:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))
            dropdown:SetHeight(14)
            dropdown.widget.arrowTexture:SetSize(22, 22)
            dropdown.widget.arrowTexture2:Hide()

            plateFrame.unitFrame.colorSelectionDropdown = dropdown

            dropdown:SetPoint("topleft", plateFrame.unitFrame, "bottomleft", 0, 0)
            dropdown:SetPoint("topright", plateFrame.unitFrame, "bottomright", 0, 0)

            dropdown:SetHook("OnShow", function()
                C_Timer.After(0.1, function()
                    local npcID = dropdown:GetParent()[MEMBER_NPCID]
                    dropdown:Select(DB_NPCID_COLORS[npcID] and DB_NPCID_COLORS[npcID][1] and DB_NPCID_COLORS[npcID][3] or "white")
                end)
            end)

            local npcID = dropdown:GetParent()[MEMBER_NPCID]
            dropdown:Select(DB_NPCID_COLORS[npcID] and DB_NPCID_COLORS[npcID][1] and DB_NPCID_COLORS[npcID][3] or "white")

            --reset button
            local reset = function()
                local npcID = dropdown:GetParent()[MEMBER_NPCID]
                if (DB_NPCID_COLORS[npcID]) then

                    local checkBox = colorsFrame.CheckBoxCache[npcID]
                    if (checkBox) then
                        checkBox:SetValue(false)
                        checkBox:GetParent():RefreshColor()
                    end

                    DB_NPCID_COLORS[npcID][1] = false
                    DB_NPCID_COLORS[npcID][2] = false

                    Plater.RefreshDBLists()
                    Plater.ForceTickOnAllNameplates()
                    Plater.UpdateAllNameplateColors()

                    colorsFrame.RefreshDropdowns()

                    dropdown:Select("white")

                    colorsFrame.RefreshScroll()
                end
            end

            local clear_color_button = DF:CreateButton(dropdown, function() reset() end, 20, 20, "", -1)
            clear_color_button:SetPoint("left", dropdown, "right", 0, 0)
            clear_color_button:SetAlpha(.8)
            clear_color_button:SetIcon([[Interface\Glues\LOGIN\Glues-CheckBox-Check]])
        end

        for _, plateFrame in ipairs(Plater.GetAllShownPlates()) do
            if (not plateFrame.unitFrame.colorSelectionDropdown) then
                make_dropdown(plateFrame)
            end
        end

        colorsFrame.RefreshDropdowns()

        colorsFrame:SetScript("OnEvent", function(self, event, unitBarId)
            local plateFrame = C_NamePlate.GetNamePlateForUnit(unitBarId)
            if (not plateFrame) then
                return
            end

            if (event == "NAME_PLATE_UNIT_REMOVED") then
                if (plateFrame.unitFrame.colorSelectionDropdown) then
                    plateFrame.unitFrame.colorSelectionDropdown:Hide()
                end

            elseif (event == "NAME_PLATE_UNIT_ADDED") then

                if (Plater.ZoneInstanceType ~= "party" and Plater.ZoneInstanceType ~= "raid") then
                    --return
                end

                local dropdown = plateFrame.unitFrame.colorSelectionDropdown
                if (not dropdown) then
                    make_dropdown(plateFrame)
                    dropdown = plateFrame.unitFrame.colorSelectionDropdown
                end

                C_Timer.After(0.1, function()
                    local npcID = dropdown:GetParent()[MEMBER_NPCID]
                    dropdown:Select(DB_NPCID_COLORS[npcID] and DB_NPCID_COLORS[npcID][1] and DB_NPCID_COLORS[npcID][3] or "white")
                end)

                dropdown:Show()
            end
        end)

        colorsFrame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
        colorsFrame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
    end)

    colorsFrame:SetScript("OnHide", function()
        colorsFrame:UnregisterEvent("NAME_PLATE_UNIT_ADDED")
        colorsFrame:UnregisterEvent("NAME_PLATE_UNIT_REMOVED")

        if (colorsFrame.ImportEditor) then
            colorsFrame.ImportEditor:Hide()
            colorsFrame.ImportEditor.IsExporting = nil
            colorsFrame.ImportEditor.IsImporting = nil
        end

        for _, plateFrame in ipairs(Plater.GetAllShownPlates()) do
            if (plateFrame.unitFrame.colorSelectionDropdown) then
                plateFrame.unitFrame.colorSelectionDropdown:Hide()
            end
        end
    end)
end