

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
local CONST_SPECID_DRUID_BALANCE = 102
local CONST_SPECID_DRUID_FERAL = 103
local CONST_SPECID_DRUID_GUARDIAN = 104
local CONST_SPECID_DRUID_RESTORATION = 105
local CONST_SPECID_PALADIN_HOLY = 65
local CONST_SPECID_PALADIN_PROTECTION = 66
local CONST_SPECID_PALADIN_RETRIBUTION = 70
local CONST_SPECID_WARLOCK_AFFLICTION = 265
local CONST_SPECID_WARLOCK_DEMONOLOGY = 266
local CONST_SPECID_WARLOCK_DESTRUCTION = 267
local CONST_SPECID_DK_UNHOLY = 252
local CONST_SPECID_DK_FROST = 251
local CONST_SPECID_DK_BLOOD = 250
local CONST_SPECID_EVOKER_DEVASTATION = 1467
local CONST_SPECID_EVOKER_PRESERVATION = 1468
local CONST_SPECID_EVOKER_AUGMENTATION = 1473

local resourceCreationFunctions = Plater.Resources.GetResourceWidgetCreationTable()


--> ~monk
    resourceCreationFunctions[CONST_SPECID_MONK_WINDWALKER] = function(parent, frameName)
        --create the frame for support
        local widgetFrame = CreateFrame("frame", frameName, parent)

        --> create background
            local backgroundTexture = parent:CreateTexture (nil, "BORDER")
            backgroundTexture:SetAtlas("MonkUI-OrbOff")
            backgroundTexture:SetDrawLayer("BORDER", 1)
            backgroundTexture:SetPoint("center", widgetFrame, "center", 0, 0)
            backgroundTexture:SetSize(20, 20)
            backgroundTexture:SetVertexColor(0.98431158065796, 0.99215465784073, 0.99999779462814, 0.99999779462814)
            parent.widgetsBackground[#parent.widgetsBackground + 1] = backgroundTexture

        --> single animation group
            local MainAnimationGroup = DF:CreateAnimationHub (widgetFrame)
            MainAnimationGroup:SetLooping("NONE")
            MainAnimationGroup:SetToFinalAlpha(true)

        --> widgets:

        ----------------------------------------------

        local BallTexture  = widgetFrame:CreateTexture (nil, "ARTWORK")
        BallTexture:SetAtlas ("MonkUI-LightOrb")
        BallTexture:SetDrawLayer ("ARTWORK", 0)
        BallTexture:SetPoint ("center", widgetFrame, "center", 0, 0)
        --BallTexture:SetSize (20 * 0.90, 20 * 0.90)
		BallTexture:SetSize (20, 20)

        --> animations for BallTexture

        BallTexture.scale = DF:CreateAnimation (MainAnimationGroup, "SCALE", 1, 0.195999994874, 0, 0, 1, 1)
        BallTexture.scale:SetTarget (BallTexture)
        BallTexture.scale2 = DF:CreateAnimation (MainAnimationGroup, "SCALE", 2, 0.046000000089407, 1, 1, 1.1999999284744, 1.1999999284744)
        BallTexture.scale2:SetTarget (BallTexture)
        BallTexture.scale3 = DF:CreateAnimation (MainAnimationGroup, "SCALE", 3, 0.016000000759959, 1.1999999284744, 1.1999999284744, 1, 1)
        BallTexture.scale3:SetTarget (BallTexture)

        ----------------------------------------------

        local UpSpark  = widgetFrame:CreateTexture (nil, "OVERLAY")
        UpSpark:SetTexture ([[Interface\QUESTFRAME\ObjectiveTracker]])
        UpSpark:SetDrawLayer ("OVERLAY", 0)
        UpSpark:SetPoint ("center", widgetFrame, "center", 0, 0)
        UpSpark:SetSize (20 * 0.89, 20 * 0.89)
        UpSpark:SetTexCoord (0.7108479309082, 0.83905952453613, 0.0010000000149012, 0.12888721466064)

        --> animations for UpSpark

        UpSpark.scale = DF:CreateAnimation (MainAnimationGroup, "SCALE", 1, 0.195999994874, 0, 0, 1, 1)
        UpSpark.scale:SetTarget (UpSpark)
        UpSpark.alpha = DF:CreateAnimation (MainAnimationGroup, "ALPHA", 1, 0.195999994874, 0, 1)
        UpSpark.alpha:SetTarget (UpSpark)
        UpSpark.rotation = DF:CreateAnimation (MainAnimationGroup, "ROTATION", 1, 0.195999994874, 60)
        UpSpark.rotation:SetTarget (UpSpark)
        UpSpark.rotation2 = DF:CreateAnimation (MainAnimationGroup, "ROTATION", 2, 0.195999994874, 15)
        UpSpark.rotation2:SetTarget (UpSpark)
        UpSpark.alpha2 =  DF:CreateAnimation (MainAnimationGroup, "ALPHA", 2, 0.096000000834465, 0.4038280248642, 0.25)
        UpSpark.alpha2:SetTarget (UpSpark)
        UpSpark.rotation3 = DF:CreateAnimation (MainAnimationGroup, "ROTATION", 3, 0.195999994874, 60)
        UpSpark.rotation3:SetTarget (UpSpark)
        UpSpark.alpha3 = DF:CreateAnimation (MainAnimationGroup, "ALPHA", 3, 0.195999994874, 0.25, 0)
        UpSpark.alpha3:SetTarget (UpSpark)

        ----------------------------------------------

        local BackgroundSpark  = widgetFrame:CreateTexture (nil, "BACKGROUND")
        BackgroundSpark:SetTexture ([[Interface\PVPFrame\PvPHonorSystem]])
        BackgroundSpark:SetDrawLayer ("BACKGROUND", 0)
        BackgroundSpark:SetPoint ("center", widgetFrame, "center", 0, 0)
        BackgroundSpark:SetSize (20 * 1.39, 20 * 1.39)
        BackgroundSpark:SetTexCoord (0.0096916198730469, 0.1160000038147, 0.43700000762939, 0.54200000762939)

        --> animations for BackgroundSpark

        BackgroundSpark.alpha = DF:CreateAnimation (MainAnimationGroup, "ALPHA", 1, 0.195999994874, 0, 1)
        BackgroundSpark.alpha:SetTarget (BackgroundSpark)
        BackgroundSpark.rotation = DF:CreateAnimation (MainAnimationGroup, "ROTATION", 1, 0.195999994874, 2)
        BackgroundSpark.rotation:SetTarget (BackgroundSpark)
        BackgroundSpark.alpha2 = DF:CreateAnimation (MainAnimationGroup, "ALPHA", 2, 0.195999994874, 0.34612736105919, 0.24995632469654)
        BackgroundSpark.alpha2:SetTarget (BackgroundSpark)
        BackgroundSpark.alpha3 = DF:CreateAnimation (MainAnimationGroup, "ALPHA", 3, 0.195999994874, 0.25, 0)
        BackgroundSpark.alpha3:SetTarget (BackgroundSpark)

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
		backgroundTexture:SetAtlas("ComboPoints-PointBg")
        --backgroundTexture:SetAtlas("ClassOverlay-ComboPoint-Off")
        backgroundTexture:SetDrawLayer("OVERLAY", 1)
        backgroundTexture:SetPoint("center", widgetFrame, "center", 0, 0)
        backgroundTexture:SetSize(13, 13)
        backgroundTexture:SetVertexColor(0.96470373868942, 0.99999779462814, 0.98823314905167, 0.99999779462814)
        widgetFrame.background = backgroundTexture
        parent.widgetsBackground[#parent.widgetsBackground + 1] = backgroundTexture

        --> single animation group
        local MainAnimationGroup = DF:CreateAnimationHub (widgetFrame)
        MainAnimationGroup:SetLooping("NONE")
        MainAnimationGroup:SetToFinalAlpha(true)

        ----------------------------------------------

        local comboPointTexture  = widgetFrame:CreateTexture("$parentcomboPointTextureTexture", "ARTWORK")
        comboPointTexture:SetAtlas("ComboPoints-ComboPoint")
		--comboPointTexture:SetAtlas("ClassOverlay-ComboPoint")
        comboPointTexture:SetDrawLayer("BORDER", 0)
        comboPointTexture:SetPoint("center", widgetFrame, "center", 0, 0)
        comboPointTexture:SetSize(13, 13)
        
        widgetFrame.texture = comboPointTexture

        --> animations for comboPointTexture

        comboPointTexture.alpha1 = DF:CreateAnimation (MainAnimationGroup, "ALPHA", 1, 0.195999994874, 0, 0.49912714958191)
        comboPointTexture.alpha1:SetTarget(comboPointTexture)
        comboPointTexture.scale1 = DF:CreateAnimation (MainAnimationGroup, "SCALE", 1, 0.195999994874, 0.29999998211861, 0.29999998211861, 1.3999999761581, 1.3999999761581)
        comboPointTexture.scale1:SetTarget(comboPointTexture)
        comboPointTexture.scale2 = DF:CreateAnimation (MainAnimationGroup, "SCALE", 2, 0.096000000834465, 0.9899999499321, 0.9899999499321, 0.79999995231628, 0.78999996185303)
        comboPointTexture.scale2:SetTarget(comboPointTexture)
        comboPointTexture.alpha2 = DF:CreateAnimation (MainAnimationGroup, "ALPHA", 2, 0.096000000834465, 0.69999998807907, 1)
        comboPointTexture.alpha2:SetTarget(comboPointTexture)
        comboPointTexture.alpha2:SetOrder(2)
        comboPointTexture.alpha2:SetDuration(0.096000000834465)
        comboPointTexture.alpha2:SetFromAlpha(0.69999998807907)
        comboPointTexture.alpha2:SetToAlpha(1)

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
        backgroundTexture:SetAtlas("Mage-ArcaneCharge")
        backgroundTexture:SetDrawLayer("OVERLAY", 0)
        backgroundTexture:SetPoint("center", widgetFrame, "center", 0, 0)
        backgroundTexture:SetSize(20, 20)
        backgroundTexture:SetDesaturated(true)
        backgroundTexture:SetBlendMode("ADD")
        widgetFrame.background = backgroundTexture
        parent.widgetsBackground[#parent.widgetsBackground + 1] = backgroundTexture

        --> single animation group
        local MainAnimationGroup = DF:CreateAnimationHub (widgetFrame)
        MainAnimationGroup:SetLooping("NONE")
        MainAnimationGroup:SetToFinalAlpha(true)

        widgetFrame:SetScript("OnHide", function()
            MainAnimationGroup:Stop()
        end)

        ----------------------------------------------

        local comboPointTexture  = widgetFrame:CreateTexture("$parentcomboPointTextureTexture", "ARTWORK")
        comboPointTexture:SetAtlas("Mage-ArcaneCharge")
        comboPointTexture:SetDrawLayer("ARTWORK", 0)
        comboPointTexture:SetPoint("center", widgetFrame, "center", 0, 0)
        comboPointTexture:SetSize(20, 20)

        --> animations for comboPointTexture

        comboPointTexture.scale = DF:CreateAnimation (MainAnimationGroup, "SCALE", 1, 0.096000000834465, 0, 0, 1, 1)
        comboPointTexture.scale:SetTarget(comboPointTexture)
        comboPointTexture.alpha = DF:CreateAnimation (MainAnimationGroup, "ALPHA", 1, 0.096000000834465, 0, 1)
        comboPointTexture.alpha:SetTarget(comboPointTexture)
        comboPointTexture.scale2 = DF:CreateAnimation (MainAnimationGroup, "SCALE", 2, 0.096000000834465, 1.3097063302994, 1.3097063302994, 1, 1)
        comboPointTexture.scale2:SetTarget(comboPointTexture)

        --> test the animation
        --MainAnimationGroup:Play()

        widgetFrame.ShowAnimation = MainAnimationGroup
        return widgetFrame
    end

    local paladinChargesFunc = function(parent, frameName)
        --> create the main frame
        local widgetFrame = CreateFrame("frame", frameName, parent)
		local curWidtgetNum = #parent.widgets + 1

        --> create background
        local backgroundTexture = parent:CreateTexture("$parentBackgroundTexture", "BACKGROUND")
        --backgroundTexture:SetTexture([[Interface\AddOns\Plater\images\paladin_combo_point_deactive]])
		--backgroundTexture:SetTexCoord(0, 1, 0, 1)
		if curWidtgetNum == 5 then
			backgroundTexture:SetAtlas("nameplates-holypower4-off")
			backgroundTexture:SetTexCoord(1,0,0,1)
		else
			backgroundTexture:SetAtlas("nameplates-holypower" .. curWidtgetNum .. "-off")
		end
        backgroundTexture:SetDrawLayer("BACKGROUND", 0)
        backgroundTexture:SetPoint("center", widgetFrame, "center", 0, 0)
        backgroundTexture:SetSize(25, 19)
        backgroundTexture:SetDesaturated(true)
        widgetFrame.background = backgroundTexture
        parent.widgetsBackground[#parent.widgetsBackground + 1] = backgroundTexture

        --> single animation group
        local MainAnimationGroup = DF:CreateAnimationHub (widgetFrame)
        MainAnimationGroup:SetLooping("NONE")
        MainAnimationGroup:SetToFinalAlpha(true)

        widgetFrame:SetScript("OnHide", function()
            MainAnimationGroup:Stop()
        end)

        local comboPointOn  = widgetFrame:CreateTexture("$parentcomboPointOnTexture", "ARTWORK")
        --comboPointOn:SetTexture([[Interface\AddOns\Plater\images\paladin_combo_point_active]])
		--comboPointOn:SetTexCoord(0, 1, 0, 1)
		if curWidtgetNum == 5 then
			comboPointOn:SetAtlas("nameplates-holypower4-on")
			comboPointOn:SetTexCoord(1,0,0,1)
		else
			comboPointOn:SetAtlas("nameplates-holypower" .. curWidtgetNum .. "-on")
		end
		
        comboPointOn:SetDrawLayer("ARTWORK", 0)
        comboPointOn:SetPoint("center", widgetFrame, "center", 0, 0)
        comboPointOn:SetSize(25, 19)

        --> animations for comboPointOn

        comboPointOn.scale = DF:CreateAnimation (MainAnimationGroup, "SCALE", 1, 0.096000000834465, 0.44999998807907, 0.59999996423721, 1, 1)
        comboPointOn.scale:SetTarget(comboPointOn)
        comboPointOn.scale2 = DF:CreateAnimation (MainAnimationGroup, "SCALE", 2, 0.056000001728535, 1.0951955318451, 1.0951955318451, 1, 1)
        comboPointOn.scale2:SetTarget(comboPointOn)

        --> test the animation
        --MainAnimationGroup:Play()

        widgetFrame.ShowAnimation = MainAnimationGroup
        return widgetFrame
    end
	
	local warlockChargesFunc = function(parent, frameName)
        --> create the main frame
        local widgetFrame = CreateFrame("frame", frameName, parent)
		widgetFrame:SetSize(17,22)

        --> create background
        local backgroundTexture = parent:CreateTexture("$parenttopCircleTexture", "BACKGROUND")
        backgroundTexture:SetAtlas("Warlock-EmptyShard")
        backgroundTexture:SetDrawLayer("BACKGROUND", 1)
        backgroundTexture:SetPoint("center", widgetFrame, "center", 0, 0)
        backgroundTexture:SetSize(17, 22)
        widgetFrame.background = backgroundTexture
        parent.widgetsBackground[#parent.widgetsBackground + 1] = backgroundTexture

        --> single animation group
        local MainAnimationGroup = DF:CreateAnimationHub (widgetFrame)
        MainAnimationGroup:SetLooping("NONE")
        MainAnimationGroup:SetToFinalAlpha(true)

        ----------------------------------------------

        local comboPointTexture  = widgetFrame:CreateTexture("$parentcomboPointTextureTexture", "ARTWORK")
        comboPointTexture:SetAtlas("Warlock-ReadyShard")
        comboPointTexture:SetDrawLayer("BORDER", 0)
        comboPointTexture:SetPoint("center", widgetFrame, "center", 0, 0)
        comboPointTexture:SetSize(17, 22)
		
		widgetFrame.texture = comboPointTexture
		
		local glowTexture  = widgetFrame:CreateTexture("$parentglowTextureTexture", "ARTWORK")
		glowTexture:SetAtlas("Warlock-Shard-Spark")
        glowTexture:SetDrawLayer("BORDER", 0)
        glowTexture:SetPoint("center", widgetFrame, "center", 0, 0)
        glowTexture:SetSize(17, 22)
		
		widgetFrame.glowtexture = glowTexture
		
		--Warlock-FillShard
		local fillBar = CreateFrame("StatusBar", "$parentFillBar", widgetFrame)
		fillBar:SetAllPoints()
		fillBar:SetFrameLevel(widgetFrame:GetFrameLevel() + 1)
		fillBar:SetFrameStrata(widgetFrame:GetFrameStrata())
		fillBar.barTexture = fillBar:CreateTexture ("$parentTexture", "ARTWORK")
		fillBar.barTexture:SetAtlas("Warlock-FillShard")
		fillBar:SetStatusBarTexture (fillBar.barTexture)
		fillBar:SetOrientation("VERTICAL")
		fillBar:SetMinMaxValues(0,1)
		fillBar:SetAlpha(0.7)
		fillBar:SetPoint("TOPLEFT", comboPointTexture, "TOPLEFT", 0, 0)
		fillBar:SetPoint("BOTTOMRIGHT", comboPointTexture, "BOTTOMRIGHT", 0, 0)
		
		widgetFrame.fillBar = fillBar
		
		
		comboPointTexture.scale = DF:CreateAnimation (MainAnimationGroup, "SCALE", 1, 0.096000000834465, 0, 0, 1, 1)
        comboPointTexture.scale:SetTarget(comboPointTexture)
        comboPointTexture.alpha = DF:CreateAnimation (MainAnimationGroup, "ALPHA", 1, 0.096000000834465, 0, 1)
        comboPointTexture.alpha:SetTarget(comboPointTexture)
        comboPointTexture.scale2 = DF:CreateAnimation (MainAnimationGroup, "SCALE", 2, 0.096000000834465, 1.3097063302994, 1.3097063302994, 1, 1)
        comboPointTexture.scale2:SetTarget(comboPointTexture)

        --> test the animation
        --MainAnimationGroup:Play()

        widgetFrame.ShowAnimation = MainAnimationGroup
        return widgetFrame
    end
	
	--helper from blizz
	local RUNE_KEY_BY_SPEC = {
		[1] = "Blood",
		[2] = "Frost",
		[3] = "Unholy",
	}
	function Plater.Resources.GetRuneKeyBySpec(specIndex)
		return RUNE_KEY_BY_SPEC[specIndex] or "Base";
	end
	local CD_EDGE_BY_SPEC = {
		[1] = "BloodUnholy",
		[2] = "Frost",
		[3] = "BloodUnholy",
	}
	function Plater.Resources.GetCDEdgeBySpec(specIndex)
		return CD_EDGE_BY_SPEC[specIndex] or "BloodUnholy";
	end
	
	local deathknightChargesFunc = function(parent, frameName)
		local specIndex = GetSpecialization()
		
        --> create the main frame
        --local widgetFrame = CreateFrame("Button", frameName, parent, "ClassNameplateBarDeathKnightRuneButton")
		local widgetFrame = CreateFrame("Button", frameName, parent)
		widgetFrame:SetSize(16,16)
		
		local comboPointTexture
		local test = nil 
		
		--rune cd
		local cooldown = CreateFrame("Cooldown", "$parentCooldown", widgetFrame, "CooldownFrameTemplate")
		cooldown:SetPoint("center", widgetFrame, "center", 0, 0)
		cooldown:SetSize(40, 40)
		cooldown:SetReverse(true)
		cooldown:SetDrawBling(false)
		cooldown:SetHideCountdownNumbers(true)
		cooldown:SetUseCircularEdge(true)
		--cooldown:SetSwipeColor(1, 1, 1, 1)
		cooldown:SetSwipeTexture("Interface\\PlayerFrame\\DK-"..Plater.Resources.GetRuneKeyBySpec(specIndex).."-Rune-CDFill")
		cooldown:SetEdgeTexture("Interface\\PlayerFrame\\DK-"..Plater.Resources.GetCDEdgeBySpec(specIndex).."-Rune-CDSpark")
		--cooldown:SetFrameLevel(widgetFrame:GetFrameLevel() + 5)
		--cooldown:SetFrameStrata(widgetFrame:GetFrameStrata())
		
		widgetFrame.cooldown = cooldown

		--> create background
		local backgroundTexture = widgetFrame:CreateTexture("$parenttopCircleTexture", "BACKGROUND")
		backgroundTexture:SetAtlas("DK-Rune-CD")
		--backgroundTexture:SetDrawLayer("BACKGROUND", 1)
		backgroundTexture:SetPoint("center", widgetFrame, "center", 0, 0)
		backgroundTexture:SetSize(16, 16)
		backgroundTexture:SetTexelSnappingBias(0.0)
		backgroundTexture:SetSnapToPixelGrid(false)
		widgetFrame.background = backgroundTexture
		parent.widgetsBackground[#parent.widgetsBackground + 1] = backgroundTexture

		----------------------------------------------

		comboPointTexture = widgetFrame:CreateTexture("$parentcomboPointTextureTexture", "ARTWORK")
		comboPointTexture:SetAtlas("DK-"..Plater.Resources.GetRuneKeyBySpec(specIndex).."-Rune-Ready")
		--comboPointTexture:SetTexture([[Interface\PlayerFrame\UI-PlayerFrame-Deathknight-SingleRune]])
		--comboPointTexture:SetDrawLayer("ARTWORK", 0)
		comboPointTexture:SetPoint("center", widgetFrame, "center", 0, 0)
		comboPointTexture:SetSize(16, 16)
		comboPointTexture:SetTexelSnappingBias(0.0)
		comboPointTexture:SetSnapToPixelGrid(false)
		
		widgetFrame.texture = comboPointTexture
		
		--[[
		local glowTexture  = widgetFrame:CreateTexture("$parentglowTextureTexture", "OVERLAY")
		glowTexture:SetAtlas("DK-Rune-Glow")
		glowTexture:SetDrawLayer("OVERLAY", 0)
		glowTexture:SetPoint("center", widgetFrame, "center", 0, 0)
		glowTexture:SetSize(16, 16)
		glowTexture:SetTexelSnappingBias(0.0);
		glowTexture:SetSnapToPixelGrid(false);
		
		widgetFrame.glowtexture = glowTexture
		]]--
		
		--> animation group on icon to work around cooldown texts behaving weird...
		local MainAnimationGroup = DF:CreateAnimationHub (comboPointTexture)
		MainAnimationGroup:SetLooping("NONE")
		MainAnimationGroup:SetToFinalAlpha(true)
		comboPointTexture.scale = DF:CreateAnimation (MainAnimationGroup, "SCALE", 1, 0.096000000834465, 0, 0, 1, 1)
        comboPointTexture.scale:SetTarget(comboPointTexture)
        comboPointTexture.alpha = DF:CreateAnimation (MainAnimationGroup, "ALPHA", 1, 0.096000000834465, 0, 1)
        comboPointTexture.alpha:SetTarget(comboPointTexture)
        comboPointTexture.scale = DF:CreateAnimation (MainAnimationGroup, "SCALE", 2, 0.096000000834465, 1.3097063302994, 1.3097063302994, 1, 1)
        comboPointTexture.scale:SetTarget(comboPointTexture)

        --> test the animation
        --MainAnimationGroup:Play()

        widgetFrame.ShowAnimation = MainAnimationGroup
        return widgetFrame
    end
	
	local deathknightChargesFuncWotLK = function(parent, frameName)
		
        --> create the main frame
        --local widgetFrame = CreateFrame("Button", frameName, parent, "ClassNameplateBarDeathKnightRuneButton")
		local widgetFrame = CreateFrame("Button", frameName, parent)
		widgetFrame:SetSize(18,18)
		
		--rune cd
		local cooldown = CreateFrame("Cooldown", "$parentCooldown", widgetFrame, "CooldownFrameTemplate")
        cooldown:ClearAllPoints()
		cooldown:SetPoint("center", widgetFrame, "center", 0, -1)
		cooldown:SetSize(14, 14)
		cooldown:SetReverse(false)
		cooldown:SetDrawBling(false)
		cooldown:SetHideCountdownNumbers(true)
		cooldown:SetUseCircularEdge(true)
		cooldown:SetDrawEdge(true)
		
		widgetFrame.cooldown = cooldown

		--> create background
		local backgroundTexture = widgetFrame:CreateTexture("$parenttopCircleTexture", "BACKGROUND")
		backgroundTexture:SetTexture("Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Ring")
		backgroundTexture:SetPoint("center", widgetFrame, "center", 0, 0)
		backgroundTexture:SetSize(18, 18)
		backgroundTexture:SetTexelSnappingBias(0.0)
		backgroundTexture:SetSnapToPixelGrid(false)
		backgroundTexture:SetVertexColor(.6, .6, .6, 1)
        backgroundTexture:SetDrawLayer("OVERLAY", 1)
		widgetFrame.background = backgroundTexture
		parent.widgetsBackground[#parent.widgetsBackground + 1] = backgroundTexture

		----------------------------------------------

		local comboPointTexture = widgetFrame:CreateTexture("$parentcomboPointTextureTexture", "ARTWORK")
		comboPointTexture:SetTexture("Interface\\ComboFrame\\ComboPoint")
		comboPointTexture:SetPoint("center", widgetFrame, "center", 0, 0)
		comboPointTexture:SetSize(18, 18)
		comboPointTexture:SetTexelSnappingBias(0.0)
		comboPointTexture:SetSnapToPixelGrid(false)
		comboPointTexture:SetDrawLayer("OVERLAY", 0)
		
		widgetFrame.texture = comboPointTexture
		
		--[[
		local glowTexture  = widgetFrame:CreateTexture("$parentglowTextureTexture", "OVERLAY")
		glowTexture:SetAtlas("DK-Rune-Glow")
		glowTexture:SetDrawLayer("OVERLAY", 0)
		glowTexture:SetPoint("center", widgetFrame, "center", 0, 0)
		glowTexture:SetSize(16, 16)
		glowTexture:SetTexelSnappingBias(0.0);
		glowTexture:SetSnapToPixelGrid(false);
		
		widgetFrame.glowtexture = glowTexture
		]]--
		
		--> animation group on icon to work around cooldown texts behaving weird...
		local MainAnimationGroup = DF:CreateAnimationHub (comboPointTexture)
		MainAnimationGroup:SetLooping("NONE")
		MainAnimationGroup:SetToFinalAlpha(true)
		comboPointTexture.scale = DF:CreateAnimation (MainAnimationGroup, "SCALE", 1, 0.096000000834465, 0, 0, 1, 1)
        comboPointTexture.scale:SetTarget(comboPointTexture)
        comboPointTexture.alpha = DF:CreateAnimation (MainAnimationGroup, "ALPHA", 1, 0.096000000834465, 0, 1)
        comboPointTexture.alpha:SetTarget(comboPointTexture)
        comboPointTexture.scale = DF:CreateAnimation (MainAnimationGroup, "SCALE", 2, 0.096000000834465, 1.3097063302994, 1.3097063302994, 1, 1)
        comboPointTexture.scale:SetTarget(comboPointTexture)

        --> test the animation
        --MainAnimationGroup:Play()

        widgetFrame.ShowAnimation = MainAnimationGroup
        return widgetFrame
    end
	
	local evokerChargesFunc = function(parent, frameName)
		--> create the main frame
        --local widgetFrame = CreateFrame("Button", frameName, parent, "ClassNameplateBarDeathKnightRuneButton")
		local widgetFrame = CreateFrame("Button", frameName, parent, "EssencePointButtonTemplate")
		widgetFrame:SetSize(24,24)
		
        widgetFrame.background = widgetFrame.EssenceEmpty
		parent.widgetsBackground[#parent.widgetsBackground + 1] = widgetFrame.EssenceEmpty
        
		widgetFrame.EssenceFillDone.AnimInOrig = widgetFrame.EssenceFillDone.AnimIn
		widgetFrame.EssenceFillDone.AnimIn = {Play = function() end, Stop = function() end}
		
		widgetFrame.ShowAnimation = {Play = function() end, Stop = function() end}
		
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
	resourceCreationFunctions[CONST_SPECID_WARLOCK_AFFLICTION] = warlockChargesFunc
	resourceCreationFunctions[CONST_SPECID_WARLOCK_DEMONOLOGY] = warlockChargesFunc
	resourceCreationFunctions[CONST_SPECID_WARLOCK_DESTRUCTION] = warlockChargesFunc
	resourceCreationFunctions[CONST_SPECID_DK_UNHOLY] = IS_WOW_PROJECT_MAINLINE and deathknightChargesFunc or deathknightChargesFuncWotLK
	resourceCreationFunctions[CONST_SPECID_DK_FROST] = IS_WOW_PROJECT_MAINLINE and deathknightChargesFunc or deathknightChargesFuncWotLK
	resourceCreationFunctions[CONST_SPECID_DK_BLOOD] = IS_WOW_PROJECT_MAINLINE and deathknightChargesFunc or deathknightChargesFuncWotLK
	resourceCreationFunctions[CONST_SPECID_EVOKER_DEVASTATION] = evokerChargesFunc
	resourceCreationFunctions[CONST_SPECID_EVOKER_PRESERVATION] = evokerChargesFunc
	resourceCreationFunctions[CONST_SPECID_EVOKER_AUGMENTATION] = evokerChargesFunc
