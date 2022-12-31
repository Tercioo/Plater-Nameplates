
local Plater = _G.Plater
local C_Timer = _G.C_Timer
local addonName, platerInternal = ...
local DF = DetailsFramework

function Plater.DebugNameplate()
    return Plater.DebugTargetNameplate()
end

function Plater.DebugTargetNameplate()
    local plateFrame = C_NamePlate.GetNamePlateForUnit("target", issecure())
    if (plateFrame) then
        if (not _G.FrameInspect) then
            Plater:Msg("Please install FrameInspect addon to use this function.")
            return
        end
        _G.FrameInspect.Inspect(plateFrame)
    else
        Plater:Msg("You don't have a target or the nameplate is protected.")
            return
    end
end