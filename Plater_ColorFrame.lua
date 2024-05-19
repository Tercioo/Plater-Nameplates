
local Plater = Plater
local addonId, platerInternal = ...
---@type detailsframework
local DF = DetailsFramework
local _


--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> color frame
function Plater.OpenColorFrame()
	if (PlaterColorPreview) then
		PlaterColorPreview:Show()
		return
	end

	local function hex(num)
		local hexstr = '0123456789abcdef'
		local s = ''
		while num > 0 do
			local mod = math.fmod(num, 16)
			s = string.sub(hexstr, mod+1, mod+1) .. s
			num = math.floor(num / 16)
		end
		if s == '' then s = '00' end
		if (string.len (s) == 1) then
			s = "0"..s
		end
		return s
	end

	local a = CreateFrame ("frame", "PlaterColorPreview", UIParent, BackdropTemplateMixin and "BackdropTemplate")
	a:SetSize (1400, 910)
	a:SetPoint ("topleft", UIParent, "topleft")

	--close button
	local closeButton = DF:CreateButton (a, function() a:Hide() end, 160, 20, "", -1, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"))
	closeButton:SetPoint ("topright", a, "topright", -1, 0)
	closeButton:SetText ("Close Color Palette")

	DF:ApplyStandardBackdrop (a)

	local onFocusGained = function (self)
		self:HighlightText (0)
	end
	local onFocusLost = function (self)
		self:HighlightText (0, 0)
	end

	local allColors = {}
	for colorName, colorTable in pairs (DF.alias_text_colors) do
		tinsert (allColors, {colorTable, colorName, hex (colorTable[1]*255) .. hex (colorTable[2]*255) .. hex (colorTable[3]*255)})
	end

	table.sort (allColors, function (t1, t2)
		return t1[1][3] > t2[1][3]
	end)

	local x = 5
	local y = -20
	local totalWidth = 105

	--for colorname, colortable in pairs (DF.alias_text_colors) do

	for index, colorTable in ipairs (allColors) do
		local colortable = colorTable [1]
		local colorname = colorTable [2]

		local backgroundTexture = a:CreateTexture (nil, "overlay")
		backgroundTexture:SetColorTexture (unpack (colortable))
		backgroundTexture:SetSize (100, 20)
		backgroundTexture:SetPoint ("topleft", a, "topleft", x, y)

		local textEntry = DF:CreateTextEntry (a, function()end, 100, 20)
		textEntry:SetBackdrop (nil)
		textEntry:SetPoint ("topleft", backgroundTexture, "topleft", 0, 0)
		textEntry:SetPoint ("bottomright", backgroundTexture, "bottomright", 0, 0)
		textEntry:SetText (colorname)
		textEntry:SetHook ("OnEditFocusGained", onFocusGained)
		textEntry:SetHook ("OnEditFocusLost", onFocusLost)

		y = y - 20
		if (y < -880) then
			y = -20
			x = x + 105
			totalWidth = totalWidth + 105
		end
	end

	a:SetWidth (totalWidth)
end