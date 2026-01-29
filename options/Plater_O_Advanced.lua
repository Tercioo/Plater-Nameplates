
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

    local nameplate_anchor_options = {
        {label = "Head", value = 0, onclick = Plater.ChangeNameplateAnchor, desc = "All nameplates are placed above the character."},
        {label = "Head/Feet", value = 1, onclick = Plater.ChangeNameplateAnchor, desc = "Friendly and neutral has the nameplate on their head, enemies below the feet."},
        {label = "Feet", value = 2, onclick = Plater.ChangeNameplateAnchor, desc = "All nameplates are placed below the character."},
    }

    --cvars
    local CVAR_ENABLED = "1"
    local CVAR_DISABLED = "0"
    local CVAR_MOVEMENT_SPEED = "nameplateMotionSpeed"

    ---@diagnostic disable-next-line: undefined-global
    local IS_WOW_PROJECT_MAINLINE = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
    ---@diagnostic disable-next-line: undefined-global
    local IS_WOW_PROJECT_NOT_MAINLINE = WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE

    local L = DF.Language.GetLanguageTable(addonId)

    local CVarDesc = "\n\n|cFFFF7700[*]|r |cFFa0a0a0" .. L["CVar, saved within Plater profile and restored when loading the profile."] .. "|r"
    local CVarIcon = "|cFFFF7700*|r"
    local CVarNeedReload = "\n\n|cFFFF2200[*]|r |cFFa0a0a0" .. L["A /reload may be required to take effect."] .. "|r"

    local dropdownStatusBarTexture = platerInternal.Defaults.dropdownStatusBarTexture
    local dropdownStatusBarColor = platerInternal.Defaults.dropdownStatusBarColor

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

    local build_number_format_options = function()
        local number_format_options = {"Western (1K - 1KK)"}
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
            tinsert (t, {
                label = number_format_options [i],
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
        {type = "label", name = "LABEL_GENERAL_SETTINGS", text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},

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
            name = "OPTIONS_UPDATE_INTERVAL",
            usedecimals = true,
            desc = "Time interval in seconds between each update on the nameplate.\n\n|cFFFFFFFFDefault: 0.25|r (4 updates every second).",
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
            name = "OPTIONS_QUICK_HIDE_ON_DEATH",
            desc = "When the unit dies, immediately hide the nameplates without playing the shrink animation.",
        },

        {
            type = "toggle",
            get = function() return Plater.db.profile.show_healthbars_on_not_attackable end,
            set = function (self, fixedparam, value)
                Plater.db.profile.show_healthbars_on_not_attackable = value
                Plater.UpdateAllPlates()
            end,
            name = "OPTIONS_SHOW_HEALTHBARS_NOT_ATTACKABLE",
            desc = "Show Healthbars on not attackable units instead of defaulting to 'name only'.",
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
            name = "@OPTIONS_SHOW_SOFT_INTERACT_OBJECTS@" .. CVarIcon,
            desc = "Show soft-interact on game objects." .. CVarDesc,
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
            name = "@OPTIONS_FORCE_NAMEPLATES_SOFT_INTERACT@" .. CVarIcon,
            desc = "Force show the nameplate on your soft-interact target." .. CVarDesc,
        },
        {
            type = "toggle",
            get = function() return Plater.db.profile.show_healthbars_on_softinteract end,
            set = function (self, fixedparam, value)
                Plater.db.profile.show_healthbars_on_softinteract = value
                Plater.UpdateAllPlates()
            end,
            name = "OPTIONS_ALWAYS_SHOW_SOFT_INTERACT",
            desc = "Always show the name or healthbar on your soft-interact target instead of hiding them on NPCs.",
        },
        {
            type = "toggle",
            get = function() return Plater.db.profile.ignore_softinteract_objects end,
            set = function (self, fixedparam, value)
                Plater.db.profile.ignore_softinteract_objects = value
                Plater.UpdateAllPlates()
            end,
            name = "OPTIONS_USE_BLIZZARD_SOFT_INTERACT",
            desc = "Only show Plater soft-interact nameplates on NPCs.",
        },
        {
            type = "toggle",
            get = function() return Plater.db.profile.hide_name_on_game_objects end,
            set = function (self, fixedparam, value)
                Plater.db.profile.hide_name_on_game_objects = value
                Plater.UpdateAllPlates()
            end,
            name = "OPTIONS_HIDE_PLATER_NAMES_OBJECTS",
            desc = "Hide Plater names game objects, such as soft-interact targets.",
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
            name = "OPTIONS_SHOW_SOFT_INTERACT_ICON",
            desc = "Show an icon on soft-interact targets.",
        },

        {type = "blank"},

        {type = "label", name = "LABEL_CLIENT_SETTINGS_CVARS", text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
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
            name = "@OPTIONS_KEEP_NAMEPLATES_ON_SCREEN@" .. CVarIcon,
            desc = "Always keep nameplates on screen if the unit in combat with the player or a party member." .. CVarDesc,
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
            name = "@OPTIONS_LOCK_SCREEN_TOP@" .. CVarIcon,
            desc = "Min space between the nameplate and the top of the screen. Increase this if some part of the nameplate are going out of the screen.\n\n|cFFFFFFFFDefault: 0.065|r\n\n|cFFFFFF00 Important |r: if you're having issue, manually set using these macros:\n/run SetCVar ('nameplateOtherTopInset', '0.065')\n/run SetCVar ('nameplateLargeTopInset', '0.065')\n\n|cFFFFFF00 Important |r: setting to 0 disables this feature." .. CVarDesc,
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
            name = "OPTIONS_LOCK_SCREEN_BOTTOM",
            desc = "Min space between the nameplate and the bottom of the screen. Increase this if some part of the nameplate are going out of the screen.\n\n|cFFFFFFFFDefault: 0.065|r\n\n|cFFFFFF00 Important |r: if you're having issue, manually set using these macros:\n/run SetCVar ('nameplateOtherBottomInset', '0.1')\n/run SetCVar ('nameplateLargeBottomInset', '0.15')\n\n|cFFFFFF00 Important |r: setting to 0 disables this feature.\n\n|cFFFF7700[*]|r |cFFa0a0a0CVar, saved within Plater profile and restored when loading the profile.|r",
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
            name = "@OPTIONS_NAMEPLATE_OVERLAP_V@" .. CVarIcon,
            desc = "The space between each nameplate vertically when stacking is enabled.\n\n|cFFFFFFFFDefault: 1.10|r\n\n|cFFFFFF00 Important |r: if you find issues with this setting, use:\n|cFFFFFFFF/run SetCVar ('nameplateOverlapV', '1.6')|r"  .. CVarDesc,
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
            name = "@OPTIONS_NAMEPLATE_OVERLAP_H@" .. CVarIcon,
            desc = "The space between each nameplate horizontally when stacking is enabled.\n\n|cFFFFFFFFDefault: 0.8|r\n\n|cFFFFFF00 Important |r: if you find issues with this setting, use:\n|cFFFFFFFF/run SetCVar ('nameplateOverlapH', '0.8')|r"  .. CVarDesc,
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
            name = "@OPTIONS_MOVEMENT_SPEED@" .. CVarIcon,
            desc = "How fast the nameplate moves (when stacking is enabled).\n\n|cFFFFFFFFDefault: 0.025|r\n\n|cFFFFFFFFRecommended: >=0.02|r" .. CVarDesc,
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
            name = "@OPTIONS_GLOBAL_SCALE@" .. CVarIcon,
            desc = "Scale all nameplates.\n\n|cFFFFFFFFDefault: 1|r" .. CVarDesc,
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
            name = "@OPTIONS_MIN_SCALE@" .. CVarIcon,
            desc = "Scale applied when the nameplate is far away from the camera.\n\n|cFFFFFF00 Important |r: is the distance from the camera and |cFFFF4444not|r the distance from your character.\n\n|cFFFFFFFFDefault: 0.8|r" .. CVarDesc,
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
            name = "@OPTIONS_LARGER_SCALE@" .. CVarIcon,
            desc = "Scale applied to important monsters (such as bosses).\n\n|cFFFFFFFFDefault: 1.2|r" .. CVarDesc,
            nocombat = true,
        },

        {
            type = "select",
            get = function() return tonumber (GetCVar ("nameplateOtherAtBase")) end,
            values = function() return nameplate_anchor_options end,
            name = "@OPTIONS_ANCHOR_POINT@" .. CVarIcon,
            desc = "Where the nameplate is anchored to.\n\n|cFFFFFFFFDefault: Head|r" .. CVarDesc,
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
            name = "@OPTIONS_SHOW_DEBUFFS_BLIZZARD@" .. CVarIcon,
            desc = "While in dungeons or raids, if friendly nameplates are enabled it won't show debuffs on them.\nIf any Plater module is disabled, this will affect these nameplates as well." .. CVarDesc .. CVarNeedReload,
            nocombat = true,
            hidden = IS_WOW_PROJECT_MIDNIGHT,
        },

        {type = "blank", hidden = not IS_WOW_PROJECT_MIDNIGHT},
        {type = "label", name = "LABEL_OVERLAP_SIZE_SCALING", text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"), hidden = not IS_WOW_PROJECT_MIDNIGHT},
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
            name = "OPTIONS_ENEMY_OVERLAP_H",
            desc = "Scaling for the space each nameplate occupies horizontally when stacking is enabled, relative to clickspace, for enemy units.",
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
            name = "OPTIONS_ENEMY_OVERLAP_V",
            desc = "Scaling for the space each nameplate occupies vertically when stacking is enabled, relative to clickspace, for enemy units.",
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
            name = "OPTIONS_FRIENDLY_OVERLAP_H",
            desc = "Scaling for the space each nameplate occupies horizontally when stacking is enabled, relative to clickspace, for friendly units.",
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
            name = "OPTIONS_FRIENDLY_OVERLAP_V",
            desc = "Scaling for the space each nameplate occupies vertically when stacking is enabled, relative to clickspace, for friendly units.",
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
            name = "@OPTIONS_LARGER_NAMEPLATES@" .. CVarIcon,
            desc = "Increases the blizzard base nameplate scaling (which is impacting the selection space and default blizzard nameplate size)." .. CVarDesc,
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
            name = "@OPTIONS_BASE_VERTICAL_SCALE@" .. CVarIcon,
            desc = "Increases the blizzard base nameplate scaling height (which is impacting the selection space and default blizzard nameplate size)." .. CVarDesc,
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
            name = "@OPTIONS_BASE_HORIZONTAL_SCALE@" .. CVarIcon,
            desc = "Increases the blizzard base nameplate scaling height (which is impacting the selection space and default blizzard nameplate size)." .. CVarDesc,
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
            name = "@OPTIONS_BASE_CLASSIFICATION_SCALE@" .. CVarIcon,
            desc = "Increases the blizzard base nameplate classification scaling (which is impacting the selection space and default blizzard nameplate size)." .. CVarDesc,
            nocombat = true,
            hidden = IS_WOW_PROJECT_MIDNIGHT,
        },
        
        {type = "blank", hidden = not IS_WOW_PROJECT_MIDNIGHT},
        {type = "label", name = "LABEL_NAMEPLATE_SELECTION_SPACE", text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"), hidden = not IS_WOW_PROJECT_MIDNIGHT},
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
        
        {type = "label", name = "LABEL_ENEMY_BOX_SELECTION_SPACE", text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"), hidden = IS_WOW_PROJECT_MIDNIGHT},
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

        {type = "label", name = "LABEL_FRIENDLY_BOX_SELECTION_SPACE", text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"), hidden = IS_WOW_PROJECT_MIDNIGHT},
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
        {type = "label", name = "LABEL_UNIT_TYPES", text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},

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
            name = "@OPTIONS_SHOW_ENEMY_GUARDIANS@" .. CVarIcon,
            desc = "Show nameplates for enemies pets considered as guardian" .. CVarDesc,
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
            name = "@OPTIONS_SHOW_ENEMY_MINIONS@" .. CVarIcon,
            desc = "Show nameplates for enemies considered as minions" .. CVarDesc,
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
            name = "@OPTIONS_SHOW_ENEMY_MINOR@" .. CVarIcon,
            desc = "Show nameplates of small units (usually they are units with max level but low health)" .. CVarDesc,
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
            name = "@OPTIONS_SHOW_ENEMY_PETS@" .. CVarIcon,
            desc = "Show nameplates for enemy pets" .. CVarDesc,
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
            name = "@OPTIONS_SHOW_ENEMY_TOTEMS@" .. CVarIcon,
            desc = "Show enemy totems" .. CVarDesc,
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
            name = "@OPTIONS_SHOW_FRIENDLY_NPCS@" .. CVarIcon,
            desc = "Show nameplates for friendly npcs" .. CVarDesc,
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
            name = "@OPTIONS_SHOW_FRIENDLY_GUARDIANS@" .. CVarIcon,
            desc = "Show nameplates for friendly pets considered as guardian" .. CVarDesc,
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
            name = "@OPTIONS_SHOW_FRIENDLY_MINIONS@" .. CVarIcon,
            desc = "Show nameplates for friendly units considered minions" .. CVarDesc,
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
            name = "@OPTIONS_SHOW_FRIENDLY_PETS@" .. CVarIcon,
            desc = "Show nameplates for friendly pets" .. CVarDesc,
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
            name = "@OPTIONS_SHOW_FRIENDLY_TOTEMS@" .. CVarIcon,
            desc = "Show friendly totems" .. CVarDesc,
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
            name = "@OPTIONS_SHOW_FRIENDLY_PLAYERS@" .. CVarIcon,
            desc = "Show nameplates for friendly players" .. CVarDesc,
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
            name = "@OPTIONS_SHOW_FRIENDLY_GUARDIANS@" .. CVarIcon,
            desc = "Show nameplates for friendly pets considered as guardian" .. CVarDesc,
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
            name = "@OPTIONS_SHOW_FRIENDLY_MINIONS@" .. CVarIcon,
            desc = "Show nameplates for friendly units considered minions" .. CVarDesc,
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
            name = "@OPTIONS_SHOW_FRIENDLY_PETS@" .. CVarIcon,
            desc = "Show nameplates for friendly pets" .. CVarDesc,
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
            name = "@OPTIONS_SHOW_FRIENDLY_TOTEMS@" .. CVarIcon,
            desc = "Show friendly totems" .. CVarDesc,
            nocombat = true,
            hidden = not IS_WOW_PROJECT_MIDNIGHT,
        },

        {type = "blank"},
        {type = "label", name = "LABEL_BLIZZARD_NAMEPLATE_FONTS", text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
        {
            type = "toggle",
            get = function() return Plater.db.profile.blizzard_nameplate_font_override_enabled end,
            set = function (self, fixedparam, value)
                Plater.db.profile.blizzard_nameplate_font_override_enabled = value
            end,
            name = L["OPTIONS_ENABLED"],
            desc = "Enable blizzard nameplate font override." .. CVarNeedReload,
        },
        {type = "label", name = "LABEL_NORMAL", text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
        {
            type = "select",
            get = function() return Plater.db.profile.blizzard_nameplate_font end,
            values = function() return DF:BuildDropDownFontList (on_select_blizzard_nameplate_font) end,
            name = L["OPTIONS_FONT"],
            desc = "Font of the text." .. CVarNeedReload,
        },
        {
            type = "range",
            get = function() return Plater.db.profile.blizzard_nameplate_font_size end,
            set = function (self, fixedparam, value) Plater.db.profile.blizzard_nameplate_font_size = value end,
            min = 6,
            max = 24,
            step = 1,
            name = L["OPTIONS_SIZE"],
            desc = "Size" .. CVarNeedReload,
        },
        {
            type = "select",
            get = function() return Plater.db.profile.blizzard_nameplate_font_outline end,
            values = function() return build_outline_modes_table (nil, "blizzard_nameplate_font_outline") end,
            name = L["OPTIONS_OUTLINE"],
            desc = "Outline" .. CVarNeedReload,
        },
        {type = "label", name = "LABEL_LARGE", text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
        {
            type = "select",
            get = function() return Plater.db.profile.blizzard_nameplate_large_font end,
            values = function() return DF:BuildDropDownFontList (on_select_blizzard_nameplate_large_font) end,
            name = L["OPTIONS_FONT"],
            desc = "Font of the text." .. CVarNeedReload,
        },
        {
            type = "range",
            get = function() return Plater.db.profile.blizzard_nameplate_large_font_size end,
            set = function (self, fixedparam, value) Plater.db.profile.blizzard_nameplate_large_font_size = value end,
            min = 6,
            max = 24,
            step = 1,
            name = L["OPTIONS_SIZE"],
            desc = "Size" .. CVarNeedReload,
        },
        {
            type = "select",
            get = function() return Plater.db.profile.blizzard_nameplate_large_font_outline end,
            values = function() return build_outline_modes_table (nil, "blizzard_nameplate_large_font_outline") end,
            name = L["OPTIONS_OUTLINE"],
            desc = "Outline" .. CVarNeedReload,
        },

        --{type = "breakline"},

        {type = "blank"},

        --can't go up to 100 pixels deviation due to the clicable space from the plateFrame
        --if it goes more than the plateFrame area it generates areas where isn't clicable
        {type = "label", name = "LABEL_GLOBAL_OFFSET", text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
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

        {type = "label", name = "LABEL_SPECIAL_UNITS", text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},

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
        {type = "label", name = "LABEL_REGION", text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},

        {
            type = "select",
            get = function() return Plater.db.profile.number_region end,
            values = function() return build_number_format_options() end,
            name = "OPTIONS_FORMAT_NUMBER",
            desc = "OPTIONS_FORMAT_NUMBER",
        },

        {type = "label", name = "LABEL_MISC", text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},

        {
            type = "toggle",
            get = function() return Plater.db.profile.show_health_prediction end,
            set = function (self, fixedparam, value)
                Plater.db.profile.show_health_prediction = value
            end,
            name = "OPTIONS_SHOW_HEALTH_PREDICTION",
            desc = "Show an extra bar for health prediction and heal absorption.",
        },
        {
            type = "toggle",
            get = function() return Plater.db.profile.show_shield_prediction end,
            set = function (self, fixedparam, value)
                Plater.db.profile.show_shield_prediction = value
            end,
            name = "OPTIONS_SHOW_SHIELD_PREDICTION",
            desc = "Show an extra bar for shields (e.g. Power Word: Shield from priests) absorption.",
        },

        {
            type = "toggle",
            get = function() return Plater.db.profile.enable_masque_support end,
            set = function (self, fixedparam, value)
                Plater.db.profile.enable_masque_support = value
                Plater:Msg ("this setting require a /reload to take effect.")
            end,
            name = "OPTIONS_MASQUE_SUPPORT",
            desc = "If the Masque addon is installed, enabling this will make Plater to use Masque borders.\n\n|cFFFFFF00 Important |r: require /reload after changing this setting.",
        },

        {
            type = "toggle",
            get = function() return Plater.db.profile.use_name_translit end,
            set = function (self, fixedparam, value)
                Plater.db.profile.use_name_translit = value
                Plater.RefreshDBUpvalues()
                Plater.FullRefreshAllPlates()
            end,
            name = "OPTIONS_NAME_TRANSLIT",
            desc = "Use LibTranslit to translit names. Changed names will be tagged with a '*'",
        },

        {
            type = "toggle",
            get = function() return Plater.db.profile.use_player_combat_state end,
            set = function (self, fixedparam, value)
                Plater.db.profile.use_player_combat_state = value
            end,
            name = "OPTIONS_USE_PLAYER_COMBAT_STATE",
            desc = "Use the players combat state instead of the units when applying settings for In/Out of Combat.",
        },

        {
            type = "toggle",
            get = function() return Plater.db.profile.opt_out_auto_accept_npc_colors end,
            set = function (self, fixedparam, value)
                Plater.db.profile.opt_out_auto_accept_npc_colors = value
            end,
            name = "OPTIONS_OPT_OUT_NPC_COLORS",
            desc = "Will not automatically accepd npc colors sent by raid-leaders but prompt instead.",
        },
        {
            type = "toggle",
            get = function() return Plater.db.profile.auto_translate_npc_names end,
            set = function (self, fixedparam, value)
                Plater.db.profile.auto_translate_npc_names = value
                Plater.TranslateNPCCache()
            end,
            name = "OPTIONS_AUTO_TRANSLATE_NPC_NAMES",
            desc = "Will automatically translate the names to the current game locale.",
        },

        {type = "blank"},
        {type = "label", name = "LABEL_PERSONAL_BAR_CUSTOM_POSITION", text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"), hidden = IS_WOW_PROJECT_NOT_MAINLINE or IS_WOW_PROJECT_MIDNIGHT},
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
                    frame.Text:SetText ("Plater: Top Constraint")
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
            name = "@OPTIONS_TOP_CONSTRAIN@" .. CVarIcon,
            desc = "Adjust the top constrain position where the personal bar cannot pass.\n\n|cFFFFFFFFDefault: 50|r" .. CVarDesc,
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
                    frame.Text:SetText ("Plater: Bottom Constraint")
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
            name = "@OPTIONS_BOTTOM_CONSTRAIN@" .. CVarIcon,
            desc = "Adjust the bottom constrain position where the personal bar cannot pass.\n\n|cFFFFFFFFDefault: 20|r" .. CVarDesc,
            hidden = IS_WOW_PROJECT_NOT_MAINLINE or IS_WOW_PROJECT_MIDNIGHT,
        },

        {type = "blank", hidden = IS_WOW_PROJECT_MIDNIGHT},
        {type = "label", name = "LABEL_ANIMATIONS", text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE") }, --, hidden = IS_WOW_PROJECT_MIDNIGHT},

        {
            type = "toggle",
            get = function() return Plater.db.profile.use_health_animation end,
            set = function (self, fixedparam, value)
                Plater.db.profile.use_health_animation = value
                Plater.RefreshDBUpvalues()
                Plater.UpdateAllPlates()
            end,
            name = "OPTIONS_ANIMATE_HEALTH_BAR",
            desc = "Do a smooth animation when the nameplate's health value changes.",
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
            name = "OPTIONS_ANIMATE_COLOR_TRANSITIONS",
            desc = "Color changes does a smooth transition between the old and the new color.",
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
            name = "OPTIONS_HEALTH_BAR_ANIM_SPEED",
            desc = "How fast is the animation.",
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
            name = "OPTIONS_COLOR_ANIM_SPEED",
            desc = "How fast is the animation.",
            hidden = IS_WOW_PROJECT_MIDNIGHT,
        },

        {type = "blank"},

        {type = "label", name = "LABEL_UNIT_WIDGET_BARS", text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"), hidden = IS_WOW_PROJECT_NOT_MAINLINE},
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
            desc = "Slightly adjust the size of widget bars.",
            usedecimals = true,
            hidden = IS_WOW_PROJECT_NOT_MAINLINE,
        },
        {
            type = "select",
            get = function() return Plater.db.profile.widget_bar_anchor.side end,
            values = function() return build_anchor_side_table (nil, "widget_bar_anchor") end,
            name = "OPTIONS_ANCHOR",
            desc = "Which side of the nameplate the widget bar should attach to.",
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
    advanced_options.Name = "Advanced Options"

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
