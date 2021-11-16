
local Plater = _G.Plater
local GameCooltip = GameCooltip2
local DF = DetailsFramework
local _
local UnitPower = _G.UnitPower
local UnitPowerMax = _G.UnitPowerMax
local abs = _G.abs

local hookbox_label_y = -130

local CONST_SCROLLBOX_WIDTH = 200
local CONST_SCROLLBOX_HEIGHT = 495
local CONST_SCROLLBOX_LINES = 20
local CONST_SCROLLBOX_LINE_HEIGHT = 20
local CONST_SCROLLBOX_LINE_BACKDROP = {bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true, edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1}
local CONST_SCROLLBOX_LINE_BACKDROP_COLOR = {0, 0, 0, 0.5}
local CONST_SCROLLBOX_LINE_BACKDROP_COLOR_SELECTED = {.6, .6, .1, 0.7}
local CONST_SCROLLBOX_LINE_BACKDROP_COLOR_HOVER = {.3, .3, .3, 0.5}

local CONST_OPTIONSFRAME_WIDTH = 864

local CONST_ENUMNAME_COMBOPOINT = "ComboPoints"
local CONST_ENUMNAME_HOLYPOWER = "HolyPower"

function Plater.Resources.BuildResourceOptionsTab(frame)

    local playerSerial = UnitGUID("player")
    local playerClassLoc, playerClass = UnitClass("player")

    if (not Plater.db.profile.resources_settings.chr[playerSerial]) then
        if (playerClass == "ROGUE") then
            Plater.db.profile.resources_settings.chr[playerSerial] = CONST_ENUMNAME_COMBOPOINT

        elseif (playerClass == "PALADIN") then
            Plater.db.profile.resources_settings.chr[playerSerial] = CONST_ENUMNAME_HOLYPOWER
        end
    end

    --left menu
    local resourceDisplaysAvailable = {
        {name = "Combo Point", defaultClass = {"DRUID", "ROGUE"}, enumName = CONST_ENUMNAME_COMBOPOINT, iconTexture = false, iconAtlas = "ClassOverlay-ComboPoint"}, --4
        {name = "Holy Power", defaultClass = {"PALADIN"}, enumName = CONST_ENUMNAME_HOLYPOWER, iconTexture = [[Interface\PLAYERFRAME\ClassOverlayHolyPower]], iconCoords = {0.530999, 0.6619999, 0.01600000, 0.3479999}}, --9
    }

    local refreshResourceScrollBox = function(self, data, offset, totalLines)
		for i = 1, totalLines do
			local index = i + offset

			local resource = data[index]
			if (resource) then
                local isSelected = Plater.db.profile.resources_settings.chr[playerSerial] == resource.enumName
				local line = self:GetLine(i)

                line.resource = resource
				line.checkBox:SetValue(isSelected)
                line.text:SetText(resource.name)

                if (isSelected) then
                    line:SetBackdropColor(unpack(CONST_SCROLLBOX_LINE_BACKDROP_COLOR_SELECTED))
                    line.isSelected = true
                else
                    line:SetBackdropColor(unpack(CONST_SCROLLBOX_LINE_BACKDROP_COLOR))
                    line.isSelected = false
                end

                if (resource.iconTexture) then
                    line.icon:SetTexture(resource.iconTexture)
                    if (resource.iconCoords) then
                        line.icon:SetTexCoord(unpack(resource.iconCoords))
                    else
                        line.icon:SetTexCoord(unpack(0, 1, 0, 1))
                    end
                elseif (resource.iconAtlas) then
                    line.icon:SetAtlas(resource.iconAtlas)
                end
			end
		end
    end

    local selectResourceScrollBox = DF:CreateScrollBox(frame, "$parentResourceScrollBox", refreshResourceScrollBox, resourceDisplaysAvailable, CONST_SCROLLBOX_WIDTH, CONST_SCROLLBOX_HEIGHT, CONST_SCROLLBOX_LINES, CONST_SCROLLBOX_LINE_HEIGHT)
    DF:ReskinSlider(selectResourceScrollBox)
    selectResourceScrollBox:SetPoint("topleft", frame, "topleft", 5, hookbox_label_y)
    frame.selectResourceScrollBox = selectResourceScrollBox

    local onEnterResourceLine = function(self)
        if (not self.isSelected) then
            self:SetBackdropColor(unpack(CONST_SCROLLBOX_LINE_BACKDROP_COLOR_HOVER))
        end
    end

    local onLeaveResourceLine = function(self)
        if (not self.isSelected) then
            self:SetBackdropColor(unpack(CONST_SCROLLBOX_LINE_BACKDROP_COLOR))
        end
    end

    local onSelectResource = function(self)

    end

    local toggleResource = function(self)
        local line = self:GetParent()
        local resource = line.resource
        Plater.db.profile.resources_settings.chr[playerSerial] = resource.enumName
        selectResourceScrollBox:Refresh()
    end

    local resourceListCreateLine = function(self, index)
		--create a new line
		local line = CreateFrame("button", "$parentLine" .. index, self, BackdropTemplateMixin and "BackdropTemplate")

		--set its parameters
		line:SetPoint("topleft", self, "topleft", 0, -((index-1) * (CONST_SCROLLBOX_LINE_HEIGHT+1)))
		line:SetSize(CONST_SCROLLBOX_WIDTH, CONST_SCROLLBOX_LINE_HEIGHT)
		line:SetScript("OnEnter", onEnterResourceLine)
		line:SetScript("OnLeave", onLeaveResourceLine)
		line:SetScript("OnMouseUp", onSelectResource)
		line:SetBackdrop(CONST_SCROLLBOX_LINE_BACKDROP)
		line:SetBackdropColor(unpack(CONST_SCROLLBOX_LINE_BACKDROP_COLOR))
		line:SetBackdropBorderColor (0, 0, 0, 0)

        local checkBox = DF:CreateSwitch(line, toggleResource, false, 20, 20, _, _, "checkbox", "$parentToggleResourceActivation" .. index, _, _, _, _, DF:GetTemplate("switch", "OPTIONS_CHECKBOX_BRIGHT_TEMPLATE"))
        checkBox:SetAsCheckBox()
        checkBox:SetPoint("left", line, "left", 2, 0)
        checkBox.index = index

        local resourceIcon = line:CreateTexture("$parentIcon", "artwork")
        resourceIcon:SetPoint("left", checkBox.widget, "right", 2, 0)
        resourceIcon:SetSize(CONST_SCROLLBOX_LINE_HEIGHT-2, CONST_SCROLLBOX_LINE_HEIGHT-2)

        local resourceName = line:CreateFontString("$parentName", "artwork", "GameFontNormal")
        resourceName:SetPoint("left", resourceIcon, "right", 2, 0)

        line.checkBox = checkBox
        line.text = resourceName
        line.icon = resourceIcon

        return line
    end

	for i = 1, CONST_SCROLLBOX_LINES do
		selectResourceScrollBox:CreateLine(resourceListCreateLine)
	end

    selectResourceScrollBox:Refresh()

    --center options
    local optionsFrame = CreateFrame("frame", "$parentOptionsFrame", frame, "BackdropTemplate")
    optionsFrame:SetWidth(CONST_OPTIONSFRAME_WIDTH)
    optionsFrame:SetPoint("topleft", selectResourceScrollBox, "topright", 26, 0)
    optionsFrame:SetPoint("bottomleft", selectResourceScrollBox, "bottomright", 26, 0)
    DF:ApplyStandardBackdrop(optionsFrame)

end