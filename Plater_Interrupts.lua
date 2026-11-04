local addonId, platerInternal = ...
local Plater = Plater
local DF = DetailsFramework
local _

--interrupt cooldown: icon on enemy nameplates and cast bar tint while the player's interrupt is not ready
--one tracker per client, plates register no events of their own

local IS_WOW_PROJECT_MAINLINE = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
local IS_WOW_PROJECT_CLASSIC_MOP = DF.IsPandaWow()
local IS_WOW_PROJECT_MIDNIGHT = DF.IsAddonApocalypseWow()

local LibSharedMedia = LibStub:GetLibrary("LibSharedMedia-3.0")

local C_Spell = C_Spell
local issecretvalue = issecretvalue
local unpack = unpack
local ipairs = ipairs
local UnitPowerType = UnitPowerType
local GetTime = GetTime
local FindSpellOverrideByID = C_SpellBook.FindSpellOverrideByID or FindSpellOverrideByID
local GetSpellTexture = C_Spell.GetSpellTexture or GetSpellTexture

local MEMBER_TARGET = platerInternal.VarSharing.MEMBER_TARGET

local CONST_COMMAND_DEMON = 119898
local CONST_TEST_COOLDOWN = 15
local CONST_ICON_TEXCOORD = {0.078125, 0.921875, 0.078125, 0.921875}
local CONST_COOLDOWN_EDGE_TEXTURE = [[Interface\Cooldown\edge]]
local CONST_SPARK_TEXTURE = [[Interface\CastingBar\UI-CastingBar-Spark]]
local CONST_SPARK_WIDTH = 12

local Interrupts = {}
platerInternal.Interrupts = Interrupts

--interrupt candidates per class in priority order, the first known one is tracked
--an id that doesn't exist on a flavor is never known there
local interruptsByClass = {
	WARRIOR = {6552, 386071, 102060, 72},
	PALADIN = {96231, 31935, 425609},
	HUNTER = {34490, 187707, 147362},
	ROGUE = {1766},
	PRIEST = {15487},
	DEATHKNIGHT = {47528, 47476},
	SHAMAN = {57994},
	MAGE = {2139},
	WARLOCK = {19647, 19244},
	MONK = {116705},
	DRUID = {106839, 78675},
	DEMONHUNTER = {183752},
	EVOKER = {351338},
}

--command demon (retail, mists) is known as the override of 119898, the override spell carries the pet's cooldown
--119914 is axe toss on retail and felstorm on mists, 119911 optical blast exists on mists only
local commandDemonSpells = {}
if (IS_WOW_PROJECT_MAINLINE or IS_WOW_PROJECT_CLASSIC_MOP) then
	local overrides = {119910, 132409, IS_WOW_PROJECT_MAINLINE and 119914 or 119911}
	for index, spellId in ipairs(overrides) do
		commandDemonSpells[spellId] = true
		table.insert(interruptsByClass.WARLOCK, index, spellId)
	end
else
	--feral charge and earth shock interrupt on era and tbc only
	table.insert(interruptsByClass.DRUID, 16979)
	table.insert(interruptsByClass.SHAMAN, 8042)
end

local candidates = interruptsByClass[select(2, UnitClass("player"))] or {}
local isEnemyActorType = {enemynpc = true, enemyplayer = true}

local isEnabled = false
local activeSpellId --the tracked interrupt, nil while none is known
local isOnCooldown = false
local durationObject --cooldown of the tracked interrupt, fed to the icons
local cooldownEndTime --classic flavors only, cooldowns are plain there
local configVersion = 0

local isSpellKnown = function(spellId)
	if (commandDemonSpells[spellId]) then
		--the lookup returns 119898 itself without a fitting pet
		return FindSpellOverrideByID(CONST_COMMAND_DEMON) == spellId
	end

	return C_SpellBook.IsSpellKnown(spellId, Enum.SpellBookSpellBank.Player) or C_SpellBook.IsSpellKnown(spellId, Enum.SpellBookSpellBank.Pet)
end

--returns the per spell color from the cast colors tab, nil when the spell has none
local getSpellColor = function(castBar, profile)
	local spellId = castBar.spellID
	if (issecretvalue(spellId)) then
		return
	end

	local customColor = profile.cast_colors[spellId]
	if (customColor and customColor[1] and customColor[2] and customColor[2] ~= "white") then
		return customColor[2]
	end
end

--hidden cooldown frame running the interrupt cooldown, its OnCooldownDone is the ready moment
local cooldownTracker = CreateFrame("cooldown", "PlaterInterruptCooldownTracker", UIParent, "CooldownFrameTemplate")
cooldownTracker:SetSize(1, 1)
cooldownTracker:SetPoint("topleft", UIParent, "topleft", 0, 0)
cooldownTracker:SetAlpha(0)
cooldownTracker:Show()

--the interrupt is ready again: sound and refresh of every plate
--no sound when the tracked spell changed (spec swap, pet dismissed)
local onReady = function(canPlaySound)
	isOnCooldown = false
	cooldownEndTime = nil

	local profile = Plater.db.profile
	if (canPlaySound and profile.interrupt_cd_sound ~= "" and not Plater.IsShowingCastBarTest) then
		PlaySoundFile(LibSharedMedia:Fetch("sound", profile.interrupt_cd_sound), "Master")
	end

	Interrupts.UpdateAllPlates()
end

cooldownTracker:SetScript("OnCooldownDone", function()
	if (isOnCooldown) then
		onReady(true)
	end
end)

--reads the cooldown of the tracked interrupt, plates are refreshed when the state changes
--forceUpdate refreshes them anyway (the tracked spell changed)
local readCooldown = function(forceUpdate)
	local wasOnCooldown = isOnCooldown
	local cooldownInfo = activeSpellId and C_Spell.GetSpellCooldown(activeSpellId)
	--isOnGCD is nil on pet spells, nil counts as not on the global cooldown
	isOnCooldown = cooldownInfo and cooldownInfo.isActive and not cooldownInfo.isOnGCD or false

	if (isOnCooldown) then
		durationObject = C_Spell.GetSpellCooldownDuration(activeSpellId, true)
		cooldownTracker:SetCooldownFromDurationObject(durationObject)
		if (not IS_WOW_PROJECT_MIDNIGHT) then
			cooldownEndTime = cooldownInfo.startTime + cooldownInfo.duration
		end

		if (wasOnCooldown and not forceUpdate) then
			--a running cooldown can change (reductions), only the shown icons follow it
			for _, plateFrame in ipairs(Plater.GetAllShownPlates()) do
				local unitFrame = plateFrame.unitFrame
				if (unitFrame and unitFrame.PlaterOnScreen and unitFrame.InterruptCooldownFrame:IsShown()) then
					unitFrame.InterruptCooldownFrame.Cooldown:SetCooldownFromDurationObject(durationObject)
				end
			end
		else
			Interrupts.UpdateAllPlates()
		end

	elseif (wasOnCooldown) then
		cooldownTracker:Clear()
		onReady(not forceUpdate)

	elseif (forceUpdate) then
		Interrupts.UpdateAllPlates()
	end
end

--SPELL_UPDATE_COOLDOWN, the payload is no filter: the end of a cooldown comes without it or with another spell id
function Interrupts.OnCooldownUpdate() --private
	if (not isEnabled) then
		return
	end

	--a command demon override can change without SPELLS_CHANGED (grimoire of sacrifice)
	if (activeSpellId and commandDemonSpells[activeSpellId] and not isSpellKnown(activeSpellId)) then
		Interrupts.Refresh()
		return
	end

	readCooldown()
end

--finds the tracked interrupt again, called on SPELLS_CHANGED and on pet changes
function Interrupts.Refresh() --private
	if (not isEnabled) then
		return
	end

	local spellId
	for _, candidateId in ipairs(candidates) do
		if (isSpellKnown(candidateId)) then
			spellId = candidateId
			break
		end
	end

	local hasChanged = spellId ~= activeSpellId
	activeSpellId = spellId
	readCooldown(hasChanged)
end

--sets size, anchor, colors and text of the icon from the profile
local skinIcon = function(iconFrame, profile)
	iconFrame.ConfigVersion = configVersion

	local size = profile.interrupt_cd_icon_size
	iconFrame:SetSize(size, size)
	iconFrame:ClearAllPoints()
	Plater.SetAnchor(iconFrame, profile.interrupt_cd_icon_anchor)

	local borderSize = profile.interrupt_cd_icon_border_size
	local border = iconFrame.Border
	border:ClearAllPoints()
	border:SetPoint("topleft", iconFrame, "topleft", -borderSize, borderSize)
	border:SetPoint("bottomright", iconFrame, "bottomright", borderSize, -borderSize)
	border:SetColorTexture(unpack(profile.interrupt_cd_icon_border_color))
	border:SetShown(borderSize > 0)

	local cooldown = iconFrame.Cooldown
	cooldown:SetSwipeColor(unpack(profile.interrupt_cd_icon_swipe_color))
	cooldown:SetEdgeTexture(CONST_COOLDOWN_EDGE_TEXTURE)
	cooldown:SetHideCountdownNumbers(not profile.interrupt_cd_icon_show_text)

	local countdownText = cooldown:GetCountdownFontString()
	DF:SetFontFace(countdownText, profile.plate_config.enemynpc.spellname_text_font)
	DF:SetFontSize(countdownText, profile.interrupt_cd_icon_text_size)
	DF:SetFontOutline(countdownText, "OUTLINE")
end

--creates the icon and the cast bar spark of a new nameplate
function Interrupts.CreatePlateWidgets(unitFrame) --private
	local healthBar = unitFrame.healthBar
	local iconFrame = CreateFrame("frame", unitFrame:GetName() .. "PlaterInterruptCooldown", healthBar)
	iconFrame:SetFrameLevel(healthBar:GetFrameLevel() + 10)
	iconFrame:Hide()

	iconFrame.Border = iconFrame:CreateTexture(nil, "background")

	iconFrame.Icon = iconFrame:CreateTexture(nil, "artwork")
	iconFrame.Icon:SetAllPoints()
	iconFrame.Icon:SetTexCoord(unpack(CONST_ICON_TEXCOORD))

	iconFrame.Cooldown = CreateFrame("cooldown", nil, iconFrame, "CooldownFrameTemplate")
	iconFrame.Cooldown:SetAllPoints()
	iconFrame.Cooldown:SetDrawEdge(true)
	iconFrame.Cooldown:EnableMouse(false)

	unitFrame.InterruptCooldownFrame = iconFrame

	local castBar = unitFrame.castBar
	local sparkParent = castBar

	--midnight: cast and cooldown times are secret, so the client places the spark. a transparent bar starts at
	--the edge of the cast fill, is scaled to the cast duration and filled to the remaining cooldown, its fill
	--edge is where the cast fill will be when the interrupt is ready. it sits in a frame clipped to the cast bar,
	--a ready point after the cast end is cut off
	if (IS_WOW_PROJECT_MIDNIGHT) then
		local clipFrame = CreateFrame("frame", nil, castBar)
		clipFrame:SetAllPoints()
		clipFrame:SetClipsChildren(true)

		local readyBar = CreateFrame("statusbar", nil, clipFrame)
		readyBar:SetStatusBarTexture([[Interface\Buttons\WHITE8X8]])
		readyBar:GetStatusBarTexture():SetAlpha(0)
		readyBar:Hide()
		--runs only while shown, which is only while the interrupt is on cooldown (durationObject is set)
		readyBar:SetScript("OnUpdate", function(self)
			self:SetValue(durationObject:GetRemainingDuration())
		end)
		castBar.InterruptReadyBar = readyBar
		sparkParent = readyBar

		--midnight: the texture can't be swapped by a secret, it is a texture over the cast fill whose alpha follows them
		local textureOverlay = castBar:CreateTexture(nil, "artwork", nil, -5)
		textureOverlay:Hide()
		castBar.InterruptTextureOverlay = textureOverlay
	end

	local spark = sparkParent:CreateTexture(nil, "overlay")
	spark:SetTexture(CONST_SPARK_TEXTURE)
	spark:SetBlendMode("ADD")
	spark:Hide()
	castBar.InterruptSpark = spark
end

--shows or hides the icon of a nameplate, called from the plate update and on tracker changes
function Interrupts.UpdatePlate(unitFrame) --private
	local iconFrame = unitFrame.InterruptCooldownFrame
	local profile = Plater.db.profile
	local isTest = Plater.IsShowingCastBarTest

	local showIcon = profile.interrupt_cd_icon_enabled and activeSpellId and isEnemyActorType[unitFrame.ActorType]
	if (showIcon and profile.interrupt_cd_icon_hide_when_ready) then
		showIcon = isOnCooldown or isTest
	end

	local onlyTarget = profile.interrupt_cd_icon_only_target
	local onlyFocus = profile.interrupt_cd_icon_only_focus and Plater.PlayerHasFocusTarget
	if (showIcon and (onlyTarget or onlyFocus)) then
		--with both filters on, the icon shows on the target and on the focus
		showIcon = (onlyTarget and unitFrame[MEMBER_TARGET]) or (onlyFocus and unitFrame.IsFocus)
	end

	if (showIcon and profile.interrupt_cd_icon_only_casters) then
		--a secret power type can't be compared, the icon stays
		local powerType = UnitPowerType(unitFrame.unit)
		showIcon = issecretvalue(powerType) or powerType == Enum.PowerType.Mana
	end

	if (not showIcon) then
		iconFrame:Hide()
		return
	end

	if (iconFrame.ConfigVersion ~= configVersion) then
		skinIcon(iconFrame, profile)
	end

	iconFrame.Icon:SetTexture(GetSpellTexture(activeSpellId))
	if (isOnCooldown) then
		iconFrame.Cooldown:SetCooldownFromDurationObject(durationObject)
	elseif (isTest) then
		iconFrame.Cooldown:SetCooldown(GetTime(), CONST_TEST_COOLDOWN)
	else
		iconFrame.Cooldown:Clear()
	end

	iconFrame:Show()
end

--refreshes icon and cast bar of every shown nameplate
function Interrupts.UpdateAllPlates() --private
	for _, plateFrame in ipairs(Plater.GetAllShownPlates()) do
		local unitFrame = plateFrame.unitFrame
		if (unitFrame and unitFrame.PlaterOnScreen) then
			Interrupts.UpdatePlate(unitFrame)
			Interrupts.UpdateCastBar(unitFrame.castBar)
		end
	end
end

--applies a color below the non interruptible color, midnight only (casts are secret)
--with priority off the important color stays above the given color
local setSecretCastColor = function(castBar, profile, r, g, b, a, isRangeSecret, inRange)
	local colors = castBar.Colors
	local splitEvaluateColor = platerInternal.SplitEvaluateColor
	local isImportant = castBar.isImportant
	--secrets are only checked with type(), a comparison could error
	local hasImportant = type(isImportant) ~= "nil" and colors.Important

	if (hasImportant and not profile.cast_statusbar_interrupt_not_ready_priority) then
		local color = colors.Important
		r, g, b, a = splitEvaluateColor(isImportant, color.r, color.g, color.b, color.a, r, g, b, a)
	end

	--a secret range result picks between the given color and the regular cast color
	if (isRangeSecret) then
		local color = castBar.channeling and colors.Channeling or colors.Casting
		local baseR, baseG, baseB, baseA = color.r, color.g, color.b, color.a
		if (hasImportant) then
			color = colors.Important
			baseR, baseG, baseB, baseA = splitEvaluateColor(isImportant, color.r, color.g, color.b, color.a, baseR, baseG, baseB, baseA)
		end

		r, g, b, a = splitEvaluateColor(inRange, baseR, baseG, baseB, baseA, r, g, b, a)
	end

	if (type(castBar.notInterruptible) ~= "nil") then
		local color = colors.NonInterruptible
		r, g, b, a = splitEvaluateColor(castBar.notInterruptible, color.r, color.g, color.b, color.a, r, g, b, a)
	end

	castBar:GetStatusBarTexture():SetVertexColor(r, g, b, a)
end

--color, texture and spark of an enemy cast bar while the interrupt is not ready or out of range
function Interrupts.UpdateCastBar(castBar) --private
	local spark = castBar.InterruptSpark
	if (not activeSpellId and not castBar.InterruptColorApplied and not castBar.InterruptTextureApplied and not spark:IsShown()) then
		return
	end

	local profile = Plater.db.profile
	local isCasting = (castBar.casting or castBar.channeling) and not castBar.IsInterrupted
	local isTracked = isCasting and activeSpellId and isEnemyActorType[castBar.unitFrame.ActorType]
	--classic: non interruptible casts keep their colors, midnight can't tell them apart in lua
	if (isTracked and not IS_WOW_PROJECT_MIDNIGHT and not castBar.canInterrupt) then
		isTracked = false
	end

	local isNotReady = isTracked and (isOnCooldown or Plater.IsShowingCastBarTest)
	local readyAt = isNotReady and cooldownEndTime and cooldownEndTime + profile.cast_statusbar_interrupt_ready_in_time_grace
	local isReadyInTime = readyAt and readyAt < castBar.spellEndTime

	local color
	local isOutOfRange = false
	local isRangeSecret = false
	local secretInRange
	if (isNotReady) then
		if (profile.cast_statusbar_interrupt_not_ready_enabled) then
			if (isReadyInTime and profile.cast_statusbar_interrupt_ready_in_time_enabled) then
				color = profile.cast_statusbar_color_interrupt_ready_in_time
			else
				color = profile.cast_statusbar_color_interrupt_not_ready
			end
		end

	elseif (isTracked and profile.cast_statusbar_interrupt_range_enabled) then
		--nil (no range for this spell) counts as in range
		local inRange = C_Spell.IsSpellInRange(activeSpellId, castBar.unit)
		if (issecretvalue(inRange)) then
			color = profile.cast_statusbar_color_interrupt_out_of_range
			isRangeSecret = true
			secretInRange = inRange
		elseif (inRange == false) then
			color = profile.cast_statusbar_color_interrupt_out_of_range
			isOutOfRange = true
		end
	end

	--priority off: a per spell color stays
	if (color and not profile.cast_statusbar_interrupt_not_ready_priority and getSpellColor(castBar, profile)) then
		color = nil
	end

	local wantsTexture = (isNotReady or isOutOfRange or isRangeSecret) and profile.cast_statusbar_interrupt_texture ~= ""

	--classic: the texture goes first, the color is applied on top of it. midnight uses an overlay, see below
	if (not IS_WOW_PROJECT_MIDNIGHT) then
		if (wantsTexture) then
			castBar:SetStatusBarTexture(LibSharedMedia:Fetch("statusbar", profile.cast_statusbar_interrupt_texture))
			castBar.InterruptTextureApplied = true

		elseif (castBar.InterruptTextureApplied) then
			castBar.InterruptTextureApplied = nil
			castBar:SetStatusBarTexture(LibSharedMedia:Fetch("statusbar", profile.cast_statusbar_texture))
		end
	end

	if (color) then
		local r, g, b, a = unpack(color)
		if (IS_WOW_PROJECT_MIDNIGHT) then
			setSecretCastColor(castBar, profile, r, g, b, a, isRangeSecret, secretInRange)
		else
			castBar:SetColor(r, g, b, a)
		end
		castBar.InterruptColorApplied = true

	elseif (castBar.InterruptColorApplied) then
		castBar.InterruptColorApplied = nil
		--back to the colors the cast started with, end states (interrupted, finished) are left to the cast bar
		if (isCasting) then
			castBar:UpdateCastColor()
			local spellColor = getSpellColor(castBar, profile)
			if (spellColor) then
				castBar:SetColor(spellColor)
			end
		end
	end

	--midnight: the overlay takes the bar's color, its alpha hides it on non interruptible casts and, with a secret
	--range result, in range. it is stretched over the fill, so a texture with a horizontal pattern is squeezed
	if (IS_WOW_PROJECT_MIDNIGHT) then
		local textureOverlay = castBar.InterruptTextureOverlay
		if (wantsTexture) then
			local castFill = castBar:GetStatusBarTexture()
			local r, g, b = castFill:GetVertexColor()
			local alpha = 1
			if (isRangeSecret) then
				alpha = C_CurveUtil.EvaluateColorValueFromBoolean(secretInRange, 0, 1)
			end

			textureOverlay:SetTexture(LibSharedMedia:Fetch("statusbar", profile.cast_statusbar_interrupt_texture))
			textureOverlay:SetAllPoints(castFill)
			textureOverlay:SetVertexColor(r, g, b, alpha)
			if (type(castBar.notInterruptible) ~= "nil") then
				textureOverlay:SetAlphaFromBoolean(castBar.notInterruptible, 0, 1)
			else
				textureOverlay:SetAlpha(1)
			end

			textureOverlay:Show()
			castBar.InterruptTextureApplied = true

		elseif (castBar.InterruptTextureApplied) then
			castBar.InterruptTextureApplied = nil
			textureOverlay:Hide()
		end
	end

	--spark at the point of the cast bar where the interrupt is ready again
	if (IS_WOW_PROJECT_MIDNIGHT) then
		local readyBar = castBar.InterruptReadyBar
		--the cast test has no duration object, nor a real cooldown
		local castDuration = castBar.durationObject
		if (isNotReady and isOnCooldown and castDuration and profile.cast_statusbar_interrupt_spark_enabled) then
			local castFill = castBar:GetStatusBarTexture()
			readyBar:ClearAllPoints()
			readyBar:SetWidth(castBar:GetWidth())
			readyBar:SetMinMaxValues(0, castDuration:GetTotalDuration())
			readyBar:SetValue(durationObject:GetRemainingDuration())
			spark:ClearAllPoints()
			spark:SetSize(CONST_SPARK_WIDTH, castBar:GetHeight())

			--channels drain to the left (empowered casts fill like casts)
			if (castBar.channeling and not castBar.empowered) then
				readyBar:SetReverseFill(true)
				readyBar:SetPoint("topright", castFill, "topright")
				readyBar:SetPoint("bottomright", castFill, "bottomright")
				spark:SetPoint("center", readyBar:GetStatusBarTexture(), "left")
			else
				readyBar:SetReverseFill(false)
				readyBar:SetPoint("topleft", castFill, "topright")
				readyBar:SetPoint("bottomleft", castFill, "bottomright")
				spark:SetPoint("center", readyBar:GetStatusBarTexture(), "right")
			end

			--no spark on non interruptible casts
			if (type(castBar.notInterruptible) ~= "nil") then
				readyBar:SetAlphaFromBoolean(castBar.notInterruptible, 0, 1)
			else
				readyBar:SetAlpha(1)
			end

			readyBar:Show()
			spark:Show()
		else
			readyBar:Hide()
			spark:Hide()
		end

	--classic: plain times, the spark only shows when the interrupt is ready before the cast ends
	elseif (isReadyInTime and profile.cast_statusbar_interrupt_spark_enabled) then
		local castDuration = castBar.spellEndTime - castBar.spellStartTime
		--channels drain from the right
		local elapsedAtReady = castBar.channeling and (castBar.spellEndTime - readyAt) or (readyAt - castBar.spellStartTime)
		spark:SetSize(CONST_SPARK_WIDTH, castBar:GetHeight())
		spark:ClearAllPoints()
		spark:SetPoint("center", castBar, "left", elapsedAtReady / castDuration * castBar:GetWidth(), 0)
		spark:Show()
	else
		spark:Hide()
	end
end

--profile changed: registers the tracker events when any part of the feature is on and refreshes the plates
function Interrupts.RefreshConfig() --private
	local profile = Plater.db.profile
	configVersion = configVersion + 1

	isEnabled = profile.interrupt_cd_icon_enabled
		or profile.interrupt_cd_sound ~= ""
		or profile.cast_statusbar_interrupt_not_ready_enabled
		or profile.cast_statusbar_interrupt_range_enabled
		or profile.cast_statusbar_interrupt_texture ~= ""
		or profile.cast_statusbar_interrupt_spark_enabled
		or false

	local eventFrame = Plater.EventHandlerFrame
	if (isEnabled) then
		eventFrame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
		eventFrame:RegisterEvent("SPELLS_CHANGED")
		Interrupts.Refresh()
		Interrupts.UpdateAllPlates()
	else
		eventFrame:UnregisterEvent("SPELL_UPDATE_COOLDOWN")
		eventFrame:UnregisterEvent("SPELLS_CHANGED")
		activeSpellId = nil
		isOnCooldown = false
		cooldownEndTime = nil
		cooldownTracker:Clear()
		Interrupts.UpdateAllPlates()
	end
end
