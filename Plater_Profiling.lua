-- profiling support (WIP)

local Plater = _G.Plater
local DF = _G.DetailsFramework

local profData = {}
local profilingEnabled = false

-- helper
local function round(x)
	if not x then return nil end
	return (x + 0.5 - (x + 0.5) % 1)
end

local function roundTime(value)
	if not value then return nil end
	return round(value*100000)/100000
end

local function roundPercent(value)
	if not value then return nil end
	return round(value*10000)/10000
end


-- profiling
function Plater.EnableProfiling()
	profilingEnabled = true
	
	profData = {}
	profData.startTime = debugprofilestop()
	profData.endTime = nil
	profData.data = {}
	
	Plater:Msg("Plater started profiling.")
end

function Plater.DisableProfiling()
	if not profilingEnabled then return end
	profilingEnabled = false
	
	profData.endTime = debugprofilestop()
	
	
	Plater.DumpPerformance(true) -- for VDT mainly atm
	Plater:Msg("Plater stopped profiling.")
	
end

--pType = profiling type (e.g. hooks)
function Plater.StartLogPerformance(pType, event, subType)
	if not profilingEnabled or not pType or not event then return end
	
	if not profData.data[pType] then
		profData.data[pType] = {}
	end
	if not profData.data[pType][event] then
		profData.data[pType][event] = {}
		profData.data[pType][event].subTypeData = {}
	end
	if subType and not profData.data[pType][event].subTypeData[subType] then
		profData.data[pType][event].subTypeData[subType] = {}
	end
	
	local startTime = debugprofilestop()
	profData.data[pType][event].curStartTime = startTime
	if subType then
		profData.data[pType][event].subTypeData[subType].curStartTime = startTime
	end
end

--pType = profiling type (e.g. hooks)
function Plater.EndLogPerformance(pType, event, subType)
	if not profilingEnabled or not pType or not event then return end
	
	local data = profData.data[pType][event]
	local stopTime = debugprofilestop()
	data.totalTime = (data.totalTime or 0) + (stopTime - data.curStartTime)
	data.count = (data.count or 0) + 1
	data.curStartTime = nil
	
	if subType then
		-- add to event type as well
		data = profData.data[pType][event].subTypeData[subType]
		data.totalTime = (data.totalTime or 0) + (stopTime - data.curStartTime)
		data.count = (data.count or 0) + 1
	end
end

local function getPerfData()
	local perfTable = {}
	local indent = "    "
	local printStr = ""
	
	perfTable.totalGlobalTime = (profData.endTime or debugprofilestop()) - (profData.startTime or debugprofilestop())
	
	local sumTimePTypes = 0
	local sumExecPTypes = 0
	for pType, data in pairs(profData.data or {}) do
		perfTable[pType] = {}
		local pTypeTime = 0
		local pTypeExec = 0
		
		local printStrPType = ""
		for event, pData in pairs(data) do
			perfTable[pType][event] = {}
			perfTable[pType][event].total = "avg: " .. roundTime(pData.totalTime / pData.count) .. "ms - count: " .. pData.count .. " - total: " .. roundTime(pData.totalTime) .. "ms"
			pTypeTime = pTypeTime + pData.totalTime
			pTypeExec = pTypeExec + pData.count
			printStrPType = printStrPType .. indent .. event .. " - " .. perfTable[pType][event].total .. "\n"
			
			perfTable[pType][event]._subTypeData = {}
			local pTypeSufTime = 0
			local pTypeSufExec = 0
			printStrPType = printStrPType .. indent .. "hooks:" .. "\n"
			for subType, sufData in pairs(pData.subTypeData) do
				perfTable[pType][event]._subTypeData[subType] = "avg: " .. roundTime(sufData.totalTime / sufData.count) .. "ms - count: " .. sufData.count .. " - total: " .. roundTime(sufData.totalTime) .. "ms"
				pTypeSufTime = pTypeSufTime + sufData.totalTime
				pTypeSufExec = pTypeSufExec + sufData.count
				printStrPType = printStrPType .. indent .. indent .. subType .. " - " .. perfTable[pType][event]._subTypeData[subType] .. "\n"
			end
			perfTable[pType][event].pTypeSufTime = pTypeSufTime
			perfTable[pType][event].pTypeSufExec = pTypeSufExec
			printStrPType = printStrPType .. "\n"
		end
		perfTable[pType].pTypeTime = pTypeTime
		perfTable[pType].pTypeExec = pTypeExec
		perfTable[pType].pTypeGlobalPercent = pTypeTime / perfTable.totalGlobalTime
		sumTimePTypes = sumTimePTypes + pTypeTime
		sumExecPTypes = sumExecPTypes + pTypeExec
		
		printStr = printStr .. pType .. ":" .. "\n" .. "Total -> count: " .. pTypeExec .. " - time: "  .. roundTime(pTypeTime) .. "ms - %global: " .. roundPercent(perfTable[pType].pTypeGlobalPercent) .. "%" .. "\n\n" .. printStrPType
		
		printStr = printStr .. "\n"
	end
	
	perfTable.timeInPlaterProfile = sumTimePTypes
	perfTable.totalLoggedEvents = sumExecPTypes
	perfTable.totalAveragePerEvent = sumTimePTypes / sumExecPTypes
	perfTable.percentGlobalInPlater = sumTimePTypes / perfTable.totalGlobalTime
	local printStrHeader = ""
	--printStrHeader = printStrHeader .. "Plater profiling data:" .. "\n\n"
	printStrHeader = printStrHeader .. "Plater profiling totals:\n"
	printStrHeader = printStrHeader .. indent .. "Profiling time: " .. roundTime(perfTable.totalGlobalTime / 100000)*100 .. "s" .. "\n"
	printStrHeader = printStrHeader .. indent .. "Time in Plater: " .. roundTime(perfTable.timeInPlaterProfile) .. "ms" .. "\n"
	printStrHeader = printStrHeader .. indent .. "Logged events: " .. perfTable.totalLoggedEvents .. "\n"
	printStrHeader = printStrHeader .. indent .. "Average runtimetime of event: " .. roundTime(perfTable.totalAveragePerEvent) .. "ms" .. "\n"
	printStrHeader = printStrHeader .. indent .. "% of global time: " .. roundPercent(perfTable.percentGlobalInPlater) .. "%" .. "\n\n"
	
	printStr = printStrHeader .. printStr
	
	return perfTable, printStr
end

function Plater.DumpPerformance(noPrintOut)

	local perfTable, printStr = getPerfData()

	if ViragDevTool_AddData then
		ViragDevTool_AddData(perfTable,"Plater Profiling")
	end
	if not noPrintOut then
		print(printStr)
	end
	
	return perfTable, printStr

end

function Plater.ShowPerfData()
	local perfTable, printStr = getPerfData()
	
	if (not PlaterPerformanceProfilingResultPanel) then
		local f = CreateFrame ("frame", "PlaterPerformanceProfilingResultPanel", UIParent, "BackdropTemplate") 
		f:SetSize (800, 700)
		f:EnableMouse (true)
		f:SetMovable (true)
		f:RegisterForDrag ("LeftButton")
		f:SetScript ("OnDragStart", function() f:StartMoving() end)
		f:SetScript ("OnDragStop", function() f:StopMovingOrSizing() end)
		f:SetScript ("OnMouseDown", function (self, button) if (button == "RightButton") then f.EntryBox:ClearFocus() f:Hide() end end)
		f:SetFrameStrata ("DIALOG")
		f:SetPoint ("center", UIParent, "center", 0, 0)
		f:SetBackdrop ({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
		f:SetBackdropColor (0, 0, 0, 0.8)
		f:SetBackdropBorderColor (0, 0, 0, 1)
		tinsert (UISpecialFrames, "PlaterPerformanceProfilingResultPanel")
		
		DF:CreateTitleBar (f, "Plater Performance Profiling")
		DF:ApplyStandardBackdrop (f)
		
		local luaeditor_backdrop_color = {.2, .2, .2, .5}
		local luaeditor_border_color = {0, 0, 0, 1}
		local textField = DF:NewSpecialLuaEditorEntry (f, 775, 670, "TextField", "$parentTextField", true, false)
		textField.editbox:SetFontObject ("GameFontHighlight")
		textField:SetPoint ("top", f, "top", -10, -25)
		textField.editbox:SetEnabled(false)
		textField:SetBackdrop ({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
		textField:SetBackdropBorderColor (unpack (luaeditor_border_color))
		textField:SetBackdropColor (unpack (luaeditor_backdrop_color))
		DF:ReskinSlider (textField.scroll)
		f.TextField = textField
		
		f:Hide()
		Plater.PlaterPerformanceProfilingResultPanel = f
	end
	
	
	Plater.PlaterPerformanceProfilingResultPanel.TextField:SetText (printStr)
	
	Plater.PlaterPerformanceProfilingResultPanel:Show()
	
end