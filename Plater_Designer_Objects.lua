
local _
local addonName, platerInternal = ...
---@type plater
local Plater = Plater
---@type detailsframework
local detailsFramework = _G.DetailsFramework
local _

local designer = platerInternal.Designer

local PixelUtil = PixelUtil
local CreateFrame = CreateFrame
local C_Timer = C_Timer
local UnitName = UnitName

---@class plater_designer_options : table

local options = designer.Options

function designer.CreateSettings(parentFrame)
    options.WidgetSettingsMapTables = {
        UnitName = {
            --text = UnitName("player"),
            size = "actorname_text_size",
            font = "actorname_text_font",
            color = "actorname_text_color",
            outline = "actorname_text_outline",
            shadowcolor = "actorname_text_shadow_color",
            shadowoffsetx = "actorname_text_shadow_color_offset[1]",
            shadowoffsety = "actorname_text_shadow_color_offset[2]",
            anchor = "actorname_text_anchor.side",
            anchoroffsetx = "actorname_text_anchor.x",
            anchoroffsety = "actorname_text_anchor.y",
            --name_attach_to_role_icon = "name_attach_to_role_icon",
            --layer = "name_layer",
            --classcolor = "name_classcolor",
        },

        UnitLevel = {
            --text = "80",
            size = "level_text_size",
            font = "level_text_font",
            --color = "level_text_color",
            outline = "level_text_outline",
            shadowcolor = "level_text_shadow_color",
            shadowoffsetx = "level_text_shadow_color_offset[1]",
            shadowoffsety = "level_text_shadow_color_offset[2]",
            anchor = "level_text_anchor.side",
            anchoroffsetx = "level_text_anchor.x",
            anchoroffsety = "level_text_anchor.y",
            alpha = "level_text_alpha",
            --name_attach_to_role_icon = "name_attach_to_role_icon",
            --layer = "name_layer",
            --classcolor = "name_classcolor",
        },
    }

    options.WidgetSettingsExtraOptions = {
        UnitName = {},
        UnitLevel = {
            {
                key = "level_text_enabled", --the name of the option in the profile table
                label = "Enabled",
                widget = "toggle",
                setter = function(widget, value) designer.UpdateAllNameplates() end,
            },
        },

        --[[
        UnitName = {
            {
                key = "layer",
                label = "Layer",
                widget = "slider",
                setter = function(widget, value) value = math.floor(value); designer.UpdateAllNameplates() end,
                minvalue = 1,
                maxvalue = 5,
            },
            {
                key = "classcolor", --the name of the option in the profile table
                label = "Use Class Color",
                widget = "toggle",
                setter = function(widget, value) designer.UpdateAllNameplates() end,
            },
            {
                key = "name_attach_to_role_icon",
                label = "Snap To Role Icon",
                widget = "toggle",
                setter = function(widget, value) designer.UpdateAllNameplates() end,
            },
        },
        --]]
    }

end