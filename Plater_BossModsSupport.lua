-- Bigwigs/DBM nameplate aura support
--[[

Options (defaults):
Plater.db.profile.bossmod_support_enabled = true
Plater.db.profile.bossmod_aura_height = 32
Plater.db.profile.bossmod_aura_width = 32
Plater.db.profile.bossmod_cooldown_text_size = 16
Plater.db.profile.bossmod_icons_anchor = {side = 8, x = 0, y = 40}
]]--

local DF = _G ["DetailsFramework"]
local Plater = _G.Plater
local C_Timer = _G.C_Timer
local C_NamePlate = _G.C_NamePlate

local UNIT_BOSS_MOD_AURAS_ACTIVE = {} --contains for each [GUID] a list of {texture, duration, desaturate}
local UNIT_BOSS_MOD_AURAS_TO_BE_REMOVED = {} --contains for each [GUID] a list of texture-ids to be removed
local HOSTILE_ENABLED = false
local IS_REGISTERED = false

-- core functions
local function ShowNameplateAura(guid, texture, duration, desaturate)
	--print("ShowNameplateAura", guid, texture, duration, desaturate)
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
end

local function HideNameplateAura(guid, texture)
	--print("HideNameplateAura", guid, texture)
	if not HOSTILE_ENABLED then return end
	if not guid or not texture then return end
	
	UNIT_BOSS_MOD_AURAS_TO_BE_REMOVED [guid] = UNIT_BOSS_MOD_AURAS_TO_BE_REMOVED [guid] or {}
	tinsert(UNIT_BOSS_MOD_AURAS_TO_BE_REMOVED [guid], texture)
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
	}
	unitFrame.BossModIconFrame = DF:CreateIconRow (unitFrame.healthBar, "$parentBossModIconRow", options)
	unitFrame.BossModIconFrame:ClearIcons()
	unitFrame.BossModIconFrame.RefreshID = 0
	
	Plater.SetAnchor (unitFrame.BossModIconFrame, Plater.db.profile.bossmod_icons_anchor or {side = 8, x = 0, y = 30})

end

function Plater.UpdateBossModAuraFrameSettings(unitFrame, refreshID)
	if (unitFrame.BossModIconFrame.RefreshID < refreshID) then
		Plater.SetAnchor (unitFrame.BossModIconFrame, Plater.db.profile.bossmod_icons_anchor)
		unitFrame.BossModIconFrame:SetOption ("text_size", Plater.db.profile.bossmod_cooldown_text_size)
		unitFrame.BossModIconFrame:SetOption ("icon_width", Plater.db.profile.bossmod_aura_width)
		unitFrame.BossModIconFrame:SetOption ("icon_height", Plater.db.profile.bossmod_aura_height)
		
		--> update refresh ID
		unitFrame.BossModIconFrame.RefreshID = refreshID
	end
end

function Plater.UpdateBossModAuras(unitFrame)

	local iconFrame = unitFrame.BossModIconFrame
	iconFrame:ClearIcons()
	
	if not HOSTILE_ENABLED then
		return
	end
	
	local guid = unitFrame.PlateFrame.namePlateUnitGUID
	local curTime = GetTime()

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
	
	if UNIT_BOSS_MOD_AURAS_ACTIVE [guid] then
		for activeIndex, values in pairs(UNIT_BOSS_MOD_AURAS_ACTIVE [guid]) do
			if values.duration and curTime > values.starttime + values.duration then
				tremove(UNIT_BOSS_MOD_AURAS_ACTIVE [guid], activeIndex)
			else
				local icon = iconFrame:SetIcon(nil, nil, values.duration and values.starttime, values.duration, values.texture)
				icon.Texture:SetDesaturated(values.desaturate)
				--icon.Cooldown:SetDesaturated(values.desaturate)
				
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
		if DBM then
			DBM:RegisterCallback('BossMod_ShowNameplateAura',Callback_DBM_ShowAura)
			DBM:RegisterCallback('BossMod_HideNameplateAura',Callback_DBM_HideNameplateAura)
			DBM:RegisterCallback('BossMod_EnableHostileNameplates',Callback_DBM_EnableHostile)
			DBM:RegisterCallback('BossMod_DisableHostileNameplates',Callback_DBM_DisableHostile)
		end
		
		if BigWigsLoader then
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


--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> spell prediction

function Plater.SetAltCastBar(plateFrame, configTable, timer)

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
	
	castBar:SetUnit(plateFrame.unitFrame.unit)

	castBar.Text:SetText(configTable.text)

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
	castBar.Icon:SetSize(castBar:GetHeight(), castBar:GetHeight())
	castBar.Spark:Show()

	local startTime = _G.GetTime()
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

--this table will store all bars created by the boss mods which is used by Plater
Plater.BossModsTimeBar = {}

--need to investigate
--there no bar information for Timer267409cd	Creature-0-3881-1861-3977-134635-00002F0387
--there no bar information for Timer272506cdcount	11
--there no bar information for Timer272506cdcount	9
--there no bar information for Timer263235cdcount	3

function Plater.InitializeSpellPrediction()
	local DBM = _G.DBM

	--check if Deadly Boss Mods are installed
	if (DBM) then
		local timerStartCallback = function (bar_type, id, msg, timer, icon, bartype, spellId, colorId, modid, arg1, arg2)

			--check if spell prediction is enabled
			if (not Plater.db.profile.spell_prediction.enabled) then
				return
			end

			local spellsDB = Plater.db.profile.captured_spells
			local spellInfoFromDB = spellsDB[spellId]

			--print("DBM:",bar_type, id, msg, timer, icon, bartype, spellId, colorId, modid)

			--check if Plater know this spell
			if (spellInfoFromDB) then
				--check if is the caster of this spell has a valid npcId
				local npcId = spellInfoFromDB.npcID
				if (npcId and npcId > 1) then
					Plater.BossModsTimeBar[id] = {bar_type, id, msg, timer, icon, bartype, spellId, colorId, modid, arg1, arg2}
					local newTimer = C_Timer.NewTimer(timer - prediction_time_to_show, triggerCastBar)
					newTimer.timerId = id
					newTimer.findUnitBySpellId = true
					--print("NewTimer:", 1)

				else
					--Plater know the spell but there's no npcId attached to it
					Plater.BossModsTimeBar[id] = {bar_type, id, msg, timer, icon, bartype, spellId, colorId, modid, arg1, arg2}
					local newTimer = C_Timer.NewTimer(timer - prediction_time_to_show, triggerCastBar)
					newTimer.timerId = id
					newTimer.attachToCurrentTarget = true
					--print("NewTimer:", 2)
				end
			
			else
				--Plater doesn't know the spell
				Plater.BossModsTimeBar[id] = {bar_type, id, msg, timer, icon, bartype, spellId, colorId, modid, arg1, arg2}
				local newTimer = C_Timer.NewTimer(timer - prediction_time_to_show, triggerCastBar)
				newTimer.timerId = id
				newTimer.attachToCurrentTarget = true
				--print("NewTimer:", 3)
			end

			--DB_CAPTURED_SPELLS [spellID] = {event = token, source = sourceName, npcID = Plater:GetNpcIdFromGuid (sourceGUID or ""), encounterID = Plater.CurrentEncounterID}
--			local spell = tostring (spellId)
--			if (spell and not current_table_dbm [spell]) then
--			current_table_dbm [spell] = {spell, id, msg, timer, icon, bartype, spellId, colorId, modid}
		end

		DBM:RegisterCallback ("DBM_TimerStart", timerStartCallback)

		--timer stop
		local timerEndCallback = function (bar_type, id)
			Plater.BossModsTimeBar[id] = nil
		end
		DBM:RegisterCallback ("DBM_TimerStop", timerEndCallback)
	end
end