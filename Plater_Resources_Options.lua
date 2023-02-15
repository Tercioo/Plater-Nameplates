local addonId, platerInternal = ...

local Plater = _G.Plater
local GameCooltip = GameCooltip2
local DF = DetailsFramework
local _
local UnitPower = _G.UnitPower
local UnitPowerMax = _G.UnitPowerMax
local abs = _G.abs

local hookbox_label_y = -130

local CONST_GLOBALSETTINGS_X = 240
local CONST_GLOBALSETTINGS_Y = hookbox_label_y

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
local CONST_ENUMNAME_RUNES = "Runes"
local CONST_ENUMNAME_ARCANECHARGES = "ArcaneCharges"
local CONST_ENUMNAME_CHI = "Chi"
local CONST_ENUMNAME_SOULCHARGES = "SoulShards"
local CONST_ENUMNAME_ESSENCE = "Essence"

local startX, startY, heightSize = 10, platerInternal.optionsYStart, 755

--templates
local options_text_template = DF:GetTemplate("font", "OPTIONS_FONT_TEMPLATE")
local options_dropdown_template = DF:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE")
local options_switch_template = DF:GetTemplate("switch", "OPTIONS_CHECKBOX_TEMPLATE")
local options_slider_template = DF:GetTemplate("slider", "OPTIONS_SLIDER_TEMPLATE")
local options_button_template = DF:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE")

--localization
local LOC = DF.Language.GetLanguageTable(addonId)

function Plater.Resources.GetResourceEnumNameForPlayer()
    local playerSerial = Plater.PlayerGUID or UnitGUID("player")
    local playerClassLoc, playerClass = UnitClass("player")

    if (not Plater.db.profile.resources_settings.chr[playerSerial]) then
        if (playerClass == "ROGUE" or playerClass == "DRUID") then
            Plater.db.profile.resources_settings.chr[playerSerial] = CONST_ENUMNAME_COMBOPOINT
            return CONST_ENUMNAME_COMBOPOINT

        elseif (playerClass == "WARLOCK") then
            Plater.db.profile.resources_settings.chr[playerSerial] = CONST_ENUMNAME_SOULCHARGES
            return CONST_ENUMNAME_SOULCHARGES

        elseif (playerClass == "MONK") then
            Plater.db.profile.resources_settings.chr[playerSerial] = CONST_ENUMNAME_CHI
            return CONST_ENUMNAME_CHI

        elseif (playerClass == "MAGE") then
            Plater.db.profile.resources_settings.chr[playerSerial] = CONST_ENUMNAME_ARCANECHARGES
            return CONST_ENUMNAME_ARCANECHARGES

        elseif (playerClass == "DEATHKNIGHT") then
            Plater.db.profile.resources_settings.chr[playerSerial] = CONST_ENUMNAME_RUNES
            return CONST_ENUMNAME_RUNES

        elseif (playerClass == "PALADIN") then
            Plater.db.profile.resources_settings.chr[playerSerial] = CONST_ENUMNAME_HOLYPOWER
            return CONST_ENUMNAME_HOLYPOWER
		elseif (playerClass == "EVOKER") then
            Plater.db.profile.resources_settings.chr[playerSerial] = CONST_ENUMNAME_ESSENCE
            return CONST_ENUMNAME_ESSENCE
        end
    end

    return Plater.db.profile.resources_settings.chr[playerSerial]
end

--return the resource Id for the player, resourceId is used to query how much resources the player has UnitPower and UnitPowerMax
function Plater.Resources.GetResourceIdForPlayer()
    local playerClassLoc, playerClass = UnitClass("player")

    if (playerClass == "ROGUE" or playerClass == "DRUID") then
        return Enum.PowerType[CONST_ENUMNAME_COMBOPOINT]

    elseif (playerClass == "WARLOCK") then
        return Enum.PowerType[CONST_ENUMNAME_SOULCHARGES]

    elseif (playerClass == "MONK") then
        return Enum.PowerType[CONST_ENUMNAME_CHI]

    elseif (playerClass == "MAGE") then
        return Enum.PowerType[CONST_ENUMNAME_ARCANECHARGES]

    elseif (playerClass == "DEATHKNIGHT") then
        return Enum.PowerType[CONST_ENUMNAME_RUNES]

    elseif (playerClass == "PALADIN") then
        return Enum.PowerType[CONST_ENUMNAME_HOLYPOWER]
		
	elseif (playerClass == "EVOKER") then
        return Enum.PowerType[CONST_ENUMNAME_ESSENCE]
    end

    --return none if not found, this will trigger an error on new resources in the future
end

function Plater.Resources.BuildResourceOptionsTab(frame)
    --if there's no default resource name for this character yet, calling this will set a default
    Plater.Resources.GetResourceEnumNameForPlayer()

    --left menu
    local resourceDisplaysAvailable = { --name should be able to get from the client
        {name = "Combo Point", defaultClass = {"DRUID", "ROGUE"}, enumName = CONST_ENUMNAME_COMBOPOINT, iconTexture = false, iconAtlas = "ClassOverlay-ComboPoint"}, --4
        {name = "Holy Power", defaultClass = {"PALADIN"}, enumName = CONST_ENUMNAME_HOLYPOWER, iconTexture = [[Interface\PLAYERFRAME\ClassOverlayHolyPower]], iconCoords = {0.530999, 0.6619999, 0.01600000, 0.3479999}}, --9
        {name = "Runes", defaultClass = {"DEATHKNIGHT"}, enumName = CONST_ENUMNAME_RUNES, iconTexture = [[Interface\PLAYERFRAME\UI-PlayerFrame-Deathknight-SingleRune]], iconCoords = {0, 1, 0, 1}}, --5
        {name = "Arcane Charges", defaultClass = {"MAGE"}, enumName = CONST_ENUMNAME_ARCANECHARGES, iconTexture = [[Interface\PLAYERFRAME\MageArcaneCharges]], iconCoords = {64/256, 91/256, 64/128, 91/128}}, --16
        {name = "Chi", defaultClass = {"MONK"}, enumName = CONST_ENUMNAME_CHI, iconTexture = [[Interface\PLAYERFRAME\MonkLightPower]], iconCoords = {0.1, .9, 0.1, .9}}, --12
        {name = "Soul Shards", defaultClass = {"WARLOCK"}, enumName = CONST_ENUMNAME_SOULCHARGES, iconTexture = [[Interface\PLAYERFRAME\UI-WARLOCKSHARD]], iconCoords = {0/64, 18/64, 0/128, 18/128}}, --7
		{name = "Essence", defaultClass = {"EVOKER"}, enumName = CONST_ENUMNAME_ESSENCE, iconTexture = false, iconAtlas = "UF-Essence-Icon"}, --8
    }

    local refreshResourceScrollBox = function(self, data, offset, totalLines)
		for i = 1, totalLines do
			local index = i + offset

			local resource = data[index]
			if (resource) then
                local isSelected = Plater.db.profile.resources_settings.chr[Plater.PlayerGUID] == resource.enumName
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

    local selectResourceLabel = DF:CreateLabel(frame, "Select which resource to use on this character:", 12, "orange")
    selectResourceLabel:SetPoint("bottomleft", selectResourceScrollBox, "topleft", 0, 4)

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
        Plater.db.profile.resources_settings.chr[Plater.PlayerGUID] = resource.enumName
        selectResourceScrollBox:Refresh()
        Plater.Resources.UpdateResourceFrameToUse()
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
	
	--hide for now and move other settings over ~TODO
	selectResourceLabel:Hide()
	selectResourceScrollBox:Hide()

    --center options
	--TODO disabled for now
    --local optionsFrame = CreateFrame("frame", "$parentOptionsFrame", frame, "BackdropTemplate")
    --optionsFrame:SetWidth(CONST_OPTIONSFRAME_WIDTH)
    --optionsFrame:SetPoint("topleft", selectResourceScrollBox, "topright", 26, 0)
    --optionsFrame:SetPoint("bottomleft", selectResourceScrollBox, "bottomright", 26, 0)
    --DF:ApplyStandardBackdrop(optionsFrame)

	--anchor table
	local anchor_names = {
		LOC["OPTIONS_ANCHOR_TOPLEFT"],
		LOC["OPTIONS_ANCHOR_LEFT"],
		LOC["OPTIONS_ANCHOR_BOTTOMLEFT"],
		LOC["OPTIONS_ANCHOR_BOTTOM"],
		LOC["OPTIONS_ANCHOR_BOTTOMRIGHT"],
		LOC["OPTIONS_ANCHOR_RIGHT"],
		LOC["OPTIONS_ANCHOR_TOPRIGHT"],
		LOC["OPTIONS_ANCHOR_TOP"],
		LOC["OPTIONS_ANCHOR_CENTER"],
		LOC["OPTIONS_ANCHOR_INNERLEFT"],
		LOC["OPTIONS_ANCHOR_INNERRIGHT"],
		LOC["OPTIONS_ANCHOR_INNERTOP"],
		LOC["OPTIONS_ANCHOR_INNERBOTTOM"],
	}

	local build_anchor_side_table = function(member1, member2)
		local t = {}
		for i = 1, 13 do
			tinsert(t, {
				label = anchor_names[i],
				value = i,
				onclick = function(_, _, value)
					Plater.db.profile.resources_settings[member1][member2].side = value
					Plater.RefreshDBUpvalues()
					Plater.UpdateAllPlates()
					Plater.UpdateAllNames()
				end
                }
            )
		end
		return t
	end

    --[=[
        -show = false, --if the resource bar from plater is enabled
        -personal_bar = false, --if the resource bar shows in the personal bar intead of the current target
        align = "horizontal", --combo points are horizontal alignment
        grow_direction = "center",
        -show_depleted = true,
        -show_number = false,
        -anchor = {side = 8, x = 0, y = 40},
        -scale = 0.8,
        -padding = 2,
    --]=]

    local globalResourceOptions = {
        {type = "label", get = function() return "Global Settings:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
        --use plater resources
        {
            type = "toggle",
            get = function() return Plater.db.profile.resources_settings.global_settings.show end,
            set = function (self, fixedparam, value)
                Plater.db.profile.resources_settings.global_settings.show = value
				if value then
					PlaterDBChr.resources_on_target = false
				end
                Plater.UpdateAllPlates()
            end,
            name = "Use Plater Resources",
            desc = "Use Plater Resources",
        },

        --show on personal bar
        {
            type = "toggle",
            get = function() return Plater.db.profile.resources_settings.global_settings.personal_bar end,
            set = function (self, fixedparam, value)
                Plater.db.profile.resources_settings.global_settings.personal_bar = value
                Plater.UpdateAllPlates()
            end,
            name = "Show On Personal Bar",
            desc = "Show On Personal Bar",
        },

        --show depleted
        {
            type = "toggle",
            get = function() return Plater.db.profile.resources_settings.global_settings.show_depleted end,
            set = function (self, fixedparam, value)
                Plater.db.profile.resources_settings.global_settings.show_depleted = value
                Plater.UpdateAllPlates()
            end,
            name = "Show Background",
            desc = "Show Background",
        },
        --show resource number
        {
            type = "toggle",
            get = function() return Plater.db.profile.resources_settings.global_settings.show_number end,
            set = function (self, fixedparam, value)
                Plater.db.profile.resources_settings.global_settings.show_number = value
                Plater.UpdateAllPlates()
            end,
            name = "Show Amount",
            desc = "Show Amount",
        },

        --anchor
		{
			type = "select",
			get = function() return Plater.db.profile.resources_settings.global_settings.anchor.side end,
			values = function() return build_anchor_side_table("global_settings", "anchor") end,
			name = LOC["OPTIONS_ANCHOR"],
			desc = "Which side of the nameplate this widget is attach to.",
		},
		--anchor x offset
		{
			type = "range",
			get = function() return Plater.db.profile.resources_settings.global_settings.anchor.x end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.resources_settings.global_settings.anchor.x = value
				Plater.UpdateAllPlates()
			end,
			min = -100,
			max = 100,
			step = 1,
			usedecimals = true,
			name = LOC["OPTIONS_XOFFSET"],
			desc = "Slightly move horizontally.",
		},
		--anchor y offset
		{
			type = "range",
			get = function() return Plater.db.profile.resources_settings.global_settings.anchor.y end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.resources_settings.global_settings.anchor.y = value
				Plater.UpdateAllPlates()
			end,
			min = -100,
			max = 100,
			step = 1,
			usedecimals = true,
			name = LOC["OPTIONS_YOFFSET"],
			desc = "Slightly move vertically.",
		},

        --scale
		{
			type = "range",
			get = function() return Plater.db.profile.resources_settings.global_settings.scale end,
			set = function (self, fixedparam, value)
				Plater.db.profile.resources_settings.global_settings.scale = value
                --call update on the resource bar
				Plater.UpdateAllPlates()
			end,
			min = 0.6,
			max = 2,
			step = 0.1,
			usedecimals = true,
			name = "Scale",
			desc = "Scale",
		},
        --padding
		{
			type = "range",
			get = function() return Plater.db.profile.resources_settings.global_settings.padding end,
			set = function (self, fixedparam, value)
				Plater.db.profile.resources_settings.global_settings.padding = value
                --call update on the resource bar
				Plater.UpdateAllPlates()
			end,
			min = -10,
			max = 10,
			step = 1,
			name = "Padding",
			desc = "Padding",
		},
    }

    local optionChangedCallback = function()
        Plater.Resources.RefreshResourcesDBUpvalues()
    end

	_G.C_Timer.After(1.4, function()
		--TODO to other frame for now
		--DF:BuildMenu(optionsFrame, globalResourceOptions, 5, -5, CONST_SCROLLBOX_HEIGHT, true, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template, optionChangedCallback)

        globalResourceOptions.always_boxfirst = true
		DF:BuildMenu(frame, globalResourceOptions, startX, startY, heightSize, false, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template, optionChangedCallback)

        --for widgetId, widget in pairs(frame.widgetids) do
        --    print(widget.hasLabel:GetText())
        --end
	end)
end
