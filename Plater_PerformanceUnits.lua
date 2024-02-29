
local _
local addonName, platerInternal = ...

function platerInternal.CreatePerformanceUnits(Plater)
	--store npcIds for npcs which flood the screen with nameplates and can be quickly processed
	--search .isPerformanceUnit for locations where there code for improve performance
	--unitFrame.isPerformanceUnit healthBar.isPerformanceUnit
	Plater.PerformanceUnits = {
		--[189706] = true, --chaotic essence (shadowlands season 4 raid affixes) --this is only one single orb which casts. no need for performance
		[189707] = true, --chaotic essence (shadowlands season 4 raid affixes) --these are the multiple spawns from the above
		[167999] = true, --Echo of Sin (shadowlands, Castle Nathria, Sire Denathrius)
		[176920] = true, --Domination Arrow (shadowlands, Sanctum of Domination, Sylvanas)
		[196642] = true, --Hungry Lasher (dragonflight, Algeth'ar Academy, Overgrown Ancient)
		[211306] = true, --Fiery Vines (dragonflight, Amirdrassil, Tindral Sageswift)
		[214441] = true, --Scorched Treant (dragonflight, Amirdrassil, Tindral Sageswift)
	}

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