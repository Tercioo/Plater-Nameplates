
local _
local addonName, platerInternal = ...
local Plater = _G.Plater

local StopSound = StopSound
local PlaySoundFile = PlaySoundFile

local validChannels = {
    ["Master"] = "Master",
    ["Music"] = "Music",
    ["SFX"] = "SFX",
    ["Ambience"] = "Ambience",
    ["Dialog"] = "Dialog",
}

local defaultAudioChannel = "Master"

---player an audio cue for a cast bar
---@param spellId number
function platerInternal.Audio.PlaySoundForCastStart(spellId)
    local audioCue = Plater.db.profile.cast_audiocues[spellId]
    if (audioCue) then
        if (platerInternal.LatestHandleForAudioPlayed) then
            StopSound(platerInternal.LatestHandleForAudioPlayed, 0.5)
        end

        local channel = validChannels[Plater.db.cast_audiocues_channel] or defaultAudioChannel
        local willPlay, soundHandle = PlaySoundFile(audioCue, channel)

        if (willPlay) then
            platerInternal.LatestHandleForAudioPlayed = soundHandle
        end
    end
end
