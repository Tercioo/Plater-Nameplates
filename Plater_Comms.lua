local Plater = _G.Plater
local C_Timer = _G.C_Timer
local addonName, platerInternal = ...
local xpcall = xpcall
local GetErrorHandler = platerInternal.GetErrorHandler
local DF = DetailsFramework
local LibAceSerializer = LibStub:GetLibrary ("AceSerializer-3.0")
local LibDeflate = LibStub:GetLibrary ("LibDeflate")
local GetSpellInfo = GetSpellInfo or function(spellID) if not spellID then return nil end local si = C_Spell.GetSpellInfo(spellID) if si then return si.name, nil, si.iconID, si.castTime, si.minRange, si.maxRange, si.spellID, si.originalIconID end end

local CONST_THROTTLE_HOOK_COMMS = 0.500 --2 comms per second per mod
local CONST_COLORNPC_SHARING_CHANNEL = "GUILD"

function Plater.CreateCommHeader(prefix, encodedString)
    return LibAceSerializer:Serialize(prefix, UnitName("player"), GetRealmName(), UnitGUID("player"), encodedString)
end

local function dispatchSendCommEvents()
	Plater.DispatchCommSendMessageHookEvents()
	C_Timer.After(CONST_THROTTLE_HOOK_COMMS, dispatchSendCommEvents)
end
dispatchSendCommEvents() -- can be done immediately

local decompressReceivedData = function(data)
	local dataCompressed = LibDeflate:DecodeForWoWAddonChannel(data)
	if (dataCompressed) then
		local dataDecompressed = LibDeflate:DecompressDeflate(dataCompressed)
		if (type(dataDecompressed) == "string") then
			return dataDecompressed
		end
	end
end

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
        Plater:SendCommMessage(Plater.COMM_PLATER_PREFIX, header, "RAID")

    elseif (IsInGroup()) then
        Plater:SendCommMessage(Plater.COMM_PLATER_PREFIX, header, "PARTY")
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
	platerInternal.Comms.CommHandler = {
        [Plater.COMM_SCRIPT_GROUP_EXPORTED] = Plater.ScriptReceivedFromGroup,
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

		if (Plater.debugcomm) then
			local stringDecompressed = decompressReceivedData(encodedData)
			local data = {strsplit(",", stringDecompressed)}
			Plater:Msg("Comm Received:", prefix, source, unpack(data))
			--dumpt(data)
			local func = platerInternal.Comms.CommHandler[prefix]
			print("prefix", prefix, "func", func)
		end

        local func = platerInternal.Comms.CommHandler[prefix]

        if (func) then
            local runOkay, errorMsg = xpcall(func, GetErrorHandler("Plater COMM error: "), prefix, unitName, realmName, unitGUID, encodedData, channel)
            if (not runOkay) then
                --Plater:Msg("error on something")
            end
        end
    end

    --register the comm
    Plater:RegisterComm(Plater.COMM_PLATER_PREFIX, "CommReceived")




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

-- ~compress ~zip ~export ~import ~deflate
function Plater.CompressDataWithoutSerialization(data, dataType)
    if (LibDeflate) then
		local dataCompressed = LibDeflate:CompressDeflate(data, {level = 9})
		if (dataCompressed) then
			if (dataType == "print") then
				local dataEncoded = LibDeflate:EncodeForPrint(dataCompressed)
				return dataEncoded

			elseif (dataType == "comm") then
				local dataEncoded = LibDeflate:EncodeForWoWAddonChannel(dataCompressed)
				return dataEncoded
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

--when an imported line is pasted in the wrong tab
--send a message telling which tab is responsible for the data
function Plater.SendScriptTypeErrorMsg(data)
    if (data and type(data) == "table") then
        if (data.type == "script") then
            Plater:Msg ("this import look like Script, try importing in the Scripting tab.")

        elseif (data.type == "hook") then
            Plater:Msg ("this import look like a Mod, try importing in the Modding tab.")

        elseif (data[Plater.Export_CastColors]) then
            Plater:Msg ("this import look like a Cast Colors, try importing in the Cast Colors tab.")

        elseif (data.NpcColor) then
            Plater:Msg ("this import looks to be a Npc Colors import, try importing in the Npc Colors tab.")

        elseif (data.plate_config) then
            Plater:Msg ("this import looks like a profile, import profiles at the Profiles tab.")
        end
    end

    Plater:Msg ("failed to import the data provided.")
end


-----------------------------------------------------------------------------------------
--npc color and rename

	local checkNpcIdIsValid = function(npcId)
		if (type(npcId) ~= "number") then
			return false
		end

		if (npcId < 1 or npcId > 500000) then
			return false
		end

		return true
	end

	local checkSpellIdIsValid = function(spellId)
		if (type(spellId) ~= "number") then
			return false
		end

		local spellName = GetSpellInfo(spellId)
		return spellName and true
	end

	local checkSpellIdIsValue = function(spellId)
		if (type(spellId) ~= "number") then
			return false
		end

		if (spellId < 1 or spellId > 600000) then
			return false
		end

		return true
	end

	local checkIfHasAssistanceOrIsLeader = function()
		--check if the player is in a raid group
		if (IsInRaid()) then
			--check if the player is the raid leader or an assistant
			if (UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")) then
				return true
			end

		--check if the player is in a party group
		elseif (IsInGroup()) then
			--check if the player is the party leader
			if (UnitIsGroupLeader("player")) then
				return true
			end
		end

		return false
	end

	local checkReceivedDataIsValid = function(unitName, channel)
		--check if the data came from the guild channel
		if (channel ~= CONST_COLORNPC_SHARING_CHANNEL) then
			return
		end

		--check if the unit that sent the data is in the same group as the player
		--UnitInParty: return if the unit is in the same party group as the player
		--UnitInRaid: return if the unit is in the same raid group as the player
		if (not UnitInRaid(unitName) and not UnitInParty(unitName)) then
			return
		end

		return true
	end

	local createImportNpcCastConfirmFrame = function()
		local frame = DF:CreateSimplePanel(UIParent, 380, 130, "Plater Nameplates: Npc or Cast Importer", "PlaterImportNpcOrCastConfirmation")
		platerInternal.Frames.ImportNpcCastConfirm = frame
		frame:Hide()
		frame:SetPoint("center", UIParent, "center", 0, 150)
		DF:ApplyStandardBackdrop(frame)

		--create the font strings to show the npc name or the cast name, npcID or spellID, Sender name, and another to show the color
		local text1 = DF:CreateLabel(frame, "Npc Name:", 12, "white", "GameFontNormal", "white")
		local text2 = DF:CreateLabel(frame, "Npc ID:", 12, "white", "GameFontNormal", "white")
		local text3 = DF:CreateLabel(frame, "Npc Zone:", 12, "white", "GameFontNormal", "white")
		local text4 = DF:CreateLabel(frame, "Sender:", 12, "white", "GameFontNormal", "white")
		local text5 = DF:CreateLabel(frame, "Color:", 12, "white", "GameFontNormal", "white")

		text1:SetPoint("topleft", frame, "topleft", 10, -30)
		text2:SetPoint("topleft", frame, "topleft", 10, -50)
		text3:SetPoint("topleft", frame, "topleft", 10,	-70)
		text4:SetPoint("topleft", frame, "topleft", 10,	-90)
		text5:SetPoint("topleft", frame, "topleft", 10,	-110)

		frame.Text1 = text1
		frame.Text2 = text2
		frame.Text3 = text3
		frame.Text4 = text4
		frame.Text5 = text5

		local declineData = function(self, button, scriptObject, senderName)
			frame:Hide()
			platerInternal.Frames.ShowImportConfirmationForNpcAndCasts()
		end

		frame.AcceptButton = Plater:CreateButton(frame, function()end, 125, 20, "Accept", -1, nil, nil, nil, nil, nil, Plater:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE"))
		frame.DeclineButton = Plater:CreateButton(frame, declineData, 125, 20, "Decline", -1, nil, nil, nil, nil, nil, Plater:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE"))

		frame.DeclineButton:SetPoint("bottomleft", frame, "bottomleft", 5, 5)
		frame.AcceptButton:SetPoint("bottomright", frame, "bottomright", -5, 5)

		local gradientBottomSide = DF:CreateTexture(frame, {gradient = "vertical", fromColor = DF.IsDragonflight() and {0, 0, 0, 0.50} or {0, 0, 0, 0.25}, toColor = "transparent"}, 1, 70, "artwork", {0, 1, 0, 1}, "gradientBottomSide")
		gradientBottomSide:SetPoint("bottoms", frame, 1, 0)

		frame.Flash = Plater.CreateFlash(frame)
	end

	local queueToAcceptDataOfNpcsOrCasts = {}

	--when received a npc rename from another player or a npc color, also cast color, name or script to use
	function platerInternal.Frames.ShowImportConfirmationForNpcAndCasts()
		--check if the import window does not exists, and create it
		if (not platerInternal.Frames.ImportNpcCastConfirm) then
			createImportNpcCastConfirmFrame()
		end

		local frame = platerInternal.Frames.ImportNpcCastConfirm
		if (frame:IsShown()) then
			frame.Title:SetText("Plater Nameplates: Npc/Cast Data Import (" .. #queueToAcceptDataOfNpcsOrCasts + 1 .. ")")
			return
		else
			frame.Title:SetText("Plater Nameplates: Npc/Cast Data Import (" .. #queueToAcceptDataOfNpcsOrCasts .. ")")
		end

		frame.Text1:SetText("")
		frame.Text2:SetText("")
		frame.Text3:SetText("")
		frame.Text4:SetText("")
		frame.Text5:SetText("")

		local nextDataToApprove = tremove(queueToAcceptDataOfNpcsOrCasts)
		if (nextDataToApprove) then
			local whichInfo = nextDataToApprove[1]

			if (whichInfo == "npccolor" or whichInfo == "npcrename" or whichInfo == "resetnpc") then
				local npcId = nextDataToApprove[2]
				local npcName = nextDataToApprove[3]
				local npcZone = nextDataToApprove[4]
				local senderName = nextDataToApprove[6]
				
				npcName = string.gsub(npcName, "@C@", ",")
				npcZone = string.gsub(npcZone, "@C@", ",")

				frame.Text1:SetText("From: " .. senderName)

				if (whichInfo == "npccolor") then
					local color = nextDataToApprove[5]
					frame.Text2:SetText("Set Npc: |cFFFFDD00" .. npcName .. "|r Color to: " .. DF:AddColorToText(color, color))

					frame.AcceptButton:SetClickFunction(function()
						--accept the data sent and add to the database
						platerInternal.Comms.AcceptNpcColor(npcId, npcName, npcZone, color)
						frame:Hide()
						platerInternal.Frames.ShowImportConfirmationForNpcAndCasts()
					end)

				elseif (whichInfo == "npcrename") then
					local newName = nextDataToApprove[5]
					newName = string.gsub(newName, "@C@", ",")
					
					frame.Text2:SetText("Rename: |cFFFFDD00" .. npcName .. "|r to: |cFFFFDD00" .. newName)

					frame.AcceptButton:SetClickFunction(function()
						--accept the data sent and add to the database
						platerInternal.Comms.AcceptNpcName(npcId, newName, npcZone)
						frame:Hide()
						platerInternal.Frames.ShowImportConfirmationForNpcAndCasts()
					end)

				elseif (whichInfo == "resetnpc") then
					frame.Text2:SetText("Remove Npc Name and Color Customizations")

					frame.AcceptButton:SetClickFunction(function()
						platerInternal.Comms.AcceptNpcReset(npcId)
						frame:Hide()
						platerInternal.Frames.ShowImportConfirmationForNpcAndCasts()
					end)
				end

				frame.Flash:Play()
				frame:Show()
				--play audio: IgPlayerInvite or igPlayerInviteDecline

			elseif (whichInfo == "castcolor" or whichInfo == "castrename" or whichInfo == "castscript" or whichInfo == "resetcast") then
				local spellId = nextDataToApprove[2] and tonumber(nextDataToApprove[2])
				if (not spellId) then
					return
				end

				local npcName = nextDataToApprove[3]
				local npcId = nextDataToApprove[4] and tonumber(nextDataToApprove[4]) or 0
				local value = nextDataToApprove[5]
				local senderName = nextDataToApprove[6]

				local spellName, _, spellIcon = GetSpellInfo(spellId)

				if (not spellName) then
					return
				end

				frame.Text1:SetText("From: " .. senderName)

				if (whichInfo == "castcolor") then
					frame.Text2:SetText("Set Spell '|cFFFFDD00" .. spellName .. "|r' color to: " .. DF:AddColorToText(value, value))

					frame.AcceptButton:SetClickFunction(function()
						platerInternal.Comms.AcceptCastDataFromComm(whichInfo, spellId, npcName, npcId, value)
						frame:Hide()
						platerInternal.Frames.ShowImportConfirmationForNpcAndCasts()
					end)

				elseif (whichInfo == "castrename") then
					frame.Text2:SetText("Set Spell '|cFFFFDD00" .. spellName .. "|r' name to: " .. value)

					frame.AcceptButton:SetClickFunction(function()
						platerInternal.Comms.AcceptCastDataFromComm(whichInfo, spellId, npcName, npcId, value)
						frame:Hide()
						platerInternal.Frames.ShowImportConfirmationForNpcAndCasts()
					end)

				elseif (whichInfo == "castscript") then
					frame.Text2:SetText("Set Spell '|cFFFFDD00" .. spellName .. "|r' to use script: " .. value)

					frame.AcceptButton:SetClickFunction(function()
						platerInternal.Comms.AcceptCastDataFromComm(whichInfo, spellId, npcName, npcId, value)
						frame:Hide()
						platerInternal.Frames.ShowImportConfirmationForNpcAndCasts()
					end)

				elseif (whichInfo == "resetcast") then
					frame.Text2:SetText("Remove Spell Name, Color and Scripts Customizations")

					frame.AcceptButton:SetClickFunction(function()
						platerInternal.Comms.AcceptCastDataFromComm(whichInfo, spellId, npcName, npcId, value)
						frame:Hide()
						platerInternal.Frames.ShowImportConfirmationForNpcAndCasts()
					end)
				end

				frame.Flash:Play()
				frame:Show()
			end
		else
			frame:Hide()
		end
	end

	--@npcId: number
	--@npcName: string
	--@npcZone: string
	--@color: string
	function platerInternal.Comms.AcceptNpcColor(npcId, npcName, npcZone, color)
		local npcColorTable = Plater.db.profile.npc_colors[npcId] --{[1] = is enabled, [2] = is script only, [3] = color name}
		if (npcColorTable) then
			npcColorTable[1] = true
			npcColorTable[2] = false
			npcColorTable[3] = color
		else
			--the color isn't in the database yet: add the color into the npc_colors database
			Plater.db.profile.npc_colors[npcId] = {true, false, color}
		end

		--check if the npc_cache has the npc name and zone, if not add them to the database
		if (not Plater.db.profile.npc_cache[npcId]) then
			Plater.db.profile.npc_cache[npcId] = {npcName, npcZone}
		end

		--refresh the colors
		Plater.RefreshDBLists()
		Plater.UpdateAllNameplateColors()
		Plater.ForceTickOnAllNameplates()
	end

	--accept the npc name, this is similar to AcceptNpcColor but the data is different
	function platerInternal.Comms.AcceptNpcName(npcId, npcName, npcZone)
		--check if the npc_cache has the npc name and zone, if not add them to the database
		if (not Plater.db.profile.npc_cache[npcId]) then
			Plater.db.profile.npc_cache[npcId] = {npcName, npcZone}
			Plater.TranslateNPCCache()
		end

		local npcsRenamed = Plater.db.profile.npcs_renamed
		if (npcName == "") then
			npcsRenamed[npcId] = nil
		else
			npcsRenamed[npcId] = npcName
		end

		Plater.RefreshDBLists()
		Plater.UpdateAllNameplateColors()
		Plater.UpdateAllPlates()
		Plater.ForceTickOnAllNameplates()
	end

	function platerInternal.Comms.AcceptNpcReset(npcId)
		--reset npc name
		Plater.db.profile.npcs_renamed[npcId] = nil

		--reset npc color
		local colorDB = Plater.db.profile.npc_colors
		local npcColorTable = colorDB[npcId]
		if (npcColorTable) then
			npcColorTable[1] = false
			npcColorTable[2] = false
			npcColorTable[3] = "white"
		end

		Plater.RefreshDBLists()
		Plater.UpdateAllNameplateColors()
		Plater.UpdateAllPlates()
		Plater.ForceTickOnAllNameplates()
	end

	function platerInternal.Comms.AcceptCastDataFromComm(whichInfo, spellId, npcName, npcId, value)
		local castColorTable = Plater.db.profile.cast_colors[spellId] --{[1] = is enabled, [2] = color, [3] = renamed cast name}

		if (whichInfo == "castcolor") then
			local color = value
			if (not DF:IsHtmlColor(color)) then
				return
			end
			platerInternal.Data.SetSpellColorData(spellId, color)

		elseif (whichInfo == "castrename") then
			platerInternal.Data.SetSpellRenameData(spellId, value)

		elseif (whichInfo == "castscript") then
			local scriptName = value
			local scriptObject = platerInternal.Scripts.GetScriptObjectByName(scriptName)
			if (scriptObject) then
				platerInternal.Scripts.RemoveTriggerFromAnyScript(spellId)
				platerInternal.Scripts.AddSpellToScriptTriggers(scriptObject, spellId)
			end
			Plater.WipeAndRecompileAllScripts("script")

		elseif (whichInfo == "resetcast") then
			if (castColorTable) then
				castColorTable[1] = false
				castColorTable[2] = "white"
				castColorTable[3] = ""
			end

			--refresh the colors
			Plater.RefreshDBLists()
			Plater.UpdateAllNameplateColors()
			Plater.ForceTickOnAllNameplates()

			--reset script
			local scriptObject = platerInternal.Scripts.GetDefaultScriptForSpellId(spellId)
			if (scriptObject) then
				platerInternal.Scripts.RemoveTriggerFromAnyScript(spellId)
				platerInternal.Scripts.AddSpellToScriptTriggers(scriptObject, spellId)

				Plater.WipeAndRecompileAllScripts("script")
			end
		end

		--check if the captured_casts has the spell name and icon, if not add them to the database
		if (not Plater.db.profile.captured_casts[spellId]) then
			Plater.db.profile.captured_casts[spellId] = {npcID = npcId, source = npcName}
		end

		--refresh the colors
		Plater.RefreshDBLists()
		Plater.UpdateAllNameplateColors()
		Plater.ForceTickOnAllNameplates()

		PlaterOptionsPanelContainerCastColorManagementColorFrame.RefreshScroll(0)
	end

	function platerInternal.Comms.OnReceiveNpcOrCastInfoFromGroup(prefix, unitName, realmName, unitGUID, encodedData, channel)
		if (not checkReceivedDataIsValid(unitName, channel)) then
			return
		end

		local stringDecompressed = decompressReceivedData(encodedData)
		if (not stringDecompressed) then
			return
		end

		local data = {strsplit(",", stringDecompressed)}

		local whichInfo = data[1]
		local ID = data[2] and tonumber(data[2]) --npcId or spellId

		if (type(ID) ~= "number" or ID < 1 or ID > 1000000) then
			return
		end

		local autoAccept = data[5] and tonumber(data[5])
		local bAutoAccept = (autoAccept == 1) and not Plater.db.profile.opt_out_auto_accept_npc_colors
		if (bAutoAccept) then
			if (not UnitIsGroupAssistant(unitName) and not UnitIsGroupLeader(unitName)) then
				return
			end
		end

		local value = data[6] --all values are strings

		if (whichInfo == "castcolor" or whichInfo == "castrename" or whichInfo == "castscript" or whichInfo == "resetcast") then
			local spellId = ID
			local npcName = data[3]
			local npcId = data[4] and tonumber(data[4]) or 0

			--check integrity of the data
			if (type(spellId) ~= "number" or type(npcName) ~= "string" or type(npcId) ~= "number" or type(autoAccept) ~= "number" or type(value) ~= "string") then
				return
			end

			if (whichInfo == "castcolor") then
				local color = value
				if (not DF:IsHtmlColor(color)) then
					return
				end

				if (bAutoAccept) then
					platerInternal.Comms.AcceptCastDataFromComm(whichInfo, spellId, npcName, npcId, color)
				else
					tinsert(queueToAcceptDataOfNpcsOrCasts, {"castcolor", spellId, npcName, npcId, color, unitName})
					platerInternal.Frames.ShowImportConfirmationForNpcAndCasts()
				end

				return

			elseif (whichInfo == "castrename") then
				local customSpellName = value

				if (bAutoAccept) then
					platerInternal.Comms.AcceptCastDataFromComm(whichInfo, spellId, npcName, npcId, customSpellName)
				else
					tinsert(queueToAcceptDataOfNpcsOrCasts, {"castrename", spellId, npcName, npcId, customSpellName, unitName})
					platerInternal.Frames.ShowImportConfirmationForNpcAndCasts()
					return
				end

			elseif (whichInfo == "castscript") then
				local scriptName = value

				if (bAutoAccept) then
					platerInternal.Comms.AcceptCastDataFromComm(whichInfo, spellId, npcName, npcId, scriptName)
				else
					tinsert(queueToAcceptDataOfNpcsOrCasts, {"castscript", spellId, npcName, npcId, scriptName, unitName})
					platerInternal.Frames.ShowImportConfirmationForNpcAndCasts()
					return
				end

			elseif (whichInfo == "resetcast") then
				if (bAutoAccept) then
					platerInternal.Comms.AcceptCastDataFromComm(whichInfo, spellId, npcName, npcId, "")
				else
					tinsert(queueToAcceptDataOfNpcsOrCasts, {"resetcast", spellId, npcName, npcId, "", unitName})
					platerInternal.Frames.ShowImportConfirmationForNpcAndCasts()
					return
				end
			end

			Plater.RefreshDBLists()
			Plater.UpdateAllNameplateColors()
			Plater.ForceTickOnAllNameplates()

		elseif (whichInfo == "npccolor" or whichInfo == "npcrename" or whichInfo == "resetnpc") then
			local npcId = ID
			local npcName = data[3]
			local npcZone = data[4]

			--check integrity of the data
			if (type(npcId) ~= "number" or type(npcName) ~= "string" or type(npcZone) ~= "string" or type(autoAccept) ~= "number" or type(value) ~= "string") then
				return
			end

			if (whichInfo == "npccolor") then
				local color = value
				if (not DF:IsHtmlColor(color)) then
					return
				end

				if (bAutoAccept) then
					platerInternal.Comms.AcceptNpcColor(npcId, npcName, npcZone, color)
				else
					tinsert(queueToAcceptDataOfNpcsOrCasts, {"npccolor", npcId, npcName, npcZone, color, unitName})
					platerInternal.Frames.ShowImportConfirmationForNpcAndCasts()
					return
				end

			elseif (whichInfo == "npcrename") then
				if (bAutoAccept) then
					platerInternal.Comms.AcceptNpcName(npcId, value, npcZone)
				else
					tinsert(queueToAcceptDataOfNpcsOrCasts, {"npcrename", npcId, npcName, npcZone, value, unitName})
					platerInternal.Frames.ShowImportConfirmationForNpcAndCasts()
					return
				end

			elseif (whichInfo == "resetnpc") then
				if (bAutoAccept) then
					platerInternal.Comms.AcceptNpcReset(npcId)
				else
					tinsert(queueToAcceptDataOfNpcsOrCasts, {"resetnpc", npcId, npcName, npcZone, "", unitName})
					platerInternal.Frames.ShowImportConfirmationForNpcAndCasts()
					return
				end
			end

			Plater.RefreshDBLists()
			Plater.UpdateAllNameplateColors()
			Plater.ForceTickOnAllNameplates()
		end
	end

	platerInternal.Comms.CommHandler[Plater.COMM_NPC_OR_CAST_CUSTOMIZATION] = platerInternal.Comms.OnReceiveNpcOrCastInfoFromGroup

	--send npc info to group

	local routineCheckToSendDataToGroup = function(npcId, autoAccept, whichInfo)
		if (not IsInGroup()) then
			Plater:Msg("not in group.")
			return
		end

		if (not IsInGuild()) then
			Plater:Msg("not in a guild.")
			return
		end

		if (not checkIfHasAssistanceOrIsLeader()) then
			Plater:Msg("does not have assist or leader.")
			return
		end

		if (whichInfo:find("npc")) then
			if (not checkNpcIdIsValid(npcId)) then
				Plater:Msg("npcId invalid.")
				return
			end
		end

		if (whichInfo:find("cast")) then
			if (not checkSpellIdIsValid(npcId)) then
				Plater:Msg("spellId invalid.")
				return
			end
		end

		if (type(autoAccept) ~= "boolean") then
			Plater:Msg("autoAccept must be a boolean.")
			return
		end

		return true
	end

	--get the npcInfo from the npc_cache, return it if it's valid or nil if it's not
	local getNpcNameAndZone = function(npcId)
		local npcInfo = Plater.db.profile.npc_cache[npcId]
		if (not npcInfo) then
			return
		end

		local npcName = npcInfo[1]
		local npcZone = npcInfo[2]

		if (type(npcName) ~= "string" or type(npcZone) ~= "string") then
			return
		end

		return npcName, npcZone
	end

	--called from the GameCooltip menu after clicking in the Send To Raid button
	function platerInternal.Comms.SendNpcInfoToGroup(buttonClicked, npcId, autoAccept, whichInfo)
		GameCooltip:Hide()

		if (not routineCheckToSendDataToGroup(npcId, autoAccept, whichInfo)) then
			return
		end

		local npcName, npcZone = getNpcNameAndZone(npcId)
		if (not npcName) then
			Plater:Msg("npcInfo not found.")
			return
		end
		
		npcName = string.gsub(npcName, ",", "@C@")
		npcZone = string.gsub(npcZone, ",", "@C@")

		local dataToSend

		if (whichInfo == "npccolor") then
			local npcColorTable = Plater.db.profile.npc_colors[npcId]
			local npcColorName = npcColorTable and npcColorTable[3]

			if (not npcColorName or type(npcColorName) ~= "string") then
				Plater:Msg("npc does not have a color.")
				return
			end

			dataToSend = whichInfo .. "," .. npcId .. "," .. npcName .. "," .. npcZone .. "," .. (autoAccept and "1" or "0") .. "," .. npcColorName

		elseif (whichInfo == "npcrename") then
			local npcNameRenamed = Plater.db.profile.npcs_renamed[npcId]
			if (not npcNameRenamed or type(npcNameRenamed) ~= "string") then
				Plater:Msg("npc does not have a custom name.")
				return
			end
			
			npcNameRenamed = string.gsub(npcNameRenamed, ",", "@C@")

			dataToSend = whichInfo .. "," .. npcId .. "," .. npcName .. "," .. npcZone .. "," .. (autoAccept and "1" or "0") .. "," .. npcNameRenamed

		elseif (whichInfo == "resetnpc") then
			--reset to the local player as well
			Plater.db.profile.npcs_renamed[npcId] = nil
			Plater.db.profile.npc_colors[npcId] = nil
			PlaterOptionsPanelContainerColorManagement.RefreshScroll(0)
			Plater.RefreshDBLists()
			Plater.UpdateAllNameplateColors()
			Plater.ForceTickOnAllNameplates()

			dataToSend = whichInfo .. "," .. npcId .. "," .. npcName .. "," .. npcZone .. "," .. (autoAccept and "1" or "0") .. "," .. "reset"
		end

		local encodedString = Plater.CompressDataWithoutSerialization(dataToSend, "comm")
		--send to guild, the receiver will check if the player is in the group
		Plater:SendCommMessage(Plater.COMM_PLATER_PREFIX, LibAceSerializer:Serialize(Plater.COMM_NPC_OR_CAST_CUSTOMIZATION, UnitName("player"), GetRealmName(), UnitGUID("player"), encodedString), CONST_COLORNPC_SHARING_CHANNEL)
	end

	function platerInternal.Comms.SendCastInfoToGroup(buttonClicked, spellId, autoAccept, whichInfo)
		GameCooltip:Hide()

		if (not routineCheckToSendDataToGroup(spellId, autoAccept, whichInfo)) then
			return
		end

		local spellName, _, spellIcon = GetSpellInfo(spellId)
		if (not spellName) then
			Plater:Msg("spellId invalid.")
			return
		end

		local dataToSend

		local capturedCasts = PlaterDB.captured_casts
		local thisCastInfo = capturedCasts[spellId] or {}

		if (whichInfo == "castcolor") then
			local castColorTable = Plater.db.profile.cast_colors[spellId]
			--the index 2 of the castColorTable is the custom color of the cast
			if (castColorTable and type(castColorTable) == "table" and type(castColorTable[2]) == "string" and castColorTable[2] ~= "white") then
				dataToSend = whichInfo .. "," .. spellId .. "," .. (thisCastInfo.source or "") .. "," .. (thisCastInfo.npcID or "") .. "," .. (autoAccept and "1" or "0") .. "," .. castColorTable[2]
			else
				Plater:Msg("cast does not have a color.")
				return
			end

		elseif (whichInfo == "castrename") then
			local castColorTable = Plater.db.profile.cast_colors[spellId]
			--index 3 of the castColorTable is the custom name of the cast
			if (castColorTable and type(castColorTable) == "table" and type(castColorTable[3]) == "string" and castColorTable[3] ~= "") then
				dataToSend = whichInfo .. "," .. spellId .. "," .. (thisCastInfo.source or "") .. "," .. (thisCastInfo.npcID or "") .. "," .. (autoAccept and "1" or "0") .. "," .. castColorTable[3]
			else
				Plater:Msg("cast does not have a custom name.")
				return
			end

		elseif (whichInfo == "castscript") then
			local scriptObject = platerInternal.Scripts.GetDefaultScriptForSpellId(spellId)
			if (not scriptObject) then
				return
			end

			dataToSend = whichInfo .. "," .. spellId .. "," .. (thisCastInfo.source or "") .. "," .. (thisCastInfo.npcID or "") .. "," .. (autoAccept and "1" or "0") .. "," .. scriptObject.Name

		elseif (whichInfo == "resetcast") then
			--reset cast information on the local player as well
			Plater.db.profile.cast_colors[spellId] = nil
			PlaterOptionsPanelContainerColorManagement.RefreshScroll(0)
			platerInternal.Scripts.RemoveTriggerFromAnyScript(spellId)
			Plater.RefreshDBLists()
			Plater.UpdateAllNameplateColors()
			Plater.ForceTickOnAllNameplates()

			dataToSend = whichInfo .. "," .. spellId .. "," .. (thisCastInfo.source or "") .. "," .. (thisCastInfo.npcID or "") .. "," .. (autoAccept and "1" or "0") .. "," .. "reset"
		end

		local encodedString = Plater.CompressDataWithoutSerialization(dataToSend, "comm")
		--send to guild, the receiver will check if the player is in the group
		Plater:SendCommMessage(Plater.COMM_PLATER_PREFIX, LibAceSerializer:Serialize(Plater.COMM_NPC_OR_CAST_CUSTOMIZATION, UnitName("player"), GetRealmName(), UnitGUID("player"), encodedString), CONST_COLORNPC_SHARING_CHANNEL)
	end