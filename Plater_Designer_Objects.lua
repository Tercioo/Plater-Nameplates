
local _
local addonName, platerInternal = ...
---@type plater
local Plater = Plater
---@type detailsframework
local detailsFramework = _G.DetailsFramework
local _
local LSM = LibStub:GetLibrary ("LibSharedMedia-3.0")
local designer = platerInternal.Designer
local L = detailsFramework.Language.GetLanguageTable(addonName)

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
            --texture = "cast_statusbar_spark_texture", --it'll need a feed of textures, perhaps a function
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

        NameplateSize = {
            --values from PlaterDB.profile.plate_config[unittype]
            width = "health_incombat[1]", --plate_config.enemynpc.
            height = "health_incombat[2]", --plate_config.enemynpc.
        },

        ExecuteRange = {},

        Target = {},

        Focus = {},

        --indicator_raidmark_anchor is a {side, x, y} table on profile root; mapping anchor +
        --offsets here lets the editor's built-in anchor handling (mover, side dropdown, offset
        --sliders) drive the raid mark's PlaterRaidTargetFrame container.
        RaidMark = {
            anchor = "indicator_raidmark_anchor.side",
            anchoroffsetx = "indicator_raidmark_anchor.x",
            anchoroffsety = "indicator_raidmark_anchor.y",
        },

        Colors = {},
        MidnightMobColors = {},
        Auras = {},
        AuraTracking = {},
        AuraBorderColors = {},
        StackCounter = {},
        AuraTimer = {},
        Indicators = {},
    }

    --in-memory mirror of target-related CVars. used as the profileTable override on Target's
    --CVar extras because the editor needs a non-nil value at registration time and the actual
    --CVar lives outside Plater.db.profile. seeded once when the designer first opens; the
    --setters keep it in sync alongside SetCVar() so re-opens stay consistent within the session.
    local cvarMirror = {
        nameplateTargetRadialPosition = GetCVarBool("nameplateTargetRadialPosition"),
        nameplateTargetBehindMaxDistance = tonumber(GetCVar("nameplateTargetBehindMaxDistance")),
        nameplateSelectedScale = tonumber(GetCVar("nameplateSelectedScale")),
    }

    --decorates a color option with the live hover preview (paints the preview's healthBar
    --while hovering or while the picker is open). composes with the option's existing setter
    --so options that also call Plater.UpdateAllNameplateColors etc. keep working unchanged.
    local addColorPreview = function(option)
        local profilePath = option.key
        local originalSetter = option.setter

        local paintPreview = function()
            local healthBar = designer.plateFrame.unitFrame.healthBar
            local color = detailsFramework.table.getfrompath(Plater.db.profile, profilePath)
            healthBar:SetStatusBarColor(color[1], color[2], color[3], color[4] or 1)
        end

        option.setter = function(colors, value)
            if (originalSetter) then
                originalSetter(colors, value)
            end
            --keep painting while the picker is open (the preview plate is not in GetAllShownPlates).
            if (ColorPickerFrame:IsShown()) then
                paintPreview()
            end
        end

        option.onenter = function(widget)
            local healthBar = designer.plateFrame.unitFrame.healthBar
            --save the original color only on the first enter so a second hover during a
            --picker session does not overwrite it with the in-progress preview color.
            if (not widget.savedHealthBarColor) then
                widget.savedHealthBarColor = {healthBar:GetStatusBarColor()}
            end
            paintPreview()

            --install once per pooled widget. fires on any picker close (ok, cancel, dismiss)
            --and restores the bar to the pre-hover color. scoped via savedHealthBarColor so
            --it no-ops for other widgets sharing the global ColorPickerFrame.
            if (not widget.colorPickerHideHookInstalled) then
                widget.colorPickerHideHookInstalled = true
                ColorPickerFrame:HookScript("OnHide", function()
                    if (widget.savedHealthBarColor) then
                        designer.plateFrame.unitFrame.healthBar:SetStatusBarColor(unpack(widget.savedHealthBarColor))
                        widget.savedHealthBarColor = nil
                    end
                end)
            end
        end

        option.onleave = function(widget)
            --keep the preview active while the picker is up so moving the mouse off the
            --colorpick button (onto the picker frame) does not revert mid-pick.
            if (ColorPickerFrame:IsShown()) then
                return
            end
            local healthBar = designer.plateFrame.unitFrame.healthBar
            if (widget.savedHealthBarColor) then
                healthBar:SetStatusBarColor(unpack(widget.savedHealthBarColor))
                widget.savedHealthBarColor = nil
            end
        end

        return option
    end

    options.WidgetSettingsExtraOptions = {
        HealthBar = {
            {
                key = "health_statusbar_texture",
                label = "Texture",
                widget = "selectstatusbartexture",
                default = Plater.db.profile.health_statusbar_texture,
                setter = function(healthBar, value) healthBar:SetTexture(LSM:Fetch("statusbar", value)); designer.UpdateAllNameplates() end,
            },

            {
                key = "health_statusbar_bgcolor",
                label = "Background Color",
                widget = "color",
                default = Plater.db.profile.health_statusbar_bgcolor,
                setter = function(healthBar, color)
                    local r, g, b, a = unpack(color)
                    healthBar.background:SetVertexColor(r, g, b, a); designer.UpdateAllNameplates()
                end,
            },

            {type = "blank"},

            {
                key = "border_color",
                label = "Border Color",
                widget = "color",
                default = Plater.db.profile.border_color,
                setter = function(healthBar, color)
                    local r, g, b, a = unpack(color)
                    Plater.UpdatePlateBorders(healthBar.unitFrame.PlateFrame) designer.UpdateAllNameplates()
                end,
            },

            {
                key = "border_thickness",
                label = "Border Thickness",
                widget = "slider",
                minvalue = 0,
                maxvalue = 10,
                step = 1,
                default = Plater.db.profile.border_thickness,
                setter = function(healthBar, value)
                    Plater.UpdatePlateBorders(healthBar.unitFrame.PlateFrame) designer.UpdateAllNameplates()
                end,
            },

            {type = "blank"},

            --hover over hightlight
            {
                key = "hover_highlight",
                label = "Mouse Hover Highlight",
                widget = "toggle",
                default = Plater.db.profile.hover_highlight,
                setter = function(healthBar, value)
                    if value then
                        Plater.EnableHighlight(healthBar.unitFrame)
                    else
                        Plater.DisableHighlight(healthBar.unitFrame)
                    end
                    designer.UpdateAllNameplates()
                end,
            },
            --hover_highlight_alpha
            {
                key = "hover_highlight_alpha",
                label = "Mouse Hover Highlight Alpha",
                widget = "slider",
                minvalue = 0,
                maxvalue = 1,
                step = 0.1,
                usedecimals = true,
                default = Plater.db.profile.hover_highlight_alpha,
                setter = function(healthBar, value)
                    healthBar.unitFrame.HighlightFrame.HighlightTexture:SetAlpha(Plater.db.profile.hover_highlight_alpha); designer.UpdateAllNameplates()
                end,
            },

            {type = "blank"},


        },

        ExecuteRange = {
            --execution range (health cutoff)
            {
                key = "health_cutoff",
                label = L["OPTIONS_EXECUTERANGE"],
                widget = "toggle",
                default = Plater.db.profile.health_cutoff,
                setter = function(healthBar, value) designer.UpdateAllNameplates() end,
            },
            {
                key = "health_cutoff_upper",
                label = L["OPTIONS_EXECUTERANGE_HIGH_HEALTH"],
                widget = "toggle",
                default = Plater.db.profile.health_cutoff_upper,
                setter = function(healthBar, value) designer.UpdateAllNameplates() end,
            },
            {
                key = "health_cutoff_extra_glow",
                label = "Add Extra Glow to Execute Range",
                widget = "toggle",
                default = Plater.db.profile.health_cutoff_extra_glow,
                setter = function(healthBar, value) designer.UpdateAllNameplates() end,
            },
        },

            --{
            --    key = "health_cutoff_hide_divisor",
            --    label = L["OPTIONS_EXECUTERANGE_HIDE_DIVISOR"],
            --    widget = "toggle",
            --    default = Plater.db.profile.health_cutoff_hide_divisor,
            --    setter = function(healthBar, value) designer.UpdateAllNameplates() end,
            --},

            --[=[
                {
                add:
                health bar 
                    use_health_animation = false, profile root

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
            },

            {type = "blank"},

            --root-level cast bar appearance. profileTable override points reads/writes at Plater.db.profile
            --since Cast Bar's registration is bound to plate_config.<actorType>.
            {
                key = "cast_statusbar_texture",
                label = "Texture",
                widget = "selectstatusbartexture",
                profileTable = Plater.db.profile,
                default = Plater.db.profile.cast_statusbar_texture,
                setter = function(castBar, value)
                    castBar:SetStatusBarTexture(LSM:Fetch("statusbar", value))
                    designer.UpdateAllNameplates()
                end,
            },
            {
                key = "cast_statusbar_bgtexture",
                label = "Background Texture",
                widget = "selectstatusbartexture",
                profileTable = Plater.db.profile,
                default = Plater.db.profile.cast_statusbar_bgtexture,
                setter = function(castBar, value)
                    castBar.background:SetTexture(LSM:Fetch("statusbar", value))
                    designer.UpdateAllNameplates()
                end,
            },

            {type = "blank"},

            {
                key = "cast_statusbar_use_fade_effects",
                label = "Enable fade animation",
                widget = "toggle",
                profileTable = Plater.db.profile,
                default = Plater.db.profile.cast_statusbar_use_fade_effects,
                setter = function(castBar, value) designer.UpdateAllNameplates() end,
            },
            {
                key = "cast_statusbar_fadein_time",
                label = "On start",
                widget = "slider",
                minvalue = 0.01,
                maxvalue = 1,
                step = 0.01,
                usedecimals = true,
                profileTable = Plater.db.profile,
                default = Plater.db.profile.cast_statusbar_fadein_time,
                setter = function(castBar, value) designer.UpdateAllNameplates() end,
            },
            {
                key = "cast_statusbar_fadeout_time",
                label = "On stop",
                widget = "slider",
                minvalue = 0.01,
                maxvalue = 2,
                step = 0.01,
                usedecimals = true,
                profileTable = Plater.db.profile,
                default = Plater.db.profile.cast_statusbar_fadeout_time,
                setter = function(castBar, value) designer.UpdateAllNameplates() end,
            },

            {type = "blank"},

            {
                key = "show_interrupt_author",
                label = "Show Interrupt Author",
                widget = "toggle",
                profileTable = Plater.db.profile,
                default = Plater.db.profile.show_interrupt_author,
                setter = function(castBar, value) designer.UpdateAllNameplates() end,
            },
            {
                key = "cast_statusbar_interrupt_anim",
                label = "Play Interrupt Animation",
                widget = "toggle",
                profileTable = Plater.db.profile,
                default = Plater.db.profile.cast_statusbar_interrupt_anim,
                setter = function(castBar, value) designer.UpdateAllNameplates() end,
            },
            {
                key = "cast_statusbar_spark_filloninterrupt",
                label = "Fill Cast Bar On Interrupt",
                widget = "toggle",
                profileTable = Plater.db.profile,
                default = Plater.db.profile.cast_statusbar_spark_filloninterrupt,
                setter = function(castBar, value) designer.UpdateAllNameplates() end,
            },
            {
                key = "cast_statusbar_quickhide",
                label = "Quick Hide Cast Bar",
                widget = "toggle",
                profileTable = Plater.db.profile,
                default = Plater.db.profile.cast_statusbar_quickhide,
                setter = function(castBar, value) designer.UpdateAllNameplates() end,
            },
            {
                key = "hide_friendly_castbars",
                label = "Hide Friendly Cast Bar",
                widget = "toggle",
                profileTable = Plater.db.profile,
                default = Plater.db.profile.hide_friendly_castbars,
                setter = function(castBar, value) designer.UpdateAllNameplates() end,
            },
            {
                key = "hide_enemy_castbars",
                label = "Hide Enemy Cast Bar",
                widget = "toggle",
                profileTable = Plater.db.profile,
                default = Plater.db.profile.hide_enemy_castbars,
                setter = function(castBar, value) designer.UpdateAllNameplates() end,
            },

            {type = "blank"},
            {type = "label", get = function() return "OPTIONS_CASTBAR_COLORS" end, text_template = detailsFramework:GetTemplate("font", "ORANGE_FONT_TEMPLATE")},

            {
                key = "cast_statusbar_color",
                label = "Regular",
                widget = "color",
                profileTable = Plater.db.profile,
                default = Plater.db.profile.cast_statusbar_color,
                setter = function(castBar, value) designer.UpdateAllNameplates() end,
            },
            {
                key = "cast_statusbar_color_channeling",
                label = "Channelled",
                widget = "color",
                profileTable = Plater.db.profile,
                default = Plater.db.profile.cast_statusbar_color_channeling,
                setter = function(castBar, value) designer.UpdateAllNameplates() end,
            },
            {
                key = "cast_statusbar_color_empowered",
                label = "Empowered",
                widget = "color",
                profileTable = Plater.db.profile,
                default = Plater.db.profile.cast_statusbar_color_empowered,
                setter = function(castBar, value) designer.UpdateAllNameplates() end,
            },
            {
                key = "cast_statusbar_color_important",
                label = "Important",
                widget = "color",
                profileTable = Plater.db.profile,
                default = Plater.db.profile.cast_statusbar_color_important,
                setter = function(castBar, value) designer.UpdateAllNameplates() end,
            },
            {
                key = "cast_statusbar_color_nointerrupt",
                label = "Uninterruptible",
                widget = "color",
                profileTable = Plater.db.profile,
                default = Plater.db.profile.cast_statusbar_color_nointerrupt,
                setter = function(castBar, value) designer.UpdateAllNameplates() end,
            },
            {
                key = "cast_statusbar_color_interrupted",
                label = "Interrupted",
                widget = "color",
                profileTable = Plater.db.profile,
                default = Plater.db.profile.cast_statusbar_color_interrupted,
                setter = function(castBar, value) designer.UpdateAllNameplates() end,
            },
            {
                key = "cast_statusbar_color_finished",
                label = "Success",
                widget = "color",
                profileTable = Plater.db.profile,
                default = Plater.db.profile.cast_statusbar_color_finished,
                setter = function(castBar, value) designer.UpdateAllNameplates() end,
            },
            {
                key = "cast_statusbar_bgcolor",
                label = "Background Color",
                widget = "color",
                profileTable = Plater.db.profile,
                default = Plater.db.profile.cast_statusbar_bgcolor,
                setter = function(castBar, value) designer.UpdateAllNameplates() end,
            },

            {type = "blank"},
            {type = "label", get = function() return "OPTIONS_CASTBAR_SPELLICON" end, text_template = detailsFramework:GetTemplate("font", "ORANGE_FONT_TEMPLATE")},

            {
                key = "castbar_icon_customization_enabled",
                label = "Enable Custom Icon",
                widget = "toggle",
                profileTable = Plater.db.profile,
                default = Plater.db.profile.castbar_icon_customization_enabled,
                setter = function(castBar, value) designer.UpdateAllNameplates() end,
            },
            {
                key = "castbar_icon_show",
                label = "Show Icon",
                widget = "toggle",
                profileTable = Plater.db.profile,
                default = Plater.db.profile.castbar_icon_show,
                setter = function(castBar, value) designer.UpdateAllNameplates() end,
            },
            {
                key = "castbar_icon_attach_to_side",
                label = "Icon Side",
                widget = "dropdown",
                profileTable = Plater.db.profile,
                default = Plater.db.profile.castbar_icon_attach_to_side,
                dropdownFunc = function()
                    return {
                        {value = "left", label = "Left"},
                        {value = "right", label = "Right"},
                    }
                end,
                setter = function(castBar, value) designer.UpdateAllNameplates() end,
            },
            {
                key = "castbar_icon_size",
                label = "Icon Size",
                widget = "dropdown",
                profileTable = Plater.db.profile,
                default = Plater.db.profile.castbar_icon_size,
                dropdownFunc = function()
                    return {
                        {value = "same as castbar", label = "Castbar Size"},
                        {value = "same as castbar plus healthbar", label = "Castbar + Healthbar Size"},
                    }
                end,
                setter = function(castBar, value) designer.UpdateAllNameplates() end,
            },
            {
                key = "castbar_icon_x_offset",
                label = "X Offset",
                widget = "slider",
                minvalue = -20,
                maxvalue = 20,
                step = 1,
                profileTable = Plater.db.profile,
                default = Plater.db.profile.castbar_icon_x_offset,
                setter = function(castBar, value) designer.UpdateAllNameplates() end,
            },
            {
                key = "castbar_icon_showshield",
                label = "Show Shield",
                widget = "toggle",
                profileTable = Plater.db.profile,
                default = Plater.db.profile.castbar_icon_showshield,
                setter = function(castBar, value) designer.UpdateAllNameplates() end,
            },

            {type = "blank"},
            {type = "label", get = function() return "OPTIONS_CASTBAR_BLIZZCASTBAR" end, text_template = detailsFramework:GetTemplate("font", "ORANGE_FONT_TEMPLATE")},

            {
                key = "hide_blizzard_castbar",
                label = "Hide Blizzard Cast Bar",
                widget = "toggle",
                profileTable = Plater.db.profile,
                default = Plater.db.profile.hide_blizzard_castbar,
                setter = function(castBar, value) designer.UpdateAllNameplates() end,
            },
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

        --all options copied from the options panel "colors / threat" section (Plater_OptionsPanel.lua
        --thread_options table). settings are global, so they read and write at profile root.
        Colors = {
            {type = "label", get = function() return "Threat Modifies" end, text_template = detailsFramework:GetTemplate("font", "ORANGE_FONT_TEMPLATE")},

            {
                key = "aggro_modifies.health_bar_color",
                label = "Health Bar Color",
                widget = "toggle",
                default = Plater.db.profile.aggro_modifies.health_bar_color,
                setter = function(colors, value) designer.UpdateAllNameplates() end,
            },
            {
                key = "aggro_modifies.border_color",
                label = "Border Color",
                widget = "toggle",
                default = Plater.db.profile.aggro_modifies.border_color,
                setter = function(colors, value) designer.UpdateAllNameplates() end,
            },
            {
                key = "aggro_modifies.actor_name_color",
                label = "Name Color",
                widget = "toggle",
                default = Plater.db.profile.aggro_modifies.actor_name_color,
                setter = function(colors, value) designer.UpdateAllNameplates() end,
            },

            {type = "blank"},
            {type = "label", get = function() return "Color When Playing as TANK" end, text_template = detailsFramework:GetTemplate("font", "ORANGE_FONT_TEMPLATE")},

            addColorPreview({
                key = "tank.colors.aggro",
                label = "Aggro on You",
                desc = "The unit is attacking you and you have solid aggro.",
                widget = "color",
                default = Plater.db.profile.tank.colors.aggro,
                setter = function(colors, value) designer.UpdateAllNameplates() end,
            }),
            addColorPreview({
                key = "tank.colors.anothertank",
                label = "Aggro on Another Tank",
                desc = "The unit is being tanked by another tank in your group.",
                widget = "color",
                default = Plater.db.profile.tank.colors.anothertank,
                setter = function(colors, value) designer.UpdateAllNameplates() end,
            }),
            addColorPreview({
                key = "tank.colors.pulling",
                label = "Aggro on You But is Low",
                desc = "The unit is attacking you but others are about to pull the aggro.",
                widget = "color",
                default = Plater.db.profile.tank.colors.pulling,
                setter = function(colors, value) designer.UpdateAllNameplates() end,
            }),
            addColorPreview({
                key = "tank.colors.noaggro",
                label = "No Aggro",
                desc = "The unit does not have aggro on you.",
                widget = "color",
                default = Plater.db.profile.tank.colors.noaggro,
                setter = function(colors, value) designer.UpdateAllNameplates() end,
            }),
            addColorPreview({
                key = "tank.colors.pulling_from_tank",
                label = "Pulling From Another Tank",
                desc = "The unit has aggro on another tank and you're about to pull it.",
                widget = "color",
                default = Plater.db.profile.tank.colors.pulling_from_tank,
                setter = function(colors, value) designer.UpdateAllNameplates() end,
            }),

            {type = "blank"},
            {type = "label", get = function() return "Color When Playing as DPS or HEALER" end, text_template = detailsFramework:GetTemplate("font", "ORANGE_FONT_TEMPLATE")},

            addColorPreview({
                key = "dps.colors.aggro",
                label = "Aggro on You",
                desc = "The unit is attacking you.",
                widget = "color",
                default = Plater.db.profile.dps.colors.aggro,
                setter = function(colors, value) designer.UpdateAllNameplates() end,
            }),
            addColorPreview({
                key = "dps.colors.pulling",
                label = "High Threat",
                desc = "The unit is about to start attacking you.",
                widget = "color",
                default = Plater.db.profile.dps.colors.pulling,
                setter = function(colors, value) designer.UpdateAllNameplates() end,
            }),
            addColorPreview({
                key = "dps.colors.noaggro",
                label = "No Aggro",
                desc = "The unit isn't attacking you.",
                widget = "color",
                default = Plater.db.profile.dps.colors.noaggro,
                setter = function(colors, value) designer.UpdateAllNameplates() end,
            }),
            {
                key = "dps.use_aggro_solo",
                label = "Use 'Solo' color",
                desc = "Use the 'Solo' color when not in a group.",
                widget = "toggle",
                default = Plater.db.profile.dps.use_aggro_solo,
                setter = function(colors, value) designer.UpdateAllNameplates() end,
            },
            addColorPreview({
                key = "dps.colors.solo",
                label = "Solo Color",
                desc = "Use the 'Solo' color when not in a group.",
                widget = "color",
                default = Plater.db.profile.dps.colors.solo,
                setter = function(colors, value) designer.UpdateAllNameplates() end,
            }),

            {type = "blank"},

            {
                key = "aggro_can_check_notank",
                label = "Check for No Tank Aggro",
                desc = "When you don't have aggro as healer or dps, check if the enemy is attacking another unit that isn't a tank.",
                widget = "toggle",
                default = Plater.db.profile.aggro_can_check_notank,
                setter = function(colors, value) designer.UpdateAllNameplates() end,
            },
            addColorPreview({
                key = "dps.colors.notontank",
                label = "No Tank Aggro",
                desc = "The unit isn't attacking you or a tank and most likely is attacking another healer or dps from your group.",
                widget = "color",
                default = Plater.db.profile.dps.colors.notontank,
                setter = function(colors, value) designer.UpdateAllNameplates() end,
            }),

            {type = "blank"},

            addColorPreview({
                key = "tank.colors.nocombat",
                label = "Unit Not in Combat",
                desc = "The unit isn't in combat.",
                widget = "color",
                default = Plater.db.profile.tank.colors.nocombat,
                setter = function(colors, value) designer.UpdateAllNameplates() end,
            }),
            addColorPreview({
                key = "tap_denied_color",
                label = "Unit Tapped",
                desc = "When someone else has claimed the unit (when you don't receive experience or loot for killing it).",
                widget = "color",
                default = Plater.db.profile.tap_denied_color,
                setter = function(colors, value) designer.UpdateAllNameplates() end,
            }),

            {type = "blank"},
            {type = "label", get = function() return "Tank or DPS Colors:" end, text_template = detailsFramework:GetTemplate("font", "ORANGE_FONT_TEMPLATE")},

            --this toggle is hidden on retail in the options panel (classic only setting). kept here
            --so all options are reachable from the editor.
            {
                key = "tank_threat_colors",
                label = "Use Tank Threat Colors",
                widget = "toggle",
                default = Plater.db.profile.tank_threat_colors,
                setter = function(colors, value)
                    Plater.RefreshTankCache()
                    designer.UpdateAllNameplates()
                end,
            },

            {type = "blank"},
            {type = "label", get = function() return "Override Default Colors" end, text_template = detailsFramework:GetTemplate("font", "ORANGE_FONT_TEMPLATE")},

            {
                key = "color_override",
                label = "Enabled",
                desc = "Modify the default colors set by the game for neutral, hostile and friendly units. During combat, these colors will be override as well if threat colors are allowed to change health bar color.",
                widget = "toggle",
                default = Plater.db.profile.color_override,
                setter = function(colors, value)
                    Plater.RefreshColorOverride()
                    designer.UpdateAllNameplates()
                end,
            },
            addColorPreview({
                key = "color_override_colors[3]",
                label = "Hostile",
                desc = "Hostile",
                widget = "color",
                default = Plater.db.profile.color_override_colors[3],
                setter = function(colors, value)
                    Plater.UpdateAllNameplateColors()
                    designer.UpdateAllNameplates()
                end,
            }),
            addColorPreview({
                key = "color_override_colors[4]",
                label = "Neutral",
                desc = "Neutral",
                widget = "color",
                default = Plater.db.profile.color_override_colors[4],
                setter = function(colors, value)
                    Plater.UpdateAllNameplateColors()
                    designer.UpdateAllNameplates()
                end,
            }),
            addColorPreview({
                key = "color_override_colors[5]",
                label = "Friendly",
                desc = "Friendly",
                widget = "color",
                default = Plater.db.profile.color_override_colors[5],
                setter = function(colors, value)
                    Plater.UpdateAllNameplateColors()
                    designer.UpdateAllNameplates()
                end,
            }),

            {type = "blank"},
            {type = "label", get = function() return "Misc:" end, text_template = detailsFramework:GetTemplate("font", "ORANGE_FONT_TEMPLATE")},

            {
                key = "show_aggro_flash",
                label = "Enable aggro flash",
                desc = "Enables the -AGGRO- flash animation on the nameplates when gaining aggro as dps.",
                widget = "toggle",
                default = Plater.db.profile.show_aggro_flash,
                setter = function(colors, value) designer.UpdateAllNameplates() end,
            },
            {
                key = "show_aggro_glow",
                label = "Enable health bar aggro glow",
                desc = "Enables the healthbar glow on the nameplates when gaining aggro as dps or losing aggro as tank.",
                widget = "toggle",
                default = Plater.db.profile.show_aggro_glow,
                setter = function(colors, value) designer.UpdateAllNameplates() end,
            },

        },

        --unit-type coloring extras, surfaced as their own widget (Midnight Mob Colors).
        --kept separate from Colors so the threat/override section stays focused on threat.
        MidnightMobColors = {
            {
                key = "unit_type_coloring_enabled",
                label = "Enabled",
                desc = "Enable unit type coloring with the colors below. Only active in dungeons and raids. Bad threat states will override this color.",
                widget = "toggle",
                default = Plater.db.profile.unit_type_coloring_enabled,
                setter = function(colors, value)
                    Plater.UpdateAllNameplateColors()
                    designer.UpdateAllNameplates()
                end,
            },
            {
                key = "unit_type_coloring_no_override_threat",
                label = "Threat overrides unit type",
                desc = "Threat coloring will have priority over unit type colors.",
                widget = "toggle",
                default = Plater.db.profile.unit_type_coloring_no_override_threat,
                setter = function(colors, value)
                    Plater.UpdateAllNameplateColors()
                    designer.UpdateAllNameplates()
                end,
            },

            {type = "blank"},

            addColorPreview({
                key = "unit_type_coloring_boss",
                label = "Boss",
                desc = "Color for raid or dungeon bosses.",
                widget = "color",
                default = Plater.db.profile.unit_type_coloring_boss,
                setter = function(colors, value)
                    Plater.UpdateAllNameplateColors()
                    designer.UpdateAllNameplates()
                end,
            }),
            addColorPreview({
                key = "unit_type_coloring_miniboss",
                label = "Miniboss",
                desc = "Color for minibosses.",
                widget = "color",
                default = Plater.db.profile.unit_type_coloring_miniboss,
                setter = function(colors, value)
                    Plater.UpdateAllNameplateColors()
                    designer.UpdateAllNameplates()
                end,
            }),
            addColorPreview({
                key = "unit_type_coloring_caster",
                label = "Caster",
                desc = "Color for caster units.",
                widget = "color",
                default = Plater.db.profile.unit_type_coloring_caster,
                setter = function(colors, value)
                    Plater.UpdateAllNameplateColors()
                    designer.UpdateAllNameplates()
                end,
            }),

            {type = "blank"},

            {
                key = "unit_type_coloring_enable_elite",
                label = "Enable elite",
                desc = "Will override non-elite colors as 'elite'.",
                widget = "toggle",
                default = Plater.db.profile.unit_type_coloring_enable_elite,
                setter = function(colors, value)
                    Plater.UpdateAllNameplateColors()
                    designer.UpdateAllNameplates()
                end,
            },
            addColorPreview({
                key = "unit_type_coloring_elite",
                label = "Elite",
                desc = "Color for elite units.",
                widget = "color",
                default = Plater.db.profile.unit_type_coloring_elite,
                setter = function(colors, value)
                    Plater.UpdateAllNameplateColors()
                    designer.UpdateAllNameplates()
                end,
            }),

            {type = "blank"},

            {
                key = "unit_type_coloring_enable_trivial",
                label = "Enable trivial",
                desc = "Will override non-elite colors as 'trivial'.",
                widget = "toggle",
                default = Plater.db.profile.unit_type_coloring_enable_trivial,
                setter = function(colors, value)
                    Plater.UpdateAllNameplateColors()
                    designer.UpdateAllNameplates()
                end,
            },
            addColorPreview({
                key = "unit_type_coloring_trivial",
                label = "Trivial",
                desc = "Color for non-elite/trivial units.",
                widget = "color",
                default = Plater.db.profile.unit_type_coloring_trivial,
                setter = function(colors, value)
                    Plater.UpdateAllNameplateColors()
                    designer.UpdateAllNameplates()
                end,
            }),
        },

        --all options copied from the options panel "buffs" section (Plater_OptionsPanel.lua
        --debuff_options table). settings are global, so they read and write at profile root.
        Auras = (function()
            --setter helpers (closures captured below). most aura settings need to refresh DB
            --upvalues and force a full plate update, sometimes also rebuilding the icon pool.
            local refreshAuraDB = function()
                Plater.RefreshDBUpvalues()
                Plater.UpdateAllPlates()
                designer.UpdateAllNameplates()
            end
            local refreshAuraDBAndIcons = function()
                Plater.RefreshDBUpvalues()
                Plater.RefreshAuras()
                Plater.UpdateAllPlates()
                designer.UpdateAllNameplates()
            end
            local updateAllPlatesOnly = function()
                Plater.UpdateAllPlates()
                designer.UpdateAllNameplates()
            end
            local refreshAndUpdateAuras = function()
                Plater.RefreshAuras()
                Plater.UpdateAllPlates()
                designer.UpdateAllNameplates()
            end

            --dropdown option builders. anchor sides + outline modes + grow directions match
            --the values Plater itself uses (see build_anchor_side_table / build_outline_modes_table
            --/ build_grow_direction_options in Plater_OptionsPanel.lua).
            local anchorSideOptions = function()
                return {
                    {value = 1, label = "Top Left"},
                    {value = 2, label = "Left"},
                    {value = 3, label = "Bottom Left"},
                    {value = 4, label = "Bottom"},
                    {value = 5, label = "Bottom Right"},
                    {value = 6, label = "Right"},
                    {value = 7, label = "Top Right"},
                    {value = 8, label = "Top"},
                    {value = 9, label = "Center"},
                }
            end
            local outlineOptions = function()
                return {
                    {value = "NONE", label = "None"},
                    {value = "MONOCHROME", label = "Monochrome"},
                    {value = "OUTLINE", label = "Outline"},
                    {value = "THICKOUTLINE", label = "Thick Outline"},
                    {value = "MONOCHROME, OUTLINE", label = "Monochrome + Outline"},
                    {value = "MONOCHROME, THICKOUTLINE", label = "Monochrome + Thick Outline"},
                }
            end
            --grow direction values are numeric (Plater stores 1/2/3, see grow_direction_names
            --in Plater_OptionsPanel.lua near line 1689). using strings here would leave the
            --dropdown showing "no option selected" since the profile value never matches.
            local growDirectionOptions = function()
                return {
                    {value = 1, label = "Left"},
                    {value = 2, label = "Center"},
                    {value = 3, label = "Right"},
                }
            end
            local fontOptions = function()
                local opts = {}
                for fontName in pairs(LSM:HashTable("font")) do
                    opts[#opts + 1] = {value = fontName, label = fontName}
                end
                return opts
            end

            return {
                {type = "label", get = function() return "General Settings" end, text_template = detailsFramework:GetTemplate("font", "ORANGE_FONT_TEMPLATE")},

                {
                    key = "aura_enabled",
                    label = "Enabled",
                    desc = "Master switch for the aura system.",
                    widget = "toggle",
                    default = Plater.db.profile.aura_enabled,
                    setter = function(auras, value) refreshAuraDB() end,
                },
                {
                    key = "aura_show_tooltip",
                    label = "Show Tooltip",
                    desc = "Show tooltip when hovering over the aura icon.",
                    widget = "toggle",
                    default = Plater.db.profile.aura_show_tooltip,
                    setter = function(auras, value) updateAllPlatesOnly() end,
                },
                {
                    key = "aura_alpha",
                    label = "Alpha",
                    desc = "Overall opacity of the aura icons.",
                    widget = "slider",
                    minvalue = 0, maxvalue = 1, step = 0.01, usedecimals = true,
                    default = Plater.db.profile.aura_alpha,
                    setter = function(auras, value) refreshAuraDB() end,
                },
                {
                    key = "aura_padding",
                    label = "Icon Spacing",
                    desc = "Horizontal space between aura icons.",
                    widget = "slider",
                    minvalue = 0, maxvalue = 10, step = 0.01, usedecimals = true,
                    default = Plater.db.profile.aura_padding,
                    setter = function(auras, value) refreshAuraDB() end,
                },
                {
                    key = "aura_breakline_space",
                    label = "Icon Row Spacing",
                    desc = "Vertical space between rows of aura icons.",
                    widget = "slider",
                    minvalue = 0, maxvalue = 15, step = 0.01, usedecimals = true,
                    default = Plater.db.profile.aura_breakline_space,
                    setter = function(auras, value) refreshAuraDB() end,
                },
                {
                    key = "aura_consolidate",
                    label = "Stack Similar Auras",
                    desc = "Auras with the same name (e.g. warlock's unstable affliction debuff) get stacked together.",
                    widget = "toggle",
                    default = Plater.db.profile.aura_consolidate,
                    setter = function(auras, value) updateAllPlatesOnly() end,
                },
                {
                    key = "aura_consolidate_timeleft_lower",
                    label = "Show shortest time of stacked auras",
                    desc = "Show shortest time of stacked auras (or longest when disabled).",
                    widget = "toggle",
                    default = Plater.db.profile.aura_consolidate_timeleft_lower,
                    setter = function(auras, value) updateAllPlatesOnly() end,
                },
                {
                    key = "aura_sort",
                    label = "Sort Auras",
                    desc = "Auras are sorted by time remaining (default).",
                    widget = "toggle",
                    default = Plater.db.profile.aura_sort,
                    setter = function(auras, value) updateAllPlatesOnly() end,
                },
                {
                    key = "aura_max_shown_limit",
                    label = "Max auras shown",
                    desc = "Limit the amount of auras shown. Negative: filter shortest. Positive: filter longest. 0 = no filtering.",
                    widget = "slider",
                    minvalue = -8, maxvalue = 8, step = 1,
                    default = Plater.db.profile.aura_max_shown_limit,
                    setter = function(auras, value) refreshAuraDB() end,
                },

                {type = "blank"},
                {type = "label", get = function() return "Aura Frame 1" end, text_template = detailsFramework:GetTemplate("font", "ORANGE_FONT_TEMPLATE")},

                {
                    key = "aura_width",
                    label = "Width",
                    desc = "Debuff's icon width.",
                    widget = "slider",
                    minvalue = 4, maxvalue = 80, step = 1,
                    default = Plater.db.profile.aura_width,
                    setter = function(auras, value) refreshAuraDBAndIcons() end,
                },
                {
                    key = "aura_height",
                    label = "Height",
                    desc = "Debuff's icon height.",
                    widget = "slider",
                    minvalue = 4, maxvalue = 80, step = 1,
                    default = Plater.db.profile.aura_height,
                    setter = function(auras, value) refreshAuraDBAndIcons() end,
                },
                {
                    key = "aura_border_thickness",
                    label = "Border Thickness",
                    desc = "Border thickness around each aura icon.",
                    widget = "slider",
                    minvalue = 1, maxvalue = 5, step = 1,
                    default = Plater.db.profile.aura_border_thickness,
                    setter = function(auras, value) refreshAuraDBAndIcons() end,
                },
                {
                    key = "aura_grow_direction",
                    label = "Grow Direction",
                    desc = "To which side aura icons should grow. Debuffs are added first, buffs after.",
                    widget = "dropdown",
                    default = Plater.db.profile.aura_grow_direction,
                    dropdownFunc = growDirectionOptions,
                    setter = function(auras, value) refreshAuraDB() end,
                },
                {
                    key = "aura_frame1_anchor.side",
                    label = "Anchor",
                    desc = "Which side of the nameplate this aura frame is attached to.",
                    widget = "dropdown",
                    default = Plater.db.profile.aura_frame1_anchor.side,
                    dropdownFunc = anchorSideOptions,
                    setter = function(auras, value) refreshAuraDB() end,
                },
                {
                    key = "aura_frame1_anchor.x",
                    label = "X Offset",
                    desc = "Horizontal offset from the anchor point.",
                    widget = "slider",
                    minvalue = -200, maxvalue = 200, step = 1, usedecimals = true,
                    default = Plater.db.profile.aura_frame1_anchor.x,
                    setter = function(auras, value)
                        --keep the legacy mirror in sync (Plater reads both keys in places).
                        Plater.db.profile.aura_x_offset = Plater.db.profile.aura_frame1_anchor.x
                        refreshAuraDB()
                    end,
                },
                {
                    key = "aura_frame1_anchor.y",
                    label = "Y Offset",
                    desc = "Vertical offset from the anchor point.",
                    widget = "slider",
                    minvalue = -200, maxvalue = 200, step = 1, usedecimals = true,
                    default = Plater.db.profile.aura_frame1_anchor.y,
                    setter = function(auras, value)
                        Plater.db.profile.aura_y_offset = Plater.db.profile.aura_frame1_anchor.y
                        refreshAuraDB()
                    end,
                },

                {type = "blank"},
                {type = "label", get = function() return "Aura Frame 2" end, text_template = detailsFramework:GetTemplate("font", "ORANGE_FONT_TEMPLATE")},

                {
                    key = "aura_width2",
                    label = "Width",
                    desc = "Icon width for the second aura frame.",
                    widget = "slider",
                    minvalue = 4, maxvalue = 80, step = 1,
                    default = Plater.db.profile.aura_width2,
                    setter = function(auras, value) refreshAuraDBAndIcons() end,
                },
                {
                    key = "aura_height2",
                    label = "Height",
                    desc = "Icon height for the second aura frame.",
                    widget = "slider",
                    minvalue = 4, maxvalue = 80, step = 1,
                    default = Plater.db.profile.aura_height2,
                    setter = function(auras, value) refreshAuraDBAndIcons() end,
                },
                {
                    key = "aura_border_thickness2",
                    label = "Border Thickness",
                    desc = "Border thickness for the second aura frame.",
                    widget = "slider",
                    minvalue = 1, maxvalue = 5, step = 1,
                    default = Plater.db.profile.aura_border_thickness2,
                    setter = function(auras, value) refreshAuraDBAndIcons() end,
                },
                {
                    key = "buffs_on_aura2",
                    label = "Enabled",
                    desc = "When enabled buffs are placed on this second frame and debuffs on the first.",
                    widget = "toggle",
                    default = Plater.db.profile.buffs_on_aura2,
                    setter = function(auras, value) refreshAuraDB() end,
                },
                {
                    key = "aura2_grow_direction",
                    label = "Grow Direction",
                    desc = "To which side aura icons should grow.",
                    widget = "dropdown",
                    default = Plater.db.profile.aura2_grow_direction,
                    dropdownFunc = growDirectionOptions,
                    setter = function(auras, value) refreshAuraDB() end,
                },
                {
                    key = "aura_frame2_anchor.side",
                    label = "Anchor",
                    desc = "Which side of the nameplate this aura frame is attached to.",
                    widget = "dropdown",
                    default = Plater.db.profile.aura_frame2_anchor.side,
                    dropdownFunc = anchorSideOptions,
                    setter = function(auras, value) refreshAuraDB() end,
                },
                {
                    key = "aura_frame2_anchor.x",
                    label = "X Offset",
                    desc = "Horizontal offset from the anchor point.",
                    widget = "slider",
                    minvalue = -200, maxvalue = 200, step = 1, usedecimals = true,
                    default = Plater.db.profile.aura_frame2_anchor.x,
                    setter = function(auras, value)
                        Plater.db.profile.aura2_x_offset = Plater.db.profile.aura_frame2_anchor.x
                        refreshAuraDB()
                    end,
                },
                {
                    key = "aura_frame2_anchor.y",
                    label = "Y Offset",
                    desc = "Vertical offset from the anchor point.",
                    widget = "slider",
                    minvalue = -200, maxvalue = 200, step = 1, usedecimals = true,
                    default = Plater.db.profile.aura_frame2_anchor.y,
                    setter = function(auras, value)
                        Plater.db.profile.aura2_y_offset = Plater.db.profile.aura_frame2_anchor.y
                        refreshAuraDB()
                    end,
                },

                {type = "blank"},
                {type = "label", get = function() return "Auras per Row" end, text_template = detailsFramework:GetTemplate("font", "ORANGE_FONT_TEMPLATE")},

                {
                    key = "auras_per_row_auto",
                    label = "Automatic",
                    desc = "Split auras into rows automatically based on health bar width.",
                    widget = "toggle",
                    default = Plater.db.profile.auras_per_row_auto,
                    setter = function(auras, value) refreshAuraDBAndIcons() end,
                },
                {
                    key = "auras_per_row_amount",
                    label = "Auras per Row 1",
                    desc = "Auras per row when auto-mode is disabled for Aura Frame 1.",
                    widget = "slider",
                    minvalue = 1, maxvalue = 10, step = 1,
                    default = Plater.db.profile.auras_per_row_amount,
                    setter = function(auras, value) refreshAuraDBAndIcons() end,
                },
                {
                    key = "auras_per_row_amount2",
                    label = "Auras per Row 2",
                    desc = "Auras per row when auto-mode is disabled for Aura Frame 2.",
                    widget = "slider",
                    minvalue = 1, maxvalue = 10, step = 1,
                    default = Plater.db.profile.auras_per_row_amount2,
                    setter = function(auras, value) refreshAuraDBAndIcons() end,
                },

                {type = "blank"},
                {type = "label", get = function() return "Swipe Animation" end, text_template = detailsFramework:GetTemplate("font", "ORANGE_FONT_TEMPLATE")},

                {
                    key = "aura_cooldown_show_swipe",
                    label = "Show Swipe Closure Texture",
                    desc = "Show a layer with a dark texture above the icon. This layer is applied or removed as the swipe moves.",
                    widget = "toggle",
                    default = Plater.db.profile.aura_cooldown_show_swipe,
                    setter = function(auras, value)
                        Plater.IncreaseRefreshID()
                        updateAllPlatesOnly()
                    end,
                },
                {
                    key = "aura_cooldown_reverse",
                    label = "Swipe Closure Inverted",
                    desc = "If enabled the swipe closure texture is applied as the swipe moves instead.",
                    widget = "toggle",
                    default = Plater.db.profile.aura_cooldown_reverse,
                    setter = function(auras, value)
                        Plater.IncreaseRefreshID()
                        updateAllPlatesOnly()
                    end,
                },
            }
        end)(),

        --automatic aura tracking toggles (which buffs/debuffs Plater picks up). lifted out of
        --the Auras Layout widget so the user can pick this group separately in the sidebar.
        AuraTracking = (function()
            local refreshAuraDB = function()
                Plater.RefreshDBUpvalues()
                Plater.UpdateAllPlates()
                designer.UpdateAllNameplates()
            end

            return {
                {
                    key = "aura_show_aura_by_the_player",
                    label = "Show Auras Casted by You",
                    desc = "Show Auras Casted by You and your pets.",
                    widget = "toggle",
                    default = Plater.db.profile.aura_show_aura_by_the_player,
                    setter = function(auras, value) refreshAuraDB() end,
                },
                {
                    key = "aura_show_debuff_as_blizzard_does",
                    label = "Show Debuffs Blizzard Nameplates show",
                    desc = "Show Debuffs as they would be shown on blizzard nameplates.",
                    widget = "toggle",
                    default = Plater.db.profile.aura_show_debuff_as_blizzard_does,
                    setter = function(auras, value) refreshAuraDB() end,
                },
                {
                    key = "aura_show_debuff_by_the_player",
                    label = "Show ALL Debuffs Casted by You",
                    desc = "Show ALL Debuffs Casted by You and your pets.",
                    widget = "toggle",
                    default = Plater.db.profile.aura_show_debuff_by_the_player,
                    setter = function(auras, value) refreshAuraDB() end,
                },
                {
                    key = "aura_show_buff_by_the_player",
                    label = "Show Buffs Casted by You",
                    desc = "Show Buffs Casted by You and your pets.",
                    widget = "toggle",
                    default = Plater.db.profile.aura_show_buff_by_the_player,
                    setter = function(auras, value) refreshAuraDB() end,
                },
                {
                    key = "aura_show_aura_by_other_players",
                    label = "Show Auras Casted by other Players",
                    desc = "Show Auras Casted by other Players. May cause a lot of auras to show.",
                    widget = "toggle",
                    default = Plater.db.profile.aura_show_aura_by_other_players,
                    setter = function(auras, value) refreshAuraDB() end,
                },
                {
                    key = "aura_show_important",
                    label = "Show Important Auras",
                    desc = "Show buffs and debuffs which the game tag as important.",
                    widget = "toggle",
                    default = Plater.db.profile.aura_show_important,
                    setter = function(auras, value) refreshAuraDB() end,
                },
                {
                    key = "aura_show_dispellable",
                    label = "Show Dispellable Buffs",
                    desc = "Show auras which can be dispelled or stolen.",
                    widget = "toggle",
                    default = Plater.db.profile.aura_show_dispellable,
                    setter = function(auras, value) refreshAuraDB() end,
                },
                {
                    key = "aura_show_raid",
                    label = "Show Raid Buffs/Debuffs",
                    desc = "Show auras which are flagged as 'RAID'.",
                    widget = "toggle",
                    default = Plater.db.profile.aura_show_raid,
                    setter = function(auras, value) refreshAuraDB() end,
                },
                {
                    key = "aura_show_only_short_dispellable_on_players",
                    label = "Only short Dispellable Buffs on Players",
                    desc = "Show dispellable or stealable auras on players only if they are below 120 sec.",
                    widget = "toggle",
                    default = Plater.db.profile.aura_show_only_short_dispellable_on_players,
                    setter = function(auras, value) refreshAuraDB() end,
                },
                {
                    key = "aura_show_enrage",
                    label = "Show Enrage Buffs",
                    desc = "Show auras which are in the enrage category.",
                    widget = "toggle",
                    default = Plater.db.profile.aura_show_enrage,
                    setter = function(auras, value) refreshAuraDB() end,
                },
                {
                    key = "aura_show_magic",
                    label = "Show Magic Buffs",
                    desc = "Show auras which are in the magic type category.",
                    widget = "toggle",
                    default = Plater.db.profile.aura_show_magic,
                    setter = function(auras, value) refreshAuraDB() end,
                },
                {
                    key = "aura_show_crowdcontrol",
                    label = "Show Crowd Control",
                    desc = "Show crowd control effects.",
                    widget = "toggle",
                    default = Plater.db.profile.aura_show_crowdcontrol,
                    setter = function(auras, value) refreshAuraDB() end,
                },
                {
                    key = "aura_show_buff_by_the_unit",
                    label = "Show Buffs Casted by the NPC",
                    desc = "Show Buffs Casted by the NPC itself.",
                    widget = "toggle",
                    default = Plater.db.profile.aura_show_buff_by_the_unit,
                    setter = function(auras, value) refreshAuraDB() end,
                },
                {
                    key = "aura_show_buff_as_blizzard_does",
                    label = "Show Buffs Blizzard Nameplates show",
                    desc = "Show Buffs as they would be shown on blizzard nameplates.",
                    widget = "toggle",
                    default = Plater.db.profile.aura_show_buff_as_blizzard_does,
                    setter = function(auras, value) refreshAuraDB() end,
                },
                {
                    key = "aura_show_buff_on_enemy_npc",
                    label = "Show all Buffs on enemy NPCs",
                    desc = "Show all Buffs on enemy NPCs.",
                    widget = "toggle",
                    default = Plater.db.profile.aura_show_buff_on_enemy_npc,
                    setter = function(auras, value) refreshAuraDB() end,
                },
                {
                    key = "aura_show_debuff_by_the_unit",
                    label = "Show Debuffs Casted by the NPC",
                    desc = "Show Debuffs Casted by the NPC itself.",
                    widget = "toggle",
                    default = Plater.db.profile.aura_show_debuff_by_the_unit,
                    setter = function(auras, value) refreshAuraDB() end,
                },
                {
                    key = "aura_show_aura_by_other_npcs",
                    label = "Show Auras Casted by other NPCs",
                    desc = "Show Auras Casted not from players and not from the unit itself.",
                    widget = "toggle",
                    default = Plater.db.profile.aura_show_aura_by_other_npcs,
                    setter = function(auras, value) refreshAuraDB() end,
                },
                {
                    key = "aura_show_offensive_cd",
                    label = "Show offensive player CDs",
                    desc = "Show offensive CDs on enemy/friendly players.",
                    widget = "toggle",
                    default = Plater.db.profile.aura_show_offensive_cd,
                    setter = function(auras, value) refreshAuraDB() end,
                },
                {
                    key = "aura_show_defensive_cd",
                    label = "Show defensive player CDs",
                    desc = "Show defensive CDs on enemy/friendly players.",
                    widget = "toggle",
                    default = Plater.db.profile.aura_show_defensive_cd,
                    setter = function(auras, value) refreshAuraDB() end,
                },
                {
                    key = "debuff_hide_permanent",
                    label = "Hide permanent auras",
                    desc = "Hide auras with no duration.",
                    widget = "toggle",
                    default = Plater.db.profile.debuff_hide_permanent,
                    setter = function(auras, value) refreshAuraDB() end,
                },
            }
        end)(),

        --aura border colors. lifted out of the Auras Layout widget so the user can pick this
        --group separately in the sidebar.
        AuraBorderColors = (function()
            local updateAllPlatesOnly = function()
                Plater.UpdateAllPlates()
                designer.UpdateAllNameplates()
            end
            local refreshAuraDBAndIcons = function()
                Plater.RefreshDBUpvalues()
                Plater.RefreshAuras()
                Plater.UpdateAllPlates()
                designer.UpdateAllNameplates()
            end

            return {
                {
                    key = "aura_border_colors.is_show_all",
                    label = "Important Auras Border Color",
                    desc = "Border color for important auras.",
                    widget = "color",
                    default = Plater.db.profile.aura_border_colors.is_show_all,
                    setter = function(auras, value) updateAllPlatesOnly() end,
                },
                {
                    key = "aura_border_colors.steal_or_purge",
                    label = "Dispellable Buffs Border Color",
                    desc = "Border color for dispellable or stealable buffs.",
                    widget = "color",
                    default = Plater.db.profile.aura_border_colors.steal_or_purge,
                    setter = function(auras, value) updateAllPlatesOnly() end,
                },
                {
                    key = "aura_border_colors.enrage",
                    label = "Enrage Buffs Border Color",
                    desc = "Border color for enrage buffs.",
                    widget = "color",
                    default = Plater.db.profile.aura_border_colors.enrage,
                    setter = function(auras, value) updateAllPlatesOnly() end,
                },
                {
                    key = "aura_border_colors.is_buff",
                    label = "Buffs Border Color",
                    desc = "Border color for buffs.",
                    widget = "color",
                    default = Plater.db.profile.aura_border_colors.is_buff,
                    setter = function(auras, value) updateAllPlatesOnly() end,
                },
                {
                    key = "aura_border_colors.is_debuff",
                    label = "Debuffs Border Color",
                    desc = "Border color for debuffs.",
                    widget = "color",
                    default = Plater.db.profile.aura_border_colors.is_debuff,
                    setter = function(auras, value) updateAllPlatesOnly() end,
                },
                {
                    key = "aura_border_colors.crowdcontrol",
                    label = "Crowd Control Border Color",
                    desc = "Border color for crowd control effects.",
                    widget = "color",
                    default = Plater.db.profile.aura_border_colors.crowdcontrol,
                    setter = function(auras, value) updateAllPlatesOnly() end,
                },
                {
                    key = "aura_border_colors.offensive",
                    label = "Offensive CD Border Color",
                    desc = "Border color for offensive cooldowns.",
                    widget = "color",
                    default = Plater.db.profile.aura_border_colors.offensive,
                    setter = function(auras, value) updateAllPlatesOnly() end,
                },
                {
                    key = "aura_border_colors.defensive",
                    label = "Defensive CD Border Color",
                    desc = "Border color for defensive cooldowns.",
                    widget = "color",
                    default = Plater.db.profile.aura_border_colors.defensive,
                    setter = function(auras, value) updateAllPlatesOnly() end,
                },
                {
                    key = "aura_border_colors.default",
                    label = "Default Border Color",
                    desc = "Default border color when no specific category matches.",
                    widget = "color",
                    default = Plater.db.profile.aura_border_colors.default,
                    setter = function(auras, value) updateAllPlatesOnly() end,
                },
                {
                    key = "aura_border_colors_by_type",
                    label = "Use type based aura border colors",
                    desc = "Use the Blizzard debuff type colors for borders.",
                    widget = "toggle",
                    default = Plater.db.profile.aura_border_colors_by_type,
                    setter = function(auras, value) refreshAuraDBAndIcons() end,
                },
            }
        end)(),

        --stack counter (number over the aura icon). lifted out of the Auras Layout widget so
        --the user can pick this group separately in the sidebar.
        StackCounter = (function()
            local updateAllPlatesOnly = function()
                Plater.UpdateAllPlates()
                designer.UpdateAllNameplates()
            end
            local anchorSideOptions = function()
                return {
                    {value = 1, label = "Top Left"},
                    {value = 2, label = "Left"},
                    {value = 3, label = "Bottom Left"},
                    {value = 4, label = "Bottom"},
                    {value = 5, label = "Bottom Right"},
                    {value = 6, label = "Right"},
                    {value = 7, label = "Top Right"},
                    {value = 8, label = "Top"},
                    {value = 9, label = "Center"},
                }
            end
            local outlineOptions = function()
                return {
                    {value = "NONE", label = "None"},
                    {value = "MONOCHROME", label = "Monochrome"},
                    {value = "OUTLINE", label = "Outline"},
                    {value = "THICKOUTLINE", label = "Thick Outline"},
                    {value = "MONOCHROME, OUTLINE", label = "Monochrome + Outline"},
                    {value = "MONOCHROME, THICKOUTLINE", label = "Monochrome + Thick Outline"},
                }
            end
            local fontOptions = function()
                local opts = {}
                for fontName in pairs(LSM:HashTable("font")) do
                    opts[#opts + 1] = {value = fontName, label = fontName}
                end
                return opts
            end

            return {
                {
                    key = "aura_stack_font",
                    label = "Font",
                    desc = "Font used for the stack count text.",
                    widget = "dropdown",
                    default = Plater.db.profile.aura_stack_font,
                    dropdownFunc = fontOptions,
                    setter = function(auras, value) updateAllPlatesOnly() end,
                },
                {
                    key = "aura_stack_size",
                    label = "Size",
                    desc = "Stack count text size.",
                    widget = "slider",
                    minvalue = 6, maxvalue = 24, step = 1,
                    default = Plater.db.profile.aura_stack_size,
                    setter = function(auras, value) updateAllPlatesOnly() end,
                },
                {
                    key = "aura_stack_outline",
                    label = "Outline",
                    desc = "Outline style for the stack count text.",
                    widget = "dropdown",
                    default = Plater.db.profile.aura_stack_outline,
                    dropdownFunc = outlineOptions,
                    setter = function(auras, value) updateAllPlatesOnly() end,
                },
                {
                    key = "aura_stack_shadow_color",
                    label = "Shadow Color",
                    desc = "Drop shadow color behind the stack count.",
                    widget = "color",
                    default = Plater.db.profile.aura_stack_shadow_color,
                    setter = function(auras, value) updateAllPlatesOnly() end,
                },
                {
                    key = "aura_stack_color",
                    label = "Color",
                    desc = "Stack count text color.",
                    widget = "color",
                    default = Plater.db.profile.aura_stack_color,
                    setter = function(auras, value) updateAllPlatesOnly() end,
                },
                {
                    key = "aura_stack_anchor.side",
                    label = "Anchor",
                    desc = "Which side of the buff icon the stack counter attaches to.",
                    widget = "dropdown",
                    default = Plater.db.profile.aura_stack_anchor.side,
                    dropdownFunc = anchorSideOptions,
                    setter = function(auras, value) updateAllPlatesOnly() end,
                },
                {
                    key = "aura_stack_anchor.x",
                    label = "X Offset",
                    desc = "Horizontal offset of the stack counter.",
                    widget = "slider",
                    minvalue = -20, maxvalue = 20, step = 1, usedecimals = true,
                    default = Plater.db.profile.aura_stack_anchor.x,
                    setter = function(auras, value) updateAllPlatesOnly() end,
                },
                {
                    key = "aura_stack_anchor.y",
                    label = "Y Offset",
                    desc = "Vertical offset of the stack counter.",
                    widget = "slider",
                    minvalue = -20, maxvalue = 20, step = 1, usedecimals = true,
                    default = Plater.db.profile.aura_stack_anchor.y,
                    setter = function(auras, value) updateAllPlatesOnly() end,
                },
            }
        end)(),

        --aura timer (time left over the aura icon). lifted out of the Auras Layout widget so
        --the user can pick this group separately in the sidebar.
        AuraTimer = (function()
            local updateAllPlatesOnly = function()
                Plater.UpdateAllPlates()
                designer.UpdateAllNameplates()
            end
            local refreshAndUpdateAuras = function()
                Plater.RefreshAuras()
                Plater.UpdateAllPlates()
                designer.UpdateAllNameplates()
            end
            local anchorSideOptions = function()
                return {
                    {value = 1, label = "Top Left"},
                    {value = 2, label = "Left"},
                    {value = 3, label = "Bottom Left"},
                    {value = 4, label = "Bottom"},
                    {value = 5, label = "Bottom Right"},
                    {value = 6, label = "Right"},
                    {value = 7, label = "Top Right"},
                    {value = 8, label = "Top"},
                    {value = 9, label = "Center"},
                }
            end
            local outlineOptions = function()
                return {
                    {value = "NONE", label = "None"},
                    {value = "MONOCHROME", label = "Monochrome"},
                    {value = "OUTLINE", label = "Outline"},
                    {value = "THICKOUTLINE", label = "Thick Outline"},
                    {value = "MONOCHROME, OUTLINE", label = "Monochrome + Outline"},
                    {value = "MONOCHROME, THICKOUTLINE", label = "Monochrome + Thick Outline"},
                }
            end
            local fontOptions = function()
                local opts = {}
                for fontName in pairs(LSM:HashTable("font")) do
                    opts[#opts + 1] = {value = fontName, label = fontName}
                end
                return opts
            end

            return {
                {
                    key = "aura_timer",
                    label = "Enabled",
                    desc = "Time left on buff or debuff.",
                    widget = "toggle",
                    default = Plater.db.profile.aura_timer,
                    setter = function(auras, value) refreshAndUpdateAuras() end,
                },
                {
                    key = "aura_timer_pandemic_color",
                    label = "Pandemic coloring",
                    desc = "Color the timer based on duration left. Above 25%: default, below 25%: orange, below 15%: red.",
                    widget = "toggle",
                    default = Plater.db.profile.aura_timer_pandemic_color,
                    setter = function(auras, value) refreshAndUpdateAuras() end,
                },
                {
                    key = "aura_timer_decimals",
                    label = "Show Decimals",
                    desc = "Show decimals below 10 seconds remaining.",
                    widget = "toggle",
                    default = Plater.db.profile.aura_timer_decimals,
                    setter = function(auras, value) refreshAndUpdateAuras() end,
                },
                {
                    key = "disable_omnicc_on_auras",
                    label = "Hide OmniCC/TullaCC Timer",
                    desc = "OmniCC/TullaCC timers will not show in the aura. Requires /reload after toggling.",
                    widget = "toggle",
                    default = Plater.db.profile.disable_omnicc_on_auras,
                    setter = function(auras, value) Plater.RefreshOmniCCGroup() end,
                },
                {
                    key = "aura_timer_text_font",
                    label = "Font",
                    desc = "Font used for the timer text.",
                    widget = "dropdown",
                    default = Plater.db.profile.aura_timer_text_font,
                    dropdownFunc = fontOptions,
                    setter = function(auras, value) updateAllPlatesOnly() end,
                },
                {
                    key = "aura_timer_text_size",
                    label = "Size",
                    desc = "Timer text size.",
                    widget = "slider",
                    minvalue = 7, maxvalue = 40, step = 1,
                    default = Plater.db.profile.aura_timer_text_size,
                    setter = function(auras, value) refreshAndUpdateAuras() end,
                },
                {
                    key = "aura_timer_text_outline",
                    label = "Outline",
                    desc = "Outline style for the timer text.",
                    widget = "dropdown",
                    default = Plater.db.profile.aura_timer_text_outline,
                    dropdownFunc = outlineOptions,
                    setter = function(auras, value) updateAllPlatesOnly() end,
                },
                {
                    key = "aura_timer_text_shadow_color",
                    label = "Shadow Color",
                    desc = "Drop shadow color behind the timer text.",
                    widget = "color",
                    default = Plater.db.profile.aura_timer_text_shadow_color,
                    setter = function(auras, value) updateAllPlatesOnly() end,
                },
                {
                    key = "aura_timer_text_color",
                    label = "Color",
                    desc = "Timer text color.",
                    widget = "color",
                    default = Plater.db.profile.aura_timer_text_color,
                    setter = function(auras, value) updateAllPlatesOnly() end,
                },
                {
                    key = "aura_timer_text_anchor.side",
                    label = "Anchor",
                    desc = "Which side of the buff icon the timer attaches to.",
                    widget = "dropdown",
                    default = Plater.db.profile.aura_timer_text_anchor.side,
                    dropdownFunc = anchorSideOptions,
                    setter = function(auras, value) updateAllPlatesOnly() end,
                },
                {
                    key = "aura_timer_text_anchor.x",
                    label = "X Offset",
                    desc = "Horizontal offset of the timer text.",
                    widget = "slider",
                    minvalue = -20, maxvalue = 20, step = 1, usedecimals = true,
                    default = Plater.db.profile.aura_timer_text_anchor.x,
                    setter = function(auras, value) updateAllPlatesOnly() end,
                },
                {
                    key = "aura_timer_text_anchor.y",
                    label = "Y Offset",
                    desc = "Vertical offset of the timer text.",
                    widget = "slider",
                    minvalue = -20, maxvalue = 20, step = 1, usedecimals = true,
                    default = Plater.db.profile.aura_timer_text_anchor.y,
                    setter = function(auras, value) updateAllPlatesOnly() end,
                },
            }
        end)(),

        --indicator icons (pet, execute range, world boss, class/spec/faction, etc.). copied
        --from the options panel "General Settings" indicators section (Plater_OptionsPanel.lua).
        --settings are global, so they read and write at profile root.
        Indicators = (function()
            local updatePlates = function()
                Plater.UpdateAllPlates()
                designer.UpdateAllNameplates()
            end
            --execute range toggles also need the cutoff value recomputed.
            local updateExecuteRange = function()
                Plater.GetHealthCutoffValue()
                Plater.UpdateAllPlates()
                designer.UpdateAllNameplates()
            end
            local anchorSideOptions = function()
                return {
                    {value = 1, label = "Top Left"},
                    {value = 2, label = "Left"},
                    {value = 3, label = "Bottom Left"},
                    {value = 4, label = "Bottom"},
                    {value = 5, label = "Bottom Right"},
                    {value = 6, label = "Right"},
                    {value = 7, label = "Top Right"},
                    {value = 8, label = "Top"},
                    {value = 9, label = "Center"},
                    {value = 10, label = "Inner Left"},
                    {value = 11, label = "Inner Right"},
                    {value = 12, label = "Inner Top"},
                    {value = 13, label = "Inner Bottom"},
                }
            end

            --hover preview helpers. onEnter shows the hovered indicator's icon on the preview,
            --onLeave reverts to the default (elite). the string is the indicator type that
            --Plater.AddIndicator uses. only icon-type indicators get a hover (shield/execute
            --range are not icons, so they are left without a hover preview).
            local showIndicatorOnEnter = function(indicatorType)
                return function() designer.SetIndicatorPreview(indicatorType) end
            end
            local revertIndicatorOnLeave = function()
                designer.SetIndicatorPreview("elite")
            end

            --re-anchor and re-scale the preview indicator so the anchor/scale sliders move it
            --live, then push the change to the nameplates.
            local reanchorIndicator = function()
                local previewPlate = designer.plateFrame
                if (previewPlate and previewPlate.unitFrame) then
                    local selector = previewPlate.unitFrame.healthBar.dummyIndicators
                    if (selector) then
                        Plater.SetAnchor(selector, Plater.db.profile.indicator_anchor)
                        selector:SetScale(Plater.db.profile.indicator_scale)
                    end
                end
                updatePlates()
            end

            return {
                {
                    key = "indicator_pet",
                    label = "Pet Icon",
                    desc = "Pet Icon",
                    onenter = showIndicatorOnEnter("pet"),
                    onleave = revertIndicatorOnLeave,
                    widget = "toggle",
                    default = Plater.db.profile.indicator_pet,
                    setter = function(indicators, value) updatePlates() end,
                },
                {
                    key = "indicator_shield",
                    label = "Shield Bar",
                    desc = "Shield Bar",
                    widget = "toggle",
                    default = Plater.db.profile.indicator_shield,
                    setter = function(indicators, value) updatePlates() end,
                },
                {
                    key = "health_cutoff",
                    label = "Execute Range",
                    desc = "Show an indicator when the target unit is in 'execute' range.",
                    widget = "toggle",
                    default = Plater.db.profile.health_cutoff,
                    setter = function(indicators, value) updateExecuteRange() end,
                },
                {
                    key = "health_cutoff_upper",
                    label = "Execute Range (high heal)",
                    desc = "Show the execute indicator for the high portion of the health.",
                    widget = "toggle",
                    default = Plater.db.profile.health_cutoff_upper,
                    setter = function(indicators, value) updateExecuteRange() end,
                },
                {
                    key = "health_cutoff_extra_glow",
                    label = "Add Extra Glow to Execute Range",
                    desc = "Add Extra Glow to Execute Range",
                    widget = "toggle",
                    default = Plater.db.profile.health_cutoff_extra_glow,
                    setter = function(indicators, value) updatePlates() end,
                },
                {
                    key = "indicator_worldboss",
                    label = "World Boss Icon",
                    desc = "World Boss Icon",
                    onenter = showIndicatorOnEnter("worldboss"),
                    onleave = revertIndicatorOnLeave,
                    widget = "toggle",
                    default = Plater.db.profile.indicator_worldboss,
                    setter = function(indicators, value) updatePlates() end,
                },
                {
                    key = "indicator_elite",
                    label = "Elite Icon",
                    desc = "Elite Icon",
                    onenter = showIndicatorOnEnter("elite"),
                    onleave = revertIndicatorOnLeave,
                    widget = "toggle",
                    default = Plater.db.profile.indicator_elite,
                    setter = function(indicators, value) updatePlates() end,
                },
                {
                    key = "indicator_rare",
                    label = "Rare Icon",
                    desc = "Rare Icon",
                    onenter = showIndicatorOnEnter("rare"),
                    onleave = revertIndicatorOnLeave,
                    widget = "toggle",
                    default = Plater.db.profile.indicator_rare,
                    setter = function(indicators, value) updatePlates() end,
                },
                {
                    key = "indicator_quest",
                    label = "Quest Icon",
                    desc = "Quest Icon",
                    onenter = showIndicatorOnEnter("quest"),
                    onleave = revertIndicatorOnLeave,
                    widget = "toggle",
                    default = Plater.db.profile.indicator_quest,
                    setter = function(indicators, value) updatePlates() end,
                },
                {
                    key = "indicator_faction",
                    label = "Enemy Faction Icon",
                    desc = "Enemy Faction Icon",
                    onenter = showIndicatorOnEnter("Horde"),
                    onleave = revertIndicatorOnLeave,
                    widget = "toggle",
                    default = Plater.db.profile.indicator_faction,
                    setter = function(indicators, value) updatePlates() end,
                },
                {
                    key = "indicator_enemyclass",
                    label = "Enemy Class Icon",
                    desc = "Enemy Class Icon",
                    onenter = showIndicatorOnEnter("classicon"),
                    onleave = revertIndicatorOnLeave,
                    widget = "toggle",
                    default = Plater.db.profile.indicator_enemyclass,
                    setter = function(indicators, value) updatePlates() end,
                },
                {
                    key = "indicator_spec",
                    label = "Enemy Spec Icon",
                    desc = "Enemy Spec Icon",
                    onenter = showIndicatorOnEnter("specicon"),
                    onleave = revertIndicatorOnLeave,
                    widget = "toggle",
                    default = Plater.db.profile.indicator_spec,
                    setter = function(indicators, value) updatePlates() end,
                },
                {
                    key = "indicator_friendlyfaction",
                    label = "Friendly Faction Icon",
                    desc = "Friendly Faction Icon",
                    onenter = showIndicatorOnEnter("Alliance"),
                    onleave = revertIndicatorOnLeave,
                    widget = "toggle",
                    default = Plater.db.profile.indicator_friendlyfaction,
                    setter = function(indicators, value) updatePlates() end,
                },
                {
                    key = "indicator_friendlyclass",
                    label = "Friendly Class",
                    desc = "Friendly Class",
                    onenter = showIndicatorOnEnter("classicon"),
                    onleave = revertIndicatorOnLeave,
                    widget = "toggle",
                    default = Plater.db.profile.indicator_friendlyclass,
                    setter = function(indicators, value) updatePlates() end,
                },
                {
                    key = "indicator_friendlyspec",
                    label = "Friendly Spec Icon",
                    desc = "Friendly Spec Icon",
                    onenter = showIndicatorOnEnter("specicon"),
                    onleave = revertIndicatorOnLeave,
                    widget = "toggle",
                    default = Plater.db.profile.indicator_friendlyspec,
                    setter = function(indicators, value) updatePlates() end,
                },

                {type = "blank"},

                {
                    key = "indicator_scale",
                    label = "Scale",
                    desc = "Scale",
                    widget = "slider",
                    minvalue = 0.2, maxvalue = 3, step = 0.01, usedecimals = true,
                    default = Plater.db.profile.indicator_scale,
                    setter = function(indicators, value) reanchorIndicator() end,
                },
                {
                    key = "indicator_anchor.side",
                    label = "Anchor",
                    desc = "Which side this widget is attach to.",
                    widget = "dropdown",
                    default = Plater.db.profile.indicator_anchor.side,
                    dropdownFunc = anchorSideOptions,
                    setter = function(indicators, value) reanchorIndicator() end,
                },
                {
                    key = "indicator_anchor.x",
                    label = "X Offset",
                    desc = "Move horizontally.",
                    widget = "slider",
                    minvalue = -100, maxvalue = 100, step = 1, usedecimals = true,
                    default = Plater.db.profile.indicator_anchor.x,
                    setter = function(indicators, value) reanchorIndicator() end,
                },
                {
                    key = "indicator_anchor.y",
                    label = "Y Offset",
                    desc = "Move vertically.",
                    widget = "slider",
                    minvalue = -100, maxvalue = 100, step = 1, usedecimals = true,
                    default = Plater.db.profile.indicator_anchor.y,
                    setter = function(indicators, value) reanchorIndicator() end,
                },

                {type = "blank"},

                {
                    key = "health_cutoff_alpha",
                    label = "Execute Alpha",
                    desc = "Execute Alpha",
                    widget = "slider",
                    minvalue = 0, maxvalue = 1, step = 0.01, usedecimals = true,
                    default = Plater.db.profile.health_cutoff_alpha,
                    setter = function(indicators, value)
                        Plater.RefreshDBUpvalues()
                        Plater.GetHealthCutoffValue()
                        designer.UpdateAllNameplates()
                    end,
                },
            }
        end)(),

        Target = {
            --target overlay (acts on the same texture HealthBar's "Target Overlay" exposes; included here per parity with the Plater options panel)
            {
                key = "health_selection_overlay",
                label = "Target Overlay",
                widget = "selectstatusbartexture",
                default = Plater.db.profile.health_selection_overlay,
                setter = function(target, value) designer.UpdateAllNameplates() end,
            },
            {
                key = "health_selection_overlay_alpha",
                label = "Target Overlay Alpha",
                widget = "slider",
                minvalue = 0, maxvalue = 1, step = 0.1, usedecimals = true,
                default = Plater.db.profile.health_selection_overlay_alpha,
                setter = function(target, value) designer.UpdateAllNameplates() end,
            },
            {
                key = "health_selection_overlay_color",
                label = "Target Overlay Color",
                widget = "color",
                default = Plater.db.profile.health_selection_overlay_color,
                setter = function(target, value) designer.UpdateAllNameplates() end,
            },

            {type = "blank"},

            --target highlight (rectangle that appears around the current target)
            {
                key = "target_highlight",
                label = "Target Highlight",
                widget = "toggle",
                default = Plater.db.profile.target_highlight,
                setter = function(target, value) designer.UpdateAllNameplates() end,
            },
            {
                key = "target_highlight_texture",
                label = "Highlight Texture",
                widget = "dropdown",
                default = Plater.db.profile.target_highlight_texture,
                dropdownFunc = function()
                    local opts = {}
                    for index, texturePath in ipairs(Plater.TargetHighlights) do
                        opts[#opts + 1] = {value = texturePath, label = "Highlight " .. index, centerTexture = texturePath}
                    end
                    return opts
                end,
                setter = function(target, value)
                    if target.NeonUp then target.NeonUp:SetTexture(value) end
                    if target.NeonDown then target.NeonDown:SetTexture(value) end
                    designer.UpdateAllNameplates()
                end,
            },
            {
                key = "target_highlight_alpha",
                label = "Highlight Alpha",
                widget = "slider",
                minvalue = 0, maxvalue = 1, step = 0.1, usedecimals = true,
                default = Plater.db.profile.target_highlight_alpha,
                setter = function(target, value)
                    if target.NeonUp then target.NeonUp:SetAlpha(value) end
                    if target.NeonDown then target.NeonDown:SetAlpha(value) end
                    designer.UpdateAllNameplates()
                end,
            },
            {
                key = "target_highlight_height",
                label = "Highlight Size",
                widget = "slider",
                minvalue = 2, maxvalue = 60, step = 1,
                default = Plater.db.profile.target_highlight_height,
                setter = function(target, value)
                    if target.NeonUp then target.NeonUp:SetHeight(value) end
                    if target.NeonDown then target.NeonDown:SetHeight(value) end
                    designer.UpdateAllNameplates()
                end,
            },
            {
                key = "target_highlight_color",
                label = "Highlight Color",
                widget = "color",
                default = Plater.db.profile.target_highlight_color,
                setter = function(target, color)
                    local r, g, b, a = unpack(color)
                    if target.NeonUp then target.NeonUp:SetVertexColor(r, g, b, a) end
                    if target.NeonDown then target.NeonDown:SetVertexColor(r, g, b, a) end
                    designer.UpdateAllNameplates()
                end,
            },

            {type = "blank"},

            --bracket indicator on the sides of the target's health bar
            {
                key = "target_indicator",
                label = "Target Bracket Indicator",
                widget = "dropdown",
                default = Plater.db.profile.target_indicator,
                dropdownFunc = function()
                    local opts = {}
                    --each preset carries a texture path plus a coords table (one set per corner).
                    --pass the first corner as the option icon so the dropdown shows a preview.
                    for name, indicatorTable in pairs(Plater.TargetIndicators) do
                        opts[#opts + 1] = {
                            value = name,
                            label = name,
                            icon = indicatorTable.path,
                            texcoord = indicatorTable.coords[1],
                        }
                    end
                    return opts
                end,
                setter = function(target, value)
                    --redraw the brackets on the preview plate so the pick shows right away
                    Plater.UpdateTargetIndicator(designer.plateFrame)
                    designer.UpdateAllNameplates()
                end,
            },

            {type = "blank"},

            --target shading (dims non-target plates)
            {
                key = "target_shady_enabled",
                label = "Target Shading",
                widget = "toggle",
                default = Plater.db.profile.target_shady_enabled,
                setter = function(target, value) designer.UpdateAllNameplates() end,
            },
            {
                key = "target_shady_combat_only",
                label = "Target Shading In Combat Only",
                widget = "toggle",
                default = Plater.db.profile.target_shady_combat_only,
                setter = function(target, value) designer.UpdateAllNameplates() end,
            },
            {
                key = "target_shady_alpha",
                label = "Target Shading Amount",
                widget = "slider",
                minvalue = 0, maxvalue = 1, step = 0.1, usedecimals = true,
                default = Plater.db.profile.target_shady_alpha,
                setter = function(target, value) designer.UpdateAllNameplates() end,
            },

            {type = "blank"},
            {type = "label", get = function() return "Mouse Hover:" end, text_template = detailsFramework:GetTemplate("font", "ORANGE_FONT_TEMPLATE")},

            --the preview's hover highlight texture lives on healthBar (target.HoverHighlight where
            --target is the dummyTarget bar). its visibility is driven by the moveUpFrame OnUpdate
            --in Plater_Designer.lua; this setter only updates the alpha so a slider drag is live.
            {
                key = "hover_highlight",
                label = "Hover Highlight",
                widget = "toggle",
                default = Plater.db.profile.hover_highlight,
                setter = function(target, value) designer.UpdateAllNameplates() end,
            },
            {
                key = "hover_highlight_alpha",
                label = "Hover Highlight Alpha",
                widget = "slider",
                minvalue = 0, maxvalue = 1, step = 0.1, usedecimals = true,
                default = Plater.db.profile.hover_highlight_alpha,
                setter = function(target, value)
                    target.HoverHighlight:SetAlpha(value)
                    designer.UpdateAllNameplates()
                end,
            },

            {type = "blank"},
            {type = "label", get = function() return "CVars:" end, text_template = detailsFramework:GetTemplate("font", "ORANGE_FONT_TEMPLATE")},

            --CVar-backed extras. profileTable points at the in-memory cvarMirror declared at the
            --top of CreateSettings since the editor needs a non-nil profile-style value to render.
            --setters call SetCVar and mirror the value back. nocombat behavior is handled inline.
            {
                key = "nameplateTargetRadialPosition",
                label = "Always on Screen",
                widget = "toggle",
                profileTable = cvarMirror,
                default = cvarMirror.nameplateTargetRadialPosition,
                setter = function(target, value)
                    if (InCombatLockdown()) then
                        Plater:Msg(L["OPTIONS_ERROR_CVARMODIFY"])
                        return
                    end
                    SetCVar("clampTargetNameplateToScreen", value and "1" or "0")
                    SetCVar("nameplateTargetRadialPosition", value and "1" or "0")
                end,
            },
            {
                key = "nameplateTargetBehindMaxDistance",
                label = "Target Behind You Distance",
                widget = "slider",
                minvalue = 5, maxvalue = 50, step = 1,
                profileTable = cvarMirror,
                default = cvarMirror.nameplateTargetBehindMaxDistance,
                setter = function(target, value)
                    if (InCombatLockdown()) then
                        Plater:Msg(L["OPTIONS_ERROR_CVARMODIFY"])
                        return
                    end
                    SetCVar("nameplateTargetBehindMaxDistance", value)
                end,
            },
            {
                key = "nameplateSelectedScale",
                label = "Target Scale",
                widget = "slider",
                minvalue = 0.75, maxvalue = 1.75, step = 0.1, usedecimals = true,
                profileTable = cvarMirror,
                default = cvarMirror.nameplateSelectedScale,
                setter = function(target, value)
                    if (InCombatLockdown()) then
                        Plater:Msg(L["OPTIONS_ERROR_CVARMODIFY"])
                        return
                    end
                    SetCVar("nameplateSelectedScale", value)
                end,
            },
        },

        Focus = {
            {
                key = "focus_indicator_enabled",
                label = "Show Focus Overlay",
                widget = "toggle",
                default = Plater.db.profile.focus_indicator_enabled,
                setter = function(target, value)
                    --turning the toggle off while the focus is still on a unit leaves the
                    --texture shown until the next target sweep, so clear it explicitly.
                    if (not value) then
                        Plater.HideFocusIndicator()
                    end
                    designer.UpdateAllNameplates()
                end,
            },
            {
                key = "focus_color",
                label = "Focus Color",
                widget = "color",
                default = Plater.db.profile.focus_color,
                setter = function(target, value) designer.UpdateAllNameplates() end,
            },
            {
                key = "focus_texture",
                label = "Focus Texture",
                widget = "selectstatusbartexture",
                default = Plater.db.profile.focus_texture,
                setter = function(target, value) designer.UpdateAllNameplates() end,
            },
        },

        --anchor/offset extras are intentionally omitted - they're driven by the built-in
        --anchor/anchoroffsetx/anchoroffsety attributes from RaidMark's map.
        RaidMark = {
            {
                key = "indicator_raidmark_scale",
                label = "Scale",
                widget = "slider",
                minvalue = 0.2, maxvalue = 2, step = 0.1, usedecimals = true,
                default = Plater.db.profile.indicator_raidmark_scale,
                setter = function(raidMark, value)
                    raidMark:SetScale(value)
                    designer.UpdateAllNameplates()
                end,
            },
            {
                key = "indicator_extra_raidmark",
                label = "Extra Raid Mark",
                widget = "toggle",
                default = Plater.db.profile.indicator_extra_raidmark,
                setter = function(raidMark, value) designer.UpdateAllNameplates() end,
            },
        },

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