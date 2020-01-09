
local Plater = _G.Plater
local GameCooltip = GameCooltip2
local DF = DetailsFramework
local _

function Plater.UpdateCustomDesign(unitFrame)
    
    local settings = Plater.db.profile.customdesign

    local healthBar = unitFrame.healthBar
    local castBar = unitFrame.castBar
    local powerBar = unitFrame.powerBar

    healthBar:SetTexture (settings.healthbar_file)
    healthBar.background:SetTexture (settings.healthbar_file)
    healthBar.background:SetVertexColor (.2, .2, .2, .8)

    --healthBar texture
    if (settings.healthbar_file) then
        healthBar:SetTexture (settings.healthbar_file)
    end

    --borderTexture
    if (settings.border_file) then
        healthBar.customborder.texture:SetTexture (settings.border_file)
        healthBar.customborder:Show()
        healthBar.border:Hide()
    end

    --border distance
    if (settings.border_distance) then
        --DF:SetPointOffsets(healthBar.customborder, settings.border_distance, settings.border_distance)
    end

    --border color
    if (settings.border_color) then
        healthBar.customborder.texture:SetVertexColor(DF:ParseColors(settings.border_color))
    end

end

function Plater.CreateCustomDesignBorder(healthBar)
    local healthBarBorderCustom = CreateFrame ("frame", nil, healthBar)
    healthBarBorderCustom:SetPoint("topleft", healthBar, "topleft", -1, 1)
    healthBarBorderCustom:SetPoint("bottomright", healthBar, "bottomright", 1, -1)
    healthBar.customborder = healthBarBorderCustom
    healthBarBorderCustom.texture = healthBarBorderCustom:CreateTexture(nil, "overlay")
    healthBarBorderCustom.texture:SetAllPoints()
    healthBarBorderCustom:Hide()
end