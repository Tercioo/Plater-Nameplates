
local _
local addonName, platerInternal = ...
local Plater = _G.Plater

local StopSound = StopSound
local PlaySoundFile = PlaySoundFile
local GetTime = GetTime

local validChannels = {
    ["Master"] = "Master",
    ["Music"] = "Music",
    ["SFX"] = "SFX",
    ["Ambience"] = "Ambience",
    ["Dialog"] = "Dialog",
}

local defaultAudioChannel = "Master"

platerInternal.LatestTimeForAudioPlayedByID = {}

function platerInternal.Audio.GetAudioCueForSpell(spellId)
    return Plater.db.profile.cast_audiocues[spellId]
end

---player an audio cue for a cast bar
---@param spellId number
---@param audioFilePath string?
function platerInternal.Audio.PlaySoundForCastStart(spellId, audioFilePath)
    local audioCue = audioFilePath or platerInternal.Audio.GetAudioCueForSpell(spellId)
    if (audioCue) then
        local bCheckCooldown = Plater.db.profile.cast_audiocue_cooldown > 0
        if (bCheckCooldown and ((platerInternal.LatestTimeForAudioPlayedByID[spellId] or 0) + Plater.db.profile.cast_audiocue_cooldown) > GetTime()) then
            return -- do not play, was played already within the last x seconds, defined on Plater.db.profile.cast_audiocue_cooldown
        end

        if (platerInternal.LatestHandleForAudioPlayed) then
            StopSound(platerInternal.LatestHandleForAudioPlayed, 500)
        end

        local channel = validChannels[Plater.db.cast_audiocues_channel] or defaultAudioChannel
        local bWillPlay, soundHandle = PlaySoundFile(audioCue, channel)

        if (bWillPlay) then
            platerInternal.LatestHandleForAudioPlayed = soundHandle
            platerInternal.LatestTimeForAudioPlayedByID[spellId] = GetTime()
        end
    end
end

--priority for user audio >> play defined in the cast colors tab >> player defined in the script
function Plater.PlayAudioForScript(canUseScriptAudio, audioFilePath, envTable) --exposed
    --user set an audio to play into the Cast Colors tab in the options panel
    local spellId = envTable._SpellID

    --audio set in the cast colors tab, if there are an audio set there for this spell, play it
    local audioByUser = platerInternal.Audio.GetAudioCueForSpell(envTable._SpellID)
    if (audioByUser) then
        platerInternal.Audio.PlaySoundForCastStart(spellId)
        return
    end

    --audio set in the script
    if (canUseScriptAudio and audioFilePath and type(audioFilePath) == "string") then
        platerInternal.Audio.PlaySoundForCastStart(spellId, audioFilePath)
    end
end