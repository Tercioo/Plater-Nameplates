

local Plater = _G.Plater
local DF = DetailsFramework
local _

local IS_WOW_PROJECT_MAINLINE = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
local IS_WOW_PROJECT_NOT_MAINLINE = WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE
local IS_WOW_PROJECT_CLASSIC_ERA = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
local IS_WOW_PROJECT_CLASSIC_TBC = WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC

Plater.Auras.GhostAuras = {}

function Plater.Auras.GhostAuras.GetPlayerSpecInfo()
    local specId
    local specName
    local specIndex
    local _, playerClass = UnitClass("player")

    if (IS_WOW_PROJECT_MAINLINE) then --retail
        specIndex = GetSpecialization()
        if (specIndex) then
            specId, specName = GetSpecializationInfo(specIndex)
        end
    end

    return specIndex, specId, specName, playerClass
end

function Plater.Auras.GhostAuras.GetAuraListForCurrentSpec()
    local specIndex, specId, specName, playerClass = Plater.Auras.GhostAuras.GetPlayerSpecInfo()

    --get the aura list from db, format: [spellId] = true
    local profile = Plater.db.profile
    local auraList = profile.ghost_auras.auras[playerClass][specIndex]

    return auraList
end

function Plater.Auras.GhostAuras.AddGhostAura(spellId)
    local auraList = Plater.Auras.GhostAuras.GetAuraListForCurrentSpec()
    auraList[spellId] = true
end

function Plater.Auras.GhostAuras.RemoveGhostAura(spellId)
    local auraList = Plater.Auras.GhostAuras.GetAuraListForCurrentSpec()
    auraList[spellId] = nil
end

--return a list of spell names that contain in the player spellbook
--[spellName] = true
--working on retail
function Plater.Auras.GhostAuras.GetSpellBookSpells()
    local spellNamesInSpellBook = {}

    for i = 1, GetNumSpellTabs() do
        local tabName, tabTexture, offset, numSpells, isGuild, offspecId = GetSpellTabInfo(i)

        if (offspecId == 0) then
            offset = offset + 1
            local tabEnd = offset + numSpells

            for j = offset, tabEnd - 1 do
                local spellType, spellId = GetSpellBookItemInfo(j, "player")

                if (spellId) then
                    if (spellType ~= "FLYOUT") then
                        local spellName = GetSpellInfo(spellId)
                        if (spellName) then
                            spellNamesInSpellBook[spellName] = true
                        end
                    else
                        local _, _, numSlots, isKnown = GetFlyoutInfo(spellId)
                        if (isKnown and numSlots > 0) then
                            for k = 1, numSlots do
                                local spellID, overrideSpellID, isKnown = GetFlyoutSlotInfo(spellId, k)
                                if (isKnown) then
                                    local spellName = GetSpellInfo(spellID)
                                    spellNamesInSpellBook[spellName] = true
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    return spellNamesInSpellBook
end
