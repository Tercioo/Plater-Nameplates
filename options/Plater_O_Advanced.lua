
local addonId, platerInternal = ...
local Plater = Plater
---@type detailsframework
local DF = DetailsFramework
local _

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

	local CVarDesc = "\n\n|cFFFF7700[*]|r |cFFa0a0a0CVar, saved within Plater profile and restored when loading the profile.|r"
	local CVarIcon = "|cFFFF7700*|r"
	local CVarNeedReload = "\n\n|cFFFF2200[*]|r |cFFa0a0a0A /reload may be required to take effect.|r"
	local ImportantText = "|cFFFFFF00 Important |r: "

    local dropdownStatusBarTexture = platerInternal.Defaults.dropdownStatusBarTexture
    local dropdownStatusBarColor = platerInternal.Defaults.dropdownStatusBarColor

    local L = DF.Language.GetLanguageTable(addonId)

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
        {type = "label", get = function() return "General Settings:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},

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
            name = "Update Interval",
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
            name = (IS_WOW_PROJECT_MAINLINE) and "Quick Hide on Death" or "Quick Hide Nameplates",
            desc = "When the unit dies, immediately hide the nameplates without playing the shrink animation.",
        },

        {
            type = "toggle",
            get = function() return Plater.db.profile.show_healthbars_on_not_attackable end,
            set = function (self, fixedparam, value)
                Plater.db.profile.show_healthbars_on_not_attackable = value
                Plater.UpdateAllPlates()
            end,
            name = "Show healthbars on not attackable units",
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
            name = "Show soft-interact on game objects" .. CVarIcon,
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
            name = "Force nameplates on soft-interact target" .. CVarIcon,
            desc = "Force show the nameplate on your soft-interact target." .. CVarDesc,
        },
        {
            type = "toggle",
            get = function() return Plater.db.profile.show_healthbars_on_softinteract end,
            set = function (self, fixedparam, value)
                Plater.db.profile.show_healthbars_on_softinteract = value
                Plater.UpdateAllPlates()
            end,
            name = "Always show soft-interact target",
            desc = "Always show the name or healthbar on your soft-interact target instead of hiding them on NPCs.",
        },
        {
            type = "toggle",
            get = function() return Plater.db.profile.ignore_softinteract_objects end,
            set = function (self, fixedparam, value)
                Plater.db.profile.ignore_softinteract_objects = value
                Plater.UpdateAllPlates()
            end,
            name = "Use blizzard soft-interact for objects",
            desc = "Only show Plater soft-interact nameplates on NPCs.",
        },
        {
            type = "toggle",
            get = function() return Plater.db.profile.hide_name_on_game_objects end,
            set = function (self, fixedparam, value)
                Plater.db.profile.hide_name_on_game_objects = value
                Plater.UpdateAllPlates()
            end,
            name = "Hide Plater names game objects",
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
            name = "Show soft-interact Icon",
            desc = "Show an icon on soft-interact targets.",
        },

        {type = "blank"},

        {type = "label", get = function() return "Client Settings (CVars):" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
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
            name = "Lock to Screen (Top Side)" .. CVarIcon,
            desc = "Min space between the nameplate and the top of the screen. Increase this if some part of the nameplate are going out of the screen.\n\n|cFFFFFFFFDefault: 0.065|r\n\n" .. ImportantText .. "if you're having issue, manually set using these macros:\n/run SetCVar ('nameplateOtherTopInset', '0.065')\n/run SetCVar ('nameplateLargeTopInset', '0.065')\n\n" .. ImportantText .. "setting to 0 disables this feature." .. CVarDesc,
            nocombat = true,
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
            name = "Lock to Screen (Bottom Side)|cFFFF7700*|r",
            desc = "Min space between the nameplate and the bottom of the screen. Increase this if some part of the nameplate are going out of the screen.\n\n|cFFFFFFFFDefault: 0.065|r\n\n|cFFFFFF00 Important |r: if you're having issue, manually set using these macros:\n/run SetCVar ('nameplateOtherBottomInset', '0.1')\n/run SetCVar ('nameplateLargeBottomInset', '0.15')\n\n|cFFFFFF00 Important |r: setting to 0 disables this feature.\n\n|cFFFF7700[*]|r |cFFa0a0a0CVar, saved within Plater profile and restored when loading the profile.|r",
            nocombat = true,
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
            name = "Nameplate Overlap (V)" .. CVarIcon,
            desc = "The space between each nameplate vertically when stacking is enabled.\n\n|cFFFFFFFFDefault: 1.10|r" .. CVarDesc .. "\n\n" .. ImportantText .. "if you find issues with this setting, use:\n|cFFFFFFFF/run SetCVar ('nameplateOverlapV', '1.6')|r",
            nocombat = true,
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
            name = "Nameplate Overlap (H)" .. CVarIcon,
            desc = "The space between each nameplate horizontally when stacking is enabled.\n\n|cFFFFFFFFDefault: 0.8|r" .. CVarDesc .. "\n\n" .. ImportantText .. "if you find issues with this setting, use:\n|cFFFFFFFF/run SetCVar ('nameplateOverlapH', '0.8')|r",
            nocombat = true,
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
            name = "Movement Speed" .. CVarIcon,
            desc = "How fast the nameplate moves (when stacking is enabled).\n\n|cFFFFFFFFDefault: 0.025|r\n\n|cFFFFFFFFRecommended: >=0.02|r" .. CVarDesc,
            nocombat = true,
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
            name = "Global Scale" .. CVarIcon,
            desc = "Scale all nameplates.\n\n|cFFFFFFFFDefault: 1|r" .. CVarDesc,
            nocombat = true,
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
            name = "Min Scale" .. CVarIcon,
            desc = "Scale applied when the nameplate is far away from the camera.\n\n" .. ImportantText .. "is the distance from the camera and |cFFFF4444not|r the distance from your character.\n\n|cFFFFFFFFDefault: 0.8|r" .. CVarDesc,
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
            name = "Larger Scale" .. CVarIcon,
            desc = "Scale applied to important monsters (such as bosses).\n\n|cFFFFFFFFDefault: 1.2|r" .. CVarDesc,
            nocombat = true,
        },

        {
            type = "select",
            get = function() return tonumber (GetCVar ("nameplateOtherAtBase")) end,
            values = function() return nameplate_anchor_options end,
            name = "Anchor Point" .. CVarIcon,
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
            name = "Show Debuffs on Blizzard Health Bars" .. CVarIcon,
            desc = "While in dungeons or raids, if friendly nameplates are enabled it won't show debuffs on them.\nIf any Plater module is disabled, this will affect these nameplates as well." .. CVarDesc .. CVarNeedReload,
            nocombat = true,
        },

        {type = "label", get = function() return "Enemy Box Selection Space:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
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
        },

        {type = "blank"},

        {type = "label", get = function() return "Friendly Box Selection Space:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
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
        {type = "label", get = function() return "Unit types:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},

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
            name = "Show Enemy Guardians" .. CVarIcon,
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
            name = "Show Enemy Minions" .. CVarIcon,
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
            name = "Show Enemy Minor Units" .. CVarIcon,
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
            name = "Show Enemy Pets" .. CVarIcon,
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
            name = "Show Enemy Totems" .. CVarIcon,
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
            name = "Show Friendly Npcs" .. CVarIcon,
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
            name = "Show Friendly Guardians" .. CVarIcon,
            desc = "Show nameplates for friendly pets considered as guardian" .. CVarDesc,
            nocombat = true,
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
            name = "Show Friendly Minions" .. CVarIcon,
            desc = "Show nameplates for friendly units considered minions" .. CVarDesc,
            nocombat = true,
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
            name = "Show Friendly Pets" .. CVarIcon,
            desc = "Show nameplates for friendly pets" .. CVarDesc,
            nocombat = true,
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
            name = "Show Friendly Totems" .. CVarIcon,
            desc = "Show friendly totems" .. CVarDesc,
            nocombat = true,
        },

        {type = "blank"},
        {type = "label", get = function() return "Blizzard nameplate fonts:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
        {
            type = "toggle",
            get = function() return Plater.db.profile.blizzard_nameplate_font_override_enabled end,
            set = function (self, fixedparam, value)
                Plater.db.profile.blizzard_nameplate_font_override_enabled = value
            end,
            name = L["OPTIONS_ENABLED"],
            desc = "Enable blizzard nameplate font override." .. CVarNeedReload,
        },
        {type = "label", get = function() return "Normal:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
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
        {type = "label", get = function() return "Large:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
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
        {type = "label", get = function() return "Global OffSet:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
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

        {type = "label", get = function() return "Special Units:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},

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
        {type = "label", get = function() return "Region:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},

        {
            type = "select",
            get = function() return Plater.db.profile.number_region end,
            values = function() return build_number_format_options() end,
            name = "OPTIONS_FORMAT_NUMBER",
            desc = "OPTIONS_FORMAT_NUMBER",
        },

        {type = "label", get = function() return "Misc:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},

        {
            type = "toggle",
            get = function() return Plater.db.profile.show_health_prediction end,
            set = function (self, fixedparam, value)
                Plater.db.profile.show_health_prediction = value
            end,
            name = "Show Health Prediction/Absorption",
            desc = "Show an extra bar for health prediction and heal absorption.",
        },
        {
            type = "toggle",
            get = function() return Plater.db.profile.show_shield_prediction end,
            set = function (self, fixedparam, value)
                Plater.db.profile.show_shield_prediction = value
            end,
            name = "Show Shield Prediction",
            desc = "Show an extra bar for shields (e.g. Power Word: Shield from priests) absorption.",
        },

        {
            type = "toggle",
            get = function() return Plater.db.profile.enable_masque_support end,
            set = function (self, fixedparam, value)
                Plater.db.profile.enable_masque_support = value
                Plater:Msg ("this setting require a /reload to take effect.")
            end,
            name = "Masque Support",
            desc = "If the Masque addon is installed, enabling this will make Plater to use Masque borders.\n\n" .. ImportantText .. "require /reload after changing this setting.",
        },

        {
            type = "toggle",
            get = function() return Plater.db.profile.use_name_translit end,
            set = function (self, fixedparam, value)
                Plater.db.profile.use_name_translit = value
                Plater.RefreshDBUpvalues()
                Plater.FullRefreshAllPlates()
            end,
            name = "Name translit",
            desc = "Use LibTranslit to translit names. Changed names will be tagged with a '*'",
        },

        {
            type = "toggle",
            get = function() return Plater.db.profile.use_player_combat_state end,
            set = function (self, fixedparam, value)
                Plater.db.profile.use_player_combat_state = value
            end,
            name = "In/Out of Combat Settings - Use Player Combat State",
            desc = "Use the players combat state instead of the units when applying settings for In/Out of Combat.",
        },

        {
            type = "toggle",
            get = function() return Plater.db.profile.opt_out_auto_accept_npc_colors end,
            set = function (self, fixedparam, value)
                Plater.db.profile.opt_out_auto_accept_npc_colors = value
            end,
            name = "Opt-Out of automatically accepting NPC Colors",
            desc = "Will not automatically accepd npc colors sent by raid-leaders but prompt instead.",
        },
        {
            type = "toggle",
            get = function() return Plater.db.profile.auto_translate_npc_names end,
            set = function (self, fixedparam, value)
                Plater.db.profile.auto_translate_npc_names = value
                Plater.TranslateNPCCache()
            end,
            name = "Automatically translate NPC names on the NPC Colors tab.",
            desc = "Will automatically translate the names to the current game locale.",
        },

        {type = "blank"},
        {type = "label", get = function() return "Personal Bar Custom Position:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"), hidden = IS_WOW_PROJECT_NOT_MAINLINE},
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
            name = "Top Constrain" .. CVarIcon,
            desc = "Adjust the top constrain position where the personal bar cannot pass.\n\n|cFFFFFFFFDefault: 50|r" .. CVarDesc,
            hidden = IS_WOW_PROJECT_NOT_MAINLINE,
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
            name = "Bottom Constrain" .. CVarIcon,
            desc = "Adjust the bottom constrain position where the personal bar cannot pass.\n\n|cFFFFFFFFDefault: 20|r" .. CVarDesc,
            hidden = IS_WOW_PROJECT_NOT_MAINLINE,
        },

        {type = "blank"},
        {type = "label", get = function() return "Animations:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},

        {
            type = "toggle",
            get = function() return Plater.db.profile.use_health_animation end,
            set = function (self, fixedparam, value)
                Plater.db.profile.use_health_animation = value
                Plater.RefreshDBUpvalues()
                Plater.UpdateAllPlates()
            end,
            name = "Animate Health Bar",
            desc = "Do a smooth animation when the nameplate's health value changes.",
        },
        {
            type = "toggle",
            get = function() return Plater.db.profile.use_color_lerp end,
            set = function (self, fixedparam, value)
                Plater.db.profile.use_color_lerp = value
                Plater.RefreshDBUpvalues()
                Plater.UpdateAllPlates()
            end,
            name = "Animate Color Transitions",
            desc = "Color changes does a smooth transition between the old and the new color.",
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
            name = "Health Bar Animation Speed",
            desc = "How fast is the animation.",
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
            name = "Color Animation Speed",
            desc = "How fast is the animation.",
        },

        {type = "blank"},

        {type = "label", get = function() return "Unit Widget Bars:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"), hidden = IS_WOW_PROJECT_NOT_MAINLINE},
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
            name = "Scale",
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
