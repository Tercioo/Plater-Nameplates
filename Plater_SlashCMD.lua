
local Plater = Plater
local addonId, platerInternal = ...
---@type detailsframework
local DF = DetailsFramework
local _

--> cvars just to make them easier to read
local CVAR_ENABLED = "1"
local CVAR_DISABLED = "0"

--> cache some common used member strings for better reading
local MEMBER_UNITID = "namePlateUnitToken"
local MEMBER_GUID = "namePlateUnitGUID"
local MEMBER_NPCID = "namePlateNpcId"
local MEMBER_QUEST = "namePlateIsQuestObjective"
local MEMBER_REACTION = "namePlateUnitReaction"
local MEMBER_RANGE = "namePlateInRange"
local MEMBER_NOCOMBAT = "namePlateNoCombat"
local MEMBER_NAME = "namePlateUnitName"
local MEMBER_NAMELOWER = "namePlateUnitNameLower"
local MEMBER_TARGET = "namePlateIsTarget"

local LDB = LibStub ("LibDataBroker-1.1", true)
local LDBIcon = LDB and LibStub ("LibDBIcon-1.0", true)

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> slash commands ~slash

SLASH_PLATER1 = "/plater"
SLASH_PLATER2 = "/nameplate"
SLASH_PLATER3 = "/nameplates"

-- ~cvar
local cvarDiagList = {
	"nameplateMaxDistance",
	"nameplateOtherTopInset",
	"nameplateOtherAtBase",
	"nameplateMinAlpha",
	"nameplateMinAlphaDistance",
	"nameplateShowAll",
	"nameplateShowEnemies",
	"nameplateShowEnemyMinions",
	"nameplateShowEnemyMinus",
	"nameplateShowFriends",
	"nameplateShowFriendlyGuardians",
	"nameplateShowFriendlyPets",
	"nameplateShowFriendlyTotems",
	"nameplateShowFriendlyMinions",
	"NamePlateHorizontalScale",
	"NamePlateVerticalScale",
}

function SlashCmdList.PLATER (msg, editbox)

	local optionsTabNumber = tonumber(msg)
	if (optionsTabNumber) then
		Plater.OpenOptionsPanel(optionsTabNumber)
		return
	end

	if (msg == "version") then
		Plater.GetVersionInfo(true)
		return

	elseif (msg == "showlogs") then
		---@type {_general_logs: string[], _error_logs: string[]}
		local logTable = platerInternal.Logs.GetLogs()
		local generalLogs = logTable._general_logs
		local errorLogs = logTable._error_logs

		---@type string[]
		local outputTable = {}

		if (#generalLogs > 0) then
			outputTable[#outputTable+1] = "General Logs:"
			for i = 1, #generalLogs do
				outputTable[#outputTable+1] = (generalLogs[i])
			end
		end

		outputTable[#outputTable+1] = " "

		if (#errorLogs > 0) then
			outputTable[#outputTable+1] = "Error Logs:"
			for i = 1, #errorLogs do
				outputTable[#outputTable+1] = (errorLogs[i])
			end
		end

		dumpt(outputTable) --this is a function from details! too buzy right now to thing on another function
		return

	elseif (msg == "dignostico" or msg == "diag" or msg == "debug") then

		print ("Plater Diagnostic:")
		for i = 1, #cvarDiagList do
			local cvar = cvarDiagList [i]
			print ("|cFFC0C0C0" .. cvar, "|r->", GetCVar(cvar))
		end

		local alphaPlateFrame = "there's no nameplate in the screen"
		local alphaUnitFrame = ""
		local alphaHealthFrame = ""
		local testPlate

		for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
			if (plateFrame [MEMBER_REACTION] < 4) then
				testPlate = plateFrame
				alphaPlateFrame = plateFrame:GetAlpha()
				alphaUnitFrame = plateFrame.unitFrame:GetAlpha()
				alphaHealthFrame = plateFrame.unitFrame.healthBar:GetAlpha()
				break
			end
		end

		print ("|cFFC0C0C0Alpha|r", "->", alphaPlateFrame, "-", alphaUnitFrame, "-", alphaHealthFrame)

		if (testPlate) then
			local w, h = testPlate:GetSize()
			print ("|cFFC0C0C0Size|r", "->", w, h, "-", testPlate.unitFrame.healthBar:GetSize())

			local point1, anchorFrame, point2, x, y = testPlate:GetPoint (1)
			print ("|cFFC0C0C0Point|r", "->", point1, anchorFrame:GetName(), point2, x, y)

			local plateIsShown = testPlate:IsShown() and "yes" or "no"
			local unitFrameIsShown = testPlate.unitFrame:IsShown() and "yes" or "no"
			local healthBarIsShown = testPlate.unitFrame.healthBar:IsShown() and "yes" or "no"
			print ("|cFFC0C0C0ShownStatus|r", "->", plateIsShown, "-", unitFrameIsShown, "-", healthBarIsShown)
		else
			print ("|cFFC0C0C0Size|r", "-> there's no nameplate in the screen")
			print ("|cFFC0C0C0Point|r", "-> there's no nameplate in the screen")
			print ("|cFFC0C0C0ShownStatus|r", "-> there's no nameplate in the screen")
		end

		return

	elseif (msg == "color" or msg == "colors") then
		Plater.OpenColorFrame()
		return

	elseif (msg == "npcs" or msg == "ids") then



	elseif (msg == "add" or msg == "addnpc") then

		local plateFrame = C_NamePlate.GetNamePlateForUnit ("target")

		if (plateFrame) then
			local npcId = plateFrame [MEMBER_NPCID]
			if (npcId) then
				local colorDB = Plater.db.profile.npc_cache
				if (not colorDB [npcId]) then
					Plater.db.profile.npc_cache [npcId] = {plateFrame [MEMBER_NAME] or "UNKNOWN", Plater.ZoneName or "UNKNOWN", Plater.Locale or "enUS"}
					Plater:Msg ("Unit added.")

					if (PlaterOptionsPanelFrame and PlaterOptionsPanelFrame:IsShown()) then
						PlaterOptionsPanelContainerColorManagementColorsScroll:Hide()
						C_Timer.After (.2, function()
							PlaterOptionsPanelContainerColorManagementColorsScroll:Show()
						end)
					end

				else
					Plater:Msg ("Unit already added.")
				end
			else
				Plater:Msg ("Invalid npc nameplate.")
			end
		else
			Plater:Msg ("you need to target a npc or the npc nameplate couldn't be found.")
		end

		return

	elseif (msg == "rare") then
		local waitTick = function(tickerObject)
			for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
				local unitClassification = UnitClassification(plateFrame.unitFrame[MEMBER_UNITID])
				if (unitClassification == "rareelite") then
					FlashClientIcon()
					Plater:Msg("(debug) rare spawned!")
				end
			end
		end

		if (not Plater.rare_ticker) then
			Plater:Msg("Plater will flash the taskbar wow icon when a rare spawns.")
			Plater.rare_ticker = _G.C_Timer.NewTicker(3, waitTick)
		else
			Plater.rare_ticker:Cancel()
			Plater.rare_ticker = nil
			Plater:Msg("Plater stopped looking for rares.")
		end

		return

	elseif (msg == "profstart" or msg == "profstartcore" or msg == "profstartadvance") then
		Plater.EnableProfiling(true)

		return

	elseif (msg == "profstartmods") then
		Plater.EnableProfiling(false)

		return

	elseif (msg == "profstop") then
		Plater.DisableProfiling()

		return

	elseif (msg == "profprint") then
		Plater.ShowPerfData()

		return

	elseif (msg == "minimap") then
		PlaterDBChr.minimap.hide = not PlaterDBChr.minimap.hide

		if (PlaterDBChr.minimap.hide) then
			LDBIcon:Hide ("Plater")
		else
			LDBIcon:Show ("Plater")
		end
		LDBIcon:Refresh ("Plater", PlaterDBChr.minimap)

		return

	elseif (msg == "compartment") then

		if LDBIcon:IsButtonInCompartment("Plater") then
			LDBIcon:RemoveButtonFromCompartment("Plater")
		else
			LDBIcon:AddButtonToCompartment("Plater")
		end

		return

	elseif (msg and msg:find("^cvar[s]?")) then
		Plater.DebugCVars(msg:gsub("^cvar[s]? ?", ""))
		return

	elseif msg ~= "" then
		local usage = "Usage Info:"
		usage = usage .. "\n|cffffaeae/plater|r : Open the Plater options window"
		usage = usage .. "\n|cffffaeae/plater|r |cffffff33version|r: print Plater version information"
		usage = usage .. "\n|cffffaeae/plater|r |cffffff33profstart|r: Start Plater profiling"
		usage = usage .. "\n|cffffaeae/plater|r |cffffff33profstop|r: Stop Plater profiling"
		usage = usage .. "\n|cffffaeae/plater|r |cffffff33profprint|r: Print gathered profiling information"
		usage = usage .. "\n|cffffaeae/plater|r |cffffff33add|r: Adds the targeted unit to the NPC Cache"
		usage = usage .. "\n|cffffaeae/plater|r |cffffff33colors|r: Opens the Plater color palette"
		usage = usage .. "\n|cffffaeae/plater|r |cffffff33minimap|r: Toggle the Plater minimap icon"
		usage = usage .. "\n|cffffaeae/plater|r |compartment|r: Toggle the Plater addon compartment icon"
		usage = usage .. "\n|cffffaeae/plater|r |cffffff33cvar <cvar name>|r: Print information about a cvar value stored in the profile."
		usage = usage .. "\n|cffffaeaeVersion:|r |cffffff33" .. Plater.GetVersionInfo() .. "|r"
		Plater:Msg(usage)
		return

	end

	Plater.OpenOptionsPanel()
end