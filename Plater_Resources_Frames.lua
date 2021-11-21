

local Plater = _G.Plater
local DF = DetailsFramework
local _

local IS_WOW_PROJECT_MAINLINE = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
local IS_WOW_PROJECT_NOT_MAINLINE = WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE
local IS_WOW_PROJECT_CLASSIC_ERA = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
local IS_WOW_PROJECT_CLASSIC_TBC = WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC

--[=[
    search keys:
    ~monk
--]=]

local CONST_SPECID_MONK_WINDWALKER = 269
local CONST_SPECID_MAGE_ARCANE = 62
local CONST_SPECID_ROGUE_ASSASSINATION = 259
local CONST_SPECID_ROGUE_OUTLAW = 260
local CONST_SPECID_ROGUE_SUBTLETY = 261
local CONST_SPECID_DRUID_FERAL = 103
local CONST_SPECID_PALADIN_HOLY = 65
local CONST_SPECID_PALADIN_PROTECTION = 66
local CONST_SPECID_PALADIN_RETRIBUTION = 70
local CONST_SPECID_WARLOCK_AFFLICTION = 265
local CONST_SPECID_WARLOCK_DEMONOLOGY = 266
local CONST_SPECID_WARLOCK_DESTRUCTION = 267
local CONST_SPECID_DK_UNHOLY = 252
local CONST_SPECID_DK_FROST = 251
local CONST_SPECID_DK_BLOOD = 250

local resourceCreationFunctions = Plater.Resources.GetResourceWidgetCreationTable()


--> ~monk
    resourceCreationFunctions[CONST_SPECID_MONK_WINDWALKER] = function(parent, frameName)
        --create the frame for support
        local widgetFrame = CreateFrame("frame", frameName, parent)

        --> create background
            local backgroundTexture = parent:CreateTexture (nil, "BORDER")
            backgroundTexture:SetTexture([[Interface\PLAYERFRAME\MonkUIAtlas]])
            backgroundTexture:SetDrawLayer("BORDER", 1)
            backgroundTexture:SetPoint("center", widgetFrame, "center", 0, 0)
            backgroundTexture:SetSize(20, 20)
            backgroundTexture:SetVertexColor(0.98431158065796, 0.99215465784073, 0.99999779462814, 0.99999779462814)
            backgroundTexture:SetTexCoord(0.5513224029541, 0.61600479125977, 0.025, 0.1610000038147)
            parent.widgetsBackground[#parent.widgetsBackground + 1] = backgroundTexture

        --> single animation group
            local MainAnimationGroup = widgetFrame:CreateAnimationGroup()
            MainAnimationGroup:SetLooping("NONE")
            MainAnimationGroup:SetToFinalAlpha(true)

        --> widgets:

        ----------------------------------------------

        local BallTexture  = widgetFrame:CreateTexture (nil, "ARTWORK")
        BallTexture:SetTexture ([[Interface\PLAYERFRAME\MonkUIAtlas]])
        BallTexture:SetDrawLayer ("ARTWORK", 0)
        BallTexture:SetPoint ("center", widgetFrame, "center", 0, 0)
        BallTexture:SetSize (20 * 0.90, 20 * 0.90)
        BallTexture:SetTexCoord (0.6427360534668, 0.70684181213379, 0.02872227191925, 0.15893713951111)

        --> animations for BallTexture

        BallTexture.scale = MainAnimationGroup:CreateAnimation ("SCALE")
        BallTexture.scale:SetTarget (BallTexture)
        BallTexture.scale:SetOrder (1)
        BallTexture.scale:SetDuration (0.195999994874)
        BallTexture.scale:SetFromScale (0, 0)
        BallTexture.scale:SetToScale (1, 1)
        BallTexture.scale:SetOrigin ("center", 0, 0)
        BallTexture.scale = MainAnimationGroup:CreateAnimation ("SCALE")
        BallTexture.scale:SetTarget (BallTexture)
        BallTexture.scale:SetOrder (2)
        BallTexture.scale:SetDuration (0.046000000089407)
        BallTexture.scale:SetFromScale (1, 1)
        BallTexture.scale:SetToScale (1.1999999284744, 1.1999999284744)
        BallTexture.scale:SetOrigin ("center", 0, 0)
        BallTexture.scale = MainAnimationGroup:CreateAnimation ("SCALE")
        BallTexture.scale:SetTarget (BallTexture)
        BallTexture.scale:SetOrder (3)
        BallTexture.scale:SetDuration (0.016000000759959)
        BallTexture.scale:SetFromScale (1.1999999284744, 1.1999999284744)
        BallTexture.scale:SetToScale (1, 1)
        BallTexture.scale:SetOrigin ("center", 0, 0)

        ----------------------------------------------

        local UpSpark  = widgetFrame:CreateTexture (nil, "OVERLAY")
        UpSpark:SetTexture ([[Interface\QUESTFRAME\ObjectiveTracker]])
        UpSpark:SetDrawLayer ("OVERLAY", 0)
        UpSpark:SetPoint ("center", widgetFrame, "center", 0, 0)
        UpSpark:SetSize (20 * 0.89, 20 * 0.89)
        UpSpark:SetTexCoord (0.7108479309082, 0.83905952453613, 0.0010000000149012, 0.12888721466064)

        --> animations for UpSpark

        UpSpark.scale = MainAnimationGroup:CreateAnimation ("SCALE")
        UpSpark.scale:SetTarget (UpSpark)
        UpSpark.scale:SetOrder (1)
        UpSpark.scale:SetDuration (0.195999994874)
        UpSpark.scale:SetFromScale (0, 0)
        UpSpark.scale:SetToScale (1, 1)
        UpSpark.scale:SetOrigin ("center", 0, 0)
        UpSpark.alpha = MainAnimationGroup:CreateAnimation ("ALPHA")
        UpSpark.alpha:SetTarget (UpSpark)
        UpSpark.alpha:SetOrder (1)
        UpSpark.alpha:SetDuration (0.195999994874)
        UpSpark.alpha:SetFromAlpha (0)
        UpSpark.alpha:SetToAlpha (0.40382900834084)
        UpSpark.rotation = MainAnimationGroup:CreateAnimation ("ROTATION")
        UpSpark.rotation:SetTarget (UpSpark)
        UpSpark.rotation:SetOrder (1)
        UpSpark.rotation:SetDuration (0.195999994874)
        UpSpark.rotation:SetDegrees (60)
        UpSpark.rotation:SetOrigin ("center", 0, 0)
        UpSpark.rotation = MainAnimationGroup:CreateAnimation ("ROTATION")
        UpSpark.rotation:SetTarget (UpSpark)
        UpSpark.rotation:SetOrder (2)
        UpSpark.rotation:SetDuration (0.195999994874)
        UpSpark.rotation:SetDegrees (15)
        UpSpark.rotation:SetOrigin ("center", 0, 0)
        UpSpark.alpha = MainAnimationGroup:CreateAnimation ("ALPHA")
        UpSpark.alpha:SetTarget (UpSpark)
        UpSpark.alpha:SetOrder (2)
        UpSpark.alpha:SetDuration (0.096000000834465)
        UpSpark.alpha:SetFromAlpha (0.4038280248642)
        UpSpark.alpha:SetToAlpha (0.25)
        UpSpark.rotation = MainAnimationGroup:CreateAnimation ("ROTATION")
        UpSpark.rotation:SetTarget (UpSpark)
        UpSpark.rotation:SetOrder (3)
        UpSpark.rotation:SetDuration (0.195999994874)
        UpSpark.rotation:SetDegrees (60)
        UpSpark.rotation:SetOrigin ("center", 0, 0)
        UpSpark.alpha = MainAnimationGroup:CreateAnimation ("ALPHA")
        UpSpark.alpha:SetTarget (UpSpark)
        UpSpark.alpha:SetOrder (3)
        UpSpark.alpha:SetDuration (0.195999994874)
        UpSpark.alpha:SetFromAlpha (0.25)
        UpSpark.alpha:SetToAlpha (0)

        ----------------------------------------------

        local BackgroundSpark  = widgetFrame:CreateTexture (nil, "BACKGROUND")
        BackgroundSpark:SetTexture ([[Interface\PVPFrame\PvPHonorSystem]])
        BackgroundSpark:SetDrawLayer ("BACKGROUND", 0)
        BackgroundSpark:SetPoint ("center", widgetFrame, "center", 0, 0)
        BackgroundSpark:SetSize (20 * 1.39, 20 * 1.39)
        BackgroundSpark:SetTexCoord (0.0096916198730469, 0.1160000038147, 0.43700000762939, 0.54200000762939)

        --> animations for BackgroundSpark

        BackgroundSpark.alpha = MainAnimationGroup:CreateAnimation ("ALPHA")
        BackgroundSpark.alpha:SetTarget (BackgroundSpark)
        BackgroundSpark.alpha:SetOrder (1)
        BackgroundSpark.alpha:SetDuration (0.195999994874)
        BackgroundSpark.alpha:SetFromAlpha (0)
        BackgroundSpark.alpha:SetToAlpha (1)
        BackgroundSpark.rotation = MainAnimationGroup:CreateAnimation ("ROTATION")
        BackgroundSpark.rotation:SetTarget (BackgroundSpark)
        BackgroundSpark.rotation:SetOrder (1)
        BackgroundSpark.rotation:SetDuration (0.195999994874)
        BackgroundSpark.rotation:SetDegrees (2)
        BackgroundSpark.rotation:SetOrigin ("center", 0, 0)
        BackgroundSpark.alpha = MainAnimationGroup:CreateAnimation ("ALPHA")
        BackgroundSpark.alpha:SetTarget (BackgroundSpark)
        BackgroundSpark.alpha:SetOrder (2)
        BackgroundSpark.alpha:SetDuration (0.195999994874)
        BackgroundSpark.alpha:SetFromAlpha (0.34612736105919)
        BackgroundSpark.alpha:SetToAlpha (0.24995632469654)
        BackgroundSpark.alpha = MainAnimationGroup:CreateAnimation ("ALPHA")
        BackgroundSpark.alpha:SetTarget (BackgroundSpark)
        BackgroundSpark.alpha:SetOrder (3)
        BackgroundSpark.alpha:SetDuration (0.195999994874)
        BackgroundSpark.alpha:SetFromAlpha (0.25)
        BackgroundSpark.alpha:SetToAlpha (0)

        --> test the animation
        --MainAnimationGroup:Play()

        widgetFrame.ShowAnimation = MainAnimationGroup
        return widgetFrame
    end


    local comboPointFunc = function(parent, frameName)
        --> create the main frame
        local widgetFrame = CreateFrame("frame", frameName, parent)

        --> create background
        local backgroundTexture = parent:CreateTexture("$parenttopCircleTexture", "BACKGROUND")
        backgroundTexture:SetAtlas("ClassOverlay-ComboPoint-Off")
        backgroundTexture:SetDrawLayer("OVERLAY", 1)
        backgroundTexture:SetPoint("center", widgetFrame, "center", 0, 0)
        backgroundTexture:SetSize(20, 20)
        backgroundTexture:SetVertexColor(0.96470373868942, 0.99999779462814, 0.98823314905167, 0.99999779462814)
        widgetFrame.background = backgroundTexture
        parent.widgetsBackground[#parent.widgetsBackground + 1] = backgroundTexture

        --> single animation group
        local MainAnimationGroup = widgetFrame:CreateAnimationGroup()
        MainAnimationGroup:SetLooping("NONE")
        MainAnimationGroup:SetToFinalAlpha(true)

        ----------------------------------------------

        local comboPointTexture  = widgetFrame:CreateTexture("$parentcomboPointTextureTexture", "ARTWORK")
        comboPointTexture:SetAtlas("ClassOverlay-ComboPoint")
        comboPointTexture:SetDrawLayer("BORDER", 0)
        comboPointTexture:SetPoint("center", widgetFrame, "center", 0, 0)
        comboPointTexture:SetSize(20, 20)
        
        widgetFrame.texture = comboPointTexture

        --> animations for comboPointTexture

        comboPointTexture.alpha1 = MainAnimationGroup:CreateAnimation("ALPHA")
        comboPointTexture.alpha1:SetTarget(comboPointTexture)
        comboPointTexture.alpha1:SetOrder(1)
        comboPointTexture.alpha1:SetDuration(0.195999994874)
        comboPointTexture.alpha1:SetFromAlpha(0)
        comboPointTexture.alpha1:SetToAlpha(0.49912714958191)
        comboPointTexture.scale1 = MainAnimationGroup:CreateAnimation("SCALE")
        comboPointTexture.scale1:SetTarget(comboPointTexture)
        comboPointTexture.scale1:SetOrder(1)
        comboPointTexture.scale1:SetDuration(0.195999994874)
        comboPointTexture.scale1:SetFromScale(0.29999998211861, 0.29999998211861)
        comboPointTexture.scale1:SetToScale(1.3999999761581, 1.3999999761581)
        comboPointTexture.scale1:SetOrigin("center", 0, 0)
        comboPointTexture.scale2 = MainAnimationGroup:CreateAnimation("SCALE")
        comboPointTexture.scale2:SetTarget(comboPointTexture)
        comboPointTexture.scale2:SetOrder(2)
        comboPointTexture.scale2:SetDuration(0.096000000834465)
        comboPointTexture.scale2:SetFromScale(0.9899999499321, 0.9899999499321)
        comboPointTexture.scale2:SetToScale(0.79999995231628, 0.78999996185303)
        comboPointTexture.scale2:SetOrigin("center", 0, 0)
        comboPointTexture.alpha1 = MainAnimationGroup:CreateAnimation("ALPHA")
        comboPointTexture.alpha1:SetTarget(comboPointTexture)
        comboPointTexture.alpha1:SetOrder(2)
        comboPointTexture.alpha1:SetDuration(0.096000000834465)
        comboPointTexture.alpha1:SetFromAlpha(0.69999998807907)
        comboPointTexture.alpha1:SetToAlpha(1)

        --> test the animation
        --MainAnimationGroup:Play()

        widgetFrame.ShowAnimation = MainAnimationGroup
        return widgetFrame
    end


    local arcaneChargesFunc = function(parent, frameName)
        --> create the main frame
        local widgetFrame = CreateFrame("frame", frameName, parent)

        --> create background
        local backgroundTexture = parent:CreateTexture("$parentbackgroundTexture", "OVERLAY")
        backgroundTexture:SetTexture([[Interface\PLAYERFRAME\MageArcaneCharges]])
        backgroundTexture:SetDrawLayer("OVERLAY", 0)
        backgroundTexture:SetPoint("center", widgetFrame, "center", 0, 0)
        backgroundTexture:SetSize(20, 20)
        backgroundTexture:SetDesaturated(true)
        backgroundTexture:SetTexCoord(0.23063896179199, 0.39712070465088, 0.15204653739929, 0.45421440124512)
        backgroundTexture:SetBlendMode("ADD")
        widgetFrame.background = backgroundTexture
        parent.widgetsBackground[#parent.widgetsBackground + 1] = backgroundTexture

        --> single animation group
        local MainAnimationGroup = widgetFrame:CreateAnimationGroup("widgetFrameAnimationGroup")
        MainAnimationGroup:SetLooping("NONE")
        MainAnimationGroup:SetToFinalAlpha(true)

        widgetFrame:SetScript("OnHide", function()
            MainAnimationGroup:Stop()
        end)

        ----------------------------------------------

        local comboPointTexture  = widgetFrame:CreateTexture("$parentcomboPointTextureTexture", "ARTWORK")
        comboPointTexture:SetTexture([[Interface\PLAYERFRAME\MageArcaneCharges]])
        comboPointTexture:SetDrawLayer("ARTWORK", 0)
        comboPointTexture:SetPoint("center", widgetFrame, "center", 0, 0)
        comboPointTexture:SetSize(20, 20)
        comboPointTexture:SetTexCoord(0.25749048233032, 0.36221286773682, 0.51534648895264, 0.73018249511719)

        --> animations for comboPointTexture

        comboPointTexture.scale = MainAnimationGroup:CreateAnimation("SCALE")
        comboPointTexture.scale:SetTarget(comboPointTexture)
        comboPointTexture.scale:SetOrder(1)
        comboPointTexture.scale:SetDuration(0.096000000834465)
        comboPointTexture.scale:SetFromScale(0, 0)
        comboPointTexture.scale:SetToScale(1, 1)
        comboPointTexture.scale:SetOrigin("center", 0, 0)
        comboPointTexture.alpha = MainAnimationGroup:CreateAnimation("ALPHA")
        comboPointTexture.alpha:SetTarget(comboPointTexture)
        comboPointTexture.alpha:SetOrder(1)
        comboPointTexture.alpha:SetDuration(0.096000000834465)
        comboPointTexture.alpha:SetFromAlpha(0)
        comboPointTexture.alpha:SetToAlpha(1)
        comboPointTexture.scale = MainAnimationGroup:CreateAnimation("SCALE")
        comboPointTexture.scale:SetTarget(comboPointTexture)
        comboPointTexture.scale:SetOrder(2)
        comboPointTexture.scale:SetDuration(0.096000000834465)
        comboPointTexture.scale:SetFromScale(1.3097063302994, 1.3097063302994)
        comboPointTexture.scale:SetToScale(1, 1)
        comboPointTexture.scale:SetOrigin("center", 0, 0)

        --> test the animation
        --MainAnimationGroup:Play()

        widgetFrame.ShowAnimation = MainAnimationGroup
        return widgetFrame
    end

    local paladinChargesFunc = function(parent, frameName)
        --> create the main frame
        local widgetFrame = CreateFrame("frame", frameName, parent)

        --> create background
        local backgroundTexture = parent:CreateTexture("$parentBackgroundTexture", "BACKGROUND")
        backgroundTexture:SetTexture([[Interface\AddOns\Plater\images\paladin_combo_point_deactive]])
        backgroundTexture:SetDrawLayer("BACKGROUND", 0)
        backgroundTexture:SetPoint("center", widgetFrame, "center", 0, 0)
        backgroundTexture:SetSize(20, 20)
        backgroundTexture:SetDesaturated(true)
        backgroundTexture:SetTexCoord(0, 1, 0, 1)
        widgetFrame.background = backgroundTexture
        parent.widgetsBackground[#parent.widgetsBackground + 1] = backgroundTexture

        --> single animation group
        local MainAnimationGroup = widgetFrame:CreateAnimationGroup("widgetFrameAnimationGroup")
        MainAnimationGroup:SetLooping("NONE")
        MainAnimationGroup:SetToFinalAlpha(true)

        widgetFrame:SetScript("OnHide", function()
            MainAnimationGroup:Stop()
        end)

        local comboPointOn  = widgetFrame:CreateTexture("$parentcomboPointOnTexture", "ARTWORK")
        comboPointOn:SetTexture([[Interface\AddOns\Plater\images\paladin_combo_point_active]])
        comboPointOn:SetDrawLayer("ARTWORK", 0)
        comboPointOn:SetPoint("center", widgetFrame, "center", 0, 0)
        comboPointOn:SetSize(20, 20)
        comboPointOn:SetTexCoord(0, 1, 0, 1)

        --> animations for comboPointOn

        comboPointOn.scale = MainAnimationGroup:CreateAnimation("SCALE")
        comboPointOn.scale:SetTarget(comboPointOn)
        comboPointOn.scale:SetOrder(1)
        comboPointOn.scale:SetDuration(0.096000000834465)
        comboPointOn.scale:SetFromScale(0.44999998807907, 0.59999996423721)
        comboPointOn.scale:SetToScale(1, 1)
        comboPointOn.scale:SetOrigin("center", 0, 0)
        comboPointOn.scale2 = MainAnimationGroup:CreateAnimation("SCALE")
        comboPointOn.scale2:SetTarget(comboPointOn)
        comboPointOn.scale2:SetOrder(2)
        comboPointOn.scale2:SetDuration(0.056000001728535)
        comboPointOn.scale2:SetFromScale(1.0951955318451, 1.0951955318451)
        comboPointOn.scale2:SetToScale(1, 1)
        comboPointOn.scale2:SetOrigin("center", 0, 0)

        --> test the animation
        --MainAnimationGroup:Play()

        widgetFrame.ShowAnimation = MainAnimationGroup
        return widgetFrame
    end

    resourceCreationFunctions[CONST_SPECID_DRUID_FERAL] = comboPointFunc
    resourceCreationFunctions[CONST_SPECID_ROGUE_ASSASSINATION] = comboPointFunc
    resourceCreationFunctions[CONST_SPECID_ROGUE_OUTLAW] = comboPointFunc
    resourceCreationFunctions[CONST_SPECID_ROGUE_SUBTLETY] = comboPointFunc
    resourceCreationFunctions[CONST_SPECID_MAGE_ARCANE] = arcaneChargesFunc
    resourceCreationFunctions[CONST_SPECID_PALADIN_HOLY] = paladinChargesFunc
    resourceCreationFunctions[CONST_SPECID_PALADIN_PROTECTION] = paladinChargesFunc
    resourceCreationFunctions[CONST_SPECID_PALADIN_RETRIBUTION] = paladinChargesFunc
