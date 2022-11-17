
local Plater = _G.Plater
local DF = _G.DetailsFramework
local AnimateTexCoords = _G.AnimateTexCoords


local dotTexturesInfo = {
    { --1
        texture = [[Interface\AddOns\Plater\images\ants_rectangle]],
        width = 512,
        height = 512,
        partWidth = 167.4,
        partHeight = 83.6,
        partAmount = 15,
        throttle = 0.025,
        speedMultiplier = 1,
    },
    { --2
        texture = [[Interface\AddOns\Plater\images\ants_rectangle_white]],
        width = 512,
        height = 512,
        partWidth = 256,
        partHeight = 64,
        partAmount = 15,
        throttle = 0.016,
        speedMultiplier = 1,
    },
    { --3
        texture = [[Interface\AddOns\Plater\images\ants_rectangle_white2]],
        width = 512,
        height = 512,
        partWidth = 256,
        partHeight = 64,
        partAmount = 15,
        throttle = 0.016,
        speedMultiplier = 1,
    },
    { --4
        texture = [[Interface\AddOns\Plater\images\ants_rectangle_white3]],
        width = 512,
        height = 512,
        partWidth = 256,
        partHeight = 64,
        partAmount = 15,
        throttle = 0.072,
        speedMultiplier = 1,
    },
    { --5
        texture = [[Interface\AddOns\Plater\images\ants_rectangle_white4]],
        width = 1024,
        height = 1024,
        partWidth = 256,
        partHeight = 64,
        partAmount = 63,
        throttle = 0.016,
        speedMultiplier = 1,
    },
    { --6
        texture = [[Interface\AddOns\Plater\images\ants_square_white1]],
        width = 1024,
        height = 512,
        partWidth = 64,
        partHeight = 64,
        partAmount = 74, --79
        throttle = 0.016,
        speedMultiplier = 1,
    },
}

local dotTextureOnUpdateFunc = function(self, deltaTime)
    AnimateTexCoords(self.dotTexture,
    self.textureInfo.width,
    self.textureInfo.height,
    self.textureInfo.partWidth,
    self.textureInfo.partHeight,
    self.textureInfo.partAmount,
    deltaTime * self.textureInfo.speedMultiplier,
    self.textureInfo.throttle)
end

--play an animation with dots around the nameplate
--@frame: parent frame
--@textureId: which dot texture to use, goes from 1 to 5
--@color: accept color name "yellow", rgba{1, .7, .2, 1}, {r = 1, g = 1, b = 1, a = 1}
--@xOffset: adjust the left and right padding
--@yOffset: adjust the bottom and top padding
--@blendMode: default "ADD", shouldn't be changed
--@throttleOverride: override the animation speed, default 0.016
--this function return a frame to be used on StopDotsAnimation()
function Plater.PlayDotAnimation(frame, textureId, color, xOffset, yOffset, blendMode, throttleOverride)
    --stores all dot animations active in the frame
    frame.dotTextureAnimations = frame.dotTextureAnimations or {}

    if (not Plater.dotAnimationFrames) then
        local createObjectFunc = function()
            --make a new frame
            local newFrame = CreateFrame("frame", nil, UIParent)

            --make the texture which will show the dots
            local dotTexture = newFrame:CreateTexture(nil, "overlay")
            newFrame.dotTexture = dotTexture
            dotTexture:SetAllPoints()

            return newFrame
        end
        Plater.dotAnimationFrames = DF:CreatePool(createObjectFunc)
    end

    xOffset = xOffset or 0
    yOffset = yOffset or 0
    textureId = textureId or 1
    color = color or "white"
    blendMode = blendMode or "ADD"

    --setup the frame
    local dotFrame = Plater.dotAnimationFrames:Acquire()
    dotFrame:SetParent(frame)
    dotFrame:ClearAllPoints()
    dotFrame:SetFrameLevel(frame:GetFrameLevel()+1)
    dotFrame:SetPoint("topleft", frame, "topleft", -xOffset, yOffset)
    dotFrame:SetPoint("bottomright", frame, "bottomright", xOffset, -yOffset)
    dotFrame:Show()

    --setup the texture
    local textureInfo = DF.table.copy({}, dotTexturesInfo[textureId])
    textureInfo.throttle = throttleOverride or textureInfo.throttle

    dotFrame.textureInfo = textureInfo
    dotFrame.dotTexture:SetTexture(textureInfo.texture)
    dotFrame.dotTexture:SetVertexColor(DF:ParseColors(color))
    dotFrame.dotTexture:SetBlendMode(blendMode)
    dotFrame.dotTexture:SetTexCoord(0, 1, 0, 1)

    --clear AnimateTexCoords() stuff added in the texture
    dotFrame.dotTexture.frame = nil
    dotFrame.dotTexture.throttle = nil
    dotFrame.dotTexture.numColumns = nil
    dotFrame.dotTexture.numRows = nil
    dotFrame.dotTexture.columnWidth = nil
    dotFrame.dotTexture.rowHeight = nil

    tinsert(frame.dotTextureAnimations, dotFrame)

    --scripts
    dotFrame:SetScript("OnUpdate", dotTextureOnUpdateFunc)
    --print("added", Plater.dotsAnimationFrames:GetAmount()) --debug
    return dotFrame
end

--stop an animation
--@frame: the parent frame used on PlayDotAnimation()
--@dotFrame: the frame returned from PlayDotAnimation()
--if no @dotFrame, it'll stop all point animations in the frame
function Plater.StopDotAnimation(frame, dotFrame)
    if (dotFrame) then
        --remove the dotFrame from the parent
        if (not frame.dotTextureAnimations) then
            return
        end

        for i = 1, #frame.dotTextureAnimations do
            local thisDotAnimation = frame.dotTextureAnimations[i]
            if (thisDotAnimation == dotFrame) then
                thisDotAnimation:SetScript("OnUpdate", nil)
                thisDotAnimation:ClearAllPoints()
                thisDotAnimation:Hide()
                Plater.dotAnimationFrames:Release(thisDotAnimation)
                tremove(frame.dotTextureAnimations, i)
                break
            end
        end
        --print("removed", Plater.dotAnimationFrames:GetAmount()) --debug
    else
        --[=
        --remove all animations from the frame
        if (frame.dotTextureAnimations) then
            for i = #frame.dotTextureAnimations, 1, -1 do
                local dotFrame = frame.dotTextureAnimations[i]
                dotFrame:SetScript("OnUpdate", nil)
                dotFrame:ClearAllPoints()
                dotFrame:Hide()
                Plater.dotAnimationFrames:Release(dotFrame)
                tremove(frame.dotTextureAnimations, i)
                --print("removed", Plater.dotAnimationFrames:GetAmount()) --debug
            end
        end
        --]=]
    end
end


--return true if there's a dot animation running in the frame
--@frame: the parent frame used on PlayDotAnimation()
function Plater.HasDotAnimationPlaying(frame)
    if (not frame.dotTextureAnimations) then
        return
    end

    for i = 1, #frame.dotTextureAnimations do
        local thisDotAnimation = frame.dotTextureAnimations[i]
        if (thisDotAnimation:GetScript("OnUpdate")) then
            return true
        end
    end
end