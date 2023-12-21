
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


function platerInternal.InstallMDTHooks()
    --first check if Mythic Dungeon Tools is installed
    if (not MDT) then
        return
    end

    --this function open the plater options panel and search for the npcId under the tab 'Npc Color and Names'
    local fSeeNpcOnPlater = function(self, fixedParameter, npcId)
        Plater.OpenOptionsPanel(platerInternal.NpcColorsFrameIndex)

        --due to lazy loading, the panel might not be loaded yet
        local npcColorFrame = PlaterOptionsPanelContainerColorManagement
        if (not npcColorFrame) then
            C_Timer.After(1.5, function()
                Plater.OpenOptionsPanel(platerInternal.NpcColorsFrameIndex)
                npcColorFrame = PlaterOptionsPanelContainerColorManagement
                npcColorFrame.AuraSearchTextEntry:SetText(npcId)
                npcColorFrame.OnSearchBoxTextChanged()
            end)
        else
            npcColorFrame.AuraSearchTextEntry:SetText(npcId)
            npcColorFrame.OnSearchBoxTextChanged()
        end
    end

    --this function open the plater options panel and search for the spellId under the tab 'Cast Color and Names'
    local fSeeSpellOnPlater = function(self, fixedParameter, spellId)
        --ColorFrame
        Plater.OpenOptionsPanel(platerInternal.CastColorsFrameIndex)

        --due to lazy loading, the panel might not be loaded yet
        local castColorFrame = PlaterOptionsPanelContainerCastColorManagementColorFrame
        if (not castColorFrame) then
            C_Timer.After(platerInternal.CastColorsCreationDelay + 0.1, function()
                Plater.OpenOptionsPanel(platerInternal.CastColorsFrameIndex)
                castColorFrame = PlaterOptionsPanelContainerCastColorManagementColorFrame
                castColorFrame.AuraSearchTextEntry:SetText(spellId)
                castColorFrame.OnSearchBoxTextChanged()
            end)
        else
            castColorFrame.AuraSearchTextEntry:SetText(spellId)
            castColorFrame.OnSearchBoxTextChanged()
        end
    end

    if (not MDT.UpdateEnemyInfoFrame) then
        return
    end

    hooksecurefunc(MDT, "UpdateEnemyInfoFrame", function()
        local midContainerChildren = MDT.EnemyInfoFrame.midContainer.children
        if (not midContainerChildren) then
            return
        end

        --MDT npc info section
        local countEditFrame
        if (midContainerChildren[1] and midContainerChildren[1].countEditBox) then
            countEditFrame = midContainerChildren[1].countEditBox
        elseif (midContainerChildren[2] and midContainerChildren[2].countEditBox) then
            countEditFrame = midContainerChildren[1].countEditBox
        end
        --Enemy Forces (Teeming) is overlapping with our frame
        --todo: currently waiting on nnoggie, to provide more space in the middle section, to add a npc color dropdown and a npc rename text entry

        --MDT spells info section
        local spellScrollChildren = MDT.EnemyInfoFrame.spellScroll.children --.children is an array of tables, each table has a frame and a spellId
        if (spellScrollChildren) then
            for i = 1, #spellScrollChildren do
                ---@type table
                local spellFrameTable = spellScrollChildren[i]
                if (spellFrameTable) then
                    local spellButton = spellFrameTable.frame
                    local spellId = spellFrameTable.spellId

                    local _, _, _, castTime = GetSpellInfo(spellId)

                    if (castTime and castTime > 0) then
                        if (not spellButton.GoToPlaterButton) then
                            spellButton.GoToPlaterButton = DF:CreateButton(spellButton, fSeeSpellOnPlater, 20, 20, "", spellId)
                            spellButton.GoToPlaterButton:SetPoint("bottomright", spellButton, "bottomright", -12, 2)
                            spellButton.GoToPlaterButton:SetIcon([[Interface\Buttons\UI-Panel-BiggerButton-Up]], 18, 18, "overlay", {0.2, 0.8, 0.2, 0.8})
                            spellButton.GoToPlaterButton.tooltip = "Setup this spell on Plater"
                            --DF:ApplyStandardBackdrop(spellButton.GoToPlaterButton) --debug button size
                        else
                            spellButton.GoToPlaterButton.param1 = spellId
                        end
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




