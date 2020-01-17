
local Plater = _G.Plater
local GameCooltip = GameCooltip2
local DF = DetailsFramework
local _

function Plater.UpdateCustomDesign(unitFrame)
    
    local settings = Plater.db.profile.customdesign

    local healthBar = unitFrame.healthBar
    local castBar = unitFrame.castBar
    local powerBar = unitFrame.powerBar

    --health bar modification
    if (settings.healthbar_enabled) then

        --healthBar texture
        if (settings.healthbar_file) then
            healthBar:SetTexture (settings.healthbar_file)
            unitFrame.HighlightFrame.HighlightTexture:SetTexture (settings.healthbar_file)
            healthBar.background:SetTexture (settings.healthbar_file)
            healthBar.background:SetTexture (Plater.db.profile.health_selection_overlay)
            healthBar.background:SetVertexColor (unpack (Plater.db.profile.health_statusbar_bgcolor))
        end

        --borderTexture
        if (settings.healthbar_border_file) then
            healthBar.customborder.texture:SetTexture (settings.healthbar_border_file)
            healthBar.customborder:Show()
            healthBar.border:Hide()
        end

        --border distance
        if (settings.healthbar_border_distance) then
            healthBar.customborder:SetPoint("topleft", healthBar, "topleft", -settings.healthbar_border_distance, settings.healthbar_border_distance)
            healthBar.customborder:SetPoint("bottomright", healthBar, "bottomright", settings.healthbar_border_distance, -settings.healthbar_border_distance)
        end

        --border color
        if (settings.healthbar_border_color) then
            healthBar.customborder.texture:SetVertexColor(DF:ParseColors(settings.healthbar_border_color))
        end
    end

    --cast bar modification
    if (settings.castbar_enabled) then

        --castbar texture
        if (settings.castbar_file) then
            castBar:SetStatusBarTexture (settings.castbar_file)
			castBar.background:SetTexture (settings.castbar_file)
			castBar.background:SetVertexColor (unpack (Plater.db.profile.cast_statusbar_bgcolor))
        end

        --borderTexture
        if (settings.castbar_border_file) then
            castBar.customborder.texture:SetTexture (settings.castbar_border_file)
            castBar.customborder:Show()
            castBar.FrameOverlay:SetBackdropBorderColor (0, 0, 0, 0)
        end

        --border distance
        if (settings.castbar_border_distance) then
            castBar.customborder:SetPoint("topleft", castBar, "topleft", -settings.castbar_border_distance, settings.castbar_border_distance)
            castBar.customborder:SetPoint("bottomright", castBar, "bottomright", settings.castbar_border_distance, -settings.castbar_border_distance)
        end

        --border color
        if (settings.castbar_border_color) then
            castBar.customborder.texture:SetVertexColor(DF:ParseColors(settings.castbar_border_color))
        end
    end

    --power bar modification
    if (settings.enabled_powerbar) then

        --castbar texture
        if (settings.healthbar_file) then
            unitFrame.powerBar:SetTexture (settings.healthbar_file)
			castBar.background:SetTexture (settings.healthbar_file)
			castBar.background:SetVertexColor (unpack (Plater.db.profile.cast_statusbar_bgcolor))
        end

        --borderTexture
        if (settings.healthbar_border_file) then
            healthBar.customborder.texture:SetTexture (settings.healthbar_border_file)
            healthBar.customborder:Show()
            healthBar.border:Hide()
        end

        --border distance
        if (settings.healthbar_border_distance) then
            healthBar.customborder:SetPoint("topleft", healthBar, "topleft", -settings.healthbar_border_distance, settings.healthbar_border_distance)
            healthBar.customborder:SetPoint("bottomright", healthBar, "bottomright", settings.healthbar_border_distance, -settings.healthbar_border_distance)
        end

        --border color
        if (settings.healthbar_border_color) then
            healthBar.customborder.texture:SetVertexColor(DF:ParseColors(settings.healthbar_border_color))
        end
    end    


end

function Plater.CreateCustomDesignBorder(frame)
    local frameBorderCustom = CreateFrame ("frame", nil, frame)
    frameBorderCustom:SetPoint("topleft", frame, "topleft", -1, 1)
    frameBorderCustom:SetPoint("bottomright", frame, "bottomright", 1, -1)
    frame.customborder = frameBorderCustom
    frameBorderCustom.texture = frameBorderCustom:CreateTexture(nil, "overlay")
    frameBorderCustom.texture:SetAllPoints()
    frameBorderCustom:Hide()
end