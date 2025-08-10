

local Plater = _G.Plater
local DF = DetailsFramework
local _

local IS_WOW_PROJECT_MAINLINE = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
local IS_WOW_PROJECT_NOT_MAINLINE = WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE
local IS_WOW_PROJECT_CLASSIC_ERA = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
local IS_WOW_PROJECT_CLASSIC_WRATH = IS_WOW_PROJECT_NOT_MAINLINE and ClassicExpansionAtLeast and LE_EXPANSION_WRATH_OF_THE_LICH_KING and ClassicExpansionAtLeast(LE_EXPANSION_WRATH_OF_THE_LICH_KING)
local IS_WOW_PROJECT_CLASSIC_MOP = IS_WOW_PROJECT_NOT_MAINLINE and ClassicExpansionAtLeast and LE_EXPANSION_MISTS_OF_PANDARIA and ClassicExpansionAtLeast(LE_EXPANSION_MISTS_OF_PANDARIA)

local GetSpecialization = C_SpecializationInfo and C_SpecializationInfo.GetSpecialization or GetSpecialization
local GetSpecializationInfo = C_SpecializationInfo and C_SpecializationInfo.GetSpecializationInfo or GetSpecializationInfo

Plater.Auras.GhostAuras = {}

function Plater.Auras.GhostAuras.GetPlayerSpecInfo()
    local specId
    local specName
    local specIndex = 0 --fallback for TBC
    local _, playerClass = UnitClass("player")

    if (IS_WOW_PROJECT_MAINLINE or IS_WOW_PROJECT_CLASSIC_MOP) then --retail or mop, where api is available
        specIndex = GetSpecialization()
        if (specIndex) then
            specId, specName = GetSpecializationInfo(specIndex)
        end
    end

    return specIndex, specId, specName, playerClass
end

function Plater.Auras.GhostAuras.GetAuraListForCurrentSpec()
    local specIndex, specId, specName, playerClass = Plater.Auras.GhostAuras.GetPlayerSpecInfo()
    
    if not playerClass or not specIndex then return nil end

    --get the aura list from db, format: [spellId] = true
    local profile = Plater.db.profile
    local auraList = profile.ghost_auras.auras[playerClass][specIndex]
    
    if not auraList then --fallback create for spec if needed
        profile.ghost_auras.auras[playerClass][specIndex] = {}
        auraList = profile.ghost_auras.auras[playerClass][specIndex]
    end

    return auraList
end

function Plater.Auras.GhostAuras.AddGhostAura(spellId)
    local auraList = Plater.Auras.GhostAuras.GetAuraListForCurrentSpec()
    auraList[spellId] = true
    Plater.UpdateGhostAurasCache()
end

function Plater.Auras.GhostAuras.RemoveGhostAura(spellId)
    local auraList = Plater.Auras.GhostAuras.GetAuraListForCurrentSpec()
    auraList[spellId] = nil
    Plater.UpdateGhostAurasCache()
end

--refresh caches when spec changes
local specChangeFrame = CreateFrame("frame")
if IS_WOW_PROJECT_MAINLINE then
    specChangeFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
else
    --specChangeFrame:RegisterEvent("CHARACTER_POINTS_CHANGED") --not needed for TBC/Classic, as there is no spec differences in the config, just class.
end
specChangeFrame:SetScript("OnEvent", function(self, event, ...)
    Plater.RefreshAuraCache()
    Plater.UpdateAuraCache()

    local ghostAurasOptionsFrame = _G.PlaterOptionsPanelContainerGhostAurasFrame
    if (ghostAurasOptionsFrame) then
        if (ghostAurasOptionsFrame:IsShown()) then
            Plater.Auras.GhostAuras.SetSpec()
        end
    end
end)