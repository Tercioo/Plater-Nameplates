
local addonName, platerInternal = ...
---@diagnostic disable-next-line: undefined-field
local Plater = _G.Plater
local GameCooltip = GameCooltip2
local detailsFramework = DetailsFramework
local _


local HOOK_NAMEPLATE_ADDED = platerInternal.VarSharing.HOOK_NAMEPLATE_ADDED
local HOOK_NAMEPLATE_CREATED = platerInternal.VarSharing.HOOK_NAMEPLATE_CREATED
local HOOK_NAMEPLATE_REMOVED = platerInternal.VarSharing.HOOK_NAMEPLATE_REMOVED
local HOOK_NAMEPLATE_UPDATED = platerInternal.VarSharing.HOOK_NAMEPLATE_UPDATED
local HOOK_TARGET_CHANGED = platerInternal.VarSharing.HOOK_TARGET_CHANGED
local HOOK_CAST_START = platerInternal.VarSharing.HOOK_CAST_START
local HOOK_CAST_UPDATE = platerInternal.VarSharing.HOOK_CAST_UPDATE
local HOOK_CAST_STOP = platerInternal.VarSharing.HOOK_CAST_STOP
local HOOK_RAID_TARGET = platerInternal.VarSharing.HOOK_RAID_TARGET
local HOOK_COMBAT_ENTER = platerInternal.VarSharing.HOOK_COMBAT_ENTER
local HOOK_COMBAT_LEAVE = platerInternal.VarSharing.HOOK_COMBAT_LEAVE
local HOOK_NAMEPLATE_CONSTRUCTOR = platerInternal.VarSharing.HOOK_NAMEPLATE_CONSTRUCTOR
local HOOK_PLAYER_POWER_UPDATE = platerInternal.VarSharing.HOOK_PLAYER_POWER_UPDATE
local HOOK_PLAYER_TALENT_UPDATE = platerInternal.VarSharing.HOOK_PLAYER_TALENT_UPDATE
local HOOK_HEALTH_UPDATE = platerInternal.VarSharing.HOOK_HEALTH_UPDATE
local HOOK_ZONE_CHANGED = platerInternal.VarSharing.HOOK_ZONE_CHANGED
local HOOK_UNITNAME_UPDATE = platerInternal.VarSharing.HOOK_UNITNAME_UPDATE
local HOOK_LOAD_SCREEN = platerInternal.VarSharing.HOOK_LOAD_SCREEN
local HOOK_PLAYER_LOGON = platerInternal.VarSharing.HOOK_PLAYER_LOGON
local HOOK_MOD_INITIALIZATION = platerInternal.VarSharing.HOOK_MOD_INITIALIZATION
local HOOK_MOD_DEINITIALIZATION = platerInternal.VarSharing.HOOK_MOD_DEINITIALIZATION
local HOOK_COMM_RECEIVED_MESSAGE = platerInternal.VarSharing.HOOK_COMM_RECEIVED_MESSAGE
local HOOK_COMM_SEND_MESSAGE = platerInternal.VarSharing.HOOK_COMM_SEND_MESSAGE
local HOOK_OPTION_CHANGED = platerInternal.VarSharing.HOOK_OPTION_CHANGED
local HOOK_MOD_OPTION_CHANGED = platerInternal.VarSharing.HOOK_MOD_OPTION_CHANGED
local HOOK_NAMEPLATE_DESTRUCTOR = platerInternal.VarSharing.HOOK_NAMEPLATE_DESTRUCTOR

local PLATER_GLOBAL_MOD_ENV = platerInternal.VarSharing.PLATER_GLOBAL_MOD_ENV
local PLATER_GLOBAL_SCRIPT_ENV = platerInternal.VarSharing.PLATER_GLOBAL_SCRIPT_ENV

--return the main db table for the script type
function Plater.GetScriptDB (scriptType)
    if (scriptType == "script") then
        return Plater.db.profile.script_data

    elseif (scriptType == "hook") then
        return Plater.db.profile.hook_data
    end
end

--if the type of a scriptObject is unknown
function Plater.GetScriptType (scriptObject)
    if (scriptObject.Hooks) then
        return "hook"
    elseif (scriptObject.SpellIds) then
        return "script"
    end
end

---retrive the script object for a selected scriptId
---@param scriptID number|string if number scriptId is the index of the script in the db table, this index can change when a script is removed
---@param scriptType string is always "script" or "hook", hooks scripts are stored in a different table, ingame they are called "Mods"
function Plater.GetScriptObject (scriptID, scriptType)
    if (type(scriptID) == "string" and scriptType == "script") then
        return platerInternal.Scripts.GetScriptObjectByName(scriptID)
    end

    if (scriptType == "script") then
        local script = Plater.db.profile.script_data [scriptID]
        if (script) then
            return script
        end

    elseif (scriptType == "hook") then
        local script = Plater.db.profile.hook_data [scriptID]
        if (script) then
            return script
        end

    end
end

function platerInternal.Scripts.AddNpcToScriptTriggers(scriptObject, npcId)
    detailsFramework.table.addunique(scriptObject.NpcNames, npcId)
    Plater.WipeAndRecompileAllScripts("script")
end

function platerInternal.Scripts.RemoveNpcFromScriptTriggers(scriptObject, npcId)
    local index = detailsFramework.table.find(scriptObject.NpcNames, npcId)
    if (index) then
        table.remove(scriptObject.NpcNames, index)
        Plater.WipeAndRecompileAllScripts("script")
    end
end

function platerInternal.Scripts.GetScriptObjectByName(scriptName)
    local allScripts = Plater.db.profile.script_data
    for i = 1, #allScripts do
        local scriptObject = allScripts[i]
        if (scriptObject.Name == scriptName) then
            return scriptObject
        end
    end
end

--add or remove a trigger without the need to pass through the scripting panel
function platerInternal.Scripts.AddSpellToScriptTriggers(scriptObject, spellId)
    detailsFramework.table.addunique(scriptObject.SpellIds, spellId)
    Plater.WipeAndRecompileAllScripts("script")
end

function platerInternal.Scripts.RemoveSpellFromScriptTriggers(scriptObject, spellId, noRecompile)
    local index = detailsFramework.table.find(scriptObject.SpellIds, spellId)
    if (index) then
        table.remove(scriptObject.SpellIds, index)

        if (not noRecompile) then
            Plater.WipeAndRecompileAllScripts("script")
        end
    end
end

function platerInternal.Scripts.DoesScriptHasTrigger(scriptObject, trigger)
    local index = detailsFramework.table.find(scriptObject.SpellIds, trigger)
    if (index) then
        return true
    end

    local index = detailsFramework.table.find(scriptObject.NpcNames, trigger)
    if (index) then
        return true
    end
end

function platerInternal.Scripts.RemoveTriggerFromScript(scriptObject, triggerId)
    local index = detailsFramework.table.find(scriptObject.SpellIds, triggerId)
    if (index) then
        table.remove(scriptObject.SpellIds, index)
        Plater.WipeAndRecompileAllScripts("script")
    end

    local index = detailsFramework.table.find(scriptObject.NpcNames, triggerId)
    if (index) then
        table.remove(scriptObject.NpcNames, index)
        Plater.WipeAndRecompileAllScripts("script")
    end
end

    function platerInternal.Scripts.RemoveTriggerFromAnyScript(triggerId)
    local scriptObject = platerInternal.Scripts.IsTriggerOnAnyScript(triggerId)
    if (scriptObject) then
        platerInternal.Scripts.RemoveTriggerFromScript(scriptObject, triggerId)
    end
end

function platerInternal.Scripts.IsTriggerOnAnyScript(triggerId)
    local allScripts = Plater.db.profile.script_data
    for i = 1, #allScripts do
        local scriptObject = allScripts[i]
        if (platerInternal.Scripts.DoesScriptHasTrigger(scriptObject, triggerId)) then
            return scriptObject
        end
    end
end

---add a trigger to a script
---@param triggerId number|string triggerId can be a npcId, npcName for NPCs or a spellId or spellName for auras and casts
---@param triggerType string|number there's 3 types of triggers: Auras, Casts and Npcs. Auras and Casts uses 'scriptObject.SpellIds' to store the triggerId and Npcs uses 'scriptObject.NpcNames'
---what define the type of trigger is the scriptObject.ScriptType, in other places of this project, triggerType can also be called scriptType
---triggerType expects: aura = 1, cast = 2, npc = 3
---@param scriptName string
---@return boolean 'true' if the trigger was added to the script, false if something went wrong
---@return string|nil message of error if the trigger wasn't added to the script
function Plater.AddTriggerToScript(triggerId, triggerType, scriptName)
    --attempt to get the scriptObject for the passed scriptName
    local scriptObject = Plater.GetScriptObject(scriptName, "script")
    if (not scriptObject) then
        return false, "script not found"
    end

    --remove the trigger from any script to avoid overlaps (a trigger can only exists in one script at time)
    platerInternal.Scripts.RemoveTriggerFromAnyScript(triggerId)

    --check the triggerType to know in what table the script will store the triggerId
    if (triggerType == 1 or triggerType == 2 or triggerType == "aura" or triggerType == "cast") then
        --aura or cast
        detailsFramework.table.addunique(scriptObject.SpellIds, triggerId)

    elseif (triggerType == 3 or triggerType == "npc") then
        --npc
        detailsFramework.table.addunique(scriptObject.NpcNames, triggerId)

    else
        return false, "invalid triggerType"
    end

    Plater.WipeAndRecompileAllScripts("script")

    return true
end

--check all triggers of all scripts for overlaps
--where a same spellId, npcName or npcId is being used by two or more scripts
--return a table with the triggerId with a index table of all scripts using that trigger
function Plater.CheckScriptTriggerOverlap()
    --store all triggers of all scripts in the format [triggerId] = {scripts using this trigger}
    local allTriggers = {
        Auras = {},
        Casts = {},
        Npcs = {},
    }

    --build the table containinf all scripts and what scripts they trigger
    for index, scriptObject in ipairs (Plater.GetAllScripts ("script")) do
        if (scriptObject.Enabled) then
            for _, spellId in ipairs (scriptObject.SpellIds) do

                if (scriptObject.ScriptType == 1) then
                    --> triggers auras
                    local triggerTable = allTriggers.Auras [spellId]
                    if (not triggerTable) then
                        allTriggers.Auras [spellId] = {scriptObject}
                    else
                        tinsert (triggerTable, scriptObject)
                    end

                elseif (scriptObject.ScriptType == 2) then
                    --> triggers cast
                    local triggerTable = allTriggers.Casts [spellId]
                    if (not triggerTable) then
                        allTriggers.Casts [spellId] = {scriptObject}
                    else
                        tinsert (triggerTable, scriptObject)
                    end

                end
            end

            for _, NpcId in ipairs (scriptObject.NpcNames) do
                local triggerTable = allTriggers.Npcs [NpcId]
                if (not triggerTable) then
                    allTriggers.Npcs [NpcId] = {scriptObject}
                else
                    tinsert (triggerTable, scriptObject)
                end
            end
        end
    end

    --> store scripts with overlap
    local scriptsWithOverlap = {
        Auras = {},
        Casts = {},
        Npcs = {},
    }

    local amount = 0

    --> check if there's more than 1 script for each trigger
    for triggerId, scriptsTable in pairs (allTriggers.Auras) do
        if (#scriptsTable > 1) then
            --overlap found
            scriptsWithOverlap.Auras [triggerId] = scriptsTable
            amount = amount + 1
        end
    end
    for triggerId, scriptsTable in pairs (allTriggers.Casts) do
        if (#scriptsTable > 1) then
            --overlap found
            scriptsWithOverlap.Casts [triggerId] = scriptsTable
            amount = amount + 1
        end
    end
    for triggerId, scriptsTable in pairs (allTriggers.Npcs) do
        if (#scriptsTable > 1) then
            --overlap found
            scriptsWithOverlap.Npcs [triggerId] = scriptsTable
            amount = amount + 1
        end
    end

    return scriptsWithOverlap, amount
end

function Plater.ScheduleHookForCombat (timerObject)
    if (timerObject.Event == "Enter Combat") then
        if (HOOK_COMBAT_ENTER.ScriptAmount > 0) then
            for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
                for i = 1, HOOK_COMBAT_ENTER.ScriptAmount do
                    local globalScriptObject = HOOK_COMBAT_ENTER [i]
                    local unitFrame = plateFrame.unitFrame
                    if not plateFrame.unitFrame.PlaterOnScreen then
                        return
                    end
                    local scriptContainer = unitFrame:ScriptGetContainer()
                    local scriptInfo = unitFrame:HookGetInfo(globalScriptObject, scriptContainer, "Enter Combat")
                    --run
                    unitFrame:ScriptRunHook (scriptInfo, "Enter Combat")
                end
            end
        end

    elseif (timerObject.Event == "Leave Combat") then
        if (HOOK_COMBAT_LEAVE.ScriptAmount > 0) then
            for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
                for i = 1, HOOK_COMBAT_LEAVE.ScriptAmount do
                    local globalScriptObject = HOOK_COMBAT_LEAVE [i]
                    local unitFrame = plateFrame.unitFrame
                    if not plateFrame.unitFrame.PlaterOnScreen then
                        return
                    end
                    local scriptContainer = unitFrame:ScriptGetContainer()
                    local scriptInfo = unitFrame:HookGetInfo(globalScriptObject, scriptContainer, "Leave Combat")
                    --run
                    unitFrame:ScriptRunHook (scriptInfo, "Leave Combat")
                end
            end
        end
    end
end