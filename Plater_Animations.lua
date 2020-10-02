
local Plater = _G.Plater
local DF = _G.DetailsFramework
local AnimateTexCoords = _G.AnimateTexCoords


local pointTexturesInfo = {
    {
        texture = [[Interface\AddOns\Plater\images\ants_rectangle]],
        width = 512,
        height = 512,
        partWidth = 167.4,
        partHeight = 83.6,
        partAmount = 15,
        throttle = 0.025
    },
    {
        texture = [[Interface\AddOns\Plater\images\ants_rectangle_white]],
        width = 512,
        height = 512,
        partWidth = 256,
        partHeight = 64,
        partAmount = 15,
        throttle = 0.016
    },
    {
        texture = [[Interface\AddOns\Plater\images\ants_rectangle_white2]],
        width = 512,
        height = 512,
        partWidth = 256,
        partHeight = 64,
        partAmount = 15,
        throttle = 0.016
    },
    {
        texture = [[Interface\AddOns\Plater\images\ants_rectangle_white3]],
        width = 512,
        height = 512,
        partWidth = 256,
        partHeight = 64,
        partAmount = 15,
        throttle = 0.072
    },
    {
        texture = [[Interface\AddOns\Plater\images\ants_rectangle_white4]],
        width = 1024,
        height = 1024,
        partWidth = 256,
        partHeight = 64,
        partAmount = 63,
        throttle = 0.016
    },
}

local pointTextureOnUpdateFunc = function(self, deltaTime)
    AnimateTexCoords(self.pointTexture, self.textureInfo.width, self.textureInfo.height, self.textureInfo.partWidth, self.textureInfo.partHeight, self.textureInfo.partAmount, deltaTime, self.textureInfo.throttle)
end

function Plater.StopPointsAnimation(frame, pointFrame)
    if (pointFrame) then
        pointFrame:SetScript("OnUpdate", nil)
        pointFrame:ClearAllPoints()
        pointFrame:Hide()
        Plater.pointsAnimationFrames:Release(pointFrame)

        --remove the pointFrame from the parent
        for i = 1, #frame.pointTextureAnimations do
            if (frame.pointTextureAnimations[i] == pointFrame) then
                tremove(frame.pointTextureAnimations, i)
                break
            end
        end
        --print("removed", Plater.pointsAnimationFrames:GetAmount()) --debug
    else
        --remove all animations
        for i = #frame.pointTextureAnimations, 1, -1 do
            local pointFrame = frame.pointTextureAnimations[i]
            pointFrame:SetScript("OnUpdate", nil)
            pointFrame:ClearAllPoints()
            pointFrame:Hide()
            Plater.pointsAnimationFrames:Release(pointFrame)
            tremove(frame.pointTextureAnimations, i)
            --print("removed", Plater.pointsAnimationFrames:GetAmount()) --debug
        end
    end
end

function Plater.PlayPointsAnimation(frame, textureId, color, xOffset, yOffset, blendMode, throttleOverride)
    --stores all point animations active in the frame
    frame.pointTextureAnimations = frame.pointTextureAnimations or {}

    if (not Plater.pointsAnimationFrames) then
        local createObjectFunc = function()
            --make a new frame
            local newFrame = CreateFrame("frame", nil, UIParent)

            --make the texture which will show the points
            local pointTexture = newFrame:CreateTexture(nil, "overlay")
            newFrame.pointTexture = pointTexture
            pointTexture:SetAllPoints()

            return newFrame
        end
        Plater.pointsAnimationFrames = DF:CreatePool(createObjectFunc)
    end

    xOffset = xOffset or 0
    yOffset = yOffset or 0
    textureId = textureId or 1
    color = color or "white"
    blendMode = blendMode or "ADD"

    --setup the frame
    local pointFrame = Plater.pointsAnimationFrames:Acquire()
    pointFrame:SetParent(frame)
    pointFrame:ClearAllPoints()
    pointFrame:SetFrameLevel(frame:GetFrameLevel()+1)
    pointFrame:SetPoint("topleft", frame, "topleft", -xOffset, yOffset)
    pointFrame:SetPoint("bottomright", frame, "bottomright", xOffset, -yOffset)
    pointFrame:Show()

    --setup the texture
    local textureInfo = DF.table.copy({}, pointTexturesInfo[textureId])
    textureInfo.throttle = throttleOverride or textureInfo.throttle

    pointFrame.textureInfo = textureInfo
    pointFrame.pointTexture:SetTexture(textureInfo.texture)
    pointFrame.pointTexture:SetVertexColor(DF:ParseColors(color))
    pointFrame.pointTexture:SetBlendMode(blendMode)
    pointFrame.pointTexture:SetTexCoord(0, 1, 0, 1)

    --clear AnimateTexCoords() stuff added in the texture
    pointFrame.pointTexture.frame = nil
    pointFrame.pointTexture.throttle = nil
    pointFrame.pointTexture.numColumns = nil
    pointFrame.pointTexture.numRows = nil
    pointFrame.pointTexture.columnWidth = nil
    pointFrame.pointTexture.rowHeight = nil

    tinsert(frame.pointTextureAnimations, pointFrame)

    --scripts
    pointFrame:SetScript("OnUpdate", pointTextureOnUpdateFunc)
    --print("added", Plater.pointsAnimationFrames:GetAmount()) --debug
    return pointFrame
end