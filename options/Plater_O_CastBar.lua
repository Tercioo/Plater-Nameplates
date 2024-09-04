
local addonId, platerInternal = ...

local Plater = Plater
---@type detailsframework
local DF = DetailsFramework
local _

function platerInternal.CreateCastBarOptions()
    if platerInternal.LoadOnDemand_IsLoaded.CastOptions then return end

    local startX, startY, heightSize = 10, platerInternal.optionsYStart, 755
    local highlightColorLastCombat = {1, 1, .2, .25}

    --db upvalues
    local DB_CAPTURED_SPELLS
    local DB_CAPTURED_CASTS
    local DB_NPCID_CACHE
    local DB_NPCID_COLORS
    local DB_AURA_ALPHA
    local DB_AURA_ENABLED
    local DB_AURA_SEPARATE_BUFFS

    local GetSpellInfo = GetSpellInfo or function(spellID) if not spellID then return nil end local si = C_Spell.GetSpellInfo(spellID) if si then return si.name, nil, si.iconID, si.castTime, si.minRange, si.maxRange, si.spellID, si.originalIconID end end

    local on_refresh_db = function()
        local profile = Plater.db.profile
        DB_CAPTURED_SPELLS = PlaterDB.captured_spells
        DB_CAPTURED_CASTS = PlaterDB.captured_casts
        DB_NPCID_CACHE = profile.npc_cache
        DB_NPCID_COLORS = profile.npc_colors
        DB_AURA_ALPHA = profile.aura_alpha
        DB_AURA_ENABLED = profile.aura_enabled
        DB_AURA_SEPARATE_BUFFS = Plater.db.profile.buffs_on_aura2
    end

    Plater.RegisterRefreshDBCallback (on_refresh_db)

    --
    --templates
    local options_text_template = DF:GetTemplate ("font", "OPTIONS_FONT_TEMPLATE")
    local options_dropdown_template = DF:GetTemplate ("dropdown", "OPTIONS_DROPDOWN_TEMPLATE")
    local options_switch_template = DF:GetTemplate ("switch", "OPTIONS_CHECKBOX_TEMPLATE")
    local options_slider_template = DF:GetTemplate ("slider", "OPTIONS_SLIDER_TEMPLATE")
    local options_button_template = DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE")
    --

    local dropdownStatusBarTexture = platerInternal.Defaults.dropdownStatusBarTexture
    local dropdownStatusBarColor = platerInternal.Defaults.dropdownStatusBarColor

    --
    local LibSharedMedia = LibStub:GetLibrary("LibSharedMedia-3.0")
    local textures = LibSharedMedia:HashTable("statusbar")

    local cast_bar_texture_selected = function (self, capsule, value)
        Plater.db.profile.cast_statusbar_texture = value
        Plater.RefreshDBUpvalues()
        Plater.UpdateAllPlates()
    end
    local cast_bar_texture_options = {}
    for name, texturePath in pairs (textures) do
        cast_bar_texture_options [#cast_bar_texture_options + 1] = {value = name, label = name, statusbar = texturePath, onclick = cast_bar_texture_selected}
    end
    table.sort (cast_bar_texture_options, function (t1, t2) return t1.label < t2.label end)
    --
    local cast_bar_bgtexture_selected = function (self, capsule, value)
        Plater.db.profile.cast_statusbar_bgtexture = value
        Plater.RefreshDBUpvalues()
        Plater.UpdateAllPlates()
    end
    local cast_bar_bgtexture_options = {}
    for name, texturePath in pairs (textures) do
        cast_bar_bgtexture_options [#cast_bar_bgtexture_options + 1] = {value = name, label = name, statusbar = texturePath, onclick = cast_bar_bgtexture_selected}
    end
    table.sort (cast_bar_bgtexture_options, function (t1, t2) return t1.label < t2.label end)
    --
    local cast_spark_texture_selected = function (self, capsule, value)
        Plater.db.profile.cast_statusbar_spark_texture = value
        Plater.UpdateAllPlates()
    end
    local cast_spark_texture_selected_options = {}
    for index, texturePath in ipairs (Plater.SparkTextures) do
        cast_spark_texture_selected_options [#cast_spark_texture_selected_options + 1] = {
            value = texturePath,
            label = "Texture " .. index,
            onclick = cast_spark_texture_selected,
            centerTexture = texturePath,
            statusbar = dropdownStatusBarTexture,
            statusbarcolor = dropdownStatusBarColor,
        }
    end
    --
    local on_select_castbar_target_font = function (_, _, value)
        Plater.db.profile.castbar_target_font = value
        Plater.UpdateAllPlates()
    end
    --
        --anchor table
        local build_anchor_side_table = function (actorType, member)
            local anchorOptions = {}
            local phraseIdTable = Plater.AnchorNamesByPhraseId
            local languageId = DF.Language.GetLanguageIdForAddonId(addonId)

            for i = 1, 13 do
                tinsert (anchorOptions, {
                    label = DF.Language.GetText(addonId, phraseIdTable[i]),
                    languageId = languageId,
                    phraseId = phraseIdTable[i],
                    value = i,
                    statusbar = dropdownStatusBarTexture,
                    statusbarcolor = dropdownStatusBarColor,
                    onclick = function (_, _, value)
                        if (actorType) then
                            Plater.db.profile.plate_config [actorType][member].side = value
                            Plater.RefreshDBUpvalues()

                            Plater.UpdateAllPlates()
                            Plater.UpdateAllNames()
                        else
                            Plater.db.profile [member].side = value
                            Plater.RefreshDBUpvalues()
                            Plater.UpdateAllPlates()
                            Plater.UpdateAllNames()
                        end
                    end
                })
            end
            return anchorOptions
        end


        --outline table
        local outline_modes = {"NONE", "MONOCHROME", "OUTLINE", "THICKOUTLINE", "MONOCHROME, OUTLINE", "MONOCHROME, THICKOUTLINE"}
        local outline_modes_names = {"None", "Monochrome", "Outline", "Thick Outline", "Monochrome Outline", "Monochrome Thick Outline"}
        local build_outline_modes_table = function (actorType, member)
            local t = {}
            for i = 1, #outline_modes do
                local value = outline_modes[i]
                local label = outline_modes_names[i]

                tinsert (t, {
                    label = label,
                    value = value,
                    statusbar = dropdownStatusBarTexture,
                    statusbarcolor = dropdownStatusBarColor,
                    onclick = function (_, _, value)
                        if (actorType) then
                            Plater.db.profile.plate_config [actorType][member] = value
                            Plater.RefreshDBUpvalues()
                            Plater.UpdateAllPlates()
                            Plater.UpdateAllNames()
                        else
                            Plater.db.profile [member] = value
                            Plater.RefreshDBUpvalues()
                            Plater.UpdateAllPlates()
                            Plater.UpdateAllNames()
                        end
                    end
                })
            end
            return t
        end



    --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    --> castbar options

    local onSelectCastBarIconSideAttach = function(_a, _b, value)
        Plater.db.profile.castbar_icon_attach_to_side = value
        Plater.RefreshDBUpvalues()
        Plater.UpdateAllPlates()
    end
    local castbar_icon_attach_to_side_options = {
        {value = "left", label = "Left", onclick = onSelectCastBarIconSideAttach},
        {value = "right", label = "Right", onclick = onSelectCastBarIconSideAttach},
    }

    local onSelectCastBarSize = function(_, _, value)
        Plater.db.profile.castbar_icon_size = value
        Plater.RefreshDBUpvalues()
        Plater.UpdateAllPlates()
    end
    local castbar_icon_size_options = {
        {value = "same as castbar", label = "Castbar Size", onclick = onSelectCastBarSize},
        {value = "same as castbar plus healthbar", label = "Castbar + Healthbar Size", onclick = onSelectCastBarSize},
    }

    local castBar_options = {
        {type = "breakline"},

        --cast bar options
        {
            type = "execute",
            func = function()
                if (Plater.IsShowingCastBarTest) then
                    Plater.StopCastBarTest()
                else
                    Plater.StartCastBarTest()
                end
            end,
            name = "OPTIONS_CASTBAR_TOGGLE_TEST",
            desc = "OPTIONS_CASTBAR_TOGGLE_TEST_DESC",
        },

        {type = "blank"},

        {type = "label", get = function() return "OPTIONS_CASTBAR_APPEARANCE" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},

        {
            type = "select",
            get = function() return Plater.db.profile.cast_statusbar_texture end,
            values = function() return cast_bar_texture_options end,
            name = "OPTIONS_TEXTURE",
            desc = "OPTIONS_TEXTURE",
        },
        {
            type = "select",
            get = function() return Plater.db.profile.cast_statusbar_bgtexture end,
            values = function() return cast_bar_bgtexture_options end,
            name = "OPTIONS_TEXTURE_BACKGROUND",
            desc = "OPTIONS_TEXTURE_BACKGROUND",
        },

        {type = "blank"},

        {
            type = "toggle",
            get = function() return Plater.db.profile.no_spellname_length_limit end,
            set = function (self, fixedparam, value)
                Plater.db.profile.no_spellname_length_limit = value
                Plater.UpdateMaxCastbarTextLength()
                Plater.UpdateAllPlates()
            end,
            name = "OPTIONS_CASTBAR_NO_SPELLNAME_LIMIT",
            desc = "OPTIONS_CASTBAR_NO_SPELLNAME_LIMIT_DESC",
        },

        {
            type = "toggle",
            get = function() return Plater.db.profile.show_interrupt_author end,
            set = function (self, fixedparam, value)
                Plater.db.profile.show_interrupt_author = value
                Plater.RefreshDBUpvalues()
            end,
            name = "OPTIONS_INTERRUPT_SHOW_AUTHOR",
            desc = "OPTIONS_INTERRUPT_SHOW_AUTHOR",
        },

        {
            type = "toggle",
            get = function() return Plater.db.profile.cast_statusbar_interrupt_anim end,
            set = function (self, fixedparam, value)
                Plater.db.profile.cast_statusbar_interrupt_anim = value
            end,
            name = "OPTIONS_INTERRUPT_SHOW_ANIM",
            desc = "OPTIONS_INTERRUPT_SHOW_ANIM",
        },

        {
            type = "toggle",
            get = function() return Plater.db.profile.cast_statusbar_spark_filloninterrupt end,
            set = function (self, fixedparam, value)
                Plater.db.profile.cast_statusbar_spark_filloninterrupt = value
                Plater.UpdateAllPlates()
            end,
            name = "OPTIONS_INTERRUPT_FILLBAR",
            desc = "OPTIONS_INTERRUPT_FILLBAR",
        },

        {
            type = "toggle",
            get = function() return Plater.db.profile.cast_statusbar_quickhide end,
            set = function (self, fixedparam, value)
                Plater.db.profile.cast_statusbar_quickhide = value
            end,
            name = "OPTIONS_CASTBAR_QUICKHIDE",
            desc = "OPTIONS_CASTBAR_QUICKHIDE_DESC",
        },

        {
            type = "toggle",
            get = function() return Plater.db.profile.hide_friendly_castbars end,
            set = function (self, fixedparam, value)
                Plater.db.profile.hide_friendly_castbars = value
                Plater.RefreshDBUpvalues()
            end,
            name = "OPTIONS_CASTBAR_HIDE_FRIENDLY",
            desc = "OPTIONS_CASTBAR_HIDE_FRIENDLY",
        },
        {
            type = "toggle",
            get = function() return Plater.db.profile.hide_enemy_castbars end,
            set = function (self, fixedparam, value)
                Plater.db.profile.hide_enemy_castbars = value
                Plater.RefreshDBUpvalues()
            end,
            name = "OPTIONS_CASTBAR_HIDE_ENEMY",
            desc = "OPTIONS_CASTBAR_HIDE_ENEMY",
        },

        {type = "blank"},

        {
            type = "toggle",
            get = function() return Plater.db.profile.cast_statusbar_use_fade_effects end,
            set = function (self, fixedparam, value)
                Plater.db.profile.cast_statusbar_use_fade_effects = value
                Plater.UpdateAllPlates()
            end,
            name = "OPTIONS_CASTBAR_FADE_ANIM_ENABLED",
            desc = "OPTIONS_CASTBAR_FADE_ANIM_ENABLED_DESC",
        },

        {
            type = "range",
            get = function() return Plater.db.profile.cast_statusbar_fadein_time end,
            set = function (self, fixedparam, value)
                Plater.db.profile.cast_statusbar_fadein_time = value
                Plater.UpdateAllPlates()
            end,
            min = 0.01,
            max = 1,
            step = 0.01,
            usedecimals = true,
            name = "OPTIONS_CASTBAR_FADE_ANIM_TIME_START",
            desc = "OPTIONS_CASTBAR_FADE_ANIM_TIME_START_DESC",
        },
        {
            type = "range",
            get = function() return Plater.db.profile.cast_statusbar_fadeout_time end,
            set = function (self, fixedparam, value)
                Plater.db.profile.cast_statusbar_fadeout_time = value
                Plater.UpdateAllPlates()
            end,
            min = 0.01,
            max = 2,
            step = 0.01,
            usedecimals = true,
            name = "OPTIONS_CASTBAR_FADE_ANIM_TIME_END",
            desc = "OPTIONS_CASTBAR_FADE_ANIM_TIME_END_DESC" ,
        },
        
        {type = "blank"},
        {type = "label", get = function() return "Boss-Mod Support:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
        
        {
            type = "toggle",
            get = function() return Plater.db.profile.bossmod_castrename_enabled end,
            set = function (self, fixedparam, value) 
                Plater.db.profile.bossmod_castrename_enabled = value
                --Plater.UpdateAllPlates()
            end,
            name = "Enable boss-mod cast spell renaming",
            desc = "Enable cast rename based on BigWigs or DBM spell names.",
        },

        {type = "breakline"},

        {type = "label", get = function() return "OPTIONS_CASTBAR_SPARK_SETTINGS" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},

        {
            type = "select",
            get = function() return Plater.db.profile.cast_statusbar_spark_texture end,
            values = function() return cast_spark_texture_selected_options end,
            name = "OPTIONS_TEXTURE",
            desc = "OPTIONS_TEXTURE",
        },

        {
            type = "toggle",
            get = function() return Plater.db.profile.cast_statusbar_spark_hideoninterrupt end,
            set = function (self, fixedparam, value)
                Plater.db.profile.cast_statusbar_spark_hideoninterrupt = value
                Plater.UpdateAllPlates()
            end,
            name = "OPTIONS_CASTBAR_SPARK_HIDE_INTERRUPT",
            desc = "OPTIONS_CASTBAR_SPARK_HIDE_INTERRUPT",
        },
        {
            type = "toggle",
            get = function() return Plater.db.profile.cast_statusbar_spark_half end,
            set = function (self, fixedparam, value)
                Plater.db.profile.cast_statusbar_spark_half = value
                Plater.UpdateAllPlates()

                print("hald spark", value)
            end,
            name = "OPTIONS_CASTBAR_SPARK_HALF",
            desc = "OPTIONS_CASTBAR_SPARK_HALF_DESC",
        },
        {
            type = "color",
            get = function()
                local color = Plater.db.profile.cast_statusbar_spark_color
                return {color[1], color[2], color[3], color[4]}
            end,
            set = function (self, r, g, b, a)
                local color = Plater.db.profile.cast_statusbar_spark_color
                color[1], color[2], color[3], color[4] = r, g, b, a
                Plater.UpdateAllPlates()
            end,
            name = "OPTIONS_COLOR",
            desc = "OPTIONS_COLOR",
        },

        {
            type = "range",
            get = function() return Plater.db.profile.cast_statusbar_spark_width end,
            set = function (self, fixedparam, value)
                Plater.db.profile.cast_statusbar_spark_width = value
                Plater.UpdateAllPlates()
            end,
            min = 4,
            max = 32,
            step = 1,
            name = "OPTIONS_WIDTH",
            desc = "OPTIONS_WIDTH",
        },
        {
            type = "range",
            get = function() return Plater.db.profile.cast_statusbar_spark_offset end,
            set = function (self, fixedparam, value)
                Plater.db.profile.cast_statusbar_spark_offset = value
                Plater.UpdateAllPlates()
            end,
            min = -32,
            max = 32,
            step = 1,
            name = "OPTIONS_XOFFSET",
            desc = "OPTIONS_XOFFSET",
        },
        {
            type = "range",
            get = function() return Plater.db.profile.cast_statusbar_spark_alpha end,
            set = function (self, fixedparam, value)
                Plater.db.profile.cast_statusbar_spark_alpha = value
                Plater.UpdateAllPlates()
            end,
            min = 0,
            max = 1,
            step = 0.1,
            usedecimals = true,
            name = "OPTIONS_ALPHA",
            desc = "OPTIONS_ALPHA",
        },

        {type = "blank"},
        {type = "label", get = function() return "OPTIONS_CASTBAR_COLORS" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},

        {
            type = "color",
            get = function()
                local color = Plater.db.profile.cast_statusbar_color
                return {color[1], color[2], color[3], color[4]}
            end,
            set = function (self, r, g, b, a)
                local color = Plater.db.profile.cast_statusbar_color
                color[1], color[2], color[3], color[4] = r, g, b, a
                Plater.UpdateAllPlates()
                Plater.DoCastBarTest()
            end,
            name = "OPTIONS_CAST_COLOR_REGULAR",
            desc = "OPTIONS_CAST_COLOR_REGULAR",
        },
        {
            type = "color",
            get = function()
                local color = Plater.db.profile.cast_statusbar_color_channeling
                return {color[1], color[2], color[3], color[4]}
            end,
            set = function (self, r, g, b, a)
                local color = Plater.db.profile.cast_statusbar_color_channeling
                color[1], color[2], color[3], color[4] = r, g, b, a
                Plater.UpdateAllPlates()
                Plater.DoCastBarTest()
            end,
            name = "OPTIONS_CAST_COLOR_CHANNELING",
            desc = "OPTIONS_CAST_COLOR_CHANNELING",
        },
        {
            type = "color",
            get = function()
                local color = Plater.db.profile.cast_statusbar_color_nointerrupt
                return {color[1], color[2], color[3], color[4]}
            end,
            set = function (self, r, g, b, a)
                local color = Plater.db.profile.cast_statusbar_color_nointerrupt
                color[1], color[2], color[3], color[4] = r, g, b, a
                Plater.UpdateAllPlates()
                Plater.DoCastBarTest (true)
            end,
            name = "OPTIONS_CAST_COLOR_UNINTERRUPTIBLE",
            desc = "OPTIONS_CAST_COLOR_UNINTERRUPTIBLE",
        },
        {
            type = "color",
            get = function()
                local color = Plater.db.profile.cast_statusbar_color_interrupted
                return {color[1], color[2], color[3], color[4]}
            end,
            set = function (self, r, g, b, a)
                local color = Plater.db.profile.cast_statusbar_color_interrupted
                color[1], color[2], color[3], color[4] = r, g, b, a
                Plater.UpdateAllPlates()
                Plater.DoCastBarTest()
            end,
            name = "OPTIONS_CAST_COLOR_INTERRUPTED",
            desc = "OPTIONS_CAST_COLOR_INTERRUPTED",
        },
        {
            type = "color",
            get = function()
                local color = Plater.db.profile.cast_statusbar_color_finished
                return {color[1], color[2], color[3], color[4]}
            end,
            set = function (self, r, g, b, a)
                local color = Plater.db.profile.cast_statusbar_color_finished
                color[1], color[2], color[3], color[4] = r, g, b, a
                Plater.UpdateAllPlates()
                Plater.DoCastBarTest()
            end,
            name = "OPTIONS_CAST_COLOR_SUCCESS",
            desc = "OPTIONS_CAST_COLOR_SUCCESS",
        },

        {
            type = "color",
            get = function()
                local color = Plater.db.profile.cast_statusbar_bgcolor
                return {color[1], color[2], color[3], color[4]}
            end,
            set = function (self, r, g, b, a)
                local color = Plater.db.profile.cast_statusbar_bgcolor
                color[1], color[2], color[3], color[4] = r, g, b, a
                Plater.UpdateAllPlates()
                Plater.DoCastBarTest()
            end,
            name = "OPTIONS_COLOR_BACKGROUND",
            desc = "OPTIONS_COLOR_BACKGROUND",
        },

        {type = "breakline"},
        --toggle cast bar target
        {type = "label", get = function() return "Cast Bar Target Name:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
        {
            type = "toggle",
            get = function() return Plater.db.profile.castbar_target_show end,
            set = function (self, fixedparam, value)
                Plater.db.profile.castbar_target_show = value
                Plater.RefreshDBUpvalues()
            end,
            name = "OPTIONS_CAST_SHOW_TARGETNAME",
            desc = "OPTIONS_CAST_SHOW_TARGETNAME_DESC",
        },

        {
            type = "toggle",
            get = function() return Plater.db.profile.castbar_target_notank end,
            set = function (self, fixedparam, value)
                Plater.db.profile.castbar_target_notank = value
                Plater.RefreshDBUpvalues()
            end,
            name = "OPTIONS_CAST_SHOW_TARGETNAME_TANK",
            desc = "OPTIONS_CAST_SHOW_TARGETNAME_TANK_DESC",
        },

        {
            type = "range",
            get = function() return Plater.db.profile.castbar_target_text_size end,
            set = function (self, fixedparam, value)
                Plater.db.profile.castbar_target_text_size = value
                Plater.UpdateAllPlates()
            end,
            min = 6,
            max = 99,
            step = 1,
            name = "OPTIONS_SIZE",
            desc = "OPTIONS_SIZE",
        },
        --text font
        {
            type = "select",
            get = function() return Plater.db.profile.castbar_target_font end,
            values = function() return DF:BuildDropDownFontList(on_select_castbar_target_font) end,
            name = "OPTIONS_FONT",
            desc = "OPTIONS_TEXT_FONT",
        },
        --cast text color
        {
            type = "color",
            get = function()
                local color = Plater.db.profile.castbar_target_color
                return {color[1], color[2], color[3], color[4]}
            end,
            set = function (self, r, g, b, a)
                local color = Plater.db.profile.castbar_target_color
                color[1], color[2], color[3], color[4] = r, g, b, a
                Plater.UpdateAllPlates()
            end,
            name = "OPTIONS_COLOR",
            desc = "OPTIONS_COLOR",
        },

        --text outline options
        {
            type = "select",
            get = function() return Plater.db.profile.castbar_target_outline end,
            values = function() return build_outline_modes_table (nil, "castbar_target_outline") end,
            name = "OPTIONS_OUTLINE",
            desc = "OPTIONS_OUTLINE",
        },

        --text shadow color
        {
            type = "color",
            get = function()
                local color = Plater.db.profile.castbar_target_shadow_color
                return {color[1], color[2], color[3], color[4]}
            end,
            set = function (self, r, g, b, a)
                local color = Plater.db.profile.castbar_target_shadow_color
                color[1], color[2], color[3], color[4] = r, g, b, a
                Plater.UpdateAllPlates()
            end,
            name = "OPTIONS_SHADOWCOLOR",
            desc = "OPTIONS_TOGGLE_TO_CHANGE",
        },

        {
            type = "select",
            get = function() return Plater.db.profile.castbar_target_anchor.side end,
            values = function() return build_anchor_side_table (nil, "castbar_target_anchor") end,
            name = "OPTIONS_ANCHOR",
            desc = "OPTIONS_ANCHOR_TARGET_SIDE",
        },
        {
            type = "range",
            get = function() return Plater.db.profile.castbar_target_anchor.x end,
            set = function (self, fixedparam, value)
                Plater.db.profile.castbar_target_anchor.x = value
                Plater.UpdateAllPlates()
            end,
            min = -100,
            max = 100,
            step = 1,
            usedecimals = true,
            name = "OPTIONS_XOFFSET",
            desc = "OPTIONS_XOFFSET",
        },
        {
            type = "range",
            get = function() return Plater.db.profile.castbar_target_anchor.y end,
            set = function (self, fixedparam, value)
                Plater.db.profile.castbar_target_anchor.y = value
                Plater.UpdateAllPlates()
            end,
            min = -100,
            max = 100,
            step = 1,
            usedecimals = true,
            name = "OPTIONS_YOFFSET",
            desc = "OPTIONS_YOFFSET",
        },

        {type = "breakline"},
        --toggle cast bar target
        {type = "label", get = function() return "OPTIONS_CASTBAR_SPELLICON" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
        {
            type = "toggle",
            get = function() return Plater.db.profile.castbar_icon_customization_enabled end,
            set = function (self, fixedparam, value)
                Plater.db.profile.castbar_icon_customization_enabled = value
                Plater.RefreshDBUpvalues()
            end,
            name = "OPTIONS_CASTBAR_ICON_CUSTOM_ENABLE",
            desc = "OPTIONS_CASTBAR_ICON_CUSTOM_ENABLE_DESC",
        },

        {
            type = "toggle",
            get = function() return Plater.db.profile.castbar_icon_show end,
            set = function (self, fixedparam, value)
                Plater.db.profile.castbar_icon_show = value
                Plater.RefreshDBUpvalues()
            end,
            name = "OPTIONS_ICON_SHOW",
            desc = "OPTIONS_ICON_SHOW",
        },

        {
            type = "select",
            get = function() return Plater.db.profile.castbar_icon_attach_to_side end,
            values = function() return castbar_icon_attach_to_side_options end,
            name = "OPTIONS_ICON_SIDE",
            desc = "OPTIONS_ICON_SIDE",
        },

        {
            type = "select",
            get = function() return Plater.db.profile.castbar_icon_size end,
            values = function() return castbar_icon_size_options end,
            name = "OPTIONS_ICON_SIZE",
            desc = "OPTIONS_ICON_SIZE",
        },

        {
            type = "range",
            get = function() return Plater.db.profile.castbar_icon_x_offset end,
            set = function (self, fixedparam, value)
                Plater.db.profile.castbar_icon_x_offset = value
                Plater.UpdateAllPlates()
            end,
            min = -20,
            max = 20,
            step = 1,
            name = "OPTIONS_XOFFSET",
            desc = "OPTIONS_XOFFSET",
        },

        {type = "blank"},
        {type = "label", get = function() return "OPTIONS_CASTBAR_BLIZZCASTBAR" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},

        --hide castbar from blizzard
        {
            type = "toggle",
            get = function() return Plater.db.profile.hide_blizzard_castbar end,
            set = function (self, fixedparam, value)
                Plater.db.profile.hide_blizzard_castbar = value
            end,
            name = "OPTIONS_CASTBAR_HIDEBLIZZARD",
            desc = "OPTIONS_CASTBAR_HIDEBLIZZARD",
        },
    }

    local castBarFrame = PlaterOptionsPanelContainerCastBarConfig

    --the -30 is to fix an annomaly where the options for castbars starts 30 pixels to the right, dunno why (tercio)
    castBar_options.always_boxfirst = true
    castBar_options.language_addonId = addonId
    castBar_options.Name = "Cast Bar Options"
    DF:BuildMenu (castBarFrame, castBar_options, startX-20, startY, heightSize, false, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template, platerInternal.OptionsGlobalCallback)

    platerInternal.LoadOnDemand_IsLoaded.CastOptions = true
    table.insert(PlaterOptionsPanelFrame.AllSettingsTable, castBar_options)
    platerInternal.CreateCastBarOptions = function() end
end