-- Bigwigs/DBM nameplate aura support
--[[

Options (defaults):
Plater.db.profile.bossmod_support_enabled = true
Plater.db.profile.bossmod_aura_height = 32
Plater.db.profile.bossmod_aura_width = 32
Plater.db.profile.bossmod_cooldown_text_size = 16
Plater.db.profile.bossmod_icons_anchor = {side = 8, x = 0, y = 40}
Plater.db.profile.bossmod_support_bars_enabled = false
Plater.db.profile.bossmod_support_bars_text_max_len = 7
]]--

local DF = _G ["DetailsFramework"]
local Plater = _G.Plater
local C_Timer = _G.C_Timer
local C_NamePlate = _G.C_NamePlate
local GetTime = _G.GetTime

local UNIT_BOSS_MOD_AURAS_ACTIVE = {} --contains for each [GUID] a list of {texture, duration, desaturate}
local UNIT_BOSS_MOD_AURAS_TO_BE_REMOVED = {} --contains for each [GUID] a list of texture-ids to be removed
local UNIT_BOSS_MOD_BARS = {} --contains for each [GUID] the bar information
local UNIT_BOSS_MOD_NEEDS_UPDATE_IN = {} -- timestamp for next update!
local HOSTILE_ENABLED = false
local IS_REGISTERED = false

local DBM_TIMER_BARS_TEST_MODE = false --can be changed via callback. will disable after 30sec

-- core functions
local function ShowNameplateAura(guid, texture, duration, desaturate)
	--print("ShowNameplateAura", guid, texture, duration, desaturate, HOSTILE_ENABLED)
	if not HOSTILE_ENABLED then return end
	if not guid or not texture then return end

	local values = {
		texture = texture,
		duration = duration,
		desaturate = desaturate,
		starttime = GetTime(),
	}

	UNIT_BOSS_MOD_AURAS_ACTIVE [guid] = UNIT_BOSS_MOD_AURAS_ACTIVE [guid] or {}

	for index, value in pairs (UNIT_BOSS_MOD_AURAS_ACTIVE [guid]) do
		if value.texture == values.texture and value.starttime == values.starttime and value.duration == values.duration then
			return
		end
	end

	tinsert(UNIT_BOSS_MOD_AURAS_ACTIVE [guid], values)

	UNIT_BOSS_MOD_NEEDS_UPDATE_IN[guid] = -1
end

local function HideNameplateAura(guid, texture)
	--print("HideNameplateAura", guid, texture)
	if not HOSTILE_ENABLED then return end
	if not guid or not texture then return end

	UNIT_BOSS_MOD_AURAS_TO_BE_REMOVED [guid] = UNIT_BOSS_MOD_AURAS_TO_BE_REMOVED [guid] or {}
	tinsert(UNIT_BOSS_MOD_AURAS_TO_BE_REMOVED [guid], texture)

	UNIT_BOSS_MOD_NEEDS_UPDATE_IN[guid] = -1
end

local function DisableHostile()
	--print("DisableHostile")
	HOSTILE_ENABLED = false
	UNIT_BOSS_MOD_AURAS_ACTIVE = {}
	UNIT_BOSS_MOD_AURAS_TO_BE_REMOVED = {}
end

local function EnableHostile()
	--print("EnableHostile")
	if not Plater.db.profile.bossmod_support_enabled then
		return
	end

	HOSTILE_ENABLED = true
end

function Plater.CreateBossModAuraFrame(unitFrame)

	Plater.RegisterBossModAuras()

	local options = {
		icon_width = Plater.db.profile.bossmod_aura_width or 32,
		icon_height = Plater.db.profile.bossmod_aura_height or 32,
		texcoord = {.1, .9, .1, .9},
		show_text = Plater.db.profile.bossmod_cooldown_text_enabled,
		text_size = Plater.db.profile.bossmod_cooldown_text_size or 16,
		surpress_tulla_omni_cc = Plater.db.profile.disable_omnicc_on_auras,
		desc_text = true,
		desc_text_size = 10
	}
	unitFrame.BossModIconFrame = DF:CreateIconRow (unitFrame.healthBar, "$parentBossModIconRow", options)
	unitFrame.BossModIconFrame:ClearIcons()
	unitFrame.BossModIconFrame.RefreshID = 0

	unitFrame.BossModIconFrame:SetOption ("surpress_tulla_omni_cc", Plater.db.profile.disable_omnicc_on_auras)
	unitFrame.BossModIconFrame:SetOption ("surpress_blizzard_cd_timer", true)
	unitFrame.BossModIconFrame:SetOption ("anchor", Plater.db.profile.bossmod_icons_anchor or {side = 8, x = 0, y = 30})
	unitFrame.BossModIconFrame:SetOption ("grow_direction", unitFrame.ExtraIconFrame:GetIconGrowDirection())
	Plater.SetAnchor (unitFrame.BossModIconFrame, Plater.db.profile.bossmod_icons_anchor or {side = 8, x = 0, y = 30})

end

function Plater.UpdateBossModAuraFrameSettings(unitFrame, refreshID)
	if (unitFrame.BossModIconFrame.RefreshID < refreshID) then
		Plater.SetAnchor (unitFrame.BossModIconFrame, Plater.db.profile.bossmod_icons_anchor)
		unitFrame.BossModIconFrame:SetOption ("surpress_tulla_omni_cc", Plater.db.profile.disable_omnicc_on_auras)
		unitFrame.BossModIconFrame:SetOption ("text_size", Plater.db.profile.bossmod_cooldown_text_size)
		unitFrame.BossModIconFrame:SetOption ("icon_width", Plater.db.profile.bossmod_aura_width)
		unitFrame.BossModIconFrame:SetOption ("icon_height", Plater.db.profile.bossmod_aura_height)
		unitFrame.BossModIconFrame:SetOption ("anchor", Plater.db.profile.bossmod_icons_anchor or {side = 8, x = 0, y = 30})
		unitFrame.BossModIconFrame:SetOption ("grow_direction", unitFrame.ExtraIconFrame:GetIconGrowDirection())

		--> update refresh ID
		unitFrame.BossModIconFrame.RefreshID = refreshID
	end
end

function Plater.EnsureUpdateBossModAuras(guid)
	if not guid then return end
	UNIT_BOSS_MOD_NEEDS_UPDATE_IN[guid] = -1
end

function Plater.UpdateBossModAuras(unitFrame)

	Plater.StartLogPerformanceCore("Plater-Core", "Update", "UpdateBossModAuras")

	local guid = unitFrame.PlateFrame.namePlateUnitGUID
	local curTime = GetTime()

	if not UNIT_BOSS_MOD_NEEDS_UPDATE_IN[guid] or UNIT_BOSS_MOD_NEEDS_UPDATE_IN[guid] > curTime then
		Plater.EndLogPerformanceCore("Plater-Core", "Update", "UpdateBossModAuras")
		return
	end

	-- maybe find a better way with iconFrame:RemoveIcon(...) ? (not yet implemented, but worth a thought)
	if UNIT_BOSS_MOD_AURAS_TO_BE_REMOVED [guid] then
		for removeIndex, removeTexture in pairs(UNIT_BOSS_MOD_AURAS_TO_BE_REMOVED [guid]) do
			for activeIndex, activeData in pairs(UNIT_BOSS_MOD_AURAS_ACTIVE [guid] or {}) do
				if removeTexture == activeData.texture then
					tremove(UNIT_BOSS_MOD_AURAS_ACTIVE [guid], activeIndex)
				end
			end
		end

		UNIT_BOSS_MOD_AURAS_TO_BE_REMOVED [guid] = nil
	end

	local nextUpdateTime = nil
	local iconFrame = unitFrame.BossModIconFrame
	iconFrame:ClearIcons()

	if HOSTILE_ENABLED and UNIT_BOSS_MOD_AURAS_ACTIVE [guid] then
		for activeIndex, values in pairs(UNIT_BOSS_MOD_AURAS_ACTIVE [guid]) do
			if values.duration and values.duration > 0 and curTime > values.starttime + values.duration then
				tremove(UNIT_BOSS_MOD_AURAS_ACTIVE [guid], activeIndex)
			else
				local icon = iconFrame:SetIcon(-1, nil, values.duration and values.duration > 0 and values.starttime, values.duration, values.texture)
				--							spellId, borderColor, startTime, duration, forceTexture, descText, count, debuffType, caster, canStealOrPurge, spellName, isBuff
				icon.Texture:SetDesaturated(values.desaturate)
				--icon.Cooldown:SetDesaturated(values.desaturate)

				local endTime = values.duration and values.duration > 0 and (values.starttime + values.duration) or nil
				if not nextUpdateTime or (endTime and endTime < nextUpdateTime) then
					nextUpdateTime = endTime
				end

				--check if Masque is enabled on Plater and reskin the aura icon
				if (Plater.Masque and not icon.Masqued) then
					local t = {
						FloatingBG = nil, --false,
						Icon = icon.Texture,
						Cooldown = icon.Cooldown,
						Flash = nil, --false,
						Pushed = nil, --false,
						Normal = false,
						Disabled = nil, --false,
						Checked = nil, --false,
						Border = nil, --icon.Border,
						AutoCastable = nil, --false,
						Highlight = nil, --false,
						HotKey = nil, --false,
						Count = false,
						Name = nil, --false,
						Duration = false,
						Shine = nil, --false,
					}
					icon.Border:Hide() --let Masque handle the border...
					Plater.Masque.BossModIconFrame:AddButton (icon, t)
					Plater.Masque.BossModIconFrame:ReSkin()
					icon.Masqued = true
				end
			end
		end
	end

	--timer bars
	if Plater.db.profile.bossmod_support_bars_enabled and UNIT_BOSS_MOD_BARS [guid] then
		local sortedAuras = {}
		for id, data in pairs(UNIT_BOSS_MOD_BARS [guid]) do
			tinsert(sortedAuras, data)
		end
		table.sort(sortedAuras, function(a,b)
			if a.paused and not b.paused then
				return false
			elseif b.paused and not a.paused then
				return true
			else
				local at, bt = a.timer or 0, b.timer or 0
				local as, bs = a.start or 0, b.start or 0
				local ar = at - (curTime - (a.paused and (curTime - (a.pauseStartTime - a.start)) or as))
				local br = bt - (curTime - (b.paused and (curTime - (b.pauseStartTime - b.start)) or bs))
				return br > ar
			end
		end)
		--for id, data in pairs(UNIT_BOSS_MOD_BARS [guid]) do
		for _, data in pairs(sortedAuras) do
			local id = data.id
			local overTime = curTime > data.start + data.timer
			if not data.keep and data.timer and overTime then
				UNIT_BOSS_MOD_BARS [guid][id] = nil
			else
				local timer, start = data.timer, data.start
				if data.paused then
					start = curTime - (data.pauseStartTime - start) --offset for paused.
				end
				if overTime and data.keep then
					timer = nil
				end
				--print(timer, start, data.name, data.msg, data.colorId)
				local icon = iconFrame:SetIcon(-1, data.color, timer and start, timer, data.icon, {text = data.display, text_color = data.color})
				--							spellId, borderColor, startTime, duration, forceTexture, descText, count, debuffType, caster, canStealOrPurge, spellName, isBuff
				--DF:TruncateText(icon.Desc, Plater.db.profile.bossmod_aura_width)
				if data.paused then
					icon:SetScript("OnUpdate", nil)
					icon.Cooldown:Pause()
					icon.Texture:SetDesaturated(true)
				else
					--[[
					local curOnUpdate = iconFrame.OnIconTick --icon:GetScript("OnUpdate")
					icon:SetScript("OnUpdate", function(self)
						if self.timeRemaining <= 0 then
							UNIT_BOSS_MOD_NEEDS_UPDATE_IN[guid] = -1 -- fallback to remove icons that have run out
						end
						self.parentIconRow.OnIconTick(self) --curOnUpdate(self)
					end)
					]]
					icon.Texture:SetDesaturated(false)
				end

				local endTime = timer and (start + timer) or nil
				if not nextUpdateTime or (endTime and endTime < nextUpdateTime) then
					nextUpdateTime = endTime
				end

				--check if Masque is enabled on Plater and reskin the aura icon
				if (Plater.Masque and not icon.Masqued) then
					local t = {
						FloatingBG = nil, --false,
						Icon = icon.Texture,
						Cooldown = icon.Cooldown,
						Flash = nil, --false,
						Pushed = nil, --false,
						Normal = false,
						Disabled = nil, --false,
						Checked = nil, --false,
						Border = nil, --icon.Border,
						AutoCastable = nil, --false,
						Highlight = nil, --false,
						HotKey = nil, --false,
						Count = false,
						Name = nil, --false,
						Duration = false,
						Shine = nil, --false,
					}
					icon.Border:Hide() --let Masque handle the border...
					Plater.Masque.BossModIconFrame:AddButton (icon, t)
					Plater.Masque.BossModIconFrame:ReSkin()
					icon.Masqued = true
				end
			end
		end
	end

	UNIT_BOSS_MOD_NEEDS_UPDATE_IN[guid] = nextUpdateTime

	Plater.EndLogPerformanceCore("Plater-Core", "Update", "UpdateBossModAuras")

end

--callbacks
local function Callback_DBM_ShowAura(_, is_guid, unit, texture, duration, desaturate)
	local guid = (is_guid == true or is_guid == 'guid') and unit or UnitGUID(unit)
	ShowNameplateAura(guid, texture, duration, desaturate)
end

local function Callback_DBM_HideNameplateAura(_, is_guid, unit, texture)
	local guid = (is_guid == true or is_guid == 'guid') and unit or UnitGUID(unit)
	HideNameplateAura(guid, texture)
end

local function Callback_DBM_DisableHostile()
	DisableHostile()
end

local function Callback_DBM_EnableHostile()
	EnableHostile()
end


local function Callback_BW_ShowAura(guid, texture, duration, desaturate)
	ShowNameplateAura(guid, texture, duration, desaturate)
end

local function Callback_BW_HideNameplateAura(guid, texture)
	HideNameplateAura(guid, texture)
end

local function Callback_BW_DisableHostile()
	DisableHostile()
end

local function Callback_BW_EnableHostile()
	EnableHostile()
end


function Plater.RegisterBossModAuras()
	if IS_REGISTERED then return end

	if Plater.db.profile.bossmod_support_enabled then
		if DBM and DBM.RegisterCallback then
			DBM:RegisterCallback('BossMod_ShowNameplateAura',Callback_DBM_ShowAura)
			DBM:RegisterCallback('BossMod_HideNameplateAura',Callback_DBM_HideNameplateAura)
			DBM:RegisterCallback('BossMod_EnableHostileNameplates',Callback_DBM_EnableHostile)
			DBM:RegisterCallback('BossMod_DisableHostileNameplates',Callback_DBM_DisableHostile)
		end

		if BigWigsLoader and BigWigsLoader.RegisterMessage then
			--[[
			BigWigsLoader.RegisterMessage(Plater,'BigWigs_ShowNameplateAura',function(_,_,...)
				Callback_ShowAura(select(5,...),...)
			end)
			BigWigsLoader.RegisterMessage(Plater,'BigWigs_HideNameplateAura',function(_,_,...)
				Callback_HideNameplateAura(select(3,...),...)
			end)
			]]--
			BigWigsLoader.RegisterMessage(Plater,'BigWigs_AddNameplateIcon',Callback_BW_ShowAura)
			BigWigsLoader.RegisterMessage(Plater,'BigWigs_RemoveNameplateIcon', Callback_BW_HideNameplateAura)
			BigWigsLoader.RegisterMessage(Plater,'BigWigs_EnableHostileNameplates', Callback_BW_EnableHostile)
			BigWigsLoader.RegisterMessage(Plater,'BigWigs_DisableHostileNameplates', Callback_BW_DisableHostile)
		end
	end

	IS_REGISTERED = true
end


function Plater.GetBossModsEventTimeLeft(spell) -- more or less deprecated, need to know how to get this information from bigwigs
	if (_G.DBM) then
		for bar, _ in _G.DBM.Bars:GetBarIterator() do
			if (not bar.dead and bar.frame:IsShown()) then
				if (bar.id:find(spell)) then
					return bar.timer, bar.totalTime, bar.id, _G[bar.frame:GetName() .. "BarName"]:GetText()
				end
			end
		end
	end

	if (BigWigsLoader) then



	end
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> spell prediction

function Plater.GetAltCastBarAltId(plateFrame)
	--check if the nameplate is valid
	if (not plateFrame or not plateFrame.unitFrame) then
		return
	end
	return plateFrame.unitFrame.castBar2.altCastId
end

function Plater.ClearAltCastBar(plateFrame)
	--check if the nameplate is valid
	if (not plateFrame or not plateFrame.unitFrame) then
		return
	end
	local castBar2 = plateFrame.unitFrame.castBar2
	castBar2.altCastId = nil
	castBar2:Hide()
end

function Plater.SetAltCastBar(plateFrame, configTable, timer, startedAt, altCastId)

	--check if the nameplate is valid
	if (not plateFrame or not plateFrame.unitFrame) then
		return
	end

	local castBar = plateFrame.unitFrame.castBar2
	castBar.CastBarEvents = {}

	--> just update the current value since it wasn't running its tick function during the hide state
	--> everything else should be in the correct state
	castBar.OnShow = function (self)
		self.flashTexture:Hide()

		if (self.unit) then
			if (self.casting) then
				self.value = GetTime() - self.spellStartTime
				if self.value > self.maxValue then
					self:Hide()
					return
				end
				self:RunHooksForWidget ("OnShow", self, self.unit)

			elseif (self.channeling) then
				self.value = self.spellEndTime - GetTime()
				if self.value < 0 then
					self:Hide()
					return
				end
				self:RunHooksForWidget ("OnShow", self, self.unit)
			end
		end
	end

	--reset the castbar
	castBar.Icon:ClearAllPoints()
	castBar.Icon:SetPoint("right", castBar, "left", -1, 0)

	castBar:ClearAllPoints()
	castBar:SetPoint("topleft", plateFrame.unitFrame.castBar, "bottomleft", 0, -2)
	castBar:SetPoint("topright", plateFrame.unitFrame.castBar, "bottomright", 0, -2)

	castBar.percentText:ClearAllPoints()
	castBar.percentText:SetPoint ("right", castBar, "right", -2, 0)

	castBar.Text:ClearAllPoints()
	castBar.Text:SetPoint ("left", castBar, "left", 2, 0)


	--set the unit
	castBar:SetUnit(plateFrame.unitFrame.unit)
	castBar.altCastId = altCastId
	--set spell name
	castBar.Text:SetText(configTable.text)
	--set texture
	castBar.Icon:SetTexture(configTable.iconTexture or "")
	if (configTable.iconTexcoord) then
		castBar.Icon:SetTexCoord(unpack(configTable.iconTexcoord))
	else
		castBar.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	end

	castBar.Icon:SetAlpha(configTable.iconAlpha or 1)
	castBar.Icon:Show()

	castBar.percentText:Show()
	castBar:SetHeight(configTable.height or 12)

	if (configTable.iconSize) then
		castBar.Icon:SetSize(configTable.iconSize, configTable.iconSize)
	else
		castBar.Icon:SetSize(castBar:GetHeight(), castBar:GetHeight())
	end

	castBar.Spark:Show()

	if (configTable.spellNameAnchor) then
		Plater.SetAnchor(castBar.Text, configTable.spellNameAnchor)
	end

	if (configTable.timerAnchor) then
		Plater.SetAnchor(castBar.percentText, configTable.timerAnchor)
	end

	if (configTable.iconAnchor) then
		Plater.SetAnchor(castBar.Icon, configTable.iconAnchor)
	end

	DF:SetFontSize(castBar.Text, configTable.textSize or 10)
	DF:SetFontSize(castBar.percentText, configTable.textSize or 10)

	local startTime
	if (startedAt) then
		startTime = startedAt
	else
		startTime = GetTime()
	end

	local endTime = startTime + timer

	if (configTable.isChanneling) then
		castBar.casting = nil
		castBar.channeling = true
		castBar.spellStartTime = 	startTime
		castBar.spellEndTime = 		endTime
		castBar.SpellStartTime = 	startTime
		castBar.SpellEndTime = 		endTime
		castBar.value = endTime - GetTime()
		castBar.maxValue = endTime - startTime

		castBar:SetMinMaxValues(0, castBar.maxValue)
		castBar:SetValue(castBar.value)
	else
		castBar.casting = true
		castBar.channeling = nil
		castBar.spellStartTime = 	startTime
		castBar.spellEndTime = 		endTime
		castBar.SpellStartTime = 	startTime
		castBar.SpellEndTime = 		endTime
		castBar.value = GetTime() - startTime
		castBar.maxValue = endTime - startTime

		castBar:SetMinMaxValues(0, castBar.maxValue)
		castBar:SetValue(castBar.value)
	end

	castBar.finished = false
	castBar.canInterrupt = configTable.canInterrupt

	castBar:SetColor(configTable.color or "yellow")

	castBar.spellName = 		configTable.text
	castBar.spellID = 		1
	castBar.spellTexture = 		configTable.texture

	castBar.flashTexture:Hide()
	castBar:Animation_StopAllAnimations()

	Plater.CastBarOnEvent_Hook(castBar, "UNIT_SPELLCAST_START", plateFrame.unitFrame.unit, plateFrame.unitFrame.unit)

	if (not castBar:IsShown()) then
		castBar:Animation_FadeIn()
		castBar:Show()
	end
end

function Plater.StopAltCastBar(plateFrame)

	--check if the nameplate is valid
	if (not plateFrame or not plateFrame.unitFrame) then
		return
	end

	local castBar = plateFrame.unitFrame.castBar2

	castBar.CastBarEvents = {}
	castBar:SetUnit(nil)
	castBar.altCastId = nil

	castBar.Text:SetText("")

	if (castBar:IsShown()) then
		castBar:Animation_FadeOut()
		castBar:Hide()
	end
end

function TESTPlater()
    local plateFrame = C_NamePlate.GetNamePlateForUnit ("target")
    local config = {

        iconTexture = "Interface\\CHARACTERFRAME\\Button_BloodPresence_DeathKnight",
        --iconTexcoord = {0, 1, 0, 1},
        iconAlpha = 1,

        text = "Test Cast Bar",

        texture = "Interface\\CHARACTERFRAME\\UI-BarFill-Simple",
        color = "pink",

        isChanneling = false,
        canInterrupt = true,
    }

    local timer = 5

    Plater.SetAltCastBar(plateFrame, config, timer)
end

--SETTINGS
local prediction_time_to_show = 3

local triggerCastBar = function(timerObject)
	--get the bar timer id
	local timerId = timerObject.timerId
	local barInfo = Plater.BossModsTimeBar[timerId]

	--check if the bar still exists
	if (not barInfo) then
		--print("there no bar information for", timerId)
		return
	end

	local bar = DBM.Bars:GetBar(timerId)
	if (not bar) then
		--print("DBM returned nil for GetBar", timerId)
		return
	end

	--the nameplate to attach the cast bar
	local plateFrame

	if (timerObject.findUnitBySpellId) then
		--find the mob responsible for cast the ability
		plateFrame = C_NamePlate.GetNamePlateForUnit("target") --debug

	elseif (timerObject.attachToCurrentTarget) then
		plateFrame = C_NamePlate.GetNamePlateForUnit("target")
	end

	if (not plateFrame)  then
		return
	end

	--set the castbar config
	local config = {
		iconTexture = barInfo[5],
		iconTexcoord = {0.1, 0.9, 0.1, 0.9},
		iconAlpha = 1,

		text = barInfo[3],

		texture = [[Interface\AddOns\Plater\images\bar_background]],
		color = "silver",

		isChanneling = false,
		canInterrupt = false,

		height = Plater.db.profile.spell_prediction.castbar_height,
	}

	--show the cast bar
	Plater.SetAltCastBar(plateFrame, config, prediction_time_to_show)
	DF:TruncateText(plateFrame.unitFrame.castBar2.Text, plateFrame.unitFrame.castBar:GetWidth() - 28)
	DF:SetFontSize(plateFrame.unitFrame.castBar2.Text, 10)
end


function Plater.GetBossTimer(spellId)
	for id, barInfo in pairs (Plater.BossModsTimeBarDBM) do
		if  ((barInfo.spellId == spellId) or (type(id) == "string" and id:find(spellId))) then
			return DF.table.copy({}, barInfo)
		end
	end
	for id, barInfo in pairs (Plater.BossModsTimeBarBW) do
		if ((barInfo.spellId == spellId) or (id == spellId)) then
			return DF.table.copy({}, barInfo)
		end
	end
end

local function getDBTColor(colorId)
	if DBT and DBT.Options then
		local barOptions = DBT.Options
		local barStartRed, barStartGreen, barStartBlue
		if colorId and colorId >= 1 then
			if colorId == 1 then--Add
				barStartRed, barStartGreen, barStartBlue = barOptions.StartColorAR, barOptions.StartColorAG, barOptions.StartColorAB
			elseif colorId == 2 then--AOE
				barStartRed, barStartGreen, barStartBlue = barOptions.StartColorAER, barOptions.StartColorAEG, barOptions.StartColorAEB
			elseif colorId == 3 then--Debuff
				barStartRed, barStartGreen, barStartBlue = barOptions.StartColorDR, barOptions.StartColorDG, barOptions.StartColorDB
			elseif colorId == 4 then--Interrupt
				barStartRed, barStartGreen, barStartBlue = barOptions.StartColorIR, barOptions.StartColorIG, barOptions.StartColorIB
			elseif colorId == 5 then--Role
				barStartRed, barStartGreen, barStartBlue = barOptions.StartColorRR, barOptions.StartColorRG, barOptions.StartColorRB
			elseif colorId == 6 then--Phase
				barStartRed, barStartGreen, barStartBlue = barOptions.StartColorPR, barOptions.StartColorPG, barOptions.StartColorPB
			elseif colorId == 7 then--Important
				barStartRed, barStartGreen, barStartBlue = barOptions.StartColorUIR, barOptions.StartColorUIG, barOptions.StartColorUIB
			end
		else
			barStartRed, barStartGreen, barStartBlue = barOptions.StartColorR, barOptions.StartColorG, barOptions.StartColorB
		end

		return {barStartRed, barStartGreen, barStartBlue, 1}
	end

	return {1, 1, 1, 1}
end

function getAllShownGUIDs()
	local guids = {}
	for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
		if plateFrame.unitFrame.PlaterOnScreen then
			tinsert(guids, plateFrame.namePlateUnitGUID)
		end
	end
	return guids
end

function Plater.PauseBarIcon(name)
	if not name then return end
	local curTime = GetTime()
	
	for id,entry in pairs(Plater.BossModsTimeBarDBM) do
		if entry.msg == name then
			--print("yes", entry.paused, id)
			if not entry.paused then
				entry.paused = true
				entry.pauseStartTime = curTime
				--UNIT_BOSS_MOD_BARS [entry.guid][id].paused = true
				--UNIT_BOSS_MOD_BARS [entry.guid][id].pauseStartTime = curTime
			else
				entry.paused = false
				entry.start = entry.start + (curTime - entry.pauseStartTime)
				entry.pauseStartTime = entry.start
				--UNIT_BOSS_MOD_BARS [entry.guid][id].paused = false
				--UNIT_BOSS_MOD_BARS [entry.guid][id].start = entry.start + (curTime - entry.pauseStartTime)
				--UNIT_BOSS_MOD_BARS [entry.guid][id].pauseStartTime = entry.start
			end
			--print(name, entry.msg, entry.msg == name, entry.guid)
			UNIT_BOSS_MOD_NEEDS_UPDATE_IN[entry.guid] = -1
		end
	end
end
function Plater.UpdateBarIcon(name, elapsed, totalTime)
	if not name then return end
	local curTime = GetTime()
	
	for id,entry in pairs(Plater.BossModsTimeBarDBM) do
		if entry.msg == name then
			entry.timer = totalTime
			entry.start = curTime - elapsed
			if entry.paused then
				entry.pauseStartTime = curTime
			end
			
			--print(name, entry.msg, entry.msg == name, entry.guid)
			UNIT_BOSS_MOD_NEEDS_UPDATE_IN[entry.guid] = -1
		end
	end
end
function Plater.KeepBarIcon(name)
	if not name then return end
	
	for id,entry in pairs(Plater.BossModsTimeBarDBM) do
		if entry.msg == name then
			entry.keep = not entry.keep
			
			--print(name, entry.msg, entry.msg == name, entry.guid)
			UNIT_BOSS_MOD_NEEDS_UPDATE_IN[entry.guid] = -1
		end
	end
end


function Plater.RegisterBossModsBars()
	local DBM = _G.DBM
	local BigWigsLoader = _G.BigWigsLoader

	--check if Deadly Boss Mods is installed
	if (DBM) then
		--test mode start
		local testModeStartCallback = function(event, timer)
			if event ~= "DBM_TestModStarted" then return end
			DBM_TIMER_BARS_TEST_MODE = true
			C_Timer.After (tonumber(timer) or 10, function() DBM_TIMER_BARS_TEST_MODE = false end)
		end
		DBM:RegisterCallback("DBM_TestModStarted", testModeStartCallback)
		
		--timer start
		local timerStartCallback = function(event, id, msg, timer, icon, barType, spellId, colorId, modId, keep, fade, name, guid)
			if event ~= "DBM_TimerStart" then return end
			if (id and guid) then
				local color = getDBTColor(colorId)
				local display = DF:CleanTruncateUTF8String(strsub(string.match(name or msg or "", "^%s*(.-)%s*$" ), 1, Plater.db.profile.bossmod_support_bars_text_max_len or 7))
				--local display = string.match(name or msg or "", "^%s*(.-)%s*$" )
				local curTime =  GetTime()

				---@type dbmtimerbar
				local barData = {
					msg = msg,
					display = display or name or msg or "",
					id = id,
					timer =  timer,
					start = curTime,
					icon = icon,
					spellId = spellId,
					barType = barType,
					color = color,
					colorId = colorId,
					modId = modId,
					keep = keep,
					fade = fade,
					name = name,
					guid = guid,
					paused = false,
				}
				Plater.BossModsTimeBarDBM[id] = barData
				UNIT_BOSS_MOD_BARS [guid] = UNIT_BOSS_MOD_BARS [guid] or {}
				UNIT_BOSS_MOD_BARS [guid][id] = barData

				UNIT_BOSS_MOD_NEEDS_UPDATE_IN[guid] = -1
			elseif id and not guid and DBM_TIMER_BARS_TEST_MODE then
				for _, guid in pairs(getAllShownGUIDs()) do
					id = id .. guid
					local color = getDBTColor(colorId)
					local display = DF:CleanTruncateUTF8String(strsub(string.match(name or msg or "", "^%s*(.-)%s*$" ), 1, Plater.db.profile.bossmod_support_bars_text_max_len or 7))
					--local display = string.match(name or msg or "", "^%s*(.-)%s*$" )
					local curTime =  GetTime()

					---@type dbmtimerbar
					local barData = {
						msg = msg,
						display = display or name or msg or "",
						id = id,
						timer =  timer,
						start = curTime,
						icon = icon,
						spellId = spellId,
						barType = barType,
						color = color,
						colorId = colorId,
						modId = modId,
						keep = keep,
						fade = fade,
						name = name,
						guid = guid,
						paused = false,
					}
					Plater.BossModsTimeBarDBM[id] = barData
					UNIT_BOSS_MOD_BARS [guid] = UNIT_BOSS_MOD_BARS [guid] or {}
					UNIT_BOSS_MOD_BARS [guid][id] = barData

					UNIT_BOSS_MOD_NEEDS_UPDATE_IN[guid] = -1
				end
			end
		end
		DBM:RegisterCallback("DBM_TimerStart", timerStartCallback)

		local timerUpdateCallback = function(event, id, elapsed, totalTime)
			if event ~= "DBM_TimerUpdate" then return end
			
			if not id or not elapsed or not totalTime then return end
			local entry = id and Plater.BossModsTimeBarDBM[id] or nil
			local guid = entry and entry.guid
			local curTime = GetTime()
			if entry and guid then
				entry.timer = totalTime
				entry.start = curTime - elapsed
				if entry.paused then
					entry.pauseStartTime = curTime
				end

				UNIT_BOSS_MOD_NEEDS_UPDATE_IN[guid] = -1
			end
		end
		DBM:RegisterCallback("DBM_TimerUpdate", timerUpdateCallback)

		local timerPauseCallback = function(event, id)
			if event ~= "DBM_TimerPause" then return end
			
			if not id then return end
			local entry = id and Plater.BossModsTimeBarDBM[id] or nil
			local guid = entry and entry.guid
			if entry and guid then
				local curTime = GetTime()
				--entry.start = entry.start - (curTime - entry.start)
				entry.paused = true
				entry.pauseStartTime = curTime
				--UNIT_BOSS_MOD_BARS [guid][id].paused = true
				--UNIT_BOSS_MOD_BARS [guid][id].pauseStartTime = curTime

				UNIT_BOSS_MOD_NEEDS_UPDATE_IN[guid] = -1
			end
		end
		DBM:RegisterCallback("DBM_TimerPause", timerPauseCallback)

		local timerResumeCallback = function(event, id)
			if event ~= "DBM_TimerResume" then return end
			
			if not id then return end
			local entry = id and Plater.BossModsTimeBarDBM[id] or nil
			local guid = entry and entry.guid
			if entry and entry.paused and guid then
				entry.paused = false
				entry.start = entry.start + (GetTime() - entry.pauseStartTime)
				entry.pauseStartTime = entry.start
				--UNIT_BOSS_MOD_BARS [guid][id].paused = false
				--UNIT_BOSS_MOD_BARS [guid][id].start = entry.start + (GetTime() - entry.pauseStartTime)
				--UNIT_BOSS_MOD_BARS [guid][id].pauseStartTime = entry.start

				UNIT_BOSS_MOD_NEEDS_UPDATE_IN[guid] = -1
			end
		end
		DBM:RegisterCallback("DBM_TimerResume", timerResumeCallback)

		--timer stop
		local timerEndCallback = function (event, id)
			if event ~= "DBM_TimerStop" then return end
			
			if not id then return end
			local guid = Plater.BossModsTimeBarDBM[id] and Plater.BossModsTimeBarDBM[id].guid
			Plater.BossModsTimeBarDBM[id] = nil
			if guid then
				UNIT_BOSS_MOD_BARS [guid] = UNIT_BOSS_MOD_BARS [guid] or {}
				UNIT_BOSS_MOD_BARS [guid][id] = nil

				UNIT_BOSS_MOD_NEEDS_UPDATE_IN[guid] = -1
			elseif not guid and DBM_TIMER_BARS_TEST_MODE then
				for _, guid in pairs(getAllShownGUIDs()) do
					UNIT_BOSS_MOD_BARS [guid] = UNIT_BOSS_MOD_BARS [guid] or {}
					UNIT_BOSS_MOD_BARS [guid][id] = nil

					UNIT_BOSS_MOD_NEEDS_UPDATE_IN[guid] = -1
				end
			end
		end
		DBM:RegisterCallback("DBM_TimerStop", timerEndCallback)
	end

	--check if BigWigs is installed
	if (BigWigsLoader) then
		function Plater:BigWigs_BarCreated(...)
			local event, self, bar, module, key, text, time, icon, isApprox = ...
			if (event == "BigWigs_BarCreated") then
				if (key) then
					---@type bwtimerbar
					local barData = {
						msg = text,
						id = key,
						timer =  time,
						start = GetTime(),
						icon = icon,
						spellId = key,
						barType = bar,
						--color = {1,1,1,1},
						--colorId = colorId,
						modId = module,
						--keep = keep,
						--fade = fade,
						name = text,
						--guid = guid,
						paused = false,
					}
					Plater.BossModsTimeBarBW[key] = barData
				end
			end
		end

        if (BigWigsLoader.RegisterMessage) then
            BigWigsLoader.RegisterMessage (Plater, "BigWigs_BarCreated")
        end
	end
end

Plater.RegisterBossModsBars()