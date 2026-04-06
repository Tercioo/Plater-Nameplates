
local addonId, platerInternal = ...
local Plater = Plater
---@type detailsframework
local DF = DetailsFramework
local _

function platerInternal.CreateAutomationOptions()
    if platerInternal.LoadOnDemand_IsLoaded.AutomationOptions then return end -- already loaded

    --templates
    local options_text_template = DF:GetTemplate ("font", "OPTIONS_FONT_TEMPLATE")
    local options_dropdown_template = DF:GetTemplate ("dropdown", "OPTIONS_DROPDOWN_TEMPLATE")
    local options_switch_template = DF:GetTemplate ("switch", "OPTIONS_CHECKBOX_TEMPLATE")
    local options_slider_template = DF:GetTemplate ("slider", "OPTIONS_SLIDER_TEMPLATE")
    local options_button_template = DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE")

    local L = DF.Language.GetLanguageTable(addonId)

    local localization = {
    }

	local auto_options = {
		--group declaration
		---@type df_menu_group
		{
			type = "group",
			UseBackdrop = {bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tileSize = 16, tile = true, tileEdge = true, edgeSize = 16, insets = {left = 3, right = 3, top = 3, bottom = 3}},
			BackgroundColor = {0, 0, 0, .2},
			BackdropBorderColor = {1, 1, 1, 0.5},
			name = "combat_toggles",
			padding = 2,
		},
		---@type df_menu_group
		{
			type = "group",
			UseBackdrop = {bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tileSize = 16, tile = true, tileEdge = true, edgeSize = 16, insets = {left = 3, right = 3, top = 3, bottom = 3}},
			BackgroundColor = {0, 0, 0, .2},
			BackdropBorderColor = {1, 1, 1, 0.5},
			name = "one",
			padding = 2,
			width = 400,
		},
		---@type df_menu_group
		{
			type = "group",
			UseBackdrop = {bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tileSize = 16, tile = true, tileEdge = true, edgeSize = 16, insets = {left = 3, right = 3, top = 3, bottom = 3}},
			BackgroundColor = {0, 0, 0, .2},
			BackdropBorderColor = {1, 1, 1, 0.5},
			name = "three",
			padding = 2,
			width = 400,
		},

		{type = "label", get = function() return L["OPTIONS_AUTO_SECTIONTITLE_COMBAT_TOGGLE"] end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"), group = "combat_toggles"},
		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_toggle_combat_enabled end,
			set = function (self, fixedparam, value)
				Plater.db.profile.auto_toggle_combat_enabled = value

				Plater.RefreshDBUpvalues()
				Plater.UpdateAllPlates()
				Plater.RefreshAutoToggle()
			end,
			name = L["OPTIONS_ENABLED"],
			desc = L["OPTIONS_AUTO_TOGGLE_COMBAT_DESC"],
			group = "combat_toggles",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_toggle_combat.enemy_ic end,
			set = function (self, fixedparam, value)
				Plater.db.profile.auto_toggle_combat.enemy_ic = value
				Plater.RefreshAutoToggle()
			end,
			name = L["OPTIONS_AUTO_ENEMY_NAMEPLATES_IC"],
			desc = L["OPTIONS_AUTO_ENEMY_NAMEPLATES_IC_DESC"],
			group = "combat_toggles",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_toggle_combat.enemy_ooc end,
			set = function (self, fixedparam, value)
				Plater.db.profile.auto_toggle_combat.enemy_ooc = value
				Plater.RefreshAutoToggle()
			end,
			name = L["OPTIONS_AUTO_ENEMY_NAMEPLATES_OOC"],
			desc = L["OPTIONS_AUTO_ENEMY_NAMEPLATES_OOC_DESC"],
			group = "combat_toggles",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_toggle_combat.friendly_ic end,
			set = function (self, fixedparam, value)
				Plater.db.profile.auto_toggle_combat.friendly_ic = value
				Plater.RefreshAutoToggle()
			end,
			name = L["OPTIONS_AUTO_FRIENDLY_NAMEPLATES_IC"],
			desc = L["OPTIONS_AUTO_FRIENDLY_NAMEPLATES_IC_DESC"],
			group = "combat_toggles",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_toggle_combat.friendly_ooc end,
			set = function (self, fixedparam, value)
				Plater.db.profile.auto_toggle_combat.friendly_ooc = value
				Plater.RefreshAutoToggle()
			end,
			name = L["OPTIONS_AUTO_FRIENDLY_NAMEPLATES_OOC"],
			desc = L["OPTIONS_AUTO_FRIENDLY_NAMEPLATES_OOC_DESC"],
			group = "combat_toggles",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_toggle_combat.blizz_healthbar_ic end,
			set = function (self, fixedparam, value)
				Plater.db.profile.auto_toggle_combat.blizz_healthbar_ic = value
				Plater.RefreshAutoToggle()
			end,
			name = L["OPTIONS_AUTO_HIDE_BLIZZARD_HEALTHBARS_IC"],
			desc = L["OPTIONS_AUTO_HIDE_BLIZZARD_HEALTHBARS_IC_DESC"],
			group = "combat_toggles",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_toggle_combat.blizz_healthbar_ooc end,
			set = function (self, fixedparam, value)
				Plater.db.profile.auto_toggle_combat.blizz_healthbar_ooc = value
				Plater.RefreshAutoToggle()
			end,
			name = L["OPTIONS_AUTO_HIDE_BLIZZARD_HEALTHBARS_OOC"],
			desc = L["OPTIONS_AUTO_HIDE_BLIZZARD_HEALTHBARS_OOC_DESC"],
			group = "combat_toggles",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_toggle_combat.always_show_ic end,
			set = function (self, fixedparam, value)
				Plater.db.profile.auto_toggle_combat.always_show_ic = value
				Plater.RefreshAutoToggle()
			end,
			name = L["OPTIONS_AUTO_SHOWNAMEPLATE_INCOMBAT"],
			desc = L["OPTIONS_AUTO_SHOWNAMEPLATE_INCOMBAT_DESC"],
			group = "combat_toggles",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_toggle_combat.always_show_ooc end,
			set = function (self, fixedparam, value)
				Plater.db.profile.auto_toggle_combat.always_show_ooc = value
				Plater.RefreshAutoToggle()
			end,
			name = L["OPTIONS_AUTO_SHOWNAMEPLATE_OUTOFCOMBAT"],
			desc = L["OPTIONS_AUTO_SHOWNAMEPLATE_OUTOFCOMBAT_DESC"],
			group = "combat_toggles",
		},

		{type = "blank"},

		{type = "label", get = function() return L["OPTIONS_AUTO_SECTIONTITLE_RAID_AND_PARTY"] end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"), group = "combat_toggles"},

		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_inside_raid_dungeon.hide_enemy_player_pets end,
			set = function (self, fixedparam, value)
				Plater.db.profile.auto_inside_raid_dungeon.hide_enemy_player_pets = value
				Plater.RefreshAutoToggle()
			end,
			name = L["OPTIONS_AUTO_HIDE_ENEMY_PETS"],
			desc = L["OPTIONS_AUTO_HIDE_ENEMY_PETS_DESC"],
			group = "combat_toggles",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_inside_raid_dungeon.hide_enemy_player_totems end,
			set = function (self, fixedparam, value)
				Plater.db.profile.auto_inside_raid_dungeon.hide_enemy_player_totems = value
				Plater.RefreshAutoToggle()
			end,
			name = L["OPTIONS_AUTO_HIDE_ENEMY_TOTEMS"],
			desc = L["OPTIONS_AUTO_HIDE_ENEMY_TOTEMS_DESC"],
			group = "combat_toggles",
		},

		{type = "breakline"},
		{type = "breakline"},

		{type = "label", get = function() return L["OPTIONS_AUTO_SECTIONTITLE_FRIENDLY_NAMEPLATES"] end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"), group = "combat_toggles"},

		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_toggle_friendly_enabled end,
			set = function (self, fixedparam, value)
				Plater.db.profile.auto_toggle_friendly_enabled = value

				Plater.RefreshDBUpvalues()
				Plater.UpdateAllPlates()
				Plater.RefreshAutoToggle()
			end,
			name = "OPTIONS_ENABLED",
			desc = "When enabled, Plater will enable or disable friendly plates based on the settings below.",
			group = "combat_toggles",
		},

		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_toggle_friendly ["party"] end,
			set = function (self, fixedparam, value)
				Plater.db.profile.auto_toggle_friendly ["party"] = value
				Plater.RefreshAutoToggle()
			end,
			name = L["OPTIONS_AUTO_FRIENDLY_IN_DUNGEONS"],
			desc = L["OPTIONS_AUTO_FRIENDLY_IN_DUNGEONS_DESC"],
			group = "combat_toggles",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_toggle_friendly ["raid"] end,
			set = function (self, fixedparam, value)
				Plater.db.profile.auto_toggle_friendly ["raid"] = value
				Plater.RefreshAutoToggle()
			end,
			name = L["OPTIONS_AUTO_FRIENDLY_IN_RAID"],
			desc = L["OPTIONS_AUTO_FRIENDLY_IN_RAID_DESC"],
			group = "combat_toggles",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_toggle_friendly ["arena"] end,
			set = function (self, fixedparam, value)
				Plater.db.profile.auto_toggle_friendly ["arena"] = value
				Plater.RefreshAutoToggle()
			end,
			name = L["OPTIONS_AUTO_FRIENDLY_IN_ARENA_BG"],
			desc = L["OPTIONS_AUTO_FRIENDLY_IN_ARENA_BG_DESC"],
			group = "combat_toggles",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_toggle_friendly ["cities"] end,
			set = function (self, fixedparam, value)
				Plater.db.profile.auto_toggle_friendly ["cities"] = value
				Plater.RefreshAutoToggle()
			end,
			name = L["OPTIONS_AUTO_FRIENDLY_IN_MAJOR_CITIES"],
			desc = L["OPTIONS_AUTO_FRIENDLY_IN_MAJOR_CITIES_DESC"],
			group = "combat_toggles",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_toggle_friendly ["world"] end,
			set = function (self, fixedparam, value)
				Plater.db.profile.auto_toggle_friendly ["world"] = value
				Plater.RefreshAutoToggle()
			end,
			name = L["OPTIONS_AUTO_FRIENDLY_IN_OPEN_WORLD"],
			desc = L["OPTIONS_AUTO_FRIENDLY_IN_OPEN_WORLD_DESC"],
			group = "combat_toggles",
		},

		--test
		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_toggle_friendly ["cities"] end,
			set = function (self, fixedparam, value)
				Plater.db.profile.auto_toggle_friendly ["cities"] = value
				Plater.RefreshAutoToggle()
			end,
			name = L["OPTIONS_AUTO_FRIENDLY_IN_MAJOR_CITIES"],
			desc = L["OPTIONS_AUTO_FRIENDLY_IN_MAJOR_CITIES_DESC"],
			group = "combat_toggles",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_toggle_friendly ["world"] end,
			set = function (self, fixedparam, value)
				Plater.db.profile.auto_toggle_friendly ["world"] = value
				Plater.RefreshAutoToggle()
			end,
			name = L["OPTIONS_AUTO_FRIENDLY_IN_OPEN_WORLD"],
			desc = L["OPTIONS_AUTO_FRIENDLY_IN_OPEN_WORLD_DESC"],
			group = "combat_toggles",
		},

		{type = "blank"},

		{type = "label", get = function() return L["OPTIONS_AUTO_SECTIONTITLE_ENEMY_NAMEPLATES"] end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"), group = "combat_toggles",},

		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_toggle_enemy_enabled end,
			set = function (self, fixedparam, value)
				Plater.db.profile.auto_toggle_enemy_enabled = value

				Plater.RefreshDBUpvalues()
				Plater.UpdateAllPlates()
				Plater.RefreshAutoToggle()
			end,
			name = L["OPTIONS_ENABLED"],
			desc = "When enabled, Plater will enable or disable enemy plates based on the settings below.",
			group = "combat_toggles",
		},

		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_toggle_enemy ["party"] end,
			set = function (self, fixedparam, value)
				Plater.db.profile.auto_toggle_enemy ["party"] = value
				Plater.RefreshAutoToggle()
			end,
			name = L["OPTIONS_AUTO_ENEMY_IN_DUNGEONS"],
			desc = L["OPTIONS_AUTO_ENEMY_IN_DUNGEONS_DESC"],
			group = "combat_toggles",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_toggle_enemy ["raid"] end,
			set = function (self, fixedparam, value)
				Plater.db.profile.auto_toggle_enemy ["raid"] = value
				Plater.RefreshAutoToggle()
			end,
			name = L["OPTIONS_AUTO_ENEMY_IN_RAID"],
			desc = L["OPTIONS_AUTO_ENEMY_IN_RAID_DESC"],
			group = "combat_toggles",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_toggle_enemy ["arena"] end,
			set = function (self, fixedparam, value)
				Plater.db.profile.auto_toggle_enemy ["arena"] = value
				Plater.RefreshAutoToggle()
			end,
			name = L["OPTIONS_AUTO_ENEMY_IN_ARENA_BG"],
			desc = L["OPTIONS_AUTO_ENEMY_IN_ARENA_BG_DESC"],
			group = "combat_toggles",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_toggle_enemy ["cities"] end,
			set = function (self, fixedparam, value)
				Plater.db.profile.auto_toggle_enemy ["cities"] = value
				Plater.RefreshAutoToggle()
			end,
			name = L["OPTIONS_AUTO_ENEMY_IN_MAJOR_CITIES"],
			desc = L["OPTIONS_AUTO_ENEMY_IN_MAJOR_CITIES_DESC"],
			group = "combat_toggles",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_toggle_enemy ["world"] end,
			set = function (self, fixedparam, value)
				Plater.db.profile.auto_toggle_enemy ["world"] = value
				Plater.RefreshAutoToggle()
			end,
			name = L["OPTIONS_AUTO_ENEMY_IN_OPEN_WORLD"],
			desc = L["OPTIONS_AUTO_ENEMY_IN_OPEN_WORLD_DESC"],
			group = "combat_toggles",
		},

		{type = "breakline"},
		{type = "breakline"},

		{type = "label", get = function() return L["OPTIONS_AUTO_SECTIONTITLE_STACKING_NAMEPLATES"] end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"), group = "three"},

		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_toggle_stacking_enabled end,
			set = function (self, fixedparam, value)
				Plater.db.profile.auto_toggle_stacking_enabled = value

				Plater.RefreshDBUpvalues()
				Plater.UpdateAllPlates()
				Plater.RefreshAutoToggle()
			end,
			name = "OPTIONS_ENABLED",
			desc = "When enabled, Plater will enable or disable stacking nameplates based on the settings below.\n\n|cFFFFFF00 Important |r: only toggle on if 'Stacking Nameplates' is enabled in the General Settings tab.",
			group = "three",
		},

		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_toggle_stacking ["party"] end,
			set = function (self, fixedparam, value)
				Plater.db.profile.auto_toggle_stacking ["party"] = value
				Plater.RefreshAutoToggle()
			end,
			name = L["OPTIONS_AUTO_STACKING_IN_DUNGEONS"],
			desc = L["OPTIONS_AUTO_STACKING_IN_DUNGEONS_DESC"],
			group = "three",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_toggle_stacking ["raid"] end,
			set = function (self, fixedparam, value)
				Plater.db.profile.auto_toggle_stacking ["raid"] = value
				Plater.RefreshAutoToggle()
			end,
			name = L["OPTIONS_AUTO_STACKING_IN_RAID"],
			desc = L["OPTIONS_AUTO_STACKING_IN_RAID_DESC"],
			group = "three",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_toggle_stacking ["arena"] end,
			set = function (self, fixedparam, value)
				Plater.db.profile.auto_toggle_stacking ["arena"] = value
				Plater.RefreshAutoToggle()
			end,
			name = L["OPTIONS_AUTO_STACKING_IN_ARENA_BG"],
			desc = L["OPTIONS_AUTO_STACKING_IN_ARENA_BG_DESC"],
			group = "three",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_toggle_stacking ["cities"] end,
			set = function (self, fixedparam, value)
				Plater.db.profile.auto_toggle_stacking ["cities"] = value
				Plater.RefreshAutoToggle()
			end,
			name = L["OPTIONS_AUTO_STACKING_IN_MAJOR_CITIES"],
			desc = L["OPTIONS_AUTO_STACKING_IN_MAJOR_CITIES_DESC"],
			group = "three",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_toggle_stacking ["world"] end,
			set = function (self, fixedparam, value)
				Plater.db.profile.auto_toggle_stacking ["world"] = value
				Plater.RefreshAutoToggle()
			end,
			name = L["OPTIONS_AUTO_STACKING_IN_OPEN_WORLD"],
			desc = L["OPTIONS_AUTO_STACKING_IN_OPEN_WORLD_DESC"],
			group = "three",
		},

		{type = "blank"},
		{type = "label", get = function() return L["OPTIONS_AUTO_SECTIONTITLE_ALWAYS_SHOW_NAMEPLATES"] end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"), group = "one"},

		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_toggle_always_show_enabled end,
			set = function (self, fixedparam, value)
				Plater.db.profile.auto_toggle_always_show_enabled = value

				Plater.RefreshDBUpvalues()
				Plater.UpdateAllPlates()
				Plater.RefreshAutoToggle()
			end,
			name = "OPTIONS_ENABLED",
			desc = "When enabled, Plater will enable or disable 'always show nameplates' based on the settings below.",
			group = "one",
		},

		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_toggle_always_show ["party"] end,
			set = function (self, fixedparam, value)
				Plater.db.profile.auto_toggle_always_show ["party"] = value
				Plater.RefreshAutoToggle()
			end,
			name = L["OPTIONS_AUTO_ALWAYS_SHOW_IN_DUNGEONS"],
			desc = L["OPTIONS_AUTO_ALWAYS_SHOW_IN_DUNGEONS_DESC"],
			group = "one",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_toggle_always_show ["raid"] end,
			set = function (self, fixedparam, value)
				Plater.db.profile.auto_toggle_always_show ["raid"] = value
				Plater.RefreshAutoToggle()
			end,
			name = L["OPTIONS_AUTO_ALWAYS_SHOW_IN_RAID"],
			desc = L["OPTIONS_AUTO_ALWAYS_SHOW_IN_RAID_DESC"],
			group = "one",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_toggle_always_show ["arena"] end,
			set = function (self, fixedparam, value)
				Plater.db.profile.auto_toggle_always_show ["arena"] = value
				Plater.RefreshAutoToggle()
			end,
			name = L["OPTIONS_AUTO_ALWAYS_SHOW_IN_ARENA_BG"],
			desc = L["OPTIONS_AUTO_ALWAYS_SHOW_IN_ARENA_BG_DESC"],
			group = "one",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_toggle_always_show ["cities"] end,
			set = function (self, fixedparam, value)
				Plater.db.profile.auto_toggle_always_show ["cities"] = value
				Plater.RefreshAutoToggle()
			end,
			name = L["OPTIONS_AUTO_ALWAYS_SHOW_IN_MAJOR_CITIES"],
			desc = L["OPTIONS_AUTO_ALWAYS_SHOW_IN_MAJOR_CITIES_DESC"],
			group = "one",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_toggle_always_show ["world"] end,
			set = function (self, fixedparam, value)
				Plater.db.profile.auto_toggle_always_show ["world"] = value
				Plater.RefreshAutoToggle()
			end,
			name = L["OPTIONS_AUTO_ALWAYS_SHOW_IN_OPEN_WORLD"],
			desc = L["OPTIONS_AUTO_ALWAYS_SHOW_IN_OPEN_WORLD_DESC"],
			group = "one",
		},
	}

    ---@diagnostic disable-next-line: undefined-global
    local automationFrame = PlaterOptionsPanelContainerAutomation

    auto_options.always_boxfirst = true
    auto_options.language_addonId = addonId
    auto_options.Name = "Auto Options"
    local startX, startY, heightSize = 10, platerInternal.optionsYStart, 755

    DF:BuildMenu(automationFrame, auto_options, startX, startY, heightSize, false, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template, platerInternal.OptionsGlobalCallback)

    platerInternal.LoadOnDemand_IsLoaded.AutomationOptions = true
    ---@diagnostic disable-next-line: undefined-global
    table.insert(PlaterOptionsPanelFrame.AllSettingsTable, automation_options)
	platerInternal.CreateAutomationOptions = function() end
end