-- profiling support (WIP)

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
end

function Plater.DisableProfiling()
	profilingEnabled = false
	
	profData.endTime = debugprofilestop()
	
end

--pType = profiling type (e.g. hooks)
function Plater.StartLogPerformance(pType, name)
	if not profilingEnabled or not pType or not name then return end
	
	if not profData.data[pType] then
		profData.data[pType] = {}
	end
	if not profData.data[pType][name] then
		profData.data[pType][name] = {}
	end
	
	profData.data[pType][name].curStartTime = debugprofilestop()
end

--pType = profiling type (e.g. hooks)
function Plater.EndLogPerformance(pType, name)
	if not profilingEnabled or not pType or not name then return end
	
	local data = profData.data[pType][name]
	data.totalTime = (data.totalTime or 0) + (debugprofilestop() - data.curStartTime)
	data.count = (data.count or 0) + 1
	data.curStartTime = nil
end

function Plater.DumpPerformance(printOut)
	local perf = {}
	local printStr = "Plater profiling data:" .. "\n"
	
	perf.totalGlobalTime = (profData.endTime or debugprofilestop()) - (profData.startTime or debugprofilestop())
	
	local sumTimePTypes = 0
	local sumExecPTypes = 0
	for pType, data in pairs(profData.data) do
		perf[pType] = {}
		local pTypeTime = 0
		local pTypeExec = 0
		
		printStr = printStr .. pType .. ":" .. "\n"
		for name, pData in pairs(data) do
			perf[pType][name] = "avg: " .. roundTime(pData.totalTime / pData.count) .. "ms - count: " .. pData.count .. " - total: " .. roundTime(pData.totalTime) .. "ms"
			pTypeTime = pTypeTime + pData.totalTime
			pTypeExec = pTypeExec + pData.count
			printStr = printStr .. "  " .. name .. " - " .. perf[pType][name] .. "\n"
		end
		perf[pType].pTypeTime = pTypeTime
		perf[pType].pTypeExec = pTypeExec
		perf[pType].pTypeGlobalPercent = pTypeTime / perf.totalGlobalTime
		printStr = printStr .. "-> count: " .. pTypeExec .. " - time: "  .. roundTime(pTypeTime) .. "ms - %global: " .. roundPercent(perf[pType].pTypeGlobalPercent) .. "%" .. "\n"
		sumTimePTypes = sumTimePTypes + pTypeTime
		sumExecPTypes = sumExecPTypes + pTypeExec
	end
	
	perf.timeInPlaterProfile = sumTimePTypes
	perf.totalLoggedEvents = sumExecPTypes
	perf.totalAveragePerEvent = sumTimePTypes / sumExecPTypes
	perf.percentGlobalInPlater = sumTimePTypes / perf.totalGlobalTime
	printStr = printStr .. "Plater profiling totals:"
	printStr = printStr .. "  Profiling time: " .. roundTime(perf.totalGlobalTime / 100000)*100 .. "s" .. "\n"
	printStr = printStr .. "  Time in Plater: " .. roundTime(perf.timeInPlaterProfile) .. "ms" .. "\n"
	printStr = printStr .. "  Logged events: " .. perf.totalLoggedEvents .. "\n"
	printStr = printStr .. "  Average runtimetime of event: " .. roundTime(perf.totalAveragePerEvent) .. "ms" .. "\n"
	printStr = printStr .. "  % of global time: " .. roundPercent(perf.percentGlobalInPlater) .. "%" .. "\n"
	
	if ViragDevTool_AddData then
		ViragDevTool_AddData(perf,"Plater Profiling")
	end
	if printOut then
		print(printStr)
	end
	
	return perf
end