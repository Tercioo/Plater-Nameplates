local addonName, platerInternal = ...

--details! framework
local DF = _G ["DetailsFramework"]
if (not DF) then
	print ("|cFFFFAA00Plater: framework not found, if you just installed or updated the addon, please restart your client.|r")
	return
end

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
LibSharedMedia:Register ("statusbar", "PlaterChess", [[Interface\AddOns\Plater\images\overlay_indicator_2]])
LibSharedMedia:Register ("statusbar", "PlaterHealth", [[Interface\AddOns\Plater\images\nameplate_health_texture]])
LibSharedMedia:Register ("statusbar", "testbar", [[Interface\AddOns\Plater\images\testbar.tga]])
LibSharedMedia:Register ("statusbar", "You Are Beautiful!", [[Interface\AddOns\Plater\images\regular_white]])
LibSharedMedia:Register ("statusbar", "PlaterBackground 2", [[Interface\AddOns\Plater\images\noise_background]])

LibSharedMedia:Register ("font", "Oswald", [[Interface\Addons\Plater\fonts\Oswald-Regular.ttf]])
LibSharedMedia:Register ("font", "Nueva Std Cond", [[Interface\Addons\Plater\fonts\Nueva Std Cond.ttf]])
LibSharedMedia:Register ("font", "Accidental Presidency", [[Interface\Addons\Plater\fonts\Accidental Presidency.ttf]])
LibSharedMedia:Register ("font", "TrashHand", [[Interface\Addons\Plater\fonts\TrashHand.TTF]])
LibSharedMedia:Register ("font", "Harry P", [[Interface\Addons\Plater\fonts\HARRYP__.TTF]])
LibSharedMedia:Register ("font", "FORCED SQUARE", [[Interface\Addons\Plater\fonts\FORCED SQUARE.ttf]])

LibSharedMedia:Register("sound", "Plater HiHat", [[Interface\Addons\Plater\sounds\Plater HiHat.ogg]])
LibSharedMedia:Register("sound", "Plater Hit", [[Interface\Addons\Plater\sounds\Plater Hit.ogg]])
LibSharedMedia:Register("sound", "Plater Shaker", [[Interface\Addons\Plater\sounds\Plater Shaker.ogg]])
LibSharedMedia:Register("sound", "Plater Steel", [[Interface\Addons\Plater\sounds\Plater Steel.ogg]])
LibSharedMedia:Register("sound", "Plater Wood", [[Interface\Addons\Plater\sounds\Plater Wood.ogg]])

--font templates
DF:InstallTemplate ("font", "PLATER_SCRIPTS_NAME", {color = "orange", size = 10, font = "Friz Quadrata TT"})
DF:InstallTemplate ("font", "PLATER_SCRIPTS_TYPE", {color = "gray", size = 9, font = "Friz Quadrata TT"})
DF:InstallTemplate ("font", "PLATER_SCRIPTS_TRIGGER_SPELLID", {color = {0.501961, 0.501961, 0.501961, .5}, size = 9, font = "Friz Quadrata TT"})
DF:InstallTemplate ("font", "PLATER_BUTTON", {color = {1, .8, .2}, size = 10, font = "Friz Quadrata TT"})
DF:InstallTemplate ("font", "PLATER_BUTTON_DISABLED", {color = {1/3, .8/3, .2/3}, size = 10, font = "Friz Quadrata TT"})

--button templates
DF:InstallTemplate ("button", "PLATER_BUTTON_DISABLED", {backdropcolor = {.4, .4, .4, .3}, backdropbordercolor = {0, 0, 0, .5}}, "OPTIONS_BUTTON_TEMPLATE")
DF:InstallTemplate ("button", "PLATER_BUTTON_SELECTED", {backdropbordercolor = {1, .7, .1, 1},}, "OPTIONS_BUTTON_TEMPLATE")

DF:InstallTemplate ("dropdown", "PLATER_DROPDOWN_OPTIONS", {
	backdrop = {
		edgeFile = [[Interface\Buttons\WHITE8X8]],
		edgeSize = 1,
		bgFile = [[Interface\Tooltips\UI-Tooltip-Background]],
		tileSize = 64,
		tile = true
	},

	backdropcolor = {.3, .3, .3, .8},
	backdropbordercolor = {0, 0, 0, 1},
	onentercolor = {.3, .3, .3, .9},
	onenterbordercolor = {1, 1, 1, 1},

	dropicon = "Interface\\BUTTONS\\arrow-Down-Down",
	dropiconsize = {16, 16},
	dropiconpoints = {-2, -3},
})


DF:InstallTemplate ("button", "PLATER_BUTTON_DARK", {
	backdrop = {edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 8, tile = true},
	backdropcolor = {0.05, 0.05, 0.05, .7},
	backdropbordercolor = {0, 0, 0, 1},
})


-- those two may be removed, as they are covered by settings now
DF:NewColor ("PLATER_FRIEND", .71, 1, 1, 1)
DF:NewColor ("PLATER_GUILD", 0.498039, 1, .2, 1)

DF:NewColor ("PLATER_DEBUFF", 1, 0.7117, 0.7117, 1)
DF:NewColor ("PLATER_BUFF", 0.7117, 1, 0.7509, 1)
DF:NewColor ("PLATER_CAST", 0.4117, 0.4784, 1, 1)

--defining reaction constants here isnce they are used within the profile
local UNITREACTION_HOSTILE = 3
local UNITREACTION_NEUTRAL = 4
local UNITREACTION_FRIENDLY = 5

platerInternal.optionsYStart = -150

PLATER_DEFAULT_SETTINGS = {
	
	profile = {
	
		--> save some cvars values so it can restore when a new character login using Plater
		saved_cvars = {},
		saved_cvars_last_change = {},
		keybinds = {},

		--store the enabled or disabled state of a plugin, this table is not shared on exporting profile
		plugins_data = {},

		--executed once for each expansion
		expansion_triggerwipe = {},

		class_colors = {
			["HUNTER"] = {r = 0.66666668653488, g = 0.82745105028152, b = 0.44705885648727, a = 1, colorStr = "ffaad372"},
			["WARRIOR"] = {r = 0.77647066116333, g = 0.60784316062927, b = 0.42745101451874, a = 1, colorStr = "ffc69b6d"},
			["ROGUE"] = {r = 1, g = 0.95686280727386, b = 0.4078431725502, a = 1, colorStr = "fffff468"},
			["MAGE"] = {r = 0.24705883860588, g = 0.78039222955704, b = 0.9215686917305, a = 1, colorStr = "ff3fc7eb"},
			["PRIEST"] = {r = 1, g = 1, b = 1, a = 1, colorStr = "ffffffff"},
			["EVOKER"] = {r = 0.20000001788139, g = 0.57647061347961, b = 0.49803924560547, a = 1, colorStr = "ff33937f"},
			["SHAMAN"] = {r = 0, g = 0.43921571969986, b = 0.8666667342186, a = 1, colorStr = "ff0070dd"},
			["WARLOCK"] = {r = 0.52941179275513, g = 0.53333336114883, b = 0.93333339691162, a = 1, colorStr = "ff8788ee"},
			["DEMONHUNTER"] = {r = 0.63921570777893, g = 0.18823531270027, b = 0.78823536634445, a = 1, colorStr = "ffa330c9"},
			["DEATHKNIGHT"] = {r = 0.76862752437592, g = 0.11764706671238, b = 0.22745099663734, a = 1, colorStr = "ffc41e3a"},
			["DRUID"] = {r = 1, g = 0.48627454042435, b = 0.039215687662363, a = 1, colorStr = "ffff7c0a"},
			["MONK"] = {r = 0, g = 1, b = 0.59607845544815, a = 1, colorStr = "ff00ff98"},
			["PALADIN"] = {r = 0.95686280727386, g = 0.54901963472366, b = 0.7294117808342, a = 1, colorStr = "fff48cba"},
		},

		--store npcs found in raids and dungeons
		npc_cache = {},
		--store colors selected by the player in the options panel
		--store as [NpcID] = {enabled1, enabled2, colorID}
		--enabled1 is if the color is enabled overall, enabled2 is if the color is only for scripts
		npc_colors = {},

		--store audio cues for spells
		--format: [SpellID] = filePath
		cast_audiocues = {},
		cast_audiocues_channel = "Master",
		cast_audiocue_cooldown = 0.1, --in seconds, delay to play the same audio again

		--store the cast colors customized by the user
		cast_colors = {}, --[spellId] = {[1] = color, [2] = enabled, [3] = custom spell name}
		cast_color_settings = { --these are settings for the original cast color settings
			enabled = false,
			width = 6,
			height_offset = 0,
			alpha = 0.8,
			anchor = {side = 11, x = 0, y = 0},
			layer = "Artwork",
		},

		click_space = {140, 28}, --classic: {132, 32}, retail: {110, 45},
		click_space_friendly = {140, 28}, --classic: {132, 32}, retail: {110, 45},
		click_space_always_show = false,
		hide_friendly_castbars = false,
		hide_enemy_castbars = false,
		
		--> offset of the whole nameplate
		global_offset_y = 0,
		global_offset_x = 0,
		
		--> number format, auto detect the region when logging for the first time in the profile
		number_region = "western",
		number_region_first_run = false,
		
		reopoen_options_panel_on_tab = false,
		
		plate_config  = {
			friendlyplayer = {
				enabled = true,
				module_enabled = true,
				only_damaged = true,
				only_thename = false,
				click_through = true,
				show_guild_name = false,
				
				fixed_class_color = {0, 1, 0, 1},
				
				health = {70, 2},
				health_incombat = {70, 2},
				cast = {80, 8},
				cast_incombat = {80, 12},
				mana = {100, 3},
				mana_incombat = {100, 3},
				buff_frame_y_offset = 10,
				castbar_offset_x = 0,
				castbar_offset = 0,
				
				actorname_text_spacing = 10,
				actorname_text_size = 10,
				actorname_text_font = "Arial Narrow",
				actorname_use_class_color = false,
				actorname_text_color = {1, 1, 1, 1},
				actorname_friend_color = {.71, 1, 1, 1},
				actorname_use_friends_color = true,
				actorname_guild_color = {0.498039, 1, .2, 1},
				actorname_use_guild_color = true,
				actorname_text_outline = "OUTLINE",
				actorname_text_shadow_color = {0, 0, 0, 1},
				actorname_text_shadow_color_offset = {1, -1},
				actorname_text_anchor = {side = 8, x = 0, y = 0},
				
				spellname_text_size = 10,
				spellname_text_font = "Arial Narrow",
				spellname_text_color = {1, 1, 1, 1},
				spellname_text_outline = "NONE",
				spellname_text_shadow_color = {0, 0, 0, 1},
				spellname_text_shadow_color_offset = {1, -1},
				spellname_text_anchor = {side = 9, x = 0, y = 0},
				
				spellpercent_text_enabled = false,
				spellpercent_text_size = 10,
				spellpercent_text_font = "Arial Narrow",
				spellpercent_text_color = {1, 1, 1, 1},
				spellpercent_text_outline = "OUTLINE",
				spellpercent_text_shadow_color = {0, 0, 0, 1},
				spellpercent_text_shadow_color_offset = {1, -1},
				spellpercent_text_anchor = {side = 11, x = -2, y = 0},
				
				level_text_enabled = false,
				level_text_anchor = {side = 7, x = 0, y = 1},
				level_text_size = 10,
				level_text_font = "Arial Narrow",
				level_text_outline = "NONE",
				level_text_shadow_color = {0, 0, 0, 1},
				level_text_shadow_color_offset = {1, -1},
				level_text_alpha = 0.7,
				
				percent_text_enabled = false,
				percent_text_ooc = false,
				percent_show_percent = true,
				percent_text_show_decimals = true,
				percent_show_health = false,
				percent_text_size = 9,
				percent_text_font = "Arial Narrow",
				percent_text_outline = "OUTLINE",
				percent_text_shadow_color = {0, 0, 0, 1},
				percent_text_shadow_color_offset = {1, -1},
				percent_text_color = {.9, .9, .9, 1},
				percent_text_anchor = {side = 9, x = 0, y = 0},
				percent_text_alpha = 1,
			},
			
			enemyplayer = {
				enabled = true,
				module_enabled = true,
				show_guild_name = false,
				
				use_playerclass_color = true,
				fixed_class_color = {1, .4, .1, 1},
				
				health = {112, 12},
				cast = {112, 10},
				mana = {100, 4},
				
				health_incombat = {120, 16},
				cast_incombat = {120, 12},
				mana_incombat = {100, 4},
				
				buff_frame_y_offset = 0,
				castbar_offset_x = 0,
				castbar_offset = 0,
				
				actorname_text_spacing = 12,
				actorname_text_size = 12,
				actorname_text_font = "Arial Narrow",
				actorname_use_class_color = false,
				actorname_text_color = {1, 1, 1, 1},
				actorname_text_outline = "NONE",
				actorname_text_shadow_color = {0, 0, 0, 1},
				actorname_text_shadow_color_offset = {1, -1},
				actorname_text_anchor = {side = 4, x = 0, y = 0},
				
				spellname_text_size = 10,
				spellname_text_font = "Arial Narrow",
				spellname_text_color = {1, 1, 1, 1},
				spellname_text_outline = "NONE",
				spellname_text_shadow_color = {0, 0, 0, 1},
				spellname_text_shadow_color_offset = {1, -1},
				spellname_text_anchor = {side = 9, x = 0, y = 0},
				
				spellpercent_text_enabled = true,
				spellpercent_text_size = 10,
				spellpercent_text_font = "Arial Narrow",
				spellpercent_text_color = {1, 1, 1, 1},
				spellpercent_text_outline = "OUTLINE",
				spellpercent_text_shadow_color = {0, 0, 0, 1},
				spellpercent_text_shadow_color_offset = {1, -1},
				spellpercent_text_anchor = {side = 11, x = -2, y = 0},
				
				level_text_enabled = true,
				level_text_anchor = {side = 7, x = 0, y = 1},
				level_text_size = 10,
				level_text_font = "Arial Narrow",
				level_text_outline = "NONE",
				level_text_shadow_color = {0, 0, 0, 1},
				level_text_shadow_color_offset = {1, -1},
				level_text_alpha = 0.7,
				
				percent_text_enabled = true,
				percent_text_ooc = true,
				percent_show_percent = true,
				percent_text_show_decimals = true,
				percent_show_health = true,
				percent_text_size = 9,
				percent_text_font = "Arial Narrow",
				percent_text_outline = "OUTLINE",
				percent_text_shadow_color = {0, 0, 0, 1},
				percent_text_shadow_color_offset = {1, -1},
				percent_text_color = {.9, .9, .9, 1},
				percent_text_anchor = {side = 9, x = 0, y = 0},
				percent_text_alpha = 1,
				
				big_actortitle_text_size = 11,
				big_actortitle_text_font = "Arial Narrow",
				big_actortitle_text_color = {1, .8, .0},
				big_actortitle_text_outline = "OUTLINE",
				big_actortitle_text_shadow_color = {0, 0, 0, 1},
				big_actortitle_text_shadow_color_offset = {1, -1},
				
				big_actorname_text_size = 9,
				big_actorname_text_font = "Arial Narrow",
				big_actorname_text_color = {.5, 1, .5},
				big_actorname_text_outline = "OUTLINE",
				big_actorname_text_shadow_color = {0, 0, 0, 1},
				big_actorname_text_shadow_color_offset = {1, -1},
			},

			friendlynpc = {
				only_names = true,
				all_names = true,
				relevance_state = 4,
				enabled = true,
				module_enabled = true,
				follow_blizzard_npc_option = false,
				
				health = {112, 12},
				cast = {112, 10},
				mana = {100, 4},
				
				health_incombat = {120, 16},
				cast_incombat = {120, 12},
				mana_incombat = {100, 4},
				
				buff_frame_y_offset = 0,
				castbar_offset_x = 0,
				castbar_offset = 0,
				
				actorname_text_spacing = 10,
				actorname_text_size = 10,
				actorname_text_font = "Arial Narrow",
				actorname_text_color = {1, 1, 1, 1},
				actorname_text_outline = "NONE",
				actorname_text_shadow_color = {0, 0, 0, 1},
				actorname_text_shadow_color_offset = {1, -1},
				actorname_text_anchor = {side = 8, x = 0, y = 0},
				
				spellname_text_size = 10,
				spellname_text_font = "Arial Narrow",
				spellname_text_color = {1, 1, 1, 1},
				spellname_text_outline = "NONE",
				spellname_text_shadow_color = {0, 0, 0, 1},
				spellname_text_shadow_color_offset = {1, -1},
				spellname_text_anchor = {side = 9, x = 0, y = 0},
				
				spellpercent_text_enabled = false,
				spellpercent_text_size = 10,
				spellpercent_text_font = "Arial Narrow",
				spellpercent_text_color = {1, 1, 1, 1},
				spellpercent_text_outline = "OUTLINE",
				spellpercent_text_shadow_color = {0, 0, 0, 1},
				spellpercent_text_shadow_color_offset = {1, -1},
				spellpercent_text_anchor = {side = 11, x = -2, y = 0},
				
				level_text_enabled = false,
				level_text_anchor = {side = 7, x = 0, y = 1},
				level_text_size = 10,
				level_text_font = "Arial Narrow",
				level_text_outline = "NONE",
				level_text_shadow_color = {0, 0, 0, 1},
				level_text_shadow_color_offset = {1, -1},
				level_text_alpha = 0.7,
				
				percent_text_enabled = false,
				percent_text_ooc = false,
				percent_show_percent = true,
				percent_text_show_decimals = true,
				percent_show_health = false,
				percent_text_size = 9,
				percent_text_font = "Arial Narrow",
				percent_text_outline = "OUTLINE",
				percent_text_shadow_color = {0, 0, 0, 1},
				percent_text_shadow_color_offset = {1, -1},
				percent_text_color = {.9, .9, .9, 1},
				percent_text_anchor = {side = 9, x = 0, y = 0},
				percent_text_alpha = 1,
				
				quest_enabled = true,
				quest_color_enabled = true,
				quest_color = {.5, 1, 0, 1},
				
				big_actortitle_text_size = 11,
				big_actortitle_text_font = "Arial Narrow",
				big_actortitle_text_color = {1, .8, .0},
				big_actortitle_text_outline = "OUTLINE",
				big_actortitle_text_shadow_color = {0, 0, 0, 1},
				big_actortitle_text_shadow_color_offset = {1, -1},
				
				big_actorname_text_size = 9,
				big_actorname_text_font = "Arial Narrow",
				big_actorname_text_color = {.5, 1, .5},
				big_actorname_text_outline = "OUTLINE",
				big_actorname_text_shadow_color = {0, 0, 0, 1},
				big_actorname_text_shadow_color_offset = {1, -1},
			},
			
			enemynpc = {
				enabled = true,
				module_enabled = true,
				all_names = true,
				
				health = {112, 12},
				cast = {112, 10},
				mana = {100, 4},
				
				health_incombat = {120, 16},
				cast_incombat = {120, 14},
				mana_incombat = {100, 4},
				
				buff_frame_y_offset = 0,
				castbar_offset_x = 0,
				castbar_offset = 0,
				
				actorname_text_spacing = 10,
				actorname_text_size = 11,
				actorname_text_font = "Arial Narrow",
				actorname_text_color = {1, 1, 1, 1},
				actorname_text_outline = "NONE",
				actorname_text_shadow_color = {0, 0, 0, 1},
				actorname_text_shadow_color_offset = {1, -1},
				actorname_text_anchor = {side = 4, x = 0, y = 0},
				
				spellname_text_size = 12,
				spellname_text_font = "Arial Narrow",
				spellname_text_color = {1, 1, 1, 1},
				spellname_text_outline = "OUTLINE",
				spellname_text_shadow_color = {0, 0, 0, 1},
				spellname_text_shadow_color_offset = {1, -1},
				spellname_text_anchor = {side = 9, x = 0, y = 0},
				
				spellpercent_text_enabled = true,
				spellpercent_text_size = 11,
				spellpercent_text_font = "Arial Narrow",
				spellpercent_text_color = {1, 1, 1, 1},
				spellpercent_text_outline = "OUTLINE",
				spellpercent_text_shadow_color = {0, 0, 0, 1},
				spellpercent_text_shadow_color_offset = {1, -1},
				spellpercent_text_anchor = {side = 11, x = -2, y = 0},
				
				level_text_enabled = true,
				level_text_anchor = {side = 7, x = 0, y = 1},
				level_text_size = 8,
				level_text_font = "Arial Narrow",
				level_text_outline = "NONE",
				level_text_shadow_color = {0, 0, 0, 1},
				level_text_shadow_color_offset = {1, -1},
				level_text_alpha = 0.7,
				
				percent_text_enabled = true,
				percent_text_ooc = true,
				percent_show_percent = true,
				percent_text_show_decimals = true,
				percent_show_health = true,
				percent_text_size = 9,
				percent_text_font = "Arial Narrow",
				percent_text_outline = "OUTLINE",
				percent_text_shadow_color = {0, 0, 0, 1},
				percent_text_shadow_color_offset = {1, -1},
				percent_text_color = {.9, .9, .9, 1},
				percent_text_anchor = {side = 9, x = 0, y = 0},
				percent_text_alpha = 1,
				
				quest_enabled = true,
				quest_color_enabled = true,
				quest_color_enemy = {1, .369, 0, 1},
				quest_color_neutral = {1, .65, 0, 1},
				
				--no color / it'll auto colour by the reaction
				big_actortitle_text_size = 10,
				big_actortitle_text_font = "Arial Narrow",
				big_actortitle_text_outline = "OUTLINE",
				big_actortitle_text_shadow_color = {0, 0, 0, 1},
				big_actortitle_text_shadow_color_offset = {1, -1},
				--big_actortitle_text_color = {1, .8, .0},
				
				big_actorname_text_size = 10,
				big_actorname_text_font = "Arial Narrow",
				big_actorname_text_outline = "OUTLINE",
				big_actorname_text_shadow_color = {0, 0, 0, 1},
				big_actorname_text_shadow_color_offset = {1, -1},
				--big_actorname_text_color = {.5, 1, .5},
			},

			player = {
				enabled = true,
				module_enabled = true,
				click_through = false,
				health = {150, 12},
				health_incombat = {150, 12},
				mana = {150, 10},
				mana_incombat = {150, 10},
				buff_frame_y_offset = 0,
				y_position_offset = -50, --deprecated
				pvp_always_incombat = true,
				healthbar_enabled = true,
				healthbar_color = {0.564706, 0.933333, 0.564706, 1},
				healthbar_color_by_hp = false,
				castbar_offset_x = 0,
				castbar_offset = 0, --not used?
				
				castbar_enabled = true,
				cast = {150, 10},
				cast_incombat = {150, 10},
				
				actorname_text_spacing = 10,
				actorname_text_size = 10,
				actorname_text_font = "Arial Narrow",
				actorname_text_color = {1, 1, 1, 1},
				actorname_text_outline = "OUTLINE",
				actorname_text_shadow_color = {0, 0, 0, 1},
				actorname_text_shadow_color_offset = {1, -1},
				actorname_text_anchor = {side = 8, x = 0, y = 0},
				
				spellname_text_size = 10,
				spellname_text_font = "Arial Narrow",
				spellname_text_color = {1, 1, 1, 1},
				spellname_text_outline = "OUTLINE",
				spellname_text_shadow_color = {0, 0, 0, 1},
				spellname_text_shadow_color_offset = {1, -1},
				spellname_text_anchor = {side = 9, x = 0, y = 0},
				
				spellpercent_text_enabled = true,
				spellpercent_text_size = 10,
				spellpercent_text_font = "Arial Narrow",
				spellpercent_text_color = {1, 1, 1, 1},
				spellpercent_text_outline = "OUTLINE",
				spellpercent_text_shadow_color = {0, 0, 0, 1},
				spellpercent_text_shadow_color_offset = {1, -1},
				spellpercent_text_anchor = {side = 11, x = -2, y = 0},
				
				level_text_enabled = false,
				level_text_anchor = {side = 7, x = 0, y = 1},
				level_text_size = 10,
				level_text_font = "Arial Narrow",
				level_text_outline = "NONE",
				level_text_shadow_color = {0, 0, 0, 1},
				level_text_shadow_color_offset = {1, -1},
				level_text_alpha = 0.7,
				
				percent_text_enabled = true,
				percent_text_ooc = true,
				percent_show_percent = true,
				percent_text_show_decimals = true,
				percent_show_health = true,
				percent_text_size = 10,
				percent_text_font = "Arial Narrow",
				percent_text_outline = "OUTLINE",
				percent_text_shadow_color = {0, 0, 0, 1},
				percent_text_shadow_color_offset = {1, -1},
				percent_text_color = {.9, .9, .9, 1},
				percent_text_anchor = {side = 9, x = 0, y = 0},
				percent_text_alpha = 1,
				
				power_enabled = true,
				power_percent_text_enabled = true,
				power_percent_text_size = 9,
				power_percent_text_font = "Arial Narrow",
				power_percent_text_outline = "OUTLINE",
				power_percent_text_shadow_color = {0, 0, 0, 1},
				power_percent_text_shadow_color_offset = {1, -1},
				power_percent_text_color = {.9, .9, .9, 1},
				power_percent_text_anchor = {side = 9, x = 0, y = 0},
				power_percent_text_alpha = 1,

			},
		},

		login_counter = 0,

		--plater resources bar ~resources
		resources_settings = {
			chr = {}, --store which resource model is used on each character
			global_settings = {
				show = false, --if the resource bar from plater is enabled
				personal_bar = false, --if the resource bar shows in the personal bar intead of the current target
				align = "horizontal", --combo points are horizontal alignment
				grow_direction = "center",
				show_depleted = true,
				show_number = false,
				anchor = {side = 8, x = 0, y = 40},
				scale = 0.8,
				padding = 2,
			},
			druid_show_always = false,
			resource_options = {
				--names below are from Enum.PowerType[<resource name>]
				["ComboPoints"] = {

				},
				["HolyPower"] = {

				},
				["Runes"] = {

				},
				["SoulShards"] = {

				},
				["Chi"] = {

				},
				["ArcaneCharges"] =  {

				},
			},
		},

		spell_prediction = { --not being used at the moment
			enabled = false,
			castbar_height = 12,

		},

		--transparency control
		transparency_behavior = 0x1,
		transparency_behavior_use_division = false,
		non_targeted_alpha_enabled = false,
		transparency_behavior_on_enemies = true,
		honor_blizzard_plate_alpha = false,
		focus_as_target_alpha = false,
		
		
		transparency_behavior_on_friendlies = false,
		
		quick_hide = false, --hide the nameplate when the unit hits 0 health points | making disabled by default, this maybe is bugging hunters FD
		
		show_healthbars_on_not_attackable = false,
		show_healthbars_on_softinteract = true,
		ignore_softinteract_objects = false,
		hide_name_on_game_objects = true,
		name_on_game_object_color = {1, 1, 1, 1},
		show_softinteract_icons = true,
		
		enable_masque_support = false,
		
		use_name_translit = false,
		
		use_player_combat_state = false,
		
		opt_out_auto_accept_npc_colors = true,
		auto_translate_npc_names = false, -- one day default to true
		
		shadowMode = 1,
		
		last_news_time = 0,
		disable_omnicc_on_auras = false,
		
		show_health_prediction = true,
		show_shield_prediction = true,
		
		show_interrupt_author = true,

		customdesign = {
			healthbar_enabled = false,
			healthbar_file = "interface\\addons\\plater\\images\\healthbar\\round_base",
			healthbar_border_file = "interface\\addons\\plater\\images\\healthbar\\round_border_2px",
			healthbar_border_distance = 0,
			healthbar_border_color = "silver",

			castbar_enabled = false,
			castbar_file = "interface\\addons\\plater\\images\\healthbar\\round_base",
			castbar_border_file = "interface\\addons\\plater\\images\\healthbar\\round_border_2px",
			castbar_border_distance = 0,
			castbar_border_color = "silver",

			powerbar_enabled = false,
			powerbar_file = "interface\\addons\\plater\\images\\healthbar\\round_base",
			powerbar_border_file = "interface\\addons\\plater\\images\\healthbar\\round_border_2px",
			powerbar_border_distance = 0,
			powerbar_border_color = "silver",
		},
		
		--allow scripts to store default values of cvars when they perform automatically changes
		cvar_default_cache = {},
		
		--experimental settings for the UIParent parenting
		use_ui_parent = false,
		use_ui_parent_just_enabled = false,
		ui_parent_base_strata = "BACKGROUND",
		ui_parent_buff_strata = "BACKGROUND", --testing, buffs should be in front of the health bar
		ui_parent_buff2_strata = "BACKGROUND",
		ui_parent_buff_special_strata = "BACKGROUND",
		ui_parent_cast_strata = "BACKGROUND", --testing, the castbar should be in front of everythings
		ui_parent_target_strata = "LOW", --testing, the current target nameplate should be in this strata
		ui_parent_buff_level = 0,
		ui_parent_buff2_level = 0,
		ui_parent_buff_special_level = 0,
		ui_parent_cast_level = 0,
		ui_parent_scale_tune = 0, --testing, a slider to change the unit frame scale / goal is to have a fine tune knob to adjust the overall size when using this feature
		
		--blizzard default nameplate fonts
		blizzard_nameplate_font_override_enabled = false,
		blizzard_nameplate_font = "Arial Narrow",
		blizzard_nameplate_font_outline = "OUTLINE",
		blizzard_nameplate_font_size = 9,
		blizzard_nameplate_large_font = "Arial Narrow",
		blizzard_nameplate_large_font_outline = "OUTLINE",
		blizzard_nameplate_large_font_size = 11,
		
		resources = {
			alpha = 1,
			scale = 0.8,
			y_offset = 0,
			y_offset_target = 8,
			y_offset_target_withauras = 26,
		},
		
		--> special unit
		pet_width_scale = 0.95,
		pet_height_scale = 0.95,
		minor_width_scale = 0.9,
		minor_height_scale = 0.95,
		
		--> widget settings
		widget_bar_scale = 0.75,
		widget_bar_anchor = {side = 4, x = 0, y = 0},
		
		no_spellname_length_limit = false,
		
		--> castbar target name
		castbar_target_show = false,
		castbar_target_notank = false,
		castbar_target_anchor = {side = 5, x = 0, y = 0},
		castbar_target_text_size = 10,
		castbar_target_outline = "OUTLINE",
		castbar_target_shadow_color = {0, 0, 0, 1},
		castbar_target_shadow_color_offset = {1, -1},
		castbar_target_color = {0.968627, 0.992156, 1, 1},
		castbar_target_font = "Arial Narrow",

		--> castbar icon
		castbar_icon_customization_enabled = true,
		castbar_icon_show = true,
		castbar_icon_attach_to_side = "left", --"right"
		castbar_icon_size = "same as castbar", --"same as castbar plus healthbar"
		castbar_icon_x_offset = 0,
		
		
		--> store spells from the latest event the player has been into
		captured_spells = {},
		captured_casts = {},

		--script tab
		script_data = {},
		script_data_trash = {}, --deleted scripts are placed here, they can be restored in 30 days
		script_auto_imported = {}, --store the name and revision of scripts imported from the Plater script library
		script_banned_user = {}, --players banned from sending scripts to this player
		
		--hooking tab
		hook_data = {},
		hook_data_trash = {}, --deleted scripts are placed here, they can be restored in 30 days
		hook_auto_imported = {}, --store the name and revision of scripts imported from the Plater script library
		
		patch_version = 0,
		patch_version_profile = 0,
		
		health_cutoff = true,
		health_cutoff_upper = true,
		health_cutoff_extra_glow = false,
		health_cutoff_hide_divisor = false,
		
		update_throttle = 0.25,
		culling_distance = 100,
		use_playerclass_color = true, --friendly player
		
		use_health_animation = false,
		health_animation_time_dilatation = 2.615321,
		
		use_color_lerp = false,
		color_lerp_speed = 12,
		
		--removed on march 10, 2019, can be cleaned up:
		--options for this feature also got removed from the options panel
		--plater.lua got full cleanup on this feature as well
		--healthbar_framelevel = 0,
		--castbar_framelevel = 0,
		
		hide_blizzard_castbar = false,
		
		aura_cooldown_reverse = true,
		aura_cooldown_show_swipe = true,
		aura_cooldown_edge_texture = [[Interface\AddOns\Plater\images\cooldown_edge_2]],
		
		aura_enabled = true,
		aura_show_tooltip = false,
		aura_width = 26,
		aura_height = 16,
		aura_border_thickness = 1,
		aura_width2 = 26,
		aura_height2 = 16,
		aura_border_thickness2 = 1,
		auras_per_row_auto = true,
		auras_per_row_amount = 10,
		auras_per_row_amount2 = 10,
		
		--> aura frame 1
		--aura_x_offset = 0,
		--aura_y_offset = 5,
		aura_grow_direction = 2, --> center
		aura_frame1_anchor = {side = 8, x = 0, y = 5}, -- in sync with aura_x_offset and aura_y_offset to be compatible to scripts...
		aura_breakline_space = 12, --space between the first and second line when the aura break line
		
		--> aura frame 2
		buffs_on_aura2 = false,
		--aura2_x_offset = 0,
		--aura2_y_offset = 5,
		aura2_grow_direction = 2, --> center
		aura_frame2_anchor = {side = 8, x = 0, y = 5}, -- in sync with aura_x_offset and aura_y_offset to be compatible to scripts...
		
		aura_padding = 1, --space between each icon
		aura_consolidate = false, --aura icons shown with the same name is stacked into only one
		aura_consolidate_timeleft_lower = true, --when stacking auras with the same name, show the time left for the aura with the lesser remaining time
		aura_sort = false, -- sort auras via sort function -> default by time left
		
		aura_alpha = 0.85,
		aura_custom = {},
		
		aura_timer = true,
		aura_timer_decimals = false,
		aura_timer_text_size = 15,
		aura_timer_text_font = "Arial Narrow",
		aura_timer_text_anchor = {side = 9, x = 0, y = 0},
		aura_timer_text_outline = "OUTLINE",
		aura_timer_text_shadow_color = {0, 0, 0, 1},
		aura_timer_text_shadow_color_offset = {1, -1},
		aura_timer_text_color = {1, 1, 1, 1},

		aura_stack_anchor = {side = 8, x = 0, y = 0},
		aura_stack_size = 10,
		aura_stack_font = "Arial Narrow",
		aura_stack_outline = "OUTLINE",
		aura_stack_shadow_color = {0, 0, 0, 1},
		aura_stack_shadow_color_offset = {1, -1},
		aura_stack_color = {1, 1, 1, 1},
		
		extra_icon_anchor = {side = 6, x = -4, y = 0},
		extra_icon_show_timer = true,
		extra_icon_timer_decimals = false,
		extra_icon_show_swipe = true,
		extra_icon_cooldown_reverse = true,
		extra_icon_cooldown_edge_texture = "Interface\\Cooldown\\edge",
		extra_icon_timer_font = "Arial Narrow",
		extra_icon_timer_size = 12,
		extra_icon_timer_outline = "NONE",
		extra_icon_width = 30,
		extra_icon_height = 18,
		extra_icon_wide_icon = true,
		extra_icon_use_blizzard_border_color = true,
		extra_icon_caster_name = true,
		extra_icon_caster_font = "Arial Narrow",
		extra_icon_caster_size = 7,
		extra_icon_caster_outline = "NONE",
		extra_icon_show_stacks = true,
		extra_icon_stack_font = "Arial Narrow",
		extra_icon_stack_size = 10,
		extra_icon_stack_outline = "NONE",
		extra_icon_backdrop_color = {0, 0, 0, 0.612853},
		extra_icon_border_color = {0, 0, 0, 1},
		extra_icon_border_size = 1,
		
		debuff_show_cc = true, --extra frame show cc
		debuff_show_cc_border = {.3, .2, .2, 1},
		extra_icon_show_purge = false, --extra frame show purge
		extra_icon_show_purge_border = {0, .925, 1, 1},
		extra_icon_show_enrage = false, --extra frame show purge
		extra_icon_show_magic = false,
		extra_icon_show_enrage_border = {0.85, 0.2, 0.1, 1},
		extra_icon_show_offensive = false,
		extra_icon_show_offensive_border = {0, .65, .1, 1},
		extra_icon_show_defensive = false,
		extra_icon_show_defensive_border = {.85, .45, .1, 1},
		
		extra_icon_auras = {}, --auras for buff special tab
		extra_icon_auras_mine = {}, --auras in the buff special that are only cast by the player
		
		aura_width_personal = 32,
		aura_height_personal = 20,
		aura_border_thickness_personal = 1,
		aura_show_buffs_personal = false,
		aura_show_debuffs_personal = true,
		aura_show_all_duration_buffs_personal = false,
		
		aura_show_important = true,
		aura_show_dispellable = true,
		aura_show_only_short_dispellable_on_players = false,
		aura_show_enrage = false,
		aura_show_magic = false,
		aura_show_aura_by_the_player = true,
		aura_show_aura_by_other_players = false,
		aura_show_buff_by_the_unit = true,
		aura_border_colors_by_type = false,
		aura_show_crowdcontrol = false,
		aura_show_offensive_cd = false,
		aura_show_defensive_cd = false,
		
		aura_border_colors = {
			steal_or_purge = {0, .5, .98, 1},
			enrage = {0.85, 0.2, 0.1, 1},
			is_buff = {0, .65, .1, 1},
			is_show_all = {.7, .1, .1, 1},
			defensive = {.85, .45, .1, 1},
			offensive = {0, .65, .1, 1},
			crowdcontrol = {.3, .2, .2, 1},
			default = {0, 0, 0, 1},
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
				--breath of coldheart (torghast)
				[333553] = true,
			},
			debuff_banned = {},
			buff_tracked = {},
			debuff_tracked = {},
		},
		
		bossmod_support_enabled = true,
		bossmod_castrename_enabled = true,
		bossmod_support_bars_enabled = true,
		bossmod_support_bars_text_enabled = true,
		bossmod_aura_height = 24,
		bossmod_aura_width = 24,
		bossmod_cooldown_text_size = 16,
		bossmod_cooldown_text_enabled = true,
		bossmod_icons_anchor = {side = 2, x = -5, y = 25},
		bossmod_aura_glow_cooldown = true,
		bossmod_aura_glow_important_only = true,
		bossmod_aura_glow_casts = true,
		bossmod_aura_glow_casts_glow_type = 4,
		bossmod_aura_glow_cooldown_glow_type = 1,
		
		not_affecting_combat_enabled = false,
		not_affecting_combat_alpha = 0.6,

		range_check_enabled = true,
		range_check_alpha = 0.65, --overall as it set in the unitFrame
		range_check_health_bar_alpha = 1,
		range_check_cast_bar_alpha = 1,
		range_check_buffs_alpha = 1,
		range_check_power_bar_alpha = 1,
		range_check_in_range_or_target_alpha = 0.9, 
		
		range_check_alpha_friendlies = 0.65, --overall as it set in the unitFrame
		range_check_health_bar_alpha_friendlies = 1,
		range_check_cast_bar_alpha_friendlies = 1,
		range_check_buffs_alpha_friendlies = 1,
		range_check_power_bar_alpha_friendlies = 1,
		range_check_in_range_or_target_alpha_friendlies = 0.9,
		
		target_highlight = true,
		target_highlight_alpha = 0.75,
		target_highlight_height = 14,
		target_highlight_color = {0, 0.521568, 1, 1},
		target_highlight_texture = [[Interface\AddOns\Plater\images\selection_indicator3]],
		
		target_shady_alpha = 0.6,
		target_shady_enabled = true,
		target_shady_combat_only = true,
		
		hover_highlight = true,
		highlight_on_hover_unit_model = false,
		hover_highlight_alpha = .30,
		
		auto_toggle_friendly_enabled = false,
		auto_toggle_friendly = {
			["party"] = false,
			["raid"] = false,
			["arena"] = false,
			["world"] =  true,
			["cities"] = true,
		},
		
		auto_toggle_enemy_enabled = false,
		auto_toggle_enemy = {
			["party"] = true,
			["raid"] = true,
			["arena"] = true,
			["world"] =  true,
			["cities"] = false,
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

		auto_inside_raid_dungeon = {
			hide_enemy_player_pets = false,
			hide_enemy_player_totems = false,
		},
		
		auto_toggle_combat_enabled = false,
		auto_toggle_combat = {
			friendly_ic = false,
			enemy_ic = false,
			friendly_ooc = false,
			enemy_ooc = false,
			blizz_healthbar_ic = false,
			blizz_healthbar_ooc = false,
		},

		spell_animations = true,
		spell_animations_scale = 1.25,

		--hold the npcs that has been rename on the Npcs tab, format: [npcId] = "new npc name"
		npcs_renamed = {},

		ghost_auras = {
			enabled = false,
			width = 0,
			height = 0,
			alpha = 0.5,
			desaturated = true,
			auras = {
				["DEMONHUNTER"] = {
					[0] = {},
					[1] = {},
					[2] = {},
				},
				["DEATHKNIGHT"] = {
					[0] = {},
					[1] = {},
					[2] = {},
					[3] = {},
				},
				["WARRIOR"] = {
					[0] = {},
					[1] = {},
					[2] = {},
					[3] = {},
				},
				["MAGE"] = {
					[0] = {},
					[1] = {},
					[2] = {},
					[3] = {},
				},
				["ROGUE"] = {
					[0] = {},
					[1] = {},
					[2] = {},
					[3] = {},
				},
				["DRUID"] = {
					[0] = {},
					[1] = {},
					[2] = {},
					[3] = {},
					[4] = {},
				},
				["HUNTER"] = {
					[0] = {},
					[1] = {},
					[2] = {},
					[3] = {},
				},
				["SHAMAN"] = {
					[0] = {},
					[1] = {},
					[2] = {},
					[3] = {},
				},
				["PRIEST"] = {
					[0] = {},
					[1] = {},
					[2] = {},
					[3] = {},
				},
				["WARLOCK"] = {
					[0] = {},
					[1] = {},
					[2] = {},
					[3] = {},
				},
				["PALADIN"] = {
					[0] = {},
					[1] = {},
					[2] = {},
					[3] = {},
				},
				["MONK"] = {
					[0] = {},
					[1] = {},
					[2] = {},
					[3] = {},
				},
				["EVOKER"] = {
					[0] = {},
					[1] = {},
					[2] = {},
					[3] = {},
				},
			},
		},

		spell_animation_list = {
			--chaos bolt
			[116858] =  {
				[1] =  {
				   ["enabled"] = true,
				   ["scale_upX"] = 1.0499999523163,
				   ["scale_downY"] = 0.94999998807907,
				   ["scale_downX"] = 0.94999998807907,
				   ["scale_upY"] = 1.0499999523163,
				   ["critical_scale"] = 1,
				   ["animation_type"] = "scale",
				   ["cooldown"] = 0.75,
				   ["duration"] = 0.099999994039536,
				},
				[2] =  {
				   ["enabled"] = true,
				   ["fade_out"] = 0.099999994039536,
				   ["absolute_sineX"] = false,
				   ["absolute_sineY"] = true,
				   ["animation_type"] = "frameshake",
				   ["scaleX"] = 0,
				   ["duration"] = 0.099999994039536,
				   ["amplitude"] = 0.59999996423721,
				   ["fade_in"] = 0.049999997019768,
				   ["scaleY"] = 4.9699974060059,
				   ["cooldown"] = 0.25,
				   ["frequency"] = 2.8999998569489,
				},
				["info"] =  {
				   ["time"] = 0,
				   ["class"] = "WARLOCK",
				   ["spellid"] = 116858,
				   ["desc"] = "",
				},
			},

			--malefic rapture
			[324540] = {
				[1] =  {
				   ["enabled"] = true,
				   ["fade_out"] = 0.089999996125698,
				   ["duration"] = 0.1499999910593,
				   ["absolute_sineX"] = false,
				   ["absolute_sineY"] = false,
				   ["animation_type"] = "frameshake",
				   ["scaleX"] = 0.099998474121094,
				   ["amplitude"] = 0.89999997615814,
				   ["critical_scale"] = 1.05,
				   ["fade_in"] = 0.0099999997764826,
				   ["scaleY"] = 2,
				   ["cooldown"] = 0.5,
				   ["frequency"] = 25.650197982788,
				},
				[2] =  {
				   ["enabled"] = true,
				   ["scale_upX"] = 1.0299999713898,
				   ["scale_downY"] = 0.96999996900558,
				   ["scale_downX"] = 0.96999996900558,
				   ["scale_upY"] = 1.0299999713898,
				   ["duration"] = 0.05,
				   ["cooldown"] = 0.75,
				   ["animation_type"] = "scale",
				},
				["info"] =  {
				   ["time"] = 1539292087,
				   ["class"] = "WARLOCK",
				   ["spellid"] = 324540,
				   ["desc"] = "",
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
				},
				info = {
					time = 0,
					desc = "",
					class = "WARLOCK",
					spellid = 27285,
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
				},
				info = {
					time = 0,
					desc = "",
					class = "WARLOCK",
					spellid = 86040,
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
					duration = 0.12,
					amplitude = 2.5,
					frequency = 20,
					fade_in = 0.01,
					fade_out = 0.08,
					cooldown = 0.25,
				},
				info = {
					time = 0,
					desc = "",
					class = "WARLOCK",
					spellid = 264178,
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
				},
				info = {
					time = 0,
					desc = "",
					class = "WARLOCK",
					spellid = 196278,
				}			
			},
			
			--Secret Technique (Rogue)
			[280720] = {
			   [1] = {
			      ["enabled"] = true,
			      ["fade_out"] = 0.089999996125698,
			      ["absolute_sineX"] = false,
			      ["duration"] = 0.19999998807907,
			      ["absolute_sineY"] = false,
			      ["animation_type"] = "frameshake",
			      ["scaleX"] = 0.1,
			      ["amplitude"] = 0.89999997615814,
			      ["critical_scale"] = 1.05,
			      ["fade_in"] = 0.0099999997764826,
			      ["scaleY"] = 1,
			      ["cooldown"] = 0.5,
			      ["frequency"] = 200,
			   },
			   ["info"] = {
			      ["time"] = 1539292087,
			      ["class"] = "ROGUE",
			      ["spellid"] = 280720,
			      ["desc"] = "",
			   },
			},
			
			--Shadowstrike (Rogue)
			[185438] = {
			   [1] = {
			      ["enabled"] = true,
			      ["fade_out"] = 0.19999998807907,
			      ["duration"] = 0.099999994039536,
			      ["absolute_sineX"] = false,
			      ["absolute_sineY"] = true,
			      ["animation_type"] = "frameshake",
			      ["scaleX"] = 0.099998474121094,
			      ["critical_scale"] = 1.05,
			      ["amplitude"] = 6.460000038147,
			      ["fade_in"] = 0,
			      ["scaleY"] = -1,
			      ["cooldown"] = 0.5,
			      ["frequency"] = 25,
			   },
			   [2] = {
			      ["enabled"] = true,
			      ["scale_upX"] = 1.0299999713898,
			      ["scale_upY"] = 1.0299999713898,
			      ["cooldown"] = 0.75,
			      ["duration"] = 0.05,
			      ["scale_downY"] = 0.96999996900559,
			      ["scale_downX"] = 0.96999996900559,
			      ["animation_type"] = "scale",
			   },
			   ["info"] = {
			      ["time"] = 1539204014,
			      ["class"] = "ROGUE",
			      ["spellid"] = 185438,
			      ["desc"] = "",
			   },
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
				},
				info = {
					time = 0,
					desc = "",
					class = "ROGUE",
					spellid = 197834,
				}				
			},
			
			--Eviscerate (Rogue)
			[196819] = {
			   [1] = {
			      ["animation_type"] = "scale",
			      ["scale_upX"] = 1.1999999284744,
			      ["enabled"] = true,
			      ["scale_downX"] = 0.89999997615814,
			      ["scale_downY"] = 0.89999997615814,
			      ["duration"] = 0.04,
			      ["cooldown"] = 0.75,
			      ["scale_upY"] = 1.2999999523163,
			   },
			   [2] = {
			      ["enabled"] = true,
			      ["fade_out"] = 0.1799999922514,
			      ["absolute_sineX"] = false,
			      ["absolute_sineY"] = true,
			      ["animation_type"] = "frameshake",
			      ["scaleX"] = 1,
			      ["duration"] = 0.21999999880791,
			      ["amplitude"] = 5,
			      ["fade_in"] = 0.0099999997764826,
			      ["scaleY"] = 1,
			      ["cooldown"] = 0.5,
			      ["frequency"] = 3.3099999427795,
			   },
			   ["info"] = {
			      ["spellid"] = 196819,
			      ["class"] = "ROGUE",
			      ["time"] = 0,
			      ["desc"] = "",
			   },
			},

			--Pistol Shot (Rogue)
			[185763] =  {
			   [1] =  {
			      ["enabled"] = true,
			      ["fade_out"] = 0.25999999046326,
			      ["absolute_sineX"] = false,
			      ["duration"] = 0.15999999642372,
			      ["absolute_sineY"] = true,
			      ["animation_type"] = "frameshake",
			      ["scaleX"] = 0.099998474121094,
			      ["amplitude"] = 3.6583230495453,
			      ["critical_scale"] = 1.05,
			      ["fade_in"] = 0.0099999997764826,
			      ["scaleY"] = 1,
			      ["cooldown"] = 0.5,
			      ["frequency"] = 23.525663375854,
			   },
			   [2] =  {
			      ["animation_type"] = "scale",
			      ["scale_upX"] = 1.0299999713898,
			      ["enabled"] = true,
			      ["scale_downX"] = 0.96999996900559,
			      ["scale_downY"] = 0.96999996900559,
			      ["duration"] = 0.05,
			      ["cooldown"] = 0.75,
			      ["scale_upY"] = 1.0299999713898,
			   },
			   ["info"] =  {
			      ["time"] = 1539275610,
			      ["class"] = "ROGUE",
			      ["spellid"] = 185763,
			      ["desc"] = "",
			   },
			},

			--Dispatch (Rogue)
			[2098] =  {
			   [1] =  {
			      ["scale_upY"] = 1.1999999284744,
			      ["scale_upX"] = 1.1000000238419,
			      ["enabled"] = true,
			      ["scale_downX"] = 0.89999997615814,
			      ["scale_downY"] = 0.89999997615814,
			      ["duration"] = 0.04,
			      ["cooldown"] = 0.75,
			      ["animation_type"] = "scale",
			   },
			   [2] =  {
			      ["enabled"] = true,
			      ["fade_out"] = 0.079999998211861,
			      ["absolute_sineX"] = false,
			      ["absolute_sineY"] = true,
			      ["animation_type"] = "frameshake",
			      ["scaleX"] = 1,
			      ["duration"] = 0.21999999880791,
			      ["amplitude"] = 1.5,
			      ["fade_in"] = 0,
			      ["scaleY"] = 1,
			      ["cooldown"] = 0.5,
			      ["frequency"] = 2.710000038147,
			   },
			   ["info"] =  {
			      ["time"] = 1539293610,
			      ["class"] = "ROGUE",
			      ["spellid"] = 2098,
			      ["desc"] = "",
			   },
			},

			--Envenom (Rogue)
			[32645] =  {
			   [1] =  {
			      ["animation_type"] = "scale",
			      ["scale_upX"] = 1.1000000238419,
			      ["enabled"] = true,
			      ["scale_downX"] = 0.89999997615814,
			      ["scale_downY"] = 0.89999997615814,
			      ["duration"] = 0.04,
			      ["cooldown"] = 0.75,
			      ["scale_upY"] = 1.1999999284744,
			   },
			   [2] =  {
			      ["enabled"] = true,
			      ["fade_out"] = 0.1799999922514,
			      ["absolute_sineX"] = false,
			      ["absolute_sineY"] = true,
			      ["animation_type"] = "frameshake",
			      ["scaleX"] = 1,
			      ["duration"] = 0.12000000476837,
			      ["amplitude"] = 4.0999999046326,
			      ["fade_in"] = 0.0099999997764826,
			      ["scaleY"] = 1,
			      ["cooldown"] = 0.5,
			      ["frequency"] = 2.6099998950958,
			   },
			   ["info"] =  {
			      ["spellid"] = 32645,
			      ["class"] = "ROGUE",
			      ["time"] = 0,
			      ["desc"] = "",
			   },
			},

			
			--Between the Eyes (Rogue)
			[199804] =  {
			   [1] =  {
			      ["enabled"] = true,
			      ["fade_out"] = 0.09,
			      ["absolute_sineX"] = false,
			      ["duration"] = 0.19999998807907,
			      ["absolute_sineY"] = true,
			      ["animation_type"] = "frameshake",
			      ["scaleX"] = 1,
			      ["amplitude"] = 1.1699999570847,
			      ["critical_scale"] = 1.05,
			      ["fade_in"] = 0.0099999997764826,
			      ["scaleY"] = 0.88999938964844,
			      ["cooldown"] = 0.5,
			      ["frequency"] = 23.525676727295,
			   },
			   [2] =  {
			      ["enabled"] = true,
			      ["scale_upX"] = 1.0499999523163,
			      ["animation_type"] = "scale",
			      ["cooldown"] = 0.75,
			      ["duration"] = 0.050000000745058,
			      ["scale_downY"] = 1,
			      ["scale_downX"] = 1,
			      ["scale_upY"] = 1.0499999523163,
			   },
			   ["info"] =  {
			      ["time"] = 1539293872,
			      ["class"] = "ROGUE",
			      ["spellid"] = 199804,
			      ["desc"] = "",
			   },
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
				},
				info = {
					time = 0,
					desc = "",
					class = "ROGUE",
					spellid = 5374,
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
				info = {
					time = 0,
					desc = "",
					class = "ROGUE",
					spellid = 245388,
				}
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
				info = {
					time = 0,
					desc = "",
					class = "MAGE",
					spellid = 30451,
				}
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
				info = {
					time = 0,
					desc = "",
					class = "MAGE",
					spellid = 7268,
				}
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
				info = {
					time = 0,
					desc = "",
					class = "MAGE",
					spellid = 44425,
				}
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
					critical_scale = 1,
				},
				info = {
					time = 0,
					desc = "",
					class = "MAGE",
					spellid = 228600,
				}
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
				info = {
					time = 0,
					desc = "",
					class = "MAGE",
					spellid = 228354,
				}
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
				info = {
					time = 0,
					desc = "",
					class = "MAGE",
					spellid = 228598,
				}
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
					critical_scale = 1,
				},
				info = {
					time = 0,
					desc = "",
					class = "MAGE",
					spellid = 11366,
				}
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
				info = {
					time = 0,
					desc = "",
					class = "MAGE",
					spellid = 31661,
				}
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
				info = {
					time = 0,
					desc = "",
					class = "MAGE",
					spellid = 108853,
				}
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
					critical_scale = 1,
				},
				info = {
					time = 0,
					desc = "",
					class = "PALADIN",
					spellid = 184575,
				}
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
					critical_scale = 1,
				},
				info = {
					time = 0,
					desc = "",
					class = "PALADIN",
					spellid = 53595,
				}
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
				info = {
					time = 0,
					desc = "",
					class = "PALADIN",
					spellid = 35395,
				}
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
					critical_scale = 1,
				},
				info = {
					time = 0,
					desc = "",
					class = "PALADIN",
					spellid = 31935,
				}
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
				info = {
					time = 0,
					desc = "",
					class = "PALADIN",
					spellid = 275779,
				}
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
				info = {
					time = 0,
					desc = "",
					class = "WARRIOR",
					spellid = 6343,
				}
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
					critical_scale = 1,
				},
				info = {
					time = 0,
					desc = "",
					class = "WARRIOR",
					spellid = 52174,
				}
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
				info = {
					time = 0,
					desc = "",
					class = "WARRIOR",
					spellid = 20243,
				}
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
				info = {
					time = 0,
					desc = "",
					class = "WARRIOR",
					spellid = 46968,
				}
			},
			
			--Death Strike (dk)
			[49998] = {
				[1] =  {
				   ["enabled"] = true,
				   ["fade_out"] = 0.019999999552965,
				   ["absolute_sineX"] = false,
				   ["absolute_sineY"] = false,
				   ["animation_type"] = "frameshake",
				   ["scaleX"] = 0.099998474121094,
				   ["duration"] = 0.050000000745058,
				   ["amplitude"] = 1.0330086946487,
				   ["fade_in"] = 0.01,
				   ["scaleY"] = 1,
				   ["cooldown"] = 0.5,
				   ["frequency"] = 25,
				},
				["info"] =  {
				   ["time"] = 0,
				   ["class"] = "DEATHKNIGHT",
				   ["spellid"] = 49998,
				   ["desc"] = "",
				},
			},
			
			--Frost Strike (dk)
			[222026] =  {
				[1] =  {
				   ["scale_upY"] = 1,
				   ["scale_upX"] = 1.0199999809265,
				   ["animation_type"] = "scale",
				   ["cooldown"] = 0.75,
				   ["enabled"] = true,
				   ["duration"] = 0.050000000745058,
				   ["scale_downX"] = 0.97999995946884,
				   ["scale_downY"] = 1,
				},
				[2] =  {
				   ["enabled"] = true,
				   ["fade_out"] = 0.1799999922514,
				   ["duration"] = 0.050000000745058,
				   ["absolute_sineY"] = true,
				   ["animation_type"] = "frameshake",
				   ["scaleX"] = 0,
				   ["absolute_sineX"] = false,
				   ["amplitude"] = 5.6999998092651,
				   ["fade_in"] = 0.0099999997764826,
				   ["scaleY"] = -1,
				   ["cooldown"] = 0.5,
				   ["frequency"] = 3.0999999046326,
				},
				["info"] =  {
				   ["time"] = 0,
				   ["class"] = "DEATHKNIGHT",
				   ["spellid"] = 222026,
				   ["desc"] = "",
				},
			},
			
			--breath of sindragosa
			[155166] = {
				{
					enabled = true,
					animation_type = "frameshake",
					scaleX = .2,
					scaleY = .6,
					absolute_sineX = false,
					absolute_sineY = false,
					duration = 0.2,
					amplitude = 0.45,
					frequency = 200,
					fade_in = 0.01,
					fade_out = 0.01,
					cooldown = 0.0,
				},
				info = {
					time = 0,
					desc = "",
					class = "DEATHKNIGHT",
					spellid = 155166,
				}
			},
			
			--Obliterate (dk)
			[222024] = {
				[1] =  {
				   ["enabled"] = true,
				   ["scale_upX"] = 1,
				   ["duration"] = 0.050000000745058,
				   ["scale_downX"] = 1,
				   ["scale_upY"] = 1.1000000238419,
				   ["critical_scale"] = 1,
				   ["animation_type"] = "scale",
				   ["cooldown"] = 0.75,
				   ["scale_downY"] = 0.89999997615814,
				},
				[2] =  {
				   ["enabled"] = true,
				   ["fade_out"] = 0.019999999552965,
				   ["duration"] = 0.050000000745058,
				   ["scaleY"] = 1,
				   ["absolute_sineY"] = true,
				   ["animation_type"] = "frameshake",
				   ["scaleX"] = 0,
				   ["critical_scale"] = 1,
				   ["amplitude"] = 1.7999999523163,
				   ["fade_in"] = 0.0099999997764826,
				   ["absolute_sineX"] = true,
				   ["cooldown"] = 0.5,
				   ["frequency"] = 11.14999961853,
				},
				["info"] =  {
				   ["time"] = 0,
				   ["class"] = "DEATHKNIGHT",
				   ["spellid"] = 222024,
				   ["desc"] = "",
				},
			},

			--Scourge Strike (dk)
			[55090] = {
				[1] =  {
				   ["enabled"] = true,
				   ["fade_out"] = 0.1799999922514,
				   ["absolute_sineX"] = false,
				   ["absolute_sineY"] = true,
				   ["animation_type"] = "frameshake",
				   ["scaleX"] = 1,
				   ["duration"] = 0.050000000745058,
				   ["amplitude"] = 3.9020702838898,
				   ["fade_in"] = 0.0099999997764826,
				   ["scaleY"] = 1,
				   ["cooldown"] = 0.5,
				   ["frequency"] = 3.7999999523163,
				},
				["info"] =  {
				   ["time"] = 0,
				   ["class"] = "DEATHKNIGHT",
				   ["spellid"] = 55090,
				   ["desc"] = "",
				},
			},
			
			--Festering Strike (dk)
			[85948] = {
				[1] =  {
				   ["enabled"] = true,
				   ["fade_out"] = 0.019999999552965,
				   ["absolute_sineX"] = false,
				   ["absolute_sineY"] = false,
				   ["animation_type"] = "frameshake",
				   ["scaleX"] = 0.099998474121094,
				   ["duration"] = 0.12000000476837,
				   ["amplitude"] = 1,
				   ["fade_in"] = 0.01,
				   ["scaleY"] = 1,
				   ["cooldown"] = 0.5,
				   ["frequency"] = 25,
				},
				["info"] =  {
				   ["time"] = 0,
				   ["class"] = "DEATHKNIGHT",
				   ["spellid"] = 85948,
				   ["desc"] = "",
				},
			},

			--Heart Strike (dk)
			[206930] = {
				[1] =  {
					["scale_upY"] = 1,
					["scale_upX"] = 1.0199999809265,
					["animation_type"] = "scale",
					["cooldown"] = 0.75,
					["enabled"] = true,
					["duration"] = 0.050000000745058,
					["scale_downX"] = 0.97999995946884,
					["scale_downY"] = 1,
				},
				[2] =  {
					["enabled"] = true,
					["fade_out"] = 0.1799999922514,
					["duration"] = 0.050000000745058,
					["absolute_sineY"] = true,
					["animation_type"] = "frameshake",
					["scaleX"] = 0,
					["absolute_sineX"] = false,
					["amplitude"] = 5.6999998092651,
					["fade_in"] = 0.0099999997764826,
					["scaleY"] = -1,
					["cooldown"] = 0.5,
					["frequency"] = 3.0999999046326,
				},
				["info"] =  {
					["time"] = 0,
					["class"] = "DEATHKNIGHT",
					["spellid"] = 222026,
					["desc"] = "",
				},
			},

			--Chi Burst (Monk)
			[148135] =  {
			   [1] =  {
			      ["enabled"] = true,
			      ["fade_out"] = 0.09,
			      ["absolute_sineX"] = false,
			      ["duration"] = 0.099999994039536,
			      ["absolute_sineY"] = false,
			      ["animation_type"] = "frameshake",
			      ["scaleX"] = 1,
			      ["amplitude"] = 1.75,
			      ["critical_scale"] = 1.05,
			      ["fade_in"] = 0.01,
			      ["scaleY"] = 1,
			      ["cooldown"] = 0.5,
			      ["frequency"] = 60.874122619629,
			   },
			   ["info"] =  {
			      ["time"] = 1539295958,
			      ["class"] = "MONK",
			      ["spellid"] = 148135,
			      ["desc"] = "",
			   },
			},

			--Blackout Strike (Monk)
			[205523] =  {
			   [1] =  {
			      ["enabled"] = true,
			      ["fade_out"] = 0.09,
			      ["absolute_sineX"] = false,
			      ["duration"] = 0.099999994039536,
			      ["absolute_sineY"] = false,
			      ["animation_type"] = "frameshake",
			      ["scaleX"] = 0.099998474121094,
			      ["amplitude"] = 3,
			      ["critical_scale"] = 1.05,
			      ["fade_in"] = 0.01,
			      ["scaleY"] = 1,
			      ["cooldown"] = 0.5,
			      ["frequency"] = 1,
			   },
			   ["info"] =  {
			      ["time"] = 1539295885,
			      ["class"] = "MONK",
			      ["spellid"] = 205523,
			      ["desc"] = "",
			   },
			},

			--Tiger Palm (Monk)
			[100780] =  {
			   [1] =  {
			      ["enabled"] = true,
			      ["fade_out"] = 0.09,
			      ["absolute_sineX"] = false,
			      ["duration"] = 0.099999994039536,
			      ["absolute_sineY"] = false,
			      ["animation_type"] = "frameshake",
			      ["scaleX"] = 0.1,
			      ["amplitude"] = 1,
			      ["critical_scale"] = 1.05,
			      ["fade_in"] = 0.01,
			      ["scaleY"] = 1,
			      ["cooldown"] = 0.5,
			      ["frequency"] = 1,
			   },
			   ["info"] =  {
			      ["time"] = 1539295910,
			      ["class"] = "MONK",
			      ["spellid"] = 100780,
			      ["desc"] = "",
			   },
			},
			
			--Blackout Kick (Monk)
			[100784] =  {
			   [1] =  {
			      ["enabled"] = true,
			      ["fade_out"] = 0.09,
			      ["absolute_sineX"] = false,
			      ["duration"] = 0.099999994039536,
			      ["absolute_sineY"] = false,
			      ["animation_type"] = "frameshake",
			      ["scaleX"] = 1,
			      ["amplitude"] = 3,
			      ["critical_scale"] = 1.05,
			      ["fade_in"] = 0.01,
			      ["scaleY"] = 1,
			      ["cooldown"] = 0.5,
			      ["frequency"] = 1,
			   },
			   ["info"] =  {
			      ["time"] = 1539296312,
			      ["class"] = "MONK",
			      ["spellid"] = 100784,
			      ["desc"] = "",
			   },
			},

			--Spinning Crane Kick (Monk)
			[107270] =  {
			   [1] =  {
			      ["enabled"] = true,
			      ["fade_out"] = 0.089999996125698,
			      ["duration"] = 0.1499999910593,
			      ["absolute_sineX"] = false,
			      ["absolute_sineY"] = false,
			      ["animation_type"] = "frameshake",
			      ["scaleX"] = 0.099998474121094,
			      ["amplitude"] = 0.1499999910593,
			      ["critical_scale"] = 1.05,
			      ["fade_in"] = 0.0099999997764826,
			      ["scaleY"] = 1,
			      ["cooldown"] = 0.5,
			      ["frequency"] = 200,
			   },
			   ["info"] =  {
			      ["spellid"] = 107270,
			      ["class"] = "MONK",
			      ["time"] = 1539296490,
			      ["desc"] = "",
			   },
			},


			--Fists of Fury (Monk)
			[117418] =  {
			   [1] =  {
			      ["scaleY"] = 1,
			      ["fade_out"] = 0.1499999910593,
			      ["absolute_sineX"] = false,
			      ["duration"] = 0.1799999922514,
			      ["absolute_sineY"] = false,
			      ["animation_type"] = "frameshake",
			      ["scaleX"] = 0.099998474121094,
			      ["enabled"] = true,
			      ["amplitude"] = 0.1499999910593,
			      ["fade_in"] = 0.0099999997764826,
			      ["critical_scale"] = 1.05,
			      ["cooldown"] = 0.5,
			      ["frequency"] = 116.00999450684,
			   },
			   ["info"] =  {
			      ["time"] = 1539296387,
			      ["class"] = "MONK",
			      ["spellid"] = 117418,
			      ["desc"] = "",
			   },
			},

			
			--Rising Sun Kick (Monk)
			[185099] =  {
			   [1] =  {
			      ["enabled"] = true,
			      ["fade_out"] = 0.18999999761581,
			      ["absolute_sineX"] = false,
			      ["duration"] = 0.19999998807907,
			      ["absolute_sineY"] = true,
			      ["animation_type"] = "frameshake",
			      ["scaleX"] = 0,
			      ["amplitude"] = 3,
			      ["critical_scale"] = 1.05,
			      ["fade_in"] = 0,
			      ["scaleY"] = 0.84999847412109,
			      ["cooldown"] = 0.5,
			      ["frequency"] = 1,
			   },
			   ["info"] =  {
			      ["time"] = 1539712435,
			      ["class"] = "MONK",
			      ["spellid"] = 185099,
			      ["desc"] = "",
			   },
			},
			
			--Blade Dance (Demon Hunter)
			[199552] =  {
			   [1] =  {
			      ["enabled"] = true,
			      ["fade_out"] = 0.099999994039536,
			      ["duration"] = 0.099999994039536,
			      ["absolute_sineX"] = true,
			      ["absolute_sineY"] = false,
			      ["animation_type"] = "frameshake",
			      ["scaleX"] = 0.20000076293945,
			      ["critical_scale"] = 1.05,
			      ["amplitude"] = 2.5,
			      ["fade_in"] = 0,
			      ["scaleY"] = 0.79999923706055,
			      ["cooldown"] = 0.5,
			      ["frequency"] = 1,
			   },
			   [2] =  {
			      ["enabled"] = true,
			      ["scale_upX"] = 1.0299999713898,
			      ["animation_type"] = "scale",
			      ["scale_downX"] = 0.96999996900559,
			      ["scale_downY"] = 0.96999996900559,
			      ["duration"] = 0.05,
			      ["cooldown"] = 0.75,
			      ["scale_upY"] = 1.0299999713898,
			   },
			   ["info"] =  {
			      ["spellid"] = 199552,
			      ["class"] = "DEMONHUNTER",
			      ["time"] = 1539717392,
			      ["desc"] = "",
			   },
			},
			--Chaos Strike (Demon Hunter)
			[199547] =  {
			   [1] =  {
			      ["enabled"] = true,
			      ["fade_out"] = 0.089999996125698,
			      ["absolute_sineX"] = false,
			      ["duration"] = 0.1,
			      ["absolute_sineY"] = true,
			      ["animation_type"] = "frameshake",
			      ["scaleX"] = 0.59999847412109,
			      ["amplitude"] = 3,
			      ["critical_scale"] = 1.05,
			      ["fade_in"] = 0.0099999997764826,
			      ["scaleY"] = 1,
			      ["cooldown"] = 0.5,
			      ["frequency"] = 1,
			   },
			   [2] =  {
			      ["enabled"] = true,
			      ["scale_upX"] = 1.039999961853,
			      ["animation_type"] = "scale",
			      ["cooldown"] = 0.75,
			      ["duration"] = 0.05,
			      ["scale_downY"] = 0.96999996900558,
			      ["scale_downX"] = 0.96999996900558,
			      ["scale_upY"] = 1.039999961853,
			   },
			   ["info"] =  {
			      ["time"] = 1539717795,
			      ["class"] = "DEMONHUNTER",
			      ["spellid"] = 199547,
			      ["desc"] = "",
			   },
			},
			--Demon's Bite (Demon Hunter)
			[162243] =  {
			   [1] =  {
			      ["enabled"] = true,
			      ["fade_out"] = 0.089999996125698,
			      ["duration"] = 0.099999994039535,
			      ["absolute_sineX"] = false,
			      ["absolute_sineY"] = true,
			      ["animation_type"] = "frameshake",
			      ["scaleX"] = 0.099998474121094,
			      ["critical_scale"] = 1.05,
			      ["amplitude"] = 1,
			      ["fade_in"] = 0.0099999997764826,
			      ["scaleY"] = 1,
			      ["cooldown"] = 0.5,
			      ["frequency"] = 1,
			   },
			   ["info"] =  {
			      ["spellid"] = 162243,
			      ["class"] = "DEMONHUNTER",
			      ["time"] = 1539717356,
			      ["desc"] = "",
			   },
			},
			--Eye Beam (Demon Hunter)
			[198030] =  {
			   [1] =  {
			      ["enabled"] = true,
			      ["fade_out"] = 0.089999996125698,
			      ["duration"] = 0.31999999284744,
			      ["absolute_sineX"] = false,
			      ["absolute_sineY"] = false,
			      ["animation_type"] = "frameshake",
			      ["scaleX"] = 0.099998474121094,
			      ["critical_scale"] = 1.05,
			      ["amplitude"] = 0.5,
			      ["fade_in"] = 0.0099999997764826,
			      ["scaleY"] = 1,
			      ["cooldown"] = 0.5,
			      ["frequency"] = 200,
			   },
			   ["info"] =  {
			      ["spellid"] = 198030,
			      ["class"] = "DEMONHUNTER",
			      ["time"] = 1539717136,
			      ["desc"] = "",
			   },
			},
			--Infernal Strike (Demon Hunter)
			[189112] =  {
			   [1] =  {
			      ["enabled"] = true,
			      ["fade_out"] = 0.34999999403954,
			      ["duration"] = 0.40000000596046,
			      ["absolute_sineX"] = true,
			      ["absolute_sineY"] = true,
			      ["animation_type"] = "frameshake",
			      ["scaleX"] = 0,
			      ["amplitude"] = 1.8799999952316,
			      ["critical_scale"] = 1.05,
			      ["fade_in"] = 0,
			      ["scaleY"] = 1,
			      ["cooldown"] = 0.5,
			      ["frequency"] = 51.979999542236,
			   },
			   ["info"] =  {
			      ["time"] = 1539715467,
			      ["class"] = "DEMONHUNTER",
			      ["spellid"] = 189112,
			      ["desc"] = "",
			   },
			},
			--Shear (Demon Hunter)
			[203782] =  {
			   [1] =  {
			      ["enabled"] = true,
			      ["fade_out"] = 0.089999996125698,
			      ["duration"] = 0.099999994039536,
			      ["absolute_sineX"] = true,
			      ["absolute_sineY"] = false,
			      ["animation_type"] = "frameshake",
			      ["scaleX"] = 0,
			      ["critical_scale"] = 1.05,
			      ["amplitude"] = 1.5,
			      ["fade_in"] = 0.0099999997764826,
			      ["scaleY"] = -1,
			      ["cooldown"] = 0.5,
			      ["frequency"] = 1,
			   },
			   ["info"] =  {
			      ["spellid"] = 203782,
			      ["class"] = "DEMONHUNTER",
			      ["time"] = 1539716639,
			      ["desc"] = "",
			   },
			},
			--Soul Cleave (Demon Hunter)
			[228478] =  {
			   [1] =  {
			      ["enabled"] = true,
			      ["fade_out"] = 0.099999994039536,
			      ["duration"] = 0.099999994039535,
			      ["absolute_sineX"] = true,
			      ["absolute_sineY"] = false,
			      ["animation_type"] = "frameshake",
			      ["scaleX"] = 0.20000076293945,
			      ["critical_scale"] = 1.05,
			      ["amplitude"] = 2.5,
			      ["fade_in"] = 0,
			      ["scaleY"] = 0.79999923706055,
			      ["cooldown"] = 0.5,
			      ["frequency"] = 1,
			   },
			   [2] =  {
			      ["animation_type"] = "scale",
			      ["scale_upX"] = 1.0299999713898,
			      ["scale_upY"] = 1.0299999713898,
			      ["scale_downX"] = 0.96999996900559,
			      ["scale_downY"] = 0.96999996900559,
			      ["duration"] = 0.05,
			      ["cooldown"] = 0.75,
			      ["enabled"] = true,
			   },
			   ["info"] =  {
			      ["spellid"] = 228478,
			      ["class"] = "DEMONHUNTER",
			      ["time"] = 1539716636,
			      ["desc"] = "",
			   },
			},
			--Throw Glaive (Demon Hunter)
			[204157] =  {
			   [1] =  {
			      ["enabled"] = true,
			      ["fade_out"] = 0.089999996125698,
			      ["duration"] = 0.1,
			      ["absolute_sineX"] = false,
			      ["absolute_sineY"] = true,
			      ["animation_type"] = "frameshake",
			      ["scaleX"] = 1,
			      ["critical_scale"] = 1.05,
			      ["amplitude"] = 6,
			      ["fade_in"] = 0.0099999997764826,
			      ["scaleY"] = 1,
			      ["cooldown"] = 0.5,
			      ["frequency"] = 1,
			   },
			   [2] =  {
			      ["animation_type"] = "scale",
			      ["scale_upX"] = 1.03,
			      ["scale_upY"] = 1.03,
			      ["scale_downX"] = 0.97,
			      ["scale_downY"] = 0.97,
			      ["duration"] = 0.05,
			      ["cooldown"] = 0.75,
			      ["enabled"] = true,
			   },
			   ["info"] =  {
			      ["spellid"] = 204157,
			      ["class"] = "DEMONHUNTER",
			      ["time"] = 1539716637,
			      ["desc"] = "",
			   },
			},

			--multi shot (hunter)
			[2643] = {
				{
					enabled = true,
					animation_type = "frameshake",
					scaleX = .2,
					scaleY = .6,
					absolute_sineX = false,
					absolute_sineY = false,
					duration = 0.2,
					amplitude = 0.45,
					frequency = 200,
					fade_in = 0.01,
					fade_out = 0.01,
					cooldown = 0.0,
				},
				info = {
					time = 0,
					desc = "",
					class = "HUNTER",
					spellid = 2643,
				}
			},

			--kill shot (hunter)
			[53351] = {
				[1] =  {
				   ["scale_upY"] = 1,
				   ["scale_upX"] = 1.0199999809265,
				   ["animation_type"] = "scale",
				   ["cooldown"] = 0.75,
				   ["enabled"] = true,
				   ["duration"] = 0.050000000745058,
				   ["scale_downX"] = 0.97999995946884,
				   ["scale_downY"] = 1,
				},
				[2] =  {
				   ["enabled"] = true,
				   ["fade_out"] = 0.1799999922514,
				   ["duration"] = 0.050000000745058,
				   ["absolute_sineY"] = true,
				   ["animation_type"] = "frameshake",
				   ["scaleX"] = 0,
				   ["absolute_sineX"] = false,
				   ["amplitude"] = 5.6999998092651,
				   ["fade_in"] = 0.0099999997764826,
				   ["scaleY"] = -1,
				   ["cooldown"] = 0.5,
				   ["frequency"] = 3.0999999046326,
				},
				["info"] =  {
				   ["time"] = 0,
				   ["class"] = "HUNTER",
				   ["spellid"] = 53351,
				   ["desc"] = "",
				},
			},

			[257045] = {
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
				info = {
					time = 0,
					desc = "",
					class = "HUNTER",
					spellid = 257045,
				}
			},

			--carve (hunter)
			[187708] = {
				{
					enabled = true,
					animation_type = "frameshake",
					scaleX = .2,
					scaleY = .6,
					absolute_sineX = false,
					absolute_sineY = false,
					duration = 0.2,
					amplitude = 0.45,
					frequency = 200,
					fade_in = 0.01,
					fade_out = 0.01,
					cooldown = 0.0,
				},
				info = {
					time = 0,
					desc = "",
					class = "HUNTER",
					spellid = 187708,
				}
			},

			--wild fire bomb (hunter)
			[265157] = {
				[1] =  {
				   ["enabled"] = true,
				   ["scale_upX"] = 1,
				   ["duration"] = 0.096889182925224,
				   ["scale_downX"] = 1,
				   ["scale_upY"] = 1.1000000238419,
				   ["critical_scale"] = 1,
				   ["animation_type"] = "scale",
				   ["cooldown"] = 0.75,
				   ["scale_downY"] = 0.89999997615814,
				},
				[2] =  {
				   ["enabled"] = true,
				   ["fade_out"] = 0.019999999552965,
				   ["duration"] = 0.099999994039536,
				   ["scaleY"] = 1,
				   ["absolute_sineY"] = false,
				   ["animation_type"] = "frameshake",
				   ["scaleX"] = 1,
				   ["critical_scale"] = 1,
				   ["amplitude"] = 0.50999999046326,
				   ["fade_in"] = 0.0099999997764826,
				   ["absolute_sineX"] = false,
				   ["cooldown"] = 0.5,
				   ["frequency"] = 39.995635986328,
				},
				["info"] =  {
				   ["time"] = 0,
				   ["class"] = "HUNTER",
				   ["spellid"] = 265157,
				   ["desc"] = "",
				},
			},

			--chain lightining (shaman)
			[188443] = {
				{
					enabled = true,
					animation_type = "frameshake",
					scaleX = .2,
					scaleY = .6,
					absolute_sineX = false,
					absolute_sineY = false,
					duration = 0.2,
					amplitude = 0.45,
					frequency = 200,
					fade_in = 0.01,
					fade_out = 0.01,
					cooldown = 0.0,
				},
				info = {
					time = 0,
					desc = "",
					class = "SHAMAN",
					spellid = 188443,
				}
			},

			--lava burst
			[285452] = {
				[1] =  {
				   ["scale_upY"] = 1,
				   ["scale_upX"] = 1.0199999809265,
				   ["animation_type"] = "scale",
				   ["cooldown"] = 0.75,
				   ["enabled"] = true,
				   ["duration"] = 0.050000000745058,
				   ["scale_downX"] = 0.97999995946884,
				   ["scale_downY"] = 1,
				},
				[2] =  {
				   ["enabled"] = true,
				   ["fade_out"] = 0.1799999922514,
				   ["duration"] = 0.050000000745058,
				   ["absolute_sineY"] = true,
				   ["animation_type"] = "frameshake",
				   ["scaleX"] = 0,
				   ["absolute_sineX"] = false,
				   ["amplitude"] = 5.6999998092651,
				   ["fade_in"] = 0.0099999997764826,
				   ["scaleY"] = -1,
				   ["cooldown"] = 0.5,
				   ["frequency"] = 3.0999999046326,
				},
				["info"] =  {
				   ["time"] = 0,
				   ["class"] = "SHAMAN",
				   ["spellid"] = 285452,
				   ["desc"] = "",
				},
			},

			--earth shock (shamam)
			[8042] = {
				[1] =  {
				   ["scale_upY"] = 1.05,
				   ["scale_upX"] = 1.05,
				   ["animation_type"] = "scale",
				   ["cooldown"] = 0.75,
				   ["enabled"] = true,
				   ["duration"] = 0.060000000745058,
				   ["scale_downX"] = 0.95,
				   ["scale_downY"] = 0.95,
				},
				[2] =  {
				   ["enabled"] = true,
				   ["fade_out"] = 0.05,
				   ["duration"] = 0.06,
				   ["absolute_sineY"] = true,
				   ["animation_type"] = "frameshake",
				   ["scaleX"] = 0,
				   ["absolute_sineX"] = false,
				   ["amplitude"] = 7.5,
				   ["fade_in"] = 0.0099999997764826,
				   ["scaleY"] = -1,
				   ["cooldown"] = 0.5,
				   ["frequency"] = 3.0999999046326,
				},
				["info"] =  {
				   ["time"] = 0,
				   ["class"] = "SHAMAN",
				   ["spellid"] = 285452,
				   ["desc"] = "",
				},
			},

			--crash lightning (shaman)
			[187874] = {
				{
					enabled = true,
					animation_type = "frameshake",
					scaleX = .2,
					scaleY = .6,
					absolute_sineX = false,
					absolute_sineY = false,
					duration = 0.2,
					amplitude = 0.85,
					frequency = 100,
					fade_in = 0.01,
					fade_out = 0.01,
					cooldown = 0.0,
				},
				info = {
					time = 0,
					desc = "",
					class = "SHAMAN",
					spellid = 187874,
				}
			},

			--stormstrike (shaman)
			[17364] = {
				[1] =  {
				   ["scale_upY"] = 1.02,
				   ["scale_upX"] = 1.02,
				   ["animation_type"] = "scale",
				   ["cooldown"] = 0.75,
				   ["enabled"] = true,
				   ["duration"] = 0.10000000745058,
				   ["scale_downX"] = 0.97,
				   ["scale_downY"] = 0.97,
				},
				[2] =  {
				   ["enabled"] = true,
				   ["fade_out"] = 0.11,
				   ["duration"] = 0.1,
				   ["absolute_sineY"] = true,
				   ["animation_type"] = "frameshake",
				   ["scaleX"] = 0,
				   ["absolute_sineX"] = false,
				   ["amplitude"] = 2.5,
				   ["fade_in"] = 0,
				   ["scaleY"] = -1,
				   ["cooldown"] = 0.5,
				   ["frequency"] = 3.0999999046326,
				},
				["info"] =  {
				   ["time"] = 0,
				   ["class"] = "SHAMAN",
				   ["spellid"] = 17364,
				   ["desc"] = "",
				},
			},

		},
		
		health_statusbar_texture = "You Are Beautiful!",
		
		health_selection_overlay = "Details Flat",
		health_selection_overlay_alpha = 0.1,
		health_selection_overlay_color = {1, 1, 1, 1},
		
		health_statusbar_bgtexture = "PlaterBackground 2",
		health_statusbar_bgcolor = {0.113725, 0.113725, 0.113725, 0.89000000},
		
		cast_statusbar_quickhide = false,
		cast_statusbar_texture = "Details Flat",
		cast_statusbar_bgtexture = "PlaterBackground 2",
		cast_statusbar_bgcolor = {0.113725, 0.113725, 0.113725, 0.891240},
		cast_statusbar_color = {1, .7, 0, 0.96},
		cast_statusbar_color_channeling = {0, 1, 0, 0.96},
		cast_statusbar_color_nointerrupt = {.5, .5, .5, 0.96},
		cast_statusbar_color_interrupted = {1, .1, .1, 1},
		cast_statusbar_color_finished = {0, 1, 0, 1},
		cast_statusbar_fadein_time = 0.02,
		cast_statusbar_fadeout_time = 0.5,
		cast_statusbar_use_fade_effects = true,
		cast_statusbar_spark_texture = [[Interface\AddOns\Plater\images\spark1]],
		cast_statusbar_spark_hideoninterrupt = true,
		cast_statusbar_spark_filloninterrupt = true,
		cast_statusbar_spark_width = 12,
		cast_statusbar_spark_offset = 0,
		cast_statusbar_spark_half = false,
		cast_statusbar_spark_alpha = 0.834,
		cast_statusbar_spark_color = {1, 1, 1, 1},

		cast_statusbar_interrupt_anim = true,
		
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
		
		color_override = true,
		color_override_colors = {
			[UNITREACTION_HOSTILE] = {0.9176470, 0.1294117, 0.0705882, 1},
			[UNITREACTION_NEUTRAL] = {0.9254901, 0.8, 0.2666666, 1},
			[UNITREACTION_FRIENDLY] = {0.023529, 0.823529, 0.023518, 1},
		},
		
		border_color = {0, 0, 0, .834},
		border_thickness = 1,
		
		focus_indicator_enabled = true,
		focus_color = {0, 0, 0, 0.5},
		focus_texture = "PlaterFocus",
		
		tap_denied_color = {.9, .9, .9, 1},
		
		aggro_modifies = {
			health_bar_color = true,
			border_color = false,
			actor_name_color = false,
		},
		
		aggro_can_check_notank = false,
		tank_threat_colors = false,
		
		show_aggro_flash = false,
		show_aggro_glow = true,
		
		tank = {
			colors = {
				aggro = {.5, .5, 1, 1},
				noaggro = {1, 0, 0, 1},
				pulling = {1, 1, 0, 1},
				nocombat = {0.505, 0.003, 0, 1},
				anothertank = {0.729, 0.917, 1, 1},
				pulling_from_tank = {1, .7, 0, 1}, --color when a tank is pulling the aggro from another tank
			},
		},
		
		dps = {
			colors = {
				aggro = {1, 0.109803, 0, 1},
				solo = {.5, .5, 1, 1},
				noaggro = {.5, .5, 1, 1},
				pulling = {1, .8, 0, 1},
				notontank = {.5, .5, 1, 1}, --color inside dungeon when the mob is not in the tank aggro and not on the player
			},
			use_aggro_solo = false,
		},
		
		news_frame = {},
		first_run2 = false,
	}
}
