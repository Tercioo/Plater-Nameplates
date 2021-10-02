
local Plater = _G.Plater
local GameCooltip = GameCooltip2
local DF = DetailsFramework
local _
local UnitPower = _G.UnitPower
local UnitPowerMax = _G.UnitPowerMax
local abs = _G.abs

local IS_WOW_PROJECT_MAINLINE = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
local IS_WOW_PROJECT_NOT_MAINLINE = WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE

local CONST_MONK_WINDWALKER_SPECID = 269
local CONST_MAGE_ARCANE_SPECID = 62
local CONST_ROGUE_ASSASSINATION = 259
local CONST_ROGUE_OUTLAW = 260
local CONST_ROGUE_SUBTLETY = 261
local CONST_DRUID_FERAL = 103
local CONST_PALADIN_RETRIBUTION = 70
local CONST_WARLOCK_AFFLICTION = 265
local CONST_WARLOCK_DEMONOLOGY = 266
local CONST_WARLOCK_DESTRUCTION = 267
local CONST_DK_UNHOLY = 252
local CONST_DK_FROST = 251
local CONST_DK_BLOOD = 250

local CONST_NUM_RESOURCES_WIDGETS = 10
local CONST_WIDGET_WIDTH = 20
local CONST_WIDGET_HEIGHT = 20

--when 'runOnNextFrame' is used instead of 'C_Timer.After', it's to indicate the func will skip the current frame and run on the next one
local runOnNextFrame = function(func)
    _G.C_Timer.After(0, func)
end

--[=[
    resource frame: the frame which is anchored into the health bar, controls the size, scale and position
    resource bar: is anchored (setallpoints) into the resource frame, hold all combo points textures and animations
    widget: is each individual widget representing a single resource

    default settings:
    alignment settings
    resource_padding = 1,

    size settings:
    block_size = 20,
    block_texture_background = "Interface\\COMMON\\Indicator-Gray"
    block_texture_artwork = "Interface\\COMMON\\Indicator-Yellow"
    block_texture_overlay = "Interface\\CHARACTERFRAME\\TempPortraitAlphaMaskSmall"
--]=]

--store functions to create the widgets for the class and the function to update them
local resourceWidgetsFunctions = {}

--store functions used to create the resource bar for each type of resource
local resourceByClass = {}

--power
local SPELL_POWER_MANA = SPELL_POWER_MANA or (PowerEnum and PowerEnum.Mana) or 0
local SPELL_POWER_RAGE = SPELL_POWER_RAGE or (PowerEnum and PowerEnum.Rage) or 1
local SPELL_POWER_FOCUS = SPELL_POWER_FOCUS or (PowerEnum and PowerEnum.Focus) or 2
local SPELL_POWER_ENERGY = SPELL_POWER_ENERGY or (PowerEnum and PowerEnum.Energy) or 3
local SPELL_POWER_COMBO_POINTS2 = SPELL_POWER_COMBO_POINTS or (PowerEnum and PowerEnum.ComboPoints) or 4
local SPELL_POWER_RUNES = SPELL_POWER_RUNES or (PowerEnum and PowerEnum.Runes) or 5
local SPELL_POWER_RUNIC_POWER = SPELL_POWER_RUNIC_POWER or (PowerEnum and PowerEnum.RunicPower) or 6
local SPELL_POWER_SOUL_SHARDS = SPELL_POWER_SOUL_SHARDS or (PowerEnum and PowerEnum.SoulShards) or 7
local SPELL_POWER_LUNAR_POWER = SPELL_POWER_LUNAR_POWER or (PowerEnum and PowerEnum.LunarPower) or 8
local SPELL_POWER_HOLY_POWER = SPELL_POWER_HOLY_POWER  or (PowerEnum and PowerEnum.HolyPower) or 9
local SPELL_POWER_ALTERNATE_POWER = SPELL_POWER_ALTERNATE_POWER or (PowerEnum and PowerEnum.Alternate) or 10
local SPELL_POWER_MAELSTROM = SPELL_POWER_MAELSTROM or (PowerEnum and PowerEnum.Maelstrom) or 11
local SPELL_POWER_CHI = SPELL_POWER_CHI or (PowerEnum and PowerEnum.Chi) or 12
local SPELL_POWER_INSANITY = SPELL_POWER_INSANITY or (PowerEnum and PowerEnum.Insanity) or 13
local SPELL_POWER_OBSOLETE = SPELL_POWER_OBSOLETE or (PowerEnum and PowerEnum.Obsolete) or 14
local SPELL_POWER_OBSOLETE2 = SPELL_POWER_OBSOLETE2 or (PowerEnum and PowerEnum.Obsolete2) or 15
local SPELL_POWER_ARCANE_CHARGES = SPELL_POWER_ARCANE_CHARGES or (PowerEnum and PowerEnum.ArcaneCharges) or 16
local SPELL_POWER_FURY = SPELL_POWER_FURY or (PowerEnum and PowerEnum.Fury) or 17
local SPELL_POWER_PAIN = SPELL_POWER_PAIN or (PowerEnum and PowerEnum.Pain) or 18

local resourceTypes = {
    [SPELL_POWER_INSANITY] = true, --shadow priest
    [SPELL_POWER_CHI] = true, --monk
    [SPELL_POWER_HOLY_POWER] = true, --paladins
    [SPELL_POWER_LUNAR_POWER] = true, --balance druids
    [SPELL_POWER_SOUL_SHARDS] = true, --warlock affliction
    [SPELL_POWER_COMBO_POINTS2] = true, --combo points
    [SPELL_POWER_MAELSTROM] = true, --shamans
    [SPELL_POWER_PAIN] = true, --demonhunter tank
    [SPELL_POWER_RUNES] = true, --dk
    [SPELL_POWER_ARCANE_CHARGES] = true, --mage
    [SPELL_POWER_FURY] = true, --warrior demonhunter dps
}

local energyTypes = {
    [SPELL_POWER_MANA] = true,
    [SPELL_POWER_RAGE] = true,
    [SPELL_POWER_ENERGY] = true,
    [SPELL_POWER_RUNIC_POWER] = true,
}

local resourcePowerType = {
    [SPELL_POWER_COMBO_POINTS2] = SPELL_POWER_ENERGY, --combo points
    [SPELL_POWER_SOUL_SHARDS] = SPELL_POWER_MANA, --warlock
    [SPELL_POWER_LUNAR_POWER] = SPELL_POWER_MANA, --druid
    [SPELL_POWER_HOLY_POWER] = SPELL_POWER_MANA, --paladin
    [SPELL_POWER_INSANITY] = SPELL_POWER_MANA, --shadowpriest
    [SPELL_POWER_MAELSTROM] = SPELL_POWER_MANA, --shaman
    [SPELL_POWER_CHI] = SPELL_POWER_MANA, --monk
    [SPELL_POWER_PAIN] = SPELL_POWER_ENERGY, --demonhuinter
    [SPELL_POWER_RUNES] = SPELL_POWER_RUNIC_POWER, --dk
    [SPELL_POWER_ARCANE_CHARGES] = SPELL_POWER_MANA, --mage
    [SPELL_POWER_FURY] = SPELL_POWER_RAGE, --warrior
}

--cache
local DB_USE_PLATER_RESOURCE_BAR = false
local DB_PLATER_RESOURCE_BAR_ON_PERSONAL = false
local DB_PLATER_RESOURCE_BAR_ANCHOR

--local DB_PLATER_RESOURCE_BAR_HEIGHT
local DB_PLATER_RESOURCE_BAR_SCALE
local DB_PLATER_RESOURCE_PADDING
local DB_PLATER_RESOURCE_GROW_DIRECTON
local DB_PLATER_RESOURCE_SHOW_DEPLATED
local DB_PLATER_RESOURCE_SHOW_NUMBER



--when plater in the main file refreshes its upvalues, this function is also called
--called from plater.lua on Plater.RefreshDBUpvalues()
    function Plater.RefreshResourcesDBUpvalues()
        local profile = Plater.db.profile

        DB_USE_PLATER_RESOURCE_BAR = profile.plater_resources_show
        DB_PLATER_RESOURCE_BAR_ON_PERSONAL = profile.plater_resources_personal_bar
        DB_PLATER_RESOURCE_BAR_ANCHOR = profile.plater_resources_anchor
        --DB_PLATER_RESOURCE_BAR_HEIGHT = profile.plater_resource_width
        DB_PLATER_RESOURCE_BAR_SCALE = profile.plater_resources_scale
        DB_PLATER_RESOURCE_PADDING = profile.plater_resources_padding
        DB_PLATER_RESOURCE_GROW_DIRECTON = profile.plater_resources_grow_direction
        DB_PLATER_RESOURCE_SHOW_DEPLATED = profile.plater_resources_show_depleted
        DB_PLATER_RESOURCE_SHOW_NUMBER = profile.plater_resources_show_number

        --check if the frame exists if the player opt-in to use plater resources
        if (DB_USE_PLATER_RESOURCE_BAR) then
            local mainResourceFrame = Plater.GetMainResourceFrame()
            if (not mainResourceFrame) then
                C_Timer.After (2, Plater.CreatePlaterResourceFrame)
            end
        end
    end

--base frame for the class or spec resource bar, it's a child of the main resource frame 'PlaterNameplatesResourceFrame'
--the function passed is responsible to build textures and animations
    local createResourceBar = function(parent, frameName, func)
        local resourceBar = CreateFrame("frame", frameName, parent)
        resourceBar:EnableMouse(false)
        resourceBar:EnableMouseWheel(false)

        --store all widgets
        resourceBar.widgets = {}
        --store all background textures
        resourceBar.widgetsBackground = {}

        --create widgets which are frames holding textures and animations
        for i = 1, CONST_NUM_RESOURCES_WIDGETS do
            local newWidget = func(resourceBar, "$parentCPO" .. i)
            resourceBar.widgets[#resourceBar.widgets + 1] = newWidget
            newWidget:EnableMouse(false)
            newWidget:EnableMouseWheel(false)
            newWidget:SetSize(20, 20)
            newWidget:Hide()

            local CPOID = DF:CreateLabel(newWidget, i, 12, "white", nil, nil, nil, "overlay")
            CPOID:SetPoint("bottom", newWidget, "top", 0, 5)
            CPOID:Hide()
            newWidget.numberId = CPOID
        end

        return resourceBar
    end

--> functions for class and specs resources
    resourceByClass["MONK"] = function(mainResourceFrame)
        local newResourceBar = createResourceBar(mainResourceFrame, "$parentMonk2Resource", resourceWidgetsFunctions.CreateMonkComboPoints) --windwalker chi
        mainResourceFrame.resourceBars[CONST_MONK_WINDWALKER_SPECID] = newResourceBar
        newResourceBar.resourceId = SPELL_POWER_CHI
        newResourceBar.updateResourceFunc = resourceWidgetsFunctions.OnComboPointsChanged
        tinsert(mainResourceFrame.allResourceBars, newResourceBar)
    end

    resourceByClass["MAGE"] = function(mainResourceFrame)
        local newResourceBar = createResourceBar(mainResourceFrame, "$parentArcaneResource")
        mainResourceFrame.resourceBars[CONST_MAGE_ARCANE_SPECID] = newResourceBar
        newResourceBar.resourceId = SPELL_POWER_ARCANE_CHARGES
        newResourceBar.updateResourceFunc = false
        tinsert(mainResourceFrame.allResourceBars, newResourceBar)
    end

    local resourceDruidAndRogue = function(mainResourceFrame)
        local newResourceBar = createResourceBar(mainResourceFrame, "$parentRogueResource")
        newResourceBar.resourceId = SPELL_POWER_COMBO_POINTS2
        newResourceBar.updateResourceFunc = false

        mainResourceFrame.resourceBars[CONST_ROGUE_ASSASSINATION] = newResourceBar
        mainResourceFrame.resourceBars[CONST_ROGUE_OUTLAW] = newResourceBar
        mainResourceFrame.resourceBars[CONST_ROGUE_SUBTLETY] = newResourceBar
        mainResourceFrame.resourceBars[CONST_DRUID_FERAL] = newResourceBar

        tinsert(mainResourceFrame.allResourceBars, newResourceBar)
    end
    resourceByClass["ROGUE"] = resourceDruidAndRogue
    resourceByClass["DRUID"] = resourceDruidAndRogue

    resourceByClass["WARLOCK"] = function(mainResourceFrame)
        local newResourceBar = createResourceBar(mainResourceFrame, "$parentWarlockResource")
        mainResourceFrame.resourceBars[CONST_WARLOCK_AFFLICTION] = newResourceBar
        mainResourceFrame.resourceBars[CONST_WARLOCK_DEMONOLOGY] = newResourceBar
        mainResourceFrame.resourceBars[CONST_WARLOCK_DESTRUCTION] = newResourceBar
        newResourceBar.resourceId = SPELL_POWER_SOUL_SHARDS
        newResourceBar.updateResourceFunc = false
        tinsert(mainResourceFrame.allResourceBars, newResourceBar)
    end

    resourceByClass["PALADIN"] = function(mainResourceFrame)
        local newResourceBar = createResourceBar(mainResourceFrame, "$parentPaladinResource")
        mainResourceFrame.resourceBars[CONST_PALADIN_RETRIBUTION] = newResourceBar
        newResourceBar.resourceId = SPELL_POWER_HOLY_POWER
        newResourceBar.updateResourceFunc = false
        tinsert(mainResourceFrame.allResourceBars, newResourceBar)
    end

    resourceByClass["DEATHKNIGHT"] = function(mainResourceFrame)
        local newResourceBar = createResourceBar(mainResourceFrame, "$parentDKResource")
        mainResourceFrame.resourceBars[CONST_DK_UNHOLY] = newResourceBar
        mainResourceFrame.resourceBars[CONST_DK_FROST] = newResourceBar
        mainResourceFrame.resourceBars[CONST_DK_BLOOD] = newResourceBar
        newResourceBar.resourceId = SPELL_POWER_RUNES
        newResourceBar.updateResourceFunc = false
        tinsert(mainResourceFrame.allResourceBars, newResourceBar)
    end

--> this funtion is called once at the logon, it'll create the resource frames for the class
    function Plater.CreatePlaterResourceFrame()
        if (not DB_USE_PLATER_RESOURCE_BAR) then
            --ignore if the settings are off
            return
        end

        local mainResourceFrame = Plater.GetMainResourceFrame()
        if (mainResourceFrame) then
            --ignore if the resource frame is already created
            return
        end

        --create a frame attached to UIParent, this frame is the fundation for the resource bar
        local mainResourceFrame = CreateFrame("frame", "PlaterNameplatesResourceFrame", UIParent)

        --store the resources bars created for the class or spec (hash table)
        mainResourceFrame.resourceBars = {}
        --store all resource bars created (index table)
        mainResourceFrame.allResourceBars = {}

        --grab the player class
        local playerClass = Plater.PlayerClass

        if (IS_WOW_PROJECT_NOT_MAINLINE) then --classic

        else
            --create the resource bar for the class, event if it'll be used by certain specs
            local classResourceFunc = resourceByClass[playerClass]
            if (classResourceFunc) then
                classResourceFunc(mainResourceFrame)
            end
        end

        --set the event function on the main frame of the resources
        mainResourceFrame:SetScript("OnEvent", function(self, event, ...)
            --get the current shown resource bar, then get its update func and call it passing the mainResourceFrame as #1 and the resourceBar itself as #2 argument
            local currentResourceBar = self.currentResourceBarShown
            if (currentResourceBar) then
                local updateResourceFunc = currentResourceBar.updateResourceFunc
                if (updateResourceFunc) then
                    updateResourceFunc(self, currentResourceBar)
                end
            end
        end)
    end

    function Plater.GetMainResourceFrame()
        return _G.PlaterNameplatesResourceFrame
    end

    function Plater.ResourceFrame_EnableEvents()
        local mainResourceFrame = Plater.GetMainResourceFrame()
		mainResourceFrame:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
        mainResourceFrame:RegisterUnitEvent("UNIT_MAXPOWER", "player")
    end

    function Plater.ResourceFrame_DisableEvents()
        local mainResourceFrame = Plater.GetMainResourceFrame()
		mainResourceFrame:UnregisterEvent("UNIT_POWER_FREQUENT")
        mainResourceFrame:UnregisterEvent("UNIT_MAXPOWER")
    end


--> called when use plater resource bar is disabled or when no match on rules to show it; only called from inside this file
    function Plater.HidePlaterResourceFrame()
        local mainResourceFrame = Plater.GetMainResourceFrame()
        if (mainResourceFrame) then
            Plater.ResourceFrame_DisableEvents()
            return mainResourceFrame:Hide()
        end
    end

--> check if plater settings allow the use of these resources and check if the class and spec has a resource to show
    local canUsePlaterResourceFrame = function()
		if IS_WOW_PROJECT_NOT_MAINLINE then
            return
        end

        --nameplate which will have the resource bar
        local plateFrame

        if (not DB_USE_PLATER_RESOURCE_BAR) then
            return Plater.HidePlaterResourceFrame()

        elseif (not DB_PLATER_RESOURCE_BAR_ON_PERSONAL) then
            --target nameplate
            plateFrame = C_NamePlate.GetNamePlateForUnit("target")
            --if the player has no target, this will return nil
            if (not plateFrame) then
                return Plater.HidePlaterResourceFrame()
            end

        else
            --personal bar
            plateFrame = C_NamePlate.GetNamePlateForUnit("player")
            --if the player nameplate does not exists, just quit
            if (not plateFrame) then
                return Plater.HidePlaterResourceFrame()
            end
        end

        if (IS_WOW_PROJECT_NOT_MAINLINE) then

        else

            --spec index from 1 to 4 (see specialization frame pressing N ingame), characters below level 10 might have a bigger index
            local specIndexSelected = GetSpecialization()
            local specId = GetSpecializationInfo(specIndexSelected)
            local mainResourceFrame = Plater.GetMainResourceFrame()

            if (specId) then
                --check if the current player spec uses a resource bar
                local resourceBarBySpec = mainResourceFrame.resourceBars[specId]
                if (resourceBarBySpec) then
                    resourceBarBySpec.resourceClass = false
                    resourceBarBySpec.resourceSpec = specId

                    Plater.ResourceFrame_EnableEvents()
                    Plater.UpdateMainResourceFrame(plateFrame)
                    return Plater.UpdateResourceBar(plateFrame, resourceBarBySpec)
                end
            else
                --if no specialization, player might be low level
                if (UnitLevel("player") < 10) then
                    --should get by class?
                    if (playerClass == "ROGUE") then
                        Plater.ResourceFrame_EnableEvents()
                        Plater.UpdateMainResourceFrame(plateFrame)
                        return Plater.UpdateResourceBar(plateFrame, mainResourceFrame.resourceBars ["ROGUE"])
                    end
                end
            end
        end

        return Plater.HidePlaterResourceFrame()
    end


--> currently is called from:
    --player spec change (PLAYER_SPECIALIZATION_CHANGED)
    --player target has changed
    --decides if the resource is shown or not
    function Plater.CanUsePlaterResourceFrame()
        return runOnNextFrame(canUsePlaterResourceFrame)
    end


--called when 'CanUsePlaterResourceFrame' gives green flag to show the resource bar
--this function receives the nameplate where the resource bar will be attached
    function Plater.UpdateMainResourceFrame(plateFrame)
		if IS_WOW_PROJECT_NOT_MAINLINE then
            return
        end

        --get the main resource frame
        local mainResourceFrame = Plater.GetMainResourceFrame()

        --make its parent be the healthBar from the nameplate where it is anchored to
        mainResourceFrame:SetParent(plateFrame.unitFrame.healthBar)

        --update the resource anchor
        Plater.SetAnchor(mainResourceFrame, DB_PLATER_RESOURCE_BAR_ANCHOR)

        --update the size
        local healthBarWidth = plateFrame.unitFrame.healthBar:GetWidth()
        mainResourceFrame:SetWidth(healthBarWidth)
        mainResourceFrame:SetHeight(2)
        mainResourceFrame:SetScale(DB_PLATER_RESOURCE_BAR_SCALE)
    end


--called when 'CanUsePlaterResourceFrame' gives green flag to show the resource bar
--this funtion receives the nameplate and the bar to show
    function Plater.UpdateResourceBar(plateFrame, resourceBar)
        --main resource frame
        local mainResourceFrame = Plater.GetMainResourceFrame()

        --hide all resourcebar widgets
        for i = 1, #resourceBar.widgets do
            resourceBar.widgets[i]:Hide()
            resourceBar.widgets[i].numberId:SetShown(DB_PLATER_RESOURCE_SHOW_NUMBER)
        end

        --check if the bar already shown isn't the bar asking to be shown
        if (mainResourceFrame.currentResourceBarShown) then
            if (mainResourceFrame.currentResourceBarShown ~= resourceBar) then
                mainResourceFrame.currentResourceBarShown:Hide()
            end
        end

        mainResourceFrame.currentResourceBarShown = resourceBar

        if (DB_PLATER_RESOURCE_SHOW_NUMBER) then

        end

        --show the resource bar
        resourceBar:Show()
        resourceBar:SetHeight(1)
        mainResourceFrame:Show()
        if (IS_WOW_PROJECT_NOT_MAINLINE) then

        else
            if (DB_PLATER_RESOURCE_SHOW_DEPLATED) then
                Plater.UpdateResourcesFor_ShowDepleted(mainResourceFrame, resourceBar)
            end
        end
    end

--update the resources widgets when using the resources showing the background of depleted
--on this type, the location of each resource icon is precomputed
    function Plater.UpdateResourcesFor_ShowDepleted(mainResourceFrame, resourceBar)
        --get the table with the widgets created
        local widgetTable = resourceBar.widgets

        --get the total of widgets to show
        local totalWidgetsShown = UnitPowerMax("player", resourceBar.resourceId)
        --store the amount of widgets currently in use
        resourceBar.widgetsInUseAmount = totalWidgetsShown
        --set the amount of resources the player has
        resourceBar.lastResourceAmount = 0

        --get the default size of each widget
        local widgetWidth = CONST_WIDGET_WIDTH
        local widgetHeight = CONST_WIDGET_HEIGHT
        --sum of the width of all resources shown
        local totalWidth = 0

        local isGrowingToLeft = DB_PLATER_RESOURCE_GROW_DIRECTON == "left"
        local firstWidgetIndex = isGrowingToLeft and totalWidgetsShown or 1
        local firstWidgetIndex = 1 --I hate my self... ; probably is 1
        local firstWindowPoint = isGrowingToLeft and "right" or "left"

        --set the point of the first widget within the resource bar
        local firstWidget = widgetTable[firstWidgetIndex]
        firstWidget:SetPoint(firstWindowPoint, resourceBar, firstWindowPoint, 0, 0)
        local firstWidgetBackground = resourceBar.widgetsBackground[firstWidgetIndex]
        firstWidgetBackground:Show()
        firstWidgetBackground:ClearAllPoints()
        firstWidgetBackground:SetPoint(firstWindowPoint, resourceBar, firstWindowPoint, 0, 0)

        for i = 1, totalWidgetsShown do
            local thisResourceWidget
            local lastResourceWidget

            if (isGrowingToLeft and false) then
                i = abs(i-(totalWidgetsShown+1))
                thisResourceWidget = widgetTable[i]
                lastResourceWidget = widgetTable[i+1]
            else
                thisResourceWidget = widgetTable[i]
                lastResourceWidget = widgetTable[i-1]
            end

            thisResourceWidget:SetSize(widgetWidth, widgetHeight)

            if (i ~= firstWidgetIndex) then
                --adjust the point of widgets
                resourceBar.widgetsBackground[i]:Show()
                resourceBar.widgetsBackground[i]:ClearAllPoints()
                thisResourceWidget:ClearAllPoints()

                if (isGrowingToLeft) then
                    resourceBar.widgetsBackground[i]:SetPoint("right", lastResourceWidget, "left", -DB_PLATER_RESOURCE_PADDING, 0)
                    thisResourceWidget:SetPoint("right", lastResourceWidget, "left", -DB_PLATER_RESOURCE_PADDING, 0)
                else
                    resourceBar.widgetsBackground[i]:SetPoint("left", lastResourceWidget, "right", DB_PLATER_RESOURCE_PADDING, 0)
                    thisResourceWidget:SetPoint("left", lastResourceWidget, "right", DB_PLATER_RESOURCE_PADDING, 0)
                end

                --add the spacing into the total width occupied
                totalWidth = totalWidth + DB_PLATER_RESOURCE_PADDING
            end

            totalWidth = totalWidth + widgetWidth
        end

        for i = totalWidgetsShown+1, CONST_NUM_RESOURCES_WIDGETS do
            local thisResourceWidget = widgetTable[i]
            thisResourceWidget:Hide()
        end

        resourceBar:SetWidth(totalWidth)
        resourceBar:SetPoint("center", mainResourceFrame, "center", 0, 0)

        mainResourceFrame.currentResourceBarShown.updateResourceFunc(mainResourceFrame, mainResourceFrame.currentResourceBarShown, true)
    end


--realign the combat points after the amount of available combo points change
--this amount isn't the max amount of combo points but the current resources deom UnitPower
    local updateResources_noDepleted = function(resourceBar, currentResources)

        --main resource frame
        local mainResourceFrame = Plater.GetMainResourceFrame()

        --get the table with the widgets created to represent monk wind walker chi
        local widgetTable = resourceBar.widgets

        --get the default size of each widget
        local widgetWidth = CONST_WIDGET_WIDTH
        local widgetHeight = CONST_WIDGET_HEIGHT
        --sum of the width of all resources shown
        local totalWidth = 0

        for i = 1, currentResources do
            local thisResourceWidget = widgetTable[i]
            local lastResourceWidget = widgetTable[i-1]
            local thisResouceBackground = resourceBar.widgetsBackground[ i ]

            if (not thisResourceWidget.inUse) then
                thisResourceWidget:Show()
                thisResouceBackground:Show()

                thisResourceWidget.inUse = true
                thisResourceWidget.ShowAnimation:Play()
                thisResourceWidget:SetSize (widgetWidth, widgetHeight)
            end

            thisResourceWidget:ClearAllPoints()
            resourceBar.widgetsBackground[i]:ClearAllPoints()

            if (not lastResourceWidget) then --this is the first widget, anchor it into the left side of the frame
                resourceBar.widgetsBackground[i]:SetPoint("left", resourceBar, "left", 0, 0)
                thisResourceWidget:SetPoint("left", resourceBar, "left", 0, 0)

            else --no the first anchor into the latest widget
                resourceBar.widgetsBackground[i]:SetPoint("left", lastResourceWidget, "right", DB_PLATER_RESOURCE_PADDING, 0)
                thisResourceWidget:SetPoint("left", lastResourceWidget, "right", DB_PLATER_RESOURCE_PADDING, 0)
                totalWidth = totalWidth + DB_PLATER_RESOURCE_PADDING --add the gap into the total width size
            end

            lastResourceWidget = thisResourceWidget
            totalWidth = totalWidth + widgetWidth
        end

        --hide non used widgets
        for i = currentResources+1, CONST_NUM_RESOURCES_WIDGETS do
            local thisResourceWidget = widgetTable[i]
            thisResourceWidget.inUse = false
            thisResourceWidget:Hide()
            resourceBar.widgetsBackground[i]:Hide()
        end

        resourceBar:SetWidth(totalWidth)
        resourceBar:SetPoint(DB_PLATER_RESOURCE_GROW_DIRECTON, mainResourceFrame, DB_PLATER_RESOURCE_GROW_DIRECTON, 0, 0)

        --save the amount of resources
        resourceBar.lastResourceAmount = currentResources
    end


    local updateResources_withDepleted = function(resourceBar, currentResources)
        --calculate how many widgets need to be shown or need to be hide
        if (currentResources < resourceBar.lastResourceAmount) then --hide widgets
            for i = resourceBar.lastResourceAmount, currentResources+1, -1 do
                resourceBar.widgets[i]:Hide()
            end

        elseif (currentResources > resourceBar.lastResourceAmount) then --show widgets
            for i = resourceBar.lastResourceAmount + 1, currentResources do
                resourceBar.widgets[i]:Show()
                resourceBar.widgets[i].ShowAnimation:Play()
            end
        end

        --save the amount of resources
        resourceBar.lastResourceAmount = currentResources
    end


    function resourceWidgetsFunctions.OnComboPointsChanged(mainResourceFrame, resourceBar, forcedRefresh)
        --amount of resources the player has now
        local currentResources = UnitPower("player", resourceBar.resourceId)
        --resources amount got updated?
        if (currentResources == resourceBar.lastResourceAmount and not forcedRefresh) then
            return
        end

        --which update method to use
        if (DB_PLATER_RESOURCE_SHOW_DEPLATED) then
            return updateResources_withDepleted(resourceBar, currentResources)
        else
            return updateResources_noDepleted(resourceBar, currentResources)
        end
    end


--functions to create the class or spec resources widgets
resourceWidgetsFunctions.CreateMonkComboPoints = function(parent, frameName)

    --> create the main frame
    local MonkWWComboPoint = CreateFrame ("frame", frameName, parent)

    --create background
    local Background  = parent:CreateTexture (nil, "BORDER")
    Background:SetTexture ([[Interface\PLAYERFRAME\MonkUIAtlas]])
    Background:SetDrawLayer ("BORDER", 1)
    Background:SetPoint ("center", MonkWWComboPoint, "center", 0, 0)
    Background:SetSize (CONST_WIDGET_WIDTH, CONST_WIDGET_HEIGHT)
    Background:SetVertexColor (0.98431158065796, 0.99215465784073, 0.99999779462814, 0.99999779462814)
    Background:SetTexCoord (0.5513224029541, 0.61600479125977, 0.025, 0.1610000038147)
    parent.widgetsBackground [ #parent.widgetsBackground + 1 ] = Background

    --> single animation group
    local MainAnimationGroup = MonkWWComboPoint:CreateAnimationGroup()
    MainAnimationGroup:SetLooping ("NONE")
    MainAnimationGroup:SetToFinalAlpha(true)

    --> widgets:

    ----------------------------------------------

    local BallTexture  = MonkWWComboPoint:CreateTexture (nil, "ARTWORK")
    BallTexture:SetTexture ([[Interface\PLAYERFRAME\MonkUIAtlas]])
    BallTexture:SetDrawLayer ("ARTWORK", 0)
    BallTexture:SetPoint ("center", MonkWWComboPoint, "center", 0, 0)
    BallTexture:SetSize (CONST_WIDGET_WIDTH * 0.90, CONST_WIDGET_HEIGHT * 0.90)
    BallTexture:SetTexCoord (0.6427360534668, 0.70684181213379, 0.02872227191925, 0.15893713951111)

    --> animations for BallTexture

    BallTexture.scale = MainAnimationGroup:CreateAnimation ("SCALE")
    BallTexture.scale:SetTarget (BallTexture)
    BallTexture.scale:SetOrder (1)
    BallTexture.scale:SetDuration (0.195999994874)
    BallTexture.scale:SetFromScale (0, 0)
    BallTexture.scale:SetToScale (1, 1)
    BallTexture.scale:SetOrigin ("center", 0, 0)
    BallTexture.scale = MainAnimationGroup:CreateAnimation ("SCALE")
    BallTexture.scale:SetTarget (BallTexture)
    BallTexture.scale:SetOrder (2)
    BallTexture.scale:SetDuration (0.046000000089407)
    BallTexture.scale:SetFromScale (1, 1)
    BallTexture.scale:SetToScale (1.1999999284744, 1.1999999284744)
    BallTexture.scale:SetOrigin ("center", 0, 0)
    BallTexture.scale = MainAnimationGroup:CreateAnimation ("SCALE")
    BallTexture.scale:SetTarget (BallTexture)
    BallTexture.scale:SetOrder (3)
    BallTexture.scale:SetDuration (0.016000000759959)
    BallTexture.scale:SetFromScale (1.1999999284744, 1.1999999284744)
    BallTexture.scale:SetToScale (1, 1)
    BallTexture.scale:SetOrigin ("center", 0, 0)

    ----------------------------------------------

    local UpSpark  = MonkWWComboPoint:CreateTexture (nil, "OVERLAY")
    UpSpark:SetTexture ([[Interface\QUESTFRAME\ObjectiveTracker]])
    UpSpark:SetDrawLayer ("OVERLAY", 0)
    UpSpark:SetPoint ("center", MonkWWComboPoint, "center", 0, 0)
    UpSpark:SetSize (CONST_WIDGET_WIDTH * 0.89, CONST_WIDGET_HEIGHT * 0.89)
    UpSpark:SetTexCoord (0.7108479309082, 0.83905952453613, 0.0010000000149012, 0.12888721466064)

    --> animations for UpSpark

    UpSpark.scale = MainAnimationGroup:CreateAnimation ("SCALE")
    UpSpark.scale:SetTarget (UpSpark)
    UpSpark.scale:SetOrder (1)
    UpSpark.scale:SetDuration (0.195999994874)
    UpSpark.scale:SetFromScale (0, 0)
    UpSpark.scale:SetToScale (1, 1)
    UpSpark.scale:SetOrigin ("center", 0, 0)
    UpSpark.alpha = MainAnimationGroup:CreateAnimation ("ALPHA")
    UpSpark.alpha:SetTarget (UpSpark)
    UpSpark.alpha:SetOrder (1)
    UpSpark.alpha:SetDuration (0.195999994874)
    UpSpark.alpha:SetFromAlpha (0)
    UpSpark.alpha:SetToAlpha (0.40382900834084)
    UpSpark.rotation = MainAnimationGroup:CreateAnimation ("ROTATION")
    UpSpark.rotation:SetTarget (UpSpark)
    UpSpark.rotation:SetOrder (1)
    UpSpark.rotation:SetDuration (0.195999994874)
    UpSpark.rotation:SetDegrees (60)
    UpSpark.rotation:SetOrigin ("center", 0, 0)
    UpSpark.rotation = MainAnimationGroup:CreateAnimation ("ROTATION")
    UpSpark.rotation:SetTarget (UpSpark)
    UpSpark.rotation:SetOrder (2)
    UpSpark.rotation:SetDuration (0.195999994874)
    UpSpark.rotation:SetDegrees (15)
    UpSpark.rotation:SetOrigin ("center", 0, 0)
    UpSpark.alpha = MainAnimationGroup:CreateAnimation ("ALPHA")
    UpSpark.alpha:SetTarget (UpSpark)
    UpSpark.alpha:SetOrder (2)
    UpSpark.alpha:SetDuration (0.096000000834465)
    UpSpark.alpha:SetFromAlpha (0.4038280248642)
    UpSpark.alpha:SetToAlpha (0.25)
    UpSpark.rotation = MainAnimationGroup:CreateAnimation ("ROTATION")
    UpSpark.rotation:SetTarget (UpSpark)
    UpSpark.rotation:SetOrder (3)
    UpSpark.rotation:SetDuration (0.195999994874)
    UpSpark.rotation:SetDegrees (60)
    UpSpark.rotation:SetOrigin ("center", 0, 0)
    UpSpark.alpha = MainAnimationGroup:CreateAnimation ("ALPHA")
    UpSpark.alpha:SetTarget (UpSpark)
    UpSpark.alpha:SetOrder (3)
    UpSpark.alpha:SetDuration (0.195999994874)
    UpSpark.alpha:SetFromAlpha (0.25)
    UpSpark.alpha:SetToAlpha (0)

    ----------------------------------------------

    local BackgroundSpark  = MonkWWComboPoint:CreateTexture (nil, "BACKGROUND")
    BackgroundSpark:SetTexture ([[Interface\PVPFrame\PvPHonorSystem]])
    BackgroundSpark:SetDrawLayer ("BACKGROUND", 0)
    BackgroundSpark:SetPoint ("center", MonkWWComboPoint, "center", 0, 0)
    BackgroundSpark:SetSize (CONST_WIDGET_WIDTH * 1.39, CONST_WIDGET_HEIGHT * 1.39)
    BackgroundSpark:SetTexCoord (0.0096916198730469, 0.1160000038147, 0.43700000762939, 0.54200000762939)

    --> animations for BackgroundSpark

    BackgroundSpark.alpha = MainAnimationGroup:CreateAnimation ("ALPHA")
    BackgroundSpark.alpha:SetTarget (BackgroundSpark)
    BackgroundSpark.alpha:SetOrder (1)
    BackgroundSpark.alpha:SetDuration (0.195999994874)
    BackgroundSpark.alpha:SetFromAlpha (0)
    BackgroundSpark.alpha:SetToAlpha (1)
    BackgroundSpark.rotation = MainAnimationGroup:CreateAnimation ("ROTATION")
    BackgroundSpark.rotation:SetTarget (BackgroundSpark)
    BackgroundSpark.rotation:SetOrder (1)
    BackgroundSpark.rotation:SetDuration (0.195999994874)
    BackgroundSpark.rotation:SetDegrees (2)
    BackgroundSpark.rotation:SetOrigin ("center", 0, 0)
    BackgroundSpark.alpha = MainAnimationGroup:CreateAnimation ("ALPHA")
    BackgroundSpark.alpha:SetTarget (BackgroundSpark)
    BackgroundSpark.alpha:SetOrder (2)
    BackgroundSpark.alpha:SetDuration (0.195999994874)
    BackgroundSpark.alpha:SetFromAlpha (0.34612736105919)
    BackgroundSpark.alpha:SetToAlpha (0.24995632469654)
    BackgroundSpark.alpha = MainAnimationGroup:CreateAnimation ("ALPHA")
    BackgroundSpark.alpha:SetTarget (BackgroundSpark)
    BackgroundSpark.alpha:SetOrder (3)
    BackgroundSpark.alpha:SetDuration (0.195999994874)
    BackgroundSpark.alpha:SetFromAlpha (0.25)
    BackgroundSpark.alpha:SetToAlpha (0)

    --> test the animation
    --MainAnimationGroup:Play()

    MonkWWComboPoint.ShowAnimation = MainAnimationGroup
    return MonkWWComboPoint
end
