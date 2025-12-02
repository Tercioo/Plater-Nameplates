
local Plater = _G.Plater
local DF = _G.DetailsFramework
local AnimateTexCoords = _G.AnimateTexCoords
local LCG = LibStub:GetLibrary("LibCustomGlow-1.0") -- https://github.com/Stanzilla/LibCustomGlow

local IS_WOW_PROJECT_MAINLINE = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
local IS_WOW_PROJECT_NOT_MAINLINE = WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE
local IS_WOW_PROJECT_CLASSIC_ERA = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
local IS_WOW_PROJECT_CLASSIC_WRATH = IS_WOW_PROJECT_NOT_MAINLINE and ClassicExpansionAtLeast and LE_EXPANSION_WRATH_OF_THE_LICH_KING and ClassicExpansionAtLeast(LE_EXPANSION_WRATH_OF_THE_LICH_KING)
--local IS_WOW_PROJECT_CLASSIC_CATACLYSM = IS_WOW_PROJECT_NOT_MAINLINE and ClassicExpansionAtLeast and LE_EXPANSION_CATACLYSM and ClassicExpansionAtLeast(LE_EXPANSION_CATACLYSM)
local IS_WOW_PROJECT_CLASSIC_MOP = IS_WOW_PROJECT_NOT_MAINLINE and ClassicExpansionAtLeast and LE_EXPANSION_MISTS_OF_PANDARIA and ClassicExpansionAtLeast(LE_EXPANSION_MISTS_OF_PANDARIA)
local IS_WOW_PROJECT_MIDNIGHT = DF.IsAddonApocalypseWow()

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

---play an animation with dots around the nameplate
---@param frame frame parent frame
---@param textureId any which dot texture to use, goes from 1 to 5
---@param color any accept color name "yellow", rgba{1, .7, .2, 1}, {r = 1, g = 1, b = 1, a = 1}
---@param xOffset number? adjust the left and right padding
---@param yOffset number? adjust the bottom and top padding
---@param blendMode string? default "ADD", shouldn't be changed
---@param throttleOverride number? override the animation speed, default 0.016
---this function return a frame to be used on StopDotsAnimation()
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

	--create a glow around the frame using LibCustomGlow - defaults to "button" glow
	--[[ options can be used to create different glow types, see https://www.curseforge.com/wow/addons/libcustomglow
		--type "pixel"
		options = {
			glowType = "pixel",
			color = "white", -- all plater color types accepted, from lib: {r,g,b,a}, color of lines and opacity, from 0 to 1. Defaul value is {0.95, 0.95, 0.32, 1}
			N = 8, -- number of lines. Defaul value is 8;
			frequency = 0.25, -- frequency, set to negative to inverse direction of rotation. Default value is 0.25;
			length = 4, -- length of lines. Default value depends on region size and number of lines;
			th = 2, -- thickness of lines. Default value is 2;
			xOffset = 0,
			yOffset = 0, -- offset of glow relative to region border;
			border = false, -- set to true to create border under lines;
			key = "", -- key of glow, allows for multiple glows on one frame;
		}

		-- type "ants"
		options = {
			glowType = "ants",
			color = "white", -- all plater color types accepted, from lib: {r,g,b,a}, color of lines and opacity, from 0 to 1. Defaul value is {0.95, 0.95, 0.32, 1}
			N = 4, -- number of particle groups. Each group contains 4 particles. Defaul value is 4;
			frequency = 0.125, -- frequency, set to negative to inverse direction of rotation. Default value is 0.125;
			scale = 1, -- scale of particles
			xOffset = 0,
			yOffset = 0, -- offset of glow relative to region border;
			key = "", -- key of glow, allows for multiple glows on one frame;
		}

		-- type "button"
		options = {
			glowType = "button",
			color = "white", -- all plater color types accepted, from lib: {r,g,b,a}, color of lines and opacity, from 0 to 1. Defaul value is {0.95, 0.95, 0.32, 1}
			frequency = 0.125, -- frequency, set to negative to inverse direction of rotation. Default value is 0.125;
		}
	--]]
	function Plater.StartGlow(frame, color, options, key)
		if not frame then return end

		if not color and (options and options.color) then
			color = options.color
		end
		if color then
			local r, g, b, a = DF:ParseColors (color)
			color = {r, g, b, a}
			options.color = color
		end

		if not options then
			options = {
				glowType = "button",
				color = color,
				key = key or "",
			}
		end

		if not options.glowType then
			options.glowType = "button"
		end

		if key then
			options.key = key
		end

		if (not frame.__PlaterGlowFrame) then
			frame.__PlaterGlowFrame = CreateFrame("Frame", nil, frame, BackdropTemplateMixin and "BackdropTemplate");
			frame.__PlaterGlowFrame:SetAllPoints(frame);
			frame.__PlaterGlowFrame:SetSize(frame:GetSize());
		end

		if options.glowType == "button" then
			LCG.ButtonGlow_Start(frame.__PlaterGlowFrame, options.color, options.frequency, options.framelevel)
		elseif options.glowType == "pixel" then
			if not options.border then options.border = false end
			LCG.PixelGlow_Start(frame.__PlaterGlowFrame, options.color, options.N, options.frequency, options.length, options.th, options.xOffset, options.yOffset, options.border, options.key or "", options.framelevel)
		elseif options.glowType == "ants" then
			LCG.AutoCastGlow_Start(frame.__PlaterGlowFrame, options.color, options.N, options.frequency, options.scale, options.xOffset, options.yOffset, options.key or "", options.framelevel)
		elseif options.glowType == "proc" then
			LCG.ProcGlow_Start(frame.__PlaterGlowFrame, options)
		end
	end

	-- creates a button glow effect
	function Plater.StartButtonGlow(frame, color, options, key)
		-- type "button"
		if not options then
			options = {
				glowType = "button",
				color = color, -- all plater color types accepted, from lib: {r,g,b,a}, color of lines and opacity, from 0 to 1. Defaul value is {0.95, 0.95, 0.32, 1}
				frequency = 0.125, -- frequency, set to negative to inverse direction of rotation. Default value is 0.125;
				key = key or "", -- key of glow, allows for multiple glows on one frame;
			}
		else
			options.glowType = "button"
		end

		Plater.StartGlow(frame, color or options.color, options, options.key)
	end

	-- creates an ants glow effect
	function Plater.StartAntsGlow(frame, color, options, key)
		-- type "ants"
		if not options then
			options = {
				glowType = "ants",
				color = color,
				N = 4, -- number of particle groups. Each group contains 4 particles. Defaul value is 4;
				frequency = 0.125, -- frequency, set to negative to inverse direction of rotation. Default value is 0.125;
				scale = 1, -- scale of particles
				xOffset = 0,
				yOffset = 0, -- offset of glow relative to region border;
				key = key or "", -- key of glow, allows for multiple glows on one frame;
			}
		else
			options.glowType = "ants"
		end

		Plater.StartGlow(frame, color or options.color, options, options.key)
	end

	-- creates a pixel glow effect
	function Plater.StartPixelGlow(frame, color, options, key)
		-- type "pixel"
		if not options then
			options = {
				glowType = "pixel",
				color = color, -- all plater color types accepted, from lib: {r,g,b,a}, color of lines and opacity, from 0 to 1. Defaul value is {0.95, 0.95, 0.32, 1}
				N = 8, -- number of lines. Defaul value is 8;
				frequency = 0.25, -- frequency, set to negative to inverse direction of rotation. Default value is 0.25;
				--length = 4, -- length of lines. Default value depends on region size and number of lines;
				th = 2, -- thickness of lines. Default value is 2;
				xOffset = 0,
				yOffset = 0, -- offset of glow relative to region border;
				border = false, -- set to true to create border under lines;
				key = key or "", -- key of glow, allows for multiple glows on one frame;
			}
		else
			options.glowType = "pixel"
		end

		Plater.StartGlow(frame, color or options.color, options, options.key)
	end

	-- creates a proc glow effect
	function Plater.StartProcGlow(frame, color, options, key)
		-- type "proc"
		if not options then
			options = {
				glowType = "proc",
				color = color,
				--frameLevel = 8,
				startAnim = true,
				xOffset = 0,
				yOffset = 0,
				duration = 1,
				key = key,
			}
		else
			options.glowType = "proc"
		end

		Plater.StartGlow(frame, color or options.color, options, options.key)
	end

	-- stop LibCustomGlow effects on the frame, if existing
	-- if glowType (and key) are given, stop one glow. if not, stop all.
	function Plater.StopGlow(frame, glowType, key)
		if not frame then return end
		if not frame.__PlaterGlowFrame then return end

		if glowType then
			if glowType == "button" then
				LCG.ButtonGlow_Stop(frame.__PlaterGlowFrame, key or "")
			elseif glowType == "pixel" then
				LCG.PixelGlow_Stop(frame.__PlaterGlowFrame, key or "")
			elseif glowType == "ants" then
				LCG.AutoCastGlow_Stop(frame.__PlaterGlowFrame, key or "")
			elseif glowType == "proc" then
				LCG.ProcGlow_Stop(frame.__PlaterGlowFrame, key or "")
			end
		else
			LCG.ButtonGlow_Stop(frame.__PlaterGlowFrame, key or "")
			LCG.PixelGlow_Stop(frame.__PlaterGlowFrame, key or "")
			LCG.AutoCastGlow_Stop(frame.__PlaterGlowFrame, key or "")
			LCG.ProcGlow_Stop(frame.__PlaterGlowFrame, key or "")
		end
	end

	-- stop a button glow
	function Plater.StopButtonGlow(frame, key)
		Plater.StopGlow(frame, "button", key)
	end

	-- stop a button glow
	function Plater.StopPixelGlow(frame, key)
		Plater.StopGlow(frame, "pixel", key)
	end

	-- stop an ants glow
	function Plater.StopAntsGlow(frame, key)
		Plater.StopGlow(frame, "ants", key)
	end

	-- stop a proc glow
	function Plater.StopProcGlow(frame, key)
		Plater.StopGlow(frame, "proc", key)
	end

	--create a glow around an icon
	function Plater.CreateIconGlow (frame, color, color2, useShowAnimation)
		local f = Plater:CreateGlowOverlay (frame, color, color2 or color)
		if not useShowAnimation and IS_WOW_PROJECT_MAINLINE then
			f:SetScript("OnShow", nil) --reset

			local onShow = function(self)
				if (self.ProcStartAnim) then
					self.ProcStartAnim:Stop()
					self.ProcStartFlipbook:Hide()
					if (not self.ProcLoop:IsPlaying()) then
						self.ProcLoop:Play()
					end
				end
			end

			f:SetScript("OnShow", onShow)
		end
		return f
	end

	--create a glow around the healthbar or castbar frame
	function Plater.CreateNameplateGlow (frame, color, left, right, top, bottom)
		local antTable = {
			Throttle = 0.025,
			AmountParts = 15,
			TexturePartsWidth = 167.4,
			TexturePartsHeight = 83.6,
			TextureWidth = 512,
			TextureHeight = 512,
			BlendMode = "ADD",
			Color = color,
			Texture = [[Interface\AddOns\Plater\images\ants_rectangle]],
		}

		--> ants
		local f = DF:CreateAnts (frame, antTable, -27 + (left or 0), 25 + (right or 0), 5 + (top or 0), -7 + (bottom or 0))
		f:SetFrameLevel (frame:GetFrameLevel() + 1)
		f:SetAlpha (ALPHA_BLEND_AMOUNT - 0.249845)

		--> glow
		local glow = f:CreateTexture (nil, "background")
		glow:SetTexture ([[Interface\AddOns\Plater\images\nameplate_glow]])
		PixelUtil.SetPoint (glow, "center", frame, "center", 0, 0)
		glow:SetSize (frame:GetWidth() + frame:GetWidth()/2.3, 36)
		glow:SetBlendMode ("ADD")
		glow:SetVertexColor (DF:ParseColors (color or "white"))
		glow:SetAlpha (ALPHA_BLEND_AMOUNT)
		glow.GlowTexture = glow

		return f
	end

	function Plater.OnPlayCustomFlashAnimation (animationHub)
		animationHub:GetParent():Show()
		animationHub.Texture:Show()
		--animationHub.Texture:Show()
	end
	function Plater.OnStopCustomFlashAnimation (animationHub)
		animationHub:GetParent():Hide()
		animationHub.Texture:Hide()
	end
	function Plater.UpdateCustomFlashAnimation (animationHub, duration, r, g, b)
		for i = 1, #animationHub.AllAnimations do
			if (duration) then
				animationHub.AllAnimations [i]:SetDuration (duration)
			end
			if (r) then
				r, g, b = DF:ParseColors (r, g, b)
				animationHub.Texture:SetColorTexture (r, g, b)
			end
		end
	end

	--creates a flash, call returnedValue:Play() to flash
	function Plater.CreateFlash (frame, duration, amount, r, g, b, a)
		--defaults
		duration = duration or 0.25
		amount = amount or 1

		if (not r) then
			r, g, b, a = 1, 1, 1, 1
		else
			r, g, b, a = DF:ParseColors (r, g, b, a)
		end

		--create the flash frame
		local f = CreateFrame ("frame", "PlaterFlashAnimationFrame".. math.random (1, 100000000), frame, BackdropTemplateMixin and "BackdropTemplate")
		f:SetFrameLevel (frame:GetFrameLevel()+1)
		f:SetAllPoints()
		f:Hide()

		--create the flash texture
		local t = f:CreateTexture ("PlaterFlashAnimationTexture".. math.random (1, 100000000), "artwork")
		t:SetColorTexture (r, g, b, a)
		t:SetAllPoints()
		t:SetBlendMode ("ADD")
		t:Hide()

		--create the flash animation
		local animationHub = DF:CreateAnimationHub (f, Plater.OnPlayCustomFlashAnimation, Plater.OnStopCustomFlashAnimation)
		animationHub.AllAnimations = {}
		animationHub.Parent = f
		animationHub.Texture = t
		animationHub.Amount = amount
		animationHub.UpdateDurationAndColor = Plater.UpdateCustomFlashAnimation

		for i = 1, amount * 2, 2 do
			local fadeIn = DF:CreateAnimation (animationHub, "Alpha", i, duration, 0, 1)
			local fadeOut = DF:CreateAnimation (animationHub, "Alpha", i + 1, duration, 1, 0)
			tinsert (animationHub.AllAnimations, fadeIn)
			tinsert (animationHub.AllAnimations, fadeOut)
		end

		return animationHub
	end