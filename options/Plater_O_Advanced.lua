
local addonId, platerInternal = ...
local Plater = Plater
---@type detailsframework
local DF = DetailsFramework
local _

local IS_WOW_PROJECT_MAINLINE = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
local IS_WOW_PROJECT_MIDNIGHT = DF.IsAddonApocalypseWow()

--font select
local on_select_blizzard_nameplate_font = function (_, _, value)
    Plater.db.profile.blizzard_nameplate_font = value
end

local on_select_blizzard_nameplate_large_font = function (_, _, value)
    Plater.db.profile.blizzard_nameplate_large_font = value
end

function platerInternal.CreateAdvancedOptions()
    if platerInternal.LoadOnDemand_IsLoaded.AdvancedOptions then return end -- already loaded
    
    --templates
    local options_text_template = DF:GetTemplate ("font", "OPTIONS_FONT_TEMPLATE")
    local options_dropdown_template = DF:GetTemplate ("dropdown", "OPTIONS_DROPDOWN_TEMPLATE")
    local options_switch_template = DF:GetTemplate ("switch", "OPTIONS_CHECKBOX_TEMPLATE")
    local options_slider_template = DF:GetTemplate ("slider", "OPTIONS_SLIDER_TEMPLATE")
    local options_button_template = DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE")

    local L = DF.Language.GetLanguageTable(addonId)

    local build_nameplate_anchor_options = function()
        local languageId = DF.Language.GetLanguageIdForAddonId(addonId)

        local headLabelId = "OPTIONS_ADVANCED_NAMEPLATE_ANCHOR_HEAD"
        local headFeetLabelId = "OPTIONS_ADVANCED_NAMEPLATE_ANCHOR_HEAD_FEET"
        local feetLabelId = "OPTIONS_ADVANCED_NAMEPLATE_ANCHOR_FEET"

        return {
            {
                label = DF.Language.GetText(addonId, headLabelId) or headLabelId,
                languageId = languageId,
                phraseId = headLabelId,
                value = 0,
                onclick = Plater.ChangeNameplateAnchor,
                desc = DF.Language.GetText(addonId, "OPTIONS_ADVANCED_NAMEPLATE_ANCHOR_HEAD_DESC") or "OPTIONS_ADVANCED_NAMEPLATE_ANCHOR_HEAD_DESC",
            },
            {
                label = DF.Language.GetText(addonId, headFeetLabelId) or headFeetLabelId,
                languageId = languageId,
                phraseId = headFeetLabelId,
                value = 1,
                onclick = Plater.ChangeNameplateAnchor,
                desc = DF.Language.GetText(addonId, "OPTIONS_ADVANCED_NAMEPLATE_ANCHOR_HEAD_FEET_DESC") or "OPTIONS_ADVANCED_NAMEPLATE_ANCHOR_HEAD_FEET_DESC",
            },
            {
                label = DF.Language.GetText(addonId, feetLabelId) or feetLabelId,
                languageId = languageId,
                phraseId = feetLabelId,
                value = 2,
                onclick = Plater.ChangeNameplateAnchor,
                desc = DF.Language.GetText(addonId, "OPTIONS_ADVANCED_NAMEPLATE_ANCHOR_FEET_DESC") or "OPTIONS_ADVANCED_NAMEPLATE_ANCHOR_FEET_DESC",
            },
        }
    end

    --cvars
    local CVAR_ENABLED = "1"
    local CVAR_DISABLED = "0"
    local CVAR_MOVEMENT_SPEED = "nameplateMotionSpeed"

    ---@diagnostic disable-next-line: undefined-global
    local IS_WOW_PROJECT_MAINLINE = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
    ---@diagnostic disable-next-line: undefined-global
    local IS_WOW_PROJECT_NOT_MAINLINE = WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE

    local CVarDesc = "\n\n|cFFFF7700[*]|r |cFFa0a0a0" .. L["CVar, saved within Plater profile and restored when loading the profile."] .. "|r"
    local CVarIcon = "|cFFFF7700*|r"
    local CVarNeedReload = "\n\n|cFFFF2200[*]|r |cFFa0a0a0" .. L["A /reload may be required to take effect."] .. "|r"

    local dropdownStatusBarTexture = platerInternal.Defaults.dropdownStatusBarTexture
    local dropdownStatusBarColor = platerInternal.Defaults.dropdownStatusBarColor

    --outline table
    local outline_modes = {"NONE", "MONOCHROME", "OUTLINE", "THICKOUTLINE", "MONOCHROME, OUTLINE", "MONOCHROME, THICKOUTLINE"}
    local outline_modes_names_phraseIds = {"OPTIONS_ADVANCED_OUTLINE_MODE_NONE", "OPTIONS_ADVANCED_OUTLINE_MODE_MONOCHROME", "OPTIONS_ADVANCED_OUTLINE_MODE_OUTLINE", "OPTIONS_ADVANCED_OUTLINE_MODE_THICK_OUTLINE", "OPTIONS_ADVANCED_OUTLINE_MODE_MONOCHROME_OUTLINE", "OPTIONS_ADVANCED_OUTLINE_MODE_MONOCHROME_THICK_OUTLINE"}
    local build_outline_modes_table = function (actorType, member)
        local t = {}
        local languageId = DF.Language.GetLanguageIdForAddonId(addonId)
        for i = 1, #outline_modes do
            local value = outline_modes[i]
            local phraseId = outline_modes_names_phraseIds[i]
            local label = DF.Language.GetText(addonId, phraseId) or phraseId
            tinsert (t, {
                label = label,
                languageId = languageId,
                phraseId = phraseId,
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

    local build_number_format_options = function()
        local languageId = DF.Language.GetLanguageIdForAddonId(addonId)
        local westernPhraseId = "OPTIONS_ADVANCED_NUMBER_FORMAT_WESTERN"
        local number_format_options = {DF.Language.GetText(addonId, westernPhraseId) or westernPhraseId}
        local number_format_options_config = {"western", "eastasia"}

        local eastAsiaMyriads_1k, eastAsiaMyriads_10k, eastAsiaMyriads_1B
        if (GetLocale() == "koKR") then
            tinsert (number_format_options, "East Asia (1천 - 1만)")
        elseif (GetLocale() == "zhCN") then
            tinsert (number_format_options, "East Asia (1千 - 1万)")
        elseif (GetLocale() == "zhTW") then
            tinsert (number_format_options, "East Asia (1千 - 1萬)")
        else
            tinsert (number_format_options, "East Asia (1천 - 1만)")
        end

        local t = {}
        for i = 1, #number_format_options do
            local phraseId = (i == 1) and westernPhraseId or nil
            tinsert (t, {
                label = number_format_options [i],
                languageId = phraseId and languageId or nil,
                phraseId = phraseId,
                value = number_format_options_config [i],
                onclick = function (_, _, value)
                    Plater.db.profile.number_region = value
                    Plater.RefreshDBUpvalues()
                    Plater.UpdateAllPlates()
                end
            })
        end
        return t
    end

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

    local advanced_options = {
        {type = "label", get = function() return "OPTIONS_ADVANCED_HEADER_GENERAL_SETTINGS" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},

        {
            type = "range",
            get = function() return Plater.db.profile.update_throttle end,
            set = function (self, fixedparam, value)
                Plater.db.profile.update_throttle = value
                Plater.RefreshDBUpvalues()
            end,
            min = 0.050,
            max = 0.500,
            step = 0.050,
            name = "OPTIONS_ADVANCED_UPDATE_INTERVAL",
            usedecimals = true,
            desc = "OPTIONS_ADVANCED_UPDATE_INTERVAL_DESC",
        },

        {
            type = "toggle",
            get = function() return Plater.db.profile.quick_hide end,
            set = function (self, fixedparam, value)
                Plater.db.profile.quick_hide = value
                if (value) then
                    SetCVar ("nameplateRemovalAnimation", CVAR_DISABLED)
                else
                    SetCVar ("nameplateRemovalAnimation", CVAR_ENABLED)
                end
                Plater.UpdateAllPlates()
            end,
            nocombat = true,
            name = "OPTIONS_ADVANCED_QUICK_HIDE_ON_DEATH",
            desc = "OPTIONS_ADVANCED_QUICK_HIDE_ON_DEATH_DESC",
        },

        {
            type = "toggle",
            get = function() return Plater.db.profile.show_healthbars_on_not_attackable end,
            set = function (self, fixedparam, value)
                Plater.db.profile.show_healthbars_on_not_attackable = value
                Plater.UpdateAllPlates()
            end,
            name = "OPTIONS_ADVANCED_SHOW_HEALTHBARS_ON_NOT_ATTACKABLE_UNITS",
            desc = "OPTIONS_ADVANCED_SHOW_HEALTHBARS_ON_NOT_ATTACKABLE_UNITS_DESC",
        },

        {
            type = "toggle",
            boxfirst = true,
            --get = function() return GetCVarBool ("SoftTargetIconGameObject") and tonumber(GetCVar("SoftTargetInteract") or 0) == 3 end,
            get = function() return tonumber(GetCVar("SoftTargetInteract") or 0) == 3 end,
            set = function (self, fixedparam, value)
                if (not InCombatLockdown()) then

                    SetCVar ("SoftTargetIconGameObject", value and "1" or "0")
                    SetCVar ("SoftTargetInteract", value and "3" or "0")
                else
                    Plater:Msg (L["OPTIONS_ERROR_CVARMODIFY"])
                end
            end,
            name = "@OPTIONS_ADVANCED_SHOW_SOFT_INTERACT_ON_GAME_OBJECTS@" .. CVarIcon,
            descPhraseId = "@OPTIONS_ADVANCED_SHOW_SOFT_INTERACT_ON_GAME_OBJECTS_DESC@" .. CVarDesc,
            nocombat = true,
        },

        {
            type = "toggle",
            get = function() return GetCVarBool ("SoftTargetNameplateInteract") end,
            set = function (self, fixedparam, value)
                if (not InCombatLockdown()) then
                    SetCVar ("SoftTargetNameplateInteract", value and "1" or "0")
                else
                    Plater:Msg (L["OPTIONS_ERROR_CVARMODIFY"])
                end
            end,
            name = "@OPTIONS_ADVANCED_FORCE_NAMEPLATES_ON_SOFT_INTERACT_TARGET@" .. CVarIcon,
            descPhraseId = "@OPTIONS_ADVANCED_FORCE_NAMEPLATES_ON_SOFT_INTERACT_TARGET_DESC@" .. CVarDesc,
        },
        {
            type = "toggle",
            get = function() return Plater.db.profile.show_healthbars_on_softinteract end,
            set = function (self, fixedparam, value)
                Plater.db.profile.show_healthbars_on_softinteract = value
                Plater.UpdateAllPlates()
            end,
            name = "OPTIONS_ADVANCED_ALWAYS_SHOW_SOFT_INTERACT_TARGET",
            desc = "OPTIONS_ADVANCED_ALWAYS_SHOW_SOFT_INTERACT_TARGET_DESC",
        },
        {
            type = "toggle",
            get = function() return Plater.db.profile.ignore_softinteract_objects end,
            set = function (self, fixedparam, value)
                Plater.db.profile.ignore_softinteract_objects = value
                Plater.UpdateAllPlates()
            end,
            name = "OPTIONS_ADVANCED_USE_BLIZZARD_SOFT_INTERACT_FOR_OBJECTS",
            desc = "OPTIONS_ADVANCED_USE_BLIZZARD_SOFT_INTERACT_FOR_OBJECTS_DESC",
        },
        {
            type = "toggle",
            get = function() return Plater.db.profile.hide_name_on_game_objects end,
            set = function (self, fixedparam, value)
                Plater.db.profile.hide_name_on_game_objects = value
                Plater.UpdateAllPlates()
            end,
            name = "OPTIONS_ADVANCED_HIDE_PLATER_NAMES_GAME_OBJECTS",
            desc = "OPTIONS_ADVANCED_HIDE_PLATER_NAMES_GAME_OBJECTS_DESC",
        },
        {
            type = "color",
            get = function()
                local color = Plater.db.profile.name_on_game_object_color
                return {color[1], color[2], color[3], color[4]}
            end,
            set = function (self, r, g, b, a)
                local color = Plater.db.profile.name_on_game_object_color
                color[1], color[2], color[3], color[4] = r, g, b, a
            end,
            name = "OPTIONS_INTERACT_OBJECT_NAME_COLOR",
            desc = "OPTIONS_INTERACT_OBJECT_NAME_COLOR_DESC",
        },
        {
            type = "toggle",
            get = function() return Plater.db.profile.show_softinteract_icons end,
            set = function (self, fixedparam, value)
                Plater.db.profile.show_softinteract_icons = value
                Plater.UpdateAllPlates()
            end,
            name = "OPTIONS_ADVANCED_SHOW_SOFT_INTERACT_ICON",
            desc = "OPTIONS_ADVANCED_SHOW_SOFT_INTERACT_ICON_DESC",
        },

        {type = "blank"},

        {type = "label", get = function() return "OPTIONS_ADVANCED_HEADER_CLIENT_SETTINGS_CVARS" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
        {
            type = "toggle",
            get = function() return GetCVarBool ("nameplateShowOffscreen") end,
            set = function (self, fixedparam, value)
                if (not InCombatLockdown()) then
                    SetCVar ("nameplateShowOffscreen", value and "1" or "0")
                else
                    Plater:Msg (L["OPTIONS_ERROR_CVARMODIFY"])
                    self:SetValue (GetCVarBool ("nameplateShowOffscreen"))
                end
            end,
            name = "@OPTIONS_ADVANCED_KEEP_NAMEPLATES_ON_SCREEN@" .. CVarIcon,
            descPhraseId = "@OPTIONS_ADVANCED_KEEP_NAMEPLATES_ON_SCREEN_DESC@" .. CVarDesc,
            nocombat = true,
            hidden = not IS_WOW_PROJECT_MIDNIGHT,
        },
        
        {
            type = "range",
            get = function() return tonumber (GetCVar ("nameplateOtherTopInset")) end,
            set = function (self, fixedparam, value)
                if (not InCombatLockdown()) then
                    if (value == 0) then
                        SetCVar ("nameplateOtherTopInset", -1)
                        SetCVar ("nameplateLargeTopInset", -1)

                    else
                        SetCVar ("nameplateOtherTopInset", value)
                        SetCVar ("nameplateLargeTopInset", value)
                    end
                else
                    Plater:Msg (L["OPTIONS_ERROR_CVARMODIFY"])
                end
            end,
            min = 0.000,
            max = 0.1,
            step = 0.005,
            thumbscale = 1.7,
            usedecimals = true,
            name = "@OPTIONS_ADVANCED_LOCK_TO_SCREEN_TOP_SIDE@" .. CVarIcon,
            descPhraseId = "@OPTIONS_ADVANCED_LOCK_TO_SCREEN_TOP_SIDE_DESC@" .. CVarDesc,
            nocombat = true,
            hidden = IS_WOW_PROJECT_MIDNIGHT,
        },

        {
            type = "range",
            get = function() return tonumber (GetCVar ("nameplateOtherBottomInset")) end,
            set = function (self, fixedparam, value)
                if (not InCombatLockdown()) then
                    if (value == 0) then
                        SetCVar ("nameplateOtherBottomInset", -1)
                        SetCVar ("nameplateLargeBottomInset", -1)

                    else
                        SetCVar ("nameplateOtherBottomInset", value)
                        SetCVar ("nameplateLargeBottomInset", value)

                    end
                else
                    Plater:Msg (L["OPTIONS_ERROR_CVARMODIFY"])
                end
            end,
            min = 0.000,
            max = 0.1,
            step = 0.005,
            thumbscale = 1.7,
            usedecimals = true,
            name = "@OPTIONS_ADVANCED_LOCK_TO_SCREEN_BOTTOM_SIDE@" .. CVarIcon,
            descPhraseId = "@OPTIONS_ADVANCED_LOCK_TO_SCREEN_BOTTOM_SIDE_DESC@" .. CVarDesc,
            nocombat = true,
            hidden = IS_WOW_PROJECT_MIDNIGHT,
        },

        {
            type = "range",
            get = function() return tonumber (GetCVar ("nameplateOverlapV")) end,
            set = function (self, fixedparam, value)
                if (not InCombatLockdown()) then
                    SetCVar ("nameplateOverlapV", value)
                else
                    Plater:Msg (L["OPTIONS_ERROR_CVARMODIFY"])
                end
            end,
            min = 0.2,
            max = 2.5,
            step = 0.05,
            thumbscale = 1.7,
            usedecimals = true,
            name = "@OPTIONS_ADVANCED_NAMEPLATE_OVERLAP_V@" .. CVarIcon,
            descPhraseId = "@OPTIONS_ADVANCED_NAMEPLATE_OVERLAP_V_DESC@" .. CVarDesc,
            nocombat = true,
            --hidden = IS_WOW_PROJECT_MIDNIGHT,
        },
        {
            type = "range",
            get = function() return tonumber (GetCVar ("nameplateOverlapH")) end,
            set = function (self, fixedparam, value)
                if (not InCombatLockdown()) then
                    SetCVar ("nameplateOverlapH", value)
                else
                    Plater:Msg (L["OPTIONS_ERROR_CVARMODIFY"])
                end
            end,
            min = 0.2,
            max = 2.5,
            step = 0.05,
            thumbscale = 1.7,
            usedecimals = true,
            name = "@OPTIONS_ADVANCED_NAMEPLATE_OVERLAP_H@" .. CVarIcon,
            descPhraseId = "@OPTIONS_ADVANCED_NAMEPLATE_OVERLAP_H_DESC@" .. CVarDesc,
            nocombat = true,
            --hidden = IS_WOW_PROJECT_MIDNIGHT,
        },

        {
            type = "range",
            get = function() return tonumber (GetCVar (CVAR_MOVEMENT_SPEED)) end,
            set = function (self, fixedparam, value)
                if (not InCombatLockdown()) then
                    SetCVar (CVAR_MOVEMENT_SPEED, value)
                else
                    Plater:Msg (L["OPTIONS_ERROR_CVARMODIFY"])
                end
            end,
            min = 0.005,
            max = 0.2,
            step = 0.005,
            thumbscale = 1.7,
            usedecimals = true,
            name = "@OPTIONS_ADVANCED_MOVEMENT_SPEED@" .. CVarIcon,
            descPhraseId = "@OPTIONS_ADVANCED_MOVEMENT_SPEED_DESC@" .. CVarDesc,
            nocombat = true,
            hidden = IS_WOW_PROJECT_MIDNIGHT,
        },
        {
            type = "range",
            get = function() return tonumber (GetCVar ("nameplateGlobalScale")) end,
            set = function (self, fixedparam, value)
                if (not InCombatLockdown()) then
                    SetCVar ("nameplateGlobalScale", value)
                else
                    Plater:Msg (L["OPTIONS_ERROR_CVARMODIFY"])
                end
            end,
            min = 0.75,
            max = 2,
            step = 0.1,
            thumbscale = 1.7,
            usedecimals = true,
            name = "@OPTIONS_ADVANCED_GLOBAL_SCALE@" .. CVarIcon,
            descPhraseId = "@OPTIONS_ADVANCED_GLOBAL_SCALE_DESC@" .. CVarDesc,
            nocombat = true,
            hidden = IS_WOW_PROJECT_MIDNIGHT,
        },

        {
            type = "range",
            get = function() return tonumber (GetCVar ("nameplateMinScale")) end,
            set = function (self, fixedparam, value)
                if (not InCombatLockdown()) then
                    SetCVar ("nameplateMinScale", value)
                else
                    Plater:Msg (L["OPTIONS_ERROR_CVARMODIFY"])
                end
            end,
            min = 0.3,
            max = 2,
            step = 0.1,
            thumbscale = 1.7,
            usedecimals = true,
            name = "@OPTIONS_ADVANCED_MIN_SCALE@" .. CVarIcon,
            descPhraseId = "@OPTIONS_ADVANCED_MIN_SCALE_DESC@" .. CVarDesc,
            nocombat = true,
        },

        {
            type = "range",
            get = function() return tonumber (GetCVar ("nameplateLargerScale")) end,
            set = function (self, fixedparam, value)
                if (not InCombatLockdown()) then
                    SetCVar ("nameplateLargerScale", value)
                else
                    Plater:Msg (L["OPTIONS_ERROR_CVARMODIFY"])
                end
            end,
            min = 0.3,
            max = 2,
            step = 0.1,
            thumbscale = 1.7,
            usedecimals = true,
            name = "@OPTIONS_ADVANCED_LARGER_SCALE@" .. CVarIcon,
            descPhraseId = "@OPTIONS_ADVANCED_LARGER_SCALE_DESC@" .. CVarDesc,
            nocombat = true,
        },

        {
            type = "select",
            get = function() return tonumber (GetCVar ("nameplateOtherAtBase")) end,
            values = function() return build_nameplate_anchor_options() end,
            name = "@OPTIONS_ADVANCED_ANCHOR_POINT@" .. CVarIcon,
            descPhraseId = "@OPTIONS_ADVANCED_ANCHOR_POINT_DESC@" .. CVarDesc,
            nocombat = true,
        },
        {
            type = "toggle",
            get = function() return GetCVarBool ("nameplateShowDebuffsOnFriendly") end,
            set = function (self, fixedparam, value)
                if (not InCombatLockdown()) then
                    SetCVar ("nameplateShowDebuffsOnFriendly", value and "1" or "0")
                else
                    Plater:Msg (L["OPTIONS_ERROR_CVARMODIFY"])
                    self:SetValue (GetCVarBool ("nameplateShowDebuffsOnFriendly"))
                end
            end,
            name = "@OPTIONS_ADVANCED_SHOW_DEBUFFS_ON_BLIZZARD_HEALTH_BARS@" .. CVarIcon,
            descPhraseId = "@OPTIONS_ADVANCED_SHOW_DEBUFFS_ON_BLIZZARD_HEALTH_BARS_DESC@" .. CVarDesc .. CVarNeedReload,
            nocombat = true,
            hidden = IS_WOW_PROJECT_MIDNIGHT,
        },

        {type = "blank", hidden = not IS_WOW_PROJECT_MIDNIGHT},
        {type = "label", get = function() return "OPTIONS_ADVANCED_HEADER_OVERLAP_SIZE_SCALING" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
        {
            type = "range",
            get = function() return Plater.db.profile.overlap_space_scale[1] end,
            set = function (self, fixedparam, value)
                Plater.db.profile.overlap_space_scale[1] = value
                Plater.UpdatePlateClickSpace (nil, true)
            end,
            min = 0.5,
            max = 2,
            step = 0.1,
            thumbscale = 1.7,
            usedecimals = true,
            name = "OPTIONS_ADVANCED_ENEMY_NAMEPLATE_OVERLAP_PERCENT_H",
            desc = "OPTIONS_ADVANCED_ENEMY_NAMEPLATE_OVERLAP_PERCENT_H_DESC",
            nocombat = true,
            hidden = not IS_WOW_PROJECT_MIDNIGHT,
        },
        {
            type = "range",
            get = function() return  Plater.db.profile.overlap_space_scale[2] end,
            set = function (self, fixedparam, value)
                Plater.db.profile.overlap_space_scale[2] = value
                Plater.UpdatePlateClickSpace (nil, true)
            end,
            min = 0.5,
            max = 2,
            step = 0.1,
            thumbscale = 1.7,
            usedecimals = true,
            name = "OPTIONS_ADVANCED_ENEMY_NAMEPLATE_OVERLAP_PERCENT_V",
            desc = "OPTIONS_ADVANCED_ENEMY_NAMEPLATE_OVERLAP_PERCENT_V_DESC",
            nocombat = true,
            hidden = not IS_WOW_PROJECT_MIDNIGHT,
        },
        {
            type = "range",
            get = function() return Plater.db.profile.overlap_space_scale_friendly[1] end,
            set = function (self, fixedparam, value)
                Plater.db.profile.overlap_space_scale_friendly[1] = value
                Plater.UpdatePlateClickSpace (nil, true)
            end,
            min = 0.0,
            max = 2,
            step = 0.1,
            thumbscale = 1.7,
            usedecimals = true,
            name = "OPTIONS_ADVANCED_FRIENDLY_NAMEPLATE_OVERLAP_PERCENT_H",
            desc = "OPTIONS_ADVANCED_FRIENDLY_NAMEPLATE_OVERLAP_PERCENT_H_DESC",
            nocombat = true,
            hidden = not IS_WOW_PROJECT_MIDNIGHT,
        },
        {
            type = "range",
            get = function() return  Plater.db.profile.overlap_space_scale_friendly[2] end,
            set = function (self, fixedparam, value)
                Plater.db.profile.overlap_space_scale_friendly[2] = value
                Plater.UpdatePlateClickSpace (nil, true)
            end,
            min = 0.0,
            max = 2,
            step = 0.1,
            thumbscale = 1.7,
            usedecimals = true,
            name = "OPTIONS_ADVANCED_FRIENDLY_NAMEPLATE_OVERLAP_PERCENT_V",
            desc = "OPTIONS_ADVANCED_FRIENDLY_NAMEPLATE_OVERLAP_PERCENT_V_DESC",
            nocombat = true,
            hidden = not IS_WOW_PROJECT_MIDNIGHT,
        },
        {
            type = "toggle",
            get = function()
                local hScale = GetCVarNumberOrDefault("NamePlateHorizontalScale");
                local vScale = GetCVarNumberOrDefault("NamePlateVerticalScale");
                local cScale = GetCVarNumberOrDefault("NamePlateClassificationScale");
                return not (ApproximatelyEqual(hScale, 1) and ApproximatelyEqual(vScale, 1) and ApproximatelyEqual(cScale, 1));
            end,
            set = function (self, fixedparam, value)
                if value then
                    SetCVar("NamePlateHorizontalScale", 1.4);
                    SetCVar("NamePlateVerticalScale", 2.7);
                    SetCVar("NamePlateClassificationScale", 1.25);
                else
                    SetCVar("NamePlateHorizontalScale", 1);
                    SetCVar("NamePlateVerticalScale", 1);
                    SetCVar("NamePlateClassificationScale", 1);
                end
                PlaterOptionsPanelFrame.RefreshOptionsFrame()
            end,
            name = "@OPTIONS_ADVANCED_LARGER_NAMEPLATES@" .. CVarIcon,
            descPhraseId = "@OPTIONS_ADVANCED_LARGER_NAMEPLATES_DESC@" .. CVarDesc,
            nocombat = true,
            hidden = IS_WOW_PROJECT_MIDNIGHT,
        },
        {
            type = "range",
            get = function() return tonumber (GetCVar ("NamePlateVerticalScale")) end,
            set = function (self, fixedparam, value)
                if (not InCombatLockdown()) then
                    SetCVar ("NamePlateVerticalScale", value)
                else
                    Plater:Msg (L["OPTIONS_ERROR_CVARMODIFY"])
                end
            end,
            min = 0.3,
            max = 3,
            step = 0.1,
            thumbscale = 1.7,
            usedecimals = true,
            name = "@OPTIONS_ADVANCED_BASE_VERTICAL_SCALE@" .. CVarIcon,
            descPhraseId = "@OPTIONS_ADVANCED_BASE_VERTICAL_SCALE_DESC@" .. CVarDesc,
            nocombat = true,
            hidden = IS_WOW_PROJECT_MIDNIGHT,
        },
        {
            type = "range",
            get = function() return tonumber (GetCVar ("NamePlateHorizontalScale")) end,
            set = function (self, fixedparam, value)
                if (not InCombatLockdown()) then
                    SetCVar ("NamePlateHorizontalScale", value)
                else
                    Plater:Msg (L["OPTIONS_ERROR_CVARMODIFY"])
                end
            end,
            min = 0.3,
            max = 2,
            step = 0.1,
            thumbscale = 1.7,
            usedecimals = true,
            name = "@OPTIONS_ADVANCED_BASE_HORIZONTAL_SCALE@" .. CVarIcon,
            descPhraseId = "@OPTIONS_ADVANCED_BASE_HORIZONTAL_SCALE_DESC@" .. CVarDesc,
            nocombat = true,
            hidden = IS_WOW_PROJECT_MIDNIGHT,
        },
        {
            type = "range",
            get = function() return tonumber (GetCVar ("NamePlateClassificationScale")) end,
            set = function (self, fixedparam, value)
                if (not InCombatLockdown()) then
                    SetCVar ("NamePlateClassificationScale", value)
                else
                    Plater:Msg (L["OPTIONS_ERROR_CVARMODIFY"])
                end
            end,
            min = 0.3,
            max = 1.5,
            step = 0.1,
            thumbscale = 1.7,
            usedecimals = true,
            name = "@OPTIONS_ADVANCED_BASE_CLASSIFICATION_SCALE@" .. CVarIcon,
            descPhraseId = "@OPTIONS_ADVANCED_BASE_CLASSIFICATION_SCALE_DESC@" .. CVarDesc,
            nocombat = true,
            hidden = IS_WOW_PROJECT_MIDNIGHT,
        },
        
        {type = "blank", hidden = not IS_WOW_PROJECT_MIDNIGHT},
        {type = "label", get = function() return "OPTIONS_ADVANCED_HEADER_NAMEPLATE_SELECTION_SPACE" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"), hidden = not IS_WOW_PROJECT_MIDNIGHT},
        {
            type = "range",
            get = function() return Plater.db.profile.click_space[1] end,
            set = function (self, fixedparam, value)
                Plater.db.profile.click_space[1] = value
                Plater.UpdatePlateClickSpace (nil, true)
            end,
            min = 1,
            max = 300,
            step = 1,
            name = "OPTIONS_WIDTH",
            nocombat = true,
            desc = "OPTIONS_CLICK_SPACE_WIDTH",
            hidden = not IS_WOW_PROJECT_MIDNIGHT,
        },

        {
            type = "range",
            get = function() return Plater.db.profile.click_space[2] end,
            set = function (self, fixedparam, value)
                Plater.db.profile.click_space[2] = value
                Plater.UpdatePlateClickSpace (nil, true)
            end,
            min = 1,
            max = 100,
            step = 1,
            name = "OPTIONS_HEIGHT",
            nocombat = true,
            desc = "OPTIONS_CLICK_SPACE_HEIGHT",
            hidden = not IS_WOW_PROJECT_MIDNIGHT,
        },
        
        {type = "label", get = function() return "OPTIONS_ADVANCED_HEADER_ENEMY_BOX_SELECTION_SPACE" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"), hidden = IS_WOW_PROJECT_MIDNIGHT},
        {
            type = "range",
            get = function() return Plater.db.profile.click_space[1] end,
            set = function (self, fixedparam, value)
                Plater.db.profile.click_space[1] = value
                Plater.UpdatePlateClickSpace (nil, true)
            end,
            min = 1,
            max = 300,
            step = 1,
            name = "OPTIONS_WIDTH",
            nocombat = true,
            desc = "OPTIONS_CLICK_SPACE_WIDTH",
            hidden = IS_WOW_PROJECT_MIDNIGHT,
        },

        {
            type = "range",
            get = function() return Plater.db.profile.click_space[2] end,
            set = function (self, fixedparam, value)
                Plater.db.profile.click_space[2] = value
                Plater.UpdatePlateClickSpace (nil, true)
            end,
            min = 1,
            max = 100,
            step = 1,
            name = "OPTIONS_HEIGHT",
            nocombat = true,
            desc = "OPTIONS_CLICK_SPACE_HEIGHT",
            hidden = IS_WOW_PROJECT_MIDNIGHT,
        },

        {type = "blank", hidden = IS_WOW_PROJECT_MIDNIGHT},

        {type = "label", get = function() return "OPTIONS_ADVANCED_HEADER_FRIENDLY_BOX_SELECTION_SPACE" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"), hidden = IS_WOW_PROJECT_MIDNIGHT},
        {
            type = "range",
            get = function() return Plater.db.profile.click_space_friendly[1] end,
            set = function (self, fixedparam, value)
                Plater.db.profile.click_space_friendly[1] = value
                Plater.UpdatePlateClickSpace (nil, true)
            end,
            min = 1,
            max = 300,
            step = 1,
            name = "OPTIONS_WIDTH",
            nocombat = true,
            desc = "OPTIONS_CLICK_SPACE_WIDTH",
            hidden = IS_WOW_PROJECT_MIDNIGHT,
        },

        {
            type = "range",
            get = function() return Plater.db.profile.click_space_friendly[2] end,
            set = function (self, fixedparam, value)
                Plater.db.profile.click_space_friendly[2] = value
                Plater.UpdatePlateClickSpace (nil, true)
            end,
            min = 1,
            max = 100,
            step = 1,
            name = "OPTIONS_HEIGHT",
            nocombat = true,
            desc = "OPTIONS_CLICK_SPACE_HEIGHT",
            hidden = IS_WOW_PROJECT_MIDNIGHT,
        },

        {type = "blank"},

        { --always show background
            type = "toggle",
            get = function() return Plater.db.profile.click_space_always_show end,
            set = function (self, fixedparam, value)
                Plater.db.profile.click_space_always_show = value
                Plater.UpdateAllPlates()
            end,
            nocombat = true,
            name = "OPTIONS_BACKGROUND_ALWAYSSHOW",
            desc = "OPTIONS_BACKGROUND_ALWAYSSHOW_DESC",
        },

        {type = "breakline"},
        {type = "label", get = function() return "OPTIONS_ADVANCED_HEADER_UNIT_TYPES" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},

        {
            type = "toggle",
            get = function() return GetCVar ("nameplateShowEnemyGuardians") == CVAR_ENABLED end,
            set = function (self, fixedparam, value)
                if (not InCombatLockdown()) then
                    SetCVar ("nameplateShowEnemyGuardians", math.abs (tonumber (GetCVar ("nameplateShowEnemyGuardians"))-1))
                else
                    Plater:Msg (L["OPTIONS_ERROR_CVARMODIFY"])
                    self:SetValue (GetCVar ("nameplateShowEnemyGuardians") == CVAR_ENABLED)
                end
            end,
            name = "@OPTIONS_ADVANCED_UNIT_SHOW_ENEMY_GUARDIANS@" .. CVarIcon,
            descPhraseId = "@OPTIONS_ADVANCED_UNIT_SHOW_ENEMY_GUARDIANS_DESC@" .. CVarDesc,
            nocombat = true,
        },

        {
            type = "toggle",
            get = function() return GetCVar ("nameplateShowEnemyMinions") == CVAR_ENABLED end,
            set = function (self, fixedparam, value)
                if (not InCombatLockdown()) then
                    SetCVar ("nameplateShowEnemyMinions", math.abs (tonumber (GetCVar ("nameplateShowEnemyMinions"))-1))
                else
                    Plater:Msg (L["OPTIONS_ERROR_CVARMODIFY"])
                    self:SetValue (GetCVar ("nameplateShowEnemyMinions") == CVAR_ENABLED)
                end
            end,
            name = "@OPTIONS_ADVANCED_UNIT_SHOW_ENEMY_MINIONS@" .. CVarIcon,
            descPhraseId = "@OPTIONS_ADVANCED_UNIT_SHOW_ENEMY_MINIONS_DESC@" .. CVarDesc,
            nocombat = true,
        },

        {
            type = "toggle",
            get = function() return GetCVar ("nameplateShowEnemyMinus") == CVAR_ENABLED end,
            set = function (self, fixedparam, value)
                if (not InCombatLockdown()) then
                    SetCVar ("nameplateShowEnemyMinus", math.abs (tonumber (GetCVar ("nameplateShowEnemyMinus"))-1))
                else
                    Plater:Msg (L["OPTIONS_ERROR_CVARMODIFY"])
                    self:SetValue (GetCVar ("nameplateShowEnemyMinus") == CVAR_ENABLED)
                end
            end,
            name = "@OPTIONS_ADVANCED_UNIT_SHOW_ENEMY_MINOR_UNITS@" .. CVarIcon,
            descPhraseId = "@OPTIONS_ADVANCED_UNIT_SHOW_ENEMY_MINOR_UNITS_DESC@" .. CVarDesc,
            nocombat = true,
        },

        {
            type = "toggle",
            get = function() return GetCVar ("nameplateShowEnemyPets") == CVAR_ENABLED end,
            set = function (self, fixedparam, value)
                if (not InCombatLockdown()) then
                    SetCVar ("nameplateShowEnemyPets", math.abs (tonumber (GetCVar ("nameplateShowEnemyPets"))-1))
                else
                    Plater:Msg (L["OPTIONS_ERROR_CVARMODIFY"])
                    self:SetValue (GetCVar ("nameplateShowEnemyPets") == CVAR_ENABLED)
                end
            end,
            name = "@OPTIONS_ADVANCED_UNIT_SHOW_ENEMY_PETS@" .. CVarIcon,
            descPhraseId = "@OPTIONS_ADVANCED_UNIT_SHOW_ENEMY_PETS_DESC@" .. CVarDesc,
            nocombat = true,
        },

        {
            type = "toggle",
            get = function() return GetCVar ("nameplateShowEnemyTotems") == CVAR_ENABLED end,
            set = function (self, fixedparam, value)
                if (not InCombatLockdown()) then
                    SetCVar ("nameplateShowEnemyTotems", math.abs (tonumber (GetCVar ("nameplateShowEnemyTotems"))-1))
                else
                    Plater:Msg (L["OPTIONS_ERROR_CVARMODIFY"])
                    self:SetValue (GetCVar ("nameplateShowEnemyTotems") == CVAR_ENABLED)
                end
            end,
            name = "@OPTIONS_ADVANCED_UNIT_SHOW_ENEMY_TOTEMS@" .. CVarIcon,
            descPhraseId = "@OPTIONS_ADVANCED_UNIT_SHOW_ENEMY_TOTEMS_DESC@" .. CVarDesc,
            nocombat = true,
        },

        {type = "blank"},

        {
            type = "toggle",
            get = function() return GetCVar ("nameplateShowFriendlyNPCs") == CVAR_ENABLED end,
            set = function (self, fixedparam, value)
                if (not InCombatLockdown()) then
                    SetCVar ("nameplateShowFriendlyNPCs", math.abs (tonumber (GetCVar ("nameplateShowFriendlyNPCs"))-1))
                else
                    Plater:Msg (L["OPTIONS_ERROR_CVARMODIFY"])
                    self:SetValue (GetCVar ("nameplateShowFriendlyNPCs") == CVAR_ENABLED)
                end
            end,
            name = "@OPTIONS_ADVANCED_UNIT_SHOW_FRIENDLY_NPCS@" .. CVarIcon,
            descPhraseId = "@OPTIONS_ADVANCED_UNIT_SHOW_FRIENDLY_NPCS_DESC@" .. CVarDesc,
            nocombat = true,
        },

        {
            type = "toggle",
            get = function() return GetCVar ("nameplateShowFriendlyGuardians") == CVAR_ENABLED end,
            set = function (self, fixedparam, value)
                if (not InCombatLockdown()) then
                    SetCVar ("nameplateShowFriendlyGuardians", math.abs (tonumber (GetCVar ("nameplateShowFriendlyGuardians"))-1))
                else
                    Plater:Msg (L["OPTIONS_ERROR_CVARMODIFY"])
                    self:SetValue (GetCVar ("nameplateShowFriendlyGuardians") == CVAR_ENABLED)
                end
            end,
            name = "@OPTIONS_ADVANCED_UNIT_SHOW_FRIENDLY_GUARDIANS@" .. CVarIcon,
            descPhraseId = "@OPTIONS_ADVANCED_UNIT_SHOW_FRIENDLY_GUARDIANS_DESC@" .. CVarDesc,
            nocombat = true,
            hidden = IS_WOW_PROJECT_MIDNIGHT,
        },

        {
            type = "toggle",
            get = function() return GetCVar ("nameplateShowFriendlyMinions") == CVAR_ENABLED end,
            set = function (self, fixedparam, value)
                if (not InCombatLockdown()) then
                    SetCVar ("nameplateShowFriendlyMinions", math.abs (tonumber (GetCVar ("nameplateShowFriendlyMinions"))-1))
                else
                    Plater:Msg (L["OPTIONS_ERROR_CVARMODIFY"])
                    self:SetValue (GetCVar ("nameplateShowFriendlyMinions") == CVAR_ENABLED)
                end
            end,
            name = "@OPTIONS_ADVANCED_UNIT_SHOW_FRIENDLY_MINIONS@" .. CVarIcon,
            descPhraseId = "@OPTIONS_ADVANCED_UNIT_SHOW_FRIENDLY_MINIONS_DESC@" .. CVarDesc,
            nocombat = true,
            hidden = IS_WOW_PROJECT_MIDNIGHT,
        },

        {
            type = "toggle",
            get = function() return GetCVar ("nameplateShowFriendlyPets") == CVAR_ENABLED end,
            set = function (self, fixedparam, value)
                if (not InCombatLockdown()) then
                    SetCVar ("nameplateShowFriendlyPets", math.abs (tonumber (GetCVar ("nameplateShowFriendlyPets"))-1))
                else
                    Plater:Msg (L["OPTIONS_ERROR_CVARMODIFY"])
                    self:SetValue (GetCVar ("nameplateShowFriendlyPets") == CVAR_ENABLED)
                end
            end,
            name = "@OPTIONS_ADVANCED_UNIT_SHOW_FRIENDLY_PETS@" .. CVarIcon,
            descPhraseId = "@OPTIONS_ADVANCED_UNIT_SHOW_FRIENDLY_PETS_DESC@" .. CVarDesc,
            nocombat = true,
            hidden = IS_WOW_PROJECT_MIDNIGHT,
        },

        {
            type = "toggle",
            get = function() return GetCVar ("nameplateShowFriendlyTotems") == CVAR_ENABLED end,
            set = function (self, fixedparam, value)
                if (not InCombatLockdown()) then
                    SetCVar ("nameplateShowFriendlyTotems", math.abs (tonumber (GetCVar ("nameplateShowFriendlyTotems"))-1))
                else
                    Plater:Msg (L["OPTIONS_ERROR_CVARMODIFY"])
                    self:SetValue (GetCVar ("nameplateShowFriendlyTotems") == CVAR_ENABLED)
                end
            end,
            name = "@OPTIONS_ADVANCED_UNIT_SHOW_FRIENDLY_TOTEMS@" .. CVarIcon,
            descPhraseId = "@OPTIONS_ADVANCED_UNIT_SHOW_FRIENDLY_TOTEMS_DESC@" .. CVarDesc,
            nocombat = true,
            hidden = IS_WOW_PROJECT_MIDNIGHT,
        },
        
        {
            type = "toggle",
            get = function() return GetCVar ("nameplateShowFriendlyPlayers") == CVAR_ENABLED end,
            set = function (self, fixedparam, value)
                if (not InCombatLockdown()) then
                    SetCVar ("nameplateShowFriendlyPlayers", math.abs (tonumber (GetCVar ("nameplateShowFriendlyPlayers"))-1))
                else
                    Plater:Msg (L["OPTIONS_ERROR_CVARMODIFY"])
                    self:SetValue (GetCVar ("nameplateShowFriendlyPlayers") == CVAR_ENABLED)
                end
            end,
            name = "@OPTIONS_ADVANCED_UNIT_SHOW_FRIENDLY_PLAYERS@" .. CVarIcon,
            descPhraseId = "@OPTIONS_ADVANCED_UNIT_SHOW_FRIENDLY_PLAYERS_DESC@" .. CVarDesc,
            nocombat = true,
            hidden = not IS_WOW_PROJECT_MIDNIGHT,
        },
        
        {
            type = "toggle",
            get = function() return GetCVar ("nameplateShowFriendlyPlayerGuardians") == CVAR_ENABLED end,
            set = function (self, fixedparam, value)
                if (not InCombatLockdown()) then
                    SetCVar ("nameplateShowFriendlyPlayerGuardians", math.abs (tonumber (GetCVar ("nameplateShowFriendlyPlayerGuardians"))-1))
                else
                    Plater:Msg (L["OPTIONS_ERROR_CVARMODIFY"])
                    self:SetValue (GetCVar ("nameplateShowFriendlyPlayerGuardians") == CVAR_ENABLED)
                end
            end,
            name = "@OPTIONS_ADVANCED_UNIT_SHOW_FRIENDLY_GUARDIANS@" .. CVarIcon,
            descPhraseId = "@OPTIONS_ADVANCED_UNIT_SHOW_FRIENDLY_GUARDIANS_DESC@" .. CVarDesc,
            nocombat = true,
            hidden = not IS_WOW_PROJECT_MIDNIGHT,
        },

        {
            type = "toggle",
            get = function() return GetCVar ("nameplateShowFriendlyMinions") == CVAR_ENABLED end,
            set = function (self, fixedparam, value)
                if (not InCombatLockdown()) then
                    SetCVar ("nameplateShowFriendlyPlayerMinions", math.abs (tonumber (GetCVar ("nameplateShowFriendlyPlayerMinions"))-1))
                else
                    Plater:Msg (L["OPTIONS_ERROR_CVARMODIFY"])
                    self:SetValue (GetCVar ("nameplateShowFriendlyPlayerMinions") == CVAR_ENABLED)
                end
            end,
            name = "@OPTIONS_ADVANCED_UNIT_SHOW_FRIENDLY_MINIONS@" .. CVarIcon,
            descPhraseId = "@OPTIONS_ADVANCED_UNIT_SHOW_FRIENDLY_MINIONS_DESC@" .. CVarDesc,
            nocombat = true,
            hidden = not IS_WOW_PROJECT_MIDNIGHT,
        },

        {
            type = "toggle",
            get = function() return GetCVar ("nameplateShowFriendlyPlayerPets") == CVAR_ENABLED end,
            set = function (self, fixedparam, value)
                if (not InCombatLockdown()) then
                    SetCVar ("nameplateShowFriendlyPlayerPets", math.abs (tonumber (GetCVar ("nameplateShowFriendlyPlayerPets"))-1))
                else
                    Plater:Msg (L["OPTIONS_ERROR_CVARMODIFY"])
                    self:SetValue (GetCVar ("nameplateShowFriendlyPlayerPets") == CVAR_ENABLED)
                end
            end,
            name = "@OPTIONS_ADVANCED_UNIT_SHOW_FRIENDLY_PETS@" .. CVarIcon,
            descPhraseId = "@OPTIONS_ADVANCED_UNIT_SHOW_FRIENDLY_PETS_DESC@" .. CVarDesc,
            nocombat = true,
            hidden = not IS_WOW_PROJECT_MIDNIGHT,
        },

        {
            type = "toggle",
            get = function() return GetCVar ("nameplateShowFriendlyPlayerTotems") == CVAR_ENABLED end,
            set = function (self, fixedparam, value)
                if (not InCombatLockdown()) then
                    SetCVar ("nameplateShowFriendlyPlayerTotems", math.abs (tonumber (GetCVar ("nameplateShowFriendlyPlayerTotems"))-1))
                else
                    Plater:Msg (L["OPTIONS_ERROR_CVARMODIFY"])
                    self:SetValue (GetCVar ("nameplateShowFriendlyPlayerTotems") == CVAR_ENABLED)
                end
            end,
            name = "@OPTIONS_ADVANCED_UNIT_SHOW_FRIENDLY_TOTEMS@" .. CVarIcon,
            descPhraseId = "@OPTIONS_ADVANCED_UNIT_SHOW_FRIENDLY_TOTEMS_DESC@" .. CVarDesc,
            nocombat = true,
            hidden = not IS_WOW_PROJECT_MIDNIGHT,
        },

        {type = "blank"},
        {type = "label", get = function() return "OPTIONS_ADVANCED_HEADER_BLIZZARD_NAMEPLATE_FONTS" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
        {
            type = "toggle",
            get = function() return Plater.db.profile.blizzard_nameplate_font_override_enabled end,
            set = function (self, fixedparam, value)
                Plater.db.profile.blizzard_nameplate_font_override_enabled = value
            end,
            name = L["OPTIONS_ENABLED"],
            descPhraseId = "@OPTIONS_ADVANCED_ENABLE_BLIZZARD_NAMEPLATE_FONT_OVERRIDE_DESC@" .. CVarNeedReload,
        },
        {type = "label", get = function() return "OPTIONS_ADVANCED_HEADER_FONT_NORMAL" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
        {
            type = "select",
            get = function() return Plater.db.profile.blizzard_nameplate_font end,
            values = function() return DF:BuildDropDownFontList (on_select_blizzard_nameplate_font) end,
            name = L["OPTIONS_FONT"],
            descPhraseId = "@OPTIONS_TEXT_FONT@" .. CVarNeedReload,
        },
        {
            type = "range",
            get = function() return Plater.db.profile.blizzard_nameplate_font_size end,
            set = function (self, fixedparam, value) Plater.db.profile.blizzard_nameplate_font_size = value end,
            min = 6,
            max = 24,
            step = 1,
            name = L["OPTIONS_SIZE"],
            descPhraseId = "@OPTIONS_SIZE@" .. CVarNeedReload,
        },
        {
            type = "select",
            get = function() return Plater.db.profile.blizzard_nameplate_font_outline end,
            values = function() return build_outline_modes_table (nil, "blizzard_nameplate_font_outline") end,
            name = L["OPTIONS_OUTLINE"],
            descPhraseId = "@OPTIONS_OUTLINE@" .. CVarNeedReload,
        },
        {type = "label", get = function() return "OPTIONS_ADVANCED_HEADER_FONT_LARGE" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
        {
            type = "select",
            get = function() return Plater.db.profile.blizzard_nameplate_large_font end,
            values = function() return DF:BuildDropDownFontList (on_select_blizzard_nameplate_large_font) end,
            name = L["OPTIONS_FONT"],
            descPhraseId = "@OPTIONS_TEXT_FONT@" .. CVarNeedReload,
        },
        {
            type = "range",
            get = function() return Plater.db.profile.blizzard_nameplate_large_font_size end,
            set = function (self, fixedparam, value) Plater.db.profile.blizzard_nameplate_large_font_size = value end,
            min = 6,
            max = 24,
            step = 1,
            name = L["OPTIONS_SIZE"],
            descPhraseId = "@OPTIONS_SIZE@" .. CVarNeedReload,
        },
        {
            type = "select",
            get = function() return Plater.db.profile.blizzard_nameplate_large_font_outline end,
            values = function() return build_outline_modes_table (nil, "blizzard_nameplate_large_font_outline") end,
            name = L["OPTIONS_OUTLINE"],
            descPhraseId = "@OPTIONS_OUTLINE@" .. CVarNeedReload,
        },

        --{type = "breakline"},

        {type = "blank"},

        --can't go up to 100 pixels deviation due to the clicable space from the plateFrame
        --if it goes more than the plateFrame area it generates areas where isn't clicable
        {type = "label", get = function() return "OPTIONS_ADVANCED_HEADER_GLOBAL_OFFSET" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
        {
            type = "range",
            get = function() return Plater.db.profile.global_offset_x end,
            set = function (self, fixedparam, value)
                Plater.db.profile.global_offset_x = value
                Plater.UpdateAllPlates()
                Plater.UpdatePlateClickSpace (nil, true)
            end,
            min = -20,
            max = 20,
            step = 1,
            usedecimals = true,
            name = "OPTIONS_XOFFSET",
            desc = "OPTIONS_NAMEPLATE_OFFSET",
        },
        {
            type = "range",
            get = function() return Plater.db.profile.global_offset_y end,
            set = function (self, fixedparam, value)
                Plater.db.profile.global_offset_y = value
                Plater.UpdateAllPlates()
                Plater.UpdatePlateClickSpace (nil, true)
            end,
            min = -20,
            max = 20,
            step = 1,
            usedecimals = true,
            name = "OPTIONS_YOFFSET",
            desc = "OPTIONS_NAMEPLATE_OFFSET",
        },

        {type = "blank"},

        {type = "label", get = function() return "OPTIONS_ADVANCED_HEADER_SPECIAL_UNITS" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},

        {
            type = "range",
            get = function() return Plater.db.profile.pet_width_scale end,
            set = function (self, fixedparam, value)
                Plater.db.profile.pet_width_scale = value
                Plater.UpdateAllPlates()
            end,
            min = 0.2,
            max = 2,
            step = 0.1,
            name = "OPTIONS_PET_SCALE_WIDTH",
            desc = "OPTIONS_PET_SCALE_DESC",
            usedecimals = true,
        },
        {
            type = "range",
            get = function() return Plater.db.profile.pet_height_scale end,
            set = function (self, fixedparam, value)
                Plater.db.profile.pet_height_scale = value
                Plater.UpdateAllPlates()
            end,
            min = 0.2,
            max = 2,
            step = 0.1,
            name = "OPTIONS_PET_SCALE_HEIGHT",
            desc = "OPTIONS_PET_SCALE_DESC",
            usedecimals = true,
        },
        {
            type = "range",
            get = function() return Plater.db.profile.minor_width_scale end,
            set = function (self, fixedparam, value)
                Plater.db.profile.minor_width_scale = value
                Plater.UpdateAllPlates()
            end,
            min = 0.2,
            max = 2,
            step = 0.1,
            name = "OPTIONS_MINOR_SCALE_WIDTH",
            desc = "OPTIONS_MINOR_SCALE_DESC",
            usedecimals = true,
        },
        {
            type = "range",
            get = function() return Plater.db.profile.minor_height_scale end,
            set = function (self, fixedparam, value)
                Plater.db.profile.minor_height_scale = value
                Plater.UpdateAllPlates()
            end,
            min = 0.2,
            max = 2,
            step = 0.1,
            name = "OPTIONS_MINOR_SCALE_HEIGHT",
            desc = "OPTIONS_MINOR_SCALE_DESC",
            usedecimals = true,
        },

        {type = "breakline"},
        {type = "label", get = function() return "OPTIONS_ADVANCED_HEADER_REGION" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},

        {
            type = "select",
            get = function() return Plater.db.profile.number_region end,
            values = function() return build_number_format_options() end,
            name = "OPTIONS_FORMAT_NUMBER",
            desc = "OPTIONS_FORMAT_NUMBER",
        },

        {type = "label", get = function() return "OPTIONS_ADVANCED_HEADER_MISC" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},

        {
            type = "toggle",
            get = function() return Plater.db.profile.show_health_prediction end,
            set = function (self, fixedparam, value)
                Plater.db.profile.show_health_prediction = value
            end,
            name = "OPTIONS_ADVANCED_SHOW_HEALTH_PREDICTION_ABSORPTION",
            desc = "OPTIONS_ADVANCED_SHOW_HEALTH_PREDICTION_ABSORPTION_DESC",
        },
        {
            type = "toggle",
            get = function() return Plater.db.profile.show_shield_prediction end,
            set = function (self, fixedparam, value)
                Plater.db.profile.show_shield_prediction = value
            end,
            name = "OPTIONS_ADVANCED_SHOW_SHIELD_PREDICTION",
            desc = "OPTIONS_ADVANCED_SHOW_SHIELD_PREDICTION_DESC",
        },

        {
            type = "toggle",
            get = function() return Plater.db.profile.enable_masque_support end,
            set = function (self, fixedparam, value)
                Plater.db.profile.enable_masque_support = value
                Plater:Msg (L["OPTIONS_ADVANCED_SETTING_REQUIRES_RELOAD"])
            end,
            name = "OPTIONS_ADVANCED_MASQUE_SUPPORT",
            desc = "OPTIONS_ADVANCED_MASQUE_SUPPORT_DESC",
        },

        {
            type = "toggle",
            get = function() return Plater.db.profile.use_name_translit end,
            set = function (self, fixedparam, value)
                Plater.db.profile.use_name_translit = value
                Plater.RefreshDBUpvalues()
                Plater.FullRefreshAllPlates()
            end,
            name = "OPTIONS_ADVANCED_NAME_TRANSLIT",
            desc = "OPTIONS_ADVANCED_NAME_TRANSLIT_DESC",
        },

        {
            type = "toggle",
            get = function() return Plater.db.profile.use_player_combat_state end,
            set = function (self, fixedparam, value)
                Plater.db.profile.use_player_combat_state = value
            end,
            name = "OPTIONS_ADVANCED_IN_OUT_COMBAT_USE_PLAYER_COMBAT_STATE",
            desc = "OPTIONS_ADVANCED_IN_OUT_COMBAT_USE_PLAYER_COMBAT_STATE_DESC",
        },

        {
            type = "toggle",
            get = function() return Plater.db.profile.opt_out_auto_accept_npc_colors end,
            set = function (self, fixedparam, value)
                Plater.db.profile.opt_out_auto_accept_npc_colors = value
            end,
            name = "OPTIONS_ADVANCED_OPT_OUT_AUTO_ACCEPT_NPC_COLORS",
            desc = "OPTIONS_ADVANCED_OPT_OUT_AUTO_ACCEPT_NPC_COLORS_DESC",
        },
        {
            type = "toggle",
            get = function() return Plater.db.profile.auto_translate_npc_names end,
            set = function (self, fixedparam, value)
                Plater.db.profile.auto_translate_npc_names = value
                Plater.TranslateNPCCache()
            end,
            name = "OPTIONS_ADVANCED_AUTO_TRANSLATE_NPC_NAMES_ON_NPC_COLORS_TAB",
            desc = "OPTIONS_ADVANCED_AUTO_TRANSLATE_NPC_NAMES_ON_NPC_COLORS_TAB_DESC",
        },

        {type = "blank"},
        {type = "label", get = function() return "OPTIONS_ADVANCED_HEADER_PERSONAL_BAR_CUSTOM_POSITION" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"), hidden = IS_WOW_PROJECT_NOT_MAINLINE or IS_WOW_PROJECT_MIDNIGHT},
        {
            type = "range",
            get = function() return tonumber (GetCVar ("nameplateSelfTopInset")*100) end,
            set = function (self, fixedparam, value)
                --Plater.db.profile.plate_config.player.y_position_offset = value

                if (InCombatLockdown()) then
                    Plater:Msg (L["OPTIONS_ERROR_CVARMODIFY"])
                    self:SetValue (tonumber (GetCVar ("nameplateSelfTopInset")*100))
                    return
                end

                --SetCVar ("nameplateSelfBottomInset", value / 100)
                SetCVar ("nameplateSelfTopInset", abs (value - 99) / 100)

                if (not Plater.PersonalAdjustLocationTop) then
                    Plater.PersonalAdjustLocationTop = CreateFrame ("frame", "PlaterPersonalBarLocation", UIParent, BackdropTemplateMixin and "BackdropTemplate")
                    local frame = Plater.PersonalAdjustLocationTop
                    frame:SetWidth (GetScreenWidth())
                    frame:SetHeight (20)
                    frame.Texture = frame:CreateTexture (nil, "background")
                    frame.Texture:SetTexture ([[Interface\AddOns\Plater\images\bar4_vidro]], true)
                    frame.Texture:SetAllPoints()
                    frame.Shadow = frame:CreateTexture (nil, "border")
                    frame.Shadow:SetTexture ([[Interface\ACHIEVEMENTFRAME\UI-Achievement-RecentHeader]], true)
                    frame.Shadow:SetPoint ("center")
                    frame.Shadow:SetSize (256, 18)
                    frame.Shadow:SetTexCoord (0, 1, 0, 22/32)
                    frame.Shadow:SetVertexColor (0, 0, 0, 1)
                    frame.Text = frame:CreateFontString (nil, "artwork", "GameFontNormal")
                    frame.Text:SetText (L["OPTIONS_ADVANCED_PERSONAL_BAR_TOP_CONSTRAINT_TEXT"])
                    frame.Text:SetPoint ("center")

                    frame.HideAnimation = DF:CreateAnimationHub (frame, nil, function() frame:Hide() end)
                    DF:CreateAnimation (frame.HideAnimation, "Alpha", 1, 1, 1, 0)

                    frame.CancelFunction = function()
                        frame.HideAnimation:Play()
                    end
                end

                if (Plater.PersonalAdjustLocationTop.HideAnimation:IsPlaying()) then
                    Plater.PersonalAdjustLocationTop.HideAnimation:Stop()
                    Plater.PersonalAdjustLocationTop:SetAlpha (1)
                end
                Plater.PersonalAdjustLocationTop:Show()

                local percentValue = GetScreenHeight()/100
                Plater.PersonalAdjustLocationTop:SetPoint ("bottom", UIParent, "bottom", 0, percentValue * value)

                if (Plater.PersonalAdjustLocationTop.Timer) then
                    Plater.PersonalAdjustLocationTop.Timer:Cancel()
                end
                Plater.PersonalAdjustLocationTop.Timer = C_Timer.NewTimer (10, Plater.PersonalAdjustLocationTop.CancelFunction)

                Plater.UpdateAllPlates()
                Plater.UpdateSelfPlate()
            end,
            min = 2,
            max = 51,
            step = 1,
            nocombat = true,
            name = "@OPTIONS_ADVANCED_TOP_CONSTRAIN@" .. CVarIcon,
            descPhraseId = "@OPTIONS_ADVANCED_TOP_CONSTRAIN_DESC@" .. CVarDesc,
            hidden = IS_WOW_PROJECT_NOT_MAINLINE or IS_WOW_PROJECT_MIDNIGHT,
        },

        {
            type = "range",
            get = function() return tonumber (GetCVar ("nameplateSelfBottomInset")*100) end,
            set = function (self, fixedparam, value)
                --Plater.db.profile.plate_config.player.y_position_offset = value

                if (InCombatLockdown()) then
                    Plater:Msg (L["OPTIONS_ERROR_CVARMODIFY"])
                    self:SetValue (tonumber (GetCVar ("nameplateSelfBottomInset")*100))
                    return
                end

                SetCVar ("nameplateSelfBottomInset", value / 100)
                --SetCVar ("nameplateSelfTopInset", value / 100)

                if (not Plater.PersonalAdjustLocationBottom) then
                    Plater.PersonalAdjustLocationBottom = CreateFrame ("frame", "PlaterPersonalBarLocation", UIParent, BackdropTemplateMixin and "BackdropTemplate")
                    local frame = Plater.PersonalAdjustLocationBottom
                    frame:SetWidth (GetScreenWidth())
                    frame:SetHeight (20)
                    frame.Texture = frame:CreateTexture (nil, "background")
                    frame.Texture:SetTexture ([[Interface\AddOns\Plater\images\bar4_vidro]], true)
                    frame.Texture:SetAllPoints()
                    frame.Shadow = frame:CreateTexture (nil, "border")
                    frame.Shadow:SetTexture ([[Interface\ACHIEVEMENTFRAME\UI-Achievement-RecentHeader]], true)
                    frame.Shadow:SetPoint ("center")
                    frame.Shadow:SetSize (256, 18)
                    frame.Shadow:SetTexCoord (0, 1, 0, 22/32)
                    frame.Shadow:SetVertexColor (0, 0, 0, 1)
                    frame.Text = frame:CreateFontString (nil, "artwork", "GameFontNormal")
                    frame.Text:SetText (L["OPTIONS_ADVANCED_PERSONAL_BAR_BOTTOM_CONSTRAINT_TEXT"])
                    frame.Text:SetPoint ("center")

                    frame.HideAnimation = DF:CreateAnimationHub (frame, nil, function() frame:Hide() end)
                    DF:CreateAnimation (frame.HideAnimation, "Alpha", 1, 1, 1, 0)

                    frame.CancelFunction = function()
                        frame.HideAnimation:Play()
                    end
                end

                if (Plater.PersonalAdjustLocationBottom.HideAnimation:IsPlaying()) then
                    Plater.PersonalAdjustLocationBottom.HideAnimation:Stop()
                    Plater.PersonalAdjustLocationBottom:SetAlpha (1)
                end
                Plater.PersonalAdjustLocationBottom:Show()

                local percentValue = GetScreenHeight()/100
                Plater.PersonalAdjustLocationBottom:SetPoint ("bottom", UIParent, "bottom", 0, percentValue * value)

                if (Plater.PersonalAdjustLocationBottom.Timer) then
                    Plater.PersonalAdjustLocationBottom.Timer:Cancel()
                end
                Plater.PersonalAdjustLocationBottom.Timer = C_Timer.NewTimer (10, Plater.PersonalAdjustLocationBottom.CancelFunction)

                Plater.UpdateAllPlates()
                Plater.UpdateSelfPlate()
            end,
            min = 2,
            max = 51,
            step = 1,
            nocombat = true,
            name = "@OPTIONS_ADVANCED_BOTTOM_CONSTRAIN@" .. CVarIcon,
            descPhraseId = "@OPTIONS_ADVANCED_BOTTOM_CONSTRAIN_DESC@" .. CVarDesc,
            hidden = IS_WOW_PROJECT_NOT_MAINLINE or IS_WOW_PROJECT_MIDNIGHT,
        },

        {type = "blank", hidden = IS_WOW_PROJECT_MIDNIGHT},
        {type = "label", get = function() return "OPTIONS_ADVANCED_HEADER_ANIMATIONS" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE") }, --, hidden = IS_WOW_PROJECT_MIDNIGHT},

        {
            type = "toggle",
            get = function() return Plater.db.profile.use_health_animation end,
            set = function (self, fixedparam, value)
                Plater.db.profile.use_health_animation = value
                Plater.RefreshDBUpvalues()
                Plater.UpdateAllPlates()
            end,
            name = "OPTIONS_ADVANCED_ANIMATE_HEALTH_BAR",
            desc = "OPTIONS_ADVANCED_ANIMATE_HEALTH_BAR_DESC",
            --hidden = IS_WOW_PROJECT_MIDNIGHT,
        },
        {
            type = "toggle",
            get = function() return Plater.db.profile.use_color_lerp end,
            set = function (self, fixedparam, value)
                Plater.db.profile.use_color_lerp = value
                Plater.RefreshDBUpvalues()
                Plater.UpdateAllPlates()
            end,
            name = "OPTIONS_ADVANCED_ANIMATE_COLOR_TRANSITIONS",
            desc = "OPTIONS_ADVANCED_ANIMATE_COLOR_TRANSITIONS_DESC",
            hidden = IS_WOW_PROJECT_MIDNIGHT,
        },
        {
            type = "range",
            get = function() return Plater.db.profile.health_animation_time_dilatation end,
            set = function (self, fixedparam, value)
                Plater.db.profile.health_animation_time_dilatation = value
                Plater.RefreshDBUpvalues()
                Plater.DebugHealthAnimation()
            end,
            min = 0.35,
            max = 5,
            step = 0.1,
            usedecimals = true,
            thumbscale = 1.7,
            name = "OPTIONS_ADVANCED_HEALTH_BAR_ANIMATION_SPEED",
            desc = "OPTIONS_ADVANCED_ANIMATION_SPEED_DESC",
            hidden = IS_WOW_PROJECT_MIDNIGHT,
        },
        {
            type = "range",
            get = function() return Plater.db.profile.color_lerp_speed end,
            set = function (self, fixedparam, value)
                Plater.db.profile.color_lerp_speed = value
                Plater.RefreshDBUpvalues()
                Plater.DebugColorAnimation()
            end,
            min = 1,
            max = 50,
            step = 1,
            name = "OPTIONS_ADVANCED_COLOR_ANIMATION_SPEED",
            desc = "OPTIONS_ADVANCED_ANIMATION_SPEED_DESC",
            hidden = IS_WOW_PROJECT_MIDNIGHT,
        },

        {type = "blank"},

        {type = "label", get = function() return "OPTIONS_ADVANCED_HEADER_UNIT_WIDGET_BARS" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"), hidden = IS_WOW_PROJECT_NOT_MAINLINE},
        {
            type = "range",
            get = function() return Plater.db.profile.widget_bar_scale end,
            set = function (self, fixedparam, value)
                Plater.db.profile.widget_bar_scale = value
                Plater.UpdateAllPlates()
            end,
            min = 0.2,
            max = 2,
            step = 0.1,
            name = "OPTIONS_SCALE",
            desc = "OPTIONS_ADVANCED_WIDGET_BAR_SCALE_DESC",
            usedecimals = true,
            hidden = IS_WOW_PROJECT_NOT_MAINLINE,
        },
        {
            type = "select",
            get = function() return Plater.db.profile.widget_bar_anchor.side end,
            values = function() return build_anchor_side_table (nil, "widget_bar_anchor") end,
            name = "OPTIONS_ANCHOR",
            desc = "OPTIONS_ADVANCED_WIDGET_BAR_ANCHOR_DESC",
            hidden = IS_WOW_PROJECT_NOT_MAINLINE,
        },
        {
            type = "range",
            get = function() return Plater.db.profile.widget_bar_anchor.x end,
            set = function (self, fixedparam, value)
                Plater.db.profile.widget_bar_anchor.x = value
                Plater.UpdateAllPlates()
            end,
            min = -20,
            max = 20,
            step = 1,
            usedecimals = true,
            name = "OPTIONS_XOFFSET",
            desc = "OPTIONS_XOFFSET_DESC",
            hidden = IS_WOW_PROJECT_NOT_MAINLINE,
        },
        {
            type = "range",
            get = function() return Plater.db.profile.widget_bar_anchor.y end,
            set = function (self, fixedparam, value)
                Plater.db.profile.widget_bar_anchor.y = value
                Plater.UpdateAllPlates()
            end,
            min = -20,
            max = 20,
            step = 1,
            usedecimals = true,
            name = "OPTIONS_YOFFSET",
            desc = "OPTIONS_YOFFSET_DESC",
            hidden = IS_WOW_PROJECT_NOT_MAINLINE,
        },
    }

    ---@diagnostic disable-next-line: undefined-global
    local advancedFrame = PlaterOptionsPanelContainerAdvancedConfig

    advanced_options.align_as_pairs = true
    advanced_options.align_as_pairs_string_space = 181
    advanced_options.widget_width = 150
    advanced_options.use_scrollframe = true
    advanced_options.language_addonId = addonId
    advanced_options.always_boxfirst = true
    advanced_options.Name = L["OPTIONS_ADVANCED_OPTIONS_TITLE"]

    local canvasFrame = DF:CreateCanvasScrollBox(advancedFrame, nil, "PlaterOptionsPanelCanvasAdvancedSettings")
    canvasFrame:SetPoint("topleft", advancedFrame, "topleft", 0, platerInternal.optionsYStart)
    canvasFrame:SetPoint("bottomright", advancedFrame, "bottomright", -26, 25)
    advancedFrame.canvasFrame = canvasFrame

    --when passing a canvas frame for BuildMenu, it automatically get its childscroll and use as parent for the widgets
    --DF:BuildMenu(canvasFrame, debuff_options, startX, 0, heightSize, false, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template, globalCallback)

    local startX, startY, heightSize = 10, platerInternal.optionsYStart, 755
    --DF:BuildMenu (advancedFrame, advanced_options, startX, startY, heightSize, false, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template, platerInternal.OptionsGlobalCallback)
    DF:BuildMenu (canvasFrame, advanced_options, startX, 0, heightSize, false, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template, platerInternal.OptionsGlobalCallback)

    platerInternal.LoadOnDemand_IsLoaded.AdvancedOptions = true
    ---@diagnostic disable-next-line: undefined-global
    table.insert(PlaterOptionsPanelFrame.AllSettingsTable, advanced_options)
    platerInternal.CreateAdvancedOptions = function() end
end
