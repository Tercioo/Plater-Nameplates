
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

        CastBarTargetName = {
            size = "castbar_target_text_size",
            font = "castbar_target_font",
            color = "castbar_target_color",
            outline = "castbar_target_outline",
            shadowcolor = "castbar_target_shadow_color",
            shadowoffsetx = "castbar_target_shadow_color_offset[1]",
            shadowoffsety = "castbar_target_shadow_color_offset[2]",
            anchor = "castbar_target_anchor.side",
            anchoroffsetx = "castbar_target_anchor.x",
            anchoroffsety = "castbar_target_anchor.y",
        },

        LifePercent = {
            text = "80",
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

        CastBarSpark = {
            texture = "cast_statusbar_spark_texture", --it'll need a feed of textures, perhaps a function
            width = "cast_statusbar_spark_width",
            vertexcolor = "cast_statusbar_spark_color",
            alpha = "cast_statusbar_spark_alpha",
            --["height"] = 0,
            --["anchor"] = 0,
            --["anchoroffsetx"] = 0,
            --["anchoroffsety"] = 0,

            --cast_statusbar_spark_texture = [[Interface\AddOns\Plater\images\spark1]],
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

        SpellCastTime = {
            --text = "3.2s",
            size = "spellpercent_text_size",
            font = "spellpercent_text_font",
            color = "spellpercent_text_color",
            outline = "spellpercent_text_outline",
            shadowcolor = "spellpercent_text_shadow_color",
            shadowoffsetx = "spellpercent_text_shadow_color_offset[1]",
            shadowoffsety = "spellpercent_text_shadow_color_offset[2]",
            anchor = "spellpercent_text_anchor.side",
            anchoroffsetx = "spellpercent_text_anchor.x",
            anchoroffsety = "spellpercent_text_anchor.y",
            --alpha = "spellpercent_text_alpha",
        },

        BigUnitName = {
            can_move = false,
            size = "big_actorname_text_size",
            font = "big_actorname_text_font",
            color = "big_actorname_text_color",
            outline = "big_actorname_text_outline",
            shadowcolor = "big_actorname_text_shadow_color",
            shadowoffsetx = "big_actorname_text_shadow_color_offset[1]",
            shadowoffsety = "big_actorname_text_shadow_color_offset[2]",
        },

        BigActorTitle = {
            can_move = false,
            size = "big_actortitle_text_size",
            font = "big_actortitle_text_font",
            outline = "big_actortitle_text_outline",
            shadowcolor = "big_actortitle_text_shadow_color",
            shadowoffsetx = "big_actortitle_text_shadow_color_offset[1]",
            shadowoffsety = "big_actortitle_text_shadow_color_offset[2]",
        },

        QuestOptions = {},

        CastBar = {
            --values from PlaterDB.profile.plate_config[unittype]
            width = "cast_incombat[1]", --plate_config.enemynpc.
            height = "cast_incombat[2]", --plate_config.enemynpc.
        },

        HealthBar = {
            --values from PlaterDB.profile.plate_config[unittype]
            width = "health_incombat[1]", --plate_config.enemynpc.
            height = "health_incombat[2]", --plate_config.enemynpc.
        },
    }

    options.WidgetSettingsExtraOptions = {
        HealthBar = {
            
            --[=[
                {
                add:
                health bar 
                health bar texture -> profile root -> profile.health_statusbar_texture
		        use_health_animation = false, profile root
                health_selection_overlay = "Details Flat",
                health_selection_overlay_alpha = 0.1,
                health_selection_overlay_color = {1, 1, 1, 1},    
                		health_statusbar_bgtexture = "PlaterBackground 2",
		health_statusbar_bgcolor = {0.113725, 0.113725, 0.113725, 0.89000000},  
        		border_color = {0, 0, 0, .834},
		border_thickness = 1,          

                mouse hover highlight -> profile root
            		hover_highlight = true,
		            highlight_on_hover_unit_model = false,
		            hover_highlight_alpha = .30,

                health cut off (execute settings) -> profile root
                    health_cutoff = true,
                    health_cutoff_upper = true,
                    health_cutoff_extra_glow = false,
                    health_cutoff_hide_divisor = false,

                border se0ttings
		focus_indicator_enabled = true,
		focus_color = {0, 0, 0, 0.5},
		focus_texture = "PlaterFocus",
                
                aggro flash

                new object for target settings

                new object for raid target
        target_highlight = true,
		target_highlight_alpha = 0.75,
		target_highlight_height = 14,
		target_highlight_color = {0, 0.521568, 1, 1},
		target_highlight_texture = [[Interface\AddOns\Plater\images\selection_indicator3]],
		target_shady_alpha = 0.6,
		target_shady_enabled = true,
		target_shady_combat_only = true,



                new object for indicators fro the main settings window
        		indicator_faction = true,
		indicator_friendlyfaction = false,
		indicator_spec = true,
		indicator_spec_always = false,
		indicator_friendlyspec = false,
		indicator_worldboss = true,
		indicator_elite = true,
		indicator_rare = true,
		indicator_quest = true,
		indicator_pet = true,
		indicator_enemyclass = false,
		indicator_friendlyclass = false,
		indicator_anchor = {side = 2, x = -2, y = 0},
		indicator_scale = 1,
		indicator_shield = false,
		indicator_extra_raidmark = true,
		indicator_raidmark_scale = 1,
		indicator_raidmark_anchor = {side = 2, x = -1, y = 0},
        target_indicator = "Silver",

                new object for theat colors.

                new object for buff settings? there is way too much options there.


                an object for range check and transparency control, those that are  in the main settings tab 

                key = "../../../health_statusbar_texture", --the name of the option in the profile table
                label = "Texture",
                widget = "selectstatusbartexture",
                setter = function(widget, value) designer.UpdateAllNameplates() end,
                tableName = "health_statusbar_texture",
            },
            --]=]
        },

        --tableName is not a field that is used by the designer in the framework
        --it is here so the Plater_Designer can know which field to update in the profile table

        CastBar = {
            {
                key = "castbar_offset_x", --the name of the option in the profile table
                label = "Offset X",
                widget = "slider",
                setter = function(widget, value) designer.UpdateAllNameplates() end,
                minvalue = -16,
                maxvalue = 16,
                step = 1,
                tableName = "castbar_offset_x",
            },
            {
                key = "castbar_offset", --without Y
                label = "Offset Y",
                widget = "slider",
                setter = function(widget, value) designer.UpdateAllNameplates() end,
                minvalue = -16,
                maxvalue = 16,
                step = 1,
                tableName = "castbar_offset_y",
            }


        },

        CastBarSpark = {
            {
                key = "cast_statusbar_spark_hideoninterrupt", --the name of the option in the profile table
                label = "Hide Spark On Interrupt",
                widget = "toggle",
                setter = function(widget, value) designer.UpdateAllNameplates() end,
            },
            {
                key = "cast_statusbar_spark_half", --the name of the option in the profile table
                label = "Half Spark",
                widget = "toggle",
                setter = function(widget, value) designer.UpdateAllNameplates() end,
            },
            {
                key = "cast_statusbar_spark_offset", --the name of the option in the profile table
                label = "Offset",
                widget = "slider",
                setter = function(widget, value) designer.UpdateAllNameplates() end,
                minvalue = -16,
                maxvalue = 16,
                step = 1,
            }
        },

        QuestOptions = {
            {
                key = "quest_enabled", --the name of the option in the profile table
                label = "Enabled",
                widget = "toggle",
                setter = function(widget, value) designer.UpdateAllNameplates() end,
            },
            {
                key = "quest_color_enabled", --the name of the option in the profile table
                label = "Change Color",
                widget = "toggle",
                setter = function(widget, value) designer.UpdateAllNameplates() end,
            },
            {
                key = "quest_color_enemy", --the name of the option in the profile table
                label = "Enemy Quest Color",
                widget = "color",
                setter = function(widget, value) designer.UpdateAllNameplates() end,
            },
            {
                key = "quest_color_neutral", --the name of the option in the profile table
                label = "Neutral Quest Color",
                widget = "color",
                setter = function(widget, value) designer.UpdateAllNameplates() end,
            },
        },

        UnitName = {},

        CastBarTargetName = {
            {
                key = "castbar_target_show", --the name of the option in the profile table
                label = "Enabled",
                widget = "toggle",
                setter = function(widget, value) designer.UpdateAllNameplates() end,
            },

            {
                key = "castbar_target_notank", --the name of the option in the profile table
                label = "No Tank",
                widget = "toggle",
                setter = function(widget, value) designer.UpdateAllNameplates() end,
            },
        },

        BigUnitName = {},
        BigActorTitle = {},

        UnitLevel = {
            {
                key = "level_text_enabled", --the name of the option in the profile table
                label = "Enabled",
                widget = "toggle",
                setter = function(widget, value) designer.UpdateAllNameplates() end,
            },
        },

        SpellCastTime = {
            {
                key = "spellpercent_text_enabled", --the name of the option in the profile table
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