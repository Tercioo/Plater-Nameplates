
local Plater = _G.Plater
local C_Timer = _G.C_Timer
local addonName, platerInternal = ...

---@type detailsframework
local DF = DetailsFramework

local GetSpellInfo = GetSpellInfo or function(spellID) if not spellID then return nil end local si = C_Spell.GetSpellInfo(spellID) if si then return si.name, nil, si.iconID, si.castTime, si.minRange, si.maxRange, si.spellID, si.originalIconID end end

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
        Plater.OpenOptionsPanel(platerInternal.NpcColorsFrameIndex, true)
        npcColorFrame.AuraSearchTextEntry:SetText(searchString)
        npcColorFrame.OnSearchBoxTextChanged()
        --C_Timer.After(0, function() Plater.OpenOptionsPanel(platerInternal.NpcColorsFrameIndex) print("selected tab") end)
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
                        containerFrame.GoToPlaterButton = DF:CreateButton(containerFrame.frame, fSeeNpcOnPlater, 1, 1, "")
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

                        local point1 = Plater.MDTSettings.enemyinfo_button_point
                        containerFrame.GoToPlaterButton:ClearAllPoints()
                        containerFrame.GoToPlaterButton:SetPoint(point1[1], containerFrame.frame, point1[2], point1[3], point1[4])
                        containerFrame.GoToPlaterButton:SetSize(Plater.MDTSettings.button_width, Plater.MDTSettings.button_height)
                        containerFrame.GoToPlaterButton:SetIcon(Plater.MDTSettings.icon_texture, Plater.MDTSettings.button_width, Plater.MDTSettings.button_height, "overlay", Plater.MDTSettings.icon_coords)
                        containerFrame.GoToPlaterButton:SetAlpha(Plater.MDTSettings.alpha)
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
                            spellButton.GoToPlaterButton = DF:CreateButton(spellButton, fSeeSpellOnPlater, 1, 1, "", spellId)
                            spellButton.GoToPlaterButton.tooltip = "Setup this spell on Plater"
                            --DF:ApplyStandardBackdrop(spellButton.GoToPlaterButton) --debug button size
                        end

                        spellButton.GoToPlaterButton.param1 = spellId
                        local point1 = Plater.MDTSettings.spellinfo_button_point
                        spellButton.GoToPlaterButton:ClearAllPoints()
                        spellButton.GoToPlaterButton:SetPoint(point1[1], spellButton, point1[2], point1[3], point1[4])
                        spellButton.GoToPlaterButton:SetSize(Plater.MDTSettings.button_width, Plater.MDTSettings.button_height)
                        spellButton.GoToPlaterButton:SetIcon(Plater.MDTSettings.icon_texture, Plater.MDTSettings.button_width, Plater.MDTSettings.button_height, "overlay", Plater.MDTSettings.icon_coords)
                        spellButton.GoToPlaterButton:SetAlpha(Plater.MDTSettings.alpha)
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



--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> debuggers ~debug

function Plater.DebugColorAnimation()
    if (Plater.DebugColorAnimation_Timer) then
        return
    end

    Plater.DebugColorAnimation_Timer = C_Timer.NewTicker (0.5, function() --~animationtest
        for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
            --make the bar jump from green to pink - pink to green
            Plater.ChangeHealthBarColor_Internal (plateFrame.unitFrame.healthBar, abs (math.sin (GetTime())), abs (math.cos (GetTime())), abs (math.sin (GetTime())), 1)
        end
    end)

    C_Timer.After (10, function()
        if (Plater.DebugColorAnimation_Timer) then
            Plater.DebugColorAnimation_Timer:Cancel()
            Plater.DebugColorAnimation_Timer = nil
            Plater:Msg ("stopped the animation test.")
            Plater.UpdateAllPlates()
        end
    end)

    Plater:Msg ("is now animating color nameplates in your screen for test purposes.")
end

function Plater.DebugHealthAnimation()
    if (Plater.DebugHealthAnimation_Timer) then
        return
    end

    Plater.DebugHealthAnimation_Timer = C_Timer.NewTicker (1.5, function() --~animationtest
        for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
            local self = plateFrame.unitFrame

            if (self.healthBar.CurrentHealth == 0) then
                self.healthBar.AnimationStart = 0
                self.healthBar.AnimationEnd = UnitHealthMax (self [MEMBER_UNITID])
            else
                self.healthBar.AnimationStart = UnitHealthMax (self [MEMBER_UNITID])
                self.healthBar.AnimationEnd = 0
            end

            self.healthBar:SetValue (self.healthBar.CurrentHealth)
            self.healthBar.CurrentHealthMax = UnitHealthMax (self [MEMBER_UNITID])

            self.healthBar.IsAnimating = true

            if (self.healthBar.AnimationEnd > self.healthBar.AnimationStart) then
                self.healthBar.AnimateFunc = Plater.AnimateRightWithAccel
            else
                self.healthBar.AnimateFunc = Plater.AnimateLeftWithAccel
            end

        end
    end)

    C_Timer.After (10, function()
        if (Plater.DebugHealthAnimation_Timer) then
            Plater.DebugHealthAnimation_Timer:Cancel()
            Plater.DebugHealthAnimation_Timer = nil
            Plater:Msg ("stopped the animation test.")
            Plater.UpdateAllPlates()
        end
    end)

    Plater:Msg ("is now animating nameplates in your screen for test purposes.")
end