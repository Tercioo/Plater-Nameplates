
local _
local addonName, platerInternal = ...

--performance units are saved at account level, they aren't exported within a profile export

--backwards compatibility with code that add performance units before plater loads its database
local performanceUnitsAddedBeforeDBLoad = {}

platerInternal.PERF_UNIT_OVERRIDES_BIT = { -- disable if this flag is set!
	["THREAT"] = 0x1,
	["CAST"] = 0x2,
	["AURA"] = 0x4,
}
platerInternal.PERF_UNIT_OVERRIDES_BITS_ALL = 0
for _, flag in pairs(platerInternal.PERF_UNIT_OVERRIDES_BIT) do
	platerInternal.PERF_UNIT_OVERRIDES_BITS_ALL = bit.bor(platerInternal.PERF_UNIT_OVERRIDES_BITS_ALL, flag)
end

Plater.PERF_UNIT_OVERRIDES_BIT = platerInternal.PERF_UNIT_OVERRIDES_BIT
Plater.PERF_UNIT_OVERRIDES_BITS_ALL = platerInternal.PERF_UNIT_OVERRIDES_BITS_ALL

Plater.AddPerformanceUnits = function(npcID, overrideFlags)
	if (type(npcID) == "number") then
		performanceUnitsAddedBeforeDBLoad[npcID] = bit.bor(tonumber(performanceUnitsAddedBeforeDBLoad[npcID]) or 0, tonumber(overrideFlags) or 0)
	end
end

Plater.RemovePerformanceUnits = function(npcID)
	if (type(npcID) == "number") then
		performanceUnitsAddedBeforeDBLoad[npcID] = nil
	end
end

Plater.PerformanceUnitsSetOverride = function(npcID, overrideFlags)
	if (type(npcID) == "number") then
		performanceUnitsAddedBeforeDBLoad[npcID] = bit.bor(tonumber(performanceUnitsAddedBeforeDBLoad[npcID]) or 0, tonumber(overrideFlags) or 0)
	end
end

Plater.PerformanceUnitsRemoveOverride = function(npcID, overrideFlags)
	if (type(npcID) == "number") then
		performanceUnitsAddedBeforeDBLoad[npcID] = bit.band(tonumber(performanceUnitsAddedBeforeDBLoad[npcID]) or 0, bit.bxor(platerInternal.PERF_UNIT_OVERRIDES_BITS_ALL, tonumber(overrideFlags) or 0))
	end
end

Plater.PerformanceUnitsGetOverride = function(npcID, overrideFlags)
	if (type(npcID) == "number") then
		return bit.band(tonumber(performanceUnitsAddedBeforeDBLoad[npcID]) or 0, bit.band(platerInternal.PERF_UNIT_OVERRIDES_BITS_ALL, tonumber(overrideFlags) or 0))
	end
end

function platerInternal.CreatePerformanceUnits(Plater)
	--store npcIds for npcs which flood the screen with nameplates and can be quickly processed
	--search .isPerformanceUnit for locations where there code for improve performance
	--unitFrame.isPerformanceUnit healthBar.isPerformanceUnit

	local perfUnits = PlaterDB.performance_units

	--list of default performance units, being in this list means they are added everytime Plater loads
	perfUnits[189707] = perfUnits[189707] == nil and true or perfUnits[189707] --chaotic essence (shadowlands season 4 raid affixes) --these are the multiple spawns from the above
	perfUnits[167999] = perfUnits[167999] == nil and true or perfUnits[167999] --Echo of Sin (shadowlands, Castle Nathria, Sire Denathrius)
	perfUnits[176920] = perfUnits[176920] == nil and true or perfUnits[176920] --Domination Arrow (shadowlands, Sanctum of Domination, Sylvanas)
	perfUnits[196642] = perfUnits[196642] == nil and true or perfUnits[196642] --Hungry Lasher (dragonflight, Algeth'ar Academy, Overgrown Ancient)
	perfUnits[211306] = perfUnits[211306] == nil and true or perfUnits[211306] --Fiery Vines (dragonflight, Amirdrassil, Tindral Sageswift)
	perfUnits[214441] = perfUnits[214441] == nil and true or perfUnits[214441] --Scorched Treant (dragonflight, Amirdrassil, Tindral Sageswift)
	perfUnits[219746] = perfUnits[219746] == nil and true or perfUnits[219746] --Silken Tomb (TWW, Nerub-ar Palace, Queen Ansurek)
	perfUnits[220626] = perfUnits[220626] == nil and true or perfUnits[220626] --Blood Parasite (TWW, Nerub-ar Palace, Broodtwister Ovi'nax)

	--transfer npcs ids directly added into Plater.PerformanceUnits table before Plater.OnInit() call
	for npcId in pairs(Plater.PerformanceUnits) do
		perfUnits[npcId] = true
	end

	--add the npc ids added before plater db loads through API calls
	for npcId, value in pairs(performanceUnitsAddedBeforeDBLoad) do
		perfUnits[npcId] = value
	end

	Plater.PerformanceUnits = perfUnits

	--setter
	Plater.AddPerformanceUnits = function (npcID, overrideFlags)
		if type(npcID) == "number" then
			Plater.PerformanceUnits[npcID] = bit.bor(tonumber(Plater.PerformanceUnits[npcID]) or 0, tonumber(overrideFlags) or 0)
		end
	end

	Plater.RemovePerformanceUnits = function (npcID)
		if type(npcID) == "number" then
			Plater.PerformanceUnits[npcID] = false
		end
	end
	
	Plater.PerformanceUnitsSetOverride = function(npcID, overrideFlags)
		if (type(npcID) == "number") then
			Plater.PerformanceUnits[npcID] = bit.bor(tonumber(Plater.PerformanceUnits[npcID]) or 0, tonumber(overrideFlags) or 0)
		end
	end
	
	Plater.PerformanceUnitsRemoveOverride = function(npcID, overrideFlags)
		if (type(npcID) == "number") then
			Plater.PerformanceUnits[npcID] = bit.band(tonumber(Plater.PerformanceUnits[npcID]) or 0, bit.bxor(platerInternal.PERF_UNIT_OVERRIDES_BITS_ALL, tonumber(overrideFlags) or 0))
		end
	end
	
	Plater.PerformanceUnitsGetOverride = function(npcID, overrideFlags)
		if (type(npcID) == "number") then
			return bit.band(tonumber(Plater.PerformanceUnits[npcID]) or 0, bit.band(platerInternal.PERF_UNIT_OVERRIDES_BITS_ALL, tonumber(overrideFlags) or 0))
		end
	end
end
