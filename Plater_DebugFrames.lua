
local Plater = _G.Plater
local C_Timer = _G.C_Timer
local addonName, platerInternal = ...

---@type detailsframework
local DF = DetailsFramework

function Plater.DebugNameplate()
    return Plater.DebugTargetNameplate()
end

function Plater.DebugTargetNameplate()
    local plateFrame = C_NamePlate.GetNamePlateForUnit("target", issecure())
    if (plateFrame) then
        if (not _G.FrameInspect) then
            Plater:Msg("Please install FrameInspect addon to use this function.")
            return
        end
        _G.FrameInspect.Inspect(plateFrame)
    else
        Plater:Msg("You don't have a target or the nameplate is protected.")
            return
    end
end

    ---open the options panel and select the cast colors tab
    ---searchString is optional, if provided, it will be used to search for a spellId, npcId, spellName, npcName, zoneName, sound name, and encounterName.
    ---@param searchString string
    ---@return nil
    function Plater.OpenCastColorsPanel(searchString)
        --ColorFrame
        Plater.OpenOptionsPanel(platerInternal.CastColorsFrameIndex)

        --due to lazy loading, the panel might not be loaded yet
        local castColorFrame = PlaterOptionsPanelContainerCastColorManagementColorFrame
        if (not castColorFrame) then
            C_Timer.After(platerInternal.CastColorsCreationDelay + 0.1, function()
                Plater.OpenOptionsPanel(platerInternal.CastColorsFrameIndex)
                castColorFrame = PlaterOptionsPanelContainerCastColorManagementColorFrame
                castColorFrame.AuraSearchTextEntry:SetText(searchString)
                castColorFrame.OnSearchBoxTextChanged()
            end)
        else
            castColorFrame.AuraSearchTextEntry:SetText(searchString)
            castColorFrame.OnSearchBoxTextChanged()
        end
    end

    function Plater.OpenNpcColorsPanel(searchString) --/run Plater.OpenNpcColorsPanel("")
        Plater.OpenOptionsPanel(platerInternal.NpcColorsFrameIndex)

        --due to lazy loading, the panel might not be loaded yet
        local npcColorFrame = PlaterOptionsPanelContainerColorManagement
        if (not npcColorFrame or not npcColorFrame.Header) then
            C_Timer.After(platerInternal.NpcColorsCreationDelay + 0.1, function()
                Plater.OpenOptionsPanel(platerInternal.NpcColorsFrameIndex)
                npcColorFrame = PlaterOptionsPanelContainerColorManagement
                npcColorFrame.AuraSearchTextEntry:SetText(searchString)
                npcColorFrame.OnSearchBoxTextChanged()
            end)
        else
            npcColorFrame.AuraSearchTextEntry:SetText(searchString)
            npcColorFrame.OnSearchBoxTextChanged()
        end
    end

function platerInternal.InstallMDTHooks()
    --first check if Mythic Dungeon Tools is installed
    if (not MDT) then
        return
    end

    --this function open the plater options panel and search for the npcId under the tab 'Npc Color and Names'
    local fSeeNpcOnPlater = function(self, fixedParameter, npcId)
        Plater.OpenNpcColorsPanel(npcId)
    end

    --this function open the plater options panel and search for the spellId under the tab 'Cast Color and Names'
    local fSeeSpellOnPlater = function(self, fixedParameter, spellId)
        Plater.OpenCastColorsPanel(spellId)
    end

    if (not MDT.UpdateEnemyInfoFrame) then
        return
    end

    hooksecurefunc(MDT, "UpdateEnemyInfoFrame", function()
        local midContainerChildren = MDT.EnemyInfoFrame and MDT.EnemyInfoFrame.midContainer and MDT.EnemyInfoFrame.midContainer.children
        if (midContainerChildren) then
            for i = 1, #midContainerChildren do
                local containerFrame = midContainerChildren[i]
                if (containerFrame.idEditBox) then
                    if (not containerFrame.GoToPlaterButton) then
                        containerFrame.GoToPlaterButton = DF:CreateButton(containerFrame.frame, fSeeNpcOnPlater, 20, 20, "")
                        containerFrame.GoToPlaterButton:SetPoint("topright", containerFrame.frame, "topright", 4.682, -21.361)
                        containerFrame.GoToPlaterButton:SetIcon([[Interface\Buttons\UI-Panel-BiggerButton-Up]], 18, 18, "overlay", {0.2, 0.8, 0.2, 0.8})
                        containerFrame.GoToPlaterButton:SetAlpha(0.834)
                        containerFrame.GoToPlaterButton.tooltip = "Setup this npc on Plater"
                        --DF:ApplyStandardBackdrop(containerFrame.GoToPlaterButton) --debug button size
                        --DF:ApplyStandardBackdrop(containerFrame.frame) --debug container size
                        --DF:DebugVisibility(containerFrame.frame)
                    end

                    local npcId = containerFrame.idEditBox:GetText()
                    npcId = tonumber(npcId)
                    if (npcId and npcId > 1) then
                        containerFrame.GoToPlaterButton.param1 = npcId
                        --/dump MDT.EnemyInfoFrame.midContainer.children[2].healthEditBox
                    else
                        containerFrame.GoToPlaterButton:Hide()
                    end
                end
            end
        end

        --MDT spells info section
        local spellScrollChildren = MDT.EnemyInfoFrame and MDT.EnemyInfoFrame.spellScroll and MDT.EnemyInfoFrame.spellScroll.children --.children is an array of tables, each table has a frame and a spellId
        if (spellScrollChildren) then
            for i = 1, #spellScrollChildren do
                ---@type table
                local spellFrameTable = spellScrollChildren[i]
                if (spellFrameTable) then
                    local spellButton = spellFrameTable.frame
                    local spellId = spellFrameTable.spellId

                    local _, _, _, castTime = GetSpellInfo(spellId or 1)

                    if (castTime and castTime > 0) then
                        if (not spellButton.GoToPlaterButton) then
                            spellButton.GoToPlaterButton = DF:CreateButton(spellButton, fSeeSpellOnPlater, 20, 20, "", spellId)
                            spellButton.GoToPlaterButton:SetPoint("bottomright", spellButton, "bottomright", -12, 2)
                            spellButton.GoToPlaterButton:SetIcon([[Interface\Buttons\UI-Panel-BiggerButton-Up]], 18, 18, "overlay", {0.2, 0.8, 0.2, 0.8})
                            spellButton.GoToPlaterButton:SetAlpha(0.834)
                            spellButton.GoToPlaterButton.tooltip = "Setup this spell on Plater"
                            --DF:ApplyStandardBackdrop(spellButton.GoToPlaterButton) --debug button size
                        end

                        spellButton.GoToPlaterButton.param1 = spellId
                    else
                        if (spellButton.GoToPlaterButton) then
                            spellButton.GoToPlaterButton:Hide()
                        end
                    end
                end
            end
        end
    end)

end




