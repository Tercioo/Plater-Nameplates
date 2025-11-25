
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

        LifePercent = {
            --text = "80",
            size = "percent_text_size",
            font = "percent_text_font",
            color = "percent_text_color",
            outline = "percent_text_outline",
            percent_text_shadow_color = "percent_text_shadow_color",
            shadowoffsetx = "percent_text_shadow_color_offset[1]",
            shadowoffsety = "percent_text_shadow_color_offset[2]",
            anchor = "percent_text_anchor.side",
            anchoroffsetx = "percent_text_anchor.x",
            anchoroffsety = "percent_text_anchor.y",
            alpha = "percent_text_alpha",
        },

        SpellName = {
            --text = UnitName("player"),
            size = "spellname_text_size",
            font = "spellname_text_font",
            color = "spellname_text_color",
            outline = "spellname_text_outline",
            shadowcolor = "spellname_text_shadow_color",
            shadowoffsetx = "spellname_text_shadow_color_offset[1]",
            shadowoffsety = "spellname_text_shadow_color_offset[2]",
            anchor = "spellname_text_anchor.side",
            anchoroffsetx = "spellname_text_anchor.x",
            anchoroffsety = "spellname_text_anchor.y",
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

        SpellName = {},

        LifePercent = {
            { --enabled
                key = "percent_text_enabled", --the name of the option in the profile table
                label = "Enabled",
                widget = "toggle",
                setter = function(widget, value) designer.UpdateAllNameplates() end,
            },
            {--out oc combat
                key = "percent_text_ooc", --the name of the option in the profile table
                label = "Show Out Of Combat",
                widget = "toggle",
                setter = function(widget, value) designer.UpdateAllNameplates() end,
            },
            {--show percent
                key = "percent_show_percent", --the name of the option in the profile table
                label = "Show Percent",
                widget = "toggle",
                setter = function(widget, value) designer.UpdateAllNameplates() end,
            },
            {--show decimals
                key = "percent_text_show_decimals", --the name of the option in the profile table
                label = "Show Decimals",
                widget = "toggle",
                setter = function(widget, value) designer.UpdateAllNameplates() end,
            },
            {--show health value
                key = "percent_show_health", --the name of the option in the profile table
                label = "Show Health Value",
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