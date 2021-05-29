local Plater = _G.Plater
local DF = DetailsFramework
local COMM_PLATER_PREFIX = "PLT"
local COMM_SCRIPT_GROUP_EXPORTED = "GE"

local LibAceSerializer = LibStub:GetLibrary ("AceSerializer-3.0")

local CONST_THROTTLE_HOOK_COMMS = 0.500 --2 comms per second per hook

function Plater.CreateCommHeader(prefix, encodedString)
    return LibAceSerializer:Serialize(prefix, UnitName("player"), GetRealmName(), UnitGUID("player"), encodedString)
end

--store comms scheduled due to have sent data recently
local commScheduleCache = {}
--comm cache - store the comms recently sent
--store the [uniqueId] = GetTime() of when the comm got sent
local commSentTime = {}

local commScheduled = function(uniqueId, ...)
    local scheduleObject = commScheduleCache[uniqueId]
    local timeLastSent = commSentTime[uniqueId]

    if (not scheduleObject and not timeLastSent) then
        --first time sending this comm
        return false

    elseif (not scheduleObject and timeLastSent) then
        --no schedule but was sent recently, check how much time has elapsed
        local timeNow = GetTime()
        local expirationTime = timeLastSent + CONST_THROTTLE_HOOK_COMMS

        if (timeNow > expirationTime) then
            --good to sent again
            return false

        else
            --don't send more than 1 comm for the hook on each tick
            if (timeNow == timeLastSent) then
                return true
            end

            --comms for this hook is on cooldown, schedule to send it
            local scheduleTime = expirationTime - timeNow
            local scheduleObject = DF.Schedules.NewTimer(scheduleTime, Plater.SendComm_ScheduledCallback, uniqueId, ...)
            DF.Schedules.SetName(scheduleObject, "PlaterComm" .. uniqueId)
            commScheduleCache[uniqueId] = scheduleObject

            return true
        end

    elseif (scheduleObject and timeLastSent) then
        --trying to send a comm and the hook already has a comm scheduled
        --on this case the timer for the next comm doesn't change, only the payload is updated
        local remainingTime = scheduleObject.expireAt - GetTime()
        DF.Schedules.Cancel(scheduleObject)

        --reschedule with the updated payload
        local scheduleObject = DF.Schedules.NewTimer(remainingTime, Plater.SendComm_ScheduledCallback, uniqueId, ...)
        DF.Schedules.SetName(scheduleObject, "PlaterComm" .. uniqueId)
        commScheduleCache[uniqueId] = scheduleObject
        return true

    else
        Plater:Msg("0x541296")
    end
end

function Plater.SendComm_ScheduledCallback(uniqueId, ...)
    --remove the hook from schedule cache
    if (commScheduleCache[uniqueId]) then
        commScheduleCache[uniqueId]:Cancel()
        commScheduleCache[uniqueId] = nil
    end
    return Plater.SendComm(uniqueId, ...)
end

function Plater.SendComm(uniqueId, ...)
    --create the payload, the first index is always the hook id
    local arguments = {uniqueId, ...}

    if (commScheduled(uniqueId, ...)) then
        --this comm got scheduled for later
        return
    end

    --store the last time a comm has sent for this hook
    --this is used to avoid sending more than 1 comm per tick and measure the time of the last comm sent
    commSentTime[uniqueId] = GetTime()

    --compress the msg
    local msgEncoded = Plater.CompressData(arguments, "comm")
    if (not msgEncoded) then
        return
    end

    --create the comm header
    local header = Plater.CreateCommHeader(Plater.COMM_SCRIPT_MSG, msgEncoded)

    --send the message
    if (IsInRaid()) then
        Plater:SendCommMessage(COMM_PLATER_PREFIX, header, "RAID")

    elseif (IsInGroup()) then
        Plater:SendCommMessage(COMM_PLATER_PREFIX, header, "PARTY")
    end

    return true
end

--when received a message from a script
function Plater.MessageReceivedFromScript(prefix, source, playerRealm, playerGUID, message)

    local data = Plater.DecompressData(message, "comm")

    if (not data) then
        return
    end

    local scriptUID = tostring(data[1])
    tremove(data, 1)

    --trigger the event 'Comm Received'
    Plater.DispatchCommMessageHookEvent(scriptUID, source, unpack(data))
end


--> Plater comm handler
    Plater.CommHandler = {
        [COMM_SCRIPT_GROUP_EXPORTED] = Plater.ScriptReceivedFromGroup,
        [Plater.COMM_SCRIPT_MSG] = Plater.MessageReceivedFromScript,
    }

    function Plater:CommReceived(commPrefix, dataReceived, channel, source)
        local dataDeserialized = {LibAceSerializer:Deserialize(dataReceived)}

        local successfulDeserialize = dataDeserialized[1]

        if (not successfulDeserialize) then
            Plater:Msg("failed to deserialize a comm received.")
            return
        end

        local prefix =  dataDeserialized[2]
        local unitName = source
        local realmName = dataDeserialized[4]
        local unitGUID = dataDeserialized[5]
        local encodedData = dataDeserialized[6]

        local func = Plater.CommHandler[prefix]

        if (func) then
            local runOkay, errorMsg = pcall(func, prefix, unitName, realmName, unitGUID, encodedData)
            if (not runOkay) then
                Plater:Msg("error on something")
            end
        end
    end

    --register the comm
    Plater:RegisterComm(COMM_PLATER_PREFIX, "CommReceived")




-- ~compress ~zip ~export ~import ~deflate ~serialize
function Plater.CompressData (data, dataType)
    local LibDeflate = LibStub:GetLibrary ("LibDeflate")
    
    if (LibDeflate and LibAceSerializer) then
        local dataSerialized = LibAceSerializer:Serialize (data)
        if (dataSerialized) then
            local dataCompressed = LibDeflate:CompressDeflate (dataSerialized, {level = 9})
            if (dataCompressed) then
                if (dataType == "print") then
                    local dataEncoded = LibDeflate:EncodeForPrint (dataCompressed)
                    return dataEncoded
                    
                elseif (dataType == "comm") then
                    local dataEncoded = LibDeflate:EncodeForWoWAddonChannel (dataCompressed)
                    return dataEncoded
                end
            end
        end
    end
end


function Plater.DecompressData (data, dataType)
    local LibDeflate = LibStub:GetLibrary ("LibDeflate")
    
    if (LibDeflate and LibAceSerializer) then
        
        local dataCompressed
        
        if (dataType == "print") then
            dataCompressed = LibDeflate:DecodeForPrint (data)
            if (not dataCompressed) then
                Plater:Msg ("couldn't decode the data.")
                return false
            end

        elseif (dataType == "comm") then
            dataCompressed = LibDeflate:DecodeForWoWAddonChannel (data)
            if (not dataCompressed) then
                Plater:Msg ("couldn't decode the data.")
                return false
            end
        end
        
        local dataSerialized = LibDeflate:DecompressDeflate (dataCompressed)
        if (not dataSerialized) then
            Plater:Msg ("couldn't uncompress the data.")
            return false
        end
        
        local okay, data = LibAceSerializer:Deserialize (dataSerialized)
        if (not okay) then
            Plater:Msg ("couldn't unserialize the data.")
            return false
        end
        
        return data
    end
end

