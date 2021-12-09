
local Plater = _G.Plater
local GameCooltip = GameCooltip2
local DF = DetailsFramework
local _
local UnitPower = _G.UnitPower
local UnitPowerMax = _G.UnitPowerMax
local abs = _G.abs

local IS_WOW_PROJECT_MAINLINE = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
local IS_WOW_PROJECT_NOT_MAINLINE = WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE
local IS_WOW_PROJECT_CLASSIC_ERA = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
local IS_WOW_PROJECT_CLASSIC_TBC = WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC

local CONST_SPECID_MONK_WINDWALKER = 269
local CONST_SPECID_MAGE_ARCANE = 62
local CONST_SPECID_ROGUE_ASSASSINATION = 259
local CONST_SPECID_ROGUE_OUTLAW = 260
local CONST_SPECID_ROGUE_SUBTLETY = 261
local CONST_SPECID_DRUID_FERAL = 103
local CONST_SPECID_PALADIN_HOLY = 65
local CONST_SPECID_PALADIN_PROTECTION = 66
local CONST_SPECID_PALADIN_RETRIBUTION = 70
local CONST_SPECID_WARLOCK_AFFLICTION = 265
local CONST_SPECID_WARLOCK_DEMONOLOGY = 266
local CONST_SPECID_WARLOCK_DESTRUCTION = 267
local CONST_SPECID_DK_UNHOLY = 252
local CONST_SPECID_DK_FROST = 251
local CONST_SPECID_DK_BLOOD = 250

local CONST_NUM_RESOURCES_WIDGETS = 10
local CONST_WIDGET_WIDTH = 20
local CONST_WIDGET_HEIGHT = 20

--store the time of the last combo point gained in order to play the show animation when a combo point is awarded
local lastComboPointGainedTime = 0

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

--this table store the resource creation functions, these functions are declared in the Plater_Resources_Frames file
local resourceWidgetCreationFunctions = {}
function Plater.Resources.GetResourceWidgetCreationTable()
    return resourceWidgetCreationFunctions
end

function Plater.Resources.GetCreateResourceWidgetFunctionForSpecId(specId)
    --function to create the resource bar
    return resourceWidgetCreationFunctions[specId]
end

--store functions to create the widgets for the class and the function to update them
local resourceWidgetsFunctions = {} --this table has created when only monk combo point was finished, perhaps in the future this need to be more organized

--store functions used to create the resource bar for each type of resource
local resourceBarCreateFuncByEnumName = {}

--power
local PowerEnum = Enum.PowerType
local SPELL_POWER_MANA = SPELL_POWER_MANA or (PowerEnum and PowerEnum.Mana) or 0
local SPELL_POWER_RAGE = SPELL_POWER_RAGE or (PowerEnum and PowerEnum.Rage) or 1
local SPELL_POWER_FOCUS = SPELL_POWER_FOCUS or (PowerEnum and PowerEnum.Focus) or 2
local SPELL_POWER_ENERGY = SPELL_POWER_ENERGY or (PowerEnum and PowerEnum.Energy) or 3
local SPELL_POWER_COMBO_POINTS = SPELL_POWER_COMBO_POINTS or (PowerEnum and PowerEnum.ComboPoints) or 4
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

local specsWithResource =  {
    [CONST_SPECID_MONK_WINDWALKER] = true,
    [CONST_SPECID_MAGE_ARCANE] = true,
    [CONST_SPECID_ROGUE_ASSASSINATION] = true,
    [CONST_SPECID_ROGUE_OUTLAW] = true,
    [CONST_SPECID_ROGUE_SUBTLETY] = true,
    [CONST_SPECID_DRUID_FERAL] = true,
    [CONST_SPECID_PALADIN_HOLY] = true,
    [CONST_SPECID_PALADIN_PROTECTION] = true,
    [CONST_SPECID_PALADIN_RETRIBUTION] = true,
    [CONST_SPECID_WARLOCK_AFFLICTION] = true,
    [CONST_SPECID_WARLOCK_DEMONOLOGY] = true,
    [CONST_SPECID_WARLOCK_DESTRUCTION] = true,
    [CONST_SPECID_DK_UNHOLY] = true,
    [CONST_SPECID_DK_FROST] = true,
    [CONST_SPECID_DK_BLOOD] = true,
}



local resourceTypes = {
    [SPELL_POWER_INSANITY] = true, --shadow priest
    [SPELL_POWER_CHI] = true, --monk
    [SPELL_POWER_HOLY_POWER] = true, --paladins
    [SPELL_POWER_LUNAR_POWER] = true, --balance druids
    [SPELL_POWER_SOUL_SHARDS] = true, --warlock affliction
    [SPELL_POWER_COMBO_POINTS] = true, --combo points
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
    [SPELL_POWER_COMBO_POINTS] = SPELL_POWER_ENERGY, --combo points
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

-- the power types which update functions should update on
local classPowerTypes = {
    ["ROGUE"] = "COMBO_POINTS",
    ["MONK"] = "CHI",
    ["PALADIN"] = "HOLY_POWER",
    ["WARLOCK"] = "SOUL_SHARDS",
    ["DRUID"] = "COMBO_POINTS",
    ["MAGE"] = "ARCANE_CHARGES",
    ["DEATHKNIGHT"] = "RUNES",
}

local doesClassUseResource = function(class)
    return classPowerTypes[class]
end

local doesSpecUseResource = function(specId)
    return specsWithResource[specId]
end

--these power types can active a combo point function
local powerTypesFilter = {
    ["COMBO_POINTS"] = true,
    ["CHI"] = true,
    ["HOLY_POWER"] = true,
    ["SOUL_SHARDS"] = true,
    ["ARCANE_CHARGES"] = true,
    ["RUNES"] = true,
}

local CONST_ENUMNAME_COMBOPOINT = "ComboPoints"
local CONST_ENUMNAME_HOLYPOWER = "HolyPower"
local CONST_ENUMNAME_RUNES = "Runes"
local CONST_ENUMNAME_ARCANECHARGES = "ArcaneCharges"
local CONST_ENUMNAME_CHI = "Chi"
local CONST_ENUMNAME_SOULCHARGES = "SoulShards"

--cache
local DB_USE_PLATER_RESOURCE_BAR = false
local DB_PLATER_RESOURCE_BAR_ON_PERSONAL = false
local DB_PLATER_RESOURCE_BAR_ANCHOR

--local DB_PLATER_RESOURCE_BAR_HEIGHT
local DB_PLATER_RESOURCE_BAR_SCALE
local DB_PLATER_RESOURCE_PADDING
local DB_PLATER_RESOURCE_GROW_DIRECTON
local DB_PLATER_RESOURCE_SHOW_DEPLETED
local DB_PLATER_RESOURCE_SHOW_NUMBER

local getPlateFrameForResourceFrame = function()
    local plateFrame = nil
    if (not DB_USE_PLATER_RESOURCE_BAR) then
        -- do nothing

    elseif (not DB_PLATER_RESOURCE_BAR_ON_PERSONAL or IS_WOW_PROJECT_NOT_MAINLINE) then
        --target nameplate
        plateFrame = C_NamePlate.GetNamePlateForUnit("target")

    elseif (IS_WOW_PROJECT_MAINLINE) then
        --personal bar
        plateFrame = C_NamePlate.GetNamePlateForUnit("player")
    end

    return plateFrame
end

--Plater.Resources

--when plater in the main file refreshes its upvalues, this function is also called
--called from plater.lua on Plater.RefreshDBUpvalues()
    function Plater.Resources.RefreshResourcesDBUpvalues()
        local profile = Plater.db.profile

        --resourceGlobalSettings: where options for all resources are stored
        local resourceGlobalSettings = profile.resources_settings.global_settings

        DB_USE_PLATER_RESOURCE_BAR = resourceGlobalSettings.show
        DB_PLATER_RESOURCE_BAR_ON_PERSONAL = resourceGlobalSettings.personal_bar
        DB_PLATER_RESOURCE_BAR_ANCHOR = resourceGlobalSettings.anchor
        --DB_PLATER_RESOURCE_BAR_HEIGHT = resourceGlobalSettings.width
        DB_PLATER_RESOURCE_BAR_SCALE = resourceGlobalSettings.scale
        DB_PLATER_RESOURCE_PADDING = resourceGlobalSettings.padding
        DB_PLATER_RESOURCE_GROW_DIRECTON = resourceGlobalSettings.grow_direction
        DB_PLATER_RESOURCE_SHOW_DEPLETED = resourceGlobalSettings.show_depleted
        DB_PLATER_RESOURCE_SHOW_NUMBER = resourceGlobalSettings.show_number

        --check if the frame exists if the player opt-in to use plater resources
        if (DB_USE_PLATER_RESOURCE_BAR) then
            local mainResourceFrame = Plater.Resources.GetMainResourceFrame()
            if (not mainResourceFrame) then
                C_Timer.After(0, function()
                    --create on next frame
                    Plater.Resources.CreateMainResourceFrame()
                    Plater.Resources.UpdateResourceFrameToUse()
                    Plater.Resources.UpdateResourceFramePosition()
                end)
            else
                Plater.Resources.CreateMainResourceFrame()
                Plater.Resources.UpdateResourceFrameToUse()
                Plater.Resources.UpdateResourceFramePosition()

                local resourceBar = Plater.Resources.GetResourceBarInUse()
                --characters without resources to show may not have a resource bar created for them
                if (not resourceBar) then
                    return
                end

                --amount of resources the player has now
                local currentResources = UnitPower("player", Plater.Resources.playerResourceId)

                --resources amount got updated?
                if (currentResources) then
                    --which update method to use
                    if (DB_PLATER_RESOURCE_SHOW_DEPLETED) then
                        Plater.Resources.UpdateResources_WithDepleted(resourceBar, currentResources)
                    else
                        Plater.Resources.UpdateResources_NoDepleted(resourceBar, currentResources)
                    end
                end

                --update the resource bar
                Plater.Resources.UpdateResourceBar(_, resourceBar)
            end
        else
            --player opt-out of using plater resources on this character
            Plater.Resources.HidePlaterResourceFrame()
        end
    end

--base frame for the class or spec resource bar, it's a child of the main resource frame 'PlaterNameplatesResourceFrame'
--the function passed is responsible to build textures and animations
    local createResourceBar = function(parent, frameName, func, widgetWidth, widgetHeight)
        local resourceBar = CreateFrame("frame", frameName, parent)
        resourceBar:EnableMouse(false)
        resourceBar:EnableMouseWheel(false)

        --store all widgets
        resourceBar.widgets = {}
        --store all background textures (created on plater_resources_frames), this texture is the default texture shown when the combo point isn't active
        resourceBar.widgetsBackground = {}

        --create widgets which are frames holding textures and animations
        if (func) then
            for i = 1, CONST_NUM_RESOURCES_WIDGETS do
                local newWidget = func(resourceBar, "$parentCPO" .. i)
                resourceBar.widgets[#resourceBar.widgets + 1] = newWidget
                newWidget:EnableMouse(false)
                newWidget:EnableMouseWheel(false)
                newWidget:SetSize(widgetWidth or CONST_WIDGET_WIDTH, widgetHeight or CONST_WIDGET_HEIGHT)
                newWidget:Hide()

                local CPOID = DF:CreateLabel(newWidget, i, 12, "white", nil, nil, nil, "overlay")
                CPOID:SetPoint("bottom", newWidget, "top", 0, 5)
                CPOID:Hide()
                newWidget.numberId = CPOID
            end
        end

        return resourceBar
    end

--> functions for class and specs resources
    resourceBarCreateFuncByEnumName[CONST_ENUMNAME_CHI] = function(mainResourceFrame)
        local resourceWidgetCreationFunc = Plater.Resources.GetCreateResourceWidgetFunctionForSpecId(CONST_SPECID_MONK_WINDWALKER)
        local newResourceBar = createResourceBar(mainResourceFrame, "$parentMonk2Resource", resourceWidgetCreationFunc) --windwalker chi
        mainResourceFrame.resourceBars[CONST_SPECID_MONK_WINDWALKER] = newResourceBar
        newResourceBar.resourceId = SPELL_POWER_CHI
        newResourceBar.updateResourceFunc = resourceWidgetsFunctions.OnResourceChanged
        tinsert(mainResourceFrame.allResourceBars, newResourceBar)
        mainResourceFrame.resourceBarsByEnumName[CONST_ENUMNAME_CHI] = newResourceBar
        return newResourceBar
    end

    resourceBarCreateFuncByEnumName[CONST_ENUMNAME_ARCANECHARGES] = function(mainResourceFrame)
        local resourceWidgetCreationFunc = Plater.Resources.GetCreateResourceWidgetFunctionForSpecId(CONST_SPECID_MAGE_ARCANE)
        local newResourceBar = createResourceBar(mainResourceFrame, "$parentArcaneMageResource", resourceWidgetCreationFunc)
        mainResourceFrame.resourceBars[CONST_SPECID_MAGE_ARCANE] = newResourceBar
        newResourceBar.resourceId = SPELL_POWER_ARCANE_CHARGES
        newResourceBar.updateResourceFunc = resourceWidgetsFunctions.OnResourceChanged
        tinsert(mainResourceFrame.allResourceBars, newResourceBar)
        mainResourceFrame.resourceBarsByEnumName[CONST_ENUMNAME_ARCANECHARGES] = newResourceBar
        return newResourceBar
    end

    resourceBarCreateFuncByEnumName[CONST_ENUMNAME_COMBOPOINT] = function(mainResourceFrame)
        local resourceWidgetCreationFunc = Plater.Resources.GetCreateResourceWidgetFunctionForSpecId(CONST_SPECID_ROGUE_OUTLAW)
        local newResourceBar = createResourceBar(mainResourceFrame, "$parentRogueResource", resourceWidgetCreationFunc, 13, 13)
        mainResourceFrame.widgetHeight = 13
        mainResourceFrame.widgetHeight = 13
        mainResourceFrame.resourceBars[CONST_SPECID_ROGUE_ASSASSINATION] = newResourceBar
        mainResourceFrame.resourceBars[CONST_SPECID_ROGUE_OUTLAW] = newResourceBar
        mainResourceFrame.resourceBars[CONST_SPECID_ROGUE_SUBTLETY] = newResourceBar
        mainResourceFrame.resourceBars[CONST_SPECID_DRUID_FERAL] = newResourceBar

        newResourceBar.resourceId = SPELL_POWER_COMBO_POINTS
        newResourceBar.updateResourceFunc = resourceWidgetsFunctions.OnResourceChanged --this was: resourceWidgetsFunctions.OnComboPointsChanged, change due to all classes can use any resource display
        tinsert(mainResourceFrame.allResourceBars, newResourceBar)
        mainResourceFrame.resourceBarsByEnumName[CONST_ENUMNAME_COMBOPOINT] = newResourceBar
        return newResourceBar
    end

    resourceBarCreateFuncByEnumName[CONST_ENUMNAME_SOULCHARGES] = function(mainResourceFrame)
        local resourceWidgetCreationFunc = Plater.Resources.GetCreateResourceWidgetFunctionForSpecId(CONST_SPECID_WARLOCK_AFFLICTION)
        local newResourceBar = createResourceBar(mainResourceFrame, "$parentWarlockResource", resourceWidgetCreationFunc)
        mainResourceFrame.resourceBars[CONST_SPECID_WARLOCK_AFFLICTION] = newResourceBar
        mainResourceFrame.resourceBars[CONST_SPECID_WARLOCK_DEMONOLOGY] = newResourceBar
        mainResourceFrame.resourceBars[CONST_SPECID_WARLOCK_DESTRUCTION] = newResourceBar
        newResourceBar.resourceId = SPELL_POWER_SOUL_SHARDS
        newResourceBar.updateResourceFunc = resourceWidgetsFunctions.OnSoulChardsChanged
        tinsert(mainResourceFrame.allResourceBars, newResourceBar)
        mainResourceFrame.resourceBarsByEnumName[CONST_ENUMNAME_SOULCHARGES] = newResourceBar
        return newResourceBar
    end

    resourceBarCreateFuncByEnumName[CONST_ENUMNAME_HOLYPOWER] = function(mainResourceFrame)
        local resourceWidgetCreationFunc = Plater.Resources.GetCreateResourceWidgetFunctionForSpecId(CONST_SPECID_PALADIN_RETRIBUTION)
        local newResourceBar = createResourceBar(mainResourceFrame, "$parentPaladinResource", resourceWidgetCreationFunc)
        mainResourceFrame.resourceBars[CONST_SPECID_PALADIN_HOLY] = newResourceBar
        mainResourceFrame.resourceBars[CONST_SPECID_PALADIN_PROTECTION] = newResourceBar
        mainResourceFrame.resourceBars[CONST_SPECID_PALADIN_RETRIBUTION] = newResourceBar
        newResourceBar.resourceId = SPELL_POWER_HOLY_POWER
        newResourceBar.updateResourceFunc = resourceWidgetsFunctions.OnResourceChanged
        tinsert(mainResourceFrame.allResourceBars, newResourceBar)
        mainResourceFrame.resourceBarsByEnumName[CONST_ENUMNAME_HOLYPOWER] = newResourceBar
        return newResourceBar
    end

    resourceBarCreateFuncByEnumName[CONST_ENUMNAME_RUNES] = function(mainResourceFrame)
        local resourceWidgetCreationFunc = Plater.Resources.GetCreateResourceWidgetFunctionForSpecId(CONST_SPECID_DK_FROST)
        local newResourceBar = createResourceBar(mainResourceFrame, "$parentDeathKnightResource", resourceWidgetCreationFunc)
        mainResourceFrame.resourceBars[CONST_SPECID_DK_UNHOLY] = newResourceBar
        mainResourceFrame.resourceBars[CONST_SPECID_DK_FROST] = newResourceBar
        mainResourceFrame.resourceBars[CONST_SPECID_DK_BLOOD] = newResourceBar
        newResourceBar.resourceId = SPELL_POWER_RUNES
        newResourceBar.updateResourceFunc = resourceWidgetsFunctions.OnRunesChanged
        tinsert(mainResourceFrame.allResourceBars, newResourceBar)
        mainResourceFrame.resourceBarsByEnumName[CONST_ENUMNAME_RUNES] = newResourceBar
        return newResourceBar
    end

--> this funtion is called once at the logon, it initializes the main frame
    function Plater.Resources.CreateMainResourceFrame()
        if (not DB_USE_PLATER_RESOURCE_BAR) then
            --ignore if the settings are off
            --return
            --nop, can't ignore because must have a main resource frame
        end

        if (_G.PlaterNameplatesResourceFrame) then
            --ignore if the resource frame is already created
            return
        end

        --create the main frame, this frame is the fundation for the resource bar
        --this frame is anchored to nameplates to show the amount of resources
        local mainResourceFrame = CreateFrame("frame", "PlaterNameplatesResourceFrame", UIParent)

        --> create tables to store the resource bars created
            --store the resources bars by class or spec (hash table with class name or spec e.g. resourceBars[73] = resourceBar)
            mainResourceFrame.resourceBars = {}
            --store all resource bars created (index table)
            mainResourceFrame.allResourceBars = {}
            --store the resource bar by its _G.Enum.PowerType name (hash table where the key is a string from  _G.Enum.PowerType), e.g. resourceBarsByEnum["HolyPower"] = resourceBar
            mainResourceFrame.resourceBarsByEnumName = {}

        --set the OnEvent function
        mainResourceFrame:SetScript("OnEvent", function(self, event, unit, powerType, ...)
            --if (event == "UPDATE_SHAPESHIFT_FORM") then
                --it's guarantee to trigger only on druids

            --else
                --get the current shown resource bar, then get its update func and call it passing the mainResourceFrame as #1 and the resourceBar itself as #2 argument
                local currentResourceBar = self.currentResourceBarShown
                if (currentResourceBar) then
                    local updateResourceFunc = currentResourceBar.updateResourceFunc
                    if (updateResourceFunc) then
                        --check if the power type passes the filter
                        if (powerTypesFilter[powerType]) then
                            lastComboPointGainedTime = GetTime()
                            Plater.StartLogPerformanceCore("Plater-Resources", "Events", event)
                            updateResourceFunc(self, currentResourceBar, false, event, unit, powerType)
                            Plater.EndLogPerformanceCore("Plater-Resources", "Events", event)
                        end
                    end
                end
            --end
        end)

        --get/create the resource frame set in the options panel
        Plater.Resources.UpdateResourceFrameToUse()
    end

    --this function get the value set by the player in the options panel and create a resource bar for what the player selected
    --for instance, players could select to use paladin style combo points on the rogues
    function Plater.Resources.UpdateResourceFrameToUse()
        local mainResourceFrame = Plater.Resources.GetMainResourceFrame()
        if (not mainResourceFrame) then
            Plater.Resources.CreateMainResourceFrame()
            mainResourceFrame = Plater.Resources.GetMainResourceFrame()
        end

        --grab the player class
        local playerClass = Plater.PlayerClass or select(2, UnitClass("player"))
		--the resourceId to query the amount of resources the player has
        Plater.Resources.playerResourceId = Plater.Resources.GetResourceIdForPlayer()

        if (IS_WOW_PROJECT_NOT_MAINLINE) then --classic
            if (playerClass == "ROGUE") then
                local classResourceFunc = resourceBarCreateFuncByEnumName[CONST_ENUMNAME_COMBOPOINT]
                if (classResourceFunc) then
                    local resourceBar = classResourceFunc(mainResourceFrame)
					mainResourceFrame.currentResourceBarShown = resourceBar
					Plater.Resources.UpdateResourceBar(nil, resourceBar)
                    return resourceBar
                end
            end
        else
            --return if there's no resource for this character
            if (not Plater.Resources.playerResourceId) then
                return
            end

            --get the resource to use on this character, players can change which resource model to use in the options panel
            local resourceEnumName = Plater.Resources.GetResourceEnumNameForPlayer()

            --if no enum name, this class does not use a resource bar
            if (not resourceEnumName) then
                return
            end

            --hide all resource bars already created
            for _, thisResourceBar in pairs(mainResourceFrame.resourceBarsByEnumName) do
                thisResourceBar:Hide()
            end

            --get the resource bar
            local resourceBar = mainResourceFrame.resourceBarsByEnumName[resourceEnumName]
            --if the resource bar isn't yet created, create now
            if (not resourceBar) then
                local createResourceBarFunc = resourceBarCreateFuncByEnumName[resourceEnumName]
                if (createResourceBarFunc) then
                    resourceBar = createResourceBarFunc(mainResourceFrame)
                end
            end

            mainResourceFrame.currentResourceBarShown = resourceBar
            Plater.Resources.UpdateResourceBar(nil, resourceBar)

            return resourceBar
        end
    end

    function Plater.Resources.GetMainResourceFrame()
        local mainResourceFrame = _G.PlaterNameplatesResourceFrame
        if (mainResourceFrame) then
            return mainResourceFrame
        else
            Plater.Resources.CreateMainResourceFrame()
            mainResourceFrame = _G.PlaterNameplatesResourceFrame
            return mainResourceFrame
        end
    end

    function Plater.Resources.GetResourceBarInUse()
        local mainResourceFrame = Plater.Resources.GetMainResourceFrame()
        if (mainResourceFrame) then
            return mainResourceFrame.currentResourceBarShown
        end
    end

    function Plater.Resources.EnableEvents()
        local mainResourceFrame = Plater.Resources.GetMainResourceFrame()
        if (not mainResourceFrame or mainResourceFrame.eventsEnabled) then
            return
        end

        mainResourceFrame:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
        mainResourceFrame:RegisterUnitEvent("UNIT_MAXPOWER", "player")

        if (IS_WOW_PROJECT_MAINLINE and Plater.PlayerClass == "ROGUE") then
            mainResourceFrame:RegisterUnitEvent("UNIT_POWER_POINT_CHARGE", "player")
        end

        if (Plater.PlayerClass == "DRUID") then
            mainResourceFrame:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
        end

        mainResourceFrame.eventsEnabled = true
    end

    function Plater.Resources.DisableEvents()
        local mainResourceFrame = Plater.Resources.GetMainResourceFrame()
        if (not mainResourceFrame or not mainResourceFrame.eventsEnabled) then
            return
        end

        mainResourceFrame:UnregisterEvent("UNIT_POWER_FREQUENT")
        mainResourceFrame:UnregisterEvent("UNIT_MAXPOWER")

        if (IS_WOW_PROJECT_MAINLINE and Plater.PlayerClass == "ROGUE") then
            mainResourceFrame:UnregisterEvent("UNIT_POWER_POINT_CHARGE")
        end

        if (Plater.PlayerClass == "DRUID") then
            mainResourceFrame:UnregisterEvent("UPDATE_SHAPESHIFT_FORM")
        end

        mainResourceFrame.eventsEnabled = false
    end


--> called when use plater resource bar is disabled or when no match on rules to show it; only called from inside this file
    function Plater.Resources.HidePlaterResourceFrame()
        local mainResourceFrame = Plater.Resources.GetMainResourceFrame()
        if (mainResourceFrame) then
            Plater.Resources.DisableEvents()
            mainResourceFrame:Hide()
            return
        end
    end

--> check if plater settings allow the use of these resources and check if the class and spec has a resource to show
    --decides if the resource is shown or not
--> currently is called from:
    --player spec change (PLAYER_SPECIALIZATION_CHANGED)

    function Plater.Resources.CanUsePlaterResourceFrame()
        Plater.StartLogPerformanceCore("Plater-Resources", "Update", "CanUsePlaterResourceFrame")

        local retVal = false

        --check first if this class has any resource to be used
        if (not doesClassUseResource(Plater.PlayerClass)) then
            Plater.EndLogPerformanceCore("Plater-Resources", "Update", "CanUsePlaterResourceFrame")
            return retVal
        end

        --nameplate which will have the resource bar
        local plateFrame = getPlateFrameForResourceFrame()

        if (not plateFrame) then
            Plater.EndLogPerformanceCore("Plater-Resources", "Update", "CanUsePlaterResourceFrame")
            return retVal
        end

        local playerClass = Plater.PlayerClass
        if (IS_WOW_PROJECT_NOT_MAINLINE) then
            if (playerClass == "ROGUE") then
                Plater.EndLogPerformanceCore("Plater-Resources", "Update", "CanUsePlaterResourceFrame")
                return true
            end
        else
            --spec index from 1 to 4 (see specialization frame pressing N ingame), characters below level 10 might have a bigger index
            local specIndexSelected = GetSpecialization()
            local specId = GetSpecializationInfo(specIndexSelected)
            local mainResourceFrame = Plater.Resources.GetMainResourceFrame()

            if (specId) then
                local doesSpecIdUseResource = doesSpecUseResource(specId)
                --player maybe in guardian spec but is using feral form
                local isInFeralForm = Plater.PlayerClass == "DRUID" and GetShapeshiftForm() == 2
                if (doesSpecIdUseResource or isInFeralForm) then --TODO: Druid can use it in all specs. stance check needed! (implementing)

                    --get the resource bar
                    local resourceBar =  Plater.Resources.GetResourceBarInUse()
                    if (resourceBar) then
                        Plater.EndLogPerformanceCore("Plater-Resources", "Update", "CanUsePlaterResourceFrame")
                        return true
                    end
                else
                    Plater.EndLogPerformanceCore("Plater-Resources", "Update", "CanUsePlaterResourceFrame")
                    return retVal
                end
            else
                --if no specialization, player might be low level
                if (UnitLevel("player") < 10) then
                    --should get by class?
                    if (playerClass == "ROGUE") then
                        Plater.EndLogPerformanceCore("Plater-Resources", "Update", "CanUsePlaterResourceFrame")
                        return true
                    end
                end
            end
        end

        Plater.EndLogPerformanceCore("Plater-Resources", "Update", "CanUsePlaterResourceFrame")
        return retVal
    end

--> currently is called from:
    --player target has changed, this is called from Plater.lua target changed function
    function Plater.Resources.UpdateResourceFramePosition()
        Plater.Resources.UpdateMainResourceFrame(getPlateFrameForResourceFrame())
    end

--this function receives the nameplate where the resource bar will be attached
    function Plater.Resources.UpdateMainResourceFrame(plateFrame)

        if (not plateFrame) then
            return
        end

        Plater.StartLogPerformanceCore("Plater-Resources", "Update", "UpdateMainResourceFrame")

        --get the main resource frame
        local mainResourceFrame = Plater.Resources.GetMainResourceFrame()
        if (not mainResourceFrame) then
            Plater.EndLogPerformanceCore("Plater-Resources", "Update", "UpdateMainResourceFrame")
            return
        end

        if (not Plater.Resources.CanUsePlaterResourceFrame()) then
            Plater.Resources.HidePlaterResourceFrame()

            Plater.EndLogPerformanceCore("Plater-Resources", "Update", "UpdateMainResourceFrame")
            return
        end

        Plater.Resources.EnableEvents()

        if (IS_WOW_PROJECT_NOT_MAINLINE) then
            Plater.Resources.UpdateResourceBar(plateFrame, mainResourceFrame.resourceBarsByEnumName[CONST_ENUMNAME_COMBOPOINT])
        else
            local resourceBar =  Plater.Resources.GetResourceBarInUse()
            Plater.Resources.UpdateResourceBar(plateFrame, resourceBar)
        end

        --make its parent be the healthBar from the nameplate where it is anchored to
        local healthBar = plateFrame.unitFrame.healthBar
        mainResourceFrame:SetParent(healthBar)

        --update the resource anchor
        Plater.SetAnchor(mainResourceFrame, DB_PLATER_RESOURCE_BAR_ANCHOR)

        --update the size
        mainResourceFrame:SetWidth(healthBar:GetWidth())
        mainResourceFrame:SetHeight(2)
        mainResourceFrame:SetScale(DB_PLATER_RESOURCE_BAR_SCALE)
        mainResourceFrame:SetFrameStrata(healthBar:GetFrameStrata())
        mainResourceFrame:SetFrameLevel(healthBar:GetFrameLevel() + 25)

        Plater.EndLogPerformanceCore("Plater-Resources", "Update", "UpdateMainResourceFrame")
    end


--called from 'UpdateMainResourceFrame'
--this funtion receives the nameplate and the bar to show
    function Plater.Resources.UpdateResourceBar(plateFrame, resourceBar) --note: plateFrame not in use in this function
        Plater.StartLogPerformanceCore("Plater-Resources", "Update", "UpdateResourceBar")

        --main resource frame
        local mainResourceFrame = Plater.Resources.GetMainResourceFrame()

        --hide all resourcebar widgets
        for i = 1, #resourceBar.widgets do
            resourceBar.widgets[i]:Hide()
            resourceBar.widgets[i].numberId:SetShown(DB_PLATER_RESOURCE_SHOW_NUMBER) --numberId is a fontstring above the combo point showing the combo point number
        end

        --check if the bar already shown isn't the bar asking to be shown
        if (mainResourceFrame.currentResourceBarShown) then
            if (mainResourceFrame.currentResourceBarShown ~= resourceBar) then
                mainResourceFrame.currentResourceBarShown:Hide()
            end
        end

        mainResourceFrame.currentResourceBarShown = resourceBar

        --show the resource bar
        resourceBar:Show()
        resourceBar:SetHeight(1)
        mainResourceFrame:Show()

        if (DB_PLATER_RESOURCE_SHOW_DEPLETED) then
            Plater.Resources.UpdateResourcesFor_ShowDepleted(mainResourceFrame, resourceBar)
        end

        Plater.EndLogPerformanceCore("Plater-Resources", "Update", "UpdateResourceBar")
    end


--update the resources widgets when using the resources showing the background of depleted
--on this type, the location of each resource icon is precomputed
    function Plater.Resources.UpdateResourcesFor_ShowDepleted(mainResourceFrame, resourceBar)
        Plater.StartLogPerformanceCore("Plater-Resources", "Update", "UpdateResourcesFor_ShowDepleted")

        --get the table with the widgets created
        local widgetTable = resourceBar.widgets
		--fallback if it is not implemented/created
		if (not widgetTable[1]) then
            return
        end

        --warning: calling UnitPowerMax with a nil resource id is returning a default resource amount, example in shadow priest which returns max insanity amount
        local totalWidgetsShown = UnitPowerMax("player", Plater.Resources.playerResourceId)

        --store the amount of widgets currently in use
        resourceBar.widgetsInUseAmount = totalWidgetsShown
        --set the amount of resources the player has
        resourceBar.lastResourceAmount = 0

        --get the default size of each widget
        local widgetWidth = mainResourceFrame.widgetWidth or CONST_WIDGET_WIDTH
        local widgetHeight = mainResourceFrame.widgetHeigth or CONST_WIDGET_HEIGHT
        --sum of the width of all resources shown
        local totalWidth = 0

        local isGrowingToLeft = DB_PLATER_RESOURCE_GROW_DIRECTON == "left"
        local firstWidgetIndex = 1
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
                thisResourceWidget:ClearAllPoints()
                if (isGrowingToLeft) then
                    thisResourceWidget:SetPoint("right", lastResourceWidget, "left", -DB_PLATER_RESOURCE_PADDING, 0)
                else
                    thisResourceWidget:SetPoint("left", lastResourceWidget, "right", DB_PLATER_RESOURCE_PADDING, 0)
                end

                local widgetBackground = resourceBar.widgetsBackground[i]
                widgetBackground:SetSize(widgetWidth, widgetHeight)
                widgetBackground:Show()

                --add the spacing into the total width occupied
                totalWidth = totalWidth + DB_PLATER_RESOURCE_PADDING
            end

            totalWidth = totalWidth + widgetWidth
        end

        for i = totalWidgetsShown+1, CONST_NUM_RESOURCES_WIDGETS do
            local thisResourceWidget = widgetTable[i]
            thisResourceWidget.inUse = false
            thisResourceWidget:Hide()
            resourceBar.widgetsBackground[i]:Hide()
        end

        resourceBar:SetWidth(totalWidth)
        resourceBar:SetPoint("center", mainResourceFrame, "center", 0, 0)

        for i = 1, totalWidgetsShown do
            local thisResourceWidget = widgetTable[i]
            local widgetBackground = resourceBar.widgetsBackground[i]
           --print(widgetBackground:GetSize())
           --print(widgetBackground:IsShown())
           --print(widgetBackground:GetPoint(1))
           --print(widgetBackground:GetName())
           --print(widgetBackground:GetTexture())
        end

        mainResourceFrame.currentResourceBarShown.updateResourceFunc(mainResourceFrame, mainResourceFrame.currentResourceBarShown, true)

        Plater.EndLogPerformanceCore("Plater-Resources", "Update", "UpdateResourcesFor_ShowDepleted")
    end


--realign the combat points after the amount of available combo points change
--this amount isn't the max amount of combo points but the current resources deom UnitPower
    function Plater.Resources.UpdateResources_NoDepleted(resourceBar, currentResources)
        Plater.StartLogPerformanceCore("Plater-Resources", "Update", "UpdateResources_NoDepleted")

        --main resource frame
        local mainResourceFrame = Plater.Resources.GetMainResourceFrame()

        --get the table with the widgets created to represent the resource points
        local widgetTable = resourceBar.widgets
		--fallback if it is not implemented/created
		if (not widgetTable[1]) then return end

        --get the default size of each widget
        local widgetWidth = mainResourceFrame.widgetWidth or CONST_WIDGET_WIDTH
        local widgetHeight = mainResourceFrame.widgetHeigth or CONST_WIDGET_HEIGHT
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
                if (lastComboPointGainedTime == GetTime()) then
                    thisResourceWidget.ShowAnimation:Play()
                end
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

        Plater.EndLogPerformanceCore("Plater-Resources", "Update", "UpdateResources_NoDepleted")
    end

    function Plater.Resources.UpdateResources_WithDepleted(resourceBar, currentResources)
        Plater.StartLogPerformanceCore("Plater-Resources", "Update", "UpdateResources_WithDepleted")

		--fallback if it is not implemented/created
		if (not resourceBar.widgets[1]) then return end

        --calculate how many widgets need to be shown or need to be hide
        if (currentResources < resourceBar.lastResourceAmount) then --hide widgets
            for i = resourceBar.lastResourceAmount, currentResources+1, -1 do
                resourceBar.widgets[i]:Hide()
            end

        elseif (currentResources > resourceBar.lastResourceAmount) then --show widgets
            for i = resourceBar.lastResourceAmount + 1, currentResources do
                resourceBar.widgets[i]:Show()
                if (lastComboPointGainedTime == GetTime()) then
                    resourceBar.widgets[i].ShowAnimation:Play()
                end
            end
        end

        --save the amount of resources
        resourceBar.lastResourceAmount = currentResources
        Plater.EndLogPerformanceCore("Plater-Resources", "Update", "UpdateResources_WithDepleted")
    end


-- CLASS SPECIFIC UPDATE FUNCTIONS
    --generic update
    function resourceWidgetsFunctions.OnResourceChanged(mainResourceFrame, resourceBar, forcedRefresh, event, unit, powerType)
        if (event == "UNIT_MAXPOWER" and DB_PLATER_RESOURCE_SHOW_DEPLETED) then
            Plater.Resources.UpdateResourcesFor_ShowDepleted(mainResourceFrame, resourceBar)
            forcedRefresh = true
        end

        --ensure to only update for proper power type or if forced
        --powerType showing the Enum name of the power
        if (not forcedRefresh and powerType and powerType ~= classPowerTypes[Plater.PlayerClass]) then
            return
        end

        --amount of resources the player has now
        local currentResources = UnitPower("player", Plater.Resources.playerResourceId)

        --resources amount got updated?
        if (currentResources == resourceBar.lastResourceAmount and not forcedRefresh) then
            return
        end

        --which update method to use
        if (DB_PLATER_RESOURCE_SHOW_DEPLETED) then
            Plater.Resources.UpdateResources_WithDepleted(resourceBar, currentResources)
        else
            Plater.Resources.UpdateResources_NoDepleted(resourceBar, currentResources)
        end
    end

    --rogue/druid CP --NOT IN USE ATM
    function resourceWidgetsFunctions.OnComboPointsChanged(mainResourceFrame, resourceBar, forcedRefresh, event, unit, powerType)
        if (event == "UNIT_MAXPOWER" and DB_PLATER_RESOURCE_SHOW_DEPLETED) then
            Plater.Resources.UpdateResourcesFor_ShowDepleted(mainResourceFrame, resourceBar)
            forcedRefresh = true
        end

        if (event == "UNIT_POWER_POINT_CHARGE") then
			--fallback if it is not implemented/created
			if (not resourceBar.widgets[1]) then return end
			
            --charges changed
            local chargedPowerPoints = GetUnitChargedPowerPoints("player")
            --chargedPowerPoints = {[1] = random(1,2), [2] = random(3,5)} --testing
            for i = 1, resourceBar.widgetsInUseAmount do
                local widget = resourceBar.widgets[i]
                local isCharged = chargedPowerPoints and tContains(chargedPowerPoints, i)
                if (widget.isCharged ~= isCharged) then
                    if (isCharged) then
                        widget.texture:SetAtlas("ClassOverlay-ComboPoint-Kyrian")
                        widget.background:SetAtlas("ClassOverlay-ComboPoint-Off-Kyrian")
                    else
                        widget.texture:SetAtlas("ClassOverlay-ComboPoint")
                        widget.background:SetAtlas("ClassOverlay-ComboPoint-Off")
                    end
                end
            end
            return
        end

        -- ensure to only update for proper power type or if forced
        if not forcedRefresh and powerType and powerType ~= classPowerTypes[Plater.PlayerClass] then
            return
        end

        --amount of resources the player has now
        local currentResources = GetComboPoints("player", "target") --UnitPower("player", Plater.Resources.playerResourceId)

        --resources amount got updated?
        if (currentResources == resourceBar.lastResourceAmount and not forcedRefresh) then
            return
        end

        --which update method to use
        if (DB_PLATER_RESOURCE_SHOW_DEPLETED) then
            return Plater.Resources.UpdateResources_WithDepleted(resourceBar, currentResources)
        else
            return Plater.Resources.UpdateResources_NoDepleted(resourceBar, currentResources)
        end
    end
    
    --DK runes update
    function resourceWidgetsFunctions.OnRunesChanged(mainResourceFrame, resourceBar, forcedRefresh, event, unit, powerType)
        
        if (event == "UNIT_MAXPOWER" and DB_PLATER_RESOURCE_SHOW_DEPLETED) then
            Plater.Resources.UpdateResourcesFor_ShowDepleted(mainResourceFrame, resourceBar)
            forcedRefresh = true
        end
        
        -- ensure to only update for proper power type or if forced
        if not forcedRefresh and powerType and powerType ~= classPowerTypes[Plater.PlayerClass] then
            return
        end
        
        --amount of resources the player has now
        local currentResources = UnitPower("player", Plater.Resources.playerResourceId)

        --resources amount got updated?
        if (currentResources == resourceBar.lastResourceAmount and not forcedRefresh) then
            return
        end

        --which update method to use
        if (DB_PLATER_RESOURCE_SHOW_DEPLETED) then
            return Plater.Resources.UpdateResources_WithDepleted(resourceBar, currentResources)
        else
            return Plater.Resources.UpdateResources_NoDepleted(resourceBar, currentResources)
        end
    end
    
    --WL soul chards
    function resourceWidgetsFunctions.OnSoulChardsChanged(mainResourceFrame, resourceBar, forcedRefresh, event, unit, powerType)
        
        if (event == "UNIT_MAXPOWER" and DB_PLATER_RESOURCE_SHOW_DEPLETED) then
            Plater.Resources.UpdateResourcesFor_ShowDepleted(mainResourceFrame, resourceBar)
            forcedRefresh = true
        end
        
        -- ensure to only update for proper power type or if forced
        if not forcedRefresh and powerType and powerType ~= classPowerTypes[Plater.PlayerClass] then
            return
        end
        
        --amount of resources the player has now
        local currentResources = UnitPower("player", Plater.Resources.playerResourceId)

        --resources amount got updated?
        if (currentResources == resourceBar.lastResourceAmount and not forcedRefresh) then
            return
        end

        --which update method to use
        if (DB_PLATER_RESOURCE_SHOW_DEPLETED) then
            return Plater.Resources.UpdateResources_WithDepleted(resourceBar, currentResources)
        else
            return Plater.Resources.UpdateResources_NoDepleted(resourceBar, currentResources)
        end
    end