
local _
local addonName, platerInternal = ...

--performance units are saved at account level, they aren't exported within a profile export

--backwards compatibility with code that add performance units before plater loads its database
local performanceUnitsAddedBeforeDBLoad = {}

Plater.AddPerformanceUnits = function(npcID)
	if (type(npcID) == "number") then
		performanceUnitsAddedBeforeDBLoad[npcID] = true
	end
end

Plater.RemovePerformanceUnits = function(npcID)
	if (type(npcID) == "number") then
		performanceUnitsAddedBeforeDBLoad[npcID] = nil
	end
end

function platerInternal.CreatePerformanceUnits(Plater)
	--store npcIds for npcs which flood the screen with nameplates and can be quickly processed
	--search .isPerformanceUnit for locations where there code for improve performance
	--unitFrame.isPerformanceUnit healthBar.isPerformanceUnit

	local perfUnits = PlaterDB.performance_units

	--list of default performance units, being in this list means they are added everytime Plater loads
	perfUnits[189707] = true --chaotic essence (shadowlands season 4 raid affixes) --these are the multiple spawns from the above
	perfUnits[167999] = true --Echo of Sin (shadowlands, Castle Nathria, Sire Denathrius)
	perfUnits[176920] = true --Domination Arrow (shadowlands, Sanctum of Domination, Sylvanas)
	perfUnits[196642] = true --Hungry Lasher (dragonflight, Algeth'ar Academy, Overgrown Ancient)
	perfUnits[211306] = true --Fiery Vines (dragonflight, Amirdrassil, Tindral Sageswift)
	perfUnits[214441] = true --Scorched Treant (dragonflight, Amirdrassil, Tindral Sageswift)

	--transfer npcs ids directly added into Plater.PerformanceUnits table before Plater.OnInit() call
	for npcId in pairs(Plater.PerformanceUnits) do
		perfUnits[npcId] = true
	end

	--add the npc ids added before plater db loads through API calls
	for npcId in pairs(performanceUnitsAddedBeforeDBLoad) do
		perfUnits[npcId] = true
	end

	Plater.PerformanceUnits = perfUnits

	--setter
	Plater.AddPerformanceUnits = function (npcID)
		if type(npcID) == "number" then
			Plater.PerformanceUnits[npcID] = true
		end
	end

	Plater.RemovePerformanceUnits = function (npcID)
		if type(npcID) == "number" then
			Plater.PerformanceUnits[npcID] = nil
		end
	end
end
