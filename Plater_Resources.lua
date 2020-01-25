
local Plater = _G.Plater
local GameCooltip = GameCooltip2
local DF = DetailsFramework
local _

--default settings
--[=[
resources_show = true,
resources_personal_bar = true,
resources_target = true,
block_size = 20
block_texture_background = "Interface\\COMMON\\Indicator-Gray"
block_texture_artwork = "Interface\\COMMON\\Indicator-Yellow"
block_texture_overlay = "Interface\\CHARACTERFRAME\\TempPortraitAlphaMaskSmall"


--]=]


--base frame to hold the resource widgets, this is the same for all resource frames
local create_resource_frame = function (parent, frameName)
    local resourceFrame = CreateFrame("frame", frameName, parent)

    resourceFrame:EnableMouse (false)
    resourceFrame:EnableMouseWheel (false)

    resourceFrame.widgets = {}

    for i = 1, 10 do
        local newWidget =  CreateFrame("frame", "$parentWidget" .. i, resourceFrame)
        resourceFrame.widgets [resourceFrame.widgets+1] = newWidget
        newWidget:EnableMouse(false)
        newWidget:EnableMouseWheel(false)
        newWidget:SetSize(20, 20)
        newWidget:Hide()
        
        newWidget.background = DF:CreateImage(newWidget, "Interface\\COMMON\\Indicator-Gray", 18, 18, "background", false, "background", "$parentBackground")
        newWidget.texture = DF:CreateImage(newWidget, "Interface\\COMMON\\Indicator-Yellow", 16, 16, "artwork", false, "texture", "$parentTexture")
        newWidget.overlay = DF:CreateImage(newWidget, "Interface\\CHARACTERFRAME\\TempPortraitAlphaMaskSmall", 16, 16, "overlay", false, "overlay", "$parentOverlay")

        newWidget.background:SetAllPoints()
        newWidget.texture:SetPoint("topleft", newWidget, "topleft", 2, -2)
        newWidget.overlay:SetPoint("topleft", newWidget, "topleft", 2, -2)
        newWidget.texture:SetPoint("bottomright", newWidget, "bottomright", -2, 2)
        newWidget.overlay:SetPoint("bottomright", newWidget, "bottomright", -2, 2)
    end
end

--each function create a resource frame for its class or spec
local resource_mage_arcane = function(unitFrame)
    unitFrame.resourceBars [62] = create_resource_frame (unitFrame, "$parentArcaneResource")
end

local resource_rogue_druid_cpoints = function(unitFrame)
    unitFrame.resourceBars ["ROGUE"] = create_resource_frame (unitFrame, "$parentRogueResource")
    --druid feral
    unitFrame.resourceBars [103] = unitFrame.resourceBars ["ROGUE"]
end

local resource_warlock = function(unitFrame)
    unitFrame.resourceBars ["WARLOCK"] = create_resource_frame (unitFrame, "$parentWarlockResource")
end

local resource_paladin = function(unitFrame)
    unitFrame.resourceBars [70] = create_resource_frame (unitFrame, "$parentPaladinResource")
end

local resource_dk = function(unitFrame)
    unitFrame.resourceBars ["DEATHKNIGHT"] = create_resource_frame (unitFrame, "$parentDKResource")
end

local resource_monk = function(unitFrame)
    --unitFrame.resourceBars [268] = create_resource_frame (unitFrame, "$parentMonk1Resource") --brewmaster chi bar
    unitFrame.resourceBars [269] = create_resource_frame (unitFrame, "$parentMonk2Resource") --windwalker points
end

function Plater.CreateResourceBar(plateFrame)

    --resource frames are attach to unitFrame
    local unitFrame = plateFrame.unitFrame
    local playerClass = Plater.PlayerClass

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

function Plater.UpdateResourceBar(plateFrame)
    local unitFrame = plateFrame.unitFrame

    if (WOW_PROJECT_ID == WOW_PROJECT_CLASSIC) then --classic
    else
        local playerClass = Plater.PlayerClass
        local playerSpec = GetSpecialization()

        local resourceBar = unitFrame.resourceBars [playerClass]
        if (not resourceBar) then
            resourceBar = unitFrame.resourceBars [playerSpec]
            if (not resourceBar) then
                --todo: hide the current shown resource on this nameplate
                return
            end
        end

        --resources are enabled overall?
        if (not Plater.db.profile.resources_show) then
            --todo: hide the current shown resource on this nameplate
            return
        end

        --nameplate is the personal bar, check if can show resources
        if (unitFrame.IsSelf) then
            if (not Plater.db.profile.resources_personal_bar) then
                --todo: hide the current shown resource on this nameplate
                return
            end

        --name is current player target, check if can show resources
        elseif (unitFrame.namePlateIsTarget) then
            if (not Plater.db.profile.resources_target) then
                --todo: hide the current shown resource on this nameplate
                return
            end

        else
            --nameplate isn't the current target or the personal bar, just hide any resource shown
            --todo: hide the current shown resource on this nameplate
            return
        end



    end

end
