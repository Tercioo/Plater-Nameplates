
local Plater = _G.Plater
local GameCooltip = GameCooltip2
local DF = DetailsFramework
local _

--each function create a resource frame for its class or spec
local resource_mage_arcane = function(unitFrame)
    unitFrame.resourceBars [62] = CreateFrame ("frame", "$parentArcaneResource", unitFrame)
end

local resource_rogue_druid_cpoints = function(unitFrame)
    unitFrame.resourceBars ["ROGUE"] = CreateFrame ("frame", "$parentRogueResource", unitFrame)
    --druid feral
    unitFrame.resourceBars [103] = unitFrame.resourceBars ["ROGUE"]
end

local resource_warlock = function(unitFrame)
    unitFrame.resourceBars ["WARLOCK"] = CreateFrame ("frame", "$parentWarlockResource", unitFrame)
end

local resource_paladin = function(unitFrame)
    unitFrame.resourceBars [70] = CreateFrame ("frame", "$parentPaladinResource", unitFrame)
end

local resource_dk = function(unitFrame)
    unitFrame.resourceBars ["DEATHKNIGHT"] = CreateFrame ("frame", "$parentDKResource", unitFrame)
end

local resource_monk = function(unitFrame)
    unitFrame.resourceBars [268] = CreateFrame ("frame", "$parentMonk1Resource", unitFrame) --brewmaster chi bar
    unitFrame.resourceBars [269] = CreateFrame ("frame", "$parentMonk2Resource", unitFrame) --windwalker points
end

function Plater.CreateResourceBar(plateFrame)

    --resource frames are attach to unitFrame
    local unitFrame = plateFrame.unitFrame
    local _, playerClass = UnitClass ("player")

    if (WOW_PROJECT_ID == WOW_PROJECT_CLASSIC) then --classic

    else --retail
        
        --get the player class and check if the class uses a resource bar on any of its specializations
        unitFrame.resourceBars = {}

        if (playerClass == "MAGE") then
            resource_mage_arcane(unitFrame)

        elseif (playerClass == "ROGUE" or playerClass == "DRUID") then
            resource_rogue_druid_cpoints(unitFrame)

        elseif (playerClass == "WARLOCK") then
            resource_warlock(unitFrame)

        elseif (playerClass == "PALADIN") then
            resource_paladin(unitFrame)

        elseif (playerClass == "DEATHKNIGHT") then
            resource_dk(unitFrame)

        elseif (playerClass == "MONK") then
            resource_monk(unitFrame)
        end

    end

end

