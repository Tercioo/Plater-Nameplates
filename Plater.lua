  if (true) then
	--return
	--but not today
end

--details! framework
local DF = _G ["DetailsFramework"]
if (not DF) then
	print ("|cFFFFAA00Plater: framework not found, if you just installed or updated the addon, please restart your client.|r")
	return
end

local unpack = unpack
local ipairs = ipairs
local pairs = pairs
local GetCVar = GetCVar
local SetCVar = SetCVar
local InCombatLockdown = InCombatLockdown
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local CompareBit = bit.band
local UnitIsPlayer = UnitIsPlayer
local UnitClassification = UnitClassification
local UnitDetailedThreatSituation = UnitDetailedThreatSituation
local UnitAura = UnitAura

local abs = math.abs
local format = string.format

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
LibSharedMedia:Register ("statusbar", "DGround", [[Interface\AddOns\Plater\images\bar_background]])
LibSharedMedia:Register ("statusbar", "PlaterBackground", [[Interface\AddOns\Plater\images\platebackground]])
LibSharedMedia:Register ("statusbar", "PlaterTexture", [[Interface\AddOns\Plater\images\platetexture]])
LibSharedMedia:Register ("statusbar", "PlaterHighlight", [[Interface\AddOns\Plater\images\plateselected]])

LibSharedMedia:Register ("statusbar", "testbar", [[Interface\AddOns\Plater\images\testbar.tga]])
--LibSharedMedia:Register ("statusbar", "testbarBLP", [[Interface\AddOns\Plater\images\testbar]])

LibSharedMedia:Register ("font", "Oswald", [[Interface\Addons\Plater\fonts\Oswald-Regular.otf]])
LibSharedMedia:Register ("font", "Nueva Std Cond", [[Interface\Addons\Plater\fonts\NuevaStd-Cond.otf]])
LibSharedMedia:Register ("font", "Accidental Presidency", [[Interface\Addons\Plater\fonts\Accidental Presidency.ttf]])
LibSharedMedia:Register ("font", "TrashHand", [[Interface\Addons\Plater\fonts\TrashHand.TTF]])
LibSharedMedia:Register ("font", "Harry P", [[Interface\Addons\Plater\fonts\HARRYP__.TTF]])
LibSharedMedia:Register ("font", "FORCED SQUARE", [[Interface\Addons\Plater\fonts\FORCED SQUARE.ttf]])

local _
local default_config = {
	
	profile = {
	
		click_space = {150, 45},
		click_space_always_show = false,
		
		plate_config  = {
			friendlyplayer = {
				enabled = true,
				plate_order = 3,
				only_damaged = false,
				
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
				spellpercent_text_shadow = false,
				spellpercent_text_anchor = {side = 11, x = -2, y = 0},
				
				level_text_enabled = false,
				level_text_anchor = {side = 7, x = 0, y = 1},
				level_text_size = 10,
				level_text_font = "Arial Narrow",
				level_text_shadow = false,
				level_text_alpha = 0.3,
				
				percent_text_enabled = false,
				percent_text_size = 9,
				percent_text_font = "Arial Narrow",
				percent_text_shadow = false,
				percent_text_color = {.9, .9, .9, 1},
				percent_text_anchor = {side = 9, x = 0, y = 0},
				percent_text_alpha = 1,
				percent_text_ooc = false,
			},
			enemyplayer = {
				enabled = true,
				plate_order = 3,
				
				health = {120, 2},
				health_incombat = {130, 10},
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
				spellpercent_text_shadow = false,
				spellpercent_text_anchor = {side = 11, x = -2, y = 0},
				
				level_text_enabled = true,
				level_text_anchor = {side = 7, x = 0, y = 1},
				level_text_size = 10,
				level_text_font = "Arial Narrow",
				level_text_shadow = false,
				level_text_alpha = 0.3,
				
				percent_text_enabled = true,
				percent_text_size = 9,
				percent_text_font = "Arial Narrow",
				percent_text_shadow = false,
				percent_text_color = {.9, .9, .9, 1},
				percent_text_anchor = {side = 9, x = 0, y = 0},
				percent_text_alpha = 1,
				percent_text_ooc = true,
			},
			friendlynpc = {
				enabled = true,
				only_relevant = true,
				relevant_and_proffesions = false,
				only_names = false,
				all_names = false,
				relevance_state = 1,
				plate_order = 3,
				
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
				spellpercent_text_shadow = false,
				spellpercent_text_anchor = {side = 11, x = -2, y = 0},
				
				level_text_enabled = false,
				level_text_anchor = {side = 7, x = 0, y = 1},
				level_text_size = 10,
				level_text_font = "Arial Narrow",
				level_text_shadow = false,
				level_text_alpha = 0.3,
				
				percent_text_enabled = false,
				percent_text_size = 9,
				percent_text_font = "Arial Narrow",
				percent_text_shadow = false,
				percent_text_color = {.9, .9, .9, 1},
				percent_text_anchor = {side = 9, x = 0, y = 0},
				percent_text_alpha = 1,
				percent_text_ooc = false,
				
				filter = {
					[1] = true, --"important npc"
					[2] = true, --repair"
					[3] = false, --merchant"
					[4] = false, --innkeeper"
					[5] = true, --banker"
					[6] = true, --autioneer"
					[7] = true, --flyght master"
					[8] = false, --stable master"
					[9] = false, --pet master"
					[10] = false, --barber"
					[11] = false, --transmogrifier"
					[12] = false, --food and drink"
					[20] = false, --fishing trainer"
					[21] = false, --first aid trainer"
					[22] = false, --archaeology trainer"
					[23] = false, --cooking trainer"
					[24] = false, --mining trainer"
					[25] = false, --engineering trainer"
					[26] = false, --leatherworking trainer"
					[27] = false, --tailor trainer"
					[28] = false, --enchanting trainer"
					[29] = false, --blacksmith trainer"
					[30] = false, --inscription trainer"
					[31] = false, --herbalism trainer"
					[32] = false, --skinning trainer"
					[33] = false, --alchemy trainer"
					[34] = false, --"jewelcrafting trainer"
				},
				
				quest_enabled = true,
				quest_color = {.5, 1, 0},
				
				big_actortitle_text_size = 11,
				big_actortitle_text_font = "Arial Narrow",
				big_actortitle_text_color = {1, .8, .0},
				big_actortitle_text_shadow = false,
				
				big_actorname_text_size = 9,
				big_actorname_text_font = "Arial Narrow",
				big_actorname_text_color = {.5, 1, .5},
				big_actorname_text_shadow = false,
			},
			enemynpc = {
				enabled = true,
				plate_order = 3,
				
				health = {120, 2},
				health_incombat = {130, 10},
				cast = {134, 12},
				cast_incombat = {134, 12},
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
				spellpercent_text_shadow = false,
				spellpercent_text_anchor = {side = 11, x = -2, y = 0},
				
				level_text_enabled = true,
				level_text_anchor = {side = 7, x = 0, y = 1},
				level_text_size = 8,
				level_text_font = "Arial Narrow",
				level_text_shadow = false,
				level_text_alpha = 0.3,
				
				percent_text_enabled = true,
				percent_text_size = 9,
				percent_text_font = "Arial Narrow",
				percent_text_shadow = false,
				percent_text_color = {.9, .9, .9, 1},
				percent_text_anchor = {side = 9, x = 0, y = 0},
				percent_text_alpha = 1,
				percent_text_ooc = false,
				
				quest_enabled = true,
				quest_color_enemy = {1, .369, 0},
				quest_color_neutral = {1, .65, 0},
			},
	
			player = {
				enabled = true,
				plate_order = 3,
				health = {150, 12},
				health_incombat = {150, 12},
				cast = {140, 8},
				cast_incombat = {140, 12},
				mana = {150, 8},
				mana_incombat = {150, 8},
				buff_frame_y_offset = 0,
				y_position_offset = -50,
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
			MONK = {
				chi_scale = 2,
			},
			MAGE = {
				arcane_charge_scale = 1,
			},
			DEATHKNIGHT = {
				rune_scale = 1,
			},
			PALADIN = {
				holypower_scale = 1,
			},
			ROGUE = {
				combopoint_scale = 1,
			},
			DRUID = {
				combopoint_scale = 1,
			},
			WARLOCK = {
				soulshard_scale = 1,
			},
		},

		aggro_tick_rate = 0.10000000,
		culling_distance = 100,
		use_playerclass_color = false,
		aura_width = 20,
		aura_height = 14,
		aura_timer = true,
		aura_custom = {},
		debuff_show_cc = true,
		
		target_highlight = true,
		target_highlight_alpha = .3,
		
		hover_highlight = true,
		hover_highlight_alpha = .3,
		
		health_statusbar_texture = "PlaterTexture", --"DGround"
		health_selection_overlay = "PlaterHighlight",
		health_statusbar_bgtexture = "PlaterBackground",
		health_statusbar_bgcolor = {1, 1, 1, 1},
		health_statusbar_bgalpha = 1,
		health_statusbar_bgalpha_selected = .7,
		
		cast_statusbar_texture = "DGround",
		cast_statusbar_bgtexture = "Details Serenity",
		cast_statusbar_bgcolor = {0, 0, 0, 0.8},
		
		friendlyplates_auto_show = false,
		friendlyplates_no_on_instances = true,
		enemyplates_only_combat = false,
		enemyplates_only_in_instances = false,
		
		indicator_faction = true,
		indicator_elite = true,
		indicator_rare = true,
		indicator_quest = true,
		indicator_anchor = {side = 2, x = -2, y = 0},
		
		border_color = {0, 0, 0, .15},

		not_affecting_combat_alpha = .5,
		
		tank = {
			colors = {
				aggro = {.5, .5, 1},
				noaggro = {1, 0, 0},
				pulling = {1, 1, 0},
				--nocombat = {0.698, 0.705, 1},
				nocombat = {0.380, 0.003, 0},
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
		
		first_run = false,
	}
}

local options_table = {
	name = "Plater Nameplates",
	type = "group",
	args = {
		
	}
}

local Plater = DF:CreateAddOn ("Plater", "PlaterDB", default_config, options_table)

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
}
Plater.DriverConfigType = {
	["FRIENDLY"] = "Friendly", 
	["ENEMY"] = "Enemy", 
	["PLAYER"] = "Player",
}
Plater.DriverConfigMembers = {
	["UseClassColors"] = "useClassColors",
}

--major
local CUF_Name = "CompactUnitFrame" --blizzard cuf
local NPF_Name = "NamePlateDriverFrame" --nameplate frame
local NPB_Name = "NameplateBuffContainerMixin" --nameplate buff
local CNP_Name = "CompactNamePlate" --compactnameplate
local CBF_Name = "CastingBarFrame" --castingbar
local BMX_Name = "NamePlateBorderTemplateMixin" --border mix-in
local MAB_Name = "ClassNameplateManaBarFrame" --mana bar

--minor
local STRING_DEFAULT = "Default"
local STRING_OPTIONS = "FrameOptions"

--const
local CVAR_SHOWPERSONAL = "nameplateShowSelf"
local CVAR_RESOURCEONTARGET = "nameplateResourceOnTarget"
local CVAR_SHOWALL = "nameplateShowAll"
local CVAR_CULLINGDISTANCE = "nameplateMaxDistance"
local CVAR_AGGROFLASH = "ShowNamePlateLoseAggroFlash"
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

local CVAR_ENABLED = "1"
local CVAR_DISABLED = "0"

local MEMBER_UNITID = "namePlateUnitToken"
local MEMBER_GUID = "namePlateUnitGUID"
local MEMBER_NPCTYPE = "namePlateNpcType"
local MEMBER_NPCID = "namePlateNpcId"
local MEMBER_QUEST = "namePlateIsQuestObjective"
local MEMBER_REACTION = "namePlateUnitReaction"

local UNITREACTION_HOSTILE = 3
local UNITREACTION_NEUTRAL = 4
local UNITREACTION_FRIENDLY = 5

local FILTER_DEBUFFS_BANNED = {}
local FILTER_BUFFS_BANNED = {}
local FILTER_BUFF_DETECTION = ""
local FILTER_BUFF_DETECTION2 = ""
local ALL_DEBUFFS = {}
local ALL_BUFFS = {}

local CAN_USE_AURATIMER = true

--> copied from blizzard code
local function IsPlayerEffectivelyTank()
	local assignedRole = UnitGroupRolesAssigned ("player");
	if ( assignedRole == "NONE" ) then
		local spec = GetSpecialization();
		return spec and GetSpecializationRole(spec) == "TANK";
	end
	return assignedRole == "TANK";
end
--copied from blizzard code
local function IsTapDenied (frame)
	return frame.optionTable.greyOutWhenTapDenied and not UnitPlayerControlled (frame.unit) and UnitIsTapDenied (frame.unit)
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

function Plater.InjectOnDefaultOptions (driverName, configType, configName, value)
	_G [STRING_DEFAULT .. driverName .. configType .. STRING_OPTIONS][configName] = value
end

function Plater.IsShowingResourcesOnTarget()
	return GetCVar (CVAR_SHOWPERSONAL) == CVAR_ENABLED and GetCVar (CVAR_RESOURCEONTARGET) == CVAR_ENABLED
end

local CrowdControl = {
	[33786] 	= true, -- Cyclone
	[339]	= true, -- Entangling Toots
	
	[3355]	= true, -- Freezing trap
	
	[118]	= true, -- Polymorph sheep
	[28272]	= true, -- Polymorph pig
	[126819]	= true, -- Polymorph pig 2
	[61305]	= true, -- Polymorph black cat
	[61721]	= true, -- Polymorph rabbit
	[61780]	= true, -- Polymorph turkey
	[28271]	= true, -- Polymorph turtle
	[161354]	= true, -- Polymorph Monkey
	[161353]	= true, -- Polymorph Polar Bear Cub
	[161355]	= true, -- Polymorph Penguin
	
	[115078]	= true, -- Paralysis
	
	[20066]	= true, -- Repentance
	
	[2094]	= true, -- Blind
	[6770]	= true, -- Sap
	
	[51514]	= true, -- Hex
}
local LocalizedCrowdControl = {}

function Plater.SpellIsCC (spellName)
	return LocalizedCrowdControl [spellName]
end

function Plater:RefreshConfig()
	Plater.UpdateAllPlates()
	if (PlaterOptionsPanelFrame) then
		PlaterOptionsPanelFrame.RefreshOptionsFrame()
	end
end

function Plater.OnInit()

	--C_Timer.After (1, Plater.OpenOptionsPanel)
	C_Timer.After (1, function()
		--Plater.OpenInterfaceProfile()
	end)
	
	--constrói a lista de cc
	for spellId, _ in pairs (CrowdControl) do
		local spellName = GetSpellInfo (spellId)
		LocalizedCrowdControl [spellName] = true
	end
	
	Plater:Msg (": |cFFFFFF00if you are seeing green bars instead, type /plater and change the textures to 'Blizzard Raid Bar'.|r")
	
	Plater.CombatTime = GetTime()
	
	if (OmniCC) then
		--CAN_USE_AURATIMER = false
	end

	Plater:RegisterEvent ("NAME_PLATE_CREATED")
	Plater:RegisterEvent ("NAME_PLATE_UNIT_ADDED")
	Plater:RegisterEvent ("NAME_PLATE_UNIT_REMOVED")
	Plater:RegisterEvent ("PLAYER_REGEN_DISABLED")
	Plater:RegisterEvent ("PLAYER_REGEN_ENABLED")
	Plater:RegisterEvent ("PLAYER_TARGET_CHANGED")
	Plater:RegisterEvent ("ZONE_CHANGED_NEW_AREA")
	Plater:RegisterEvent ("FRIENDLIST_UPDATE")
	Plater:RegisterEvent ("PLAYER_LOGOUT")
	Plater:RegisterEvent ("QUEST_ACCEPTED")
	Plater:RegisterEvent ("QUEST_ACCEPT_CONFIRM")
	Plater:RegisterEvent ("QUEST_COMPLETE")
	Plater:RegisterEvent ("QUEST_POI_UPDATE")
	Plater:RegisterEvent ("QUEST_QUERY_COMPLETE")
	Plater:RegisterEvent ("QUEST_DETAIL")
	Plater:RegisterEvent ("QUEST_FINISHED")
	Plater:RegisterEvent ("QUEST_GREETING")
	Plater:RegisterEvent ("QUEST_LOG_UPDATE")
	Plater:RegisterEvent ("UNIT_QUEST_LOG_CHANGED")

	--configuração do personagem
	PlaterDBChr = PlaterDBChr or {first_run = {}}
	PlaterDBChr.debuffsBanned = PlaterDBChr.debuffsBanned or {}
	PlaterDBChr.buffsBanned = PlaterDBChr.buffsBanned or {}
	
	FILTER_DEBUFFS_BANNED = PlaterDBChr.debuffsBanned
	FILTER_BUFFS_BANNED = PlaterDBChr.buffsBanned
	FILTER_BUFF_DETECTION = GetSpellInfo (203761)
	FILTER_BUFF_DETECTION2 = GetSpellInfo (213486)
	
	--verifica se é a primeira vez que rodou o addon no personagem
	local check_first_run = function()
		if (not UnitGUID ("player")) then
			C_Timer.After (1, Plater.CheckFirstRun)
			return
		end
		if (not Plater.db.profile.first_run) then
			Plater.db.profile.first_run = true
			C_Timer.After (15, Plater.SetCVarsOnFirstRun)
		elseif (not PlaterDBChr.first_run [UnitGUID ("player")]) then
			C_Timer.After (15, Plater.SetCVarsOnFirstRun)
		else
			Plater.ShutdownInterfaceOptionsPanel()
		end
	end
	function Plater.CheckFirstRun()
		check_first_run()
	end
	Plater.CheckFirstRun()

	C_Timer.After (4, Plater.UpdateCullingDistance)
	
	--seta a graça do jogador na barra dele --ajuda a evitar os 'desconhecidos' pelo cliente do jogo (frame da unidade)
	InstallHook (Plater.GetDriverSubObjectName (CUF_Name, Plater.DriverFuncNames.OnNameUpdate), function (self)
		if (self.healthBar.actorName) then
			self.healthBar.actorName:SetText (UnitName (self.unit))
			Plater.FormatTextForFriend (self:GetParent(), self.healthBar.actorName, self.name:GetText(), Plater.db.profile.plate_config [self:GetParent().actorType])
		end
	end)
	
	--quando trocar de target, da overwrite na textura de overlay do selected target (frame da unidade)
	InstallHook (Plater.GetDriverSubObjectName (CUF_Name, Plater.DriverFuncNames.OnSelectionUpdate), function (self)
		if (self.isNamePlate) then
			if (self.selectionHighlight:IsShown()) then
				local targetedOverlayTexture = LibSharedMedia:Fetch ("statusbar", Plater.db.profile.health_selection_overlay)
				self.selectionHighlight:SetTexture (targetedOverlayTexture)
				self.healthBar.background:SetAlpha (Plater.db.profile.health_statusbar_bgalpha_selected)
			else
				self.healthBar.background:SetAlpha (1)
			end
			Plater.UpdatePlateBorders()
		end
	end)

	InstallHook (Plater.GetDriverGlobalObject (BMX_Name), Plater.DriverFuncNames.OnBorderUpdate, function (self)
		Plater.UpdatePlateBorders (self.plateFrame)
	end)
	
	--sobrepõe a função que atualiza as auras
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
	InstallOverride (NPF_Name, Plater.DriverFuncNames.OnAuraUpdate, Override_UNIT_AURA_EVENT)
	
	local auraWatch = function (ticker)
		ticker.cooldown.Timer:SetText (floor (ticker.expireTime-GetTime()))
	end

	local BUFF_MAX_DISPLAY = BUFF_MAX_DISPLAY
	local CooldownFrame_Set = CooldownFrame_Set
	
	local AddAura = function (self, i, auraWidth, auraHeight, name, rank, texture, count, debuffType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId)
		if (not self.buffList[i]) then
			self.buffList[i] = CreateFrame ("Frame", self:GetParent():GetName() .. "Buff" .. i, self, "NameplateBuffButtonTemplate")
			self.buffList[i]:SetMouseClickEnabled(false)
			local timer = self.buffList[i].Cooldown:CreateFontString (nil, "overlay", "NumberFontNormal")
			self.buffList[i].Cooldown.Timer = timer
			timer:SetPoint ("center")
		end
		
		local buff = self.buffList [i]
		buff:SetID (i)
		buff.name = name
		buff.layoutIndex = i
		buff.Icon:SetTexture(texture)
		if (count > 1) then
			buff.CountFrame.Count:SetText (count)
			buff.CountFrame.Count:Show()
		else
			buff.CountFrame.Count:Hide()
		end
		
		buff:SetSize (auraWidth, auraHeight)
		buff.Icon:SetSize (auraWidth-2, auraHeight-2)
		
		if (buff.Cooldown.TimerTicker and not buff.Cooldown.TimerTicker._cancelled) then
			buff.Cooldown.TimerTicker:Cancel()
		end
		
		CooldownFrame_Set (buff.Cooldown, expirationTime - duration, duration, duration > 0, true)
		
		if (Plater.db.profile.aura_timer) then
			local timeLeft = expirationTime - GetTime()
			local ticker = C_Timer.NewTicker (.33, auraWatch, timeLeft*3)
			ticker.expireTime = expirationTime
			ticker.cooldown = buff.Cooldown
			buff.Cooldown.Timer:Show()
			buff.Cooldown.TimerTicker = ticker
			auraWatch (ticker)
		else
			buff.Cooldown.Timer:Hide()
		end
		
		buff:Show()
		return buff
	end
	
	local Override_UpdateBuffs = function (self, unit, filter)
		self.unit = unit
		self.filter = filter
		self:UpdateAnchor()
		
		local auraWidth = Plater.db.profile.aura_width
		local auraHeight = Plater.db.profile.aura_height
		local lastValidIndex = 1
		
		for i = 1, BUFF_MAX_DISPLAY do
			if (filter == "NONE" and self.buffList[i]) then
				self.buffList[i]:Hide()
				return
			end
			local name, rank, texture, count, debuffType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId = UnitAura (unit, i, filter)
			--retirada essa funcao  e apenas ira verificar o nome por enquanto
			--if (self:ShouldShowBuff(name, caster, nameplateShowPersonal, nameplateShowAll, duration)) then
			if (name and not FILTER_DEBUFFS_BANNED [spellId] and not FILTER_BUFFS_BANNED [spellId]) then
				AddAura (self, i, auraWidth, auraHeight, name, rank, texture, count, debuffType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId)
				lastValidIndex = i
			else
				if (self.buffList[i]) then
					self.buffList[i]:Hide()
				end
			end
		end
		
		for i = 1, #Plater.db.profile.aura_custom do
			local name, rank, texture, count, debuffType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId = UnitAura (unit, custom_auras[i].auraName)
			if (name) then
				local buff = AddAura (self, lastValidIndex, auraWidth, auraHeight, name, rank, texture, count, debuffType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId)
				if (custom_auras[i].border) then
					buff:SetBackdrop ({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1})
					buff:SetBackdropBorderColor (1, 1, 0, 1)
				end
				lastValidIndex = lastValidIndex + 1
			end
		end
		
		self:Layout()
	end
	--NameplateBuffContainerMixin.UpdateBuffs = Override_UpdateBuffs
	InstallOverride (NPB_Name, Plater.DriverFuncNames.OnUpdateBuffs, Override_UpdateBuffs)
	--buffcontainermixin é diferente de nameplate frame mixin
	
	--sobrepõe a função, economiza processamento uma vez que o resultado da função original não é usado
	local Override_UNIT_AURA_ANCHORUPDATE = function (self)
		if (self.Point1) then
			self:SetPoint (self.Point1, self.Anchor, self.Point2, self.X, self.Y)
		end
	end
	InstallOverride (NPB_Name, Plater.DriverFuncNames.OnUpdateAnchor, Override_UNIT_AURA_ANCHORUPDATE)
	
	--tamanho dos ícones dos debuffs sobre a nameplate
	function Plater.UpdateAuraIcons (self, unit, filter)
		local hasCC = false
		local show_cc = Plater.db.profile.debuff_show_cc
		local amtDebuffs = 0
		
		local auraWidth = Plater.db.profile.aura_width
		local auraHeight = Plater.db.profile.aura_height

		for _, buffFrame in ipairs (self.buffList) do
			if (buffFrame:IsShown()) then
				buffFrame:SetSize (auraWidth, auraHeight)
				buffFrame.Icon:SetSize (auraWidth-2, auraHeight-2)
				if (show_cc) then
					if (Plater.SpellIsCC (buffFrame.name)) then
						hasCC = buffFrame.name
					end
				end
				amtDebuffs = amtDebuffs + 1
			end
		end
		
		self.amtDebuffs = amtDebuffs
		Plater.UpdateBuffContainer (self:GetParent():GetParent())

		if (show_cc) then
			local UnitFrame = self:GetParent()
			if (hasCC) then
				UnitFrame.ExtraIcon1:Show()
				UnitFrame.ExtraIcon1Timer:Show()
				UnitFrame.ExtraIcon1:SetTexture ([[Interface\MINIMAP\Vehicle-Trap-Gold]])
				UnitFrame.hasCC = hasCC
			else
				if (UnitFrame.hasCC) then
					UnitFrame.ExtraIcon1:Hide()
					UnitFrame.ExtraIcon1Timer:Hide()
					UnitFrame.hasCC = false
				end
			end
		end
	end
	InstallHook (Plater.GetDriverGlobalObject (NPB_Name), Plater.DriverFuncNames.OnUpdateBuffs, Plater.UpdateAuraIcons)
	function Plater.RefreshAuras()
		for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do 
			Plater.UpdateAuraIcons (plateFrame.UnitFrame.BuffFrame)
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
	
	--1 debuff, health, castbar
	--2 health, buffs, castbar
	--3 castbar, health, buffs
	
	function Plater.UpdateBuffContainer (plateFrame)
		if ((plateFrame.UnitFrame.BuffFrame.amtDebuffs or 0) > 0) then
			--esta plate possui debuffs sendo mostrados
			Plater.PlateShowingDebuffFrame (plateFrame)
		else
			--esta plate não tem debuffs
			Plater.PlateNotShowingDebuffFrame (plateFrame)
		end
	end

	InstallHook (Plater.GetDriverGlobalObject (NPF_Name), Plater.DriverFuncNames.OnResourceUpdate, function (self, onTarget, resourceFrame)
	
		--atualiza o tamanho da barra de mana
		Plater.UpdateManaAndResourcesBar()
	
		if (not onTarget) then
			-- ele esta chamando duas vezes, uma com resources no alvo e outra não
			--ignorarando a que ele diz que não esta no alvo
			return
		end

		local plateFrame = C_NamePlate.GetNamePlateForUnit ("target")
		
		if (plateFrame) then
			local order = plateFrame.order
			if (order == 1) then
				NamePlateTargetResourceFrame:SetPoint ("BOTTOM", plateFrame.UnitFrame.name, "TOP", 0, 4);
			elseif (order == 2) then
				NamePlateTargetResourceFrame:SetPoint ("BOTTOM", plateFrame.UnitFrame.name, "TOP", 0, 4);
			elseif (order == 3) then
				Plater.UpdateBuffContainer (plateFrame)
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
	
	InstallHook (Plater.GetDriverSubObjectName (CBF_Name, Plater.DriverFuncNames.OnCastBarEvent), function (self, event, ...)
	
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
		
		if (event == "UNIT_SPELLCAST_START" and self.percentText) then
			local unitCast = unit
			if (unitCast ~= self.unit or not self.isNamePlate) then
				return
			end
			local name, nameSubtext, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible, arg10 = UnitCastingInfo (unitCast)
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
			
			self.ReUpdateNextTick = true
			
		elseif (event == "UNIT_SPELLCAST_CHANNEL_START" and self.percentText) then
			local unitCast = unit
			if (unitCast ~= self.unit or not self.isNamePlate) then
				return
			end
			local name, nameSubtext, text, texture, startTime, endTime, isTradeSkill, notInterruptible = UnitChannelInfo (unitCast)
			
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
			
			self.ReUpdateNextTick = true
		end
	end)
	
	InstallHook (Plater.GetDriverSubObjectName (CBF_Name, Plater.DriverFuncNames.OnTick), function (self, deltaTime)
		if (self.percentText) then --é uma castbar do plater?
			if (self.casting) then
				self.percentText:SetText (format ("%.1f", abs (self.value - self.maxValue)))
			elseif (self.channeling) then
				self.percentText:SetText (format ("%.1f", abs (self.value - self.maxValue)))
			else
				self.percentText:SetText ("")
			end
			
			if (self.ReUpdateNextTick) then
				self.BorderShield:ClearAllPoints()
				self.BorderShield:SetPoint ("center", self.Icon, "center")
				self.ReUpdateNextTick = nil
			end
		end
	end)

	InstallHook (Plater.GetDriverSubObjectName (CUF_Name, Plater.DriverFuncNames.OnUpdateHealth), function (self)
		local plateFrame = self:GetParent()
		if (plateFrame.isNamePlate) then
			if (plateFrame.isSelf) then
				local healthBar = self.healthBar
				local min, max = healthBar:GetMinMaxValues()
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
			else
				local currentHealth = UnitHealth (plateFrame [MEMBER_UNITID])
				self.healthBar:SetValue (currentHealth)
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
	
	InstallHook (Plater.GetDriverGlobalObject (NPF_Name), Plater.DriverFuncNames.OnOptionsUpdate, function()
		Plater.UpdateSelfPlate()
	end)
	InstallHook (Plater.GetDriverGlobalObject (MAB_Name), Plater.DriverFuncNames.OnManaBarOptionsUpdate, function()
		ClassNameplateManaBarFrame:SetSize (unpack (Plater.db.profile.plate_config.player.mana))
	end)

	--> ~db
	Plater.db.RegisterCallback (Plater, "OnProfileChanged", "RefreshConfig")
	Plater.db.RegisterCallback (Plater, "OnProfileCopied", "RefreshConfig")
	Plater.db.RegisterCallback (Plater, "OnProfileReset", "RefreshConfig")
	--Plater.db.RegisterCallback (Plater, "OnNewProfile", "RefreshConfig")
	--Plater.db.RegisterCallback (Plater, "OnProfileDeleted", "RefreshConfig")
	--Plater.db.RegisterCallback (Plater, "OnDatabaseReset", "RefreshConfig")
	
	Plater.UpdateSelfPlate()
	Plater.UpdateUseClassColors()
	C_Timer.After (4.1, Plater.QuestLogUpdated)
	C_Timer.After (5.1, Plater.UpdateAllPlates)
end

local re_update_self_plate = function()
	Plater.UpdateSelfPlate()
end
function Plater.UpdateSelfPlate()
	if (InCombatLockdown()) then
		return C_Timer.After (.3, re_update_self_plate)
	end
	C_NamePlate.SetNamePlateSelfSize (unpack (Plater.db.profile.plate_config.player.health))
	ClassNameplateManaBarFrame:SetSize (unpack (Plater.db.profile.plate_config.player.mana))
end

-- se o jogador estiver em combate, colorir a barra de acordo com o aggro do jogador ~aggro
function Plater.UpdateAggroPlates (self)

	if (not self.displayedUnit or UnitIsPlayer (self.displayedUnit) or Plater.petCache [self:GetParent() [MEMBER_GUID]] or self.displayedUnit:match ("pet%d$")) then
		--não computar aggro de jogadores inimigos
		--print ("ignorando plate:", self.displayedUnit)
		return
	end
	
	local isTanking, threatStatus = UnitDetailedThreatSituation ("player", self.displayedUnit)
	-- (3 = securely tanking, 2 = insecurely tanking, 1 = not tanking but higher threat than tank, 0 = not tanking and lower threat than tank)

	self.aggroGlowUpper:Hide()
	self.aggroGlowLower:Hide()
	self:SetAlpha (1)
	
	if (IsPlayerEffectivelyTank()) then --true or 
		--se o jogador é TANK

		if (not isTanking) then
			if (UnitAffectingCombat (self.displayedUnit)) then
				--não há aggro neste mob mas ele esta participando do combate
				Plater.ForceChangeHealthBarColor (self.healthBar, unpack (Plater.db.profile.tank.colors.noaggro))
			else
				--náo ha aggro e ele não esta participando do combate
				if (self [MEMBER_REACTION] == 4) then
					--o mob é um npc neutro, apenas colorir com a cor neutra
					Plater.ForceChangeHealthBarColor (self.healthBar, 1, 1, 0)
				else
					Plater.ForceChangeHealthBarColor (self.healthBar, unpack (Plater.db.profile.tank.colors.nocombat))
				end
				
				self:SetAlpha (Plater.db.profile.not_affecting_combat_alpha)
			end
		else
			--o jogador esta tankando e:
			if (threatStatus == 3) then --esta tankando com segurança
				Plater.ForceChangeHealthBarColor (self.healthBar, unpack (Plater.db.profile.tank.colors.aggro))
			elseif (threatStatus == 2) then --esta tankando sem segurança
				Plater.ForceChangeHealthBarColor (self.healthBar, unpack (Plater.db.profile.tank.colors.pulling))
				self.aggroGlowUpper:Show()
				self.aggroGlowLower:Show()
			else --não esta tankando
				Plater.ForceChangeHealthBarColor (self.healthBar, unpack (Plater.db.profile.tank.colors.noaggro))
			end
		end
	else
		--o player é DPS
		
		if (isTanking) then
			--o jogador esta tankando como dps
			Plater.ForceChangeHealthBarColor (self.healthBar, unpack (Plater.db.profile.dps.colors.aggro))
			if (not self:GetParent().playerHasAggro) then
				self:GetParent().PlayAggroFlash()
			end
			self:GetParent().playerHasAggro = true
		else
			if (threatStatus == 3) then --o jogador esta tankando como dps
				Plater.ForceChangeHealthBarColor (self.healthBar, unpack (Plater.db.profile.dps.colors.aggro))
				if (not self:GetParent().playerHasAggro) then
					self:GetParent().PlayAggroFlash()
				end
				self:GetParent().playerHasAggro = true
			elseif (threatStatus == 2) then --esta tankando com pouco aggro
				Plater.ForceChangeHealthBarColor (self.healthBar, unpack (Plater.db.profile.dps.colors.aggro))
				self:GetParent().playerHasAggro = true
			elseif (threatStatus == 1) then --esta quase puxando o aggro
				Plater.ForceChangeHealthBarColor (self.healthBar, unpack (Plater.db.profile.dps.colors.pulling))
				self:GetParent().playerHasAggro = false
				self.aggroGlowUpper:Show()
				self.aggroGlowLower:Show()
				
			elseif (threatStatus == 0) then --não esta tankando
				Plater.ForceChangeHealthBarColor (self.healthBar, unpack (Plater.db.profile.dps.colors.noaggro))
				self:GetParent().playerHasAggro = false
			elseif (threatStatus == nil) then
				if (UnitAffectingCombat (self.displayedUnit)) then
					Plater.ForceChangeHealthBarColor (self.healthBar, unpack (Plater.db.profile.dps.colors.noaggro))
					self:GetParent().playerHasAggro = false
				else
				--	Plater.ForceChangeHealthBarColor (self.healthBar, unpack (Plater.db.profile.dps.colors.noaggro))
					self:GetParent().playerHasAggro = false
					self:SetAlpha (Plater.db.profile.not_affecting_combat_alpha)
				end
			end
		end
	end
end

-- ~ontick
local EventTickFunction = function (plateFrame, deltaTime)
	local unitFrame = plateFrame.UnitFrame
	
	--é realmente uma nameplate?
	if (not unitFrame.healthBar.barTexture or not unitFrame.unit) then
		return
	end
	
	unitFrame.name:Hide()
	
	if (plateFrame.UnitFrame.hasCC) then
		local name, rank, texture, count, debuffType, duration, expirationTime, caster, _, nameplateShowPersonal, spellId, _, _, _, nameplateShowAll = UnitDebuff (plateFrame.namePlateUnitToken, plateFrame.UnitFrame.hasCC)
		if (expirationTime and duration) then
			plateFrame.UnitFrame.ExtraIcon1Timer:SetText (floor (expirationTime - GetTime()))
		end
	end
	
	if (InCombatLockdown()) then
		--if (plateFrame.UpdateAggroTick < 0) then
			--é inimigo?
			if (plateFrame [MEMBER_REACTION] <= 4 and not IsTapDenied (unitFrame)) then
				--é um inimigo ou neutro
				Plater.UpdateAggroPlates (unitFrame)
			else
				--o proprio jogo seta a cor da barra aqui
			end
			
			if (Plater.db.profile.plate_config [plateFrame.actorType].percent_text_enabled) then
				Plater.UpdateLifePercentText (plateFrame.UnitFrame.healthBar.lifePercent, plateFrame.namePlateUnitToken)
			end
			
		--	plateFrame.UpdateAggroTick = Plater.db.profile.aggro_tick_rate
		--else
		--	plateFrame.UpdateAggroTick = plateFrame.UpdateAggroTick - deltaTime
		--end
	else
		--nao esta em combate, verifica se a porcetagem esta para mostrar fora de combate
		if (Plater.db.profile.plate_config [plateFrame.actorType].percent_text_enabled and Plater.db.profile.plate_config [plateFrame.actorType].percent_text_ooc) then
			Plater.UpdateLifePercentText (plateFrame.UnitFrame.healthBar.lifePercent, plateFrame.namePlateUnitToken)
			plateFrame.UnitFrame.healthBar.lifePercent:Show()
		end
	end
end

function Plater.UpdateAllNameplateColors()
	for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
		CompactUnitFrame_UpdateHealthColor (plateFrame.UnitFrame)
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
end
function Plater.UpdatePlateClickSpace (plateFrame, needReorder, isDebug, isConceal)
	if (plateFrame) then
		--if (isConceal) then
		--	if (Plater.CanChangePlateSize()) then
				
		--	end
		--	return
		--end
		if (Plater.db.profile.click_space_always_show) then
			Plater.SetPlateBackground (plateFrame)
		else
			plateFrame:SetBackdrop (nil)
		end
	end

	if (not plateFrame) then
		for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
			Plater.UpdatePlateClickSpace (plateFrame, true, isDebug)
		end
		return
	end
	local width, height = Plater.db.profile.click_space[1], Plater.db.profile.click_space[2]
	if (Plater.CanChangePlateSize()) then
		--ajusta o tamanho de uma unica barra
		plateFrame:SetSize (width, height)
		if (needReorder) then
			Plater.UpdatePlateFrame (plateFrame, plateFrame.actorType, plateFrame.order)
		end
		if (isDebug and not Plater.db.profile.click_space_always_show) then
			plateFrame:SetBackdrop ({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16, edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1})
			if (Plater.PlateSizeDebugTimer and not Plater.PlateSizeDebugTimer._cancelled) then
				Plater.PlateSizeDebugTimer:Cancel()
			end
			Plater.PlateSizeDebugTimer = C_Timer.NewTimer (3, shutdown_platesize_debug)
		end
	end
end

function Plater.UpdateAllPlates()
	for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
		Plater.UpdatePlateFrame (plateFrame)
	end
end

function Plater.GetAllShownPlates()
	return C_NamePlate.GetNamePlates()
end

function Plater:PLAYER_REGEN_DISABLED()
	C_Timer.After (0.5, Plater.UpdateAllPlates)
	Plater.CombatTime = GetTime()
	if (Plater.db.profile.enemyplates_only_in_instances and (Plater.zoneInstanceType == "party" or Plater.zoneInstanceType == "raid")) then
		return
	end
	if (not InCombatLockdown() and Plater.db.profile.enemyplates_only_combat) then
		SetCVar (CVAR_ENEMY_ALL, CVAR_ENABLED)
	end
end
function Plater:PLAYER_REGEN_ENABLED()
	C_Timer.After (0.5, Plater.UpdateAllPlates)
	if (Plater.db.profile.enemyplates_only_in_instances and (Plater.zoneInstanceType == "party" or Plater.zoneInstanceType == "raid")) then
		return
	end
	if (not InCombatLockdown() and Plater.db.profile.enemyplates_only_combat) then
		SetCVar (CVAR_ENEMY_ALL, CVAR_DISABLED)
	end
	Plater.UpdateAllNameplateColors()
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

	local do_flash_anim = function()
		if (not plateFrame.UnitFrame.healthBar.canHealthFlash) then
			return
		end
		plateFrame.UnitFrame.healthBar.canHealthFlash = false
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

	local do_flash_anim = function()
		if (Plater.CombatTime+5 > GetTime()) then
			return
		end
		f_anim:Show()
		animation:Play()
	end
	
	f_anim:Hide()
	plateFrame.PlayAggroFlash = do_flash_anim
end

function Plater.CanChangePlateSize()
	return not InCombatLockdown()
end

function Plater.FRIENDLIST_UPDATE()
	wipe (Plater.FriendsCache)
	for i = 1, GetNumFriends() do
		local toonName, level, class, area, connected, status, note = GetFriendInfo (i)
		if (connected and toonName) then
			Plater.FriendsCache [toonName] = true
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
				--verifica se já fechou a quantidade necessária pra esse npc
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
	wipe (Plater.QuestCache)
	local numEntries, numQuests = GetNumQuestLogEntries()
	for questId = 1, numEntries do
		local title, level, suggestedGroup, isHeader, isCollapsed, isComplete, frequency, questId, startEvent, displayQuestID, isOnMap, hasLocalPOI, isTask, isStory = GetQuestLogTitle (questId)
		if (type (questId) == "number" and questId > 0) then -- and not isComplete
			Plater.QuestCache [title] = true
		end
	end
	
	local mapId = GetCurrentMapAreaID()
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
	
	Plater.UpdateAllPlates()
end

function Plater.QuestLogUpdated()
	if (Plater.UpdateQuestCacheThrottle and not Plater.UpdateQuestCacheThrottle._cancelled) then
		Plater.UpdateQuestCacheThrottle:Cancel()
	end
	Plater.UpdateQuestCacheThrottle = C_Timer.NewTimer (2, update_quest_cache)
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

function Plater.FormatTextForFriend (plateFrame, actorNameString, playerName, plateConfigs)
	if (GetGuildInfo (plateFrame.UnitFrame.unit) == Plater.PlayerGuildName) then
		--DF:SetFontColor (actorNameString, "lime")
		DF:SetFontColor (actorNameString, "chartreuse")
		DF:SetFontOutline (actorNameString, false)
	end	
end

-- ~updatetext
function Plater.UpdatePlateText (plateFrame, plateConfigs)
	
	local spellnameString = plateFrame.UnitFrame.castBar.Text
	local spellPercentString = plateFrame.UnitFrame.castBar.percentText
	local nameString = plateFrame.UnitFrame.healthBar.actorName	
	local levelString = plateFrame.UnitFrame.healthBar.actorLevel
	local lifeString = plateFrame.UnitFrame.healthBar.lifePercent

	if (plateFrame.isSelf) then
		--se a barra for do proprio jogador não tem porque setar o nome
		nameString:SetText ("")
	else
		--pega o nome do actor
		local playerName = plateFrame.UnitFrame.name:GetText()
		
		--atualiza o nome do jogador
		DF:SetFontSize (nameString, plateConfigs.actorname_text_size)
		DF:SetFontFace (nameString, plateConfigs.actorname_text_font)
		DF:SetFontOutline (nameString, plateConfigs.actorname_text_shadow)
		
		Plater.FormatTextForFriend (plateFrame, nameString, playerName, plateConfigs)

		if (Plater.FriendsCache [playerName]) then
			DF:SetFontColor (nameString, "aqua")
			DF:SetFontOutline (nameString, false)
			plateFrame.isFriend = true
		else
			--DF:SetFontColor (nameString, plateConfigs.actorname_text_color)
			DF:SetFontColor (nameString, "white")
			if (plateFrame.isFriend) then
				DF:SetFontColor (nameString, "white")
				plateFrame.isFriend = nil
			end
		end
		
		Plater.SetAnchor (nameString, plateConfigs.actorname_text_anchor) --manda a tabela com .anchor .x e .y	
		
		--seta o nome na linha secundária
		if (plateFrame.shouldShowNpcNameAndTitle) then
			
			--> mostra todos os npcs
			if (plateConfigs.all_names) then
				--nome
				plateFrame.actorNameSolo:Show()
				plateFrame.actorNameSolo:SetText (UnitName (plateFrame [MEMBER_UNITID]))
				
				plateFrame.actorNameSolo:SetTextColor (unpack (plateConfigs.big_actorname_text_color))
				DF:SetFontSize (plateFrame.actorNameSolo, plateConfigs.big_actorname_text_size)
				DF:SetFontFace (plateFrame.actorNameSolo, plateConfigs.big_actorname_text_font)
				DF:SetFontOutline (plateFrame.actorNameSolo, plateConfigs.big_actorname_text_shadow)
				--profissão
				local subTitle = Plater.GetActorSubName (plateFrame)
				if (subTitle and subTitle ~= "" and not subTitle:match ("%d")) then
					plateFrame.actorSubTitleSolo:Show()
					plateFrame.actorSubTitleSolo:SetText ("<" .. subTitle .. ">")
					plateFrame.actorSubTitleSolo:ClearAllPoints()
					plateFrame.actorSubTitleSolo:SetPoint ("top", plateFrame.actorNameSolo, "bottom", 0, -2)
					
					plateFrame.actorSubTitleSolo:SetTextColor (unpack (plateConfigs.big_actortitle_text_color))
					DF:SetFontSize (plateFrame.actorSubTitleSolo, plateConfigs.big_actortitle_text_size)
					DF:SetFontFace (plateFrame.actorSubTitleSolo, plateConfigs.big_actortitle_text_font)
					DF:SetFontOutline (plateFrame.actorSubTitleSolo, plateConfigs.big_actortitle_text_shadow)
				end
			else
				--faz o scan no tooltip para saber se é um npc relevante
				local subTitle = Plater.GetActorSubName (plateFrame)
				if (subTitle and subTitle ~= "" and not Plater.IsIgnored (plateFrame, true)) then
					if (not subTitle:match ("%d")) then
						--profession
						
--						Plater.db.profile.plate_config [actorType].relevant_and_proffesions
--						Plater.db.profile.plate_config [actorType].only_relevant
						
						plateFrame.actorSubTitleSolo:Show()
						plateFrame.actorSubTitleSolo:SetText ("<" .. subTitle .. ">")
						--plateFrame.actorSubTitleSolo:SetText (subTitle)
						plateFrame.actorSubTitleSolo:ClearAllPoints()
						plateFrame.actorSubTitleSolo:SetPoint ("top", plateFrame.actorNameSolo, "bottom", 0, -2)
						
						plateFrame.actorSubTitleSolo:SetTextColor (unpack (plateConfigs.big_actortitle_text_color))
						DF:SetFontSize (plateFrame.actorSubTitleSolo, plateConfigs.big_actortitle_text_size)
						DF:SetFontFace (plateFrame.actorSubTitleSolo, plateConfigs.big_actortitle_text_font)
						DF:SetFontOutline (plateFrame.actorSubTitleSolo, plateConfigs.big_actortitle_text_shadow)
						
						---
						--npc name
						plateFrame.actorNameSolo:Show()
						plateFrame.actorNameSolo:SetText (UnitName (plateFrame [MEMBER_UNITID]))

						plateFrame.actorNameSolo:SetTextColor (unpack (plateConfigs.big_actorname_text_color))
						DF:SetFontSize (plateFrame.actorNameSolo, plateConfigs.big_actorname_text_size)
						DF:SetFontFace (plateFrame.actorNameSolo, plateConfigs.big_actorname_text_font)
						DF:SetFontOutline (plateFrame.actorNameSolo, plateConfigs.big_actorname_text_shadow)
					end
				end
			end
		elseif (plateFrame.shouldShowNpcTitle) then
			local subTitle = Plater.GetActorSubName (plateFrame)
			if (subTitle and subTitle ~= "" and not subTitle:match ("%d") and not Plater.IsIgnored (plateFrame, true)) then
				plateFrame.actorSubTitleSolo:Show()
				plateFrame.actorNameSolo:SetText ("")
				plateFrame.actorSubTitleSolo:SetText (subTitle)
				plateFrame.actorSubTitleSolo:ClearAllPoints()
				plateFrame.actorSubTitleSolo:SetPoint ("top", plateFrame.actorNameSolo, "bottom", 0, 3)
				
				plateFrame.actorSubTitleSolo:SetTextColor (unpack (plateConfigs.big_actortitle_text_color))
				DF:SetFontSize (plateFrame.actorSubTitleSolo, plateConfigs.big_actortitle_text_size)
				DF:SetFontFace (plateFrame.actorSubTitleSolo, plateConfigs.big_actortitle_text_font)
				DF:SetFontOutline (plateFrame.actorSubTitleSolo, plateConfigs.big_actortitle_text_shadow)
			end
		elseif (plateFrame.shouldShowNpcTitleWithBrackets) then
			local subTitle = Plater.GetActorSubName (plateFrame)
			if (subTitle and subTitle ~= "" and not subTitle:match ("%d")) then
				plateFrame.actorSubTitleSolo:Show()
				plateFrame.actorNameSolo:SetText ("")
				plateFrame.actorSubTitleSolo:SetText ("<" .. subTitle .. ">")
				plateFrame.actorSubTitleSolo:ClearAllPoints()
				plateFrame.actorSubTitleSolo:SetPoint ("top", plateFrame.actorNameSolo, "bottom", 0, 3)
				
				plateFrame.actorSubTitleSolo:SetTextColor (unpack (plateConfigs.big_actortitle_text_color))
				DF:SetFontSize (plateFrame.actorSubTitleSolo, plateConfigs.big_actortitle_text_size)
				DF:SetFontFace (plateFrame.actorSubTitleSolo, plateConfigs.big_actortitle_text_font)
				DF:SetFontOutline (plateFrame.actorSubTitleSolo, plateConfigs.big_actortitle_text_shadow)
			end
		end
		
	end

	--atualiza o texto da cast bar
	DF:SetFontColor (spellnameString, plateConfigs.spellname_text_color)
	DF:SetFontSize (spellnameString, plateConfigs.spellname_text_size)
	DF:SetFontOutline (spellnameString, plateConfigs.spellname_text_shadow)
	DF:SetFontFace (spellnameString, plateConfigs.spellname_text_font)
	
	--atualiza o texto da porcentagem do cast
	if (plateConfigs.spellpercent_text_enabled) then
		spellPercentString:Show()
		DF:SetFontColor (spellPercentString, plateConfigs.spellpercent_text_color)
		DF:SetFontSize (spellPercentString, plateConfigs.spellpercent_text_size)
		DF:SetFontOutline (spellPercentString, plateConfigs.spellpercent_text_shadow)
		DF:SetFontFace (spellPercentString, plateConfigs.spellpercent_text_font)
		Plater.SetAnchor (spellPercentString, plateConfigs.spellpercent_text_anchor)
	else
		spellPercentString:Hide()
	end

	Plater.SetAnchor (spellnameString, plateConfigs.spellname_text_anchor)
	
	--atualiza o texto do level ??
	if (plateConfigs.level_text_enabled) then
		levelString:Show()
		DF:SetFontSize (levelString, plateConfigs.level_text_size)
		DF:SetFontFace (levelString, plateConfigs.level_text_font)
		DF:SetFontOutline (levelString, plateConfigs.level_text_shadow)
		Plater.SetAnchor (levelString, plateConfigs.level_text_anchor)
		Plater.UpdateLevelTextAndColor (levelString, plateFrame.namePlateUnitToken)
		levelString:SetAlpha (plateConfigs.level_text_alpha)
	else
		levelString:Hide()
	end

	--atualiza o texto da porcentagem da vida
	if (plateConfigs.percent_text_enabled) then
		lifeString:Show()
		--apenas mostrar durante o combate
		if (InCombatLockdown()) then
			lifeString:Show()
		else
			lifeString:Hide()
		end
		DF:SetFontSize (lifeString, plateConfigs.percent_text_size)
		DF:SetFontFace (lifeString, plateConfigs.percent_text_font)
		DF:SetFontOutline (lifeString, plateConfigs.percent_text_shadow)
		DF:SetFontColor (lifeString, plateConfigs.percent_text_color)
		Plater.SetAnchor (lifeString, plateConfigs.percent_text_anchor)
		lifeString:SetAlpha (plateConfigs.percent_text_alpha)
		Plater.UpdateLifePercentText (lifeString, plateFrame.namePlateUnitToken)
	else
		lifeString:Hide()
	end
	
	--atualiza o texto da porcentagem da mana
	if (plateFrame.isSelf) then
		if (plateConfigs.power_percent_text_enabled) then
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
	end
end

function Plater.UpdateLifePercentText (lifeString, unitId)
	local currentHealth, maxHealth = UnitHealth (unitId), UnitHealthMax (unitId)
	--lifeString:SetText (string.format ("%.2f", currentHealth / maxHealth * 100) .. "%")
	lifeString:SetText (floor (currentHealth / maxHealth * 100) .. "%")
end

function Plater.UpdatePlateSize (plateFrame)
	if (not plateFrame.actorType) then
		return
	end

	local actorType = plateFrame.actorType
	local order = plateFrame.order

	local plateConfigs = Plater.db.profile.plate_config [actorType]
	local plateWidth = plateFrame:GetWidth()

	local unitFrame = plateFrame.UnitFrame
	local healthFrame = unitFrame.healthBar
	local castFrame = unitFrame.castBar
	local buffFrame = unitFrame.BuffFrame
	local nameFrame = unitFrame.healthBar.actorName

	local isMinus = Plater.ShouldForceSmallBar (plateFrame)
	local isInCombat = InCombatLockdown()
	
	--sempre usar barras grandes quando estiver em pvp
	if (plateFrame.actorType == ACTORTYPE_ENEMY_PLAYER) then
		if ((Plater.zoneInstanceType == "pvp" or Plater.zoneInstanceType == "arena") and Plater.db.profile.plate_config.player.pvp_always_incombat) then
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
		local selfBarOffset = plateConfigs.y_position_offset
		
		local height_offset = 0
		
		if (plateFrame.isSelf) then
			height_offset = selfBarOffset
		end		
		
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
		if (Plater.zonePvpType ~= "sanctuary") then
			scalarValue = SizeOf_healthBar_Width > SizeOf_castBar_Width and -((SizeOf_healthBar_Width - SizeOf_castBar_Width) / 2) or ((SizeOf_castBar_Width - SizeOf_healthBar_Width) / 2)
		else
			--scalarValue = 80 > SizeOf_castBar_Width and -((80 - SizeOf_castBar_Width) / 2) or ((SizeOf_castBar_Width - 80) / 2)
			scalarValue = SizeOf_healthBar_Width > SizeOf_castBar_Width and -((SizeOf_healthBar_Width - SizeOf_castBar_Width) / 2) or ((SizeOf_castBar_Width - SizeOf_healthBar_Width) / 2)
		end

		healthFrame:ClearAllPoints()
		healthFrame:SetPoint ("BOTTOMLEFT", castFrame, "TOPLEFT", scalarValue,  (-SizeOf_healthBar_Height) + (-SizeOf_castBar_Height) - 4);
		healthFrame:SetPoint ("BOTTOMRIGHT", castFrame, "TOPRIGHT", -scalarValue,  (-SizeOf_healthBar_Height) + (-SizeOf_castBar_Height) - 4);
		healthFrame:SetHeight (SizeOf_healthBar_Height / (isMinus and 2 or 1))

		buffFrame.Point1 = "top"
		buffFrame.Point2 = "bottom"
		buffFrame.Anchor = healthFrame
		buffFrame.X = 0
		buffFrame.Y = -11 + plateConfigs.buff_frame_y_offset
		buffFrame:SetPoint (buffFrame.Point1, buffFrame.Anchor, buffFrame.Point2, buffFrame.X, buffFrame.Y)

		--player
		if (plateFrame.isSelf) then
			Plater.UpdateManaAndResourcesBar()
			healthFrame.barTexture:SetVertexColor (DF:ParseColors ("lightgreen"))
		end
		
	elseif (order == 2) then
		--health, buffs, castbar
		
		local castKey, heathKey, textKey = Plater.GetHashKey (isInCombat)
		local SizeOf_healthBar_Width = plateConfigs [heathKey][1]
		local SizeOf_castBar_Width = plateConfigs [castKey][1]
		local SizeOf_healthBar_Height = plateConfigs [heathKey][2]
		local SizeOf_castBar_Height = plateConfigs [castKey][2]
		local SizeOf_text = plateConfigs [textKey]
		local selfBarOffset = plateConfigs.y_position_offset
		
		local height_offset = 0
		
		if (plateFrame.isSelf) then
			height_offset = selfBarOffset
		end		
		
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
		if (Plater.zonePvpType ~= "sanctuary") then
			scalarValue = SizeOf_healthBar_Width > SizeOf_castBar_Width and -((SizeOf_healthBar_Width - SizeOf_castBar_Width) / 2) or ((SizeOf_castBar_Width - SizeOf_healthBar_Width) / 2)
		else
			scalarValue = 70 > SizeOf_castBar_Width and -((70 - SizeOf_castBar_Width) / 2) or ((SizeOf_castBar_Width - 70) / 2)
		end
		
--		local isMinus
--		if (UnitClassification (plateFrame.namePlateUnitToken) == "minus" or Plater.petCache [UnitGUID (plateFrame [MEMBER_UNITID])]) then
--			scalarValue = scalarValue + (SizeOf_healthBar_Width/4)
--			isMinus = true
--		end
		
		healthFrame:ClearAllPoints()
		healthFrame:SetPoint ("BOTTOMLEFT", castFrame, "TOPLEFT", scalarValue,  (-SizeOf_healthBar_Height) + (-SizeOf_castBar_Height) + (-buffFrameSize) - 4);
		healthFrame:SetPoint ("BOTTOMRIGHT", castFrame, "TOPRIGHT", -scalarValue,  (-SizeOf_healthBar_Height) + (-SizeOf_castBar_Height) + (-buffFrameSize) - 4);
		healthFrame:SetHeight (SizeOf_healthBar_Height / (isMinus and 2 or 1))
		
		buffFrame.Point1 = "top"
		buffFrame.Point2 = "bottom"
		buffFrame.Anchor = castFrame
		buffFrame.X = 0
		buffFrame.Y = -1 + plateConfigs.buff_frame_y_offset
		buffFrame:SetPoint (buffFrame.Point1, buffFrame.Anchor, buffFrame.Point2, buffFrame.X, buffFrame.Y)
		
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
		local selfBarOffset = plateConfigs.y_position_offset

		local height_offset = 0
		
		if (plateFrame.isSelf) then
			height_offset = selfBarOffset
		end
		
--		print (plateFrame:GetSize())
--		print (plateFrame.UnitFrame:GetSize())
		
		local buffFrameSize = Plater.db.profile.aura_height
		local scalarValue = SizeOf_castBar_Width > plateWidth and -((SizeOf_castBar_Width - plateWidth) / 2) or ((plateWidth - SizeOf_castBar_Width) / 2)

		if (isMinus) then
			scalarValue = scalarValue + (SizeOf_castBar_Width/5)
		end
		
		castFrame:SetPoint ("BOTTOMLEFT", unitFrame, "BOTTOMLEFT", scalarValue, height_offset) ---SizeOf_healthBar_Height + (-SizeOf_castBar_Height + 2)
		castFrame:SetPoint ("BOTTOMRIGHT", unitFrame, "BOTTOMRIGHT", -scalarValue, height_offset)
		castFrame:SetHeight (SizeOf_castBar_Height)
		castFrame.Icon:SetSize (SizeOf_castBar_Height, SizeOf_castBar_Height)
		castFrame.BorderShield:SetSize (SizeOf_castBar_Height*1.4, SizeOf_castBar_Height*1.4)
		
		local scalarValue
		local passouPor = 0
		if (Plater.zonePvpType ~= "sanctuary" or plateFrame [MEMBER_REACTION] == 4) then
			scalarValue = SizeOf_healthBar_Width > SizeOf_castBar_Width and -((SizeOf_healthBar_Width - SizeOf_castBar_Width) / 2) or ((SizeOf_castBar_Width - SizeOf_healthBar_Width) / 2)
			passouPor = 1
		else
			if (plateFrame.isSelf) then
				scalarValue = SizeOf_healthBar_Width > SizeOf_castBar_Width and -((SizeOf_healthBar_Width - SizeOf_castBar_Width) / 2) or ((SizeOf_castBar_Width - SizeOf_healthBar_Width) / 2)
				passouPor = 2
			else
				scalarValue = 70 > SizeOf_castBar_Width and -((70 - SizeOf_castBar_Width) / 2) or ((SizeOf_castBar_Width - 70) / 2)
				passouPor = 3
			end
		end

		--health
		healthFrame:ClearAllPoints()
		healthFrame:SetPoint ("BOTTOMLEFT", castFrame, "TOPLEFT", scalarValue,  1)
		healthFrame:SetPoint ("BOTTOMRIGHT", castFrame, "TOPRIGHT", -scalarValue,  1)
		healthFrame:SetHeight (SizeOf_healthBar_Height / (isMinus and 2 or 1))
		
--		if (UnitIsPlayer (plateFrame [MEMBER_UNITID])) then
--			if (healthFrame:GetWidth()-2 > SizeOf_healthBar_Width) then
				--bugou
				--NAME - Tamanho na Config - Tamanha Atual - Scalar Value - Qual If Usou
--				print (UnitName (plateFrame [MEMBER_UNITID]), SizeOf_healthBar_Width, floor (healthFrame:GetWidth()), scalarValue, passouPor, " | ", floor (castFrame:GetWidth()))
--			end
--		end

		--buff
		buffFrame.Point1 = "bottom"
		buffFrame.Point2 = "top"
		buffFrame.Anchor = healthFrame
		buffFrame.X = 0
		buffFrame.Y = (buffFrameSize / 3) + 1 + plateConfigs.buff_frame_y_offset
		buffFrame:SetPoint (buffFrame.Point1, buffFrame.Anchor, buffFrame.Point2, buffFrame.X, buffFrame.Y)
		
		--player
		if (plateFrame.isSelf) then
			Plater.UpdateManaAndResourcesBar()
			healthFrame.barTexture:SetVertexColor (DF:ParseColors ("lightgreen"))
		end
	end
end

function Plater.UpdateManaAndResourcesBar()
	local profile = Plater.db.profile
	local manaConfig = profile.plate_config [ACTORTYPE_PLAYER].mana
	local locClass, class = UnitClass ("player")
	local width, height = manaConfig[1], manaConfig[2]
	
	--mana and power
	ClassNameplateManaBarFrame:SetSize (width, height)
	
	--chi windwalker
	if (class == "MONK") then
		ClassNameplateBrewmasterBarFrame:SetSize (width, height-2)
		ClassNameplateBarWindwalkerMonkFrame:ClearAllPoints()
		ClassNameplateBarWindwalkerMonkFrame:SetPoint ("topleft", ClassNameplateManaBarFrame, "bottomleft")
		ClassNameplateBarWindwalkerMonkFrame:SetPoint ("topright", ClassNameplateManaBarFrame, "bottomright")
		--ClassNameplateBarWindwalkerMonkFrame:SetSize (width, height-2)
		local f = ClassNameplateBarWindwalkerMonkFrame
		local scale = profile.resources.MONK.chi_scale
		for i = 1, 5 do
			local chi = f ["Chi" .. i]
			chi:SetScale (scale)
			local width = chi:GetWidth()
			chi:ClearAllPoints()
			chi:SetPoint ("center", (i-3)*width, 0)
		end
		
	--arcane charge
	elseif (class == "MAGE") then
		local f = ClassNameplateBarMageFrame
		f:ClearAllPoints()
		f:SetPoint ("topleft", ClassNameplateManaBarFrame, "bottomleft")
		f:SetPoint ("topright", ClassNameplateManaBarFrame, "bottomright")
		
		local scale = profile.resources.MAGE.arcane_charge_scale
		for i = 1, 4 do
			local charge = f ["Charge" .. i]
			charge:SetScale (scale)
			local width = charge:GetWidth()
			charge:ClearAllPoints()
			charge:SetPoint ("center", (i-2.5)*width, 0)
		end
	
	--dk runes
	elseif (class == "DEATHKNIGHT") then
		local f = DeathKnightResourceOverlayFrame
		f:ClearAllPoints()
		f:SetPoint ("topleft", ClassNameplateManaBarFrame, "bottomleft")
		f:SetPoint ("topright", ClassNameplateManaBarFrame, "bottomright")
		
		local scale = profile.resources.DEATHKNIGHT.rune_scale
		for i = 1, 6 do
			local charge = f ["Rune" .. i]
			charge:SetScale (scale)
			local width = charge:GetWidth()
			charge:ClearAllPoints()
			charge:SetPoint ("center", (i-3.5)*width, 0)
		end

	--paladin holy power
	elseif (class == "PALADIN") then
		local f = ClassNameplateBarPaladinFrame
		f:ClearAllPoints()
		f:SetPoint ("topleft", ClassNameplateManaBarFrame, "bottomleft")
		f:SetPoint ("topright", ClassNameplateManaBarFrame, "bottomright")
		
		local scale = profile.resources.PALADIN.holypower_scale
		for i = 1, 5 do
			local charge = f ["Rune" .. i]
			charge:SetScale (scale)
			local width = charge:GetWidth()
			charge:ClearAllPoints()
			charge:SetPoint ("center", (i-3)*width, 0)
		end
		
	elseif (class == "ROGUE" or class == "DRUID") then
		local f = ClassNameplateBarRogueDruidFrame
		f:ClearAllPoints()
		f:SetPoint ("topleft", ClassNameplateManaBarFrame, "bottomleft")
		f:SetPoint ("topright", ClassNameplateManaBarFrame, "bottomright")
		
		local scale
		if (class == "ROGUE") then
			scale = profile.resources.ROGUE.combopoint_scale
		elseif (class == "DRUID") then
			scale = profile.resources.DRUID.combopoint_scale
		end
		
		for i = 1, 5 do
			local charge = f ["Combo" .. i]
			charge:SetScale (scale)
			local width = charge:GetWidth()
			charge:ClearAllPoints()
			charge:SetPoint ("center", (i-3)*width, 0)
		end
		for i = 6, 8 do
			local charge = f ["Combo" .. i]
			charge:SetScale (scale)
			local width = charge:GetWidth()
			local height = charge:GetWidth()
			charge:ClearAllPoints()
			charge:SetPoint ("center", (i-2)*width, -(height/2)-3)
		end

	--warlock soul shards
	elseif (class == "WARLOCK") then
		local f = ClassNameplateBarWarlockFrame
		f:ClearAllPoints()
		f:SetPoint ("topleft", ClassNameplateManaBarFrame, "bottomleft")
		f:SetPoint ("topright", ClassNameplateManaBarFrame, "bottomright")
		
		local scale = profile.resources.WARLOCK.soulshard_scale
		for i = 1, 5 do
			local charge = f ["Shard" .. i]
			charge:SetScale (scale)
			local width = charge:GetWidth()
			charge:ClearAllPoints()
			charge:SetPoint ("center", (i-3)*width, 0)
		end
		
	end
	
end

function Plater.ShouldForceSmallBar (plateFrame)
	if (UnitClassification (plateFrame [MEMBER_UNITID]) == "minus") then
		return true
	elseif (Plater.petCache [plateFrame [MEMBER_GUID]]) then
		return true
	end
end

function Plater:PLAYER_TARGET_CHANGED()
	Plater.OnPlayerTargetChanged()
end

local wait_for_leave_combat = function()
	Plater:ZONE_CHANGED_NEW_AREA()
end
function Plater:ZONE_CHANGED_NEW_AREA()
	if (InCombatLockdown()) then
		C_Timer.After (1, wait_for_leave_combat)
		return
	end
	
	local pvpType, isFFA, faction = GetZonePVPInfo()
	Plater.zonePvpType = pvpType
	
	local name, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceMapID, instanceGroupSize = GetInstanceInfo()
	Plater.zoneInstanceType = instanceType
	
	if (instanceType == "party" or instanceType == "raid") then
		if (GetCVar (CVAR_FRIENDLY_ALL) == CVAR_ENABLED and Plater.db.profile.friendlyplates_no_on_instances) then
			SetCVar (CVAR_FRIENDLY_ALL, CVAR_DISABLED)
		end
		
		--verifica se 'somente instancias' esta ligado
		if (Plater.db.profile.enemyplates_only_in_instances) then
			SetCVar (CVAR_ENEMY_ALL, CVAR_ENABLED)
		--se não estiver, verifica se 'apenas em combate' esta ligado
		elseif (GetCVar (CVAR_ENEMY_ALL) == CVAR_ENABLED and Plater.db.profile.enemyplates_only_combat and not InCombatLockdown()) then
			SetCVar (CVAR_ENEMY_ALL, CVAR_DISABLED)
		end
		
		Plater.UpdateAllPlates()
		return
	else
		if (Plater.db.profile.friendlyplates_auto_show) then
			SetCVar (CVAR_FRIENDLY_ALL, CVAR_ENABLED)
		end
		if (GetCVar (CVAR_ENEMY_ALL) == CVAR_ENABLED and Plater.db.profile.enemyplates_only_combat and not InCombatLockdown()) then
			SetCVar (CVAR_ENEMY_ALL, CVAR_DISABLED)
		end
		
		Plater.UpdateAllPlates()
		return
	end
end

function Plater:PLAYER_ENTERING_WORLD()
	C_Timer.After (1, Plater.ZONE_CHANGED_NEW_AREA)
	C_Timer.After (1, Plater.FRIENDLIST_UPDATE)
	Plater.PlayerGuildName = GetGuildInfo ("player")
	if (not Plater.PlayerGuildName or Plater.PlayerGuildName == "") then
		Plater.PlayerGuildName = "ThePlayerHasNoGuildName/30Char"
	end
	
	local pvpType, isFFA, faction = GetZonePVPInfo()
	Plater.zonePvpType = pvpType
	
	local name, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceMapID, instanceGroupSize = GetInstanceInfo()
	Plater.zoneInstanceType = instanceType
	
end
Plater:RegisterEvent ("PLAYER_ENTERING_WORLD")

function Plater.ForceChangeHealthBarColor (healthBar, r, g, b)
	if (r ~= healthBar.r or g ~= healthBar.g or b ~= healthBar.b) then
		healthBar.r, healthBar.g, healthBar.b = r, g, b
		healthBar.barTexture:SetVertexColor (r, g, b)
	end
end

function Plater.CheckForDetectors (plateFrame)
	local name, rank, texture, count, debuffType, duration, expirationTime, caster, _, nameplateShowPersonal, spellId, _, _, _, nameplateShowAll = UnitAura (plateFrame [MEMBER_UNITID], FILTER_BUFF_DETECTION)
	if (name) then
		plateFrame.Top3DFrame:Show()
		plateFrame.Top3DFrame:SetModel ("Spells\\Blackfuse_LaserTurret_GroundBurn_State_Base")
	else
		local name, rank, texture, count, debuffType, duration, expirationTime, caster, _, nameplateShowPersonal, spellId, _, _, _, nameplateShowAll = UnitAura (plateFrame [MEMBER_UNITID], FILTER_BUFF_DETECTION2)
		if (name) then
			plateFrame.Top3DFrame:Show()
			plateFrame.Top3DFrame:SetModel ("Spells\\Blackfuse_LaserTurret_GroundBurn_State_Base")
		end
	end
end

-- ~update
function Plater.UpdatePlateFrame (plateFrame, actorType, order)
	actorType = actorType or plateFrame.actorType
	order = order or plateFrame.order
	
	order = Plater.db.profile.plate_config [actorType].plate_order
	
	local unitFrame = plateFrame.UnitFrame --setallpoints
	local healthFrame = unitFrame.healthBar
	local castFrame = unitFrame.castBar
	local buffFrame = unitFrame.BuffFrame
	local nameFrame = unitFrame.healthBar.actorName
	
	plateFrame.actorType = actorType
	plateFrame.order = order
	plateFrame.shouldShowNpcNameAndTitle = false
	plateFrame.shouldShowNpcTitleWithBrackets = false
	plateFrame.shouldShowNpcTitle = false
	
	local wasQuestPlate = plateFrame [MEMBER_QUEST]
	plateFrame [MEMBER_QUEST] = false
	
	plateFrame.actorNameSolo:Hide()
	plateFrame.actorSubTitleSolo:Hide()
	plateFrame.Top3DFrame:Hide()

	--remove a alpha colocada pelo aggro
	unitFrame:SetAlpha (1)
	
	--remove o glow posto pelo aggro
	unitFrame.aggroGlowUpper:Hide()
	unitFrame.aggroGlowLower:Hide()
	
	--a plate esta desativada?
	if (not Plater.CanShowPlateFor (actorType)) then
		if (InCombatLockdown()) then
			healthFrame:Hide()
			buffFrame:Hide()
			nameFrame:Hide()
		else
			plateFrame:Hide()
		end
		
	--a plate é de um NPC inimigo e estamos dentro de um santuário?
	elseif (plateFrame [MEMBER_REACTION] < 4 and Plater.zonePvpType == "sanctuary") then
		if (InCombatLockdown()) then
			healthFrame:Hide()
			buffFrame:Hide()
			nameFrame:Hide()
		else
			plateFrame:Hide()
		end
	else

		--se for um npc inimigo, ver se faz parte de alguma quest
		if (actorType == ACTORTYPE_ENEMY_NPC and Plater.db.profile.plate_config [actorType].quest_enabled) then --actorType == ACTORTYPE_FRIENDLY_NPC or 
			local isQuestMob = Plater.IsQuestObjective (plateFrame)
			if (isQuestMob and not IsTapDenied (plateFrame.UnitFrame)) then
				if (plateFrame [MEMBER_REACTION] == UNITREACTION_NEUTRAL) then
					Plater.ForceChangeHealthBarColor (healthFrame, unpack (Plater.db.profile.plate_config [actorType].quest_color_neutral))
					plateFrame [MEMBER_QUEST] = true
				else
					Plater.ForceChangeHealthBarColor (healthFrame, unpack (Plater.db.profile.plate_config [actorType].quest_color_enemy))
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

			if (Plater.db.profile.plate_config [actorType].quest_enabled and Plater.IsQuestObjective (plateFrame)) then
				Plater.ForceChangeHealthBarColor (healthFrame, unpack (Plater.db.profile.plate_config [actorType].quest_color))

				if (not plateFrame:IsShown() and not InCombatLockdown()) then
					plateFrame:Show()
				end
				healthFrame:Show()
				buffFrame:Show()
				nameFrame:Show()
				
				plateFrame [MEMBER_QUEST] = true
				
				--plateFrame.shouldShowNpcNameAndTitle = true
				
				--mostrar nomes de todos os npcs sem as barras de vida
			elseif (Plater.db.profile.plate_config [actorType].only_names or Plater.db.profile.plate_config [actorType].all_names) then
				if (not plateFrame:IsShown() and not InCombatLockdown()) then
					plateFrame:Show()
				end
				healthFrame:Hide()
				buffFrame:Hide()
				nameFrame:Hide()
				plateFrame.shouldShowNpcNameAndTitle = true
			
			--mostrar apenas plates para npcs relevantes / verifica se possui relevância ativa
			elseif (Plater.db.profile.plate_config [actorType].only_relevant) then
				--a relevancia esta ativada

				--se não tem um tipo ou o tipo esta desligado
				if (not plateFrame [MEMBER_NPCTYPE] or not Plater.db.profile.plate_config [actorType].filter [plateFrame [MEMBER_NPCTYPE]]) then
					--if (InCombatLockdown()) then
						healthFrame:Hide()
						buffFrame:Hide()
						nameFrame:Hide()
					--else
					--	plateFrame:Hide()
					--end
					
					--verifica se pode mostrar o nome dos npcs que não possuem relevancia
					if (Plater.db.profile.plate_config [actorType].relevant_and_proffesions) then
						--plateFrame.shouldShowNpcNameAndTitle = true
						plateFrame.shouldShowNpcTitle = true
					end
				else	
					--o npc possui um tipo e pode ser mostrado
					healthFrame:Show()
					buffFrame:Show()
					nameFrame:Show()
					if (not plateFrame:IsShown() and not InCombatLockdown()) then
						plateFrame:Show()
					end
					plateFrame.shouldShowNpcTitleWithBrackets = true
				end
			else
				healthFrame:Show()
				buffFrame:Show()
				nameFrame:Show()
				if (not plateFrame:IsShown() and not InCombatLockdown()) then
					plateFrame:Show()
				end
			end
			
			--suramar detectors
			Plater.CheckForDetectors (plateFrame)

		elseif (actorType == ACTORTYPE_FRIENDLY_PLAYER) then
			if (Plater.db.profile.plate_config [actorType].only_damaged) then
				if (UnitHealth (plateFrame [MEMBER_UNITID]) < UnitHealthMax (plateFrame [MEMBER_UNITID])) then
					healthFrame:Show()
					buffFrame:Show()
					nameFrame:Show()
					if (not plateFrame:IsShown() and not InCombatLockdown()) then
						plateFrame:Show()
					end
				else
					healthFrame:Hide()
					buffFrame:Hide()
					nameFrame:Hide()
				end
			else
				healthFrame:Show()
				buffFrame:Show()
				nameFrame:Show()
				if (not plateFrame:IsShown() and not InCombatLockdown()) then
					plateFrame:Show()
				end
			end
		else
			--tudo okey, podemos mostrar a barra
			healthFrame:Show()
			buffFrame:Show()
			nameFrame:Show()
			if (not plateFrame:IsShown() and not InCombatLockdown()) then
				plateFrame:Show()
			end
			
			--suramar detectors
			Plater.CheckForDetectors (plateFrame)
		end
	end
	
	buffFrame:ClearAllPoints()
	nameFrame:ClearAllPoints()
	
	local castTexture = LibSharedMedia:Fetch ("statusbar", Plater.db.profile.cast_statusbar_texture)
	local castBGTexture = LibSharedMedia:Fetch ("statusbar", Plater.db.profile.cast_statusbar_bgtexture)
	local healthTexture = LibSharedMedia:Fetch ("statusbar", Plater.db.profile.health_statusbar_texture)
	local healthBGTexture = LibSharedMedia:Fetch ("statusbar", Plater.db.profile.health_statusbar_bgtexture)
	--ajusta a cast bar
	castFrame:SetStatusBarTexture (castTexture)
	castFrame.background:SetTexture (castBGTexture)
	castFrame.background:SetVertexColor (unpack (Plater.db.profile.cast_statusbar_bgcolor))
	castFrame.Flash:SetTexture (castTexture)
	castFrame.Icon:SetTexCoord (0.078125, 0.921875, 0.078125, 0.921875)
	--ajusta a health bar
	healthFrame.barTexture:SetTexture (healthTexture)
	healthFrame.background:SetTexture (healthBGTexture)
	healthFrame.background:SetVertexColor (unpack (Plater.db.profile.health_statusbar_bgcolor))
	
	if (unitFrame.selectionHighlight:IsShown()) then
		local targetedOverlayTexture = LibSharedMedia:Fetch ("statusbar", Plater.db.profile.health_selection_overlay)
		unitFrame.selectionHighlight:SetTexture (targetedOverlayTexture)
		unitFrame.healthBar.background:SetAlpha (Plater.db.profile.health_statusbar_bgalpha_selected)
	else
		unitFrame.healthBar.background:SetAlpha (1)
	end

	Plater.UpdatePlateBorders (plateFrame)
	Plater.UpdatePlateText (plateFrame, Plater.db.profile.plate_config [actorType])
	Plater.UpdatePlateSize (plateFrame)
	Plater.UpdateIndicators (plateFrame, actorType)
	Plater.UpdateBuffContainer (plateFrame)
	Plater.UpdateTarget (plateFrame)
end

function Plater.UpdateIndicators (plateFrame, actorType)
	--limpa os indicadores
	Plater.ClearIndicators (plateFrame)
	local config = Plater.db.profile
	
	--if (UnitName (plateFrame.namePlateUnitToken):find ("Morti")) then
		--print (UnitName (plateFrame.namePlateUnitToken), actorType, UnitClassification (plateFrame.namePlateUnitToken))
	--end
	
	if (actorType == ACTORTYPE_ENEMY_PLAYER and config.indicator_faction) then
		Plater.AddIndicator (plateFrame, UnitFactionGroup (plateFrame [MEMBER_UNITID]))
		
	elseif (actorType == ACTORTYPE_ENEMY_NPC) then -- or actorType == ACTORTYPE_FRIENDLY_NPC
		--verifica quest e elite npc
		local isQuestBoss = UnitIsQuestBoss (plateFrame.namePlateUnitToken) --true false
		local unitClassification = UnitClassification (plateFrame.namePlateUnitToken) --elite minus normal rare rareelite worldboss
		if (Plater.petCache [UnitGUID (plateFrame [MEMBER_UNITID])]) then
			Plater.AddIndicator (plateFrame, "pet")
		end
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
		
		if (isQuestBoss and config.indicator_quest) then
			Plater.AddIndicator (plateFrame, "quest")
		end
	
	elseif (actorType == ACTORTYPE_FRIENDLY_NPC) then
		if (plateFrame [MEMBER_QUEST]) then
			Plater.AddIndicator (plateFrame, "quest")
		end
	end
	
	if (plateFrame [MEMBER_NPCTYPE]) then
		plateFrame.UnitFrame.ExtraIcon1:Show()
		plateFrame.UnitFrame.ExtraIcon1Timer:Hide()
		--pega o icone
		local iconTexture, L, R, T, B = Plater.GetNpcTypeIcon (plateFrame [MEMBER_NPCTYPE])
		plateFrame.UnitFrame.ExtraIcon1:SetTexture (iconTexture)
		plateFrame.UnitFrame.ExtraIcon1:SetTexCoord (L, R, T, B)
		plateFrame.UnitFrame.ExtraIcon1:SetSize (12, 12)
	else
		plateFrame.UnitFrame.ExtraIcon1:Hide()
		plateFrame.UnitFrame.ExtraIcon1Timer:Hide()
	end
end

function Plater.AddIndicator (plateFrame, indicator)
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
--		thisIndicator:SetTexCoord (661/1024, 701/1024, 317/512, 368/512)
	elseif (indicator == "Alliance") then
		--thisIndicator:SetTexture ([[Interface\PVPFrame\PVP-Conquest-Misc]])
		--thisIndicator:SetTexCoord (719/1024, 758/1024, 316/512, 365/512)
		thisIndicator:SetTexture ([[Interface\PVPFrame\PVP-Currency-Alliance]])
		thisIndicator:SetTexCoord (4/32, 29/32, 2/32, 30/32)
		thisIndicator:SetSize (12, 12)
	elseif (indicator == "elite") then
		thisIndicator:SetTexture ([[Interface\GLUES\CharacterSelect\Glues-AddOn-Icons]])
		--thisIndicator:SetTexture ([[Interface\Scenarios\SCENARIOSPARTS]])
		thisIndicator:SetTexCoord (0.75, 1, 0, 1)
		--thisIndicator:SetTexCoord (1/512, 47/512, 418/512, 460/512)
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

function Plater.UpdatePlateBorders (plateFrame)
	--bordas
	if (not plateFrame) then
		for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
			Plater.UpdatePlateBorders (plateFrame)
		end
		return
	end
	local r, g, b, a = unpack (Plater.db.profile.border_color)
	for index, texture in ipairs (plateFrame.UnitFrame.healthBar.border.Textures) do
		texture:SetVertexColor (r, g, b, a)
	end	
end

function Plater.OnPlayerTargetChanged()
	for index, plateFrame in ipairs (Plater.GetAllShownPlates()) do
		Plater.UpdateTarget (plateFrame)
	end
end
-- ~target
function Plater.UpdateTarget (plateFrame)
	if (UnitIsUnit (plateFrame [MEMBER_UNITID], "target") and Plater.db.profile.target_highlight) then
		plateFrame.TargetNeonUp:Show()
		plateFrame.TargetNeonDown:Show()
		Plater.UpdateTargetPoints (plateFrame)
	else
		plateFrame.TargetNeonUp:Hide()
		plateFrame.TargetNeonDown:Hide()
	end
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

Plater ["NAME_PLATE_CREATED"] = function (self, event, plateFrame)
	--isto é uma nameplate
	plateFrame.isNamePlate = true
	plateFrame.UnitFrame.isNamePlate = true
	plateFrame.UnitFrame.BuffFrame.amtDebuffs = 0
	plateFrame.UnitFrame.healthBar.border.plateFrame = plateFrame
	local healthBar = plateFrame.UnitFrame.healthBar
	
	--highlight para o mouse over
	local mouseHighlight = healthBar:CreateTexture (nil, "overlay")
	mouseHighlight:SetDrawLayer ("overlay", 7)
	mouseHighlight:SetAllPoints()
	mouseHighlight:SetTexture ([[Interface\ACHIEVEMENTFRAME\UI-Achievement-Alert-Glow]])
	mouseHighlight:SetTexCoord (50/512, 300/512, 60/256, 100/256)
	mouseHighlight:SetAlpha (.3)
	mouseHighlight:Hide()
	
	local TargetNeonUp = healthBar:CreateTexture (nil, "overlay")
	TargetNeonUp:SetDrawLayer ("overlay", 7)
	TargetNeonUp:SetPoint ("topleft", healthBar, "bottomleft")
	TargetNeonUp:SetPoint ("topright", healthBar, "bottomright")
	TargetNeonUp:SetTexture ([[Interface\BUTTONS\UI-Panel-Button-Glow]])
	TargetNeonUp:SetTexCoord (1/128, 95/128, 30/64, 38/64)
	TargetNeonUp:SetDesaturated (true)
	TargetNeonUp:SetBlendMode ("ADD")
	TargetNeonUp:SetHeight (8)
	TargetNeonUp:Hide()
	plateFrame.TargetNeonUp = TargetNeonUp
	
	local  TargetNeonDown = healthBar:CreateTexture (nil, "overlay")
	TargetNeonDown:SetDrawLayer ("overlay", 7)
	TargetNeonDown:SetPoint ("bottomleft", healthBar, "topleft")
	TargetNeonDown:SetPoint ("bottomright", healthBar, "topright")
	TargetNeonDown:SetTexture ([[Interface\BUTTONS\UI-Panel-Button-Glow]])
	TargetNeonDown:SetTexCoord (1/128, 95/128, 38/64, 30/64) --0, 95/128
	TargetNeonDown:SetDesaturated (true)
	TargetNeonDown:SetBlendMode ("ADD")
	TargetNeonDown:SetHeight (8)
	TargetNeonDown:Hide()
	plateFrame.TargetNeonDown = TargetNeonDown
	
	plateFrame:SetScript ("OnEnter", function (self)
		if (Plater.db.profile.hover_highlight) then
			mouseHighlight:Show()
			mouseHighlight:SetAlpha (Plater.db.profile.hover_highlight_alpha)
		end
	end)
	plateFrame:SetScript ("OnLeave", function (self)
		mouseHighlight:Hide()
	end)
	
	--nome customizado
	local actorName = plateFrame.UnitFrame.healthBar:CreateFontString (nil, "artwork", "GameFontNormal")
	plateFrame.UnitFrame.healthBar.actorName = actorName
	
	--nomes extras e sub titulo
	local actorNameSolo = plateFrame:CreateFontString (nil, "artwork", "GameFontNormal")
	plateFrame.actorNameSolo = actorNameSolo
	plateFrame.actorNameSolo:SetPoint ("center", plateFrame, "center")
	plateFrame.actorNameSolo:Hide()
	local actorSubTitleSolo = plateFrame:CreateFontString (nil, "artwork", "GameFontNormal")
	plateFrame.actorSubTitleSolo = actorSubTitleSolo
	plateFrame.actorSubTitleSolo:SetPoint ("top", actorNameSolo, "bottom", 0, -2)
	plateFrame.actorSubTitleSolo:Hide()
	
	plateFrame.UnitFrame.name:ClearAllPoints()
	plateFrame.UnitFrame.name:SetPoint ("bottom", plateFrame.UnitFrame.healthBar.actorName, "bottom")
	
	--level customizado
	local actorLevel = plateFrame.UnitFrame.healthBar:CreateFontString (nil, "overlay", "GameFontNormal")
	plateFrame.UnitFrame.healthBar.actorLevel = actorLevel
	--porcentagem de vida
	
	local lifePercent = plateFrame.UnitFrame.healthBar:CreateFontString (nil, "overlay", "GameFontNormal")
	plateFrame.UnitFrame.healthBar.lifePercent = lifePercent
	
	--icone extra, usado para ccs e para mostrar o tipo do npc
	local ExtraIcon1 = plateFrame.UnitFrame.healthBar:CreateTexture (nil, "overlay")
	ExtraIcon1:SetPoint ("left", plateFrame.UnitFrame.healthBar, "right", 2, 0)
	ExtraIcon1:SetSize (16, 16)
	ExtraIcon1:Hide()
	plateFrame.UnitFrame.ExtraIcon1 = ExtraIcon1
	
	local ExtraIcon1Timer = plateFrame.UnitFrame:CreateFontString (nil, "overlay", "GameFontNormal")
	ExtraIcon1Timer:SetPoint ("left", ccIcon, "right", 0, 0)
	ExtraIcon1Timer:Hide()
	plateFrame.UnitFrame.ExtraIcon1Timer = ExtraIcon1Timer
	
	--icone três dimensões
	plateFrame.Top3DFrame = CreateFrame ("playermodel", plateFrame:GetName() .. "3DFrame", plateFrame, "ModelWithControlsTemplate")
	plateFrame.Top3DFrame:SetPoint ("bottom", plateFrame, "top", 0, -100)
	plateFrame.Top3DFrame:SetSize (200, 250)
	plateFrame.Top3DFrame:EnableMouse (false)
	plateFrame.Top3DFrame:EnableMouseWheel (false)
	plateFrame.Top3DFrame:Hide()
	
	--fundo da castbar
	local extraBackground = plateFrame.UnitFrame.castBar:CreateTexture (nil, "background")
	extraBackground:SetAllPoints()
	extraBackground:SetColorTexture (0, 0, 0, 1)
	plateFrame.UnitFrame.castBar.extraBackground = extraBackground
	extraBackground:SetDrawLayer ("background", -3)
	extraBackground:Hide()
	
	--porcentagem da cast bar
	local percentText = plateFrame.UnitFrame.castBar:CreateFontString (nil, "background", "GameFontNormal")
	percentText:SetPoint ("right", plateFrame.UnitFrame.castBar, "right")
	plateFrame.UnitFrame.castBar.percentText = percentText
	
	--icone de não interrompível
	plateFrame.UnitFrame.castBar.BorderShield:SetTexture ([[Interface\ACHIEVEMENTFRAME\UI-Achievement-Progressive-IconBorder]])
	plateFrame.UnitFrame.castBar.BorderShield:SetTexCoord (5/64, 37/64, 1/64, 36/64)
	plateFrame.UnitFrame.castBar.isNamePlate = true

	--icones indicadores
	plateFrame.IconIndicators = {}
	
	--nome que vem com o frame
	plateFrame.UnitFrame.name:ClearAllPoints()
	plateFrame.UnitFrame.name:SetPoint ("top", plateFrame.UnitFrame.healthBar, "bottom", 0, 0)
	plateFrame.UnitFrame.name:SetPoint ("center", plateFrame.UnitFrame.healthBar, "center")
	
	--flash de aggro
	Plater.CreateAggroFlashFrame (plateFrame)
	plateFrame.playerHasAggro = false
	
	--aviso de aggro baixo
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
	
	plateFrame.UpdateAggroTick = Plater.db.profile.aggro_tick_rate
	plateFrame:HookScript ("OnUpdate", EventTickFunction)
end

function Plater.CanShowPlateFor (actorType)
	return Plater.db.profile.plate_config [actorType].enabled
end

Plater ["NAME_PLATE_UNIT_ADDED"] = function (self, event, unitBarId)
	--pega a nameplate deste jogador
	local plateFrame = C_NamePlate.GetNamePlateForUnit (unitBarId)
	
	plateFrame [MEMBER_GUID] = UnitGUID (unitBarId) or ""
	plateFrame.isSelf = nil
	Plater.CheckForNpcType (plateFrame)
	
	local name = UnitName (unitBarId)
	plateFrame.UnitFrame.healthBar.actorName:SetText (name)
	
	Plater.UpdatePlateClickSpace (plateFrame)
	
	local reaction = UnitReaction ("player", unitBarId)
	plateFrame [MEMBER_REACTION] = reaction
	plateFrame.UnitFrame [MEMBER_REACTION] = reaction
	
	if (plateFrame.UnitFrame.unit) then
		if (UnitIsUnit (unitBarId, "player")) then
			plateFrame.isSelf = true
			Plater.UpdatePlateFrame (plateFrame, ACTORTYPE_PLAYER)
		else
			if (UnitIsPlayer (unitBarId)) then
				--é um jogador, determinar se é um inimigo ou aliado
				if (reaction >= UNITREACTION_FRIENDLY) then
					Plater.UpdatePlateFrame (plateFrame, ACTORTYPE_FRIENDLY_PLAYER)
				else
					Plater.UpdatePlateFrame (plateFrame, ACTORTYPE_ENEMY_PLAYER)
				end
			else
				--é um npc
				if (reaction >= UNITREACTION_FRIENDLY) then
					Plater.UpdatePlateFrame (plateFrame, ACTORTYPE_FRIENDLY_NPC)
				else
					--inclui npcs que são neutros
					Plater.UpdatePlateFrame (plateFrame, ACTORTYPE_ENEMY_NPC)
				end
			end
		end
	end

	--icone da cast bar
	plateFrame.UnitFrame.castBar.Icon:ClearAllPoints()
	plateFrame.UnitFrame.castBar.Icon:SetPoint ("left", plateFrame.UnitFrame.castBar, "left", 0, 0)
	plateFrame.UnitFrame.castBar.BorderShield:ClearAllPoints()
	plateFrame.UnitFrame.castBar.BorderShield:SetPoint ("left", plateFrame.UnitFrame.castBar, "left", 0, 0)

	--esconde os glow de aggro
	plateFrame.UnitFrame.aggroGlowUpper:Hide()
	plateFrame.UnitFrame.aggroGlowLower:Hide()
	
	--tick
	plateFrame.UpdateAggroTick = Plater.db.profile.aggro_tick_rate
end

function Plater.UpdateUseClassColors()
	if (Plater.db.profile.use_playerclass_color) then
		Plater.InjectOnDefaultOptions (CNP_Name, Plater.DriverConfigType ["FRIENDLY"], Plater.DriverConfigMembers ["UseClassColors"], true)
	else
		Plater.InjectOnDefaultOptions (CNP_Name, Plater.DriverConfigType ["FRIENDLY"], Plater.DriverConfigMembers ["UseClassColors"], false)
	end
	for index, plateFrame in ipairs (Plater.GetAllShownPlates()) do
		Plater.Execute (CUF_Name, Plater.DriverFuncNames ["OnChangeHealthConfig"], plateFrame.UnitFrame)
	end
end

local CullingUnderCombat = function()
	return Plater.UpdateCullingDistance()
end
function Plater.UpdateCullingDistance()
	if (InCombatLockdown()) then	
		return C_Timer.After (1, CullingUnderCombat)
	end
	local distance = Plater.db.profile.culling_distance
	--SetCVar (CVAR_CULLINGDISTANCE, distance)
end

Plater ["NAME_PLATE_UNIT_REMOVED"] = function (self, event, unitBarId)
	local plateFrame = C_NamePlate.GetNamePlateForUnit (unitBarId)
	plateFrame [MEMBER_QUEST] = false
end

local petCache = {}
Plater.petCache = petCache

local CL_Parser = CreateFrame ("frame", nil, UIParent)
local CL_Func = function (self, event, time, token, hidding, sourceGUID, sourceName, sourceFlag, sourceFlag2, targetGUID, targetName, targetFlag, targetFlag2, ...)
	if (sourceFlag and CompareBit (sourceFlag, 0x00003000) ~= 0) then
		petCache [sourceGUID] = time
	elseif (targetFlag and CompareBit (targetFlag, 0x00003000) ~= 0) then
		petCache [targetGUID] = time
	end
end
CL_Parser:SetScript ("OnEvent", CL_Func)
CL_Parser:RegisterEvent ("COMBAT_LOG_EVENT_UNFILTERED")

C_Timer.NewTicker (180, function()
	local now = time()
	for guid, time in pairs (petCache) do
		if (time+180 < now) then
			petCache [guid] = nil
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

--não esta sendo usado
function Plater.UpdateCVars()
	if (not Plater.db.profile.plate_config.friendlyplayer) then
		SetCVar (CVAR_FRIENDLY_ALL, CVAR_DISABLED)
	else
		SetCVar (CVAR_FRIENDLY_ALL, CVAR_ENABLED)
	end
	if (not Plater.db.profile.plate_config.enemyplayer) then
		SetCVar (CVAR_ENEMY_ALL, CVAR_DISABLED)
	else
		SetCVar (CVAR_ENEMY_ALL, CVAR_ENABLED)
	end
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

	SetCVar (CVAR_SHOWPERSONAL, CVAR_DISABLED)
	SetCVar (CVAR_RESOURCEONTARGET, CVAR_DISABLED)
	SetCVar (CVAR_SHOWALL, CVAR_ENABLED)
	SetCVar (CVAR_AGGROFLASH, CVAR_ENABLED)
	SetCVar (CVAR_ENEMY_MINIONS, CVAR_ENABLED)
	SetCVar (CVAR_ENEMY_MINUS, CVAR_ENABLED)
	SetCVar (CVAR_PLATEMOTION, CVAR_ENABLED)
	SetCVar (CVAR_FRIENDLY_ALL, CVAR_ENABLED)
	SetCVar (CVAR_FRIENDLY_GUARDIAN, CVAR_DISABLED)
	SetCVar (CVAR_FRIENDLY_PETS, CVAR_DISABLED)
	SetCVar (CVAR_FRIENDLY_TOTEMS, CVAR_DISABLED)
	SetCVar (CVAR_FRIENDLY_MINIONS, CVAR_DISABLED)
	SetCVar (CVAR_CLASSCOLOR, CVAR_ENABLED)
	
	SetCVar (CVAR_SHOWPERSONAL, CVAR_DISABLED)
	
	--SetCVar (CVAR_SCALE_HORIZONTAL, "1.4")
	SetCVar (CVAR_SCALE_HORIZONTAL, CVAR_ENABLED)
	--SetCVar (CVAR_SCALE_VERTICAL, "2.7")	
	SetCVar (CVAR_SCALE_VERTICAL, CVAR_ENABLED)	

	InterfaceOptionsNamesPanelUnitNameplatesMakeLarger:Click()
	InterfaceOptionsNamesPanelUnitNameplatesPersonalResource:Click()
	InterfaceOptionsNamesPanelUnitNameplatesPersonalResource:Click()
	
	Plater.ShutdownInterfaceOptionsPanel()
	
	PlaterDBChr.first_run [UnitGUID ("player")] = true
	
	SetCVar (CVAR_CULLINGDISTANCE, 100)
	
	C_Timer.After (2, function()
		SetCVar (CVAR_SHOWPERSONAL, CVAR_ENABLED)
	end)
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

-- ~options
function Plater.OpenOptionsPanel()

	if (PlaterOptionsPanelFrame) then
		return PlaterOptionsPanelFrame:Show()
	end
	
	--pega os templates dos os widgets
	local options_text_template = DF:GetTemplate ("font", "OPTIONS_FONT_TEMPLATE")
	local options_dropdown_template = DF:GetTemplate ("dropdown", "OPTIONS_DROPDOWN_TEMPLATE")
	local options_switch_template = DF:GetTemplate ("switch", "OPTIONS_CHECKBOX_TEMPLATE")
	local options_slider_template = DF:GetTemplate ("slider", "OPTIONS_SLIDER_TEMPLATE")
	local options_button_template = DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE")
	
--	local f = CreateFrame ("frame", "PlaterOptionsPanel", UIParent)
	Plater.db.profile.OptionsPanelDB = Plater.db.profile.OptionsPanelDB or {}
	
	--controi o menu principal
	--local f = DF:Create1PxPanel (UIParent, 900, 600, "Plater Options", "PlaterOptionsPanel", Plater.db.profile.OptionsPanelDB)
	local f = DF:CreateSimplePanel (UIParent, 1100, 590, "Plater Options", "PlaterOptionsPanelFrame", {UseScaleBar = true}, Plater.db.profile.OptionsPanelDB)
	--f:SetPoint ("center", UIParent, "center", 0, 0)
	local profile = Plater.db.profile
	
	local frame_options = {
		y_offset = 0,
		button_width = 105,
		button_height = 20,
		button_x = 230,
		button_y = -32,
		button_text_size = 10,
	}
	
	-- mainFrame é um frame vazio para sustentrar todos os demais frames, este frame sempre será mostrado
	local mainFrame = DF:CreateTabContainer (f, "Plater Options", "PlaterOptionsPanelContainer", {
		{name = "FrontPage", title = "Main Menu"},
		{name = "PersonalBar", title = "Personal Bar"},
		{name = "FriendlyPlayer", title = "Friendly Player"},
		{name = "EnemyPlayer", title = "Enemy Player"},
		{name = "FriendlyNpc", title = "Friendly Npc"},
		{name = "EnemyNpc", title = "Enemy Npc"},
		{name = "DebuffConfig", title = "Config Debuffs"},
		{name = "ProfileManagement", title = "Profiles"},
	}, 
	frame_options)

	local frontPageFrame = mainFrame.AllFrames [1]
	local personalPlayerFrame = mainFrame.AllFrames [2]
	local friendlyPCsFrame = mainFrame.AllFrames [3]
	local friendlyNPCsFrame = mainFrame.AllFrames [5]
	local enemyPCsFrame = mainFrame.AllFrames [4]
	local enemyNPCsFrame = mainFrame.AllFrames [6]
	local auraFilterFrame = mainFrame.AllFrames [7]
	local profilesFrame = mainFrame.AllFrames [8]

	local generalOptionsAnchor = CreateFrame ("frame", "$parentOptionsAnchor", frontPageFrame)
	generalOptionsAnchor:SetSize (1, 1)
	generalOptionsAnchor:SetPoint ("topleft", frontPageFrame, "topleft", 10, -290)
	
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
	end
	
	local startX, startY, heightSize = 10, -110, 630
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
	
	--cria o botão de configurar a relevancia para os friendly npcs
	local relevancePanel = CreateFrame ("frame", nil, friendlyNPCsFrame)
	relevancePanel:SetSize (860, 500)
	relevancePanel:SetBackdrop ({bgFile = [[Interface\FrameGeneral\UI-Background-Marble]], tile = true, tileSize = 16, edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1})
	relevancePanel:SetBackdropColor (0, 0, 0, 0.9)
	relevancePanel:SetBackdropBorderColor (0, 0, 0, 1)
	relevancePanel:SetFrameLevel (friendlyNPCsFrame:GetFrameLevel()+5)
	relevancePanel:EnableMouse (true)
	
	do
		local options = {
			[1] = "important npc",
			[2] = "repair",
			[3] = "merchant",
			[4] = "innkeeper",
			[5] = "banker",
			[6] = "autioneer",
			[7] = "flyght master",
			[8] = "stable master",
			[9] = "pet master",
			[10] = "barber",
			[11] = "transmogrifier",
			[12] = "food and drink",
			[20] = "fishing trainer",
			[21] = "first aid trainer",
			[22] = "archaeology trainer",
			[23] = "cooking trainer",
			[24] = "mining trainer",
			[25] = "engineering trainer",
			[26] = "leatherworking trainer",
			[27] = "tailor trainer",
			[28] = "enchanting trainer",
			[29] = "blacksmith trainer",
			[30] = "inscription trainer",
			[31] = "herbalism trainer",
			[32] = "skinning trainer",
			[33] = "alchemy trainer",
			[34] = "jewelcrafting trainer",
		}
		
		local reorder = {}
		for id, textType in pairs (options) do
			tinsert (reorder, {id, textType})
		end
		table.sort (reorder, function (a, b) return a[2] < b[2] end)
		
		local change_relevance = function (_, id, state)
			Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_NPC].filter [id] = state
			Plater.UpdateAllPlates()
		end
		
		local x, y = 10, -10
		for i, t in ipairs (reorder) do
			local id, textType = unpack (t)

			local checkbox, label = DF:CreateSwitch (relevancePanel, change_relevance, Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_NPC].filter [id], _, _, _, _, "relevantCheckbox" .. id, _, _, _, _, "", DF:GetTemplate ("switch", "OPTIONS_CHECKBOX_BRIGHT_TEMPLATE"), options_text_template)
			checkbox:SetAsCheckBox()
			checkbox:SetPoint ("topleft", relevancePanel, "topleft", x, y)
			checkbox:SetFixedParameter (id)
			local stringRelevant = DF:CreateLabel (checkbox, textType, 10, "orange", nil, "relevantString" .. id, nil, "overlay")
			stringRelevant:SetPoint ("left", checkbox, "right", 2, 0)
			
			y = y - 20
			
			if (y < -480) then
				y = -10
				x = x + 180
			end
		end
		
	end
	
	relevancePanel:Hide()
	
	local open_friendlynpc_relevance_panel = function()
		relevancePanel:SetShown (not relevancePanel:IsShown())
	end
	local relevanceButton = DF:CreateButton (friendlyNPCsFrame, open_friendlynpc_relevance_panel, 200, 20, "Config Relevance", nil, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"))
	relevanceButton:SetPoint ("topleft", friendlyNPCsFrame, "topleft", 237, -30)
	
	relevancePanel:SetPoint ("topleft", relevanceButton.widget, "bottomleft", 0, -35)
	
-------------------------
-- funções gerais dos dropdowns
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
						Plater.UpdateAllPlates()
					else
						Plater.db.profile [member].side = value
						Plater.UpdateAllPlates()
					end
				end
			})
		end
		return t
	end	
	--
	local health_bar_texture_selected = function (self, capsule, value)
		Plater.db.profile.health_statusbar_texture = value
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
--opções do painel de interface da blizzard

local interface_options = {

		{type = "label", get = function() return "Interface Options:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},

		{
			type = "toggle",
			get = function() return GetCVar (CVAR_SHOWPERSONAL) == CVAR_ENABLED end,
			set = function (self, fixedparam, value) 
				if (not InCombatLockdown()) then
					SetCVar (CVAR_SHOWPERSONAL, math.abs (tonumber (GetCVar (CVAR_SHOWPERSONAL))-1))
				else
					Plater:Msg ("you are in combat.")
					self:SetValue (GetCVar (CVAR_SHOWPERSONAL) == CVAR_ENABLED)
				end
			end,
			name = "Personal Health and Mana Bars",
			desc = "Shows a mini health and mana bars under your character.",
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
			name = "Show Resources on Target",
			desc = "Shows your resource such as combo points above your current target.\n\n'Personal Health and Mana Bars' has to be enabled",
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
			name = "Always Show Nameplates",
			desc = "Show nameplates for all units near you. If disabled on show relevant units when you are in combat.",
			nocombat = true,
		},
		{
			type = "toggle",
			get = function() return GetCVar (CVAR_PLATEMOTION) == CVAR_ENABLED end,
			set = function (self, fixedparam, value) 
				if (not InCombatLockdown()) then
					SetCVar (CVAR_PLATEMOTION, math.abs (tonumber (GetCVar (CVAR_PLATEMOTION))-1))
				else
					Plater:Msg ("you are in combat.")
					self:SetValue (GetCVar (CVAR_PLATEMOTION) == CVAR_ENABLED)
				end
			end,
			name = "Stacking Nameplates",
			desc = "Nameplates won't overlap each other.",
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
			name = "Enemy Units (" .. (GetBindingKey ("NAMEPLATES") or "") .. "): Minions",
			desc = "Show nameplate for enemy pets, totems and guardians.",
			nocombat = true,
		},
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
			name = "Enemy Units (V): Minor",
			desc = "Show nameplate for minor enemies.",
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
			name = "Friendly Units (" .. (GetBindingKey ("FRIENDNAMEPLATES") or "") .. "): Minions",
			desc = "Show nameplate for friendly pets, totems and guardians.\n\nAlso check the Enabled box below Friendly Npc Config.",
			nocombat = true,
		},
}

DF:BuildMenu (frontPageFrame, interface_options, startX, startY, 300 + 60, true, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template)	

-------------------------------------------------------------------------------
-- painel para configurar debuffs e buffs

local debuff_options = {
	{type = "label", get = function() return "General Settings:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
	{
		type = "toggle",
		get = function() return Plater.db.profile.aura_timer end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.aura_timer = value
			Plater.RefreshAuras()
			Plater.UpdateAllPlates()
		end,
		name = "Show Timer",
		desc = "Time left on buff or debuff.",
	},
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
	{
		type = "toggle",
		get = function() return Plater.db.profile.debuff_show_cc end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.debuff_show_cc = value
			Plater.UpdateAllPlates()
		end,
		name = "Crowd Control Icon",
		desc = "When the actor has a crowd control spell (such as Polymorph).",
	},
}

DF:BuildMenu (auraFilterFrame, debuff_options, startX, startY, 300 + 60, true, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template)	

local welcomestring = DF:CreateLabel (auraFilterFrame, "Cast spells to fill *your* buffs and debuffs list.", 16, "white")
welcomestring:SetPoint ("topleft", self, "topleft", 10, -235)
local subLine = DF:CreateImage (auraFilterFrame, nil, 300, 1)
subLine:SetColorTexture (1, 1, 1, 0.7)
--subLine:SetPoint ("topleft", welcomestring, "bottomleft")
--subLine:SetPoint ("topright", welcomestring, "bottomright")

local ResetWidgets = function (self)
	for _, widget in ipairs (self.widgets) do 
		widget:Hide()
	end
	self.nextWidget = 1
end

local onenter = function (self, capsule)
	GameTooltip:SetOwner (self, "ANCHOR_RIGHT")
	GameTooltip:SetSpellByID (capsule.spellid)
	GameTooltip:Show()
	capsule.textcolor = "white"
end
local onleave = function (self, capsule)
	GameTooltip:Hide()
	capsule.textcolor = "khaki"
end

local aura_line_height = 14

local GetOrCreateWidget = function (self)
	local index = self.nextWidget
	local widget = self.widgets [index]
	if (not widget) then
		widget = DF:CreateButton (self, function()end, 235, aura_line_height, "", nil, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"))
		widget:SetHook ("OnEnter", onenter)
		widget:SetHook ("OnLeave", onleave)
		widget.textcolor = "wheat"
		widget.textsize = 10
		tinsert (self.widgets, widget)
	end
	self.nextWidget = self.nextWidget + 1
	return widget
end

local RefreshWidgets = function (self)
	self:ResetWidgets()
	for spellid, _ in pairs (self.spells) do
		local widget = self:GetOrCreateWidget()
		widget:SetPoint ("topleft", self, "topleft", 0, -aura_line_height*(self.nextWidget-1))
		widget:SetClickFunction (self.func, spellid)
		local spellname, _, spellicon = GetSpellInfo (spellid)
		widget:SetIcon (spellicon, aura_line_height, aura_line_height)
		widget:SetText (spellname)
		widget.spellid = spellid
		widget:Show()
	end
end

--widgets do debuff
	--lista do combat log
	local debuffs_list = CreateFrame ("frame", nil, auraFilterFrame)
	local name = DF:CreateLabel (debuffs_list, "Debuffs", 12, "orange")
	local name2 = DF:CreateLabel (debuffs_list, "click to add to ignore list", 10, "white")
	name:SetPoint ("bottomleft", debuffs_list, "topleft")
	name2:SetPoint ("topleft", name, "bottomleft", 0, -1)
	--lista dos ja banidos
	local debuffs_added_list = CreateFrame ("frame", nil, auraFilterFrame)
	local name = DF:CreateLabel (debuffs_added_list, "Debuffs Ignored", 12, "orange")
	local name2 = DF:CreateLabel (debuffs_list, "click to remove from ignore list", 10, "white")
	name:SetPoint ("bottomleft", debuffs_added_list, "topleft")
	name2:SetPoint ("topleft", name, "bottomleft", 0, -1)

	--lista do combat log
	debuffs_list.widgets = {}
	debuffs_list.spells = ALL_DEBUFFS
	debuffs_list.func = function (self, button, spellid)
		if (not FILTER_DEBUFFS_BANNED [spellid]) then
			FILTER_DEBUFFS_BANNED [spellid] = true
			debuffs_added_list:RefreshWidgets()
		end
	end
	debuffs_list.ResetWidgets = ResetWidgets
	debuffs_list.GetOrCreateWidget = GetOrCreateWidget
	debuffs_list.RefreshWidgets = RefreshWidgets
	debuffs_list.nextWidget = 1

	--lista dos ja banidos
	debuffs_added_list.widgets = {}
	debuffs_added_list.spells = FILTER_DEBUFFS_BANNED
	debuffs_added_list.func = function (self, button, spellid)
		FILTER_DEBUFFS_BANNED [spellid] = nil
		debuffs_added_list:RefreshWidgets()
	end
	debuffs_added_list.ResetWidgets = ResetWidgets
	debuffs_added_list.GetOrCreateWidget = GetOrCreateWidget
	debuffs_added_list.RefreshWidgets = RefreshWidgets
	debuffs_added_list.nextWidget = 1

--widgets do buff
	--lista do combat log
	local buffs_list = CreateFrame ("frame", nil, auraFilterFrame)
	local name = DF:CreateLabel (buffs_list, "Buffs", 12, "orange")
	local name2 = DF:CreateLabel (buffs_list, "click to add to ignore list", 10, "white")
	name:SetPoint ("bottomleft", buffs_list, "topleft")
	name2:SetPoint ("topleft", name, "bottomleft", 0, -1)
	--lista dos ja banidos
	local buffs_added_list = CreateFrame ("frame", nil, auraFilterFrame)
	local name = DF:CreateLabel (buffs_added_list, "Buffs Ignored", 12, "orange")
	local name2 = DF:CreateLabel (buffs_list, "click to remove from ignore list", 10, "white")
	name:SetPoint ("bottomleft", buffs_added_list, "topleft")
	name2:SetPoint ("topleft", name, "bottomleft", 0, -1)

	--lista do combat log
	buffs_list.widgets = {}
	buffs_list.spells = ALL_BUFFS
	buffs_list.func = function (self, button, spellid)
		if (not FILTER_BUFFS_BANNED [spellid]) then
			FILTER_BUFFS_BANNED [spellid] = true
			buffs_added_list:RefreshWidgets()
		end
	end
	buffs_list.ResetWidgets = ResetWidgets
	buffs_list.GetOrCreateWidget = GetOrCreateWidget
	buffs_list.RefreshWidgets = RefreshWidgets
	buffs_list.nextWidget = 1

	--lista dos ja banidos
	buffs_added_list.widgets = {}
	buffs_added_list.spells = FILTER_BUFFS_BANNED
	buffs_added_list.func = function (self, button, spellid)
		FILTER_BUFFS_BANNED [spellid] = nil
		buffs_added_list:RefreshWidgets()
	end
	buffs_added_list.ResetWidgets = ResetWidgets
	buffs_added_list.GetOrCreateWidget = GetOrCreateWidget
	buffs_added_list.RefreshWidgets = RefreshWidgets
	buffs_added_list.nextWidget = 1
	
--seta os pontos
local yLoc = -280
debuffs_list:SetPoint ("topleft", auraFilterFrame, "topleft", 10, yLoc)
buffs_list:SetPoint ("topleft", auraFilterFrame, "topleft", 260, yLoc)
debuffs_added_list:SetPoint ("topleft", auraFilterFrame, "topleft", 520, yLoc)
buffs_added_list:SetPoint ("topleft", auraFilterFrame, "topleft", 780, yLoc)

local allframes = {debuffs_list, buffs_list, debuffs_added_list, buffs_added_list}
for _, frame in ipairs (allframes) do
	frame:SetBackdrop ({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16, edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1})
	frame:SetBackdropColor (0, 0, 0, 0.5)
	frame:SetBackdropBorderColor (0, 0, 0, 0.3)
	frame:SetSize (240, 300)
end

local readCombatLog = CreateFrame ("frame", nil, auraFilterFrame)
readCombatLog:SetScript ("OnEvent", function (self, event, time, token, hidding, sourceGUID, sourceName, sourceFlag, sourceFlag2, targetGUID, targetName, targetFlag, targetFlag2, spellid, spellname, spellschool, auraType, amount)
	if (auraType == "BUFF" and sourceGUID == readCombatLog.playerGUID) then
		if (not ALL_BUFFS [spellid]) then
			ALL_BUFFS [spellid] = true
			buffs_list:RefreshWidgets()
		end
	elseif (auraType == "DEBUFF" and sourceGUID == readCombatLog.playerGUID) then
		if (not ALL_DEBUFFS [spellid]) then
			ALL_DEBUFFS [spellid] = true
			debuffs_list:RefreshWidgets()
		end
	end
end)

auraFilterFrame:SetScript ("OnShow", function()
	--wipe (ALL_DEBUFFS)
	
	for i = 1, BUFF_MAX_DISPLAY do
		--buff
		local name, rank, texture, count, debuffType, duration, expirationTime, caster, _, nameplateShowPersonal, spellId, _, _, _, nameplateShowAll = UnitAura ("player", i, "HELPFUL")
		if (name) then
			ALL_BUFFS [spellId] = true
		end
		--debuff
		local name, rank, texture, count, debuffType, duration, expirationTime, caster, _, nameplateShowPersonal, spellId, _, _, _, nameplateShowAll = UnitAura ("player", i, "HARMFUL")
		if (name) then
			ALL_DEBUFFS [spellId] = true
		end
	end
	
	debuffs_list:RefreshWidgets()
	buffs_list:RefreshWidgets()
	debuffs_added_list:RefreshWidgets()
	buffs_added_list:RefreshWidgets()
	readCombatLog.playerGUID = UnitGUID ("player")
	readCombatLog:RegisterEvent ("COMBAT_LOG_EVENT_UNFILTERED")
end)
auraFilterFrame:SetScript ("OnHide", function()
	readCombatLog:UnregisterEvent ("COMBAT_LOG_EVENT_UNFILTERED")
end)

-------------------------------------------------------------------------------
-- opções para a barra do player ~player
	
	local on_select_player_percent_text_font = function (_, _, value)
		Plater.db.profile.plate_config.player.percent_text_font = value
		Plater.UpdateAllPlates()
	end
	
	local on_select_player_power_percent_text_font = function (_, _, value)
		Plater.db.profile.plate_config.player.power_percent_text_font = value
		Plater.UpdateAllPlates()
	end
	
	local id, name, description, iconWindWalker = GetSpecializationInfoByID (269)
	local id, name, description, iconArcane = GetSpecializationInfoByID (62)
	local id, name, description, iconRune = GetSpecializationInfoByID (250)
	local id, name, description, iconHolyPower = GetSpecializationInfoByID (66)
	local id, name, description, iconRogueCB = GetSpecializationInfoByID (261)
	local id, name, description, iconDruidCB = GetSpecializationInfoByID (103)
	local id, name, description, iconSoulShard = GetSpecializationInfoByID (267)
	
	local locClass = UnitClass ("player")
	
	local options_personal = {
		--life size
		{type = "label", get = function() return "Health Bar Size:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.player.health[1] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.player.health[1] = value
				Plater.db.profile.plate_config.player.health_incombat[1] = value
				Plater.UpdateAllPlates()
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
				Plater.UpdateAllPlates()
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
		{type = "label", get = function() return "Location:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.player.y_position_offset end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.player.y_position_offset = value
				Plater.UpdateAllPlates()
				Plater.UpdateSelfPlate()
			end,
			min = -300,
			max = 300,
			step = 1,
			name = "Y Offset",
			desc = "Adjust the positioning on the Y axis.",
		},

		{type = "breakline"},
		
		--percent text
		{type = "label", get = function() return "Health Percent Text:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
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
		--monk WW chi bar
		{
			type = "range",
			get = function() return Plater.db.profile.resources.MONK.chi_scale end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.resources.MONK.chi_scale = value
				Plater.UpdateAllPlates()
			end,
			min = 0.65,
			max = 3,
			step = 0.01,
			usedecimals = true,
			name = "|T"..iconWindWalker..":0|t Chi Scale",
			desc = "Adjust the scale of this resource.",
		},
		--mage arcane charge
		{
			type = "range",
			get = function() return Plater.db.profile.resources.MAGE.arcane_charge_scale end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.resources.MAGE.arcane_charge_scale = value
				Plater.UpdateAllPlates()
			end,
			min = 0.65,
			max = 3,
			step = 0.01,
			usedecimals = true,
			name = "|T" .. iconArcane .. ":0|t Arcane Charge Scale",
			desc = "Adjust the scale of this resource.",
		},
		--dk rune
		{
			type = "range",
			get = function() return Plater.db.profile.resources.DEATHKNIGHT.rune_scale end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.resources.DEATHKNIGHT.rune_scale = value
				Plater.UpdateAllPlates()
			end,
			min = 0.65,
			max = 3,
			step = 0.01,
			usedecimals = true,
			name = "|T" .. iconRune .. ":0|t Rune Scale",
			desc = "Adjust the scale of this resource.",
		},
		--paladin holy power
		{
			type = "range",
			get = function() return Plater.db.profile.resources.PALADIN.holypower_scale end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.resources.PALADIN.holypower_scale = value
				Plater.UpdateAllPlates()
			end,
			min = 0.65,
			max = 3,
			step = 0.01,
			usedecimals = true,
			name = "|T" .. iconHolyPower .. ":0|t Holy Power Scale",
			desc = "Adjust the scale of this resource.",
		},
		--rogue combo point
		{
			type = "range",
			get = function() return Plater.db.profile.resources.ROGUE.combopoint_scale end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.resources.ROGUE.combopoint_scale = value
				Plater.UpdateAllPlates()
			end,
			min = 0.65,
			max = 3,
			step = 0.01,
			usedecimals = true,
			name = "|T" .. iconRogueCB .. ":0|t Combo Point Scale",
			desc = "Adjust the scale of this resource.",
		},
		--druid feral combo point
		{
			type = "range",
			get = function() return Plater.db.profile.resources.DRUID.combopoint_scale end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.resources.DRUID.combopoint_scale = value
				Plater.UpdateAllPlates()
			end,
			min = 0.65,
			max = 3,
			step = 0.01,
			usedecimals = true,
			name = "|T" .. iconDruidCB .. ":0|t Combo Point Scale",
			desc = "Adjust the scale of this resource.",
		},
		--warlock shard
		{
			type = "range",
			get = function() return Plater.db.profile.resources.WARLOCK.soulshard_scale end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.resources.WARLOCK.soulshard_scale = value
				Plater.UpdateAllPlates()
			end,
			min = 0.65,
			max = 3,
			step = 0.01,
			usedecimals = true,
			name = "|T" .. iconSoulShard .. ":0|t Soul Shard Scale",
			desc = "Adjust the scale of this resource.",
		},

}

DF:BuildMenu (personalPlayerFrame, options_personal, startX, startY, heightSize, true, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template)


-------------------------------------------------------------------------------
--coloca as opções gerais no main menu logo abaixo dos 4 botões
--OPÇÕES NO PAINEL PRINCIPAL

function Plater.ChangeNpcRelavance (_, _, value)
	if (value == 1) then
		Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_NPC].only_relevant = true
		Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_NPC].relevant_and_proffesions = false
		Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_NPC].only_names = false
		Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_NPC].all_names = false
	elseif (value == 2) then
		Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_NPC].only_relevant = true
		Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_NPC].relevant_and_proffesions = true
		Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_NPC].only_names = false
		Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_NPC].all_names = false
	elseif (value == 3) then
		Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_NPC].only_relevant = false
		Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_NPC].relevant_and_proffesions = false
		Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_NPC].only_names = true
		Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_NPC].all_names = false
	elseif (value == 4) then
		Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_NPC].only_relevant = false
		Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_NPC].relevant_and_proffesions = false
		Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_NPC].only_names = false
		Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_NPC].all_names = true
	end
	
	Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_NPC].relevance_state = value
	
	Plater.UpdateAllPlates()
end
local relevance_options = {
	{label = "Only Relevant", value = 1, onclick = Plater.ChangeNpcRelavance},
	{label = "Relevant + Professions", value = 2, onclick = Plater.ChangeNpcRelavance},
	{label = "All Professions", value = 3, onclick = Plater.ChangeNpcRelavance},
	{label = "All Npcs", value = 4, onclick = Plater.ChangeNpcRelavance},
}

function Plater.ChangeNameplateAnchor (_, _, value)
	if (value == 0) then
		SetCVar ("nameplateOtherAtBase", "0")
	elseif (value == 1) then
		SetCVar ("nameplateOtherAtBase", "1")
	elseif (value == 2) then
		SetCVar ("nameplateOtherAtBase", "2")
	end
end
local nameplate_anchor_options = {
	{label = "Head", value = 0, onclick = Plater.ChangeNameplateAnchor, desc = "All nameplates are placed above the character."},
	{label = "Head/Feet", value = 1, onclick = Plater.ChangeNameplateAnchor, desc = "Friendly and neutral has the nameplate on their head, enemies below the feet."},
	{label = "Feet", value = 2, onclick = Plater.ChangeNameplateAnchor, desc = "All nameplates are placed below the character."},
}

	--menu 1 ~general ~geral
	local options_table1 = {
	
		{type = "label", get = function() return "General Appearance:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "toggle",
			get = function() return Plater.db.profile.use_playerclass_color end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.use_playerclass_color = value
				Plater.UpdateUseClassColors()
			end,
			name = "Use Class Colors",
			desc = "Player name plates uses the player class color",
		},
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
			name = "Health Bar Background Color",
			desc = "Color used to paint the health bar background.",
		},
		{
			type = "select",
			get = function() return Plater.db.profile.health_selection_overlay end,
			values = function() return health_selection_overlay_options end,
			name = "Target Overlay Texture",
			desc = "Used above the health bar when it is the current target.",
		},
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
		{
			type = "range",
			get = function() return Plater.db.profile.not_affecting_combat_alpha end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.not_affecting_combat_alpha = value
			end,
			min = 0,
			max = 1,
			step = 0.1,
			name = "Combat Alpha",
			desc = "While you are in combat, set the alpha for other mobs which isn't in combat.",
			usedecimals = true,
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.hover_highlight end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.hover_highlight = value
				Plater.UpdateAllPlates()
			end,
			name = "Highlight",
			desc = "Highlight effect when hovering over a nameplate.",
		},
		{
			type = "range",
			get = function() return Plater.db.profile.hover_highlight_alpha end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.hover_highlight_alpha = value
			end,
			min = 0,
			max = 1,
			step = 0.1,
			name = "Highlight Alpha",
			desc = "Highlight Alpha.",
			usedecimals = true,
		},
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
		
		{type = "breakline"},
		
		{type = "label", get = function() return "Plate Color As a Tank:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
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
			name = "Aggro Color",
			desc = "When you are a Tank and have aggro.",
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
			name = "No Aggro Color",
			desc = "When you are the tank and the mob isn't attacking you.",
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
			name = "High Threat Color",
			desc = "When you are near to pull the aggro from the other tank or group member.",
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
			name = "Not in Combat Color",
			desc = "When you are in combat and the enemy isn't in combat with you or with a member of your group.",
		},
		
		{type = "blank"},
		{type = "label", get = function() return "Plate Color As a Dps:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
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
			name = "Aggro Color",
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
			name = "No Aggro Color",
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
			name = "High Threat Color",
			desc = "When you are neat to pull the aggro.",
		},
		
		{type = "blank"},
		{type = "label", get = function() return "Plate Border Color:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.border_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.border_color
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdatePlateBorders()
			end,
			name = "Color",
			desc = "Color of the plate border.",
		},
		
		{type = "breakline"},
		{type = "label", get = function() return "Icon Indicators:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		
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
		{type = "label", get = function() return "Box Selection Space:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "range",
			get = function() return Plater.db.profile.click_space[1] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.click_space[1] = value
				Plater.UpdatePlateClickSpace (nil, nil, true)
			end,
			min = 50,
			max = 300,
			step = 1,
			name = "Width",
			desc = "How large are area which accepts mouse clicks to select the target",
		},
		{
			type = "range",
			get = function() return Plater.db.profile.click_space[2] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.click_space[2] = value
				Plater.UpdatePlateClickSpace (nil, nil, true)
			end,
			min = 1,
			max = 100,
			step = 1,
			name = "Height",
			desc = "The height of the are area which accepts mouse clicks to select the target",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.click_space_always_show end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.click_space_always_show = value
				Plater.UpdatePlateClickSpace (nil, nil, true)
			end,
			name = "Always Show Background",
			desc = "Enable a background showing the area of the clicable area.",
		},
		
		{type = "breakline"},
		{type = "label", get = function() return "General Settings:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		
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
			get = function() return Plater.CanShowPlateFor (ACTORTYPE_ENEMY_PLAYER) end,
			set = function (self, fixedparam, value) 
				Plater.SetShowActorType (ACTORTYPE_ENEMY_PLAYER, value)
				Plater.UpdateAllPlates()
			end,
			name = "Enemy Players",
			desc = "Show nameplate for enemy players.\n\n|cFFFFFF00Important|r: This option is dependent on the client`s nameplate state (on/off).\n\n|cFFFFFF00Important|r: when disabled but enabled on the client through (" .. (GetBindingKey ("NAMEPLATES") or "") .. ") the healthbar isn't visible but the nameplate is still clickable.",
		},
		{
			type = "toggle",
			get = function() return Plater.CanShowPlateFor (ACTORTYPE_FRIENDLY_NPC) end,
			set = function (self, fixedparam, value) 
				Plater.SetShowActorType (ACTORTYPE_FRIENDLY_NPC, value)
				Plater.UpdateAllPlates()
			end,
			name = "Friendly Npc",
			desc = "Show nameplate for friendly npcs.\n\n|cFFFFFF00Important|r: This option is dependent on the client`s nameplate state (on/off).\n\n|cFFFFFF00Important|r: when disabled but enabled on the client through (" .. (GetBindingKey ("FRIENDNAMEPLATES") or "") .. ") the healthbar isn't visible but the nameplate is still clickable.",
		},
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_NPC].relevance_state end,
			values = function() return relevance_options end,
			name = "Friendly Npc Relevance",
			desc = "Modify the way friendly npcs are shown.\n\n|cFFFFFF00Important|r: This option is dependent on the client`s nameplate state (on/off).",
		},
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
		{
			type = "range",
			get = function() return tonumber (GetCVar ("nameplateMaxDistance")) end,
			set = function (self, fixedparam, value) 
				if (not InCombatLockdown()) then
					SetCVar ("nameplateMaxDistance", value)
				else
					Plater:Msg ("you are in combat.")
				end
			end,
			min = 1,
			max = 100,
			step = 1,
			name = "Nameplate Distance",
			desc = "How far you can see nameplates (in yards).\n\n|cFFFFFFFFDefault: 60|r",
			nocombat = true,
		},
		{
			type = "select",
			get = function() return tonumber (GetCVar ("nameplateOtherAtBase")) end,
			values = function() return nameplate_anchor_options end,
			name = "Nameplate Anchor",
			desc = "Where the nameplate shall anchor.",
			nocombat = true,
		},
		
	}
	
	DF:BuildMenu (generalOptionsAnchor, options_table1, 0, 0, mainHeightSize + 20, true, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template)	
	
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
--FriendlyPC painel de opções ~friendly
	
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
		--health bar size out of combat
		{type = "label", get = function() return "Health Bar Size out of Combat:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.health[1] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.health[1] = value
				Plater.UpdateAllPlates()
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
				Plater.UpdateAllPlates()
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
				Plater.UpdateAllPlates()
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
				Plater.UpdateAllPlates()
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
		
		--percent text
		{type = "label", get = function() return "Health Percent Text:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
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
		
		{type = "blank"},
		{type = "label", get = function() return "Cast Time Text:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
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
		{type = "label", get = function() return "Automatization:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "toggle",
			get = function() return Plater.db.profile.friendlyplates_auto_show end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.friendlyplates_auto_show = value
			end,
			name = "Force Show Friendly",
			desc = "When allowed, the addon try to enable nameplates for friendly characters.",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.friendlyplates_no_on_instances end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.friendlyplates_no_on_instances = value
			end,
			name = "No Friendly on Instances",
			desc = "Forces the addon to shutdown nameplates for friendly characters when entering an instance.",
		},		
		
	}
	DF:BuildMenu (friendlyPCsFrame, options_table3, startX, startY, heightSize, true, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template)

--------------------------------
--Enemy Player painel de opções ~enemy

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
		--health bar size out of combat
		{type = "label", get = function() return "Health Bar Size out of Combat:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.enemyplayer.health[1] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.health[1] = value
				Plater.UpdateAllPlates()
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
				Plater.UpdateAllPlates()
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
				Plater.UpdateAllPlates()
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
				Plater.UpdateAllPlates()
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
		
		--player name size
		{type = "blank"},
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
		
		--plate order
		{type = "blank"},
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
		
		--percent text
		{type = "label", get = function() return "Health Percent Text:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
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
		{type = "label", get = function() return "Cast Time Text:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
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
		
	}
	DF:BuildMenu (enemyPCsFrame, options_table4, startX, startY, heightSize, true, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template)

-----------------------------------------------	
--Friendly NPC painel de opções ~friendly

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
		Plater.UpdateAllPlates()
	end
	
	local on_select_friendlynpc_spellpercent_text_font = function (_, _, value)
		Plater.db.profile.plate_config.friendlynpc.spellpercent_text_font = value
		Plater.UpdateAllPlates()
	end	
	
	--menu 2
	local friendly_npc_options_table = {
	
		--health bar size out of combat
		{type = "label", get = function() return "Health Bar Size out of Combat:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlynpc.health[1] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.health[1] = value
				Plater.UpdateAllPlates()
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
				Plater.UpdateAllPlates()
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
				Plater.UpdateAllPlates()
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
				Plater.UpdateAllPlates()
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
			values = function() return DF:BuildDropDownFontList (on_select_enemy_npcname_font) end,
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
		
		--level text settings
		{type = "blank"},
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
		
		--plate order
		{type = "blank"},
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
		
		{type = "breakline"},
		
		--percent text
		{type = "label", get = function() return "Health Percent Text:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
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
		{type = "label", get = function() return "Quest Color:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		--enabled
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.friendlynpc.quest_enabled end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.quest_enabled = value
				Plater.UpdateAllPlates()
			end,
			name = "Enabled",
			desc = "Nameplates for objectives mobs, now have a new color.",
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
			name = "Friendly Npc",
			desc = "Nameplate has this color when a friendly mob is a quest objective.",
		},		
		
		{type = "blank"},
		{type = "label", get = function() return "Profession Text:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		
		--profession text size
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlynpc.big_actortitle_text_size end,
			set = function (self, fixedparam, value) 
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
			get = function() return Plater.db.profile.plate_config.friendlynpc.big_actortitle_text_font end,
			values = function() return DF:BuildDropDownFontList (on_select_friendlynpc_titletext_text_font) end,
			name = "Font",
			desc = "Font of the text.",
		},
		--profession text shadow
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.friendlynpc.big_actortitle_text_shadow end,
			set = function (self, fixedparam, value) 
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
				local color = Plater.db.profile.plate_config.friendlynpc.big_actortitle_text_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.plate_config.friendlynpc.big_actortitle_text_color
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllPlates()
			end,
			name = "Color",
			desc = "The color of the text.",
		},
		
		{type = "breakline"},
		
		{type = "label", get = function() return "Npc Name Text When no Health Bar Shown:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		
		--profession text size
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlynpc.big_actorname_text_size end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.big_actorname_text_size = value
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
		
		{type = "blank"},
		{type = "label", get = function() return "Cast Time Text:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
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
		
	}
	DF:BuildMenu (friendlyNPCsFrame, friendly_npc_options_table, startX, startY, heightSize, true, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template)

-----------------------------------------------	
--Enemy NPC painel de opções ~enemy

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

	--menu 2 --enemy npc
	local options_table2 = {
		--health bar size out of combat
		{type = "label", get = function() return "Health Bar Size out of Combat:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.enemynpc.health[1] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemynpc.health[1] = value
				Plater.UpdateAllPlates()
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
				Plater.UpdateAllPlates()
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
				Plater.UpdateAllPlates()
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
				Plater.UpdateAllPlates()
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
		
		{type = "breakline"},
		
		--percent text
		{type = "label", get = function() return "Health Percent Text:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
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
		
		{type = "blank"},
		{type = "label", get = function() return "Cast Time Text:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
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
		
		{type = "label", get = function() return "Quest Color:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		--enabled
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.enemynpc.quest_enabled end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemynpc.quest_enabled = value
				Plater.UpdateAllPlates()
			end,
			name = "Enabled",
			desc = "Nameplates for objectives mobs, now have a new color.",
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
				--print (r, g, b)
				Plater.UpdateAllPlates()
			end,
			name = "Hostile Npc",
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
			name = "Neutral Npc",
			desc = "Nameplate has this color when a neutral mob is a quest objective.",
		},			
	
		{type = "blank"},
		{type = "label", get = function() return "Automatization:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "toggle",
			get = function() return Plater.db.profile.enemyplates_only_combat end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.enemyplates_only_combat = value
				if (value) then
					--apenas mostrar durante o combate
					if (not InCombatLockdown()) then
						Plater:PLAYER_REGEN_ENABLED()
					end
				else
					if (not Plater.db.profile.enemyplates_only_in_instances or (Plater.db.profile.enemyplates_only_in_instances and IsInInstance())) then
						if (not InCombatLockdown()) then
							SetCVar (CVAR_ENEMY_ALL, CVAR_ENABLED)
						end
					end
				end
			end,
			name = "Only Show in Combat",
			desc = "Tries to hide enemy nameplates when you aren't in combat.",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.enemyplates_only_in_instances end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.enemyplates_only_in_instances = value
				if (value) then
					Plater:ZONE_CHANGED_NEW_AREA()
				else
					if (Plater.db.profile.enemyplates_only_combat) then
						if (not InCombatLockdown()) then
							Plater:PLAYER_REGEN_ENABLED()
						end
					else
						if (not InCombatLockdown()) then
							SetCVar (CVAR_ENEMY_ALL, CVAR_ENABLED)
						end
					end
					
				end
			end,
			name = "Only on Instances",
			desc = "Tries to hide enemy nameplates when you aren't inside instances.",
		},	
	}
	DF:BuildMenu (enemyNPCsFrame, options_table2, startX, startY, heightSize, true, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template)

end

SLASH_PLATER1 = "/plater"
SLASH_PLATER2 = "/nameplate"
SLASH_PLATER3 = "/nameplates"

local function distance (x1,y1,x2,y2)
	local _,TLx,TLy,BRx,BRy = GetCurrentMapZone()
	local cx = TLx-BRx -- width of zone in yards
	local cy = TLy-BRy -- height of zone in yards
	if cx~=0 and cy~=0 then
		return math.sqrt( ((x1-x2)*cx)^2 + ((y1-y2)*cy)^2 )
	end
end

-- ~cvar
function SlashCmdList.PLATER (msg, editbox)
	if (msg == "t") then
		Plater.ScanTooltip()
		return
	elseif (msg == "p") then
		if (not POSITIONP) then
			POSITIONP = {GetPlayerMapPosition ("player")}
			print ("position saved")
			print ("x:", POSITIONP[1])
			print ("y:", POSITIONP[2])
			
			return
		else
			local x, y = GetPlayerMapPosition ("player")
			local originX, originY = POSITIONP[1], POSITIONP[2]
			
			print ("vdistance: ", distance (x, y, originX, originY))

			return
		end
	elseif (msg == "a") then
	
	end
	Plater.OpenOptionsPanel()
end

local ignored_npcs = {
	[90336] = true, --azurewing whelping - Azsuna
	[88782] = true, --nar'thalas nightwatcher - Azsuna
	[89634] = true, --nar'thalas citizen - Azsuna
	[111625] = true, --warden trainee - Azsuna
}

local ignored_npcs_when_profession = {
	[32751] = true, --warp huntress pet - Dalaran
	[110571] = 1, --delas mooonfang - Dalaran
	[113199] = true, --delas's pet - Dalaran
	[110018] = 1, --gazrix gearlock - Dalaran
	[107622] = true, --glutonia - Dalaran
	[106263] = 1, --earthen ring shaman - Dalaran
	[106262] = 1, --earthen ring shaman - Dalaran
	[97141] = true, --koraud - Dalaran
--	[] = true, --
}

local ignored_factions = {}

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


local npc_types = {
	[100468] = 7,
	[110971] = 7,
	[112007] = 12,
	[96978] = 2,
	[96803] = 12,
	[96819] = 5,
	[93520] = 25,
	[111418] = 7,
	[95688] = 7,
	[96979] = 2,
	[97011] = 2,
	[111323] = 7,
	[96804] = 12,
	[96565] = 7,
	[97856] = 3,
	[99912] = 12,
	[98972] = 7,
	[100550] = 7,
	[92183] = 29,
	[111324] = 2,
	[96805] = 12,
	[96821] = 5,
	[97857] = 3,
	[93538] = 22,
	[111420] = 7,
	[110974] = 2,
	[106655] = 29,
	[98017] = 28,
	[93188] = 24,
	[108504] = 4,
	[96806] = 4,
	[112632] = 12,
	[97858] = 2,
	[93539] = 25,
	[93826] = 1,
	[93189] = 24,
	[93460] = 4,
	[98066] = 7,
	[108537] = 2,
	[96823] = 5,
	[93524] = 27,
	[107326] = 9,
	[108888] = 7,
	[92839] = 2,
	[98720] = 32,
	[96999] = 3,
	[108506] = 2,
	[92457] = 33,
	[96808] = 12,
	[108554] = 4,
	[97860] = 7,
	[93541] = 32,
	[94099] = 4,
	[93940] = 7,
	[92936] = 12,
	[92458] = 33,
	[96809] = 12,
	[108555] = 12,
	[93526] = 34,
	[93542] = 27,
	[100459] = 7,
	[94100] = 2,
	[93447] = 7,
	[96778] = 2,
	[92459] = 31,
	[108556] = 12,
	[97862] = 8,
	[91535] = 2,
	[96779] = 2,
	[92460] = 31,
	[93528] = 21,
	[93544] = 30,
	[98931] = 26,
	[98724] = 9,
	[92684] = 4,
	[88110] = 7,
	[96796] = 4,
	[93529] = 21,
	[98948] = 26,
	[107379] = 1,
	[97004] = 3,
	[96781] = 10,
	[96813] = 7,
	[108559] = 4,
	[99905] = 2,
	[106902] = 1,
	[96479] = 9,
	[93945] = 2,
	[97786] = 4,
	[96782] = 12,
	[108560] = 2,
	[93531] = 28,
	[111675] = 7,
	[96822] = 5,
	[98966] = 7,
	[98161] = 7,
	[97876] = 2,
	[93527] = 34,
	[96990] = 12,
	[93691] = 24,
	[98105] = 7,
	[96980] = 2,
	[96799] = 4,
	[93464] = 2,
	[98106] = 4,
	[97867] = 3,
	[92456] = 33,
	[92464] = 31,
	[92560] = 7,
	[103796] = 4,
	[93532] = 30,
	[79858] = 9,
	[94973] = 7,
	[96975] = 2,
	[108534] = 12,
	[97007] = 2,
	[97865] = 2,
	[92194] = 25,
	[96807] = 4,
	[93523] = 26,
	[97852] = 4,
	[97868] = 7,
	[95844] = 20,
	[95118] = 4,
	[96507] = 8,
	[98124] = 7,
	[93530] = 28,
	[96784] = 12,
	[112866] = 7,
	[96976] = 2,
	[92195] = 30,
	[93522] = 26,
	[89640] = 2,
	[96785] = 12,
	[96801] = 2,
	[96817] = 5,
	[111627] = 2,
	[97869] = 2,
	[93521] = 26,
	[110531] = 3,
	[92242] = 29,
	[99867] = 11,
	[89639] = 4,
	[90639] = 7,
	[93525] = 27,
	[96977] = 2,
	[90638] = 2,
	[92184] = 29,
	[100559] = 7,
	[111327] = 7,
	[96802] = 12,
	[96818] = 5,
	[111624] = 7,
	[97870] = 7,
	[92245] = 2,
	[108553] = 3,
}

function Plater.CheckForNpcType (plateFrame)
	--limpa o tipo do npc
	plateFrame [MEMBER_NPCTYPE] = nil
	plateFrame [MEMBER_NPCID] = nil
	
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
	
	local typeId = npc_types [npcId]
	if (typeId) then
		plateFrame [MEMBER_NPCTYPE] = typeId
		--print ("a nameplate tem npc type:", plateFrame [MEMBER_NPCTYPE])
	else
		return
	end
end

function Plater.GetNpcTypeIcon (npcType)
	if (npcType == 1) then --important npc
		return [[Interface\MINIMAP\ObjectIconsAtlas]], 205/512, 236/512, 137/512, 160/512
	elseif (npcType == 2) then --repair
		return [[Interface\MINIMAP\ObjectIconsAtlas]], 106/512, 132/512, 273/512, 302/512
	elseif (npcType == 3) then --merchant
		return [[Interface\GossipFrame\BankerGossipIcon]], 0, 1, 0, 1
	elseif (npcType == 4) then --innkeeper
		return [[Interface\MINIMAP\ObjectIconsAtlas]], 36/512, 66/512, 442/512, 472/512
	elseif (npcType == 5) then --banker
		return [[Interface\GossipFrame\BankerGossipIcon]], 2/16, 1, 0, 1
	elseif (npcType == 6) then --autioneer
		return [[Interface\GossipFrame\auctioneerGossipIcon]], 0, 1, 0, 1
	elseif (npcType == 7) then --flyght master
		return [[Interface\GossipFrame\TaxiGossipIcon]], 0, 1, 0, 1
	elseif (npcType == 8) then --stable master
		return [[Interface\MINIMAP\ObjectIconsAtlas]], 104/512, 135/512, 442/512, 473/512
	elseif (npcType == 9) then --pet master
		return [[Interface\MINIMAP\ObjectIconsAtlas]], 172/512, 201/512, 273/512, 301/512
	elseif (npcType == 10) then --barber
		return [[]], 0
	elseif (npcType == 11) then --transmogrifier
		return [[Interface\BUTTONS\UI-GroupLoot-DE-Up]], 0, 1, 0, 1
	elseif (npcType == 12) then --food and drink
		return [[Interface\MINIMAP\ObjectIconsAtlas]], 35/512, 66/512, 341/512, 371/512
	elseif (npcType == 20) then --fishing 
		return [[Interface\Garrison\MobileAppIcons]], 0, 127/1024, 779/1024, 910/1024
	elseif (npcType == 21) then --first aid
		return [[Interface\Garrison\MobileAppIcons]], 0, 130/1024, 650/1024, 779/1024
	elseif (npcType == 22) then --archaeology
		return [[Interface\Garrison\MobileAppIcons]], 130/1024, 260/1024, 0, 130/1024
	elseif (npcType == 23) then --cooking
		return [[Interface\Garrison\MobileAppIcons]], 0, 130/1024, 260/1024, 390/1024
	elseif (npcType == 24) then --mining
		return [[Interface\Garrison\MobileAppIcons]], 130/1024, 260/1024, 780/1024, 910/1024
	elseif (npcType == 25) then --engineering
		return [[Interface\Garrison\MobileAppIcons]], 0, 130/1024, 520/1024, 650/1024
	elseif (npcType == 26) then --leatherworking
		return [[Interface\Garrison\MobileAppIcons]], 520/1024, 650/1024, 130/1024, 260/1024
	elseif (npcType == 27) then --tailor
		return [[Interface\Garrison\MobileAppIcons]], 780/1024, 910/1024, 260/1024, 390/1024
	elseif (npcType == 28) then --enchanting
		return [[Interface\Garrison\MobileAppIcons]], 0, 130/1024, 390/1024, 520/1024
	elseif (npcType == 29) then --blacksmith
		return [[Interface\Garrison\MobileAppIcons]], 260/1024, 390/1024, 0, 130/1024
	elseif (npcType == 30) then --inscription
		return [[Interface\Garrison\MobileAppIcons]], 260/1024, 390/1024, 130/1024, 260/1024
	elseif (npcType == 31) then --herbalism
		return [[Interface\Garrison\MobileAppIcons]], 130/1024, 260/1024, 130/1024, 260/1024
	elseif (npcType == 32) then --skinning
		return [[Interface\Garrison\MobileAppIcons]], 650/1024, 780/1024, 260/1024, 390/1024
	elseif (npcType == 33) then --alchemy
		return [[Interface\Garrison\MobileAppIcons]], 0, 125/1024, 0, 130/1024
	elseif (npcType == 34) then --jewelcraft
		return [[Interface\Garrison\MobileAppIcons]], 395/1024, 515/1024, 130/1024, 260/1024
	end
end

--update class color
function Plater.UpdateUnitColor (self, unit)
	
end