-- profiling support (WIP)

local profData
local profilingEnabled = false

function Plater.EnableProfiling()
	profilingEnabled = true
	
	profData = {}
end

function Plater.DisableProfiling()
	profilingEnabled = false
	
end

--pType = profiling type (e.g. hooks)
function Plater.StartLogPerformance(pType, name)
	if not profilingEnabled or not pType or not name then return end
	
	if not profData[pType] then
		profData[pType] = {}
	end
	if not profData[pType][name] then
		profData[pType][name] = {}
	end
	
	profData[pType][name].curStartTime = debugprofilestop()
end

--pType = profiling type (e.g. hooks)
function Plater.EndLogPerformance(pType, name)
	if not profilingEnabled or not pType or not name then return end
	
	profData[pType][name].totalTime = (profData[pType][name].totalTime or 0) + (debugprofilestop() - profData[pType][name].curStartTime)
	profData[pType][name].count = (profData[pType][name].count or 0) + 1
	profData[pType][name].curStartTime = nil
end

function Plater.DumpPerformance()
	local perf = {}
	for pType, data in pairs(profData) do
		print(pType .. ":")
		perf[pType] = {}
		for name, pData in pairs(data) do
			perf[pType][name] = "avg: " .. (pData.totalTime / pData.count) .. " - count: " .. pData.count .. " - total: " .. pData.totalTime
			print("  " .. name .. " - " .. perf[pType][name])
		end
	end
	if ViragDevTool_AddData then
		ViragDevTool_AddData(perf,"Plater Profiling")
	end
	return perf
end
