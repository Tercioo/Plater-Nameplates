
local Plater = _G.Plater
local DF = _G.DetailsFramework
local addonName, platerInternal = ...
local _ = nil

local IS_WOW_PROJECT_MAINLINE = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
local IS_WOW_PROJECT_NOT_MAINLINE = WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE
local IS_WOW_PROJECT_CLASSIC_ERA = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC

--preparation for 10.0
local IS_NEW_UNIT_AURA_AVAILABLE = C_UnitAuras and C_UnitAuras.GetAuraDataBySlot and true

--stop yellow lines on my editor
local tinsert = _G.tinsert
local min = _G.min
local max = _G.max
local abs = _G.abs
local CreateFrame = _G.CreateFrame
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
local UnitAura = _G.UnitAura or (C_UnitAuras and (function(...) local auraData = C_UnitAuras.GetAuraDataByIndex(unitToken, index, filter); if not auraData then return nil; end; return AuraUtil.UnpackAuraData(auraData); end))
local GetAuraDataBySlot = _G.C_UnitAuras and _G.C_UnitAuras.GetAuraDataBySlot
local GetAuraSlots = _G.C_UnitAuras and _G.C_UnitAuras.GetAuraSlots
local GetAuraDataByAuraInstanceID = _G.C_UnitAuras and _G.C_UnitAuras.GetAuraDataByAuraInstanceID
local BackdropTemplateMixin = _G.BackdropTemplateMixin
local BUFF_MAX_DISPLAY = _G.BUFF_MAX_DISPLAY
local BUFF_MAX_DISPLAY_PLATER = (not IS_NEW_UNIT_AURA_AVAILABLE and _G.BUFF_MAX_DISPLAY) or (IS_NEW_UNIT_AURA_AVAILABLE and nil) -- why limit it in this case?

local DB_AURA_GROW_DIRECTION
local DB_AURA_GROW_DIRECTION2
local DB_AURA_PADDING
local DB_AURA_SEPARATE_BUFFS
local DB_SHOW_PURGE_IN_EXTRA_ICONS
local DB_SHOW_ENRAGE_IN_EXTRA_ICONS
local DB_SHOW_MAGIC_IN_EXTRA_ICONS
local DB_DEBUFF_BANNED
local DB_AURA_SHOW_IMPORTANT
local DB_AURA_SHOW_BYPLAYER
local DB_AURA_SHOW_BYOTHERPLAYERS
local DB_BUFF_BANNED
local DB_AURA_SHOW_DISPELLABLE
local DB_AURA_SHOW_ONLY_SHORT_DISPELLABLE_ON_PLAYERS
local DB_AURA_SHOW_ENRAGE
local DB_AURA_SHOW_MAGIC
local DB_AURA_SHOW_BYUNIT
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
			else
				--I guess the aura will get cleaned by regular Plater.ResetAuraContainer()
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

-- support for LibClassicDurations from https://github.com/rgd87/LibClassicDurations by d87
local LCD = LibStub:GetLibrary("LibClassicDurations", true)
if IS_WOW_PROJECT_CLASSIC_ERA and LCD then
	LCD:Register(Plater)
	LCD.RegisterCallback(Plater, "UNIT_BUFF", function(event, unit)end)
	UnitAura = LCD.UnitAuraWithBuffs
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
	
	--This is a fallback to save tooltips in classic... can't have nice things.
	--IS_NEW_UNIT_AURA_AVAILABLE = tooltip.SetUnitBuffByAuraInstanceID and true or false --disable this for now. might work.
	
	return tooltip
end

local NamePlateTooltip = _G.NamePlateTooltip -- can be removed later
local PlaterNamePlateAuraTooltip = CreatePlaterNamePlateAuraTooltip()

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> Private Aura handling

function Plater.HandlePrivateAuraAnchors(unitFrame, maxIndex)
	if true then return end -- disable for now...
	if not unitFrame then return end
	if not C_UnitAuras or not C_UnitAuras.RemovePrivateAuraAnchor then return end

	if unitFrame.privateAuraAnchors then
		for index, anchorID in pairs(unitFrame.privateAuraAnchors) do
			C_UnitAuras.RemovePrivateAuraAnchor(anchorID)
		end
		table.wipe(unitFrame.privateAuraAnchors)
	else
		unitFrame.privateAuraAnchors = {}
	end
	
	if not unitFrame.PlaterOnScreen then return end
	
	--anchor building
	local anchorSide = Plater.db.profile.aura_frame1_anchor.side
	local rowGrowthDirectionUp = (anchorSide < 3 or anchorSide > 5)
	local maxIndex = maxIndex or 2
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
	
	for index = 1, maxIndex do
		local privateAnchorArgs = {
			unitToken = unit,
			auraIndex = index,
			parent = unitFrame,
			showCountdownFrame = true,
			showCountdownNumbers = true,
			iconInfo = {
				iconAnchor = {
					point = relIconPoint,
					relativeTo = unitFrame.BuffFrame,
					relativePoint = relIconPointTo,
					offsetX = ((Plater.db.profile.aura_width * (index - 1)) + DB_AURA_PADDING * (index -1)) * paddingMult, --((Plater.db.profile.aura_width * Plater.db.profile.ui_parent_scale_tune * (index - 1)) + DB_AURA_PADDING * (index -1)) * paddingMult,
					offsetY = Plater.db.profile.aura_breakline_space,
				},
				iconWidth = Plater.db.profile.aura_width, -- * Plater.db.profile.ui_parent_scale_tune,
				iconHeight = Plater.db.profile.aura_height, -- * Plater.db.profile.ui_parent_scale_tune,
			},
			durationAnchor = {
				point = relIconPoint,
				relativeTo = unitFrame.BuffFrame,
				relativePoint = relIconPointTo,
				offsetX = ((Plater.db.profile.aura_width * (index - 1)) + DB_AURA_PADDING * (index -1)) * paddingMult, --((Plater.db.profile.aura_width * Plater.db.profile.ui_parent_scale_tune * (index - 1)) + DB_AURA_PADDING * (index -1)) * paddingMult,
				offsetY = Plater.db.profile.aura_breakline_space,
			},
		}
		
		unitFrame.privateAuraAnchors[index] = C_UnitAuras.AddPrivateAuraAnchor(privateAnchorArgs)
	end
	--anchored, so we should 'show' the buffframe as anchor point. TODO: how to handle this for name only and other stuff?... might need separate anchor frame
	unitFrame.BuffFrame:Show()
	unitFrame.BuffFrame:SetSize(1,1)
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> UNIT_AURA event handling

local ValidateAuraForUpdate = function (unit, aura)
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
				or (aura.sourceUnit == "player" and ( MANUAL_TRACKING_BUFFS[name] or MANUAL_TRACKING_BUFFS[spellId] or MANUAL_TRACKING_DEBUFFS[name] or MANUAL_TRACKING_DEBUFFS[spellId] ))
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

local UnitAuraEventHandlerValidation = function (unit, isFullUpdate, updatedAuras)
	--DevTool:AddData({unit = unit, isFullUpdate = isFullUpdate, updatedAuras = updatedAuras}, "Plater_UNIT_AURA")
	if isFullUpdate ~= false or not updatedAuras then
		return true, true, true --update all
	end
	
	local needsUpdate = false
	local hasBuff = false
	local hasDebuff = false
	
	for _, aura in pairs(updatedAuras) do
		local nU, hB, hD = ValidateAuraForUpdate(unit, aura)
		needsUpdate = needsUpdate or nU
		hasBuff = hasBuff or hB
		hasDebuff = hasDebuff or hD
	end
	
	--resets buffs and debuffs if not using aura frame 2 (for now, until partial clear is implemented)
	hasBuff = not DB_AURA_SEPARATE_BUFFS and (hasBuff or hasDebuff) or hasBuff 
	hasDebuff = not DB_AURA_SEPARATE_BUFFS and (hasBuff or hasDebuff) or hasDebuff
	
	--DevTool:AddData({unit = unit, needsUpdate=needsUpdate, hasBuff=hasBuff, hasDebuff=hasDebuff}, "Plater_UNIT_AURA return")
	return needsUpdate, hasBuff, hasDebuff
end

--[[
UNIT_AURA Payload:
	- unit					-- the unit the aura update is applied to
	- isFullUpdate			-- if there needs to be a full aura update (potentially empty updatedAuras)
	- updatedAuras {		-- the table of updated aura information for this unit/event
		[n] {
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
		}

In 10.0:
	- unit
	- UnitAuraUpdateInfo = {
			addedAuras = AuraInstanceInfo[]?,
			updatedAuraInstanceIDs = number[]?
			removedAuraInstanceIDs = number[]?
			isFullUpdate = boolean?,
		}

with AuraInstanceInfo = {	
		--FULL UnitAura return values plus:
		auraInstanceID = number,
		-- "Magic" | "Curse" | "Disease" | "Poison"
		dispelName = string,  
	}
]]--
local UnitAuraEventHandlerData = {}
local UnitAuraEventHandlerValidUnits = {} -- units on screen. set via Plater.RemoveFromAuraUpdate and Plater.AddToAuraUpdate from NAME_PLATE_UNIT_REMOVED and NAME_PLATE_UNIT_ADDED events
local UnitAuraCacheData = {} --new unit aura event info data cache
local UpdateUnitAuraCacheData
local UnitAuraEventHandlerFrame = CreateFrame ("frame") --private
local UnitAuraEventHandler = function (_, event, arg1, arg2, arg3, ...)
	Plater.StartLogPerformanceCore("Plater-Core", "Events", event)
	--DevTool:AddData({event = event, arg1 = arg1, arg2 = arg2}, "Plater_UnitAuraEventHandler - " .. (event or "N/A"))
	if event == "UNIT_AURA" then
		if IS_NEW_UNIT_AURA_AVAILABLE then --for 10.0
			local unit, updatedAuras = arg1, arg2
			--DevTool:AddData({unit = unit, updatedAuras = updatedAuras, valid = UnitAuraEventHandlerValidUnits[unit]}, "Plater_UNIT_AURA - " .. unit)
			if unit and UnitAuraEventHandlerValidUnits[unit] then
				UpdateUnitAuraCacheData(unit, updatedAuras)
			end
			
		else --old code
			local unit, isFullUpdate, updatedAuras = arg1, arg2, arg3
			if unit and UnitAuraEventHandlerValidUnits[unit] then
				local needsUpdate, hasBuff, hasDebuff = UnitAuraEventHandlerValidation(unit, isFullUpdate, updatedAuras)
				--DevTool:AddData({unit = unit, isFullUpdate = isFullUpdate, updatedAuras = updatedAuras, needsUpdate = needsUpdate, hasBuff = hasBuff, hasDebuff = hasDebuff, existing=CopyTable(UnitAuraEventHandlerData[unit] or {})}, "Plater_UNIT_AURA_AFTER")
				if needsUpdate then
					local existingData = UnitAuraEventHandlerData[unit] or { hasBuff = false, hasDebuff = false }
					UpdateUnitAuraCacheData(unit, nil)
					UnitAuraEventHandlerData[unit] = { hasBuff = existingData.hasBuff or hasBuff or false, hasDebuff = existingData.hasDebuff or hasDebuff or false }
				end
			end
		end
	end
	
	Plater.EndLogPerformanceCore("Plater-Core", "Events", event)
end
UnitAuraEventHandlerFrame:SetScript ("OnEvent", UnitAuraEventHandler)
UnitAuraEventHandlerFrame:RegisterEvent ("UNIT_AURA")

function Plater.RemoveFromAuraUpdate (unit)
	if not unit then return end
	UnitAuraEventHandlerValidUnits[unit] = nil
	UnitAuraCacheData[unit] = nil
	UnitAuraEventHandlerData[unit] = nil
end

function Plater.AddToAuraUpdate (unit)
	if not unit then return end
	UnitAuraEventHandlerValidUnits[unit] = true
	UnitAuraEventHandlerData[unit] = { hasBuff = true, hasDebuff = true } --update at least once
	UpdateUnitAuraCacheData(unit, nil)
end


UpdateUnitAuraCacheData = function (unit, updatedAuras)
	--DevTool:AddData({unit = unit, updatedAuras = updatedAuras}, "Plater_UpdateUnitAuraCacheData - " .. (unit or "N/A"))
	local unitCacheData = UnitAuraCacheData[unit]
	if not unitCacheData then
		unitCacheData = {}
		unitCacheData.buffs = {}
		unitCacheData.debuffs = {}
		UnitAuraCacheData[unit] = unitCacheData
	end
	
	if updatedAuras == nil or updatedAuras.isFullUpdate then
		UnitAuraCacheData[unit] = {}
		UnitAuraCacheData[unit].buffs = {}
		UnitAuraCacheData[unit].debuffs = {}
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
			unitCacheData.debuffs[auraInstanceID].requriresUpdate = true
			unitCacheData.debuffsChanged = true
		elseif unitCacheData.buffs[auraInstanceID] ~= nil then
			unitCacheData.buffs[auraInstanceID].requriresUpdate = true
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
			local aura = C_UnitAuras.GetAuraDataByAuraInstanceID(unit, index)
			if aura then
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
	
	local unitCacheData = UnitAuraCacheData[unit]
	--DevTool:AddData({unitCacheData, filter = filter, isFullUpdateHarm = unitCacheData.isFullUpdateHarm, isFullUpdateHelp = unitCacheData.isFullUpdateHelp, update = ((isHarmful and  not unitCacheData.isFullUpdateHarm) or (isHelpful and not unitCacheData.isFullUpdateHelp))}, "getUnitAuras - " .. unit)
	
	if unitCacheData and ((isHarmful and  not unitCacheData.isFullUpdateHarm) or (isHelpful and not unitCacheData.isFullUpdateHelp)) then --new aura event
		Plater.StartLogPerformanceCore("Plater-Core", "Update", "UpdateAuras - getUnitAuras - short")
		-- debuffs
		if unitCacheData.debuffsChanged then
			local tmpDebuffs = {}
			for auraInstanceID, aura in pairs (unitCacheData.debuffs) do
				if aura.requriresUpdate then
					tmpDebuffs[auraInstanceID] = GetAuraDataByAuraInstanceID(unit, auraInstanceID)
				else
					tmpDebuffs[auraInstanceID] = aura
				end
			end
			unitCacheData.debuffs = tmpDebuffs
			unitCacheData.debuffsChanged = false
		end
		
		-- buffs
		if unitCacheData.buffsChanged then
			local tmpBuffs = {}
			for auraInstanceID, aura in pairs (unitCacheData.buffs) do
				if aura.requriresUpdate then
					tmpBuffs[auraInstanceID] = GetAuraDataByAuraInstanceID(unit, auraInstanceID)
				else
					tmpBuffs[auraInstanceID] = aura
				end
			end
			unitCacheData.buffs = tmpBuffs
			unitCacheData.buffsChanged = false
		end
		
		Plater.EndLogPerformanceCore("Plater-Core", "Update", "UpdateAuras - getUnitAuras - short")
		return unitCacheData
	end
	
	if not filter then return end --old code requires this.
	unitCacheData = unitCacheData or {debuffs = {}, buffs = {}}
	UnitAuraCacheData[unit] = unitCacheData
	
	-- full updates and old way here
	local filterCache = (isHarmful and unitCacheData.debuffs) or (isHelpful and unitCacheData.buffs) or nil
	if not filterCache then return end
	
	Plater.StartLogPerformanceCore("Plater-Core", "Update", "UpdateAuras - getUnitAuras - long")
	
	local continuationToken
	local debuffIndex = 0
	repeat -- until continuationToken == nil
		local numSlots = 0
		local slots
		if IS_NEW_UNIT_AURA_AVAILABLE then
			slots = { GetAuraSlots(unit, filter, BUFF_MAX_DISPLAY_PLATER, continuationToken) }
			continuationToken = slots[1]
			numSlots = #slots
		else
			numSlots = (BUFF_MAX_DISPLAY or 32) + 1
		end
		
		for i=2, numSlots do
			if IS_NEW_UNIT_AURA_AVAILABLE then
				local slot = slots[i]
				local aura = GetAuraDataBySlot(unit, slot)
				if aura then
					--DevTool:AddData({unit = unit, aura = aura, slot = slot}, "GetAuraDataBySlot")
					filterCache[aura.auraInstanceID] = aura
				end
			else
				local name, icon, applications, dispelName, duration, expirationTime, sourceUnit, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossAura, isFromPlayerOrPlayerPet, nameplateShowAll, timeMod, shouldConsolidate  = UnitAura(unit, i-1, filter)
				--DevTool:AddData({name, icon, applications, dispelName, duration, expirationTime, sourceUnit, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossAura, isFromPlayerOrPlayerPet, nameplateShowAll, timeMod, shouldConsolidate }, "UnitAura")
				if not name then
					break
				end
				
				debuffIndex = debuffIndex + 1
				
				filterCache[debuffIndex] = {
					applications = applications,
					auraInstanceID = debuffIndex,
					canApplyAura = canApplyAura,
					dispelName = dispelName,
					duration = duration,
					expirationTime = expirationTime,
					icon = icon,
					isBossAura = isBossAura,
					isFromPlayerOrPlayerPet = isFromPlayerOrPlayerPet,
					isHarmful = isHarmful,
					isHelpful = isHelpful,
					isNameplateOnly = false,
					isRaid = false,
					isStealable = isStealable,
					name = name,
					nameplateShowAll = nameplateShowAll,
					nameplateShowPersonal = nameplateShowPersonal,
					points = {},
					sourceUnit = sourceUnit,
					spellId = spellId,
					timeMod = timeMod,
				}
			end
			
		end
	until continuationToken == nil
	
	Plater.EndLogPerformanceCore("Plater-Core", "Update", "UpdateAuras - getUnitAuras - long")
	
	-- done the update?
	if unitCacheData.isFullUpdateHelp and isHelpful then unitCacheData.isFullUpdateHelp = false end
	if unitCacheData.isFullUpdateHarm and isHarmful then unitCacheData.isFullUpdateHarm = false end
	return unitCacheData
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
	if not IS_NEW_UNIT_AURA_AVAILABLE or not unitID or not UnitAuraCacheData[unitID] then
		return nil
	end

	local allAuras = {}
	local aurasHelp = getUnitAuras(unitID, "HELPFUL") or {buffs = {}}
	local aurasHarm = getUnitAuras(unitID, "HARMFUL") or {debuffs = {}}
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
		if PlaterNamePlateAuraTooltip.SetUnitBuffByAuraInstanceID then
            if(iconFrame.spellId and not iconFrame.auraInstanceID) then 
                PlaterNamePlateAuraTooltip:SetSpellByID(iconFrame.spellId)
            elseif(iconFrame.auraInstanceID) then 
                local setFunction = iconFrame.isBuff and NamePlateTooltip.SetUnitBuffByAuraInstanceID or NamePlateTooltip.SetUnitDebuffByAuraInstanceID
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
		if NamePlateTooltip:IsForbidden() then return end
		NamePlateTooltip:Hide() -- backwards compatibility for mods (should be removed later)
	end
	
	--called from the options panel, request a refresh on all auras shown
	function Plater.RefreshAuras() --private
		for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
			if plateFrame.unitFrame.PlaterOnScreen then -- only for visible
				UnitAuraEventHandlerData[plateFrame.unitFrame.unit] = { hasBuff = true, hasDebuff = true } -- ensure aura update
				Plater.NameplateTick (plateFrame.OnTickFrame, 1)
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
		if (DB_AURA_GHOSTAURA_ENABLED) then
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
							Plater.AddAura(buffFrame, auraIconFrame, -1, spellName.."_player_ghost", spellIcon, 1, "DEBUFF", 0, 0, "player", false, false, -spellId, false, false, false, false, "DEBUFF", 1)
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
									Plater.AddAura  (buffFrame, auraIconFrame, -1, extraAuraTable.spellNameExtraCache, spellIcon, 1, "DEBUFF", duration, expirationTime, "player", false, false, spellId, false, false, true,  false, "DEBUFF", 1)

									--Plater.AddAura(buffFrame, auraIconFrame, -1, spellName.."_player_ghost",    spellIcon, 1, "DEBUFF", 0,        0,              "player", false, false, spellId, false, false, false, false, "DEBUFF", 1)
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
	function Plater.AlignAuraFrames (self)

		if (self.isNameplate) then
			local profile = Plater.db.profile
			local horizontalLength = 1
			local curRowLength = 0
			local verticalHeight = 1
			local firstIcon
		
			if (profile.aura_consolidate) then
				Plater.ConsolidateAuraIcons (self)
			end
			
			--get the table where all icon frames are stored in
			local iconFrameContainer = self.PlaterBuffList
			--get the amount of auras shown in the frame; iterate over all if not sorting
			local amountFramesShown = #iconFrameContainer
			
			
			if IS_NEW_UNIT_AURA_AVAILABLE then
				-- still sort by auraInstanceID for some consistency
				local iconFrameContainerCopy = {}
				local index = 0
				for _, icon in pairs(iconFrameContainer) do
					if icon:IsShown() then
						index = index + 1
						iconFrameContainerCopy[index] = icon
					end
				end
				iconFrameContainer = iconFrameContainerCopy
				table.sort (iconFrameContainer, function(aura1, aura2) 
					return (aura1.auraInstanceID or 0) < (aura2.auraInstanceID or 0)
				end)
				--when sorted, this is reliable
				amountFramesShown = index
			end
			
			if (profile.aura_sort) then
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
				for i = 1, amountFramesShown do
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
				for i = 1, amountFramesShown do
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

	--adjust the texcoord of the icon by the size of the icon
	--if the icon is more of a retangular shape, it'll cut the top and bottom sides of the icon giving a wide view
	function Plater.UpdateIconAspecRatio (auraIconFrame)
		local width, height = auraIconFrame:GetSize()
		local ratio = width > height and min (max (abs (width / height - 2) + 0.05, 0.6), 1) or .95
		auraIconFrame.Icon:SetTexCoord (.05, .95, .09, ratio)
	end

	function platerInternal.CreateAuraIcon (parent, name) --private ~createicon ~icon
		local newIcon = CreateFrame ("Button", name, parent, BackdropTemplateMixin and "BackdropTemplate")
		newIcon:Hide()
		newIcon:SetSize (20, 16)
		
		newIcon:SetScript ("OnEnter", Plater.OnEnterAura)
		newIcon:SetScript ("OnLeave", Plater.OnLeaveAura)
		
		newIcon:SetMouseClickEnabled (false)
		
		newIcon.Border = newIcon:CreateTexture (nil, "background")
		newIcon.Border:SetAllPoints()
		newIcon.Border:SetColorTexture (0, 0, 0)

		newIcon.BorderMask = newIcon:CreateMaskTexture(nil, "artwork")
		newIcon.BorderMask:SetAllPoints()
		newIcon.BorderMask:SetTexture([[Interface/addons/plater/masks/rounded_square_32x32]])
		newIcon.Border:AddMaskTexture(newIcon.BorderMask)
		newIcon.BorderMask:Hide()

		newIcon.Icon = newIcon:CreateTexture (nil, "BORDER")
		newIcon.Icon:SetSize (18, 12)
		newIcon.Icon:SetPoint ("center")
		newIcon.Icon:SetTexCoord (.05, .95, .1, .6)

		newIcon.IconMask = newIcon:CreateMaskTexture(nil, "artwork")
		newIcon.IconMask:SetAllPoints()
		newIcon.IconMask:SetTexture([[Interface/addons/plater/masks/rounded_square_32x32]])
		newIcon.Icon:AddMaskTexture(newIcon.IconMask)
		newIcon.IconMask:Hide()
		
		newIcon.Cooldown = CreateFrame ("cooldown", "$parentCooldown", newIcon, "CooldownFrameTemplate, BackdropTemplate")
		newIcon.Cooldown:SetPoint ("center", 0, -1)
		newIcon.Cooldown:SetAllPoints()
		newIcon.Cooldown:EnableMouse (false)
		if newIcon.Cooldown.EnableMouseMotion then
			newIcon.Cooldown:EnableMouseMotion (false)
		end
		newIcon.Cooldown:SetHideCountdownNumbers (true)
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

		--newIcon.Cooldown:SetSwipeColor (0, 0, 0) --not working
		--newIcon.Cooldown:SetDrawSwipe (false)
		--newIcon.Cooldown:SetSwipeTexture ("Interface\\Garrison\\Garr_TimerFill")
		--newIcon.Cooldown:SetEdgeTexture ("Interface\\Cooldown\\edge-LoC");
		--newIcon.Cooldown:SetReverse (true)
		--newIcon.Cooldown:SetCooldownUNIX (startTime, buildDuration);

		newIcon.CountFrame = CreateFrame ("frame", "$parentCountFrame", newIcon, BackdropTemplateMixin and "BackdropTemplate")
		newIcon.CountFrame:SetAllPoints()
		newIcon.CountFrame:EnableMouse (false)
		if newIcon.CountFrame.EnableMouseMotion then
			newIcon.CountFrame:EnableMouseMotion (false)
		end
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
		if (self.lastUpdateCooldown + 0.05) <= now then
			self.RemainingTime = (self.ExpirationTime - now) / (self.ModRate or 1)
			if self.RemainingTime > 0 then
				if self.formatWithDecimals then
					self.Cooldown.Timer:SetText (Plater.FormatTimeDecimal (self.RemainingTime))
				else
					self.Cooldown.Timer:SetText (Plater.FormatTime (self.RemainingTime))
				end
			else
				self.Cooldown.Timer:SetText ("")
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
			
			newFrameIcon:SetBackdrop ({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1})
		
			local auraWidth
			local auraHeight
			if curBuffFrame == 2 then
				auraWidth = Plater.db.profile.aura_width2
				auraHeight = Plater.db.profile.aura_height2
			else
				auraWidth = Plater.db.profile.aura_width
			    auraHeight = Plater.db.profile.aura_height
			end
			newFrameIcon:SetSize (auraWidth, auraHeight)
			newFrameIcon.Icon:SetSize (auraWidth-2, auraHeight-2)
			
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
					newFrameIcon.Border:Hide() --let Masque handle the border...
					Plater.Masque.AuraFrame1:AddButton (newFrameIcon, t, "AuraButtonTemplate", true)
					Plater.Masque.AuraFrame1:ReSkin(newFrameIcon)
					
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
					Plater.Masque.AuraFrame2:AddButton (newFrameIcon, t, "AuraButtonTemplate", true)
					Plater.Masque.AuraFrame2:ReSkin(newFrameIcon)
					
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
    

    	
	--update the aura icon, this icon is getted with GetAuraIcon -
	--dispelName is the UnitAura return value for the auraType ("" is enrage, nil/"none" for unspecified and "Disease", "Poison", "Curse", "Magic" for other types. -Continuity/Ariani
	--self is .BuffFrame or .BuffFrame2
	function Plater.AddAura (self, auraIconFrame, i, spellName, icon, applications, auraType, duration, expirationTime, sourceUnit, isStealable, nameplateShowPersonal, spellId, isBuff, isShowAll, isDebuff, isPersonal, dispelName, modRate) --~addaura ãddaura
		Plater.StartLogPerformanceCore("Plater-Core", "Update", "UpdateAuras - AddAura")
		
		auraIconFrame:SetID (i)
		auraIconFrame.auraInstanceID = i
		local curBuffFrame = self.Name == "Secondary" and 2 or 1

		-- ensure playing show animation if necessary
		if (not auraIconFrame.InUse) then
			auraIconFrame.ShowAnimation:Play()
		end
		
		--> check if the icon is showing a different aura
		if (auraIconFrame.spellId ~= spellId) then
			
			--> update the icon
			auraIconFrame.Icon:SetTexture (icon)
			
			--> update members
			auraIconFrame.spellId = spellId
			auraIconFrame.texture = icon
			auraIconFrame.layoutIndex = auraIconFrame.ID
			auraIconFrame.IsShowingBuff = false
			auraIconFrame.CanStealOrPurge = false
			auraIconFrame.AuraType = AURA_TYPES[dispelName] or "none"

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
		self.AuraCache [spellId.."_"..(sourceUnit or "N/A")] = true
		self.AuraCache [spellName.."_"..(sourceUnit or "N/A")] = true
		self.AuraCache.canStealOrPurge = self.AuraCache.canStealOrPurge or isStealable
		self.AuraCache.hasEnrage = self.AuraCache.hasEnrage or dispelName == AURA_TYPE_ENRAGE
		
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
				if curBuffFrame == 2 then
					local auraWidth = profile.aura_width2
					local auraHeight = profile.aura_height2
					auraIconFrame:SetSize (auraWidth, auraHeight)
					auraIconFrame.Icon:SetSize (auraWidth-2, auraHeight-2)
				else
					local auraWidth = profile.aura_width
					local auraHeight = profile.aura_height
					auraIconFrame:SetSize (auraWidth, auraHeight)
					auraIconFrame.Icon:SetSize (auraWidth-2, auraHeight-2)
				end
			end
			
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
			if (isPersonal) then
				local auraWidth = profile.aura_width_personal
				local auraHeight = profile.aura_height_personal
				auraIconFrame:SetSize (auraWidth, auraHeight)
				auraIconFrame.Icon:SetSize (auraWidth-2, auraHeight-2)
			else
				if curBuffFrame == 2 then
					local auraWidth = profile.aura_width2
					local auraHeight = profile.aura_height2
					auraIconFrame:SetSize (auraWidth, auraHeight)
					auraIconFrame.Icon:SetSize (auraWidth-2, auraHeight-2)
				else
					local auraWidth = profile.aura_width
					local auraHeight = profile.aura_height
					auraIconFrame:SetSize (auraWidth, auraHeight)
					auraIconFrame.Icon:SetSize (auraWidth-2, auraHeight-2)
				end
			end
			
			Plater.UpdateIconAspecRatio (auraIconFrame)
		end
		auraIconFrame.IsPersonal = isPersonal
		auraIconFrame.IsGhostAura = false
		auraIconFrame.BuffFrame = self.Name == "Secondary" and 2 or 1

		if (applications > 1) then
			local stackLabel = auraIconFrame.CountFrame.Count
			stackLabel:SetText (applications)
			stackLabel:Show()
		else
			auraIconFrame.CountFrame.Count:Hide()
		end
		
		auraIconFrame.IsShowingBuff = isBuff
		auraIconFrame.CanStealOrPurge = isStealable
		
		--border colors
		if (isStealable) then
			auraIconFrame:SetBackdropBorderColor (unpack (profile.aura_border_colors.steal_or_purge))
		
		elseif (Plater.db.profile.aura_border_colors_by_type) then
			-- use Blizzards color global 'DebuffTypeColor' for the actual color:
			local color = DebuffTypeColor[dispelName or "none"] or {r=0,b=0,g=0, a=0}
			auraIconFrame:SetBackdropBorderColor (color.r, color.g, color.b, color.a or 1)
		
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
			--> for debuffs on the player for the personal bar
			auraIconFrame:SetBackdropBorderColor (1, 0, 0, 1)
		
		elseif (isShowAll) then
			auraIconFrame:SetBackdropBorderColor (unpack (profile.aura_border_colors.is_show_all))
				
		else
			auraIconFrame:SetBackdropBorderColor (0, 0, 0, 0)
			
		end

		modRate = modRate or 1
		--CooldownFrame_Set(self, start, duration, enable, forceShowDrawEdge, modRate)
		CooldownFrame_Set (auraIconFrame.Cooldown, expirationTime - duration, duration, duration > 0, true, modRate)
		local now = GetTime()
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
		if (auraIconFrame:IsShown()) then
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
		
		--Plater.Masque.AuraFrame1:ReSkin()

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

	--> check both buff frames for aura icons which aren't in use and hide them
	Plater.HideNonUsedAuraIcons = function (self)
	
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
		
		local _, sourceUnitClass = UnitClass(sourceUnit or "")
		local sourceUnitName
		if (sourceUnitClass and UnitPlayerControlled(sourceUnit)) then
			--adding only the name for players in case the player used a stun
			sourceUnitName = UnitName(sourceUnit)
		end

		local borderColor
		local profile = Plater.db.profile

		if (isStealable) then
			borderColor = profile.extra_icon_show_purge_border

		elseif (profile.extra_icon_use_blizzard_border_color) then
			-- use blizzard border colors
			local color = DebuffTypeColor[debuffType or "none"] or {r=0, b=0, g=0, a=0} --dispelName is a global? it have been not passed | dispelName is the 5th argument
			borderColor = {color.r, color.g, color.b, color.a or 1}

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

		--spellId, borderColor, startTime, duration, forceTexture, descText
		--calling SetIcon make the ExtraIconFrame call show() on it self
		local iconFrame = self.ExtraIconFrame:SetIcon (spellId, borderColor, expirationTime - duration, duration, false, sourceUnitName and {text = sourceUnitName, text_color = sourceUnitClass} or false, applications, debuffType, sourceUnit, isStealable, spellName, isBuff, modRate)
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
			Plater.Masque.BuffSpecial:AddButton (iconFrame, t, "AuraButtonTemplate", true)
			Plater.Masque.BuffSpecial:ReSkin(iconFrame)
			iconFrame.Masqued = true
		end
		
		Plater.EndLogPerformanceCore("Plater-Core", "Update", "UpdateAuras - AddExtraIcon")
	end
	
	--> reset both buff frames to make them ready to receive an aura update
	function Plater.ResetAuraContainer (self, resetBuffs, resetDebuffs)
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
		local unitAuraCache = self.unitFrame.AuraCache
		local show_debuffs_personal = Plater.db.profile.aura_show_debuffs_personal
		local show_buffs_personal = Plater.db.profile.aura_show_buffs_personal
 
		if (isBuff) then
			local unitAuras = getUnitAuras(unit, "HELPFUL") or {}
			
			for id, aura in pairs(unitAuras.buffs or {}) do
				--DevTool:AddData({i, aura})
				local name, icon, applications, dispelName, duration, expirationTime, sourceUnit, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossAura, isFromPlayerOrPlayerPet, nameplateShowAll, timeMod, applications = 
					aura.name, aura.icon, aura.applications, aura.dispelName, aura.duration, aura.expirationTime, aura.sourceUnit, aura.isStealable, aura.nameplateShowPersonal, aura.spellId, aura.canApplyAura, 
					aura.isBossAura, aura.isFromPlayerOrPlayerPet, aura.nameplateShowAll, aura.timeMod, aura.applications
				
				unitAuraCache[name] = true
				unitAuraCache[spellId] = true
				unitAuraCache[name.."_"..(sourceUnit or "N/A")] = true
				unitAuraCache[spellId.."_"..(sourceUnit or "N/A")] = true
				unitAuraCache.canStealOrPurge = unitAuraCache.canStealOrPurge or isStealable
				unitAuraCache.hasEnrage = unitAuraCache.hasEnrage or dispelName == AURA_TYPE_ENRAGE
				
				if ((show_buffs_personal and isPersonal) or not isPersonal) then
				
					local auraType = "BUFF"
					--verify is this aura is in the table passed
					if (aurasToCheck [name] or aurasToCheck [spellId]) then
						local auraIconFrame, buffFrame = Plater.GetAuraIcon (self, true)
						Plater.AddAura (buffFrame, auraIconFrame, id, name, icon, applications, auraType, duration, expirationTime, sourceUnit, isStealable, nameplateShowPersonal, spellId, true, false, false, isPersonal, dispelName, timeMod)
					end
					
					--> check if is a special aura
					if (not noSpecial) then
						--> check for special auras auto added by setting like 'show crowd control' or 'show dispellable'
						--> SPECIAL_AURAS_AUTO_ADDED has a list of crowd control not do not have a list of dispellable, so check if isStealable.
						--> in addition, we want to check if enrage tracking is enabled and show enrage effects
						if (SPECIAL_AURAS_AUTO_ADDED [name] or SPECIAL_AURAS_AUTO_ADDED [spellId] or (DB_SHOW_PURGE_IN_EXTRA_ICONS and isStealable) or (DB_SHOW_ENRAGE_IN_EXTRA_ICONS and dispelName == AURA_TYPE_ENRAGE) or (DB_SHOW_MAGIC_IN_EXTRA_ICONS and dispelName == AURA_TYPE_MAGIC)) then
							Plater.AddExtraIcon (self, name, icon, applications, dispelName, duration, expirationTime, sourceUnit, isStealable, nameplateShowPersonal, spellId, true, "HELPFUL", id, timeMod)
						
						--> check for special auras added by the user it self
						elseif (((SPECIAL_AURAS_USER_LIST [name] or SPECIAL_AURAS_USER_LIST [spellId]) and not (SPECIAL_AURAS_USER_LIST_MINE [name] or SPECIAL_AURAS_USER_LIST_MINE [spellId])) or ((SPECIAL_AURAS_USER_LIST_MINE [name] or SPECIAL_AURAS_USER_LIST_MINE [spellId]) and sourceUnit and (UnitIsUnit (sourceUnit, "player") or UnitIsUnit (sourceUnit, "pet")))) then
							Plater.AddExtraIcon (self, name, icon, applications, dispelName, duration, expirationTime, sourceUnit, isStealable, nameplateShowPersonal, spellId, true,"HELPFUL", id, timeMod)
							
						end
					end
				end
			end
		else
			--> debuffs
			local unitAuras = getUnitAuras(unit, "HARMFUL") or {}
			
			for id, aura in pairs(unitAuras.debuffs or {}) do
				--DevTool:AddData({i, aura})
				local name, icon, applications, dispelName, duration, expirationTime, sourceUnit, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossAura, isFromPlayerOrPlayerPet, nameplateShowAll, timeMod, applications = 
					aura.name, aura.icon, aura.applications, aura.dispelName, aura.duration, aura.expirationTime, aura.sourceUnit, aura.isStealable, aura.nameplateShowPersonal, aura.spellId, aura.canApplyAura, 
					aura.isBossAura, aura.isFromPlayerOrPlayerPet, aura.nameplateShowAll, aura.timeMod, aura.applications
				
				unitAuraCache[name] = true
				unitAuraCache[spellId] = true
				unitAuraCache[name.."_"..(sourceUnit or "N/A")] = true
				unitAuraCache[spellId.."_"..(sourceUnit or "N/A")] = true
				unitAuraCache.canStealOrPurge = unitAuraCache.canStealOrPurge or isStealable
				unitAuraCache.hasEnrage = unitAuraCache.hasEnrage or dispelName == AURA_TYPE_ENRAGE
				
				if ((show_debuffs_personal and isPersonal) or not isPersonal) then
				
					local auraType = "DEBUFF"
					--checking here if the debuff is placed by the player
					--if (sourceUnit and aurasToCheck [name] and UnitIsUnit (sourceUnit, "player")) then --this doesn't track the pet, so auras like freeze from mage frost elemental won't show
					if (sourceUnit and (aurasToCheck [name] or aurasToCheck [spellId]) and (UnitIsUnit (sourceUnit, "player") or UnitIsUnit (sourceUnit, "pet"))) then
					--if (aurasToCheck [name]) then
						local auraIconFrame, buffFrame = Plater.GetAuraIcon (self)
						Plater.AddAura (buffFrame, auraIconFrame, id, name, icon, applications, auraType, duration, expirationTime, sourceUnit, isStealable, nameplateShowPersonal, spellId, false, false, false, isPersonal, dispelName, timeMod)
					end
					
					--> check if is a special aura
					if (not noSpecial) then
						--> check for special auras auto added by setting like 'show crowd control' or 'show dispellable'
						--> SPECIAL_AURAS_AUTO_ADDED has a list of crowd control not do not have a list of dispellable, so check if isStealable
						--> in addition, we want to check if enrage tracking is enabled and show enrage effects
						if (SPECIAL_AURAS_AUTO_ADDED [name] or SPECIAL_AURAS_AUTO_ADDED [spellId] or (DB_SHOW_PURGE_IN_EXTRA_ICONS and isStealable) or (DB_SHOW_ENRAGE_IN_EXTRA_ICONS and dispelName == AURA_TYPE_ENRAGE)) then
							Plater.AddExtraIcon (self, name, icon, applications, dispelName, duration, expirationTime, sourceUnit, isStealable, nameplateShowPersonal, spellId, false, "HARMFUL", id, timeMod)
						
						--> check for special auras added by the user it self
						elseif (((SPECIAL_AURAS_USER_LIST [name] or SPECIAL_AURAS_USER_LIST [spellId]) and not (SPECIAL_AURAS_USER_LIST_MINE [name] or SPECIAL_AURAS_USER_LIST_MINE [spellId])) or ((SPECIAL_AURAS_USER_LIST_MINE [name] or SPECIAL_AURAS_USER_LIST_MINE [spellId]) and sourceUnit and (UnitIsUnit (sourceUnit, "player") or UnitIsUnit (sourceUnit, "pet")))) then
							Plater.AddExtraIcon (self, name, icon, applications, dispelName, duration, expirationTime, sourceUnit, isStealable, nameplateShowPersonal, spellId, false, "HARMFUL", id, timeMod)
							
						end
					end
				end
			end
		end
		
		return true
	end
	
	function Plater.UpdateAuras_Manual (self, unit, isPersonal)
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
			local unitAuras = getUnitAuras(unit, "HARMFUL") or {}
			
			for id, aura in pairs(unitAuras.debuffs or {}) do
				--DevTool:AddData({i, aura})
				local name, icon, applications, dispelName, duration, expirationTime, sourceUnit, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossAura, isFromPlayerOrPlayerPet, nameplateShowAll, timeMod, applications = 
					aura.name, aura.icon, aura.applications, aura.dispelName, aura.duration, aura.expirationTime, aura.sourceUnit, aura.isStealable, aura.nameplateShowPersonal, aura.spellId, aura.canApplyAura, 
					aura.isBossAura, aura.isFromPlayerOrPlayerPet, aura.nameplateShowAll, aura.timeMod, aura.applications
				
				--start as false, during the checks can be changed to true, if is true this debuff is added on the nameplate
				local can_show_this_debuff
				local auraType = "DEBUFF"
				
				unitAuraCache[name] = true
				unitAuraCache[spellId] = true
				unitAuraCache[name.."_"..(sourceUnit or "N/A")] = true
				unitAuraCache[spellId.."_"..(sourceUnit or "N/A")] = true
				unitAuraCache.canStealOrPurge = unitAuraCache.canStealOrPurge or isStealable
				unitAuraCache.hasEnrage = unitAuraCache.hasEnrage or dispelName == AURA_TYPE_ENRAGE

				--check if the debuff isn't filtered out
				if (not DB_DEBUFF_BANNED [name] and not DB_DEBUFF_BANNED [spellId]) then
			
					--> if true it'll show all auras - this can be called from scripts to debug aura things
					if (Plater.DebugAuras) then
						if (duration and duration < 60) then
							can_show_this_debuff = true
						end
					end
			
					--> important aura
					if (DB_AURA_SHOW_IMPORTANT and (nameplateShowAll or isBossAura)) then
						can_show_this_debuff = true
					
					--> is casted by the player
					elseif (DB_AURA_SHOW_BYPLAYER and sourceUnit and (UnitIsUnit (sourceUnit, "player") or UnitIsUnit (sourceUnit, "pet") or Plater.PlayerPetCache[UnitGUID(sourceUnit)])) then
						can_show_this_debuff = true
						
					--> is casted by other players
					elseif (DB_AURA_SHOW_BYOTHERPLAYERS and isFromPlayerOrPlayerPet and sourceUnit and not UnitIsUnit (sourceUnit, "player")) then
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
				end
				
				--> check for special auras added by the user it self
				if (can_show_this_debuff ~= false and (((SPECIAL_AURAS_USER_LIST [name] or SPECIAL_AURAS_USER_LIST [spellId]) and not (SPECIAL_AURAS_USER_LIST_MINE [name] or SPECIAL_AURAS_USER_LIST_MINE [spellId])) or ((SPECIAL_AURAS_USER_LIST_MINE [name] or SPECIAL_AURAS_USER_LIST_MINE [spellId]) and sourceUnit and (UnitIsUnit (sourceUnit, "player") or UnitIsUnit (sourceUnit, "pet"))))) then
					Plater.AddExtraIcon (self, name, icon, applications, dispelName, duration, expirationTime, sourceUnit, isStealable, nameplateShowPersonal, spellId, false, "HARMFUL", id, timeMod)
					can_show_this_debuff = false
				end
				
				if (can_show_this_debuff) then
					--get the icon to be used by this aura
					local auraIconFrame, buffFrame = Plater.GetAuraIcon (self)
					Plater.AddAura (buffFrame, auraIconFrame, id, name, icon, applications, auraType, duration, expirationTime, sourceUnit, isStealable, nameplateShowPersonal, spellId, false, nil, nil, nil, dispelName, timeMod)
				end
			end
		end
		
		--> buffs
		if unitAuraEventData.hasBuff then
			local unitAuras = getUnitAuras(unit, "HELPFUL") or {}
			--DevTool:AddData(unitAuras, "HELPFUL")
			
			for id, aura in pairs(unitAuras.buffs or {}) do
				--DevTool:AddData({i, aura})
				local name, icon, applications, dispelName, duration, expirationTime, sourceUnit, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossAura, isFromPlayerOrPlayerPet, nameplateShowAll, timeMod, applications = 
					aura.name, aura.icon, aura.applications, aura.dispelName, aura.duration, aura.expirationTime, aura.sourceUnit, aura.isStealable, aura.nameplateShowPersonal, aura.spellId, aura.canApplyAura, 
					aura.isBossAura, aura.isFromPlayerOrPlayerPet, aura.nameplateShowAll, aura.timeMod, aura.applications
				
				local auraType = "BUFF"
				
				unitAuraCache[name] = true
				unitAuraCache[spellId] = true
				unitAuraCache[name.."_"..(sourceUnit or "N/A")] = true
				unitAuraCache[spellId.."_"..(sourceUnit or "N/A")] = true
				unitAuraCache.canStealOrPurge = unitAuraCache.canStealOrPurge or isStealable
				unitAuraCache.hasEnrage = unitAuraCache.hasEnrage or dispelName == AURA_TYPE_ENRAGE
				
				--> check for special auras added by the user it self
				if (((SPECIAL_AURAS_USER_LIST [name] or SPECIAL_AURAS_USER_LIST [spellId]) and not (SPECIAL_AURAS_USER_LIST_MINE [name] or SPECIAL_AURAS_USER_LIST_MINE [spellId])) or ((SPECIAL_AURAS_USER_LIST_MINE [name] or SPECIAL_AURAS_USER_LIST_MINE [spellId]) and sourceUnit and (UnitIsUnit (sourceUnit, "player") or UnitIsUnit (sourceUnit, "pet")))) then
					Plater.AddExtraIcon (self, name, icon, applications, dispelName, duration, expirationTime, sourceUnit, isStealable, nameplateShowPersonal, spellId, true, "HELPFUL", id, timeMod)
					
				elseif (not DB_BUFF_BANNED [name] and not DB_BUFF_BANNED [spellId]) then
					--> if true it'll show all auras - this can be called from scripts to debug aura things
					if (Plater.DebugAuras) then
						if (duration and duration < 60) then
							local auraIconFrame, buffFrame = Plater.GetAuraIcon (self, true)
							Plater.AddAura (buffFrame, auraIconFrame, id, name, icon, applications, auraType, duration, expirationTime, sourceUnit, isStealable, nameplateShowPersonal, spellId, true, nil, nil, nil, dispelName, timeMod)
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
						if (DB_AURA_SHOW_IMPORTANT and (nameplateShowAll or isBossAura)) then
							local auraIconFrame, buffFrame = Plater.GetAuraIcon (self, true)
							Plater.AddAura (buffFrame, auraIconFrame, id, name, icon, applications, auraType, duration, expirationTime, sourceUnit, isStealable, nameplateShowPersonal, spellId, true, true, nil, nil, dispelName, timeMod)
						
						--> is dispellable or can be steal
						elseif (DB_AURA_SHOW_DISPELLABLE and isStealable) then
							if (self.unitFrame.isPlayer and DB_AURA_SHOW_ONLY_SHORT_DISPELLABLE_ON_PLAYERS) then
								--don't show dispellable on players if the duration is bigger than 2 minutes (terciob july 2022)
								--this avoid showing big buffs like power word: fortitute
								--show infinite as well and option to enable this separately (continuity, july 2022)
								if (duration == 0 or duration < 120) then
									local auraIconFrame, buffFrame = Plater.GetAuraIcon (self, true)
									Plater.AddAura (buffFrame, auraIconFrame, id, name, icon, applications, auraType, duration, expirationTime, sourceUnit, isStealable, nameplateShowPersonal, spellId, true, nil, nil, nil, dispelName, timeMod)
								end
							else
								local auraIconFrame, buffFrame = Plater.GetAuraIcon (self, true)
								Plater.AddAura (buffFrame, auraIconFrame, id, name, icon, applications, auraType, duration, expirationTime, sourceUnit, isStealable, nameplateShowPersonal, spellId, true, nil, nil, nil, dispelName, timeMod)
							end
							
						--> is enrage
						elseif (DB_AURA_SHOW_ENRAGE and dispelName == AURA_TYPE_ENRAGE) then
							local auraIconFrame, buffFrame = Plater.GetAuraIcon (self, true)
							Plater.AddAura (buffFrame, auraIconFrame, id, name, icon, applications, auraType, duration, expirationTime, sourceUnit, isStealable, nameplateShowPersonal, spellId, true, nil, nil, nil, dispelName, timeMod)
						
						--> is magic
						elseif (DB_AURA_SHOW_MAGIC and dispelName == AURA_TYPE_MAGIC) then
							local auraIconFrame, buffFrame = Plater.GetAuraIcon (self, true)
							Plater.AddAura (buffFrame, auraIconFrame, id, name, icon, applications, auraType, duration, expirationTime, sourceUnit, isStealable, nameplateShowPersonal, spellId, true, nil, nil, nil, dispelName, timeMod)
						
						--> is casted by the player
						elseif (DB_AURA_SHOW_BYPLAYER and sourceUnit and UnitIsUnit (sourceUnit, "player")) then
							local auraIconFrame, buffFrame = Plater.GetAuraIcon (self, true)
							Plater.AddAura (buffFrame, auraIconFrame, id, name, icon, applications, auraType, duration, expirationTime, sourceUnit, isStealable, nameplateShowPersonal, spellId, true, nil, nil, nil, dispelName, timeMod)
							
						--> is casted by other players
						elseif (DB_AURA_SHOW_BYOTHERPLAYERS and isFromPlayerOrPlayerPet and sourceUnit and not UnitIsUnit (sourceUnit, "player")) then
							local auraIconFrame, buffFrame = Plater.GetAuraIcon (self, true)
							Plater.AddAura (buffFrame, auraIconFrame, id, name, icon, applications, auraType, duration, expirationTime, sourceUnit, isStealable, nameplateShowPersonal, spellId, true, nil, nil, nil, dispelName, timeMod)
							
						--> is casted by the unit it self
						elseif (DB_AURA_SHOW_BYUNIT and sourceUnit and UnitIsUnit (sourceUnit, unit) and not isFromPlayerOrPlayerPet) then
							local auraIconFrame, buffFrame = Plater.GetAuraIcon (self, true)
							Plater.AddAura (buffFrame, auraIconFrame, id, name, icon, applications, auraType, duration, expirationTime, sourceUnit, isStealable, nameplateShowPersonal, spellId, true, nil, nil, nil, dispelName, timeMod)
						
						--> user added this buff to track in the buff tracking tab
						elseif (AUTO_TRACKING_EXTRA_BUFFS [name] or AUTO_TRACKING_EXTRA_BUFFS [spellId]) then
							local auraIconFrame, buffFrame = Plater.GetAuraIcon (self, true)
							Plater.AddAura (buffFrame, auraIconFrame, id, name, icon, applications, auraType, duration, expirationTime, sourceUnit, isStealable, nameplateShowPersonal, spellId, true, nil, nil, nil, dispelName, timeMod)
							
						end
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
		
		--> debuffs
		if (Plater.db.profile.aura_show_debuffs_personal and unitAuraEventData.hasDebuff) then
			local unitAuras = getUnitAuras(unit, "HARMFUL") or {}
			--DevTool:AddData(unitAuras)
			
			for id, aura in pairs(unitAuras.debuffs or {}) do
				--DevTool:AddData({i, aura})
				local name, icon, applications, dispelName, duration, expirationTime, sourceUnit, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossAura, isFromPlayerOrPlayerPet, nameplateShowAll, timeMod, applications = 
					aura.name, aura.icon, aura.applications, aura.dispelName, aura.duration, aura.expirationTime, aura.sourceUnit, aura.isStealable, aura.nameplateShowPersonal, aura.spellId, aura.canApplyAura, 
					aura.isBossAura, aura.isFromPlayerOrPlayerPet, aura.nameplateShowAll, aura.timeMod, aura.applications

				
				local auraType = "DEBUFF"
				
				unitAuraCache[name] = true
				unitAuraCache[spellId] = true
				unitAuraCache[name.."_"..(sourceUnit or "N/A")] = true
				unitAuraCache[spellId.."_"..(sourceUnit or "N/A")] = true
				unitAuraCache.canStealOrPurge = unitAuraCache.canStealOrPurge or isStealable
				unitAuraCache.hasEnrage = unitAuraCache.hasEnrage or dispelName == AURA_TYPE_ENRAGE
					
				if (not DB_DEBUFF_BANNED [name] and not DB_DEBUFF_BANNED [spellId]) then
					local auraIconFrame, buffFrame = Plater.GetAuraIcon (self)
					Plater.AddAura (buffFrame, auraIconFrame, id, name, icon, applications, auraType, duration, expirationTime, sourceUnit, isStealable, nameplateShowPersonal, spellId, false, false, true, true, dispelName, timeMod)
					
					--> check for special auras auto added by setting like 'show crowd control' or 'show dispellable'
					--> SPECIAL_AURAS_AUTO_ADDED has a list of crowd control not do not have a list of dispellable, so check if isStealable
					--> in addition, we want to check if enrage tracking is enabled and show enrage effects
					if (SPECIAL_AURAS_AUTO_ADDED [name] or SPECIAL_AURAS_AUTO_ADDED [spellId] or (DB_SHOW_PURGE_IN_EXTRA_ICONS and isStealable) or (DB_SHOW_ENRAGE_IN_EXTRA_ICONS and dispelName == AURA_TYPE_ENRAGE)) then
						Plater.AddExtraIcon (self, name, icon, applications, dispelName, duration, expirationTime, sourceUnit, isStealable, nameplateShowPersonal, spellId, false, "HARMFUL", id, timeMod)
					end
				end
				
				--> check for special auras added by the user it self
				if (((SPECIAL_AURAS_USER_LIST [name] or SPECIAL_AURAS_USER_LIST [spellId]) and not (SPECIAL_AURAS_USER_LIST_MINE [name] or SPECIAL_AURAS_USER_LIST_MINE [spellId])) or ((SPECIAL_AURAS_USER_LIST_MINE [name] or SPECIAL_AURAS_USER_LIST_MINE [spellId]) and sourceUnit and (UnitIsUnit (sourceUnit, "player") or UnitIsUnit (sourceUnit, "pet")))) then
					Plater.AddExtraIcon (self, name, icon, applications, dispelName, duration, expirationTime, sourceUnit, isStealable, nameplateShowPersonal, spellId, false, "HARMFUL", id, timeMod)
				end
				
			end
		end
		
		--> buffs
		if (Plater.db.profile.aura_show_buffs_personal and unitAuraEventData.hasBuff) then
			local unitAuras = getUnitAuras(unit, "HELPFUL|PLAYER") or {}
			--DevTool:AddData(unitAuras)
			
			for id, aura in pairs(unitAuras.buffs or {}) do
				--DevTool:AddData({i, aura})
				local name, icon, applications, dispelName, duration, expirationTime, sourceUnit, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossAura, isFromPlayerOrPlayerPet, nameplateShowAll, timeMod, applications = 
					aura.name, aura.icon, aura.applications, aura.dispelName, aura.duration, aura.expirationTime, aura.sourceUnit, aura.isStealable, aura.nameplateShowPersonal, aura.spellId, aura.canApplyAura, 
					aura.isBossAura, aura.isFromPlayerOrPlayerPet, aura.nameplateShowAll, aura.timeMod, aura.applications
					
				local auraType = "BUFF"

				unitAuraCache[name] = true
				unitAuraCache[spellId] = true
				unitAuraCache[name.."_"..(sourceUnit or "N/A")] = true
				unitAuraCache[spellId.."_"..(sourceUnit or "N/A")] = true
				unitAuraCache.canStealOrPurge = unitAuraCache.canStealOrPurge or isStealable
				unitAuraCache.hasEnrage = unitAuraCache.hasEnrage or dispelName == AURA_TYPE_ENRAGE
				
				--> only show buffs casted by the player it self and less than 1 minute in duration
				if ((not DB_BUFF_BANNED [name] and not DB_BUFF_BANNED [spellId]) and (noBuffDurationLimitation or (duration and (duration > 0 and duration < 60))) and (sourceUnit and UnitIsUnit (sourceUnit, "player"))) then
					local auraIconFrame, buffFrame = Plater.GetAuraIcon (self, true)
					Plater.AddAura (buffFrame, auraIconFrame, id, name, icon, applications, auraType, duration, expirationTime, sourceUnit, isStealable, nameplateShowPersonal, spellId, true, false, false, true, dispelName, timeMod)

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
									Plater.AddAura (buffFrame, auraIconFrame, index, auraTable.SpellName, auraTable.SpellTexture, auraTable.Count, "DEBUFF", auraTable.Duration, auraTable.ApplyTime+auraTable.Duration, "player", false, false, auraTable.SpellID, nil, nil, nil, nil, auraTable.Type, 1)
								else
									Plater.AddAura (buffFrame, auraIconFrame, index, auraTable.SpellName, auraTable.SpellTexture, auraTable.Count, "DEBUFF", auraTable.Duration, auraTable.ApplyTime+auraTable.Duration, "player", false, false, auraTable.SpellID, false, false, true, true, auraTable.Type, 1)
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
									Plater.AddAura (buffFrame, auraIconFrame, index, auraTable.SpellName, auraTable.SpellTexture, auraTable.Count, "DEBUFF", auraTable.Duration, auraTable.ApplyTime+auraTable.Duration, "player", true, false, auraTable.SpellID, true, nil, nil, nil, auraTable.Type, 1)
								else
									Plater.AddAura (buffFrame, auraIconFrame, index, auraTable.SpellName, auraTable.SpellTexture, auraTable.Count, "DEBUFF", auraTable.Duration, auraTable.ApplyTime+auraTable.Duration, "player", true, false, auraTable.SpellID, false, false, false, true, auraTable.Type, 1)
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
									Plater.AddAura (buffFrame, auraIconFrame, index, auraTable.SpellName, auraTable.SpellTexture, auraTable.Count, "DEBUFF", auraTable.Duration, auraTable.ApplyTime+auraTable.Duration, "player", false, false, auraTable.SpellID, nil, nil, nil, nil, auraTable.Type, 1)
								else
									Plater.AddAura (buffFrame, auraIconFrame, index, auraTable.SpellName, auraTable.SpellTexture, auraTable.Count, "DEBUFF", auraTable.Duration, auraTable.ApplyTime+auraTable.Duration, "player", false, false, auraTable.SpellID, false, false, true, true, auraTable.Type, 1)
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
									Plater.AddAura (frame, auraIconFrame, index, auraTable.SpellName, auraTable.SpellTexture, auraTable.Count, "BUFF", auraTable.Duration, auraTable.ApplyTime+auraTable.Duration, "player", true, false, auraTable.SpellID, true, nil, nil, nil, auraTable.Type, 1)
								else
									Plater.AddAura (frame, auraIconFrame, index, auraTable.SpellName, auraTable.SpellTexture, auraTable.Count, "BUFF", auraTable.Duration, auraTable.ApplyTime+auraTable.Duration, "player", true, false, auraTable.SpellID, true, false, false, false, auraTable.Type, 1)
									--Plater.AddAura (frame, auraIconFrame, index, auraTable.SpellName, auraTable.SpellTexture, auraTable.Count, "BUFF", auraTable.Duration, auraTable.ApplyTime+auraTable.Duration, "player", true, false, auraTable.SpellID, false, false, false, true, auraTable.Type)
								end
								
								unitAuraCache[auraTable.SpellName] = true
								unitAuraCache[auraTable.SpellID] = true
								unitAuraCache[auraTable.SpellName.."_player"] = true
								unitAuraCache[auraTable.SpellID.."_player"] = true
								unitAuraCache.hasEnrage = unitAuraCache.hasEnrage or auraTable.Type == AURA_TYPE_ENRAGE
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
		end

		auraOptionsFrame.EnableAuraTest = function()
			DB_AURA_ENABLED = false
			Plater.DisableAuraTrackingForAuraTest()
			Plater.RefreshAuras()
			auraOptionsFrame.NextTime = 0.2
			auraOptionsFrame:SetScript ("OnUpdate", auraOptionsFrame.OnUpdateFunc)
		end
		auraOptionsFrame.DisableAuraTest = function()
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
			for spellId, _ in pairs (DF.CrowdControlSpells) do
				local spellName = GetSpellInfo (spellId)
				if (spellName) then
					SPECIAL_AURAS_AUTO_ADDED [spellId] = true
					CROWDCONTROL_AURA_IDS [spellId] = true
				end
			end
        end
        
		--build the offensive cd list
		if (profile.extra_icon_show_offensive) then
			for spellId, _ in pairs (DF.CooldownsAttack) do
				local spellName = GetSpellInfo (spellId)
				if (spellName) then
					SPECIAL_AURAS_AUTO_ADDED [spellId] = true
					OFFENSIVE_AURA_IDS [spellId] = true
				end
			end
        end
        
		--build the defensive cd list
		if (profile.extra_icon_show_defensive) then
			for spellId, _ in pairs (DF.CooldownsAllDeffensive) do
				local spellName = GetSpellInfo (spellId)
				if (spellName) then
					SPECIAL_AURAS_AUTO_ADDED [spellId] = true
					DEFENSIVE_AURA_IDS [spellId] = true
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
						SPECIAL_AURAS_USER_LIST_MINE [spellId] = true
					end
				end
			end
		end
    end

	function Plater.RefreshAuraCache()
		local profile = Plater.db.profile

		DB_AURA_ENABLED = profile.aura_enabled
		DB_AURA_ALPHA = profile.aura_alpha

		DB_AURA_SEPARATE_BUFFS = Plater.db.profile.buffs_on_aura2

		DB_AURA_SHOW_IMPORTANT = profile.aura_show_important
		DB_AURA_SHOW_DISPELLABLE = profile.aura_show_dispellable
		DB_AURA_SHOW_ONLY_SHORT_DISPELLABLE_ON_PLAYERS = profile.aura_show_only_short_dispellable_on_players
		DB_AURA_SHOW_ENRAGE = profile.aura_show_enrage
		DB_AURA_SHOW_MAGIC = profile.aura_show_magic
		DB_AURA_SHOW_BYPLAYER = profile.aura_show_aura_by_the_player
		DB_AURA_SHOW_BYOTHERPLAYERS = profile.aura_show_aura_by_other_players
		DB_AURA_SHOW_BYUNIT = profile.aura_show_buff_by_the_unit
		DB_AURA_PADDING = profile.aura_padding

		DB_AURA_GROW_DIRECTION = profile.aura_grow_direction
		DB_AURA_GROW_DIRECTION2 = profile.aura2_grow_direction

		DB_AURA_GHOSTAURA_ENABLED = profile.ghost_auras.enabled
		
		DB_TRACK_METHOD = profile.aura_tracker.track_method

		Plater.MaxAurasPerRow = floor(profile.plate_config.enemynpc.health_incombat[1] / (profile.aura_width + DB_AURA_PADDING))
		
		if IS_WOW_PROJECT_CLASSIC_ERA then
			IS_NEW_UNIT_AURA_AVAILABLE = Plater.db.profile.auras_experimental_update_classic_era
		end
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
				local spellName = GetSpellInfo (tonumber(manualDebuffsToTrack [i]) or manualDebuffsToTrack [i])
				if (spellName) then
					MANUAL_TRACKING_DEBUFFS [spellName] = true
				else
					--add the entry in case there's a spell name instead of a spellId in the list (for back compatibility)
					MANUAL_TRACKING_DEBUFFS [manualDebuffsToTrack [i]] = true
				end
			end

			for i = 1, #manualBuffsToTrack do
				local spellName = GetSpellInfo (tonumber(manualBuffsToTrack [i]) or manualBuffsToTrack [i])
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
						AUTO_TRACKING_EXTRA_DEBUFFS [spellId] = true
						CROWDCONTROL_AURA_IDS [spellId] = true
					end
				end
			end

			if (profile.aura_show_offensive_cd and DF.CooldownsAttack) then
				for spellId, _ in pairs (DF.CooldownsAttack) do
					local spellName = GetSpellInfo (spellId)
					if (spellName) then
						--AUTO_TRACKING_EXTRA_BUFFS [spellName] = true
						AUTO_TRACKING_EXTRA_BUFFS [spellId] = true
						OFFENSIVE_AURA_IDS [spellId] = true
					end
				end
			end

			if (profile.aura_show_defensive_cd and DF.CooldownsAllDeffensive) then
				for spellId, _ in pairs (DF.CooldownsAllDeffensive) do
					local spellName = GetSpellInfo (spellId)
					if (spellName) then
						--AUTO_TRACKING_EXTRA_BUFFS [spellName] = true
						AUTO_TRACKING_EXTRA_BUFFS [spellId] = true
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

		--> ghost aura cache
		Plater.UpdateGhostAurasCache()
	end
