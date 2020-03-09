--Plater main software file

--Calls with : are functions imported from the framework
--whenever a variable or function has a --private comment attached to it, means scripts cannot access it (read, write, override), anything else can be overriden with scripts
--with that, you can make your own version of Plater by modifying and overriding functions entirelly using a hooking script, them you can export the script and upload to wago.io (have fun :)
--check the list of available functions and members to override at 'Plater.CanOverride_Functions' and 'Plater.CanOverride_Members'

--Weakauras Scripters: if you need to attach something to Plater nameplates:
-- local namePlate = C_NamePlate.GetNamePlateForUnit (unitID)
-- local unitFrame = namePlate.unitFrame --unitFrame is the main frame where all things is attached, it has SetAllPoints() on the namePlate frame.
-- local healthBar = unitFrame.healthBar
-- local castBar = unitFrame.castBar

-- navigate within the code using search tags: ~color ~border, etc...

 if (true) then
	--return
	--but not today
end

--> details! framework
local DF = _G ["DetailsFramework"]
if (not DF) then
	print ("|cFFFFAA00Plater: framework not found, if you just installed or updated the addon, please restart your client.|r")
	return
end

--/run UIErrorsFrame:HookScript ("OnEnter", function() UIErrorsFrame:EnableMouse (false);Plater:Msg("UIErrorsFrame had MouseEnabled, its disabled now.") end)
--> some WA or addon are enabling the mouse on the error frame making nameplates unclickable
if (UIErrorsFrame) then
	UIErrorsFrame:HookScript ("OnEnter", function()
		--safe disable the mouse on error frame avoiding mouse interactions and warn the user
		UIErrorsFrame:EnableMouse (false)
		Plater:Msg ("something enabled the mouse on UIErrorsFrame, Plater disabled.")
	end)
	UIErrorsFrame:EnableMouse (false)
end

--> blend nameplates with the worldframe
local AlphaBlending = ALPHA_BLEND_AMOUNT + 0.0654785

--> locals
local unpack = unpack
local ipairs = ipairs
local pairs = pairs
local InCombatLockdown = InCombatLockdown
local UnitIsPlayer = UnitIsPlayer
local UnitClassification = UnitClassification
local UnitDetailedThreatSituation = UnitDetailedThreatSituation
local UnitAura = UnitAura
local UnitBuff = UnitBuff
local UnitDebuff = UnitDebuff
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

local LibSharedMedia = LibStub:GetLibrary ("LibSharedMedia-3.0")
local LCG = LibStub:GetLibrary("LibCustomGlow-1.0")
local _

local Plater = DF:CreateAddOn ("Plater", "PlaterDB", PLATER_DEFAULT_SETTINGS, { --options table
	name = "Plater Nameplates",
	type = "group",
	args = {
		
	}
})

--> when a hook script is compiled, it increases the build version, so the handler for running scripts will notice in the change and update the script in real time
local PLATER_HOOK_BUILD = 1
function Plater.IncreaseHookBuildID() --private
	PLATER_HOOK_BUILD = PLATER_HOOK_BUILD + 1
end

--> if a widget has a RefreshID lower than the addon, it needs to be updated
local PLATER_REFRESH_ID = 1
function Plater.IncreaseRefreshID() --private
	PLATER_REFRESH_ID = PLATER_REFRESH_ID + 1
end

--all functions below can be overridden by scripts, hooks or any external code
--this allows the user to fully modify Plater at a high level

--how to override a function:
--create a script in the hooking tab, add a 'Constructor' and a 'Nameplate Created'
--copy the entire function from this file and paste in the constructor, hit save.
--then when the first nameplate appears in the screen the function get rewritten

--for fast debugging is recomended to paste the function in a 'Nameplate Updated' hook so just by saving the script (SHIFT + ENTER) you get the function to update immediately.

Plater.CanOverride_Functions = {
	RefreshDBUpvalues = true, --refresh cache
	RefreshDBLists = true, --refresh cache
	UpdateAuraCache = true, --refresh cache
	
	CreateShowAuraIconAnimation = true, --creates the animation for aura icons played when they are shown
	GetHealthCutoffValue = true, --check if the character has a execute range and enable or disable the health cut off indicators
	CheckRange = true, --check if the player is in range of the unit
	GetSpellForRangeCheck = true, --get a spell to be used in the range check
	SetFontOutlineAndShadow = true, --apply the outline and shadow of a text
	UpdatePersonalBar = true, --update the personal bar
	UpdateResourceFrame = true, --anchors the resource frame (soul shards, combo points, etc)
	UpdateCastbarTargetText = true, --update the settings of the cast target (font color, size, etc)
	UpdateSpellNameSize = true, --receive a fontString and set the length of the spell name size in the cast bar
	QuickHealthUpdate = true, --update the health bar during NAMEPLATE_ADDED
	OnUpdateHealth = true, --when the healthbar get a new health value
	OnUpdateHealthMax = true, --when the maxhealth of the healthbar get updated
	UpdateIconAspecRatio = true, --adjust the icon texcoords depending on its size
	FormatTime = true, --get a number and return it formated into time, e.g. 63 return "1m" 1 minute
	GetAuraIcon = true, --return an icon to be use to show an aura
	AddAura = true, --adds an aura into the nameplate, require all the aura data and an icon
	AddExtraIcon = true, --adds an aura into the extra buff row of icons, require the aura data
	HideNonUsedAuraIcons = true, --after an aura refresh, hide all non used icons in the aura container
	ResetAuraContainer = true, --reset the aura container to be ready to a refresh
	TrackSpecificAuras = true, --refresh the aura container using a list of auras to track
	UpdateAuras_Manual = true, --start an aura refresh for manual aura tracking
	UpdateAuras_Automatic = true, --start an aura refresh for automatic aura tracking
	UpdateAuras_Self_Automatic = true, --start an aura refresh on the personal bar nameplate
	
	ColorOverrider = true, --control which color que nameplate will have when the Override Default Colors are enabled
	FindAndSetNameplateColor = true, --Plater tries to find a color for the nameplate
	SetTextColorByClass = true, --adds the class color into a text with scape sequence
	
	UpdatePlateSize = true, --control the size of health, cast, power bars
	SetPlateBackground = true, --set the backdrop when showing the nameplate area
	UpdateNameplateThread = true, --change the nameplate color based on threat
	UpdateTargetHighlight = true, --adjust the highlight on the player target nameplate
	UpdateTargetIndicator = true, --adjust the target indicator on the player target nameplate
	UpdateLifePercentVisibility = true, --control when the life percent text is shown
	UpdateLifePercentText = true, --update the health shown in the nameplate
	AddGuildNameToPlayerName = true, --adds the guild name into the player name
	UpdateUnitName = true, --update the unit name
	UpdateUnitNameTextSize = true, --controls the length of the unit name text
	UpdateBorderColor = true, --update the color of the border
	UpdatePlateBorderThickness = true, --adjust how thick is the border around the health bar
	UpdatePlateRaidMarker = true, --update the raid marker in the nameplate
	UpdateIndicators = true, --check which indicators will be shown in the nameplate (rare, elite, etc)
	AddIndicator = true, --adds an indicator
	ClearIndicators = true, --clear all indicators in the nameplate
	GetPlateAlpha = true, --get the absolute alpha amount for the nameplate (when in range)
	CheckHighlight = true, --check if the mouse is over the nameplate and show the highlight
	EnableHighlight = true, --enable the highlight check
	DisableHighlight = true, --disable the highlight check
	GetUnitType = true, --return if an unit is a pet, minor or regular
	
	AnimateLeftWithAccel = true, --move the health bar to left when health animation is enabled
	AnimateRightWithAccel = true, --move the health bar to right when health animation is enabled
	UpdateMaxCastbarTextLength = true, --update the length allowed for the spell name text in the cast bar
	IsQuestObjective = true, --check if the npc from the nameplate is a quest mob

}

--store functions and members which can be overridden by scripts
Plater.CanOverride_Members = {
	TargetIndicators = true, --table with all options for target indicators
	TargetHighlights = true, --table with all options for target highlight
	SparkTextures = true, --table with all textures available for castbar sparks
	CooldownEdgeTextures = true, --table with all textures available for cooldown edges
	AurasHorizontalPadding = true, --space in pixels between each row of buffs
	WideIconCoords = true, --used on buff special icons, are the texcoordinates when using wide icons
	BorderLessIconCoords = true, --used on buff special icons, when not using wide icons
	PlayerIsTank = true, --for aggro checks, if true the function will consider the player as tank
	CombatTime = true, --GetTime() of when the player entered in combat, affect aggro animations
	CurrentEncounterID = true, --store the current encounter ID if in combat and fighiting a boss
	LatestEncounter = true, --store time() from the latest ENCOUNTER_END
	ZoneInstanceType = true, --from GetInstanceInfo zone type, can be party, raid, arena, pvp, none
	ZonePvpType = true, --from GetZonePVPInfo
	PlayerGuildName = true, --name of the player's guild
	SpellForRangeCheck = true, --spell name used for range check
	PlayerGUID = true, --store the GUID of the player
	PlayerClass = true, --store the name for the player (non localized)
	
	
	
}

--> types of codes for each script in the Scripting tab (do not change these inside scripts)
Plater.CodeTypeNames = { --private
	[1] = "UpdateCode",
	[2] = "ConstructorCode",
	[3] = "OnHideCode",
	[4] = "OnShowCode",
	[5] = "Initialization",
}

--hook options
--> types of codes available to add in a script in the Hooking tab
Plater.HookScripts = { --private
	"Initialization",
	"Constructor",
	"Destructor",
	"Nameplate Created",
	"Nameplate Added",
	"Nameplate Removed",
	"Nameplate Updated",
	"Cast Start",
	"Cast Update",
	"Cast Stop",
	"Target Changed",
	"Raid Target",
	"Enter Combat",
	"Leave Combat",
	"Player Power Update",
	"Player Talent Update",
	"Health Update",
	"Zone Changed",
	"Name Updated",
	"Load Screen",
	"Player Logon",
}

Plater.HookScriptsDesc = { --private
	["Initialization"] = "Executed once for the mod when it is compiled. Used to initialize the global mod environment 'modTable'.",
	["Constructor"] = "Executed once when the nameplate run the hook for the first time.\n\nUse to initialize configs in the environment.\n\nAlways receive unitFrame in 'self' parameter.",
	["Destructor"] = "Run when the hook is Disabled or unloaded due to Load Conditions.\n\nUse to hide all frames created.\n\n|cFF44FF44Run on all nameplates shown in the screen|r.",
	["Nameplate Created"] = "Executed when a nameplate is created.\n\nRequires a |cFFFFFF22/reload|r after changing the code.",
	["Nameplate Added"] = "Run after a nameplate is added to the screen.",
	["Nameplate Removed"] = "Run when the nameplate is removed from the screen.",
	["Nameplate Updated"] = "Run after the nameplate gets an updated from Plater.\n\n|cFFFFFF22Important:|r doesn't run every frame.",
	
	["Cast Start"] = "When the unit starts to cast a spell.\n\n|cFFFFFF22self|r is unitFrame.castBar",
	["Cast Update"] = "When the cast bar receives an update from Plater.\n\n|cFFFFFF22Important:|r doesn't run every frame.\n\n|cFFFFFF22self|r is unitFrame.castBar",
	["Cast Stop"] = "When the cast is finished for any reason or the nameplate has been removed from the screen.\n\n|cFFFFFF22self|r is unitFrame.castBar",
	
	["Target Changed"] = "Run after the player selects a new target.\n\n|cFF44FF44Run on all nameplates shown in the screen|r.",
	["Raid Target"] = "A raid target mark has added, modified or removed (skull, cross, etc).\n\n|cFF44FF44Run on all nameplates shown in the screen|r.",
	["Enter Combat"] = "Executed shortly after the player enter combat.\n\n|cFF44FF44Run on all nameplates shown in the screen|r.",
	["Leave Combat"] = "Executed shortly after the player leave combat.\n\n|cFF44FF44Run on all nameplates shown in the screen|r.",
	
	["Player Power Update"] = "Run when the player power, such as combo points, gets an update.\n\n|cFF44FF44Run only on the nameplate of your current target|r.",
	["Player Talent Update"] = "When the player changes a talent or specialization.\n\n|cFF44FF44Run on all nameplates shown in the screen|r.",
	
	["Health Update"] = "When the health of the unit changes.",
	["Zone Changed"] = "Run when the player enter into a new zone.\n\n|cFF44FF44Run on all nameplates already created, on screen or not|r.",
	["Name Updated"] = "Executed when the name of the unit shown in the nameplate receives an update.",
	["Load Screen"] = "Run when a load screen finishes.\n\nUse to change settings for a specific area or map.\n\n|cFF44FF44Do not run on nameplates|r.",
	["Player Logon"] = "Run when the player login into the game.\n\nUse to register textures, indicators, etc.\n\n|cFF44FF44Do not run on nameplates,\nrun only once after login\nor /reload|r.",
}

-- ~hook (hook scripts are cached in the indexed part of these tales, for performance the member ScriptAmount caches the amount of scripts inside the indexed table)
local HOOK_NAMEPLATE_ADDED = {ScriptAmount = 0}
local HOOK_NAMEPLATE_CREATED = {ScriptAmount = 0}
local HOOK_NAMEPLATE_REMOVED = {ScriptAmount = 0}
local HOOK_NAMEPLATE_UPDATED = {ScriptAmount = 0}
local HOOK_TARGET_CHANGED = {ScriptAmount = 0}
local HOOK_CAST_START = {ScriptAmount = 0}
local HOOK_CAST_UPDATE = {ScriptAmount = 0}
local HOOK_CAST_STOP = {ScriptAmount = 0}
local HOOK_RAID_TARGET = {ScriptAmount = 0}
local HOOK_COMBAT_ENTER = {ScriptAmount = 0}
local HOOK_COMBAT_LEAVE = {ScriptAmount = 0}
local HOOK_NAMEPLATE_CONSTRUCTOR = {ScriptAmount = 0}
local HOOK_PLAYER_POWER_UPDATE = {ScriptAmount = 0}
local HOOK_PLAYER_TALENT_UPDATE = {ScriptAmount = 0}
local HOOK_HEALTH_UPDATE = {ScriptAmount = 0}
local HOOK_ZONE_CHANGED = {ScriptAmount = 0}
local HOOK_UNITNAME_UPDATE = {ScriptAmount = 0}
local HOOK_LOAD_SCREEN = {ScriptAmount = 0}
local HOOK_PLAYER_LOGON = {ScriptAmount = 0}
local HOOK_MOD_INITIALIZATION = {ScriptAmount = 0}

local PLATER_GLOBAL_MOD_ENV = {}  -- contains modEnv for each mod, identified by "<mod name>"
local PLATER_GLOBAL_SCRIPT_ENV = {} -- contains modEnv for each script, identified by "<script name>"

--> addon comm
local COMM_PLATER_PREFIX = "PLT"
local COMM_SCRIPT_GROUP_EXPORTED = "GE"

--> consts
local BUFF_MAX_DISPLAY = BUFF_MAX_DISPLAY
local CooldownFrame_Set = CooldownFrame_Set

 --> cvars just to make them easier to read
local CVAR_ENABLED = "1"
local CVAR_DISABLED = "0"

--unit reaction
local UNITREACTION_HOSTILE = 3
local UNITREACTION_NEUTRAL = 4
local UNITREACTION_FRIENDLY = 5

--> cache some common used member strings for better reading
local MEMBER_UNITID = "namePlateUnitToken"
local MEMBER_GUID = "namePlateUnitGUID"
local MEMBER_NPCID = "namePlateNpcId"
local MEMBER_QUEST = "namePlateIsQuestObjective"
local MEMBER_REACTION = "namePlateUnitReaction"
local MEMBER_RANGE = "namePlateInRange"
local MEMBER_NOCOMBAT = "namePlateNoCombat"
local MEMBER_NAME = "namePlateUnitName"
local MEMBER_NAMELOWER = "namePlateUnitNameLower"
local MEMBER_TARGET = "namePlateIsTarget"

--> cache nameplate types for better reading the code
local ACTORTYPE_FRIENDLY_PLAYER = "friendlyplayer"
local ACTORTYPE_FRIENDLY_NPC = "friendlynpc"
local ACTORTYPE_ENEMY_PLAYER = "enemyplayer"
local ACTORTYPE_ENEMY_NPC = "enemynpc"
local ACTORTYPE_PLAYER = "player"

--> Aura types for usage in AddAura / AddExtraIcon checks
local AURA_TYPE_ENRAGE = "" -- yes, 'enrage' is just empty string for Blizzard...
local AURA_TYPE_MAGIC = "Magic"
local AURA_TYPE_DISEASE = "Disease"
local AURA_TYPE_POISON = "Poison"
local AURA_TYPE_CURSE = "Curse"
local AURA_TYPE_UNKNOWN = nil

--> As accessible translator map (where nil needs to resemble "NONE") for modding/scripting to be published in .AuraType:
local AURA_TYPES = {
	[""] = "enrage",
	["Magic"] = "magic",
	["Poison"] = "poison",
	["Curse"] = "curse",
	["nil"] = "none",
}

--> icon texcoords
Plater.WideIconCoords = {.1, .9, .1, .6} --used in extra icons frame, constant,  can be changed with scripts
Plater.BorderLessIconCoords = {.1, .9, .1, .9} --used in extra icons frame,constant, can be changed with scripts
--note: regular icons has their texcoords automatically adjusted

--> limit the cast bar text to this (this is dynamically adjusted at run time)
Plater.MaxCastBarTextLength = 200
--> auras 
Plater.MaxAurasPerRow = 10 --can change during runtime

--> textures used in the cooldown animation, scripts can add more values to it, profile holds only the path to it
Plater.CooldownEdgeTextures = {
	[[Interface\AddOns\Plater\images\cooldown_edge_1]],
	[[Interface\AddOns\Plater\images\cooldown_edge_2]],
	"Interface\\Cooldown\\edge",
	"Interface\\Cooldown\\edge-LoC",
	"Interface\\GLUES\\loadingOld",
}

--> textures used in the castbar, scripts can add more values to it, profile holds only the path to it
Plater.SparkTextures = {
	[[Interface\AddOns\Plater\images\spark1]],
	[[Interface\AddOns\Plater\images\spark2]],
	[[Interface\AddOns\Plater\images\spark3]],
	[[Interface\AddOns\Plater\images\spark4]],
	[[Interface\AddOns\Plater\images\spark5]],
	[[Interface\AddOns\Plater\images\spark6]],
	[[Interface\AddOns\Plater\images\spark7]],
	[[Interface\AddOns\Plater\images\spark8]],
}

--> textures used to indicate which nameplate is the current target, scripts can add more values to it, profile holds only the path to it
Plater.TargetHighlights = {
	[[Interface\AddOns\Plater\images\selection_indicator1]],
	[[Interface\AddOns\Plater\images\selection_indicator2]],
	[[Interface\AddOns\Plater\images\selection_indicator3]],
	[[Interface\AddOns\Plater\images\selection_indicator4]],
	[[Interface\AddOns\Plater\images\selection_indicator5]],
	[[Interface\AddOns\Plater\images\selection_indicator6]],
}

--> icons available for any purpose
Plater.Media = {
	Icons = {
		[[Interface\AddOns\Plater\media\arrow_apple_64]],
		[[Interface\AddOns\Plater\media\arrow_double_right_64]],
		[[Interface\AddOns\Plater\media\arrow_right_64]],
		[[Interface\AddOns\Plater\media\arrow_simple_right_64]],
		[[Interface\AddOns\Plater\media\arrow_single_right_64]],
		[[Interface\AddOns\Plater\media\arrow_thin_right_64]],
		[[Interface\AddOns\Plater\media\blocked_center_64]],
		[[Interface\AddOns\Plater\media\crown_64]],
		[[Interface\AddOns\Plater\media\drop_64]],
		[[Interface\AddOns\Plater\media\duck_64]],
		[[Interface\AddOns\Plater\media\exclamation_64]],
		[[Interface\AddOns\Plater\media\exclamation2_64]],
		[[Interface\AddOns\Plater\media\fire_64]],
		[[Interface\AddOns\Plater\media\glasses_64]],
		[[Interface\AddOns\Plater\media\glow_horizontal_256]],
		[[Interface\AddOns\Plater\media\glow_radial_128]],
		[[Interface\AddOns\Plater\media\glow_square_64]],
		[[Interface\AddOns\Plater\media\hat_64]],
		[[Interface\AddOns\Plater\media\heart_center_64]],
		[[Interface\AddOns\Plater\media\line_horizontal_256]],
		[[Interface\AddOns\Plater\media\line_vertical_256]],
		[[Interface\AddOns\Plater\media\radio_64]],
		[[Interface\AddOns\Plater\media\skullbones_64]],
		[[Interface\AddOns\Plater\media\stop_64]],
		[[Interface\AddOns\Plater\media\star_empty_64]],
		[[Interface\AddOns\Plater\media\star_full_64]],
		[[Interface\AddOns\Plater\media\x_64]],
		[[Interface\AddOns\Plater\media\checked_64]],
		[[Interface\AddOns\Plater\media\sphere_full_64]],
		[[Interface\AddOns\Plater\media\eye_64]],
		[[Interface\AddOns\Plater\media\cross_64]],
	},
}

--> these are the images shown in the nameplate of the current target, they are placed in the left and right side of the health bar, scripts can add more options
--> if the coords has 2 tables, it uses two textures attach in the left and right sides of the health bar
--> if the coords has 4 tables, it uses 4 textures attached in top left, bottom left, top right and bottom right corners
Plater.TargetIndicators = {
	["NONE"] = {
		path = [[Interface\ACHIEVEMENTFRAME\UI-Achievement-WoodBorder-Corner]],
		coords = {{.9, 1, .9, 1}, {.9, 1, .9, 1}, {.9, 1, .9, 1}, {.9, 1, .9, 1}}, --texcoords, support 4 or 8 coords method
		desaturated = false,
		width = 10,
		height = 10,
		x = 1, --offset
		y = 1, --offset
	},
	
	["Magneto"] = {
		path = [[Interface\Artifacts\RelicIconFrame]],
		coords = {{0, .5, 0, .5}, {0, .5, .5, 1}, {.5, 1, .5, 1}, {.5, 1, 0, .5}},
		desaturated = false,
		width = 8,
		height = 10,
		x = 2,
		y = 2,
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
		x = 18,
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

--> which specs each class has available
Plater.SpecList = { --private
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

--> default spells to use in the range check proccess, player can select a different spell in the options panel
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

	[265] = 686, --> warlock aff - Shadow Bolt
	[266] = 686, --> warlock demo - Shadow Bolt
	[267] = 116858, --> warlock destro - Chaos Bolt
	
	[71] = 355, --> warrior arms - Taunt
	[72] = 355, --> warrior fury - Taunt
	[73] = 355, --> warrior protect - Taunt
}

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> cached value ~cache
--Plater allocate several values in memory to save performance (cpu), this may increase memory usage
--example: intead of querying Plater.db.profile.tank it just hold a pointer to that table in the variable DB_AGGRO_TANK_COLORS, and this pointer is updated when the user changes something in the options panel

	local DB_NUMBER_REGION_EAST_ASIA
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
	
	local DB_USE_UIPARENT
	
	local DB_UNITCOLOR_CACHE = {}
	local DB_UNITCOLOR_SCRIPT_CACHE = {}

	local DB_AURA_SEPARATE_BUFFS

	local DB_AURA_SHOW_IMPORTANT
	local DB_AURA_SHOW_DISPELLABLE
	local DB_AURA_SHOW_ENRAGE
	local DB_AURA_SHOW_BYPLAYER
	local DB_AURA_SHOW_BYUNIT
	local DB_AURA_PADDING

	local DB_AURA_GROW_DIRECTION --> main aura frame
	local DB_AURA_GROW_DIRECTION2 --> secondary aura frame is adding buffs in a different frame

	local IS_USING_DETAILS_INTEGRATION

	local DB_TRACK_METHOD
	local DB_BORDER_COLOR_R
	local DB_BORDER_COLOR_G
	local DB_BORDER_COLOR_B
	local DB_BORDER_COLOR_A
	local DB_BORDER_THICKNESS
	local DB_AGGRO_CHANGE_HEALTHBAR_COLOR
	local DB_AGGRO_CHANGE_NAME_COLOR
	local DB_AGGRO_CHANGE_BORDER_COLOR
	local DB_AGGRO_CAN_CHECK_NOTANKAGGRO
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
	local DB_USE_NON_TARGETS_ALPHA
	local DB_USE_QUICK_HIDE

	local DB_TEXTURE_CASTBAR
	local DB_TEXTURE_CASTBAR_BG
	local DB_TEXTURE_HEALTHBAR
	local DB_TEXTURE_HEALTHBAR_BG

	local DB_CASTBAR_HIDE_ENEMIES
	local DB_CASTBAR_HIDE_FRIENDLY

	local DB_CAPTURED_SPELLS = {}

	local DB_SHOW_PURGE_IN_EXTRA_ICONS
	local DB_SHOW_ENRAGE_IN_EXTRA_ICONS

	--store the aggro color table for tanks and dps
	local DB_AGGRO_TANK_COLORS
	local DB_AGGRO_DPS_COLORS

	--store if the no combat alpha is enabled
	local DB_NOT_COMBAT_ALPHA_ENABLED
	
	local DB_USE_HEALTHCUTOFF = false
	local DB_HEALTHCUTOFF_AT = 20
	
	--store the npc id cache
	local DB_NPCIDS_CACHE = {}

	local SCRIPT_AURA = {}
	local SCRIPT_CASTBAR = {}
	local SCRIPT_UNIT = {}

	--store aura names to manually track
	local MANUAL_TRACKING_BUFFS = {}
	local MANUAL_TRACKING_DEBUFFS = {}
	local AUTO_TRACKING_EXTRA_BUFFS = {}
	local AUTO_TRACKING_EXTRA_DEBUFFS = {}
	
	--if automatic aura tracking and there's auras to manually track (user added into the buff tracking tab)
	local CAN_TRACK_EXTRA_BUFFS = false
	local CAN_TRACK_EXTRA_DEBUFFS = false
	

	--list of auras the user added into the track list for special auras, _MINE caches the auras where the user checked the 'Only Mine' checkbox
	local SPECIAL_AURAS_USER_LIST = {}
	local SPECIAL_AURAS_USER_LIST_MINE = {}
	--list of auras Plater added automatically to special auras, automatic added auras passes throught black list filters while auras manually added by the user do no
	local SPECIAL_AURAS_AUTO_ADDED = {}
	--caches aura names for crowd control to determine the border color for special auras, if the aura is in this table, the border will be colored with crowd control color
	local CROWDCONTROL_AURA_NAMES = {} 
	
	--spell animations - store a table with information about animation for spells
	local SPELL_WITH_ANIMATIONS = {}
	--cache this inside plater object to access it from the animation editor
	Plater.SPELL_WITH_ANIMATIONS = SPELL_WITH_ANIMATIONS

	--store players which have the tank role in the group
	local TANK_CACHE = {}

	--store pet GUIDs
	local PET_CACHE = {}
	--store pets summoned by the player it self
	Plater.PlayerPetCache = {}

	--store if the player is in combat (not reliable, toggled at regen switch)
	local PLAYER_IN_COMBAT

	--store if the player is not inside an instance
	local IS_IN_OPEN_WORLD = true
	--store if the player is inside a instance (raid or dungeon)
	local IS_IN_INSTANCE = false

	--if true, the animation will update its settings before play
	local IS_EDITING_SPELL_ANIMATIONS = false

	--store a list of friendly players in the player friends list
	Plater.FriendsCache = {}
	
	--store quests the player is in
	Plater.QuestCache = {}
	
	--cache the profile settings for each actor type on this table, so scripts can have access to profile
	Plater.ActorTypeSettingsCache = { --private
		RefreshID = -1,
		--plate holder tables, they will be overriden when updating the cache
		[ACTORTYPE_FRIENDLY_PLAYER] = {},
		[ACTORTYPE_FRIENDLY_NPC] = {},
		[ACTORTYPE_ENEMY_PLAYER] = {},
		[ACTORTYPE_ENEMY_NPC] = {},
		[ACTORTYPE_PLAYER] = {},
	}

	--update the settings cache for scritps
	--this is a table with a copy of the settings from the profile so can be safelly accessed by scripts
	function Plater.UpdateSettingsCache() --private
		if (Plater.ActorTypeSettingsCache.RefreshID >= PLATER_REFRESH_ID) then
			return
		end
		
		local namePlateConfig = Plater.db.profile.plate_config
		Plater.ActorTypeSettingsCache [ACTORTYPE_FRIENDLY_PLAYER] = DF.table.copy ({}, namePlateConfig [ACTORTYPE_FRIENDLY_PLAYER])
		Plater.ActorTypeSettingsCache [ACTORTYPE_FRIENDLY_NPC] = DF.table.copy ({}, namePlateConfig [ACTORTYPE_FRIENDLY_NPC])
		Plater.ActorTypeSettingsCache [ACTORTYPE_ENEMY_PLAYER] = DF.table.copy ({}, namePlateConfig [ACTORTYPE_ENEMY_PLAYER])
		Plater.ActorTypeSettingsCache [ACTORTYPE_ENEMY_NPC] = DF.table.copy ({}, namePlateConfig [ACTORTYPE_ENEMY_NPC])
		Plater.ActorTypeSettingsCache [ACTORTYPE_PLAYER] = DF.table.copy ({}, namePlateConfig [ACTORTYPE_PLAYER])
		
		Plater.ActorTypeSettingsCache.RefreshID = PLATER_REFRESH_ID
	end
	
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> character specific abilities and spells ~spells

	-- ~execute
	--> update if can use execute indicators - this function needs to be updated when a new execute spell is added, removed, modified
	--> in scripts you can use Plater.SetExecuteRange or override this function completelly
	function Plater.GetHealthCutoffValue()
		Plater.SetExecuteRange (false)
		
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
							Plater.SetExecuteRange (true, 0.20)
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
							Plater.SetExecuteRange (true, 0.30)
						end
					end
				end
				
				
			elseif (class == "WARRIOR") then
				--is playing as a Arms warrior?
				local specID = GetSpecializationInfo (spec)
				if (specID and specID ~= 0) then
					if (specID == 71 or specID == 72) then --arms or fury
						Plater.SetExecuteRange (true, 0.20)
						
						if (specID == 71) then --arms
							local _, _, _, using_Massacre = GetTalentInfo (3, 1, 1)
							if (using_Massacre) then
								--if using massacre, execute can be used at 35% health in Arms spec
								Plater.SetExecuteRange (true, 0.35)
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
							Plater.SetExecuteRange (true, 0.35)
						end
					end
				end
			elseif (class == "PALADIN") then
				local specID = GetSpecializationInfo (spec)
				if (specID and specID ~= 0) then
					if (specID == 70) then --retribution paladin
						--> is using hammer of wrath?
						local _, _, _, using_HammerOfWrath = GetTalentInfo (2, 3, 1)
						if (using_HammerOfWrath) then
							Plater.SetExecuteRange (true, 0.2)
						end
					end
				end
			end
		end
	end	

	--> range check ~range
	function Plater.CheckRange (plateFrame, onAdded)

		--value when the unit is in range
		local inRangeAlpha = Plater.db.profile.range_check_in_range_or_target_alpha

		--if is using the no combat alpha and the unit isn't in combat, ignore the range check, no combat alpha is disabled by default
		if (plateFrame [MEMBER_NOCOMBAT]) then
			return
		
		--the unit is friendly or not using range check and non targets alpha
		elseif (plateFrame [MEMBER_REACTION] >= 5 or (not DB_USE_RANGE_CHECK and not DB_USE_NON_TARGETS_ALPHA)) then
			plateFrame.unitFrame:SetAlpha (inRangeAlpha)
			plateFrame [MEMBER_RANGE] = true
			plateFrame.unitFrame [MEMBER_RANGE] = true
			return
		end

		--this unit is target
		local unitIsTarget
		local notTheTarget = false
		--when the unit is out of range and isnt target, alpha is multiplied by this amount
		local alphaMultiplier = 0.70

		--values for when the unit is out of range
		local overallRangeCheckAlpha = Plater.db.profile.range_check_alpha
		local healthBar_rangeCheckAlpha = Plater.db.profile.range_check_health_bar_alpha
		local castBar_rangeCheckAlpha = Plater.db.profile.range_check_cast_bar_alpha
		local buffFrames_rangeCheckAlpha = Plater.db.profile.range_check_buffs_alpha
		local powerBar_rangeCheckAlpha = Plater.db.profile.range_check_power_bar_alpha

		local unitFrame = plateFrame.unitFrame
		local healthBar = unitFrame.healthBar
		local castBar = unitFrame.castBar
		local powerBar = unitFrame.powerBar
		local buffFrame1 = unitFrame.BuffFrame
		local buffFrame2 = unitFrame.BuffFrame2		

		--if "units which is not target" is enabled and the player is targetting something else than the player it self
		if (DB_USE_NON_TARGETS_ALPHA and Plater.PlayerHasTargetNonSelf) then
			if (plateFrame [MEMBER_TARGET]) then
				unitIsTarget = true
			else
				notTheTarget = true
			end

			if (Plater.db.profile.transparency_behavior_use_division) then
				alphaMultiplier = 0.5
			end
		end
 
		--is using the range check by ability
		if (DB_USE_RANGE_CHECK) then
			--check when the unit just has been added to the screen

			if (IsSpellInRange (Plater.SpellForRangeCheck, plateFrame [MEMBER_UNITID]) == 1) then
				--unit is in rage
				if (onAdded) then
					--plateFrame.FadedIn = true

					unitFrame:SetAlpha (inRangeAlpha * (notTheTarget and overallRangeCheckAlpha or 1))
					healthBar:SetAlpha (inRangeAlpha * (notTheTarget and healthBar_rangeCheckAlpha or 1))
					castBar:SetAlpha (inRangeAlpha * (notTheTarget and castBar_rangeCheckAlpha or 1))
					powerBar:SetAlpha (inRangeAlpha * (notTheTarget and powerBar_rangeCheckAlpha or 1))
					buffFrame1:SetAlpha (inRangeAlpha * (notTheTarget and buffFrames_rangeCheckAlpha or 1))
					buffFrame2:SetAlpha (inRangeAlpha * (notTheTarget and buffFrames_rangeCheckAlpha or 1))

					plateFrame [MEMBER_RANGE] = true
					plateFrame.unitFrame [MEMBER_RANGE] = true

				else
					local healthBarNewAlpha = inRangeAlpha * (notTheTarget and healthBar_rangeCheckAlpha or 1)
					if (not DF:IsNearlyEqual (healthBar:GetAlpha(), healthBarNewAlpha, 0.01)) then
						--play animations (animation aren't while in development)
						unitFrame:SetAlpha (inRangeAlpha * (notTheTarget and overallRangeCheckAlpha or 1))
						healthBar:SetAlpha (healthBarNewAlpha)
						castBar:SetAlpha (inRangeAlpha * (notTheTarget and castBar_rangeCheckAlpha or 1))
						powerBar:SetAlpha (inRangeAlpha * (notTheTarget and powerBar_rangeCheckAlpha or 1))
						buffFrame1:SetAlpha (inRangeAlpha * (notTheTarget and buffFrames_rangeCheckAlpha or 1))
						buffFrame2:SetAlpha (inRangeAlpha * (notTheTarget and buffFrames_rangeCheckAlpha or 1))
					end

					plateFrame [MEMBER_RANGE] = true
					plateFrame.unitFrame [MEMBER_RANGE] = true
				end
			else
				--unit is out of range
				if (onAdded) then
					plateFrame.FadedIn = nil

--					unitFrame:SetAlpha (overallRangeCheckAlpha * (notTheTarget and overallRangeCheckAlpha or 1))
--					healthBar:SetAlpha (healthBar_rangeCheckAlpha * (notTheTarget and healthBar_rangeCheckAlpha or 1))
--					castBar:SetAlpha (castBar_rangeCheckAlpha * (notTheTarget and castBar_rangeCheckAlpha or 1))
--					powerBar:SetAlpha (powerBar_rangeCheckAlpha * (notTheTarget and powerBar_rangeCheckAlpha or 1))
--					buffFrame1:SetAlpha (buffFrames_rangeCheckAlpha * (notTheTarget and buffFrames_rangeCheckAlpha or 1))
--					buffFrame2:SetAlpha (buffFrames_rangeCheckAlpha * (notTheTarget and buffFrames_rangeCheckAlpha or 1))

					unitFrame:SetAlpha (overallRangeCheckAlpha * (notTheTarget and alphaMultiplier or 1))
					healthBar:SetAlpha (healthBar_rangeCheckAlpha * (notTheTarget and alphaMultiplier or 1))
					castBar:SetAlpha (castBar_rangeCheckAlpha * (notTheTarget and alphaMultiplier  or 1))
					powerBar:SetAlpha (powerBar_rangeCheckAlpha * (notTheTarget and alphaMultiplier or 1))
					buffFrame1:SetAlpha (buffFrames_rangeCheckAlpha * (notTheTarget and alphaMultiplier or 1))
					buffFrame2:SetAlpha (buffFrames_rangeCheckAlpha * (notTheTarget and alphaMultiplier or 1))

					plateFrame [MEMBER_RANGE] = false
					plateFrame.unitFrame [MEMBER_RANGE] = false

				else
					local healthBarNewAlpha = healthBar_rangeCheckAlpha * (notTheTarget and healthBar_rangeCheckAlpha or 1)
					if (not DF:IsNearlyEqual (healthBar:GetAlpha(), healthBarNewAlpha, 0.01)) then
						
						--play animations (animation aren't while in development)
--						unitFrame:SetAlpha (overallRangeCheckAlpha * (notTheTarget and overallRangeCheckAlpha or 1))
--						healthBar:SetAlpha (healthBar_rangeCheckAlpha * (notTheTarget and healthBar_rangeCheckAlpha or 1))
--						castBar:SetAlpha (castBar_rangeCheckAlpha * (notTheTarget and castBar_rangeCheckAlpha or 1))
--						powerBar:SetAlpha (powerBar_rangeCheckAlpha * (notTheTarget and powerBar_rangeCheckAlpha or 1))
--						buffFrame1:SetAlpha (buffFrames_rangeCheckAlpha * (notTheTarget and buffFrames_rangeCheckAlpha or 1))
--						buffFrame2:SetAlpha (buffFrames_rangeCheckAlpha * (notTheTarget and buffFrames_rangeCheckAlpha or 1))
						
						unitFrame:SetAlpha (overallRangeCheckAlpha * (notTheTarget and alphaMultiplier or 1))
						healthBar:SetAlpha (healthBar_rangeCheckAlpha * (notTheTarget and alphaMultiplier or 1))
						castBar:SetAlpha (castBar_rangeCheckAlpha * (notTheTarget and alphaMultiplier  or 1))
						powerBar:SetAlpha (powerBar_rangeCheckAlpha * (notTheTarget and alphaMultiplier or 1))
						buffFrame1:SetAlpha (buffFrames_rangeCheckAlpha * (notTheTarget and alphaMultiplier or 1))
						buffFrame2:SetAlpha (buffFrames_rangeCheckAlpha * (notTheTarget and alphaMultiplier or 1))

					end
					plateFrame [MEMBER_RANGE] = false
					plateFrame.unitFrame [MEMBER_RANGE] = false
				end
			end

		--range check isnt enabled, check is no target alpha is
		elseif (DB_USE_NON_TARGETS_ALPHA) then
			
			--player has a target other than him self?
			if (Plater.PlayerHasTargetNonSelf) then
				--is this unit is the current player target?
				if (unitIsTarget) then
					if (not DF:IsNearlyEqual (healthBar:GetAlpha(), inRangeAlpha, 0.01)) then
						unitFrame:SetAlpha (inRangeAlpha)
						healthBar:SetAlpha (inRangeAlpha)
						castBar:SetAlpha (inRangeAlpha)
						powerBar:SetAlpha (inRangeAlpha)
						buffFrame1:SetAlpha (inRangeAlpha)
						buffFrame2:SetAlpha (inRangeAlpha)
					end
					plateFrame.FadedIn = true

				else
					--this unit isnt the current player target
					if (not DF:IsNearlyEqual (healthBar:GetAlpha(), inRangeAlpha * healthBar_rangeCheckAlpha, 0.01)) then
						unitFrame:SetAlpha (inRangeAlpha * overallRangeCheckAlpha)
						healthBar:SetAlpha (inRangeAlpha * healthBar_rangeCheckAlpha)
						castBar:SetAlpha (inRangeAlpha * castBar_rangeCheckAlpha)
						powerBar:SetAlpha (inRangeAlpha * powerBar_rangeCheckAlpha)
						buffFrame1:SetAlpha (inRangeAlpha * buffFrames_rangeCheckAlpha)
						buffFrame2:SetAlpha (inRangeAlpha * buffFrames_rangeCheckAlpha)
					end
					plateFrame.FadedIn = nil
				end
			else
				--player does not have a target, so just set to regular alpha
				plateFrame.FadedIn = true
				plateFrame.unitFrame:SetAlpha (inRangeAlpha)
				healthBar:SetAlpha (1)
				castBar:SetAlpha (1)
				powerBar:SetAlpha (1)
				buffFrame1:SetAlpha (1)
				buffFrame2:SetAlpha (1)
			end
		else
			-- no alpha settings, so just go to default
			plateFrame.FadedIn = true
			unitFrame:SetAlpha (inRangeAlpha)
			healthBar:SetAlpha (1)
			castBar:SetAlpha (1)
			powerBar:SetAlpha (1)
			buffFrame1:SetAlpha (1)
			buffFrame2:SetAlpha (1)
		end
	end	
	
	local re_GetSpellForRangeCheck = function()
		Plater.GetSpellForRangeCheck()
	end

	--> execute after player logon or when the player changes its spec
	function Plater.GetSpellForRangeCheck()
		Plater.SpellBookForRangeCheck = nil

		local specIndex = GetSpecialization()
		if (specIndex) then
			local specID = GetSpecializationInfo (specIndex)
			if (specID and specID ~= 0) then
				--the local character saved variable hold the spell name used for the range check
				Plater.SpellForRangeCheck = PlaterDBChr.spellRangeCheck [specID]
				
				--getting the spell slot from the spellbook doesn't fix the problem with the demonhunter taunt ability
				--the rest of the code of this function is disabled, maybe in the future I'll revisit it

				--[=[
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
				--]=]
			else
				C_Timer.After (5, re_GetSpellForRangeCheck)
			end
		else
			C_Timer.After (5, re_GetSpellForRangeCheck)
		end

	end	

	-- ~tank --todo: make these functions be inside the Plater object
	--true if the 'player' unit is a tank
	local function IsPlayerEffectivelyTank()
		local assignedRole = UnitGroupRolesAssigned ("player")
		if (assignedRole == "NONE") then
			local spec = GetSpecialization()
			return spec and GetSpecializationRole (spec) == "TANK"
		end
		return assignedRole == "TANK"
	end

	--return true if the unit is in tank role
	local function IsUnitEffectivelyTank (unit)
		return UnitGroupRolesAssigned (unit) == "TANK"
	end
	
	--iterate among group members and store the names of all tanks in the group
	--this is called when the player enter, leave or when the group roster is changed
	--tank cache is used mostly in the aggro check to know if the player is a tank
	function Plater.RefreshTankCache() --private
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
		
		--is in group and is inside a dungeon
		--there's only one tank on dungeon but dps may see if a unit is not in the tank aggro
		elseif (IsInGroup() and Plater.ZoneInstanceType == "party") then
			for i = 1, GetNumGroupMembers() -1 do
				if (IsUnitEffectivelyTank ("party" .. i)) then
					if (not UnitIsUnit ("party" .. i, "player")) then
						TANK_CACHE [UnitName ("party" .. i)] = true
					end
				end
			end
		end
	end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> general unit functions

	--> return a table with points on where the unitFrame is attached
	--these points are hardcoded in the UpdatePlateSize() function
	function Plater.GetPoints (unitFrame)
		local points = {
			{"topleft", unitFrame.PlateFrame, "topleft", 0, 0},
			{"bottomright", unitFrame.PlateFrame, "bottomright", 0, 0},
		}
		return points
	end

	--> return an iterator with all namepaltes on the screen
	function Plater.GetAllShownPlates() --private
		return C_NamePlate.GetNamePlates()
	end

	--> returns if the unit is tapped (gray health color when another player hit the unit first) 
	function Plater.IsUnitTapDenied (unitID)
		return unitID and not UnitPlayerControlled (unitID) and UnitIsTapDenied (unitID)
	end

	--> returns what member from the profile need to be used, since there's entries for in combat and out of combat
	function Plater.GetHashKey (inCombat) --private
		if (PLAYER_IN_COMBAT or inCombat) then
			return "cast_incombat", "health_incombat", "mana_incombat"
		else
			return "cast", "health", "mana"
		end
	end

	--> return true if the resource bar should shown above the nameplate in the current target nameplate
	function Plater.IsShowingResourcesOnTarget() --private
		return PlaterDBChr.resources_on_target
	end
	
	--> when the player left a zone but is in combat, wait 1 second and trigger the zone changed again
	local wait_for_leave_combat = function()
		Plater.RunFunctionForEvent ("ZONE_CHANGED_NEW_AREA")
	end

	--> when the auto toggle function is called but the player is in combat
	local re_RefreshAutoToggle = function()
		return Plater.RefreshAutoToggle()
	end
	
	--> when the player enter in the world, wait a few seconds to get the guild name data
	local delayed_guildname_check = function()
		Plater.PlayerGuildName = GetGuildInfo ("player")
		if (not Plater.PlayerGuildName or Plater.PlayerGuildName == "") then
			Plater.PlayerGuildName = "ThePlayerHasNoGuildName/30Char"
		end
	end
	
	--> run a scheduled update for a nameplate, functions can create schedules when some events are triggered when the client doesn't have the data yet
	function Plater.RunScheduledUpdate (timerObject) --private
		local plateFrame = timerObject.plateFrame
		local unitGUID = timerObject.GUID
		
		--checking the serial of the unit is the same in case this nameplate is being used on another unit
		if (plateFrame:IsShown() and unitGUID == plateFrame [MEMBER_GUID]) then
			--save user input data (usualy set from scripts) before call the unit added event
				local unitFrame = plateFrame.unitFrame
				local customHealthBarWidth = unitFrame.customHealthBarWidth
				local customHealthBarHeight = unitFrame.customHealthBarHeight
				
				local customCastBarWidth = unitFrame.customCastBarWidth
				local customCastBarHeight = unitFrame.customCastBarHeight
				
				local customPowerBarWidth = unitFrame.customPowerBarWidth
				local customPowerBarHeight = unitFrame.customPowerBarHeight
				
				local customBorderColor = unitFrame.customBorderColor
			
			--full refresh the nameplate, this will override user data from scripts
			Plater.RunFunctionForEvent ("NAME_PLATE_UNIT_ADDED", unitFrame [MEMBER_UNITID])
			
			--restore user input data
				unitFrame.customHealthBarWidth = customHealthBarWidth
				unitFrame.customHealthBarHeight = customHealthBarHeight
				
				unitFrame.customCastBarWidth = customCastBarWidth
				unitFrame.customCastBarHeight = customCastBarHeight
				
				unitFrame.customPowerBarWidth = customPowerBarWidth
				unitFrame.customPowerBarHeight = customPowerBarHeight

				if (	customHealthBarWidth or
					customHealthBarHeight or
					customCastBarWidth or
					customCastBarHeight or
					customPowerBarWidth or
					customPowerBarHeight
				) then
					Plater.UpdatePlateSize (plateFrame)
				end
				
				unitFrame.customBorderColor = customBorderColor
				if (unitFrame.customBorderColor) then
					Plater.UpdateBorderColor (plateFrame.unitFrame)
				end
		end
	end
	
	--run a delayed update on the namepalte, this is used when the client receives an information from the server but does not update the state immediately
	--this usualy happens with faction and flag changes
	function Plater.ScheduleUpdateForNameplate (plateFrame) --private
		--check if there's already an update scheduled for this unit
		if (plateFrame.HasUpdateScheduled and not plateFrame.HasUpdateScheduled._cancelled) then
			return
		else
			plateFrame.HasUpdateScheduled = C_Timer.NewTimer (0.75, Plater.RunScheduledUpdate)
			plateFrame.HasUpdateScheduled.plateFrame = plateFrame
			plateFrame.HasUpdateScheduled.GUID = plateFrame [MEMBER_GUID]
		end
	end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> settings functions

	-- ~profile
	--refreshes the values for the profile when the profile is loaded or changed
	function Plater:RefreshConfig() --private
		Plater.IncreaseRefreshID()

		Plater.RefreshDBUpvalues()
		
		Plater.UpdateAllPlates()
		
		if (PlaterOptionsPanelFrame) then
			PlaterOptionsPanelFrame.RefreshOptionsFrame()
		end
		
		Plater.UpdateSettingsCache()
	end
	
	function Plater:RefreshConfigProfileChanged() --private
		Plater:RefreshConfig()
		
		--call the user to /reload his UI
		DF:ShowPromptPanel ("Plater profile changed, do you want /reload now (recommended)?", function() ReloadUI() end, function() end, true, 500)
	end
	
	--~save ~cvar
	--on logout or on profile change, save some important cvars inside the profile
	function Plater.SaveConsoleVariables() --private
		local cvarTable = Plater.db.profile.saved_cvars
		
		if (not cvarTable) then
			return
		end
		
		--> personal and resources
		cvarTable ["nameplateShowSelf"] = GetCVar ("nameplateShowSelf")
		cvarTable ["nameplateResourceOnTarget"] = GetCVar ("nameplateResourceOnTarget")
		cvarTable ["nameplatePersonalShowAlways"] = GetCVar ("nameplatePersonalShowAlways")
		cvarTable ["nameplatePersonalShowWithTarget"] = GetCVar ("nameplatePersonalShowWithTarget")
		cvarTable ["nameplatePersonalShowInCombat"] = GetCVar ("nameplatePersonalShowInCombat")
		cvarTable ["nameplateSelfAlpha"] = GetCVar ("nameplateSelfAlpha")
		cvarTable ["nameplateSelfScale"] = GetCVar ("nameplateSelfScale")
		
		--> which nameplates to show
		cvarTable ["nameplateShowAll"] = GetCVar ("nameplateShowAll")
		cvarTable ["ShowNamePlateLoseAggroFlash"] = GetCVar ("ShowNamePlateLoseAggroFlash")
		cvarTable ["nameplateShowEnemyMinions"] = GetCVar ("nameplateShowEnemyMinions")
		cvarTable ["nameplateShowEnemyMinus"] = GetCVar ("nameplateShowEnemyMinus")
		cvarTable ["nameplateShowFriendlyGuardians"] = GetCVar ("nameplateShowFriendlyGuardians")
		cvarTable ["nameplateShowFriendlyPets"] = GetCVar ("nameplateShowFriendlyPets")
		cvarTable ["nameplateShowFriendlyTotems"] = GetCVar ("nameplateShowFriendlyTotems")
		cvarTable ["nameplateShowFriendlyMinions"] = GetCVar ("nameplateShowFriendlyMinions")
		
		--> make it show the class color of players
		cvarTable ["ShowClassColorInNameplate"] = GetCVar ("ShowClassColorInNameplate")
		
		--> just reset to default the clamp from the top side
		cvarTable ["nameplateOtherTopInset"] = GetCVar ("nameplateOtherTopInset")
		
		--> reset the horizontal and vertical scale
		cvarTable ["NamePlateHorizontalScale"] = GetCVar ("NamePlateHorizontalScale")
		cvarTable ["NamePlateVerticalScale"] = GetCVar ("NamePlateVerticalScale")
		
		--> stacking nameplates
		cvarTable ["nameplateMotion"] = GetCVar ("nameplateMotion")
		
		--> make the selection be a little bigger
		cvarTable ["nameplateSelectedScale"] = GetCVar ("nameplateSelectedScale")
		cvarTable ["nameplateMinScale"] = GetCVar ("nameplateMinScale")
		cvarTable ["nameplateGlobalScale"] = GetCVar ("nameplateGlobalScale")
		
		--> distance between each nameplate when using stacking
		cvarTable ["nameplateOverlapV"] = GetCVar ("nameplateOverlapV")
		
		--> movement speed of nameplates when using stacking, going above this isn't recommended
		cvarTable ["nameplateMotionSpeed"] = GetCVar ("nameplateMotionSpeed")
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
		cvarTable ["nameplateMaxDistance"] = GetCVar ("nameplateMaxDistance")
		
	end

	--refresh call back will run all functions in its table when Plater refreshes the dynamic upvales for the file
	Plater.DBRefreshCallback = {}
	function Plater.RegisterRefreshDBCallback (func) --private
		DF.table.addunique (Plater.DBRefreshCallback, func)
	end
	function Plater.FireRefreshDBCallback() --private
		for _, func in ipairs (Plater.DBRefreshCallback) do
			DF:Dispatch (func)
		end
	end

	--> place most used data into local upvalues to save process time
	--> scripts need to call this function if they change something in the profile
	function Plater.RefreshDBUpvalues()
		local profile = Plater.db.profile

		DB_NUMBER_REGION_EAST_ASIA = Plater.db.profile.number_region == "eastasia"
		
		DB_TICK_THROTTLE = profile.update_throttle
		DB_LERP_COLOR = profile.use_color_lerp
		DB_LERP_COLOR_SPEED = profile.color_lerp_speed
		DB_PLATE_CONFIG = profile.plate_config
		DB_TRACK_METHOD = profile.aura_tracker.track_method
		
		DB_DO_ANIMATIONS = profile.use_health_animation
		DB_ANIMATION_TIME_DILATATION = profile.health_animation_time_dilatation
		
		DB_HOVER_HIGHLIGHT = profile.hover_highlight
		DB_USE_RANGE_CHECK = profile.range_check_enabled
		DB_USE_NON_TARGETS_ALPHA = profile.non_targeted_alpha_enabled
		DB_USE_QUICK_HIDE = profile.quick_hide
		
		DB_NPCIDS_CACHE = Plater.db.profile.npc_cache
		
		DB_USE_UIPARENT = profile.use_ui_parent
		
		DB_BORDER_COLOR_R = profile.border_color [1]
		DB_BORDER_COLOR_G = profile.border_color [2]
		DB_BORDER_COLOR_B = profile.border_color [3]
		DB_BORDER_COLOR_A = profile.border_color [4]
		DB_BORDER_THICKNESS = profile.border_thickness
		DB_AGGRO_CHANGE_HEALTHBAR_COLOR = profile.aggro_modifies.health_bar_color
		DB_AGGRO_CHANGE_BORDER_COLOR = profile.aggro_modifies.border_color
		DB_AGGRO_CHANGE_NAME_COLOR = profile.aggro_modifies.actor_name_color
		DB_AGGRO_CAN_CHECK_NOTANKAGGRO = profile.aggro_can_check_notank
		
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
		DB_SHOW_ENRAGE_IN_EXTRA_ICONS = profile.extra_icon_show_enrage
		
		--refresh cast bar text max size
		Plater.UpdateMaxCastbarTextLength()
		
		--refresh lists
		Plater.RefreshDBLists()
		Plater.RefreshAuraCache()
		Plater.RefreshResourcesDBUpvalues() --~resources
	end

	-- ~db
	function Plater.RefreshAuraCache()
		local profile = Plater.db.profile
		
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
		DB_AURA_SHOW_ENRAGE = profile.aura_show_enrage
		DB_AURA_SHOW_BYPLAYER = profile.aura_show_aura_by_the_player
		DB_AURA_SHOW_BYUNIT = profile.aura_show_buff_by_the_unit
		DB_AURA_PADDING = profile.aura_padding

		DB_AURA_GROW_DIRECTION = profile.aura_grow_direction
		DB_AURA_GROW_DIRECTION2 = profile.aura2_grow_direction
		
		Plater.MaxAurasPerRow = floor (profile.plate_config.enemynpc.health_incombat[1] / (profile.aura_width + DB_AURA_PADDING))
	end
	
	function Plater.RefreshDBLists()

		local profile = Plater.db.profile

		wipe (SPELL_WITH_ANIMATIONS)
		
		if (profile.spell_animations) then
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
					
					SPELL_WITH_ANIMATIONS [spellName] = frameAnimations
				end
				
			end
		end

		--list of auras the user added into the track list for special auras
		wipe (SPECIAL_AURAS_USER_LIST)
		wipe (SPECIAL_AURAS_USER_LIST_MINE)
		
		--list of auras Plater added automatically to special auras
		wipe (SPECIAL_AURAS_AUTO_ADDED)
		
		--crown control spells for the border in the special auras
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
					SPECIAL_AURAS_AUTO_ADDED [spellName] = true
					CROWDCONTROL_AURA_NAMES [spellName] = true
				end
			end
		end
		
		--> add auras added by the player into the special aura container
		for index, spellId in ipairs (profile.extra_icon_auras) do
			local spellName = GetSpellInfo (spellId)
			if (spellName) then
				SPECIAL_AURAS_USER_LIST [spellId] = true
			end
		end
		
		for spellId, state in pairs (profile.extra_icon_auras_mine) do
			if (state) then
				local spellName = GetSpellInfo (spellId)
				if (spellName) then
					--> mine list only store if the user checked the 'only mine' box
					--> if the user remove the spell, that spell isn't removed from the 'only mine' list
					--> so need to check if the spell on 'only mine' list is included in the special aura list
					if (SPECIAL_AURAS_USER_LIST [spellId]) then
						SPECIAL_AURAS_USER_LIST_MINE [spellId] = true
					end
				end
			end
		end
		
		--> build the list of npcs with special colors
		wipe (DB_UNITCOLOR_CACHE) --regular color overrides the threat color
		wipe (DB_UNITCOLOR_SCRIPT_CACHE) --color only used for scripts, plater does not use them 
		
		for npcID, infoTable in pairs (Plater.db.profile.npc_colors) do
			local enabled1 = infoTable [1] --this is the overall enabled
			local enabled2 = infoTable [2] --if this is true, this color is only used for scripts
			local colorID = infoTable [3] --the color
			
			if (enabled1 and not enabled2) then
				local r, g, b = DF:ParseColors (colorID)
				DB_UNITCOLOR_CACHE [npcID] = {r, g, b, 1}
				
			elseif (enabled1 and enabled2) then
				local r, g, b = DF:ParseColors (colorID)
				DB_UNITCOLOR_SCRIPT_CACHE [npcID] = {r, g, b, 1}
				
			end
		end
		
		Plater.UpdateAuraCache()
		Plater.IncreaseRefreshID()
		
		Plater.FireRefreshDBCallback()
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

	--a patch is a function stored in the Plater_ScriptLibrary file and are executed only once to change a profile setting, remove or add an aura into the tracker or modify a script
	--patch versions are stored within the profile, so importing or creating a new profile will apply all patches that wasn't applyed into it yet
	function Plater.ApplyPatches() --private
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
			
			--do not clear patch library, when creating a new profile it'll need to re-apply patches
			--PlaterPatchLibrary = nil
		end
	end
	
	--when using UIParent as the parent for the unitFrame, this function is hooked in the plateFrame OnSizeChanged script
	--the goal is to adjust the the unitFrame scale when the plateFrame scale changes
	--this approach also solves the issue to the unitFrame not playing correctly the animation when the nameplate is removed from the screen
	--self is plateFrame, w, h aren't reliable
	function Plater.UpdateUIParentScale (self, w, h) --private 
		if (self.unitFrame) then
			local defaultScale = self:GetEffectiveScale()
			if (defaultScale < 0.4) then
				--assuming the nameplate is in process of being removed from the screen if the scale if lower than .4
				self.unitFrame:SetScale (defaultScale)
			else
				--scale (adding a fine tune knob)
				local scaleFineTune = max (Plater.db.profile.ui_parent_scale_tune, 0.3)
				
				--@Ariani - March, 9
				self.unitFrame:SetScale (defaultScale * scaleFineTune)
				
				--@Tercio
				--self.unitFrame:SetScale (Clamp (defaultScale + scaleFineTune, 0.01, 5))
			end
		end
	end
	
	--this reset the UIParent levels to user default set on the UIParent tab
	--there's an api that calls this function called Plater.RefreshNameplateStrata()
	function Plater.UpdateUIParentLevels (unitFrame) --private
		if (DB_USE_UIPARENT) then
			--setup frame strata and levels
			local profile = Plater.db.profile
			local castBar = unitFrame.castBar
			local buffFrame1 = unitFrame.BuffFrame
			local buffFrame2 = unitFrame.BuffFrame2
			--strata
			unitFrame:SetFrameStrata (profile.ui_parent_base_strata)
			castBar:SetFrameStrata (profile.ui_parent_cast_strata)
			buffFrame1:SetFrameStrata (profile.ui_parent_buff_strata)
			buffFrame2:SetFrameStrata (profile.ui_parent_buff2_strata)
			--level
			castBar:SetFrameLevel (profile.ui_parent_cast_level)
			buffFrame1:SetFrameLevel (profile.ui_parent_buff_level)
			buffFrame2:SetFrameLevel (profile.ui_parent_buff2_level)
			
			--raid-target marker adjust:
			unitFrame.PlaterRaidTargetFrame:SetFrameStrata(unitFrame.healthBar:GetFrameStrata())
			unitFrame.PlaterRaidTargetFrame:SetFrameLevel(unitFrame.healthBar:GetFrameLevel() + 25)
		end
	end	
	
	--move the target nameplate to its strata
	--also need to move other frame components of this nameplate as well so the entire nameplate is up front
	function Plater.UpdateUIParentTargetLevels (unitFrame) --private
		if (DB_USE_UIPARENT) then
			--move all frames to target strata
			local targetStrata = Plater.db.profile.ui_parent_target_strata
			unitFrame:SetFrameStrata (targetStrata)
			unitFrame.castBar:SetFrameStrata (targetStrata)
			unitFrame.BuffFrame:SetFrameStrata (targetStrata)
			unitFrame.BuffFrame2:SetFrameStrata (targetStrata)
		end
	end
	
	--> regional format numbers
	do
		local eastAsiaMyriads_1k, eastAsiaMyriads_10k, eastAsiaMyriads_1B
		if (GetLocale() == "koKR") then
			eastAsiaMyriads_1k, eastAsiaMyriads_10k, eastAsiaMyriads_1B = "천", "만", "억"
			
		elseif (GetLocale() == "zhCN") then
			eastAsiaMyriads_1k, eastAsiaMyriads_10k, eastAsiaMyriads_1B = "千", "万", "亿"
			
		elseif (GetLocale() == "zhTW") then
			eastAsiaMyriads_1k, eastAsiaMyriads_10k, eastAsiaMyriads_1B = "千", "萬", "億"
			
		else
			eastAsiaMyriads_1k, eastAsiaMyriads_10k, eastAsiaMyriads_1B = "천", "만", "억"
		end

		function Plater.FormatNumber (number)
			if (DB_NUMBER_REGION_EAST_ASIA) then
				if (number > 99999999) then
					return format ("%.2f", number/100000000) .. eastAsiaMyriads_1B
					
				elseif (number > 999999) then
					return format ("%.2f", number/10000) .. eastAsiaMyriads_10k
					
				elseif (number > 99999) then
					return floor (number/10000) .. eastAsiaMyriads_10k
					
				elseif (number > 9999) then
					return format ("%.1f", (number/10000)) .. eastAsiaMyriads_10k
					
				elseif (number > 999) then
					return format ("%.1f", (number/1000)) .. eastAsiaMyriads_1k
					
				end
				
				return format ("%.1f", number)
			else
				if (number > 999999999) then
					return format ("%.2f", number/1000000000) .. "B"
					
				elseif (number > 999999) then
					return format ("%.2f", number/1000000) .. "M"
					
				elseif (number > 99999) then
					return floor (number/1000) .. "K"
					
				elseif (number > 999) then
					return format ("%.1f", (number/1000)) .. "K"
					
				end
				
				return floor (number)			
			end
		end

	end
	

	
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> event handler

	--frame which will receive events
	Plater.EventHandlerFrame = CreateFrame ("frame") --private

	--schedule zone change
	local run_zonechanged_hook = function()
		if (HOOK_ZONE_CHANGED.ScriptAmount > 0) then
			--for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
			local globalScope = _G
			for i = 1, 40 do
				--run on all nameplates already created
				local plateFrame = globalScope ["NamePlate" .. i]
				if (plateFrame) then
					for i = 1, HOOK_ZONE_CHANGED.ScriptAmount do
						local globalScriptObject = HOOK_ZONE_CHANGED [i]
						local unitFrame = plateFrame.unitFrame
						local scriptContainer = unitFrame:ScriptGetContainer()
						local scriptInfo = unitFrame:ScriptGetInfo (globalScriptObject, scriptContainer, "Zone Changed")
						--run
						unitFrame:ScriptRunHook (scriptInfo, "Zone Changed")
					end
				else
					break
				end
			end
		end	
	end
	function Plater.ScheduleZoneChangeHook()
		if (Plater.ScheduledZoneChangeTriggerHook) then
			Plater.ScheduledZoneChangeTriggerHook:Cancel()
		end
		Plater.ScheduledZoneChangeTriggerHook = C_Timer.NewTimer (2, run_zonechanged_hook)
	end
	
	function Plater.RunLoadScreenHook()
		for i = 1, HOOK_LOAD_SCREEN.ScriptAmount do
			local hookInfo = HOOK_LOAD_SCREEN [i]
			Plater.ScriptMetaFunctions.ScriptRunNoAttach (hookInfo, "Load Screen")
		end
	end
	
	--store all functions for all events that will be registered inside OnInit
	local eventFunctions = {

		--when a unit from unatackable change its state, this event triggers several times, a schedule is used to only update once
		UNIT_FLAGS = function (_, unit)
			if (unit == "player") then
				return
			end
			
			local plateFrame = C_NamePlate.GetNamePlateForUnit (unit, issecure())
			if (plateFrame) then
				--rules if can schedule an update for unit flag event:
				
				--nameplate is from a npc which the player cannot attack and now the player can attack
				local playerCannotAttack = plateFrame.PlayerCannotAttack
				--the player is in open world, dungeons and raids does trigger unit flag event but won't need a full refresh
				local playerInOpenWorld = IS_IN_OPEN_WORLD
				
				if (playerCannotAttack or playerInOpenWorld) then
					--print ("UNIT_FLAG", plateFrame, issecure(), unit, unit and UnitName (unit))
					Plater.ScheduleUpdateForNameplate (plateFrame)
				end
			end
		end,
		
		UNIT_FACTION = function (_, unit)
			if (unit == "player") then
				return
			end
			
			--fires when somebody changes faction near the player
			local plateFrame = C_NamePlate.GetNamePlateForUnit (unit, issecure())
			if (plateFrame) then
				Plater.ScheduleUpdateForNameplate (plateFrame)
			end
		end,

		PLAYER_SPECIALIZATION_CHANGED = function()
			C_Timer.After (1.5, Plater.CanUsePlaterResourceFrame) --~resource
			C_Timer.After (2, Plater.GetSpellForRangeCheck)
			C_Timer.After (2, Plater.GetHealthCutoffValue)
			C_Timer.After (1, Plater.DispatchTalentUpdateHookEvent)
		end,

		PLAYER_TALENT_UPDATE = function()
			C_Timer.After (2, Plater.GetSpellForRangeCheck)
			C_Timer.After (2, Plater.GetHealthCutoffValue)
			C_Timer.After (1, Plater.DispatchTalentUpdateHookEvent)
		end,
		
		GROUP_ROSTER_UPDATE = function()
			Plater.RefreshTankCache()
		end,

		PLAYER_REGEN_DISABLED = function()
			PLAYER_IN_COMBAT = true

			Plater.RefreshTankCache()
			
			Plater.UpdateAuraCache()
			Plater.UpdateAllPlates()
			
			--check if can run combat enter hook and schedule it true
			if (HOOK_COMBAT_ENTER.ScriptAmount > 0) then
				local hookTimer = C_Timer.NewTimer (0.1, Plater.ScheduleHookForCombat)
				hookTimer.Event = "Enter Combat"
			end
			
			Plater.CombatTime = GetTime()
		end,

		PLAYER_REGEN_ENABLED = function()

			PLAYER_IN_COMBAT = false
			
			for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
				plateFrame [MEMBER_NOCOMBAT] = nil
			end
			
			--check if can run combat enter hook and schedule it true
			if (HOOK_COMBAT_LEAVE.ScriptAmount > 0) then
				local hookTimer = C_Timer.NewTimer (0.1, Plater.ScheduleHookForCombat)
				hookTimer.Event = "Leave Combat"
			end
			
			Plater.RefreshTankCache()
			
			Plater.UpdateAllNameplateColors()
			Plater.UpdateAllPlates()
		end,

		FRIENDLIST_UPDATE = function()
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
			
			--let's not trigger a full update on all plates because a friend is now online
			--Plater.UpdateAllPlates()
		end,

		RAID_TARGET_UPDATE = function()
			Plater.UpdateRaidMarkersOnAllNameplates()
		end,

		QUEST_REMOVED = function()
			Plater.QuestLogUpdated()
		end,
		QUEST_ACCEPTED = function()
			Plater.QuestLogUpdated()
		end,
		QUEST_ACCEPT_CONFIRM = function()
			Plater.QuestLogUpdated()
		end,
		QUEST_COMPLETE = function()
			Plater.QuestLogUpdated()
		end,
		QUEST_POI_UPDATE = function()
			Plater.QuestLogUpdated()
		end,
		QUEST_QUERY_COMPLETE = function()
			Plater.QuestLogUpdated()
		end,
		QUEST_DETAIL = function()
			Plater.QuestLogUpdated()
		end,
		QUEST_FINISHED = function()
			Plater.QuestLogUpdated()
		end,
		QUEST_GREETING = function()
			Plater.QuestLogUpdated()
		end,
		QUEST_LOG_UPDATE = function()
			Plater.QuestLogUpdated()
		end,
		UNIT_QUEST_LOG_CHANGED = function()
			Plater.QuestLogUpdated()
		end,

		PLAYER_FOCUS_CHANGED = function()
			Plater.OnPlayerTargetChanged()
		end,
		PLAYER_TARGET_CHANGED = function()
			Plater.OnPlayerTargetChanged()
		end,

		PLAYER_UPDATE_RESTING = function()
			Plater.RefreshAutoToggle()
		end,

		--update the unit name, triggered when the client receives the rest of the information about an unit
		UNIT_NAME_UPDATE = function (_, unitID)
			if (unitID) then
				local plateFrame = C_NamePlate.GetNamePlateForUnit (unitID)
				if (plateFrame) then
					plateFrame [MEMBER_NAME] = UnitName (unitID)
					plateFrame [MEMBER_NAMELOWER] = lower (plateFrame [MEMBER_NAME])
					local unitFrame = plateFrame.unitFrame
					
					if (plateFrame.isSelf) then
						--name isn't shown in the personal bar
						unitFrame.healthBar.unitName:SetText ("")
						return
					end
					
					--schedule an name update on this nameplate
					unitFrame.ScheduleNameUpdate = true
				end
			end
		end,

		ENCOUNTER_END = function()
			Plater.CurrentEncounterID = nil
			Plater.LatestEncounter = time()
		end,

		ENCOUNTER_START = function (_, encounterID)
			Plater.CurrentEncounterID = encounterID
			
			local _, zoneType = GetInstanceInfo()
			if (zoneType == "raid") then
				table.wipe (DB_CAPTURED_SPELLS)
			end
		end,

		CHALLENGE_MODE_START = function()
			table.wipe (DB_CAPTURED_SPELLS)
		end,

		ZONE_CHANGED_NEW_AREA = function()
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
			Plater.ZoneName = name
			
			IS_IN_OPEN_WORLD = Plater.ZoneInstanceType == "none"
			IS_IN_INSTANCE = Plater.ZoneInstanceType == "raid" or Plater.ZoneInstanceType == "party"
			
			Plater.UpdateAllPlates()
			Plater.RefreshAutoToggle()
			
			--hooks
			Plater.ScheduleZoneChangeHook()
			
			if (Plater.PlayerEnteringWorld) then
				Plater.PlayerEnteringWorld = false
				C_Timer.After (1, Plater.RunLoadScreenHook)
			end
		end,

		ZONE_CHANGED_INDOORS = function()
			Plater.RunFunctionForEvent ("ZONE_CHANGED_NEW_AREA")
		end,

		ZONE_CHANGED = function()
			Plater.RunFunctionForEvent ("ZONE_CHANGED_NEW_AREA")
		end,
		
		PLAYER_ENTERING_WORLD = function()

			Plater.db.profile.login_counter = Plater.db.profile.login_counter + 1

			Plater.ScheduleRunFunctionForEvent (1, "ZONE_CHANGED_NEW_AREA")
			Plater.ScheduleRunFunctionForEvent (1, "FRIENDLIST_UPDATE")

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
			
			--run hooks on load screen
			if (HOOK_LOAD_SCREEN.ScriptAmount > 0) then
				Plater.PlayerEnteringWorld = true
			end
			
			--> ensure resource on target consistency after login:
			local resourcesOnTarget = GetCVar ("nameplateResourceOnTarget") == CVAR_ENABLED
			if resourcesOnTarget then
				PlaterDBChr.resources_on_target = true
				if (not InCombatLockdown()) then
					SetCVar ("nameplateResourceOnTarget", CVAR_DISABLED) -- reset this to false always, as it conflicts
				end
			end

			--create the frame to hold the plater resoruce bar
			Plater.CreatePlaterResourceFrame() --~resource
		end,

		PLAYER_LOGOUT = function()
			
		end,
		
		DISPLAY_SIZE_CHANGED = function()
			for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
				plateFrame.UnitFrame:Hide()
			end
			Plater.UpdateAllPlates (true)
		end,
		
		UI_SCALE_CHANGED = function()
			for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
				plateFrame.UnitFrame:Hide()
			end
			Plater.UpdateAllPlates (true)
		end,
		
		--~created ~events ~oncreated 
		NAME_PLATE_CREATED = function (event, plateFrame)
			
			--> create the unitframe
				local unitFrameOptions = {
					ShowPowerBar = false, 
					ShowBorder = false, 
					CanModifyHealhBarColor = false,
					ShowTargetOverlay = false,
					ShowUnitName = false, --let Plater control the unit name
					ClearUnitOnHide = false, --let Plater control when the cleanup is execute on the unit frame
				}
				
				local healthBarOptions = {
					ShowHealingPrediction = false,
					ShowShields = false,
				}
				
				local castBarOptions = {
					FadeInTime = 0.02,
					FadeOutTime = 0.66,
					SparkHeight = 20,
					LazyUpdateCooldown = 0.1,
				}
				
				local powerBarOptions = {
					ShowAlternatePower = false,
				}
				
				--community patch by Ariani#0960 (discord)
				--make the unitFrame be parented to UIParent allowing frames to be moved between strata levels
				--March 3rd, 2019
				local newUnitFrame
				if (DB_USE_UIPARENT) then
					--when using UIParent as the unit frame parent, adjust the unitFrame scale to be equal to blizzard plateFrame
					newUnitFrame = DF:CreateUnitFrame (UIParent, plateFrame:GetName() .. "PlaterUnitFrame", unitFrameOptions, healthBarOptions, castBarOptions, powerBarOptions)
					newUnitFrame:SetAllPoints()
					newUnitFrame:SetFrameStrata ("BACKGROUND")

					plateFrame:HookScript("OnSizeChanged", Plater.UpdateUIParentScale)
					
					--create a 33ms show animation played when the nameplate is added in the screen
					--nevermind, unitFrame childs are kepping the last alpha value of the animation instead of reseting to their defaults
					--i'm considering this a bug in the animation API from the game client
					--at the moment this cannot be used
					--newUnitFrame.ShowUIParentAnimation = DF:CreateAnimationHub (newUnitFrame, nil, function(self) Plater.UpdateUIParentScale (self:GetParent().PlateFrame) end)
					--DF:CreateAnimation (newUnitFrame.ShowUIParentAnimation, "scale", 1, 0.033, .5, .5, 1, 1)
					--DF:CreateAnimation (newUnitFrame.ShowUIParentAnimation, "alpha", 1, 0.033, .5, 1)
					
					--end of patch
					
					newUnitFrame.IsUIParent = true --expose to scripts the unitFrame is a UIParent child
				else
					newUnitFrame = DF:CreateUnitFrame (plateFrame, plateFrame:GetName() .. "PlaterUnitFrame", unitFrameOptions, healthBarOptions, castBarOptions)
				end

				plateFrame.unitFrame = newUnitFrame
				plateFrame.unitFrame:EnableMouse (false)
				
				--mix plater functions (most are for scripting support) into the unit frame
				DF:Mixin (newUnitFrame, Plater.ScriptMetaFunctions)

				--hook the retail nameplate
				plateFrame.UnitFrame:HookScript ("OnShow", Plater.OnRetailNamePlateShow)
				
				--OnHide handler
				newUnitFrame:HookScript ("OnHide", newUnitFrame.OnHideWidget)

				--OnHealthUpdate
				newUnitFrame.healthBar:SetHook ("OnHealthChange", Plater.OnHealthChange)
				newUnitFrame.healthBar:SetHook ("OnHealthMaxChange", Plater.OnHealthMaxChange)
				
				--register details framework hooks
				newUnitFrame.castBar:SetHook ("OnShow", Plater.CastBarOnShow_Hook)
				hooksecurefunc (newUnitFrame.castBar, "OnEvent", Plater.CastBarOnEvent_Hook)
				hooksecurefunc (newUnitFrame.castBar, "OnTick", Plater.CastBarOnTick_Hook)
				
				newUnitFrame.HasHooksRegistered = true
				
				--backup the unit frame address so we can restore it in case a script messes up and override the unit frame
				plateFrame.unitFramePlater = newUnitFrame
				
				--set proprieties
				plateFrame.Plater = true
				plateFrame.unitFrame.Plater = true
				
				plateFrame.unitFrame.PlateFrame = plateFrame
				plateFrame.isNamePlate = true
				plateFrame.unitFrame.isNamePlate = true
				plateFrame.unitFrame.IsUnitNameplate = true
				
				plateFrame.NameAnchor = 0
				plateFrame.unitFrame.healthBar.isNamePlate = true
			
			plateFrame.unitFrame.RefreshID = 0
			
			-- "PlaterMainAuraIcon"
			-- "PlaterSecondaryAuraIcon"

			--> buff frames
				--main buff frame
				plateFrame.unitFrame.BuffFrame = CreateFrame ("frame", plateFrame.unitFrame:GetName() .. "BuffFrame1", plateFrame.unitFrame)
				plateFrame.unitFrame.BuffFrame.amountAurasShown = 0
				plateFrame.unitFrame.BuffFrame.PlaterBuffList = {}
				plateFrame.unitFrame.BuffFrame.isNameplate = true
				plateFrame.unitFrame.BuffFrame.unitFrame = plateFrame.unitFrame --used on resource frame anchor update
				plateFrame.unitFrame.BuffFrame.healthBar = plateFrame.unitFrame.healthBar
				plateFrame.unitFrame.BuffFrame.AuraCache = {}
				
				--secondary buff frame
				plateFrame.unitFrame.BuffFrame2 = CreateFrame ("frame", plateFrame.unitFrame:GetName() .. "BuffFrame2", plateFrame.unitFrame)
				plateFrame.unitFrame.BuffFrame2.amountAurasShown = 0
				plateFrame.unitFrame.BuffFrame2.PlaterBuffList = {}
				plateFrame.unitFrame.BuffFrame2.isNameplate = true
				plateFrame.unitFrame.BuffFrame2.unitFrame = plateFrame.unitFrame
				plateFrame.unitFrame.BuffFrame2.healthBar = plateFrame.unitFrame.healthBar
				plateFrame.unitFrame.BuffFrame2.AuraCache = {}
			
			--> identify aura containers
				plateFrame.unitFrame.BuffFrame.Name = "Main" --aura frame 1
				plateFrame.unitFrame.BuffFrame2.Name = "Secondary" --aura frame 2
			
			--> store the secondary anchor inside the regular buff container for speed
			plateFrame.unitFrame.BuffFrame.BuffFrame2 = plateFrame.unitFrame.BuffFrame2
			plateFrame.unitFrame.BuffFrame2.BuffFrame1 = plateFrame.unitFrame.BuffFrame
			
			local healthBar = plateFrame.unitFrame.healthBar
			
			--cache the unit frame within the health and cast bars, this avoid GetParent() calls
			healthBar.unitFrame = plateFrame.unitFrame
			plateFrame.unitFrame.castBar.unitFrame = plateFrame.unitFrame
			
			--> pre create the scale animation used on animations for spell hits
			Plater.CreateScaleAnimation (plateFrame)
			--> create the animations when the unit goes out of range
			Plater.CreateAlphaAnimation (plateFrame)
			
			--store custom indicators
			plateFrame.unitFrame.CustomIndicators = {}
			
			--> cliclable area debug
				plateFrame.debugAreaTexture = plateFrame:CreateTexture (nil, "background")
				plateFrame.debugAreaTexture:SetColorTexture (.1, .1, .1, .834)
				plateFrame.debugAreaTexture:SetAllPoints()
				plateFrame.debugAreaTexture:Hide()
				plateFrame.debugAreaText = plateFrame:CreateFontString (nil, "artwork", "GameFontNormal")
				plateFrame.debugAreaText:SetPoint ("bottom", plateFrame.debugAreaTexture, "top", 0, 1)
				plateFrame.debugAreaText:SetText ("valid area for clicks")
				plateFrame.debugAreaText:SetTextColor (.7, .7, .7)
				plateFrame.debugAreaText:Hide()
			
			--> Indicators
				--container to store created indicators, they are created at run time
				plateFrame.IconIndicators = {}
			
			--> flash aggro
				Plater.CreateAggroFlashFrame (plateFrame)
				plateFrame.playerHasAggro = false
			
			--> target indicators
				--left and right target indicators
				plateFrame.unitFrame.TargetTextures2Sides = {}
				plateFrame.unitFrame.TargetTextures4Sides = {}
				for i = 1, 2 do
					local targetTexture = healthBar:CreateTexture (nil, "overlay")
					targetTexture:SetDrawLayer ("overlay", 7)
					tinsert (plateFrame.unitFrame.TargetTextures2Sides, targetTexture)
				end
				for i = 1, 4 do
					local targetTexture = healthBar:CreateTexture (nil, "overlay")
					targetTexture:SetDrawLayer ("overlay", 7)
					tinsert (plateFrame.unitFrame.TargetTextures4Sides, targetTexture)
				end
				
				--two extra target glow placed outside the healthbar, one above and another below the health bar
				local TargetNeonUp = plateFrame.unitFrame:CreateTexture (nil, "overlay")
				TargetNeonUp:SetDrawLayer ("overlay", 7)
				TargetNeonUp:SetBlendMode ("ADD")
				TargetNeonUp:Hide()
				plateFrame.TargetNeonUp = TargetNeonUp
				plateFrame.unitFrame.TargetNeonUp = TargetNeonUp
				
				local TargetNeonDown = plateFrame.unitFrame:CreateTexture (nil, "overlay")
				TargetNeonDown:SetDrawLayer ("overlay", 7)
				TargetNeonDown:SetBlendMode ("ADD")
				TargetNeonDown:SetTexCoord (0, 1, 1, 0)
				TargetNeonDown:Hide()
				plateFrame.TargetNeonDown = TargetNeonDown
				plateFrame.unitFrame.TargetNeonDown = TargetNeonDown
				
			--> target overlay (the texture added above the nameplate when the unit is selected)
				plateFrame.unitFrame.targetOverlayTexture = healthBar:CreateTexture (nil, "artwork")
				plateFrame.unitFrame.targetOverlayTexture:SetDrawLayer ("artwork", 2)
				plateFrame.unitFrame.targetOverlayTexture:SetBlendMode ("ADD")
				plateFrame.unitFrame.targetOverlayTexture:SetAllPoints()
			
			--> create the highlight texture (when the mouse passes over the nameplate and receives a highlight)
				Plater.CreateHighlightNameplate (plateFrame)

			--> health bar overlay
				--> create an overlay frame that sits just above the health bar
				--this is ideal for adding borders and other overlays
				healthBar.FrameOverlay = CreateFrame ("frame", "$parentOverlayFrame", healthBar)
				healthBar.FrameOverlay:SetAllPoints()
			
			--> execute range textures and animations
				--health cutoff texture shown inside the health bar
				local healthCutOff = healthBar:CreateTexture (nil, "overlay")
				healthCutOff:SetDrawLayer ("overlay", 7)
				healthCutOff:SetTexture ([[Interface\AddOns\Plater\images\health_bypass_indicator]])

				healthCutOff:SetBlendMode ("ADD")
				healthCutOff:Hide()
				healthBar.healthCutOff = healthCutOff
				healthBar.ExecuteRangeHealthCutOff = healthCutOff --alias for scripting
			
				local cutoffAnimationOnPlay = function()
					healthCutOff:Show()
				end
				local cutoffAnimationOnStop = function()
					healthCutOff:SetAlpha (.5)
				end
				
				local healthCutOffShowAnimation = DF:CreateAnimationHub (healthCutOff, cutoffAnimationOnPlay, cutoffAnimationOnStop)
				DF:CreateAnimation (healthCutOffShowAnimation, "Scale", 1, .2, .3, .3, 1.2, 1.2)
				DF:CreateAnimation (healthCutOffShowAnimation, "Scale", 2, .2, 1.2, 1.2, 1, 1)
				DF:CreateAnimation (healthCutOffShowAnimation, "Alpha", 1, .2, .2, 1)
				DF:CreateAnimation (healthCutOffShowAnimation, "Alpha", 2, .2, 1, .5)
				healthCutOff.ShowAnimation = healthCutOffShowAnimation
				
				--overlay for the healthbar showing the healthbar of the execute (shown when the unit is on execute range)
				local executeRange = healthBar:CreateTexture (nil, "border")
				executeRange:SetTexture ([[Interface\AddOns\Plater\images\execute_bar]])
				PixelUtil.SetPoint (executeRange, "left", healthBar, "left", 0, 0)
				healthBar.executeRange = executeRange
				healthBar.ExecuteRangeBar = executeRange --alias for scripting
				executeRange:Hide()

				--two extra execute glow placed outside the healthbar (disabled by default)
				local executeGlowUp = healthBar:CreateTexture (nil, "overlay")
				executeGlowUp:SetTexture ([[Interface\AddOns\Plater\images\blue_neon]])
				executeGlowUp:SetTexCoord (0, 1, 0, 0.5)
				executeGlowUp:SetHeight (32)		
				executeGlowUp:SetBlendMode ("ADD")
				executeGlowUp:Hide()
				PixelUtil.SetPoint (executeGlowUp, "bottom", healthBar, "top", 0, 0)
				healthBar.ExecuteGlowUp = executeGlowUp
				
				local executeGlowDown = healthBar:CreateTexture (nil, "overlay")
				executeGlowDown:SetTexture ([[Interface\AddOns\Plater\images\blue_neon]])
				executeGlowDown:SetTexCoord (0, 1, 0.5, 1)
				executeGlowDown:SetHeight (30)
				executeGlowDown:SetBlendMode ("ADD")
				executeGlowDown:Hide()
				PixelUtil.SetPoint (executeGlowDown, "top", healthBar, "bottom", 0, 0)
				healthBar.ExecuteGlowDown = executeGlowDown
				
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

			--> create the raid target widgets
				--raid target inside the health bar
				local raidTarget = healthBar:CreateTexture (nil, "overlay")
				PixelUtil.SetPoint (raidTarget, "right", raidTarget:GetParent(), "right", -2, 0)
				plateFrame.RaidTarget = raidTarget
				healthBar.ExtraRaidMark = raidTarget --alias for scripting

				--raid target outside the health bar
				plateFrame.unitFrame.PlaterRaidTargetFrame = CreateFrame ("frame", nil, plateFrame.unitFrame)
				local targetFrame = plateFrame.unitFrame.PlaterRaidTargetFrame
				targetFrame:SetSize (22, 22)
				PixelUtil.SetPoint (targetFrame, "right", healthBar, "left", -15, 0)
				
				--icon
				targetFrame.RaidTargetIcon = targetFrame:CreateTexture (nil, "artwork")
				targetFrame.RaidTargetIcon:SetAllPoints()
				targetFrame.RaidTargetIcon:SetTexture ([[Interface\TargetingFrame\UI-RaidTargetingIcons]])
				
				--create show animation to play when the icon is set to show
				local raidMarkAnimation = DF:CreateAnimationHub (targetFrame.RaidTargetIcon)
				DF:CreateAnimation (raidMarkAnimation, "Scale", 1, .075, .1, .1, 1.2, 1.2)
				DF:CreateAnimation (raidMarkAnimation, "Scale", 2, .075, 1.2, 1.2, 1, 1)
				targetFrame.RaidTargetIcon.ShowAnimation = raidMarkAnimation
			
			--> create details! integration strings
				healthBar.DetailsRealTime = healthBar:CreateFontString (nil, "overlay", "GameFontNormal")
				healthBar.DetailsRealTimeFromPlayer = healthBar:CreateFontString (nil, "overlay", "GameFontNormal")
				healthBar.DetailsDamageTaken = healthBar:CreateFontString (nil, "overlay", "GameFontNormal")
			
			--> tick frames (these frames are used for OnUpdate scripts)
				local onTickFrame = CreateFrame ("frame", nil, plateFrame)
				plateFrame.OnTickFrame = onTickFrame
				onTickFrame.unit = plateFrame [MEMBER_UNITID]
				onTickFrame.HealthBar = healthBar
				onTickFrame.PlateFrame = plateFrame
				onTickFrame.unitFrame = plateFrame.unitFrame
				onTickFrame.BuffFrame = plateFrame.unitFrame.BuffFrame
				onTickFrame.BuffFrame2 = plateFrame.unitFrame.BuffFrame2
			
			--> unit name
				--regular name
				plateFrame.unitFrame.unitName:SetParent (healthBar) --the name is parented to unitFrame in the framework, parent it to health bar
				healthBar.unitName = plateFrame.unitFrame.unitName
				healthBar.PlateFrame = plateFrame
				plateFrame.unitName = plateFrame.unitFrame.unitName
				plateFrame.CurrentUnitNameString = plateFrame.unitFrame.unitName
				healthBar.unitName:SetDrawLayer ("overlay", 7)
				
				--special name and title
				local ActorNameSpecial = plateFrame:CreateFontString (nil, "artwork", "GameFontNormal")
				plateFrame.ActorNameSpecial = ActorNameSpecial
				PixelUtil.SetPoint (plateFrame.ActorNameSpecial, "center", plateFrame, "center", 0, 0)
				plateFrame.ActorNameSpecial:Hide()
				
				local ActorTitleSpecial = plateFrame:CreateFontString (nil, "artwork", "GameFontNormal")
				plateFrame.ActorTitleSpecial = ActorTitleSpecial
				PixelUtil.SetPoint (plateFrame.ActorTitleSpecial, "top", ActorNameSpecial, "bottom", 0, -2)
				plateFrame.ActorTitleSpecial:Hide()
				
				plateFrame.unitFrame.ActorNameSpecial = ActorNameSpecial --alias for scripts
				plateFrame.unitFrame.ActorTitleSpecial = ActorTitleSpecial --alias for scripts
				
			--> level text
				local actorLevel = healthBar:CreateFontString (nil, "overlay", "GameFontNormal")
				healthBar.actorLevel = actorLevel
			
			--> life percent text
				local lifePercent = healthBar:CreateFontString (nil, "overlay", "GameFontNormal")
				lifePercent:SetDrawLayer ("overlay", 5)
				healthBar.lifePercent = lifePercent
				
			--> non target occlusion texture (disabled by default, it applies alayer of darkness above nameplates of units that aren't the player target)
				local obscuredTexture = healthBar:CreateTexture (nil, "overlay")
				obscuredTexture:SetDrawLayer ("overlay", 6)
				obscuredTexture:SetAllPoints()
				obscuredTexture:SetTexture ("Interface\\Tooltips\\UI-Tooltip-Background")
				obscuredTexture:SetVertexColor (0, 0, 0, 1)
				plateFrame.Obscured = obscuredTexture

			--> create the extra icon frame (used for the special aura)
				local options = {
					icon_width = 20, 
					icon_height = 20, 
					texcoord = {.1, .9, .1, .9},
					show_text = true,
				}
				
				plateFrame.unitFrame.ExtraIconFrame = DF:CreateIconRow (plateFrame.unitFrame, "$parentExtraIconRow", options)
				plateFrame.unitFrame.ExtraIconFrame:ClearIcons()
				plateFrame.unitFrame.ExtraIconFrame.RefreshID = 0
				plateFrame.unitFrame.ExtraIconFrame.AuraCache = {}
				--> cache the extra icon frame inside the buff frame for speed
				plateFrame.unitFrame.BuffFrame.ExtraIconFrame = plateFrame.unitFrame.ExtraIconFrame
			
			--> Support for DBM and BigWigs Nameplate Auras
				Plater.CreateBossModAuraFrame(plateFrame.unitFrame)
			
			--> 3D model frame
				plateFrame.Top3DFrame = CreateFrame ("playermodel", plateFrame:GetName() .. "3DFrame", plateFrame, "ModelWithControlsTemplate")
				plateFrame.Top3DFrame:SetPoint ("bottom", plateFrame, "top", 0, -100)
				plateFrame.Top3DFrame:SetSize (200, 250)
				plateFrame.Top3DFrame:EnableMouse (false)
				plateFrame.Top3DFrame:EnableMouseWheel (false)
				plateFrame.Top3DFrame:Hide()
				plateFrame.unitFrame.Top3DFrame = plateFrame.Top3DFrame
			
			--> castbar // create custom widgets for the cast bar
				--[=[
					castbar members:
						.Text			text string to show the spell name
						.background 		default background created in the unit frame
						.extraBackground 	an extra background shown when it has low alpha
						.barTexture		cast bar texture
						.Icon			texture to show the spell icon
						.Spark			texture that follows the cast progress
						.percentText		text showing that cast progress, usually is the time left to finish the cast
						.BorderShield 	border shown in the icon when the cast isn't interruptible
						.FrameOverlay 	invisible frame shown above the nameplate, useful for creating overlays
						.TargetName 		text showing the name for the target
						
				--]=]
			
				--set a UnitFrame member so scripts can get a quick reference of the unit frame from the castbar without calling for GetParent()
				plateFrame.unitFrame.castBar.PlateFrame = plateFrame
				plateFrame.unitFrame.castBar.unitFrame = plateFrame.unitFrame
				plateFrame.unitFrame.castBar.IsCastBar = true
				plateFrame.unitFrame.castBar.isNamePlate = true
				plateFrame.unitFrame.castBar.ThrottleUpdate = 0
				
				--mix the plater functions into the castbar (most of the functions are for scripting support)
				DF:Mixin (plateFrame.unitFrame.castBar, Plater.ScriptMetaFunctions)
				plateFrame.unitFrame.castBar:HookScript ("OnHide", plateFrame.unitFrame.castBar.OnHideWidget)

				--setup non interruptible cast shield
				plateFrame.unitFrame.castBar.BorderShield:SetTexture ([[Interface\ACHIEVEMENTFRAME\UI-Achievement-Progressive-IconBorder]])
				plateFrame.unitFrame.castBar.BorderShield:SetTexCoord (5/64, 37/64, 1/64, 36/64)
				
				--> create an overlay frame that sits just above the castbar
				--this is ideal for adding borders and other overlays
				plateFrame.unitFrame.castBar.FrameOverlay = CreateFrame ("frame", "$parentOverlayFrame", plateFrame.unitFrame.castBar)
				plateFrame.unitFrame.castBar.FrameOverlay:SetAllPoints()
				--pushing the spell name up
				plateFrame.unitFrame.castBar.Text:SetParent (plateFrame.unitFrame.castBar.FrameOverlay)
				--does have a border but its alpha is zero by default
				plateFrame.unitFrame.castBar.FrameOverlay:SetBackdrop ({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1})
				plateFrame.unitFrame.castBar.FrameOverlay:SetBackdropBorderColor (1, 1, 1, 0)
				--creates the target name overlay which shows who the unit is targetting while casting (this is disabled by default)
				plateFrame.unitFrame.castBar.FrameOverlay.TargetName = plateFrame.unitFrame.castBar.FrameOverlay:CreateFontString (nil, "overlay", "GameFontNormal")
				plateFrame.unitFrame.castBar.TargetName = plateFrame.unitFrame.castBar.FrameOverlay.TargetName --alias for scripts
			
				--create custom border frame for modeling
				if (Plater.CreateCustomDesignBorder) then
					Plater.CreateCustomDesignBorder(plateFrame.unitFrame.castBar)
				else
					--this msg can be removed after january 2020
					print("you may want to restart your game client to update addons!")
				end

			--> border
				--create a border using default borders from the retail game
				local healthBarBorder = CreateFrame ("frame", nil, plateFrame.unitFrame.healthBar, "NamePlateFullBorderTemplate")
				plateFrame.unitFrame.healthBar.border = healthBarBorder
				
				local powerBarBorder = CreateFrame ("frame", nil, plateFrame.unitFrame.powerBar, "NamePlateFullBorderTemplate")
				plateFrame.unitFrame.powerBar.border = powerBarBorder
				powerBarBorder:SetVertexColor (0, 0, 0, 1)

				--create custom border frame for modeling
				if (Plater.CreateCustomDesignBorder) then
					Plater.CreateCustomDesignBorder(healthBar)
				else
					--this msg can be removed after january 2020
					print("you may want to restart your game client to update addons!")
				end

				--create custom border frame for modeling
				if (Plater.CreateCustomDesignBorder) then
					Plater.CreateCustomDesignBorder(plateFrame.unitFrame.powerBar)
				else
					--this msg can be removed after january 2020
					print("you may want to restart your game client to update addons!")
				end
			
			--> focus indicator
				local focusIndicator = healthBar:CreateTexture (nil, "overlay")
				focusIndicator:SetDrawLayer ("overlay", 2)
				PixelUtil.SetPoint (focusIndicator, "topleft", healthBar, "topleft", 0, 0)
				PixelUtil.SetPoint (focusIndicator, "bottomright", healthBar, "bottomright", 0, 0)
				focusIndicator:Hide()
				healthBar.FocusIndicator = focusIndicator
				plateFrame.FocusIndicator = focusIndicator
				plateFrame.unitFrame.FocusIndicator = focusIndicator
			
			--> low aggro warning
				plateFrame.unitFrame.aggroGlowUpper = plateFrame:CreateTexture (nil, "background", -4)
				PixelUtil.SetPoint (plateFrame.unitFrame.aggroGlowUpper, "bottomleft", plateFrame.unitFrame.healthBar, "topleft", -3, 0)
				PixelUtil.SetPoint (plateFrame.unitFrame.aggroGlowUpper, "bottomright", plateFrame.unitFrame.healthBar, "topright", 3, 0)
				plateFrame.unitFrame.aggroGlowUpper:SetTexture ([[Interface\BUTTONS\UI-Panel-Button-Glow]])
				plateFrame.unitFrame.aggroGlowUpper:SetTexCoord (0, 95/128, 0, 9/64)
				plateFrame.unitFrame.aggroGlowUpper:SetBlendMode ("ADD")
				plateFrame.unitFrame.aggroGlowUpper:SetHeight (4)
				plateFrame.unitFrame.aggroGlowUpper:Hide()
				
				plateFrame.unitFrame.aggroGlowLower = plateFrame:CreateTexture (nil, "background", -4)
				PixelUtil.SetPoint (plateFrame.unitFrame.aggroGlowLower, "topleft", plateFrame.unitFrame.healthBar, "bottomleft", -3, 0)
				PixelUtil.SetPoint (plateFrame.unitFrame.aggroGlowLower, "topright", plateFrame.unitFrame.healthBar, "bottomright", 3, 0)
				plateFrame.unitFrame.aggroGlowLower:SetTexture ([[Interface\BUTTONS\UI-Panel-Button-Glow]])
				plateFrame.unitFrame.aggroGlowLower:SetTexCoord (0, 95/128, 30/64, 38/64)
				plateFrame.unitFrame.aggroGlowLower:SetBlendMode ("ADD")
				plateFrame.unitFrame.aggroGlowLower:SetHeight (4)
				plateFrame.unitFrame.aggroGlowLower:Hide()
			
			--> name plate created hook
				if (HOOK_NAMEPLATE_CREATED.ScriptAmount > 0) then
					for i = 1, HOOK_NAMEPLATE_CREATED.ScriptAmount do
						local globalScriptObject = HOOK_NAMEPLATE_CREATED [i]
						local scriptContainer = plateFrame.unitFrame:ScriptGetContainer()
						local scriptInfo = plateFrame.unitFrame:ScriptGetInfo (globalScriptObject, scriptContainer, "Nameplate Created")
						plateFrame.unitFrame:ScriptRunHook (scriptInfo, "Nameplate Created")
					end
				end
		end,

		-- ~added
		NAME_PLATE_UNIT_ADDED = function (event, unitBarId)
		
			--debug for hunter faith death
--			if (select (2, UnitClass (unitBarId)) == "HUNTER") then
--				print ("nameplate added", UnitName (unitBarId))
--			end
		
			local plateFrame = C_NamePlate.GetNamePlateForUnit (unitBarId)
			if (not plateFrame) then
				return
			end
			
			--> check the unit frame integrity, several times some weakaura or script mess with the unit frame
			if (not plateFrame.unitFrame or not plateFrame.unitFrame.SetUnit) then
				plateFrame.unitFrame = plateFrame.unitFramePlater
			end
			
			local unitID = unitBarId
			
			--hide blizzard namepaltes
			plateFrame.UnitFrame:Hide()
			--show plater unit frame
			plateFrame.unitFrame:Show()
			
			--save the last unit type shown in this plate
			plateFrame.PreviousUnitType = plateFrame.actorType
			
			--caching frames
			local unitFrame = plateFrame.unitFrame
			local castBar = unitFrame.castBar
			local healthBar = unitFrame.healthBar
			
			if (unitFrame.ShowUIParentAnimation) then
				unitFrame.ShowUIParentAnimation:Play()
			end
			
			if (not unitFrame.HasHooksRegistered) then
				--hook the retail nameplate
				plateFrame.UnitFrame:HookScript ("OnShow", Plater.OnRetailNamePlateShow)
				
				--onHide for unitFrame
				plateFrame.unitFrame:HookScript ("OnHide", unitFrame.OnHideWidget)
				--onShow for castbar
				castBar:SetHook ("OnShow", Plater.CastBarOnShow_Hook)
			
				unitFrame.HasHooksRegistered = true
			end
			
			--powerbar are disabled by default in the settings table, called SetUnit will make the framework hide the power bar
			--SetPowerBarSize() will show the power bar or the personal resource bar update also will show it
			unitFrame:SetUnit (unitID)
			
			--show unit name, the frame work will hide it due to ShowUnitName is set to false
			unitFrame.unitName:Show()
			
			--set the unitID in the unitFrame, several script and external addons read this member, adding different variations to be compatible with all
			unitFrame.unit = unitID
			unitFrame.namePlateUnitToken = unitID
			unitFrame.displayedUnit = unitID
			
			--was causing taints because MEMBER_UNITID is an actually member from the default blizzard nameplate
			--so when this nameplate is reclycled to be in a proteecteed nameplate, it was causing taints
			--plateFrame [MEMBER_UNITID] = unitID --causing taints
			
			plateFrame.QuestAmountCurrent = nil
			plateFrame.QuestAmountTotal = nil
			unitFrame.QuestAmountCurrent = nil
			unitFrame.QuestAmountTotal = nil
			
			--cache the unit target id, so it doesnt need to waste cycles building up on aggro checks
			unitFrame.targetUnitID = unitID .. "target"

			--clear values
			plateFrame.CurrentUnitNameString = plateFrame.unitName
			
			plateFrame.isSelf = nil
			unitFrame.IsSelf = nil --value exposed to scripts
			castBar.IsSelf = nil --value exposed to scripts
			
			plateFrame.PlayerCannotAttack = nil
			plateFrame.playerGuildName = nil
			plateFrame [MEMBER_NOCOMBAT] = nil
			
			plateFrame [MEMBER_TARGET] = nil
			plateFrame [MEMBER_NPCID] = nil
			unitFrame [MEMBER_TARGET] = nil
			unitFrame [MEMBER_NPCID] = nil
			
			--reset custom size set by the user
			unitFrame.customHealthBarWidth = nil
			unitFrame.customHealthBarHeight = nil
			
			unitFrame.customCastBarWidth = nil
			unitFrame.customCastBarHeight = nil
			
			unitFrame.customPowerBarWidth = nil
			unitFrame.customPowerBarHeight = nil
			
			--reset border
			unitFrame.customBorderColor = nil
			Plater.UpdateBorderColor (unitFrame)

			--reset custom color flag
			unitFrame.UsingCustomColor = nil
			
			unitFrame.InExecuteRange = false
			
			--check if this nameplate has an update scheduled
			if (plateFrame.HasUpdateScheduled) then
				if (not plateFrame.HasUpdateScheduled._cancelled) then
					plateFrame.HasUpdateScheduled:Cancel()
				end
				plateFrame.HasUpdateScheduled = nil
			end
			
			--cache values
			plateFrame [MEMBER_GUID] = UnitGUID (unitID) or ""
			plateFrame [MEMBER_NAME] = UnitName (unitID) or ""
			plateFrame [MEMBER_NAMELOWER] = lower (plateFrame [MEMBER_NAME])
			plateFrame ["namePlateClassification"] = UnitClassification (unitID)
			
			--clear name schedules
			unitFrame.ScheduleNameUpdate = nil
			
			unitFrame.InCombat = UnitAffectingCombat (unitID)
			
			--cache values into the unitFrame as well to reduce the overhead on scripts and hooks
			unitFrame [MEMBER_NAME] = plateFrame [MEMBER_NAME]
			unitFrame [MEMBER_NAMELOWER] = plateFrame [MEMBER_NAMELOWER]
			unitFrame [MEMBER_GUID] = plateFrame [MEMBER_GUID]
			unitFrame ["namePlateClassification"] = plateFrame ["namePlateClassification"]
			unitFrame [MEMBER_UNITID] = unitID
			unitFrame.namePlateThreatPercent = 0
			unitFrame.namePlateThreatIsTanking = nil
			unitFrame.namePlateThreatStatus = nil
			
			--get and format the reaction to always be the value of the constants, then cache the reaction in some widgets for performance
			local reaction = UnitReaction (unitID, "player") or 1
			reaction = reaction <= UNITREACTION_HOSTILE and UNITREACTION_HOSTILE or reaction >= UNITREACTION_FRIENDLY and UNITREACTION_FRIENDLY or UNITREACTION_NEUTRAL
			
			plateFrame [MEMBER_REACTION] = reaction
			unitFrame [MEMBER_REACTION] = reaction
			unitFrame.BuffFrame [MEMBER_REACTION] = reaction
			unitFrame.BuffFrame2 [MEMBER_REACTION] = reaction
			unitFrame.BuffFrame.unit = unitID
			unitFrame.BuffFrame2.unit = unitID
			
			--clear the custom indicators table
			wipe (unitFrame.CustomIndicators)
			
			--sending true to force the color update when the color overrider is enabled
			Plater.FindAndSetNameplateColor (unitFrame, true)
			
			--health amount
			Plater.QuickHealthUpdate (unitFrame)
			healthBar.IsAnimating = false
			
			if (not DB_USE_HEALTHCUTOFF) then
				healthBar.healthCutOff:Hide()
				healthBar.executeRange:Hide()
				healthBar.ExecuteGlowUp:Hide()
				healthBar.ExecuteGlowDown:Hide()
			end
			
			local actorType
			
			--reset the frame level and strata if using UIParent as the parent of the unitFrame
			--the function checks if the option is enabled, no need to check here
			Plater.UpdateUIParentLevels (unitFrame)
			
			if (unitFrame.unit) then
				
				if (UnitIsUnit (unitID, "player")) then
					--> personal health bar
					plateFrame.isSelf = true
					unitFrame.IsSelf = true --this is the value exposed to scripts
					castBar.IsSelf = true --this is the value exposed to scripts
					actorType = ACTORTYPE_PLAYER
					plateFrame.NameAnchor = 0
					
					--do not allow the framework to show the unit name
					unitFrame.Settings.ShowUnitName = false
					unitFrame.unitName:Hide()
					
					plateFrame.PlateConfig = DB_PLATE_CONFIG.player
					Plater.UpdatePlateFrame (plateFrame, ACTORTYPE_PLAYER, nil, true)
					Plater.OnUpdateHealth (healthBar)
					
				else
					--> regular nameplate
					
					plateFrame.PlayerCannotAttack = not UnitCanAttack ("player", unitID)
					unitFrame.PlayerCannotAttack = plateFrame.PlayerCannotAttack --expose to scripts
					
					if (UnitIsPlayer (unitID)) then
						--unit is a player
						plateFrame.playerGuildName = GetGuildInfo (unitID)
						
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
							
							--add the npc in the npcid cache
							if (not DB_NPCIDS_CACHE [plateFrame [MEMBER_NPCID]] and not IS_IN_OPEN_WORLD and not Plater.ZonePvpType and plateFrame [MEMBER_NPCID]) then
								if (UNKNOWN ~= plateFrame [MEMBER_NAME]) then --UNKNOWN is the global string from blizzard
									DB_NPCIDS_CACHE [plateFrame [MEMBER_NPCID]] = {plateFrame [MEMBER_NAME], Plater.ZoneName}
								end
							end
							
							plateFrame.NameAnchor = DB_NAME_NPCENEMY_ANCHOR
							plateFrame.PlateConfig = DB_PLATE_CONFIG.enemynpc
							Plater.UpdatePlateFrame (plateFrame, ACTORTYPE_ENEMY_NPC, nil, true)
							actorType = ACTORTYPE_ENEMY_NPC
							if (DB_CASTBAR_HIDE_ENEMIES) then
								CastingBarFrame_SetUnit (castBar, nil, nil, nil)
							end
							
							--get threat situation to expose it to scripts already in the nameplate added hook
							local isTanking, threatStatus, threatpct = UnitDetailedThreatSituation ("player", unitID)
							unitFrame.namePlateThreatIsTanking = isTanking
							unitFrame.namePlateThreatStatus = threatStatus
							unitFrame.namePlateThreatPercent = threatpct or 0
						end
					end
				end
			end
			
			--icone da cast bar
			castBar.Icon:ClearAllPoints()
			PixelUtil.SetPoint (castBar.Icon, "left", castBar, "left", 0, 0)
			castBar.BorderShield:ClearAllPoints()
			PixelUtil.SetPoint (castBar.BorderShield, "left", castBar, "left", 0, 0)
			
			--esconde os glow de aggro
			unitFrame.aggroGlowUpper:Hide()
			unitFrame.aggroGlowLower:Hide()
			
			--can check aggro
			unitFrame.CanCheckAggro = unitFrame.displayedUnit == unitID and actorType == ACTORTYPE_ENEMY_NPC
			
			--tick
			plateFrame.OnTickFrame.ThrottleUpdate = DB_TICK_THROTTLE
			plateFrame.OnTickFrame.actorType = actorType
			plateFrame.OnTickFrame.unit = unitID
			plateFrame.OnTickFrame:SetScript ("OnUpdate", Plater.NameplateTick)
			Plater.NameplateTick (plateFrame.OnTickFrame, 10)

			--highlight check
			if (DB_HOVER_HIGHLIGHT and not plateFrame.PlayerCannotAttack and (actorType ~= ACTORTYPE_FRIENDLY_PLAYER and actorType ~= ACTORTYPE_FRIENDLY_NPC and actorType ~= ACTORTYPE_PLAYER)) then
				Plater.EnableHighlight (unitFrame)
			else
				Plater.DisableHighlight (unitFrame)
			end
			
			--range
			Plater.CheckRange (plateFrame, true)
			
			--hooks
			if (HOOK_NAMEPLATE_ADDED.ScriptAmount > 0) then
				for i = 1, HOOK_NAMEPLATE_ADDED.ScriptAmount do
					local globalScriptObject = HOOK_NAMEPLATE_ADDED [i]
					local scriptContainer = unitFrame:ScriptGetContainer()
					local scriptInfo = unitFrame:ScriptGetInfo (globalScriptObject, scriptContainer, "Nameplate Added")
					--run
					unitFrame:ScriptRunHook (scriptInfo, "Nameplate Added")
				end
			end
			
			unitFrame.PlaterOnScreen = true
		end,

		-- ~removed
		NAME_PLATE_UNIT_REMOVED = function (event, unitBarId)
			local plateFrame = C_NamePlate.GetNamePlateForUnit (unitBarId)
			
			--debug for hunter faith death
			--if (select (2, UnitClass (unitBarId)) == "HUNTER") then
			--	print ("nameplate removed", UnitName (unitBarId))
			--end
			
			--hooks
			if (HOOK_NAMEPLATE_REMOVED.ScriptAmount > 0) then
				for i = 1, HOOK_NAMEPLATE_REMOVED.ScriptAmount do
					local globalScriptObject = HOOK_NAMEPLATE_REMOVED [i]
					local unitFrame = plateFrame.unitFrame
					local scriptContainer = unitFrame:ScriptGetContainer()
					local scriptInfo = unitFrame:ScriptGetInfo (globalScriptObject, scriptContainer, "Nameplate Removed")
					--run
					plateFrame.unitFrame:ScriptRunHook (scriptInfo, "Nameplate Removed")
				end
			end
			
			plateFrame.OnTickFrame:SetScript ("OnUpdate", nil)
			plateFrame.unitFrame.HighlightFrame:SetScript ("OnUpdate", nil)
			
			plateFrame [MEMBER_QUEST] = false
			plateFrame.unitFrame [MEMBER_QUEST] = false
			plateFrame [MEMBER_TARGET] = nil
			
			local healthBar = plateFrame.unitFrame.healthBar
			if (healthBar.TargetHeight) then
				healthBar:SetHeight (healthBar.TargetHeight)
			end
			healthBar.IsIncreasingHeight = nil
			healthBar.IsDecreasingHeight = nil
			
			--hide the highlight
			--is mouse over ~highlight ~mouseover
			plateFrame.unitFrame.HighlightFrame:Hide()
			plateFrame.unitFrame.HighlightFrame.Shown = false
			
			--> check if is running any script
			plateFrame.unitFrame:OnHideWidget()
			plateFrame.unitFrame.castBar:OnHideWidget()
			for _, auraIconFrame in ipairs (plateFrame.unitFrame.BuffFrame.PlaterBuffList) do
				auraIconFrame:OnHideWidget()
			end
			for _, auraIconFrame in ipairs (plateFrame.unitFrame.BuffFrame2.PlaterBuffList) do
				auraIconFrame:OnHideWidget()
			end
			
			plateFrame.unitFrame.PlaterOnScreen = nil
			
			--tell the framework to execute a cleanup on the unit frame, this is required since Plater set .ClearUnitOnHide to false
			plateFrame.unitFrame:SetUnit (nil)
			
			--community patch by Ariani#0960 (discord)
			--make the unitFrame be parented to UIParent allowing frames to be moved between strata levels
			--March 3rd, 2019
			if (DB_USE_UIPARENT) then
				-- need to explicitly hide the frame now, as it is not tethered to the blizz nameplate
				plateFrame.unitFrame:Hide()
			end
			--end of patch
			
		end,
	}

	function Plater.EventHandler (_, event, ...) --private
		local func = eventFunctions [event]
		if (func) then
			func (event, ...)
		else
			Plater:Msg ("no registered function for event " .. (event or "unknown event"))
		end
	end

	Plater.EventHandlerFrame:SetScript ("OnEvent", Plater.EventHandler)
	Plater.EventHandlerFrame:RegisterEvent ("PLAYER_ENTERING_WORLD")
	
	function Plater.RunFunctionForEvent (event, ...) --private
		Plater.EventHandler (nil, event, ...)
	end
	
	local run_scheduled_event_function = function (timerObject)
		local event = timerObject.event
		local args = timerObject.args
		Plater.RunFunctionForEvent (event, unpack (args))
	end
	
	function Plater.ScheduleRunFunctionForEvent (delay, event, ...) --private
		local timer = C_Timer.NewTimer (delay, run_scheduled_event_function)
		timer.event = event
		timer.args = {...}
	end

	--function for plateFrame.UnitFrame OnShow script
	--it'll hide the retail nameplate when it shown
	function Plater.OnRetailNamePlateShow (self) --private
		self:Hide()
		self:UnregisterAllEvents()
		if (CompactUnitFrame_UnregisterEvents) then
			CompactUnitFrame_UnregisterEvents (self)
		end
	end
	
	
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> addon initialization

function Plater.OnInit() --private
	Plater.RefreshDBUpvalues()
	
	Plater.CombatTime = GetTime()

	PLAYER_IN_COMBAT = false
	if (InCombatLockdown()) then
		PLAYER_IN_COMBAT = true
	end
	
	--character settings
		PlaterDBChr = PlaterDBChr or {first_run3 = {}}
		PlaterDBChr.first_run3 = PlaterDBChr.first_run3 or {}
		PlaterDBChr.debuffsBanned = PlaterDBChr.debuffsBanned or {}
		PlaterDBChr.buffsBanned = PlaterDBChr.buffsBanned or {}
		PlaterDBChr.spellRangeCheck = PlaterDBChr.spellRangeCheck or {}

	--to fix: attempt to index field 'spellRangeCheck' (a string value)
		if (type (PlaterDBChr.spellRangeCheck) ~= "table") then
			PlaterDBChr.spellRangeCheck = {}
		end
	
	--range check spells
		for specID, _ in pairs (Plater.SpecList [select (2, UnitClass ("player"))]) do
			if (PlaterDBChr.spellRangeCheck [specID] == nil) then
				PlaterDBChr.spellRangeCheck [specID] = GetSpellInfo (Plater.DefaultSpellRangeList [specID])
			end
		end
		Plater.SpellForRangeCheck = ""
	
	--who is the player
		Plater.PlayerGUID = UnitGUID ("player")
		Plater.PlayerClass = select (2, UnitClass ("player"))

	--load scripts from the script library
		Plater.ImportScriptsFromLibrary()
		Plater.ApplyPatches()
		--and compile all scripts and hooks
		Plater.CompileAllScripts ("script")
		Plater.CompileAllScripts ("hook")
	
	--check if masque is installed and add support for masque addon
		local Masque = LibStub ("Masque", true)
		if (Masque and Plater.db.profile.enable_masque_support) then
			Plater.Masque = {}
			Plater.Masque.AuraFrame1 = Masque:Group ("Plater Nameplates", "Aura Frame 1")
			Plater.Masque.AuraFrame2 = Masque:Group ("Plater Nameplates", "Aura Frame 2")
			Plater.Masque.BuffSpecial = Masque:Group ("Plater Nameplates", "Buff Special")
			Plater.Masque.BossModIconFrame = Masque:Group ("Plater Nameplates", "Boss Mod Icons")
		end
	
	--set some cvars that we want to set
		local re_ForceCVars = function()
			Plater.ForceCVars()
		end
		function Plater.ForceCVars()
			if (InCombatLockdown()) then
				return C_Timer.After (1, re_ForceCVars)
			end
			SetCVar ("nameplateMinAlpha", 0.90135484)
			SetCVar ("nameplateMinAlphaDistance", -10^5.2)
		end
	
	--schedule data update
		C_Timer.After (0.1, Plater.UpdatePlateClickSpace)
		C_Timer.After (1, Plater.GetSpellForRangeCheck)
		C_Timer.After (4, Plater.GetHealthCutoffValue)
		C_Timer.After (4.2, Plater.ForceCVars)
	
	--hooking scripts has load conditions, here it creates a load filter for plater
	--so when a load condition is changed it reload hooks
		function Plater.HookLoadCallback (encounterID) --private
			Plater.EncounterID = encounterID
			Plater.WipeAndRecompileAllScripts ("hook", true) --sending true to not dispatch a hotReload in the scripts
		end
		DF:CreateLoadFilterParser (Plater.HookLoadCallback)
	
	--refresh the color overrider
		Plater.RefreshColorOverride()
	--update how long the spell name text can be
		Plater.UpdateMaxCastbarTextLength()
	
	--update the current zone
		local _, zoneType = GetInstanceInfo()
		Plater.ZoneInstanceType = zoneType
	
	--check if is the first time Plater is running in the account or in the character
		local check_first_run = function()
			if (not UnitGUID ("player")) then
				C_Timer.After (1, Plater.CheckFirstRun)
				return
			end
			
			if (not Plater.db.profile.first_run3) then
				C_Timer.After (15, Plater.SetCVarsOnFirstRun)
				
				--enable UIParent nameplates for new installs of Plater
				--this setting is disabled by default and will be enabled for new people
				Plater.db.profile.use_ui_parent = true
				--adjust the fine tune to player's screen scale
				Plater.db.profile.ui_parent_scale_tune = 1 / UIParent:GetEffectiveScale()
				
			elseif (not PlaterDBChr.first_run3 [UnitGUID ("player")]) then
				--do not run cvars for individual characters
				C_Timer.After (15, Plater.SetCVarsOnFirstRun)
			else
				Plater.CreatePlaterButtonAtInterfaceOptions()
			end
		end
		
		function Plater.CheckFirstRun() --private
			check_first_run()
		end
		Plater.CheckFirstRun()
		
	--load a table with a copy of the plateConfigs table to be accessed by scripts
		Plater.UpdateSettingsCache()
	
	--events
		Plater.EventHandlerFrame:RegisterEvent ("NAME_PLATE_CREATED")
		Plater.EventHandlerFrame:RegisterEvent ("NAME_PLATE_UNIT_ADDED")
		Plater.EventHandlerFrame:RegisterEvent ("NAME_PLATE_UNIT_REMOVED")
		
		Plater.EventHandlerFrame:RegisterEvent ("PLAYER_TARGET_CHANGED")
		Plater.EventHandlerFrame:RegisterEvent ("PLAYER_FOCUS_CHANGED")
		
		Plater.EventHandlerFrame:RegisterEvent ("PLAYER_REGEN_DISABLED")
		Plater.EventHandlerFrame:RegisterEvent ("PLAYER_REGEN_ENABLED")
		
		Plater.EventHandlerFrame:RegisterEvent ("ZONE_CHANGED_NEW_AREA")
		Plater.EventHandlerFrame:RegisterEvent ("ZONE_CHANGED_INDOORS")
		Plater.EventHandlerFrame:RegisterEvent ("ZONE_CHANGED")
		Plater.EventHandlerFrame:RegisterEvent ("FRIENDLIST_UPDATE")
		Plater.EventHandlerFrame:RegisterEvent ("PLAYER_LOGOUT")
		Plater.EventHandlerFrame:RegisterEvent ("PLAYER_UPDATE_RESTING")
		Plater.EventHandlerFrame:RegisterEvent ("RAID_TARGET_UPDATE")
		
		Plater.EventHandlerFrame:RegisterEvent ("QUEST_ACCEPTED")
		Plater.EventHandlerFrame:RegisterEvent ("QUEST_REMOVED")
		Plater.EventHandlerFrame:RegisterEvent ("QUEST_ACCEPT_CONFIRM")
		Plater.EventHandlerFrame:RegisterEvent ("QUEST_COMPLETE")
		Plater.EventHandlerFrame:RegisterEvent ("QUEST_POI_UPDATE")
		Plater.EventHandlerFrame:RegisterEvent ("QUEST_DETAIL")
		Plater.EventHandlerFrame:RegisterEvent ("QUEST_FINISHED")
		Plater.EventHandlerFrame:RegisterEvent ("QUEST_GREETING")
		Plater.EventHandlerFrame:RegisterEvent ("QUEST_LOG_UPDATE")
		Plater.EventHandlerFrame:RegisterEvent ("UNIT_QUEST_LOG_CHANGED")
		Plater.EventHandlerFrame:RegisterEvent ("PLAYER_SPECIALIZATION_CHANGED")
		Plater.EventHandlerFrame:RegisterEvent ("PLAYER_TALENT_UPDATE")
		
		Plater.EventHandlerFrame:RegisterEvent ("ENCOUNTER_START")
		Plater.EventHandlerFrame:RegisterEvent ("ENCOUNTER_END")
		Plater.EventHandlerFrame:RegisterEvent ("CHALLENGE_MODE_START")
		
		Plater.EventHandlerFrame:RegisterEvent ("UNIT_NAME_UPDATE")
		
		Plater.EventHandlerFrame:RegisterEvent ("UNIT_FLAGS")
		Plater.EventHandlerFrame:RegisterEvent ("UNIT_FACTION")
		
		Plater.EventHandlerFrame:RegisterEvent ("DISPLAY_SIZE_CHANGED")
		Plater.EventHandlerFrame:RegisterEvent ("UI_SCALE_CHANGED")
		
		Plater.EventHandlerFrame:RegisterEvent ("GROUP_ROSTER_UPDATE")
		
		--many times at saved variables load the spell database isn't loaded yet
		function Plater:PLAYER_LOGIN()
			C_Timer.After (0.1, Plater.UpdatePlateClickSpace)
			C_Timer.After (0.2, Plater.GetSpellForRangeCheck)
			C_Timer.After (0.4, Plater.ForceCVars)
			
			-- ensure OmniCC settings are up to date
			C_Timer.After (1, Plater.RefreshOmniCCGroup)
			
			--wait more time for the talents information be received from the server
			C_Timer.After (4, Plater.GetHealthCutoffValue)
			
			C_Timer.After (2, Plater.ScheduleZoneChangeHook)
			
			C_Timer.After (5, function()
				local petGUID = UnitGUID ("playerpet")
				if (petGUID) then
					Plater.PlayerPetCache [petGUID] = time()
				end
			end)
			
			--if the user just used a /reload to enable ui parenting, auto adjust the fine tune scale
			--the uiparent fine tune scale initially: after testing and playing around with it, I think it should be 1 / UIParent:GetEffectiveScale() and scaling should be done by multiplying defaultScale * scaleFineTune
			if (Plater.db.profile.use_ui_parent_just_enabled) then
				Plater.db.profile.use_ui_parent_just_enabled = false
				if (Plater.db.profile.ui_parent_scale_tune == 0) then
					--@Ariani - march 9
					Plater.db.profile.ui_parent_scale_tune = 1 / UIParent:GetEffectiveScale()
					
					--@Tercio:
					--if (UIParent:GetEffectiveScale() < 1) then
					--	Plater.db.profile.ui_parent_scale_tune = 1 - UIParent:GetEffectiveScale()
					--end
				end
			end
			
			if (not Plater.db.profile.number_region_first_run) then
				if (GetLocale() == "koKR") then
					Plater.db.profile.number_region = "eastasia"
				elseif (GetLocale() == "zhCN") then
					Plater.db.profile.number_region = "eastasia"
				elseif (GetLocale() == "zhTW") then
					Plater.db.profile.number_region = "eastasia"
				else
					Plater.db.profile.number_region = "western"
				end
				
				Plater.db.profile.number_region_first_run = true
			end
			
			if (Plater.db.profile.reopoen_options_panel_on_tab) then
				C_Timer.After (2, function()
					Plater.OpenOptionsPanel()
					PlaterOptionsPanelContainer:SelectIndex (Plater, Plater.db.profile.reopoen_options_panel_on_tab)
					Plater.db.profile.reopoen_options_panel_on_tab = false
				end)
			end
			
			--run hooks on player logon
			if (HOOK_PLAYER_LOGON.ScriptAmount > 0) then
				C_Timer.After (1, function()
					for i = 1, HOOK_PLAYER_LOGON.ScriptAmount do
						local hookInfo = HOOK_PLAYER_LOGON [i]
						Plater.ScriptMetaFunctions.ScriptRunNoAttach (hookInfo, "Player Logon")
					end
				end)
			end
			
			--check addons incompatibility
			--> Plater has issues with ElvUI due to be using the same namespace for unitFrame and healthBar
			C_Timer.After (5, function()
				if (IsAddOnLoaded ("ElvUI")) then
					if (ElvUI[1] and ElvUI[1].private and ElvUI[1].private.nameplates and ElvUI[1].private.nameplates.enable) then
						Plater:Msg ("'ElvUI Nameplates' and 'Plater Nameplates' are enabled and both nameplates won't work together.")
						Plater:Msg ("You may disable ElvUI Nameplates at /elvui > Nameplates section or you may disable Plater at the addon control panel.")
					end
				end 
			end)

		end
		Plater:RegisterEvent ("PLAYER_LOGIN")

		--power update for hooking scripts
		local hookPowerEventFrame = CreateFrame ("frame")
		--hookPowerEventFrame:RegisterUnitEvent ("UNIT_POWER_UPDATE", "player")
		hookPowerEventFrame:RegisterUnitEvent ("UNIT_POWER_FREQUENT", "player")
		hookPowerEventFrame:RegisterUnitEvent ("UNIT_MAXPOWER", "player")
		--hookPowerEventFrame:RegisterUnitEvent ("UNIT_DISPLAYPOWER", "player")
		--hookPowerEventFrame:RegisterUnitEvent ("UNIT_POWER_BAR_HIDE", "player")

		hookPowerEventFrame:SetScript ("OnEvent", function()
			if (HOOK_PLAYER_POWER_UPDATE.ScriptAmount > 0) then
				for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
					if (plateFrame) then
						for i = 1, HOOK_PLAYER_POWER_UPDATE.ScriptAmount do
							local globalScriptObject = HOOK_PLAYER_POWER_UPDATE [i]
							local unitFrame = plateFrame.unitFrame
							local scriptContainer = unitFrame:ScriptGetContainer()
							local scriptInfo = unitFrame:ScriptGetInfo (globalScriptObject, scriptContainer, "Player Power Update")
							--run
							unitFrame:ScriptRunHook (scriptInfo, "Player Power Update")
						end
					end
				end
			end
		end)

	--addon comm handler
		Plater.CommHandler = { --private
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
	
		--this should pull the resources bar up and down based on if the target has debuffs shown on it or not
		function Plater.UpdateResourceFrameAnchor (buffFrame)
			if (Plater.CurrentTargetResourceFrame) then
				--if this buffFrame anchored in the current target?
				if (buffFrame.unitFrame [MEMBER_TARGET]) then
					--has any aura shown?
					--algumas vezes o amtdebbufs esta retornando 0 por alguma razao...
					if (buffFrame.amountAurasShown > 0 or (DB_AURA_SEPARATE_BUFFS and buffFrame.BuffFrame2.amountAurasShown > 0)) then
						Plater.CurrentTargetResourceFrame:SetPoint ("bottom", buffFrame.healthBar, "top", 0, Plater.db.profile.resources.y_offset_target + Plater.db.profile.resources.y_offset_target_withauras)
					else
						Plater.CurrentTargetResourceFrame:SetPoint ("bottom", buffFrame.healthBar, "top", 0, Plater.db.profile.resources.y_offset_target)
					end
				end
			end
		end
	
		function Plater.SetFontOutlineAndShadow (fontString, outline, shadowColor, shadowXOffSet, shadowYOffSet)
			--update the outline
			DF:SetFontOutline (fontString, outline)
			
			--update shadow color and shadow offset
			if (shadowColor) then
				local r, g, b, a = DF:ParseColors (shadowColor)
				DF:SetFontShadow (fontString, r, g, b, a, shadowXOffSet, shadowYOffSet)
			end
		end
	
		--this function is declared inside 'NamePlateDriverMixin' at Blizzard_NamePlates.lua
		--self if the nameplate driver frame: _G.NamePlateDriverFrame
		--at the moment self isn't being used ~personal
		function Plater.UpdatePersonalBar (self)
			local showSelf = GetCVarBool ("nameplateShowSelf")
			if (not showSelf) then
				if PlaterDBChr.resources_on_target then
					Plater.UpdateResourceFrame()
				end
				return
			end

			--show Plater power bar for the player personal nameplate
			local plateFrame = C_NamePlate.GetNamePlateForUnit ("player")
			if (plateFrame) then
			
				if (not plateFrame.Plater) then
					return
				end
			
				if (NamePlateDriverFrame.classNamePlatePowerBar and NamePlateDriverFrame.classNamePlatePowerBar:IsShown()) then
					--hide the power bar from default ui
					NamePlateDriverFrame.classNamePlatePowerBar:Hide()
				end
				
				local unitFrame = plateFrame.unitFrame
				
				--setup the power bar and cast bar from the details! framework unit frame
				local powerBar = unitFrame.powerBar
				local castBar = unitFrame.castBar
				local healthBar = unitFrame.healthBar
				
				if (not DB_PLATE_CONFIG.player.healthbar_enabled) then
					--the health bar is set when the nameplate is shown
					healthBar:SetUnit (nil)
				end
				
				if (DB_PLATE_CONFIG.player.power_enabled) then
					powerBar:SetUnit (unitFrame.unit)
					
					--update the power percent text
					local plateConfigs = DB_PLATE_CONFIG.player
					if (plateConfigs.power_percent_text_enabled) then
						unitFrame.powerBar.Settings.ShowPercentText = true
						
						local textString = powerBar.percentText
						textString:Show()
						
						DF:SetFontSize (textString, plateConfigs.power_percent_text_size)
						DF:SetFontFace (textString, plateConfigs.power_percent_text_font)
						
						DF:SetFontColor (textString, plateConfigs.power_percent_text_color)
						Plater.SetAnchor (textString, plateConfigs.power_percent_text_anchor)
						textString:SetAlpha (plateConfigs.power_percent_text_alpha)
						
						powerBar.border:SetVertexColor (0, 0, 0, 1) --hardcoded color
						
						Plater.SetFontOutlineAndShadow (textString, plateConfigs.power_percent_text_outline, plateConfigs.power_percent_text_shadow_color, plateConfigs.power_percent_text_shadow_color_offset[1], plateConfigs.power_percent_text_shadow_color_offset[2])
					else
						unitFrame.powerBar.Settings.ShowPercentText = false
						powerBar.percentText:Hide()
					end
				else
					powerBar:SetUnit (nil)
				end
				
				--setup the cast bar from details! framework unit frame
				if (DB_PLATE_CONFIG.player.castbar_enabled) then
					castBar:SetUnit (unitFrame.unit)
					castBar.extraBackground:Show()
				else
					castBar:SetUnit (nil)
				end
				
				--update resource bar
				Plater.UpdateResourceFrame()
			end
		end
		
		local on_personal_bar_update = function (self)
			return Plater.UpdatePersonalBar (self)
		end
		--can also hook 'ClassNameplateBar:ShowNameplateBar()' which will show and call NamePlateDriverFrame:SetClassNameplateBar(self); which will call SetupClassNameplateBars()
		hooksecurefunc (NamePlateDriverFrame, "SetupClassNameplateBars", on_personal_bar_update)

		--update the resource location and anchor
		function Plater.UpdateResourceFrame()
			--this holds a reference of the current resource frame anchored into the 'target' namepate
			--it is used when checking if the unit has auras to move the resources up to make room for the auras
			Plater.CurrentTargetResourceFrame = nil
		
			local showSelf = GetCVarBool ("nameplateShowSelf")
			local onCurrentTarget = PlaterDBChr.resources_on_target
			
			if (not showSelf) then
				if (not onCurrentTarget) then
					return
				end
			end
			
			local resourceFrame = NamePlateDriverFrame.classNamePlateMechanicFrame
			if (not resourceFrame or resourceFrame:IsForbidden()) then
				return
			end
			
			--> set scale based on Plater user settings
			resourceFrame:SetScale (Plater.db.profile.resources.scale)
			resourceFrame:SetAlpha (Plater.db.profile.resources.alpha)
			
			--check if resources are placed on the current target
			if (onCurrentTarget) then
				--resource bar are placed on the current target nameplate
				local targetPlateFrame = C_NamePlate.GetNamePlateForUnit ("target", false) -- don't attach to secure frames to avoid tainting!
				if (targetPlateFrame) then
					resourceFrame:Show()
					resourceFrame:SetParent (targetPlateFrame.unitFrame)
					resourceFrame:ClearAllPoints()
					resourceFrame:SetPoint ("bottom", targetPlateFrame.unitFrame.healthBar, "top", 0, Plater.db.profile.resources.y_offset_target)
					resourceFrame:SetFrameStrata(targetPlateFrame.unitFrame.healthBar:GetFrameStrata())
					resourceFrame:SetFrameLevel(targetPlateFrame.unitFrame.healthBar:GetFrameLevel() + 25)
					Plater.CurrentTargetResourceFrame = resourceFrame
					
					Plater.UpdateResourceFrameAnchor (targetPlateFrame.unitFrame.BuffFrame)
				else
					resourceFrame:Hide()
				end
			else
				--resource bar are placed below the mana bar at the personal bar
				local personalPlateFrame = C_NamePlate.GetNamePlateForUnit ("player", issecure())
				if (personalPlateFrame) then
					resourceFrame:Show()
					resourceFrame:SetParent (personalPlateFrame.unitFrame)
					resourceFrame:ClearAllPoints()
					
					--> attach to powerbar if shown
					if (personalPlateFrame.unitFrame.powerBar:IsShown()) then
						resourceFrame:SetPoint ("top", personalPlateFrame.unitFrame.powerBar, "bottom", 0, -3 + Plater.db.profile.resources.y_offset)
					else
						resourceFrame:SetPoint ("top", personalPlateFrame.unitFrame.healthBar, "bottom", 0, -3 + Plater.db.profile.resources.y_offset)
					end
					
					resourceFrame:SetFrameStrata(personalPlateFrame.unitFrame.healthBar:GetFrameStrata())
					resourceFrame:SetFrameLevel(personalPlateFrame.unitFrame.healthBar:GetFrameLevel() + 25)
				else
					resourceFrame:Hide()
				end
			end
		end

		--this function is declared inside 'NamePlateDriverMixin' at Blizzard_NamePlates.lua
		hooksecurefunc (NamePlateDriverFrame, "UpdateNamePlateOptions", function()
			Plater.UpdateSelfPlate()
		end)

	--> cast frame ~castbar
	
		--test castbar
		Plater.CastBarTestFrame = CreateFrame ("frame", nil, UIParent)
		
		function Plater.StartCastBarTest()
			Plater.IsShowingCastBarTest = true
			Plater.DoCastBarTest()
		end
		
		function Plater.DoCastBarTest (castNoInterrupt)

			for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
				local castBar = plateFrame.unitFrame.castBar
				
				castBar.Text:SetText ("Getting Bald")
				castBar.Icon:SetTexture ([[Interface\AddOns\Plater\images\icon_bald_guy]])
				castBar.Icon:SetAlpha (1)
				castBar.Icon:Show()
				castBar.percentText:Show()
				castBar:SetMinMaxValues (0, 3)
				castBar:SetValue (0)
				castBar.Spark:Show()
				castBar.casting = true
				castBar.finished = false
				castBar.value = 0
				castBar.maxValue = 3
				castBar.canInterrupt = math.random (1, 2) == 1
				castBar.canInterrupt = true
				castBar:UpdateCastColor()
				
				castBar.spellName = 		"Getting Bald"
				castBar.spellID = 		1
				castBar.spellTexture = 		[[Interface\AddOns\Plater\images\icon_bald_guy]]
				castBar.spellStartTime = 	GetTime()
				castBar.spellEndTime = 	GetTime() + 3
				
				castBar.SpellStartTime = 	GetTime()
				castBar.SpellEndTime = 	GetTime() + 3
				
				castBar.playedFinishedTest = nil
				
				castBar.flashTexture:Hide()
				castBar:Animation_StopAllAnimations()

				Plater.CastBarOnEvent_Hook (castBar, "UNIT_SPELLCAST_START", plateFrame.unitFrame.unit, plateFrame.unitFrame.unit)
				
				if (not castBar:IsShown()) then
					castBar:Animation_FadeIn()
					castBar:Show()
				end
			end
			
			local totalTime = 0
			local forward = true

			Plater.CastBarTestFrame:SetScript ("OnUpdate", function (self, deltaTime)
				if (totalTime >= 3.7) then
					if (Plater.IsShowingCastBarTest) then
						Plater.StartCastBarTest()
					end
				else
					totalTime = totalTime + deltaTime
				end

				for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
					local castBar = plateFrame.unitFrame.castBar
					if (castBar.finished and not castBar.playedFinishedTest) then
						Plater.CastBarOnEvent_Hook (castBar, "UNIT_SPELLCAST_STOP", plateFrame.unitFrame.unit, plateFrame.unitFrame.unit)
						castBar.playedFinishedTest = true
					end
				end
				
				if (not Plater.IsShowingCastBarTest) then
					Plater.CastBarTestFrame:SetScript ("OnUpdate", nil)
				end
			end)
		end
		
		function Plater.StopCastBarTest()
			Plater.IsShowingCastBarTest = false
			
			for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
				local castBar = plateFrame.unitFrame.castBar
				castBar.playedFinishedTest = true
			end
		end
	
		--> when the option to show the target of the cast is enabled, this function update the text settings but not the target name
		function Plater.UpdateCastbarTargetText (castBar)
			local profile = Plater.db.profile
			
			if (profile.castbar_target_show) then
				local textString = castBar.FrameOverlay.TargetName
				textString:Show()
				
				DF:SetFontSize (textString, profile.castbar_target_text_size)
				DF:SetFontOutline (textString, profile.castbar_target_shadow)
				
				Plater.SetFontOutlineAndShadow (textString, profile.castbar_target_outline, profile.castbar_target_shadow_color, profile.castbar_target_shadow_color_offset[1], profile.castbar_target_shadow_color_offset[2])
				
				DF:SetFontColor (textString, profile.castbar_target_color)
				DF:SetFontFace (textString, profile.castbar_target_font)
				
				Plater.SetAnchor (textString, profile.castbar_target_anchor)
			else
				castBar.FrameOverlay.TargetName:Hide()
			end
		end
		
		--> self is the castBar object from the details! framework unit frame widget
		--> this hook is set inside the nameplate created event
		function Plater.CastBarOnShow_Hook (self, unit) --private
			--> this cast bar is a nameplate widget?
			if (self.isNamePlate) then
				if (self.IsSelf) then
					self.extraBackground:Show()
				else
					--in case the unit is out of range, add some background color for the cast
					if (self:GetAlpha() < 0.4) then
						self.extraBackground:Show()
					else
						self.extraBackground:Hide()
					end
				end
			end
		end
		
		--~cast
		--hook for all castbar events
		function Plater.CastBarOnEvent_Hook (self, event, unit, ...) --private
	
			if (event == "PLAYER_ENTERING_WORLD") then
				if (not self.isNamePlate) then
					return
				end
				
				unit = self.unit
				
				if (self.casting) then
					event = "UNIT_SPELLCAST_START"
					
				elseif (self.channeling) then
					event = "UNIT_SPELLCAST_CHANNEL_START"
				else
					return
				end
			end
			
			if (self.isNamePlate) then
				local shouldRunCastStartHook = false
				
				if (event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_CHANNEL_START") then
					local unitCast = unit
					if (unitCast ~= self.unit) then
						return
					end
					
					--local name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible, spellId = UnitCastingInfo (unitCast)
					self.SpellName = 		self.spellName
					self.SpellID = 		self.spellID
					self.SpellTexture = 	self.spellTexture
					self.SpellStartTime = 	self.spellStartTime or GetTime()
					self.SpellEndTime = 	self.spellEndTime or GetTime()
					
					local notInterruptible = not self.canInterrupt
					
					self.IsInterrupted = false
					self.ReUpdateNextTick = true
					self.ThrottleUpdate = -1
					
					--> set border shield
					self.Icon:SetDrawLayer ("OVERLAY", 5)
					self.BorderShield:SetDrawLayer ("OVERLAY", 6)
					
					if (notInterruptible) then
						self.BorderShield:ClearAllPoints()
						self.BorderShield:SetPoint ("center", self.Icon, "center")
						self.BorderShield:Show()
					else
						self.BorderShield:Hide()
					end

					if (notInterruptible) then
						self.CanInterrupt = false
					else
						self.CanInterrupt = true
					end
					
					self.FrameOverlay:SetBackdropBorderColor (0, 0, 0, 0)
					
					--cut the spell name text to fit within the castbar
					local textLenght = self.Text:GetStringWidth()
					if (textLenght > Plater.MaxCastBarTextLength) then
						Plater.UpdateSpellNameSize (self.Text)
					end

					Plater.UpdateCastbarTargetText (self)
					shouldRunCastStartHook = true

				elseif (event == "UNIT_SPELLCAST_INTERRUPTED") then
					local unitCast = unit
					if (unitCast ~= self.unit) then
						return
					end
					
					self:OnHideWidget()
					self.IsInterrupted = true

				elseif (event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_CHANNEL_STOP") then
					local unitCast = unit
					if (unitCast ~= self.unit) then
						return
					end
					
					self:OnHideWidget()
					self.IsInterrupted = true
					
				end
				
				--hooks
				if (shouldRunCastStartHook) then
					if (HOOK_CAST_START.ScriptAmount > 0) then
						for i = 1, HOOK_CAST_START.ScriptAmount do
							local globalScriptObject = HOOK_CAST_START [i]
							local unitFrame = self.unitFrame
							local scriptContainer = unitFrame:ScriptGetContainer()
							local scriptInfo = unitFrame:ScriptGetInfo (globalScriptObject, scriptContainer, "Cast Start")
							
							--update envTable
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
							scriptEnv._CanStealOrPurge = self.CanStealOrPurge
							scriptEnv._AuraType = self.AuraType
							
							--run
							unitFrame:ScriptRunHook (scriptInfo, "Cast Start", self)
						end
					end
				end
			end
		end
		
		Plater.CastBarOnTick_Hook = function (self, deltaTime) --private
			if (self.percentText) then --check if is a plater cast bar
			
				self.ThrottleUpdate = self.ThrottleUpdate - deltaTime
				
				if (self.ThrottleUpdate < 0) then

					self.SpellStartTime = self.spellStartTime or GetTime()
					self.SpellEndTime = self.spellEndTime or GetTime()
				
					if (self.ReUpdateNextTick) then
						self.BorderShield:ClearAllPoints()
						self.BorderShield:SetPoint ("center", self.Icon, "center")
						self.ReUpdateNextTick = nil
					end

					--get the script object of the aura which will be showing in this icon frame
					local globalScriptObject = SCRIPT_CASTBAR [self.SpellName]
					
					if (self.unit and Plater.db.profile.castbar_target_show and not UnitIsUnit (self.unit, "player")) then
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
						scriptEnv._CanStealOrPurge = self.CanStealOrPurge
						scriptEnv._AuraType = self.AuraType
						
						if (self.casting) then
							scriptEnv._CastPercent = self.value / self.maxValue * 100
							
						elseif (self.channeling) then
							scriptEnv._CastPercent = abs (self.value - self.maxValue) / self.maxValue * 100
						end
					
						--run onupdate script
						self:ScriptRunOnUpdate (scriptInfo)
					end
					
					--hooks
					if (HOOK_CAST_UPDATE.ScriptAmount > 0) then
						for i = 1, HOOK_CAST_UPDATE.ScriptAmount do
							local globalScriptObject = HOOK_CAST_UPDATE [i]
							local unitFrame = self.unitFrame
							local scriptContainer = unitFrame:ScriptGetContainer()
							local scriptInfo = unitFrame:ScriptGetInfo (globalScriptObject, scriptContainer, "Cast Update")
							
							--update envTable
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
							scriptEnv._CanStealOrPurge = self.CanStealOrPurge
							scriptEnv._AuraType = self.AuraType
							
							--run
							unitFrame:ScriptRunHook (scriptInfo, "Cast Update", self)
						end
					end
					
				end
			end
		end
		
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--> health frame

	function Plater.QuickHealthUpdate (unitFrame)
		local unitHealth = UnitHealth (unitFrame.unit)
		local unitHealthMax = UnitHealthMax (unitFrame.unit)
		unitFrame.healthBar:SetMinMaxValues (0, unitHealthMax)
		unitFrame.healthBar:SetValue (unitHealth)
		
		unitFrame.healthBar.CurrentHealth = unitHealth
		unitFrame.healthBar.CurrentHealthMax = unitHealthMax
	end
	
	local run_on_health_change_hook = function (unitFrame)
		for i = 1, HOOK_HEALTH_UPDATE.ScriptAmount do
			local globalScriptObject = HOOK_HEALTH_UPDATE [i]
			local scriptContainer = unitFrame:ScriptGetContainer()
			local scriptInfo = unitFrame:ScriptGetInfo (globalScriptObject, scriptContainer, "Health Update")
			--run
			unitFrame:ScriptRunHook (scriptInfo, "Health Update")
		end
	end
	
	function Plater.OnUpdateHealth (self)
		if (not self.isNamePlate) then
			--this is not a nameplate, perhaps another frame from the framework
			return
		end

		local plateFrame = self.PlateFrame
		local currentHealth = self.currentHealth
		local currentHealthMax = self.currentHealthMax
		local unitFrame = self.unitFrame
		local oldHealth = self.CurrentHealth
		
		--> exposed values to scripts
		self.CurrentHealth = currentHealth
		self.CurrentHealthMax = currentHealthMax
	
		if (plateFrame.isSelf) then
			self.CurrentHealth = currentHealth
			self.CurrentHealthMax = currentHealthMax
		
			--> flash if low health
			if (currentHealth / currentHealthMax < 0.27) then
				if (not self.PlayHealthFlash) then
					Plater.CreateHealthFlashFrame (plateFrame)
				end
				self.PlayHealthFlash()
			else
				if (self.PlayHealthFlash) then
					if (currentHealth / currentHealthMax > 0.5) then
						self.canHealthFlash = true
					end
				end
			end
			
			if (plateFrame.PlateConfig.healthbar_color_by_hp) then
				local originalColor = plateFrame.PlateConfig.healthbar_color
				local r, g, b = DF:LerpLinearColor (abs (currentHealth / currentHealthMax - 1), 1, originalColor[1], originalColor[2], originalColor[3], 1, .4, 0)
				Plater.ChangeHealthBarColor_Internal (self, r, g, b, true)
			end
			
			Plater.CheckLifePercentText (unitFrame)
			
		else

			--quick hide the nameplate if the unit doesn't exists or if the unit died
			if (DB_USE_QUICK_HIDE) then
				if (not UnitExists (unitFrame.unit) or self.CurrentHealth < 1) then
					--the unit died!
					unitFrame:Hide()
					return
				end
			end
			
			if (DB_DO_ANIMATIONS) then
				--do healthbar animation ~animation ~healthbar
				oldHealth = oldHealth or self.CurrentHealth
				
				self.CurrentHealthMax = currentHealthMax
				self.AnimationStart = oldHealth
				self.AnimationEnd = currentHealth

				self:SetValue (oldHealth)
				
				self.IsAnimating = true
				
				if (self.AnimationEnd > self.AnimationStart) then
					self.AnimateFunc = Plater.AnimateRightWithAccel
				else
					self.AnimateFunc = Plater.AnimateLeftWithAccel
				end
			else
				self.CurrentHealth = currentHealth
				self.CurrentHealthMax = currentHealthMax
			end
			
			if (plateFrame.actorType == ACTORTYPE_FRIENDLY_PLAYER) then
				Plater.ParseHealthSettingForPlayer (plateFrame)
				self.ScheduleNameUpdate = true
				--Plater.UpdatePlateText (plateFrame, DB_PLATE_CONFIG [ACTORTYPE_FRIENDLY_PLAYER], false)
			end
			
			Plater.CheckLifePercentText (unitFrame)
		end
	end

	--self is the healthBar (it's parent is the unitFrame)
	function Plater.OnUpdateHealthMax (self)
		--the framework already set the min max values
		self.CurrentHealthMax = self.currentHealthMax -- o.0 hãããnnn
		Plater.CheckLifePercentText (self.unitFrame)
	end

	function Plater.OnHealthChange (self, unitId)
		Plater.OnUpdateHealth (self)
		
		--> run on health changed hook
		if (HOOK_HEALTH_UPDATE.ScriptAmount > 0) then
			return run_on_health_change_hook (self.unitFrame)
		end
	end
	
	function Plater.OnHealthMaxChange (self, unitId)
		Plater.OnUpdateHealthMax (self)
		
		--> run on health changed hook
		if (HOOK_HEALTH_UPDATE.ScriptAmount > 0) then
			return run_on_health_change_hook (self.unitFrame)
		end
	end
	
	--> profile changes and refreshes ~db
		Plater.db.RegisterCallback (Plater, "OnProfileChanged", "RefreshConfigProfileChanged")
		Plater.db.RegisterCallback (Plater, "OnProfileCopied", "RefreshConfig")
		Plater.db.RegisterCallback (Plater, "OnProfileReset", "RefreshConfig")
		Plater.db.RegisterCallback (Plater, "OnDatabaseShutdown", "SaveConsoleVariables")
		
		function Plater.OnProfileCreated()
			C_Timer.After (.5, function()
				Plater:Msg ("new profile created, applying patches and adding default scripts.")
				Plater.ImportScriptsFromLibrary()
				Plater.ApplyPatches()
				Plater.CompileAllScripts ("script")
				Plater.CompileAllScripts ("hook")
				
				--enable UIParent nameplates for new installs of Plater
				--this setting is disabled by default and will be enabled for new users and new profiles
				Plater.db.profile.use_ui_parent = true
				--adjust the fine tune to player's screen scale
				Plater.db.profile.ui_parent_scale_tune = 1 / UIParent:GetEffectiveScale()
				
				--call major refresh
				Plater:RefreshConfig()
				Plater.UpdatePlateClickSpace()
				
				--call the user to /reload UI
				DF:ShowPromptPanel ("Plater profile created, do you want /reload now (recommended)?", function() ReloadUI() end, function() end, true, 500)
			end)
		end
		
		Plater.db.RegisterCallback (Plater, "OnNewProfile", "OnProfileCreated")

		Plater.UpdateSelfPlate()
		
		C_Timer.After (4.1, Plater.QuestLogUpdated)
		C_Timer.After (5.1, function() Plater.IncreaseRefreshID(); Plater.UpdateAllPlates() end)
	
		for i = 1, 3 do
			C_Timer.After (i, Plater.RefreshDBUpvalues)
		end
		
	CastingBarFrame:HookScript ("OnShow", function (self)
		if (Plater.db.profile.hide_blizzard_castbar) then
			self:Hide()
		end
	end)
	
	-- hook to the InterfaceOptionsFrame and update the nameplate sizes, as blizzard somehow messes things up there on hide...
	InterfaceOptionsFrame:HookScript('OnHide',Plater.UpdatePlateClickSpace)
end





--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> aura buffs and debuffs ~aura ~buffs ~debuffs ~auras

	--> show the tooltip in the aura icon
	function Plater.OnEnterAura (iconFrame) --private
		NamePlateTooltip:SetOwner (iconFrame, "ANCHOR_LEFT")
		NamePlateTooltip:SetUnitAura (iconFrame:GetParent().unit, iconFrame:GetID(), iconFrame.filter)
		iconFrame.UpdateTooltip = Plater.OnEnterAura
	end

	function Plater.OnLeaveAura (iconFrame) --private
		NamePlateTooltip:Hide()
	end
	
	--called from the options panel, request a refresh on all auras shown
	function Plater.RefreshAuras() --private
		for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
			Plater.NameplateTick (plateFrame.OnTickFrame, 1)
		end
		if Plater.Masque then
			Plater.Masque.AuraFrame1:ReSkin()
			Plater.Masque.AuraFrame2:ReSkin()
			Plater.Masque.BuffSpecial:ReSkin()
			Plater.Masque.BossModIconFrame:ReSkin()
		end
	end
	
	--stack auras with the same name and change the stack text above the icon to indicate how many auras with the same name the unit has
	--self is BuffFrame
	function Plater.ConsolidateAuraIcons (self)
		--get the table where all icon frames are stored in
		local iconFrameContainer = self.PlaterBuffList
		
		--get the amount of auras shown in the frame, this variable should be always reliable
		local amountFramesShown = self.amountAurasShown
		--store icon frames with the same name
		local aurasDuplicated = {}
		
		for i = 1, amountFramesShown do
			local iconFrame = iconFrameContainer [i]
			local spellId = iconFrame.spellId
			
			if (aurasDuplicated [spellId]) then
				tinsert (aurasDuplicated [spellId], {iconFrame, iconFrame.RemainingTime})
			else
				aurasDuplicated [spellId] = {
					{iconFrame, iconFrame.RemainingTime}
				}
			end
		end

		for spellId, iconFramesTable in pairs (aurasDuplicated) do
			--how many auras with the same name the unit has
			local amountOfSimilarAuras = #iconFramesTable
			
			if (amountOfSimilarAuras > 1) then
				--reverse order: the aura with the less time left is shown
				--if the aura with less time isn't the first occurence of this aura, it'll create some empty gaps
			--	if (Plater.db.profile.aura_consolidate_timeleft_lower) then
			--		table.sort (iconFramesTable, DF.SortOrder2R)
			--	else
			--		table.sort (iconFramesTable, DF.SortOrder2)
			--	end
				
				--hide all auras except for the first occurrence of this aura
				for i = 2, amountOfSimilarAuras do
					local iconFrame = iconFramesTable [i][1]
					iconFrame:Hide()
					iconFrame.InUse = false
					
					--decrease the amount of auras shown on the buff frame
					self.amountAurasShown = self.amountAurasShown - 1
				end
				
				--set the stack amount number to indicate how many auras similar to this the unit has
				local stackLabel = iconFramesTable [1][1].StackText
				stackLabel:SetText (amountOfSimilarAuras)
				stackLabel:Show()
			end
		end
	end
	
	--align the aura frame icons currently shown in buff container
	--this function is called after Plater complete the aura update loop
	--at this point, icons shown are reliable icons that has auras that are shown above the nameplate
	--hidden icons aren't in use and should be ignored
	--self is the buff container
	--~align
	function Plater.AlignAuraFrames (self)

		if (self.isNameplate) then
		
			if (Plater.db.profile.aura_consolidate) then
				Plater.ConsolidateAuraIcons (self)
			end
		
			local growDirection

			--> get the grow direction for the buff frame
			if (self.Name == "Main") then
				growDirection = DB_AURA_GROW_DIRECTION
				
			elseif (self.Name == "Secondary") then
				growDirection = DB_AURA_GROW_DIRECTION2
			end
			
			--get the table where all icon frames are stored in
			local iconFrameContainer = self.PlaterBuffList
			
			--get the amount of auras shown in the frame, this variable should be always reliable
			local amountFramesShown = self.amountAurasShown
			
			if (growDirection ~= 2) then --it's growing to left or right
			
				self:SetSize (1, 1)
				
				--debug where the buffFrame anchors are
				--self:SetSize (5, 5)
				--self:SetBackdrop ({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1})
				--self:SetBackdropBorderColor (1, 0, 0, 1)
			
				local framersPerRow = Plater.MaxAurasPerRow + 1
				local firstIcon = iconFrameContainer[1]
				
				--check if there's one icon and if the icon is shown
				if (not firstIcon or not firstIcon:IsShown()) then
					return
				end

				--set the point of the first icon
				firstIcon:ClearAllPoints()
				firstIcon:SetPoint ("center", self, "center", 0, 5)
				
				--which slot index is being manipulated within the icon loop
				--is an icon is hidden it won't be used and the slot won't increase
				--the slot 1 is guaranteed to always be in use
				local slotId = 2
				
				--which was the last shown and valid icon attached into the visible icon row
				local lastIconUsed = firstIcon
				
				--left to right
				if (growDirection == 3) then
					--iterate among all icon frames
					for i = 2, #iconFrameContainer do
						--get the icon id from the icon frame container
						local iconFrame = iconFrameContainer [i]
						if (iconFrame:IsShown()) then
							iconFrame:ClearAllPoints()
							
							if (slotId == framersPerRow) then
								iconFrame:SetPoint ("bottomleft", firstIcon, "topleft", 0, Plater.db.profile.aura_breakline_space)
								framersPerRow = framersPerRow + framersPerRow
								--update the first icon to be the first icon in the second row
								firstIcon = iconFrame
							else
								iconFrame:SetPoint ("topleft", lastIconUsed, "topright", DB_AURA_PADDING, 0)
							end
							
							lastIconUsed = iconFrame
							slotId = slotId + 1
						end
					end

				-- <-- right to left
				elseif (growDirection == 1) then
					--> iterate among all icon frames
					for i = 2, #iconFrameContainer do
						--get the icon id from the icon frame container
						local iconFrame = iconFrameContainer [i]
						if (iconFrame:IsShown()) then
							iconFrame:ClearAllPoints()
							
							if (slotId == framersPerRow) then
								iconFrame:SetPoint ("bottomright", firstIcon, "topright", 0, Plater.db.profile.aura_breakline_space)
								framersPerRow = framersPerRow + framersPerRow
								--update the first icon to be the first icon in the second row
								firstIcon = iconFrame
							else
								iconFrame:SetPoint ("topright", lastIconUsed, "topleft", -DB_AURA_PADDING, 0)
							end
							
							lastIconUsed = iconFrame
							slotId = slotId + 1
						end
					end
				end
				
			else --it's growing from center
				
				local iconAmount = 0
				local horizontalLength = 0
				local firstIcon
				local previousIcon

				--iterate among all icons in the aura frame
				--set the point of the first icon in the bottom left of the buff frame
				--set the point of all other icons to the right of the previous icon and update the size of the buff frame
				for i = 1, #iconFrameContainer do
					local iconFrame = iconFrameContainer [i]
					if (iconFrame:IsShown()) then
						iconAmount = iconAmount + 1
						horizontalLength = horizontalLength + iconFrame:GetWidth() + DB_AURA_PADDING
						iconFrame:ClearAllPoints()
						
						if (not firstIcon) then
							firstIcon = iconFrame
							firstIcon:SetPoint ("bottomleft", self, "bottomleft", 0, 0)
							previousIcon = firstIcon
						else
							iconFrame:SetPoint ("bottomleft", previousIcon, "bottomright", DB_AURA_PADDING, 0)
							previousIcon = iconFrame
						end
					end
				end
				
				if (not firstIcon) then
					return
				end
				
				--remove 1 icon padding value
				horizontalLength = horizontalLength - DB_AURA_PADDING
				
				--set the size of the buff frame
				self:SetWidth (horizontalLength)
				self:SetHeight (firstIcon:GetHeight())
			end
		end
	end

	--adjust the texcoord of the texture by the size of the icon
	--if the icon is more of a retangular shape, it'll cut the top and bottom sides of the texture giving a wide view
	function Plater.UpdateIconAspecRatio (auraIconFrame)
		local width, height = auraIconFrame:GetSize()
		local ratio = width > height and min (max (abs (width / height - 2) + 0.05, 0.6), 1) or .95
		auraIconFrame.Icon:SetTexCoord (.05, .95, .09, ratio)
	end

	function Plater.CreateAuraIcon (parent, name) --private
		local newIcon = CreateFrame ("Button", name, parent)
		newIcon:Hide()
		newIcon:SetSize (20, 16)
		
		newIcon:SetScript ("OnEnter", Plater.OnEnterAura)
		newIcon:SetScript ("OnLeave", Plater.OnLeaveAura)
		
		newIcon:SetMouseClickEnabled (false)
		
		newIcon.Border = newIcon:CreateTexture (nil, "background")
		newIcon.Border:SetAllPoints()
		newIcon.Border:SetColorTexture (0, 0, 0)
		
		newIcon.Icon = newIcon:CreateTexture (nil, "BORDER")
		newIcon.Icon:SetSize (18, 12)
		newIcon.Icon:SetPoint ("center")
		newIcon.Icon:SetTexCoord (.05, .95, .1, .6)
		
		newIcon.Cooldown = CreateFrame ("cooldown", "$parentCooldown", newIcon, "CooldownFrameTemplate")
		newIcon.Cooldown:SetPoint ("center", 0, -1)
		newIcon.Cooldown:SetAllPoints()
		newIcon.Cooldown:EnableMouse (false)
		newIcon.Cooldown:SetHideCountdownNumbers (true)
		newIcon.Cooldown:Hide()
		
		--newIcon.Cooldown:SetSwipeColor (0, 0, 0) --not working
		--newIcon.Cooldown:SetDrawSwipe (false)
		--newIcon.Cooldown:SetSwipeTexture ("Interface\\Garrison\\Garr_TimerFill")
		--newIcon.Cooldown:SetEdgeTexture ("Interface\\Cooldown\\edge-LoC");
		--newIcon.Cooldown:SetReverse (true)
		--newIcon.Cooldown:SetCooldownUNIX (startTime, buildDuration);
		
		newIcon.CountFrame = CreateFrame ("frame", "$parentCountFrame", newIcon)
		newIcon.CountFrame:SetAllPoints()
		newIcon.CountFrame:EnableMouse (false)
		newIcon.CountFrame.Count = newIcon.CountFrame:CreateFontString (nil, "artwork", "NumberFontNormalSmall")
		newIcon.CountFrame.Count:SetJustifyH ("right")
		newIcon.CountFrame.Count:SetPoint ("bottomright", 3, -2)
		
		--expose to scripts
		newIcon.StackText = newIcon.CountFrame.Count
		
		newIcon.Cooldown.Timer = newIcon.Cooldown:CreateFontString (nil, "overlay", "NumberFontNormal")
		newIcon.Cooldown.Timer:SetPoint ("center")
		newIcon.TimerText = newIcon.Cooldown.Timer

		return newIcon
	end
	
	--create the animation when the icon is shown above the nameplate
	function Plater.CreateShowAuraIconAnimation (iconFrame)
		local iconShowInAnimation = DF:CreateAnimationHub (iconFrame)
		DF:CreateAnimation (iconShowInAnimation, "Scale", 1, .05, .7, .7, 1.1, 1.1)
		DF:CreateAnimation (iconShowInAnimation, "Scale", 2, .05, 1.1, 1.1, 1, 1)
		iconFrame.ShowAnimation = iconShowInAnimation
	end
	
	--an aura is about to be added in the nameplate, need to get an icon for it ~geticonaura
	function Plater.GetAuraIcon (self, isBuff)
		--self parent = NamePlate_X_UnitFrame
		--self = BuffFrame
		
		if (isBuff and DB_AURA_SEPARATE_BUFFS) then
			self = self.BuffFrame2
		end
		
		local i = self.NextAuraIcon
		
		if (not self.PlaterBuffList[i]) then
			local newFrameIcon = Plater.CreateAuraIcon (self, self.unitFrame:GetName() .. "Plater" .. self.Name .. "AuraIcon" .. i)
			newFrameIcon.unitFrame = self.unitFrame
			newFrameIcon.spellId = 0
			newFrameIcon.ID = i
			newFrameIcon.RefreshID = 0
			newFrameIcon.IsPersonal = -1 --place holder
			
			self.PlaterBuffList[i] = newFrameIcon
			
			newFrameIcon:SetBackdrop ({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1})
		
			local auraWidth = Plater.db.profile.aura_width
			local auraHeight = Plater.db.profile.aura_height
			newFrameIcon:SetSize (auraWidth, auraHeight)
			newFrameIcon.Icon:SetSize (auraWidth-2, auraHeight-2)
			
			--mixin the meta functions for scripts
			DF:Mixin (newFrameIcon, Plater.ScriptMetaFunctions)
			newFrameIcon.IsAuraIcon = true
			newFrameIcon:HookScript ("OnHide", newFrameIcon.OnHideWidget)
			
			--create the animation for when the icon is shown
			Plater.CreateShowAuraIconAnimation (newFrameIcon)
			
			--masque support
			if (Plater.Masque) then
				if (self.Name == "Main") then
					local t = {
						FloatingBG = nil, --false,
						Icon = newFrameIcon.Icon,
						Cooldown = newFrameIcon.Cooldown,
						Flash = nil, --false,
						Pushed = nil, --false,
						Normal = nil, --false,
						Disabled = nil, --false,
						Checked = nil, --false,
						Border = nil, --newFrameIcon.Border,
						AutoCastable = nil, --false,
						Highlight = nil, --false,
						HotKey = nil, --false,
						Count = false,
						Name = nil, --false,
						Duration = false,
						Shine = nil, --false,
					}
					newFrameIcon.Border:Hide() --let Masque handle the border...
					Plater.Masque.AuraFrame1:AddButton (newFrameIcon, t)
					Plater.Masque.AuraFrame1:ReSkin()
					
				elseif (self.Name == "Secondary") then
					local t = {
						FloatingBG = nil, --false,
						Icon = newFrameIcon.Icon,
						Cooldown = newFrameIcon.Cooldown,
						Flash = nil, --false,
						Pushed = nil, --false,
						Normal = nil, --false,
						Disabled = nil, --false,
						Checked = nil, --false,
						Border = nil, --newFrameIcon.Border,
						AutoCastable = nil, --false,
						Highlight = nil, --false,
						HotKey = nil, --false,
						Count = false,
						Name = nil, --false,
						Duration = false,
						Shine = nil, --false,
					}
					newFrameIcon.Border:Hide() --let Masque handle the border...
					Plater.Masque.AuraFrame2:AddButton (newFrameIcon, t)
					Plater.Masque.AuraFrame2:ReSkin()
					
				end
			end
		end
		
		local auraIconFrame = self.PlaterBuffList [i]
		self.NextAuraIcon = self.NextAuraIcon + 1
		
		return auraIconFrame, self
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
	
	--update the aura icon, this icon is getted with GetAuraIcon -
	--actualAuraType is the UnitAura return value for the auraType ("" is enrage, nil/"none" for unspecified and "Disease", "Poison", "Curse", "Magic" for other types. -Continuity/Ariani
	            
	function Plater.AddAura (self, auraIconFrame, i, spellName, texture, count, auraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId, isBuff, isShowAll, isDebuff, isPersonal, actualAuraType)
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
			auraIconFrame.CanStealOrPurge = false
			auraIconFrame.AuraType = AURA_TYPES[actualAuraType] or "none"

			if (auraType == "DEBUFF") then
				auraIconFrame.filter = "HARMFUL"
				auraIconFrame:GetParent().HasDebuff = true
				
			elseif (auraType == "BUFF") then
				auraIconFrame.filter = "HELPFUL"
				auraIconFrame:GetParent().HasBuff = true
				
			else
				auraIconFrame.filter = ""
			end
		end
		
		--> caching the profile for performance
		local profile = Plater.db.profile
		
		self.AuraCache [spellId] = true
		self.AuraCache [spellName] = true
		
		--> check if a full refresh is required
		if (auraIconFrame.RefreshID < PLATER_REFRESH_ID) then
			--stack counter
			local stackLabel = auraIconFrame.CountFrame.Count
			DF:SetFontSize (stackLabel, profile.aura_stack_size)
			
			--DF:SetFontOutline (stackLabel, profile.aura_stack_shadow)
			Plater.SetFontOutlineAndShadow (stackLabel, profile.aura_stack_outline, profile.aura_stack_shadow_color, profile.aura_stack_shadow_color_offset[1], profile.aura_stack_shadow_color_offset[2])
			
			DF:SetFontColor (stackLabel, profile.aura_stack_color)
			DF:SetFontFace (stackLabel, profile.aura_stack_font)
			Plater.SetAnchor (stackLabel, profile.aura_stack_anchor)
			
			--timer
			local timerLabel = auraIconFrame.Cooldown.Timer
			DF:SetFontSize (timerLabel, profile.aura_timer_text_size)
			
			--DF:SetFontOutline (timerLabel, profile.aura_timer_text_shadow)
			Plater.SetFontOutlineAndShadow (timerLabel, profile.aura_timer_text_outline, profile.aura_timer_text_shadow_color, profile.aura_timer_text_shadow_color_offset[1], profile.aura_timer_text_shadow_color_offset[2])
			
			DF:SetFontFace (timerLabel, profile.aura_timer_text_font)
			DF:SetFontColor (timerLabel, profile.aura_timer_text_color)
			Plater.SetAnchor (timerLabel, profile.aura_timer_text_anchor)
			
			auraIconFrame.RefreshID = PLATER_REFRESH_ID
			
			--icon size
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
			
			auraIconFrame.Cooldown:SetEdgeTexture (profile.aura_cooldown_edge_texture)
			auraIconFrame.Cooldown:SetReverse (profile.aura_cooldown_reverse)
			auraIconFrame.Cooldown:SetDrawSwipe (profile.aura_cooldown_show_swipe)

			Plater.UpdateIconAspecRatio (auraIconFrame)
			
			--if tooltip enabled
			auraIconFrame:EnableMouse (profile.aura_show_tooltip)
			auraIconFrame:SetMouseClickEnabled (false)
		end

		--icon size repeated due to:
		--when the size is changed in the options it doesnt change the IsPersonal flag
		--when it changes the isPersonal flag it change locally without increasing the refresh ID
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
			
			Plater.UpdateIconAspecRatio (auraIconFrame)
		end
		auraIconFrame.IsPersonal = isPersonal

		if (count > 1) then
			local stackLabel = auraIconFrame.CountFrame.Count
			stackLabel:SetText (count)
			stackLabel:Show()
		else
			auraIconFrame.CountFrame.Count:Hide()
		end
		
		--border colors
		if (canStealOrPurge) then
			auraIconFrame:SetBackdropBorderColor (unpack (profile.aura_border_colors.steal_or_purge))
			auraIconFrame.CanStealOrPurge = true
		
		elseif (Plater.db.profile.aura_border_colors_by_type) then
			-- use Blizzards color global 'DebuffTypeColor' for the actual color:
			local color = DebuffTypeColor[actualAuraType or "none"] or {r=0,b=0,g=0, a=0}
			auraIconFrame:SetBackdropBorderColor (color.r, color.g, color.b, color.a or 1)
		
		elseif (isBuff) then
			auraIconFrame:SetBackdropBorderColor (unpack (profile.aura_border_colors.is_buff))
			auraIconFrame.IsShowingBuff = true
		
		elseif (isDebuff) then
			--> for debuffs on the player for the personal bar
			auraIconFrame:SetBackdropBorderColor (1, 0, 0, 1)
		
		elseif (actualAuraType == AURA_TYPE_ENRAGE) then 
			--> enrage effects
			auraIconFrame:SetBackdropBorderColor (unpack (profile.aura_border_colors.enrage))
		
		elseif (isShowAll) then
			auraIconFrame:SetBackdropBorderColor (unpack (profile.aura_border_colors.is_show_all))
				
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
		auraIconFrame.RemainingTime = max (expirationTime - GetTime(), 0)
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
			scriptEnv._CanStealOrPurge = canStealOrPurge
			scriptEnv._AuraType = AURA_TYPES[actualAuraType] or "none"
			
			--run onupdate script
			auraIconFrame:ScriptRunOnUpdate (scriptInfo)
		end	
		
		--Plater.Masque.AuraFrame1:ReSkin()

		--auraIconFrame.Icon:Hide()
		--auraIconFrame.Cooldown:SetBackdrop (nil)
		--print (auraIconFrame.Border:GetObjectType())
		--print (auraIconFrame.Icon:GetAlpha())
		
		--print (self:GetName(), self:GetSize(), self:IsShown())
		
		return true
	end

	--> check both buff frames for aura icons which aren't in use and hide them
	Plater.HideNonUsedAuraIcons = function (self)
	
		--aura frame 1
		local nextAuraIndex = self.NextAuraIcon
		for i = nextAuraIndex, #self.PlaterBuffList do
			local icon = self.PlaterBuffList [i]
			if (icon and icon.InUse and icon:IsShown()) then
				icon:Hide()
				icon.InUse = false
			end
		end
		
		--save the amount of auras shown
		--used to move up the resource frame when it is shown on current target
		--also used on the aura align function
		self.amountAurasShown = self.NextAuraIcon - 1
		
		--aura frame 2
		if (DB_AURA_SEPARATE_BUFFS) then
			--secondary buff frame
			local buffFrame2 = self.BuffFrame2

			local nextAuraIndex = buffFrame2.NextAuraIcon
			for i = nextAuraIndex, #buffFrame2.PlaterBuffList do
				local icon = buffFrame2.PlaterBuffList [i]
				if (icon and icon.InUse and icon:IsShown()) then
					icon:Hide()
					icon.InUse = false
				end
			end
			
			--save the amount of auras shown
			buffFrame2.amountAurasShown = buffFrame2.NextAuraIcon - 1
		end
		
		--move up the resource frame if shown
		Plater.UpdateResourceFrameAnchor (self)
	end

	
	--~special ~auraspecial
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
			
		elseif (Plater.db.profile.extra_icon_use_blizzard_border_color) then
			-- use blizzard border colors
			local color = DebuffTypeColor[actualAuraType or "none"] or {r=0,b=0,g=0, a=0}
			borderColor = {color.r, color.g, color.b, color.a or 1}
			
		elseif (CROWDCONTROL_AURA_NAMES [spellName]) then
			borderColor = Plater.db.profile.debuff_show_cc_border
		
		elseif (debuffType == AURA_TYPE_ENRAGE) then 
			--> enrage effects
			borderColor = Plater.db.profile.extra_icon_show_enrage_border
		
		else
			borderColor = Plater.db.profile.extra_icon_border_color
			
		end
		
		--spellId, borderColor, startTime, duration, forceTexture, descText
		local iconFrame = self.ExtraIconFrame:SetIcon (spellId, borderColor, expirationTime - duration, duration, false, casterName and {text = casterName, text_color = casterClass} or false, count, debuffType, caster, canStealOrPurge)
		--add the spell into the cache
		self.ExtraIconFrame.AuraCache [spellId] = true
		self.ExtraIconFrame.AuraCache [spellName] = true
		
		--check if Masque is enabled on Plater and reskin the aura icon
		if (Plater.Masque and not iconFrame.Masqued) then
			local t = {
				FloatingBG = nil, --false,
				Icon = iconFrame.Texture,
				Cooldown = iconFrame.Cooldown,
				Flash = nil, --false,
				Pushed = nil, --false,
				Normal = false,
				Disabled = nil, --false,
				Checked = nil, --false,
				Border = nil, --iconFrame.Border,
				AutoCastable = nil, --false,
				Highlight = nil, --false,
				HotKey = nil, --false,
				Count = false,
				Name = nil, --false,
				Duration = false,
				Shine = nil, --false,
			}
			iconFrame.Border:Hide() --let Masque handle the border...
			Plater.Masque.BuffSpecial:AddButton (iconFrame, t)
			Plater.Masque.BuffSpecial:ReSkin()
			iconFrame.Masqued = true
		end
	end
	
	--> reset both buff frames to make them ready to receive an aura update
	function Plater.ResetAuraContainer (self)
		--> reset the extra icon frame
		self.ExtraIconFrame:ClearIcons()

		--> reset next aura icon to use
		self.NextAuraIcon = 1
		self.BuffFrame2.NextAuraIcon = 1
		
		--> reset auras
		self.HasBuff = false
		self.HasDebuff = false
		
		--> second buff anchor
		self.BuffFrame2.HasBuff = false 
		self.BuffFrame2.HasDebuff = false
		
		--> wipe the cache
		wipe (self.AuraCache)
		wipe (self.BuffFrame2.AuraCache)
		wipe (self.ExtraIconFrame.AuraCache)
		
	end

	
	-- ~auras ~aura
	--receives a hash table with spell names keys and true as the value
	--used when the user selects manual aura tracking
	function Plater.TrackSpecificAuras (self, unit, isBuff, aurasToCheck, isPersonal, noSpecial)

		if (isBuff) then
			--> buffs
			for i = 1, BUFF_MAX_DISPLAY do
				local name, texture, count, actualAuraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId = UnitBuff (unit, i)
				if (not name) then
					break
				else
					local auraType = "BUFF"
					--verify is this aura is in the table passed
					if (aurasToCheck [name]) then
						local auraIconFrame, buffFrame = Plater.GetAuraIcon (self, true)
						Plater.AddAura (buffFrame, auraIconFrame, i, name, texture, count, auraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId, true, false, false, isPersonal, actualAuraType)
					end
					
					--> check if is a special aura
					if (not noSpecial) then
						--> check for special auras auto added by setting like 'show crowd control' or 'show dispellable'
						--> SPECIAL_AURAS_AUTO_ADDED has a list of crowd control not do not have a list of dispellable, so check if canStealOrPurge.
						--> in addition, we want to check if enrage tracking is enabled and show enrage effects
						if (SPECIAL_AURAS_AUTO_ADDED [name] or (DB_SHOW_PURGE_IN_EXTRA_ICONS and canStealOrPurge) or (DB_SHOW_ENRAGE_IN_EXTRA_ICONS and actualAuraType == AURA_TYPE_ENRAGE)) then
							Plater.AddExtraIcon (self, name, texture, count, actualAuraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId)
						
						--> check for special auras added by the user it self
						elseif (((SPECIAL_AURAS_USER_LIST [name] or SPECIAL_AURAS_USER_LIST [spellId]) and not (SPECIAL_AURAS_USER_LIST_MINE [name] or SPECIAL_AURAS_USER_LIST_MINE [spellId])) or ((SPECIAL_AURAS_USER_LIST_MINE [name] or SPECIAL_AURAS_USER_LIST_MINE [spellId]) and caster and (UnitIsUnit (caster, "player") or UnitIsUnit (caster, "pet")))) then
							Plater.AddExtraIcon (self, name, texture, count, actualAuraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId)
							
						end
					end
				end
			end
		else
			--> debuffs
			for i = 1, BUFF_MAX_DISPLAY do
				--using the PLAYER filter it'll avoid special auras to be scan
				--local name, texture, count, auraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId = UnitDebuff (unit, i, "HARMFUL|PLAYER")
				local name, texture, count, actualAuraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId = UnitDebuff (unit, i)
				if (not name) then
					break
				else
					local auraType = "DEBUFF"
					--checking here if the debuff is placed by the player
					--if (caster and aurasToCheck [name] and UnitIsUnit (caster, "player")) then --this doesn't track the pet, so auras like freeze from mage frost elemental won't show
					if (caster and aurasToCheck [name] and (UnitIsUnit (caster, "player") or UnitIsUnit (caster, "pet"))) then
					--if (aurasToCheck [name]) then
						local auraIconFrame, buffFrame = Plater.GetAuraIcon (self)
						Plater.AddAura (buffFrame, auraIconFrame, i, name, texture, count, auraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId, false, false, false, isPersonal, actualAuraType)
					end
					
					--> check if is a special aura
					if (not noSpecial) then
						--> check for special auras auto added by setting like 'show crowd control' or 'show dispellable'
						--> SPECIAL_AURAS_AUTO_ADDED has a list of crowd control not do not have a list of dispellable, so check if canStealOrPurge
						--> in addition, we want to check if enrage tracking is enabled and show enrage effects
						if (SPECIAL_AURAS_AUTO_ADDED [name] or (DB_SHOW_PURGE_IN_EXTRA_ICONS and canStealOrPurge) or (DB_SHOW_ENRAGE_IN_EXTRA_ICONS and actualAuraType == AURA_TYPE_ENRAGE)) then
							Plater.AddExtraIcon (self, name, texture, count, actualAuraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId)
						
						--> check for special auras added by the user it self
						elseif (((SPECIAL_AURAS_USER_LIST [name] or SPECIAL_AURAS_USER_LIST [spellId]) and not (SPECIAL_AURAS_USER_LIST_MINE [name] or SPECIAL_AURAS_USER_LIST_MINE [spellId])) or ((SPECIAL_AURAS_USER_LIST_MINE [name] or SPECIAL_AURAS_USER_LIST_MINE [spellId]) and caster and (UnitIsUnit (caster, "player") or UnitIsUnit (caster, "pet")))) then
							Plater.AddExtraIcon (self, name, texture, count, actualAuraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId)
							
						end
					end
				end
			end
		end
		
		return true
	end
	
	function Plater.UpdateAuras_Manual (self, unit, isPersonal)
		Plater.ResetAuraContainer (self)
		
		Plater.TrackSpecificAuras (self, unit, false, MANUAL_TRACKING_DEBUFFS, isPersonal)
		Plater.TrackSpecificAuras (self, unit, true, MANUAL_TRACKING_BUFFS, isPersonal)

		--> hide not used aura frames
		Plater.HideNonUsedAuraIcons (self)
	end

	--> track auras automatically when the user has automatic aura tracking selected in the options panel
	function Plater.UpdateAuras_Automatic (self, unit)
		Plater.ResetAuraContainer (self)
		
		--> debuffs
			for i = 1, BUFF_MAX_DISPLAY do
			
				--todo: fix the variable name inconsistence, here the buff name is called "spellName" in the other loop below is called "name"
				local name, texture, count, actualAuraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, isCastByPlayer, nameplateShowAll = UnitDebuff (unit, i)
				--start as false, during the checks can be changed to true, if is true this debuff is added on the nameplate
				local can_show_this_debuff
				local auraType = "DEBUFF"
				
				if (not name) then
					break
				
				--check if the debuff isn't filtered out
				elseif (not DB_DEBUFF_BANNED [name]) then
			
					--> if true it'll show all auras - this can be called from scripts to debug aura things
					if (Plater.DebugAuras) then
						if (duration and duration < 60) then
							can_show_this_debuff = true
						end
					end
			
					--> important aura
					if (DB_AURA_SHOW_IMPORTANT and (nameplateShowAll or isBossDebuff)) then
						can_show_this_debuff = true
					
					--> is casted by the player
					elseif (DB_AURA_SHOW_BYPLAYER and caster and (UnitIsUnit (caster, "player") or UnitIsUnit (caster, "pet") or Plater.PlayerPetCache[UnitGUID(caster)])) then
						can_show_this_debuff = true
						
					--> user added this buff to track in the buff tracking tab
					elseif (AUTO_TRACKING_EXTRA_DEBUFFS [name]) then
						can_show_this_debuff = true
					end
					
					--> check for special auras auto added by setting like 'show crowd control' or 'show dispellable'
					--> SPECIAL_AURAS_AUTO_ADDED has a list of crowd control not do not have a list of dispellable, so check if canStealOrPurge
					--> in addition, we want to check if enrage tracking is enabled and show enrage effects
					if (SPECIAL_AURAS_AUTO_ADDED [name] or (DB_SHOW_PURGE_IN_EXTRA_ICONS and canStealOrPurge) or (DB_SHOW_ENRAGE_IN_EXTRA_ICONS and actualAuraType == AURA_TYPE_ENRAGE)) then
						Plater.AddExtraIcon (self, name, texture, count, actualAuraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId)
						can_show_this_debuff = false
					end
				end
				
				--> check for special auras added by the user it self
				if (((SPECIAL_AURAS_USER_LIST [name] or SPECIAL_AURAS_USER_LIST [spellId]) and not (SPECIAL_AURAS_USER_LIST_MINE [name] or SPECIAL_AURAS_USER_LIST_MINE [spellId])) or ((SPECIAL_AURAS_USER_LIST_MINE [name] or SPECIAL_AURAS_USER_LIST_MINE [spellId]) and caster and (UnitIsUnit (caster, "player") or UnitIsUnit (caster, "pet")))) then
					Plater.AddExtraIcon (self, name, texture, count, actualAuraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId)
					can_show_this_debuff = false
				end
				
				if (can_show_this_debuff) then
					--get the icon to be used by this aura
					local auraIconFrame, buffFrame = Plater.GetAuraIcon (self)
					Plater.AddAura (buffFrame, auraIconFrame, i, name, texture, count, auraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId, nil, nil, nil, nil, actualAuraType)
				end
			end
		
		--> buffs
			for i = 1, BUFF_MAX_DISPLAY do
				local name, texture, count, actualAuraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, isCastByPlayer, nameplateShowAll = UnitBuff (unit, i)
				local auraType = "BUFF"
				
				if (not name) then
					break
				end
				
				--> check for special auras added by the user it self
				if (((SPECIAL_AURAS_USER_LIST [name] or SPECIAL_AURAS_USER_LIST [spellId]) and not (SPECIAL_AURAS_USER_LIST_MINE [name] or SPECIAL_AURAS_USER_LIST_MINE [spellId])) or ((SPECIAL_AURAS_USER_LIST_MINE [name] or SPECIAL_AURAS_USER_LIST_MINE [spellId]) and caster and (UnitIsUnit (caster, "player") or UnitIsUnit (caster, "pet")))) then
					Plater.AddExtraIcon (self, name, texture, count, actualAuraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId)
					
				elseif (not DB_BUFF_BANNED [name]) then
					--> if true it'll show all auras - this can be called from scripts to debug aura things
					if (Plater.DebugAuras) then
						if (duration and duration < 60) then
							local auraIconFrame, buffFrame = Plater.GetAuraIcon (self, true)
							Plater.AddAura (buffFrame, auraIconFrame, i, name, texture, count, auraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId, true, nil, nil, nil, actualAuraType)
						end
					end
					
					--> this special aura check is inside the 'buff banned' prevented because they are automatic added
					--> check for special auras auto added by setting like 'show crowd control' or 'show dispellable'
					--> SPECIAL_AURAS_AUTO_ADDED has a list of crowd control not do not have a list of dispellable, so check if canStealOrPurge
					--> in addition, we want to check if enrage tracking is enabled and show enrage effects
					if (SPECIAL_AURAS_AUTO_ADDED [name] or (DB_SHOW_PURGE_IN_EXTRA_ICONS and canStealOrPurge) or (DB_SHOW_ENRAGE_IN_EXTRA_ICONS and actualAuraType == AURA_TYPE_ENRAGE)) then
						Plater.AddExtraIcon (self, name, texture, count, actualAuraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId)
					else
						--> important aura
						if (DB_AURA_SHOW_IMPORTANT and (nameplateShowAll or isBossDebuff)) then
							local auraIconFrame, buffFrame = Plater.GetAuraIcon (self, true)
							Plater.AddAura (buffFrame, auraIconFrame, i, name, texture, count, auraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId, false, true, nil, nil, actualAuraType)
						
						--> is dispellable or can be steal
						elseif (DB_AURA_SHOW_DISPELLABLE and canStealOrPurge) then
							local auraIconFrame, buffFrame = Plater.GetAuraIcon (self, true)
							Plater.AddAura (buffFrame, auraIconFrame, i, name, texture, count, auraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId, nil, nil, nil, nil, actualAuraType)
						
						--> is enrage
						elseif (DB_AURA_SHOW_ENRAGE and actualAuraType == AURA_TYPE_ENRAGE) then
							local auraIconFrame, buffFrame = Plater.GetAuraIcon (self, true)
							Plater.AddAura (buffFrame, auraIconFrame, i, name, texture, count, auraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId, nil, nil, nil, nil, actualAuraType)
						
						--> is casted by the player
						elseif (DB_AURA_SHOW_BYPLAYER and caster and UnitIsUnit (caster, "player")) then
							local auraIconFrame, buffFrame = Plater.GetAuraIcon (self, true)
							Plater.AddAura (buffFrame, auraIconFrame, i, name, texture, count, auraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId, nil, nil, nil, nil, actualAuraType)
						
						--> is casted by the unit it self
						elseif (DB_AURA_SHOW_BYUNIT and caster and UnitIsUnit (caster, unit) and not isCastByPlayer) then
							local auraIconFrame, buffFrame = Plater.GetAuraIcon (self, true)
							Plater.AddAura (buffFrame, auraIconFrame, i, name, texture, count, auraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId, true, nil, nil, nil, actualAuraType)
						
						--> user added this buff to track in the buff tracking tab
						elseif (AUTO_TRACKING_EXTRA_BUFFS [name]) then
							local auraIconFrame, buffFrame = Plater.GetAuraIcon (self, true)
							Plater.AddAura (buffFrame, auraIconFrame, i, name, texture, count, auraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId, true, nil, nil, nil, actualAuraType)
							
						end
					end

				end
			end
		
		--hide non used icons
			Plater.HideNonUsedAuraIcons (self)
	end

	function Plater.UpdateAuras_Self_Automatic (self)
		Plater.ResetAuraContainer (self)
		
		--> debuffs
		if (Plater.db.profile.aura_show_debuffs_personal) then
			for i = 1, BUFF_MAX_DISPLAY do
				local name, texture, count, actualAuraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId = UnitDebuff ("player", i)
				local auraType = "DEBUFF"
				
				if (not name) then
					break
					
				elseif (not DB_DEBUFF_BANNED [name]) then
					local auraIconFrame, buffFrame = Plater.GetAuraIcon (self)
					Plater.AddAura (buffFrame, auraIconFrame, i, name, texture, count, auraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId, false, false, true, true, actualAuraType)
					
					--> check for special auras auto added by setting like 'show crowd control' or 'show dispellable'
					--> SPECIAL_AURAS_AUTO_ADDED has a list of crowd control not do not have a list of dispellable, so check if canStealOrPurge
					--> in addition, we want to check if enrage tracking is enabled and show enrage effects
					if (SPECIAL_AURAS_AUTO_ADDED [name] or (DB_SHOW_PURGE_IN_EXTRA_ICONS and canStealOrPurge) or (DB_SHOW_ENRAGE_IN_EXTRA_ICONS and actualAuraType == AURA_TYPE_ENRAGE)) then
						Plater.AddExtraIcon (self, name, texture, count, actualAuraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId)
					end
				end
				
				--> check for special auras added by the user it self
				if (((SPECIAL_AURAS_USER_LIST [name] or SPECIAL_AURAS_USER_LIST [spellId]) and not (SPECIAL_AURAS_USER_LIST_MINE [name] or SPECIAL_AURAS_USER_LIST_MINE [spellId])) or ((SPECIAL_AURAS_USER_LIST_MINE [name] or SPECIAL_AURAS_USER_LIST_MINE [spellId]) and caster and (UnitIsUnit (caster, "player") or UnitIsUnit (caster, "pet")))) then
					Plater.AddExtraIcon (self, name, texture, count, actualAuraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId)
				end
				
			end
		end
		
		--> buffs
		if (Plater.db.profile.aura_show_buffs_personal) then
			for i = 1, BUFF_MAX_DISPLAY do
				local name, texture, count, actualAuraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId = UnitBuff ("player", i, nil, "PLAYER")
				local auraType = "BUFF"
				
				if (not name) then
					break
					
				--> only show buffs casted by the player it self and less than 1 minute in duration
				elseif (not DB_BUFF_BANNED [name] and (duration and (duration > 0 and duration < 60)) and (caster and UnitIsUnit (caster, "player"))) then
					local auraIconFrame, buffFrame = Plater.GetAuraIcon (self, true)
					Plater.AddAura (buffFrame, auraIconFrame, i, name, texture, count, auraType, duration, expirationTime, caster, canStealOrPurge, nameplateShowPersonal, spellId, false, false, false, true, actualAuraType)

				end
				
				--> there is no special auras for buffs in the personal bar
			end
		end	
		
		--> hide not used aura frames
		Plater.HideNonUsedAuraIcons (self)
	end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> color stuff ~color

	function Plater.SetQuestColorByReaction (unitFrame)
		--unit is a quest mob, reset the color to quest color
		if (unitFrame.ActorType) then
			if (unitFrame [MEMBER_REACTION] == UNITREACTION_NEUTRAL) then
				Plater.ChangeHealthBarColor_Internal (unitFrame.healthBar, unpack (DB_PLATE_CONFIG [unitFrame.ActorType].quest_color_neutral))
				
			elseif (unitFrame [MEMBER_REACTION] < UNITREACTION_NEUTRAL) then
				Plater.ChangeHealthBarColor_Internal (unitFrame.healthBar, unpack (DB_PLATE_CONFIG [unitFrame.ActorType].quest_color_enemy))
				
			else
				--there's a bug here where quest_color is nil for a friendly npc
				--this is happening when an enemy quest npc turns friendly and (probably) the actorType doesn't change
				--so in the enemy npc settings table does not have 'quest_color' input
				Plater.ChangeHealthBarColor_Internal (unitFrame.healthBar, unpack (DB_PLATE_CONFIG [unitFrame.ActorType].quest_color or {.5, 1, 0}))
			end
		end
	end

	--override colors
	--this function will set the color of the nameplate by the reaction of the unit shown
	--it can only run if color override is enabled and when not in combat or when in combat but color by aggro is disabled
	function Plater.ColorOverrider (unitFrame, forceRefresh)
		--not in combat or aggro isn't changing the healthbar color
		if (forceRefresh or not InCombatLockdown() or not DB_AGGRO_CHANGE_HEALTHBAR_COLOR) then
			--isn't a quest
			if (not unitFrame [MEMBER_QUEST]) then
				local reaction = unitFrame [MEMBER_REACTION]
				--has a valid reaction
				if (reaction) then
					local r, g, b = unpack (Plater.db.profile.color_override_colors [reaction])
					Plater.ChangeHealthBarColor_Internal (unitFrame.healthBar, r, g, b, true)
				end
			else
				--unit is a quest mob, reset the color to quest color
				Plater.SetQuestColorByReaction (unitFrame)
			end
		end
	end

	--refresh the use of the color overrider
	--called from the OnInit and from the options panel when the override color settings is changed
	function Plater.RefreshColorOverride() --private
		if (Plater.db.profile.color_override) then
			Plater.CanOverrideColor = true
		else
			Plater.CanOverrideColor = false
		end
		
		Plater.UpdateAllNameplateColors()
	end
	
	--internal function to change the health bar color
	function Plater.ChangeHealthBarColor_Internal (healthBar, r, g, b, forceNoLerp) --private
		if (r ~= healthBar.R or g ~= healthBar.G or b ~= healthBar.B) then
			healthBar.R, healthBar.G, healthBar.B = r, g, b
			if (not DB_LERP_COLOR or forceNoLerp) then -- ~lerpcolor
				healthBar.barTexture:SetVertexColor (r, g, b)
			end
		end
	end

	--do several checkes to determine which are the color of this nameplate
	--if force refresh is true, it'll ignore aggro and incombat checks in the ColorOverrider function
	function Plater.FindAndSetNameplateColor (unitFrame, forceRefresh)
		local r, g, b = 1, 1, 1
		local unitID = unitFrame.unit
		
		if (unitFrame.isSelf) then
			return
			
		else
			--check if is a player
			if UnitIsPlayer (unitID) then
				if (unitFrame.ActorType == ACTORTYPE_FRIENDLY_PLAYER) then
					if (Plater.db.profile.use_playerclass_color) then
						local _, class = UnitClass (unitID)
						local classColor = RAID_CLASS_COLORS [class]
						if (classColor) then -- and unitFrame.optionTable.useClassColors
							r, g, b = classColor.r, classColor.g, classColor.b
						end
					else
						r, g, b = unpack(Plater.db.profile.plate_config.friendlyplayer.fixed_class_color)
					end
				elseif (unitFrame.ActorType == ACTORTYPE_ENEMY_PLAYER) then
					if (Plater.db.profile.plate_config.enemyplayer.use_playerclass_color) then
						local _, class = UnitClass (unitID)
						local classColor = RAID_CLASS_COLORS [class]
						if (classColor) then -- and unitFrame.optionTable.useClassColors
							r, g, b = classColor.r, classColor.g, classColor.b
						end
					else
						r, g, b = unpack(Plater.db.profile.plate_config.enemyplayer.fixed_class_color)
					end
				end
				
			--check if is tapped
			elseif (Plater.IsUnitTapDenied (unitID)) then
				r, g, b = unpack (Plater.db.profile.tap_denied_color)

			else
				if (Plater.CanOverrideColor) then
					Plater.ColorOverrider (unitFrame, forceRefresh)
					return
				end

				--check if the mob is a quest mob
				if (unitFrame [MEMBER_QUEST]) then
					Plater.SetQuestColorByReaction (unitFrame)
					return
				end
				
				--get the color from the client
				r, g, b = UnitSelectionColor (unitID)
			end
		end
		
		Plater.ChangeHealthBarColor_Internal (unitFrame.healthBar, r, g, b, true)
	end

	--force an update on all nameplates showin in the screen
	--called after a refresh color override (on init and option settings changes)
	--called after leaving the combat
	function Plater.UpdateAllNameplateColors() --private
		for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
			if (not plateFrame.isSelf) then
				--reset the nameplate color
				Plater.FindAndSetNameplateColor (plateFrame.unitFrame)
			end
		end
	end
	
	--get a unit and a text and color the text with the class color of the unit
	function Plater.SetTextColorByClass (unit, text)
		--checking if the unit exists because this can be called from the cleu parser
		if (unit) then
			local _, class = UnitClass (unit)
			if (class) then
				local color = RAID_CLASS_COLORS [class]
				if (color) then
					text = "|c" .. color.colorStr .. DF:RemoveRealName (text) .. "|r"
				end
			else
				text = DF:RemoveRealName (text)
			end
			return text
		else
			return text
		end
	end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> update functions ~update

	--full refresh calls
	function Plater.UpdateAllPlates (forceUpdate, justAdded) --private
		for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
			Plater.UpdatePlateFrame (plateFrame, nil, forceUpdate, justAdded)
		end
	end
	
	--called from the options panel
	function Plater.FullRefreshAllPlates() --private
		for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
			--hack to call the update without overriding user settings from scripts
			Plater.RunScheduledUpdate ({plateFrame = plateFrame, GUID = plateFrame [MEMBER_GUID]})
		end
	end

	--update the player bar (personal nameplate)
	local re_update_self_plate = function()
		Plater.UpdateSelfPlate()
	end

	function Plater.UpdateSelfPlate() --private
		if (InCombatLockdown()) then
			return C_Timer.After (.3, re_update_self_plate)
		end
		C_NamePlate.SetNamePlateSelfClickThrough (DB_PLATE_CONFIG.player.click_through)
		
		--disabled due to modifying the player personal nameplate makes it be a little offset in the Y anchor making it to be in front of the player
	--	C_NamePlate.SetNamePlateSelfSize (unpack (DB_PLATE_CONFIG.player.health))
	end
	
	-- ~size ~updatesize
	--update thee nameplate size including healthbar, castbar, etc
	function Plater.UpdatePlateSize (plateFrame)
		if (not plateFrame.actorType) then
			return
		end
		
		local isInCombat = PLAYER_IN_COMBAT
		
		local unitFrame = plateFrame.unitFrame
		local healthBar = unitFrame.healthBar
		local castBar = unitFrame.castBar
		local powerBar = unitFrame.powerBar
		local buffFrame1 = unitFrame.BuffFrame
		local buffFrame2 = unitFrame.BuffFrame2
		
		--use in combat bars when in pvp
		if (plateFrame.actorType == ACTORTYPE_ENEMY_PLAYER) then
			if ((Plater.ZoneInstanceType == "pvp" or Plater.ZoneInstanceType == "arena") and DB_PLATE_CONFIG.player.pvp_always_incombat) then
				isInCombat = true
			end
		end
		
		local actorType = plateFrame.actorType
		
		local profile = Plater.db.profile
		--get the config for this actor type
		local plateConfigs = DB_PLATE_CONFIG [actorType]
		--get the config key based if the player is in combat
		local castBarConfigKey, healthBarConfigKey, manaConfigKey = Plater.GetHashKey (isInCombat)

		local healthBarWidth, healthBarHeight = unitFrame.customHealthBarWidth or plateConfigs [healthBarConfigKey][1], unitFrame.customHealthBarHeight or plateConfigs [healthBarConfigKey][2]
		local castBarWidth, castBarHeight = unitFrame.customCastBarWidth or plateConfigs [castBarConfigKey][1], unitFrame.customCastBarHeight or plateConfigs [castBarConfigKey][2]
		local powerBarWidth, powerBarHeight = unitFrame.customPowerBarHeight or plateConfigs [manaConfigKey][1], unitFrame.customPowerBarHeight or plateConfigs [manaConfigKey][2]
		
		local castBarOffSetX = (healthBarWidth - castBarWidth) / 2
		local castBarOffSetY = plateConfigs.castbar_offset
		
		local powerBarOffSetX = (healthBarWidth - powerBarWidth) / 2
		local powerBarOffSetY = 0

		--calculate the size deviation for pets
		local unitType = Plater.GetUnitType (plateFrame)
		if (unitType == "pet") then
			healthBarHeight = healthBarHeight * Plater.db.profile.pet_height_scale
			healthBarWidth = healthBarWidth * Plater.db.profile.pet_width_scale

		elseif (unitType == "minus") then
			healthBarHeight = healthBarHeight * Plater.db.profile.minor_height_scale
			healthBarWidth = healthBarWidth * Plater.db.profile.minor_width_scale
		end
		
		--community patch by Ariani#0960 (discord)
		--make the unitFrame be parented to UIParent allowing frames to be moved between strata levels
		--March 3rd, 2019
		if (DB_USE_UIPARENT) then
			--unit frame - is set to be the same size as the plateFrame
				unitFrame:ClearAllPoints()
				unitFrame:SetPoint ("topleft", unitFrame.PlateFrame, "topleft", 0, 0)
				unitFrame:SetPoint ("bottomright", unitFrame.PlateFrame, "bottomright", 0, 0)
				
			--health bar
				-- ensure that we are using the configured size, as it will be automatically scaled
				healthBar:ClearAllPoints()
				PixelUtil.SetPoint (healthBar, "center", unitFrame, "center", profile.global_offset_x, profile.global_offset_y)
				PixelUtil.SetSize (healthBar, healthBarWidth, healthBarHeight)
		--end of patch
			--update scale
			Plater.UpdateUIParentScale (plateFrame)
		else
			--unit frame - is set to be the same size as the plateFrame
				unitFrame:ClearAllPoints()
				--unitFrame:SetAllPoints()
				--using the same setpoint pattern on both nameplate parent types to make easy the frameshake to handle the points
				unitFrame:SetPoint ("topleft", unitFrame.PlateFrame, "topleft", 0, 0)
				unitFrame:SetPoint ("bottomright", unitFrame.PlateFrame, "bottomright", 0, 0)
			
			--health bar
				--this calculates the health bar anchor points
				--it will always be placed in the center of the nameplate main frame attached with two anchor points
				local xOffSet = (plateFrame:GetWidth() - healthBarWidth) / 2
				local yOffSet = (plateFrame:GetHeight() - healthBarHeight) / 2
				
				healthBar:ClearAllPoints()
				PixelUtil.SetPoint (healthBar, "topleft", unitFrame, "topleft", xOffSet + profile.global_offset_x, -yOffSet + profile.global_offset_y)
				PixelUtil.SetPoint (healthBar, "bottomright", unitFrame, "bottomright", -xOffSet + profile.global_offset_x, yOffSet + profile.global_offset_y)
		end
		
		--cast bar - is set by default below the healthbar
			castBar:ClearAllPoints()
			PixelUtil.SetPoint (castBar, "topleft", healthBar, "bottomleft", castBarOffSetX, castBarOffSetY)
			PixelUtil.SetPoint (castBar, "topright", healthBar, "bottomright", -castBarOffSetX, castBarOffSetY)
			PixelUtil.SetWidth (castBar, castBarWidth)
			PixelUtil.SetHeight (castBar, castBarHeight)
			PixelUtil.SetSize (castBar.Icon, castBarHeight, castBarHeight)
			PixelUtil.SetSize (castBar.BorderShield, castBarHeight * 1.4, castBarHeight * 1.4)
			PixelUtil.SetSize (castBar.Spark, profile.cast_statusbar_spark_width, castBarHeight)

		--power bar
			powerBar:ClearAllPoints()
			PixelUtil.SetPoint (powerBar, "topleft", healthBar, "bottomleft", powerBarOffSetX, powerBarOffSetY)
			PixelUtil.SetPoint (powerBar, "topright", healthBar, "bottomright", -powerBarOffSetX, powerBarOffSetY)
			PixelUtil.SetSize (powerBar, powerBarWidth, powerBarHeight)
			
			--power bar are hidden by default, show it if there's a custom size for it
			if (unitFrame.customPowerBarWidth and unitFrame.customPowerBarHeight) then
				powerBar:SetUnit (unitFrame.unit)
			end
			
		--aura frame
			--DB_AURA_Y_OFFSET = profile.aura_y_offset is from the buff Settings tab
			--plateConfigs.buff_frame_y_offset is the offset from the actor type, e.g. enemy npc
			buffFrame1:ClearAllPoints()
			PixelUtil.SetPoint (buffFrame1, "bottom", unitFrame, "top", DB_AURA_X_OFFSET,  plateConfigs.buff_frame_y_offset + DB_AURA_Y_OFFSET)
			
			buffFrame2:ClearAllPoints()
			PixelUtil.SetPoint (buffFrame2, "bottom", unitFrame, "top", Plater.db.profile.aura2_x_offset,  plateConfigs.buff_frame_y_offset + Plater.db.profile.aura2_y_offset)
	end
	
	--debug function to print the size of the anchor for each aura container
	function Plater.DebugAuraAnchor()
		print ("DB_AURA_Y_OFFSET:", DB_AURA_Y_OFFSET)
		local profile = Plater.db.profile
		--get the config for this actor type
		local plateConfigs = DB_PLATE_CONFIG ["enemynpc"]
		print ("DB_PLATE_CONFIG [enemynpc].buff_frame_y_offset:", plateConfigs.buff_frame_y_offset)
		
	end
	
	--show the background of the clickable aura, this is also shown when changing the clickable area
	function Plater.SetPlateBackground (plateFrame)
		plateFrame:SetBackdrop ({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16, edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1})
		plateFrame:SetBackdropColor (0, 0, 0, 0.5)
		plateFrame:SetBackdropBorderColor (0, 0, 0, 1)
	end

	local shutdown_platesize_debug = function (timer)
		for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
		
			Plater.HideClickSpace (plateFrame)
			
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

	--debug to show the clickable area when adjusting the click space
	function Plater.ShowClickSpace (plateFrame)
		plateFrame.debugAreaText:Show()
		plateFrame.debugAreaTexture:Show()
	end
	function Plater.HideClickSpace (plateFrame)
		plateFrame.debugAreaText:Hide()
		plateFrame.debugAreaTexture:Hide()
	end
	
	-- ~platesize
	function Plater.UpdatePlateClickSpace (needReorder, isDebug) --private
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
				if not plateFrame.isSelf then
					Plater.ShowClickSpace (plateFrame)
					
					if (Plater.PlateSizeDebugTimer and not Plater.PlateSizeDebugTimer._cancelled) then
						Plater.PlateSizeDebugTimer:Cancel()
					end
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
	
	function Plater.ForceTickOnAllNameplates() --private
		for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
			Plater.NameplateTick (plateFrame.OnTickFrame, 1) --GetWorldDeltaSeconds()
		end
	end
	
	-- ~ontick ~onupdate ~tick
	function Plater.NameplateTick (tickFrame, deltaTime) --private

		tickFrame.ThrottleUpdate = tickFrame.ThrottleUpdate - deltaTime
		local unitFrame = tickFrame.unitFrame
		local healthBar = unitFrame.healthBar
		
		--throttle updates, things on this block update with the interval set in the advanced tab
		if (tickFrame.ThrottleUpdate < 0) then
			--make the db path smaller for performance
			local actorTypeDBConfig = DB_PLATE_CONFIG [tickFrame.actorType]
			
			--perform a range check
			Plater.CheckRange (tickFrame.PlateFrame)
			
			--health cutoff (execute range) - don't show if the nameplate is the personal bar
			if (DB_USE_HEALTHCUTOFF and not unitFrame.IsSelf) then
				local healthPercent = UnitHealth (tickFrame.unit) / UnitHealthMax (tickFrame.unit)
				if (healthPercent < DB_HEALTHCUTOFF_AT) then
					if (not healthBar.healthCutOff:IsShown()) then
						healthBar.healthCutOff:ClearAllPoints()
						healthBar.healthCutOff:SetSize (healthBar:GetHeight(), healthBar:GetHeight())
						healthBar.healthCutOff:SetPoint ("center", healthBar, "left", healthBar:GetWidth() * DB_HEALTHCUTOFF_AT, 0)
						
						if (not Plater.db.profile.health_cutoff_hide_divisor) then
							healthBar.healthCutOff:Show()
							healthBar.healthCutOff.ShowAnimation:Play()
						else
							healthBar.healthCutOff:Show()
							healthBar.healthCutOff:SetAlpha (0)
						end

						healthBar.executeRange:Show()
						healthBar.executeRange:SetTexCoord (0, DB_HEALTHCUTOFF_AT, 0, 1)
						healthBar.executeRange:SetAlpha (0.2)
						healthBar.executeRange:SetVertexColor (.3, .3, .3)
						healthBar.executeRange:SetHeight (healthBar:GetHeight())
						healthBar.executeRange:SetPoint ("right", healthBar.healthCutOff, "center")
						
						if (Plater.db.profile.health_cutoff_extra_glow) then
							healthBar.ExecuteGlowUp.ShowAnimation:Play()
							healthBar.ExecuteGlowDown.ShowAnimation:Play()
						end
					end
					
					unitFrame.InExecuteRange = true
				else
					healthBar.healthCutOff:Hide()
					healthBar.executeRange:Hide()
					healthBar.ExecuteGlowUp:Hide()
					healthBar.ExecuteGlowDown:Hide()
					
					unitFrame.InExecuteRange = false
				end
			end
			
			unitFrame.InCombat = UnitAffectingCombat (tickFrame.unit)
			
			--if the unit tapped? (gray color)
			if (Plater.IsUnitTapDenied (tickFrame.unit)) then
				Plater.ChangeHealthBarColor_Internal (healthBar, unpack (Plater.db.profile.tap_denied_color))
			
			--check aggro if is in combat
			elseif (PLAYER_IN_COMBAT) then

				if (unitFrame.CanCheckAggro) then
					Plater.UpdateNameplateThread (unitFrame)
				end
				
				if (actorTypeDBConfig.percent_text_enabled) then
					Plater.UpdateLifePercentText (healthBar, unitFrame.unit, actorTypeDBConfig.percent_show_health, actorTypeDBConfig.percent_show_percent, actorTypeDBConfig.percent_text_show_decimals)
				end
			else
				--if not in combat, check if can show the percent health out of combat
				if (actorTypeDBConfig.percent_text_enabled and actorTypeDBConfig.percent_text_ooc) then
					Plater.UpdateLifePercentText (healthBar, unitFrame.unit, actorTypeDBConfig.percent_show_health, actorTypeDBConfig.percent_show_percent, actorTypeDBConfig.percent_text_show_decimals)
					healthBar.lifePercent:Show()
				end
			end

			--the color overrider for unitIDs goes after the threat check and before the aura, since auras can run scripts and scripts have priority on setting colors
			if (DB_UNITCOLOR_CACHE [unitFrame [MEMBER_NPCID]]) then
				Plater.ChangeHealthBarColor_Internal (healthBar, unpack (DB_UNITCOLOR_CACHE [unitFrame [MEMBER_NPCID]]))
				unitFrame.UsingCustomColor = true --exposed to scripts
			end
			
			--update buffs and debuffs
			if (DB_AURA_ENABLED) then
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
				
				--align icons in the aura frame
				Plater.AlignAuraFrames (tickFrame.BuffFrame)
				--update the alignment on the second aura frame as well if enabled
				if (DB_AURA_SEPARATE_BUFFS) then
					Plater.AlignAuraFrames (tickFrame.BuffFrame.BuffFrame2)
				end
				
				tickFrame.BuffFrame:SetAlpha (DB_AURA_ALPHA)
				tickFrame.BuffFrame2:SetAlpha (DB_AURA_ALPHA)
			end
			-- update DBM and BigWigs nameplate auras
			Plater.UpdateBossModAuras(unitFrame)
			
			--set the delay to perform another update
			tickFrame.ThrottleUpdate = DB_TICK_THROTTLE

			--check if the unit name or unit npcID has a script
			local globalScriptObject = SCRIPT_UNIT [tickFrame.PlateFrame [MEMBER_NAMELOWER]] or SCRIPT_UNIT [unitFrame [MEMBER_NPCID]]
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
			
			--scheduled name update
			if (unitFrame.ScheduleNameUpdate) then
				if (unitFrame.ActorType == ACTORTYPE_FRIENDLY_PLAYER) then
					tickFrame.PlateFrame.playerGuildName = GetGuildInfo (tickFrame.unit)
					Plater.UpdatePlateText (tickFrame.PlateFrame, DB_PLATE_CONFIG [unitFrame.ActorType], false)
				end
				
				Plater.UpdateUnitName (tickFrame.PlateFrame)
				unitFrame.ScheduleNameUpdate = nil
				
				--run hook
				if (HOOK_UNITNAME_UPDATE.ScriptAmount > 0) then
					for i = 1, HOOK_UNITNAME_UPDATE.ScriptAmount do
						local globalScriptObject = HOOK_UNITNAME_UPDATE [i]
						local scriptContainer = unitFrame:ScriptGetContainer()
						local scriptInfo = unitFrame:ScriptGetInfo (globalScriptObject, scriptContainer, "Name Updated")
						--run
						unitFrame:ScriptRunHook (scriptInfo, "Name Updated")
					end
				end
			end
			
			--hooks
			if (HOOK_NAMEPLATE_UPDATED.ScriptAmount > 0) then
				for i = 1, HOOK_NAMEPLATE_UPDATED.ScriptAmount do
					local globalScriptObject = HOOK_NAMEPLATE_UPDATED [i]

					local scriptContainer = unitFrame:ScriptGetContainer()
					local scriptInfo = unitFrame:ScriptGetInfo (globalScriptObject, scriptContainer, "Nameplate Updated")
					local scriptEnv = scriptInfo.Env
					scriptEnv._HealthPercent = healthBar.CurrentHealth / healthBar.CurrentHealthMax * 100
					
					--run
					unitFrame:ScriptRunHook (scriptInfo, "Nameplate Updated")
				end
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
						textString:SetText (Plater.FormatNumber (damage / PLATER_DPS_SAMPLE_SIZE))
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
						textString:SetText (Plater.FormatNumber (damage / PLATER_DPS_SAMPLE_SIZE))
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
						textString:SetText (Plater.FormatNumber (damage))
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
				local r, g, b = DF:LerpLinearColor (deltaTime, DB_LERP_COLOR_SPEED, currentR, currentG, currentB, healthBar.R or currentR, healthBar.G or currentG, healthBar.B or currentB)
				healthBar.barTexture:SetVertexColor (r, g, b)
			end
			
			--animate health bar ~animation
			if (DB_DO_ANIMATIONS) then
				if (healthBar.IsAnimating) then
					healthBar.AnimateFunc (healthBar, deltaTime)
				end
			end
	end
	
	local set_aggro_color = function (self, r, g, b) --self = unitName
		if (DB_AGGRO_CHANGE_HEALTHBAR_COLOR) then	
			Plater.ChangeHealthBarColor_Internal (self.healthBar, r, g, b)
		end
		
		if (DB_AGGRO_CHANGE_BORDER_COLOR) then
			Plater.ForceChangeBorderColor (self, r, g, b)
		end
		
		if (DB_AGGRO_CHANGE_NAME_COLOR) then
			self.unitName:SetTextColor (r, g, b)
		end
	end

	--aggro threat ~aggro ~threat
	function Plater.UpdateNameplateThread (self) --self = unitFrame

		--make sure there's a unitID in the unit frame
		if (not self.displayedUnit) then
			return
		end
		
		local isTanking, threatStatus, threatpct = UnitDetailedThreatSituation ("player", self.displayedUnit)
		
		--expose all threat situation to scripts
		self.namePlateThreatIsTanking = isTanking
		self.namePlateThreatStatus = threatStatus
		self.namePlateThreatPercent = threatpct or 0
		-- (3 = securely tanking, 2 = insecurely tanking, 1 = not tanking but higher threat than tank, 0 = not tanking and lower threat than tank)
		
		self.aggroGlowUpper:Hide()
		self.aggroGlowLower:Hide()
		
		--player is a tank
		if (Plater.PlayerIsTank) then
			--and isn't tanking the unit
			if (not isTanking) then
				--is the player in combat?
				if (self.InCombat) then
					--is the player in a raid group?
					if (IsInRaid()) then
						--check if another tank is effectively tanking
						--as the other tank may not be targeted due to spell-casts, we need to check the threat situation for tanks
						local unitOffTank = nil
						local otherIsTanking, otherThreatStatus, otherThreatpct
						--loop on all tanks in the group (tank_cache is updated on entering combat or when group roster is updated) 
						for tank, _ in pairs(TANK_CACHE) do
							if not UnitIsUnit("player", tank) then
								otherIsTanking, otherThreatStatus, otherThreatpct = UnitDetailedThreatSituation (tank, self.displayedUnit)
								if otherIsTanking then
									unitOffTank = tank
									break
								end
							end
						end

						--another tank is tanking the unit
						if (unitOffTank) then
							--as the unit is being tanked by the off-tank, check if the player it self which is the other tank is about to accidently pull aggro just by hitting the mob
							if (threatpct and otherThreatpct) then
								--threatpct = player threat on the mob
								--otherThreatpct = the aggro on the tank tanking the unit
								if ((threatpct + 10) - otherThreatpct > 0) then
									set_aggro_color (self, unpack (DB_AGGRO_TANK_COLORS.pulling_from_tank))
								else
									set_aggro_color (self, unpack (DB_AGGRO_TANK_COLORS.anothertank))
								end
							else
								set_aggro_color (self, unpack (DB_AGGRO_TANK_COLORS.anothertank))
							end
						else
							--no tank is tanking this unit
							set_aggro_color (self, unpack (DB_AGGRO_TANK_COLORS.noaggro))
						end
						
						if (self.PlateFrame [MEMBER_NOCOMBAT]) then
							self.PlateFrame [MEMBER_NOCOMBAT] = nil
							Plater.CheckRange (self.PlateFrame, true)
						end
					else
						--player isn't tanking this unit
						set_aggro_color (self, unpack (DB_AGGRO_TANK_COLORS.noaggro))
						
						if (self.PlateFrame [MEMBER_NOCOMBAT]) then
							self.PlateFrame [MEMBER_NOCOMBAT] = nil
							Plater.CheckRange (self.PlateFrame, true)
						end
					end
				else
					--if isn't a quest mob
					if (not self.PlateFrame [MEMBER_QUEST]) then
						--there's no aggro, isn't in combat, isn't a quest mob
						if (self [MEMBER_REACTION] == 4) then
							--do nothing if the mob is neutral
							--set_aggro_color (self, 1, 1, 0) --ticket #185
						else
							set_aggro_color (self, unpack (DB_AGGRO_TANK_COLORS.nocombat))
						end
						
						if (DB_NOT_COMBAT_ALPHA_ENABLED) then
							self.PlateFrame [MEMBER_NOCOMBAT] = true
							self:SetAlpha (Plater.db.profile.not_affecting_combat_alpha)
						end
					end
				end
			else
				--The player is tanking and:
				if (threatStatus == 3) then --is tanking safely
					set_aggro_color (self, unpack (DB_AGGRO_TANK_COLORS.aggro))
					
				elseif (threatStatus == 2) then --is tanking with risk of aggro loss
					set_aggro_color (self, unpack (DB_AGGRO_TANK_COLORS.pulling))
					self.aggroGlowUpper:Show()
					self.aggroGlowLower:Show()
					
				else --not tanking
					set_aggro_color (self, unpack (DB_AGGRO_TANK_COLORS.noaggro))

				end
				if (self.PlateFrame [MEMBER_NOCOMBAT]) then
					self.PlateFrame [MEMBER_NOCOMBAT] = nil
					Plater.CheckRange (self.PlateFrame, true)

				end
			end
		else

			--dps
			if (isTanking) then
				--the player is tanking as dps
				if Plater.db.profile.dps.use_aggro_solo and not IsInGroup() then
					set_aggro_color (self, unpack (DB_AGGRO_DPS_COLORS.solo))
				else
					set_aggro_color (self, unpack (DB_AGGRO_DPS_COLORS.aggro))
				end
				if (not self.PlateFrame.playerHasAggro and IS_IN_INSTANCE) then
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
					
					--> unit is in combat?
					if (self.InCombat) then
						set_aggro_color (self, unpack (DB_AGGRO_DPS_COLORS.noaggro))
						self.PlateFrame.playerHasAggro = false
						
						if (self.PlateFrame [MEMBER_NOCOMBAT]) then
							self.PlateFrame [MEMBER_NOCOMBAT] = nil
							Plater.CheckRange (self.PlateFrame, true)
						end
					else
						--if isn't a quest mob
						if (not self.PlateFrame [MEMBER_QUEST]) then
							--there's no aggro, isn't in combat, isn't a quest mob
							if (self [MEMBER_REACTION] == 4) then --ticket #185
								--do nothing if the mob is neutral
								--set_aggro_color (self, 1, 1, 0)
							else
								set_aggro_color (self, unpack (DB_AGGRO_TANK_COLORS.nocombat))
							end
							
							if (Plater.db.profile.not_affecting_combat_enabled) then --not self.PlateFrame [MEMBER_NOCOMBAT] and 
								self.PlateFrame [MEMBER_NOCOMBAT] = true
								self:SetAlpha (Plater.db.profile.not_affecting_combat_alpha)
							end
						end
						
					end
				else
					if (threatStatus == 3) then --player is tanking the mob as dps
						if Plater.db.profile.dps.use_aggro_solo and not IsInGroup() then
							set_aggro_color (self, unpack (DB_AGGRO_DPS_COLORS.solo))
						else
							set_aggro_color (self, unpack (DB_AGGRO_DPS_COLORS.aggro))
						end
						if (not self.PlateFrame.playerHasAggro and IS_IN_INSTANCE) then
							self.PlateFrame.PlayBodyFlash ("-AGGRO-")
						end
						self.PlateFrame.playerHasAggro = true
						
					elseif (threatStatus == 2) then --player is tanking the mob with low aggro
						if Plater.db.profile.dps.use_aggro_solo and not IsInGroup() then
							set_aggro_color (self, unpack (DB_AGGRO_DPS_COLORS.solo))
						else
							set_aggro_color (self, unpack (DB_AGGRO_DPS_COLORS.aggro))
						end
						self.PlateFrame.playerHasAggro = true
						
					else --the unit isn't attacking the player based on the threat situation
					
						--which color the use in the nameplate based on the threat status
						--this color can be overritten by the 'no tank aggro' check
						local colorToUse
						if (threatStatus == 1) then --player is almost aggroing the mob
							--show aggro warning indicators
							self.aggroGlowUpper:Show()
							self.aggroGlowLower:Show()
							if Plater.db.profile.dps.use_aggro_solo and not IsInGroup() then
								colorToUse = DB_AGGRO_DPS_COLORS.solo
							else
								colorToUse = DB_AGGRO_DPS_COLORS.pulling
							end
							
						elseif (threatStatus == 0) then
							colorToUse = DB_AGGRO_DPS_COLORS.noaggro
							
						end
					
						if (Plater.ZoneInstanceType == "party" or Plater.ZoneInstanceType == "raid") then
							--check if can check for no tank aggro
							if (DB_AGGRO_CAN_CHECK_NOTANKAGGRO) then
								local unitTarget = UnitName (self.targetUnitID)
								--check if the unit isn't attacking a tank comparing the target name with tank names
								if (not TANK_CACHE [unitTarget]) then
								
									--check if this isn't a false positive where the mob target another unit to cast a spell
									local hasTankAggro = false
									for tankName, _ in pairs (TANK_CACHE) do
										local threatStatus = UnitThreatSituation (tankName, self.displayedUnit)
										if (threatStatus and threatStatus >= 2) then
											--a tank has aggro on this unit, it is a false positive
											hasTankAggro = true
											break
										end
									end
									
									if (not hasTankAggro) then
										--the unit isn't targeting a tank and no tank in the group has threat status of 2 or more, the unit might be attacking a dps or healer
										set_aggro_color (self, unpack (DB_AGGRO_DPS_COLORS.notontank))
									else
										--the unit isn't targeting a tank but a tank in the group has aggro on this unit
										set_aggro_color (self, unpack (colorToUse))
									end
								else
									--the unit is targeting a tank
									set_aggro_color (self, unpack (colorToUse))
								end
							else
								--isn't checking for 'no tank aggro'
								set_aggro_color (self, unpack (colorToUse))
							end
						else
							--player isn't inside a dungeon or raid
							set_aggro_color (self, unpack (colorToUse))
						end
						
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
	
	-- ~target
	function Plater.UpdateTarget (plateFrame) --private

		if (UnitIsUnit (plateFrame.unitFrame [MEMBER_UNITID], "focus") and Plater.db.profile.focus_indicator_enabled) then
			--this is a rare call, no need to cache these values
			local texture = LibSharedMedia:Fetch ("statusbar", Plater.db.profile.focus_texture)
			plateFrame.FocusIndicator:SetTexture (texture)
			plateFrame.FocusIndicator:SetVertexColor (unpack (Plater.db.profile.focus_color))
			plateFrame.FocusIndicator:Show()
		else
			plateFrame.FocusIndicator:Hide()
		end

		if (UnitIsUnit (plateFrame.unitFrame [MEMBER_UNITID], "target")) then
			plateFrame [MEMBER_TARGET] = true
			plateFrame.unitFrame [MEMBER_TARGET] = true
			
			--hide obscured texture
			plateFrame.Obscured:Hide()
			
			--target indicator
			Plater.UpdateTargetIndicator (plateFrame)
			
			--target highlight
			if (Plater.db.profile.target_highlight) then
				if (plateFrame.actorType ~= ACTORTYPE_FRIENDLY_PLAYER and plateFrame.actorType ~= ACTORTYPE_FRIENDLY_NPC and not plateFrame.PlayerCannotAttack) then
					plateFrame.TargetNeonUp:Show()
					plateFrame.TargetNeonDown:Show()
				else
					plateFrame.TargetNeonUp:Hide()
					plateFrame.TargetNeonDown:Hide()
				end
				Plater.UpdateTargetHighlight (plateFrame) --neon
			else
				plateFrame.TargetNeonUp:Hide()
				plateFrame.TargetNeonDown:Hide()
			end
			
			if (not plateFrame.unitFrame.healthBar:IsShown()) then
				plateFrame.unitFrame.targetOverlayTexture:Hide()
			else
				plateFrame.unitFrame.targetOverlayTexture:Show()
			end
			
			if (DB_USE_UIPARENT) then
				Plater.UpdateUIParentTargetLevels (plateFrame.unitFrame)
			end
			
			Plater.UpdateResourceFrame()
			
		else
			plateFrame.TargetNeonUp:Hide()
			plateFrame.TargetNeonDown:Hide()
			plateFrame.unitFrame.targetOverlayTexture:Hide()
			
			plateFrame [MEMBER_TARGET] = nil
			plateFrame.unitFrame [MEMBER_TARGET] = nil
			
			if (plateFrame.unitFrame.IsTarget or plateFrame.unitFrame.TargetTextures2Sides [1]:IsShown() or plateFrame.unitFrame.TargetTextures4Sides [1]:IsShown()) then
				for i = 1, 2 do
					plateFrame.unitFrame.TargetTextures2Sides [i]:Hide()
				end
				for i = 1, 4 do
					plateFrame.unitFrame.TargetTextures4Sides [i]:Hide()
				end
				
				plateFrame.unitFrame.IsTarget = false
			end
			
			if (DB_TARGET_SHADY_ENABLED and (not DB_TARGET_SHADY_COMBATONLY or PLAYER_IN_COMBAT) and not plateFrame.isSelf) then
				plateFrame.Obscured:Show()
				plateFrame.Obscured:SetAlpha (DB_TARGET_SHADY_ALPHA)
			else
				plateFrame.Obscured:Hide()
			end
			
			if (DB_USE_UIPARENT) then
				Plater.UpdateUIParentLevels (plateFrame.unitFrame)
			end
		end

		Plater.CheckRange (plateFrame, true) --disabled on 2018-10-09 | enabled back on 2020-1-16

	end

	--called when the player targets a new unit, when focus changed or when a unit isn't in the screen any more
	function Plater.OnPlayerTargetChanged() --private
		Plater.PlayerCurrentTargetGUID = UnitGUID ("target")
		Plater.PlayerHasTarget = Plater.PlayerCurrentTargetGUID and true
		Plater.PlayerHasTargetNonSelf = Plater.PlayerHasTarget and Plater.PlayerCurrentTargetGUID ~= Plater.PlayerGUID and true
		
		for index, plateFrame in ipairs (Plater.GetAllShownPlates()) do
			Plater.UpdateTarget (plateFrame)
			
			--hooks
			if (HOOK_TARGET_CHANGED.ScriptAmount > 0) then
				for i = 1, HOOK_TARGET_CHANGED.ScriptAmount do
					local globalScriptObject = HOOK_TARGET_CHANGED [i]
					local unitFrame = plateFrame.unitFrame
					local scriptContainer = unitFrame:ScriptGetContainer()
					local scriptInfo = unitFrame:ScriptGetInfo (globalScriptObject, scriptContainer, "Target Changed")
					--run
					unitFrame:ScriptRunHook (scriptInfo, "Target Changed")
				end
			end
		end

		Plater.CanUsePlaterResourceFrame() --~resource
	end

	function Plater.UpdateTargetHighlight (plateFrame)
		local healthBar = plateFrame.unitFrame.healthBar
		local profile = Plater.db.profile
		
		local alpha = profile.target_highlight_alpha
		local height = profile.target_highlight_height
		local color = profile.target_highlight_color
		local texture = profile.target_highlight_texture
		
		plateFrame.TargetNeonUp:SetVertexColor (unpack (color))
		plateFrame.TargetNeonUp:SetAlpha (alpha)
		plateFrame.TargetNeonUp:SetTexture (texture)
		PixelUtil.SetHeight (plateFrame.TargetNeonUp, height)
		PixelUtil.SetPoint (plateFrame.TargetNeonUp, "bottomleft", healthBar, "topleft", 0, 0)
		PixelUtil.SetPoint (plateFrame.TargetNeonUp, "bottomright", healthBar, "topright", 0, 0)

		plateFrame.TargetNeonDown:SetVertexColor (unpack (color))
		plateFrame.TargetNeonDown:SetAlpha (alpha)
		plateFrame.TargetNeonDown:SetTexture (texture)
		PixelUtil.SetHeight (plateFrame.TargetNeonDown, height)
		PixelUtil.SetPoint (plateFrame.TargetNeonDown, "topleft", healthBar, "bottomleft", 0, 0)
		PixelUtil.SetPoint (plateFrame.TargetNeonDown, "topright", healthBar, "bottomright", 0, 0)
	end

	function Plater.UpdateTargetIndicator (plateFrame)

		local healthBarHeight = plateFrame.unitFrame.healthBar:GetHeight()
		
		--if the height is lower than 4, just hide all indicators
		if (healthBarHeight < 4) then
			for i = 1, 2 do
				plateFrame.unitFrame.TargetTextures2Sides [i]:Hide()
			end
			for i = 1, 4 do
				plateFrame.unitFrame.TargetTextures4Sides [i]:Hide()
			end
			
			return
		end

		local preset = Plater.TargetIndicators [Plater.db.profile.target_indicator]
		if (not preset) then
			--use default indicator is the indicator isn't found
			preset = Plater.TargetIndicators ["Silver"]
		end
		
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
				local texture = plateFrame.unitFrame.TargetTextures4Sides [i]
				texture:Show()
				texture:SetTexture (path)
				texture:SetTexCoord (unpack (coords [i]))
				texture:SetSize (width * scale, height * scale)
				texture:SetAlpha (alpha)
				texture:SetVertexColor (overlayColorR, overlayColorG, overlayColorB)
				texture:SetDesaturated (desaturated)
				
				if (i == 1) then
					PixelUtil.SetPoint (texture, "topleft", plateFrame.unitFrame.healthBar, "topleft", -x, y)
					
				elseif (i == 2) then
					PixelUtil.SetPoint (texture, "bottomleft", plateFrame.unitFrame.healthBar, "bottomleft", -x, -y)
					
				elseif (i == 3) then
					PixelUtil.SetPoint (texture, "bottomright", plateFrame.unitFrame.healthBar, "bottomright", x, -y)
					
				elseif (i == 4) then
					PixelUtil.SetPoint (texture, "topright", plateFrame.unitFrame.healthBar, "topright", x, y)
					
				end
			end
			
			for i = 1, 2 do
				plateFrame.unitFrame.TargetTextures2Sides [i]:Hide()
			end
			
		--two parts
		else
			for i = 1, 2 do
				local texture = plateFrame.unitFrame.TargetTextures2Sides [i]
				texture:Show()
				texture:SetTexture (path)
				texture:SetBlendMode (blend)
				texture:SetTexCoord (unpack (coords [i]))
				PixelUtil.SetSize (texture, width * scale, height * scale)
				texture:SetDesaturated (desaturated)
				texture:SetAlpha (alpha)
				texture:SetVertexColor (overlayColorR, overlayColorG, overlayColorB)
				
				if (i == 1) then
					PixelUtil.SetPoint (texture, "left", plateFrame.unitFrame.healthBar, "left", -x, y)
					
				elseif (i == 2) then
					PixelUtil.SetPoint (texture, "right", plateFrame.unitFrame.healthBar, "right", x, -y)
				end
			end
			
			for i = 1, 4 do
				plateFrame.unitFrame.TargetTextures4Sides [i]:Hide()
			end
		end
		
		plateFrame.unitFrame.IsTarget = true
	end	

	-- ~updatetext ~update - called only from UpdatePlateFrame()
	-- update all texts in the nameplate, settings can variate from different unit types
	-- needReset is true when the previous unit type shown on this place is different from the current unit
	function Plater.UpdatePlateText (plateFrame, plateConfigs, needReset) --private
	
		-- ensure castBar updates are done, as this needs to be done for all types of plates...
		local spellnameString = plateFrame.unitFrame.castBar.Text
		local spellPercentString = plateFrame.unitFrame.castBar.percentText
		--update spell name text
		if (needReset) then
			DF:SetFontColor (spellnameString, plateConfigs.spellname_text_color)
			
			--DF:SetFontOutline (spellnameString, plateConfigs.spellname_text_shadow)
			Plater.SetFontOutlineAndShadow (spellnameString, plateConfigs.spellname_text_outline, plateConfigs.spellname_text_shadow_color, plateConfigs.spellname_text_shadow_color_offset[1], plateConfigs.spellname_text_shadow_color_offset[2])
			
			DF:SetFontFace (spellnameString, plateConfigs.spellname_text_font)
			DF:SetFontSize (spellnameString, plateConfigs.spellname_text_size)
			Plater.SetAnchor (spellnameString, plateConfigs.spellname_text_anchor)
		end

		--update spell cast time
		if (plateConfigs.spellpercent_text_enabled) then
			spellPercentString:Show()
			plateFrame.unitFrame.castBar.Settings.ShowCastTime = true
			if (needReset) then
				DF:SetFontColor (spellPercentString, plateConfigs.spellpercent_text_color)
				DF:SetFontSize (spellPercentString, plateConfigs.spellpercent_text_size)
				
				--DF:SetFontOutline (spellPercentString, plateConfigs.spellpercent_text_shadow)
				Plater.SetFontOutlineAndShadow (spellPercentString, plateConfigs.spellpercent_text_outline, plateConfigs.spellpercent_text_shadow_color, plateConfigs.spellpercent_text_shadow_color_offset[1], plateConfigs.spellpercent_text_shadow_color_offset[2])
				
				DF:SetFontFace (spellPercentString, plateConfigs.spellpercent_text_font)
				Plater.SetAnchor (spellPercentString, plateConfigs.spellpercent_text_anchor)
			end
		else
			plateFrame.unitFrame.castBar.Settings.ShowCastTime = false
			spellPercentString:Hide()
		end
		
	
		-- updates for special frames
		if (plateFrame.isSelf) then
		
			--return
			--needReset = true
			
		elseif (plateFrame.IsFriendlyPlayerWithoutHealthBar) then --not critical code
			--when the option to show only the player name is enabled
			--special string to show the player name
			local nameFontString = plateFrame.ActorNameSpecial
			nameFontString:Show()
			
			--set the name in the string
			plateFrame.CurrentUnitNameString = nameFontString
			Plater.UpdateUnitName (plateFrame)
			
			DF:SetFontSize (nameFontString, plateConfigs.actorname_text_size)
			DF:SetFontFace (nameFontString, plateConfigs.actorname_text_font)
			
			--DF:SetFontOutline (nameFontString, plateConfigs.actorname_text_shadow)
			Plater.SetFontOutlineAndShadow (nameFontString, plateConfigs.actorname_text_outline, plateConfigs.actorname_text_shadow_color, plateConfigs.actorname_text_shadow_color_offset[1], plateConfigs.actorname_text_shadow_color_offset[2])
			
			--check if the player has a guild, this check is done when the nameplate is added
			if (plateFrame.playerGuildName) then
				if (plateConfigs.show_guild_name) then
					Plater.AddGuildNameToPlayerName (plateFrame)
				end
			end
			
			--set the point of the name and guild texts
			nameFontString:ClearAllPoints()
			PixelUtil.SetPoint (plateFrame.ActorNameSpecial, "center", plateFrame, "center", 0, 10)
			
			--format the color if is the same guild, a friend from friends list or color by player class
			if (Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_PLAYER].actorname_use_guild_color and plateFrame.playerGuildName == Plater.PlayerGuildName) then
				--is a guild friend?
				DF:SetFontColor (nameFontString, unpack(Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_PLAYER].actorname_guild_color))
				plateFrame.isFriend = true
				
			elseif (Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_PLAYER].actorname_use_friends_color and Plater.FriendsCache [plateFrame [MEMBER_NAME]]) then
				--is regular friend
				DF:SetFontColor (nameFontString, unpack(Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_PLAYER].actorname_friend_color))
				--DF:SetFontOutline (nameFontString, plateConfigs.actorname_text_shadow)
				Plater.SetFontOutlineAndShadow (nameFontString, plateConfigs.actorname_text_outline, plateConfigs.actorname_text_shadow_color, plateConfigs.actorname_text_shadow_color_offset[1], plateConfigs.actorname_text_shadow_color_offset[2])
				plateFrame.isFriend = true
				
			else
				--isn't friend, check if is showing only the name and if is showing class colors
				if (Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_PLAYER].actorname_use_class_color) then
					local _, unitClass = UnitClass (plateFrame.unitFrame [MEMBER_UNITID])
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
			
			PixelUtil.SetPoint (plateFrame.ActorNameSpecial, "center", plateFrame, "center", 0, 10)
			PixelUtil.SetPoint (plateFrame.ActorTitleSpecial, "top", plateFrame.ActorNameSpecial, "bottom", 0, -2)

			--there's two ways of showing this for friendly npcs (selected from the options panel): show all names or only npcs with profession names
			--enemy npcs always show all
			if (plateConfigs.all_names) then
				plateFrame.ActorNameSpecial:Show()
				plateFrame.CurrentUnitNameString = plateFrame.ActorNameSpecial
				Plater.UpdateUnitName (plateFrame)
				
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
					
					--DF:SetFontOutline (plateFrame.ActorNameSpecial, plateConfigs.big_actorname_text_shadow)
					Plater.SetFontOutlineAndShadow (plateFrame.ActorNameSpecial, plateConfigs.big_actorname_text_outline, plateConfigs.big_actorname_text_shadow_color, plateConfigs.big_actorname_text_shadow_color_offset[1], plateConfigs.big_actorname_text_shadow_color_offset[2])
					
					--npc title
					local subTitle = Plater.GetActorSubName (plateFrame)
					if (subTitle and subTitle ~= "" and not subTitle:match ("%d")) then
						plateFrame.ActorTitleSpecial:Show()
						subTitle = DF:RemoveRealmName (subTitle)
						plateFrame.ActorTitleSpecial:SetText ("<" .. subTitle .. ">")
						plateFrame.ActorTitleSpecial:ClearAllPoints()
						PixelUtil.SetPoint (plateFrame.ActorTitleSpecial, "top", plateFrame.ActorNameSpecial, "bottom", 0, -2)
						
						plateFrame.ActorTitleSpecial:SetTextColor (r, g, b, a)
						DF:SetFontSize (plateFrame.ActorTitleSpecial, plateConfigs.big_actortitle_text_size)
						DF:SetFontFace (plateFrame.ActorTitleSpecial, plateConfigs.big_actortitle_text_font)
						
						--DF:SetFontOutline (plateFrame.ActorTitleSpecial, plateConfigs.big_actortitle_text_shadow)
						Plater.SetFontOutlineAndShadow (plateFrame.ActorTitleSpecial, plateConfigs.big_actortitle_text_outline, plateConfigs.big_actortitle_text_shadow_color, plateConfigs.big_actortitle_text_shadow_color_offset[1], plateConfigs.big_actortitle_text_shadow_color_offset[2])
					else
						plateFrame.ActorTitleSpecial:Hide()
					end
					
				else
					--it's a friendly npc
					plateFrame.ActorNameSpecial:SetTextColor (unpack (plateConfigs.big_actorname_text_color))
					DF:SetFontSize (plateFrame.ActorNameSpecial, plateConfigs.big_actorname_text_size)
					DF:SetFontFace (plateFrame.ActorNameSpecial, plateConfigs.big_actorname_text_font)
					
					--DF:SetFontOutline (plateFrame.ActorNameSpecial, plateConfigs.big_actorname_text_shadow)
					Plater.SetFontOutlineAndShadow (plateFrame.ActorNameSpecial, plateConfigs.big_actorname_text_outline, plateConfigs.big_actorname_text_shadow_color, plateConfigs.big_actorname_text_shadow_color_offset[1], plateConfigs.big_actorname_text_shadow_color_offset[2])
					
					--profession (title)
					local subTitle = Plater.GetActorSubName (plateFrame)
					if (subTitle and subTitle ~= "" and not subTitle:match ("%d")) then
						plateFrame.ActorTitleSpecial:Show()
						subTitle = DF:RemoveRealmName (subTitle)
						plateFrame.ActorTitleSpecial:SetText ("<" .. subTitle .. ">")
						plateFrame.ActorTitleSpecial:ClearAllPoints()
						PixelUtil.SetPoint (plateFrame.ActorTitleSpecial, "top", plateFrame.ActorNameSpecial, "bottom", 0, -2)
						
						plateFrame.ActorTitleSpecial:SetTextColor (unpack (plateConfigs.big_actortitle_text_color))
						DF:SetFontSize (plateFrame.ActorTitleSpecial, plateConfigs.big_actortitle_text_size)
						DF:SetFontFace (plateFrame.ActorTitleSpecial, plateConfigs.big_actortitle_text_font)
						
						--DF:SetFontOutline (plateFrame.ActorTitleSpecial, plateConfigs.big_actortitle_text_shadow)
						Plater.SetFontOutlineAndShadow (plateFrame.ActorTitleSpecial, plateConfigs.big_actortitle_text_outline, plateConfigs.big_actortitle_text_shadow_color, plateConfigs.big_actortitle_text_shadow_color_offset[1], plateConfigs.big_actortitle_text_shadow_color_offset[2])
					end
				end
			else
				--scan tooltip to check if there's an title for this npc
				local subTitle = Plater.GetActorSubName (plateFrame)
				if (subTitle and subTitle ~= "" and not Plater.IsNpcInIgnoreList (plateFrame, true)) then
					if (not subTitle:match ("%d")) then --isn't level

						plateFrame.ActorTitleSpecial:Show()
						subTitle = DF:RemoveRealmName (subTitle)
						plateFrame.ActorTitleSpecial:SetText ("<" .. subTitle .. ">")
						plateFrame.ActorTitleSpecial:ClearAllPoints()
						PixelUtil.SetPoint (plateFrame.ActorTitleSpecial, "top", plateFrame.ActorNameSpecial, "bottom", 0, -2)
						
						plateFrame.ActorTitleSpecial:SetTextColor (unpack (plateConfigs.big_actortitle_text_color))
						plateFrame.ActorNameSpecial:SetTextColor (unpack (plateConfigs.big_actorname_text_color))
						
						DF:SetFontSize (plateFrame.ActorTitleSpecial, plateConfigs.big_actortitle_text_size)
						DF:SetFontFace (plateFrame.ActorTitleSpecial, plateConfigs.big_actortitle_text_font)
						
						--DF:SetFontOutline (plateFrame.ActorTitleSpecial, plateConfigs.big_actortitle_text_shadow)
						Plater.SetFontOutlineAndShadow (plateFrame.ActorTitleSpecial, plateConfigs.big_actortitle_text_outline, plateConfigs.big_actortitle_text_shadow_color, plateConfigs.big_actortitle_text_shadow_color_offset[1], plateConfigs.big_actortitle_text_shadow_color_offset[2])
						
						--npc name
						plateFrame.ActorNameSpecial:Show()

						plateFrame.CurrentUnitNameString = plateFrame.ActorNameSpecial
						Plater.UpdateUnitName (plateFrame)

						DF:SetFontSize (plateFrame.ActorNameSpecial, plateConfigs.big_actorname_text_size)
						DF:SetFontFace (plateFrame.ActorNameSpecial, plateConfigs.big_actorname_text_font)
						
						--DF:SetFontOutline (plateFrame.ActorNameSpecial, plateConfigs.big_actorname_text_shadow)
						Plater.SetFontOutlineAndShadow (plateFrame.ActorNameSpecial, plateConfigs.big_actorname_text_outline, plateConfigs.big_actorname_text_shadow_color, plateConfigs.big_actorname_text_shadow_color_offset[1], plateConfigs.big_actorname_text_shadow_color_offset[2])
					end
				end
			end
			
			return
		end
		
		--get the unitId shown on this nameplate
		local unitId = plateFrame.unitFrame.unit
		
		--critical code
		--the nameplate is showing the health bar
		--cache the strings for performance
		local nameString = plateFrame.unitFrame.healthBar.unitName	
		local guildString = plateFrame.ActorTitleSpecial
		local levelString = plateFrame.unitFrame.healthBar.actorLevel
		local lifeString = plateFrame.unitFrame.healthBar.lifePercent
		
		--update the unit name
		plateFrame.CurrentUnitNameString = nameString
		Plater.UpdateUnitName (plateFrame)
		
		--update unit name text
		if (needReset) then
			DF:SetFontSize (nameString, plateConfigs.actorname_text_size)
			DF:SetFontFace (nameString, plateConfigs.actorname_text_font)
			
			Plater.SetFontOutlineAndShadow (nameString, plateConfigs.actorname_text_outline, plateConfigs.actorname_text_shadow_color, plateConfigs.actorname_text_shadow_color_offset[1], plateConfigs.actorname_text_shadow_color_offset[2])

			Plater.SetAnchor (nameString, plateConfigs.actorname_text_anchor)
			--PixelUtil.SetHeight (nameString, nameString:GetLineHeight())
		end
		
		if (plateFrame.playerGuildName) then
			if (plateConfigs.show_guild_name) then
				Plater.AddGuildNameToPlayerName (plateFrame)
			end
		end
		
		if (Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_PLAYER].actorname_use_guild_color and plateFrame.playerGuildName == Plater.PlayerGuildName) then
			--is a guild friend?
			DF:SetFontColor (nameString, unpack(Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_PLAYER].actorname_guild_color))
			DF:SetFontColor (guildString, unpack(Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_PLAYER].actorname_guild_color))
			plateFrame.isFriend = true
		
		elseif (Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_PLAYER].actorname_use_friends_color and Plater.FriendsCache [plateFrame [MEMBER_NAME]]) then
			--is regular friend
			DF:SetFontColor (nameString, unpack(Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_PLAYER].actorname_friend_color))
			DF:SetFontColor (guildString, unpack(Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_PLAYER].actorname_friend_color))
			plateFrame.isFriend = true		

		elseif (plateFrame.actorType == ACTORTYPE_FRIENDLY_PLAYER and Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_PLAYER].actorname_use_class_color) then
			--class colors should be used, if possible, because this is enabled
			plateFrame.isFriend = nil
			
			local _, unitClass = UnitClass (plateFrame.unitFrame [MEMBER_UNITID])
			if (unitClass) then
				local color = RAID_CLASS_COLORS [unitClass]
				DF:SetFontColor (nameString, color.r, color.g, color.b)
				DF:SetFontColor (guildString, color.r, color.g, color.b)
			else
				DF:SetFontColor (nameString, plateConfigs.actorname_text_color)
				DF:SetFontColor (guildString, plateConfigs.actorname_text_color)
			end
		
		else
			DF:SetFontColor (nameString, plateConfigs.actorname_text_color)
			DF:SetFontColor (guildString, plateConfigs.actorname_text_color)
			plateFrame.isFriend = nil
		end
		
		--update unit level text
		if (plateConfigs.level_text_enabled) then
			levelString:Show()
			if (needReset) then
				DF:SetFontSize (levelString, plateConfigs.level_text_size)
				DF:SetFontFace (levelString, plateConfigs.level_text_font)

				Plater.SetFontOutlineAndShadow (levelString, plateConfigs.level_text_outline, plateConfigs.level_text_shadow_color, plateConfigs.level_text_shadow_color_offset[1], plateConfigs.level_text_shadow_color_offset[2])
				
				Plater.SetAnchor (levelString, plateConfigs.level_text_anchor)
				Plater.UpdateLevelTextAndColor (levelString, unitId)
				levelString:SetAlpha (plateConfigs.level_text_alpha)
			else
				Plater.UpdateLevelTextAndColor (levelString, unitId)
				levelString:SetAlpha (plateConfigs.level_text_alpha)
			end
		else
			levelString:Hide()
		end

		--update health amount text
		if (plateConfigs.percent_text_enabled) then
			if (needReset) then
				DF:SetFontSize (lifeString, plateConfigs.percent_text_size)
				DF:SetFontFace (lifeString, plateConfigs.percent_text_font)

				Plater.SetFontOutlineAndShadow (lifeString, plateConfigs.percent_text_outline, plateConfigs.percent_text_shadow_color, plateConfigs.percent_text_shadow_color_offset[1], plateConfigs.percent_text_shadow_color_offset[2])
				
				DF:SetFontColor (lifeString, plateConfigs.percent_text_color)

				Plater.SetAnchor (lifeString, plateConfigs.percent_text_anchor)
				PixelUtil.SetHeight (lifeString, lifeString:GetLineHeight())
				
				lifeString:SetAlpha (plateConfigs.percent_text_alpha)
			end
			
			Plater.UpdateLifePercentText (plateFrame.unitFrame.healthBar, unitId, plateConfigs.percent_show_health, plateConfigs.percent_show_percent, plateConfigs.percent_text_show_decimals)
		else
			lifeString:Hide()
		end
		
		--name isn't shown in the personal bar
		if (plateFrame.isSelf) then
			plateFrame.unitFrame.healthBar.unitName:SetText ("")
		end
		
		return true
	end
	
	--check if the life percent should be showing for this nameplate
	--self is plateFrame
	function Plater.UpdateLifePercentVisibility (self)
		local plateConfigs = Plater.GetSettings (self)
		
		if (plateConfigs.percent_text_enabled) then
			--can show out of combat? or if the player is in combat
			if (PLAYER_IN_COMBAT or plateConfigs.percent_text_ooc) then
				self.unitFrame.healthBar.lifePercent:Show()
			else
				self.unitFrame.healthBar.lifePercent:Hide()
			end
		else
			self.unitFrame.healthBar.lifePercent:Hide()
		end
	end

	--return the nameplate config directly from the profile
	--this is the actual table from the db, any changes will affect the profile
	--self is plateFrame
	function Plater.GetSettings (self) --private
		return self.PlateConfig
	end
	
	function Plater.UpdateLifePercentText (healthBar, unitId, showHealthAmount, showPercentAmount, showDecimals) -- ~health
		
		--get the cached health amount for performance
		local currentHealth, maxHealth = healthBar.CurrentHealth, healthBar.CurrentHealthMax
		
		if (showHealthAmount and showPercentAmount) then
			local percent = currentHealth / maxHealth * 100
			
			if (showDecimals) then
				if (percent < 10) then
					healthBar.lifePercent:SetText (Plater.FormatNumber (currentHealth) .. " (" .. format ("%.2f", percent) .. "%)")
					
				elseif (percent < 99.9) then
					healthBar.lifePercent:SetText (Plater.FormatNumber (currentHealth) .. " (" .. format ("%.1f", percent) .. "%)")
				else
					healthBar.lifePercent:SetText (Plater.FormatNumber (currentHealth) .. " (100%)")
				end
			else
				healthBar.lifePercent:SetText (Plater.FormatNumber (currentHealth) .. " (" .. floor (percent) .. "%)")
			end
			
		elseif (showHealthAmount) then
			healthBar.lifePercent:SetText (Plater.FormatNumber (currentHealth))
		
		elseif (showPercentAmount) then
			local percent = currentHealth / maxHealth * 100
			
			if (showDecimals) then
				if (percent < 10) then
					healthBar.lifePercent:SetText (format ("%.2f", percent) .. "%")
					
				elseif (percent < 99.9) then
					healthBar.lifePercent:SetText (format ("%.1f", percent) .. "%")
				else
					healthBar.lifePercent:SetText ("100%")
				end
			else
				healthBar.lifePercent:SetText (floor (percent) .. "%")
			end
		
		else
			healthBar.lifePercent:SetText ("")
		end
	end

	-- this test if the percent life text can updated
	function Plater.CheckLifePercentText (unitFrame) --private
		if (not unitFrame.actorType) then
			return
		end
		
		local actorTypeDBConfig = DB_PLATE_CONFIG [unitFrame.actorType]
		if (PLAYER_IN_COMBAT) then
			if (actorTypeDBConfig.percent_text_enabled) then
				Plater.UpdateLifePercentText (unitFrame.healthBar, unitFrame.unit, actorTypeDBConfig.percent_show_health, actorTypeDBConfig.percent_show_percent, actorTypeDBConfig.percent_text_show_decimals)
			end
		else
			--if not in combat, check if can show the percent health out of combat
			if (actorTypeDBConfig.percent_text_enabled and actorTypeDBConfig.percent_text_ooc) then
				Plater.UpdateLifePercentText (unitFrame.healthBar, unitFrame.unit, actorTypeDBConfig.percent_show_health, actorTypeDBConfig.percent_show_percent, actorTypeDBConfig.percent_text_show_decimals)
			end
		end
	end
		
	function Plater.UpdateAllNames() --private
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

	function Plater.AddGuildNameToPlayerName (plateFrame)
		local currentText = plateFrame.CurrentUnitNameString:GetText()
		if (not currentText:find ("<")) then
			plateFrame.CurrentUnitNameString:SetText (currentText .. "\n" .. "<" .. plateFrame.playerGuildName .. ">")
		end
	end
	
	function Plater.UpdateUnitName (plateFrame)
		local nameString = plateFrame.CurrentUnitNameString

		if (plateFrame.NameAnchor >= 9) then
			--remove some character from the unit name if the name is placed inside the nameplate
			local stringSize = max (plateFrame.unitFrame.healthBar:GetWidth() - 6, 44)
			local name = plateFrame [MEMBER_NAME]
			
			nameString:SetText (name)
			Plater.UpdateUnitNameTextSize (plateFrame, nameString)
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

	function Plater.UpdateUnitNameTextSize (plateFrame, nameString)
		local stringSize = max (plateFrame.unitFrame.healthBar:GetWidth() - 6, 44)
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

	--updates the level text and the color
	function Plater.UpdateLevelTextAndColor (levelString, unitId) --private
		--level text
		local level = UnitLevel (unitId)
		if (not level) then
			levelString:SetText ("")
			
		elseif (level == -1) then
			levelString:SetText ("??")
			
		else
			levelString:SetText (level)
		end
		
		--level color
		local color = GetRelativeDifficultyColor (UnitLevel ("player") or 120, UnitLevel (unitId) or 120) or Plater.DefaultLevelColor
		levelString:SetTextColor (color.r, color.g, color.b, Plater.db.profile.level_text_alpha)
	end	

	-- ~updateplate ~update ~updatenameplate
	function Plater.UpdatePlateFrame (plateFrame, actorType, forceUpdate, justAdded)
		actorType = actorType or plateFrame.actorType
		
		if (not actorType) then
			return
		end
		
		local unitFrame = plateFrame.unitFrame
		local healthBar = unitFrame.healthBar
		local castBar = unitFrame.castBar
		local buffFrame = unitFrame.BuffFrame
		local buffFrame2 = unitFrame.BuffFrame2
		local nameFrame = unitFrame.healthBar.unitName
		
		plateFrame.actorType = actorType
		unitFrame.actorType = actorType
		unitFrame.ActorType = actorType --exposed to scripts
		
		local shouldForceRefresh = justAdded or forceUpdate
		if (plateFrame.IsNpcWithoutHealthBar or plateFrame.IsFriendlyPlayerWithoutHealthBar) then
			shouldForceRefresh = true
			plateFrame.IsNpcWithoutHealthBar = false
			plateFrame.IsFriendlyPlayerWithoutHealthBar = false
			
		end

		healthBar.BorderIsAggroIndicator = nil
		
		local wasQuestPlate = plateFrame [MEMBER_QUEST]
		plateFrame [MEMBER_QUEST] = false
		unitFrame [MEMBER_QUEST] = false
		
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
			if (isQuestMob and not Plater.IsUnitTapDenied (plateFrame.unitFrame.unit)) then
				if (plateFrame [MEMBER_REACTION] == UNITREACTION_NEUTRAL) then
					Plater.ChangeHealthBarColor_Internal (healthBar, unpack (DB_PLATE_CONFIG [actorType].quest_color_neutral))
					plateFrame [MEMBER_QUEST] = true
					unitFrame [MEMBER_QUEST] = true
					
				else
					Plater.ChangeHealthBarColor_Internal (healthBar, unpack (DB_PLATE_CONFIG [actorType].quest_color_enemy))
					plateFrame [MEMBER_QUEST] = true
					unitFrame [MEMBER_QUEST] = true
				end
			else
				if (wasQuestPlate) then
					Plater.FindAndSetNameplateColor (unitFrame)
				end
			end
		else
			if (wasQuestPlate) then
				Plater.FindAndSetNameplateColor (unitFrame)
			end
		end
		
		--if the nameplate is for a friendly npc
		if (actorType == ACTORTYPE_FRIENDLY_NPC) then
			local subTitleExists = false
			local subTitle = Plater.GetActorSubName (plateFrame)
			if (subTitle and subTitle ~= "" and not Plater.IsNpcInIgnoreList (plateFrame, true)) then
				if (not subTitle:match ("%d")) then --isn't level
					subTitleExists = true
				end
			end
		
			Plater.ForceFindPetOwner (plateFrame [MEMBER_GUID])
		
			-- handle own pets separately, including nazjatar guardians
			if (Plater.PlayerPetCache [unitFrame [MEMBER_GUID]]) then
				if (DB_PLATE_CONFIG [actorType].only_names) then
					healthBar:Hide()
					buffFrame:Hide()
					buffFrame2:Hide()
					nameFrame:Hide()
					plateFrame.IsNpcWithoutHealthBar = true
				
				else
					healthBar:Show()
					buffFrame:Show()
					buffFrame2:Show()
					nameFrame:Show()
				end
			
			elseif (IS_IN_OPEN_WORLD and DB_PLATE_CONFIG [actorType].quest_enabled and Plater.IsQuestObjective (plateFrame)) then
				Plater.ChangeHealthBarColor_Internal (healthBar, unpack (DB_PLATE_CONFIG [actorType].quest_color))

				healthBar:Show()
				buffFrame:Show()
				buffFrame2:Show()
				nameFrame:Show()
				
				--these twoseettings make the healthing dummy show the healthbar
--				Plater.db.profile.plate_config.friendlynpc.only_names = false
--				Plater.db.profile.plate_config.friendlynpc.all_names = false
				plateFrame [MEMBER_QUEST] = true
				unitFrame [MEMBER_QUEST] = true
			
			elseif (DB_PLATE_CONFIG [actorType].only_names) then
				--show only the npc name without the health bar

				healthBar:Hide()
				buffFrame:Hide()
				buffFrame2:Hide()
				nameFrame:Hide()
				plateFrame.IsNpcWithoutHealthBar = true
				
			elseif (not subTitleExists and not DB_PLATE_CONFIG [actorType].all_names) then
				-- show only if a title is present
				healthBar:Hide()
				buffFrame:Hide()
				buffFrame:Hide()
				nameFrame:Hide()
				plateFrame.IsNpcWithoutHealthBar = true
			
			else
				healthBar:Show()
				buffFrame:Show()
				buffFrame2:Show()
				nameFrame:Show()
			end

		elseif (actorType == ACTORTYPE_FRIENDLY_PLAYER) then
			Plater.ParseHealthSettingForPlayer (plateFrame)
			
				--change the player health bar color to either class color or users choice
			if (not Plater.db.profile.use_playerclass_color) then
				Plater.ChangeHealthBarColor_Internal (healthBar, unpack(DB_PLATE_CONFIG [actorType].fixed_class_color))
			else
				local _, class = UnitClass (unitFrame [MEMBER_UNITID])
				if (class) then		
					local color = RAID_CLASS_COLORS [class]
					Plater.ChangeHealthBarColor_Internal (healthBar, color.r, color.g, color.b)
				else
					Plater.ChangeHealthBarColor_Internal (healthBar, 1, 1, 1)
				end
			end
			
		else
			--> enemy npc or enemy player pass throught here
			--check if this is an enemy npc but the player cannot attack it
			if (plateFrame.PlayerCannotAttack) then
				healthBar:Hide()
				buffFrame:Hide()
				buffFrame2:Hide()
				nameFrame:Hide()
				plateFrame.IsNpcWithoutHealthBar = true
				
			else
				healthBar:Show()
				buffFrame:Show()
				buffFrame2:Show()
				nameFrame:Show()
				
				--> check for enemy player class color
				if (actorType == ACTORTYPE_ENEMY_PLAYER) then
					if (DB_PLATE_CONFIG [actorType].use_playerclass_color) then
						local _, class = UnitClass (unitFrame [MEMBER_UNITID])
						if (class) then		
							local color = RAID_CLASS_COLORS [class]
							Plater.ChangeHealthBarColor_Internal (healthBar, color.r, color.g, color.b)
						else
							Plater.ChangeHealthBarColor_Internal (healthBar, unpack (DB_PLATE_CONFIG [actorType].fixed_class_color))
						end
					else
						Plater.ChangeHealthBarColor_Internal (healthBar, unpack (DB_PLATE_CONFIG [actorType].fixed_class_color))
					end
				end
			end

		end
		
		castBar:SetStatusBarTexture (DB_TEXTURE_CASTBAR)
		
		--update all texts in the nameplate
		Plater.UpdatePlateText (plateFrame, DB_PLATE_CONFIG [actorType], shouldForceRefresh or plateFrame.PreviousUnitType ~= actorType or unitFrame.RefreshID < PLATER_REFRESH_ID)

		if (unitFrame.RefreshID < PLATER_REFRESH_ID or shouldForceRefresh) then
			unitFrame.RefreshID = PLATER_REFRESH_ID

			local profile = Plater.db.profile
			
			--update highlight texture
			unitFrame.HighlightFrame.HighlightTexture:SetTexture (DB_TEXTURE_HEALTHBAR)
			unitFrame.HighlightFrame.HighlightTexture:SetBlendMode ("ADD")
			unitFrame.HighlightFrame.HighlightTexture:SetAlpha (profile.hover_highlight_alpha)
			
			--click area is shown?
			if (profile.click_space_always_show) then
				Plater.SetPlateBackground (plateFrame)
			else
				plateFrame:SetBackdrop (nil)
			end
			
			--setup cast bar
			castBar.background:SetTexture (DB_TEXTURE_CASTBAR_BG)
			castBar.extraBackground:SetTexture (DB_TEXTURE_CASTBAR_BG)
			castBar.background:SetVertexColor (unpack (profile.cast_statusbar_bgcolor))
			castBar.extraBackground:SetVertexColor (unpack (profile.cast_statusbar_bgcolor))
			castBar.flashTexture:SetTexture (DB_TEXTURE_CASTBAR)
			castBar.Icon:SetTexCoord (0.078125, 0.921875, 0.078125, 0.921875)
			
			local colors = castBar.Settings.Colors
			colors.Casting:SetColor (profile.cast_statusbar_color)
			colors.Channeling:SetColor (profile.cast_statusbar_color) --for channeling color, use the same color as the regular cast
			colors.NonInterruptible:SetColor (profile.cast_statusbar_color_nointerrupt)
			colors.Interrupted:SetColor (profile.cast_statusbar_color_interrupted)
			colors.Finished:SetColor (profile.cast_statusbar_color_finished)
			
			castBar.Settings.FadeInTime = profile.cast_statusbar_fadein_time
			castBar.Settings.FadeOutTime = profile.cast_statusbar_fadeout_time
			castBar.fadeOutAnimation.alpha1:SetDuration (castBar.Settings.FadeOutTime)
			castBar.fadeInAnimation.alpha1:SetDuration (castBar.Settings.FadeInTime)
			castBar.Settings.NoFadeEffects = not profile.cast_statusbar_use_fade_effects
			castBar.Settings.SparkTexture = profile.cast_statusbar_spark_texture
			castBar.Spark:SetTexture (castBar.Settings.SparkTexture)
			castBar.Spark:SetVertexColor (unpack (profile.cast_statusbar_spark_color))
			castBar.Spark:SetAlpha (profile.cast_statusbar_spark_alpha)
			
			if (profile.cast_statusbar_spark_half) then
				castBar.Spark:SetTexCoord (0, 0.5, 0, 1)
			else
				castBar.Spark:SetTexCoord (0, 1, 0, 1)
			end
			
			castBar.Settings.SparkOffset = profile.cast_statusbar_spark_offset
			
			--setup power bar
			unitFrame.powerBar:SetTexture (DB_TEXTURE_HEALTHBAR)
			
			--setup health bar~
			healthBar:SetTexture (DB_TEXTURE_HEALTHBAR)
			healthBar.background:SetTexture (DB_TEXTURE_HEALTHBAR_BG)
			healthBar.background:SetVertexColor (unpack (profile.health_statusbar_bgcolor))
			
			--update border
			Plater.UpdatePlateBorders (plateFrame)
			
			--target overlay texture
			local targetedOverlayTexture = LibSharedMedia:Fetch ("statusbar", profile.health_selection_overlay)
			unitFrame.targetOverlayTexture:SetTexture (targetedOverlayTexture)
			unitFrame.targetOverlayTexture:SetAlpha (profile.health_selection_overlay_alpha)
			
			--heal prediction
			unitFrame.healthBar.Settings.ShowHealingPrediction = Plater.db.profile.show_health_prediction
			unitFrame.healthBar.Settings.ShowShields = Plater.db.profile.show_shield_prediction
			if (unitFrame.healthBar.unit) then
				unitFrame.healthBar:UNIT_HEALTH()
			end
		end
		
		--update the plate size for this unit
		Plater.UpdatePlateSize (plateFrame)
		
		--raid marker
		Plater.UpdatePlateRaidMarker (plateFrame)
		
		--indicators for the unit
		Plater.UpdateIndicators (plateFrame, actorType)
		
		--update the visibility of the health text
		Plater.UpdateLifePercentVisibility (plateFrame)
		--update the health text
		Plater.CheckLifePercentText (unitFrame)
		
		--target indicator
		Plater.UpdateTarget (plateFrame)
		
		--personal player bar
		if (plateFrame.isSelf) then
			Plater.UpdatePersonalBar (NamePlateDriverFrame)
			if (not DB_PLATE_CONFIG [actorType].healthbar_color_by_hp) then
				Plater.ChangeHealthBarColor_Internal (healthBar, unpack (DB_PLATE_CONFIG [actorType].healthbar_color))
			end
		end
		
		Plater.UpdateCustomDesign (unitFrame)

		--update options in the extra icons row frame
		if (unitFrame.ExtraIconFrame.RefreshID < PLATER_REFRESH_ID) then
			Plater.SetAnchor (unitFrame.ExtraIconFrame, Plater.db.profile.extra_icon_anchor)
			unitFrame.ExtraIconFrame:SetOption ("show_text", Plater.db.profile.extra_icon_show_timer)
			unitFrame.ExtraIconFrame:SetOption ("grow_direction", unitFrame.ExtraIconFrame:GetIconGrowDirection())
			unitFrame.ExtraIconFrame:SetOption ("icon_width", Plater.db.profile.extra_icon_width)
			unitFrame.ExtraIconFrame:SetOption ("icon_height", Plater.db.profile.extra_icon_height)
			unitFrame.ExtraIconFrame:SetOption ("texcoord", Plater.db.profile.extra_icon_wide_icon and Plater.WideIconCoords or Plater.BorderLessIconCoords)
			unitFrame.ExtraIconFrame:SetOption ("desc_text", Plater.db.profile.extra_icon_caster_name)
			unitFrame.ExtraIconFrame:SetOption ("stack_text", Plater.db.profile.extra_icon_show_stacks)
			
			--> update refresh ID
			unitFrame.ExtraIconFrame.RefreshID = PLATER_REFRESH_ID
		end
		
		--update options in the boss mods icons frame
		Plater.UpdateBossModAuraFrameSettings(unitFrame, PLATER_REFRESH_ID)
		
		--> details! integration
		if (IS_USING_DETAILS_INTEGRATION) then
			local detailsPlaterConfig = Details.plater

			if (detailsPlaterConfig.realtime_dps_enabled) then
				local textString = healthBar.DetailsRealTime
				Plater.SetAnchor (textString, detailsPlaterConfig.realtime_dps_anchor)
				DF:SetFontSize (textString, detailsPlaterConfig.realtime_dps_size)
				DF:SetFontOutline (textString, detailsPlaterConfig.realtime_dps_shadow)
				DF:SetFontColor (textString, detailsPlaterConfig.realtime_dps_color)
			end
			
			if (detailsPlaterConfig.realtime_dps_player_enabled) then
				local textString = healthBar.DetailsRealTimeFromPlayer
				Plater.SetAnchor (textString, detailsPlaterConfig.realtime_dps_player_anchor)
				DF:SetFontSize (textString, detailsPlaterConfig.realtime_dps_player_size)
				DF:SetFontOutline (textString, detailsPlaterConfig.realtime_dps_player_shadow)
				DF:SetFontColor (textString, detailsPlaterConfig.realtime_dps_player_color)
			end
			
			if (detailsPlaterConfig.damage_taken_enabled) then
				local textString = healthBar.DetailsDamageTaken
				Plater.SetAnchor (textString, detailsPlaterConfig.damage_taken_anchor)
				DF:SetFontSize (textString, detailsPlaterConfig.damage_taken_size)
				DF:SetFontOutline (textString, detailsPlaterConfig.damage_taken_shadow)
				DF:SetFontColor (textString, detailsPlaterConfig.damage_taken_color)
			end
			
			--reset all labels used by details!
			healthBar.DetailsRealTime:SetText ("")
			healthBar.DetailsRealTimeFromPlayer:SetText ("")
			healthBar.DetailsDamageTaken:SetText ("")
		end
		
		if (plateFrame.OnTickFrame.actorType == actorType and plateFrame.OnTickFrame.unit == unitFrame [MEMBER_UNITID]) then
			Plater.NameplateTick (plateFrame.OnTickFrame, 10)
		end
	end

	-- ~border
	--changes the border color, this call is used internally on Plater
	--see Plater.SetBorderColor for scripting calls
	--currently this is called for threat color changes (if enabled at the options panel)
	function Plater.ForceChangeBorderColor (self, r, g, b) --private --self = unitFrame
		--this call is from the retail game, file: blizzard_nameplates.lua
		if (not self.customBorderColor) then
			self.healthBar.border:SetVertexColor (r, g, b)
			self.BorderIsAggroIndicator = true
		end
	end
	
	--> update the border color respecting custom colors set by scripts
	function Plater.UpdateBorderColor (self) --self is unitFrame
		--set the border color
		if (not self.customBorderColor) then
			self.healthBar.border:SetVertexColor (DB_BORDER_COLOR_R, DB_BORDER_COLOR_G, DB_BORDER_COLOR_B, DB_BORDER_COLOR_A)
			self.powerBar.border:SetVertexColor (DB_BORDER_COLOR_R, DB_BORDER_COLOR_G, DB_BORDER_COLOR_B, DB_BORDER_COLOR_A)
		else
			self.healthBar.border:SetVertexColor (unpack (self.customBorderColor))
			self.powerBar.border:SetVertexColor (unpack (self.customBorderColor))
		end
	end

	function Plater.UpdatePlateBorders (plateFrame) --private
		--if didn't pass a plate to update, update all frames
		if (not plateFrame) then
			for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
				Plater.UpdatePlateBorders (plateFrame)
			end
			return
		end
		
		Plater.UpdatePlateBorderThickness (plateFrame)
		
		--ignore if the border is being used internally as threat indicator
		if (plateFrame.unitFrame.healthBar.BorderIsAggroIndicator) then
			return
		end
		
		Plater.UpdateBorderColor (plateFrame.unitFrame)
	end

	function Plater.UpdatePlateBorderThickness (plateFrame)
		if (not plateFrame) then
			for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
				Plater.UpdatePlateBorderThickness (plateFrame)
			end
			return
		end
		
		plateFrame.unitFrame.healthBar.border:SetBorderSizes (DB_BORDER_THICKNESS, DB_BORDER_THICKNESS, DB_BORDER_THICKNESS, DB_BORDER_THICKNESS)
		plateFrame.unitFrame.healthBar.border:UpdateSizes()
		
		plateFrame.unitFrame.powerBar.border:SetBorderSizes (DB_BORDER_THICKNESS, DB_BORDER_THICKNESS, DB_BORDER_THICKNESS, DB_BORDER_THICKNESS)
		plateFrame.unitFrame.powerBar.border:UpdateSizes()
	end

	-- ~raidmarker ~raidtarget
	function Plater.UpdatePlateRaidMarker (plateFrame)
		local index = GetRaidTargetIndex (plateFrame.unitFrame [MEMBER_UNITID])

		if (index and not plateFrame.isSelf) then
			local icon = plateFrame.unitFrame.PlaterRaidTargetFrame.RaidTargetIcon
			SetRaidTargetIconTexture (icon, index)
			icon:Show()
			
			if (not icon.IsShowning) then
				--play animations
				icon.IsShowning = true
				icon.ShowAnimation:Play()
			end
			
			--adjust scale and anchor
			plateFrame.unitFrame.PlaterRaidTargetFrame:SetScale (Plater.db.profile.indicator_raidmark_scale)
			Plater.SetAnchor (plateFrame.unitFrame.PlaterRaidTargetFrame, Plater.db.profile.indicator_raidmark_anchor)
			
			--adjust frame level:
			plateFrame.unitFrame.PlaterRaidTargetFrame:SetFrameStrata(plateFrame.unitFrame.healthBar:GetFrameStrata())
			plateFrame.unitFrame.PlaterRaidTargetFrame:SetFrameLevel(plateFrame.unitFrame.healthBar:GetFrameLevel() + 25)
			
			--mini mark inside the nameplate
			if (Plater.db.profile.indicator_extra_raidmark) then
				plateFrame.RaidTarget:Show()
				plateFrame.RaidTarget:SetTexture (icon:GetTexture())
				plateFrame.RaidTarget:SetTexCoord (icon:GetTexCoord())
				
				local height = plateFrame.unitFrame.healthBar:GetHeight() - 2
				plateFrame.RaidTarget:SetSize (height, height)
				plateFrame.RaidTarget:SetAlpha (.4)
			end
		else
			plateFrame.unitFrame.PlaterRaidTargetFrame.RaidTargetIcon.IsShowning = nil
			plateFrame.unitFrame.PlaterRaidTargetFrame.RaidTargetIcon:Hide()
			--hide the extra raid target inside the nameplate
			plateFrame.RaidTarget:Hide()
		end
	end

	--iterate among all nameplates and update the raid target icon
	function Plater.UpdateRaidMarkersOnAllNameplates() --private
		for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
			Plater.UpdatePlateRaidMarker (plateFrame)
			
			--hooks
			if (HOOK_RAID_TARGET.ScriptAmount > 0) then
				for i = 1, HOOK_RAID_TARGET.ScriptAmount do
					local globalScriptObject = HOOK_RAID_TARGET [i]
					local unitFrame = plateFrame.unitFrame
					local scriptContainer = unitFrame:ScriptGetContainer()
					local scriptInfo = unitFrame:ScriptGetInfo (globalScriptObject, scriptContainer, "Raid Target")
					--run
					unitFrame:ScriptRunHook (scriptInfo, "Raid Target")
				end
			end
		end
	end

	-- ~indicators
	function Plater.UpdateIndicators (plateFrame, actorType)
		--limpa os indicadores
		Plater.ClearIndicators (plateFrame)
		local config = Plater.db.profile
		
		if (actorType == ACTORTYPE_ENEMY_PLAYER) then
			if (config.indicator_faction) then
				Plater.AddIndicator (plateFrame, UnitFactionGroup (plateFrame.unitFrame [MEMBER_UNITID]))
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
				if (config.indicator_pet) then
					Plater.AddIndicator (plateFrame, "pet")
				end
			end

			--classification
			local unitClassification = UnitClassification (plateFrame.unitFrame [MEMBER_UNITID]) --elite minus normal rare rareelite worldboss
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
			local isQuestBoss = UnitIsQuestBoss (plateFrame.unitFrame [MEMBER_UNITID]) --true false
			if (isQuestBoss and config.indicator_quest) then
				Plater.AddIndicator (plateFrame, "quest")
			end
		
		elseif (actorType == ACTORTYPE_FRIENDLY_NPC) then
			if (plateFrame [MEMBER_QUEST]) then
				Plater.AddIndicator (plateFrame, "quest")
			end
		end
		
		--custom indicators from scripts
		for i = 1, #plateFrame.unitFrame.CustomIndicators do
			Plater.AddIndicator (plateFrame, "custom", unpack (plateFrame.unitFrame.CustomIndicators [i]))
		end
	end

	function Plater.AddIndicator (plateFrame, indicator, ...)

		local thisIndicator = plateFrame.IconIndicators [plateFrame.IconIndicators.Next]
		
		if (not thisIndicator) then
			local newIndicator = plateFrame.unitFrame.healthBar:CreateTexture (nil, "overlay")
			newIndicator:SetSize (10, 10)
			tinsert (plateFrame.IconIndicators, newIndicator)
			thisIndicator = newIndicator
		end

		thisIndicator:Show()
		thisIndicator:SetTexCoord (0, 1, 0, 1)
		thisIndicator:SetVertexColor (1, 1, 1)
		thisIndicator:SetDesaturated (false)
		thisIndicator:SetSize (10, 10)
		thisIndicator:SetScale (Plater.db.profile.indicator_scale)
		
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
			local _, class = UnitClass (plateFrame.unitFrame [MEMBER_UNITID])
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
		
		elseif (indicator == "custom") then
			local texture, width, height, color, L, R, T, B = ...
			thisIndicator:SetTexture (texture)
			thisIndicator:SetSize (width, height)
			thisIndicator:SetTexCoord (L, R, T, B)
			local r, g, b = DF:ParseColors (color)
			thisIndicator:SetVertexColor (r, g, b)
		end
		
		if (plateFrame.IconIndicators.Next == 1) then
			Plater.SetAnchor (thisIndicator, Plater.db.profile.indicator_anchor)
		else
			local attachTo = plateFrame.IconIndicators [plateFrame.IconIndicators.Next - 1]
			--se for menor que 4 ele deve crescer para o lado da esquerda, nos outros casos vai para a direita
			if (Plater.db.profile.indicator_anchor.side < 4) then
				PixelUtil.SetPoint (thisIndicator, "right", attachTo, "left", -2, 0)
			else
				PixelUtil.SetPoint (thisIndicator, "left", attachTo, "right", 1, 0)
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
	


--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> misc stuff - general functions ~misc

	--auto toggle the show friendly players, and other stuff.
	function Plater.RefreshAutoToggle() --private

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
				SetCVar ("nameplateMotion", Plater.db.profile.auto_toggle_stacking ["party"] and CVAR_ENABLED or CVAR_DISABLED)
				
			elseif (zoneType == "raid") then
				SetCVar ("nameplateMotion", Plater.db.profile.auto_toggle_stacking ["raid"] and CVAR_ENABLED or CVAR_DISABLED)
				
			elseif (zoneType == "arena") then
				SetCVar ("nameplateMotion", Plater.db.profile.auto_toggle_stacking ["arena"] and CVAR_ENABLED or CVAR_DISABLED)
				
			else
				--if the player is resting, consider inside a major city
				if (IsResting()) then
					SetCVar ("nameplateMotion", Plater.db.profile.auto_toggle_stacking ["cities"] and CVAR_ENABLED or CVAR_DISABLED)
				else
					SetCVar ("nameplateMotion", Plater.db.profile.auto_toggle_stacking ["world"] and CVAR_ENABLED or CVAR_DISABLED)
				end
			end
		end
	end

	local anchor_functions = {
		function (widget, config, attachTo)--1
			widget:ClearAllPoints()
			PixelUtil.SetPoint (widget, "bottomleft", attachTo, "topleft", config.x, config.y, 0, 0)
		end,
		function (widget, config, attachTo)--2
			widget:ClearAllPoints()
			PixelUtil.SetPoint (widget, "right", attachTo, "left", config.x, config.y, 0, 0)
		end,
		function (widget, config, attachTo)--3
			widget:ClearAllPoints()
			PixelUtil.SetPoint (widget, "topleft", attachTo, "bottomleft", config.x, config.y, 0, 0)
		end,
		function (widget, config, attachTo)--4
			widget:ClearAllPoints()
			PixelUtil.SetPoint (widget, "top", attachTo, "bottom", config.x, config.y, 0, 0)
		end,
		function (widget, config, attachTo)--5
			widget:ClearAllPoints()
			PixelUtil.SetPoint (widget, "topright", attachTo, "bottomright", config.x, config.y, 0, 0)
		end,
		function (widget, config, attachTo)--6
			widget:ClearAllPoints()
			PixelUtil.SetPoint (widget, "left", attachTo, "right", config.x, config.y, 0, 0)
		end,
		function (widget, config, attachTo)--7
			widget:ClearAllPoints()
			PixelUtil.SetPoint (widget, "bottomright", attachTo, "topright", config.x, config.y, 0, 0)
		end,
		function (widget, config, attachTo)--8
			widget:ClearAllPoints()
			PixelUtil.SetPoint (widget, "bottom", attachTo, "top", config.x, config.y, 0, 0)
		end,
		function (widget, config, attachTo)--9
			widget:ClearAllPoints()
			PixelUtil.SetPoint (widget, "center", attachTo, "center", config.x, config.y, 0, 0)
		end,
		function (widget, config, attachTo)--10
			widget:ClearAllPoints()
			PixelUtil.SetPoint (widget, "left", attachTo, "left", config.x, config.y, 0, 0)
		end,
		function (widget, config, attachTo)--11
			widget:ClearAllPoints()
			PixelUtil.SetPoint (widget, "right", attachTo, "right", config.x, config.y, 0, 0)
		end,
		function (widget, config, attachTo)--12
			widget:ClearAllPoints()
			PixelUtil.SetPoint (widget, "top", attachTo, "top", config.x, config.y, 0, 0)
		end,
		function (widget, config, attachTo)--13
			widget:ClearAllPoints()
			PixelUtil.SetPoint (widget, "bottom", attachTo, "bottom", config.x, config.y, 0, 0)
		end
	}

	--auto set the point based on the table from the config, if attachTo isn't received, it'll use its parent
	function Plater.SetAnchor (widget, config, attachTo) --private
		attachTo = attachTo or widget:GetParent()
		anchor_functions [config.side] (widget, config, attachTo)
	end

	--check the setting 'only_damaged' and 'only_thename' for player characters. not critical code, can run slow
	function Plater.ParseHealthSettingForPlayer (plateFrame) --private
		plateFrame.IsFriendlyPlayerWithoutHealthBar = false

		if (DB_PLATE_CONFIG [ACTORTYPE_FRIENDLY_PLAYER].only_thename and not DB_PLATE_CONFIG [ACTORTYPE_FRIENDLY_PLAYER].only_damaged) then
			Plater.HideHealthBar (plateFrame.unitFrame, true)
			plateFrame.IsFriendlyPlayerWithoutHealthBar = true
			
		elseif (DB_PLATE_CONFIG [ACTORTYPE_FRIENDLY_PLAYER].only_damaged) then
			if (UnitHealth (plateFrame.unitFrame [MEMBER_UNITID]) < UnitHealthMax (plateFrame.unitFrame [MEMBER_UNITID])) then
				Plater.ShowHealthBar (plateFrame.unitFrame)
			else
				Plater.HideHealthBar (plateFrame.unitFrame, true)
				
				if (DB_PLATE_CONFIG [ACTORTYPE_FRIENDLY_PLAYER].only_thename) then
					plateFrame.IsFriendlyPlayerWithoutHealthBar = true
				end
			end
			
		else
			Plater.ShowHealthBar (plateFrame.unitFrame)
		end
	end

	function Plater.GetPlateAlpha (plateFrame)
		if (UnitIsUnit (plateFrame.unitFrame [MEMBER_UNITID], "target")) then
			return 1
		else
			return AlphaBlending
		end
	end

	local widget_set_alpha = function (widget, value)
		if (widget.FadeAnimation:IsPlaying()) then
			widget.FadeAnimation:Stop()
		end
		widget.FadeAnimation.Animation:SetFromAlpha (widget:GetAlpha())
		widget.FadeAnimation.Animation:SetToAlpha (value)
		widget.FadeAnimation:Play()
	end	

	local on_finished_fade_animation = function (fadeAnimation)
		local widget = fadeAnimation:GetParent()
		widget:SetAlpha(fadeAnimation.Animation:GetToAlpha())
	end

	Plater.CreateAlphaAnimation = function (plateFrame)
		local unitFrame = plateFrame.unitFrame
		local healthBar = plateFrame.unitFrame.healthBar
		local castBar = plateFrame.unitFrame.castBar
		local powerBar = plateFrame.unitFrame.powerBar
		local buffFrame = plateFrame.unitFrame.BuffFrame
		local buffFrame2 = plateFrame.unitFrame.BuffFrame2

		local allWidgets = {
			unitFrame, healthBar, castBar, buffFrame, buffFrame2, powerBar
		}

		for i = 1, #allWidgets do
			local widget = allWidgets[i]
			widget.FadeAnimation = widget:CreateAnimationGroup()
			--widget.FadeAnimation:SetScript ("OnPlay", on_play_fade_animation)
			widget.FadeAnimation:SetScript ("OnFinished", on_finished_fade_animation)
			widget.FadeAnimation.Animation = widget.FadeAnimation:CreateAnimation ("Alpha")
			widget.FadeAnimation.Animation:SetOrder (1)
			widget.FadeAnimation.Animation:SetDuration (0.15)
			widget.SetAlphaTo = widget_set_alpha
		end
	end

	function Plater.CheckHighlight (self)
		if (UnitIsUnit ("mouseover", self.unit)) then
			self.HighlightTexture:Show()
		else
			self.HighlightTexture:Hide()
		end
	end
	
	--create a new frame for the highlight (when the mouse passes over the nameplate)
	function Plater.CreateHighlightNameplate (plateFrame) --private
		local highlightOverlay = CreateFrame ("frame", "$parentHighlightOverlay", plateFrame.unitFrame.healthBar) --why this was parented to UIParent (question mark)
		highlightOverlay:EnableMouse (false)
		highlightOverlay:SetAllPoints()
		highlightOverlay:SetScript ("OnUpdate", Plater.CheckHighlight)
		highlightOverlay:Hide()
		--highlightOverlay:SetFrameStrata ("TOOLTIP") --it'll use the same strata as the health bar now
		
		highlightOverlay.HighlightTexture = plateFrame.unitFrame.healthBar:CreateTexture (nil, "artwork")
		highlightOverlay.HighlightTexture:SetAllPoints()
		highlightOverlay.HighlightTexture:SetColorTexture (1, 1, 1, 1)
		highlightOverlay.HighlightTexture:SetAlpha (1)
		highlightOverlay:Hide()
		
		plateFrame.unitFrame.HighlightFrame = highlightOverlay
	end
	
	function Plater.EnableHighlight (unitFrame)
		unitFrame.HighlightFrame:Show()
		unitFrame.HighlightFrame.HighlightTexture:Show()

		unitFrame.HighlightFrame.unit = unitFrame [MEMBER_UNITID]
		unitFrame.HighlightFrame:SetScript ("OnUpdate", Plater.CheckHighlight)
	end
	
	function Plater.DisableHighlight (unitFrame)
		unitFrame.HighlightFrame:SetScript ("OnUpdate", nil)
		unitFrame.HighlightFrame:Hide()
		unitFrame.HighlightFrame.HighlightTexture:Hide()
	end
	
	function Plater.CreateHealthFlashFrame (plateFrame) --private
		local f_anim = CreateFrame ("frame", nil, plateFrame.unitFrame.healthBar)
		f_anim:SetFrameLevel (plateFrame.unitFrame.healthBar:GetFrameLevel()-1)
		f_anim:SetPoint ("topleft", plateFrame.unitFrame.healthBar, "topleft", -2, 2)
		f_anim:SetPoint ("bottomright", plateFrame.unitFrame.healthBar, "bottomright", 2, -2)
		plateFrame.unitFrame.healthBar.canHealthFlash = true
		
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
			if (not plateFrame.unitFrame.healthBar.canHealthFlash) then
				return
			end
			plateFrame.unitFrame.healthBar.canHealthFlash = false
			
			duration = duration or 0.1
			
			anim1:SetDuration (duration)
			anim2:SetDuration (duration)
			anim3:SetDuration (duration)
			
			f_anim:Show()
			animation:Play()
		end
		
		f_anim:Hide()
		plateFrame.unitFrame.healthBar.PlayHealthFlash = do_flash_anim
	end

	function Plater.CreateAggroFlashFrame (plateFrame) --private

		--local f_anim = CreateFrame ("frame", nil, plateFrame.unitFrame.healthBar)
		local f_anim = CreateFrame ("frame", nil, plateFrame)
		f_anim:SetFrameLevel (plateFrame.unitFrame.healthBar:GetFrameLevel()+3)
		f_anim:SetPoint ("topleft", plateFrame.unitFrame.healthBar, "topleft")
		f_anim:SetPoint ("bottomright", plateFrame.unitFrame.healthBar, "bottomright")
		
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

		local do_flash_anim = function (text, duration, ignoreCooldown)
			if (not ignoreCooldown and Plater.CombatTime+5 > GetTime()) then
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
	

	--> animation with acceleration ~animation ~healthbaranimation
	function Plater.AnimateLeftWithAccel (self, deltaTime)
		local distance = (self.AnimationStart - self.AnimationEnd) / self.CurrentHealthMax * 100	--scale 1 - 100
		local minTravel = min (distance / 10, 3) -- 10 = trigger distance to max speed 3 = speed scale on max travel
		local maxTravel = max (minTravel, 0.45) -- 0.45 = min scale speed on low travel speed
		local calcAnimationSpeed = (self.CurrentHealthMax * (deltaTime * DB_ANIMATION_TIME_DILATATION)) * maxTravel --re-scale back to unit health, scale with delta time and scale with the travel speed
		
		self.AnimationStart = self.AnimationStart - (calcAnimationSpeed)
		self:SetValue (self.AnimationStart)
		self.CurrentHealth = self.AnimationStart
		
		if (self.Spark) then
			self.Spark:SetPoint ("center", self, "left", self.AnimationStart / self.CurrentHealthMax * self:GetWidth(), 0)
			self.Spark:Show()
		end
		
		if (self.AnimationStart-1 <= self.AnimationEnd) then
			self:SetValue (self.AnimationEnd)
			self.CurrentHealth = self.AnimationEnd
			self.IsAnimating = false
			if (self.Spark) then
				self.Spark:Hide()
			end
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

	function Plater.CreateScaleAnimation (plateFrame) --private
		--animation table
		plateFrame.SpellAnimations = {}
		
		--scale animation
		local duration = 0.05
		local animationHub = DF:CreateAnimationHub (plateFrame.unitFrame)
		animationHub.ScaleUp = DF:CreateAnimation (animationHub, "scale", 1, duration,	1, 	1, 	1.2, 	1.2)
		animationHub.ScaleDown = DF:CreateAnimation (animationHub, "scale", 2, duration,	1, 	1, 	0.8, 	0.8)
		
		plateFrame.SpellAnimations ["scale"] = animationHub
	end

	function Plater.DoNameplateAnimation (plateFrame, frameAnimations, spellName, isCritical) --private
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
					local shakeTargetFrame = plateFrame.unitFrame
					
					if (not frameShake) then
			
						--[=[ 8.2 GetPoint isn't more possible in nameplate childs
						for i = 1, shakeTargetFrame:GetNumPoints() do --shakeTargetFrame = unitFrame from Plater
							local p1, p2, p3, p4, p5 = shakeTargetFrame:GetPoint (i)
							points [#points+1] = {p1, p2, p3, p4, p5}
						end
						--]=]
						
						local points = Plater.GetPoints (plateFrame.unitFrame)
						
						frameShake = DF:CreateFrameShake (shakeTargetFrame, animationTable.duration, animationTable.amplitude, animationTable.frequency, animationTable.absolute_sineX, animationTable.absolute_sineY, animationTable.scaleX, animationTable.scaleY, animationTable.fade_in, animationTable.fade_out, points)
						plateFrame.SpellAnimations ["frameshake" .. spellName] = frameShake
					end
					
					local animationScale = Plater.db.profile.spell_animations_scale
					
					if (IS_EDITING_SPELL_ANIMATIONS) then
						shakeTargetFrame:SetFrameShakeSettings (frameShake, animationTable.duration, animationTable.amplitude, animationTable.frequency, animationTable.absolute_sineX, animationTable.absolute_sineY, animationTable.scaleX, animationTable.scaleY, animationTable.fade_in, animationTable.fade_out)
					end
					
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

	function Plater.RefreshIsEditingAnimations (state) --private
		IS_EDITING_SPELL_ANIMATIONS = state
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

	function Plater.IsNpcInIgnoreList (plateFrame, onlyProfession) --private
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
	
	function Plater.UpdateMaxCastbarTextLength()
		if (Plater.db.profile.no_spellname_length_limit) then
			Plater.MaxCastBarTextLength = 500
		else
			local barWidth = Plater.db.profile.plate_config.enemynpc.cast_incombat
			Plater.MaxCastBarTextLength = Plater.db.profile.plate_config.enemynpc.cast_incombat[1] - 40
		end
	end

	function Plater.GetNpcIDFromGUID (guid) --private
		local npcID = select (6, strsplit ("-", guid))
		return tonumber (npcID or "0") or 0
	end

	function Plater.GetNpcID (plateFrame) --private
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
		plateFrame.unitFrame [MEMBER_NPCID] = npcId
		
		return npcId
	end
	
	function Plater.GetUnitType (plateFrame)
		if (PET_CACHE [plateFrame [MEMBER_GUID]]) then
			return "pet"
			
		elseif (plateFrame ["namePlateClassification"] == "minus") then
			return "minus"
		end
		
		return "normal"
	end

	function Plater.CanChangePlateSize() --private
		return not InCombatLockdown()
	end
	
	function Plater.RefreshOmniCCGroup (fromInit) --private
		if (OmniCC) then
			local platerThemeName = "Plater Nameplates Theme"
			local platerRuleName = "Plater Nameplates Rule"
			
			--cleanup old data...
			OmniCC:RemoveRule("PlaterNameplates Blacklist")
			OmniCC:RemoveTheme("PlaterNameplates Blacklist")
			
			--attempt to get the plater theme
			local platerTheme = OmniCC:GetTheme(platerThemeName)
			
			--check if the plater theme exists, if it doesn't but the call is from Initialization or Profile Refresh, just quit
			if (not platerTheme and fromInit) then
				return
			end
			
			--if doesn't exists and isn't from init (the call came from the options panel by the user clicking in the checkbox)
			if (not platerTheme) then
				platerTheme = OmniCC:AddTheme(platerThemeName)
				platerTheme.enableText = false
			end
			
			local platerRules = OmniCC:AddRule(platerRuleName, platerThemeName)
			if not platerRules then
				-- rule already exists, get it properly...
				for _, rule in OmniCC:GetRulesets() do
					if rule.id == platerRuleName then
						platerRules = rule
						break
					end
				end
			end
			
			DF.table.addunique (platerRules.patterns, "PlaterMainAuraIcon")
			DF.table.addunique (platerRules.patterns, "PlaterSecondaryAuraIcon")
			DF.table.addunique (platerRules.patterns, "ExtraIconRowIcon")
			
			if (Plater.db.profile.disable_omnicc_on_auras) then
				platerTheme.enableText = false
				platerRules.enabled = true
			else
				platerTheme.enableText = true
			end
			
			OmniCC:OnProfileChanged()
			OmniCC.Cooldown:ForAll("Refresh", true)
		end
	end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> combat log reader  ~combatlog


	local PlaterCLEUParser = CreateFrame ("frame", "PlaterCLEUParserFrame", UIParent)

	local parserFunctions = {
		SPELL_DAMAGE = function (time, token, hidding, sourceGUID, sourceName, sourceFlag, sourceFlag2, targetGUID, targetName, targetFlag, targetFlag2, spellID, spellName, spellType, amount, overKill, school, resisted, blocked, absorbed, isCritical)
			if (SPELL_WITH_ANIMATIONS [spellName] and sourceGUID == Plater.PlayerGUID) then
				for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
					if (plateFrame [MEMBER_GUID] == targetGUID) then
						--disabled for patch 8.2
						--need a workaround for GetPoints() not being available on this patch
						
						--testing new fix
						Plater.DoNameplateAnimation (plateFrame, SPELL_WITH_ANIMATIONS [spellName], spellName, isCritical)
					end
				end
			end
		end,
		
		SPELL_SUMMON = function (time, token, hidding, sourceGUID, sourceName, sourceFlag, sourceFlag2, targetGUID, targetName, targetFlag, targetFlag2, spellID, spellName, spellType, amount, overKill, school, resisted, blocked, absorbed, isCritical)
		--[=[ --some actors are not having the pet flag 0x3000, so we are directly adding all target summons into the cache
			print ("Summon", targetFlag, bit.band (targetFlag, 0x00003000) ~= 0)
			
			if (sourceFlag and bit.band (sourceFlag, 0x00003000) ~= 0) then
				print ("new pet", sourceName, targetName)
				PET_CACHE [sourceGUID] = time
				
			elseif (targetFlag and bit.band (targetFlag, 0x00003000) ~= 0) then
				print ("new pet", sourceName, targetName)
				PET_CACHE [targetGUID] = time
			end
		--]=]

			PET_CACHE [targetGUID] = time
			
			if (sourceGUID == Plater.PlayerGUID) then
				Plater.PlayerPetCache [targetGUID] = time
			end
		end,
		
		SPELL_INTERRUPT = function (time, token, hidding, sourceGUID, sourceName, sourceFlag, sourceFlag2, targetGUID, targetName, targetFlag, targetFlag2, spellID, spellName, spellType, amount, overKill, school, resisted, blocked, absorbed, isCritical)
			if (not Plater.db.profile.show_interrupt_author) then
				return
			end
			
			for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
				if (plateFrame.unitFrame.castBar:IsShown()) then
					if (plateFrame [MEMBER_GUID] == targetGUID) then
						plateFrame.unitFrame.castBar.Text:SetText (INTERRUPTED .. " [" .. Plater.SetTextColorByClass (sourceName, sourceName) .. "]")
						plateFrame.unitFrame.castBar.IsInterrupted = true
						--> check and stop the casting script if any
						plateFrame.unitFrame.castBar:OnHideWidget()
					end
				end
			end
		end,
		
		SPELL_CAST_SUCCESS = function (time, token, hidding, sourceGUID, sourceName, sourceFlag, sourceFlag2, targetGUID, targetName, targetFlag, targetFlag2, spellID, spellName, spellType, amount, overKill, school, resisted, blocked, absorbed, isCritical)
			if (not DB_CAPTURED_SPELLS [spellID]) then
				DB_CAPTURED_SPELLS [spellID] = {event = token, source = sourceName, npcID = Plater:GetNpcIdFromGuid (sourceGUID or ""), encounterID = Plater.CurrentEncounterID}
			end
		end,

		SPELL_AURA_APPLIED = function (time, token, hidding, sourceGUID, sourceName, sourceFlag, sourceFlag2, targetGUID, targetName, targetFlag, targetFlag2, spellID, spellName, spellType, amount, overKill, school, resisted, blocked, absorbed, isCritical)
			if (not DB_CAPTURED_SPELLS [spellID]) then
				local auraType = amount
				DB_CAPTURED_SPELLS [spellID] = {event = token, source = sourceName, type = auraType, npcID = Plater:GetNpcIdFromGuid (sourceGUID or ""), encounterID = Plater.CurrentEncounterID}
			end
		end,
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
		
		for guid, time in pairs (Plater.PlayerPetCache) do
			if (time + 3600 < now) then
				Plater.PlayerPetCache [guid] = nil
			end
		end
	end)

	Plater.NpcBlackList = {} 
	function Plater.ForceFindPetOwner (serial) --private
		local tooltipFrame = PlaterPetOwnerFinder or CreateFrame ("GameTooltip", "PlaterPetOwnerFinder", nil, "GameTooltipTemplate")
		
		tooltipFrame:SetOwner (WorldFrame, "ANCHOR_NONE")
		tooltipFrame:SetHyperlink ("unit:" .. serial or "")
		
		local isPlayerPet = false
		
		local line1 = _G ["PlaterPetOwnerFinderTextLeft2"]
		local text1 = line1 and line1:GetText()
		if (text1 and text1 ~= "") then
			local pName = GetUnitName ("player", true)
			local playerName = pName:gsub ("%-.*", "") --remove realm name
			if (text1:find (playerName)) then
				isPlayerPet = true
			end
		end
		
		if (not isPlayerPet) then
			local line2 = _G ["PlaterPetOwnerFinderTextLeft3"]
			local text2 = line2 and line2:GetText()
			if (text2 and text2 ~= "") then
				local pName = GetUnitName ("player", true)
				local playerName = pName:gsub ("%-.*", "") --remove realm name
				if (text2:find (playerName)) then
					isPlayerPet = true
				end
			end
		end
		
		if (not isPlayerPet) then
			Plater.NpcBlackList [serial] = true
		else
			PET_CACHE [serial] = time()
			Plater.PlayerPetCache [serial] = time()
		end
	end
	
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> cvars - ~cvars
	
function Plater.CreatePlaterButtonAtInterfaceOptions()
	local f = CreateFrame ("frame", nil, InterfaceOptionsNamesPanel)
	f:SetSize (300, 200)
	f:SetPoint ("topleft", InterfaceOptionsNamesPanel, "topleft", 10, -440)
	
	local open_options = function()
		InterfaceOptionsFrame:Hide()
		Plater.OpenOptionsPanel()
	end
	
	local Button = DF:CreateButton (f, open_options, 100, 22, "", -1, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"))
	Button:SetPoint ("topleft", f, "topleft", 10, 0)
	Button:SetText ("Advanced Nameplate Options")
	Button:SetIcon ([[Interface\BUTTONS\UI-OptionsButton]], 18, 18, "overlay", {0, 1, 0, 1})
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
		--SetCVar ("nameplateShowFriends", CVAR_ENABLED)
	--> location of the personal bar
	--	SetCVar ("nameplateSelfBottomInset", 20 / 100)
	--	SetCVar ("nameplateSelfTopInset", abs (20 - 99) / 100)
	
	--> set the stacking to true
	--SetCVar ("nameplateMotion", CVAR_ENABLED) --March 08, 2019 don't change the stacking type when installing plater
	--> distance between each nameplate when using stacking
	--SetCVar ("nameplateOverlapV", 1.25)
	
	--> make nameplates always shown and down't show minions
	SetCVar ("nameplateShowAll", CVAR_ENABLED)
	SetCVar ("ShowNamePlateLoseAggroFlash", CVAR_ENABLED) --blizzard flash
	
	--scale when it is too far away from the camera
	SetCVar ("nameplateMinScale", 1)
	--scale of the nameplate for important units, default is 1.2 which makes the nameplate be too big with the 1.15 target scale
	SetCVar ("nameplateLargerScale", 1.10)
	
	--enable enemy minus nameplates
	SetCVar ("nameplateShowEnemyMinions", CVAR_ENABLED)
	SetCVar ("nameplateShowEnemyMinus", CVAR_ENABLED)
	
	--don't show friendly npcs
	SetCVar ("nameplateShowFriendlyNPCs", 0)
	--disable friendly minius nameplates
	SetCVar ("nameplateShowFriendlyGuardians", CVAR_DISABLED)
	SetCVar ("nameplateShowFriendlyPets", CVAR_DISABLED)
	SetCVar ("nameplateShowFriendlyTotems", CVAR_DISABLED)
	SetCVar ("nameplateShowFriendlyMinions", CVAR_DISABLED)
	
	--> make it show the class color of players
	SetCVar ("ShowClassColorInNameplate", CVAR_ENABLED)
	
	--> lock nameplates to screen
	SetCVar ("nameplateOtherTopInset", "0.085")
	SetCVar ("nameplateLargeTopInset", "0.085")
	SetCVar ("nameplateTargetRadialPosition", "1")
	SetCVar ("nameplateTargetBehindMaxDistance", "30")

	--> reset the horizontal and vertical scale
	SetCVar ("NamePlateHorizontalScale", CVAR_ENABLED)
	SetCVar ("NamePlateVerticalScale", CVAR_ENABLED)
	
	--> make the selection be a little bigger
	SetCVar ("nameplateSelectedScale", "1.15")

	--> movement speed of nameplates when using stacking, going above this isn't recommended
	SetCVar ("nameplateMotionSpeed", "0.05")
	--> this must be 1 for bug reasons on the game client
	SetCVar ("nameplateOccludedAlphaMult", 1)
	--> make the personal bar hide very fast
	SetCVar ("nameplatePersonalHideDelaySeconds", 0.2)

	--> view distance
	SetCVar ("nameplateMaxDistance", 100)
	
	--> ensure resource on target consistency:
	PlaterDBChr.resources_on_target = GetCVar ("nameplateResourceOnTarget") == CVAR_ENABLED
	SetCVar ("nameplateResourceOnTarget", CVAR_DISABLED)
	
	PlaterDBChr.first_run3 [UnitGUID ("player")] = true
	Plater.db.profile.first_run3 = true
	
	Plater.RunFunctionForEvent ("ZONE_CHANGED_NEW_AREA")
	
	--InterfaceOptionsNamesPanelUnitNameplatesMakeLarger:Click() --this isn't required anymore since we use our own unitframe now
	--InterfaceOptionsNamesPanelUnitNameplatesPersonalResource:Click() --removing this since I don't have documentation on why this was added
	--InterfaceOptionsNamesPanelUnitNameplatesPersonalResource:Click()
	Plater.CreatePlaterButtonAtInterfaceOptions()
	
	--[=[
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
	--]=]
	
	--Plater:Msg ("Plater has been successfully installed on this character.")

end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> quest log stuff ~quest

	--PlaterScanTooltip:SetOwner (WorldFrame, "ANCHOR_NONE")
	local GameTooltipFrame = CreateFrame ("GameTooltip", "PlaterScanTooltip", nil, "GameTooltipTemplate")
	local GameTooltipFrameTextLeft2 = _G ["PlaterScanTooltipTextLeft2"]
	
	function Plater.GetActorSubName (plateFrame) --private
		GameTooltipFrame:SetOwner (WorldFrame, "ANCHOR_NONE")
		GameTooltipFrame:SetHyperlink ("unit:" .. (plateFrame [MEMBER_GUID] or ''))
		return GameTooltipFrameTextLeft2:GetText()
	end

	local GameTooltipScanQuest = CreateFrame ("GameTooltip", "PlaterScanQuestTooltip", nil, "GameTooltipTemplate")
	local ScanQuestTextCache = {}
	--for i = 1, 8 do
	--	ScanQuestTextCache [i] = _G ["PlaterScanQuestTooltipTextLeft" .. i]
	--end

	function Plater.IsQuestObjective (plateFrame)
		if (not plateFrame [MEMBER_GUID]) then --platerFrame.actorType == "friendlynpc"
			return
		end
		
		-- reset quest amount
		plateFrame.QuestAmountCurrent = nil
		plateFrame.QuestAmountTotal = nil
		plateFrame.unitFrame.QuestAmountCurrent = nil
		plateFrame.unitFrame.QuestAmountTotal = nil
		
		GameTooltipScanQuest:SetOwner (WorldFrame, "ANCHOR_NONE")
		GameTooltipScanQuest:SetHyperlink ("unit:" .. plateFrame [MEMBER_GUID])

		--8.2 tooltip changes fix by GentMerc#9560 on Discord
		for i = 1, GameTooltipScanQuest:NumLines() do
			ScanQuestTextCache [i] = _G ["PlaterScanQuestTooltipTextLeft" .. i]
		end
		
		local isQuestUnit = false
		local atLeastOneQuestUnfinished = false
		for i = 1, #ScanQuestTextCache do
			local text = ScanQuestTextCache [i]:GetText()
			if (Plater.QuestCache [text]) then
				--unit belongs to a quest
				isQuestUnit = true
				local amount1, amount2 = nil, nil
				local j = i
				while (ScanQuestTextCache [j+1]) do
					--check if the unit objective isn't already done
					local nextLineText = ScanQuestTextCache [j+1]:GetText()
					if (nextLineText) then
						if not nextLineText:match(THREAT_TOOLTIP) then
							local p1, p2 = nextLineText:match ("(%d+)/(%d+)") 
							if (not p1) then
								-- check for % based quests
								p1 = nextLineText:match ("(%d+%%)")
								if p1 then
									-- remove the % sign for consistency
									p1 = string.gsub(p1,"%%", '')
								end
							end
							
							if (p1 and p2 and not (p1 == p2)) or (p1 and not p2 and not (p1 == "100")) then
								-- quest not completed
								atLeastOneQuestUnfinished = true
								amount1, amount2 = p1, p2
							end
						else
							j = 99 --safely break here, as we saw threat% -> quest text is done
						end
					end
					j = j + 1
				end

				if (amount1 and atLeastOneQuestUnfinished) then
					plateFrame.QuestAmountCurrent = amount1
					plateFrame.QuestAmountTotal = amount2
					
					--expose to scripts
					plateFrame.unitFrame.QuestAmountCurrent = amount1
					plateFrame.unitFrame.QuestAmountTotal = amount2
				end
			end
		end
		
		if isQuestUnit and atLeastOneQuestUnfinished then
			plateFrame [MEMBER_QUEST] = true
			plateFrame.unitFrame [MEMBER_QUEST] = true
			return true
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

	function Plater.QuestLogUpdated() --private
		if (Plater.UpdateQuestCacheThrottle and not Plater.UpdateQuestCacheThrottle._cancelled) then
			Plater.UpdateQuestCacheThrottle:Cancel()
		end
		Plater.UpdateQuestCacheThrottle = C_Timer.NewTimer (2, update_quest_cache)
	end


--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> aura test - when the options panel is opened at the buff settings

	function Plater.CreateAuraTesting()

		local auraOptionsFrame = PlaterOptionsPanelContainer.AllFrames [9]

		auraOptionsFrame.OnUpdateFunc = function (self, deltaTime)
			
			auraOptionsFrame.NextTime = auraOptionsFrame.NextTime - deltaTime
			DB_AURA_ENABLED = false
			
			if (auraOptionsFrame.NextTime <= 0) then
				auraOptionsFrame.NextTime = 0.016
				
				for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do

					local buffFrame = plateFrame.unitFrame.BuffFrame
					local buffFrame2 = plateFrame.unitFrame.BuffFrame2
					
					buffFrame:SetAlpha (DB_AURA_ALPHA)
					buffFrame2:SetAlpha (DB_AURA_ALPHA)
					
					--> reset next aura icon to use
					buffFrame.NextAuraIcon = 1
					buffFrame2.NextAuraIcon = 1
				
					if (not DB_AURA_SEPARATE_BUFFS) then
						for index, auraTable in ipairs (auraOptionsFrame.AuraTesting.DEBUFF) do
							local auraIconFrame = Plater.GetAuraIcon (buffFrame)
							if (not auraTable.ApplyTime or auraTable.ApplyTime+auraTable.Duration < GetTime()) then
								auraTable.ApplyTime = GetTime() + math.random (3, 12)
							end
							
							if (not UnitIsUnit (plateFrame.unitFrame [MEMBER_UNITID], "player")) then
								Plater.AddAura (buffFrame, auraIconFrame, index, auraTable.SpellName, auraTable.SpellTexture, auraTable.Count, "DEBUFF", auraTable.Duration, auraTable.ApplyTime+auraTable.Duration, "player", false, false, auraTable.SpellID, nil, nil, nil, nil, auraTable.Type)
							else
								Plater.AddAura (buffFrame, auraIconFrame, index, auraTable.SpellName, auraTable.SpellTexture, auraTable.Count, "DEBUFF", auraTable.Duration, auraTable.ApplyTime+auraTable.Duration, "player", false, false, auraTable.SpellID, false, false, true, true, auraTable.Type)
							end
							
							Plater.UpdateIconAspecRatio (auraIconFrame)
						end
						
						for index, auraTable in ipairs (auraOptionsFrame.AuraTesting.BUFF) do
							local auraIconFrame = Plater.GetAuraIcon (buffFrame)
							if (not auraTable.ApplyTime or auraTable.ApplyTime+auraTable.Duration < GetTime()) then
								auraTable.ApplyTime = GetTime() + math.random (3, 12)
							end
							
							if (not UnitIsUnit (plateFrame.unitFrame [MEMBER_UNITID], "player")) then
								Plater.AddAura (buffFrame, auraIconFrame, index, auraTable.SpellName, auraTable.SpellTexture, auraTable.Count, "DEBUFF", auraTable.Duration, auraTable.ApplyTime+auraTable.Duration, "player", false, false, auraTable.SpellID, true, nil, nil, nil, auraTable.Type)
							else
								Plater.AddAura (buffFrame, auraIconFrame, index, auraTable.SpellName, auraTable.SpellTexture, auraTable.Count, "DEBUFF", auraTable.Duration, auraTable.ApplyTime+auraTable.Duration, "player", false, false, auraTable.SpellID, false, false, false, true, auraTable.Type)
							end
							
							Plater.UpdateIconAspecRatio (auraIconFrame)
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
							
							if (not UnitIsUnit (plateFrame.unitFrame [MEMBER_UNITID], "player")) then
								Plater.AddAura (buffFrame, auraIconFrame, index, auraTable.SpellName, auraTable.SpellTexture, auraTable.Count, "DEBUFF", auraTable.Duration, auraTable.ApplyTime+auraTable.Duration, "player", false, false, auraTable.SpellID, nil, nil, nil, nil, auraTable.Type)
							else
								Plater.AddAura (buffFrame, auraIconFrame, index, auraTable.SpellName, auraTable.SpellTexture, auraTable.Count, "DEBUFF", auraTable.Duration, auraTable.ApplyTime+auraTable.Duration, "player", false, false, auraTable.SpellID, false, false, true, true, auraTable.Type)
							end
						end
						
						for index, auraTable in ipairs (auraOptionsFrame.AuraTesting.BUFF) do
							local auraIconFrame, frame = Plater.GetAuraIcon (buffFrame, true)
							if (not auraTable.ApplyTime or auraTable.ApplyTime+auraTable.Duration < GetTime()) then
								auraTable.ApplyTime = GetTime() + math.random (3, 12)
							end
							
							if (not UnitIsUnit (plateFrame.unitFrame [MEMBER_UNITID], "player")) then
								Plater.AddAura (frame, auraIconFrame, index, auraTable.SpellName, auraTable.SpellTexture, auraTable.Count, "BUFF", auraTable.Duration, auraTable.ApplyTime+auraTable.Duration, "player", false, false, auraTable.SpellID, true, nil, nil, nil, auraTable.Type)
							else
								Plater.AddAura (frame, auraIconFrame, index, auraTable.SpellName, auraTable.SpellTexture, auraTable.Count, "BUFF", auraTable.Duration, auraTable.ApplyTime+auraTable.Duration, "player", false, false, auraTable.SpellID, true, false, false, false, auraTable.Type)
								--Plater.AddAura (frame, auraIconFrame, index, auraTable.SpellName, auraTable.SpellTexture, auraTable.Count, "BUFF", auraTable.Duration, auraTable.ApplyTime+auraTable.Duration, "player", false, false, auraTable.SpellID, false, false, false, true, auraTable.Type)
							end
						end
					end
					
					Plater.HideNonUsedAuraIcons (buffFrame)
					Plater.AlignAuraFrames (buffFrame)
					
					if (DB_AURA_SEPARATE_BUFFS) then
						Plater.AlignAuraFrames (buffFrame.BuffFrame2)
					end
				
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
	end


--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> API ~API

	--attempt to get the role of the unit shown in the nameplate
	function Plater.GetUnitRole (unitFrame)
		local assignedRole = UnitGroupRolesAssigned (unitFrame.unit)
		if (assignedRole and assignedRole ~= "NONE") then
			return assignedRole
		end
		
		if (Plater.ZoneInstanceType == "arena") then
			local oponentes = GetNumArenaOpponentSpecs()
			for i = 1, oponentes do
				local unitGUID = UnitGUID ("arena" .. i)
				if (unitGUID == unitFrame [MEMBER_GUID]) then
					local spec = GetArenaOpponentSpec (i)
					if (spec) then
						local id, name, description, icon, role, class = GetSpecializationInfoByID (spec)
						if (role and role ~= "NONE") then
							return role
						end
					end
				end
			end
			
		elseif (Plater.ZoneInstanceType == "pvp") then
			if (Details) then
				local actor = Details:GetActor ("current", DETAILS_ATTRIBUTE_DAMAGE, GetUnitName (unitFrame.unit, true))
				if (actor) then
					local spec = actor.spec
					if (spec) then
						local id, name, description, icon, role, class = GetSpecializationInfoByID (spec)
						if (role and role ~= "NONE") then
							return role
						end
					end
				end
			end
		end
		
		return assignedRole
	end
	
	--similar to Plater.GetSettings, but can be called from scripts
	--is is also safe because it passes a read-only table with copied values
	function Plater.GetConfig (unitFrame)
		return Plater.ActorTypeSettingsCache [unitFrame.ActorType]
	end
	
	--return true if the player is in open world (not inside dungeons, etc)
	function Plater.IsInOpenWorld()
		return IS_IN_OPEN_WORLD
	end
	
	--refresh the frame strata and frame level when using UIParent as the parent
	function Plater.RefreshNameplateStrata (unitFrame)
		return Plater.UpdateUIParentLevels (unitFrame)
	end
	
	--add an extra indicator
	function Plater.ShowIndicator (unitFrame, texture, width, height, color, L, R, T, B)
		tinsert (unitFrame.CustomIndicators, {texture or "", width or 12, height or 12, color or "white", L or 0, R or 1, T or 0, B or 1})
		Plater.UpdateIndicators (unitFrame.PlateFrame, unitFrame.ActorType)
	end
	
	--allow scripts to perform safe cvars changes with backup of default values
	--PostponeCVarChange stores cvars scheduled to be changed after the combat lockdown drops
	Plater.PostponeSetCVar = {}
	local postpone_set_cvar = function (timerObject)
		local variableName, value = timerObject.variableName, timerObject.value
		Plater.PostponeSetCVar [variableName] = nil
		Plater.SafeSetCVar (variableName, value)
	end
	
	function Plater.SafeSetCVar (variableName, value)
		--check if is a valid cvar
		if (GetCVar (variableName) == nil) then
			Plater:Msg ("invalid cvar for Plater.SafeSetCVar()")
			return
		end
		
		--check if there's a scheduled change for this cvar and cancel it
		if (Plater.PostponeSetCVar [variableName]) then
			Plater.PostponeSetCVar [variableName]:Cancel()
			Plater.PostponeSetCVar [variableName] = nil
		end
		
		--check if is in combat, if is, schedule to change this cvar after the lockdown drop
		if (InCombatLockdown()) then
			local timerObject = C_Timer.NewTimer (0.5, postpone_set_cvar)
			timerObject.variableName = variableName
			timerObject.value = value
			Plater.PostponeSetCVar [variableName] = timerObject
			return true
		end
		
		--store the default value if there's no default value set yet
		local cvarCache = Plater.db.profile.cvar_default_cache
		if (cvarCache [variableName] == nil) then
			cvarCache [variableName] = GetCVar (variableName)
		end
		
		SetCVar (variableName, value)
		return true
	end
	
	Plater.PostponeRestoreCVar = {}
	function Plater.PostponeCVarRestauration (timerObject)
		local variableName = timerObject.variableName
		Plater.PostponeRestoreCVar [variableName] = nil
		Plater.RestoreCVar (variableName)
	end
	
	function Plater.RestoreCVar (variableName)
		--check if is a valid cvar
		if (GetCVar (variableName) == nil) then
			Plater:Msg ("invalid cvar for Plater.SafeSetCVar()")
			return
		end
		
		--check if there's a scheduled change for this cvar and cancel it
		if (Plater.PostponeRestoreCVar [variableName]) then
			Plater.PostponeRestoreCVar [variableName]:Cancel()
			Plater.PostponeRestoreCVar [variableName] = nil
		end
		
		--check if is in combat, if is, schedule to change this cvar after the lockdown drop
		if (InCombatLockdown()) then
			local timerObject = C_Timer.NewTimer (0.5, Plater.PostponeCVarRestauration)
			timerObject.variableName = variableName
			Plater.PostponeRestoreCVar [variableName] = timerObject
			return true
		end

		--restore the value
		local cvarCache = Plater.db.profile.cvar_default_cache
		if (cvarCache [variableName]) then
			SetCVar (variableName, cvarCache [variableName])
			cvarCache [variableName] = nil
			return true
		end
	end
	
	--return if the unit is in the friends list
	function Plater.IsUnitInFriendsList (unitFrame)
		return Plater.FriendsCache [unitFrame [MEMBER_NAME]] or Plater.FriendsCache [unitFrame [MEMBER_NAMELOWER]]
	end
	
	--> api version of the tap denied function
	function Plater.IsUnitTapped (unitFrame)
		return Plater.IsUnitTapDenied (unitFrame.unit)
	end
	
	--set if Plater will check for the execute range and what percent of life is require to enter in the execute range
	--healthAmount is a floor com zero to one, example: 25% is 0.25
	function Plater.SetExecuteRange (isExecuteEnabled, healthAmount)
		DB_USE_HEALTHCUTOFF = isExecuteEnabled
		DB_HEALTHCUTOFF_AT = type (healthAmount) == "number" and healthAmount or 0
	end
	
	--return the name of the unit guild
	function Plater.GetUnitGuildName (unitFrame)
		return unitFrame.PlateFrame.playerGuildName
	end
	
	--return if the nameplate is showing an aura
	function Plater.NameplateHasAura (unitFrame, aura)
		return unitFrame.BuffFrame.AuraCache [aura] or unitFrame.BuffFrame2.AuraCache [aura] or unitFrame.ExtraIconFrame.AuraCache [aura]
	end
	
	--get npc color set in the colors tab
	function Plater.GetNpcColor (unitFrame)
		return DB_UNITCOLOR_SCRIPT_CACHE [unitFrame [MEMBER_NPCID]]
	end

	--return which raid mark the namepalte has
	function Plater.GetRaidMark (unitFrame)
		if (unitFrame.IsSelf) then
			return false
		end
		return GetRaidTargetIndex (unitFrame.unit)
	end

	--limit the text size of a font string
	function Plater.LimitTextSize (fontString, maxWidth)
		if (not fontString) then
			Plater:Msg ("Plater.LimitTextSize() with not fontString")
			return
		end
		
		maxWidth = max (maxWidth or 0, 10)
		local text = fontString:GetText()
		
		while (fontString:GetStringWidth() > maxWidth) do
			text = strsub (text, 1, #text - 1)
			fontString:SetText (text)
			if (string.len (text) <= 1) then
				break
			end
		end	
	end
	
	--create a custom aura checking, this reset the currently shown auras and only check for auras the script passed
	--@buffList: a table with aura names as keys and true as the value, example: ["aura name"] = true
	--@debuffList: same as above
	--@noSpecialAuras: won't check special auras
	function Plater.CheckAuras (self, buffList, debuffList, noSpecialAuras)
		local buffFrame = self.BuffFrame
		
		Plater.ResetAuraContainer (buffFrame)
		
		Plater.TrackSpecificAuras (buffFrame, self.unit, true, buffList, self.IsSelf, noSpecialAuras)
		Plater.TrackSpecificAuras (buffFrame, self.unit, false, debuffList, self.IsSelf, noSpecialAuras)
		
		Plater.HideNonUsedAuraIcons (buffFrame)
		
		--update the buff layout and alpha
		buffFrame.unit = self.unit
		Plater.AlignAuraFrames (buffFrame)
		buffFrame:SetAlpha (DB_AURA_ALPHA)
		buffFrame2:SetAlpha (DB_AURA_ALPHA)
	end
	
	--return the health bar and the unitname text
	function Plater.GetHealthBar (unitFrame)
		--check if the plateFrame has been passed instead
		if (unitFrame.unitFrame) then
			unitFrame = unitFrame.unitFrame
		end
		return unitFrame.healthBar, unitFrame.healthBar.unitName
	end
	--return the cast bar and the spellname text
	function Plater.GetCastBar (unitFrame)
		--check if the plateFrame has been passed instead
		if (unitFrame.unitFrame) then
			unitFrame = unitFrame.unitFrame
		end
		return unitFrame.castBar, unitFrame.castBar.Text
	end
	
	--create a glow around the frame using LibCustomGlow - defaults to "button" glow
	--[[ options can be used to create different glow types, see https://www.curseforge.com/wow/addons/libcustomglow
		--type "pixel"
		options = {
			glowType = "pixel",
			color = "white", -- all plater color types accepted, from lib: {r,g,b,a}, color of lines and opacity, from 0 to 1. Defaul value is {0.95, 0.95, 0.32, 1}
			N = 8, -- number of lines. Defaul value is 8;
			frequency = 0.25, -- frequency, set to negative to inverse direction of rotation. Default value is 0.25;
			length = 4, -- length of lines. Default value depends on region size and number of lines;
			th = 2, -- thickness of lines. Default value is 2;
			xOffset = 0,
			yOffset = 0, -- offset of glow relative to region border;
			border = false, -- set to true to create border under lines;
			key = "", -- key of glow, allows for multiple glows on one frame;
		}
		
		-- type "ants"
		options = {
			glowType = "ants",
			color = "white", -- all plater color types accepted, from lib: {r,g,b,a}, color of lines and opacity, from 0 to 1. Defaul value is {0.95, 0.95, 0.32, 1}
			N = 4, -- number of particle groups. Each group contains 4 particles. Defaul value is 4;
			frequency = 0.125, -- frequency, set to negative to inverse direction of rotation. Default value is 0.125;
			scale = 1, -- scale of particles
			xOffset = 0,
			yOffset = 0, -- offset of glow relative to region border;
			key = "", -- key of glow, allows for multiple glows on one frame;
		}
		
		-- type "button"
		options = {
			glowType = "button",
			color = "white", -- all plater color types accepted, from lib: {r,g,b,a}, color of lines and opacity, from 0 to 1. Defaul value is {0.95, 0.95, 0.32, 1}
			frequency = 0.125, -- frequency, set to negative to inverse direction of rotation. Default value is 0.125;
		}
	--]]
	function Plater.StartGlow(frame, color, options, key)
		if not frame then return end
		
		if not color and (options and options.color) then
			color = options.color
		end
		if color then
			local r, g, b, a = DF:ParseColors (color)
			color = {r, g, b, a}
			options.color = color
		end
		
		if not options then
			options = {
				glowType = "button",
				color = color,
				key = key or "",
			}
		end
		
		if not options.glowType then
			options.glowType = "button"
		end
		
		if key then
			options.key = key
		end
		
		if (not frame.__PlaterGlowFrame) then
			frame.__PlaterGlowFrame = CreateFrame("Frame", nil, frame);
			frame.__PlaterGlowFrame:SetAllPoints(frame);
			frame.__PlaterGlowFrame:SetSize(frame:GetSize());
		end
		
		if options.glowType == "button" then
			LCG.ButtonGlow_Start(frame.__PlaterGlowFrame, options.color, options.frequency)
		elseif options.glowType == "pixel" then
			if not options.border then options.border = false end
			LCG.PixelGlow_Start(frame.__PlaterGlowFrame, options.color, options.N, options.frequency, options.length, options.th, options.xOffset, options.yOffset, options.border, options.key or "")
		elseif options.glowType == "ants" then
			LCG.AutoCastGlow_Start(frame.__PlaterGlowFrame, options.color, options.N, options.frequency, options.scale, options.xOffset, options.yOffset, options.key or "")
		end
	end
	
	-- creates a button glow effect
	function Plater.StartButtonGlow(frame, color, options)
		-- type "button"
		if not options then
			options = {
				glowType = "button",
				color = color, -- all plater color types accepted, from lib: {r,g,b,a}, color of lines and opacity, from 0 to 1. Defaul value is {0.95, 0.95, 0.32, 1}
				frequency = 0.125, -- frequency, set to negative to inverse direction of rotation. Default value is 0.125;
			}
		else
			options.glowType = "button"
		end
		
		Plater.StartGlow(frame, color, options)
	end
	
	-- creates an ants glow effect
	function Plater.StartAntsGlow(frame, color, options, key)
		-- type "ants"
		if not options then
			options = {
				glowType = "ants",
				color = color,
				N = 4, -- number of particle groups. Each group contains 4 particles. Defaul value is 4;
				frequency = 0.125, -- frequency, set to negative to inverse direction of rotation. Default value is 0.125;
				scale = 1, -- scale of particles
				xOffset = 0,
				yOffset = 0, -- offset of glow relative to region border;
				key = key or "", -- key of glow, allows for multiple glows on one frame;
			}
		else
			options.glowType = "ants"
		end
		
		Plater.StartGlow(frame, color, options, key)
	end
	
	-- creates a pixel glow effect
	function Plater.StartPixelGlow(frame, color, options, key)
		-- type "pixel"
		if not options then
			options = {
				glowType = "pixel",
				color = color, -- all plater color types accepted, from lib: {r,g,b,a}, color of lines and opacity, from 0 to 1. Defaul value is {0.95, 0.95, 0.32, 1}
				N = 8, -- number of lines. Defaul value is 8;
				frequency = 0.25, -- frequency, set to negative to inverse direction of rotation. Default value is 0.25;
				--length = 4, -- length of lines. Default value depends on region size and number of lines;
				th = 2, -- thickness of lines. Default value is 2;
				xOffset = 0,
				yOffset = 0, -- offset of glow relative to region border;
				border = false, -- set to true to create border under lines;
				key = key or "", -- key of glow, allows for multiple glows on one frame;
			}
		else
			options.glowType = "pixel"
		end
		
		Plater.StartGlow(frame, color, options, key)
	end
	
	-- stop LibCustomGlow effects on the frame, if existing
	-- if glowType (and key) are given, stop one glow. if not, stop all.
	function Plater.StopGlow(frame, glowType, key)
		if not frame then return end
		if not frame.__PlaterGlowFrame then return end
		
		if glowType then		
			if glowType == "button" then
				LCG.ButtonGlow_Stop(frame.__PlaterGlowFrame, key or "")
			elseif glowType == "pixel" then
				LCG.PixelGlow_Stop(frame.__PlaterGlowFrame, key or "")
			elseif glowType == "ants" then
				LCG.AutoCastGlow_Stop(frame.__PlaterGlowFrame, key or "")
			end
		else
			LCG.ButtonGlow_Stop(frame.__PlaterGlowFrame, key or "")
			LCG.PixelGlow_Stop(frame.__PlaterGlowFrame, key or "")
			LCG.AutoCastGlow_Stop(frame.__PlaterGlowFrame, key or "")
		end
	end
	
	-- stop a button glow
	function Plater.StopButtonGlow(frame, key)
		Plater.StopGlow(frame, "button", key)
	end
	
	-- stop a button glow
	function Plater.StopPixelGlow(frame, key)
		Plater.StopGlow(frame, "pixel", key)
	end
	
	-- stop an ants glow
	function Plater.StopAntsGlow(frame, key)
		Plater.StopGlow(frame, "ants", key)
	end

	--create a glow around an icon
	function Plater.CreateIconGlow (frame, color)
		local f = Plater:CreateGlowOverlay (frame, color, color)
		return f
	end

	--create a glow around the healthbar or castbar frame
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
		PixelUtil.SetPoint (glow, "center", frame, "center", 0, 0)
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

	--creates a flash, call returnedValue:Play() to flash
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

	--called to undo a color modification
	function Plater.RefreshNameplateColor (unitFrame)
		if (unitFrame.unit) then
			if (Plater.IsUnitTapDenied (unitFrame.unit)) then
				Plater.ChangeHealthBarColor_Internal (unitFrame.healthBar, unpack (Plater.db.profile.tap_denied_color))
			else
				if (InCombatLockdown()) then
					local unitReaction = unitFrame.PlateFrame [MEMBER_REACTION]
					if (unitReaction == 4 and not UnitAffectingCombat (unitFrame.unit)) then
						Plater.FindAndSetNameplateColor (unitFrame, true)
					else
						if (unitReaction <= 4 and DB_AGGRO_CHANGE_HEALTHBAR_COLOR) then
							Plater.UpdateNameplateThread (unitFrame)
						else
							Plater.FindAndSetNameplateColor (unitFrame)
						end
					end
				else
					Plater.FindAndSetNameplateColor (unitFrame)
				end
			end
		end
	end

	--modify the color of the health bar
	function Plater.SetNameplateColor (unitFrame, r, g, b)
		if (unitFrame.unit) then
			if (not r) then
				Plater.RefreshNameplateColor (unitFrame)
			else
				r, g, b = DF:ParseColors (r, g, b)
				return Plater.ChangeHealthBarColor_Internal (unitFrame.healthBar, r, g, b)
			end
		end
	end

	local function inTable(tbl, item)
		for key, value in pairs(tbl) do
			if value == item then return key end
		end
		return false
	end

	function Plater.SetNameplateFontOutline (unitFrame, outline)
		if (unitFrame.unit) then
			local outline_modes = {"NONE", "MONOCHROME", "OUTLINE", "THICKOUTLINE"}
			local plateConfigs = DB_PLATE_CONFIG[unitFrame.ActorType]
			if (outline and outline ~= '' and inTable(outline_modes, outline)) then
				Plater.SetFontOutlineAndShadow (unitFrame.unitName, outline, plateConfigs.actorname_text_shadow_color, plateConfigs.actorname_text_shadow_color_offset[1], plateConfigs.actorname_text_shadow_color_offset[2])
			else
				Plater.SetFontOutlineAndShadow (unitFrame.unitName, plateConfigs.actorname_text_outline, plateConfigs.actorname_text_shadow_color, plateConfigs.actorname_text_shadow_color_offset[1], plateConfigs.actorname_text_shadow_color_offset[2])
			end
		end
	end

	function Plater.ResetNameplateFontOutline (unitFrame)
		if (unitFrame.unit) then
			local plateConfigs = DB_PLATE_CONFIG[unitFrame.ActorType]
			Plater.SetFontOutlineAndShadow (unitFrame.unitName, plateConfigs.actorname_text_outline, plateConfigs.actorname_text_shadow_color, plateConfigs.actorname_text_shadow_color_offset[1], plateConfigs.actorname_text_shadow_color_offset[2])
		end
	end

	--set a temporarly size for the healthbar
	--this value is reset when the nameplate is added to the screen
	function Plater.SetNameplateSize (unitFrame, width, height)
		unitFrame.customHealthBarWidth = width
		unitFrame.customHealthBarHeight = height
		Plater.UpdatePlateSize (unitFrame.PlateFrame)
	end

	--modify the color of the cast bar
	function Plater.SetCastBarColor (unitFrame, r, g, b)
		if (unitFrame.unit) then
			if (not r) then
				--refresh the castbar color (the framework adjust the cast bar color)
				unitFrame.castBar:UpdateCastColor()
			else
				--framework accepts SetColor, it does parse the color within the call
				return unitFrame.castBar:SetColor (r, g, b)
			end
		end
	end
	
	--set a temporarly size for the castbar
	--this value is reset when the nameplate is added to the screen
	function Plater.SetCastBarSize (unitFrame, width, height)
		unitFrame.customCastBarWidth = width
		unitFrame.customCastBarHeight = height
		Plater.UpdatePlateSize (unitFrame.PlateFrame)
	end
	
	--same thing as the two above but for the power bar
	function Plater.SetPowerBarSize (unitFrame, width, height)
		unitFrame.customPowerBarWidth = width
		unitFrame.customPowerBarHeight = height
		Plater.UpdatePlateSize (unitFrame.PlateFrame)
	end
	
	--changes the border color, this call is for the API, can be called from external sources
	function Plater.SetBorderColor (self, r, g, b, a) --self = unitFrame
		if (not r) then
			self.customBorderColor = nil
			Plater.UpdateBorderColor (self)
			return
		end
		
		r, g, b, a = DF:ParseColors (r, g, b, a)
		
		--UpdateBorderColor will use the value set on customBorderColor member if any
		self.customBorderColor = {r, g, b, a}
		
		Plater.UpdateBorderColor (self)
	end

	--flashes on the health bar border
	function Plater.FlashNameplateBorder (unitFrame, duration)
		if (not unitFrame.healthBar.PlayHealthFlash) then
			Plater.CreateHealthFlashFrame (unitFrame.PlateFrame)
		end
		unitFrame.healthBar.canHealthFlash = true
		unitFrame.healthBar.PlayHealthFlash (duration)
	end

	--flashes the unitFrame body
	function Plater.FlashNameplateBody (unitFrame, text, duration)
		--> sending true to ignore cooldown
		unitFrame.PlateFrame.PlayBodyFlash (text, duration, true)
	end

	--return if the player is in combat
	function Plater.IsInCombat()
		return InCombatLockdown() or PLAYER_IN_COMBAT
	end

	--return true if the unit is in the tank role
	function Plater.IsUnitTank (unitFrame)
		return TANK_CACHE [unitFrame [MEMBER_NAME]] or TANK_CACHE [unitFrame [MEMBER_NAMELOWER]]
	end
	
	--check the role and the role of the specialization to return if the player is in a tank role
	function Plater.IsPlayerTank()
		return IsPlayerEffectivelyTank()
	end
	
	--return the table where tanks is stored
	--has the unit name as the key and true as value
	function Plater.GetTanks()
		return TANK_CACHE
	end

	--change the color of the cast bar
	function Plater.SetCastBarBorderColor (castBar, r, g, b, a)
		--check if the frame passed was the unitFrame instead of the castbar it self
		if (castBar.castBar) then
			castBar = castBar.castBar
		end
		
		if (not r) then
			castBar.FrameOverlay:SetBackdropBorderColor (0, 0, 0, 0)
			return
		end
		
		r, g, b, a = DF:ParseColors (r, g, b, a)
		castBar.FrameOverlay:SetBackdropBorderColor (r, g, b, a)
	end

	--show the health bar, the health bar is shown by default, use to undo HideHealthBar() call
	function Plater.ShowHealthBar (unitFrame)
		unitFrame.healthBar:Show()
		unitFrame.BuffFrame:Show()
		unitFrame.BuffFrame2:Show()
		unitFrame.ExtraIconFrame:Show()
		unitFrame.healthBar.unitName:Show()
		
		unitFrame.PlateFrame.IsFriendlyPlayerWithoutHealthBar = false
		
		unitFrame.ActorNameSpecial:Hide()
		unitFrame.ActorTitleSpecial:Hide()
		
		Plater.UpdatePlateText (unitFrame.PlateFrame, DB_PLATE_CONFIG [unitFrame.ActorType], true)
	end

	--hide the health bar and show the secondary unit name and title text strings
	function Plater.HideHealthBar (unitFrame, showPlayerName, showNameNpc)
		unitFrame.healthBar:Hide()
		unitFrame.BuffFrame:Hide()
		unitFrame.BuffFrame2:Hide()
		unitFrame.ExtraIconFrame:Hide()
		unitFrame.healthBar.unitName:Hide()
		
		unitFrame.PlateFrame.IsFriendlyPlayerWithoutHealthBar = showPlayerName
		unitFrame.PlateFrame.IsNpcWithoutHealthBar = showNameNpc
		
		if (showPlayerName) then
			Plater.UpdatePlateText (unitFrame.PlateFrame, DB_PLATE_CONFIG [ACTORTYPE_FRIENDLY_PLAYER], true)
			
		elseif (showNameNpc) then
			Plater.UpdatePlateText (unitFrame.PlateFrame, DB_PLATE_CONFIG [ACTORTYPE_ENEMY_NPC], true)
		end
	end
	
	--forces a range check regardless of the user options and only changes the member_range flag, no alpha changes
	--if the spell name is passed, it just return the result without modifying the nameplate attributes
	function Plater.NameplateInRange (unitFrame, spellName)
		if (spellName) then
			return IsSpellInRange (spellName, unitFrame [MEMBER_UNITID]) == 1
			
		elseif (Plater.SpellBookForRangeCheck) then
			if (IsSpellInRange (Plater.SpellForRangeCheck, Plater.SpellBookForRangeCheck, unitFrame [MEMBER_UNITID]) == 1) then
				unitFrame [MEMBER_RANGE] = true
				return true
			else
				unitFrame [MEMBER_RANGE] = false
				return false
			end
		else
			if (IsSpellInRange (Plater.SpellForRangeCheck, unitFrame [MEMBER_UNITID]) == 1) then
				unitFrame [MEMBER_RANGE] = true
				return true
			else
				unitFrame [MEMBER_RANGE] = false
				return false
			end
		end
	end

	
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> scripting ~scripting
	
	-- ~compress ~zip ~export ~import ~deflate ~serialize
	function Plater.CompressData (data, dataType)
		local LibDeflate = LibStub:GetLibrary ("LibDeflate")
		local LibAceSerializer = LibStub:GetLibrary ("AceSerializer-3.0")
		
		if (LibDeflate and LibAceSerializer) then
			local dataSerialized = LibAceSerializer:Serialize (data)
			if (dataSerialized) then
				local dataCompressed = LibDeflate:CompressDeflate (dataSerialized, {level = 9})
				if (dataCompressed) then
					if (dataType == "print") then
						local dataEncoded = LibDeflate:EncodeForPrint (dataCompressed)
						return dataEncoded
						
					elseif (dataType == "comm") then
						local dataEncoded = LibDeflate:EncodeForWoWAddonChannel (dataCompressed)
						return dataEncoded
					end
				end
			end
		end
	end

	function Plater.DecompressData (data, dataType)
		local LibDeflate = LibStub:GetLibrary ("LibDeflate")
		local LibAceSerializer = LibStub:GetLibrary ("AceSerializer-3.0")
		
		if (LibDeflate and LibAceSerializer) then
			
			local dataCompressed
			
			if (dataType == "print") then
				dataCompressed = LibDeflate:DecodeForPrint (data)
				if (not dataCompressed) then
					Plater:Msg ("couldn't decode the data.")
					return false
				end

			elseif (dataType == "comm") then
				dataCompressed = LibDeflate:DecodeForWoWAddonChannel (data)
				if (not dataCompressed) then
					Plater:Msg ("couldn't decode the data.")
					return false
				end
			end
			
			local dataSerialized = LibDeflate:DecompressDeflate (dataCompressed)
			if (not dataSerialized) then
				Plater:Msg ("couldn't uncompress the data.")
				return false
			end
			
			local okay, data = LibAceSerializer:Deserialize (dataSerialized)
			if (not okay) then
				Plater:Msg ("couldn't unserialize the data.")
				return false
			end
			
			return data
		end
	end

	function Plater.ExportProfileToString()
		local profile = Plater.db.profile
		
		--temp store the animations on another table
		local spellAnimations = profile.spell_animation_list
		--remove the animation list from the profile
		profile.spell_animation_list = nil
		
		--temp store trashcans
		local trashcanScripts = profile.script_data_trash
		local trashcanHooks = profile.hook_data_trash
		--clear the trash can
		profile.script_data_trash = {}
		profile.hook_data_trash = {}
		
		--cleanup mods HooksTemp (for good)
		for i = #Plater.db.profile.hook_data, 1, -1 do
			local scriptObject = Plater.db.profile.hook_data [i]
			scriptObject.HooksTemp = {}
		end
		
		--convert the profile to string
		local data = Plater.CompressData (profile, "print")
		if (not data) then
			Plater:Msg ("failed to compress the profile")
		end
		
		--restore the profile animations and trashcan
		profile.spell_animation_list = spellAnimations
		profile.script_data_trash = trashcanScripts
		profile.hook_data_trash = trashcanHooks
		
		return data
	end

	--scripts mixin - these functions are mixed in with castbar, unitframe and aura icons
	Plater.ScriptMetaFunctions = {
		--get the table which stores all script information for the widget
		--self is the affected widget, e.g. icon frame, unitframe, castbar progressbar
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
		ScriptGetInfo = function (self, globalScriptObject, widgetScriptContainer, isHookScript)
			widgetScriptContainer = widgetScriptContainer or self:GetScriptContainer()
			
			--using the memory address of the original scriptObject from db.profile as the map key
			local scriptInfo = widgetScriptContainer [globalScriptObject.DBScriptObject]
			if (
				(not scriptInfo) or 
				(scriptInfo.GlobalScriptObject.NeedHotReload) or 
				(scriptInfo.GlobalScriptObject.Build and scriptInfo.GlobalScriptObject.Build < PLATER_HOOK_BUILD)
			) then
				local forceHotReload = scriptInfo and scriptInfo.GlobalScriptObject.NeedHotReload
			
				scriptInfo = {
					GlobalScriptObject = globalScriptObject, 
					HotReload = -1, 
					Env = {}, 
					IsActive = false
				}

				if (globalScriptObject.HasConstructor and (not scriptInfo.Initialized or (isHookScript and forceHotReload))) then
					local okay, errortext = pcall (globalScriptObject.Constructor, self, self.displayedUnit or self.unit or self:GetParent()[MEMBER_UNITID], self, scriptInfo.Env, PLATER_GLOBAL_MOD_ENV [scriptInfo.GlobalScriptObject.DBScriptObject.Name])
					if (not okay) then
						Plater:Msg ("Script |cFFAAAA22" .. scriptInfo.GlobalScriptObject.DBScriptObject.Name .. "|r Constructor error: " .. errortext)
					end
					scriptInfo.Initialized = true
				end
				
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
				local unitFrame = self.unitFrame or self
				local okay, errortext = pcall (scriptInfo.GlobalScriptObject ["ConstructorCode"], self, unitFrame.displayedUnit or unitFrame.unit or unitFrame.PlateFrame[MEMBER_UNITID], unitFrame, scriptInfo.Env, PLATER_GLOBAL_SCRIPT_ENV [scriptInfo.GlobalScriptObject.DBScriptObject.Name])
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
			local unitFrame = self.unitFrame or self
			local okay, errortext = pcall (scriptInfo.GlobalScriptObject ["UpdateCode"], self, unitFrame.displayedUnit or unitFrame.unit or unitFrame.PlateFrame[MEMBER_UNITID], unitFrame, scriptInfo.Env, PLATER_GLOBAL_SCRIPT_ENV [scriptInfo.GlobalScriptObject.DBScriptObject.Name])
			if (not okay) then
				Plater:Msg ("Script |cFFAAAA22" .. scriptInfo.GlobalScriptObject.DBScriptObject.Name .. "|r OnUpdate error: " .. errortext)
			end
		end,
		
		--run the OnShow script
		ScriptRunOnShow = function (self, scriptInfo)
			--dispatch the on show script
			local unitFrame = self.unitFrame or self
			local okay, errortext = pcall (scriptInfo.GlobalScriptObject ["OnShowCode"], self, unitFrame.displayedUnit or unitFrame.unit or unitFrame.PlateFrame[MEMBER_UNITID], unitFrame, scriptInfo.Env, PLATER_GLOBAL_SCRIPT_ENV [scriptInfo.GlobalScriptObject.DBScriptObject.Name])
			if (not okay) then
				Plater:Msg ("Script |cFFAAAA22" .. scriptInfo.GlobalScriptObject.DBScriptObject.Name .. "|r OnShow error: " .. errortext)
			end
			
			scriptInfo.IsActive = true
			self.ScriptKey = scriptInfo.GlobalScriptObject.ScriptKey
		end,
		
		--run the OnHide script
		ScriptRunOnHide = function (self, scriptInfo)
			--dispatch the on hide script
			local unitFrame = self.unitFrame or self
			local okay, errortext = pcall (scriptInfo.GlobalScriptObject ["OnHideCode"], self, unitFrame.displayedUnit or unitFrame.unit or unitFrame.PlateFrame[MEMBER_UNITID], unitFrame, scriptInfo.Env, PLATER_GLOBAL_SCRIPT_ENV [scriptInfo.GlobalScriptObject.DBScriptObject.Name])
			if (not okay) then
				Plater:Msg ("Script |cFFAAAA22" .. scriptInfo.GlobalScriptObject.DBScriptObject.Name .. "|r OnHide error: " .. errortext)
			end
			
			scriptInfo.IsActive = false
			self.ScriptKey = nil
		end,
		
		--run the Initialization script, called during compile time
		ScriptRunInitialization = function (globalScriptObject)
			--dispatch the init script
			local okay, errortext = pcall (globalScriptObject ["Initialization"], PLATER_GLOBAL_SCRIPT_ENV [globalScriptObject.DBScriptObject.Name])
			if (not okay) then
				Plater:Msg ("Script |cFFAAAA22" .. globalScriptObject.DBScriptObject.Name .. "|r Initialization error: " .. errortext)
			end
		end,
		
		ScriptRunHook = function (self, scriptInfo, hookName, frame)
			--dispatch a hook for the script
			--at the moment, self is always the unit frame
			local okay, errortext = pcall (scriptInfo.GlobalScriptObject [hookName], frame or self, self.displayedUnit, self, scriptInfo.Env, PLATER_GLOBAL_MOD_ENV [scriptInfo.GlobalScriptObject.DBScriptObject.Name])
			if (not okay) then
				Plater:Msg ("Mod |cFFAAAA22" .. scriptInfo.GlobalScriptObject.DBScriptObject.Name .. "|r code for |cFFBB8800" .. hookName .. "|r error: " .. errortext)
			end
		end,
		
		--run only once without attach to the script or hook
		ScriptRunNoAttach = function (hookInfo, hookName)
			local func = hookInfo [hookName]
			local okay, errortext = pcall (func, PLATER_GLOBAL_MOD_ENV [hookInfo.DBScriptObject.Name])
			if (not okay) then
				Plater:Msg ("Mod |cFFAAAA22" .. hookInfo.DBScriptObject.Name .. "|r code for |cFFBB8800" .. hookName .. "|r error: " .. errortext)
			end
		end,
		
		--run when the widget hides
		OnHideWidget = function (self)
			--> check if can quickly quit (if there's no script container for the nameplate)
			if (self.ScriptInfoTable) then
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
			end

			--> hooks, check which kind of widget this is and then run the appropriate hook
			if (self.IsCastBar) then
				if (HOOK_CAST_STOP.ScriptAmount > 0) then
					for i = 1, HOOK_CAST_STOP.ScriptAmount do
						local globalScriptObject = HOOK_CAST_STOP [i]
						local unitFrame = self.unitFrame
						local scriptContainer = unitFrame:ScriptGetContainer()
						local scriptInfo = unitFrame:ScriptGetInfo (globalScriptObject, scriptContainer, "Cast Stop")
						--run
						unitFrame:ScriptRunHook (scriptInfo, "Cast Stop", self)
					end
				end
			end
			
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
		end,
		
		IsProtected = function (self)
		-- assume that nameplates are always protected since 8.2
			if self then
				if self.PlateFrame then
					return self.PlateFrame:IsProtected()
				end
			end
			
			return false
		end,
	}
	 
	function Plater.GetAllScripts (scriptType)
		if (scriptType == "script") then
			return Plater.db.profile.script_data
		elseif (scriptType == "hook") then
			return Plater.db.profile.hook_data
		end
	end
	
	function Plater.GetAllScriptsAsPrioSortedCopy (scriptType)
		local scripts
		if (scriptType == "script") then
			scripts = DF.table.copy({}, Plater.db.profile.script_data)
		elseif (scriptType == "hook") then
			scripts = DF.table.copy({}, Plater.db.profile.hook_data)
		end
		
		local function round(x)
			if not x then return nil end
			return (x + 0.5 - (x + 0.5) % 1)
		end
		
		if scripts then
			table.sort(scripts, function(a,b)
				if a and not b then
					return false
				elseif not a and b then
					return true
				else
					return round(a.Prio or 99) > round(b.Prio or 99)
				end
				return false
			end)
		end
		--table.foreach(scripts, function(index, self) if self then print(self.Prio, self.Name) else print("not self") end end)
		return scripts
	end
	
	--compile all scripts
	function Plater.CompileAllScripts (scriptType, noHotReload)
		if (scriptType == "script") then
			for scriptId, scriptObject in ipairs (Plater.GetAllScriptsAsPrioSortedCopy ("script")) do
				if (scriptObject.Enabled) then
					if not noHotReload then
						PLATER_GLOBAL_SCRIPT_ENV [scriptObject.Name] = nil
					end
					Plater.CompileScript (scriptObject)
				end
			end
		elseif (scriptType == "hook") then
			--get all hook scripts from the profile database
			for scriptId, scriptObject in ipairs (Plater.GetAllScriptsAsPrioSortedCopy ("hook")) do
				if not noHotReload then
					PLATER_GLOBAL_MOD_ENV [scriptObject.Name] = nil
				end
				Plater.CompileHook (scriptObject)
			end
		end
	end

	--when a script object get disabled, need to clear all compiled scripts in the cache and recompile than again
	--this other scripts that uses the same trigger name get activated
	-- ~scripts

	Plater.CoreVersion = 1

	--from weakauras
	--source https://github.com/WeakAuras/WeakAuras2/blob/520951a4b49b64cb49d88c1a8542d02bbcdbe412/WeakAuras/AuraEnvironment.lua#L66
	local blockedFunctions = {
		-- Lua functions that may allow breaking out of the environment
		getfenv = true,
		getfenv = true,
		loadstring = true,
		pcall = true,
		xpcall = true,
		getglobal = true,
		
		-- blocked WoW API
		SendMail = true,
		SetTradeMoney = true,
		AddTradeMoney = true,
		PickupTradeMoney = true,
		PickupPlayerMoney = true,
		TradeFrame = true,
		MailFrame = true,
		EnumerateFrames = true,
		RunScript = true,
		AcceptTrade = true,
		SetSendMailMoney = true,
		EditMacro = true,
		SlashCmdList = true,
		DevTools_DumpCommand = true,
		hash_SlashCmdList = true,
		CreateMacro = true,
		SetBindingMacro = true,
		GuildDisband = true,
		GuildUninvite = true,
		securecall = true,
		
		--additional
		setmetatable = true,
	}
	
	--internal Plater functions
	local privateFunctions = {
		CompileAllScripts = true,
		GetAllScripts = true,
		ScriptMetaFunctions = true,
		DecompressData = true,
		CompressData = true,
		ExportProfileToString = true,
		WipeAndRecompileAllScripts = true,
		AllHookGlobalContainers = true,
		WipeHookContainers = true,
		GetContainerForHook = true,
		CurrentlyLoadedHooks = true,
		DestructorScriptHooks = true,
		RunDestructorForHook = true,
		CompileHook = true,
		CompileScript = true,
		CheckScriptTriggerOverlap = true,
		GetScriptObject = true,
		GetScriptDB = true,
		GetScriptType = true,
		GetDecodedScriptType = true,
		ImportScriptsFromLibrary = true,
		ImportScriptString = true,
		AddScript = true,
		BuildScriptObjectFromIndexTable = true,
		DecodeImportedString = true,
		PrepareTableToExport = true,
		ScriptReceivedFromGroup = true,
		ExportScriptToGroup = true,
		ShowImportScriptConfirmation = true,
		DispatchTalentUpdateHookEvent  = true,
		ScheduleHookForCombat = true,
		ScheduleRunFunctionForEvent = true,
		RunFunctionForEvent = true,
		EventHandler = true,
		RegisterRefreshDBCallback = true,
		FireRefreshDBCallback = true,
		--RefreshDBUpvalues = true,
		--RefreshDBLists = true,
		--UpdateAuraCache = true,
		ApplyPatches = true,
		RefreshConfig = true,
		RefreshConfigProfileChanged = true,
		RefreshConfig = true,
		SaveConsoleVariables = true,
		GetSettings = true,
		CodeTypeNames = true,
		HookScripts = true,
		HookScriptsDesc = true,
		IncreaseHookBuildID = true,
		IncreaseRefreshID = true,
		SpecList = true,
		UpdateSettingsCache = true,
		ActorTypeSettingsCache = true,
		RunScheduledUpdate = true,
		ScheduleUpdateForNameplate = true,
		EventHandlerFrame = true,
		OnInit = true,
		HookLoadCallback = true,
		CheckFirstRun = true,
		CommHandler = true,
		CommReceived = true,
		GetAllShownPlates = true,
		GetHashKey = true,
		IsShowingResourcesOnTarget = true,
		OnRetailNamePlateShow = true,
		UpdateSelfPlate = true,
		CastBarOnShow_Hook = true,
		CastBarOnEvent_Hook = true,
		CastBarOnTick_Hook = true,
		OnEnterAura = true,
		OnLeaveAur = true,
		RefreshAuras = true,
		CreateAuraIcon = true,
		RefreshColorOverride = true,
		ChangeHealthBarColor_Internal = true,
		UpdateAllPlates = true,
		FullRefreshAllPlates = true,
		UpdatePlateClickSpace = true,
		NameplateTick = true,
		OnPlayerTargetChanged = true,
		UpdateTarget = true,
		UpdatePlateText = true,
		CheckLifePercentText = true,
		UpdateAllNames = true,
		UpdateLevelTextAndColor = true,
		UpdatePlateFrame = true,
		ForceChangeBorderColor = true,
		UpdatePlateBorders = true,
		UpdateRaidMarkersOnAllNameplates = true,
		RefreshAutoToggle = true,
		ParseHealthSettingForPlayer = true,
		CreateAlphaAnimation = true,
		CreateHighlightNameplate = true,
		CreateHealthFlashFrame = true,
		CreateAggroFlashFrame = true,
		CreateScaleAnimation = true,
		DoNameplateAnimation = true,
		RefreshIsEditingAnimations = true,
		IsNpcInIgnoreList = true,
		CanChangePlateSize = true,
		RefreshOmniCCGroup = true,
		CreatePlaterButtonAtInterfaceOptions = true,
		SetCVarsOnFirstRun = true,
		GetActorSubName = true,
		QuestLogUpdated = true,
		QuestLogUpdated = true,
		GetNpcIDFromGUID = true,
		GetNpcID = true,
		ForceTickOnAllNameplates = true,
		UpdateUIParentScale = true,
		UpdateUIParentLevels = true,
		UpdateUIParentTargetLevels = true,
		RefreshTankCache = true,
		ForceFindPetOwner = true,
	}
	
	local functionFilter = setmetatable ({}, {__index = function (env, key)
		if (key == "_G") then
			return env
			
		elseif (blockedFunctions [key] or privateFunctions [key]) then
			return nil
			
		else	
			return _G [key]
		end
	end})	

	function Plater.WipeAndRecompileAllScripts (scriptType, noHotReload)
		if (scriptType == "script") then
			table.wipe (SCRIPT_AURA)
			table.wipe (SCRIPT_CASTBAR)
			table.wipe (SCRIPT_UNIT)
			Plater.CompileAllScripts (scriptType, noHotReload)
			
		elseif (scriptType == "hook") then
			Plater.WipeHookContainers (noHotReload)
			Plater.CompileAllScripts (scriptType, noHotReload)
		end
	end

	Plater.AllHookGlobalContainers = {
		HOOK_NAMEPLATE_CREATED,
		HOOK_NAMEPLATE_ADDED,
		HOOK_NAMEPLATE_REMOVED,
		HOOK_NAMEPLATE_UPDATED,
		HOOK_TARGET_CHANGED,
		HOOK_CAST_START,
		HOOK_CAST_UPDATE,
		HOOK_CAST_STOP,
		HOOK_RAID_TARGET,
		HOOK_COMBAT_ENTER,
		HOOK_COMBAT_LEAVE,
		HOOK_NAMEPLATE_CONSTRUCTOR,
		HOOK_PLAYER_POWER_UPDATE,
		HOOK_PLAYER_TALENT_UPDATE,
		HOOK_HEALTH_UPDATE,
		HOOK_ZONE_CHANGED,
		HOOK_UNITNAME_UPDATE,
		HOOK_LOAD_SCREEN,
		HOOK_PLAYER_LOGON,
		HOOK_MOD_INITIALIZATION
	}

	function Plater.WipeHookContainers (noHotReload)
		Plater.IncreaseHookBuildID()
		
		for _, container in ipairs (Plater.AllHookGlobalContainers) do
			if (not noHotReload) then
				for _, globalScriptObject in ipairs (container) do
					globalScriptObject.NeedHotReload = true
				end
			end
			table.wipe (container)
			container.ScriptAmount = 0
		end
	end

	function Plater.GetContainerForHook (hookName)
		if (hookName == "Initialization") then
			return HOOK_MOD_INITIALIZATION	
		elseif (hookName == "Constructor") then
			return HOOK_NAMEPLATE_CONSTRUCTOR	
		elseif (hookName == "Nameplate Created") then
			return HOOK_NAMEPLATE_CREATED
		elseif (hookName == "Nameplate Added") then
			return HOOK_NAMEPLATE_ADDED
		elseif (hookName == "Nameplate Removed") then
			return HOOK_NAMEPLATE_REMOVED
		elseif (hookName == "Nameplate Updated") then
			return HOOK_NAMEPLATE_UPDATED	
		elseif (hookName == "Target Changed") then
			return HOOK_TARGET_CHANGED
		elseif (hookName == "Cast Start") then
			return HOOK_CAST_START
		elseif (hookName == "Cast Update") then
			return HOOK_CAST_UPDATE
		elseif (hookName == "Cast Stop") then
			return HOOK_CAST_STOP
		elseif (hookName == "Raid Target") then
			return HOOK_RAID_TARGET
		elseif (hookName == "Enter Combat") then
			return HOOK_COMBAT_ENTER
		elseif (hookName == "Leave Combat") then
			return HOOK_COMBAT_LEAVE
		elseif (hookName == "Player Power Update") then
			return HOOK_PLAYER_POWER_UPDATE	
		elseif (hookName == "Player Talent Update") then
			return HOOK_PLAYER_TALENT_UPDATE
		elseif (hookName == "Health Update") then
			return HOOK_HEALTH_UPDATE
		elseif (hookName == "Zone Changed") then
			return HOOK_ZONE_CHANGED	
		elseif (hookName == "Name Updated") then	
			return HOOK_UNITNAME_UPDATE
		elseif (hookName == "Load Screen") then
			return HOOK_LOAD_SCREEN	
		elseif (hookName == "Player Logon") then
			return HOOK_PLAYER_LOGON
		else
			Plater:Msg ("Unknown hook: " .. (hookName or "Invalid Hook Name"))
		end
	end

	--store the names of hooks that passed the filters
	Plater.CurrentlyLoadedHooks = {}
	--store global objects of hooks with destructors, key is the script object, value is the global object
	Plater.DestructorScriptHooks = {}

	function Plater.RunDestructorForHook (scriptObject)
		--check if the script has a destructor script
		if (scriptObject.Hooks ["Destructor"]) then
			--load and compile the destructor code
			
			local compiledScript, errortext = loadstring ("return " .. scriptObject.Hooks ["Destructor"], "Destructor for " .. scriptObject.Name)
			if (not compiledScript) then
				Plater:Msg ("failed to compile destructor for script " .. scriptObject.Name .. ": " .. errortext)
			else
				--store the function to execute
				setfenv (compiledScript, functionFilter)
				local func = compiledScript()
				
				--iterate among all nameplates
				for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
					if (plateFrame) then
						
						local globalScriptObject = Plater.DestructorScriptHooks [scriptObject]
						local unitFrame = plateFrame.unitFrame
						local scriptContainer = unitFrame:ScriptGetContainer()
						local scriptInfo = unitFrame:ScriptGetInfo (globalScriptObject, scriptContainer, "Destructor")

						local okay, errortext = pcall (func, unitFrame, unitFrame.displayedUnit, unitFrame, scriptInfo.Env)
						if (not okay) then
							Plater:Msg ("Mod: |cFFAAAA22" .. scriptInfo.GlobalScriptObject.DBScriptObject.Name .. "|r " .. scriptObject.Name .. " error: " .. errortext)
						end
					end
				end
			end		
		end
	end
	
	--compile scripts from the Hooking tab
	function Plater.CompileHook (scriptObject)
		
		--check if the script is valid and if is enabled
		if (not scriptObject) then
			return
			
		elseif (not scriptObject.Enabled) then
			--check if this hook is currently loaded
			if (Plater.CurrentlyLoadedHooks [scriptObject]) then
				Plater.CurrentlyLoadedHooks [scriptObject] = false
				Plater.RunDestructorForHook (scriptObject)
			end
			return
		end
		
		do --check integrity
			if (not scriptObject.Name) then
				Plater:Msg ("fail to load mod: " .. (scriptObject.Name or "") .. ".")
				return
			end

			if (not scriptObject.LoadConditions) then
				Plater:Msg ("fail to load mod: " .. (scriptObject.Name or "") .. ".")
				return
			end
			
			if (
				not scriptObject.LoadConditions.class or
				not scriptObject.LoadConditions.spec or
				not scriptObject.LoadConditions.race or
				not scriptObject.LoadConditions.talent or
				not scriptObject.LoadConditions.pvptalent or
				not scriptObject.LoadConditions.group or
				not scriptObject.LoadConditions.role or
				not scriptObject.LoadConditions.affix or
				not scriptObject.LoadConditions.encounter_ids or
				not scriptObject.LoadConditions.map_ids
			) then
				Plater:Msg ("fail to load mod: " .. (scriptObject.Name or "") .. ".")
				return
			end

			if (not scriptObject.Hooks) then
				Plater:Msg ("fail to load mod: " .. (scriptObject.Name or "") .. ".")
				return
			end
		end
		
		--check if can load this hook
		if (not DF:PassLoadFilters (scriptObject.LoadConditions, Plater.EncounterID)) then
			--check if this hook is currently loaded
			if (Plater.CurrentlyLoadedHooks [scriptObject]) then
				Plater.CurrentlyLoadedHooks [scriptObject] = false
				Plater.RunDestructorForHook (scriptObject)
			end
			return
		else
			Plater.CurrentlyLoadedHooks [scriptObject] = true
		end
		
		--store the scripts to be compiled
		local scriptCode = {}
		
		--get scripts from the object
		for hookName, code in pairs (scriptObject.Hooks) do
			scriptCode [hookName] = "return " .. code
		end
		
		--get or create the global script object
		local globalScriptObject = {
			HotReload = -1,
			DBScriptObject = scriptObject,
			Build = PLATER_HOOK_BUILD,
		}
		
		--init modEnv if necessary
		local needsInitCall = false
		if not PLATER_GLOBAL_MOD_ENV [scriptObject.Name] then
			needsInitCall = true
			PLATER_GLOBAL_MOD_ENV [scriptObject.Name] = {}
		end
		
		--compile
		for hookName, code in pairs (scriptCode) do
			
			if (type (code) ~= "string") then
				Plater:Msg ("fail to load mod: " .. (scriptObject.Name or "") .. ".")
				return
			end
			
			local compiledScript, errortext = loadstring (code, "" .. hookName .. " for " .. scriptObject.Name)
			if (not compiledScript) then
				Plater:Msg ("failed to compile " .. hookName .. " for script " .. scriptObject.Name .. ": " .. errortext)
			else
				if (hookName == "Destructor") then
					Plater.DestructorScriptHooks [scriptObject] = globalScriptObject
				else
					--store the function to execute inside the global script object
					setfenv (compiledScript, functionFilter)
					globalScriptObject [hookName] = compiledScript()
					
					--insert the script in the global script container, no need to check if already exists, hook containers cache are cleaned before script compile
					local globalScriptContainer = Plater.GetContainerForHook (hookName)
					tinsert (globalScriptContainer, globalScriptObject)
					globalScriptContainer.ScriptAmount = globalScriptContainer.ScriptAmount + 1
					
					if (hookName == "Constructor") then
						globalScriptObject.HasConstructor = true
					elseif (hookName == "Initialization") and needsInitCall then
						Plater.ScriptMetaFunctions.ScriptRunNoAttach (globalScriptObject, "Initialization")
					end
				end
			end
		end
		
	end

	--compile scripts from the Scripting tab
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
			-- ensure init is filled always
			if (not scriptObject [scriptType] and i == 5) then
				scriptObject [scriptType] = [=[
					function (scriptTable)
						--insert code here
						
					end
				]=]	
			end
			if (not scriptCode [scriptType]) then
				scriptCode [scriptType] = "return " .. scriptObject [scriptType]
			end
		end
		
		--init modEnv if necessary
		local needsInitCall = false
		if not PLATER_GLOBAL_SCRIPT_ENV [scriptObject.Name] then
			needsInitCall = true
			PLATER_GLOBAL_SCRIPT_ENV [scriptObject.Name] = {}
		end

		--compile
		for scriptType, code in pairs (scriptCode) do
			local compiledScript, errortext = loadstring (code, "" .. scriptType .. " for " .. scriptObject.Name)
			if (not compiledScript) then
				Plater:Msg ("failed to compile " .. scriptType .. " for script " .. scriptObject.Name .. ": " .. errortext)
			else
				--get the function to execute
				setfenv (compiledScript, functionFilter)
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
				
				--add the script functions to the global object table
				for scriptType, func in pairs (scriptFunctions) do
					globalScriptObject [scriptType] = func
				end
				
				--run initialization (once)
				if needsInitCall then
					Plater.ScriptMetaFunctions.ScriptRunInitialization(globalScriptObject)
					needsInitCall = false
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
		for index, scriptObject in ipairs (Plater.GetAllScripts ("script")) do
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
	function Plater.GetScriptObject (scriptID, scriptType)
		if (scriptType == "script") then
			local script = Plater.db.profile.script_data [scriptID]
			if (script) then
				return script
			end
			
		elseif (scriptType == "hook") then
			local script = Plater.db.profile.hook_data [scriptID]
			if (script) then
				return script
			end

		end
	end

	--return the main db table for the script type
	function Plater.GetScriptDB (scriptType)
		if (scriptType == "script") then
			return Plater.db.profile.script_data
			
		elseif (scriptType == "hook") then
			return Plater.db.profile.hook_data
		end
	end

	--if the type of a scriptObject is unknown
	function Plater.GetScriptType (scriptObject)
		if (scriptObject.Hooks) then
			return "hook"
		elseif (scriptObject.SpellIds) then
			return "script"
		end
	end

	--an indexScriptTable is a table decoded from an imported string, Plater uses this table to build an scriptObject
	--check the type of indexes in the indexScriptTable to determine which type of script is this
	--this is done to avoid sending an extra index just to tell which type of script is the string
	function Plater.GetDecodedScriptType (indexScriptTable)
		if (type (indexScriptTable [9]) == "table") then --hook
			return "hook"
		elseif (type (indexScriptTable [9]) == "number") then --script
			return "script"
		end
	end

	--import scripts from the library
	--autoImportScript is a table holding the revision number, the string to import and the type of script
	function Plater.ImportScriptsFromLibrary()
		if (PlaterScriptLibrary) then
			for name, autoImportScript in pairs (PlaterScriptLibrary) do
				local importedDB
				
				if (autoImportScript.ScriptType == "script") then
					importedDB = Plater.db.profile.script_auto_imported
					
				elseif (autoImportScript.ScriptType == "hook") then
					importedDB = Plater.db.profile.hook_auto_imported
				end
				
				if ((importedDB [name] or 0) < autoImportScript.Revision) then
					importedDB [name] = autoImportScript.Revision

					local encodedString = autoImportScript.String
					if (encodedString) then
						local success, scriptAdded = Plater.ImportScriptString (encodedString, true, false, false)
						if (success) then
							if (autoImportScript.Revision == 1) then
								Plater:Msg ("New Script Installed: " .. name)
							else
								Plater:Msg ("Applied Update to Script: " .. name)
							end
							
							--all scripts imported are enabled by default, if the import object has a enabled member, probably its value is false
							if (type (autoImportScript.Enabled) == "boolean") then
								scriptAdded.Enabled = autoImportScript.Enabled
							end
						end
					end
				end
			end
			
			--can't wipe because it need to be reused when a new profile is created
			--table.wipe (PlaterScriptLibrary)
		end
	end

	--import a string from any source with more options than the convencional importer
	--this is used when importing scripts from the library and when the user inserted the wrong script type in the import box at hook or script, e.g. imported a hook in the script import box
	--guarantee to always receive a 'print' type of encode
	function Plater.ImportScriptString (text, ignoreRevision, overrideTriggers, showDebug)
		if (not text or type (text) ~= "string") then
			return
		end
		
		local errortext, objectAdded
		
		local indexScriptTable = Plater.DecompressData (text, "print")
		if (indexScriptTable and type (indexScriptTable) == "table") then

			--get the script type, if is a hook or regular script
			local scriptType = Plater.GetDecodedScriptType (indexScriptTable)
			local newScript = Plater.BuildScriptObjectFromIndexTable (indexScriptTable, scriptType)
			
			if (newScript) then
			
				if (scriptType == "script") then
					local scriptName = newScript.Name
					local alreadyExists = false
					local scriptDB = Plater.GetScriptDB (scriptType)
					
					for i = 1, #Plater.db.profile.script_data do
						local scriptObject = scriptDB [i]
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
							
							--add to the new script object, triggers that the current script has, since the user might have added some
							if (not overrideTriggers) then
								if (newScript.ScriptType == 0x1 or newScript.ScriptType == 0x2) then
									--aura or cast trigger
									for index, trigger in ipairs (scriptObject.SpellIds) do
										DF.table.addunique (newScript.SpellIds, trigger)
									end
								else
									--npc trigger
									for index, trigger in ipairs (scriptObject.NpcNames) do
										DF.table.addunique (newScript.SpellIds, trigger)
									end
								end
							end
							
							--keep the enabled state
							newScript.Enabled = scriptObject.Enabled
							
							--replace the old script with the new one
							tremove (scriptDB, i)
							tinsert (scriptDB, i, newScript)
							objectAdded = newScript
							
							if (showDebug) then
								Plater:Msg ("Script replaced by a newer one.")
							end
							
							alreadyExists = true
							break
						end
					end
					
					if (not alreadyExists) then
						tinsert (scriptDB, newScript)
						objectAdded = newScript
						if (showDebug) then
							Plater:Msg ("Script added.")
						end
					end
					
				elseif (scriptType == "hook") then
					
					local scriptName = newScript.Name
					local alreadyExists = false
					local scriptDB = Plater.GetScriptDB (scriptType)
					
					for i = 1, #Plater.db.profile.hook_data do
						local scriptObject = scriptDB [i]
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
							
							--keep the enabled state
							newScript.Enabled = scriptObject.Enabled
							
							--replace the old script with the new one
							tremove (scriptDB, i)
							tinsert (scriptDB, i, newScript)
							objectAdded = newScript
							
							if (showDebug) then
								Plater:Msg ("Script replaced by a newer one.")
							end
							
							alreadyExists = true
							break
						end
					end
					
					if (not alreadyExists) then
						tinsert (scriptDB, newScript)
						objectAdded = newScript
						if (showDebug) then
							Plater:Msg ("Script added.")
						end
					end

				end
			else
				--check if the user in importing a profile in the scripting tab
				if (indexScriptTable.plate_config) then
					DF:ShowErrorMessage ("Invalid Script or Mod.\n\nImport profiles at the Profiles tab.")
				end
				errortext = "Cannot import: data imported is invalid"
			end
		else
			
			errortext = "Cannot import: data imported is invalid"
		end
		
		if (errortext and showDebug) then
			Plater:Msg (errortext)
			return false
		end
		
		return true, objectAdded
	end

	--add a scriptObject to the script db
	--if noOverwrite is passed, it won't replace if a script with the same name already exists
	function Plater.AddScript (scriptObjectToAdd, noOverwrite)
		if (scriptObjectToAdd) then
			local indexToReplace
			local scriptType = Plater.GetScriptType (scriptObjectToAdd)
			local scriptDB = Plater.GetScriptDB (scriptType)
			
			--check if already exists
			for i = 1, #scriptDB do
				local scriptObject = scriptDB [i]
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
				tremove (scriptDB, indexToReplace)
				tinsert (scriptDB, indexToReplace, scriptObjectToAdd)
			else
				--add the new script to the end of the table
				tinsert (scriptDB, scriptObjectToAdd)
			end
		end
	end

	--get a index table from an imported string and build a scriptObject from it
	function Plater.BuildScriptObjectFromIndexTable (indexTable, scriptType)
		
		if (scriptType == "hook") then
			local scriptObject = {}
			scriptObject.Enabled 		= true --imported scripts are always enabled
			scriptObject.Name		= indexTable [1]
			scriptObject.Icon			= indexTable [2]
			scriptObject.Desc		= indexTable [3]
			scriptObject.Author		= indexTable [4]
			scriptObject.Time			= indexTable [5]
			scriptObject.Revision		= indexTable [6]
			scriptObject.PlaterCore		= indexTable [7]
			scriptObject.LoadConditions	= indexTable [8]

			scriptObject.Hooks = {}
			scriptObject.HooksTemp = {}
			scriptObject.LastHookEdited = ""
			
			for hookName, hookCode in pairs (indexTable [9]) do
				scriptObject.Hooks [hookName] = hookCode
			end
			
			return scriptObject
			
		elseif (scriptType == "script") then
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
	end

	--transform the string into a indexScriptTable and then transform it into a scriptObject
	function Plater.DecodeImportedString (str)
		local LibAceSerializer = LibStub:GetLibrary ("AceSerializer-3.0")
		if (LibAceSerializer) then
			-- ~zip
			local decoded = DF.DecodeString (str)
			if (decoded) then
				local unSerializedOkay, indexScriptTable = LibAceSerializer:Deserialize (decoded)
				if (unSerializedOkay and type (indexScriptTable) == "table") then
					local scriptObject = Plater.BuildScriptObjectFromIndexTable (indexScriptTable, Plater.GetDecodedScriptType (indexScriptTable))
					if (scriptObject) then
						return scriptObject
					end
				end
			end
		end
	end

	--make an indexScriptTable for the script object using indexes instead of key to decrease the size of the string to be exported
	function Plater.PrepareTableToExport (scriptObject)
		
		if (scriptObject.Hooks) then
			--script for hooks
			local t = {}
			
			t [1] = scriptObject.Name
			t [2] = scriptObject.Icon
			t [3] = scriptObject.Desc
			t [4] = scriptObject.Author
			t [5] = scriptObject.Time
			t [6] = scriptObject.Revision
			t [7] = scriptObject.PlaterCore
			t [8] = scriptObject.LoadConditions
			t [9] = {}

			for hookName, hookCode in pairs (scriptObject.Hooks) do
				t [9] [hookName] = hookCode
			end
			
			return t
		else
			--regular script for aura cast or unitID
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
	end

	function Plater.ScriptReceivedFromGroup (prefix, playerName, playerRealm, playerGUID, importedString)
		if (not Plater.db.profile.script_banned_user [playerGUID]) then
			
			local indexScriptTable = Plater.DecompressData (importedString, "comm")
			if (indexScriptTable and type (indexScriptTable) == "table") then
			
				local importedScriptObject = Plater.BuildScriptObjectFromIndexTable (indexScriptTable, Plater.GetDecodedScriptType (indexScriptTable))
				if (not importedScriptObject) then
					return
				end

				local scriptName = importedScriptObject.Name
				local alreadyExists = false
				local alreadyExistsVersion = 0
				
				local scriptType = Plater.GetScriptType (importedScriptObject)
				local scriptDB = Plater.GetScriptDB (scriptType)

				for i = 1, #scriptDB do
					local scriptObject = scriptDB [i]
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

	function Plater.ExportScriptToGroup (scriptId, scriptType)
		local scriptToSend = Plater.GetScriptObject (scriptId, scriptType)
		
		if (not scriptToSend) then
			Plater:Msg ("script not found", scriptId)
			return
		end
		
		--convert hash table to index table for smaller size
		local indexedScriptTable = Plater.PrepareTableToExport (scriptToSend)
		--compress the indexed table for WoWAddonChannel
		local encodedString = Plater.CompressData (indexedScriptTable, "comm")
		
		if (encodedString) then
			
			local LibAceSerializer = LibStub:GetLibrary ("AceSerializer-3.0")
			
			if (IsInRaid (LE_PARTY_CATEGORY_HOME)) then
				Plater:SendCommMessage (COMM_PLATER_PREFIX, LibAceSerializer:Serialize (COMM_SCRIPT_GROUP_EXPORTED, UnitName ("player"), GetRealmName(), UnitGUID ("player"), encodedString), "RAID")
				
			elseif (IsInGroup (LE_PARTY_CATEGORY_HOME)) then
				Plater:SendCommMessage (COMM_PLATER_PREFIX, LibAceSerializer:Serialize (COMM_SCRIPT_GROUP_EXPORTED, UnitName ("player"), GetRealmName(), UnitGUID ("player"), encodedString), "PARTY")
				
			else
				Plater:Msg ("Failed to send the script: your group isn't home group.")
			end
		else
			Plater:Msg ("Fail to encode scriptId", scriptId)
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

	function Plater.DispatchTalentUpdateHookEvent()
		if (HOOK_PLAYER_TALENT_UPDATE.ScriptAmount > 0) then
			for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
				if (plateFrame) then
					for i = 1, HOOK_PLAYER_TALENT_UPDATE.ScriptAmount do
						local globalScriptObject = HOOK_PLAYER_TALENT_UPDATE [i]
						local unitFrame = plateFrame.unitFrame
						local scriptContainer = unitFrame:ScriptGetContainer()
						local scriptInfo = unitFrame:ScriptGetInfo (globalScriptObject, scriptContainer, "Player Talent Update")
						--run
						unitFrame:ScriptRunHook (scriptInfo, "Player Talent Update")
					end
				end
			end
		end
	end

	function Plater.ScheduleHookForCombat (timerObject)
		if (timerObject.Event == "Enter Combat") then
			if (HOOK_COMBAT_ENTER.ScriptAmount > 0) then
				for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
					for i = 1, HOOK_COMBAT_ENTER.ScriptAmount do
						local globalScriptObject = HOOK_COMBAT_ENTER [i]
						local unitFrame = plateFrame.unitFrame
						local scriptContainer = unitFrame:ScriptGetContainer()
						local scriptInfo = unitFrame:ScriptGetInfo (globalScriptObject, scriptContainer, "Enter Combat")
						--run
						unitFrame:ScriptRunHook (scriptInfo, "Enter Combat")
					end
				end
			end
			
		elseif (timerObject.Event == "Leave Combat") then
			if (HOOK_COMBAT_LEAVE.ScriptAmount > 0) then
				for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
					for i = 1, HOOK_COMBAT_LEAVE.ScriptAmount do
						local globalScriptObject = HOOK_COMBAT_LEAVE [i]
						local unitFrame = plateFrame.unitFrame
						local scriptContainer = unitFrame:ScriptGetContainer()
						local scriptInfo = unitFrame:ScriptGetInfo (globalScriptObject, scriptContainer, "Leave Combat")
						--run
						unitFrame:ScriptRunHook (scriptInfo, "Leave Combat")
					end
				end
			end
		end
	end	
	
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> slash commands ~slash
	
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
				alphaUnitFrame = plateFrame.unitFrame:GetAlpha()
				alphaHealthFrame = plateFrame.unitFrame.healthBar:GetAlpha()
				break
			end
		end
		
		print ("|cFFC0C0C0Alpha|r", "->", alphaPlateFrame, "-", alphaUnitFrame, "-", alphaHealthFrame)
	
		if (testPlate) then
			local w, h = testPlate:GetSize()
			print ("|cFFC0C0C0Size|r", "->", w, h, "-", testPlate.unitFrame.healthBar:GetSize())
			
			local point1, anchorFrame, point2, x, y = testPlate:GetPoint (1)
			print ("|cFFC0C0C0Point|r", "->", point1, anchorFrame:GetName(), point2, x, y)
			
			local plateIsShown = testPlate:IsShown() and "yes" or "no"
			local unitFrameIsShown = testPlate.unitFrame:IsShown() and "yes" or "no"
			local healthBarIsShown = testPlate.unitFrame.healthBar:IsShown() and "yes" or "no"
			print ("|cFFC0C0C0ShownStatus|r", "->", plateIsShown, "-", unitFrameIsShown, "-", healthBarIsShown)
		else
			print ("|cFFC0C0C0Size|r", "-> there's no nameplate in the screen")
			print ("|cFFC0C0C0Point|r", "-> there's no nameplate in the screen")
			print ("|cFFC0C0C0ShownStatus|r", "-> there's no nameplate in the screen")
		end
	
		return
	
	elseif (msg == "color" or msg == "colors") then
		Plater.OpenColorFrame()
		return
	
	elseif (msg == "npcs" or msg == "ids") then
		

		
	elseif (msg == "add" or msg == "addnpc") then
		
		local plateFrame = C_NamePlate.GetNamePlateForUnit ("target")
		
		if (plateFrame) then
			local npcId = plateFrame [MEMBER_NPCID]
			if (npcId) then
				local colorDB = Plater.db.profile.npc_colors
				if (not colorDB [npcId]) then
					Plater.db.profile.npc_cache [npcId] = {plateFrame [MEMBER_NAME], Plater.ZoneName}
					Plater:Msg ("Unit added.")
					
					if (PlaterOptionsPanelFrame and PlaterOptionsPanelFrame:IsShown()) then
						PlaterOptionsPanelContainerColorManagementColorsScroll:Hide()
						C_Timer.After (.2, function()
							PlaterOptionsPanelContainerColorManagementColorsScroll:Show()
						end)
					end
					
				else
					Plater:Msg ("Unit already added.")
				end
			else
				Plater:Msg ("Invalid npc nameplate.")
			end
		else
			Plater:Msg ("you need to target a npc or the npc nameplate couldn't be found.")
		end
	
		return
	end
	
	Plater.OpenOptionsPanel()
end



--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> debuggers ~debug

	function Plater.DebugColorAnimation()
		if (Plater.DebugColorAnimation_Timer) then
			return
		end

		Plater.DebugColorAnimation_Timer = C_Timer.NewTicker (0.5, function() --~animationtest
			for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
				--make the bar jump from green to pink - pink to green
				Plater.ChangeHealthBarColor_Internal (plateFrame.unitFrame.healthBar, math.abs (math.sin (GetTime())), math.abs (math.cos (GetTime())), math.abs (math.sin (GetTime())))
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
	
	function Plater.DebugHealthAnimation()
		if (Plater.DebugHealthAnimation_Timer) then
			return
		end

		Plater.DebugHealthAnimation_Timer = C_Timer.NewTicker (1.5, function() --~animationtest
			for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
				local self = plateFrame.unitFrame
				
				if (self.healthBar.CurrentHealth == 0) then
					self.healthBar.AnimationStart = 0
					self.healthBar.AnimationEnd = UnitHealthMax (self [MEMBER_UNITID])
				else
					self.healthBar.AnimationStart = UnitHealthMax (self [MEMBER_UNITID])
					self.healthBar.AnimationEnd = 0
				end
				
				self.healthBar:SetValue (self.healthBar.CurrentHealth)
				self.healthBar.CurrentHealthMax = UnitHealthMax (self [MEMBER_UNITID])
				
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

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> color frame
function Plater.OpenColorFrame()
	if (PlaterColorPreview) then
		PlaterColorPreview:Show()
		return
	end
	
	local function hex (num)
		local hexstr = '0123456789abcdef'
		local s = ''
		while num > 0 do
			local mod = math.fmod(num, 16)
			s = string.sub(hexstr, mod+1, mod+1) .. s
			num = math.floor(num / 16)
		end
		if s == '' then s = '00' end
		if (string.len (s) == 1) then
			s = "0"..s
		end
		return s
	end
	
	local a = CreateFrame ("frame", "PlaterColorPreview", UIParent)
	a:SetSize (1400, 910)
	a:SetPoint ("topleft", UIParent, "topleft")
	
	--close button
	local closeButton = DF:CreateButton (a, function() a:Hide() end, 160, 20, "", -1, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"))
	closeButton:SetPoint ("topright", a, "topright", -1, 0)
	closeButton:SetText ("Close Color Palette")
	
	DF:ApplyStandardBackdrop (a)
	
	local onFocusGained = function (self)
		self:HighlightText (0)
	end
	local onFocusLost = function (self)
		self:HighlightText (0, 0)
	end
	
	local allColors = {}
	for colorName, colorTable in pairs (DF.alias_text_colors) do
		tinsert (allColors, {colorTable, colorName, hex (colorTable[1]*255) .. hex (colorTable[2]*255) .. hex (colorTable[3]*255)})
	end
	
	table.sort (allColors, function (t1, t2)
		return t1[1][3] > t2[1][3]
	end)
	
	local x = 5
	local y = -20
	local totalWidth = 105
	
	--for colorname, colortable in pairs (DF.alias_text_colors) do
	
	for index, colorTable in ipairs (allColors) do
		local colortable = colorTable [1]
		local colorname = colorTable [2]
	
		local backgroundTexture = a:CreateTexture (nil, "overlay")
		backgroundTexture:SetColorTexture (unpack (colortable))
		backgroundTexture:SetSize (100, 20)
		backgroundTexture:SetPoint ("topleft", a, "topleft", x, y)
		
		local textEntry = DF:CreateTextEntry (a, function()end, 100, 20)
		textEntry:SetBackdrop (nil)
		textEntry:SetPoint ("topleft", backgroundTexture, "topleft", 0, 0)
		textEntry:SetPoint ("bottomright", backgroundTexture, "bottomright", 0, 0)
		textEntry:SetText (colorname)
		textEntry:SetHook ("OnEditFocusGained", onFocusGained)
		textEntry:SetHook ("OnEditFocusLost", onFocusLost)
		
		y = y - 20
		if (y < -880) then
			y = -20
			x = x + 105
			totalWidth = totalWidth + 105
		end
	end
	
	a:SetWidth (totalWidth)
end

--functiona enda
