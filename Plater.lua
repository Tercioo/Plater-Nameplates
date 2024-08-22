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

-- update localization

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

--> locals
local unpack = unpack
local ipairs = ipairs
local rawset = rawset
--local rawget = rawget --200 locals limit
--local setfenv = setfenv --200 locals limit
local xpcall = xpcall
local InCombatLockdown = InCombatLockdown
local UnitIsPlayer = UnitIsPlayer
local UnitClassification = UnitClassification
local UnitDetailedThreatSituation = UnitDetailedThreatSituation
local UnitCanAttack = UnitCanAttack
--local IsSpellInRange = IsSpellInRange --200 locals limit
local abs = math.abs
local format = string.format
local GetSpellInfo = GetSpellInfo or function(spellID) if not spellID then return nil end local si = C_Spell.GetSpellInfo(spellID) if si then return si.name, nil, si.iconID, si.castTime, si.minRange, si.maxRange, si.spellID, si.originalIconID end end
local UnitIsUnit = UnitIsUnit
local type = type
local select = select
local UnitGUID = UnitGUID
local strsplit = strsplit
local lower = string.lower
local floor = floor
local max = math.max
local min = math.min

local IS_WOW_PROJECT_MAINLINE = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
local IS_WOW_PROJECT_NOT_MAINLINE = WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE
local IS_WOW_PROJECT_CLASSIC_ERA = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
local IS_WOW_PROJECT_CLASSIC_WRATH = IS_WOW_PROJECT_NOT_MAINLINE and ClassicExpansionAtLeast and LE_EXPANSION_WRATH_OF_THE_LICH_KING and ClassicExpansionAtLeast(LE_EXPANSION_WRATH_OF_THE_LICH_KING)
--local IS_WOW_PROJECT_CLASSIC_CATACLYSM = IS_WOW_PROJECT_NOT_MAINLINE and ClassicExpansionAtLeast and LE_EXPANSION_CATACLYSM and ClassicExpansionAtLeast(LE_EXPANSION_CATACLYSM)

local PixelUtil = PixelUtil or DFPixelUtil

local parserFunctions --reference needed

local LibSharedMedia = LibStub:GetLibrary ("LibSharedMedia-3.0") -- https://www.curseforge.com/wow/addons/libsharedmedia-3-0
local LCG = LibStub:GetLibrary("LibCustomGlow-1.0") -- https://github.com/Stanzilla/LibCustomGlow
local LibRangeCheck = LibStub:GetLibrary ("LibRangeCheck-3.0") -- https://github.com/WeakAuras/LibRangeCheck-3.0
local LibTranslit = LibStub:GetLibrary ("LibTranslit-1.0") -- https://github.com/Vardex/LibTranslit
local LDB = LibStub ("LibDataBroker-1.1", true)
local LDBIcon = LDB and LibStub ("LibDBIcon-1.0", true)

local addonId, platerInternal = ...
local _ = nil

--localization
local LOC = DF.Language.GetLanguageTable(addonId)

---@type plater
local Plater = DF:CreateAddOn ("Plater", "PlaterDB", PLATER_DEFAULT_SETTINGS, InterfaceOptionsFrame and { --options table --TODO: DISABLED FOR DRAGONFLIGHT FOR NOW!
	name = "Plater Nameplates",
	type = "group",
	args = {
		openOptions = {
			name = "Open Plater Options",
			desc = "Opens the Plater Options Menu.",
			type = "execute",
			func = function()
				if InterfaceOptionsFrame then
					InterfaceOptionsFrame:Hide()
				elseif SettingsPanel then
					SettingsPanel:Hide()
				end
				HideUIPanel(GameMenuFrame)
				Plater.OpenOptionsPanel()
			end,
		},
	}
})
local GetAddOnMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
Plater.versionString = GetAddOnMetadata("Plater", "Version")
Plater.fullVersionInfo = Plater.versionString .. " - DF v" .. select(2,LibStub:GetLibrary("DetailsFramework-1.0")) .. " - " .. GetBuildInfo()
function Plater.GetVersionInfo(printOut)
	-- update, just in case...
	Plater.versionString = GetAddOnMetadata("Plater", "Version")
	Plater.fullVersionInfo = Plater.versionString .. " - DF v" .. select(2,LibStub:GetLibrary("DetailsFramework-1.0")) .. " - " .. GetBuildInfo()
	if printOut then print("Plater version info:\n" .. Plater.fullVersionInfo) end
	return Plater.fullVersionInfo
end

--> when a hook script is compiled, it increases the build version, so the handler for running scripts will notice in the change and update the script in real time
local PLATER_HOOK_BUILD = 1
function Plater.IncreaseHookBuildID() --private
	PLATER_HOOK_BUILD = PLATER_HOOK_BUILD + 1
end

--> if a widget has a RefreshID lower than the addon, it needs to be updated
local PLATER_REFRESH_ID = 1
function Plater.IncreaseRefreshID() --private
	PLATER_REFRESH_ID = PLATER_REFRESH_ID + 1
	Plater.IncreaseRefreshID_Auras()
end

platerInternal.CreateDataTables(Plater)

Plater.ForceBlizzardNameplateUnits = {
	--
}
Plater.AddForceBlizzardNameplateUnits = function(npcID)
	if type(npcID) == "number" then
		Plater.ForceBlizzardNameplateUnits[npcID] = true
	end
end
Plater.RemoveForceBlizzardNameplateUnits = function(npcID)
	if type(npcID) == "number" then
		Plater.ForceBlizzardNameplateUnits[npcID] = nil
	end
end

--store npc names and spell names from the current/latest combat
--used to sort data in the options panel: Spell List, Spell Colors and Npc Colors
Plater.LastCombat = {
	npcNames = {},
	spellNames = {},
}

Plater.MDTSettings = {
	button_width = 18, --button and icon width
	button_height = 18,
	enemyinfo_button_point = {"topright", "topright", 4.682, -21.361},
	spellinfo_button_point = {"bottomright", "bottomright", -12, 2},
	icon_texture = [[Interface\Buttons\UI-Panel-BiggerButton-Up]],
	icon_coords = {0.2, 0.8, 0.2, 0.8},
	alpha = 0.834, --button alpha
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
local HOOK_MOD_DEINITIALIZATION = {ScriptAmount = 0}
local HOOK_COMM_RECEIVED_MESSAGE = {ScriptAmount = 0}
local HOOK_COMM_SEND_MESSAGE = {ScriptAmount = 0}
local HOOK_OPTION_CHANGED = {ScriptAmount = 0}
local HOOK_MOD_OPTION_CHANGED = {ScriptAmount = 0}
local HOOK_NAMEPLATE_DESTRUCTOR = {ScriptAmount = 0}

platerInternal.HOOK_MOD_OPTION_CHANGED = HOOK_MOD_OPTION_CHANGED --triggered from Plater.ScriptingOptions.lua

local PLATER_GLOBAL_MOD_ENV = {}  -- contains modEnv for each mod, identified by "<mod name>"
local PLATER_GLOBAL_SCRIPT_ENV = {} -- contains modEnv for each script, identified by "<script name>"

--> cvars just to make them easier to read
local CVAR_ENABLED = "1"
local CVAR_DISABLED = "0"

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

local class_specs_coords = {
	[577] = {128/512, 192/512, 256/512, 320/512}, --> havoc demon hunter
	[581] = {192/512, 256/512, 256/512, 320/512}, --> vengeance demon hunter

	[250] = {0, 64/512, 0, 64/512}, --> blood dk
	[251] = {64/512, 128/512, 0, 64/512}, --> frost dk
	[252] = {128/512, 192/512, 0, 64/512}, --> unholy dk
	
	[102] = {192/512, 256/512, 0, 64/512}, -->  druid balance
	[103] = {256/512, 320/512, 0, 64/512}, -->  druid feral
	[104] = {320/512, 384/512, 0, 64/512}, -->  druid guardian
	[105] = {384/512, 448/512, 0, 64/512}, -->  druid resto

	[253] = {448/512, 512/512, 0, 64/512}, -->  hunter bm
	[254] = {0, 64/512, 64/512, 128/512}, --> hunter marks
	[255] = {64/512, 128/512, 64/512, 128/512}, --> hunter survivor
	
	[62] = {(128/512) + 0.001953125, 192/512, 64/512, 128/512}, --> mage arcane
	[63] = {192/512, 256/512, 64/512, 128/512}, --> mage fire
	[64] = {256/512, 320/512, 64/512, 128/512}, --> mage frost
	
	[268] = {320/512, 384/512, 64/512, 128/512}, --> monk bm
	[269] = {448/512, 512/512, 64/512, 128/512}, --> monk ww
	[270] = {384/512, 448/512, 64/512, 128/512}, --> monk mw
	
	[65] = {0, 64/512, 128/512, 192/512}, --> paladin holy
	[66] = {64/512, 128/512, 128/512, 192/512}, --> paladin protect
	[70] = {(128/512) + 0.001953125, 192/512, 128/512, 192/512}, --> paladin ret
	
	[256] = {192/512, 256/512, 128/512, 192/512}, --> priest disc
	[257] = {256/512, 320/512, 128/512, 192/512}, --> priest holy
	[258] = {(320/512) + (0.001953125 * 4), 384/512, 128/512, 192/512}, --> priest shadow
	
	[259] = {64/512, 128/512, 384/512, 448/512}, --> rogue assassination
	[260] = {0, 64/512, 384/512, 448/512}, --> rogue outlaw
	[261] = {0, 64/512, 192/512, 256/512}, --> rogue sub
	
	[262] = {64/512, 128/512, 192/512, 256/512}, --> shaman elemental
	[263] = {128/512, 192/512, 192/512, 256/512}, --> shamel enhancement
	[264] = {192/512, 256/512, 192/512, 256/512}, --> shaman resto
	
	[265] = {256/512, 320/512, 192/512, 256/512}, --> warlock aff
	[266] = {320/512, 384/512, 192/512, 256/512}, --> warlock demo
	[267] = {384/512, 448/512, 192/512, 256/512}, --> warlock destro
	
	[71] = {448/512, 512/512, 192/512, 256/512}, --> warrior arms
	[72] = {0, 64/512, 256/512, 320/512}, --> warrior fury
	[73] = {64/512, 128/512, 256/512, 320/512}, --> warrior protect
	
	[1467] = {256/512, 320/512, 256/512, 320/512}, --> evoker devastation
	[1468] = {320/512, 384/512, 256/512, 320/512}, --> evoker preservation
	[1473] = {384/512, 448/512, 256/512, 320/512}, --> evoker augmentation
}

--localization
Plater.AnchorNames = {
	LOC["OPTIONS_ANCHOR_TOPLEFT"],
	LOC["OPTIONS_ANCHOR_LEFT"],
	LOC["OPTIONS_ANCHOR_BOTTOMLEFT"],
	LOC["OPTIONS_ANCHOR_BOTTOM"],
	LOC["OPTIONS_ANCHOR_BOTTOMRIGHT"],
	LOC["OPTIONS_ANCHOR_RIGHT"],
	LOC["OPTIONS_ANCHOR_TOPRIGHT"],
	LOC["OPTIONS_ANCHOR_TOP"],
	LOC["OPTIONS_ANCHOR_CENTER"],
	LOC["OPTIONS_ANCHOR_INNERLEFT"],
	LOC["OPTIONS_ANCHOR_INNERRIGHT"],
	LOC["OPTIONS_ANCHOR_INNERTOP"],
	LOC["OPTIONS_ANCHOR_INNERBOTTOM"],
}

Plater.AnchorNamesByPhraseId = {
	"OPTIONS_ANCHOR_TOPLEFT",
	"OPTIONS_ANCHOR_LEFT",
	"OPTIONS_ANCHOR_BOTTOMLEFT",
	"OPTIONS_ANCHOR_BOTTOM",
	"OPTIONS_ANCHOR_BOTTOMRIGHT",
	"OPTIONS_ANCHOR_RIGHT",
	"OPTIONS_ANCHOR_TOPRIGHT",
	"OPTIONS_ANCHOR_TOP",
	"OPTIONS_ANCHOR_CENTER",
	"OPTIONS_ANCHOR_INNERLEFT",
	"OPTIONS_ANCHOR_INNERRIGHT",
	"OPTIONS_ANCHOR_INNERTOP",
	"OPTIONS_ANCHOR_INNERBOTTOM",
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
	local DB_CLASS_COLORS

	--auras
	local DB_AURA_ENABLED
	local DB_AURA_ALPHA
	local DB_AURA_SEPARATE_BUFFS

	local DB_USE_UIPARENT
	
	local DB_UNITCOLOR_CACHE = {}
	local DB_UNITCOLOR_SCRIPT_CACHE = {}

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
	local DB_USE_FOCUS_TARGET_ALPHA
	local DB_USE_ALPHA_FRIENDLIES
	local DB_USE_ALPHA_ENEMIES
	local DB_USE_QUICK_HIDE
	local DB_SHOW_HEALTHBARS_FOR_NOT_ATTACKABLE

	local DB_TEXTURE_CASTBAR
	local DB_TEXTURE_CASTBAR_BG
	local DB_TEXTURE_HEALTHBAR
	local DB_TEXTURE_HEALTHBAR_BG

	local DB_CASTBAR_HIDE_ENEMIES
	local DB_CASTBAR_HIDE_FRIENDLY

	---@type plater_spelldata[]
	local DB_CAPTURED_SPELLS = {}

	---@type plater_spelldata[]
	local DB_CAPTURED_CASTS = {}

	--store the aggro color table for tanks and dps
	local DB_AGGRO_TANK_COLORS
	local DB_AGGRO_DPS_COLORS

	--store if the no combat alpha is enabled
	local DB_NOT_COMBAT_ALPHA_ENABLED
	
	local DB_USE_HEALTHCUTOFF = false
	local DB_HEALTHCUTOFF_AT = 0.2
	local DB_HEALTHCUTOFF_AT_UPPER = 0.8
	
	--store translit option
	local DB_USE_NAME_TRANSLIT = false
	local TRANSLIT_MARK = "*"
	
	--store the npc id cache
	local DB_NPCIDS_CACHE = {}

	Plater.ScriptAura = {}
	local SCRIPT_AURA_TRIGGER_CACHE = Plater.ScriptAura

	Plater.ScriptCastBar = {}
	local SCRIPT_CASTBAR_TRIGGER_CACHE = Plater.ScriptCastBar

	Plater.ScriptUnit = {}
	local SCRIPT_UNIT_TRIGGER_CACHE = Plater.ScriptUnit
	
	--spell animations - store a table with information about animation for spells
	local SPELL_WITH_ANIMATIONS = {}
	--cache this inside plater object to access it from the animation editor
	Plater.SPELL_WITH_ANIMATIONS = SPELL_WITH_ANIMATIONS

	--store players which have the tank role in the group
	local TANK_CACHE = {}

	--store pet GUIDs
	---@type plater_petinfo[]
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
	
	local HOOKED_BLIZZARD_PLATEFRAMES = {}
	local ENABLED_BLIZZARD_PLATEFRAMES = {}
	local SUPPORT_BLIZZARD_PLATEFRAMES = false
	local NUM_NAMEPLATES_ON_SCREEN = 0
	local NAMEPLATES_ON_SCREEN_CACHE = {}
	
	local CLASS_INFO_CACHE = {}

	--store a list of friendly players in the player friends list
	Plater.FriendsCache = {}
	
	--store quests the player is in
	Plater.QuestCache = {}
	--store only campaign quests
	Plater.QuestCacheCampaign = {}
	
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
	
	function Plater.InitLDB()
		if LDB then
			local databroker = LDB:NewDataObject ("Plater", {
				type = "data source",
				icon = [[Interface\AddOns\Plater\images\cast_bar]],
				text = "Plater",
				showInCompartment = true,
				
				HotCornerIgnore = true,
				
				OnClick = function (self, button)
				
					if (button == "LeftButton") then
						if (PlaterOptionsPanelFrame and PlaterOptionsPanelFrame:IsShown()) then
							PlaterOptionsPanelFrame:Hide()
							return true
						end
						Plater.OpenOptionsPanel()
					
					elseif (button == "RightButton") then
					
						GameTooltip:Hide()
						local GameCooltip = GameCooltip2
						
						GameCooltip:Reset()
						GameCooltip:SetType ("menu")
						GameCooltip:SetOption ("ButtonsYMod", -5)
						GameCooltip:SetOption ("HeighMod", 5)
						GameCooltip:SetOption ("TextSize", 10)
						
						--> disable minimap icon
						local toggle_minimap = function()
							PlaterDBChr.minimap.hide = not PlaterDBChr.minimap.hide
							
							if (PlaterDBChr.minimap.hide) then
								LDBIcon:Hide ("Plater")
							else
								LDBIcon:Show ("Plater")
							end
							LDBIcon:Refresh ("Plater", PlaterDBChr.minimap)
						end
						
						local toggle_compartment = function()
							if LDBIcon:IsButtonInCompartment("Plater") then
								LDBIcon:RemoveButtonFromCompartment("Plater")
							else
								LDBIcon:AddButtonToCompartment("Plater")
							end
						end
						
						GameCooltip:AddMenu (1, function() Plater.EnableProfiling(true) end, true, nil, nil, "Start profiling", nil, true)
						GameCooltip:AddIcon ([[Interface\Addons\Plater\media\sphere_full_64]], 1, 1, 14, 14, 0, 1, 0, 1, "red")
						GameCooltip:AddMenu (1, function() Plater.DisableProfiling() end, true, nil, nil, "Stop profiling", nil, true)
						GameCooltip:AddIcon ([[Interface\Addons\Plater\media\square_64]], 1, 1, 14, 14, 0, 1, 0, 1, "blue")
						GameCooltip:AddMenu (1, function() Plater.ShowPerfData() end, true, nil, nil, "Show profiling data", nil, true)
						GameCooltip:AddIcon ([[Interface\Addons\Plater\media\eye_64]], 1, 1, 14, 14, 0, 1, 0, 1, "green")
						GameCooltip:AddLine ("$div")
						GameCooltip:AddMenu (1, toggle_minimap, true, nil, nil, "Hide/Show Minimap Icon", nil, true)
						GameCooltip:AddIcon ([[Interface\Buttons\UI-Panel-HideButton-Disabled]], 1, 1, 14, 14, 7/32, 24/32, 8/32, 24/32, "gray")
						GameCooltip:AddMenu (1, toggle_compartment, true, nil, nil, "Hide/Show Compartment Entry", nil, true)
						GameCooltip:AddIcon ([[Interface\Buttons\UI-Panel-HideButton-Disabled]], 1, 1, 14, 14, 7/32, 24/32, 8/32, 24/32, "gray")
						
						--GameCooltip:SetBackdrop (1, _detalhes.tooltip_backdrop, nil, _detalhes.tooltip_border_color)
						GameCooltip:SetWallpaper (1, [[Interface\SPELLBOOK\Spellbook-Page-1]], {.6, 0.1, 0.64453125, 0}, {.8, .8, .8, 0.2}, true)
						
						GameCooltip:SetOwner (self, "topright", "bottomleft")
						GameCooltip:ShowCooltip()
					
					end
					
				end,
				OnTooltipShow = function (tooltip)
					tooltip:AddLine ("Plater Nameplates", 1, 1, 1)
					tooltip:AddLine ("|cFFCFCFCFLeft click|r: Show/Hide Options Window")
					tooltip:AddLine ("|cFFCFCFCFRight click|r: Quick Menu")
				end,
			})
			
			if (databroker and not LDBIcon:IsRegistered ("Plater")) then
				PlaterDBChr.minimap = PlaterDBChr.minimap or {}
				LDBIcon:Register ("Plater", databroker, PlaterDBChr.minimap)
				if not PlaterDBChr.minimap.showInCompartment == true then
					--LDBIcon:AddButtonToCompartment("Plater") -- this is opt-in in LDBIcon (for now)
				end
			end
			
			Plater.databroker = databroker
		end

	end
	
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> character specific abilities and spells ~spells

	-- ~execute
	---update if can use execute indicators - this function needs to be updated when a new execute spell is added, removed, modified
	---in scripts you can use Plater.SetExecuteRange or override this function completelly
	function Plater.GetHealthCutoffValue(getOnly)
		Plater.SetExecuteRange (false)
		
		local lowerEnabled, upperEnabled = Plater.db.profile.health_cutoff, Plater.db.profile.health_cutoff_upper
			
		if (not (lowerEnabled or upperEnabled)) then
			if not getOnly then
				return
			end
		end
		
		local lowExecute, highExecute = nil, nil
		
		if IS_WOW_PROJECT_MAINLINE then
			--retail
			
			--small helper
			local isTalentLearned = function(nodeID)
				local talentConfig = C_ClassTalents.GetActiveConfigID()
				local nodeInfo = talentConfig and nodeID and C_Traits.GetNodeInfo(talentConfig, nodeID)
				return nodeInfo and nodeInfo.entryIDsWithCommittedRanks and nodeInfo.entryIDsWithCommittedRanks[1] and true or false
			end
			
			local classLoc, class = UnitClass ("player")
			local spec = GetSpecialization()
			if (spec and class) then
			
				if (class == "PRIEST") then
					-- SW:D is available to all priest specs
					if IsPlayerSpell(32379) then
						lowExecute = 0.20
					end
					
				elseif (class == "MAGE") then
					if IsPlayerSpell(2948) then -- Scorch
						lowExecute = 0.3
						if isTalentLearned(449349) then --Sunfury Execution (for Scorch)
							lowExecute = 0.35
						end
					end
					if IsPlayerSpell(205026) then --Firestarter
						highExecute = 0.9
					end
					if IsPlayerSpell(384581) then -- Arcane Bombardment
						lowExecute = 0.35
					end
					
				elseif (class == "WARRIOR") then
					-- Execute is baseline
					if IsPlayerSpell(163201) then
						local using_Massacre = IsPlayerSpell(281001) or IsPlayerSpell(206315)
						lowExecute = using_Massacre and 0.35 or 0.2
						--local using_Condemn = IsPlayerSpell(317320) -- that's not really used anymore...
						--highExecute = using_Condemn and 0.8 or nil
					end
					
				elseif (class == "HUNTER") then
					if IsPlayerSpell(53351) or IsPlayerSpell(320976) then -- Kill Shot
						lowExecute = 0.2
					end
					if IsPlayerSpell(273887) then --> is using killer instinct?
						lowExecute = 0.35
					end
					if IsPlayerSpell(260228) then --> Careful Aim
						highExecute = 0.7
					end
					
				elseif (class == "PALADIN") then
					-- hammer of wrath
					if IsPlayerSpell(24275) then
						lowExecute = 0.2
					end
					
				elseif (class == "MONK") then
					--Touch of Death
					if IsPlayerSpell(322113) then
						lowExecute = 0.15
					end
				
				elseif (class == "WARLOCK") then				
					if IsPlayerSpell(17877) then --Shadowburn
						lowExecute = 0.20
					elseif IsSpellKnownOrOverridesKnown(198590) then --Drain Soul
						lowExecute = 0.20
					end
				
				elseif (class == "ROGUE") then				
					if IsPlayerSpell(328085) then --Blindside
						lowExecute = 0.35
					end
				
				elseif (class == "DEATHKNIGHT") then
					if IsPlayerSpell(343294) then --Soul Reaper
						lowExecute = 0.35
					end
				
				end
			end
		
		else
			-- WotLK and classic
			local classLoc, class = UnitClass ("player")
			if (class) then
				if (class == "WARRIOR") then
					-- Execute
					if GetSpellInfo(GetSpellInfo(5308)) then
						lowExecute = 0.2
					end
				elseif (class == "PALADIN") then
					-- Hammer of Wrath
					if GetSpellInfo(GetSpellInfo(24275)) then
						lowExecute = 0.2
					end
				elseif (class == "WARLOCK") then
					-- Decimation
					if IsPlayerSpell(63156) or IsPlayerSpell(63158) then
						lowExecute = 0.25
					else
						lowExecute = 0.25
					end
				elseif (class == "HUNTER") then
					-- Kill Shot
					if GetSpellInfo(GetSpellInfo(53351)) then
						lowExecute = 0.2
					end
				elseif (class == "PRIEST") then
					if IS_WOW_PROJECT_CLASSIC_WRATH then -- why wrath again?... can't remember
						for i = 1, 6 do
							local enabled, _, glyphSpellID = GetGlyphSocketInfo(i)
							if enabled and glyphSpellID then
								if glyphSpellID == 55682 then --Glyph of Shadow Word: Death
									lowExecute = 0.35
									break
								end
							end
						end
					end
					
					-- SW:D is available to all priest specs
					if IsPlayerSpell(32379) then
						lowExecute = 0.25
					end
				end
			end
		
		end
		
		if not getOnly then
			Plater.SetExecuteRange (true, lowerEnabled and lowExecute or nil, upperEnabled and highExecute or nil)
		end
		return lowerEnabled and lowExecute or nil, upperEnabled and highExecute or nil
	end	

	---range check ~range
	---@param plateFrame plateframe
	---@param onAdded boolean
	function Plater.CheckRange (plateFrame, onAdded)
		Plater.StartLogPerformanceCore("Plater-Core", "Update", "CheckRange")
		
		local profile = Plater.db.profile
		local unitFrame = plateFrame.unitFrame
		local castBarFade = unitFrame.castBar.fadeOutAnimation:IsPlaying() --and profile.cast_statusbar_use_fade_effects
		local nameplateAlpha = 1
		local occlusionAlpha = tonumber(GetCVar ("nameplateOccludedAlphaMult")) or 1
		if DB_USE_UIPARENT and profile.honor_blizzard_plate_alpha then
		--if DB_USE_UIPARENT end
			nameplateAlpha = plateFrame:GetAlpha()
		end
		unitFrame.IsInRange = nil
		
		--if is using the no combat alpha and the unit isn't in combat, ignore the range check, no combat alpha is disabled by default
		if (unitFrame.IsSelf) then
			unitFrame.IsInRange = true --player plate is always in range
			
			unitFrame:SetAlpha (nameplateAlpha)

			unitFrame.healthBar:SetAlpha (1)
			if not castBarFade then
				unitFrame.castBar:SetAlpha (1)
			end
			unitFrame.powerBar:SetAlpha (1)
			unitFrame.BuffFrame:SetAlpha (DB_AURA_ALPHA)
			unitFrame.BuffFrame2:SetAlpha (DB_AURA_ALPHA)
			
			Plater.EndLogPerformanceCore("Plater-Core", "Update", "CheckRange")
			return
			
		elseif (plateFrame [MEMBER_NOCOMBAT] or unitFrame.isWidgetOnlyMode) then
			if unitFrame.isWidgetOnlyMode then
				unitFrame:SetAlpha (1)
			elseif nameplateAlpha < profile.not_affecting_combat_alpha and nameplateAlpha >= occlusionAlpha then
				unitFrame:SetAlpha (nameplateAlpha)
			else
				unitFrame:SetAlpha (profile.not_affecting_combat_alpha)
			end
			--unitFrame:SetAlpha (profile.not_affecting_combat_alpha) -- already set if necessary
			unitFrame.healthBar:SetAlpha (1)
			if not castBarFade then
				unitFrame.castBar:SetAlpha (1)
			end
			unitFrame.powerBar:SetAlpha (1)
			unitFrame.BuffFrame:SetAlpha (DB_AURA_ALPHA)
			unitFrame.BuffFrame2:SetAlpha (DB_AURA_ALPHA)
			
			Plater.EndLogPerformanceCore("Plater-Core", "Update", "CheckRange")
			return
		
		--the unit is friendly or not using range check and non targets alpha
		elseif ((not DB_USE_ALPHA_FRIENDLIES and plateFrame [MEMBER_REACTION] >= 5) or (not DB_USE_ALPHA_ENEMIES and plateFrame [MEMBER_REACTION] < 5) or (not DB_USE_RANGE_CHECK and not DB_USE_NON_TARGETS_ALPHA)) then
			unitFrame:SetAlpha (nameplateAlpha)
			unitFrame.healthBar:SetAlpha (1)
			if not castBarFade then
				unitFrame.castBar:SetAlpha (1)
			end
			unitFrame.powerBar:SetAlpha (1)
			unitFrame.BuffFrame:SetAlpha (DB_AURA_ALPHA)
			unitFrame.BuffFrame2:SetAlpha (DB_AURA_ALPHA)
			
			plateFrame [MEMBER_RANGE] = true
			unitFrame [MEMBER_RANGE] = true
			
			Plater.EndLogPerformanceCore("Plater-Core", "Update", "CheckRange")
			return
		end
		
		
		--alpha values
		local inRangeAlpha
		local overallRangeCheckAlpha
		local healthBar_rangeCheckAlpha
		local castBar_rangeCheckAlpha
		local buffFrames_rangeCheckAlpha
		local powerBar_rangeCheckAlpha
		local rangeChecker
		local rangeCheckRange
		
		if plateFrame [MEMBER_REACTION] < 5 then
			-- enemy
			inRangeAlpha = profile.range_check_in_range_or_target_alpha
			overallRangeCheckAlpha = profile.range_check_alpha
			healthBar_rangeCheckAlpha = profile.range_check_health_bar_alpha
			castBar_rangeCheckAlpha = profile.range_check_cast_bar_alpha
			buffFrames_rangeCheckAlpha = profile.range_check_buffs_alpha
			powerBar_rangeCheckAlpha = profile.range_check_power_bar_alpha
			rangeChecker = Plater.RangeCheckFunctionEnemy or LibRangeCheck:GetHarmMaxChecker(Plater.RangeCheckRangeEnemy or 40, true)
			rangeCheckRange = Plater.RangeCheckRangeEnemy
			
		else
			-- friendly
			inRangeAlpha = profile.range_check_in_range_or_target_alpha_friendlies
			overallRangeCheckAlpha = profile.range_check_alpha_friendlies
			healthBar_rangeCheckAlpha = profile.range_check_health_bar_alpha_friendlies
			castBar_rangeCheckAlpha = profile.range_check_cast_bar_alpha_friendlies
			buffFrames_rangeCheckAlpha = profile.range_check_buffs_alpha_friendlies
			powerBar_rangeCheckAlpha = profile.range_check_power_bar_alpha_friendlies
			rangeChecker = Plater.RangeCheckFunctionFriendly or LibRangeCheck:GetFriendMaxChecker(Plater.RangeCheckRangeFriendly or 40, true)
			rangeCheckRange = Plater.RangeCheckRangeFriendly
		end
		
		if not rangeChecker then
			rangeChecker = function (unit)
				local range = (LibRangeCheck:GetRange(unit, nil, true) or 0) <= (rangeCheckRange or 40)
				Plater.EndLogPerformanceCore("Plater-Core", "Update", "CheckRange")
				return range
			end
			Plater.GetSpellForRangeCheck()
		end

		--this unit is target
		local unitIsTarget = unitFrame.isSoftInteract -- default to softinteract
		local notTheTarget = false
		--when the unit is out of range and isnt target, alpha is multiplied by this amount
		local alphaMultiplier = 0.70

		local healthBar = unitFrame.healthBar
		local castBar = unitFrame.castBar
		local powerBar = unitFrame.powerBar
		local buffFrame1 = unitFrame.BuffFrame
		local buffFrame2 = unitFrame.BuffFrame2		

		--if "units which is not target" is enabled and the player is targetting something else than the player it self
		if ((DB_USE_NON_TARGETS_ALPHA and Plater.PlayerHasTargetNonSelf) or (DB_USE_FOCUS_TARGET_ALPHA and Plater.PlayerHasFocusTargetNonSelf)) then
			if (plateFrame [MEMBER_TARGET]) then
				unitIsTarget = true
			elseif (DB_USE_FOCUS_TARGET_ALPHA and unitFrame.IsFocus) then
				unitIsTarget = true
			else
				notTheTarget = true
				if (profile.transparency_behavior_use_division) then
					alphaMultiplier = 0.5
				end
			end
		end
 
		--is using the range check by ability
		if (DB_USE_RANGE_CHECK and rangeChecker) then
			--check when the unit just has been added to the screen
			local isInRange = rangeChecker (plateFrame [MEMBER_UNITID])

			if (isInRange) then
				--unit is in rage
				unitFrame.IsInRange = true
				
				if (onAdded) then
					--plateFrame.FadedIn = true

					unitFrame:SetAlpha (nameplateAlpha * inRangeAlpha * (notTheTarget and overallRangeCheckAlpha or 1))
					healthBar:SetAlpha (inRangeAlpha * (notTheTarget and healthBar_rangeCheckAlpha or 1))
					if not castBarFade then
						castBar:SetAlpha (inRangeAlpha * (notTheTarget and castBar_rangeCheckAlpha or 1))
					end
					powerBar:SetAlpha (inRangeAlpha * (notTheTarget and powerBar_rangeCheckAlpha or 1))
					buffFrame1:SetAlpha (inRangeAlpha * (notTheTarget and buffFrames_rangeCheckAlpha or 1))
					buffFrame2:SetAlpha (inRangeAlpha * (notTheTarget and buffFrames_rangeCheckAlpha or 1))

					plateFrame [MEMBER_RANGE] = true
					plateFrame.unitFrame [MEMBER_RANGE] = true

				else
					local newAlpha = nameplateAlpha * inRangeAlpha * (notTheTarget and overallRangeCheckAlpha or 1)
					if (not DF:IsNearlyEqual (unitFrame:GetAlpha(), newAlpha, 0.01)) then
						--play animations (animation aren't while in development)
						unitFrame:SetAlpha (nameplateAlpha * inRangeAlpha * (notTheTarget and overallRangeCheckAlpha or 1))
						healthBar:SetAlpha (inRangeAlpha * (notTheTarget and healthBar_rangeCheckAlpha or 1))
						if not castBarFade then
							castBar:SetAlpha (inRangeAlpha * (notTheTarget and castBar_rangeCheckAlpha or 1))
						end
						powerBar:SetAlpha (inRangeAlpha * (notTheTarget and powerBar_rangeCheckAlpha or 1))
						buffFrame1:SetAlpha (inRangeAlpha * (notTheTarget and buffFrames_rangeCheckAlpha or 1))
						buffFrame2:SetAlpha (inRangeAlpha * (notTheTarget and buffFrames_rangeCheckAlpha or 1))
					end

					plateFrame [MEMBER_RANGE] = true
					plateFrame.unitFrame [MEMBER_RANGE] = true
				end
			else
				--unit is out of range
				unitFrame.IsInRange = false
				
				if (onAdded) then
					plateFrame.FadedIn = nil

--					unitFrame:SetAlpha (overallRangeCheckAlpha * (notTheTarget and overallRangeCheckAlpha or 1))
--					healthBar:SetAlpha (healthBar_rangeCheckAlpha * (notTheTarget and healthBar_rangeCheckAlpha or 1))
--					castBar:SetAlpha (castBar_rangeCheckAlpha * (notTheTarget and castBar_rangeCheckAlpha or 1))
--					powerBar:SetAlpha (powerBar_rangeCheckAlpha * (notTheTarget and powerBar_rangeCheckAlpha or 1))
--					buffFrame1:SetAlpha (buffFrames_rangeCheckAlpha * (notTheTarget and buffFrames_rangeCheckAlpha or 1))
--					buffFrame2:SetAlpha (buffFrames_rangeCheckAlpha * (notTheTarget and buffFrames_rangeCheckAlpha or 1))

					unitFrame:SetAlpha ((unitIsTarget and inRangeAlpha or overallRangeCheckAlpha) * nameplateAlpha * (notTheTarget and alphaMultiplier or 1))
					healthBar:SetAlpha ((unitIsTarget and inRangeAlpha or healthBar_rangeCheckAlpha) * (notTheTarget and alphaMultiplier or 1))
					if not castBarFade then
						castBar:SetAlpha ((unitIsTarget and inRangeAlpha or castBar_rangeCheckAlpha) * (notTheTarget and alphaMultiplier  or 1))
					end
					powerBar:SetAlpha ((unitIsTarget and inRangeAlpha or powerBar_rangeCheckAlpha) * (notTheTarget and alphaMultiplier or 1))
					buffFrame1:SetAlpha ((unitIsTarget and inRangeAlpha or buffFrames_rangeCheckAlpha) * (notTheTarget and alphaMultiplier or 1))
					buffFrame2:SetAlpha ((unitIsTarget and inRangeAlpha or buffFrames_rangeCheckAlpha) * (notTheTarget and alphaMultiplier or 1))

					plateFrame [MEMBER_RANGE] = false
					plateFrame.unitFrame [MEMBER_RANGE] = false

				else
					local newAlpha = nameplateAlpha * overallRangeCheckAlpha * (notTheTarget and alphaMultiplier or 1)
					if (not DF:IsNearlyEqual (unitFrame:GetAlpha(), newAlpha, 0.01)) then
						
						--play animations (animation aren't while in development)
--						unitFrame:SetAlpha (overallRangeCheckAlpha * (notTheTarget and overallRangeCheckAlpha or 1))
--						healthBar:SetAlpha (healthBar_rangeCheckAlpha * (notTheTarget and healthBar_rangeCheckAlpha or 1))
--						castBar:SetAlpha (castBar_rangeCheckAlpha * (notTheTarget and castBar_rangeCheckAlpha or 1))
--						powerBar:SetAlpha (powerBar_rangeCheckAlpha * (notTheTarget and powerBar_rangeCheckAlpha or 1))
--						buffFrame1:SetAlpha (buffFrames_rangeCheckAlpha * (notTheTarget and buffFrames_rangeCheckAlpha or 1))
--						buffFrame2:SetAlpha (buffFrames_rangeCheckAlpha * (notTheTarget and buffFrames_rangeCheckAlpha or 1))
						
						unitFrame:SetAlpha ((unitIsTarget and inRangeAlpha or overallRangeCheckAlpha) * nameplateAlpha * (notTheTarget and alphaMultiplier or 1))
						healthBar:SetAlpha ((unitIsTarget and inRangeAlpha or healthBar_rangeCheckAlpha) * (notTheTarget and alphaMultiplier or 1))
						if not castBarFade then
							castBar:SetAlpha ((unitIsTarget and inRangeAlpha or castBar_rangeCheckAlpha) * (notTheTarget and alphaMultiplier  or 1))
						end
						powerBar:SetAlpha ((unitIsTarget and inRangeAlpha or powerBar_rangeCheckAlpha) * (notTheTarget and alphaMultiplier or 1))
						buffFrame1:SetAlpha ((unitIsTarget and inRangeAlpha or buffFrames_rangeCheckAlpha) * (notTheTarget and alphaMultiplier or 1))
						buffFrame2:SetAlpha ((unitIsTarget and inRangeAlpha or buffFrames_rangeCheckAlpha) * (notTheTarget and alphaMultiplier or 1))
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
					if (not DF:IsNearlyEqual (unitFrame:GetAlpha(), nameplateAlpha * inRangeAlpha, 0.01)) then
						unitFrame:SetAlpha (nameplateAlpha * inRangeAlpha)
						healthBar:SetAlpha (inRangeAlpha)
						if not castBarFade then
							castBar:SetAlpha (inRangeAlpha)
						end
						powerBar:SetAlpha (inRangeAlpha)
						buffFrame1:SetAlpha (DB_AURA_ALPHA)
						buffFrame2:SetAlpha (DB_AURA_ALPHA)
					end
					plateFrame.FadedIn = true

				else
					--this unit isnt the current player target
					if (not DF:IsNearlyEqual (unitFrame:GetAlpha(), nameplateAlpha * inRangeAlpha * overallRangeCheckAlpha, 0.01)) then
						unitFrame:SetAlpha (nameplateAlpha * inRangeAlpha * overallRangeCheckAlpha)
						healthBar:SetAlpha (inRangeAlpha * healthBar_rangeCheckAlpha)
						if not castBarFade then
							castBar:SetAlpha (inRangeAlpha * castBar_rangeCheckAlpha)
						end
						powerBar:SetAlpha (inRangeAlpha * powerBar_rangeCheckAlpha)
						buffFrame1:SetAlpha (inRangeAlpha * buffFrames_rangeCheckAlpha)
						buffFrame2:SetAlpha (inRangeAlpha * buffFrames_rangeCheckAlpha)
					end
					plateFrame.FadedIn = nil
				end
			else
				--player does not have a target, so just set to regular alpha
				plateFrame.FadedIn = true
				unitFrame:SetAlpha (nameplateAlpha * inRangeAlpha)
				healthBar:SetAlpha (1)
				if not castBarFade then
					castBar:SetAlpha (1)
				end
				powerBar:SetAlpha (1)
				buffFrame1:SetAlpha (DB_AURA_ALPHA)
				buffFrame2:SetAlpha (DB_AURA_ALPHA)
			end
		else
			-- no alpha settings, so just go to default
			plateFrame.FadedIn = true
			unitFrame:SetAlpha (nameplateAlpha * inRangeAlpha)
			healthBar:SetAlpha (1)
			if not castBarFade then
				castBar:SetAlpha (1)
			end
			powerBar:SetAlpha (1)
			buffFrame1:SetAlpha (DB_AURA_ALPHA)
			buffFrame2:SetAlpha (DB_AURA_ALPHA)
		end
		
		Plater.EndLogPerformanceCore("Plater-Core", "Update", "CheckRange")
	end	
	
	local re_GetSpellForRangeCheck = function()
		Plater.GetSpellForRangeCheck()
	end

	--> execute after player logon or when the player changes its spec
	local tryingToUpdateRangeChecker = false
	function Plater.GetSpellForRangeCheck()
		if tryingToUpdateRangeChecker then return end
		Plater.RangeCheckRangeEnemy = nil
		Plater.RangeCheckRangeFriendly = nil
		Plater.RangeCheckFunctionEnemy = nil
		Plater.RangeCheckFunctionFriendly = nil

		local specIndex = (IS_WOW_PROJECT_MAINLINE) and GetSpecialization() or 0
		if (specIndex) then
			local specID = (IS_WOW_PROJECT_MAINLINE) and GetSpecializationInfo (specIndex) or select (3, UnitClass ("player"))
			if (specID and specID ~= 0) then
			
			--[[ -- don't do that here, really. it will reset ranges with talent changes, etc. maybe only for current spec?
				--range check spells fallback update
				local harmCheckers = {}
				local maxHarm = 0
				for range, func in LibRangeCheck:GetHarmCheckers(true) do
					harmCheckers[range] = func
					if maxHarm < range then maxHarm = range end
				end
				local friendCheckers = {}
				local maxFriend = 0
				for range, func in LibRangeCheck:GetFriendCheckers(true) do
					friendCheckers[range] = func
					if maxFriend < range then maxFriend = range end
				end
				if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
					for specID, _ in pairs (Plater.SpecList [select (2, UnitClass ("player"))]) do
						if harmCheckers then
							if (PlaterDBChr.spellRangeCheckRangeEnemy [specID] == nil or not harmCheckers[PlaterDBChr.spellRangeCheckRangeEnemy [specID] ]) then
								PlaterDBChr.spellRangeCheckRangeEnemy [specID] = maxHarm --Plater.DefaultSpellRangeList [specID]
							end
						end
						if friendCheckers then
							if (PlaterDBChr.spellRangeCheckRangeFriendly [specID] == nil or not friendCheckers[PlaterDBChr.spellRangeCheckRangeFriendly [specID] ]) then
								PlaterDBChr.spellRangeCheckRangeFriendly [specID] = maxFriend --Plater.DefaultSpellRangeListF [specID]
							end
						end
					end
				else
					local playerClass = select (3, UnitClass ("player"))
					if harmCheckers then
						if (PlaterDBChr.spellRangeCheckRangeEnemy [playerClass] == nil or not harmCheckers[PlaterDBChr.spellRangeCheckRangeEnemy [playerClass] ]) then
							PlaterDBChr.spellRangeCheckRangeEnemy [playerClass] = maxHarm --Plater.DefaultSpellRangeList [playerClass]
						end
					end
					if friendCheckers then
						if (PlaterDBChr.spellRangeCheckRangeFriendly [playerClass] == nil or not friendCheckers[PlaterDBChr.spellRangeCheckRangeFriendly [playerClass] ]) then
							PlaterDBChr.spellRangeCheckRangeFriendly [playerClass] = maxFriend --Plater.DefaultSpellRangeListF [playerClass]
						end
					end
				end
				]]--
			
				--the local character saved variable hold the spell name used for the range check
				Plater.RangeCheckRangeFriendly = PlaterDBChr.spellRangeCheckRangeFriendly [specID] or Plater.DefaultSpellRangeListF [specID] or 40
				Plater.RangeCheckRangeEnemy = PlaterDBChr.spellRangeCheckRangeEnemy [specID] or Plater.DefaultSpellRangeList [specID] or 40
				Plater.RangeCheckFunctionFriendly = LibRangeCheck:GetFriendMaxChecker(Plater.RangeCheckRangeFriendly, true)
				Plater.RangeCheckFunctionEnemy = LibRangeCheck:GetHarmMaxChecker(Plater.RangeCheckRangeEnemy, true)
				
				tryingToUpdateRangeChecker = false
			else
				tryingToUpdateRangeChecker = true
				C_Timer.After (1, re_GetSpellForRangeCheck)
			end
		else
			tryingToUpdateRangeChecker = true
			C_Timer.After (1, re_GetSpellForRangeCheck)
		end
	end

	-- ~tank --todo: make these functions be inside the Plater object
	--true if the 'player' unit is a tank
	--parameter "hasTankAura" is used to force aura scan skip for paladins -> UpdatePlayerTankState -> SPELL_AURA_APPLIED/REMOVED (CLASSIC)
	local function IsPlayerEffectivelyTank(hasTankAura)
		if IS_WOW_PROJECT_MAINLINE then
			local assignedRole = UnitGroupRolesAssigned ("player")
			if (assignedRole == "NONE") then
				local spec = GetSpecialization()
				return spec and GetSpecializationRole (spec) == "TANK"
			end
			return assignedRole == "TANK"
		elseif IS_WOW_PROJECT_CLASSIC_WRATH then
			local assignedRole = UnitGroupRolesAssigned ("player")
			if assignedRole == "NONE" and UnitLevel ("player") >= 10 then
				assignedRole = GetTalentGroupRole(GetActiveTalentGroup())
			end
			local playerIsTank = assignedRole == "TANK"
			
			if not playerIsTank then
				playerIsTank = GetPartyAssignment("MAINTANK", "player") or false
			end
			
			return playerIsTank
		else
		
			local playerIsTank = hasTankAura or false
		
			if not hasTankAura then
				local playerClass = Plater.PlayerClass
				if playerClass == "WARRIOR" then
					local stance = GetShapeshiftFormID() --18 is def, 24 is glad
					playerIsTank = stance == 18 or ((not stance == 24) and IsEquippedItemType("Shields")) -- Defensive Stance or shield (and not glad)
				elseif playerClass == "DRUID" then
					local formId = GetShapeshiftFormID()
					playerIsTank = (formId == 5) or (formId == 8) -- Bear Form or Dire Bear Form...
				elseif playerClass == "PALADIN" then
					for i=1,40 do
					  local spellId = select(10, UnitBuff("player",i))
					  if spellId == 25780 or spellId == 407627 then
						playerIsTank = true
					  end
					end
				elseif playerClass == "ROGUE" then
					for i=1,40 do
					  local spellId = select(10, UnitBuff("player",i))
					  if spellId == 400015 or spellId == 400016 then
						playerIsTank = true
					  end
					end
				elseif playerClass == "WARLOCK" then
					for i=1,40 do
					  local spellId = select(10, UnitBuff("player",i))
					  if spellId == 403789 then
						playerIsTank = true
					  end
					end
				elseif playerClass == "SHAMAN" then
					for i=1,40 do
					  local spellId = select(10, UnitBuff("player",i))
					  if spellId == 408680 then
						playerIsTank = true
					  end
					end
				end
				
			end
			
			-- if the player is assigned as MAINTANK, then treat him as one:
			if not playerIsTank then
				playerIsTank = GetPartyAssignment("MAINTANK", "player") or false
			end
			
			return playerIsTank
		end
	end

	--return true if the unit is in tank role
	local function IsUnitEffectivelyTank (unit)
		if IS_WOW_PROJECT_MAINLINE then
			return UnitGroupRolesAssigned (unit) == "TANK"
		elseif IS_WOW_PROJECT_CLASSIC_WRATH then
			if IsInRaid() then
				return GetPartyAssignment("MAINTANK", unit)
			else
				return UnitGroupRolesAssigned (unit) == "TANK"
			end
		else
			return GetPartyAssignment("MAINTANK", unit)
		end
	end
	
	
	-- toggle Threat Color Mode between tank / dps (CLASSIC)
	function Plater.ToggleThreatColorMode()
		if IS_WOW_PROJECT_NOT_MAINLINE and not IS_WOW_PROJECT_CLASSIC_WRATH then
			Plater.db.profile.tank_threat_colors = not Plater.db.profile.tank_threat_colors
			Plater.RefreshTankCache()
			if Plater.PlayerIsTank then
				print("Plater: Using Tank Threat Colors")
			else
				print("Plater: Using DPS Threat Colors")
			end
		end
	end
	
	local function UpdatePlayerTankState(hasAura)
		if (IsPlayerEffectivelyTank(hasAura)) then
			TANK_CACHE [UnitName ("player")] = true
			Plater.PlayerIsTank = true
		else
			TANK_CACHE [UnitName ("player")] = false
			if IS_WOW_PROJECT_MAINLINE or IS_WOW_PROJECT_CLASSIC_WRATH then
				Plater.PlayerIsTank = false
			else
				Plater.PlayerIsTank = false or Plater.db.profile.tank_threat_colors
			end
		end
	end
	
	--iterate among group members and store the names of all tanks in the group
	--this is called when the player enter, leave or when the group roster is changed
	--tank cache is used mostly in the aggro check to know if the player is a tank
	function Plater.RefreshTankCache() --private
		Plater.PlayerIsTank = false
	
		wipe (TANK_CACHE)
		
		--add the player to the tank pool if the player is a tank
		UpdatePlayerTankState()
		
		--search for tanks in the raid
		if (IsInRaid()) then
			for i = 1, GetNumGroupMembers() do
				if (IsUnitEffectivelyTank ("raid" .. i)) then
					if (not UnitIsUnit ("raid" .. i, "player")) then
						local unitName = UnitName ("raid" .. i)
						if unitName ~= UNKNOWN then
							TANK_CACHE [unitName] = true
						end
					end
				end
			end
		
		--is in group and is inside a dungeon
		--there's only one tank on dungeon but dps may see if a unit is not in the tank aggro
		elseif (IsInGroup() and Plater.ZoneInstanceType == "party") then
			for i = 1, GetNumGroupMembers() -1 do
				if (IsUnitEffectivelyTank ("party" .. i)) then
					if (not UnitIsUnit ("party" .. i, "player")) then
						local unitName = UnitName ("party" .. i)
						if unitName ~= UNKNOWN then
							TANK_CACHE [unitName] = true
						end
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
		if (inCombat or (inCombat == nil and PLAYER_IN_COMBAT)) then
			return "cast_incombat", "health_incombat", "mana_incombat"
		else
			return "cast", "health", "mana"
		end
	end

	--> return true if the resource bar should shown above the nameplate in the current target nameplate
	function Plater.IsShowingResourcesOnTarget() --private
		return PlaterDBChr.resources_on_target
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
		Plater.StartLogPerformanceCore("Plater-Core", "Update", "RunScheduledUpdate")

		local unitId = timerObject.unitId
		---@type plateframe
		local plateFrame = C_NamePlate.GetNamePlateForUnit (unitId)
		
		if (plateFrame) then
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
			Plater.RunFunctionForEvent ("NAME_PLATE_UNIT_REMOVED", unitId)
			Plater.RunFunctionForEvent ("NAME_PLATE_UNIT_ADDED", unitId)
			
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
		
		Plater.EndLogPerformanceCore("Plater-Core", "Update", "RunScheduledUpdate")
	end

	---run a delayed update on the namepalte, this is used when the client receives an information from the server but does not update the state immediately
	---this usualy happens with faction and flag changes
	---@param plateFrame plateframe
	---@param passedUnitId string|nil
	---@param scheduleTime number|nil
	function Plater.ScheduleUpdateForNameplate (plateFrame, passedUnitId, scheduleTime) --private
		local unitId = passedUnitId or plateFrame [MEMBER_UNITID]
		if not unitId and plateFrame.HasUpdateScheduled then -- well... fuck.
			plateFrame.HasUpdateScheduled:Cancel()
			return
		end
		
		--check if there's already an update scheduled for this unit
		if (plateFrame.HasUpdateScheduled and not plateFrame.HasUpdateScheduled:IsCancelled()) then
			if unitId and (not plateFrame.HasUpdateScheduled.unitId or plateFrame.HasUpdateScheduled.unitId ~= unitId) then
				plateFrame.HasUpdateScheduled:Cancel()
			else
				return
			end
		end
		
		plateFrame.HasUpdateScheduled = C_Timer.NewTimer (scheduleTime or 0, Plater.RunScheduledUpdate) --scheduleTime or next frame
		plateFrame.HasUpdateScheduled.unitId = unitId
	end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> settings functions

	-- ~profile
	--refreshes the values for the profile when the profile is loaded or changed
	function Plater:RefreshConfig() --private
		platerInternal.ScriptTriggers.WipeDeprecatedScriptTriggersFromProfile(Plater.db.profile)

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
	local cvars_to_store = {
		["NamePlateClassificationScale"] = true,
		["NamePlateHorizontalScale"] = true,
		["NamePlateVerticalScale"] = true,
		["ShowClassColorInNameplate"] = true,
		["ShowNamePlateLoseAggroFlash"] = true,
		["nameplateGlobalScale"] = true,
		["nameplateLargerScale"] = true,
		["nameplateLargeTopInset"] = true,
		["nameplateLargeBottomInset"] = true,
		["nameplateMaxDistance"] = true,
		["nameplatePlayerMaxDistance"] = true,
		["nameplateMinScale"] = true,
		["nameplateMotion"] = true,
		["nameplateMotionSpeed"] = true,
		["nameplateOccludedAlphaMult"] = true,
		["nameplateOtherAtBase"] = true,
		["nameplateOtherTopInset"] = true,
		["nameplateOtherBottomInset"] = true,
		["nameplateOverlapV"] = true,
		["nameplateOverlapH"] = true,
		["nameplatePersonalHideDelaySeconds"] = true,
		["nameplatePersonalShowAlways"] = true,
		["nameplatePersonalShowInCombat"] = true,
		["nameplatePersonalShowWithTarget"] = true,
		["nameplateResourceOnTarget"] = (IS_WOW_PROJECT_MAINLINE),
		["nameplateSelectedScale"] = true,
		["nameplateSelfAlpha"] = (IS_WOW_PROJECT_MAINLINE),
		["nameplateSelfBottomInset"] = (IS_WOW_PROJECT_MAINLINE),
		["nameplateSelfScale"] = (IS_WOW_PROJECT_MAINLINE),
		["nameplateSelfTopInset"] = (IS_WOW_PROJECT_MAINLINE),
		["nameplateShowAll"] = true,
		["nameplateShowEnemies"] = true,
		["nameplateShowEnemyGuardians"] = true,
		["nameplateShowEnemyMinions"] = true,
		["nameplateShowEnemyMinus"] = true,
		["nameplateShowEnemyPets"] = true,
		["nameplateShowEnemyTotems"] = true,
		["nameplateShowFriends"] = true,
		["nameplateShowFriendlyNPCs"] = true,
		["nameplateShowFriendlyMinions"] = true,
		["nameplateShowFriendlyPets"] = true,
		["nameplateShowFriendlyGuardians"] = true,
		["nameplateShowFriendlyTotems"] = true,
		["nameplateShowOnlyNames"] = true,
		["nameplateShowSelf"] = (IS_WOW_PROJECT_MAINLINE),
		["nameplateTargetBehindMaxDistance"] = true,
		["clampTargetNameplateToScreen"] = true,
		["nameplateTargetRadialPosition"] = true,
		["nameplateSelectedAlpha"] = true,
		["nameplateNotSelectedAlpha"] = (IS_WOW_PROJECT_NOT_MAINLINE),
		["nameplateRemovalAnimation"] = (IS_WOW_PROJECT_NOT_MAINLINE),
		["nameplateMinAlpha"] = true,
		["nameplateMinAlphaDistance"] = true,
		["nameplateShowDebuffsOnFriendly"] = true,
		["SoftTargetIconGameObject"] = (IS_WOW_PROJECT_MAINLINE),
		["SoftTargetInteract"] = (IS_WOW_PROJECT_MAINLINE),
		["SoftTargetNameplateInteract"] = (IS_WOW_PROJECT_MAINLINE),
	}
	
	local cvars_to_store_lower = {}
	for CVarName in pairs (cvars_to_store) do
		cvars_to_store_lower[lower(CVarName)] = CVarName
	end
	
	--keep this separate for now, with only stuff that NEEDS restoring in order
	local function cvar_restore_order(v1, v2)
		local restoreOrder = {
			["nameplateShowFriends"] = 1,
			["nameplateShowFriendlyNPCs"] = 2,
			["nameplateShowFriendlyMinions"] = 3,
			["nameplateShowFriendlyPets"] = 4,
			["nameplateShowFriendlyGuardians"] = 5,
			["nameplateShowFriendlyTotems"] = 6,
			["nameplateShowEnemies"] = 7,
			["nameplateShowEnemyNPCs"] = 8,
			["nameplateShowEnemyMinions"] = 9,
			["nameplateShowEnemyPets"] = 10,
			["nameplateShowEnemyGuardians"] = 11,
			["nameplateShowEnemyTotems"] = 12,
		}
		
		local order1, order2 = restoreOrder[v1], restoreOrder[v2]
		
		if order1 and not order2 then
			return false
		elseif not order1 and order2 then
			return true
		elseif order1 and order2 then
			return order1 < order2
		elseif not order1 and not order2 then
			return v1 < v2
		end
		
	end
	
	function Plater.ParseCVarValue(value)
		if value == nil then return nil end
		--bool checks
		if type(value) == "boolean" then
			value = value and 1 or 0 --store as 1/0
		elseif value == "true" then
			value = 1
		elseif value == "false" then
			value = 0
		end
		return tostring(value) --to store string representation
	end
	
	local canSaveCVars = false --only allow storing after plater has restored
	--on logout or on profile change, or when they are actually set, save some important cvars inside the profile
	function Plater.SaveConsoleVariables(cvar, value) --private
		if not canSaveCVars then return end
		
		--print("save cvars", cvar, value, debugstack())
		local cvarTable = Plater.db.profile.saved_cvars
		local cvarLastChangedTable = Plater.db.profile.saved_cvars_last_change
		
		if (not cvarTable) then
			--return
			Plater.db.profile.saved_cvars = {}
			cvarTable = Plater.db.profile.saved_cvars
		end
		
		if not cvar then -- store all
			for CVarName, enabled in pairs (cvars_to_store) do
				if enabled then
					cvarTable [CVarName] = Plater.ParseCVarValue(GetCVar (CVarName))
				end
			end
		else
			-- make this case insensitive, but ensure original case is stored
			cvar = cvars_to_store_lower[lower(cvar) or "N/A"] -- get right case for storage
			if cvars_to_store[cvar] then
				cvarTable [cvar] = Plater.ParseCVarValue(value)
				local callstack = debugstack(2) -- starts at "SetCVar" or caller
				if callstack then
					local caller, line = callstack:match("\"@([^\"]+)\"%]:(%d+)")
					if not caller then
						caller, line = callstack:match("in function <([^:%[>]+):(%d+)>")
					end
					
					--print((caller and caller .. ":" .. line) or callstack)
					local isCVarUtil = (caller and caller:lower():find("[\\/]sharedxml[\\/]cvarutil%.lua"))
					cvarLastChangedTable [cvar] = not isCVarUtil and (caller and (caller .. ":" .. line)) or callstack or "N/A"
				end
			end
		end
		
	end
	--restore profile cvars
	function Plater.RestoreProfileCVars()
		if (InCombatLockdown()) then
			C_Timer.After (1, function() Plater.RestoreProfileCVars() end)
			return
		end
		
		--> try to restore cvars from the profile
		local savedCVars = Plater.db and Plater.db.profile and Plater.db.profile.saved_cvars
		if (savedCVars) then
			--pre-sort restore order:
			local orderKeys = {}
			for k in pairs (cvars_to_store) do
				tinsert(orderKeys, k)
			end
			table.sort(orderKeys, cvar_restore_order)
			
			for _, CVarName in pairs (orderKeys) do
				local CVarValue = savedCVars [CVarName]
				if CVarValue then --only restore what we want to store/restore!
					SetCVar (CVarName, Plater.ParseCVarValue(CVarValue))
				end
			end
		end
		canSaveCVars = true --allow storing after restoring the first time
	end
	
	function Plater.DebugCVars(cvar)
		cvar = cvar and cvar:gsub(" ", "") or nil
		if cvar and cvar ~= "" then
			if cvars_to_store[cvar] then
				print("CVar info:\nName: '" .. cvar .. "'\nCurrent Value: " .. (Plater.ParseCVarValue(GetCVar (cvar)) or "<not set>") .. "\nStored Value: " .. (Plater.db.profile.saved_cvars[cvar] or "<not stored>") ..  "\nLast changed by: " .. (Plater.db.profile.saved_cvars_last_change[cvar] and ("\n" .. Plater.db.profile.saved_cvars_last_change[cvar]) or "<no info>"))
			else
				print("CVar '" .. cvar .. "' is not stored in Plater.")
			end
		else
			print("No CVar name provided. Printing all stored CVar names. Use '/plater cvar <cvar name> for more details.'")
			local savedCVars = Plater.db and Plater.db.profile and Plater.db.profile.saved_cvars or {}
			for CVarName, CVarValue in pairs (savedCVars) do
				print("'" .. CVarName .. "' = " .. (Plater.ParseCVarValue(CVarValue) or "<not set>"))
			end
		end
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

	function Plater.DisableAuraTrackingForAuraTest()
		DB_AURA_ENABLED = false
	end

	--> place most used data into local upvalues to save process time
	--> scripts need to call this function if they change something in the profile ~refresh ~db ~upvalues
	function Plater.RefreshDBUpvalues()
		local profile = Plater.db.profile

		DB_AURA_ENABLED = profile.aura_enabled
		DB_AURA_ALPHA = profile.aura_alpha
		DB_AURA_SEPARATE_BUFFS = profile.buffs_on_aura2

		DB_NUMBER_REGION_EAST_ASIA = Plater.db.profile.number_region == "eastasia"
		
		DB_TICK_THROTTLE = profile.update_throttle
		DB_LERP_COLOR = profile.use_color_lerp

		--class colors
		DB_CLASS_COLORS = profile.class_colors
		--update colorStr
		for className, colorTable in pairs(profile.class_colors) do
			colorTable.colorStr = DetailsFramework:FormatColor("hex", colorTable.r, colorTable.g, colorTable.b, 1)
		end

		DB_LERP_COLOR_SPEED = profile.color_lerp_speed
		DB_PLATE_CONFIG = profile.plate_config
		DB_TRACK_METHOD = profile.aura_tracker.track_method
		
		DB_DO_ANIMATIONS = profile.use_health_animation
		DB_ANIMATION_TIME_DILATATION = profile.health_animation_time_dilatation
		
		DB_HOVER_HIGHLIGHT = profile.hover_highlight
		DB_USE_RANGE_CHECK = profile.range_check_enabled
		DB_USE_NON_TARGETS_ALPHA = profile.non_targeted_alpha_enabled
		DB_USE_FOCUS_TARGET_ALPHA = profile.focus_as_target_alpha
		DB_USE_ALPHA_FRIENDLIES = profile.transparency_behavior_on_friendlies
		DB_USE_ALPHA_ENEMIES = profile.transparency_behavior_on_enemies
		DB_USE_QUICK_HIDE = profile.quick_hide
		DB_SHOW_HEALTHBARS_FOR_NOT_ATTACKABLE = profile.show_healthbars_on_not_attackable
		
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
		
		DB_CAPTURED_CASTS = PlaterDB.captured_casts
		DB_CAPTURED_SPELLS = PlaterDB.captured_spells
		
		DB_USE_NAME_TRANSLIT = profile.use_name_translit

		--refresh lists
		Plater.RefreshDBLists()

		--refresh auras
		Plater.RefreshAuraCache() --on Plater_Auras.lua
		Plater.RefreshAuraDBUpvalues() --on Plater_Auras.lua
		Plater.UpdateAuraCache() --on Plater_Auras.lua

		--refresh resources
		Plater.Resources.RefreshResourcesDBUpvalues() --Plater_Resources.lua
	end
	
	function Plater.RefreshDBLists()
		local profile = Plater.db.profile

		wipe (SPELL_WITH_ANIMATIONS)
		
		if (profile.spell_animations) then
			for spellId, animations in pairs (profile.spell_animation_list) do
				if type(spellId) == "string" and tonumber(spellId) then
					profile.spell_animation_list[tonumber(spellId)] = animations
					profile.spell_animation_list[spellId] = nil
				end
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

		--> build the list of npcs with special colors
		wipe (DB_UNITCOLOR_CACHE) --regular color overrides the threat color
		wipe (DB_UNITCOLOR_SCRIPT_CACHE) --color only used for scripts, plater does not use them 
		
		for npcID, infoTable in pairs (Plater.db.profile.npc_colors) do
			local enabled1 = infoTable [1] --this is the overall enabled
			local enabled2 = infoTable [2] --if this is true, this color is only used for scripts
			local colorID = infoTable [3] --the color
			
			if (enabled1 and not enabled2) then
				local r, g, b, a = DF:ParseColors (colorID)
				DB_UNITCOLOR_CACHE [npcID] = {r, g, b, a}
				
			elseif (enabled1 and enabled2) then
				local r, g, b, a = DF:ParseColors (colorID)
				DB_UNITCOLOR_SCRIPT_CACHE [npcID] = {r, g, b, a}
				
			end
		end
		
		Plater.IncreaseRefreshID()
		Plater.FireRefreshDBCallback()
	end

	--a patch is a function stored in the Plater_ScriptLibrary file and are executed only once to change a profile setting, remove or add an aura into the tracker or modify a script
	--patch versions are stored within the profile, so importing or creating a new profile will apply all patches that wasn't applyed into it yet
	function Plater.ApplyPatches() --private ~updates ~scriptupdates ~patch ~patches
		if (PlaterPatchLibrary) then
			local currentPatch = Plater.db.profile.patch_version
			local bSkipNonEssentialPatches = PlaterDB.SkipNonEssentialPatches
			for patchId = currentPatch+1, #PlaterPatchLibrary do
				local bCanInstallPatch = true

				if (bSkipNonEssentialPatches) then
					if (PlaterPatchLibrary[patchId].NotEssential) then
						print(LOC["OPTIONS_NOESSENTIAL_SKIP_ALERT"], PlaterPatchLibrary[patchId].Notes[1]) --"Skipped non-essential patch:"
						bCanInstallPatch = false
					end
				end

				if (bCanInstallPatch) then
					local patch = PlaterPatchLibrary [patchId]
					Plater:Msg ("Applied Patch #" .. patchId .. ":")
					
					for o = 1, #patch.Notes do
						print (patch.Notes [o])
					end
					
					DF:Dispatch (patch.Func)
				end
				
				Plater.db.profile.patch_version = patchId
			end
			
			--do not clear patch library, when creating a new profile it'll need to re-apply patches
			--PlaterPatchLibrary = nil
		end
	end
	
	function Plater.SetNameplateScale(unitFrame, scale)
		scale = tonumber(scale)
		unitFrame.nameplateScaleAdjust = scale and (scale > 0) and scale or 1
		if (DB_USE_UIPARENT) then
			Plater.UpdateUIParentScale (unitFrame.PlateFrame)
		else
			unitFrame:SetScale (unitFrame.nameplateScaleAdjust)
			Plater.UpdatePlateSize(unitFrame.PlateFrame)
		end
	end

	---when using UIParent as the parent for the unitFrame, this function is hooked in the plateFrame OnSizeChanged script
	---the goal is to adjust the the unitFrame scale when the plateFrame scale changes
	---this approach also solves the issue to the unitFrame not playing correctly the animation when the nameplate is removed from the screen
	---self is plateFrame, w, h aren't reliable
	---@param self plateframe
	---@param w any
	---@param h any
	function Plater.UpdateUIParentScale (self, w, h) --private
		local unitFrame = self.unitFrame
		if (unitFrame) then
			local defaultScale = self:GetEffectiveScale()
			--local defaultScale = UIParent:GetEffectiveScale()
			
			if (defaultScale < 0.4) then
				--assuming the nameplate is in process of being removed from the screen if the scale if lower than .4
				unitFrame:SetScale (defaultScale)
			else
				--scale (adding a fine tune knob)
				local scaleFineTune = max (Plater.db.profile.ui_parent_scale_tune, 0.3)
				
				--@Ariani - March, 9
				unitFrame:SetScale (defaultScale * scaleFineTune * (tonumber(unitFrame.nameplateScaleAdjust) or 1))

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
			local buffSpecial = unitFrame.ExtraIconFrame
			
			--strata
			unitFrame:SetFrameStrata (profile.ui_parent_base_strata)
			castBar:SetFrameStrata (profile.ui_parent_cast_strata)
			buffFrame1:SetFrameStrata (profile.ui_parent_buff_strata)
			buffFrame2:SetFrameStrata (profile.ui_parent_buff2_strata)
			buffSpecial:SetFrameStrata (profile.ui_parent_buff_special_strata)
			
			--level
			local baseLevel = unitFrame:GetFrameLevel()
			
			local tmplevel = baseLevel + profile.ui_parent_cast_level + 3
			castBar:SetFrameLevel ((tmplevel > 0) and tmplevel or 0)
			
			tmplevel = baseLevel + profile.ui_parent_buff_level + 3
			buffFrame1:SetFrameLevel ((tmplevel > 0) and tmplevel or 0)
			
			tmplevel = baseLevel + profile.ui_parent_buff2_level + 10
			buffFrame2:SetFrameLevel ((tmplevel > 0) and tmplevel or 0)
			
			tmplevel = baseLevel + profile.ui_parent_buff_special_level + 10
			buffSpecial:SetFrameLevel ((tmplevel > 0) and tmplevel or 0)
			
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
					return format ("%.2fB", number/1000000000)
					
				elseif (number > 999999) then
					return format ("%.2fM", number/1000000)
					
				elseif (number > 99999) then
					return floor (number/1000) .. "K"
					
				elseif (number > 999) then
					return format ("%.1fK", (number/1000))
					
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
				---@type plateframe
				local plateFrame = globalScope ["NamePlate" .. i]
				if (plateFrame) then
					for i = 1, HOOK_ZONE_CHANGED.ScriptAmount do
						local globalScriptObject = HOOK_ZONE_CHANGED [i]
						local unitFrame = plateFrame.unitFrame
						local scriptContainer = unitFrame:ScriptGetContainer()
						local scriptInfo = unitFrame:HookGetInfo(globalScriptObject, scriptContainer, "Zone Changed")
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

	function platerInternal.OnOptionChanged()
		for i = 1, HOOK_OPTION_CHANGED.ScriptAmount do
			local hookInfo = HOOK_OPTION_CHANGED[i]
			Plater.ScriptMetaFunctions.ScriptRunNoAttach(hookInfo, "Option Changed")
		end
	end
	
	--store all functions for all events that will be registered inside OnInit
	local last_GetShapeshiftFormID = GetShapeshiftFormID()
	local eventFunctions = {

		--when a unit from unatackable change its state, this event triggers several times, a schedule is used to only update once
		UNIT_FLAGS = function (_, unit)
			--if (unit == "player") then
			--	return
			--end
			
			if not string.match(unit, "nameplate%d%d?$") then return end
			
			---@type plateframe
			local plateFrame = C_NamePlate.GetNamePlateForUnit (unit, issecure())
			if (plateFrame) then
				--rules if can schedule an update for unit flag event:
				
				--has the hostility changed?
				local reactionChanged = false
				local curReaction = plateFrame [MEMBER_REACTION]
				local newReaction = UnitReaction(unit, "player")
				if not curReaction then -- in case the plater nameplate is not on screen, ensure that it can change
					reactionChanged = true
				elseif curReaction ~= newReaction then
					if curReaction == Plater.UnitReaction.UNITREACTION_NEUTRAL and newReaction ~= curReaction then
						reactionChanged = true
					elseif curReaction < Plater.UnitReaction.UNITREACTION_NEUTRAL and newReaction >= Plater.UnitReaction.UNITREACTION_NEUTRAL then
						reactionChanged = true
					elseif curReaction > Plater.UnitReaction.UNITREACTION_NEUTRAL and newReaction <= Plater.UnitReaction.UNITREACTION_NEUTRAL then
						reactionChanged = true
					end
				end

				--can the user attack or no longer attack?
				local attackableChanged = plateFrame.PlayerCannotAttack ~= not UnitCanAttack ("player", unit)
				if (reactionChanged or attackableChanged or not plateFrame.unitFrame.PlaterOnScreen) then
					--print ("UNIT_FLAG", plateFrame, issecure(), unit, unit and UnitName (unit))
					--Plater.ScheduleUpdateForNameplate (plateFrame, unit)
					
					Plater.RunScheduledUpdate({unitId = unit}) -- do this now
				end
			end
		end,
		
		UNIT_FACTION = function (_, unit)
			--if (unit == "player") then
			--	return
			--end
			
			--fires when somebody changes faction near the player
			---@type plateframe
			local plateFrame = C_NamePlate.GetNamePlateForUnit (unit, issecure())
			if (plateFrame) then
				Plater.ScheduleUpdateForNameplate (plateFrame)
			end
		end,

		ACTIVE_TALENT_GROUP_CHANGED = function()
			C_Timer.After (0.5, UpdatePlayerTankState)
			C_Timer.After (0.5, Plater.Resources.OnSpecChanged) --~resource
			C_Timer.After (2, Plater.GetSpellForRangeCheck)
			C_Timer.After (2, Plater.GetHealthCutoffValue)
			C_Timer.After (1, Plater.DispatchTalentUpdateHookEvent)
		end,
		
		PLAYER_SPECIALIZATION_CHANGED = function()
			C_Timer.After (0.5, Plater.Resources.OnSpecChanged) --~resource
			C_Timer.After (2, Plater.GetSpellForRangeCheck)
			C_Timer.After (2, Plater.GetHealthCutoffValue)
			C_Timer.After (1, Plater.DispatchTalentUpdateHookEvent)
		end,
		
		TRAIT_CONFIG_UPDATED = function()
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
		
		UNIT_PET = function(_, unit)
			for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
				---@cast plateFrame plateframe
				if plateFrame.unitFrame and plateFrame.unitFrame.PlaterOnScreen then
					if not plateFrame.unitFrame.isPerformanceUnit then
						Plater.AddToAuraUpdate(plateFrame.unitFrame.unit) -- force aura update
					end
					Plater.ScheduleUpdateForNameplate (plateFrame)
				end
			end
		end,

		PLAYER_REGEN_DISABLED = function()
			PLAYER_IN_COMBAT = true

			Plater.RefreshAutoToggle(PLAYER_IN_COMBAT)

			Plater.RefreshTankCache()
			
			--Plater.UpdateAuraCache()
			Plater.UpdateAllPlates(false, false, true)
			
			--check if can run combat enter hook and schedule it true
			if (HOOK_COMBAT_ENTER.ScriptAmount > 0) then
				local hookTimer = C_Timer.NewTimer (0.1, Plater.ScheduleHookForCombat)
				hookTimer.Event = "Enter Combat"
			end
			
			Plater.CombatTime = GetTime()

			--store names and casts from 'last' combat, this is used when showing Npcs Colors and Cast Colors to bump up stuff from the last combat
			table.wipe(Plater.LastCombat.npcNames)
			table.wipe(Plater.LastCombat.spellNames)

			--store player and pet guids for friendly affiliation
			local unitCachePlayers
			local unitCachePets

			if (IsInRaid()) then
				unitCachePlayers = platerInternal.UnitIdCache.Raid --raid1, raid2, raid3
				unitCachePets = platerInternal.UnitIdCache.RaidPet --raidpet1, raidpet2, raidpet3
			else
				unitCachePlayers = platerInternal.UnitIdCache.Party --player, party1, party2
				unitCachePets = platerInternal.UnitIdCache.PartyPet --partypet1, partypet2
			end

			table.wipe(platerInternal.HasFriendlyAffiliation)

			for i = 1, #unitCachePlayers do
				local unitGuid = UnitGUID(unitCachePlayers[i])
				if (unitGuid) then
					platerInternal.HasFriendlyAffiliation[unitGuid] = true
				else
					break
				end
			end

			for i = 1, #unitCachePets do
				local unitGuid = UnitGUID(unitCachePets[i])
				if (unitGuid) then
					platerInternal.HasFriendlyAffiliation[unitGuid] = true
				end
			end
		end,

		PLAYER_REGEN_ENABLED = function()

			PLAYER_IN_COMBAT = false
			
			Plater.RefreshAutoToggle(PLAYER_IN_COMBAT, true)
			
			for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
				---@cast plateFrame plateframe
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
			
			if (platerInternal.OpenOptionspanelAfterCombat) then
				local OpenOptionspanelAfterCombat = platerInternal.OpenOptionspanelAfterCombat
				platerInternal.OpenOptionspanelAfterCombat = nil
				C_Timer.NewTimer (1.5, function() Plater.OpenOptionsPanel(unpack(OpenOptionspanelAfterCombat)) end )
			end
		end,

		FRIENDLIST_UPDATE = function()
			wipe (Plater.FriendsCache)
			for i = 1, C_FriendList.GetNumFriends() do
				local info = C_FriendList.GetFriendInfoByIndex (i)
				if (info and info.connected and info.name) then
					Plater.FriendsCache [info.name] = true
					Plater.FriendsCache [DF:RemoveRealmName (info.name)] = true
				end
			end
			
			if IS_WOW_PROJECT_MAINLINE then
				local _, numBNetOnline = BNGetNumFriends();
				for i = 1, numBNetOnline do
					local accountInfo = C_BattleNet.GetFriendAccountInfo(i);
					if (accountInfo and accountInfo.gameAccountInfo and accountInfo.gameAccountInfo.isOnline and accountInfo.gameAccountInfo.characterName) then
						Plater.FriendsCache [accountInfo.gameAccountInfo.characterName] = true
					end
				end
			else
				for i = 1, BNGetNumFriends() do 
					local presenceID, presenceName, battleTag, isBattleTagPresence, toonName, toonID, client, isOnline, lastOnline, isAFK, isDND, messageText, noteText, isRIDFriend, broadcastTime, canSoR = BNGetFriendInfo (i)
					if (isOnline and toonName) then
						Plater.FriendsCache [toonName] = true
					end
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
				---@type plateframe
				local plateFrame = C_NamePlate.GetNamePlateForUnit (unitID)
				if (plateFrame and plateFrame.unitFrame.PlaterOnScreen) then
					local unitFrame = plateFrame.unitFrame
					local unitName = UnitName (unitID)
					local unitNameTranslit = unitName
					if DB_USE_NAME_TRANSLIT then
						unitNameTranslit = LibTranslit:Transliterate(unitName, TRANSLIT_MARK)
					end
					plateFrame [MEMBER_NAME] = unitNameTranslit
					plateFrame [MEMBER_NAMELOWER] = lower (plateFrame [MEMBER_NAME])
					plateFrame.unitNameInternal = unitName
					unitFrame [MEMBER_NAME] = plateFrame [MEMBER_NAME]
					unitFrame [MEMBER_NAMELOWER] = plateFrame [MEMBER_NAMELOWER]
					unitFrame.unitNameInternal = unitName
					
					if (plateFrame.IsSelf) then
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
			Plater.CurrentEncounterName = nil
			Plater.CurrentEncounterDifficultyId = nil
			Plater.LatestEncounter = time()
		end,

		ENCOUNTER_START = function (_, encounterID, encounterName, difficultyID)
			Plater.CurrentEncounterID = encounterID
			Plater.CurrentEncounterName = encounterName
			Plater.CurrentEncounterDifficultyId = difficultyID
			
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
				C_Timer.After (1, function() Plater.RunFunctionForEvent ("ZONE_CHANGED_NEW_AREA") end)
				return
			end
			
			Plater.CurrentEncounterID = nil
			
			local pvpType, isFFA, faction = (GetZonePVPInfo or C_PvP.GetZonePVPInfo)()
			Plater.ZonePvpType = pvpType
			Plater.UpdateBgPlayerRoleCache()
			
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
		
		PLAYER_ENTERING_WORLD = function(_, isInitialLogin, isReloadingUi)

			Plater.db.profile.login_counter = Plater.db.profile.login_counter + 1

			Plater.ScheduleRunFunctionForEvent (1, "ZONE_CHANGED_NEW_AREA")
			Plater.ScheduleRunFunctionForEvent (1, "FRIENDLIST_UPDATE")

			Plater.PlayerGuildName = GetGuildInfo ("player")
			if (not Plater.PlayerGuildName or Plater.PlayerGuildName == "") then
				Plater.PlayerGuildName = "ThePlayerHasNoGuildName/30Char"
				
				--somethimes guild information isn't available at the login
				C_Timer.After (10, delayed_guildname_check)
			end
			
			local pvpType, isFFA, faction = (GetZonePVPInfo or C_PvP.GetZonePVPInfo)()
			Plater.ZonePvpType = pvpType
			
			local name, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceMapID, instanceGroupSize = GetInstanceInfo()
			Plater.ZoneInstanceType = instanceType
			
			--> ensure resource on target consistency after login:
			local resourcesOnTarget = GetCVar ("nameplateResourceOnTarget") == CVAR_ENABLED
			if resourcesOnTarget then
				PlaterDBChr.resources_on_target = true
				if (not InCombatLockdown()) then
					SetCVar ("nameplateResourceOnTarget", CVAR_DISABLED) -- reset this to false always, as it conflicts
				end
			end
			
			-- this seems to be gone as of 18.12.2020
			--if Plater.db.profile.plate_config.friendlynpc.quest_enabled and not InCombatLockdown() then
				--SetCVar("showQuestTrackingTooltips", 1) -- ensure it is turned on...
			--end

			--create the frame to hold the plater resoruce bar
			Plater.Resources.CreateMainResourceFrame() --~resource
			
			--run hooks on load screen
			if (HOOK_LOAD_SCREEN.ScriptAmount > 0) then
				Plater.PlayerEnteringWorld = true
			end
		end,

		PLAYER_LOGOUT = function()
			--Plater.SaveConsoleVariables()
		end,
		
		VARIABLES_LOADED = function()
			
			C_Timer.After (0.1, Plater.ForceCVars)
			
			C_Timer.After (0.2, Plater.RestoreProfileCVars)

			C_Timer.After (0.3, Plater.UpdatePlateClickSpace)
			
			C_Timer.After (0.4, function() 
				Plater.RefreshAutoToggle(InCombatLockdown()) -- refresh this
				Plater.UpdateBaseNameplateOptions()
			end)
			
			-- hook CVar saving
			hooksecurefunc('SetCVar', Plater.SaveConsoleVariables)
			if C_CVar and C_CVar.SetCVar then
				hooksecurefunc(C_CVar, 'SetCVar', Plater.SaveConsoleVariables)
			end
			hooksecurefunc('ConsoleExec', function(console)
				local par1, par2, par3 = console:match('^(%S+)%s+(%S+)%s*(%S*)')
				if par1 then
					if par1:lower() == 'set' then -- /console SET cvar value
						Plater.SaveConsoleVariables(par2, par3)
					else -- /console cvar value
						Plater.SaveConsoleVariables(par1, par2)
					end
				end
			end)
			
		end,
		
		--many times at saved variables load the spell database isn't loaded yet
		PLAYER_LOGIN = function()			
			
			--C_Timer.After (0.1, Plater.GetSpellForRangeCheck)
			
			-- ensure OmniCC settings are up to date
			C_Timer.After (1, Plater.RefreshOmniCCGroup)
			
			--wait more time for the talents information be received from the server
			C_Timer.After (4, Plater.GetHealthCutoffValue)
			
			C_Timer.After (2, Plater.ScheduleZoneChangeHook)
			
			C_Timer.After (5, function()
				local petGUID = UnitGUID ("playerpet")
				if (petGUID) then
					local entry = {ownerGUID = Plater.PlayerGUID, ownerName = UnitName("player"), petName = UnitName("playerpet"), time = time()}
					Plater.PlayerPetCache [petGUID] = entry
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
					PlaterOptionsPanelContainer:SelectTabByIndex (Plater.db.profile.reopoen_options_panel_on_tab)
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
			C_Timer.After (15, function()
				if ((IsAddOnLoaded or C_AddOns.IsAddOnLoaded) ("ElvUI")) then
					if (ElvUI[1] and ElvUI[1].private and ElvUI[1].private.nameplates and ElvUI[1].private.nameplates.enable) then
						Plater:Msg ("'ElvUI Nameplates' and 'Plater Nameplates' are enabled and both nameplates won't work together.")
						Plater:Msg ("You may disable ElvUI Nameplates at /elvui > Nameplates section or you may disable Plater at the addon control panel.")
					end
				end 
			end)

			-- ensure resources are up to date
			C_Timer.After (3, Plater.Resources.OnSpecChanged)
			
			-- translate NPC_CACHE entries if needed
			C_Timer.After (10, Plater.TranslateNPCCache)

		end,
		
		DISPLAY_SIZE_CHANGED = function()
			for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
				---@cast plateFrame plateframe
				if plateFrame.unitFrame.PlaterOnScreen then
					Plater.OnRetailNamePlateShow(plateFrame.UnitFrame)
				end
			end
			Plater.UpdateAllPlates (true)
		end,
		
		UI_SCALE_CHANGED = function()
			for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
				---@cast plateFrame plateframe
				Plater.OnRetailNamePlateShow(plateFrame.UnitFrame)
			end
			Plater.UpdateAllPlates (true)
		end,
		
		PLAYER_SOFT_INTERACT_CHANGED = function(_, arg1, arg2)
			for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
				---@cast plateFrame plateframe
				if plateFrame.unitFrame.PlaterOnScreen then
					if plateFrame [MEMBER_GUID] == arg1 or plateFrame [MEMBER_GUID] == arg2 then
						Plater.UpdateSoftInteractTarget(plateFrame, true)
					end
				end
			end
		end,
		
		PLAYER_SOFT_FRIEND_CHANGED = function(_, arg1, arg2)
			for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
				---@cast plateFrame plateframe
				if plateFrame.unitFrame.PlaterOnScreen then
					if plateFrame [MEMBER_GUID] == arg1 or plateFrame [MEMBER_GUID] == arg2 then
						Plater.UpdateSoftInteractTarget(plateFrame, true)
					end
				end
			end
		end,
		
		PLAYER_SOFT_ENEMY_CHANGED = function(_, arg1, arg2)
			for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
				---@cast plateFrame plateframe
				if plateFrame.unitFrame.PlaterOnScreen then
					if plateFrame [MEMBER_GUID] == arg1 or plateFrame [MEMBER_GUID] == arg2 then
						Plater.UpdateSoftInteractTarget(plateFrame, true)
					end
				end
			end
		end,
		
		--~created ~events ~oncreated 
		---@param event string
		---@param plateFrame plateframe
		NAME_PLATE_CREATED = function (event, plateFrame)
			--ViragDevTool_AddData({ctime = GetTime(), unit = plateFrame [MEMBER_UNITID] or "nil", stack = debugstack()}, "NAME_PLATE_CREATED - " .. (plateFrame [MEMBER_UNITID] or "nil"))
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
					FillOnInterrupt = false,
					HideSparkOnInterrupt = false,
				}
				
				local powerBarOptions = {
					ShowAlternatePower = false,
				}
				
				--community patch by Ariani#0960 (discord)
				--make the unitFrame be parented to UIParent allowing frames to be moved between strata levels
				--March 3rd, 2019
				local newUnitFrame
				if (DB_USE_UIPARENT) then
					--TODO: why is it not showing properly when V / V hide / show but when leaving / entering scren??? -> plateFrame for now...
					--when using UIParent as the unit frame parent, adjust the unitFrame scale to be equal to blizzard plateFrame
					newUnitFrame = DF:CreateUnitFrame (UIParent, plateFrame:GetName() .. "PlaterUnitFrame", unitFrameOptions, healthBarOptions, castBarOptions, powerBarOptions)
					newUnitFrame:SetAllPoints()
					newUnitFrame:SetFrameStrata ("BACKGROUND")

					--plateFrame:HookScript("OnSizeChanged", Plater.UpdateUIParentScale)
					
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
					newUnitFrame = DF:CreateUnitFrame (plateFrame, plateFrame:GetName() .. "PlaterUnitFrame", unitFrameOptions, healthBarOptions, castBarOptions, powerBarOptions)
				end

				plateFrame.unitFrame = newUnitFrame
				--plateFrame.unitFrame:SetPoint("center", plateFrame)
				plateFrame.unitFrame:EnableMouse(false)
				
				--mix plater functions (most are for scripting support) into the unit frame
				DF:Mixin(newUnitFrame, Plater.ScriptMetaFunctions)
				
				--OnHide handler
				newUnitFrame:HookScript("OnHide", newUnitFrame.OnHideWidget)

				--OnHealthUpdate
				newUnitFrame.healthBar:SetHook("OnHealthChange", Plater.OnHealthChange)
				newUnitFrame.healthBar:SetHook("OnHealthMaxChange", Plater.OnHealthMaxChange)
				
				--register details framework hooks
				newUnitFrame.castBar:SetHook("OnShow", Plater.CastBarOnShow_Hook)
				hooksecurefunc(newUnitFrame.castBar, "OnEvent", Plater.CastBarOnEvent_Hook)
				hooksecurefunc(newUnitFrame.castBar, "OnTick", Plater.CastBarOnTick_Hook)
				
				newUnitFrame.HasHooksRegistered = true
				
				--to ensure all applies
				newUnitFrame:UpdateTargetOverlay()
				
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
				plateFrame.unitFrame.BuffFrame = CreateFrame ("frame", plateFrame.unitFrame:GetName() .. "BuffFrame1", plateFrame.unitFrame, BackdropTemplateMixin and "BackdropTemplate")
				plateFrame.unitFrame.BuffFrame.amountAurasShown = 0
				plateFrame.unitFrame.BuffFrame.PlaterBuffList = {}
				plateFrame.unitFrame.BuffFrame.isNameplate = true
				plateFrame.unitFrame.BuffFrame.unitFrame = plateFrame.unitFrame --used on resource frame anchor update
				plateFrame.unitFrame.BuffFrame.healthBar = plateFrame.unitFrame.healthBar
				plateFrame.unitFrame.BuffFrame.AuraCache = {}
				
				--secondary buff frame
				plateFrame.unitFrame.BuffFrame2 = CreateFrame ("frame", plateFrame.unitFrame:GetName() .. "BuffFrame2", plateFrame.unitFrame, BackdropTemplateMixin and "BackdropTemplate")
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
			
			--> unit aura cache
			plateFrame.unitFrame.AuraCache = {}
			plateFrame.unitFrame.GhostAuraCache = {}
			plateFrame.unitFrame.ExtraAuraCache = {}
			
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
				healthBar.FrameOverlay = CreateFrame ("frame", "$parentOverlayFrame", healthBar, BackdropTemplateMixin and "BackdropTemplate")
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
				
				--shield indicator
				local shieldIndicator = healthBar:CreateTexture(nil, "overlay", nil, 7)
				shieldIndicator:SetPoint("bottomleft", healthBar, "bottomleft", 0, 0)
				shieldIndicator:SetHeight(3)
				shieldIndicator:SetTexture([[Interface\AddOns\Plater\images\shieldbar]])
				shieldIndicator:SetAlpha(0.85)
				shieldIndicator:Hide()
				healthBar.shieldIndicator = shieldIndicator

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
				PixelUtil.SetPoint (executeGlowUp, "bottomright", healthBar, "topright", 0, 0)
				PixelUtil.SetPoint (executeGlowUp, "bottomleft", healthBar, "topleft", 0, 0)
				healthBar.ExecuteGlowUp = executeGlowUp
				
				local executeGlowDown = healthBar:CreateTexture (nil, "overlay")
				executeGlowDown:SetTexture ([[Interface\AddOns\Plater\images\blue_neon]])
				executeGlowDown:SetTexCoord (0, 1, 0.5, 1)
				executeGlowDown:SetHeight (32)
				executeGlowDown:SetBlendMode ("ADD")
				executeGlowDown:Hide()
				PixelUtil.SetPoint (executeGlowDown, "topright", healthBar, "bottomright", 0, 0)
				PixelUtil.SetPoint (executeGlowDown, "topleft", healthBar, "bottomleft", 0, 0)
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
				plateFrame.unitFrame.PlaterRaidTargetFrame = CreateFrame ("frame", nil, plateFrame.unitFrame, BackdropTemplateMixin and "BackdropTemplate")
				--plateFrame.unitFrame.PlaterRaidTargetFrame = CreateFrame ("frame", nil, plateFrame.unitFrame.healthBar, BackdropTemplateMixin and "BackdropTemplate")
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
				local onTickFrame = CreateFrame ("frame", nil, plateFrame, BackdropTemplateMixin and "BackdropTemplate")
				plateFrame.OnTickFrame = onTickFrame
				onTickFrame.unit = plateFrame [MEMBER_UNITID]
				onTickFrame.HealthBar = healthBar
				onTickFrame.PlateFrame = plateFrame
				onTickFrame.unitFrame = plateFrame.unitFrame
				onTickFrame.BuffFrame = plateFrame.unitFrame.BuffFrame
				onTickFrame.BuffFrame2 = plateFrame.unitFrame.BuffFrame2
				
				
				--> create a second castbar
				local castBar2 = DF:CreateCastBar (plateFrame.unitFrame, "$parentCastBar2")
				plateFrame.unitFrame.castBar2 = castBar2
				castBar2.Icon:ClearAllPoints()
				castBar2.Icon:SetPoint("right", castBar2, "left", -1, 0)

				castBar2.FrameOverlay = CreateFrame ("frame", "$parentOverlayFrame", castBar2, BackdropTemplateMixin and "BackdropTemplate")
				castBar2.FrameOverlay:SetAllPoints()

				--pushing the spell name up
				castBar2.Text:SetParent (castBar2.FrameOverlay)
				
				--does have a border but its alpha is zero by default
				castBar2.FrameOverlay:SetBackdrop ({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1})
				castBar2.FrameOverlay:SetBackdropBorderColor (1, 1, 1, 0)
				castBar2:SetPoint("topleft", plateFrame.unitFrame.castBar, "bottomleft", 0, -2)
				castBar2:SetPoint("topright", plateFrame.unitFrame.castBar, "bottomright", 0, -2)

			
			--> unit name
				--regular name
				plateFrame.unitFrame.unitName:SetParent (healthBar) --the name is parented to unitFrame in the framework, parent it to health bar
				healthBar.unitName = plateFrame.unitFrame.unitName
				healthBar.PlateFrame = plateFrame
				plateFrame.unitName = plateFrame.unitFrame.unitName
				plateFrame.CurrentUnitNameString = plateFrame.unitFrame.unitName
				healthBar.unitName:SetDrawLayer ("overlay", 7)
				
				--special name and title
				local ActorNameSpecial = plateFrame.unitFrame:CreateFontString (nil, "artwork", "GameFontNormal")
				plateFrame.unitFrame.ActorNameSpecial = ActorNameSpecial --alias for scripts
				plateFrame.ActorNameSpecial = ActorNameSpecial
				PixelUtil.SetPoint (plateFrame.ActorNameSpecial, "center", plateFrame, "center", 0, 0)
				plateFrame.ActorNameSpecial:Hide()
				
				local ActorTitleSpecial = plateFrame.unitFrame:CreateFontString (nil, "artwork", "GameFontNormal")
				plateFrame.unitFrame.ActorTitleSpecial = ActorTitleSpecial --alias for scripts
				plateFrame.ActorTitleSpecial = ActorTitleSpecial
				PixelUtil.SetPoint (plateFrame.ActorTitleSpecial, "top", ActorNameSpecial, "bottom", 0, -2)
				plateFrame.ActorTitleSpecial:Hide()
				
				
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

				obscuredTexture.Mask = healthBar:CreateMaskTexture(nil, "artwork")
				obscuredTexture.Mask:SetAllPoints(obscuredTexture)
				obscuredTexture.Mask:SetTexture([[Interface\AddOns\Plater\masks\mask1]])
				obscuredTexture.Mask:Hide()
				obscuredTexture:AddMaskTexture(obscuredTexture.Mask)

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
				local castBar = plateFrame.unitFrame.castBar
				castBar.PlateFrame = plateFrame
				castBar.unitFrame = plateFrame.unitFrame
				castBar.IsCastBar = true
				castBar.isNamePlate = true
				castBar.ThrottleUpdate = 0
				
				--check if Masque is enabled on Plater and reskin the cast icon
				local castIconFrame = castBar.Icon
				if (Plater.Masque and not castIconFrame.Masqued) then
					--as masque only skins buttons and not textures alone, work around that with a dummy frame and some meta-table shenannigans to not break anything...
					--create the button frame and anchor the original icon within
					local dummyMasqueIconButton = CreateFrame ("Button", castBar:GetName() .. "dummyMasqueIconButton", castBar, BackdropTemplateMixin and "BackdropTemplate")
					dummyMasqueIconButton:SetSize(castIconFrame:GetSize())
					castIconFrame:ClearAllPoints()
					castIconFrame:SetParent(dummyMasqueIconButton)
					castIconFrame:SetPoint("TOPLEFT")
					castIconFrame:SetPoint("BOTTOMRIGHT")
					
					dummyMasqueIconButton:EnableMouse (false)
					if dummyMasqueIconButton.EnableMouseMotion then
						dummyMasqueIconButton:EnableMouseMotion (false)
					end
					
					castIconFrame:Show()
					
					--overwrite original and keep a reference
					dummyMasqueIconButton.Icon = castIconFrame
					castBar.IconOrig = castIconFrame
					castBar.Icon = dummyMasqueIconButton
					
					--now ensure all calls to the icon which are directed towards the original texture are re-routed to the icon texture
					local origIndex = getmetatable(dummyMasqueIconButton).__index
					local metaTable = {
						__index = function (t,k)
							--print(k, rawget(dummyMasqueIconButton, k), rawget(origIndex, k), castIconFrame[k])
							local v = rawget(dummyMasqueIconButton, k) or rawget(origIndex, k)
							if not v then
								v = castIconFrame[k]--rawget(castIconFrame, k) or rawget(getmetatable(castIconFrame).__index, k) or rawget(t, k)
								if type(v) == "function" then
									return function(self, ...) return castIconFrame[k](castIconFrame, ...) end
								end
							end
							return v
						end,
					
						__newindex = function (t,k,v)
							rawset(t, k, v)
						end
						
					}
					setmetatable(dummyMasqueIconButton, metaTable)
					dummyMasqueIconButton:Show()
					
					-- now skin!
					local t = {
						Icon = castIconFrame,
					}
					Plater.Masque.CastIcon:AddButton (dummyMasqueIconButton, t, "Frame", true)
					Plater.Masque.CastIcon:ReSkin(dummyMasqueIconButton)
					castIconFrame.Masqued = true
					dummyMasqueIconButton.Masqued = true
				end
				
				--mix the plater functions into the castbar (most of the functions are for scripting support)
				DF:Mixin (castBar, Plater.ScriptMetaFunctions)
				castBar:HookScript ("OnHide", castBar.OnHideWidget)
				
				--> create an overlay frame that sits just above the castbar
				--this is ideal for adding borders and other overlays
				castBar.FrameOverlay = CreateFrame ("frame", "$parentOverlayFrame", castBar, BackdropTemplateMixin and "BackdropTemplate")
				castBar.FrameOverlay:SetAllPoints()

				--create a frame that are always below the castbar, this frame help with extra backdrops
				--textures, animations are need to be placed below the cast bar
				castBar.FrameDownlayer = CreateFrame ("frame", "$parentDownlayerFrame", castBar, BackdropTemplateMixin and "BackdropTemplate")
				castBar.FrameDownlayer:SetFrameLevel(castBar:GetFrameLevel()-1)
				castBar.FrameDownlayer:SetAllPoints()

				--pushing the spell name and timer up
				castBar.Text:SetParent (castBar.FrameOverlay)
				castBar.percentText:SetParent (castBar.FrameOverlay)
				--does have a border but its alpha is zero by default
				castBar.FrameOverlay:SetBackdrop ({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1})
				castBar.FrameOverlay:SetBackdropBorderColor (1, 1, 1, 0)
				--creates the target name overlay which shows who the unit is targetting while casting (this is disabled by default)
				castBar.FrameOverlay.TargetName = castBar.FrameOverlay:CreateFontString (nil, "overlay", "GameFontNormal")
				castBar.TargetName = castBar.FrameOverlay.TargetName --alias for scripts
			
				--> create the spell color texture
				castBar.castColorTexture = castBar:CreateTexture("$parentCastColor", "background", nil, -6)

				--create custom border frame for modeling
				if (Plater.CreateCustomDesignBorder) then
					Plater.CreateCustomDesignBorder(castBar)
				end

			--> border
				--create a border using default borders from the retail game
				local healthBarBorder = DF:CreateFullBorder(nil, plateFrame.unitFrame.healthBar)
				local borderOffset = 0 -- -1 * UIParent:GetEffectiveScale() * (Plater.db.profile.use_ui_parent_just_enabled and Plater.db.profile.ui_parent_scale_tune or 1)
				PixelUtil.SetPoint (healthBarBorder, "TOPLEFT", plateFrame.unitFrame.healthBar, "TOPLEFT", -borderOffset, borderOffset)
				PixelUtil.SetPoint (healthBarBorder, "TOPRIGHT", plateFrame.unitFrame.healthBar, "TOPRIGHT", borderOffset, borderOffset)
				PixelUtil.SetPoint (healthBarBorder, "BOTTOMLEFT", plateFrame.unitFrame.healthBar, "BOTTOMLEFT", -borderOffset, -borderOffset)
				PixelUtil.SetPoint (healthBarBorder, "BOTTOMRIGHT", plateFrame.unitFrame.healthBar, "BOTTOMRIGHT", borderOffset, -borderOffset)
				healthBarBorder.Left:SetDrawLayer("OVERLAY", 6)
				healthBarBorder.Right:SetDrawLayer("OVERLAY", 6)
				healthBarBorder.Top:SetDrawLayer("OVERLAY", 6)
				healthBarBorder.Bottom:SetDrawLayer("OVERLAY", 6)
				plateFrame.unitFrame.healthBar.border = healthBarBorder
				
				local powerBarBorder = DF:CreateFullBorder(nil, plateFrame.unitFrame.powerBar)
				PixelUtil.SetPoint (powerBarBorder, "TOPLEFT", plateFrame.unitFrame.powerBar, "TOPLEFT", -borderOffset, borderOffset)
				PixelUtil.SetPoint (powerBarBorder, "TOPRIGHT", plateFrame.unitFrame.powerBar, "TOPRIGHT", borderOffset, borderOffset)
				PixelUtil.SetPoint (powerBarBorder, "BOTTOMLEFT", plateFrame.unitFrame.powerBar, "BOTTOMLEFT", -borderOffset, -borderOffset)
				PixelUtil.SetPoint (powerBarBorder, "BOTTOMRIGHT", plateFrame.unitFrame.powerBar, "BOTTOMRIGHT", borderOffset, -borderOffset)
				powerBarBorder.Left:SetDrawLayer("OVERLAY", 6)
				powerBarBorder.Right:SetDrawLayer("OVERLAY", 6)
				powerBarBorder.Top:SetDrawLayer("OVERLAY", 6)
				powerBarBorder.Bottom:SetDrawLayer("OVERLAY", 6)
				plateFrame.unitFrame.powerBar.border = powerBarBorder
				powerBarBorder:SetVertexColor (0, 0, 0, 1)

				--create custom border frame for modeling
				if (Plater.CreateCustomDesignBorder) then
					Plater.CreateCustomDesignBorder(healthBar)
				end

				--create custom border frame for modeling
				if (Plater.CreateCustomDesignBorder) then
					Plater.CreateCustomDesignBorder(plateFrame.unitFrame.powerBar)
				end
			
			--> focus indicator
				local focusIndicator = healthBar:CreateTexture(nil, "overlay")
				focusIndicator:SetDrawLayer("overlay", 2)
				PixelUtil.SetPoint(focusIndicator, "topleft", healthBar, "topleft", 0, 0)
				PixelUtil.SetPoint(focusIndicator, "bottomright", healthBar, "bottomright", 0, 0)
				focusIndicator:Hide()
				healthBar.FocusIndicator = focusIndicator
				plateFrame.FocusIndicator = focusIndicator
				plateFrame.unitFrame.FocusIndicator = focusIndicator
			
			--> low aggro warning
				plateFrame.unitFrame.aggroGlowUpper = plateFrame:CreateTexture (nil, "background", nil, -4)
				PixelUtil.SetPoint (plateFrame.unitFrame.aggroGlowUpper, "bottomleft", plateFrame.unitFrame.healthBar, "topleft", -3, 0)
				PixelUtil.SetPoint (plateFrame.unitFrame.aggroGlowUpper, "bottomright", plateFrame.unitFrame.healthBar, "topright", 3, 0)
				plateFrame.unitFrame.aggroGlowUpper:SetTexture ([[Interface\BUTTONS\UI-Panel-Button-Glow]])
				plateFrame.unitFrame.aggroGlowUpper:SetTexCoord (0, 95/128, 0, 9/64)
				plateFrame.unitFrame.aggroGlowUpper:SetBlendMode ("ADD")
				plateFrame.unitFrame.aggroGlowUpper:SetHeight (4)
				plateFrame.unitFrame.aggroGlowUpper:Hide()
				
				plateFrame.unitFrame.aggroGlowLower = plateFrame:CreateTexture (nil, "background", nil, -4)
				PixelUtil.SetPoint (plateFrame.unitFrame.aggroGlowLower, "topleft", plateFrame.unitFrame.healthBar, "bottomleft", -3, 0)
				PixelUtil.SetPoint (plateFrame.unitFrame.aggroGlowLower, "topright", plateFrame.unitFrame.healthBar, "bottomright", 3, 0)
				plateFrame.unitFrame.aggroGlowLower:SetTexture ([[Interface\BUTTONS\UI-Panel-Button-Glow]])
				plateFrame.unitFrame.aggroGlowLower:SetTexCoord (0, 95/128, 30/64, 38/64)
				plateFrame.unitFrame.aggroGlowLower:SetBlendMode ("ADD")
				plateFrame.unitFrame.aggroGlowLower:SetHeight (4)
				plateFrame.unitFrame.aggroGlowLower:Hide()

			--> soft-interact icon
				plateFrame.unitFrame.softInteractIconFrame = CreateFrame ("frame",plateFrame.unitFrame:GetName() .. "softInteractIconFrame", plateFrame, BackdropTemplateMixin and "BackdropTemplate")
				plateFrame.unitFrame.softInteractIcon = plateFrame.unitFrame.softInteractIconFrame:CreateTexture("$parentIcon", "OVERLAY")
				plateFrame.unitFrame.softInteractIcon:SetParent(plateFrame)
				plateFrame.unitFrame.softInteractIcon:SetTexture(136243)
				plateFrame.unitFrame.softInteractIcon:Show()
				plateFrame.unitFrame.softInteractIconFrame:SetFrameLevel(plateFrame.unitFrame.healthBar:GetFrameLevel() + 25)
				plateFrame.unitFrame.softInteractIconFrame.Mask = plateFrame.unitFrame.softInteractIconFrame:CreateMaskTexture(nil, "OVERLAY", nil, 1)
				plateFrame.unitFrame.softInteractIconFrame.Mask:Show()
				plateFrame.unitFrame.softInteractIconFrame.Mask:SetAtlas("CircleMaskScalable", true)
				--plateFrame.unitFrame.softInteractIconFrame.Mask:SetScale(1)
				plateFrame.unitFrame.softInteractIcon:AddMaskTexture(plateFrame.unitFrame.softInteractIconFrame.Mask)
				plateFrame.unitFrame.softInteractIconFrame.Mask:ClearAllPoints()
				PixelUtil.SetPoint(plateFrame.unitFrame.softInteractIconFrame.Mask, "CENTER", plateFrame.unitFrame.softInteractIconFrame, "CENTER", 0, 0)
				plateFrame.unitFrame.softInteractIconFrame.Mask:SetAllPoints(plateFrame.unitFrame.softInteractIcon)
				plateFrame.unitFrame.softInteractIconFrame:Hide()
				plateFrame.unitFrame.softInteractIcon.anchor = { side = 8, x = 0, y = 18, }
				plateFrame.unitFrame.softInteractIcon.size = 24
				--Plater.SetAnchor(plateFrame.unitFrame.softInteractIconFrame, plateFrame.unitFrame.softInteractIcon.anchor or { side = 8, x = 0, y = 18, }, plateFrame.unitFrame.healthBar)
				--Plater.SetAnchor(plateFrame.unitFrame.softInteractIconFrame, plateFrame.unitFrame.softInteractIcon.anchor or { side = 8, x = 0, y = 18, }, plateFrame.unitFrame.PlateFrame)
			
			--> name plate created hook
				if (HOOK_NAMEPLATE_CREATED.ScriptAmount > 0) then
					for i = 1, HOOK_NAMEPLATE_CREATED.ScriptAmount do
						local globalScriptObject = HOOK_NAMEPLATE_CREATED [i]
						local scriptContainer = plateFrame.unitFrame:ScriptGetContainer()
						local scriptInfo = plateFrame.unitFrame:HookGetInfo (globalScriptObject, scriptContainer, "Nameplate Created")
						plateFrame.unitFrame:ScriptRunHook (scriptInfo, "Nameplate Created")
					end
				end
		end,
		
		---@param event string
		---@param unitBarId string
		FORBIDDEN_NAME_PLATE_UNIT_ADDED = function (event, unitBarId)
			local unitID = unitBarId
		
			local plateFrame = C_NamePlate.GetNamePlateForUnit (unitID, true)
			if (plateFrame) then -- and plateFrame.template == "ForbiddenNamePlateUnitFrameTemplate"
			
				if (not IS_WOW_PROJECT_MAINLINE) then
					-- this is for classic cast bars on blizzard default nameplates
					if GetCVarBool ("nameplateShowOnlyNames") or Plater.db.profile.saved_cvars.nameplateShowOnlyNames == "1" then
						TextureLoadingGroupMixin.RemoveTexture({ textures = plateFrame.UnitFrame.CastBar }, "showCastbar")
					else
						TextureLoadingGroupMixin.AddTexture({ textures = plateFrame.UnitFrame.CastBar }, "showCastbar")
					end
				end
			end
		end,

		-- ~added ãdded 
		---@param event string
		---@param unitBarId string
		NAME_PLATE_UNIT_ADDED = function (event, unitBarId)
			--ViragDevTool_AddData({ctime = GetTime(), unit = unitBarId or "nil", stack = debugstack()}, "NAME_PLATE_UNIT_ADDED - " .. (unitBarId or "nil"))
			--debug for hunter faith death
--			if (select (2, UnitClass (unitBarId)) == "HUNTER") then
--				print ("nameplate added", UnitName (unitBarId))
--			end
		
			local unitID = unitBarId

			---@type plateframe
			local plateFrame = C_NamePlate.GetNamePlateForUnit (unitID)
			if (not plateFrame) then
				--try forbidden as well for hiding stuff
				plateFrame = C_NamePlate.GetNamePlateForUnit (unitID, true)
				if (plateFrame) then
					if (not IS_WOW_PROJECT_MAINLINE) then
						if GetCVarBool ("nameplateShowOnlyNames") or Plater.db.profile.saved_cvars.nameplateShowOnlyNames == "1" then
							TextureLoadingGroupMixin.RemoveTexture({ textures = plateFrame.UnitFrame.CastBar }, "showCastbar")
						else
							TextureLoadingGroupMixin.AddTexture({ textures = plateFrame.UnitFrame.CastBar }, "showCastbar")
						end
					end
				end
				return
			end
			
			--> check the unit frame integrity, several times some weakaura or script mess with the unit frame
			if (not plateFrame.unitFrame or not plateFrame.unitFrame.SetUnit) then
				plateFrame.unitFrame = plateFrame.unitFramePlater
			end
			
			--get and format the reaction to always be the value of the constants, then cache the reaction in some widgets for performance
			Plater.UpdateSoftInteractTarget(plateFrame)
			local reaction = UnitReaction (unitID, "player")
			local isSoftInteract = plateFrame.isSoftInteract
			local isObject = plateFrame.isObject
			local isSoftInteractObject = isObject and isSoftInteract
			reaction = reaction or isSoftInteract and Plater.UnitReaction.UNITREACTION_NEUTRAL or Plater.UnitReaction.UNITREACTION_HOSTILE
			reaction = reaction <= Plater.UnitReaction.UNITREACTION_HOSTILE and Plater.UnitReaction.UNITREACTION_HOSTILE or reaction >= Plater.UnitReaction.UNITREACTION_FRIENDLY and Plater.UnitReaction.UNITREACTION_FRIENDLY or Plater.UnitReaction.UNITREACTION_NEUTRAL
			
			local isWidgetOnlyMode = (IS_WOW_PROJECT_MAINLINE) and UnitNameplateShowsWidgetsOnly (unitID) or false
			local isBattlePet = (IS_WOW_PROJECT_MAINLINE) and UnitIsBattlePet(unitID) or false
			local isPlayer = UnitIsPlayer (unitID)
			local isSelf = UnitIsUnit (unitID, "player")
			
			plateFrame [MEMBER_NPCID] = nil
			plateFrame.unitFrame [MEMBER_NPCID] = nil
			plateFrame [MEMBER_GUID] = UnitGUID (unitID) or ""
			plateFrame.unitFrame [MEMBER_GUID] = plateFrame [MEMBER_GUID]
			
			if (not isPlayer) then
				Plater.GetNpcID (plateFrame)
			end
			
			local actorType
			if (unitID) then
				
				if (isSelf) then
					--> personal health bar
					actorType = ACTORTYPE_PLAYER
					
				else
					--> regular nameplate
					
					if (isPlayer) then
						--unit is a player
						
						if (reaction >= Plater.UnitReaction.UNITREACTION_FRIENDLY) then
							actorType = ACTORTYPE_FRIENDLY_PLAYER
							
						else
							actorType = ACTORTYPE_ENEMY_PLAYER
							
						end
					else
						--the unit is a npc
						
						if (reaction >= Plater.UnitReaction.UNITREACTION_FRIENDLY) then
							actorType = ACTORTYPE_FRIENDLY_NPC
							
						elseif isBattlePet then
							actorType = ACTORTYPE_FRIENDLY_NPC
							
						else
							--includes neutral npcs
							actorType = ACTORTYPE_ENEMY_NPC
							
						end
					end
				end
			end
			local isPlateEnabled = not isSoftInteractObject and (DB_PLATE_CONFIG [actorType].module_enabled and not isWidgetOnlyMode) or (not Plater.db.profile.ignore_softinteract_objects and isSoftInteractObject)
			isPlateEnabled = (isPlayer or not Plater.ForceBlizzardNameplateUnits[plateFrame [MEMBER_NPCID]]) and isPlateEnabled
			
			local blizzardPlateFrameID = tostring(plateFrame.UnitFrame)
			plateFrame.unitFrame.blizzardPlateFrameID = blizzardPlateFrameID
			
			--if (not plateFrame.UnitFrame.HasPlaterHooksRegistered) then
			if not HOOKED_BLIZZARD_PLATEFRAMES[blizzardPlateFrameID] then
				--print(HOOKED_BLIZZARD_PLATEFRAMES[tostring(plateFrame.UnitFrame)], tostring(plateFrame.UnitFrame), plateFrame.UnitFrame.HasPlaterHooksRegistered)
                --hook the retail nameplate
                --plateFrame.UnitFrame:HookScript("OnShow", Plater.OnRetailNamePlateShow)
				hooksecurefunc(plateFrame.UnitFrame, "Show", Plater.OnRetailNamePlateShow)
                --plateFrame.UnitFrame.HasPlaterHooksRegistered = true
				HOOKED_BLIZZARD_PLATEFRAMES[blizzardPlateFrameID] = true
				
            end
			
			-- we should clear stuff here, tbh...
			
			if isPlateEnabled then
				ENABLED_BLIZZARD_PLATEFRAMES[blizzardPlateFrameID] = false
				
			else
				plateFrame.unitFrame.PlaterOnScreen = false
				ENABLED_BLIZZARD_PLATEFRAMES[blizzardPlateFrameID] = true
				plateFrame.unitFrame:Hide()
				
				-- this is for classic cast bars on blizzard default nameplates
				if (not IS_WOW_PROJECT_MAINLINE) then
					if GetCVarBool ("nameplateShowOnlyNames") or Plater.db.profile.saved_cvars.nameplateShowOnlyNames == "1" then
						TextureLoadingGroupMixin.RemoveTexture({ textures = plateFrame.UnitFrame.CastBar }, "showCastbar")
					else
						TextureLoadingGroupMixin.AddTexture({ textures = plateFrame.UnitFrame.CastBar }, "showCastbar")
					end
				end
				
				return
			end
			
			local requiresScheduledUpdate = false
			if not NAMEPLATES_ON_SCREEN_CACHE[unitID] then
				NAMEPLATES_ON_SCREEN_CACHE[unitID] = true
				NUM_NAMEPLATES_ON_SCREEN = NUM_NAMEPLATES_ON_SCREEN + 1
			else
				requiresScheduledUpdate = true
			end
			
			--hide blizzard namepaltes
			--plateFrame.UnitFrame:Hide()
			Plater.OnRetailNamePlateShow(plateFrame.UnitFrame)
			--show plater unit frame
			plateFrame.unitFrame:Show()
			
			plateFrame.unitFrame.PlaterOnScreen = true
			
			Plater.AddToAuraUpdate(unitID)
			-- update DBM and BigWigs nameplate auras
			Plater.EnsureUpdateBossModAuras(plateFrame [MEMBER_GUID])
			
			--save the last unit type shown in this plate
			plateFrame.PreviousUnitType = plateFrame.actorType
			
			--caching frames
			local unitFrame = plateFrame.unitFrame
			local castBar = unitFrame.castBar
			local healthBar = unitFrame.healthBar

			unitFrame.IsNeutralOrHostile = actorType == ACTORTYPE_ENEMY_NPC or actorType == ACTORTYPE_ENEMY_PLAYER
			
			if (unitFrame.ShowUIParentAnimation) then
				unitFrame.ShowUIParentAnimation:Play()
			end
			
			unitFrame.nameplateScaleAdjust = 1
			
			if (DB_USE_UIPARENT) then
				plateFrame:HookScript("OnSizeChanged", Plater.UpdateUIParentScale)
				Plater.UpdateUIParentScale(plateFrame)
			else
				unitFrame:SetScale (1) --reset scale
			end
			
			--check if the hide hook is registered on this Blizzard nameplate
			if (not unitFrame.HasHideHookRegistered) then
				--onHide for unitFrame
				plateFrame.unitFrame:HookScript ("OnHide", unitFrame.OnHideWidget)
				--onShow for castbar
				castBar:SetHook ("OnShow", Plater.CastBarOnShow_Hook)
			
				unitFrame.HasHideHookRegistered = true
			end
			
			--powerbar are disabled by default in the settings table, called SetUnit will make the framework hide the power bar
			--SetPowerBarSize() will show the power bar or the personal resource bar update also will show it
			
			--ensure castBar is enabled properly when switching actorType or unit (with unit changing, it will be properly enabled)
			local castBarWasEnabled = (unitFrame.Settings.ShowCastBar and (plateFrame.PreviousUnitType == actorType)) or (unitFrame.unit ~= unitID)
			unitFrame.Settings.ShowCastBar = true -- reset to default, clearing later.
		
			--set the unit
			unitFrame:SetUnit (unitID)
			
			--reset performance unit
			unitFrame.isPerformanceUnit = nil
			unitFrame.healthBar.isPerformanceUnit = nil
			
			if (Plater.PerformanceUnits[plateFrame[MEMBER_NPCID]]) then
				--print("perf", plateFrame[MEMBER_NPCID])
				unitFrame.castBar:SetUnit(nil) -- no casts
				Plater.RemoveFromAuraUpdate (unitID) -- no auras
				unitFrame.isPerformanceUnit = true
				unitFrame.healthBar.isPerformanceUnit = true
			end
			
			--show unit name, the frame work will hide it due to ShowUnitName is set to false
			unitFrame.unitName:Show()
			
			--set the unitID in the unitFrame, several script and external addons read this member, adding different variations to be compatible with all
			unitFrame.unit = unitID
			unitFrame.namePlateUnitToken = unitID
			unitFrame.displayedUnit = unitID
			unitFrame.DenyColorChange = nil
			
			--was causing taints because MEMBER_UNITID is an actually member from the default blizzard nameplate
			--so when this nameplate is reclycled to be in a proteecteed nameplate, it was causing taints
			--plateFrame [MEMBER_UNITID] = unitID --causing taints
			
			plateFrame.QuestAmountCurrent = nil
			plateFrame.QuestAmountTotal = nil
			plateFrame.QuestText = nil
			plateFrame.QuestName = nil
			plateFrame.QuestIsCampaign = nil
			unitFrame.QuestAmountCurrent = nil
			unitFrame.QuestAmountTotal = nil
			unitFrame.QuestText = nil
			unitFrame.QuestName = nil
			unitFrame.QuestIsCampaign = nil
			
			--cache the unit target id, so it doesnt need to waste cycles building up on aggro checks
			unitFrame.targetUnitID = unitID .. "target"

			--clear values
			plateFrame.CurrentUnitNameString = plateFrame.unitName
			
			plateFrame.isSelf = nil
			plateFrame.IsSelf = nil
			unitFrame.IsSelf = nil --value exposed to scripts
			castBar.IsSelf = nil --value exposed to scripts

			unitFrame.unitName.isRenamed = nil
			
			plateFrame.PlayerCannotAttack = nil
			plateFrame.playerGuildName = nil
			plateFrame [MEMBER_NOCOMBAT] = nil
			
			plateFrame [MEMBER_TARGET] = nil
			unitFrame [MEMBER_TARGET] = nil
			
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
			
			unitFrame.IsInRange = nil
			
			--check if this nameplate has an update scheduled and cancel it in any case
			if (plateFrame.HasUpdateScheduled) then
				if (not plateFrame.HasUpdateScheduled._cancelled) then
					plateFrame.HasUpdateScheduled:Cancel()
				end
				plateFrame.HasUpdateScheduled = nil
			end
			
			if requiresScheduledUpdate then --this COULD counter some rare issues with feign death instant cancel where nameplate hide/show is weird
				Plater.ScheduleUpdateForNameplate (plateFrame, unitID, 0.5) --half second enough maybe
			end
			
			--cache values
			local unitName = UnitName (unitID) or ""
			local unitNameTranslit = unitName
			if DB_USE_NAME_TRANSLIT then
				unitNameTranslit = LibTranslit:Transliterate(unitName, TRANSLIT_MARK)
			end
			plateFrame [MEMBER_NAME] = unitNameTranslit
			plateFrame [MEMBER_NAMELOWER] = lower (plateFrame [MEMBER_NAME])
			plateFrame ["namePlateClassification"] = UnitClassification (unitID)
			plateFrame.unitNameInternal = unitName
			
			--clear name schedules
			unitFrame.ScheduleNameUpdate = nil
			
			unitFrame.InCombat = UnitAffectingCombat (unitID) or (Plater.ForceInCombatUnits[unitFrame [MEMBER_NPCID]] and PLAYER_IN_COMBAT) or false
			
			--cache values into the unitFrame as well to reduce the overhead on scripts and hooks
			unitFrame [MEMBER_NAME] = plateFrame [MEMBER_NAME]
			unitFrame [MEMBER_NAMELOWER] = plateFrame [MEMBER_NAMELOWER]
			unitFrame ["namePlateClassification"] = plateFrame ["namePlateClassification"]
			unitFrame.unitNameInternal = unitName
			unitFrame [MEMBER_UNITID] = unitID
			unitFrame.namePlateThreatPercent = 0
			unitFrame.namePlateThreatIsTanking = nil
			unitFrame.namePlateThreatStatus = nil
			unitFrame.namePlateThreatOffTankIsTanking = false
			unitFrame.namePlateThreatOffTankName = nil
			
			plateFrame [MEMBER_REACTION] = reaction
			unitFrame [MEMBER_REACTION] = reaction
			unitFrame.BuffFrame [MEMBER_REACTION] = reaction
			unitFrame.BuffFrame2 [MEMBER_REACTION] = reaction
			unitFrame.BuffFrame.unit = unitID
			unitFrame.BuffFrame2.unit = unitID
			unitFrame.ExtraIconFrame.unit = unitID
			
			plateFrame.isBattlePet = isBattlePet
			unitFrame.isBattlePet = isBattlePet
			
			plateFrame.isWidgetOnlyMode = isWidgetOnlyMode
			unitFrame.isWidgetOnlyMode = isWidgetOnlyMode
			
			plateFrame.isPlayer = isPlayer
			unitFrame.isPlayer = isPlayer
			
			--clear the custom indicators table
			wipe (unitFrame.CustomIndicators)
			
			--health amount
			Plater.QuickHealthUpdate (unitFrame)
			healthBar.IsAnimating = false
			
			--hide execute indicators
			healthBar.healthCutOff:Hide()
			healthBar.executeRange:Hide()
			healthBar.ExecuteGlowUp:Hide()
			healthBar.ExecuteGlowDown:Hide()
			
			--reset color values
			healthBar.R, healthBar.G, healthBar.B, healthBar.A = nil, nil, nil, nil
			
			--reset the frame level and strata if using UIParent as the parent of the unitFrame
			--the function checks if the option is enabled, no need to check here
			Plater.UpdateUIParentLevels (unitFrame)
			
			if (unitFrame.unit) then
				
				if (isSelf) then
					--> personal health bar
					plateFrame.isSelf = true
					plateFrame.IsSelf = true
					unitFrame.IsSelf = true --this is the value exposed to scripts
					castBar.IsSelf = true --this is the value exposed to scripts
					plateFrame.NameAnchor = 0
					plateFrame.PlayerCannotAttack = true
					unitFrame.PlayerCannotAttack = true
					
					--do not allow the framework to show the unit name
					unitFrame.Settings.ShowUnitName = false
					unitFrame.unitName:Hide()
					
					--setup castbar
					unitFrame.Settings.ShowCastBar = DB_PLATE_CONFIG.player.castbar_enabled
					if (not DB_PLATE_CONFIG.player.castbar_enabled) then
						--CastingBarFrame_SetUnit (castBar, nil, nil, nil)
						unitFrame.castBar:SetUnit(nil, nil)
					elseif not castBarWasEnabled then
						unitFrame.castBar:SetUnit (unitID, unitID)
					end
					
					plateFrame.PlateConfig = DB_PLATE_CONFIG.player
					Plater.UpdatePlateFrame (plateFrame, ACTORTYPE_PLAYER, nil, true)
					Plater.OnUpdateHealth (healthBar)
					
				else
					--> regular nameplate
					
					plateFrame.PlayerCannotAttack = not UnitCanAttack ("player", unitID)
					unitFrame.PlayerCannotAttack = plateFrame.PlayerCannotAttack --expose to scripts
					
					if (isPlayer) then
						--unit is a player
						plateFrame.playerGuildName = GetGuildInfo (unitID)
						
						if (reaction >= Plater.UnitReaction.UNITREACTION_FRIENDLY) then
							plateFrame.NameAnchor = DB_NAME_PLAYERFRIENDLY_ANCHOR
							plateFrame.PlateConfig = DB_PLATE_CONFIG.friendlyplayer
							Plater.UpdatePlateFrame (plateFrame, ACTORTYPE_FRIENDLY_PLAYER, nil, true)
							unitFrame.Settings.ShowCastBar = not DB_CASTBAR_HIDE_FRIENDLY
							if (DB_CASTBAR_HIDE_FRIENDLY) then
								--CastingBarFrame_SetUnit (castBar, nil, nil, nil)
								unitFrame.castBar:SetUnit(nil, nil)
							elseif not castBarWasEnabled then
								unitFrame.castBar:SetUnit (unitID, unitID)
							end
						else
							plateFrame.NameAnchor = DB_NAME_PLAYERENEMY_ANCHOR
							plateFrame.PlateConfig = DB_PLATE_CONFIG.enemyplayer
							Plater.UpdatePlateFrame (plateFrame, ACTORTYPE_ENEMY_PLAYER, nil, true)
							unitFrame.Settings.ShowCastBar = not DB_CASTBAR_HIDE_ENEMIES
							if (DB_CASTBAR_HIDE_ENEMIES) then
								--CastingBarFrame_SetUnit (castBar, nil, nil, nil)
								unitFrame.castBar:SetUnit(nil, nil)
							elseif not castBarWasEnabled then
								unitFrame.castBar:SetUnit (unitID, unitID)
							end
						end
					else
						--the unit is a npc
						 
						if (reaction >= Plater.UnitReaction.UNITREACTION_FRIENDLY) then
							plateFrame.NameAnchor = DB_NAME_NPCFRIENDLY_ANCHOR
							plateFrame.PlateConfig = DB_PLATE_CONFIG.friendlynpc
							Plater.UpdatePlateFrame (plateFrame, ACTORTYPE_FRIENDLY_NPC, nil, true)
							unitFrame.Settings.ShowCastBar = not DB_CASTBAR_HIDE_FRIENDLY
							if (DB_CASTBAR_HIDE_FRIENDLY) then
								--CastingBarFrame_SetUnit (castBar, nil, nil, nil)
								unitFrame.castBar:SetUnit(nil, nil)
							elseif not castBarWasEnabled then
								unitFrame.castBar:SetUnit (unitID, unitID)
							end
						elseif isBattlePet then
							plateFrame.NameAnchor = DB_NAME_NPCFRIENDLY_ANCHOR
							plateFrame.PlateConfig = DB_PLATE_CONFIG.friendlynpc
							Plater.UpdatePlateFrame (plateFrame, ACTORTYPE_FRIENDLY_NPC, nil, true)
							unitFrame.Settings.ShowCastBar = not DB_CASTBAR_HIDE_FRIENDLY
							if (DB_CASTBAR_HIDE_FRIENDLY) then
								--CastingBarFrame_SetUnit (castBar, nil, nil, nil)
								unitFrame.castBar:SetUnit(nil, nil)
							elseif not castBarWasEnabled then
								unitFrame.castBar:SetUnit (unitID, unitID)
							end
							
						else
							--includes neutral npcs
							
							--add the npc in the npcid cache
							if (Plater.ZoneInstanceType == "raid" or Plater.ZoneInstanceType == "party" or Plater.ZoneInstanceType == "scenario") then
								if (plateFrame[MEMBER_NPCID] and plateFrame[MEMBER_NAME] ~= UNKNOWN) then --UNKNOWN is the global string from blizzard
									--npcCacheInfo: [1] npc name [2] zone name [3] language
									local npcCacheInfo = DB_NPCIDS_CACHE[plateFrame[MEMBER_NPCID]]
									if (not npcCacheInfo) then
										DB_NPCIDS_CACHE[plateFrame[MEMBER_NPCID]] = {plateFrame[MEMBER_NAME], Plater.ZoneName or "UNKNOWN", Plater.Locale or "enUS"}
									else
										--the npc is already cached, check if the language is different
										if (npcCacheInfo[3] ~= Plater.Locale) then
											--the npc is cached but the language is different, update the name
											npcCacheInfo[1] = plateFrame[MEMBER_NAME]
											npcCacheInfo[2] = Plater.ZoneName or "UNKNOWN"
											npcCacheInfo[3] = Plater.Locale
										end
									end
								end
							end
							
							plateFrame.NameAnchor = DB_NAME_NPCENEMY_ANCHOR
							plateFrame.PlateConfig = DB_PLATE_CONFIG.enemynpc
							Plater.UpdatePlateFrame (plateFrame, ACTORTYPE_ENEMY_NPC, nil, true)
							unitFrame.Settings.ShowCastBar = not DB_CASTBAR_HIDE_ENEMIES
							if (DB_CASTBAR_HIDE_ENEMIES) then
								--CastingBarFrame_SetUnit (castBar, nil, nil, nil)
								unitFrame.castBar:SetUnit(nil, nil)
							elseif not castBarWasEnabled then
								unitFrame.castBar:SetUnit (unitID, unitID)
							end
							
							--get threat situation to expose it to scripts already in the nameplate added hook
							local isTanking, threatStatus, threatpct, threatrawpct, threatValue = UnitDetailedThreatSituation ("player", unitID)
							unitFrame.namePlateThreatIsTanking = isTanking
							unitFrame.namePlateThreatStatus = threatStatus
							unitFrame.namePlateThreatPercent = threatpct or 0
							unitFrame.namePlateThreatRawPercent = threatrawpct or 0
							unitFrame.namePlateThreatValue = threatValue or 0

							Plater.UpdateNameOnRenamedUnit(plateFrame)
						end
					end
				end
			end
			
			plateFrame.actorType = actorType
			unitFrame.actorType = actorType
			unitFrame.ActorType = actorType --exposed to scripts
			
			--sending true to force the color update when the color overrider is enabled
			Plater.FindAndSetNameplateColor (unitFrame, true)
			
			--icone da cast bar
			Plater.UpdateCastbarIcon(castBar)
			
			--esconde os glow de aggro
			unitFrame.aggroGlowUpper:Hide()
			unitFrame.aggroGlowLower:Hide()
			
			--widget container update
			if IS_WOW_PROJECT_MAINLINE then
				plateFrame.unitFrame.WidgetContainer = plateFrame.UnitFrame.WidgetContainer
				if plateFrame.unitFrame.WidgetContainer then
					plateFrame.unitFrame.WidgetContainer:SetParent(plateFrame.unitFrame)
					plateFrame.unitFrame.WidgetContainer:ClearAllPoints()
					plateFrame.unitFrame.WidgetContainer:SetIgnoreParentScale(true)
					plateFrame.unitFrame.WidgetContainer:SetScale(Plater.db.profile.widget_bar_scale)
					Plater.SetAnchor (plateFrame.unitFrame.WidgetContainer, Plater.db.profile.widget_bar_anchor, plateFrame.unitFrame)
				end
			end
			
			--can check aggro
			unitFrame.CanCheckAggro = unitFrame.displayedUnit == unitID and actorType == ACTORTYPE_ENEMY_NPC and not unitFrame.isPerformanceUnit
			
			--tick-setup
			plateFrame.OnTickFrame.ThrottleUpdate = DB_TICK_THROTTLE
			plateFrame.OnTickFrame.actorType = actorType
			plateFrame.OnTickFrame.unit = unitID
			plateFrame.OnTickFrame:SetScript ("OnUpdate", Plater.NameplateTick)

			--highlight check
			if (DB_HOVER_HIGHLIGHT and (not plateFrame.PlayerCannotAttack or (plateFrame.PlayerCannotAttack and DB_SHOW_HEALTHBARS_FOR_NOT_ATTACKABLE)) and (actorType == ACTORTYPE_ENEMY_PLAYER or actorType == ACTORTYPE_ENEMY_NPC)) then
				Plater.EnableHighlight (unitFrame)
			else
				Plater.DisableHighlight (unitFrame)
			end
			
			--range
			--Plater.CheckRange (plateFrame, true)
			
			--resources - TODO:
			Plater.Resources.UpdateResourceFramePosition() --~resource

			--hooks
			if (HOOK_NAMEPLATE_ADDED.ScriptAmount > 0) then
				for i = 1, HOOK_NAMEPLATE_ADDED.ScriptAmount do
					local globalScriptObject = HOOK_NAMEPLATE_ADDED [i]
					local scriptContainer = unitFrame:ScriptGetContainer()
					local scriptInfo = unitFrame:HookGetInfo(globalScriptObject, scriptContainer, "Nameplate Added")
					--run
					unitFrame:ScriptRunHook (scriptInfo, "Nameplate Added")
				end
			end
			
			--tick
			Plater.NameplateTick (plateFrame.OnTickFrame, 999)
			
			unitFrame.PlaterOnScreen = true
			
			-- add private aura anchors
			Plater.HandlePrivateAuraAnchors(plateFrame.unitFrame) -- requires namePlateUnitToken, PlaterOnScreen and IsSelf to be set

			--check if the cast bar test is enabled
			if (Plater.IsShowingCastBarTest) then
				--start a castbar test for this unit
				platerInternal.CastBar.StartTestCastBarForNameplate(plateFrame)
			end
		end,

		-- ~removed
		---@param event string
		---@param unitBarId string
		NAME_PLATE_UNIT_REMOVED = function (event, unitBarId)
			--ViragDevTool_AddData({ctime = GetTime(), unit = unitBarId or "nil", stack = debugstack()}, "NAME_PLATE_UNIT_REMOVED - " .. (unitBarId or "nil"))
			---@type plateframe
			local plateFrame = C_NamePlate.GetNamePlateForUnit (unitBarId)
			
			Plater.RemoveFromAuraUpdate (unitBarId) -- ensure no updates
			
			ENABLED_BLIZZARD_PLATEFRAMES[plateFrame.unitFrame.blizzardPlateFrameID] = true -- OnRetailNamePlateShow is called first. ensure the plate might show!
			if not plateFrame.unitFrame.PlaterOnScreen then
				return
			end
			
			NAMEPLATES_ON_SCREEN_CACHE[unitBarId] = false
			NUM_NAMEPLATES_ON_SCREEN = NUM_NAMEPLATES_ON_SCREEN - 1
			
			--check if this nameplate has an update scheduled
			if (plateFrame.HasUpdateScheduled) then
				if (not plateFrame.HasUpdateScheduled._cancelled) then
					plateFrame.HasUpdateScheduled:Cancel()
				end
				plateFrame.HasUpdateScheduled = nil
			end
			
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
					local scriptInfo = unitFrame:HookGetInfo(globalScriptObject, scriptContainer, "Nameplate Removed")
					--run
					plateFrame.unitFrame:ScriptRunHook (scriptInfo, "Nameplate Removed")
				end
			end
			
			plateFrame.OnTickFrame:SetScript ("OnUpdate", nil)
			plateFrame.unitFrame.HighlightFrame:SetScript ("OnUpdate", nil)
			
			plateFrame [MEMBER_QUEST] = false
			plateFrame.unitFrame [MEMBER_QUEST] = false
			plateFrame.QuestInfo = {}
			plateFrame.unitFrame.QuestInfo = {}
			plateFrame [MEMBER_TARGET] = nil
			
			plateFrame.isObject = nil
			plateFrame.unitFrame.isObject = nil
			plateFrame.isSoftInteract = nil
			plateFrame.unitFrame.isSoftInteract = nil
			plateFrame.isSoftInteractObject = nil
			plateFrame.unitFrame.isSoftInteractObject = nil
			
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
			
			--hide target highlight
			plateFrame.TargetNeonUp:Hide()
			plateFrame.TargetNeonDown:Hide()
			
			--hide threat highlight
			plateFrame.unitFrame.aggroGlowUpper:Hide()
			plateFrame.unitFrame.aggroGlowLower:Hide()
			
			--> check if is running any script
			plateFrame.unitFrame:OnHideWidget()
			plateFrame.unitFrame.castBar:OnHideWidget()
			for _, auraIconFrame in ipairs (plateFrame.unitFrame.BuffFrame.PlaterBuffList) do
				auraIconFrame:OnHideWidget()
			end
			for _, auraIconFrame in ipairs (plateFrame.unitFrame.BuffFrame2.PlaterBuffList) do
				auraIconFrame:OnHideWidget()
			end
			
			--stop animations
			if plateFrame.unitFrame.BodyFlashFrame and plateFrame.unitFrame.BodyFlashFrame.animation then
				plateFrame.unitFrame.BodyFlashFrame.animation:Stop()
				plateFrame.unitFrame.BodyFlashFrame:Hide()
			end
			if plateFrame.unitFrame.healthBar.HealthFlashFrame and plateFrame.unitFrame.healthBar.HealthFlashFrame.animation then
				plateFrame.unitFrame.healthBar.HealthFlashFrame.animation:Stop()
				plateFrame.unitFrame.healthBar.HealthFlashFrame:Hide()
			end
			
			plateFrame.unitFrame.PlaterOnScreen = nil
			
			--reset auras
			Plater.ResetAuraContainer (plateFrame.unitFrame.BuffFrame, true, true)
			Plater.HideNonUsedAuraIcons (plateFrame.unitFrame.BuffFrame)
			
			--remove private aura anchors
			Plater.HandlePrivateAuraAnchors(plateFrame.unitFrame)
			
			--tell the framework to execute a cleanup on the unit frame, this is required since Plater set .ClearUnitOnHide to false
			plateFrame.unitFrame:SetUnit (nil)
			
			-- remove widgets
			if IS_WOW_PROJECT_MAINLINE and plateFrame.unitFrame.WidgetContainer then
				plateFrame.unitFrame.WidgetContainer:SetIgnoreParentScale(false)
				plateFrame.unitFrame.WidgetContainer:SetParent(plateFrame)
				plateFrame.unitFrame.WidgetContainer:ClearAllPoints()
				plateFrame.unitFrame.WidgetContainer:SetPoint('TOP', plateFrame.castBar, 'BOTTOM')
			end
			
			--if plateFrame.UnitFrame and plateFrame.UnitFrame.HealthBarsContainerOrigParent then
			--	DevTool:AddData("removing")
			--	plateFrame.UnitFrame.HealthBarsContainer:SetParent(plateFrame.UnitFrame.HealthBarsContainerOrigParent)
			--	plateFrame.UnitFrame.HealthBarsContainerOrigParent = nil
			--end
			
			--community patch by Ariani#0960 (discord)
			--make the unitFrame be parented to UIParent allowing frames to be moved between strata levels
			--March 3rd, 2019
			if (DB_USE_UIPARENT) then
				-- need to explicitly hide the frame now, as it is not tethered to the blizz nameplate
				plateFrame.unitFrame:Hide()
			end
			--end of patch
			
		end,
		
		UNIT_INVENTORY_CHANGED = function()
			UpdatePlayerTankState()
			--Plater.UpdateAllNameplateColors()
			--Plater.UpdateAllPlates()
		end,
		
		UPDATE_SHAPESHIFT_FORM = function()
			local curTime = GetTime()
			--this is to work around UPDATE_SHAPESHIFT_FORM firing for all units and not just the player... causing lag...
			if last_GetShapeshiftFormID == GetShapeshiftFormID() then
				return
			end
			last_GetShapeshiftFormID = GetShapeshiftFormID()
			
			UpdatePlayerTankState()
			Plater.UpdateAllNameplateColors()
			Plater.UpdateAllPlates()
			Plater.Resources.UpdateResourceFramePosition()
		end,
		
		TALENT_GROUP_ROLE_CHANGED = function()
			UpdatePlayerTankState()
			Plater.UpdateAllNameplateColors()
			Plater.UpdateAllPlates()
		end,
	}

	--allow other files of the addon to have access to event functions
	platerInternal.Events.GetEventFunction = function(event)
		return eventFunctions[event]
	end

	function Plater.EventHandler (_, event, ...) --private
		local func = eventFunctions [event]
		if (func) then
			Plater.StartLogPerformanceCore("Plater-Core", "Events", event)
			func (event, ...)
			Plater.EndLogPerformanceCore("Plater-Core", "Events", event)
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
		if ENABLED_BLIZZARD_PLATEFRAMES[tostring(self)] then
			-- do not hide
			return
		end
		
		--self:Hide()
		
		if self:IsProtected() then
			self:ClearAllPoints()
			self:SetParent(nil)
			
			if self.HealthBarsContainer then
				self.HealthBarsContainerOrigParent = self.HealthBarsContainer:GetParent() or self.HealthBarsContainerOrigParent
				self.HealthBarsContainer:ClearAllPoints()
				--self.HealthBarsContainer:SetParent(nil)
			end
			
			--for _, f in pairs(self:GetChildren() or {}) do
			--	--DevTool:AddData(f, "child")
			--	if type(f) == "table" and f.IsProtected then
			--		local p, ep = f:IsProtected()
			--		--DevTool:AddData({p, ep, f}, "protected?")
			--		if ep then
			--			--DevTool:AddData(f, "protected!")
			--			f:ClearAllPoints()
			--			f:SetParent(nil)
			--			f:Hide()
			--		end
			--	end
			--end
			if not self:IsProtected() then
				self:Hide()
			elseif DevTool then
				DevTool:AddData(self, "protected nameplate...")
			end
		else
			self:Hide()
		end
		
		
		if not SUPPORT_BLIZZARD_PLATEFRAMES then
			-- should be done if events are not needed
			-- CompactUnitFrame_UnregisterEvents only removes event hanlder functions
			self:UnregisterAllEvents()
		end
		
		if (CompactUnitFrame_UnregisterEvents) then
			CompactUnitFrame_UnregisterEvents (self)
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
	
	---import scripts from the library database, after that apply patches and recompile scripts
	function platerInternal.Scripts.UpdateFromLibrary()
		Plater.ImportScriptsFromLibrary()
		Plater.ApplyPatches()
		--and compile all scripts and hooks
		Plater.CompileAllScripts("script")
		Plater.CompileAllScripts("hook")
	end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> addon initialization

function Plater.InitializeSavedVariables()
	local PlaterDB = _G.PlaterDB

	--table to store casts with SPELL_CAST_START
	PlaterDB.captured_casts = PlaterDB.captured_casts or {}
	--table to store auras and any spell cast
	PlaterDB.captured_spells = PlaterDB.captured_spells or {}

	--table to store npcIds of performance units
	PlaterDB.performance_units = PlaterDB.performance_units or {}
end

function Plater.OnInit() --private --~oninit ~init
	LibStub ("AceDBOptions-3.0"):GetOptionsTable (Plater.db, true) -- register this now, to ensure no default "realm", "char - realm" profiles are shown in profiles management
	
	do
		local languageCurrentVersion = 1
		if (not PlaterLanguage) then
			PlaterLanguage = {
				language = GetLocale(), 
				version = languageCurrentVersion,
			}
		end

		if (PlaterLanguage.version < languageCurrentVersion) then
			--do stuff in the future
		end

		DF.Language.SetCurrentLanguage(addonId, PlaterLanguage.language)
	end

	--PlaterBackup is a table to store data that has been removed by the player might want to restore in another time
	PlaterBackup = PlaterBackup or {}

	Plater.InitializeSavedVariables()
	Plater.RefreshDBUpvalues()

	C_Timer.After(0, function()
		platerInternal.CreatePerformanceUnits(Plater)
	end)
	
	Plater.UpdateBlizzardNameplateFonts()
	
	-- do we need to support blizzard frames?
	SUPPORT_BLIZZARD_PLATEFRAMES = (not DB_PLATE_CONFIG [ACTORTYPE_PLAYER].module_enabled) or (not DB_PLATE_CONFIG [ACTORTYPE_FRIENDLY_PLAYER].module_enabled) or (not DB_PLATE_CONFIG [ACTORTYPE_ENEMY_PLAYER].module_enabled) or (not DB_PLATE_CONFIG [ACTORTYPE_FRIENDLY_NPC].module_enabled) or (not DB_PLATE_CONFIG [ACTORTYPE_ENEMY_NPC].module_enabled)
	
	Plater.CombatTime = GetTime()

	PLAYER_IN_COMBAT = false
	if (InCombatLockdown()) then
		PLAYER_IN_COMBAT = true
	end

	Plater.Locale =  GetLocale()

	do --log initialization version
		pcall(function()
			local GetAddOnMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
			local platerVersion = GetAddOnMetadata("Plater", "Version")
			local frameworkVersion = "Framework v" .. select(2,LibStub:GetLibrary("DetailsFramework-1.0"))
			local gameVersion = GetBuildInfo()
			local gameLocale = Plater.Locale
			local charName = UnitName("player")
			platerInternal.Logs.Log("INIT | " .. platerVersion .. " | " .. frameworkVersion .. " | " .. gameVersion .. " | " .. gameLocale .. " | " .. charName)
		end)
	end

	PlaterDB.InterruptableSpells = PlaterDB.InterruptableSpells or {}

	--check if details is loaded and if the version has support for mythic+ overall event
	if (Details and Details.RegistredEvents["COMBAT_MYTHICPLUS_OVERALL_READY"]) then
		platerInternal.DetailsEvents = Details:CreateEventListener()
		platerInternal.DetailsEvents:RegisterEvent("COMBAT_MYTHICPLUS_OVERALL_READY", function()
			local interruptableSpells = {}
			local combatObject = Details:GetCurrentCombat()
			if (combatObject:GetCombatType() == DETAILS_SEGMENTTYPE_MYTHICDUNGEON_OVERALL) then
				local utilityContainer = combatObject:GetContainer(DETAILS_ATTRIBUTE_MISC)
				for index, actorObject in utilityContainer:ListActors() do
					local interrupttedSpells = actorObject:GetSpellContainer("interruptwhat")
					if (interrupttedSpells) then
						for spellId in pairs(interrupttedSpells) do
							PlaterDB.InterruptableSpells[spellId] = true --~interrupt ~interruptable
						end
					end
				end
			end
		end)
	end

	--Plater:BossModsLink()
	
	--character settings
		PlaterDBChr = PlaterDBChr or {first_run3 = {}}
		PlaterDBChr.first_run3 = PlaterDBChr.first_run3 or {}
		PlaterDBChr.debuffsBanned = PlaterDBChr.debuffsBanned or {}
		PlaterDBChr.buffsBanned = PlaterDBChr.buffsBanned or {}
		PlaterDBChr.spellRangeCheckRangeEnemy = PlaterDBChr.spellRangeCheckRangeEnemy or {}
		PlaterDBChr.spellRangeCheckRangeFriendly = PlaterDBChr.spellRangeCheckRangeFriendly or {}

	--Register LDB
	Plater.InitLDB()

	--to fix: attempt to index field 'spellRangeCheck' (a string value)
		if (type (PlaterDBChr.spellRangeCheckRangeEnemy) ~= "table") then
			PlaterDBChr.spellRangeCheckRangeEnemy = {}
		end
		if (type (PlaterDBChr.spellRangeCheckRangeFriendly) ~= "table") then
			PlaterDBChr.spellRangeCheckRangeFriendly = {}
		end
	
	--run once per profile per expansion
	platerInternal.ScriptTriggers.WipeDeprecatedScriptTriggersFromProfile(Plater.db.profile)

	--ensure global nameplate width/height setting is initialized
		Plater.db.profile.plate_config.global_health_width = Plater.db.profile.plate_config.global_health_width or Plater.db.profile.plate_config.enemynpc.health[1]
		Plater.db.profile.plate_config.global_health_height = Plater.db.profile.plate_config.global_health_height or Plater.db.profile.plate_config.enemynpc.health[2]
	
	--range check spells
		if IS_WOW_PROJECT_MAINLINE then
			for specID, _ in pairs (Plater.SpecList [select (2, UnitClass ("player"))]) do
				--if (PlaterDBChr.spellRangeCheckRangeEnemy [specID] == nil or not LibRangeCheck:GetHarmMaxChecker (PlaterDBChr.spellRangeCheckRangeEnemy [specID])) then
				if (PlaterDBChr.spellRangeCheckRangeEnemy [specID] == nil) then
					PlaterDBChr.spellRangeCheckRangeEnemy [specID] = Plater.DefaultSpellRangeList [specID]
				end
				--if (PlaterDBChr.spellRangeCheckRangeFriendly [specID] == nil or not LibRangeCheck:GetFriendMaxChecker(PlaterDBChr.spellRangeCheckRangeFriendly [specID])) then
				if (PlaterDBChr.spellRangeCheckRangeFriendly [specID] == nil) then
					PlaterDBChr.spellRangeCheckRangeFriendly [specID] = Plater.DefaultSpellRangeListF [specID]
				end
			end
		else
			local playerClass = select (3, UnitClass ("player"))
			--if (PlaterDBChr.spellRangeCheckRangeEnemy [playerClass] == nil or not LibRangeCheck:GetHarmMaxChecker (PlaterDBChr.spellRangeCheckRangeEnemy [playerClass])) then
			if (PlaterDBChr.spellRangeCheckRangeEnemy [playerClass] == nil) then
				PlaterDBChr.spellRangeCheckRangeEnemy [playerClass] = Plater.DefaultSpellRangeList [playerClass]
			end
			--if (PlaterDBChr.spellRangeCheckRangeFriendly [playerClass] == nil or not LibRangeCheck:GetFriendMaxChecker(PlaterDBChr.spellRangeCheckRangeFriendly [playerClass])) then
			if (PlaterDBChr.spellRangeCheckRangeFriendly [playerClass] == nil) then
				PlaterDBChr.spellRangeCheckRangeFriendly [playerClass] = Plater.DefaultSpellRangeListF [playerClass]
			end
		end
		Plater.RangeCheckRangeEnemy = nil
		Plater.RangeCheckRangeFriendly = nil
		Plater.RangeCheckFunctionEnemy = nil
		Plater.RangeCheckFunctionFriendly = nil
		
		LibRangeCheck.RegisterCallback(Plater, LibRangeCheck.CHECKERS_CHANGED, function() Plater.GetSpellForRangeCheck() end)
	
	--who is the player
		Plater.PlayerGUID = UnitGUID ("player")
		Plater.PlayerClass = select (2, UnitClass ("player"))
	
	--track player auras
		Plater.AddToAuraUpdate("player")

	--load scripts from the script library
		platerInternal.Scripts.UpdateFromLibrary()
	
	--check if masque is installed and add support for masque addon
		local Masque = LibStub ("Masque", true)
		if (Masque and Plater.db.profile.enable_masque_support) then
			Plater.Masque = {}
			Plater.Masque.Callback = function(group, option, value)
				group:ReSkin(true)
			end
			Plater.Masque.AuraFrame1 = Masque:Group ("Plater Nameplates", "Aura Frame 1")
			Plater.Masque.AuraFrame1:RegisterCallback(Plater.Masque.Callback)
			Plater.Masque.AuraFrame2 = Masque:Group ("Plater Nameplates", "Aura Frame 2")
			Plater.Masque.AuraFrame2:RegisterCallback(Plater.Masque.Callback)
			Plater.Masque.BuffSpecial = Masque:Group ("Plater Nameplates", "Buff Special")
			Plater.Masque.BuffSpecial:RegisterCallback(Plater.Masque.Callback)
			Plater.Masque.BossModIconFrame = Masque:Group ("Plater Nameplates", "Boss Mod Icons")
			Plater.Masque.BossModIconFrame:RegisterCallback(Plater.Masque.Callback)
			Plater.Masque.CastIcon = Masque:Group ("Plater Nameplates", "Cast Bar Icons")
			Plater.Masque.CastIcon:RegisterCallback(Plater.Masque.Callback)
		end
	
	--set some cvars that we want to set
		function Plater.ForceCVars()
			if (InCombatLockdown()) then
				return C_Timer.After (1, function() Plater.ForceCVars() end)
			end
			SetCVar ("nameplateMinAlpha", 0.90135484)
			SetCVar ("nameplateMinAlphaDistance", -10^5.2)
			SetCVar ("nameplateSelectedAlpha", 1)
			SetCVar ("nameplateNotSelectedAlpha", 1)
			SetCVar ("nameplateRemovalAnimation", DB_USE_QUICK_HIDE and 0 or 1)
			SetCVar ("nameplateShowFriendlyBuffs", 0)
			SetCVar ("nameplateShowPersonalCooldowns", 0)
			if IS_WOW_PROJECT_MAINLINE and not GetCVar("nameplatePlayerMaxDistance") then -- this is 10.1 workaround.
				SetCVar ("nameplatePlayerMaxDistance", 60)
			end
		end
	
	--schedule data update
		--C_Timer.After (1, Plater.GetSpellForRangeCheck)
		C_Timer.After (4, Plater.GetHealthCutoffValue)
	
	--Mythic Dungeon Tools
		platerInternal.InstallMDTHooks()

	--hooking scripts has load conditions, here it creates a load filter for plater
	--so when a load condition is changed it reload hooks
		function Plater.HookLoadCallback (encounterID) --private
			Plater.StartLogPerformanceCore("Plater-Core", "Mod/Script", "HookLoadCallback")
			
			Plater.EncounterID = encounterID
			Plater.WipeAndRecompileAllScripts ("hook", true) --sending true to not dispatch a hotReload in the scripts
			
			Plater.EndLogPerformanceCore("Plater-Core", "Mod/Script", "HookLoadCallback")
		end
		DF:CreateLoadFilterParser (Plater.HookLoadCallback)
	
	--refresh the color overrider
		Plater.RefreshColorOverride()
	
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
		Plater.EventHandlerFrame:RegisterEvent ("FORBIDDEN_NAME_PLATE_UNIT_ADDED")
		Plater.EventHandlerFrame:RegisterEvent ("NAME_PLATE_UNIT_REMOVED")
		
		Plater.EventHandlerFrame:RegisterEvent ("PLAYER_TARGET_CHANGED")
		Plater.EventHandlerFrame:RegisterEvent ("PLAYER_FOCUS_CHANGED")
		if IS_WOW_PROJECT_MAINLINE then
			Plater.EventHandlerFrame:RegisterEvent ("PLAYER_SOFT_INTERACT_CHANGED")
			Plater.EventHandlerFrame:RegisterEvent ("PLAYER_SOFT_FRIEND_CHANGED")
			Plater.EventHandlerFrame:RegisterEvent ("PLAYER_SOFT_ENEMY_CHANGED")
		end
		
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
		if IS_WOW_PROJECT_MAINLINE then
			Plater.EventHandlerFrame:RegisterEvent ("QUEST_POI_UPDATE")
		end
		Plater.EventHandlerFrame:RegisterEvent ("QUEST_DETAIL")
		Plater.EventHandlerFrame:RegisterEvent ("QUEST_FINISHED")
		Plater.EventHandlerFrame:RegisterEvent ("QUEST_GREETING")
		Plater.EventHandlerFrame:RegisterEvent ("QUEST_LOG_UPDATE")
		Plater.EventHandlerFrame:RegisterEvent ("UNIT_QUEST_LOG_CHANGED")
		if IS_WOW_PROJECT_MAINLINE then
			Plater.EventHandlerFrame:RegisterEvent ("PLAYER_SPECIALIZATION_CHANGED")
			Plater.EventHandlerFrame:RegisterEvent (C_Traits and "TRAIT_CONFIG_UPDATED" or "PLAYER_TALENT_UPDATE")
		elseif IS_WOW_PROJECT_CLASSIC_WRATH then
			Plater.EventHandlerFrame:RegisterEvent ("ACTIVE_TALENT_GROUP_CHANGED")
			Plater.EventHandlerFrame:RegisterEvent ("PLAYER_TALENT_UPDATE")
		end
		
		Plater.EventHandlerFrame:RegisterEvent ("ENCOUNTER_START")
		Plater.EventHandlerFrame:RegisterEvent ("ENCOUNTER_END")
		if IS_WOW_PROJECT_MAINLINE then
			Plater.EventHandlerFrame:RegisterEvent ("CHALLENGE_MODE_START")
		end
		
		Plater.EventHandlerFrame:RegisterEvent ("UNIT_NAME_UPDATE")
		
		Plater.EventHandlerFrame:RegisterEvent ("UNIT_FLAGS")
		Plater.EventHandlerFrame:RegisterEvent ("UNIT_FACTION")
		
		Plater.EventHandlerFrame:RegisterEvent ("DISPLAY_SIZE_CHANGED")
		Plater.EventHandlerFrame:RegisterEvent ("UI_SCALE_CHANGED")
		
		Plater.EventHandlerFrame:RegisterEvent ("GROUP_ROSTER_UPDATE")
		
		Plater.EventHandlerFrame:RegisterEvent ("UNIT_PET")
		
		if IS_WOW_PROJECT_NOT_MAINLINE then -- tank spec detection
			Plater.EventHandlerFrame:RegisterEvent ("UNIT_INVENTORY_CHANGED")
			Plater.EventHandlerFrame:RegisterEvent ("UPDATE_SHAPESHIFT_FORM")
			if IS_WOW_PROJECT_CLASSIC_WRATH then
				Plater.EventHandlerFrame:RegisterEvent ("TALENT_GROUP_ROLE_CHANGED")
			end
		elseif Plater.PlayerClass == "DRUID" then
			Plater.EventHandlerFrame:RegisterEvent ("UPDATE_SHAPESHIFT_FORM")
		end
		
		Plater.EventHandlerFrame:RegisterEvent ("PLAYER_LOGIN")
		Plater.EventHandlerFrame:RegisterEvent ("VARIABLES_LOADED")

		--power update for hooking scripts
		local hookPowerEventFrame = CreateFrame ("frame")
		--hookPowerEventFrame:RegisterUnitEvent ("UNIT_POWER_UPDATE", "player")
		hookPowerEventFrame:RegisterUnitEvent ("UNIT_POWER_FREQUENT", "player")
		hookPowerEventFrame:RegisterUnitEvent ("UNIT_MAXPOWER", "player")
		--hookPowerEventFrame:RegisterUnitEvent ("UNIT_DISPLAYPOWER", "player")
		--hookPowerEventFrame:RegisterUnitEvent ("UNIT_POWER_BAR_HIDE", "player")

		hookPowerEventFrame:SetScript ("OnEvent", function(self, event, target, powerType)
			-- target is always 'player'
			if (HOOK_PLAYER_POWER_UPDATE.ScriptAmount > 0) then
				for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
					---@cast plateFrame plateframe
					if (plateFrame) then
						for i = 1, HOOK_PLAYER_POWER_UPDATE.ScriptAmount do
							local globalScriptObject = HOOK_PLAYER_POWER_UPDATE [i]
							local unitFrame = plateFrame.unitFrame
							local scriptContainer = unitFrame:ScriptGetContainer()
							local scriptInfo = unitFrame:HookGetInfo(globalScriptObject, scriptContainer, "Player Power Update")
							--run
							unitFrame:ScriptRunHook (scriptInfo, "Player Power Update", unitFrame, powerType)
						end
					end
				end
			end
		end)
	
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
	
		--this function is declared inside 'NamePlateDriverMixin' at Blizzard_NamePlates.lua
		--self if the nameplate driver frame: _G.NamePlateDriverFrame
		--at the moment self isn't being used ~personal
		function Plater.UpdatePersonalBar (self)
			local showSelf = GetCVarBool ("nameplateShowSelf") and Plater.db.profile.plate_config.player.module_enabled
			if (not showSelf) then
				if PlaterDBChr.resources_on_target then
					Plater.UpdateResourceFrame()
				end
				return
			end

			--show Plater power bar for the player personal nameplate
			---@type plateframe
			local plateFrame = C_NamePlate.GetNamePlateForUnit ("player")
			if (plateFrame) then
			
				if (not plateFrame.Plater) then
					return
				end
			
				if (NamePlateDriverFrame.classNamePlatePowerBar and NamePlateDriverFrame.classNamePlatePowerBar:IsShown()) then
					--hide the power bar from default ui
					NamePlateDriverFrame.classNamePlatePowerBar:Hide()
					NamePlateDriverFrame.classNamePlatePowerBar:UnregisterAllEvents()
				end
				
				local unitFrame = plateFrame.unitFrame
				
				--setup the power bar and cast bar from the details! framework unit frame
				local powerBar = unitFrame.powerBar
				local castBar = unitFrame.castBar
				local healthBar = unitFrame.healthBar
				
				if (not DB_PLATE_CONFIG.player.healthbar_enabled) then
					--the health bar is set when the nameplate is shown
					healthBar:SetUnit (nil)
					
					-- hide target glow
					plateFrame.TargetNeonUp:Hide()
					plateFrame.TargetNeonDown:Hide()
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
				
			end
			
			--update resource bar
			Plater.UpdateResourceFrame()
		end
		
		--can also hook 'ClassNameplateBar:ShowNameplateBar()' which will show and call NamePlateDriverFrame:SetClassNameplateBar(self); which will call SetupClassNameplateBars()
		if IS_WOW_PROJECT_MAINLINE then
			hooksecurefunc (NamePlateDriverFrame, "SetupClassNameplateBars", function (self)
				return Plater.UpdatePersonalBar (self)
			end)
			
			--[[ -- fuck things up a bit...
			hooksecurefunc (NamePlateBaseMixin, "OnAdded", function(self, namePlateUnitToken, driverFrame)
				local plateFrame = C_NamePlate.GetNamePlateForUnit (namePlateUnitToken)
				Plater.OnRetailNamePlateShow(plateFrame.UnitFrame)
			end)
			
			hooksecurefunc (NamePlateDriverFrame, "OnNamePlateAdded", function(self, namePlateUnitToken)
				if not ENABLED_BLIZZARD_PLATEFRAMES[tostring(frame)] then
					local plateFrame = C_NamePlate.GetNamePlateForUnit (namePlateUnitToken)
					DevTool:AddData(plateFrame, "OnNamePlateAdded")
					C_Timer.After(0, function() Plater.OnRetailNamePlateShow(plateFrame.UnitFrame) end)
				end
			end)
			hooksecurefunc ("DefaultCompactNamePlateFrameSetupInternal", function(frame)
				DevTool:AddData(frame, "DefaultCompactNamePlateFrameSetupInternal")
				if not ENABLED_BLIZZARD_PLATEFRAMES[tostring(frame)] then
					
					--Plater.OnRetailNamePlateShow (frame)
				end
			end)
			--]]
			
		end

		--update the resource location and anchor
		function Plater.UpdateResourceFrame()
			if IS_WOW_PROJECT_NOT_MAINLINE then return end
			--this holds a reference of the current resource frame anchored into the 'target' namepate
			--it is used when checking if the unit has auras to move the resources up to make room for the auras
			Plater.CurrentTargetResourceFrame = nil
		
			local showSelf = GetCVarBool ("nameplateShowSelf") and Plater.db.profile.plate_config.player.module_enabled
			local onCurrentTarget = PlaterDBChr.resources_on_target
			
			if (not showSelf) then
				if (not onCurrentTarget) then
					return
				end
			end
			
			local resourceFrame = NamePlateDriverFrame.classNamePlateMechanicFrame
			if (resourceFrame and not resourceFrame:IsForbidden()) then
				if Plater.db.profile.resources_settings.global_settings.show then
					resourceFrame:SetAlpha (0)
					resourceFrame:Hide()
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
			
			local alternatePowerFrame = NamePlateDriverFrame.classNamePlateAlternatePowerBar
			if (alternatePowerFrame and not alternatePowerFrame:IsForbidden()) then
				if Plater.db.profile.resources_settings.global_settings.show then
					alternatePowerFrame:SetAlpha (0)
					alternatePowerFrame:Hide()
					return
				end
				
				--> set scale based on Plater user settings
				alternatePowerFrame:SetScale (Plater.db.profile.resources.scale * (resourceFrame and 2 or 2)) --augvoker and stagger bars, separate handling. same size for now
				alternatePowerFrame:SetAlpha (Plater.db.profile.resources.alpha)
				
				--check if resources are placed on the current target
				if (onCurrentTarget) then
					--resource bar are placed on the current target nameplate
					local targetPlateFrame = C_NamePlate.GetNamePlateForUnit ("target", false) -- don't attach to secure frames to avoid tainting!
					if (targetPlateFrame) then
						alternatePowerFrame:Show()
						alternatePowerFrame:SetParent (targetPlateFrame.unitFrame)
						alternatePowerFrame:ClearAllPoints()
						if resourceFrame then
							alternatePowerFrame:SetPoint ("bottom", resourceFrame, "top", 0, 2)
						else
							alternatePowerFrame:SetPoint ("bottom", targetPlateFrame.unitFrame.healthBar, "top", 0, Plater.db.profile.resources.y_offset_target)
						end
						alternatePowerFrame:SetFrameStrata(targetPlateFrame.unitFrame.healthBar:GetFrameStrata())
						alternatePowerFrame:SetFrameLevel(targetPlateFrame.unitFrame.healthBar:GetFrameLevel() + 25)
						Plater.CurrentTargetResourceFrame = resourceFrame or alternatePowerFrame
						
						Plater.UpdateResourceFrameAnchor (targetPlateFrame.unitFrame.BuffFrame)
					else
						alternatePowerFrame:Hide()
					end
				else
					--resource bar are placed below the mana bar at the personal bar
					local personalPlateFrame = C_NamePlate.GetNamePlateForUnit ("player", issecure())
					if (personalPlateFrame) then
						alternatePowerFrame:Show()
						alternatePowerFrame:SetParent (personalPlateFrame.unitFrame)
						alternatePowerFrame:ClearAllPoints()
						
						--> attach to powerbar if shown
						if resourceFrame then
							alternatePowerFrame:SetPoint ("top", resourceFrame, "bottom", 0, -2)
						else
							if (personalPlateFrame.unitFrame.powerBar:IsShown()) then
								alternatePowerFrame:SetPoint ("top", personalPlateFrame.unitFrame.powerBar, "bottom", 0, -3 + Plater.db.profile.resources.y_offset)
							else
								alternatePowerFrame:SetPoint ("top", personalPlateFrame.unitFrame.healthBar, "bottom", 0, -3 + Plater.db.profile.resources.y_offset)
							end
						end
						
						alternatePowerFrame:SetFrameStrata(personalPlateFrame.unitFrame.healthBar:GetFrameStrata())
						alternatePowerFrame:SetFrameLevel(personalPlateFrame.unitFrame.healthBar:GetFrameLevel() + 25)
					else
						alternatePowerFrame:Hide()
					end
				end
			end
		end

		if IS_WOW_PROJECT_MAINLINE then
			--C_CVar.RegisterCVar("nameplateShowOnlyNames") -- ensure this is still available and usable for our purposes, as it was removed with 10.0.5, but re-added with amnesia shortly after. not needed now.
		end
		
		-- do this now
		Plater.UpdateBaseNameplateOptions()
		
		--this function is declared inside 'NamePlateDriverMixin' at Blizzard_NamePlates.lua
		hooksecurefunc (NamePlateDriverFrame, "UpdateNamePlateOptions", function()
			Plater.UpdateSelfPlate()
			Plater.UpdateBaseNameplateOptions()
			Plater.UpdatePlateClickSpace()
		end)
		
		--this might come in useful
		function Plater.SetNamePlatePreferredClickInsets(nameplateType, left, right, top, bottom)
			if not InCombatLockdown() then
				if nameplateType == "friendly" then
					C_NamePlate.SetNamePlateFriendlyPreferredClickInsets (left or 0, right or 0, top or 0, bottom or 0)
				elseif nameplateType == "enemy" then
					C_NamePlate.SetNamePlateEnemyPreferredClickInsets (left or 0, right or 0, top or 0, bottom or 0)
				elseif nameplateType == "player" then
					C_NamePlate.SetNamePlateSelfPreferredClickInsets (left or 0, right or 0, top or 0, bottom or 0)
				end
			else
				C_Timer.After(1, function() Plater.SetNamePlatePreferredClickInsets(nameplateType, left, right, top, bottom) end)
			end
		end
		hooksecurefunc(NamePlateDriverFrame.namePlateSetInsetFunctions, "friendly", function()
			--C_NamePlate.SetNamePlateFriendlyPreferredClickInsets (0, 0, 0, 0)
			Plater.SetNamePlatePreferredClickInsets("friendly", 0, 0, 0, 0)
		end)
		hooksecurefunc(NamePlateDriverFrame.namePlateSetInsetFunctions, "enemy", function()
			--C_NamePlate.SetNamePlateEnemyPreferredClickInsets (0, 0, 0, 0)
			Plater.SetNamePlatePreferredClickInsets("enemy", 0, 0, 0, 0)
		end)
		if IS_WOW_PROJECT_MAINLINE then
			hooksecurefunc(NamePlateDriverFrame.namePlateSetInsetFunctions, "player", function()
				--C_NamePlate.SetNamePlateSelfPreferredClickInsets (0, 0, 0, 0)
				Plater.SetNamePlatePreferredClickInsets("player", 0, 0, 0, 0)
			end)
		end
		

	--> cast frame ~castbar
	
		--test castbar ~test
		Plater.CastBarTestFrame = CreateFrame ("frame", nil, UIParent, BackdropTemplateMixin and "BackdropTemplate")
		
		function Plater.StartCastBarTest(castNoInterrupt, castTime, isLoop)
			castTime = castTime or 3

			if (isLoop) then
				Plater.CastBarTestFrame.castNoInterrupt = Plater.CastBarTestFrame.castNoInterrupt
				Plater.CastBarTestFrame.castTime = Plater.CastBarTestFrame.castTime
			else
				Plater.CastBarTestFrame.castNoInterrupt = castNoInterrupt
				Plater.CastBarTestFrame.castTime = castTime
			end

			Plater.IsShowingCastBarTest = true
			Plater.DoCastBarTest(castNoInterrupt, castTime)

			Plater.IsTestRunning = true
		end

		function platerInternal.CastBar.StartTestCastBarForNameplate(plateFrame)
			local castTime = Plater.CastBarTestFrame.castTime
			---@cast plateFrame plateframe
			if plateFrame.unitFrame.PlaterOnScreen then
				local castBar = plateFrame.unitFrame.castBar
				
				local spellName, _, spellIcon = GetSpellInfo(116)

				castBar.Text:SetText(spellName)
				castBar.Icon:SetTexture(spellIcon)
				castBar.Icon:SetAlpha(1)
				castBar.Icon:Show()
				castBar.percentText:Show()
				castBar:SetMinMaxValues(0, (castTime or 3))
				castBar:SetValue(0)
				castBar.Spark:Show()
				castBar.casting = true
				castBar.finished = false
				castBar.value = 0
				castBar.maxValue = (castTime or 3)
				castBar.canInterrupt = castNoInterrupt or math.random (1, 2) == 1
				--castBar.canInterrupt = true
				--castBar.channeling = true
				castBar:UpdateCastColor()

				castBar.spellName = 		spellName
				castBar.spellID = 			116
				castBar.spellTexture = 		spellIcon
				castBar.spellStartTime = 	GetTime()
				castBar.spellEndTime = 		GetTime() + (castTime or 3)
				
				castBar.SpellStartTime = 	GetTime()
				castBar.SpellEndTime = 		GetTime() + (castTime or 3)
				
				castBar.playedFinishedTest = nil
				
				castBar.flashTexture:Hide()
				castBar:Animation_StopAllAnimations()

				if (castBar.channeling) then
					Plater.CastBarOnEvent_Hook(castBar, "UNIT_SPELLCAST_CHANNEL_START", plateFrame.unitFrame.unit, plateFrame.unitFrame.unit)
				else
					Plater.CastBarOnEvent_Hook(castBar, "UNIT_SPELLCAST_START", plateFrame.unitFrame.unit, plateFrame.unitFrame.unit)
				end

				platerInternal.Audio.PlaySoundForCastStart(castBar.spellID)
				
				if (not castBar:IsShown()) then
					castBar:Animation_FadeIn()
					castBar:Show()
				end

				Plater.UpdateCastbarTargetText(castBar)
				local textString = castBar.FrameOverlay.TargetName
				textString:Show()
				textString:SetText("Target Name")
			end
		end
		
		function Plater.DoCastBarTest (castNoInterrupt, castTime)
			Plater.CastBarTestFrame.castTime = castTime or 3
			
			for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
				platerInternal.CastBar.StartTestCastBarForNameplate(plateFrame)
			end
			
			local totalTime = 0
			local checkEachSeconds = 0.4 --0.4 default
			local forward = true

			Plater.CastBarTestFrame:SetScript ("OnUpdate", function (self, deltaTime)
				if (totalTime >= checkEachSeconds) then --(Plater.CastBarTestFrame.castTime + 0.1)
					totalTime = 0

					for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
						---@cast plateFrame plateframe
						if plateFrame.unitFrame.PlaterOnScreen then
							local castBar = plateFrame.unitFrame.castBar
							--local textString = castBar.FrameOverlay.TargetName
							--textString:Show()
							--textString:SetText("Target Name")

							if (castBar.finished and not castBar.playedFinishedTest) then
								Plater.CastBarOnEvent_Hook (castBar, "UNIT_SPELLCAST_STOP", plateFrame.unitFrame.unit, plateFrame.unitFrame.unit)
								castBar.playedFinishedTest = true
							end
						end
					end
					
					if (Plater.IsShowingCastBarTest) then
						--run another cycle
						if (not Plater.CastBarTestFrame.ScheduleNewCycle) then
							Plater.CastBarTestFrame.ScheduleNewCycle = C_Timer.NewTimer(0.5, function()
								if (Plater.IsShowingCastBarTest) then
									for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
										if (not plateFrame.unitFrame.castBar:IsShown()) then
											platerInternal.CastBar.StartTestCastBarForNameplate(plateFrame)
										end
									end
								end
								Plater.CastBarTestFrame.ScheduleNewCycle = nil
							end)
						end
					else
						--don't run another cycle
						Plater.CastBarTestFrame:SetScript("OnUpdate", nil)
						Plater.IsTestRunning = nil
					end
				else
					totalTime = totalTime + deltaTime
				end
			end)
		end
		
		function Plater.StopCastBarTest()
			for _, plateFrame in ipairs(Plater.GetAllShownPlates()) do
				local castBar = plateFrame.unitFrame.castBar
				if (castBar:IsShown()) then
					Plater.CastBarOnEvent_Hook(castBar, "UNIT_SPELLCAST_STOP", plateFrame.unitFrame.unit, plateFrame.unitFrame.unit)
					castBar.playedFinishedTest = true
					castBar:Hide()
				end
			end

			if (Plater.CastBarTestFrame.ScheduleNewCycle and not Plater.CastBarTestFrame.ScheduleNewCycle:IsCancelled()) then
				Plater.CastBarTestFrame.ScheduleNewCycle:Cancel()
				Plater.CastBarTestFrame.ScheduleNewCycle = nil
			end

			Plater.IsTestRunning = nil
			Plater.IsShowingCastBarTest = false
			Plater.CastBarTestFrame:SetScript("OnUpdate", nil)
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
		
		function Plater.UpdateCastbarIcon(castBar)
			local profile = Plater.db.profile
			local icon = castBar.Icon
			local unitFrame = castBar.unitFrame
			local borderShield = castBar.BorderShield
			
			--icon:SetDrawLayer ("OVERLAY", 5)
			--borderShield:SetDrawLayer ("OVERLAY", 6)
			local castBarHeight = castBar:GetHeight()
			
			if (profile.castbar_icon_customization_enabled) then

				if (profile.castbar_icon_show) then
					icon:ClearAllPoints()
					borderShield:ClearAllPoints()
					borderShield:SetTexture ([[Interface\GROUPFRAME\UI-GROUP-MAINTANKICON]])
					borderShield:SetTexCoord (0, 1, 0, 1)
					borderShield:SetDesaturated (true)
					PixelUtil.SetSize (borderShield, castBarHeight * 0.8, castBarHeight)

					if (profile.castbar_icon_attach_to_side == "left") then
						if (profile.castbar_icon_size == "same as castbar") then
							icon:SetPoint("topright", castBar, "topleft", profile.castbar_icon_x_offset, 0)
							icon:SetPoint("bottomright", castBar, "bottomleft", profile.castbar_icon_x_offset, 0)
							
							PixelUtil.SetPoint (borderShield, "center", castBar, "left", 0, 0)

						elseif (profile.castbar_icon_size == "same as castbar plus healthbar") then
							local actorType = unitFrame.actorType
							local plateConfigs = DB_PLATE_CONFIG [actorType]
							local castBarConfigKey, healthBarConfigKey, manaConfigKey = Plater.GetHashKey (isInCombat)

							local healthBarHeight = unitFrame.customHealthBarHeight or (plateConfigs and plateConfigs [healthBarConfigKey][2]) or 0
							local castBarOffSetY = plateConfigs and plateConfigs.castbar_offset or 0
							
							if castBarOffSetY > healthBarHeight then
								icon:SetPoint("topright", castBar, "topleft", profile.castbar_icon_x_offset, 0)
								icon:SetPoint("bottomright", unitFrame.healthBar, "bottomleft", profile.castbar_icon_x_offset, 0)
							else
								icon:SetPoint("topright", unitFrame.healthBar, "topleft", profile.castbar_icon_x_offset, 0)
								icon:SetPoint("bottomright", castBar, "bottomleft", profile.castbar_icon_x_offset, 0)
							end
							
							PixelUtil.SetPoint (borderShield, "center", castBar, "left", 0, 0)
						end

					elseif (profile.castbar_icon_attach_to_side == "right") then
						if (profile.castbar_icon_size == "same as castbar") then
							icon:SetPoint("topleft", castBar, "topright", profile.castbar_icon_x_offset, 0)
							icon:SetPoint("bottomleft", castBar, "bottomright", profile.castbar_icon_x_offset, 0)
							
							PixelUtil.SetPoint (borderShield, "center", castBar, "right", 0, 0)

						elseif (profile.castbar_icon_size == "same as castbar plus healthbar") then
							local actorType = unitFrame.actorType
							local plateConfigs = DB_PLATE_CONFIG [actorType]
							local castBarConfigKey, healthBarConfigKey, manaConfigKey = Plater.GetHashKey (isInCombat)

							local healthBarHeight = unitFrame.customHealthBarHeight or (plateConfigs and plateConfigs [healthBarConfigKey][2]) or 0
							local castBarOffSetY = plateConfigs and plateConfigs.castbar_offset or 0
							
							if castBarOffSetY > healthBarHeight then
								icon:SetPoint("topleft", castBar, "topright", profile.castbar_icon_x_offset, 0)
								icon:SetPoint("bottomleft", unitFrame.healthBar, "bottomright", profile.castbar_icon_x_offset, 0)
							else
								icon:SetPoint("topleft", unitFrame.healthBar, "topright", profile.castbar_icon_x_offset, 0)
								icon:SetPoint("bottomleft", castBar, "bottomright", profile.castbar_icon_x_offset, 0)
							end
							
							PixelUtil.SetPoint (borderShield, "center", castBar, "right", 0, 0)
						end
					end

					icon:SetWidth(icon:GetHeight())
				else
					icon:Hide()
					borderShield:Hide()
				end
			else
				icon:ClearAllPoints()
				PixelUtil.SetPoint (icon, "left", castBar, "left", 0, 0)
				PixelUtil.SetSize (icon, castBarHeight, castBarHeight)
				
				--setup non interruptible cast shield
				borderShield:SetTexture ([[Interface\ACHIEVEMENTFRAME\UI-Achievement-Progressive-IconBorder]])
				borderShield:SetTexCoord (5/64, 37/64, 1/64, 36/64)
				borderShield:ClearAllPoints()
				borderShield:SetPoint ("center", castBar.Icon, "center")
				PixelUtil.SetSize (borderShield, castBarHeight * 1.4, castBarHeight * 1.4)
				borderShield:SetDesaturated (false)
			end
			if castBar.Icon.Masqued then
				Plater.Masque.CastIcon:ReSkin(castBar.Icon)
			end
		end
		
		
		---return if the unit is casting a spell, if the spellId is passed, will return if the unit is casting the spellId, otherwise will return the spellId of the spell being casted
		---@param unitId string
		---@param spellId number|string|nil
		---@return boolean|number
		function Plater.UnitIsCasting(unitId, spellId)
			if (UnitExists(unitId)) then
				---@type plateframe
				local plateFrame = C_NamePlate.GetNamePlateForUnit(unitId)
				if (plateFrame) then
					local castBar = plateFrame.unitFrame.castBar
					if (castBar:IsShown()) then
						if (spellId) then
							return castBar.SpellID == spellId or castBar.SpellName == spellId
						else
							return castBar.SpellID
						end
					end
				else
					return false
				end
			end
			return false
		end

		---return true if the spell can be interrupted
		---the function can only return results for spells that the addon observed being interrupted.
		---@param spellId number
		---@return boolean|nil
		function Plater.IsSpellInterruptable(spellId)
			return PlaterDB.InterruptableSpells[spellId]
		end

		--hook for all castbar events --~cast
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
				local unitFrame = self.unitFrame
				local shouldRunCastStartHook = false
				
				if (event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_CHANNEL_START") then
					local unitCast = unit
					if (unitCast ~= self.unit) then
						return
					end

					-- if we are starting a cast but it is an immediate chained cast, then needs to trigger OnHide and OnShow again afterwards
					local globalScriptObject = SCRIPT_CASTBAR_TRIGGER_CACHE[self.SpellName]
					if (globalScriptObject and (self.casting or self.channeling) and not self.IsInterrupted) then
						self:OnHideWidget()
					end

					--reset the visibility of the spell name text
					self.Text:Show()
					
					local curTime = GetTime()
					--local name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible, spellId = UnitCastingInfo (unitCast)
					self.SpellName = 		self.spellName
					self.SpellID = 		self.spellID
					self.SpellTexture = 	self.spellTexture
					self.SpellStartTime = 	self.spellStartTime or curTime
					self.SpellEndTime = 	self.spellEndTime or curTime
					
					local notInterruptible = not self.canInterrupt
					
					self.IsInterrupted = false
					self.InterruptSourceName = nil
					self.InterruptSourceGUID = nil
					self.ReUpdateNextTick = true
					self.ThrottleUpdate = -1
					
					if (notInterruptible) then
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
					
					local profile = Plater.db.profile
					local isInCombat = profile.use_player_combat_state and PLAYER_IN_COMBAT or unitFrame.InCombat
					
					--reset spark color and size
					self.Spark:SetVertexColor(unpack(profile.cast_statusbar_spark_color))
					self.Spark:SetAlpha (profile.cast_statusbar_spark_alpha)
					PixelUtil.SetSize(self.Spark, profile.cast_statusbar_spark_width, self:GetHeight())

					--cut the spell name text to fit within the castbar
					Plater.UpdateSpellNameSize (self.Text, unitFrame.ActorType, nil, isInCombat)

					Plater.UpdateCastbarTargetText (self)

					--castbar icon
					Plater.UpdateCastbarIcon(self)

					shouldRunCastStartHook = true

					--spell color
					self.castColorTexture:Hide()

					--cast color (from options tab Cast Colors)
					local castColors = profile.cast_colors
					local customColor = castColors[self.spellID]
					if (customColor) then
						local isEnabled, color, customSpellName = customColor[1], customColor[2], customColor[3]
						if (color and isEnabled) then
							local originalCastColor = profile.cast_color_settings.enabled

							--set the new cast color
							if (color == "white") then
								--the color white is used as a default disabled color
								originalCastColor = false
							else
								self:SetColor(color)
							end

							if (customSpellName and customSpellName ~= "") then
								self.Text:SetText(customSpellName)
							end

							--check if the original cast color is enabled
							if (originalCastColor) then
								--get the original cast color
								local castColor = self:GetCastColor()
								self.castColorTexture:Show()
								local r, g, b = Plater:ParseColors(castColor)
								self.castColorTexture:SetColorTexture(r, g, b)
								self.castColorTexture:SetHeight(self:GetHeight() + profile.cast_color_settings.height_offset)
							end
						end
					end
					
					if (self.channeling and (self.SpellStartTime + 0.25 > curTime)) then
						platerInternal.Audio.PlaySoundForCastStart(self.spellID) --fallback for edge cases. should not double play
					end
					
					-- in some occasions channeled casts don't have a CLEU entry... check this here
					if (unitFrame.ActorType == "enemynpc" and event == "UNIT_SPELLCAST_CHANNEL_START" and (not DB_CAPTURED_SPELLS[self.spellID] or DB_CAPTURED_SPELLS[self.spellID].isChanneled == nil)) then
						parserFunctions.SPELL_CAST_SUCCESS (nil, "SPELL_CAST_SUCCESS", nil, unitFrame[MEMBER_GUID], unitFrame.unitNameInternal, 0x00000000, nil, nil, nil, nil, nil, self.spellID, nil, nil, nil, nil, nil, nil, nil, nil, nil)
					end

				elseif (event == "UNIT_SPELLCAST_INTERRUPTED") then
					local unitCast = unit
					if (unitCast ~= self.unit) then
						return
					end

					--self:Hide()
					
					-- this is called in SPELL_INTERRUPT event
					--self:OnHideWidget()
					--self.IsInterrupted = true

				elseif (event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_CHANNEL_STOP") then
					local unitCast = unit
					if (unitCast ~= self.unit) then
						return
					end

					self:OnHideWidget()

					if (Plater.db.profile.cast_statusbar_quickhide) then
						self:Hide()
					end
				end
				
				--hooks
				if (shouldRunCastStartHook) then
					if (HOOK_CAST_START.ScriptAmount > 0) then
						for i = 1, HOOK_CAST_START.ScriptAmount do
							local globalScriptObject = HOOK_CAST_START [i]
							local scriptContainer = unitFrame:ScriptGetContainer()
							local scriptInfo = unitFrame:HookGetInfo(globalScriptObject, scriptContainer, "Cast Start")
							
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
							scriptEnv._CastBarHeight = unitFrame.castBar:GetHeight()
							
							--run
							unitFrame:ScriptRunHook (scriptInfo, "Cast Start", self)
						end
					end
				end
			end
		end
		
		Plater.CastBarOnTick_Hook = function (self, deltaTime) --private
			if (self.percentText) then --check if is a plater cast bar
			
				Plater.StartLogPerformanceCore("Plater-Core", "Update", "CastBarOnTick")
				
				self.ThrottleUpdate = self.ThrottleUpdate - deltaTime
				
				if (self.ThrottleUpdate < 0) then
				
					Plater.StartLogPerformanceCore("Plater-Core", "Update", "CastBarOnTick-Full")

					self.SpellStartTime = self.spellStartTime or GetTime()
					self.SpellEndTime = self.spellEndTime or GetTime()
				
					if (self.ReUpdateNextTick) then
						self.ReUpdateNextTick = nil
					end
					
					if (self.unit and Plater.db.profile.castbar_target_show and not UnitIsUnit (self.unit, "player")) then
						local targetName = UnitName (self.unit .. "target")
						if (targetName) then

							local canShowTargetName = true
							local notInTank = Plater.db.profile.castbar_target_notank
							if (notInTank) then
								if (Plater.PlayerIsTank and targetName == UnitName("player")) then
									canShowTargetName = false
								end
							end

							if (canShowTargetName) then
								if DB_USE_NAME_TRANSLIT then
									targetName = LibTranslit:Transliterate(targetName, TRANSLIT_MARK)
								end
								
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
					else
						self.FrameOverlay.TargetName:SetText ("")
					end
					
					self.ThrottleUpdate = self.unitFrame.PlateFrame.OnTickFrame.ThrottleUpdate + DB_TICK_THROTTLE

					--get the script object of the aura which will be showing in this icon frame
					local globalScriptObject = SCRIPT_CASTBAR_TRIGGER_CACHE[self.SpellName]

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
							local scriptInfo = unitFrame:HookGetInfo(globalScriptObject, scriptContainer, "Cast Update")
							
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
					
					Plater.EndLogPerformanceCore("Plater-Core", "Update", "CastBarOnTick-Full")
					
				end
				
				Plater.EndLogPerformanceCore("Plater-Core", "Update", "CastBarOnTick")
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
		unitFrame.healthBar.currentHealth = unitHealth
		unitFrame.healthBar.currentHealthMax = unitHealthMax
	end
	
	local run_on_health_change_hook = function (unitFrame)
		if unitFrame.isPerformanceUnit then return end -- don't run health update hooks on performance units
		for i = 1, HOOK_HEALTH_UPDATE.ScriptAmount do
			local globalScriptObject = HOOK_HEALTH_UPDATE [i]
			local scriptContainer = unitFrame:ScriptGetContainer()
			local scriptInfo = unitFrame:HookGetInfo(globalScriptObject, scriptContainer, "Health Update")
			--run
			unitFrame:ScriptRunHook (scriptInfo, "Health Update")
		end
	end
	
	function Plater.OnUpdateHealth (self) --self is unitFrame.healthBar
		if (not self.isNamePlate) then
			--this is not a nameplate, perhaps another frame from the framework
			return
		end
		
		Plater.StartLogPerformanceCore("Plater-Core", "Health", "OnUpdateHealth")

		-- update - for whatever weird reason max health event does not give proper values sometimes...
		if self.displayedUnit then --failsafe?!
			local maxHealth = UnitHealthMax (self.displayedUnit)
			self:SetMinMaxValues (0, maxHealth)
			self.currentHealthMax = maxHealth
		end

		---@type plateframe
		local plateFrame = self.PlateFrame
		local currentHealth = self.currentHealth
		local currentHealthMax = self.currentHealthMax
		local unitFrame = self.unitFrame
		local oldHealth = self.CurrentHealth
		
		--> exposed values to scripts
		self.CurrentHealth = currentHealth
		self.CurrentHealthMax = currentHealthMax
	
		if (plateFrame.IsSelf) then
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
				Plater.ChangeHealthBarColor_Internal (self, r, g, b, (originalColor[4] or 1), true)
			--else
				--Plater.ChangeHealthBarColor_Internal (self, unpack (plateFrame.PlateConfig.healthbar_color))
			end
			
			Plater.CheckLifePercentText (unitFrame)
			
		else

			--quick hide the nameplate if the unit doesn't exists or if the unit died
			if (DB_USE_QUICK_HIDE and (IS_WOW_PROJECT_MAINLINE)) then
				if (not UnitExists (unitFrame.unit) or self.CurrentHealth < 1) then
					--the unit died!
					unitFrame:Hide()
					Plater.EndLogPerformanceCore("Plater-Core", "Health", "OnUpdateHealth")
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
				local isWithoutHealthbar = plateFrame.IsFriendlyPlayerWithoutHealthBar
				plateFrame.IsNpcWithoutHealthBar = false --ensure this.
				Plater.ParseHealthSettingForPlayer (plateFrame)
				self.ScheduleNameUpdate = plateFrame.IsFriendlyPlayerWithoutHealthBar ~= isWithoutHealthbar
				--Plater.UpdatePlateText (plateFrame, DB_PLATE_CONFIG [ACTORTYPE_FRIENDLY_PLAYER], false)
			end
			
			Plater.CheckLifePercentText (unitFrame)
		end
		
		Plater.EndLogPerformanceCore("Plater-Core", "Health", "OnUpdateHealth")
	end

	--self is the healthBar (it's parent is the unitFrame)
	function Plater.OnUpdateHealthMax (self)
		Plater.StartLogPerformanceCore("Plater-Core", "Health", "OnUpdateHealthMax")
		
		-- ensure updated values...
		Plater.QuickHealthUpdate (self.unitFrame)
		
		Plater.CheckLifePercentText (self.unitFrame)
		
		Plater.EndLogPerformanceCore("Plater-Core", "Health", "OnUpdateHealthMax")
	end

	function Plater.OnHealthChange (self, unitId) --~health
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
		--Plater.db.RegisterCallback (Plater, "OnDatabaseShutdown", "SaveConsoleVariables")
		
		function Plater.OnProfileCreated()
			C_Timer.After (.5, function()
				Plater:Msg ("new profile created, applying patches and adding default scripts.")
				platerInternal.Scripts.UpdateFromLibrary()
				
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
		
		--update quest log after the addon initialization
		C_Timer.After (4.1, Plater.QuestLogUpdated)

		--update all nameplate after the addon initialized
		C_Timer.After (5.1, function() 
			Plater.IncreaseRefreshID()
			Plater.FullRefreshAllPlates()
		end)
	
		for i = 1, 3 do
			C_Timer.After (i, Plater.RefreshDBUpvalues)
		end
		
	if CastingBarFrame then
		CastingBarFrame:HookScript ("OnShow", function (self)
			if (Plater.db.profile.hide_blizzard_castbar) then
				self:Hide()
			end
		end)
	elseif PlayerCastingBarFrame then
		PlayerCastingBarFrame:HookScript ("OnShow", function (self)
			if (Plater.db.profile.hide_blizzard_castbar) then
				self:Hide()
			end
		end)		
	end
	
	-- fill class-info cache data
	if IS_WOW_PROJECT_MAINLINE then
		for classID = 1, MAX_CLASSES do
			local _, classFile = GetClassInfo(classID)
			CLASS_INFO_CACHE[classFile] = {}
			for i = 1, GetNumSpecializationsForClassID(classID) do
				local specID, maleName, _, iconID, role = GetSpecializationInfoForClassID(classID, i, 2) -- male
				local _, femaleName, _, iconID, role = GetSpecializationInfoForClassID(classID, i, 3) -- female
				CLASS_INFO_CACHE[classFile][maleName] = {role = role, specID = specID, iconID = iconID}
				CLASS_INFO_CACHE[classFile][femaleName] = CLASS_INFO_CACHE[classFile][maleName]
			end
		end
	end
	
	-- hook to the InterfaceOptionsFrame and VideoOptionsFrame to update the nameplate sizes, as blizzard somehow messes things up there on hide...
	if InterfaceOptionsFrame then
		InterfaceOptionsFrame:HookScript('OnHide',Plater.UpdatePlateClickSpace)
		VideoOptionsFrame:HookScript('OnHide',Plater.UpdatePlateClickSpace)
	elseif SettingsPanel then
		SettingsPanel:HookScript('OnHide',Plater.UpdatePlateClickSpace)
	end
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

function Plater.FormatTimeDecimal (time)
	if time < 10 then
		return ("%.1f"):format(time)
	elseif time < 60 then
		return ("%d"):format(time)
	elseif time < 3600 then
		return ("%d:%02d"):format(time/60%60, time%60)
	elseif time < 86400 then
		return ("%dh %02dm"):format(time/(3600), time/60%60)
	else
		return ("%dd %02dh"):format(time/86400, (time/3600) - (floor(time/86400) * 24))
	end
end


--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> color stuff ~color

	function Plater.SetQuestColorByReaction (unitFrame)
		--unit is a quest mob, reset the color to quest color
		if (unitFrame.ActorType and DB_PLATE_CONFIG [unitFrame.ActorType].quest_color_enabled) then
			if (unitFrame [MEMBER_REACTION] == Plater.UnitReaction.UNITREACTION_NEUTRAL) then
				Plater.ChangeHealthBarColor_Internal (unitFrame.healthBar, unpack (DB_PLATE_CONFIG [unitFrame.ActorType].quest_color_neutral))
				
			elseif (unitFrame [MEMBER_REACTION] < Plater.UnitReaction.UNITREACTION_NEUTRAL) then
				Plater.ChangeHealthBarColor_Internal (unitFrame.healthBar, unpack (DB_PLATE_CONFIG [unitFrame.ActorType].quest_color_enemy))
				
			else
				--there's a bug here where quest_color is nil for a friendly npc
				--this is happening when an enemy quest npc turns friendly and (probably) the actorType doesn't change
				--so in the enemy npc settings table does not have 'quest_color' input
				Plater.ChangeHealthBarColor_Internal (unitFrame.healthBar, unpack (DB_PLATE_CONFIG [unitFrame.ActorType].quest_color or {.5, 1, 0, 1}))
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
			if (not unitFrame [MEMBER_QUEST] or not DB_PLATE_CONFIG [unitFrame.ActorType].quest_color_enabled) then
				local reaction = unitFrame [MEMBER_REACTION]
				--has a valid reaction
				if (reaction) then
					local r, g, b, a = unpack (Plater.db.profile.color_override_colors [reaction])
					Plater.ChangeHealthBarColor_Internal (unitFrame.healthBar, r, g, b, a, true)
				end
			else
				--unit is a quest mob, reset the color to quest color
				Plater.SetQuestColorByReaction (unitFrame)
			end
		end
	end

	function Plater.DenyColorChange(unitFrame, state)
		unitFrame.DenyColorChange = state
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
	function Plater.ChangeHealthBarColor_Internal (healthBar, r, g, b, a, forceNoLerp) --private
		a = a or 1
		if (r ~= healthBar.R or g ~= healthBar.G or b ~= healthBar.B or a ~= healthBar.A) then
			healthBar.R, healthBar.G, healthBar.B, healthBar.A = r, g, b, a
			if (not DB_LERP_COLOR or forceNoLerp) then -- ~lerpcolor
				healthBar.barTexture:SetVertexColor (r, g, b, a)
			end
		end
	end

	--do several checkes to determine which are the color of this nameplate
	--if force refresh is true, it'll ignore aggro and incombat checks in the ColorOverrider function
	function Plater.FindAndSetNameplateColor (unitFrame, forceRefresh)
		local r, g, b, a = 1, 1, 1, 1
		local unitID = unitFrame [MEMBER_UNITID]
		if (unitFrame.IsSelf or not unitFrame.PlaterOnScreen) then
			return
			
		else
			--check if is a player
			if UnitIsPlayer (unitID) then
				if (unitFrame.ActorType == ACTORTYPE_FRIENDLY_PLAYER) then
					if (Plater.db.profile.use_playerclass_color) then
						local _, class = UnitClass (unitID)
						local classColor = DB_CLASS_COLORS [class]
						if (classColor) then -- and unitFrame.optionTable.useClassColors
							r, g, b, a = classColor.r, classColor.g, classColor.b, classColor.a
						end
					else
						r, g, b, a = unpack(Plater.db.profile.plate_config.friendlyplayer.fixed_class_color)
					end
				elseif (unitFrame.ActorType == ACTORTYPE_ENEMY_PLAYER) then
					if (Plater.db.profile.plate_config.enemyplayer.use_playerclass_color) then
						local _, class = UnitClass (unitID)
						local classColor = DB_CLASS_COLORS [class]
						if (classColor) then -- and unitFrame.optionTable.useClassColors
							r, g, b, a = classColor.r, classColor.g, classColor.b, classColor.a
						end
					else
						r, g, b, a = unpack(Plater.db.profile.plate_config.enemyplayer.fixed_class_color)
					end
				end
				
			--check if is tapped
			elseif (Plater.IsUnitTapDenied (unitID)) then
				r, g, b, a = unpack (Plater.db.profile.tap_denied_color)

			else
				if (Plater.CanOverrideColor) then
					Plater.ColorOverrider (unitFrame, forceRefresh)
					return
				end

				--check if the mob is a quest mob
				if (unitFrame [MEMBER_QUEST] and DB_PLATE_CONFIG [unitFrame.ActorType].quest_color_enabled) then
					Plater.SetQuestColorByReaction (unitFrame)
					return
				end
				
				--get the color from the client
				r, g, b, a = UnitSelectionColor (unitID)
			end
		end
		
		Plater.ChangeHealthBarColor_Internal (unitFrame.healthBar, r, g, b, a, true)
	end

	--force an update on all nameplates showin in the screen
	--called after a refresh color override (on init and option settings changes)
	--called after leaving the combat
	function Plater.UpdateAllNameplateColors() --private
		for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
			---@cast plateFrame plateframe
			if (not plateFrame.IsSelf) then
				--reset the nameplate color
				Plater.FindAndSetNameplateColor (plateFrame.unitFrame)
			end
		end
	end
	
	--get a unit and a text and color the text with the class color of the unit (accepts player GUID as well)
	function Plater.SetTextColorByClass (unit, text)
		--checking if the unit exists because this can be called from the cleu parser
		if (unit) then
			local _, class = nil, nil
			if (unit:sub(1, #"Player-") == "Player-") then
				_, class = GetPlayerInfoByGUID (unit)
			else
				_, class = UnitClass (unit)
			end
			if (class) then
				local color = DB_CLASS_COLORS [class]
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

	--run the hook "Nameplate Updated", this is called from inside the Tick and UpdateAllPlates()
	function Plater.TriggerNameplateUpdatedEvent(unitFrame)
		if unitFrame.PlaterOnScreen and (HOOK_NAMEPLATE_UPDATED.ScriptAmount > 0) then
			for i = 1, HOOK_NAMEPLATE_UPDATED.ScriptAmount do
				local globalScriptObject = HOOK_NAMEPLATE_UPDATED [i]

				local scriptContainer = unitFrame:ScriptGetContainer()
				local scriptInfo = unitFrame:HookGetInfo(globalScriptObject, scriptContainer, "Nameplate Updated")
				local scriptEnv = scriptInfo.Env
				scriptEnv._HealthPercent = unitFrame.healthBar.CurrentHealth / unitFrame.healthBar.CurrentHealthMax * 100
				
				--run
				unitFrame:ScriptRunHook (scriptInfo, "Nameplate Updated")
			end
		end
	end

	--full refresh calls
	function Plater.UpdateAllPlates (forceUpdate, justAdded, regenDisabled) --private
		for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
			---@cast plateFrame plateframe
			if plateFrame.unitFrame and plateFrame.unitFrame.PlaterOnScreen then
				if not plateFrame.unitFrame.isPerformanceUnit then
					if not IS_WOW_PROJECT_CLASSIC_ERA or (IS_WOW_PROJECT_CLASSIC_ERA and plateFrame.actorType ~= ACTORTYPE_ENEMY_PLAYER) then -- don't force update in classic
						Plater.AddToAuraUpdate(plateFrame.unitFrame.unit) -- force aura update
					end
				end
				
				Plater.UpdatePlateFrame (plateFrame, nil, forceUpdate, justAdded, regenDisabled)
				--trigger a nameplate updated event
				Plater.TriggerNameplateUpdatedEvent(plateFrame.unitFrame)
			end
		end
	end
	
	--called from the options panel | this is the same as calling Name_Plate_Unit_Added for each nameplate
	function Plater.FullRefreshAllPlates() --private
		for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
			---@cast plateFrame plateframe
			--hack to call the update without overriding user settings from scripts
			Plater.RunScheduledUpdate ({unitId = plateFrame [MEMBER_UNITID], GUID = plateFrame [MEMBER_GUID]})
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
	---update thee nameplate size including healthbar, castbar, etc
	---@param plateFrame plateframe
	function Plater.UpdatePlateSize (plateFrame)
		if (not plateFrame.actorType) then
			return
		end
		
		Plater.StartLogPerformanceCore("Plater-Core", "Update", "UpdatePlateSize")
		
		local profile = Plater.db.profile
		local unitFrame = plateFrame.unitFrame
		local healthBar = unitFrame.healthBar
		local castBar = unitFrame.castBar
		local powerBar = unitFrame.powerBar
		local buffFrame1 = unitFrame.BuffFrame
		local buffFrame2 = unitFrame.BuffFrame2
		
		local isInCombat = profile.use_player_combat_state and PLAYER_IN_COMBAT or unitFrame.InCombat
		
		--use in combat bars when in pvp
		if (plateFrame.actorType == ACTORTYPE_ENEMY_PLAYER) then
			if ((Plater.ZoneInstanceType == "pvp" or Plater.ZoneInstanceType == "arena") and DB_PLATE_CONFIG.player.pvp_always_incombat) then
				isInCombat = true
			end
		end
		
		local actorType = plateFrame.actorType
		
		--get the config for this actor type
		local plateConfigs = DB_PLATE_CONFIG [actorType]
		--get the config key based if the player is in combat
		local castBarConfigKey, healthBarConfigKey, manaConfigKey = Plater.GetHashKey (isInCombat)

		local healthBarWidth, healthBarHeight = unitFrame.customHealthBarWidth or plateConfigs [healthBarConfigKey][1], unitFrame.customHealthBarHeight or plateConfigs [healthBarConfigKey][2]
		local castBarWidth, castBarHeight = unitFrame.customCastBarWidth or plateConfigs [castBarConfigKey][1], unitFrame.customCastBarHeight or plateConfigs [castBarConfigKey][2]
		local powerBarWidth, powerBarHeight = unitFrame.customPowerBarWidth or plateConfigs [manaConfigKey][1], unitFrame.customPowerBarHeight or plateConfigs [manaConfigKey][2]
		
		local castBarOffSetX = plateConfigs.castbar_offset_x
		local castBarOffSetXRel = (healthBarWidth - castBarWidth) / 2
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
				local xOffSet = (plateFrame:GetWidth() - (healthBarWidth * unitFrame.nameplateScaleAdjust)) / 2
				local yOffSet = (plateFrame:GetHeight() - (healthBarHeight * unitFrame.nameplateScaleAdjust)) / 2
				
				healthBar:SetScale(1/unitFrame.nameplateScaleAdjust)
				
				healthBar:ClearAllPoints()
				PixelUtil.SetPoint (healthBar, "topleft", unitFrame, "topleft", xOffSet + profile.global_offset_x, -yOffSet + profile.global_offset_y)
				PixelUtil.SetPoint (healthBar, "bottomright", unitFrame, "bottomright", -xOffSet + profile.global_offset_x, yOffSet + profile.global_offset_y)
		end
		
		--execute indicator
			healthBar.healthCutOff:SetSize (healthBarHeight, healthBarHeight)
			healthBar.executeRange:SetHeight (healthBarHeight)
		
		--cast bar - is set by default below the healthbar
			castBar:ClearAllPoints()
			PixelUtil.SetPoint (castBar, "topleft", healthBar, "bottomleft", castBarOffSetXRel + castBarOffSetX, castBarOffSetY)
			PixelUtil.SetPoint (castBar, "topright", healthBar, "bottomright", -castBarOffSetXRel + castBarOffSetX, castBarOffSetY)
			PixelUtil.SetWidth (castBar, castBarWidth)
			PixelUtil.SetHeight (castBar, castBarHeight)
			--PixelUtil.SetSize (castBar.BorderShield, castBarHeight * 1.4, castBarHeight * 1.4)
			PixelUtil.SetSize (castBar.Spark, profile.cast_statusbar_spark_width, castBarHeight)
			castBar.Spark:SetAlpha (profile.cast_statusbar_spark_alpha)
			Plater.UpdateCastbarIcon(castBar)

			castBar._points = {{"topleft", healthBar, "bottomleft", castBarOffSetXRel + castBarOffSetX, castBarOffSetY},
			{"topright", healthBar, "bottomright", -castBarOffSetXRel + castBarOffSetX, castBarOffSetY}}

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
			--plateConfigs.buff_frame_y_offset is the offset from the actor type, e.g. enemy npc
			local bf1Anchor = Plater.db.profile.aura_frame1_anchor
			Plater.SetAnchor (buffFrame1, {side = bf1Anchor.side, x = bf1Anchor.x, y = bf1Anchor.y + plateConfigs.buff_frame_y_offset}, unitFrame.healthBar, (Plater.db.profile.aura_grow_direction or 2) == 2)
			
			
			local bf2Anchor = Plater.db.profile.aura_frame2_anchor
			Plater.SetAnchor (buffFrame2, {side = bf2Anchor.side, x = bf2Anchor.x, y = bf2Anchor.y + plateConfigs.buff_frame_y_offset}, unitFrame.healthBar, (Plater.db.profile.aura2_grow_direction or 2) == 2)
			
		if (Plater.db.profile.show_health_prediction or Plater.db.profile.show_shield_prediction) and healthBar.displayedUnit then
			healthBar:UpdateHealPrediction() -- ensure health prediction is updated properly
		end
		
		Plater.UpdateUnitName (plateFrame)
		
		Plater.EndLogPerformanceCore("Plater-Core", "Update", "UpdatePlateSize")
	end
	
	--debug function to print the size of the anchor for each aura container
	function Plater.DebugAuraAnchor()
		local profile = Plater.db.profile
		--get the config for this actor type
		local plateConfigs = DB_PLATE_CONFIG ["enemynpc"]
		print ("DB_PLATE_CONFIG [enemynpc].buff_frame_y_offset:", plateConfigs.buff_frame_y_offset)
		
	end
	
	--show the background of the clickable aura, this is also shown when changing the clickable area
	function Plater.SetPlateBackground (plateFrame)
		plateFrame.unitFrame:SetBackdrop ({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16, edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1})
		plateFrame.unitFrame:SetBackdropColor (0, 0, 0, 0.5)
		plateFrame.unitFrame:SetBackdropBorderColor (0, 0, 0, 1)
	end

	local shutdown_platesize_debug = function (timer)
		for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
		
			Plater.HideClickSpace (plateFrame)
			
			if (Plater.db.profile.click_space_always_show) then
				Plater.SetPlateBackground (plateFrame)
			else
				plateFrame.unitFrame:SetBackdrop (nil)
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
	
	-- default blizzard plate shenanigans
	function Plater.UpdateBaseNameplateOptions()
		if GetCVarBool ("nameplateShowOnlyNames") or Plater.db.profile.saved_cvars.nameplateShowOnlyNames == "1" then
			TextureLoadingGroupMixin.AddTexture({ textures = DefaultCompactNamePlateFrameSetUpOptions }, "hideHealthbar")
			TextureLoadingGroupMixin.AddTexture({ textures = DefaultCompactNamePlateFrameSetUpOptions }, "hideCastbar")
			TextureLoadingGroupMixin.AddTexture({ textures = DefaultCompactNamePlateFrameSetUpOptions }, "colorNameBySelection")
			TextureLoadingGroupMixin.AddTexture({ textures = DefaultCompactNamePlateFrameSetUpOptions }, "colorNameWithExtendedColors")
			TextureLoadingGroupMixin.AddTexture({ textures = DefaultCompactNamePlateFriendlyFrameOptions }, "hideHealthbar")
			TextureLoadingGroupMixin.AddTexture({ textures = DefaultCompactNamePlateFriendlyFrameOptions }, "hideCastbar")
			TextureLoadingGroupMixin.AddTexture({ textures = DefaultCompactNamePlateFriendlyFrameOptions }, "colorNameBySelection")
			TextureLoadingGroupMixin.AddTexture({ textures = DefaultCompactNamePlateFriendlyFrameOptions }, "colorNameWithExtendedColors")
			TextureLoadingGroupMixin.AddTexture({ textures = DefaultCompactNamePlateEnemyFrameOptions }, "hideHealthbar")
			TextureLoadingGroupMixin.AddTexture({ textures = DefaultCompactNamePlateEnemyFrameOptions }, "hideCastbar")
			TextureLoadingGroupMixin.AddTexture({ textures = DefaultCompactNamePlateEnemyFrameOptions }, "colorNameBySelection")
			TextureLoadingGroupMixin.AddTexture({ textures = DefaultCompactNamePlateEnemyFrameOptions }, "colorNameWithExtendedColors")
			
			TextureLoadingGroupMixin.RemoveTexture({ textures = DefaultCompactNamePlateFrameSetUpOptions }, "showLevel")
			TextureLoadingGroupMixin.RemoveTexture({ textures = DefaultCompactNamePlateFriendlyFrameOptions }, "showLevel")
			TextureLoadingGroupMixin.RemoveTexture({ textures = DefaultCompactNamePlateEnemyFrameOptions }, "showLevel")
		else
			TextureLoadingGroupMixin.RemoveTexture({ textures = DefaultCompactNamePlateFrameSetUpOptions }, "hideHealthbar")
			TextureLoadingGroupMixin.RemoveTexture({ textures = DefaultCompactNamePlateFrameSetUpOptions }, "hideCastbar")
			TextureLoadingGroupMixin.RemoveTexture({ textures = DefaultCompactNamePlateFriendlyFrameOptions }, "hideHealthbar")
			TextureLoadingGroupMixin.RemoveTexture({ textures = DefaultCompactNamePlateFriendlyFrameOptions }, "hideCastbar")
			TextureLoadingGroupMixin.RemoveTexture({ textures = DefaultCompactNamePlateEnemyFrameOptions }, "hideHealthbar")
			TextureLoadingGroupMixin.RemoveTexture({ textures = DefaultCompactNamePlateEnemyFrameOptions }, "hideCastbar")
			
			
			if not IS_WOW_PROJECT_MAINLINE then
				--other defaults
				TextureLoadingGroupMixin.RemoveTexture({ textures = DefaultCompactNamePlateFrameSetUpOptions }, "colorNameBySelection")
				TextureLoadingGroupMixin.RemoveTexture({ textures = DefaultCompactNamePlateFrameSetUpOptions }, "colorNameWithExtendedColors")
				TextureLoadingGroupMixin.RemoveTexture({ textures = DefaultCompactNamePlateFriendlyFrameOptions }, "colorNameBySelection")
				TextureLoadingGroupMixin.RemoveTexture({ textures = DefaultCompactNamePlateFriendlyFrameOptions }, "colorNameWithExtendedColors")
				TextureLoadingGroupMixin.RemoveTexture({ textures = DefaultCompactNamePlateEnemyFrameOptions }, "colorNameBySelection")
				TextureLoadingGroupMixin.RemoveTexture({ textures = DefaultCompactNamePlateEnemyFrameOptions }, "colorNameWithExtendedColors")
				
				TextureLoadingGroupMixin.AddTexture({ textures = DefaultCompactNamePlateFrameSetUpOptions }, "showLevel")
				TextureLoadingGroupMixin.AddTexture({ textures = DefaultCompactNamePlateFriendlyFrameOptions }, "showLevel")
				TextureLoadingGroupMixin.AddTexture({ textures = DefaultCompactNamePlateEnemyFrameOptions }, "showLevel")
			end

		end
		if not IS_WOW_PROJECT_MAINLINE then
			for _, plateFrame in pairs(C_NamePlate.GetNamePlates(true)) do
				if (plateFrame) then
					if GetCVarBool ("nameplateShowOnlyNames") or Plater.db.profile.saved_cvars.nameplateShowOnlyNames == "1" then
						TextureLoadingGroupMixin.RemoveTexture({ textures = plateFrame.UnitFrame.CastBar }, "showCastbar")
					else
						TextureLoadingGroupMixin.AddTexture({ textures = plateFrame.UnitFrame.CastBar }, "showCastbar")
					end
				end
			end
		end
	end
	
	-- ~platesize
	function Plater.UpdatePlateClickSpace (needReorder, isDebug) --private
		if (not Plater.CanChangePlateSize()) then
			return C_Timer.After (1, re_UpdatePlateClickSpace)
		end
		
		Plater.StartLogPerformanceCore("Plater-Core", "Update", "UpdatePlateClickSpace")
		
		local width, height = Plater.db.profile.click_space_friendly[1], Plater.db.profile.click_space_friendly[2]
		C_NamePlate.SetNamePlateFriendlySize (width, height) --classic: {132, 32}, retail: {110, 45},
		
		local width, height = Plater.db.profile.click_space[1], Plater.db.profile.click_space[2]
		C_NamePlate.SetNamePlateEnemySize (width, height) --classic: {132, 32}, retail: {110, 45},
		
		--C_NamePlate.SetNamePlateSelfPreferredClickInsets (0, 0, 0, 0)
		--C_NamePlate.SetNamePlateFriendlyPreferredClickInsets (0, 0, 0, 0)
		--C_NamePlate.SetNamePlateEnemyPreferredClickInsets (0, 0, 0, 0)
		
		C_NamePlate.SetNamePlateFriendlyClickThrough (Plater.db.profile.plate_config.friendlyplayer.click_through) 
		
		if (isDebug and not Plater.db.profile.click_space_always_show) then
			for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
				if not plateFrame.IsSelf and plateFrame.unitFrame.PlaterOnScreen then
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
		
		Plater.EndLogPerformanceCore("Plater-Core", "Update", "UpdatePlateClickSpace")
	end
	
	function Plater.ForceTickOnAllNameplates() --private
		for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
			if plateFrame.unitFrame.PlaterOnScreen then
				Plater.NameplateTick (plateFrame.OnTickFrame, 10) --GetWorldDeltaSeconds()
			end
		end
	end
	
	--FPS meter to spread NameplateTick evenly
	Plater.FPSData = {
		startTime = GetTime(),
		platesUpdatedThisFrame = 0,
		platesToUpdatePerFrame = 40,
		frames = 1,
		curFPS = 1,
	}
	
	function Plater.EveryFrameFPSCheck()
		-- calculate every .25sec
		local curTime = GetTime()
		local curFPSData = Plater.FPSData
		if (curFPSData.startTime + 0.25) < curTime then
			curFPSData.curFPS = max(curFPSData.frames / (curTime - curFPSData.startTime), 1)
			curFPSData.platesToUpdatePerFrame = math.ceil(NUM_NAMEPLATES_ON_SCREEN / DB_TICK_THROTTLE / curFPSData.curFPS)
			
			--ViragDevTool_AddData({curFPSData=curFPSData, NUM_NAMEPLATES_ON_SCREEN = NUM_NAMEPLATES_ON_SCREEN}, "Plater_FPS")
			
			curFPSData.frames = 0
			curFPSData.startTime = curTime
		else
			curFPSData.frames = curFPSData.frames + 1
		end
		
		--ViragDevTool_AddData(curFPSData.platesUpdatedThisFrame, "platesUpdatedThisFrame")
		curFPSData.platesUpdatedThisFrame = 0
		
		C_Timer.After( 0, Plater.EveryFrameFPSCheck )
	end
	C_Timer.After( 0, Plater.EveryFrameFPSCheck )
	
	-- ~ontick ~onupdate ~tick
	function Plater.NameplateTick (tickFrame, deltaTime) --private
		Plater.StartLogPerformanceCore("Plater-Core", "Update", "NameplateTick")

		tickFrame.ThrottleUpdate = (tickFrame.ThrottleUpdate or 0) - deltaTime
		local unitFrame = tickFrame.unitFrame
		local healthBar = unitFrame.healthBar
		local profile = Plater.db.profile
		
		--throttle updates, things on this block update with the interval set in the advanced tab
		local shouldUpdate = tickFrame.ThrottleUpdate < 0
		local curFPSData = Plater.FPSData
		if shouldUpdate and not ((1.5 * DB_TICK_THROTTLE + tickFrame.ThrottleUpdate) < 0) then --ensure updates are not posponed indefinetely
			if curFPSData.platesUpdatedThisFrame >= curFPSData.platesToUpdatePerFrame then
				shouldUpdate = false
			end
		end

		if (shouldUpdate) then
			Plater.StartLogPerformanceCore("Plater-Core", "Update", "NameplateTick-Full")
		
			curFPSData.platesUpdatedThisFrame = curFPSData.platesUpdatedThisFrame + 1
			
			--make the db path smaller for performance
			local actorTypeDBConfig = DB_PLATE_CONFIG [tickFrame.actorType]
			
			--health cutoff (execute range) - don't show if the nameplate is the personal bar
			if (DB_USE_HEALTHCUTOFF and not unitFrame.IsSelf and not unitFrame.PlayerCannotAttack) then
				local healthPercent = (healthBar.currentHealth or 1) / (healthBar.currentHealthMax or 1)
				if (healthPercent < DB_HEALTHCUTOFF_AT) then
					if (not healthBar.healthCutOff:IsShown() or healthBar.healthCutOff.isUpper) then
						healthBar.healthCutOff.isUpper = false
						healthBar.healthCutOff.isLower = true
						healthBar.healthCutOff:ClearAllPoints()
						healthBar.healthCutOff:SetSize (healthBar:GetHeight(), healthBar:GetHeight())
						healthBar.healthCutOff:SetPoint ("center", healthBar, "left", healthBar:GetWidth() * DB_HEALTHCUTOFF_AT, 0)
						
						if (not profile.health_cutoff_hide_divisor) then
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
						healthBar.executeRange:SetPoint ("left", healthBar, "left")
						
						if (profile.health_cutoff_extra_glow) then
							healthBar.ExecuteGlowUp.ShowAnimation:Play()
							healthBar.ExecuteGlowDown.ShowAnimation:Play()
						end
					end
					
					unitFrame.InExecuteRange = true
				elseif (healthPercent > DB_HEALTHCUTOFF_AT_UPPER and healthPercent < 0.999) then
					if (not healthBar.healthCutOff:IsShown() or healthBar.healthCutOff.isLower) then
						healthBar.healthCutOff.isUpper = true
						healthBar.healthCutOff.isLower = false
						healthBar.healthCutOff:ClearAllPoints()
						healthBar.healthCutOff:SetSize (healthBar:GetHeight(), healthBar:GetHeight())
						healthBar.healthCutOff:SetPoint ("center", healthBar, "right", - (healthBar:GetWidth() * (1-DB_HEALTHCUTOFF_AT_UPPER)), 0)
						
						if (not profile.health_cutoff_hide_divisor) then
							healthBar.healthCutOff:Show()
							healthBar.healthCutOff.ShowAnimation:Play()
						else
							healthBar.healthCutOff:Show()
							healthBar.healthCutOff:SetAlpha (0)
						end

						healthBar.executeRange:Show()
						healthBar.executeRange:SetTexCoord (0, 1-DB_HEALTHCUTOFF_AT_UPPER, 0, 1)
						healthBar.executeRange:SetAlpha (0.2)
						healthBar.executeRange:SetVertexColor (.3, .3, .3)
						healthBar.executeRange:SetHeight (healthBar:GetHeight())
						healthBar.executeRange:SetPoint ("left", healthBar.healthCutOff, "center")
						healthBar.executeRange:SetPoint ("right", healthBar, "right")
						
						if (profile.health_cutoff_extra_glow) then
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
			
			local isSoftInteract = UnitIsUnit(tickFrame.unit, "softinteract")
			unitFrame.isSoftInteract = isSoftInteract
			unitFrame.PlateFrame.isSoftInteract = isSoftInteract
			unitFrame.isSoftInteractObject = isSoftInteract and (unitFrame.PlateFrame.isObject or unitFrame.isObject)
			unitFrame.PlateFrame.isSoftInteractObject = isSoftInteract and (unitFrame.PlateFrame.isObject or unitFrame.isObject)
			
			local isLooseTarget = IsTargetLoose()
			unitFrame.isLooseTarget = isLooseTarget
			unitFrame.PlateFrame.isLooseTarget = isLooseTarget
			local isSoftEnemy = UnitIsUnit(tickFrame.unit, "softenemy")
			unitFrame.isSoftEnemy = isSoftEnemy
			unitFrame.PlateFrame.isSoftEnemy = isSoftEnemy
			local isSoftFriend = UnitIsUnit(tickFrame.unit, "softfriend")
			unitFrame.isSoftFriend = isSoftFriend
			unitFrame.PlateFrame.isSoftFriend = isSoftFriend
			
			local wasCombat = unitFrame.InCombat
			unitFrame.InCombat = UnitAffectingCombat (tickFrame.unit) or (Plater.ForceInCombatUnits[unitFrame [MEMBER_NPCID]] and PLAYER_IN_COMBAT) or false
			if wasCombat ~= unitFrame.InCombat then
				Plater.UpdatePlateSize (tickFrame.PlateFrame)
			end
			
			--check aggro if is in combat
			if (PLAYER_IN_COMBAT) then
				if (unitFrame.CanCheckAggro) then
					Plater.UpdateNameplateThread (unitFrame)
				end
			end
			
			--perform a range check
			Plater.CheckRange (tickFrame.PlateFrame, (deltaTime == 999))
			
			--if not in combat, check if can show the percent health out of combat
			if (actorTypeDBConfig.percent_text_enabled and (((profile.use_player_combat_state and PLAYER_IN_COMBAT or unitFrame.InCombat)) or actorTypeDBConfig.percent_text_ooc)) then
				Plater.UpdateLifePercentText (healthBar, unitFrame.unit, actorTypeDBConfig.percent_show_health, actorTypeDBConfig.percent_show_percent, actorTypeDBConfig.percent_text_show_decimals)
				healthBar.lifePercent:Show()
			else
				healthBar.lifePercent:Hide()
			end

			if (not unitFrame.DenyColorChange) then --tagged from a script
				--if the unit tapped? (gray color)
				if (Plater.IsUnitTapDenied (tickFrame.unit)) then
					Plater.ChangeHealthBarColor_Internal (healthBar, unpack (profile.tap_denied_color))
				end
			end

			--the color overrider for unitIDs goes after the threat check and before the aura, since auras can run scripts and scripts have priority on setting colors
			if (DB_UNITCOLOR_CACHE [unitFrame [MEMBER_NPCID]]) then
				Plater.ChangeHealthBarColor_Internal (healthBar, unpack (DB_UNITCOLOR_CACHE [unitFrame [MEMBER_NPCID]]))
				unitFrame.UsingCustomColor = true --exposed to scripts
			end
			
			--update buffs and debuffs
			if (DB_AURA_ENABLED) then --should update only when the heathbar is shown?
				--Plater.StartLogPerformanceCore("Plater-Core", "Update", "UpdateAuras")
				
				if (DB_TRACK_METHOD == 0x1) then --automatic
					if (tickFrame.actorType == ACTORTYPE_PLAYER) then
						--update auras on the personal bar
						Plater.UpdateAuras_Self_Automatic (tickFrame.BuffFrame, tickFrame.unit)
					else
						Plater.UpdateAuras_Automatic (tickFrame.BuffFrame, tickFrame.unit)
					end
				else
					--manual aura track
					Plater.UpdateAuras_Manual (tickFrame.BuffFrame, tickFrame.unit, tickFrame.actorType == ACTORTYPE_PLAYER)
				end
				
				--update the buff layout and alpha
				tickFrame.BuffFrame.unit = tickFrame.unit

				--ghost and extra auras only show in the debuff frame
				Plater.ShowGhostAuras(tickFrame.BuffFrame) 
				--check for expired extra auras
				platerInternal.ExtraAuras.ClearExpired()
				--update extra auras
				platerInternal.ExtraAuras.Show(tickFrame.BuffFrame)
				
				--align icons in the aura frame
				Plater.AlignAuraFrames (tickFrame.BuffFrame)
				--update the alignment on the second aura frame as well if enabled
				if (DB_AURA_SEPARATE_BUFFS) then
					Plater.AlignAuraFrames (tickFrame.BuffFrame.BuffFrame2)
				end
				
				Plater.RunScriptTriggersForAuraIcons (unitFrame)
				
				--tickFrame.BuffFrame:SetAlpha (DB_AURA_ALPHA)
				--tickFrame.BuffFrame2:SetAlpha (DB_AURA_ALPHA)
				
				--Plater.EndLogPerformanceCore("Plater-Core", "Update", "UpdateAuras")
			end
			-- update DBM and BigWigs nameplate auras
			Plater.UpdateBossModAuras(unitFrame)
			
			--set the delay to perform another update
			tickFrame.ThrottleUpdate = DB_TICK_THROTTLE * (unitFrame.isPerformanceUnit and 5 or 1)

			--check if the unit name or unit npcID has a script
			local globalScriptObject = SCRIPT_UNIT_TRIGGER_CACHE[tickFrame.PlateFrame [MEMBER_NAMELOWER]] or SCRIPT_UNIT_TRIGGER_CACHE[unitFrame [MEMBER_NPCID]]
			--check if this aura has a custom script
			if (globalScriptObject) then
				--stored information about scripts
				local scriptContainer = unitFrame:ScriptGetContainer()
				--get the info about this particularly script
				local scriptInfo = unitFrame:ScriptGetInfo(globalScriptObject, scriptContainer)
				
				local scriptEnv = scriptInfo.Env
				scriptEnv._UnitID = tickFrame.PlateFrame [MEMBER_UNITID]
				scriptEnv._NpcID = tickFrame.PlateFrame [MEMBER_NPCID]
				scriptEnv._UnitName = tickFrame.PlateFrame [MEMBER_NAME]
				scriptEnv._UnitGUID = tickFrame.PlateFrame [MEMBER_GUID]
				scriptEnv._HealthPercent = healthBar.CurrentHealth / healthBar.CurrentHealthMax * 100
		
				--run onupdate script
				unitFrame:ScriptRunOnUpdate(scriptInfo)
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
						local scriptInfo = unitFrame:HookGetInfo(globalScriptObject, scriptContainer, "Name Updated")
						--run
						unitFrame:ScriptRunHook (scriptInfo, "Name Updated")
					end
				end
			end
			
			--hooks
			Plater.TriggerNameplateUpdatedEvent(unitFrame)
			
			--details! integration
			if (IS_USING_DETAILS_INTEGRATION and not tickFrame.PlateFrame.IsSelf and PLAYER_IN_COMBAT and unitFrame.InCombat) then
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
			
			--check shield ~shield
			if (IS_WOW_PROJECT_MAINLINE) then
				if (profile.indicator_shield) then
					local amountAbsorb = UnitGetTotalAbsorbs(tickFrame.PlateFrame[MEMBER_UNITID])
					if (amountAbsorb and amountAbsorb > 0) then
						--update the total amount on the shield indicator
						if (not healthBar.shieldIndicator.shieldTotal) then
							healthBar.shieldIndicator.shieldTotal = amountAbsorb
						else
							if (amountAbsorb > healthBar.shieldIndicator.shieldTotal) then
								healthBar.shieldIndicator.shieldTotal = amountAbsorb
							end
						end

						healthBar.shieldIndicator:Show()

						local percent = amountAbsorb / healthBar.shieldIndicator.shieldTotal
						local width = healthBar:GetWidth() * percent
						healthBar.shieldIndicator:SetWidth(width)
					else
						--hide the shield bar is currently shown
						if (healthBar.shieldIndicator:IsShown()) then
							healthBar.shieldIndicator:Hide()
							healthBar.shieldIndicator.shieldTotal = nil
						end
					end
				end
			end
			
			if (unitFrame.castBar:IsShown()) then
				Plater.CastBarOnTick_Hook(unitFrame.castBar, 999)
			end
			
			Plater.EndLogPerformanceCore("Plater-Core", "Update", "NameplateTick-Full")

			--end of throttled updates
		end

		--OnTick updates
			--smooth color transition ~lerpcolor
			if (DB_LERP_COLOR and not unitFrame.isPerformanceUnit) then
				local currentR, currentG, currentB = healthBar.barTexture:GetVertexColor()
				local r, g, b = DF:LerpLinearColor (deltaTime, DB_LERP_COLOR_SPEED, currentR, currentG, currentB, healthBar.R or currentR, healthBar.G or currentG, healthBar.B or currentB)
				healthBar.barTexture:SetVertexColor (r, g, b)
			end
			
			--animate health bar ~animation
			if (DB_DO_ANIMATIONS and not unitFrame.isPerformanceUnit) then
				if (healthBar.IsAnimating) then
					healthBar.AnimateFunc (healthBar, deltaTime)
				end
			end
			
		Plater.EndLogPerformanceCore("Plater-Core", "Update", "NameplateTick")
	end
	
	local set_aggro_color = function (self, r, g, b, a) --self = unitName
		if (DB_AGGRO_CHANGE_HEALTHBAR_COLOR) then
			if (not self.DenyColorChange) then --tagged from a script
				Plater.ChangeHealthBarColor_Internal (self.healthBar, r, g, b, a)
			end
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
		if (not self.displayedUnit or not self.CanCheckAggro) then
			return
		end
		
		Plater.StartLogPerformanceCore("Plater-Core", "Update", "UpdateNameplateThreat")
		
		local profile = Plater.db.profile
		
		local isTanking, threatStatus, threatpct, threatrawpct, threatValue = UnitDetailedThreatSituation ("player", self.displayedUnit)
		
		--expose all threat situation to scripts
		self.namePlateThreatIsTanking = isTanking
		self.namePlateThreatStatus = threatStatus
		self.namePlateThreatPercent = threatpct or 0
		self.namePlateThreatRawPercent = threatrawpct or 0
		self.namePlateThreatValue = threatValue or 0
		-- (3 = securely tanking, 2 = insecurely tanking, 1 = not tanking but higher threat than tank, 0 = not tanking and lower threat than tank)
		self.namePlateThreatOffTankIsTanking = false
		self.namePlateThreatOffTankName = nil
		
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
							if UnitExists(tank) and not UnitIsUnit("player", tank) then
								otherIsTanking, otherThreatStatus, otherThreatpct = UnitDetailedThreatSituation (tank, self.displayedUnit)
								if otherIsTanking then
									unitOffTank = tank
									break
								end
							end
						end

						--another tank is tanking the unit
						if (unitOffTank) then
							self.namePlateThreatOffTankIsTanking = true
							self.namePlateThreatOffTankName = unitOffTank
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
							self:SetAlpha (profile.not_affecting_combat_alpha)
						end
					end
				end
			else
				--The player is tanking and:
				if (threatStatus == 3) then --is tanking safely
					set_aggro_color (self, unpack (DB_AGGRO_TANK_COLORS.aggro))
					
				elseif (threatStatus == 2) then --is tanking with risk of aggro loss
					set_aggro_color (self, unpack (DB_AGGRO_TANK_COLORS.pulling))
					if profile.show_aggro_glow then
						self.aggroGlowUpper:Show()
						self.aggroGlowLower:Show()
					end
					
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
				if profile.dps.use_aggro_solo and not IsInGroup() then
					set_aggro_color (self, unpack (DB_AGGRO_DPS_COLORS.solo))
				else
					set_aggro_color (self, unpack (DB_AGGRO_DPS_COLORS.aggro))
				end
				if (not self.PlateFrame.playerHasAggro and IS_IN_INSTANCE) then
					if profile.show_aggro_flash then
						self.PlateFrame.PlayBodyFlash ("-AGGRO-")
					end
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
							
							if (DB_NOT_COMBAT_ALPHA_ENABLED) then --not self.PlateFrame [MEMBER_NOCOMBAT] and 
								self.PlateFrame [MEMBER_NOCOMBAT] = true
								self:SetAlpha (profile.not_affecting_combat_alpha)
							end
						end
						
					end
				else
					if (threatStatus == 3) then --player is tanking the mob as dps
						if profile.dps.use_aggro_solo and not IsInGroup() then
							set_aggro_color (self, unpack (DB_AGGRO_DPS_COLORS.solo))
						else
							set_aggro_color (self, unpack (DB_AGGRO_DPS_COLORS.aggro))
						end
						if (not self.PlateFrame.playerHasAggro and IS_IN_INSTANCE) then
							if profile.show_aggro_flash then
								self.PlateFrame.PlayBodyFlash ("-AGGRO-")
							end
						end
						self.PlateFrame.playerHasAggro = true
						
					elseif (threatStatus == 2) then --player is tanking the mob with low aggro
						if profile.dps.use_aggro_solo and not IsInGroup() then
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
							if profile.show_aggro_glow then
								self.aggroGlowUpper:Show()
								self.aggroGlowLower:Show()
							end
							if profile.dps.use_aggro_solo and not IsInGroup() then
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
										if UnitExists(tankName) then
											local threatStatus = UnitThreatSituation (tankName, self.displayedUnit)
											if (threatStatus and threatStatus >= 2) then
												--a tank has aggro on this unit, it is a false positive
												hasTankAggro = true
												break
											end
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
		
		Plater.EndLogPerformanceCore("Plater-Core", "Update", "UpdateNameplateThreat")
	end	
	
	function Plater.UpdateSoftInteractTarget(plateFrame, updateText)
		local unitFrame = plateFrame.unitFrame
		local unitID = plateFrame [MEMBER_UNITID]
		
		local isSoftInteract = UnitIsUnit(unitID, "softinteract")
		local reaction = UnitReaction (unitID, "player")
		local isObject = (IS_WOW_PROJECT_MAINLINE and UnitIsGameObject(unitID)) or reaction == nil
		local isSoftInteractObject = isObject and isSoftInteract
		plateFrame.isSoftInteract = isSoftInteract
		unitFrame.isSoftInteract = isSoftInteract
		plateFrame.isObject = isObject
		unitFrame.isObject = isObject
		plateFrame.isSoftInteractObject = isSoftInteractObject
		unitFrame.isSoftInteractObject = isSoftInteractObject
		
		local isLooseTarget = IsTargetLoose()
		unitFrame.isLooseTarget = isLooseTarget
		unitFrame.PlateFrame.isLooseTarget = isLooseTarget
		local isSoftEnemy = UnitIsUnit(unitID, "softenemy")
		unitFrame.isSoftEnemy = isSoftEnemy
		unitFrame.PlateFrame.isSoftEnemy = isSoftEnemy
		local isSoftFriend = UnitIsUnit(unitID, "softfriend")
		unitFrame.isSoftFriend = isSoftFriend
		unitFrame.PlateFrame.isSoftFriend = isSoftFriend
		
		if plateFrame.IsNpcWithoutHealthBar and updateText then
			Plater.UpdatePlateText (plateFrame, DB_PLATE_CONFIG [plateFrame.unitFrame.ActorType], false)
		end
		
		if isSoftInteract and Plater.db.profile.show_softinteract_icons then
			--re-anchor
			Plater.SetAnchor(unitFrame.softInteractIcon, unitFrame.softInteractIcon.anchor or { side = 8, x = 0, y = 18, }, plateFrame)
			
			local size = unitFrame.softInteractIcon.size or 24
			unitFrame.softInteractIconFrame:SetSize(size, size)
			unitFrame.softInteractIcon:SetDesaturated(false)
			unitFrame.softInteractIcon:SetIgnoreParentAlpha(true)
			unitFrame.softInteractIcon:SetSize(size, size)
			unitFrame.softInteractIconFrame:Show()
			unitFrame.softInteractIcon:Show()
			
			local hasTexture =  SetUnitCursorTexture(unitFrame.softInteractIcon, plateFrame [MEMBER_UNITID], nil, true)
			if not hasTexture then
				unitFrame.softInteractIcon:SetTexture(136243)
			end
		else
			unitFrame.softInteractIconFrame:Hide()
		end
	end
	
	-- ~target ~selection
	function Plater.UpdateTarget (plateFrame) --private

		local profile = Plater.db.profile
		local unitFrame = plateFrame.unitFrame
		if UnitIsUnit (unitFrame [MEMBER_UNITID], "focus") then
			if profile.focus_indicator_enabled then
				--this is a rare call, no need to cache these values
				local texture = LibSharedMedia:Fetch ("statusbar", Plater.db.profile.focus_texture)
				plateFrame.FocusIndicator:SetTexture (texture)
				plateFrame.FocusIndicator:SetVertexColor (unpack (Plater.db.profile.focus_color))
				plateFrame.FocusIndicator:Show()
			end
			unitFrame.IsFocus = true
		else
			unitFrame.IsFocus = false
			plateFrame.FocusIndicator:Hide()
		end

		if (UnitIsUnit (unitFrame [MEMBER_UNITID], "target")) then
			plateFrame [MEMBER_TARGET] = true
			unitFrame [MEMBER_TARGET] = true
			
			--hide obscured texture
			plateFrame.Obscured:Hide()
			
			--target indicator
			Plater.UpdateTargetIndicator (plateFrame)
			
			--target highlight
			if (profile.target_highlight) then
				if (plateFrame.actorType ~= ACTORTYPE_FRIENDLY_PLAYER and plateFrame.actorType ~= ACTORTYPE_FRIENDLY_NPC and not plateFrame.PlayerCannotAttack and unitFrame.healthBar:IsShown()) then
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
			
			if (not unitFrame.healthBar:IsShown()) then
				unitFrame.targetOverlayTexture:Hide()
			else
				unitFrame.targetOverlayTexture:Show()
			end
			
			if (DB_USE_UIPARENT) then
				Plater.UpdateUIParentTargetLevels (unitFrame)
			end
			
			Plater.UpdateResourceFrame()
		else
			plateFrame.TargetNeonUp:Hide()
			plateFrame.TargetNeonDown:Hide()
			unitFrame.targetOverlayTexture:Hide()
			
			plateFrame [MEMBER_TARGET] = nil
			unitFrame [MEMBER_TARGET] = nil
			
			if (unitFrame.IsTarget or unitFrame.TargetTextures2Sides [1]:IsShown() or unitFrame.TargetTextures4Sides [1]:IsShown()) then
				for i = 1, 2 do
					unitFrame.TargetTextures2Sides [i]:Hide()
				end
				for i = 1, 4 do
					unitFrame.TargetTextures4Sides [i]:Hide()
				end
				
				unitFrame.IsTarget = false
			end
			
			if (DB_TARGET_SHADY_ENABLED and (not DB_TARGET_SHADY_COMBATONLY or (profile.use_player_combat_state and PLAYER_IN_COMBAT or unitFrame.InCombat)) and not plateFrame.IsSelf) then
				plateFrame.Obscured:Show()
				plateFrame.Obscured:SetAlpha (DB_TARGET_SHADY_ALPHA)
			else
				plateFrame.Obscured:Hide()
			end
			
			if (DB_USE_UIPARENT) then
				Plater.UpdateUIParentLevels (unitFrame)
			end
		end

		Plater.CheckRange (plateFrame, true) --disabled on 2018-10-09 | enabled back on 2020-1-16

	end

	--called when the player targets a new unit, when focus changed or when a unit isn't in the screen any more
	function Plater.OnPlayerTargetChanged() --private
		Plater.PlayerCurrentTargetGUID = UnitGUID ("target")
		Plater.PlayerHasTarget = Plater.PlayerCurrentTargetGUID and true
		Plater.PlayerHasTargetNonSelf = Plater.PlayerHasTarget and Plater.PlayerCurrentTargetGUID ~= Plater.PlayerGUID and true
		Plater.PlayerCurrentFocusTargetGUID = UnitGUID ("focus")
		Plater.PlayerHasFocusTarget = Plater.PlayerCurrentFocusTargetGUID and true
		Plater.PlayerHasFocusTargetNonSelf = Plater.PlayerHasFocusTarget and Plater.PlayerCurrentFocusTargetGUID ~= Plater.PlayerGUID and true
		
		for index, plateFrame in ipairs (Plater.GetAllShownPlates()) do
			if plateFrame.unitFrame.PlaterOnScreen then
				Plater.UpdateTarget (plateFrame)
				
				--hooks
				if (HOOK_TARGET_CHANGED.ScriptAmount > 0) then
					for i = 1, HOOK_TARGET_CHANGED.ScriptAmount do
						local globalScriptObject = HOOK_TARGET_CHANGED [i]
						local unitFrame = plateFrame.unitFrame
						local scriptContainer = unitFrame:ScriptGetContainer()
						local scriptInfo = unitFrame:HookGetInfo(globalScriptObject, scriptContainer, "Target Changed")
						--run
						unitFrame:ScriptRunHook (scriptInfo, "Target Changed")
					end
				end
			end
		end

		Plater.Resources.UpdateResourceFramePosition() --~resource
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
		plateFrame.TargetNeonUp:SetHeight (height)
		PixelUtil.SetPoint (plateFrame.TargetNeonUp, "bottomleft", healthBar, "topleft", 0, 0)
		PixelUtil.SetPoint (plateFrame.TargetNeonUp, "bottomright", healthBar, "topright", 0, 0)

		plateFrame.TargetNeonDown:SetVertexColor (unpack (color))
		plateFrame.TargetNeonDown:SetAlpha (alpha)
		plateFrame.TargetNeonDown:SetTexture (texture)
		plateFrame.TargetNeonDown:SetHeight (height)
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
		local wscale, hscale = preset.wscale or 1, preset.hscale or 1
		local x, y = preset.x or 0, preset.y or 0
		local desaturated = preset.desaturated
		local coords = preset.coords
		local path = preset.path
		local blend = preset.blend or "BLEND"
		local alpha = preset.alpha or 1
		local doScale = preset.autoScale
		local custScale = preset.scale
		local overlayColorR, overlayColorG, overlayColorB = DF:ParseColors (preset.color or "white")
		
		local scale = (not doScale and custScale) or (healthBarHeight / (doScale and height or 10))
		
		--four parts (textures)
		if (#coords == 4) then
			for i = 1, 4 do
				local texture = plateFrame.unitFrame.TargetTextures4Sides [i]
				texture:Show()
				texture:SetTexture (path)
				texture:SetTexCoord (unpack (coords [i]))
				texture:SetSize (width * scale * wscale, height * scale * hscale)
				texture:SetAlpha (alpha)
				texture:SetVertexColor (overlayColorR, overlayColorG, overlayColorB)
				texture:SetDesaturated (desaturated)
				
				if (i == 1) then
					--PixelUtil.SetPoint (texture, "topleft", plateFrame.unitFrame.healthBar, "topleft", -x * scale, y * scale)
					texture:SetPoint ("topleft", plateFrame.unitFrame.healthBar, "topleft", -x * scale, y * scale)
					
				elseif (i == 2) then
					--PixelUtil.SetPoint (texture, "bottomleft", plateFrame.unitFrame.healthBar, "bottomleft", -x * scale, -y * scale)
					texture:SetPoint ("bottomleft", plateFrame.unitFrame.healthBar, "bottomleft", -x * scale, -y * scale)
					
				elseif (i == 3) then
					--PixelUtil.SetPoint (texture, "bottomright", plateFrame.unitFrame.healthBar, "bottomright", x * scale, -y * scale)
					texture:SetPoint ("bottomright", plateFrame.unitFrame.healthBar, "bottomright", x * scale, -y * scale)
					
				elseif (i == 4) then
					--PixelUtil.SetPoint (texture, "topright", plateFrame.unitFrame.healthBar, "topright", x * scale, y * scale)
					texture:SetPoint ("topright", plateFrame.unitFrame.healthBar, "topright", x * scale, y * scale)
					
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
				--PixelUtil.SetSize (texture, width * scale, height * scale)
				--PixelUtil.SetSize (texture, width * scale * wscale, height * scale * hscale)
				texture:SetSize (width * scale * wscale, height * scale * hscale)
				texture:SetDesaturated (desaturated)
				texture:SetAlpha (alpha)
				texture:SetVertexColor (overlayColorR, overlayColorG, overlayColorB)
				
				if (i == 1) then
					--PixelUtil.SetPoint (texture, "left", plateFrame.unitFrame.healthBar, "left", -x * scale, y * scale)
					texture:SetPoint ("left", plateFrame.unitFrame.healthBar, "left", -x * scale, y * scale)
					
				elseif (i == 2) then
					--PixelUtil.SetPoint (texture, "right", plateFrame.unitFrame.healthBar, "right", x * scale, -y * scale)
					texture:SetPoint ("right", plateFrame.unitFrame.healthBar, "right", x * scale, y * scale)
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
	
		if plateFrame.unitFrame.isWidgetOnlyMode then
			plateFrame.ActorNameSpecial:Hide()
			plateFrame.ActorTitleSpecial:Hide()
			
			return
		end
		
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
		if (plateFrame.IsSelf) then
		
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
			PixelUtil.SetPoint (plateFrame.ActorNameSpecial, "center", plateFrame.unitFrame, "center", 0, 10)
			
			--format the color if is the same guild, a friend from friends list or color by player class
			if (Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_PLAYER].actorname_use_guild_color and plateFrame.playerGuildName == Plater.PlayerGuildName) then
				--is a guild friend?
				DF:SetFontColor (nameFontString, unpack(Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_PLAYER].actorname_guild_color))
				plateFrame.isFriend = true
				
			elseif (Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_PLAYER].actorname_use_friends_color and Plater.FriendsCache [plateFrame.unitNameInternal]) then
				--is regular friend
				DF:SetFontColor (nameFontString, unpack(Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_PLAYER].actorname_friend_color))
				--DF:SetFontOutline (nameFontString, plateConfigs.actorname_text_shadow)
				Plater.SetFontOutlineAndShadow (nameFontString, plateConfigs.actorname_text_outline, plateConfigs.actorname_text_shadow_color, plateConfigs.actorname_text_shadow_color_offset[1], plateConfigs.actorname_text_shadow_color_offset[2])
				plateFrame.isFriend = true
				
			else
				--isn't friend, check if is showing only the name and if is showing class colors
				if (plateConfigs.actorname_use_class_color) then
					local _, unitClass = UnitClass (plateFrame.unitFrame [MEMBER_UNITID])
					if (unitClass) then
						local color = DB_CLASS_COLORS [unitClass]
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
			
			--hide for good measure as reset
			plateFrame.ActorNameSpecial:Hide()
			plateFrame.ActorTitleSpecial:Hide()
			
			PixelUtil.SetPoint (plateFrame.ActorNameSpecial, "center", plateFrame.unitFrame, "center", 0, 10)
			PixelUtil.SetPoint (plateFrame.ActorTitleSpecial, "top", plateFrame.ActorNameSpecial, "bottom", 0, -2)

			--there's two ways of showing this for friendly npcs (selected from the options panel): show all names or only npcs with profession names
			--enemy npcs always show all
			if (plateConfigs.all_names or (plateFrame.isSoftInteract and Plater.db.profile.show_healthbars_on_softinteract)) then
				if not plateFrame.isObject or (plateFrame.isObject and not Plater.db.profile.hide_name_on_game_objects) then
					plateFrame.ActorNameSpecial:Show()
				else
					plateFrame.ActorNameSpecial:Hide()
				end
				plateFrame.CurrentUnitNameString = plateFrame.ActorNameSpecial
				Plater.UpdateUnitName (plateFrame)
				
				--if this is an enemy or neutral npc
				if (plateFrame [MEMBER_REACTION] <= 4) then
				
					local r, g, b, a
					
					--get the quest color if this npcs is a quest npc
					if (plateFrame [MEMBER_QUEST] and DB_PLATE_CONFIG [plateFrame.unitFrame.ActorType].quest_color_enabled) then
						if (plateFrame [MEMBER_REACTION] == Plater.UnitReaction.UNITREACTION_NEUTRAL) then
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
					if (subTitle and subTitle ~= "") then
						plateFrame.ActorTitleSpecial:Show()
						--subTitle = DF:RemoveRealmName (subTitle) -- why are removing real names on npc titles? e.g. <T-Shirt Scalper> Skin-Me-Own-Coat-Dibblefur gets broken to <T>.
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
					if (subTitle and subTitle ~= "") then
						plateFrame.ActorTitleSpecial:Show()
						--subTitle = DF:RemoveRealmName (subTitle)
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
				
					plateFrame.ActorTitleSpecial:Show()
					--subTitle = DF:RemoveRealmName (subTitle)
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
			
			return
		end
		
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
		
		elseif (Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_PLAYER].actorname_use_friends_color and Plater.FriendsCache [plateFrame.unitNameInternal]) then
			--is regular friend
			DF:SetFontColor (nameString, unpack(Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_PLAYER].actorname_friend_color))
			DF:SetFontColor (guildString, unpack(Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_PLAYER].actorname_friend_color))
			plateFrame.isFriend = true		

		elseif (plateFrame.actorType == ACTORTYPE_FRIENDLY_PLAYER and Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_PLAYER].actorname_use_class_color) then
			--class colors should be used, if possible, because this is enabled
			plateFrame.isFriend = nil
			
			local _, unitClass = UnitClass (plateFrame.unitFrame [MEMBER_UNITID])
			if (unitClass) then
				local color = DB_CLASS_COLORS [unitClass]
				DF:SetFontColor (nameString, color.r, color.g, color.b)
				DF:SetFontColor (guildString, color.r, color.g, color.b)
			else
				DF:SetFontColor (nameString, plateConfigs.actorname_text_color)
				DF:SetFontColor (guildString, plateConfigs.actorname_text_color)
			end
		
		elseif (plateFrame.actorType == ACTORTYPE_ENEMY_PLAYER and Plater.db.profile.plate_config [ACTORTYPE_ENEMY_PLAYER].actorname_use_class_color) then
			--class colors should be used, if possible, because this is enabled
			plateFrame.isFriend = nil
			
			local _, unitClass = UnitClass (plateFrame.unitFrame [MEMBER_UNITID])
			if (unitClass) then
				local color = DB_CLASS_COLORS [unitClass]
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
				Plater.UpdateLevelTextAndColor (levelString, plateFrame.unitFrame [MEMBER_UNITID])
				levelString:SetAlpha (plateConfigs.level_text_alpha)
			else
				Plater.UpdateLevelTextAndColor (levelString, plateFrame.unitFrame [MEMBER_UNITID])
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
			
			Plater.UpdateLifePercentText (plateFrame.unitFrame.healthBar, plateFrame.unitFrame [MEMBER_UNITID], plateConfigs.percent_show_health, plateConfigs.percent_show_percent, plateConfigs.percent_text_show_decimals)
		else
			lifeString:Hide()
		end
		
		--name isn't shown in the personal bar
		if (plateFrame.IsSelf) then
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
			if ((Plater.db.profile.use_player_combat_state and PLAYER_IN_COMBAT or self.unitFrame.InCombat) or plateConfigs.percent_text_ooc) then
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
			local percent = maxHealth == 0 and 100 or (currentHealth / maxHealth * 100)
			
			if (showDecimals) then
				if (percent < 10) then
					healthBar.lifePercent:SetText (Plater.FormatNumber (currentHealth) .. format (" (%.2f%%)", percent))
					
				elseif (percent < 99.9) then
					healthBar.lifePercent:SetText (Plater.FormatNumber (currentHealth) .. format (" (%.1f%%)", percent))
				else
					healthBar.lifePercent:SetText (Plater.FormatNumber (currentHealth) .. " (100%)")
				end
			else
				healthBar.lifePercent:SetText (Plater.FormatNumber (currentHealth) ..  format (" (%d%%)", percent))
			end
			
		elseif (showHealthAmount) then
			healthBar.lifePercent:SetText (Plater.FormatNumber (currentHealth))
		
		elseif (showPercentAmount) then
			local percent = maxHealth == 0 and 100 or (currentHealth / maxHealth * 100)
			
			if (showDecimals) then
				if (percent < 10) then
					healthBar.lifePercent:SetText (format ("%.2f%%", percent))
					
				elseif (percent < 99.9) then
					healthBar.lifePercent:SetText (format ("%.1f%%", percent))
				else
					healthBar.lifePercent:SetText ("100%")
				end
			else
				healthBar.lifePercent:SetText (format ("%d%%", percent))
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
		if (Plater.db.profile.use_player_combat_state and PLAYER_IN_COMBAT or unitFrame.InCombat) then
			if (actorTypeDBConfig.percent_text_enabled) then
				Plater.UpdateLifePercentText (unitFrame.healthBar, unitFrame.unit, actorTypeDBConfig.percent_show_health, actorTypeDBConfig.percent_show_percent, actorTypeDBConfig.percent_text_show_decimals)
			else
				unitFrame.healthBar.lifePercent:Hide()
			end
		else
			--if not in combat, check if can show the percent health out of combat
			if (actorTypeDBConfig.percent_text_enabled and actorTypeDBConfig.percent_text_ooc) then
				Plater.UpdateLifePercentText (unitFrame.healthBar, unitFrame.unit, actorTypeDBConfig.percent_show_health, actorTypeDBConfig.percent_show_percent, actorTypeDBConfig.percent_text_show_decimals)
			else
				unitFrame.healthBar.lifePercent:Hide()
			end
		end
	end
		
	function Plater.UpdateAllNames() --private
		for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
			if (plateFrame.actorType == ACTORTYPE_PLAYER) then
				plateFrame.NameAnchor = 0
				
			elseif (plateFrame.actorType == Plater.UnitReaction.UNITREACTION_FRIENDLY) then
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

	function Plater.UpdateSpellNameSize (nameString, actorType, cutOff, inCombat)
		local spellName = nameString:GetText()
		
		if not spellName or spellName == "" then
			return
		end
		
		local maxLength = Plater.MaxCastBarTextLength or 500
		cutOff = cutOff or 40
		actorType = actorType or "enemynpc"
		
		if (not Plater.db.profile.no_spellname_length_limit) then
			local castKey = Plater.GetHashKey(inCombat)
			if Plater.db.profile.plate_config[actorType][castKey] then
				maxLength = Plater.db.profile.plate_config[actorType][castKey][1] - cutOff
			end
		end
		
		while (nameString:GetStringWidth() > maxLength) do
			spellName = strsub (spellName, 1, #spellName - 1)
			nameString:SetText (spellName)
			if (string.len (spellName) <= 1) then
				break
			end
		end
		
		-- cleanup utf8...
		spellName = DF:CleanTruncateUTF8String(spellName)
		nameString:SetText (spellName)
		
	end

	function Plater.AddGuildNameToPlayerName (plateFrame)
		local currentText = plateFrame.CurrentUnitNameString:GetText()
		if (not currentText:find ("<")) then
			plateFrame.CurrentUnitNameString:SetText (currentText .. "\n" .. "<" .. plateFrame.playerGuildName .. ">")
		end
	end
	
	function Plater.UpdateUnitName (plateFrame)
		local nameString = plateFrame.CurrentUnitNameString

		if ( not (plateFrame.IsFriendlyPlayerWithoutHealthBar or plateFrame.IsNpcWithoutHealthBar) and plateFrame.NameAnchor >= 9) then
			--remove some character from the unit name if the name is placed inside the nameplate
			Plater.UpdateUnitNameTextSize (plateFrame, nameString)
		else
			nameString:SetText (plateFrame [MEMBER_NAME] or plateFrame.unitFrame [MEMBER_NAME] or "")
		end
		
		--check if the player has a guild, this check is done when the nameplate is added
		if (plateFrame.playerGuildName) then
			if (plateFrame.PlateConfig.show_guild_name) then
				Plater.AddGuildNameToPlayerName (plateFrame)
			end
		end
	end

	function Plater.UpdateUnitNameTextSize (plateFrame, nameString, maxWidth)
		local stringSize = maxWidth or max (plateFrame.unitFrame.healthBar:GetWidth() - 6, 44)
		local name = plateFrame [MEMBER_NAME] or plateFrame.unitFrame [MEMBER_NAME] or ""
		
		nameString:SetText (name)
		
		if not name or name == "" then
			return
		end
		
		while (nameString:GetStringWidth() > stringSize) do
			name = strsub (name, 1, #name-1)
			nameString:SetText (name)
			if (string.len (name) <= 1) then
				break
			end
		end
		
		-- cleanup utf8...
		name = DF:CleanTruncateUTF8String(name)
		nameString:SetText (name)
	end

	--updates the level text and the color
	function Plater.UpdateLevelTextAndColor (levelString, unitId)
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

	--units can be rename on the Npc Colors tab, this function run from nameplate_added and UpdatePlateFrame() (usually from UpdateAllPlates() are called)
	function Plater.UpdateNameOnRenamedUnit(plateFrame)
		--set the npc name if the unit has a custom name
		local newNpcName = Plater.db.profile.npcs_renamed[plateFrame[MEMBER_NPCID]]
		local unitFrame = plateFrame.unitFrame
		if (newNpcName) then
			plateFrame [MEMBER_NAME] = newNpcName
			plateFrame [MEMBER_NAMELOWER] = lower (newNpcName)
			unitFrame [MEMBER_NAME] = newNpcName
			unitFrame [MEMBER_NAMELOWER] = plateFrame [MEMBER_NAMELOWER]
			unitFrame.unitName:SetText(newNpcName)
			unitFrame.unitName.isRenamed = true
		else
			if (unitFrame.unitName.isRenamed) then
				newNpcName = UnitName(plateFrame[MEMBER_UNITID])
				plateFrame [MEMBER_NAME] = newNpcName
				plateFrame [MEMBER_NAMELOWER] = lower (newNpcName)
				unitFrame [MEMBER_NAME] = newNpcName
				unitFrame [MEMBER_NAMELOWER] = plateFrame [MEMBER_NAMELOWER]
				unitFrame.unitName:SetText(newNpcName)
				unitFrame.unitName.isRenamed = nil
			end
		end
	end
	
	--Blizzard default font settings
	function Plater.UpdateBlizzardNameplateFonts()
		local profile = Plater.db.profile
		if profile.blizzard_nameplate_font_override_enabled then
			DF:SetFontFace (_G.SystemFont_NamePlate, profile.blizzard_nameplate_font)
			DF:SetFontOutline (_G.SystemFont_NamePlate, profile.blizzard_nameplate_font_outline)
			DF:SetFontSize (_G.SystemFont_NamePlate, profile.blizzard_nameplate_font_size)
			
			DF:SetFontFace (_G.SystemFont_NamePlateFixed, profile.blizzard_nameplate_font)
			DF:SetFontOutline (_G.SystemFont_NamePlateFixed, profile.blizzard_nameplate_font_outline)
			DF:SetFontSize (_G.SystemFont_NamePlateFixed, profile.blizzard_nameplate_font_size)
			
			DF:SetFontFace (_G.SystemFont_LargeNamePlate, profile.blizzard_nameplate_large_font)
			DF:SetFontOutline (_G.SystemFont_LargeNamePlate, profile.blizzard_nameplate_large_font_outline)
			DF:SetFontSize (_G.SystemFont_LargeNamePlate, profile.blizzard_nameplate_large_font_size)
			
			DF:SetFontFace (_G.SystemFont_LargeNamePlateFixed, profile.blizzard_nameplate_large_font)
			DF:SetFontOutline (_G.SystemFont_LargeNamePlateFixed, profile.blizzard_nameplate_large_font_outline)
			DF:SetFontSize (_G.SystemFont_LargeNamePlateFixed, profile.blizzard_nameplate_large_font_size)
		end
	end

	-- ~updateplate ~update ~updatenameplate
	function Plater.UpdatePlateFrame (plateFrame, actorType, forceUpdate, justAdded, regenDisabled)
		Plater.StartLogPerformanceCore("Plater-Core", "Update", "UpdatePlateFrame")
		
		actorType = actorType or plateFrame.actorType
		
		if (not actorType or not plateFrame.unitFrame.PlaterOnScreen) then
			return
		end
		
		local unitFrame = plateFrame.unitFrame
		local healthBar = unitFrame.healthBar
		local castBar = unitFrame.castBar
		local buffFrame = unitFrame.BuffFrame
		local buffFrame2 = unitFrame.BuffFrame2
		local nameFrame = unitFrame.healthBar.unitName
		
		castBar.Settings.FillOnInterrupt = Plater.db.profile.cast_statusbar_spark_filloninterrupt
		castBar.Settings.HideSparkOnInterrupt = Plater.db.profile.cast_statusbar_spark_hideoninterrupt

		plateFrame.actorType = actorType
		unitFrame.actorType = actorType
		unitFrame.ActorType = actorType --exposed to scripts
		
		local shouldForceRefresh = justAdded or forceUpdate
		if (plateFrame.IsNpcWithoutHealthBar or plateFrame.IsFriendlyPlayerWithoutHealthBar) then
			shouldForceRefresh = true
			
		end

		healthBar.BorderIsAggroIndicator = nil
		
		local wasQuestPlate = plateFrame [MEMBER_QUEST]
		plateFrame [MEMBER_QUEST] = false
		unitFrame [MEMBER_QUEST] = false
		plateFrame.QuestInfo = {}
		unitFrame.QuestInfo = {}
		
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
			if (isQuestMob and DB_PLATE_CONFIG [actorType].quest_color_enabled and not Plater.IsUnitTapDenied (plateFrame.unitFrame.unit)) then
				if (plateFrame [MEMBER_REACTION] == Plater.UnitReaction.UNITREACTION_NEUTRAL) then
					Plater.ChangeHealthBarColor_Internal (healthBar, unpack (DB_PLATE_CONFIG [actorType].quest_color_neutral))
					
				else
					Plater.ChangeHealthBarColor_Internal (healthBar, unpack (DB_PLATE_CONFIG [actorType].quest_color_enemy))
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
			plateFrame.IsFriendlyPlayerWithoutHealthBar = false
			
			local subTitleExists = false
			local subTitle = Plater.GetActorSubName (plateFrame)
			if (subTitle and subTitle ~= "" and not Plater.IsNpcInIgnoreList (plateFrame, true)) then
				subTitleExists = true
			end
		
			Plater.ForceFindPetOwner (plateFrame [MEMBER_GUID])
		
			-- handle own pets separately, including nazjatar guardians
			if (Plater.PlayerPetCache [unitFrame [MEMBER_GUID]] and not plateFrame.isBattlePet) then
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
					plateFrame.IsNpcWithoutHealthBar = false
				end
			
			elseif (DB_PLATE_CONFIG [actorType].follow_blizzard_npc_option and not (unitFrame.isSoftInteract or plateFrame [MEMBER_TARGET]) and not UnitShouldDisplayName(plateFrame [MEMBER_UNITID])) then
				-- hide if following blizzard naming
				healthBar:Hide()
				buffFrame:Hide()
				buffFrame2:Hide()
				nameFrame:Hide()
				plateFrame.IsNpcWithoutHealthBar = false
				
			elseif (IS_IN_OPEN_WORLD and DB_PLATE_CONFIG [actorType].quest_enabled and Plater.IsQuestObjective (plateFrame)) then
				if (DB_PLATE_CONFIG [actorType].quest_color_enabled) then
					Plater.ChangeHealthBarColor_Internal (healthBar, unpack (DB_PLATE_CONFIG [actorType].quest_color))
				end

				healthBar:Show()
				buffFrame:Show()
				buffFrame2:Show()
				nameFrame:Show()
				plateFrame.IsNpcWithoutHealthBar = false
				
				--these twoseettings make the healthing dummy show the healthbar
				--				Plater.db.profile.plate_config.friendlynpc.only_names = false
				--				Plater.db.profile.plate_config.friendlynpc.all_names = false
			
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
				buffFrame2:Hide()
				nameFrame:Hide()
				plateFrame.IsNpcWithoutHealthBar = true
			
			else
				healthBar:Show()
				buffFrame:Show()
				buffFrame2:Show()
				nameFrame:Show()
				plateFrame.IsNpcWithoutHealthBar = false
			end

		elseif (actorType == ACTORTYPE_FRIENDLY_PLAYER) then
			plateFrame.IsNpcWithoutHealthBar = false
			Plater.ParseHealthSettingForPlayer (plateFrame, justAdded)
			
				--change the player health bar color to either class color or users choice
			if (not Plater.db.profile.use_playerclass_color) then
				Plater.ChangeHealthBarColor_Internal (healthBar, unpack(DB_PLATE_CONFIG [actorType].fixed_class_color))
			else
				local _, class = UnitClass (unitFrame [MEMBER_UNITID])
				if (class) then		
					local color = DB_CLASS_COLORS [class]
					Plater.ChangeHealthBarColor_Internal (healthBar, color.r, color.g, color.b, color.a)
				else
					Plater.ChangeHealthBarColor_Internal (healthBar, 1, 1, 1, 1)
				end
			end
			
		elseif (actorType == ACTORTYPE_ENEMY_PLAYER) then
			plateFrame.IsNpcWithoutHealthBar = false
			
			if (plateFrame.PlayerCannotAttack and not DB_SHOW_HEALTHBARS_FOR_NOT_ATTACKABLE) then
				healthBar:Hide()
				buffFrame:Hide()
				buffFrame2:Hide()
				nameFrame:Hide()
				plateFrame.IsFriendlyPlayerWithoutHealthBar = true
				
			else
				healthBar:Show()
				buffFrame:Show()
				buffFrame2:Show()
				nameFrame:Show()
				plateFrame.IsFriendlyPlayerWithoutHealthBar = false
				
				if (DB_PLATE_CONFIG [actorType].use_playerclass_color) then
					local _, class = UnitClass (unitFrame [MEMBER_UNITID])
					if (class) then		
						local color = DB_CLASS_COLORS [class]
						Plater.ChangeHealthBarColor_Internal (healthBar, color.r, color.g, color.b, color.a)
					else
						Plater.ChangeHealthBarColor_Internal (healthBar, unpack (DB_PLATE_CONFIG [actorType].fixed_class_color))
					end
				else
					Plater.ChangeHealthBarColor_Internal (healthBar, unpack (DB_PLATE_CONFIG [actorType].fixed_class_color))
				end
			end
			
		else --> ENEMY NPC pass throught here
			plateFrame.IsFriendlyPlayerWithoutHealthBar = false
			
			--check if this is an enemy npc but the player cannot attack it
			if (plateFrame.PlayerCannotAttack and not DB_SHOW_HEALTHBARS_FOR_NOT_ATTACKABLE and not unitFrame.IsSelf) or unitFrame.isSoftInteractObject then
				healthBar:Hide()
				buffFrame:Hide()
				buffFrame2:Hide()
				nameFrame:Hide()
				plateFrame.IsNpcWithoutHealthBar = true
				
			else
				healthBar:Show()
				buffFrame:Show()
				buffFrame2:Show()
				plateFrame.IsNpcWithoutHealthBar = false
				
				if unitFrame.IsSelf then
					--refresh color
					if (plateFrame.PlateConfig.healthbar_color_by_hp) then
						local currentHealth = healthBar.currentHealth
						local currentHealthMax = healthBar.currentHealthMax
						local originalColor = plateFrame.PlateConfig.healthbar_color
						local r, g, b = DF:LerpLinearColor (abs (currentHealth / currentHealthMax - 1), 1, originalColor[1], originalColor[2], originalColor[3], 1, .4, 0)
						Plater.ChangeHealthBarColor_Internal (healthBar, r, g, b, (originalColor[4] or 1), true)
					else
						Plater.ChangeHealthBarColor_Internal (healthBar, unpack (DB_PLATE_CONFIG [actorType].healthbar_color))
					end
				else
					nameFrame:Show()
					-- could be a pet
					Plater.ForceFindPetOwner (plateFrame [MEMBER_GUID])
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
				plateFrame.unitFrame:SetBackdrop (nil)
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
			colors.Channeling:SetColor (profile.cast_statusbar_color_channeling)
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

			castBar.castColorTexture:Hide()
			if (profile.cast_color_settings.enabled) then
				castBar.castColorTexture:SetWidth(profile.cast_color_settings.width)
				castBar.castColorTexture:SetAlpha(profile.cast_color_settings.alpha)
				castBar.castColorTexture:SetDrawLayer(profile.cast_color_settings.layer, -6)
				Plater.SetAnchor(castBar.castColorTexture, profile.cast_color_settings.anchor)
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
			unitFrame.targetOverlayTexture:SetVertexColor (unpack (Plater.db.profile.health_selection_overlay_color))
			unitFrame.targetOverlayTexture:SetAlpha (profile.health_selection_overlay_alpha)
			
			--heal prediction
			unitFrame.healthBar.Settings.ShowHealingPrediction = Plater.db.profile.show_health_prediction
			unitFrame.healthBar.Settings.ShowShields = Plater.db.profile.show_shield_prediction
			if (unitFrame.healthBar.unit) then
				unitFrame.healthBar:UNIT_HEALTH()
			end
			
			if IS_WOW_PROJECT_MAINLINE and unitFrame.WidgetContainer then
				Plater.SetAnchor (unitFrame.WidgetContainer, profile.widget_bar_anchor, unitFrame)
				plateFrame.unitFrame.WidgetContainer:SetScale(Plater.db.profile.widget_bar_scale)
			end
		end
		
		--update the plate size for this unit
		Plater.UpdatePlateSize (plateFrame)
		
		--raid marker
		Plater.UpdatePlateRaidMarker (plateFrame)
		
		--indicators for the unit
		Plater.UpdateIndicators (plateFrame, actorType, regenDisabled)
		
		--update the visibility of the health text
		Plater.UpdateLifePercentVisibility (plateFrame)
		--update the health text
		Plater.CheckLifePercentText (unitFrame)
		
		--target indicator
		Plater.UpdateTarget (plateFrame)
		
		--personal player bar
		if (plateFrame.IsSelf) then
			Plater.UpdatePersonalBar (NamePlateDriverFrame)
			if (not DB_PLATE_CONFIG [actorType].healthbar_color_by_hp) then
				Plater.ChangeHealthBarColor_Internal (healthBar, unpack (DB_PLATE_CONFIG [actorType].healthbar_color))
			end
		end
		
		Plater.UpdateCustomDesign (unitFrame)

		Plater.UpdateNameOnRenamedUnit(plateFrame)

		--update options in the extra icons row frame
		if (unitFrame.ExtraIconFrame.RefreshID < PLATER_REFRESH_ID) then
			Plater.SetAnchor (unitFrame.ExtraIconFrame, Plater.db.profile.extra_icon_anchor)
			unitFrame.ExtraIconFrame:SetOption ("anchor", Plater.db.profile.extra_icon_anchor)
			unitFrame.ExtraIconFrame:SetOption ("show_text", Plater.db.profile.extra_icon_show_timer)
			unitFrame.ExtraIconFrame:SetOption ("text_font", Plater.db.profile.extra_icon_timer_font)
			unitFrame.ExtraIconFrame:SetOption ("text_size", Plater.db.profile.extra_icon_timer_size)
			unitFrame.ExtraIconFrame:SetOption ("text_outline", Plater.db.profile.extra_icon_timer_outline)
			unitFrame.ExtraIconFrame:SetOption ("grow_direction", unitFrame.ExtraIconFrame:GetIconGrowDirection())
			unitFrame.ExtraIconFrame:SetOption ("icon_width", Plater.db.profile.extra_icon_width)
			unitFrame.ExtraIconFrame:SetOption ("icon_height", Plater.db.profile.extra_icon_height)
			unitFrame.ExtraIconFrame:SetOption ("texcoord", Plater.db.profile.extra_icon_wide_icon and Plater.WideIconCoords or Plater.BorderLessIconCoords)
			unitFrame.ExtraIconFrame:SetOption ("desc_text", Plater.db.profile.extra_icon_caster_name)
			unitFrame.ExtraIconFrame:SetOption ("desc_text_font", Plater.db.profile.extra_icon_caster_font)
			unitFrame.ExtraIconFrame:SetOption ("desc_text_size", Plater.db.profile.extra_icon_caster_size)
			unitFrame.ExtraIconFrame:SetOption ("desc_text_outline", Plater.db.profile.extra_icon_caster_outline)
			unitFrame.ExtraIconFrame:SetOption ("stack_text", Plater.db.profile.extra_icon_show_stacks)
			unitFrame.ExtraIconFrame:SetOption ("stack_text_font", Plater.db.profile.extra_icon_stack_font)
			unitFrame.ExtraIconFrame:SetOption ("stack_text_size", Plater.db.profile.extra_icon_stack_size)
			unitFrame.ExtraIconFrame:SetOption ("stack_text_outline", Plater.db.profile.extra_icon_stack_outline)
			unitFrame.ExtraIconFrame:SetOption ("surpress_tulla_omni_cc", Plater.db.profile.disable_omnicc_on_auras)
			unitFrame.ExtraIconFrame:SetOption ("surpress_blizzard_cd_timer", true)
			unitFrame.ExtraIconFrame:SetOption ("decimal_timer", Plater.db.profile.extra_icon_timer_decimals)
			unitFrame.ExtraIconFrame:SetOption ("cooldown_reverse", Plater.db.profile.extra_icon_cooldown_reverse)
			unitFrame.ExtraIconFrame:SetOption ("cooldown_swipe_enabled", Plater.db.profile.extra_icon_show_swipe)
			unitFrame.ExtraIconFrame:SetOption ("cooldown_edge_texture", Plater.db.profile.extra_icon_cooldown_edge_texture)
			
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
		
		Plater.EndLogPerformanceCore("Plater-Core", "Update", "UpdatePlateFrame")
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

		if (index and not plateFrame.IsSelf) then
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
			if plateFrame.unitFrame.PlaterOnScreen then
				Plater.UpdatePlateRaidMarker (plateFrame)
				
				--hooks
				if (HOOK_RAID_TARGET.ScriptAmount > 0) then
					for i = 1, HOOK_RAID_TARGET.ScriptAmount do
						local globalScriptObject = HOOK_RAID_TARGET [i]
						local unitFrame = plateFrame.unitFrame
						local scriptContainer = unitFrame:ScriptGetContainer()
						local scriptInfo = unitFrame:HookGetInfo(globalScriptObject, scriptContainer, "Raid Target")
						--run
						unitFrame:ScriptRunHook (scriptInfo, "Raid Target")
					end
				end
			end
		end
	end

	-- ~indicators
	function Plater.UpdateIndicators (plateFrame, actorType, regenDisabled)
		--limpa os indicadores
		Plater.ClearIndicators (plateFrame)
		local config = Plater.db.profile
		
		if (actorType == ACTORTYPE_ENEMY_PLAYER) then
			if (config.indicator_faction) then
				--don't show faction icon on arena of battleground, it's kinda useless (terciob july 2022)
				if (Plater.ZoneInstanceType ~= "pvp" and Plater.ZoneInstanceType ~= "arena") then
					Plater.AddIndicator (plateFrame, UnitFactionGroup (plateFrame.unitFrame [MEMBER_UNITID]))
				end
			end

			if (config.indicator_enemyclass) then
				Plater.AddIndicator (plateFrame, "classicon")
			end

			--don't show spec icon during combat, it occupies a valuable space (terciob july 2022)
			if (config.indicator_spec and (config.indicator_spec_always or (not InCombatLockdown() and not regenDisabled))) then
				-- use BG info if available
				local texture, L, R, T, B = Plater.GetSpecIconForUnitFromBG(plateFrame.unitFrame [MEMBER_UNITID])
				if texture then
					Plater.AddIndicator (plateFrame, "specicon", texture, L, R, T, B)
				else
					--> check if the user is using details
					if (Details and Details.realversion >= 134) then
						local spec = Details:GetSpecByGUID (plateFrame [MEMBER_GUID])
						if (spec) then
							local texture, L, R, T, B = Details:GetSpecIcon (spec)
							Plater.AddIndicator (plateFrame, "specicon", texture, L, R, T, B)
						end
					end
				end
			end
		
		elseif (actorType == ACTORTYPE_FRIENDLY_PLAYER) then
			if (config.indicator_friendlyfaction) then
				Plater.AddIndicator (plateFrame, UnitFactionGroup (plateFrame.unitFrame [MEMBER_UNITID]))
			end
			if (config.indicator_friendlyclass) then
				Plater.AddIndicator (plateFrame, "classicon")
			end
			if (config.indicator_friendlyspec) then
				-- use BG info if available
				local texture, L, R, T, B = Plater.GetSpecIconForUnitFromBG(plateFrame [MEMBER_UNITID])
				if texture then
					Plater.AddIndicator (plateFrame, "specicon", texture, L, R, T, B)
				else
					--> check if the user is using details
					if (Details and Details.realversion >= 134) then
						local spec = Details:GetSpecByGUID (plateFrame [MEMBER_GUID])
						if (spec) then
							local texture, L, R, T, B = Details:GetSpecIcon (spec)
							Plater.AddIndicator (plateFrame, "specicon", texture, L, R, T, B)
						end
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
			if (unitClassification == "worldboss" and config.indicator_worldboss) then
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
			local isQuestBoss = (IS_WOW_PROJECT_MAINLINE) and UnitIsQuestBoss (plateFrame.unitFrame [MEMBER_UNITID]) or false --true false
			if (isQuestBoss and config.indicator_quest) then
				Plater.AddIndicator (plateFrame, "quest")
			end
		
		elseif (actorType == ACTORTYPE_FRIENDLY_NPC and config.indicator_quest) then
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
			newIndicator:SetDrawLayer("OVERLAY", 7)
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
	function Plater.RefreshAutoToggle(combat, leavingCombat) --private

		if Plater.HasRefreshAutoToggleScheduled and combat == nil then
			return
		elseif leavingCombat then
			if Plater.HasRefreshAutoToggleScheduled then
				Plater.HasRefreshAutoToggleScheduled:Cancel()
			end
			
			Plater.HasRefreshAutoToggleScheduled = C_Timer.NewTimer (1.5, function()
					Plater.HasRefreshAutoToggleScheduled = nil
					Plater.RefreshAutoToggle(false) 
				end) --schedule
			return
			
		elseif not leavingCombat and Plater.HasRefreshAutoToggleScheduled then
			if combat then
				Plater.HasRefreshAutoToggleScheduled:Cancel()
				Plater.HasRefreshAutoToggleScheduled = nil
			else
				return
			end
		end
		
		if ((combat == nil) and InCombatLockdown()) then
			C_Timer.After (0.5, function() Plater.RefreshAutoToggle() end)
			return
		end
		
		local zoneName, zoneType = GetInstanceInfo()
		local profile = Plater.db.profile
		
		-- combat toggle
		if (profile.auto_toggle_combat_enabled and (combat ~= nil)) then
			local onlyNamesEnabled = GetCVarBool("nameplateShowOnlyNames")
			local onlyNamesEnabledRaw = GetCVar("nameplateShowOnlyNames")
			
			--NamePlateDriverFrame:UnregisterEvent("CVAR_UPDATE")
			if combat or InCombatLockdown() then -- update this separately and only if needed
				if onlyNamesEnabled ~= profile.auto_toggle_combat.blizz_healthbar_ic then
					SetCVar("nameplateShowOnlyNames", profile.auto_toggle_combat.blizz_healthbar_ic and CVAR_ENABLED or CVAR_DISABLED)
					Plater.UpdateBaseNameplateOptions()
				end
			else
				if onlyNamesEnabled ~= profile.auto_toggle_combat.blizz_healthbar_ooc then
					SetCVar("nameplateShowOnlyNames", profile.auto_toggle_combat.blizz_healthbar_ooc and CVAR_ENABLED or CVAR_DISABLED)
					--Plater.UpdateBaseNameplateOptions()
				end
			end
			--NamePlateDriverFrame:RegisterEvent("CVAR_UPDATE")
			
			if combat then
				SetCVar("nameplateShowFriends", profile.auto_toggle_combat.friendly_ic and CVAR_ENABLED or CVAR_DISABLED)
				SetCVar("nameplateShowEnemies", profile.auto_toggle_combat.enemy_ic and CVAR_ENABLED or CVAR_DISABLED)
				return
			else
				SetCVar("nameplateShowFriends", profile.auto_toggle_combat.friendly_ooc and CVAR_ENABLED or CVAR_DISABLED)
				SetCVar("nameplateShowEnemies", profile.auto_toggle_combat.enemy_ooc and CVAR_ENABLED or CVAR_DISABLED)
			end
		end

		-- dungeon/raid toggle pets/totems
		if not combat then -- just do this out of combat to counter some weird errors
			if (profile.auto_inside_raid_dungeon.hide_enemy_player_pets) then
				local showEnemyPets = GetCVarBool("nameplateShowEnemyPets")
				if (zoneType == "party" or zoneType == "raid") then
					if showEnemyPets ~= CVAR_DISABLED then
						SetCVar("nameplateShowEnemyPets", CVAR_DISABLED)
					end
				else
					if showEnemyPets ~= CVAR_ENABLED then
						SetCVar("nameplateShowEnemyPets", CVAR_ENABLED)
					end
				end
			end
			if (profile.auto_inside_raid_dungeon.hide_enemy_player_totems) then
				local showEnemyTotems = GetCVarBool("nameplateShowEnemyTotems")
				if (zoneType == "party" or zoneType == "raid") then
					if showEnemyTotems ~= CVAR_DISABLED then
						SetCVar("nameplateShowEnemyTotems", CVAR_DISABLED)
					end
				else
					if showEnemyTotems ~= CVAR_ENABLED then
						SetCVar("nameplateShowEnemyTotems", CVAR_ENABLED)
					end
				end
			end
		end
		
		--stacking toggle
		if (profile.auto_toggle_stacking_enabled and profile.stacking_nameplates_enabled) then
			--discover which is the map type the player is in
			if (zoneType == "party") then
				SetCVar ("nameplateMotion", profile.auto_toggle_stacking ["party"] and CVAR_ENABLED or CVAR_DISABLED)
				
			elseif (zoneType == "raid") then
				SetCVar ("nameplateMotion", profile.auto_toggle_stacking ["raid"] and CVAR_ENABLED or CVAR_DISABLED)
				
			elseif (zoneType == "arena" or zoneType == "pvp") then
				SetCVar ("nameplateMotion", profile.auto_toggle_stacking ["arena"] and CVAR_ENABLED or CVAR_DISABLED)
				
			else
				--if the player is resting, consider inside a major city
				if (IsResting()) then
					SetCVar ("nameplateMotion", profile.auto_toggle_stacking ["cities"] and CVAR_ENABLED or CVAR_DISABLED)
				else
					SetCVar ("nameplateMotion", profile.auto_toggle_stacking ["world"] and CVAR_ENABLED or CVAR_DISABLED)
				end
			end
		end
		
		if combat then return end

		--friendly nameplate toggle
		if (profile.auto_toggle_friendly_enabled) then
			--discover which is the map type the player is in
			if (zoneType == "party") then
				SetCVar ("nameplateShowFriends", profile.auto_toggle_friendly ["party"] and CVAR_ENABLED or CVAR_DISABLED)
				
			elseif (zoneType == "raid") then
				SetCVar ("nameplateShowFriends", profile.auto_toggle_friendly ["raid"] and CVAR_ENABLED or CVAR_DISABLED)
				
			elseif (zoneType == "arena" or zoneType == "pvp") then
				SetCVar ("nameplateShowFriends", profile.auto_toggle_friendly ["arena"] and CVAR_ENABLED or CVAR_DISABLED)
				
			else
				--if the player is resting, consider inside a major city
				if (IsResting()) then
					SetCVar ("nameplateShowFriends", profile.auto_toggle_friendly ["cities"] and CVAR_ENABLED or CVAR_DISABLED)
				else
					SetCVar ("nameplateShowFriends", profile.auto_toggle_friendly ["world"] and CVAR_ENABLED or CVAR_DISABLED)
				end
			end
		end
		
		--enemy nameplate toggle
		if (profile.auto_toggle_enemy_enabled) then
			--discover which is the map type the player is in
			if (zoneType == "party") then
				SetCVar ("nameplateShowEnemies", profile.auto_toggle_enemy ["party"] and CVAR_ENABLED or CVAR_DISABLED)
				
			elseif (zoneType == "raid") then
				SetCVar ("nameplateShowEnemies", profile.auto_toggle_enemy ["raid"] and CVAR_ENABLED or CVAR_DISABLED)
				
			elseif (zoneType == "arena" or zoneType == "pvp") then
				SetCVar ("nameplateShowEnemies", profile.auto_toggle_enemy ["arena"] and CVAR_ENABLED or CVAR_DISABLED)
				
			else
				--if the player is resting, consider inside a major city
				if (IsResting()) then
					SetCVar ("nameplateShowEnemies", profile.auto_toggle_enemy ["cities"] and CVAR_ENABLED or CVAR_DISABLED)
				else
					SetCVar ("nameplateShowEnemies", profile.auto_toggle_enemy ["world"] and CVAR_ENABLED or CVAR_DISABLED)
				end
			end
		end
	end

	local anchor_functions = {
		function (widget, config, attachTo, centered)--1 topleft
			widget:ClearAllPoints()
			local widgetRelative = centered and "bottom" or "bottomleft"
			PixelUtil.SetPoint (widget, widgetRelative, attachTo, "topleft", config.x, config.y, 0, 0)
		end,
		function (widget, config, attachTo, centered)--2 left
			widget:ClearAllPoints()
			local widgetRelative = centered and "center" or "right"
			PixelUtil.SetPoint (widget, widgetRelative, attachTo, "left", config.x, config.y, 0, 0)
		end,
		function (widget, config, attachTo, centered)--3 bottomleft
			widget:ClearAllPoints()
			local widgetRelative = centered and "top" or "topleft"
			PixelUtil.SetPoint (widget, widgetRelative, attachTo, "bottomleft", config.x, config.y, 0, 0)
		end,
		function (widget, config, attachTo, centered)--4 bottom
			widget:ClearAllPoints()
			PixelUtil.SetPoint (widget, "top", attachTo, "bottom", config.x, config.y, 0, 0)
		end,
		function (widget, config, attachTo, centered)--5 bottomright
			widget:ClearAllPoints()
			local widgetRelative = centered and "top" or "topright"
			PixelUtil.SetPoint (widget, widgetRelative, attachTo, "bottomright", config.x, config.y, 0, 0)
		end,
		function (widget, config, attachTo, centered)--6 right
			widget:ClearAllPoints()
			local widgetRelative = centered and "center" or "left"
			PixelUtil.SetPoint (widget, widgetRelative, attachTo, "right", config.x, config.y, 0, 0)
		end,
		function (widget, config, attachTo, centered)--7 topright
			widget:ClearAllPoints()
			local widgetRelative = centered and "bottom" or "bottomright"
			PixelUtil.SetPoint (widget, widgetRelative, attachTo, "topright", config.x, config.y, 0, 0)
		end,
		function (widget, config, attachTo, centered)--8 top
			widget:ClearAllPoints()
			PixelUtil.SetPoint (widget, "bottom", attachTo, "top", config.x, config.y, 0, 0)
		end,
		function (widget, config, attachTo, centered)--9 center
			widget:ClearAllPoints()
			PixelUtil.SetPoint (widget, "center", attachTo, "center", config.x, config.y, 0, 0)
		end,
		function (widget, config, attachTo, centered)--10 inner left
			widget:ClearAllPoints()
			PixelUtil.SetPoint (widget, "left", attachTo, "left", config.x, config.y, 0, 0)
		end,
		function (widget, config, attachTo, centered)--11 inner right
			widget:ClearAllPoints()
			PixelUtil.SetPoint (widget, "right", attachTo, "right", config.x, config.y, 0, 0)
		end,
		function (widget, config, attachTo, centered)--12 inner top
			widget:ClearAllPoints()
			PixelUtil.SetPoint (widget, "top", attachTo, "top", config.x, config.y, 0, 0)
		end,
		function (widget, config, attachTo, centered)--13 inner bottom
			widget:ClearAllPoints()
			PixelUtil.SetPoint (widget, "bottom", attachTo, "bottom", config.x, config.y, 0, 0)
		end
	}

	--auto set the point based on the table from the config, if attachTo isn't received, it'll use its parent
	function Plater.SetAnchor (widget, config, attachTo, centered) --private
		attachTo = attachTo or widget:GetParent()
		anchor_functions [config.side] (widget, config, attachTo, centered)
	end
	
	-- anchor sides as comprehensive table.
	Plater.AnchorSides = {
        TOP_LEFT = 1,
        LEFT = 2,
        BOTTOM_LEFT = 3,
        BOTTOM = 4,
        BOTTOM_RIGHT = 5,
        RIGHT = 6,
        TOP_RIGHT = 7,
        TOP = 8,
        CENTER = 9,
        INNER_LEFT = 10,
        INNER_RIGHT = 11,
        INNER_TOP = 12,
        INNER_BOTTOM = 13,
    }

	--check the setting 'only_damaged' and 'only_thename' for player characters. not critical code, can run slow
	function Plater.ParseHealthSettingForPlayer (plateFrame, force) --private
		local isFriendlyPlayerWithoutHealthBar = plateFrame.IsFriendlyPlayerWithoutHealthBar
		if (DB_PLATE_CONFIG [ACTORTYPE_FRIENDLY_PLAYER].only_thename and not DB_PLATE_CONFIG [ACTORTYPE_FRIENDLY_PLAYER].only_damaged) then
			if (not isFriendlyPlayerWithoutHealthBar) or force then
				Plater.HideHealthBar (plateFrame.unitFrame, true)
			end
			
		elseif (DB_PLATE_CONFIG [ACTORTYPE_FRIENDLY_PLAYER].only_damaged) then
			local healthBar = plateFrame.unitFrame.healthBar
			if ((healthBar.currentHealth or 1) < (healthBar.currentHealthMax or 1)) then
				if isFriendlyPlayerWithoutHealthBar or force then
					Plater.ShowHealthBar (plateFrame.unitFrame)
				end
				
			elseif (not isFriendlyPlayerWithoutHealthBar) or force then
				Plater.HideHealthBar (plateFrame.unitFrame, true)
			end
			
		elseif isFriendlyPlayerWithoutHealthBar or force then
			Plater.ShowHealthBar (plateFrame.unitFrame)
		end
	end

	function Plater.GetPlateAlpha (plateFrame)
		return plateFrame and plateFrame.unitFrame and plateFrame.unitFrame:GetAlpha() or -1
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
		local highlightOverlay = CreateFrame ("frame", "$parentHighlightOverlay", plateFrame.unitFrame.healthBar, BackdropTemplateMixin and "BackdropTemplate") --why this was parented to UIParent (question mark)
		highlightOverlay:EnableMouse (false)
		highlightOverlay:SetAllPoints()
		highlightOverlay:SetScript ("OnUpdate", Plater.CheckHighlight)
		highlightOverlay:Hide()
		--highlightOverlay:SetFrameStrata ("TOOLTIP") --it'll use the same strata as the health bar now
		
		highlightOverlay.HighlightTexture = plateFrame.unitFrame.healthBar:CreateTexture (nil, "overlay")
		highlightOverlay.HighlightTexture:SetAllPoints()
		highlightOverlay.HighlightTexture:SetColorTexture (1, 1, 1, 1)
		highlightOverlay.HighlightTexture:SetAlpha (1)
		highlightOverlay.HighlightTexture:Hide()
		
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
		local f_anim = CreateFrame ("frame", nil, plateFrame.unitFrame.healthBar, BackdropTemplateMixin and "BackdropTemplate")
		f_anim:SetFrameLevel (plateFrame.unitFrame.healthBar:GetFrameLevel()-1)
		f_anim:SetPoint ("topleft", plateFrame.unitFrame.healthBar, "topleft", -2, 2)
		f_anim:SetPoint ("bottomright", plateFrame.unitFrame.healthBar, "bottomright", 2, -2)
		plateFrame.unitFrame.healthBar.canHealthFlash = true
		
		local t = f_anim:CreateTexture (nil, "artwork")
		t:SetColorTexture (1, 1, 1, 1)
		t:SetAllPoints()
		t:SetBlendMode ("ADD")
		f_anim.texture = t
		
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
		f_anim.animation = animation

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
		plateFrame.unitFrame.healthBar.HealthFlashFrame = f_anim
		plateFrame.unitFrame.healthBar.PlayHealthFlash = do_flash_anim
	end

	function Plater.CreateAggroFlashFrame (plateFrame) --private

		local f_anim = CreateFrame ("frame", nil, plateFrame.unitFrame.healthBar, BackdropTemplateMixin and "BackdropTemplate")
		--local f_anim = CreateFrame ("frame", nil, plateFrame, BackdropTemplateMixin and "BackdropTemplate")
		f_anim:SetFrameLevel (plateFrame.unitFrame.healthBar:GetFrameLevel()+3)
		f_anim:SetPoint ("topleft", plateFrame.unitFrame.healthBar, "topleft")
		f_anim:SetPoint ("bottomright", plateFrame.unitFrame.healthBar, "bottomright")
		
		local t = f_anim:CreateTexture (nil, "artwork")
		--t:SetTexCoord (0, 0.78125, 0, 0.66796875)
		--t:SetTexture ([[Interface\AchievementFrame\UI-Achievement-Alert-Glow]])
		t:SetColorTexture (1, 1, 1, 1)
		t:SetAllPoints()
		t:SetBlendMode ("ADD")
		f_anim.texture = t
		local s = f_anim:CreateFontString (nil, "overlay", "GameFontNormal")
		s:SetText ("-AGGRO-")
		s:SetTextColor (.70, .70, .70)
		s:SetPoint ("center", t, "center")
		f_anim.text = s
		
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
		f_anim.animation = animation
		
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
		plateFrame.unitFrame.BodyFlashFrame = f_anim
		plateFrame.PlayBodyFlash = do_flash_anim
	end	
	

	--> animation with acceleration ~animation ~healthbaranimation
	function Plater.AnimateLeftWithAccel (self, deltaTime)
		local distance = (self.AnimationStart - self.AnimationEnd) / self.CurrentHealthMax * 100	--scale 1 - 100
		local minTravel = min (distance / 10, 3) -- 10 = trigger distance to max speed 3 = speed scale on max travel
		local maxTravel = max (minTravel, 0.45) -- 0.45 = min scale speed on low travel speed
		local calcAnimationSpeed = (self.CurrentHealthMax * (deltaTime * DB_ANIMATION_TIME_DILATATION)) * maxTravel --re-scale back to unit health, scale with delta time and scale with the travel speed
		
		self.AnimationStart = self.CurrentHealthMax == 0 and 1 or self.AnimationStart - calcAnimationSpeed
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
		local minTravel = min (distance / 10, 3) -- 10 = trigger distance to max speed 3 = speed scale on max travel
		local maxTravel = max (minTravel, 0.45) -- 0.45 = min scale speed on low travel speed
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
		Plater.StartLogPerformanceCore("Plater-Core", "Update", "DoNameplateAnimation")
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
					local scaleDownX, scaleDownY = animationTable.scale_downX, animationTable.scale_downY;
					
					(animationHub.ScaleUp.SetFromScale or animationHub.ScaleUp.SetScaleFrom) (animationHub.ScaleUp, 1, 1);
					(animationHub.ScaleUp.SetToScale or animationHub.ScaleUp.SetScaleTo) (animationHub.ScaleUp, scaleUpX, scaleUpY);
					(animationHub.ScaleDown.SetFromScale or animationHub.ScaleDown.SetScaleFrom) (animationHub.ScaleDown, 1, 1);
					(animationHub.ScaleDown.SetToScale or animationHub.ScaleDown.SetScaleTo) (animationHub.ScaleDown, scaleDownX, scaleDownY)
					
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
		Plater.EndLogPerformanceCore("Plater-Core", "Update", "DoNameplateAnimation")
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
	
	function Plater.UpdateMaxCastbarTextLength(newGlobalSize)
		Plater.MaxCastBarTextLength = newGlobalSize
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
		if (plateFrame ["namePlateClassification"] == "minus") then
			return "minus"
			
		elseif (PET_CACHE [plateFrame [MEMBER_GUID]]) then
			return "pet"
			
		end
		
		return "normal"
	end
	
	--returns isPet, isPlayerPet, PET_CACHE-entry (if existing)
	function Plater.IsUnitPet (unitFrame) 
		if not unitFrame then return false, false, nil end
		local entry = PET_CACHE [unitFrame.PlateFrame [MEMBER_GUID]]
		if (entry) then
			return true, Plater.PlayerPetCache [unitFrame.PlateFrame [MEMBER_GUID]] and true or false, entry
		end
		return false, false, nil
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
	
	-- tanslate the npc cache entries if needed, do so. can translate names only, but not zones.
	function Plater.TranslateNPCCache()
		if not Plater.db.profile.auto_translate_npc_names then return end
		if Plater.TranslateNPCCacheIsRunning then return end
		Plater.TranslateNPCCacheIsRunning = true
		local maxPerFrame = 10
		local translateTimer = 0.1
		
		local function GetCreatureNameFromID(npcID)
			if C_TooltipInfo then
				local info = C_TooltipInfo.GetHyperlink(("unit:Creature-0-0-0-0-%d"):format(npcID))
				local leftText = info and info.lines and info.lines[1] and info.lines[1].leftText
				if leftText and leftText ~= _G.UNKNOWN then
					return leftText
				end
			else
				local tooltipFrame = GetCreatureNameFromIDFinderTooltip or CreateFrame ("GameTooltip", "GetCreatureNameFromIDFinderTooltip", nil, "GameTooltipTemplate")
				tooltipFrame:SetOwner (WorldFrame, "ANCHOR_NONE")
				tooltipFrame:SetHyperlink (("unit:Creature-0-0-0-0-%d"):format(npcID))
				local npcNameLine = _G ["GetCreatureNameFromIDFinderTooltipTextLeft1"]
				return npcNameLine and npcNameLine:GetText()
			end
		end
		
		local translate_npc_cache
		translate_npc_cache	= function()
			if not Plater.db.profile.auto_translate_npc_names then return end
			if PLAYER_IN_COMBAT then --or not IS_IN_OPEN_WORLD then
				C_Timer.After(5, translate_npc_cache)
				return
			end
			
			local count = 0
			local leftOvers = false
			for id, entry in pairs(DB_NPCIDS_CACHE) do
				
				if entry[3] ~= Plater.Locale then
					local npcName = GetCreatureNameFromID(id)
					if npcName then
						--DevTool:AddData(npcName, "translated")
						entry[1] = npcName
						entry[3] = Plater.Locale
						count = count + 1
					else
						--DevTool:AddData(id .. " - " .. entry[1], "not translated")
					end
				end
				
				if count >= maxPerFrame then
					leftOvers = true
					break
				end
			end
			
			if leftOvers and Plater.TranslateNPCCacheIsRunning then
				C_Timer.After(translateTimer, translate_npc_cache)
			else
				Plater.TranslateNPCCacheIsRunning = false
			end
		end
		translate_npc_cache()
	end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> combat log reader  ~combatlog ~cleu


	local PlaterCLEUParser = CreateFrame ("frame", "PlaterCLEUParserFrame", UIParent, BackdropTemplateMixin and "BackdropTemplate")

	-- defined local above
	parserFunctions = {
		--todo: if animations are disabled, SPELL_DAMAGE doesn't need to be read
		SPELL_DAMAGE = function (time, token, hidding, sourceGUID, sourceName, sourceFlag, sourceFlag2, targetGUID, targetName, targetFlag, targetFlag2, spellID, spellName, spellType, amount, overKill, school, resisted, blocked, absorbed, isCritical)
			if (SPELL_WITH_ANIMATIONS [spellName] and sourceGUID == Plater.PlayerGUID) then
				for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
					if (plateFrame [MEMBER_GUID] == targetGUID and plateFrame.unitFrame.PlaterOnScreen) then
						Plater.DoNameplateAnimation (plateFrame, SPELL_WITH_ANIMATIONS [spellName], spellName, isCritical)
					end
				end
			end
		end,
		
		--~summon
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

			---@type plater_petinfo
			local entry = {
				ownerGUID = sourceGUID,
				ownerName = sourceName,
				petName = targetName,
				time = time
			}
			PET_CACHE[targetGUID] = entry
			
			if (sourceGUID == Plater.PlayerGUID) then
				Plater.PlayerPetCache [targetGUID] = entry
			end

			--check if the summoner has friendly affiliation, if it is friendly, add it to the friendly affiliation cache
			if ((sourceFlag and bit.band(sourceFlag, 0x10) ~= 0) or (targetFlag and bit.band(targetFlag, 0x10) ~= 0)) then --0x10 = affiliation friendly
				platerInternal.HasFriendlyAffiliation[targetGUID] = true
			end
		end,
		
		SPELL_INTERRUPT = function (time, token, hidding, sourceGUID, sourceName, sourceFlag, sourceFlag2, targetGUID, targetName, targetFlag, targetFlag2, spellID, spellName, spellType, amount, overKill, school, resisted, blocked, absorbed, isCritical)
			if (IS_IN_INSTANCE) then
				PlaterDB.InterruptableSpells[spellID] = true
			end

			if (not Plater.db.profile.show_interrupt_author) then
				return
			end

			--~interrupt
			local name = sourceName
			for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
				local unitFrame = plateFrame.unitFrame
				local castBar = unitFrame.castBar
				if (unitFrame.PlaterOnScreen and castBar:IsShown()) then
					if (plateFrame [MEMBER_GUID] == targetGUID) then
						--get owner name if a pet interrupted
						local petOwnerTable = PET_CACHE[sourceGUID]
						if (petOwnerTable) then
							name = petOwnerTable.ownerName or name
							sourceGUID = petOwnerTable.ownerGUID or sourceGUID
						end
						if DB_USE_NAME_TRANSLIT then
							name = LibTranslit:Transliterate(name, TRANSLIT_MARK)
						end
						castBar.Text:SetText (INTERRUPTED .. " [" .. Plater.SetTextColorByClass (sourceGUID, name) .. "]")
						castBar.IsInterrupted = true
						castBar.InterruptSourceName = sourceName
						castBar.InterruptSourceGUID = sourceGUID
						
						--interrupt animation
						if (Plater.db.profile.cast_statusbar_interrupt_anim) then
							local interruptAnim = castBar._interruptAnim
							if (not interruptAnim) then
								--scale animation
								local duration = 0.05
								local animationHub = DF:CreateAnimationHub(castBar)
								animationHub.ScaleUp = DF:CreateAnimation(animationHub, "scale", 1, duration,	1, 	1, 	1, 	1.05)
								animationHub.ScaleDown = DF:CreateAnimation(animationHub, "scale", 2, duration,	1, 	1.05, 	1, 	0.95)

								--shake animattion
								local duration = 0.36
								local amplitude = 0.58
								local frequency = 3.39
								local absolute_sineX = false
								local absolute_sineY = false
								local scaleX = 0
								local scaleY = 1.2
								local fade_out = 0.33
								local fade_in = 0.001
								local cooldown = 0.5

								local points = castBar._points
								local frameShakeObject = DF:CreateFrameShake(castBar, duration, amplitude, frequency, absolute_sineX, absolute_sineY, scaleX, scaleY, fade_in, fade_out, points)

								castBar._interruptAnim = {
									Scale = animationHub,
									Shake = frameShakeObject
								}

								interruptAnim = castBar._interruptAnim
							end

							interruptAnim.Scale:Play()
							castBar:PlayFrameShake(interruptAnim.Shake)
						end

						castBar.FrameOverlay.TargetName:Hide() -- hide the target immediately
						--> check and stop the casting script if any
						castBar:OnHideWidget()
					end
				end
			end
		end,
		
		SPELL_CAST_SUCCESS = function (time, token, hidding, sourceGUID, sourceName, sourceFlag, sourceFlag2, targetGUID, targetName, targetFlag, targetFlag2, spellID, spellName, spellType, amount, overKill, school, resisted, blocked, absorbed, isCritical)
			if ((tonumber(spellID) or 0) > 0 and (not DB_CAPTURED_SPELLS[spellID] or DB_CAPTURED_SPELLS[spellID].isChanneled == nil)) then -- check isChanneled to ensure update of already existing data
				if (not platerInternal.HasFriendlyAffiliation[sourceGUID]) then
					if (not sourceFlag or bit.band(sourceFlag, 0x60) ~= 0) then --is neutral or hostile
						local npcId = Plater:GetNpcIdFromGuid(sourceGUID or "")
						local isChanneled = false
						if sourceGUID and UnitTokenFromGUID then -- this is the only proper way to check for channeled spells...
							local unit = UnitTokenFromGUID(sourceGUID)
							if unit and UnitChannelInfo(unit) then
								isChanneled = true
							end 
						end

						if (npcId and npcId ~= 0) then
							---@type plater_spelldata
							local spellData = {
								event = token,
								source = sourceName,
								npcID = npcId,
								encounterID = Plater.CurrentEncounterID,
								encounterName = Plater.CurrentEncounterName,
								isChanneled = isChanneled
							}
							--print("added DB_CAPTURED_SPELLS 1:", sourceName, spellID, spellName)
							DB_CAPTURED_SPELLS[spellID] = spellData

							if isChanneled and not DB_CAPTURED_CASTS[spellID] then
								---@type plater_spelldata
								local spellData = {
									event = token,
									source = sourceName,
									npcID = npcId,
									encounterID = Plater.CurrentEncounterID,
									encounterName = Plater.CurrentEncounterName,
									isChanneled = isChanneled
								}
								DB_CAPTURED_CASTS[spellID] = spellData
							end
						end
					end
				end
			end
		end,
		
		SPELL_CAST_START = function (time, token, hidding, sourceGUID, sourceName, sourceFlag, sourceFlag2, targetGUID, targetName, targetFlag, targetFlag2, spellID, spellName, spellType, amount, overKill, school, resisted, blocked, absorbed, isCritical)
			if (not DB_CAPTURED_CASTS[spellID] and not platerInternal.HasFriendlyAffiliation[sourceGUID]) then
				if (not sourceFlag or bit.band(sourceFlag, 0x60) ~= 0) then --is neutral or hostile
					local npcId = Plater:GetNpcIdFromGuid(sourceGUID or "")
					if (npcId and npcId ~= 0) then
						---@type plater_spelldata
						local spellData = {
							event = token,
							source = sourceName,
							npcID = npcId,
							encounterID = Plater.CurrentEncounterID,
							encounterName = Plater.CurrentEncounterName
						}
						DB_CAPTURED_CASTS[spellID] = spellData
					end
				end
			end

			if (spellName) then
				Plater.LastCombat.spellNames[spellName] = true
			end

			platerInternal.Audio.PlaySoundForCastStart(spellID)
		end,

		SPELL_AURA_APPLIED = function (time, token, hidding, sourceGUID, sourceName, sourceFlag, sourceFlag2, targetGUID, targetName, targetFlag, targetFlag2, spellID, spellName, spellType, auraType, overKill, school, resisted, blocked, absorbed, isCritical)
			if (not DB_CAPTURED_SPELLS[spellID] and not platerInternal.HasFriendlyAffiliation[sourceGUID]) then
				if (not sourceFlag or bit.band(sourceFlag, 0x60) ~= 0) then --is neutral or hostile
					local npcId = Plater:GetNpcIdFromGuid(sourceGUID or "")
					if (npcId and npcId ~= 0) then
						---@type plater_spelldata
						local spellData = {
							event = token,
							source = sourceName,
							type = auraType,
							npcID = npcId,
							encounterID = Plater.CurrentEncounterID,
							encounterName = Plater.CurrentEncounterName
						}
						--print("added DB_CAPTURED_SPELLS 2:", sourceName, spellID, spellName, sourceFlag)
						DB_CAPTURED_SPELLS[spellID] = spellData
					end
				end
			end
			
			if IS_WOW_PROJECT_NOT_MAINLINE then
				-- paladin tank buff tracking
				local playerGUID = Plater.PlayerGUID
				if sourceGUID == playerGUID and targetGUID == playerGUID then
					spellId = select(7, GetSpellInfo(spellName))
					if spellId == 25780 or spellId == 407627 then
						UpdatePlayerTankState(true)
						--Plater.RefreshTankCache()
					end
				end
			end
		end,

		UNIT_DIED = function(time, token, hidding, sourceGUID, sourceName, sourceFlag, sourceFlag2, targetGUID)
			--targetGUID is the GUID of the unit which died
			platerInternal.ExtraAuras.RemoveGUIDFromUnitFrameCache(targetGUID)
		end,
	}
	
	if IS_WOW_PROJECT_NOT_MAINLINE then
		tinsert(parserFunctions, {
			SPELL_AURA_REMOVED = function (time, token, hidding, sourceGUID, sourceName, sourceFlag, sourceFlag2, targetGUID, targetName, targetFlag, targetFlag2, spellID, spellName, spellType, amount, overKill, school, resisted, blocked, absorbed, isCritical)
				-- paladin tank buff tracking
				local playerGUID = Plater.PlayerGUID
				if sourceGUID == playerGUID and targetGUID == playerGUID then
					spellId = select(7, GetSpellInfo(spellName))
					if spellId == 25780 or spellId == 407627 then
						UpdatePlayerTankState(false)
						--Plater.RefreshTankCache()
					end
				end
			end,
		})
	end

	PlaterCLEUParser.Parser = function (self)
		local time, token, hidding, sourceGUID, sourceName, sourceFlag, sourceFlag2, targetGUID, targetName, targetFlag, targetFlag2, spellID, spellName, spellType, amount, overKill, school, resisted, blocked, absorbed, isCritical = CombatLogGetCurrentEventInfo()
		local func = parserFunctions [token]
		if (func) then
			Plater.StartLogPerformanceCore("Plater-Core", "Events", token)
			func (time, token, hidding, sourceGUID, sourceName, sourceFlag, sourceFlag2, targetGUID, targetName, targetFlag, targetFlag2, spellID, spellName, spellType, amount, overKill, school, resisted, blocked, absorbed, isCritical)
			if (targetName) then
				Plater.LastCombat.npcNames[targetName] = true
			end
			Plater.EndLogPerformanceCore("Plater-Core", "Events", token)
		end
	end

	PlaterCLEUParser:SetScript ("OnEvent", PlaterCLEUParser.Parser)
	PlaterCLEUParser:RegisterEvent ("COMBAT_LOG_EVENT_UNFILTERED")

	C_Timer.NewTicker (600, function()
		local now = time()
		for guid, entry in pairs (PET_CACHE) do
			local time = entry.time
			if (time+600 < now) then
				PET_CACHE [guid] = nil
			end
		end
		
		for guid, entry in pairs (Plater.PlayerPetCache) do
			local time = entry.time
			if (time + 3600 < now) then
				Plater.PlayerPetCache [guid] = nil
			end
		end
	end)

	Plater.NpcBlackList = {} 
	function Plater.ForceFindPetOwner (serial) --private
		Plater.StartLogPerformanceCore("Plater-Core", "Update", "ForceFindPetOwner")
		
		local petName,text1
		local cbMode = tonumber(GetCVar("colorblindMode")) or 0
		if IS_WOW_PROJECT_MAINLINE then
			local tooltipData = C_TooltipInfo.GetHyperlink ("unit:" .. serial or "")
			if tooltipData then
				local lines = tooltipData.lines
				
				petName = lines and lines[1] and lines[1].leftText
				text1 = lines and lines[2 + cbMode] and lines[2 + cbMode].leftText
			end
			
		else
			local tooltipFrame = PlaterPetOwnerFinder or CreateFrame ("GameTooltip", "PlaterPetOwnerFinder", nil, "GameTooltipTemplate")
			tooltipFrame:SetOwner (WorldFrame, "ANCHOR_NONE")
			tooltipFrame:SetHyperlink ("unit:" .. serial or "")
			
			local petNameLine = _G ["PlaterPetOwnerFinderTextLeft1"]
			petName = petNameLine and petNameLine:GetText()
			local line1 = _G ["PlaterPetOwnerFinderTextLeft" .. (2 + cbMode)]
			text1 = line1 and line1:GetText()
		end
		
		local isPlayerPet = false
		local isOtherPet = false
		local ownerName = ""
		
		
		if (text1 and text1 ~= "") then
			local pName = GetUnitName ("player", true)
			local playerName = pName:gsub ("%-.*", "") --remove realm name
			if (text1:find (playerName)) then
				isPlayerPet = true
				ownerName = playerName
			else
				ownerName = (string.match(text1, string.gsub(UNITNAME_TITLE_PET, "%%s", "(%.*)")) or string.match(text1, string.gsub(UNITNAME_TITLE_MINION, "%%s", "(%.*)")) or string.match(text1, string.gsub(UNITNAME_TITLE_GUARDIAN, "%%s", "(%.*)")))
				if ownerName then
					isOtherPet = true
				end
			end
		end
		
		if (isPlayerPet or isOtherPet) and petName then
			local entry = {ownerGUID = UnitGUID(ownerName), ownerName = ownerName, petName = petName, time = time()}
			
			if (isPlayerPet) then
				PET_CACHE [serial] = entry
				Plater.PlayerPetCache [serial] = entry
			elseif (isOtherPet) then
				--ViragDevTool_AddData({serial = serial, entry = entry, tooltipFrame = tooltipFrame}, "pet")
				PET_CACHE [serial] = entry
			end
		else
			Plater.NpcBlackList [serial] = true
		end
		
		Plater.EndLogPerformanceCore("Plater-Core", "Update", "ForceFindPetOwner")
	end
	
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> cvars - ~cvars
	
function Plater.CreatePlaterButtonAtInterfaceOptions()
	if not InterfaceOptionsFrame then return end --DF does not has this anymore TODO
	local f = CreateFrame ("frame", nil, InterfaceOptionsNamesPanel, BackdropTemplateMixin and "BackdropTemplate")
	f:SetSize (300, 200)
	f:SetPoint ("topleft", InterfaceOptionsNamesPanel, "topleft", 10, -440)
	
	local open_options = function()
		InterfaceOptionsFrame:Hide()
		HideUIPanel(GameMenuFrame)
		Plater.OpenOptionsPanel()
	end
	
	local Button = DF:CreateButton (f, open_options, 100, 22, "", -1, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"))
	Button:SetPoint ("topleft", f, "topleft", 10, 0)
	Button:SetText ("Advanced Nameplate Options")
	Button:SetIcon ([[Interface\BUTTONS\UI-OptionsButton]], 18, 18, "overlay", {0, 1, 0, 1})
end

--elseof
function Plater.SetCVarsOnFirstRun()

	if (InCombatLockdown()) then
		C_Timer.After (1, function() Plater.SetCVarsOnFirstRun() end)
		return
	end
	
	canSaveCVars = false -- ensure to not overwrite profile

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
	if IS_WOW_PROJECT_MAINLINE then
		SetCVar ("ShowNamePlateLoseAggroFlash", CVAR_ENABLED) --blizzard flash
	end
	
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
	SetCVar ("clampTargetNameplateToScreen", "1")
	SetCVar ("nameplateTargetRadialPosition", "1")
	SetCVar ("nameplateTargetBehindMaxDistance", "30")

	--> reset the horizontal and vertical scale
	SetCVar ("NamePlateHorizontalScale", CVAR_ENABLED)
	SetCVar ("NamePlateVerticalScale", CVAR_ENABLED)
	if IS_WOW_PROJECT_MAINLINE then
		SetCVar ("NamePlateClassificationScale", CVAR_ENABLED)
	end
	
	--> make the selection be a little bigger
	SetCVar ("nameplateSelectedScale", "1.15")

	--> movement speed of nameplates when using stacking, going above 0.5 this isn't recommended
	SetCVar ("nameplateMotionSpeed", "0.025")

	--> make the personal bar hide very fast
	SetCVar ("nameplatePersonalHideDelaySeconds", 0.2)
	
	--> don't show debuffs on blizzard healthbars
	SetCVar ("nameplateShowDebuffsOnFriendly", CVAR_DISABLED)

	--> view distance
	if IS_WOW_PROJECT_MAINLINE then
		SetCVar ("nameplateMaxDistance", 60)
	else
		SetCVar ("nameplateMaxDistance", 41)
	end
	
	--> ensure resource on target consistency:
	if IS_WOW_PROJECT_MAINLINE then
		PlaterDBChr.resources_on_target = GetCVar ("nameplateResourceOnTarget") == CVAR_ENABLED
		SetCVar ("nameplateResourceOnTarget", CVAR_DISABLED)
	end
	
	PlaterDBChr.first_run3 [UnitGUID ("player")] = true
	Plater.db.profile.first_run3 = true
	
	Plater.RunFunctionForEvent ("ZONE_CHANGED_NEW_AREA")
	
	--Plater:Msg ("Plater has been successfully installed on this character.")
	
	Plater.RestoreProfileCVars() -- restore profile, if existing
	
	canSaveCVars = true -- save cvars again

end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> quest log stuff ~quest
	
	function Plater.GetActorSubName (plateFrame) --private
		local cbMode = tonumber(GetCVar("colorblindMode")) or 0
		local subTitle = ""
		if IS_WOW_PROJECT_MAINLINE then
			local tooltipData = C_TooltipInfo.GetHyperlink("unit:" .. (plateFrame [MEMBER_GUID] or ""))
			if tooltipData then
				local line = tooltipData.lines and tooltipData.lines[2 + cbMode]
				subTitle = line and line.leftText or ""
			end
		else
			local GameTooltipFrame = PlaterScanTooltip or CreateFrame ("GameTooltip", "PlaterScanTooltip", nil, "GameTooltipTemplate")
			GameTooltipFrame:SetOwner (WorldFrame, "ANCHOR_NONE")
			GameTooltipFrame:SetHyperlink ("unit:" .. (plateFrame [MEMBER_GUID] or ''))
			
			local GameTooltipFrameTextLeft = _G ["PlaterScanTooltipTextLeft" .. (2 + cbMode)]
			subTitle = GameTooltipFrameTextLeft and GameTooltipFrameTextLeft:GetText() or ""
		end
		if subTitle ~= "" and not subTitle:lower():match (string.gsub(UNIT_LEVEL_TEMPLATE:lower(), "%%d", "(%.*)")) then
			return subTitle
		else
			return nil
		end
	end

	function Plater.IsQuestObjective (plateFrame)
		if (not plateFrame [MEMBER_GUID]) then --platerFrame.actorType == "friendlynpc"
			return
		end
		
		Plater.StartLogPerformanceCore("Plater-Core", "Update", "IsQuestObjective")
		
		-- reset quest amount
		plateFrame.QuestAmountCurrent = nil
		plateFrame.QuestAmountTotal = nil
		plateFrame.QuestText = nil
		plateFrame.QuestName = nil
		plateFrame.QuestIsCampaign = nil
		plateFrame.unitFrame.QuestAmountCurrent = nil
		plateFrame.unitFrame.QuestAmountTotal = nil
		plateFrame.unitFrame.QuestText = nil
		plateFrame.unitFrame.QuestName = nil
		plateFrame.unitFrame.QuestIsCampaign = nil
		
		local ScanQuestTextCache = {}
		local useQuestie = false
		local QuestieTooltips = QuestieLoader and QuestieLoader._modules["QuestieTooltips"]
		if QuestieTooltips then
			ScanQuestTextCache = QuestieTooltips.GetTooltip("m_"..plateFrame [MEMBER_NPCID])
			if not ScanQuestTextCache then
				ScanQuestTextCache = {}
			end
			useQuestie = true
		else
			if IS_WOW_PROJECT_MAINLINE then
				local tooltipData = C_TooltipInfo.GetHyperlink ("unit:" .. plateFrame [MEMBER_GUID])
				if tooltipData then
					for _, line in ipairs(tooltipData.lines or {}) do
						if line.type == Enum.TooltipDataLineType.QuestObjective or line.type == Enum.TooltipDataLineType.QuestTitle or line.type == Enum.TooltipDataLineType.QuestPlayer then
							--only add actual quest tooltip lines
							ScanQuestTextCache [#ScanQuestTextCache + 1] = line.leftText or ""
						end
					end
				end
			else
				local GameTooltipScanQuest = PlaterScanQuestTooltip or CreateFrame ("GameTooltip", "PlaterScanQuestTooltip", nil, "GameTooltipTemplate")
				GameTooltipScanQuest:SetOwner (WorldFrame, "ANCHOR_NONE")
				GameTooltipScanQuest:SetHyperlink ("unit:" .. plateFrame [MEMBER_GUID])
				
				for i = 1, GameTooltipScanQuest:NumLines() do
					ScanQuestTextCache [i] = _G ["PlaterScanQuestTooltipTextLeft" .. i]:GetText() or ""
				end
			end
			
		end
		
		local playerName = UnitName("player")
		local isInGroup = IsInGroup()
		local unitQuestData = {}
		
		local isQuestUnit = false
		local atLeastOneQuestUnfinished = false
		for i = 1, #ScanQuestTextCache do
			local text = ScanQuestTextCache [i]
			if useQuestie then
				text = gsub(text,"|c........","") -- remove coloring begin
				text = gsub(text,"|r","") -- remove color end
				text = gsub(text,"%[.*%] ","") -- remove level text
				text = gsub(text," %(%d+%)","") -- remove quest-id
			end
			
			if (Plater.QuestCache [text]) then
				--unit belongs to a quest
				isQuestUnit = true
				
				local isCampaignQuest = Plater.QuestCacheCampaign[text]
				local isGroupQuest, yourQuest = nil, nil

				---@type questdata
				local questData = {
					questName = text,
					questText = "",
					finished = true,
					groupQuest = false,
					groupFinished = true,
					amount = 0,
					groupAmount = 0,
					total = 0,
					yourQuest = false,
					isCampaignQuest = isCampaignQuest,
				}

				local amount1, amount2, questText = nil, nil, nil
				local amountSet = false
				local j = i
				while (ScanQuestTextCache [j+1]) do
					--check if the unit objective isn't already done
					local nextLineText = ScanQuestTextCache [j+1]
					if useQuestie then
						nextLineText = gsub(nextLineText,"|c........","") -- remove coloring begin
						nextLineText = gsub(nextLineText,"|r","") -- remove color end
					end
					
					if (nextLineText) then
						if useQuestie then
							local isQuestieOwn = nextLineText:match ("%(("..playerName..")%)%s*$") and true or false
							local isQuestieGroup = nextLineText:match ("%((%w+)%)%s*$") and isInGroup and true or false
							yourQuest = isQuestieOwn or not isQuestieGroup
							isGroupQuest = isQuestieGroup
							questData.yourQuest = yourQuest
							questData.groupQuest = isGroupQuest
						end
						if not useQuestie and isInGroup and nextLineText == playerName then
							yourQuest = true
							isGroupQuest = true
							questData.yourQuest = true
							questData.groupQuest = true
						elseif not nextLineText:match(THREAT_TOOLTIP) then
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
								if not amountSet or ((tonumber(p1) or 0) < (tonumber(questData.groupAmount) or 0)) then
									questData.groupAmount = amount1
								end
								
								questData.total = amount2
								if yourQuest ~= false then
									yourQuest = false -- already set on data
									questData.finished = false
									questData.amount = amount1
								end
								questData.groupFinished = false
								questData.questText = nextLineText
								questText = nextLineText
								amountSet = true
							elseif yourQuest and (p1 and p2 and (p1 == p2)) or (p1 and not p2 and (p1 == "100")) then
								yourQuest = false -- already set on data
								questData.finished = true
								questData.amount = p1
							end
						else
							j = 99 --safely break here, as we saw threat% -> quest text is done
						end
					end
					j = j + 1
				end

				if (amount1 and atLeastOneQuestUnfinished) then
					plateFrame.QuestAmountCurrent = questData.groupAmount
					plateFrame.QuestAmountTotal = amount2
					plateFrame.QuestText = questText
					plateFrame.QuestName = text
					plateFrame.QuestIsCampaign = isCampaignQuest
					
					--expose to scripts
					plateFrame.unitFrame.QuestAmountCurrent = questData.groupAmount
					plateFrame.unitFrame.QuestAmountTotal = amount2
					plateFrame.unitFrame.QuestText = questText
					plateFrame.unitFrame.QuestName = text
					plateFrame.unitFrame.QuestIsCampaign = isCampaignQuest
				end
				
				if not isGroupQuest then
					questData.yourQuest = true
				end
				
				tinsert(unitQuestData, questData)
			end
		end
		
		plateFrame.QuestInfo = unitQuestData
		plateFrame.unitFrame.QuestInfo = unitQuestData
		
		local namePlateIsQuestObjective = isQuestUnit and atLeastOneQuestUnfinished
		plateFrame [MEMBER_QUEST] = namePlateIsQuestObjective
		plateFrame.unitFrame [MEMBER_QUEST] = namePlateIsQuestObjective
		
		Plater.EndLogPerformanceCore("Plater-Core", "Update", "IsQuestObjective")
		
		return namePlateIsQuestObjective
	end

	local update_quest_cache = function()

		--clear the quest cache
		wipe (Plater.QuestCache)
		wipe (Plater.QuestCacheCampaign)

		--do not update if is inside an instance
		local isInInstance = IsInInstance()
		if (isInInstance) then
			return
		end
		
		--update the quest cache
		local numEntries, numQuests = C_QuestLog.GetNumQuestLogEntries and C_QuestLog.GetNumQuestLogEntries() or GetNumQuestLogEntries()
		for questLogId = 1, numEntries do
			if IS_WOW_PROJECT_MAINLINE then
				local questDetails = C_QuestLog.GetInfo(questLogId)
				--any chance to track via quest objective? no unit IDs given there...
				--ViragDevTool_AddData({questDetails = questDetails, QuestObjectives = C_QuestLog.GetQuestObjectives(questDetails.questID), Title = C_QuestLog.GetTitleForLogIndex(questLogId)}, "QuestUpdate - " .. questLogId)
				if (questDetails and not questDetails.isHeader and questDetails.title and type (questDetails.questID) == "number" and questDetails.questID > 0) then
					Plater.QuestCache [questDetails.title] = true
					if (questDetails.campaignID) then
						Plater.QuestCacheCampaign[questDetails.title] = true
					end
				end
			else
				local title, level, suggestedGroup, isHeader, isCollapsed, isComplete, frequency, questId, startEvent, displayQuestID, isOnMap, hasLocalPOI, isTask, isStory = GetQuestLogTitle (questLogId)
				if (type (questId) == "number" and questId > 0) then -- and not isComplete
					Plater.QuestCache [title] = true
				end
			end
		end
		
		if IS_WOW_PROJECT_MAINLINE then
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
		end
		
		Plater.UpdateAllPlates()
	end

	function Plater.QuestLogUpdated() --private
		if (Plater.UpdateQuestCacheThrottle and not Plater.UpdateQuestCacheThrottle._cancelled) then
			Plater.UpdateQuestCacheThrottle:Cancel()
		end
		Plater.UpdateQuestCacheThrottle = C_Timer.NewTimer(1, update_quest_cache)
	end



--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> API ~API

	--attempt to get the role of the unit shown in the nameplate
	function Plater.GetUnitRole (unitFrame)
		if IS_WOW_PROJECT_MAINLINE then
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
			
		else
			if IS_WOW_PROJECT_CLASSIC_WRATH then
				local assignedRole = UnitGroupRolesAssigned (unitFrame.unit)
				if (assignedRole and assignedRole ~= "NONE") then
					return assignedRole
				end
			end
			if GetPartyAssignment("MAINTANK", unit) then
				return "MAINTANK"
			elseif GetPartyAssignment("MAINASSIST", unit) then
				return "MAINASSIST"
			end
		end
	end
	
	
	local BG_PLAYER_CACHE = {}
	function Plater.UpdateBgPlayerRoleCache()
		wipe(BG_PLAYER_CACHE)
	
		if IS_WOW_PROJECT_MAINLINE then
			if Plater.ZoneInstanceType == "pvp" then
				local curNumScores = GetNumBattlefieldScores()
				for i = 1, curNumScores do
					local info = C_PvP.GetScoreInfo(i)
					if info then
						local name, faction, race, class, classToken, talentSpec = info.name, info.faction, info.raceName, info.className, info.classToken, info.talentSpec
						if name then
							BG_PLAYER_CACHE[name] = {faction = faction, race = race, class = class, classToken = classToken, talentSpec = talentSpec, specID = (CLASS_INFO_CACHE[classToken] and CLASS_INFO_CACHE[classToken][talentSpec] and CLASS_INFO_CACHE[classToken][talentSpec].specID), name = name}
						end
					end
				end
			elseif Plater.ZoneInstanceType == "arena" then
				local numOpps = GetNumArenaOpponentSpecs();
				for i=1, numOpps do
					local specID, gender = GetArenaOpponentSpec(i);
					if (specID > 0) then
						local name = GetUnitName ("arena"..i, true)
						if name then
							local id, talentSpec, _, _, _, class = GetSpecializationInfoByID(specID, gender);
							local class, classToken = UnitClass("arena"..i);
							local race = UnitRace("arena"..i);
							BG_PLAYER_CACHE[name] = {faction = nil, race = race, class = class, classToken = classToken, talentSpec = talentSpec, specID = specID, name = name}
						end
					end
				end
			end
			
		else
			--TODO: Does this really work in BG/Arena or is it just score screen?
			if Plater.ZoneInstanceType == "pvp" or Plater.ZoneInstanceType == "arena" then
				local curNumScores = GetNumBattlefieldScores()
				for i = 1, curNumScores do
					local name, _, _, _, _, faction, _, race, class, classToken = GetBattlefieldScore(i);
					if name then
						BG_PLAYER_CACHE[name] = {faction = faction, race = race, class = class, classToken = classToken, talentSpec = "UNKNOWN", specID = nil, name = name}
					end
				end
			end
		end
	end

	function Plater.GetUnitBGInfo(unit)

		if (not UnitIsPlayer(unit)) then
			return nil
		end
		
		if (not Plater.ZoneInstanceType == "pvp" and not Plater.ZoneInstanceType == "arena") then
			return nil
		end

		local name = GetUnitName(unit, true)
		if not BG_PLAYER_CACHE[name] then
			Plater.UpdateBgPlayerRoleCache()
		end

		return BG_PLAYER_CACHE[name]
	end
	
	function Plater.GetSpecIconForUnitFromBG(unit)
		
		local cache = Plater.GetUnitBGInfo(unit)
		if cache and cache.specID then
			return Plater.GetSpecIcon(cache.specID)
		end
		return nil
	end
	
	function Plater.GetSpecIcon(spec)
		if (spec) then
			if (not class_specs_coords[spec]) then -- default to holy paladin if spec not supported
				spec = 65
			end
			if (useAlpha) then
				return [[Interface\AddOns\Plater\images\spec_icons_normal_alpha]], unpack (class_specs_coords [spec])
			else
				return [[Interface\AddOns\Plater\images\spec_icons_normal]], unpack (class_specs_coords [spec])
			end
		end
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
		return Plater.FriendsCache [unitFrame.unitNameInternal]
	end
	
	--> api version of the tap denied function
	function Plater.IsUnitTapped (unitFrame)
		return Plater.IsUnitTapDenied (unitFrame.unit)
	end
	
	--set if Plater will check for the execute range and what percent of life is require to enter in the execute range
	--healthAmount is a floor com zero to one, example: 25% is 0.25
	function Plater.SetExecuteRange (isExecuteEnabled, healthAmountLower, healthAmountUpper)
		DB_USE_HEALTHCUTOFF = isExecuteEnabled
		DB_HEALTHCUTOFF_AT = tonumber (healthAmountLower) or -0.1
		DB_HEALTHCUTOFF_AT_UPPER = tonumber (healthAmountUpper) or 1.1
	end
	
	--return the name of the unit guild
	function Plater.GetUnitGuildName (unitFrame)
		return unitFrame.PlateFrame.playerGuildName
	end
	
	--return if the nameplate is showing an aura
	function Plater.NameplateHasAura (unitFrame, aura)
		return unitFrame.BuffFrame.AuraCache [aura] or unitFrame.BuffFrame2.AuraCache [aura] or unitFrame.ExtraIconFrame.AuraCache [aura]
	end
	
	--return if the unit has a specific aura
	function Plater.UnitHasAura (unitFrame, aura)
		return unitFrame and unitFrame.AuraCache and aura and unitFrame.AuraCache [aura]
	end
	
	--return if the unit has an enrage effect
	function Plater.UnitHasEnrage (unitFrame)
		return unitFrame and unitFrame.AuraCache and unitFrame.AuraCache.hasEnrage
	end
	
	--return if the unit has a dispellable effect
	function Plater.UnitHasDispellable (unitFrame)
		return unitFrame and unitFrame.AuraCache and unitFrame.AuraCache.canStealOrPurge
	end
	
	--get npc color set in the colors tab, it is getting the color set by the user with or without the "scripts only checked"
	function Plater.GetNpcColor(unitFrame)
		local npcId = unitFrame[MEMBER_NPCID]
		if (npcId) then
			return DB_UNITCOLOR_CACHE[npcId] or DB_UNITCOLOR_SCRIPT_CACHE[npcId]
		end
	end

	--pass some colors and return the first valid color
    function Plater.GetColorByPriority(unitFrame, color1, color2, color3)
        if (unitFrame) then
			--from the Npc Colors and Names
            local npcColor = Plater.GetNpcColor(unitFrame)
            if (npcColor) then
                return npcColor
            end
        end
        
        if (color1) then
            return color1
        end
        
        if (color2) then
            return color2
        end

		if (color3) then
            return color3
        end
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
		
		if not text or text == "" then
			return
		end
		
		while (fontString:GetStringWidth() > maxWidth) do
			text = strsub (text, 1, #text - 1)
			fontString:SetText (text)
			if (string.len (text) <= 1) then
				break
			end
		end	
		
		-- cleanup utf8...
		text = DF:CleanTruncateUTF8String(text)
		fontString:SetText (text)
		
	end
	
	--create a custom aura checking, this reset the currently shown auras and only check for auras the script passed
	--this is only called from scripts
	--@buffList: a table with aura names as keys and true as the value, example: ["aura name"] = true
	--@debuffList: same as above
	--@noSpecialAuras: won't check special auras
	function Plater.CheckAuras (self, buffList, debuffList, noSpecialAuras)
		local buffFrame = self.BuffFrame
		local buffFrame2 = self.BuffFrame2
		
		Plater.ResetAuraContainer (buffFrame)
		
		Plater.TrackSpecificAuras (buffFrame, self.unit, true, buffList, self.IsSelf, noSpecialAuras)
		Plater.TrackSpecificAuras (buffFrame, self.unit, false, debuffList, self.IsSelf, noSpecialAuras)
		
		Plater.HideNonUsedAuraIcons (buffFrame)
		
		--update the buff layout and alpha
		buffFrame.unit = self.unit
		Plater.AlignAuraFrames (buffFrame)
		--buffFrame:SetAlpha (DB_AURA_ALPHA)
		
		if (DB_AURA_SEPARATE_BUFFS) then
			buffFrame2.unit = self.unit
			Plater.AlignAuraFrames (buffFrame2)
			--buffFrame2:SetAlpha (DB_AURA_ALPHA)
		end
		Plater.RunScriptTriggersForAuraIcons (unitFrame)
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
			frame.__PlaterGlowFrame = CreateFrame("Frame", nil, frame, BackdropTemplateMixin and "BackdropTemplate");
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
	function Plater.StartButtonGlow(frame, color, options, key)
		-- type "button"
		if not options then
			options = {
				glowType = "button",
				color = color, -- all plater color types accepted, from lib: {r,g,b,a}, color of lines and opacity, from 0 to 1. Defaul value is {0.95, 0.95, 0.32, 1}
				frequency = 0.125, -- frequency, set to negative to inverse direction of rotation. Default value is 0.125;
				key = key or "", -- key of glow, allows for multiple glows on one frame;
			}
		else
			options.glowType = "button"
		end
		
		Plater.StartGlow(frame, color or options.color, options, options.key)
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
		
		Plater.StartGlow(frame, color or options.color, options, options.key)
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
		
		Plater.StartGlow(frame, color or options.color, options, options.key)
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
	function Plater.CreateIconGlow (frame, color, color2, useShowAnimation)
		local f = Plater:CreateGlowOverlay (frame, color, color2 or color)
		if not useShowAnimation and IS_WOW_PROJECT_MAINLINE then
			f:SetScript("OnShow", nil) --reset
			
			local onShow = function(self)
				if (self.ProcStartAnim) then
					self.ProcStartAnim:Stop()
					self.ProcStartFlipbook:Hide()
					if (not self.ProcLoop:IsPlaying()) then
						self.ProcLoop:Play()
					end
				end
			end
			
			f:SetScript("OnShow", onShow)
		end
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
	function Plater.CreateFlash (frame, duration, amount, r, g, b, a)
		--defaults
		duration = duration or 0.25
		amount = amount or 1
		
		if (not r) then
			r, g, b, a = 1, 1, 1, 1
		else
			r, g, b, a = DF:ParseColors (r, g, b, a)
		end

		--create the flash frame
		local f = CreateFrame ("frame", "PlaterFlashAnimationFrame".. math.random (1, 100000000), frame, BackdropTemplateMixin and "BackdropTemplate")
		f:SetFrameLevel (frame:GetFrameLevel()+1)
		f:SetAllPoints()
		f:Hide()
		
		--create the flash texture
		local t = f:CreateTexture ("PlaterFlashAnimationTexture".. math.random (1, 100000000), "artwork")
		t:SetColorTexture (r, g, b, a)
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
			elseif (DB_UNITCOLOR_CACHE [unitFrame [MEMBER_NPCID] or -1]) then
				Plater.ChangeHealthBarColor_Internal (unitFrame.healthBar, unpack (DB_UNITCOLOR_CACHE [unitFrame [MEMBER_NPCID]]))
				unitFrame.UsingCustomColor = true --exposed to scripts
			else
				if (InCombatLockdown()) then
					local unitReaction = unitFrame.PlateFrame [MEMBER_REACTION]
					if (unitReaction == 4 and not unitFrame.InCombat) then
						Plater.FindAndSetNameplateColor (unitFrame, true)
					elseif (DB_AGGRO_CHANGE_HEALTHBAR_COLOR and unitFrame.CanCheckAggro and unitReaction <= 4) then
						Plater.UpdateNameplateThread (unitFrame)
					else
						Plater.FindAndSetNameplateColor (unitFrame)
					end
				else
					Plater.FindAndSetNameplateColor (unitFrame)
				end
			end
		end
	end

	--modify the color of the health bar
	function Plater.SetNameplateColor (unitFrame, r, g, b, a)
		if (unitFrame.unit) then
			if (not r) then
				Plater.RefreshNameplateColor (unitFrame)
			else
				r, g, b, a = DF:ParseColors (r, g, b, a)
				return Plater.ChangeHealthBarColor_Internal (unitFrame.healthBar, r, g, b, a)
			end
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
	
	---changes the border color, this call is for the API, can be called from external sources
	---@param self table unitFrame
	---@param r any
	---@param g number|nil
	---@param b number|nil
	---@param a number|nil
	function Plater.SetBorderColor(self, r, g, b, a)
		if (not r) then
			self.customBorderColor = nil
			Plater.UpdateBorderColor(self)
			return
		end
		
		r, g, b, a = DF:ParseColors(r, g, b, a)
		
		--UpdateBorderColor will use the value set on customBorderColor member if any
		self.customBorderColor = {r, g, b, a}
		
		Plater.UpdateBorderColor(self)
	end

	---flashes on the health bar border
	---@param unitFrame table unitFrame
	---@param duration number
	function Plater.FlashNameplateBorder(unitFrame, duration)
		if (not unitFrame.healthBar.PlayHealthFlash) then
			Plater.CreateHealthFlashFrame(unitFrame.PlateFrame)
		end
		unitFrame.healthBar.canHealthFlash = true
		unitFrame.healthBar.PlayHealthFlash(duration)
	end

	---flashes the unitFrame body showing a text in the middle of the flash texture, by default this call is use to show aggro alerts with the word "-AGGRO-"
	---@param unitFrame table unitFrame
	---@param text string
	---@param duration number
	function Plater.FlashNameplateBody(unitFrame, text, duration)
		--sending true to ignore cooldown
		unitFrame.PlateFrame.PlayBodyFlash(text, duration, true) --weird, there's no reference to the plateFrame
	end

	---return if the player is in combat
	---@return boolean bIsPlayerInCombat
	function Plater.IsInCombat()
		return InCombatLockdown() or PLAYER_IN_COMBAT
	end

	---return true if the unit is in the tank role
	---@param unitFrame table unitFrame
	---@return boolean bIsUnitInTankRole
	function Plater.IsUnitTank(unitFrame)
		return TANK_CACHE[unitFrame.unitNameInternal]
	end
	
	---check the player role and role specialization and return if it is in the tank role
	---@return boolean bIsPlayerInTankRole
	function Plater.IsPlayerTank()
		return IsPlayerEffectivelyTank()
	end
	
	---return the table where tanks is stored
	---has the unit name as the key and true as value
	---@return table<string, boolean> tankList
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
		unitFrame.PlateFrame.IsNpcWithoutHealthBar = false
		
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
		
		showPlayerName = showPlayerName and (unitFrame.ActorType == ACTORTYPE_FRIENDLY_PLAYER or unitFrame.ActorType == ACTORTYPE_ENEMY_PLAYER)
		showNameNpc = showNameNpc and (unitFrame.ActorType == ACTORTYPE_FRIENDLY_NPC or unitFrame.ActorType == ACTORTYPE_ENEMY_NPC)
		
		unitFrame.PlateFrame.IsFriendlyPlayerWithoutHealthBar = showPlayerName
		unitFrame.PlateFrame.IsNpcWithoutHealthBar = showNameNpc
		
		if (showPlayerName) then
			Plater.UpdatePlateText (unitFrame.PlateFrame, DB_PLATE_CONFIG [unitFrame.ActorType], true)
			
		elseif (showNameNpc) then
			Plater.UpdatePlateText (unitFrame.PlateFrame, DB_PLATE_CONFIG [unitFrame.ActorType], true)
		end
	end
	
	--forces a range check regardless of the user options and only changes the member_range flag, no alpha changes
	--if the spell name is passed, it just return the result without modifying the nameplate attributes
	function Plater.NameplateInRange (unitFrame, spellName)
		if (spellName) then
			return IsSpellInRange (spellName, unitFrame [MEMBER_UNITID]) == 1

		else
			local rangeChecker
			if unitFrame [MEMBER_REACTION] < 5 then 
				rangeChecker = Plater.RangeCheckFunctionEnemy
			else
				rangeChecker = Plater.RangeCheckFunctionFriendly
			end
			if (rangeChecker and rangeChecker (unitFrame [MEMBER_UNITID])) then
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
	
	--the mod/script error handler
	local errorContext = {}
	local prevErrors = {}
	local ErrorHandler = function(errorMessage)
		errorContext.message = errorContext.message or "Plater error: "
		local msg = errorContext.message .. errorMessage
		--throttle error messages a bit...
		local lastTime = prevErrors[msg]
		local curTime = GetTime()
		if lastTime and curTime - lastTime < 1 then
			return
		end
		prevErrors[msg] = curTime
		DevTool:AddData(errorContext)
		local modscriptInfo = errorContext.modscript and errorContext.modscript.url and ("Mod/Script URL: " .. errorContext.modscript.url .. "\n") or nil
		if BugGrabber then
			geterrorhandler()(errorContext.message .. "\n" .. (modscriptInfo or "") .. Plater.fullVersionInfo .. "\n" .. errorMessage)
		end
		Plater:Msg (msg .. (modscriptInfo and ("\n" .. modscriptInfo) or ""))
		errorContext = {}
		return errorMessage
	end
	local GetErrorHandler = function(contextMessage, contextModScript)
		errorContext.message = contextMessage
		errorContext.modscript = contextModScript
		return ErrorHandler
	end
	platerInternal.GetErrorHandler = GetErrorHandler


	--scripts mixin - these functions are mixed in with castbar, unitframe and aura icons
	Plater.ScriptMetaFunctions = {
		--get the table which stores all script information for the widget
		--self is the affected widget, e.g. icon frame, unitframe, castbar progressbar
		ScriptGetContainer = function(self)
			local infoTable = self.ScriptInfoTable
			if (not infoTable) then
				self.ScriptInfoTable = {}
				return self.ScriptInfoTable
			else
				return infoTable
			end
		end,
		
		--get the table which stores the information for a single script
		--run for hooks only
		HookGetInfo = function (self, globalScriptObject, scriptContainer)
			scriptContainer = scriptContainer or self:ScriptGetContainer()
			
			--using the memory address of the original scriptObject from db.profile as the map key
			local scriptInfo = scriptContainer[globalScriptObject.DBScriptObject.scriptId]

			if (
				(not scriptInfo) or 
				(scriptInfo.GlobalScriptObject.NeedHotReload) or 
				(scriptInfo.GlobalScriptObject.Build and scriptInfo.GlobalScriptObject.Build < PLATER_HOOK_BUILD)
			) then
				local forceHotReload = scriptInfo and scriptInfo.GlobalScriptObject.NeedHotReload
			
				--keep script info and update as needed
				scriptInfo = scriptInfo or {
					GlobalScriptObject = globalScriptObject, 
					HotReload = -1, 
					Env = {}, 
					IsActive = false
				}
				scriptInfo.GlobalScriptObject = globalScriptObject
				scriptInfo.GlobalScriptObject.Build = PLATER_HOOK_BUILD
				scriptInfo.GlobalScriptObject.NeedHotReload = false

				if (globalScriptObject.HasConstructor and (not scriptInfo.Initialized or forceHotReload)) then
					local modName = scriptInfo.GlobalScriptObject.DBScriptObject.Name
					Plater.StartLogPerformance("Mod-RunHooks", modName, "Constructor")
					local okay, errortext = xpcall (globalScriptObject.Constructor, GetErrorHandler("Plater Mod |cFFAAAA22" .. modName .. "|r Constructor error: ", globalScriptObject.DBScriptObject), self, self.displayedUnit or self.unit or self:GetParent()[MEMBER_UNITID], self, scriptInfo.Env, PLATER_GLOBAL_MOD_ENV [scriptInfo.GlobalScriptObject.DBScriptObject.scriptId])
					Plater.EndLogPerformance("Mod-RunHooks", modName, "Constructor")
					if (not okay) then
						--handled via error handler
						--Plater:Msg ("Plater Mod |cFFAAAA22" .. modName .. "|r Constructor error: " .. errortext)
					end
					scriptInfo.Initialized = true
				end
				
				scriptContainer [globalScriptObject.DBScriptObject.scriptId] = scriptInfo
			end
			
			--always overwriting the globalScriptObject fixes the issue for not updating the script after saving it but only for OnShow OnUpdate and OnHide
			scriptInfo.GlobalScriptObject = globalScriptObject
			return scriptInfo
		end,

		--get the table which stores the information for a single script
		--run for scripts only
		ScriptGetInfo = function (self, globalScriptObject, scriptContainer)
			scriptContainer = scriptContainer or self:ScriptGetContainer()
			
			--using the memory address of the original scriptObject from db.profile as the map key
			local scriptInfo = scriptContainer[globalScriptObject.DBScriptObject.scriptId]

			local lastUpdateTime = globalScriptObject.LastUpdateTime or 0
			if (not scriptInfo or scriptInfo.LastUpdateTime <= lastUpdateTime) then
				--create script info
				if (not scriptInfo) then
					scriptInfo = {
						--GlobalScriptObject = globalScriptObject, --is set below
						HotReload = -1, --deprecated
						Env = {}, 
						IsActive = false
					}
				end

				scriptInfo.LastUpdateTime = GetTime()
				--scriptInfo.GlobalScriptObject = globalScriptObject
				
				scriptContainer [globalScriptObject.DBScriptObject.scriptId] = scriptInfo
			end
			
			--always overwriting the globalScriptObject fixes the issue for not updating the script after saving it but only for OnShow OnUpdate and OnHide
			scriptInfo.GlobalScriptObject = globalScriptObject
			return scriptInfo
		end,
		
		--if the global script had an update or if the first time running this script on this widget, run the constructor
		ScriptHotReload = function (self, scriptInfo)
			--dispatch constructor if necessary
			if (scriptInfo.HotReload < scriptInfo.GlobalScriptObject.HotReload) then
				--update the hotreload state
				scriptInfo.HotReload = scriptInfo.GlobalScriptObject.HotReload

				--there's some bug with the global env becoming nil after saving a script
				--print(scriptInfo.GlobalScriptObject.DBScriptObject.Name, PLATER_GLOBAL_SCRIPT_ENV [scriptInfo.GlobalScriptObject.DBScriptObject.scriptId])

				--dispatch the constructor
				local unitFrame = self.unitFrame or self
				local scriptName = scriptInfo.GlobalScriptObject.DBScriptObject.Name
				Plater.StartLogPerformance("Scripts", scriptName, "Constructor")
				local okay, errortext = xpcall (scriptInfo.GlobalScriptObject ["ConstructorCode"], GetErrorHandler("Plater Script |cFFAAAA22" .. scriptName .. "|r Constructor error: ", scriptInfo.GlobalScriptObject.DBScriptObject), self, unitFrame.displayedUnit or unitFrame.unit or unitFrame.PlateFrame[MEMBER_UNITID], unitFrame, scriptInfo.Env, PLATER_GLOBAL_SCRIPT_ENV [scriptInfo.GlobalScriptObject.DBScriptObject.scriptId])
				Plater.EndLogPerformance("Scripts", scriptName, "Constructor")
				if (not okay) then
					--handled via error handler
					--Plater:Msg ("Plater Script |cFFAAAA22" .. scriptName .. "|r Constructor error: " .. errortext)
				end
			end
		end,
		
		--run the update script, called when the castbar updates, from within the tick and from the aura file on the AddAura()
		ScriptRunOnUpdate = function (self, scriptInfo)
			if (not scriptInfo.IsActive) then
				--run constructor
				self:ScriptHotReload (scriptInfo)
				--run on show
				self:ScriptRunOnShow (scriptInfo)
			end
			
			--dispatch the runtime script
			local unitFrame = self.unitFrame or self
			local scriptName = scriptInfo.GlobalScriptObject.DBScriptObject.Name
			Plater.StartLogPerformance("Scripts", scriptName, "OnUpdate")
			local okay, errortext = xpcall (scriptInfo.GlobalScriptObject ["UpdateCode"], GetErrorHandler("Plater Script |cFFAAAA22" .. scriptName .. "|r OnUpdate error: ", scriptInfo.GlobalScriptObject.DBScriptObject), self, unitFrame.displayedUnit or unitFrame.unit or unitFrame.PlateFrame[MEMBER_UNITID], unitFrame, scriptInfo.Env, PLATER_GLOBAL_SCRIPT_ENV [scriptInfo.GlobalScriptObject.DBScriptObject.scriptId])
			Plater.EndLogPerformance("Scripts", scriptName, "OnUpdate")
			if (not okay) then
				--handled via error handler
				--Plater:Msg ("Plater Script |cFFAAAA22" .. scriptName .. "|r OnUpdate error: " .. errortext)
			end
		end,
		
		--run the OnShow script
		ScriptRunOnShow = function(self, scriptInfo)
			--dispatch the on show script
			local unitFrame = self.unitFrame or self
			scriptInfo.Env._DefaultWidth = self:GetWidth()
			scriptInfo.Env._DefaultHeight = self:GetHeight()

			local scriptName = scriptInfo.GlobalScriptObject.DBScriptObject.Name
			Plater.StartLogPerformance("Scripts", scriptName, "OnShow")

			local func = scriptInfo.GlobalScriptObject["OnShowCode"]

			local okay, errortext = xpcall(func, GetErrorHandler("Plater Script |cFFAAAA22" .. scriptName .. "|r OnShow error: ", scriptInfo.GlobalScriptObject.DBScriptObject), self, unitFrame.displayedUnit or unitFrame.unit or unitFrame.PlateFrame[MEMBER_UNITID], unitFrame, scriptInfo.Env, PLATER_GLOBAL_SCRIPT_ENV [scriptInfo.GlobalScriptObject.DBScriptObject.scriptId])
			Plater.EndLogPerformance("Scripts", scriptName, "OnShow")

			if (not okay) then
				--handled via error handler
				--Plater:Msg ("Plater Script |cFFAAAA22" .. scriptName .. "|r OnShow error: " .. errortext)
			end
			
			scriptInfo.IsActive = true
			self.ScriptKey = scriptInfo.GlobalScriptObject.ScriptKey
		end,
		
		--run the OnHide script
		ScriptRunOnHide = function (self, scriptInfo)
			--dispatch the on hide script
			local unitFrame = self.unitFrame or self
			local scriptName = scriptInfo.GlobalScriptObject.DBScriptObject.Name
			Plater.StartLogPerformance("Scripts", scriptName, "OnHide")
			local okay, errortext = xpcall (scriptInfo.GlobalScriptObject ["OnHideCode"], GetErrorHandler("Plater Script |cFFAAAA22" .. scriptName .. "|r OnHide error: ", scriptInfo.GlobalScriptObject.DBScriptObject), self, unitFrame.displayedUnit or unitFrame.unit or unitFrame.PlateFrame[MEMBER_UNITID], unitFrame, scriptInfo.Env, PLATER_GLOBAL_SCRIPT_ENV [scriptInfo.GlobalScriptObject.DBScriptObject.scriptId])
			Plater.EndLogPerformance("Scripts", scriptName, "OnHide")
			if (not okay) then
				--handled via error handler
				--Plater:Msg ("Plater Script |cFFAAAA22" .. scriptName .. "|r OnHide error: " .. errortext)
			end
			
			scriptInfo.IsActive = false
			self.ScriptKey = nil
		end,
		
		--run the Initialization script, called during compile time
		ScriptRunInitialization = function (globalScriptObject)
			--dispatch the init script
			local scriptName = globalScriptObject.DBScriptObject.Name
			Plater.StartLogPerformance("Scripts", scriptName, "Initialization")
			local okay, errortext = xpcall (globalScriptObject ["Initialization"], GetErrorHandler("Plater Script |cFFAAAA22" .. scriptName .. "|r Initialization error: ", globalScriptObject.DBScriptObject), PLATER_GLOBAL_SCRIPT_ENV [globalScriptObject.DBScriptObject.scriptId])
			Plater.EndLogPerformance("Scripts", scriptName, "Initialization")
			if (not okay) then
				--handled via error handler
				--Plater:Msg ("Plater Script |cFFAAAA22" .. scriptName .. "|r Initialization error: " .. errortext)
			end
		end,
		
		ScriptRunCommMessageHook = function(globalScriptObject, hookName, source, ...)
			local modName = globalScriptObject.DBScriptObject.Name
			Plater.StartLogPerformance("Mod-RunHooks", modName, hookName)
			local okay, errortext = xpcall (globalScriptObject [hookName], GetErrorHandler("Plater Mod |cFFAAAA22" .. modName .. "|r code for |cFFBB8800" .. hookName .. "|r error: ", globalScriptObject.DBScriptObject), PLATER_GLOBAL_MOD_ENV [globalScriptObject.DBScriptObject.scriptId], source, ...)
			Plater.EndLogPerformance("Mod-RunHooks", modName, hookName)
			if (not okay) then
				--handled via error handler
				--Plater:Msg ("Plater Mod |cFFAAAA22" .. modName .. "|r code for |cFFBB8800" .. hookName .. "|r error: " .. errortext)
			end
		end,
		
		ScriptRunHook = function (self, scriptInfo, hookName, frame, ...)
			--dispatch a hook for the script
			--at the moment, self is always the unit frame
			local modName = scriptInfo.GlobalScriptObject.DBScriptObject.Name
			Plater.StartLogPerformance("Mod-RunHooks", modName, hookName)
			local okay, errortext = xpcall (scriptInfo.GlobalScriptObject [hookName], GetErrorHandler("Plater Mod |cFFAAAA22" .. modName .. "|r code for |cFFBB8800" .. hookName .. "|r error: ", scriptInfo.GlobalScriptObject.DBScriptObject), frame or self, self.displayedUnit, self, scriptInfo.Env, PLATER_GLOBAL_MOD_ENV [scriptInfo.GlobalScriptObject.DBScriptObject.scriptId], ...)
			Plater.EndLogPerformance("Mod-RunHooks", modName, hookName)
			if (not okay) then
				--handled via error handler
				--Plater:Msg ("Plater Mod |cFFAAAA22" .. modName .. "|r code for |cFFBB8800" .. hookName .. "|r error: " .. errortext)
			end
		end,
		
		--run only once without attach to the script or hook
		ScriptRunNoAttach = function (hookInfo, hookName)
			local func = hookInfo [hookName]
			local modName = hookInfo.DBScriptObject.Name
			Plater.StartLogPerformance("Mod-RunHooks", modName, " -NoAttach- " .. hookName)
			local okay, errortext = xpcall (func, GetErrorHandler("Plater Mod |cFFAAAA22" .. modName .. "|r code for |cFFBB8800" .. hookName .. "|r error: ", hookInfo.DBScriptObject), PLATER_GLOBAL_MOD_ENV [hookInfo.DBScriptObject.scriptId])
			Plater.EndLogPerformance("Mod-RunHooks", modName, " -NoAttach- " .. hookName)
			if (not okay) then
				--handled via error handler
				--Plater:Msg ("Plater Mod |cFFAAAA22" .. modName .. "|r code for |cFFBB8800" .. hookName .. "|r error: " .. errortext)
			end
		end,
		
		--run when the widget hides
		OnHideWidget = function(self)
			--check if can quickly quit (if there's no script container for the nameplate)
			if (self.ScriptInfoTable) then
				local triggerCacheTable
				
				if (self.IsAuraIcon) then
					triggerCacheTable = SCRIPT_AURA_TRIGGER_CACHE
				elseif (self.IsCastBar) then
					triggerCacheTable = SCRIPT_CASTBAR_TRIGGER_CACHE
				elseif (self.IsUnitNameplate) then
					triggerCacheTable = SCRIPT_UNIT_TRIGGER_CACHE
				end

				--ScriptKey holds the trigger of the script currently running
				local globalScriptObject = triggerCacheTable[self.ScriptKey]
				
				--does the aura has a custom script?
				if (globalScriptObject) then
					--does the aura icon has a table with script information?
					local scriptContainer = self:ScriptGetContainer() --return self.ScriptInfoTable
					if (scriptContainer) then
						local scriptInfo = self:ScriptGetInfo(globalScriptObject, scriptContainer)
						if (scriptInfo and scriptInfo.IsActive) then
							self:ScriptRunOnHide(scriptInfo)
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
						local scriptInfo = unitFrame:HookGetInfo(globalScriptObject, scriptContainer, "Cast Stop")
						--run
						unitFrame:ScriptRunHook (scriptInfo, "Cast Stop", self)
					end
				end
			end
			
		end,
		
		--stop a running script by the trigger ID
		--this is used when deleting a script or disabling it
		KillScript = function(self, triggerID)
			local triggerCacheTable
			
			if (self.IsAuraIcon) then
				triggerCacheTable = SCRIPT_AURA_TRIGGER_CACHE
				triggerID = GetSpellInfo(triggerID)
				
			elseif (self.IsCastBar) then
				triggerCacheTable = SCRIPT_CASTBAR_TRIGGER_CACHE
				triggerID = GetSpellInfo(triggerID)
				
			elseif (self.IsUnitNameplate) then
				triggerCacheTable = SCRIPT_UNIT_TRIGGER_CACHE
			end
			
			if (self.ScriptKey and self.ScriptKey == triggerID) then
				local globalScriptObject = triggerCacheTable[triggerID]
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
		local seeds = {}
		
		local function copyHookTables (t1, t2)
			for key, value in pairs (t2) do 
				if (key ~= "__index") then
					if (type (value) == "table") then
						t1 [key] = t1 [key] or {}
						-- add hashID to the hook-data
						t1 [key].scriptId = tostring(value) -- keep this internal hashed

						--create UID if it does not exist --TODO maybe not needed in the future
						local uID = value.UID
						if not uID then
							local seed = tonumber(value.Time) or time()
							while seeds[seed] do
								seed = math.random(value.Time)
							end
							seeds[seed] = true
							
							uID = Plater.CreateUniqueIdentifier(seed)
							--value.UID = uID -- TODO permanently set UID
							t1 [key].UID = uID -- TODO temporary volatile for now
						end
						
						DF.table.copy (t1 [key], t2 [key])
					else
						t1 [key] = value
					end
				end
			end
			return t1
		end
		
		if (scriptType == "script") then
			--cleanup first
			for scriptId, scriptObject in ipairs (Plater.db.profile.script_data) do
				scriptObject.scriptId = nil
			end
			
			--copy
			scripts = copyHookTables({}, Plater.db.profile.script_data)
			
		elseif (scriptType == "hook") then
			--cleanup first
			for scriptId, scriptObject in ipairs (Plater.db.profile.hook_data) do
				scriptObject.scriptId = nil
			end
			
			--copy
			scripts = copyHookTables({}, Plater.db.profile.hook_data)
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
					Plater.CompileScript (scriptObject, noHotReload)
				end
			end
		elseif (scriptType == "hook") then
			--get all hook scripts from the profile database
			for scriptId, scriptObject in ipairs (Plater.GetAllScriptsAsPrioSortedCopy ("hook")) do
				Plater.CompileHook (scriptObject, noHotReload)
			end
		end
	end

	--recompile a single scriptObject deleting the global environment
	function Plater.RecompileScript(scriptObject)
		if not scriptObject.scriptId then
			scriptObject.scriptId = tostring(scriptObject)
		end
		local scriptType = Plater.GetScriptType(scriptObject)
		if (scriptType == "script") then
			Plater.CompileScript(scriptObject)

		elseif (scriptType == "hook") then
			Plater.CompileHook(scriptObject)
		end
	end

	function Plater.IsModEnabled(modName)
		for scriptId, scriptObject in ipairs (Plater.db.profile.hook_data) do
			if (scriptObject.Name == modName) then
				if (scriptObject.Enabled) then
					return true
				end
			end
		end
	end

	--when a script object get disabled, need to clear all compiled scripts in the cache and recompile than again
	--this other scripts that uses the same trigger name get activated
	-- ~scripts

	Plater.CoreVersion = 1
	
	--internal Plater functions
	--in the list/false: can't be overwritten; true->can't be read at all
	local privateFunctions = {
		["Plater"] = {
			["CompileAllScripts"] = true,
			["GetAllScripts"] = true,
			["GetAllScriptsAsPrioSortedCopy"] = true,
			["ScriptMetaFunctions"] = true,
			["DecompressData"] = true,
			["CompressData"] = true,
			["WipeAndRecompileAllScripts"] = true,
			["AllHookGlobalContainers"] = true,
			["WipeHookContainers"] = true,
			["GetContainerForHook"] = true,
			["CurrentlyLoadedHooks"] = true,
			["RunDestructorForHook"] = true,
			["CompileHook"] = true,
			["CompileScript"] = true,
			["CheckScriptTriggerOverlap"] = true,
			["GetScriptObject"] = true,
			["GetScriptDB"] = true,
			["GetScriptType"] = true,
			["GetDecodedScriptType"] = true,
			["ImportScriptsFromLibrary"] = true,
			["ImportScriptString"] = true,
			["AddScript"] = true,
			["BuildScriptObjectFromIndexTable"] = true,
			["DecodeImportedString"] = true,
			["PrepareTableToExport"] = true,
			["ScriptReceivedFromGroup"] = true,
			["ExportScriptToGroup"] = true,
			["ShowImportScriptConfirmation"] = true,
			["DispatchTalentUpdateHookEvent "] = true,
			["ScheduleHookForCombat"] = true,
			["ScheduleRunFunctionForEvent"] = true,
			["RunFunctionForEvent"] = true,
			["EventHandler"] = true,
			["RegisterRefreshDBCallback"] = true,
			["FireRefreshDBCallback"] = true,
			["RefreshDBUpvalues"] = false,
			["RefreshDBLists"] = false,
			["UpdateAuraCache"] = false,
			["ApplyPatches"] = true,
			["RefreshConfig"] = true,
			["RefreshConfigProfileChanged"] = true,
			["SaveConsoleVariables"] = true,
			["GetSettings"] = true,
			["CodeTypeNames"] = true,
			["HookScripts"] = true,
			["HookScriptsDesc"] = true,
			["IncreaseHookBuildID"] = true,
			["IncreaseRefreshID"] = true,
			["IncreaseRefreshID_Auras"] = true,
			["SpecList"] = true,
			["UpdateSettingsCache"] = true,
			["ActorTypeSettingsCache"] = true,
			["RunScheduledUpdate"] = true,
			["ScheduleUpdateForNameplate"] = true,
			["EventHandlerFrame"] = true,
			["OnInit"] = true,
			["HookLoadCallback"] = true,
			["CheckFirstRun"] = true,
			["CommHandler"] = true,
			["CommReceived"] = true,
			["GetAllShownPlates"] = false,
			["GetHashKey"] = false,
			["IsShowingResourcesOnTarget"] = false,
			["OnRetailNamePlateShow"] = true,
			["UpdateSelfPlate"] = true,
			["CastBarOnShow_Hook"] = true,
			["CastBarOnEvent_Hook"] = true,
			["CastBarOnTick_Hook"] = true,
			["RefreshAuras"] = true,
			["CreateAuraIcon"] = true,
			["RefreshColorOverride"] = true,
			["ChangeHealthBarColor_Internal"] = true,
			["UpdateAllPlates"] = true,
			["FullRefreshAllPlates"] = true,
			["UpdatePlateClickSpace"] = true,
			["SetNamePlatePreferredClickInsets"] = true,
			["EveryFrameFPSCheck"] = true,
			["NameplateTick"] = true,
			["OnPlayerTargetChanged"] = true,
			["UpdateTarget"] = true,
			["UpdateSoftInteractTarget"] = true,
			["UpdatePlateText"] = true,
			["CheckLifePercentText"] = true,
			["UpdateAllNames"] = true,
			--["UpdateLevelTextAndColor"] = true,
			["UpdatePlateFrame"] = true,
			["ForceChangeBorderColor"] = true,
			["UpdatePlateBorders"] = true,
			["UpdateRaidMarkersOnAllNameplates"] = true,
			["RefreshAutoToggle"] = true,
			["HasRefreshAutoToggleScheduled"] = true,
			["ParseHealthSettingForPlayer"] = true,
			["CreateAlphaAnimation"] = true,
			["CreateHighlightNameplate"] = true,
			["CreateHealthFlashFrame"] = true,
			["CreateAggroFlashFrame"] = true,
			["CreateScaleAnimation"] = true,
			["DoNameplateAnimation"] = true,
			["RefreshIsEditingAnimations"] = true,
			["IsNpcInIgnoreList"] = true,
			["CanChangePlateSize"] = true,
			["RefreshOmniCCGroup"] = true,
			["CreatePlaterButtonAtInterfaceOptions"] = true,
			["SetCVarsOnFirstRun"] = true,
			["GetActorSubName"] = false,
			["QuestLogUpdated"] = true,
			["GetNpcIDFromGUID"] = false,
			["GetNpcID"] = false,
			["ForceTickOnAllNameplates"] = true,
			["UpdateUIParentScale"] = true,
			["SetNameplateScale"] = false,
			["UpdateUIParentLevels"] = true,
			["UpdateUIParentTargetLevels"] = true,
			["RefreshTankCache"] = true,
			["ToggleThreatColorMode"] = false,
			["ForceFindPetOwner"] = true,
			["UpdateBgPlayerRoleCache"] = false,
			["GetSpecIconForUnitFromBG"] = false,
			["GetUnitBGInfo"] = false,
			["GetSpecIcon"] = false,
			["InitLDB"] = true,
			["APIList"] = true,
			["FrameworkList"] = true,
			["UnitFrameMembers"] = true,
			["NameplateComponents"] = true,
			["UpdateOptionsTabUpdateState"] = true,
			["EnableProfiling"] = false,
			["DisableProfiling"] = false,
			["StartLogPerformance"] = false,
			["EndLogPerformance"] = false,
			["StartLogPerformanceCore"] = false,
			["StartLogPerformanceCore"] = false,
			["EndLogPerformanceCore"] = false,
			["DumpPerformance"] = true,
			["ShowPerfData"] = true,
			["StoreEventLogData"] = true,
			["CheckOptionsTab"] = true,
			["OpenOptionsPanel"] = true,
			["TriggerDefaultMembers"] = true,
			["OpenCopyUrlDialog"] = true,
			["CreateOptionTableForScriptObject"] = true,
			["HasWagoUpdate"] = true,
			["GetWagoUpdateDataFromCompanion"] = true,
			["CheckWagoUpdates"] = true,
			["AddCompanionData"] = true,
			["CompanionDataSlugs"] = true,
			["GetVersionInfo"] = false,
			["versionString"] = false,
			["fullVersionInfo"] = false,
			["DispatchCommReceivedMessageHookEvent"] = true,
			["DispatchCommSendMessageHookEvents"] = true,
			["VerifyScriptIdForComm"] = true,
			["MessageReceivedFromScript"] = true,
			["CreateUniqueIdentifier"] = false,
			["GetScriptFromUID"] = true,
			["SendCommMessage"] = true,
			["CreateCommHeader"] = true,
			["SendComm"] = false,
			["FPSData"] = {
				["startTime"] = true,
				["frames"] = true,
				["platesUpdatedThisFrame"] = true,
				["platesToUpdatePerFrame"] = true,
				["curFPS"] = false,
			},
			["UnitReaction"] = {
				["UNITREACTION_HOSTILE"] = false,
				["UNITREACTION_NEUTRAL"] = false,
				["UNITREACTION_FRIENDLY"] = false,
			},
			["Export_NpcColors"] = true,
			["Export_CastColors"] = true,
			["ScriptAura"] = true,
			["ScriptCastBar"] = true,
			["ScriptUnit"] = true,
			["RemoveFromAuraUpdate"] = true,
			["AddToAuraUpdate"] = true,
			["AnchorSides"] = false,
			["SetAnchor"] = false,
			["RunScriptTriggersForAuraIcons"] = true,
			["AddAura"] = true,
			["GetAuraIcon"] = true,
			["HideNonUsedAuraIcons"] = true,
			["AddExtraIcon"] = true,
			["ResetAuraContainer"] = true,
			["TrackSpecificAuras"] = true,
			["UpdateAuras_Manual"] = true,
			["UpdateAuras_Automatic"] = true,
			["UpdateAuras_Self_Automatic"] = true,
			["GetUnitAuras"] = false,
			["GetUnitAurasForUnitID"] = false,
			["PerformanceUnits"] = true,
			["ForceBlizzardNameplateUnits"] = true,
			["COMM_PLATER_PREFIX"] = true,
			["COMM_SCRIPT_GROUP_EXPORTED"] = true,
			["COMM_SCRIPT_MSG"] = true,
			["Resources"] = {
				["GetResourceWidgetCreationTable"] = true,
				["GetCreateResourceWidgetFunctionForSpecId"] = true,
				["RefreshResourcesDBUpvalues"] = true,
				["CreateMainResourceFrame"] = true,
				["UpdateResourceFrameToUse"] = true,
				["GetMainResourceFrame"] = true,
				["GetResourceBarInUse"] = true,
				["EnableEvents"] = true,
				["DisableEvents"] = true,
				["HidePlaterResourceFrame"] = true,
				["OnSpecChanged"] = true,
				["CanUsePlaterResourceFrame"] = true,
				["UpdateResourceFramePosition"] = true,
				["UpdateMainResourceFrame"] = true,
				["UpdateResourceBar"] = true,
				["UpdateResourcesFor_HideDeplete"] = true,
				["UpdateResourcesFor_ShowDepleted"] = true,
				["UpdateResources_NoDepleted"] = true,
				["UpdateResources_WithDepleted"] = true,
				["GetRuneKeyBySpec"] = true,
				["GetCDEdgeBySpec"] = true,
			},
			["UpdateBaseNameplateOptions"] = true,
			["BossModsTimeBarDBM"] = true,
			["BossModsTimeBarBW"] = true,
			["BigWigs_BarCreated"] = true,
			["UpdateBossModAuras"] = true,
			["EnsureUpdateBossModAuras"] = true,
			["CreateBossModAuraFrame"] = true,
			["UpdateBossModAuraFrameSettings"] = true,
			["RegisterBossModAuras"] = true,
			["GetBossModsEventTimeLeft"] = false,
			["GetAltCastBarAltId"] = false,
			["ClearAltCastBar"] = false,
			["SetAltCastBar"] = false,
			["StopAltCastBar"] = false,
			["GetBossTimer"] = false,
			["RegisterBossModsBars"] = false,
			["TranslateNPCCache"] = true,
		},
		
		["DetailsFramework"] = {
			["SetEnvironment"] = true,
		},

		["WeakAuras"] = {
			["Add"] = true,
			["AddMany"] = true,
			["Delete"] = true,
			["NewAura"] = true,
		},
		
		["C_GuildInfo"] = {
			["RemoveFromGuild"] = true,
		},
		
		
		--block mail, trades, action house, banks
		["C_AuctionHouse"] 	= true,
		["C_Bank"] = true,
		["C_GuildBank"] = true,
		["SetSendMailMoney"] = true,
		["SendMail"]		= true,
		["SetTradeMoney"]	= true,
		["AddTradeMoney"]	= true,
		["PickupTradeMoney"]	= true,
		["PickupPlayerMoney"]	= true,
		["AcceptTrade"]		= true,

		--frames
		["BankFrame"] 		= true,
		["TradeFrame"]		= true,
		["GuildBankFrame"] 	= true,
		["MailFrame"]		= true,
		["EnumerateFrames"] = true,

		--block run code inside code
		["RunScript"] = true,
		["securecall"] = true,
		["getfenv"] = true,
		["getfenv"] = true,
		["loadstring"] = true,
		["pcall"] = true,
		["xpcall"] = true,
		["getglobal"] = true,
		["setmetatable"] = true,
		["DevTools_DumpCommand"] = true,

		--avoid creating/running macros
		["SetBindingMacro"] = true,
		["CreateMacro"] = true,
		["EditMacro"] = true,
		["hash_SlashCmdList"] = true,
		["SlashCmdList"] = true,
		["MacroEditBox"] = true,
		["ChatEdit_SendText"] = true,
		["AreDangerousScriptsAllowed"] = true,

		--block guild commands
		["GuildDisband"] = true,
		["GuildUninvite"] = true,

		--other things
		["C_GMTicketInfo"] = true,

		--deny messing addons with script support
		["PlaterDB"] = true,
		["PlaterDBChr"] = true,
		["_detalhes_global"] = true,
		["WeakAurasSaved"] = true,
	}
	
	local overrideFunctions = {
		["CreateFrame"] = function(frameType, name, parent, template, id)
			if template then
				template = string.gsub(template, "SecureActionButtonTemplate", "")
				template = string.gsub(template, "SecureHandlerClickTemplate", "")
			end
			return CreateFrame(frameType, name, parent, template, id)
		end,
	}
	
	--this allows full shadowing on 'Plater' global with the filter above
	local function buildShadowTable(privateFunctionsTable, tableKey, shadowTable)
		if not privateFunctionsTable then return end
		shadowTable = shadowTable or {}
		
		--ViragDevTool_AddData({privateFunctionsTable, tableKey, shadowTable}, "buildShadowTable")
		local shadowValuesTable = {}
		if tableKey then
			shadowTable[tableKey] = {}
			shadowTable = shadowTable[tableKey]
		end
		--ViragDevTool_AddData({tableKey, shadowValuesTable}, "buildShadowTable_tables")
		for key, value in pairs(privateFunctionsTable) do
			--ViragDevTool_AddData({key, value}, "buildShadowTable_ITER")
			if type(value) == "table" then
				buildShadowTable(value, key, shadowTable)
			else
				--ViragDevTool_AddData({key, value}, "buildShadowTable_ADD")
				shadowValuesTable [key] = value
			end
		end
		
		--ViragDevTool_AddData({shadowValuesTable, tableKey}, "buildShadowTable_SET")
		setmetatable(shadowTable, {
			__index = function (env, key)
				--ViragDevTool_AddData({env, key, tableKey, tableKey and _G[tableKey] or _G}, "GET")
				if key == "_G" then
					return env
				elseif overrideFunctions [key] then
					return overrideFunctions [key]
				elseif shadowValuesTable [key] then -- if true, don't return value
					return nil
				else
					return rawget(tableKey and _G[tableKey] or _G, key)
				end
			end,
			
			__newindex = function (t, k, v)
				--ViragDevTool_AddData({t, k, v, tableKey, tableKey and _G[tableKey] or _G}, "SET")
				if shadowValuesTable [k] ~= nil then -- if in the list: don't overwrite
					error ("'" .. tableKey .. "." .. k .. "' is protected and may not be overwritten.")
				else
					rawset(tableKey and _G[tableKey] or _G, k, v)
				end
			end,
		})
		
		--ViragDevTool_AddData({shadowTable}, "buildShadowTable_return")
		return shadowTable
	end
	
	local ShadowTable = nil
	local getShadowTable = function()
		if not ShadowTable then
			ShadowTable = buildShadowTable(privateFunctions)
		end
		return ShadowTable
	end
	
	local platerModEnvironment = {} -- needed for DF:SetEnvironment to have a common mod/script environment in Plater
	local platerModEnvironment2 = getShadowTable()
	local function SetPlaterEnvironment(func)
		setfenv(func, platerModEnvironment2)
	end

	function Plater.WipeAndRecompileAllScripts (scriptType, noHotReload)
		if (scriptType == "script") then
			Plater.StartLogPerformanceCore("Plater-Core", "Mod/Script", "WipeAndRecompileAllScripts - script")
			
			table.wipe(SCRIPT_AURA_TRIGGER_CACHE)
			table.wipe(SCRIPT_CASTBAR_TRIGGER_CACHE)
			table.wipe(SCRIPT_UNIT_TRIGGER_CACHE)
			Plater.CompileAllScripts (scriptType, noHotReload)
			
			Plater.EndLogPerformanceCore("Plater-Core", "Mod/Script", "WipeAndRecompileAllScripts - script")
			
		elseif (scriptType == "hook") then
			Plater.StartLogPerformanceCore("Plater-Core", "Mod/Script", "WipeAndRecompileAllScripts - hook")
			
			Plater.WipeHookContainers (noHotReload)
			Plater.CompileAllScripts (scriptType, noHotReload)
			
			Plater.EndLogPerformanceCore("Plater-Core", "Mod/Script", "WipeAndRecompileAllScripts - hook")
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
		HOOK_MOD_INITIALIZATION,
		HOOK_COMM_RECEIVED_MESSAGE,
		HOOK_COMM_SEND_MESSAGE,
		HOOK_OPTION_CHANGED,
		HOOK_MOD_OPTION_CHANGED,
		HOOK_NAMEPLATE_DESTRUCTOR,
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
		elseif (hookName == "Deinitialization") then
			return HOOK_MOD_DEINITIALIZATION
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
		elseif (hookName == "Receive Comm Message") then
			return HOOK_COMM_RECEIVED_MESSAGE
		elseif (hookName == "Send Comm Message") then
			return HOOK_COMM_SEND_MESSAGE
		elseif (hookName == "Option Changed") then
			return HOOK_OPTION_CHANGED
		elseif (hookName == "Mod Option Changed") then
			return HOOK_MOD_OPTION_CHANGED
		elseif (hookName == "Destructor") then
			return HOOK_NAMEPLATE_DESTRUCTOR
		else
			Plater:Msg ("Unknown hook: " .. (hookName or "Invalid Hook Name"))
		end
	end

	--store the names of hooks that passed the filters
	Plater.CurrentlyLoadedHooks = {}

	function Plater.RunDestructorForHook (scriptObject)
		--check if the script has a destructor script
		if (scriptObject.Hooks ["Destructor"]) then
			--load and compile the destructor code
			local code = "return " .. scriptObject.Hooks ["Destructor"]
			
			if IS_WOW_PROJECT_NOT_MAINLINE then
				code = string.gsub(code, "\"NamePlateFullBorderTemplate\"", "\"PlaterNamePlateFullBorderTemplate\"")
			end
			
			local compiledScript, errortext = loadstring (code, "Destructor for " .. scriptObject.Name)
			if (not compiledScript) then
				Plater:Msg ("failed to compile destructor for script " .. scriptObject.Name .. ": " .. errortext)
			else
				--store the function to execute
				--setfenv (compiledScript, functionFilter)
				if (Plater.db.profile.shadowMode and Plater.db.profile.shadowMode == 0) then -- legacy mode
					DF:SetEnvironment(compiledScript, nil, platerModEnvironment)
				elseif (not Plater.db.profile.shadowMode or Plater.db.profile.shadowMode == 1) then
					SetPlaterEnvironment(compiledScript)
				end
				
				local func = compiledScript()
				
				--iterate among all nameplates
				for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
					if (plateFrame) then
						
						--local globalScriptObject = HOOK_NAMEPLATE_DESTRUCTOR [scriptObject.scriptId]
						--does not exist when mod is not loaded through load conditions or similar
						local globalScriptObject = HOOK_NAMEPLATE_DESTRUCTOR [scriptObject.scriptId] or {
							HotReload = -1,
							DBScriptObject = scriptObject,
							Build = PLATER_HOOK_BUILD,
						}
						local unitFrame = plateFrame.unitFrame
						local scriptContainer = unitFrame:ScriptGetContainer()
						local scriptInfo = unitFrame:HookGetInfo(globalScriptObject, scriptContainer, "Destructor")

						local okay, errortext = xpcall (func, GetErrorHandler("Mod: |cFFAAAA22" .. scriptInfo.GlobalScriptObject.DBScriptObject.Name .. "|r " .. scriptObject.Name .. " error: ", scriptObject), unitFrame, unitFrame.displayedUnit, unitFrame, scriptInfo.Env, PLATER_GLOBAL_MOD_ENV [scriptInfo.GlobalScriptObject.DBScriptObject.scriptId])
						if (not okay) then
							--handled via error handler
							--Plater:Msg ("Mod: |cFFAAAA22" .. scriptInfo.GlobalScriptObject.DBScriptObject.Name .. "|r " .. scriptObject.Name .. " error: " .. errortext)
						end
					end
				end
			end		
		end
	end
	
	function Plater.RunDeinitializationForHook (scriptObject)
		--check if the script has a destructor script
		if (scriptObject.Hooks ["Deinitialization"]) then
			--load and compile the destructor code
			local code = "return " .. scriptObject.Hooks ["Deinitialization"]
			
			if IS_WOW_PROJECT_NOT_MAINLINE then
				code = string.gsub(code, "\"NamePlateFullBorderTemplate\"", "\"PlaterNamePlateFullBorderTemplate\"")
			end
			
			local compiledScript, errortext = loadstring (code, "Deinitialization for " .. scriptObject.Name)
			if (not compiledScript) then
				Plater:Msg ("failed to compile Deinitialization for script " .. scriptObject.Name .. ": " .. errortext)
			else
				--store the function to execute
				--setfenv (compiledScript, functionFilter)
				if (Plater.db.profile.shadowMode and Plater.db.profile.shadowMode == 0) then -- legacy mode
					DF:SetEnvironment(compiledScript, nil, platerModEnvironment)
				elseif (not Plater.db.profile.shadowMode or Plater.db.profile.shadowMode == 1) then
					SetPlaterEnvironment(compiledScript)
				end
				
				--does not exist when mod is not loaded through load conditions or similar
				local globalScriptObject = HOOK_NAMEPLATE_DESTRUCTOR [scriptObject.scriptId] or {
					HotReload = -1,
					DBScriptObject = scriptObject,
					Build = PLATER_HOOK_BUILD,
				}
				
				globalScriptObject ["Deinitialization"] = compiledScript()
				
				Plater.ScriptMetaFunctions.ScriptRunNoAttach (globalScriptObject, "Deinitialization")

			end		
		end
	end
	
	-- which option types should be copied to modTable.config?
	local options_for_config_table = {
		[1] = true, -- Color
		[2] = true, -- Number
		[3] = true, -- Text
		[4] = true, -- Toggle
		[5] = false, -- Label
		[6] = false, -- Blank Line
		[7] = true, -- List
		[8] = true, -- Audio
	}
	
	--compile scripts from the Hooking tab
	function Plater.CompileHook (scriptObject, noHotReload)
		Plater.StartLogPerformanceCore("Plater-Core", "Mod/Script", "CompileHook")
		
		--check if the script is valid and if is enabled
		if (not scriptObject) then
			Plater.EndLogPerformanceCore("Plater-Core", "Mod/Script", "CompileHook")
			return
		end
		
		if not scriptObject.scriptId then
			scriptObject.scriptId = tostring(scriptObject)
		end
		
		--check if this hook is currently loaded
		if (not scriptObject.Enabled) then
			if (Plater.CurrentlyLoadedHooks [scriptObject.scriptId]) then
				Plater.CurrentlyLoadedHooks [scriptObject.scriptId] = false
				Plater.RunDestructorForHook (scriptObject)
				Plater.RunDeinitializationForHook (scriptObject)
			end
			--clear env when disabling/disabled
			PLATER_GLOBAL_MOD_ENV [scriptObject.scriptId] = nil
			Plater.EndLogPerformanceCore("Plater-Core", "Mod/Script", "CompileHook")
			return
		end
		
		do --check integrity
			if (not scriptObject.Name) then
				Plater:Msg ("fail to load mod: " .. (scriptObject.Name or "") .. ".")
				Plater.EndLogPerformanceCore("Plater-Core", "Mod/Script", "CompileHook")
				return
			end

			if (not scriptObject.LoadConditions) then
				Plater:Msg ("fail to load mod: " .. (scriptObject.Name or "") .. ".")
				Plater.EndLogPerformanceCore("Plater-Core", "Mod/Script", "CompileHook")
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
				Plater.EndLogPerformanceCore("Plater-Core", "Mod/Script", "CompileHook")
				return
			end

			if (not scriptObject.Hooks) then
				Plater:Msg ("fail to load mod: " .. (scriptObject.Name or "") .. ".")
				Plater.EndLogPerformanceCore("Plater-Core", "Mod/Script", "CompileHook")
				return
			end
		end
		
		--check if can load this hook
		if (not DF:PassLoadFilters (scriptObject.LoadConditions, Plater.EncounterID)) then
			--check if this hook is currently loaded
			if (Plater.CurrentlyLoadedHooks [scriptObject.scriptId]) then
				Plater.CurrentlyLoadedHooks [scriptObject.scriptId] = false
				Plater.RunDestructorForHook (scriptObject)
				Plater.RunDeinitializationForHook (scriptObject)
			end
			if not noHotReload then
				--clear env if needed
				PLATER_GLOBAL_MOD_ENV [scriptObject.scriptId] = nil
			end
			Plater.EndLogPerformanceCore("Plater-Core", "Mod/Script", "CompileHook")
			return
		else
			Plater.CurrentlyLoadedHooks [scriptObject.scriptId] = true
		end
		
		if not noHotReload then
			--clear env if needed
			PLATER_GLOBAL_MOD_ENV [scriptObject.scriptId] = nil
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
			scriptId = scriptObject.scriptId,
		}
		
		--init modEnv if necessary
		local needsInitCall = false
		if (not PLATER_GLOBAL_MOD_ENV [scriptObject.scriptId]) then
			needsInitCall = true
			PLATER_GLOBAL_MOD_ENV [scriptObject.scriptId] = {
				config = {}
			}
		end

		--copy options to global env
		-- ensure options are valid:
		Plater.CreateOptionTableForScriptObject(scriptObject)
		local scriptOptions = scriptObject.Options
		local scriptOptionsValues = scriptObject.OptionsValues

		for i = 1, #scriptOptions do
			local thisOption = scriptOptions[i]
			if (options_for_config_table[thisOption.Type]) then
				if (type(scriptOptionsValues[thisOption.Key]) == "boolean") then
					PLATER_GLOBAL_MOD_ENV [scriptObject.scriptId].config[thisOption.Key] = scriptOptionsValues[thisOption.Key]

				elseif (thisOption.Type == 7) then --list type
					--check if the options is a list
					
					--build default values if needed
					if not scriptOptionsValues[thisOption.Key] then
						scriptOptionsValues[thisOption.Key] = DF.table.copy({}, thisOption.Value)
					end
					
					--build a hash table with the entries in the list
					local hashTable = {}
					for index, entryTable in ipairs(scriptOptionsValues[thisOption.Key]) do
						local key = entryTable[1]
						local value = entryTable[2]
						hashTable[key] = value
					end

					PLATER_GLOBAL_MOD_ENV [scriptObject.scriptId].config[thisOption.Key] = hashTable
				else
					PLATER_GLOBAL_MOD_ENV [scriptObject.scriptId].config[thisOption.Key] = scriptOptionsValues[thisOption.Key] or thisOption.Value
				end
			end
		end
		
		--compile
		for hookName, code in pairs (scriptCode) do
			
			local globalScriptContainer = Plater.GetContainerForHook (hookName)
			
			if (type (code) ~= "string") then
				Plater:Msg ("fail to load mod: " .. (scriptObject.Name or "") .. ".")
				Plater.EndLogPerformanceCore("Plater-Core", "Mod/Script", "CompileHook")
				return
			end
			
			if IS_WOW_PROJECT_NOT_MAINLINE then
				code = string.gsub(code, "\"NamePlateFullBorderTemplate\"", "\"PlaterNamePlateFullBorderTemplate\"")
			end

			--find occurences of Plater.SendComm(arg1, arg2, arg3, ...) and replace with Plater.SendComm_Internal(uniqueIdentifier, arg1, arg2, arg3, ...) or fail to compile for all than "Send Comm Message" and don't replace (use empty dummy)
			if hookName == "Send Comm Message" then
				code = string.gsub(code, "Plater.SendComm%s*%(", "Plater.SendComm(" .. globalScriptContainer.ScriptAmount + 1 .. ", \"" .. scriptObject.scriptId .. "\", \"" .. scriptObject.UID .. "\", ")
			else
				local foundSendComm = string.find(code, "Plater.SendComm")
				if foundSendComm then
					Plater:Msg ("failed to compile " .. hookName .. " for script " .. scriptObject.Name .. ": " .. "Usage of 'Plater.SendComm' is only allowed in 'Send Comm Message' hook.")
				end
			end
			
			local compiledScript, errortext = loadstring (code, "" .. hookName .. " for " .. scriptObject.Name)
			if (not compiledScript) then
				Plater:Msg ("failed to compile " .. hookName .. " for script " .. scriptObject.Name .. ": " .. errortext)
			else
				--setfenv (compiledScript, functionFilter)
				if (Plater.db.profile.shadowMode and Plater.db.profile.shadowMode == 0) then -- legacy mode
					DF:SetEnvironment(compiledScript, nil, platerModEnvironment)
				elseif (not Plater.db.profile.shadowMode or Plater.db.profile.shadowMode == 1) then
					SetPlaterEnvironment(compiledScript)
				end
				
				--store the function to execute inside the global script object
				globalScriptObject [hookName] = compiledScript()
				
				--insert the script in the global script container, remove existing, as option changes re-compile only single mod without wipe
				local isReplace = false
				for i, curScriptObject in ipairs(globalScriptContainer) do
					if scriptObject.scriptId == curScriptObject.scriptId then
						tremove(globalScriptContainer, i)
						isReplace = true
					end
				end
				tinsert (globalScriptContainer, globalScriptObject)
				globalScriptContainer.ScriptAmount = globalScriptContainer.ScriptAmount + (isReplace and 0 or 1)
				
				if (hookName == "Constructor") then
					globalScriptObject.HasConstructor = true
				elseif (hookName == "Initialization") and needsInitCall then
					Plater.ScriptMetaFunctions.ScriptRunNoAttach (globalScriptObject, "Initialization")
				end
			end
		end
		
		Plater.EndLogPerformanceCore("Plater-Core", "Mod/Script", "CompileHook")
	end

	--compile scripts from the Scripting tab
	function Plater.CompileScript(scriptObject, noHotReload, ...)
		Plater.StartLogPerformanceCore("Plater-Core", "Mod/Script", "CompileScript")
		
		--check if the script is valid and if is enabled
		if (not scriptObject) then
			Plater.EndLogPerformanceCore("Plater-Core", "Mod/Script", "CompileScript")
			return
		elseif (not scriptObject.Enabled) then
			Plater.EndLogPerformanceCore("Plater-Core", "Mod/Script", "CompileScript")
			return
		end
		
		if (not scriptObject.scriptId) then
			scriptObject.scriptId = tostring(scriptObject)
		end

		--clear env on re-compilation if necessary
		if (not noHotReload) then
			PLATER_GLOBAL_SCRIPT_ENV[scriptObject.scriptId] = nil
		end
		
		--store the scripts to be compiled
		local scriptCode, scriptFunctions = {}, {}
		
		--get scripts passed
		for i = 1, select ("#",...) do
			scriptCode[Plater.CodeTypeNames [i]] = "return " .. select(i, ...)
		end
		
		--get scripts which wasn't passed
		for i = 1, #Plater.CodeTypeNames do
			local scriptType = Plater.CodeTypeNames[i]
			-- ensure init is filled always, 5 is the index where the init code is
			if (not scriptObject[scriptType] and i == 5) then
				scriptObject[scriptType] = [=[
					function (scriptTable)
						--insert code here
						
					end
				]=]	
			end
			if (not scriptCode[scriptType]) then
				scriptCode[scriptType] = "return " .. scriptObject[scriptType]
			end
		end
		
		--init modEnv if necessary
		local needsInitCall = false
		if (not PLATER_GLOBAL_SCRIPT_ENV[scriptObject.scriptId]) then
			needsInitCall = true
			PLATER_GLOBAL_SCRIPT_ENV[scriptObject.scriptId] = {
				config = {}
			}
		end

		--copy options to global env and ensure options are valid
		Plater.CreateOptionTableForScriptObject(scriptObject)
		local scriptOptions = scriptObject.Options
		local scriptOptionsValues = scriptObject.OptionsValues

		for i = 1, #scriptOptions do
			local thisOption = scriptOptions[i]
			if (options_for_config_table[thisOption.Type]) then
				if (type(scriptOptionsValues[thisOption.Key]) == "boolean") then
					PLATER_GLOBAL_SCRIPT_ENV [scriptObject.scriptId].config[thisOption.Key] = scriptOptionsValues[thisOption.Key]

				elseif (thisOption.Type == 7) then --check if the options is a list
					--build default values if needed
					if not scriptOptionsValues[thisOption.Key] then
						scriptOptionsValues[thisOption.Key] = DF.table.copy({}, thisOption.Value)
					end
					
					--build a hash table with the entries in the list
					local hashTable = {}
					for index, entryTable in ipairs(scriptOptionsValues[thisOption.Key]) do
						local key = entryTable[1]
						local value = entryTable[2]
						hashTable[key] = value
					end

					PLATER_GLOBAL_SCRIPT_ENV [scriptObject.scriptId].config[thisOption.Key] = hashTable
				else
					PLATER_GLOBAL_SCRIPT_ENV [scriptObject.scriptId].config[thisOption.Key] = scriptOptionsValues[thisOption.Key] or thisOption.Value
				end
			end
		end

		--compile
		for scriptType, code in pairs(scriptCode) do
			if (IS_WOW_PROJECT_NOT_MAINLINE) then
				code = string.gsub(code, "\"NamePlateFullBorderTemplate\"", "\"PlaterNamePlateFullBorderTemplate\"")
			end
			
			local compiledScript, errortext = loadstring(code, "" .. scriptType .. " for " .. scriptObject.Name)
			if (not compiledScript) then
				Plater:Msg ("failed to compile " .. scriptType .. " for script " .. scriptObject.Name .. ": " .. errortext)
			else
				--get the function to execute
				--setfenv(compiledScript, functionFilter) deprecated
				if (Plater.db.profile.shadowMode and Plater.db.profile.shadowMode == 0) then --legacy mode
					DF:SetEnvironment(compiledScript, nil, platerModEnvironment)

				elseif (not Plater.db.profile.shadowMode or Plater.db.profile.shadowMode == 1) then
					SetPlaterEnvironment(compiledScript)
				end

				--extract the function
				scriptFunctions[scriptType] = compiledScript()
			end
		end
		
		--trigger container is the table with spellIds for auras and/or spellcast
		--triggerId is the spellId converted to spellName or the unitName in case of a Unit name
		local triggerContainer, triggerId
		if (scriptObject.ScriptType == 1 or scriptObject.ScriptType == 2) then --aura or castbar
			triggerContainer = "SpellIds"

		elseif (scriptObject.ScriptType == 3) then --unit name
			triggerContainer = "NpcNames"
		end
		
		for i = 1, #scriptObject[triggerContainer] do
			local triggerId = scriptObject[triggerContainer][i]
			
			--if the trigger is using spellId, check if the spell exists
			if (scriptObject.ScriptType == 1 or scriptObject.ScriptType == 2) then
				if (type(triggerId) == "number") then
					triggerId = GetSpellInfo(triggerId)
					if (not triggerId) then
						if IS_WOW_PROJECT_MAINLINE then -- disable this in classic for now... too spammy
							--just ignore, the spell on trigger list will be blank with a remove trigger button
							--Plater:Msg ("failed to get the spell name for spellId: " .. (scriptObject [triggerContainer] [i] or "invalid spellId") .. " for script '" .. scriptObject.Name .. "', the spell has been removed from the triggers.")
						end
					end
				end
			
			elseif (scriptObject.ScriptType == 3) then --unit names
				--cast the string to number to see if it's a npcId
				triggerId = tonumber(triggerId) or triggerId
				
				--if is a unit name, make it be in lower case
				if (type(triggerId) == "string") then
					triggerId = triggerId:lower()
				end
			end

			if (triggerId) then
				--get the global script object table
				local triggerCacheTable
				
				if (scriptObject.ScriptType == 1) then
					triggerCacheTable = SCRIPT_AURA_TRIGGER_CACHE
				elseif (scriptObject.ScriptType == 2) then
					triggerCacheTable = SCRIPT_CASTBAR_TRIGGER_CACHE
				elseif (scriptObject.ScriptType == 3) then
					triggerCacheTable = SCRIPT_UNIT_TRIGGER_CACHE
				end
				
				local globalScriptObject = triggerCacheTable[triggerId]
				
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

					--insert the table just created inthe the triggerCacheTable
					triggerCacheTable[triggerId] = globalScriptObject
					
				else --hot reload and update
					globalScriptObject.HotReload = globalScriptObject.HotReload + 1
					globalScriptObject.DBScriptObject = scriptObject
				end

				globalScriptObject.LastUpdateTime = GetTime()-0.05
				
				--add the script functions to the global object table
				for scriptType, func in pairs(scriptFunctions) do
					globalScriptObject[scriptType] = func
				end
				
				--run initialization (once)
				if (needsInitCall) then
					Plater.ScriptMetaFunctions.ScriptRunInitialization(globalScriptObject)
					needsInitCall = false
				end
			end
		end
		
		Plater.EndLogPerformanceCore("Plater-Core", "Mod/Script", "CompileScript")
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

	---add a trigger to a script
	---@param triggerId number|string triggerId can be a npcId, npcName for NPCs or a spellId or spellName for auras and casts
	---@param triggerType string|number there's 3 types of triggers: Auras, Casts and Npcs. Auras and Casts uses 'scriptObject.SpellIds' to store the triggerId and Npcs uses 'scriptObject.NpcNames'
	---what define the type of trigger is the scriptObject.ScriptType, in other places of this project, triggerType can also be called scriptType
	---triggerType expects: aura = 1, cast = 2, npc = 3
	---@param scriptName string
	---@return boolean 'true' if the trigger was added to the script, false if something went wrong
	---@return string|nil message of error if the trigger wasn't added to the script
	function Plater.AddTriggerToScript(triggerId, triggerType, scriptName)
		--attempt to get the scriptObject for the passed scriptName
		local scriptObject = Plater.GetScriptObject(scriptName, "script")
		if (not scriptObject) then
			return false, "script not found"
		end
		
		--remove the trigger from any script to avoid overlaps (a trigger can only exists in one script at time)
		platerInternal.Scripts.RemoveTriggerFromAnyScript(triggerId)

		--check the triggerType to know in what table the script will store the triggerId
		if (triggerType == 1 or triggerType == 2 or triggerType == "aura" or triggerType == "cast") then
			--aura or cast
			DF.table.addunique(scriptObject.SpellIds, triggerId)

		elseif (triggerType == 3 or triggerType == "npc") then
			--npc
			DF.table.addunique(scriptObject.NpcNames, triggerId)

		else
			return false, "invalid triggerType"
		end
		
		Plater.WipeAndRecompileAllScripts("script")

		return true
	end

	function platerInternal.Scripts.RemoveTriggerFromAnyScript(triggerId)
		local scriptObject = platerInternal.Scripts.IsTriggerOnAnyScript(triggerId)
		if (scriptObject) then
			platerInternal.Scripts.RemoveTriggerFromScript(scriptObject, triggerId)
		end
	end

	function platerInternal.Scripts.IsTriggerOnAnyScript(triggerId)
		local allScripts = Plater.db.profile.script_data
		for i = 1, #allScripts do
			local scriptObject = allScripts[i]
			if (platerInternal.Scripts.DoesScriptHasTrigger(scriptObject, triggerId)) then
				return scriptObject
			end
		end
	end

	function platerInternal.Scripts.GetScriptObjectByName(scriptName)
		local allScripts = Plater.db.profile.script_data
		for i = 1, #allScripts do
			local scriptObject = allScripts[i]
			if (scriptObject.Name == scriptName) then
				return scriptObject
			end
		end
	end

	--add or remove a trigger without the need to pass through the scripting panel
	function platerInternal.Scripts.AddSpellToScriptTriggers(scriptObject, spellId)
		DF.table.addunique(scriptObject.SpellIds, spellId)
		Plater.WipeAndRecompileAllScripts("script")
	end

	function platerInternal.Scripts.RemoveSpellFromScriptTriggers(scriptObject, spellId, noRecompile)
		local index = DF.table.find(scriptObject.SpellIds, spellId)
		if (index) then
			tremove(scriptObject.SpellIds, index)

			if (not noRecompile) then
				Plater.WipeAndRecompileAllScripts("script")
			end
		end
	end

	function platerInternal.Scripts.DoesScriptHasTrigger(scriptObject, trigger)
		local index = DF.table.find(scriptObject.SpellIds, trigger)
		if (index) then
			return true
		end

		local index = DF.table.find(scriptObject.NpcNames, trigger)
		if (index) then
			return true
		end
	end

	function platerInternal.Scripts.RemoveTriggerFromScript(scriptObject, triggerId)
		local index = DF.table.find(scriptObject.SpellIds, triggerId)
		if (index) then
			tremove(scriptObject.SpellIds, index)
			Plater.WipeAndRecompileAllScripts("script")
		end

		local index = DF.table.find(scriptObject.NpcNames, triggerId)
		if (index) then
			tremove(scriptObject.NpcNames, index)
			Plater.WipeAndRecompileAllScripts("script")
		end
	end

	function platerInternal.Scripts.AddNpcToScriptTriggers(scriptObject, npcId)
		DF.table.addunique(scriptObject.NpcNames, npcId)
		Plater.WipeAndRecompileAllScripts("script")
	end

	function platerInternal.Scripts.RemoveNpcFromScriptTriggers(scriptObject, npcId)
		local index = DF.table.find(scriptObject.NpcNames, npcId)
		if (index) then
			tremove(scriptObject.NpcNames, index)
			Plater.WipeAndRecompileAllScripts("script")
		end
	end

	---retrive the script object for a selected scriptId
	---@param scriptID number|string if number scriptId is the index of the script in the db table, this index can change when a script is removed
	---@param scriptType string is always "script" or "hook", hooks scripts are stored in a different table, ingame they are called "Mods"
	function Plater.GetScriptObject (scriptID, scriptType)
		if (type(scriptID) == "string" and scriptType == "script") then
			return platerInternal.Scripts.GetScriptObjectByName(scriptID)
		end

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

	function Plater.DispatchCommReceivedMessageHookEvent(scriptUID, source, ...)
		if (HOOK_COMM_RECEIVED_MESSAGE.ScriptAmount > 0) then
			for i = 1, HOOK_COMM_RECEIVED_MESSAGE.ScriptAmount do
				local globalScriptObject = HOOK_COMM_RECEIVED_MESSAGE[i]
				
				if (globalScriptObject.DBScriptObject.UID == scriptUID) then
					--run
					Plater.ScriptMetaFunctions.ScriptRunCommMessageHook(globalScriptObject, "Receive Comm Message", source, ...)
				end
			end
		end
	end
	
	function Plater.DispatchCommSendMessageHookEvents()
		if (HOOK_COMM_SEND_MESSAGE.ScriptAmount > 0) then
			for i = 1, HOOK_COMM_SEND_MESSAGE.ScriptAmount do
				local globalScriptObject = HOOK_COMM_SEND_MESSAGE[i]
				
				--run
				Plater.ScriptMetaFunctions.ScriptRunCommMessageHook(globalScriptObject, "Send Comm Message")
			end
		end
	end
	
	function Plater.VerifyScriptIdForComm(scriptIndex, scriptId, uniqueId)
		if not scriptIndex or not scriptId or not uniqueId then return end
		
		local globalScriptObject = HOOK_COMM_SEND_MESSAGE[scriptIndex]
		if globalScriptObject and globalScriptObject.DBScriptObject and globalScriptObject.DBScriptObject.scriptId and globalScriptObject.DBScriptObject.scriptId == scriptId and globalScriptObject.DBScriptObject.UID and globalScriptObject.DBScriptObject.UID == uniqueId then
			return true
		end
		
		return false
	end

	function Plater.DispatchTalentUpdateHookEvent()
		if (HOOK_PLAYER_TALENT_UPDATE.ScriptAmount > 0) then
			for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
				if (plateFrame and plateFrame.unitFrame.PlaterOnScreen) then
					for i = 1, HOOK_PLAYER_TALENT_UPDATE.ScriptAmount do
						local globalScriptObject = HOOK_PLAYER_TALENT_UPDATE [i]
						local unitFrame = plateFrame.unitFrame
						if not plateFrame.unitFrame.PlaterOnScreen then
							return
						end
						local scriptContainer = unitFrame:ScriptGetContainer()
						local scriptInfo = unitFrame:HookGetInfo(globalScriptObject, scriptContainer, "Player Talent Update")
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
						if not plateFrame.unitFrame.PlaterOnScreen then
							return
						end
						local scriptContainer = unitFrame:ScriptGetContainer()
						local scriptInfo = unitFrame:HookGetInfo(globalScriptObject, scriptContainer, "Enter Combat")
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
						if not plateFrame.unitFrame.PlaterOnScreen then
							return
						end
						local scriptContainer = unitFrame:ScriptGetContainer()
						local scriptInfo = unitFrame:HookGetInfo(globalScriptObject, scriptContainer, "Leave Combat")
						--run
						unitFrame:ScriptRunHook (scriptInfo, "Leave Combat")
					end
				end
			end
		end
	end	





