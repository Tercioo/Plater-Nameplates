
local addonId, platerInternal = ...

local Plater = Plater
---@type detailsframework
local DF = DetailsFramework
local _

--run after all Plater Nameplates files has been loaded

--store a boolean informing if a portion of the addon that is loaded on demand has already been loaded
---@type table<string, boolean>
platerInternal.LoadOnDemand_IsLoaded = {
	CastOptions = false,
	SearchOptions = false,
	AdvancedOptions = false,
	BossModOptions = false,
}

---@type table<string, function>
platerInternal.LoadOnDemand_LoadFunc = {
	CastOptions = platerInternal.CreateCastBarOptions,
	SearchOptions = platerInternal.CreateSearchOptions,
	AdvancedOptions = platerInternal.CreateAdvancedOptions,
	BossModOptions = platerInternal.CreateBossModOptions,
}