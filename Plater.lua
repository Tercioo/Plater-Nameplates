
-- todo check code with review tag --review

 if (true) then
	--return
	--but not today
end

--/run UIErrorsFrame:HookScript ("OnEnter", function() UIErrorsFrame:EnableMouse (false);Plater:Msg("UIErrorsFrame had MouseEnabled, its disabled now.") end)
--some WA or addon are enabling the mouse on the error frame making nameplates unclickable
if (UIErrorsFrame) then
	UIErrorsFrame:HookScript ("OnEnter", function()
		--safe disable the mouse on error frame avoiding mouse interactions and warn the user
		UIErrorsFrame:EnableMouse (false)
		Plater:Msg ("something enabled the mouse on UIErrorsFrame, Plater disabled.")
	end)
	UIErrorsFrame:EnableMouse (false)
end

--details! framework
local DF = _G ["DetailsFramework"]
if (not DF) then
	print ("|cFFFFAA00Plater: framework not found, if you just installed or updated the addon, please restart your client.|r")
	return
end

--blend nameplates with the worldframe
local AlphaBlending = ALPHA_BLEND_AMOUNT + 0.0654785

--locals
local unpack = unpack
local ipairs = ipairs
local pairs = pairs
local InCombatLockdown = InCombatLockdown
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local CompareBit = bit.band
local UnitIsPlayer = UnitIsPlayer
local UnitClassification = UnitClassification
local UnitDetailedThreatSituation = UnitDetailedThreatSituation
local UnitAura = UnitAura
local UnitCanAttack = UnitCanAttack
local IsSpellInRange = IsSpellInRange
local abs = math.abs
local format = string.format
local GetSpellInfo = GetSpellInfo
local UnitIsUnit = UnitIsUnit
local type = type
local tonumber = tonumber
local select = select
local UnitGUID = UnitGUID
local strsplit = strsplit
local lower = string.lower
local floor = floor
local max = math.max
local min = math.min

local GameCooltip = GameCooltip2

--endd
--dump color palette
--[=[
local a = CreateFrame ("frame", nil, UIParent)
a:SetSize (1400, 900)
a:SetPoint ("topleft", UIParent, "topleft")
local x = 5
local y = -20
for colorname, colortable in pairs (DF.alias_text_colors) do
	local f = a:CreateTexture (nil, "overlay")
	f:SetColorTexture (unpack (colortable))
	f:SetSize (100, 20)
	f:SetPoint ("topleft", a, "topleft", x, y)
	local t = a:CreateFontString (nil, "overlay", "GameFontNormal")
	t:SetPoint ("center", f, "center")
	t:SetText (colorname)
	y = y - 20
	if (y < -880) then
		y = -20
		x = x + 105
	end
end
--]=]

local LibSharedMedia = LibStub:GetLibrary ("LibSharedMedia-3.0")

LibSharedMedia:Register ("statusbar", "DGround", [[Interface\AddOns\Plater\images\bar_background]])

LibSharedMedia:Register ("statusbar", "Details D'ictum", [[Interface\AddOns\Plater\images\bar4]])
LibSharedMedia:Register ("statusbar", "Details Vidro", [[Interface\AddOns\Plater\images\bar4_vidro]])
LibSharedMedia:Register ("statusbar", "Details D'ictum (reverse)", [[Interface\AddOns\Plater\images\bar4_reverse]])
LibSharedMedia:Register ("statusbar", "Details Serenity", [[Interface\AddOns\Plater\images\bar_serenity]])
LibSharedMedia:Register ("statusbar", "BantoBar", [[Interface\AddOns\Plater\images\BantoBar]])
LibSharedMedia:Register ("statusbar", "Skyline", [[Interface\AddOns\Plater\images\bar_skyline]])
LibSharedMedia:Register ("statusbar", "WorldState Score", [[Interface\WorldStateFrame\WORLDSTATEFINALSCORE-HIGHLIGHT]])
LibSharedMedia:Register ("statusbar", "Details Flat", [[Interface\AddOns\Plater\images\bar_background]])
LibSharedMedia:Register ("statusbar", "DGround", [[Interface\AddOns\Plater\images\bar_background]])
LibSharedMedia:Register ("statusbar", "PlaterBackground", [[Interface\AddOns\Plater\images\platebackground]])
LibSharedMedia:Register ("statusbar", "PlaterTexture", [[Interface\AddOns\Plater\images\platetexture]])
LibSharedMedia:Register ("statusbar", "PlaterHighlight", [[Interface\AddOns\Plater\images\plateselected]])
LibSharedMedia:Register ("statusbar", "PlaterFocus", [[Interface\AddOns\Plater\images\overlay_indicator_1]])
LibSharedMedia:Register ("statusbar", "PlaterHealth", [[Interface\AddOns\Plater\images\nameplate_health_texture]])

LibSharedMedia:Register ("statusbar", "testbar", [[Interface\AddOns\Plater\images\testbar.tga]])
--LibSharedMedia:Register ("statusbar", "testbarBLP", [[Interface\AddOns\Plater\images\testbar]])

LibSharedMedia:Register ("font", "Oswald", [[Interface\Addons\Plater\fonts\Oswald-Regular.otf]])
LibSharedMedia:Register ("font", "Nueva Std Cond", [[Interface\Addons\Plater\fonts\NuevaStd-Cond.otf]])
LibSharedMedia:Register ("font", "Accidental Presidency", [[Interface\Addons\Plater\fonts\Accidental Presidency.ttf]])
LibSharedMedia:Register ("font", "TrashHand", [[Interface\Addons\Plater\fonts\TrashHand.TTF]])
LibSharedMedia:Register ("font", "Harry P", [[Interface\Addons\Plater\fonts\HARRYP__.TTF]])
LibSharedMedia:Register ("font", "FORCED SQUARE", [[Interface\Addons\Plater\fonts\FORCED SQUARE.ttf]])

--font templates
DF:InstallTemplate ("font", "PLATER_SCRIPTS_NAME", {color = "orange", size = 10, font = "Friz Quadrata TT"})
DF:InstallTemplate ("font", "PLATER_SCRIPTS_TYPE", {color = "gray", size = 9, font = "Friz Quadrata TT"})
DF:InstallTemplate ("font", "PLATER_SCRIPTS_TRIGGER_SPELLID", {color = {0.501961, 0.501961, 0.501961, .5}, size = 9, font = "Friz Quadrata TT"})
DF:InstallTemplate ("font", "PLATER_BUTTON", {color = {1, .8, .2}, size = 10, font = "Friz Quadrata TT"})
DF:InstallTemplate ("font", "PLATER_BUTTON_DISABLED", {color = {1/3, .8/3, .2/3}, size = 10, font = "Friz Quadrata TT"})

--button templates
DF:InstallTemplate ("button", "PLATER_BUTTON_DISABLED", {backdropcolor = {.4, .4, .4, .3}, backdropbordercolor = {0, 0, 0, .5}}, "OPTIONS_BUTTON_TEMPLATE")

DF:NewColor ("PLATER_FRIEND", .71, 1, 1, 1)
DF:NewColor ("PLATER_GUILD", 0.498039, 1, .2, 1)

DF:NewColor ("PLATER_DEBUFF", 1, 0.7117, 0.7117, 1)
DF:NewColor ("PLATER_BUFF", 0.7117, 1, 0.7509, 1)
DF:NewColor ("PLATER_CAST", 0.7117, 0.7784, 1, 1)

--defining reaction constants here isnce they are used within the profile
local UNITREACTION_HOSTILE = 3
local UNITREACTION_NEUTRAL = 4
local UNITREACTION_FRIENDLY = 5

local _
local default_config = {
	
	profile = {
	
		--> save some cvars values so it can restore when a new character login using Plater
		saved_cvars = {},
	
		keybinds = {},
	
		click_space = {140, 28},
		click_space_friendly = {140, 28},
		click_space_always_show = false,
		hide_friendly_castbars = false,
		hide_enemy_castbars = false,
		
		plate_config  = {
			friendlyplayer = {
				enabled = true,
				plate_order = 3,
				only_damaged = true,
				only_thename = true,
				click_through = true,
				show_guild_name = true,
				
				health = {70, 2},
				health_incombat = {70, 2},
				cast = {80, 8},
				cast_incombat = {80, 12},
				mana = {100, 3},
				mana_incombat = {100, 3},
				buff_frame_y_offset = 10,
				
				actorname_text_spacing = 10,
				actorname_text_size = 10,
				actorname_text_font = "Arial Narrow",
				actorname_text_color = {1, 1, 1, 1},
				actorname_text_shadow = true,
				actorname_text_anchor = {side = 8, x = 0, y = 0},
				
				spellname_text_size = 10,
				spellname_text_font = "Arial Narrow",
				spellname_text_color = {1, 1, 1, 1},
				spellname_text_shadow = false,
				spellname_text_anchor = {side = 9, x = 0, y = 0},
				
				spellpercent_text_enabled = false,
				spellpercent_text_size = 10,
				spellpercent_text_font = "Arial Narrow",
				spellpercent_text_color = {1, 1, 1, 1},
				spellpercent_text_shadow = true,
				spellpercent_text_anchor = {side = 11, x = -2, y = 0},
				
				level_text_enabled = false,
				level_text_anchor = {side = 7, x = 0, y = 1},
				level_text_size = 10,
				level_text_font = "Arial Narrow",
				level_text_shadow = false,
				level_text_alpha = 0.3,
				
				percent_text_enabled = false,
				percent_text_show_decimals = false,
				percent_text_ooc = false,
				percent_show_health = false,
				percent_text_size = 9,
				percent_text_font = "Arial Narrow",
				percent_text_shadow = true,
				percent_text_color = {.9, .9, .9, 1},
				percent_text_anchor = {side = 9, x = 0, y = 0},
				percent_text_alpha = 1,
			},
			
			enemyplayer = {
				enabled = true,
				plate_order = 3,
				show_guild_name = true,
				
				use_playerclass_color = true,
				fixed_class_color = {1, .4, .1},
				
				health = {112, 10},
				health_incombat = {112, 10},
				cast = {134, 12},
				cast_incombat = {134, 12},
				mana = {100, 3},
				mana_incombat = {100, 3},
				buff_frame_y_offset = 0,
				
				actorname_text_spacing = 12,
				actorname_text_size = 12,
				actorname_text_font = "Arial Narrow",
				actorname_text_color = {1, 1, 1, 1},
				actorname_text_shadow = false,
				actorname_text_anchor = {side = 4, x = 0, y = 0},
				
				spellname_text_size = 10,
				spellname_text_font = "Arial Narrow",
				spellname_text_color = {1, 1, 1, 1},
				spellname_text_shadow = false,
				spellname_text_anchor = {side = 9, x = 0, y = 0},
				
				spellpercent_text_enabled = true,
				spellpercent_text_size = 10,
				spellpercent_text_font = "Arial Narrow",
				spellpercent_text_color = {1, 1, 1, 1},
				spellpercent_text_shadow = true,
				spellpercent_text_anchor = {side = 11, x = -2, y = 0},
				
				level_text_enabled = true,
				level_text_anchor = {side = 7, x = 0, y = 1},
				level_text_size = 10,
				level_text_font = "Arial Narrow",
				level_text_shadow = false,
				level_text_alpha = 0.3,
				
				percent_text_enabled = true,
				percent_text_show_decimals = true,
				percent_text_ooc = true,
				percent_show_health = true,
				percent_text_size = 9,
				percent_text_font = "Arial Narrow",
				percent_text_shadow = true,
				percent_text_color = {.9, .9, .9, 1},
				percent_text_anchor = {side = 9, x = 0, y = 0},
				percent_text_alpha = 1,
				
				big_actortitle_text_size = 11,
				big_actortitle_text_font = "Arial Narrow",
				big_actortitle_text_color = {1, .8, .0},
				big_actortitle_text_shadow = true,
				big_actorname_text_size = 9,
				big_actorname_text_font = "Arial Narrow",
				big_actorname_text_color = {.5, 1, .5},
				big_actorname_text_shadow = true,
			},

			friendlynpc = {
				only_names = true,
				all_names = false,
				relevance_state = 3,
				plate_order = 3,
				enabled = true,
				
				health = {100, 2},
				health_incombat = {100, 2},
				cast = {100, 12},
				cast_incombat = {100, 12},
				mana = {100, 3},
				mana_incombat = {100, 3},
				buff_frame_y_offset = 0,
				
				actorname_text_spacing = 10,
				actorname_text_size = 10,
				actorname_text_font = "Arial Narrow",
				actorname_text_color = {1, 1, 1, 1},
				actorname_text_shadow = false,
				actorname_text_anchor = {side = 8, x = 0, y = 0},
				
				spellname_text_size = 10,
				spellname_text_font = "Arial Narrow",
				spellname_text_color = {1, 1, 1, 1},
				spellname_text_shadow = false,
				spellname_text_anchor = {side = 9, x = 0, y = 0},
				
				spellpercent_text_enabled = false,
				spellpercent_text_size = 10,
				spellpercent_text_font = "Arial Narrow",
				spellpercent_text_color = {1, 1, 1, 1},
				spellpercent_text_shadow = true,
				spellpercent_text_anchor = {side = 11, x = -2, y = 0},
				
				level_text_enabled = false,
				level_text_anchor = {side = 7, x = 0, y = 1},
				level_text_size = 10,
				level_text_font = "Arial Narrow",
				level_text_shadow = false,
				level_text_alpha = 0.3,
				
				percent_text_enabled = false,
				percent_text_show_decimals = false,
				percent_text_ooc = false,
				percent_show_health = false,
				percent_text_size = 9,
				percent_text_font = "Arial Narrow",
				percent_text_shadow = true,
				percent_text_color = {.9, .9, .9, 1},
				percent_text_anchor = {side = 9, x = 0, y = 0},
				percent_text_alpha = 1,
				
				quest_enabled = true,
				quest_color = {.5, 1, 0},
				
				big_actortitle_text_size = 11,
				big_actortitle_text_font = "Arial Narrow",
				big_actortitle_text_color = {1, .8, .0},
				big_actortitle_text_shadow = true,
				
				big_actorname_text_size = 9,
				big_actorname_text_font = "Arial Narrow",
				big_actorname_text_color = {.5, 1, .5},
				big_actorname_text_shadow = true,
			},
			
			enemynpc = {
				enabled = true,
				plate_order = 3,
				all_names = true,
				
				health = {92, 9},
				health_incombat = {112, 9},
				cast = {124, 12},
				cast_incombat = {124, 12},
				mana = {100, 3},
				mana_incombat = {100, 3},
				buff_frame_y_offset = 0,
				
				actorname_text_spacing = 12,
				actorname_text_size = 11,
				actorname_text_font = "Arial Narrow",
				actorname_text_color = {1, 1, 1, 1},
				actorname_text_shadow = false,
				actorname_text_anchor = {side = 4, x = 0, y = 0},
				
				spellname_text_size = 12,
				spellname_text_font = "Arial Narrow",
				spellname_text_color = {1, 1, 1, 1},
				spellname_text_shadow = true,
				spellname_text_anchor = {side = 9, x = 0, y = 0},
				
				spellpercent_text_enabled = true,
				spellpercent_text_size = 10,
				spellpercent_text_font = "Arial Narrow",
				spellpercent_text_color = {1, 1, 1, 1},
				spellpercent_text_shadow = true,
				spellpercent_text_anchor = {side = 11, x = -2, y = 0},
				
				level_text_enabled = true,
				level_text_anchor = {side = 7, x = 0, y = 1},
				level_text_size = 8,
				level_text_font = "Arial Narrow",
				level_text_shadow = false,
				level_text_alpha = 0.3,
				
				percent_text_enabled = true,
				percent_text_show_decimals = true,
				percent_text_ooc = false,
				percent_show_health = false,
				percent_text_size = 9,
				percent_text_font = "Arial Narrow",
				percent_text_shadow = true,
				percent_text_color = {.9, .9, .9, 1},
				percent_text_anchor = {side = 9, x = 0, y = 0},
				percent_text_alpha = 1,
				
				quest_enabled = true,
				quest_color_enemy = {1, .369, 0},
				quest_color_neutral = {1, .65, 0},
				
				--no color / it'll auto colour by the reaction
				big_actortitle_text_size = 11,
				big_actortitle_text_font = "Arial Narrow",
				big_actortitle_text_shadow = true,
				--big_actortitle_text_color = {1, .8, .0},
				
				big_actorname_text_size = 9,
				big_actorname_text_font = "Arial Narrow",
				big_actorname_text_shadow = true,
				--big_actorname_text_color = {.5, 1, .5},
			},
	
			player = {
				enabled = true,
				click_through = false,
				plate_order = 3,
				health = {150, 12},
				health_incombat = {150, 12},
				cast = {140, 8},
				cast_incombat = {140, 12},
				mana = {150, 8},
				mana_incombat = {150, 8},
				buff_frame_y_offset = 0,
				y_position_offset = -50, --deprecated
				pvp_always_incombat = true,
				
				actorname_text_spacing = 10,
				actorname_text_size = 10,
				actorname_text_font = "Arial Narrow",
				actorname_text_color = {1, 1, 1, 1},
				actorname_text_shadow = false,
				actorname_text_anchor = {side = 8, x = 0, y = 0},
				
				spellname_text_size = 10,
				spellname_text_font = "Arial Narrow",
				spellname_text_color = {1, 1, 1, 1},
				spellname_text_shadow = false,
				spellname_text_anchor = {side = 9, x = 0, y = 0},
				
				level_text_enabled = false,
				level_text_anchor = {side = 7, x = 0, y = 1},
				level_text_size = 10,
				level_text_font = "Arial Narrow",
				level_text_shadow = false,
				level_text_alpha = 0.3,
				
				percent_text_enabled = true,
				percent_text_size = 9,
				percent_text_font = "Arial Narrow",
				percent_text_shadow = true,
				percent_text_color = {.9, .9, .9, 1},
				percent_text_anchor = {side = 9, x = 0, y = 0},
				percent_text_alpha = 1,
				percent_text_ooc = false,
				
				power_percent_text_enabled = true,
				power_percent_text_size = 9,
				power_percent_text_font = "Arial Narrow",
				power_percent_text_shadow = true,
				power_percent_text_color = {.9, .9, .9, 1},
				power_percent_text_anchor = {side = 9, x = 0, y = 0},
				power_percent_text_alpha = 1,
			},
		},
		
		resources = {
			scale = 1,
			y_offset = 0,
			y_offset_target = 28,
		},
		
		--> special unit
		pet_width_scale = 0.7,
		pet_height_scale = 1,
		minor_width_scale = 0.7,
		minor_height_scale = 1,
		
		castbar_target_show = false,
		castbar_target_anchor = {side = 5, x = 0, y = 0},
		castbar_target_text_size = 10,
		castbar_target_shadow = true,
		castbar_target_color = {1, 1, 1, 1},
		castbar_target_font = "Arial Narrow",
		
		--> store spells from the latest event the player has been into
		captured_spells = {},

		script_data = {},
		script_data_trash = {}, --deleted scripts are placed here, they can be restored in 30 days
		script_auto_imported = {}, --store the name and revision of scripts imported from the Plater script library
		script_banned_user = {}, --players banned from sending scripts to this player
		
		patch_version = 0,
		
		health_cutoff = true,
		health_cutoff_extra_glow = false,
		
		update_throttle = 0.25000000,
		culling_distance = 100,
		use_playerclass_color = true, --friendly player
		
		use_health_animation = false,
		health_animation_time_dilatation = 2.615321,
		
		use_color_lerp = true,
		color_lerp_speed = 12,
		
		height_animation = false,
		height_animation_speed = 15,
		
		healthbar_framelevel = 0,
		castbar_framelevel = 0,
		
		aura_enabled = true,
		aura_show_tooltip = false,
		aura_width = 26,
		aura_height = 16,
		
		--> aura frame 1
		aura_x_offset = 0,
		aura_y_offset = 0,
		aura_grow_direction = 2, --> center
		
		--> aura frame 2
		buffs_on_aura2 = false,
		aura2_x_offset = 0,
		aura2_y_offset = 0,
		aura2_grow_direction = 2, --> center
		
		aura_alpha = 0.85,
		aura_custom = {},
		
		--use blizzard aura tracking
		aura_use_default = false,
		
		aura_timer = true,
		aura_timer_text_size = 15,
		aura_timer_text_anchor = {side = 9, x = 0, y = 0},
		aura_timer_text_shadow = true,
		aura_timer_text_color = {1, 1, 1, 1},

		aura_stack_anchor = {side = 8, x = 0, y = 0},
		aura_stack_size = 10,
		aura_stack_shadow = true,
		aura_stack_color = {1, 1, 1, 1},
		
		extra_icon_anchor = {side = 6, x = -4, y = 4},
		extra_icon_show_timer = true,
		extra_icon_width = 30,
		extra_icon_height = 18,
		extra_icon_wide_icon = true,
		extra_icon_caster_name = true,
		extra_icon_backdrop_color = {0, 0, 0, 0.5},
		extra_icon_border_color = {0, 0, 0, 1},
		
		debuff_show_cc = true, --extra frame show cc
		debuff_show_cc_border = {.3, .2, .2, 1},
		extra_icon_show_purge = false, --extra frame show purge
		extra_icon_show_purge_border = {0, .925, 1, 1},
		
		extra_icon_auras = {},
		
		aura_width_personal = 32,
		aura_height_personal = 20,
		aura_show_buffs_personal = true,
		aura_show_debuffs_personal = true,
		
		aura_show_important = true,
		aura_show_dispellable = true,
		aura_show_aura_by_the_player = true,
		aura_show_buff_by_the_unit = true,
		
		aura_border_colors = {
			steal_or_purge = {0, .5, .98, 1},
			is_buff = {0, .65, .1, 1},
			is_show_all = {.7, .1, .1, 1},
		},
		
		aura_tracker = {
			buff = {},
			debuff = {},
			buff_ban_percharacter = {},
			debuff_ban_percharacter = {},
			options = {},
			track_method = 0x1,
			buff_banned = { 
				--banner of alliance and horde on training dummies
				[61574] = true, 
				[61573] = true,
				--challenger's might on mythic+
				[206150] = true, 
			},
			debuff_banned = {},
			buff_tracked = {},
			debuff_tracked = {},
		},
		
		not_affecting_combat_enabled = false,
		not_affecting_combat_alpha = .63,
		range_check_enabled = true,
		range_check_alpha = 0.5,
		target_highlight = true,
		target_highlight_alpha = .5,
		
		target_shady_alpha = 0.55,
		target_shady_enabled = true,
		target_shady_combat_only = true,
		
		hover_highlight = true,
		highlight_on_hover_unit_model = false,
		hover_highlight_alpha = .33,
		
		auto_toggle_friendly_enabled = false,
		auto_toggle_friendly = {
			["party"] = false,
			["raid"] = false,
			["arena"] = false,
			["world"] =  true,
			["cities"] = true,
		},
		
		stacking_nameplates_enabled = true,
		
		auto_toggle_stacking_enabled = false,
		auto_toggle_stacking = {
			["party"] = true,
			["raid"] = true,
			["arena"] = true,
			["world"] =  true,
			["cities"] = false,
		},
		
		spell_animations = true,
		spell_animations_scale = 1.25,
		
		spell_animation_list = {
		
			--chaos bolt
			[116858] = {
				{
					enabled = true,
					duration = 0.075, --seconds
					animation_type = "scale",
					cooldown = 0.75, --seconds
					scale_upX = 1.075,
					scale_upY = 1.075,
					scale_downX = 0.915,
					scale_downY = 0.915,
				},
				{
					enabled = true,
					animation_type = "frameshake",
					scaleX = 0.1,
					scaleY = 1,
					absolute_sineX = false,
					absolute_sineY = false,
					duration = 0.15,
					amplitude = 2,
					frequency = 60,
					fade_in = 0.05,
					fade_out = 0.10,
					cooldown = 0.25,
				},
			},
		
			--seed of corruption
			[27285] = {
				{
					enabled = true,
					duration = 0.075, --seconds
					animation_type = "scale",
					cooldown = 0.75, --seconds
					scale_upX = 1.1,
					scale_upY = 1.1,
					scale_downX = 0.9,
					scale_downY = 0.9,
				}
			},
			
			--hand of guldan
			[86040] = {
				{
					enabled = true,
					animation_type = "frameshake",
					scaleX = 0.1,
					scaleY = 1,
					absolute_sineX = false,
					absolute_sineY = false,
					duration = 0.15,
					amplitude = 2,
					frequency = 20,
					fade_in = 0.05,
					fade_out = 0.10,
					cooldown = 0.25,
				}
			},
			
			--demonbolt
			[264178] = {
				{
					enabled = true,
					animation_type = "frameshake",
					scaleX = .2,
					scaleY = 1,
					absolute_sineX = false,
					absolute_sineY = false,
					duration = 0.15,
					amplitude = 3,
					frequency = 25,
					fade_in = 0.01,
					fade_out = 0.08,
					cooldown = 0.25,
				}
			},
			
			--implosion
			[196278] = {
				{
					enabled = true,
					animation_type = "frameshake",
					scaleX = .2,
					scaleY = 1,
					absolute_sineX = false,
					absolute_sineY = false,
					duration = 0.05,
					amplitude = 0.75,
					frequency = 200,
					fade_in = 0.01,
					fade_out = 0.01,
					cooldown = 0.0,
				}
			},
			
			--sinister strike (outlaw)
			[197834] = {
				{
					enabled = true,
					animation_type = "frameshake",
					scaleX = .1,
					scaleY = 1,
					absolute_sineX = false,
					absolute_sineY = false,
					duration = 0.12,
					amplitude = 1,
					frequency = 25,
					fade_in = 0.01,
					fade_out = 0.02,
					cooldown = 0.5,
				}
			},
			
			--eviscerate (subtlety)
			[196819] = {
				{
					enabled = true,
					duration = 0.04, --seconds
					animation_type = "scale",
					cooldown = 0.75, --seconds
					scale_upX = 1.1,
					scale_upY = 1.1,
					scale_downX = 0.9,
					scale_downY = 0.9,
				},
				{
					enabled = true,
					animation_type = "frameshake",
					scaleX = 1,
					scaleY = 1,
					absolute_sineX = false,
					absolute_sineY = true,
					duration = 0.08,
					amplitude = 10,
					frequency = 4.1,
					fade_in = 0.01,
					fade_out = 0.18,
					cooldown = 0.5,
				}
			},
			
			--mutilate (assassination)
			[5374] = {
				{
					enabled = true,
					animation_type = "frameshake",
					scaleX = .1,
					scaleY = 1,
					absolute_sineX = false,
					absolute_sineY = false,
					duration = 0.12,
					amplitude = 1,
					frequency = 25,
					fade_in = 0.01,
					fade_out = 0.02,
					cooldown = 0.5,
				}
			},
			
			--envenom (assassination)
			[32645] = {
				{
					enabled = true,
					duration = 0.04, --seconds
					animation_type = "scale",
					cooldown = 0.75, --seconds
					scale_upX = 1.1,
					scale_upY = 1.1,
					scale_downX = 0.9,
					scale_downY = 0.9,
				},
				{
					enabled = true,
					animation_type = "frameshake",
					scaleX = 1,
					scaleY = 1,
					absolute_sineX = false,
					absolute_sineY = true,
					duration = 0.08,
					amplitude = 10,
					frequency = 4.1,
					fade_in = 0.01,
					fade_out = 0.18,
					cooldown = 0.5,
				}
			},
			
			--toxic blade (assassination)
			[245388] = {
				{
					enabled = true,
					duration = 0.03, --seconds
					animation_type = "scale",
					cooldown = 0.75, --seconds
					scale_upX = 1.1,
					scale_upY = 1.1,
					scale_downX = 0.9,
					scale_downY = 0.9,
				},
				{
					enabled = true,
					animation_type = "frameshake",
					scaleX = 1,
					scaleY = 1,
					absolute_sineX = false,
					absolute_sineY = false,
					duration = 0.06,
					amplitude = 5,
					frequency = 2,
					fade_in = 0.01,
					fade_out = 0.01,
					cooldown = 0.5,
				},
			},
			
			--arcane blast (mage)
			[30451] = {
				{
					enabled = true,
					animation_type = "frameshake",
					scaleX = .1,
					scaleY = 1,
					absolute_sineX = false,
					absolute_sineY = false,
					duration = 0.12,
					amplitude = 1,
					frequency = 25,
					fade_in = 0.01,
					fade_out = 0.02,
					cooldown = 0.5,
				},
			},
			
			--arcane missiles (mage)
			[7268] = {
				{
					enabled = true,
					animation_type = "frameshake",
					scaleX = .2,
					scaleY = 1,
					absolute_sineX = false,
					absolute_sineY = false,
					duration = 0.1,
					amplitude = 0.75,
					frequency = 200,
					fade_in = 0.01,
					fade_out = 0.01,
					cooldown = 0.0,
				},
			},
			
			--arcane barrage (mage)
			[44425] = {
				{
					enabled = true,
					animation_type = "frameshake",
					scaleX = .1,
					scaleY = 1,
					absolute_sineX = false,
					absolute_sineY = false,
					duration = 0.12,
					amplitude = 1,
					frequency = 25,
					fade_in = 0.01,
					fade_out = 0.02,
					cooldown = 0.5,
				},
			},
			
			--glacial spike (frost mage)
			[228600] = {
				{
					enabled = true,
					animation_type = "frameshake",
					scaleX = .1,
					scaleY = 1,
					absolute_sineX = false,
					absolute_sineY = true,
					duration = 0.1,
					amplitude = 10,
					frequency = 1,
					fade_in = 0.01,
					fade_out = 0.09,
					cooldown = 0.5,
					critical_scale = 1.2,
				},
			},
			
			--flurry (frost mage)
			[228354] = {
				{
					enabled = true,
					animation_type = "frameshake",
					scaleX = .1,
					scaleY = 1,
					absolute_sineX = false,
					absolute_sineY = false,
					duration = 0.12,
					amplitude = 1,
					frequency = 25,
					fade_in = 0.01,
					fade_out = 0.02,
					cooldown = 0.5,
				},
			},
			
			--ice lance (frost mage)
			[228598] = {
				{
					enabled = true,
					animation_type = "frameshake",
					scaleX = .1,
					scaleY = 1,
					absolute_sineX = false,
					absolute_sineY = false,
					duration = 0.12,
					amplitude = 2,
					frequency = 25,
					fade_in = 0.01,
					fade_out = 0.02,
					cooldown = 0.5,
				},
			},
			
			--pyro (fire mage)
			[11366] = {
				{
					enabled = true,
					duration = 0.05, --seconds
					animation_type = "scale",
					cooldown = 0.75, --seconds
					scale_upX = 1.15,
					scale_upY = 1.15,
					scale_downX = 0.8,
					scale_downY = 0.8,
				},
				{
					enabled = true,
					animation_type = "frameshake",
					scaleX = .1,
					scaleY = 1,
					absolute_sineX = false,
					absolute_sineY = true,
					duration = 0.1,
					amplitude = 10,
					frequency = 1,
					fade_in = 0.01,
					fade_out = 0.09,
					cooldown = 0.5,
					critical_scale = 1.2,
				},
			},
			
			--dragon's breath (fire mage)
			[31661] = {
				{
					enabled = true,
					animation_type = "frameshake",
					scaleX = .2,
					scaleY = 1,
					absolute_sineX = false,
					absolute_sineY = false,
					duration = 0.1,
					amplitude = 0.75,
					frequency = 200,
					fade_in = 0.01,
					fade_out = 0.01,
					cooldown = 0.0,
				},
			},
			
			--fire blast (fire mage)
			[108853] = {
				{
					enabled = true,
					animation_type = "frameshake",
					scaleX = .1,
					scaleY = 1,
					absolute_sineX = false,
					absolute_sineY = false,
					duration = 0.12,
					amplitude = 1,
					frequency = 25,
					fade_in = 0.01,
					fade_out = 0.02,
					cooldown = 0.5,
				},
			},
			
			--Blade of Justice (paladin)
			[184575] = {
				{
					enabled = true,
					duration = 0.05, --seconds
					animation_type = "scale",
					cooldown = 0.75, --seconds
					scale_upX = 1.05,
					scale_upY = 1.05,
					scale_downX = 0.95,
					scale_downY = 0.95,
				},
				{
					enabled = true,
					animation_type = "frameshake",
					scaleX = .1,
					scaleY = 1,
					absolute_sineX = false,
					absolute_sineY = true,
					duration = 0.1,
					amplitude = 2,
					frequency = 1,
					fade_in = 0.01,
					fade_out = 0.09,
					cooldown = 0.5,
					critical_scale = 1.2,
				},
			},
			
			--Hammer of the Righteous (paladin)
			[53595] = {
				{
					enabled = true,
					duration = 0.05, --seconds
					animation_type = "scale",
					cooldown = 0.75, --seconds
					scale_upX = 1.03,
					scale_upY = 1.03,
					scale_downX = 0.97,
					scale_downY = 0.97,
				},
				{
					enabled = true,
					animation_type = "frameshake",
					scaleX = .1,
					scaleY = 1,
					absolute_sineX = false,
					absolute_sineY = true,
					duration = 0.1,
					amplitude = 3,
					frequency = 1,
					fade_in = 0.01,
					fade_out = 0.09,
					cooldown = 0.5,
					critical_scale = 1.05,
				},
			},
			
			--Crusader Strike (paladin)
			[35395] = {
				{
					enabled = true,
					animation_type = "frameshake",
					scaleX = .1,
					scaleY = 1,
					absolute_sineX = false,
					absolute_sineY = false,
					duration = 0.12,
					amplitude = 1,
					frequency = 25,
					fade_in = 0.01,
					fade_out = 0.02,
					cooldown = 0.5,
				},
			}, 
			
			--Avenger's Shield (paladin)
			[31935] = {
				{
					enabled = true,
					duration = 0.05, --seconds
					animation_type = "scale",
					cooldown = 0.75, --seconds
					scale_upX = 1.03,
					scale_upY = 1.03,
					scale_downX = 0.97,
					scale_downY = 0.97,
				},
				{
					enabled = true,
					animation_type = "frameshake",
					scaleX = 1,
					scaleY = 1,
					absolute_sineX = true,
					absolute_sineY = false,
					duration = 0.1,
					amplitude = 6,
					frequency = 1,
					fade_in = 0.01,
					fade_out = 0.09,
					cooldown = 0.5,
					critical_scale = 1.05,
				},
			},
			
			--Judgment (paladin)
			[275779] = {
				{
					enabled = true,
					animation_type = "frameshake",
					scaleX = .1,
					scaleY = -1, --absolute sine * -1 makes the shake always go down
					absolute_sineX = false,
					absolute_sineY = true,
					duration = 0.12,
					amplitude = 1,
					frequency = 25,
					fade_in = 0.01,
					fade_out = 0.02,
					cooldown = 0.5,
				},
			},
			
			--Thunder Clap (warrior)
			[6343] = {
				{
					enabled = true,
					animation_type = "frameshake",
					scaleX = .2,
					scaleY = 1,
					absolute_sineX = false,
					absolute_sineY = false,
					duration = 0.12,
					amplitude = 0.95,
					frequency = 200,
					fade_in = 0.01,
					fade_out = 0.01,
					cooldown = 0.1,
				},
			},
			
			--Heroic Leap (warrior)
			[52174] = {
				{
					enabled = true,
					duration = 0.075, --seconds
					animation_type = "scale",
					cooldown = 0.75, --seconds
					scale_upX = 1.15,
					scale_upY = 1.15,
					scale_downX = 0.8,
					scale_downY = 0.8,
				},
				{
					enabled = true,
					animation_type = "frameshake",
					scaleX = .15,
					scaleY = 1,
					absolute_sineX = false,
					absolute_sineY = false,
					duration = 0.3,
					amplitude = 6,
					frequency = 50,
					fade_in = 0.01,
					fade_out = 0.2,
					cooldown = 0.5,
					critical_scale = 1.2,
				},
			}, 
			
			--Devastate (warrior)
			[20243] = {
				{
					enabled = true,
					animation_type = "frameshake",
					scaleX = .1,
					scaleY = 1,
					absolute_sineX = false,
					absolute_sineY = false,
					duration = 0.12,
					amplitude = 1,
					frequency = 25,
					fade_in = 0.01,
					fade_out = 0.02,
					cooldown = 0.5,
				},
			}, 
			
			--Shockwave (warrior)
			[46968] = {
				{
					enabled = true,
					animation_type = "frameshake",
					scaleX = .1,
					scaleY = 1,
					absolute_sineX = false,
					absolute_sineY = false,
					duration = 0.10,
					amplitude = 0.95,
					frequency = 120,
					fade_in = 0.01,
					fade_out = 0.01,
					cooldown = 0.1,
				},
			}, 
			
			--Death Strike (dk)
			[49998] = {
				{
					enabled = true,
					animation_type = "frameshake",
					scaleX = .1,
					scaleY = 1,
					absolute_sineX = false,
					absolute_sineY = false,
					duration = 0.13,
					amplitude = 1.8,
					frequency = 25,
					fade_in = 0.01,
					fade_out = 0.02,
					cooldown = 0.5,
				},
			}, 
			
			--Frost Strike (dk)
			[222026] = {
				{
					enabled = true,
					duration = 0.04, --seconds
					animation_type = "scale",
					cooldown = 0.75, --seconds
					scale_upX = 1.1,
					scale_upY = 1.1,
					scale_downX = 0.9,
					scale_downY = 0.9,
				},
				{
					enabled = true,
					animation_type = "frameshake",
					scaleX = 1,
					scaleY = -1,
					absolute_sineX = false,
					absolute_sineY = true,
					duration = 0.08,
					amplitude = 10,
					frequency = 4.1,
					fade_in = 0.01,
					fade_out = 0.18,
					cooldown = 0.5,
				},
			}, 
			
			--Obliterate (dk)
			[222024] = {
				{
					enabled = true,
					duration = 0.035, --seconds
					animation_type = "scale",
					cooldown = 0.75, --seconds
					scale_upX = 1.1,
					scale_upY = 1.1,
					scale_downX = 0.9,
					scale_downY = 0.9,
				},
				{
					enabled = true,
					animation_type = "frameshake",
					scaleX = 1,
					scaleY = -1,
					absolute_sineX = true,
					absolute_sineY = true,
					duration = 0.075,
					amplitude = 1.8,
					frequency = 50,
					fade_in = 0.01,
					fade_out = 0.02,
					cooldown = 0.5,
					critical_scale = 2,
				},
			},
			
			--Scourge Strike (dk)
			[55090] = {
				{
					enabled = true,
					animation_type = "frameshake",
					scaleX = 1,
					scaleY = 1,
					absolute_sineX = false,
					absolute_sineY = true,
					duration = 0.08,
					amplitude = 10,
					frequency = 4.1,
					fade_in = 0.01,
					fade_out = 0.18,
					cooldown = 0.5,
				},
			}, 
			
			--Festering Strike (dk)
			[85948] = {
				{
					enabled = true,
					animation_type = "frameshake",
					scaleX = .1,
					scaleY = 1,
					absolute_sineX = false,
					absolute_sineY = false,
					duration = 0.12,
					amplitude = 1,
					frequency = 25,
					fade_in = 0.01,
					fade_out = 0.02,
					cooldown = 0.5,
				},
			}, 
			
			--Heart Strike (dk)
			[206930] = {
				{
					enabled = true,
					duration = 0.035, --seconds
					animation_type = "scale",
					cooldown = 0.75, --seconds
					scale_upX = 1.1,
					scale_upY = 1.1,
					scale_downX = 0.9,
					scale_downY = 0.9,
				},
				{
					enabled = true,
					animation_type = "frameshake",
					scaleX = -1,
					scaleY = 1,
					absolute_sineX = true,
					absolute_sineY = true,
					duration = 0.075,
					amplitude = 1.8,
					frequency = 50,
					fade_in = 0.01,
					fade_out = 0.02,
					cooldown = 0.5,
					critical_scale = 2,
				},
			}, 
			
		},
		
		--health_statusbar_texture = "PlaterHealth",
		health_statusbar_texture = "Details Flat",
		health_selection_overlay = "PlaterHighlight",
		health_statusbar_bgtexture = "PlaterBackground",
		health_statusbar_bgcolor = {1, 1, 1, 0.823},
		health_statusbar_bgalpha = 1,
		
		cast_statusbar_texture = "Details Flat",
		cast_statusbar_bgtexture = "Details Serenity",
		cast_statusbar_bgcolor = {0, 0, 0, 0.823},
		cast_statusbar_color = {1, .7, 0, 0.96},
		cast_statusbar_color_nointerrupt = {.5, .5, .5, 0.96},
		
		indicator_faction = true,
		indicator_spec = true,
		indicator_elite = true,
		indicator_rare = true,
		indicator_quest = true,
		indicator_enemyclass = false,
		indicator_anchor = {side = 2, x = -2, y = 0},
		
		indicator_extra_raidmark = true,
		indicator_raidmark_scale = 1,
		indicator_raidmark_anchor = {side = 2, x = -1, y = 4},
		
		target_indicator = "Silver",
		
		color_override = false,
		color_override_colors = {
			[UNITREACTION_HOSTILE] = {0.9176470, 0.2784313, 0.2078431},
			[UNITREACTION_FRIENDLY] = {0.9254901, 0.8, 0.2666666},
			[UNITREACTION_NEUTRAL] = {0.5215686, 0, 0.4509803},
		},
		
		border_color = {0, 0, 0, .36},
		border_thickness = 3,
		
		focus_indicator_enabled = true,
		focus_color = {0, 0, 0, 0.5},
		focus_texture = "PlaterFocus",
		
		tap_denied_color = {.9, .9, .9},
		
		aggro_modifies = {
			health_bar_color = true,
			border_color = false,
			actor_name_color = false,
		},
		
		tank = {
			colors = {
				aggro = {.5, .5, 1},
				noaggro = {1, 0, 0},
				pulling = {1, 1, 0},
				nocombat = {0.505, 0.003, 0},
				anothertank = {0.729, 0.917, 1},
			},
		},
		
		dps = {
			colors = {
				--aggro = {1, .5, .5},
				aggro = {1, 0.317, 0.172},
				noaggro = {.5, .5, 1},
				pulling = {1, 1, 0},
			},
		},
		
		first_run2 = false,
	}
}

local Plater = DF:CreateAddOn ("Plater", "PlaterDB", default_config, { --options table
	name = "Plater Nameplates",
	type = "group",
	args = {
		
	}
})

--> if a widget has a RefreshID lower than the addon, it triggers a refresh on it
local PLATER_REFRESH_ID = 1
function Plater.IncreaseRefreshID()
	PLATER_REFRESH_ID = PLATER_REFRESH_ID + 1
end

--major
local CUF_Name = "CompactUnitFrame" --blizzard cuf
local NPF_Name = "NamePlateDriverFrame" --nameplate frame
local NPB_Name = "NameplateBuffContainerMixin" --nameplate buff
local CBF_Name = "CastingBarFrame" --castingbar

Plater.FriendsCache = {}
Plater.QuestCache = {}
Plater.DriverFuncNames = {
	["OnNameUpdate"] = "UpdateName",
	["OnUpdateBuffs"] = "UpdateBuffs",
	["OnUpdateHealth"] = "UpdateHealth",
	["OnUpdateAnchor"] = "UpdateAnchor",
	["OnBorderUpdate"] = "SetVertexColor",
	["OnChangeHealthConfig"] = "UpdateHealthColor",
	["OnSelectionUpdate"] = "UpdateSelectionHighlight",
	["OnAuraUpdate"] = "OnUnitAuraUpdate",
	["OnResourceUpdate"] = "SetupClassNameplateBar",
	["OnOptionsUpdate"] = "UpdateNamePlateOptions",
	["OnManaBarOptionsUpdate"] = "OnOptionsUpdated",
	["OnCastBarEvent"] = "OnEvent",
	["OnCastBarShow"] = "OnShow",
	["OnTick"] = "OnUpdate",
	["OnRaidTargetUpdate"] = "OnRaidTargetUpdate",
}
Plater.DriverConfigType = {
	["FRIENDLY"] = "Friendly", 
	["ENEMY"] = "Enemy", 
	["PLAYER"] = "Player",
}
Plater.DriverConfigMembers = {
	["UseClassColors"] = "useClassColors",
	["UseRangeCheck"] = "fadeOutOfRange",
	["UseAlwaysHostile"] = "considerSelectionInCombatAsHostile",
	["CanShowUnitName"] = "displayName",
	["HideCastBar"] = "hideCastbar",
}

Plater.CodeTypeNames = {
	[1] = "UpdateCode",
	[2] = "ConstructorCode",
	[3] = "OnHideCode",
	[4] = "OnShowCode",
}

Plater.TriggerDefaultMembers = {
	[1] = {
		"envTable._SpellID",
		"envTable._UnitID",
		"envTable._SpellName",
		"envTable._Texture",
		"envTable._Caster",
		"envTable._StackCount",
		"envTable._Duration",
		"envTable._StartTime",
		"envTable._EndTime",
		"envTable._RemainingTime",
	},
	[2] = {
		"envTable._SpellID",
		"envTable._UnitID",
		"envTable._SpellName",
		"envTable._Texture",
		"envTable._Caster",
		"envTable._Duration",
		"envTable._StartTime",
		"envTable._EndTime",
		"envTable._RemainingTime",
		"envTable._CastPercent",
		"envTable._CanInterrupt",
	},
	[3] = {
		"envTable._UnitID",
		"envTable._NpcID",
		"envTable._UnitName",
		"envTable._UnitGUID",
		"envTable._HealthPercent",
	},
}

local SCRIPT_TYPE_CONSTRUCTOR = Plater.CodeTypeNames [2]
local SCRIPT_TYPE_ONUPDATE = Plater.CodeTypeNames [1]
local SCRIPT_TYPE_ONHIDE = Plater.CodeTypeNames [3]
local SCRIPT_TYPE_ONSHOW = Plater.CodeTypeNames [4]

--const
local CVAR_RESOURCEONTARGET = "nameplateResourceOnTarget"
local CVAR_CULLINGDISTANCE = "nameplateMaxDistance"
local CVAR_CEILING = "nameplateOtherTopInset"
local CVAR_ANCHOR = "nameplateOtherAtBase"
local CVAR_AGGROFLASH = "ShowNamePlateLoseAggroFlash"
local CVAR_MOVEMENT_SPEED = "nameplateMotionSpeed"
local CVAR_MIN_ALPHA = "nameplateMinAlpha"
local CVAR_MIN_ALPHA_DIST = "nameplateMinAlphaDistance"
local CVAR_SHOWALL = "nameplateShowAll"
local CVAR_ENEMY_ALL = "nameplateShowEnemies"
local CVAR_ENEMY_MINIONS = "nameplateShowEnemyMinions"
local CVAR_ENEMY_MINUS = "nameplateShowEnemyMinus"
local CVAR_PLATEMOTION = "nameplateMotion"
local CVAR_FRIENDLY_ALL = "nameplateShowFriends"
local CVAR_FRIENDLY_GUARDIAN = "nameplateShowFriendlyGuardians"
local CVAR_FRIENDLY_PETS = "nameplateShowFriendlyPets"
local CVAR_FRIENDLY_TOTEMS = "nameplateShowFriendlyTotems"
local CVAR_FRIENDLY_MINIONS = "nameplateShowFriendlyMinions"
local CVAR_CLASSCOLOR = "ShowClassColorInNameplate"
local CVAR_SCALE_HORIZONTAL = "NamePlateHorizontalScale"
local CVAR_SCALE_VERTICAL = "NamePlateVerticalScale"

--comm
local COMM_PLATER_PREFIX = "PLT"
local COMM_SCRIPT_GROUP_EXPORTED = "GE"

--store aura names to manually track
local MANUAL_TRACKING_BUFFS = {}
local MANUAL_TRACKING_DEBUFFS = {}
local AUTO_TRACKING_EXTRA_BUFFS = {}
local AUTO_TRACKING_EXTRA_DEBUFFS = {}
--if automatic aura tracking and there's auras to manually track
local CAN_TRACK_EXTRA_BUFFS = false
local CAN_TRACK_EXTRA_DEBUFFS = false

--spell animations - store a table with information about animation for spells
local SPELL_WITH_ANIMATIONS = {}

--store players which have the tank role in the group
local TANK_CACHE = {}

--store pets
local PET_CACHE = {}

--store if the player is in combat (not reliable, toggled at regen switch)
local PLAYER_IN_COMBAT

--store if the player is not inside an instance
local IS_IN_OPEN_WORLD = true

local BUFF_MAX_DISPLAY = BUFF_MAX_DISPLAY
local CooldownFrame_Set = CooldownFrame_Set

 --cvars
local CVAR_ENABLED = "1"
local CVAR_DISABLED = "0"

local CVAR_ANCHOR_HEAD = "0"
local CVAR_ANCHOR_BOTH = "1"
local CVAR_ANCHOR_FEET = "2"

--members
local MEMBER_UNITID = "namePlateUnitToken"
local MEMBER_GUID = "namePlateUnitGUID"
local MEMBER_NPCID = "namePlateNpcId"
local MEMBER_QUEST = "namePlateIsQuestObjective"
local MEMBER_REACTION = "namePlateUnitReaction"
local MEMBER_ALPHA = "namePlateAlpha"
local MEMBER_RANGE = "namePlateInRange"
local MEMBER_NOCOMBAT = "namePlateNoCombat"
local MEMBER_NAME = "namePlateUnitName"
local MEMBER_NAMELOWER = "namePlateUnitNameLower"
local MEMBER_TARGET = "namePlateIsTarget"
local MEMBER_CLASSIFICATION = "namePlateClassification"

--icon texcoords
Plater.WideIconCoords = {.1, .9, .1, .6}
Plater.BorderLessIconCoords = {.1, .9, .1, .9}

local CAN_USE_AURATIMER = true
Plater.CanLoadFactionStrings = true

local CONST_USE_HEALTHCUTOFF = false
local CONST_HEALTHCUTOFF_AT = 20

-- ~execute
function Plater.GetHealthCutoffValue()

	CONST_USE_HEALTHCUTOFF = false
	
	if (not Plater.db.profile.health_cutoff) then
		return
	end
	
	local classLoc, class = UnitClass ("player")
	local spec = GetSpecialization()
	if (spec and class) then
	
		if (class == "PRIEST") then
			--playing as shadow?
			local specID = GetSpecializationInfo (spec)
			if (specID and specID ~= 0) then
				if (specID == 258) then --shadow
					local _, _, _, using_SWDeath = GetTalentInfo (5, 2, 1)
					if (using_SWDeath) then
						CONST_USE_HEALTHCUTOFF = true
						CONST_HEALTHCUTOFF_AT = 0.20
					end
				end
			end
			
		elseif (class == "MAGE") then
			--playing fire mage?
			local specID = GetSpecializationInfo (spec)
			if (specID and specID ~= 0) then
				if (specID == 63) then --fire
					local _, _, _, using_SearingTouch = GetTalentInfo (1, 3, 1)
					if (using_SearingTouch) then
						CONST_USE_HEALTHCUTOFF = true
						CONST_HEALTHCUTOFF_AT = 0.30
					end
				end
			end
			
			
		elseif (class == "WARRIOR") then
			--is playing as a Arms warrior?
			local specID = GetSpecializationInfo (spec)
			if (specID and specID ~= 0) then
				if (specID == 71 or specID == 72) then --arms or fury
					CONST_USE_HEALTHCUTOFF = true
					CONST_HEALTHCUTOFF_AT = 0.20
					
					if (specID == 71) then --arms
						local _, _, _, using_Massacre = GetTalentInfo (3, 1, 1)
						if (using_Massacre) then
							--if using massacre, execute can be used at 35% health in Arms spec
							CONST_HEALTHCUTOFF_AT = 0.35
						end
					end
				end
			end
			
		elseif (class == "HUNTER") then
			local specID = GetSpecializationInfo (spec)
			if (specID and specID ~= 0) then
				if (specID == 253) then --beast mastery
					--> is using killer instinct?
					local _, _, _, using_KillerInstinct = GetTalentInfo (1, 1, 1)
					if (using_KillerInstinct) then
						CONST_USE_HEALTHCUTOFF = true
						CONST_HEALTHCUTOFF_AT = 0.35
					end
				end
			end
		end
	end
end

--> copied from blizzard code
local function IsPlayerEffectivelyTank()
	local assignedRole = UnitGroupRolesAssigned ("player");
	if ( assignedRole == "NONE" ) then
		local spec = GetSpecialization();
		return spec and GetSpecializationRole(spec) == "TANK";
	end
	return assignedRole == "TANK";
end

local function IsUnitEffectivelyTank (unit)
	local assignedRole = UnitGroupRolesAssigned (unit);
	return assignedRole == "TANK";
end


--copied from blizzard code
local function IsTapDenied (unit)
	return unit and not UnitPlayerControlled (unit) and UnitIsTapDenied (unit)
end

function Plater.GetDriverSubObjectName (driverName, funcName, isChildMember)
	if (isChildMember) then
		return driverName [funcName]
	else
		return driverName .. "_" .. funcName
	end
end

function Plater.GetDriverGlobalObject (driverName)
	return _G [driverName]
end
function Plater.Execute (driverName, funcName, ...)
	local subObject = Plater.GetDriverSubObjectName (driverName, funcName, false)
	if (subObject) then
		return _G [subObject] and _G [subObject] (...)
	end
end

local InstallHook = hooksecurefunc
local InstallOverride = function (driverName, funcName, newFunction)
	if (not funcName) then
		_G [driverName] = newFunction
	else
		_G [driverName] [funcName] = newFunction
	end
end

function Plater.GetHashKey (inCombat)
	if (inCombat) then
		return "cast_incombat", "health_incombat", "actorname_text_spacing", "mana_incombat"
	else
		return "cast", "health", "actorname_text_spacing", "mana"
	end
end

local ACTORTYPE_FRIENDLY_PLAYER = "friendlyplayer"
local ACTORTYPE_FRIENDLY_NPC = "friendlynpc"
local ACTORTYPE_ENEMY_PLAYER = "enemyplayer"
local ACTORTYPE_ENEMY_NPC = "enemynpc"
local ACTORTYPE_PLAYER = "player"

local actorTypes = {ACTORTYPE_FRIENDLY_PLAYER, ACTORTYPE_ENEMY_PLAYER, ACTORTYPE_FRIENDLY_NPC, ACTORTYPE_ENEMY_NPC, ACTORTYPE_PLAYER}
function Plater.GetActorTypeByIndex (index)
	return actorTypes [index] or error ("Invalid actor type")
end

function Plater.SetShowActorType (actorType, value)
	Plater.db.profile.plate_config [actorType].enabled = value
end

do
	local STRING_DEFAULT = "Default"
	local STRING_OPTIONS = "FrameOptions"

	function Plater.InjectOnDefaultOptions (driverName, configType, configName, value)
		_G [STRING_DEFAULT .. driverName .. configType .. STRING_OPTIONS][configName] = value
	end
end

function Plater.IsShowingResourcesOnTarget()
	return GetCVar ("nameplateShowSelf") == CVAR_ENABLED and GetCVar (CVAR_RESOURCEONTARGET) == CVAR_ENABLED
end

local TargetIndicators = {
	["NONE"] = {
		path = [[Interface\ACHIEVEMENTFRAME\UI-Achievement-WoodBorder-Corner]],
		coords = {{.9, 1, .9, 1}, {.9, 1, .9, 1}, {.9, 1, .9, 1}, {.9, 1, .9, 1}},
		desaturated = false,
		width = 10,
		height = 10,
		x = 1,
		y = 1,
	},
	
	["Magneto"] = {
		path = [[Interface\Artifacts\RelicIconFrame]],
		coords = {{0, .5, 0, .5}, {0, .5, .5, 1}, {.5, 1, .5, 1}, {.5, 1, 0, .5}},
		desaturated = false,
		width = 8,
		height = 10,
		x = 1,
		y = 1,
	},
	
	["Gray Bold"] = {
		path = [[Interface\ContainerFrame\UI-Icon-QuestBorder]],
		coords = {{0, .5, 0, .5}, {0, .5, .5, 1}, {.5, 1, .5, 1}, {.5, 1, 0, .5}},
		desaturated = true,
		width = 10,
		height = 10,
		x = 2,
		y = 2,
	},
	
	["Pins"] = {
		path = [[Interface\ITEMSOCKETINGFRAME\UI-ItemSockets]],
		coords = {{145/256, 161/256, 3/256, 19/256}, {145/256, 161/256, 19/256, 3/256}, {161/256, 145/256, 19/256, 3/256}, {161/256, 145/256, 3/256, 19/256}},
		desaturated = 1,
		width = 4,
		height = 4,
		x = 2,
		y = 2,
	},

	["Silver"] = {
		path = [[Interface\PETBATTLES\PETBATTLEHUD]],
		coords = {
			{848/1024, 868/1024, 454/512, 474/512}, 
			{848/1024, 868/1024, 474/512, 495/512}, 
			{868/1024, 889/1024, 474/512, 495/512}, 
			{868/1024, 889/1024, 454/512, 474/512}
		}, --848 889 454 495
		desaturated = false,
		width = 6,
		height = 6,
		x = 1,
		y = 1,
	},
	
	["Ornament"] = {
		path = [[Interface\PETBATTLES\PETJOURNAL]],
		coords = {
			{124/512, 161/512, 71/1024, 99/1024}, 
			{119/512, 156/512, 29/1024, 57/1024}
		},
		desaturated = false,
		width = 18,
		height = 12,
		x = 12,
		y = 0,
	},
	
	["Golden"] = {
		path = [[Interface\Artifacts\Artifacts]],
		coords = {
			{137/1024, (137+29)/1024, 920/1024, 978/1024},
			{(137+30)/1024, 195/1024, 920/1024, 978/1024},
		},
		desaturated = false,
		width = 8,
		height = 12,
		x = 0,
		y = 0,
	},
	
	["Ornament Gray"] = {
		path = [[Interface\Challenges\challenges-besttime-bg]],
		coords = {
			{89/512, 123/512, 0, 1},
			{123/512, 89/512, 0, 1},
		},
		desaturated = false,
		width = 8,
		height = 12,
		alpha = 0.7,
		x = 0,
		y = 0,
		color = "red",
	},

	["Epic"] = {
		path = [[Interface\UNITPOWERBARALT\WowUI_Horizontal_Frame]],
		coords = {
			{30/256, 40/256, 15/64, 49/64},
			{40/256, 30/256, 15/64, 49/64}, 
		},
		desaturated = false,
		width = 6,
		height = 12,
		x = 3,
		y = 0,
		blend = "ADD",
	},
}

--> general values

local DB_TICK_THROTTLE
local DB_LERP_COLOR
local DB_LERP_COLOR_SPEED
local DB_PLATE_CONFIG
local DB_HOVER_HIGHLIGHT
local DB_BUFF_BANNED
local DB_DEBUFF_BANNED
local DB_AURA_ENABLED
local DB_AURA_ALPHA
local DB_AURA_X_OFFSET
local DB_AURA_Y_OFFSET

local DB_AURA_SEPARATE_BUFFS

local DB_AURA_SHOW_IMPORTANT
local DB_AURA_SHOW_DISPELLABLE
local DB_AURA_SHOW_BYPLAYER
local DB_AURA_SHOW_BYUNIT

local DB_AURA_GROW_DIRECTION --> main aura frame
local DB_AURA_GROW_DIRECTION2 --> secondary aura frame is adding buffs in a different frame

local IS_USING_DETAILS_INTEGRATION
local DB_UPDATE_FRAMELEVEL

local DB_TRACK_METHOD
local DB_BORDER_COLOR_R
local DB_BORDER_COLOR_G
local DB_BORDER_COLOR_B
local DB_BORDER_COLOR_A
local DB_BORDER_THICKNESS
local DB_AGGRO_CHANGE_HEALTHBAR_COLOR
local DB_AGGRO_CHANGE_NAME_COLOR
local DB_AGGRO_CHANGE_BORDER_COLOR
local DB_TARGET_SHADY_ENABLED
local DB_TARGET_SHADY_ALPHA
local DB_TARGET_SHADY_COMBATONLY

local DB_NAME_NPCENEMY_ANCHOR
local DB_NAME_NPCFRIENDLY_ANCHOR
local DB_NAME_PLAYERENEMY_ANCHOR
local DB_NAME_PLAYERFRIENDLY_ANCHOR

local DB_DO_ANIMATIONS
local DB_ANIMATION_TIME_DILATATION

local DB_USE_RANGE_CHECK

local DB_TEXTURE_CASTBAR
local DB_TEXTURE_CASTBAR_BG
local DB_TEXTURE_HEALTHBAR
local DB_TEXTURE_HEALTHBAR_BG

local DB_CASTBAR_HIDE_ENEMIES
local DB_CASTBAR_HIDE_FRIENDLY

local DB_CAPTURED_SPELLS = {}

local DB_SHOW_PURGE_IN_EXTRA_ICONS

--store the aggro color table for tanks and dps
local DB_AGGRO_TANK_COLORS
local DB_AGGRO_DPS_COLORS

--store if the no combat alpha is enabled
local DB_NOT_COMBAT_ALPHA_ENABLED

local SCRIPT_AURA = {}
local SCRIPT_CASTBAR = {}
local SCRIPT_UNIT = {}

local SPECIAL_AURA_NAMES = {}
local CROWDCONTROL_AURA_NAMES = {}

Plater.ScriptMetaFunctions = {
	--get the table which stores all script information for the widget
	ScriptGetContainer = function (self)
		local infoTable = self.ScriptInfoTable
		if (not infoTable) then
			self.ScriptInfoTable = {}
			return self.ScriptInfoTable
		else
			return infoTable
		end
	end,
	
	--get the table which stores the information for a single script
	ScriptGetInfo = function (self, globalScriptObject, widgetScriptContainer)
		widgetScriptContainer = widgetScriptContainer or self:GetScriptContainer()
		
		--using the memory address of the original scriptObject from db.profile as the map key
		local scriptInfo = widgetScriptContainer [globalScriptObject.DBScriptObject]
		if (not scriptInfo) then
			scriptInfo = {
				GlobalScriptObject = globalScriptObject, 
				HotReload = -1, 
				Env = {}, 
				IsActive = false
			}
			widgetScriptContainer [globalScriptObject.DBScriptObject] = scriptInfo
		end
		
		return scriptInfo
	end,
	
	--if the global script had an update or if the first time running this script on this widget, run the constructor
	ScriptHotReload = function (self, scriptInfo)
		--dispatch constructor if necessary
		if (scriptInfo.HotReload < scriptInfo.GlobalScriptObject.HotReload) then
			--update the hotreload state
			scriptInfo.HotReload = scriptInfo.GlobalScriptObject.HotReload

			--dispatch the constructor
			local unitFrame = self.UnitFrame or self
			local okay, errortext = pcall (scriptInfo.GlobalScriptObject [SCRIPT_TYPE_CONSTRUCTOR], self, unitFrame.displayedUnit or unitFrame.unit or unitFrame:GetParent()[MEMBER_UNITID], unitFrame, scriptInfo.Env)
			if (not okay) then
				Plater:Msg ("Script |cFFAAAA22" .. scriptInfo.GlobalScriptObject.DBScriptObject.Name .. "|r Constructor error: " .. errortext)
			end
		end
	end,
	
	--run the update script
	ScriptRunOnUpdate = function (self, scriptInfo)
		if (not scriptInfo.IsActive) then
			--run constructor
			self:ScriptHotReload (scriptInfo)
			--run on show
			self:ScriptRunOnShow (scriptInfo)
		end
		
		--dispatch the runtime script
		local unitFrame = self.UnitFrame or self
		local okay, errortext = pcall (scriptInfo.GlobalScriptObject [SCRIPT_TYPE_ONUPDATE], self, unitFrame.displayedUnit or unitFrame.unit or unitFrame:GetParent()[MEMBER_UNITID], unitFrame, scriptInfo.Env)
		if (not okay) then
			Plater:Msg ("Script |cFFAAAA22" .. scriptInfo.GlobalScriptObject.DBScriptObject.Name .. "|r OnUpdate error: " .. errortext)
		end
	end,
	
	--run the OnShow script
	ScriptRunOnShow = function (self, scriptInfo)
		--dispatch the destructor script
		local unitFrame = self.UnitFrame or self
		local okay, errortext = pcall (scriptInfo.GlobalScriptObject [SCRIPT_TYPE_ONSHOW], self, unitFrame.displayedUnit or unitFrame.unit or unitFrame:GetParent()[MEMBER_UNITID], unitFrame, scriptInfo.Env)
		if (not okay) then
			Plater:Msg ("Script |cFFAAAA22" .. scriptInfo.GlobalScriptObject.DBScriptObject.Name .. "|r OnShow error: " .. errortext)
		end
		
		scriptInfo.IsActive = true
		self.ScriptKey = scriptInfo.GlobalScriptObject.ScriptKey
	end,
	
	--run the OnHide script
	ScriptRunOnHide = function (self, scriptInfo)
		--dispatch the destructor script
		local unitFrame = self.UnitFrame or self
		local okay, errortext = pcall (scriptInfo.GlobalScriptObject [SCRIPT_TYPE_ONHIDE], self, unitFrame.displayedUnit or unitFrame.unit or unitFrame:GetParent()[MEMBER_UNITID], unitFrame, scriptInfo.Env)
		if (not okay) then
			Plater:Msg ("Script |cFFAAAA22" .. scriptInfo.GlobalScriptObject.DBScriptObject.Name .. "|r OnHide error: " .. errortext)
		end
		
		scriptInfo.IsActive = false
		self.ScriptKey = nil
	end,
	
	--run when the widget hides, usable with HookScript
	OnHideWidget = function (self)
		--> check if can quickly quit (if there's no script container for the nameplate)
		if (not self.ScriptInfoTable) then
			return
		end
		
		local mainScriptTable
		
		if (self.IsAuraIcon) then
			mainScriptTable = SCRIPT_AURA
		elseif (self.IsCastBar) then
			mainScriptTable = SCRIPT_CASTBAR
		elseif (self.IsUnitNameplate) then
			mainScriptTable = SCRIPT_UNIT				
		end

		--> ScriptKey holds the trigger of the script currently running
		local globalScriptObject = mainScriptTable [self.ScriptKey]
		
		--does the aura has a custom script?
		if (globalScriptObject) then
			--does the aura icon has a table with script information?
			local scriptContainer = self:ScriptGetContainer()
			if (scriptContainer) then
				local scriptInfo = self:ScriptGetInfo (globalScriptObject, scriptContainer)
				if (scriptInfo and scriptInfo.IsActive) then
					self:ScriptRunOnHide (scriptInfo)
				end
			end
		end

		--[=[
			for globalTable, scriptInfo in pairs (self.ScriptInfoTable) do
				if (scriptInfo.IsActive) then
					Plater:Msg ("A script didn't shutdown properly: Bug? ScriptObject.Name: " .. (globalTable.Name or "??") .. " Current Script Key: " .. (self.ScriptKey or "??"))
				end
			end
		--]=]
	end,
	
	--stop a running script by the trigger ID
	--this is used when deleting a script or disabling it
	KillScript = function (self, triggerID)
		local mainScriptTable
		
		if (self.IsAuraIcon) then
			mainScriptTable = SCRIPT_AURA
			triggerID = GetSpellInfo (triggerID)
			
		elseif (self.IsCastBar) then
			mainScriptTable = SCRIPT_CASTBAR
			triggerID = GetSpellInfo (triggerID)
			
		elseif (self.IsUnitNameplate) then
			mainScriptTable = SCRIPT_UNIT				
		end
		
		if (self.ScriptKey and self.ScriptKey == triggerID) then
			local globalScriptObject = mainScriptTable [triggerID]
			if (globalScriptObject) then
				local scriptContainer = self:ScriptGetContainer()
				if (scriptContainer) then
					local scriptInfo = self:ScriptGetInfo (globalScriptObject, scriptContainer)
					if (scriptInfo and scriptInfo.IsActive) then
						self:ScriptRunOnHide (scriptInfo)
					end
				end
			end
		end
	end
}
 
function Plater.GetAllScripts()
	return Plater.db.profile.script_data
end
 
--compile all scripts
function Plater.CompileAllScripts()
	for scriptId, scriptObject in ipairs (Plater.db.profile.script_data) do
		if (scriptObject.Enabled) then
			Plater.CompileScript (scriptObject)
		end
	end
end

--when a script object get disabled, need to clear all compiled scripts in the cache and recompile than again
--this other scripts that uses the same trigger name get activated
-- ~scripts

Plater.CoreVersion = 1

function Plater.WipeAndRecompileAllScripts()
	table.wipe (SCRIPT_AURA)
	table.wipe (SCRIPT_CASTBAR)
	table.wipe (SCRIPT_UNIT)
	Plater.CompileAllScripts()
end

function Plater.CompileScript (scriptObject, ...)
	
	--check if the script is valid and if is enabled
	if (not scriptObject) then
		return
	elseif (not scriptObject.Enabled) then
		return
	end
	
	--store the scripts to be compiled
	local scriptCode, scriptFunctions = {}, {}
	
	--get scripts passed to
	for i = 1, select ("#",...) do
		scriptCode [Plater.CodeTypeNames [i]] = "return " .. select (i, ...)
	end
	
	--get scripts which wasn't passed
	for i = 1, #Plater.CodeTypeNames do
		local scriptType = Plater.CodeTypeNames [i]
		if (not scriptCode [scriptType]) then
			scriptCode [scriptType] = "return " .. scriptObject [scriptType]
		end
	end

	--compile
	for scriptType, code in pairs (scriptCode) do
		local compiledScript, errortext = loadstring (code, "Compiling " .. scriptType .. " for " .. scriptObject.Name)
		if (not compiledScript) then
			Plater:Msg ("failed to compile " .. scriptType .. " for script " .. scriptObject.Name .. ": " .. errortext)
		else
			--get the function to execute
			scriptFunctions [scriptType] = compiledScript()
		end
	end
	
	--trigger container is the table with spellIds for auras or spellcast
	--triggerId is the spellId then converted to spellName or the unitName in case is a Unit script
	local triggerContainer, triggerId
	if (scriptObject.ScriptType == 1 or scriptObject.ScriptType == 2) then --aura or castbar
		triggerContainer = "SpellIds"
	elseif (scriptObject.ScriptType == 3) then --unit plate
		triggerContainer = "NpcNames"
	end
	
	for i = 1, #scriptObject [triggerContainer] do
		local triggerId = scriptObject [triggerContainer] [i]
		
		--> if the trigger is using spellId, check if the spell exists
		if (scriptObject.ScriptType == 1 or scriptObject.ScriptType == 2) then
			if (type (triggerId) == "number") then
				triggerId = GetSpellInfo (triggerId)
				if (not triggerId) then
					Plater:Msg ("failed to get the spell name for spellId: " .. (scriptObject [triggerContainer] [i] or "invalid spellId"))
				end
			end
		
		--> if is a unit name, make it be in lower case	
		elseif (scriptObject.ScriptType == 3) then
			--> cast the string to number to see if it's a npcId
			triggerId = tonumber (triggerId) or triggerId
			
			--> the user may have inserted the npcId
			if (type (triggerId) == "string") then
				triggerId = lower (triggerId)
			end
		end

		if (triggerId) then
			--get the global script object table
			local mainScriptTable
			
			if (scriptObject.ScriptType == 1) then
				mainScriptTable = SCRIPT_AURA
			elseif (scriptObject.ScriptType == 2) then
				mainScriptTable = SCRIPT_CASTBAR
			elseif (scriptObject.ScriptType == 3) then
				mainScriptTable = SCRIPT_UNIT
			end
			
			local globalScriptObject = mainScriptTable [triggerId]
			
			if (not globalScriptObject) then
				--first time compiled, create the global script object
				--this table controls the hot reload state, holds the original object from the database and has the compiled functions
				globalScriptObject = {
					DBScriptObject = scriptObject,
					--whenever the script is applied or saved the hot reload increases making it run again when the script is triggered
					HotReload = 1,
					--script key is set in the widget so it can lookup for a script using the key when the widget is hidding
					ScriptKey = triggerId,
				}
				mainScriptTable [triggerId] = globalScriptObject
				
			else --hot reload
				globalScriptObject.HotReload = globalScriptObject.HotReload + 1
				
			end
			
			--add the script functions to the scrip table
			for scriptType, func in pairs (scriptFunctions) do
				globalScriptObject [scriptType] = func
			end
		end
	end
	
end


--check all triggers of all scripts for overlaps
--where a same spellId, npcName or npcId is being used by two or more scripts
--return a table with the triggerId with a index table of all scripts using that trigger
function Plater.CheckScriptTriggerOverlap()
	--store all triggers of all scripts in the format [triggerId] = {scripts using this trigger}
	local allTriggers = {
		Auras = {},
		Casts = {},
		Npcs = {},
	}
	
	--build the table containinf all scripts and what scripts they trigger
	for index, scriptObject in ipairs (Plater.GetAllScripts()) do
		if (scriptObject.Enabled) then
			for _, spellId in ipairs (scriptObject.SpellIds) do
				
				if (scriptObject.ScriptType == 1) then
					--> triggers auras
					local triggerTable = allTriggers.Auras [spellId]
					if (not triggerTable) then
						allTriggers.Auras [spellId] = {scriptObject}
					else
						tinsert (triggerTable, scriptObject)
					end
				
				elseif (scriptObject.ScriptType == 2) then
					--> triggers cast
					local triggerTable = allTriggers.Casts [spellId]
					if (not triggerTable) then
						allTriggers.Casts [spellId] = {scriptObject}
					else
						tinsert (triggerTable, scriptObject)
					end

				end
			end
			
			for _, NpcId in ipairs (scriptObject.NpcNames) do
				local triggerTable = allTriggers.Npcs [NpcId]
				if (not triggerTable) then
					allTriggers.Npcs [NpcId] = {scriptObject}
				else
					tinsert (triggerTable, scriptObject)
				end
			end
		end
	end
	
	--> store scripts with overlap
	local scriptsWithOverlap = {
		Auras = {},
		Casts = {},
		Npcs = {},
	}
	
	local amount = 0
	
	--> check if there's more than 1 script for each trigger
	for triggerId, scriptsTable in pairs (allTriggers.Auras) do
		if (#scriptsTable > 1) then
			--overlap found
			scriptsWithOverlap.Auras [triggerId] = scriptsTable
			amount = amount + 1
		end
	end
	for triggerId, scriptsTable in pairs (allTriggers.Casts) do
		if (#scriptsTable > 1) then
			--overlap found
			scriptsWithOverlap.Casts [triggerId] = scriptsTable
			amount = amount + 1
		end
	end
	for triggerId, scriptsTable in pairs (allTriggers.Npcs) do
		if (#scriptsTable > 1) then
			--overlap found
			scriptsWithOverlap.Npcs [triggerId] = scriptsTable
			amount = amount + 1
		end
	end
	
	return scriptsWithOverlap, amount
end

--retrive the script object for a selected scriptId
function Plater.GetScriptObject (script_id)
	local script = Plater.db.profile.script_data [script_id]
	if (script) then
		return script
	end
end

function Plater.ImportScriptsFromLibrary()
	if (PlaterScriptLibrary) then
		for name, autoImportScript in pairs (PlaterScriptLibrary) do
			if ((Plater.db.profile.script_auto_imported [name] or 0) < autoImportScript.Revision) then
			
				Plater.db.profile.script_auto_imported [name] = autoImportScript.Revision

				local encodedString = autoImportScript.String
				if (encodedString) then
					Plater.ImportScriptString (encodedString, true, false)
					if (autoImportScript.Revision == 1) then
						Plater:Msg ("New Script Installed: " .. name)
					else
						Plater:Msg ("Applied Update to Script: " .. name)
					end
				end
			end
		end
		
		table.wipe (PlaterScriptLibrary)
	end
end

function Plater.ImportScriptString (text, ignoreRevision, showDebug)
	if (not text or type (text) ~= "string") then
		return
	end
	
	local errortext
	
	local LibAceSerializer = LibStub:GetLibrary ("AceSerializer-3.0")
	if (LibAceSerializer) then
		local decoded = DF.DecodeString (text)
		if (decoded) then
			local unSerializedOkay, indexScriptTable = LibAceSerializer:Deserialize (decoded)
			if (unSerializedOkay and type (indexScriptTable) == "table") then
				local newScript = Plater.BuildScriptObjectFromIndexTable (indexScriptTable)
				if (newScript) then
				
					local scriptName = newScript.Name
					local alreadyExists = false
					
					for i = 1, #Plater.db.profile.script_data do
						local scriptObject = Plater.db.profile.script_data [i]
						if (scriptObject.Name == scriptName) then
							--the script already exists
							if (not ignoreRevision) then
								if (scriptObject.Revision >= newScript.Revision) then
									if (showDebug) then
										Plater:Msg ("Your version of this script is newer or is the same version.")
										return false
									end
								end
							end
							
							tremove (Plater.db.profile.script_data, i)
							tinsert (Plater.db.profile.script_data, i, newScript)
							
							if (showDebug) then
								Plater:Msg ("Script replaced by a newer one.")
							end
							
							alreadyExists = true
							break
						end
					end
					
					if (not alreadyExists) then
						tinsert (Plater.db.profile.script_data, newScript)
						if (showDebug) then
							Plater:Msg ("Script added.")
						end
					end
				else
					errortext = "Cannot import: data imported is invalid"
				end
			else
				errortext = "Cannot import: couldn't unserialize the string"
			end
		else
			errortext = "Cannot import: couldn't decode the string"
		end
	else
		errortext = "Cannot import: LibAceSerializer not found"
	end
	
	if (errortext and showDebug) then
		Plater:Msg (errortext)
		return false
	end
	
	return true
end

--add a script 
function Plater.AddScript (scriptObjectToAdd, noOverwrite)
	if (scriptObjectToAdd) then
		--check if already exists
		local indexToReplace
		for i = 1, #Plater.db.profile.script_data do
			local scriptObject = Plater.db.profile.script_data [i]
			if (scriptObject.Name == scriptObjectToAdd.Name) then
				--the script already exists
				if (noOverwrite) then
					return
				else
					indexToReplace = i
					break
				end
			end
		end
		
		if (indexToReplace) then
			--remove the old script and add the new one
			tremove (Plater.db.profile.script_data, indexToReplace)
			tinsert (Plater.db.profile.script_data, indexToReplace, scriptObjectToAdd)
		else
			--add the new script to the end of the table
			tinsert (Plater.db.profile.script_data, scriptObjectToAdd)
		end
	end
end

function Plater.BuildScriptObjectFromIndexTable (indexTable)
	local scriptObject = {}
	
	scriptObject.Enabled 		= true --imported scripts are always enabled
	scriptObject.ScriptType 	= indexTable [1]
	scriptObject.Name  		= indexTable [2]
	scriptObject.SpellIds  		= indexTable [3]
	scriptObject.NpcNames  	= indexTable [4]
	scriptObject.Icon  		= indexTable [5]
	scriptObject.Desc  		= indexTable [6]
	scriptObject.Author  		= indexTable [7]
	scriptObject.Time  		= indexTable [8]
	scriptObject.Revision  		= indexTable [9]
	scriptObject.PlaterCore  	= indexTable [10]
	
	for i = 1, #Plater.CodeTypeNames do
		local memberName = Plater.CodeTypeNames [i]
		scriptObject [memberName] = indexTable [10 + i]
	end
	
	return scriptObject
end

function Plater.EncodeScript (scriptId)
	--get the script object
	local scriptToEncode = Plater.GetScriptObject (scriptId)
	--convert hash table to index table
	local indexedScriptTable = Plater.PrepareTableToExport (scriptToEncode)

	if (indexedScriptTable) then
		local LibAceSerializer = LibStub:GetLibrary ("AceSerializer-3.0")
		if (LibAceSerializer) then
			local serialized = LibAceSerializer:Serialize (indexedScriptTable)
			if (serialized) then
				local encoded = DF.EncodeString (serialized)
				if (encoded) then
					return encoded
				end
			end
		end
	end
end

function Plater.DecodeImportedString (str)
	local LibAceSerializer = LibStub:GetLibrary ("AceSerializer-3.0")
	if (LibAceSerializer) then
		local decoded = DF.DecodeString (str)
		if (decoded) then
			local unSerializedOkay, indexScriptTable = LibAceSerializer:Deserialize (decoded)
			if (unSerializedOkay and type (indexScriptTable) == "table") then
				local scriptObject = Plater.BuildScriptObjectFromIndexTable (indexScriptTable)
				if (scriptObject) then
					return scriptObject
				end
			end
		end
	end
end

--make a table for the script object using indexes instead of key to decrease the size of the string to be exported
function Plater.PrepareTableToExport (scriptObject)
	local t = {}
	
	t [1] = scriptObject.ScriptType
	t [2] = scriptObject.Name
	t [3] = scriptObject.SpellIds
	t [4] = scriptObject.NpcNames
	t [5] = scriptObject.Icon
	t [6] = scriptObject.Desc
	t [7] = scriptObject.Author
	t [8] = scriptObject.Time
	t [9] = scriptObject.Revision
	t [10] = scriptObject.PlaterCore
	
	for i = 1, #Plater.CodeTypeNames do
		local memberName = Plater.CodeTypeNames [i]
		t [#t + 1] = scriptObject [memberName]
	end
	
	return t
end

function Plater.ScriptReceivedFromGroup (prefix, playerName, playerRealm, playerGUID, importedString)
	if (not Plater.db.profile.script_banned_user [playerGUID]) then
		
		local importedScriptObject = Plater.DecodeImportedString (importedString)
		
		if (importedScriptObject) then
			local scriptName = importedScriptObject.Name
			local alreadyExists = false
			local alreadyExistsVersion = 0
			
			for i = 1, #Plater.db.profile.script_data do
				local scriptObject = Plater.db.profile.script_data [i]
				if (scriptObject.Name == scriptName) then
					alreadyExists = true
					alreadyExistsVersion = scriptObject.Revision
					break
				end
			end
			
			--add the script to the queue
			Plater.ScriptsWaitingApproval = Plater.ScriptsWaitingApproval or {}
			tinsert (Plater.ScriptsWaitingApproval, {importedScriptObject, playerName, playerRealm, playerGUID, alreadyExists, alreadyExistsVersion})
			
			Plater.ShowImportScriptConfirmation()
		end
	end
end

function Plater.ExportScriptToGroup (scriptId)
	local scriptToSend = Plater.GetScriptObject (scriptId)
	local LibAceSerializer = LibStub:GetLibrary ("AceSerializer-3.0")
	if (scriptToSend and LibAceSerializer) then
		local encodedString = Plater.EncodeScript (scriptId)
		
		if (encodedString) then
			if (IsInRaid (LE_PARTY_CATEGORY_HOME)) then
				Plater:SendCommMessage (COMM_PLATER_PREFIX, LibAceSerializer:Serialize (COMM_SCRIPT_GROUP_EXPORTED, UnitName ("player"), GetRealmName(), UnitGUID ("player"), encodedString), "RAID")
				
			elseif (IsInGroup (LE_PARTY_CATEGORY_HOME)) then
				Plater:SendCommMessage (COMM_PLATER_PREFIX, LibAceSerializer:Serialize (COMM_SCRIPT_GROUP_EXPORTED, UnitName ("player"), GetRealmName(), UnitGUID ("player"), encodedString), "PARTY")
				
			else
				Plater:Msg ("Failed to send the script: your group isn't home group.")
			end
		end
	else
		Plater:Msg ("Fail to find scriptId", scriptId)
	end
end

function Plater.ShowImportScriptConfirmation()

	if (not Plater.ImportConfirm) then
		Plater.ImportConfirm = DF:CreateSimplePanel (UIParent, 380, 130, "Plater Nameplates: Script Importer", "PlaterImportScriptConfirmation")
		Plater.ImportConfirm:Hide()
		DF:ApplyStandardBackdrop (Plater.ImportConfirm)
		
		Plater.ImportConfirm.AcceptText = Plater:CreateLabel (Plater.ImportConfirm, "", Plater:GetTemplate ("font", "OPTIONS_FONT_TEMPLATE"))
		Plater.ImportConfirm.AcceptText:SetPoint (16, -26)
		
		Plater.ImportConfirm.ScriptName = Plater:CreateLabel (Plater.ImportConfirm, "", Plater:GetTemplate ("font", "OPTIONS_FONT_TEMPLATE"))
		Plater.ImportConfirm.ScriptName:SetPoint (16, -41)
		
		Plater.ImportConfirm.ScriptVersion = Plater:CreateLabel (Plater.ImportConfirm, "", Plater:GetTemplate ("font", "OPTIONS_FONT_TEMPLATE"))
		Plater.ImportConfirm.ScriptVersion:SetPoint (16, -56)
		
		local accept_aura = function (self, button, scriptObject)
			Plater.AddScript (scriptObject)
			Plater.ImportConfirm:Hide()
			Plater.ShowImportScriptConfirmation()
		end
		
		local decline_aura = function (self, button, scriptObject, senderGUID)
			if (Plater.ImportConfirm.AlwaysIgnoreCheckBox.value) then
				Plater.db.profile.script_banned_user [senderGUID] = true
				Plater:Msg ("the user won't send more scripts to you.")
			end
			Plater.ImportConfirm:Hide()
			Plater.ShowImportScriptConfirmation()
		end
		
		Plater.ImportConfirm.AcceptButton = Plater:CreateButton (Plater.ImportConfirm, accept_aura, 125, 20, "Accept", -1, nil, nil, nil, nil, nil, Plater:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"))
		Plater.ImportConfirm.DeclineButton = Plater:CreateButton (Plater.ImportConfirm, decline_aura, 125, 20, "Decline", -1, nil, nil, nil, nil, nil, Plater:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"))
		
		Plater.ImportConfirm.AcceptButton:SetPoint ("bottomright", Plater.ImportConfirm, "bottomright", -14, 31)
		Plater.ImportConfirm.DeclineButton:SetPoint ("bottomleft", Plater.ImportConfirm, "bottomleft", 14, 31)
		
		Plater.ImportConfirm.AlwaysIgnoreCheckBox = DF:CreateSwitch (Plater.ImportConfirm, function()end, false, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, DF:GetTemplate ("switch", "OPTIONS_CHECKBOX_BRIGHT_TEMPLATE"))
		Plater.ImportConfirm.AlwaysIgnoreCheckBox:SetAsCheckBox()
		Plater.ImportConfirm.AlwaysIgnoreLabel = Plater:CreateLabel (Plater.ImportConfirm, "Always decline this user", Plater:GetTemplate ("font", "OPTIONS_FONT_TEMPLATE"))
		Plater.ImportConfirm.AlwaysIgnoreCheckBox:SetPoint ("topleft", Plater.ImportConfirm.DeclineButton, "bottomleft", 0, -4)
		Plater.ImportConfirm.AlwaysIgnoreLabel:SetPoint ("left", Plater.ImportConfirm.AlwaysIgnoreCheckBox, "right", 2, 0)
		
		Plater.ImportConfirm.Flash = Plater.CreateFlash (Plater.ImportConfirm)
	end
	
	if (Plater.ImportConfirm:IsShown()) then
		Plater.ImportConfirm.Title:SetText ("Plater Nameplates: Script Importer (" .. #Plater.ScriptsWaitingApproval + 1 .. ")")
		return
	else
		Plater.ImportConfirm.Title:SetText ("Plater Nameplates: Script Importer (" .. #Plater.ScriptsWaitingApproval .. ")")
	end
	
	local nextScriptToApprove = tremove (Plater.ScriptsWaitingApproval)
	
	if (nextScriptToApprove) then
		local scriptObject = nextScriptToApprove [1]
		local senderGUID = nextScriptToApprove [4]
	
		rawset (Plater.ImportConfirm.AcceptButton, "param1", scriptObject)
		rawset (Plater.ImportConfirm.AcceptButton, "param2", senderGUID)
		rawset (Plater.ImportConfirm.DeclineButton, "param1", scriptObject)
		rawset (Plater.ImportConfirm.DeclineButton, "param2", senderGUID)
		
		Plater.ImportConfirm.AcceptText.text = "The user |cFFFFAA00" .. nextScriptToApprove [2] .. "|r sent the script: |cFFFFAA00" .. scriptObject.Name .. "|r"
		Plater.ImportConfirm.ScriptName.text = "Script Version: |cFFFFAA00" .. scriptObject.Revision .. "|r"
		Plater.ImportConfirm.ScriptVersion.text = nextScriptToApprove [5] and "|cFFFFAA33You already have this script on version:|r " .. nextScriptToApprove [6] or "|cFF33DD33You don't have this script yet!"
		
		Plater.ImportConfirm:SetPoint ("center", UIParent, "center", 0, 150)
		Plater.ImportConfirm.AlwaysIgnoreCheckBox:SetValue (false)
		Plater.ImportConfirm.Flash:Play()
		Plater.ImportConfirm:Show()
		
		--play audio: IgPlayerInvite or igPlayerInviteDecline
	else
		Plater.ImportConfirm:Hide()
	end
	
end

--override colors
--function to set in the installhook for the default UI color change
function Plater.ColorOverrider (unitFrame)
	--is a namepalte and can override the color
	if (unitFrame.isNamePlate and Plater.CanOverrideColor) then
		--not in combat or aggro isn't changing the healthbar color
		if (not InCombatLockdown() or not DB_AGGRO_CHANGE_HEALTHBAR_COLOR) then
			--isn't a quest
			if (not unitFrame:GetParent() [MEMBER_QUEST]) then
				local reaction = unitFrame [MEMBER_REACTION]
				--is has a valid reaction
				if (reaction) then
					local r, g, b = unpack (Plater.db.profile.color_override_colors [reaction])
					Plater.ForceChangeHealthBarColor (unitFrame.healthBar, r, g, b, true)
				end
			end
		end
	end
end

--when the default unit frame refreshes the nameplate color, check if is in combat and if can use aggro to refresh the color by aggro
InstallHook ("CompactUnitFrame_UpdateHealthColor", function (unitFrame)
	if (unitFrame.isNamePlate and PLAYER_IN_COMBAT and unitFrame.CanCheckAggro) then
		if (unitFrame:GetParent() [MEMBER_REACTION] <= 4) then
			if (DB_AGGRO_CHANGE_HEALTHBAR_COLOR) then
				local healthBar = unitFrame.healthBar
				Plater.ForceChangeHealthBarColor (healthBar, healthBar.R, healthBar.G, healthBar.B)
			end
		end
	end
end)

--refresh the use of the color overrider
function Plater.RefreshColorOverride()
	if (Plater.db.profile.color_override) then
		InstallHook ("CompactUnitFrame_UpdateHealthColor", Plater.ColorOverrider)
		Plater.CanOverrideColor = true
	else
		Plater.CanOverrideColor = false
	end
	
	Plater.UpdateAllNameplateColors()
end

-- ~profile
function Plater:RefreshConfig()
	Plater.RefreshDBUpvalues()
	
	Plater.UpdateAllPlates()
	if (PlaterOptionsPanelFrame) then
		PlaterOptionsPanelFrame.RefreshOptionsFrame()
	end
	Plater.UpdateUseCastBar()
	Plater.UpdateUseClassColors()
end

function Plater.SaveConsoleVariables()
	local cvarTable = Plater.db.profile.saved_cvars
	
	if (not cvarTable) then
		return
	end
	
	--> personal and resources
	cvarTable ["nameplateShowSelf"] = GetCVar ("nameplateShowSelf")
	cvarTable [CVAR_RESOURCEONTARGET] = GetCVar (CVAR_RESOURCEONTARGET)
	cvarTable ["nameplatePersonalShowAlways"] = GetCVar ("nameplatePersonalShowAlways")
	cvarTable ["nameplatePersonalShowWithTarget"] = GetCVar ("nameplatePersonalShowWithTarget")
	cvarTable ["nameplatePersonalShowInCombat"] = GetCVar ("nameplatePersonalShowInCombat")
	cvarTable ["nameplateSelfAlpha"] = GetCVar ("nameplateSelfAlpha")
	cvarTable ["nameplateSelfScale"] = GetCVar ("nameplateSelfScale")
	
	--> which nameplates to show
	cvarTable [CVAR_SHOWALL] = GetCVar (CVAR_SHOWALL)
	cvarTable [CVAR_AGGROFLASH] = GetCVar (CVAR_AGGROFLASH)
	cvarTable [CVAR_ENEMY_MINIONS] = GetCVar (CVAR_ENEMY_MINIONS)
	cvarTable [CVAR_ENEMY_MINUS] = GetCVar (CVAR_ENEMY_MINUS)
	cvarTable [CVAR_FRIENDLY_GUARDIAN] = GetCVar (CVAR_FRIENDLY_GUARDIAN)
	cvarTable [CVAR_FRIENDLY_PETS] = GetCVar (CVAR_FRIENDLY_PETS)
	cvarTable [CVAR_FRIENDLY_TOTEMS] = GetCVar (CVAR_FRIENDLY_TOTEMS)
	cvarTable [CVAR_FRIENDLY_MINIONS] = GetCVar (CVAR_FRIENDLY_MINIONS)
	
	--> make it show the class color of players
	cvarTable [CVAR_CLASSCOLOR] = GetCVar (CVAR_CLASSCOLOR)
	
	--> just reset to default the clamp from the top side
	cvarTable [CVAR_CEILING] = GetCVar (CVAR_CEILING)
	
	--> reset the horizontal and vertical scale
	cvarTable [CVAR_SCALE_HORIZONTAL] = GetCVar (CVAR_SCALE_HORIZONTAL)
	cvarTable [CVAR_SCALE_VERTICAL] = GetCVar (CVAR_SCALE_VERTICAL)
	
	--> stacking nameplates
	cvarTable [CVAR_PLATEMOTION] = GetCVar (CVAR_PLATEMOTION)
	
	--> make the selection be a little bigger
	cvarTable ["nameplateSelectedScale"] = GetCVar ("nameplateSelectedScale")
	cvarTable ["nameplateMinScale"] = GetCVar ("nameplateMinScale")
	cvarTable ["nameplateGlobalScale"] = GetCVar ("nameplateGlobalScale")
	
	--> distance between each nameplate when using stacking
	cvarTable ["nameplateOverlapV"] = GetCVar ("nameplateOverlapV")
	
	--> movement speed of nameplates when using stacking, going above this isn't recommended
	cvarTable [CVAR_MOVEMENT_SPEED] = GetCVar (CVAR_MOVEMENT_SPEED)
	--> this must be 1 for bug reasons on the game client
	cvarTable ["nameplateOccludedAlphaMult"] = GetCVar ("nameplateOccludedAlphaMult")
	--> don't show friendly npcs
	cvarTable ["nameplateShowFriendlyNPCs"] = GetCVar ("nameplateShowFriendlyNPCs")
	--> make the personal bar hide very fast
	cvarTable ["nameplatePersonalHideDelaySeconds"] = GetCVar ("nameplatePersonalHideDelaySeconds")
	
	--> location of the personagem bar
	cvarTable ["nameplateSelfBottomInset"] = GetCVar ("nameplateSelfBottomInset")
	cvarTable ["nameplateSelfTopInset"] = GetCVar ("nameplateSelfTopInset")
	
	--> view distance
	cvarTable [CVAR_CULLINGDISTANCE] = GetCVar (CVAR_CULLINGDISTANCE)
	
end

--place most used data into local upvalues to save process time
function Plater.RefreshDBUpvalues()
	local profile = Plater.db.profile

	DB_TICK_THROTTLE = profile.update_throttle
	DB_LERP_COLOR = profile.use_color_lerp
	DB_LERP_COLOR_SPEED = profile.color_lerp_speed
	DB_PLATE_CONFIG = profile.plate_config
	DB_TRACK_METHOD = profile.aura_tracker.track_method
	
	DB_DO_ANIMATIONS = profile.use_health_animation
	DB_ANIMATION_TIME_DILATATION = profile.health_animation_time_dilatation
	
	DB_HOVER_HIGHLIGHT = profile.hover_highlight
	DB_USE_RANGE_CHECK = profile.range_check_enabled
	
	--> load spells filtered out, use the spellname instead of the spellId
		if (not DB_BUFF_BANNED) then
			DB_BUFF_BANNED = {}
			DB_DEBUFF_BANNED = {}
		else
			wipe (DB_BUFF_BANNED)
			wipe (DB_DEBUFF_BANNED)
		end
	
		for spellId, state in pairs (profile.aura_tracker.buff_banned) do
			local spellName = GetSpellInfo (spellId)
			if (spellName) then
				DB_BUFF_BANNED [spellName] = true
			end
		end
		
		for spellId, state in pairs (profile.aura_tracker.debuff_banned) do
			local spellName = GetSpellInfo (spellId)
			if (spellName) then
				DB_DEBUFF_BANNED [spellName] = true
			end
		end
	
	DB_AURA_ENABLED = profile.aura_enabled
	DB_AURA_ALPHA = profile.aura_alpha
	DB_AURA_X_OFFSET = profile.aura_x_offset
	DB_AURA_Y_OFFSET = profile.aura_y_offset
	
	DB_AURA_SEPARATE_BUFFS = Plater.db.profile.buffs_on_aura2

	DB_AURA_SHOW_IMPORTANT = profile.aura_show_important
	DB_AURA_SHOW_DISPELLABLE = profile.aura_show_dispellable
	DB_AURA_SHOW_BYPLAYER = profile.aura_show_aura_by_the_player
	DB_AURA_SHOW_BYUNIT = profile.aura_show_buff_by_the_unit

	DB_AURA_GROW_DIRECTION = profile.aura_grow_direction
	DB_AURA_GROW_DIRECTION2 = profile.aura2_grow_direction
	
	DB_BORDER_COLOR_R = profile.border_color [1]
	DB_BORDER_COLOR_G = profile.border_color [2]
	DB_BORDER_COLOR_B = profile.border_color [3]
	DB_BORDER_COLOR_A = profile.border_color [4]
	DB_BORDER_THICKNESS = profile.border_thickness
	DB_AGGRO_CHANGE_HEALTHBAR_COLOR = profile.aggro_modifies.health_bar_color
	DB_AGGRO_CHANGE_BORDER_COLOR = profile.aggro_modifies.border_color
	DB_AGGRO_CHANGE_NAME_COLOR = profile.aggro_modifies.actor_name_color
	
	DB_AGGRO_TANK_COLORS = profile.tank.colors
	DB_AGGRO_DPS_COLORS = profile.dps.colors
	
	DB_NOT_COMBAT_ALPHA_ENABLED = profile.not_affecting_combat_enabled
	
	DB_TARGET_SHADY_ENABLED = profile.target_shady_enabled
	DB_TARGET_SHADY_ALPHA = profile.target_shady_alpha
	DB_TARGET_SHADY_COMBATONLY = profile.target_shady_combat_only
	
	DB_NAME_NPCENEMY_ANCHOR = profile.plate_config.enemynpc.actorname_text_anchor.side
	DB_NAME_NPCFRIENDLY_ANCHOR = profile.plate_config.friendlynpc.actorname_text_anchor.side
	DB_NAME_PLAYERENEMY_ANCHOR = profile.plate_config.enemyplayer.actorname_text_anchor.side
	DB_NAME_PLAYERFRIENDLY_ANCHOR = profile.plate_config.friendlyplayer.actorname_text_anchor.side
	
	DB_TEXTURE_CASTBAR = LibSharedMedia:Fetch ("statusbar", profile.cast_statusbar_texture)
	DB_TEXTURE_CASTBAR_BG = LibSharedMedia:Fetch ("statusbar", profile.cast_statusbar_bgtexture)
	DB_TEXTURE_HEALTHBAR = LibSharedMedia:Fetch ("statusbar", profile.health_statusbar_texture)
	DB_TEXTURE_HEALTHBAR_BG = LibSharedMedia:Fetch ("statusbar", profile.health_statusbar_bgtexture)	
	
	DB_CASTBAR_HIDE_ENEMIES = profile.hide_enemy_castbars
	DB_CASTBAR_HIDE_FRIENDLY = profile.hide_friendly_castbars
	
	DB_CAPTURED_SPELLS = profile.captured_spells
	
	DB_SHOW_PURGE_IN_EXTRA_ICONS = profile.extra_icon_show_purge
	
	if (Plater.db.profile.healthbar_framelevel ~= 0 or Plater.db.profile.castbar_framelevel ~= 0) then
		DB_UPDATE_FRAMELEVEL = true
	else
		DB_UPDATE_FRAMELEVEL = false
	end
	
	--
	Plater.RefreshDBLists()
end

function Plater.RefreshDBLists()

	local profile = Plater.db.profile

	wipe (SPELL_WITH_ANIMATIONS)
	
	if (profile.spell_animations) then
		--for spellId, spellOptions in pairs (profile.spell_animation_list) do
		for spellId, animations in pairs (profile.spell_animation_list) do
			local frameAnimations = {}
			local spellName = GetSpellInfo (spellId)
			if (spellName) then
				for animationIndex, animationOptions in ipairs (animations) do
					if (animationOptions.enabled) then
						local data = DF.table.deploy ({}, animationOptions)
						data.animationCooldown = {} --store nameplate references with [nameplateRef] = GetTime() + cooldown
						tinsert (frameAnimations, data)
					end
				end
			end
			
			SPELL_WITH_ANIMATIONS [spellName] = frameAnimations
		end
	end
	
	wipe (SPECIAL_AURA_NAMES)
	wipe (CROWDCONTROL_AURA_NAMES)
	
	IS_USING_DETAILS_INTEGRATION = false
	
	--details integration
	if (Details and Details.plater) then
		local detailsPlaterConfig = Details.plater
		if (detailsPlaterConfig.realtime_dps_enabled) then
			IS_USING_DETAILS_INTEGRATION = true
		elseif (detailsPlaterConfig.realtime_dps_player_enabled) then
			IS_USING_DETAILS_INTEGRATION = true
		elseif (detailsPlaterConfig.damage_taken_enabled) then
			IS_USING_DETAILS_INTEGRATION = true
		end
	end	
	
	--build the crowd control list
	if (profile.debuff_show_cc) then
		for spellId, _ in pairs (DF.CrowdControlSpells) do
			local spellName = GetSpellInfo (spellId)
			if (spellName) then
				SPECIAL_AURA_NAMES [spellName] = true
				CROWDCONTROL_AURA_NAMES [spellName] = true
			end
		end
	end
	
	--> add auras added by the player into the special aura container
	for index, spellId in ipairs (profile.extra_icon_auras) do
		local spellName = GetSpellInfo (spellId)
		if (spellName) then
			SPECIAL_AURA_NAMES [spellName] = true
		end
	end

	Plater.UpdateAuraCache()
	Plater.IncreaseRefreshID()
end

function Plater.ApplyPatches()
	if (PlaterPatchLibrary) then
		local currentPatch = Plater.db.profile.patch_version
		for i = currentPatch+1, #PlaterPatchLibrary do
		
			local patch = PlaterPatchLibrary [i]
			Plater:Msg ("Applied Patch #" .. i .. ":")
			
			for o = 1, #patch.Notes do
				print (patch.Notes [o])
			end
			
			DF:Dispatch (patch.Func)
			
			Plater.db.profile.patch_version = i
		end
		
		PlaterPatchLibrary = nil
	end
end

function Plater.OnInit()
	Plater.RefreshDBUpvalues()
	
	Plater.CombatTime = GetTime()

	PLAYER_IN_COMBAT = false
	if (InCombatLockdown()) then
		PLAYER_IN_COMBAT = true
	end
	
	Plater.CompileAllScripts()

	--configuraï¿½ï¿½o do personagem
	PlaterDBChr = PlaterDBChr or {first_run2 = {}}
	PlaterDBChr.first_run2 = PlaterDBChr.first_run2 or {}
	
	PlaterDBChr.debuffsBanned = PlaterDBChr.debuffsBanned or {}
	PlaterDBChr.buffsBanned = PlaterDBChr.buffsBanned or {}
	PlaterDBChr.spellRangeCheck = PlaterDBChr.spellRangeCheck or {}
	
	for specID, _ in pairs (Plater.SpecList [select (2, UnitClass ("player"))]) do
		if (PlaterDBChr.spellRangeCheck [specID] == nil) then
			PlaterDBChr.spellRangeCheck [specID] = GetSpellInfo (Plater.DefaultSpellRangeList [specID])
		end
	end
	Plater.SpellForRangeCheck = ""
	Plater.PlayerGUID = UnitGUID ("player")
	
	Plater.ImportScriptsFromLibrary()
	Plater.ApplyPatches()
	
	local re_ForceCVars = function()
		Plater.ForceCVars()
	end
	function Plater.ForceCVars()
		if (InCombatLockdown()) then
			return C_Timer.After (1, re_ForceCVars)
		end
		SetCVar (CVAR_MIN_ALPHA, 0.90135484)
		SetCVar (CVAR_MIN_ALPHA_DIST, -10^5.2)
	end
	
	C_Timer.After (0.1, Plater.UpdatePlateClickSpace)
	C_Timer.After (1, Plater.GetSpellForRangeCheck)
	C_Timer.After (4, Plater.GetHealthCutoffValue)
	C_Timer.After (4.2, Plater.ForceCVars)
	
	Plater.RefreshColorOverride()
	Plater.UpdateMaxCastbarTextLength()
	
	local _, zoneType = GetInstanceInfo()
	Plater.ZoneInstanceType = zoneType
	
	--> check if is the first time Plater is running in the account or in the character
	local check_first_run = function()
		if (not UnitGUID ("player")) then
			C_Timer.After (1, Plater.CheckFirstRun)
			return
		end
		
		if (not Plater.db.profile.first_run2) then
			C_Timer.After (15, Plater.SetCVarsOnFirstRun)
			
		elseif (not PlaterDBChr.first_run2 [UnitGUID ("player")]) then
			--do not run cvars for individual characters
			C_Timer.After (15, Plater.SetCVarsOnFirstRun)
		else
			Plater.ShutdownInterfaceOptionsPanel()
		end
	end
	
	function Plater.CheckFirstRun()
		check_first_run()
	end
	Plater.CheckFirstRun()
	
	Plater:RegisterEvent ("NAME_PLATE_CREATED")
	Plater:RegisterEvent ("NAME_PLATE_UNIT_ADDED")
	Plater:RegisterEvent ("NAME_PLATE_UNIT_REMOVED")
	
	Plater:RegisterEvent ("PLAYER_TARGET_CHANGED")
	Plater:RegisterEvent ("PLAYER_FOCUS_CHANGED")
	
	Plater:RegisterEvent ("PLAYER_REGEN_DISABLED")
	Plater:RegisterEvent ("PLAYER_REGEN_ENABLED")
	
	Plater:RegisterEvent ("ZONE_CHANGED_NEW_AREA")
	Plater:RegisterEvent ("ZONE_CHANGED_INDOORS")
	Plater:RegisterEvent ("ZONE_CHANGED")
	Plater:RegisterEvent ("FRIENDLIST_UPDATE")
	Plater:RegisterEvent ("PLAYER_LOGOUT")
	Plater:RegisterEvent ("PLAYER_UPDATE_RESTING")
	
	Plater:RegisterEvent ("QUEST_ACCEPTED")
	Plater:RegisterEvent ("QUEST_REMOVED")
	Plater:RegisterEvent ("QUEST_ACCEPT_CONFIRM")
	Plater:RegisterEvent ("QUEST_COMPLETE")
	Plater:RegisterEvent ("QUEST_POI_UPDATE")
	Plater:RegisterEvent ("QUEST_DETAIL")
	Plater:RegisterEvent ("QUEST_FINISHED")
	Plater:RegisterEvent ("QUEST_GREETING")
	Plater:RegisterEvent ("QUEST_LOG_UPDATE")
	Plater:RegisterEvent ("UNIT_QUEST_LOG_CHANGED")
	Plater:RegisterEvent ("PLAYER_SPECIALIZATION_CHANGED")
	
	Plater:RegisterEvent ("ENCOUNTER_START")
	Plater:RegisterEvent ("ENCOUNTER_END")
	Plater:RegisterEvent ("CHALLENGE_MODE_START")

	function Plater:UNIT_FACTION (event, unit)
		--> fires when somebody changes faction near the player
		local plateFrame = C_NamePlate.GetNamePlateForUnit (unit)
		if (plateFrame) then
			--print ("Unit Changed Faction", plateFrame [MEMBER_UNITID], UnitName (unit), "Refreshing the nameplate...")
			--refresh
			Plater ["NAME_PLATE_UNIT_ADDED"] (Plater, "NAME_PLATE_UNIT_ADDED", plateFrame [MEMBER_UNITID])
		end
	end
	
	Plater:RegisterEvent ("UNIT_FACTION")
	
	--addon comm
	Plater.CommHandler = {
		[COMM_SCRIPT_GROUP_EXPORTED] = Plater.ScriptReceivedFromGroup,
	}
	
	function Plater:CommReceived (_, dataReceived)
		local LibAceSerializer = LibStub:GetLibrary ("AceSerializer-3.0")
		if (LibAceSerializer) then
			local prefix =  select (2, LibAceSerializer:Deserialize (dataReceived))
			local func = Plater.CommHandler [prefix]
			if (func) then
				local values = {LibAceSerializer:Deserialize (dataReceived)}
				if (values [1]) then
					tremove (values, 1) --remove the Deserialize state
					func (unpack (values))
				end
			end
		end
	end
	Plater:RegisterComm (COMM_PLATER_PREFIX, "CommReceived")
	
	--seta o nome do jogador na barra dele --ajuda a evitar os 'desconhecidos' pelo cliente do jogo (frame da unidade)
	InstallHook (Plater.GetDriverSubObjectName (CUF_Name, Plater.DriverFuncNames.OnNameUpdate), function (self)
		if (self.healthBar.actorName) then
			local plateFrame = self.PlateFrame
			plateFrame [MEMBER_NAME] = UnitName (self.unit)
			
			if (plateFrame.actorType == ACTORTYPE_FRIENDLY_PLAYER) then
				plateFrame.playerGuildName = GetGuildInfo (plateFrame [MEMBER_UNITID])
				Plater.UpdatePlateText (plateFrame, DB_PLATE_CONFIG [plateFrame.actorType], false)
			end
			
			Plater.UpdateUnitName (plateFrame)
			self.name:SetText ("")
		end
	end)
	
	--quando trocar de target, da overwrite na textura de overlay do selected target (frame da unidade) --review
	InstallHook (Plater.GetDriverSubObjectName (CUF_Name, Plater.DriverFuncNames.OnSelectionUpdate), function (self)
		if (self.isNamePlate) then
			if (self.selectionHighlight:IsShown()) then
				local targetedOverlayTexture = LibSharedMedia:Fetch ("statusbar", Plater.db.profile.health_selection_overlay)
				self.selectionHighlight:SetTexture (targetedOverlayTexture)
			end
			Plater.UpdatePlateBorders()
		end
	end)

	InstallHook (Plater.GetDriverGlobalObject ("NamePlateBorderTemplateMixin"), Plater.DriverFuncNames.OnBorderUpdate, function (self)
		Plater.UpdatePlateBorders (self.plateFrame)
	end)
	
	--sobrepï¿½e a funï¿½ï¿½o que atualiza as auras
	local Override_UNIT_AURA_EVENT = function (self, unit)
		local nameplate = C_NamePlate.GetNamePlateForUnit (unit)
		if (nameplate) then
			local filter;
			if (UnitIsUnit ("player", unit)) then
				filter = "HELPFUL|INCLUDE_NAME_PLATE_ONLY|PLAYER";
			else
				local reaction = UnitReaction ("player", unit);
				if (reaction and reaction <= 4) then
					filter = "HARMFUL|PLAYER"; --"HARMFUL|INCLUDE_NAME_PLATE_ONLY|PLAYER"
				elseif (reaction and reaction > 4) then
					filter = "HELPFUL|PLAYER";
				else
					filter = "NONE";
				end
			end
			
			nameplate.UnitFrame.BuffFrame:UpdateBuffs (unit, filter);
		end
	end

	if (not Plater.db.profile.aura_use_default) then
		InstallHook (_G [NPF_Name], Plater.DriverFuncNames.OnAuraUpdate, Override_UNIT_AURA_EVENT)
	end

	local BUFF_MAX_DISPLAY = BUFF_MAX_DISPLAY
	local CooldownFrame_Set = CooldownFrame_Set
	
	function Plater.Override_UpdateBuffs (self, unit, filter, showAll)
		if (not self [MEMBER_REACTION]) then
			--parece que nao esta colocando reaction em barras de jogadores
			return
		end

		--> shutdown the aura update from blizzard interface
		self.isActive = false
		self.BuffsAnchor.isActive = false
	end
	
	if (not Plater.db.profile.aura_use_default) then
		InstallHook (_G [NPB_Name], Plater.DriverFuncNames.OnUpdateBuffs, Plater.Override_UpdateBuffs)
	end
	
	--sobrepï¿½e a funï¿½ï¿½o, economiza processamento uma vez que o resultado da funï¿½ï¿½o original nï¿½o ï¿½ usado
	local Override_UNIT_AURA_ANCHORUPDATE = function (self)
		if (self.Point1) then
			self:SetPoint (self.Point1, self.Anchor, self.Point2, self.X, self.Y)
		end
	end
	
	if (not Plater.db.profile.aura_use_default) then
		InstallHook (_G [NPB_Name], Plater.DriverFuncNames.OnUpdateAnchor, Override_UNIT_AURA_ANCHORUPDATE)
	end
	
	--tamanho dos ï¿½cones dos debuffs sobre a nameplate
	function Plater.UpdateAuraIcons (self, unit, filter)
	
		if (not self [MEMBER_REACTION]) then
			--parece que nao esta colocando reaction em barras de jogadores
			return
		end

		local amtDebuffs = 0
		for _, auraIconFrame in ipairs (self.PlaterBuffList) do
			if (auraIconFrame:IsShown()) then
			
				if (auraIconFrame.IsPersonal) then
					local auraWidth = Plater.db.profile.aura_width_personal
					local auraHeight = Plater.db.profile.aura_height_personal
					auraIconFrame:SetSize (auraWidth, auraHeight)
					auraIconFrame.Icon:SetSize (auraWidth-2, auraHeight-2)
				else
					local auraWidth = Plater.db.profile.aura_width
					local auraHeight = Plater.db.profile.aura_height
					auraIconFrame:SetSize (auraWidth, auraHeight)
					auraIconFrame.Icon:SetSize (auraWidth-2, auraHeight-2)
				end

				amtDebuffs = amtDebuffs + 1
			end
		end

		for _, auraIconFrame in ipairs (self.BuffsAnchor.PlaterBuffList) do
			if (auraIconFrame:IsShown()) then
			
				if (auraIconFrame.IsPersonal) then
					local auraWidth = Plater.db.profile.aura_width_personal
					local auraHeight = Plater.db.profile.aura_height_personal
					auraIconFrame:SetSize (auraWidth, auraHeight)
					auraIconFrame.Icon:SetSize (auraWidth-2, auraHeight-2)
				else
					local auraWidth = Plater.db.profile.aura_width
					local auraHeight = Plater.db.profile.aura_height
					auraIconFrame:SetSize (auraWidth, auraHeight)
					auraIconFrame.Icon:SetSize (auraWidth-2, auraHeight-2)
				end

				amtDebuffs = amtDebuffs + 1
			end
		end		
		
		self.amtDebuffs = amtDebuffs
		
		Plater.UpdateBuffContainer (self:GetParent():GetParent())
	end
	
	if (not Plater.db.profile.aura_use_default) then
		InstallHook (Plater.GetDriverGlobalObject (NPB_Name), Plater.DriverFuncNames.OnUpdateBuffs, Plater.UpdateAuraIcons)
	end
	
	function Plater.RefreshAuras()
		for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do 
			Plater.UpdateAuraIcons (plateFrame.UnitFrame.BuffFrame, plateFrame [MEMBER_UNITID])
		end
	end
	
	function Plater.PlateShowingDebuffFrame (plateFrame)
		if (plateFrame.order == 3 and Plater.IsShowingResourcesOnTarget() and UnitIsUnit (plateFrame [MEMBER_UNITID], "target")) then --3 castbar, health, buffs
			--puxa os resources pra cima
			local SizeOf_healthBar_Height = plateFrame.UnitFrame.healthBar:GetHeight()
			NamePlateTargetResourceFrame:SetPoint ("BOTTOM", plateFrame.UnitFrame.name, "TOP", 0, -4 + SizeOf_healthBar_Height + (Plater.db.profile.aura_height))
		end
	end
	
	function Plater.PlateNotShowingDebuffFrame (plateFrame) 
		if (plateFrame.order == 3 and Plater.IsShowingResourcesOnTarget() and UnitIsUnit (plateFrame [MEMBER_UNITID], "target")) then --3 castbar, health, buffs
			--puxa os resources pra baixo
			local SizeOf_healthBar_Height = plateFrame.UnitFrame.healthBar:GetHeight()
			NamePlateTargetResourceFrame:SetPoint ("BOTTOM", plateFrame.UnitFrame.name, "TOP", 0, -4 + SizeOf_healthBar_Height)
		end
	end
	
	--> realign buff auras
	InstallHook (LayoutMixin, "Layout", function (self) 
		--> grow directions are: 2 Center 1 Left 3 Right
		if (self.isNameplate) then
			--> main buff container
			if (self.Name == "Main") then
				if (DB_AURA_GROW_DIRECTION ~= 2) then
					--> format the buffFrame size to 1, 1 so the custom grow direction can be effective
					self:SetSize (1, 1)
				end
			
			--> secondary buff container in case buffs are placed in a separated frame
			elseif (self.Name == "Secondary") then
				if (DB_AURA_GROW_DIRECTION2 ~= 2) then
					--> format the buffFrame size to 1, 1 so the custom grow direction can be effective
					self:SetSize (1, 1)
				end
			end
		end
	end)
	
	InstallHook (HorizontalLayoutMixin, "LayoutChildren", function (self, children, ignored, expandToHeight) 
		if (self.isNameplate) then
			local growDirection
			
			--> get the grow direction for the buff frame
			if (self.Name == "Main") then
				growDirection = DB_AURA_GROW_DIRECTION
			elseif (self.Name == "Secondary") then
				growDirection = DB_AURA_GROW_DIRECTION2
			end
			
			if (growDirection ~= 2) then
				local padding = 1
				local firstChild = children[1]
				local anchorPoint = firstChild and firstChild:GetParent() --> get the buffContainer
				
				if (anchorPoint) then
					--> set the point of the first child (the other children will follow the position)
					firstChild:ClearAllPoints()
					firstChild:SetPoint ("center", anchorPoint, "center", 0, 5)
				
					--> left to right
					if (growDirection == 3) then
						--> iterate among all children
						for i = 2, #children do
							local child = children [i]
							child:ClearAllPoints()
							child:SetPoint ("topleft", children [i-1], "topright", padding, 0)
						end

					--> right to left
					elseif (growDirection == 1) then
						--> iterate among all children
						for i = 2, #children do
							local child = children [i]
							child:ClearAllPoints()
							child:SetPoint ("topright", children [i-1], "topleft", -padding, 0)
						end
					end
				end
			end
		end
	end)
	
	--1 debuff, health, castbar
	--2 health, buffs, castbar
	--3 castbar, health, buffs
	
	function Plater.UpdateBuffContainer (plateFrame) 
		if ((plateFrame.UnitFrame.BuffFrame.amtDebuffs or 0) > 0) then
			--esta plate possui debuffs sendo mostrados
			Plater.PlateShowingDebuffFrame (plateFrame)
		else
			--esta plate nï¿½o tem debuffs
			Plater.PlateNotShowingDebuffFrame (plateFrame)
		end
	end

	function Plater.UpdateResourceAnchor()
		local namePlateTarget = C_NamePlate.GetNamePlateForUnit ("target", issecure())
		if (namePlateTarget) then
		
			local classResourceBar
			local _, class = UnitClass ("player")
			
			if (class == "MONK") then
				classResourceBar = ClassNameplateBrewmasterBarFrame
			elseif (class == "MAGE") then
				classResourceBar = ClassNameplateBarMageFrame
			elseif (class == "DEATHKNIGHT") then
				classResourceBar = DeathKnightResourceOverlayFrame
			elseif (class == "PALADIN") then
				classResourceBar = ClassNameplateBarPaladinFrame
			elseif (class == "ROGUE" or class == "DRUID") then
				classResourceBar = ClassNameplateBarRogueDruidFrame
			elseif (class == "WARLOCK") then
				classResourceBar = ClassNameplateBarWarlockFrame
			end
			
			classResourceBar:ClearAllPoints()
			classResourceBar:SetPoint ("bottom", namePlateTarget.UnitFrame.healthBar, "bottom", 0, 2 + Plater.db.profile.resources.y_offset_target)
			classResourceBar:SetScale (Plater.db.profile.resources.scale)
		end
	end
	
	InstallHook (Plater.GetDriverGlobalObject (NPF_Name), Plater.DriverFuncNames.OnResourceUpdate, function (self, onTarget, resourceFrame)
	--original name: SetupClassNameplateBar
		
		if (not resourceFrame) then
			return
		end
		
		local showSelf = GetCVar ("nameplateShowSelf")
		if (showSelf == "0") then
			return
		end
		
		if (resourceFrame ~= ClassNameplateManaBarFrame and onTarget) then
			Plater.UpdateResourceAnchor()
			
			--[=[
			local namePlateTarget = C_NamePlate.GetNamePlateForUnit ("target", issecure())
			if (namePlateTarget) then
				resourceFrame:ClearAllPoints()
				resourceFrame:SetPoint ("bottom", namePlateTarget.UnitFrame.healthBar, "bottom", 0, 2 + Plater.db.profile.resources.y_offset)
				resourceFrame:SetScale (Plater.db.profile.resources.scale)
				for i = 1, resourceFrame:GetNumPoints() do
					local myPoint, frame, relativePoint, xOffset, yOffset = resourceFrame:GetPoint (i)
					if (myPoint == "BOTTOM" or myPoint == "TOP") then
						resourceFrame:SetPoint (myPoint, frame, relativePoint, xOffset, yOffset + Plater.db.profile.resources.y_offset)
					end
				end
			end
			--]=]
			
		elseif (resourceFrame == ClassNameplateManaBarFrame and not onTarget) then
		
			local classResourceBar
			local _, class = UnitClass ("player")
			
			if (class == "MONK") then
				classResourceBar = ClassNameplateBrewmasterBarFrame
			elseif (class == "MAGE") then
				classResourceBar = ClassNameplateBarMageFrame
			elseif (class == "DEATHKNIGHT") then
				classResourceBar = DeathKnightResourceOverlayFrame
			elseif (class == "PALADIN") then
				classResourceBar = ClassNameplateBarPaladinFrame
			elseif (class == "ROGUE" or class == "DRUID") then
				classResourceBar = ClassNameplateBarRogueDruidFrame
			elseif (class == "WARLOCK") then
				classResourceBar = ClassNameplateBarWarlockFrame
			end
			
			if (classResourceBar) then
				for i = 1, classResourceBar:GetNumPoints() do
					local myPoint, frame, relativePoint, xOffset, yOffset = classResourceBar:GetPoint (i)
					if (myPoint == "BOTTOM" or myPoint == "TOP") then
						classResourceBar:SetPoint (myPoint, frame, relativePoint, xOffset, yOffset + Plater.db.profile.resources.y_offset)
						classResourceBar:SetScale (Plater.db.profile.resources.scale)
					end
				end
			end
		end
	end)

	InstallHook (Plater.GetDriverSubObjectName (CBF_Name, Plater.DriverFuncNames.OnCastBarShow), function (self)
		local plateFrame = C_NamePlate.GetNamePlateForUnit (self.unit or "")
		if (plateFrame) then
			if (plateFrame:GetAlpha() < 0.55) then
				plateFrame.UnitFrame.castBar.extraBackground:Show()
			else
				plateFrame.UnitFrame.castBar.extraBackground:Hide()
			end
		end
	end)
	
	function Plater.UpdateCastbarTargetText (castBar)
		local profile = Plater.db.profile
		
		if (profile.castbar_target_show) then
			local textString = castBar.FrameOverlay.TargetName
			textString:Show()
			
			DF:SetFontSize (textString, profile.castbar_target_text_size)
			DF:SetFontOutline (textString, profile.castbar_target_shadow)
			DF:SetFontColor (textString, profile.castbar_target_color)
			DF:SetFontFace (textString, profile.castbar_target_font)
			
			Plater.SetAnchor (textString, profile.castbar_target_anchor)
		else
			castBar.FrameOverlay.TargetName:Hide()
		end
	end
	
	-- ~cast
	local CastBarOnEventHook = function (self, event, ...)
	
		local unit = ...
		
		if (event == "PLAYER_ENTERING_WORLD") then
			if (not self.isNamePlate) then
				return
			end
			
			unit = self.unit
			
			local castname = UnitCastingInfo (unit)
			local channelname = UnitChannelInfo (unit)
			if (castname) then
				event = "UNIT_SPELLCAST_START"
			elseif (channelname) then
				event = "UNIT_SPELLCAST_CHANNEL_START"
			else
				return
			end
		end
		
		if (self.percentText) then
			if (event == "UNIT_SPELLCAST_START") then
				local unitCast = unit
				if (unitCast ~= self.unit or not self.isNamePlate) then
					return
				end
				
				local name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible, spellId = UnitCastingInfo (unitCast) --nameSubtext, 
				self.SpellName = name
				self.SpellID = spellId
				self.SpellTexture = texture
				self.SpellStartTime = startTime/1000
				self.SpellEndTime = endTime/1000
				
				self.IsInterrupted = false
				
				self.Icon:SetTexture (texture)
				self.Icon:Show()
				self.Icon:SetDrawLayer ("OVERLAY", 5)
				if (notInterruptible) then
					self.BorderShield:ClearAllPoints()
					self.BorderShield:SetPoint ("center", self.Icon, "center")
					self.BorderShield:SetDrawLayer ("OVERLAY", 6)
					self.BorderShield:Show()
				else
					self.BorderShield:Hide()
				end

				if (notInterruptible) then
					self:SetStatusBarColor (unpack (Plater.db.profile.cast_statusbar_color_nointerrupt))
					self.CanInterrupt = false
				else
					self:SetStatusBarColor (unpack (Plater.db.profile.cast_statusbar_color))
					self.CanInterrupt = true
				end
				
				self.ReUpdateNextTick = true
				self.ThrottleUpdate = -1
				
				self.FrameOverlay:SetBackdropBorderColor (0, 0, 0, 0)
				
				local textLenght = self.Text:GetStringWidth()
				if (textLenght > Plater.MaxCastBarTextLength) then
					Plater.UpdateSpellNameSize (self.Text)
				end
				
				Plater.UpdateCastbarTargetText (self)
				
				--self.Text:ClearAllPoints()
				--self.Text:SetPoint ("left", self.Icon, "right", 4, 0)
				
			elseif (event == "UNIT_SPELLCAST_CHANNEL_START") then
				local unitCast = unit
				if (unitCast ~= self.unit or not self.isNamePlate) then
					return
				end
				
				local name, text, texture, startTime, endTime, isTradeSkill, notInterruptible, spellId = UnitChannelInfo (unitCast) --nameSubtext, 
				self.SpellName = name
				self.SpellID = spellId
				self.SpellTexture = texture
				self.SpellStartTime = startTime/1000
				self.SpellEndTime = endTime/1000
				
				self.IsInterrupted = false
				
				self.Icon:SetTexture (texture)
				self.Icon:Show()
				self.Icon:SetDrawLayer ("OVERLAY", 5)
				if (notInterruptible) then
					self.BorderShield:ClearAllPoints()
					self.BorderShield:SetPoint ("center", self.Icon, "center")
					self.BorderShield:SetDrawLayer ("OVERLAY", 6)
					self.BorderShield:Show()
				else
					self.BorderShield:Hide()
				end
				
				if (notInterruptible) then
					self:SetStatusBarColor (unpack (Plater.db.profile.cast_statusbar_color_nointerrupt))
					self.CanInterrupt = false
				else
					self:SetStatusBarColor (unpack (Plater.db.profile.cast_statusbar_color))
					self.CanInterrupt = true
				end
				
				self.ReUpdateNextTick = true
				self.ThrottleUpdate = -1
				
				self.FrameOverlay:SetBackdropBorderColor (0, 0, 0, 0)
				
				local textLenght = self.Text:GetStringWidth()
				if (textLenght > Plater.MaxCastBarTextLength) then
					Plater.UpdateSpellNameSize (self.Text)
				end
				
				Plater.UpdateCastbarTargetText (self)
				
				--self.Text:ClearAllPoints()
				--self.Text:SetPoint ("left", self.Icon, "right", 4, 0)
			
			elseif (event == "UNIT_SPELLCAST_INTERRUPTED") then
				local unitCast = unit
				if (unitCast ~= self.unit or not self.isNamePlate) then
					return
				end
				
				self:OnHideWidget()
				self.IsInterrupted = true

			elseif (event == "UNIT_SPELLCAST_STOP") then
				local unitCast = unit
				if (unitCast ~= self.unit or not self.isNamePlate) then
					return
				end
				
				self:OnHideWidget()
				self.IsInterrupted = true
				
			end
			
		end
	end
	InstallHook (Plater.GetDriverSubObjectName (CBF_Name, Plater.DriverFuncNames.OnCastBarEvent), CastBarOnEventHook)
	
	local CastBarOnTickHook = function (self, deltaTime)
		if (self.percentText) then --é uma castbar do plater?
		
			self.ThrottleUpdate = self.ThrottleUpdate - deltaTime
			
			if (self.ThrottleUpdate < 0) then
				if (self.casting) then
					self.percentText:SetText (format ("%.1f", abs (self.value - self.maxValue)))
					
				elseif (self.channeling) then
					--self.percentText:SetText (format ("%.1f", abs (self.value - self.maxValue))) --elapsed
					local remainingTime = abs (self.value) -- remaining -- thanks nnogga
					if (remainingTime > 999) then
						self.percentText:SetText ("")
					else
						self.percentText:SetText (format ("%.1f", remainingTime))
					end
				else
					self.percentText:SetText ("")
				end
				
				if (self.ReUpdateNextTick) then
					self.BorderShield:ClearAllPoints()
					self.BorderShield:SetPoint ("center", self.Icon, "center")
					self.ReUpdateNextTick = nil
				end

				--get the script object of the aura which will be showing in this icon frame
				local globalScriptObject = SCRIPT_CASTBAR [self.SpellName]
				
				if (self.unit and Plater.db.profile.castbar_target_show) then
					local targetName = UnitName (self.unit .. "target")
					if (targetName) then
						local _, class = UnitClass (self.unit .. "target")
						if (class) then 
							self.FrameOverlay.TargetName:SetText (targetName)
							self.FrameOverlay.TargetName:SetTextColor (DF:ParseColors (class))
						else
							self.FrameOverlay.TargetName:SetText (targetName)
							DF:SetFontColor (self.FrameOverlay.TargetName, Plater.db.profile.castbar_target_color)
						end
					else
						self.FrameOverlay.TargetName:SetText ("")
					end
				else
					self.FrameOverlay.TargetName:SetText ("")
				end
				
				--plateFrame.UnitFrame.castBar.FrameOverlay.TargetName
				
				self.ThrottleUpdate = DB_TICK_THROTTLE

				--check if this aura has a custom script
				if (globalScriptObject and self.SpellEndTime and GetTime() < self.SpellEndTime and (self.casting or self.channeling) and not self.IsInterrupted) then
					--stored information about scripts
					local scriptContainer = self:ScriptGetContainer()
					--get the info about this particularly script
					local scriptInfo = self:ScriptGetInfo (globalScriptObject, scriptContainer)
					
					local scriptEnv = scriptInfo.Env
					scriptEnv._SpellID = self.SpellID
					scriptEnv._UnitID = self.unit
					scriptEnv._SpellName = self.SpellName
					scriptEnv._Texture = self.SpellTexture
					scriptEnv._Caster = self.unit
					scriptEnv._Duration = self.SpellEndTime - self.SpellStartTime
					scriptEnv._StartTime = self.SpellStartTime
					scriptEnv._CanInterrupt = self.CanInterrupt
					scriptEnv._EndTime = self.SpellEndTime
					scriptEnv._RemainingTime = max (self.SpellEndTime - GetTime(), 0)
					
					if (self.casting) then
						scriptEnv._CastPercent = self.value / self.maxValue * 100
					elseif (self.channeling) then
						scriptEnv._CastPercent = abs (self.value - self.maxValue) / self.maxValue * 100
					end
				
					--run onupdate script
					self:ScriptRunOnUpdate (scriptInfo)
				end
				
			end
		end
	end
	
	InstallHook (Plater.GetDriverSubObjectName (CBF_Name, Plater.DriverFuncNames.OnTick), CastBarOnTickHook)

	InstallHook (Plater.GetDriverSubObjectName (CUF_Name, Plater.DriverFuncNames.OnUpdateHealth), function (self)

		if (not self [MEMBER_REACTION]) then
			--parece que nao esta colocando reaction em barras de jogadores
			return
		end
		
		local plateFrame = self:GetParent()
		
		if (plateFrame.isNamePlate) then
			if (plateFrame.isSelf) then
				local healthBar = self.healthBar
				local min, max = healthBar:GetMinMaxValues()
				
				--> flash if low health
				if (healthBar:GetValue() / max < 0.27) then
					if (not healthBar.PlayHealthFlash) then
						Plater.CreateHealthFlashFrame (plateFrame)
					end
					healthBar.PlayHealthFlash()
				else
					if (healthBar.PlayHealthFlash) then
						if (healthBar:GetValue() / max > 0.5) then
							healthBar.canHealthFlash = true
						end
					end
				end
				
				local unitHealth = UnitHealth (plateFrame [MEMBER_UNITID])
				local unitHealthMax = UnitHealthMax (plateFrame [MEMBER_UNITID])
				
				healthBar.CurrentHealth = unitHealth
				healthBar.CurrentHealthMax = unitHealthMax
				
				-- is out of combat, reposition the health bar since the player health bar automatically change place when showing out of combat
				--it shows out of combat when the health had a decrease in value
				--[=[
				if (PLAYER_IN_COMBAT and not InCombatLockdown()) then
					local value = tonumber (GetCVar ("nameplateSelfBottomInset"))
					SetCVar ("nameplateSelfBottomInset", value)
					SetCVar ("nameplateSelfTopInset", abs (value - 99))
				end
				--]=]
			else
				if (DB_DO_ANIMATIONS) then
					--do healthbar animation ~animation ~healthbar ~health
					self.healthBar.CurrentHealthMax = UnitHealthMax (plateFrame [MEMBER_UNITID])
					self.healthBar.AnimationStart = self.healthBar.CurrentHealth
					self.healthBar.AnimationEnd = self.healthBar:GetValue()
					self.healthBar:SetValue (self.healthBar.CurrentHealth)
					self.healthBar.IsAnimating = true
					
					if (self.healthBar.AnimationEnd > self.healthBar.AnimationStart) then
						self.healthBar.AnimateFunc = Plater.AnimateRightWithAccel
					else
						self.healthBar.AnimateFunc = Plater.AnimateLeftWithAccel
					end
				else
					local unitHealth = UnitHealth (plateFrame [MEMBER_UNITID])
					local unitHealthMax = UnitHealthMax (plateFrame [MEMBER_UNITID])
					self.healthBar:SetValue (unitHealth)
					
					self.healthBar.CurrentHealth = unitHealth
					self.healthBar.CurrentHealthMax = unitHealthMax
				end
				
				if (plateFrame.actorType == ACTORTYPE_FRIENDLY_PLAYER) then
					Plater.ParseHealthSettingForPlayer (plateFrame)
					Plater.UpdatePlateText (plateFrame, DB_PLATE_CONFIG [ACTORTYPE_FRIENDLY_PLAYER], false)
				end
				
			end
		end
	end)

	local powerPercent = ClassNameplateManaBarFrame:CreateFontString (nil, "overlay", "GameFontNormal")
	ClassNameplateManaBarFrame.powerPercent = powerPercent
	powerPercent:SetPoint ("center")
	powerPercent:SetText ("100%")

	ClassNameplateManaBarFrame:HookScript ("OnValueChanged", function (self)
		ClassNameplateManaBarFrame.powerPercent:SetText (floor (self:GetValue()/select (2, self:GetMinMaxValues()) * 100) .. "%")
	end)
	
	InstallHook (Plater.GetDriverGlobalObject (NPF_Name), Plater.DriverFuncNames.OnRaidTargetUpdate, function (self)
		Plater.UpdateRaidMarker()
	end)
	
	InstallHook (Plater.GetDriverGlobalObject (NPF_Name), Plater.DriverFuncNames.OnOptionsUpdate, function()
		Plater.UpdateSelfPlate()
	end)
	
	InstallHook (Plater.GetDriverGlobalObject ("ClassNameplateManaBarFrame"), Plater.DriverFuncNames.OnManaBarOptionsUpdate, function()
		ClassNameplateManaBarFrame:SetSize (unpack (DB_PLATE_CONFIG.player.mana))
	end)
	
--]=]
	--> ~db
	Plater.db.RegisterCallback (Plater, "OnProfileChanged", "RefreshConfig")
	Plater.db.RegisterCallback (Plater, "OnProfileCopied", "RefreshConfig")
	Plater.db.RegisterCallback (Plater, "OnProfileReset", "RefreshConfig")
	Plater.db.RegisterCallback (Plater, "OnDatabaseShutdown", "SaveConsoleVariables")
	
	--saved_cvars
	Plater.UpdateSelfPlate()
	Plater.UpdateUseClassColors()
	
	C_Timer.After (4.1, Plater.QuestLogUpdated)
	C_Timer.After (5.1, function() Plater.IncreaseRefreshID(); Plater.UpdateAllPlates() end)
	
	for i = 1, 3 do
		C_Timer.After (i, Plater.RefreshDBUpvalues)
	end
	
end

function Plater.UpdateMaxCastbarTextLength()
	local barWidth = Plater.db.profile.plate_config.enemynpc.cast_incombat
	Plater.MaxCastBarTextLength = Plater.db.profile.plate_config.enemynpc.cast_incombat[1] - 40
end
--> set a default value here to be safe
Plater.MaxCastBarTextLength = 200

function Plater.UpdateAllNames()
	for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
		if (plateFrame.actorType == ACTORTYPE_PLAYER) then
			plateFrame.NameAnchor = 0
			
		elseif (plateFrame.actorType == UNITREACTION_FRIENDLY) then
			plateFrame.NameAnchor = DB_NAME_PLAYERFRIENDLY_ANCHOR
			
		elseif (plateFrame.actorType == ACTORTYPE_ENEMY_PLAYER) then
			plateFrame.NameAnchor = DB_NAME_PLAYERENEMY_ANCHOR
			
		elseif (plateFrame.actorType == ACTORTYPE_FRIENDLY_NPC) then
			plateFrame.NameAnchor = DB_NAME_NPCFRIENDLY_ANCHOR
			
		elseif (plateFrame.actorType == ACTORTYPE_ENEMY_NPC) then
			plateFrame.NameAnchor = DB_NAME_NPCENEMY_ANCHOR
			
		end
	
		Plater.UpdateUnitName (plateFrame)
	end
end

function Plater.UpdateSpellNameSize (nameString)
	local spellName = nameString:GetText()
	
	while (nameString:GetStringWidth() > Plater.MaxCastBarTextLength) do
		spellName = strsub (spellName, 1, #spellName - 1)
		nameString:SetText (spellName)
		if (string.len (spellName) <= 1) then
			break
		end
	end	
end

function Plater.UpdateTextSize (plateFrame, nameString)
	local stringSize = max (plateFrame.UnitFrame.healthBar:GetWidth() - 6, 44)
	local name = plateFrame [MEMBER_NAME]
	
	nameString:SetText (name)
	
	while (nameString:GetStringWidth() > stringSize) do
		name = strsub (name, 1, #name-1)
		nameString:SetText (name)
		if (string.len (name) <= 1) then
			break
		end
	end
end

function Plater.AddGuildNameToPlayerName (plateFrame)
	local currentText = plateFrame.CurrentUnitNameString:GetText()
	if (not currentText:find ("<")) then
		plateFrame.CurrentUnitNameString:SetText (currentText .. "\n" .. "<" .. plateFrame.playerGuildName .. ">")
	end
end

function Plater.UpdateUnitName (plateFrame, nameFontString)

	local nameString = plateFrame.CurrentUnitNameString

	if (plateFrame.NameAnchor >= 9) then
		--remove some character from the unit name if the name is placed inside the nameplate
		local stringSize = max (plateFrame.UnitFrame.healthBar:GetWidth() - 6, 44)
		local name = plateFrame [MEMBER_NAME]
		
		nameString:SetText (name)
		local stringWidth = nameString:GetStringWidth()
		
		if (stringWidth > stringSize and nameString == plateFrame.actorName) then 
			plateFrame:TickUpdate (true)
		else
			Plater.UpdateTextSize (plateFrame, nameString)
		end
	else
		nameString:SetText (plateFrame [MEMBER_NAME])
	end
	
	--check if the player has a guild, this check is done when the nameplate is added
	if (plateFrame.playerGuildName) then
		if (plateFrame.PlateConfig.show_guild_name) then
			Plater.AddGuildNameToPlayerName (plateFrame)
		end
	end
	
end

local tick_update = function (self)
	if (self.UpdateActorNameSize) then
		Plater.UpdateTextSize (self:GetParent(), self:GetParent().actorName)
	end
	
	self.UpdateActorNameSize = nil
	self:SetScript ("OnUpdate", nil)
end

function Plater.TickUpdate (plateFrame, UpdateActorNameSize)
	plateFrame.OnNextTickUpdate.UpdateActorNameSize = UpdateActorNameSize
	plateFrame.OnNextTickUpdate:SetScript ("OnUpdate", tick_update)
end



local re_update_self_plate = function()
	Plater.UpdateSelfPlate()
end

function Plater.UpdateSelfPlate()
	if (InCombatLockdown()) then
		return C_Timer.After (.3, re_update_self_plate)
	end
	C_NamePlate.SetNamePlateSelfClickThrough (DB_PLATE_CONFIG.player.click_through)
	
	--disabled due to modifying the player personal nameplate makes it be a little offset in the Y anchor making it to be in front of the player
--	C_NamePlate.SetNamePlateSelfSize (unpack (DB_PLATE_CONFIG.player.health))
	ClassNameplateManaBarFrame:SetSize (unpack (DB_PLATE_CONFIG.player.mana))
end

-- se o jogador estiver em combate, colorir a barra de acordo com o aggro do jogador ~aggro ï¿½ggro
local set_aggro_color = function (self, r, g, b) --self.actorName
	if (DB_AGGRO_CHANGE_HEALTHBAR_COLOR) then
		Plater.ForceChangeHealthBarColor (self, r, g, b)
	end
	if (DB_AGGRO_CHANGE_BORDER_COLOR) then
		Plater.ForceChangeBorderColor (self, r, g, b)
	end
	if (DB_AGGRO_CHANGE_NAME_COLOR) then
		self.actorName:SetTextColor (r, g, b)
	end
end

function Plater.UpdateNameplateThread (self) --self = UnitFrame

	--make sure there's a unitID in the unit frame
	if (not self.displayedUnit) then
		return
	end
	
	local isTanking, threatStatus = UnitDetailedThreatSituation ("player", self.displayedUnit)
	-- (3 = securely tanking, 2 = insecurely tanking, 1 = not tanking but higher threat than tank, 0 = not tanking and lower threat than tank)

	self.aggroGlowUpper:Hide()
	self.aggroGlowLower:Hide()
	
	if (Plater.PlayerIsTank) then
		--se o jogador ï¿½ TANK

		if (not isTanking) then
		
			if (UnitAffectingCombat (self.displayedUnit)) then
			
				if (IsInRaid()) then
					--check is the mob is tanked by another tank in the raid
					local unitTarget = UnitName (self.displayedUnit .. "target")
					if (TANK_CACHE [unitTarget]) then
						--nï¿½o hï¿½ aggro neste mob mas ele esta participando do combate
						Plater.ForceChangeHealthBarColor (self.healthBar, unpack (DB_AGGRO_TANK_COLORS.anothertank))
					else
						--nï¿½o hï¿½ aggro neste mob mas ele esta participando do combate
						Plater.ForceChangeHealthBarColor (self.healthBar, unpack (DB_AGGRO_TANK_COLORS.noaggro))
					end
					
					if (self.PlateFrame [MEMBER_NOCOMBAT]) then
						self.PlateFrame [MEMBER_NOCOMBAT] = nil
						Plater.CheckRange (self.PlateFrame, true)
					end
				else
					--nï¿½o hï¿½ aggro neste mob mas ele esta participando do combate
					Plater.ForceChangeHealthBarColor (self.healthBar, unpack (DB_AGGRO_TANK_COLORS.noaggro))
					
					if (self.PlateFrame [MEMBER_NOCOMBAT]) then
						self.PlateFrame [MEMBER_NOCOMBAT] = nil
						Plater.CheckRange (self.PlateFrame, true)
					end
				end
			else
				--if isn't a quest mob
				if (not self.PlateFrame [MEMBER_QUEST]) then
					--nï¿½o ha aggro e ele nï¿½o esta participando do combate
					if (self [MEMBER_REACTION] == 4) then
						--o mob ï¿½ um npc neutro, apenas colorir com a cor neutra
						set_aggro_color (self.healthBar, 1, 1, 0)
					else
						set_aggro_color (self.healthBar, unpack (DB_AGGRO_TANK_COLORS.nocombat))
					end
					
					if (DB_NOT_COMBAT_ALPHA_ENABLED) then
						self.PlateFrame [MEMBER_NOCOMBAT] = true
						self:SetAlpha (Plater.db.profile.not_affecting_combat_alpha)
					end
				end
			end
		else
			--o jogador esta tankando e:
			if (threatStatus == 3) then --esta tankando com seguranï¿½a
				set_aggro_color (self.healthBar, unpack (DB_AGGRO_TANK_COLORS.aggro))
				
			elseif (threatStatus == 2) then --esta tankando sem seguranï¿½a
				set_aggro_color (self.healthBar, unpack (DB_AGGRO_TANK_COLORS.pulling))
				self.aggroGlowUpper:Show()
				self.aggroGlowLower:Show()
				
			else --nï¿½o esta tankando
				set_aggro_color (self.healthBar, unpack (DB_AGGRO_TANK_COLORS.noaggro))
				
			end
			if (self.PlateFrame [MEMBER_NOCOMBAT]) then
				self.PlateFrame [MEMBER_NOCOMBAT] = nil
				Plater.CheckRange (self.PlateFrame, true)
				
			end
		end
	else
		--dps
		if (isTanking) then
			--o jogador esta tankando como dps
			set_aggro_color (self.healthBar, unpack (DB_AGGRO_DPS_COLORS.aggro))
			if (not self.PlateFrame.playerHasAggro) then
				self.PlateFrame.PlayBodyFlash ("-AGGRO-")
				
			end
			self.PlateFrame.playerHasAggro = true
			
			if (self.PlateFrame [MEMBER_NOCOMBAT]) then
				self.PlateFrame [MEMBER_NOCOMBAT] = nil
				Plater.CheckRange (self.PlateFrame, true)
			end
		else
			if (threatStatus == nil) then
				self.PlateFrame.playerHasAggro = false
				
				if (UnitAffectingCombat (self.displayedUnit)) then
					set_aggro_color (self.healthBar, unpack (DB_AGGRO_DPS_COLORS.noaggro))
					self.PlateFrame.playerHasAggro = false
					
					if (self.PlateFrame [MEMBER_NOCOMBAT]) then
						self.PlateFrame [MEMBER_NOCOMBAT] = nil
						Plater.CheckRange (self.PlateFrame, true)
					end
				else
					--if isn't a quest mob
					if (not self.PlateFrame [MEMBER_QUEST]) then
						--nï¿½o ha aggro e ele nï¿½o esta participando do combate
						if (self [MEMBER_REACTION] == 4) then
							--o mob ï¿½ um npc neutro, apenas colorir com a cor neutra
							set_aggro_color (self.healthBar, 1, 1, 0)
						else
							set_aggro_color (self.healthBar, unpack (DB_AGGRO_TANK_COLORS.nocombat))
						end
						
						if (Plater.db.profile.not_affecting_combat_enabled) then --not self.PlateFrame [MEMBER_NOCOMBAT] and 
							self.PlateFrame [MEMBER_NOCOMBAT] = true
							self:SetAlpha (Plater.db.profile.not_affecting_combat_alpha)
						end
					end
					
				end
			else
				if (threatStatus == 3) then --o jogador esta tankando como dps
					set_aggro_color (self.healthBar, unpack (DB_AGGRO_DPS_COLORS.aggro))
					if (not self.PlateFrame.playerHasAggro) then
						self.PlateFrame.PlayBodyFlash ("-AGGRO-")
					end
					self.PlateFrame.playerHasAggro = true
					
				elseif (threatStatus == 2) then --esta tankando com pouco aggro
					set_aggro_color (self.healthBar, unpack (DB_AGGRO_DPS_COLORS.aggro))
					
					self.PlateFrame.playerHasAggro = true
				elseif (threatStatus == 1) then --esta quase puxando o aggro
					set_aggro_color (self.healthBar, unpack (DB_AGGRO_DPS_COLORS.pulling))
					
					self.PlateFrame.playerHasAggro = false
					self.aggroGlowUpper:Show()
					self.aggroGlowLower:Show()
				elseif (threatStatus == 0) then --nï¿½o esta tankando
					set_aggro_color (self.healthBar, unpack (DB_AGGRO_DPS_COLORS.noaggro))
					self.PlateFrame.playerHasAggro = false
					
				end
				
				if (self.PlateFrame [MEMBER_NOCOMBAT]) then
					self.PlateFrame [MEMBER_NOCOMBAT] = nil
					Plater.CheckRange (self.PlateFrame, true)
				end
			end
		end
	end
end

Plater.OnAuraIconHide = function (self)
	local globalScriptObject = SCRIPT_AURA [self.SpellName]
	--does the aura has a custom script?
	if (globalScriptObject) then
		--does the aura icon has a table with script information?
		local scriptContainer = self:ScriptGetContainer()
		if (scriptContainer) then
			local scriptInfo = self:ScriptGetInfo (globalScriptObject, scriptContainer)
			if (scriptInfo and scriptInfo.IsActive) then
				self:ScriptRunOnHide (scriptInfo)
			end
		end
	end
end

--an aura is about to be added in the nameplate, need to get an icon for it ~geticonaura
function Plater.GetAuraIcon (self, isBuff)
	--self parent = NamePlate_X_UnitFrame
	--self = BuffFrame
	
	if (isBuff and DB_AURA_SEPARATE_BUFFS) then
		self = self.BuffsAnchor
	end
	
	local i = self.NextAuraIcon
	
	if (not self.PlaterBuffList[i]) then
		local newFrameIcon = CreateFrame ("Frame", self:GetParent():GetName() .. "Plater" .. self.Name .. "AuraIcon" .. i, self, "NameplateBuffButtonTemplate")
		newFrameIcon:Hide()
		newFrameIcon.UnitFrame = self:GetParent()
		newFrameIcon.spellId = 0
		newFrameIcon.ID = i
		newFrameIcon.RefreshID = 0
		newFrameIcon.IsPersonal = -1 --place holder
		
		self.PlaterBuffList[i] = newFrameIcon
		
		newFrameIcon:SetMouseClickEnabled (false)
		newFrameIcon:SetBackdrop ({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1})
		
		local timer = newFrameIcon.Cooldown:CreateFontString (nil, "overlay", "NumberFontNormal")
		newFrameIcon.Cooldown.Timer = timer
		timer:SetPoint ("center")
		
		local auraWidth = Plater.db.profile.aura_width
		local auraHeight = Plater.db.profile.aura_height
		newFrameIcon:SetSize (auraWidth, auraHeight)
		newFrameIcon.Icon:SetSize (auraWidth-2, auraHeight-2)
		
		--mixin the meta functions for scripts
		DF:Mixin (newFrameIcon, Plater.ScriptMetaFunctions)
		newFrameIcon.IsAuraIcon = true
		newFrameIcon:HookScript ("OnHide", newFrameIcon.OnHideWidget)
		
		local iconShowInAnimation = DF:CreateAnimationHub (newFrameIcon)
		DF:CreateAnimation (iconShowInAnimation, "Scale", 1, .05, .7, .7, 1.1, 1.1)
		DF:CreateAnimation (iconShowInAnimation, "Scale", 2, .05, 1.1, 1.1, 1, 1)
		newFrameIcon.ShowAnimation = iconShowInAnimation
	end
	
	local auraIconFrame = self.PlaterBuffList [i]
	self.NextAuraIcon = self.NextAuraIcon + 1
	return auraIconFrame
end

local test_performance = CreateFrame ("frame", nil, UIParent)
test_performance.Cooldown = 1
test_performance.TestedLastTick = false
test_performance.Enabled = false
Plater.GT = 0

if (test_performance.Enabled) then
	test_performance:SetScript ("OnUpdate", function (self, deltaTime)

		if (test_performance.TestedLastTick) then
			print ("elapsed:", deltaTime)
			test_performance.TestedLastTick = false
		end

		if (test_performance.Cooldown < 0) then
			-- performance test
			for i = 1, 10^6 do
				--local V = GetTime() -- 0.073
				--local V = Plater.GT -- 0.052
			end
		
			test_performance.Cooldown = 1
			test_performance.TestedLastTick = true
		else
			test_performance.Cooldown = test_performance.Cooldown - deltaTime
		end
	end)
end

function Plater.FormatTime (time)
	if (time >= 3600) then
		return floor (time / 3600) .. "h"
	elseif (time >= 60) then
		return floor (time / 60) .. "m"
	else
		return floor (time)
	end
end

--> show the tooltip in the aura icon
hooksecurefunc (NameplateBuffButtonTemplateMixin, "OnEnter", function (iconFrame)
	NamePlateTooltip:SetOwner (iconFrame, "ANCHOR_LEFT")
	NamePlateTooltip:SetUnitAura (iconFrame:GetParent().unit, iconFrame:GetID(), iconFrame.filter)

	iconFrame.UpdateTooltip = NameplateBuffButtonTemplateMixin.OnEnter
end)

--update the aura icon, this icon is getted with GetAuraIcon
function Plater.AddAura (auraIconFrame, i, spellName, texture, count, debuffType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId, isBuff, isShowAll, isDebuff, isPersonal)
	auraIconFrame:SetID (i)

	--> check if the icon is showing a different aura
	if (auraIconFrame.spellId ~= spellId) then
		if (not isBuff and not auraIconFrame:IsShown() or auraIconFrame.IsShowingBuff) then
			auraIconFrame.ShowAnimation:Play()
		end

		--> update the texture
		auraIconFrame.Icon:SetTexture (texture)
		--> update members
		
		auraIconFrame.spellId = spellId
		auraIconFrame.layoutIndex = auraIconFrame.ID
		auraIconFrame.IsShowingBuff = false

		auraIconFrame.filter = debuffType == "DEBUFF" and "HARMFUL" or debuffType == "BUFF" and "HELPFUL" or ""
	end
	
	--> caching the profile for performance
	local profile = Plater.db.profile
	
	--> check if a full refresh is required
	if (auraIconFrame.RefreshID < PLATER_REFRESH_ID) then
		--if tooltip enabled
		auraIconFrame:EnableMouse (profile.aura_show_tooltip)
		
		--stack counter
		local stackLabel = auraIconFrame.CountFrame.Count
		DF:SetFontSize (stackLabel, profile.aura_stack_size)
		DF:SetFontOutline (stackLabel, profile.aura_stack_shadow)
		DF:SetFontColor (stackLabel, profile.aura_stack_color)
		Plater.SetAnchor (stackLabel, profile.aura_stack_anchor)
		
		--timer
		local timerLabel = auraIconFrame.Cooldown.Timer
		DF:SetFontSize (timerLabel, profile.aura_timer_text_size)
		DF:SetFontOutline (timerLabel, profile.aura_timer_text_shadow)
		DF:SetFontColor (timerLabel, profile.aura_timer_text_color)
		Plater.SetAnchor (timerLabel, profile.aura_timer_text_anchor)
		
		auraIconFrame.RefreshID = PLATER_REFRESH_ID
	end

	--> update the icon size depending on where it is shown
	if (auraIconFrame.IsPersonal ~= isPersonal) then
		if (isPersonal) then
			local auraWidth = profile.aura_width_personal
			local auraHeight = profile.aura_height_personal
			auraIconFrame:SetSize (auraWidth, auraHeight)
			auraIconFrame.Icon:SetSize (auraWidth-2, auraHeight-2)
		else
			local auraWidth = profile.aura_width
			local auraHeight = profile.aura_height
			auraIconFrame:SetSize (auraWidth, auraHeight)
			auraIconFrame.Icon:SetSize (auraWidth-2, auraHeight-2)
		end
	end
	auraIconFrame.IsPersonal = isPersonal

	if (count > 1) then
		local stackLabel = auraIconFrame.CountFrame.Count
		stackLabel:SetText (count)
		stackLabel:Show()
	else
		auraIconFrame.CountFrame.Count:Hide()
	end
	
	--hard coded colors - todo: put them on a setting
	if (canStealOrPurge) then
		auraIconFrame:SetBackdropBorderColor (unpack (profile.aura_border_colors.steal_or_purge))
	
	elseif (isBuff) then
		auraIconFrame:SetBackdropBorderColor (unpack (profile.aura_border_colors.is_buff))
		auraIconFrame.IsShowingBuff = true
	
	elseif (isShowAll) then
		auraIconFrame:SetBackdropBorderColor (unpack (profile.aura_border_colors.is_show_all))
		
	elseif (isDebuff) then
		--> for debuffs on the player for the personal bar
		auraIconFrame:SetBackdropBorderColor (1, 0, 0, 1)
	
	else	
		auraIconFrame:SetBackdropBorderColor (0, 0, 0, 0)
	end
	
	CooldownFrame_Set (auraIconFrame.Cooldown, expirationTime - duration, duration, duration > 0, true)
	local timeLeft = expirationTime-GetTime()
	
	if (profile.aura_timer and timeLeft > 0) then
		--> update the aura timer
		local timerLabel = auraIconFrame.Cooldown.Timer
	
		timerLabel:SetText (Plater.FormatTime (timeLeft))
		timerLabel:Show()
	else
		auraIconFrame.Cooldown.Timer:Hide()
	end
	
	--check if the aura icon frame is already shown
	if (auraIconFrame:IsShown()) then
		--is was showing a different aura, simulate a OnHide()
		if (auraIconFrame.SpellName ~= spellName) then
			auraIconFrame:OnHideWidget()
		end
	end
	
	--> spell name must be update here and cannot be cached due to scripts
	auraIconFrame.SpellName = spellName
	auraIconFrame.InUse = true
	auraIconFrame:Show()
	
	--get the script object of the aura which will be showing in this icon frame
	local globalScriptObject = SCRIPT_AURA [spellName]
	
	--check if this aura has a custom script
	if (globalScriptObject) then
		--stored information about scripts
		local scriptContainer = auraIconFrame:ScriptGetContainer()
		
		--get the info about this particularly script
		local scriptInfo = auraIconFrame:ScriptGetInfo (globalScriptObject, scriptContainer)
		
		--set the aura information on the script env
		local scriptEnv = scriptInfo.Env
		scriptEnv._SpellID = spellId
		scriptEnv._UnitID = caster
		scriptEnv._SpellName = spellName
		scriptEnv._Texture = texture
		scriptEnv._Caster = caster
		scriptEnv._StackCount = count
		scriptEnv._Duration = duration
		scriptEnv._StartTime = expirationTime - duration
		scriptEnv._EndTime = expirationTime
		scriptEnv._RemainingTime = max (expirationTime - GetTime(), 0)
		
		--run onupdate script
		auraIconFrame:ScriptRunOnUpdate (scriptInfo)
	end	
	
	return true
end

local hide_non_used_auraFrames = function (self)
	--> regular buff frame
	local nextAuraIndex = self.NextAuraIcon
	for i = nextAuraIndex, #self.PlaterBuffList do
		local icon = self.PlaterBuffList [i]
		if (icon) then
			icon:Hide()
			icon.InUse = false
		end
	end
	
	--> if using a second buff frame to separate buffs, update it
	if (DB_AURA_SEPARATE_BUFFS) then
		--> secondary buff frame
		self = self.BuffsAnchor
		local nextAuraIndex = self.NextAuraIcon
		
		for i = nextAuraIndex, #self.PlaterBuffList do
			local icon = self.PlaterBuffList [i]
			if (icon) then
				icon:Hide()
				icon.InUse = false
			end
		end

		--> weird adding the Layout() call inside the hide function, but saves on performance
		--> update icon anchors
		self:Layout()
	end
end

function Plater.AddExtraIcon (self, spellName, texture, count, debuffType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId)
	local _, casterClass = UnitClass (caster or "")
	local casterName
	if (casterClass and UnitPlayerControlled (caster)) then
		--adding only the name for players in case the player used a stun
		casterName = UnitName (caster)
	end
	
	local borderColor
	
	if (canStealOrPurge) then
		borderColor = Plater.db.profile.extra_icon_show_purge_border
		
	elseif (CROWDCONTROL_AURA_NAMES [spellName]) then
		borderColor = Plater.db.profile.debuff_show_cc_border
	
	else
		borderColor = Plater.db.profile.extra_icon_border_color
	end
	
	--spellId, borderColor, startTime, duration, forceTexture, descText
	self.ExtraIconFrame:SetIcon (spellId, borderColor, expirationTime - duration, duration, false, casterName and {text = casterName, text_color = casterClass} or false)
end

-- ~auras ãura
function Plater.TrackSpecificAuras (self, unit, isBuff, aurasToCheck, isPersonal, noSpecial)

	if (isBuff) then
		--> buffs
		for i = 1, BUFF_MAX_DISPLAY do
			local name, texture, count, debuffType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId = UnitBuff (unit, i)
			if (not name) then
				break
			else
				debuffType = "BUFF"
				if (aurasToCheck [name]) then
					local auraIconFrame = Plater.GetAuraIcon (self, true)
					Plater.AddAura (auraIconFrame, i, name, texture, count, debuffType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId, true, false, false, isPersonal)
				end
				
				--> check if is a special aura
				if (not noSpecial and (SPECIAL_AURA_NAMES [name] or DB_SHOW_PURGE_IN_EXTRA_ICONS and canStealOrPurge)) then
					Plater.AddExtraIcon (self, name, texture, count, debuffType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId)
				end
			end
		end
	else
		--> debuffs
		for i = 1, BUFF_MAX_DISPLAY do
			local name, texture, count, debuffType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId = UnitDebuff (unit, i, "HARMFUL|PLAYER")
			if (not name) then
				break
			else
				debuffType = "DEBUFF"
				if (aurasToCheck [name]) then
					local auraIconFrame = Plater.GetAuraIcon (self)
					Plater.AddAura (auraIconFrame, i, name, texture, count, debuffType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId, false, false, false, isPersonal)
				end
				
				--> check if is a special aura
				if (not noSpecial and (SPECIAL_AURA_NAMES [name] or DB_SHOW_PURGE_IN_EXTRA_ICONS and canStealOrPurge)) then
					Plater.AddExtraIcon (self, name, texture, count, debuffType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId)
				end
			end
		end
	end
	
	return true
end

function Plater.UpdateAuras_Manual (self, unit, isPersonal)

	self.ExtraIconFrame:ClearIcons()

	--> reset next aura icon to use
	self.NextAuraIcon = 1
	self.BuffsAnchor.NextAuraIcon = 1
	
	Plater.TrackSpecificAuras (self, unit, false, MANUAL_TRACKING_DEBUFFS, isPersonal)
	Plater.TrackSpecificAuras (self, unit, true, MANUAL_TRACKING_BUFFS, isPersonal)

	--> hide not used aura frames
	hide_non_used_auraFrames (self)
end

function Plater.UpdateAuras_Automatic (self, unit)

	--> reset next aura icon to use
	self.NextAuraIcon = 1
	self.BuffsAnchor.NextAuraIcon = 1
	
	self.ExtraIconFrame:ClearIcons()
	
	--> debuffs
		for i = 1, BUFF_MAX_DISPLAY do
		
			local spellName, texture, count, debuffType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, isCastByPlayer, nameplateShowAll = UnitDebuff (unit, i)
			--start as false, during the checks can be changed to true, if is true this debuff is added on the nameplate
			local can_show_this_debuff
			debuffType = "DEBUFF"
			
			if (not spellName) then
				break
			
			--check if the debuff isn't filtered out
			elseif (not DB_DEBUFF_BANNED [spellName]) then
		
				--> important aura' 
				if (DB_AURA_SHOW_IMPORTANT and (nameplateShowAll or isBossDebuff)) then
					can_show_this_debuff = true
				
				--> is casted by the player
				elseif (DB_AURA_SHOW_BYPLAYER and caster and UnitIsUnit (caster, "player")) then
					can_show_this_debuff = true
				end

				if (SPECIAL_AURA_NAMES [spellName] or DB_SHOW_PURGE_IN_EXTRA_ICONS and canStealOrPurge) then
					Plater.AddExtraIcon (self, spellName, texture, count, debuffType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId)
				end
			end
			
			if (can_show_this_debuff) then
				--get the icon to be used by this aura
				local auraIconFrame = Plater.GetAuraIcon (self)
				Plater.AddAura (auraIconFrame, i, spellName, texture, count, debuffType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId)
			end
			
		end
	
	--> buffs
		for i = 1, BUFF_MAX_DISPLAY do
			local name, texture, count, debuffType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, isCastByPlayer, nameplateShowAll = UnitBuff (unit, i)
			debuffType = "BUFF"
			
			if (not name) then
				break
			
			elseif (not DB_BUFF_BANNED [name]) then

				--> important aura
				if (DB_AURA_SHOW_IMPORTANT and (nameplateShowAll or isBossDebuff)) then
					local auraIconFrame = Plater.GetAuraIcon (self, true)
					Plater.AddAura (auraIconFrame, i, name, texture, count, debuffType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId, false, true)
				
				--> is dispellable or can be steal
				elseif (DB_AURA_SHOW_DISPELLABLE and canStealOrPurge) then
					local auraIconFrame = Plater.GetAuraIcon (self, true)
					Plater.AddAura (auraIconFrame, i, name, texture, count, debuffType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId)
				
				--> is casted by the player
				elseif (DB_AURA_SHOW_BYPLAYER and caster and UnitIsUnit (caster, "player")) then
					local auraIconFrame = Plater.GetAuraIcon (self, true)
					Plater.AddAura (auraIconFrame, i, name, texture, count, debuffType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId)
				
				--> is casted by the unit it self
				elseif (DB_AURA_SHOW_BYUNIT and caster and UnitIsUnit (caster, unit) and not isCastByPlayer) then
					local auraIconFrame = Plater.GetAuraIcon (self, true)
					Plater.AddAura (auraIconFrame, i, name, texture, count, debuffType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId, true)
				
				end
				
				--> is a special aura?
				if (SPECIAL_AURA_NAMES [name] or DB_SHOW_PURGE_IN_EXTRA_ICONS and canStealOrPurge) then
					Plater.AddExtraIcon (self, name, texture, count, debuffType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId)
				end
			end
		end

	--track extra auras
		if (CAN_TRACK_EXTRA_BUFFS) then
			Plater.TrackSpecificAuras (self, unit, true, AUTO_TRACKING_EXTRA_BUFFS, false, true)
		end
		
		if (CAN_TRACK_EXTRA_DEBUFFS) then
			Plater.TrackSpecificAuras (self, unit, false, AUTO_TRACKING_EXTRA_DEBUFFS, false, true)
		end
	
	--hide non used icons
		hide_non_used_auraFrames (self)
end

function Plater.UpdateAuras_Self_Automatic (self)

	--> reset next aura icon to use
	self.NextAuraIcon = 1
	self.BuffsAnchor.NextAuraIcon = 1
	
	self.ExtraIconFrame:ClearIcons()
	
	--> debuffs
	if (Plater.db.profile.aura_show_debuffs_personal) then
		for i = 1, BUFF_MAX_DISPLAY do
			local name, texture, count, debuffType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId = UnitDebuff ("player", i)
			debuffType = "DEBUFF"
			
			if (not name) then
				break
				
			elseif (not DB_DEBUFF_BANNED [name]) then
				local auraIconFrame = Plater.GetAuraIcon (self)
				Plater.AddAura (auraIconFrame, i, name, texture, count, debuffType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId, false, false, true, true)
				
				if (SPECIAL_AURA_NAMES [name] or DB_SHOW_PURGE_IN_EXTRA_ICONS and canStealOrPurge) then
					Plater.AddExtraIcon (self, name, texture, count, debuffType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId)
				end
			end
		end
	end
	
	--> buffs
	if (Plater.db.profile.aura_show_buffs_personal) then
		for i = 1, BUFF_MAX_DISPLAY do
			local name, texture, count, debuffType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId = UnitBuff ("player", i, nil, "PLAYER")
			debuffType = "BUFF"
			
			if (not name) then
				break
				
			elseif (not DB_BUFF_BANNED [name] and (duration and (duration > 0 and duration < 91)) and (caster and UnitIsUnit (caster, "player"))) then
				local auraIconFrame = Plater.GetAuraIcon (self, true)
				Plater.AddAura (auraIconFrame, i, name, texture, count, debuffType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId, false, false, false, true)
			end
		end
	end	
	
	--> hide not used aura frames
	hide_non_used_auraFrames (self)
end

--debug animations

function Plater.DebugHealthAnimation()
	if (Plater.DebugHealthAnimation_Timer) then
		return
	end

	Plater.DebugHealthAnimation_Timer = C_Timer.NewTicker (1.5, function() --~animationtest
		for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
			local self = plateFrame.UnitFrame
			
			if (self.healthBar.CurrentHealth == 0) then
				self.healthBar.AnimationStart = 0
				self.healthBar.AnimationEnd = UnitHealthMax (plateFrame [MEMBER_UNITID])
			else
				self.healthBar.AnimationStart = UnitHealthMax (plateFrame [MEMBER_UNITID])
				self.healthBar.AnimationEnd = 0
			end
			
			self.healthBar:SetValue (self.healthBar.CurrentHealth)
			self.healthBar.CurrentHealthMax = UnitHealthMax (plateFrame [MEMBER_UNITID])
			
			self.healthBar.IsAnimating = true
			
			if (self.healthBar.AnimationEnd > self.healthBar.AnimationStart) then
				self.healthBar.AnimateFunc = Plater.AnimateRightWithAccel
			else
				self.healthBar.AnimateFunc = Plater.AnimateLeftWithAccel
			end
		
		end
	end)
	
	C_Timer.After (10, function()
		if (Plater.DebugHealthAnimation_Timer) then
			Plater.DebugHealthAnimation_Timer:Cancel()
			Plater.DebugHealthAnimation_Timer = nil
			Plater:Msg ("stopped the animation test.")
			Plater.UpdateAllPlates()
		end
	end)
	
	Plater:Msg ("is now animating nameplates in your screen for test purposes.")
end

function Plater.DebugColorAnimation()
	if (Plater.DebugColorAnimation_Timer) then
		return
	end

	Plater.DebugColorAnimation_Timer = C_Timer.NewTicker (0.5, function() --~animationtest
		for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
			--make the bar jump from green to pink - pink to green
			Plater.ForceChangeHealthBarColor (plateFrame.UnitFrame.healthBar, math.abs (math.sin (GetTime())), math.abs (math.cos (GetTime())), math.abs (math.sin (GetTime())))
		end
	end)

	C_Timer.After (10, function()
		if (Plater.DebugColorAnimation_Timer) then
			Plater.DebugColorAnimation_Timer:Cancel()
			Plater.DebugColorAnimation_Timer = nil
			Plater:Msg ("stopped the animation test.")
			Plater.UpdateAllPlates()
		end
	end)
	
	Plater:Msg ("is now animating color nameplates in your screen for test purposes.")
end

--> animation with acceleration ~animation
function Plater.AnimateLeftWithAccel (self, deltaTime)
	local distance = (self.AnimationStart - self.AnimationEnd) / self.CurrentHealthMax * 100	--scale 1 - 100
	local minTravel = min (distance / 10, 3) -- 10 = trigger distance to max speed 3 = speed scale on max travel
	local maxTravel = max (minTravel, 0.45) -- 0.45 = min scale speed on low travel speed
	local calcAnimationSpeed = (self.CurrentHealthMax * (deltaTime * DB_ANIMATION_TIME_DILATATION)) * maxTravel --re-scale back to unit health, scale with delta time and scale with the travel speed
	
	self.AnimationStart = self.AnimationStart - (calcAnimationSpeed)
	self:SetValue (self.AnimationStart)
	self.CurrentHealth = self.AnimationStart
	
	if (self.AnimationStart-1 <= self.AnimationEnd) then
		self:SetValue (self.AnimationEnd)
		self.CurrentHealth = self.AnimationEnd
		self.IsAnimating = false
	end
end

function Plater.AnimateRightWithAccel (self, deltaTime)
	local distance = (self.AnimationEnd - self.AnimationStart) / self.CurrentHealthMax * 100	--scale 1 - 100 basis
	local minTravel = math.min (distance / 10, 3) -- 10 = trigger distance to max speed 3 = speed scale on max travel
	local maxTravel = math.max (minTravel, 0.45) -- 0.45 = min scale speed on low travel speed
	local calcAnimationSpeed = (self.CurrentHealthMax * (deltaTime * DB_ANIMATION_TIME_DILATATION)) * maxTravel --re-scale back to unit health, scale with delta time and scale with the travel speed
	
	self.AnimationStart = self.AnimationStart + (calcAnimationSpeed)
	self:SetValue (self.AnimationStart)
	self.CurrentHealth = self.AnimationStart
	
	if (self.AnimationStart+1 >= self.AnimationEnd) then
		self:SetValue (self.AnimationEnd)
		self.CurrentHealth = self.AnimationEnd
		self.IsAnimating = false
	end
end

-- ~ontick ~onupdate ~tick õnupdate õntick 
local EventTickFunction = function (tickFrame, deltaTime)

	tickFrame.ThrottleUpdate = tickFrame.ThrottleUpdate - deltaTime
	local unitFrame = tickFrame.UnitFrame
	local healthBar = unitFrame.healthBar
	
	--throttle updates, things on this block update with the interval set in the advanced tab
	if (tickFrame.ThrottleUpdate < 0) then
		--make the db path smaller for performance
		local actorTypeDBConfig = DB_PLATE_CONFIG [tickFrame.actorType]

		--perform a range check
		Plater.CheckRange (tickFrame.PlateFrame)
		
		--health cutoff (execute range)
		if (CONST_USE_HEALTHCUTOFF) then
			local healthPercent = UnitHealth (tickFrame.unit) / UnitHealthMax (tickFrame.unit)
			if (healthPercent < CONST_HEALTHCUTOFF_AT) then
				if (not healthBar.healthCutOff:IsShown()) then
					healthBar.healthCutOff:SetHeight (healthBar:GetHeight())
					healthBar.healthCutOff:SetPoint ("left", healthBar, "left", healthBar:GetWidth() * CONST_HEALTHCUTOFF_AT, 0)
					healthBar.healthCutOff:Show()
					healthBar.healthCutOff.ShowAnimation:Play()
					
					healthBar.executeRange:Show()
					healthBar.executeRange:SetTexCoord (0, CONST_HEALTHCUTOFF_AT, 0, 1)
					healthBar.executeRange:SetAlpha (0.2)
					healthBar.executeRange:SetVertexColor (.3, .3, .3)
					healthBar.executeRange:SetHeight (healthBar:GetHeight())
					healthBar.executeRange:SetPoint ("right", healthBar.healthCutOff, "left")
					
					if (Plater.db.profile.health_cutoff_extra_glow) then
						healthBar.ExecuteGlowUp.ShowAnimation:Play()
						healthBar.ExecuteGlowDown.ShowAnimation:Play()
					end
				end
			else
				healthBar.healthCutOff:Hide()
				healthBar.executeRange:Hide()
				healthBar.ExecuteGlowUp:Hide()
				healthBar.ExecuteGlowDown:Hide()
			end
		end
		
		--if the unit tapped? (gray color)
		if (IsTapDenied (tickFrame.unit)) then
			Plater.ForceChangeHealthBarColor (healthBar, unpack (Plater.db.profile.tap_denied_color))
		
		--check aggro if is in combat
		elseif (PLAYER_IN_COMBAT) then
			if (unitFrame.CanCheckAggro) then
				Plater.UpdateNameplateThread (unitFrame)
			end
			
			if (actorTypeDBConfig.percent_text_enabled) then
				Plater.UpdateLifePercentText (healthBar, unitFrame.unit, actorTypeDBConfig.percent_show_health, actorTypeDBConfig.percent_text_show_decimals)
			end
		else
			--if not in combat, check if can show the percent health out of combat
			if (actorTypeDBConfig.percent_text_enabled and actorTypeDBConfig.percent_text_ooc) then
				Plater.UpdateLifePercentText (healthBar, unitFrame.unit, actorTypeDBConfig.percent_show_health, actorTypeDBConfig.percent_text_show_decimals)
				healthBar.lifePercent:Show()
			end
		end

		--update buffs and debuffs
		if (DB_AURA_ENABLED) then
			tickFrame.BuffFrame:UpdateAnchor()
			if (DB_TRACK_METHOD == 0x1) then --automatic
				if (tickFrame.actorType == ACTORTYPE_PLAYER) then
					--update auras on the personal bar
					Plater.UpdateAuras_Self_Automatic (tickFrame.BuffFrame)
				else
					Plater.UpdateAuras_Automatic (tickFrame.BuffFrame, tickFrame.unit)
				end
			else
				--manual aura track
				Plater.UpdateAuras_Manual (tickFrame.BuffFrame, tickFrame.unit, tickFrame.actorType == ACTORTYPE_PLAYER)
			end
			
			--update the buff layout and alpha
			tickFrame.BuffFrame.unit = tickFrame.unit
			tickFrame.BuffFrame:Layout()
			tickFrame.BuffFrame:SetAlpha (DB_AURA_ALPHA)
		end
		
		--set the delay to perform another update
		tickFrame.ThrottleUpdate = DB_TICK_THROTTLE

		--check if the unit name or unit npcID has a script
		local globalScriptObject = SCRIPT_UNIT [tickFrame.PlateFrame [MEMBER_NAMELOWER]] or SCRIPT_UNIT [tickFrame.PlateFrame [MEMBER_NPCID]]
		--check if this aura has a custom script
		if (globalScriptObject) then
			--stored information about scripts
			local scriptContainer = unitFrame:ScriptGetContainer()
			--get the info about this particularly script
			local scriptInfo = unitFrame:ScriptGetInfo (globalScriptObject, scriptContainer)
			
			local scriptEnv = scriptInfo.Env
			scriptEnv._UnitID = tickFrame.PlateFrame [MEMBER_UNITID]
			scriptEnv._NpcID = tickFrame.PlateFrame [MEMBER_NPCID]
			scriptEnv._UnitName = tickFrame.PlateFrame [MEMBER_NAME]
			scriptEnv._UnitGUID = tickFrame.PlateFrame [MEMBER_GUID]
			scriptEnv._HealthPercent = healthBar.CurrentHealth / healthBar.CurrentHealthMax * 100
	
			--run onupdate script
			unitFrame:ScriptRunOnUpdate (scriptInfo)
		end
		
		--details! integration
		if (IS_USING_DETAILS_INTEGRATION and not tickFrame.PlateFrame.isSelf and PLAYER_IN_COMBAT) then
			local detailsPlaterConfig = Details.plater

			--> current damage taken from all sources
			if (detailsPlaterConfig.realtime_dps_enabled) then
				local unitDamageTable = DetailsPlaterFrame.DamageTaken [tickFrame.PlateFrame [MEMBER_GUID]]
				if (unitDamageTable) then
					local damage = unitDamageTable.CurrentDamage or 0
					
					local textString = healthBar.DetailsRealTime
					textString:SetText (DF.FormatNumber (damage / PLATER_DPS_SAMPLE_SIZE))
				else
					local textString = healthBar.DetailsRealTime
					textString:SetText ("")
				end
			end
			
			if (detailsPlaterConfig.realtime_dps_player_enabled) then
				local unitDamageTable = DetailsPlaterFrame.DamageTaken [tickFrame.PlateFrame [MEMBER_GUID]]
				if (unitDamageTable) then
					local damage = unitDamageTable.CurrentDamageFromPlayer or 0
					
					local textString = healthBar.DetailsRealTimeFromPlayer
					textString:SetText (DF.FormatNumber (damage / PLATER_DPS_SAMPLE_SIZE))
				else
					local textString = healthBar.DetailsRealTimeFromPlayer
					textString:SetText ("")
				end

			end
			
			if (detailsPlaterConfig.damage_taken_enabled) then
				local unitDamageTable = DetailsPlaterFrame.DamageTaken [tickFrame.PlateFrame [MEMBER_GUID]]
				if (unitDamageTable) then
					local damage = unitDamageTable.TotalDamageTaken or 0
					
					local textString = healthBar.DetailsDamageTaken
					textString:SetText (DF.FormatNumber (damage))
				else
					local textString = healthBar.DetailsDamageTaken
					textString:SetText ("")
				end
			end
		end
		
		--end of throttled updates
	end

	--OnTick updates
		--smooth color transition ~lerpcolor
		if (DB_LERP_COLOR) then
			local currentR, currentG, currentB = healthBar.barTexture:GetVertexColor()
			local r, g, b = DF:LerpLinearColor (deltaTime, DB_LERP_COLOR_SPEED, currentR, currentG, currentB, healthBar.R, healthBar.G, healthBar.B)
			healthBar.barTexture:SetVertexColor (r, g, b)
		end
		
		--animate health bar ~animation
		if (DB_DO_ANIMATIONS) then
			if (healthBar.IsAnimating) then
				healthBar.AnimateFunc (healthBar, deltaTime)
			end
		end
		
		--height animation transition
		if (healthBar.HAVE_HEIGHT_ANIMATION) then
			if (healthBar.HAVE_HEIGHT_ANIMATION == "up") then
				local increment = deltaTime * Plater.db.profile.height_animation_speed * healthBar.ToIncreace
				local size = healthBar:GetHeight() + increment
				if (size + 0.0001 >= healthBar.TargetHeight) then
					healthBar:SetHeight (healthBar.TargetHeight)
					healthBar.HAVE_HEIGHT_ANIMATION = nil
					Plater.UpdateTarget (tickFrame.PlateFrame)
				else
					healthBar:SetHeight (size)
				end			
				
			elseif (healthBar.HAVE_HEIGHT_ANIMATION == "down") then
				local decrease = deltaTime * Plater.db.profile.height_animation_speed * healthBar.ToDecrease
				local size = healthBar:GetHeight() - decrease
				if (size - 0.0001 <= healthBar.TargetHeight) then
					healthBar:SetHeight (healthBar.TargetHeight)
					healthBar.HAVE_HEIGHT_ANIMATION = nil
					Plater.UpdateTarget (tickFrame.PlateFrame)
				else
					healthBar:SetHeight (size)
				end			
				
			end
		end
end

--forï¿½a a default UI a trocar a cor das barras
function Plater.UpdateAllNameplateColors()
	if (Plater.CanOverrideColor) then
		for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
			CompactUnitFrame_UpdateHealthColor (plateFrame.UnitFrame)
		end
	else
		for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
			local healthBar = plateFrame.UnitFrame.healthBar
			Plater.ForceChangeHealthBarColor (healthBar, healthBar.r, healthBar.g, healthBar.b)
		end
	end
end

function Plater.SetPlateBackground (plateFrame)
	plateFrame:SetBackdrop ({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16, edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1})
	plateFrame:SetBackdropColor (0, 0, 0, 0.5)
	plateFrame:SetBackdropBorderColor (0, 0, 0, 1)
end

local shutdown_platesize_debug = function (timer)
	for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
		if (Plater.db.profile.click_space_always_show) then
			Plater.SetPlateBackground (plateFrame)
		else
			plateFrame:SetBackdrop (nil)
		end
	end
	
	Plater.PlateSizeDebugTimer = nil
end

local re_UpdatePlateClickSpace = function()
	Plater.UpdatePlateClickSpace()
end

-- ~platesize
function Plater.UpdatePlateClickSpace (needReorder, isDebug)
	if (not Plater.CanChangePlateSize()) then
		return C_Timer.After (1, re_UpdatePlateClickSpace)
	end
	
	local width, height = Plater.db.profile.click_space_friendly[1], Plater.db.profile.click_space_friendly[2]
	C_NamePlate.SetNamePlateFriendlySize (width, height)
	
	local width, height = Plater.db.profile.click_space[1], Plater.db.profile.click_space[2]
	C_NamePlate.SetNamePlateEnemySize (width, height)
	
	C_NamePlate.SetNamePlateFriendlyClickThrough (Plater.db.profile.plate_config.friendlyplayer.click_through) 
	
	if (isDebug and not Plater.db.profile.click_space_always_show) then
		for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
			plateFrame:SetBackdrop ({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16, edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1})
			if (Plater.PlateSizeDebugTimer and not Plater.PlateSizeDebugTimer._cancelled) then
				Plater.PlateSizeDebugTimer:Cancel()
			end
		end
		if (not Plater.PlateSizeDebugTimer) then
			Plater:Msg ("showing the clickable area for test purposes.")
		end
		Plater.PlateSizeDebugTimer = C_Timer.NewTimer (3, shutdown_platesize_debug)
	end
	
	if (needReorder) then
		for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
			Plater.UpdatePlateFrame (plateFrame, plateFrame.actorType)
		end
	end
end

function Plater.UpdateAllPlates (forceUpdate, justAdded)
	for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
		Plater.UpdatePlateFrame (plateFrame, nil, forceUpdate, justAdded)
	end
end

function Plater.GetAllShownPlates()
	--return C_NamePlate.GetNamePlates()
	return C_NamePlate.GetNamePlates (issecure())
end

-- ~events
function Plater:PLAYER_SPECIALIZATION_CHANGED()
	Plater.GetSpellForRangeCheck()
	Plater.GetHealthCutoffValue()
end

function Plater.UpdateAuraCache()
	
	--manual tracking has an indexed table to store what to track
	--the extra auras for automatic tracking has a hash table with spellIds
	
	--manual aura tracking
		local manualBuffsToTrack = Plater.db.profile.aura_tracker.buff
		local manualDebuffsToTrack = Plater.db.profile.aura_tracker.debuff

		wipe (MANUAL_TRACKING_DEBUFFS)
		wipe (MANUAL_TRACKING_BUFFS)
		
		for i = 1, #manualDebuffsToTrack do
			local spellName = GetSpellInfo (manualDebuffsToTrack [i])
			if (spellName) then
				MANUAL_TRACKING_DEBUFFS [spellName] = true
			else
				--add the entry in case there's a spell name instead of a spellId in the list (for back compatibility)
				MANUAL_TRACKING_DEBUFFS [manualDebuffsToTrack [i]] = true
			end
		end

		for i = 1, #manualBuffsToTrack do
			local spellName = GetSpellInfo (manualBuffsToTrack [i])
			if (spellName) then
				MANUAL_TRACKING_BUFFS [spellName] = true
			else
				--add the entry in case there's a spell name instead of a spellId in the list (for back compatibility)
				MANUAL_TRACKING_BUFFS [manualBuffsToTrack [i]]= true
			end
		end

	--extra auras to track on automatic aura tracking
		local extraBuffsToTrack = Plater.db.profile.aura_tracker.buff_tracked
		local extraDebuffsToTrack = Plater.db.profile.aura_tracker.debuff_tracked
		
		wipe (AUTO_TRACKING_EXTRA_BUFFS)
		wipe (AUTO_TRACKING_EXTRA_DEBUFFS)
		
		CAN_TRACK_EXTRA_BUFFS = false
		CAN_TRACK_EXTRA_DEBUFFS = false

		for spellId, _ in pairs (extraBuffsToTrack) do
			local spellName = GetSpellInfo (spellId)
			if (spellName) then
				AUTO_TRACKING_EXTRA_BUFFS [spellName] = true
				CAN_TRACK_EXTRA_BUFFS = true
			end
		end
		
		for spellId, _ in pairs (extraDebuffsToTrack) do
			local spellName = GetSpellInfo (spellId)
			if (spellName) then
				AUTO_TRACKING_EXTRA_DEBUFFS [spellName] = true
				CAN_TRACK_EXTRA_DEBUFFS = true
			end
		end

end

function Plater:PLAYER_REGEN_DISABLED()

	PLAYER_IN_COMBAT = true

	--> refresh tank cache
		Plater.PlayerIsTank = false
	
		wipe (TANK_CACHE)
		
		--add the player to the tank pool if the player is a tank
		if (IsPlayerEffectivelyTank()) then
			TANK_CACHE [UnitName ("player")] = true
			Plater.PlayerIsTank = true
		end
		
		--search for tanks in the raid
		if (IsInRaid()) then
			for i = 1, GetNumGroupMembers() do
				if (IsUnitEffectivelyTank ("raid" .. i)) then
					if (not UnitIsUnit ("raid" .. i, "player")) then
						TANK_CACHE [UnitName ("raid" .. i)] = true
					end
				end
			end
		end
	
	Plater.UpdateAuraCache()
	
	C_Timer.After (0.5, Plater.UpdateAllPlates)
	Plater.CombatTime = GetTime()
	
	--C_Timer.After (1.01, Plater.OnPlayerTargetChanged) --it update inside the tick after the animation is done
end
function Plater:PLAYER_REGEN_ENABLED()

	PLAYER_IN_COMBAT = false
	
	for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
		plateFrame [MEMBER_NOCOMBAT] = nil
	end
	
	C_Timer.After (0.41, Plater.UpdateAllNameplateColors) --schedule to avoid taint issues
	C_Timer.After (0.51, Plater.UpdateAllPlates)

	--C_Timer.After (0.51, Plater.OnPlayerTargetChanged) --it update inside the tick after the animation is done
end

function Plater.FRIENDLIST_UPDATE()
	wipe (Plater.FriendsCache)
	for i = 1, GetNumFriends() do
		local toonName, level, class, area, connected, status, note = GetFriendInfo (i)
		if (connected and toonName) then
			Plater.FriendsCache [toonName] = true
			Plater.FriendsCache [DF:RemoveRealmName (toonName)] = true
		end
	end
	for i = 1, BNGetNumFriends() do 
		local presenceID, presenceName, battleTag, isBattleTagPresence, toonName, toonID, client, isOnline, lastOnline, isAFK, isDND, messageText, noteText, isRIDFriend, broadcastTime, canSoR = BNGetFriendInfo (i)
		if (isOnline and toonName) then
			Plater.FriendsCache [toonName] = true
		end
	end
	Plater.UpdateAllPlates()
end

function Plater:QUEST_REMOVED()
	Plater.QuestLogUpdated()
end
function Plater:QUEST_ACCEPTED()
	Plater.QuestLogUpdated()
end
function Plater:QUEST_ACCEPT_CONFIRM()
	Plater.QuestLogUpdated()
end
function Plater:QUEST_COMPLETE()
	Plater.QuestLogUpdated()
end
function Plater:QUEST_POI_UPDATE()
	Plater.QuestLogUpdated()
end
function Plater:QUEST_QUERY_COMPLETE()
	Plater.QuestLogUpdated()
end
function Plater:QUEST_DETAIL()
	Plater.QuestLogUpdated()
end
function Plater:QUEST_FINISHED()
	Plater.QuestLogUpdated()
end
function Plater:QUEST_GREETING()
	Plater.QuestLogUpdated()
end
function Plater:QUEST_LOG_UPDATE()
	Plater.QuestLogUpdated()
end
function Plater:UNIT_QUEST_LOG_CHANGED()
	Plater.QuestLogUpdated()
end

function Plater:PLAYER_FOCUS_CHANGED()
	Plater.OnPlayerTargetChanged()
end
function Plater:PLAYER_TARGET_CHANGED()
	Plater.OnPlayerTargetChanged()
end

local wait_for_leave_combat = function()
	Plater:ZONE_CHANGED_NEW_AREA()
end

local re_RefreshAutoToggle = function()
	return Plater.RefreshAutoToggle()
end

function Plater.RefreshAutoToggle()

	if (InCombatLockdown()) then
		C_Timer.After (0.5, re_RefreshAutoToggle)
		return
	end
	
	local zoneName, zoneType = GetInstanceInfo()

	--friendly nameplate toggle
	if (Plater.db.profile.auto_toggle_friendly_enabled) then
		--discover which is the map type the player is in
		if (zoneType == "party") then
			SetCVar ("nameplateShowFriends", Plater.db.profile.auto_toggle_friendly ["party"] and CVAR_ENABLED or CVAR_DISABLED)
			
		elseif (zoneType == "raid") then
			SetCVar ("nameplateShowFriends", Plater.db.profile.auto_toggle_friendly ["raid"] and CVAR_ENABLED or CVAR_DISABLED)
			
		elseif (zoneType == "arena") then
			SetCVar ("nameplateShowFriends", Plater.db.profile.auto_toggle_friendly ["arena"] and CVAR_ENABLED or CVAR_DISABLED)
			
		else
			--if the player is resting, consider inside a major city
			if (IsResting()) then
				SetCVar ("nameplateShowFriends", Plater.db.profile.auto_toggle_friendly ["cities"] and CVAR_ENABLED or CVAR_DISABLED)
			else
				SetCVar ("nameplateShowFriends", Plater.db.profile.auto_toggle_friendly ["world"] and CVAR_ENABLED or CVAR_DISABLED)
			end
		end
	end
	
	--stacking toggle
	if (Plater.db.profile.auto_toggle_stacking_enabled and Plater.db.profile.stacking_nameplates_enabled) then
		--discover which is the map type the player is in
		if (zoneType == "party") then
			SetCVar (CVAR_PLATEMOTION, Plater.db.profile.auto_toggle_stacking ["party"] and CVAR_ENABLED or CVAR_DISABLED)
			
		elseif (zoneType == "raid") then
			SetCVar (CVAR_PLATEMOTION, Plater.db.profile.auto_toggle_stacking ["raid"] and CVAR_ENABLED or CVAR_DISABLED)
			
		elseif (zoneType == "arena") then
			SetCVar (CVAR_PLATEMOTION, Plater.db.profile.auto_toggle_stacking ["arena"] and CVAR_ENABLED or CVAR_DISABLED)
			
		else
			--if the player is resting, consider inside a major city
			if (IsResting()) then
				SetCVar (CVAR_PLATEMOTION, Plater.db.profile.auto_toggle_stacking ["cities"] and CVAR_ENABLED or CVAR_DISABLED)
			else
				SetCVar (CVAR_PLATEMOTION, Plater.db.profile.auto_toggle_stacking ["world"] and CVAR_ENABLED or CVAR_DISABLED)
			end
		end
	end
end

function Plater:PLAYER_UPDATE_RESTING()
	Plater.RefreshAutoToggle()
end

function Plater:ENCOUNTER_END()
	Plater.CurrentEncounterID = nil
	Plater.LatestEncounter = time()
end

function Plater:ENCOUNTER_START (encounterID)
	Plater.CurrentEncounterID = encounterID
	
	local _, zoneType = GetInstanceInfo()
	if (zoneType == "raid") then
		table.wipe (DB_CAPTURED_SPELLS)
	end
end

function Plater:CHALLENGE_MODE_START()
	table.wipe (DB_CAPTURED_SPELLS)
end

function Plater:ZONE_CHANGED_NEW_AREA()
	if (InCombatLockdown()) then
		C_Timer.After (1, wait_for_leave_combat)
		return
	end
	
	Plater.CurrentEncounterID = nil
	
	local pvpType, isFFA, faction = GetZonePVPInfo()
	Plater.ZonePvpType = pvpType
	
	local name, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceMapID, instanceGroupSize = GetInstanceInfo()
	
	--reset when entering in a battleground
	if (instanceType == "pvp") then
		table.wipe (DB_CAPTURED_SPELLS)
	end
	Plater.ZoneInstanceType = instanceType
	
	IS_IN_OPEN_WORLD = Plater.ZoneInstanceType == "none"
	
	Plater.UpdateAllPlates()
	Plater.RefreshAutoToggle()
end

function Plater:ZONE_CHANGED_INDOORS()
	return Plater:ZONE_CHANGED_NEW_AREA()
end

function Plater:ZONE_CHANGED()
	return Plater:ZONE_CHANGED_NEW_AREA()
end

local delayed_guildname_check = function()
	Plater.PlayerGuildName = GetGuildInfo ("player")
	if (not Plater.PlayerGuildName or Plater.PlayerGuildName == "") then
		Plater.PlayerGuildName = "ThePlayerHasNoGuildName/30Char"
	end
	
	--print ("delayind guild check:", Plater.PlayerGuildName)
end

function Plater:PLAYER_ENTERING_WORLD()
	C_Timer.After (1, Plater.ZONE_CHANGED_NEW_AREA)
	C_Timer.After (1, Plater.FRIENDLIST_UPDATE)
	Plater.PlayerGuildName = GetGuildInfo ("player")
	if (not Plater.PlayerGuildName or Plater.PlayerGuildName == "") then
		Plater.PlayerGuildName = "ThePlayerHasNoGuildName/30Char"
		
		--somethimes guild information isn't available at the login
		C_Timer.After (10, delayed_guildname_check)
	end
	
	local pvpType, isFFA, faction = GetZonePVPInfo()
	Plater.ZonePvpType = pvpType
	
	local name, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceMapID, instanceGroupSize = GetInstanceInfo()
	Plater.ZoneInstanceType = instanceType
	
end
Plater:RegisterEvent ("PLAYER_ENTERING_WORLD")

function Plater.OnPlayerTargetChanged()
	for index, plateFrame in ipairs (Plater.GetAllShownPlates()) do
		Plater.UpdateTarget (plateFrame)
	end
end

-- ~target
function Plater.UpdateTarget (plateFrame)

	if (UnitIsUnit (plateFrame [MEMBER_UNITID], "focus") and Plater.db.profile.focus_indicator_enabled) then
		--this is a rare call, no need to cache these values
		local texture = LibSharedMedia:Fetch ("statusbar", Plater.db.profile.focus_texture)
		plateFrame.FocusIndicator:SetTexture (texture)
		plateFrame.FocusIndicator:SetVertexColor (unpack (Plater.db.profile.focus_color))
		plateFrame.FocusIndicator:Show()
	else
		plateFrame.FocusIndicator:Hide()
	end

	if (UnitIsUnit (plateFrame [MEMBER_UNITID], "target") and Plater.db.profile.target_highlight) then
	
		if (plateFrame.actorType ~= ACTORTYPE_FRIENDLY_PLAYER and plateFrame.actorType ~= ACTORTYPE_FRIENDLY_NPC and not plateFrame.PlayerCannotAttack) then
			plateFrame.TargetNeonUp:Show()
			plateFrame.TargetNeonDown:Show()
		else
			plateFrame.TargetNeonUp:Hide()
			plateFrame.TargetNeonDown:Hide()
		end

		plateFrame [MEMBER_TARGET] = true
		Plater.UpdateTargetPoints (plateFrame) --neon
		Plater.UpdateTargetIndicator (plateFrame) --border
		--hide obscured texture
		plateFrame.Obscured:Hide()
	else
		plateFrame.TargetNeonUp:Hide()
		plateFrame.TargetNeonDown:Hide()
		plateFrame [MEMBER_TARGET] = nil
		
		if (plateFrame.UnitFrame.IsTarget or plateFrame.UnitFrame.TargetTextures2Sides [1]:IsShown() or plateFrame.UnitFrame.TargetTextures4Sides [1]:IsShown()) then
			for i = 1, 2 do
				plateFrame.UnitFrame.TargetTextures2Sides [i]:Hide()
			end
			for i = 1, 4 do
				plateFrame.UnitFrame.TargetTextures4Sides [i]:Hide()
			end
			
			plateFrame.UnitFrame.IsTarget = false
		end
		
		if (DB_TARGET_SHADY_ENABLED and (not DB_TARGET_SHADY_COMBATONLY or PLAYER_IN_COMBAT)) then
			plateFrame.Obscured:Show()
			plateFrame.Obscured:SetAlpha (DB_TARGET_SHADY_ALPHA)
		else
			plateFrame.Obscured:Hide()
		end
	end
	
	Plater.CheckRange (plateFrame, true)
end

function Plater.UpdateTargetPoints (plateFrame)
	local healthBar = plateFrame.UnitFrame.healthBar
	local width = healthBar:GetWidth()
	local x = width/14
	local alpha = Plater.db.profile.target_highlight_alpha
	plateFrame.TargetNeonUp:SetAlpha (alpha)
	plateFrame.TargetNeonUp:SetPoint ("topleft", healthBar, "bottomleft", -x, 0)
	plateFrame.TargetNeonUp:SetPoint ("topright", healthBar, "bottomright", x, 0)
	plateFrame.TargetNeonDown:SetAlpha (alpha)
	plateFrame.TargetNeonDown:SetPoint ("bottomleft", healthBar, "topleft", -x, 0)
	plateFrame.TargetNeonDown:SetPoint ("bottomright", healthBar, "topright", x, 0)
end

function Plater.UpdateTargetIndicator (plateFrame)

	local healthBarHeight = plateFrame.UnitFrame.healthBar:GetHeight()
	
	--if the height is lower than 4, just hide all indicators
	if (healthBarHeight < 4) then
		for i = 1, 2 do
			plateFrame.UnitFrame.TargetTextures2Sides [i]:Hide()
		end
		for i = 1, 4 do
			plateFrame.UnitFrame.TargetTextures4Sides [i]:Hide()
		end
		
		return
	end

	local preset = TargetIndicators [Plater.db.profile.target_indicator]
	
	local width, height = preset.width, preset.height
	local x, y = preset.x, preset.y
	local desaturated = preset.desaturated
	local coords = preset.coords
	local path = preset.path
	local blend = preset.blend or "BLEND"
	local alpha = preset.alpha or 1
	local overlayColorR, overlayColorG, overlayColorB = DF:ParseColors (preset.color or "white")
	
	local scale = healthBarHeight / 10
	
	--four parts (textures)
	if (#coords == 4) then
		for i = 1, 4 do
			local texture = plateFrame.UnitFrame.TargetTextures4Sides [i]
			texture:Show()
			texture:SetTexture (path)
			texture:SetTexCoord (unpack (coords [i]))
			texture:SetSize (width * scale, height * scale)
			texture:SetAlpha (alpha)
			texture:SetVertexColor (overlayColorR, overlayColorG, overlayColorB)
			texture:SetDesaturated (desaturated)
			
			if (i == 1) then
				texture:SetPoint ("topleft", plateFrame.UnitFrame.healthBar, "topleft", -x, y)
				
			elseif (i == 2) then
				texture:SetPoint ("bottomleft", plateFrame.UnitFrame.healthBar, "bottomleft", -x, -y)
				
			elseif (i == 3) then
				texture:SetPoint ("bottomright", plateFrame.UnitFrame.healthBar, "bottomright", x, -y)
				
			elseif (i == 4) then
				texture:SetPoint ("topright", plateFrame.UnitFrame.healthBar, "topright", x, y)
				
			end
		end
		
		for i = 1, 2 do
			plateFrame.UnitFrame.TargetTextures2Sides [i]:Hide()
		end
	else
		for i = 1, 2 do
			local texture = plateFrame.UnitFrame.TargetTextures2Sides [i]
			texture:Show()
			texture:SetTexture (path)
			texture:SetBlendMode (blend)
			texture:SetTexCoord (unpack (coords [i]))
			texture:SetSize (width * scale, height * scale)
			texture:SetDesaturated (desaturated)
			texture:SetAlpha (alpha)
			texture:SetVertexColor (overlayColorR, overlayColorG, overlayColorB)
			
			if (i == 1) then
				texture:SetPoint ("left", plateFrame.UnitFrame.healthBar, "left", -x, y)
				
			elseif (i == 2) then
				texture:SetPoint ("right", plateFrame.UnitFrame.healthBar, "right", x, -y)
			end
		end
		for i = 1, 4 do
			plateFrame.UnitFrame.TargetTextures4Sides [i]:Hide()
		end
	end
	
	plateFrame.UnitFrame.IsTarget = true
end

function Plater.CreateHealthFlashFrame (plateFrame)
	local f_anim = CreateFrame ("frame", nil, plateFrame.UnitFrame.healthBar)
	f_anim:SetFrameLevel (plateFrame.UnitFrame.healthBar:GetFrameLevel()-1)
	f_anim:SetPoint ("topleft", plateFrame.UnitFrame.healthBar, "topleft", -2, 2)
	f_anim:SetPoint ("bottomright", plateFrame.UnitFrame.healthBar, "bottomright", 2, -2)
	plateFrame.UnitFrame.healthBar.canHealthFlash = true
	
	local t = f_anim:CreateTexture (nil, "artwork")
	t:SetColorTexture (1, 1, 1, 1)
	t:SetAllPoints()
	t:SetBlendMode ("ADD")
	
	local animation = t:CreateAnimationGroup()
	local anim1 = animation:CreateAnimation ("Alpha")
	local anim2 = animation:CreateAnimation ("Alpha")
	local anim3 = animation:CreateAnimation ("Alpha")
	anim1:SetOrder (1)
	anim1:SetFromAlpha (0)
	anim1:SetToAlpha (1)
	anim1:SetDuration (0.1)
	anim2:SetOrder (2)
	anim2:SetFromAlpha (1)
	anim2:SetToAlpha (0)
	anim2:SetDuration (0.1)
	anim3:SetOrder (3)
	anim3:SetFromAlpha (0)
	anim3:SetToAlpha (1)
	anim3:SetDuration (0.1)

	animation:SetScript ("OnFinished", function (self)
		f_anim:Hide()
	end)
	animation:SetScript ("OnPlay", function (self)
		f_anim:Show()
	end)

	local do_flash_anim = function (duration)
		if (not plateFrame.UnitFrame.healthBar.canHealthFlash) then
			return
		end
		plateFrame.UnitFrame.healthBar.canHealthFlash = false
		
		duration = duration or 0.1
		
		anim1:SetDuration (duration)
		anim2:SetDuration (duration)
		anim3:SetDuration (duration)
		
		f_anim:Show()
		animation:Play()
	end
	
	f_anim:Hide()
	plateFrame.UnitFrame.healthBar.PlayHealthFlash = do_flash_anim
end

function Plater.CreateAggroFlashFrame (plateFrame)

	--local f_anim = CreateFrame ("frame", nil, plateFrame.UnitFrame.healthBar)
	local f_anim = CreateFrame ("frame", nil, plateFrame)
	f_anim:SetFrameLevel (plateFrame.UnitFrame.healthBar:GetFrameLevel()+3)
	f_anim:SetPoint ("topleft", plateFrame.UnitFrame.healthBar, "topleft")
	f_anim:SetPoint ("bottomright", plateFrame.UnitFrame.healthBar, "bottomright")
	
	local t = f_anim:CreateTexture (nil, "artwork")
	--t:SetTexCoord (0, 0.78125, 0, 0.66796875)
	--t:SetTexture ([[Interface\AchievementFrame\UI-Achievement-Alert-Glow]])
	t:SetColorTexture (1, 1, 1, 1)
	t:SetAllPoints()
	t:SetBlendMode ("ADD")
	local s = f_anim:CreateFontString (nil, "overlay", "GameFontNormal")
	s:SetText ("-AGGRO-")
	s:SetTextColor (.70, .70, .70)
	s:SetPoint ("center", t, "center")
	
	local animation = t:CreateAnimationGroup()
	local anim1 = animation:CreateAnimation ("Alpha")
	local anim2 = animation:CreateAnimation ("Alpha")
	anim1:SetOrder (1)
	anim1:SetFromAlpha (0)
	anim1:SetToAlpha (1)
	anim1:SetDuration (0.2)
	anim2:SetOrder (2)
	anim2:SetFromAlpha (1)
	anim2:SetToAlpha (0)
	anim2:SetDuration (0.2)
	
	animation:SetScript ("OnFinished", function (self)
		f_anim:Hide()
	end)
	animation:SetScript ("OnPlay", function (self)
		f_anim:Show()
	end)

	local do_flash_anim = function (text, duration)
		if (Plater.CombatTime+5 > GetTime()) then
			return
		end
		
		text = text or ""
		duration = duration or 0.2
		
		anim1:SetDuration (duration)
		anim2:SetDuration (duration)
		
		s:SetText (text)
		f_anim:Show()
		animation:Play()
	end
	
	f_anim:Hide()
	plateFrame.PlayBodyFlash = do_flash_anim
end

function Plater.CanChangePlateSize()
	return not InCombatLockdown()
end

local default_level_color = {r = 1.0, g = 0.82, b = 0.0}
local get_level_color = function (unitId, unitLevel)
	if (UnitCanAttack ("player", unitId)) then
		local playerLevel = UnitLevel ("player")
		local color = GetRelativeDifficultyColor (playerLevel, unitLevel)
		return color
	end
	return default_level_color
end

function Plater.UpdateLevelTextAndColor (plateFrame, unitId)
	local level = UnitLevel (unitId)
	if (not level) then
		plateFrame:SetText ("")
	elseif (level == -1) then
		plateFrame:SetText ("??")
	else
		plateFrame:SetText (level)
	end
	
	local color = get_level_color (unitId, level)
	plateFrame:SetTextColor (color.r, color.g, color.b)
end

local anchor_functions = {
	function (widget, config)--1
		widget:ClearAllPoints()
		widget:SetPoint ("bottomleft", widget:GetParent(), "topleft", config.x, config.y)
	end,
	function (widget, config)--2
		widget:ClearAllPoints()
		widget:SetPoint ("right", widget:GetParent(), "left", config.x, config.y)
	end,
	function (widget, config)--3
		widget:ClearAllPoints()
		widget:SetPoint ("topleft", widget:GetParent(), "bottomleft", config.x, config.y)
	end,
	function (widget, config)--4
		widget:ClearAllPoints()
		widget:SetPoint ("top", widget:GetParent(), "bottom", config.x, config.y)
	end,
	function (widget, config)--5
		widget:ClearAllPoints()
		widget:SetPoint ("topright", widget:GetParent(), "bottomright", config.x, config.y)
	end,
	function (widget, config)--6
		widget:ClearAllPoints()
		widget:SetPoint ("left", widget:GetParent(), "right", config.x, config.y)
	end,
	function (widget, config)--7
		widget:ClearAllPoints()
		widget:SetPoint ("bottomright", widget:GetParent(), "topright", config.x, config.y)
	end,
	function (widget, config)--8
		widget:ClearAllPoints()
		widget:SetPoint ("bottom", widget:GetParent(), "top", config.x, config.y)
	end,
	function (widget, config)--9
		widget:ClearAllPoints()
		widget:SetPoint ("center", widget:GetParent(), "center", config.x, config.y)
	end,
	function (widget, config)--10
		widget:ClearAllPoints()
		widget:SetPoint ("left", widget:GetParent(), "left", config.x, config.y)
	end,
	function (widget, config)--11
		widget:ClearAllPoints()
		widget:SetPoint ("right", widget:GetParent(), "right", config.x, config.y)
	end,
	function (widget, config)--12
		widget:ClearAllPoints()
		widget:SetPoint ("top", widget:GetParent(), "top", config.x, config.y)
	end,
	function (widget, config)--13
		widget:ClearAllPoints()
		widget:SetPoint ("bottom", widget:GetParent(), "bottom", config.x, config.y)
	end
}

function Plater.SetAnchor (widget, config)
	anchor_functions [config.side] (widget, config)
end

--PlaterScanTooltip:SetOwner (WorldFrame, "ANCHOR_NONE")
local GameTooltipFrame = CreateFrame ("GameTooltip", "PlaterScanTooltip", nil, "GameTooltipTemplate")
local GameTooltipFrameTextLeft2 = _G ["PlaterScanTooltipTextLeft2"]
function Plater.GetActorSubName (plateFrame)
	GameTooltipFrame:SetOwner (WorldFrame, "ANCHOR_NONE")
	GameTooltipFrame:SetHyperlink ("unit:" .. (plateFrame [MEMBER_GUID] or ''))
	return GameTooltipFrameTextLeft2:GetText()
end

local GameTooltipScanQuest = CreateFrame ("GameTooltip", "PlaterScanQuestTooltip", nil, "GameTooltipTemplate")
local ScanQuestTextCache = {}
for i = 1, 8 do
	ScanQuestTextCache [i] = _G ["PlaterScanQuestTooltipTextLeft" .. i]
end

function Plater.IsQuestObjective (plateFrame)
	if (not plateFrame [MEMBER_GUID]) then
		return
	end
	GameTooltipScanQuest:SetOwner (WorldFrame, "ANCHOR_NONE")
	GameTooltipScanQuest:SetHyperlink ("unit:" .. plateFrame [MEMBER_GUID])
	
	for i = 1, 8 do
		local text = ScanQuestTextCache [i]:GetText()
		if (Plater.QuestCache [text]) then
			--este npc percente a uma quest
			if (not IsInGroup() and i < 8) then
				--verifica se jï¿½ fechou a quantidade necessï¿½ria pra esse npc
				local nextLineText = ScanQuestTextCache [i+1]:GetText()
				if (nextLineText) then
					local p1, p2 = nextLineText:match ("(%d%d)/(%d%d)") --^ - 
					if (not p1) then
						p1, p2 = nextLineText:match ("(%d)/(%d%d)")
						if (not p1) then
							p1, p2 = nextLineText:match ("(%d)/(%d)")
						end
					end
					if (p1 and p2 and p1 == p2) then
						return
					end
				end
			end

			plateFrame [MEMBER_QUEST] = true
			return true
		end
	end
end

local update_quest_cache = function()

	--clear the quest cache
	wipe (Plater.QuestCache)

	--do not update if is inside an instance
	local isInInstance = IsInInstance()
	if (isInInstance) then
		return
	end
	
	--update the quest cache
	local numEntries, numQuests = GetNumQuestLogEntries()
	for questId = 1, numEntries do
		local title, level, suggestedGroup, isHeader, isCollapsed, isComplete, frequency, questId, startEvent, displayQuestID, isOnMap, hasLocalPOI, isTask, isStory = GetQuestLogTitle (questId)
		if (type (questId) == "number" and questId > 0) then -- and not isComplete
			Plater.QuestCache [title] = true
		end
	end
	
	local mapId = C_Map.GetBestMapForUnit ("player")
	if (mapId) then
		local worldQuests = C_TaskQuest.GetQuestsForPlayerByMapID (mapId)
		if (type (worldQuests) == "table") then
			for i, questTable in ipairs (worldQuests) do
				local x, y, floor, numObjectives, questId, inProgress = questTable.x, questTable.y, questTable.floor, questTable.numObjectives, questTable.questId, questTable.inProgress
				if (type (questId) == "number" and questId > 0) then
					local questName = C_TaskQuest.GetQuestInfoByQuestID (questId)
					if (questName) then
						Plater.QuestCache [questName] = true
					end
				end
			end
		end
	end
	
	Plater.UpdateAllPlates()
end

function Plater.QuestLogUpdated()
	if (Plater.UpdateQuestCacheThrottle and not Plater.UpdateQuestCacheThrottle._cancelled) then
		Plater.UpdateQuestCacheThrottle:Cancel()
	end
	Plater.UpdateQuestCacheThrottle = C_Timer.NewTimer (2, update_quest_cache)
end

-- ~updatetext - called only from UpdatePlateFrame()
-- update all texts in the nameplate, settings can variate from different unit types
-- needReset is true when the previous unit type shown on this place is different from the current unit
function Plater.UpdatePlateText (plateFrame, plateConfigs, needReset)
	
	if (plateFrame.isSelf) then
		--name isn't shown in the personal bar
		plateFrame.UnitFrame.healthBar.actorName:SetText ("")
		
		--update the power percent text
		if (plateConfigs.power_percent_text_enabled and needReset) then
			local powerString = ClassNameplateManaBarFrame.powerPercent
			DF:SetFontSize (powerString, plateConfigs.power_percent_text_size)
			DF:SetFontFace (powerString, plateConfigs.power_percent_text_font)
			DF:SetFontOutline (powerString, plateConfigs.power_percent_text_shadow)
			DF:SetFontColor (powerString, plateConfigs.power_percent_text_color)
			Plater.SetAnchor (powerString, plateConfigs.power_percent_text_anchor)
			powerString:SetAlpha (plateConfigs.power_percent_text_alpha)
			powerString:Show()
		else
			ClassNameplateManaBarFrame.powerPercent:Hide()
		end
		
		return
		
	elseif (plateFrame.IsFriendlyPlayerWithoutHealthBar) then --not critical code
		--when the option to show only the player name is enabled
		--special string to show the player name
		local nameFontString = plateFrame.ActorNameSpecial
		nameFontString:Show()
		
		--set the name in the string
		plateFrame.CurrentUnitNameString = nameFontString
		Plater.UpdateUnitName (plateFrame, nameFontString)
		
		DF:SetFontSize (nameFontString, plateConfigs.actorname_text_size)
		DF:SetFontFace (nameFontString, plateConfigs.actorname_text_font)
		DF:SetFontOutline (nameFontString, plateConfigs.actorname_text_shadow)
		
		--check if the player has a guild, this check is done when the nameplate is added
		if (plateFrame.playerGuildName) then
			if (plateConfigs.show_guild_name) then
				Plater.AddGuildNameToPlayerName (plateFrame)
			end
		end
		
		--set the point of the name and guild texts
		nameFontString:ClearAllPoints()
		plateFrame.ActorNameSpecial:SetPoint ("center", plateFrame, "center", 0, 10)
		
		--format the color if is the same guild, a friend from friends list or color by player class
		if (plateFrame.playerGuildName == Plater.PlayerGuildName) then
			--is a guild friend?
			DF:SetFontColor (nameFontString, "PLATER_GUILD")
			plateFrame.isFriend = true
			
		elseif (Plater.FriendsCache [plateFrame [MEMBER_NAME]]) then
			--is regular friend
			DF:SetFontColor (nameFontString, "PLATER_FRIEND")
			DF:SetFontOutline (nameFontString, plateConfigs.actorname_text_shadow)
			plateFrame.isFriend = true
			
		else
			--isn't friend, check if is showing only the name and if is showing class colors
			if (Plater.db.profile.use_playerclass_color) then
				local _, unitClass = UnitClass (plateFrame [MEMBER_UNITID])
				if (unitClass) then
					local color = RAID_CLASS_COLORS [unitClass]
					DF:SetFontColor (nameFontString, color.r, color.g, color.b)
				else
					DF:SetFontColor (nameFontString, plateConfigs.actorname_text_color)
				end
			else
				DF:SetFontColor (nameFontString, plateConfigs.actorname_text_color)
			end

			plateFrame.isFriend = nil
		end
		
		return
	
	elseif (plateFrame.IsNpcWithoutHealthBar) then --not critical code
	
		--reset points for special units
		plateFrame.ActorNameSpecial:ClearAllPoints()
		plateFrame.ActorTitleSpecial:ClearAllPoints()
		plateFrame.ActorNameSpecial:SetPoint ("center", plateFrame, "center", 0, 10)
		plateFrame.ActorTitleSpecial:SetPoint ("top", plateFrame.ActorNameSpecial, "bottom", 0, -2)
	
		--there's two ways of showing this for friendly npcs (selected from the options panel): show all names or only npcs with profession names
		--enemy npcs always show all
		if (plateConfigs.all_names) then
			plateFrame.ActorNameSpecial:Show()
			plateFrame.CurrentUnitNameString = plateFrame.ActorNameSpecial
			Plater.UpdateUnitName (plateFrame, plateFrame.ActorNameSpecial)
			
			--if this is an enemy or neutral npc
			if (plateFrame [MEMBER_REACTION] <= 4) then
			
				local r, g, b, a
				
				--get the quest color if this npcs is a quest npc
				if (plateFrame [MEMBER_QUEST]) then
					if (plateFrame [MEMBER_REACTION] == UNITREACTION_NEUTRAL) then
						r, g, b, a = unpack (plateConfigs.quest_color_neutral)
					else
						r, g, b, a = unpack (plateConfigs.quest_color_enemy)
						g = g + 0.1
						b = b + 0.1
					end
				else
					r, g, b, a = 1, 1, 0, 1 --neutral
					if (plateFrame [MEMBER_REACTION] <= 3) then
						r, g, b, a = 1, .05, .05, 1
					end
				end
				
				plateFrame.ActorNameSpecial:SetTextColor (r, g, b, a)
				DF:SetFontSize (plateFrame.ActorNameSpecial, plateConfigs.big_actorname_text_size)
				DF:SetFontFace (plateFrame.ActorNameSpecial, plateConfigs.big_actorname_text_font)
				DF:SetFontOutline (plateFrame.ActorNameSpecial, plateConfigs.big_actorname_text_shadow)
				
				--npc title
				local subTitle = Plater.GetActorSubName (plateFrame)
				if (subTitle and subTitle ~= "" and not subTitle:match ("%d")) then
					plateFrame.ActorTitleSpecial:Show()
					subTitle = DF:RemoveRealmName (subTitle)
					plateFrame.ActorTitleSpecial:SetText ("<" .. subTitle .. ">")
					plateFrame.ActorTitleSpecial:ClearAllPoints()
					plateFrame.ActorTitleSpecial:SetPoint ("top", plateFrame.ActorNameSpecial, "bottom", 0, -2)
					
					plateFrame.ActorTitleSpecial:SetTextColor (r, g, b, a)
					DF:SetFontSize (plateFrame.ActorTitleSpecial, plateConfigs.big_actortitle_text_size)
					DF:SetFontFace (plateFrame.ActorTitleSpecial, plateConfigs.big_actortitle_text_font)
					DF:SetFontOutline (plateFrame.ActorTitleSpecial, plateConfigs.big_actortitle_text_shadow)
				else
					plateFrame.ActorTitleSpecial:Hide()
				end
				
			else
				--it's a friendly npc
				plateFrame.ActorNameSpecial:SetTextColor (unpack (plateConfigs.big_actorname_text_color))
				DF:SetFontSize (plateFrame.ActorNameSpecial, plateConfigs.big_actorname_text_size)
				DF:SetFontFace (plateFrame.ActorNameSpecial, plateConfigs.big_actorname_text_font)
				DF:SetFontOutline (plateFrame.ActorNameSpecial, plateConfigs.big_actorname_text_shadow)
				
				--profession (title)
				local subTitle = Plater.GetActorSubName (plateFrame)
				if (subTitle and subTitle ~= "" and not subTitle:match ("%d")) then
					plateFrame.ActorTitleSpecial:Show()
					subTitle = DF:RemoveRealmName (subTitle)
					plateFrame.ActorTitleSpecial:SetText ("<" .. subTitle .. ">")
					plateFrame.ActorTitleSpecial:ClearAllPoints()
					plateFrame.ActorTitleSpecial:SetPoint ("top", plateFrame.ActorNameSpecial, "bottom", 0, -2)
					
					plateFrame.ActorTitleSpecial:SetTextColor (unpack (plateConfigs.big_actortitle_text_color))
					DF:SetFontSize (plateFrame.ActorTitleSpecial, plateConfigs.big_actortitle_text_size)
					DF:SetFontFace (plateFrame.ActorTitleSpecial, plateConfigs.big_actortitle_text_font)
					DF:SetFontOutline (plateFrame.ActorTitleSpecial, plateConfigs.big_actortitle_text_shadow)
				end
			end
		else
			--scan tooltip to check if there's an title for this npc
			local subTitle = Plater.GetActorSubName (plateFrame)
			if (subTitle and subTitle ~= "" and not Plater.IsIgnored (plateFrame, true)) then
				if (not subTitle:match ("%d")) then --isn't level

					plateFrame.ActorTitleSpecial:Show()
					subTitle = DF:RemoveRealmName (subTitle)
					plateFrame.ActorTitleSpecial:SetText ("<" .. subTitle .. ">")
					plateFrame.ActorTitleSpecial:ClearAllPoints()
					plateFrame.ActorTitleSpecial:SetPoint ("top", plateFrame.ActorNameSpecial, "bottom", 0, -2)
					
					plateFrame.ActorTitleSpecial:SetTextColor (unpack (plateConfigs.big_actortitle_text_color))
					plateFrame.ActorNameSpecial:SetTextColor (unpack (plateConfigs.big_actorname_text_color))
					
					DF:SetFontSize (plateFrame.ActorTitleSpecial, plateConfigs.big_actortitle_text_size)
					DF:SetFontFace (plateFrame.ActorTitleSpecial, plateConfigs.big_actortitle_text_font)
					DF:SetFontOutline (plateFrame.ActorTitleSpecial, plateConfigs.big_actortitle_text_shadow)
					
					--npc name
					plateFrame.ActorNameSpecial:Show()

					plateFrame.CurrentUnitNameString = plateFrame.ActorNameSpecial
					Plater.UpdateUnitName (plateFrame, plateFrame.ActorNameSpecial)

					DF:SetFontSize (plateFrame.ActorNameSpecial, plateConfigs.big_actorname_text_size)
					DF:SetFontFace (plateFrame.ActorNameSpecial, plateConfigs.big_actorname_text_font)
					DF:SetFontOutline (plateFrame.ActorNameSpecial, plateConfigs.big_actorname_text_shadow)
				end
			end
		end
		
		return
	end
	
	--critical code
	--the nameplate is showing the health bar
	--cache the strings for performance
	local spellnameString = plateFrame.UnitFrame.castBar.Text
	local spellPercentString = plateFrame.UnitFrame.castBar.percentText
	local nameString = plateFrame.UnitFrame.healthBar.actorName	
	local guildString = plateFrame.ActorTitleSpecial
	local levelString = plateFrame.UnitFrame.healthBar.actorLevel
	local lifeString = plateFrame.UnitFrame.healthBar.lifePercent
	
	--update the unit name
	plateFrame.CurrentUnitNameString = nameString
	Plater.UpdateUnitName (plateFrame)
	
	--update the unit name text settings if required
	if (needReset) then
		DF:SetFontSize (nameString, plateConfigs.actorname_text_size)
		DF:SetFontFace (nameString, plateConfigs.actorname_text_font)
		DF:SetFontOutline (nameString, plateConfigs.actorname_text_shadow)
	end
	Plater.SetAnchor (nameString, plateConfigs.actorname_text_anchor)
	
	if (plateFrame.playerGuildName) then
		if (plateConfigs.show_guild_name) then
			Plater.AddGuildNameToPlayerName (plateFrame)
		end
	end
	
	if (plateFrame.playerGuildName == Plater.PlayerGuildName) then
		--is a guild friend?
		DF:SetFontColor (nameString, "PLATER_GUILD")
		DF:SetFontColor (guildString, "PLATER_GUILD")
		plateFrame.isFriend = true
	
	elseif (Plater.FriendsCache [plateFrame [MEMBER_NAME]]) then
		--is regular friend
		DF:SetFontColor (textString, "PLATER_FRIEND")
		DF:SetFontColor (guildString, "PLATER_FRIEND")
		plateFrame.isFriend = true		

	else
		DF:SetFontColor (nameString, plateConfigs.actorname_text_color)
		plateFrame.isFriend = nil
	end

	--atualiza o texto da cast bar
	if (needReset) then
		DF:SetFontColor (spellnameString, plateConfigs.spellname_text_color)
		DF:SetFontSize (spellnameString, plateConfigs.spellname_text_size)
		DF:SetFontOutline (spellnameString, plateConfigs.spellname_text_shadow)
		DF:SetFontFace (spellnameString, plateConfigs.spellname_text_font)
	end
	
	--atualiza o texto da porcentagem do cast
	if (plateConfigs.spellpercent_text_enabled) then
		spellPercentString:Show()
		if (needReset) then
			DF:SetFontColor (spellPercentString, plateConfigs.spellpercent_text_color)
			DF:SetFontSize (spellPercentString, plateConfigs.spellpercent_text_size)
			DF:SetFontOutline (spellPercentString, plateConfigs.spellpercent_text_shadow)
			DF:SetFontFace (spellPercentString, plateConfigs.spellpercent_text_font)
			Plater.SetAnchor (spellPercentString, plateConfigs.spellpercent_text_anchor)
		end
	else
		spellPercentString:Hide()
	end

	Plater.SetAnchor (spellnameString, plateConfigs.spellname_text_anchor)
	
	--atualiza o texto do level ??
	if (plateConfigs.level_text_enabled) then
		levelString:Show()
		if (needReset) then
			DF:SetFontSize (levelString, plateConfigs.level_text_size)
			DF:SetFontFace (levelString, plateConfigs.level_text_font)
			DF:SetFontOutline (levelString, plateConfigs.level_text_shadow)
			Plater.SetAnchor (levelString, plateConfigs.level_text_anchor)
			Plater.UpdateLevelTextAndColor (levelString, plateFrame.namePlateUnitToken)
			levelString:SetAlpha (plateConfigs.level_text_alpha)
		end
	else
		levelString:Hide()
	end

	--atualiza o texto da porcentagem da vida
	if (plateConfigs.percent_text_enabled) then
		lifeString:Show()
		
		--apenas mostrar durante o combate
		if (PLAYER_IN_COMBAT or plateConfigs.percent_text_ooc) then
			lifeString:Show()
		else
			lifeString:Hide()
		end
		
		if (needReset) then
			DF:SetFontSize (lifeString, plateConfigs.percent_text_size)
			DF:SetFontFace (lifeString, plateConfigs.percent_text_font)
			DF:SetFontOutline (lifeString, plateConfigs.percent_text_shadow)
			DF:SetFontColor (lifeString, plateConfigs.percent_text_color)
			Plater.SetAnchor (lifeString, plateConfigs.percent_text_anchor)
			lifeString:SetAlpha (plateConfigs.percent_text_alpha)
		end
		
		Plater.UpdateLifePercentText (plateFrame.UnitFrame.healthBar, plateFrame.namePlateUnitToken, plateConfigs.percent_show_health, plateConfigs.percent_text_show_decimals)
	else
		lifeString:Hide()
	end
end

function Plater.UpdateLifePercentText (healthBar, unitId, showHealthAmount, showDecimals)
	--get the cached health amount
	local currentHealth, maxHealth = healthBar.CurrentHealth, healthBar.CurrentHealthMax
	local percentText = ""
	local percent = currentHealth / maxHealth * 100
	
	if (showDecimals) then
		if (percent < 10) then
			percentText = format ("%.2f", percent)
		elseif (percent < 99.9) then
			percentText = format ("%.1f", percent)
		else
			percentText = floor (percent)
		end
	else
		percentText = floor (percent)
	end
	
	if (showHealthAmount) then
		local healthAmount = DF.FormatNumber (currentHealth)
		healthBar.lifePercent:SetText (healthAmount .. " (" .. percentText .. "%)")
	else
		healthBar.lifePercent:SetText (percentText .. "%")
	end
end

-- ~raidmarker ~raidtarget 
function Plater.UpdatePlateRaidMarker (plateFrame)
	if (plateFrame.UnitFrame.RaidTargetFrame.RaidTargetIcon:IsShown()) then
		if (not plateFrame.UnitFrame.RaidTargetFrame.RaidTargetIcon.IsShowning) then
			--play animations
			plateFrame.UnitFrame.RaidTargetFrame.RaidTargetIcon.IsShowning = true
			plateFrame.UnitFrame.RaidTargetFrame.RaidTargetIcon.ShowAnimation:Play()
		end
		
		--adjust scale and anchor
		plateFrame.UnitFrame.RaidTargetFrame:SetScale (Plater.db.profile.indicator_raidmark_scale)
		Plater.SetAnchor (plateFrame.UnitFrame.RaidTargetFrame, Plater.db.profile.indicator_raidmark_anchor)
		
		--mini mark inside the nameplate
		if (Plater.db.profile.indicator_extra_raidmark) then
			plateFrame.RaidTarget:Show()
			plateFrame.RaidTarget:SetTexture (plateFrame.UnitFrame.RaidTargetFrame.RaidTargetIcon:GetTexture())
			plateFrame.RaidTarget:SetTexCoord (plateFrame.UnitFrame.RaidTargetFrame.RaidTargetIcon:GetTexCoord())
			local height = plateFrame.UnitFrame.healthBar:GetHeight() - 2
			plateFrame.RaidTarget:SetSize (height, height)
			plateFrame.RaidTarget:SetAlpha (.4)
		end
	else
		plateFrame.UnitFrame.RaidTargetFrame.RaidTargetIcon.IsShowning = nil
		plateFrame.RaidTarget:Hide()
	end
end

--iterate among all nameplates and update the raid target icon
function Plater.UpdateRaidMarker()
	for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
		Plater.UpdatePlateRaidMarker (plateFrame)
	end
end

-- ~size
function Plater.UpdatePlateSize (plateFrame, justAdded)
	if (not plateFrame.actorType) then
		return
	end

	local actorType = plateFrame.actorType
	local order = plateFrame.order

	local plateConfigs = DB_PLATE_CONFIG [actorType]
	local plateWidth = plateFrame:GetWidth()

	local unitFrame = plateFrame.UnitFrame
	local healthFrame = unitFrame.healthBar
	local castFrame = unitFrame.castBar
	local buffFrame = unitFrame.BuffFrame
	local nameFrame = unitFrame.healthBar.actorName
	
	local unitType = Plater.GetUnitType (plateFrame)
	local isInCombat = PLAYER_IN_COMBAT

	--sempre usar barras grandes quando estiver em pvp
	if (plateFrame.actorType == ACTORTYPE_ENEMY_PLAYER) then
		if ((Plater.ZoneInstanceType == "pvp" or Plater.ZoneInstanceType == "arena") and DB_PLATE_CONFIG.player.pvp_always_incombat) then
			isInCombat = true
		end
	end
	
	if (order == 1) then
		--debuff, health, castbar
		
		local castKey, heathKey, textKey = Plater.GetHashKey (isInCombat)
		local SizeOf_healthBar_Width = plateConfigs [heathKey][1]
		local SizeOf_castBar_Width = plateConfigs [castKey][1]
		local SizeOf_healthBar_Height = plateConfigs [heathKey][2]
		local SizeOf_castBar_Height = plateConfigs [castKey][2]
		local SizeOf_text = plateConfigs [textKey]
		
		local height_offset = 0
		
		--pegar o tamanho da barra de debuff para colocar a cast bar em cima dela
		local buffFrameSize = Plater.db.profile.aura_height
		
		local scalarValue = SizeOf_castBar_Width > plateWidth and -((SizeOf_castBar_Width - plateWidth) / 2) or ((plateWidth - SizeOf_castBar_Width) / 2)
		if (unitType == "pet") then
			scalarValue = scalarValue + (SizeOf_castBar_Width/5)
		elseif (unitType == "minus") then
			scalarValue = scalarValue + (SizeOf_castBar_Width/5)
		end
		
		castFrame:SetPoint ("BOTTOMLEFT", unitFrame, "BOTTOMLEFT", scalarValue, buffFrameSize + SizeOf_healthBar_Height + 2 + height_offset);
		castFrame:SetPoint ("BOTTOMRIGHT", unitFrame, "BOTTOMRIGHT", -scalarValue, buffFrameSize + SizeOf_healthBar_Height + 2 + height_offset);
		castFrame:SetHeight (SizeOf_castBar_Height)
		castFrame.Icon:SetSize (SizeOf_castBar_Height, SizeOf_castBar_Height)
		castFrame.BorderShield:SetSize (SizeOf_castBar_Height*1.4, SizeOf_castBar_Height*1.4)
		
		local scalarValue
		if (Plater.ZonePvpType ~= "sanctuary") then
			scalarValue = SizeOf_healthBar_Width > SizeOf_castBar_Width and -((SizeOf_healthBar_Width - SizeOf_castBar_Width) / 2) or ((SizeOf_castBar_Width - SizeOf_healthBar_Width) / 2)
		else
			--scalarValue = 80 > SizeOf_castBar_Width and -((80 - SizeOf_castBar_Width) / 2) or ((SizeOf_castBar_Width - 80) / 2)
			scalarValue = SizeOf_healthBar_Width > SizeOf_castBar_Width and -((SizeOf_healthBar_Width - SizeOf_castBar_Width) / 2) or ((SizeOf_castBar_Width - SizeOf_healthBar_Width) / 2)
		end

		healthFrame:ClearAllPoints()
		healthFrame:SetPoint ("BOTTOMLEFT", castFrame, "TOPLEFT", scalarValue,  (-SizeOf_healthBar_Height) + (-SizeOf_castBar_Height) - 4);
		healthFrame:SetPoint ("BOTTOMRIGHT", castFrame, "TOPRIGHT", -scalarValue,  (-SizeOf_healthBar_Height) + (-SizeOf_castBar_Height) - 4);
		
		local targetHeight = SizeOf_healthBar_Height / (isMinus and 2 or 1)
		local currentHeight = healthFrame:GetHeight()
		
		if (justAdded or not Plater.db.profile.height_animation) then
			healthFrame:SetHeight (targetHeight)
		else
			if (currentHeight < targetHeight) then
				if (not healthFrame.IsIncreasingHeight) then
					healthFrame.IsDecreasingHeight = nil
					healthFrame.TargetHeight = targetHeight
					healthFrame.ToIncreace = targetHeight - currentHeight
					healthFrame.HAVE_HEIGHT_ANIMATION = "up"
				end
			elseif (currentHeight > targetHeight) then
				if (not healthFrame.IsDecreasingHeight) then
					healthFrame.IsIncreasingHeight = nil
					healthFrame.TargetHeight = targetHeight
					healthFrame.ToDecrease = currentHeight - targetHeight
					healthFrame.HAVE_HEIGHT_ANIMATION = "down"
				end
			end
		end
		
		buffFrame.Point1 = "top"
		buffFrame.Point2 = "bottom"
		buffFrame.Anchor = healthFrame
		buffFrame.X = DB_AURA_X_OFFSET
		buffFrame.Y = -11 + plateConfigs.buff_frame_y_offset + DB_AURA_Y_OFFSET
		
		buffFrame:ClearAllPoints()
		buffFrame:SetPoint (buffFrame.Point1, buffFrame.Anchor, buffFrame.Point2, buffFrame.X, buffFrame.Y)

		--> second aura frame
		if (DB_AURA_SEPARATE_BUFFS) then
			unitFrame.BuffFrame2.X = Plater.db.profile.aura2_x_offset
			unitFrame.BuffFrame2.Y = -11 + plateConfigs.buff_frame_y_offset + Plater.db.profile.aura2_y_offset
			unitFrame.BuffFrame2:ClearAllPoints()
			unitFrame.BuffFrame2:SetPoint (buffFrame.Point1, buffFrame.Anchor, buffFrame.Point2, unitFrame.BuffFrame2.X, unitFrame.BuffFrame2.Y)
		end
		
		--player
		if (plateFrame.isSelf) then
			Plater.UpdateManaAndResourcesBar()
			local r, g, b = DF:ParseColors ("lightgreen")
			healthFrame.barTexture:SetVertexColor (r, g, b)
			healthFrame.R, healthFrame.G, healthFrame.B = r, g, b
		end
		
	elseif (order == 2) then
		--health, buffs, castbar
		
		local castKey, heathKey, textKey = Plater.GetHashKey (isInCombat)
		local SizeOf_healthBar_Width = plateConfigs [heathKey][1]
		local SizeOf_castBar_Width = plateConfigs [castKey][1]
		local SizeOf_healthBar_Height = plateConfigs [heathKey][2]
		local SizeOf_castBar_Height = plateConfigs [castKey][2]
		local SizeOf_text = plateConfigs [textKey]
		
		local height_offset = 0

		--pegar o tamanho da barra de debuff para colocar a cast bar em cima dela
		local buffFrameSize = Plater.db.profile.aura_height
		
		local scalarValue = SizeOf_castBar_Width > plateWidth and -((SizeOf_castBar_Width - plateWidth) / 2) or ((plateWidth - SizeOf_castBar_Width) / 2)
		if (isMinus) then
			scalarValue = scalarValue + (SizeOf_castBar_Width/5)
		end
		castFrame:SetPoint ("BOTTOMLEFT", unitFrame, "BOTTOMLEFT", scalarValue, buffFrameSize + SizeOf_healthBar_Height + 2 + height_offset);
		castFrame:SetPoint ("BOTTOMRIGHT", unitFrame, "BOTTOMRIGHT", -scalarValue, buffFrameSize + SizeOf_healthBar_Height + 2 + height_offset);
		castFrame:SetHeight (SizeOf_castBar_Height)
		castFrame.Icon:SetSize (SizeOf_castBar_Height, SizeOf_castBar_Height)
		castFrame.BorderShield:SetSize (SizeOf_castBar_Height*1.4, SizeOf_castBar_Height*1.4)
		
		local scalarValue
		if (Plater.ZonePvpType ~= "sanctuary") then
			scalarValue = SizeOf_healthBar_Width > SizeOf_castBar_Width and -((SizeOf_healthBar_Width - SizeOf_castBar_Width) / 2) or ((SizeOf_castBar_Width - SizeOf_healthBar_Width) / 2)
		else
			scalarValue = 70 > SizeOf_castBar_Width and -((70 - SizeOf_castBar_Width) / 2) or ((SizeOf_castBar_Width - 70) / 2)
		end
		
		healthFrame:ClearAllPoints()
		healthFrame:SetPoint ("BOTTOMLEFT", castFrame, "TOPLEFT", scalarValue,  (-SizeOf_healthBar_Height) + (-SizeOf_castBar_Height) + (-buffFrameSize) - 4);
		healthFrame:SetPoint ("BOTTOMRIGHT", castFrame, "TOPRIGHT", -scalarValue,  (-SizeOf_healthBar_Height) + (-SizeOf_castBar_Height) + (-buffFrameSize) - 4);
		
		local targetHeight = SizeOf_healthBar_Height / (isMinus and 2 or 1)
		local currentHeight = healthFrame:GetHeight()
		
		if (justAdded or not Plater.db.profile.height_animation) then
			healthFrame:SetHeight (targetHeight)
		else
			if (currentHeight < targetHeight) then
				if (not healthFrame.IsIncreasingHeight) then
					healthFrame.IsDecreasingHeight = nil
					healthFrame.TargetHeight = targetHeight
					healthFrame.ToIncreace = targetHeight - currentHeight
					--print ("!", healthFrame.ToIncreace, 2886)
					healthFrame.HAVE_HEIGHT_ANIMATION = "up"
				end
			elseif (currentHeight > targetHeight) then
				if (not healthFrame.IsDecreasingHeight) then
					healthFrame.IsIncreasingHeight = nil
					healthFrame.TargetHeight = targetHeight
					healthFrame.ToDecrease = currentHeight - targetHeight
					healthFrame.HAVE_HEIGHT_ANIMATION = "down"
				end
			end
		end
		
		buffFrame.Point1 = "top"
		buffFrame.Point2 = "bottom"
		buffFrame.Anchor = castFrame
		buffFrame.X = DB_AURA_X_OFFSET
		buffFrame.Y = -1 + plateConfigs.buff_frame_y_offset + DB_AURA_Y_OFFSET
		
		buffFrame:ClearAllPoints()
		buffFrame:SetPoint (buffFrame.Point1, buffFrame.Anchor, buffFrame.Point2, buffFrame.X, buffFrame.Y)
		
		--> second aura frame
		if (DB_AURA_SEPARATE_BUFFS) then
			unitFrame.BuffFrame2.X = Plater.db.profile.aura2_x_offset
			unitFrame.BuffFrame2.Y = -1 + plateConfigs.buff_frame_y_offset + Plater.db.profile.aura2_y_offset
			unitFrame.BuffFrame2:ClearAllPoints()
			unitFrame.BuffFrame2:SetPoint (buffFrame.Point1, buffFrame.Anchor, buffFrame.Point2, unitFrame.BuffFrame2.X, unitFrame.BuffFrame2.Y)
		end
		
		--player
		if (plateFrame.isSelf) then
			Plater.UpdateManaAndResourcesBar()
			healthFrame.barTexture:SetVertexColor (DF:ParseColors ("lightgreen"))
		end
		
	elseif (order == 3) then --~order
		--castbar, health, buffs
		
		local castKey, heathKey, textKey = Plater.GetHashKey (isInCombat)
		local SizeOf_healthBar_Width = plateConfigs [heathKey][1]
		local SizeOf_castBar_Width = plateConfigs [castKey][1]
		local SizeOf_healthBar_Height = plateConfigs [heathKey][2]
		local SizeOf_castBar_Height = plateConfigs [castKey][2]
		local SizeOf_text = plateConfigs [textKey]
		local buffFrameSize = Plater.db.profile.aura_height
		local height_offset = 0
		
		--> cast bar
			local scalarValue = SizeOf_castBar_Width > plateWidth and -((SizeOf_castBar_Width - plateWidth) / 2) or ((plateWidth - SizeOf_castBar_Width) / 2)
			
			if (unitType == "pet") then
				scalarValue = abs (Plater.db.profile.pet_width_scale - 2) * scalarValue
			elseif (unitType == "minus") then
				scalarValue = abs (Plater.db.profile.minor_width_scale - 2) * scalarValue
			end
			
			castFrame:SetPoint ("BOTTOMLEFT", unitFrame, "BOTTOMLEFT", scalarValue, height_offset) ---SizeOf_healthBar_Height + (-SizeOf_castBar_Height + 2)
			castFrame:SetPoint ("BOTTOMRIGHT", unitFrame, "BOTTOMRIGHT", -scalarValue, height_offset)
			
			--10/03/2018: cast frame affecting the position of the player health bar when leaving combat
			if (not plateFrame.isSelf) then
				if (unitType == "pet") then
					SizeOf_castBar_Height = SizeOf_castBar_Height * Plater.db.profile.pet_height_scale
					castFrame:SetHeight (SizeOf_castBar_Height)
					
				elseif (unitType == "minus") then
					SizeOf_castBar_Height = SizeOf_castBar_Height * Plater.db.profile.minor_height_scale
					castFrame:SetHeight (SizeOf_castBar_Height)
					
				else
					castFrame:SetHeight (SizeOf_castBar_Height)
				end
			end
			
			castFrame.Icon:SetSize (SizeOf_castBar_Height, SizeOf_castBar_Height)
			castFrame.BorderShield:SetSize (SizeOf_castBar_Height*1.4, SizeOf_castBar_Height*1.4)

		--> health bar
			local scalarValue
			if (plateFrame [MEMBER_REACTION] <= 4) then --> enemy and neutral
				scalarValue = SizeOf_healthBar_Width > SizeOf_castBar_Width and -((SizeOf_healthBar_Width - SizeOf_castBar_Width) / 2) or ((SizeOf_castBar_Width - SizeOf_healthBar_Width) / 2)
			else
				if (plateFrame.isSelf) then
					scalarValue = SizeOf_healthBar_Width > SizeOf_castBar_Width and -((SizeOf_healthBar_Width - SizeOf_castBar_Width) / 2) or ((SizeOf_castBar_Width - SizeOf_healthBar_Width) / 2)
				else
					--> friendly
					scalarValue = SizeOf_healthBar_Width > SizeOf_castBar_Width and -((SizeOf_healthBar_Width - SizeOf_castBar_Width) / 2) or ((SizeOf_castBar_Width - SizeOf_healthBar_Width) / 2)
				end
			end

			--health
			healthFrame:ClearAllPoints()
			healthFrame:SetPoint ("BOTTOMLEFT", castFrame, "TOPLEFT", scalarValue,  1)
			healthFrame:SetPoint ("BOTTOMRIGHT", castFrame, "TOPRIGHT", -scalarValue,  1)
			
			local targetHeight = SizeOf_healthBar_Height
			if (unitType == "pet") then
				targetHeight = targetHeight * Plater.db.profile.pet_height_scale
			elseif (unitType == "minus") then
				targetHeight = targetHeight * Plater.db.profile.minor_height_scale
			end

			local currentHeight = healthFrame:GetHeight()
			
			if (justAdded or not Plater.db.profile.height_animation) then
				healthFrame:SetHeight (targetHeight)
			else
				if (currentHeight < targetHeight) then
					if (not healthFrame.IsIncreasingHeight) then
						healthFrame.IsDecreasingHeight = nil
						healthFrame.TargetHeight = targetHeight
						healthFrame.ToIncreace = targetHeight - currentHeight
						healthFrame.HAVE_HEIGHT_ANIMATION = "up"
					end
				elseif (currentHeight > targetHeight) then
					if (not healthFrame.IsDecreasingHeight) then
						healthFrame.IsIncreasingHeight = nil
						healthFrame.TargetHeight = targetHeight
						healthFrame.ToDecrease = currentHeight - targetHeight
						healthFrame.HAVE_HEIGHT_ANIMATION = "down"
					end
				end
			end
		
		--> buff frame
			buffFrame.Point1 = "bottom"
			buffFrame.Point2 = "top"
			buffFrame.Anchor = healthFrame
			buffFrame.X = DB_AURA_X_OFFSET
			buffFrame.Y = (buffFrameSize / 3) + 1 + plateConfigs.buff_frame_y_offset + DB_AURA_Y_OFFSET
			
			buffFrame:ClearAllPoints()
			buffFrame:SetPoint (buffFrame.Point1, buffFrame.Anchor, buffFrame.Point2, buffFrame.X, buffFrame.Y)
			
			--> second aura frame
			if (DB_AURA_SEPARATE_BUFFS) then
				unitFrame.BuffFrame2.X = Plater.db.profile.aura2_x_offset
				unitFrame.BuffFrame2.Y = (buffFrameSize / 3) + 1 + plateConfigs.buff_frame_y_offset + Plater.db.profile.aura2_y_offset
				unitFrame.BuffFrame2:ClearAllPoints()
				unitFrame.BuffFrame2:SetPoint (buffFrame.Point1, buffFrame.Anchor, buffFrame.Point2, unitFrame.BuffFrame2.X, unitFrame.BuffFrame2.Y)
			end
			
			--personal player bar
			if (plateFrame.isSelf) then
				Plater.UpdateManaAndResourcesBar()
				healthFrame.barTexture:SetVertexColor (DF:ParseColors ("lightgreen"))
			end
	end
end

function Plater.UpdateManaAndResourcesBar()
	if (not InCombatLockdown()) then
		NamePlateDriverFrame:SetupClassNameplateBars()
	end
end

function Plater.GetUnitType (plateFrame)
	if (PET_CACHE [plateFrame [MEMBER_GUID]]) then
		return "pet"
		
	elseif (plateFrame [MEMBER_CLASSIFICATION] == "minus") then
		return "minus"
	end
	
	return "normal"
end

-- ~color
function Plater.ForceChangeHealthBarColor (healthBar, r, g, b, forceNoLerp)
	--if (r ~= healthBar.R or g ~= healthBar.G or b ~= healthBar.B) then
		healthBar.R, healthBar.G, healthBar.B = r, g, b
		if (not DB_LERP_COLOR or forceNoLerp) then -- ~lerpcolor
			healthBar.barTexture:SetVertexColor (r, g, b)
		end
	--end
end

--[=[
v7.3.5.072
function Plater.ForceChangeHealthBarColor (healthBar, r, g, b)
	if (r ~= healthBar.R or g ~= healthBar.G or b ~= healthBar.B) then
		--healthBar.r, healthBar.g, healthBar.b = r, g, b
		healthBar.R, healthBar.G, healthBar.B = r, g, b
		healthBar.barTexture:SetVertexColor (r, g, b)
	end
end

r43-release
function Plater.ForceChangeHealthBarColor (healthBar, r, g, b)
	if (r ~= healthBar.r or g ~= healthBar.g or b ~= healthBar.b) then
		healthBar.r, healthBar.g, healthBar.b = r, g, b
		healthBar.barTexture:SetVertexColor (r, g, b)
	end
end
--]=]

--test if still tainted... nop still taited
--healthBar.r = r
--healthBar.g = g
--healthBar.b = b
--healthBar:SetStatusBarColor (r, g, b)

--plater ~API ãpi

function Plater.CreateIconGlow (frame, color)
	local f = Plater:CreateGlowOverlay (frame, color, color)
	return f
end

function Plater.CreateNameplateGlow (frame, color, left, right, top, bottom)
	local antTable = {
		Throttle = 0.025,
		AmountParts = 15,
		TexturePartsWidth = 167.4,
		TexturePartsHeight = 83.6,
		TextureWidth = 512,
		TextureHeight = 512,
		BlendMode = "ADD",
		Color = color,
		Texture = [[Interface\AddOns\Plater\images\ants_rectangle]],
	}

	--> ants
	local f = DF:CreateAnts (frame, antTable, -27 + (left or 0), 25 + (right or 0), 5 + (top or 0), -7 + (bottom or 0))
	f:SetFrameLevel (frame:GetFrameLevel() + 1)
	f:SetAlpha (ALPHA_BLEND_AMOUNT - 0.249845)
	
	--> glow
	local glow = f:CreateTexture (nil, "background")
	glow:SetTexture ([[Interface\AddOns\Plater\images\nameplate_glow]])
	glow:SetPoint ("center", frame, "center", 0, 0)
	glow:SetSize (frame:GetWidth() + frame:GetWidth()/2.3, 36)
	glow:SetBlendMode ("ADD")
	glow:SetVertexColor (DF:ParseColors (color or "white"))
	glow:SetAlpha (ALPHA_BLEND_AMOUNT)
	glow.GlowTexture = glow
	
	return f
end

function Plater.OnPlayCustomFlashAnimation (animationHub)
	animationHub:GetParent():Show()
	animationHub.Texture:Show()
	--animationHub.Texture:Show()
end
function Plater.OnStopCustomFlashAnimation (animationHub)
	animationHub:GetParent():Hide()
	animationHub.Texture:Hide()
end
function Plater.UpdateCustomFlashAnimation (animationHub, duration, r, g, b)
	for i = 1, #animationHub.AllAnimations do
		if (duration) then
			animationHub.AllAnimations [i]:SetDuration (duration)
		end
		if (r) then
			r, g, b = DF:ParseColors (r, g, b)
			animationHub.Texture:SetColorTexture (r, g, b)
		end
	end
end

function Plater.CreateFlash (frame, duration, amount, r, g, b)
	--defaults
	duration = duration or 0.25
	amount = amount or 1
	
	if (not r) then
		r, g, b = 1, 1, 1
	else
		r, g, b = DF:ParseColors (r, g, b)
	end

	--create the flash frame
	local f = CreateFrame ("frame", "PlaterFlashAnimationFrame".. math.random (1, 100000000), frame)
	f:SetFrameLevel (frame:GetFrameLevel()+1)
	f:SetAllPoints()
	f:Hide()
	
	--create the flash texture
	local t = f:CreateTexture ("PlaterFlashAnimationTexture".. math.random (1, 100000000), "artwork")
	t:SetColorTexture (r, g, b)
	t:SetAllPoints()
	t:SetBlendMode ("ADD")
	t:Hide()
	
	--create the flash animation
	local animationHub = DF:CreateAnimationHub (f, Plater.OnPlayCustomFlashAnimation, Plater.OnStopCustomFlashAnimation)
	animationHub.AllAnimations = {}
	animationHub.Parent = f
	animationHub.Texture = t
	animationHub.Amount = amount
	animationHub.UpdateDurationAndColor = Plater.UpdateCustomFlashAnimation
	
	for i = 1, amount * 2, 2 do
		local fadeIn = DF:CreateAnimation (animationHub, "ALPHA", i, duration, 0, 1)
		local fadeOut = DF:CreateAnimation (animationHub, "ALPHA", i + 1, duration, 1, 0)
		tinsert (animationHub.AllAnimations, fadeIn)
		tinsert (animationHub.AllAnimations, fadeOut)
	end
	
	return animationHub
end

function Plater.RefreshNameplateColor (unitFrame)
	if (unitFrame.unit) then
		if (IsTapDenied (unitFrame.unit)) then
			Plater.ForceChangeHealthBarColor (unitFrame.healthBar, unpack (Plater.db.profile.tap_denied_color))
		else
			if (InCombatLockdown()) then
				if (unitFrame:GetParent() [MEMBER_REACTION] <= 4) then
					Plater.UpdateNameplateThread (unitFrame)
				else
					CompactUnitFrame_UpdateHealthColor (unitFrame)
				end
			else
				CompactUnitFrame_UpdateHealthColor (unitFrame)
			end
		end
	end
end

function Plater.SetNameplateColor (unitFrame, r, g, b)
	if (unitFrame.unit) then
		if (not r) then
			Plater.RefreshNameplateColor (unitFrame)
		else
			r, g, b = DF:ParseColors (r, g, b)
			return Plater.ForceChangeHealthBarColor (unitFrame.healthBar, r, g, b)
		end
	end
end

function Plater.FlashNameplateBorder (unitFrame, duration)
	if (not unitFrame.healthBar.PlayHealthFlash) then
		Plater.CreateHealthFlashFrame (unitFrame:GetParent())
	end
	unitFrame.healthBar.canHealthFlash = true
	unitFrame.healthBar.PlayHealthFlash (duration)
end

function Plater.FlashNameplateBody (unitFrame, text, duration)
	unitFrame:GetParent().PlayBodyFlash (text, duration)
end

function Plater.SetCastBarBorderColor (castBar, r, g, b, a)
	--check if the frame passed was the unitFrame instead of the castbar it self
	if (castBar.castBar) then
		castBar = castBar.castBar
	end
	
	r, g, b, a = DF:ParseColors (r, g, b, a)
	castBar.FrameOverlay:SetBackdropBorderColor (r, g, b, a)
end

--check the setting 'only_damaged' and 'only_thename' for player characters. not critical code, can run slow
function Plater.ParseHealthSettingForPlayer (plateFrame)

	plateFrame.IsFriendlyPlayerWithoutHealthBar = false

	if (DB_PLATE_CONFIG [ACTORTYPE_FRIENDLY_PLAYER].only_damaged) then
		if (UnitHealth (plateFrame [MEMBER_UNITID]) < UnitHealthMax (plateFrame [MEMBER_UNITID])) then
			plateFrame.UnitFrame.healthBar:Show()
			plateFrame.UnitFrame.BuffFrame:Show()
			plateFrame.UnitFrame.BuffFrame2:Show()
			plateFrame.UnitFrame.healthBar.actorName:Show()
			
			plateFrame.ActorNameSpecial:Hide()
			plateFrame.ActorTitleSpecial:Hide()
		else
			plateFrame.UnitFrame.healthBar:Hide()
			plateFrame.UnitFrame.BuffFrame:Hide()
			plateFrame.UnitFrame.BuffFrame2:Hide()
			plateFrame.UnitFrame.healthBar.actorName:Hide()
			
			if (DB_PLATE_CONFIG [ACTORTYPE_FRIENDLY_PLAYER].only_thename) then
				plateFrame.IsFriendlyPlayerWithoutHealthBar = true
			end
		end
		
	elseif (DB_PLATE_CONFIG [ACTORTYPE_FRIENDLY_PLAYER].only_thename) then
		plateFrame.UnitFrame.healthBar:Hide()
		plateFrame.UnitFrame.BuffFrame:Hide()
		plateFrame.UnitFrame.BuffFrame2:Hide()
		plateFrame.UnitFrame.healthBar.actorName:Hide()
		plateFrame.IsFriendlyPlayerWithoutHealthBar = true
		
	else
		plateFrame.UnitFrame.healthBar:Show()
		plateFrame.UnitFrame.BuffFrame:Show()
		plateFrame.UnitFrame.BuffFrame2:Show()
		plateFrame.UnitFrame.healthBar.actorName:Show()
	end
end

-- ~update
function Plater.UpdatePlateFrame (plateFrame, actorType, forceUpdate, justAdded)
	
	actorType = actorType or plateFrame.actorType
	
	local order = DB_PLATE_CONFIG [actorType].plate_order
	
	local unitFrame = plateFrame.UnitFrame --setallpoints
	local healthFrame = unitFrame.healthBar
	local castFrame = unitFrame.castBar
	local buffFrame = unitFrame.BuffFrame
	local nameFrame = unitFrame.healthBar.actorName
	
	plateFrame.actorType = actorType
	plateFrame.order = order
	
	local shouldForceRefresh = false
	if (plateFrame.IsNpcWithoutHealthBar or plateFrame.IsFriendlyPlayerWithoutHealthBar) then
		shouldForceRefresh = true
		plateFrame.IsNpcWithoutHealthBar = false
		plateFrame.IsFriendlyPlayerWithoutHealthBar = false
	end

	healthFrame.BorderIsAggroIndicator = nil
	
	local wasQuestPlate = plateFrame [MEMBER_QUEST]
	plateFrame [MEMBER_QUEST] = false
	
	plateFrame.ActorNameSpecial:Hide()
	plateFrame.ActorTitleSpecial:Hide()
	plateFrame.Top3DFrame:Hide()
	plateFrame.RaidTarget:Hide()
	
	--clear aggro glow
	unitFrame.aggroGlowUpper:Hide()
	unitFrame.aggroGlowLower:Hide()
	
	--check for quest color
	if (IS_IN_OPEN_WORLD and actorType == ACTORTYPE_ENEMY_NPC and DB_PLATE_CONFIG [actorType].quest_enabled) then --actorType == ACTORTYPE_FRIENDLY_NPC or 
		local isQuestMob = Plater.IsQuestObjective (plateFrame)
		if (isQuestMob and not IsTapDenied (plateFrame.UnitFrame.unit)) then
			if (plateFrame [MEMBER_REACTION] == UNITREACTION_NEUTRAL) then
				Plater.ForceChangeHealthBarColor (healthFrame, unpack (DB_PLATE_CONFIG [actorType].quest_color_neutral))
				plateFrame [MEMBER_QUEST] = true
			else
				Plater.ForceChangeHealthBarColor (healthFrame, unpack (DB_PLATE_CONFIG [actorType].quest_color_enemy))
				plateFrame [MEMBER_QUEST] = true
			end
		else
			if (wasQuestPlate) then
				CompactUnitFrame_UpdateHealthColor (unitFrame)
			end
		end
	else
		if (wasQuestPlate) then
			CompactUnitFrame_UpdateHealthColor (unitFrame)
		end
	end
	
	--se a plate for de npc amigo
	if (actorType == ACTORTYPE_FRIENDLY_NPC) then
	
		if (IS_IN_OPEN_WORLD and DB_PLATE_CONFIG [actorType].quest_enabled and Plater.IsQuestObjective (plateFrame)) then
			Plater.ForceChangeHealthBarColor (healthFrame, unpack (DB_PLATE_CONFIG [actorType].quest_color))

			healthFrame:Show()
			buffFrame:Show()
			nameFrame:Show()
			
			plateFrame [MEMBER_QUEST] = true
		
		elseif (DB_PLATE_CONFIG [actorType].only_names or DB_PLATE_CONFIG [actorType].all_names) then
			--show only the npc name without the health bar

			healthFrame:Hide()
			buffFrame:Hide()
			nameFrame:Hide()
			plateFrame.IsNpcWithoutHealthBar = true
			
		else
			healthFrame:Show()
			buffFrame:Show()
			nameFrame:Show()

		end

	elseif (actorType == ACTORTYPE_FRIENDLY_PLAYER) then
		Plater.ParseHealthSettingForPlayer (plateFrame)
		
		if (not plateFrame.IsFriendlyPlayerWithoutHealthBar) then
			--change the player health bar color (no class color uses hardcoded white color)
			if (not Plater.db.profile.use_playerclass_color) then
				Plater.ForceChangeHealthBarColor (healthFrame, 1, 1, 1)
			else
				local _, class = UnitClass (plateFrame [MEMBER_UNITID])
				if (class) then		
					local color = RAID_CLASS_COLORS [class]
					Plater.ForceChangeHealthBarColor (healthFrame, color.r, color.g, color.b)
				else
					Plater.ForceChangeHealthBarColor (healthFrame, 1, 1, 1)
				end
			end
		end
		
	else
		--> enemy npc or enemy player pass throught here
		--check if this is an enemy npc but the player cannot attack it
		if (plateFrame.PlayerCannotAttack) then
			healthFrame:Hide()
			buffFrame:Hide()
			nameFrame:Hide()
			plateFrame.IsNpcWithoutHealthBar = true
			
		else
			healthFrame:Show()
			buffFrame:Show()
			nameFrame:Show()
			
			--> check for enemy player class color
			if (actorType == ACTORTYPE_ENEMY_PLAYER) then
				if (DB_PLATE_CONFIG [actorType].use_playerclass_color) then
					local _, class = UnitClass (plateFrame [MEMBER_UNITID])
					if (class) then		
						local color = RAID_CLASS_COLORS [class]
						Plater.ForceChangeHealthBarColor (healthFrame, color.r, color.g, color.b)
					else
						Plater.ForceChangeHealthBarColor (healthFrame, unpack (DB_PLATE_CONFIG [actorType].fixed_class_color))
					end
				else
					Plater.ForceChangeHealthBarColor (healthFrame, unpack (DB_PLATE_CONFIG [actorType].fixed_class_color))
				end
			end
		end

	end
	
	buffFrame:ClearAllPoints()
	nameFrame:ClearAllPoints()
	
	castFrame:SetStatusBarTexture (DB_TEXTURE_CASTBAR)
	
	--update all texts in the nameplate
	Plater.UpdatePlateText (plateFrame, DB_PLATE_CONFIG [actorType], shouldForceRefresh or plateFrame.PreviousUnitType ~= actorType or unitFrame.RefreshID < PLATER_REFRESH_ID)

	if (unitFrame.RefreshID < PLATER_REFRESH_ID) then
		unitFrame.RefreshID = PLATER_REFRESH_ID

		--update highlight texture
		unitFrame.HighlightFrame.HighlightTexture:SetTexture (DB_TEXTURE_HEALTHBAR)
		unitFrame.HighlightFrame.HighlightTexture:SetBlendMode ("ADD")
		unitFrame.HighlightFrame.HighlightTexture:SetAlpha (Plater.db.profile.hover_highlight_alpha)
		
		--click area is shown?
		if (Plater.db.profile.click_space_always_show) then
			Plater.SetPlateBackground (plateFrame)
		else
			plateFrame:SetBackdrop (nil)
		end
		
		--setup the cast bar
		castFrame.background:SetTexture (DB_TEXTURE_CASTBAR_BG)
		castFrame.background:SetVertexColor (unpack (Plater.db.profile.cast_statusbar_bgcolor))
		castFrame.Flash:SetTexture (DB_TEXTURE_CASTBAR)
		castFrame.Icon:SetTexCoord (0.078125, 0.921875, 0.078125, 0.921875)
		
		--setup the health bar
		healthFrame.barTexture:SetTexture (DB_TEXTURE_HEALTHBAR)
		healthFrame.background:SetTexture (DB_TEXTURE_HEALTHBAR_BG)
		healthFrame.background:SetVertexColor (unpack (Plater.db.profile.health_statusbar_bgcolor))

		--update the energy bar on the personal bar
		ClassNameplateManaBarFrame.Texture:SetTexture (DB_TEXTURE_HEALTHBAR)
		
		--update border
		Plater.UpdatePlateBorders (plateFrame)
	end
	
	if (unitFrame.selectionHighlight:IsShown()) then
		local targetedOverlayTexture = LibSharedMedia:Fetch ("statusbar", Plater.db.profile.health_selection_overlay)
		unitFrame.selectionHighlight:SetTexture (targetedOverlayTexture)
	end
	
	--update the plate size for this unit
	Plater.UpdatePlateSize (plateFrame, justAdded)
	
	--raid marker
	Plater.UpdatePlateRaidMarker (plateFrame)
	
	--indicators for the unit
	Plater.UpdateIndicators (plateFrame, actorType)
	
	--aura container
	Plater.UpdateBuffContainer (plateFrame)
	
	--target indicator
	Plater.UpdateTarget (plateFrame)
	
	--update the frame level
	if (DB_UPDATE_FRAMELEVEL) then
		if (Plater.db.profile.healthbar_framelevel ~= 0) then
			healthFrame:SetFrameLevel (healthFrame.DefaultFrameLevel + Plater.db.profile.healthbar_framelevel)
		end
		if (Plater.db.profile.castbar_framelevel ~= 0) then
			castFrame:SetFrameLevel (castFrame.DefaultFrameLevel + Plater.db.profile.castbar_framelevel)
		end
	end
	
	--update options in the extra icons row frame
	if (unitFrame.ExtraIconFrame.RefreshID < PLATER_REFRESH_ID) then
		Plater.SetAnchor (unitFrame.ExtraIconFrame, Plater.db.profile.extra_icon_anchor)
		unitFrame.ExtraIconFrame:SetOption ("show_text", Plater.db.profile.extra_icon_show_timer)
		unitFrame.ExtraIconFrame:SetOption ("grow_direction", unitFrame.ExtraIconFrame:GetIconGrowDirection())
		unitFrame.ExtraIconFrame:SetOption ("icon_width", Plater.db.profile.extra_icon_width)
		unitFrame.ExtraIconFrame:SetOption ("icon_height", Plater.db.profile.extra_icon_height)
		unitFrame.ExtraIconFrame:SetOption ("texcoord", Plater.db.profile.extra_icon_wide_icon and Plater.WideIconCoords or Plater.BorderLessIconCoords)
		unitFrame.ExtraIconFrame:SetOption ("desc_text", Plater.db.profile.extra_icon_caster_name)
		
		--> update refresh ID
		unitFrame.ExtraIconFrame.RefreshID = PLATER_REFRESH_ID
	end
	
	--> details! integration
	if (IS_USING_DETAILS_INTEGRATION) then
		local detailsPlaterConfig = Details.plater

		if (detailsPlaterConfig.realtime_dps_enabled) then
			local textString = healthFrame.DetailsRealTime
			Plater.SetAnchor (textString, detailsPlaterConfig.realtime_dps_anchor)
			DF:SetFontSize (textString, detailsPlaterConfig.realtime_dps_size)
			DF:SetFontOutline (textString, detailsPlaterConfig.realtime_dps_shadow)
			DF:SetFontColor (textString, detailsPlaterConfig.realtime_dps_color)
		end
		
		if (detailsPlaterConfig.realtime_dps_player_enabled) then
			local textString = healthFrame.DetailsRealTimeFromPlayer
			Plater.SetAnchor (textString, detailsPlaterConfig.realtime_dps_player_anchor)
			DF:SetFontSize (textString, detailsPlaterConfig.realtime_dps_player_size)
			DF:SetFontOutline (textString, detailsPlaterConfig.realtime_dps_player_shadow)
			DF:SetFontColor (textString, detailsPlaterConfig.realtime_dps_player_color)
		end
		
		if (detailsPlaterConfig.damage_taken_enabled) then
			local textString = healthFrame.DetailsDamageTaken
			Plater.SetAnchor (textString, detailsPlaterConfig.damage_taken_anchor)
			DF:SetFontSize (textString, detailsPlaterConfig.damage_taken_size)
			DF:SetFontOutline (textString, detailsPlaterConfig.damage_taken_shadow)
			DF:SetFontColor (textString, detailsPlaterConfig.damage_taken_color)
		end
		
		--reset all labels used by details!
		healthFrame.DetailsRealTime:SetText ("")
		healthFrame.DetailsRealTimeFromPlayer:SetText ("")
		healthFrame.DetailsDamageTaken:SetText ("")
	end
end

-- ~indicators
function Plater.UpdateIndicators (plateFrame, actorType)
	--limpa os indicadores
	Plater.ClearIndicators (plateFrame)
	local config = Plater.db.profile
	
	if (actorType == ACTORTYPE_ENEMY_PLAYER) then
		if (config.indicator_faction) then
			Plater.AddIndicator (plateFrame, UnitFactionGroup (plateFrame [MEMBER_UNITID]))
		end
		if (config.indicator_enemyclass) then
			Plater.AddIndicator (plateFrame, "classicon")
		end
		if (config.indicator_spec) then 
			--> check if the user is using details
			if (Details and Details.realversion >= 134) then
				local spec = Details:GetSpecByGUID (plateFrame [MEMBER_GUID])
				if (spec) then
					local texture, L, R, T, B = Details:GetSpecIcon (spec)
					Plater.AddIndicator (plateFrame, "specicon", texture, L, R, T, B)
				end
			end
		end
		
	elseif (actorType == ACTORTYPE_ENEMY_NPC) then
	
		--is a pet
		if (PET_CACHE [plateFrame [MEMBER_GUID]]) then
			Plater.AddIndicator (plateFrame, "pet")
		end

		--classification
		local unitClassification = UnitClassification (plateFrame.namePlateUnitToken) --elite minus normal rare rareelite worldboss
		if (unitClassification == "worldboss") then
			Plater.AddIndicator (plateFrame, "worldboss")
			
		elseif (unitClassification == "rareelite" and (config.indicator_rare or config.indicator_elite)) then
			Plater.AddIndicator (plateFrame, "elite")
			Plater.AddIndicator (plateFrame, "rare")
		else
			if (unitClassification == "elite" and config.indicator_elite) then
				Plater.AddIndicator (plateFrame, "elite")
			end
			if (unitClassification == "rare" and config.indicator_rare) then
				Plater.AddIndicator (plateFrame, "rare")
			end
		end
		
		--quest boss
		local isQuestBoss = UnitIsQuestBoss (plateFrame.namePlateUnitToken) --true false
		if (isQuestBoss and config.indicator_quest) then
			Plater.AddIndicator (plateFrame, "quest")
		end
	
	elseif (actorType == ACTORTYPE_FRIENDLY_NPC) then
		if (plateFrame [MEMBER_QUEST]) then
			Plater.AddIndicator (plateFrame, "quest")
		end
	end
end

function Plater.AddIndicator (plateFrame, indicator, ...)

	local thisIndicator = plateFrame.IconIndicators [plateFrame.IconIndicators.Next]
	
	if (not thisIndicator) then
		local newIndicator = plateFrame.UnitFrame.healthBar:CreateTexture (nil, "overlay")
		newIndicator:SetSize (10, 10)
		tinsert (plateFrame.IconIndicators, newIndicator)
		thisIndicator = newIndicator
	end

	thisIndicator:Show()
	thisIndicator:SetTexCoord (0, 1, 0, 1)
	thisIndicator:SetVertexColor (1, 1, 1)
	thisIndicator:SetDesaturated (false)
	thisIndicator:SetSize (10, 10)
	
	--esconde o icone default do jogo
	plateFrame.UnitFrame.ClassificationFrame:Hide()
	
	-- ~icons
	if (indicator == "pet") then
		thisIndicator:SetTexture ([[Interface\AddOns\Plater\images\peticon]])
		
	elseif (indicator == "Horde") then
		thisIndicator:SetTexture ([[Interface\PVPFrame\PVP-Currency-Horde]])
		thisIndicator:SetSize (12, 12)

	elseif (indicator == "Alliance") then
		thisIndicator:SetTexture ([[Interface\PVPFrame\PVP-Currency-Alliance]])
		thisIndicator:SetTexCoord (4/32, 29/32, 2/32, 30/32)
		thisIndicator:SetSize (12, 12)
		
	elseif (indicator == "elite") then
		thisIndicator:SetTexture ([[Interface\GLUES\CharacterSelect\Glues-AddOn-Icons]])
		thisIndicator:SetTexCoord (0.75, 1, 0, 1)
		thisIndicator:SetVertexColor (1, .8, 0)
		thisIndicator:SetSize (12, 12)
		
	elseif (indicator == "rare") then
		thisIndicator:SetTexture ([[Interface\GLUES\CharacterSelect\Glues-AddOn-Icons]])
		thisIndicator:SetTexCoord (0.75, 1, 0, 1)
		thisIndicator:SetSize (12, 12)
		thisIndicator:SetDesaturated (true)
		
	elseif (indicator == "quest") then
		thisIndicator:SetTexture ([[Interface\TARGETINGFRAME\PortraitQuestBadge]])
		thisIndicator:SetTexCoord (2/32, 26/32, 1/32, 31/32)
		
	elseif (indicator == "classicon") then
		local _, class = UnitClass (plateFrame [MEMBER_UNITID])
		if (class) then
			thisIndicator:SetTexture ([[Interface\GLUES\CHARACTERCREATE\UI-CharacterCreate-Classes]])
			thisIndicator:SetTexCoord (unpack (CLASS_ICON_TCOORDS [class]))
		end
	
	elseif (indicator == "specicon") then
		local texture, L, R, T, B = ...
		thisIndicator:SetTexture (texture)
		thisIndicator:SetTexCoord (L, R, T, B)
	
	elseif (indicator == "worldboss") then
		thisIndicator:SetTexture ([[Interface\Scenarios\ScenarioIcon-Boss]])
		
	end
	
	if (plateFrame.IconIndicators.Next == 1) then
		Plater.SetAnchor (thisIndicator, Plater.db.profile.indicator_anchor)
	else
		local attachTo = plateFrame.IconIndicators [plateFrame.IconIndicators.Next - 1]
		--se for menor que 4 ele deve crescer para o lado da esquerda, nos outros casos vai para a direita
		if (Plater.db.profile.indicator_anchor.side < 4) then
			thisIndicator:SetPoint ("right", attachTo, "left", -2, 0)
		else
			thisIndicator:SetPoint ("left", attachTo, "right", 1, 0)
		end
	end
	
	plateFrame.IconIndicators.Next = plateFrame.IconIndicators.Next + 1
end

function Plater.ClearIndicators (plateFrame)
	for _, indicator in ipairs (plateFrame.IconIndicators) do
		indicator:Hide()
		indicator:ClearAllPoints()
	end
	plateFrame.IconIndicators.Next = 1
end

function Plater.ForceChangeBorderColor (self, r, g, b) --self = healthBar
	for index, texture in ipairs (self.border.Textures) do
		texture:SetVertexColor (r, g, b, 1)
	end
	self.BorderIsAggroIndicator = true
end

-- ~border
function Plater.UpdatePlateBorders (plateFrame)
	--bordas
	if (not plateFrame) then
		for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
			Plater.UpdatePlateBorders (plateFrame)
		end
		return
	end
	
	if (plateFrame.UnitFrame.healthBar.BorderIsAggroIndicator) then
		return
	end
	
	for index, texture in ipairs (plateFrame.UnitFrame.healthBar.border.Textures) do
		texture:Hide()
	end
	
	plateFrame.UnitFrame.healthBar:SetBorderAlpha (DB_BORDER_COLOR_A, DB_BORDER_COLOR_A/3, DB_BORDER_COLOR_A/6)
	plateFrame.UnitFrame.healthBar:SetBorderColor (DB_BORDER_COLOR_R, DB_BORDER_COLOR_G, DB_BORDER_COLOR_B)
	
	Plater.UpdatePlateBorderThickness (plateFrame)
end

function Plater.UpdatePlateBorderThickness (plateFrame)
	if (not plateFrame) then
		for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
			Plater.UpdatePlateBorderThickness (plateFrame)
		end
		return
	end
	
	plateFrame.UnitFrame.healthBar:SetLayerVisibility (true, DB_BORDER_THICKNESS >= 2, DB_BORDER_THICKNESS >= 3)
end

function Plater.GetPlateAlpha (plateFrame)
	if (UnitIsUnit (plateFrame [MEMBER_UNITID], "target")) then
		return 1
	else
		return AlphaBlending
	end
end

-- ~range
function Plater.CheckRange (plateFrame, onAdded)

	if (plateFrame [MEMBER_NOCOMBAT]) then
		return
		
	elseif (not DB_USE_RANGE_CHECK or plateFrame [MEMBER_REACTION] >= 5) then
		plateFrame.UnitFrame:SetAlpha (AlphaBlending)
		plateFrame [MEMBER_ALPHA] = AlphaBlending
		plateFrame [MEMBER_RANGE] = true
		return
	end
	
	if (onAdded) then
		--range check when the nameplate is added
	
		--debug
		--demon hunter Torment isn't working for range check
		--print (Plater.SpellForRangeCheck, IsSpellInRange (Plater.SpellForRangeCheck, plateFrame [MEMBER_UNITID]), plateFrame [MEMBER_UNITID])
		--IsSpellInRange (FindSpellBookSlotBySpellID (185245), "spell", plateFrame [MEMBER_UNITID]) 
		--if (IsSpellInRange (FindSpellBookSlotBySpellID (185245), "spell", plateFrame [MEMBER_UNITID]) == 1) then
		
		if (IsSpellInRange (Plater.SpellForRangeCheck, plateFrame [MEMBER_UNITID]) == 1) then
			plateFrame.FadedIn = true
			local alpha = Plater.GetPlateAlpha (plateFrame)
			plateFrame.UnitFrame:SetAlpha (alpha)
			plateFrame [MEMBER_ALPHA] = alpha
			plateFrame [MEMBER_RANGE] = true
		else
			plateFrame.FadedIn = nil
			local alpha = Plater.db.profile.range_check_alpha
			plateFrame.UnitFrame:SetAlpha (alpha)
			plateFrame [MEMBER_ALPHA] = alpha
			plateFrame [MEMBER_RANGE] = false
		end
	else

--test performance with druid guardian
--/run local f=CreateFrame("frame") f.Run=1 f:SetScript("OnUpdate", function(_,t) if (f.Run) then for i = 1, 1000000 do IsSpellInRange(25,"SPELL","target") end f.Run=nil else f:SetScript("OnUpdate",nil);print(t) end end)
--/run local f=CreateFrame("frame") f.Run=1 f:SetScript("OnUpdate", function(_,t) if (f.Run) then for i = 1, 1000000 do IsSpellInRange("Growl","target") end f.Run=nil else f:SetScript("OnUpdate",nil);print(t) end end)

		--regular range check during throttled tick
		if (Plater.SpellBookForRangeCheck) then
			if (IsSpellInRange (Plater.SpellForRangeCheck, Plater.SpellBookForRangeCheck, plateFrame [MEMBER_UNITID]) == 1) then
				if (not plateFrame.FadedIn and not plateFrame.UnitFrame.FadeIn.playing) then
					plateFrame:RangeFadeIn()
				end
			else
				if (plateFrame.FadedIn and not plateFrame.UnitFrame.FadeOut.playing) then
					plateFrame:RangeFadeOut()
				end
			end
		else
			if (IsSpellInRange (Plater.SpellForRangeCheck, plateFrame [MEMBER_UNITID]) == 1) then
				if (not plateFrame.FadedIn and not plateFrame.UnitFrame.FadeIn.playing) then
					plateFrame:RangeFadeIn()
				end
			else
				if (plateFrame.FadedIn and not plateFrame.UnitFrame.FadeOut.playing) then
					plateFrame:RangeFadeOut()
				end
			end
		end
	end
end

local on_fade_in_play = function (animation)
	animation.playing = true
end
local on_fade_out_play = function (animation)
	animation.playing = true
end
local on_fade_in_finished = function (animation)
	animation.playing = nil
	animation:GetParent():GetParent().FadedIn = true
	animation:GetParent():SetAlpha (AlphaBlending)
	animation:GetParent():GetParent() [MEMBER_ALPHA] = AlphaBlending
end
local on_fade_out_finished = function (animation)
	animation.playing = nil
	animation:GetParent():GetParent().FadedIn = false
	local alpha = Plater.db.profile.range_check_alpha
	animation:GetParent():SetAlpha (alpha)
	animation:GetParent():GetParent() [MEMBER_ALPHA] = alpha
end
local plate_fade_in = function (plateFrame)
	plateFrame.UnitFrame.FadeIn.Animation:SetFromAlpha (plateFrame.UnitFrame:GetAlpha())
	plateFrame.UnitFrame.FadeIn.Animation:SetToAlpha (AlphaBlending)
	plateFrame.UnitFrame.FadeIn:Play()
end
local plate_fade_out = function (plateFrame)
	plateFrame.UnitFrame.FadeOut.Animation:SetFromAlpha (plateFrame.UnitFrame:GetAlpha())
	plateFrame.UnitFrame.FadeOut.Animation:SetToAlpha (Plater.db.profile.range_check_alpha)
	plateFrame.UnitFrame.FadeOut:Play()
end
local create_alpha_animations = function (plateFrame)
	local unitFrame = plateFrame.UnitFrame
	
	unitFrame.FadeIn = plateFrame.UnitFrame:CreateAnimationGroup()
	unitFrame.FadeOut = plateFrame.UnitFrame:CreateAnimationGroup()
	
	unitFrame.FadeIn:SetScript ("OnPlay", on_fade_in_play)
	unitFrame.FadeOut:SetScript ("OnPlay", on_fade_out_play)
	unitFrame.FadeIn:SetScript ("OnFinished", on_fade_in_finished)
	unitFrame.FadeOut:SetScript ("OnFinished", on_fade_out_finished)
	
	unitFrame.FadeIn.Animation = unitFrame.FadeIn:CreateAnimation ("Alpha")
	unitFrame.FadeOut.Animation = unitFrame.FadeOut:CreateAnimation ("Alpha")
	
	unitFrame.FadeIn.Animation:SetOrder (1)
	unitFrame.FadeOut.Animation:SetOrder (1)
	unitFrame.FadeIn.Animation:SetDuration (0.2)
	unitFrame.FadeOut.Animation:SetDuration (0.2)
	
	plateFrame.RangeFadeIn = plate_fade_in
	plateFrame.RangeFadeOut = plate_fade_out
	
	plateFrame.FadedIn = true
end

function Plater.GetHealthBar (unitFrame)
	return unitFrame.healthBar, unitFrame.healthBar.actorName
end

function Plater.GetCastBar (unitFrame)
	return unitFrame.castBar, unitFrame.castBar.Text
end

function Plater.CheckHighlight (self)
	if (UnitIsUnit ("mouseover", self.unit)) then
		self.HighlightTexture:Show()
	else
		self.HighlightTexture:Hide()
	end
end

function Plater.CreateHighlightNameplate (plateFrame)
	local highlightOverlay = CreateFrame ("frame", "$parentHighlightOverlay", UIParent)
	highlightOverlay:EnableMouse (false)
	highlightOverlay:SetFrameStrata ("TOOLTIP")
	highlightOverlay:SetAllPoints (plateFrame.UnitFrame.healthBar)
	highlightOverlay:SetScript ("OnUpdate", Plater.CheckHighlight)
	
	highlightOverlay.HighlightTexture = highlightOverlay:CreateTexture (nil, "overlay")
	highlightOverlay.HighlightTexture:SetAllPoints()
	highlightOverlay.HighlightTexture:SetColorTexture (1, 1, 1, 1)
	highlightOverlay.HighlightTexture:SetAlpha (1)
	highlightOverlay:Hide()
	
	plateFrame.UnitFrame.HighlightFrame = highlightOverlay
end

function Plater.CreateScaleAnimation (plateFrame)

	--animation table
	plateFrame.SpellAnimations = {}
	
	--scale animation
	local duration = 0.05
	local animationHub = DF:CreateAnimationHub (plateFrame.UnitFrame)
	animationHub.ScaleUp = DF:CreateAnimation (animationHub, "scale", 1, duration,	1, 	1, 	1.2, 	1.2)
	animationHub.ScaleDown = DF:CreateAnimation (animationHub, "scale", 2, duration,	1, 	1, 	0.8, 	0.8)
	
	plateFrame.SpellAnimations ["scale"] = animationHub

--debug
--	C_Timer.NewTicker (2, function()
--		animationHub:Play()
--	end)
	
end

Plater ["NAME_PLATE_CREATED"] = function (self, event, plateFrame) -- ~created ~events
	--isto ï¿½ uma nameplate
	plateFrame.UnitFrame.PlateFrame = plateFrame
	plateFrame.isNamePlate = true
	plateFrame.UnitFrame.isNamePlate = true
	plateFrame.UnitFrame.BuffFrame.amtDebuffs = 0
	plateFrame.UnitFrame.BuffFrame.PlaterBuffList = {}
	plateFrame.UnitFrame.BuffFrame.isNameplate = true
	
	--> this technically should be causing taint
	plateFrame.UnitFrame.BuffFrame.UpdateAnchor = function()end
	plateFrame.UnitFrame.healthBar.border.plateFrame = plateFrame
	
	plateFrame.UnitFrame.RefreshID = 0
	
	--> second buff frame
	plateFrame.UnitFrame.BuffFrame2 = CreateFrame ("frame", nil, plateFrame.UnitFrame, "HorizontalLayoutFrame")
	Mixin (plateFrame.UnitFrame.BuffFrame2, NameplateBuffContainerMixin)
	plateFrame.UnitFrame.BuffFrame2.UpdateAnchor = function()end
	
	plateFrame.UnitFrame.BuffFrame2:SetPoint ("RIGHT", plateFrame.UnitFrame.healthBar, 0, 0)
	plateFrame.UnitFrame.BuffFrame2.spacing = 4
	plateFrame.UnitFrame.BuffFrame2.fixedHeight = 14
	plateFrame.UnitFrame.BuffFrame2:OnLoad()
	plateFrame.UnitFrame.BuffFrame2:SetScript ("OnEvent", plateFrame.UnitFrame.BuffFrame2.OnEvent)
	plateFrame.UnitFrame.BuffFrame2.amtDebuffs = 0
	plateFrame.UnitFrame.BuffFrame2.PlaterBuffList = {}
	plateFrame.UnitFrame.BuffFrame2.isNameplate = true
	
	--> buff frame doesn't has a name, make a name here to know which frame is being updated on :Layout() and to give names for icon frames
	plateFrame.UnitFrame.BuffFrame.Name = "Main"
	plateFrame.UnitFrame.BuffFrame2.Name = "Secondary"
	
	--> store the secondary anchor inside the regular buff container for speed
	plateFrame.UnitFrame.BuffFrame.BuffsAnchor = plateFrame.UnitFrame.BuffFrame2
	
	local healthBar = plateFrame.UnitFrame.healthBar
	plateFrame.NameAnchor = 0
	
	Plater.CreateScaleAnimation (plateFrame)
	
	plateFrame.UnitFrame.healthBar.DefaultFrameLevel = plateFrame.UnitFrame.healthBar:GetFrameLevel()
	plateFrame.UnitFrame.castBar.DefaultFrameLevel = plateFrame.UnitFrame.castBar:GetFrameLevel()
	
	--target indicators stored inside the UnitFrame but their parent is the healthBar
	plateFrame.UnitFrame.TargetTextures2Sides = {}
	plateFrame.UnitFrame.TargetTextures4Sides = {}
	for i = 1, 2 do
		local targetTexture = plateFrame.UnitFrame.healthBar:CreateTexture (nil, "overlay")
		targetTexture:SetDrawLayer ("overlay", 7)
		tinsert (plateFrame.UnitFrame.TargetTextures2Sides, targetTexture)
	end
	for i = 1, 4 do
		local targetTexture = plateFrame.UnitFrame.healthBar:CreateTexture (nil, "overlay")
		targetTexture:SetDrawLayer ("overlay", 7)
		tinsert (plateFrame.UnitFrame.TargetTextures4Sides, targetTexture)
	end
	
	local TargetNeonUp = plateFrame.UnitFrame:CreateTexture (nil, "overlay")
	TargetNeonUp:SetDrawLayer ("overlay", 7)
	TargetNeonUp:SetPoint ("topleft", healthBar, "bottomleft", 0, 0)
	TargetNeonUp:SetPoint ("topright", healthBar, "bottomright", 0, 0)
	TargetNeonUp:SetTexture ([[Interface\BUTTONS\UI-Panel-Button-Glow]])
	TargetNeonUp:SetTexCoord (1/128, 95/128, 30/64, 38/64)
	TargetNeonUp:SetDesaturated (true)
	TargetNeonUp:SetBlendMode ("ADD")
	TargetNeonUp:SetHeight (8)
	TargetNeonUp:Hide()
	plateFrame.TargetNeonUp = TargetNeonUp
	plateFrame.UnitFrame.TargetNeonUp = TargetNeonUp
	
	local TargetNeonDown = plateFrame.UnitFrame:CreateTexture (nil, "overlay")
	TargetNeonDown:SetDrawLayer ("overlay", 7)
	TargetNeonDown:SetPoint ("bottomleft", healthBar, "topleft", 0, 0)
	TargetNeonDown:SetPoint ("bottomright", healthBar, "topright", 0, 0)
	TargetNeonDown:SetTexture ([[Interface\BUTTONS\UI-Panel-Button-Glow]])
	TargetNeonDown:SetTexCoord (1/128, 95/128, 38/64, 30/64) --0, 95/128
	TargetNeonDown:SetDesaturated (true)
	TargetNeonDown:SetBlendMode ("ADD")
	TargetNeonDown:SetHeight (8)
	TargetNeonDown:Hide()
	plateFrame.TargetNeonDown = TargetNeonDown
	plateFrame.UnitFrame.TargetNeonDown = TargetNeonDown
	
	Plater.CreateHighlightNameplate (plateFrame)

	--health cutoff - execute range
	local healthCutOff = healthBar:CreateTexture (nil, "overlay")
	healthCutOff:SetTexture ([[Interface\AddOns\Plater\images\health_bypass_indicator]])
	healthCutOff:SetPoint ("left", healthBar, "left")
	healthCutOff:SetSize (16, 25)
	healthCutOff:SetBlendMode ("ADD")
	healthCutOff:SetDrawLayer ("overlay", 7)
	healthCutOff:Hide()
	healthBar.healthCutOff = healthCutOff
	
	local cutoffAnimationOnPlay = function()
		healthCutOff:Show()
	end
	local cutoffAnimationOnStop = function()
		healthCutOff:SetAlpha (.5)
	end
	
	local executeRange = healthBar:CreateTexture (nil, "border")
	executeRange:SetTexture ([[Interface\AddOns\Plater\images\execute_bar]])
	executeRange:SetPoint ("left", healthBar, "left")
	healthBar.executeRange = executeRange
	executeRange:Hide()

	local healthCutOffShowAnimation = DF:CreateAnimationHub (healthCutOff, cutoffAnimationOnPlay, cutoffAnimationOnStop)
	DF:CreateAnimation (healthCutOffShowAnimation, "Scale", 1, .2, .3, .3, 1.2, 1.2)
	DF:CreateAnimation (healthCutOffShowAnimation, "Scale", 2, .2, 1.2, 1.2, 1, 1)
	DF:CreateAnimation (healthCutOffShowAnimation, "Alpha", 1, .2, .2, 1)
	DF:CreateAnimation (healthCutOffShowAnimation, "Alpha", 2, .2, 1, .5)
	healthCutOff.ShowAnimation = healthCutOffShowAnimation
	
	local executeGlowUp = healthBar:CreateTexture (nil, "overlay")
	local executeGlowDown = healthBar:CreateTexture (nil, "overlay")
	executeGlowUp:SetTexture ([[Interface\AddOns\Plater\images\blue_neon]])
	executeGlowUp:SetTexCoord (0, 1, 0, 0.5)
	executeGlowUp:SetHeight (32)
	executeGlowUp:SetPoint ("bottom", healthBar, "top")
	executeGlowUp:SetBlendMode ("ADD")
	executeGlowDown:SetTexture ([[Interface\AddOns\Plater\images\blue_neon]])
	executeGlowDown:SetTexCoord (0, 1, 0.5, 1)
	executeGlowDown:SetHeight (30)
	executeGlowDown:SetPoint ("top", healthBar, "bottom")
	executeGlowDown:SetBlendMode ("ADD")
	
	local executeGlowAnimationOnPlay = function (self)
		self:GetParent():Show()
	end
	local executeGlowAnimationOnStop = function()
		
	end
	
	executeGlowUp.ShowAnimation = DF:CreateAnimationHub (executeGlowUp, executeGlowAnimationOnPlay, executeGlowAnimationOnStop)
	DF:CreateAnimation (executeGlowUp.ShowAnimation, "Scale", 1, .2, 1, .1, 1, 1.2, "bottom", 0, 0)
	DF:CreateAnimation (executeGlowUp.ShowAnimation, "Scale", 1, .2, 1, 1, 1, 1)
	
	executeGlowDown.ShowAnimation = DF:CreateAnimationHub (executeGlowDown, executeGlowAnimationOnPlay, executeGlowAnimationOnStop)
	DF:CreateAnimation (executeGlowDown.ShowAnimation, "Scale", 1, .2, 1, .1, 1, 1.2, "top", 0, 0)
	DF:CreateAnimation (executeGlowDown.ShowAnimation, "Scale", 1, .2, 1, 1.1, 1, 1)

	executeGlowUp:Hide()
	executeGlowDown:Hide()
	
	healthBar.ExecuteGlowUp = executeGlowUp
	healthBar.ExecuteGlowDown = executeGlowDown
	
	--raid target
	local raidTarget = healthBar:CreateTexture (nil, "overlay")
	raidTarget:SetPoint ("right", -2, 0)
	plateFrame.RaidTarget = raidTarget
	
	local raidMarkAnimation = DF:CreateAnimationHub (plateFrame.UnitFrame.RaidTargetFrame.RaidTargetIcon)
	DF:CreateAnimation (raidMarkAnimation, "Scale", 1, .075, .1, .1, 1.2, 1.2)
	DF:CreateAnimation (raidMarkAnimation, "Scale", 2, .075, 1.2, 1.2, 1, 1)
	plateFrame.UnitFrame.RaidTargetFrame.RaidTargetIcon.ShowAnimation = raidMarkAnimation
	
	plateFrame [MEMBER_ALPHA] = 1
	
	create_alpha_animations (plateFrame)
	
	--> create details! integration strings
	healthBar.DetailsRealTime = healthBar:CreateFontString (nil, "overlay", "GameFontNormal")
	healthBar.DetailsRealTimeFromPlayer = healthBar:CreateFontString (nil, "overlay", "GameFontNormal")
	healthBar.DetailsDamageTaken = healthBar:CreateFontString (nil, "overlay", "GameFontNormal")
	
	local onTickFrame = CreateFrame ("frame", nil, plateFrame)
	plateFrame.OnTickFrame = onTickFrame
	onTickFrame.unit = plateFrame [MEMBER_UNITID]
	onTickFrame.HealthBar = healthBar
	onTickFrame.PlateFrame = plateFrame
	onTickFrame.UnitFrame = plateFrame.UnitFrame
	onTickFrame.BuffFrame = plateFrame.UnitFrame.BuffFrame
	onTickFrame.BuffFrame2 = plateFrame.UnitFrame.BuffFrame2
	
	local onNextTickUpdate = CreateFrame ("frame", nil, plateFrame)
	plateFrame.OnNextTickUpdate = onNextTickUpdate
	onNextTickUpdate.unit = plateFrame [MEMBER_UNITID]
	onNextTickUpdate.HealthBar = healthBar
	onNextTickUpdate.PlateFrame = plateFrame
	onNextTickUpdate.UnitFrame = plateFrame.UnitFrame
	onNextTickUpdate.BuffFrame = plateFrame.UnitFrame.BuffFrame
	plateFrame.TickUpdate = Plater.TickUpdate
	
	--regular name
	local actorName = healthBar:CreateFontString (nil, "artwork", "GameFontNormal")
	healthBar.actorName = actorName
	plateFrame.actorName = actorName --shortcut
	plateFrame.CurrentUnitNameString = actorName
	
	--special name and title
	local ActorNameSpecial = plateFrame:CreateFontString (nil, "artwork", "GameFontNormal")
	plateFrame.ActorNameSpecial = ActorNameSpecial
	plateFrame.ActorNameSpecial:SetPoint ("center", plateFrame, "center")
	plateFrame.ActorNameSpecial:Hide()
	local ActorTitleSpecial = plateFrame:CreateFontString (nil, "artwork", "GameFontNormal")
	plateFrame.ActorTitleSpecial = ActorTitleSpecial
	plateFrame.ActorTitleSpecial:SetPoint ("top", ActorNameSpecial, "bottom", 0, -2)
	plateFrame.ActorTitleSpecial:Hide()

	plateFrame.UnitFrame.name:ClearAllPoints()
	plateFrame.UnitFrame.name:SetPoint ("bottom", healthBar.actorName, "bottom")
	
	--level customizado
	local actorLevel = healthBar:CreateFontString (nil, "overlay", "GameFontNormal")
	healthBar.actorLevel = actorLevel
	
	--porcentagem de vida
	local lifePercent = healthBar:CreateFontString (nil, "overlay", "GameFontNormal")
	lifePercent:SetDrawLayer ("ARTWORK", 0)
	healthBar.lifePercent = lifePercent
	
	local obscuredTexture = healthBar:CreateTexture (nil, "overlay")
	obscuredTexture:SetAllPoints()
	obscuredTexture:SetTexture ("Interface\\Tooltips\\UI-Tooltip-Background")
	obscuredTexture:SetVertexColor (0, 0, 0, 1)
	plateFrame.Obscured = obscuredTexture
	
	lifePercent:SetDrawLayer ("overlay", 5)
	obscuredTexture:SetDrawLayer ("overlay", 6)

	--> create the extra icon frame
	local options = {
		icon_width = 20, 
		icon_height = 20, 
		texcoord = {.1, .9, .1, .9},
		show_text = true,
	}
	
	plateFrame.UnitFrame.ExtraIconFrame = DF:CreateIconRow (plateFrame.UnitFrame, "$parentExtraIconRow", options)
	plateFrame.UnitFrame.ExtraIconFrame:ClearIcons()
	--> initialize the refresh ID
	plateFrame.UnitFrame.ExtraIconFrame.RefreshID = 0
	--> cache the extra icon frame inside the buff frame for speed
	plateFrame.UnitFrame.BuffFrame.ExtraIconFrame = plateFrame.UnitFrame.ExtraIconFrame
	
	--icone trï¿½s dimensï¿½es
	plateFrame.Top3DFrame = CreateFrame ("playermodel", plateFrame:GetName() .. "3DFrame", plateFrame, "ModelWithControlsTemplate")
	plateFrame.Top3DFrame:SetPoint ("bottom", plateFrame, "top", 0, -100)
	plateFrame.Top3DFrame:SetSize (200, 250)
	plateFrame.Top3DFrame:EnableMouse (false)
	plateFrame.Top3DFrame:EnableMouseWheel (false)
	plateFrame.Top3DFrame:Hide()
	plateFrame.UnitFrame.Top3DFrame = plateFrame.Top3DFrame
	
	--castbar
	--castbar background
	local castBarDefaultBackground = plateFrame.UnitFrame.castBar:CreateTexture (nil, "background")
	castBarDefaultBackground:SetAllPoints()
	castBarDefaultBackground:SetColorTexture (0, 0, 0, 0.5)
	
	local extraBackground = plateFrame.UnitFrame.castBar:CreateTexture (nil, "background")
	extraBackground:SetAllPoints()
	extraBackground:SetColorTexture (0, 0, 0, 1)
	plateFrame.UnitFrame.castBar.extraBackground = extraBackground
	extraBackground:SetDrawLayer ("background", -3)
	extraBackground:Hide()
	
	--set a UnitFrame member so scripts can get a quick reference of the unit frame from the castbar without calling for GetParent()
	plateFrame.UnitFrame.castBar.UnitFrame = plateFrame.UnitFrame
	
	plateFrame.UnitFrame.IsUnitNameplate = true
	DF:Mixin (plateFrame.UnitFrame, Plater.ScriptMetaFunctions)
	plateFrame.UnitFrame:HookScript ("OnHide", plateFrame.UnitFrame.OnHideWidget)
	
	plateFrame.UnitFrame.castBar.IsCastBar = true
	DF:Mixin (plateFrame.UnitFrame.castBar, Plater.ScriptMetaFunctions)
	plateFrame.UnitFrame.castBar:HookScript ("OnHide", plateFrame.UnitFrame.castBar.OnHideWidget)

	--> overlay for cast bar border
	plateFrame.UnitFrame.castBar.FrameOverlay = CreateFrame ("frame", "$parentOverlayFrame", plateFrame.UnitFrame.castBar)
	plateFrame.UnitFrame.castBar.FrameOverlay:SetAllPoints()
	plateFrame.UnitFrame.castBar.FrameOverlay:SetBackdrop ({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1})
	plateFrame.UnitFrame.castBar.FrameOverlay:SetBackdropBorderColor (1, 1, 1, 0)
	
	plateFrame.UnitFrame.castBar.FrameOverlay.TargetName = plateFrame.UnitFrame.castBar.FrameOverlay:CreateFontString (nil, "overlay", "GameFontNormal")
	
	--castbar percent, now anchored on the frame overlay so it'll be above the spell name and the cast bar it self
	local percentText = plateFrame.UnitFrame.castBar.FrameOverlay:CreateFontString (nil, "overlay", "GameFontNormal")
	percentText:SetPoint ("right", plateFrame.UnitFrame.castBar, "right")
	plateFrame.UnitFrame.castBar.percentText = percentText
	
	--non interruptible cast shield
	plateFrame.UnitFrame.castBar.BorderShield:SetTexture ([[Interface\ACHIEVEMENTFRAME\UI-Achievement-Progressive-IconBorder]])
	plateFrame.UnitFrame.castBar.BorderShield:SetTexCoord (5/64, 37/64, 1/64, 36/64)
	plateFrame.UnitFrame.castBar.isNamePlate = true
	plateFrame.UnitFrame.castBar.ThrottleUpdate = 0

	--indicators
	plateFrame.IconIndicators = {}
	
	--default string to show the name
	plateFrame.UnitFrame.name:ClearAllPoints()
	plateFrame.UnitFrame.name:SetPoint ("top", plateFrame.UnitFrame.healthBar, "bottom", 0, 0)
	plateFrame.UnitFrame.name:SetPoint ("center", plateFrame.UnitFrame.healthBar, "center")
	
	--flash aggro
	Plater.CreateAggroFlashFrame (plateFrame)
	plateFrame.playerHasAggro = false
	
	--border frame
	DF:CreateBorderWithSpread (plateFrame.UnitFrame.healthBar, .4, .2, .05, 1, 0.5)
	
	--focus
	local focusIndicator = healthBar:CreateTexture (nil, "overlay")
	focusIndicator:SetPoint ("topleft", healthBar, "topleft", 0, 0)
	focusIndicator:SetPoint ("bottomright", healthBar, "bottomright", 0, 0)
	focusIndicator:Hide()
	plateFrame.FocusIndicator = focusIndicator
	plateFrame.UnitFrame.FocusIndicator = focusIndicator
	
	--low aggro warning
	plateFrame.UnitFrame.aggroGlowUpper = plateFrame:CreateTexture (nil, "background", -4)
	plateFrame.UnitFrame.aggroGlowUpper:SetPoint ("bottomleft", plateFrame.UnitFrame.healthBar, "topleft", -3, 0)
	plateFrame.UnitFrame.aggroGlowUpper:SetPoint ("bottomright", plateFrame.UnitFrame.healthBar, "topright", 3, 0)
	plateFrame.UnitFrame.aggroGlowUpper:SetTexture ([[Interface\BUTTONS\UI-Panel-Button-Glow]])
	plateFrame.UnitFrame.aggroGlowUpper:SetTexCoord (0, 95/128, 0, 9/64)
	plateFrame.UnitFrame.aggroGlowUpper:SetBlendMode ("ADD")
	plateFrame.UnitFrame.aggroGlowUpper:SetHeight (4)
	plateFrame.UnitFrame.aggroGlowUpper:Hide()
	
	plateFrame.UnitFrame.aggroGlowLower = plateFrame:CreateTexture (nil, "background", -4)
	plateFrame.UnitFrame.aggroGlowLower:SetPoint ("topleft", plateFrame.UnitFrame.healthBar, "bottomleft", -3, 0)
	plateFrame.UnitFrame.aggroGlowLower:SetPoint ("topright", plateFrame.UnitFrame.healthBar, "bottomright", 3, 0)
	plateFrame.UnitFrame.aggroGlowLower:SetTexture ([[Interface\BUTTONS\UI-Panel-Button-Glow]])
	plateFrame.UnitFrame.aggroGlowLower:SetTexCoord (0, 95/128, 30/64, 38/64)
	plateFrame.UnitFrame.aggroGlowLower:SetBlendMode ("ADD")
	plateFrame.UnitFrame.aggroGlowLower:SetHeight (4)
	plateFrame.UnitFrame.aggroGlowLower:Hide()
	
end

function Plater.CanShowPlateFor (actorType)
	return DB_PLATE_CONFIG [actorType].enabled
end

Plater ["NAME_PLATE_UNIT_ADDED"] = function (self, event, unitBarId) -- ~added ãdded
	--pega a nameplate deste jogador
	
	local plateFrame = C_NamePlate.GetNamePlateForUnit (unitBarId)
	if (not plateFrame) then
		return
	end
	
	--save the last unit type shown in this plate
	plateFrame.PreviousUnitType = plateFrame.actorType
	
	--caching frames
	local unitFrame = plateFrame.UnitFrame
	local castBar = unitFrame.castBar
	local healthBar = unitFrame.healthBar
	
	--use our own classification icons
	unitFrame.ClassificationFrame:Hide()

	--clear values
	plateFrame.CurrentUnitNameString = plateFrame.actorName
	plateFrame.isSelf = nil
	plateFrame.PlayerCannotAttack = nil
	plateFrame.playerGuildName = nil
	plateFrame [MEMBER_NOCOMBAT] = nil
	plateFrame [MEMBER_NPCID] = nil
	
	--cache values
	plateFrame [MEMBER_GUID] = UnitGUID (unitBarId) or ""
	plateFrame [MEMBER_NAME] = UnitName (unitBarId) or ""
	plateFrame [MEMBER_NAMELOWER] = lower (plateFrame [MEMBER_NAME])
	plateFrame [MEMBER_CLASSIFICATION] = UnitClassification (plateFrame [unitBarId])
	
	--get and format the reaction to always be the value of the constants, then cache the reaction in some widgets for performance
	local reaction = UnitReaction (unitBarId, "player") or 1
	reaction = reaction <= UNITREACTION_HOSTILE and UNITREACTION_HOSTILE or reaction >= UNITREACTION_FRIENDLY and UNITREACTION_FRIENDLY or UNITREACTION_NEUTRAL
	
	plateFrame [MEMBER_REACTION] = reaction
	unitFrame [MEMBER_REACTION] = reaction
	unitFrame.BuffFrame [MEMBER_REACTION] = reaction
	unitFrame.BuffFrame2 [MEMBER_REACTION] = reaction
	unitFrame.BuffFrame2.unit = unitBarId
	
	if (Plater.CanOverrideColor) then
		Plater.ColorOverrider (unitFrame)
	else
		--reset the nameplate color to default
		healthBar.R, healthBar.G, healthBar.B = healthBar.r, healthBar.g, healthBar.b
		healthBar.barTexture:SetVertexColor (healthBar.R, healthBar.G, healthBar.B)
	end
	
	--health amount
	healthBar.CurrentHealth = UnitHealth (unitBarId)
	healthBar.CurrentHealthMax = UnitHealthMax (unitBarId)
	healthBar.IsAnimating = false
	healthBar:SetValue (healthBar.CurrentHealth)
	
	if (not CONST_USE_HEALTHCUTOFF) then
		healthBar.healthCutOff:Hide()
		healthBar.executeRange:Hide()
		healthBar.ExecuteGlowUp:Hide()
		healthBar.ExecuteGlowDown:Hide()
	end
	
	local actorType
	
	if (unitFrame.unit) then
		if (UnitIsUnit (unitBarId, "player")) then
			plateFrame.isSelf = true
			actorType = ACTORTYPE_PLAYER
			plateFrame.NameAnchor = 0
			plateFrame.PlateConfig = DB_PLATE_CONFIG.player
			Plater.UpdatePlateFrame (plateFrame, ACTORTYPE_PLAYER, nil, true)
		else
			if (UnitIsPlayer (unitBarId)) then
				--unit is a player
				plateFrame.playerGuildName = GetGuildInfo (unitBarId)
				
				if (reaction >= UNITREACTION_FRIENDLY) then
					plateFrame.NameAnchor = DB_NAME_PLAYERFRIENDLY_ANCHOR
					plateFrame.PlateConfig = DB_PLATE_CONFIG.friendlyplayer
					Plater.UpdatePlateFrame (plateFrame, ACTORTYPE_FRIENDLY_PLAYER, nil, true)
					actorType = ACTORTYPE_FRIENDLY_PLAYER
					if (DB_CASTBAR_HIDE_FRIENDLY) then
						CastingBarFrame_SetUnit (castBar, nil, nil, nil)
					end
				else
					plateFrame.NameAnchor = DB_NAME_PLAYERENEMY_ANCHOR
					plateFrame.PlateConfig = DB_PLATE_CONFIG.enemyplayer
					Plater.UpdatePlateFrame (plateFrame, ACTORTYPE_ENEMY_PLAYER, nil, true)
					actorType = ACTORTYPE_ENEMY_PLAYER
					if (DB_CASTBAR_HIDE_ENEMIES) then
						CastingBarFrame_SetUnit (castBar, nil, nil, nil)
					end
				end
			else
				--the unit is a npc
				Plater.GetNpcID (plateFrame)	
				
				if (reaction >= UNITREACTION_FRIENDLY) then
					plateFrame.NameAnchor = DB_NAME_NPCFRIENDLY_ANCHOR
					plateFrame.PlateConfig = DB_PLATE_CONFIG.friendlynpc
					Plater.UpdatePlateFrame (plateFrame, ACTORTYPE_FRIENDLY_NPC, nil, true)
					actorType = ACTORTYPE_FRIENDLY_NPC
					if (DB_CASTBAR_HIDE_FRIENDLY) then
						CastingBarFrame_SetUnit (castBar, nil, nil, nil)
					end
				else
					--includes neutral npcs
					plateFrame.PlayerCannotAttack = not UnitCanAttack ("player", unitBarId)
					plateFrame.NameAnchor = DB_NAME_NPCENEMY_ANCHOR
					plateFrame.PlateConfig = DB_PLATE_CONFIG.enemynpc
					Plater.UpdatePlateFrame (plateFrame, ACTORTYPE_ENEMY_NPC, nil, true)
					actorType = ACTORTYPE_ENEMY_NPC
					if (DB_CASTBAR_HIDE_ENEMIES) then
						CastingBarFrame_SetUnit (castBar, nil, nil, nil)
					end
				end
			end
		end
	end
	
	--icone da cast bar
	castBar.Icon:ClearAllPoints()
	castBar.Icon:SetPoint ("left", castBar, "left", 0, 0)
	castBar.BorderShield:ClearAllPoints()
	castBar.BorderShield:SetPoint ("left", castBar, "left", 0, 0)
	
	--esconde os glow de aggro
	unitFrame.aggroGlowUpper:Hide()
	unitFrame.aggroGlowLower:Hide()
	
	--can check aggro
	-- or PET_CACHE [self:GetParent() [MEMBER_GUID]] or self.displayedUnit:match ("pet%d$")
	unitFrame.CanCheckAggro = unitFrame.displayedUnit == unitBarId and actorType == ACTORTYPE_ENEMY_NPC
	
	--tick
	plateFrame.OnTickFrame.ThrottleUpdate = DB_TICK_THROTTLE
	plateFrame.OnTickFrame.actorType = actorType
	plateFrame.OnTickFrame.unit = plateFrame [MEMBER_UNITID]
	plateFrame.OnTickFrame:SetScript ("OnUpdate", EventTickFunction)
	EventTickFunction (plateFrame.OnTickFrame, 10)
	
	--one tick update
	plateFrame.OnNextTickUpdate.actorType = actorType
	plateFrame.OnNextTickUpdate.unit = plateFrame [MEMBER_UNITID]
	
	--highlight check
	if (DB_HOVER_HIGHLIGHT and not plateFrame.PlayerCannotAttack and (actorType ~= ACTORTYPE_FRIENDLY_PLAYER and actorType ~= ACTORTYPE_FRIENDLY_NPC and not plateFrame.isSelf)) then
		unitFrame.HighlightFrame:Show()
		unitFrame.HighlightFrame.unit = plateFrame [MEMBER_UNITID]
		unitFrame.HighlightFrame:SetScript ("OnUpdate", Plater.CheckHighlight)
	else
		unitFrame.HighlightFrame:SetScript ("OnUpdate", nil)
		unitFrame.HighlightFrame:Hide()
	end
	
	--range
	Plater.CheckRange (plateFrame, true)
	
end

function Plater.UpdateUseClassColors()
	for index, plateFrame in ipairs (Plater.GetAllShownPlates()) do
		Plater.Execute (CUF_Name, Plater.DriverFuncNames ["OnChangeHealthConfig"], plateFrame.UnitFrame)
	end
end

function Plater.UpdateUseCastBar()
	Plater.RefreshDBUpvalues()
end

-- ~removed
Plater ["NAME_PLATE_UNIT_REMOVED"] = function (self, event, unitBarId)
	local plateFrame = C_NamePlate.GetNamePlateForUnit (unitBarId)
	
	plateFrame.OnTickFrame:SetScript ("OnUpdate", nil)
	plateFrame.UnitFrame.HighlightFrame:SetScript ("OnUpdate", nil)
	
	plateFrame [MEMBER_QUEST] = false
	
	local healthFrame = plateFrame.UnitFrame.healthBar
	if (healthFrame.TargetHeight) then
		healthFrame:SetHeight (healthFrame.TargetHeight)
	end
	healthFrame.IsIncreasingHeight = nil
	healthFrame.IsDecreasingHeight = nil
	
	--hide the highlight
	--is mouse over ~highlight ~mouseover
	plateFrame.UnitFrame.HighlightFrame:Hide()
	plateFrame.UnitFrame.HighlightFrame.Shown = false
	
	--> check if is running any script
	plateFrame.UnitFrame:OnHideWidget()
	plateFrame.UnitFrame.castBar:OnHideWidget()
	for _, auraIconFrame in ipairs (plateFrame.UnitFrame.BuffFrame.PlaterBuffList) do
		auraIconFrame:OnHideWidget()
	end
	for _, auraIconFrame in ipairs (plateFrame.UnitFrame.BuffFrame2.PlaterBuffList) do
		auraIconFrame:OnHideWidget()
	end
end

function Plater.DoNameplateAnimation (plateFrame, frameAnimations, spellName, isCritical)
	for animationIndex, animationTable in ipairs (frameAnimations) do
		if ((animationTable.animationCooldown [plateFrame] or 0) < GetTime()) then
			--animation "scale" is pre constructed when the nameplate frame is created
			if (animationTable.animation_type == "scale") then
				--get the animation
				local animationHub = plateFrame.SpellAnimations ["scale"]

				--duration
				animationHub.ScaleUp:SetDuration (animationTable.duration)
				animationHub.ScaleDown:SetDuration (animationTable.duration)
				
				local scaleUpX, scaleUpY = animationTable.scale_upX, animationTable.scale_upY
				local scaleDownX, scaleDownY = animationTable.scale_downX, animationTable.scale_downY
				
				animationHub.ScaleUp:SetFromScale (1, 1)
				animationHub.ScaleUp:SetToScale (scaleUpX, scaleUpY)
				animationHub.ScaleDown:SetFromScale (1, 1)
				animationHub.ScaleDown:SetToScale (scaleDownX, scaleDownY)
				
				--play it
				animationHub:Play()
				animationTable.animationCooldown [plateFrame] = GetTime() + animationTable.cooldown
				
			elseif (animationTable.animation_type == "frameshake") then
				--get the animation
				local frameShake = plateFrame.SpellAnimations ["frameshake" .. spellName]
				local shakeTargetFrame = plateFrame.UnitFrame
				
				if (not frameShake) then
					local points = {}
		
					for i = 1, shakeTargetFrame:GetNumPoints() do
						local p1, p2, p3, p4, p5 = shakeTargetFrame:GetPoint (i)
						points [#points+1] = {p1, p2, p3, p4, p5}
					end
				
					frameShake = DF:CreateFrameShake (shakeTargetFrame, animationTable.duration, animationTable.amplitude, animationTable.frequency, animationTable.absolute_sineX, animationTable.absolute_sineY, animationTable.scaleX, animationTable.scaleY, animationTable.fade_in, animationTable.fade_out, points)
					plateFrame.SpellAnimations ["frameshake" .. spellName] = frameShake
				end
				
				local animationScale = Plater.db.profile.spell_animations_scale
				
				if (isCritical and animationTable.critical_scale) then
					animationScale = animationScale * animationTable.critical_scale
					shakeTargetFrame:PlayFrameShake (frameShake, animationScale, animationScale, animationScale, DF:Clamp (0.75, 1.75, animationScale)) --, animationScale
				else
					--scaleDirection, scaleAmplitude, scaleFrequency, scaleDuration
					shakeTargetFrame:PlayFrameShake (frameShake, animationScale, animationScale, animationScale, DF:Clamp (0.75, 1.75, animationScale)) --, animationScale
				end
				
				animationTable.animationCooldown [plateFrame] = GetTime() + animationTable.cooldown
			end
		end
	end
end

local PlaterCLEUParser = CreateFrame ("frame", "PlaterCLEUParserFrame", UIParent)

local parserFunctions = {
	SPELL_DAMAGE = function (time, token, hidding, sourceGUID, sourceName, sourceFlag, sourceFlag2, targetGUID, targetName, targetFlag, targetFlag2, spellID, spellName, spellType, amount, overKill, school, resisted, blocked, absorbed, isCritical)
		if (SPELL_WITH_ANIMATIONS [spellName] and sourceGUID == Plater.PlayerGUID) then
			for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
				if (plateFrame [MEMBER_GUID] == targetGUID) then
					Plater.DoNameplateAnimation (plateFrame, SPELL_WITH_ANIMATIONS [spellName], spellName, isCritical)
				end
			end
		end
	end,
	
	SPELL_SUMMON = function (time, token, hidding, sourceGUID, sourceName, sourceFlag, sourceFlag2, targetGUID, targetName, targetFlag, targetFlag2, spellID, spellName, spellType, amount, overKill, school, resisted, blocked, absorbed, isCritical)
		if (sourceFlag and CompareBit (sourceFlag, 0x00003000) ~= 0) then
			PET_CACHE [sourceGUID] = time
			
		elseif (targetFlag and CompareBit (targetFlag, 0x00003000) ~= 0) then
			PET_CACHE [targetGUID] = time
		end
	end,
	
	SPELL_INTERRUPT = function (time, token, hidding, sourceGUID, sourceName, sourceFlag, sourceFlag2, targetGUID, targetName, targetFlag, targetFlag2, spellID, spellName, spellType, amount, overKill, school, resisted, blocked, absorbed, isCritical)
		for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
			if (plateFrame.UnitFrame.castBar:IsShown()) then
				if (plateFrame.UnitFrame.castBar.Text:GetText() == INTERRUPTED) then
					if (plateFrame [MEMBER_GUID] == targetGUID) then
						plateFrame.UnitFrame.castBar.Text:SetText (INTERRUPTED .. " [" .. Plater.SetTextColorByClass (sourceName, sourceName) .. "]")
						plateFrame.UnitFrame.castBar.IsInterrupted = true
						--> check and stop the casting script if any
						plateFrame.UnitFrame.castBar:OnHideWidget()
					end
				end
			end
		end
	end,
	
	SPELL_CAST_SUCCESS = function (time, token, hidding, sourceGUID, sourceName, sourceFlag, sourceFlag2, targetGUID, targetName, targetFlag, targetFlag2, spellID, spellName, spellType, amount, overKill, school, resisted, blocked, absorbed, isCritical)
		if (sourceFlag and CompareBit (sourceFlag, 0x00000060) ~= 0) then
			if (not DB_CAPTURED_SPELLS [spellID]) then
				DB_CAPTURED_SPELLS [spellID] = {event = token, source = sourceName, npcID = Plater:GetNpcIdFromGuid (sourceGUID or ""), encounterID = Plater.CurrentEncounterID}
			end
		end
	end,
	
	--[=[
	SPELL_AURA_APPLIED = function (time, token, hidding, sourceGUID, sourceName, sourceFlag, sourceFlag2, targetGUID, targetName, targetFlag, targetFlag2, spellID, spellName, spellType, amount, overKill, school, resisted, blocked, absorbed, isCritical)
		if (sourceFlag and CompareBit (sourceFlag, 0x00000060) ~= 0) then
			local auraType = amount
			if (not DB_CAPTURED_SPELLS [spellID]) then
				DB_CAPTURED_SPELLS [spellID] = {event = token, source = sourceName, type = auraType, npcID = Plater:GetNpcIdFromGuid (sourceGUID or ""), encounterID = Plater.CurrentEncounterID}
			end
		end
	end,
	--]=]
}

PlaterCLEUParser.Parser = function (self)
	local time, token, hidding, sourceGUID, sourceName, sourceFlag, sourceFlag2, targetGUID, targetName, targetFlag, targetFlag2, spellID, spellName, spellType, amount, overKill, school, resisted, blocked, absorbed, isCritical = CombatLogGetCurrentEventInfo()
	local func = parserFunctions [token]
	if (func) then
		return func (time, token, hidding, sourceGUID, sourceName, sourceFlag, sourceFlag2, targetGUID, targetName, targetFlag, targetFlag2, spellID, spellName, spellType, amount, overKill, school, resisted, blocked, absorbed, isCritical)
	end
end

PlaterCLEUParser:SetScript ("OnEvent", PlaterCLEUParser.Parser)
PlaterCLEUParser:RegisterEvent ("COMBAT_LOG_EVENT_UNFILTERED")

C_Timer.NewTicker (180, function()
	local now = time()
	for guid, time in pairs (PET_CACHE) do
		if (time+180 < now) then
			PET_CACHE [guid] = nil
		end
	end
end)

function Plater.ShutdownInterfaceOptionsPanel()
	local frames = {
		InterfaceOptionsNamesPanelUnitNameplates,
		InterfaceOptionsNamesPanelUnitNameplatesFriendsText,
		InterfaceOptionsNamesPanelUnitNameplatesEnemies,
		InterfaceOptionsNamesPanelUnitNameplatesPersonalResource,
		InterfaceOptionsNamesPanelUnitNameplatesPersonalResourceOnEnemy,
		InterfaceOptionsNamesPanelUnitNameplatesMakeLarger,
		InterfaceOptionsNamesPanelUnitNameplatesShowAll,
		InterfaceOptionsNamesPanelUnitNameplatesAggroFlash,
		InterfaceOptionsNamesPanelUnitNameplatesFriendlyMinions,
		InterfaceOptionsNamesPanelUnitNameplatesEnemyMinions,
		InterfaceOptionsNamesPanelUnitNameplatesEnemyMinus,
		InterfaceOptionsNamesPanelUnitNameplatesMotionDropDown,
	}

	for _, frame in ipairs (frames) do
		frame:Hide()
	end
	
	InterfaceOptionsNamesPanelUnitNameplatesMakeLarger.setFunc = function() end
	
	local f = CreateFrame ("frame", nil, InterfaceOptionsNamesPanel)
	f:SetSize (300, 200)
	f:SetPoint ("topleft", InterfaceOptionsNamesPanel, "topleft", 10, -240)
	
	local open_options = function()
		InterfaceOptionsFrame:Hide()
		--GameMenuFrame:Hide()
		Plater.OpenOptionsPanel()
	end
	
	local Button = DF:CreateButton (f, open_options, 100, 20, "", -1, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"))
	Button:SetPoint ("topleft", f, "topleft", 10, 0)
	Button:SetText ("Open Plater Options")
	Button:SetIcon ([[Interface\BUTTONS\UI-OptionsButton]], 18, 18, "overlay", {0, 1, 0, 1})
	
	local Label = DF:CreateLabel (f, "Where are the Nameplate options?\n- Open Plater options, they are at the top left.")
	Label:SetPoint ("bottomleft", Button, "topleft", 0, 2)
end

--elseof
local run_SetCVarsOnFirstRun = function()
	Plater.SetCVarsOnFirstRun()
end
function Plater.SetCVarsOnFirstRun()

	if (InCombatLockdown()) then
		C_Timer.After (1, run_SetCVarsOnFirstRun)
		return
	end

	--> these are the cvars set for each character when they logon
	
	--disabled:
		--SetCVar ("nameplateShowSelf", CVAR_DISABLED)
		--SetCVar (CVAR_RESOURCEONTARGET, CVAR_DISABLED)
		--SetCVar (CVAR_FRIENDLY_ALL, CVAR_ENABLED)
	--> location of the personal bar
	--	SetCVar ("nameplateSelfBottomInset", 20 / 100)
	--	SetCVar ("nameplateSelfTopInset", abs (20 - 99) / 100)
	
	--> set the stacking to true
	SetCVar (CVAR_PLATEMOTION, CVAR_ENABLED)
	
	--> make nameplates always shown and down't show minions
	SetCVar (CVAR_SHOWALL, CVAR_ENABLED)
	SetCVar (CVAR_AGGROFLASH, CVAR_ENABLED)
	SetCVar (CVAR_ENEMY_MINIONS, CVAR_ENABLED)
	SetCVar (CVAR_ENEMY_MINUS, CVAR_ENABLED)
	SetCVar (CVAR_FRIENDLY_GUARDIAN, CVAR_DISABLED)
	SetCVar (CVAR_FRIENDLY_PETS, CVAR_DISABLED)
	SetCVar (CVAR_FRIENDLY_TOTEMS, CVAR_DISABLED)
	SetCVar (CVAR_FRIENDLY_MINIONS, CVAR_DISABLED)
	
	--> make it show the class color of players
	SetCVar (CVAR_CLASSCOLOR, CVAR_ENABLED)
	
	--> just reset to default the clamp from the top side
	SetCVar (CVAR_CEILING, 0.075)

	--> reset the horizontal and vertical scale
	SetCVar (CVAR_SCALE_HORIZONTAL, CVAR_ENABLED)
	SetCVar (CVAR_SCALE_VERTICAL, CVAR_ENABLED)
	
	--> make the selection be a little bigger
	SetCVar ("nameplateSelectedScale", 1.15)
	
	--> distance between each nameplate when using stacking
	SetCVar ("nameplateOverlapV", 1.25)
	
	--> movement speed of nameplates when using stacking, going above this isn't recommended
	SetCVar (CVAR_MOVEMENT_SPEED, 0.05)
	--> this must be 1 for bug reasons on the game client
	SetCVar ("nameplateOccludedAlphaMult", 1)
	--> don't show friendly npcs
	SetCVar ("nameplateShowFriendlyNPCs", 0)
	--> make the personal bar hide very fast
	SetCVar ("nameplatePersonalHideDelaySeconds", 0.2)
	


	--> view distance
	SetCVar (CVAR_CULLINGDISTANCE, 100)
	
	--> try to restore cvars from the profile
	local savedCVars = Plater.db and Plater.db.profile and Plater.db.profile.saved_cvars
	if (savedCVars) then
		for CVarName, CVarValue in pairs (savedCVars) do
			SetCVar (CVarName, CVarValue)
		end
		if (PlaterOptionsPanelFrame) then
			PlaterOptionsPanelFrame.RefreshOptionsFrame()
		end
	end
	
	PlaterDBChr.first_run2 [UnitGUID ("player")] = true
	Plater.db.profile.first_run2 = true
	
	Plater:ZONE_CHANGED_NEW_AREA()
	
	InterfaceOptionsNamesPanelUnitNameplatesMakeLarger:Click()
	InterfaceOptionsNamesPanelUnitNameplatesPersonalResource:Click()
	InterfaceOptionsNamesPanelUnitNameplatesPersonalResource:Click()
	Plater.ShutdownInterfaceOptionsPanel()

	--[=[
		--> override settings based on the class
		local _, unitClass = UnitClass ("player")
		
		if (unitClass == "WARRIOR") then
			--warrior doesn't have good spells to chech the range
			--settings the view distance of nameplates to 40 and the alpha for range change is always 100%
			SetCVar (CVAR_CULLINGDISTANCE, 40)
			Plater.db.profile.range_check_alpha = 100
			
			print ("Plater Debug - Special Settings for Warrior Applied")
		end	
	--]=]

	--Plater:Msg ("has installed custom CVars values, it is ready to work!")
end

function Plater:PLAYER_LOGOUT()
	--be safe, don't break shit
	--SetCVar (CVAR_CULLINGDISTANCE, 60)
end

function Plater.OpenFeedbackWindow()
	if (not Plater.report_window) then
		local w = CreateFrame ("frame", "PlaterBugReportWindow", UIParent)
		w:SetFrameStrata ("TOOLTIP")
		w:SetSize (300, 50)
		w:SetPoint ("center", UIParent, "center")
		tinsert (UISpecialFrames, "PlaterBugReportWindow")
		Plater.report_window = w
		
		local editbox = DF:CreateTextEntry (w, function()end, 280, 20)
		w.editbox = editbox
		editbox:SetPoint ("center", w, "center")
		editbox:SetAutoFocus (false)
		
		editbox:SetHook ("OnEditFocusGained", function() 
			editbox.text = "http://us.battle.net/wow/en/forum/topic/20744134351#1"
			editbox:HighlightText()
		end)
		editbox:SetHook ("OnEditFocusLost", function() 
			w:Hide()
		end)
		editbox:SetHook ("OnChar", function() 
			editbox.text = "http://us.battle.net/wow/en/forum/topic/20744134351#1"
			editbox:HighlightText()
		end)
		editbox.text = "http://us.battle.net/wow/en/forum/topic/20744134351#1"
		
		function Plater:ReportWindowSetFocus()
			if (PlaterBugReportWindow:IsShown()) then
				PlaterBugReportWindow:Show()
				PlaterBugReportWindow.editbox:SetFocus()
				PlaterBugReportWindow.editbox:HighlightText()
			end
		end
	end
	
	PlaterBugReportWindow:Show()
	C_Timer.After (1, Plater.ReportWindowSetFocus)
end


SLASH_PLATER1 = "/plater"
SLASH_PLATER2 = "/nameplate"
SLASH_PLATER3 = "/nameplates"

-- ~cvar
local cvarDiagList = {
	"nameplateMaxDistance",
	"nameplateOtherTopInset",
	"nameplateOtherAtBase",
	"nameplateMinAlpha",
	"nameplateMinAlphaDistance",
	"nameplateShowAll",
	"nameplateShowEnemies",
	"nameplateShowEnemyMinions",
	"nameplateShowEnemyMinus",
	"nameplateShowFriends",
	"nameplateShowFriendlyGuardians",
	"nameplateShowFriendlyPets",
	"nameplateShowFriendlyTotems",
	"nameplateShowFriendlyMinions",
	"NamePlateHorizontalScale",
	"NamePlateVerticalScale",
}
function SlashCmdList.PLATER (msg, editbox)
	if (msg == "dignostico" or msg == "diag" or msg == "debug") then
		
		print ("Plater Diagnostic:")
		for i = 1, #cvarDiagList do
			local cvar = cvarDiagList [i]
			print ("|cFFC0C0C0" .. cvar, "|r->", GetCVar (cvar))
		end
		
		local alphaPlateFrame = "there's no nameplate in the screen"
		local alphaUnitFrame = ""
		local alphaHealthFrame = ""
		local testPlate
		
		for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
			if (plateFrame [MEMBER_REACTION] < 4) then
				testPlate = plateFrame
				alphaPlateFrame = plateFrame:GetAlpha()
				alphaUnitFrame = plateFrame.UnitFrame:GetAlpha()
				alphaHealthFrame = plateFrame.UnitFrame.healthBar:GetAlpha()
				break
			end
		end
		
		print ("|cFFC0C0C0Alpha|r", "->", alphaPlateFrame, "-", alphaUnitFrame, "-", alphaHealthFrame)
		
		if (testPlate) then
			local w, h = testPlate:GetSize()
			print ("|cFFC0C0C0Size|r", "->", w, h, "-", testPlate.UnitFrame.healthBar:GetSize())
			
			local point1, anchorFrame, point2, x, y = testPlate:GetPoint (1)
			print ("|cFFC0C0C0Point|r", "->", point1, anchorFrame:GetName(), point2, x, y)
			
			local plateIsShown = testPlate:IsShown() and "yes" or "no"
			local unitFrameIsShown = testPlate.UnitFrame:IsShown() and "yes" or "no"
			local healthBarIsShown = testPlate.UnitFrame.healthBar:IsShown() and "yes" or "no"
			print ("|cFFC0C0C0ShownStatus|r", "->", plateIsShown, "-", unitFrameIsShown, "-", healthBarIsShown)
		else
			print ("|cFFC0C0C0Size|r", "-> there's no nameplate in the screen")
			print ("|cFFC0C0C0Point|r", "-> there's no nameplate in the screen")
			print ("|cFFC0C0C0ShownStatus|r", "-> there's no nameplate in the screen")
		end
		
		return
	end
	Plater.OpenOptionsPanel()
end

--black list npcs to not show when showing friendly npcs
local ignored_npcs_when_profession = {
	[32751] = true, --warp huntress pet - Dalaran
	[110571] = 1, --delas mooonfang - Dalaran
	[113199] = true, --delas's pet - Dalaran
	[110018] = 1, --gazrix gearlock - Dalaran
	[107622] = true, --glutonia - Dalaran
	[106263] = 1, --earthen ring shaman - Dalaran
	[106262] = 1, --earthen ring shaman - Dalaran
	[97141] = true, --koraud - Dalaran
}

function Plater.IsIgnored (plateFrame, onlyProfession)
	if (onlyProfession) then
		local npcId = plateFrame [MEMBER_NPCID]
		if (not npcId) then
			return
		end
		if (ignored_npcs_when_profession [npcId]) then
			return true
		end
	end
end

function Plater.GetNpcID (plateFrame)
	local npcId = plateFrame [MEMBER_GUID]
	if (npcId and npcId ~= "") then
		npcId = select (6, strsplit ("-", npcId))
		if (npcId) then
			npcId = tonumber (npcId)
		else
			return
		end
	else
		return
	end
	
	if (not npcId) then
		return
	end
	
	plateFrame [MEMBER_NPCID] = npcId
end

function Plater.SetTextColorByClass (unit, text)
	local _, class = UnitClass (unit)
	if (class) then
		local color = RAID_CLASS_COLORS [class]
		if (color) then
			text = "|c" .. color.colorStr .. DF:RemoveRealName (text) .. "|r"
		end
	end
	return text
end

Plater.SpecList = {
	["DEMONHUNTER"] = {
		[577] = true, 
		[581] = true,
	},
	["DEATHKNIGHT"] = {
		[250] = true,
		[251] = true,
		[252] = true,
	},
	["WARRIOR"] = {
		[71] = true,
		[72] = true,
		[73] = true,
	},
	["MAGE"] = {
		[62] = true,
		[63] = true,
		[64] = true,
	},
	["ROGUE"] = {
		[259] = true,
		[260] = true,		
		[261] = true,
	},
	["DRUID"] = {
		[102] = true,
		[103] = true,
		[104] = true,
		[105] = true,
	},
	["HUNTER"] = {
		[253] = true,
		[254] = true,		
		[255] = true,
	},
	["SHAMAN"] = {
		[262] = true,
		[263] = true,
		[264] = true,
	},
	["PRIEST"] = {
		[256] = true,
		[257] = true,
		[258] = true,
	},
	["WARLOCK"] = {
		[265] = true,
		[266] = true,
		[267] = true,
	},
	["PALADIN"] = {
		[65] = true,
		[66] = true,
		[70] = true,
	},
	["MONK"] = {
		[268] = true, 
		[269] = true, 
		[270] = true, 
	},
}

local re_GetSpellForRangeCheck = function()
	Plater.GetSpellForRangeCheck()
end
function Plater.GetSpellForRangeCheck()
	Plater.SpellBookForRangeCheck = nil
	local specIndex = GetSpecialization()
	if (specIndex) then
		local specID = GetSpecializationInfo (specIndex)
		if (specID and specID ~= 0) then
			Plater.SpellForRangeCheck = PlaterDBChr.spellRangeCheck [specID]
			
			--attempt ot get the spellbook slot for this spell
			for i = 1, GetNumSpellTabs() do
				local name, texture, offset, numEntries, isGuild, offspecID = GetSpellTabInfo (i)
				
				--is the tab enabled?
				if (offspecID == 0) then
					for slotIndex = offset, offset + numEntries - 1 do
						local skillType, spellID = GetSpellBookItemInfo (slotIndex, BOOKTYPE_SPELL)
						if (skillType == "SPELL" or skillType == "FUTURESPELL") then
							local spellName = GetSpellInfo (spellID)
							if (spellName == Plater.SpellForRangeCheck) then
								Plater.SpellForRangeCheck = FindSpellBookSlotBySpellID (spellID)
								Plater.SpellBookForRangeCheck = skillType
								break
							end
						end
					end
				end
			end
		else
		 	C_Timer.After (5, re_GetSpellForRangeCheck)
		end
	else
		C_Timer.After (5, re_GetSpellForRangeCheck)
	end
end

-- ~range
Plater.DefaultSpellRangeList = {
	-- 185245 spellID for Torment, it is always failing to check range with IsSpellInRange()
	[577] = 278326, --> havoc demon hunter - Consume Magic
	[581] = 278326, --> vengeance demon hunter - Consume Magic

	[250] = 56222, --> blood dk - dark command
	[251] = 56222, --> frost dk - dark command
	[252] = 56222, --> unholy dk - dark command
	
	[102] = 8921, -->  druid balance - Moonfire (45 yards)
	[103] = 8921, -->  druid feral - Moonfire (40 yards)
	[104] = 6795, -->  druid guardian - Growl
	[105] = 8921, -->  druid resto - Moonfire (40 yards)

	[253] = 193455, -->  hunter bm - Cobra Shot
	[254] = 19434, --> hunter marks - Aimed Shot
	[255] = 271788, --> hunter survivor - Serpent Sting
	
	[62] = 227170, --> mage arcane - arcane blast
	[63] = 133, --> mage fire - fireball
	[64] = 228597, --> mage frost - frostbolt
	
	[268] = 115546 , --> monk bm - Provoke
	[269] = 117952, --> monk ww - Crackling Jade Lightning (40 yards)
	[270] = 117952, --> monk mw - Crackling Jade Lightning (40 yards)
	
	[65] = 20473, --> paladin holy - Holy Shock (40 yards)
	[66] = 62124, --> paladin protect - Hand of Reckoning
	[70] = 62124, --> paladin ret - Hand of Reckoning
	
	[256] = 585, --> priest disc - Smite
	[257] = 585, --> priest holy - Smite
	[258] = 8092, --> priest shadow - Mind Blast
	
	[259] = 185565, --> rogue assassination - Poisoned Knife (30 yards)
	[260] = 185763, --> rogue outlaw - Pistol Shot (20 yards)
	[261] = 114014, --> rogue sub - Shuriken Toss (30 yards)

	[262] = 188196, --> shaman elemental - Lightning Bolt
	[263] = 187837, --> shaman enhancement - Lightning Bolt (instance cast)
	[264] = 403, --> shaman resto - Lightning Bolt

	[265] = 980, --> warlock aff - Agony
	[266] = 686, --> warlock demo - Shadow Bolt
	[267] = 116858, --> warlock destro - Chaos Bolt
	
	[71] = 355, --> warrior arms - Taunt
	[72] = 355, --> warrior fury - Taunt
	[73] = 355, --> warrior protect - Taunt
}

function Plater.CheckOptionsTab()
	if (Plater.LatestEncounter) then
		if (Plater.LatestEncounter + 60 > time()) then
			PlaterOptionsPanelContainer:SelectIndex (Plater, 11)
		end
	end
end

-- ~options õptions
function Plater.OpenOptionsPanel()
	
	if (PlaterOptionsPanelFrame) then
		PlaterOptionsPanelFrame:Show()
		Plater.CheckOptionsTab()
		return true
	end
	
	--pega os templates dos os widgets
	local options_text_template = DF:GetTemplate ("font", "OPTIONS_FONT_TEMPLATE")
	local options_dropdown_template = DF:GetTemplate ("dropdown", "OPTIONS_DROPDOWN_TEMPLATE")
	local options_switch_template = DF:GetTemplate ("switch", "OPTIONS_CHECKBOX_TEMPLATE")
	local options_slider_template = DF:GetTemplate ("slider", "OPTIONS_SLIDER_TEMPLATE")
	local options_button_template = DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE")
	
	Plater.db.profile.OptionsPanelDB = Plater.db.profile.OptionsPanelDB or {}
	
	--controi o menu principal
	local f = DF:CreateSimplePanel (UIParent, 1100, 610, "Plater Options", "PlaterOptionsPanelFrame", {UseScaleBar = true}, Plater.db.profile.OptionsPanelDB)
	f:SetFrameStrata ("MEDIUM")
	DF:ApplyStandardBackdrop (f)

	local profile = Plater.db.profile
	
	local CVarDesc = "\n\n|cFFFF7700[*]|r |cFFa0a0a0CVar, not saved within Plater profile and is a Per-Character setting.|r"
	local CVarIcon = "|cFFFF7700*|r"
	
	local frame_options = {
		y_offset = 0,
		button_width = 102,
		button_height = 20,
		button_x = 210,
		button_y = -7,
		button_text_size = 10,
	}
	
	-- mainFrame ï¿½ um frame vazio para sustentrar todos os demais frames, este frame sempre serï¿½ mostrado
	local mainFrame = DF:CreateTabContainer (f, "Plater Options", "PlaterOptionsPanelContainer", 
	{
		{name = "FrontPage", title = "General Settings"},
		{name = "ThreatConfig", title = "Threat / Aggro"},
		{name = "PersonalBar", title = "Personal Bar"},
		{name = "EnemyNpc", title = "Enemy Npc"},
		{name = "EnemyPlayer", title = "Enemy Player"},
		{name = "FriendlyNpc", title = "Friendly Npc"},
		{name = "FriendlyPlayer", title = "Friendly Player"},
		{name = "Automation", title = "Auto"},
		
		{name = "DebuffConfig", title = "Buff Settings"},
		{name = "DebuffBlacklist", title = "Buff Tracking"},
		{name = "DebuffLastEvent", title = "Buff Ease"},
		{name = "DebuffSpecialContainer", title = "Buff Special"},
		{name = "Scripting", title = "Scripting"},
		{name = "AdvancedConfig", title = "Advanced"},
		{name = "ProfileManagement", title = "Profiles"},
	}, 
	frame_options)
	
	--> when any setting is changed, call this function
	local globalCallback = function()
		Plater.IncreaseRefreshID()
		Plater.RefreshDBUpvalues()
		Plater.UpdateAllPlates()
	end

	--1st row
	local frontPageFrame = mainFrame.AllFrames [1]
	local threatFrame = mainFrame.AllFrames [2]
	local personalPlayerFrame = mainFrame.AllFrames [3]
	local enemyNPCsFrame = mainFrame.AllFrames [4]
	local enemyPCsFrame = mainFrame.AllFrames [5]
	local friendlyNPCsFrame = mainFrame.AllFrames [6]
	local friendlyPCsFrame = mainFrame.AllFrames [7]
	local autoFrame = mainFrame.AllFrames [8]
	
	--2nd row
	local auraOptionsFrame = mainFrame.AllFrames [9]
	local auraFilterFrame = mainFrame.AllFrames [10]
	local auraLastEventFrame = mainFrame.AllFrames [11]
	local auraSpecialFrame = mainFrame.AllFrames [12]
	local scriptingFrame = mainFrame.AllFrames [13]
	local advancedFrame = mainFrame.AllFrames [14]
	local profilesFrame = mainFrame.AllFrames [15]

	local generalOptionsAnchor = CreateFrame ("frame", "$parentOptionsAnchor", frontPageFrame)
	generalOptionsAnchor:SetSize (1, 1)
	generalOptionsAnchor:SetPoint ("topleft", frontPageFrame, "topleft", 10, -210)
	
	f.AllMenuFrames = {}
	for _, frame in ipairs (mainFrame.AllFrames) do
		tinsert (f.AllMenuFrames, frame)
	end
	tinsert (f.AllMenuFrames, generalOptionsAnchor)
	
	--> on profile change
	function f.RefreshOptionsFrame()
		for _, frame in ipairs (f.AllMenuFrames) do
			if (frame.RefreshOptions) then
				frame:RefreshOptions()
			end
		end
		Plater.UpdateMaxCastbarTextLength()
	end
	
	local startX, startY, heightSize = 10, -110, 670
	local mainStartX, mainStartY, mainHeightSize = 10, -280, 800
	
	--mostra o painel de profiles no menu de interface
	profilesFrame:SetScript ("OnShow", function()
		Plater:OpenInterfaceProfile()
		f:Hide()
		C_Timer.After (.5, function()
			mainFrame:SetIndex (1)
			mainFrame:SelectIndex (_, 1)
		end)
	end)
	
-------------------------
-- funï¿½ï¿½es gerais dos dropdowns
	local textures = LibSharedMedia:HashTable ("statusbar")

	--anchor table
	local anchor_names = {"Top Left", "Left", "Bottom Left", "Bottom", "Bottom Right", "Right", "Top Right", "Top", "Center", "Inner Left", "Inner Right", "Inner Top", "Inner Bottom"}
	local build_anchor_side_table = function (actorType, member)
		local t = {}
		for i = 1, 13 do
			tinsert (t, {
				label = anchor_names[i], 
				value = i, 
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
		return t
	end	
	--
	local health_bar_texture_selected = function (self, capsule, value)
		Plater.db.profile.health_statusbar_texture = value
		Plater.RefreshDBUpvalues()
		Plater.UpdateAllPlates()
	end
	local health_bar_texture_options = {}
	for name, texturePath in pairs (textures) do 
		health_bar_texture_options [#health_bar_texture_options + 1] = {value = name, label = name, statusbar = texturePath, onclick = health_bar_texture_selected}
	end
	table.sort (health_bar_texture_options, function (t1, t2) return t1.label < t2.label end)
	--
	local health_bar_bgtexture_selected = function (self, capsule, value)
		Plater.db.profile.health_statusbar_bgtexture = value
		Plater.RefreshDBUpvalues()
		Plater.UpdateAllPlates()
	end
	local health_bar_bgtexture_options = {}
	for name, texturePath in pairs (textures) do 
		health_bar_bgtexture_options [#health_bar_bgtexture_options + 1] = {value = name, label = name, statusbar = texturePath, onclick = health_bar_bgtexture_selected}
	end
	table.sort (health_bar_bgtexture_options, function (t1, t2) return t1.label < t2.label end)
	--
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
	local health_selection_overlay_selected = function (self, capsule, value)
		Plater.db.profile.health_selection_overlay = value
		Plater.UpdateAllPlates()
	end
	local health_selection_overlay_options = {}
	for name, texturePath in pairs (textures) do
		health_selection_overlay_options [#health_selection_overlay_options + 1] = {value = name, label = name, statusbar = texturePath, onclick = health_selection_overlay_selected}
	end
	table.sort (health_selection_overlay_options, function (t1, t2) return t1.label < t2.label end)
	--
	

-------------------------------------------------------------------------------
--opï¿½ï¿½es do painel de interface da blizzard


function Plater.ChangeNameplateAnchor (_, _, value)
	if (value == 0) then
		SetCVar (CVAR_ANCHOR, CVAR_ANCHOR_HEAD)
	elseif (value == 1) then
		SetCVar (CVAR_ANCHOR, CVAR_ANCHOR_BOTH)
	elseif (value == 2) then
		SetCVar (CVAR_ANCHOR, CVAR_ANCHOR_FEET)
	end
end
local nameplate_anchor_options = {
	{label = "Head", value = 0, onclick = Plater.ChangeNameplateAnchor, desc = "All nameplates are placed above the character."},
	{label = "Head/Feet", value = 1, onclick = Plater.ChangeNameplateAnchor, desc = "Friendly and neutral has the nameplate on their head, enemies below the feet."},
	{label = "Feet", value = 2, onclick = Plater.ChangeNameplateAnchor, desc = "All nameplates are placed below the character."},
}

local interface_options = {

		--{type = "label", get = function() return "Interface Options:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},

		{
			type = "toggle",
			get = function() return GetCVar ("nameplateShowSelf") == CVAR_ENABLED end,
			set = function (self, fixedparam, value) 
				if (not InCombatLockdown()) then
					SetCVar ("nameplateShowSelf", math.abs (tonumber (GetCVar ("nameplateShowSelf"))-1))
				else
					Plater:Msg ("you are in combat.")
					self:SetValue (GetCVar ("nameplateShowSelf") == CVAR_ENABLED)
				end
			end,
			name = "Personal Health and Mana Bars" .. CVarIcon,
			desc = "Shows a mini health and mana bars under your character." .. CVarDesc,
			nocombat = true,
		},
		{
			type = "toggle",
			get = function() return GetCVar (CVAR_RESOURCEONTARGET) == CVAR_ENABLED end,
			set = function (self, fixedparam, value) 
				if (not InCombatLockdown()) then
					SetCVar (CVAR_RESOURCEONTARGET, math.abs (tonumber (GetCVar (CVAR_RESOURCEONTARGET))-1))
				else
					Plater:Msg ("you are in combat.")
					self:SetValue (GetCVar (CVAR_RESOURCEONTARGET) == CVAR_ENABLED)
				end
			end,
			name = "Show Resources on Target" .. CVarIcon,
			desc = "Shows your resource such as combo points above your current target.\n\n'Personal Health and Mana Bars' has to be enabled" .. CVarDesc,
			nocombat = true,
		},
		{
			type = "toggle",
			get = function() return GetCVar (CVAR_SHOWALL) == CVAR_ENABLED end,
			set = function (self, fixedparam, value) 
				if (not InCombatLockdown()) then
					SetCVar (CVAR_SHOWALL, math.abs (tonumber (GetCVar (CVAR_SHOWALL))-1))
				else
					Plater:Msg ("you are in combat.")
					self:SetValue (GetCVar (CVAR_SHOWALL) == CVAR_ENABLED)
				end
			end,
			name = "Always Show Nameplates" .. CVarIcon,
			desc = "Show nameplates for all units near you. If disabled on show relevant units when you are in combat." .. CVarDesc,
			nocombat = true,
		},
		
		{type = "breakline"},
		
		{
			type = "toggle",
			get = function() return Plater.db.profile.stacking_nameplates_enabled end, --GetCVar (CVAR_PLATEMOTION) == CVAR_ENABLED
			set = function (self, fixedparam, value) 
				if (not InCombatLockdown()) then
					SetCVar (CVAR_PLATEMOTION, value and "1" or "0")
					Plater.db.profile.stacking_nameplates_enabled = value
				else
					Plater:Msg ("you are in combat.")
					self:SetValue (GetCVar (CVAR_PLATEMOTION) == CVAR_ENABLED)
				end
			end,
			name = "Stacking Nameplates" .. CVarIcon,
			desc = "If enabled, nameplates won't overlap each other." .. CVarDesc .. "\n\n|cFFFFFF00Important|r: to set the amount of space between each nameplate see '|cFFFFFFFFNameplate Vertical Padding|r' under Advanced tab.",
			nocombat = true,
		},
		{
			type = "range",
			get = function() return tonumber (GetCVar (CVAR_CULLINGDISTANCE)) end,
			set = function (self, fixedparam, value) 
				if (not InCombatLockdown()) then
					SetCVar (CVAR_CULLINGDISTANCE, value)
				else
					Plater:Msg ("you are in combat.")
				end
			end,
			min = 1,
			max = 100,
			step = 1,
			name = "View Distance" .. CVarIcon,
			desc = "How far you can see nameplates (in yards).\n\n|cFFFFFFFFDefault: 40|r" .. CVarDesc,
			nocombat = true,
		},
		{
			type = "toggle",
			get = function() return GetCVar (CVAR_ENEMY_MINIONS) == CVAR_ENABLED end,
			set = function (self, fixedparam, value) 
				if (not InCombatLockdown()) then
					SetCVar (CVAR_ENEMY_MINIONS, math.abs (tonumber (GetCVar (CVAR_ENEMY_MINIONS))-1))
				else
					Plater:Msg ("you are in combat.")
					self:SetValue (GetCVar (CVAR_ENEMY_MINIONS) == CVAR_ENABLED)
				end
			end,
			name = "Enemy Units (" .. (GetBindingKey ("NAMEPLATES") or "") .. "): Minions" .. CVarIcon,
			desc = "Show nameplate for enemy pets, totems and guardians." .. CVarDesc,
			nocombat = true,
		},
		
		{type = "breakline"},
		
		{
			type = "toggle",
			get = function() return GetCVar (CVAR_ENEMY_MINUS) == CVAR_ENABLED end,
			set = function (self, fixedparam, value) 
				if (not InCombatLockdown()) then
					SetCVar (CVAR_ENEMY_MINUS, math.abs (tonumber (GetCVar (CVAR_ENEMY_MINUS))-1))
				else
					Plater:Msg ("you are in combat.")
					self:SetValue (GetCVar (CVAR_ENEMY_MINUS) == CVAR_ENABLED)
				end
			end,
			name = "Enemy Units (V): Minor" .. CVarIcon,
			desc = "Show nameplate for minor enemies." .. CVarDesc,
			nocombat = true,
		},
		{
			type = "toggle",
			get = function() return GetCVar (CVAR_FRIENDLY_GUARDIAN) == CVAR_ENABLED end,
			set = function (self, fixedparam, value) 
				if (not InCombatLockdown()) then
					SetCVar (CVAR_FRIENDLY_GUARDIAN, math.abs (tonumber (GetCVar (CVAR_FRIENDLY_GUARDIAN))-1))
					SetCVar (CVAR_FRIENDLY_PETS, 	GetCVar (CVAR_FRIENDLY_GUARDIAN))
					SetCVar (CVAR_FRIENDLY_TOTEMS, GetCVar (CVAR_FRIENDLY_GUARDIAN))
					SetCVar (CVAR_FRIENDLY_MINIONS, GetCVar (CVAR_FRIENDLY_GUARDIAN))
				else
					Plater:Msg ("you are in combat.")
					self:SetValue (GetCVar (CVAR_FRIENDLY_GUARDIAN) == CVAR_ENABLED)
				end
			end,
			name = "Friendly Units (" .. (GetBindingKey ("FRIENDNAMEPLATES") or "") .. "): Minions" .. CVarIcon,
			desc = "Show nameplate for friendly pets, totems and guardians.\n\nAlso check the Enabled box below Friendly Npc Config." .. CVarDesc,
			nocombat = true,
		},
}

local interface_title = Plater:CreateLabel (frontPageFrame, "Interface Options (from the client):", Plater:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"))
interface_title:SetPoint (startX, startY)

local in_combat_background = Plater:CreateImage (frontPageFrame)
in_combat_background:SetColorTexture (.6, 0, 0, .1)
in_combat_background:SetPoint ("topleft", interface_title, "bottomleft", 0, 2)
in_combat_background:SetPoint ("bottomright", frontPageFrame, "bottomright", -10, 390)
in_combat_background:Hide()

local in_combat_label = Plater:CreateLabel (frontPageFrame, "you are in combat", 24, "silver")
in_combat_label:SetPoint ("right", in_combat_background, "right", -10, 0)
in_combat_label:Hide()

frontPageFrame:RegisterEvent ("PLAYER_REGEN_DISABLED")
frontPageFrame:RegisterEvent ("PLAYER_REGEN_ENABLED")
frontPageFrame:SetScript ("OnEvent", function (self, event)
	if (event == "PLAYER_REGEN_DISABLED") then
		in_combat_background:Show()
		in_combat_label:Show()
	elseif (event == "PLAYER_REGEN_ENABLED") then
		in_combat_background:Hide()
		in_combat_label:Hide()
	end
end)

DF:BuildMenu (frontPageFrame, interface_options, startX, startY-20, 300 + 60, true, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template, globalCallback)

--warning scripts

frontPageFrame.WarningScripts = CreateFrame ("frame", nil, frontPageFrame)
frontPageFrame.WarningScripts:SetSize (350, 60)
frontPageFrame.WarningScripts:SetPoint ("topright", frontPageFrame, "topright", -20, -120)
DF:ApplyStandardBackdrop (frontPageFrame.WarningScripts)
frontPageFrame.WarningScripts:SetBackdropColor (.3, .1, .1)
frontPageFrame.WarningScripts.Label = DF:CreateLabel (frontPageFrame.WarningScripts, "Scripts are now enabled and available to use!\n\nBuilt-In castbar and nameplate script effects\nfor dungeons are running.")
frontPageFrame.WarningScripts.Label:SetPoint ("topleft", 4, -4)
frontPageFrame.WarningScripts.Label.textsize = 12

-------------------------------------------------------------------------------
-- painel para configurar debuffs e buffs

local grow_direction_names = {"Left", "Center", "Right"}
local build_grow_direction_options = function (memberName)
	local t = {}
	for i = 1, #grow_direction_names do
		tinsert (t, {
			label = grow_direction_names [i], 
			value = i, 
			onclick = function (_, _, value)
				Plater.db.profile [memberName] = value
				Plater.RefreshDBUpvalues()
				Plater.UpdateAllPlates()
			end
		})
	end
	return t
end

local debuff_options = {
	{type = "label", get = function() return "General Settings:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
	
	{
		type = "toggle",
		get = function() return Plater.db.profile.aura_enabled end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.aura_enabled = value
			Plater.RefreshDBUpvalues()
			Plater.UpdateAllPlates()
			
			if (not value) then
				for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
					--for _, frame in ipairs (plateFrame.UnitFrame.BuffFrame.buffList) do
					for _, frame in ipairs (plateFrame.UnitFrame.BuffFrame.PlaterBuffList) do
						frame:Hide()
					end
				end
			end
		end,
		name = "Use Plater Auras",
		desc = "Plater will add buffs and debuffs above nameplates.",
	},
	
	{
		type = "toggle",
		get = function() return Plater.db.profile.aura_use_default end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.aura_use_default = value
			Plater:Msg ("use Blizzard aura filtering requires a /reload.")
		end,
		name = "Use Blizzard Auras",
		desc = "The default user interface will be allowed to add auras above the nameplate.\n\n|cFFFFFF00Important|r: Plater will also add auras, you may want disable the option above (|cFFFFAA00Use Plater Auras|r) in order to prevent duplicated debuffs.\n\n|cFFFFFF00Important|r: require |cFFFFAA00/reload|r after changing this setting.",
	},
	
	{
		type = "toggle",
		get = function() return Plater.db.profile.aura_show_tooltip end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.aura_show_tooltip = value
			Plater.UpdateAllPlates()
		end,
		name = "Show Tooltip",
		desc = "Show tooltip when hovering over the aura icon.",
	},
	
	{
		type = "range",
		get = function() return Plater.db.profile.aura_alpha end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.aura_alpha = value
			Plater.RefreshDBUpvalues()
		end,
		min = 0,
		max = 1,
		step = 0.01,
		usedecimals = true,
		thumbscale = 1.8,
		name = "Alpha",
		desc = "Alpha",
	},
	
	{type = "blank"},
	{type = "label", get = function() return "Aura Size:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
	
	{
		type = "range",
		get = function() return Plater.db.profile.aura_width end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.aura_width = value
			Plater.RefreshAuras()
			Plater.UpdateAllPlates()
		end,
		min = 8,
		max = 40,
		step = 1,
		name = "Width",
		desc = "Debuff's icon width.",
	},
	{
		type = "range",
		get = function() return Plater.db.profile.aura_height end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.aura_height = value
			Plater.RefreshAuras()
			Plater.UpdateAllPlates()
		end,
		min = 8,
		max = 40,
		step = 1,
		name = "Height",
		desc = "Debuff's icon height.",
	},
	
	{type = "blank"},
	{type = "label", get = function() return "Aura Frame 1:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
	
	--> grow direction
	{
		type = "select",
		get = function() return Plater.db.profile.aura_grow_direction end,
		values = function() return build_grow_direction_options ("aura_grow_direction") end,
		name = "Grow Direction",
		desc = "To which side aura icons should grow.\n\n|cFFFFFF00Important|r: debuffs are added first, buffs after.",
	},
	
	
	{
		type = "range",
		get = function() return Plater.db.profile.aura_x_offset end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.aura_x_offset = value
			Plater.RefreshDBUpvalues()
			Plater.UpdateAllPlates()
		end,
		min = -100,
		max = 100,
		step = 1,
		name = "X Offset",
		desc = "X Offset",
	},
	{
		type = "range",
		get = function() return Plater.db.profile.aura_y_offset end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.aura_y_offset = value
			Plater.RefreshDBUpvalues()
			Plater.UpdateAllPlates()
		end,
		min = -100,
		max = 100,
		step = 1,
		name = "Y Offset",
		desc = "Y Offset",
	},
	
	{type = "blank"},
	{type = "label", get = function() return "Aura Frame 2:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
	
	{
		type = "toggle",
		get = function() return Plater.db.profile.buffs_on_aura2 end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.buffs_on_aura2 = value
			Plater.RefreshDBUpvalues()
			Plater.UpdateAllPlates()
		end,
		name = "Enabled",
		desc = "When enabled auras are separated: Buffs are placed on this second frame, Debuffs on the first.\n\n|cFFFFFF00Important|r: require /reload when disabling this feature.",
	},
	--> grow direction
	{
		type = "select",
		get = function() return Plater.db.profile.aura2_grow_direction end,
		values = function() return build_grow_direction_options ("aura2_grow_direction") end,
		name = "Grow Direction",
		desc = "To which side aura icons should grow.",
	},
	--> offset
	{
		type = "range",
		get = function() return Plater.db.profile.aura2_x_offset end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.aura2_x_offset = value
			Plater.RefreshDBUpvalues()
			Plater.UpdateAllPlates()
		end,
		min = -100,
		max = 100,
		step = 1,
		name = "X Offset",
		desc = "X Offset",
	},
	{
		type = "range",
		get = function() return Plater.db.profile.aura2_y_offset end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.aura2_y_offset = value
			Plater.RefreshDBUpvalues()
			Plater.UpdateAllPlates()
		end,
		min = -100,
		max = 100,
		step = 1,
		name = "Y Offset",
		desc = "Y Offset",
	},
	
	{type = "breakline"},
	
	{type = "label", get = function() return "Aura Timer:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
	
	{
		type = "toggle",
		get = function() return Plater.db.profile.aura_timer end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.aura_timer = value
			Plater.RefreshAuras()
			Plater.UpdateAllPlates()
		end,
		name = "Show",
		desc = "Time left on buff or debuff.",
	},
	{
		type = "range",
		get = function() return Plater.db.profile.aura_timer_text_size end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.aura_timer_text_size = value
			Plater.RefreshAuras()
			Plater.UpdateAllPlates()
		end,
		min = 7,
		max = 40,
		step = 1,
		name = "Size",
		desc = "Size",
	},
	{
		type = "toggle",
		get = function() return Plater.db.profile.aura_timer_text_shadow end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.aura_timer_text_shadow = value
			Plater.UpdateAllPlates()
		end,
		name = "Shadow",
		desc = "Shadow",
	},
	{
		type = "color",
		get = function()
			local color = Plater.db.profile.aura_timer_text_color
			return {color[1], color[2], color[3], color[4]}
		end,
		set = function (self, r, g, b, a) 
			local color = Plater.db.profile.aura_timer_text_color
			color[1], color[2], color[3], color[4] = r, g, b, a
			Plater.UpdateAllPlates()
		end,
		name = "Color",
		desc = "Color",
	},
	{
		type = "select",
		get = function() return Plater.db.profile.aura_timer_text_anchor.side end,
		values = function() return build_anchor_side_table (nil, "aura_timer_text_anchor") end,
		name = "Anchor",
		desc = "Which side of the buff icon the timer should attach to.",
	},
	{
		type = "range",
		get = function() return Plater.db.profile.aura_timer_text_anchor.x end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.aura_timer_text_anchor.x = value
			Plater.UpdateAllPlates()
		end,
		min = -20,
		max = 20,
		step = 1,
		name = "X Offset",
		desc = "Slightly move the text horizontally.",
	},
	--y offset
	{
		type = "range",
		get = function() return Plater.db.profile.aura_timer_text_anchor.y end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.aura_timer_text_anchor.y = value
			Plater.UpdateAllPlates()
		end,
		min = -20,
		max = 20,
		step = 1,
		name = "Y Offset",
		desc = "Slightly move the text vertically.",
	},
	
	{type = "blank"},

	{type = "label", get = function() return "Stack Counter:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
	
	--stack text anchor
	{
		type = "range",
		get = function() return Plater.db.profile.aura_stack_size end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.aura_stack_size = value
			Plater.UpdateAllPlates()
		end,
		min = 6,
		max = 24,
		step = 1,
		name = "Size",
		desc = "Size",
	},
	{
		type = "toggle",
		get = function() return Plater.db.profile.aura_stack_shadow end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.aura_stack_shadow = value
			Plater.UpdateAllPlates()
		end,
		name = "Shadow",
		desc = "Shadow",
	},
	{
		type = "color",
		get = function()
			local color = Plater.db.profile.aura_stack_color
			return {color[1], color[2], color[3], color[4]}
		end,
		set = function (self, r, g, b, a) 
			local color = Plater.db.profile.aura_stack_color
			color[1], color[2], color[3], color[4] = r, g, b, a
			Plater.UpdateAllPlates()
		end,
		name = "Color",
		desc = "Color",
	},
	{
		type = "select",
		get = function() return Plater.db.profile.aura_stack_anchor.side end,
		values = function() return build_anchor_side_table (nil, "aura_stack_anchor") end,
		name = "Anchor",
		desc = "Which side of the buff icon the stack counter should attach to.",
	},
	{
		type = "range",
		get = function() return Plater.db.profile.aura_stack_anchor.x end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.aura_stack_anchor.x = value
			Plater.UpdateAllPlates()
		end,
		min = -20,
		max = 20,
		step = 1,
		name = "X Offset",
		desc = "Slightly move the text horizontally.",
	},
	--y offset
	{
		type = "range",
		get = function() return Plater.db.profile.aura_stack_anchor.y end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.aura_stack_anchor.y = value
			Plater.UpdateAllPlates()
		end,
		min = -20,
		max = 20,
		step = 1,
		name = "Y Offset",
		desc = "Slightly move the text vertically.",
	},
	
	{type = "blank"},
	
	{type = "label", get = function() return "Aura Size on Personal Bar:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
	
	{
		type = "range",
		get = function() return Plater.db.profile.aura_width_personal end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.aura_width_personal = value
			Plater.RefreshAuras()
			Plater.UpdateAllPlates()
		end,
		min = 8,
		max = 40,
		step = 1,
		name = "Width",
		desc = "Debuff's icon width.",
	},
	{
		type = "range",
		get = function() return Plater.db.profile.aura_height_personal end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.aura_height_personal = value
			Plater.RefreshAuras()
			Plater.UpdateAllPlates()
		end,
		min = 8,
		max = 40,
		step = 1,
		name = "Height",
		desc = "Debuff's icon height.",
	},
	
	{type = "breakline"},

	{type = "label", get = function() return "Automatic Aura Tracking:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},

	{
		type = "toggle",
		get = function() return Plater.db.profile.aura_show_aura_by_the_player end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.aura_show_aura_by_the_player = value
			Plater.RefreshDBUpvalues()
			Plater.UpdateAllPlates()
		end,
		name = "Show Auras Casted by You",
		desc = "Show Auras Casted by You.",
	},
	
	{type = "blank"},
	
	{
		type = "toggle",
		get = function() return Plater.db.profile.aura_show_important end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.aura_show_important = value
			Plater.RefreshDBUpvalues()
			Plater.UpdateAllPlates()
		end,
		name = "Show Important Auras",
		desc = "Show buffs and debuffs which the game tag as important.",
	},
	{
		type = "color",
		get = function()
			local color = Plater.db.profile.aura_border_colors.is_show_all
			return {color[1], color[2], color[3], color[4]}
		end,
		set = function (self, r, g, b, a) 
			local color = Plater.db.profile.aura_border_colors.is_show_all
			color[1], color[2], color[3], color[4] = r, g, b, a
			Plater.UpdateAllPlates()
		end,
		name = "Important Auras Border Color",
		desc = "Important Auras Border Color",
	},
	
	{type = "blank"},
	
	{
		type = "toggle",
		get = function() return Plater.db.profile.aura_show_dispellable end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.aura_show_dispellable = value
			Plater.RefreshDBUpvalues()
			Plater.UpdateAllPlates()
		end,
		name = "Show Dispellable Buffs",
		desc = "Show auras which can be dispelled or stealed.",
	},
	{
		type = "color",
		get = function()
			local color = Plater.db.profile.aura_border_colors.steal_or_purge
			return {color[1], color[2], color[3], color[4]}
		end,
		set = function (self, r, g, b, a) 
			local color = Plater.db.profile.aura_border_colors.steal_or_purge
			color[1], color[2], color[3], color[4] = r, g, b, a
			Plater.UpdateAllPlates()
		end,
		name = "Dispellable Buffs Border Color",
		desc = "Dispellable Buffs Border Color",
	},
	
	{type = "blank"},

	{
		type = "toggle",
		get = function() return Plater.db.profile.aura_show_buff_by_the_unit end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.aura_show_buff_by_the_unit = value
			Plater.RefreshDBUpvalues()
			Plater.UpdateAllPlates()
		end,
		name = "Show Buffs Casted by the Unit",
		desc = "Show Buffs Casted by the Unit it self",
	},
	--border color is buff
	{
		type = "color",
		get = function()
			local color = Plater.db.profile.aura_border_colors.is_buff
			return {color[1], color[2], color[3], color[4]}
		end,
		set = function (self, r, g, b, a) 
			local color = Plater.db.profile.aura_border_colors.is_buff
			color[1], color[2], color[3], color[4] = r, g, b, a
			Plater.UpdateAllPlates()
		end,
		name = "Buffs Border Color",
		desc = "Buffs Border Color",
	},	
	
	{type = "breakline"},
	
	--{type = "label", get = function() return "|TInterface\\GossipFrame\\AvailableLegendaryQuestIcon:0|tTest Auras:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
	{type = "label", get = function() return "Test Auras:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
	{
		type = "toggle",
		get = function() return Plater.DisableAuraTest and true or false end,
		set = function (self, fixedparam, value) 
			Plater.DisableAuraTest = value
			if (value) then
				auraOptionsFrame.DisableAuraTest()
			else
				auraOptionsFrame.EnableAuraTest()
			end
		end,
		name = "|TInterface\\GossipFrame\\AvailableQuestIcon:0|tDisable Testing Auras",
		desc = "Enable this to hide test auras shown when configuring.",
	},
	
	
	
}

DF:BuildMenu (auraOptionsFrame, debuff_options, startX, startY, heightSize, true, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template, globalCallback)

auraOptionsFrame.AuraTesting = {
	DEBUFF = {
		{
			SpellName = "Shadow Word: Pain",
			SpellTexture = 136207,
			Count = 1,
			Duration = 7,
			SpellID = 589,
		},
		{
			SpellName = "Vampiric Touch",
			SpellTexture = 135978,
			Count = 1,
			Duration = 5,
			SpellID = 34914,
		},
		{
			SpellName = "Mind Flay",
			SpellTexture = 136208,
			Count = 3,
			Duration = 5,
			SpellID = 15407,
		},
	},
	
	BUFF = {
		{
			SpellName = "Twist of Fate",
			SpellTexture = 237566,
			Count = 1,
			Duration = 9,
			SpellID = 123254,
		},
		{
			SpellName = "Empty Mind",
			SpellTexture = 136206,
			Count = 4,
			Duration = 7,
			SpellID = 247226,
		},
	}
}

auraOptionsFrame.OnUpdateFunc = function (self, deltaTime)
	
	auraOptionsFrame.NextTime = auraOptionsFrame.NextTime - deltaTime
	DB_AURA_ENABLED = false
	
	if (auraOptionsFrame.NextTime <= 0) then
		auraOptionsFrame.NextTime = 0.016
		
		for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do

			local buffFrame = plateFrame.UnitFrame.BuffFrame
			local buffFrame2 = plateFrame.UnitFrame.BuffFrame2
			
			buffFrame:SetAlpha (DB_AURA_ALPHA)
			
			--> reset next aura icon to use
			buffFrame.NextAuraIcon = 1
			buffFrame2.NextAuraIcon = 1
		
			if (not DB_AURA_SEPARATE_BUFFS) then
				for index, auraTable in ipairs (auraOptionsFrame.AuraTesting.DEBUFF) do
					local auraIconFrame = Plater.GetAuraIcon (buffFrame)
					if (not auraTable.ApplyTime or auraTable.ApplyTime+auraTable.Duration < GetTime()) then
						auraTable.ApplyTime = GetTime() + math.random (3, 12)
					end
					
					if (not UnitIsUnit (plateFrame [MEMBER_UNITID], "player")) then
						Plater.AddAura (auraIconFrame, index, auraTable.SpellName, auraTable.SpellTexture, auraTable.Count, "DEBUFF", auraTable.Duration, auraTable.ApplyTime+auraTable.Duration, "player", false, false, auraTable.SpellID)
					else
						Plater.AddAura (auraIconFrame, index, auraTable.SpellName, auraTable.SpellTexture, auraTable.Count, "DEBUFF", auraTable.Duration, auraTable.ApplyTime+auraTable.Duration, "player", false, false, auraTable.SpellID, false, false, true, true)
					end
				end
				
				for index, auraTable in ipairs (auraOptionsFrame.AuraTesting.BUFF) do
					local auraIconFrame = Plater.GetAuraIcon (buffFrame)
					if (not auraTable.ApplyTime or auraTable.ApplyTime+auraTable.Duration < GetTime()) then
						auraTable.ApplyTime = GetTime() + math.random (3, 12)
					end
					
					if (not UnitIsUnit (plateFrame [MEMBER_UNITID], "player")) then
						Plater.AddAura (auraIconFrame, index, auraTable.SpellName, auraTable.SpellTexture, auraTable.Count, "DEBUFF", auraTable.Duration, auraTable.ApplyTime+auraTable.Duration, "player", false, false, auraTable.SpellID, true)
					else
						Plater.AddAura (auraIconFrame, index, auraTable.SpellName, auraTable.SpellTexture, auraTable.Count, "DEBUFF", auraTable.Duration, auraTable.ApplyTime+auraTable.Duration, "player", false, false, auraTable.SpellID, false, false, false, true)
					end
				end
	
				--hide icons on the second buff frame
				for i = 1, #buffFrame2.PlaterBuffList do
					local icon = buffFrame2.PlaterBuffList [i]
					if (icon) then
						icon:Hide()
						icon.InUse = false
					end
				end
			end
		
			if (DB_AURA_SEPARATE_BUFFS) then
				for index, auraTable in ipairs (auraOptionsFrame.AuraTesting.DEBUFF) do
					local auraIconFrame = Plater.GetAuraIcon (buffFrame)
					if (not auraTable.ApplyTime or auraTable.ApplyTime+auraTable.Duration < GetTime()) then
						auraTable.ApplyTime = GetTime() + math.random (3, 12)
					end
					
					if (not UnitIsUnit (plateFrame [MEMBER_UNITID], "player")) then
						Plater.AddAura (auraIconFrame, index, auraTable.SpellName, auraTable.SpellTexture, auraTable.Count, "DEBUFF", auraTable.Duration, auraTable.ApplyTime+auraTable.Duration, "player", false, false, auraTable.SpellID)
					else
						Plater.AddAura (auraIconFrame, index, auraTable.SpellName, auraTable.SpellTexture, auraTable.Count, "DEBUFF", auraTable.Duration, auraTable.ApplyTime+auraTable.Duration, "player", false, false, auraTable.SpellID, false, false, true, true)
					end
				end
			
				for index, auraTable in ipairs (auraOptionsFrame.AuraTesting.BUFF) do
					local auraIconFrame = Plater.GetAuraIcon (buffFrame, true)
					if (not auraTable.ApplyTime or auraTable.ApplyTime+auraTable.Duration < GetTime()) then
						auraTable.ApplyTime = GetTime() + math.random (3, 12)
					end
					
					if (not UnitIsUnit (plateFrame [MEMBER_UNITID], "player")) then
						Plater.AddAura (auraIconFrame, index, auraTable.SpellName, auraTable.SpellTexture, auraTable.Count, "BUFF", auraTable.Duration, auraTable.ApplyTime+auraTable.Duration, "player", false, false, auraTable.SpellID, true)
					else
						Plater.AddAura (auraIconFrame, index, auraTable.SpellName, auraTable.SpellTexture, auraTable.Count, "BUFF", auraTable.Duration, auraTable.ApplyTime+auraTable.Duration, "player", false, false, auraTable.SpellID, false, false, false, true)
					end
				end
			end
			
			hide_non_used_auraFrames (buffFrame)
			buffFrame:Layout()
		
		end
		
	end
	
end

auraOptionsFrame.EnableAuraTest = function()
	DB_AURA_ENABLED = false
	auraOptionsFrame.NextTime = 0.2
	auraOptionsFrame:SetScript ("OnUpdate", auraOptionsFrame.OnUpdateFunc)
end
auraOptionsFrame.DisableAuraTest = function()
	Plater.RefreshDBUpvalues()
	auraOptionsFrame:SetScript ("OnUpdate", nil)
end

auraOptionsFrame:SetScript ("OnShow", function()
	if (not Plater.DisableAuraTest) then
		auraOptionsFrame.EnableAuraTest()
	end
end)

auraOptionsFrame:SetScript ("OnHide", function()
	auraOptionsFrame.DisableAuraTest()
end)

----------------------------------------------------------------------------------------------------------------------------------------------------------------
--> aura tracking

-- ~aura ~buff ~debuff

	local aura_options = {
		height = 330, 
		row_height = 16,
		width = 200,
		button_text_template = "PLATER_BUTTON", --text template
	}

	local method_change_callback = function()
		Plater.RefreshDBUpvalues()
	end
	
	local debuff_panel_texts = {
		BUFFS_AVAILABLE = "Click to add buffs to blacklist",
		BUFFS_IGNORED = "Buffs on the blacklist (filtered out)",
		DEBUFFS_AVAILABLE = "Click to add debuffs to blacklist",
		DEBUFFS_IGNORED = "Debuffs on the blacklist (filtered out)",
		BUFFS_TRACKED = "Aditional buffs to track",
		DEBUFFS_TRACKED = "Aditional debuffs to track",
	}
	
	auraFilterFrame:SetSize (f:GetWidth(), f:GetHeight() + startY)
	
	local auraConfigPanel = DF:CreateAuraConfigPanel (auraFilterFrame, "$parentAuraConfig", Plater.db.profile, method_change_callback, aura_options, debuff_panel_texts)
	auraConfigPanel:SetPoint ("topleft", auraFilterFrame, "topleft", 10, startY)
	auraConfigPanel:SetSize (f:GetWidth() - 20, f:GetHeight() + startY)
	auraConfigPanel:Show()
	auraFilterFrame.auraConfigPanel = auraConfigPanel


--------------------------------------------------------------------------------------------------------------------------------------------------------------
--> last event auras

	--local auraLastEventFrame = mainFrame.AllFrames [8]
	do
		--options
		local scroll_width = 1050
		local scroll_height = 442
		local scroll_lines = 21
		local scroll_line_height = 20
		local backdrop_color = {.2, .2, .2, 0.2}
		local backdrop_color_on_enter = {.8, .8, .8, 0.4}
		local y = startY
		local headerY = y - 20
		local scrollY = headerY - 20
	
		--header
		local headerTable = {
			{text = "Icon", width = 32},
			{text = "Spell ID", width = 74},
			{text = "Spell Name", width = 162},
			{text = "Source", width = 130},
			{text = "Spell Type", width = 70},
			{text = "Add to Tracklist", width = 100},
			{text = "Add to Blacklist", width = 100},
			{text = "Add to Special Auras", width = 120},
			{text = "Add to Script Trigger", width = 120},
			{text = "Create WeakAura", width = 120, icon = _G.WeakAuras and [[Interface\AddOns\WeakAuras\Media\Textures\icon]] or ""},
		}
		local headerOptions = {
			padding = 2,
		}
		
		auraLastEventFrame.Header = DF:CreateHeader (auraLastEventFrame, headerTable, headerOptions)
		auraLastEventFrame.Header:SetPoint ("topleft", auraLastEventFrame, "topleft", 10, headerY)
	
		--line scripts
		local line_onenter = function (self)
			self:SetBackdropColor (unpack (backdrop_color_on_enter))
			if (self.SpellID) then
				GameTooltip:SetOwner (self, "ANCHOR_TOPLEFT")
				GameTooltip:SetSpellByID (self.SpellID)
				GameTooltip:AddLine (" ")
				GameTooltip:Show()
			end
		end
		
		local line_onleave = function (self)
			self:SetBackdropColor (unpack (backdrop_color))
			GameTooltip:Hide()
		end
		
		local widget_onenter = function (self)
			local line = self:GetParent()
			line:GetScript ("OnEnter")(line)
		end
		local widget_onleave = function (self)
			local line = self:GetParent()
			line:GetScript ("OnLeave")(line)
		end
		
		local line_add_tracklist = function (self)
			self = self:GetCapsule()
			
			if (self.AuraType == "BUFF") then
				if (Plater.db.profile.aura_tracker.track_method == 0x1) then
					Plater.db.profile.aura_tracker.buff_tracked [self.SpellID] = true
					Plater:Msg ("Aura added to buff tracking.")
					
				elseif (Plater.db.profile.aura_tracker.track_method == 0x2) then
					local added = DF.table.addunique (Plater.db.profile.aura_tracker.buff, self.SpellID)
					if (added) then
						Plater:Msg ("Aura added to manual buff tracking.")
					else
						Plater:Msg ("Aura not added: already on track.")
					end
					
				end
			
			elseif (self.AuraType == "DEBUFF") then
				if (Plater.db.profile.aura_tracker.track_method == 0x1) then
					Plater.db.profile.aura_tracker.debuff_tracked [self.SpellID] = true
					Plater:Msg ("Aura added to debuff tracking.")
					
				elseif (Plater.db.profile.aura_tracker.track_method == 0x2) then
					local added = DF.table.addunique (Plater.db.profile.aura_tracker.debuff, self.SpellID)
					if (added) then
						Plater:Msg ("Aura added to manual debuff tracking.")
					else
						Plater:Msg ("Aura not added: already on track.")
					end
					
				end
			end
		end
		
		local line_add_ignorelist = function (self)
			self = self:GetCapsule()
			
			if (self.AuraType == "BUFF") then
				if (Plater.db.profile.aura_tracker.track_method == 0x1) then
					Plater.db.profile.aura_tracker.buff_banned [self.SpellID] = true
					Plater:Msg ("Aura added to buff blacklist.")
				end
			
			elseif (self.AuraType == "DEBUFF") then
				if (Plater.db.profile.aura_tracker.track_method == 0x1) then
					Plater.db.profile.aura_tracker.debuff_banned [self.SpellID] = true
					Plater:Msg ("Aura added to debuff blacklist.")
				end
			end
		end
		
		local line_add_special = function (self)
			self = self:GetCapsule()
			
			local added = DF.table.addunique (Plater.db.profile.extra_icon_auras, self.SpellID)
			if (added) then
				Plater:Msg ("Aura added to the special aura container.")
			else
				Plater:Msg ("Aura not added: already on the special container.")
			end
		end
		
		local line_onclick_trigger_dropdown = function (self, fixedValue, scriptID)
			local scriptObject = Plater.GetScriptObject (scriptID)
			local spellName = GetSpellInfo (self.SpellID)
			
			if (scriptObject and spellName) then
				if (scriptObject.ScriptType == 1 or scriptObject.ScriptType == 2) then
					--add the trigger
					local added = DF.table.addunique (scriptObject.SpellIds, self.SpellID)
					if (added) then
						--reload all scripts
						Plater.WipeAndRecompileAllScripts()
						Plater:Msg ("Trigger added to script.")
					else
						Plater:Msg ("Script already have this trigger.")
					end
					
					--refresh and select no option
					self:Refresh()
					self:Select (0, true)
				end
			end
		end
		
		local line_refresh_trigger_dropdown = function (self)
			if (not self.SpellID) then
				return {}
			end
			
			local t = {}
			local spellName = GetSpellInfo (self.SpellID)

			local scripts = Plater.GetAllScripts()
			for i = 1, #scripts do
				local scriptObject = scripts [i]
				if (scriptObject.ScriptType == 1 or scriptObject.ScriptType == 2) then
					tinsert (t, {0, 0, scriptObject.Name, scriptObject.Enabled and 1 or 0, label = scriptObject.Name, value = i, color = scriptObject.Enabled and "white" or "red", onclick = line_onclick_trigger_dropdown, desc = scriptObject.Desc})
				end
			end
			
			table.sort (t, Plater.SortScripts)
			
			return t
		end
		
		local line_create_aura = function (self)
			self = self:GetCapsule()
			
			if (Details) then
				local spellName, _, spellIcon = GetSpellInfo (self.SpellID)
				local encounterID = self.EncounterID
				
				Details:OpenAuraPanel (self.SpellID, spellName, spellIcon, encounterID, self.AuraType == "BUFF" and 5 or self.AuraType == "DEBUFF" and 1 or self.IsCast and 7 or 2, 1)
				PlaterOptionsPanelFrame:Hide()
			else
				Plater:Msg ("Details! Damage Meter not found, install it from the Twitch App!")
			end
		end
	
		local oneditfocusgained_spellid = function (self, capsule)
			self:HighlightText (0)
		end
	
		--line
		local scroll_createline = function (self, index)
		
			local line = CreateFrame ("button", "$parentLine" .. index, self)
			line:SetPoint ("topleft", self, "topleft", 1, -((index-1)*(scroll_line_height+1)) - 1)
			line:SetSize (scroll_width - 2, scroll_line_height)
			line:SetScript ("OnEnter", line_onenter)
			line:SetScript ("OnLeave", line_onleave)
			
			line:SetBackdrop ({bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
			line:SetBackdropColor (unpack (backdrop_color))
			
			DF:Mixin (line, DF.HeaderFunctions)
			
			local icon = line:CreateTexture ("$parentSpellIcon", "overlay")
			icon:SetSize (scroll_line_height - 2, scroll_line_height - 2)
			
			local spell_id = DF:CreateTextEntry (line, function()end, headerTable[2].width, 20, nil, nil, nil, DF:GetTemplate ("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))
			spell_id:SetHook ("OnEditFocusGained", oneditfocusgained_spellid)
	
			local spell_name = DF:CreateLabel (line, "", DF:GetTemplate ("font", "PLATER_SCRIPTS_NAME"))
			local source_name = DF:CreateLabel (line, "", DF:GetTemplate ("font", "PLATER_SCRIPTS_NAME"))
			local spell_type = DF:CreateLabel (line, "", DF:GetTemplate ("font", "PLATER_SCRIPTS_NAME"))

			local add_tracklist = DF:CreateButton (line, line_add_tracklist, headerTable[6].width, 20, "Add", -1, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
			local add_ignorelist = DF:CreateButton (line, line_add_ignorelist, headerTable[7].width, 20, "Add", -1, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
			local add_special = DF:CreateButton (line, line_add_special, headerTable[8].width, 20, "Add", -1, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
			
			local add_script_trigger = DF:CreateDropDown (line, line_refresh_trigger_dropdown, 1, headerTable[9].width, 20, nil, nil, DF:GetTemplate ("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))
			
			local create_aura = DF:CreateButton (line, line_create_aura, headerTable[10].width, 20, "Create", -1, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
			
			spell_id:SetHook ("OnEnter", widget_onenter)
			spell_id:SetHook ("OnLeave", widget_onleave)
			
			add_tracklist:SetHook ("OnEnter", widget_onenter)
			add_tracklist:SetHook ("OnLeave", widget_onleave)
			
			add_ignorelist:SetHook ("OnEnter", widget_onenter)
			add_ignorelist:SetHook ("OnLeave", widget_onleave)
			
			add_special:SetHook ("OnEnter", widget_onenter)
			add_special:SetHook ("OnLeave", widget_onleave)
			
			add_script_trigger:SetHook ("OnEnter", widget_onenter)
			add_script_trigger:SetHook ("OnLeave", widget_onleave)
			
			create_aura:SetHook ("OnEnter", widget_onenter)
			create_aura:SetHook ("OnLeave", widget_onleave)
			
			line:AddFrameToHeaderAlignment (icon)
			line:AddFrameToHeaderAlignment (spell_id)
			line:AddFrameToHeaderAlignment (spell_name)
			line:AddFrameToHeaderAlignment (source_name)
			line:AddFrameToHeaderAlignment (spell_type)
			line:AddFrameToHeaderAlignment (add_tracklist)
			line:AddFrameToHeaderAlignment (add_ignorelist)
			line:AddFrameToHeaderAlignment (add_special)
			line:AddFrameToHeaderAlignment (add_script_trigger)
			line:AddFrameToHeaderAlignment (create_aura)
			
			line:AlignWithHeader (auraLastEventFrame.Header, "left")
			
			line.Icon = icon
			line.SpellIDEntry = spell_id
			line.SpellName = spell_name
			line.SourceName = source_name
			line.SpellType = spell_type
			line.AddTrackList = add_tracklist
			line.AddIgnoreList = add_ignorelist
			line.AddSpecial = add_special
			line.AddTrigger = add_script_trigger
			line.CreateAura = create_aura
			
			return line
		end
		
		--refresh scroll
		local IsSearchingFor
		local scroll_refresh = function (self, data, offset, total_lines)
		
			local dataInOrder = {}
			
			if (IsSearchingFor and IsSearchingFor ~= "") then
				if (self.SearchCachedTable and IsSearchingFor == self.SearchCachedTable.SearchTerm) then
					dataInOrder = self.SearchCachedTable
				else
					for i = 1, #data do
						local spellID = data[i] [1]
						local spellName, _, spellIcon = GetSpellInfo (spellID)
						
						if (spellName:lower():find (IsSearchingFor)) then
							dataInOrder [#dataInOrder+1] = {i, data[i], spellName}
						end
					end

					self.SearchCachedTable = dataInOrder
					self.SearchCachedTable.SearchTerm = IsSearchingFor
				end
			else
				if (not self.CachedTable) then
					for i = 1, #data do
						local spellID = data[i] [1]
						local spellName, _, spellIcon = GetSpellInfo (spellID)
						dataInOrder [#dataInOrder+1] = {i, data[i], spellName}
					end
					self.CachedTable = dataInOrder
				end
				
				dataInOrder = self.CachedTable
			end

			table.sort (dataInOrder, DF.SortOrder3R)
			data = dataInOrder
		
			for i = 1, total_lines do
				local index = i + offset
				local spellTable = data [index] and data [index] [2]
				
				if (spellTable) then
					local line = self:GetLine (i)
					local spellID = spellTable [1]
					local spellData = spellTable [2]
					
					local spellName, _, spellIcon = GetSpellInfo (spellID)
					
					line.value = spellTable
					
					if (spellName) then
						line.Icon:SetTexture (spellIcon)
						line.Icon:SetTexCoord (.1, .9, .1, .9)
						
						line.SpellName:SetTextTruncated (spellName, headerTable [3].width)
						line.SourceName:SetTextTruncated (spellData.source, headerTable [4].width)
						
						if (spellData.type == "BUFF") then
							line.SpellType.color = "PLATER_BUFF"
						elseif (spellData.type == "DEBUFF") then
							line.SpellType.color = "PLATER_DEBUFF"
						elseif (spellData.event == "SPELL_CAST_START") then
							line.SpellType.color = "PLATER_CAST"
						end
						
						line.SpellID = spellID
						
						line.SpellIDEntry:SetText (spellID)

						--{event = token, source = sourceName, type = auraType, npcID = Plater:GetNpcIdFromGuid (sourceGUID or "")}

						line.SpellType:SetText (spellData.event == "SPELL_CAST_START" and "Spell Cast" or spellData.event == "SPELL_AURA_APPLIED" and spellData.type)
						
						line.AddTrackList.SpellID = spellID
						line.AddTrackList.AuraType = spellData.type
						line.AddTrackList.EncounterID = spellData.encounterID
						
						line.AddIgnoreList.SpellID = spellID
						line.AddIgnoreList.AuraType = spellData.type
						line.AddIgnoreList.EncounterID = spellData.encounterID
						
						line.AddSpecial.SpellID = spellID
						line.AddSpecial.AuraType = spellData.type
						line.AddSpecial.EncounterID = spellData.encounterID
						
						line.CreateAura.SpellID = spellID
						line.CreateAura.AuraType = spellData.type
						line.CreateAura.IsCast = spellData.event == "SPELL_CAST_START"
						line.CreateAura.EncounterID = spellData.encounterID
						
						line.AddTrigger.SpellID = spellID
						line.AddTrigger:Refresh()
						
						--manual tracking doesn't have a black list
						if (Plater.db.profile.aura_tracker.track_method == 0x1) then
							line.AddIgnoreList:Enable()
							
						elseif (Plater.db.profile.aura_tracker.track_method == 0x2) then
							line.AddIgnoreList:Disable()
							
						end
						
					else
						line:Hide()
					end
				end
			end
		end
		
		--create scroll
		local spells_scroll = DF:CreateScrollBox (auraLastEventFrame, "$parentSpellScroll", scroll_refresh, {}, scroll_width, scroll_height, scroll_lines, scroll_line_height)
		DF:ReskinSlider (spells_scroll)
		spells_scroll:SetPoint ("topleft", auraLastEventFrame, "topleft", 10, scrollY)
		
		spells_scroll:SetScript ("OnShow", function (self)
			if (self.LastRefresh and self.LastRefresh+0.5 > GetTime()) then
				return
			end
			self.LastRefresh = GetTime()
		
			local newData = {}
			
			for spellID, spellTable in pairs (DB_CAPTURED_SPELLS) do
				tinsert (newData, {spellID, spellTable})
			end
			
			self.CachedTable = nil
			self.SearchCachedTable = nil
			
			self:SetData (newData)
			self:Refresh()
		end)
		
		--create lines
		for i = 1, scroll_lines do 
			spells_scroll:CreateLine (scroll_createline)
		end

		--create button to open spell list on Details!
		local openDetailsSpellList = function()
			if (Details) then
				Details.OpenForge()
				PlaterOptionsPanelFrame:Hide()
				--select all spells in the details! all spells panel
				if (DetailsForgePanel and DetailsForgePanel.SelectModule) then
					-- module 2 is the All Spells
					DetailsForgePanel.SelectModule (_, _, 2)
				end
			else
				Plater:Msg ("Details! Damage Meter is required and isn't installed, get it on Twitch App!")
			end
		end
		
		local open_spell_list_button = DF:CreateButton (auraLastEventFrame, openDetailsSpellList, 160, 20, "Open Full Spell List", -1, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
		open_spell_list_button:SetPoint ("bottomright", spells_scroll, "topright", 0, 24)

		--create the clean list button
			local wipe_spell_list = function()
				wipe (DB_CAPTURED_SPELLS)
				spells_scroll:Hide()
				C_Timer.After (0.016, function() spells_scroll:Show(); spells_scroll:Refresh() end)
			end
			local clear_list_button = DF:CreateButton (auraLastEventFrame, wipe_spell_list, 160, 20, "Clear List", -1, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
			clear_list_button:SetPoint ("right", open_spell_list_button, "left", -6, 0)
		
		--create search box
			function auraLastEventFrame.OnSearchBoxTextChanged()
				local text = auraLastEventFrame.AuraSearchTextEntry:GetText()
				if (text and string.len (text) > 0) then
					IsSearchingFor = text:lower()
				else
					IsSearchingFor = nil
				end
				spells_scroll:Refresh()
			end

			local aura_search_textentry = DF:CreateTextEntry (auraLastEventFrame, function()end, 160, 20, "AuraSearchTextEntry", _, _, options_dropdown_template)
			aura_search_textentry:SetPoint ("right", clear_list_button, "left", -6, 0)
			aura_search_textentry:SetHook ("OnChar",		auraLastEventFrame.OnSearchBoxTextChanged)
			aura_search_textentry:SetHook ("OnTextChanged", 	auraLastEventFrame.OnSearchBoxTextChanged)
			aura_search_label = DF:CreateLabel (auraLastEventFrame, "Search:", DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"))
			aura_search_label:SetPoint ("right", aura_search_textentry, "left", -2, 0)
		
		--create the title
		auraLastEventFrame.TitleDescText = Plater:CreateLabel (auraLastEventFrame, "Quick way to manage auras from a recent raid boss or dungeon run", 10, "silver")
		auraLastEventFrame.TitleDescText:SetPoint ("bottomleft", spells_scroll, "topleft", 0, 26)
		auraLastEventFrame.TitleText = Plater:CreateLabel (auraLastEventFrame, "Aura Ease", 14, "orange")
		auraLastEventFrame.TitleText:SetPoint ("bottomleft", auraLastEventFrame.TitleDescText, "topleft", 0, 2)
		
	end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> special auras
--> special aura container
	do 
		--> scroll with auras added to the special aura container
		local specialAuraFrame = CreateFrame ("frame", nil, auraSpecialFrame)
		specialAuraFrame:SetHeight (480)
		specialAuraFrame:SetPoint ("topleft", auraSpecialFrame, "topleft", startX, startY)
		specialAuraFrame:SetPoint ("topright", auraSpecialFrame, "topright", -10, startY)
		--DF:ApplyStandardBackdrop (specialAuraFrame, false, 0.6)
		
		local scroll_width = 280
		local scroll_height = 440
		local scroll_lines = 15
		local scroll_line_height = 20
		local backdrop_color = {.8, .8, .8, 0.2}
		local backdrop_color_on_enter = {.8, .8, .8, 0.4}
		local y = startY
		
		local line_onenter = function (self)
			self:SetBackdropColor (unpack (backdrop_color_on_enter))
			local spellid = select (7, GetSpellInfo (self.value))
			if (spellid) then
				GameTooltip:SetOwner (self, "ANCHOR_RIGHT");
				GameTooltip:SetSpellByID (spellid)
				GameTooltip:AddLine (" ")
				GameTooltip:Show()
			end
		end
		
		local line_onleave = function (self)
			self:SetBackdropColor (unpack (backdrop_color))
			GameTooltip:Hide()
		end
		
		local onclick_remove_button = function (self)
			local spell = self:GetParent().value
			local data = self:GetParent():GetParent():GetData()
			
			for i = 1, #data do
				if (data[i] == spell) then
					tremove (data, i)
					break
				end
			end
			
			self:GetParent():GetParent():Refresh()
			Plater.RefreshDBUpvalues()
		end
		
		local scroll_createline = function (self, index)
			local line = CreateFrame ("button", "$parentLine" .. index, self)
			line:SetPoint ("topleft", self, "topleft", 1, -((index-1)*(scroll_line_height+1)) - 1)
			line:SetSize (scroll_width - 2, scroll_line_height)
			line:SetScript ("OnEnter", line_onenter)
			line:SetScript ("OnLeave", line_onleave)
			
			line:SetBackdrop ({bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
			line:SetBackdropColor (unpack (backdrop_color))
			
			local icon = line:CreateTexture ("$parentIcon", "overlay")
			icon:SetSize (scroll_line_height - 2, scroll_line_height - 2)
			
			local name = line:CreateFontString ("$parentName", "overlay", "GameFontNormal")

			local remove_button = CreateFrame ("button", "$parentRemoveButton", line, "UIPanelCloseButton")
			remove_button:SetSize (16, 16)
			remove_button:SetScript ("OnClick", onclick_remove_button)
			remove_button:SetPoint ("topright", line, "topright")
			remove_button:GetNormalTexture():SetDesaturated (true)
			
			icon:SetPoint ("left", line, "left", 2, 0)
			name:SetPoint ("left", icon, "right", 2, 0)
			
			line.icon = icon
			line.name = name
			line.removebutton = remove_button
			
			return line
		end

		local scroll_refresh = function (self, data, offset, total_lines)
			for i = 1, total_lines do
				local index = i + offset
				local aura = data [index]
				if (aura) then
					local line = self:GetLine (i)
					local name, _, icon = GetSpellInfo (aura)
					line.value = aura
					if (name) then
						line.name:SetText (name)
						line.icon:SetTexture (icon)
						line.icon:SetTexCoord (.1, .9, .1, .9)
					else
						line.name:SetText (aura)
						line.icon:SetTexture ([[Interface\InventoryItems\WoWUnknownItem01]])
					end
				end
			end
		end
		
		local special_auras_added = DF:CreateScrollBox (specialAuraFrame, "$parentSpecialAurasAdded", scroll_refresh, Plater.db.profile.extra_icon_auras, scroll_width, scroll_height, scroll_lines, scroll_line_height)
		DF:ReskinSlider (special_auras_added)
		special_auras_added.__background:SetAlpha (.4)
		special_auras_added:SetPoint ("topleft", specialAuraFrame, "topleft", 0, -40)
		
		local title = DF:CreateLabel (specialAuraFrame, "Special Auras:", DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"))
		DF:SetFontSize (title, 12)
		title:SetPoint ("bottomleft", special_auras_added, "topleft", 0, 2)
		
		for i = 1, scroll_lines do 
			special_auras_added:CreateLine (scroll_createline)
		end
		
		--> text entry to input the aura name
		local new_buff_string = DF:CreateLabel (specialAuraFrame, "Add Special Aura", DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"))
		DF:SetFontSize (new_buff_string, 12)
		
		local new_buff_entry = DF:CreateTextEntry (specialAuraFrame, function()end, 200, 20, "NewSpecialAuraTextBox", _, _, options_dropdown_template)
		new_buff_entry.tooltip = "Enter the aura name using lower case letters.\n\nYou can add several spells at once using |cFFFFFF00;|r to separate each spell name."
		new_buff_entry:SetJustifyH ("left")
		
		new_buff_entry.SpellHashTable = {}
		new_buff_entry.SpellIndexTable = {}
		
		function new_buff_entry.LoadGameSpells()
			if (not next (new_buff_entry.SpellHashTable)) then
				--load all spells in the game
				DF:LoadAllSpells (new_buff_entry.SpellHashTable, new_buff_entry.SpellIndexTable)
				return true
			end
		end
		
		new_buff_entry:SetHook ("OnEditFocusGained", function (self, capsule)
			new_buff_entry.LoadGameSpells()
			new_buff_entry.SpellAutoCompleteList = new_buff_entry.SpellIndexTable
			new_buff_entry:SetAsAutoComplete ("SpellAutoCompleteList", nil, true)
		end)
		
		--> add aura button
		local add_buff_button = DF:CreateButton (specialAuraFrame, function()
		
			local text = new_buff_entry.text
			new_buff_entry:SetText ("")
			new_buff_entry:ClearFocus()
			
			if (text ~= "") then
				--> check for more than one spellname
				if (text:find (";")) then
					for _, spellName in ipairs ({strsplit (";", text)}) do
						spellName = DF:trim (spellName)
						spellName = lower (spellName)
						if (string.len (spellName) > 0) then
							local spellId = new_buff_entry.SpellHashTable [spellName]
							if (spellId) then
								tinsert (Plater.db.profile.extra_icon_auras, spellId)
							else
								print ("spellId not found for spell:", spellName)
							end
						end
					end
				else
					--get the spellId
					local spellName = lower (text)
					local spellId = new_buff_entry.SpellHashTable [spellName]
					if (not spellId) then
						print ("spellIs for spell ", spellName, "not found")
						return
					end
				
					tinsert (Plater.db.profile.extra_icon_auras, spellId)
				end
				
				special_auras_added:Refresh()
				Plater.RefreshDBUpvalues()
			end
			
		end, 100, 20, "Add Aura", nil, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"))		

		new_buff_entry:SetPoint ("topleft",  special_auras_added, "topright", 40, 0)
		new_buff_string:SetPoint ("bottomleft", new_buff_entry, "topleft", 0, 2)
		add_buff_button:SetPoint ("topleft", new_buff_entry, "bottomleft", 0, -2)
		add_buff_button.tooltip = "Add the aura to be tracked."
		
		--
		local especial_aura_settings = {
			{type = "label", get = function() return "Anchor Settings:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
			--anchor
			{
				type = "select",
				get = function() return Plater.db.profile.extra_icon_anchor.side end,
				values = function() return build_anchor_side_table (false, "extra_icon_anchor") end,
				name = "Anchor",
				desc = "Which side of the nameplate this widget is attach to.",
			},
			--x offset
			{
				type = "range",
				get = function() return Plater.db.profile.extra_icon_anchor.x end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.extra_icon_anchor.x = value
					Plater.UpdateAllPlates()
				end,
				min = -20,
				max = 20,
				step = 1,
				name = "X Offset",
				desc = "Slightly move the text horizontally.",
			},
			--y offset
			{
				type = "range",
				get = function() return Plater.db.profile.extra_icon_anchor.y end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.extra_icon_anchor.y = value
					Plater.UpdateAllPlates()
				end,
				min = -20,
				max = 20,
				step = 1,
				name = "Y Offset",
				desc = "Slightly move the text vertically.",
			},
			--show timer
			{
				type = "toggle",
				get = function() return Plater.db.profile.extra_icon_show_timer end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.extra_icon_show_timer = value
					Plater.UpdateAllPlates()
				end,
				name = "Show Timer",
				desc = "Show Timer",
			},
			--show caster name
			{
				type = "toggle",
				get = function() return Plater.db.profile.extra_icon_caster_name end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.extra_icon_caster_name = value
					Plater.UpdateAllPlates()
				end,
				name = "Show Caster Name",
				desc = "Show Caster Name (if player)",
			},
			
			--width
			{
				type = "range",
				get = function() return Plater.db.profile.extra_icon_width end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.extra_icon_width = value
					Plater.UpdateAllPlates()
				end,
				min = 8,
				max = 128,
				step = 1,
				name = "Width",
				desc = "Width",
			},
			--height
			{
				type = "range",
				get = function() return Plater.db.profile.extra_icon_height end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.extra_icon_height = value
					Plater.UpdateAllPlates()
				end,
				min = 8,
				max = 128,
				step = 1,
				name = "Height",
				desc = "Height",
			},
			--wide icons
			{
				type = "toggle",
				get = function() return Plater.db.profile.extra_icon_wide_icon end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.extra_icon_wide_icon = value
					Plater.UpdateAllPlates()
				end,
				name = "Wide Icons",
				desc = "Wide Icons",
			},
			--border color
			{
				type = "color",
				get = function()
					local color = Plater.db.profile.extra_icon_border_color
					return {color[1], color[2], color[3], color[4]}
				end,
				set = function (self, r, g, b, a) 
					local color = Plater.db.profile.extra_icon_border_color
					color[1], color[2], color[3], color[4] = r, g, b, a
					Plater.UpdateAllPlates()
				end,
				name = "Default Border Color",
				desc = "Default Border Color",
			},
			
			{type = "breakline"},
			
			{type = "label", get = function() return "Auto Add These Types of Auras:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
			
			--show crowd control auras
			{
				type = "toggle",
				get = function() return Plater.db.profile.debuff_show_cc end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.debuff_show_cc = value
					Plater.RefreshDBUpvalues()
					Plater.UpdateAllPlates()
				end,
				name = "Crowd Control",
				desc = "When the unit has a crowd control spell (such as Polymorph).",
			},
			--cc border color
			{
				type = "color",
				get = function()
					local color = Plater.db.profile.debuff_show_cc_border
					return {color[1], color[2], color[3], color[4]}
				end,
				set = function (self, r, g, b, a) 
					local color = Plater.db.profile.debuff_show_cc_border
					color[1], color[2], color[3], color[4] = r, g, b, a
					Plater.UpdateAllPlates()
				end,
				name = "Crowd Control Border Color",
				desc = "Crowd Control Border Color",
			},
			
			{type = "blank"},
			
			--show purge icons
			{
				type = "toggle",
				get = function() return Plater.db.profile.extra_icon_show_purge end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.extra_icon_show_purge = value
					Plater.RefreshDBUpvalues()
					Plater.UpdateAllPlates()
				end,
				name = "Dispellable",
				desc = "When the unit has an aura which can be dispellable or purge by you",
			},
			--purge border color
			{
				type = "color",
				get = function()
					local color = Plater.db.profile.extra_icon_show_purge_border
					return {color[1], color[2], color[3], color[4]}
				end,
				set = function (self, r, g, b, a) 
					local color = Plater.db.profile.extra_icon_show_purge_border
					color[1], color[2], color[3], color[4] = r, g, b, a
					Plater.UpdateAllPlates()
				end,
				name = "Dispellable Border Color",
				desc = "Dispellable Border Color",
			},
		
		}
		
		auraSpecialFrame.ExampleImageDesc = DF:CreateLabel (auraSpecialFrame, "Special auras look like this:", 14)
		auraSpecialFrame.ExampleImageDesc:SetPoint (330, -216)
		auraSpecialFrame.ExampleImage = DF:CreateImage (auraSpecialFrame, [[Interface\AddOns\Plater\images\extra_icon_example]], 256*0.8, 128*0.8)
		auraSpecialFrame.ExampleImage:SetPoint (330, -230)
		
		local fff = CreateFrame ("frame", "$parentExtraIconsSettings", auraSpecialFrame)
		fff:SetAllPoints()
		DF:BuildMenu (fff, especial_aura_settings, 570, startY - 27, heightSize, true, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template, globalCallback)

		--when the profile has changed
		function auraSpecialFrame:RefreshOptions()
			--update the script data for the scroll and refresh
			special_auras_added:SetData (Plater.db.profile.extra_icon_auras)
			special_auras_added:Refresh()
		end
		
		specialAuraFrame:SetScript ("OnShow", function()
			special_auras_added:Refresh()
			
			--not working properly, auras stay "flying" in the screen
			
			--[=[
			fff:SetScript ("OnUpdate", function()
				
				for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
					plateFrame.UnitFrame.ExtraIconFrame:ClearIcons()
					plateFrame.UnitFrame.ExtraIconFrame:SetIcon (248441, false, GetTime() - 2, 8)
					plateFrame.UnitFrame.ExtraIconFrame:SetIcon (273769, false, GetTime() - 3, 12)
					plateFrame.UnitFrame.ExtraIconFrame:SetIcon (206589, false, GetTime() - 6, 16)
					plateFrame.UnitFrame.ExtraIconFrame:SetIcon (279565, false, GetTime() - 180, 360)

					local spellName, _, spellIcon = GetSpellInfo (248441)
					local auraIconFrame = Plater.GetAuraIcon (plateFrame.UnitFrame.BuffFrame, 1)
					Plater.AddAura (auraIconFrame, 1, spellName, spellIcon, 1, "BUFF", 8, GetTime()+5, "player", false, false, 248441, false, false, false, false)
					auraIconFrame.InUse = true
					
					local spellName, _, spellIcon = GetSpellInfo (273769)
					local auraIconFrame = Plater.GetAuraIcon (plateFrame.UnitFrame.BuffFrame, 1)
					Plater.AddAura (auraIconFrame, 2, spellName, spellIcon, 1, "BUFF", 12, GetTime()+2, "player", false, false, 273769, false, false, false, false)
					auraIconFrame.InUse = true
				end
			end)
			--]=]
		end)
		
		specialAuraFrame:SetScript ("OnHide", function()
			--[=[
			fff:SetScript ("OnUpdate", nil)
			
			
			for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
				plateFrame.UnitFrame.ExtraIconFrame:ClearIcons()
				hide_non_used_auraFrames (plateFrame.UnitFrame.BuffFrame, 1)
			end
			--]=]
			
		end)
		
		--create the title
		auraSpecialFrame.TitleDescText = Plater:CreateLabel (auraSpecialFrame, "Track auras adding them to a special buff frame separated from the main buff line. Use it to emphasize important auras from raid bosses or mythic dungeons.", 10, "silver")
		auraSpecialFrame.TitleDescText:SetPoint ("bottomleft", special_auras_added, "topleft", 0, 26)
		auraSpecialFrame.TitleText = Plater:CreateLabel (auraSpecialFrame, "Aura Special", 14, "orange")
		auraSpecialFrame.TitleText:SetPoint ("bottomleft", auraSpecialFrame.TitleDescText, "topleft", 0, 2)
		
	end


--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- personal player ~player
do
		local on_select_player_percent_text_font = function (_, _, value)
			Plater.db.profile.plate_config.player.percent_text_font = value
			Plater.UpdateAllPlates()
		end
		
		local on_select_player_power_percent_text_font = function (_, _, value)
			Plater.db.profile.plate_config.player.power_percent_text_font = value
			Plater.UpdateAllPlates()
		end
		
		local _, _, _, iconWindWalker = GetSpecializationInfoByID (269)
		local _, _, _, iconArcane = GetSpecializationInfoByID (62)
		local _, _, _, iconRune = GetSpecializationInfoByID (250)
		local _, _, _, iconHolyPower = GetSpecializationInfoByID (66)
		local _, _, _, iconRogueCB = GetSpecializationInfoByID (261)
		local _, _, _, iconDruidCB = GetSpecializationInfoByID (103)
		local _, _, _, iconSoulShard = GetSpecializationInfoByID (267)
		
		local locClass = UnitClass ("player")
		
		local options_personal = {

			{type = "label", get = function() return "General Settings:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
			{
				type = "toggle",
				get = function() return Plater.db.profile.plate_config.player.click_through end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.player.click_through = value
					Plater.UpdateSelfPlate()
				end,
				name = "Click Through",
				desc = "Player nameplate won't receive mouse clicks.",
			},
			{
				type = "toggle",
				get = function() return GetCVarBool ("nameplatePersonalShowAlways") end,
				set = function (self, fixedparam, value) 
					if (value) then
						SetCVar ("nameplatePersonalShowAlways", CVAR_ENABLED)
					else
						SetCVar ("nameplatePersonalShowAlways", CVAR_DISABLED)
					end
				end,
				nocombat = true,
				name = "Always Show" .. CVarIcon,
				desc = "If enabled, the personal health bar is always shown.\n\n|cFFFFFF00Important|r: 'Personal Health and Mana Bars' (in the Main Menu tab) must be enabled." .. CVarDesc,
			},
			{
				type = "toggle",
				get = function() return GetCVarBool ("nameplatePersonalShowWithTarget") end,
				set = function (self, fixedparam, value) 
					if (value) then
						SetCVar ("nameplatePersonalShowWithTarget", CVAR_ENABLED)
					else
						SetCVar ("nameplatePersonalShowWithTarget", CVAR_DISABLED)
					end
				end,
				nocombat = true,
				name = "Show When you Have a Target" .. CVarIcon,
				desc = "If enabled, show the personal bar when you have a target.\n\n|cFFFFFF00Important|r: 'Personal Health and Mana Bars' (in the Main Menu tab) must be enabled." .. CVarDesc,
			},
			{
				type = "toggle",
				get = function() return GetCVarBool ("nameplatePersonalShowInCombat") end,
				set = function (self, fixedparam, value) 
					if (value) then
						SetCVar ("nameplatePersonalShowInCombat", CVAR_ENABLED)
					else
						SetCVar ("nameplatePersonalShowInCombat", CVAR_DISABLED)
					end
				end,
				nocombat = true,
				name = "Show In Combat" .. CVarIcon,
				desc = "If enabled, show the personal bar when you are in combat.\n\n|cFFFFFF00Important|r: 'Personal Health and Mana Bars' (in the Main Menu tab) must be enabled." .. CVarDesc,
			},
			{
				type = "range",
				get = function() return tonumber (GetCVar ("nameplateSelfAlpha")) end,
				set = function (self, fixedparam, value) 
					if (not InCombatLockdown()) then
						SetCVar ("nameplateSelfAlpha", value)
					else
						Plater:Msg ("you are in combat.")
					end
				end,
				min = 0.1,
				max = 1,
				step = 0.1,
				thumbscale = 1.7,
				usedecimals = true,
				name = "Alpha" .. CVarIcon,
				desc = "Alpha" .. CVarDesc,
				nocombat = true,
			},
			{
				type = "range",
				get = function() return tonumber (GetCVar ("nameplateSelfScale")) end,
				set = function (self, fixedparam, value) 
					if (not InCombatLockdown()) then
						SetCVar ("nameplateSelfScale", value)
					else
						Plater:Msg ("you are in combat.")
					end
				end,
				min = 0.5,
				max = 2.5,
				step = 0.1,
				thumbscale = 1.7,
				usedecimals = true,
				name = "Scale" .. CVarIcon,
				desc = "Scale" .. CVarDesc,
				nocombat = true,
			},

			{type = "blank"},
			
			{
				type = "toggle",
				get = function() return Plater.db.profile.aura_show_buffs_personal end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.aura_show_buffs_personal = value
					Plater.RefreshDBUpvalues()
					Plater.RefreshAuras()
					Plater.UpdateAllPlates()
				end,
				name = "Show Buffs on Personal Bar",
				desc = "Show buffs on you on the Personal Bar.",
			},
			
			{
				type = "toggle",
				get = function() return Plater.db.profile.aura_show_debuffs_personal end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.aura_show_debuffs_personal = value
					Plater.RefreshDBUpvalues()
					Plater.RefreshAuras()
					Plater.UpdateAllPlates()
				end,
				name = "Show Debuffs on Personal Bar",
				desc = "Show debuffs on you on the Personal Bar.",
			},			
			
			{type = "blank"},
		
			--life size
			{type = "label", get = function() return "Health Bar Size:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
			{
				type = "range",
				get = function() return Plater.db.profile.plate_config.player.health[1] end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.player.health[1] = value
					Plater.db.profile.plate_config.player.health_incombat[1] = value
					Plater.UpdateAllPlates (nil, true)
					Plater.UpdateSelfPlate()
				end,
				min = 50,
				max = 300,
				step = 1,
				name = "Width",
				desc = "Width of the health bar.",
			},
			{
				type = "range",
				get = function() return Plater.db.profile.plate_config.player.health[2] end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.player.health[2] = value
					Plater.db.profile.plate_config.player.health_incombat[2] = value
					Plater.UpdateAllPlates (nil, true)
					Plater.UpdateSelfPlate()
				end,
				min = 1,
				max = 100,
				step = 1,
				name = "Height",
				desc = "Height of the health bar.",
			},
			
			--mana size
			{type = "blank"},
			{type = "label", get = function() return "Power Bar Size:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
			{
				type = "range",
				get = function() return Plater.db.profile.plate_config.player.mana[1] end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.player.mana[1] = value
					Plater.db.profile.plate_config.player.mana_incombat[1] = value
					Plater.UpdateAllPlates()
					Plater.UpdateSelfPlate()
				end,
				min = 50,
				max = 300,
				step = 1,
				name = "Width",
				desc = "Width of the power bar.",
			},
			{
				type = "range",
				get = function() return Plater.db.profile.plate_config.player.mana[2] end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.player.mana[2] = value
					Plater.db.profile.plate_config.player.mana_incombat[2] = value
					Plater.UpdateAllPlates()
					Plater.UpdateSelfPlate()
				end,
				min = 1,
				max = 100,
				step = 1,
				name = "Height",
				desc = "Height of the power bar.",
			},
			{type = "blank"},
			
--	SetCVar ("nameplateSelfBottomInset", 20 / 100)
--	SetCVar ("nameplateSelfTopInset", abs (20 - 99) / 100)
			{type = "label", get = function() return "Personal Bar Constrain:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
			
			{
				type = "range",
				get = function() return tonumber (GetCVar ("nameplateSelfTopInset")*100) end,
				set = function (self, fixedparam, value) 
					--Plater.db.profile.plate_config.player.y_position_offset = value

					if (InCombatLockdown()) then
						Plater:Msg ("you are in combat.")
						self:SetValue (tonumber (GetCVar ("nameplateSelfTopInset")*100))
						return
					end

					--SetCVar ("nameplateSelfBottomInset", value / 100)
					SetCVar ("nameplateSelfTopInset", abs (value - 99) / 100)
					
					if (not Plater.PersonalAdjustLocationTop) then
						Plater.PersonalAdjustLocationTop = CreateFrame ("frame", "PlaterPersonalBarLocation", UIParent)
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
			},
			
			{
				type = "range",
				get = function() return tonumber (GetCVar ("nameplateSelfBottomInset")*100) end,
				set = function (self, fixedparam, value) 
					--Plater.db.profile.plate_config.player.y_position_offset = value

					if (InCombatLockdown()) then
						Plater:Msg ("you are in combat.")
						self:SetValue (tonumber (GetCVar ("nameplateSelfBottomInset")*100))
						return
					end

					SetCVar ("nameplateSelfBottomInset", value / 100)
					--SetCVar ("nameplateSelfTopInset", value / 100)
					
					if (not Plater.PersonalAdjustLocationBottom) then
						Plater.PersonalAdjustLocationBottom = CreateFrame ("frame", "PlaterPersonalBarLocation", UIParent)
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
			},

			{type = "blank"},
			{
				type = "range",
				get = function() return tonumber (GetCVar ("nameplateSelfBottomInset")*100) end,
				set = function (self, fixedparam, value) 
					--Plater.db.profile.plate_config.player.y_position_offset = value

					if (InCombatLockdown()) then
						Plater:Msg ("you are in combat.")
						self:SetValue (tonumber (GetCVar ("nameplateSelfBottomInset")*100))
						return
					end

					value = floor (value)
					
					SetCVar ("nameplateSelfBottomInset", value / 100)
					SetCVar ("nameplateSelfTopInset", abs (value - 99) / 100)
					
					if (not Plater.PersonalAdjustLocation) then
						Plater.PersonalAdjustLocation = CreateFrame ("frame", "PlaterPersonalBarLocation", UIParent)
						local frame = Plater.PersonalAdjustLocation
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
						frame.Text:SetText ("Plater: Personal Bar Position")
						frame.Text:SetPoint ("center")
						
						frame.HideAnimation = DF:CreateAnimationHub (frame, nil, function() frame:Hide() end)
						DF:CreateAnimation (frame.HideAnimation, "Alpha", 1, 1, 1, 0)
						
						frame.CancelFunction = function()
							frame.HideAnimation:Play()
						end
					end
					
					if (Plater.PersonalAdjustLocation.HideAnimation:IsPlaying()) then
						Plater.PersonalAdjustLocation.HideAnimation:Stop()
						Plater.PersonalAdjustLocation:SetAlpha (1)
					end
					Plater.PersonalAdjustLocation:Show()
					
					local percentValue = GetScreenHeight()/100
					Plater.PersonalAdjustLocation:SetPoint ("bottom", UIParent, "bottom", 0, percentValue * value)
					
					if (Plater.PersonalAdjustLocation.Timer) then
						Plater.PersonalAdjustLocation.Timer:Cancel()
					end
					Plater.PersonalAdjustLocation.Timer = C_Timer.NewTimer (7, Plater.PersonalAdjustLocation.CancelFunction)
					
					Plater.UpdateAllPlates()
					Plater.UpdateSelfPlate()
				end,
				min = 2,
				max = 98,
				step = 1,
				nocombat = true,
				name = "Fixed Position" .. CVarIcon,
				desc = "Set a fixed position, the personal bar won't move." .. CVarDesc,
			},
--]=]

			{type = "breakline"},
			
			--percent text
			{type = "label", get = function() return "Health Text:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
			--enabled
			{
				type = "toggle",
				get = function() return Plater.db.profile.plate_config.player.percent_text_enabled end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.player.percent_text_enabled = value
					Plater.UpdateAllPlates()
				end,
				name = "Enabled",
				desc = "Show the percent text.",
			},
			--percent text size
			{
				type = "range",
				get = function() return Plater.db.profile.plate_config.player.percent_text_size end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.player.percent_text_size = value
					Plater.UpdateAllPlates()
				end,
				min = 6,
				max = 99,
				step = 1,
				name = "Size",
				desc = "Size of the text.",
			},
			--percent text font
			{
				type = "select",
				get = function() return Plater.db.profile.plate_config.player.percent_text_font end,
				values = function() return DF:BuildDropDownFontList (on_select_player_percent_text_font) end,
				name = "Font",
				desc = "Font of the text.",
			},
			--percent text shadow
			{
				type = "toggle",
				get = function() return Plater.db.profile.plate_config.player.percent_text_shadow end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.player.percent_text_shadow = value
					Plater.UpdateAllPlates()
				end,
				name = "Shadow",
				desc = "If the text has a black outline.",
			},
			--pecent text color
			{
				type = "color",
				get = function()
					local color = Plater.db.profile.plate_config.player.percent_text_color
					return {color[1], color[2], color[3], color[4]}
				end,
				set = function (self, r, g, b, a) 
					local color = Plater.db.profile.plate_config.player.percent_text_color
					color[1], color[2], color[3], color[4] = r, g, b, a
					Plater.UpdateAllPlates()
				end,
				name = "Color",
				desc = "The color of the text.",
			},
			--percent text alpha
			{
				type = "range",
				get = function() return Plater.db.profile.plate_config.player.percent_text_alpha end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.player.percent_text_alpha = value
					Plater.UpdateAllPlates()
				end,
				min = 0,
				max = 1,
				step = 0.1,
				name = "Alpha",
				desc = "Set the transparency of the text.",
				usedecimals = true,
			},
			--percent anchor
			{
				type = "select",
				get = function() return Plater.db.profile.plate_config.player.percent_text_anchor.side end,
				values = function() return build_anchor_side_table ("player", "percent_text_anchor") end,
				name = "Anchor",
				desc = "Which side of the nameplate this widget is attach to.",
			},
			--percent anchor x offset
			{
				type = "range",
				get = function() return Plater.db.profile.plate_config.player.percent_text_anchor.x end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.player.percent_text_anchor.x = value
					Plater.UpdateAllPlates()
				end,
				min = -20,
				max = 20,
				step = 1,
				name = "X Offset",
				desc = "Slightly move the text horizontally.",
			},
			--percent anchor x offset
			{
				type = "range",
				get = function() return Plater.db.profile.plate_config.player.percent_text_anchor.y end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.player.percent_text_anchor.y = value
					Plater.UpdateAllPlates()
				end,
				min = -20,
				max = 20,
				step = 1,
				name = "Y Offset",
				desc = "Slightly move the text vertically.",
			},
			
			{type = "blank"},
			{type = "label", get = function() return "Power Percent Text:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
			--enabled
			{
				type = "toggle",
				get = function() return Plater.db.profile.plate_config.player.power_percent_text_enabled end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.player.power_percent_text_enabled = value
					Plater.UpdateAllPlates()
				end,
				name = "Enabled",
				desc = "Show the percent text.",
			},
			--percent text size
			{
				type = "range",
				get = function() return Plater.db.profile.plate_config.player.power_percent_text_size end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.player.power_percent_text_size = value
					Plater.UpdateAllPlates()
				end,
				min = 6,
				max = 99,
				step = 1,
				name = "Size",
				desc = "Size of the text.",
			},
			--percent text font
			{
				type = "select",
				get = function() return Plater.db.profile.plate_config.player.power_percent_text_font end,
				values = function() return DF:BuildDropDownFontList (on_select_player_power_percent_text_font) end,
				name = "Font",
				desc = "Font of the text.",
			},
			--percent text shadow
			{
				type = "toggle",
				get = function() return Plater.db.profile.plate_config.player.power_percent_text_shadow end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.player.power_percent_text_shadow = value
					Plater.UpdateAllPlates()
				end,
				name = "Shadow",
				desc = "If the text has a black outline.",
			},
			--pecent text color
			{
				type = "color",
				get = function()
					local color = Plater.db.profile.plate_config.player.power_percent_text_color
					return {color[1], color[2], color[3], color[4]}
				end,
				set = function (self, r, g, b, a) 
					local color = Plater.db.profile.plate_config.player.power_percent_text_color
					color[1], color[2], color[3], color[4] = r, g, b, a
					Plater.UpdateAllPlates()
				end,
				name = "Color",
				desc = "The color of the text.",
			},
			--percent text alpha
			{
				type = "range",
				get = function() return Plater.db.profile.plate_config.player.power_percent_text_alpha end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.player.power_percent_text_alpha = value
					Plater.UpdateAllPlates()
				end,
				min = 0,
				max = 1,
				step = 0.1,
				name = "Alpha",
				desc = "Set the transparency of the text.",
				usedecimals = true,
			},
			--percent anchor
			{
				type = "select",
				get = function() return Plater.db.profile.plate_config.player.power_percent_text_anchor.side end,
				values = function() return build_anchor_side_table ("player", "power_percent_text_anchor") end,
				name = "Anchor",
				desc = "Which side of the nameplate this widget is attach to.",
			},
			--percent anchor x offset
			{
				type = "range",
				get = function() return Plater.db.profile.plate_config.player.power_percent_text_anchor.x end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.player.power_percent_text_anchor.x = value
					Plater.UpdateAllPlates()
				end,
				min = -20,
				max = 20,
				step = 1,
				name = "X Offset",
				desc = "Slightly move the text horizontally.",
			},
			--percent anchor x offset
			{
				type = "range",
				get = function() return Plater.db.profile.plate_config.player.power_percent_text_anchor.y end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.player.power_percent_text_anchor.y = value
					Plater.UpdateAllPlates()
				end,
				min = -20,
				max = 20,
				step = 1,
				name = "Y Offset",
				desc = "Slightly move the text vertically.",
			},		

			{type = "breakline"},
			
			--class resources
			{type = "label", get = function() return "Resources:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},

			{
				type = "range",
				get = function() return Plater.db.profile.resources.scale end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.resources.scale = value
					Plater.UpdateAllPlates()
					Plater.UpdateManaAndResourcesBar()
				end,
				min = 0.65,
				max = 3,
				step = 0.01,
				usedecimals = true,
				nocombat = true,
				name = "Resource Scale",
				desc = "Resource Scale",
			},
			
			{
				type = "range",
				get = function() return Plater.db.profile.resources.y_offset end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.resources.y_offset = value
					Plater.UpdateAllPlates()
					Plater.UpdateManaAndResourcesBar()
				end,
				min = -40,
				max = 40,
				step = 1,
				nocombat = true,
				name = "Y OffSet on Personal Bar",
				desc = "Y Offset when resource bar are anchored to your personal bar",
			},
			
			{
				type = "range",
				get = function() return Plater.db.profile.resources.y_offset_target end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.resources.y_offset_target = value
					Plater.UpdateAllPlates()
					Plater.UpdateManaAndResourcesBar()
				end,
				min = -40,
				max = 40,
				step = 1,
				nocombat = true,
				name = "Y OffSet on Target",
				desc = "Y Offset when the resource are anchored on your current target",
			},
			
			

	}

	DF:BuildMenu (personalPlayerFrame, options_personal, startX, startY, heightSize, true, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template, globalCallback)
end

-------------------------------------------------------------------------------
--coloca as opï¿½ï¿½es gerais no main menu logo abaixo dos 4 botï¿½es
--OPï¿½ï¿½ES NO PAINEL PRINCIPAL

function Plater.ChangeNpcRelavance (_, _, value)
	if (value == 3) then
		Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_NPC].only_names = true
		Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_NPC].all_names = false
		
	elseif (value == 4) then
		Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_NPC].only_names = false
		Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_NPC].all_names = true
	end
	
	Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_NPC].relevance_state = value
	
	Plater.UpdateAllPlates()
end
local relevance_options = {
	{label = "All Professions", value = 3, onclick = Plater.ChangeNpcRelavance},
	{label = "All Npcs", value = 4, onclick = Plater.ChangeNpcRelavance},
}

local on_select_target_indicator = function (_, _, indicator)
	Plater.db.profile.target_indicator = indicator
	Plater.OnPlayerTargetChanged()
end
local indicator_table = {}
for name, indicatoirTable in pairs (TargetIndicators) do
	tinsert (indicator_table, {label = name, value = name, onclick = on_select_target_indicator, icon = indicatoirTable.path, texcoord = indicatoirTable.coords[1]})
end
local build_target_indicator_table = function()
	return indicator_table
end


--
	local focus_indicator_texture_selected = function (self, capsule, value)
		Plater.db.profile.focus_texture = value
		Plater.OnPlayerTargetChanged()
	end
	local focus_indicator_texture_options = {}
	for name, texturePath in pairs (textures) do 
		focus_indicator_texture_options [#focus_indicator_texture_options + 1] = {value = name, label = name, statusbar = texturePath, onclick = focus_indicator_texture_selected}
	end
	table.sort (focus_indicator_texture_options, function (t1, t2) return t1.label < t2.label end)
--
	local on_select_castbar_target_font = function (_, _, value)
		Plater.db.profile.castbar_target_font = value
		Plater.UpdateAllPlates()
	end
	
	--menu 1 ~general ~geral
	local options_table1 = {
	
		{type = "label", get = function() return "Health Bar Appearance:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "select",
			get = function() return Plater.db.profile.health_statusbar_texture end,
			values = function() return health_bar_texture_options end,
			name = "Health Bar Texture",
			desc = "Texture used on the health bar",
		},
		{
			type = "select",
			get = function() return Plater.db.profile.health_statusbar_bgtexture end,
			values = function() return health_bar_bgtexture_options end,
			name = "Health Bar Background Texture",
			desc = "Texture used on the health bar background",
		},
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.health_statusbar_bgcolor
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.health_statusbar_bgcolor
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllPlates()
			end,
			name = "Health Bar Background Color and Alpha",
			desc = "Color used to paint the health bar background.",
		},
		
		{type = "blank"},
		{type = "label", get = function() return "Cast Bar Appearance:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		
		{
			type = "select",
			get = function() return Plater.db.profile.cast_statusbar_texture end,
			values = function() return cast_bar_texture_options end,
			name = "Cast Bar Texture",
			desc = "Texture used on the cast bar",
		},
		{
			type = "select",
			get = function() return Plater.db.profile.cast_statusbar_bgtexture end,
			values = function() return cast_bar_bgtexture_options end,
			name = "Cast Bar Background Texture",
			desc = "Texture used on the cast bar background.",
		},
		
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.cast_statusbar_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.cast_statusbar_color
				color[1], color[2], color[3], color[4] = r, g, b, a
			end,
			name = "Cast Bar Color",
			desc = "Cast Bar Color",
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
			end,
			name = "Cast Bar Color No Interrupt",
			desc = "Cast Bar Color No Interrupt",
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
			end,
			name = "Cast Bar Background Color",
			desc = "Color used to paint the cast bar background.",
		},

		--toggle cast bar target
		{
			type = "toggle",
			get = function() return Plater.db.profile.castbar_target_show end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.castbar_target_show = value
				Plater.UpdateUseCastBar()
			end,
			name = "Show Target Name",
			desc = "Show who is the target of the current cast (if available)",
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
			name = "Target Name Size",
			desc = "Target Name Size",
		},
		--text font
		{
			type = "select",
			get = function() return Plater.db.profile.castbar_target_font end,
			values = function() return DF:BuildDropDownFontList (on_select_castbar_target_font) end,
			name = "Target Name Font",
			desc = "Target Name Font",
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
			name = "Target Name Color",
			desc = "Target Name Color",
		},
		--cast text shadow
		{
			type = "toggle",
			get = function() return Plater.db.profile.castbar_target_shadow end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.castbar_target_shadow = value
				Plater.UpdateAllPlates()
			end,
			name = "Target Name Shadow",
			desc = "Target Name Shadow",
		},		
		{
			type = "select",
			get = function() return Plater.db.profile.castbar_target_anchor.side end,
			values = function() return build_anchor_side_table (nil, "castbar_target_anchor") end,
			name = "Target Name Anchor",
			desc = "Which side of the cast bar this widget is attach to.",
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
			name = "Target Name X Offset",
			desc = "Target Name X Offset",
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
			name = "Target Name Y Offset",
			desc = "Target Name Y Offset",
		},


		{type = "breakline"},
		{type = "label", get = function() return "Indicators:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		
		{
			type = "toggle",
			get = function() return Plater.db.profile.indicator_faction end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.indicator_faction = value
				Plater.UpdateAllPlates()
			end,
			name = "Enemy Faction Icon",
			desc = "Show horde or alliance icon.",
		},
		
		{
			type = "toggle",
			get = function() return Plater.db.profile.health_cutoff end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.health_cutoff = value
				Plater.UpdateAllPlates()
			end,
			name = "Execute Range",
			desc = "Show an indicator when the unit is in execute range.\n\nPlater auto detects execute range for:\n\n|cFFFFFF00Hunter|r: Beast Master spec with Killer Instinct talent.\n\n|cFFFFFF00Warrior|r: Arms and Fury specs.\n\n|cFFFFFF00Priest|r: Shadow spec with Shadow Word: Death talent.\n\n|cFFFFFF00Mage|r: Fire spec with Searing Touch talent.",
		},

		
		{
			type = "toggle",
			get = function() return Plater.db.profile.indicator_elite end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.indicator_elite = value
				Plater.UpdateAllPlates()
			end,
			name = "Elite Icon",
			desc = "Show when the actor is elite.",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.indicator_rare end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.indicator_rare = value
				Plater.UpdateAllPlates()
			end,
			name = "Rare Icon",
			desc = "Show when the actor is rare.",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.indicator_quest end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.indicator_quest = value
				Plater.UpdateAllPlates()
			end,
			name = "Quest Icon",
			desc = "Show when the actor is a boss for a quest.",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.indicator_enemyclass end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.indicator_enemyclass = value
				Plater.UpdateAllPlates()
			end,
			name = "Enemy Class",
			desc = "Enemy player class icon.",
		},
		
		{
			type = "toggle",
			get = function() return Plater.db.profile.indicator_spec end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.indicator_spec = value
				Plater.UpdateAllPlates()
			end,
			name = "Enemy Spec",
			desc = "Enemy player spec icon.\n\n|cFFFFFF00Important|r: must have Details! Damage Meter installed.",
		},
		--

		--indicator icon anchor
		{
			type = "select",
			get = function() return Plater.db.profile.indicator_anchor.side end,
			values = function() return build_anchor_side_table (nil, "indicator_anchor") end,
			name = "Anchor",
			desc = "Which side of the nameplate this widget is attach to.",
		},
		--indicator icon anchor x offset
		{
			type = "range",
			get = function() return Plater.db.profile.indicator_anchor.x end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.indicator_anchor.x = value
				Plater.UpdateAllPlates()
			end,
			min = -20,
			max = 20,
			step = 1,
			name = "X Offset",
			desc = "Slightly move horizontally.",
		},
		--indicator icon anchor y offset
		{
			type = "range",
			get = function() return Plater.db.profile.indicator_anchor.y end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.indicator_anchor.y = value
				Plater.UpdateAllPlates()
			end,
			min = -20,
			max = 20,
			step = 1,
			name = "Y Offset",
			desc = "Slightly move vertically.",
		},
		
		{type = "blank"},
		
		{type = "label", get = function() return "Raid Mark:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		
		{
			type = "range",
			get = function() return Plater.db.profile.indicator_raidmark_scale end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.indicator_raidmark_scale = value
				Plater.UpdateAllPlates()
			end,
			min = 0.2,
			max = 2,
			step = 0.1,
			usedecimals = true,
			name = "Scale",
			desc = "Scale",
		},
		
		--indicator icon anchor
		{
			type = "select",
			get = function() return Plater.db.profile.indicator_raidmark_anchor.side end,
			values = function() return build_anchor_side_table (nil, "indicator_raidmark_anchor") end,
			name = "Anchor",
			desc = "Which side of the nameplate this widget is attach to.",
		},
		--indicator icon anchor x offset
		{
			type = "range",
			get = function() return Plater.db.profile.indicator_raidmark_anchor.x end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.indicator_raidmark_anchor.x = value
				Plater.UpdateAllPlates()
			end,
			min = -20,
			max = 20,
			step = 1,
			name = "X Offset",
			desc = "Slightly move horizontally.",
		},
		--indicator icon anchor y offset
		{
			type = "range",
			get = function() return Plater.db.profile.indicator_raidmark_anchor.y end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.indicator_raidmark_anchor.y = value
				Plater.UpdateAllPlates()
			end,
			min = -20,
			max = 20,
			step = 1,
			name = "Y Offset",
			desc = "Slightly move vertically.",
		},
		
		{
			type = "toggle",
			get = function() return Plater.db.profile.indicator_extra_raidmark end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.indicator_extra_raidmark = value
				Plater.UpdateAllPlates()
				Plater.UpdateRaidMarker()
			end,
			name = "Extra Raid Mark",
			desc = "Places an extra raid mark icon inside the health bar.",
		},
		
		{type = "breakline"},
		
		{type = "label", get = function() return "Target:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		
		--target texture
		{
			type = "select",
			get = function() return Plater.db.profile.health_selection_overlay end,
			values = function() return health_selection_overlay_options end,
			name = "Target Overlay Texture",
			desc = "Used above the health bar when it is the current target.",
		},
		
		{
			type = "toggle",
			get = function() return GetCVarBool ("nameplateTargetRadialPosition") end,
			set = function (self, fixedparam, value) 
				if (value) then
					SetCVar ("nameplateTargetRadialPosition", CVAR_ENABLED)
				else
					SetCVar ("nameplateTargetRadialPosition", CVAR_DISABLED)
				end
			end,
			nocombat = true,
			name = "Target Always on the Screen",
			desc = "When enabled, the nameplate of your target is always shown even when the enemy isn't in the screen.",
		},
		{
			type = "range",
			get = function() return tonumber (GetCVar ("nameplateSelectedScale")) end,
			set = function (self, fixedparam, value) 
				if (not InCombatLockdown()) then
					SetCVar ("nameplateSelectedScale", value)
				else
					Plater:Msg ("you are in combat.")
				end
			end,
			min = 0.75,
			max = 1.75,
			step = 0.1,
			thumbscale = 1.7,
			usedecimals = true,
			name = "Target Scale",
			desc = "The nameplate size for the current target is multiplied by this value.\n\n|cFFFFFFFFDefault: 1|r\n\n|cFFFFFFFFRecommended: 1.15|r",
			nocombat = true,
		},		

		{type = "blank"},
		
		{
			type = "toggle",
			get = function() return Plater.db.profile.hover_highlight end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.hover_highlight = value
				Plater.RefreshDBUpvalues()
				Plater.UpdateAllPlates()
			end,
			name = "Hover Over Highlight",
			desc = "Highlight effect when the mouse is over the nameplate.\n\n|cFFFFFF00Important|r: for enemies only (players and npcs).",
		},
		{
			type = "range",
			get = function() return Plater.db.profile.hover_highlight_alpha end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.hover_highlight_alpha = value
				Plater.UpdateAllPlates()
			end,
			min = 0,
			max = 1,
			step = 0.1,
			name = "Hover Over Highlight Alpha",
			desc = "Hover Over Highlight Alpha",
			usedecimals = true,
		},
		
		{type = "blank"},
		
		{
			type = "toggle",
			get = function() return Plater.db.profile.target_highlight end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.target_highlight = value
				Plater.UpdateAllPlates()
			end,
			name = "Target Highlight",
			desc = "Highlight effect on the nameplate of your current target.",
		},
		{
			type = "range",
			get = function() return Plater.db.profile.target_highlight_alpha end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.target_highlight_alpha = value
				Plater.OnPlayerTargetChanged()
			end,
			min = 0,
			max = 1,
			step = 0.1,
			name = "Target Highlight Alpha",
			desc = "Target Highlight Alpha.",
			usedecimals = true,
		},
		
		{
			type = "select",
			get = function() return Plater.db.profile.target_indicator end,
			values = function() return build_target_indicator_table() end,
			name = "Target Indicator",
			desc = "Target Indicator",
		},
		
		{type = "blank"},
		
		--target alpha
		{
			type = "toggle",
			get = function() return Plater.db.profile.target_shady_enabled end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.target_shady_enabled = value
				Plater.RefreshDBUpvalues()
				Plater.OnPlayerTargetChanged()
				--update
			end,
			name = "Target Shading",
			desc = "Apply a layer of shadow above the nameplate when the unit is in range but isn't your current target.",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.target_shady_combat_only end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.target_shady_combat_only = value
				Plater.RefreshDBUpvalues()
				Plater.OnPlayerTargetChanged()
				--update
			end,
			name = "Target Shading Only in Combat",
			desc = "Apply target shading only when in combat.",
		},
		{
			type = "range",
			get = function() return Plater.db.profile.target_shady_alpha end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.target_shady_alpha = value
				Plater.RefreshDBUpvalues()
				Plater.OnPlayerTargetChanged()
				--update
			end,
			min = 0,
			max = 1,
			step = 0.1,
			name = "Target Shading Amount",
			desc = "Amount of shade to apply.",
			usedecimals = true,
		},		
		
		
		{type = "breakline"},
		
		{type = "label", get = function() return "Focus:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		
		{
			type = "toggle",
			get = function() return Plater.db.profile.focus_indicator_enabled end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.focus_indicator_enabled = value
				Plater.OnPlayerTargetChanged()
			end,
			name = "Show Focus Overlay",
			desc = "Focus Indicator",
		},
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.focus_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.focus_color
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.OnPlayerTargetChanged()
			end,
			name = "Color",
			desc = "Focus Color",
		},
		{
			type = "select",
			get = function() return Plater.db.profile.focus_texture end,
			values = function() return focus_indicator_texture_options end,
			name = "Texture",
			desc = "Focus Texture",
		},
		
		{type = "blank"},
		
		
		{type = "label", get = function() return "Alpha Control:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},

		--alpha and range check
		{
			type = "toggle",
			get = function() return Plater.db.profile.not_affecting_combat_enabled end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.not_affecting_combat_enabled = value
				Plater.UpdateAllPlates()
			end,
			name = "Use No Combat Alpha",
			desc = "Changes the nameplate alpha when you are in combat and the unit isn't.\n\n|cFFFFFF00Important|r: If the unit isn't in combat, it overrides the alpha from the range check.",
		},
		{
			type = "range",
			get = function() return Plater.db.profile.not_affecting_combat_alpha end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.not_affecting_combat_alpha = value
				Plater.UpdateAllPlates()
			end,
			min = 0,
			max = 1,
			step = 0.1,
			name = "No Combat Alpha",
			desc = "Amount of transparency to apply for 'No Combat' feature.",
			usedecimals = true,
		},
		
		{type = "blank"},
		
		
		{
			type = "toggle",
			get = function() return Plater.db.profile.range_check_enabled end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.range_check_enabled = value
				Plater.RefreshDBUpvalues()
				Plater.UpdateAllPlates()
			end,
			name = "Use Range Check",
			desc = "Units that are out of range has their nameplates more transparent (adjust the amount in the slider below).\n\n|cFFFFFF00Important|r: check which spell you want to use to check the range.",
		},
		{
			type = "range",
			get = function() return Plater.db.profile.range_check_alpha end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.range_check_alpha = value
				Plater.RefreshDBUpvalues()
				Plater.UpdateAllPlates()
			end,
			min = 0,
			max = 1,
			step = 0.1,
			name = "Out of Range Alpha",
			desc = "Amount of alpha to apply when the unit is out of range.\n\n|cFFFFFF001.0|r: full opaque.\n|cFFFFFF00Zero|r: full transparent.",
			usedecimals = true,
		},
	}
	
	--tinsert (options_table1, {type = "blank"})
	--tinsert (options_table1, {type = "label", get = function() return "Spells for Range Check" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")})
	
	local spells = {}
	local offset
	for i = 2, GetNumSpellTabs() do
		local name, texture, offset, numEntries, isGuild, offspecID = GetSpellTabInfo (i)
		local tabEnd = offset + numEntries
		offset = offset + 1
		for j = offset, tabEnd - 1 do
			local spellType, spellID = GetSpellBookItemInfo (j, "player")
			if (spellType == "SPELL") then
				tinsert (spells, spellID)
			end
		end
	end
	
	local playerSpecs = Plater.SpecList [select (2, UnitClass ("player"))]
	local i = 1
	for specID, _ in pairs (playerSpecs) do
		local spec_id, spec_name, spec_description, spec_icon, spec_background, spec_role, spec_class = GetSpecializationInfoByID (specID)
		tinsert (options_table1, {
			type = "select",
			get = function() return PlaterDBChr.spellRangeCheck [specID] end,
			values = function() 
				local onSelectFunc = function (_, _, spellName)
					PlaterDBChr.spellRangeCheck [specID] = spellName
					Plater.GetSpellForRangeCheck()
				end
				local t = {}
				for _, spellID in ipairs (spells) do
					local spellName, _, spellIcon = GetSpellInfo (spellID)
					tinsert (t, {label = spellName, icon = spellIcon, onclick = onSelectFunc, value = spellName})
				end
				return t
			end,
			name = "|T" .. spec_icon .. ":16:16|t Range Check",
			desc = "Spell to range check on this specializartion.",
		})
		i = i + 1
	end	
	
	DF:BuildMenu (generalOptionsAnchor, options_table1, 0, 0, mainHeightSize, true, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template, globalCallback)
	
------------------------------------------------	
--order functions

	local on_select_friendlyplayer_order = function (_, _, value)
		Plater.db.profile.plate_config.friendlyplayer.order = value
		Plater.UpdateAllPlates()
	end
	local on_select_friendlynpc_order = function (_, _, value)
		Plater.db.profile.plate_config.friendlynpc.order = value
		Plater.UpdateAllPlates()
	end	
	local on_select_enemyplayer_order = function (_, _, value)
		Plater.db.profile.plate_config.enemyplayer.order = value
		Plater.UpdateAllPlates()
	end
	local on_select_enemynpc_order = function (_, _, value)
		Plater.db.profile.plate_config.enemynpc.order = value
		Plater.UpdateAllPlates()
	end
	
	--anchor table
	local order_names = {"Debuffs, Health Bar, Cast Bar", "Health Bar, Debuffs, Cast Bar", "Cast Bar, Health Bar, Debuffs"}
	local build_order_options = function (actorType)
		local t = {}
		for i = 1, 3 do
			tinsert (t, {
				label = order_names[i], 
				value = i, 
				onclick = function (_, _, value)
					Plater.db.profile.plate_config [actorType].plate_order = value
					Plater.UpdateAllPlates()
				end
			})
		end
		return t
	end
	
------------------------------------------------	
--FriendlyPC painel de opï¿½ï¿½es ~friendly ~friendlynpc
	
	local on_select_friendly_playername_font = function (_, _, value)
		Plater.db.profile.plate_config.friendlyplayer.actorname_text_font = value
		Plater.UpdateAllPlates()
	end
	local on_select_friendly_playercastname_font = function (_, _, value)
		Plater.db.profile.plate_config.friendlyplayer.spellname_text_font = value
		Plater.UpdateAllPlates()
	end
	local on_select_friendlyplayer_level_text_font = function (_, _, value)
		Plater.db.profile.plate_config.friendlyplayer.level_text_font = value
		Plater.UpdateAllPlates()
	end
	local on_select_friendlyplayer_percent_text_font = function (_, _, value)
		Plater.db.profile.plate_config.friendlyplayer.percent_text_font = value
		Plater.UpdateAllPlates()
	end
	local on_select_friendlyplayer_spellpercent_text_font = function (_, _, value)
		Plater.db.profile.plate_config.friendlyplayer.spellpercent_text_font = value
		Plater.UpdateAllPlates()
	end

	local options_table3 = {
	
	
		{type = "label", get = function() return "General Settings:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "toggle",
			get = function() return Plater.db.profile.use_playerclass_color end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.use_playerclass_color = value
				Plater.UpdateUseClassColors()
				Plater.UpdateAllPlates()
			end,
			name = "Use Class Colors",
			desc = "Player name plates uses the player class color",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_PLAYER].only_damaged end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_PLAYER].only_damaged = value
				Plater.UpdateAllPlates()
			end,
			name = "Only Damaged Players",
			desc = "Hide the health bar when a friendly character has full health.",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_PLAYER].only_thename end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_PLAYER].only_thename = value
				Plater.UpdateAllPlates()
			end,
			name = "Only Show Player Name",
			desc = "Hide the health bar, only show the character name.\n\n|cFFFFFF00Important|r: overrides 'Only Damaged Players'.",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.show_guild_name end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.show_guild_name = value
				Plater.UpdateAllPlates (true)
			end,
			name = "Show Guild Name",
			desc = "Show Guild Name",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.click_through end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.click_through = value
				Plater.UpdatePlateClickSpace (nil, true)
			end,
			name = "Click Through",
			desc = "Friendly player nameplates won't receive mouse clicks.\n\n|cFFFFFF00Important|r: also affects friendly npcs and can affect some neutral npcs too.",
		},		

		{type = "blank"},
		{type = "label", get = function() return "Plate Order:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		--plate order
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.plate_order end,
			values = function() return build_order_options ("friendlyplayer") end,
			name = "Order",
			desc = "How the health, cast and buff bars are ordered.\n\nFrom bottom (near the character head) to top.",
		},
		
		{type = "blank"},
		{type = "label", get = function() return "Buff Frame:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		--y offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.buff_frame_y_offset end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.buff_frame_y_offset = value
				Plater.UpdateAllPlates()
			end,
			min = -64,
			max = 64,
			step = 1,
			name = "Y Offset",
			desc = "Adjusts the position on the Y axis.",
		},
		
		{type = "breakline"},
	
		--health bar size out of combat
		{type = "label", get = function() return "Health Bar Size out of Combat:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.health[1] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.health[1] = value
				Plater.UpdateAllPlates (nil, true)
			end,
			min = 50,
			max = 300,
			step = 1,
			name = "Width",
			desc = "Width of the health bar when out of combat.",
		},
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.health[2] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.health[2] = value
				Plater.UpdateAllPlates (nil, true)
			end,
			min = 1,
			max = 100,
			step = 1,
			name = "Height",
			desc = "Height of the health bar when out of combat.",
		},
		
		--health bar size in combat
		{type = "label", get = function() return "Health Bar Size in Combat:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.health_incombat[1] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.health_incombat[1] = value
				Plater.UpdateAllPlates (nil, true)
			end,
			min = 50,
			max = 300,
			step = 1,
			name = "Width",
			desc = "Width of the health bar when in combat.",
		},
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.health_incombat[2] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.health_incombat[2] = value
				Plater.UpdateAllPlates (nil, true)
			end,
			min = 1,
			max = 100,
			step = 1,
			name = "Height",
			desc = "Height of the health bar when in combat.",
		},
		
		{type = "blank"},
		
		--cast bar size out of combat
		{type = "label", get = function() return "Cast Bar Size out of Combat:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.cast[1] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.cast[1] = value
				Plater.UpdateAllPlates()
			end,
			min = 50,
			max = 300,
			step = 1,
			name = "Width",
			desc = "Width of the cast bar when out of combat.",
		},
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.cast[2] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.cast[2] = value
				Plater.UpdateAllPlates()
			end,
			min = 1,
			max = 100,
			step = 1,
			name = "Height",
			desc = "Height of the cast bar when out of combat.",
		},
		--cast bar size out of combat
		{type = "label", get = function() return "Cast Bar Size in Combat:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.cast_incombat[1] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.cast_incombat[1] = value
				Plater.UpdateAllPlates()
			end,
			min = 50,
			max = 300,
			step = 1,
			name = "Width",
			desc = "Width of the cast bar when in combat.",
		},
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.cast_incombat[2] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.cast_incombat[2] = value
				Plater.UpdateAllPlates()
			end,
			min = 1,
			max = 100,
			step = 1,
			name = "Height",
			desc = "Height of the cast bar when in combat.",
		},
		
		{type = "blank"},
		--player name size
		{type = "label", get = function() return "Player Name Text:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.actorname_text_size end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.actorname_text_size = value
				Plater.db.profile.plate_config.friendlyplayer.actorname_text_spacing = value-1
				Plater.UpdateAllPlates()
			end,
			min = 6,
			max = 99,
			step = 1,
			name = "Size",
			desc = "Size of the text.",
		},
		--player name font
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.actorname_text_font end,
			values = function() return DF:BuildDropDownFontList (on_select_friendly_playername_font) end,
			name = "Font",
			desc = "Font of the text.",
		},
		--player name color
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.plate_config.friendlyplayer.actorname_text_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.plate_config.friendlyplayer.actorname_text_color
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllPlates()
			end,
			name = "Color",
			desc = "The color of the text.",
		},
		--player name shadow
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.actorname_text_shadow end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.actorname_text_shadow = value
				Plater.UpdateAllPlates()
			end,
			name = "Shadow",
			desc = "If the text has a black outline.",
		},
		
		--npc name anchor
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.actorname_text_anchor.side end,
			values = function() return build_anchor_side_table ("friendlyplayer", "actorname_text_anchor") end,
			name = "Anchor",
			desc = "Which side of the nameplate this widget is attach to.",
		},
		--npc name anchor x offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.actorname_text_anchor.x end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.actorname_text_anchor.x = value
				Plater.UpdateAllPlates()
			end,
			min = -20,
			max = 20,
			step = 1,
			name = "X Offset",
			desc = "Slightly move the text horizontally.",
		},
		--npc name anchor x offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.actorname_text_anchor.y end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.actorname_text_anchor.y = value
				Plater.UpdateAllPlates()
			end,
			min = -20,
			max = 20,
			step = 1,
			name = "Y Offset",
			desc = "Slightly move the text vertically.",
		},	
		
		--cast text size
		{type = "breakline"},
		
		--cast text size
		{type = "label", get = function() return "Spell Name Text:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.spellname_text_size end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.spellname_text_size = value
				Plater.UpdateAllPlates()
			end,
			min = 6,
			max = 99,
			step = 1,
			name = "Size",
			desc = "Size of the text.",
		},
		--cast text font
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.spellname_text_font end,
			values = function() return DF:BuildDropDownFontList (on_select_friendly_playercastname_font) end,
			name = "Font",
			desc = "Font of the text.",
		},
		--cast text color
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.plate_config.friendlyplayer.spellname_text_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.plate_config.friendlyplayer.spellname_text_color
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllPlates()
			end,
			name = "Color",
			desc = "The color of the text.",
		},
		--cast text shadow
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.spellname_text_shadow end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.spellname_text_shadow = value
				Plater.UpdateAllPlates()
			end,
			name = "Shadow",
			desc = "If the text has a black outline.",
		},
		
		{type = "blank"},
		{type = "label", get = function() return "Spell Cast Time Text:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.spellpercent_text_enabled end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.spellpercent_text_enabled = value
				Plater.UpdateAllPlates()
			end,
			name = "Enabled",
			desc = "Show the cast time progress.",
		},
		--cast time text
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.spellpercent_text_size end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.spellpercent_text_size = value
				Plater.UpdateAllPlates()
			end,
			min = 6,
			max = 99,
			step = 1,
			name = "Size",
			desc = "Size of the text.",
		},
		--cast time text font
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.spellpercent_text_font end,
			values = function() return DF:BuildDropDownFontList (on_select_friendlyplayer_spellpercent_text_font) end,
			name = "Font",
			desc = "Font of the text.",
		},
		--cast time text shadow
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.spellpercent_text_shadow end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.spellpercent_text_shadow = value
				Plater.UpdateAllPlates()
			end,
			name = "Shadow",
			desc = "If the text has a black outline.",
		},
		--cast time text color
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.plate_config.friendlyplayer.spellpercent_text_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.plate_config.friendlyplayer.spellpercent_text_color
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllPlates()
			end,
			name = "Color",
			desc = "The color of the text.",
		},
		
		--cast time anchor
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.spellpercent_text_anchor.side end,
			values = function() return build_anchor_side_table ("friendlyplayer", "spellpercent_text_anchor") end,
			name = "Anchor",
			desc = "Which side of the nameplate this widget is attach to.",
		},
		--cast time anchor x offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.spellpercent_text_anchor.x end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.spellpercent_text_anchor.x = value
				Plater.UpdateAllPlates()
			end,
			min = -20,
			max = 20,
			step = 1,
			name = "X Offset",
			desc = "Slightly move the text horizontally.",
		},
		--cast time anchor x offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.spellpercent_text_anchor.y end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.spellpercent_text_anchor.y = value
				Plater.UpdateAllPlates()
			end,
			min = -20,
			max = 20,
			step = 1,
			name = "Y Offset",
			desc = "Slightly move the text vertically.",
		},		

		{type = "breakline"},
		
		--percent text
		{type = "label", get = function() return "Health Text:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		--enabled
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.percent_text_enabled end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.percent_text_enabled = value
				Plater.UpdateAllPlates()
			end,
			name = "Enabled",
			desc = "Show the percent text.",
		},
		--out of combat
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.percent_text_ooc end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.percent_text_ooc = value
				
				Plater.UpdateAllPlates()
			end,
			name = "Out of Combat",
			desc = "Show the percent even when isn't in combat.",
		},
		--use decimals
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.percent_text_show_decimals end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.percent_text_show_decimals = value
				Plater.UpdateAllPlates()
			end,
			name = "Show Decimals",
			desc = "Without decimals: 56%\nWith decimals: 56.1%\n\nWithout decimals: 9%\nWith decimals: 9.16%",
		},		
		--health amount
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.percent_show_health end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.percent_show_health = value
				Plater.UpdateAllPlates()
			end,
			name = "Show Health Amount",
			desc = "Show Health Amount",
		},
		--percent text size
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.percent_text_size end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.percent_text_size = value
				Plater.UpdateAllPlates()
			end,
			min = 6,
			max = 99,
			step = 1,
			name = "Size",
			desc = "Size of the text.",
		},
		--percent text font
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.percent_text_font end,
			values = function() return DF:BuildDropDownFontList (on_select_friendlyplayer_percent_text_font) end,
			name = "Font",
			desc = "Font of the text.",
		},
		--percent text shadow
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.percent_text_shadow end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.percent_text_shadow = value
				Plater.UpdateAllPlates()
			end,
			name = "Shadow",
			desc = "If the text has a black outline.",
		},
		--pecent text color
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.plate_config.friendlyplayer.percent_text_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.plate_config.friendlyplayer.percent_text_color
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllPlates()
			end,
			name = "Color",
			desc = "The color of the text.",
		},
		--percent text alpha
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.percent_text_alpha end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.percent_text_alpha = value
				Plater.UpdateAllPlates()
			end,
			min = 0,
			max = 1,
			step = 0.1,
			name = "Alpha",
			desc = "Set the transparency of the text.",
			usedecimals = true,
		},
		--percent anchor
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.percent_text_anchor.side end,
			values = function() return build_anchor_side_table ("friendlyplayer", "percent_text_anchor") end,
			name = "Anchor",
			desc = "Which side of the nameplate this widget is attach to.",
		},
		--percent anchor x offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.percent_text_anchor.x end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.percent_text_anchor.x = value
				Plater.UpdateAllPlates()
			end,
			min = -20,
			max = 20,
			step = 1,
			name = "X Offset",
			desc = "Slightly move the text horizontally.",
		},
		--percent anchor x offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.percent_text_anchor.y end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.percent_text_anchor.y = value
				Plater.UpdateAllPlates()
			end,
			min = -20,
			max = 20,
			step = 1,
			name = "Y Offset",
			desc = "Slightly move the text vertically.",
		},
		

		--level text settings
		{type = "blank"},
		{type = "label", get = function() return "Level Text:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		--level enabled
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.level_text_enabled end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.level_text_enabled = value
				Plater.UpdateAllPlates()
			end,
			name = "Enabled",
			desc = "Check this box to show the level of the actor.",
		},
		--level text size
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.level_text_size end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.level_text_size = value
				Plater.UpdateAllPlates()
			end,
			min = 6,
			max = 99,
			step = 1,
			name = "Size",
			desc = "Size of the text.",
		},
		--level text font
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.level_text_font end,
			values = function() return DF:BuildDropDownFontList (on_select_friendlyplayer_level_text_font) end,
			name = "Font",
			desc = "Font of the text.",
		},
		--level text shadow
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.level_text_shadow end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.level_text_shadow = value
				Plater.UpdateAllPlates()
			end,
			name = "Shadow",
			desc = "If the text has a black outline.",
		},
		--level text alpha
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.level_text_alpha end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.level_text_alpha = value
				Plater.UpdateAllPlates()
			end,
			min = 0,
			max = 1,
			step = 0.1,
			name = "Alpha",
			desc = "Set the transparency of the text.",
			usedecimals = true,
		},
		--level anchor
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.level_text_anchor.side end,
			values = function() return build_anchor_side_table ("friendlyplayer", "level_text_anchor") end,
			name = "Anchor",
			desc = "Which side of the nameplate this widget is attach to.",
		},
		--level anchor x offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.level_text_anchor.x end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.level_text_anchor.x = value
				Plater.UpdateAllPlates()
			end,
			min = -20,
			max = 20,
			step = 1,
			name = "X Offset",
			desc = "Slightly move the text horizontally.",
		},
		--level anchor x offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.level_text_anchor.y end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.level_text_anchor.y = value
				Plater.UpdateAllPlates()
			end,
			min = -20,
			max = 20,
			step = 1,
			name = "Y Offset",
			desc = "Slightly move the text vertically.",
		},
		
		

	}
	DF:BuildMenu (friendlyPCsFrame, options_table3, startX, startY, heightSize, true, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template, globalCallback)

--------------------------------
--Enemy Player painel de opï¿½ï¿½es ~enemy

	local on_select_enemy_playername_font = function (_, _, value)
		Plater.db.profile.plate_config.enemyplayer.actorname_text_font = value
		Plater.UpdateAllPlates()
	end
	local on_select_enemy_playercastname_font = function (_, _, value)
		Plater.db.profile.plate_config.enemyplayer.spellname_text_font = value
		Plater.UpdateAllPlates()
	end
	
	local on_select_enemyplayer_level_text_font = function (_, _, value)
		Plater.db.profile.plate_config.enemyplayer.level_text_font = value
		Plater.UpdateAllPlates()
	end
	local on_select_enemyplayer_percent_text_font = function (_, _, value)
		Plater.db.profile.plate_config.enemyplayer.percent_text_font = value
		Plater.UpdateAllPlates()
	end
	
	local on_select_enemyplayer_spellpercent_text_font = function (_, _, value)
		Plater.db.profile.plate_config.enemyplayer.spellpercent_text_font = value
		Plater.UpdateAllPlates()
	end	
	
	local options_table4 = {
	
		
		{type = "label", get = function() return "General Settings:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.enemyplayer.use_playerclass_color end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.use_playerclass_color = value
				Plater.UpdateAllPlates (true)
			end,
			name = "Use Class Colors",
			desc = "Player name plates uses the player class color",
		},
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.plate_config.enemyplayer.fixed_class_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.plate_config.enemyplayer.fixed_class_color
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllPlates()
			end,
			name = "Fixed Color",
			desc = "Use this color when not using class colors.",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.enemyplayer.show_guild_name end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.show_guild_name = value
				Plater.UpdateAllPlates (true)
			end,
			name = "Show Guild Name",
			desc = "Show Guild Name",
		},
		
		{type = "blank"},
		
		--plate order		
		{type = "label", get = function() return "Plate Order:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.enemyplayer.plate_order end,
			values = function() return build_order_options ("enemyplayer") end,
			name = "Order",
			desc = "How the health, cast and buff bars are ordered.\n\nFrom bottom (near the character head) to top.",
		},
		
		{type = "blank"},
		
		{type = "label", get = function() return "Debuff Frame:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		--y offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.enemyplayer.buff_frame_y_offset end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.buff_frame_y_offset = value
				Plater.UpdateAllPlates()
			end,
			min = -64,
			max = 64,
			step = 1,
			name = "Y Offset",
			desc = "Adjusts the position on the Y axis.",
		},		
		
		{type = "breakline"},
	
		--health bar size out of combat
		{type = "label", get = function() return "Health Bar Size out of Combat:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.enemyplayer.health[1] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.health[1] = value
				Plater.UpdateAllPlates (nil, true)
			end,
			min = 50,
			max = 300,
			step = 1,
			name = "Width",
			desc = "Width of the health bar when out of combat.",
		},
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.enemyplayer.health[2] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.health[2] = value
				Plater.UpdateAllPlates (nil, true)
			end,
			min = 1,
			max = 100,
			step = 1,
			name = "Height",
			desc = "Height of the health bar when out of combat.",
		},
		
		--health bar size in combat
		{type = "label", get = function() return "Health Bar Size in Combat:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.enemyplayer.health_incombat[1] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.health_incombat[1] = value
				Plater.UpdateAllPlates (nil, true)
			end,
			min = 50,
			max = 300,
			step = 1,
			name = "Width",
			desc = "Width of the health bar when in combat.",
		},
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.enemyplayer.health_incombat[2] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.health_incombat[2] = value
				Plater.UpdateAllPlates (nil, true)
			end,
			min = 1,
			max = 100,
			step = 1,
			name = "Height",
			desc = "Height of the health bar when in combat.",
		},
		
		{type = "blank"},
		
		--cast bar size out of combat
		{type = "label", get = function() return "Cast Bar Size out of Combat:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.enemyplayer.cast[1] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.cast[1] = value
				Plater.UpdateAllPlates()
			end,
			min = 50,
			max = 300,
			step = 1,
			name = "Width",
			desc = "Width of the cast bar when out of combat.",
		},
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.enemyplayer.cast[2] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.cast[2] = value
				Plater.UpdateAllPlates()
			end,
			min = 1,
			max = 100,
			step = 1,
			name = "Height",
			desc = "Height of the cast bar when out of combat.",
		},
		--cast bar size out of combat
		{type = "label", get = function() return "Cast Bar Size in Combat:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.enemyplayer.cast_incombat[1] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.cast_incombat[1] = value
				Plater.UpdateAllPlates()
			end,
			min = 50,
			max = 300,
			step = 1,
			name = "Width",
			desc = "Width of the cast bar when in combat.",
		},
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.enemyplayer.cast_incombat[2] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.cast_incombat[2] = value
				Plater.UpdateAllPlates()
			end,
			min = 1,
			max = 100,
			step = 1,
			name = "Height",
			desc = "Height of the cast bar when in combat.",
		},

		{type = "blank"},
		
		--player name size
		{type = "label", get = function() return "Player Name Text:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.enemyplayer.actorname_text_size end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.actorname_text_size = value
				Plater.db.profile.plate_config.enemyplayer.actorname_text_spacing = value-1
				Plater.UpdateAllPlates()
			end,
			min = 6,
			max = 99,
			step = 1,
			name = "Size",
			desc = "Size of the text.",
		},
		--player name font
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.enemyplayer.actorname_text_font end,
			values = function() return DF:BuildDropDownFontList (on_select_enemy_playername_font) end,
			name = "Font",
			desc = "Font of the text.",
		},
		--player name color
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.plate_config.enemyplayer.actorname_text_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.plate_config.enemyplayer.actorname_text_color
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllPlates()
			end,
			name = "Color",
			desc = "The color of the text.",
		},
		--player name shadow
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.enemyplayer.actorname_text_shadow end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.actorname_text_shadow = value
				Plater.UpdateAllPlates()
			end,
			name = "Shadow",
			desc = "If the text has a black outline.",
		},
		--npc name anchor
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.enemyplayer.actorname_text_anchor.side end,
			values = function() return build_anchor_side_table ("enemyplayer", "actorname_text_anchor") end,
			name = "Anchor",
			desc = "Which side of the nameplate this widget is attach to.",
		},
		--npc name anchor x offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.enemyplayer.actorname_text_anchor.x end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.actorname_text_anchor.x = value
				Plater.UpdateAllPlates()
			end,
			min = -20,
			max = 20,
			step = 1,
			name = "X Offset",
			desc = "Slightly move the text horizontally.",
		},
		--npc name anchor x offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.enemyplayer.actorname_text_anchor.y end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.actorname_text_anchor.y = value
				Plater.UpdateAllPlates()
			end,
			min = -20,
			max = 20,
			step = 1,
			name = "Y Offset",
			desc = "Slightly move the text vertically.",
		},	
		
		{type = "breakline"},
		
		--cast text size
		{type = "label", get = function() return "Spell Name Text:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.enemyplayer.spellname_text_size end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.spellname_text_size = value
				Plater.UpdateAllPlates()
			end,
			min = 6,
			max = 99,
			step = 1,
			name = "Size",
			desc = "Size of the text.",
		},
		--cast text font
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.enemyplayer.spellname_text_font end,
			values = function() return DF:BuildDropDownFontList (on_select_enemy_playercastname_font) end,
			name = "Font",
			desc = "Font of the text.",
		},
		--cast text color
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.plate_config.enemyplayer.spellname_text_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.plate_config.enemyplayer.spellname_text_color
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllPlates()
			end,
			name = "Color",
			desc = "The color of the text.",
		},
		--cast text shadow
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.enemyplayer.spellname_text_shadow end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.spellname_text_shadow = value
				Plater.UpdateAllPlates()
			end,
			name = "Shadow",
			desc = "If the text has a black outline.",
		},
		
		--level text settings
		{type = "blank"},

		{type = "label", get = function() return "Spell Cast Time Text:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.enemyplayer.spellpercent_text_enabled end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.spellpercent_text_enabled = value
				Plater.UpdateAllPlates()
			end,
			name = "Enabled",
			desc = "Show the cast time progress.",
		},
		--cast time text
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.enemyplayer.spellpercent_text_size end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.spellpercent_text_size = value
				Plater.UpdateAllPlates()
			end,
			min = 6,
			max = 99,
			step = 1,
			name = "Size",
			desc = "Size of the text.",
		},
		--cast time text font
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.enemyplayer.spellpercent_text_font end,
			values = function() return DF:BuildDropDownFontList (on_select_enemyplayer_spellpercent_text_font) end,
			name = "Font",
			desc = "Font of the text.",
		},
		--cast time text shadow
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.enemyplayer.spellpercent_text_shadow end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.spellpercent_text_shadow = value
				Plater.UpdateAllPlates()
			end,
			name = "Shadow",
			desc = "If the text has a black outline.",
		},
		--cast time text color
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.plate_config.enemyplayer.spellpercent_text_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.plate_config.enemyplayer.spellpercent_text_color
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllPlates()
			end,
			name = "Color",
			desc = "The color of the text.",
		},
		
		--cast time anchor
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.enemyplayer.spellpercent_text_anchor.side end,
			values = function() return build_anchor_side_table ("enemyplayer", "spellpercent_text_anchor") end,
			name = "Anchor",
			desc = "Which side of the nameplate this widget is attach to.",
		},
		--cast time anchor x offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.enemyplayer.spellpercent_text_anchor.x end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.spellpercent_text_anchor.x = value
				Plater.UpdateAllPlates()
			end,
			min = -20,
			max = 20,
			step = 1,
			name = "X Offset",
			desc = "Slightly move the text horizontally.",
		},
		--cast time anchor x offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.enemyplayer.spellpercent_text_anchor.y end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.spellpercent_text_anchor.y = value
				Plater.UpdateAllPlates()
			end,
			min = -20,
			max = 20,
			step = 1,
			name = "Y Offset",
			desc = "Slightly move the text vertically.",
		},

		{type = "breakline"},
		
		--percent text
		{type = "label", get = function() return "Health Text:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		--enabled
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.enemyplayer.percent_text_enabled end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.percent_text_enabled = value
				Plater.UpdateAllPlates()
			end,
			name = "Enabled",
			desc = "Show the percent text.",
		},
		--out of combat
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.percent_text_ooc end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.percent_text_ooc = value
				
				Plater.UpdateAllPlates()
			end,
			name = "Out of Combat",
			desc = "Show the percent even when isn't in combat.",
		},
		--use decimals
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.enemyplayer.percent_text_show_decimals end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.percent_text_show_decimals = value
				Plater.UpdateAllPlates()
			end,
			name = "Show Decimals",
			desc = "Without decimals: 56%\nWith decimals: 56.1%\n\nWithout decimals: 9%\nWith decimals: 9.16%",
		},		
		--health amount
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.enemyplayer.percent_show_health end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.percent_show_health = value
				Plater.UpdateAllPlates()
			end,
			name = "Show Health Amount",
			desc = "Show Health Amount",
		},		
		--percent text size
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.enemyplayer.percent_text_size end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.percent_text_size = value
				Plater.UpdateAllPlates()
			end,
			min = 6,
			max = 99,
			step = 1,
			name = "Size",
			desc = "Size of the text.",
		},
		--percent text font
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.enemyplayer.percent_text_font end,
			values = function() return DF:BuildDropDownFontList (on_select_enemyplayer_percent_text_font) end,
			name = "Font",
			desc = "Font of the text.",
		},
		--percent text shadow
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.enemyplayer.percent_text_shadow end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.percent_text_shadow = value
				Plater.UpdateAllPlates()
			end,
			name = "Shadow",
			desc = "If the text has a black outline.",
		},
		--pecent text color
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.plate_config.enemyplayer.percent_text_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.plate_config.enemyplayer.percent_text_color
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllPlates()
			end,
			name = "Color",
			desc = "The color of the text.",
		},
		--percent text alpha
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.enemyplayer.percent_text_alpha end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.percent_text_alpha = value
				Plater.UpdateAllPlates()
			end,
			min = 0,
			max = 1,
			step = 0.1,
			name = "Alpha",
			desc = "Set the transparency of the text.",
			usedecimals = true,
		},
		--percent anchor
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.enemyplayer.percent_text_anchor.side end,
			values = function() return build_anchor_side_table ("enemyplayer", "percent_text_anchor") end,
			name = "Anchor",
			desc = "Which side of the nameplate this widget is attach to.",
		},
		--percent anchor x offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.enemyplayer.percent_text_anchor.x end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.percent_text_anchor.x = value
				Plater.UpdateAllPlates()
			end,
			min = -20,
			max = 20,
			step = 1,
			name = "X Offset",
			desc = "Slightly move the text horizontally.",
		},
		--percent anchor x offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.enemyplayer.percent_text_anchor.y end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.percent_text_anchor.y = value
				Plater.UpdateAllPlates()
			end,
			min = -20,
			max = 20,
			step = 1,
			name = "Y Offset",
			desc = "Slightly move the text vertically.",
		},
		
		{type = "blank"},
		
		{type = "label", get = function() return "Level Text:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		--level enabled
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.enemyplayer.level_text_enabled end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.level_text_enabled = value
				Plater.UpdateAllPlates()
			end,
			name = "Enabled",
			desc = "Check this box to show the level of the actor.",
		},
		--level text size
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.enemyplayer.level_text_size end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.level_text_size = value
				Plater.UpdateAllPlates()
			end,
			min = 6,
			max = 99,
			step = 1,
			name = "Size",
			desc = "Size of the text.",
		},
		--level text font
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.enemyplayer.level_text_font end,
			values = function() return DF:BuildDropDownFontList (on_select_enemyplayer_level_text_font) end,
			name = "Font",
			desc = "Font of the text.",
		},
		--level text shadow
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.enemyplayer.level_text_shadow end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.level_text_shadow = value
				Plater.UpdateAllPlates()
			end,
			name = "Shadow",
			desc = "If the text has a black outline.",
		},
		--level text alpha
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.enemyplayer.level_text_alpha end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.level_text_alpha = value
				Plater.UpdateAllPlates()
			end,
			min = 0,
			max = 1,
			step = 0.1,
			name = "Alpha",
			desc = "Set the transparency of the text.",
			usedecimals = true,
		},
		--level anchor
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.enemyplayer.level_text_anchor.side end,
			values = function() return build_anchor_side_table ("enemyplayer", "level_text_anchor") end,
			name = "Anchor",
			desc = "Which side of the nameplate this widget is attach to.",
		},
		--level anchor x offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.enemyplayer.level_text_anchor.x end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.level_text_anchor.x = value
				Plater.UpdateAllPlates()
			end,
			min = -20,
			max = 20,
			step = 1,
			name = "X Offset",
			desc = "Slightly move the text horizontally.",
		},
		--level anchor x offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.enemyplayer.level_text_anchor.y end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.level_text_anchor.y = value
				Plater.UpdateAllPlates()
			end,
			min = -20,
			max = 20,
			step = 1,
			name = "Y Offset",
			desc = "Slightly move the text vertically.",
		},		

	}
	DF:BuildMenu (enemyPCsFrame, options_table4, startX, startY, heightSize, true, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template, globalCallback)

-----------------------------------------------	
--Friendly NPC painel de opï¿½ï¿½es ~friendly

	local on_select_friendly_npcname_font = function (_, _, value)
		Plater.db.profile.plate_config.friendlynpc.actorname_text_font = value
		Plater.UpdateAllPlates()
	end
	local on_select_friendly_npccastname_font = function (_, _, value)
		Plater.db.profile.plate_config.friendlynpc.spellname_text_font = value
		Plater.UpdateAllPlates()
	end
	
	local on_select_friendlynpc_level_text_font = function (_, _, value)
		Plater.db.profile.plate_config.friendlynpc.level_text_font = value
		Plater.UpdateAllPlates()
	end
	local on_select_friendlynpc_percent_text_font = function (_, _, value)
		Plater.db.profile.plate_config.friendlynpc.percent_text_font = value
		Plater.UpdateAllPlates()
	end	
	local on_select_friendlynpc_titletext_text_font = function (_, _, value)
		Plater.db.profile.plate_config.friendlynpc.big_actortitle_text_font = value
		Plater.UpdateAllPlates()
	end
	local on_select_friendlynpc_bignametext_text_font = function (_, _, value)
		Plater.db.profile.plate_config.friendlynpc.big_actorname_text_font = value
		Plater.db.profile.plate_config.friendlynpc.big_actortitle_text_font = value
		Plater.UpdateAllPlates()
	end
	
	local on_select_friendlynpc_spellpercent_text_font = function (_, _, value)
		Plater.db.profile.plate_config.friendlynpc.spellpercent_text_font = value
		Plater.UpdateAllPlates()
	end	
	
	--menu 2
	local friendly_npc_options_table = {
	
		{type = "label", get = function() return "General Settings:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "toggle",
			get = function() return GetCVarBool ("nameplateShowFriendlyNPCs") end,
			set = function (self, fixedparam, value) 
				if (value) then
					SetCVar ("nameplateShowFriendlyNPCs", CVAR_ENABLED)
					Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_NPC].enabled = true
				else
					SetCVar ("nameplateShowFriendlyNPCs", CVAR_DISABLED)
					Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_NPC].enabled = false
				end
			end,
			nocombat = true,
			name = "Enabled" .. CVarIcon,
			desc = "Show nameplate for friendly npcs.\n\n|cFFFFFF00Important|r: This option is dependent on the client`s nameplate state (on/off).\n\n|cFFFFFF00Important|r: when disabled but enabled on the client through (" .. (GetBindingKey ("FRIENDNAMEPLATES") or "") .. ") the healthbar isn't visible but the nameplate is still clickable." .. CVarDesc,
		},

		{
			type = "select",
			get = function() return Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_NPC].relevance_state end,
			values = function() return relevance_options end,
			name = "Show",
			desc = "Modify the way friendly npcs are shown.\n\n|cFFFFFF00Important|r: This option is dependent on the client`s nameplate state (on/off).",
		},
		
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.friendlynpc.quest_enabled end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.quest_enabled = value
				Plater.UpdateAllPlates()
			end,
			name = "Use Quest Color",
			desc = "Use a different color when a unit is objective of a quest.",
		},
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.plate_config.friendlynpc.quest_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.plate_config.friendlynpc.quest_color
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllPlates()
			end,
			name = "Quest Color",
			desc = "Nameplate has this color when a friendly npc unit is a quest objective.",
		},		
		
		{type = "blank"},
		
		--plate order
		{type = "label", get = function() return "Plate Order:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlynpc.plate_order end,
			values = function() return build_order_options ("friendlynpc") end,
			name = "Order",
			desc = "How the health, cast and buff bars are ordered.\n\nFrom bottom (near the character head) to top.",
		},
		
		{type = "blank"},
		
		{type = "label", get = function() return "Buff Frame:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		--y offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlynpc.buff_frame_y_offset end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.buff_frame_y_offset = value
				Plater.UpdateAllPlates()
			end,
			min = -64,
			max = 64,
			step = 1,
			name = "Y Offset",
			desc = "Adjusts the position on the Y axis.",
		},
		
		{type = "blank"},
		
		{type = "label", get = function() return "Npc Name Text When no Health Bar Shown:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		--profession text size
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlynpc.big_actorname_text_size end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.big_actorname_text_size = value
				Plater.db.profile.plate_config.friendlynpc.big_actortitle_text_size = value
				Plater.UpdateAllPlates()
			end,
			min = 6,
			max = 99,
			step = 1,
			name = "Size",
			desc = "Size of the text.",
		},
		--profession text font
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlynpc.big_actorname_text_font end,
			values = function() return DF:BuildDropDownFontList (on_select_friendlynpc_bignametext_text_font) end,
			name = "Font",
			desc = "Font of the text.",
		},
		--profession text shadow
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.friendlynpc.big_actorname_text_shadow end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.big_actorname_text_shadow = value
				Plater.db.profile.plate_config.friendlynpc.big_actortitle_text_shadow = value
				Plater.UpdateAllPlates()
			end,
			name = "Shadow",
			desc = "If the text has a black outline.",
		},
		--profession text color
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.plate_config.friendlynpc.big_actorname_text_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.plate_config.friendlynpc.big_actorname_text_color
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllPlates()
			end,
			name = "Color",
			desc = "The color of the text.",
		},
		--profession text color
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.plate_config.friendlynpc.big_actortitle_text_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.plate_config.friendlynpc.big_actortitle_text_color
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllPlates()
			end,
			name = "Profession Text Color",
			desc = "The color of the profession text below the npc name.",
		},			

		{type = "breakline"},

		--health bar size out of combat
		{type = "label", get = function() return "Health Bar Size out of Combat:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlynpc.health[1] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.health[1] = value
				Plater.UpdateAllPlates (nil, true)
			end,
			min = 50,
			max = 300,
			step = 1,
			name = "Width",
			desc = "Width of the health bar when out of combat.",
		},
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlynpc.health[2] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.health[2] = value
				Plater.UpdateAllPlates (nil, true)
			end,
			min = 1,
			max = 100,
			step = 1,
			name = "Height",
			desc = "Height of the health bar when out of combat.",
		},
		
		--health bar size in combat
		{type = "label", get = function() return "Health Bar Size in Combat:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlynpc.health_incombat[1] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.health_incombat[1] = value
				Plater.UpdateAllPlates (nil, true)
			end,
			min = 50,
			max = 300,
			step = 1,
			name = "Width",
			desc = "Width of the health bar when in combat.",
		},
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlynpc.health_incombat[2] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.health_incombat[2] = value
				Plater.UpdateAllPlates (nil, true)
			end,
			min = 1,
			max = 100,
			step = 1,
			name = "Height",
			desc = "Height of the health bar when in combat.",
		},
		
		{type = "blank"},
		
		--cast bar size out of combat
		{type = "label", get = function() return "Cast Bar Size out of Combat:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlynpc.cast[1] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.cast[1] = value
				Plater.UpdateAllPlates()
			end,
			min = 50,
			max = 300,
			step = 1,
			name = "Width",
			desc = "Width of the cast bar when out of combat.",
		},
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlynpc.cast[2] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.cast[2] = value
				Plater.UpdateAllPlates()
			end,
			min = 1,
			max = 100,
			step = 1,
			name = "Height",
			desc = "Height of the cast bar when out of combat.",
		},
		--cast bar size out of combat
		{type = "label", get = function() return "Cast Bar Size in Combat:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlynpc.cast_incombat[1] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.cast_incombat[1] = value
				Plater.UpdateAllPlates()
			end,
			min = 50,
			max = 300,
			step = 1,
			name = "Width",
			desc = "Width of the cast bar when in combat.",
		},
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlynpc.cast_incombat[2] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.cast_incombat[2] = value
				Plater.UpdateAllPlates()
			end,
			min = 1,
			max = 100,
			step = 1,
			name = "Height",
			desc = "Height of the cast bar when in combat.",
		},
		
		--player name size
		{type = "blank"},
		
		{type = "label", get = function() return "Npc Name Text:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlynpc.actorname_text_size end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.actorname_text_size = value
				Plater.db.profile.plate_config.friendlynpc.actorname_text_spacing = value-1
				Plater.UpdateAllPlates()
			end,
			min = 6,
			max = 99,
			step = 1,
			name = "Size",
			desc = "Size of the text.",
		},
		--player name font
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlynpc.actorname_text_font end,
			values = function() return DF:BuildDropDownFontList (on_select_friendly_npcname_font) end,
			name = "Font",
			desc = "Font of the text.",
		},
		--player name color
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.plate_config.friendlynpc.actorname_text_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.plate_config.friendlynpc.actorname_text_color
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllPlates()
			end,
			name = "Color",
			desc = "The color of the text.",
		},
		--player name shadow
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.friendlynpc.actorname_text_shadow end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.actorname_text_shadow = value
				Plater.UpdateAllPlates()
			end,
			name = "Shadow",
			desc = "If the text has a black outline.",
		},
		
		--npc name anchor
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlynpc.actorname_text_anchor.side end,
			values = function() return build_anchor_side_table ("friendlynpc", "actorname_text_anchor") end,
			name = "Anchor",
			desc = "Which side of the nameplate this widget is attach to.",
		},
		--npc name anchor x offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlynpc.actorname_text_anchor.x end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.actorname_text_anchor.x = value
				Plater.UpdateAllPlates()
			end,
			min = -20,
			max = 20,
			step = 1,
			name = "X Offset",
			desc = "Slightly move the text horizontally.",
		},
		--npc name anchor x offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlynpc.actorname_text_anchor.y end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.actorname_text_anchor.y = value
				Plater.UpdateAllPlates()
			end,
			min = -20,
			max = 20,
			step = 1,
			name = "Y Offset",
			desc = "Slightly move the text vertically.",
		},	
		
		{type = "breakline"},
		
		--cast text size
		{type = "label", get = function() return "Spell Name Text:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlynpc.spellname_text_size end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.spellname_text_size = value
				Plater.UpdateAllPlates()
			end,
			min = 6,
			max = 99,
			step = 1,
			name = "Size",
			desc = "Size of the text.",
		},
		--cast text font
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlynpc.spellname_text_font end,
			values = function() return DF:BuildDropDownFontList (on_select_enemy_npccastname_font) end,
			name = "Font",
			desc = "Font of the text.",
		},
		--cast text color
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.plate_config.friendlynpc.spellname_text_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.plate_config.friendlynpc.spellname_text_color
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllPlates()
			end,
			name = "Color",
			desc = "The color of the text.",
		},
		--cast text shadow
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.friendlynpc.spellname_text_shadow end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.spellname_text_shadow = value
				Plater.UpdateAllPlates()
			end,
			name = "Shadow",
			desc = "If the text has a black outline.",
		},
		
		{type = "blank"},

		{type = "label", get = function() return "Spell Cast Time Text:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.friendlynpc.spellpercent_text_enabled end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.spellpercent_text_enabled = value
				Plater.UpdateAllPlates()
			end,
			name = "Enabled",
			desc = "Show the cast time progress.",
		},
		--cast time text
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlynpc.spellpercent_text_size end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.spellpercent_text_size = value
				Plater.UpdateAllPlates()
			end,
			min = 6,
			max = 99,
			step = 1,
			name = "Size",
			desc = "Size of the text.",
		},
		--cast time text font
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlynpc.spellpercent_text_font end,
			values = function() return DF:BuildDropDownFontList (on_select_friendlynpc_spellpercent_text_font) end,
			name = "Font",
			desc = "Font of the text.",
		},
		--cast time text shadow
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.friendlynpc.spellpercent_text_shadow end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.spellpercent_text_shadow = value
				Plater.UpdateAllPlates()
			end,
			name = "Shadow",
			desc = "If the text has a black outline.",
		},
		--cast time text color
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.plate_config.friendlynpc.spellpercent_text_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.plate_config.friendlynpc.spellpercent_text_color
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllPlates()
			end,
			name = "Color",
			desc = "The color of the text.",
		},
		--cast time anchor
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlynpc.spellpercent_text_anchor.side end,
			values = function() return build_anchor_side_table ("friendlynpc", "spellpercent_text_anchor") end,
			name = "Anchor",
			desc = "Which side of the nameplate this widget is attach to.",
		},
		--cast time anchor x offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlynpc.spellpercent_text_anchor.x end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.spellpercent_text_anchor.x = value
				Plater.UpdateAllPlates()
			end,
			min = -20,
			max = 20,
			step = 1,
			name = "X Offset",
			desc = "Slightly move the text horizontally.",
		},
		--cast time anchor x offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlynpc.spellpercent_text_anchor.y end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.spellpercent_text_anchor.y = value
				Plater.UpdateAllPlates()
			end,
			min = -20,
			max = 20,
			step = 1,
			name = "Y Offset",
			desc = "Slightly move the text vertically.",
		},

		{type = "breakline"},
		
		--percent text
		{type = "label", get = function() return "Health Text:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		--enabled
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.friendlynpc.percent_text_enabled end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.percent_text_enabled = value
				Plater.UpdateAllPlates()
			end,
			name = "Enabled",
			desc = "Show the percent text.",
		},
		--out of combat
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.percent_text_ooc end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.percent_text_ooc = value
				
				Plater.UpdateAllPlates()
			end,
			name = "Out of Combat",
			desc = "Show the percent even when isn't in combat.",
		},
		--use decimals
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.friendlynpc.percent_text_show_decimals end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.percent_text_show_decimals = value
				Plater.UpdateAllPlates()
			end,
			name = "Show Decimals",
			desc = "Without decimals: 56%\nWith decimals: 56.1%\n\nWithout decimals: 9%\nWith decimals: 9.16%",
		},		
		--health amount
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.friendlynpc.percent_show_health end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.percent_show_health = value
				Plater.UpdateAllPlates()
			end,
			name = "Show Health Amount",
			desc = "Show Health Amount",
		},		
		--percent text size
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlynpc.percent_text_size end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.percent_text_size = value
				Plater.UpdateAllPlates()
			end,
			min = 6,
			max = 99,
			step = 1,
			name = "Size",
			desc = "Size of the text.",
		},
		--percent text font
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlynpc.percent_text_font end,
			values = function() return DF:BuildDropDownFontList (on_select_friendlynpc_percent_text_font) end,
			name = "Font",
			desc = "Font of the text.",
		},
		--percent text shadow
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.friendlynpc.percent_text_shadow end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.percent_text_shadow = value
				Plater.UpdateAllPlates()
			end,
			name = "Shadow",
			desc = "If the text has a black outline.",
		},
		--pecent text color
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.plate_config.friendlynpc.percent_text_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.plate_config.friendlynpc.percent_text_color
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllPlates()
			end,
			name = "Color",
			desc = "The color of the text.",
		},
		--percent text alpha
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlynpc.percent_text_alpha end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.percent_text_alpha = value
				Plater.UpdateAllPlates()
			end,
			min = 0,
			max = 1,
			step = 0.1,
			name = "Alpha",
			desc = "Set the transparency of the text.",
			usedecimals = true,
		},
		--percent anchor
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlynpc.percent_text_anchor.side end,
			values = function() return build_anchor_side_table ("friendlynpc", "percent_text_anchor") end,
			name = "Anchor",
			desc = "Which side of the nameplate this widget is attach to.",
		},
		--percent anchor x offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlynpc.percent_text_anchor.x end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.percent_text_anchor.x = value
				Plater.UpdateAllPlates()
			end,
			min = -20,
			max = 20,
			step = 1,
			name = "X Offset",
			desc = "Slightly move the text horizontally.",
		},
		--percent anchor x offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlynpc.percent_text_anchor.y end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.percent_text_anchor.y = value
				Plater.UpdateAllPlates()
			end,
			min = -20,
			max = 20,
			step = 1,
			name = "Y Offset",
			desc = "Slightly move the text vertically.",
		},
	
		{type = "blank"},
		
		--level text settings
		{type = "label", get = function() return "Level Text:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		--level enabled
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.friendlynpc.level_text_enabled end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.level_text_enabled = value
				Plater.UpdateAllPlates()
			end,
			name = "Enabled",
			desc = "Check this box to show the level of the actor.",
		},
		--level text size
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlynpc.level_text_size end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.level_text_size = value
				Plater.UpdateAllPlates()
			end,
			min = 6,
			max = 99,
			step = 1,
			name = "Size",
			desc = "Size of the text.",
		},
		--level text font
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlynpc.level_text_font end,
			values = function() return DF:BuildDropDownFontList (on_select_friendlynpc_level_text_font) end,
			name = "Font",
			desc = "Font of the text.",
		},
		--level text shadow
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.friendlynpc.level_text_shadow end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.level_text_shadow = value
				Plater.UpdateAllPlates()
			end,
			name = "Shadow",
			desc = "If the text has a black outline.",
		},
		--level text alpha
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlynpc.level_text_alpha end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.level_text_alpha = value
				Plater.UpdateAllPlates()
			end,
			min = 0,
			max = 1,
			step = 0.1,
			name = "Alpha",
			desc = "Set the transparency of the text.",
			usedecimals = true,
		},
		--level anchor
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlynpc.level_text_anchor.side end,
			values = function() return build_anchor_side_table ("friendlynpc", "level_text_anchor") end,
			name = "Anchor",
			desc = "Which side of the nameplate this widget is attach to.",
		},
		--level anchor x offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlynpc.level_text_anchor.x end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.level_text_anchor.x = value
				Plater.UpdateAllPlates()
			end,
			min = -20,
			max = 20,
			step = 1,
			name = "X Offset",
			desc = "Slightly move the text horizontally.",
		},
		--level anchor x offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlynpc.level_text_anchor.y end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.level_text_anchor.y = value
				Plater.UpdateAllPlates()
			end,
			min = -20,
			max = 20,
			step = 1,
			name = "Y Offset",
			desc = "Slightly move the text vertically.",
		},
		
	}
	
	DF:BuildMenu (friendlyNPCsFrame, friendly_npc_options_table, startX, startY, heightSize, true, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template, globalCallback)

-----------------------------------------------	
--Enemy NPC painel de opï¿½ï¿½es ~enemy

	do

		local on_select_enemy_npcname_font = function (_, _, value)
			Plater.db.profile.plate_config.enemynpc.actorname_text_font = value
			Plater.UpdateAllPlates()
		end
		local on_select_enemy_npccastname_font = function (_, _, value)
			Plater.db.profile.plate_config.enemynpc.spellname_text_font = value
			Plater.UpdateAllPlates()
		end
		local on_select_enemy_level_text_font = function (_, _, value)
			Plater.db.profile.plate_config.enemynpc.level_text_font = value
			Plater.UpdateAllPlates()
		end
		local on_select_enemy_percent_text_font = function (_, _, value)
			Plater.db.profile.plate_config.enemynpc.percent_text_font = value
			Plater.UpdateAllPlates()
		end

		local on_select_enemy_spellpercent_text_font = function (_, _, value)
			Plater.db.profile.plate_config.enemynpc.spellpercent_text_font = value
			Plater.UpdateAllPlates()
		end

		local on_select_enemynpc_bignametext_text_font = function (_, _, value)
			Plater.db.profile.plate_config.enemynpc.big_actorname_text_font = value
			Plater.db.profile.plate_config.enemynpc.big_actortitle_text_font = value
			Plater.UpdateAllPlates()
		end

		--menu 2 --enemy npc
		local options_table2 = {
		
			{type = "label", get = function() return "General Settings:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
			--enabled
			{
				type = "toggle",
				get = function() return Plater.db.profile.plate_config.enemynpc.quest_enabled end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.quest_enabled = value
					Plater.UpdateAllPlates()
				end,
				name = "Use Quest Color",
				desc = "Enemy npc units which are objective of a quest have a different color.",
			},
			{
				type = "color",
				get = function()
					local color = Plater.db.profile.plate_config.enemynpc.quest_color_enemy
					return {color[1], color[2], color[3], color[4]}
				end,
				set = function (self, r, g, b, a) 
					local color = Plater.db.profile.plate_config.enemynpc.quest_color_enemy
					color[1], color[2], color[3], color[4] = r, g, b, a
					Plater.UpdateAllPlates()
				end,
				name = "Quest Color (hostile npc)",
				desc = "Nameplate has this color when a hostile mob is a quest objective.",
			},
			{
				type = "color",
				get = function()
					local color = Plater.db.profile.plate_config.enemynpc.quest_color_neutral
					return {color[1], color[2], color[3], color[4]}
				end,
				set = function (self, r, g, b, a) 
					local color = Plater.db.profile.plate_config.enemynpc.quest_color_neutral
					color[1], color[2], color[3], color[4] = r, g, b, a
					Plater.UpdateAllPlates()
				end,
				name = "Quest Color (neutral npc)",
				desc = "Nameplate has this color when a neutral mob is a quest objective.",
			},
			
			--plate order
			{type = "blank"},
			{type = "label", get = function() return "Plate Order:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
			{
				type = "select",
				get = function() return Plater.db.profile.plate_config.enemynpc.plate_order end,
				values = function() return build_order_options ("enemynpc") end,
				name = "Order",
				desc = "How the health, cast and buff bars are ordered.\n\nFrom bottom (near the character head) to top.",
			},
			
			{type = "blank"},
			{type = "label", get = function() return "Debuff Frame:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
			--y offset
			{
				type = "range",
				get = function() return Plater.db.profile.plate_config.enemynpc.buff_frame_y_offset end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.buff_frame_y_offset = value
					Plater.UpdateAllPlates()
				end,
				min = -64,
				max = 64,
				step = 1,
				name = "Y Offset",
				desc = "Adjusts the position on the Y axis.",
			},

			
			{type = "blank"},
			
			{type = "label", get = function() return "Npc Name Text When no Health Bar Shown:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
			--profession text size
			{
				type = "range",
				get = function() return Plater.db.profile.plate_config.enemynpc.big_actorname_text_size end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.big_actorname_text_size = value
					Plater.db.profile.plate_config.enemynpc.big_actortitle_text_size = value
					Plater.UpdateAllPlates()
				end,
				min = 6,
				max = 99,
				step = 1,
				name = "Size",
				desc = "Size of the text.",
			},
			--profession text font
			{
				type = "select",
				get = function() return Plater.db.profile.plate_config.enemynpc.big_actorname_text_font end,
				values = function() return DF:BuildDropDownFontList (on_select_enemynpc_bignametext_text_font) end,
				name = "Font",
				desc = "Font of the text.",
			},
			--profession text shadow
			{
				type = "toggle",
				get = function() return Plater.db.profile.plate_config.enemynpc.big_actorname_text_shadow end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.big_actorname_text_shadow = value
					Plater.db.profile.plate_config.enemynpc.big_actortitle_text_shadow = value
					Plater.UpdateAllPlates()
				end,
				name = "Shadow",
				desc = "If the text has a black outline.",
			},
			
			--[=[
			--profession text color
			{
				type = "color",
				get = function()
					local color = Plater.db.profile.plate_config.enemynpc.big_actorname_text_color
					return {color[1], color[2], color[3], color[4]}
				end,
				set = function (self, r, g, b, a) 
					local color = Plater.db.profile.plate_config.enemynpc.big_actorname_text_color
					color[1], color[2], color[3], color[4] = r, g, b, a
					Plater.UpdateAllPlates()
				end,
				name = "Color",
				desc = "The color of the text.",
			},
			--profession text color
			{
				type = "color",
				get = function()
					local color = Plater.db.profile.plate_config.enemynpc.big_actortitle_text_color
					return {color[1], color[2], color[3], color[4]}
				end,
				set = function (self, r, g, b, a) 
					local color = Plater.db.profile.plate_config.enemynpc.big_actortitle_text_color
					color[1], color[2], color[3], color[4] = r, g, b, a
					Plater.UpdateAllPlates()
				end,
				name = "Profession Text Color",
				desc = "The color of the profession text below the npc name.",
			},
			--]=]
			
			{type = "breakline"},
		
			--health bar size out of combat
			{type = "label", get = function() return "Health Bar Size out of Combat:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
			{
				type = "range",
				get = function() return Plater.db.profile.plate_config.enemynpc.health[1] end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.health[1] = value
					Plater.UpdateAllPlates (nil, true)
				end,
				min = 50,
				max = 300,
				step = 1,
				name = "Width",
				desc = "Width of the health bar when out of combat.",
			},
			{
				type = "range",
				get = function() return Plater.db.profile.plate_config.enemynpc.health[2] end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.health[2] = value
					Plater.UpdateAllPlates (nil, true)
				end,
				min = 1,
				max = 100,
				step = 1,
				name = "Height",
				desc = "Height of the health bar when out of combat.",
			},
			
			--health bar size in combat
			{type = "label", get = function() return "Health Bar Size in Combat:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
			{
				type = "range",
				get = function() return Plater.db.profile.plate_config.enemynpc.health_incombat[1] end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.health_incombat[1] = value
					Plater.UpdateAllPlates (nil, true)
				end,
				min = 50,
				max = 300,
				step = 1,
				name = "Width",
				desc = "Width of the health bar when in combat.",
			},
			{
				type = "range",
				get = function() return Plater.db.profile.plate_config.enemynpc.health_incombat[2] end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.health_incombat[2] = value
					Plater.UpdateAllPlates (nil, true)
				end,
				min = 1,
				max = 100,
				step = 1,
				name = "Height",
				desc = "Height of the health bar when in combat.",
			},
			{type = "blank"},
			--cast bar size out of combat
			{type = "label", get = function() return "Cast Bar Size out of Combat:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
			{
				type = "range",
				get = function() return Plater.db.profile.plate_config.enemynpc.cast[1] end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.cast[1] = value
					Plater.UpdateAllPlates()
				end,
				min = 50,
				max = 300,
				step = 1,
				name = "Width",
				desc = "Width of the cast bar when out of combat.",
			},
			{
				type = "range",
				get = function() return Plater.db.profile.plate_config.enemynpc.cast[2] end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.cast[2] = value
					Plater.UpdateAllPlates()
				end,
				min = 1,
				max = 100,
				step = 1,
				name = "Height",
				desc = "Height of the cast bar when out of combat.",
			},
			--cast bar size out of combat
			{type = "label", get = function() return "Cast Bar Size in Combat:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
			{
				type = "range",
				get = function() return Plater.db.profile.plate_config.enemynpc.cast_incombat[1] end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.cast_incombat[1] = value
					Plater.UpdateAllPlates()
					Plater.UpdateMaxCastbarTextLength()
				end,
				min = 50,
				max = 300,
				step = 1,
				name = "Width",
				desc = "Width of the cast bar when in combat.",
			},
			{
				type = "range",
				get = function() return Plater.db.profile.plate_config.enemynpc.cast_incombat[2] end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.cast_incombat[2] = value
					Plater.UpdateAllPlates()
				end,
				min = 1,
				max = 100,
				step = 1,
				name = "Height",
				desc = "Height of the cast bar when in combat.",
			},
			{type = "blank"},
			--player name size
			{type = "label", get = function() return "Npc Name Text:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
			{
				type = "range",
				get = function() return Plater.db.profile.plate_config.enemynpc.actorname_text_size end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.actorname_text_size = value
					Plater.db.profile.plate_config.enemynpc.actorname_text_spacing = value-1
					Plater.UpdateAllPlates()
				end,
				min = 6,
				max = 99,
				step = 1,
				name = "Size",
				desc = "Size of the text.",
			},
			--player name font
			{
				type = "select",
				get = function() return Plater.db.profile.plate_config.enemynpc.actorname_text_font end,
				values = function() return DF:BuildDropDownFontList (on_select_enemy_npcname_font) end,
				name = "Font",
				desc = "Font of the text.",
			},
			--player name color
			{
				type = "color",
				get = function()
					local color = Plater.db.profile.plate_config.enemynpc.actorname_text_color
					return {color[1], color[2], color[3], color[4]}
				end,
				set = function (self, r, g, b, a) 
					local color = Plater.db.profile.plate_config.enemynpc.actorname_text_color
					color[1], color[2], color[3], color[4] = r, g, b, a
					Plater.UpdateAllPlates()
				end,
				name = "Color",
				desc = "The color of the text.",
			},
			--player name shadow
			{
				type = "toggle",
				get = function() return Plater.db.profile.plate_config.enemynpc.actorname_text_shadow end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.actorname_text_shadow = value
					Plater.UpdateAllPlates()
				end,
				name = "Shadow",
				desc = "If the text has a black outline.",
			},
			
			--npc name anchor
			{
				type = "select",
				get = function() return Plater.db.profile.plate_config.enemynpc.actorname_text_anchor.side end,
				values = function() return build_anchor_side_table ("enemynpc", "actorname_text_anchor") end,
				name = "Anchor",
				desc = "Which side of the nameplate this widget is attach to.",
			},
			--npc name anchor x offset
			{
				type = "range",
				get = function() return Plater.db.profile.plate_config.enemynpc.actorname_text_anchor.x end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.actorname_text_anchor.x = value
					Plater.UpdateAllPlates()
				end,
				min = -20,
				max = 20,
				step = 1,
				name = "X Offset",
				desc = "Slightly move the text horizontally.",
			},
			--npc name anchor x offset
			{
				type = "range",
				get = function() return Plater.db.profile.plate_config.enemynpc.actorname_text_anchor.y end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.actorname_text_anchor.y = value
					Plater.UpdateAllPlates()
				end,
				min = -20,
				max = 20,
				step = 1,
				name = "Y Offset",
				desc = "Slightly move the text vertically.",
			},	
			
			{type = "breakline"},
			
			--cast text size
			{type = "label", get = function() return "Spell Name Text:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
			{
				type = "range",
				get = function() return Plater.db.profile.plate_config.enemynpc.spellname_text_size end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.spellname_text_size = value
					Plater.UpdateAllPlates()
				end,
				min = 6,
				max = 99,
				step = 1,
				name = "Size",
				desc = "Size of the text.",
			},
			--cast text font
			{
				type = "select",
				get = function() return Plater.db.profile.plate_config.enemynpc.spellname_text_font end,
				values = function() return DF:BuildDropDownFontList (on_select_enemy_npccastname_font) end,
				name = "Font",
				desc = "Font of the text.",
			},
			--cast text color
			{
				type = "color",
				get = function()
					local color = Plater.db.profile.plate_config.enemynpc.spellname_text_color
					return {color[1], color[2], color[3], color[4]}
				end,
				set = function (self, r, g, b, a) 
					local color = Plater.db.profile.plate_config.enemynpc.spellname_text_color
					color[1], color[2], color[3], color[4] = r, g, b, a
					Plater.UpdateAllPlates()
				end,
				name = "Color",
				desc = "The color of the text.",
			},
			--cast text shadow
			{
				type = "toggle",
				get = function() return Plater.db.profile.plate_config.enemynpc.spellname_text_shadow end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.spellname_text_shadow = value
					Plater.UpdateAllPlates()
				end,
				name = "Shadow",
				desc = "If the text has a black outline.",
			},
			
			{type = "blank"},
			
			{type = "label", get = function() return "Spell Cast Time Text:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
			{
				type = "toggle",
				get = function() return Plater.db.profile.plate_config.enemynpc.spellpercent_text_enabled end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.spellpercent_text_enabled = value
					Plater.UpdateAllPlates()
				end,
				name = "Enabled",
				desc = "Show the cast time progress.",
			},
			--cast time text
			{
				type = "range",
				get = function() return Plater.db.profile.plate_config.enemynpc.spellpercent_text_size end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.spellpercent_text_size = value
					Plater.UpdateAllPlates()
				end,
				min = 6,
				max = 99,
				step = 1,
				name = "Size",
				desc = "Size of the text.",
			},
			--cast time text font
			{
				type = "select",
				get = function() return Plater.db.profile.plate_config.enemynpc.spellpercent_text_font end,
				values = function() return DF:BuildDropDownFontList (on_select_enemy_spellpercent_text_font) end,
				name = "Font",
				desc = "Font of the text.",
			},
			--cast time text shadow
			{
				type = "toggle",
				get = function() return Plater.db.profile.plate_config.enemynpc.spellpercent_text_shadow end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.spellpercent_text_shadow = value
					Plater.UpdateAllPlates()
				end,
				name = "Shadow",
				desc = "If the text has a black outline.",
			},
			--cast time text color
			{
				type = "color",
				get = function()
					local color = Plater.db.profile.plate_config.enemynpc.spellpercent_text_color
					return {color[1], color[2], color[3], color[4]}
				end,
				set = function (self, r, g, b, a) 
					local color = Plater.db.profile.plate_config.enemynpc.spellpercent_text_color
					color[1], color[2], color[3], color[4] = r, g, b, a
					Plater.UpdateAllPlates()
				end,
				name = "Color",
				desc = "The color of the text.",
			},
			
			--cast time anchor
			{
				type = "select",
				get = function() return Plater.db.profile.plate_config.enemynpc.spellpercent_text_anchor.side end,
				values = function() return build_anchor_side_table ("enemynpc", "spellpercent_text_anchor") end,
				name = "Anchor",
				desc = "Which side of the nameplate this widget is attach to.",
			},
			--cast time anchor x offset
			{
				type = "range",
				get = function() return Plater.db.profile.plate_config.enemynpc.spellpercent_text_anchor.x end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.spellpercent_text_anchor.x = value
					Plater.UpdateAllPlates()
				end,
				min = -20,
				max = 20,
				step = 1,
				name = "X Offset",
				desc = "Slightly move the text horizontally.",
			},
			--cast time anchor x offset
			{
				type = "range",
				get = function() return Plater.db.profile.plate_config.enemynpc.spellpercent_text_anchor.y end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.spellpercent_text_anchor.y = value
					Plater.UpdateAllPlates()
				end,
				min = -20,
				max = 20,
				step = 1,
				name = "Y Offset",
				desc = "Slightly move the text vertically.",
			},			
			
			{type = "breakline"},
			
			--percent text
			{type = "label", get = function() return "Health Text:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
			--enabled
			{
				type = "toggle",
				get = function() return Plater.db.profile.plate_config.enemynpc.percent_text_enabled end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.percent_text_enabled = value
					Plater.UpdateAllPlates()
				end,
				name = "Enabled",
				desc = "Show the percent text.",
			},
			--out of combat
			{
				type = "toggle",
				get = function() return Plater.db.profile.plate_config.enemynpc.percent_text_ooc end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.percent_text_ooc = value
					
					Plater.UpdateAllPlates()
				end,
				name = "Out of Combat",
				desc = "Show the percent even when isn't in combat.",
			},
			--use decimals
			{
				type = "toggle",
				get = function() return Plater.db.profile.plate_config.enemynpc.percent_text_show_decimals end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.percent_text_show_decimals = value
					Plater.UpdateAllPlates()
				end,
				name = "Show Decimals",
				desc = "Without decimals: 56%\nWith decimals: 56.1%\n\nWithout decimals: 9%\nWith decimals: 9.16%",
			},
			--health amount
			{
				type = "toggle",
				get = function() return Plater.db.profile.plate_config.enemynpc.percent_show_health end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.percent_show_health = value
					Plater.UpdateAllPlates()
				end,
				name = "Show Health Amount",
				desc = "Show Health Amount",
			},
			--percent text size
			{
				type = "range",
				get = function() return Plater.db.profile.plate_config.enemynpc.percent_text_size end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.percent_text_size = value
					Plater.UpdateAllPlates()
				end,
				min = 6,
				max = 99,
				step = 1,
				name = "Size",
				desc = "Size of the text.",
			},
			--percent text font
			{
				type = "select",
				get = function() return Plater.db.profile.plate_config.enemynpc.percent_text_font end,
				values = function() return DF:BuildDropDownFontList (on_select_enemy_percent_text_font) end,
				name = "Font",
				desc = "Font of the text.",
			},
			--percent text shadow
			{
				type = "toggle",
				get = function() return Plater.db.profile.plate_config.enemynpc.percent_text_shadow end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.percent_text_shadow = value
					Plater.UpdateAllPlates()
				end,
				name = "Shadow",
				desc = "If the text has a black outline.",
			},
			--pecent text color
			{
				type = "color",
				get = function()
					local color = Plater.db.profile.plate_config.enemynpc.percent_text_color
					return {color[1], color[2], color[3], color[4]}
				end,
				set = function (self, r, g, b, a) 
					local color = Plater.db.profile.plate_config.enemynpc.percent_text_color
					color[1], color[2], color[3], color[4] = r, g, b, a
					Plater.UpdateAllPlates()
				end,
				name = "Color",
				desc = "The color of the text.",
			},
			--percent text alpha
			{
				type = "range",
				get = function() return Plater.db.profile.plate_config.enemynpc.percent_text_alpha end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.percent_text_alpha = value
					Plater.UpdateAllPlates()
				end,
				min = 0,
				max = 1,
				step = 0.1,
				name = "Alpha",
				desc = "Set the transparency of the text.",
				usedecimals = true,
			},
			--percent anchor
			{
				type = "select",
				get = function() return Plater.db.profile.plate_config.enemynpc.percent_text_anchor.side end,
				values = function() return build_anchor_side_table ("enemynpc", "percent_text_anchor") end,
				name = "Anchor",
				desc = "Which side of the nameplate this widget is attach to.",
			},
			--percent anchor x offset
			{
				type = "range",
				get = function() return Plater.db.profile.plate_config.enemynpc.percent_text_anchor.x end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.percent_text_anchor.x = value
					Plater.UpdateAllPlates()
				end,
				min = -20,
				max = 20,
				step = 1,
				name = "X Offset",
				desc = "Slightly move the text horizontally.",
			},
			--percent anchor x offset
			{
				type = "range",
				get = function() return Plater.db.profile.plate_config.enemynpc.percent_text_anchor.y end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.percent_text_anchor.y = value
					Plater.UpdateAllPlates()
				end,
				min = -20,
				max = 20,
				step = 1,
				name = "Y Offset",
				desc = "Slightly move the text vertically.",
			},

			--level text settings
			{type = "blank"},
			{type = "label", get = function() return "Level Text:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
			--level enabled
			{
				type = "toggle",
				get = function() return Plater.db.profile.plate_config.enemynpc.level_text_enabled end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.level_text_enabled = value
					Plater.UpdateAllPlates()
				end,
				name = "Enabled",
				desc = "Check this box to show the level of the actor.",
			},
			--level text size
			{
				type = "range",
				get = function() return Plater.db.profile.plate_config.enemynpc.level_text_size end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.level_text_size = value
					Plater.UpdateAllPlates()
				end,
				min = 6,
				max = 99,
				step = 1,
				name = "Size",
				desc = "Size of the text.",
			},
			--level text font
			{
				type = "select",
				get = function() return Plater.db.profile.plate_config.enemynpc.level_text_font end,
				values = function() return DF:BuildDropDownFontList (on_select_enemy_level_text_font) end,
				name = "Font",
				desc = "Font of the text.",
			},
			--level text shadow
			{
				type = "toggle",
				get = function() return Plater.db.profile.plate_config.enemynpc.level_text_shadow end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.level_text_shadow = value
					Plater.UpdateAllPlates()
				end,
				name = "Shadow",
				desc = "If the text has a black outline.",
			},
			--level text alpha
			{
				type = "range",
				get = function() return Plater.db.profile.plate_config.enemynpc.level_text_alpha end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.level_text_alpha = value
					Plater.UpdateAllPlates()
				end,
				min = 0,
				max = 1,
				step = 0.1,
				name = "Alpha",
				desc = "Set the transparency of the text.",
				usedecimals = true,
			},
			--level anchor
			{
				type = "select",
				get = function() return Plater.db.profile.plate_config.enemynpc.level_text_anchor.side end,
				values = function() return build_anchor_side_table ("enemynpc", "level_text_anchor") end,
				name = "Anchor",
				desc = "Which side of the nameplate this widget is attach to.",
			},
			--level anchor x offset
			{
				type = "range",
				get = function() return Plater.db.profile.plate_config.enemynpc.level_text_anchor.x end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.level_text_anchor.x = value
					Plater.UpdateAllPlates()
				end,
				min = -20,
				max = 20,
				step = 1,
				name = "X Offset",
				desc = "Slightly move the text horizontally.",
			},
			--level anchor x offset
			{
				type = "range",
				get = function() return Plater.db.profile.plate_config.enemynpc.level_text_anchor.y end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.level_text_anchor.y = value
					Plater.UpdateAllPlates()
				end,
				min = -20,
				max = 20,
				step = 1,
				name = "Y Offset",
				desc = "Slightly move the text vertically.",
			},

		}
		DF:BuildMenu (enemyNPCsFrame, options_table2, startX, startY, heightSize, true, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template, globalCallback)
	end
	
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> ~keybind ~bindings

	--[=[
	local keybind_changed_callback = function()
		local data = Plater.db.profile.keybinds [DF:GetCurrentSpec()]
		if (data) then
			local bind_string, bind_type_func, bind_macro_func = DF:BuildKeybindFunctions (data, "PL")
			if (bind_string) then
				for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
					DF:SetKeybindsOnProtectedFrame (plateFrame, bind_string, bind_type_func, bind_macro_func)
				end
			end
		end
	end
	
	local editKeybindFrame = DF:CreateKeybindBox (keybindsFrame, "PlaterKeybindSettings", Plater.db.profile.keybinds, keybind_changed_callback, 800, 600, 12, 20)
	editKeybindFrame:SetPoint ("topleft", keybindsFrame, 0, -110)
	editKeybindFrame:Hide()
	
	function keybindsFrame.RefreshOptions()
		editKeybindFrame:SetData (Plater.db.profile.keybinds)
	end
	--]=]
	
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> ~scripts ~scripting ~code
	
	--options
	local start_y = -108
	local main_frames_size = {600, 400}
	local edit_script_size = {620, 431}
	
	local scrollbox_size = {200, 405}
	local scrollbox_lines = 13
	local scrollbox_line_height = 30
	
	local triggerbox_size = {180, 288}
	local triggerbox_lines = 11
	local triggerbox_line_height = 25
	
	local scrollbox_line_backdrop_color = {0, 0, 0, 0.5}
	local scrollbox_line_backdrop_color_selected = {.6, .6, .1, 0.7}
	
	local buttons_size = {120, 20}
	local luaeditor_backdrop_color = {.2, .2, .2, .5}
	local luaeditor_border_color = {0, 0, 0, 1}
	
	local currentEditingScript = nil
	
	--localized names of the different trigger types and description
	scriptingFrame.TriggerTypes = {
		"Buffs & Debuffs",
		"Spell Casting",
		"Unit Name",
	}
	scriptingFrame.TriggerTypesDesc = {
		"When an unit receives an aura (buff or debuff), the aura name is checked against all the spell names added in the trigger box below.",
		"When an unit starts to cast a spell, the name of the spell is checked against all the spell names added in the trigger box below.",
		"When a nameplate is shown, the name of the unit is checked against all the spell names added in the trigger box below.",
	}
	
	scriptingFrame.CodeTypes = {
		{Name = "Constructor", Desc = "Is executed only once, create your custom stuff here like frames, textures, animations and store them inside |cFFFFFF00envTable|r.\n\nAlso check if the frame already exists before creating it!", Value = 2},
		{Name = "On Show", Desc = "Executed when the trigger match!\n\nUse to show your custom frames, textures, play animations, etc.", Value = 4},
		{Name = "On Update", Desc = "Executed after Plater updates the nameplate.\n\nUse this to update your custom stuff or override values that Plater might have set during the nameplate update, e.g. the nameplate color due to aggro checks.", Value = 1},
		{Name = "On Hide", Desc = "Executed when the widget is Hide() or trigger doesn't match anymore.\n\nUse to hide your custom frames, textures, stop animations, etc.", Value = 3},
	}
	
	scriptingFrame.APIList = {
		{Name = "RefreshNameplateColor", 		Signature = "Plater.RefreshNameplateColor (unitFrame)", 				Desc = "Check which color the nameplate should have and set it."},
		{Name = "SetNameplateColor", 		Signature = "Plater.SetNameplateColor (unitFrame, color)", 				Desc = "Set the color of the nameplate.\n\nColor formats are:\n|cFFFFFF00Just Values|r: r, g, b\n|cFFFFFF00Index Table|r: {r, g, b}\n|cFFFFFF00Hash Table|r: {r = 1, g = 1, b = 1}\n|cFFFFFF00Hex|r: '#FFFF0000' or '#FF0000'\n|cFFFFFF00Name|r: 'yellow' 'white'"},
		{Name = "SetCastBarBorderColor", 		Signature = "Plater.SetCastBarBorderColor (castBar, color)", 			Desc = "Set the color of the castbar.\n\nColor formats are:\n|cFFFFFF00Just Values|r: r, g, b, a\n|cFFFFFF00Index Table|r: {r, g, b}\n|cFFFFFF00Hash Table|r: {r = 1, g = 1, b = 1}\n|cFFFFFF00Hex|r: '#FFFF0000' or '#FF0000'\n|cFFFFFF00Name|r: 'yellow' 'white'"},
		{Name = "FlashNameplateBorder", 		Signature = "Plater.FlashNameplateBorder (unitFrame [, duration])", 		Desc = "Do a quick flash in the nameplate border, duration is optional."},
		{Name = "FlashNameplateBody", 		Signature = "Plater.FlashNameplateBody (unitFrame [, text [, duration]])", 	Desc = "Flash the healthbar portion of the nameplate, text and duration are optionals."},
		{Name = "UpdateNameplateThread", 	Signature = "Plater.UpdateNameplateThread (unitFrame)", 				Desc = "Perform an Aggro update on the nameplate changing color to the current thread situation."},
	}

	scriptingFrame.FrameworkList = {
		{Name = "CreateFlash",		 		Signature = "Plater.CreateFlash (parent, duration, amountOfFlashes, color)", 	Desc = "Creates a custom flash which can be triggered by the ReturnValue:Play()\n\nUse:\n|cFFFFFF00ReturnedValue:Play()|r on OnShow.\n|cFFFFFF00ReturnedValue:Stop()|r on OnHide.", AddVar = true, AddCall = "--@ENV@:Play() --@ENV@:Stop()"},
		--{Name = "CreateFrameShake",		Signature = "Plater:CreateFrameShake (parent, duration, amplitude, frequency, bAbsoluteSineX, bAbsoluteSineY, scaleX, scaleY, fadeInTime, fadeOutTime)",	Desc = "Creates a shake for the frame.\n\nStore the returned table inside the envTable and call parent:PlayFrameShake (returned table) to play the shake.", AddVar = true, AddCall = "--parent:PlayFrameShake(@ENV@)"}, -- --parent:StopFrameShake(@ENV@)
		
		{Name = "CreateLabel",		 		Signature = "Plater:CreateLabel (parent, text, size, color, font, member, name, layer)",	Desc = "Creates a simple text to show in the nameplate, all parameters after 'parent' are optional.\n\nUse:\n|cFFFFFF00ReturnedValue:Show()|r on OnShow.\n|cFFFFFF00ReturnedValue:Hide()|r on OnHide.\n\nMembers:\n.text = 'new text'\n.textcolor = 'red'\n.textsize = 12\n.textfont = 'fontName'", AddVar = true, AddCall = "@ENV@:SetPoint ('center', 0, 0)"},
		{Name = "CreateImage",		 	Signature = "Plater:CreateImage (parent, texture, w, h, layer, coords, member, name)",	Desc = "Creates a image to show in the nameplate, all parameters after 'parent' are optional.\n\nUse:\n|cFFFFFF00ReturnedValue:Show()|r on OnShow.\n|cFFFFFF00ReturnedValue:Hide()|r on OnHide.\n\nMembers:\n.texture = 'texture path'\n.alpha = 0.5\n.width = 300\n.height = 200", AddVar = true, AddCall = "@ENV@:SetPoint ('center', 0, 0)"},
		{Name = "CreateBar",		 		Signature = "Plater:CreateBar (parent, texture, w, h, value, member, name)",			Desc = "Creates progress bar, all parameters after 'parent' are optional.\n\nUse:\n|cFFFFFF00ReturnedValue:Show()|r on OnShow.\n|cFFFFFF00ReturnedValue:Hide()|r on OnHide.\n\nMembers:\n.value = 50\n.texture = 'texture path'\n.icon = 'texture path'\n.lefttext = 'new text'\n.righttext = 'new text'\n.color = color\n.width = 300\n.height = 200", AddVar = true, AddCall = "@ENV@:SetPoint ('center', 0, 0)"},
		
		{Name = "SetFontSize",		 	Signature = "Plater:SetFontSize (fontString, fontSize, ...)",						Desc = "Set the size of a text, accept more than one size, automatically picks the bigger one."},
		{Name = "SetFontFace",		 	Signature = "Plater:SetFontFace (fontString, fontFace)",						Desc = "Set the font of a text."},
		{Name = "SetFontColor",		 	Signature = "Plater:SetFontColor (fontString, r, g, b, a)",						Desc = "Set the color of a text.\n\nColor formats are:\n|cFFFFFF00Just Values|r: r, g, b, a\n|cFFFFFF00Index Table|r: {r, g, b}\n|cFFFFFF00Hash Table|r: {r = 1, g = 1, b = 1}\n|cFFFFFF00Hex|r: '#FFFF0000' or '#FF0000'\n|cFFFFFF00Name|r: 'yellow' 'white'"},
		
		{Name = "CreateAnimationHub",		Signature = "Plater:CreateAnimationHub (parent, onShowFunc, onHideFunc)",		Desc = "Creates an object to hold animations, see 'CreateAnimation' to add animations to the hub. When ReturnedValue:Play() is called all animations in the hub start playing respecting the Order set in the CreateAnimation().\n\nUse onShowFunc and onHideFunc to show or hide custom frames, textures or text.\n\nMethods:\n|cFFFFFF00ReturnedValue:Play()|r plays all animations in the hub.\n|cFFFFFF00ReturnedValue:Stop()|r: stop all animations in the hub.", AddVar = true, AddCall = "--@ENV@:Play() --@ENV@:Stop()"},
		{Name = "CreateAnimation",			Signature = "Plater:CreateAnimation (animationHub, animationType, order, duration, |cFFCCCCCCarg1|r, |cFFCCCCCCarg2|r, |cFFCCCCCCarg3|r, |cFFCCCCCCarg4|r)",	Desc = "Creates an animation within an animation hub.\n\nOrder: integer between 1 and 10, lower play first. Animations with the same Order play at the same time.\n\nDuration: how much time this animation takes to complete.\n\nAnimation Types:\n|cFFFFFF00\"Alpha\"|r:\n|cFFCCCCCCarg1|r: Alpha Start Value, |cFFCCCCCCarg2|r: Alpha End Value.\n\n|cFFFFFF00\"Scale\"|r:\n|cFFCCCCCCarg1|r: X Start, |cFFCCCCCCarg2|r: Y Start, |cFFCCCCCCarg3|r: X End, |cFFCCCCCCarg4|r: Y End.\n\n|cFFFFFF00\"Rotation\"|r:\n |cFFCCCCCCarg1|r: Rotation Degrees.\n\n|cFFFFFF00\"Translation\"|r:\n |cFFCCCCCCarg1|r: X Offset, |cFFCCCCCCarg2|r: Y Offset."},
		
		{Name = "CreateIconGlow",			Signature = "Plater.CreateIconGlow (self)",						Desc = "Creates a glow effect around an icon.\n\nUse:\n|cFFFFFF00ReturnedValue:Show()|r on OnShow.\n|cFFFFFF00ReturnedValue:Hide()|r on OnHide.\n|cFFFFFF00ReturnedValue:SetColor(dotColor, glowColor)|r to adjust the color.", AddVar = true, AddCall = "--@ENV@:Show() --@ENV@:Hide()"},
		{Name = "CreateNameplateGlow",		Signature = "Plater.CreateNameplateGlow (unitFrame.healthBar)",	Desc = "Creates a glow effect around the nameplate.\n\nUse:\n|cFFFFFF00ReturnedValue:Show()|r on OnShow.\n|cFFFFFF00ReturnedValue:Hide()|r on OnHide.\n|cFFFFFF00ReturnedValue:SetColor(dotColor, glowColor)|r to adjust the color.\n\nUse offsets to adjust the dot animation to fit the nameplate.", AddVar = true, AddCall = "--@ENV@:Show() --@ENV@:Hide() --@ENV@:SetOffset (-27, 25, 5, -7)"},

		{Name = "FormatNumber",			Signature = "Plater.FormatNumber (number)",	Desc = "Format a number to be short as possible.\n\nExample:\n300000 to 300K\n2500000 to 2.5M"},
		{Name = "CommaValue",			Signature = "Plater:CommaValue (number)",	Desc = "Format a number separating by thousands and millions.\n\nExample: 300000 to 300.000\n2500000 to 2.500.000"},
		{Name = "IntegerToTimer",			Signature = "Plater:IntegerToTimer (number)",	Desc = "Format a number to time\n\nExample: 94 to 1:34"},
		
		{Name = "RemoveRealmName",		Signature = "Plater:RemoveRealmName (playerName)",	Desc = "Removes the realm name from a player name."},
		{Name = "Trim",					Signature = "Plater:Trim (string)",			Desc = "Removes spaces in the begining and end of a string."},
		
	}
	
	scriptingFrame.UnitFrameMembers = {
		"unitFrame.castBar",
		"unitFrame.castBar.Text",
		"unitFrame.castBar.FrameOverlay",
		"unitFrame.castBar.percentText",
		--"unitFrame.castBar.extraBackground",
		"unitFrame.healthBar",
		"unitFrame.healthBar.actorName",
		--"unitFrame.healthBar.actorLevel",
		"unitFrame.healthBar.lifePercent",
		"unitFrame.healthBar.border",
		--"unitFrame.healthBar.healthCutOff",
		"unitFrame.BuffFrame",
		"unitFrame.BuffFrame2",
		--"unitFrame.ExtraIconFrame",
		"unitFrame.Top3DFrame",
		--"unitFrame.FocusIndicator",
		"unitFrame.TargetNeonUp",
		"unitFrame.TargetNeonDown",
	}
	
	--store all spells from the game in a hash table and also on the index table
	--these are loaded on demand and cleared when the scripting frame is hided
	scriptingFrame.SpellHashTable = {}
	scriptingFrame.SpellIndexTable = {}
	scriptingFrame.SearchString = ""
	
	scriptingFrame:SetScript ("OnShow", function()
		--update the created scripts scrollbox
		scriptingFrame.ScriptSelectionScrollBox:Refresh()
		
		--check trash can timeout
		local timeout = 60 * 60 * 24 * 30
		--local timeout = 60 * 60 * 24 * 1 --for testing, setting this to 1 day
		
		for i = #Plater.db.profile.script_data_trash, 1, -1 do
			local scriptObject = Plater.db.profile.script_data_trash [i]
			if (not scriptObject.__TrashAt or scriptObject.__TrashAt + timeout < time()) then
				tremove (Plater.db.profile.script_data_trash, i)
			end
		end
	end)
	
	scriptingFrame:SetScript ("OnHide", function()
		--save
		local scriptObject = scriptingFrame.GetCurrentScriptObject()
		if (scriptObject) then
			scriptingFrame.SaveScript()
		end
		
		--clean the spell hash table
		wipe (scriptingFrame.SpellHashTable)
		wipe (scriptingFrame.SpellIndexTable)
		collectgarbage()
	end)
	
	-- scriptingFrame.ScriptNameTextEntry --name of the script (text entry)
	-- scriptingFrame.ScriptIconButton -- icon pick button
	-- scriptingFrame.ScriptTypeDropdown --type of the script (dropdown)
	-- scriptingFrame.TriggerTextEntry --text entry for the trigger add (text entry)
	-- scriptingFrame.TriggerScrollBox --scrollbox for the triggers (scrollbox)
	-- scriptingFrame.CodeEditorLuaEntry --text entry for the lua editor
	-- scriptingFrame.ScriptSelectionScrollBox --scrollbox with all script created to select
	-- scriptingFrame.CodeTypeDropdown --dropdown for the type of code being edited (runtime or constructor)
	
	scriptingFrame.DefaultScript = [=[
		function (self, unitId, unitFrame, envTable)
			
		end
	]=]
	
	--a new script has been created
	function scriptingFrame.CreateNewScript()

		--build the table of the new script
		local newScriptObject = {
			Enabled = true,
			ScriptType = 0x1,
			Name = "New Script",
			SpellIds = {},
			NpcNames = {},
			Icon = "",
			Desc = "",
			Author = "",
			Time = time(), --is set when the save button is pressed
			Revision = 1, --increase everytime the save button is pressed
			PlaterCore = Plater.CoreVersion, --store the version of plater required to run this script
		}
		
		--scripts
		for i = 1, #Plater.CodeTypeNames do
			local memberName = Plater.CodeTypeNames [i]
			newScriptObject [memberName] = scriptingFrame.DefaultScript
			newScriptObject ["Temp_" .. memberName] = scriptingFrame.DefaultScript
		end

		local playerName = UnitName ("player")
		local realm = GetRealmName()
		
		newScriptObject.Author = playerName .. "-" .. realm
		
		--add it to the database
		tinsert (Plater.db.profile.script_data, newScriptObject)
		
		--start editing the new script
		scriptingFrame.EditScript (#Plater.db.profile.script_data)
		
		--refresh the scrollbox showing all scripts created
		scriptingFrame.ScriptSelectionScrollBox:Refresh()
	end
	
	function scriptingFrame.GetScriptObject (script_id)
		local script = Plater.db.profile.script_data [script_id]
		if (script) then
			return script
		else
			Plater:Msg ("GetScriptObject could find the script id")
			return
		end
	end
	
	function scriptingFrame.GetCurrentScriptObject()
		return currentEditingScript
	end
	
	function scriptingFrame.LoadGameSpells()
		if (not next (scriptingFrame.SpellHashTable)) then
			--load all spells in the game
			DF:LoadAllSpells (scriptingFrame.SpellHashTable, scriptingFrame.SpellIndexTable)
			return true
		end
	end
	
	--restore the values on the text fields and scroll boxes to the values on the object
	function scriptingFrame.CancelEditing (is_deleting)
		if (not is_deleting) then
			--re fill all the text entried and dropdowns to the default from the script
			--doing this to restore the script so it can do a hot reload
			scriptingFrame.UpdateEditingPanel()
			
			--hot reload restored scripts
			scriptingFrame.ApplyScript()
		end
		
		--clear current editing script
		currentEditingScript = nil
		
		--lock the editing panel
		scriptingFrame.EditScriptFrame:LockFrame()
		
		--hide the editing frame
		--scriptingFrame.HideEditPanel()
		
		--reload the script selection scrollbox in case the script got renamed
		scriptingFrame.ScriptSelectionScrollBox:Refresh()
	end
	
	--save all values
	function scriptingFrame.SaveScript()
		--get the current editing object
		local scriptObject = scriptingFrame.GetCurrentScriptObject()
		
		--script name
		scriptObject.Name = scriptingFrame.ScriptNameTextEntry.text
		--script icon
		scriptObject.Icon = scriptingFrame.ScriptIconButton:GetIconTexture()
		--script description
		scriptObject.Desc = scriptingFrame.ScriptDescTextEntry.text
		--script type
		scriptObject.ScriptType = scriptingFrame.ScriptTypeDropdown.value
		
		--triggers are auto save
		
		--transfer the temporarily code saved to the scrip object
		for i = 1, #Plater.CodeTypeNames do
			local memberName = Plater.CodeTypeNames [i]
			scriptObject [memberName] = scriptObject ["Temp_" .. memberName]
		end

		--save the current code
		scriptObject [Plater.CodeTypeNames [scriptingFrame.CodeTypeDropdown.CodeType]] = scriptingFrame.CodeEditorLuaEntry:GetText()

		scriptObject.Time = time()
		scriptObject.Revision = scriptObject.Revision + 1
		
		--do a hot reload on the script
		scriptingFrame.ApplyScript (true)
		
		--reload the script selection scrollbox in case the script got renamed
		scriptingFrame.ScriptSelectionScrollBox:Refresh()
		
		--remove the focus from the editing code textentry
		scriptingFrame.CodeEditorLuaEntry:ClearFocus()
		
		--update the overlapp button
		scriptingFrame.UpdateOverlapButton()
		
		--remove focus of everything
		scriptingFrame.ScriptNameTextEntry:ClearFocus()
		scriptingFrame.ScriptDescTextEntry:ClearFocus()
		scriptingFrame.TriggerTextEntry:ClearFocus()
	end
	
	--hot reload the script by compiling it and applying it to the nameplates without saving
	function scriptingFrame.ApplyScript (on_save)
		--get the text from the text fields, compile and apply the changes to the nameplate without saving the script

		--doing this since the framework send 'self' in the first parameter of the button click
		on_save = type (on_save) == "boolean" and on_save
		
		local code = {}
		--prebuild the code table with the code types (constructor/onupdate etc)
		for i = 1, #Plater.CodeTypeNames do
			local memberName = Plater.CodeTypeNames [i]
			code [memberName] = ""
		end		

		local scriptObject = scriptingFrame.GetCurrentScriptObject()

		if (not on_save) then
			--is hot reload, get the code from the code editor
			for i = 1, #Plater.CodeTypeNames do
				local memberName = Plater.CodeTypeNames [i]
				code [memberName] = scriptObject ["Temp_" .. memberName]
			end
			
			code [Plater.CodeTypeNames [scriptingFrame.CodeTypeDropdown.CodeType]] = scriptingFrame.CodeEditorLuaEntry:GetText()
		else
			--is a save, get the code from the object
			for i = 1, #Plater.CodeTypeNames do
				local memberName = Plater.CodeTypeNames [i]
				code [memberName] = scriptObject [memberName]
			end
		end

		do
			local t = {}
			--build a script table for the comppiler
			for i = 1, #Plater.CodeTypeNames do
				local memberName = Plater.CodeTypeNames [i]
				tinsert (t, code [memberName])
			end
			Plater.CompileScript (scriptObject, unpack (t))
		end
		
		--remove the focus so the user can cast spells etc
		scriptingFrame.CodeEditorLuaEntry:ClearFocus()
	end
	
	--when deleting or disabling a script object, it needs to stop any running script
	function scriptingFrame.KillRunningScriptsForObject (scriptObject)
		--kill scripts running for this script object
		for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
			local unitFrame = plateFrame.UnitFrame

			if (scriptObject.ScriptType == 1) then
				--buff and debuffs
				--iterate among all icons shown in the nameplate and attempt to kill the script by its trigger
				for _, iconAuraFrame in ipairs (unitFrame.BuffFrame.PlaterBuffList) do
					for _, spellID in ipairs (scriptObject.SpellIds) do
						iconAuraFrame:KillScript (spellID)
					end
				end
				for _, iconAuraFrame in ipairs (unitFrame.BuffFrame2.PlaterBuffList) do
					for _, spellID in ipairs (scriptObject.SpellIds) do
						iconAuraFrame:KillScript (spellID)
					end
				end
				
			elseif (scriptObject.ScriptType == 2) then
				--cast bar
				for _, spellID in ipairs (scriptObject.SpellIds) do
					unitFrame.castBar:KillScript (spellID)
				end

			elseif (scriptObject.ScriptType == 3) then
				--nameplate
				for _, triggerID in ipairs (scriptObject.NpcNames) do
					unitFrame:KillScript (triggerID)
				end

			end
			
		end
	end
	
	function scriptingFrame.RemoveScript (scriptId)
		local scriptObjectToBeRemoved = scriptingFrame.GetScriptObject (scriptId)
		local currentScript = scriptingFrame.GetCurrentScriptObject()
		
		--check if the script to be removed is valid
		if (not scriptObjectToBeRemoved) then
			return
		end
		
		scriptingFrame.KillRunningScriptsForObject (scriptObjectToBeRemoved)
		
		--if is the current script being edited, cancel the edit
		if (currentScript == scriptObjectToBeRemoved) then
			--cancel the editing process
			scriptingFrame.CancelEditing (true)
		end
		
		--set the time when the script has been moved to trash
		scriptObjectToBeRemoved.__TrashAt = time()
		
		tinsert (Plater.db.profile.script_data_trash, scriptObjectToBeRemoved)
		tremove (Plater.db.profile.script_data, scriptId)
		
		--refresh the script selection scrollbox
		scriptingFrame.ScriptSelectionScrollBox:Refresh()
		
		GameCooltip:Hide()
		Plater:Msg ("Script moved to trash.")
		
		--reload all scripts
		Plater.WipeAndRecompileAllScripts()
		
		--update overlap button
		scriptingFrame.UpdateOverlapButton()
	end
	
	function scriptingFrame.DuplicateScript (scriptId)
		local scriptToBeCopied = scriptingFrame.GetScriptObject (scriptId)
		local newScript = DF.table.copy ({}, scriptToBeCopied)
		
		tinsert (Plater.db.profile.script_data, newScript)
		scriptingFrame.ScriptSelectionScrollBox:Refresh()
		
		Plater:Msg ("Script duplicated. Make sure to use different triggers.")
		
		--update overlap button
		scriptingFrame.UpdateOverlapButton()
	end
	
	--called from the context menu when right click an option in the script menu
	function scriptingFrame.ExportScript (scriptId)
		local scriptToBeExported = scriptingFrame.GetScriptObject (scriptId)
		
		local LibAceSerializer = LibStub:GetLibrary ("AceSerializer-3.0")
		local LibCompress = LibStub:GetLibrary ("LibCompress")
		
		if (LibAceSerializer and LibCompress) then
			local tableToExport = Plater.PrepareTableToExport (scriptToBeExported)
	
			local serialized = LibAceSerializer:Serialize (tableToExport)
			local encoded = DF.EncodeString (serialized)

			scriptingFrame.ImportTextEditor.IsImporting = false
			scriptingFrame.ImportTextEditor.IsExporting = true

			scriptingFrame.ImportTextEditor:Show()
			scriptingFrame.ImportTextEditor:SetText (encoded)
			scriptingFrame.ImportTextEditor.TextInfo.text = "Exporting '" .. scriptToBeExported.Name .. "'"
			
			--if there's anything being edited, start editing the script which is being exported
			if (not scriptingFrame.GetCurrentScriptObject()) then
				scriptingFrame.EditScript (scriptId)
			end
			
			scriptingFrame.EditScriptFrame:Show()
			
			C_Timer.After (0.3, function()
				scriptingFrame.ImportTextEditor.editbox:SetFocus (true)
				scriptingFrame.ImportTextEditor.editbox:HighlightText()
			end)
		end
	end
	
	function scriptingFrame.ShowImportTextField()
		--if editing a script, save it and close it
		local scriptObject = scriptingFrame.GetCurrentScriptObject()
		if (scriptObject) then
			scriptingFrame.SaveScript()
			scriptingFrame.CancelEditing()
			--refresh the script selection scrollbox
			scriptingFrame.ScriptSelectionScrollBox:Refresh()
		end
		
		--lock the editing panel
		scriptingFrame.EditScriptFrame:LockFrame()
		
		scriptingFrame.EditScriptFrame:Show()
		scriptingFrame.ImportTextEditor:Show()
		scriptingFrame.ImportTextEditor:SetText ("")
		scriptingFrame.ImportTextEditor.IsImporting = true
		scriptingFrame.ImportTextEditor.IsExporting = false
		scriptingFrame.ImportTextEditor:SetFocus (true)
		scriptingFrame.ImportTextEditor.TextInfo.text = "Paste the string:"
	end
	
	--this is only called from the 'okay' button in the import text editor
	function scriptingFrame.ImportScript()
	
		--if clicked in the 'okay' button when the import text editor is showing a string to export, just hide the import editor
		if (scriptingFrame.ImportTextEditor.IsExporting) then
			scriptingFrame.ImportTextEditor.IsImporting = nil
			scriptingFrame.ImportTextEditor.IsExporting = nil
			scriptingFrame.ImportTextEditor:Hide()
			return
		end
	
		local text = scriptingFrame.ImportTextEditor:GetText()

		if (string.len (text) > 0) then
			local LibAceSerializer = LibStub:GetLibrary ("AceSerializer-3.0")
			
			if (LibAceSerializer) then
				local decoded = DF.DecodeString (text)
				if (decoded) then
					local unSerializedOkay, indexScriptTable = LibAceSerializer:Deserialize (decoded)
					if (unSerializedOkay and type (indexScriptTable) == "table") then
						local newScript = Plater.BuildScriptObjectFromIndexTable (indexScriptTable)
						if (newScript) then
							tinsert (Plater.db.profile.script_data, newScript)
							scriptingFrame.ScriptSelectionScrollBox:Refresh()
							scriptingFrame.EditScript (#Plater.db.profile.script_data)
							--refresh the script selection scrollbox
							scriptingFrame.ScriptSelectionScrollBox:Refresh()
						else
							Plater:Msg ("Cannot import: data imported is invalid")
						end
					else
						Plater:Msg ("Cannot import: couldn't unserialize the string")
					end
				else
					Plater:Msg ("Cannot import: couldn't decode the string")
				end
			else
				Plater:Msg ("Cannot import: LibAceSerializer not found")
			end
		end
		
		scriptingFrame.ImportTextEditor.IsImporting = nil
		scriptingFrame.ImportTextEditor:Hide()
	end
	
	--set all values from the current editing script object to all text entried and scroll fields
	function scriptingFrame.UpdateEditingPanel()
		--get the current editing object
			local scriptObject = scriptingFrame.GetCurrentScriptObject()
		
		--set the data from the object in the widgets
			scriptingFrame.ScriptNameTextEntry.text =  scriptObject.Name
			scriptingFrame.ScriptNameTextEntry:ClearFocus()
			scriptingFrame.ScriptIconButton:SetIcon (scriptObject.Icon)
			scriptingFrame.ScriptDescTextEntry.text = scriptObject.Desc or ""
			scriptingFrame.ScriptDescTextEntry:ClearFocus()
			scriptingFrame.ScriptTypeDropdown:Select (scriptObject.ScriptType, true)
			scriptingFrame.TriggerTextEntry.text = ""
			scriptingFrame.TriggerTextEntry:ClearFocus()
			
			--trigger box data
			if (scriptObject.ScriptType == 1 or scriptObject.ScriptType == 2) then
				scriptingFrame.TriggerScrollBox:SetData (scriptObject.SpellIds)
			elseif (scriptObject.ScriptType == 3) then
				scriptingFrame.TriggerScrollBox:SetData (scriptObject.NpcNames)
			end
			scriptingFrame.TriggerScrollBox:Refresh()
			
			--refresh the code editing
			for i = 1, #Plater.CodeTypeNames do
				local memberName = Plater.CodeTypeNames [i]
				scriptObject ["Temp_" .. memberName] = scriptObject [memberName]
			end
			
			--use the runtime code as the default editing script
			scriptingFrame.CodeEditorLuaEntry:SetText (scriptObject [Plater.CodeTypeNames [2]]) 
			scriptingFrame.CodeEditorLuaEntry:ClearFocus()
			
			--update the code type dropdown
			scriptingFrame.CodeTypeDropdown:Select (2)
			scriptingFrame.CodeTypeDropdown.CodeType = 2
	end
	
	--start editing a script
	function scriptingFrame.EditScript (script_id)
	
		local scriptObject
	
		--> check if passed a script object
		if (type (script_id) == "table") then
			scriptObject = script_id
		else
			scriptObject = scriptingFrame.GetScriptObject (script_id)
		end
		
		if (not scriptObject) then
			return
		end
		
		scriptingFrame.EditScriptFrame:UnlockFrame()
		
		scriptingFrame.EditScriptFrame:Show()
		
		--set the new editing script
		currentEditingScript = scriptObject
		
		--load the values in the frame
		scriptingFrame.UpdateEditingPanel()
	end
	
	--add a trigger to the current editing script
	function scriptingFrame.AddTrigger()
		--get the text on the addon trigger text entry
		local text = scriptingFrame.TriggerTextEntry.text
		scriptingFrame.TriggerTextEntry:ClearFocus()
		
		--check the text if is valid
		text = DF:trim (text)
		if (text == "" or string.len (text) < 2) then
			Plater:Msg ("Invalid trigger")
			return
		end

		local scriptObject = scriptingFrame.GetCurrentScriptObject()
		
		if (scriptObject.ScriptType == 1 or scriptObject.ScriptType == 2) then --require a spellId
			--cast the string to number
			local spellId = tonumber (text)
			if (not spellId or not GetSpellInfo (spellId)) then
				--load spell hash table
				scriptingFrame.LoadGameSpells()
				
				--attempt to get the spellId from the hash table
				spellId = scriptingFrame.SpellHashTable [string.lower (text)]
				--if still fail, stop here
				if (not spellId) then
					Plater:Msg ("Trigger requires a valid spell name or an ID of a spell")
					return
				end
			end
			
			--add the spell id
			tinsert (scriptObject.SpellIds, spellId)
			
			--refresh the trigger box
			scriptingFrame.TriggerScrollBox:Refresh()
			
			--check if the script has an icon, if not set the icon
			if (not scriptObject.Icon or scriptObject.Icon == "") then
				local _, _, spellIcon = GetSpellInfo (spellId)
				scriptingFrame.ScriptIconButton:SetIcon (spellIcon)
			end
			
		elseif (scriptObject.ScriptType == 3) then
			--add the npc name
			tinsert (scriptObject.NpcNames, text)
			
			--refresh the trigger box
			scriptingFrame.TriggerScrollBox:Refresh()
		end
		
		--update overlap button
		scriptingFrame.UpdateOverlapButton()
		
		--recompile all
		Plater.WipeAndRecompileAllScripts()
		
		--clear the trigger box
		scriptingFrame.TriggerTextEntry:SetText ("")
		scriptingFrame.TriggerTextEntry:ClearFocus()
		
		Plater:Msg ("Trigger added!")
	end
	
	--store the script object which is currently being edited
	
	function scriptingFrame.GetScriptTriggerTypeName (script_type)
		return scriptingFrame.TriggerTypes [script_type] or "none", scriptingFrame.TriggerTypesDesc [script_type] or ""
	end

	do
		local help_popup = DF:CreateSimplePanel (UIParent, 1000, 480, "Plater Scripting Help", "PlaterScriptingHelp")
		help_popup:SetFrameStrata ("DIALOG")
		help_popup:SetPoint ("center")
		DF:ApplyStandardBackdrop (help_popup, false, 1.2)
		help_popup:Hide()
		
		scriptingFrame.HelpFrame = help_popup
	
		local scripting_help_label = DF:CreateLabel (help_popup, "Script Name:", DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"))
		
		local frontpageText_Welcome = "Scripting allows you to apply a more depth customization into the nameplate.\n"
		local frontpageText_Lua = "A basic knowledge of Lua programming may be required.\n\n"
		local frontpageText_Triggers = "|cFFFFFF00How a Script Works:|r\n\nThere's three types of triggers: |cFFFF5500Auras|r, |cFFFF5500Spell Cast|r and |cFFFF5500Unit Name|r, when a condition for the trigger matches, it begins to run its code.\n\n"
		local frontpageText_Scripts = "There's four types of code:\n|cFFFF5500Constructor|r: runs only once, use to create your custom frames, texture and animations.\n|cFFFF5500On Show|r: is executed each time the script triggers. Use this to show or play frames and animations created inside the constructor.\n|cFFFF5500On Update|r runs every time Plater updates the nameplate. Use this to override something that Plater have set, the nameplate color for example, or, update some information from your custom stuff.\n|cFFFF5500On Hide|r: executed when the trigger doesn't match the condition any more. Use this to hide and stop all your frames and animations.\n"
		local frontpageText_Function = "\n|cFFFFFF00Function Parameters:|r\n\n|cFFC0C0C0function (self, unit, unitFrame, envTable)\n    --code\nend|r\n\n|cFFFF5500self|r: is different for each trigger, for buffs is the frame of the icon, spell casting passes the frame of the cast bar and the unit frame is passed for unit names.\n|cFFFF5500unit|r: unitId of the unit shown in the nameplate, use to query data, for example: UnitName (unitId).\n|cFFFF5500unitFrame|r: is the nameplate unit frame (parent of all widgets), the tooltip of the ? button has all the members to access all components of the nameplate from the unit frame.\n|cFFFF5500envTable|r: a table where you can store data, it also store information about the aura, cast and the unit shown depending on the type of the trigger.\n"
		local frontpageText_ReturnValues = "\nWhat is a |cFFFF5500ReturnValue|r?\nIs what a function returns after a calling it, example:\nenvTable.MyFlash = Plater.CreateFlash (unitFrame.healthBar, 0.05, 2, 'white')\nPlater.CreateFlash() returned an object with information about the flash created, then this information is stored inside '|cFFFF5500envTable.MyFlash|r'\nYou can use it later to play the flash with '|cFFFF5500envTable.MyFlash:Play()|r' or stop it with '|cFFFF5500envTable.MyFlash:Stop()|r'."
		local frontpageText_Parent = "\n\nWhat is a |cFFFF5500Parent|r?\nThe parent field required for create some widgets is the frame which will hold it, in other words: where it will be attach to."
		
		scripting_help_label.text = frontpageText_Welcome .. frontpageText_Lua .. frontpageText_Triggers .. frontpageText_Scripts .. frontpageText_Function .. frontpageText_ReturnValues .. frontpageText_Parent
		scripting_help_label.fontsize = 14
		scripting_help_label:SetPoint ("topleft", help_popup, "topleft", 5, -25)
	end
	
	--create the frame which will hold the create panel
	local edit_script_frame = CreateFrame ("frame", "$parentCreateScript", scriptingFrame)
	edit_script_frame:SetSize (unpack (main_frames_size))
	edit_script_frame:SetScript ("OnShow", function()

	end)
	edit_script_frame:SetScript ("OnHide", function()

	end)
	edit_script_frame:Hide()
	scriptingFrame.EditScriptFrame = edit_script_frame

	
	
	function edit_script_frame.UnlockFrame()
		scriptingFrame.ScriptNameTextEntry:Enable()
		scriptingFrame.ScriptIconButton:Enable()
		scriptingFrame.ScriptDescTextEntry:Enable()
		scriptingFrame.ScriptTypeDropdown:Enable()
		scriptingFrame.TriggerTextEntry:Enable()
		scriptingFrame.AddTriggerButton:Enable()
		
		scriptingFrame.AddAPIDropdown:Enable()
		scriptingFrame.AddFWDropdown:Enable()
		
		scriptingFrame.CodeEditorLuaEntry:Enable()
		scriptingFrame.CodeTypeDropdown:Enable()
		scriptingFrame.ApplyScriptButton:Enable()
		scriptingFrame.SaveScriptButton:Enable()
		scriptingFrame.CancelScriptButton:Enable()
	end
	
	function edit_script_frame.LockFrame()
		scriptingFrame.ScriptNameTextEntry:SetText ("")
		scriptingFrame.ScriptNameTextEntry:Disable()
		scriptingFrame.ScriptIconButton:SetIcon ("")
		scriptingFrame.ScriptIconButton:Disable()
		scriptingFrame.ScriptDescTextEntry:SetText ("")
		scriptingFrame.ScriptDescTextEntry:Disable()
		scriptingFrame.ScriptTypeDropdown:Disable()
		scriptingFrame.TriggerTextEntry:SetText ("")
		scriptingFrame.TriggerTextEntry:Disable()
		scriptingFrame.AddTriggerButton:Disable()
		scriptingFrame.TriggerScrollBox:SetData ({})
		scriptingFrame.TriggerScrollBox:Refresh()
		
		scriptingFrame.AddAPIDropdown:Disable()
		scriptingFrame.AddFWDropdown:Disable()
		
		scriptingFrame.CodeEditorLuaEntry:SetText ("")
		scriptingFrame.CodeEditorLuaEntry:Disable()
		scriptingFrame.CodeTypeDropdown:Disable()
		scriptingFrame.ApplyScriptButton:Disable()
		scriptingFrame.SaveScriptButton:Disable()
		scriptingFrame.CancelScriptButton:Disable()
	end
	
	function scriptingFrame.HideEditPanel()
		edit_script_frame:Hide()
	end
	
	--create new script frame widgets
	
		--textentry to insert the name of the script
			local script_name_label = DF:CreateLabel (edit_script_frame, "Script Name:", DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"))
			local script_name_textentry = DF:CreateTextEntry (edit_script_frame, function()end, 156, 20, "ScriptNameTextEntry", _, _, options_dropdown_template)
			script_name_textentry:SetPoint ("topleft", script_name_label, "bottomleft", 0, -2)
			scriptingFrame.ScriptNameTextEntry = script_name_textentry
		
		--icon selection
			local script_icon_callback = function (texture)
				scriptingFrame.ScriptIconButton:SetIcon (texture)
			end
			local script_icon_label = DF:CreateLabel (edit_script_frame, "Icon:", DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"))
			local script_icon_button = DF:CreateButton (edit_script_frame, function() DF:IconPick (script_icon_callback, true) end, 20, 20, "", 0, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"))
			script_icon_button:SetPoint ("topleft", script_icon_label, "bottomleft", 0, -2)
			scriptingFrame.ScriptIconButton = script_icon_button
		
		--description
			local script_desc_label = DF:CreateLabel (edit_script_frame, "Description:", DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"))
			local script_desc_textentry = DF:CreateTextEntry (edit_script_frame, function()end, 156, 20, "ScriptDescriptionTextEntry", _, _, options_dropdown_template)
			script_desc_textentry:SetPoint ("topleft", script_desc_label, "bottomleft", 0, -2)
			scriptingFrame.ScriptDescTextEntry = script_desc_textentry
		
		--dropdown to select which type of trigger / frame it'll use
			local on_select_tracking_option = function (self, fixed_parameter, value_selected)
				local scriptObject = scriptingFrame.GetCurrentScriptObject()
				
				scriptObject.ScriptType = value_selected
				
				--change the trigger type
					--auras or spellcast
					if (value_selected == 1 or value_selected == 2) then
						scriptingFrame.TriggerScrollBox:SetData (scriptObject.SpellIds)
						scriptingFrame.TriggerLabel.text = "Add Trigger (Spell Id or Spell Name)"
						
					--npc name
					elseif (value_selected == 3) then
						scriptingFrame.TriggerScrollBox:SetData (scriptObject.NpcNames)
						scriptingFrame.TriggerLabel.text = "Add Trigger (Unit Name)"
						
					end
					
					scriptingFrame.TriggerScrollBox:Refresh()
				
				--recompile all
				Plater.WipeAndRecompileAllScripts()
			end
			
			local build_script_type_dropdown_options = function()
				local t = {
					{label = scriptingFrame.GetScriptTriggerTypeName (1), value = 1, onclick = on_select_tracking_option, desc = select (2, scriptingFrame.GetScriptTriggerTypeName (1))},
					{label = scriptingFrame.GetScriptTriggerTypeName (2), value = 2, onclick = on_select_tracking_option, desc = select (2, scriptingFrame.GetScriptTriggerTypeName (2))},
					{label = scriptingFrame.GetScriptTriggerTypeName (3), value = 3, onclick = on_select_tracking_option, desc = select (2, scriptingFrame.GetScriptTriggerTypeName (3))},
				}
				return t
			end
			
			local script_type_label = DF:CreateLabel (edit_script_frame, "Trigger Type:", DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"))
			local script_type_dropdown = DF:CreateDropDown (edit_script_frame, build_script_type_dropdown_options, 1, 160, 20, "ScriptTypeDropdown", _, DF:GetTemplate ("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))
			script_type_dropdown:SetPoint ("topleft", script_type_label, "bottomleft", 0, -2)
			script_type_dropdown.tooltip = "The type of event when the script check for trigger matches, only the selected option is used.\n\n|cFFFFFF00Buffs & Debuffs|r: an aura shown in the nameplate.\n\n|cFFFFFF00Spell Casting|r: the spell the unit is casting.\n\n|cFFFFFF00Unit Name|r: the unit name shown in the nameplate."
			scriptingFrame.ScriptTypeDropdown = script_type_dropdown
		
		--button to add a spellId or npc name trigger
			local add_trigger_label = DF:CreateLabel (edit_script_frame, "Add Trigger (Spell Id or Spell Name)", DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"))
			local add_trigger_textentry = DF:CreateTextEntry (edit_script_frame, function()end, 140, 20, "ScriptTriggerTextEntry", _, _, options_dropdown_template)
			add_trigger_textentry:SetPoint ("topleft", add_trigger_label, "bottomleft", 0, -2)
			add_trigger_textentry.tooltip = "Enter data based on the trigger selected:\n\n|cFFFFFF00Buff and Spell Cast|r: Enter the spell name using lower case letters.\n\n|cFFFFFF00Unit Name|r: Enter the unit name or the npcID."
			scriptingFrame.TriggerTextEntry = add_trigger_textentry
			scriptingFrame.TriggerLabel = add_trigger_label
			
			add_trigger_textentry:SetHook ("OnEditFocusGained", function (self, capsule)
				--if ithe script is for aura or castbar and if the textentry box doesnt have an auto complete table yet
				local scriptObject = scriptingFrame.GetCurrentScriptObject()
				if ((scriptObject.ScriptType == 1 or scriptObject.ScriptType == 2) and (not add_trigger_textentry.SpellAutoCompleteList or not scriptingFrame.SpellIndexTable[1])) then
					--load spell hash table
					scriptingFrame.LoadGameSpells()
					add_trigger_textentry.SpellAutoCompleteList = scriptingFrame.SpellIndexTable
					add_trigger_textentry:SetAsAutoComplete ("SpellAutoCompleteList", nil, true)
				end
			end)

			local add_trigger_button = DF:CreateButton (edit_script_frame, scriptingFrame.AddTrigger, 50, 20, "Add", -1, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
			add_trigger_button:SetIcon ([[Interface\BUTTONS\UI-PlusButton-Up]], 20, 20, "overlay", {0, 1, 0, 1})
			add_trigger_button:SetPoint ("left", add_trigger_textentry, "right", 2, 0)
			--add_trigger_button.tooltip = 
			
			add_trigger_button:SetHook ("OnEnter", function()
				GameCooltip:Preset (2)
				--GameCooltip:SetOption ("TextSize", 11)
				GameCooltip:SetOption ("FixedWidth", 300)
				
				local scriptObject = scriptingFrame.GetCurrentScriptObject()
				
				if ((scriptObject.ScriptType == 1 or scriptObject.ScriptType == 2)) then
					GameCooltip:AddLine ("|cFFFFFF00Important|r: it's normal for the Icon and Description of the spell you added to be different, The name of the spell is used to active the script.\n\nYou can enter the SpellID as well.")
				else
					GameCooltip:AddLine ("|cFFFFFF00Important|r: npc name isn't case-sensitive.\n\n|cFFFFFF00Important|r: you can use the npcId as well for the multi-language support of your script.")
				end
				
				GameCooltip:SetOwner (add_trigger_button.widget)
				GameCooltip:Show()
			end)
			
			add_trigger_button:SetHook ("OnLeave", function()
				GameCooltip:Hide()
			end)
			
			scriptingFrame.AddTriggerButton = add_trigger_button
		
		--list of spells or npc names for this script
			--refresh the list of scripts already created
				local refresh_trigger_scrollbox = function (self, data, offset, total_lines)
					local data
					local scriptObject = scriptingFrame.GetCurrentScriptObject()
					if (scriptObject) then
						if (scriptObject.ScriptType == 1 or scriptObject.ScriptType == 2) then
							data = scriptObject.SpellIds
						elseif (scriptObject.ScriptType == 3) then
							data = scriptObject.NpcNames
						end
					
						--update the scroll
						for i = 1, total_lines do
							local index = i + offset
							local trigger = data [index]
							if (trigger) then
								--update the line
								local line = self:GetLine (i)
								line:UpdateLine (index, trigger)
							end
						end
					end
					
					--update overlap button
					scriptingFrame.UpdateOverlapButton()
				end
			
			--when the user hover over a scrollbox line
				local onenter_trigger_line = function (self)
					if (self.SpellID) then
						GameTooltip:SetOwner (self, "ANCHOR_RIGHT")
						GameTooltip:SetSpellByID (self.SpellID)
						GameTooltip:AddLine (" ")
						GameTooltip:Show()
					end
					self:SetBackdropColor (.3, .3, .3, 0.7)
				end
			
			--when the user leaves a scrollbox line from a hover over
				local onleave_trigger_line = function (self)
					GameTooltip:Hide()
					self:SetBackdropColor (unpack (scrollbox_line_backdrop_color))
				end
			
			--update the trigger line
			local update_trigger_line = function (self, trigger_id, trigger)
				local scriptObject = scriptingFrame.GetCurrentScriptObject()
				
				if (scriptObject.ScriptType == 1 or scriptObject.ScriptType == 2) then
					--spellname
					local spellName, _, spellIcon = GetSpellInfo (trigger)
					self.Icon:SetTexture (spellIcon)
					self.Icon:SetTexCoord (.1, .9, .1, .9)
					self.Icon:SetDesaturated (false)
					self.Icon:SetAlpha (1)
					self.SpellID = trigger
					self.TriggerName:SetText (spellName)
					self.TriggerID:SetText (trigger)
					
				elseif (scriptObject.ScriptType == 3) then
					--npc name
					self.Icon:SetTexture ([[Interface\ICONS\INV_Misc_SeagullPet_01]])
					self.Icon:SetTexCoord (.9, .1, .1, .9)
					self.Icon:SetDesaturated (true)
					self.Icon:SetAlpha (0.5)
					self.SpellID = nil
					self.TriggerName:SetText (trigger)
					self.TriggerID:SetText ("")
				end
				
				self.TriggerId = trigger_id
			end
			
			local onclick_remove_trigger_line = function (self)
				local scriptObject = scriptingFrame.GetCurrentScriptObject()
				local parent = self:GetParent()
				
				local triggerId = parent.TriggerId
				
				--remove the trigger
				if (scriptObject.ScriptType == 1 or scriptObject.ScriptType == 2) then
					--spellname
					tremove (scriptObject.SpellIds, triggerId)
					
				elseif (scriptObject.ScriptType == 3) then
					--npc name
					tremove (scriptObject.NpcNames, triggerId)
				
				end
				
				--refresh the trigger box
				scriptingFrame.TriggerScrollBox:Refresh()
				
				--update overlap button
				scriptingFrame.UpdateOverlapButton()
				
				--recompile all
				Plater.WipeAndRecompileAllScripts()
			end
			
			--create a line in the scroll box
				local create_line_triggerbox = function (self, index)
					--create a new line
					local line = CreateFrame ("button", "$parentLine" .. index, self)
					--set its parameters
					line:SetPoint ("topleft", self, "topleft", 0, -((index-1) * (triggerbox_line_height+1)))
					line:SetSize (triggerbox_size[1], triggerbox_line_height)
					line:SetScript ("OnEnter", onenter_trigger_line)
					line:SetScript ("OnLeave", onleave_trigger_line)
					line:SetBackdrop ({bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
					line:SetBackdropColor (unpack (scrollbox_line_backdrop_color))
					
					local icon = line:CreateTexture ("$parentIcon", "overlay")
					icon:SetSize (triggerbox_line_height - 2, triggerbox_line_height - 2)
					
					local trigger_name = DF:CreateLabel (line, "", DF:GetTemplate ("font", "PLATER_SCRIPTS_NAME"))
					local trigger_id = DF:CreateLabel (line, "", DF:GetTemplate ("font", "PLATER_SCRIPTS_TRIGGER_SPELLID"))
					
					local remove_button = CreateFrame ("button", "$parentRemoveButton", line, "UIPanelCloseButton")
					remove_button:SetSize (16, 16)
					remove_button:SetScript ("OnClick", onclick_remove_trigger_line)
					remove_button:SetPoint ("topright", line, "topright")
					remove_button:GetNormalTexture():SetDesaturated (true)

					icon:SetPoint ("left", line, "left", 2, 0)
					trigger_name:SetPoint ("topleft", icon, "topright", 4, -2)
					trigger_id:SetPoint ("topleft", trigger_name, "bottomleft", 0, 0)
					
					line.Icon = icon
					line.TriggerName = trigger_name
					line.TriggerID = trigger_id
					line.RemoveButton = remove_button

					line.UpdateLine = update_trigger_line
					line:Hide()
					
					return line
				end
			
			--scroll showing all triggers of the script
				local trigger_scrollbox_label = DF:CreateLabel (edit_script_frame, "Triggers:", DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"))
				local trigger_scrollbox = DF:CreateScrollBox (edit_script_frame, "$parentTriggerScrollBox", refresh_trigger_scrollbox, {}, triggerbox_size[1], triggerbox_size[2], triggerbox_lines, triggerbox_line_height)
				trigger_scrollbox:SetPoint ("topleft", trigger_scrollbox_label.widget, "bottomleft", 0, -4)
				trigger_scrollbox:SetBackdrop ({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
				trigger_scrollbox:SetBackdropColor (0, 0, 0, 0.2)
				trigger_scrollbox:SetBackdropBorderColor (0, 0, 0, 1)
				scriptingFrame.TriggerScrollBox = trigger_scrollbox
				DF:ReskinSlider (trigger_scrollbox)
				
				local overlapFrame = DF:CreateSimplePanel (UIParent, 600, 400, "Trigger Overlap", "PlaterScriptTriggerOverlap")
				overlapFrame:SetFrameStrata ("DIALOG")
				overlapFrame:SetPoint ("center")
				DF:ApplyStandardBackdrop (overlapFrame, false, 1.2)
				overlapFrame.OverlappedScriptFrames = {}
				overlapFrame:Hide()
				
				local enableScriptFromOverlapPanel = function (self, fixedParameter, scriptObject, value2)
					scriptObject.Enabled = true
					
					scriptingFrame.UpdateOverlapButton()
					scriptingFrame.ScriptSelectionScrollBox:Refresh()
					overlapFrame.RefreshPanel()
				end
				
				local disableScriptFromOverlapPanel = function (self, fixedParameter, scriptObject, value2)
					scriptObject.Enabled = false
					
					scriptingFrame.UpdateOverlapButton()
					scriptingFrame.ScriptSelectionScrollBox:Refresh()
					overlapFrame.RefreshPanel()
				end
				
				local removeTriggerFromOverlapPanel = function (self, fixedParameter, scriptObject, triggerId)
					if (scriptObject.ScriptType == 0x1 or scriptObject.ScriptType == 0x2) then
						for index, trigger in ipairs (scriptObject.SpellIds) do
							if (trigger == triggerId) then
								tremove (scriptObject.SpellIds, index)
								break
							end
						end
					else
						for index, trigger in ipairs (scriptObject.NpcNames) do
							if (trigger == triggerId) then
								tremove (scriptObject.NpcNames, index)
								break
							end
						end
					end
					
					scriptingFrame.UpdateOverlapButton()
					overlapFrame.RefreshPanel()
					
					--reload all scripts
					Plater.WipeAndRecompileAllScripts()
				end
				
				local onEnterOverlapPanelLine = function (self)
					self:SetBackdropColor (0.5, 0.5, 0.5, 1)
				end
				
				local onLeaveOverlapPanelLine = function (self)
					self:SetBackdropColor (unpack (self.OriginalBackdropColor))
				end
				
				local onClickOverlapPanelLine = function (self)
					if (self.ScriptObject) then
						local currentScriptObject = scriptingFrame.GetCurrentScriptObject()
						--check if isn't the same script
						local scriptToBeEdited = self.ScriptObject
						if (scriptToBeEdited == currentScriptObject) then
							--no need to load the new script if is the same
							return
						end
						
						--save the current script if any
						if (currentScriptObject) then
							scriptingFrame.SaveScript()
						end
						
						--select the script to start edit
						scriptingFrame.EditScript (self.ScriptObject)
						--refresh the script list to update the backdrop color of the selected script
						scriptingFrame.ScriptSelectionScrollBox:Refresh()
						
						--check if the import/export text field is shown and hide it
						if (scriptingFrame.ImportTextEditor:IsShown()) then
							scriptingFrame.ImportTextEditor:Hide()
						end
					end
				end

				overlapFrame.RefreshPanel = function()
				
					if (not overlapFrame:IsShown()) then
						return
					end
				
					if (not overlapFrame.CreateNewFrameTable) then
					
						local reset = function (f)
							f.TriggerName.text = ""
							f.TriggerId.text = ""
							
							for i = 1, #f.Scripts do
								f.Scripts [i].Parent:Hide()
							end
						end
					
						function overlapFrame:CreateNewFrameTable()
							local i = #overlapFrame.OverlappedScriptFrames + 1
							local f = CreateFrame ("frame", "$parentTriggerCluster" .. i, overlapFrame)
							f:SetSize (590, 20)
							f.Reset = reset
							DF:ApplyStandardBackdrop (f, true, 0.1)
							
							if (i == 1) then
								f:SetPoint ("topleft", overlapFrame, "topleft", 5, -26)
							else
								f:SetPoint ("topleft", overlapFrame.OverlappedScriptFrames [i - 1], "bottomleft", 0, -2)
							end
							
							f.TriggerName = DF:CreateLabel (f)
							f.TriggerIcon = DF:CreateImage (f, "", 18, 18)
							f.TriggerIcon:SetPoint (5, -5)
							f.TriggerName:SetPoint ("left", f.TriggerIcon, "right", 2, 0)
							
							f.TriggerId = DF:CreateLabel (f)
							f.TriggerId:SetPoint (250, -5)
							
							f.Scripts = {}
							
							for o = 1, 2 do
								overlapFrame:CreateFrameForScript (f, o)
							end
							
							tinsert (overlapFrame.OverlappedScriptFrames, f)
							
							return f
						end
						
						function overlapFrame:CreateFrameForScript (f, i)
							local ff = CreateFrame ("frame", "$parentLine" .. i, f)
							ff:SetSize (580, 22)
							ff:SetPoint ("topleft", f, "topleft", 0, -24 - ((i - 1) * 23))
							DF:ApplyStandardBackdrop (ff, true, 0.8)
							ff:SetBackdropBorderColor (0, 0, 0, 0)
							ff:SetFrameLevel (f:GetFrameLevel() + 5)
							
							ff.OriginalBackdropColor = {ff:GetBackdropColor()}
							
							local scriptName = DF:CreateLabel (ff)
							local enableScript = DF:CreateButton (ff, enableScriptFromOverlapPanel, 120, 20, "Enable Script", nil, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
							local disableScript = DF:CreateButton (ff, disableScriptFromOverlapPanel, 120, 20, "Disable Script", nil, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
							local removeTrigger = DF:CreateButton (ff, removeTriggerFromOverlapPanel, 120, 20, "Remove Trigger", nil, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
							
							--> create a background below the script name to make an impression it's a button
							local nameBackdrop = CreateFrame ("frame", nil, ff)
							nameBackdrop:SetSize (140, 20)
							DF:ApplyStandardBackdrop (nameBackdrop)
							nameBackdrop:SetPoint ("topleft", ff, "topleft", 3, 0)
							nameBackdrop:EnableMouse (false)
							nameBackdrop:SetBackdropColor (0, 0, 0, 0)
							nameBackdrop.__background:Hide()
							
							scriptName:SetPoint (5, -4)
							enableScript:SetPoint (160, 0)
							disableScript:SetPoint ("left", enableScript, "right", 2, 0)
							removeTrigger:SetPoint ("left", disableScript, "right", 2, 0)
							
							ff:SetScript ("OnEnter", onEnterOverlapPanelLine)
							ff:SetScript ("OnLeave", onLeaveOverlapPanelLine)
							ff:SetScript ("OnMouseDown", onClickOverlapPanelLine)
							
							tinsert (f.Scripts, {ScriptName = scriptName, EnableButton = enableScript, DisableButton = disableScript, RemoveButton = removeTrigger, Parent = ff})
							
							return f.Scripts [#f.Scripts]
						end
					end
				
					local overlaps = scriptingFrame.OverlapButton.OverlapTable
					if (overlaps) then
					
						--reset frames
						for i, frame in ipairs (overlapFrame.OverlappedScriptFrames) do
							frame:Reset()
							frame:Hide()
						end
						
						local i = 1
						
						for triggerTypeName, overlapTable in pairs (scriptingFrame.OverlapButton.OverlapTable) do
							for triggerId, scriptsTable in pairs (overlapTable) do
							
								local frameTable = overlapFrame.OverlappedScriptFrames [i]
								if (not frameTable) then
									frameTable = overlapFrame:CreateNewFrameTable()
								end
								
								frameTable:Reset()
								frameTable:Show()
								
								local triggerName = triggerId
								local triggerIcon = ""
								if (scriptsTable[1].ScriptType == 0x1 or scriptsTable[1].ScriptType == 0x2) then
									triggerName, _, triggerIcon = GetSpellInfo (triggerId)
									frameTable.TriggerIcon.texture = triggerIcon
									frameTable.TriggerIcon:SetTexCoord (.1, .9, .1, .9)
								else
									frameTable.TriggerIcon.texture = ""
								end
								
								frameTable.TriggerName.text = triggerName
								frameTable.TriggerId.text = triggerId .. " [" .. ((scriptingFrame.TriggerTypes [triggerTypeName == "Auras" and 1 or triggerTypeName == "Casts" and 2 or triggerTypeName == "Npcs" and 3]) or "") .. "]"

								for o = 1, #scriptsTable do
									local scriptF = frameTable.Scripts [o]
									if (not scriptF) then
										scriptF = overlapFrame:CreateFrameForScript (frameTable, o)
									end
									
									local scriptObject = scriptsTable [o]
									
									scriptF.ScriptName.text = scriptObject.Name
									scriptF.Parent.ScriptObject = scriptObject
									
									if (not scriptObject.Enabled) then
										scriptF.EnableButton:SetClickFunction (enableScriptFromOverlapPanel, scriptObject)
										scriptF.EnableButton:Enable()
									else
										scriptF.EnableButton:Disable()
									end
									
									if (scriptObject.Enabled) then
										scriptF.DisableButton:SetClickFunction (disableScriptFromOverlapPanel, scriptObject)
										scriptF.DisableButton:Enable()
									else
										scriptF.DisableButton:Disable()
									end
									
									scriptF.RemoveButton:SetClickFunction (removeTriggerFromOverlapPanel, scriptObject, triggerId)
									scriptF.Parent:Show()
								end
								
								frameTable:SetHeight (22 + (#scriptsTable * 26))
								
								i = i + 1
							end
						end
						
					else
						overlapFrame:Hide()
					end
				end
				
				overlapFrame:SetScript ("OnShow", function()
					overlapFrame.RefreshPanel()
				end)
				
				--add script overlap button / frame
				local overlapButton = Plater:CreateButton (scriptingFrame, function() overlapFrame:Show() end, 160, 20, "Trigger Overlaps: 0", -1, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
				overlapButton:SetPoint ("topleft", trigger_scrollbox, "bottomleft", 0, -2)
				overlapButton:SetPoint ("topright", trigger_scrollbox, "bottomright", 0, -2)
				scriptingFrame.OverlapButton = overlapButton
				
				overlapButton:SetHook ("OnEnter", function (self)
					GameCooltip:Preset (2)
					GameCooltip:SetOption ("TextSize", 11)
					GameCooltip:SetOption ("FixedWidth", 300)
					
					GameCooltip:AddLine ("Trigger Overlaps", "", 1, "yellow", "yellow", 12, nil, "OUTLINE")
					GameCooltip:AddLine ("A SpellID, NpcName or NpcID cannot be used in more than 1 script with the same Trigger Type.")
					
					GameCooltip:AddLine (" ")
					GameCooltip:AddLine ("Trigger Name", "Trigger ID", 1, "yellow", "yellow", 12)
					
					if (overlapButton.OverlapAmount and overlapButton.OverlapAmount > 0) then
						for triggerId, scriptsTable in pairs (overlapButton.OverlapTable.Auras) do
							local triggerName = GetSpellInfo (triggerId)
							GameCooltip:AddLine (triggerName, triggerId .. " [" .. scriptingFrame.TriggerTypes [1] .. "]")
						end
						for triggerId, scriptsTable in pairs (overlapButton.OverlapTable.Casts) do
							local triggerName = GetSpellInfo (triggerId)
							GameCooltip:AddLine (triggerName, triggerId .. " [" .. scriptingFrame.TriggerTypes [1] .. "]")
						end
						for triggerId, scriptsTable in pairs (overlapButton.OverlapTable.Npcs) do
							local triggerName = triggerId
							GameCooltip:AddLine (triggerName, triggerId .. " [" .. scriptingFrame.TriggerTypes [1] .. "]")
						end
						
						GameCooltip:AddLine (" ")
						GameCooltip:AddLine ("click for more information", "", 1, "green")
					end

					GameCooltip:SetOwner (self)
					GameCooltip:Show()
				end)
				overlapButton:SetHook ("OnLeave", function()
					GameCooltip:Hide()
				end)
				
				function scriptingFrame.UpdateOverlapButton()
					local overlappedTriggers, amoutOfOverlaps = Plater.CheckScriptTriggerOverlap()
					overlapButton:SetText ("Trigger Overlaps: " .. amoutOfOverlaps)
					
					if (amoutOfOverlaps > 0) then
						overlapButton:SetTemplate (DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"))
						overlapButton:SetTextColor (DF:GetTemplate ("font", "PLATER_BUTTON").color)
					else
						overlapButton:SetTemplate (DF:GetTemplate ("button", "PLATER_BUTTON_DISABLED"))
						local r, g, b = unpack (DF:GetTemplate ("font", "PLATER_BUTTON").color)
						overlapButton:SetTextColor (r/2, g/2, b/2)
					end
					
					overlapButton.OverlapAmount = amoutOfOverlaps
					overlapButton.OverlapTable = overlappedTriggers
					
					PlaterScriptTriggerOverlap.RefreshPanel()
				end
				
			--create the scrollbox lines
				for i = 1, scrollbox_lines do 
					trigger_scrollbox:CreateLine (create_line_triggerbox)
				end
		
		--import and export string text editor
				local import_text_editor = DF:NewSpecialLuaEditorEntry (edit_script_frame, edit_script_size[1], edit_script_size[2], "ImportEditor", "$parentImportEditor", true)
				import_text_editor:SetBackdrop ({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
				import_text_editor:SetBackdropBorderColor (unpack (luaeditor_border_color))
				import_text_editor:SetBackdropColor (unpack (luaeditor_backdrop_color))
				import_text_editor:Hide()
				
				--hide the code editor when the import text editor is shown
				import_text_editor:SetScript ("OnShow", function()
					scriptingFrame.CodeEditorLuaEntry:Hide()
				end)
				
				--show the code editor when the import text editor is hide
				import_text_editor:SetScript ("OnHide", function()
					scriptingFrame.CodeEditorLuaEntry:Show()
				end)
				
				scriptingFrame.ImportTextEditor = import_text_editor
				
				--import info
					info_import_label = DF:CreateLabel (import_text_editor, "IMPORT INFO:", DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"))
					info_import_label:SetPoint ("bottomleft", import_text_editor, "topleft", 0, 2)
					scriptingFrame.ImportTextEditor.TextInfo = info_import_label
					
				--import button
					local okay_import_button = DF:CreateButton (import_text_editor, scriptingFrame.ImportScript, buttons_size[1], buttons_size[2], "Okay", -1, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
					okay_import_button:SetIcon ([[Interface\BUTTONS\UI-Panel-BiggerButton-Up]], 20, 20, "overlay", {0.1, .9, 0.1, .9})
				
				--cancel button
					local cancel_import_button = DF:CreateButton (import_text_editor, function() scriptingFrame.ImportTextEditor:Hide() end, buttons_size[1], buttons_size[2], "Cancel", -1, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
					cancel_import_button:SetIcon ([[Interface\BUTTONS\UI-Panel-MinimizeButton-Up]], 20, 20, "overlay", {0.1, .9, 0.1, .9})
			
		--edit script text entry
				local code_editor = DF:NewSpecialLuaEditorEntry (edit_script_frame, edit_script_size[1], edit_script_size[2], "CodeEditor", "$parentCodeEditor")
				
				code_editor.scroll:SetBackdrop (nil)
				code_editor.editbox:SetBackdrop (nil)
				code_editor:SetBackdrop (nil)
				
				DF:ReskinSlider (code_editor.scroll)
				
				--DF:ApplyStandardBackdrop (code_editor, false, 1)
				
				if (not code_editor.__background) then
					code_editor.__background = code_editor:CreateTexture (nil, "background")
				end
				
				code_editor:SetBackdrop ({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1})
				code_editor:SetBackdropBorderColor (0, 0, 0, 1)
				
				code_editor.__background:SetColorTexture (0.2317647, 0.2317647, 0.2317647)
				code_editor.__background:SetVertexColor (0.27, 0.27, 0.27)
				code_editor.__background:SetAlpha (0.8)
				code_editor.__background:SetVertTile (true)
				code_editor.__background:SetHorizTile (true)
				code_editor.__background:SetAllPoints()				
				
				--code_editor:SetAsAutoComplete ("AutoCompleteAPI", DF.AutoCompleteAPI)
				
				scriptingFrame.CodeEditorLuaEntry = code_editor
				
				--api help small frame
				local unit_frame_components_menu = DF:CreateButton (code_editor, function() end, 100, 20, "Components", -1, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
				unit_frame_components_menu:SetIcon ([[Interface\FriendsFrame\UI-FriendsList-Large-Up]], 16, 16, "overlay", {.2, .74, .27, .75}, nil, 4)
				
				local onSelectComponentMember = function (a, d, member)
					code_editor.editbox:Insert (member)
					GameCooltip:Hide()
				end
				
				local buildComponentTableMenu = function()
					GameCooltip:Preset (2)
					GameCooltip:SetOption ("TextSize", 11)
					GameCooltip:SetOption ("FixedWidth", 300)
					
					GameCooltip:AddLine ("Nameplate Components", "", 1, "yellow", "yellow", 12, nil, "OUTLINE")
					
					local backgroundAlpha = 0.2
					
					for i = 1, #scriptingFrame.UnitFrameMembers do 
						GameCooltip:AddLine (scriptingFrame.UnitFrameMembers [i])
						GameCooltip:AddMenu (1, onSelectComponentMember, scriptingFrame.UnitFrameMembers [i])
						GameCooltip:AddStatusBar (100, 1, 0, 0, 0, backgroundAlpha)
					end
				end

				unit_frame_components_menu.CoolTip = {
					Type = "menu",
					BuildFunc = buildComponentTableMenu,
					ShowSpeed = 0.05,
				}
				
				GameCooltip2:CoolTipInject (unit_frame_components_menu)
				
				--script env helper
				local script_env_helper = DF:CreateButton (code_editor, function() end, 100, 20, "envTable", -1, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
				script_env_helper:SetIcon ([[Interface\FriendsFrame\UI-FriendsList-Small-Up]], 16, 16, "overlay", {.2, .74, .27, .75}, nil, 4)
				
				local onSelectEnvTableMember = function (a, d, member)
					code_editor.editbox:Insert (member)
					GameCooltip:Hide()
				end
				
				local buildEnvTableMenu = function()
				
					local scriptObject = scriptingFrame.GetCurrentScriptObject()
				
					if (not scriptObject) then
						GameCooltip:Preset (2)
						GameCooltip:SetOption ("TextSize", 11)
						GameCooltip:SetOption ("FixedWidth", 400)
						GameCooltip:AddLine ("*No script loaded", "", 1, "red")
						GameCooltip:AddLine ("Use this menu to quick add to your code a member from envTable")
						return
					end
				
					GameCooltip:Preset (2)
					GameCooltip:SetOption ("TextSize", 11)
					GameCooltip:SetOption ("FixedWidth", 400)

					local backgroundAlpha = 0.2
					--if (scriptObject.ScriptType == 0x1) then
					if (not scriptObject or scriptObject.ScriptType == 0x1) then
						GameCooltip:AddLine ("envTable Members for Trigger Buffs and Debuffs", "", 1, "yellow", "yellow", 12, nil, "OUTLINE")
						
						for index, member in ipairs (Plater.TriggerDefaultMembers [1]) do
							GameCooltip:AddLine (member, "", 1, "orange", "white"); GameCooltip:AddStatusBar (100, 1, 0, 0, 0, backgroundAlpha)
							GameCooltip:AddMenu (1, onSelectEnvTableMember, member)
						end
						
						--adds a space to separate from the infor of the next trigger
						if (not scriptObject) then
							GameCooltip:AddLine (" ")
						end
					end
					
					if (not scriptObject or scriptObject.ScriptType == 0x2) then
						GameCooltip:AddLine ("envTable Members for Trigger Spell Casting", "", 1, "yellow", "yellow", 12, nil, "OUTLINE")
						
						for index, member in ipairs (Plater.TriggerDefaultMembers [2]) do
							GameCooltip:AddLine (member, "", 1, "orange", "white"); GameCooltip:AddStatusBar (100, 1, 0, 0, 0, backgroundAlpha)
							GameCooltip:AddMenu (1, onSelectEnvTableMember, member)
						end
						
						--adds a space to separate from the infor of the next trigger
						if (not scriptObject) then
							GameCooltip:AddLine (" ")
						end
					end
					
					if (not scriptObject or scriptObject.ScriptType == 0x3) then
						GameCooltip:AddLine ("envTable Members for Trigger Unit Name", "", 1, "yellow", "yellow", 12, nil, "OUTLINE")
					
						for index, member in ipairs (Plater.TriggerDefaultMembers [3]) do
							GameCooltip:AddLine (member, "", 1, "orange", "white"); GameCooltip:AddStatusBar (100, 1, 0, 0, 0, backgroundAlpha)
							GameCooltip:AddMenu (1, onSelectEnvTableMember, member)
						end
					end
					
					GameCooltip:AddLine (" ")
					GameCooltip:AddLine ("envTable Members From Constructor Code:", "", 1, "yellow", "yellow", 12, nil, "OUTLINE")
					
					--> get the constructor code from the editor if the current editing is the constructor or get the temporarily saved script from the script object
					local code = scriptingFrame.CodeTypeDropdown.CodeType == 2 and scriptingFrame.CodeEditorLuaEntry:GetText() or scriptObject ["Temp_" .. Plater.CodeTypeNames [2]]
					if (code) then
						--> find all member names added to the envTable
						--> add all members in the comments too
						local alreadyAdded = {}
						for _, memberName in code:gmatch ("(envTable%.)(.-)(%s)") do
							memberName = DF:Trim (memberName)
							if (not memberName:find ("%s") and not alreadyAdded [memberName]) then
								alreadyAdded [memberName] = memberName
								GameCooltip:AddLine ("envTable." .. memberName, "", 1, "orange", "white"); GameCooltip:AddStatusBar (100, 1, 0, 0, 0, backgroundAlpha)
								GameCooltip:AddMenu (1, onSelectEnvTableMember, "envTable." .. memberName)
							end
						end
					end
						
				end
				
				script_env_helper.CoolTip = {
					Type = "menu",
					BuildFunc = buildEnvTableMenu,
					ShowSpeed = 0.05,
				}
				
				GameCooltip2:CoolTipInject (script_env_helper)
				
				--add api palette dropdown
					local on_select_FW_option = function (self, fixed_parameter, option_selected)
						local api = scriptingFrame.APIList [option_selected]
						code_editor.editbox:Insert (api.Signature)
					end
					
					local build_API_dropdown_options = function()
						local t = {}
						for i = 1, #scriptingFrame.APIList do 
							local api = scriptingFrame.APIList [i]
							t [#t + 1] = {label = api.Name, value = i, onclick = on_select_FW_option, desc = "Signature:\n|cFFFFFF00" .. api.Signature .. "|r\n\n" .. api.Desc, tooltipwidth = 300}
						end
						return t
					end
					
					local add_API_label = DF:CreateLabel (edit_script_frame, "API Palette:", DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"))
					local add_API_dropdown = DF:CreateDropDown (edit_script_frame, build_API_dropdown_options, 1, 130, 20, "AddAPIDropdown", _, DF:GetTemplate ("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))
					scriptingFrame.AddAPIDropdown = add_API_dropdown
					add_API_dropdown:SetFrameStrata (code_editor:GetFrameStrata())
					add_API_dropdown:SetFrameLevel (code_editor:GetFrameLevel()+100)
					
					--top left of the code editor
					script_env_helper:SetPoint ("bottomleft", code_editor, "topleft", 0, 2)
					unit_frame_components_menu:SetPoint ("left", script_env_helper, "right", 2, 0)
					
					--top right of the code editor
					add_API_dropdown:SetPoint ("bottomright", code_editor, "topright", 0, 2)
					add_API_label:SetPoint ("right", add_API_dropdown, "left", -2, 0)

				--add framework palette dropdowns
					local frameworkSelected
					local memberNameCallback = function (text)
						if (text and text ~= "" and not text:find ("%s")) then
							text = DF:Trim (text)
							local textToAdd = frameworkSelected.Signature
							
							--save the current cursor position
							code_editor.editbox:SetFocus (true)
							local cursorPosition = code_editor.editbox:GetCursorPosition()
							
							--insert the text
							local textToInsert = "envTable." .. text .. " = envTable." .. text .. " or " .. frameworkSelected.Signature
							code_editor.editbox:Insert (textToInsert)
							
							if (frameworkSelected.AddCall) then
								code_editor.editbox:Insert ("\n")
								local addCallString = frameworkSelected.AddCall
								addCallString = addCallString:gsub ("@ENV@", "envTable." .. text)
								code_editor.editbox:Insert (addCallString)
								code_editor.editbox:Insert ("\n")
							end

							--restore the cursor position
							local argumentStart = textToInsert:find ("%(")
							code_editor.editbox:SetCursorPosition (cursorPosition + argumentStart)
							
						else
							Plater:Msg ("Invalid variable name.")
						end
					end
					
					local on_select_FW_option = function (self, fixed_parameter, option_selected)
						local framework = scriptingFrame.FrameworkList [option_selected]
						
						if (framework.AddVar) then
							frameworkSelected = framework
							DF:ShowTextPromptPanel ("Name the variable using letters, numbers and no spaces (e.g. myFlash, overlayTexture, animation1)", memberNameCallback)
						else
							code_editor.editbox:Insert (framework.Signature)
						end
					end
					
					local build_FW_dropdown_options = function()
						local t = {}
						for i = 1, #scriptingFrame.FrameworkList do 
							local api = scriptingFrame.FrameworkList [i]
							t [#t + 1] = {label = api.Name, value = i, onclick = on_select_FW_option, desc = "Signature:\n|cFFFFFF00" .. api.Signature .. "|r\n\n" .. api.Desc, tooltipwidth = 300}
						end
						return t
					end
					
					local add_FW_label = DF:CreateLabel (edit_script_frame, "Framework Palette:", DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"))
					local add_FW_dropdown = DF:CreateDropDown (edit_script_frame, build_FW_dropdown_options, 1, 130, 20, "AddFWDropdown", _, DF:GetTemplate ("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))
					scriptingFrame.AddFWDropdown = add_FW_dropdown
					add_FW_dropdown:SetFrameStrata (code_editor:GetFrameStrata())
					add_FW_dropdown:SetFrameLevel (code_editor:GetFrameLevel()+100)
				
					add_FW_dropdown:SetPoint ("right", add_API_label, "left", -10, 0)
					add_FW_label:SetPoint ("right", add_FW_dropdown, "left", -2, 0)
				
				--error text
				local errortext_frame = CreateFrame ("frame", nil, code_editor)
				errortext_frame:SetPoint ("bottomleft", code_editor, "bottomleft", 1, 1)
				errortext_frame:SetPoint ("bottomright", code_editor, "bottomright", -1, 1)
				errortext_frame:SetHeight (20)
				errortext_frame:SetBackdrop ({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
				errortext_frame:SetBackdropBorderColor (unpack (luaeditor_border_color))
				errortext_frame:SetBackdropColor (0, 0, 0)
				
				local errortext_label = DF:CreateLabel (errortext_frame, "", DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"))
				errortext_label.textcolor = "red"
				--errortext_label:SetPoint ("bottomright", code_editor, "topright", 0, 2)
				errortext_label:SetPoint ("left", errortext_frame, "left", 3, 0)
				
				code_editor.NextCodeCheck = 0.33
				
				code_editor:HookScript ("OnUpdate", function (self, deltaTime)
				
					code_editor.NextCodeCheck = code_editor.NextCodeCheck - deltaTime
					
					if (code_editor.NextCodeCheck < 0) then
					
						local script = code_editor:GetText()
						script = "return " .. script
						local func, errortext = loadstring (script, "Q")
						if (not func) then
							local firstLine = strsplit ("\n", script, 2)
							errortext = errortext:gsub (firstLine, "")
							errortext = errortext:gsub ("%[string \"", "")
							errortext = errortext:gsub ("...\"]:", "")
							errortext = errortext:gsub ("Q\"]:", "")
							errortext = "Line " .. errortext
							errortext_label.text = errortext
						else
							errortext_label.text = ""
						end
						
						code_editor.NextCodeCheck = 0.33
					end
					--
				end)
		
		--apply button
			local apply_script_button = DF:CreateButton (code_editor, scriptingFrame.ApplyScript, buttons_size[1], buttons_size[2], "Apply", -1, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
			apply_script_button:SetIcon ([[Interface\BUTTONS\UI-Panel-BiggerButton-Up]], 20, 20, "overlay", {0.1, .9, 0.1, .9})
		
		--save button
			local save_script_button = DF:CreateButton (code_editor, scriptingFrame.SaveScript, buttons_size[1], buttons_size[2], "Save", -1, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
			save_script_button:SetIcon ([[Interface\BUTTONS\UI-Panel-ExpandButton-Up]], 20, 20, "overlay", {0.1, .9, 0.1, .9})
			
		--cancel button
			local cancel_script_button = DF:CreateButton (code_editor, scriptingFrame.CancelEditing, buttons_size[1], buttons_size[2], "Cancel", -1, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
			cancel_script_button:SetIcon ([[Interface\BUTTONS\UI-Panel-MinimizeButton-Up]], 20, 20, "overlay", {0.1, .9, 0.1, .9})
			
			scriptingFrame.ApplyScriptButton = apply_script_button
			scriptingFrame.SaveScriptButton = save_script_button
			scriptingFrame.CancelScriptButton = cancel_script_button
			
		--change the script code type (when the user select from normal runtime code or constructor code)
			local on_select_code_type =  function (self, fixed_parameter, value_selected)
				--get the current editing script
				local scriptObject = scriptingFrame.GetCurrentScriptObject()
				
				--save the current code
				scriptObject ["Temp_" .. Plater.CodeTypeNames [scriptingFrame.CodeTypeDropdown.CodeType]] = scriptingFrame.CodeEditorLuaEntry:GetText()
				
				--load the code
				scriptingFrame.CodeEditorLuaEntry:SetText (scriptObject ["Temp_" .. Plater.CodeTypeNames [value_selected]])
				
				--update the code type
				scriptingFrame.CodeTypeDropdown.CodeType = value_selected
			end
			
			local build_script_code_dropdown_options = function()
				local t = {}
				for i = 1, #scriptingFrame.CodeTypes do
					local thisType = scriptingFrame.CodeTypes [i]
					tinsert (t, {label = thisType.Name, value = thisType.Value, desc = thisType.Desc, onclick = on_select_code_type})
				end
				return t
			end
			
			local code_type_label = DF:CreateLabel (code_editor, "Code Type:", DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"))
			local code_type_dropdown = DF:CreateDropDown (code_editor, build_script_code_dropdown_options, 1, 160, 20, "CodeTypeDropdown", _, DF:GetTemplate ("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))
			code_type_dropdown:SetPoint ("left", code_type_label, "right", 2, 0)
			code_type_dropdown.CodeType = 1
			scriptingFrame.CodeTypeDropdown = code_type_dropdown

	--script for the button to show the create panel
	local onclick_create_new_script_button = function()
		scriptingFrame.CreateNewScript()
	end
	
	--create new script script button, it does use the width of the scrollbox to select a created script	
	local create_new_script_button = DF:CreateButton (scriptingFrame, onclick_create_new_script_button, scrollbox_size[1] - (28*3), buttons_size[2], "New Script", -1, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
	create_new_script_button:SetPoint ("topleft", scriptingFrame, "topleft", 10, start_y)
	create_new_script_button:SetIcon ([[Interface\BUTTONS\UI-PlusButton-Up]], 20, 20, "overlay", {0, 1, 0, 1})
	
	--create the trash restore button
	local restore_script_button = DF:CreateButton (scriptingFrame, function() GameCooltip:Hide() end, 26, buttons_size[2], "", nil, nil, nil, nil, nil, false, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"))
	restore_script_button:SetPoint ("left", create_new_script_button, "right", 2, 0)
	restore_script_button:SetIcon ([[Interface\AddOns\Plater\images\icons]], 16, 16, "overlay", {0, 64/512, 0, 64/512}, {0.945, .635, 0}, nil, nil, nil, false)
	scriptingFrame.RestoreScriptButton = restore_script_button
	
	local restore_from_trashcan = function (self, fixed_parameter, script_id)
		local restoredScriptObject = Plater.db.profile.script_data_trash [script_id]
		
		restoredScriptObject.__TrashAt = nil
		
		tinsert (Plater.db.profile.script_data, restoredScriptObject)
		tremove (Plater.db.profile.script_data_trash, script_id)
		
		--start editing the restored script
		scriptingFrame.EditScript (#Plater.db.profile.script_data)
		
		--refresh the script selection scrollbox
		scriptingFrame.ScriptSelectionScrollBox:Refresh()

		GameCooltip:Hide()
		
		--update overlap button
		scriptingFrame.UpdateOverlapButton()
	end
	
	local build_restore_menu = function()
		local data = Plater.db.profile.script_data_trash
		local timeToday = time()
		
		GameCooltip:Preset (2)
		GameCooltip:SetOption ("TextSize", 10)
		GameCooltip:SetOption ("FixedWidth", 200)
		
		if (#data == 0) then
			GameCooltip:SetType ("tooltip")
			GameCooltip:AddLine ("Recycle Bin", "", 1, "yellow", "yellow", 12, nil, "OUTLINE")
			GameCooltip:AddLine ("All deleted scripts are moved to here for 30 days where they can be restored during this period")
		else
			for i = 1, #data do
				local scriptObject = data [i]
				local age = timeToday - scriptObject.__TrashAt

				GameCooltip:AddLine (scriptObject.Name, floor (age/60/60/24) .. " days")
				GameCooltip:AddIcon (scriptObject.Icon  ~= "" and scriptObject.Icon or [[Interface\ICONS\INV_Misc_QuestionMark]], 1, 1, 20, 20)
				GameCooltip:AddMenu (1, restore_from_trashcan, i)
			end
		end
	end

	restore_script_button.CoolTip = {
		Type = "menu",
		BuildFunc = build_restore_menu,
		ShowSpeed = 0.05,
	}
	
	local GameCooltip = GameCooltip2
	GameCooltip:CoolTipInject (restore_script_button)
	
	--import button
	local import_script_button = DF:CreateButton (scriptingFrame, scriptingFrame.ShowImportTextField, 26, buttons_size[2], "", -1, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
	import_script_button:SetPoint ("left", restore_script_button, "right", 2, 0)
	import_script_button:SetIcon ([[Interface\AddOns\Plater\images\icons]], 16, 16, "overlay", {5/512, 19/512, 195/512, 210/512}, {1, .8, .2}, nil, nil, nil, false)
	
	import_script_button:HookScript ("OnEnter", function()
		GameCooltip:Preset (2)
		GameCooltip:SetOption ("TextSize", 10)
		GameCooltip:SetOption ("FixedWidth", 200)
		GameCooltip:SetOwner  (import_script_button.widget)
		
		GameCooltip:AddLine ("Import Script", "", 1, "yellow", "yellow", 12, nil, "OUTLINE")
		GameCooltip:AddLine ("Add a new script from a previous exported string.\n\nYou can export to string by right clicking a script in the menu below.")
		
		GameCooltip:Show()
	end)	
	import_script_button:HookScript ("OnLeave", function()
		GameCooltip:Hide()
	end)
	
	--help button
	local help_script_button = DF:CreateButton (scriptingFrame, function() scriptingFrame.HelpFrame:Show() end, 26, buttons_size[2], "", -1, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
	help_script_button:SetPoint ("left", import_script_button, "right", 2, 0)
	help_script_button:SetIcon ([[Interface\GossipFrame\ActiveQuestIcon]], 18, 18, "overlay", {0, 1, 0, 1}, nil, 0, -1, nil, false)

	function Plater.SortScripts (t1, t2)
		--> index 4 stores if the script is enabled
		if (t1[4] > t2[4]) then
			return true
		elseif (t1[4] < t2[4]) then
			return false
		else
			--> index 3 stores the script name
			return t1[3] < t2[3]
		end
	end	
	
	--refresh the list of scripts already created
	local refresh_script_scrollbox = function (self, data, offset, total_lines)
		--alphabetical order
		local dataInOrder = {}
		
		if (scriptingFrame.SearchString ~= "") then
			for i = 1, #data do
				if (data [i].Name:lower():find (scriptingFrame.SearchString)) then
					dataInOrder [#dataInOrder+1] = {i, data [i], data[i].Name, data[i].Enabled and 1 or 0}
				end
			end
		else
			for i = 1, #data do
				dataInOrder [#dataInOrder+1] = {i, data [i], data[i].Name, data[i].Enabled and 1 or 0}
			end
		end

		table.sort (dataInOrder, Plater.SortScripts)
		
		local currentScript = scriptingFrame.GetCurrentScriptObject()
		
		--update the scroll
		for i = 1, total_lines do
			local index = i + offset
			local t = dataInOrder [index]
			if (t) then
				--get the data
				local scriptId = t [1]
				local data = t [2]
				--update the line
				local line = self:GetLine (i)
				line:UpdateLine (scriptId, data)
				
				if (data == currentScript) then
					line:SetBackdropColor (unpack (scrollbox_line_backdrop_color_selected))
				else
					line:SetBackdropColor (unpack (scrollbox_line_backdrop_color))
				end
			end
		end
		
		--update overlap button
		scriptingFrame.UpdateOverlapButton()
	end
	
	local onclick_menu_scroll_line = function (self, scriptId, option, ...)
		if (option == "editscript") then
			scriptingFrame.EditScript (scriptId)
			
		elseif (option == "remove") then
			scriptingFrame.RemoveScript (scriptId)
			
		elseif (option == "duplicate") then
			scriptingFrame.DuplicateScript (scriptId)
			
		elseif (option == "export") then
			scriptingFrame.ExportScript (scriptId)
		
		elseif (option == "sendtogroup") then
			if (not IsInGroup()) then
				Plater:Msg ("You need to be in a group to use this export option.")
				return
			end
			
			Plater.ExportScriptToGroup (scriptId)
		end
		
		GameCooltip:Hide()
	end
	
	--when the user clicks on a scrollbox line
	local onclick_scroll_line = function (self, button)
	
		if (button == "LeftButton") then
			local currentScriptObject = scriptingFrame.GetCurrentScriptObject()
			--check if isn't the same script
			local scriptToBeEdited = scriptingFrame.GetScriptObject (self.ScriptId)
			if (scriptToBeEdited == currentScriptObject) then
				--no need to load the new script if is the same
				return
			end
			
			--save the current script if any
			if (currentScriptObject) then
				scriptingFrame.SaveScript()
			end
			
			--select the script to start edit
			scriptingFrame.EditScript (self.ScriptId)
			--refresh the script list to update the backdrop color of the selected script
			scriptingFrame.ScriptSelectionScrollBox:Refresh()
			
			--check if the import/export text field is shown and hide it
			if (scriptingFrame.ImportTextEditor:IsShown()) then
				scriptingFrame.ImportTextEditor:Hide()
			end
			
		elseif (button == "RightButton") then
			--open menu
			GameCooltip:Preset (2)
			GameCooltip:SetType ("menu")
			GameCooltip:SetOption ("TextSize", 10)
			GameCooltip:SetOption ("FixedWidth", 200)
			GameCooltip:SetOption ("ButtonsYModSub", -1)
			GameCooltip:SetOption ("YSpacingModSub", -4)
			GameCooltip:SetOwner (self, "topleft", "topright", 2, 0)
			GameCooltip:SetFixedParameter (self.ScriptId)

			GameCooltip:AddLine ("Edit Script")
			GameCooltip:AddMenu (1, onclick_menu_scroll_line, "editscript")
			GameCooltip:AddIcon ([[Interface\BUTTONS\UI-GuildButton-PublicNote-Up]], 1, 1, 16, 16)
			
			GameCooltip:AddLine ("Duplicate")
			GameCooltip:AddMenu (1, onclick_menu_scroll_line, "duplicate")
			GameCooltip:AddIcon ([[Interface\AddOns\Plater\images\icons]], 1, 1, 16, 16, 3/512, 21/512, 215/512, 233/512)

			GameCooltip:AddLine ("Export")
			GameCooltip:AddIcon ([[Interface\BUTTONS\UI-GuildButton-MOTD-Up]], 1, 1, 16, 16, 1, 0, 0, 1)
			
			GameCooltip:AddLine ("As a Text String", "", 2)
			GameCooltip:AddIcon ([[Interface\BUTTONS\UI-GuildButton-MOTD-Up]], 2, 1, 16, 16, 1, 0, 0, 1)
			GameCooltip:AddMenu (2, onclick_menu_scroll_line, "export")

			GameCooltip:AddLine ("Send to Your Party/Raid", "", 2)
			GameCooltip:AddIcon ([[Interface\BUTTONS\UI-GuildButton-MOTD-Up]], 2, 1, 16, 16, 1, 0, 0, 1)
			GameCooltip:AddMenu (2, onclick_menu_scroll_line, "sendtogroup")
			
			--[=[
			GameCooltip:AddLine ("Export (As String)")
			GameCooltip:AddMenu (1, onclick_menu_scroll_line, "export")
			GameCooltip:AddIcon ([[Interface\BUTTONS\UI-GuildButton-MOTD-Up]], 1, 1, 16, 16, 1, 0, 0, 1)

			GameCooltip:AddLine ("Export (Send to Group)")
			GameCooltip:AddLine ("Export (Send to Group)", "", 2)
			GameCooltip:AddMenu (1, onclick_menu_scroll_line, "sendtogroup")
			GameCooltip:AddIcon ([[Interface\BUTTONS\UI-GuildButton-MOTD-Up]], 1, 1, 16, 16, 1, 0, 0, 1)
			--]=]
			
			GameCooltip:AddLine ("Remove")
			GameCooltip:AddMenu (1, onclick_menu_scroll_line, "remove")
			GameCooltip:AddIcon ([[Interface\AddOns\Plater\images\icons]], 1, 1, 16, 16, 3/512, 21/512, 235/512, 257/512)
			
			GameCooltip:Show()
		end
	end
	
	--when the user hover over a scrollbox line
	local onenter_scroll_line = function (self)
		self:SetBackdropColor (.3, .3, .3, .6)
	end
	
	--when the user leaves a scrollbox line from a hover over
	local onleave_scroll_line = function (self)
		local currentScript = scriptingFrame.GetCurrentScriptObject()
		
		--check if the hover overed button is the current script being edited
		if (currentScript == self.Data) then
			self:SetBackdropColor (unpack (scrollbox_line_backdrop_color_selected))
		else
			self:SetBackdropColor (unpack (scrollbox_line_backdrop_color))
		end
	end
	
	local update_line = function (self, script_id, data)
		local icon_texture, script_name, script_type = data.Icon, data.Name, data.ScriptType
		
		self.ScriptId = script_id
		self.Data = data
		self.Icon:SetTexture (icon_texture)
		self.Icon:SetTexCoord (.1, .9, .1, .9)
		self.ScriptName:SetText (script_name)
		
		local scriptTypeName = scriptingFrame.GetScriptTriggerTypeName (script_type)
		self.ScriptType:SetText (scriptTypeName)
		
		self.EnabledCheckbox:SetValue (data.Enabled)
		self.EnabledCheckbox:SetFixedParameter (script_id)
	end
	
	local onclick_remove_script = function (self)
		local parent = self:GetParent()
		local scriptId = parent.ScriptId
		scriptingFrame.RemoveScript (scriptId)
	end
	
	local cooltip_scriptsscrollbox = function (self, fixed_parameter)

		GameCooltip:Preset (2)
		GameCooltip:SetOption ("TextSize", 10)
		GameCooltip:SetOption ("FixedWidth", 200)
		
		local scriptObject = scriptingFrame.GetScriptObject (self.ScriptId)
		local lastEdited = date ("%d/%m/%Y", scriptObject.Time)
		
		GameCooltip:AddLine (scriptObject.Name, nil, 1, "yellow", "yellow", 11, "Friz Quadrata TT", "OUTLINE")
		if (scriptObject.Icon ~= "") then
			GameCooltip:AddIcon (scriptObject.Icon)
		end

		GameCooltip:AddLine ("Last Edited:", lastEdited)
		local scriptTypeName = scriptingFrame.GetScriptTriggerTypeName (scriptObject.ScriptType)
		GameCooltip:AddLine ("Trigger Type:", scriptTypeName)
		GameCooltip:AddLine ("Author:", scriptObject.Author or "--x--x--")
		if (scriptObject.Desc and scriptObject.Desc ~= "") then
			GameCooltip:AddLine (scriptObject.Desc, "", 1, "gray")
		end
		
	end
	
	local cooltip_inject_table_scriptsscrollbox = {
		Type = "tooltip",
		BuildFunc = cooltip_scriptsscrollbox,
		ShowSpeed = 0.016,
		MyAnchor = "topleft",
		HisAnchor = "topright",
		X = 10,
		Y = 0,
	}
	
	local toggle_script_enabled = function (self, scriptId, value)
		local scriptObject = Plater.GetScriptObject (scriptId)
		if (scriptObject) then
			scriptObject.Enabled = value
			if (not value) then
				scriptingFrame.KillRunningScriptsForObject (scriptObject)
				Plater.WipeAndRecompileAllScripts()
			else
				Plater.CompileScript (scriptObject)
			end
		end
		
		scriptingFrame.UpdateOverlapButton()
		scriptingFrame.ScriptSelectionScrollBox:Refresh()
	end
	
	--create a line in the scroll box
	local create_line_scrollbox = function (self, index)
		--create a new line
		local line = CreateFrame ("button", "$parentLine" .. index, self)
		--set its parameters
		line:SetPoint ("topleft", self, "topleft", 1, -((index-1) * (scrollbox_line_height+1)) - 1)
		line:SetSize (scrollbox_size[1]-2, scrollbox_line_height)
		line:SetScript ("OnEnter", onenter_scroll_line)
		line:SetScript ("OnLeave", onleave_scroll_line)
		line:SetScript ("OnClick", onclick_scroll_line)
		line:RegisterForClicks ("LeftButtonDown", "RightButtonDown")
		
		line.CoolTip = cooltip_inject_table_scriptsscrollbox
		GameCooltip:CoolTipInject (line)
		
		line:SetBackdrop ({bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true, edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1})
		line:SetBackdropColor (unpack (scrollbox_line_backdrop_color))
		line:SetBackdropBorderColor (0, 0, 0, 1)
		
		local icon = line:CreateTexture ("$parentIcon", "overlay")
		icon:SetSize (scrollbox_line_height-4, scrollbox_line_height-4)
		
		local script_name = DF:CreateLabel (line, "", DF:GetTemplate ("font", "PLATER_SCRIPTS_NAME"))
		--script_name.color = "white"
		local script_type = DF:CreateLabel (line, "", DF:GetTemplate ("font", "PLATER_SCRIPTS_TYPE"))
		
		local remove_button = CreateFrame ("button", "$parentRemoveButton", line, "UIPanelCloseButton")
		remove_button:SetSize (16, 16)
		remove_button:SetScript ("OnClick", onclick_remove_script)
		remove_button:SetPoint ("topright", line, "topright")
		remove_button:GetNormalTexture():SetDesaturated (true)
		remove_button:SetAlpha (.4)
		
		--hide the remove button
		remove_button:Hide()
		
		--create the enabled box
		--the with_label value with passing an empty string "" making the switch create a label and anchor the checkbox to it
		--after that it anchor the checkbox again here making the checkbox to be anchor to two different widgets making it not move while its parent moves
		local enabled_checkbox = DF:CreateSwitch (line, toggle_script_enabled, true, _, _, _, _, "enabledCheckbox", "$parentScriptToggle" .. index, _, _, _, nil, DF:GetTemplate ("switch", "OPTIONS_CHECKBOX_BRIGHT_TEMPLATE"))
		enabled_checkbox:SetAsCheckBox()
		
		--setup anchors
		icon:SetPoint ("left", line, "left", 2, 0)
		script_name:SetPoint ("topleft", icon, "topright", 2, -2)
		script_type:SetPoint ("topleft", script_name, "bottomleft", 0, 0)
		enabled_checkbox:SetPoint ("right", line, "right", -2, 0)
		
		line.Icon = icon
		line.ScriptName = script_name
		line.ScriptType = script_type
		line.EnabledCheckbox = enabled_checkbox
		
		line.UpdateLine = update_line

		return line
	end
	
	--scroll panel to select which script to edit
		local script_scrollbox_label = DF:CreateLabel (scriptingFrame, "Scripts", DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"))
		local enabled_scrollbox_label = DF:CreateLabel (scriptingFrame, "Enabled", DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"))
		local script_scroll_box = DF:CreateScrollBox (scriptingFrame, "$parentScrollBox", refresh_script_scrollbox, Plater.db.profile.script_data, scrollbox_size[1], scrollbox_size[2], scrollbox_lines, scrollbox_line_height)
		DF:ReskinSlider (script_scroll_box)

		scriptingFrame.ScriptSelectionScrollBox = script_scroll_box

		--create the scrollbox lines
		for i = 1, scrollbox_lines do 
			script_scroll_box:CreateLine (create_line_scrollbox)
		end
		
	--script search box
		function scriptingFrame.OnSearchBoxTextChanged()
			local text = scriptingFrame.ScriptSearchTextEntry:GetText()
			scriptingFrame.SearchString = text:lower()
			script_scroll_box:Refresh()
		end
	
		local script_search_textentry = DF:CreateTextEntry (scriptingFrame, function()end, 200, 20, "ScriptSearchTextEntry", _, _, options_dropdown_template)
		script_search_textentry:SetPoint ("topleft", create_new_script_button, "bottomleft", 0, -20)
		script_search_textentry:SetHook ("OnChar", scriptingFrame.OnSearchBoxTextChanged)
		script_search_textentry:SetHook ("OnTextChanged", scriptingFrame.OnSearchBoxTextChanged)
		script_search_label = DF:CreateLabel (scriptingFrame, "Search:", DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"))
		script_search_label:SetPoint ("bottomleft", script_search_textentry, "topleft", 0, 2)

	--when the profile has changed
	function scriptingFrame:RefreshOptions()
		--update the script data for the scroll and refresh
		script_scroll_box:SetData (Plater.db.profile.script_data)
		script_scroll_box:Refresh()
		
	end
	
	--anchors
		--scroll to select which script to edit
		--script_scrollbox_label:SetPoint ("topleft", create_new_script_button.widget, "bottomleft", 0, -12)
		
		script_scroll_box:SetPoint ("topleft", script_search_textentry.widget, "bottomleft", 0, -20)
		
		script_scrollbox_label:SetPoint ("bottomleft", script_scroll_box, "topleft", 0, 2)
		enabled_scrollbox_label:SetPoint ("bottomright", script_scroll_box, "topright", 0, 2)
	
		--create frame holding the script options
		edit_script_frame:SetPoint ("topleft", scriptingFrame, "topleft", scrollbox_size[1] + 30, start_y)
		
		--script options
		script_name_label:SetPoint ("topleft", edit_script_frame, "topleft", 10, 2)
		script_icon_label:SetPoint ("topleft", edit_script_frame, "topleft", 170, 0)
		script_desc_label:SetPoint ("topleft", edit_script_frame, "topleft", 10, -40)
		
		script_type_label:SetPoint ("topleft", edit_script_frame, "topleft", 10, -80)
		
		add_trigger_label:SetPoint ("topleft", edit_script_frame, "topleft", 10, -120)
		trigger_scrollbox_label:SetPoint ("topleft", edit_script_frame, "topleft", 10, -160)
		
		--lua code editor
		code_editor:SetPoint ("topleft", edit_script_frame, "topleft", 230, -20)
		--import editor
		import_text_editor:SetPoint ("topleft", edit_script_frame, "topleft", 230, -20)
		
		--script control buttons
		apply_script_button:SetPoint ("topright", code_editor, "bottomright", 0, -10)
		save_script_button:SetPoint ("right", apply_script_button, "left", -20, 0)
		cancel_script_button:SetPoint ("right", save_script_button, "left", -20, 0)
		
		--import control buttons
		okay_import_button:SetPoint ("topright", code_editor, "bottomright", 0, -10)
		cancel_import_button:SetPoint ("right", apply_script_button, "left", -20, 0)
		
		--code type
		code_type_label:SetPoint ("topleft", code_editor, "bottomleft", 0, -15)
	
	
	scriptingFrame.EditScriptFrame:LockFrame()
	scriptingFrame.EditScriptFrame:Show()
	
	
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> ~auto ~ï¿½uto

	--autoFrame
		
	local auto_options = {
		{type = "label", get = function() return "Auto Toggle Friendly Nameplates:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		
		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_toggle_friendly_enabled end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.auto_toggle_friendly_enabled = value
				
				Plater.RefreshDBUpvalues()
				Plater.UpdateAllPlates()
				Plater.RefreshAutoToggle()
			end,
			name = "Enabled",
			desc = "When enabled, Plater will enable or disable friendly plates based on the settings below.",
		},
		
		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_toggle_friendly ["party"] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.auto_toggle_friendly ["party"] = value
				Plater.RefreshAutoToggle()
			end,
			name = "In Dungeons",
			desc = "Show friendly nameplates when inside dungeons.",
		},	
		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_toggle_friendly ["raid"] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.auto_toggle_friendly ["raid"] = value
				Plater.RefreshAutoToggle()
			end,
			name = "In Raid",
			desc = "Show friendly nameplates when inside raids.",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_toggle_friendly ["arena"] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.auto_toggle_friendly ["arena"] = value
				Plater.RefreshAutoToggle()
			end,
			name = "In Arena",
			desc = "Show friendly nameplates when inside arena.",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_toggle_friendly ["cities"] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.auto_toggle_friendly ["cities"] = value
				Plater.RefreshAutoToggle()
			end,
			name = "In Major Cities",
			desc = "Show friendly nameplates when inside a major city.",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_toggle_friendly ["world"] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.auto_toggle_friendly ["world"] = value
				Plater.RefreshAutoToggle()
			end,
			name = "In Open World",
			desc = "Show friendly nameplates when at any place not listed on the other options.",
		},
		
		{type = "blank"},
		
		{type = "label", get = function() return "Auto Toggle Stacking Nameplates:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		
		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_toggle_stacking_enabled end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.auto_toggle_stacking_enabled = value
				
				Plater.RefreshDBUpvalues()
				Plater.UpdateAllPlates()
				Plater.RefreshAutoToggle()
			end,
			name = "Enabled",
			desc = "When enabled, Plater will enable or disable stacking nameplates based on the settings below.\n\n|cFFFFFF00Important|r: only toggle on if 'Stacking Nameplates' is enabled in the General Settings tab.",
		},
		
		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_toggle_stacking ["party"] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.auto_toggle_stacking ["party"] = value
				Plater.RefreshAutoToggle()
			end,
			name = "In Dungeons",
			desc = "Set stacking on when inside dungeons.",
		},	
		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_toggle_stacking ["raid"] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.auto_toggle_stacking ["raid"] = value
				Plater.RefreshAutoToggle()
			end,
			name = "In Raid",
			desc = "Set stacking on when inside raids.",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_toggle_stacking ["arena"] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.auto_toggle_stacking ["arena"] = value
				Plater.RefreshAutoToggle()
			end,
			name = "In Arena",
			desc = "Set stacking on when inside arena.",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_toggle_stacking ["cities"] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.auto_toggle_stacking ["cities"] = value
				Plater.RefreshAutoToggle()
			end,
			name = "In Major Cities",
			desc = "Set stacking on when inside a major city.",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_toggle_stacking ["world"] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.auto_toggle_stacking ["world"] = value
				Plater.RefreshAutoToggle()
			end,
			name = "In Open World",
			desc = "Set stacking on when at any place not listed on the other options.",
		},
		
	}
	
	DF:BuildMenu (autoFrame, auto_options, startX, startY, heightSize, true, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template, globalCallback)	
	
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> ~threat ï¿½ggro ~aggro
	

	local thread_options = {
		{type = "label", get = function() return "Plate Color by Aggro:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.tank.colors.aggro
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.tank.colors.aggro
				color[1], color[2], color[3], color[4] = r, g, b, a
			end,
			name = "[tank] Aggro on You",
			desc = "When you are tanking with solid aggro.",
		},
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.tank.colors.anothertank
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.tank.colors.anothertank
				color[1], color[2], color[3], color[4] = r, g, b, a
			end,
			name = "[tank] Aggro on Another Tank",
			desc = "The enemy is being tanked by another tank in the raid.",
		},
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.tank.colors.pulling
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.tank.colors.pulling
				color[1], color[2], color[3], color[4] = r, g, b, a
			end,
			name = "[tank] Aggro on You Warning",
			desc = "When you are tanking but others are close to pull the aggro from you.",
		},
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.tank.colors.noaggro
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.tank.colors.noaggro
				color[1], color[2], color[3], color[4] = r, g, b, a
			end,
			name = "[tank] No Aggro",
			desc = "The enemy is attacking a player that isn't a tank!.",
		},
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.tank.colors.nocombat
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.tank.colors.nocombat
				color[1], color[2], color[3], color[4] = r, g, b, a
			end,
			name = "[tank] Not in Combat",
			desc = "When you are in combat and the enemy isn't in combat with you or with a member of your group.",
		},
			
		{type = "blank"},
--		{type = "label", get = function() return "Plate Color As a Dps:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.dps.colors.aggro
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.dps.colors.aggro
				color[1], color[2], color[3], color[4] = r, g, b, a
			end,
			name = "[dps] Aggro",
			desc = "The name plate is painted with this color when you are a Dps (or healer) and have aggro.",
		},
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.dps.colors.noaggro
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.dps.colors.noaggro
				color[1], color[2], color[3], color[4] = r, g, b, a
			end,
			name = "[dps] No Aggro",
			desc = "When you are a dps (or healer) and the mob isn't attacking you.",
		},
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.dps.colors.pulling
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.dps.colors.pulling
				color[1], color[2], color[3], color[4] = r, g, b, a
			end,
			name = "[dps] High Threat",
			desc = "When you are neat to pull the aggro.",
		},
		
		{type = "blank"},
		
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.tap_denied_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.tap_denied_color
				color[1], color[2], color[3], color[4] = r, g, b, a
			end,
			name = "Unit Tapped",
			desc = "When someone else has claimed the unit (when you don't receive experience or loot for killing it).",
		},
		
		{type = "blank"},
		{type = "label", get = function() return "Aggro Modifies:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
	
		{
			type = "toggle",
			get = function() return Plater.db.profile.aggro_modifies.health_bar_color end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.aggro_modifies.health_bar_color = value
				Plater.RefreshDBUpvalues()
				Plater.UpdateAllPlates()
				if (not value) then
					for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
						CompactUnitFrame_UpdateHealthColor (plateFrame.UnitFrame)
					end
				end
			end,
			name = "Health Bar Color",
			desc = "Health Bar Color",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.aggro_modifies.border_color end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.aggro_modifies.border_color = value
				Plater.RefreshDBUpvalues()
				Plater.UpdateAllPlates()
			end,
			name = "Border Color",
			desc = "Border Color",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.aggro_modifies.actor_name_color end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.aggro_modifies.actor_name_color = value
				Plater.RefreshDBUpvalues()
				Plater.UpdateAllPlates()
			end,
			name = "Name Color",
			desc = "Name Color",
		},
			
	}
	
	DF:BuildMenu (threatFrame, thread_options, startX, startY, heightSize, true, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template, globalCallback)
	
	
	
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> ~advanced ï¿½dvanced
	

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
			desc = "Time interval between each update in the nameplate.",
		},
		
		{type = "blank"},
		{type = "label", get = function() return "Animation Settings:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},

		{
			type = "toggle",
			get = function() return Plater.db.profile.spell_animations end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.spell_animations = value
				Plater.RefreshDBUpvalues()
			end,
			name = "Nameplate Shake (Spell Reaction)",
			desc = "If enabled some of your abilities will cause the nameplate to shake or play a special effect when the ability hits the enemy.",
		},
		{
			type = "range",
			get = function() return Plater.db.profile.spell_animations_scale end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.spell_animations_scale = value
			end,
			min = 0.75,
			max = 2.75,
			step = 0.1,
			name = "Nameplate Shake Intensity",
			desc = "Nameplate Shake Intensity.",
			thumbscale = 1.8,
			usedecimals = true,
		},
		
		{type = "blank"},
		
		{
			type = "toggle",
			get = function() return Plater.db.profile.use_color_lerp end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.use_color_lerp = value
				Plater.RefreshDBUpvalues()
				Plater.UpdateAllPlates()
			end,
			name = "Use Smooth Color Transition",
			desc = "Color changes does a smooth transition between the old and the new color.",
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
			name = "Smooth Color Transition Speed",
			desc = "How fast it transition between colors.",
		},
		
		{type = "blank"},
		
		{
			type = "toggle",
			get = function() return Plater.db.profile.height_animation end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.height_animation = value
				Plater.RefreshDBUpvalues()
				Plater.UpdateAllPlates()
			end,
			name = "Use Smooth Height Transition",
			desc = "Do a smooth animation when the nameplate's height changes.",
		},
		{
			type = "range",
			get = function() return Plater.db.profile.height_animation_speed end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.height_animation_speed = value
				Plater.RefreshDBUpvalues()
			end,
			min = 1,
			max = 50,
			step = 1,
			name = "Smooth Height Transition Speed",
			desc = "How fast is the transition animation.",
		},
		
		{type = "blank"},
		
		{
			type = "toggle",
			get = function() return Plater.db.profile.use_health_animation end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.use_health_animation = value
				Plater.RefreshDBUpvalues()
				Plater.UpdateAllPlates()
			end,
			name = "Use Smooth Health Transition",
			desc = "Do a smooth animation when the nameplate's health value changes.",
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
			name = "Smooth Health Transition Speed",
			desc = "How fast is the transition animation.",
		},
		
		{type = "blank"},
		
		{type = "label", get = function() return "Advanced Nameplate:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "range",
			get = function() return tonumber (GetCVar (CVAR_CEILING)) end,
			set = function (self, fixedparam, value) 
				if (not InCombatLockdown()) then
					if (value == 0) then
						SetCVar (CVAR_CEILING, -1)
					else
						SetCVar (CVAR_CEILING, value)
					end
				else
					Plater:Msg ("you are in combat.")
				end
			end,
			min = 0.000,
			max = 0.1,
			step = 0.005,
			thumbscale = 1.7,
			usedecimals = true,
			name = "Screen Padding (Top Side)" .. CVarIcon,
			desc = "Min space between the nameplate and the top of the screen. Increase this if some part of the nameplate are going out of the screen.\n\n|cFFFFFFFFDefault: 0.065|r\n\n|cFFFFFF00Important|r: setting to 0 disables this feature." .. CVarDesc,
			nocombat = true,
		},
		{
			type = "select",
			get = function() return tonumber (GetCVar (CVAR_ANCHOR)) end,
			values = function() return nameplate_anchor_options end,
			name = "Anchor Point" .. CVarIcon,
			desc = "Where the nameplate is anchored to.\n\n|cFFFFFFFFDefault: Head|r" .. CVarDesc,
			nocombat = true,
		},
		{
			type = "range",
			get = function() return tonumber (GetCVar (CVAR_MOVEMENT_SPEED)) end,
			set = function (self, fixedparam, value) 
				if (not InCombatLockdown()) then
					SetCVar (CVAR_MOVEMENT_SPEED, value)
				else
					Plater:Msg ("you are in combat.")
				end
			end,
			min = 0.02,
			max = 0.2,
			step = 0.005,
			thumbscale = 1.7,
			usedecimals = true,
			name = "Movement Speed" .. CVarIcon,
			desc = "How fast the nameplate moves (when stacking is enabled).\n\n|cFFFFFFFFDefault: 0.025|r\n\n|cFFFFFFFFRecommended: 0.05|r" .. CVarDesc,
			nocombat = true,
		},
		{
			type = "range",
			get = function() return tonumber (GetCVar ("nameplateOverlapV")) end,
			set = function (self, fixedparam, value) 
				if (not InCombatLockdown()) then
					SetCVar ("nameplateOverlapV", value)
				else
					Plater:Msg ("you are in combat.")
				end
			end,
			min = 0.2,
			max = 1.6,
			step = 0.05,
			thumbscale = 1.7,
			usedecimals = true,
			name = "Nameplate Vertical Padding" .. CVarIcon,
			desc = "Min distance between each nameplate (when stacking is enabled).\n\n|cFFFFFFFFDefault: 1.10|r" .. CVarDesc .. "\n\n|cFFFFFF00Important|r: if you find issues with this setting, use:\n|cFFFFFFFF/run SetCVar ('nameplateOverlapV', '1.6')|r",
			nocombat = true,
		},
		{
			type = "range",
			get = function() return tonumber (GetCVar ("nameplateMinScale")) end,
			set = function (self, fixedparam, value) 
				if (not InCombatLockdown()) then
					SetCVar ("nameplateMinScale", value)
				else
					Plater:Msg ("you are in combat.")
				end
			end,
			min = 0.3,
			max = 2,
			step = 0.1,
			thumbscale = 1.7,
			usedecimals = true,
			name = "Distance Scale" .. CVarIcon,
			desc = "Scale applied when the nameplate is far away from the camera.\n\n|cFFFFFF00Important|r: is the distance from the camera and |cFFFF4444not|r the distance from your character.\n\n|cFFFFFFFFDefault: 0.8|r" .. CVarDesc,
			nocombat = true,
		},
		{
			type = "range",
			get = function() return tonumber (GetCVar ("nameplateGlobalScale")) end,
			set = function (self, fixedparam, value) 
				if (not InCombatLockdown()) then
					SetCVar ("nameplateGlobalScale", value)
				else
					Plater:Msg ("you are in combat.")
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
		
		{type = "breakline"},
	
		{type = "label", get = function() return "Enemy Box Selection Space:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "range",
			get = function() return Plater.db.profile.click_space[1] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.click_space[1] = value
				Plater.UpdatePlateClickSpace (nil, true)
			end,
			min = 50,
			max = 300,
			step = 1,
			name = "Width",
			nocombat = true,
			desc = "How large are area which accepts mouse clicks to select the target",
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
			name = "Height",
			nocombat = true,
			desc = "The height of the are area which accepts mouse clicks to select the target",
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
			min = 50,
			max = 300,
			step = 1,
			name = "Width",
			nocombat = true,
			desc = "How large are area which accepts mouse clicks to select the target",
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
			name = "Height",
			nocombat = true,
			desc = "The height of the are area which accepts mouse clicks to select the target",
		},		
		
		{type = "blank"},
		
		{
			type = "toggle",
			get = function() return Plater.db.profile.click_space_always_show end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.click_space_always_show = value
				Plater.UpdateAllPlates()
			end,
			nocombat = true,
			name = "Always Show Background",
			desc = "Enable a background showing the area of the clicable area.",
		},
		
		{type = "blank"},
		
		{type = "label", get = function() return "Color Overriding:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		
		{
			type = "toggle",
			get = function() return Plater.db.profile.color_override end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.color_override = value
				Plater.RefreshColorOverride()
			end,
			name = "Override Default Colors",
			desc = "Override Default Colors",
		},
		
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.color_override_colors [UNITREACTION_HOSTILE]
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.color_override_colors [UNITREACTION_HOSTILE]
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllNameplateColors()
			end,
			name = "Hostile",
			desc = "Hostile",
		},
		
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.color_override_colors [UNITREACTION_NEUTRAL]
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.color_override_colors [UNITREACTION_NEUTRAL]
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllNameplateColors()
			end,
			name = "Neutral",
			desc = "Neutral",
		},
		
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.color_override_colors [UNITREACTION_FRIENDLY]
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.color_override_colors [UNITREACTION_FRIENDLY]
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllNameplateColors()
			end,
			name = "Friendly",
			desc = "Friendly",
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
			name = "Pet Width Scale",
			desc = "Slightly adjust the size of nameplates when showing a pet",
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
			name = "Pet Height Scale",
			desc = "Slightly adjust the size of nameplates when showing a pet",
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
			name = "Minor Unit Width Scale",
			desc = "Slightly adjust the size of nameplates when showing a minor unit (these units has a smaller nameplate by default).",
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
			name = "Minor Unit Height Scale",
			desc = "Slightly adjust the size of nameplates when showing a minor unit (these units has a smaller nameplate by default).",
			usedecimals = true,
		},
		
		{type = "breakline"},
		{type = "label", get = function() return "Misc:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		
		--[=
		{
			type = "toggle",
			get = function() return Plater.db.profile.hide_enemy_castbars end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.hide_enemy_castbars = value
				Plater.UpdateUseCastBar()
			end,
			name = "Hide Enemy Cast Bar",
			desc = "Hide Enemy Cast Bar",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.hide_friendly_castbars end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.hide_friendly_castbars = value
				Plater.UpdateUseCastBar()
			end,
			name = "Hide Friendly Cast Bar",
			desc = "Hide Friendly Cast Bar",
		},
		--]=]
		
		--[=
		--{type = "label", get = function() return "Border Settings:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.border_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.border_color
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.RefreshDBUpvalues()
				Plater.UpdatePlateBorders()
			end,
			name = "Border Color",
			desc = "Color of the plate border.",
		},
		{
			type = "range",
			get = function() return Plater.db.profile.border_thickness end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.border_thickness = value
				Plater.RefreshDBUpvalues()
				Plater.UpdatePlateBorderThickness()
			end,
			min = 1,
			max = 3,
			step = 1,
			name = "Border Thickness",
			desc = "How thick the border should be.",
		},
		
		{
			type = "range",
			get = function() return Plater.db.profile.healthbar_framelevel end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.healthbar_framelevel = value
				Plater.RefreshDBUpvalues()
				Plater.UpdateAllPlates()
			end,
			min = -5,
			max = 75,
			step = 1,
			name = "HealthBar Frame Level",
			desc = "Add this to the default frame level of the healthbar",
		},
		{
			type = "range",
			get = function() return Plater.db.profile.castbar_framelevel end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.castbar_framelevel = value
				Plater.RefreshDBUpvalues()
				Plater.UpdateAllPlates()
			end,
			min = -5,
			max = 75,
			step = 1,
			name = "CastBar Frame Level",
			desc = "Add this to the default frame level of the castbar",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.health_cutoff_extra_glow end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.health_cutoff_extra_glow = value
				Plater.UpdateAllPlates()
			end,
			name = "Add Extra Glow to Execute Range",
			desc = "Add Extra Glow to Execute Range",
		},
		
		
		--]=]		
	}
	
	DF:BuildMenu (advancedFrame, advanced_options, startX, startY, heightSize, true, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template, globalCallback)
		
	--
	Plater.CheckOptionsTab()
end

--update class color
function Plater.UpdateUnitColor (self, unit)
	
end


	--[[
		{
			type = "toggle",
			get = function() return Plater.CanShowPlateFor (ACTORTYPE_FRIENDLY_PLAYER) end,
			set = function (self, fixedparam, value) 
				Plater.SetShowActorType (ACTORTYPE_FRIENDLY_PLAYER, value)
				Plater.UpdateAllPlates()
			end,
			name = "Friendly Players",
			desc = "Show nameplate for friendly players.\n\n|cFFFFFF00Important|r: This option is dependent on the client`s nameplate state (on/off).\n\n|cFFFFFF00Important|r: when disabled but enabled on the client through (" .. (GetBindingKey ("FRIENDNAMEPLATES") or "") .. ") the healthbar isn't visible but the nameplate is still clickable.",
		},
		{
			type = "toggle",
			get = function() return Plater.CanShowPlateFor (ACTORTYPE_ENEMY_PLAYER) end,
			set = function (self, fixedparam, value) 
				Plater.SetShowActorType (ACTORTYPE_ENEMY_PLAYER, value)
				Plater.UpdateAllPlates()
			end,
			name = "Enemy Players",
			desc = "Show nameplate for enemy players.\n\n|cFFFFFF00Important|r: This option is dependent on the client`s nameplate state (on/off).\n\n|cFFFFFF00Important|r: when disabled but enabled on the client through (" .. (GetBindingKey ("NAMEPLATES") or "") .. ") the healthbar isn't visible but the nameplate is still clickable.",
		},
	--]]
	--[[
		{
			type = "toggle",
			get = function() return Plater.CanShowPlateFor (ACTORTYPE_ENEMY_NPC) end,
			set = function (self, fixedparam, value) 
				Plater.SetShowActorType (ACTORTYPE_ENEMY_NPC, value)
				Plater.UpdateAllPlates()
			end,
			name = "Enemy Npc",
			desc = "Show nameplate for enemy npcs.\n\n|cFFFFFF00Important|r: This option is dependent on the client`s nameplate state (on/off).\n\n|cFFFFFF00Important|r: when disabled but enabled on the client through (" .. (GetBindingKey ("NAMEPLATES") or "") .. ") the healthbar isn't visible but the nameplate is still clickable.",
		},
--]]		

--functiona
