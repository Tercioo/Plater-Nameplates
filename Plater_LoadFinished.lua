
local addonId, platerInternal = ...

local Plater = Plater
---@type detailsframework
local DF = DetailsFramework
local _

--run after all Plater Nameplates files has been loaded

--store a boolean informing if a portion of the addon that is load on demand has already been loaded
platerInternal.LoadOnDemand_IsLoaded = {
	CastOptions = false,
	CastOptions_LoadFunc = platerInternal.CreateCastBarOptions,
}