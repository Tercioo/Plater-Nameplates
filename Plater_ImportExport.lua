
local Plater = Plater
local addonId, platerInternal = ...
---@type detailsframework
local DF = DetailsFramework
local _

local time = time

local LibAceSerializer = LibStub:GetLibrary("AceSerializer-3.0")

--import scripts from the library
--autoImportScript is a table holding the revision number, the string to import and the type of script
function Plater.ImportScriptsFromLibrary()
    if (PlaterScriptLibrary) then
        for name, autoImportScript in pairs(PlaterScriptLibrary) do
            local importedDB

            if (autoImportScript.ScriptType == "script") then
                importedDB = Plater.db.profile.script_auto_imported

            elseif (autoImportScript.ScriptType == "hook") then
                importedDB = Plater.db.profile.hook_auto_imported
            end

            if ((importedDB [name] or 0) < autoImportScript.Revision) then
                importedDB [name] = autoImportScript.Revision

                local encodedString = autoImportScript.String
                if (encodedString) then
                    local success, scriptAdded, wasEnabled = Plater.ImportScriptString(encodedString, true, autoImportScript.OverrideTriggers, false, false)
                    if (success) then
                        if (autoImportScript.Revision == 1) then
                            Plater:Msg("New Script Installed: " .. name)
                        else
                            Plater:Msg("Applied Update to Script: " .. name)
                        end

                        --all scripts imported are enabled by default, if the import object has a enabled member, probably its value is false
                        if (type(autoImportScript.Enabled) == "boolean") then
                            scriptAdded.Enabled = wasEnabled == nil and autoImportScript.Enabled or wasEnabled or false
                        end
                    end
                end
            end
        end

        --can't wipe because it need to be reused when a new profile is created
        --table.wipe(PlaterScriptLibrary)
    end
end

-- migrate imports to string-based indexes
function Plater.MigrateScriptModImport(indexScriptTable)
    local newindexScriptTable = {}

    if not indexScriptTable or type(indexScriptTable) ~= "table" then
        return newindexScriptTable
    end

    -- generate a keys list and a tmpTable with all string keys
    for k,v in pairs(indexScriptTable) do
        newindexScriptTable[k .. ""] = v
    end

    -- if index 2 or 5 are empty, fill them(icons for mods/scripts)
    if not newindexScriptTable["2"] then
        --newindexScriptTable["2"] = 134400
    end
    if not newindexScriptTable["5"] then
        --newindexScriptTable["5"] = 134400
    end

    --print(DF.table.dump(newindexScriptTable))
    return newindexScriptTable
end

--merge/clean up user options
function Plater.UpdateOptionsForModScriptImport(scriptObjectNew, scriptObjectOld)
    if not scriptObjectNew or not scriptObjectOld then return end

    --consistency/init:
    scriptObjectNew.OptionsValues = scriptObjectNew.OptionsValues or {}
    scriptObjectNew.Options = scriptObjectNew.Options or {}
    scriptObjectOld.OptionsValues = scriptObjectOld.OptionsValues or {}

    local newUserOptions = scriptObjectNew.OptionsValues
    local newOptions = scriptObjectNew.Options
    local oldUserOptions = scriptObjectOld.OptionsValues

    for i = 1, #newOptions do
        local newOption = newOptions[i]
        if newOption.Key and oldUserOptions[newOption.Key] then
            newUserOptions[newOption.Key] = oldUserOptions[newOption.Key]
        end
    end
end

--import a string from any source with more options than the convencional importer
--this is used when importing scripts from the library and when the user inserted the wrong script type in the import box at hook or script, e.g. imported a hook in the script import box
--guarantee to always receive a 'print' type of encode
function Plater.ImportScriptString(text, ignoreRevision, overrideTriggers, showDebug, keepExisting)
    if (not text or type(text) ~= "string") then
        return
    end

    local errortext, objectAdded, wasEnabled

    local indexScriptTable = Plater.DecompressData(text, "print")
    if (indexScriptTable and type(indexScriptTable) == "table") then

        indexScriptTable = Plater.MigrateScriptModImport(indexScriptTable)

        --get the script type, if is a hook or regular script
        local scriptType = Plater.GetDecodedScriptType(indexScriptTable)
        local newScript = Plater.BuildScriptObjectFromIndexTable(indexScriptTable, scriptType)

        if (newScript) then
            if (scriptType == "script") then
                local scriptName = newScript.Name
                local alreadyExists = false
                local scriptDB = Plater.GetScriptDB(scriptType)

                if not keepExisting then
                    for i = 1, #scriptDB do
                        local scriptObject = scriptDB [i]
                        if (scriptObject.Name == scriptName) then
                            --the script already exists
                            if (not ignoreRevision) then
                                if (scriptObject.Revision >= newScript.Revision) then
                                    if (showDebug) then
                                        Plater:Msg("Your version of this script is newer or is the same version.")
                                        return false
                                    end
                                end
                            end

                            --by not overriding it'll drop the new triggers and use triggers of the old script that got replaced
                            if (type(overrideTriggers) == "boolean" and not overrideTriggers) then
                                if (newScript.ScriptType == 0x1 or newScript.ScriptType == 0x2) then
                                    --aura or cast trigger
                                    newScript.SpellIds = {}
                                    for index, trigger in ipairs(scriptObject.SpellIds) do
                                        DF.table.addunique(newScript.SpellIds, trigger)
                                    end
                                else
                                    --npc trigger
                                    newScript.NpcNames = {}
                                    for index, trigger in ipairs(scriptObject.NpcNames) do
                                        DF.table.addunique(newScript.NpcNames, trigger)
                                    end
                                end

                            elseif (type(overrideTriggers) == "boolean" and overrideTriggers) then
                                --ignore the old triggers

                            --this will use the old triggers and the new ones
                            elseif (type(overrideTriggers) == "string" and overrideTriggers == "merge") then
                                if (newScript.ScriptType == 0x1 or newScript.ScriptType == 0x2) then
                                    --aura or cast trigger
                                    for index, trigger in ipairs(scriptObject.SpellIds) do
                                        DF.table.addunique(newScript.SpellIds, trigger)
                                    end
                                else
                                    --npc trigger
                                    for index, trigger in ipairs(scriptObject.NpcNames) do
                                        DF.table.addunique(newScript.NpcNames, trigger)
                                    end
                                end
                            end

                            --keep the enabled state
                            wasEnabled = scriptObject.Enabled
                            --carry the enabled state from user
                            newScript.Enabled = scriptObject.Enabled

                            Plater.UpdateOptionsForModScriptImport(newScript, scriptObject)

                            --replace the old script with the new one
                            local oldScript = scriptDB[i]
                            if (oldScript) then
                                --move it to trash
                                oldScript.__TrashAt = time()
                                table.insert(Plater.db.profile.script_data_trash, oldScript)
                            end

                            table.remove(scriptDB, i)
                            table.insert(scriptDB, i, newScript)
                            objectAdded = newScript

                            if (showDebug) then
                                Plater:Msg("Script replaced by a newer version.")
                            end

                            alreadyExists = true
                            break
                        end
                    end
                end

                if (not alreadyExists) then
                    table.insert(scriptDB, newScript)
                    objectAdded = newScript
                    if (showDebug) then
                        Plater:Msg("Script added.")
                    end
                end

            elseif (scriptType == "hook") then
                local scriptName = newScript.Name
                local alreadyExists = false
                local scriptDB = Plater.GetScriptDB(scriptType)

                if not keepExisting then
                    for i = 1, #scriptDB do
                        local scriptObject = scriptDB [i]
                        if (scriptObject.Name == scriptName) then
                            --the script already exists
                            if (not ignoreRevision) then
                                if (scriptObject.Revision >= newScript.Revision) then
                                    if (showDebug) then
                                        Plater:Msg("Your version of this script is newer or is the same version.")
                                        return false
                                    end
                                end
                            end

                            --keep the enabled state
                            wasEnabled = scriptObject.Enabled
                            newScript.Enabled = scriptObject.Enabled

                            Plater.UpdateOptionsForModScriptImport(newScript, scriptObject)

                            --replace the old script with the new one
                            local oldScript = scriptDB[i]
                            if (oldScript) then
                                --move it to trash
                                oldScript.__TrashAt = time()
                                table.insert(Plater.db.profile.hook_data_trash, oldScript)
                            end

                            --replace the old script with the new one
                            table.remove(scriptDB, i)
                            table.insert(scriptDB, i, newScript)
                            objectAdded = newScript

                            if (showDebug) then
                                Plater:Msg("Mod replaced by a newer version.")
                            end

                            alreadyExists = true
                            break
                        end
                    end
                end

                if (not alreadyExists) then
                    table.insert(scriptDB, newScript)
                    objectAdded = newScript
                    if (showDebug) then
                        Plater:Msg("Script added.")
                    end
                end
            end
        else
            --check if the user in importing a profile in the scripting tab
            if (indexScriptTable.plate_config) then
                DF:ShowErrorMessage("Invalid Script or Mod.\n\nImport profiles at the Profiles tab.")
            elseif (indexScriptTable.NpcColor) then
                DF:ShowErrorMessage("Invalid Script or Mod.\n\nImport NpcColors at the Npc Colors tab.")
            end
            errortext = "Cannot import: data imported is invalid"
        end
    else
        errortext = "Cannot import: data imported is invalid"
    end

    if (errortext and showDebug) then
        Plater:Msg(errortext)
        return false
    end

    if objectAdded then
        return true, objectAdded, wasEnabled
    else
        return false
    end
end

--transform the string into a indexScriptTable and then transform it into a scriptObject
function Plater.DecodeImportedString(str) --not in use?(can't find something calling this - tercio)
    local LibAceSerializer = LibStub:GetLibrary("AceSerializer-3.0")
    if (LibAceSerializer) then
        -- ~zip
        local decoded = DF.DecodeString(str)
        if (decoded) then
            local unSerializedOkay, indexScriptTable = LibAceSerializer:Deserialize(decoded)
            if (unSerializedOkay and type(indexScriptTable) == "table") then
                local scriptObject = Plater.BuildScriptObjectFromIndexTable(indexScriptTable, Plater.GetDecodedScriptType(indexScriptTable))
                if (scriptObject) then
                    return scriptObject
                end
            end
        end
    end
end

--function Plater.PrepareTableToExportStringIndexes(scriptObject)
function Plater.PrepareTableToExport(scriptObject)
    if (scriptObject.Hooks) then
        --script for hooks
        local tableToExport = {}

        tableToExport ["1"] = scriptObject.Name
        tableToExport ["2"] = scriptObject.Icon
        tableToExport ["3"] = scriptObject.Desc
        tableToExport ["4"] = scriptObject.Author
        tableToExport ["5"] = scriptObject.Time
        tableToExport ["6"] = scriptObject.Revision
        tableToExport ["7"] = scriptObject.PlaterCore
        tableToExport ["8"] = scriptObject.LoadConditions
        tableToExport ["9"] = {}

        for hookName, hookCode in pairs(scriptObject.Hooks) do
            tableToExport ["9"] [hookName] = hookCode
        end

        tableToExport ["options"] = scriptObject.Options or {}

        tableToExport ["addon"] = "Plater"
        tableToExport ["tocversion"] = select(4, GetBuildInfo()) -- provide export toc
        tableToExport ["type"] = "hook"
        tableToExport ["UID"] = scriptObject.UID

        return tableToExport
    else
        --regular script for aura cast or unitID
        local tableToExport = {}

        tableToExport ["1"] = scriptObject.ScriptType
        tableToExport ["2"] = scriptObject.Name
        tableToExport ["3"] = scriptObject.SpellIds
        tableToExport ["4"] = scriptObject.NpcNames
        tableToExport ["5"] = scriptObject.Icon
        tableToExport ["6"] = scriptObject.Desc
        tableToExport ["7"] = scriptObject.Author
        tableToExport ["8"] = scriptObject.Time
        tableToExport ["9"] = scriptObject.Revision
        tableToExport ["10"] = scriptObject.PlaterCore

        for i = 1, #Plater.CodeTypeNames do
            local memberName = Plater.CodeTypeNames [i]
            tableToExport [(10 + i)..""] = scriptObject [memberName]
        end

        tableToExport ["options"] = scriptObject.Options or {}

        tableToExport ["addon"] = "Plater"
        tableToExport ["tocversion"] = select(4, GetBuildInfo()) -- provide export toc
        tableToExport ["type"] = "script"

        return tableToExport
    end
end

    --an indexScriptTable is a table decoded from an imported string, Plater uses this table to build an scriptObject
--check the type of indexes in the indexScriptTable to determine which type of script is this
--this is done to avoid sending an extra index just to tell which type of script is the string
function Plater.GetDecodedScriptType(indexScriptTable)
    -- newer versions
    if indexScriptTable.type == "hook" then
        return "hook"
    elseif indexScriptTable.type == "script" then
        return "script"
    elseif indexScriptTable.type == "npc_colors" then
        return "npc_colors"
    end

    -- fallback for old versions
    indexScriptTable = Plater.MigrateScriptModImport(indexScriptTable) -- just to make sure this works as intended...
    if (indexScriptTable.NpcColor) then
        return "npc_colors"
    elseif (type(indexScriptTable ["9"]) == "table") then --hook
        return "hook"
    elseif (type(indexScriptTable ["9"]) == "number") then --script
        return "script"
    end
end

--add a scriptObject to the script db
--if noOverwrite is passed, it won't replace if a script with the same name already exists
function Plater.AddScript(scriptObjectToAdd, noOverwrite)
    if (scriptObjectToAdd) then
        local indexToReplace
        local existingScriptObject
        local scriptType = Plater.GetScriptType(scriptObjectToAdd)
        local scriptDB = Plater.GetScriptDB(scriptType)

        --check if already exists
        for i = 1, #scriptDB do
            local scriptObject = scriptDB [i]
            if (scriptObject.Name == scriptObjectToAdd.Name) then
                --the script already exists
                if (noOverwrite) then
                    return
                else
                    indexToReplace = i
                    existingScriptObject = scriptObject
                    break
                end
            end
        end

        if (indexToReplace) then
            --remove the old script and add the new one
            Plater.UpdateOptionsForModScriptImport(scriptObjectToAdd, existingScriptObject)
            table.remove(scriptDB, indexToReplace)
            table.insert(scriptDB, indexToReplace, scriptObjectToAdd)
        else
            --add the new script to the end of the table
            table.insert(scriptDB, scriptObjectToAdd)
        end
    end
end

--get a index table from an imported string and build a scriptObject from it
function Plater.BuildScriptObjectFromIndexTable(indexTable, scriptType)
    if (scriptType == "hook") then
        -- check integrity: name and hooks
        if not indexTable ["1"] or not indexTable ["9"] then
            return nil
        end

        local scriptObject = {}
        scriptObject.Enabled 		= true --imported scripts are always enabled
        scriptObject.Name		    = indexTable ["1"]
        scriptObject.Icon			= indexTable ["2"]
        scriptObject.Desc		    = indexTable ["3"]
        scriptObject.Author		    = indexTable ["4"]
        scriptObject.Time			= indexTable ["5"]
        scriptObject.Revision		= indexTable ["6"]
        scriptObject.PlaterCore		= indexTable ["7"]
        scriptObject.LoadConditions	= indexTable ["8"]

        scriptObject.Hooks = {}
        scriptObject.HooksTemp = {}
        scriptObject.LastHookEdited = ""

        for hookName, hookCode in pairs(indexTable ["9"]) do
            scriptObject.Hooks [hookName] = hookCode
        end

        scriptObject.Options = indexTable.options

        scriptObject.url         = indexTable.url or ""
        scriptObject.version = indexTable.version or -1
        scriptObject.semver  = indexTable.semver or ""

        scriptObject.UID = indexTable.UID

        return scriptObject

    elseif (scriptType == "script") then
        -- check integrity: type, name, triggers and hooks
        if not indexTable ["1"] or not indexTable ["2"] or not indexTable ["3"] or not indexTable ["4"]
            or not indexTable ["11"] or not indexTable ["12"] or not indexTable ["13"] or not indexTable ["14"] then
            return nil
        end

        local scriptObject = {}

        scriptObject.Enabled 		= true --imported scripts are always enabled
        scriptObject.ScriptType 	= indexTable ["1"]
        scriptObject.Name  		    = indexTable ["2"]
        scriptObject.SpellIds  		= indexTable ["3"]
        scriptObject.NpcNames  	    = indexTable ["4"]
        scriptObject.Icon  		    = indexTable ["5"]
        scriptObject.Desc  		    = indexTable ["6"]
        scriptObject.Author  		= indexTable ["7"]
        scriptObject.Time  		    = indexTable ["8"]
        scriptObject.Revision  		= indexTable ["9"]
        scriptObject.PlaterCore  	= indexTable ["10"]
        scriptObject.Options        = indexTable.options
        scriptObject.url  	        = indexTable.url or ""
        scriptObject.version        = indexTable.version or -1
        scriptObject.semver         = indexTable.semver or ""

        for i = 1, #Plater.CodeTypeNames do
            local memberName = Plater.CodeTypeNames [i]
            scriptObject [memberName] = indexTable [(10 + i)..""]
        end

        return scriptObject
    end
end

function Plater.ScriptReceivedFromGroup(prefix, playerName, playerRealm, playerGUID, importedString)
    if (not Plater.db.profile.script_banned_user [playerGUID]) then
        local indexScriptTable = Plater.DecompressData(importedString, "comm")

        if (indexScriptTable and type(indexScriptTable) == "table") then
            local importedScriptObject = Plater.BuildScriptObjectFromIndexTable(indexScriptTable, Plater.GetDecodedScriptType(indexScriptTable))
            if (not importedScriptObject) then
                return
            end

            local scriptName = importedScriptObject.Name
            local alreadyExists = false
            local alreadyExistsVersion = 0

            local scriptType = Plater.GetScriptType(importedScriptObject)
            local scriptDB = Plater.GetScriptDB(scriptType)

            for i = 1, #scriptDB do
                local scriptObject = scriptDB [i]
                if (scriptObject.Name == scriptName) then
                    alreadyExists = true
                    alreadyExistsVersion = scriptObject.Revision
                    break
                end
            end

            --add the script to the queue
            Plater.ScriptsWaitingApproval = Plater.ScriptsWaitingApproval or {}
            table.insert(Plater.ScriptsWaitingApproval, {importedScriptObject, playerName, playerRealm, playerGUID, alreadyExists, alreadyExistsVersion})

            Plater.ShowImportScriptConfirmation()
        end
    end
end

function Plater.ExportScriptToGroup(scriptId, scriptType)
    local scriptToSend = Plater.GetScriptObject(scriptId, scriptType)

    if (not scriptToSend) then
        Plater:Msg("script not found", scriptId)
        return
    end

    --convert hash table to index table for smaller size
    local indexedScriptTable = Plater.PrepareTableToExport(scriptToSend)
    --compress the indexed table for WoWAddonChannel
    local encodedString = Plater.CompressData(indexedScriptTable, "comm")

    if (encodedString) then
        if (IsInRaid(LE_PARTY_CATEGORY_HOME)) then
            Plater:SendCommMessage(Plater.COMM_PLATER_PREFIX, LibAceSerializer:Serialize(Plater.COMM_SCRIPT_GROUP_EXPORTED, UnitName("player"), GetRealmName(), UnitGUID("player"), encodedString), "RAID")

        elseif (IsInGroup(LE_PARTY_CATEGORY_HOME)) then
            Plater:SendCommMessage(Plater.COMM_PLATER_PREFIX, LibAceSerializer:Serialize(Plater.COMM_SCRIPT_GROUP_EXPORTED, UnitName("player"), GetRealmName(), UnitGUID("player"), encodedString), "PARTY")

        else
            Plater:Msg("Failed to send the script: your group isn't home group.")
        end
    else
        Plater:Msg("Fail to encode scriptId", scriptId)
    end
end

function Plater.ShowImportScriptConfirmation()

    if (not Plater.ImportConfirm) then
        Plater.ImportConfirm = DF:CreateSimplePanel(UIParent, 380, 130, "Plater Nameplates: Script Importer", "PlaterImportScriptConfirmation")
        Plater.ImportConfirm:Hide()
        DF:ApplyStandardBackdrop(Plater.ImportConfirm)

        Plater.ImportConfirm.AcceptText = Plater:CreateLabel(Plater.ImportConfirm, "", Plater:GetTemplate("font", "OPTIONS_FONT_TEMPLATE"))
        Plater.ImportConfirm.AcceptText:SetPoint(16, -26)

        Plater.ImportConfirm.ScriptName = Plater:CreateLabel(Plater.ImportConfirm, "", Plater:GetTemplate("font", "OPTIONS_FONT_TEMPLATE"))
        Plater.ImportConfirm.ScriptName:SetPoint(16, -41)

        Plater.ImportConfirm.ScriptVersion = Plater:CreateLabel(Plater.ImportConfirm, "", Plater:GetTemplate("font", "OPTIONS_FONT_TEMPLATE"))
        Plater.ImportConfirm.ScriptVersion:SetPoint(16, -56)

        local accept_aura = function(self, button, scriptObject)
            Plater.AddScript(scriptObject)
            Plater.ImportConfirm:Hide()
            Plater.ShowImportScriptConfirmation()
        end

        local decline_aura = function(self, button, scriptObject, senderGUID)
            if (Plater.ImportConfirm.AlwaysIgnoreCheckBox.value) then
                Plater.db.profile.script_banned_user [senderGUID] = true
                Plater:Msg("the user won't send more scripts to you.")
            end
            Plater.ImportConfirm:Hide()
            Plater.ShowImportScriptConfirmation()
        end

        Plater.ImportConfirm.AcceptButton = Plater:CreateButton(Plater.ImportConfirm, accept_aura, 125, 20, "Accept", -1, nil, nil, nil, nil, nil, Plater:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE"))
        Plater.ImportConfirm.DeclineButton = Plater:CreateButton(Plater.ImportConfirm, decline_aura, 125, 20, "Decline", -1, nil, nil, nil, nil, nil, Plater:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE"))

        Plater.ImportConfirm.AcceptButton:SetPoint("bottomright", Plater.ImportConfirm, "bottomright", -14, 31)
        Plater.ImportConfirm.DeclineButton:SetPoint("bottomleft", Plater.ImportConfirm, "bottomleft", 14, 31)

        Plater.ImportConfirm.AlwaysIgnoreCheckBox = DF:CreateSwitch(Plater.ImportConfirm, function()end, false, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, DF:GetTemplate("switch", "OPTIONS_CHECKBOX_BRIGHT_TEMPLATE"))
        Plater.ImportConfirm.AlwaysIgnoreCheckBox:SetAsCheckBox()
        Plater.ImportConfirm.AlwaysIgnoreLabel = Plater:CreateLabel(Plater.ImportConfirm, "Always decline this user", Plater:GetTemplate("font", "OPTIONS_FONT_TEMPLATE"))
        Plater.ImportConfirm.AlwaysIgnoreCheckBox:SetPoint("topleft", Plater.ImportConfirm.DeclineButton, "bottomleft", 0, -4)
        Plater.ImportConfirm.AlwaysIgnoreLabel:SetPoint("left", Plater.ImportConfirm.AlwaysIgnoreCheckBox, "right", 2, 0)

        Plater.ImportConfirm.Flash = Plater.CreateFlash(Plater.ImportConfirm)
    end

    if (Plater.ImportConfirm:IsShown()) then
        Plater.ImportConfirm.Title:SetText("Plater Nameplates: Script Importer(" .. #Plater.ScriptsWaitingApproval + 1 .. ")")
        return
    else
        Plater.ImportConfirm.Title:SetText("Plater Nameplates: Script Importer(" .. #Plater.ScriptsWaitingApproval .. ")")
    end

    local nextScriptToApprove = table.remove(Plater.ScriptsWaitingApproval)

    if (nextScriptToApprove) then
        local scriptObject = nextScriptToApprove [1]
        local senderGUID = nextScriptToApprove [4]

        rawset(Plater.ImportConfirm.AcceptButton, "param1", scriptObject)
        rawset(Plater.ImportConfirm.AcceptButton, "param2", senderGUID)
        rawset(Plater.ImportConfirm.DeclineButton, "param1", scriptObject)
        rawset(Plater.ImportConfirm.DeclineButton, "param2", senderGUID)

        Plater.ImportConfirm.AcceptText.text = "The user |cFFFFAA00" .. nextScriptToApprove [2] .. "|r sent the script: |cFFFFAA00" .. scriptObject.Name .. "|r"
        Plater.ImportConfirm.ScriptName.text = "Script Version: |cFFFFAA00" .. scriptObject.Revision .. "|r"
        Plater.ImportConfirm.ScriptVersion.text = nextScriptToApprove [5] and "|cFFFFAA33You already have this script on version:|r " .. nextScriptToApprove [6] or "|cFF33DD33You don't have this script yet!"

        Plater.ImportConfirm:SetPoint("center", UIParent, "center", 0, 150)
        Plater.ImportConfirm.AlwaysIgnoreCheckBox:SetValue(false)
        Plater.ImportConfirm.Flash:Play()
        Plater.ImportConfirm:Show()

        --play audio: IgPlayerInvite or igPlayerInviteDecline
    else
        Plater.ImportConfirm:Hide()
    end
end