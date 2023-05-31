-- profiling support (WIP)

local Plater = _G.Plater
local FPSData = Plater.FPSData
local DF = _G.DetailsFramework
local C_Timer = _G.C_Timer
local debugprofilestop = debugprofilestop

local loggedEvents = {}
local profStartTime = 0
local profEndTime = 0
local profilingEnabled = false
local everyFrameLogSkipFirst = true

local PRT_INDENT = "    "

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
	return round(value*1000)/1000
end

local function getFPSValuesFromTimes(times)
	local values = {}
	if not times then return values end
	
	for _, ftime in pairs(times) do
		tinsert(values, round(1000/ftime))
	end
	
	return values
end

local function getAverageTime(times)
	local sum = 0;
	if not times then return sum end
	for _, v in pairs(times) do
		sum = sum + v
	end
	return sum / #times
end

local function getModeTime(times, dec)
	if not times then return 0, 0, 0 end
	local tmpData = {}
	for _, v in pairs(times or {}) do
		v = round(v * (dec or 1000))/(dec or 1000)
		tmpData[v] = (tmpData[v] or 0) + 1
	end
	
	local val, amount = 0, 0
	for k, v in pairs(tmpData) do
		if v > amount then
			amount = v
			val = k
		end
	end
	return val, amount, #times
end

local function getMedianTime(times)
	local med = 0
	if times and (#times > 0) then
		table.sort(times)
		med = times[math.ceil(#times/2)]
	end
	return med
end

local function getMinMax(times)
	local min, max = 9999999, 0
	for _, v in pairs(times) do
		if v < min then min = v end
		if v > max then max = v end
	end
	return min, max
end


-- profiling
local function everyFrameEventLog()
	if not profilingEnabled then
		PlaterDBChr.perfEventLog = nil -- reset this.
		return
	end
	
	C_Timer.After( 0, everyFrameEventLog )
	
	if everyFrameLogSkipFirst then
		everyFrameLogSkipFirst = false
	end
	
	local curTime = debugprofilestop()
	tinsert(loggedEvents, {pType = "Game-Core", event = "Frame Tick", subType = "Frame Tick Internal", timestamp = curTime, startEvent = false, endEvent = false, isFrameTick = true, curFPS = FPSData.curFPS})
end
C_Timer.After( 0, everyFrameEventLog )

function Plater.StartLogPerformance()
end
function Plater.StartLogPerformanceCore()
end
local function StartLogPerformance(pType, event, subType)
	if not profilingEnabled or not pType or not event or not subType then return end	
	
	local startTime = debugprofilestop()
	tinsert(loggedEvents, {pType = pType, event = event, subType = subType, timestamp = startTime, startEvent = true, endEvent = false, curFPS = FPSData.curFPS})
end

function Plater.EndLogPerformance()
end
function Plater.EndLogPerformanceCore()
end
local function EndLogPerformance(pType, event, subType)
	if not profilingEnabled or not pType or not event or not subType then return end
	
	local stopTime = debugprofilestop()
	tinsert(loggedEvents, {pType = pType, event = event, subType = subType, timestamp = stopTime, startEvent = false, endEvent = true, curFPS = FPSData.curFPS})
end

function Plater.EnableProfiling(core)
	profilingEnabled = true
	
	profStartTime = debugprofilestop()
	profEndTime = nil
	
	loggedEvents = {}
	
	Plater.StartLogPerformance = StartLogPerformance
	Plater.EndLogPerformance = EndLogPerformance
	
	if core then
		Plater.StartLogPerformanceCore = StartLogPerformance
		Plater.EndLogPerformanceCore = EndLogPerformance
	end
	
	everyFrameLogSkipFirst = true
	C_Timer.After( 0, everyFrameEventLog )
	
	Plater:Msg("Plater started profiling.")
end

function Plater.DisableProfiling()
	if not profilingEnabled then return end
	profilingEnabled = false
	
	profEndTime = debugprofilestop()
	
	Plater.StartLogPerformance = function() end
	Plater.EndLogPerformance = function() end
	
	Plater.StartLogPerformanceCore = function() end
	Plater.EndLogPerformanceCore = function() end
	
	--Plater.DumpPerformance(true) -- for VDT mainly atm
	Plater:Msg("Plater stopped profiling.")
	
	if PlaterPerformanceProfilingResultPanel and PlaterPerformanceProfilingResultPanel:IsVisible() then
		Plater.ShowPerfData()
	end
end

local function getAdvancedPerfData()
	local profData = {}
	profData.data = {}
	profData.fpsValues = {}
	profData.fpsTimes = {}
	local prevEventStack = {}
	local prevEventForType = {}
	
	--consolidate events
	for _, logEntry in pairs(loggedEvents) do
		--{pType, event, subType, timestamp, startEvent, endEvent}
		
		local curPTypeData = profData.data[logEntry.pType]
		if not curPTypeData then
			profData.data[logEntry.pType] = {}
			profData.data[logEntry.pType].eventData = {}
			curPTypeData = profData.data[logEntry.pType]
		end
		
		local curEventData = curPTypeData.eventData[logEntry.event]
		if not curEventData then
			curPTypeData.eventData[logEntry.event] = {}
			curPTypeData.eventData[logEntry.event].subTypeData = {}
			curPTypeData.eventData[logEntry.event].times = {}
			curPTypeData.eventData[logEntry.event].fpsValues = {}
			curEventData = curPTypeData.eventData[logEntry.event]
		end
		
		local curSubTypeData = curEventData.subTypeData[logEntry.subType]
		if not curSubTypeData then
			curEventData.subTypeData[logEntry.subType] = {}
			curEventData.subTypeData[logEntry.subType].times = {}
			curEventData.subTypeData[logEntry.subType].fpsValues = {}
			curSubTypeData = curEventData.subTypeData[logEntry.subType]
		end

		
		if logEntry.startEvent then
			tinsert(prevEventStack, logEntry)
			curEventData.startTime = logEntry.timestamp
			
			if #prevEventStack == 1 then
				curEventData.curStartTime = logEntry.timestamp
			end
			
			curSubTypeData.curStartTime = logEntry.timestamp
			curSubTypeData.curFPS = logEntry.curFPS
			
			tinsert(profData.fpsValues, logEntry.curFPS)
			
		elseif logEntry.endEvent then
			local prevLogEntry = tremove(prevEventStack)
			
			curEventData.count = (curEventData.count or 0) + 1
			
			local stopTime = logEntry.timestamp
			local curSTime = (stopTime - prevLogEntry.timestamp)
			local curETime
			if #prevEventStack == 0 then
				curETime = (stopTime - curEventData.curStartTime)
				profData.totalTimeInPlater = (profData.totalTimeInPlater or 0) + curETime
				curEventData.totalTime = (curEventData.totalTime or 0) + (stopTime - prevLogEntry.timestamp)
				tinsert(curEventData.times, curETime)
				curEventData.curStartTime = nil

			else
				curETime = (stopTime - curSubTypeData.curStartTime)
				curEventData.subLogTime = (curEventData.subLogTime or 0) + curETime
				curEventData.totalTime = (curEventData.totalTime or 0) + curETime
				tinsert(curEventData.times, curETime)
			end
			
			curSubTypeData.curStartTime = nil
			
			tinsert(curSubTypeData.times, curSTime)
			
			-- add to event subType
			curSubTypeData.totalTime = (curSubTypeData.totalTime or 0) + curSTime
			curSubTypeData.count = (curSubTypeData.count or 0) + 1
			
			-- min/max values
			if (curSubTypeData.minTime or 9999999) > curSTime then
				curSubTypeData.minTime = curSTime
			end
			if (curSubTypeData.maxTime or 0) < curSTime then
				curSubTypeData.maxTime = curSTime
			end
			
			if (curEventData.minTime or 9999999) > curETime then
				curEventData.minTime = curETime
			end
			if (curEventData.maxTime or 0) < curETime then
				curEventData.maxTime = curETime
			end
			
			
		elseif logEntry.isFrameTick then
			local key = "FrameTick_Internal"
			local lastTime = prevEventForType[key] and prevEventForType[key].timestamp
			if lastTime then -- ignore start to first frame
				local curETime = logEntry.timestamp - lastTime
				
				curEventData.subTypeData = {} -- don't want this
				
				curEventData.count = (curEventData.count or 0) + 1
				curEventData.totalTime = (curEventData.totalTime or 0) + curETime
				
				tinsert(curEventData.times, curETime)
				tinsert(profData.fpsTimes, curETime)
				
				if (curEventData.minTime or 9999999) > curETime then
					curEventData.minTime = curETime
				end
				if (curEventData.maxTime or 0) < curETime then
					curEventData.maxTime = curETime
				end
			end
			
			prevEventForType[key] = logEntry
		else
			--single event (ping), no timeframe -> count from last event.
			local key = (logEntry.pType or "") .. "-|-" .. (logEntry.event or "") .. "-|-" .. (logEntry.subType or "")
			local lastTime = prevEventForType[key] and prevEventForType[key].timestamp or profStartTime
			local curETime = logEntry.timestamp - lastTime
			
			curEventData.totalTime = (curEventData.totalTime or 0) + curETime
			curEventData.count = (curEventData.count or 0) + 1
			curSubTypeData.totalTime = (curSubTypeData.totalTime or 0) + curETime
			curSubTypeData.count = (curSubTypeData.count or 0) + 1
			curSubTypeData.curFPS = logEntry.curFPS
			
			tinsert(curEventData.times, curETime)
			tinsert(curSubTypeData.times, curETime)
			
			-- min/max values
			if (curSubTypeData.minTime or 9999999) > curETime then
				curSubTypeData.minTime = curETime
			end
			if (curSubTypeData.maxTime or 0) < curETime then
				curSubTypeData.maxTime = curETime
			end
			if (curEventData.minTime or 9999999) > curETime then
				curEventData.minTime = curETime
			end
			if (curEventData.maxTime or 0) < curETime then
				curEventData.maxTime = curETime
			end
			
			prevEventForType[key] = logEntry
		end
	end
	
	if ViragDevTool_AddData then
		--ViragDevTool_AddData(profData,"Plater Profiling TMP Data")
		--ViragDevTool_AddData(prevEventStack,"Plater Profiling TMP Data - Stack")
	end
	
	
	local perfTable = {}
	local printStr = ""
	local sumTimePTypes = 0
	local sumExecPTypes = 0
	local totalGlobalTime = (profEndTime or debugprofilestop()) - (profStartTime or debugprofilestop())
	
	--do sort
	local dataKeys = {}
	for k in pairs(profData.data) do table.insert(dataKeys, k) end
	table.sort(dataKeys)
	
	for _, dataKey in pairs(dataKeys) do
		local pType, data = dataKey, profData.data[dataKey]

		perfTable[pType] = {}
		local pTypeTime = 0
		local pTypeExec = 0
		local pTypeSubLog = 0		
		local printStrPType = ""
		
		--do sort
		local eventKeys = {}
		for k in pairs(data.eventData) do table.insert(eventKeys, k) end
		table.sort(eventKeys)
		
		for _, eventKey in pairs(eventKeys) do
			local event, pData = eventKey, data.eventData[eventKey]
			perfTable[pType][event] = {}
			pData.count = pData.count or 0
			local modeVal, modeAmount, modeTotal = getModeTime(pData.times) 
			local modeData = roundTime(modeVal).." ("..modeAmount.."/"..modeTotal..")"
			perfTable[pType][event].total =  "count: " .. pData.count .. " - total: " .. roundTime(pData.totalTime) .. "ms - (direct: " .. roundTime(pData.totalTime - (pData.subLogTime or 0)) .. "ms, sub-log: " .. roundTime(pData.subLogTime or 0) .. "ms)\n" .. "min/max/avg/med/mod (ms): " .. roundTime(pData.minTime) .. " / " .. roundTime(pData.maxTime) .. " / " .. roundTime(pData.totalTime / pData.count) .. " / " .. roundTime(getMedianTime(pData.times)) .. " / " .. modeData
			pTypeTime = pTypeTime + pData.totalTime
			pTypeSubLog = pTypeSubLog + (pData.subLogTime or 0)
			pTypeExec = pTypeExec + pData.count
			printStrPType = printStrPType .. PRT_INDENT .. event .. ":" .. "\n" .. PRT_INDENT .. PRT_INDENT .. "Total:\n" .. PRT_INDENT .. PRT_INDENT .. PRT_INDENT .. string.gsub(perfTable[pType][event].total, "\n", "\n" .. PRT_INDENT .. PRT_INDENT .. PRT_INDENT) .. "\n\n"
			
			perfTable[pType][event]._subTypeData = {}
			local pTypeSufTime = 0
			local pTypeSufExec = 0
			if pData.subTypeData and #pData.subTypeData > 0 then printStrPType = printStrPType .. PRT_INDENT .. PRT_INDENT .. "Sub-Events:" .. "\n" end
			
			--do sort
			local subTypeDataKeys = {}
			for k in pairs(pData.subTypeData) do table.insert(subTypeDataKeys, k) end
			table.sort(subTypeDataKeys)
			for _, sufDataKey in pairs(subTypeDataKeys) do
				local subType, sufData = sufDataKey, pData.subTypeData[sufDataKey]
				if sufData.totalTime then -- sanity check for bad data
					local modeVal, modeAmount, modeTotal = getModeTime(sufData.times) 
					local modeData = roundTime(modeVal).." ("..modeAmount.."/"..modeTotal..")"
					perfTable[pType][event]._subTypeData[subType] = "count: " .. sufData.count .. " - total: " .. roundTime(sufData.totalTime) .. "ms\n" .. "min/max/avg/med/mod (ms): " .. roundTime(sufData.minTime) .. " / " .. roundTime(sufData.maxTime) .. " / " .. roundTime(sufData.totalTime / sufData.count) .. " / " .. roundTime(getMedianTime(sufData.times)) .. " / " .. modeData
					pTypeSufTime = pTypeSufTime + sufData.totalTime
					pTypeSufExec = pTypeSufExec + sufData.count
					printStrPType = printStrPType .. PRT_INDENT .. PRT_INDENT .. PRT_INDENT .. subType .. "\n"
					printStrPType = printStrPType .. PRT_INDENT .. PRT_INDENT .. PRT_INDENT .. PRT_INDENT .. string.gsub(perfTable[pType][event]._subTypeData[subType], "\n", "\n" .. PRT_INDENT .. PRT_INDENT .. PRT_INDENT .. PRT_INDENT)  .. "\n\n"
				else
					printStrPType = printStrPType .. PRT_INDENT .. PRT_INDENT .. PRT_INDENT .. subType .. " - ERROR - NO TOTAL LOGGED\n\n"
				end
			end
			perfTable[pType][event].pTypeSufTime = pTypeSufTime
			perfTable[pType][event].pTypeSufExec = pTypeSufExec
			
			printStrPType = printStrPType .. "\n"
		end
		perfTable[pType].pTypeTime = pTypeTime
		perfTable[pType].pTypeExec = pTypeExec
		perfTable[pType].pTypeSubLog = pTypeSubLog
		perfTable[pType].pTypeGlobalPercent = pTypeTime / totalGlobalTime * 100
		perfTable[pType].pTypeGlobalPercentDirect = (pTypeTime - pTypeSubLog) / totalGlobalTime * 100
		perfTable[pType].pTypeGlobalPercentSubLog = pTypeSubLog / totalGlobalTime * 100
		sumTimePTypes = sumTimePTypes + pTypeTime
		sumExecPTypes = sumExecPTypes + pTypeExec
		
		printStr = printStr .. pType .. ":" .. "\n" .. PRT_INDENT .. "Total -> count: " .. pTypeExec .. " - time: "  .. roundTime(pTypeTime) .. "ms (direct: " .. roundTime(pTypeTime - pTypeSubLog) .. "ms/" .. roundPercent(perfTable[pType].pTypeGlobalPercentDirect) .. "%, sub-log: " .. roundTime(pTypeSubLog) .. "ms/" .. roundPercent(perfTable[pType].pTypeGlobalPercentSubLog) .. "%)" .. "\n\n" .. printStrPType
		
		printStr = printStr .. "\n"
	end
	
	local fpsValues = getFPSValuesFromTimes(profData.fpsTimes) --profData.fpsValues
	local fpsAverage = getAverageTime(fpsValues)
	local minFPS, maxFPS = getMinMax(fpsValues)
	local medFPS = getMedianTime(fpsValues)
	local modeVal, modeAmount, modeTotal = getModeTime(fpsValues, 10) 
	local modFPS = round(modeVal*10)/10 .." ("..modeAmount.."/"..modeTotal..")"
	
	perfTable.timeInPlaterProfile = (profData.totalTimeInPlater or 0) --sumTimePTypes
	perfTable.totalLoggedEvents = sumExecPTypes
	perfTable.totalAveragePerEvent = perfTable.timeInPlaterProfile / sumExecPTypes
	perfTable.percentGlobalInPlater = perfTable.timeInPlaterProfile / totalGlobalTime * 100
	local printStrHeader = ""
	printStrHeader = printStrHeader .. "Plater profiling totals:\n"
	printStrHeader = printStrHeader .. PRT_INDENT .. "Profiling time: " .. roundTime(totalGlobalTime / 100000)*100 .. "s" .. "\n"
	printStrHeader = printStrHeader .. PRT_INDENT .. "Time in Plater: " .. roundTime(perfTable.timeInPlaterProfile) .. "ms" .. "\n"
	printStrHeader = printStrHeader .. PRT_INDENT .. "Logged events: " .. perfTable.totalLoggedEvents .. "\n"
	printStrHeader = printStrHeader .. PRT_INDENT .. "Average runtimetime of event: " .. roundTime(perfTable.totalAveragePerEvent) .. "ms" .. "\n"
	printStrHeader = printStrHeader .. PRT_INDENT .. "% of global time: " .. roundPercent(perfTable.percentGlobalInPlater) .. "%" .. "\n"
	printStrHeader = printStrHeader .. PRT_INDENT .. "FPS (min/max/avg/med/mod): " .. round(minFPS*10)/10 .. " / " .. round(maxFPS*10)/10 .. " / " .. round(fpsAverage*10)/10 .. " / " .. round(medFPS*10)/10 .. " / " .. modFPS .. "\n\n"
	
	printStr = printStrHeader .. printStr
	
	printStr = printStr .. "Plater Version: " .. Plater.GetVersionInfo()
	
	return perfTable, printStr
end

function Plater.DumpPerformance(noPrintOut)

	local perfTable, printStr = getAdvancedPerfData()

	if ViragDevTool_AddData then
		ViragDevTool_AddData(perfTable,"Plater Profiling Data")
		ViragDevTool_AddData(loggedEvents,"Plater Profiling - Logged-Events")
	end
	if not noPrintOut then
		print(printStr)
	end
	
	return perfTable, printStr

end

local function createResultsPanel()
	local f = CreateFrame ("frame", "PlaterPerformanceProfilingResultPanel", UIParent, "BackdropTemplate") 
	f:SetSize (900, 700)
	f:EnableMouse (true)
	f:SetMovable (true)
	f:RegisterForDrag ("LeftButton")
	f:SetScript ("OnDragStart", function() f:StartMoving() end)
	f:SetScript ("OnDragStop", function() f:StopMovingOrSizing() end)
	f:SetScript ("OnMouseDown", function (self, button) if (button == "RightButton") then f.TextField:ClearFocus() f:Hide() end end)
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
	local textField = DF:NewSpecialLuaEditorEntry (f, 875, 670, "TextField", "$parentTextField", true, false)
	textField.editbox:SetFontObject ("GameFontHighlight")
	textField:SetPoint ("top", f, "top", -10, -25)
	--textField.editbox:SetEnabled(false)
	textField:SetBackdrop ({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
	textField:SetBackdropBorderColor (unpack (luaeditor_border_color))
	textField:SetBackdropColor (unpack (luaeditor_backdrop_color))
	DF:ReskinSlider (textField.scroll)
	f.TextField = textField
	
	f:Hide()
	Plater.PlaterPerformanceProfilingResultPanel = f
end

function Plater.ShowPerfData()
	local perfTable, printStr = getAdvancedPerfData()
	
	if (not PlaterPerformanceProfilingResultPanel) then
		createResultsPanel()
	end
	
	Plater.PlaterPerformanceProfilingResultPanel.TextField:SetText (printStr)
	
	Plater.PlaterPerformanceProfilingResultPanel:Show()
	
end

function Plater.ShowPerfDataSpec()
	local perfTable, printStr = getAdvancedPerfData()
	
	if (not PlaterPerformanceProfilingResultPanel) then
		createResultsPanel()
	end
	
	Plater.PlaterPerformanceProfilingResultPanel.TextField:SetText (printStr)
	
	Plater.PlaterPerformanceProfilingResultPanel:Show()
	
end

function Plater.StoreEventLogData()
	local eventLogData = {}
	for _, event in pairs(loggedEvents) do
		if event.startEvent then
			tinsert(eventLogData, '\n    {"ph":"B","name":"' .. event.pType .. " - " .. event.event .. " - " .. event.subType .. '","ts":' .. (event.timestamp * 1000) .. ',"pid":0}')
		elseif event.endEvent then
			tinsert(eventLogData, '\n    {"ph":"E","name":"' .. event.pType .. " - " .. event.event .. " - " .. event.subType .. '","ts":' .. (event.timestamp * 1000) .. ',"pid":0}')
		else
			tinsert(eventLogData, '\n    {"ph":"I","name":"vsync","ts":'..(event.timestamp * 1000)..',"pid":1}')
		end
	end
	
	local eventLogStr = "[" .. table.concat(eventLogData, ",") .. "]"
	
	PlaterDBChr.perfEventLog = eventLogStr
	
	ReloadUI()
end