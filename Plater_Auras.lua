
local Plater = _G.Plater
local DF = _G.DetailsFramework
local addonName, platerInternal = ...
local _ = nil

local IS_WOW_PROJECT_MAINLINE = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
local IS_WOW_PROJECT_NOT_MAINLINE = WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE
local IS_WOW_PROJECT_CLASSIC_ERA = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
local IS_WOW_PROJECT_MIDNIGHT = DF.IsAddonApocalypseWow()
--local IS_WOW_PROJECT_MIDNIGHT = DF.IsMidnightWowAPI()
local IS_WOW_PROJECT_MIDNIGHT_API = DF.IsMidnightWowAPI()
local IS_WOW_PROJECT_MIDNIGHT_API_WITH_AURA_CONTAINERS = C_XMLUtil and C_XMLUtil.GetTemplateInfo and C_XMLUtil.GetTemplateInfo("CustomAuraContainerTemplate") and true or false

--stop yellow lines on my editor
local tinsert = _G.tinsert
local min = _G.min
local max = _G.max
local abs = _G.abs
local G_CreateFrame = _G.CreateFrame


local CreateFrame = function (frameType , name, parent, template, id)
	local frame = G_CreateFrame(frameType , name, parent, template, id)
	DF:Mixin(frame, DF.FrameFunctions)
	
	if frame.ApplyBackdrop then
		NineSliceUtil.DisableSharpening(frame)
	end
	
	return frame
end
local unpack = _G.unpack
local CooldownFrame_Set = _G.CooldownFrame_Set
local GetTime = _G.GetTime
local UnitClass = _G.UnitClass
local UnitPlayerControlled = _G.UnitPlayerControlled
local UnitName = _G.UnitName
local wipe = _G.wipe
local UnitIsUnit = _G.UnitIsUnit
local UnitGUID = _G.UnitGUID
local GetSpellInfo = GetSpellInfo or function(spellID) if not spellID then return nil end local si = C_Spell.GetSpellInfo(spellID) if si then return si.name, nil, si.iconID, si.castTime, si.minRange, si.maxRange, si.spellID, si.originalIconID end end
local floor = _G.floor
local UnitAuraBySlot = _G.UnitAuraBySlot or (C_UnitAuras and (function(...) local auraData = C_UnitAuras.GetAuraDataBySlot(...); if not auraData then return nil; end; return AuraUtil.UnpackAuraData(auraData); end))
local GetAuraDataBySlot = _G.C_UnitAuras and _G.C_UnitAuras.GetAuraDataBySlot
local GetAuraSlots = _G.C_UnitAuras and _G.C_UnitAuras.GetAuraSlots
local GetAuraDataByAuraInstanceID = _G.C_UnitAuras and _G.C_UnitAuras.GetAuraDataByAuraInstanceID
local BackdropTemplateMixin = _G.BackdropTemplateMixin
local BUFF_MAX_DISPLAY_PLATER = nil -- don't limit.
--size of the pandemic glow relative to the aura icon
local CONST_PANDEMIC_GLOW_SCALE = 1.4
--the dispel glow texture is drawn in texture pixels, this brings it down to nameplate size
local CONST_DISPEL_GLOW_SCALE = 0.6
--thickness of the dispel border style, in dispel glow units (scaled by CONST_DISPEL_GLOW_SCALE)
local CONST_DISPEL_BORDER_SIZE = 3
--the dispel ants style: amount of dots, seconds for one round and the size of a dot in health bar pixels at glow size 1
local CONST_DISPEL_ANTS_AMOUNT = 16
local CONST_DISPEL_ANTS_DURATION = 6
local CONST_DISPEL_ANTS_SIZE = 3
--lines of the dispel pixel glow, the max of its lines option
local CONST_DISPEL_PIXEL_MAX_LINES = 30
--size of the mask showing the dispel pixel glow, in dispel glow units. a square far bigger than any health bar
local CONST_DISPEL_PIXEL_MASK_SIZE = 4000
--aura container sets (one per nameplate, 3 containers each) for the 40 nameplates max plus a spare. built with their aura groups
--behind the loading screen, each costs ~40ms and ~100 aura buttons
local CONST_MAX_AURA_CONTAINER_SETS = 41
--height of a slot frame of the per aura healthbar colors, more than twice the height of any health bar. the masks are half of it
local CONST_AURA_COLOR_SLOT_HEIGHT = 400
--width of the masks of the per aura healthbar colors, wider than any health bar
local CONST_AURA_COLOR_MASK_WIDTH = 2000

local DB_AURA_GROW_DIRECTION
local DB_AURA_GROW_DIRECTION2
local DB_AURA_PADDING
local DB_AURA_SEPARATE_BUFFS
local DB_SHOW_PURGE_IN_EXTRA_ICONS
local DB_SHOW_ENRAGE_IN_EXTRA_ICONS
local DB_SHOW_MAGIC_IN_EXTRA_ICONS
local DB_AURA_SHOW_IMPORTANT
local DB_AURA_SHOW_RAID
local DB_AURA_SHOW_BYPLAYER
local DB_AURA_SHOW_DEBUFF_BYPLAYER
local DB_AURA_SHOW_AS_BLIZZARD
local DB_AURA_SHOW_BUFFS_AS_BLIZZARD
local DB_AURA_SHOW_BUFF_BYPLAYER
local DB_AURA_SHOW_BYOTHERPLAYERS
local DB_AURA_SHOW_BYOTHERNPCS
local DB_AURA_SHOW_DISPELLABLE
local DB_AURA_SHOW_ONLY_SHORT_DISPELLABLE_ON_PLAYERS
local DB_AURA_SHOW_ENRAGE
local DB_AURA_SHOW_MAGIC
local DB_AURA_SHOW_BUFFBYUNIT
local DB_AURA_SHOW_DEBUFFBYUNIT
local DB_AURA_SHOW_BUFFENEMYNPC
local DB_AURA_ALPHA
local DB_AURA_ENABLED
local DB_AURA_GHOSTAURA_ENABLED
local DB_TRACK_METHOD

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

local DebuffTypeColor = _G.DebuffTypeColor

--> As accessible translator map (where nil needs to resemble "NONE") for modding/scripting to be published in .AuraType:
local AURA_TYPES = {
	[""] = "enrage",
	["Magic"] = "magic",
	["Poison"] = "poison",
	["Curse"] = "curse",
	["nil"] = "none",
}
local DEBUFF_DISPLAY_COLOR_INFO = {
	[0] = DEBUFF_TYPE_NONE_COLOR,
	[1] = DEBUFF_TYPE_MAGIC_COLOR,
	[2] = DEBUFF_TYPE_CURSE_COLOR,
	[3] = DEBUFF_TYPE_DISEASE_COLOR,
	[4] = DEBUFF_TYPE_POISON_COLOR,
	[9] = DEBUFF_TYPE_BLEED_COLOR, -- enrage
	[11] = DEBUFF_TYPE_BLEED_COLOR,
}
local dispelColorCurve = C_CurveUtil and C_CurveUtil.CreateColorCurve() --TODO: correct colors! MIDNIGHT!!
local pandemicColorCurve = C_CurveUtil and C_CurveUtil.CreateColorCurve()
local timeFormatter = C_StringUtil.CreateNumericRuleFormatter()
function Plater.RefreshAuarasCurves()

	if dispelColorCurve then
		dispelColorCurve:SetType(Enum.LuaCurveType.Step)
		for i, c in pairs(DEBUFF_DISPLAY_COLOR_INFO) do
			dispelColorCurve:AddPoint(i, c)
		end
	end

	if pandemicColorCurve then
		pandemicColorCurve:SetType(Enum.LuaCurveType.Step)
		pandemicColorCurve:AddPoint(0, CreateColor(1, 0, 0, 1))
		pandemicColorCurve:AddPoint(15, CreateColor(1, 0.5, 0, 1))
		pandemicColorCurve:AddPoint(30, CreateColor(1, 1, 1, 1))
	end

	if timeFormatter then
		if Plater.db.profile.aura_timer_decimals then
			timeFormatter:AddBreakpoint({
			threshold = 0,
			step = 0.1,
			format = "%.1f",
			})
			timeFormatter:AddBreakpoint({
				threshold = 5,
				step = 1,
				format = "%d",
			})
		else
			timeFormatter:AddBreakpoint({
				threshold = 0,
				step = 1,
				format = "%d",
			})
		end
		timeFormatter:AddBreakpoint({
			threshold = 60,
			format = "%d:%02d",
			components = {
				{
					div = 60,
				},
				{
					mod = 60,
				},
			}
		})
		timeFormatter:AddBreakpoint({
			threshold = 180,
			format = "%dm",
			components = {
				{
					div = 60,
					step = 1,
				},
			}
		})
	end
end

--> Aura types for usage in AddAura / AddExtraIcon checks
local AURA_TYPE_ENRAGE = "" -- yes, 'enrage' is just empty string for Blizzard...
local AURA_TYPE_MAGIC = "Magic"
local AURA_TYPE_DISEASE = "Disease"
local AURA_TYPE_POISON = "Poison"
local AURA_TYPE_CURSE = "Curse"
local AURA_TYPE_UNKNOWN = nil

local PLATER_REFRESH_ID = 1
function Plater.IncreaseRefreshID_Auras()
    PLATER_REFRESH_ID = PLATER_REFRESH_ID + 1
end

local SCRIPT_AURA_TRIGGER_CACHE = Plater.ScriptAura
--local SCRIPT_CASTBAR = Plater.ScriptCastBar
--local SCRIPT_UNIT = Plater.ScriptUnit

--caches auras for crowd control, offensives and defensives to determine the border color for special auras, if the aura is in this table, the border will be colored with the respective color
local CROWDCONTROL_AURA_IDS = {}
local OFFENSIVE_AURA_IDS = {}
local DEFENSIVE_AURA_IDS = {}
--list of auras Plater added automatically to special auras, automatic added auras passes throught black list filters while auras manually added by the user do no
local SPECIAL_AURAS_AUTO_ADDED = {}
--list of auras the user added into the track list for special auras, _MINE caches the auras where the user checked the 'Only Mine' checkbox
local SPECIAL_AURAS_USER_LIST = {}
local SPECIAL_AURAS_USER_LIST_MINE = {}

--store aura names to manually track
local MANUAL_TRACKING_BUFFS = {}
local MANUAL_TRACKING_DEBUFFS = {}
local AUTO_TRACKING_EXTRA_BUFFS = {}
local AUTO_TRACKING_EXTRA_DEBUFFS = {}
--spell names used by the per aura healthbar colors, expandAuraCaches() resolves them into spell ids
local AURA_COLORS = {}

--debuffs the player can apply several copies of to one target under the same spell id
--with 'aura_consolidate' enabled, the aura containers show a single icon for each of them
local CONSOLIDATED_DEBUFFS = {
	[55078] = true, --blood plague
}

--blacklists
local DB_DEBUFF_BANNED
local DB_BUFF_BANNED

--cache
local DB_AURA_NAME_CACHE

--Cache for ghost auras
--Updated on function: Plater.UpdateGhostAurasCache()
local GHOSTAURAS = {}

--extra auras namespace ~extraaura
--Plater does not have a list of saved extra auras, these are added and removed on the fly from scripts and mods
--These auras only live for its expirationTime, after that it need another Add() call to add it again
platerInternal.ExtraAuras = {
	--only store unitFrames whith an extra aura
	unitFramesToGUID = {}
}

platerInternal.Auras = {
	spellCaches = {
		allIDsByName = {},
	},
	spellCachesLoaded = false,
	spellCachesLoading = false,
}
Plater.SpellCaches = platerInternal.Auras.spellCaches

local spellBlacklist = { -- some spells just crash PTR/beta clients... add them here
	[255616] = true,
	[1249911] = true,
	[1251678] = true,
	[1251535] = true,
}

-- Spell Caches
local expandAuraCaches
local lazyBuildSpellCache
local spellCacheCallbacks = {}
-- Spell Cache init
lazyBuildSpellCache = function(start)
	platerInternal.Auras.spellCachesLoading = true
	platerInternal.Auras.spellCachesLoaded = false
	local startPoint = start or 1
	local endPoint = startPoint + 1500
	local i = startPoint

	local toLowerCase = string.lower
	local GetSpellInfo = GetSpellInfo

	local allSpellsSameName = platerInternal.Auras.spellCaches.allIDsByName

	local curTime = debugprofilestop()
	local endTime = curTime + 25

	--while (i < endPoint) do
	while (curTime < endTime) do
		local spellName = (not spellBlacklist[i]) and GetSpellInfo(i)

		if (spellName) then
			spellName = toLowerCase(spellName)

			local spellNameTable = allSpellsSameName[spellName]
			if (not spellNameTable) then
				spellNameTable = {}
				allSpellsSameName[spellName] = spellNameTable
			end
			spellNameTable[#spellNameTable+1] = i
		end

		i = i + 1

		curTime = debugprofilestop()
	end
	if i < 1500000 then
		C_Timer.After(0, function() lazyBuildSpellCache(i) end)
	else
		--if DevTool then DevTool:AddData(platerInternal.Auras.spellCaches) end
		platerInternal.Auras.spellCachesLoaded = true
		platerInternal.Auras.spellCachesLoading = false
		expandAuraCaches()

		for _, callback in ipairs(spellCacheCallbacks) do
			callback()
		end

		wipe(spellCacheCallbacks)
	end
end

--builds the spell cache when it isn't built yet. 'callback' runs once the cache is ready
function platerInternal.Auras.InitSpellCache(callback)
	if (platerInternal.Auras.spellCachesLoaded) then
		callback()
		return
	end

	spellCacheCallbacks[#spellCacheCallbacks+1] = callback

	if (not platerInternal.Auras.spellCachesLoading) then
		--the sweep starts on the next frame, the flag keeps expandAuraCaches() from scheduling a second one
		platerInternal.Auras.spellCachesLoading = true
		C_Timer.After(0, lazyBuildSpellCache)
	end
end
--lazyBuildSpellCache()

function expandAuraCaches()
	--if not IS_WOW_PROJECT_MIDNIGHT_API_WITH_AURA_CONTAINERS or not platerInternal.Auras.spellCachesLoaded then return end
	if not IS_WOW_PROJECT_MIDNIGHT_API_WITH_AURA_CONTAINERS then return end
	local toLowerCase = string.lower
	local allIDsByName = platerInternal.Auras.spellCaches.allIDsByName
	local missing = {}
	local containersToExtend = DB_TRACK_METHOD == 0x1 and {DB_DEBUFF_BANNED, DB_BUFF_BANNED, SPECIAL_AURAS_AUTO_ADDED, SPECIAL_AURAS_USER_LIST, SPECIAL_AURAS_USER_LIST_MINE, AUTO_TRACKING_EXTRA_BUFFS, AUTO_TRACKING_EXTRA_DEBUFFS, AURA_COLORS} or {SPECIAL_AURAS_AUTO_ADDED, SPECIAL_AURAS_USER_LIST, SPECIAL_AURAS_USER_LIST_MINE, MANUAL_TRACKING_BUFFS, MANUAL_TRACKING_DEBUFFS, AURA_COLORS}
	for _, container in pairs (containersToExtend) do
		local containerCopy = DF.table.copy({}, container or {})
		for id, val in pairs(containerCopy) do
			local lowerID = toLowerCase(id)
			local isNumber = tonumber(id) and true or false
			local addIDs = Plater.SpellSameNameTable[lowerID] or DB_AURA_NAME_CACHE[lowerID] or allIDsByName[lowerID] -- just expand names and refresh automatically
			if addIDs and not isNumber then
				DB_AURA_NAME_CACHE[lowerID] = addIDs
				for _, addID in pairs(addIDs) do
					container[addID] = val
				end
			elseif not isNumber and not platerInternal.Auras.spellCachesLoaded then -- if that's a miss, even in the cache, then ignore it.
				table.insert(missing, lowerID)
			end
		end
	end

	if next(missing) and not platerInternal.Auras.spellCachesLoading then
		C_Timer.After(0, lazyBuildSpellCache)
	elseif not platerInternal.Auras.spellCachesLoading then
		C_Timer.After(0, function()
			--clean spell cache
			local copy = DF.table.copy({}, DB_AURA_NAME_CACHE)
			local toCheck = {DB_DEBUFF_BANNED, DB_BUFF_BANNED, SPECIAL_AURAS_AUTO_ADDED, SPECIAL_AURAS_USER_LIST, SPECIAL_AURAS_USER_LIST_MINE, AUTO_TRACKING_EXTRA_BUFFS, AUTO_TRACKING_EXTRA_DEBUFFS, MANUAL_TRACKING_BUFFS, MANUAL_TRACKING_DEBUFFS, AURA_COLORS}
			local fullList = {}
			for _, cache in pairs (toCheck) do
				for id in pairs(cache) do
					if not tonumber(id) then
						fullList[toLowerCase(id)] = true
					end
				end
			end
			for name in pairs (copy) do
				local contained = false
				if fullList[name] then
					contained = true
				end
				if not contained then
					DB_AURA_NAME_CACHE[name] = nil
				end
			end
		end)
	end

	-- update filters
	Plater.Auras.SetContainerFiltersOutdated()
	--if DevTool then DevTool:AddData(containersToExtend, "containers") end
	for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
		if plateFrame.unitFrame and plateFrame.unitFrame.PlaterOnScreen then
			if not plateFrame.unitFrame.isPerformanceUnitAura then
				Plater.AddToAuraUpdate(plateFrame.unitFrame.namePlateUnitToken, plateFrame.unitFrame) -- force aura update
			end
		end
	end
end
-- End Spell Caches



local extraAuraGUIDtoUnitFrameCache = platerInternal.ExtraAuras.unitFramesToGUID

--when an extra aura is added to a nameplate, cache the unit GUID to unitFrame to use when the extra aura expired
function platerInternal.ExtraAuras.CacheGUID_to_UnitFrame(GUID, unitFrame)
	extraAuraGUIDtoUnitFrameCache[GUID] = unitFrame
end
function platerInternal.ExtraAuras.GetUnitFrameFromGUID(GUID)
	return extraAuraGUIDtoUnitFrameCache[GUID]
end

function platerInternal.ExtraAuras.RemoveGUIDFromUnitFrameCache(GUID)
	if (extraAuraGUIDtoUnitFrameCache[GUID]) then
		extraAuraGUIDtoUnitFrameCache[GUID] = nil
	end
end

--not caches, these two tables hold extra icons added from platerInternal.ExtraAuras.Add()
--store {[spellId] = {[GUID] = exraAuraTable}}
local EXTRAAURAS_SPELLIDS = {}
--store {[GUID] = {[spellId] = exraAuraTable}}
local EXTRAAURAS_GUIDS = {}

--@unitGUID: to identify in which nameplate the extra aura is shown
--@spellId: of the aura
--@duration: debuff duration, start time is always the time that ExtraAuras.AddAura is called
--@borderColor: optional border color
function Plater.AddExtraAura(unitGUID, spellId, duration, borderColor, overlayColor, desaturated, showErrors)
	--! if the extra aura won't show if the player isn't in combat, why add them when the player is out of combat?
	local startTime = GetTime()
	local expirationTime = startTime + duration
	local spellName, _, spellIcon = GetSpellInfo(spellId)

	if (not spellName) then
		if (showErrors) then
			Plater:Msg("platerInternal.ExtraAuras.Add(): invalid spellId or spell does not exists.")
		end
		return
	end

	local extraAuraTable = EXTRAAURAS_SPELLIDS[spellId] and EXTRAAURAS_SPELLIDS[spellId][unitGUID]
	if (extraAuraTable) then --refresh
		extraAuraTable.startTime = startTime
		extraAuraTable.duration = duration
		extraAuraTable.expirationTime = expirationTime
		extraAuraTable.borderColor = borderColor
		extraAuraTable.overlayColor = overlayColor
		extraAuraTable.desaturated = desaturated
		extraAuraTable.needRefresh = "refresh"
	else
		extraAuraTable = { --add new
			startTime = startTime,
			duration = duration,
			expirationTime = expirationTime,
			borderColor = borderColor,
			overlayColor = overlayColor,
			desaturated = desaturated,
			spellName = spellName,
			spellIcon = spellIcon,
			--pre-create cache keys to avoid expensive string manipulation at runtime
			spellNameExtraCache = spellName .. "_extra",
			spellNameAuraCache = spellName .. "_player",
			spellNameGhostAuraCache = spellName .. "_player_ghost",
			needRefresh = "added",
		}
	end

	--add the extra aura
	EXTRAAURAS_SPELLIDS[spellId] = EXTRAAURAS_SPELLIDS[spellId] or {}
	EXTRAAURAS_SPELLIDS[spellId][unitGUID] = extraAuraTable

	EXTRAAURAS_GUIDS[unitGUID] = EXTRAAURAS_GUIDS[unitGUID] or {}
	EXTRAAURAS_GUIDS[unitGUID][spellId] = extraAuraTable

	return true
end

--called from Plater.ResetAuraContainer()
function platerInternal.ExtraAuras.WipeCache(unitFrame)
	wipe(unitFrame.ExtraAuraCache)
end

--remove an extra aura, this is called when a extra aura expires at platerInternal.ExtraAuras.ClearExpired()
function platerInternal.ExtraAuras.Remove(spellId, unitGUID)
	EXTRAAURAS_SPELLIDS[spellId][unitGUID] = nil
	EXTRAAURAS_GUIDS[unitGUID][spellId] = nil

	--find the unit frame and remove the icon
	--! shouldn't this call Plater.ResetAuraContainer (self, resetBuffs, resetDebuffs)?
		--! but calling it now might mess with regular and ghost auras already added in the pipe line
	local unitFrame = platerInternal.ExtraAuras.GetUnitFrameFromGUID(unitGUID)
	--unitFrame might not exist in the cache: got cleared by unit_died, or the player isn't in combat so extra auras aren't added to nameplates
	if (unitFrame and unitFrame:IsShown()) then
		--need to find the extra aura icon
		local buffFrame1 = unitFrame.BuffFrame
		for i = 1, #buffFrame1.PlaterBuffList do
			local auraIconFrame = buffFrame1.PlaterBuffList[i]
			if (auraIconFrame.extraAuraSpellId == spellId and auraIconFrame.spellId == spellId) then
				auraIconFrame.extraAuraSpellId = nil
				auraIconFrame:Hide()
			end
		end
	end
end

--when adding a new extra icon, attempt to get an aura icon already showing the extra aura
--! dunno if this should be require is the auras get clean up each tick? but not on retail I guess
function platerInternal.ExtraAuras.GetAuraIconByExtraAuraSpellId(unitFrame, spellId)
	local buffFrame1 = unitFrame.BuffFrame
	for i = 1, #buffFrame1.PlaterBuffList do
		local auraIconFrame = buffFrame1.PlaterBuffList[i]
		if (auraIconFrame.extraAuraSpellId == spellId and auraIconFrame.spellId == spellId) then
			return auraIconFrame
		end
	end
end

--iterate among all extra auras currently active and remove all expired
--this is called from Tick after Plater.ShowGhostAuras(tickFrame.BuffFrame)
function platerInternal.ExtraAuras.ClearExpired()
	local currentTime = GetTime()
	for spellId, listOfUnitGUIDs in pairs(EXTRAAURAS_SPELLIDS) do
		for unitGUID, extraAuraTable in pairs(listOfUnitGUIDs) do
			if (extraAuraTable.expirationTime < currentTime) then
				--this extra aura has expired
				platerInternal.ExtraAuras.Remove(spellId, unitGUID)
			end
		end
	end
end

local function CreatePlaterNamePlateAuraTooltip()
	local tooltip = CreateFrame("GameTooltip", "PlaterNamePlateAuraTooltip", UIParent, "GameTooltipTemplate")
	
	tooltip.ApplyOwnBackdrop = function(self)
		self:SetBackdrop ({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Buttons\WHITE8X8]], tileSize = 0, tile = false, tileEdge = true})
		self:SetBackdropColor (0.05, 0.05, 0.05, 0.8)
		self:SetBackdropBorderColor (0, 0, 0, 1)
	end
	
	local function OnUpdate(self, elapsed)
		self.updateTooltipTimer = (self.updateTooltipTimer or TOOLTIP_UPDATE_TIME or 0.2) - elapsed;
		if self.updateTooltipTimer > 0 then
			return;
		end
		self.updateTooltipTimer = TOOLTIP_UPDATE_TIME or 0.2
		local owner = self:GetOwner();
		if owner and owner.UpdateTooltip then
			owner:UpdateTooltip();
		end
	end
	
	tooltip:SetScript("OnUpdate", OnUpdate)
	
	if tooltip.SetBackdrop then
		return tooltip
	end
	
	-- workarounds for 9.1.5
	local nineSlice = tooltip.NineSlice or tooltip
    Mixin(nineSlice, BackdropTemplateMixin)
    nineSlice:SetScript("OnSizeChanged", nineSlice.OnSizeChanged)

    nineSlice.backdropInfo = tooltip.backdropInfo
    nineSlice.backdropColor = tooltip.backdropColor
    nineSlice.backdropColorAlpha = tooltip.backdropColorAlpha
    nineSlice.backdropBorderColor = tooltip.backdropBorderColor
    nineSlice.backdropBorderColorAlpha = tooltip.backdropBorderColorAlpha
    nineSlice.backdropBorderBlendMode = tooltip.backdropBorderBlendMode

    nineSlice:OnBackdropLoaded()
	
	tooltip.SetBackdrop = function(self,...)
		local nineSlice = self.NineSlice or self
		nineSlice:SetBackdrop(...)
	end
	tooltip.SetBackdropColor = function(self,...)
		local nineSlice = self.NineSlice or self
		nineSlice:SetBackdropColor(...)
	end
	tooltip.SetBackdropBorderColor = function(self,...)
		local nineSlice = self.NineSlice or self
		nineSlice:SetBackdropBorderColor(...)
	end
	tooltip.ApplyBackdrop = function(self,...)
		local nineSlice = self.NineSlice or self
		nineSlice:ApplyBackdrop(...)
	end
	
	return tooltip
end

local NamePlateTooltip = _G.NamePlateTooltip -- can be removed later
local PlaterNamePlateAuraTooltip = CreatePlaterNamePlateAuraTooltip()

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> Private Aura handling

function Plater.HandlePrivateAuraAnchors(plateFrame, maxIndex)
	if true then return end -- disable for now...
	if not plateFrame then return end
	if not C_UnitAuras or not C_UnitAuras.RemovePrivateAuraAnchor then return end

	local unitFrame = plateFrame.unitFrame
	if not unitFrame then return end

	if not unitFrame.privateAuraAnchorsFrame then
		unitFrame.privateAuraAnchorsFrame = CreateFrame ("frame", unitFrame:GetName() .. "PrivateAuraFrame", unitFrame)
		unitFrame.privateAuraAnchorsFrame.icons = {}
		unitFrame.privateAuraAnchorsFrame:SetParent(unitFrame)
		unitFrame.privateAuraAnchorsFrame:SetSize(1, 1)
	end
	
	if not unitFrame.PlaterOnScreen then
		if unitFrame.privateAuraAnchorsFrame.icons then
			for _, icon in pairs(unitFrame.privateAuraAnchorsFrame.icons) do
				if icon.anchorID then
					C_UnitAuras.RemovePrivateAuraAnchor(icon.anchorID)
				end
				icon.anchorID = nil
				icon:Hide()
			end
		end
		unitFrame.privateAuraAnchorsFrame:Hide()
		return
	end
	
	--anchor building
	local anchorSide = Plater.db.profile.aura_frame1_anchor.side
	local rowGrowthDirectionUp = (anchorSide < 3 or anchorSide > 5)
	maxIndex = maxIndex or 2
	local relIconPoint = "bottom"
	local relIconPointTo = "top"
	local paddingMult = 1
	
	-- --> left to right
	if (DB_AURA_GROW_DIRECTION == 3) then
		relIconPoint = rowGrowthDirectionUp and "bottomleft" or "topleft"
		relIconPointTo = rowGrowthDirectionUp and "topleft" or "bottomleft"
		paddingMult = 1
		
	-- <-- right to left
	elseif (DB_AURA_GROW_DIRECTION == 1) then
		relIconPoint = rowGrowthDirectionUp and "bottomright" or "topright"
		relIconPointTo = rowGrowthDirectionUp and "topright" or "bottomright"
		paddingMult = -1
	end
	
	local unit = unitFrame.IsSelf and "player" or unitFrame[MEMBER_UNITID]
	
	unitFrame.privateAuraAnchorsFrame:SetPoint(relIconPoint, unitFrame.BuffFrame, relIconPointTo, 0, Plater.db.profile.aura_breakline_space)

	for index = 1, maxIndex do
		local icon = unitFrame.privateAuraAnchorsFrame.icons[index]
		if not icon then
			icon = CreateFrame ("frame", unitFrame:GetName() .. "PAFI" .. index, unitFrame.privateAuraAnchorsFrame)
			unitFrame.privateAuraAnchorsFrame.icons[index] = icon
		end
		icon:SetPoint(relIconPoint, unitFrame.privateAuraAnchorsFrame, relIconPointTo, ((Plater.db.profile.aura_width * (index - 1)) + DB_AURA_PADDING * (index -1)) * paddingMult, 0)
		icon:SetSize(Plater.db.profile.aura_width, Plater.db.profile.aura_height)
		icon:Show()
		local privateAnchorArgs = {
			unitToken = unit,
			auraIndex = index,
			parent = unitFrame.privateAuraAnchorsFrame,
			showCountdownFrame = true,
			showCountdownNumbers = true,
			isContainer = false,
			iconInfo = {
				iconAnchor = {
					point = "CENTER",
					relativeTo = icon,
					relativePoint = "CENTER",
					offsetX = 0,
					offsetY = 0,
				},
				iconWidth = Plater.db.profile.aura_width,
				iconHeight = Plater.db.profile.aura_height,
				borderScale = -1000,
			},
			durationAnchor = {
				point = "CENTER",
				relativeTo = icon,
				relativePoint = "CENTER",
				offsetX = 0,
				offsetY = 0,
			},
		}
		
		icon.anchorID = C_UnitAuras.AddPrivateAuraAnchor(privateAnchorArgs)
		--print("PAFI: ", index, " - ", icon.anchorID)
	end
	unitFrame.privateAuraAnchorsFrame:Show()
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> UNIT_AURA event handling


local function setAdditionalAuraFields(aura, unit, sourceIsSelf, sourceReaction, sourceIsPlayer)
	if not aura then return end
	if IS_WOW_PROJECT_MIDNIGHT then 
		aura.sourceIsSelf = false
		aura.sourceReaction = 4
		aura.sourceIsPlayer = false
		return
	end
	aura.sourceIsSelf = sourceIsSelf or aura.sourceUnit and unit and UnitIsUnit (aura.sourceUnit, unit) or false
	aura.sourceReaction = sourceReaction or aura.sourceUnit and UnitReaction(aura.sourceUnit, "player") or 4
	aura.sourceIsPlayer = sourceIsPlayer or aura.sourceUnit and (UnitIsUnit (aura.sourceUnit, "player") or UnitIsUnit (aura.sourceUnit, "pet")) or false
	--print(aura.name, aura.sourceUnit, aura.sourceIsSelf, aura.sourceReaction, aura.sourceIsPlayer)
end
--override local again with more handling
GetAuraDataByAuraInstanceID = function(unit, auraInstanceID)
	local aura = C_UnitAuras.GetAuraDataByAuraInstanceID(unit, auraInstanceID)
	setAdditionalAuraFields(aura, unit)
	return aura
end
GetAuraDataBySlot = function (unit, slot)
	local aura = C_UnitAuras.GetAuraDataBySlot(unit, slot)
	setAdditionalAuraFields(aura, unit)
	return aura
end

local ValidateAuraForUpdate = function (unit, aura)
	if IS_WOW_PROJECT_MIDNIGHT then return true, true, true end
	local needsUpdate = false
	local hasBuff = false
	local hasDebuff = false
	
	if DB_AURA_GHOSTAURA_ENABLED and DB_AURA_SEPARATE_BUFFS then
		if aura.isHarmful and aura.sourceUnit == "player" and GHOSTAURAS[aura.name] then
			-- ensure ghost auras are updated properly
			hasBuff = true
			needsUpdate = true
		end
	end
	
	local name, spellId = aura.name, aura.spellId
	
	--DevTool:AddData({blacklist = (DB_BUFF_BANNED[name] or DB_BUFF_BANNED[spellId] or DB_DEBUFF_BANNED[name] or DB_DEBUFF_BANNED[spellId]) or false, spellId = spellId, name = name}, "UnitAura-Check: "..name)
	
	hasBuff = aura.isHelpful or hasBuff
	hasDebuff = aura.isHarmful or hasDebuff
	
	local advancedBrokenFilteringTest = false
	if advancedBrokenFilteringTest then
	
		if DB_TRACK_METHOD == 0x2 then
			--manual tracking
			
			if DB_SHOW_PURGE_IN_EXTRA_ICONS or DB_SHOW_ENRAGE_IN_EXTRA_ICONS or DB_SHOW_MAGIC_IN_EXTRA_ICONS
				or (aura.sourceUnit == "player" and ( MANUAL_TRACKING_BUFFS[name] or MANUAL_TRACKING_BUFFS[spellId] ) or MANUAL_TRACKING_DEBUFFS[name] or MANUAL_TRACKING_DEBUFFS[spellId] )
				then -- only player buffs in manual tracking
				needsUpdate = true
			end
			
		else
			-- automatic tracking
			
			--TODO: additional checks for track-list etc. possible, depending on the buff settings: if nothing like dispellable or so is ticked, we can verify this here
			
			if not (DB_BUFF_BANNED[name] or DB_BUFF_BANNED[spellId] or DB_DEBUFF_BANNED[name] or DB_DEBUFF_BANNED[spellId]) then
				--a not blocked aura is included in the update
				needsUpdate = true
			end
		end
		
		if SPECIAL_AURAS_AUTO_ADDED [name] or SPECIAL_AURAS_AUTO_ADDED [spellId] or  SPECIAL_AURAS_USER_LIST[name] or SPECIAL_AURAS_USER_LIST[spellId] or (aura.sourceUnit == "player" and (SPECIAL_AURAS_USER_LIST_MINE[name] or SPECIAL_AURAS_USER_LIST_MINE[spellId])) then
			--or DB_SHOW_PURGE_IN_EXTRA_ICONS or DB_SHOW_ENRAGE_IN_EXTRA_ICONS or DB_SHOW_MAGIC_IN_EXTRA_ICONS
			--include buff special at all times
			needsUpdate = true
		end
		
		
	else
		needsUpdate = hasBuff or hasDebuff or false
	end

	--DevTool:AddData({needsUpdate=needsUpdate, hasBuff=hasBuff, hasDebuff=hasDebuff}, "Plater_UNIT_AURA return")
	return needsUpdate, hasBuff, hasDebuff
	
end

--[[
UNIT_AURA Payload:
	- unit						-- the unit the aura update is applied to
	- UnitAuraUpdateInfo = {	-- the table of updated aura information for this unit/event
			addedAuras = AuraInstanceInfo[]?,
			updatedAuraInstanceIDs = number[]?
			removedAuraInstanceIDs = number[]?
			isFullUpdate = boolean?,
		}

with AuraInstanceInfo = {	
		canApplyAura,
		debuffType,
		isBossAura,
		isFromPlayerOrPlayerPet,
		isHarmful,
		isHelpful,
		isNameplateOnly,
		isRaid,
		name,
		nameplateShowAll,
		nameplateShowPersonal,
		shouldNeverShow,
		sourceUnit,
		spellId,
		
		-- so, FULL UnitAura return values plus:
		auraInstanceID = number,
		dispelName = string,  -- "Magic" | "Curse" | "Disease" | "Poison"
	}
]]--
local UnitAuraEventHandlerData = {}
local UnitAuraCacheData = {} --new unit aura event info data cache
local UpdateUnitAuraCacheData
local UnitAuraEventHandler = function (_, event, arg1, arg2, arg3, ...)
	Plater.StartLogPerformanceCore("Plater-Core", "Events", event)
	--DevTool:AddData({event = event, arg1 = arg1, arg2 = arg2}, "Plater_UnitAuraEventHandler - " .. (event or "N/A"))
	if event == "UNIT_AURA" then
		local unit, updatedAuras = arg1, arg2
		--print(issecretvalue(arg1), issecretvalue(arg2))
		--DevTool:AddData({unit = unit, updatedAuras = updatedAuras}, "Plater_UNIT_AURA - " .. unit)
		if unit then
			UpdateUnitAuraCacheData(unit, updatedAuras)
		end
	end
	
	Plater.EndLogPerformanceCore("Plater-Core", "Events", event)
end


--[[
	New aura container code - MIDNIGHT 12.1!
]]--

local AURA_CONTAINER_CACHE = {}

local auraFramesSetup = {
	{
		frameName = "BuffFrame1",
		key = "BuffFrame",
		name = "Main",
	},
	{
		frameName = "BuffFrame2",
		key = "BuffFrame2",
		name = "Secondary",
	},
	{
		frameName = "ExtraIconRow",
		key = "ExtraIconFrame",
		name = "ExtraIconFrame",
	},
}

-- TODO: filter by buffs/debuffs
local containerConfigCache = {
	containerConfigIndex = 0,
	candidateFilterIndex = 0,
	candidateFilters = {},
	auraFilterIndex = 1,
	auraFilters = {
		enemynpc = {},
		friendlynpc = {},
		enemyplayer = {},
		friendlyplayer = {},
	},
	containerLayoutIndex = 0,
	containerLayouts = {},
	containerFullOptionIndex = 0,
	containerFullOptions = {
		enemynpc = {},
		friendlynpc = {},
		enemyplayer = {},
		friendlyplayer = {},
	},
	auraFrameOptionIndex = 0,
	auraFrameOptions = {},
	auraFrameLayoutIndex = 0,
	auraFrameLayouts = {},
	auraBorderOptionIndex = 0,
	auraBorderOptions = {},
}
function Plater.Auras.SetIconConfigOutdated()
	Plater.StartLogPerformanceCore("Plater-Core", "Update", "SetIconConfigOutdated")
	containerConfigCache.containerConfigIndex = containerConfigCache.containerConfigIndex + 1
	containerConfigCache.containerLayoutIndex = containerConfigCache.containerLayoutIndex + 1
	containerConfigCache.containerFullOptionIndex = containerConfigCache.containerFullOptionIndex + 1
	containerConfigCache.auraBorderOptionIndex = containerConfigCache.auraBorderOptionIndex + 1
	containerConfigCache.auraFrameLayoutIndex = containerConfigCache.auraFrameLayoutIndex + 1
	containerConfigCache.auraFrameOptionIndex = containerConfigCache.auraFrameOptionIndex + 1
	Plater.EndLogPerformanceCore("Plater-Core", "Update", "SetIconConfigOutdated")
end
function Plater.Auras.SetContainerFiltersOutdated()
	Plater.StartLogPerformanceCore("Plater-Core", "Update", "SetContainerFiltersOutdated")
	containerConfigCache.candidateFilterIndex = containerConfigCache.candidateFilterIndex + 1
	containerConfigCache.auraFilterIndex = containerConfigCache.auraFilterIndex + 1
	Plater.EndLogPerformanceCore("Plater-Core", "Update", "SetContainerFiltersOutdated")
end

--adds a debuff to the list shown as a single icon while 'aura_consolidate' is enabled, can be called by mods
---@param spellId number
function Plater.Auras.AddConsolidatedDebuff(spellId)
	if (type(spellId) ~= "number") then
		error("Plater.Auras.AddConsolidatedDebuff: spellId must be a number.", 2)
	end

	--a mod may call this from a hook that runs on every nameplate update
	if (CONSOLIDATED_DEBUFFS[spellId]) then
		return
	end

	CONSOLIDATED_DEBUFFS[spellId] = true
	Plater.Auras.SetContainerFiltersOutdated()
	Plater.Auras.SetIconConfigOutdated()
	Plater.UpdateAllPlates()
end

local function getCandidateFilters(frameName, force)
	Plater.StartLogPerformanceCore("Plater-Core", "Update", "getCandidateFilters")
	local profile = Plater.db.profile

	local cachedFilter = containerConfigCache.candidateFilters[frameName]
	if not force and cachedFilter and cachedFilter.filterIndex == containerConfigCache.candidateFilterIndex then
		cachedFilter = DF.table.copy({}, cachedFilter)
		Plater.EndLogPerformanceCore("Plater-Core", "Update", "getCandidateFilters")
		return cachedFilter
	end

	local filters = {
		mainFilter = {
			includeSpellIDs = DB_TRACK_METHOD ~= 1 and {} or nil, -- for automatic, this should be nil, for manual this will filter everything with an empty table
			excludeSpellIDs = {}, -- needs to exclude anything on the additionalInclude, due to second include group!
			--includeDispelTypes -- AuraUtil.DispellableDebuffTypes
			--excludeDispelTypes -- AuraUtil.DispellableDebuffTypes
			--maxDuration = nil --profile.debuff_hide_permanent and math.huge or nil,
			--processedAuraType --AuraUtil.AuraUpdateChangedType
			--isFromPlayerOrPlayerPet
			--isRoleAura
			--isPriorityAura
			--isStealable
			--nameplateShowAll
			--nameplateShowPersonal
			--canApplyAura
			--isBossAura
			--isBossOrRoleAura
		},
		additionalInclude = {
			includeSpellIDs = {},
		},
		filterIndex = containerConfigCache.candidateFilterIndex
	}

	if frameName == "Main" then
		if DB_AURA_SEPARATE_BUFFS then
			if DB_TRACK_METHOD == 1 then 
				DF.table.copy(filters.additionalInclude.includeSpellIDs, AUTO_TRACKING_EXTRA_DEBUFFS)

				DF.table.copy(filters.mainFilter.excludeSpellIDs, AUTO_TRACKING_EXTRA_DEBUFFS)
				DF.table.copy(filters.mainFilter.excludeSpellIDs, DB_DEBUFF_BANNED)
				DF.table.copy(filters.mainFilter.excludeSpellIDs, SPECIAL_AURAS_AUTO_ADDED)
				DF.table.copy(filters.mainFilter.excludeSpellIDs, SPECIAL_AURAS_USER_LIST)
				DF.table.copy(filters.mainFilter.excludeSpellIDs, SPECIAL_AURAS_USER_LIST_MINE)
			else
				DF.table.copy(filters.additionalInclude.includeSpellIDs, MANUAL_TRACKING_DEBUFFS)
				DF.table.copy(filters.mainFilter.excludeSpellIDs, MANUAL_TRACKING_DEBUFFS)
			end
		else
			if DB_TRACK_METHOD == 1 then
				DF.table.copy(filters.additionalInclude.includeSpellIDs, AUTO_TRACKING_EXTRA_BUFFS)
				DF.table.copy(filters.additionalInclude.includeSpellIDs, AUTO_TRACKING_EXTRA_DEBUFFS)

				DF.table.copy(filters.mainFilter.excludeSpellIDs, DB_BUFF_BANNED)
				DF.table.copy(filters.mainFilter.excludeSpellIDs, DB_DEBUFF_BANNED)

				DF.table.copy(filters.mainFilter.excludeSpellIDs, AUTO_TRACKING_EXTRA_BUFFS)
				DF.table.copy(filters.mainFilter.excludeSpellIDs, AUTO_TRACKING_EXTRA_DEBUFFS)
				DF.table.copy(filters.mainFilter.excludeSpellIDs, SPECIAL_AURAS_AUTO_ADDED)
				DF.table.copy(filters.mainFilter.excludeSpellIDs, SPECIAL_AURAS_USER_LIST)
				DF.table.copy(filters.mainFilter.excludeSpellIDs, SPECIAL_AURAS_USER_LIST_MINE)
			else
				DF.table.copy(filters.additionalInclude.includeSpellIDs, MANUAL_TRACKING_BUFFS)
				DF.table.copy(filters.additionalInclude.includeSpellIDs, MANUAL_TRACKING_DEBUFFS)

				DF.table.copy(filters.mainFilter.excludeSpellIDs, MANUAL_TRACKING_BUFFS)
				DF.table.copy(filters.mainFilter.excludeSpellIDs, MANUAL_TRACKING_DEBUFFS)
			end
		end

		--consolidated debuffs are shown by their own single frame groups, see getAuraFilters
		if (profile.aura_consolidate) then
			for spellId in pairs(CONSOLIDATED_DEBUFFS) do
				filters.additionalInclude.includeSpellIDs[spellId] = nil

				if (DB_AURA_SHOW_DEBUFF_BYPLAYER or DB_AURA_SHOW_AS_BLIZZARD) then
					filters.mainFilter.excludeSpellIDs[spellId] = true
				end
			end
		end
	elseif frameName == "Secondary" then
		if DB_TRACK_METHOD == 1 then
			DF.table.copy(filters.mainFilter.excludeSpellIDs, DB_BUFF_BANNED)

			DF.table.copy(filters.additionalInclude.includeSpellIDs, AUTO_TRACKING_EXTRA_BUFFS)
			DF.table.copy(filters.mainFilter.excludeSpellIDs, AUTO_TRACKING_EXTRA_BUFFS)
		else
			DF.table.copy(filters.additionalInclude.includeSpellIDs, MANUAL_TRACKING_BUFFS)
			DF.table.copy(filters.mainFilter.excludeSpellIDs, MANUAL_TRACKING_BUFFS)
		end
	elseif frameName == "ExtraIconFrame" then
		filters.mainFilter.includeSpellIDs = nil
		filters.additionalInclude.excludeSpellIDs = {}

		DF.table.copy(filters.additionalInclude.includeSpellIDs, SPECIAL_AURAS_AUTO_ADDED)
		DF.table.copy(filters.additionalInclude.includeSpellIDs, SPECIAL_AURAS_USER_LIST)
		DF.table.copy(filters.additionalInclude.excludeSpellIDs, SPECIAL_AURAS_USER_LIST_MINE) -- explicitly

		DF.table.copy(filters.mainFilter.excludeSpellIDs, SPECIAL_AURAS_AUTO_ADDED)
		DF.table.copy(filters.mainFilter.excludeSpellIDs, SPECIAL_AURAS_USER_LIST)
		DF.table.copy(filters.mainFilter.excludeSpellIDs, SPECIAL_AURAS_USER_LIST_MINE)

		if DB_TRACK_METHOD == 1 then
			DF.table.copy(filters.mainFilter.excludeSpellIDs, DB_BUFF_BANNED)
			DF.table.copy(filters.mainFilter.excludeSpellIDs, DB_DEBUFF_BANNED)
			DF.table.copy(filters.additionalInclude.excludeSpellIDs, DB_BUFF_BANNED)
			DF.table.copy(filters.additionalInclude.excludeSpellIDs, DB_DEBUFF_BANNED)

			DF.table.copy(filters.mainFilter.excludeSpellIDs, AUTO_TRACKING_EXTRA_BUFFS)
			DF.table.copy(filters.mainFilter.excludeSpellIDs, AUTO_TRACKING_EXTRA_DEBUFFS)
			DF.table.copy(filters.additionalInclude.excludeSpellIDs, AUTO_TRACKING_EXTRA_BUFFS)
			DF.table.copy(filters.additionalInclude.excludeSpellIDs, AUTO_TRACKING_EXTRA_DEBUFFS)
		else
			DF.table.copy(filters.mainFilter.excludeSpellIDs, MANUAL_TRACKING_BUFFS)
			DF.table.copy(filters.mainFilter.excludeSpellIDs, MANUAL_TRACKING_DEBUFFS)
			DF.table.copy(filters.additionalInclude.excludeSpellIDs, MANUAL_TRACKING_BUFFS)
			DF.table.copy(filters.additionalInclude.excludeSpellIDs, MANUAL_TRACKING_DEBUFFS)
		end

		--consolidated debuffs are shown by their own single frame groups, see getAuraFilters
		if (profile.aura_consolidate) then
			for spellId in pairs(CONSOLIDATED_DEBUFFS) do
				filters.additionalInclude.includeSpellIDs[spellId] = nil
			end
		end
	end

	containerConfigCache.candidateFilters[frameName] = filters

	Plater.EndLogPerformanceCore("Plater-Core", "Update", "getCandidateFilters")
	return filters
end

local function getAuraFilters(frameName, actorType, force)
	Plater.StartLogPerformanceCore("Plater-Core", "Update", "getAuraFilters")

	if not actorType then
		Plater.EndLogPerformanceCore("Plater-Core", "Update", "getAuraFilters")
		return {}
	end

	local isPlayer = actorType == "enemyplayer" or actorType == "friendlyplayer"
	local canAssist = actorType == "friendlynpc" or actorType == "friendlyplayer"
	--local unitReaction = unit and UnitReaction (unit, "player")
	--local isFriend = unit and UnitIsFriend("player", unit)

	local cachedFilterInfo = containerConfigCache.auraFilters[actorType]
	if not cachedFilterInfo[frameName] then
		cachedFilterInfo[frameName] = {}
	end
	cachedFilterInfo = cachedFilterInfo[frameName]
	if not force and cachedFilterInfo.filters and cachedFilterInfo.filterIndex == containerConfigCache.auraFilterIndex then
		cachedFilterInfo = DF.table.copy({}, cachedFilterInfo)
		Plater.EndLogPerformanceCore("Plater-Core", "Update", "getAuraFilters")
		return cachedFilterInfo.filters
	end

	local filters = {}

	for _, type in pairs({"debuffs", "buffs"}) do
		local allCandidates = getCandidateFilters(frameName, force) -- fetch a fresh copy

		local pFilters = {}
		local nFilters = {}
		local mainFilterString = nil

		--consolidated debuffs get one single frame group each, the container keeps the top sorted copy and drops the rest
		if (frameName ~= "Secondary" and type == "debuffs" and not canAssist and Plater.db.profile.aura_consolidate) then
			for spellId in pairs(CONSOLIDATED_DEBUFFS) do
				local candidate = {includeSpellIDs = {[spellId] = true}}
				local filterString = "HARMFUL|PLAYER"
				local isTracked = false
				local isSpecialAura = SPECIAL_AURAS_AUTO_ADDED[spellId] or SPECIAL_AURAS_USER_LIST[spellId]

				if (frameName == "ExtraIconFrame") then
					isTracked = isSpecialAura

					--an 'only mine' special aura is in both user lists, anything else is shown from any caster
					if (not SPECIAL_AURAS_USER_LIST_MINE[spellId]) then
						filterString = "HARMFUL"
						candidate.excludeSpellIDs = allCandidates.additionalInclude.excludeSpellIDs
					end

				elseif (DB_TRACK_METHOD == 0x2) then
					isTracked = MANUAL_TRACKING_DEBUFFS[spellId]

				elseif (AUTO_TRACKING_EXTRA_DEBUFFS[spellId]) then
					--the extra tracking list shows a debuff from any caster
					isTracked = true
					filterString = "HARMFUL"

				--special auras are shown on the buff special frame instead
				elseif (not DB_DEBUFF_BANNED[spellId] and not isSpecialAura) then
					isTracked = DB_AURA_SHOW_DEBUFF_BYPLAYER or DB_AURA_SHOW_AS_BLIZZARD

					--same restriction as the 'as blizzard' groups below
					if (not DB_AURA_SHOW_DEBUFF_BYPLAYER) then
						candidate.nameplateShowPersonal = true
					end
				end

				if (isTracked) then
					table.insert(filters, {
						filterString = filterString,
						candidateFilters = candidate,
						maxFrameCount = 1,
					})
				end
			end
		end

		if DB_TRACK_METHOD == 0x2 and frameName ~= "ExtraIconFrame" then
			--manual tracking shortcut.
			if frameName == "Main" and type == "debuffs" and not canAssist then
				table.insert(filters, {
					filterString = "HARMFUL|PLAYER",
					candidateFilters = allCandidates.additionalInclude
				})
			elseif ((frameName == "Main" and not DB_AURA_SEPARATE_BUFFS) or (frameName == "Secondary" and DB_AURA_SEPARATE_BUFFS)) and type == "buffs" and canAssist then
				table.insert(filters, {
					filterString = "HELPFUL",
					candidateFilters = allCandidates.additionalInclude
				})

			--spell IDs may not be matched for debuffs on friends and buffs on enemies. the container rejects what
			--it may not match, so these two groups show the listed spells that are never secret and nothing else
			elseif frameName == "Main" and type == "debuffs" and canAssist then
				table.insert(filters, {
					filterString = "HARMFUL",
					candidateFilters = allCandidates.additionalInclude
				})
			elseif ((frameName == "Main" and not DB_AURA_SEPARATE_BUFFS) or (frameName == "Secondary" and DB_AURA_SEPARATE_BUFFS)) and type == "buffs" and not canAssist then
				table.insert(filters, {
					filterString = "HELPFUL",
					candidateFilters = allCandidates.additionalInclude
				})
			end
		elseif DB_TRACK_METHOD == 0x1 and frameName == "Main" and type == "debuffs" then
			mainFilterString = "HARMFUL"

			allCandidates.mainFilter.maxDuration = Plater.db.profile.aura_hide_permanent_debuffs and math.huge or nil

			--additional filters
			if canAssist == false then
				table.insert(filters, {
					filterString = "HARMFUL",
					candidateFilters = allCandidates.additionalInclude
				})
			end

			if canAssist then
				if DB_AURA_SHOW_DISPELLABLE and not DB_SHOW_PURGE_IN_EXTRA_ICONS then
					table.insert(pFilters, "RAID_PLAYER_DISPELLABLE")
				elseif DB_SHOW_PURGE_IN_EXTRA_ICONS then
					table.insert(nFilters, "!RAID_PLAYER_DISPELLABLE")
				end
			end
			if DB_AURA_SHOW_RAID then
				table.insert(pFilters, "RAID_IN_COMBAT")
				--table.insert(pFilters, "RAID")
			end
			
			if Plater.db.profile.aura_show_crowdcontrol and not Plater.db.profile.debuff_show_cc then
				table.insert(pFilters, "CROWD_CONTROL")
			elseif Plater.db.profile.debuff_show_cc then
				table.insert(nFilters, "!CROWD_CONTROL")
			end

			if DB_AURA_SHOW_DEBUFF_BYPLAYER then
				table.insert(filters, {
					filterString = "HARMFUL|PLAYER" .. (canAssist and DB_SHOW_PURGE_IN_EXTRA_ICONS and "|!RAID_PLAYER_DISPELLABLE" or "") .. (DB_AURA_SHOW_RAID and "|!RAID_IN_COMBAT" or "") .. (Plater.db.profile.aura_show_crowdcontrol and "|!CROWD_CONTROL" or ""),
					candidateFilters = allCandidates.mainFilter,
				})
			end
			if DB_AURA_SHOW_AS_BLIZZARD and not DB_AURA_SHOW_DEBUFF_BYPLAYER then
				local candidate = DF.table.copy({}, allCandidates.mainFilter)
				candidate.nameplateShowPersonal = true
				table.insert(filters, {
					filterString = "HARMFUL|IMPORTANT|PLAYER|!CROWD_CONTROL" .. (canAssist and DB_SHOW_PURGE_IN_EXTRA_ICONS and "|!RAID_PLAYER_DISPELLABLE" or ""),
					candidateFilters = candidate,
				})
				table.insert(filters, {
					filterString = "HARMFUL|!IMPORTANT|PLAYER|!CROWD_CONTROL" .. (canAssist and DB_SHOW_PURGE_IN_EXTRA_ICONS and "|!RAID_PLAYER_DISPELLABLE" or ""),
					candidateFilters = candidate,
				})
				pFilters = {}
			end

		elseif DB_TRACK_METHOD == 0x1 and ((frameName == "Main" and not DB_AURA_SEPARATE_BUFFS) or (frameName == "Secondary" and DB_AURA_SEPARATE_BUFFS)) and type == "buffs" then
			mainFilterString = "HELPFUL"

			allCandidates.mainFilter.maxDuration = Plater.db.profile.aura_hide_permanent_buffs and math.huge or nil

			--additional filters
			if canAssist == true then
				table.insert(filters, {
					filterString = "HELPFUL",
					candidateFilters = allCandidates.additionalInclude
				})
			end

			if DB_AURA_SHOW_ENRAGE and not DB_SHOW_ENRAGE_IN_EXTRA_ICONS and not canAssist then
				local candidate = DF.table.copy({}, allCandidates.mainFilter)
				candidate.includeSpellIDs = nil
				candidate.includeDispelTypes = candidate.includeDispelTypes or {}
				allCandidates.mainFilter.excludeDispelTypes = allCandidates.mainFilter.excludeDispelTypes or {}
				allCandidates.additionalInclude.excludeDispelTypes = allCandidates.additionalInclude.excludeDispelTypes or {}
				candidate.includeDispelTypes["Enrage"] = true
				table.insert(filters, {
					filterString = "HELPFUL" .. (Plater.db.profile.extra_icon_show_defensive and "|!BIG_DEFENSIVE|!EXTERNAL_DEFENSIVE" or ""),
					candidateFilters = candidate,
				})

				-- remaining exclude enrage
				allCandidates.mainFilter.excludeDispelTypes["Enrage"] = true
				allCandidates.additionalInclude.excludeDispelTypes["Enrage"] = true
			elseif DB_SHOW_ENRAGE_IN_EXTRA_ICONS and not canAssist then
				allCandidates.mainFilter.excludeDispelTypes = allCandidates.mainFilter.excludeDispelTypes or {}
				allCandidates.additionalInclude.excludeDispelTypes = allCandidates.additionalInclude.excludeDispelTypes or {}
				allCandidates.mainFilter.excludeDispelTypes["Enrage"] = true
				allCandidates.additionalInclude.excludeDispelTypes["Enrage"] = true
			end

			if DB_AURA_SHOW_MAGIC and not DB_SHOW_MAGIC_IN_EXTRA_ICONS and not canAssist then
				local candidate = DF.table.copy({}, allCandidates.mainFilter)
				candidate.includeSpellIDs = nil
				candidate.includeDispelTypes = candidate.includeDispelTypes or {}
				allCandidates.mainFilter.excludeDispelTypes = allCandidates.mainFilter.excludeDispelTypes or {}
				allCandidates.additionalInclude.excludeDispelTypes = allCandidates.additionalInclude.excludeDispelTypes or {}
				candidate.includeDispelTypes["Magic"] = true
				table.insert(filters, {
					filterString = "HELPFUL" .. (Plater.db.profile.extra_icon_show_defensive and "|!BIG_DEFENSIVE|!EXTERNAL_DEFENSIVE" or ""),
					candidateFilters = candidate,
				})

				-- remaining exclude magic
				allCandidates.mainFilter.excludeDispelTypes["Magic"] = true
				allCandidates.additionalInclude.excludeDispelTypes["Magic"] = true
			elseif DB_SHOW_MAGIC_IN_EXTRA_ICONS and not canAssist then
				allCandidates.mainFilter.excludeDispelTypes = allCandidates.mainFilter.excludeDispelTypes or {}
				allCandidates.additionalInclude.excludeDispelTypes = allCandidates.additionalInclude.excludeDispelTypes or {}
				allCandidates.mainFilter.excludeDispelTypes["Magic"] = true
				allCandidates.additionalInclude.excludeDispelTypes["Magic"] = true
			end

			if Plater.db.profile.aura_show_defensive_cd and not Plater.db.profile.extra_icon_show_defensive  then
				if isPlayer or canAssist then
					table.insert(pFilters, "BIG_DEFENSIVE")
					table.insert(pFilters, "EXTERNAL_DEFENSIVE")
				end
			elseif Plater.db.profile.extra_icon_show_defensive then
				table.insert(nFilters, "!BIG_DEFENSIVE")
				table.insert(nFilters, "!EXTERNAL_DEFENSIVE")
			end
			if not canAssist and not isPlayer then
				if DB_AURA_SHOW_DISPELLABLE and not DB_SHOW_PURGE_IN_EXTRA_ICONS then
					table.insert(pFilters, "RAID_PLAYER_DISPELLABLE")
				elseif DB_SHOW_PURGE_IN_EXTRA_ICONS then
					table.insert(nFilters, "!RAID_PLAYER_DISPELLABLE")
				end
			end
			if DB_AURA_SHOW_BUFF_BYPLAYER then
				table.insert(pFilters, "PLAYER")
			elseif DB_AURA_SHOW_RAID then
				table.insert(pFilters, "PLAYER")
				table.insert(pFilters, "RAID_IN_COMBAT")
				table.insert(pFilters, "RAID")
			end

			if DB_AURA_SHOW_BUFFENEMYNPC and not canAssist and not isPlayer then -- special treatment...
				local candidateFilter = DF.table.copy({}, allCandidates.mainFilter)
				candidateFilter.includeSpellIDs = nil
				table.insert(filters, {
					filterString = "HELPFUL" .. (DB_SHOW_PURGE_IN_EXTRA_ICONS and "|!RAID_PLAYER_DISPELLABLE" or "") .. (Plater.db.profile.extra_icon_show_defensive and "|!BIG_DEFENSIVE|!EXTERNAL_DEFENSIVE" or ""),
					candidateFilters = candidateFilter
				})
				pFilters = {}
			end

			if DB_AURA_SHOW_BUFFS_AS_BLIZZARD and not DB_AURA_SHOW_BUFFENEMYNPC and not canAssist then
				local candidate = DF.table.copy({}, allCandidates.mainFilter)
				candidate.includeSpellIDs = nil
				--candidate.nameplateShowPersonal = true
				--candidate.nameplateShowAll = true
				candidate.isStealable = true
				table.insert(filters, {
					filterString = "HELPFUL|INCLUDE_NAME_PLATE_ONLY" .. (DB_SHOW_PURGE_IN_EXTRA_ICONS and "|!RAID_PLAYER_DISPELLABLE" or "") .. (Plater.db.profile.extra_icon_show_defensive and "|!BIG_DEFENSIVE|!EXTERNAL_DEFENSIVE" or ""),
					candidateFilters = candidate,
					--candidateFilters = allCandidates.mainFilter,
				})
				candidate = DF.table.copy({}, allCandidates.mainFilter)
				candidate.includeSpellIDs = nil
				candidate.isStealable = false
				table.insert(filters, {
					filterString = "HELPFUL|IMPORTANT" .. (DB_SHOW_PURGE_IN_EXTRA_ICONS and "|!RAID_PLAYER_DISPELLABLE" or "") .. (Plater.db.profile.extra_icon_show_defensive and "|!BIG_DEFENSIVE|!EXTERNAL_DEFENSIVE" or ""),
					candidateFilters = candidate,
					--candidateFilters = allCandidates.mainFilter,
				})
				pFilters = {}
			end
			
		elseif frameName == "ExtraIconFrame" and type == "debuffs" then
			mainFilterString = "HARMFUL"

			if not canAssist then
				table.insert(filters, {
					filterString = "HARMFUL",
					candidateFilters = allCandidates.additionalInclude
				})
				-- the "only mine"
				table.insert(filters, {
					filterString = "HARMFUL|PLAYER",
					candidateFilters = {
						includeSpellIDs = SPECIAL_AURAS_USER_LIST_MINE,
						excludeSpellIDs = Plater.db.profile.aura_consolidate and CONSOLIDATED_DEBUFFS or nil, --shown by their own groups
						--excludeSpellIDs = SPECIAL_AURAS_USER_LIST,
					}
				})
			end
			
			if Plater.db.profile.debuff_show_cc then
				table.insert(pFilters, "CROWD_CONTROL")
			end
			
		elseif frameName == "ExtraIconFrame" and type == "buffs" then
			mainFilterString = "HELPFUL"
			
			if canAssist then
				table.insert(filters, {
					filterString = "HELPFUL",
					candidateFilters = allCandidates.additionalInclude
				})
				-- the "only mine"
				table.insert(filters, {
					filterString = "HELPFUL|PLAYER",
					candidateFilters = {
						includeSpellIDs = SPECIAL_AURAS_USER_LIST_MINE,
						--excludeSpellIDs = SPECIAL_AURAS_USER_LIST,
					}
				})
			end

			if DB_SHOW_ENRAGE_IN_EXTRA_ICONS and not canAssist then
				local candidate = DF.table.copy({}, allCandidates.mainFilter)
				candidate.includeSpellIDs = nil
				candidate.includeDispelTypes = candidate.includeDispelTypes or {}
				allCandidates.mainFilter.excludeDispelTypes = allCandidates.mainFilter.excludeDispelTypes or {}
				allCandidates.additionalInclude.excludeDispelTypes = allCandidates.additionalInclude.excludeDispelTypes or {}
				candidate.includeDispelTypes["Enrage"] = true
				table.insert(filters, {
					filterString = "HELPFUL" .. (Plater.db.profile.extra_icon_show_defensive and "|!BIG_DEFENSIVE|!EXTERNAL_DEFENSIVE" or ""),
					candidateFilters = candidate,
				})

				-- remaining exclude enrage
				allCandidates.mainFilter.excludeDispelTypes["Enrage"] = true
				allCandidates.additionalInclude.excludeDispelTypes["Enrage"] = true
			end

			if DB_SHOW_MAGIC_IN_EXTRA_ICONS and not canAssist then
				local candidate = DF.table.copy({}, allCandidates.mainFilter)
				candidate.includeSpellIDs = nil
				candidate.includeDispelTypes = candidate.includeDispelTypes or {}
				allCandidates.mainFilter.excludeDispelTypes = allCandidates.mainFilter.excludeDispelTypes or {}
				allCandidates.additionalInclude.excludeDispelTypes = allCandidates.additionalInclude.excludeDispelTypes or {}
				candidate.includeDispelTypes["Magic"] = true
				table.insert(filters, {
					filterString = "HELPFUL" .. (Plater.db.profile.extra_icon_show_defensive and "|!BIG_DEFENSIVE|!EXTERNAL_DEFENSIVE" or ""),
					candidateFilters = candidate,
				})

				-- remaining exclude magic
				allCandidates.mainFilter.excludeDispelTypes["Magic"] = true
				allCandidates.additionalInclude.excludeDispelTypes["Magic"] = true
			end

			if Plater.db.profile.extra_icon_show_defensive then
				table.insert(pFilters, "BIG_DEFENSIVE")
				table.insert(pFilters, "EXTERNAL_DEFENSIVE")
			end
			if DB_SHOW_PURGE_IN_EXTRA_ICONS then
				table.insert(pFilters, "RAID_PLAYER_DISPELLABLE")
			end
			
		end
		
		for i, filter in pairs(pFilters) do

			local negFilters = {}
			for j, negFilter in pairs(pFilters) do
				if j ~= i then table.insert(negFilters, "!" .. negFilter) end
			end

			local filterString = mainFilterString and string.join("|", mainFilterString, filter, unpack(negFilters)) or string.join("|", filter, unpack(negFilters))

			if #nFilters > 0 then
				filterString = string.join("|", filterString, unpack(nFilters))
			end
			table.insert(filters, {
				filterString = filterString,
				candidateFilters = allCandidates.mainFilter
			})
		end
		--if DevTool then DevTool:AddData({pFilters = pFilters, nFilters = nFilters, mainFilterString = mainFilterString, allCandidates = allCandidates}, frameName .. " - filters") end
	end

	--if DevTool then DevTool:AddData(filters, frameName) end

	if actorType then
		cachedFilterInfo.filters = filters
		cachedFilterInfo.filterIndex = containerConfigCache.auraFilterIndex
	end
	
	Plater.EndLogPerformanceCore("Plater-Core", "Update", "getAuraFilters")
	return filters
end

--TODO: by container group as well. requires larger rework of the whole current setup. support separate sizes for "own" debuffs/buffs
local function getAuraFrameLayout(frameName)
	Plater.StartLogPerformanceCore("Plater-Core", "Update", "getAuraFrameLayout")
	if not Plater.MaxAurasPerRow then Plater.RefreshAuraCache() end -- security check

	local cachedFrameLayout = containerConfigCache.auraFrameLayouts[frameName]
	if cachedFrameLayout and cachedFrameLayout.optionIndex == containerConfigCache.auraFrameLayoutIndex then
		cachedFrameLayout = DF.table.copy({}, cachedFrameLayout)
		Plater.EndLogPerformanceCore("Plater-Core", "Update", "getAuraFrameLayout")
		return cachedFrameLayout
	end

	local profile = Plater.db.profile
	local layout = {
		elementSpacing = profile.aura_padding,
		lineSpacing = profile.aura_breakline_space,
		--groupSpacing = profile.aura_padding, -- element spacing is for groups as well
		groupLineSpacing = profile.aura_breakline_space,
		--forceNewLine = false,
		elementWidth = 26,
		elementHeight = 16,
		--layoutIndex
		maximumLineSize = math.huge,
		optionIndex = containerConfigCache.auraFrameLayoutIndex,
	}

	if frameName == "Main" then
		layout.elementWidth = profile.aura_width
		layout.elementHeight = profile.aura_height
		layout.maximumLineSize = (profile.auras_per_row_auto and Plater.MaxAurasPerRow or profile.auras_per_row_amount or 10) * (layout.elementWidth + layout.elementSpacing) + 1
	elseif frameName == "Secondary" then
		layout.elementWidth = profile.aura_width2
		layout.elementHeight = profile.aura_height2
		layout.maximumLineSize = (profile.auras_per_row_auto and Plater.MaxAurasPerRow or profile.auras_per_row_amount2 or 10) * (layout.elementWidth + layout.elementSpacing) + 1
	elseif frameName == "ExtraIconFrame" then
		layout.elementWidth = profile.extra_icon_width
		layout.elementHeight = profile.extra_icon_height
	end

	containerConfigCache.auraFrameLayouts[frameName] = layout

	Plater.EndLogPerformanceCore("Plater-Core", "Update", "getAuraFrameLayout")
	return layout
end

local function getLayoutGrowthDirection(frameName)
	local profile = Plater.db.profile
	local horizontalDirection, verticalDirection, anchorPoint = AnchorUtil.FlowDirection.Right, AnchorUtil.FlowDirection.Up, "TOPLEFT"
	if frameName == "Main" then
		horizontalDirection = (profile.aura_grow_direction == 1) and AnchorUtil.FlowDirection.Left or AnchorUtil.FlowDirection.Right -- default to right
		local anchorSide = profile.aura_frame1_anchor.side
		verticalDirection = (anchorSide < 3 or anchorSide > 5) and AnchorUtil.FlowDirection.Up or AnchorUtil.FlowDirection.Down
		anchorPoint = (anchorSide < 3 or anchorSide > 5) and ((profile.aura_grow_direction == 1) and "BOTTOMRIGHT" or "BOTTOMLEFT") or ((profile.aura_grow_direction == 1) and "TOPRIGHT" or "TOPLEFT")

	elseif frameName == "Secondary" then
		horizontalDirection = (profile.aura2_grow_direction == 1) and AnchorUtil.FlowDirection.Left or AnchorUtil.FlowDirection.Right -- default to right
		local anchorSide = profile.aura_frame2_anchor.side
		verticalDirection = (anchorSide < 3 or anchorSide > 5) and AnchorUtil.FlowDirection.Up or AnchorUtil.FlowDirection.Down
		anchorPoint = (anchorSide < 3 or anchorSide > 5) and ((profile.aura2_grow_direction == 1) and "BOTTOMRIGHT" or "BOTTOMLEFT") or ((profile.aura2_grow_direction == 1) and "TOPRIGHT" or "TOPLEFT")

	elseif frameName == "ExtraIconFrame" then
		horizontalDirection = (DF.GrowDirectionBySide[profile.extra_icon_anchor.side] == 2) and AnchorUtil.FlowDirection.Left or AnchorUtil.FlowDirection.Right -- default to right
		anchorPoint = (DF.GrowDirectionBySide[profile.extra_icon_anchor.side] == 2) and "RIGHT" or "LEFT"
	end

	return horizontalDirection, verticalDirection, anchorPoint
end

local function getAuraProcessingPolicy(frameName)
	local policy = CustomAuraContainerAuraProcessingPolicy.ProcessAura --none
	local options = {
		displayOnlyDispellableDebuffs = false,
		ignoreBuffs = false,
		ignoreDebuffs = false,
		ignoreDispelDebuffs = false
	}

	if frameName == "Main" then

	elseif frameName == "Secondary" then

	elseif frameName == "ExtraIconFrame" then
		
	end
	return policy, options
end

-- allow for override in aura creation and update
platerInternal.Auras.initAndUpdateAuraFrameOverrides = {}
platerInternal.Auras.AuraFrameUpdateCallbackTypes = {
	["Icon"] = true,
	["Cooldown"] = true,
	["Count"] = true,
	["Timer"] = true,
	["Border"] = true,
}
Plater.Auras.AuraFrameUpdateCallbackTypes = {
	"Icon",
	"Cooldown",
	"Count",
	"Timer",
	"Border",
}
function Plater.Auras.SetAuraFrameUpdateCallback(callbackType, callbackFunc)
	assert(callbackType and platerInternal.Auras.AuraFrameUpdateCallbackTypes[callbackType], "The aura frame update callback 'type' needs to be 'Icon', 'Cooldown', 'Count', 'Timer' or 'Border'.")
	assert(type(callbackFunc) == "function", "The aura frame update callback function needs to be a function.")

	platerInternal.Auras.initAndUpdateAuraFrameOverrides[callbackType] = callbackFunc
end
function Plater.Auras.ClearAuraFrameUpdateCallback(callbackType)
	assert(callbackType and platerInternal.Auras.AuraFrameUpdateCallbackTypes[callbackType], "The aura frame update callback 'type' needs to be 'Icon', 'Cooldown', 'Count', 'Timer' or 'Border'.")
	platerInternal.Auras.initAndUpdateAuraFrameOverrides[callbackType] = nil
end

--dispel type id (the curve x value) to profile color key. it is a step curve, so each color holds until the next id:
--the ids between the named types (stealth, invisibility, ...) get the untyped color
local BORDER_DISPEL_CURVE_KEYS = {[0] = "none", [1] = "magic", [2] = "curse", [3] = "disease", [4] = "poison", [5] = "none", [9] = "enrage", [10] = "none", [11] = "bleed", [12] = "none"}

--one curve per border option instead of a color map: every AddDispelTypeTexture call securecopies its options per button,
--and a map of ColorMixin tables made that copy the most expensive part of creating an aura button
local function buildBorderColorCurve(typeColors, byType, untypedColor)
	local curve = C_CurveUtil.CreateColorCurve()
	curve:SetType(Enum.LuaCurveType.Step)
	for dispelTypeId, key in pairs(BORDER_DISPEL_CURVE_KEYS) do
		curve:AddPoint(dispelTypeId, CreateColor(unpack(byType and key ~= "none" and typeColors[key] or untypedColor)))
	end
	return curve
end

local BORDER_COLOR_KEYS = {"none", "magic", "curse", "disease", "poison", "bleed", "enrage", "is_debuff", "is_buff", "steal_or_purge"}

--every profile value the color maps are built from, to rebuild them only when one of these changed
local function getAuraBorderOptionsSignature(profile, isExtra, colors)
	local split = not isExtra and profile.aura_border_colors_split
	local byType = isExtra and profile.extra_icon_aura_border_colors_by_type or not isExtra and profile.aura_border_colors_by_type
	if not split and not byType then
		return "" --no color maps at all
	end
	local parts = {tostring(split)}
	if split then
		parts[2] = tostring(profile.aura_border_colors_by_type_debuff)
		parts[3] = tostring(profile.aura_border_colors_by_type_buff)
		parts[4] = tostring(profile.aura_border_colors_by_type_dispellable)
	end
	for _, key in ipairs(BORDER_COLOR_KEYS) do
		local color = colors[key]
		parts[#parts + 1] = color and table.concat(color, ",") or ""
	end
	return table.concat(parts, ";")
end

local function getAuraBorderOptions(frameName)
	Plater.StartLogPerformanceCore("Plater-Core", "Update", "getAuraBorderOptions")
	local cached = containerConfigCache.auraBorderOptions[frameName]
	if cached and cached.optionIndex == containerConfigCache.auraBorderOptionIndex then
		Plater.EndLogPerformanceCore("Plater-Core", "Update", "getAuraBorderOptions")
		return cached
	end

	local profile = Plater.db.profile
	local isExtra = frameName == "ExtraIconFrame"
	local colors = isExtra and profile.extra_icon_dispel_type_colors or profile.aura_border_colors
	local signature = getAuraBorderOptionsSignature(profile, isExtra, colors)
	if cached and cached.signature == signature then
		cached.optionIndex = containerConfigCache.auraBorderOptionIndex
		Plater.EndLogPerformanceCore("Plater-Core", "Update", "getAuraBorderOptions")
		return cached
	end

	local style = Enum.CustomAuraButtonDispelTypeTextureStyle.PreserveAsset
	local borderOptions = {optionIndex = containerConfigCache.auraBorderOptionIndex, signature = signature}

	if not isExtra and profile.aura_border_colors_split then
		local stealable = Enum.CustomAuraButtonDispelTypeStealableFilter
		borderOptions[1] = { --debuffs
			showWhenHarmful = true, showWhenHelpful = false, showWithoutDispelType = true, style = style,
			customDispelColorCurve = buildBorderColorCurve(colors, profile.aura_border_colors_by_type_debuff, colors.is_debuff),
		}
		borderOptions[2] = { --buffs
			showWhenHarmful = false, showWhenHelpful = true, showWithoutDispelType = true, style = style,
			stealableFilter = stealable.NotStealable,
			customDispelColorCurve = buildBorderColorCurve(colors, profile.aura_border_colors_by_type_buff, colors.is_buff),
		}
		borderOptions[3] = { --steal or purge
			showWhenHarmful = false, showWhenHelpful = true, showWithoutDispelType = true, style = style,
			stealableFilter = stealable.Stealable,
			customDispelColorCurve = buildBorderColorCurve(colors, profile.aura_border_colors_by_type_dispellable, colors.steal_or_purge),
		}
	elseif isExtra and profile.extra_icon_aura_border_colors_by_type or not isExtra and profile.aura_border_colors_by_type then
		borderOptions[1] = { --fallback default
			showWhenHarmful = true, showWhenHelpful = true, showWithoutDispelType = true, style = style,
			customDispelColorCurve = buildBorderColorCurve(colors, true, colors.none),
		}
	end

	containerConfigCache.auraBorderOptions[frameName] = borderOptions

	Plater.EndLogPerformanceCore("Plater-Core", "Update", "getAuraBorderOptions")
	return borderOptions
end

local function applyAuraBorders(auraButton, frameName, borderOptions, borderThickness, auraWidth, auraHeight)
	local profile = Plater.db.profile
	local defaultColor = frameName ~= "ExtraIconFrame" and profile.aura_border_colors.default or profile.extra_icon_dispel_type_colors.default
	local borders = auraButton.Borders

	--false while the border is disabled, turning it back on registers again
	local activeBorderOptions = borderThickness > 0 and borderOptions
	local shouldRegister = auraButton.activeBorderOptions ~= activeBorderOptions
	if (shouldRegister) then
		auraButton:ClearDispelTypeTextures()
		auraButton.activeBorderOptions = activeBorderOptions
	end

	for i = 1, math.max(#borderOptions, #borders, 1) do
		local border = borders[i]
		if not border then
			border = auraButton:CreateTexture(nil, "overlay")
			border:SetTexture([[Interface\AddOns\Plater\images\IconBorderWhite]])
			border:SetTextureSliceMargins(8, 8, 8, 8)
			border:SetAllPoints()
			borders[i] = border
		end
		border:SetSize(auraWidth, auraHeight)

		local borderOption = activeBorderOptions and borderOptions[i]
		if (borderOption) then
			border:SetScale(borderThickness / 8)
			if (shouldRegister) then
				auraButton:AddDispelTypeTexture(border, borderOption)
			end

		elseif (i == 1 and borderThickness > 0) then
			--no option set, static border in the default color
			border:SetScale(borderThickness / 8)
			border:SetVertexColor(defaultColor[1], defaultColor[2], defaultColor[3], defaultColor[4])
			border:Show()

		else
			border:Hide()
		end
	end
	auraButton.Border = borders[1] --compatibility
end

--pulsing glow around the aura while a recast keeps its remaining time (pandemic window, 12.1.5).
--blizzard shows the texture and plays the animation, plater only registers them
local applyPandemicGlow = function(auraButton, auraWidth, auraHeight)
	local profile = Plater.db.profile
	local isEnabled = profile.aura_pandemic_glow
	local glowColor = profile.aura_pandemic_glow_color
	local glowWidth = auraWidth * CONST_PANDEMIC_GLOW_SCALE
	local glowHeight = auraHeight * CONST_PANDEMIC_GLOW_SCALE
	local pandemicGlow = auraButton.PandemicGlow

	if (not pandemicGlow) then
		if (not isEnabled) then
			return
		end

		--desaturated, the color comes from the profile
		pandemicGlow = auraButton:CreateTexture(nil, "overlay", nil, 7)
		pandemicGlow:SetTexture([[Interface\SpellActivationOverlay\IconAlert]])
		pandemicGlow:SetTexCoord(0.00781250, 0.50781250, 0.27734375, 0.52734375)
		pandemicGlow:SetDesaturated(true)
		pandemicGlow:SetBlendMode("ADD")
		pandemicGlow:SetPoint("center")
		pandemicGlow:Hide()
		auraButton.PandemicGlow = pandemicGlow

		--a registered animation group cannot get more animations, so it is complete before registering
		local pulseAnimation = pandemicGlow:CreateAnimationGroup()
		pulseAnimation:SetLooping("BOUNCE")
		local alphaAnimation = pulseAnimation:CreateAnimation("Alpha")
		alphaAnimation:SetFromAlpha(1)
		alphaAnimation:SetToAlpha(0.3)
		alphaAnimation:SetDuration(0.5)
		auraButton.PandemicPulse = pulseAnimation
	end

	pandemicGlow:SetSize(glowWidth, glowHeight)
	pandemicGlow:SetVertexColor(glowColor[1], glowColor[2], glowColor[3], glowColor[4])

	--registering the same region or animation twice is an assert error. with nothing registered the button
	--stops computing the pandemic window
	if (isEnabled and not auraButton.hasPandemicGlow) then
		auraButton:AddPandemicRegion(pandemicGlow)
		auraButton.hasPandemicGlow = true

	elseif (not isEnabled and auraButton.hasPandemicGlow) then
		auraButton:RemovePandemicRegion(pandemicGlow)
		pandemicGlow:Hide()
		auraButton.hasPandemicGlow = false
	end

	--blizzard only stops the animations it knows about, so a pulse removed while playing is stopped here
	local isPulseEnabled = isEnabled and profile.aura_pandemic_glow_pulse
	if (isPulseEnabled and not auraButton.hasPandemicPulse) then
		auraButton:AddPandemicActiveAnimation(auraButton.PandemicPulse)
		auraButton.hasPandemicPulse = true

	elseif (not isPulseEnabled and auraButton.hasPandemicPulse) then
		auraButton:RemovePandemicActiveAnimation(auraButton.PandemicPulse)
		auraButton.PandemicPulse:Stop()
		auraButton.hasPandemicPulse = false
	end

	--one flash when the window opens. the texture does not keep the alpha 0 it is given once the animation is
	--registered, so it is a pandemic region as well, and the animation holds its final alpha 0 for the rest of the window
	local isFlashEnabled = isEnabled and profile.aura_pandemic_glow_flash
	local pandemicFlash = auraButton.PandemicFlash

	if (not pandemicFlash) then
		if (not isFlashEnabled) then
			return
		end

		pandemicFlash = auraButton:CreateTexture(nil, "overlay", nil, 7)
		pandemicFlash:SetTexture([[Interface\SpellActivationOverlay\IconAlert]])
		pandemicFlash:SetTexCoord(0.00781250, 0.50781250, 0.27734375, 0.52734375)
		pandemicFlash:SetDesaturated(true)
		pandemicFlash:SetBlendMode("ADD")
		pandemicFlash:SetPoint("center")
		pandemicFlash:Hide()
		auraButton.PandemicFlash = pandemicFlash

		local flashAnimation = pandemicFlash:CreateAnimationGroup()
		flashAnimation:SetToFinalAlpha(true)
		local fadeInAnimation = flashAnimation:CreateAnimation("Alpha")
		fadeInAnimation:SetOrder(1)
		fadeInAnimation:SetFromAlpha(0)
		fadeInAnimation:SetToAlpha(1)
		fadeInAnimation:SetDuration(0.1)
		local fadeOutAnimation = flashAnimation:CreateAnimation("Alpha")
		fadeOutAnimation:SetOrder(2)
		fadeOutAnimation:SetFromAlpha(1)
		fadeOutAnimation:SetToAlpha(0)
		fadeOutAnimation:SetDuration(0.4)
		local growAnimation = flashAnimation:CreateAnimation("Scale")
		growAnimation:SetOrder(2)
		growAnimation:SetScaleFrom(1, 1)
		growAnimation:SetScaleTo(1.4, 1.4)
		growAnimation:SetDuration(0.4)
		auraButton.PandemicFlashAnimation = flashAnimation
	end

	if (isFlashEnabled and not auraButton.hasPandemicFlash) then
		auraButton:AddPandemicRegion(pandemicFlash)
		auraButton:AddPandemicEnterAnimation(auraButton.PandemicFlashAnimation)
		auraButton.hasPandemicFlash = true

	elseif (not isFlashEnabled and auraButton.hasPandemicFlash) then
		auraButton:RemovePandemicRegion(pandemicFlash)
		auraButton:RemovePandemicEnterAnimation(auraButton.PandemicFlashAnimation)
		pandemicFlash:Hide()
		auraButton.hasPandemicFlash = false
	end

	pandemicFlash:SetSize(glowWidth, glowHeight)
	pandemicFlash:SetVertexColor(glowColor[1], glowColor[2], glowColor[3], glowColor[4])
end

local function initAuraFrame(auraButton, frameName, frameKey, auraContainer)
	Plater.StartLogPerformanceCore("Plater-Core", "Update", "initAuraFrame")
	Plater.StartLogPerformanceCore("Plater-Core", "Update", "initAuraFrame - create")
	--DevTool:AddData(newIcon, "initAuraFrame")
	local profile = Plater.db.profile

	auraButton:SetMouseMotionEnabled(profile.aura_show_tooltip)
	--auraButton:SetHideTooltipInCombat(true)

	-- create stuff
	local iconOffset = 0
	auraButton.Icon = auraButton:CreateTexture (nil, "artwork")
	--PixelUtil.SetPoint (auraButton.Icon, "TOPLEFT", auraButton, "TOPLEFT", -iconOffset, iconOffset)
	--PixelUtil.SetPoint (auraButton.Icon, "TOPRIGHT", auraButton, "TOPRIGHT", iconOffset, iconOffset)
	--PixelUtil.SetPoint (auraButton.Icon, "BOTTOMLEFT", auraButton, "BOTTOMLEFT", -iconOffset, -iconOffset)
	--PixelUtil.SetPoint (auraButton.Icon, "BOTTOMRIGHT", auraButton, "BOTTOMRIGHT", iconOffset, -iconOffset)
	auraButton.Icon:SetPoint("Center")
	auraButton.Icon:SetTexCoord (.05, .95, .1, .6)
	auraButton.Icon:SetTexelSnappingBias(0.0)
	auraButton.Icon:SetSnapToPixelGrid(false)

	auraButton:SetIcon(auraButton.Icon)
	
	auraButton.Cooldown = CreateFrame ("cooldown", "$parentCooldown", auraButton, "CooldownFrameTemplate")
	--PixelUtil.SetPoint (auraButton.Cooldown, "TOPLEFT", auraButton, "TOPLEFT", -iconOffset, iconOffset)
	--PixelUtil.SetPoint (auraButton.Cooldown, "TOPRIGHT", auraButton, "TOPRIGHT", iconOffset, iconOffset)
	--PixelUtil.SetPoint (auraButton.Cooldown, "BOTTOMLEFT", auraButton, "BOTTOMLEFT", -iconOffset, -iconOffset)
	--PixelUtil.SetPoint (auraButton.Cooldown, "BOTTOMRIGHT", auraButton, "BOTTOMRIGHT", iconOffset, -iconOffset)
	auraButton.Cooldown:SetPoint("Center")
	auraButton.Cooldown:EnableMouse (false)
	if auraButton.Cooldown.EnableMouseMotion then
		auraButton.Cooldown:EnableMouseMotion (false)
	end
	auraButton.Cooldown:SetHideCountdownNumbers (true)
	auraButton.Cooldown:SetDrawBling(false)
	--auraButton.Cooldown:SetCountdownAbbrevThreshold(60)
	--auraButton.Cooldown:SetMinimumCountdownDuration(0)
	--auraButton.Cooldown:Hide()

	auraButton.Cooldown:SetEdgeTexture (profile.aura_cooldown_edge_texture)
	auraButton.Cooldown:SetReverse (profile.aura_cooldown_reverse)
	auraButton.Cooldown:SetDrawSwipe (profile.aura_cooldown_show_swipe)

	auraButton:SetDurationCooldown(auraButton.Cooldown)

	
	auraButton.CountFrame = CreateFrame ("frame", "$parentCountFrame", auraButton)--, BackdropTemplateMixin and "BackdropTemplate")
	auraButton.CountFrame:SetPoint("CENTER")
	auraButton.CountFrame:EnableMouse (false)
	if auraButton.CountFrame.EnableMouseMotion then
		auraButton.CountFrame:EnableMouseMotion (false)
	end
	auraButton.CountFrame.Count = auraButton.CountFrame:CreateFontString (nil, "artwork", "NumberFontNormalSmall")
	auraButton.Count = auraButton.CountFrame.Count
	auraButton.CountFrame.Count:SetJustifyH ("right")
	auraButton.CountFrame.Count:SetPoint ("bottomright", 3, -2)
	
	auraButton:SetApplicationCount(auraButton.Count)

	
	auraButton.TimerText = auraButton.Cooldown:CreateFontString (nil, "overlay", "NumberFontNormal")
	auraButton.TimerText:SetPoint ("center")
	--auraButton.TimerText = auraButton.Cooldown:GetRegions()
	Plater.EndLogPerformanceCore("Plater-Core", "Update", "initAuraFrame - create")

	Plater.StartLogPerformanceCore("Plater-Core", "Update", "initAuraFrame - durationtext")
	if profile.aura_timer then
		local durationTextOptions = {
			textFormatter = timeFormatter,
			textColor = Plater.db.profile.aura_timer_pandemic_color and {
				curve = pandemicColorCurve,
				property = Enum.DurationTextBindingProperty.RemainingPercent,
			} or nil
		}
		auraButton:SetDurationText(auraButton.TimerText, durationTextOptions)
		auraButton.TimerText:Show()
	else
		auraButton.TimerText:Hide()
		auraButton:ClearDurationText()
	end

	if frameName == "ExtraIconFrame" then
		auraButton.Desc = auraButton:CreateFontString(nil, "overlay", "GameFontNormal")
		auraButton.Desc:SetPoint("bottom", auraButton, "top", 0, 2)
		auraButton.Desc:SetText("")
		DF:SetFontSize(auraButton.Desc, Plater.db.profile.extra_icon_caster_size)
		DF:SetFontFace(auraButton.Desc, Plater.db.profile.extra_icon_caster_font)
		DF:SetFontOutline(auraButton.Desc, "SLUG")
	end

	if auraButton.SetCasterName and frameName == "ExtraIconFrame" and Plater.db.profile.extra_icon_caster_name then
		auraButton:SetCasterName(auraButton.Desc, {showRealmName = false, useClassColors = true})
	elseif auraButton.ClearCasterName then
		auraButton:ClearCasterName()
	end
	Plater.EndLogPerformanceCore("Plater-Core", "Update", "initAuraFrame - durationtext")


	Plater.StartLogPerformanceCore("Plater-Core", "Update", "initAuraFrame - fonts")
	--sizes and position:
	local auraWidth
	local auraHeight
	local borderThickness
	if frameName == "Main" then
		auraWidth = profile.aura_width
		auraHeight = profile.aura_height
		borderThickness = profile.aura_border_thickness

		local stackLabel = auraButton.Count
		DF:SetFontSize (stackLabel, profile.aura_stack_size)
		Plater.SetFontOutlineAndShadow (stackLabel, profile.aura_stack_outline, profile.aura_stack_shadow_color, profile.aura_stack_shadow_color_offset[1], profile.aura_stack_shadow_color_offset[2])
		DF:SetFontColor (stackLabel, profile.aura_stack_color)
		DF:SetFontFace (stackLabel, profile.aura_stack_font)
		Plater.SetAnchor (stackLabel, profile.aura_stack_anchor)
		
		--timer
		local timerLabel = auraButton.TimerText
		DF:SetFontSize (timerLabel, profile.aura_timer_text_size)
		Plater.SetFontOutlineAndShadow (timerLabel, profile.aura_timer_text_outline, profile.aura_timer_text_shadow_color, profile.aura_timer_text_shadow_color_offset[1], profile.aura_timer_text_shadow_color_offset[2])
		DF:SetFontFace (timerLabel, profile.aura_timer_text_font)
		DF:SetFontColor (timerLabel, profile.aura_timer_text_color)
		Plater.SetAnchor (timerLabel, profile.aura_timer_text_anchor)


	elseif frameName == "Secondary" then
		auraWidth = profile.aura_width2
		auraHeight = profile.aura_height2
		borderThickness = profile.aura_border_thickness2

		local stackLabel = auraButton.Count
		DF:SetFontSize (stackLabel, profile.aura_stack_size)
		Plater.SetFontOutlineAndShadow (stackLabel, profile.aura_stack_outline, profile.aura_stack_shadow_color, profile.aura_stack_shadow_color_offset[1], profile.aura_stack_shadow_color_offset[2])
		DF:SetFontColor (stackLabel, profile.aura_stack_color)
		DF:SetFontFace (stackLabel, profile.aura_stack_font)
		Plater.SetAnchor (stackLabel, profile.aura_stack_anchor)
		
		--timer
		local timerLabel = auraButton.TimerText
		DF:SetFontSize (timerLabel, profile.aura_timer_text_size)
		Plater.SetFontOutlineAndShadow (timerLabel, profile.aura_timer_text_outline, profile.aura_timer_text_shadow_color, profile.aura_timer_text_shadow_color_offset[1], profile.aura_timer_text_shadow_color_offset[2])
		DF:SetFontFace (timerLabel, profile.aura_timer_text_font)
		DF:SetFontColor (timerLabel, profile.aura_timer_text_color)
		Plater.SetAnchor (timerLabel, profile.aura_timer_text_anchor)


	elseif frameName == "ExtraIconFrame" then
		auraWidth = profile.extra_icon_width
		auraHeight = profile.extra_icon_height
		borderThickness = 1

		local stackLabel = auraButton.Count
		DF:SetFontSize (stackLabel, profile.extra_icon_stack_size)
		Plater.SetFontOutlineAndShadow (stackLabel, profile.extra_icon_stack_outline)
		DF:SetFontFace (stackLabel, profile.extra_icon_stack_font)
		Plater.SetAnchor (stackLabel, profile.aura_stack_anchor) --TODO
		
		
		--timer
		local timerLabel = auraButton.TimerText
		DF:SetFontSize (timerLabel, profile.extra_icon_timer_size)
		Plater.SetFontOutlineAndShadow (timerLabel, profile.extra_icon_timer_outline)
		DF:SetFontFace (timerLabel, profile.extra_icon_timer_font)
		Plater.SetAnchor (timerLabel, profile.aura_timer_text_anchor) --TODO
	end
	Plater.EndLogPerformanceCore("Plater-Core", "Update", "initAuraFrame - fonts")

	-- switch to proper border, keep compatibility
	Plater.StartLogPerformanceCore("Plater-Core", "Update", "initAuraFrame - applyAuraBorders")
	auraButton.Borders = {}
	applyAuraBorders(auraButton, frameName, getAuraBorderOptions(frameName), borderThickness, auraWidth, auraHeight)
	Plater.EndLogPerformanceCore("Plater-Core", "Update", "initAuraFrame - applyAuraBorders")
	Plater.StartLogPerformanceCore("Plater-Core", "Update", "initAuraFrame - applyPandemicGlow")
	applyPandemicGlow(auraButton, auraWidth, auraHeight)
	Plater.EndLogPerformanceCore("Plater-Core", "Update", "initAuraFrame - applyPandemicGlow")


	Plater.StartLogPerformanceCore("Plater-Core", "Update", "initAuraFrame - size")
	--PixelUtil.SetSize(auraButton.Border, auraWidth, auraHeight)
	--PixelUtil.SetSize(auraButton, auraWidth, auraHeight)
	auraButton:SetSize(auraWidth, auraHeight)
	auraButton.Border:SetSize(auraWidth, auraHeight)
	auraButton.Icon:SetSize(auraWidth, auraHeight)
	auraButton.Cooldown:SetSize(auraWidth, auraHeight)
	auraButton.CountFrame:SetSize(auraWidth, auraHeight)
	auraButton:SetScale(1)

	Plater.UpdateIconAspecRatio (auraButton)
	Plater.EndLogPerformanceCore("Plater-Core", "Update", "initAuraFrame - size")

	--the pass in the nameplate created event skips aura containers, so the buttons get it here
	if (PixelUtil.SetRoundLayoutToNearestPixelRecursively) then
		PixelUtil.SetRoundLayoutToNearestPixelRecursively(auraButton, true)
	end

	auraButton.frameName = frameName
	auraButton.frameKey = frameKey
	auraButton.auraContainer = auraContainer

	tinsert(auraContainer.auraButtons, auraButton)

	Plater.EndLogPerformanceCore("Plater-Core", "Update", "initAuraFrame")
	return auraButton
end

platerInternal.Auras.reSkinAuraButtonsTimer = nil
platerInternal.Auras.reSkinAuraButtonsObjects = {}
local reSkinAuraButtons
local function runScheduledUpdateAuraButtons()
	Plater.StartLogPerformanceCore("Plater-Core", "Update", "runScheduledUpdateAuraButtons")
	if C_Secrets.ShouldAurasBeSecret() or InCombatLockdown() then
		if platerInternal.Auras.reSkinAuraButtonsTimer then
			platerInternal.Auras.reSkinAuraButtonsTimer:Cancel()
		end
		platerInternal.Auras.reSkinAuraButtonsTimer = C_Timer.NewTimer(1, runScheduledUpdateAuraButtons)
		return
	end
	local curTime = debugprofilestop()
	local endTime = curTime + 100
	local doneItems = {}
	for auraButton, options in pairs(platerInternal.Auras.reSkinAuraButtonsObjects) do
		reSkinAuraButtons(auraButton, options)
		table.insert(doneItems, auraButton)
		curTime = debugprofilestop()
		if curTime > endTime then break end
	end
	for _, auraButtons in pairs (doneItems) do
		platerInternal.Auras.reSkinAuraButtonsObjects[auraButtons] = nil
	end
	for _ in pairs(platerInternal.Auras.reSkinAuraButtonsObjects) do
		-- has something..
		if platerInternal.Auras.reSkinAuraButtonsTimer then
			platerInternal.Auras.reSkinAuraButtonsTimer:Cancel()
		end
		platerInternal.Auras.reSkinAuraButtonsTimer = C_Timer.NewTimer(0, runScheduledUpdateAuraButtons)
		break
	end
	Plater.EndLogPerformanceCore("Plater-Core", "Update", "runScheduledUpdateAuraButtons")
end
local function scheduleReSkinAurButtons(auraButtons, options)
	if platerInternal.Auras.reSkinAuraButtonsTimer then
		platerInternal.Auras.reSkinAuraButtonsTimer:Cancel()
	end
	platerInternal.Auras.reSkinAuraButtonsObjects[auraButtons] = options
	platerInternal.Auras.reSkinAuraButtonsTimer = C_Timer.NewTimer(1, runScheduledUpdateAuraButtons)
end
function reSkinAuraButtons(auraButtons, options)

	local profile = Plater.db.profile

	if C_Secrets.ShouldAurasBeSecret() or InCombatLockdown() then
		--if DevTool then DevTool:AddData(auraButtons, "schedule - " .. tostring(auraButtons)) end
		scheduleReSkinAurButtons(auraButtons, options)
		return
	end
	Plater.StartLogPerformanceCore("Plater-Core", "Update", "reSkinAuraButtons")
	
	--if DevTool then DevTool:AddData(auraButtons, "updating - " .. tostring(auraButtons)) end
	for _, auraButton in pairs(auraButtons) do
		
		auraButton:SetMouseMotionEnabled(profile.aura_show_tooltip)

		local auraWidth
		local auraHeight
		local borderThickness
		local frameName = auraButton.frameName
		if frameName == "Main" then
			auraWidth = profile.aura_width
			auraHeight = profile.aura_height
			borderThickness = profile.aura_border_thickness

			local stackLabel = auraButton.Count
			DF:SetFontSize (stackLabel, profile.aura_stack_size)
			Plater.SetFontOutlineAndShadow (stackLabel, profile.aura_stack_outline, profile.aura_stack_shadow_color, profile.aura_stack_shadow_color_offset[1], profile.aura_stack_shadow_color_offset[2])
			DF:SetFontColor (stackLabel, profile.aura_stack_color)
			DF:SetFontFace (stackLabel, profile.aura_stack_font)
			Plater.SetAnchor (stackLabel, profile.aura_stack_anchor)
			
			--timer
			local timerLabel = auraButton.TimerText
			DF:SetFontSize (timerLabel, profile.aura_timer_text_size)
			Plater.SetFontOutlineAndShadow (timerLabel, profile.aura_timer_text_outline, profile.aura_timer_text_shadow_color, profile.aura_timer_text_shadow_color_offset[1], profile.aura_timer_text_shadow_color_offset[2])
			DF:SetFontFace (timerLabel, profile.aura_timer_text_font)
			DF:SetFontColor (timerLabel, profile.aura_timer_text_color)
			Plater.SetAnchor (timerLabel, profile.aura_timer_text_anchor)


		elseif frameName == "Secondary" then
			auraWidth = profile.aura_width2
			auraHeight = profile.aura_height2
			borderThickness = profile.aura_border_thickness2

			local stackLabel = auraButton.Count
			DF:SetFontSize (stackLabel, profile.aura_stack_size)
			Plater.SetFontOutlineAndShadow (stackLabel, profile.aura_stack_outline, profile.aura_stack_shadow_color, profile.aura_stack_shadow_color_offset[1], profile.aura_stack_shadow_color_offset[2])
			DF:SetFontColor (stackLabel, profile.aura_stack_color)
			DF:SetFontFace (stackLabel, profile.aura_stack_font)
			Plater.SetAnchor (stackLabel, profile.aura_stack_anchor)
			
			--timer
			local timerLabel = auraButton.TimerText
			DF:SetFontSize (timerLabel, profile.aura_timer_text_size)
			Plater.SetFontOutlineAndShadow (timerLabel, profile.aura_timer_text_outline, profile.aura_timer_text_shadow_color, profile.aura_timer_text_shadow_color_offset[1], profile.aura_timer_text_shadow_color_offset[2])
			DF:SetFontFace (timerLabel, profile.aura_timer_text_font)
			DF:SetFontColor (timerLabel, profile.aura_timer_text_color)
			Plater.SetAnchor (timerLabel, profile.aura_timer_text_anchor)


		elseif frameName == "ExtraIconFrame" then
			auraWidth = profile.extra_icon_width
			auraHeight = profile.extra_icon_height
			borderThickness = 1

			local stackLabel = auraButton.Count
			DF:SetFontSize (stackLabel, profile.extra_icon_stack_size)
			Plater.SetFontOutlineAndShadow (stackLabel, profile.extra_icon_stack_outline)
			DF:SetFontFace (stackLabel, profile.extra_icon_stack_font)
			Plater.SetAnchor (stackLabel, profile.aura_stack_anchor) --TODO
			
			
			--timer
			local timerLabel = auraButton.TimerText
			DF:SetFontSize (timerLabel, profile.extra_icon_timer_size)
			Plater.SetFontOutlineAndShadow (timerLabel, profile.extra_icon_timer_outline)
			DF:SetFontFace (timerLabel, profile.extra_icon_timer_font)
			Plater.SetAnchor (timerLabel, profile.aura_timer_text_anchor) --TODO

			if auraButton.SetCasterName and Plater.db.profile.extra_icon_caster_name then
				auraButton:SetCasterName(auraButton.Desc, {showRealmName = false, useClassColors = true})
			elseif auraButton.ClearCasterName then
				auraButton:ClearCasterName()
			end
		end

		--PixelUtil.SetSize(auraButton.Border, auraWidth, auraHeight)
		--PixelUtil.SetSize(auraButton, auraWidth, auraHeight)
		auraButton:SetSize(auraWidth, auraHeight)
		auraButton.Border:SetSize(auraWidth, auraHeight)
		auraButton.Icon:SetSize(auraWidth, auraHeight)
		auraButton.Cooldown:SetSize(auraWidth, auraHeight)
		auraButton.CountFrame:SetSize(auraWidth, auraHeight)
		auraButton:SetScale(1)

		applyAuraBorders(auraButton, frameName, options.borderOptions, borderThickness, auraWidth, auraHeight)
		applyPandemicGlow(auraButton, auraWidth, auraHeight)

		auraButton.Cooldown:SetEdgeTexture (profile.aura_cooldown_edge_texture)
		auraButton.Cooldown:SetReverse (profile.aura_cooldown_reverse)
		auraButton.Cooldown:SetDrawSwipe (profile.aura_cooldown_show_swipe)

		if profile.aura_timer then
			local durationTextOptions = {
				textFormatter = timeFormatter,
				textColor = Plater.db.profile.aura_timer_pandemic_color and {
					curve = pandemicColorCurve,
					property = Enum.DurationTextBindingProperty.RemainingPercent,
				} or nil
			}
			auraButton:SetDurationText(auraButton.TimerText, durationTextOptions)
			auraButton.TimerText:Show()
		else
			auraButton.TimerText:Hide()
			auraButton:ClearDurationText()
		end

	end
	Plater.EndLogPerformanceCore("Plater-Core", "Update", "reSkinAuraButtons")
end

local function getAuraFrameOptions(frameName, key, auraContainer)
	Plater.StartLogPerformanceCore("Plater-Core", "Update", "getAuraFrameOptions")
	local cachedAuraOptions = containerConfigCache.auraFrameOptions[frameName]
	if cachedAuraOptions and cachedAuraOptions.optionIndex == containerConfigCache.auraFrameOptionIndex then
		cachedAuraOptions = DF.table.copy({}, cachedAuraOptions)
		cachedAuraOptions.initializeFrame = function(auraButton) initAuraFrame(auraButton, frameName, key, auraContainer) end -- this needs to be up to date!
		Plater.EndLogPerformanceCore("Plater-Core", "Update", "getAuraFrameOptions")
		return cachedAuraOptions
	end
	
	local auraFrameOptions = {
		-- Maximum number of aura frames this filter group may display.
		maxFrameCount = (Plater.db.profile.aura_max_shown_limit and (Plater.db.profile.aura_max_shown_limit <= 0))and math.huge or Plater.db.profile.aura_max_shown_limit or math.huge,
		-- Sort method used to order auras accepted by this filter group.
		sortMethod = Plater.db.profile.aura_sort and AuraContainerSortMethod.Expiration or AuraContainerSortMethod.Default,
		-- Sort direction applied to the selected sort method.
		sortDirection = AuraContainerSortDirection.Normal,
		-- Additional templates inherited by frames created for this filter group. CustomAuraButtonTemplate is always inherited first.
		templateNames = nil,
		-- Optional candidate filters applied after the aura filter string.
		candidateFilters = nil,
		-- Optional callback invoked after each frame is created.
		initializeFrame = function(auraButton) initAuraFrame(auraButton, frameName, key, auraContainer) end,
		-- Optional flow layout settings for this filter group's visible frames.
		layout = getAuraFrameLayout(frameName),
		optionIndex = containerConfigCache.auraFrameOptionIndex,
	}

	if frameName == "ExtraIconFrame" then
		auraFrameOptions.maxFrameCount = math.huge
	end

	containerConfigCache.auraFrameOptions[frameName] = auraFrameOptions

	Plater.EndLogPerformanceCore("Plater-Core", "Update", "getAuraFrameOptions")
	return auraFrameOptions
end

local function getFullAuraOptions(frameName, key, auraContainer, actorType, force)
	Plater.StartLogPerformanceCore("Plater-Core", "Update", "getFullAuraOptions")
	local cachedAuraOptions = actorType and containerConfigCache.containerFullOptions[actorType][frameName]
	if not force and cachedAuraOptions and cachedAuraOptions.optionIndex == containerConfigCache.containerFullOptionIndex then
		cachedAuraOptions.auraFrameOptions.initializeFrame = function(auraButton) initAuraFrame(auraButton, frameName, key, auraContainer) end -- this needs to be up to date!
		Plater.EndLogPerformanceCore("Plater-Core", "Update", "getFullAuraOptions")
		return cachedAuraOptions
	end
	local fullOptions = {
		auraFrameOptions = getAuraFrameOptions(frameName, key, auraContainer),
		--processingPolicy = {},
		layoutGrowth = {},
		auraFilters = getAuraFilters(frameName, actorType, force),
		borderOptions = getAuraBorderOptions(frameName),
		optionsIndex = actorType and containerConfigCache.containerFullOptionIndex or -1,
		actorType = actorType,
	}

	local horizontalDirection, verticalDirection, anchorPoint = getLayoutGrowthDirection(frameName)
	fullOptions.layoutGrowth.horizontalDirection = horizontalDirection
	fullOptions.layoutGrowth.verticalDirection = verticalDirection
	fullOptions.layoutGrowth.anchorPoint = anchorPoint

	--local policy, policyOptions = getAuraProcessingPolicy(frameName)
	--fullOptions.processingPolicy.policy = policy
	--fullOptions.processingPolicy.policyOptions = policyOptions

	if actorType then
		containerConfigCache.containerFullOptions[actorType][frameName] = fullOptions
	end

	Plater.EndLogPerformanceCore("Plater-Core", "Update", "getFullAuraOptions")
	return fullOptions
end

local allocIndex = 1
--buildGroups gives the container as many aura groups as the actor type that uses the most, a plate taking it then only switches filters.
--without it the container gets its groups when a plate takes it
local function createAuraContainers(unitFrame, buildGroups)
	if not IS_WOW_PROJECT_MIDNIGHT_API_WITH_AURA_CONTAINERS then return end
	if not unitFrame and allocIndex > CONST_MAX_AURA_CONTAINER_SETS then return end
	for _, frameInfo in pairs (auraFramesSetup) do
		local auraContainer = CreateFrame("AuraContainer", "PlaterAuraContainer" .. allocIndex .. frameInfo.frameName, unitFrame or UIParent, "CustomAuraContainerTemplate")
		auraContainer:SetSize(1, 1)
		if unitFrame then
			unitFrame[frameInfo.key] = auraContainer
		end
		-- skip ahead and store
		while AURA_CONTAINER_CACHE[allocIndex] and AURA_CONTAINER_CACHE[allocIndex][frameInfo.key] do
			allocIndex = allocIndex + 1
		end
		AURA_CONTAINER_CACHE[allocIndex] = AURA_CONTAINER_CACHE[allocIndex] or {}
		AURA_CONTAINER_CACHE[allocIndex][frameInfo.key] = auraContainer

		auraContainer.frameInfo = frameInfo
		auraContainer.Name = frameInfo.name
		auraContainer.index = allocIndex

		local options = getFullAuraOptions(frameInfo.name, frameInfo.key, auraContainer, nil)
		if (buildGroups) then
			--friendly players use the friendly npc filters
			for _, actorType in ipairs({"enemynpc", "friendlynpc", "enemyplayer"}) do
				local actorOptions = getFullAuraOptions(frameInfo.name, frameInfo.key, auraContainer, actorType)
				if (#actorOptions.auraFilters > #options.auraFilters) then
					options = actorOptions
				end
			end
		end

		auraContainer.activeOptions = options
		auraContainer.groups = {}
		auraContainer.auraButtons = {}

		--TODO:GROUPS
		local index = 0
		for _, filter in pairs(options.auraFilters) do
			--if DevTool then DevTool:AddData(filter) end
			index = index + 1
			local groupName = "group"..index
			options.auraFrameOptions.candidateFilters = filter.candidateFilters
			auraContainer:AddAuraGroup(groupName, filter.filterString, options.auraFrameOptions)
			auraContainer.groups[groupName] = true
			auraContainer:SetAuraGroupLayout(groupName, options.auraFrameOptions.layout)
		end
		auraContainer:SetFlowLayoutAnchorPoint(options.layoutGrowth.anchorPoint)
		auraContainer:SetFlowLayoutGrowthDirection(options.layoutGrowth.horizontalDirection, options.layoutGrowth.verticalDirection)
		auraContainer:SetFlowLayoutMaximumLineSize(options.auraFrameOptions.layout.maximumLineSize)
		--auraContainer:SetAuraProcessingPolicy(options.processingPolicy.policy, options.processingPolicy.policyOptions)
		--SetAuraLayoutPadding

		auraContainer:SetEnabled(false)

		--the buttons were just created with the current config, the plate taking this container does not need to reskin them
		auraContainer.configIndex = containerConfigCache.containerConfigIndex

		--DevTool:AddData(auraContainer, "create - "..allocIndex)
	end
	allocIndex = allocIndex + 1
end

local nextAuraIndex = 1
local function createOrAllocateAuraContainers(unitFrame)
	Plater.StartLogPerformanceCore("Plater-Core", "Update", "createOrAllocateAuraContainers")
	if nextAuraIndex > allocIndex or not AURA_CONTAINER_CACHE[nextAuraIndex] then
		--if DevTool then DevTool:AddData(unitFrame, "allocate direct create") end
		createAuraContainers(unitFrame)
	else
		--if DevTool then DevTool:AddData(unitFrame, "allocate from cache") end
		local auraContainers = AURA_CONTAINER_CACHE[nextAuraIndex]
		for _, frameInfo in pairs (auraFramesSetup) do
			local container = auraContainers[frameInfo.key]
			unitFrame[frameInfo.key] = container
			container:SetParent(unitFrame)
		end
	end
	nextAuraIndex = nextAuraIndex + 1
	Plater.EndLogPerformanceCore("Plater-Core", "Update", "createOrAllocateAuraContainers")
end

local function preCreateAuraContainers()
	if not IS_WOW_PROJECT_MIDNIGHT_API_WITH_AURA_CONTAINERS then return end
	if allocIndex > CONST_MAX_AURA_CONTAINER_SETS then return end
	Plater.StartLogPerformanceCore("Plater-Core", "Init", "PreCreateAuraContainers")
	local curTime = debugprofilestop()
	local endTime = curTime + 100
	while curTime < endTime and allocIndex <= CONST_MAX_AURA_CONTAINER_SETS do
		createAuraContainers()
		curTime = debugprofilestop()
	end
	Plater.EndLogPerformanceCore("Plater-Core", "Init", "PreCreateAuraContainers")
	C_Timer.After(0, preCreateAuraContainers)
end
function Plater.StartPreCreateAuraContainers()
	if not IS_WOW_PROJECT_MIDNIGHT_API_WITH_AURA_CONTAINERS then return end

	--runs behind the loading screen. the plates shown after it take these sets and only switch their filters,
	--building the groups there instead froze the first frame for 1-2s
	if (DB_AURA_ENABLED) then
		Plater.StartLogPerformanceCore("Plater-Core", "Init", "CreateAuraContainersAtLogin")
		while (allocIndex <= CONST_MAX_AURA_CONTAINER_SETS) do
			createAuraContainers(nil, true)
		end
		Plater.EndLogPerformanceCore("Plater-Core", "Init", "CreateAuraContainersAtLogin")
	end

	C_Timer.After(0, preCreateAuraContainers)
end

function platerInternal.Auras.CreateOldAuraContainers(unitFrame)
	--main buff frames
	local buffFrame = CreateFrame ("frame", unitFrame:GetName() .. "BuffFrame1", unitFrame, BackdropTemplateMixin and "BackdropTemplate")
	buffFrame.amountAurasShown = 0
	buffFrame.PlaterBuffList = {}
	buffFrame.isNameplate = true
	buffFrame.unitFrame = unitFrame --used on resource frame anchor update
	buffFrame.healthBar = unitFrame.healthBar
	buffFrame.AuraCache = {}
	unitFrame.BuffFrame = buffFrame

	--secondary buff frame
	local buffFrame2 = CreateFrame ("frame", unitFrame:GetName() .. "BuffFrame2", unitFrame, BackdropTemplateMixin and "BackdropTemplate")
	buffFrame2 = CreateFrame ("frame", unitFrame:GetName() .. "BuffFrame2", unitFrame, BackdropTemplateMixin and "BackdropTemplate")
	buffFrame2.amountAurasShown = 0
	buffFrame2.PlaterBuffList = {}
	buffFrame2.isNameplate = true
	buffFrame2.unitFrame = unitFrame
	buffFrame2.healthBar = unitFrame.healthBar
	buffFrame2.AuraCache = {}
	unitFrame.BuffFrame2 = buffFrame2

--> identify aura containers
	buffFrame.Name = "Main" --aura frame 1
	buffFrame2.Name = "Secondary" --aura frame 2

	--> store the secondary anchor inside the regular buff container for speed
	buffFrame.BuffFrame2 = buffFrame2
	buffFrame2.BuffFrame1 = buffFrame

	--> unit aura cache
	unitFrame.AuraCache = {}
	unitFrame.GhostAuraCache = {}
	unitFrame.ExtraAuraCache = {}

	--> create the extra icon frame (used for the special aura)
	local options = {
		icon_width = 20, 
		icon_height = 20, 
		texcoord = {.1, .9, .1, .9},
		show_text = true,
	}
	
	unitFrame.ExtraIconFrame = DF:CreateIconRow (unitFrame, "$parentExtraIconRow", options)
	unitFrame.ExtraIconFrame:ClearIcons()
	unitFrame.ExtraIconFrame.RefreshID = 0
	unitFrame.ExtraIconFrame.AuraCache = {}
	unitFrame.ExtraIconFrame.Name = "ExtraIconFrame"
	--> cache the extra icon frame inside the buff frame for speed
	unitFrame.BuffFrame.ExtraIconFrame = unitFrame.ExtraIconFrame
end

--places a part of a dispel pixel glow line on the edge of the glow frame where 'distance' lies, distances run clockwise from
--the top left corner. the part ends at the next corner at the latest, returns its length
local placeDispelPixelGlowPart = function(part, glowFrame, width, height, thickness, distance, length)
	if (distance < width) then
		length = min(length, width - distance)
		part:SetPoint("topleft", glowFrame, "topleft", distance, 0)
		part:SetSize(length, thickness)

	elseif (distance < width + height) then
		distance = distance - width
		length = min(length, height - distance)
		part:SetPoint("topleft", glowFrame, "topleft", width - thickness, -distance)
		part:SetSize(thickness, length)

	elseif (distance < 2 * width + height) then
		distance = distance - width - height
		length = min(length, width - distance)
		part:SetPoint("topleft", glowFrame, "topleft", width - distance - length, thickness - height)
		part:SetSize(length, thickness)

	else
		distance = distance - 2 * width - height
		length = min(length, height - distance)
		part:SetPoint("topleft", glowFrame, "topleft", 0, distance + length - height)
		part:SetSize(thickness, length)
	end

	return length
end

--OnUpdate of the dispel pixel glow: moves its lines along the inner edge of the glow frame. every slot of the dispel glow
--has its own set of lines, all sets are at the same place
local moveDispelPixelGlowLines = function(glowFrame, elapsed)
	--the size of the glow frame is secret (it hangs off the aura container and its lines have a mask on the slot frame),
	--the health bar has the same scale and the glow frame is 'offset' bigger on every side. a negative offset can make it
	--smaller than nothing on a thin health bar
	local width, height = glowFrame.healthBar:GetSize()
	width = max(1, width + 2 * glowFrame.offset)
	height = max(1, height + 2 * glowFrame.offset)
	local perimeter = 2 * (width + height)
	local thickness = glowFrame.thickness
	local lineAmount = glowFrame.lineAmount
	local lineSets = glowFrame.lineSets
	--no longer than the shorter side, so a line goes around one corner at most and has two parts
	local length = min(glowFrame.length, width, height)
	glowFrame.progress = (glowFrame.progress + elapsed * glowFrame.speed) % 1

	for setIndex = 1, #lineSets do
		local lineSet = lineSets[setIndex]
		for i = 1, lineAmount do
			local distance = ((glowFrame.progress + (i - 1) / lineAmount) % 1) * perimeter
			local firstLength = placeDispelPixelGlowPart(lineSet.firstParts[i], glowFrame, width, height, thickness, distance, length)
			local secondPart = lineSet.secondParts[i]
			if (firstLength < length) then
				placeDispelPixelGlowPart(secondPart, glowFrame, width, height, thickness, (distance + firstLength) % perimeter, length - firstLength)
				secondPart:Show()
			else
				secondPart:Hide()
			end
		end
	end
end

--shows the dispel glow style picked in the profile and colors it. the styles belong to aura slot frames, which can be
--locked while auras are secret. there is no event for the end of that, so a locked glow is tried again every second
local applyDispelGlowStyle
applyDispelGlowStyle = function(container)
	for _, glowSlot in ipairs(container.GlowSlots) do
		if (not glowSlot.slotFrame:CanBeAccessedInContext() or not glowSlot.glow:CanBeAccessedInContext()) then
			container.glowColorTimer = C_Timer.NewTimer(1, function() applyDispelGlowStyle(container) end)
			return
		end
	end

	local profile = Plater.db.profile
	local glowColor = profile.aura_dispel_glow_color

	--colored by type, the regions of the style in use are dispel type textures: blizzard shows them and colors them from
	--the dispel type of the aura in the slot. auras without a type get the glow color
	local dispelTypeOptions
	if (profile.aura_dispel_glow_color_by_type) then
		dispelTypeOptions = {
			showAlways = true,
			style = Enum.CustomAuraButtonDispelTypeTextureStyle.PreserveAsset,
			customDispelColorCurve = buildBorderColorCurve(profile.aura_border_colors, true, glowColor),
		}
	end

	local glowType = profile.aura_dispel_glow_type
	local glowSize = profile.aura_dispel_glow_size
	local lineAmount = profile.aura_dispel_glow_pixel_lines
	if (glowType == "ants") then
		lineAmount = CONST_DISPEL_ANTS_AMOUNT
	end

	for _, glowSlot in ipairs(container.GlowSlots) do
		local slotFrame = glowSlot.slotFrame
		--a cleared texture keeps the state blizzard gave it, so every region is set again below
		slotFrame:ClearDispelTypeTextures()

		for styleName, regions in pairs(glowSlot.styles) do
			local isStyleInUse = styleName == glowType
			for _, region in ipairs(regions) do
				if (isStyleInUse and dispelTypeOptions) then
					slotFrame:AddDispelTypeTexture(region, dispelTypeOptions)
				else
					region:SetShown(isStyleInUse)
					region:SetVertexColor(glowColor[1], glowColor[2], glowColor[3], glowColor[4])
				end
			end
		end

		--the lines are outside of the slot frame, so they can't be dispel type textures. colored by type, the lines of the
		--enrage slot get the enrage color, the other slot covers several types and keeps the glow color
		local lineColor = (glowSlot.isEnrage and dispelTypeOptions) and profile.aura_border_colors.enrage or glowColor
		local lineSet = glowSlot.lineSet
		--the OnUpdate shows the second parts of the lines in use when they go around a corner
		for i = 1, CONST_DISPEL_PIXEL_MAX_LINES do
			local firstPart = lineSet.firstParts[i]
			local secondPart = lineSet.secondParts[i]
			firstPart:SetShown(i <= lineAmount)
			firstPart:SetVertexColor(lineColor[1], lineColor[2], lineColor[3], lineColor[4])
			secondPart:SetVertexColor(lineColor[1], lineColor[2], lineColor[3], lineColor[4])
			if (i > lineAmount) then
				secondPart:Hide()
			end
		end
	end

	--the container scale sets the thickness of the glow and the border, a region scale would move their anchor offsets
	--without the slice margins of the glow. the frame of the lines keeps the scale of the health bar
	container:SetScale(CONST_DISPEL_GLOW_SCALE * glowSize)
	local pixelGlowFrame = container.PixelGlowFrame
	pixelGlowFrame:SetScale(1 / (CONST_DISPEL_GLOW_SCALE * glowSize))

	--the pixel glow and the ants are both moving lines, the ants are square lines of the glow size
	local isPixelGlow = glowType == "pixel" or glowType == "ants"
	pixelGlowFrame:SetShown(isPixelGlow)
	if (isPixelGlow) then
		local speed = profile.aura_dispel_glow_pixel_speed
		local length = profile.aura_dispel_glow_pixel_length
		local thickness = profile.aura_dispel_glow_pixel_thickness
		if (glowType == "ants") then
			speed = 1 / CONST_DISPEL_ANTS_DURATION
			thickness = max(1, floor(CONST_DISPEL_ANTS_SIZE * glowSize + 0.5))
			length = thickness
		end

		--the lines run along the inner edge of the glow frame. at profile offset 0 they are outside of the health bar on its
		--border, so the offset of the frame is the profile offset plus their thickness
		local offset = profile.aura_dispel_glow_pixel_offset + thickness
		pixelGlowFrame:SetPoint("topleft", container, "topleft", -offset, offset)
		pixelGlowFrame:SetPoint("bottomright", container, "bottomright", offset, -offset)
		pixelGlowFrame.offset = offset
		pixelGlowFrame.lineAmount = lineAmount
		pixelGlowFrame.speed = speed
		pixelGlowFrame.length = length
		pixelGlowFrame.thickness = thickness
	end

	container.configIndex = containerConfigCache.containerConfigIndex
	container.glowColorTimer = nil
end

--adds an aura slot of the dispel glow with every glow style. 'candidateFilters' picks the auras of the slot, 'isEnrage' marks
--the slot of enrage effects, whose lines get the enrage color. the engine shows the slot frame while such an aura is on the unit
local addDispelGlowSlot = function(container, slotKey, candidateFilters, isEnrage)
	local index = #container.GlowSlots + 1
	local pixelGlowFrame = container.PixelGlowFrame

	container:AddAuraSlot(slotKey, "HELPFUL|RAID_PLAYER_DISPELLABLE", {
		candidateFilters = candidateFilters,
		--the slot frame is locked while auras are secret, so everything it needs is done in here
		initializeFrame = function(slotFrame)
			--the slot frame is a button, it takes no mouse input so it does not take the clicks on the health bar
			slotFrame:SetMouseMotionEnabled(false)
			slotFrame:SetMouseClickEnabled(false)

			--the slot frame runs no addon scripts and takes no other parent, so the moving lines of the pixel glow are outside of it.
			--a mask standing on top of the slot frame shows them: hidden, the slot frame has no height and the mask is one mask size
			--below the lines, shown it covers them. the slot frame stands on a foot frame far below the health bar.
			--an anchor to a collapsed frame loses its offset, so all anchors to the slot frame are without one
			local footFrame = CreateFrame("frame", container:GetName() .. "PixelGlowFoot" .. index, container.maskFrame, "DisableUntrustedLayoutScriptsTemplate")
			footFrame:SetSize(1, 1)
			footFrame:SetPoint("bottomleft", container, "bottomleft", -CONST_DISPEL_PIXEL_MASK_SIZE / 2, -CONST_DISPEL_PIXEL_MASK_SIZE * 1.5)
			slotFrame:SetSize(1, CONST_DISPEL_PIXEL_MASK_SIZE)
			slotFrame:SetCollapsesLayout(true)
			slotFrame:SetPoint("bottomleft", footFrame, "bottomleft", 0, 0)

			local pixelGlowMask = container.maskFrame:CreateMaskTexture()
			--stretched this far, linear filtering fades the outer half pixel of the 8x8 texture to black over hundreds of pixels
			pixelGlowMask:SetTexture([[Interface\BUTTONS\WHITE8X8]], "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE", "NEAREST")
			pixelGlowMask:SetSize(CONST_DISPEL_PIXEL_MASK_SIZE, CONST_DISPEL_PIXEL_MASK_SIZE)
			pixelGlowMask:SetPoint("bottomleft", slotFrame, "topleft", 0, 0)

			--every style is built here since the slot frame is locked afterwards, applyDispelGlowStyle shows the one in use.
			--animations are registered as aura shown animations: blizzard plays them when the slot shows and stops them when it hides

			--the texture is black with the glow around a hollow bar, the bar starts 38 pixels from the sides and 24 from top and bottom.
			--sliced, so the glow keeps its thickness on every health bar size
			local createGlowTexture = function()
				local glow = slotFrame:CreateTexture(nil, "overlay")
				glow:SetTexture([[Interface\AddOns\Plater\images\nameplate_glow]])
				glow:SetTextureSliceMargins(44, 30, 44, 30)
				glow:SetBlendMode("ADD")
				glow:SetPoint("topleft", container, "topleft", -38, 24)
				glow:SetPoint("bottomright", container, "bottomright", 38, -24)
				return glow
			end

			local glow = createGlowTexture()

			local pulseGlow = createGlowTexture()
			local pulseAnimation = pulseGlow:CreateAnimationGroup()
			pulseAnimation:SetLooping("BOUNCE")
			local alphaAnimation = pulseAnimation:CreateAnimation("Alpha")
			alphaAnimation:SetFromAlpha(1)
			alphaAnimation:SetToAlpha(0.2)
			alphaAnimation:SetDuration(0.5)
			slotFrame:AddAuraShownAnimation(pulseAnimation)

			--four solid lines around the health bar
			local borderTop = slotFrame:CreateTexture(nil, "overlay")
			borderTop:SetPoint("topleft", container, "topleft", -CONST_DISPEL_BORDER_SIZE, CONST_DISPEL_BORDER_SIZE)
			borderTop:SetPoint("bottomright", container, "topright", CONST_DISPEL_BORDER_SIZE, 0)
			local borderBottom = slotFrame:CreateTexture(nil, "overlay")
			borderBottom:SetPoint("topleft", container, "bottomleft", -CONST_DISPEL_BORDER_SIZE, 0)
			borderBottom:SetPoint("bottomright", container, "bottomright", CONST_DISPEL_BORDER_SIZE, -CONST_DISPEL_BORDER_SIZE)
			local borderLeft = slotFrame:CreateTexture(nil, "overlay")
			borderLeft:SetPoint("topleft", container, "topleft", -CONST_DISPEL_BORDER_SIZE, 0)
			borderLeft:SetPoint("bottomright", container, "bottomleft", 0, 0)
			local borderRight = slotFrame:CreateTexture(nil, "overlay")
			borderRight:SetPoint("topleft", container, "topright", 0, 0)
			borderRight:SetPoint("bottomright", container, "bottomright", CONST_DISPEL_BORDER_SIZE, 0)

			local borders = {borderTop, borderBottom, borderLeft, borderRight}
			for _, border in ipairs(borders) do
				border:SetColorTexture(1, 1, 1, 1)
			end

			--the lines of this slot for the pixel and the ants styles. every line has two parts, one for each side of the corner it
			--goes around. the mask can only be added in here. the enrage lines are drawn above the others
			local lineSet = {firstParts = {}, secondParts = {}}
			local createLinePart = function()
				local part = pixelGlowFrame:CreateTexture(nil, "overlay", nil, isEnrage and 1 or 0)
				part:SetColorTexture(1, 1, 1, 1)
				part:AddMaskTexture(pixelGlowMask)
				return part
			end

			for i = 1, CONST_DISPEL_PIXEL_MAX_LINES do
				lineSet.firstParts[i] = createLinePart()
				lineSet.secondParts[i] = createLinePart()
			end

			pixelGlowFrame.lineSets[index] = lineSet

			container.GlowSlots[index] = {
				slotFrame = slotFrame,
				glow = glow,
				lineSet = lineSet,
				isEnrage = isEnrage,
				--keys are the values of the aura_dispel_glow_type profile key, except "pixel" and "ants"
				styles = {
					glow = {glow},
					pulse = {pulseGlow},
					border = borders,
				},
			}

			applyDispelGlowStyle(container)
		end,
	})
end

--makes the nameplate glow while the unit has an aura the player can dispel, purge or soothe. the auras are secret, so aura
--slots do the work, one for enrage effects and one for everything else. 'unit' is nil when the nameplate is removed
local updateDispelGlow = function(unitFrame, unit)
	local profile = Plater.db.profile
	local isEnabled = unit and profile.aura_dispel_glow
	local container = unitFrame.DispelGlowFrame

	if (not container) then
		if (not isEnabled) then
			return
		end

		container = CreateFrame("AuraContainer", "$parentDispelGlowFrame", unitFrame.healthBar, "CustomAuraContainerTemplate")
		container:SetScale(CONST_DISPEL_GLOW_SCALE)
		container:SetAllPoints()
		container:SetEnabled(false)
		--with the preview on, the container reads the edit mode source instead of the unit's auras
		container:SetEditModePreviewEnabled(false)
		container.GlowSlots = {}
		unitFrame.DispelGlowFrame = container

		--owns the masks of the pixel glow and the foot frames of the slots, this template is what allows anchoring them to the slot frames
		container.maskFrame = CreateFrame("frame", container:GetName() .. "PixelGlowMask", container, "DisableUntrustedLayoutScriptsTemplate")
		container.maskFrame:SetAllPoints()

		--the frame of the pixel and the ants styles, its options are in health bar pixels instead of dispel glow units
		local pixelGlowFrame = CreateFrame("frame", container:GetName() .. "PixelGlow", container)
		pixelGlowFrame:Hide()
		pixelGlowFrame.lineSets = {}
		pixelGlowFrame.progress = 0
		pixelGlowFrame.healthBar = unitFrame.healthBar
		pixelGlowFrame:SetScript("OnUpdate", moveDispelPixelGlowLines)
		container.PixelGlowFrame = pixelGlowFrame

		addDispelGlowSlot(container, "dispel", {excludeDispelTypes = {Enrage = true}}, false)
		addDispelGlowSlot(container, "enrage", {includeDispelTypes = {Enrage = true}}, true)
	end

	if (not isEnabled) then
		--a slot keeps its last state while the container is disabled, so the container is hidden as well
		container:SetEnabled(false)
		container:Hide()
		return
	end

	if (container.configIndex ~= containerConfigCache.containerConfigIndex and not container.glowColorTimer) then
		applyDispelGlowStyle(container)
	end

	--buffs are removed from enemies and debuffs from friends. without the split a debuff on an enemy matches as well
	local filterString = UnitCanAssist("player", unit) and "HARMFUL|RAID_PLAYER_DISPELLABLE" or "HELPFUL|RAID_PLAYER_DISPELLABLE"
	container:SetAuraSlotFilterString("dispel", filterString)
	container:SetAuraSlotFilterString("enrage", filterString)
	container:SetEnabled(true)
	container:SetUnit(unit)
	container:Show()
end

--per aura healthbar colors ~auracolor
--creates a mask of the per aura healthbar colors with its bottom edge on the top edge of 'anchorFrame'.
--it covers the health bar while that bottom edge is 10 below the bottom of the bar, any other position is a slot height away from the bar.
--with 'pillarName' the mask sits one slot height higher, on top of a frame of that name, which is returned too.
--an anchor to a collapsed frame loses its offset, so the height is added by that frame instead of an offset
local createAuraColorMask = function(maskFrame, anchorFrame, pillarName)
	if (pillarName) then
		local pillarFrame = CreateFrame("Frame", pillarName, maskFrame, "DisableUntrustedLayoutScriptsTemplate")
		pillarFrame:SetSize(1, CONST_AURA_COLOR_SLOT_HEIGHT)
		pillarFrame:SetPoint("bottomleft", anchorFrame, "topleft", 0, 0)
		anchorFrame = pillarFrame
	end

	local mask = maskFrame:CreateMaskTexture()
	--stretched this far, linear filtering fades the outer half pixel of the 8x8 texture to black over 125 pixels, a fade across the whole bar
	mask:SetTexture([[Interface\BUTTONS\WHITE8X8]], "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE", "NEAREST")
	mask:SetSize(CONST_AURA_COLOR_MASK_WIDTH, CONST_AURA_COLOR_SLOT_HEIGHT / 2)
	mask:SetPoint("bottomleft", anchorFrame, "topleft", 0, 0)
	return mask, anchorFrame
end

--creates one color of the per aura healthbar colors: a copy of the bar texture directly above it, below every other texture of the health bar
local createAuraColorTint = function(healthBar)
	local tint = healthBar:CreateTexture(nil, "artwork", nil, 2)
	tint:SetTexture(healthBar.barTexture:GetTexture())
	tint:SetPoint("topleft", healthBar.barTexture, "topleft", 0, 0)
	tint:SetPoint("bottomright", healthBar.barTexture, "bottomright", 0, 0)
	return tint
end

--builds the slots of the per aura healthbar colors from the profile, ordered by priority. the result is cached until the aura filters change
local getAuraColorSlots = function()
	if (containerConfigCache.auraColorSlotsIndex == containerConfigCache.candidateFilterIndex) then
		return containerConfigCache.auraColorSlots
	end

	local entries = {}
	for spellId, colorTable in pairs(Plater.db.profile.aura_colors) do
		if (colorTable[1]) then
			entries[#entries+1] = {spellId, colorTable}
		end
	end

	--higher priority first, equal priorities are ordered by the spell key to keep the result stable
	table.sort(entries, function(entry1, entry2)
		local priority1 = entry1[2][5]
		local priority2 = entry2[2][5]
		if (priority1 ~= priority2) then
			return priority1 > priority2
		end

		return tostring(entry1[1]) < tostring(entry2[1])
	end)

	local colorSlots = {}
	local slot
	for _, entry in ipairs(entries) do
		local spellId = entry[1]
		local colorTable = entry[2]
		local colorName = colorTable[2]
		local pandemicColorName = colorTable[6]
		local playerFilter = colorTable[4] and "|PLAYER" or ""

		--entries following each other with the same colors and caster filter share a slot
		local isSameSlot = slot and slot.colorName == colorName and slot.pandemicColorName == pandemicColorName and slot.playerFilter == playerFilter
		if (not isSameSlot) then
			slot = {spellIds = {}, colorName = colorName, pandemicColorName = pandemicColorName, playerFilter = playerFilter}
			colorSlots[#colorSlots+1] = slot
		end

		slot.spellIds[spellId] = true

		--a string key is a spell name, a number key tracked by name uses its spell name
		local spellName
		if (type(spellId) == "string") then
			spellName = spellId

		elseif (colorTable[3]) then
			spellName = GetSpellInfo(spellId)
		end

		--tracked by name: add all spell ids with that name, expandAuraCaches() resolved them
		local sameNameIds = spellName and DB_AURA_NAME_CACHE[string.lower(spellName)]
		if (sameNameIds) then
			for _, sameNameId in pairs(sameNameIds) do
				slot.spellIds[sameNameId] = true
			end
		end
	end

	containerConfigCache.auraColorSlots = colorSlots
	containerConfigCache.auraColorSlotsIndex = containerConfigCache.candidateFilterIndex
	return colorSlots
end

--creates and updates the hidden aura container which colors the health bar while a configured aura is active. 'unit' is nil when the nameplate is removed
local updateAuraColorContainer = function(unitFrame, unit)
	local colorSlots = getAuraColorSlots()
	local healthBar = unitFrame.healthBar
	local barTexture = healthBar.barTexture
	local container = unitFrame.AuraColorFrame

	if (not container) then
		if (not unit or #colorSlots == 0) then
			return
		end

		container = CreateFrame("AuraContainer", "$parentAuraColorFrame", healthBar, "CustomAuraContainerTemplate")
		container:SetAllPoints()
		container:SetEnabled(false)
		--the colors are no edit mode element: with the preview on, the container reads the edit mode source instead of the unit's auras
		container:SetEditModePreviewEnabled(false)
		--owns the masks, this template is what allows anchoring them to the slot frames
		container.maskFrame = CreateFrame("Frame", "$parentAuraColorMasks", healthBar, "DisableUntrustedLayoutScriptsTemplate")
		container.maskFrame:SetAllPoints()
		container.slotFrames = {}
		container.tints = {}
		container.pandemicTints = {}
		unitFrame.AuraColorFrame = container

		--the colors copy the bar art on every change of it. the first nameplate added gets here before the skin sets the bar texture
		hooksecurefunc(barTexture, "SetTexture", function(_, texture)
			for index, tint in ipairs(container.tints) do
				tint:SetTexture(texture)
				container.pandemicTints[index]:SetTexture(texture)
			end
		end)
	end

	if (container.filterIndex ~= containerConfigCache.candidateFilterIndex) then
		--after login a slot frame is locked as soon as its initializeFrame returns, and so is everything anchored to it.
		--so a new slot never uses anything of an older slot: it is added at the base of the stack, the slots added before it stand on top of it.
		--a slot is never removed, the stack only grows
		for index = #container.slotFrames + 1, #colorSlots do
			--a texture is drawn only where all of its masks cover it, each mask checks one condition. a texture takes at most 3 masks,
			--the colors already end at the bar fill and need no mask of the health bar.
			--the color and the pandemic color of a slot, the masks keep only one of the two on the bar
			local tint = createAuraColorTint(healthBar)
			local pandemicTint = createAuraColorTint(healthBar)
			container.tints[index] = tint
			container.pandemicTints[index] = pandemicTint

			--the slot stands on this frame, which never hides and is no slot frame. it starts at the base of the stack,
			--the next slot moves it on top of itself
			local footFrame = CreateFrame("Frame", container:GetName() .. "Foot" .. index, container.maskFrame, "DisableUntrustedLayoutScriptsTemplate")
			footFrame:SetSize(1, 1)
			footFrame:SetPoint("bottomleft", healthBar, "bottomleft", -10, -10 - CONST_AURA_COLOR_SLOT_HEIGHT)

			container.slotFrames[index] = container:AddAuraSlot(tostring(index), "HARMFUL", {
				--of several matching auras the player's own and then the one expiring first decides about the pandemic color
				sortMethod = AuraContainerSortMethod.Expiration,
				sortDirection = AuraContainerSortDirection.Normal,
				--the slot frame is locked once this returns, so everything anchored to it is done in here
				initializeFrame = function(slotFrame)
					--the slot frame is a button, it stays one pixel wide and doesn't take the mouse
					slotFrame:SetMouseMotionEnabled(false)
					slotFrame:SetMouseClickEnabled(false)
					slotFrame:SetSize(1, CONST_AURA_COLOR_SLOT_HEIGHT)
					--a frame anchored to a hidden slot takes the anchor of the slot instead, but only one level deep, so foot frames and
					--slots take turns. the foot frame of the slot added before this one moves on top of this slot: it rises by one slot height
					--while this slot is shown, and so does everything standing on it
					slotFrame:SetCollapsesLayout(true)
					slotFrame:SetPoint("bottomleft", footFrame, "bottomleft", 0, 0)

					--the foot frame of the base slot only has the health bar as anchor, nothing locked depends on it yet
					if (container.baseFootFrame) then
						container.baseFootFrame:SetPoint("bottomleft", slotFrame, "topleft", 0, 0)
					end

					container.baseFootFrame = footFrame

					--no slot below this one is shown: one slot height above its foot frame it is still at the base of the stack
					local noneBelowMask = createAuraColorMask(container.maskFrame, footFrame, container:GetName() .. "NoneBelow" .. index)
					tint:AddMaskTexture(noneBelowMask)
					pandemicTint:AddMaskTexture(noneBelowMask)

					--with no slot below, this slot is shown: its top edge is one slot height above the base of the stack
					local isShownMask = createAuraColorMask(container.maskFrame, slotFrame)
					tint:AddMaskTexture(isShownMask)
					pandemicTint:AddMaskTexture(isShownMask)

					--the engine shows this frame while the aura of the slot is in its pandemic window, hidden it has no height
					local pandemicFrame = CreateFrame("Frame", container:GetName() .. "Pandemic" .. index, slotFrame, "DisableUntrustedLayoutScriptsTemplate")
					pandemicFrame:SetSize(1, CONST_AURA_COLOR_SLOT_HEIGHT)
					pandemicFrame:SetCollapsesLayout(true)
					pandemicFrame:SetPoint("bottomleft", healthBar, "bottomleft", -10, -10 - CONST_AURA_COLOR_SLOT_HEIGHT)
					slotFrame:AddPandemicRegion(pandemicFrame)

					--outside the pandemic window the pandemic frame is hidden and the color is shown, inside the window the pandemic color
					tint:AddMaskTexture(createAuraColorMask(container.maskFrame, pandemicFrame, container:GetName() .. "OutsidePandemic" .. index))
					pandemicTint:AddMaskTexture(createAuraColorMask(container.maskFrame, pandemicFrame))
				end,
			})
		end

		--the lower a slot in the stack, the higher its priority: the last slot is at the base and takes the first color slot.
		--surplus slots are disabled, a disabled slot is cleared and hidden by the engine
		local slotCount = #container.slotFrames
		for index = 1, slotCount do
			local slotKey = tostring(index)
			local slot = colorSlots[slotCount - index + 1]
			container:SetAuraSlotEnabled(slotKey, slot ~= nil)

			if (slot) then
				container:SetAuraSlotCandidateFilters(slotKey, {includeSpellIDs = slot.spellIds})
				container.tints[index]:SetVertexColor(DF:ParseColors(slot.colorName))
				--without a pandemic color the bar keeps its color inside the pandemic window
				container.pandemicTints[index]:SetVertexColor(DF:ParseColors(slot.pandemicColorName or slot.colorName))
			end
		end

		container.filterIndex = containerConfigCache.candidateFilterIndex
	end

	local hasColors = #colorSlots > 0
	local isPerformanceUnit = unitFrame.isPerformanceUnitAura
	local isActive = unit and hasColors and not isPerformanceUnit
	local slotCount = #container.slotFrames
	if (isActive) then
		--spell id filters only apply to debuffs on non-assistable units and buffs on assistable ones
		local filterString = UnitCanAssist("player", unit, true, true) and "HELPFUL" or "HARMFUL"
		for index = 1, slotCount do
			local slot = colorSlots[slotCount - index + 1]
			if (slot) then
				container:SetAuraSlotFilterString(tostring(index), filterString .. slot.playerFilter)
			end
		end

		container:SetEnabled(true)
		container:SetUnit(unit)
		container:UpdateAllAuras()
	else
		container:SetEnabled(false)
	end

	--a slot keeps its last state while the container is disabled, so the colors are hidden by hand
	for index, tint in ipairs(container.tints) do
		local isSlotUsed = isActive and colorSlots[slotCount - index + 1] ~= nil or false
		tint:SetShown(isSlotUsed)
		container.pandemicTints[index]:SetShown(isSlotUsed)
	end
end

function Plater.CreateOrUpdateAuraContainers(unitFrame, unit, forceFull, forceFilters, forceLayout)
	Plater.StartLogPerformanceCore("Plater-Core", "Update", "CreateOrUpdateAuraContainers")
	if IS_WOW_PROJECT_MIDNIGHT_API_WITH_AURA_CONTAINERS and unit ~= "player" then
		
		if not unitFrame.BuffFrame then
			Plater.StartLogPerformanceCore("Plater-Core", "Update", "CreateOrUpdateAuraContainers - createallocate")
			createOrAllocateAuraContainers(unitFrame)

			for _, frameInfo in pairs (auraFramesSetup) do
				
				local auraContainer = unitFrame[frameInfo.key]
				-- some standard plater stuff for compatibility
				auraContainer.unitFrame = unitFrame
				auraContainer.healthBar = unitFrame.healthBar
				auraContainer.PlaterBuffList = {}
				auraContainer.AuraCache = {}
				auraContainer.isNameplate = true

				--DevTool:AddData(auraContainer, "create")
			end

			--> unit aura cache dummy compat
			unitFrame.BuffFrame.amountAurasShown = 0
			unitFrame.BuffFrame2.amountAurasShown = 0
			unitFrame.AuraCache = {}
			unitFrame.GhostAuraCache = {}
			unitFrame.ExtraAuraCache = {}
			unitFrame.BuffFrame.BuffFrame2 = unitFrame.BuffFrame2
			unitFrame.BuffFrame.ExtraIconFrame = unitFrame.ExtraIconFrame
			Plater.EndLogPerformanceCore("Plater-Core", "Update", "CreateOrUpdateAuraContainers - createallocate")
		end

		-- update
		local auraActorType = unitFrame.ActorType == "friendlyplayer" and "friendlynpc" or unitFrame.ActorType -- shared friendly filters
		for _, frameInfo in pairs (auraFramesSetup) do
			local auraContainer = unitFrame[frameInfo.key]
			if DB_AURA_ENABLED and unit then
				if forceFull then
					forceLayout = true
					forceFilters = true
				end
				--if force or auraContainer.activeUnit ~= unit or (auraContainer.activeOptionsType ~= unitFrame.ActorType) or (auraContainer.activeOptionsIndex ~= options.optionsIndex) then
				local shouldUpdate = (auraContainer.activeOptionsType ~= auraActorType) or (auraContainer.activeOptionsIndex ~= containerConfigCache.containerFullOptionIndex)
				if forceFilters or shouldUpdate or forceLayout then
					local options = getFullAuraOptions(frameInfo.name, frameInfo.key, auraContainer, auraActorType, forceFull) -- only build when needed
					--if DevTool then DevTool:AddData({stack = debugstack(), force = force, shouldUpdate = shouldUpdate, forceLayout = forceLayout, forceFull = forceFull, active = auraContainer.activeOptionsType, current = unitFrame.ActorType, activeIndex = auraContainer.activeOptionsIndex, currentIndex = options.optionsIndex, options = options}, "Updating: " .. unit .. " - " .. frameInfo.key) end
					if shouldUpdate or forceLayout then
						Plater.StartLogPerformanceCore("Plater-Core", "Update", "CreateOrUpdateAuraContainers - updatelayout")
						--auraContainer:SetAuraProcessingPolicy(options.processingPolicy.policy, options.processingPolicy.policyOptions) -- currently unused
						auraContainer:SetFlowLayoutMaximumLineSize(options.auraFrameOptions.layout.maximumLineSize)
						auraContainer:SetFlowLayoutAnchorPoint(options.layoutGrowth.anchorPoint)
						auraContainer:SetFlowLayoutGrowthDirection(options.layoutGrowth.horizontalDirection, options.layoutGrowth.verticalDirection)
						Plater.EndLogPerformanceCore("Plater-Core", "Update", "CreateOrUpdateAuraContainers - updatelayout")
					end

					if shouldUpdate or forceFilters then
						Plater.StartLogPerformanceCore("Plater-Core", "Update", "CreateOrUpdateAuraContainers - updatefilters")
						local index = 1
						for _, filter in pairs(options.auraFilters) do
							local groupName = "group"..index
							--if DevTool then DevTool:AddData({hasGroup = auraContainer:HasAuraGroup(groupName), auraContainer = auraContainer, unitFrame = unitFrame}, "update-" .. frameInfo.key .. "-" .. (unit or "nil") .. "-" .. groupName) end
							if not auraContainer.groups[groupName] then
								options.auraFrameOptions.candidateFilters = filter.candidateFilters
								Plater.StartLogPerformanceCore("Plater-Core", "Update", "updatefilters - AddAuraGroup")
								auraContainer:AddAuraGroup(groupName, filter.filterString, options.auraFrameOptions)
								Plater.EndLogPerformanceCore("Plater-Core", "Update", "updatefilters - AddAuraGroup")
								auraContainer.groups[groupName] = true
							end

							if filter.filterString then
								auraContainer:SetAuraGroupCandidateFilters(groupName, filter.candidateFilters)
								auraContainer:SetAuraGroupFilterString(groupName, filter.filterString)

								if shouldUpdate or forceLayout then
									auraContainer:SetAuraGroupMaxFrameCount(groupName, filter.maxFrameCount or options.auraFrameOptions.maxFrameCount)
									auraContainer:SetAuraGroupSortMethod(groupName, options.auraFrameOptions.sortMethod, options.auraFrameOptions.sortDirection)
									auraContainer:SetAuraGroupLayout(groupName, options.auraFrameOptions.layout)
								end

								--enabled last, a group that was disabled is not parsed with its old filters
								auraContainer:SetAuraGroupEnabled(groupName, true)
							else
								auraContainer:SetAuraGroupEnabled(groupName, false)
							end

							index = index + 1
						end

						while (auraContainer.groups["group"..index]) do
							--disable surplus
							--if DevTool then DevTool:AddData({hasGroup = auraContainer:HasAuraGroup(groupName), auraContainer = auraContainer, unitFrame = unitFrame}, "disable-" .. frameInfo.key .. "-" .. (unit or "nil") .. "-" .. "group"..index) end
							auraContainer:SetAuraGroupEnabled("group"..index, false)
							index = index + 1
						end
						Plater.EndLogPerformanceCore("Plater-Core", "Update", "CreateOrUpdateAuraContainers - updatefilters")
					end
					
					if auraContainer.configIndex ~= containerConfigCache.containerConfigIndex then
						reSkinAuraButtons(auraContainer.auraButtons, options)
						auraContainer.configIndex = containerConfigCache.containerConfigIndex
					end

					if auraActorType then
						auraContainer.activeOptionsType = auraActorType
						auraContainer.activeOptions = options
						auraContainer.activeOptionsIndex = options.optionsIndex
						auraContainer.activeUnit = unit
					end
				end

				if auraContainer.enabled and auraContainer.unitToken and auraContainer.unitToken == unit then
					Plater.StartLogPerformanceCore("Plater-Core", "Update", "createOrAllocateAuraContainers - rebuildupdate")
					--auraContainer:RebuildAuraParseFilters()
					auraContainer:UpdateAllAuras()
					--C_Timer.After(0, auraContainer.UpdateAllAuras)
					--auraContainer:Hide()
					auraContainer:Show()
					Plater.EndLogPerformanceCore("Plater-Core", "Update", "createOrAllocateAuraContainers - rebuildupdate")
				else 
					auraContainer:SetEnabled(true)
					auraContainer:SetUnit(unit)
					auraContainer:Show()
				end
			else
				--auraContainer:SetUnit("player") -- dummy
				auraContainer:SetEnabled(false)
				auraContainer:Hide()
			end

			--auraContainer:SetEnabled(DB_AURA_ENABLED and unit and true or false)

			--if DevTool then DevTool:AddData({auraContainer = auraContainer, unitFrame = unitFrame, debugstack = debugstack()}, "update - " .. (unit or "nil")) end
		end

		updateDispelGlow(unitFrame, unit)
		updateAuraColorContainer(unitFrame, unit)

	elseif not unitFrame.BuffFrame then -- old API
		platerInternal.Auras.CreateOldAuraContainers(unitFrame)
	end
	Plater.EndLogPerformanceCore("Plater-Core", "Update", "CreateOrUpdateAuraContainers")
end

function Plater.RemoveFromAuraUpdate (unit, unitFrame)
	Plater.StartLogPerformanceCore("Plater-Core", "Update", "RemoveFromAuraUpdate")
	if IS_WOW_PROJECT_MIDNIGHT_API_WITH_AURA_CONTAINERS then
		Plater.CreateOrUpdateAuraContainers(unitFrame, nil)
		Plater.EndLogPerformanceCore("Plater-Core", "Update", "RemoveFromAuraUpdate")
		return
	end
	if not unit or not unitFrame then return end
	unitFrame.UnitAuraEventHandlerFrame = unitFrame.UnitAuraEventHandlerFrame or CreateFrame ("frame")
	unitFrame.UnitAuraEventHandlerFrame:UnregisterEvent("UNIT_AURA")
	unitFrame.UnitAuraEventHandlerFrame:SetScript ("OnEvent", nil)
	UnitAuraCacheData[unit] = nil
	UnitAuraEventHandlerData[unit] = nil
	Plater.EndLogPerformanceCore("Plater-Core", "Update", "RemoveFromAuraUpdate")
end

function Plater.AddToAuraUpdate (unit, unitFrame)
	if not unit or not unitFrame then return end
	Plater.StartLogPerformanceCore("Plater-Core", "Update", "AddToAuraUpdate")
	if IS_WOW_PROJECT_MIDNIGHT_API_WITH_AURA_CONTAINERS then
		Plater.CreateOrUpdateAuraContainers(unitFrame, unit)
		--Plater.CreateOrUpdateAuraContainers(unitFrame, unit, false, true)
		Plater.EndLogPerformanceCore("Plater-Core", "Update", "AddToAuraUpdate")
		return
	end
	unitFrame.UnitAuraEventHandlerFrame = unitFrame.UnitAuraEventHandlerFrame or CreateFrame ("frame")
	unitFrame.UnitAuraEventHandlerFrame:SetScript ("OnEvent", UnitAuraEventHandler)
	unitFrame.UnitAuraEventHandlerFrame:RegisterUnitEvent("UNIT_AURA", unit)
	UnitAuraEventHandlerData[unit] = { hasBuff = true, hasDebuff = true } --update at least once
	--UpdateUnitAuraCacheData(unit, {isFullUpdate = true})
	UpdateUnitAuraCacheData(unit, nil)
	Plater.EndLogPerformanceCore("Plater-Core", "Update", "AddToAuraUpdate")
end


UpdateUnitAuraCacheData = function (unit, updatedAuras)
	--DevTool:AddData({unit = unit, updatedAuras = updatedAuras}, "Plater_UpdateUnitAuraCacheData - " .. (unit or "N/A"))
	local unitCacheData = UnitAuraCacheData[unit]
	if not unitCacheData then
		unitCacheData = {}
		unitCacheData.buffs = {}
		unitCacheData.debuffs = {}
		unitCacheData.buffsInOrder = {}
		unitCacheData.debuffsInOrder = {}
		UnitAuraCacheData[unit] = unitCacheData
	end
	
	if IS_WOW_PROJECT_MIDNIGHT and not updatedAuras then
		UnitAuraCacheData[unit] = {}
		UnitAuraCacheData[unit].buffs = {}
		UnitAuraCacheData[unit].debuffs = {}
		UnitAuraCacheData[unit].buffsInOrder = {}
		UnitAuraCacheData[unit].debuffsInOrder = {}
		UnitAuraCacheData[unit].buffsChanged = true
		UnitAuraCacheData[unit].debuffsChanged = true
		UnitAuraCacheData[unit].isFullUpdateHelp = true
		UnitAuraCacheData[unit].isFullUpdateHarm = true
		UnitAuraEventHandlerData[unit] = { hasBuff = true, hasDebuff = true }
		return
	elseif not IS_WOW_PROJECT_MIDNIGHT and updatedAuras == nil or updatedAuras.isFullUpdate then
		UnitAuraCacheData[unit] = {}
		UnitAuraCacheData[unit].buffs = {}
		UnitAuraCacheData[unit].debuffs = {}
		UnitAuraCacheData[unit].buffsInOrder = {}
		UnitAuraCacheData[unit].debuffsInOrder = {}
		UnitAuraCacheData[unit].buffsChanged = true
		UnitAuraCacheData[unit].debuffsChanged = true
		UnitAuraCacheData[unit].isFullUpdateHelp = (updatedAuras == nil and true) or updatedAuras.isFullUpdate or false
		UnitAuraCacheData[unit].isFullUpdateHarm = (updatedAuras == nil and true) or updatedAuras.isFullUpdate or false
		UnitAuraEventHandlerData[unit] = { hasBuff = true, hasDebuff = true }
		return
	end
	
	unitCacheData.tbd = {}
	
	for _, aura in ipairs(updatedAuras.addedAuras or {}) do
		local needsUpdate = ValidateAuraForUpdate(unit, aura)
		if needsUpdate then
			setAdditionalAuraFields(aura, unit)
			
			if IS_WOW_PROJECT_MIDNIGHT then
				aura.isHarmful = not C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, aura.auraInstanceID, "HARMFUL")
				aura.isHelpful = not C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, aura.auraInstanceID, "HELPFUL")
				--print(aura.isHarmful, aura.isHelpful)
			end
			
			if aura.isHarmful then
				unitCacheData.debuffs[aura.auraInstanceID] = aura
				unitCacheData.debuffsChanged = true
			elseif aura.isHelpful then
				unitCacheData.buffs[aura.auraInstanceID] = aura
				unitCacheData.buffsChanged = true
			end
		end
	end
	
	for _, auraInstanceID in ipairs(updatedAuras.updatedAuraInstanceIDs or {}) do
		if unitCacheData.debuffs[auraInstanceID] ~= nil then
			unitCacheData.debuffs[auraInstanceID].requiresUpdate = true
			unitCacheData.debuffsChanged = true
		elseif unitCacheData.buffs[auraInstanceID] ~= nil then
			unitCacheData.buffs[auraInstanceID].requiresUpdate = true
			unitCacheData.buffsChanged = true
		else
			unitCacheData.tbd[auraInstanceID] = true
			unitCacheData.tbdChanged = true
		end
	end
	
	for _, auraInstanceID in ipairs(updatedAuras.removedAuraInstanceIDs or {}) do
		if unitCacheData.debuffs[auraInstanceID] ~= nil then
			unitCacheData.debuffs[auraInstanceID] = nil
			unitCacheData.debuffsChanged = true
		elseif unitCacheData.buffs[auraInstanceID] ~= nil then
			unitCacheData.buffs[auraInstanceID] = nil
			unitCacheData.buffsChanged = true
		else
			unitCacheData.tbd[auraInstanceID] = true
			unitCacheData.tbdChanged = true
		end
	end
	
	if unitCacheData.tbdChanged then
		for index, _ in pairs(unitCacheData.tbd) do
			local aura = GetAuraDataByAuraInstanceID(unit, index)
			if aura then
				if IS_WOW_PROJECT_MIDNIGHT then
					aura.isHarmful = not C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, aura.auraInstanceID, "HARMFUL")
					aura.isHelpful = not C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, aura.auraInstanceID, "HELPFUL")
					--print(aura.isHarmful, aura.isHelpful)
				end
			
				if aura.isHarmful then
					unitCacheData.debuffs[aura.auraInstanceID] = aura
					unitCacheData.debuffsChanged = true
				elseif aura.isHelpful then
					unitCacheData.buffs[aura.auraInstanceID] = aura
					unitCacheData.buffsChanged = true
				end
			end
		end
	end
	
	unitCacheData.tbd = nil
	unitCacheData.tbdChanged = nil
	
	local existingData = UnitAuraEventHandlerData[unit] or { hasBuff = false, hasDebuff = false }
	local hasDebuff = existingData.hasDebuff or unitCacheData.debuffsChanged or not DB_AURA_SEPARATE_BUFFS or false
	local hasBuff = existingData.hasBuff or unitCacheData.buffsChanged or not DB_AURA_SEPARATE_BUFFS or false
	UnitAuraEventHandlerData[unit] = { hasBuff = hasBuff, hasDebuff = hasDebuff }
end

local function getUnitAuras(unit, filter)
	if not unit then return end
	
	local isHarmful = string.find(filter or "HARMFUL", "HARMFUL") and true or false
	local isHelpful = string.find(filter or "HELPFUL", "HELPFUL") and true or false
	
	--if IS_WOW_PROJECT_MIDNIGHT then filter = "INCLUDE_NAME_PLATE_ONLY" end
	--if IS_WOW_PROJECT_MIDNIGHT then filter = filter and (filter .. "|PLAYER") or "PLAYER" end
	--print (filter)
	local unitCacheData = UnitAuraCacheData[unit]
	--DevTool:AddData({unitCacheData, filter = filter, isFullUpdateHarm = unitCacheData.isFullUpdateHarm, isFullUpdateHelp = unitCacheData.isFullUpdateHelp, update = ((isHarmful and  not unitCacheData.isFullUpdateHarm) or (isHelpful and not unitCacheData.isFullUpdateHelp))}, "getUnitAuras - " .. unit)
	
	if unitCacheData and ((isHarmful and not unitCacheData.isFullUpdateHarm) or (isHelpful and not unitCacheData.isFullUpdateHelp)) then --new aura event
		Plater.StartLogPerformanceCore("Plater-Core", "Update", "UpdateAuras - getUnitAuras - short")
		-- debuffs
		if unitCacheData.debuffsChanged then
			local tmpDebuffs = {}
			for auraInstanceID, aura in pairs (unitCacheData.debuffs) do
				if aura.requiresUpdate then
					tmpDebuffs[auraInstanceID] = GetAuraDataByAuraInstanceID(unit, auraInstanceID)
				else
					tmpDebuffs[auraInstanceID] = aura
				end
			end
			if C_UnitAuras.GetUnitAuras then
				unitCacheData.debuffsInOrder = C_UnitAuras.GetUnitAuras(unit, "HARMFUL", nil, IS_WOW_PROJECT_MIDNIGHT and (Plater.db.profile.aura_sort and Enum.UnitAuraSortRule.Expiration or Enum.UnitAuraSortRule.Unsorted) or nil)
			end
			unitCacheData.debuffs = tmpDebuffs
			unitCacheData.debuffsChanged = false
		end
		
		-- buffs
		if unitCacheData.buffsChanged then
			local tmpBuffs = {}
			for auraInstanceID, aura in pairs (unitCacheData.buffs) do
				if aura.requiresUpdate then
					tmpBuffs[auraInstanceID] = GetAuraDataByAuraInstanceID(unit, auraInstanceID)
				else
					tmpBuffs[auraInstanceID] = aura
				end
			end
			if C_UnitAuras.GetUnitAuras then
				unitCacheData.buffsInOrder = C_UnitAuras.GetUnitAuras(unit, "HELPFUL", nil, IS_WOW_PROJECT_MIDNIGHT and (Plater.db.profile.aura_sort and Enum.UnitAuraSortRule.Expiration or Enum.UnitAuraSortRule.Unsorted) or nil)
			end
			unitCacheData.buffs = tmpBuffs
			unitCacheData.buffsChanged = false
		end
		
		Plater.EndLogPerformanceCore("Plater-Core", "Update", "UpdateAuras - getUnitAuras - short")
		return unitCacheData
	end
	
	if not filter then return end --old code requires this.
	unitCacheData = unitCacheData or {debuffs = {}, buffs = {}, debuffsInOrder = {}, buffsInOrder = {}}
	UnitAuraCacheData[unit] = unitCacheData
	
	-- full updates and old way here
	local filterCache = (isHarmful and unitCacheData.debuffs) or (isHelpful and unitCacheData.buffs) or nil
	if not filterCache then return end
	
	Plater.StartLogPerformanceCore("Plater-Core", "Update", "UpdateAuras - getUnitAuras - long")
	
	if C_UnitAuras.GetUnitAuras then
		local auraData = C_UnitAuras.GetUnitAuras(unit, filter, nil, IS_WOW_PROJECT_MIDNIGHT and (Plater.db.profile.aura_sort and Enum.UnitAuraSortRule.Expiration or Enum.UnitAuraSortRule.Unsorted) or nil)
		for _, aura in pairs(auraData) do
			setAdditionalAuraFields(aura, unit)
			filterCache[aura.auraInstanceID] = aura
		end
		if isHarmful then
			unitCacheData.debuffsInOrder = auraData
		elseif isHelpful then
			unitCacheData.buffsInOrder = auraData
		end
	else
		local continuationToken
		repeat -- until continuationToken == nil
			local slots = { GetAuraSlots(unit, filter, BUFF_MAX_DISPLAY_PLATER, continuationToken) }
			continuationToken = slots[1]
			local numSlots = #slots
			
			for i=2, numSlots do
				local slot = slots[i]
				local aura = GetAuraDataBySlot(unit, slot)
				if aura then
					--DevTool:AddData({unit = unit, aura = aura, slot = slot}, "GetAuraDataBySlot")
					filterCache[aura.auraInstanceID] = aura
				end
			end
		until continuationToken == nil
	end
	
	Plater.EndLogPerformanceCore("Plater-Core", "Update", "UpdateAuras - getUnitAuras - long")
	
	-- done the update?
	if unitCacheData.isFullUpdateHelp and isHelpful then unitCacheData.isFullUpdateHelp = false end
	if unitCacheData.isFullUpdateHarm and isHarmful then unitCacheData.isFullUpdateHarm = false end
	return unitCacheData
end

local function getBlizzardDebuffs(unitFrame)
	local blizzDebuffFrame = unitFrame.PlateFrame.UnitFrame and unitFrame.PlateFrame.UnitFrame.AurasFrame and unitFrame.PlateFrame.UnitFrame.AurasFrame.DebuffListFrame
	--DevTool:AddData(unitFrame.PlateFrame.UnitFrame)
	local blizzardDebuffs = {}
	if blizzDebuffFrame then
		for _, child in ipairs(blizzDebuffFrame:GetLayoutChildren()) do
			blizzardDebuffs[child.auraInstanceID] = true
		end
	end
	return blizzardDebuffs
end
local function getBlizzardBuffs(unitFrame)
	local blizzBuffFrame = unitFrame.PlateFrame.UnitFrame and unitFrame.PlateFrame.UnitFrame.AurasFrame and unitFrame.PlateFrame.UnitFrame.AurasFrame.BuffListFrame
	local blizzardBuffs = {}
	if blizzBuffFrame then
		for _, child in ipairs(blizzBuffFrame:GetLayoutChildren()) do
			blizzardBuffs[child.auraInstanceID] = true
		end
	end
	return blizzardBuffs
end

--[[
returns the following structure from cached / quick-updated values:
auras = {
  [<aura-ID>] = {
		applications,
		auraInstanceID,
		canApplyAura,
		dispelName,
		duration,
		expirationTime,
		icon,
		isBossAura,
		isFromPlayerOrPlayerPet,
		isHarmful,
		isHelpful,
		isNameplateOnly,
		isRaid,
		isStealable,
		name,
		nameplateShowAll,
		nameplateShowPersonal,
		points,
		sourceUnit,
		spellId,
		timeMod,
	},
}

--]]
function Plater.GetUnitAurasForUnitID(unitID)
	if not unitID or not UnitAuraCacheData[unitID] then
		return nil
	end

	local allAuras = {}
	local aurasHelp = getUnitAuras(unitID, "HELPFUL") or {buffs = {}, buffsInOrder = {}}
	local aurasHarm = getUnitAuras(unitID, "HARMFUL") or {debuffs = {}, debuffsInOrder = {}}
	DF.table.copy(allAuras, aurasHelp.buffs)
	DF.table.copy(allAuras, aurasHarm.debuffs)
	return allAuras
end
function Plater.GetUnitAuras(unitFrame)
	return Plater.GetUnitAurasForUnitID(unitFrame.namePlateUnitToken)
end


--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> aura buffs and debuffs ~aura ~buffs ~debuffs ~auras

	--> show the tooltip in the aura icon
	function Plater.OnEnterAura (iconFrame) --private
		PlaterNamePlateAuraTooltip:SetOwner (iconFrame, "ANCHOR_LEFT")
		if PlaterNamePlateAuraTooltip.SetUnitBuffByAuraInstanceID and DB_AURA_ENABLED then
            if(iconFrame.spellId and not iconFrame.auraInstanceID) then 
                PlaterNamePlateAuraTooltip:SetSpellByID(iconFrame.spellId)
            elseif (iconFrame.auraInstanceID) then 
                local setFunction = iconFrame.isBuff and PlaterNamePlateAuraTooltip.SetUnitBuffByAuraInstanceID or PlaterNamePlateAuraTooltip.SetUnitDebuffByAuraInstanceID
                setFunction(PlaterNamePlateAuraTooltip, iconFrame:GetParent().unit, iconFrame:GetID(), iconFrame.filter)
            end 
        else
			PlaterNamePlateAuraTooltip:SetSpellByID(iconFrame.spellId)
            --PlaterNamePlateAuraTooltip:SetUnitAura (iconFrame:GetParent().unit, iconFrame:GetID(), iconFrame.filter)
        end
		PlaterNamePlateAuraTooltip:ApplyOwnBackdrop()
		iconFrame.UpdateTooltip = Plater.OnEnterAura
	end

	function Plater.OnLeaveAura (iconFrame) --private
		PlaterNamePlateAuraTooltip:Hide()
		if not NamePlateTooltip or NamePlateTooltip:IsForbidden() then return end
		NamePlateTooltip:Hide() -- backwards compatibility for mods (should be removed later)
	end
	
	--called from the options panel, request a refresh on all auras shown
	function Plater.RefreshAuras() --private
		if not IS_WOW_PROJECT_MIDNIGHT_API_WITH_AURA_CONTAINERS then
			for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
				if plateFrame.unitFrame.PlaterOnScreen then -- only for visible
					UnitAuraEventHandlerData[plateFrame.unitFrame.unit] = { hasBuff = true, hasDebuff = true } -- ensure aura update
					Plater.NameplateTick (plateFrame.OnTickFrame, 1)
				end
			end
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
			local icon = iconFrame.texture
			local spellName = iconFrame.SpellName
			local index = spellName .. (icon or spellName or math.random(1, 1000000))

			if (aurasDuplicated [index]) then
				tinsert (aurasDuplicated [index], {iconFrame, iconFrame.RemainingTime})
			else
				aurasDuplicated [index] = {
					{iconFrame, iconFrame.RemainingTime}
				}
			end
		end

		for index, iconFramesTable in pairs (aurasDuplicated) do
			--how many auras with the same name the unit has
			local amountOfSimilarAuras = #iconFramesTable
			
			if (amountOfSimilarAuras > 1) then
				--sort order: the aura with the least time left is shown by default
				if (Plater.db.profile.aura_consolidate_timeleft_lower) then
					table.sort (iconFramesTable, DF.SortOrder2R)
				else
					table.sort (iconFramesTable, DF.SortOrder2)
				end
				
				local totalStacks = 0
				
				--hide all auras except for the first occurrence of this aura
				for i = 1, amountOfSimilarAuras do
					local iconFrame = iconFramesTable [i][1]
					if i == 1 then --ensure the sorted icon is always shown
						iconFrame:Show()
						iconFrame.InUse = true
					else --hide other icons
						iconFrame.ShowAnimation:Stop()
						iconFrame:Hide()
						iconFrame.InUse = false
					end
					
					totalStacks = totalStacks + (iconFrame.Stacks > 0 and iconFrame.Stacks or 1)
					
					--decrease the amount of auras shown on the buff frame
					self.amountAurasShown = self.amountAurasShown - 1
				end
				
				--set the stack amount number to indicate how many auras similar to this the unit has
				local stackLabel = iconFramesTable [1][1].StackText
				stackLabel:SetText (totalStacks)
				stackLabel:Show()
			end
		end
	end
	
	
	--sort aura icons according to this function. default is time remaining hight to low (l->r) with 0-duration on the left
	function Plater.AuraIconsSortFunction (aura1, aura2)
		return (aura1.Duration == 0 and 99999999 or aura1.RemainingTime or 0) < (aura2.Duration == 0 and 99999999 or aura2.RemainingTime or 0)
		--return (aura1.Duration == 0 and 99999999 or aura1.RemainingTime or 0) > (aura2.Duration == 0 and 99999999 or aura2.RemainingTime or 0)
	end

	--update the ghost auras
	--this function is guaranteed to run after all auras been processed
	function Plater.ShowGhostAuras(buffFrame)
		if (DB_AURA_GHOSTAURA_ENABLED and not IS_WOW_PROJECT_MIDNIGHT) then
			local unitFrame = buffFrame.unitFrame
			if ((unitFrame.namePlateUnitReaction < 5) and unitFrame.InCombat and not unitFrame.IsSelf and not unitFrame.isPerformanceUnit and InCombatLockdown()) then
				local nameplateAuraCache = unitFrame.AuraCache --active auras currently shown in the nameplate
				local nameplateGhostAuraCache = unitFrame.GhostAuraCache --active ghost auras currently shown in the nameplate
				for spellName, spellTable in pairs(GHOSTAURAS) do
					if (not nameplateAuraCache[spellName.."_player"]) then
						if (not nameplateGhostAuraCache[spellName.."_player_ghost"]) then --the ghost aura isn't in the nameplate
							--add the extra icon
							local spellIcon, spellId = spellTable[1], spellTable[2]
							local auraIconFrame = Plater.GetAuraIcon(buffFrame) -- show on debuff frame
							auraIconFrame.InUse = true --don't play animation
							Plater.AddAura(buffFrame, auraIconFrame, -1, spellName.."_player_ghost", spellIcon, 1, "DEBUFF", 0, 0, "player", true, false, false, -spellId, false, false, false, false, "DEBUFF", 1)
							auraIconFrame:EnableMouse (false) --don't use tooltips, as there is no real aura
							if auraIconFrame.EnableMouseMotion then
								auraIconFrame:EnableMouseMotion (false) --don't use tooltips, as there is no real aura
							end
							auraIconFrame.IsGhostAura = true
							Plater.Auras.GhostAuras.ApplyAppearance(auraIconFrame, spellName.."_player_ghost", spellIcon, -spellId)
							nameplateGhostAuraCache[spellName.."_player_ghost"] = true --this is shown as ghost aura
						end
					else
						nameplateGhostAuraCache[spellName.."_player_ghost"] = false --this is shown as regular aura
					end
				end
			end
		end
	end

	--extra auras
	--these are auras which some script or weakaura requested to be shown in the nameplate of an unit
	--plater does not have control, does not save or has a list of extra auras, they are all external
	--plater just add an icon for the spellId and show it until its duration expires
	--this function is called on tick after Plater.ShowGhostAuras(tickFrame.BuffFrame) and platerInternal.ExtraAuras.ClearExpired()
	function platerInternal.ExtraAuras.Show(buffFrame)
		local unitFrame = buffFrame.unitFrame
		--unitFrame.IsNeutralOrHostile count npcs and players
		if (unitFrame.IsNeutralOrHostile and not unitFrame.IsSelf) then --and unitFrame.InCombat --removed for debug on training dummies
			if (InCombatLockdown()) then
				local unitGUID = unitFrame[MEMBER_GUID]
				if issecretvalue(unitGUID) then return end
				local unitExtraAurasSpellIds = EXTRAAURAS_GUIDS[unitGUID]

				--does the mob shown in the nameplate has an extra aura added to it?
				if (unitExtraAurasSpellIds) then
					--active extra auras currently shown in the nameplate
					local nameplateExtraAurasCache = unitFrame.ExtraAuraCache
					--active auras currently shown in the nameplate
					local nameplateAuraCache = unitFrame.AuraCache
					--active ghost auras currently shown in the nameplate
					local nameplateGhostAuraCache = unitFrame.GhostAuraCache

					for spellId, extraAuraTable in pairs(unitExtraAurasSpellIds) do
						--does this extra aura just added or got a time refresh?
						local needRefresh = extraAuraTable.needRefresh

						if (needRefresh or not nameplateExtraAurasCache[extraAuraTable.spellNameExtraCache]) then
							if (needRefresh or not nameplateAuraCache[extraAuraTable.spellNameAuraCache]) then
								if (needRefresh or not nameplateGhostAuraCache[extraAuraTable.spellNameGhostAuraCache]) then
									local spellName = extraAuraTable.spellName --not in use
									local spellIcon = extraAuraTable.spellIcon
									local duration = extraAuraTable.duration
									local startTime = extraAuraTable.startTime --not in use
									local expirationTime = extraAuraTable.expirationTime
									local borderColor = extraAuraTable.borderColor
									local overlayColor = extraAuraTable.overlayColor
									local idDesaturated = extraAuraTable.desaturated

									--check if can use the same icon, this might not be required in the future
									local auraIconFrame = platerInternal.ExtraAuras.GetAuraIconByExtraAuraSpellId(unitFrame, spellId)
									if (not auraIconFrame) then
										auraIconFrame = Plater.GetAuraIcon(buffFrame)
									end

									auraIconFrame.InUse = true
									Plater.AddAura  (buffFrame, auraIconFrame, -1, extraAuraTable.spellNameExtraCache, spellIcon, 1, "DEBUFF", duration, expirationTime, "player", true, false, false, spellId, false, false, true,  false, "DEBUFF", 1)

									auraIconFrame.extraAuraSpellId = spellId

									--set the icon and border settings
									auraIconFrame.Icon:SetDesaturated(idDesaturated)
									auraIconFrame.Icon:SetVertexColor(DetailsFramework:ParseColors(overlayColor))

									auraIconFrame:SetBackdropBorderColor(DetailsFramework:ParseColors(borderColor))

									--add the aura to 'unitFrame.ExtraAuraCache', spellNameExtraCache = spellName .. "_extra"
									nameplateExtraAurasCache[extraAuraTable.spellNameExtraCache] = true
									--add to extra auras cache to know which unitFrame has the extra aura by the mob guid
									platerInternal.ExtraAuras.CacheGUID_to_UnitFrame(unitGUID, unitFrame)

									--tag this extra aura as clean
									extraAuraTable.needRefresh = false
								end
							end
						end
					end
				end
			end
		end
	end

	
	--align the aura frame icons currently shown in buff container
	--this function is called after Plater complete the aura update loop
	--at this point, icons shown are reliable icons that has auras that are shown above the nameplate
	--hidden icons aren't in use and should be ignored
	--self is the buff container
	--~align
	function platerInternal.AlignAuraFrames (self)

		if (self.isNameplate) then
			local profile = Plater.db.profile
			local horizontalLength = 1
			local curRowLength = 0
			local verticalHeight = 1
			local firstIcon
		
			if (profile.aura_consolidate) and not IS_WOW_PROJECT_MIDNIGHT then
				Plater.ConsolidateAuraIcons (self)
			end
			
			--get the table where all icon frames are stored in
			local iconFrameContainer = self.PlaterBuffList
			--get the amount of auras shown in the frame; iterate over all if not sorting
			local amountFramesShown = #iconFrameContainer
			
			
			-- still sort by auraInstanceID for some consistency
			local iconFrameContainerCopy = {}
			local index = 0
			for _, icon in pairs(iconFrameContainer) do
				if icon:IsShown() then
					-- some more filtering doing here, as cannot be done earlier for midnight without larger rework...
					local isPermanentToFilter = IS_WOW_PROJECT_MIDNIGHT and not icon.Cooldown:IsShown() and Plater.db.profile.debuff_hide_permanent or false
					if not isPermanentToFilter then
						index = index + 1
						iconFrameContainerCopy[index] = icon
					else
						icon:Hide()
					end
				end
			end
			iconFrameContainer = iconFrameContainerCopy
			if not IS_WOW_PROJECT_MIDNIGHT then -- new aura sorting done via API, let's see...
				table.sort (iconFrameContainer, function(aura1, aura2) 
					return (aura1.auraInstanceID or 0) < (aura2.auraInstanceID or 0)
				end)
			else
				-- new aura sorting done via API, let's see...
				--[[
				table.sort (iconFrameContainer, function(aura1, aura2)
					local aFromPlayer = (aura1.sourceUnit ~= nil) and UnitIsUnit("player", aura1.sourceUnit) or false
					local bFromPlayer = (aura2.sourceUnit ~= nil) and UnitIsUnit("player", aura2.sourceUnit) or false
					if aFromPlayer ~= bFromPlayer then
						return aFromPlayer
					end
					return (aura1.auraInstanceID or 0) < (aura2.auraInstanceID or 0)
				end)
				]]--
			end
			--when sorted, this is reliable
			amountFramesShown = index
			
			if (profile.aura_sort) then
				if IS_WOW_PROJECT_MIDNIGHT then
					local order = {}
					for i, auraData in pairs (self.debuffsInOrder or {}) do
						order[auraData.auraInstanceID] = i
					end
					for i, auraData in pairs (self.buffsInOrder or {}) do
						order[auraData.auraInstanceID] = i
					end
					table.sort (iconFrameContainer, function(aura1, aura2) 
						return (order[aura1.auraInstanceID] or 0) > (order[aura2.auraInstanceID] or 0)
					end)
				else
					-- this needs to be done in addition. the above is just to keep them consistent in order
					local iconFrameContainerCopy = {}
					local index = 0
					for _, icon in pairs(iconFrameContainer) do
						if icon:IsShown() then
							index = index + 1
							iconFrameContainerCopy[index] = icon
						end
					end
					iconFrameContainer = iconFrameContainerCopy
					table.sort (iconFrameContainer, Plater.AuraIconsSortFunction)
					--when sorted, this is reliable
					amountFramesShown = index
				end
			end

			local auraLimit = Plater.db.profile.aura_max_shown_limit or 0
			local auraArrayStart = 1
			local auraArrayEnd = amountFramesShown
			if auraLimit > 0 then
				for i = 1, amountFramesShown - auraLimit do
					iconFrameContainer[i]:Hide()
				end
				auraArrayStart = max(amountFramesShown - auraLimit + 1, 1)
				auraArrayEnd = amountFramesShown
			elseif auraLimit < 0 then
				auraLimit = abs(auraLimit)
				for i = auraLimit + 1, amountFramesShown do
					iconFrameContainer[i]:Hide()
				end
				auraArrayStart = 1
				auraArrayEnd = min(amountFramesShown, auraLimit)
			end
		
			local growDirection
			local anchorSide
			local auras_per_row

			--> get the grow direction for the buff frame
			if (self.Name == "Main") then
				growDirection = DB_AURA_GROW_DIRECTION
				anchorSide = profile.aura_frame1_anchor.side
				auras_per_row = profile.auras_per_row_amount
				
			elseif (self.Name == "Secondary") then
				growDirection = DB_AURA_GROW_DIRECTION2
				anchorSide = profile.aura_frame2_anchor.side
				auras_per_row = profile.auras_per_row_amount2
			
			else
				return
			end
			
			if (growDirection ~= 2) then --it's growing to left or right
			
				--debug where the buffFrame anchors are
				--self:SetSize (5, 5)
				--self:SetBackdrop ({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1})
				--self:SetBackdropBorderColor (1, 0, 0, 1)
			
				local aurasPerRow = (not profile.auras_per_row_auto and floor(auras_per_row) or Plater.MaxAurasPerRow)
				local curAurasRowCount = aurasPerRow + 1
				local rowGrowthDirectionUp = (anchorSide < 3 or anchorSide > 5)
				local lineBreakMult = rowGrowthDirectionUp and 1 or -1
				
				--which slot index is being manipulated within the icon loop
				--if an icon is hidden it won't be used and the slot won't increase
				--the slot 1 is guaranteed to always be in use
				local slotId = 1
				
				--which was the last shown and valid icon attached into the visible icon row
				local lastIconUsed
				local relIconPoint
				local relIconPointTo
				local relRowIconPoint
				local relFirstIconPoint
				local paddingMult
				
				--left to right
				if (growDirection == 3) then
					relIconPoint = rowGrowthDirectionUp and "bottomleft" or "topleft"
					relIconPointTo = rowGrowthDirectionUp and "bottomright" or "topright"
					relRowIconPoint = rowGrowthDirectionUp and "topleft" or "bottomleft"
					relFirstIconPoint = rowGrowthDirectionUp and "bottomleft" or "topleft"
					paddingMult = 1
				
				-- <-- right to left
				elseif (growDirection == 1) then
					relIconPoint = rowGrowthDirectionUp and "bottomright" or "topright"
					relIconPointTo = rowGrowthDirectionUp and "bottomleft" or "topleft"
					relRowIconPoint = rowGrowthDirectionUp and "topright" or "bottomright"
					relFirstIconPoint = rowGrowthDirectionUp and "bottomright" or "topright"
					paddingMult = -1
				end
				
				--iterate among all icon frames
				for i = auraArrayStart, auraArrayEnd do
					--get the icon id from the icon frame container
					local iconFrame = iconFrameContainer [i]
					if (iconFrame:IsShown()) then
						iconFrame:ClearAllPoints()
						
						if not firstIcon then
							--set the point of the first icon
							iconFrame:ClearAllPoints()
							iconFrame:SetPoint (relFirstIconPoint, self, relFirstIconPoint, 0, 0)
							firstIcon = iconFrame
							verticalHeight = firstIcon:GetHeight()
						else
							if (slotId == curAurasRowCount) then
								iconFrame:SetPoint (relIconPoint, firstIcon, relRowIconPoint, 0, profile.aura_breakline_space * lineBreakMult)
								curAurasRowCount = curAurasRowCount + aurasPerRow
								--update the first icon to be the first icon in the second row
								firstIcon = iconFrame
								verticalHeight = verticalHeight + profile.aura_breakline_space + firstIcon:GetHeight()
								
							else
								iconFrame:SetPoint (relIconPoint, lastIconUsed, relIconPointTo, DB_AURA_PADDING * paddingMult, 0)
							end
						end
						
						lastIconUsed = iconFrame
						slotId = slotId + 1
					end
				end
				
				horizontalLength = 1 + DB_AURA_PADDING
				
			else --it's growing from center
				
				local previousIcon

				--iterate among all icons in the aura frame
				--set the point of the first icon in the bottom left of the buff frame
				--set the point of all other icons to the right of the previous icon and update the size of the buff frame
				for i = auraArrayStart, auraArrayEnd do
					local iconFrame = iconFrameContainer [i]
					if (iconFrame:IsShown()) then
						curRowLength = curRowLength + iconFrame:GetWidth() + DB_AURA_PADDING
						iconFrame:ClearAllPoints()
						
						if (not firstIcon) then
							firstIcon = iconFrame
							firstIcon:SetPoint ("bottomleft", self, "bottomleft", 0, 0)
							previousIcon = firstIcon
							verticalHeight = firstIcon:GetHeight()
							horizontalLength = curRowLength
							
						else
							iconFrame:SetPoint ("bottomleft", previousIcon, "bottomright", DB_AURA_PADDING, 0)
							previousIcon = iconFrame
						end
					end
				end
				
			end
			
			if curRowLength > horizontalLength then
				horizontalLength = curRowLength
			end
			
			--remove 1 icon padding value
			horizontalLength = (horizontalLength > 1) and (horizontalLength - DB_AURA_PADDING) or 1
			--set the size of the buff frame
			self:SetWidth (horizontalLength)
			self:SetHeight (verticalHeight)
		end
	end
	Plater.AlignAuraFrames = platerInternal.AlignAuraFrames

	--adjust the texcoord of the icon by the size of the icon
	--if the icon is more of a retangular shape, it'll cut the top and bottom sides of the icon giving a wide view
	function Plater.UpdateIconAspecRatio (auraIconFrame)
		local width, height = auraIconFrame:GetSize()
		local ratio = width > height and min (max (abs (width / height - 2) + 0.08, 0.6), 1) or .92
		auraIconFrame.Icon:SetTexCoord (.08, .92, .08, ratio)
	end

	function platerInternal.CreateAuraIcon (parent, name) --private ~createicon ~icon
		--local newIcon = CreateFrame ("Button", name, parent, BackdropTemplateMixin and "BackdropTemplate")
		local newIcon = CreateFrame ("Button", name, parent)
		newIcon:Hide()
		newIcon:SetSize (20, 16)
		
		newIcon:SetScript ("OnEnter", Plater.OnEnterAura)
		newIcon:SetScript ("OnLeave", Plater.OnLeaveAura)
		
		newIcon:SetMouseClickEnabled (false)

		--newIcon.BorderMask = newIcon:CreateMaskTexture(nil, "artwork")
		--newIcon.BorderMask:SetAllPoints()
		--newIcon.BorderMask:SetTexture([[Interface/addons/plater/masks/rounded_square_32x32]])
		--newIcon.Border:AddMaskTexture(newIcon.BorderMask)
		--newIcon.BorderMask:Hide()

		newIcon.Icon = newIcon:CreateTexture (nil, "artwork")
		local iconOffset = 0
		PixelUtil.SetPoint (newIcon.Icon, "TOPLEFT", newIcon, "TOPLEFT", -iconOffset, iconOffset)
		PixelUtil.SetPoint (newIcon.Icon, "TOPRIGHT", newIcon, "TOPRIGHT", iconOffset, iconOffset)
		PixelUtil.SetPoint (newIcon.Icon, "BOTTOMLEFT", newIcon, "BOTTOMLEFT", -iconOffset, -iconOffset)
		PixelUtil.SetPoint (newIcon.Icon, "BOTTOMRIGHT", newIcon, "BOTTOMRIGHT", iconOffset, -iconOffset)
		newIcon.Icon:SetTexCoord (.05, .95, .1, .6)
		newIcon.Icon:SetTexelSnappingBias(0.0)
		newIcon.Icon:SetSnapToPixelGrid(false)

		newIcon.IconMask = newIcon:CreateMaskTexture(nil, "artwork")
		newIcon.IconMask:SetAllPoints()
		newIcon.IconMask:SetTexture([[Interface/addons/plater/masks/rounded_square_32x32]])
		newIcon.Icon:AddMaskTexture(newIcon.IconMask)
		newIcon.IconMask:Hide()
		
		newIcon.Cooldown = CreateFrame ("cooldown", "$parentCooldown", newIcon, "CooldownFrameTemplate")
		iconOffset = 0
		PixelUtil.SetPoint (newIcon.Cooldown, "TOPLEFT", newIcon, "TOPLEFT", -iconOffset, iconOffset)
		PixelUtil.SetPoint (newIcon.Cooldown, "TOPRIGHT", newIcon, "TOPRIGHT", iconOffset, iconOffset)
		PixelUtil.SetPoint (newIcon.Cooldown, "BOTTOMLEFT", newIcon, "BOTTOMLEFT", -iconOffset, -iconOffset)
		PixelUtil.SetPoint (newIcon.Cooldown, "BOTTOMRIGHT", newIcon, "BOTTOMRIGHT", iconOffset, -iconOffset)
		newIcon.Cooldown:EnableMouse (false)
		if newIcon.Cooldown.EnableMouseMotion then
			newIcon.Cooldown:EnableMouseMotion (false)
		end
		newIcon.Cooldown:SetHideCountdownNumbers (not IS_WOW_PROJECT_MIDNIGHT)
		if IS_WOW_PROJECT_MIDNIGHT then
			newIcon.Cooldown:SetCountdownAbbrevThreshold(60) --TODO: MIDNIGHT!!
		end
		newIcon.Cooldown:Hide()

		--tested to change the texture used in the semi-transparent black overlay which get "cutted" by the edge texture
		--newIcon.Cooldown.SwipeTexture = newIcon.Cooldown:CreateTexture(nil, "artwork")
		--newIcon.Cooldown.SwipeTexture:SetAllPoints()
		--newIcon.Cooldown.SwipeTexture:SetColorTexture(0, 0, 0, 0.3)
		--newIcon.Cooldown:SetSwipeTexture([[Interface/addons/plater/masks/rounded_square_32x32]], 0, 0, 1, 1)
		--newIcon.Cooldown:SetEdgeTexture([[Interface/addons/plater/masks/rounded_square_32x32]], 0, 0, 1, 1)
		--newIcon.CooldownMask = newIcon.Cooldown:CreateMaskTexture(nil, "artwork")
		--newIcon.CooldownMask:SetAllPoints()
		--newIcon.CooldownMask:SetTexture([[Interface/addons/plater/masks/rounded_square_32x32]])
		--newIcon.Cooldown.SwipeTexture:AddMaskTexture(newIcon.CooldownMask)
		--newIcon.CooldownMask:Hide()

		newIcon.Cooldown.noCooldownCount = Plater.db.profile.disable_omnicc_on_auras

		newIcon.CountFrame = CreateFrame ("frame", "$parentCountFrame", newIcon)--, BackdropTemplateMixin and "BackdropTemplate")
		newIcon.CountFrame:SetAllPoints()
		newIcon.CountFrame:EnableMouse (false)
		if newIcon.CountFrame.EnableMouseMotion then
			newIcon.CountFrame:EnableMouseMotion (false)
		end
		newIcon.CountFrame.Count = newIcon.CountFrame:CreateFontString (nil, "artwork", "NumberFontNormalSmall")
		if newIcon.CountFrame.Count.SetSmoothScaling then
			--newIcon.CountFrame.Count:SetSmoothScaling(true)
		end
		newIcon.CountFrame.Count:SetJustifyH ("right")
		newIcon.CountFrame.Count:SetPoint ("bottomright", 3, -2)
		
		--expose to scripts
		newIcon.StackText = newIcon.CountFrame.Count
		
		if IS_WOW_PROJECT_MIDNIGHT then
			newIcon.Cooldown:SetMinimumCountdownDuration(0)
			newIcon.Cooldown.Timer = newIcon.Cooldown:GetRegions()
			--newIcon.Cooldown.Timer:SetSmoothScaling(true)
		else
			newIcon.Cooldown.Timer = newIcon.Cooldown:CreateFontString (nil, "overlay", "NumberFontNormal")
			newIcon.Cooldown.Timer:SetPoint ("center")
		end
		newIcon.TimerText = newIcon.Cooldown.Timer


		-- switch to proper border, keep compatibility
		newIcon.Border = DF:CreateFullBorder("$parentBorder", newIcon)
		for _, tex in pairs(newIcon.Border.Textures) do
			tex:SetDrawLayer ("overlay", 7)
		end
		local iconOffset = -1
		PixelUtil.SetPoint (newIcon.Border, "TOPLEFT", newIcon, "TOPLEFT", -iconOffset, iconOffset)
		PixelUtil.SetPoint (newIcon.Border, "TOPRIGHT", newIcon, "TOPRIGHT", iconOffset, iconOffset)
		PixelUtil.SetPoint (newIcon.Border, "BOTTOMLEFT", newIcon, "BOTTOMLEFT", -iconOffset, -iconOffset)
		PixelUtil.SetPoint (newIcon.Border, "BOTTOMRIGHT", newIcon, "BOTTOMRIGHT", iconOffset, -iconOffset)
		newIcon.SetBackdropBorderColor = function(self, r, g, b, a)
			self.Border:SetVertexColor(r, g, b, a)
		end
		newIcon.Border.SetBorderSize = function(self, size)
			local borderSize = (size or 1) * UIParent:GetEffectiveScale()
			self:SetBorderSizes(borderSize, 0, borderSize, 0)
			self:UpdateSizes()
		end
		newIcon.SetBorderSize = function(self, size)
			self.Border:SetBorderSize(size)
		end
		newIcon.SetBackdrop = function(self, options)
			local borderSize = options.edgeSize or 1
			self.Border:SetBorderSize(borderSize)
		end
		newIcon.GetBackdropBorderColor = function(self)
			return self.Border:GetVertexColor()
		end

		newIcon.SetSizes = function(self)
			local extraBorderOffset = 0
			if self.Name == "Secondary" then
				extraBorderOffset = Plater.db.profile.aura_border_extraoffset2 or 0
			else
				extraBorderOffset = Plater.db.profile.aura_border_extraoffset or 0
			end
			local iconOffset = -1 * UIParent:GetEffectiveScale() + extraBorderOffset
			PixelUtil.SetPoint (self.Border, "TOPLEFT", self, "TOPLEFT", -iconOffset, iconOffset)
			PixelUtil.SetPoint (self.Border, "TOPRIGHT", self, "TOPRIGHT", iconOffset, iconOffset)
			PixelUtil.SetPoint (self.Border, "BOTTOMLEFT", self, "BOTTOMLEFT", -iconOffset, -iconOffset)
			PixelUtil.SetPoint (self.Border, "BOTTOMRIGHT", self, "BOTTOMRIGHT", iconOffset, -iconOffset)

			iconOffset = 0
			PixelUtil.SetPoint (self.Icon, "TOPLEFT", self, "TOPLEFT", -iconOffset, iconOffset)
			PixelUtil.SetPoint (self.Icon, "TOPRIGHT", self, "TOPRIGHT", iconOffset, iconOffset)
			PixelUtil.SetPoint (self.Icon, "BOTTOMLEFT", self, "BOTTOMLEFT", -iconOffset, -iconOffset)
			PixelUtil.SetPoint (self.Icon, "BOTTOMRIGHT", self, "BOTTOMRIGHT", iconOffset, -iconOffset)

			iconOffset = -1 * UIParent:GetEffectiveScale()
			PixelUtil.SetPoint (self.Cooldown, "TOPLEFT", self, "TOPLEFT", -iconOffset, iconOffset)
			PixelUtil.SetPoint (self.Cooldown, "TOPRIGHT", self, "TOPRIGHT", iconOffset, iconOffset)
			PixelUtil.SetPoint (self.Cooldown, "BOTTOMLEFT", self, "BOTTOMLEFT", -iconOffset, -iconOffset)
			PixelUtil.SetPoint (self.Cooldown, "BOTTOMRIGHT", self, "BOTTOMRIGHT", iconOffset, -iconOffset)
		end

		return newIcon
	end
	
	--create the animation when the icon is shown above the nameplate
	function Plater.CreateShowAuraIconAnimation (iconFrame)
		local showAnimationOnPlay = function()
			
		end
		local showAnimationOnStop = function()
			iconFrame:SetScale(1)
		end
		
		local iconShowInAnimation = {}
	
		local iconShowInAnimationIcon = DF:CreateAnimationHub (iconFrame.Icon, showAnimationOnPlay, showAnimationOnStop)
		DF:CreateAnimation (iconShowInAnimationIcon, "Scale", 1, .05, .7, .7, 1.1, 1.1)
		DF:CreateAnimation (iconShowInAnimationIcon, "Scale", 2, .05, 1.1, 1.1, 1, 1)
		
		local iconShowInAnimationBorder = DF:CreateAnimationHub (iconFrame.Border, showAnimationOnPlay, showAnimationOnStop)
		DF:CreateAnimation (iconShowInAnimationBorder, "Scale", 1, .05, .7, .7, 1.1, 1.1)
		DF:CreateAnimation (iconShowInAnimationBorder, "Scale", 2, .05, 1.1, 1.1, 1, 1)
		
		iconShowInAnimation.iconShowInAnimationIcon = iconShowInAnimationIcon
		iconShowInAnimation.iconShowInAnimationBorder = iconShowInAnimationBorder
		
		function iconShowInAnimation.Play(iconShowInAnimation)
			iconShowInAnimation.iconShowInAnimationIcon:Play()
			iconShowInAnimation.iconShowInAnimationBorder:Play()
		end
		function iconShowInAnimation.Stop(iconShowInAnimation)
			iconShowInAnimation.iconShowInAnimationIcon:Stop()
			iconShowInAnimation.iconShowInAnimationBorder:Stop()
		end
		
		iconFrame.ShowAnimation = iconShowInAnimation
	end
	
	local function aura_icon_on_hide_callback (self)
		self.ShowAnimation:Stop()
		self:OnHideWidget()
	end
	
	-- cooldown timer update tick
	local function AuraIconOnTick_UpdateCooldown (self, deltaTime)
		local now = GetTime()
		if (self.lastUpdateCooldown + (IS_WOW_PROJECT_MIDNIGHT and 0.5 or 0.05)) <= now then
			if IS_WOW_PROJECT_MIDNIGHT then
				--self.RemainingTime = C_UnitAuras.GetAuraDurationRemaining(self.unitFrame.namePlateUnitToken, self:GetID())
				self.RemainingTime = self.durationObject and self.durationObject:GetRemainingDuration() -- or C_UnitAuras.GetAuraDurationRemaining(self.unitFrame.namePlateUnitToken, self:GetID())
				--self.Cooldown.Timer:SetText(string.format("%d",self.RemainingTime))
				
				--local pandemicColor = C_UnitAuras.GetAuraDurationRemainingColor(auraIconFrame.unitFrame.namePlateUnitToken, i , pandemicColorCurve)
				if Plater.db.profile.aura_timer_pandemic_color then
					local pandemicColor = self.durationObject:EvaluateRemainingPercent(pandemicColorCurve)
					self.Cooldown.Timer:SetTextColor(pandemicColor:GetRGBA())
				else
					-- don't reset each update, just do it next cycle...
					--local c = Plater.db.profile.aura_timer_text_color
					--self.Cooldown.Timer:SetTextColor(unpack(c))
				end
				
			else
				self.RemainingTime = (self.ExpirationTime - now) / (self.ModRate or 1)
				if not self.noExpirationTime and self.RemainingTime > 0 then
					if self.formatWithDecimals then
						self.Cooldown.Timer:SetText (Plater.FormatTimeDecimal (self.RemainingTime))
					else
						self.Cooldown.Timer:SetText (Plater.FormatTime (self.RemainingTime))
					end
				else
					self.Cooldown.Timer:SetText ("")
				end
			end
			self.lastUpdateCooldown = now
		end
	end
	
	--an aura is about to be added in the nameplate, need to get an icon for it ~geticonaura ~icon
	function Plater.GetAuraIcon (self, isBuff)
		Plater.StartLogPerformanceCore("Plater-Core", "Update", "UpdateAuras - GetAuraIcon")
	
		--self parent = NamePlate_X_UnitFrame
		--self = BuffFrame
		
		local curBuffFrame = 1
		if (isBuff and DB_AURA_SEPARATE_BUFFS) then
			self = self.BuffFrame2
			curBuffFrame = 2
		end
		
		local i = self.NextAuraIcon or 1
		
		if (not self.PlaterBuffList[i]) then
			local newFrameIcon = platerInternal.CreateAuraIcon (self, self.unitFrame:GetName() .. "Plater" .. self.Name .. "AuraIcon" .. i)
			newFrameIcon.unitFrame = self.unitFrame
			newFrameIcon.spellId = 0
			newFrameIcon.ID = i
			newFrameIcon.RefreshID = 0
			newFrameIcon.IsPersonal = -1 --place holder
			
			self.PlaterBuffList[i] = newFrameIcon
			
			--newFrameIcon:SetBackdrop ({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1})
			--newFrameIcon.Border:SetBorderSize (1)
			
		
			local auraWidth
			local auraHeight
			local borderThickness
			if curBuffFrame == 2 then
				auraWidth = Plater.db.profile.aura_width2
				auraHeight = Plater.db.profile.aura_height2
				borderThickness = Plater.db.profile.aura_border_thickness2
			else
				auraWidth = Plater.db.profile.aura_width
			    auraHeight = Plater.db.profile.aura_height
				borderThickness = Plater.db.profile.aura_border_thickness
			end
			newFrameIcon:SetBorderSize (borderThickness)
			--newFrameIcon:SetSize (auraWidth, auraHeight)
			--newFrameIcon.Icon:SetSize (auraWidth-2, auraHeight-2)
			local sizeMod = 1
			PixelUtil.SetSize(newFrameIcon, auraWidth * sizeMod, auraHeight * sizeMod)
			
			--mixin the meta functions for scripts
			DF:Mixin (newFrameIcon, Plater.ScriptMetaFunctions)
			newFrameIcon.IsAuraIcon = true
			newFrameIcon:HookScript ("OnHide", aura_icon_on_hide_callback)
			
			newFrameIcon.UpdateCooldown = AuraIconOnTick_UpdateCooldown
			
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
					local mOptions = Plater.Masque.AuraFrame1:GetOptions()
					if mOptions and mOptions.Disable and mOptions.Disable.get and not mOptions.Disable.get() then
						newFrameIcon.Border:Hide() --let Masque handle the border...
					end
					Plater.Masque.AuraFrame1:AddButton (newFrameIcon, t, "Aura", true)
					Plater.Masque.AuraFrame1:ReSkin(newFrameIcon)
					newFrameIcon.Masqued = true
					
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
					local mOptions = Plater.Masque.AuraFrame2:GetOptions()
					if mOptions and mOptions.Disable and mOptions.Disable.get and not mOptions.Disable.get() then
						newFrameIcon.Border:Hide() --let Masque handle the border...
					end
					Plater.Masque.AuraFrame2:AddButton (newFrameIcon, t, "Aura", true)
					Plater.Masque.AuraFrame2:ReSkin(newFrameIcon)
					newFrameIcon.Masqued = true
					
				end
			end
		end
		
		local auraIconFrame = self.PlaterBuffList [i]
		self.NextAuraIcon = (self.NextAuraIcon or 1) + 1
		
		auraIconFrame:SetAlpha(1)
		auraIconFrame.Icon:SetDesaturated(false)
		auraIconFrame.Cooldown:Show()
		
		Plater.EndLogPerformanceCore("Plater-Core", "Update", "UpdateAuras - GetAuraIcon")

		return auraIconFrame, self, self.NextAuraIcon-1
    end
    
	local SplitEvaluateColor = function(state, r1, g1, b1, a1, r2, g2, b2, a2)
		return C_CurveUtil.EvaluateColorValueFromBoolean(state, r1, r2),
			C_CurveUtil.EvaluateColorValueFromBoolean(state, g1, g2),
			C_CurveUtil.EvaluateColorValueFromBoolean(state, b1, b2),
			C_CurveUtil.EvaluateColorValueFromBoolean(state, a1 or 1, a2 or 1)
	end

	--update the aura icon, this icon is getted with GetAuraIcon -
	--dispelName is the UnitAura return value for the auraType ("" is enrage, nil/"none" for unspecified and "Disease", "Poison", "Curse", "Magic" for other types. -Continuity/Ariani
	--self is .BuffFrame or .BuffFrame2
	function Plater.AddAura (self, auraIconFrame, i, spellName, icon, applications, auraType, duration, expirationTime, sourceUnit, isFromPlayerOrPlayerPet, isStealable, nameplateShowPersonal, spellId, isBuff, isShowAll, isDebuff, isPersonal, dispelName, modRate) --~addaura ãddaura
		Plater.StartLogPerformanceCore("Plater-Core", "Update", "UpdateAuras - AddAura")
		
		auraIconFrame:SetID (i)
		auraIconFrame.auraInstanceID = i
		local curBuffFrame = self.Name == "Secondary" and 2 or 1

		-- ensure playing show animation if necessary
		if (not auraIconFrame.InUse) then
			auraIconFrame.ShowAnimation:Play()
		end
		
		--> check if the icon is showing a different aura
		if IS_WOW_PROJECT_MIDNIGHT or (auraIconFrame.spellId ~= spellId) then
			
			--> update the icon
			auraIconFrame.Icon:SetTexture (icon)
			
			--> update members
			auraIconFrame.spellId = spellId
			auraIconFrame.texture = icon
			auraIconFrame.layoutIndex = auraIconFrame.ID
			auraIconFrame.IsShowingBuff = false
			auraIconFrame.CanStealOrPurge = false
			if not IS_WOW_PROJECT_MIDNIGHT then
				auraIconFrame.AuraType = AURA_TYPES[dispelName] or "none"
			end
			auraIconFrame.IsFromPlayer = isFromPlayerOrPlayerPet

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
		
		if not IS_WOW_PROJECT_MIDNIGHT then
			self.AuraCache [spellId] = true
			self.AuraCache [spellName] = true
			self.AuraCache [spellId.."_"..(sourceUnit or "N/A")] = true
			self.AuraCache [spellName.."_"..(sourceUnit or "N/A")] = true
			self.AuraCache.canStealOrPurge = self.AuraCache.canStealOrPurge or isStealable
			self.AuraCache.hasEnrage = self.AuraCache.hasEnrage or dispelName == AURA_TYPE_ENRAGE
		end
		
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
			local auraWidth
			local auraHeight
			local borderThickness
			if (isPersonal) then
				auraWidth = profile.aura_width_personal
				auraHeight = profile.aura_height_personal
				borderThickness = profile.aura_border_thickness_personal
				--auraIconFrame:SetSize (auraWidth, auraHeight)
				--auraIconFrame.Icon:SetSize (auraWidth-2, auraHeight-2)
			else
				if curBuffFrame == 2 then
					auraWidth = profile.aura_width2
					auraHeight = profile.aura_height2
					borderThickness = profile.aura_border_thickness2
					--auraIconFrame:SetSize (auraWidth, auraHeight)
					--auraIconFrame.Icon:SetSize (auraWidth-2, auraHeight-2)
				else
					auraWidth = profile.aura_width
					auraHeight = profile.aura_height
					borderThickness = profile.aura_border_thickness
					--auraIconFrame:SetSize (auraWidth, auraHeight)
					--auraIconFrame.Icon:SetSize (auraWidth-2, auraHeight-2)
				end
			end
			local sizeMod = 1
			PixelUtil.SetSize(auraIconFrame, auraWidth * sizeMod, auraHeight * sizeMod)
			auraIconFrame:SetSizes()
			auraIconFrame:SetBorderSize (borderThickness)
			
			auraIconFrame.Cooldown:SetEdgeTexture (profile.aura_cooldown_edge_texture)
			auraIconFrame.Cooldown:SetReverse (profile.aura_cooldown_reverse)
			auraIconFrame.Cooldown:SetDrawSwipe (profile.aura_cooldown_show_swipe)

			Plater.UpdateIconAspecRatio (auraIconFrame)
			
			auraIconFrame:SetMouseClickEnabled (false)
		end
		
		--ensure proper state:
		if auraIconFrame.EnableMouseMotion then
			auraIconFrame:EnableMouse (false)
			auraIconFrame:EnableMouseMotion (profile.aura_show_tooltip)
		else
			auraIconFrame:EnableMouse (profile.aura_show_tooltip)
		end

		--icon size repeated due to:
		--when the size is changed in the options it doesnt change the IsPersonal flag
		--when it changes the isPersonal flag it change locally without increasing the refresh ID
		--> update the icon size depending on where it is shown
		if (auraIconFrame.IsPersonal ~= isPersonal or auraIconFrame.BuffFrame ~= curBuffFrame or auraIconFrame.IsGhostAura) then
			local auraWidth
			local auraHeight
			local borderThickness
			if (isPersonal) then
				auraWidth = profile.aura_width_personal
				auraHeight = profile.aura_height_personal
				borderThickness = profile.aura_border_thickness_personal
				--auraIconFrame:SetSize (auraWidth, auraHeight)
				--auraIconFrame.Icon:SetSize (auraWidth-2, auraHeight-2)
			else
				if curBuffFrame == 2 then
					auraWidth = profile.aura_width2
					auraHeight = profile.aura_height2
					borderThickness = profile.aura_border_thickness2
					--auraIconFrame:SetSize (auraWidth, auraHeight)
					--auraIconFrame.Icon:SetSize (auraWidth-2, auraHeight-2)
				else
					auraWidth = profile.aura_width
					auraHeight = profile.aura_height
					borderThickness = profile.aura_border_thickness
					--auraIconFrame:SetSize (auraWidth, auraHeight)
					--auraIconFrame.Icon:SetSize (auraWidth-2, auraHeight-2)
				end
			end
			auraIconFrame:SetBorderSize (borderThickness)
			local sizeMod = 1 --UIParent:GetEffectiveScale() --* (Plater.db.profile.use_ui_parent and (Plater.db.profile.ui_parent_scale_tune) or 1)
			PixelUtil.SetSize(auraIconFrame, auraWidth * sizeMod, auraHeight * sizeMod)
			
			Plater.UpdateIconAspecRatio (auraIconFrame)
		end
		auraIconFrame.IsPersonal = isPersonal
		auraIconFrame.IsGhostAura = false
		auraIconFrame.BuffFrame = self.Name == "Secondary" and 2 or 1

		if IS_WOW_PROJECT_MIDNIGHT then
			local stackLabel = auraIconFrame.CountFrame.Count
			stackLabel:SetText (C_StringUtil.TruncateWhenZero(applications))
			stackLabel:Show()
		else
			if (applications > 1) then
				local stackLabel = auraIconFrame.CountFrame.Count
				stackLabel:SetText (applications)
				stackLabel:Show()
			else
				auraIconFrame.CountFrame.Count:Hide()
			end
		end
		
		auraIconFrame.IsShowingBuff = isBuff
		auraIconFrame.CanStealOrPurge = isStealable
		
		--border colors
		if IS_WOW_PROJECT_MIDNIGHT then
			if Plater.db.profile.aura_border_colors_by_type then
				local color
				if DB_AURA_ENABLED then --check for aura testing, so actual auras
					color = C_UnitAuras.GetAuraDispelTypeColor(auraIconFrame.unitFrame.namePlateUnitToken, i, dispelColorCurve)
				else
					color = DEBUFF_DISPLAY_COLOR_INFO[dispelName or "none"]
				end
				
				if color then
					--auraIconFrame:SetBackdropBorderColor(color:GetRGBA())
					auraIconFrame:SetBackdropBorderColor(color.r, color.g, color.b, color.a)
				else
					auraIconFrame:SetBackdropBorderColor (unpack (profile.aura_border_colors.is_debuff))
				end
			else
				local r, g, b, a = unpack (profile.aura_border_colors.default)
				local er, eg, eb, ea
				
				if isBuff ~= nil then
					er, eg, eb, ea = unpack (profile.aura_border_colors.is_buff)
					r, g, b, a = SplitEvaluateColor(isBuff, er, eg, eb, ea, r, g, b, a)
				end
				
				if isDebuff ~= nil then
					er, eg, eb, ea = unpack (profile.aura_border_colors.is_debuff)
					r, g, b, a = SplitEvaluateColor(isDebuff , er, eg, eb, ea, r, g, b, a)
				end

				local isCC = not C_UnitAuras.IsAuraFilteredOutByInstanceID(auraIconFrame.unitFrame.namePlateUnitToken, i, "HARMFUL|CROWD_CONTROL")
				if isCC ~= nil then
					er, eg, eb, ea = unpack (profile.aura_border_colors.crowdcontrol)
					r, g, b, a = SplitEvaluateColor(isCC, er, eg, eb, ea, r, g, b, a)
				end

				local isDefensive = not C_UnitAuras.IsAuraFilteredOutByInstanceID(auraIconFrame.unitFrame.namePlateUnitToken, i, "HELPFUL|BIG_DEFENSIVE") or not C_UnitAuras.IsAuraFilteredOutByInstanceID(auraIconFrame.unitFrame.namePlateUnitToken, i, "HELPFUL|EXTERNAL_DEFENSIVE")
				if isDefensive ~= nil then
					er, eg, eb, ea = unpack (profile.aura_border_colors.defensive)
					r, g, b, a = SplitEvaluateColor(isDefensive, er, eg, eb, ea, r, g, b, a)
				end

				if isStealable ~= nil then
					er, eg, eb, ea = unpack (profile.aura_border_colors.steal_or_purge)
					r, g, b, a = SplitEvaluateColor(isStealable, er, eg, eb, ea, r, g, b, a)
				end
				auraIconFrame:SetBackdropBorderColor(r, g, b, a)
			end
			--elseif (isBuff) then
			--	auraIconFrame:SetBackdropBorderColor (unpack (profile.aura_border_colors.is_buff))
			--
			--elseif (isDebuff) then
			--	auraIconFrame:SetBackdropBorderColor (unpack (profile.aura_border_colors.is_debuff))
			--	
			--elseif C_UnitAuras.IsAuraFilteredOutByInstanceID(auraIconFrame.unitFrame.namePlateUnitToken, i, "HARMFUL|CROWD_CONTROL") then
			--	auraIconFrame:SetBackdropBorderColor (unpack (profile.aura_border_colors.crowdcontrol))
			--	
			--else
			--	auraIconFrame:SetBackdropBorderColor (unpack (profile.aura_border_colors.default))
			--	
			--end
			
		else
		
			if (isStealable) then
				auraIconFrame:SetBackdropBorderColor (unpack (profile.aura_border_colors.steal_or_purge))
			
			elseif (Plater.db.profile.aura_border_colors_by_type) then
				if IS_WOW_PROJECT_MIDNIGHT_API then
					local color
					if DB_AURA_ENABLED then --check for aura testing, so actual auras
						color = C_UnitAuras.GetAuraDispelTypeColor(auraIconFrame.unitFrame.namePlateUnitToken, i, dispelColorCurve)
					else
						color = DEBUFF_DISPLAY_COLOR_INFO[dispelName or "none"]
					end
					
					if color then
						--auraIconFrame:SetBackdropBorderColor(color:GetRGBA())
						auraIconFrame:SetBackdropBorderColor(color.r, color.g, color.b, color.a)
					else
						auraIconFrame:SetBackdropBorderColor (unpack (profile.aura_border_colors.is_debuff))
					end
				else
					-- use Blizzards color global 'DebuffTypeColor' for the actual color:
					local color = DebuffTypeColor[dispelName or "none"] or {r=0,b=0,g=0, a=0}
					auraIconFrame:SetBackdropBorderColor (color.r, color.g, color.b, color.a or 1)
				end
			
			elseif (CROWDCONTROL_AURA_IDS [spellId]) then 
				--> CC effects
				auraIconFrame:SetBackdropBorderColor (unpack (profile.aura_border_colors.crowdcontrol))
			
			elseif (OFFENSIVE_AURA_IDS [spellId]) then 
				--> offensive CDs
				auraIconFrame:SetBackdropBorderColor (unpack (profile.aura_border_colors.offensive))
			
			elseif (DEFENSIVE_AURA_IDS [spellId]) then 
				--> defensive CDs
				auraIconFrame:SetBackdropBorderColor (unpack (profile.aura_border_colors.defensive))

			elseif (dispelName == AURA_TYPE_ENRAGE) then 
				--> enrage effects
				auraIconFrame:SetBackdropBorderColor (unpack (profile.aura_border_colors.enrage))
				
			elseif (isBuff) then
				auraIconFrame:SetBackdropBorderColor (unpack (profile.aura_border_colors.is_buff))
			
			elseif (isDebuff) then
				auraIconFrame:SetBackdropBorderColor (unpack (profile.aura_border_colors.is_debuff))
			
			elseif (isShowAll) then
				auraIconFrame:SetBackdropBorderColor (unpack (profile.aura_border_colors.is_show_all))
					
			else
				auraIconFrame:SetBackdropBorderColor (unpack (profile.aura_border_colors.default))
				
			end
		end

		local now = GetTime()
		--MIDNIGHT!!
		if IS_WOW_PROJECT_MIDNIGHT then --TODO (lots of...) MIDNIGHT!!
			local durationObjectOrig = C_UnitAuras.GetAuraDuration(auraIconFrame.unitFrame.namePlateUnitToken, i)
			local durationObject
			if not DB_AURA_ENABLED then --aura testing
				durationObject = C_DurationUtil.CreateDuration()
				durationObject:SetTimeFromEnd(expirationTime, duration, modRate or 1)
			elseif not durationObjectOrig then
				-- fallback for 0 duration
				durationObject = C_DurationUtil.CreateDuration()
				durationObject:SetTimeFromEnd(0, 0, 1)
			else
				durationObject = durationObjectOrig
			end
			local timeLeft = durationObject and durationObject:GetRemainingDuration()
			--local maxduration = C_UnitAuras.GetRefreshExtendedDuration(auraIconFrame.unitFrame.namePlateUnitToken, i)
			local maxduration = durationObject and durationObject:GetTotalDuration() or C_UnitAuras.GetAuraBaseDuration(auraIconFrame.unitFrame.namePlateUnitToken, i)
			auraIconFrame.Cooldown:SetDrawEdge(true)
			--auraIconFrame.Cooldown:SetCooldown(start, duration, modRate)
			--auraIconFrame.Cooldown:SetCooldownDuration(duration, modRate)
			local noExpirationTime = durationObject:IsZero()--C_UnitAuras.DoesAuraHaveExpirationTime(auraIconFrame.unitFrame.namePlateUnitToken, i)
			--auraIconFrame.Cooldown:SetCooldownFromExpirationTime(expirationTime, duration, modRate)
			if durationObjectOrig then
				auraIconFrame.Cooldown:SetCooldownFromDurationObject(durationObject)
				auraIconFrame.isPermanent = false
			else
				auraIconFrame.Cooldown:Clear()
				auraIconFrame.isPermanent = true
			end
			auraIconFrame.Cooldown:SetAlphaFromBoolean(noExpirationTime, 0, 1)
			
			auraIconFrame.noExpirationTime = noExpirationTime
			auraIconFrame.SpellName = spellName
			auraIconFrame.SpellId = spellId
			auraIconFrame.InUse = true
			auraIconFrame.RemainingTime = timeLeft
			auraIconFrame.Duration = maxduration
			auraIconFrame.DurationRemaining = duration
			auraIconFrame.Stacks = applications
			auraIconFrame.ExpirationTime = expirationTime
			auraIconFrame.Caster = sourceUnit
			auraIconFrame.AuraAmount = applications
			auraIconFrame.ModRate = modRate
			auraIconFrame.isBuff = isBuff
			auraIconFrame.durationObject = durationObject
			auraIconFrame:Show()

			auraIconFrame.Cooldown:SetHideCountdownNumbers(not Plater.db.profile.aura_timer)
			if Plater.db.profile.aura_timer then
				auraIconFrame.lastUpdateCooldown = now
				auraIconFrame:SetScript ("OnUpdate", auraIconFrame.UpdateCooldown)
				auraIconFrame.Cooldown.Timer:Show()
			
				if Plater.db.profile.aura_timer_pandemic_color then
					local pandemicColor = durationObject:EvaluateRemainingPercent(pandemicColorCurve)
					auraIconFrame.Cooldown.Timer:SetTextColor(pandemicColor:GetRGBA())
				else
					local c = Plater.db.profile.aura_timer_text_color
					auraIconFrame.Cooldown.Timer:SetTextColor(unpack(c))
				end
			else
				auraIconFrame:SetScript ("OnUpdate", nil)
				auraIconFrame.Cooldown.Timer:Hide()
			end

			return
		else
			modRate = modRate or 1
			--CooldownFrame_Set(self, start, duration, enable, forceShowDrawEdge, modRate)
			CooldownFrame_Set (auraIconFrame.Cooldown, expirationTime - duration, duration, duration > 0, true, modRate)
		end
		
		local timeLeft = (expirationTime - now) / modRate
		
		if (profile.aura_timer and timeLeft > 0) then
			--> update the aura timer
			local timerLabel = auraIconFrame.Cooldown.Timer

			auraIconFrame.formatWithDecimals = profile.aura_timer_decimals -- update setting
			if profile.aura_timer_decimals then
				timerLabel:SetText (Plater.FormatTimeDecimal (timeLeft))
			else
				timerLabel:SetText (Plater.FormatTime (timeLeft))
			end
			auraIconFrame.lastUpdateCooldown = now
			auraIconFrame:SetScript ("OnUpdate", auraIconFrame.UpdateCooldown)
			timerLabel:Show()
		else
			auraIconFrame:SetScript("OnUpdate", nil)
			auraIconFrame.Cooldown.Timer:Hide()
		end
		
		--check if the aura icon frame is already shown
		if (not IS_WOW_PROJECT_MIDNIGHT and auraIconFrame:IsShown()) then
			--is was showing a different aura, simulate a OnHide()
			if (auraIconFrame.SpellName ~= spellName) then
				aura_icon_on_hide_callback(auraIconFrame)
			end
		end
		
		--> spell name must be update here and cannot be cached due to scripts
		auraIconFrame.SpellName = spellName
		auraIconFrame.SpellId = spellId
		auraIconFrame.InUse = true
		auraIconFrame.RemainingTime = max (timeLeft, 0)
		auraIconFrame.Duration = duration
		auraIconFrame.Stacks = applications
		auraIconFrame.ExpirationTime = expirationTime
		auraIconFrame.Caster = sourceUnit
		auraIconFrame.AuraAmount = applications
		auraIconFrame.ModRate = modRate
		auraIconFrame.isBuff = isBuff
		auraIconFrame:Show()
		
		if (Plater.Masque and auraIconFrame.Masqued) then
			if (self.Name == "Main") then
				Plater.Masque.AuraFrame1:ReSkin(auraIconFrame)
			elseif (self.Name == "Secondary") then
				Plater.Masque.AuraFrame2:ReSkin(auraIconFrame)
			end
		end

		--auraIconFrame.Icon:Hide()
		--auraIconFrame.Cooldown:SetBackdrop (nil)
		--print (auraIconFrame.Border:GetObjectType())
		--print (auraIconFrame.Icon:GetAlpha())
		
		--print (self:GetName(), self:GetSize(), self:IsShown())
		
		Plater.EndLogPerformanceCore("Plater-Core", "Update", "UpdateAuras - AddAura")
		return true
	end
	
	function Plater.RunScriptTriggersForAuraIcons (unitFrame)
		
		local now = GetTime()
		
		local auraContainers = {unitFrame.BuffFrame.PlaterBuffList}
		if (DB_AURA_SEPARATE_BUFFS) then
			auraContainers [2] = unitFrame.BuffFrame2.PlaterBuffList
		end
    
		for containerID = 1, #auraContainers do
			local auraContainer = auraContainers [containerID]
		
			for index, auraIconFrame in pairs(auraContainer) do
				
				if auraIconFrame:IsShown() then
					local spellName = auraIconFrame.SpellName
					if not issecretvalue(spellName) and not issecretvalue(auraIconFrame.Duration) then
						--get the script object of the aura which will be showing in this icon frame
						local globalScriptObject = SCRIPT_AURA_TRIGGER_CACHE[spellName]
						
						--check if this aura has a custom script
						if (globalScriptObject) then
							--stored information about scripts
							local scriptContainer = auraIconFrame:ScriptGetContainer()
							
							--get the info about this particularly script
							local scriptInfo = auraIconFrame:ScriptGetInfo (globalScriptObject, scriptContainer)
							
							--set the aura information on the script env
							local scriptEnv = scriptInfo.Env
							scriptEnv._SpellID = auraIconFrame.spellId
							scriptEnv._UnitID = auraIconFrame.Caster
							scriptEnv._SpellName = auraIconFrame.SpellName
							scriptEnv._Texture = auraIconFrame.texture
							scriptEnv._Caster = auraIconFrame.Caster
							scriptEnv._StackCount = auraIconFrame.Stacks
							scriptEnv._Duration = auraIconFrame.Duration
							scriptEnv._StartTime = auraIconFrame.ExpirationTime - auraIconFrame.Duration
							scriptEnv._EndTime = auraIconFrame.ExpirationTime
							scriptEnv._RemainingTime = max (auraIconFrame.ExpirationTime - now, 0)
							scriptEnv._CanStealOrPurge = auraIconFrame.CanStealOrPurge
							scriptEnv._AuraType = auraIconFrame.AuraType
							scriptEnv._AuraAmount = auraIconFrame.AuraAmount
							
							--run onupdate script
							auraIconFrame:ScriptRunOnUpdate (scriptInfo)
						end
					end
				end
			
			end
		end
		
	end

	--> check both buff frames for aura icons which aren't in use and hide them
	Plater.HideNonUsedAuraIcons = function (self)
		if IS_WOW_PROJECT_MIDNIGHT_API_WITH_AURA_CONTAINERS then return end
	
		--aura frame 1
		local nextAuraIndex = self.NextAuraIcon
		for i = nextAuraIndex, #self.PlaterBuffList do
			local icon = self.PlaterBuffList [i]
			if (icon and icon.InUse and icon:IsShown()) then
				icon.ShowAnimation:Stop()
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
					icon.ShowAnimation:Stop()
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

	--~special ~auraspecial self is BuffFrame
	function Plater.AddExtraIcon (self, spellName, icon, applications, debuffType, duration, expirationTime, sourceUnit, isStealable, nameplateShowPersonal, spellId, isBuff, filter, id, modRate)
		Plater.StartLogPerformanceCore("Plater-Core", "Update", "UpdateAuras - AddExtraIcon")
		
		local sourceUnitName, sourceUnitClass
		local borderColor
		local profile = Plater.db.profile
		local startTime

		if IS_WOW_PROJECT_MIDNIGHT then
			local durationObject = C_UnitAuras.GetAuraDuration and C_UnitAuras.GetAuraDuration(self.unitFrame.namePlateUnitToken, id)
			duration = durationObject
			if sourceUnit ~= nil then
				--local sourceUnitGUID = UnitGUID(sourceUnit)
				local _, class, _, race, _, name, realm --= GetPlayerInfoByGUID(sourceUnitGUID)
				local name = UnitName(sourceUnit)
				local classColor
				if class then
					classColor = C_ClassColor.GetClassColor(class)
				end
				if classColor then
					sourceUnitName = classColor:WrapTextInColorCode(name)
				else
					sourceUnitName = name
				end
			end
		
			local color
			if DB_AURA_ENABLED then --check for aura testing, so actual auras
				if profile.extra_icon_use_blizzard_border_color then
					color = C_UnitAuras.GetAuraDispelTypeColor(self.unitFrame.namePlateUnitToken, id, dispelColorCurve)
				else
					local r, g, b, a = unpack (profile.extra_icon_border_color)
					local er, eg, eb, ea

					local isCC = not C_UnitAuras.IsAuraFilteredOutByInstanceID(self.unitFrame.namePlateUnitToken, id, "HARMFUL|CROWD_CONTROL")
					if isCC ~= nil then
						er, eg, eb, ea = unpack (profile.debuff_show_cc_border)
						r, g, b, a = SplitEvaluateColor(isCC, er, eg, eb, ea, r, g, b, a)
					end

					local isDefensive = not C_UnitAuras.IsAuraFilteredOutByInstanceID(self.unitFrame.namePlateUnitToken, id, "HELPFUL|BIG_DEFENSIVE") or not C_UnitAuras.IsAuraFilteredOutByInstanceID(self.unitFrame.namePlateUnitToken, id, "HELPFUL|EXTERNAL_DEFENSIVE")
					if isDefensive ~= nil then
						er, eg, eb, ea = unpack (profile.extra_icon_show_defensive_border)
						r, g, b, a = SplitEvaluateColor(isDefensive, er, eg, eb, ea, r, g, b, a)
					end

					if isStealable ~= nil then
						er, eg, eb, ea = unpack (profile.extra_icon_show_purge_border)
						r, g, b, a = SplitEvaluateColor(isStealable, er, eg, eb, ea, r, g, b, a)
					end

					color = {r = r, g = g, b = b, a = a}
				end
			else
				color = DEBUFF_DISPLAY_COLOR_INFO[dispelName or "none"]
			end
			
			if color then
				borderColor = {color.r, color.g, color.b, color.a}
			else
				borderColor = profile.aura_border_colors.debuff_show_cc_border
			end
		else
			startTime = expirationTime - duration

			if IS_WOW_PROJECT_MIDNIGHT_API then -- using midnight api icon code
				local tmpDuration = C_DurationUtil.CreateDuration()
				tmpDuration:SetTimeFromEnd(expirationTime, duration, modRate)
				duration = tmpDuration
			end

			local _, sourceUnitClassNow = UnitClass(sourceUnit or "")
			sourceUnitClass = sourceUnitClassNow
			if (sourceUnitClass and UnitPlayerControlled(sourceUnit)) then
				--adding only the name for players in case the player used a stun
				sourceUnitName = UnitName(sourceUnit)
			end
			
			if (isStealable) then
				borderColor = profile.extra_icon_show_purge_border

			elseif (profile.extra_icon_use_blizzard_border_color) then
				-- use blizzard border colors
				if IS_WOW_PROJECT_MIDNIGHT_API then
					local color
					if DB_AURA_ENABLED then --check for aura testing, so actual auras
						color = C_UnitAuras.GetAuraDispelTypeColor(self.unitFrame.namePlateUnitToken, id, dispelColorCurve)
					else
						color = DEBUFF_DISPLAY_COLOR_INFO[debuffType or "none"]
					end
					
					if color then
						borderColor = {color.r, color.g, color.b, color.a or 1}
					else
						borderColor = profile.aura_border_colors.is_debuff
					end

				else
					-- use Blizzards color global 'DebuffTypeColor' for the actual color:
					local color = DebuffTypeColor[debuffType or "none"] or {r=0, b=0, g=0, a=0} --dispelName is a global? it have been not passed | dispelName is the 5th argument
					borderColor = {color.r, color.g, color.b, color.a or 1}
				end

			elseif (CROWDCONTROL_AURA_IDS [spellId]) then
				borderColor = profile.debuff_show_cc_border

			elseif (DEFENSIVE_AURA_IDS [spellId]) then
				--> defensive effects
				borderColor = profile.extra_icon_show_defensive_border

			elseif (OFFENSIVE_AURA_IDS [spellId]) then
				--> offensive effects
				borderColor = profile.extra_icon_show_offensive_border

			elseif (debuffType == AURA_TYPE_ENRAGE) then
				--> enrage effects
				borderColor = profile.extra_icon_show_enrage_border

			else
				borderColor = profile.extra_icon_border_color
			end
		end

		--spellId, borderColor, startTime, duration, forceTexture, descText
		--calling SetIcon make the ExtraIconFrame call show() on it self
		local iconFrame = self.ExtraIconFrame:SetIcon (spellId, borderColor, startTime, duration, false, sourceUnitName and {text = sourceUnitName, text_color = sourceUnitClass} or false, applications, debuffType, sourceUnit, isStealable, spellName, isBuff, modRate)
		iconFrame.Texture:SetDesaturated(false) -- ensure this

		-- tooltip info
		if id and id > 0 then
			iconFrame:SetID (id)
			iconFrame.filter = filter
			iconFrame:SetScript ("OnEnter", Plater.OnEnterAura)
			iconFrame:SetScript ("OnLeave", Plater.OnLeaveAura)
			if iconFrame.EnableMouseMotion then
				iconFrame:EnableMouse (false)
				iconFrame:EnableMouseMotion (profile.aura_show_tooltip)
			else
				iconFrame:EnableMouse (profile.aura_show_tooltip)
			end
		else
			iconFrame:SetScript ("OnEnter", nil)
			iconFrame:SetScript ("OnLeave", nil)
			iconFrame:EnableMouse (false)
			if iconFrame.EnableMouseMotion then
				iconFrame:EnableMouseMotion (false)
			end
		end
		
		if (not iconFrame.platerSkinned) then
			iconFrame:ClearBackdrop()
			iconFrame.Border:Hide()
			
			iconFrame.Border = DF:CreateFullBorder("$parentBorder", iconFrame)
			for _, tex in pairs(iconFrame.Border.Textures) do
				tex:SetDrawLayer ("overlay", 7)
			end

			local iconOffset = -1
			PixelUtil.SetPoint (iconFrame.Border, "TOPLEFT", iconFrame, "TOPLEFT", -iconOffset, iconOffset)
			PixelUtil.SetPoint (iconFrame.Border, "TOPRIGHT", iconFrame, "TOPRIGHT", iconOffset, iconOffset)
			PixelUtil.SetPoint (iconFrame.Border, "BOTTOMLEFT", iconFrame, "BOTTOMLEFT", -iconOffset, -iconOffset)
			PixelUtil.SetPoint (iconFrame.Border, "BOTTOMRIGHT", iconFrame, "BOTTOMRIGHT", iconOffset, -iconOffset)
			iconFrame.SetBackdropBorderColor = function(self, r, g, b, a)
				self.Border:SetVertexColor(r, g, b, a)
			end
			iconFrame.Border.SetBorderSize = function(self, size)
				local borderSize = (size or 1) * UIParent:GetEffectiveScale()
				self:SetBorderSizes(borderSize, 1, borderSize, 0)
				self:UpdateSizes()
			end
			iconFrame.SetBorderSize = function(self, size)
				self.Border:SetBorderSize(size)
			end
			iconFrame.SetBackdrop = function(self, options)
				local borderSize = options.edgeSize or 1
				self.Border:SetBorderSize(borderSize)
			end
			iconFrame.GetBackdropBorderColor = function(self)
				return self.Border:GetVertexColor()
			end
			
			iconOffset = 0
			PixelUtil.SetPoint (iconFrame.Texture, "TOPLEFT", iconFrame, "TOPLEFT", -iconOffset, iconOffset)
			PixelUtil.SetPoint (iconFrame.Texture, "TOPRIGHT", iconFrame, "TOPRIGHT", iconOffset, iconOffset)
			PixelUtil.SetPoint (iconFrame.Texture, "BOTTOMLEFT", iconFrame, "BOTTOMLEFT", -iconOffset, -iconOffset)
			PixelUtil.SetPoint (iconFrame.Texture, "BOTTOMRIGHT", iconFrame, "BOTTOMRIGHT", iconOffset, -iconOffset)

			iconFrame.SetSizes = function(self)
				local extraBorderOffset = Plater.db.profile.extra_icon_border_extraoffset or 0
				local iconOffset = -1 * UIParent:GetEffectiveScale() + extraBorderOffset
				PixelUtil.SetPoint (self.Border, "TOPLEFT", self, "TOPLEFT", -iconOffset, iconOffset)
				PixelUtil.SetPoint (self.Border, "TOPRIGHT", self, "TOPRIGHT", iconOffset, iconOffset)
				PixelUtil.SetPoint (self.Border, "BOTTOMLEFT", self, "BOTTOMLEFT", -iconOffset, -iconOffset)
				PixelUtil.SetPoint (self.Border, "BOTTOMRIGHT", self, "BOTTOMRIGHT", iconOffset, -iconOffset)

				iconOffset = 0
				PixelUtil.SetPoint (self.Texture, "TOPLEFT", self, "TOPLEFT", -iconOffset, iconOffset)
				PixelUtil.SetPoint (self.Texture, "TOPRIGHT", self, "TOPRIGHT", iconOffset, iconOffset)
				PixelUtil.SetPoint (self.Texture, "BOTTOMLEFT", self, "BOTTOMLEFT", -iconOffset, -iconOffset)
				PixelUtil.SetPoint (self.Texture, "BOTTOMRIGHT", self, "BOTTOMRIGHT", iconOffset, -iconOffset)

				iconOffset = -1 * UIParent:GetEffectiveScale()
				PixelUtil.SetPoint (self.Cooldown, "TOPLEFT", self, "TOPLEFT", -iconOffset, iconOffset)
				PixelUtil.SetPoint (self.Cooldown, "TOPRIGHT", self, "TOPRIGHT", iconOffset, iconOffset)
				PixelUtil.SetPoint (self.Cooldown, "BOTTOMLEFT", self, "BOTTOMLEFT", -iconOffset, -iconOffset)
				PixelUtil.SetPoint (self.Cooldown, "BOTTOMRIGHT", self, "BOTTOMRIGHT", iconOffset, -iconOffset)
			end

			iconFrame.platerSkinned = true
		end

		iconFrame:SetBackdropBorderColor(unpack(borderColor))
		iconFrame:SetBorderSize(profile.extra_icon_border_size or 1)
		iconFrame:SetSizes()
		
		--check if Masque is enabled on Plater and reskin the aura icon
		if (Plater.Masque and not iconFrame.Masqued) then
			local t = {
				FloatingBG = nil, --false,
				Icon = iconFrame.Texture,
				Cooldown = iconFrame.Cooldown,
				Flash = nil, --false,
				Pushed = nil, --false,
				Normal = nil, --false
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
			local mOptions = Plater.Masque.BuffSpecial:GetOptions()
			if mOptions and mOptions.Disable and mOptions.Disable.get and not mOptions.Disable.get() then
				iconFrame.Border:Hide() --let Masque handle the border...
			end
			Plater.Masque.BuffSpecial:AddButton (iconFrame, t, "Aura", true)
			--Plater.Masque.BuffSpecial:ReSkin(iconFrame)
			iconFrame.Masqued = true
		end
		
		if (Plater.Masque and iconFrame.Masqued) then
			Plater.Masque.BuffSpecial:ReSkin(iconFrame)
		end
		
		Plater.EndLogPerformanceCore("Plater-Core", "Update", "UpdateAuras - AddExtraIcon")
	end
	
	--> reset both buff frames to make them ready to receive an aura update
	function Plater.ResetAuraContainer (self, resetBuffs, resetDebuffs)
		if IS_WOW_PROJECT_MIDNIGHT_API_WITH_AURA_CONTAINERS then return end
		Plater.StartLogPerformanceCore("Plater-Core", "Update", "UpdateAuras - ResetAuraContainer")
		--DevTool:AddData({resetBuffs, resetDebuffs}, "ResetAuraContainer")
		-- ensure reset is happening if nil
		resetBuffs = resetBuffs ~= false
		resetDebuffs = resetDebuffs ~= false
	
		--> reset the extra icon frame
		self.ExtraIconFrame:ClearIcons(resetBuffs, resetDebuffs)
		
		--> reset auras
		if resetDebuffs or not DB_AURA_SEPARATE_BUFFS then
			wipe (self.unitFrame.GhostAuraCache) -- ghost and extra are on aura frame 1, needs to be cleared.
			platerInternal.ExtraAuras.WipeCache(self.unitFrame)
			
			wipe (self.AuraCache)
			self.HasBuff = false
			self.HasDebuff = false
			--> reset next aura icon to use
			self.NextAuraIcon = 1
		end
		
		--> second buff anchor
		if resetBuffs then
			wipe (self.BuffFrame2.AuraCache)
			self.BuffFrame2.HasBuff = false 
			self.BuffFrame2.HasDebuff = false
			--> reset next aura icon to use
			self.BuffFrame2.NextAuraIcon = 1
		end
		
		--> wipe the cache
		wipe (self.unitFrame.AuraCache)
		
		--> rebuild the cache
		self.unitFrame.AuraCache = DF.table.copy(self.unitFrame.AuraCache, self.AuraCache)
		self.unitFrame.AuraCache = DF.table.copy(self.unitFrame.AuraCache, self.BuffFrame2.AuraCache)
		self.unitFrame.AuraCache = DF.table.copy(self.unitFrame.AuraCache, self.ExtraIconFrame.AuraCache)
		
		Plater.EndLogPerformanceCore("Plater-Core", "Update", "UpdateAuras - ResetAuraContainer")
		
	end

	
	-- ~auras ~aura
	--receives a hash table with spell names keys and true as the value
	--used when the user selects manual aura tracking
	function Plater.TrackSpecificAuras (self, unit, isBuff, aurasToCheck, isPersonal, noSpecial)
		if IS_WOW_PROJECT_MIDNIGHT_API_WITH_AURA_CONTAINERS then return end
		local unitAuraCache = self.unitFrame.AuraCache
		local show_debuffs_personal = Plater.db.profile.aura_show_debuffs_personal
		local show_buffs_personal = Plater.db.profile.aura_show_buffs_personal
 
		if (isBuff) then
			local unitAuras = getUnitAuras(unit, "HELPFUL") or {}
			self.buffsInOrder = unitAuras.buffsInOrder or {}
			
			for id, aura in pairs(unitAuras.buffs or {}) do
				--DevTool:AddData({i, aura})
				local name, icon, applications, dispelName, duration, expirationTime, sourceUnit, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossAura, isFromPlayerOrPlayerPet, nameplateShowAll, timeMod, applications = 
					aura.name, aura.icon, aura.applications, aura.dispelName, aura.duration, aura.expirationTime, aura.sourceUnit, aura.isStealable, aura.nameplateShowPersonal, aura.spellId, aura.canApplyAura, 
					aura.isBossAura, aura.isFromPlayerOrPlayerPet, aura.nameplateShowAll, aura.timeMod, aura.applications
				
				if not IS_WOW_PROJECT_MIDNIGHT then
					unitAuraCache[name] = true
					unitAuraCache[spellId] = true
					unitAuraCache[name.."_"..(sourceUnit or "N/A")] = true
					unitAuraCache[spellId.."_"..(sourceUnit or "N/A")] = true
					unitAuraCache.canStealOrPurge = unitAuraCache.canStealOrPurge or isStealable
					unitAuraCache.hasEnrage = unitAuraCache.hasEnrage or dispelName == AURA_TYPE_ENRAGE
				end
				
				if ((show_buffs_personal and isPersonal) or not isPersonal) then
				
					local auraType = "BUFF"
					local isSpecial = false
					
					--> check if is a special aura
					if (not noSpecial) then
						--> check for special auras auto added by setting like 'show crowd control' or 'show dispellable'
						--> SPECIAL_AURAS_AUTO_ADDED has a list of crowd control not do not have a list of dispellable, so check if isStealable.
						--> in addition, we want to check if enrage tracking is enabled and show enrage effects
						if not IS_WOW_PROJECT_MIDNIGHT and (SPECIAL_AURAS_AUTO_ADDED [name] or SPECIAL_AURAS_AUTO_ADDED [spellId] or (DB_SHOW_PURGE_IN_EXTRA_ICONS and isStealable) or (DB_SHOW_ENRAGE_IN_EXTRA_ICONS and dispelName == AURA_TYPE_ENRAGE) or (DB_SHOW_MAGIC_IN_EXTRA_ICONS and dispelName == AURA_TYPE_MAGIC)) then
							Plater.AddExtraIcon (self, name, icon, applications, dispelName, duration, expirationTime, sourceUnit, isStealable, nameplateShowPersonal, spellId, true, "HELPFUL", id, timeMod)
							isSpecial = true
						
						--> check for special auras added by the user it self
						elseif not IS_WOW_PROJECT_MIDNIGHT and (((SPECIAL_AURAS_USER_LIST [name] or SPECIAL_AURAS_USER_LIST [spellId]) and not (SPECIAL_AURAS_USER_LIST_MINE [name] or SPECIAL_AURAS_USER_LIST_MINE [spellId])) or ((SPECIAL_AURAS_USER_LIST_MINE [name] or SPECIAL_AURAS_USER_LIST_MINE [spellId]) and aura.sourceIsPlayer)) then
							Plater.AddExtraIcon (self, name, icon, applications, dispelName, duration, expirationTime, sourceUnit, isStealable, nameplateShowPersonal, spellId, true,"HELPFUL", id, timeMod)
							isSpecial = true
							
						end
					end
					
					--verify is this aura is in the table passed
					if not IS_WOW_PROJECT_MIDNIGHT and (not isSpecial and (aurasToCheck [name] or aurasToCheck [spellId])) then
						local auraIconFrame, buffFrame = Plater.GetAuraIcon (self, true)
						Plater.AddAura (buffFrame, auraIconFrame, id, name, icon, applications, auraType, duration, expirationTime, sourceUnit, isFromPlayerOrPlayerPet, isStealable, nameplateShowPersonal, spellId, true, false, false, isPersonal, dispelName, timeMod)
					elseif IS_WOW_PROJECT_MIDNIGHT then
						local auraIconFrame, buffFrame = Plater.GetAuraIcon (self, true)
						Plater.AddAura (buffFrame, auraIconFrame, id, name, icon, applications, auraType, duration, expirationTime, sourceUnit, isFromPlayerOrPlayerPet, isStealable, nameplateShowPersonal, spellId, true, false, false, isPersonal, dispelName, timeMod)
					end
				end
			end
		else
			--> debuffs
			local unitAuras = getUnitAuras(unit, "HARMFUL") or {}
			self.debuffsInOrder = unitAuras.debuffsInOrder or {}
			
			for id, aura in pairs(unitAuras.debuffs or {}) do
				--DevTool:AddData({i, aura})
				local name, icon, applications, dispelName, duration, expirationTime, sourceUnit, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossAura, isFromPlayerOrPlayerPet, nameplateShowAll, timeMod, applications = 
					aura.name, aura.icon, aura.applications, aura.dispelName, aura.duration, aura.expirationTime, aura.sourceUnit, aura.isStealable, aura.nameplateShowPersonal, aura.spellId, aura.canApplyAura, 
					aura.isBossAura, aura.isFromPlayerOrPlayerPet, aura.nameplateShowAll, aura.timeMod, aura.applications
				
				if not IS_WOW_PROJECT_MIDNIGHT then
					unitAuraCache[name] = true
					unitAuraCache[spellId] = true
					unitAuraCache[name.."_"..(sourceUnit or "N/A")] = true
					unitAuraCache[spellId.."_"..(sourceUnit or "N/A")] = true
					unitAuraCache.canStealOrPurge = unitAuraCache.canStealOrPurge or isStealable
					unitAuraCache.hasEnrage = unitAuraCache.hasEnrage or dispelName == AURA_TYPE_ENRAGE
				end
				
				if ((show_debuffs_personal and isPersonal) or not isPersonal) then
				
					local auraType = "DEBUFF"
					local isSpecial = false
					
					--> check if is a special aura
					if (not noSpecial) then
						--> check for special auras auto added by setting like 'show crowd control' or 'show dispellable'
						--> SPECIAL_AURAS_AUTO_ADDED has a list of crowd control not do not have a list of dispellable, so check if isStealable
						--> in addition, we want to check if enrage tracking is enabled and show enrage effects
						if not IS_WOW_PROJECT_MIDNIGHT and (SPECIAL_AURAS_AUTO_ADDED [name] or SPECIAL_AURAS_AUTO_ADDED [spellId] or (DB_SHOW_PURGE_IN_EXTRA_ICONS and isStealable) or (DB_SHOW_ENRAGE_IN_EXTRA_ICONS and dispelName == AURA_TYPE_ENRAGE)) then
							Plater.AddExtraIcon (self, name, icon, applications, dispelName, duration, expirationTime, sourceUnit, isStealable, nameplateShowPersonal, spellId, false, "HARMFUL", id, timeMod)
							isSpecial = true
						
						--> check for special auras added by the user it self
						elseif not IS_WOW_PROJECT_MIDNIGHT and (((SPECIAL_AURAS_USER_LIST [name] or SPECIAL_AURAS_USER_LIST [spellId]) and not (SPECIAL_AURAS_USER_LIST_MINE [name] or SPECIAL_AURAS_USER_LIST_MINE [spellId])) or ((SPECIAL_AURAS_USER_LIST_MINE [name] or SPECIAL_AURAS_USER_LIST_MINE [spellId]) and aura.sourceIsPlayer)) then
							Plater.AddExtraIcon (self, name, icon, applications, dispelName, duration, expirationTime, sourceUnit, isStealable, nameplateShowPersonal, spellId, false, "HARMFUL", id, timeMod)
							isSpecial = true
							
						end
					end
					
					--checking here if the debuff is placed by the player
					--if (sourceUnit and aurasToCheck [name] and UnitIsUnit (sourceUnit, "player")) then --this doesn't track the pet, so auras like freeze from mage frost elemental won't show
					if not IS_WOW_PROJECT_MIDNIGHT and (not isSpecial and (aurasToCheck [name] or aurasToCheck [spellId]) and aura.sourceIsPlayer) then
					--if (aurasToCheck [name]) then
						local auraIconFrame, buffFrame = Plater.GetAuraIcon (self)
						Plater.AddAura (buffFrame, auraIconFrame, id, name, icon, applications, auraType, duration, expirationTime, sourceUnit, isFromPlayerOrPlayerPet, isStealable, nameplateShowPersonal, spellId, false, false, true, isPersonal, dispelName, timeMod)
					elseif IS_WOW_PROJECT_MIDNIGHT then
						local auraIconFrame, buffFrame = Plater.GetAuraIcon (self)
						Plater.AddAura (buffFrame, auraIconFrame, id, name, icon, applications, auraType, duration, expirationTime, sourceUnit, isFromPlayerOrPlayerPet, isStealable, nameplateShowPersonal, spellId, false, false, true, isPersonal, dispelName, timeMod)
					end
				end
			end
		end
		
		return true
	end
	
	function Plater.UpdateAuras_Manual (self, unit, isPersonal)
		if IS_WOW_PROJECT_MIDNIGHT_API_WITH_AURA_CONTAINERS then return end
		Plater.StartLogPerformanceCore("Plater-Core", "Update", "UpdateAuras_Manual")
		
		if UnitAuraEventHandlerData[unit] then
		
			local unitAuraEventData = UnitAuraEventHandlerData[unit]
			
			Plater.ResetAuraContainer (self, unitAuraEventData.hasBuff, unitAuraEventData.hasDebuff)
			
			
			if unitAuraEventData.hasDebuff then
				Plater.TrackSpecificAuras (self, unit, false, MANUAL_TRACKING_DEBUFFS, isPersonal)
			end
			if unitAuraEventData.hasBuff then
				Plater.TrackSpecificAuras (self, unit, true, MANUAL_TRACKING_BUFFS, isPersonal)
			end

			--> hide not used aura frames
			Plater.HideNonUsedAuraIcons (self)
			
			UnitAuraEventHandlerData[unit] = nil
		end
		
		Plater.EndLogPerformanceCore("Plater-Core", "Update", "UpdateAuras_Manual")
	end

	--> track auras automatically when the user has automatic aura tracking selected in the options panel
	function Plater.UpdateAuras_Automatic (self, unit)
		if IS_WOW_PROJECT_MIDNIGHT_API_WITH_AURA_CONTAINERS then return end
		Plater.StartLogPerformanceCore("Plater-Core", "Update", "UpdateAuras_Automatic")
		
		local unitAuraEventData = UnitAuraEventHandlerData[unit]
		if not unitAuraEventData then
			Plater.EndLogPerformanceCore("Plater-Core", "Update", "UpdateAuras_Automatic")
			return
		end
		
		Plater.ResetAuraContainer (self, unitAuraEventData.hasBuff, unitAuraEventData.hasDebuff)
		local unitAuraCache = self.unitFrame.AuraCache
		--DevTool:AddData({unitAuraEventData.hasBuff, unitAuraEventData.hasDebuff}, "UpdateAuras_Automatic")
		--> debuffs
		if unitAuraEventData.hasDebuff then
			local blizzardDebuffs = {}
			if IS_WOW_PROJECT_MIDNIGHT and DB_AURA_SHOW_AS_BLIZZARD then
				blizzardDebuffs = getBlizzardDebuffs(self.unitFrame)
			end
			local unitAuras = getUnitAuras(unit, "HARMFUL") or {}
			self.debuffsInOrder = unitAuras.debuffsInOrder or {}
			for id, aura in pairs(unitAuras.debuffs or {}) do
				--DevTool:AddData({i, aura})
				local name, icon, applications, dispelName, duration, expirationTime, sourceUnit, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossAura, isFromPlayerOrPlayerPet, nameplateShowAll, timeMod, applications = 
					aura.name, aura.icon, aura.applications, aura.dispelName, aura.duration, aura.expirationTime, aura.sourceUnit, aura.isStealable, aura.nameplateShowPersonal, aura.spellId, aura.canApplyAura, 
					aura.isBossAura, aura.isFromPlayerOrPlayerPet, aura.nameplateShowAll, aura.timeMod, aura.applications
				--start as false, during the checks can be changed to true, if is true this debuff is added on the nameplate
				local can_show_this_debuff
				local auraType = "DEBUFF"
				
				if not IS_WOW_PROJECT_MIDNIGHT then
					unitAuraCache[name] = true
					unitAuraCache[spellId] = true
					unitAuraCache[name.."_"..(sourceUnit or "N/A")] = true
					unitAuraCache[spellId.."_"..(sourceUnit or "N/A")] = true
					unitAuraCache.canStealOrPurge = unitAuraCache.canStealOrPurge or isStealable
					unitAuraCache.hasEnrage = unitAuraCache.hasEnrage or dispelName == AURA_TYPE_ENRAGE
				end

				--check if the debuff isn't filtered out
				if not IS_WOW_PROJECT_MIDNIGHT and (not DB_DEBUFF_BANNED [name] and not DB_DEBUFF_BANNED [spellId]) then
			
					--> if true it'll show all auras - this can be called from scripts to debug aura things
					if (Plater.DebugAuras) then
						if (duration and duration < 60) then
							can_show_this_debuff = true
						end
					end
					
					local sourceIsPlayer = aura.sourceIsPlayer or (sourceUnit and Plater.PlayerPetCache[UnitGUID(sourceUnit)]) and true
			
					--> important aura
					if Plater.db.profile.debuff_hide_permanent and (not duration or duration == 0) then
						can_show_this_debuff = false -- no duration -> permanent -> hide

					elseif (DB_AURA_SHOW_IMPORTANT and (nameplateShowAll or isBossAura or (nameplateShowPersonal and sourceIsPlayer))) then
						can_show_this_debuff = true
					
					--> is casted by the player
					elseif (DB_AURA_SHOW_BYPLAYER and sourceIsPlayer) then
						can_show_this_debuff = true
						
					--> is casted by other players
					elseif (DB_AURA_SHOW_BYOTHERPLAYERS and isFromPlayerOrPlayerPet and sourceUnit and not sourceIsPlayer) then
						can_show_this_debuff = true
						
					--> is casted by other npcs
					elseif (DB_AURA_SHOW_BYOTHERNPCS and not isFromPlayerOrPlayerPet and sourceUnit and not aura.sourceIsSelf and aura.sourceReaction <= 4) then
						can_show_this_debuff = true
						
					--> is casted by the unit it self
					elseif (DB_AURA_SHOW_DEBUFFBYUNIT and sourceUnit and aura.sourceIsSelf and not isFromPlayerOrPlayerPet) then
						can_show_this_debuff = true
					
					--> user added this buff to track in the buff tracking tab
					elseif (AUTO_TRACKING_EXTRA_DEBUFFS [name] or AUTO_TRACKING_EXTRA_DEBUFFS [spellId]) then
						can_show_this_debuff = true
					end
					
					--> check for special auras auto added by setting like 'show crowd control' or 'show dispellable'
					--> SPECIAL_AURAS_AUTO_ADDED has a list of crowd control not do not have a list of dispellable, so check if isStealable
					--> in addition, we want to check if enrage tracking is enabled and show enrage effects
					if (SPECIAL_AURAS_AUTO_ADDED [name] or SPECIAL_AURAS_AUTO_ADDED [spellId] or (DB_SHOW_PURGE_IN_EXTRA_ICONS and isStealable) or (DB_SHOW_ENRAGE_IN_EXTRA_ICONS and dispelName == AURA_TYPE_ENRAGE)) then
						Plater.AddExtraIcon (self, name, icon, applications, dispelName, duration, expirationTime, sourceUnit, isStealable, nameplateShowPersonal, spellId, false, "HARMFUL", id, timeMod)
						can_show_this_debuff = false
					end
				elseif IS_WOW_PROJECT_MIDNIGHT then
					--local durationObject = C_UnitAuras.GetAuraDuration(unit, id)
					--print(issecretvalue(C_UnitAuras.AuraIsBigDefensive(spellId)), C_UnitAuras.AuraIsBigDefensive(spellId), issecretvalue(C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, aura.auraInstanceID, "CROWD_CONTROL")), C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, aura.auraInstanceID, "CROWD_CONTROL"))
					
					-- TODO: MIDNIGHT!!
					--print(C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, aura.auraInstanceID, "HARMFUL|RAID_IN_COMBAT"), C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, aura.auraInstanceID, "HARMFUL|RAID"), C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, aura.auraInstanceID, "IMPORTANT"))
					--if Plater.db.profile.debuff_hide_permanent and not C_UnitAuras.GetAuraDuration(unit, id) then
						--can_show_this_debuff = false - no duration -> permanent -> hide. But cannot be done here, as aura duration will be returned. checking visible CD instead as workaround
					if Plater.db.profile.debuff_show_cc and not C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, aura.auraInstanceID, "HARMFUL|CROWD_CONTROL") then
						Plater.AddExtraIcon (self, name, icon, applications, dispelName, duration, expirationTime, sourceUnit, isStealable, nameplateShowPersonal, spellId, false, "HARMFUL", id, timeMod)
						can_show_this_debuff = false
					elseif DB_SHOW_PURGE_IN_EXTRA_ICONS and self.unitFrame.namePlateUnitReaction > 4 and not C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, aura.auraInstanceID, "HARMFUL|RAID_PLAYER_DISPELLABLE") then
						Plater.AddExtraIcon (self, name, icon, applications, dispelName, duration, expirationTime, sourceUnit, isStealable, nameplateShowPersonal, spellId, false, "HARMFUL", id, timeMod)
						can_show_this_debuff = false
					elseif DB_AURA_SHOW_AS_BLIZZARD and blizzardDebuffs[id] then
						can_show_this_debuff = true
					elseif DB_AURA_SHOW_DISPELLABLE and self.unitFrame.namePlateUnitReaction > 4 and not C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, aura.auraInstanceID, "HARMFUL|RAID_PLAYER_DISPELLABLE") then -- this requires rework. shows wl curses on enemy nameplates
						can_show_this_debuff = true
					elseif DB_AURA_SHOW_RAID and (not C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, aura.auraInstanceID, "HARMFUL|RAID_IN_COMBAT") or not C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, aura.auraInstanceID, "HARMFUL|RAID")) then
						can_show_this_debuff = true
					elseif DB_AURA_SHOW_DEBUFF_BYPLAYER and not C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, aura.auraInstanceID, "HARMFUL|PLAYER") then
						can_show_this_debuff = true
					elseif Plater.db.profile.aura_show_crowdcontrol and not C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, aura.auraInstanceID, "HARMFUL|CROWD_CONTROL") then
						can_show_this_debuff = true
					end
					--can_show_this_debuff = not C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, aura.auraInstanceID, HARM_BUFF_FILTER)
				end
				
				--> check for special auras added by the user it self
				if not IS_WOW_PROJECT_MIDNIGHT and (can_show_this_debuff ~= false and (((SPECIAL_AURAS_USER_LIST [name] or SPECIAL_AURAS_USER_LIST [spellId]) and not (SPECIAL_AURAS_USER_LIST_MINE [name] or SPECIAL_AURAS_USER_LIST_MINE [spellId])) or ((SPECIAL_AURAS_USER_LIST_MINE [name] or SPECIAL_AURAS_USER_LIST_MINE [spellId]) and aura.sourceIsPlayer))) then
					Plater.AddExtraIcon (self, name, icon, applications, dispelName, duration, expirationTime, sourceUnit, isStealable, nameplateShowPersonal, spellId, false, "HARMFUL", id, timeMod)
					can_show_this_debuff = false
				end
				
				if (can_show_this_debuff) then
					--get the icon to be used by this aura
					local auraIconFrame, buffFrame = Plater.GetAuraIcon (self)
					Plater.AddAura (buffFrame, auraIconFrame, id, name, icon, applications, auraType, duration, expirationTime, sourceUnit, isFromPlayerOrPlayerPet, isStealable, nameplateShowPersonal, spellId, false, nil, true, nil, dispelName, timeMod)
				end
			end
		end
		
		--> buffs
		if unitAuraEventData.hasBuff then
			local blizzardBuffs = {}
			if IS_WOW_PROJECT_MIDNIGHT and DB_AURA_SHOW_BUFFS_AS_BLIZZARD then
				blizzardBuffs = getBlizzardBuffs(self.unitFrame)
			end
			local unitAuras = getUnitAuras(unit, "HELPFUL") or {}
			self.buffsInOrder = unitAuras.buffsInOrder or {}
			--DevTool:AddData(unitAuras, "HELPFUL")
			
			for id, aura in pairs(unitAuras.buffs or {}) do
				--DevTool:AddData({i, aura})
				local name, icon, applications, dispelName, duration, expirationTime, sourceUnit, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossAura, isFromPlayerOrPlayerPet, nameplateShowAll, timeMod, applications = 
					aura.name, aura.icon, aura.applications, aura.dispelName, aura.duration, aura.expirationTime, aura.sourceUnit, aura.isStealable, aura.nameplateShowPersonal, aura.spellId, aura.canApplyAura, 
					aura.isBossAura, aura.isFromPlayerOrPlayerPet, aura.nameplateShowAll, aura.timeMod, aura.applications
				
				local auraType = "BUFF"
				
				if not IS_WOW_PROJECT_MIDNIGHT then
					unitAuraCache[name] = true
					unitAuraCache[spellId] = true
					unitAuraCache[name.."_"..(sourceUnit or "N/A")] = true
					unitAuraCache[spellId.."_"..(sourceUnit or "N/A")] = true
					unitAuraCache.canStealOrPurge = unitAuraCache.canStealOrPurge or isStealable
					unitAuraCache.hasEnrage = unitAuraCache.hasEnrage or dispelName == AURA_TYPE_ENRAGE
				end
				
				--> check for special auras added by the user it self
				if not IS_WOW_PROJECT_MIDNIGHT and (((SPECIAL_AURAS_USER_LIST [name] or SPECIAL_AURAS_USER_LIST [spellId]) and not (SPECIAL_AURAS_USER_LIST_MINE [name] or SPECIAL_AURAS_USER_LIST_MINE [spellId])) or ((SPECIAL_AURAS_USER_LIST_MINE [name] or SPECIAL_AURAS_USER_LIST_MINE [spellId]) and aura.sourceIsPlayer)) then
					Plater.AddExtraIcon (self, name, icon, applications, dispelName, duration, expirationTime, sourceUnit, isStealable, nameplateShowPersonal, spellId, true, "HELPFUL", id, timeMod)
					
				elseif not IS_WOW_PROJECT_MIDNIGHT and (not DB_BUFF_BANNED [name] and not DB_BUFF_BANNED [spellId]) then
					--> if true it'll show all auras - this can be called from scripts to debug aura things
					if (Plater.DebugAuras) then
						if (duration and duration < 60) then
							local auraIconFrame, buffFrame = Plater.GetAuraIcon (self, true)
							Plater.AddAura (buffFrame, auraIconFrame, id, name, icon, applications, auraType, duration, expirationTime, sourceUnit, isFromPlayerOrPlayerPet, isStealable, nameplateShowPersonal, spellId, true, nil, nil, nil, dispelName, timeMod)
						end
					end
					
					--> this special aura check is inside the 'buff banned' prevented because they are automatic added
					--> check for special auras auto added by setting like 'show crowd control' or 'show dispellable'
					--> SPECIAL_AURAS_AUTO_ADDED has a list of crowd control not do not have a list of dispellable, so check if isStealable
					--> in addition, we want to check if enrage tracking is enabled and show enrage effects
					if (SPECIAL_AURAS_AUTO_ADDED [name] or SPECIAL_AURAS_AUTO_ADDED [spellId] or (DB_SHOW_PURGE_IN_EXTRA_ICONS and isStealable) or (DB_SHOW_ENRAGE_IN_EXTRA_ICONS and dispelName == AURA_TYPE_ENRAGE) or (DB_SHOW_MAGIC_IN_EXTRA_ICONS and dispelName == AURA_TYPE_MAGIC)) then
						Plater.AddExtraIcon (self, name, icon, applications, dispelName, duration, expirationTime, sourceUnit, isStealable, nameplateShowPersonal, spellId, true, "HELPFUL", id, timeMod)
					else
						--> important aura
						local sourceIsPlayer = aura.sourceIsPlayer or (sourceUnit and Plater.PlayerPetCache[UnitGUID(sourceUnit)]) and true
						
						if Plater.db.profile.debuff_hide_permanent and (not duration or duration == 0) then
							-- no duration -> permanent -> hide

						elseif (DB_AURA_SHOW_IMPORTANT and (nameplateShowAll or isBossAura or (nameplateShowPersonal and sourceIsPlayer))) then
							local auraIconFrame, buffFrame = Plater.GetAuraIcon (self, true)
							Plater.AddAura (buffFrame, auraIconFrame, id, name, icon, applications, auraType, duration, expirationTime, sourceUnit, isFromPlayerOrPlayerPet, isStealable, nameplateShowPersonal, spellId, true, true, nil, nil, dispelName, timeMod)
						
						--> is dispellable or can be steal
						elseif (DB_AURA_SHOW_DISPELLABLE and isStealable) then
							if (self.unitFrame.isPlayer and DB_AURA_SHOW_ONLY_SHORT_DISPELLABLE_ON_PLAYERS) then
								--don't show dispellable on players if the duration is bigger than 2 minutes (terciob july 2022)
								--this avoid showing big buffs like power word: fortitute
								--show infinite as well and option to enable this separately (continuity, july 2022)
								if (duration == 0 or duration < 120) then
									local auraIconFrame, buffFrame = Plater.GetAuraIcon (self, true)
									Plater.AddAura (buffFrame, auraIconFrame, id, name, icon, applications, auraType, duration, expirationTime, sourceUnit, isFromPlayerOrPlayerPet, isStealable, nameplateShowPersonal, spellId, true, nil, nil, nil, dispelName, timeMod)
								end
							else
								local auraIconFrame, buffFrame = Plater.GetAuraIcon (self, true)
								Plater.AddAura (buffFrame, auraIconFrame, id, name, icon, applications, auraType, duration, expirationTime, sourceUnit, isFromPlayerOrPlayerPet, isStealable, nameplateShowPersonal, spellId, true, nil, nil, nil, dispelName, timeMod)
							end
							
						--> is enrage
						elseif (DB_AURA_SHOW_ENRAGE and dispelName == AURA_TYPE_ENRAGE) then
							local auraIconFrame, buffFrame = Plater.GetAuraIcon (self, true)
							Plater.AddAura (buffFrame, auraIconFrame, id, name, icon, applications, auraType, duration, expirationTime, sourceUnit, isFromPlayerOrPlayerPet, isStealable, nameplateShowPersonal, spellId, true, nil, nil, nil, dispelName, timeMod)
						
						--> is magic
						elseif (DB_AURA_SHOW_MAGIC and dispelName == AURA_TYPE_MAGIC) then
							local auraIconFrame, buffFrame = Plater.GetAuraIcon (self, true)
							Plater.AddAura (buffFrame, auraIconFrame, id, name, icon, applications, auraType, duration, expirationTime, sourceUnit, isFromPlayerOrPlayerPet, isStealable, nameplateShowPersonal, spellId, true, nil, nil, nil, dispelName, timeMod)
						
						--> is casted by the player
						elseif (DB_AURA_SHOW_BYPLAYER and sourceIsPlayer) then
							local auraIconFrame, buffFrame = Plater.GetAuraIcon (self, true)
							Plater.AddAura (buffFrame, auraIconFrame, id, name, icon, applications, auraType, duration, expirationTime, sourceUnit, isFromPlayerOrPlayerPet, isStealable, nameplateShowPersonal, spellId, true, nil, nil, nil, dispelName, timeMod)
							
						--> is casted by other players
						elseif (DB_AURA_SHOW_BYOTHERPLAYERS and isFromPlayerOrPlayerPet and sourceUnit and not sourceIsPlayer) then
							local auraIconFrame, buffFrame = Plater.GetAuraIcon (self, true)
							Plater.AddAura (buffFrame, auraIconFrame, id, name, icon, applications, auraType, duration, expirationTime, sourceUnit, isFromPlayerOrPlayerPet, isStealable, nameplateShowPersonal, spellId, true, nil, nil, nil, dispelName, timeMod)
												
						--> is casted by other nopcs
						elseif (DB_AURA_SHOW_BYOTHERNPCS and not isFromPlayerOrPlayerPet and sourceUnit and not aura.sourceIsSelf and aura.sourceReaction <= 4) then
							local auraIconFrame, buffFrame = Plater.GetAuraIcon (self, true)
							Plater.AddAura (buffFrame, auraIconFrame, id, name, icon, applications, auraType, duration, expirationTime, sourceUnit, isFromPlayerOrPlayerPet, isStealable, nameplateShowPersonal, spellId, true, nil, nil, nil, dispelName, timeMod)
							
						--> is casted by the unit it self
						elseif (DB_AURA_SHOW_BUFFBYUNIT and aura.sourceIsSelf and not isFromPlayerOrPlayerPet) then
							local auraIconFrame, buffFrame = Plater.GetAuraIcon (self, true)
							Plater.AddAura (buffFrame, auraIconFrame, id, name, icon, applications, auraType, duration, expirationTime, sourceUnit, isFromPlayerOrPlayerPet, isStealable, nameplateShowPersonal, spellId, true, nil, nil, nil, dispelName, timeMod)
						
						--> user added this buff to track in the buff tracking tab
						elseif (AUTO_TRACKING_EXTRA_BUFFS [name] or AUTO_TRACKING_EXTRA_BUFFS [spellId]) then
							local auraIconFrame, buffFrame = Plater.GetAuraIcon (self, true)
							Plater.AddAura (buffFrame, auraIconFrame, id, name, icon, applications, auraType, duration, expirationTime, sourceUnit, isFromPlayerOrPlayerPet, isStealable, nameplateShowPersonal, spellId, true, nil, nil, nil, dispelName, timeMod)
							
						end
					end

				elseif IS_WOW_PROJECT_MIDNIGHT then
					--if Plater.db.profile.debuff_hide_permanent and not C_UnitAuras.GetAuraDuration(unit, id) then
						-- no duration -> permanent -> hide. But cannot be done here, as aura duration will be returned. checking visible CD instead as workaround
					if DB_SHOW_PURGE_IN_EXTRA_ICONS and self.unitFrame.namePlateUnitReaction < 4 and self.unitFrame.ActorType == "enemynpc" and not C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, aura.auraInstanceID, "HELPFUL|RAID_PLAYER_DISPELLABLE") then
						Plater.AddExtraIcon (self, name, icon, applications, dispelName, duration, expirationTime, sourceUnit, isStealable, nameplateShowPersonal, spellId, true, "HELPFUL", id, timeMod)
					elseif Plater.db.profile.extra_icon_show_defensive and (self.unitFrame.ActorType == "enemyplayer" or self.unitFrame.ActorType == "friendlyplayer") and (not C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, aura.auraInstanceID, "HELPFUL|BIG_DEFENSIVE") or not C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, aura.auraInstanceID, "HELPFUL|EXTERNAL_DEFENSIVE")) then
						Plater.AddExtraIcon (self, name, icon, applications, dispelName, duration, expirationTime, sourceUnit, isStealable, nameplateShowPersonal, spellId, true, "HELPFUL", id, timeMod)
					elseif Plater.db.profile.aura_show_defensive_cd and (self.unitFrame.ActorType == "enemyplayer" or self.unitFrame.ActorType == "friendlyplayer") and (not C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, aura.auraInstanceID, "HELPFUL|BIG_DEFENSIVE") or not C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, aura.auraInstanceID, "HELPFUL|EXTERNAL_DEFENSIVE")) then
						local auraIconFrame, buffFrame = Plater.GetAuraIcon (self, true)
						Plater.AddAura (buffFrame, auraIconFrame, id, name, icon, applications, auraType, duration, expirationTime, sourceUnit, isFromPlayerOrPlayerPet, isStealable, nameplateShowPersonal, spellId, true, nil, nil, nil, dispelName, timeMod)
					elseif DB_AURA_SHOW_BUFFS_AS_BLIZZARD and blizzardBuffs[id] then
						local auraIconFrame, buffFrame = Plater.GetAuraIcon (self, true)
						Plater.AddAura (buffFrame, auraIconFrame, id, name, icon, applications, auraType, duration, expirationTime, sourceUnit, isFromPlayerOrPlayerPet, isStealable, nameplateShowPersonal, spellId, true, nil, nil, nil, dispelName, timeMod)
					elseif DB_AURA_SHOW_DISPELLABLE and self.unitFrame.namePlateUnitReaction < 4 and self.unitFrame.ActorType == "enemynpc" and not C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, aura.auraInstanceID, "HELPFUL|RAID_PLAYER_DISPELLABLE") then
						local auraIconFrame, buffFrame = Plater.GetAuraIcon (self, true)
						Plater.AddAura (buffFrame, auraIconFrame, id, name, icon, applications, auraType, duration, expirationTime, sourceUnit, isFromPlayerOrPlayerPet, isStealable, nameplateShowPersonal, spellId, true, nil, nil, nil, dispelName, timeMod)
					elseif DB_AURA_SHOW_RAID and (not C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, aura.auraInstanceID, "HELPFUL|PLAYER|RAID_IN_COMBAT") or not C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, aura.auraInstanceID, "HELPFUL|PLAYER|RAID")) then
						local auraIconFrame, buffFrame = Plater.GetAuraIcon (self, true)
						Plater.AddAura (buffFrame, auraIconFrame, id, name, icon, applications, auraType, duration, expirationTime, sourceUnit, isFromPlayerOrPlayerPet, isStealable, nameplateShowPersonal, spellId, true, nil, nil, nil, dispelName, timeMod)
					elseif DB_AURA_SHOW_BUFF_BYPLAYER and not C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, aura.auraInstanceID, "HELPFUL|PLAYER") then
						local auraIconFrame, buffFrame = Plater.GetAuraIcon (self, true)
						Plater.AddAura (buffFrame, auraIconFrame, id, name, icon, applications, auraType, duration, expirationTime, sourceUnit, isFromPlayerOrPlayerPet, isStealable, nameplateShowPersonal, spellId, true, nil, nil, nil, dispelName, timeMod)
					elseif DB_AURA_SHOW_BUFFENEMYNPC and self.unitFrame.namePlateUnitReaction < 4 and self.unitFrame.ActorType == "enemynpc" and not C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, aura.auraInstanceID, "HELPFUL") then
						local auraIconFrame, buffFrame = Plater.GetAuraIcon (self, true)
						Plater.AddAura (buffFrame, auraIconFrame, id, name, icon, applications, auraType, duration, expirationTime, sourceUnit, isFromPlayerOrPlayerPet, isStealable, nameplateShowPersonal, spellId, true, nil, nil, nil, dispelName, timeMod)
					end
				end
			end
		end
		
		--hide non used icons
		Plater.HideNonUsedAuraIcons (self)
			
		UnitAuraEventHandlerData[unit] = nil
		
		Plater.EndLogPerformanceCore("Plater-Core", "Update", "UpdateAuras_Automatic")
	end

	--used in scripts to get a specific buff from the unit, return full information
	--can be used with spellId or spellName
	function Plater.GetAura(unitId, spellName) --alias
		return Plater.GetBuff(unitId, spellName)
	end
	function Plater.GetBuff(unitId, spellName)
		if (type(spellName) == "number") then
			spellName = GetSpellInfo(spellName)
		end

		if (not spellName) then
			return
		end

		spellName =  spellName:lower()

		local continuationToken
		repeat
			local slots = { GetAuraSlots(unitId, "HELPFUL", BUFF_MAX_DISPLAY_PLATER, continuationToken) }
			continuationToken = slots[1]
			for i=2, #slots do
				local slot = slots[i];
				local name, icon, applications, dispelName, duration, expirationTime, sourceUnit, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossAura, isFromPlayerOrPlayerPet, nameplateShowAll, timeMod, applications = UnitAuraBySlot(unitId, slot)
				if (name) then
					if (name:lower()  == spellName) then
						return name, icon, applications, dispelName, duration, expirationTime, sourceUnit, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossAura, isFromPlayerOrPlayerPet, nameplateShowAll, timeMod, applications
					end
				end
			end
		until not continuationToken

		local continuationToken
		repeat
			local slots = { GetAuraSlots(unitId, "HARMFUL", BUFF_MAX_DISPLAY_PLATER, continuationToken) }
			continuationToken = slots[1]
			for i=2, #slots do
				local slot = slots[i];
				local name, icon, applications, dispelName, duration, expirationTime, sourceUnit, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossAura, isFromPlayerOrPlayerPet, nameplateShowAll, timeMod, applications = UnitAuraBySlot(unitId, slot)
				if (name) then
					if (name:lower()  == spellName) then
						return name, icon, applications, dispelName, duration, expirationTime, sourceUnit, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossAura, isFromPlayerOrPlayerPet, nameplateShowAll, timeMod, applications
					end
				end
			end
		until not continuationToken
	end

	function Plater.UpdateAuras_Self_Automatic (self, unit)
		if IS_WOW_PROJECT_MIDNIGHT_API_WITH_AURA_CONTAINERS then return end
		Plater.StartLogPerformanceCore("Plater-Core", "Update", "UpdateAuras_Self_Automatic")
		
		local unitAuraEventData = UnitAuraEventHandlerData[self.unit] or UnitAuraEventHandlerData["player"]
		
		if not unitAuraEventData then
			Plater.EndLogPerformanceCore("Plater-Core", "Update", "UpdateAuras_Self_Automatic")
			return
		end
		
		--DevTool:AddData({unitAuraEventData.hasBuff, unitAuraEventData.hasDebuff}, "UpdateAuras_Self_Automatic")
		
		Plater.ResetAuraContainer (self, unitAuraEventData.hasBuff, unitAuraEventData.hasDebuff)
		local unitAuraCache = self.unitFrame.AuraCache
		local noBuffDurationLimitation = Plater.db.profile.aura_show_all_duration_buffs_personal
		local onlyImportantBuffs = Plater.db.profile.aura_show_only_important_buffs_personal
		
		--> debuffs
		if (Plater.db.profile.aura_show_debuffs_personal and unitAuraEventData.hasDebuff) then
			local unitAuras = getUnitAuras(unit, "HARMFUL") or {}
			self.debuffsInOrder = unitAuras.debuffsInOrder or {}
			--DevTool:AddData(unitAuras)
			
			for id, aura in pairs(unitAuras.debuffs or {}) do
				--DevTool:AddData({i, aura})
				local name, icon, applications, dispelName, duration, expirationTime, sourceUnit, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossAura, isFromPlayerOrPlayerPet, nameplateShowAll, timeMod, applications = 
					aura.name, aura.icon, aura.applications, aura.dispelName, aura.duration, aura.expirationTime, aura.sourceUnit, aura.isStealable, aura.nameplateShowPersonal, aura.spellId, aura.canApplyAura, 
					aura.isBossAura, aura.isFromPlayerOrPlayerPet, aura.nameplateShowAll, aura.timeMod, aura.applications

				
				local auraType = "DEBUFF"
				
				if not IS_WOW_PROJECT_MIDNIGHT then
					unitAuraCache[name] = true
					unitAuraCache[spellId] = true
					unitAuraCache[name.."_"..(sourceUnit or "N/A")] = true
					unitAuraCache[spellId.."_"..(sourceUnit or "N/A")] = true
					unitAuraCache.canStealOrPurge = unitAuraCache.canStealOrPurge or isStealable
					unitAuraCache.hasEnrage = unitAuraCache.hasEnrage or dispelName == AURA_TYPE_ENRAGE
				end
					
				if not IS_WOW_PROJECT_MIDNIGHT and (not DB_DEBUFF_BANNED [name] and not DB_DEBUFF_BANNED [spellId]) then
					local auraIconFrame, buffFrame = Plater.GetAuraIcon (self)
					Plater.AddAura (buffFrame, auraIconFrame, id, name, icon, applications, auraType, duration, expirationTime, sourceUnit, isFromPlayerOrPlayerPet, isStealable, nameplateShowPersonal, spellId, false, false, true, true, dispelName, timeMod)
					
					--> check for special auras auto added by setting like 'show crowd control' or 'show dispellable'
					--> SPECIAL_AURAS_AUTO_ADDED has a list of crowd control not do not have a list of dispellable, so check if isStealable
					--> in addition, we want to check if enrage tracking is enabled and show enrage effects
					if (SPECIAL_AURAS_AUTO_ADDED [name] or SPECIAL_AURAS_AUTO_ADDED [spellId] or (DB_SHOW_PURGE_IN_EXTRA_ICONS and isStealable) or (DB_SHOW_ENRAGE_IN_EXTRA_ICONS and dispelName == AURA_TYPE_ENRAGE)) then
						Plater.AddExtraIcon (self, name, icon, applications, dispelName, duration, expirationTime, sourceUnit, isStealable, nameplateShowPersonal, spellId, false, "HARMFUL", id, timeMod)
					end
				elseif IS_WOW_PROJECT_MIDNIGHT then
					local auraIconFrame, buffFrame = Plater.GetAuraIcon (self)
					Plater.AddAura (buffFrame, auraIconFrame, id, name, icon, applications, auraType, duration, expirationTime, sourceUnit, isFromPlayerOrPlayerPet, isStealable, nameplateShowPersonal, spellId, false, false, true, true, dispelName, timeMod)
				end
				
				--> check for special auras added by the user it self
				if (((SPECIAL_AURAS_USER_LIST [name] or SPECIAL_AURAS_USER_LIST [spellId]) and not (SPECIAL_AURAS_USER_LIST_MINE [name] or SPECIAL_AURAS_USER_LIST_MINE [spellId])) or ((SPECIAL_AURAS_USER_LIST_MINE [name] or SPECIAL_AURAS_USER_LIST_MINE [spellId]) and aura.sourceIsPlayer)) then
					Plater.AddExtraIcon (self, name, icon, applications, dispelName, duration, expirationTime, sourceUnit, isStealable, nameplateShowPersonal, spellId, false, "HARMFUL", id, timeMod)
				end
				
			end
		end
		
		--> buffs
		if (Plater.db.profile.aura_show_buffs_personal and unitAuraEventData.hasBuff) then
			local unitAuras = getUnitAuras(unit, "HELPFUL|PLAYER") or {}
			self.buffsInOrder = unitAuras.buffsInOrder or {}
			--DevTool:AddData(unitAuras)
			
			for id, aura in pairs(unitAuras.buffs or {}) do
				--DevTool:AddData({i, aura})
				local name, icon, applications, dispelName, duration, expirationTime, sourceUnit, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossAura, isFromPlayerOrPlayerPet, nameplateShowAll, timeMod, applications = 
					aura.name, aura.icon, aura.applications, aura.dispelName, aura.duration, aura.expirationTime, aura.sourceUnit, aura.isStealable, aura.nameplateShowPersonal, aura.spellId, aura.canApplyAura, 
					aura.isBossAura, aura.isFromPlayerOrPlayerPet, aura.nameplateShowAll, aura.timeMod, aura.applications
					
				local auraType = "BUFF"

				if not IS_WOW_PROJECT_MIDNIGHT then
					unitAuraCache[name] = true
					unitAuraCache[spellId] = true
					unitAuraCache[name.."_"..(sourceUnit or "N/A")] = true
					unitAuraCache[spellId.."_"..(sourceUnit or "N/A")] = true
					unitAuraCache.canStealOrPurge = unitAuraCache.canStealOrPurge or isStealable
					unitAuraCache.hasEnrage = unitAuraCache.hasEnrage or dispelName == AURA_TYPE_ENRAGE
				end
				
				--> only show buffs casted by the player it self and less than 1 minute in duration
				if not IS_WOW_PROJECT_MIDNIGHT and ((not DB_BUFF_BANNED [name] and not DB_BUFF_BANNED [spellId]) and (noBuffDurationLimitation or (duration and (duration > 0 and duration < 60))) and (sourceUnit and UnitIsUnit (sourceUnit, "player") and ((onlyImportantBuffs and nameplateShowPersonal or (AUTO_TRACKING_EXTRA_BUFFS [name] or AUTO_TRACKING_EXTRA_BUFFS [spellId])) or not onlyImportantBuffs))) then
					local auraIconFrame, buffFrame = Plater.GetAuraIcon (self, true)
					Plater.AddAura (buffFrame, auraIconFrame, id, name, icon, applications, auraType, duration, expirationTime, sourceUnit, isFromPlayerOrPlayerPet, isStealable, nameplateShowPersonal, spellId, true, false, false, true, dispelName, timeMod)

				elseif IS_WOW_PROJECT_MIDNIGHT then
					local auraIconFrame, buffFrame = Plater.GetAuraIcon (self)
					Plater.AddAura (buffFrame, auraIconFrame, id, name, icon, applications, auraType, duration, expirationTime, sourceUnit, isFromPlayerOrPlayerPet, isStealable, nameplateShowPersonal, spellId, false, false, true, true, dispelName, timeMod)
				end
				
				--> there is no special auras for buffs in the personal bar
			end
		end	
		
		--> hide not used aura frames
		Plater.HideNonUsedAuraIcons (self)
		
		UnitAuraEventHandlerData[self.unit] = nil
		UnitAuraEventHandlerData["player"] = nil
		
		Plater.EndLogPerformanceCore("Plater-Core", "Update", "UpdateAuras_Self_Automatic")
    end
    


    --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> aura ~test - when the options panel is opened at the buff settings

	function Plater.CreateAuraTesting()

		local auraOptionsFrame = _G.PlaterOptionsPanelContainer.AllFrames[9]

		auraOptionsFrame.OnUpdateFunc = function (self, deltaTime)
			
			auraOptionsFrame.NextTime = auraOptionsFrame.NextTime - deltaTime
			DB_AURA_ENABLED = false
			Plater.DisableAuraTrackingForAuraTest()
			
			if (auraOptionsFrame.NextTime <= 0) then
				auraOptionsFrame.NextTime = 0.016
				
				for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
					if plateFrame.unitFrame.PlaterOnScreen then

						local buffFrame = plateFrame.unitFrame.BuffFrame
						local buffFrame2 = plateFrame.unitFrame.BuffFrame2
						local unitAuraCache = plateFrame.unitFrame.AuraCache
						
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
									Plater.AddAura (buffFrame, auraIconFrame, index, auraTable.SpellName, auraTable.SpellTexture, auraTable.Count, "DEBUFF", auraTable.Duration, auraTable.ApplyTime+auraTable.Duration, "player", true, false, false, auraTable.SpellID, nil, nil, nil, nil, auraTable.Type, 1)
								else
									Plater.AddAura (buffFrame, auraIconFrame, index, auraTable.SpellName, auraTable.SpellTexture, auraTable.Count, "DEBUFF", auraTable.Duration, auraTable.ApplyTime+auraTable.Duration, "player", true, false, false, auraTable.SpellID, false, false, true, true, auraTable.Type, 1)
								end
								
								unitAuraCache[auraTable.SpellName] = true
								unitAuraCache[auraTable.SpellID] = true
								unitAuraCache[auraTable.SpellName.."_player"] = true
								unitAuraCache[auraTable.SpellID.."_player"] = true
								
								Plater.UpdateIconAspecRatio (auraIconFrame)
							end
							
							for index, auraTable in ipairs (auraOptionsFrame.AuraTesting.BUFF) do
								local auraIconFrame = Plater.GetAuraIcon (buffFrame)
								if (not auraTable.ApplyTime or auraTable.ApplyTime+auraTable.Duration < GetTime()) then
									auraTable.ApplyTime = GetTime() + math.random (3, 12)
								end
								
								if (not UnitIsUnit (plateFrame.unitFrame [MEMBER_UNITID], "player")) then
									Plater.AddAura (buffFrame, auraIconFrame, index, auraTable.SpellName, auraTable.SpellTexture, auraTable.Count, "DEBUFF", auraTable.Duration, auraTable.ApplyTime+auraTable.Duration, "player", true, true, false, auraTable.SpellID, true, nil, nil, nil, auraTable.Type, 1)
								else
									Plater.AddAura (buffFrame, auraIconFrame, index, auraTable.SpellName, auraTable.SpellTexture, auraTable.Count, "DEBUFF", auraTable.Duration, auraTable.ApplyTime+auraTable.Duration, "player", true, true, false, auraTable.SpellID, false, false, false, true, auraTable.Type, 1)
								end
								
								unitAuraCache[auraTable.SpellName] = true
								unitAuraCache[auraTable.SpellID] = true
								unitAuraCache[auraTable.SpellName.."_player"] = true
								unitAuraCache[auraTable.SpellID.."_player"] = true
								
								Plater.UpdateIconAspecRatio (auraIconFrame)
							end
							
							--hide icons on the second buff frame
							for i = 1, #buffFrame2.PlaterBuffList do
								local icon = buffFrame2.PlaterBuffList [i]
								if (icon) then
									icon.ShowAnimation:Stop()
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
									Plater.AddAura (buffFrame, auraIconFrame, index, auraTable.SpellName, auraTable.SpellTexture, auraTable.Count, "DEBUFF", auraTable.Duration, auraTable.ApplyTime+auraTable.Duration, "player", true, false, false, auraTable.SpellID, nil, nil, nil, nil, auraTable.Type, 1)
								else
									Plater.AddAura (buffFrame, auraIconFrame, index, auraTable.SpellName, auraTable.SpellTexture, auraTable.Count, "DEBUFF", auraTable.Duration, auraTable.ApplyTime+auraTable.Duration, "player", true, false, false, auraTable.SpellID, false, false, true, true, auraTable.Type, 1)
								end
								
								unitAuraCache[auraTable.SpellName] = true
								unitAuraCache[auraTable.SpellID] = true
								unitAuraCache[auraTable.SpellName.."_player"] = true
								unitAuraCache[auraTable.SpellID.."_player"] = true
								unitAuraCache.hasEnrage = unitAuraCache.hasEnrage or auraTable.Type == AURA_TYPE_ENRAGE
							end
							
							for index, auraTable in ipairs (auraOptionsFrame.AuraTesting.BUFF) do
								local auraIconFrame, frame = Plater.GetAuraIcon (buffFrame, true)
								if (not auraTable.ApplyTime or auraTable.ApplyTime+auraTable.Duration < GetTime()) then
									auraTable.ApplyTime = GetTime() + math.random (3, 12)
								end
								
								if (not UnitIsUnit (plateFrame.unitFrame [MEMBER_UNITID], "player")) then
									Plater.AddAura (frame, auraIconFrame, index, auraTable.SpellName, auraTable.SpellTexture, auraTable.Count, "BUFF", auraTable.Duration, auraTable.ApplyTime+auraTable.Duration, "player", true, true, false, auraTable.SpellID, true, nil, nil, nil, auraTable.Type, 1)
								else
									Plater.AddAura (frame, auraIconFrame, index, auraTable.SpellName, auraTable.SpellTexture, auraTable.Count, "BUFF", auraTable.Duration, auraTable.ApplyTime+auraTable.Duration, "player", true, true, false, auraTable.SpellID, true, false, false, false, auraTable.Type, 1)
								end
								
								unitAuraCache[auraTable.SpellName] = true
								unitAuraCache[auraTable.SpellID] = true
								unitAuraCache[auraTable.SpellName.."_player"] = true
								unitAuraCache[auraTable.SpellID.."_player"] = true
								unitAuraCache.hasEnrage = unitAuraCache.hasEnrage or auraTable.Type == AURA_TYPE_ENRAGE
							end
						end
						
						Plater.HideNonUsedAuraIcons (buffFrame)
						platerInternal.AlignAuraFrames (buffFrame)
						
						if (DB_AURA_SEPARATE_BUFFS) then
							platerInternal.AlignAuraFrames (buffFrame.BuffFrame2)
						end
					end
				end
			end
		end

		auraOptionsFrame.EnableAuraTest = function()
			if IS_WOW_PROJECT_MIDNIGHT_API_WITH_AURA_CONTAINERS then
				C_UnitAuras.SwitchAuraDataProvider()
				return
			end
			DB_AURA_ENABLED = false
			Plater.DisableAuraTrackingForAuraTest()
			Plater.RefreshAuras()
			auraOptionsFrame.NextTime = 0.2
			auraOptionsFrame:SetScript ("OnUpdate", auraOptionsFrame.OnUpdateFunc)
		end
		auraOptionsFrame.DisableAuraTest = function()
			if IS_WOW_PROJECT_MIDNIGHT_API_WITH_AURA_CONTAINERS then
				C_UnitAuras.ResetAuraDataProvider()
				return
			end
			Plater.RefreshDBUpvalues()
			Plater.RefreshAuras()
			auraOptionsFrame:SetScript ("OnUpdate", nil)
		end

		auraOptionsFrame:SetScript ("OnShow", function()
			--Plater.DisableAuraTest = not Plater.db.profile.aura_enabled
			if (not Plater.DisableAuraTest) then
				auraOptionsFrame.EnableAuraTest()
			end
		end)

		auraOptionsFrame:SetScript ("OnHide", function()
			auraOptionsFrame.DisableAuraTest()
		end)
	end


    -------------------------------------------------------------------------------------------------------------------
    --> aura caches -- ~db
    
    function Plater.RefreshAuraDBUpvalues()
        local profile = Plater.db.profile

		DB_SHOW_PURGE_IN_EXTRA_ICONS = profile.extra_icon_show_purge
		DB_SHOW_ENRAGE_IN_EXTRA_ICONS = profile.extra_icon_show_enrage
		DB_SHOW_MAGIC_IN_EXTRA_ICONS = profile.extra_icon_show_magic

		--list of auras the user added into the track list for special auras
		wipe (SPECIAL_AURAS_USER_LIST)
		wipe (SPECIAL_AURAS_USER_LIST_MINE)
		
		--list of auras Plater added automatically to special auras
        wipe (SPECIAL_AURAS_AUTO_ADDED)

		--cached spells for the border in the special auras
		wipe (CROWDCONTROL_AURA_IDS)
		wipe (OFFENSIVE_AURA_IDS)
		wipe (DEFENSIVE_AURA_IDS)

		--build the crowd control list
		if (profile.debuff_show_cc) then
			local ccList = LIB_OPEN_RAID_CROWDCONTROL
			if (ccList) then
				for spellId, _ in pairs (ccList) do
					local spellName = GetSpellInfo (spellId)
					if (spellName) then
						if not IS_WOW_PROJECT_MIDNIGHT_API_WITH_AURA_CONTAINERS then
							SPECIAL_AURAS_AUTO_ADDED [spellId] = true
						end
						CROWDCONTROL_AURA_IDS [spellId] = true
					end
				end
			else
				for spellId, _ in pairs (DF.CrowdControlSpells) do
					local spellName = GetSpellInfo (spellId)
					if (spellName) then
						if not IS_WOW_PROJECT_MIDNIGHT_API_WITH_AURA_CONTAINERS then
							SPECIAL_AURAS_AUTO_ADDED [spellId] = true
						end
						CROWDCONTROL_AURA_IDS [spellId] = true
					end
				end
			end
        end
        
		--build the offensive cd list
		if (profile.extra_icon_show_offensive) then
			--pull from the openraid library
			local cooldownList = LIB_OPEN_RAID_COOLDOWNS_INFO
			if (cooldownList) then
				for spellId, cooldownInfo in pairs(cooldownList) do
					if (cooldownInfo.type == 1) then --offense cooldown
						if not IS_WOW_PROJECT_MIDNIGHT_API_WITH_AURA_CONTAINERS then
							SPECIAL_AURAS_AUTO_ADDED[spellId] = true
						end
						OFFENSIVE_AURA_IDS[spellId] = true
					end
				end
			else
				for spellId, _ in pairs (DF.CooldownsAttack) do
					local spellName = GetSpellInfo (spellId)
					if (spellName) then
						if not IS_WOW_PROJECT_MIDNIGHT_API_WITH_AURA_CONTAINERS then
							SPECIAL_AURAS_AUTO_ADDED [spellId] = true
						end
						OFFENSIVE_AURA_IDS [spellId] = true
					end
				end
			end
        end
        
		--build the defensive cd list
		if (profile.extra_icon_show_defensive) then
			--pull from the openraid library
			local cooldownList = LIB_OPEN_RAID_COOLDOWNS_INFO
			if (cooldownList) then
				for spellId, cooldownInfo in pairs(cooldownList) do
					if (cooldownInfo.type == 2 or cooldownInfo.type == 3 or cooldownInfo.type == 4) then --personal, targeted or raidwide defense cooldown
						if not IS_WOW_PROJECT_MIDNIGHT_API_WITH_AURA_CONTAINERS then
							SPECIAL_AURAS_AUTO_ADDED[spellId] = true
						end
						DEFENSIVE_AURA_IDS[spellId] = true
					end
				end
			else
				for spellId, _ in pairs (DF.CooldownsAllDeffensive) do
					local spellName = GetSpellInfo (spellId)
					if (spellName) then
						if not IS_WOW_PROJECT_MIDNIGHT_API_WITH_AURA_CONTAINERS then
							SPECIAL_AURAS_AUTO_ADDED [spellId] = true
						end
						DEFENSIVE_AURA_IDS [spellId] = true
					end
				end
			end
        end
        
		--> add auras added by the player into the special aura container
		for index, spellId in ipairs (profile.extra_icon_auras) do
			local spellName = GetSpellInfo (spellId)
			if (spellName) or type(spellId) == "string" then -- either valid ID or name
				SPECIAL_AURAS_USER_LIST [spellId] = true
			end
        end
        
		for spellId, state in pairs (profile.extra_icon_auras_mine) do
			if (state) then
				local spellName = GetSpellInfo (spellId)
				if (spellName) or type(spellId) == "string" then -- either valid ID or name
					--> mine list only store if the user checked the 'only mine' box
					--> if the user remove the spell, that spell isn't removed from the 'only mine' list
					--> so need to check if the spell on 'only mine' list is included in the special aura list
					if (SPECIAL_AURAS_USER_LIST [spellId]) then
						--SPECIAL_AURAS_USER_LIST [spellId] = nil --TODO is thi safe?
						SPECIAL_AURAS_USER_LIST_MINE [spellId] = true
					end
				end
			end
		end
    end

	--isProfileUnchanged: the profile is the same as on the last refresh, the aura button skins are still valid
	function Plater.RefreshAuraCache(isProfileUnchanged)
		Plater.StartLogPerformanceCore("Plater-Core", "Update", "RefreshAuraCache")

		local profile = Plater.db.profile

		DB_AURA_ENABLED = profile.aura_enabled
		DB_AURA_ALPHA = profile.aura_alpha

		DB_AURA_SEPARATE_BUFFS = Plater.db.profile.buffs_on_aura2

		DB_AURA_SHOW_IMPORTANT = profile.aura_show_important
		DB_AURA_SHOW_DISPELLABLE = profile.aura_show_dispellable
		DB_AURA_SHOW_RAID = profile.aura_show_raid
		DB_AURA_SHOW_ONLY_SHORT_DISPELLABLE_ON_PLAYERS = profile.aura_show_only_short_dispellable_on_players
		DB_AURA_SHOW_ENRAGE = profile.aura_show_enrage
		DB_AURA_SHOW_MAGIC = profile.aura_show_magic
		DB_AURA_SHOW_BYPLAYER = profile.aura_show_aura_by_the_player
		DB_AURA_SHOW_DEBUFF_BYPLAYER = profile.aura_show_debuff_by_the_player
		DB_AURA_SHOW_AS_BLIZZARD = profile.aura_show_debuff_as_blizzard_does
		DB_AURA_SHOW_BUFFS_AS_BLIZZARD = profile.aura_show_buff_as_blizzard_does
		DB_AURA_SHOW_BUFF_BYPLAYER = profile.aura_show_buff_by_the_player
		DB_AURA_SHOW_BYOTHERPLAYERS = profile.aura_show_aura_by_other_players
		DB_AURA_SHOW_BYOTHERNPCS = profile.aura_show_aura_by_other_npcs
		DB_AURA_SHOW_BUFFBYUNIT = profile.aura_show_buff_by_the_unit
		DB_AURA_SHOW_BUFFENEMYNPC = profile.aura_show_buff_on_enemy_npc
		DB_AURA_SHOW_DEBUFFBYUNIT = profile.aura_show_debuff_by_the_unit
		DB_AURA_PADDING = profile.aura_padding

		DB_AURA_GROW_DIRECTION = profile.aura_grow_direction
		DB_AURA_GROW_DIRECTION2 = profile.aura2_grow_direction

		DB_AURA_GHOSTAURA_ENABLED = profile.ghost_auras.enabled
		
		DB_TRACK_METHOD = profile.aura_tracker.track_method

		DB_AURA_NAME_CACHE = profile.aura_tracker.spell_name_cache

		Plater.MaxAurasPerRow = floor(profile.plate_config.enemynpc.health_incombat[1] / (profile.aura_width + DB_AURA_PADDING))
		Plater.Auras.SetContainerFiltersOutdated()
		if (not isProfileUnchanged) then
			Plater.Auras.SetIconConfigOutdated()
		end

		Plater.EndLogPerformanceCore("Plater-Core", "Update", "RefreshAuraCache")
    end

	local function re_UpdateGhostAurasCache()
		Plater.UpdateGhostAurasCache()
	end
	
	function Plater.UpdateGhostAurasCache()
		wipe(GHOSTAURAS)
		local ghostAuraList = Plater.Auras.GhostAuras.GetAuraListForCurrentSpec()
		if (not ghostAuraList) then
			--something in the pipeline is triggering before being ready
			C_Timer.After(1, re_UpdateGhostAurasCache)
			return
		end

		for spellId in pairs(ghostAuraList) do
			local spellName, _, spellIcon = GetSpellInfo(spellId)
			if (spellName) then
				GHOSTAURAS[spellName] = {spellIcon, spellId}
			end
		end
	end

    function Plater.UpdateAuraCache()
		local profile = Plater.db.profile
		--manual tracking has an indexed table to store what to track
		--the extra auras for automatic tracking has a hash table with spellIds

		--> manual aura tracking
			local manualBuffsToTrack = profile.aura_tracker.buff
			local manualDebuffsToTrack = profile.aura_tracker.debuff

			wipe(MANUAL_TRACKING_DEBUFFS)
			wipe(MANUAL_TRACKING_BUFFS)

			for i = 1, #manualDebuffsToTrack do
				local spellIDNum = tonumber(manualDebuffsToTrack [i])
				local spellName = GetSpellInfo (spellIDNum or manualDebuffsToTrack [i])
				if (spellName) then
					MANUAL_TRACKING_DEBUFFS [spellName] = true
				else
					--add the entry in case there's a spell name instead of a spellId in the list (for back compatibility)
					MANUAL_TRACKING_DEBUFFS [manualDebuffsToTrack [i]] = true
				end
			end

			for i = 1, #manualBuffsToTrack do
				local spellIDNum = tonumber(manualBuffsToTrack [i])
				local spellName = GetSpellInfo (spellIDNum or manualBuffsToTrack [i])
				if (spellName) then
					MANUAL_TRACKING_BUFFS [spellName] = true
				else
					--add the entry in case there's a spell name instead of a spellId in the list (for back compatibility)
					MANUAL_TRACKING_BUFFS [manualBuffsToTrack [i]]= true
				end
			end

		--> extra auras to track on automatic aura tracking
			local extraBuffsToTrack = profile.aura_tracker.buff_tracked
			local extraDebuffsToTrack = profile.aura_tracker.debuff_tracked

			wipe(AUTO_TRACKING_EXTRA_BUFFS)
			wipe(AUTO_TRACKING_EXTRA_DEBUFFS)

			for spellId, flag in pairs (extraBuffsToTrack) do
				spellId = tonumber(spellId) or spellId --ensure either actual number or name of the spell
				local spellName = GetSpellInfo (spellId)
				if (spellName) then
					if flag then
						AUTO_TRACKING_EXTRA_BUFFS [spellName] = true
					else
						AUTO_TRACKING_EXTRA_BUFFS [spellId] = true
					end
				end
			end

			for spellId, flag in pairs (extraDebuffsToTrack) do
				spellId = tonumber(spellId) or spellId --ensure either actual number or name of the spell
				local spellName = GetSpellInfo (spellId)
				if (spellName) then
					if flag then
						AUTO_TRACKING_EXTRA_DEBUFFS [spellName] = true
					else
						AUTO_TRACKING_EXTRA_DEBUFFS [spellId] = true
					end
				end
			end

			if (profile.aura_show_crowdcontrol and DF.CrowdControlSpells) then
				for spellId, _ in pairs (DF.CrowdControlSpells) do
					local spellName = GetSpellInfo (spellId)
					if (spellName) then
						--AUTO_TRACKING_EXTRA_DEBUFFS [spellName] = true
						if not IS_WOW_PROJECT_MIDNIGHT_API_WITH_AURA_CONTAINERS then
							AUTO_TRACKING_EXTRA_DEBUFFS [spellId] = true
						end
						CROWDCONTROL_AURA_IDS [spellId] = true
					end
				end
			end

			if (profile.aura_show_offensive_cd and DF.CooldownsAttack) then
				for spellId, _ in pairs (DF.CooldownsAttack) do
					local spellName = GetSpellInfo (spellId)
					if (spellName) then
						--AUTO_TRACKING_EXTRA_BUFFS [spellName] = true
						if not IS_WOW_PROJECT_MIDNIGHT_API_WITH_AURA_CONTAINERS then
							AUTO_TRACKING_EXTRA_BUFFS [spellId] = true
						end
						OFFENSIVE_AURA_IDS [spellId] = true
					end
				end
			end

			if (profile.aura_show_defensive_cd and DF.CooldownsAllDeffensive) then
				for spellId, _ in pairs (DF.CooldownsAllDeffensive) do
					local spellName = GetSpellInfo (spellId)
					if (spellName) then
						--AUTO_TRACKING_EXTRA_BUFFS [spellName] = true
						if not IS_WOW_PROJECT_MIDNIGHT_API_WITH_AURA_CONTAINERS then
							AUTO_TRACKING_EXTRA_BUFFS [spellId] = true
						end
						DEFENSIVE_AURA_IDS [spellId] = true
					end
				end
			end

			--> load spells filtered out, use the spellname instead of the spellId
			if (not DB_BUFF_BANNED) then
				DB_BUFF_BANNED = {}
				DB_DEBUFF_BANNED = {}
			else
				wipe(DB_BUFF_BANNED)
				wipe(DB_DEBUFF_BANNED)
			end

			for spellId, state in pairs (profile.aura_tracker.buff_banned) do
				spellId = tonumber(spellId) or spellId --ensure either actual number or name of the spell
				local spellName = GetSpellInfo (spellId)
				if (spellName) then
					if state then
						DB_BUFF_BANNED [spellName] = true
					else
						DB_BUFF_BANNED [spellId] = true
					end
				end
			end

			for spellId, state in pairs (profile.aura_tracker.debuff_banned) do
				spellId = tonumber(spellId) or spellId --ensure either actual number or name of the spell
				local spellName = GetSpellInfo (spellId)
				if (spellName) then
					if state then
						DB_DEBUFF_BANNED [spellName] = true
					else
						DB_DEBUFF_BANNED [spellId] = true
					end
				end
			end

		--> per aura healthbar colors, only the spell names: expandAuraCaches() resolves them into spell ids
			wipe (AURA_COLORS)
			for spellId, colorTable in pairs (profile.aura_colors) do
				if (colorTable [1]) then
					--a string key is a spell name, a number key tracked by name uses its spell name
					if (type (spellId) == "string") then
						AURA_COLORS [spellId] = true

					elseif (colorTable [3]) then
						local spellName = GetSpellInfo (spellId)
						if (spellName) then
							AURA_COLORS [spellName] = true
						end
					end
				end
			end

		--> ghost aura cache
		Plater.UpdateGhostAurasCache()
		if IS_WOW_PROJECT_MIDNIGHT_API_WITH_AURA_CONTAINERS then
			expandAuraCaches()
		end
	end
