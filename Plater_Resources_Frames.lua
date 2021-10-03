

local Plater = _G.Plater
local DF = DetailsFramework
local _

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