
local addonName, platerInternal = ...
---@diagnostic disable-next-line: undefined-field
local Plater = _G.Plater
local GameCooltip = GameCooltip2
---@type detailsframework
local detailsFramework = DetailsFramework
local _

local DEBUG_OPEN_AT_LOGIN = false

---@class plater_designer : table

platerInternal.Designer = {}
local designer = platerInternal.Designer

designer.Options = {}
local options = designer.Options

local editorOptionsTextTemplate = {
    size = 11,
    color = "gold",
}

local editorOptionsSliderTemplate = {
    thumbwidth = 20,
}

--all objects that uses only settings that are within the plate_config table
---@type df_editor_objectinfo[]
local plateConfigObjectsInfo = {}

local ACTORTYPE_FRIENDLY_PLAYER = platerInternal.VarSharing.ACTORTYPE_FRIENDLY_PLAYER
local ACTORTYPE_FRIENDLY_NPC = platerInternal.VarSharing.ACTORTYPE_FRIENDLY_NPC
local ACTORTYPE_ENEMY_PLAYER = platerInternal.VarSharing.ACTORTYPE_ENEMY_PLAYER
local ACTORTYPE_ENEMY_NPC = platerInternal.VarSharing.ACTORTYPE_ENEMY_NPC
local ACTORTYPE_PLAYER = platerInternal.VarSharing.ACTORTYPE_PLAYER

local MEMBER_UNITID = platerInternal.VarSharing.MEMBER_UNITID
local MEMBER_GUID = platerInternal.VarSharing.MEMBER_GUID
local MEMBER_NPCID = platerInternal.VarSharing.MEMBER_NPCID
local MEMBER_QUEST = platerInternal.VarSharing.MEMBER_QUEST
local MEMBER_REACTION = platerInternal.VarSharing.MEMBER_REACTION
local MEMBER_RANGE = platerInternal.VarSharing.MEMBER_RANGE
local MEMBER_NOCOMBAT = platerInternal.VarSharing.MEMBER_NOCOMBAT
local MEMBER_NAME = platerInternal.VarSharing.MEMBER_NAME
local MEMBER_NAMELOWER = platerInternal.VarSharing.MEMBER_NAMELOWER
local MEMBER_TARGET = platerInternal.VarSharing.MEMBER_TARGET

local plateFrame

---profile.plate_config[enemynpc, friendlynpc, enemyplayer, friendlyplayer]
local subTablePath = "enemynpc"

local getProfileTable = function()
    return Plater.db.profile.plate_config[subTablePath]
end

local dv = function(f) detailsFramework:DebugVisibility(f) end

---debug tags to help identify frames, the string passed is always the variable name for the frame
---@param f frame
---@param n string
local createFrameTag = function (f,n)
    do return end
    local t = f:CreateTexture (nil, "overlay")
    local fs = f:CreateFontString (nil, "overlay", "GameFontNormalSmall")

    t:SetSize(140, 12)
    t:SetColorTexture (1, 1, 0, 1)
    t:SetPoint ("bottomleft", f, "topleft", 0, 0)

    fs:SetPoint ("left", t, "left", 0, 0)
    fs:SetText (n)
    fs:SetTextColor (0, 0, 0, 1)


end

function Plater.ToggleDesignerWindow()
    if (Plater.DesignerWindow and Plater.DesignerWindow:IsShown()) then
        Plater.DesignerWindow:Hide()
        return
    end

    Plater.OpenDesignerWindow()
end

function Plater.OpenDesignerWindow()
    if (Plater.DesignerWindow) then
        Plater.DesignerWindow:Show()
        return
    end

    Plater.CreateDesignerWindow()
end

local a = CreateFrame("frame")
a:RegisterEvent("PLAYER_LOGIN")
a:SetScript("OnEvent", function(self, event, ...)
    if DEBUG_OPEN_AT_LOGIN then
        Plater.OpenDesignerWindow()
    end
    self:UnregisterEvent("PLAYER_LOGIN")
end)

function Plater.CreateDesignerWindow(tabFrame, tabContainer, parent)
    local gName = "PlaterDsgn"

    local isCastBarSelected = false

    local startX, startY, heightSize = 10, platerInternal.optionsYStart, 755

    --tab background using a rounded panel | need to make a preset for this, atm it is declaring each time the same table
    local roundedPanelOptions = {
        scale = 1,
        width = tabFrame:GetWidth() - 4,
        height = tabFrame:GetHeight() - 4 - math.abs(startY),
        roundness = 8,
    }

    ---@type df_roundedpanel
    --local editorMainFrame = detailsFramework:CreateRoundedPanel(tabFrame, gName, roundedPanelOptions)
    local editorMainFrame = CreateFrame("Frame", gName, tabFrame)
    --editorMainFrame:SetFrameStrata("FULLSCREEN")
    --local editorMainFrame = CreateFrame("frame", gName, UIParent)

    Plater.DesignerWindow = editorMainFrame

    --detailsFramework:MakeDraggable(editorMainFrame)
    --editorMainFrame:EnableMouse(true)
    createFrameTag(editorMainFrame, "editorMainFrame")
    editorMainFrame:SetSize(roundedPanelOptions.width, roundedPanelOptions.height)
    --editorMainFrame:SetPoint ("center", UIParent, "center", -100, 0)
    editorMainFrame:SetPoint("topleft", tabFrame, "topleft", 0, startY + 24)

    --create the widget editor
    local editorOptions = {
        width = editorMainFrame:GetWidth() - 10,
        create_object_list = true,
        object_list_width = 200,
        object_list_height = editorMainFrame:GetHeight() - 15,
        object_list_lines = 20,
        object_list_line_height = 20,
        text_template = editorOptionsTextTemplate,
        slider_template = editorOptionsSliderTemplate,
        no_anchor_points = true,
        start_editing_callback = function(layoutEditor, objectInfo)
            if (objectInfo.id:match("^CAST")) then
                isCastBarSelected = true
                Plater.StartCastBarTest()
            else
                isCastBarSelected = false
                Plater.StopCastBarTest()
            end
        end,
        selection_texture = "Interface\\AddOns\\Plater\\images\\selection_corner.png",
    }

    --Plater_Designer_Objects.lua
    --create two tables to map the layout settings for the editor
    designer.CreateSettings(editorMainFrame)

    --the frame in the middle of the tab, the the settings for the selected widget are placed
    ---@type df_editor
    local layoutEditor = detailsFramework:CreateEditor(editorMainFrame, "Plater_LayoutEditor_", editorOptions)
    createFrameTag(layoutEditor, "layoutEditor")
    layoutEditor:SetPoint("topleft", editorMainFrame, "topleft", 5, -16)
    layoutEditor:SetPoint("bottomleft", editorMainFrame, "bottomleft", 5, 5)
    layoutEditor:EnableMouse(false)
    layoutEditor:SetFrameLevel(editorMainFrame:GetFrameLevel() + 10)
    --layoutEditor:SetFrameStrata("HIGH")

    function designer.UpdateAllNameplates()
        for _, thisPlateFrame in ipairs(Plater.GetAllShownPlates()) do
            if thisPlateFrame.namePlateUnitToken or thisPlateFrame.unitToken then
                platerInternal.Events.GetEventFunction("NAME_PLATE_UNIT_ADDED")("NAME_PLATE_UNIT_ADDED", thisPlateFrame.namePlateUnitToken or thisPlateFrame.unitToken)
            end
        end
    end

    --create close button using the framework
    --local closeButton = detailsFramework:CreateCloseButton(editorMainFrame)
    --closeButton:SetPoint("topright", editorMainFrame, "topright", -3, -3)

    local canvasFrame = layoutEditor:GetCanvasScrollBox()
    canvasFrame:EnableMouse(false)

    local objectSelector = layoutEditor:GetObjectSelector()
    local optionsFrame = layoutEditor:GetOptionsFrame()
    optionsFrame:AdjustPointsOffset(-2, 0)

    --create a frame to guide the setting points on the empty area at the right side of the main frame, which is reserved for the preview
    local previewNameplateFrame = CreateFrame("Frame", "$parentGuideFrame", layoutEditor)
    createFrameTag(previewNameplateFrame, "previewPlateFrame")
    previewNameplateFrame:SetPoint("bottomleft", canvasFrame, "bottomright", 30, 0)
    previewNameplateFrame:SetPoint("topright", editorMainFrame, "topright", -5, -5)
    previewNameplateFrame:SetFrameLevel(layoutEditor:GetFrameLevel() + 1)

    local findWidgetExtraOptionTable = function(sectionName, tableName)
        local extraOptionsSection = options.WidgetSettingsExtraOptions[sectionName]
        if (extraOptionsSection) then
            for i = 1, #extraOptionsSection do
                local widgetExtraOption = extraOptionsSection[i]
                local optionCategoryName = widgetExtraOption.tableName
                if (optionCategoryName == tableName) then
                    return widgetExtraOption
                end
            end
        end
    end

    --plater only
    local onClickSelectPlateConfigOption = function(self, fixedParameter, newSubTablePath)
        subTablePath = newSubTablePath

        --update the paths in the mapping tables
        --cast bar:
        --options.WidgetSettingsMapTables.CastBar.width = "plate_config." .. subTablePath .. ".cast_incombat[1]"
        --options.WidgetSettingsMapTables.CastBar.height = "plate_config." .. subTablePath .. ".cast_incombat[2]"
        --local castOutOfCombatWidth = findWidgetExtraOptionTable("CastBar", "out_of_combat_cast_width")
        --castOutOfCombatWidth.key = "plate_config." .. subTablePath .. ".cast[1]"
        --local castOutOfCombatHeight = findWidgetExtraOptionTable("CastBar", "out_of_combat_cast_height")
        --castOutOfCombatHeight.key = "plate_config." .. subTablePath .. ".cast[2]"
        --local castBarOffsetX = findWidgetExtraOptionTable("CastBar", "castbar_offset_x")
        --castBarOffsetX.key = "plate_config." .. subTablePath .. ".castbar_offset_x"
        --local castBarOffsetY = findWidgetExtraOptionTable("CastBar", "castbar_offset_y")
        --castBarOffsetY.key = "plate_config." .. subTablePath .. ".castbar_offset"

        --health bar:
        --options.WidgetSettingsMapTables.HealthBar.width = "plate_config." .. subTablePath .. ".health_incombat[1]"
        --options.WidgetSettingsMapTables.HealthBar.height = "plate_config." .. subTablePath .. ".health_incombat[2]"
        --local healthOutOfCombatWidth = findWidgetExtraOptionTable("HealthBar", "out_of_combat_health_width")
        --healthOutOfCombatWidth.key = "plate_config." .. subTablePath .. ".health[1]"
        --local healthOutOfCombatHeight = findWidgetExtraOptionTable("HealthBar", "out_of_combat_health_height")
        --healthOutOfCombatHeight.key = "plate_config." .. subTablePath .. ".health[2]"

        --

        for index, objectInfo in ipairs(plateConfigObjectsInfo) do
            layoutEditor:UpdateProfileSubTablePath(objectInfo, subTablePath)
        end

        layoutEditor:Refresh()
    end

    ---@type dropdownoption[]
    local plateConfigOptions = {
        {label = "Enemy NPC", value = "enemynpc", onclick = onClickSelectPlateConfigOption},
        {label = "Friendly NPC", value = "friendlynpc", onclick = onClickSelectPlateConfigOption},
        {label = "Enemy Player", value = "enemyplayer", onclick = onClickSelectPlateConfigOption},
        {label = "Friendly Player", value = "friendlyplayer", onclick = onClickSelectPlateConfigOption},
    }

    --create df dropdown to select which plate config to edit
    local plateConfigDropdown = detailsFramework:CreateDropDown(previewNameplateFrame, function() return plateConfigOptions end, subTablePath, 160, 20)
    plateConfigDropdown:SetPoint("topleft", previewNameplateFrame, "topleft", 2, -13)
    plateConfigDropdown:SetTemplate(detailsFramework:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))

    local onSelectChangeAllFonts = function(self, fixedParameter, fontName)
        local SharedMedia = LibStub:GetLibrary("LibSharedMedia-3.0")
        local fontFile = SharedMedia:Fetch("font", fontName)

        local plateConfigs = {"enemynpc", "friendlynpc", "enemyplayer", "friendlyplayer", "player"}

        for i = 1, #plateConfigs do
            local plateTable = Plater.db.profile.plate_config[plateConfigs[i]]
            plateTable.actorname_text_font = fontName
            plateTable.spellname_text_font = fontName
            plateTable.spellpercent_text_font = fontName
            plateTable.level_text_font = fontName
            plateTable.percent_text_font = fontName
            plateTable.big_actortitle_text_font = fontName
            plateTable.big_actorname_text_font = fontName
            plateTable.power_percent_text_font = fontName
        end

        local profile = Plater.db.profile
        profile.castbar_target_font = fontName
        profile.aura_timer_text_font = fontName
        profile.aura_stack_font = fontName

        --update the font on all nameplates
        designer.UpdateAllNameplates()

        --refreshes the current object being edited
        layoutEditor:Refresh()

        local registeredObjects = layoutEditor:GetAllRegisteredObjects()
        for i = 1, #registeredObjects do
            local objectInfo = registeredObjects[i]
            local uiObject = objectInfo.object
            if (uiObject.GetObjectType and uiObject:GetObjectType() == "FontString") then
                ---@cast uiObject fontstring
                detailsFramework:SetFontFace(uiObject, fontFile)
            end
        end
    end

    local selectFontDropdown = detailsFramework:CreateFontDropDown(previewNameplateFrame, onSelectChangeAllFonts, 0, 160, 20)
    selectFontDropdown:SetPoint("topright", previewNameplateFrame, "topright", -2, -13)
    selectFontDropdown:SetTemplate(detailsFramework:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))
    selectFontDropdown.label:SetText("change all fonts")
    selectFontDropdown.icon:SetTexture([[Interface\AnimCreate\AnimCreateIcons]])
    selectFontDropdown.icon:SetTexCoord(0, 32/128, 64/128, 96/128)

    plateFrame = designer.CreatePreview(previewNameplateFrame)
    --createFrameTag(plateFrame, "nameplate")
    plateFrame:SetPoint("center", previewNameplateFrame, "center", 0, 50)
    plateFrame:SetScale(1.0)
    plateFrame:SetSize(180, 60)
    plateFrame.unit = "player"
    --platerInternal.Events.GetEventFunction("NAME_PLATE_UNIT_ADDED")("NAME_PLATE_UNIT_ADDED", "preview")

    ---@type unitframe
    local unitFrame = plateFrame.unitFrame
    ---@type healthbar
    local healthBar = unitFrame.healthBar
    healthBar:SetMinMaxValues(0, 1)
    healthBar:SetValue(0.7)
    ---@type castbar
    local castBar = unitFrame.castBar
    castBar:SetMinMaxValues(0, 1)
    castBar:SetValue(0.5)

    castBar:Show()
    castBar:AdjustPointsOffset(0, -30)

    --castBar:ClearAllPoints()

    --Plater_LayoutEditor
    --Plater_LayoutEditorGuideFrame
    --PlaterDesignerPlatePreview
    --^ parenting stair

    ---@type fontstring
    local unitName = unitFrame.unitName
    ---@type fontstring
    local levelText = healthBar.actorLevel
    ---@type fontstring
    local spellName = castBar.Text
    ---@type fontstring
    local lifePercent = healthBar.lifePercent_Safe
    ---@type fontstring
    local castPercentText = castBar.percentText
    ---@type fontstring
    local actorTitleSpecial = plateFrame.ActorTitleSpecial
    ---@type fontstring
    local actorNameSpecial = plateFrame.ActorNameSpecial
    ---@type fontstring
    local questOptionsFontString = unitFrame.QuestOptionsDummyFontString
    ---@type fontstring
    local castBarTargetName = castBar.TargetName
    ---@type fontstring
    local newcastBarTargetName = castBar.NewCastBarTargetName
    ---@type texture
    local castBarSpark = castBar.Spark

    spellName:SetText("Blizzard")
    unitName:SetText("Unit Name")
    levelText:SetText("60")
    lifePercent:SetText("80%")
    castPercentText:SetText("3.2s")
    actorNameSpecial:SetText("Unit Name When No Health Bar")
    actorTitleSpecial:SetText("Unit Title When No Health Bar")

    detailsFramework:SetFontSize(actorNameSpecial, Plater.db.profile.plate_config.enemynpc.big_actorname_text_size)
    detailsFramework:SetFontSize(actorTitleSpecial, Plater.db.profile.plate_config.enemynpc.big_actortitle_text_size)

    actorNameSpecial:ClearAllPoints()
    actorNameSpecial:SetPoint("bottomleft", previewNameplateFrame, "bottomleft", 5, 40)
    actorTitleSpecial:ClearAllPoints()
    actorTitleSpecial:SetPoint("top", actorNameSpecial, "bottom", 0, -2)

    --Plater.db.profile
    local profileRoot = Plater.db.profile
    local rootKey = "" --as the settings are in the root of the profile table, there is no path to pass
    --profileRoot.plate_config
    local plateConfig = profileRoot.plate_config

    local onSettingChanged = function(editingObject, optionKey, newValue, profileTable, profileKey)
        --plater only, change the incombat and outofcombat settings together
        if profileKey:find("health_incombat") then
            if optionKey == "width" then
                profileTable.health[1] = newValue
            else
                profileTable.health[2] = newValue
            end
        end

        if profileKey:find("cast_incombat") then
            if optionKey == "width" then
                profileTable.cast[1] = newValue
                local castBarOffSetX = plateConfig[subTablePath].castbar_offset_x
                local castBarOffSetXRel = (healthBar:GetWidth() - newValue) / 2
                --local castBarOffSetY = plateConfig.castbar_offset --override by -30 pixels
                PixelUtil.SetPoint (castBar, "topleft", healthBar, "bottomleft", castBarOffSetXRel + castBarOffSetX, -30)
                PixelUtil.SetPoint (castBar, "topright", healthBar, "bottomright", -castBarOffSetXRel + castBarOffSetX, -30)
            else
                profileTable.cast[2] = newValue
            end
        end

        if (optionKey == "anchor") then
            local anchorTable = detailsFramework.table.getfrompath(profileTable, profileKey, 1)
            anchorTable.x = 0
            anchorTable.y = 0

            C_Timer.After(0, function()
                --layoutEditor:PrepareObjectForEditing()
            end)
        end

        designer.UpdateAllNameplates()
    end

    ---@type df_editobjectoptions
    local editObjectDefaultOptions = {
        use_colon = false, --colon after the localizedLabel
        can_move = true,
        use_guide_lines = false,
        text_template = detailsFramework:GetTemplate("font", "OPTIONS_FONT_TEMPLATE"),
    }

    local editObjectNoMoveOptions = detailsFramework.table.copy({}, editObjectDefaultOptions)
    editObjectNoMoveOptions.can_move = false

    actorNameSpecial:Show()
    actorTitleSpecial:Show()
    --castBarTargetName:Show()

    local previousCastbarTargetShow = Plater.db.profile.castbar_target_show
    Plater.db.profile.castbar_target_show = true
    Plater.UpdateCastbarTargetText(castBar, newcastBarTargetName)
    Plater.db.profile.castbar_target_show = previousCastbarTargetShow

    newcastBarTargetName:Show()
    newcastBarTargetName:SetText("Target Name")

    --by registering the object within the editor, the the object will show up in the list of widgets to select

    --pathstring: a string containing dots or brackets to reach the subtable where the settings are stored
    --example: "nameplate.texts.colors.out_of_combat_color[1]" > would return the first value of the out_of_combat_color table

    --[[
        RegisterObject(self, object:uiobject, localizedLabel:string, id:string, profileTable:table, subTablePath:pathstring, profileKeyMap:table, extraOptions:table, callback:function, options:table, refFrame:uiobject)
        object: the uiobject to be edited (error if invalid)
        localizedLabel: the name shown in the list
        id: a string with a unique id for the object, used with EditObjectById(ID)
        profileTable: the table where the settings are stored
        subTablePath: a pathstring within the profile table where the settings are stored, support pathstring
        profileKeyMap: a table mapping the default editor options to the keys used in the profile table. see 'Plater_Designer_Objects.lua' file.
        extraOptions: a table containing extra options to be added to the editor, see 'Plater_Designer_Objects.lua' file.
        callback: a function called when a setting is changed, parameters are (UIObject, optionKey, newValue, profileTable:table, subTablePath:pathstring)
        options: a table containing options for the registered object.
        refFrame: a uiobject used as reference the anchor point.
    ]]

    --~register

    ---@type df_editor_objectinfo
    local objectInfo

    --plateConfig objects are objects where all settings are within the plate_config table

    --quest options:
    local questOptions = detailsFramework.table.copy({}, editObjectDefaultOptions)
    questOptions.icon = "QuestNormal" --atlas name
    questOptions.can_move = false
    objectInfo = layoutEditor:RegisterObject(questOptionsFontString, "Quest Options", "QUESTOPTIONS", plateConfig, subTablePath, options.WidgetSettingsMapTables.QuestOptions, options.WidgetSettingsExtraOptions.QuestOptions, onSettingChanged, questOptions, unitFrame)
    plateConfigObjectsInfo[#plateConfigObjectsInfo+1] = objectInfo


    --health bar
    ---@type df_editobjectoptions
    local healthBarOptions = detailsFramework.table.copy({}, editObjectDefaultOptions)
    healthBarOptions.can_move = false
    objectInfo = layoutEditor:RegisterObject(healthBar, "Health Bar", "HEALTHBAR", plateConfig, subTablePath, options.WidgetSettingsMapTables.HealthBar, options.WidgetSettingsExtraOptions.HealthBar, onSettingChanged, healthBarOptions, healthBar)

    objectInfo = layoutEditor:RegisterObject(unitName, "Unit Name", "UNITNAME", plateConfig, subTablePath, options.WidgetSettingsMapTables.UnitName, options.WidgetSettingsExtraOptions.UnitName, onSettingChanged, editObjectDefaultOptions, healthBar)
    plateConfigObjectsInfo[#plateConfigObjectsInfo+1] = objectInfo

    objectInfo = layoutEditor:RegisterObject(levelText, "Unit Level", "UNITLEVEL", plateConfig, subTablePath, options.WidgetSettingsMapTables.UnitLevel, options.WidgetSettingsExtraOptions.UnitLevel, onSettingChanged, editObjectDefaultOptions, healthBar)
    plateConfigObjectsInfo[#plateConfigObjectsInfo+1] = objectInfo
    objectInfo = layoutEditor:RegisterObject(lifePercent, "Life Percent", "LIFEPERCENT", plateConfig, subTablePath, options.WidgetSettingsMapTables.LifePercent, options.WidgetSettingsExtraOptions.LifePercent, onSettingChanged, editObjectDefaultOptions, healthBar)
    plateConfigObjectsInfo[#plateConfigObjectsInfo+1] = objectInfo
    platerInternal.UpdatePercentTextLayout(lifePercent, plateConfig[subTablePath])

    --actor title and name special
    objectInfo = layoutEditor:RegisterObject(actorNameSpecial, "Big Unit Name", "BIGUNITNAME", plateConfig, subTablePath, options.WidgetSettingsMapTables.BigUnitName, options.WidgetSettingsExtraOptions.BigUnitName, onSettingChanged, editObjectNoMoveOptions, plateFrame)
    plateConfigObjectsInfo[#plateConfigObjectsInfo+1] = objectInfo
    layoutEditor:RegisterObject(actorTitleSpecial, "Big Unit Title", "BIGUNITTITLE", plateConfig, subTablePath, options.WidgetSettingsMapTables.BigActorTitle, options.WidgetSettingsExtraOptions.BigActorTitle, onSettingChanged, editObjectNoMoveOptions, plateFrame)
    plateConfigObjectsInfo[#plateConfigObjectsInfo+1] = objectInfo

    --cast bar [no plate config]
    --cast bar has settings both in plate_config and in the root file of profile
    ---@type df_editobjectoptions
    local castBarOptions = detailsFramework.table.copy({}, editObjectDefaultOptions)
    castBarOptions.can_move = false
    objectInfo = layoutEditor:RegisterObject(castBar, "Cast Bar", "CASTBAR", plateConfig, subTablePath, options.WidgetSettingsMapTables.CastBar, options.WidgetSettingsExtraOptions.CastBar, onSettingChanged, castBarOptions, castBar)

    objectInfo = layoutEditor:RegisterObject(spellName, "Cast Spell Name", "CASTSPELLNAME", plateConfig, subTablePath, options.WidgetSettingsMapTables.SpellName, options.WidgetSettingsExtraOptions.SpellName, onSettingChanged, editObjectDefaultOptions, castBar)
    plateConfigObjectsInfo[#plateConfigObjectsInfo+1] = objectInfo
    objectInfo = layoutEditor:RegisterObject(castPercentText, "Cast Time", "CASTSPELLTIME", plateConfig, subTablePath, options.WidgetSettingsMapTables.SpellCastTime, options.WidgetSettingsExtraOptions.SpellCastTime, onSettingChanged, editObjectDefaultOptions, castBar)
    plateConfigObjectsInfo[#plateConfigObjectsInfo+1] = objectInfo

    --[no plate config]
    ---@type df_editobjectoptions
    local sparkOptions = detailsFramework.table.copy({}, editObjectDefaultOptions)
    sparkOptions.can_move = false
    objectInfo = layoutEditor:RegisterObject(newcastBarTargetName, "Cast Target Name", "CASTTARGETNAME", profileRoot, rootKey, options.WidgetSettingsMapTables.CastBarTargetName, options.WidgetSettingsExtraOptions.CastBarTargetName, onSettingChanged, sparkOptions, castBar.FrameOverlay)
    --[no plate config]
    objectInfo = layoutEditor:RegisterObject(castBarSpark, "Cast Spark", "CASTSPARK", profileRoot, rootKey, options.WidgetSettingsMapTables.CastBarSpark, options.WidgetSettingsExtraOptions.CastBarSpark, onSettingChanged, sparkOptions, castBar.FrameOverlay)

    --designer.RefreshLayout()

    --select the first object
    layoutEditor:EditObjectByIndex(2)

    editorMainFrame:SetAlpha(1)

    local disabledAlpha = 0.2
    local curCastBarValue = 0

    local moveUpFrame = CreateFrame("frame", nil, editorMainFrame)
    moveUpFrame:SetScript("OnUpdate", function(self, deltaTime)
        --plateFrame.unitFrame:SetFrameStrata("HIGH")
        plateFrame:SetFrameLevel(previewNameplateFrame:GetFrameLevel() + 100)
        --unitFrame:Show()
        --healthBar:Show()
        --plateFrame.unitName:SetText()
        --stops when the frame hides
        --dv(plateFrame)

        --castBarTargetName:Show()
        castBar:Show()
        castBar:SetMinMaxValues(0, 3)
        castBar:SetValue(isCastBarSelected and curCastBarValue or 0)

        if (curCastBarValue >= 3) then
            curCastBarValue = 0
        else
            if not isCastBarSelected then
                curCastBarValue = 0
            else
                curCastBarValue = curCastBarValue + deltaTime
            end
        end

        --castBarTargetName:SetText("Target Name")
        --castBarTargetName:Show()

        --[=[ spark debug
        local np = NamePlate1
        local npcastBar = np and np.unitFrame and np.unitFrame.castBar
        local spark = npcastBar and npcastBar.Spark
        dv(spark)
        --]=]

        --check options
        if (plateConfig[subTablePath].percent_text_enabled) then
            lifePercent:SetAlpha(1)
        else
            lifePercent:SetAlpha(disabledAlpha)
        end
    end)


    editorMainFrame:SetScript("OnShow", function()
        previewNameplateFrame:Show()
        plateFrame:Show()
        layoutEditor:Show()
        plateFrame:Show()
        actorTitleSpecial:Show()
        actorNameSpecial:Show()
        healthBar:Show()
        plateFrame.unitFrame:SetUnit("player")
        unitName:SetText("Unit Name")
        unitName:Show()
        unitFrame.BuffFrame:Show()
        unitFrame.BuffFrame2:Show()
    end)

    editorMainFrame:SetScript("OnHide", function()
        previewNameplateFrame:Hide()
        plateFrame:Hide()
        layoutEditor:Hide()
        plateFrame:Hide()
        plateFrame.unitFrame:SetUnit(nil)

        actorTitleSpecial:Hide()
        actorNameSpecial:Hide()

        C_Timer.After(1, function()
            plateFrame:Hide()
        end)

        unitFrame.BuffFrame:Hide()
        unitFrame.BuffFrame2:Hide()
    end)

    --/plater editmode

end


function Plater.UpdateCustomDesign(unitFrame)




end

function Plater.CreateCustomDesignBorder(frame) --need review
    local frameBorderCustom = CreateFrame ("frame", nil, frame)
    frameBorderCustom:SetPoint("topleft", frame, "topleft", -1, 1)
    frameBorderCustom:SetPoint("bottomright", frame, "bottomright", 1, -1)
    frame.customborder = frameBorderCustom
    frameBorderCustom.texture = frameBorderCustom:CreateTexture(nil, "overlay")
    frameBorderCustom.texture:SetAllPoints()
    frameBorderCustom:Hide()
end

--plateFrame.PlateConfig = DB_PLATE_CONFIG.enemynpc

function designer.CreatePreview(parent)
    plateFrame = CreateFrame("frame", "PlaterDesignerPlatePreview", parent)
    plateFrame.isDesigner = true

    plateFrame.UnitFrame = CreateFrame("frame") --blizzard's unit frame placeholder

    plateFrame:SetScale(1.5)

    --simulate the creation of a game's nameplate, this creates the nameplate.unitFrame and its widgets
    platerInternal.Events.GetEventFunction("NAME_PLATE_CREATED")("NAME_PLATE_CREATED", plateFrame)

    designer.UpdatePreview()

    return plateFrame
end


function designer.UpdatePreview()
    local DB_NAME_NPCENEMY_ANCHOR = platerInternal.VarSharing.DB_NAME_NPCENEMY_ANCHOR
    local DB_PLATE_CONFIG = platerInternal.VarSharing.DB_PLATE_CONFIG
    local DB_CASTBAR_HIDE_ENEMIES = platerInternal.VarSharing.DB_CASTBAR_HIDE_ENEMIES

    local unitFrame = plateFrame.unitFrame
    local plateConfigs = getProfileTable()
    local needReset = true

    local reaction = 4 --enemy

    local unitID = "player"
    unitFrame:SetUnit(unitID)
    unitFrame.unit = unitID
    unitFrame.namePlateUnitToken = unitID
    unitFrame.displayedUnit = unitID
    plateFrame.unit = unitID
    plateFrame.OnTickFrame.unit = unitID
    plateFrame.OnTickFrame.actorType = ACTORTYPE_ENEMY_NPC
    unitFrame.PlaterOnScreen = true

    local unitName = unitFrame.unitName
    plateFrame.unitNameInternal = unitName

    unitName:SetText(UnitName(unitID))
    plateFrame.CurrentUnitNameString = unitName

    local actorNameSpecial = unitFrame.ActorNameSpecial
    local actorTitleSpecial = unitFrame.ActorTitleSpecial

    local healthBar = unitFrame.healthBar
    local powerBar = unitFrame.powerBar
    local castBar = unitFrame.castBar
    local castBar2 = unitFrame.castBar2

    local PLAYER_IN_COMBAT = false

    local actorType = ACTORTYPE_ENEMY_NPC

    Plater.UpdateSoftInteractTarget(plateFrame)

    plateFrame[MEMBER_GUID] = UnitGUID(unitID)
    plateFrame[MEMBER_NAME] = UnitName(unitID)

    unitFrame.IsNeutralOrHostile = actorType == ACTORTYPE_ENEMY_NPC

    unitFrame.nameplateScaleAdjust = 1

    unitFrame.targetUnitID = unitID .. "target"

	unitFrame.InCombat = UnitAffectingCombat(unitID) or (Plater.ForceInCombatUnits[unitFrame[MEMBER_NPCID]] and PLAYER_IN_COMBAT) or false
        plateFrame [MEMBER_REACTION] = reaction
        unitFrame [MEMBER_REACTION] = reaction
        unitFrame.BuffFrame [MEMBER_REACTION] = reaction
        unitFrame.BuffFrame2 [MEMBER_REACTION] = reaction

    --cache values into the unitFrame as well to reduce the overhead on scripts and hooks
    unitFrame [MEMBER_NAME] = plateFrame [MEMBER_NAME]
    unitFrame [MEMBER_NAMELOWER] = plateFrame [MEMBER_NAMELOWER]
    plateFrame ["namePlateClassification"] = "worldboss"
    unitFrame ["namePlateClassification"] = "worldboss"
    unitFrame.unitNameInternal = unitName
    unitFrame [MEMBER_UNITID] = unitID

    unitFrame.BuffFrame [MEMBER_REACTION] = reaction
    unitFrame.BuffFrame2 [MEMBER_REACTION] = reaction
    unitFrame.BuffFrame.unit = unitID
    unitFrame.BuffFrame2.unit = unitID
    unitFrame.ExtraIconFrame.unit = unitID

    plateFrame.playerGuildName = "Guild Name"

    local no = false
    local yes = true

    unitFrame.Settings.ShowCastBar = yes
    plateFrame.isPlayer = no
    unitFrame.isPlayer = no
    plateFrame.PlayerCannotAttack = no
    unitFrame.InExecuteRange = no
    plateFrame.actorType = actorType
    unitFrame.actorType = actorType

    unitFrame:SetUnit(unitID)

    Plater.OnRetailNamePlateShow(plateFrame.UnitFrame) --affecting blizz nameplate which the preview only a dummy
    unitFrame:Show()
    unitFrame.unitName:Show()
    Plater.AddToAuraUpdate(unitID, unitFrame)
    Plater.EnsureUpdateBossModAuras(plateFrame[MEMBER_GUID])

    plateFrame.NameAnchor = DB_NAME_NPCENEMY_ANCHOR
    plateFrame.PlateConfig = DB_PLATE_CONFIG.enemynpc
    Plater.UpdatePlateFrame (plateFrame, ACTORTYPE_ENEMY_NPC, nil, true)
    unitFrame.Settings.ShowCastBar = not DB_CASTBAR_HIDE_ENEMIES
    unitFrame.castBar:SetUnit (unitID, unitID)

    --get threat situation to expose it to scripts already in the nameplate added hook
    local isTanking, threatStatus, threatpct, threatrawpct, threatValue = UnitDetailedThreatSituation("player", unitID)
    unitFrame.namePlateThreatIsTanking = isTanking
    unitFrame.namePlateThreatStatus = threatStatus
    unitFrame.namePlateThreatPercent = threatpct or 0
    unitFrame.namePlateThreatRawPercent = threatrawpct or 0
    unitFrame.namePlateThreatValue = threatValue or 0

    --update the bars
    Plater.UpdatePlateText(plateFrame, plateConfigs, needReset)

    Plater.UpdateUnitName(plateFrame)

    Plater.UpdateUIParentLevels(unitFrame)

    Plater.UpdatePlateFrame(plateFrame, ACTORTYPE_ENEMY_NPC, nil, true)

    Plater.OnUpdateHealth(healthBar)
    Plater.QuickHealthUpdate(unitFrame)

    Plater.UpdateBorderColor(unitFrame)

    Plater.UpdateNameOnRenamedUnit(plateFrame)

    Plater.FindAndSetNameplateColor (unitFrame, true)

    Plater.UpdateCastbarIcon(castBar)

    plateFrame.unitFrame.WidgetContainer = plateFrame.UnitFrame.WidgetContainer
    if plateFrame.unitFrame.WidgetContainer then
        plateFrame.unitFrame.WidgetContainer:SetParent(plateFrame.unitFrame)
        plateFrame.unitFrame.WidgetContainer:ClearAllPoints()
        plateFrame.unitFrame.WidgetContainer:SetIgnoreParentScale(true)
        plateFrame.unitFrame.WidgetContainer:SetScale(Plater.db.profile.widget_bar_scale)
        Plater.SetAnchor (plateFrame.unitFrame.WidgetContainer, Plater.db.profile.widget_bar_anchor, plateFrame.unitFrame)
    end

    unitFrame.CanCheckAggro = yes

    Plater.Resources.UpdateResourceFramePosition()

    Plater.NameplateTick (plateFrame.OnTickFrame, 999)
    unitFrame.PlaterOnScreen = true

    --create new fontstring to life percent to avoid issues with UnitHealth() returning a secret
    ---@type fontstring
    local newLifePercent = healthBar:CreateFontString(nil, "overlay", "GameFontNormal")
    healthBar.lifePercent_Safe = newLifePercent
    healthBar.lifePercent_Safe:SetPoint("center", healthBar, "center", 0, 0)
    healthBar.lifePercent:Hide()

    ---quest options dummy
    ---@type fontstring
    local questOptionsFontString = castBar:CreateFontString(nil, "overlay", "GameFontNormal")
    unitFrame.QuestOptionsDummyFontString = questOptionsFontString

    --dv(healthBar)

    local focusIndicator = unitFrame.FocusIndicator

    local anchorFrame = plateFrame.PlaterAnchorFrame

    --local actorLevel = healthBar.actorLevel


    local obscuredTexture = plateFrame.Obscured

    local extraIconFrame = unitFrame.ExtraIconFrame

    local castBarIcon = castBar.Icon
    local castBarText = castBar.Text
    local castBarPercentText = castBar.percentText
    local castBarTargetName = castBar.TargetName

    --print(castBarTargetName:GetParent():GetName())

    local newBarTargetName = castBar.FrameOverlay:CreateFontString(nil, "overlay", "GameFontNormal")
    castBar.NewCastBarTargetName = newBarTargetName

    local buffFrame1 = unitFrame.BuffFrame
    local buffFrame2 = unitFrame.BuffFrame2

    local targetNeonUp = unitFrame.TargetNeonUp
    local targetNeonDown = unitFrame.TargetNeonDown

    local targetOverlayTexture = unitFrame.targetOverlayTexture

    local frameOverlay = healthBar.FrameOverlay
    local healthCutOff = healthBar.healthCutOff
    local shieldIndicator = healthBar.shieldIndicator
    local executeRange = healthBar.executeRange
    local executeGlowUp = healthBar.ExecuteGlowUp
    local executeGlowDown = healthBar.ExecuteGlowDown

    local raidTargetIcon = unitFrame.PlaterRaidTargetFrame.RaidTargetIcon
    local extraRaidMark = healthBar.ExtraRaidMark

    plateFrame:SetParent(UIParent)
    plateFrame:SetFrameStrata("FULLSCREEN")
    plateFrame.unitFrame:SetFrameStrata("FULLSCREEN")

    Plater.UpdatePlateSize(plateFrame)
end