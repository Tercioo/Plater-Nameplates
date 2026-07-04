
local addonName, platerInternal = ...
---@diagnostic disable-next-line: undefined-field
local Plater = _G.Plater
local GameCooltip = GameCooltip2
---@type detailsframework
local detailsFramework = DetailsFramework
local _

local DEBUG_OPEN_AT_LOGIN = false
local IS_WOW_PROJECT_MIDNIGHT = detailsFramework.IsAddonApocalypseWow()

--fake aura data for the designer's Auras preview. structure matches what Plater.AddAura
--expects (name, texture, count, duration, spellID, type). ApplyTime is mutated per-tick by
--the driver so each aura cycles its visible time.
local AURA_TEST_DEBUFFS = {
    {SpellName = "Shadow Word: Pain", SpellTexture = 136207, Count = 1, Duration = 7, SpellID = 589, Type = "Magic"},
    {SpellName = "Vampiric Touch", SpellTexture = 135978, Count = 1, Duration = 5, SpellID = 34914, Type = "Magic"},
    --Count 0 on these two so their stack number does not overlap the "stacks" preview button
    --sitting directly above them (they are the 3rd and 4th icons under that label).
    {SpellName = "Mind Flay", SpellTexture = 136208, Count = 0, Duration = 5, SpellID = 15407, Type = "Magic"},
    {SpellName = "Enrage", SpellTexture = 132345, Count = 0, Duration = 0, SpellID = 228318, Type = ""},
}
local AURA_TEST_BUFFS = {
    {SpellName = "Twist of Fate", SpellTexture = 237566, Count = 1, Duration = 9, SpellID = 123254},
    {SpellName = "Empty Mind", SpellTexture = 136206, Count = 4, Duration = 7, SpellID = 247226},
}

---@class plater_designer : table

platerInternal.Designer = {}
local designer = platerInternal.Designer

designer.Options = {}
local options = designer.Options

local editorOptionsTextTemplate = {
    size = 11,
    color = "gold",
}

local editorOptionsSliderTemplate = {
    thumbwidth = 20,
}

--all objects that uses only settings that are within the plate_config table
---@type df_editor_objectinfo[]
local plateConfigObjectsInfo = {}

local ACTORTYPE_FRIENDLY_PLAYER = platerInternal.VarSharing.ACTORTYPE_FRIENDLY_PLAYER
local ACTORTYPE_FRIENDLY_NPC = platerInternal.VarSharing.ACTORTYPE_FRIENDLY_NPC
local ACTORTYPE_ENEMY_PLAYER = platerInternal.VarSharing.ACTORTYPE_ENEMY_PLAYER
local ACTORTYPE_ENEMY_NPC = platerInternal.VarSharing.ACTORTYPE_ENEMY_NPC
local ACTORTYPE_PLAYER = platerInternal.VarSharing.ACTORTYPE_PLAYER

local MEMBER_UNITID = platerInternal.VarSharing.MEMBER_UNITID
local MEMBER_GUID = platerInternal.VarSharing.MEMBER_GUID
local MEMBER_NPCID = platerInternal.VarSharing.MEMBER_NPCID
local MEMBER_QUEST = platerInternal.VarSharing.MEMBER_QUEST
local MEMBER_REACTION = platerInternal.VarSharing.MEMBER_REACTION
local MEMBER_RANGE = platerInternal.VarSharing.MEMBER_RANGE
local MEMBER_NOCOMBAT = platerInternal.VarSharing.MEMBER_NOCOMBAT
local MEMBER_NAME = platerInternal.VarSharing.MEMBER_NAME
local MEMBER_NAMELOWER = platerInternal.VarSharing.MEMBER_NAMELOWER
local MEMBER_TARGET = platerInternal.VarSharing.MEMBER_TARGET

local plateFrame

---profile.plate_config[enemynpc, friendlynpc, enemyplayer, friendlyplayer]
local subTablePath = "enemynpc"

local getProfileTable = function()
    return Plater.db.profile.plate_config[subTablePath]
end

local dv = function(f) detailsFramework:DebugVisibility(f) end

---debug tags to help identify frames, the string passed is always the variable name for the frame
---@param f frame
---@param n string
local createFrameTag = function (f,n)
    do return end
    local t = f:CreateTexture (nil, "overlay")
    local fs = f:CreateFontString (nil, "overlay", "GameFontNormalSmall")

    t:SetSize(140, 12)
    t:SetColorTexture (1, 1, 0, 1)
    t:SetPoint ("bottomleft", f, "topleft", 0, 0)

    fs:SetPoint ("left", t, "left", 0, 0)
    fs:SetText (n)
    fs:SetTextColor (0, 0, 0, 1)


end

function Plater.ToggleDesignerWindow()
    if (Plater.DesignerWindow and Plater.DesignerWindow:IsShown()) then
        Plater.DesignerWindow:Hide()
        return
    end

    Plater.OpenDesignerWindow()
end

function Plater.OpenDesignerWindow()
    if (Plater.DesignerWindow) then
        Plater.DesignerWindow:Show()
        return
    end

    Plater.CreateDesignerWindow()
end

local a = CreateFrame("frame")
a:RegisterEvent("PLAYER_LOGIN")
a:SetScript("OnEvent", function(self, event, ...)
    if DEBUG_OPEN_AT_LOGIN then
        Plater.OpenDesignerWindow()
    end
    self:UnregisterEvent("PLAYER_LOGIN")
end)

function Plater.CreateDesignerWindow(tabFrame, tabContainer, parent)
    local gName = "PlaterDsgn"

    local isCastBarSelected = false
    local isTargetSelected = false
    local isFocusSelected = false
    local isAuraTimerSelected = false

    --when true, the fake aura preview is also painted on real game-world nameplates. only
    --enabled while an aura-related widget is selected so the preview does not clutter the
    --player's actual nameplates while editing other parts of the design.
    local isAuraWorldPreviewOn = false

    --widget ids that count as "aura related" for the world-plate preview above.
    local AURA_WIDGET_IDS = {
        AURAS = true,
        AURATRACKING = true,
        AURABORDERCOLORS = true,
        STACKCOUNTER = true,
        AURATIMER = true,
    }

    local startX, startY, heightSize = 10, platerInternal.optionsYStart, 755

    --tab background using a rounded panel | need to make a preset for this, atm it is declaring each time the same table
    local roundedPanelOptions = {
        scale = 1,
        width = tabFrame:GetWidth() - 4,
        height = tabFrame:GetHeight() - 4 - math.abs(startY),
        roundness = 8,
    }

    ---@type df_roundedpanel
    --local editorMainFrame = detailsFramework:CreateRoundedPanel(tabFrame, gName, roundedPanelOptions)
    local editorMainFrame = CreateFrame("Frame", gName, tabFrame)
    --editorMainFrame:SetFrameStrata("FULLSCREEN")
    --local editorMainFrame = CreateFrame("frame", gName, UIParent)

    Plater.DesignerWindow = editorMainFrame

    --detailsFramework:MakeDraggable(editorMainFrame)
    --editorMainFrame:EnableMouse(true)
    createFrameTag(editorMainFrame, "editorMainFrame")
    editorMainFrame:SetSize(roundedPanelOptions.width, roundedPanelOptions.height)
    --editorMainFrame:SetPoint ("center", UIParent, "center", -100, 0)
    editorMainFrame:SetPoint("topleft", tabFrame, "topleft", 0, startY + 24)

    --derive the object list line count from the scroll box height so the list fills the panel
    --regardless of screen size. the framework stacks each line at (lineHeight + 1) pixels (1px
    --gap between rows, see createLineFunc in editor.lua), so divide by that stride.
    local objectListHeight = editorMainFrame:GetHeight() - 15
    local objectListLineHeight = 20
    local objectListLineSpacing = 1
    local objectListLines = math.floor(objectListHeight / (objectListLineHeight + objectListLineSpacing))

    --create the widget editor
    local editorOptions = {
        width = editorMainFrame:GetWidth() - 10,
        create_object_list = true,
        object_list_width = 200,
        object_list_height = objectListHeight,
        object_list_lines = objectListLines,
        object_list_line_height = objectListLineHeight,
        text_template = editorOptionsTextTemplate,
        slider_template = editorOptionsSliderTemplate,
        no_anchor_points = true,
        start_editing_callback = function(layoutEditor, objectInfo)
            if (objectInfo.id:match("^CAST")) then
                if not isCastBarSelected then
                    isCastBarSelected = true
                    Plater.StartCastBarTest()
                end
            else
                isCastBarSelected = false
                Plater.StopCastBarTest()
            end

            isTargetSelected = objectInfo.id == "TARGET"
            isFocusSelected = objectInfo.id == "FOCUS"
            isAuraTimerSelected = objectInfo.id == "AURATIMER"

            --aura preview runs the whole time the designer tab is visible. OnShow does not
            --fire on every tab switch, but the editor auto-selects a widget when the tab
            --loads, so this callback fires reliably. StartAuraTest is idempotent (running
            --guard inside), so this is cheap to call on every selection.
            if (designer.StartAuraTest) then
                designer.StartAuraTest()
            end

            --only paint the fake auras on real world nameplates while an aura widget is selected.
            if (designer.SetAuraWorldPreview) then
                designer.SetAuraWorldPreview(AURA_WIDGET_IDS[objectInfo.id] == true)
            end
        end,
        selection_texture = "Interface\\AddOns\\Plater\\images\\selection_corner.png",
    }

    --Plater_Designer_Objects.lua
    --create two tables to map the layout settings for the editor
    designer.CreateSettings(editorMainFrame)

    --the frame in the middle of the tab, the the settings for the selected widget are placed
    ---@type df_editor
    local layoutEditor = detailsFramework:CreateEditor(editorMainFrame, "Plater_LayoutEditor_", editorOptions)
    createFrameTag(layoutEditor, "layoutEditor")
    layoutEditor:SetPoint("topleft", editorMainFrame, "topleft", 5, -16)
    layoutEditor:SetPoint("bottomleft", editorMainFrame, "bottomleft", 5, 5)
    layoutEditor:EnableMouse(false)
    layoutEditor:SetFrameLevel(editorMainFrame:GetFrameLevel() + 10)
    layoutEditor:SetSelectedBackgroundColor(0, 0, 0, 0)
    --layoutEditor:SetUndoKeybind("CTRL+Z")
    --layoutEditor:SetRedoKeybind("CTRL+Y")
    --layoutEditor:SetFrameStrata("HIGH")

    function designer.UpdateAllNameplates()
        Plater.RefreshDBUpvalues()
        for _, thisPlateFrame in ipairs(Plater.GetAllShownPlates()) do
            if thisPlateFrame.namePlateUnitToken or thisPlateFrame.unitToken then
                platerInternal.Events.GetEventFunction("NAME_PLATE_UNIT_ADDED")("NAME_PLATE_UNIT_ADDED", thisPlateFrame.namePlateUnitToken or thisPlateFrame.unitToken)
            end
        end
    end

    --aura preview driver. mirrors Plater.CreateAuraTesting from Plater_Auras.lua but lives
    --here so the designer can drive it directly. populates both the preview plate (which is
    --not in C_NamePlate.GetNamePlates()) and every real shown plate, matching the original.
    local auraTestTicker
    --running guard so StartAuraTest can be called repeatedly (from OnShow + every widget
    --selection) without re-running the expensive DisableAuraTrackingForAuraTest + RefreshAuras
    --setup or restarting the OnUpdate.
    local auraTestRunning = false

    --apply the fake aura set to one plate's buffFrame(s). called per-plate each tick.
    local applyTestAurasToPlate = function(plateFrame, isPreview)
        local unitFrameForPlate = plateFrame and plateFrame.unitFrame
        if (not unitFrameForPlate) then
            return
        end
        --real plates only get processed when on-screen. preview is always treated as on-screen.
        if (not isPreview and not unitFrameForPlate.PlaterOnScreen) then
            return
        end

        local buffFrame = unitFrameForPlate.BuffFrame
        local buffFrame2 = unitFrameForPlate.BuffFrame2
        local unitAuraCache = unitFrameForPlate.AuraCache
        if (not unitAuraCache) then
            unitAuraCache = {}
            unitFrameForPlate.AuraCache = unitAuraCache
        end

        local alpha = Plater.db.profile.aura_alpha
        local separate = Plater.db.profile.buffs_on_aura2
        local unitID = unitFrameForPlate[MEMBER_UNITID] or "player"
        local isPlayerUnit = UnitIsUnit(unitID, "player")

        --read frame-specific size/border now so the per-icon updates below pick up profile
        --changes on every tick. real plates get this through Plater.RefreshAuras rebuilding
        --the pool, but our pooled icons persist so we re-apply the values each cycle.
        local profile = Plater.db.profile
        local widthFrame1 = profile.aura_width
        local heightFrame1 = profile.aura_height
        local borderFrame1 = profile.aura_border_thickness
        local widthFrame2 = profile.aura_width2
        local heightFrame2 = profile.aura_height2
        local borderFrame2 = profile.aura_border_thickness2

        --inline helper to (re)skin a pooled icon. cheap; runs ~16 times/sec across all auras.
        local applySize = function(iconFrame, useSecondary)
            if (not iconFrame) then
                return
            end
            if (useSecondary) then
                if (iconFrame.SetBorderSize) then
                    iconFrame:SetBorderSize(borderFrame2)
                end
                PixelUtil.SetSize(iconFrame, widthFrame2, heightFrame2)
            else
                if (iconFrame.SetBorderSize) then
                    iconFrame:SetBorderSize(borderFrame1)
                end
                PixelUtil.SetSize(iconFrame, widthFrame1, heightFrame1)
            end
        end

        buffFrame:SetAlpha(alpha)
        buffFrame2:SetAlpha(alpha)
        buffFrame.NextAuraIcon = 1
        buffFrame2.NextAuraIcon = 1

        if (not separate) then
            --both buffs and debuffs land on buffFrame (Frame 1) when separation is off.
            for index, auraTable in ipairs(AURA_TEST_DEBUFFS) do
                local auraIconFrame = Plater.GetAuraIcon(buffFrame)
                if (not auraTable.ApplyTime or auraTable.ApplyTime + auraTable.Duration < GetTime()) then
                    auraTable.ApplyTime = GetTime() + math.random(3, 12)
                end
                if (not isPlayerUnit) then
                    Plater.AddAura(buffFrame, auraIconFrame, index, auraTable.SpellName, auraTable.SpellTexture, auraTable.Count, "DEBUFF", auraTable.Duration, auraTable.ApplyTime + auraTable.Duration, "player", true, false, false, auraTable.SpellID, nil, nil, nil, nil, auraTable.Type, 1)
                else
                    Plater.AddAura(buffFrame, auraIconFrame, index, auraTable.SpellName, auraTable.SpellTexture, auraTable.Count, "DEBUFF", auraTable.Duration, auraTable.ApplyTime + auraTable.Duration, "player", true, false, false, auraTable.SpellID, false, false, true, true, auraTable.Type, 1)
                end
                unitAuraCache[auraTable.SpellName] = true
                unitAuraCache[auraTable.SpellID] = true
                unitAuraCache[auraTable.SpellName .. "_player"] = true
                unitAuraCache[auraTable.SpellID .. "_player"] = true
                applySize(auraIconFrame, false)
                Plater.UpdateIconAspecRatio(auraIconFrame)
            end
            for index, auraTable in ipairs(AURA_TEST_BUFFS) do
                local auraIconFrame = Plater.GetAuraIcon(buffFrame)
                if (not auraTable.ApplyTime or auraTable.ApplyTime + auraTable.Duration < GetTime()) then
                    auraTable.ApplyTime = GetTime() + math.random(3, 12)
                end
                if (not isPlayerUnit) then
                    Plater.AddAura(buffFrame, auraIconFrame, index, auraTable.SpellName, auraTable.SpellTexture, auraTable.Count, "DEBUFF", auraTable.Duration, auraTable.ApplyTime + auraTable.Duration, "player", true, true, false, auraTable.SpellID, true, nil, nil, nil, auraTable.Type, 1)
                else
                    Plater.AddAura(buffFrame, auraIconFrame, index, auraTable.SpellName, auraTable.SpellTexture, auraTable.Count, "DEBUFF", auraTable.Duration, auraTable.ApplyTime + auraTable.Duration, "player", true, true, false, auraTable.SpellID, false, false, false, true, auraTable.Type, 1)
                end
                unitAuraCache[auraTable.SpellName] = true
                unitAuraCache[auraTable.SpellID] = true
                unitAuraCache[auraTable.SpellName .. "_player"] = true
                unitAuraCache[auraTable.SpellID .. "_player"] = true
                applySize(auraIconFrame, false)
                Plater.UpdateIconAspecRatio(auraIconFrame)
            end
            --hide icons left on the second buff frame from a previous tick (in case the
            --user just toggled separation off).
            for i = 1, #buffFrame2.PlaterBuffList do
                local icon = buffFrame2.PlaterBuffList[i]
                if (icon) then
                    icon.ShowAnimation:Stop()
                    icon:Hide()
                    icon.InUse = false
                end
            end
        else
            --debuffs on Frame 1, buffs on Frame 2.
            for index, auraTable in ipairs(AURA_TEST_DEBUFFS) do
                local auraIconFrame = Plater.GetAuraIcon(buffFrame)
                if (not auraTable.ApplyTime or auraTable.ApplyTime + auraTable.Duration < GetTime()) then
                    auraTable.ApplyTime = GetTime() + math.random(3, 12)
                end
                if (not isPlayerUnit) then
                    Plater.AddAura(buffFrame, auraIconFrame, index, auraTable.SpellName, auraTable.SpellTexture, auraTable.Count, "DEBUFF", auraTable.Duration, auraTable.ApplyTime + auraTable.Duration, "player", true, false, false, auraTable.SpellID, nil, nil, nil, nil, auraTable.Type, 1)
                else
                    Plater.AddAura(buffFrame, auraIconFrame, index, auraTable.SpellName, auraTable.SpellTexture, auraTable.Count, "DEBUFF", auraTable.Duration, auraTable.ApplyTime + auraTable.Duration, "player", true, false, false, auraTable.SpellID, false, false, true, true, auraTable.Type, 1)
                end
                unitAuraCache[auraTable.SpellName] = true
                unitAuraCache[auraTable.SpellID] = true
                unitAuraCache[auraTable.SpellName .. "_player"] = true
                unitAuraCache[auraTable.SpellID .. "_player"] = true
                applySize(auraIconFrame, false)
            end
            for index, auraTable in ipairs(AURA_TEST_BUFFS) do
                local auraIconFrame, frame = Plater.GetAuraIcon(buffFrame, true)
                if (not auraTable.ApplyTime or auraTable.ApplyTime + auraTable.Duration < GetTime()) then
                    auraTable.ApplyTime = GetTime() + math.random(3, 12)
                end
                if (not isPlayerUnit) then
                    Plater.AddAura(frame, auraIconFrame, index, auraTable.SpellName, auraTable.SpellTexture, auraTable.Count, "BUFF", auraTable.Duration, auraTable.ApplyTime + auraTable.Duration, "player", true, true, false, auraTable.SpellID, true, nil, nil, nil, auraTable.Type, 1)
                else
                    Plater.AddAura(frame, auraIconFrame, index, auraTable.SpellName, auraTable.SpellTexture, auraTable.Count, "BUFF", auraTable.Duration, auraTable.ApplyTime + auraTable.Duration, "player", true, true, false, auraTable.SpellID, true, false, false, false, auraTable.Type, 1)
                end
                unitAuraCache[auraTable.SpellName] = true
                unitAuraCache[auraTable.SpellID] = true
                unitAuraCache[auraTable.SpellName .. "_player"] = true
                unitAuraCache[auraTable.SpellID .. "_player"] = true
                applySize(auraIconFrame, true)
            end
        end

        Plater.HideNonUsedAuraIcons(buffFrame)
        platerInternal.AlignAuraFrames(buffFrame)
        if (separate) then
            platerInternal.AlignAuraFrames(buffFrame.BuffFrame2)
        end

        --preview only: track the Aura Timer overlay to the 3rd and 4th icons and drive the
        --mock cooldown swipes + big numbers. real plates never show this.
        if (isPreview) then
            local timerOverlay = buffFrame.auraTimerPreview
            local icon3 = buffFrame.PlaterBuffList[3]
            local icon4 = buffFrame.PlaterBuffList[4]
            if (timerOverlay and icon3 and icon4 and icon3:IsShown() and icon4:IsShown()) then
                --span the clickable overlay across both icons.
                timerOverlay:ClearAllPoints()
                timerOverlay:SetPoint("topleft", icon3, "topleft", 0, 0)
                timerOverlay:SetPoint("bottomright", icon4, "bottomright", 0, 0)
                timerOverlay:Show()

                local iconForCooldown = {icon3, icon4}
                for cooldownIndex = 1, 2 do
                    local cooldown = timerOverlay.cooldowns[cooldownIndex]
                    cooldown:ClearAllPoints()
                    cooldown:SetAllPoints(iconForCooldown[cooldownIndex])
                    cooldown:Show()
 
                    --seconds the mock timer shows. animated (20->0 loop) while the Aura Timer
                    --widget is selected, otherwise frozen at a static 16.
                    local remaining
                    if (isAuraTimerSelected) then
                        if (cooldown.mode ~= "animate") then
                            cooldown.mode = "animate"
                            cooldown.cooldownEnd = 0
                        end
                        remaining = (cooldown.cooldownEnd or 0) - GetTime()
                        if (remaining <= 0) then
                            cooldown:SetCooldown(GetTime(), 20)
                            cooldown:Resume()
                            cooldown.cooldownEnd = GetTime() + 20
                            remaining = 20
                        end
                    else
                        if (cooldown.mode ~= "static") then
                            cooldown.mode = "static"
                            cooldown:SetCooldown(GetTime() - 4, 20)
                            cooldown:Pause()
                        end
                        remaining = 16
                    end

                    --style the number from the aura_timer_text_* profile settings so every
                    --Aura Timer option reflects in the preview live. mirrors the real timer
                    --styling in Plater.AddAura (Plater_Auras.lua).
                    local timerNumber = cooldown.bigNumber
                    if (not profile.aura_timer) then
                        timerNumber:Hide()
                    else
                        local text
                        if (profile.aura_timer_decimals and remaining < 10) then
                            text = string.format("%.1f", remaining)
                        else
                            text = tostring(math.ceil(remaining))
                        end
                        timerNumber:SetText(text)

                        detailsFramework:SetFontSize(timerNumber, profile.aura_timer_text_size)
                        Plater.SetFontOutlineAndShadow(timerNumber, profile.aura_timer_text_outline, profile.aura_timer_text_shadow_color, profile.aura_timer_text_shadow_color_offset[1], profile.aura_timer_text_shadow_color_offset[2])
                        detailsFramework:SetFontFace(timerNumber, profile.aura_timer_text_font)

                        --pandemic coloring overrides the base color below 25% / 15% remaining.
                        local fraction = remaining / 20
                        if (profile.aura_timer_pandemic_color and fraction < 0.15) then
                            detailsFramework:SetFontColor(timerNumber, 1, 0, 0)
                        elseif (profile.aura_timer_pandemic_color and fraction < 0.25) then
                            detailsFramework:SetFontColor(timerNumber, 1, 0.65, 0)
                        else
                            detailsFramework:SetFontColor(timerNumber, profile.aura_timer_text_color)
                        end

                        Plater.SetAnchor(timerNumber, profile.aura_timer_text_anchor)
                        timerNumber:Show()
                    end
                end
            elseif (timerOverlay) then
                timerOverlay:Hide()
            end
        end
    end

    function designer.StartAuraTest()
        if (auraTestRunning) then
            return
        end
        local previewPlate = designer.plateFrame
        if (not previewPlate) then
            return
        end
        auraTestRunning = true

        --mirrors the options panel test setup. DisableAuraTrackingForAuraTest clears the
        --DB_AURA_ENABLED upvalue (Plater.lua scope) and RefreshAuras rebuilds the icon pool
        --on a clean slate so the first tick is not racing against real-aura tracking.
        Plater.DisableAuraTrackingForAuraTest()
        Plater.RefreshAuras()

        auraTestTicker = auraTestTicker or CreateFrame("frame")
        auraTestTicker.nextTickIn = 0.2
        local tickBody = function(self, deltaTime)
            self.nextTickIn = self.nextTickIn - deltaTime
            if (self.nextTickIn > 0) then
                return
            end
            self.nextTickIn = 0.016

            --the designer's own preview plate always shows the fake auras.
            applyTestAurasToPlate(previewPlate, true)

            --real game-world plates only get the fake auras while an aura widget is selected,
            --so the preview does not clutter the player's nameplates while editing other parts.
            if (isAuraWorldPreviewOn) then
                for _, realPlate in ipairs(Plater.GetAllShownPlates()) do
                    if (realPlate ~= previewPlate) then
                        applyTestAurasToPlate(realPlate, false)
                    end
                end
            end
        end

        --wrap so a silent error inside the body (which OnUpdate normally swallows) surfaces
        --to the user's chat instead of just halting the driver.
        auraTestTicker:SetScript("OnUpdate", function(self, deltaTime)
            xpcall(tickBody, geterrorhandler(), self, deltaTime)
        end)
    end

    function designer.StopAuraTest()
        if (not auraTestRunning) then
            return
        end
        auraTestRunning = false
        if (auraTestTicker) then
            auraTestTicker:SetScript("OnUpdate", nil)
        end
        --restore real aura tracking now that the test is off. mirrors DisableAuraTest in
        --Plater_Auras.lua: refresh the upvalues and force a real aura sweep.
        Plater.RefreshDBUpvalues()
        Plater.RefreshAuras()
    end

    --hide the fake aura icons on real game-world nameplates. used when switching away from an
    --aura widget so the preview stops cluttering the player's actual plates. the designer's
    --own preview plate is left untouched. resetting NextAuraIcon to 1 then hiding makes
    --HideNonUsedAuraIcons clear every icon on both buff frames.
    local clearWorldPlateFakeAuras = function()
        for _, realPlate in ipairs(Plater.GetAllShownPlates()) do
            if (realPlate ~= designer.plateFrame and realPlate.unitFrame) then
                local realBuffFrame = realPlate.unitFrame.BuffFrame
                local realBuffFrame2 = realPlate.unitFrame.BuffFrame2
                if (realBuffFrame) then
                    realBuffFrame.NextAuraIcon = 1
                    Plater.HideNonUsedAuraIcons(realBuffFrame)
                end
                if (realBuffFrame2) then
                    realBuffFrame2.NextAuraIcon = 1
                    Plater.HideNonUsedAuraIcons(realBuffFrame2)
                end
            end
        end
    end

    --toggle whether real game-world nameplates show the fake aura preview. clears them once
    --on the transition to off so they do not keep the last painted icons frozen.
    function designer.SetAuraWorldPreview(enabled)
        if (enabled == isAuraWorldPreviewOn) then
            return
        end
        isAuraWorldPreviewOn = enabled
        if (not enabled) then
            clearWorldPlateFakeAuras()
        end
    end

    --create close button using the framework
    --local closeButton = detailsFramework:CreateCloseButton(editorMainFrame)
    --closeButton:SetPoint("topright", editorMainFrame, "topright", -3, -3)

    local canvasFrame = layoutEditor:GetCanvasScrollBox()
    canvasFrame:EnableMouse(false)

    local objectSelector = layoutEditor:GetObjectSelector()
    local optionsFrame = layoutEditor:GetOptionsFrame()
    optionsFrame:AdjustPointsOffset(-2, 0)

    --create a frame to guide the setting points on the empty area at the right side of the main frame, which is reserved for the preview
    local previewNameplateFrame = CreateFrame("Frame", "$parentGuideFrame", layoutEditor)
    createFrameTag(previewNameplateFrame, "previewPlateFrame")
    previewNameplateFrame:SetPoint("bottomleft", canvasFrame, "bottomright", 30, 0)
    previewNameplateFrame:SetPoint("topright", editorMainFrame, "topright", -5, -5)
    previewNameplateFrame:SetFrameLevel(layoutEditor:GetFrameLevel() + 1)

    local findWidgetExtraOptionTable = function(sectionName, tableName)
        local extraOptionsSection = options.WidgetSettingsExtraOptions[sectionName]
        if (extraOptionsSection) then
            for i = 1, #extraOptionsSection do
                local widgetExtraOption = extraOptionsSection[i]
                local optionCategoryName = widgetExtraOption.tableName
                if (optionCategoryName == tableName) then
                    return widgetExtraOption
                end
            end
        end
    end

    --plater only
    local onClickSelectPlateConfigOption = function(self, fixedParameter, newSubTablePath)
        subTablePath = newSubTablePath

        --update the paths in the mapping tables
        --cast bar:
        --options.WidgetSettingsMapTables.CastBar.width = "plate_config." .. subTablePath .. ".cast_incombat[1]"
        --options.WidgetSettingsMapTables.CastBar.height = "plate_config." .. subTablePath .. ".cast_incombat[2]"
        --local castOutOfCombatWidth = findWidgetExtraOptionTable("CastBar", "out_of_combat_cast_width")
        --castOutOfCombatWidth.key = "plate_config." .. subTablePath .. ".cast[1]"
        --local castOutOfCombatHeight = findWidgetExtraOptionTable("CastBar", "out_of_combat_cast_height")
        --castOutOfCombatHeight.key = "plate_config." .. subTablePath .. ".cast[2]"
        --local castBarOffsetX = findWidgetExtraOptionTable("CastBar", "castbar_offset_x")
        --castBarOffsetX.key = "plate_config." .. subTablePath .. ".castbar_offset_x"
        --local castBarOffsetY = findWidgetExtraOptionTable("CastBar", "castbar_offset_y")
        --castBarOffsetY.key = "plate_config." .. subTablePath .. ".castbar_offset"

        --health bar:
        --options.WidgetSettingsMapTables.HealthBar.width = "plate_config." .. subTablePath .. ".health_incombat[1]"
        --options.WidgetSettingsMapTables.HealthBar.height = "plate_config." .. subTablePath .. ".health_incombat[2]"
        --local healthOutOfCombatWidth = findWidgetExtraOptionTable("HealthBar", "out_of_combat_health_width")
        --healthOutOfCombatWidth.key = "plate_config." .. subTablePath .. ".health[1]"
        --local healthOutOfCombatHeight = findWidgetExtraOptionTable("HealthBar", "out_of_combat_health_height")
        --healthOutOfCombatHeight.key = "plate_config." .. subTablePath .. ".health[2]"

        --

        for index, objectInfo in ipairs(plateConfigObjectsInfo) do
            layoutEditor:UpdateProfileSubTablePath(objectInfo, subTablePath)
        end

        layoutEditor:Refresh()
    end

    ---@type dropdownoption[]
    local plateConfigOptions = {
        {label = "Enemy NPC", value = "enemynpc", onclick = onClickSelectPlateConfigOption},
        {label = "Friendly NPC", value = "friendlynpc", onclick = onClickSelectPlateConfigOption},
        {label = "Enemy Player", value = "enemyplayer", onclick = onClickSelectPlateConfigOption},
        {label = "Friendly Player", value = "friendlyplayer", onclick = onClickSelectPlateConfigOption},
    }

    --create df dropdown to select which plate config to edit
    local plateConfigDropdown = detailsFramework:CreateDropDown(previewNameplateFrame, function() return plateConfigOptions end, subTablePath, 160, 20)
    plateConfigDropdown:SetPoint("topleft", previewNameplateFrame, "topleft", 2, -13)
    plateConfigDropdown:SetTemplate(detailsFramework:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))

    local onSelectChangeAllFonts = function(self, fixedParameter, fontName)
        local SharedMedia = LibStub:GetLibrary("LibSharedMedia-3.0")
        local fontFile = SharedMedia:Fetch("font", fontName)

        local plateConfigs = {"enemynpc", "friendlynpc", "enemyplayer", "friendlyplayer", "player"}

        for i = 1, #plateConfigs do
            local plateTable = Plater.db.profile.plate_config[plateConfigs[i]]
            plateTable.actorname_text_font = fontName
            plateTable.spellname_text_font = fontName
            plateTable.spellpercent_text_font = fontName
            plateTable.level_text_font = fontName
            plateTable.percent_text_font = fontName
            plateTable.big_actortitle_text_font = fontName
            plateTable.big_actorname_text_font = fontName
            plateTable.power_percent_text_font = fontName
        end

        local profile = Plater.db.profile
        profile.castbar_target_font = fontName
        profile.aura_timer_text_font = fontName
        profile.aura_stack_font = fontName

        --update the font on all nameplates
        designer.UpdateAllNameplates()

        --refreshes the current object being edited
        layoutEditor:Refresh()

        local registeredObjects = layoutEditor:GetAllRegisteredObjects()
        for i = 1, #registeredObjects do
            local objectInfo = registeredObjects[i]
            local uiObject = objectInfo.object
            if (uiObject.GetObjectType and uiObject:GetObjectType() == "FontString") then
                ---@cast uiObject fontstring
                detailsFramework:SetFontFace(uiObject, fontFile)
            end
        end
    end

    local selectFontDropdown = detailsFramework:CreateFontDropDown(previewNameplateFrame, onSelectChangeAllFonts, 0, 160, 20)
    selectFontDropdown:SetPoint("topright", previewNameplateFrame, "topright", -2, -13)
    selectFontDropdown:SetTemplate(detailsFramework:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))
    selectFontDropdown.label:SetText("change all fonts")
    selectFontDropdown.icon:SetTexture([[Interface\AnimCreate\AnimCreateIcons]])
    selectFontDropdown.icon:SetTexCoord(0, 32/128, 64/128, 96/128)

    plateFrame = designer.CreatePreview(previewNameplateFrame)
    --createFrameTag(plateFrame, "nameplate")
    plateFrame:SetPoint("center", previewNameplateFrame, "center", 0, 50)
    plateFrame:SetScale(1.0)
    plateFrame:SetSize(180, 60)
    plateFrame.unit = "player"
    --platerInternal.Events.GetEventFunction("NAME_PLATE_UNIT_ADDED")("NAME_PLATE_UNIT_ADDED", "preview")

    ---@type unitframe
    local unitFrame = plateFrame.unitFrame
    ---@type healthbar
    local healthBar = unitFrame.healthBar
    healthBar:SetMinMaxValues(0, 1)
    healthBar:SetValue(0.7)
    ---@type castbar
    local castBar = unitFrame.castBar
    castBar:SetMinMaxValues(0, 1)
    castBar:SetValue(0.5)

    castBar:Show()
    castBar:AdjustPointsOffset(0, -30)

    --castBar:ClearAllPoints()

    --Plater_LayoutEditor
    --Plater_LayoutEditorGuideFrame
    --PlaterDesignerPlatePreview
    --^ parenting stair

    ---@type fontstring
    local unitName = unitFrame.unitName
    ---@type fontstring
    local levelText = healthBar.actorLevel
    ---@type fontstring
    local spellName = castBar.Text
    ---@type fontstring
    local lifePercent = healthBar.lifePercent_Safe
    ---@type fontstring
    local castPercentText = castBar.percentText
    ---@type fontstring
    local actorTitleSpecial = plateFrame.ActorTitleSpecial
    ---@type fontstring
    local actorNameSpecial = plateFrame.ActorNameSpecial
    ---@type fontstring
    local questOptionsFontString = unitFrame.QuestOptionsDummyFontString
    ---@type fontstring
    local castBarTargetName = castBar.TargetName
    ---@type fontstring
    local newcastBarTargetName = castBar.NewCastBarTargetName
    ---@type texture
    local castBarSpark = castBar.Spark

    local raidTargetIcon = unitFrame.PlaterRaidTargetFrame.RaidTargetIcon
    local raidTargetFrame = unitFrame.PlaterRaidTargetFrame
    --anchor the icon to its container so changes to PlaterRaidTargetFrame's scale/anchor
    --(from the Raid Mark widget's setters) actually move/scale the icon in the preview.
    raidTargetIcon:ClearAllPoints()
    raidTargetIcon:SetAllPoints(raidTargetFrame)
    raidTargetFrame:SetSize(20, 20)
    raidTargetFrame:SetScale(Plater.db.profile.indicator_raidmark_scale)
    Plater.SetAnchor(raidTargetFrame, Plater.db.profile.indicator_raidmark_anchor, unitFrame)
    raidTargetIcon:Show()
    SetRaidTargetIconTexture(raidTargetIcon, 5)

    spellName:SetText("Blizzard")
    unitName:SetText("Unit Name")
    levelText:SetText("60")
    lifePercent:SetText("80%")
    castPercentText:SetText("3.2s")
    actorNameSpecial:SetText("Unit Name When No Health Bar")
    actorTitleSpecial:SetText("Unit Title When No Health Bar")

    detailsFramework:SetFontSize(actorNameSpecial, Plater.db.profile.plate_config.enemynpc.big_actorname_text_size)
    detailsFramework:SetFontSize(actorTitleSpecial, Plater.db.profile.plate_config.enemynpc.big_actortitle_text_size)

    actorNameSpecial:ClearAllPoints()
    actorNameSpecial:SetPoint("bottomleft", previewNameplateFrame, "bottomleft", 5, 40)
    actorTitleSpecial:ClearAllPoints()
    actorTitleSpecial:SetPoint("top", actorNameSpecial, "bottom", 0, -2)

    --Plater.db.profile
    local profileRoot = Plater.db.profile
    local rootKey = "" --as the settings are in the root of the profile table, there is no path to pass
    --profileRoot.plate_config
    local plateConfig = profileRoot.plate_config

    local onSettingChanged = function(UIObject, optionKey, newValue, profileTable, profileKey)
        --plater only, change the incombat and outofcombat settings together
        if profileKey:find("health_incombat") then
            if optionKey == "width" then
                healthBar:SetSize(newValue, healthBar:GetHeight())
                profileTable.health[1] = newValue
            else
                healthBar:SetSize(healthBar:GetWidth(), newValue)
                profileTable.health[2] = newValue --height
            end
        end

        if profileKey:find("cast_incombat") then
            if optionKey == "width" then
                profileTable.cast[1] = newValue
                local castBarOffSetX = plateConfig[subTablePath].castbar_offset_x
                local castBarOffSetXRel = (healthBar:GetWidth() - newValue) / 2
                --local castBarOffSetY = plateConfig.castbar_offset --override by -30 pixels
                PixelUtil.SetPoint (castBar, "topleft", healthBar, "bottomleft", castBarOffSetXRel + castBarOffSetX, -30)
                PixelUtil.SetPoint (castBar, "topright", healthBar, "bottomright", -castBarOffSetXRel + castBarOffSetX, -30)
            else
                profileTable.cast[2] = newValue --height
            end
        end

        if (optionKey == "anchor") then
            local anchorTable = detailsFramework.table.getfrompath(profileTable, profileKey, 1)
            anchorTable.x = 0
            anchorTable.y = 0

            C_Timer.After(0, function()
                --layoutEditor:PrepareObjectForEditing()
            end)
        end

        designer.UpdateAllNameplates()
    end

    ---@type df_editobjectoptions
    local editObjectDefaultOptions = {
        use_colon = false, --colon after the localizedLabel
        can_move = true,
        use_guide_lines = false,
        text_template = detailsFramework:GetTemplate("font", "OPTIONS_FONT_TEMPLATE"),
    }

    local editObjectNoMoveOptions = detailsFramework.table.copy({}, editObjectDefaultOptions)
    editObjectNoMoveOptions.can_move = false

    actorNameSpecial:Show()
    actorTitleSpecial:Show()
    --castBarTargetName:Show()

    local previousCastbarTargetShow = Plater.db.profile.castbar_target_show
    Plater.db.profile.castbar_target_show = true
    Plater.UpdateCastbarTargetText(castBar, newcastBarTargetName)
    Plater.db.profile.castbar_target_show = previousCastbarTargetShow

    newcastBarTargetName:Show()
    newcastBarTargetName:SetText("Target Name")

    --by registering the object within the editor, the the object will show up in the list of widgets to select

    --pathstring: a string containing dots or brackets to reach the subtable where the settings are stored
    --example: "nameplate.texts.colors.out_of_combat_color[1]" > would return the first value of the out_of_combat_color table

    --[[
        RegisterObject(self, object:uiobject, localizedLabel:string, id:string, profileTable:table, subTablePath:pathstring, profileKeyMap:table, extraOptions:table, callback:function, options:table, refFrame:uiobject)
        object: the uiobject to be edited (error if invalid)
        localizedLabel: the name shown in the list
        id: a string with a unique id for the object, used with EditObjectById(ID)
        profileTable: the table where the settings are stored
        subTablePath: a pathstring within the profile table where the settings are stored, support pathstring
        profileKeyMap: a table mapping the default editor options to the keys used in the profile table. see 'Plater_Designer_Objects.lua' file.
        extraOptions: a table containing extra options to be added to the editor, see 'Plater_Designer_Objects.lua' file.
        callback: a function called when a setting is changed, parameters are (UIObject, optionKey, newValue, profileTable:table, subTablePath:pathstring)
        options: a table containing options for the registered object.
        refFrame: a uiobject used as reference the anchor point.
    ]]

    --~register

    ---@type df_editor_objectinfo
    local objectInfo

    --plateConfig objects are objects where all settings are within the plate_config table

    --quest options:
    local questOptions = detailsFramework.table.copy({}, editObjectDefaultOptions)
    questOptions.icon = "QuestNormal" --atlas name
    questOptions.can_move = false
    objectInfo = layoutEditor:RegisterObject(questOptionsFontString, "Quest Options", "QUESTOPTIONS", plateConfig, subTablePath, options.WidgetSettingsMapTables.QuestOptions, options.WidgetSettingsExtraOptions.QuestOptions, onSettingChanged, questOptions, unitFrame)
    plateConfigObjectsInfo[#plateConfigObjectsInfo+1] = objectInfo

    --nameplate bar size
    ---@type df_editobjectoptions
    local nameplateSizeOptions = detailsFramework.table.copy({}, editObjectDefaultOptions)
    nameplateSizeOptions.can_move = false
    nameplateSizeOptions.can_click = false --healthBar.dummy fully overlaps the health bar; let those clicks reach Health Bar / Life Percent
    objectInfo = layoutEditor:RegisterObject(healthBar.dummy, "Nameplate Size", "NAMEPLATE_SIZE", plateConfig, subTablePath, options.WidgetSettingsMapTables.NameplateSize, options.WidgetSettingsExtraOptions.NameplateSize, onSettingChanged, nameplateSizeOptions, healthBar)
    plateConfigObjectsInfo[#plateConfigObjectsInfo+1] = objectInfo


    --health options
    ---@type df_editobjectoptions
    local healthBarOptions = detailsFramework.table.copy({}, editObjectDefaultOptions)
    healthBarOptions.can_move = false
    healthBarOptions.icon = [[Interface\AddOns\Plater\images\healbar_icon.png]]
    objectInfo = layoutEditor:RegisterObject(healthBar, "Health Bar", "HEALTHBAR", profileRoot, rootKey, options.WidgetSettingsMapTables.HealthBar, options.WidgetSettingsExtraOptions.HealthBar, onSettingChanged, healthBarOptions, healthBar)

    --target highlight, overlay, indicator
    ---@type df_editobjectoptions
    local targetOptions = detailsFramework.table.copy({}, editObjectDefaultOptions)
    targetOptions.can_move = false
    objectInfo = layoutEditor:RegisterObject(healthBar.dummyTarget, "Target", "TARGET", profileRoot, rootKey, options.WidgetSettingsMapTables.Target, options.WidgetSettingsExtraOptions.Target, onSettingChanged, targetOptions, healthBar)

    --focus widget uses its own dummy bar above the target bar
    ---@type df_editobjectoptions
    local focusOptions = detailsFramework.table.copy({}, editObjectDefaultOptions)
    focusOptions.can_move = false
    objectInfo = layoutEditor:RegisterObject(healthBar.dummyFocus, "Focus", "FOCUS", profileRoot, rootKey, options.WidgetSettingsMapTables.Focus, options.WidgetSettingsExtraOptions.Focus, onSettingChanged, focusOptions, healthBar)

    --raid mark (the icon on the right of the health bar)
    ---@type df_editobjectoptions
    local raidMarkOptions = detailsFramework.table.copy({}, editObjectDefaultOptions)
    --raidMarkOptions.can_move = false
    objectInfo = layoutEditor:RegisterObject(unitFrame.PlaterRaidTargetFrame, "Raid Mark", "RAIDMARK", profileRoot, rootKey, options.WidgetSettingsMapTables.RaidMark, options.WidgetSettingsExtraOptions.RaidMark, onSettingChanged, raidMarkOptions, unitFrame)

    --aggro colors (threat, override) global settings, top-level entry
    ---@type df_editobjectoptions
    local colorsOptions = detailsFramework.table.copy({}, editObjectDefaultOptions)
    colorsOptions.can_move = false
    objectInfo = layoutEditor:RegisterObject(healthBar.dummyColors, "Aggro Colors", "COLORS", profileRoot, rootKey, options.WidgetSettingsMapTables.Colors, options.WidgetSettingsExtraOptions.Colors, onSettingChanged, colorsOptions, healthBar)

    --midnight mob colors (unit-type coloring) global settings, no canvas anchor, top-level entry
    ---@type df_editobjectoptions
    local midnightMobColorsOptions = detailsFramework.table.copy({}, editObjectDefaultOptions)
    midnightMobColorsOptions.can_move = false
    midnightMobColorsOptions.can_click = false
    objectInfo = layoutEditor:RegisterObject(healthBar.dummyMidnightMobColors, "Midnight Mob Colors", "MIDNIGHTMOBCOLORS", profileRoot, rootKey, options.WidgetSettingsMapTables.MidnightMobColors, options.WidgetSettingsExtraOptions.MidnightMobColors, onSettingChanged, midnightMobColorsOptions, healthBar)

    --auras (buffs and debuffs above the health bar). buffFrame is the registration target so
    --the user can also click the aura cluster in the preview to select this widget.
    ---@type df_editobjectoptions
    local aurasOptions = detailsFramework.table.copy({}, editObjectDefaultOptions)
    aurasOptions.can_move = false
    objectInfo = layoutEditor:RegisterObject(unitFrame.BuffFrame, "Auras Layout", "AURAS", profileRoot, rootKey, options.WidgetSettingsMapTables.Auras, options.WidgetSettingsExtraOptions.Auras, onSettingChanged, aurasOptions, unitFrame)

    --aura automatic tracking (which buffs/debuffs Plater picks up). visible auto-tracking
    --button above the target bar gives the user an on-canvas way to select this widget.
    --nested under Auras Layout in the object selector.
    ---@type df_editobjectoptions
    local auraTrackingOptions = detailsFramework.table.copy({}, editObjectDefaultOptions)
    auraTrackingOptions.can_move = false
    auraTrackingOptions.parentId = "AURAS"
    objectInfo = layoutEditor:RegisterObject(healthBar.dummyAuraTracking, "Aura Automatic Tracking", "AURATRACKING", profileRoot, rootKey, options.WidgetSettingsMapTables.AuraTracking, options.WidgetSettingsExtraOptions.AuraTracking, onSettingChanged, auraTrackingOptions, healthBar)

    --aura border colors. visible "border colors" button above the auto-tracking button
    --gives the user an on-canvas way to select this widget. nested under Auras Layout.
    ---@type df_editobjectoptions
    local auraBorderColorsOptions = detailsFramework.table.copy({}, editObjectDefaultOptions)
    auraBorderColorsOptions.can_move = false
    auraBorderColorsOptions.parentId = "AURAS"
    objectInfo = layoutEditor:RegisterObject(healthBar.dummyAuraBorderColors, "Aura Border Colors", "AURABORDERCOLORS", profileRoot, rootKey, options.WidgetSettingsMapTables.AuraBorderColors, options.WidgetSettingsExtraOptions.AuraBorderColors, onSettingChanged, auraBorderColorsOptions, healthBar)

    --stack counter. visible "stacks" button sits above the buff icons for on-canvas selection.
    --nested under Auras Layout.
    ---@type df_editobjectoptions
    local stackCounterOptions = detailsFramework.table.copy({}, editObjectDefaultOptions)
    stackCounterOptions.can_move = false
    stackCounterOptions.parentId = "AURAS"
    objectInfo = layoutEditor:RegisterObject(healthBar.dummyStackCounter, "Stack Counter", "STACKCOUNTER", profileRoot, rootKey, options.WidgetSettingsMapTables.StackCounter, options.WidgetSettingsExtraOptions.StackCounter, onSettingChanged, stackCounterOptions, healthBar)

    --aura timer. the clickable overlay sits over the 3rd and 4th buff icons (positioned each
    --tick by the driver) so clicking those icons selects this widget. nested under Auras Layout.
    ---@type df_editobjectoptions
    local auraTimerOptions = detailsFramework.table.copy({}, editObjectDefaultOptions)
    auraTimerOptions.can_move = false
    auraTimerOptions.parentId = "AURAS"
    objectInfo = layoutEditor:RegisterObject(healthBar.dummyAuraTimer, "Aura Timer", "AURATIMER", profileRoot, rootKey, options.WidgetSettingsMapTables.AuraTimer, options.WidgetSettingsExtraOptions.AuraTimer, onSettingChanged, auraTimerOptions, healthBar)

    --indicators (pet/execute/boss/class icons, etc.). the indicator selector frame sits on the
    --left of the health bar (via indicator_anchor) and is clickable to select this widget.
    ---@type df_editobjectoptions
    local indicatorsOptions = detailsFramework.table.copy({}, editObjectDefaultOptions)
    indicatorsOptions.can_move = false
    objectInfo = layoutEditor:RegisterObject(healthBar.dummyIndicators, "Indicators", "INDICATORS", profileRoot, rootKey, options.WidgetSettingsMapTables.Indicators, options.WidgetSettingsExtraOptions.Indicators, onSettingChanged, indicatorsOptions, healthBar)

    --shared options for the text widgets that live inside the Health Bar group
    --(copies the defaults so the parentId does not leak onto every other registration).
    ---@type df_editobjectoptions
    local inHealthBarGroupOptions = detailsFramework.table.copy({}, editObjectDefaultOptions)
    inHealthBarGroupOptions.parentId = "HEALTHBAR"

    objectInfo = layoutEditor:RegisterObject(unitName, "Unit Name", "UNITNAME", plateConfig, subTablePath, options.WidgetSettingsMapTables.UnitName, options.WidgetSettingsExtraOptions.UnitName, onSettingChanged, inHealthBarGroupOptions, healthBar)
    plateConfigObjectsInfo[#plateConfigObjectsInfo+1] = objectInfo

    objectInfo = layoutEditor:RegisterObject(levelText, "Unit Level", "UNITLEVEL", plateConfig, subTablePath, options.WidgetSettingsMapTables.UnitLevel, options.WidgetSettingsExtraOptions.UnitLevel, onSettingChanged, inHealthBarGroupOptions, healthBar)
    plateConfigObjectsInfo[#plateConfigObjectsInfo+1] = objectInfo
    objectInfo = layoutEditor:RegisterObject(lifePercent, "Life Percent", "LIFEPERCENT", plateConfig, subTablePath, options.WidgetSettingsMapTables.LifePercent, options.WidgetSettingsExtraOptions.LifePercent, onSettingChanged, inHealthBarGroupOptions, healthBar)
    plateConfigObjectsInfo[#plateConfigObjectsInfo+1] = objectInfo
    platerInternal.UpdatePercentTextLayout(lifePercent, plateConfig[subTablePath])

    --execute range (profileRoot-bound; intentionally NOT in plateConfigObjectsInfo - the
    --plate-config dropdown only repoints registrations whose values live under plate_config.*)
    objectInfo = layoutEditor:RegisterObject(healthBar.healthCutOff, "Execute Range", "EXECUTERANGE", profileRoot, rootKey, options.WidgetSettingsMapTables.ExecuteRange, options.WidgetSettingsExtraOptions.ExecuteRange, onSettingChanged, editObjectNoMoveOptions, healthBar)

    --actor title and name special
    objectInfo = layoutEditor:RegisterObject(actorNameSpecial, "Big Unit Name", "BIGUNITNAME", plateConfig, subTablePath, options.WidgetSettingsMapTables.BigUnitName, options.WidgetSettingsExtraOptions.BigUnitName, onSettingChanged, editObjectNoMoveOptions, plateFrame)
    plateConfigObjectsInfo[#plateConfigObjectsInfo+1] = objectInfo
    objectInfo = layoutEditor:RegisterObject(actorTitleSpecial, "Big Unit Title", "BIGUNITTITLE", plateConfig, subTablePath, options.WidgetSettingsMapTables.BigActorTitle, options.WidgetSettingsExtraOptions.BigActorTitle, onSettingChanged, editObjectNoMoveOptions, plateFrame)
    plateConfigObjectsInfo[#plateConfigObjectsInfo+1] = objectInfo

    --cast bar [no plate config]
    --cast bar has settings both in plate_config and in the root file of profile
    ---@type df_editobjectoptions
    local castBarOptions = detailsFramework.table.copy({}, editObjectDefaultOptions)
    castBarOptions.can_move = false
    objectInfo = layoutEditor:RegisterObject(castBar, "Cast Bar", "CASTBAR", plateConfig, subTablePath, options.WidgetSettingsMapTables.CastBar, options.WidgetSettingsExtraOptions.CastBar, onSettingChanged, castBarOptions, castBar)
    plateConfigObjectsInfo[#plateConfigObjectsInfo+1] = objectInfo

    --shared options for the text widgets that live inside the Cast Bar group
    --(copies the defaults so the parentId does not leak onto every other registration).
    ---@type df_editobjectoptions
    local inCastBarGroupOptions = detailsFramework.table.copy({}, editObjectDefaultOptions)
    inCastBarGroupOptions.parentId = "CASTBAR"

    objectInfo = layoutEditor:RegisterObject(spellName, "Cast Spell Name", "CASTSPELLNAME", plateConfig, subTablePath, options.WidgetSettingsMapTables.SpellName, options.WidgetSettingsExtraOptions.SpellName, onSettingChanged, inCastBarGroupOptions, castBar)
    plateConfigObjectsInfo[#plateConfigObjectsInfo+1] = objectInfo
    objectInfo = layoutEditor:RegisterObject(castPercentText, "Cast Time", "CASTSPELLTIME", plateConfig, subTablePath, options.WidgetSettingsMapTables.SpellCastTime, options.WidgetSettingsExtraOptions.SpellCastTime, onSettingChanged, inCastBarGroupOptions, castBar)
    plateConfigObjectsInfo[#plateConfigObjectsInfo+1] = objectInfo

    --[no plate config]
    ---@type df_editobjectoptions
    local sparkOptions = detailsFramework.table.copy({}, editObjectDefaultOptions)
    sparkOptions.can_move = false
    sparkOptions.parentId = "CASTBAR"
    objectInfo = layoutEditor:RegisterObject(newcastBarTargetName, "Cast Target Name", "CASTTARGETNAME", profileRoot, rootKey, options.WidgetSettingsMapTables.CastBarTargetName, options.WidgetSettingsExtraOptions.CastBarTargetName, onSettingChanged, sparkOptions, castBar.FrameOverlay)
    --[no plate config]
    objectInfo = layoutEditor:RegisterObject(castBarSpark, "Cast Spark", "CASTSPARK", profileRoot, rootKey, options.WidgetSettingsMapTables.CastBarSpark, options.WidgetSettingsExtraOptions.CastBarSpark, onSettingChanged, sparkOptions, castBar.FrameOverlay)

    --designer.RefreshLayout()

    --select the first object
    layoutEditor:EditObjectByIndex(2)

    editorMainFrame:SetAlpha(1)

    local disabledAlpha = 0.2
    local curCastBarValue = 0

    local moveUpFrame = CreateFrame("frame", nil, editorMainFrame)
    moveUpFrame:SetScript("OnUpdate", function(self, deltaTime)
        --plateFrame.unitFrame:SetFrameStrata("HIGH")
        plateFrame:SetFrameLevel(previewNameplateFrame:GetFrameLevel() + 100)
        --unitFrame:Show()
        --healthBar:Show()
        --plateFrame.unitName:SetText()
        --stops when the frame hides
        --dv(plateFrame)

        unitFrame.HighlightFrame.unit = "player"
        unitFrame.HighlightFrame:Show()

        --castBarTargetName:Show()
        castBar:Show()
        castBar:SetMinMaxValues(0, 3)
        castBar:SetValue(isCastBarSelected and curCastBarValue or 0)
        castBar.Icon:SetTexture(135815)

        healthBar.healthCutOff:SetPoint("left", healthBar, "left", healthBar:GetWidth()*0.2, 0)
        healthBar.healthCutOff:SetSize(healthBar:GetHeight(), healthBar:GetHeight())
        healthBar.healthCutOff:Show()

        if (Plater.db.profile.target_highlight) then
            healthBar.dummyTargetBar.NeonUp:Show()
            healthBar.dummyTargetBar.NeonDown:Show()
        else
            healthBar.dummyTargetBar.NeonUp:Hide()
            healthBar.dummyTargetBar.NeonDown:Hide()
        end

        if (isTargetSelected) then
            unitFrame.targetOverlayTexture:Show()
        else
            unitFrame.targetOverlayTexture:Hide()
        end

        --focus preview (texture and color pulled live so dropdown changes reflect immediately)
        if (isFocusSelected and Plater.db.profile.focus_indicator_enabled) then
            local SharedMedia = LibStub:GetLibrary("LibSharedMedia-3.0")
            local focusTexture = SharedMedia:Fetch("statusbar", Plater.db.profile.focus_texture)
            healthBar.FocusIndicator:SetTexture(focusTexture)
            healthBar.FocusIndicator:SetVertexColor(unpack(Plater.db.profile.focus_color))
            healthBar.FocusIndicator:Show()
        else
            healthBar.FocusIndicator:Hide()
        end

        --preview hover-over highlight
        if (Plater.db.profile.hover_highlight and healthBar:IsMouseOver()) then
            healthBar.dummyTargetBar.HoverHighlight:Show()
        else
            healthBar.dummyTargetBar.HoverHighlight:Hide()
        end

        if (Plater.db.profile.indicator_extra_raidmark) then
            healthBar.ExtraRaidMark:Show()
            healthBar.ExtraRaidMark:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]])
            SetRaidTargetIconTexture(healthBar.ExtraRaidMark, 6)
            local height = healthBar:GetHeight() - 2
            plateFrame.RaidTarget:SetSize (height, height)
            plateFrame.RaidTarget:SetAlpha (.4)
        else
            healthBar.ExtraRaidMark:Hide()
        end

        SetRaidTargetIconTexture(raidTargetIcon, 6)
        raidTargetIcon:Show()

        if (curCastBarValue >= 3) then
            curCastBarValue = 0
        else
            if not isCastBarSelected then
                curCastBarValue = 0
            else
                curCastBarValue = curCastBarValue + deltaTime
            end
        end

        if (curCastBarValue > 0) then
            castBarSpark:Show()
            castBarSpark:SetVertexColor(unpack(Plater.db.profile.cast_statusbar_spark_color))
            castBarSpark:SetAlpha(Plater.db.profile.cast_statusbar_spark_alpha)
            PixelUtil.SetSize(castBarSpark, Plater.db.profile.cast_statusbar_spark_width, castBar:GetHeight())
            --half spark (crops the texture to the left half so only one side is shown)
            if (Plater.db.profile.cast_statusbar_spark_half) then
                castBarSpark:SetTexCoord(0, 0.5, 0, 1)
            else
                castBarSpark:SetTexCoord(0, 1, 0, 1)
            end
            --offset (anchored at the right edge of the bar's fill, shifted by the profile value)
            castBarSpark:ClearAllPoints()
            PixelUtil.SetPoint(castBarSpark, "center", castBar.barTexture, "right", Plater.db.profile.cast_statusbar_spark_offset, 0)
        end

        --castBarTargetName:SetText("Target Name")
        --castBarTargetName:Show()

        --[=[ spark debug
        local np = NamePlate1
        local npcastBar = np and np.unitFrame and np.unitFrame.castBar
        local spark = npcastBar and npcastBar.Spark
        dv(spark)
        --]=]

        --percent text disabled
        --lifePercent:SetAlpha(plateConfig[subTablePath].percent_text_enabled and 1 or disabledAlpha)
        --unit level disabled
        --levelText:SetAlpha(plateConfig[subTablePath].level_text_enabled and 1 or disabledAlpha)

    end)


    editorMainFrame:SetScript("OnShow", function()
        previewNameplateFrame:Show()
        plateFrame:Show()
        layoutEditor:Show()
        plateFrame:Show()
        actorTitleSpecial:Show()
        actorNameSpecial:Show()
        healthBar:Show()
        plateFrame.unitFrame:SetUnit("player")
        unitName:SetText("Unit Name")
        unitName:Show()
        unitFrame.BuffFrame:Show()
        unitFrame.BuffFrame2:Show()

        plateFrame.unitFrame:SetParent(UIParent)
        plateFrame.unitFrame:SetFrameStrata("FULLSCREEN")
        plateFrame.unitFrame:Show()

        --aura preview runs the whole time the designer tab is visible, not just when the
        --Auras Layout widget is selected.
        designer.StartAuraTest()
    end)

    editorMainFrame:SetScript("OnHide", function()
        previewNameplateFrame:Hide()
        plateFrame:Hide()
        layoutEditor:Hide()
        plateFrame:Hide()
        plateFrame.unitFrame:SetUnit(nil)

        actorTitleSpecial:Hide()
        actorNameSpecial:Hide()

        C_Timer.After(1, function()
            plateFrame:Hide()
        end)

        unitFrame.BuffFrame:Hide()
        unitFrame.BuffFrame2:Hide()

        if isCastBarSelected then
            isCastBarSelected = false
            Plater.StopCastBarTest()
        end

        designer.StopAuraTest()

        plateFrame.unitFrame:SetParent(editorMainFrame)
        plateFrame.unitFrame:Hide()
    end)

    --/plater editmode

end


function Plater.UpdateCustomDesign(unitFrame)




end

function Plater.CreateCustomDesignBorder(frame) --need review
    local frameBorderCustom = CreateFrame ("frame", nil, frame)
    frameBorderCustom:SetPoint("topleft", frame, "topleft", -1, 1)
    frameBorderCustom:SetPoint("bottomright", frame, "bottomright", 1, -1)
    frame.customborder = frameBorderCustom
    frameBorderCustom.texture = frameBorderCustom:CreateTexture(nil, "overlay")
    frameBorderCustom.texture:SetAllPoints()
    frameBorderCustom:Hide()
end

--set the preview indicator texture to resemble a given indicator type. mirrors the texture
--setup in Plater.AddIndicator (Plater.lua). used for the default icon and the hover preview
--on the Indicators options. safe to call before the preview exists (no-op then).
function designer.SetIndicatorPreview(indicatorType)
    local previewPlate = designer.plateFrame
    if (not previewPlate or not previewPlate.unitFrame) then
        return
    end
    local selector = previewPlate.unitFrame.healthBar.dummyIndicators
    if (not selector) then
        return
    end

    local texture = selector.texture
    texture:SetTexCoord(0, 1, 0, 1)
    texture:SetVertexColor(1, 1, 1)
    texture:SetDesaturated(false)

    if (indicatorType == "pet") then
        texture:SetTexture([[Interface\AddOns\Plater\images\peticon]])

    elseif (indicatorType == "Horde") then
        texture:SetTexture([[Interface\PVPFrame\PVP-Currency-Horde]])

    elseif (indicatorType == "Alliance") then
        texture:SetTexture([[Interface\PVPFrame\PVP-Currency-Alliance]])
        texture:SetTexCoord(4/32, 29/32, 2/32, 30/32)

    elseif (indicatorType == "elite") then
        texture:SetTexture([[Interface\GLUES\CharacterSelect\Glues-AddOn-Icons]])
        texture:SetTexCoord(0.75, 1, 0, 1)
        texture:SetVertexColor(1, .8, 0)

    elseif (indicatorType == "rare") then
        texture:SetTexture([[Interface\GLUES\CharacterSelect\Glues-AddOn-Icons]])
        texture:SetTexCoord(0.75, 1, 0, 1)
        texture:SetDesaturated(true)

    elseif (indicatorType == "quest") then
        texture:SetTexture([[Interface\TARGETINGFRAME\PortraitQuestBadge]])
        texture:SetTexCoord(2/32, 26/32, 1/32, 31/32)

    elseif (indicatorType == "classicon") then
        local _, class = UnitClass("player")
        if (class) then
            texture:SetTexture([[Interface\GLUES\CHARACTERCREATE\UI-CharacterCreate-Classes]])
            texture:SetTexCoord(unpack(CLASS_ICON_TCOORDS[class]))
        end

    elseif (indicatorType == "specicon") then
        local specTexture = [[Interface\Icons\INV_Misc_QuestionMark]]
        local specIndex = GetSpecialization and GetSpecialization()
        if (specIndex) then
            local _, _, _, icon = GetSpecializationInfo(specIndex)
            specTexture = icon or specTexture
        end
        texture:SetTexture(specTexture)

    elseif (indicatorType == "worldboss") then
        texture:SetTexture([[Interface\Scenarios\ScenarioIcon-Boss]])
    end

    selector:SetScale(Plater.db.profile.indicator_scale)
end

--plateFrame.PlateConfig = DB_PLATE_CONFIG.enemynpc

function designer.CreatePreview(parent)
    plateFrame = CreateFrame("frame", "PlaterDesignerPlatePreview", parent)
    --share the preview plate with sibling files (Plater_Designer_Objects.lua setters)
    designer.plateFrame = plateFrame
    plateFrame.isDesigner = true

    plateFrame.UnitFrame = CreateFrame("frame", "$parentDummyUnitFrame", plateFrame) --blizzard's unit frame placeholder

    plateFrame:SetScale(1.5)
    plateFrame.SetStackingBoundsFrame = function() end

    --simulate the creation of a game's nameplate, this creates the nameplate.unitFrame and its widgets
    platerInternal.Events.GetEventFunction("NAME_PLATE_CREATED")("NAME_PLATE_CREATED", plateFrame)


    designer.UpdatePreview()

    return plateFrame
end


function designer.UpdatePreview()
    local DB_NAME_NPCENEMY_ANCHOR = platerInternal.VarSharing.DB_NAME_NPCENEMY_ANCHOR
    local DB_PLATE_CONFIG = platerInternal.VarSharing.DB_PLATE_CONFIG
    local DB_CASTBAR_HIDE_ENEMIES = platerInternal.VarSharing.DB_CASTBAR_HIDE_ENEMIES

    local unitFrame = plateFrame.unitFrame
    local plateConfigs = getProfileTable()
    local needReset = true

    local reaction = 4 --enemy

    local unitID = "player"
    unitFrame:SetUnit(unitID)
    unitFrame.unit = unitID
    unitFrame.namePlateUnitToken = unitID
    unitFrame.displayedUnit = unitID
    plateFrame.unit = unitID
    plateFrame.OnTickFrame.unit = unitID
    plateFrame.OnTickFrame.actorType = ACTORTYPE_ENEMY_NPC
    unitFrame.PlaterOnScreen = true

    local unitName = unitFrame.unitName
    plateFrame.unitNameInternal = unitName

    unitName:SetText(UnitName(unitID))
    plateFrame.CurrentUnitNameString = unitName

    local actorNameSpecial = unitFrame.ActorNameSpecial
    local actorTitleSpecial = unitFrame.ActorTitleSpecial

    local healthBar = unitFrame.healthBar
    local powerBar = unitFrame.powerBar
    local castBar = unitFrame.castBar
    local castBar2 = unitFrame.castBar2

    local raidTargetIcon = plateFrame.unitFrame.PlaterRaidTargetFrame.RaidTargetIcon
    raidTargetIcon:SetPoint("left", healthBar, "right", 10, 0)
    SetRaidTargetIconTexture(raidTargetIcon, 8)

    local dummyHealthBar = CreateFrame("frame", nil, healthBar)
    dummyHealthBar:SetAllPoints()
    healthBar.dummy = dummyHealthBar

    --colors button (sits to the right of the raid mark, click selects the Colors widget)
    --anchored to healthBar (not the raid mark) so the height matches the target and focus bars.
    local colorsButton = CreateFrame("frame", nil, healthBar, "BackdropTemplate")
    healthBar.dummyColors = colorsButton
    colorsButton:SetFrameLevel(healthBar:GetFrameLevel() - 2)
    colorsButton:SetPoint("topleft", healthBar, "topleft", 0, 0)
    colorsButton:SetPoint("bottomleft", healthBar, "bottomleft", 0, 0)
    colorsButton:SetPoint("topright", healthBar, "topright", 90, 0)
    colorsButton:SetPoint("bottomright", healthBar, "bottomright", 90, 0)
    colorsButton:SetBackdrop({bgFile = [[Interface\ChatFrame\ChatFrameBackground]], edgeFile = [[Interface\Buttons\WHITE8X8]], tile = true, tileSize = 16, edgeSize = 1, insets = {left = 1, right = 1, top = 1, bottom = 1}})
    colorsButton:SetBackdropColor(0, 0, 0, 0.1)
    colorsButton:SetBackdropBorderColor(.2, .2, .2, 0.5)

    local textureBlue = colorsButton:CreateTexture(nil, "overlay")
    textureBlue:SetColorTexture(0, 0, 1, 1)
    textureBlue:SetWidth(6)
    textureBlue:SetPoint("topright", colorsButton, "topright", -1, -1)
    textureBlue:SetPoint("bottomright", colorsButton, "bottomright", -1, 1)

    local textureGreen = colorsButton:CreateTexture(nil, "overlay")
    textureGreen:SetColorTexture(0, 1, 0, 1)
    textureGreen:SetWidth(6)
    textureGreen:SetPoint("topright", textureBlue, "topleft", 0, 0)
    textureGreen:SetPoint("bottomright", textureBlue, "bottomleft", 0, 0)

    local textureRed = colorsButton:CreateTexture(nil, "overlay")
    textureRed:SetColorTexture(1, 0, 0, 1)
    textureRed:SetWidth(6)
    textureRed:SetPoint("topright", textureGreen, "topleft", 0, 0)
    textureRed:SetPoint("bottomright", textureGreen, "bottomleft", 0, 0)

    colorsButton.text = colorsButton:CreateFontString(nil, "overlay", "GameFontNormal")
    colorsButton.text:SetPoint("right", textureRed, "left", -7, 0)
    colorsButton.text:SetText("colors")
    detailsFramework:SetFontSize(colorsButton.text, 9)
    detailsFramework:SetFontColor(colorsButton.text, "silver")

    --invisible anchor for the Midnight Mob Colors widget (unit-type coloring options).
    --no on-canvas slot today, selectable from the sidebar object list.
    local dummyMidnightMobColors = CreateFrame("frame", nil, healthBar)
    dummyMidnightMobColors:SetAllPoints()
    healthBar.dummyMidnightMobColors = dummyMidnightMobColors

    --indicator selector frame. positioned by the indicator_anchor profile (SetAnchor) so it
    --sits exactly where a real indicator icon renders (left of the health bar by default).
    --click selects the Indicators widget. holds one preview texture (real AddIndicator can
    --stack several; the preview shows just one). default is the elite icon; hovering an
    --indicator option in the list swaps the shown icon to that indicator.
    local indicatorSelector = CreateFrame("frame", nil, healthBar)
    indicatorSelector:SetSize(16, 16)
    indicatorSelector:SetFrameLevel(healthBar:GetFrameLevel() + 5)
    healthBar.dummyIndicators = indicatorSelector
    Plater.SetAnchor(indicatorSelector, Plater.db.profile.indicator_anchor)

    local indicatorTexture = indicatorSelector:CreateTexture(nil, "overlay")
    indicatorTexture:SetAllPoints()
    indicatorSelector.texture = indicatorTexture

    --default to the elite icon.
    designer.SetIndicatorPreview("elite")

    --visible "auto tracking" button. anchored to the right edge of the BuffFrame (the aura
    --cluster) so it sits alongside the aura icons, not on top of them. click selects the
    --Aura Automatic Tracking widget.
    local autoTrackingButton = CreateFrame("frame", nil, healthBar, "BackdropTemplate")
    healthBar.dummyAuraTracking = autoTrackingButton
    autoTrackingButton:SetSize(90, 14)
    autoTrackingButton:SetPoint("topleft", unitFrame.BuffFrame, "topleft", -80, 0)
    autoTrackingButton:SetPoint("bottomleft", unitFrame.BuffFrame, "bottomleft", -80, 0)
    autoTrackingButton:SetPoint("topright", unitFrame.BuffFrame, "topright", 2, 0)
    autoTrackingButton:SetPoint("bottomright", unitFrame.BuffFrame, "bottomright", 2, 0)
    autoTrackingButton:SetBackdrop({bgFile = [[Interface\ChatFrame\ChatFrameBackground]], edgeFile = [[Interface\Buttons\WHITE8X8]], tile = true, tileSize = 16, edgeSize = 1, insets = {left = 1, right = 1, top = 1, bottom = 1}})
    autoTrackingButton:SetBackdropColor(0, 0, 0, 0.1)
    autoTrackingButton:SetBackdropBorderColor(.2, .2, .2, 0.5)
    autoTrackingButton.text = autoTrackingButton:CreateFontString(nil, "overlay", "GameFontNormal")
    autoTrackingButton.text:SetPoint("left", autoTrackingButton, "left", 4, 0)
    autoTrackingButton.text:SetText("aura tracking")
    detailsFramework:SetFontSize(autoTrackingButton.text, 9)
    detailsFramework:SetFontColor(autoTrackingButton.text, "silver")

    --visible "border colors" button stacked above auto tracking, sharing its LEFT and RIGHT
    --edges (same way the colors button shares its left edge with the health bar). click
    --selects the Aura Border Colors widget.
    local borderColorsButton = CreateFrame("frame", nil, healthBar, "BackdropTemplate")
    healthBar.dummyAuraBorderColors = borderColorsButton
    borderColorsButton:SetHeight(14)
    borderColorsButton:SetPoint("topleft", unitFrame.BuffFrame, "topleft", -2, 0)
    borderColorsButton:SetPoint("bottomleft", unitFrame.BuffFrame, "bottomleft", -2, 0)
    borderColorsButton:SetPoint("topright", unitFrame.BuffFrame, "topright", 85, 0)
    borderColorsButton:SetPoint("bottomright", unitFrame.BuffFrame, "bottomright", 85, 0)
    borderColorsButton:SetBackdrop({bgFile = [[Interface\ChatFrame\ChatFrameBackground]], edgeFile = [[Interface\Buttons\WHITE8X8]], tile = true, tileSize = 16, edgeSize = 1, insets = {left = 1, right = 1, top = 1, bottom = 1}})
    borderColorsButton:SetBackdropColor(0, 0, 0, 0.1)
    borderColorsButton:SetBackdropBorderColor(.2, .2, .2, 0.5)
    borderColorsButton.text = borderColorsButton:CreateFontString(nil, "overlay", "GameFontNormal")
    borderColorsButton.text:SetPoint("right", borderColorsButton, "right", -2, 0)
    borderColorsButton.text:SetText("aura borders")
    detailsFramework:SetFontSize(borderColorsButton.text, 9)
    detailsFramework:SetFontColor(borderColorsButton.text, "silver")

    --visible "stacks" button, sits directly above the buff icons. click selects the Stack
    --Counter widget. matches the styling of aura tracking / aura borders so the row of
    --preview-pickers reads as one set.
    local stacksButton = CreateFrame("frame", nil, healthBar, "BackdropTemplate")
    healthBar.dummyStackCounter = stacksButton
    stacksButton:SetHeight(18)
    stacksButton:SetPoint("bottomleft", unitFrame.BuffFrame, "topleft", -2, -2)
    stacksButton:SetPoint("bottomright", unitFrame.BuffFrame, "topright", 2, -2)
    stacksButton:SetBackdrop({bgFile = [[Interface\ChatFrame\ChatFrameBackground]], edgeFile = [[Interface\Buttons\WHITE8X8]], tile = true, tileSize = 16, edgeSize = 1, insets = {left = 1, right = 1, top = 1, bottom = 1}})
    stacksButton:SetBackdropColor(0, 0, 0, 0.1)
    stacksButton:SetBackdropBorderColor(.2, .2, .2, 0.5)
    stacksButton.text = stacksButton:CreateFontString(nil, "overlay", "GameFontNormal")
    stacksButton.text:SetPoint("center", stacksButton, "center", 0, 0)
    stacksButton.text:SetText("stacks")
    detailsFramework:SetFontSize(stacksButton.text, 9)
    detailsFramework:SetFontColor(stacksButton.text, "silver")

    --clickable Aura Timer selector. sits over the 3rd and 4th buff icons (the driver positions
    --it each tick). parented to the buff frame with a high frame level so its selectButton wins
    --clicks over the buff icons (which otherwise select Auras Layout). holds two mock cooldown
    --swipes with a big number so the user sees where a timer renders.
    local auraTimerPreview = CreateFrame("frame", nil, unitFrame.BuffFrame)
    auraTimerPreview:SetFrameLevel(unitFrame.BuffFrame:GetFrameLevel() + 30)
    auraTimerPreview:SetPoint("topleft", unitFrame.BuffFrame, "topleft", 0, 0)
    auraTimerPreview:SetSize(40, 20)
    healthBar.dummyAuraTimer = auraTimerPreview
    unitFrame.BuffFrame.auraTimerPreview = auraTimerPreview

    --two cooldown frames, one per icon. big number fontstring mocks the timer text.
    auraTimerPreview.cooldowns = {}
    for cooldownIndex = 1, 2 do
        local cooldown = CreateFrame("Cooldown", nil, auraTimerPreview, "CooldownFrameTemplate")
        cooldown:SetFrameLevel(auraTimerPreview:GetFrameLevel() + 1)
        cooldown:SetHideCountdownNumbers(true)
        --darker swipe so the shaded area below the number reads clearly.
        cooldown:SetSwipeColor(0, 0, 0, 0.9)
        cooldown.bigNumber = cooldown:CreateFontString(nil, "overlay", "GameFontNormal")
        cooldown.bigNumber:SetPoint("center", cooldown, "center", 0, 0)
        cooldown.bigNumber:SetTextColor(1, 1, 1, 1)
        detailsFramework:SetFontSize(cooldown.bigNumber, 12)
        auraTimerPreview.cooldowns[cooldownIndex] = cooldown
    end

    local dummyTargetBar = CreateFrame("frame", nil, healthBar, "BackdropTemplate")
    healthBar.dummyTargetBar = dummyTargetBar
    dummyTargetBar:SetFrameLevel(healthBar:GetFrameLevel() - 2)
    --shifted 24px further left (was -80) to make room for the indicator selector frame that
    --sits against the health bar's left edge.
    dummyTargetBar:SetPoint("topleft", healthBar, "topleft", -104, 0)
    dummyTargetBar:SetPoint("bottomright", healthBar, "bottomright", 3, 0)
    dummyTargetBar:SetBackdrop({bgFile = [[Interface\ChatFrame\ChatFrameBackground]], edgeFile = [[Interface\Buttons\WHITE8X8]], tile = true, tileSize = 16, edgeSize = 1, insets = {left = 1, right = 1, top = 1, bottom = 1}})
    dummyTargetBar:SetBackdropColor(0, 0, 0, 0.1)
    dummyTargetBar:SetBackdropBorderColor(.2, .2, .2, 0.5)
    healthBar.dummyTarget = dummyTargetBar
    dummyTargetBar.text = dummyTargetBar:CreateFontString(nil, "overlay", "GameFontNormal")
    dummyTargetBar.text:SetPoint("left", dummyTargetBar, "left", 2, 0)
    dummyTargetBar.text:SetText("target")

    --dummy focus bar (sits above the target bar, narrower so they do not overlap)
    local dummyFocusBar = CreateFrame("frame", nil, healthBar, "BackdropTemplate")
    healthBar.dummyFocusBar = dummyFocusBar
    dummyFocusBar:SetFrameLevel(healthBar:GetFrameLevel() - 1)
    --shifted 24px further left (was -40) to match the target bar and clear the indicator slot.
    dummyFocusBar:SetPoint("topleft", healthBar, "topleft", -64, 0)
    dummyFocusBar:SetPoint("bottomright", healthBar, "bottomright", 3, 0)
    dummyFocusBar:SetHeight(15)
    dummyFocusBar:SetBackdrop({bgFile = [[Interface\ChatFrame\ChatFrameBackground]], edgeFile = [[Interface\Buttons\WHITE8X8]], tile = true, tileSize = 16, edgeSize = 1, insets = {left = 1, right = 1, top = 1, bottom = 1}})
    dummyFocusBar:SetBackdropColor(0, 0, 0, 0.1)
    dummyFocusBar:SetBackdropBorderColor(.2, .2, .2, 0.5)
    healthBar.dummyFocus = dummyFocusBar
    dummyFocusBar.text = dummyFocusBar:CreateFontString(nil, "overlay", "GameFontNormal")
    dummyFocusBar.text:SetPoint("left", dummyFocusBar, "left", 2, 0)
    dummyFocusBar.text:SetText("focus")
    detailsFramework:SetFontSize(dummyFocusBar.text, 9)
    detailsFramework:SetFontColor(dummyFocusBar.text, "silver")
    detailsFramework:SetFontSize(dummyTargetBar.text, 9)
    detailsFramework:SetFontColor(dummyTargetBar.text, "silver")

    --neon highlight textures that mimic plateFrame.TargetNeonUp/TargetNeonDown so the editor
    --preview reflects target_highlight_* changes live. seeded from profile values on creation;
    --the Target widget's setters update these directly via target.NeonUp / target.NeonDown.
    local targetNeonUp = healthBar:CreateTexture(nil, "overlay")
    targetNeonUp:SetPoint("bottomleft", healthBar, "topleft", 0, 0)
    targetNeonUp:SetPoint("bottomright", healthBar, "topright", 0, 0)
    targetNeonUp:SetHeight(Plater.db.profile.target_highlight_height)
    targetNeonUp:SetTexture(Plater.db.profile.target_highlight_texture)
    targetNeonUp:SetVertexColor(unpack(Plater.db.profile.target_highlight_color))
    targetNeonUp:SetAlpha(Plater.db.profile.target_highlight_alpha)
    targetNeonUp:SetBlendMode("ADD")
    dummyTargetBar.NeonUp = targetNeonUp

    local targetNeonDown = healthBar:CreateTexture(nil, "overlay")
    targetNeonDown:SetPoint("topleft", healthBar, "bottomleft", 0, 0)
    targetNeonDown:SetPoint("topright", healthBar, "bottomright", 0, 0)
    targetNeonDown:SetHeight(Plater.db.profile.target_highlight_height)
    targetNeonDown:SetTexture(Plater.db.profile.target_highlight_texture)
    targetNeonDown:SetVertexColor(unpack(Plater.db.profile.target_highlight_color))
    targetNeonDown:SetAlpha(Plater.db.profile.target_highlight_alpha)
    targetNeonDown:SetBlendMode("ADD")
    targetNeonDown:SetTexCoord(0, 1, 1, 0) --flip vertically to mirror NeonUp
    dummyTargetBar.NeonDown = targetNeonDown

    --hover-over highlight texture it mimics plateFrame.unitFrame.HighlightFrame.HighlightTexture
    local hoverHighlightTexture = healthBar:CreateTexture(nil, "overlay")
    hoverHighlightTexture:SetAllPoints(healthBar)
    hoverHighlightTexture:SetColorTexture(1, 1, 1, 1)
    hoverHighlightTexture:SetAlpha(Plater.db.profile.hover_highlight_alpha)
    hoverHighlightTexture:Hide()
    dummyTargetBar.HoverHighlight = hoverHighlightTexture

    local PLAYER_IN_COMBAT = false

    local actorType = ACTORTYPE_ENEMY_NPC

    Plater.UpdateSoftInteractTarget(plateFrame)

    plateFrame[MEMBER_GUID] = UnitGUID(unitID)
    plateFrame[MEMBER_NAME] = UnitName(unitID)

    unitFrame.IsNeutralOrHostile = actorType == ACTORTYPE_ENEMY_NPC

    unitFrame.nameplateScaleAdjust = 1

    unitFrame.targetUnitID = unitID .. "target"

	unitFrame.InCombat = UnitAffectingCombat(unitID) or (Plater.ForceInCombatUnits[unitFrame[MEMBER_NPCID]] and PLAYER_IN_COMBAT) or false
        plateFrame [MEMBER_REACTION] = reaction
        unitFrame [MEMBER_REACTION] = reaction
        unitFrame.BuffFrame [MEMBER_REACTION] = reaction
        unitFrame.BuffFrame2 [MEMBER_REACTION] = reaction

    --cache values into the unitFrame as well to reduce the overhead on scripts and hooks
    unitFrame [MEMBER_NAME] = plateFrame [MEMBER_NAME]
    unitFrame [MEMBER_NAMELOWER] = plateFrame [MEMBER_NAMELOWER]
    plateFrame ["namePlateClassification"] = "worldboss"
    unitFrame ["namePlateClassification"] = "worldboss"
    unitFrame.unitNameInternal = unitName
    unitFrame [MEMBER_UNITID] = unitID

    unitFrame.BuffFrame [MEMBER_REACTION] = reaction
    unitFrame.BuffFrame2 [MEMBER_REACTION] = reaction
    unitFrame.BuffFrame.unit = unitID
    unitFrame.BuffFrame2.unit = unitID
    unitFrame.ExtraIconFrame.unit = unitID

    plateFrame.playerGuildName = "Guild Name"

    local no = false
    local yes = true

    unitFrame.Settings.ShowCastBar = yes
    plateFrame.isPlayer = no
    unitFrame.isPlayer = no
    plateFrame.PlayerCannotAttack = no
    unitFrame.InExecuteRange = no
    plateFrame.actorType = actorType
    unitFrame.actorType = actorType

    unitFrame:SetUnit(unitID)

    Plater.OnRetailNamePlateShow(plateFrame.UnitFrame) --affecting blizz nameplate which the preview only a dummy
    unitFrame:Show()
    unitFrame.unitName:Show()
    Plater.AddToAuraUpdate(unitID, unitFrame)
    Plater.EnsureUpdateBossModAuras(plateFrame[MEMBER_GUID])

    plateFrame.NameAnchor = DB_NAME_NPCENEMY_ANCHOR
    plateFrame.PlateConfig = DB_PLATE_CONFIG.enemynpc
    Plater.UpdatePlateFrame (plateFrame, ACTORTYPE_ENEMY_NPC, nil, true)
    unitFrame.Settings.ShowCastBar = not DB_CASTBAR_HIDE_ENEMIES
    unitFrame.castBar:SetUnit (unitID, unitID)

    --get threat situation to expose it to scripts already in the nameplate added hook
    local isTanking, threatStatus, threatpct, threatrawpct, threatValue = UnitDetailedThreatSituation("player", unitID)
    unitFrame.namePlateThreatIsTanking = isTanking
    unitFrame.namePlateThreatStatus = threatStatus
    unitFrame.namePlateThreatPercent = threatpct or 0
    unitFrame.namePlateThreatRawPercent = threatrawpct or 0
    unitFrame.namePlateThreatValue = threatValue or 0

    --update the bars
    Plater.UpdatePlateText(plateFrame, plateConfigs, needReset)

    Plater.UpdateUnitName(plateFrame)

    Plater.UpdateUIParentLevels(unitFrame)

    Plater.UpdatePlateFrame(plateFrame, ACTORTYPE_ENEMY_NPC, nil, true)

    Plater.OnUpdateHealth(healthBar)
    Plater.QuickHealthUpdate(unitFrame)

    Plater.UpdateBorderColor(unitFrame)

    Plater.UpdateNameOnRenamedUnit(plateFrame)

    Plater.FindAndSetNameplateColor (unitFrame, true)

    Plater.UpdateCastbarIcon(castBar)

    plateFrame.unitFrame.WidgetContainer = plateFrame.UnitFrame.WidgetContainer
    if plateFrame.unitFrame.WidgetContainer then
        plateFrame.unitFrame.WidgetContainer:SetParent(plateFrame.unitFrame)
        plateFrame.unitFrame.WidgetContainer:ClearAllPoints()
        plateFrame.unitFrame.WidgetContainer:SetIgnoreParentScale(true)
        plateFrame.unitFrame.WidgetContainer:SetScale(Plater.db.profile.widget_bar_scale)
        Plater.SetAnchor (plateFrame.unitFrame.WidgetContainer, Plater.db.profile.widget_bar_anchor, plateFrame.unitFrame)
    end

    unitFrame.CanCheckAggro = yes

    Plater.Resources.UpdateResourceFramePosition()

    Plater.NameplateTick (plateFrame.OnTickFrame, 999)
    plateFrame.OnTickFrame.ThrottleUpdate = 10^7
    unitFrame.PlaterOnScreen = true

    --create new fontstring to life percent to avoid issues with UnitHealth() returning a secret
    ---@type fontstring
    local newLifePercent = healthBar:CreateFontString(nil, "overlay", "GameFontNormal")
    healthBar.lifePercent_Safe = newLifePercent
    healthBar.lifePercent_Safe:SetPoint("center", healthBar, "center", 0, 0)
    healthBar.lifePercent:Hide()

    ---quest options dummy
    ---@type fontstring
    local questOptionsFontString = castBar:CreateFontString(nil, "overlay", "GameFontNormal")
    unitFrame.QuestOptionsDummyFontString = questOptionsFontString

    --dv(healthBar)

    local focusIndicator = unitFrame.FocusIndicator

    local anchorFrame = plateFrame.PlaterAnchorFrame

    --local actorLevel = healthBar.actorLevel


    local obscuredTexture = plateFrame.Obscured

    local extraIconFrame = unitFrame.ExtraIconFrame

    local castBarIcon = castBar.Icon
    local castBarText = castBar.Text
    local castBarPercentText = castBar.percentText
    local castBarTargetName = castBar.TargetName

    --print(castBarTargetName:GetParent():GetName())

    local newBarTargetName = castBar.FrameOverlay:CreateFontString(nil, "overlay", "GameFontNormal")
    castBar.NewCastBarTargetName = newBarTargetName

    local buffFrame1 = unitFrame.BuffFrame
    local buffFrame2 = unitFrame.BuffFrame2

    local targetNeonUp = unitFrame.TargetNeonUp
    local targetNeonDown = unitFrame.TargetNeonDown

    local targetOverlayTexture = unitFrame.targetOverlayTexture

    local frameOverlay = healthBar.FrameOverlay
    local healthCutOff = healthBar.healthCutOff
    local shieldIndicator = healthBar.shieldIndicator
    local executeRange = healthBar.executeRange
    local executeGlowUp = healthBar.ExecuteGlowUp
    local executeGlowDown = healthBar.ExecuteGlowDown

    local raidTargetIcon = unitFrame.PlaterRaidTargetFrame.RaidTargetIcon
    local extraRaidMark = healthBar.ExtraRaidMark

    plateFrame:SetParent(UIParent)
    plateFrame:SetFrameStrata("FULLSCREEN")
    plateFrame.unitFrame:SetFrameStrata("FULLSCREEN")

    Plater.UpdatePlateSize(plateFrame)

    --draw the bracket indicator on the preview (the preview unit is not the player target
    --so Plater.UpdateTarget never runs the indicator code path for it)
    Plater.UpdateTargetIndicator(plateFrame)
end