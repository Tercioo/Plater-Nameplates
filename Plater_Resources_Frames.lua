

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
        local backgroundTexture = widgetFrame:CreateTexture("$parentbackgroundTexture", "OVERLAY")
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

        ----------------------------------------------

        --[=[
        local rotatingSpark  = widgetFrame:CreateTexture("$parentrotatingSparkTexture", "BACKGROUND")
        rotatingSpark:SetTexture([[Interface\PLAYERFRAME\MageArcaneCharges]])
        rotatingSpark:SetDrawLayer("BACKGROUND", 1)
        rotatingSpark:SetPoint("center", widgetFrame, "center", 0, -6)
        rotatingSpark:SetSize(20, 20)
        rotatingSpark:SetTexCoord(0.0010000000149012, 0.2252681350708, 0.047248387336731, 0.5467858505249)
        rotatingSpark:SetBlendMode("ADD")

        --> animations for rotatingSpark

        rotatingSpark.alpha = MainAnimationGroup:CreateAnimation("ALPHA")
        rotatingSpark.alpha:SetTarget(rotatingSpark)
        rotatingSpark.alpha:SetOrder(1)
        rotatingSpark.alpha:SetDuration(0.016000000759959)
        rotatingSpark.alpha:SetFromAlpha(0)
        rotatingSpark.alpha:SetToAlpha(0)
        rotatingSpark.rotation = MainAnimationGroup:CreateAnimation("ROTATION")
        rotatingSpark.rotation:SetTarget(rotatingSpark)
        rotatingSpark.rotation:SetOrder(3)
        rotatingSpark.rotation:SetDuration(10)
        rotatingSpark.rotation:SetDegrees(360)
        rotatingSpark.rotation:SetOrigin("center", 0, 0)
        rotatingSpark.alpha1 = MainAnimationGroup:CreateAnimation("ALPHA")
        rotatingSpark.alpha1:SetTarget(rotatingSpark)
        rotatingSpark.alpha1:SetOrder(3)
        rotatingSpark.alpha1:SetDuration(4.9959998130798)
        rotatingSpark.alpha1:SetFromAlpha(0.099999994039536)
        rotatingSpark.alpha1:SetToAlpha(0.19999998807907)
        rotatingSpark.alpha2 = MainAnimationGroup:CreateAnimation("ALPHA")
        rotatingSpark.alpha2:SetTarget(rotatingSpark)
        rotatingSpark.alpha2:SetOrder(3)
        rotatingSpark.alpha2:SetDuration(4.9959998130798)
        rotatingSpark.alpha2:SetStartDelay(5)
        rotatingSpark.alpha2:SetFromAlpha(0.19999998807907)
        rotatingSpark.alpha2:SetToAlpha(0.099999994039536)
        --]=]

        ----------------------------------------------
        --[=[
        local pinkRotatingSpark  = widgetFrame:CreateTexture("$parentpinkRotatingSparkTexture", "ARTWORK")
        pinkRotatingSpark:SetTexture([[Interface\PLAYERFRAME\MageArcaneCharges]])
        pinkRotatingSpark:SetDrawLayer("ARTWORK", -1)
        pinkRotatingSpark:SetPoint("center", widgetFrame, "center", 0, 0)
        pinkRotatingSpark:SetSize(20, 20)
        pinkRotatingSpark:SetVertexColor(0.99999779462814, 0.99999779462814, 0.99999779462814, 0.39999911189079)
        pinkRotatingSpark:SetTexCoord(0.39799999237061, 0.55700000762939, 0.17, 0.425)
        pinkRotatingSpark:SetBlendMode("ADD")
        pinkRotatingSpark:SetAlpha(0.40000003576279)

        --> animations for pinkRotatingSpark

        pinkRotatingSpark.alpha1 = MainAnimationGroup:CreateAnimation("ALPHA")
        pinkRotatingSpark.alpha1:SetTarget(pinkRotatingSpark)
        pinkRotatingSpark.alpha1:SetOrder(1)
        pinkRotatingSpark.alpha1:SetDuration(0.016000000759959)
        pinkRotatingSpark.alpha1:SetFromAlpha(0)
        pinkRotatingSpark.alpha1:SetToAlpha(0)
        pinkRotatingSpark.alpha2 = MainAnimationGroup:CreateAnimation("ALPHA")
        pinkRotatingSpark.alpha2:SetTarget(pinkRotatingSpark)
        pinkRotatingSpark.alpha2:SetOrder(3)
        pinkRotatingSpark.alpha2:SetDuration(0.99599993228912)
        pinkRotatingSpark.alpha2:SetFromAlpha(0)
        pinkRotatingSpark.alpha2:SetToAlpha(0.23999999463558)
        pinkRotatingSpark.scale1 = MainAnimationGroup:CreateAnimation("SCALE")
        pinkRotatingSpark.scale1:SetTarget(pinkRotatingSpark)
        pinkRotatingSpark.scale1:SetOrder(3)
        pinkRotatingSpark.scale1:SetDuration(2.9960000514984)
        pinkRotatingSpark.scale1:SetFromScale(0.5, 0.5)
        pinkRotatingSpark.scale1:SetToScale(1.1999999284744, 1.1999999284744)
        pinkRotatingSpark.scale1:SetOrigin("center", 0, 0)
        pinkRotatingSpark.scale2 = MainAnimationGroup:CreateAnimation("SCALE")
        pinkRotatingSpark.scale2:SetTarget(pinkRotatingSpark)
        pinkRotatingSpark.scale2:SetOrder(3)
        pinkRotatingSpark.scale2:SetDuration(1.9959999322891)
        pinkRotatingSpark.scale2:SetStartDelay(3)
        pinkRotatingSpark.scale2:SetFromScale(1.1999999284744, 1.1999999284744)
        pinkRotatingSpark.scale2:SetToScale(0.69999998807907, 0.69999998807907)
        pinkRotatingSpark.scale2:SetOrigin("center", 0, 0)
        pinkRotatingSpark.scale3 = MainAnimationGroup:CreateAnimation("SCALE")
        pinkRotatingSpark.scale3:SetTarget(pinkRotatingSpark)
        pinkRotatingSpark.scale3:SetOrder(3)
        pinkRotatingSpark.scale3:SetDuration(2.9960000514984)
        pinkRotatingSpark.scale3:SetStartDelay(5)
        pinkRotatingSpark.scale3:SetFromScale(0.79999995231628, 0.79999995231628)
        pinkRotatingSpark.scale3:SetToScale(1.1000000238419, 1.1000000238419)
        pinkRotatingSpark.scale3:SetOrigin("center", 0, 0)
        pinkRotatingSpark.scale4 = MainAnimationGroup:CreateAnimation("SCALE")
        pinkRotatingSpark.scale4:SetTarget(pinkRotatingSpark)
        pinkRotatingSpark.scale4:SetOrder(3)
        pinkRotatingSpark.scale4:SetDuration(1.9959999322891)
        pinkRotatingSpark.scale4:SetStartDelay(8)
        pinkRotatingSpark.scale4:SetFromScale(1.1000000238419, 1.1000000238419)
        pinkRotatingSpark.scale4:SetToScale(0.5, 0.5)
        pinkRotatingSpark.scale4:SetOrigin("center", 0, 0)
        pinkRotatingSpark.rotation1 = MainAnimationGroup:CreateAnimation("ROTATION")
        pinkRotatingSpark.rotation1:SetTarget(pinkRotatingSpark)
        pinkRotatingSpark.rotation1:SetOrder(3)
        pinkRotatingSpark.rotation1:SetDuration(10)
        pinkRotatingSpark.rotation1:SetDegrees(248)
        pinkRotatingSpark.rotation1:SetOrigin("center", 0, 0)
        --]=]

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
