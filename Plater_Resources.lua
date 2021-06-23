
local Plater = _G.Plater
local GameCooltip = GameCooltip2
local DF = DetailsFramework
local _
local UnitPower = _G.UnitPower
local UnitPowerMax = _G.UnitPowerMax
local abs = _G.abs

local IS_WOW_PROJECT_MAINLINE = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
local IS_WOW_PROJECT_NOT_MAINLINE = WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE

--when 'runOnNextFrame' is used instead of 'C_Timer.After', it's to indicate the func will skip the current frame and run on the next one
local runOnNextFrame = function (func)
    _G.C_Timer.After(0, func)
end

--[=[
    resource frame: the frame which is anchored into the health bar, controls the size, scale and position
    resource bar: is anchored (setallpoints) into the resource frame, hold all combo points textures and animations
    widget: wildcard to reference a texture, fontstring or a frame containing textures and fontstring
--]=]


--default settings
--[=[
--alignment settings
resource_padding = 1,

--size settings
block_size = 20,
block_texture_background = "Interface\\COMMON\\Indicator-Gray"
block_texture_artwork = "Interface\\COMMON\\Indicator-Yellow"
block_texture_overlay = "Interface\\CHARACTERFRAME\\TempPortraitAlphaMaskSmall"
--]=]


--[=[
- quando o plater é iniciado, criar um unico frame para o resource que irá pular para a nameplate que é alvo
- quando uma nameplate é mostrada no jogo, confere se o novo resource esta ativo e se ele é mostrado na nameplate alvo e se o jogador tem spec que usa
- quando o alvo é mudado, faz as checagens acima tbm
- se é mostrado na personal bar, apenas adicionar ela lá

- funcões que serão necessárias:
    - criação do frame do resource quando o plater for iniciado (CreateResourceBar)
    - precisa mostra o resource em uma nameplate (UpdateResourceBar)
    - verifica se a spec que o jogador esta usando possui uma barra de resource

- cache e verificações no codigo do plater
    - variaveis que precisam de cache: esta usando o novo resource e se esta usando target (ou no personal bar)
    - ao mudar de target >  conferir se esta usando o novo resource > conferir se esta usando resource em nameplate > conferir se a namepalte é o alvo
    - se a spec do jogador não usar uma barra de resource, por false que o jogador esta usando o novo resource
--]=]


local CONST_NUM_COMBO_POINTS = 10
local CONST_WIDGET_WIDTH = 20
local CONST_WIDGET_HEIGHT = 20

local animationFunctions = {}

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
            if (not _G.PlaterNameplatesResourceFrame) then
                C_Timer.After (2, Plater.CreatePlaterResourceFrame)
            end
        end
    end

--base frame for the class or spec resource bar, it's a child of the main frame called 'PlaterNameplatesResourceFrame'
--the function passed is responsible to build textures and animations
    local create_resource_bar = function (parent, frameName, func)
        local resourceBar = CreateFrame("frame", frameName, parent)

        resourceBar:EnableMouse (false)
        resourceBar:EnableMouseWheel (false)

        --store all widgets
        resourceBar.widgets = {}
        --store all background textures
        resourceBar.widgetsBackground = {}

        --create widgets which are frames holding textures and animations
        for i = 1, CONST_NUM_COMBO_POINTS do
            local newWidget = func(resourceBar, "$parentCPO" .. i)
            resourceBar.widgets [#resourceBar.widgets + 1] = newWidget
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


--separated resources functions for class and specs
    local resource_monk = function(platerResourceFrame)
        --platerResourceFrame.resourceBars [268] = create_resource_bar (platerResourceFrame, "$parentMonk1Resource") --brewmaster chi bar
        local newResourceBar = create_resource_bar (platerResourceFrame, "$parentMonk2Resource", animationFunctions.CreateMonkComboPoints) --windwalker chi
        platerResourceFrame.resourceBars [269] = newResourceBar
        tinsert (platerResourceFrame.allResourceBars, newResourceBar)
        newResourceBar.resourceId = SPELL_POWER_CHI
        newResourceBar.updateResourceFunc = animationFunctions.OnComboPointsChanged
    end

--each function create a resource frame for its class or spec
    local resource_mage_arcane = function(platerResourceFrame)
        local newResourceBar = create_resource_bar (platerResourceFrame, "$parentArcaneResource")
        platerResourceFrame.resourceBars [62] = newResourceBar
        tinsert (platerResourceFrame.allResourceBars, newResourceBar)
        newResourceBar.resourceId = SPELL_POWER_ARCANE_CHARGES
        newResourceBar.updateResourceFunc = false
    end

    local resource_rogue_druid_cpoints = function(platerResourceFrame)
        local newResourceBar = create_resource_bar (platerResourceFrame, "$parentRogueResource")
        newResourceBar.resourceId = SPELL_POWER_COMBO_POINTS2
        tinsert (platerResourceFrame.allResourceBars, newResourceBar)

        --rogue
        if (Plater.PlayerClass == "DRUID") then
            platerResourceFrame.resourceBars ["ROGUE"] = newResourceBar
            newResourceBar.classId = "ROGUE"
            newResourceBar.updateResourceFunc = false
        
        --druid
        elseif (Plater.PlayerClass == "DRUID") then
            platerResourceFrame.resourceBars [103] = newResourceBar
            newResourceBar.classId = "DRUID"
            newResourceBar.updateResourceFunc = false
        end
    end

    local resource_warlock = function(platerResourceFrame)
        local newResourceBar = create_resource_bar (platerResourceFrame, "$parentWarlockResource")
        platerResourceFrame.resourceBars ["WARLOCK"] = newResourceBar
        tinsert (platerResourceFrame.allResourceBars, newResourceBar)
        newResourceBar.resourceId = SPELL_POWER_SOUL_SHARDS
        newResourceBar.updateResourceFunc = false
        newResourceBar.classId = "WARLOCK"
    end

    local resource_paladin = function(platerResourceFrame)
        local newResourceBar = create_resource_bar (platerResourceFrame, "$parentPaladinResource")
        platerResourceFrame.resourceBars [70] = newResourceBar
        tinsert (platerResourceFrame.allResourceBars, newResourceBar)
        newResourceBar.resourceId = SPELL_POWER_HOLY_POWER
        newResourceBar.updateResourceFunc = false
        newResourceBar.classId = "PALADIN"
    end

    local resource_dk = function(platerResourceFrame)
        local newResourceBar = create_resource_bar (platerResourceFrame, "$parentDKResource")
        platerResourceFrame.resourceBars ["DEATHKNIGHT"] = newResourceBar
        tinsert (platerResourceFrame.allResourceBars, newResourceBar)
        newResourceBar.resourceId = SPELL_POWER_RUNES
        newResourceBar.updateResourceFunc = false
        newResourceBar.classId = "DEATHKNIGHT"
    end


--this funtion is called once at the logon, it'll create the resource frames for the class
    function Plater.CreatePlaterResourceFrame()

        if (not DB_USE_PLATER_RESOURCE_BAR) then
            return
        end

        if (PlaterNameplatesResourceFrame) then
            return
        end

        --create a frame attached to UIParent, this frame is the fondation for the resource bar
        local platerResourceFrame = CreateFrame("frame", "PlaterNameplatesResourceFrame")

        --store the resources bars created for the class or spec (hash table)
        platerResourceFrame.resourceBars = {}
        --store all resource bars created (index table)
        platerResourceFrame.allResourceBars = {}
        
        --grab the player class
        local playerClass = Plater.PlayerClass

        if (IS_WOW_PROJECT_NOT_MAINLINE) then --classic

        else
            if (playerClass == "MAGE") then
                resource_mage_arcane(platerResourceFrame)

            elseif (playerClass == "ROGUE" or playerClass == "DRUID") then
                resource_rogue_druid_cpoints(platerResourceFrame)

            elseif (playerClass == "WARLOCK") then
                resource_warlock(platerResourceFrame)

            elseif (playerClass == "PALADIN") then
                resource_paladin(platerResourceFrame)

            elseif (playerClass == "DEATHKNIGHT") then
                resource_dk(platerResourceFrame)

            elseif (playerClass == "MONK") then
                resource_monk(platerResourceFrame)
            end
        end

        --run the function to update the 
        platerResourceFrame:SetScript ("OnEvent", function(self, event, ...)
            self.currentBarShown.updateResourceFunc(self, self.currentBarShown)
        end)

    end

    function Plater.ResourceFrame_EnableEvents()
        local platerResourceFrame = _G.PlaterNameplatesResourceFrame
		platerResourceFrame:RegisterUnitEvent ("UNIT_POWER_FREQUENT", "player")
        platerResourceFrame:RegisterUnitEvent ("UNIT_MAXPOWER", "player")
    end

    function Plater.ResourceFrame_DisableEvents()
        local platerResourceFrame = _G.PlaterNameplatesResourceFrame
		platerResourceFrame:UnregisterEvent ("UNIT_POWER_FREQUENT")
        platerResourceFrame:UnregisterEvent ("UNIT_MAXPOWER")
    end


--called when use plater resource bar is disabled or when no match on rules to show it
--only called from inside this file
    function Plater.HidePlaterResourceFrame()
        if (PlaterNameplatesResourceFrame) then
            Plater.ResourceFrame_DisableEvents()
            return PlaterNameplatesResourceFrame:Hide()
        end
    end


    local canUsePlaterResourceFrame = function()
		if IS_WOW_PROJECT_NOT_MAINLINE then return end
		
        --nameplate which will have the resource bar
        local nameplateAnchor

        if (not DB_USE_PLATER_RESOURCE_BAR) then
            return Plater.HidePlaterResourceFrame()

        elseif (not DB_PLATER_RESOURCE_BAR_ON_PERSONAL) then
            --target nameplate
            nameplateAnchor = C_NamePlate.GetNamePlateForUnit ("target")
            --if the player has no target, this will return nil
            if (not nameplateAnchor) then
                return Plater.HidePlaterResourceFrame()
            end

        else
            --personal bar
            nameplateAnchor = C_NamePlate.GetNamePlateForUnit ("player")
            --if the player nameplate does not exists, just quit
            if (not nameplateAnchor) then
                return Plater.HidePlaterResourceFrame()
            end
        end

        if (IS_WOW_PROJECT_NOT_MAINLINE) then

        else

            local specIndex = GetSpecializationInfo (GetSpecialization())

            if (specIndex) then
                local playerClass = Plater.PlayerClass

                --check if the resource bar is used by all specs in the player class by comparing it to the class name
                local resourceBarByClass = _G.PlaterNameplatesResourceFrame.resourceBars[playerClass]
                if (resourceBarByClass) then
                    resourceBarByClass.resourceClass = playerClass
                    resourceBarByClass.resourceSpec = false

                    Plater.ResourceFrame_EnableEvents()
                    Plater.UpdatePlaterResourceFrame(nameplateAnchor)
                    return Plater.UpdatePlaterResourceBar(nameplateAnchor, resourceBarByClass)
                end

                --check if the current player spec uses a resource bar
                local resourceBarBySpec = _G.PlaterNameplatesResourceFrame.resourceBars[specIndex]
                if (resourceBarBySpec) then
                    resourceBarBySpec.resourceClass = false
                    resourceBarBySpec.resourceSpec = specIndex

                    Plater.ResourceFrame_EnableEvents()
                    Plater.UpdatePlaterResourceFrame(nameplateAnchor)
                    return Plater.UpdatePlaterResourceBar(nameplateAnchor, resourceBarBySpec)
                end
            else
                --if no specialization, player might be low level
                if (UnitLevel("player") < 10) then
                    --should get by class?
                    if (playerClass == "ROGUE") then
                        Plater.ResourceFrame_EnableEvents()
                        Plater.UpdatePlaterResourceFrame(nameplateAnchor)
                        return Plater.UpdatePlaterResourceBar(nameplateAnchor, _G.PlaterNameplatesResourceFrame.resourceBars ["ROGUE"])
                    end
                end
            end
        end

        return Plater.HidePlaterResourceFrame()
    end


--currently is called from:
--player spec change (PLAYER_SPECIALIZATION_CHANGED)
--player target has changed
--decides if the resource is shown or not
    function Plater.CanUsePlaterResourceFrame()
        return runOnNextFrame(canUsePlaterResourceFrame)
    end


--called when 'CanUsePlaterResourceFrame' gives green flag to show the resource bar
--this function receives the nameplate where the resource bar will be attached
    function Plater.UpdatePlaterResourceFrame(plateFrame)
		if IS_WOW_PROJECT_NOT_MAINLINE then return end

        --get the main resource frame
        local platerResourceFrame = _G.PlaterNameplatesResourceFrame

        --make its parent be the healthBar from the nameplate where it is anchored to
        platerResourceFrame:SetParent(plateFrame.unitFrame.healthBar)

        --update the resource anchor
        Plater.SetAnchor(platerResourceFrame, DB_PLATER_RESOURCE_BAR_ANCHOR)

        --update the size
        local healthBarWidth = plateFrame.unitFrame.healthBar:GetWidth()
        platerResourceFrame:SetWidth(healthBarWidth)
        platerResourceFrame:SetHeight(2)
        platerResourceFrame:SetScale(DB_PLATER_RESOURCE_BAR_SCALE)
    end


--called when 'CanUsePlaterResourceFrame' gives green flag to show the resource bar
--this funtion receives the nameplate and the bar to show
    function Plater.UpdatePlaterResourceBar(plateFrame, resourceBar)

        --main resource frame
        local platerResourceFrame = _G.PlaterNameplatesResourceFrame
        
        --hide all resourcebar widgets
        for i = 1, #resourceBar.widgets do
            resourceBar.widgets[i]:Hide()
            resourceBar.widgets[i].numberId:SetShown(DB_PLATER_RESOURCE_SHOW_NUMBER)
        end
        
        --check if the bar already shown isn't the bar asking to be shown
        if (platerResourceFrame.currentBarShown) then
            if (platerResourceFrame.currentBarShown ~= resourceBar) then
                platerResourceFrame.currentBarShown:Hide()
            end
        end

        platerResourceFrame.currentBarShown = resourceBar

        if (DB_PLATER_RESOURCE_SHOW_NUMBER) then

        end

        --show the resource bar
        resourceBar:Show()
        resourceBar:SetHeight(1)
        platerResourceFrame:Show()
        
        if (IS_WOW_PROJECT_NOT_MAINLINE) then


        else
            if (DB_PLATER_RESOURCE_SHOW_DEPLATED) then
                Plater.UpdateResourcesFor_ShowDepleted(platerResourceFrame, resourceBar)
            end
        end
    end

--update the resources widgets when using the resources showing the background of depleted
--on this type, the location of each resource icon is precomputed
    function Plater.UpdateResourcesFor_ShowDepleted(platerResourceFrame, resourceBar)
        --get the table with the widgets created to represent monk wind walker chi
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
        local firstWidgetIndex = 1
        local firstWindowPoint = isGrowingToLeft and "right" or "left"

        local firstWidget = widgetTable[firstWidgetIndex]
        firstWidget:SetPoint(firstWindowPoint, resourceBar, firstWindowPoint, 0, 0)
        resourceBar.widgetsBackground[ firstWidgetIndex ]:Show()
        resourceBar.widgetsBackground[ firstWidgetIndex ]:ClearAllPoints()
        resourceBar.widgetsBackground[ firstWidgetIndex ]:SetPoint(firstWindowPoint, resourceBar, firstWindowPoint, 0, 0)

        for i = 1, totalWidgetsShown do
            local thisResourceWidget
            local lastResourceWidget

            if (isGrowingToLeft and false) then
                i = abs(i-(totalWidgetsShown+1))
                thisResourceWidget = widgetTable[i]
                lastResourceWidget = widgetTable[i + 1]
            else
                thisResourceWidget = widgetTable[i]
                lastResourceWidget = widgetTable[i - 1]
            end

            thisResourceWidget:SetSize (widgetWidth, widgetHeight)

            if (i ~= firstWidgetIndex) then
                resourceBar.widgetsBackground[ i ]:Show()
                resourceBar.widgetsBackground[ i ]:ClearAllPoints()
                thisResourceWidget:ClearAllPoints()

                if (isGrowingToLeft) then
                    resourceBar.widgetsBackground[ i ]:SetPoint("right", lastResourceWidget, "left", -DB_PLATER_RESOURCE_PADDING, 0)
                    thisResourceWidget:SetPoint("right", lastResourceWidget, "left", -DB_PLATER_RESOURCE_PADDING, 0)
                else
                    resourceBar.widgetsBackground[ i ]:SetPoint("left", lastResourceWidget, "right", DB_PLATER_RESOURCE_PADDING, 0)
                    thisResourceWidget:SetPoint("left", lastResourceWidget, "right", DB_PLATER_RESOURCE_PADDING, 0)
                end

                --add the spacing into the total width occupied
                totalWidth = totalWidth + DB_PLATER_RESOURCE_PADDING
            end

            totalWidth = totalWidth + widgetWidth
        end

        for i = totalWidgetsShown+1, CONST_NUM_COMBO_POINTS do
            local thisResourceWidget = widgetTable[i]
            thisResourceWidget:Hide()
        end

        resourceBar:SetWidth(totalWidth)
        resourceBar:SetPoint("center", platerResourceFrame, "center", 0, 0)

        platerResourceFrame.currentBarShown.updateResourceFunc(platerResourceFrame, platerResourceFrame.currentBarShown, true)
    end


--realign the combat points after the amount of available combo points change
--this amount isn't the max amount of combo points but the current resources deom UnitPower
    local updateResources_noDepleted = function(resourceBar, currentResources)

        --main resource frame
        local platerResourceFrame = _G.PlaterNameplatesResourceFrame

        --get the table with the widgets created to represent monk wind walker chi
        local widgetTable = resourceBar.widgets

        --get the default size of each widget
        local widgetWidth = CONST_WIDGET_WIDTH
        local widgetHeight = CONST_WIDGET_HEIGHT
        --sum of the width of all resources shown
        local totalWidth = 0

        for i = 1, currentResources do
            local thisResourceWidget = widgetTable[i]
            local lastResourceWidget = widgetTable[i - 1]
            local thisResouceBackground = resourceBar.widgetsBackground[ i ]

            if (not thisResourceWidget.inUse) then
                thisResourceWidget:Show()
                thisResouceBackground:Show()

                thisResourceWidget.inUse = true
                thisResourceWidget.ShowAnimation:Play()
                thisResourceWidget:SetSize (widgetWidth, widgetHeight)
            end
            
            thisResourceWidget:ClearAllPoints()
            resourceBar.widgetsBackground[ i ]:ClearAllPoints()

            if (not lastResourceWidget) then --this is the first widget, anchor it into the left side of the frame
                resourceBar.widgetsBackground[ i ]:SetPoint("left", resourceBar, "left", 0, 0)
                thisResourceWidget:SetPoint("left", resourceBar, "left", 0, 0)

            else --no the first anchor into the latest widget
                resourceBar.widgetsBackground[ i ]:SetPoint("left", lastResourceWidget, "right", DB_PLATER_RESOURCE_PADDING, 0)
                thisResourceWidget:SetPoint("left", lastResourceWidget, "right", DB_PLATER_RESOURCE_PADDING, 0)
                totalWidth = totalWidth + DB_PLATER_RESOURCE_PADDING --add the gap into the total width size
            end

            lastResourceWidget = thisResourceWidget
            totalWidth = totalWidth + widgetWidth
        end

        --hide non used widgets
        for i = currentResources+1, CONST_NUM_COMBO_POINTS do
            local thisResourceWidget = widgetTable[i]
            thisResourceWidget.inUse = false
            thisResourceWidget:Hide()
            resourceBar.widgetsBackground[ i ]:Hide()
        end

        resourceBar:SetWidth(totalWidth)
        resourceBar:SetPoint(DB_PLATER_RESOURCE_GROW_DIRECTON, platerResourceFrame, DB_PLATER_RESOURCE_GROW_DIRECTON, 0, 0)

        --save the amount of resources
        resourceBar.lastResourceAmount = currentResources
    end


    local updateResources_withDepleted = function(resourceBar, currentResources)
        --calculate how many widgets need to be shown or need to be hide
        if (currentResources < resourceBar.lastResourceAmount) then --hide widgets
            for i = resourceBar.lastResourceAmount, currentResources+1, -1 do
                resourceBar.widgets[ i ]:Hide()
            end
        
        elseif (currentResources > resourceBar.lastResourceAmount) then --show widgets
            for i = resourceBar.lastResourceAmount + 1, currentResources do
                resourceBar.widgets[ i ]:Show()
                resourceBar.widgets[ i ].ShowAnimation:Play()
            end
        end

        --save the amount of resources
        resourceBar.lastResourceAmount = currentResources
    end


    function animationFunctions.OnComboPointsChanged(platerResourceFrame, resourceBar, forcedRefresh)
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
animationFunctions.CreateMonkComboPoints = function(parent, frameName)

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
