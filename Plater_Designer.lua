
local addonName, platerInternal = ...
local Plater = _G.Plater
local GameCooltip = GameCooltip2
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
local profileKey = "enemynpc"

local getProfileTable = function()
    return Plater.db.profile.plate_config[profileKey]
end

local dv = function(f) detailsFramework:DebugVisibility(f) end

---debug tags to help identify frames, the string passed is always the variable name for the frame
---@param f frame
---@param n string
local createFrameTag = function (f,n)
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

function Plater.CreateDesignerWindow()
    local gName = "PlaterDsgn"

    local startY = -30
    local startX = 10

    --tab background using a rounded panel | need to make a preset for this, atm it is declaring each time the same table
    local roundedPanelOptions = {
        scale = 1,
        width = 1300,
        height = 600,
        roundness = 8,
    }

    ---@type df_roundedpanel
    local editorMainFrame = detailsFramework:CreateRoundedPanel(UIParent, gName, roundedPanelOptions)
    --local editorMainFrame = CreateFrame("frame", gName, UIParent)

    --local 

    Plater.DesignerWindow = editorMainFrame

    detailsFramework:MakeDraggable(editorMainFrame)
    editorMainFrame:EnableMouse(true)
    createFrameTag(editorMainFrame, "editorMainFrame")
    editorMainFrame:SetSize (roundedPanelOptions.width, roundedPanelOptions.height)
    editorMainFrame:SetPoint ("center", UIParent, "center", -100, 0)



    --create the widget editor
    local editorOptions = {
        width = editorMainFrame:GetWidth() - 10,
        create_object_list = true,
        object_list_width = 200,
        object_list_height = editorMainFrame:GetHeight() - 15,
        object_list_lines = 20,
        object_list_line_height = 20,
        text_template = editorOptionsTextTemplate,
        no_anchor_points = true,
    }

    --Plater_Designer_Objects.lua
    --create two tables to map the layout settings for the editor
    designer.CreateSettings(editorMainFrame)

    --the frame in the middle of the tab, the the settings for the selected widget are placed
    ---@type df_editor
    local layoutEditor = detailsFramework:CreateEditor(editorMainFrame, "Plater_LayoutEditor", editorOptions)
    createFrameTag(layoutEditor, "layoutEditor")
    layoutEditor:SetPoint("topleft", editorMainFrame, "topleft", 5, -16)
    layoutEditor:SetPoint("bottomleft", editorMainFrame, "bottomleft", 5, 5)
    layoutEditor:EnableMouse(false)
    layoutEditor:SetFrameLevel(editorMainFrame:GetFrameLevel() + 10)
    layoutEditor:SetFrameStrata("HIGH")

    function designer.UpdateAllNameplates()
        for _, thisPlateFrame in ipairs(Plater.GetAllShownPlates()) do
            if thisPlateFrame.namePlateUnitToken or thisPlateFrame.unitToken then
                platerInternal.Events.GetEventFunction("NAME_PLATE_UNIT_ADDED")("NAME_PLATE_UNIT_ADDED", thisPlateFrame.namePlateUnitToken or thisPlateFrame.unitToken)
            end
        end
    end

    --create close button using the framework
    local closeButton = detailsFramework:CreateCloseButton(editorMainFrame, function() editorMainFrame:Hide() end, -6, 6)
    closeButton:SetPoint("topright", editorMainFrame, "topright", -3, -3)

    local canvasFrame = layoutEditor:GetCanvasScrollBox()
    canvasFrame:EnableMouse(false)

    --create a frame to guide the setting points on the empty area at the right side of the main frame, which is reserved for the preview
    local previewNameplateFrame = CreateFrame("Frame", "$parentGuideFrame", layoutEditor)
    createFrameTag(previewNameplateFrame, "previewPlateFrame")
    previewNameplateFrame:SetPoint("bottomleft", canvasFrame, "bottomright", 30, 0)
    previewNameplateFrame:SetPoint("topright", editorMainFrame, "topright", -5, -5)
    previewNameplateFrame:SetFrameLevel(layoutEditor:GetFrameLevel() + 1)

    local plateFrame = designer.CreatePreview(previewNameplateFrame)
    createFrameTag(plateFrame, "nameplate")
    plateFrame:SetPoint("center", previewNameplateFrame, "center", 0, 0)
    plateFrame:SetScale(1.5)
    plateFrame:SetSize(180, 60)
    plateFrame.unit = "player"
    --platerInternal.Events.GetEventFunction("NAME_PLATE_UNIT_ADDED")("NAME_PLATE_UNIT_ADDED", "preview")

    ---@type unitframe
    local unitFrame = plateFrame.unitFrame
    ---@type healthbar
    local healthBar = unitFrame.healthBar
    ---@type castbar
    local castBar = unitFrame.castBar

    castBar:Show()
    castBar:AdjustPointsOffset(0, -30)

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
    local lifePercent = healthBar.lifePercent

    spellName:SetText("Blizzard")
    unitName:SetText("Unit Name")
    levelText:SetText("60")


    local onSettingChanged = function(editingObject, optionName, newValue, profileTable, profileKey)
        print("Changed!", optionName, newValue, profileTable, profileKey)

        if (optionName == "anchor") then
            local anchorTable = detailsFramework.table.getfrompath(profileTable, profileKey, 1)
            anchorTable.x = 0
            anchorTable.y = 0

            C_Timer.After(0, function()
                --layoutEditor:PrepareObjectForEditing()
            end)
        end

        designer.UpdateAllNameplates()
    end

    local profile = Plater.db.profile.plate_config
    local layoutOptions = {}

    --by registering the object within the editor, the the object will show up in the list of widgets to select

    --health bar
    layoutEditor:RegisterObject(unitName, "Unit Name", "UNITNAME", profile, profileKey, options.WidgetSettingsMapTables.UnitName, options.WidgetSettingsExtraOptions.UnitName, onSettingChanged, layoutOptions, healthBar)
    layoutEditor:RegisterObject(levelText, "Unit Level", "UNITLEVEL", profile, profileKey, options.WidgetSettingsMapTables.UnitLevel, options.WidgetSettingsExtraOptions.UnitLevel, onSettingChanged, layoutOptions, healthBar)
    layoutEditor:RegisterObject(lifePercent, "Life Percent", "LIFEPERCENT", profile, profileKey, options.WidgetSettingsMapTables.LifePercent, options.WidgetSettingsExtraOptions.LifePercent, onSettingChanged, layoutOptions, healthBar)

    --cast bar
    layoutEditor:RegisterObject(spellName, "Spell Name", "SPELLNAME", profile, profileKey, options.WidgetSettingsMapTables.SpellName, options.WidgetSettingsExtraOptions.SpellName, onSettingChanged, layoutOptions, castBar)

    local objectSelector = layoutEditor:GetObjectSelector()
    local optionsFrame = layoutEditor:GetOptionsFrame()
    local canvasFrame = layoutEditor:GetCanvasScrollBox()

    --designer.RefreshLayout()

    --select the first object
    layoutEditor:EditObjectByIndex(2)

    editorMainFrame:SetAlpha(1)

    local disabledAlpha = 0.2

    local moveUpFrame = CreateFrame("frame", nil, editorMainFrame)
    moveUpFrame:SetScript("OnUpdate", function()
        plateFrame.unitFrame:SetFrameStrata("HIGH")
        plateFrame:SetFrameLevel(previewNameplateFrame:GetFrameLevel() + 100)
        --unitFrame:Show()
        --healthBar:Show()
        --plateFrame.unitName:SetText()
        --stops when the frame hides
        --dv(plateFrame)

        --check options
        if (profile[profileKey].percent_text_enabled) then
            lifePercent:SetAlpha(1)
        else
            lifePercent:SetAlpha(disabledAlpha)
        end
    end)


    editorMainFrame:SetScript("OnShow", function()
        previewNameplateFrame:Show()
        plateFrame:Show()
        layoutEditor:Show()
        PlaterDesignerPlatePreview:Show()
    end)

    editorMainFrame:SetScript("OnHide", function()
        previewNameplateFrame:Hide()
        plateFrame:Hide()
        layoutEditor:Hide()
        PlaterDesignerPlatePreview:Hide()
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

    plateFrame:SetScale(2)

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
    Plater.AddToAuraUpdate(unitID)
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
end