
local _
local addonName, platerInternal = ...

function platerInternal.Date.GetDateForLogs()
	return date("%Y-%m-%d %H:%M:%S")
end

---get the table which can save logs and errors
---@return {_general_logs: string[], _error_logs: string[]}
function platerInternal.Logs.GetLogs()
	---@type {_general_logs: string[], _error_logs: string[]}
	local platerLogs = PlaterLogs
	if (not platerLogs) then
		PlaterLogs = { --[[GLOBAL]]
			_general_logs = {},
			_error_logs = {},
		}
		return PlaterLogs
	end

	platerLogs._error_logs = platerLogs._error_logs or {}
	platerLogs._general_logs = platerLogs._general_logs or {}
	return platerLogs
end

function platerInternal.Logs.Log(text)
	if (type(text) == "string") then
		local platerLogs = platerInternal.Logs.GetLogs()
		table.insert(platerLogs._general_logs, 1, platerInternal.Date.GetDateForLogs() .. " | " .. text)
		table.remove(platerLogs._general_logs, 20)
	end
end

function platerInternal.Logs.LogError(text)
	if (type(text) == "string") then
		local platerLogs = platerInternal.Logs.GetLogs()
		table.insert(platerLogs._error_logs, 1, platerInternal.Date.GetDateForLogs() .. " | " .. text)
		table.remove(platerLogs._error_logs, 10)
	end
end