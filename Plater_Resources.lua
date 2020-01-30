
local Plater = _G.Plater
local GameCooltip = GameCooltip2
local DF = DetailsFramework
local _

--default settings
--[=[
--alignment settings
resource_padding = 1,

--size settings
block_size = 20,
block_texture_background = "Interface\\COMMON\\Indicator-Gray"
block_texture_artwork = "Interface\\COMMON\\Indicator-Yellow"
block_texture_overlay = "Interface\\CHARACTERFRAME\\TempPortraitAlphaMaskSmall"
--]=]


--[=[
- quando o plater é iniciado, criar um unico frame para o resource que irá pular para a nameplate que é alvo
- quando uma nameplate é mostrada no jogo, confere se o novo resource esta ativo e se ele é mostrado na nameplate alvo e se o jogador tem spec que usa
- quando o alvo é mudado, faz as checagens acima tbm
- se é mostrado na personal bar, apenas adicionar ela lá

- funcões que serão necessárias:
    - criação do frame do resource quando o plater for iniciado (CreateResourceBar)
    - precisa mostra o resource em uma nameplate (UpdateResourceBar)
    - verifica se a spec que o jogador esta usando possui uma barra de resource

- cache e verificações no codigo do plater
    - variaveis que precisam de cache: esta usando o novo resource e se esta usando target (ou no personal bar)
    - ao mudar de target >  conferir se esta usando o novo resource > conferir se esta usando resource em nameplate > conferir se a namepalte é o alvo
    - se a spec do jogador não usar uma barra de resource, por false que o jogador esta usando o novo resource
--]=]


local CONST_NUM_COMBO_POINTS = 10
local animationFunctions = {}

--cache
local DB_USE_PLATER_RESOURCE_BAR = false
local DB_PLATER_RESOURCE_BAR_ON_PERSONAL = false


--when plater in the main file refreshes its upvalues, this function is also called
--called from plater.lua on Plater.RefreshDBUpvalues()
function Plater.RefreshResourcesDBUpvalues()
    local profile = Plater.db.profile

    DB_USE_PLATER_RESOURCE_BAR = profile.plater_resources_show
    DB_PLATER_RESOURCE_BAR_ON_PERSONAL = profile.plater_resources_personal_bar
end


--base frame for resource bar, it's a child of the main frame 'PlaterNameplatesResourceBar'
--the function passed is responsible to build textures and animations
local create_resource_frame = function (parent, frameName, func)
    local resourceFrame = CreateFrame("frame", frameName, parent)

    resourceFrame:EnableMouse (false)
    resourceFrame:EnableMouseWheel (false)

    --store all widgets
    resourceFrame.widgets = {}

    --create widgets which are frames holding textures and animations
    for i = 1, CONST_NUM_COMBO_POINTS do
        local newWidget = func(resourceFrame, "$parentCP" .. i)
        resourceFrame.widgets [#resourceFrame.widgets + 1] = newWidget
        newWidget:EnableMouse(false)
        newWidget:EnableMouseWheel(false)
        newWidget:SetSize(20, 20)
        newWidget:Hide()
    end
end


--separated resources functions for class and specs
local resource_monk = function(platerResourceBar)
    --platerResourceBar.resourceBars [268] = create_resource_frame (platerResourceBar, "$parentMonk1Resource") --brewmaster chi bar
    platerResourceBar.resourceBars [269] = create_resource_frame (platerResourceBar, "$parentMonk2Resource", animationFunctions.CreateMonkComboPoints) --windwalker points
    tinsert (platerResourceBar.allResourceBars, platerResourceBar.resourceBars [269])
end

--each function create a resource frame for its class or spec
local resource_mage_arcane = function(platerResourceBar)
    platerResourceBar.resourceBars [62] = create_resource_frame (platerResourceBar, "$parentArcaneResource")
    tinsert (platerResourceBar.allResourceBars, platerResourceBar.resourceBars [62])
end

local resource_rogue_druid_cpoints = function(platerResourceBar)
    --rogue
    platerResourceBar.resourceBars ["ROGUE"] = create_resource_frame (platerResourceBar, "$parentRogueResource")
    tinsert (platerResourceBar.allResourceBars, platerResourceBar.resourceBars ["ROGUE"])

    --druid feral
    platerResourceBar.resourceBars [103] = platerResourceBar.resourceBars ["ROGUE"]
    tinsert (platerResourceBar.allResourceBars, platerResourceBar.resourceBars [103])
end

local resource_warlock = function(platerResourceBar)
    platerResourceBar.resourceBars ["WARLOCK"] = create_resource_frame (platerResourceBar, "$parentWarlockResource")
    tinsert (platerResourceBar.allResourceBars, platerResourceBar.resourceBars ["WARLOCK"])
end

local resource_paladin = function(platerResourceBar)
    platerResourceBar.resourceBars [70] = create_resource_frame (platerResourceBar, "$parentPaladinResource")
    tinsert (platerResourceBar.allResourceBars, platerResourceBar.resourceBars [70])
end

local resource_dk = function(platerResourceBar)
    platerResourceBar.resourceBars ["DEATHKNIGHT"] = create_resource_frame (platerResourceBar, "$parentDKResource")
    tinsert (platerResourceBar.allResourceBars, platerResourceBar.resourceBars ["DEATHKNIGHT"])
end


--this funtion is called once at the logon, it'll create the resource frames for the class
function Plater.CreatePlaterResourceBar()

    --create a frame attached to UIParent, this frame is the fondation for the resource bar
    local platerResourceBar = CreateFrame("frame", "PlaterNameplatesResourceBar", UIParent)

    --store the resources bars created for the class or spec (hash table)
    platerResourceBar.resourceBars = {}
    --store all resource bars created (index table)
    platerResourceBar.allResourceBars = {}
    
    --grab the player class
    local playerClass = Plater.PlayerClass

    if (WOW_PROJECT_ID == WOW_PROJECT_CLASSIC) then --classic

    else
        if (playerClass == "MAGE") then
            resource_mage_arcane(platerResourceBar)

        elseif (playerClass == "ROGUE" or playerClass == "DRUID") then
            resource_rogue_druid_cpoints(platerResourceBar)

        elseif (playerClass == "WARLOCK") then
            resource_warlock(platerResourceBar)

        elseif (playerClass == "PALADIN") then
            resource_paladin(platerResourceBar)

        elseif (playerClass == "DEATHKNIGHT") then
            resource_dk(platerResourceBar)

        elseif (playerClass == "MONK") then
            resource_monk(platerResourceBar)
        end
    end
end


--called when use plater resource bar is disabled or when no match on rules to show it
--only called from inside this file
function Plater.HidePlaterResourceBar()
    return PlaterNameplatesResourceBar:Hide()
end

--currently is called from:
--player spec change (PLAYER_SPECIALIZATION_CHANGED)
--decides if the resource is shown or not
function Plater.CanUsePlaterResourceBar()
    
    --nameplate which will have the resource bar
    local nameplateAnchor

    if (not DB_USE_PLATER_RESOURCE_BAR) then
        return Plater.HidePlaterResourceBar()

    elseif (not DB_PLATER_RESOURCE_BAR_ON_PERSONAL) then
        --target nameplate
        nameplateAnchor = C_NamePlate.GetNamePlateForUnit ("target")
        --if the player has no target, this will return nil
        if (not nameplateAnchor) then
            return Plater.HidePlaterResourceBar()
        end

    else
        --personal bar
        nameplateAnchor = C_NamePlate.GetNamePlateForUnit ("player")
        --if the player nameplate does not exists, just quit
        if (not nameplateAnchor) then
            return Plater.HidePlaterResourceBar()
        end
    end

    local specIndex = GetSpecialization()
    if (specIndex) then
        
        local playerClass = Plater.PlayerClass

        do
            --check if the resource bar is used by all specs in the player class
            local resourceBar = _G.PlaterNameplatesResourceBar.resourceBars[playerClass]
            if (resourceBar) then
                return Plater.UpdatePlaterResourceBar(nameplateAnchor, resourceBar)
            end
        end

        do
            --check if the player spec uses a resource bar
            local resourceBar = _G.PlaterNameplatesResourceBar.resourceBars[specIndex]
            if (resourceBar) then
                return Plater.UpdatePlaterResourceBar(nameplateAnchor, resourceBar)
            end
        end

    else
        --if no specialization, player might be low level
        if (UnitLevel("player") < 10) then
            --should get by class?
            if (playerClass == "ROGUE") then
                return Plater.UpdatePlaterResourceBar(nameplateAnchor, _G.PlaterNameplatesResourceBar.resourceBars ["ROGUE"])
            end
        end
    end

    return Plater.HidePlaterResourceBar()
end


--called when 'CanUsePlaterResourceBar' gives green flag to show the resource bar
--this funtion receives the nameplate and the bar to show
--
function Plater.UpdatePlaterResourceBar(plateFrame, resourceBar)

    --main resource frame
    local platerResourceBar = _G.PlaterNameplatesResourceBar
    --nameplate unit frame
    local unitFrame = platerFrane.unitFrame
    --resource bar
    resourceBar = resourceBar

    --check if the resource bar to show isn't the same which ill be show
    if (platerResourceBar.currentBarShown) then
        if (platerResourceBar.currentBarShown ~= resourceBar) then
            platerResourceBar.currentBarShown:Hide()
        end
    end

    --show the resource bar
    resourceBar:Show()
    platerResourceBar:Show()

    if (WOW_PROJECT_ID == WOW_PROJECT_CLASSIC) then 
        

    else
        

    end

end


animationFunctions.CreateMonkComboPoints = function(parent, frameName)

    --> create the main frame
    local MonkWWComboPoint = CreateFrame ("frame", frameName, parent);

    --> single animation group
    local MainAnimationGroup = MonkWWComboPoint:CreateAnimationGroup ("MonkWWComboPointAnimationGroup")
    MainAnimationGroup:SetLooping ("NONE")

    --> widgets:

    ----------------------------------------------

    local Background  = MonkWWComboPoint:CreateTexture ("BackgroundTexture", "BORDER")
    Background:SetTexture ([[Interface\PLAYERFRAME\MonkUIAtlas]])
    Background:SetDrawLayer ("BORDER", 1)
    Background:SetPoint ("center", MonkWWComboPoint, "center", 0, 0)
    Background:SetSize (100, 100)
    Background:SetVertexColor (0.98431158065796, 0.99215465784073, 0.99999779462814, 0.99999779462814)
    Background:SetTexCoord (0.54899997711182, 0.62299999237061, 0.023999998569489, 0.17200000762939)

    --> animations for Background


    ----------------------------------------------

    local BallTexture  = MonkWWComboPoint:CreateTexture ("BallTextureTexture", "ARTWORK")
    BallTexture:SetTexture ([[Interface\PLAYERFRAME\MonkUIAtlas]])
    BallTexture:SetDrawLayer ("ARTWORK", 0)
    BallTexture:SetPoint ("center", MonkWWComboPoint, "center", -1, 2)
    BallTexture:SetSize (74, 74)
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

    local UpSpark  = MonkWWComboPoint:CreateTexture ("UpSparkTexture", "OVERLAY")
    UpSpark:SetTexture ([[Interface\QUESTFRAME\ObjectiveTracker]])
    UpSpark:SetDrawLayer ("OVERLAY", 0)
    UpSpark:SetPoint ("center", MonkWWComboPoint, "center", 0, 0)
    UpSpark:SetSize (89, 89)
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

    local BackgroundSpark  = MonkWWComboPoint:CreateTexture ("BackgroundSparkTexture", "BACKGROUND")
    BackgroundSpark:SetTexture ([[Interface\PVPFrame\PvPHonorSystem]])
    BackgroundSpark:SetDrawLayer ("BACKGROUND", 0)
    BackgroundSpark:SetPoint ("center", MonkWWComboPoint, "center", 0, 0)
    BackgroundSpark:SetSize (139, 139)
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

    return MonkWWComboPoint
end