local Plater = _G.Plater
local C_Timer = _G.C_Timer
local COMM_PLATER_PREFIX = "PLT"
local COMM_SCRIPT_GROUP_EXPORTED = "GE"

local pcall = pcall

local LibAceSerializer = LibStub:GetLibrary ("AceSerializer-3.0")
local LibDeflate = LibStub:GetLibrary ("LibDeflate")

local CONST_THROTTLE_HOOK_COMMS = 0.500 --2 comms per second per mod

function Plater.CreateCommHeader(prefix, encodedString)
    return LibAceSerializer:Serialize(prefix, UnitName("player"), GetRealmName(), UnitGUID("player"), encodedString)
end

function dispatchSendCommEvents()
	Plater.DispatchCommSendMessageHookEvents()
	C_Timer.After(CONST_THROTTLE_HOOK_COMMS, dispatchSendCommEvents)
end
dispatchSendCommEvents() -- can be done immediately

function Plater.SendComm(scriptIndex, scriptId, uniqueId, ...)
	
	if not Plater.VerifyScriptIdForComm(scriptIndex, scriptId, uniqueId) then return end -- block execution if verification fails
	
    --create the payload, the first index is always the hook id
    local arguments = {uniqueId, ...}

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
    Plater.DispatchCommReceivedMessageHookEvent(scriptUID, source, unpack(data))
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

