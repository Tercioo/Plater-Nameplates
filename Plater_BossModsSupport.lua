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
		show_text = true,
		text_size = Plater.db.profile.bossmod_cooldown_text_size or 16,
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