local addonId, platerInternal = ...

local Plater = Plater
---@type detailsframework
local DF = DetailsFramework
local LibSharedMedia = LibStub:GetLibrary ("LibSharedMedia-3.0")
local LibRangeCheck = LibStub:GetLibrary ("LibRangeCheck-3.0")
local _

local IS_WOW_PROJECT_MAINLINE = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
local IS_WOW_PROJECT_NOT_MAINLINE = WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE
local IS_WOW_PROJECT_CLASSIC_ERA = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
local IS_WOW_PROJECT_CLASSIC_TBC = WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC
local IS_WOW_PROJECT_CLASSIC_WRATH = IS_WOW_PROJECT_NOT_MAINLINE and ClassicExpansionAtLeast and LE_EXPANSION_WRATH_OF_THE_LICH_KING and ClassicExpansionAtLeast(LE_EXPANSION_WRATH_OF_THE_LICH_KING)
--local IS_WOW_PROJECT_CLASSIC_CATACLYSM = IS_WOW_PROJECT_NOT_MAINLINE and ClassicExpansionAtLeast and LE_EXPANSION_CATACLYSM and ClassicExpansionAtLeast(LE_EXPANSION_CATACLYSM)

local PixelUtil = PixelUtil or DFPixelUtil

--templates
local options_text_template = DF:GetTemplate ("font", "OPTIONS_FONT_TEMPLATE")
local options_dropdown_template = DF:GetTemplate ("dropdown", "OPTIONS_DROPDOWN_TEMPLATE")
local options_switch_template = DF:GetTemplate ("switch", "OPTIONS_CHECKBOX_TEMPLATE")
local options_slider_template = DF:GetTemplate ("slider", "OPTIONS_SLIDER_TEMPLATE")
local options_button_template = DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE")

--configs
local startX, startY, heightSize = 10, platerInternal.optionsYStart, 755
local optionsWidth, optionsHeight = 1100, 670
local mainHeightSize = 820

local IMPORT_EXPORT_EDIT_MAX_BYTES = 0 --1024000*4 -- 0 appears to be "no limit"
local IMPORT_EXPORT_EDIT_MAX_LETTERS = 0 --128000*4 -- 0 appears to be "no limit"

local highlightColorLastCombat = {1, 1, .2, .25}

local dropdownStatusBarTexture = platerInternal.Defaults.dropdownStatusBarTexture
local dropdownStatusBarColor = platerInternal.Defaults.dropdownStatusBarColor

local CONST_DELAY_TO_CREATE_SPELLLISTTAB = 0.15

--when opening the options after an encounter, open at the tab "spell list", it shows the spells used on the encounter
local CONST_LASTEVENTS_TAB_INDEX = 19

 --cvars
local CVAR_ENABLED = "1"
local CVAR_DISABLED = "0"
local CVAR_RESOURCEONTARGET = "nameplateResourceOnTarget"
local CVAR_CULLINGDISTANCE = "nameplateMaxDistance"
local CVAR_AGGROFLASH = "ShowNamePlateLoseAggroFlash"
local CVAR_MOVEMENT_SPEED = "nameplateMotionSpeed"
local CVAR_MIN_ALPHA = "nameplateMinAlpha"
local CVAR_MIN_ALPHA_DIST = "nameplateMinAlphaDistance"
local CVAR_SHOWALL = "nameplateShowAll"
local CVAR_ENEMY_ALL = "nameplateShowEnemies"
local CVAR_ENEMY_MINIONS = "nameplateShowEnemyMinions"
local CVAR_ENEMY_MINUS = "nameplateShowEnemyMinus"
local CVAR_PLATEMOTION = "nameplateMotion"
local CVAR_FRIENDLY_ALL = "nameplateShowFriends"
local CVAR_FRIENDLY_GUARDIAN = "nameplateShowFriendlyGuardians"
local CVAR_FRIENDLY_PETS = "nameplateShowFriendlyPets"
local CVAR_FRIENDLY_TOTEMS = "nameplateShowFriendlyTotems"
local CVAR_FRIENDLY_MINIONS = "nameplateShowFriendlyMinions"
local CVAR_CLASSCOLOR = "ShowClassColorInNameplate"
local CVAR_SCALE_HORIZONTAL = "NamePlateHorizontalScale"
local CVAR_SCALE_VERTICAL = "NamePlateVerticalScale"

--members
local MEMBER_UNITID = "namePlateUnitToken"
local MEMBER_GUID = "namePlateUnitGUID"
local MEMBER_NPCID = "namePlateNpcId"
local MEMBER_QUEST = "namePlateIsQuestObjective"
local MEMBER_REACTION = "namePlateUnitReaction"
local MEMBER_ALPHA = "namePlateAlpha"
local MEMBER_RANGE = "namePlateInRange"
local MEMBER_NOCOMBAT = "namePlateNoCombat"
local MEMBER_NAME = "namePlateUnitName"
local MEMBER_NAMELOWER = "namePlateUnitNameLower"
local MEMBER_TARGET = "namePlateIsTarget"
local MEMBER_CLASSIFICATION = "namePlateClassification"

--actor types
local ACTORTYPE_FRIENDLY_PLAYER = "friendlyplayer"
local ACTORTYPE_FRIENDLY_NPC = "friendlynpc"
local ACTORTYPE_ENEMY_PLAYER = "enemyplayer"
local ACTORTYPE_ENEMY_NPC = "enemynpc"
local ACTORTYPE_PLAYER = "player"

--reaction
local UNITREACTION_HOSTILE = 3
local UNITREACTION_NEUTRAL = 4
local UNITREACTION_FRIENDLY = 5

local lower = string.lower
local GetSpellInfo = GetSpellInfo or function(spellID) if not spellID then return nil end local si = C_Spell.GetSpellInfo(spellID) if si then return si.name, nil, si.iconID, si.castTime, si.minRange, si.maxRange, si.spellID, si.originalIconID end end

--db upvalues
local DB_CAPTURED_SPELLS
local DB_CAPTURED_CASTS
local DB_NPCID_CACHE
local DB_NPCID_COLORS
local DB_AURA_ALPHA
local DB_AURA_ENABLED
local DB_AURA_SEPARATE_BUFFS

local on_refresh_db = function()
	local profile = Plater.db.profile
	DB_CAPTURED_SPELLS = PlaterDB.captured_spells
	DB_CAPTURED_CASTS = PlaterDB.captured_casts
	DB_NPCID_CACHE = profile.npc_cache
	DB_NPCID_COLORS = profile.npc_colors
	DB_AURA_ALPHA = profile.aura_alpha
	DB_AURA_ENABLED = profile.aura_enabled
	DB_AURA_SEPARATE_BUFFS = Plater.db.profile.buffs_on_aura2
end

Plater.RegisterRefreshDBCallback (on_refresh_db)

local update_wago_update_icons = function()
	local countMods, countScripts, hasProfileUpdate = Plater.CheckWagoUpdates(true)
	local mainFrame = PlaterOptionsPanelContainer
	local scriptButton		= mainFrame.AllButtons [6] --~changeindex1
	local modButton			= mainFrame.AllButtons [7]
	local profileButton		= mainFrame.AllButtons [22]
	
	if countMods > 0 then
		modButton.updateIcon:Show()
	else
		modButton.updateIcon:Hide()
	end
	
	if countScripts > 0 then
		scriptButton.updateIcon:Show()
	else
		scriptButton.updateIcon:Hide()
	end
	
	if hasProfileUpdate then
		profileButton.updateIcon:Show()
	else
		profileButton.updateIcon:Hide()
	end
end
Plater.UpdateOptionsTabUpdateState = update_wago_update_icons

--check if a encounter has just ended and open the aura ease tab
function Plater.CheckOptionsTab()
	if (Plater.LatestEncounter) then
		if (Plater.LatestEncounter + 60 > time()) then
			---@type df_tabcontainer
			local tabContainer = _G["PlaterOptionsPanelContainer"]
			C_Timer.After(CONST_DELAY_TO_CREATE_SPELLLISTTAB+0.050, function()
				tabContainer:SelectTabByIndex(CONST_LASTEVENTS_TAB_INDEX)
			end)
		end
	end
	update_wago_update_icons()
end

---@param profileName string
---@param profile table
---@param bIsUpdate boolean
---@param bKeepModsNotInUpdate boolean
---@param doNotReload boolean
function Plater.ImportAndSwitchProfile(profileName, profile, bIsUpdate, bKeepModsNotInUpdate, doNotReload)
	local bWasUsingUIParent = Plater.db.profile.use_ui_parent
	local scriptDataBackup = (bIsUpdate or bKeepModsNotInUpdate) and DF.table.copy({}, Plater.db.profile.script_data) or {}
	local hookDataBackup = (bIsUpdate or bKeepModsNotInUpdate) and DF.table.copy({}, Plater.db.profile.hook_data) or {}
	
	--switch to profile
	Plater.db:SetProfile(profileName)
	
	--cleanup profile -> reset to defaults
	Plater.db:ResetProfile(false, true)
	
	--import new profile settings
	DF.table.copy(Plater.db.profile, profile)
	
	--make the option reopen after the reload
	Plater.db.profile.reopoen_options_panel_on_tab = TAB_INDEX_PROFILES

	--check if parent to UIParent is enabled and calculate the new scale
	if (Plater.db.profile.use_ui_parent) then
		if (not bIsUpdate or not bWasUsingUIParent) then --only update if necessary
			Plater.db.profile.ui_parent_scale_tune = 1 / UIParent:GetEffectiveScale()
		end
	else
		Plater.db.profile.ui_parent_scale_tune = 0
	end
	
	if (bIsUpdate or bKeepModsNotInUpdate) then
		--copy user settings for mods/scripts and keep mods/scripts which are not part of the profile
		for index, oldScriptObject in ipairs(scriptDataBackup) do
			local scriptDB = Plater.db.profile.script_data or {}
			local bFound = false
			for i = 1, #scriptDB do
				local scriptObject = scriptDB[i]
				if (scriptObject.Name == oldScriptObject.Name) then
					if (bIsUpdate) then
						Plater.UpdateOptionsForModScriptImport(scriptObject, oldScriptObject)
					end

					bFound = true
					break
				end
			end

			if (not bFound and bKeepModsNotInUpdate) then
				table.insert(scriptDB, oldScriptObject)
			end
		end
		
		for index, oldScriptObject in ipairs(hookDataBackup) do
			local scriptDB = Plater.db.profile.hook_data or {}
			local bFound = false
			for i = 1, #scriptDB do
				local scriptObject = scriptDB[i]
				if (scriptObject.Name == oldScriptObject.Name) then
					if (bIsUpdate) then
						Plater.UpdateOptionsForModScriptImport(scriptObject, oldScriptObject)
					end

					bFound = true
					break
				end
			end

			if (not bFound and bKeepModsNotInUpdate) then
				table.insert(scriptDB, oldScriptObject)
			end
		end
	end
	
	--cleanup NPC cache/colors
	---@type table<number, string[]> [1] npcname [2] zonename [3] language
	local cache = Plater.db.profile.npc_cache

	local cacheTemp = DetailsFramework.table.copy({}, cache)
	for npcId, npcData in pairs(cacheTemp) do
		---@cast npcData table{key1: string, key2: string, key3: string|nil}
		if (tonumber(npcId)) then
			cache[npcId] = nil
			cache[tonumber(npcId)] = npcData 
		end
	end
	
	--cleanup npc colors
	---@type npccolordb
	local colors = Plater.db.profile.npc_colors
	---@type npccolordb
	local colorsTemp = DetailsFramework.table.copy({}, colors)

	---@type number, npccolortable
	for npcId, npcColorTable in pairs(colorsTemp) do
		if tonumber(npcId) then 
			colors[npcId] = nil
			colors[tonumber(npcId)] = npcColorTable 
		end
	end
	
	--cleanup cast colors/sounds
	---@type castcolordb
	local castColors = Plater.db.profile.cast_colors
	---@type castcolordb
	local castColorsTemp = DetailsFramework.table.copy({}, castColors)

	---@type number, castcolortable
	for spellId, castColorTable in pairs(castColorsTemp) do
		if tonumber(spellId) then 
			castColors[spellId] = nil
			castColors[tonumber(spellId)] = castColorTable 
		end
	end
	
	---@type renamednpcsdb
	local renamedNPCs = Plater.db.profile.npcs_renamed
	---@type renamednpcsdb
	local renamedNPCsTemp = DetailsFramework.table.copy({}, renamedNPCs)
	
	for npcId, renamedName in pairs(renamedNPCsTemp) do
		if tonumber(npcId) then 
			renamedNPCs[npcId] = nil
			renamedNPCs[tonumber(npcId)] = renamedName 
		end
	end
	
	---@type audiocuedb
	local audioCues = Plater.db.profile.cast_audiocues
	---@type audiocuedb
	local audioCuesTemp = DetailsFramework.table.copy({}, audioCues)

	for spellId, audioCuePath in pairs(audioCuesTemp) do
		if tonumber(spellId) then 
			audioCues[spellId] = nil
			audioCues[tonumber(spellId)] = audioCuePath 
		end
	end
	
	---@type ghostauras
	local ghostAuras = Plater.db.profile.ghost_auras.auras
	---@type ghostauras
	local ghostAurasTemp = DetailsFramework.table.copy({}, ghostAuras)
	local ghostAurasDefault = PLATER_DEFAULT_SETTINGS.profile.ghost_auras.auras
	--cleanup is needed for proper number indexing. will remove crap as well.
	for class, specs in pairs(ghostAurasTemp) do
		for specID, specData in pairs(specs) do
			ghostAuras[class][specID] = nil
			if ghostAurasDefault[class][tonumber(specID)] then
				ghostAuras[class][tonumber(specID)] = ghostAuras[class][tonumber(specID)] or {}
				for spellId, enabled in pairs(specData) do
					if tonumber(spellId) then
						ghostAuras[class][tonumber(specID)][tonumber(spellId)] = enabled 
					end
				end
			end
		end
	end
	
	-- cleanup captured_spells
	for spellId, data in pairs(Plater.db.profile.captured_spells) do
		DB_CAPTURED_SPELLS[spellId] = DB_CAPTURED_SPELLS[spellId] or data --retain original
	end
	Plater.db.profile.captured_spells = nil --this does belong into PlaterDB
	-- cleanup captured_casts
	for spellId, data in pairs(Plater.db.profile.captured_casts) do
		DB_CAPTURED_CASTS[spellId] = DB_CAPTURED_CASTS[spellId] or data --retain original
	end
	Plater.db.profile.captured_casts = nil --this does belong into PlaterDB
	
	--restore CVars of the profile
	Plater.RestoreProfileCVars()
	
	--automatically reload the user UI unless explicitly posponed (external importer, for example)
	if not doNotReload then
		ReloadUI()
	end
end

local TAB_INDEX_UIPARENTING = 5
local TAB_INDEX_PROFILES = 22

local bIsOptionsPanelFullyLoaded = false

-- ~options �ptions
function Plater.OpenOptionsPanel(pageNumber, bIgnoreLazyLoad)
	platerInternal.OpenOptionspanelAfterCombat = nil
	
	--__benchmark() --~perf

	--localization
	local L = DF.Language.GetLanguageTable(addonId)

	if (PlaterOptionsPanelFrame) then
		PlaterOptionsPanelFrame:Show()
		Plater.CheckOptionsTab()

		if (pageNumber) then
			if (not bIsOptionsPanelFullyLoaded and not bIgnoreLazyLoad) then
				C_Timer.After(1.5, function()
					---@type df_tabcontainer
					local tabContainer = _G["PlaterOptionsPanelContainer"]
					tabContainer:SelectTabByIndex(pageNumber)
				end)
			else
				---@type df_tabcontainer
				local tabContainer = _G["PlaterOptionsPanelContainer"]
				tabContainer:SelectTabByIndex(pageNumber)
			end
		end

		return true
	end
	
	if (InCombatLockdown() and not Plater.IsInOpenWorld()) then
		Plater:Msg ("Optionspanel not loaded and cannot open during combat. It will open automatically after combat ends.")
		platerInternal.OpenOptionspanelAfterCombat = {pageNumber, bIgnoreLazyLoad}
		return
	end

	if (pageNumber) then
		C_Timer.After(0, function()
			---@type df_tabcontainer
			local tabContainer = _G["PlaterOptionsPanelContainer"]
			tabContainer:SelectTabByIndex(pageNumber)
		end)
	end	
	
	Plater.db.profile.OptionsPanelDB = Plater.db.profile.OptionsPanelDB or {}
	
	C_Timer.After(2, function() bIsOptionsPanelFullyLoaded = true end)
	
	--build the main frame
	local f = DF:CreateSimplePanel (UIParent, optionsWidth, optionsHeight, "Plater |cFFFF8822[|r|cFFFFFFFFNameplates|r|cFFFF8822]|r: professional addon for hardcore gamers", "PlaterOptionsPanelFrame", {UseScaleBar = true}, Plater.db.profile.OptionsPanelDB)
	f.Title:SetAlpha(.75)
	f:SetFrameStrata("DIALOG")
	f:SetToplevel(true)
	DF:ApplyStandardBackdrop(f)
	f:ClearAllPoints()
	PixelUtil.SetPoint(f, "center", UIParent, "center", 2, 2, 1, 1)

	--over the top frame
	local OTTFrame = CreateFrame("frame", "PlaterNameplatesOverTheTopFrame", f)
	OTTFrame:SetFrameLevel(2000)
	OTTFrame:SetSize(1, 1)
	OTTFrame:SetPoint("topright", f, "topright", -22, -110)

	f:HookScript("OnShow", function()
		OTTFrame:Show()
	end)
	f:HookScript("OnHide", function()
		OTTFrame:Hide()
	end)

	-- version text
	local versionText = DF:CreateLabel (f, Plater.fullVersionInfo, 11, "white")
	versionText:SetPoint ("topright", f, "topright", -25, -7)
	versionText:SetAlpha(0.75)

	local profile = Plater.db.profile
	
	--local CVarDesc = "\n\n|cFFFF7700[*]|r |cFFa0a0a0CVar, not saved within Plater profile and is a Per-Character setting.|r"
	local CVarDesc = "\n\n|cFFFF7700[*]|r |cFFa0a0a0CVar, saved within Plater profile and restored when loading the profile.|r"
	local CVarIcon = "|cFFFF7700*|r"
	local CVarNeedReload = "\n\n|cFFFF2200[*]|r |cFFa0a0a0A /reload may be required to take effect.|r"
	local ImportantText = "|cFFFFFF00 Important |r: "
	local SliderRightClickDesc = "\n\n" .. ImportantText .. "right click to type the value."
	
	local hookList = {
		---@param tabContainer df_tabcontainer
		---@param tabButton df_tabcontainerbutton
		OnSelectIndex = function(tabContainer, tabButton)
			if (not tabButton.leftSelectionIndicator) then
				return
			end

			for index, frame in ipairs(tabContainer.AllFrames) do
				local tabButton = tabContainer.AllButtons[index]
				tabButton.leftSelectionIndicator:SetColorTexture(.4, .4, .4)
			end

			tabButton.leftSelectionIndicator:SetColorTexture(1, 1, 0)
			tabButton.selectedUnderlineGlow:Hide()
		end,
	}

	local frame_options = {
		y_offset = 0,
		button_width = 108,
		button_height = 23,
		button_x = 190,
		button_y = 1,
		button_text_size = 10,
		right_click_y = 5,
		rightbutton_always_close = true,
		close_text_alpha = 0.4,
		container_width_offset = 30,
	}

	local languageInfo = {
		language_addonId = addonId,
	}

	-- mainFrame � um frame vazio para sustentrar todos os demais frames, este frame sempre ser� mostrado
	local mainFrame = DF:CreateTabContainer (f, "Plater Options", "PlaterOptionsPanelContainer", 
	{
		--when chaging these indexes also need to change the function f.CopySettings
		{name = "FrontPage",				text = "OPTIONS_TABNAME_GENERALSETTINGS"},
		{name = "ThreatConfig",				text = "OPTIONS_TABNAME_THREAT"},
		{name = "TargetConfig",				text = "OPTIONS_TABNAME_TARGET"},
		{name = "CastBarConfig",			text = "OPTIONS_TABNAME_CASTBAR", createOnDemandFunc = platerInternal.CreateCastBarOptions},
		{name = "LevelStrataConfig",		text = "OPTIONS_TABNAME_STRATA"},
		{name = "Scripting",				text = "OPTIONS_TABNAME_SCRIPTING"},
		{name = "AutoRunCode",				text = "OPTIONS_TABNAME_MODDING"},
		{name = "PersonalBar",				text = "OPTIONS_TABNAME_PERSONAL"},
		
		{name = "DebuffConfig",				text = "OPTIONS_TABNAME_BUFF_SETTINGS"},
		{name = "DebuffBlacklist",			text = "OPTIONS_TABNAME_BUFF_TRACKING"},
		{name = "DebuffSpecialContainer",	text = "OPTIONS_TABNAME_BUFF_SPECIAL"},
		{name = "GhostAurasFrame",			text = "Ghost Auras"}, --localize-me
		{name = "EnemyNpc",					text = "OPTIONS_TABNAME_NPCENEMY"},
		{name = "EnemyPlayer",				text = "OPTIONS_TABNAME_PLAYERENEMY"},
		{name = "FriendlyNpc",				text = "OPTIONS_TABNAME_NPCFRIENDLY"},
		{name = "FriendlyPlayer",			text = "OPTIONS_TABNAME_PLAYERFRIENDLY"},

		{name = "ColorManagement",			text = "OPTIONS_TABNAME_NPC_COLORNAME"},
		{name = "CastColorManagement",		text = "OPTIONS_TABNAME_CASTCOLORS"},
		{name = "DebuffLastEvent",			text = "OPTIONS_TABNAME_BUFF_LIST"},
		{name = "AnimationPanel",			text = "OPTIONS_TABNAME_ANIMATIONS"},
		{name = "Automation",				text = "OPTIONS_TABNAME_AUTO"},
		{name = "ProfileManagement",		text = "OPTIONS_TABNAME_PROFILES"},
		{name = "AdvancedConfig",			text = "OPTIONS_TABNAME_ADVANCED", createOnDemandFunc = platerInternal.CreateAdvancedOptions},
		{name = "resourceFrame",			text = "OPTIONS_TABNAME_COMBOPOINTS"},

		{name = "WagoIo", text = "Wago Imports"}, --wago_imports --localize-me
		{name = "SearchFrame", text = "OPTIONS_TABNAME_SEARCH", createOnDemandFunc = platerInternal.CreateSearchOptions},
		{name = "PluginsFrame", text = "Plugins"}, --localize-me
		
	}, 
	frame_options, hookList, languageInfo)

	mainFrame:SetAllPoints()

	--> when any setting is changed, call this function
	local globalCallback = function()
		Plater.IncreaseRefreshID()
		Plater.RefreshDBUpvalues()
		Plater.UpdateAllPlates()

		--trigger the event "Options Changed" for mods
		platerInternal.OnOptionChanged()
	end

	--export the function to other files
	platerInternal.OptionsGlobalCallback = globalCallback

	--make the tab button's text be aligned to left and fit the button's area
	for index, frame in ipairs(mainFrame.AllFrames) do
		--DF:ApplyStandardBackdrop(frame)
		local frameBackgroundTexture = frame:CreateTexture(nil, "artwork")
		frameBackgroundTexture:SetPoint("topleft", frame, "topleft", 1, -140)
		frameBackgroundTexture:SetPoint("bottomright", frame, "bottomright", -1, 20)
		frameBackgroundTexture:SetColorTexture (0.2317647, 0.2317647, 0.2317647)
		frameBackgroundTexture:SetVertexColor (0.27, 0.27, 0.27)
		frameBackgroundTexture:SetAlpha (0.3)
		--frameBackgroundTexture:Hide()

		--divisor shown above the background (create above)
		local frameBackgroundTextureTopLine = frame:CreateTexture(nil, "artwork")
		frameBackgroundTextureTopLine:SetPoint("bottomleft", frameBackgroundTexture, "topleft", 0, 0)
		frameBackgroundTextureTopLine:SetPoint("bottomright", frame, "topright", -1, 0)
		frameBackgroundTextureTopLine:SetHeight(1)
		frameBackgroundTextureTopLine:SetColorTexture(0.1215, 0.1176, 0.1294)
		frameBackgroundTextureTopLine:SetAlpha(1)

		frame.titleText.fontsize = 12

		local gradientBelowTheLine = DF:CreateTexture(frame, {gradient = "vertical", fromColor = "transparent", toColor = DF.IsDragonflight() and {0, 0, 0, 0.15} or {0, 0, 0, 0.25}}, 1, 100, "artwork", {0, 1, 0, 1}, "gradientBelowTheLine")
		gradientBelowTheLine:SetPoint("top-bottom", frameBackgroundTextureTopLine)

		local gradientAboveTheLine = DF:CreateTexture(frame, {gradient = "vertical", fromColor = DF.IsDragonflight() and {0, 0, 0, 0.3} or {0, 0, 0, 0.4}, toColor = "transparent"}, 1, 80, "artwork", {0, 1, 0, 1}, "gradientAboveTheLine")
		gradientAboveTheLine:SetPoint("bottom-top", frameBackgroundTextureTopLine)

		local tabButton = mainFrame.AllButtons[index]

		local leftSelectionIndicator = tabButton:CreateTexture(nil, "overlay")

		if (index == 1) then
			leftSelectionIndicator:SetColorTexture(1, 1, 0)
		else
			leftSelectionIndicator:SetColorTexture(.4, .4, .4)
		end
		leftSelectionIndicator:SetPoint("left", tabButton.widget, "left", 2, 0)
		leftSelectionIndicator:SetSize(4, tabButton:GetHeight()-4)
		tabButton.leftSelectionIndicator = leftSelectionIndicator

		local maxTextLength = tabButton:GetWidth() - 7

		local fontString = _G[tabButton:GetName() .. "_Text"]
		fontString:ClearAllPoints()
		fontString:SetPoint("left", leftSelectionIndicator, "right", 2, 0)
		fontString:SetJustifyH("left")
		fontString:SetWidth(maxTextLength)
		fontString:SetHeight(tabButton:GetHeight()+20)
		fontString:SetWordWrap(true)
		fontString:SetText(fontString:GetText())

		local stringWidth = fontString:GetStringWidth()

		--print(stringWidth, maxTextLength, fontString:GetText())

		if (stringWidth > maxTextLength) then
			local fontSize = DF:GetFontSize(fontString)
			DF:SetFontSize(fontString, fontSize-0.5)
		end
	end

	--1st row
	local frontPageFrame		= mainFrame.AllFrames [1]
	local threatFrame			= mainFrame.AllFrames [2]
	local targetFrame			= mainFrame.AllFrames [3]
	local castBarFrame			= mainFrame.AllFrames [4]--; print(castBarFrame:GetName())
	local uiParentFeatureFrame	= mainFrame.AllFrames [5]
	local scriptingFrame		= mainFrame.AllFrames [6]
	local runCodeFrame			= mainFrame.AllFrames [7]
	local personalPlayerFrame	= mainFrame.AllFrames [8]
	
	--2nd row
	local auraOptionsFrame		= mainFrame.AllFrames [9]
	local auraFilterFrame		= mainFrame.AllFrames [10]
	local auraSpecialFrame		= mainFrame.AllFrames [11]
	local ghostAuras			= mainFrame.AllFrames [12]
	local enemyNPCsFrame		= mainFrame.AllFrames [13]
	local enemyPCsFrame			= mainFrame.AllFrames [14]
	local friendlyNPCsFrame		= mainFrame.AllFrames [15]
	local friendlyPCsFrame		= mainFrame.AllFrames [16]
	
	--3rd row
	local npcColorsFrame			= mainFrame.AllFrames [17]; platerInternal.NpcColorsFrameIndex = 17; platerInternal.NpcColorsCreationDelay = 0.08;
	local castColorsFrame		= mainFrame.AllFrames [18]; platerInternal.CastColorsFrameIndex = 18; platerInternal.CastColorsCreationDelay = 0.1;
	local auraLastEventFrame	= mainFrame.AllFrames [19]; platerInternal.AuraLastFrameIndex = 19; platerInternal.AuraLastCreationDelay = 0.02;
	local animationFrame		= mainFrame.AllFrames [20] --when this index is changed, need to also change the index on Plater_AnimationEditor.lua
	local autoFrame				= mainFrame.AllFrames [21]
	local profilesFrame			= mainFrame.AllFrames [22]
	local advancedFrame			= mainFrame.AllFrames [23]
	local resourceFrame			= mainFrame.AllFrames [24]

	--4th row
	local wagoIoFrame 			= mainFrame.AllFrames [25] --wago_imports
	local searchFrame			= mainFrame.AllFrames [26]
	local pluginsFrame			= mainFrame.AllFrames [27]

	local scriptButton		= mainFrame.AllButtons [6] --also need update on ~changeindex1 and ~changeindex2
	local modButton		 	= mainFrame.AllButtons [7]
	local profileButton		= mainFrame.AllButtons [22]
	local ghostAurasButton	= mainFrame.AllButtons [12]

	--[=[ ghost auras isn't new anymore, keeping this code in case need to add the button into another tab
	if (time() + 60*60*24*15 > 1647542962) then
		ghostAuras.newTexture = ghostAurasButton:CreateTexture(nil, "overlay", nil, 7)
		ghostAuras.newTexture:SetTexture([[Interface\AddOns\Plater\images\new]])
		ghostAuras.newTexture:SetPoint("right", ghostAurasButton.widget, "right", 4, -9)
		ghostAuras.newTexture:SetSize(35, 35)
		ghostAuras.newTexture:SetAlpha(0.88)
	end
	--]=]

	C_Timer.After(0.1, function() Plater.Resources.BuildResourceOptionsTab(resourceFrame) end)
	C_Timer.After(0.1, function() Plater.Auras.BuildGhostAurasOptionsTab(ghostAuras) end)
	C_Timer.After(platerInternal.CastColorsCreationDelay, function() Plater.CreateCastColorOptionsFrame(castColorsFrame) end)
	--C_Timer.After(platerInternal.NpcColorsCreationDelay, function() Plater.CreateNpcColorOptionsFrame(npcColorsFrame) end)

	C_Timer.After(CONST_DELAY_TO_CREATE_SPELLLISTTAB, function() 
		Plater.CreateAuraLastEventOptionsFrame(auraLastEventFrame)
	end)

	C_Timer.After(0.20, function() 
		Plater.CreateNpcColorOptionsFrame(npcColorsFrame)
	end)

	C_Timer.After(0.1, function() platerInternal.Plugins.CreatePluginsOptionsTab(pluginsFrame) end)
	local generalOptionsAnchor = CreateFrame ("frame", "$parentOptionsAnchor", frontPageFrame, BackdropTemplateMixin and "BackdropTemplate")
	generalOptionsAnchor:SetSize (1, 1)
	generalOptionsAnchor:SetPoint ("topleft", frontPageFrame, "topleft", startX, startY)
	
	local statusBar = CreateFrame ("frame", "$parentStatusBar", f, BackdropTemplateMixin and "BackdropTemplate")
	statusBar:SetPoint ("bottomleft", f, "bottomleft")
	statusBar:SetPoint ("bottomright", f, "bottomright")
	statusBar:SetHeight (20)
	DF:ApplyStandardBackdrop (statusBar)
	statusBar:SetAlpha (0.9)
	statusBar:SetFrameLevel (f:GetFrameLevel()+10)
	
	DF:BuildStatusbarAuthorInfo (statusBar, "Plater is Maintained by ", "Cont1nuity & Terciob")
	
	--if (DF.IsDragonflight()) then
	local bottomGradient = DF:CreateTexture(f, {gradient = "vertical", fromColor = {0, 0, 0, 0.6}, toColor = "transparent"}, 1, 100, "artwork", {0, 1, 0, 1}, "bottomGradient")
	bottomGradient:SetPoint("bottom-top", statusBar)
	--end

	--wago.io support
	local wagoDesc = DF:CreateLabel (statusBar, L["OPTIONS_STATUSBAR_TEXT"])
	wagoDesc.textcolor = "white"
	wagoDesc.textsize = 11
	wagoDesc:SetPoint ("left", statusBar.DiscordTextBox, "right", 10, 0)
	
	wagoDesc.Anim = DF:CreateAnimationHub (wagoDesc)
	wagoDesc.Anim:SetLooping ("repeat")
	DF:CreateAnimation (wagoDesc.Anim, "alpha", 1, 1, .3, .7)
	DF:CreateAnimation (wagoDesc.Anim, "alpha", 2, 1, 1, .3)
	--wagoDesc.Anim:Play()
	
	local updateIconScripts = scriptButton.button:CreateTexture ("$parentIcon", "overlay")
	updateIconScripts:SetSize (16, 10)
	updateIconScripts:SetTexture([[Interface\AddOns\Plater\images\wagologo.tga]])
	updateIconScripts:SetPoint("bottomright", scriptButton.button, "bottomright", -2, 2)
	updateIconScripts:Hide()
	scriptButton.updateIcon = updateIconScripts
	
	local updateIconMods = modButton.button:CreateTexture ("$parentIcon", "overlay")
	updateIconMods:SetSize (16, 10)
	updateIconMods:SetTexture([[Interface\AddOns\Plater\images\wagologo.tga]])
	updateIconMods:SetPoint("bottomright", modButton.button, "bottomright", -2, 2)
	updateIconMods:Hide()
	modButton.updateIcon = updateIconMods
	
	local updateIconProfile = profileButton.button:CreateTexture ("$parentIcon", "overlay")
	updateIconProfile:SetSize (16, 10)
	updateIconProfile:SetTexture([[Interface\AddOns\Plater\images\wagologo.tga]])
	updateIconProfile:SetPoint("bottomright", profileButton.button, "bottomright", -2, 2)
	updateIconProfile:Hide()
	profileButton.updateIcon = updateIconProfile
	
	f.AllMenuFrames = {}
	for _, frame in ipairs (mainFrame.AllFrames) do
		tinsert (f.AllMenuFrames, frame)
	end
	tinsert (f.AllMenuFrames, generalOptionsAnchor)

	--~languages
		---executed when the user selects a language in the dropdown
		---@param languageId string
		local onLanguageChangedCallback = function(languageId)
			PlaterLanguage.language = languageId
		end

		---@type string
		local currentLanguage = PlaterLanguage.language

		--addonId, parent, callback, defaultLanguage
		local languageSelectorDropdown = DF.Language.CreateLanguageSelector(addonId, OTTFrame, onLanguageChangedCallback, currentLanguage)
		languageSelectorDropdown:SetPoint("topright", 0, 0)
	--end of languages

	--> on profile change
	function f.RefreshOptionsFrame()
		for _, frame in ipairs (f.AllMenuFrames) do
			if (frame.RefreshOptions) then
				frame:RefreshOptions()
			end
		end
		Plater.UpdateMaxCastbarTextLength()
	end
	
	function f.CopySettingsConfirmed()
		DF.table.copy (Plater.db.profile.plate_config [f.CopyingTo], Plater.db.profile.plate_config [f.CopyingFrom])
		PlaterOptionsPanelFrame.RefreshOptionsFrame()
		Plater:Msg (L["OPTIONS_SETTINGS_COPIED"])
	end
	
	--> copy settings from one actor type to another
	function f.CopySettings (_, _, from)
		local currentTab = mainFrame.CurrentIndex
		local settingsTo
		if (currentTab == 8) then
			settingsTo = "player"
		elseif (currentTab == 13) then
			settingsTo = "enemynpc"
		elseif (currentTab == 14) then
			settingsTo = "enemyplayer"
		elseif (currentTab == 15) then
			settingsTo = "friendlynpc"
		elseif (currentTab == 16) then
			settingsTo = "friendlyplayer"
		end
		
		if (settingsTo) then
			f.CopyingFrom = from
			f.CopyingTo = settingsTo
			DF:ShowPromptPanel ("Copy setting from '" .. from .. "' to '" .. settingsTo .. "' ?", f.CopySettingsConfirmed, function() f.CopyingFrom = nil; f.CopyingTo = nil; end)
		else
			Plater:Msg (L["OPTIONS_SETTINGS_FAIL_COPIED"])
		end
	end
	
	local copy_settings_options = {
		{label = L["OPTIONS_TABNAME_PERSONAL"], value = "player", onclick = f.CopySettings},
		{label = L["OPTIONS_TABNAME_NPCENEMY"], value = "enemynpc", onclick = f.CopySettings},
		{label = L["OPTIONS_TABNAME_PLAYERENEMY"], value = "enemyplayer", onclick = f.CopySettings},
		{label = L["OPTIONS_TABNAME_NPCFRIENDLY"], value = "friendlynpc", onclick = f.CopySettings},
		{label = L["OPTIONS_TABNAME_PLAYERFRIENDLY"], value = "friendlyplayer", onclick = f.CopySettings},
	}

	
------------------------------------------------------------------------------------------------------------
--> profile frame ~profile
	
	do
	
		--logic
			--when the user click to export the current profile
			function profilesFrame.ExportCurrentProfile()
				profilesFrame.IsExporting = true
				profilesFrame.IsImporting = nil
				profilesFrame.ImportStringField.importDataText = nil
				
				local editbox = profilesFrame.ImportStringField.editbox
				editbox:SetMaxBytes (IMPORT_EXPORT_EDIT_MAX_BYTES)
				editbox:SetScript("OnChar", nil);
				
				if (not profilesFrame.ImportingProfileAlert) then
					profilesFrame.ImportingProfileAlert = CreateFrame ("frame", "PlaterExportingProfileAlert", UIParent, BackdropTemplateMixin and "BackdropTemplate")
					profilesFrame.ImportingProfileAlert:SetSize (340, 75)
					profilesFrame.ImportingProfileAlert:SetPoint ("center")
					profilesFrame.ImportingProfileAlert:SetFrameStrata ("TOOLTIP")
					DF:ApplyStandardBackdrop (profilesFrame.ImportingProfileAlert)
					profilesFrame.ImportingProfileAlert:SetBackdropBorderColor (1, 0.8, 0.1)
					
					profilesFrame.ImportingProfileAlert.IsLoadingLabel1 = DF:CreateLabel (profilesFrame.ImportingProfileAlert, L["OPTIONS_PROFILE_CONFIG_EXPORTINGTASK"])
					profilesFrame.ImportingProfileAlert.IsLoadingLabel2 = DF:CreateLabel (profilesFrame.ImportingProfileAlert, L["OPTIONS_PLEASEWAIT"])
					profilesFrame.ImportingProfileAlert.IsLoadingImage1 = DF:CreateImage (profilesFrame.ImportingProfileAlert, [[Interface\DialogFrame\UI-Dialog-Icon-AlertOther]], 32, 32)
					profilesFrame.ImportingProfileAlert.IsLoadingLabel1.align = "center"
					profilesFrame.ImportingProfileAlert.IsLoadingLabel2.align = "center"
					
					profilesFrame.ImportingProfileAlert.IsLoadingLabel1:SetPoint ("center", 16, 10)
					profilesFrame.ImportingProfileAlert.IsLoadingLabel2:SetPoint ("center", 16, -5)
					profilesFrame.ImportingProfileAlert.IsLoadingImage1:SetPoint ("left", 10, 0)
				end
				
				profilesFrame.NewProfileLabel:Hide()
				profilesFrame.NewProfileTextEntry:Hide()
				
				profilesFrame.ImportStringField:Show()
				profilesFrame.ImportingProfileAlert:Show()
				
				C_Timer.After (.1, function()
					--save mod/script editing
					local hookFrame = mainFrame.AllFrames [7]
					local scriptObject = hookFrame.GetCurrentScriptObject()
					if (scriptObject) then
						hookFrame.SaveScript()
						hookFrame.CancelEditing()
					end
					local scriptingFrame = mainFrame.AllFrames [6]
					local scriptObject = scriptingFrame.GetCurrentScriptObject()
					if (scriptObject) then
						scriptingFrame.SaveScript()
						scriptingFrame.CancelEditing()
					end
				
					Plater.db.profile.captured_spells = {} -- cleanup, although it should be empty, stored in PlaterDB
					Plater.db.profile.captured_casts = {} -- cleanup, although it should be empty, stored in PlaterDB
					
					--create a modifiable copy, do not modify "in use" profile for safety
					local profile = DF.table.copy(Plater.db.profile, {})
					local npc_cacheOrig = Plater.db.profile.npc_cache
					
					--do not export cache data, these data can be rebuild at run time
					profile.npc_cache = {}
					profile.saved_cvars_last_change = {}
					profile.script_data_trash = {}
					profile.hook_data_trash = {}
					profile.plugins_data = {} -- it might be good to remove those to ensure no addon dependencies break anything
					--profile.spell_animation_list = nil -- nil -> default will be used. but this should be part of the profile?!
					
					--retain npc_cache for set npc_colors
					for npcID, _ in pairs (profile.npc_colors) do
						profile.npc_cache [npcID] = npc_cacheOrig [npcID]
					end
					--retain npc_cache for set npcs_renamed
					for npcID, _ in pairs (profile.npcs_renamed) do
						profile.npc_cache [npcID] = npc_cacheOrig [npcID]
					end
					--retain npc_cache, captured_spells and captured_casts for set cast_colors
					for spellId, _ in pairs (profile.cast_colors) do
						profile.captured_spells[spellId] = DB_CAPTURED_SPELLS[spellId]
						profile.captured_casts[spellId] = DB_CAPTURED_CASTS[spellId]
						local capturedSpell = DB_CAPTURED_SPELLS[spellId] or DB_CAPTURED_CASTS[spellId]
						if capturedSpell and capturedSpell.npcID then
							local npcID = capturedSpell.npcID
							profile.npc_cache [npcID] = npc_cacheOrig [npcID]
						end
					end
					--retain npc_cache, captured_spells and captured_casts for set cast_colors
					for spellId, _ in pairs (profile.cast_audiocues) do
						profile.captured_spells[spellId] = DB_CAPTURED_SPELLS[spellId]
						profile.captured_casts[spellId] = DB_CAPTURED_CASTS[spellId]
						local capturedSpell = DB_CAPTURED_SPELLS[spellId] or DB_CAPTURED_CASTS[spellId]
						if capturedSpell and capturedSpell.npcID then
							local npcID = capturedSpell.npcID
							profile.npc_cache [npcID] = npc_cacheOrig [npcID]
						end
					end
					
					--cleanup mods HooksTemp (for good)
					for i = #profile.hook_data, 1, -1 do
						local scriptObject = profile.hook_data [i]
						scriptObject.HooksTemp = {}
					end
					
					--store current profile name
					profile.profile_name = Plater.db:GetCurrentProfile()
					profile.tocversion = select(4, GetBuildInfo()) -- provide export toc
					
					--convert the profile to string
					local data = Plater.CompressData (profile, "print")
					if (not data) then
						Plater:Msg ("failed to compress the profile")
					end
					
					--export to string
					profilesFrame.ImportStringField:SetText (data or L["OPTIONS_ERROR_EXPORTSTRINGERROR"])
				end)
				
				C_Timer.After (.3, function()
					profilesFrame.ImportStringField:SetFocus (true)
					profilesFrame.ImportStringField.editbox:HighlightText()
					profilesFrame.ImportingProfileAlert:Hide()
				end)
			end
			
			function profilesFrame.ImportProfile()
				profilesFrame.IsExporting = nil
				profilesFrame.IsImporting = true
				
				profilesFrame.ImportStringField.importDataText = nil
				local editbox = profilesFrame.ImportStringField.editbox
				local pasteBuffer, pasteCharCount, isPasting = {}, 0, false
				--editbox:SetMaxBytes (1) -- for performance
				
				local function clearBuffer(self)
					self:SetScript('OnUpdate', nil)
					editbox:SetMaxBytes (IMPORT_EXPORT_EDIT_MAX_BYTES)
					isPasting = false
					if pasteCharCount > 10 then
						local paste = strtrim(table.concat(pasteBuffer))
						
						local wagoProfile = Plater.DecompressData (paste, "print")
						if (wagoProfile and type (wagoProfile) == "table") then
							if  (wagoProfile.plate_config) then
								local existingProfileName = nil
								local wagoInfoText = "Import data verified.\n\n"
								if wagoProfile.url then
									local impProfUrl = wagoProfile.url or ""
									local impProfID = impProfUrl:match("wago.io/([^/]+)/([0-9]+)") or impProfUrl:match("wago.io/([^/]+)$")
									local profiles = Plater.db.profiles
									if impProfID then
										for pName, pData in pairs(profiles) do
											local pUrl = pData.url or ""
											local id = pUrl:match("wago.io/([^/]+)/([0-9]+)") or pUrl:match("wago.io/([^/]+)$")
											if id and impProfID == id then
												existingProfileName = pName
												break
											end									
										end
									end
								
									wagoInfoText = wagoInfoText .. "Extracted the following wago information from the profile data:\n"
									wagoInfoText = wagoInfoText .. "  Local Profile Name: " .. (wagoProfile.profile_name or "N/A") .. "\n"
									wagoInfoText = wagoInfoText .. "  Wago-Revision: " .. (wagoProfile.version or "-") .. "\n"
									wagoInfoText = wagoInfoText .. "  Wago-Version: " .. (wagoProfile.semver or "-") .. "\n"
									wagoInfoText = wagoInfoText .. "  Wago-URL: " .. (wagoProfile.url and (wagoProfile.url .. "\n") or "")
									wagoInfoText = wagoInfoText .. (existingProfileName and ("\nThis profile already exists as: '" .. existingProfileName .. "' in your profiles.\n") or "")
								else
									wagoInfoText = "This profile does not contain any wago.io information.\n"
								end
								
								wagoInfoText = wagoInfoText .. "\nYou may change the name below and click on '".. L["OPTIONS_OKAY"] .. "' to import the profile."
								
								editbox:SetText (wagoInfoText)
								profilesFrame.ImportStringField.importDataText = paste
								local curNewProfName = profilesFrame.NewProfileTextEntry:GetText()
								if existingProfileName and curNewProfName and curNewProfName == "MyNewProfile" then
									profilesFrame.NewProfileTextEntry:SetText(existingProfileName)
								elseif wagoProfile.profile_name and wagoProfile.profile_name ~= "Default" and curNewProfName and curNewProfName == "MyNewProfile" then
									profilesFrame.NewProfileTextEntry:SetText(wagoProfile.profile_name)
								end
							else
								local scriptType = Plater.GetDecodedScriptType (wagoProfile)
								if (scriptType == "hook" or scriptType == "script") then
									editbox:SetText (L["OPTIONS_PROFILE_ERROR_WRONGTAB"])
								else
									editbox:SetText (L["OPTIONS_PROFILE_ERROR_STRINGINVALID"])
								end
							end
						else
							editbox:SetText("Could not decompress the data. The text pasted does not appear to be a serialized Plater profile.\nTry copying the import string again.")
						end
						
						editbox:ClearFocus()
					end
				end
				editbox:SetScript('OnChar', function(self, c)
					if not isPasting then
						if editbox:GetMaxBytes() ~= 1 then -- ensure this for performance!
							editbox:SetMaxBytes (1)
						end
						pasteBuffer, pasteCharCount, isPasting = {}, 0, true
						self:SetScript('OnUpdate', clearBuffer)
					end
					pasteCharCount = pasteCharCount + 1
					pasteBuffer[pasteCharCount] = c
				end)
				
				profilesFrame.ImportStringField:Show()
				
				C_Timer.After (.2, function()
					profilesFrame.ImportStringField:SetText ("<Paste import string here>")
					profilesFrame.ImportStringField:SetFocus (true)
				end)
				
				profilesFrame.NewProfileLabel:Show()
				profilesFrame.NewProfileTextEntry:Show()
			end
			
			function profilesFrame.HideStringField()
				profilesFrame.IsExporting = nil
				profilesFrame.IsImporting = nil
				profilesFrame.ImportStringField.importDataText = nil
				
				local editbox = profilesFrame.ImportStringField.editbox
				editbox:SetMaxBytes (IMPORT_EXPORT_EDIT_MAX_BYTES)
				editbox:SetScript("OnChar", nil);
				
				profilesFrame.ImportStringField:Hide()
				profilesFrame.ImportStringField:SetText ("")
				
				profilesFrame.NewProfileLabel:Hide()
				profilesFrame.NewProfileTextEntry:Hide()
			end
			
			--importing a profile in the profiles tab
			--this is called when the user pressess the okay button to confirm the profile import
			function profilesFrame.ConfirmImportProfile(isWagoUpdate)
				if (profilesFrame.IsExporting) then
					profilesFrame.HideStringField()
					return
				end

				local text = profilesFrame.ImportStringField.importDataText
				local profile = Plater.DecompressData (text, "print")
				
				if (profile and type (profile) == "table") then
				
					--decompress success, need to see if this is a real profile and not a script
					if (not profile.plate_config) then
						local scriptType = Plater.GetDecodedScriptType (profile)
						if (scriptType == "hook" or scriptType == "script") then
							DF:ShowErrorMessage (L["OPTIONS_PROFILE_ERROR_WRONGTAB"], "Plater Nameplates")
						else
							DF:ShowErrorMessage (L["OPTIONS_PROFILE_ERROR_STRINGINVALID"], "Plater Nameplates")
						end
						return
					end
					
					local profileName = profilesFrame.NewProfileTextEntry:GetText()
					if (profileName == "") then
						Plater:Msg (L["OPTIONS_PROFILE_ERROR_PROFILENAME"])
						return
					end
					
					if (not profile.spell_animation_list) then
						profile.spell_animation_list = DF.table.copy ({}, PLATER_DEFAULT_SETTINGS.profile.spell_animation_list)
					end
					
					--if true then  --debug: dump the uncompressed table
					--	Details:DumpTable (profile)
					--	return
					--end
					
					local profiles = Plater.db:GetProfiles()
					local profileExists = false
					for i, existingProfName in ipairs(profiles) do
						if existingProfName == profileName then
							profileExists = true
							break
						end
					end
					
					if profileExists then
						--DF:ShowPromptPanel ("Warning!\nA Plater profile with the name \profileName.. "\" already exists. Are you sure you want to overwrite it?\nIf not: please specify a new name for the profile.\nOverwriting an existing profile cannot be undone!", function() profilesFrame.DoProfileImport(profileName, profile) end, function() end, true, 500)
						DF:ShowPromptPanel (format (L["OPTIONS_PROFILE_IMPORT_OVERWRITE"], profileName), function() profilesFrame.DoProfileImport(profileName, profile, true, isWagoUpdate) end, function() end, true, 500)
					else
						profilesFrame.DoProfileImport(profileName, profile, false, false)
					end
					
				end
			end
			
			---@param profileName string
			---@param profile table
			---@param bIsUpdate boolean
			---@param bKeepModsNotInUpdate boolean
			function profilesFrame.DoProfileImport(profileName, profile, bIsUpdate, bKeepModsNotInUpdate)
				profilesFrame.HideStringField()
				
				profile.profile_name = nil --no need to import
				
				Plater.ImportAndSwitchProfile(profileName, profile, bIsUpdate, bKeepModsNotInUpdate, false)
			end
			
			function profilesFrame.OpenProfileManagement()
				f:Hide()
				if SettingsPanel then
					if not Plater.ProfileFrame then
						Plater.ProfileFrame = LibStub ("AceConfig-3.0"):RegisterOptionsTable ("Plater", LibStub ("AceDBOptions-3.0"):GetOptionsTable (Plater.db, true))
					end
					LibStub ("AceConfigDialog-3.0"):Open("Plater")
				else
					Plater:OpenInterfaceProfile()
				end
				C_Timer.After (.5, function()
					mainFrame:SetIndex(1)
					mainFrame:SelectTabByIndex(1)
				end)
			end
			
			function profilesFrame.UpdateProfile()
				if not Plater.HasWagoUpdate(Plater.db.profile) then return end
		
				local url = Plater.db.profile.url or ""
				local id = url:match("wago.io/([^/]+)/([0-9]+)") or url:match("wago.io/([^/]+)$")
				if id and Plater.CompanionDataSlugs[id] then
					local update = Plater.CompanionDataSlugs[id]
					
					profilesFrame.IsExporting = nil
					profilesFrame.IsImporting = true
					
					profilesFrame.NewProfileTextEntry:SetText(Plater.db:GetCurrentProfile())
					profilesFrame.ImportStringField.importDataText = update.encoded
					
					profilesFrame.ConfirmImportProfile(true)
				end
			end
			
			local function checkProfilesUpdateEnabled()
				local hasProfileUpdate = Plater.HasWagoUpdate(Plater.db.profile)
				local wago_update = Plater.GetWagoUpdateDataFromCompanion(Plater.db.profile)
				local companionVersion = wago_update and tonumber(wago_update.wagoVersion) or nil
				if (Plater.db.profile.skipWagoUpdate and wago_update) or hasProfileUpdate then
					profilesFrame.skipProfileUpdateButton:Enable()
				else
					profilesFrame.skipProfileUpdateButton:Disable()
				end
				
				if hasProfileUpdate then
					profilesFrame.updateProfileButton:Enable()
				else
					profilesFrame.updateProfileButton:Disable()
				end
				update_wago_update_icons()
			end
			
			function profilesFrame.IgnoreUpdateProfile()
				if not Plater.db.profile.ignoreWagoUpdate then
					profilesFrame.ignoreProfileUpdateButton.button.text:SetText ("Don't ignore Profile Update")
					Plater.db.profile.ignoreWagoUpdate = true
					checkProfilesUpdateEnabled()
				else
					profilesFrame.ignoreProfileUpdateButton.button.text:SetText ("Ignore Profile Update")
					Plater.db.profile.ignoreWagoUpdate = nil
					checkProfilesUpdateEnabled()
				end
			end
			
			function profilesFrame.SkipUpdateProfile()					
				local hasProfileUpdate = Plater.HasWagoUpdate(Plater.db.profile)
				local wago_update = Plater.GetWagoUpdateDataFromCompanion(Plater.db.profile)
				local companionVersion = wago_update and tonumber(wago_update.wagoVersion) or nil
				if (Plater.db.profile.skipWagoUpdate and wago_update) or hasProfileUpdate then
					if Plater.db.profile.skipWagoUpdate or companionVersion and Plater.db.profile.skipWagoUpdate == companionVersion then
						profilesFrame.skipProfileUpdateButton.button.text:SetText ("Skip this version")
						Plater.db.profile.skipWagoUpdate = nil
						checkProfilesUpdateEnabled()
					else
						profilesFrame.skipProfileUpdateButton.button.text:SetText ("Don't skip this version")
						Plater.db.profile.skipWagoUpdate = companionVersion
						checkProfilesUpdateEnabled()
					end
				end
			end
			
			function profilesFrame.CopyWagoUrl()
				Plater.OpenCopyUrlDialog(Plater.db.profile.url)
			end
			
			profilesFrame:SetScript ("OnShow", function()
				profilesFrame.HideStringField()
			end)
		
		--frames
			--export profile button
			local exportProfileButton = DF:CreateButton (profilesFrame, profilesFrame.ExportCurrentProfile, 160, 20, L["OPTIONS_PROFILE_CONFIG_EXPORTPROFILE"], -1, nil, nil, "ExportButton", nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
			exportProfileButton:SetPoint ("topleft", profilesFrame, "topleft", 10, startY)
			
			--import profile button
			local importProfileButton = DF:CreateButton (profilesFrame, profilesFrame.ImportProfile, 160, 20, L["OPTIONS_PROFILE_CONFIG_IMPORTPROFILE"], -1, nil, nil, "ImportButton", nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
			importProfileButton:SetPoint ("topleft", exportProfileButton, "bottomleft", 0, -2)
			
			--open profile management button
			local openManagementProfileButton = DF:CreateButton (profilesFrame, profilesFrame.OpenProfileManagement, 160, 20, L["OPTIONS_PROFILE_CONFIG_OPENSETTINGS"], -1, nil, nil, "ProfileSettingsButton", nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
			openManagementProfileButton:SetPoint ("topleft", importProfileButton, "bottomleft", 0, -10)
			
			local moreProfilesLabel = DF:CreateLabel (profilesFrame, L["OPTIONS_PROFILE_CONFIG_MOREPROFILES"] .. ":", DF:GetTemplate ("font", "PLATER_BUTTON"))
			moreProfilesLabel:SetPoint ("topleft", openManagementProfileButton, "bottomleft", 0, -20)
			
			local moreProfilesTextEntry = DF:CreateTextEntry (profilesFrame, function()end, 160, 20, "moreProfilesTextEntry", nil, nil, DF:GetTemplate ("dropdown", "PLATER_DROPDOWN_OPTIONS"))
			moreProfilesTextEntry:SetPoint ("topleft", moreProfilesLabel, "bottomleft", 0, -2)
			moreProfilesTextEntry:SetText ("https://wago.io/plater")
			
			moreProfilesTextEntry:SetHook ("OnEditFocusGained", function()
				moreProfilesTextEntry:HighlightText()
			end)
			
			local profileInfoLabel = DF:CreateLabel (profilesFrame, "Current Profile Info" .. ":", DF:GetTemplate ("font", "PLATER_BUTTON"))
			profileInfoLabel:SetPoint ("topleft", moreProfilesTextEntry, "bottomleft", 0, -30)
			
			local profileInfoText = ""
			profileInfoText = profileInfoText .. "Name: " .. Plater.db:GetCurrentProfile() .. "\n\n"
			profileInfoText = profileInfoText .. "Profile-Revision: " .. (Plater.db.profile.version or "-") .. "\n"
			profileInfoText = profileInfoText .. "Profile-Version: " .. (Plater.db.profile.semver or "-") .. "\n\n"
			profileInfoText = profileInfoText .. (Plater.db.profile.url or "")
			
			local profileInfo = DF:CreateLabel(profilesFrame, profileInfoText, 10, "orange")
			profileInfo.width = 160
			profileInfo.height = 80
			profileInfo.valign = "top"
			profileInfo.align = "left"
			profileInfo:SetPoint("topleft", profileInfoLabel, "bottomleft", 0, -2)
			
			local copyWagoURLButton = DF:CreateButton (profilesFrame, profilesFrame.CopyWagoUrl, 160, 20, "Copy Wago URL", -1, nil, nil, "CopyWagoUrlButton", nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
			copyWagoURLButton:SetPoint ("topleft", profileInfo, "bottomleft", 0, -2)
			if not Plater.db.profile.url then
				copyWagoURLButton:Disable()
			end
			
			local updateProfileLabel = DF:CreateLabel (profilesFrame, "Update from wago.io" .. ":", DF:GetTemplate ("font", "PLATER_BUTTON"))
			updateProfileLabel:SetPoint ("topleft", copyWagoURLButton, "bottomleft", 0, -30)
			
			--import profile button
			local updateProfileButton = DF:CreateButton (profilesFrame, profilesFrame.UpdateProfile, 160, 20, "Update Profile", -1, nil, nil, "WagoUpdateProfileButton", nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
			updateProfileButton:SetPoint ("topleft", updateProfileLabel, "bottomleft", 0, -2)
			profilesFrame.updateProfileButton = updateProfileButton
			
			local updateIcon = updateProfileButton.button:CreateTexture ("$parentIcon", "overlay")
			updateIcon:SetSize (16, 10)
			updateIcon:SetTexture([[Interface\AddOns\Plater\images\wagologo.tga]])
			updateIcon:SetPoint("bottomright", updateProfileButton.button, "bottomright", -2, 2)
			updateProfileButton.updateIcon = updateIcon
			
			--ignore profile update button
			local ignoreProfileUpdateButton = DF:CreateButton (profilesFrame, profilesFrame.IgnoreUpdateProfile, 160, 20, "Ignore Profile Update", -1, nil, nil, "WagoIgnoreUpdateProfileButton", nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
			ignoreProfileUpdateButton:SetPoint ("topleft", updateProfileButton, "bottomleft", 0, -2)
			profilesFrame.ignoreProfileUpdateButton = ignoreProfileUpdateButton
			
			--ignore profile update button
			local skipProfileUpdateButton = DF:CreateButton (profilesFrame, profilesFrame.SkipUpdateProfile, 160, 20, "Skip this version", -1, nil, nil, "WagoSkipUpdateProfileButton", nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
			skipProfileUpdateButton:SetPoint ("topleft", ignoreProfileUpdateButton, "bottomleft", 0, -2)
			profilesFrame.skipProfileUpdateButton = skipProfileUpdateButton
			
			local wagoInfoLabel = DF:CreateLabel (profilesFrame, "Wago ProfileInfo" .. ":", DF:GetTemplate ("font", "PLATER_BUTTON"))
			wagoInfoLabel:SetPoint ("topleft", skipProfileUpdateButton, "bottomleft", 0, -10)
			
			local wagoInfo = DF:CreateLabel(profilesFrame, "", 10, "orange")
			wagoInfo.width = 160
			wagoInfo.height = 80
			wagoInfo.valign = "top"
			wagoInfo.align = "left"
			wagoInfo:SetPoint("topleft", wagoInfoLabel, "bottomleft", 0, -2)
			
			local hasProfileUpdate = Plater.HasWagoUpdate(Plater.db.profile)
			if hasProfileUpdate then
				
				local url = Plater.db.profile.url or ""
				local id = url:match("wago.io/([^/]+)/([0-9]+)") or url:match("wago.io/([^/]+)$")
				if id and Plater.CompanionDataSlugs[id] then
					local update = Plater.CompanionDataSlugs[id]
					
					local wagoProfile = Plater.DecompressData (update.encoded, "print")				
					if (wagoProfile and type(wagoProfile) == "table" and wagoProfile.plate_config) then
				
						local wagoInfoText = ""
						wagoInfoText = wagoInfoText .. "Name: " .. update.name .. "\n\n"
						wagoInfoText = wagoInfoText .. "Wago-Revision: " .. (wagoProfile.version or "-") .. "\n"
						wagoInfoText = wagoInfoText .. "Wago-Version: " .. (wagoProfile.semver or "-") .. "\n\n"
						wagoInfoText = wagoInfoText .. (wagoProfile.url or "")
						
						wagoInfo.label:SetText (wagoInfoText)
					end
				end
			else
				updateProfileButton:Disable()
			end
			
			if (Plater.db.profile.url) then
				if Plater.db.profile.ignoreWagoUpdate then
					ignoreProfileUpdateButton.button.text:SetText ("Don't ignore Profile Update")
				end
				
				local wago_update = Plater.GetWagoUpdateDataFromCompanion(Plater.db.profile)
				local companionVersion = wago_update and tonumber(wago_update.wagoVersion) or nil
				if (Plater.db.profile.skipWagoUpdate and wago_update) or hasProfileUpdate then
					if Plater.db.profile.skipWagoUpdate or companionVersion and Plater.db.profile.skipWagoUpdate == companionVersion then
						skipProfileUpdateButton.button.text:SetText ("Don't skip this version")
					end
				else
					skipProfileUpdateButton:Disable()
				end
			else
				ignoreProfileUpdateButton:Disable()
				skipProfileUpdateButton:Disable()
			end
			
			profilesFrame.moreProfilesLabel = moreProfilesLabel
			profilesFrame.moreProfilesTextEntry = moreProfilesTextEntry
			
			--text editor
			local luaeditor_backdrop_color = {.2, .2, .2, .5}
			local luaeditor_border_color = {0, 0, 0, 1}
			local edit_script_size = {620, 431}
			local buttons_size = {120, 20}
			
			local importStringField = DF:NewSpecialLuaEditorEntry (profilesFrame, edit_script_size[1], edit_script_size[2], "ImportEditor", "$parentImportEditor", true)
			importStringField:SetBackdrop ({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
			importStringField:SetBackdropBorderColor (unpack (luaeditor_border_color))
			importStringField:SetBackdropColor (unpack (luaeditor_backdrop_color))
			importStringField:Hide()
			profilesFrame.ImportStringField = importStringField
			DF:ReskinSlider (importStringField.scroll)
			
			local block_mouse_frame = CreateFrame ("frame", nil, importStringField, BackdropTemplateMixin and "BackdropTemplate")
			--block_mouse_frame:SetFrameLevel (block_mouse_frame:GetFrameLevel()-5)
			block_mouse_frame:SetAllPoints()
			
			local function importStringFieldTextHighlight()
				importStringField:SetFocus (true)
				if profilesFrame.IsImporting then
					--importStringField.editbox:SetText("")
					importStringField.editbox:HighlightText()
				else
					importStringField.editbox:HighlightText()
				end
			end
			block_mouse_frame:SetScript ("OnMouseDown", importStringFieldTextHighlight)
			importStringField.editbox:SetScript ("OnCursorChanged", importStringFieldTextHighlight)
			
			--import button
			local okayButton = DF:CreateButton (importStringField, function() profilesFrame.ConfirmImportProfile(false) end, buttons_size[1], buttons_size[2], L["OPTIONS_OKAY"], -1, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
			okayButton:SetIcon ([[Interface\BUTTONS\UI-Panel-BiggerButton-Up]], 20, 20, "overlay", {0.1, .9, 0.1, .9})
			
			--cancel button
			local cancelButton = DF:CreateButton (importStringField, profilesFrame.HideStringField, buttons_size[1], buttons_size[2], L["OPTIONS_CANCEL"], -1, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
			cancelButton:SetIcon ([[Interface\BUTTONS\UI-Panel-MinimizeButton-Up]], 20, 20, "overlay", {0.1, .9, 0.1, .9})
			
			importStringField:SetPoint ("topleft", profilesFrame, "topleft", 220, startY)
			okayButton:SetPoint ("topright", importStringField, "bottomright", 0, -10)
			cancelButton:SetPoint ("right", okayButton, "left", -20, 0)
			
			--new profile name
			local newProfileNameLabel = DF:CreateLabel (profilesFrame, L["OPTIONS_PROFILE_CONFIG_PROFILENAME"] .. ":", DF:GetTemplate ("font", "OPTIONS_FONT_TEMPLATE"))
			local newProfileNameTextEntry = DF:CreateTextEntry (profilesFrame, function()end, 160, 20, "ProfileNameTextEntry", _, _, DF:GetTemplate ("dropdown", "PLATER_DROPDOWN_OPTIONS"))
			newProfileNameTextEntry:SetText ("MyNewProfile")
			newProfileNameTextEntry.tooltip = L["OPTIONS_PROFILE_CONFIG_PROFILENAME_DESC"]
			newProfileNameLabel:SetPoint ("topleft", importStringField, "bottomleft", 0, -16)
			newProfileNameTextEntry:SetPoint ("left", newProfileNameLabel, "right", 2, 0)
			
			profilesFrame.NewProfileLabel = newProfileNameLabel
			profilesFrame.NewProfileTextEntry = newProfileNameTextEntry
			profilesFrame.NewProfileLabel:Hide()
			profilesFrame.NewProfileTextEntry:Hide()
			
			-- don't do this anymore, this causes huge lag when pasting large strings... buffer instead on importing. Setting values for good measure, though
			profilesFrame.ImportStringField.editbox:SetMaxBytes (IMPORT_EXPORT_EDIT_MAX_BYTES)
			profilesFrame.ImportStringField.editbox:SetMaxLetters (IMPORT_EXPORT_EDIT_MAX_LETTERS)
			
		--profile options (this is the panel in the right side of the profile tab)
			local scriptUpdatesTitleLocTable = DetailsFramework.Language.CreateLocTable(addonId, "OPTIONS_NOESSENTIAL_TITLE")
			local scriptUpdatesTitle = DF:CreateLabel(profilesFrame, scriptUpdatesTitleLocTableL, DF:GetTemplate("font", "YELLOW_FONT_TEMPLATE"))
			scriptUpdatesTitle:SetPoint("topleft", profilesFrame, "topright", -235, startY)
			scriptUpdatesTitle.textsize = 9

			local scriptUpdatesDescLocTable = DetailsFramework.Language.CreateLocTable(addonId, "OPTIONS_NOESSENTIAL_DESC")
			local scriptUpdatesDesc = DF:CreateLabel(profilesFrame, scriptUpdatesDescLocTable, DF:GetTemplate("font", "ORANGE_FONT_TEMPLATE"))
			scriptUpdatesDesc:SetPoint("topleft", scriptUpdatesTitle, "bottomleft", 0, -5)
			scriptUpdatesDesc.width = 180
			scriptUpdatesDesc.textsize = 9

			local scriptUpdatesCheckBox = DF:CreateSwitch(
				profilesFrame, 
				function() PlaterDB.SkipNonEssentialPatches = not PlaterDB.SkipNonEssentialPatches end, 
				PlaterDB.SkipNonEssentialPatches, _, _, _, _, 
				"ScriptUpdatesCheckBox", "$parentScriptUpdatesCheckBox", 
				nil, nil, nil, nil,
				DF:GetTemplate("switch", "OPTIONS_CHECKBOX_BRIGHT_TEMPLATE")
			)
			scriptUpdatesCheckBox:SetAsCheckBox()
			scriptUpdatesCheckBox:SetPoint("topleft", scriptUpdatesDesc, "bottomleft", 0, -10)

			local scriptUpdatesCheckBoxLabelLocTable = DetailsFramework.Language.CreateLocTable(addonId, "OPTIONS_NOESSENTIAL_NAME")
			local scriptUpdatesCheckBoxLabel = DF:CreateLabel(profilesFrame, scriptUpdatesCheckBoxLabelLocTable, DF:GetTemplate("font", "YELLOW_FONT_TEMPLATE"))
			scriptUpdatesCheckBoxLabel:SetPoint("left", scriptUpdatesCheckBox, "right", 5, 0)
			scriptUpdatesCheckBoxLabel.textsize = 9
			scriptUpdatesCheckBoxLabel.width = 180

	end


-------------------------
-- fun��es gerais dos dropdowns ~dropdowns
	local textures = LibSharedMedia:HashTable ("statusbar")

	--outline table
	local outline_modes = {"NONE", "MONOCHROME", "OUTLINE", "THICKOUTLINE", "MONOCHROME, OUTLINE", "MONOCHROME, THICKOUTLINE"}
	local outline_modes_names = {"None", "Monochrome", "Outline", "Thick Outline", "Monochrome Outline", "Monochrome Thick Outline"}
	local build_outline_modes_table = function (actorType, member)
		local t = {}
		for i = 1, #outline_modes do
			local value = outline_modes[i]
			local label = outline_modes_names[i]
		
			tinsert (t, {
				label = label,
				value = value,
                statusbar = dropdownStatusBarTexture,
                statusbarcolor = dropdownStatusBarColor,
				onclick = function (_, _, value)
					if (actorType) then
						Plater.db.profile.plate_config [actorType][member] = value
						Plater.RefreshDBUpvalues()
						Plater.UpdateAllPlates()
						Plater.UpdateAllNames()
					else
						Plater.db.profile [member] = value
						Plater.RefreshDBUpvalues()
						Plater.UpdateAllPlates()
						Plater.UpdateAllNames()
					end
				end
			})
		end
		return t
	end	
	
	--anchor table
	local build_anchor_side_table = function (actorType, member)
		local anchorOptions = {}
		local phraseIdTable = Plater.AnchorNamesByPhraseId
		local languageId = DF.Language.GetLanguageIdForAddonId(addonId)

		for i = 1, 13 do
			tinsert (anchorOptions, {
				label = DF.Language.GetText(addonId, phraseIdTable[i]),
				languageId = languageId,
				phraseId = phraseIdTable[i],
				value = i, 
                statusbar = dropdownStatusBarTexture,
                statusbarcolor = dropdownStatusBarColor,
				onclick = function (_, _, value)
					if (actorType) then
						Plater.db.profile.plate_config [actorType][member].side = value
						Plater.RefreshDBUpvalues()
						
						Plater.UpdateAllPlates()
						Plater.UpdateAllNames()
					else
						Plater.db.profile [member].side = value
						Plater.RefreshDBUpvalues()
						Plater.UpdateAllPlates()
						Plater.UpdateAllNames()
					end
				end
			})
		end
		return anchorOptions
	end	
	--
	local health_bar_texture_selected = function (self, capsule, value)
		Plater.db.profile.health_statusbar_texture = value
		Plater.RefreshDBUpvalues()
		Plater.UpdateAllPlates()
	end
	local health_bar_texture_options = {}
	for name, texturePath in pairs (textures) do 
		health_bar_texture_options [#health_bar_texture_options + 1] = {value = name, label = name, statusbar = texturePath, onclick = health_bar_texture_selected}
	end
	table.sort (health_bar_texture_options, function (t1, t2) return t1.label < t2.label end)
	--
	local health_bar_bgtexture_selected = function (self, capsule, value)
		Plater.db.profile.health_statusbar_bgtexture = value
		Plater.RefreshDBUpvalues()
		Plater.UpdateAllPlates()
	end
	local health_bar_bgtexture_options = {}
	for name, texturePath in pairs (textures) do 
		health_bar_bgtexture_options [#health_bar_bgtexture_options + 1] = {value = name, label = name, statusbar = texturePath, onclick = health_bar_bgtexture_selected}
	end
	table.sort (health_bar_bgtexture_options, function (t1, t2) return t1.label < t2.label end)

	local health_selection_overlay_selected = function (self, capsule, value)
		Plater.db.profile.health_selection_overlay = value
		Plater.UpdateAllPlates()
	end
	local health_selection_overlay_options = {}
	for name, texturePath in pairs (textures) do
		health_selection_overlay_options [#health_selection_overlay_options + 1] = {value = name, label = name, statusbar = texturePath, onclick = health_selection_overlay_selected}
	end
	table.sort (health_selection_overlay_options, function (t1, t2) return t1.label < t2.label end)
	--
	local target_selection_texture_selected = function (self, capsule, value)
		Plater.db.profile.target_highlight_texture = value
		Plater.UpdateAllPlates()
	end
	local target_selection_texture_selected_options = {}
	for index, texturePath in ipairs (Plater.TargetHighlights) do
		target_selection_texture_selected_options [#target_selection_texture_selected_options + 1] = {value = texturePath, label = "Highlight " .. index, statusbar = texturePath, onclick = target_selection_texture_selected}
	end
	--
	local cooldown_edge_texture_selected = function (self, capsule, value)
		Plater.db.profile.aura_cooldown_edge_texture = value
		Plater.IncreaseRefreshID()
		Plater.UpdateAllPlates()
	end
	local cooldown_edge_texture_selected_options = {}
	for index, texturePath in ipairs (Plater.CooldownEdgeTextures) do
		cooldown_edge_texture_selected_options [#cooldown_edge_texture_selected_options + 1] = {value = texturePath, label = "Texture " .. index, statusbar = texturePath, onclick = cooldown_edge_texture_selected}
	end
	--
	local extra_icon_cooldown_edge_texture_selected = function (self, capsule, value)
		Plater.db.profile.extra_icon_cooldown_edge_texture = value
		Plater.IncreaseRefreshID()
		Plater.UpdateAllPlates()
	end
	local extra_icon_cooldown_edge_texture_selected_options = {}
	for index, texturePath in ipairs (Plater.CooldownEdgeTextures) do
		extra_icon_cooldown_edge_texture_selected_options [#extra_icon_cooldown_edge_texture_selected_options + 1] = {value = texturePath, label = "Texture " .. index, statusbar = texturePath, onclick = extra_icon_cooldown_edge_texture_selected}
	end
	--

	
	
-------------------------------------------------------------------------------
--op��es do painel de interface da blizzard


function Plater.ChangeNameplateAnchor (_, _, value)
	if (value == 0) then
		SetCVar ("nameplateOtherAtBase", "0") --head
	elseif (value == 1) then
		SetCVar ("nameplateOtherAtBase", "1") --both
	elseif (value == 2) then
		SetCVar ("nameplateOtherAtBase", "2") --feet
	end
end


local interface_options = {
	--{type = "label", get = function() return "Interface Options:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
}

local interface_title = Plater:CreateLabel (frontPageFrame, "", Plater:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"))
interface_title:SetPoint (startX, startY)

local in_combat_background = Plater:CreateImage (frontPageFrame)
in_combat_background:SetColorTexture (.6, 0, 0, .1)
in_combat_background:SetPoint ("topleft", interface_title, "bottomleft", -5, 5)
in_combat_background:SetSize(275, 288)
in_combat_background:Hide()

local in_combat_label = Plater:CreateLabel (frontPageFrame, "you are in combat", 24, "silver")
in_combat_label:SetPoint ("right", in_combat_background, "right", -10, 10)
in_combat_label:Hide()

frontPageFrame:RegisterEvent ("PLAYER_REGEN_DISABLED")
frontPageFrame:RegisterEvent ("PLAYER_REGEN_ENABLED")
frontPageFrame:SetScript ("OnEvent", function (self, event)
	if (event == "PLAYER_REGEN_DISABLED") then
		in_combat_background:Show()
		in_combat_label:Show()
	elseif (event == "PLAYER_REGEN_ENABLED") then
		in_combat_background:Hide()
		in_combat_label:Hide()
	end
end)

interface_options.always_boxfirst = true
interface_options.language_addonId = addonId
interface_options.Name = "Interface Options"
DF:BuildMenu (frontPageFrame, interface_options, startX, startY-20, 300 + 60, false, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template, globalCallback)

function frontPageFrame.OpenNewsWindow()
	if (not PlaterNewsFrame) then
		local options = {
			width = 550,
			height = 700,
			line_amount = 13,
			line_height = 50,
		}
		
		local newsFrame = DF:CreateNewsFrame (UIParent, "PlaterNewsFrame", options, Plater.GetChangelogTable(), Plater.db.profile.news_frame)
		newsFrame:SetFrameStrata ("FULLSCREEN")
		
		local lastNews = Plater.db.profile.last_news_time
		
		newsFrame.NewsScroll.OnUpdateLineHook = function (line, lineIndex, data)
		--/run Plater.db.profile.last_news_time = 1
			local thisEntryTime = data [1]
			if (thisEntryTime > lastNews) then
				line.backdrop_color = {.4, .4, .4, .6}
				line.backdrop_color_highlight = {.5, .5, .5, .8}
				line:SetBackdropColor (.4, .4, .4, .6)
			else
				line.backdrop_color = {0, 0, 0, 0.2}
				line.backdrop_color_highlight = {.2, .2, .2, 0.4}
				line:SetBackdropColor (0, 0, 0, 0.2)
			end
		end
	end
	
	PlaterNewsFrame:Show()
	PlaterNewsFrame.NewsScroll:Refresh()
	Plater.db.profile.last_news_time = time()
	
	local numNews = DF:GetNumNews (Plater.GetChangelogTable(), Plater.db.profile.last_news_time)
	frontPageFrame.NewsButton:SetText ("Open Change Log")

end

local openNewsButton = DF:CreateButton (frontPageFrame, frontPageFrame.OpenNewsWindow, 160, 20, "Open Change Log", -1, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
openNewsButton:SetPoint ("topleft", frontPageFrame, "topleft", 10, -80)
frontPageFrame.NewsButton = openNewsButton

local numNews = DF:GetNumNews (Plater.GetChangelogTable(), Plater.db.profile.last_news_time)
if (numNews > 0) then
	frontPageFrame.NewsButton:SetText ("Open Change Log (|cFFFFFF00" .. numNews .."|r)")
end


--go to frames

function Plater.CreateGoToTabFrame(parent, text, index)
	local goToTab = CreateFrame("frame", nil, parent, BackdropTemplateMixin and "BackdropTemplate")
	goToTab:SetSize (230, 55)
	DF:ApplyStandardBackdrop (goToTab, false, 0.6)
	
	local labelgoToTab = DF:CreateLabel(goToTab, text, 10, "orange")
	labelgoToTab.width = 220
	labelgoToTab.height = 50
	labelgoToTab.valign = "middle"
	labelgoToTab.align = "center"
	labelgoToTab:SetPoint("center", goToTab, "center", 0, 0)

	local goTo = function()
		---@type df_tabcontainer
		local platerOptionsPanelContainer = PlaterOptionsPanelContainer
		platerOptionsPanelContainer:SelectTabByIndex(index)
	end

	local buttonGo = DF:CreateButton (parent, goTo, 20, 1, "", false, false, "", false, false, false, options_button_template)
	buttonGo:SetPoint("topleft", goToTab, "topright", 1, 0)
	buttonGo:SetPoint("bottomleft", goToTab, "bottomright", 1, 0)
	DF:ApplyStandardBackdrop (buttonGo, false, 0.8)

	local arrowTexture = DF:CreateImage (buttonGo, "Interface\\CHATFRAME\\ChatFrameExpandArrow", 18, 18, "overlay")
	arrowTexture:SetPoint("center", buttonGo, "center")

	return goToTab
end

local goToTabFrame1 = Plater.CreateGoToTabFrame(frontPageFrame, "Go to 'Enemy Npc' tab to setup health and castbar size.", 13)
goToTabFrame1:SetPoint("bottomright", frontPageFrame, "bottomright", -24, 22)

local goToTabFrame2 = Plater.CreateGoToTabFrame(enemyNPCsFrame, "Go to 'Threat / Aggro' tab to setup colors.", 2)
goToTabFrame2:SetPoint("bottomright", enemyNPCsFrame, "bottomright", -24, 22)

local goToTabFrame3 = Plater.CreateGoToTabFrame(threatFrame, "Go to 'Target' tab to choose how the nameplate looks like when the unit is your target.", 3)
goToTabFrame3:SetPoint("bottomright", threatFrame, "bottomright", -24, 22)

local goToTabFrame4 = Plater.CreateGoToTabFrame(targetFrame, "Go to 'Buff Settings' tab to setup the auras above the nameplate.", 9)
goToTabFrame4:SetPoint("bottomright", targetFrame, "bottomright", -24, 22)

-------------------------------------------------------------------------------
-- painel para configurar debuffs e buffs




local grow_direction_names = {"Left", "Center", "Right"}
local build_grow_direction_options = function (memberName)
	local t = {}
	for i = 1, #grow_direction_names do
		tinsert (t, {
			label = grow_direction_names [i], 
			value = i, 
			onclick = function (_, _, value)
				Plater.db.profile [memberName] = value
				Plater.RefreshDBUpvalues()
				Plater.UpdateAllPlates()
			end
		})
	end
	return t
end

local on_select_stack_text_font = function (_, _, value)
	Plater.db.profile.aura_stack_font = value
	Plater.UpdateAllPlates()
end

local on_select_auratimer_text_font  = function (_, _, value)
	Plater.db.profile.aura_timer_text_font = value
	Plater.UpdateAllPlates()
end

local debuff_options = {

	--{type = "label", get = function() return "|TInterface\\GossipFrame\\AvailableLegendaryQuestIcon:0|tTest Auras:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
	{type = "label", get = function() return "Test Auras:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
	{
		type = "toggle",
		boxfirst = true,
		get = function() return Plater.DisableAuraTest and true or false end,
		set = function (self, fixedparam, value) 
			Plater.DisableAuraTest = value
			if (value) then
				auraOptionsFrame.DisableAuraTest()
			elseif Plater.db.profile.aura_enabled then
				auraOptionsFrame.EnableAuraTest()
			end
		end,
		name = "|TInterface\\GossipFrame\\AvailableQuestIcon:0|tDisable Testing Auras",
		desc = "OPTIONS_AURAS_ENABLETEST",
	},
	
	{type = "blank"},
	
	{type = "label", get = function() return "General Settings:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},	
	{
		type = "toggle",
		boxfirst = true,
		get = function() return Plater.db.profile.aura_enabled end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.aura_enabled = value
			Plater.RefreshDBUpvalues()
			Plater.UpdateAllPlates()
			
			if (not value) then
				Plater.DisableAuraTest = true
				auraOptionsFrame.DisableAuraTest()
				for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
					for _, frame in ipairs (plateFrame.unitFrame.BuffFrame.PlaterBuffList) do
						frame:Hide()
					end
					for _, frame in ipairs (plateFrame.unitFrame.BuffFrame2.PlaterBuffList) do
						frame:Hide()
					end
				end
			else
				Plater.DisableAuraTest = false
				auraOptionsFrame.EnableAuraTest()
			end

			--refresh the aura options panel, as the canvasFrame was passed to BuildMenu() it require here to get the scrollChild to call RefreshOptions()
			auraOptionsFrame.canvasFrame:GetScrollChild():RefreshOptions()
		end,
		name = "OPTIONS_ENABLED",
		desc = "OPTIONS_ENABLED",
		childrenids = {"auras_general_tooltip", "auras_general_alpha", "auras_general_iconspacing", "auras_general_icon_row_spacing", "auras_general_stack_similar_aura", "auras_general_stack_auratime"},
		children_follow_enabled = true,
		--children_follow_reverse = true, --if the children should be enabled when the toogle is disabled, for cases like "do this automatically" if not, set manually
	},
	
	{
		type = "toggle",
		boxfirst = true,
		get = function() return Plater.db.profile.aura_show_tooltip end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.aura_show_tooltip = value
			Plater.UpdateAllPlates()
		end,
		name = "OPTIONS_SHOWTOOLTIP",
		desc = "OPTIONS_SHOWTOOLTIP_DESC",
		id = "auras_general_tooltip",
	},
	
	{
		type = "range",
		get = function() return Plater.db.profile.aura_alpha end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.aura_alpha = value
			Plater.RefreshDBUpvalues()
		end,
		min = 0,
		max = 1,
		step = 0.01,
		usedecimals = true,
		thumbscale = 1.8,
		name = "OPTIONS_ALPHA",
		desc = "OPTIONS_ALPHA",
		id = "auras_general_alpha",
	},
	
	{
		type = "range",
		get = function() return Plater.db.profile.aura_padding end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.aura_padding = value
			Plater.RefreshDBUpvalues()
		end,
		min = 0,
		max = 10,
		step = 0.01,
		usedecimals = true,
		thumbscale = 1.8,
		name = "OPTIONS_ICONSPACING",
		desc = "OPTIONS_ICONSPACING",
		id = "auras_general_iconspacing",
	},
	
	{
		type = "range",
		get = function() return Plater.db.profile.aura_breakline_space end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.aura_breakline_space = value
			Plater.RefreshDBUpvalues()
		end,
		min = 0,
		max = 15,
		step = 0.01,
		usedecimals = true,
		thumbscale = 1.8,
		name = "OPTIONS_ICONROWSPACING",
		desc = "OPTIONS_ICONROWSPACING",
		id = "auras_general_icon_row_spacing",
	},
	
	{
		type = "toggle",
		boxfirst = true,
		get = function() return Plater.db.profile.aura_consolidate end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.aura_consolidate = value
			Plater.UpdateAllPlates()
		end,
		name = "OPTIONS_STACK_SIMILAR_AURAS",
		desc = "OPTIONS_STACK_SIMILAR_AURAS_DESC",
		id = "auras_general_stack_similar_aura",
	},
	{
		type = "toggle",
		boxfirst = true,
		get = function() return Plater.db.profile.aura_consolidate_timeleft_lower end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.aura_consolidate_timeleft_lower = value
			Plater.UpdateAllPlates()
		end,
		name = "OPTIONS_STACK_AURATIME",
		desc = "OPTIONS_STACK_AURATIME_DESC",
		id = "auras_general_stack_auratime",
	},
	
	{type = "blank"},
	
	{
		type = "toggle",
		boxfirst = true,
		get = function() return Plater.db.profile.aura_sort end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.aura_sort = value
			Plater.UpdateAllPlates()
		end,
		name = "OPTIONS_AURAS_SORT",
		desc = "OPTIONS_AURAS_SORT_DESC",
	},
	
	{type = "blank"},
	{type = "label", get = function() return "Aura Size (Frame 1):" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
	
	{
		type = "range",
		get = function() return Plater.db.profile.aura_width end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.aura_width = value
			Plater.RefreshDBUpvalues()
			Plater.RefreshAuras()
			Plater.UpdateAllPlates()
		end,
		min = 4,
		max = 80,
		step = 1,
		name = "OPTIONS_WIDTH",
		desc = "OPTIONS_AURA_DEBUFF_WITH",
	},
	{
		type = "range",
		get = function() return Plater.db.profile.aura_height end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.aura_height = value
			Plater.RefreshDBUpvalues()
			Plater.RefreshAuras()
			Plater.UpdateAllPlates()
		end,
		min = 4,
		max = 80,
		step = 1,
		name = "OPTIONS_HEIGHT",
		desc = "OPTIONS_AURA_DEBUFF_HEIGHT",
	},
	{
		type = "range",
		get = function() return Plater.db.profile.aura_border_thickness end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.aura_border_thickness = value
			Plater.RefreshDBUpvalues()
			Plater.RefreshAuras()
			Plater.UpdateAllPlates()
		end,
		min = 1,
		max = 5,
		step = 1,
		name = "OPTIONS_BORDER_THICKNESS",
		desc = "OPTIONS_BORDER_THICKNESS",
	},
	
	{type = "blank"},
	{type = "label", get = function() return "Aura Size (Frame 2):" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
	
	{
		type = "range",
		get = function() return Plater.db.profile.aura_width2 end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.aura_width2 = value
			Plater.RefreshDBUpvalues()
			Plater.RefreshAuras()
			Plater.UpdateAllPlates()
		end,
		min = 4,
		max = 80,
		step = 1,
		name = "OPTIONS_WIDTH",
		desc = "OPTIONS_AURA_WIDTH",
	},
	{
		type = "range",
		get = function() return Plater.db.profile.aura_height2 end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.aura_height2 = value
			Plater.RefreshDBUpvalues()
			Plater.RefreshAuras()
			Plater.UpdateAllPlates()
		end,
		min = 4,
		max = 80,
		step = 1,
		name = "OPTIONS_HEIGHT",
		desc = "OPTIONS_AURA_HEIGHT",
	},
	{
		type = "range",
		get = function() return Plater.db.profile.aura_border_thickness2 end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.aura_border_thickness2 = value
			Plater.RefreshDBUpvalues()
			Plater.RefreshAuras()
			Plater.UpdateAllPlates()
		end,
		min = 1,
		max = 5,
		step = 1,
		name = "OPTIONS_BORDER_THICKNESS",
		desc = "OPTIONS_BORDER_THICKNESS",
	},
	
	{type = "blank"},

	{type = "label", get = function() return "Automatic Aura Tracking:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},

	{
		type = "toggle",
		boxfirst = true,
		get = function() return Plater.db.profile.aura_show_aura_by_the_player end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.aura_show_aura_by_the_player = value
			Plater.RefreshDBUpvalues()
			Plater.UpdateAllPlates()
		end,
		name = "Show Auras Casted by You",
		desc = "Show Auras Casted by You.",
	},
	
	{
		type = "toggle",
		boxfirst = true,
		get = function() return Plater.db.profile.aura_show_aura_by_other_players end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.aura_show_aura_by_other_players = value
			Plater.RefreshDBUpvalues()
			Plater.UpdateAllPlates()
		end,
		name = "Show Auras Casted by other Players",
		desc = "Show Auras Casted by other Players.\n\n" .. ImportantText .. "This may cause a lot of auras to show!",
	},

	{type = "blank"},
	
	{
		type = "toggle",
		boxfirst = true,
		get = function() return Plater.db.profile.aura_show_important end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.aura_show_important = value
			Plater.RefreshDBUpvalues()
			Plater.UpdateAllPlates()
		end,
		name = "Show Important Auras",
		desc = "Show buffs and debuffs which the game tag as important.",
	},
	
	{
		type = "toggle",
		boxfirst = true,
		get = function() return Plater.db.profile.aura_show_dispellable end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.aura_show_dispellable = value
			Plater.RefreshDBUpvalues()
			Plater.UpdateAllPlates()
		end,
		name = "Show Dispellable Buffs",
		desc = "Show auras which can be dispelled or stolen.",
	},
	
	{
		type = "toggle",
		boxfirst = true,
		get = function() return Plater.db.profile.aura_show_only_short_dispellable_on_players end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.aura_show_only_short_dispellable_on_players = value
			Plater.RefreshDBUpvalues()
			Plater.UpdateAllPlates()
		end,
		name = "Only short Dispellable Buffs on Players",
		desc = "Show auras which can be dispelled or stolen on players if they are below 120sec duration (only applicable when 'Show Dispellable Buffs' is enabled).",
	},
	
	{
		type = "toggle",
		boxfirst = true,
		get = function() return Plater.db.profile.aura_show_enrage end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.aura_show_enrage = value
			Plater.RefreshDBUpvalues()
			Plater.UpdateAllPlates()
		end,
		name = "Show Enrage Buffs",
		desc = "Show auras which are in the enrage category.",
	},
	
	{
		type = "toggle",
		boxfirst = true,
		get = function() return Plater.db.profile.aura_show_magic end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.aura_show_magic = value
			Plater.RefreshDBUpvalues()
			Plater.UpdateAllPlates()
		end,
		name = "Show Magic Buffs",
		desc = "Show auras which are in the magic type category.",
	},
	
	{
		type = "toggle",
		boxfirst = true,
		get = function() return Plater.db.profile.aura_show_crowdcontrol end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.aura_show_crowdcontrol = value
			Plater.RefreshDBUpvalues()
			Plater.UpdateAllPlates()
		end,
		name = "Show Crowd Control",
		desc = "Show crowd control effects.",
	},
	
	{type = "blank"},
	
	{
		type = "toggle",
		boxfirst = true,
		get = function() return Plater.db.profile.aura_show_buff_by_the_unit end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.aura_show_buff_by_the_unit = value
			Plater.RefreshDBUpvalues()
			Plater.UpdateAllPlates()
		end,
		name = "Show Buffs Casted by the Unit",
		desc = "Show Buffs Casted by the Unit it self",
	},
	{
		type = "toggle",
		boxfirst = true,
		get = function() return Plater.db.profile.aura_show_offensive_cd end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.aura_show_offensive_cd = value
			Plater.RefreshDBUpvalues()
			Plater.UpdateAllPlates()
		end,
		name = "Show offensive player CDs",
		desc = "Show offensive CDs on enemy/friendly players.",
	},
	
	{
		type = "toggle",
		boxfirst = true,
		get = function() return Plater.db.profile.aura_show_defensive_cd end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.aura_show_defensive_cd = value
			Plater.RefreshDBUpvalues()
			Plater.UpdateAllPlates()
		end,
		name = "Show defensive player CDs",
		desc = "Show defensive CDs on enemy/friendly players.",
	},
	
	{type = "breakline"},
	{type = "label", get = function() return "Aura Frame 1:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
	
	--> grow direction
	{
		type = "select",
		get = function() return Plater.db.profile.aura_grow_direction end,
		values = function() return build_grow_direction_options ("aura_grow_direction") end,
		name = "Grow Direction",
		desc = "To which side aura icons should grow.\n\n" .. ImportantText .. "debuffs are added first, buffs after.",
	},
	
	{
		type = "select",
		get = function() return Plater.db.profile.aura_frame1_anchor.side end,
		values = function() return build_anchor_side_table (nil, "aura_frame1_anchor") end,
		name = "OPTIONS_ANCHOR",
		desc = "Which side of the nameplate this aura frame is attached to.",
	},
	{
		type = "range",
		get = function() return Plater.db.profile.aura_frame1_anchor.x end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.aura_frame1_anchor.x = value
			Plater.db.profile.aura_x_offset = value -- keep backwards compatibility
			Plater.RefreshDBUpvalues()
			Plater.UpdateAllPlates()
		end,
		min = -200,
		max = 200,
		step = 1,
		usedecimals = true,
		name = "OPTIONS_XOFFSET",
		desc = "OPTIONS_XOFFSET",
	},
	{
		type = "range",
		get = function() return Plater.db.profile.aura_frame1_anchor.y end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.aura_frame1_anchor.y = value
			Plater.db.profile.aura_y_offset = value -- keep backwards compatibility
			Plater.RefreshDBUpvalues()
			Plater.UpdateAllPlates()
		end,
		min = -200,
		max = 200,
		step = 1,
		usedecimals = true,
		name = "OPTIONS_YOFFSET",
		desc = "OPTIONS_YOFFSET",
	},
	
	{type = "blank"},
	{type = "label", get = function() return "Aura Frame 2:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
	
	{
		type = "toggle",
		boxfirst = true,
		get = function() return Plater.db.profile.buffs_on_aura2 end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.buffs_on_aura2 = value
			Plater.RefreshDBUpvalues()
			Plater.UpdateAllPlates()
		end,
		name = "OPTIONS_ENABLED",
		desc = "When enabled auras are separated: Buffs are placed on this second frame, Debuffs on the first.",
	},
	--> grow direction
	{
		type = "select",
		get = function() return Plater.db.profile.aura2_grow_direction end,
		values = function() return build_grow_direction_options ("aura2_grow_direction") end,
		name = "Grow Direction",
		desc = "To which side aura icons should grow.",
	},
	--> offset
	{
		type = "select",
		get = function() return Plater.db.profile.aura_frame2_anchor.side end,
		values = function() return build_anchor_side_table (nil, "aura_frame2_anchor") end,
		name = "OPTIONS_ANCHOR",
		desc = "Which side of the nameplate this aura frame is attached to.",
	},
	{
		type = "range",
		get = function() return Plater.db.profile.aura_frame2_anchor.x end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.aura_frame2_anchor.x = value
			Plater.db.profile.aura2_x_offset = value -- keep backwards compatibility
			Plater.RefreshDBUpvalues()
			Plater.UpdateAllPlates()
		end,
		min = -200,
		max = 200,
		step = 1,
		usedecimals = true,
		name = "OPTIONS_XOFFSET",
		desc = "OPTIONS_XOFFSET",
	},
	{
		type = "range",
		get = function() return Plater.db.profile.aura_frame2_anchor.y end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.aura_frame2_anchor.y = value
			Plater.db.profile.aura2_y_offset = value -- keep backwards compatibility
			Plater.RefreshDBUpvalues()
			Plater.UpdateAllPlates()
		end,
		min = -200,
		max = 200,
		step = 1,
		usedecimals = true,
		name = "OPTIONS_YOFFSET",
		desc = "OPTIONS_YOFFSET",
	},
	
	{type = "blank"},

	{type = "label", get = function() return "Stack Counter:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},

	{
		type = "select",
		get = function() return Plater.db.profile.aura_stack_font end,
		values = function() return DF:BuildDropDownFontList (on_select_stack_text_font) end,
		name = "OPTIONS_FONT",
		desc = "OPTIONS_TEXT_FONT",
	},

	{
		type = "range",
		get = function() return Plater.db.profile.aura_stack_size end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.aura_stack_size = value
			Plater.UpdateAllPlates()
		end,
		min = 6,
		max = 24,
		step = 1,
		name = "OPTIONS_SIZE",
		desc = "Size",
	},
	
	--text outline options
	{
		type = "select",
		get = function() return Plater.db.profile.aura_stack_outline end,
		values = function() return build_outline_modes_table (nil, "aura_stack_outline") end,
		name = "OPTIONS_OUTLINE",
		desc = "OPTIONS_OUTLINE",
	},
	
	--text shadow color
	{
		type = "color",
		boxfirst = true,
		get = function()
			local color = Plater.db.profile.aura_stack_shadow_color
			return {color[1], color[2], color[3], color[4]}
		end,
		set = function (self, r, g, b, a) 
			local color = Plater.db.profile.aura_stack_shadow_color
			color[1], color[2], color[3], color[4] = r, g, b, a
			Plater.UpdateAllPlates()
		end,
		name = "OPTIONS_SHADOWCOLOR",
		desc = "OPTIONS_TOGGLE_TO_CHANGE",
	},

	{
		type = "color",
		boxfirst = true,
		get = function()
			local color = Plater.db.profile.aura_stack_color
			return {color[1], color[2], color[3], color[4]}
		end,
		set = function (self, r, g, b, a) 
			local color = Plater.db.profile.aura_stack_color
			color[1], color[2], color[3], color[4] = r, g, b, a
			Plater.UpdateAllPlates()
		end,
		name = "OPTIONS_COLOR",
		desc = "Color",
	},
	{
		type = "select",
		get = function() return Plater.db.profile.aura_stack_anchor.side end,
		values = function() return build_anchor_side_table (nil, "aura_stack_anchor") end,
		name = "OPTIONS_ANCHOR",
		desc = "Which side of the buff icon the stack counter should attach to.",
	},
	{
		type = "range",
		get = function() return Plater.db.profile.aura_stack_anchor.x end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.aura_stack_anchor.x = value
			Plater.UpdateAllPlates()
		end,
		min = -20,
		max = 20,
		step = 1,
		usedecimals = true,
		name = "OPTIONS_XOFFSET",
		desc = "OPTIONS_XOFFSET_DESC",
	},
	--y offset
	{
		type = "range",
		get = function() return Plater.db.profile.aura_stack_anchor.y end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.aura_stack_anchor.y = value
			Plater.UpdateAllPlates()
		end,
		min = -20,
		max = 20,
		step = 1,
		usedecimals = true,
		name = "OPTIONS_YOFFSET",
		desc = "OPTIONS_YOFFSET_DESC",
	},

	{type = "blank"},

	{type = "label", get = function() return "Aura Border Colors:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
	{
		type = "color",
		boxfirst = true,
		get = function()
			local color = Plater.db.profile.aura_border_colors.is_show_all
			return {color[1], color[2], color[3], color[4]}
		end,
		set = function (self, r, g, b, a) 
			local color = Plater.db.profile.aura_border_colors.is_show_all
			color[1], color[2], color[3], color[4] = r, g, b, a
			Plater.UpdateAllPlates()
		end,
		name = "Important Auras Border Color",
		desc = "Important Auras Border Color",
	},
	{
		type = "color",
		boxfirst = true,
		get = function()
			local color = Plater.db.profile.aura_border_colors.steal_or_purge
			return {color[1], color[2], color[3], color[4]}
		end,
		set = function (self, r, g, b, a) 
			local color = Plater.db.profile.aura_border_colors.steal_or_purge
			color[1], color[2], color[3], color[4] = r, g, b, a
			Plater.UpdateAllPlates()
		end,
		name = "Dispellable Buffs Border Color",
		desc = "Dispellable Buffs Border Color",
	},
	{
		type = "color",
		boxfirst = true,
		get = function()
			local color = Plater.db.profile.aura_border_colors.enrage
			return {color[1], color[2], color[3], color[4]}
		end,
		set = function (self, r, g, b, a) 
			local color = Plater.db.profile.aura_border_colors.enrage
			color[1], color[2], color[3], color[4] = r, g, b, a
			Plater.UpdateAllPlates()
		end,
		name = "Enrage Buffs Border Color",
		desc = "Enrage Buffs Border Color",
	},
	--border color is buff
	{
		type = "color",
		boxfirst = true,
		get = function()
			local color = Plater.db.profile.aura_border_colors.is_buff
			return {color[1], color[2], color[3], color[4]}
		end,
		set = function (self, r, g, b, a) 
			local color = Plater.db.profile.aura_border_colors.is_buff
			color[1], color[2], color[3], color[4] = r, g, b, a
			Plater.UpdateAllPlates()
		end,
		name = "Buffs Border Color",
		desc = "Buffs Border Color",
	},
	--border color is offensive
	{
		type = "color",
		boxfirst = true,
		get = function()
			local color = Plater.db.profile.aura_border_colors.crowdcontrol
			return {color[1], color[2], color[3], color[4]}
		end,
		set = function (self, r, g, b, a) 
			local color = Plater.db.profile.aura_border_colors.crowdcontrol
			color[1], color[2], color[3], color[4] = r, g, b, a
			Plater.UpdateAllPlates()
		end,
		name = "Crowd Control Border Color",
		desc = "Crowd Control Border Color",
	},
	--border color is offensive
	{
		type = "color",
		boxfirst = true,
		get = function()
			local color = Plater.db.profile.aura_border_colors.offensive
			return {color[1], color[2], color[3], color[4]}
		end,
		set = function (self, r, g, b, a) 
			local color = Plater.db.profile.aura_border_colors.offensive
			color[1], color[2], color[3], color[4] = r, g, b, a
			Plater.UpdateAllPlates()
		end,
		name = "Offensive CD Border Color",
		desc = "Offensive CD Border Color",
	},
	--border color is offensive
	{
		type = "color",
		boxfirst = true,
		get = function()
			local color = Plater.db.profile.aura_border_colors.defensive
			return {color[1], color[2], color[3], color[4]}
		end,
		set = function (self, r, g, b, a) 
			local color = Plater.db.profile.aura_border_colors.defensive
			color[1], color[2], color[3], color[4] = r, g, b, a
			Plater.UpdateAllPlates()
		end,
		name = "Defensive CD Border Color",
		desc = "Defensive CD Border Color",
	},
	--border color is default
	{
		type = "color",
		boxfirst = true,
		get = function()
			local color = Plater.db.profile.aura_border_colors.default
			return {color[1], color[2], color[3], color[4]}
		end,
		set = function (self, r, g, b, a) 
			local color = Plater.db.profile.aura_border_colors.default
			color[1], color[2], color[3], color[4] = r, g, b, a
			Plater.UpdateAllPlates()
		end,
		name = "Default Border Color",
		desc = "Default Border Color",
	},
	
	{
		type = "toggle",
		boxfirst = true,
		get = function() return Plater.db.profile.aura_border_colors_by_type end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.aura_border_colors_by_type = value
			Plater.RefreshDBUpvalues()
			Plater.UpdateAllPlates()
			Plater.RefreshAuras()
		end,
		name = "Use type based aura border colors",
		desc = "Use the Blizzard debuff type colors for borders",
	},	
	
	{type = "breakline"},
	
	{type = "label", get = function() return "Auras per Row:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
	{
		type = "toggle",
		boxfirst = true,
		get = function() return Plater.db.profile.auras_per_row_auto end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.auras_per_row_auto = value
			Plater.RefreshDBUpvalues()
			Plater.RefreshAuras()
			Plater.UpdateAllPlates()
		end,
		name = "Automatic",
		desc = "When enabled auras are split into rows automatically according to healthbar width when growing left/right. Mods can overwrite the amount.",
	},
	{
		type = "range",
		get = function() return Plater.db.profile.auras_per_row_amount end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.auras_per_row_amount = value
			Plater.RefreshDBUpvalues()
			Plater.RefreshAuras()
			Plater.UpdateAllPlates()
		end,
		min = 1,
		max = 10,
		step = 1,
		name = "Auras per Row 1",
		desc = "Auras per Row if auto-mode is disabled for Aura Frame 1.",
	},
		{
		type = "range",
		get = function() return Plater.db.profile.auras_per_row_amount2 end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.auras_per_row_amount2 = value
			Plater.RefreshDBUpvalues()
			Plater.RefreshAuras()
			Plater.UpdateAllPlates()
		end,
		min = 1,
		max = 10,
		step = 1,
		name = "Auras per Row 2",
		desc = "Auras per Row if auto-mode is disabled for Aura Frame 2.",
	},
	
	{type = "break"},
	{type = "label", get = function() return "Aura Timer:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
	
	{
		type = "toggle",
		boxfirst = true,
		get = function() return Plater.db.profile.aura_timer end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.aura_timer = value
			Plater.RefreshAuras()
			Plater.UpdateAllPlates()
		end,
		name = "OPTIONS_ENABLED",
		desc = "Time left on buff or debuff.",
	},
	
	{
		type = "toggle",
		boxfirst = true,
		get = function() return Plater.db.profile.aura_timer_decimals end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.aura_timer_decimals = value
			Plater.RefreshAuras()
			Plater.UpdateAllPlates()
		end,
		name = "Show Decimals",
		desc = "Show decimals below 10s remaining time",
	},

	{
		type = "toggle",
		boxfirst = true,
		get = function() return Plater.db.profile.disable_omnicc_on_auras end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.disable_omnicc_on_auras = value
			Plater.RefreshOmniCCGroup()
		end,
		name = "Hide OmniCC/TullaCC Timer",
		desc = "OmniCC/TullaCC timers won't show in the aura.\n\n" .. ImportantText .. "require /reload when toggling this feature.",
	},
	
	{
		type = "select",
		get = function() return Plater.db.profile.aura_timer_text_font end,
		values = function() return DF:BuildDropDownFontList (on_select_auratimer_text_font) end,
		name = "OPTIONS_FONT",
		desc = "OPTIONS_TEXT_FONT",
	},
	{
		type = "range",
		get = function() return Plater.db.profile.aura_timer_text_size end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.aura_timer_text_size = value
			Plater.RefreshAuras()
			Plater.UpdateAllPlates()
		end,
		min = 7,
		max = 40,
		step = 1,
		name = "OPTIONS_SIZE",
		desc = "Size",
	},
	
	--text outline options
	{
		type = "select",
		get = function() return Plater.db.profile.aura_timer_text_outline end,
		values = function() return build_outline_modes_table (nil, "aura_timer_text_outline") end,
		name = "OPTIONS_OUTLINE",
		desc = "OPTIONS_OUTLINE",
	},
	
	--text shadow color
	{
		type = "color",
		boxfirst = true,
		get = function()
			local color = Plater.db.profile.aura_timer_text_shadow_color
			return {color[1], color[2], color[3], color[4]}
		end,
		set = function (self, r, g, b, a) 
			local color = Plater.db.profile.aura_timer_text_shadow_color
			color[1], color[2], color[3], color[4] = r, g, b, a
			Plater.UpdateAllPlates()
		end,
		name = "OPTIONS_SHADOWCOLOR",
		desc = "OPTIONS_TOGGLE_TO_CHANGE",
	},

	
	{
		type = "color",
		boxfirst = true,
		get = function()
			local color = Plater.db.profile.aura_timer_text_color
			return {color[1], color[2], color[3], color[4]}
		end,
		set = function (self, r, g, b, a) 
			local color = Plater.db.profile.aura_timer_text_color
			color[1], color[2], color[3], color[4] = r, g, b, a
			Plater.UpdateAllPlates()
		end,
		name = "OPTIONS_COLOR",
		desc = "Color",
	},
	{
		type = "select",
		get = function() return Plater.db.profile.aura_timer_text_anchor.side end,
		values = function() return build_anchor_side_table (nil, "aura_timer_text_anchor") end,
		name = "OPTIONS_ANCHOR",
		desc = "Which side of the buff icon the timer should attach to.",
	},
	{
		type = "range",
		get = function() return Plater.db.profile.aura_timer_text_anchor.x end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.aura_timer_text_anchor.x = value
			Plater.UpdateAllPlates()
		end,
		min = -20,
		max = 20,
		step = 1,
		usedecimals = true,
		name = "OPTIONS_XOFFSET",
		desc = "OPTIONS_XOFFSET_DESC",
	},
	--y offset
	{
		type = "range",
		get = function() return Plater.db.profile.aura_timer_text_anchor.y end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.aura_timer_text_anchor.y = value
			Plater.UpdateAllPlates()
		end,
		min = -20,
		max = 20,
		step = 1,
		usedecimals = true,
		name = "OPTIONS_YOFFSET",
		desc = "OPTIONS_YOFFSET_DESC",
	},
	
	{type = "blank"},
	{type = "label", get = function() return "Swipe Animation:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
	{
		type = "select",
		get = function() return Plater.db.profile.aura_cooldown_edge_texture end,
		values = function() return cooldown_edge_texture_selected_options end,
		name = "Swipe Texture",
		desc = "Texture in the form of a line which rotates within the aura icon following the aura remaining time.",
	},
	{
		type = "toggle",
		boxfirst = true,
		get = function() return Plater.db.profile.aura_cooldown_show_swipe end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.aura_cooldown_show_swipe = value
			Plater.IncreaseRefreshID()
			Plater.UpdateAllPlates()
		end,
		name = "Show Swipe Closure Texture",
		desc = "Show a layer with a dark texture above the icon. This layer is applied or removed as the swipe moves.",
	},
	{
		type = "toggle",
		boxfirst = true,
		get = function() return Plater.db.profile.aura_cooldown_reverse end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.aura_cooldown_reverse = value
			Plater.IncreaseRefreshID()
			Plater.UpdateAllPlates()
		end,
		name = "Swipe Closure Inverted",
		desc = "If enabled the swipe closure texture is applied as the swipe moves instead.",
	},
}

if IS_WOW_PROJECT_CLASSIC_ERA then
	tinsert(debuff_options, 5, {
		type = "toggle",
		boxfirst = true,
		get = function() return Plater.db.profile.auras_experimental_update_classic_era end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.auras_experimental_update_classic_era = value
			Plater.RefreshAuraCache()
		end,
		name = "Enable experimental aura updates",
		desc = "Enable experimental aura updates for classic era.\nMight help in tracking enemy buffs that are applied while the nameplate is visible.",
	})
end

_G.C_Timer.After(0.850, function() --~delay
	debuff_options.always_boxfirst = true
	debuff_options.language_addonId = addonId

	debuff_options.align_as_pairs = true
	debuff_options.align_as_pairs_string_space = 181
	debuff_options.widget_width = 150

    local canvasFrame = DF:CreateCanvasScrollBox(auraOptionsFrame, nil, "PlaterOptionsPanelCanvasAuraSettings")
    canvasFrame:SetPoint("topleft", auraOptionsFrame, "topleft", 0, platerInternal.optionsYStart)
    canvasFrame:SetPoint("bottomright", auraOptionsFrame, "bottomright", -26, 25)
	auraOptionsFrame.canvasFrame = canvasFrame

	debuff_options.use_scrollframe = true

	--when passing a canvas frame for BuildMenu, it automatically get its childscroll and use as parent for the widgets
	debuff_options.Name = "Debuff Options"
	DF:BuildMenu(canvasFrame, debuff_options, startX, 0, heightSize, false, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template, globalCallback)

	--DF:DebugVisibility(canvasFrame:GetScrollChild())
end)

auraOptionsFrame.AuraTesting = {
	DEBUFF = {
		{
			SpellName = "Shadow Word: Pain",
			SpellTexture = 136207,
			Count = 1,
			Duration = 7,
			SpellID = 589,
			Type = "Magic",
		},
		{
			SpellName = "Vampiric Touch",
			SpellTexture = 135978,
			Count = 1,
			Duration = 5,
			SpellID = 34914,
			Type = "Magic",
		},
		{
			SpellName = "Mind Flay",
			SpellTexture = 136208,
			Count = 3,
			Duration = 5,
			SpellID = 15407,
			Type = "Magic",
		},
		{
			SpellName = "Enrage",
			SpellTexture = 132345,
			Count = 1,
			Duration = 0,
			SpellID = 228318,
			Type = "",
		},
	},
	
	BUFF = {
		{
			SpellName = "Twist of Fate",
			SpellTexture = 237566,
			Count = 1,
			Duration = 9,
			SpellID = 123254,
		},
		{
			SpellName = "Empty Mind",
			SpellTexture = 136206,
			Count = 4,
			Duration = 7,
			SpellID = 247226,
		},
	}
}

Plater.CreateAuraTesting()

----------------------------------------------------------------------------------------------------------------------------------------------------------------
--> aura tracking

-- ~aura ~bufftracking ~debuff ~tracking
	
	local aura_options = {
		width = 200,
		height = 343, 
		row_height = 16,
		button_text_template = "PLATER_BUTTON", --text template
		font_size = 11,
	}
	 
	local method_change_callback = function()
		Plater.RefreshDBUpvalues()
	end
	
	local debuff_panel_texts = {
		BUFFS_AVAILABLE = "Click to add buffs to blacklist",
		DEBUFFS_AVAILABLE = "Click to add debuffs to blacklist",
		BUFFS_IGNORED = "BUFFS on the BLACKLIST (filtered out)",
		DEBUFFS_IGNORED = "DEBUFFS on the BLACKLIST (filtered out)",
		BUFFS_TRACKED = "Additional BUFFS to TRACK",
		DEBUFFS_TRACKED = "Additional DEBUFFS to TRACK",
		MANUAL_DESC = "Auras are being tracked manually, the addon only check for auras you entered below.\nShow debuffs only casted by you, buffs from any source.\nYou may use the 'Buff Special' tab to add debuffs from any source.",
	}
	
	auraFilterFrame:SetSize (f:GetWidth(), f:GetHeight() + startY)

	auraFilterFrame:SetScript("OnShow", function()
		DF:LoadSpellCache(Plater.SpellHashTable, Plater.SpellIndexTable, Plater.SpellSameNameTable)
	end)
	auraFilterFrame:SetScript("OnHide", function()
		--DF:UnloadSpellCache()
	end)
	
	local auraConfigPanel = DF:CreateAuraConfigPanel (auraFilterFrame, "$parentAuraConfig", Plater.db.profile, method_change_callback, aura_options, debuff_panel_texts)
	auraConfigPanel:SetPoint ("topleft", auraFilterFrame, "topleft", 10, startY)
	auraConfigPanel:SetSize (f:GetWidth() - 20, f:GetHeight() + startY)
	auraConfigPanel:Show()
	auraFilterFrame.auraConfigPanel = auraConfigPanel
	
	--create bottom highlights
	local debuffBackList = _G.PlaterOptionsPanelContainerDebuffBlacklistAuraConfig_AutomaticDebuffIgnored
	debuffBackList.bottomTexture = debuffBackList:CreateTexture(nil, "artwork")
	debuffBackList.bottomTexture:SetTexture([[Interface\AddOns\Plater\images\selection_indicator3]])
	debuffBackList.bottomTexture:SetPoint("topleft", debuffBackList, "bottomleft", -12, 0)
	debuffBackList.bottomTexture:SetPoint("topright", debuffBackList, "bottomright", 12, 0)
	debuffBackList.bottomTexture:SetBlendMode("ADD")
	debuffBackList.bottomTexture:SetTexCoord(0, 1, 1, 0)
	debuffBackList.bottomTexture:SetVertexColor(1, .1, 0, 0.2)

	local buffBackList = _G.PlaterOptionsPanelContainerDebuffBlacklistAuraConfig_AutomaticBuffIgnored
	buffBackList.bottomTexture = buffBackList:CreateTexture(nil, "artwork")
	buffBackList.bottomTexture:SetTexture([[Interface\AddOns\Plater\images\selection_indicator3]])
	buffBackList.bottomTexture:SetPoint("topleft", buffBackList, "bottomleft", -12, 0)
	buffBackList.bottomTexture:SetPoint("topright", buffBackList, "bottomright", 12, 0)
	buffBackList.bottomTexture:SetBlendMode("ADD")
	buffBackList.bottomTexture:SetTexCoord(0, 1, 1, 0)
	buffBackList.bottomTexture:SetVertexColor(1, .1, 0, 0.2)

	local debuffTrackList = _G.PlaterOptionsPanelContainerDebuffBlacklistAuraConfig_AutomaticDebuffTracked
	debuffTrackList.bottomTexture = debuffTrackList:CreateTexture(nil, "artwork")
	debuffTrackList.bottomTexture:SetTexture([[Interface\AddOns\Plater\images\selection_indicator3]])
	debuffTrackList.bottomTexture:SetPoint("topleft", debuffTrackList, "bottomleft", -12, 0)
	debuffTrackList.bottomTexture:SetPoint("topright", debuffTrackList, "bottomright", 12, 0)
	debuffTrackList.bottomTexture:SetBlendMode("ADD")
	debuffTrackList.bottomTexture:SetTexCoord(0, 1, 1, 0)
	debuffTrackList.bottomTexture:SetVertexColor(0, .1, 1, 0.2)

	local buffTrackList = _G.PlaterOptionsPanelContainerDebuffBlacklistAuraConfig_AutomaticBuffTracked
	buffTrackList.bottomTexture = buffTrackList:CreateTexture(nil, "artwork")
	buffTrackList.bottomTexture:SetTexture([[Interface\AddOns\Plater\images\selection_indicator3]])
	buffTrackList.bottomTexture:SetPoint("topleft", buffTrackList, "bottomleft", -12, 0)
	buffTrackList.bottomTexture:SetPoint("topright", buffTrackList, "bottomright", 12, 0)
	buffTrackList.bottomTexture:SetBlendMode("ADD")
	buffTrackList.bottomTexture:SetTexCoord(0, 1, 1, 0)
	buffTrackList.bottomTexture:SetVertexColor(0, .1, 1, 0.2)
	
	function auraFilterFrame.RefreshOptions()
		auraConfigPanel:OnProfileChanged (Plater.db.profile)
	end


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> special auras ~special ~aura ~buffspecial
--> special aura container
	local especial_aura_settings
	do 
	
		--> fonts
		local on_select_buff_special_timer_font = function (_, _, value)
			Plater.db.profile.extra_icon_timer_font = value
			Plater.UpdateAllPlates()
		end
		
		local on_select_buff_special_stack_font = function (_, _, value)
			Plater.db.profile.extra_icon_stack_font = value
			Plater.UpdateAllPlates()
		end
		
		local on_select_buff_special_caster_font = function (_, _, value)
			Plater.db.profile.extra_icon_caster_font = value
			Plater.UpdateAllPlates()
		end
	
		--> scroll with auras added to the special aura container
		local specialAuraFrame = CreateFrame ("frame", nil, auraSpecialFrame, BackdropTemplateMixin and "BackdropTemplate")
		specialAuraFrame:SetHeight (480)
		specialAuraFrame:SetPoint ("topleft", auraSpecialFrame, "topleft", startX, startY)
		specialAuraFrame:SetPoint ("topright", auraSpecialFrame, "topright", -10, startY)
		--DF:ApplyStandardBackdrop (specialAuraFrame, false, 0.6)
		
		local scroll_width = 280
		local scroll_height = 442
		local scroll_lines = 21
		local scroll_line_height = 20
		local backdrop_color = {.8, .8, .8, 0.2}
		local backdrop_color_on_enter = {.8, .8, .8, 0.4}
		local y = startY
		
		local showSpellWithSameName = function (self, spellId) 
			local spellName = GetSpellInfo(spellId)
			if (spellName) then
				--replace here with the cache
				local spellNameLower = spellName:lower()
				local spellsWithSameNameCache = Plater.SpellSameNameTable
				local spellsWithSameName = spellsWithSameNameCache[spellNameLower]
				
				if (spellsWithSameName) then
					GameCooltip2:Preset(2)
					GameCooltip2:SetOwner(self, "left", "right", 2, 0)
					GameCooltip2:SetOption("TextSize", 10)
					
					for i, spellID in ipairs(spellsWithSameName) do
						local spellName, _, spellIcon = GetSpellInfo(spellID)
						if (spellName) then
							GameCooltip2:AddLine(spellName .. " (" .. spellID .. ")")
							GameCooltip2:AddIcon(spellIcon, 1, 1, 14, 14, .1, .9, .1, .9)
						end
					end
					
					GameCooltip2:Show()
				end
			end
		end
		
		local line_onenter = function (self)
			self:SetBackdropColor (unpack (backdrop_color_on_enter))
			local spellid = select (7, GetSpellInfo (self.value))
			
			if  not spellid then
				-- if the player class does not know the spell, try checking the cache
				spellid = Plater.SpellHashTable[self.value]
			end
			
			if (spellid) then
				GameTooltip:SetOwner (self, "ANCHOR_TOPLEFT");
				GameTooltip:SetSpellByID (spellid)
				GameTooltip:AddLine (" ")
				GameTooltip:Show()
				
				if not tonumber (self.value) then
					showSpellWithSameName (self, spellid)
				end
			end
		end
		
		local line_onleave = function (self)
			self:SetBackdropColor (unpack (backdrop_color))
			GameTooltip:Hide()
			GameCooltip2:Hide()
		end
		
		local onclick_remove_button = function (self)
			local spell = self:GetParent().value
			local data = self:GetParent():GetParent():GetData()
			
			for i = 1, #data do
				if (data[i] == spell) then
					tremove (data, i)
					break
				end
			end
			
			self:GetParent():GetParent():Refresh()
			Plater.RefreshDBUpvalues()
		end
		
		local on_toggle_mine = function (self, spellID, state)
			Plater.db.profile.extra_icon_auras_mine [spellID] = state
			Plater.RefreshDBLists()
		end
		
		local scroll_createline = function (self, index)
			local line = CreateFrame ("button", "$parentLine" .. index, self, BackdropTemplateMixin and "BackdropTemplate")
			line:SetPoint ("topleft", self, "topleft", 1, -((index-1)*(scroll_line_height+1)) - 1)
			line:SetSize (scroll_width - 2, scroll_line_height)
			line:SetScript ("OnEnter", line_onenter)
			line:SetScript ("OnLeave", line_onleave)
			
			line:SetBackdrop ({bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
			line:SetBackdropColor (unpack (backdrop_color))
			
			local icon = line:CreateTexture ("$parentIcon", "overlay")
			icon:SetSize (scroll_line_height - 2, scroll_line_height - 2)
			
			local name = line:CreateFontString ("$parentName", "overlay", "GameFontNormal")

			local remove_button = CreateFrame ("button", "$parentRemoveButton", line, "UIPanelCloseButton, BackdropTemplate")
			remove_button:SetSize (21, 21)
			remove_button:SetScript ("OnClick", onclick_remove_button)
			remove_button:SetPoint ("right", line, "right", -6, 0)
			remove_button:SetNormalTexture([[Interface\GLUES\LOGIN\Glues-CheckBox-Check]])
			remove_button:SetPushedTexture([[Interface\GLUES\LOGIN\Glues-CheckBox-Check]])
			remove_button:GetNormalTexture():SetDesaturated (true)
			remove_button:GetPushedTexture():SetDesaturated (true)
			remove_button:GetPushedTexture():ClearAllPoints()
			remove_button:GetPushedTexture():SetPoint ("center")
			remove_button:GetPushedTexture():SetSize (18, 18)
			
			local onlyMineCheckbox = DF:CreateSwitch (line, on_toggle_mine, true, _, _, _, _, "mineCheckbox", "$parentMineToggle" .. index, _, _, _, nil, DF:GetTemplate ("switch", "OPTIONS_CHECKBOX_BRIGHT_TEMPLATE"))
			onlyMineCheckbox:SetAsCheckBox()
			onlyMineCheckbox:SetPoint ("right", remove_button, "left", -22, 0)
			
			icon:SetPoint ("left", line, "left", 2, 0)
			name:SetPoint ("left", icon, "right", 2, 0)
			
			line.icon = icon
			line.name = name
			line.removebutton = remove_button
			line.mineCheckbox = onlyMineCheckbox
			
			return line
		end

		local scroll_refresh = function (self, data, offset, total_lines)
			local needsRefresh
			for i = 1, total_lines do
				local index = i + offset
				local aura = data [index]
				if (aura) then
					local line = self:GetLine (i)
					local spellName, _, spellIcon = GetSpellInfo (aura)
					line.value = aura
					
					if not spellName then
						-- if the player class does not know the spell, try checking the cache
						-- avoids "unknown spell" in this case
						local id = Plater.SpellHashTable[lower(aura)]
						spellName, _, spellIcon = GetSpellInfo (id)
					end
					
					if (spellName) then
						line.name:SetText (spellName)
						line.icon:SetTexture (spellIcon)
						line.icon:SetTexCoord (.1, .9, .1, .9)
						line.mineCheckbox:SetFixedParameter (aura)
						line.mineCheckbox:SetValue (Plater.db.profile.extra_icon_auras_mine [aura] or false)
					else
						line.name:SetText ("unknown aura")
						line.icon:SetTexture ("")
						line.icon:SetTexture ([[Interface\InventoryItems\WoWUnknownItem01]])
						needsRefresh = true
					end
				end
			end
			if needsRefresh then
				C_Timer.After(1, function() self:Refresh() end)
			end
		end
		
		local special_auras_added = DF:CreateScrollBox (specialAuraFrame, "$parentSpecialAurasAdded", scroll_refresh, Plater.db.profile.extra_icon_auras, scroll_width, scroll_height, scroll_lines, scroll_line_height)
		DF:ReskinSlider (special_auras_added)
		special_auras_added.__background:SetAlpha (.4)
		special_auras_added:SetPoint ("topleft", specialAuraFrame, "topleft", 0, -40)
		
		local title = DF:CreateLabel (specialAuraFrame, "Special Auras:", DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"))
		DF:SetFontSize (title, 12)
		title:SetPoint ("bottomleft", special_auras_added, "topleft", 0, 2)
		
		local removeLabel = DF:CreateLabel (specialAuraFrame, "remove", DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"))
		--DF:SetFontSize (title, 12)
		removeLabel:SetPoint ("bottomright", special_auras_added, "topright", 0, 2)
		
		local onlyMineLabel = DF:CreateLabel (specialAuraFrame, "only mine", DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"))
		--DF:SetFontSize (title, 12)
		onlyMineLabel:SetPoint ("bottomright", special_auras_added, "topright", -40, 2)
		
		for i = 1, scroll_lines do 
			special_auras_added:CreateLine (scroll_createline)
		end
		
		--> text entry to input the aura name
		local new_buff_string = DF:CreateLabel (specialAuraFrame, "Add Special Aura", DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"))
		DF:SetFontSize (new_buff_string, 12)
		
		local new_buff_entry = DF:CreateTextEntry (specialAuraFrame, function()end, 200, 20, "NewSpecialAuraTextBox", _, _, options_dropdown_template)
		new_buff_entry.tooltip = "Enter the aura name using lower case letters or spell-IDs.\n\nYou can add several spells at once using |cFFFFFF00;|r to separate each spell name."
		new_buff_entry:SetJustifyH ("left")
		
		new_buff_entry:SetHook ("OnEditFocusGained", function (self, capsule)
			new_buff_entry.SpellAutoCompleteList = Plater.SpellIndexTable
			new_buff_entry:SetAsAutoComplete ("SpellAutoCompleteList", nil, true)
		end)
		
		new_buff_entry.GetSpellIDFromString = function (text)
			--check if the user entered a spell ID
			local isSpellID = tonumber (text)
			if (isSpellID and isSpellID > 1 and isSpellID < 10000000) then
				local isValidSpellID = GetSpellInfo (isSpellID)
				if (isValidSpellID) then
					return isSpellID
				else
					return
				end
			end
			
			--get the spell ID from the spell name
			local lowertext = lower (text)
			local spellID = Plater.SpellHashTable [lowertext]
			if (not spellID) then
				return
			end
			
			-- ensure proper name (case sensitive)
			text = GetSpellInfo (spellID)
			
			return text
		end		
		
		--> add aura button
		local add_buff_button = DF:CreateButton (specialAuraFrame, function()
		
			local text = new_buff_entry.text
			new_buff_entry:SetText ("")
			new_buff_entry:ClearFocus()
			
			if (text ~= "") then
				--> check for more than one spellname
				if (text:find (";")) then
					for _, spellName in ipairs ({strsplit (";", text)}) do
						spellName = DF:trim (spellName)
						local spellID = new_buff_entry.GetSpellIDFromString (spellName)

						if (spellID) then
							tinsert (Plater.db.profile.extra_icon_auras, spellID)
						else
							print ("spellId not found for spell:", spellName)
						end
					end
				else
					--get the spellId
					local spellID = new_buff_entry.GetSpellIDFromString (text)
					if (not spellID) then
						print ("spellID for spell ", text, "not found")
						return
					end
				
					tinsert (Plater.db.profile.extra_icon_auras, spellID)
				end
				
				special_auras_added:Refresh()
				Plater.RefreshDBUpvalues()
			end
			
		end, 100, 20, "Add Aura", nil, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"))		

		new_buff_entry:SetPoint ("topleft",  special_auras_added, "topright", 40, 0)
		new_buff_string:SetPoint ("bottomleft", new_buff_entry, "topleft", 0, 2)
		add_buff_button:SetPoint ("topleft", new_buff_entry, "bottomleft", 0, -2)
		add_buff_button.tooltip = "Add the aura to be tracked."
		
		--
		especial_aura_settings = {
			{type = "blank"},
			{type = "blank"},
			{type = "blank"},
			{type = "blank"},
			{type = "blank"},
			{type = "blank"},
			{type = "blank"},
			{type = "blank"},
			{type = "blank"},
			{type = "label", get = function() return "Icon Settings:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
			--anchor
			{
				type = "select",
				get = function() return Plater.db.profile.extra_icon_anchor.side end,
				values = function() return build_anchor_side_table (false, "extra_icon_anchor") end,
				name = "OPTIONS_ANCHOR",
				desc = "OPTIONS_ANCHOR_TARGET_SIDE",
			},
			--x offset
			{
				type = "range",
				get = function() return Plater.db.profile.extra_icon_anchor.x end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.extra_icon_anchor.x = value
					Plater.UpdateAllPlates()
				end,
				min = -100,
				max = 100,
				step = 1,
				usedecimals = true,
				name = "OPTIONS_XOFFSET",
				desc = "Slightly move horizontally.",
			},
			--y offset
			{
				type = "range",
				get = function() return Plater.db.profile.extra_icon_anchor.y end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.extra_icon_anchor.y = value
					Plater.UpdateAllPlates()
				end,
				min = -100,
				max = 100,
				step = 1,
				usedecimals = true,
				name = "OPTIONS_YOFFSET",
				desc = "Slightly move vertically.",
			},
			--width
			{
				type = "range",
				get = function() return Plater.db.profile.extra_icon_width end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.extra_icon_width = value
					Plater.UpdateAllPlates()
				end,
				min = 8,
				max = 128,
				step = 1,
				name = "OPTIONS_WIDTH",
				desc = "OPTIONS_WIDTH",
			},
			--height
			{
				type = "range",
				get = function() return Plater.db.profile.extra_icon_height end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.extra_icon_height = value
					Plater.UpdateAllPlates()
				end,
				min = 8,
				max = 128,
				step = 1,
				name = "OPTIONS_HEIGHT",
				desc = "OPTIONS_HEIGHT",
			},
			--border size
			{
				type = "range",
				get = function() return Plater.db.profile.extra_icon_border_size end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.extra_icon_border_size = value
				end,
				min = 0,
				max = 10,
				step = 1,
				name = "OPTIONS_BORDER_THICKNESS",
				desc = "Border Thickness" .. CVarNeedReload,
			},
			--wide icons
			{
				type = "toggle",
				get = function() return Plater.db.profile.extra_icon_wide_icon end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.extra_icon_wide_icon = value
					Plater.UpdateAllPlates()
				end,
				name = "Wide Icons",
				desc = "Wide Icons",
			},
			--use blizzard border colors
			{
				type = "toggle",
				get = function() return Plater.db.profile.extra_icon_use_blizzard_border_color end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.extra_icon_use_blizzard_border_color = value
					Plater.UpdateAllPlates()
				end,
				name = "Use Blizzard border colors",
				desc = "Use Blizzard border colors if enabled or the below defined default border color if disabled.",
			},
			--border color
			{
				type = "color",
				get = function()
					local color = Plater.db.profile.extra_icon_border_color
					return {color[1], color[2], color[3], color[4]}
				end,
				set = function (self, r, g, b, a) 
					local color = Plater.db.profile.extra_icon_border_color
					color[1], color[2], color[3], color[4] = r, g, b, a
					Plater.UpdateAllPlates()
				end,
				name = "Default Border Color",
				desc = "Default Border Color",
			},
			{
				type = "select",
				get = function() return Plater.db.profile.extra_icon_cooldown_edge_texture end,
				values = function() return extra_icon_cooldown_edge_texture_selected_options end,
				name = "Swipe Texture",
				desc = "Texture in the form of a line which rotates within the aura icon following the aura remaining time.",
			},
			{
				type = "toggle",
				get = function() return Plater.db.profile.extra_icon_show_swipe end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.extra_icon_show_swipe = value
					Plater.UpdateAllPlates()
				end,
				name = "Show Swipe Closure Texture",
				desc = "If enabled the swipe closure texture is applied as the swipe moves instead.",
			},
			{
				type = "toggle",
				get = function() return Plater.db.profile.extra_icon_cooldown_reverse end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.extra_icon_cooldown_reverse = value
					Plater.UpdateAllPlates()
				end,
				name = "Swipe Closure Inverted",
				desc = "If enabled the swipe closure texture is applied as the swipe moves instead.",
			},
			
			{type = "breakline"},
			--{type = "label", get = function() return "Text Settings:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
			--show timer
			{
				type = "toggle",
				get = function() return Plater.db.profile.extra_icon_show_timer end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.extra_icon_show_timer = value
					Plater.UpdateAllPlates()
				end,
				name = "Show Timer",
				desc = "Show Timer",
			},
			{
				type = "toggle",
				get = function() return Plater.db.profile.extra_icon_timer_decimals end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.extra_icon_timer_decimals = value
					Plater.UpdateAllPlates()
				end,
				name = "Show Decimals",
				desc = "Show decimals below 10s remaining time",
			},
			{
				type = "select",
				get = function() return Plater.db.profile.extra_icon_timer_font end,
				values = function() return DF:BuildDropDownFontList (on_select_buff_special_timer_font) end,
				name = "OPTIONS_FONT",
				desc = "OPTIONS_TEXT_FONT",
			},
			{
				type = "range",
				get = function() return Plater.db.profile.extra_icon_timer_size end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.extra_icon_timer_size = value
					Plater.UpdateAllPlates()
				end,
				min = 6,
				max = 99,
				step = 1,
				name = "OPTIONS_SIZE",
				desc = "OPTIONS_TEXT_SIZE",
			},
			--text outline options
			{
				type = "select",
				get = function() return Plater.db.profile.extra_icon_timer_outline end,
				values = function() return build_outline_modes_table (nil, "extra_icon_timer_outline") end,
				name = "OPTIONS_OUTLINE",
				desc = "OPTIONS_OUTLINE",
			},

			--show caster name
			{
				type = "toggle",
				get = function() return Plater.db.profile.extra_icon_caster_name end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.extra_icon_caster_name = value
					Plater.UpdateAllPlates()
				end,
				name = "Show Caster Name",
				desc = "Show Caster Name (if player)",
			},
			{
				type = "select",
				get = function() return Plater.db.profile.extra_icon_caster_font end,
				values = function() return DF:BuildDropDownFontList (on_select_buff_special_caster_font) end,
				name = "OPTIONS_FONT",
				desc = "OPTIONS_TEXT_FONT",
			},
			{
				type = "range",
				get = function() return Plater.db.profile.extra_icon_caster_size end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.extra_icon_caster_size = value
					Plater.UpdateAllPlates()
				end,
				min = 6,
				max = 99,
				step = 1,
				name = "OPTIONS_SIZE",
				desc = "OPTIONS_TEXT_SIZE",
			},
			--text outline options
			{
				type = "select",
				get = function() return Plater.db.profile.extra_icon_caster_outline end,
				values = function() return build_outline_modes_table (nil, "extra_icon_caster_outline") end,
				name = "OPTIONS_OUTLINE",
				desc = "OPTIONS_OUTLINE",
			},
			
			--show stacks
			{
				type = "toggle",
				get = function() return Plater.db.profile.extra_icon_show_stacks end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.extra_icon_show_stacks = value
					Plater.UpdateAllPlates()
				end,
				name = "Show Stacks",
				desc = "Show Stacks",
			},
						{
				type = "select",
				get = function() return Plater.db.profile.extra_icon_stack_font end,
				values = function() return DF:BuildDropDownFontList (on_select_buff_special_stack_font) end,
				name = "OPTIONS_FONT",
				desc = "OPTIONS_TEXT_FONT",
			},
			{
				type = "range",
				get = function() return Plater.db.profile.extra_icon_stack_size end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.extra_icon_stack_size = value
					Plater.UpdateAllPlates()
				end,
				min = 6,
				max = 99,
				step = 1,
				name = "OPTIONS_SIZE",
				desc = "OPTIONS_TEXT_SIZE",
			},
			--text outline options
			{
				type = "select",
				get = function() return Plater.db.profile.extra_icon_stack_outline end,
				values = function() return build_outline_modes_table (nil, "extra_icon_stack_outline") end,
				name = "OPTIONS_OUTLINE",
				desc = "OPTIONS_OUTLINE",
			},
			
			{type = "blank"},
			
			{type = "label", get = function() return "Auto Add These Types of Auras:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
			
			--show crowd control auras
			{
				type = "toggle",
				get = function() return Plater.db.profile.debuff_show_cc end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.debuff_show_cc = value
					Plater.RefreshDBUpvalues()
					Plater.UpdateAllPlates()
				end,
				name = "Crowd Control",
				desc = "When the unit has a crowd control spell (such as Polymorph).",
			},
			--show purge icons
			{
				type = "toggle",
				get = function() return Plater.db.profile.extra_icon_show_purge end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.extra_icon_show_purge = value
					Plater.RefreshDBUpvalues()
					Plater.UpdateAllPlates()
				end,
				name = "Dispellable",
				desc = "When the unit has an aura which can be dispellable or purge by you",
			},
			--show enrages
			{
				type = "toggle",
				get = function() return Plater.db.profile.extra_icon_show_enrage end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.extra_icon_show_enrage = value
					Plater.RefreshDBUpvalues()
					Plater.UpdateAllPlates()
				end,
				name = "Enrage",
				desc = "When the unit has an enrage effect on it, show it.",
			},
			--show enrages
			{
				type = "toggle",
				get = function() return Plater.db.profile.extra_icon_show_magic end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.extra_icon_show_magic = value
					Plater.RefreshDBUpvalues()
					Plater.UpdateAllPlates()
				end,
				name = "Magic",
				desc = "When the unit has a magic buff on it, show it.",
			},
			--show offensive CDs
			{
				type = "toggle",
				get = function() return Plater.db.profile.extra_icon_show_offensive end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.extra_icon_show_offensive = value
					Plater.RefreshDBUpvalues()
					Plater.UpdateAllPlates()
				end,
				name = "Offensive player CDs",
				desc = "When the unit has an offensive effect on it, show it.",
			},
			--show defensive CDs
			{
				type = "toggle",
				get = function() return Plater.db.profile.extra_icon_show_defensive end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.extra_icon_show_defensive = value
					Plater.RefreshDBUpvalues()
					Plater.UpdateAllPlates()
				end,
				name = "Defensive player CDs",
				desc = "When the unit has a defensive effect on it, show it.",
			},
			
			{type = "breakline"},
			
			{type = "label", get = function() return "Aura Border Colors:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
			--cc border color
			{
				type = "color",
				get = function()
					local color = Plater.db.profile.debuff_show_cc_border
					return {color[1], color[2], color[3], color[4]}
				end,
				set = function (self, r, g, b, a) 
					local color = Plater.db.profile.debuff_show_cc_border
					color[1], color[2], color[3], color[4] = r, g, b, a
					Plater.UpdateAllPlates()
				end,
				name = "Crowd Control Border Color",
				desc = "Crowd Control Border Color",
			},
			--purge border color
			{
				type = "color",
				get = function()
					local color = Plater.db.profile.extra_icon_show_purge_border
					return {color[1], color[2], color[3], color[4]}
				end,
				set = function (self, r, g, b, a) 
					local color = Plater.db.profile.extra_icon_show_purge_border
					color[1], color[2], color[3], color[4] = r, g, b, a
					Plater.UpdateAllPlates()
				end,
				name = "Dispellable Border Color",
				desc = "Dispellable Border Color",
			},
			--enrage border color
			{
				type = "color",
				get = function()
					local color = Plater.db.profile.extra_icon_show_enrage_border
					return {color[1], color[2], color[3], color[4]}
				end,
				set = function (self, r, g, b, a) 
					local color = Plater.db.profile.extra_icon_show_enrage_border
					color[1], color[2], color[3], color[4] = r, g, b, a
					Plater.UpdateAllPlates()
				end,
				name = "Enrage Border Color",
				desc = "Enrage Border Color",
			},
			--offensive border color
			{
				type = "color",
				get = function()
					local color = Plater.db.profile.extra_icon_show_offensive_border
					return {color[1], color[2], color[3], color[4]}
				end,
				set = function (self, r, g, b, a) 
					local color = Plater.db.profile.extra_icon_show_offensive_border
					color[1], color[2], color[3], color[4] = r, g, b, a
					Plater.UpdateAllPlates()
				end,
				name = "Offensive Border Color",
				desc = "Offensive Border Color",
			},
			--defensive border color
			{
				type = "color",
				get = function()
					local color = Plater.db.profile.extra_icon_show_defensive_border
					return {color[1], color[2], color[3], color[4]}
				end,
				set = function (self, r, g, b, a) 
					local color = Plater.db.profile.extra_icon_show_defensive_border
					color[1], color[2], color[3], color[4] = r, g, b, a
					Plater.UpdateAllPlates()
				end,
				name = "Defensive Border Color",
				desc = "Defensive Border Color",
			},
		
			{type = "blank"},
			--{type = "blank"},
			{type = "label", get = function() return "DBM / BigWigs Icon-Support:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},

			{
				type = "toggle",
				get = function() return Plater.db.profile.bossmod_support_enabled end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.bossmod_support_enabled = value
					Plater.UpdateAllPlates()
				end,
				name = "OPTIONS_ENABLED",
				desc = "Enable the boss mod icon support for BigWigs and DBM.",
			},
			
			{
				type = "toggle",
				get = function() return Plater.db.profile.bossmod_support_bars_enabled end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.bossmod_support_bars_enabled = value
					Plater.UpdateAllPlates()
				end,
				name = "DBM CD-Bar Icons enabled",
				desc = "Enable the boss mod bar support for DBM, to show timer bars as icons on the nameplates.",
			},
			
			{type = "blank"},
			
			{type = "label", get = function() return "Icon Settings:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
			
			--width
			{
				type = "range",
				get = function() return Plater.db.profile.bossmod_aura_width end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.bossmod_aura_width = value
					Plater.UpdateAllPlates()
				end,
				min = 8,
				max = 64,
				step = 1,
				name = "OPTIONS_WIDTH",
				desc = "OPTIONS_WIDTH",
			},
			--height
			{
				type = "range",
				get = function() return Plater.db.profile.bossmod_aura_height end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.bossmod_aura_height = value
					Plater.UpdateAllPlates()
				end,
				min = 8,
				max = 64,
				step = 1,
				name = "OPTIONS_HEIGHT",
				desc = "OPTIONS_HEIGHT",
			},
			
			--anchor
			{
			type = "select",
			get = function() return Plater.db.profile.bossmod_icons_anchor.side end,
			values = function() return build_anchor_side_table (nil, "bossmod_icons_anchor") end,
			name = "OPTIONS_ANCHOR",
			desc = "Which side of the nameplate the icons should attach to.",
			},
			--x offset
			{
				type = "range",
				get = function() return Plater.db.profile.bossmod_icons_anchor.x end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.bossmod_icons_anchor.x = value
					Plater.UpdateAllPlates()
				end,
				min = -40,
				max = 40,
				step = 1,
				usedecimals = true,
				name = "OPTIONS_XOFFSET",
				desc = "OPTIONS_XOFFSET_DESC",
			},
			--y offset
			{
				type = "range",
				get = function() return Plater.db.profile.bossmod_icons_anchor.y end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.bossmod_icons_anchor.y = value
					Plater.UpdateAllPlates()
				end,
				min = -60,
				max = 60,
				step = 1,
				usedecimals = true,
				name = "OPTIONS_YOFFSET",
				desc = "OPTIONS_YOFFSET_DESC",
			},
			--text enabled
			{
				type = "toggle",
				get = function() return Plater.db.profile.bossmod_support_bars_text_enabled end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.bossmod_support_bars_text_enabled = value
					Plater.UpdateAllPlates()
				end,
				name = "Icon text enabled",
				desc = "Enable Bar Text.",
			},
			
			--{type = "blank"},
			
			{type = "label", get = function() return "Cooldown Text:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
			{
				type = "toggle",
				get = function() return Plater.db.profile.bossmod_cooldown_text_enabled end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.bossmod_cooldown_text_enabled = value
					Plater.UpdateAllPlates()
				end,
				name = "OPTIONS_ENABLED",
				desc = "Enable Cooldown Text.",
			},
			--cd text size
			{
				type = "range",
				get = function() return Plater.db.profile.bossmod_cooldown_text_size end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.bossmod_cooldown_text_size = value
					Plater.RefreshAuras()
					Plater.UpdateAllPlates()
				end,
				min = 6,
				max = 32,
				step = 1,
				name = "OPTIONS_SIZE",
				desc = "Size",
			},
		}
		
		auraSpecialFrame.ExampleImageDesc = DF:CreateLabel (auraSpecialFrame, "Special auras look like this:", 14)
		auraSpecialFrame.ExampleImageDesc:SetPoint (330, -235)
		auraSpecialFrame.ExampleImage = DF:CreateImage (auraSpecialFrame, [[Interface\AddOns\Plater\images\extra_icon_example]], 256*0.8, 128*0.8)
		auraSpecialFrame.ExampleImage:SetPoint (330, -249)
		auraSpecialFrame.ExampleImage:SetAlpha (.834)
		
		local fff = CreateFrame ("frame", "$parentExtraIconsSettings", auraSpecialFrame, BackdropTemplateMixin and "BackdropTemplate")
		fff:SetAllPoints()

		_G.C_Timer.After(0.6, function() --~delay
			especial_aura_settings.always_boxfirst = true
			especial_aura_settings.language_addonId = addonId
			especial_aura_settings.Name = "Special Auras Options"
			DF:BuildMenu (fff, especial_aura_settings, 330, startY - 27, heightSize, false, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template, globalCallback)
		end)

		--when the profile has changed
		function auraSpecialFrame:RefreshOptions()
			--update the script data for the scroll and refresh
			special_auras_added:SetData (Plater.db.profile.extra_icon_auras)
			special_auras_added:Refresh()
		end
		
		specialAuraFrame:SetScript ("OnShow", function()
			special_auras_added:Refresh()
			DF:LoadSpellCache(Plater.SpellHashTable, Plater.SpellIndexTable, Plater.SpellSameNameTable)
		end)
		specialAuraFrame:SetScript ("OnHide", function()
			--DF:UnloadSpellCache()
		end)
		
		--create the description
		auraSpecialFrame.TitleDescText = Plater:CreateLabel (auraSpecialFrame, "Track auras adding them to a special buff frame separated from the main buff line. Use it to emphasize important auras from raid bosses or mythic dungeons.", 10, "silver")
		auraSpecialFrame.TitleDescText:SetPoint ("bottomleft", special_auras_added, "topleft", 0, 26)
	end


--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- personal player ~player
local options_personal

do
	local on_select_player_percent_text_font = function (_, _, value)
		Plater.db.profile.plate_config.player.percent_text_font = value
		Plater.UpdateAllPlates()
	end
	
	local on_select_player_power_percent_text_font = function (_, _, value)
		Plater.db.profile.plate_config.player.power_percent_text_font = value
		Plater.UpdateAllPlates()
	end
	
	local on_select_player_npccastname_font = function (_, _, value)
		Plater.db.profile.plate_config.player.spellname_text_font = value
		Plater.UpdateAllPlates()
	end
	
	local on_select_player_spellpercent_text_font = function (_, _, value)
		Plater.db.profile.plate_config.player.spellpercent_text_font = value
		Plater.UpdateAllPlates()
	end
	
	--local _, _, _, iconWindWalker = GetSpecializationInfoByID (269)
	--local _, _, _, iconArcane = GetSpecializationInfoByID (62)
	--local _, _, _, iconRune = GetSpecializationInfoByID (250)
	--local _, _, _, iconHolyPower = GetSpecializationInfoByID (66)
	--local _, _, _, iconRogueCB = GetSpecializationInfoByID (261)
	--local _, _, _, iconDruidCB = GetSpecializationInfoByID (103)
	--local _, _, _, iconSoulShard = GetSpecializationInfoByID (267)
	
	local locClass = UnitClass ("player")
	
	options_personal = {

		{type = "label", get = function() return "General Settings:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		
		{
			type = "select",
			get = function() return "player" end,
			values = function() return copy_settings_options end,
			name = "Copy",
			desc = "Copy settings from another tab.\n\nWhen selecting an option a confirmation box is shown to confirm the copy.",
		},
		
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.player.module_enabled end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.player.module_enabled = value
				ReloadUI()
			end,
			nocombat = true,
			name = "Module Enabled",
			desc = "Enable Plater nameplates for the personal bar.\n\n" .. ImportantText .. "Forces a /reload on change.\nThis option is dependent on the client`s nameplate state (on/off)",
		},
		
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.player.click_through end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.player.click_through = value
				Plater.UpdateSelfPlate()
			end,
			name = "Click Through",
			desc = "Player nameplate won't receive mouse clicks.",
		},
		{
			type = "toggle",
			get = function() return GetCVarBool ("nameplatePersonalShowAlways") end,
			set = function (self, fixedparam, value) 
				if (value) then
					SetCVar ("nameplatePersonalShowAlways", CVAR_ENABLED)
				else
					SetCVar ("nameplatePersonalShowAlways", CVAR_DISABLED)
				end
			end,
			nocombat = true,
			name = "Always Show" .. CVarIcon,
			desc = "If enabled, the personal health bar is always shown.\n\n" .. ImportantText .. "'Personal Health and Mana Bars' (in the Main Menu tab) must be enabled." .. CVarDesc,
		},

		{
			type = "toggle",
			get = function() return GetCVarBool ("nameplatePersonalShowWithTarget") end,
			set = function (self, fixedparam, value) 
				if (value) then
					SetCVar ("nameplatePersonalShowWithTarget", CVAR_ENABLED)
				else
					SetCVar ("nameplatePersonalShowWithTarget", CVAR_DISABLED)
				end
			end,
			nocombat = true,
			name = "Show When you Have a Target" .. CVarIcon,
			desc = "If enabled, show the personal bar when you have a target.\n\n" .. ImportantText .. "'Personal Health and Mana Bars' (in the Main Menu tab) must be enabled." .. CVarDesc,
		},
		{
			type = "toggle",
			get = function() return GetCVarBool ("nameplatePersonalShowInCombat") end,
			set = function (self, fixedparam, value) 
				if (value) then
					SetCVar ("nameplatePersonalShowInCombat", CVAR_ENABLED)
				else
					SetCVar ("nameplatePersonalShowInCombat", CVAR_DISABLED)
				end
			end,
			nocombat = true,
			name = "Show In Combat" .. CVarIcon,
			desc = "If enabled, show the personal bar when you are in combat.\n\n" .. ImportantText .. "'Personal Health and Mana Bars' (in the Main Menu tab) must be enabled." .. CVarDesc,
		},
		{
			type = "range",
			get = function() return tonumber (GetCVar ("nameplateSelfAlpha")) end,
			set = function (self, fixedparam, value) 
				if (not InCombatLockdown()) then
					SetCVar ("nameplateSelfAlpha", value)
				else
					Plater:Msg (L["OPTIONS_ERROR_CVARMODIFY"])
				end
			end,
			min = 0.1,
			max = 1,
			step = 0.1,
			thumbscale = 1.7,
			usedecimals = true,
			name = L["OPTIONS_ALPHA"] .. CVarIcon,
			desc = "Alpha" .. CVarDesc,
			nocombat = true,
		},
		{
			type = "range",
			get = function() return tonumber (GetCVar ("nameplateSelfScale")) end,
			set = function (self, fixedparam, value) 
				if (not InCombatLockdown()) then
					SetCVar ("nameplateSelfScale", value)
				else
					Plater:Msg (L["OPTIONS_ERROR_CVARMODIFY"])
				end
			end,
			min = 0.5,
			max = 2.5,
			step = 0.1,
			thumbscale = 1.7,
			usedecimals = true,
			name = "Scale" .. CVarIcon,
			desc = "Scale" .. CVarDesc,
			nocombat = true,
		},

		{type = "blank"},
		{type = "label", get = function() return "Aura Frame:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "toggle",
			get = function() return Plater.db.profile.aura_show_buffs_personal end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.aura_show_buffs_personal = value
				Plater.RefreshDBUpvalues()
				Plater.RefreshAuras()
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_AURA_SHOW_BUFFS",
			desc = "OPTIONS_AURA_SHOW_BUFFS_DESC",
		},
		
		{
			type = "toggle",
			get = function() return Plater.db.profile.aura_show_debuffs_personal end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.aura_show_debuffs_personal = value
				Plater.RefreshDBUpvalues()
				Plater.RefreshAuras()
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_AURA_SHOW_DEBUFFS",
			desc = "OPTIONS_AURA_SHOW_DEBUFFS_DESC",
		},
		
		{
			type = "toggle",
			get = function() return Plater.db.profile.aura_show_all_duration_buffs_personal end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.aura_show_all_duration_buffs_personal = value
				Plater.RefreshDBUpvalues()
				Plater.RefreshAuras()
				Plater.UpdateAllPlates()
			end,
			name = "Don't filter Buffs by Duration",
			desc = "Show debuffs on you on the Personal Bar regardless of duration (show no-duration and >60sec).",
		},

		{
			type = "range",
			get = function() return Plater.db.profile.aura_width_personal end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.aura_width_personal = value
				Plater.RefreshAuras()
				Plater.UpdateAllPlates()
			end,
			min = 4,
			max = 80,
			step = 1,
			name = "OPTIONS_WIDTH",
			desc = "OPTIONS_AURA_WIDTH",
		},
		{
			type = "range",
			get = function() return Plater.db.profile.aura_height_personal end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.aura_height_personal = value
				Plater.RefreshAuras()
				Plater.UpdateAllPlates()
			end,
			min = 4,
			max = 80,
			step = 1,
			name = "OPTIONS_HEIGHT",
			desc = "OPTIONS_AURA_HEIGHT",
		},
		{
			type = "range",
			get = function() return Plater.db.profile.aura_border_thickness_personal end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.aura_border_thickness_personal = value
				Plater.RefreshDBUpvalues()
				Plater.RefreshAuras()
				Plater.UpdateAllPlates()
			end,
			min = 1,
			max = 5,
			step = 1,
			name = "OPTIONS_BORDER_THICKNESS",
			desc = "OPTIONS_BORDER_THICKNESS",
		},
		
		--y offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.player.buff_frame_y_offset end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.player.buff_frame_y_offset = value
				Plater.UpdateAllPlates()
			end,
			min = -100,
			max = 100,
			step = 1,
			usedecimals = true,
			name = "OPTIONS_YOFFSET",
			desc = "OPTIONS_YOFFSET_DESC",
		},
		
		{type = "blank"},
	
		{type = "label", get = function() return "Personal Bar Constrain:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		
		{
			type = "execute",
			func = function() 
				SetCVar ("nameplateSelfTopInset", 0.50)
				SetCVar ("nameplateSelfBottomInset", 0.20)
			end,
			desc = "When using a fixed position and want to go back to Blizzard default." .. CVarDesc,
			name = "Reset to Automatic Position" .. CVarIcon,
			nocombat = true,
			width = 140,
		},
		
		{
			type = "range",
			get = function() return tonumber (GetCVar ("nameplateSelfBottomInset")*100) end,
			set = function (self, fixedparam, value) 
				--Plater.db.profile.plate_config.player.y_position_offset = value

				if (InCombatLockdown()) then
					Plater:Msg (L["OPTIONS_ERROR_CVARMODIFY"])
					self:SetValue (tonumber (GetCVar ("nameplateSelfBottomInset")*100))
					return
				end

				value = floor (value)
				
				SetCVar ("nameplateSelfBottomInset", value / 100)
				SetCVar ("nameplateSelfTopInset", abs (value - 99) / 100)
				
				if (not Plater.PersonalAdjustLocation) then
					Plater.PersonalAdjustLocation = CreateFrame ("frame", "PlaterPersonalBarLocation", UIParent, BackdropTemplateMixin and "BackdropTemplate")
					local frame = Plater.PersonalAdjustLocation
					frame:SetWidth (GetScreenWidth())
					frame:SetHeight (20)
					frame.Texture = frame:CreateTexture (nil, "background")
					frame.Texture:SetTexture ([[Interface\AddOns\Plater\images\bar4_vidro]], true)
					frame.Texture:SetAllPoints()
					frame.Shadow = frame:CreateTexture (nil, "border")
					frame.Shadow:SetTexture ([[Interface\ACHIEVEMENTFRAME\UI-Achievement-RecentHeader]], true)
					frame.Shadow:SetPoint ("center")
					frame.Shadow:SetSize (256, 18)
					frame.Shadow:SetTexCoord (0, 1, 0, 22/32)
					frame.Shadow:SetVertexColor (0, 0, 0, 1)
					frame.Text = frame:CreateFontString (nil, "artwork", "GameFontNormal")
					frame.Text:SetText ("Plater: Personal Bar Position")
					frame.Text:SetPoint ("center")
					
					frame.HideAnimation = DF:CreateAnimationHub (frame, nil, function() frame:Hide() end)
					DF:CreateAnimation (frame.HideAnimation, "Alpha", 1, 1, 1, 0)
					
					frame.CancelFunction = function()
						frame.HideAnimation:Play()
					end
				end
				
				if (Plater.PersonalAdjustLocation.HideAnimation:IsPlaying()) then
					Plater.PersonalAdjustLocation.HideAnimation:Stop()
					Plater.PersonalAdjustLocation:SetAlpha (1)
				end
				Plater.PersonalAdjustLocation:Show()
				
				local percentValue = GetScreenHeight()/100
				Plater.PersonalAdjustLocation:SetPoint ("bottom", UIParent, "bottom", 0, percentValue * value)
				
				if (Plater.PersonalAdjustLocation.Timer) then
					Plater.PersonalAdjustLocation.Timer:Cancel()
				end
				Plater.PersonalAdjustLocation.Timer = C_Timer.NewTimer (7, Plater.PersonalAdjustLocation.CancelFunction)
				
				Plater.UpdateAllPlates()
				Plater.UpdateSelfPlate()
			end,
			min = 2,
			max = 98,
			step = 1,
			nocombat = true,
			name = "Fixed Position" .. CVarIcon,
			desc = "With a fixed position, personal bar won't move.\n\nTo revert this, click the button above." .. CVarDesc,
		},
		
		--{type = "blank"},
		{type = "label", get = function() return "Blizzard Cast Bar:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		
		--hide castbar from blizzard
		{
			type = "toggle",
			get = function() return Plater.db.profile.hide_blizzard_castbar end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.hide_blizzard_castbar = value
			end,
			name = "OPTIONS_CASTBAR_HIDEBLIZZARD",
			desc = "OPTIONS_CASTBAR_HIDEBLIZZARD",
		},

		{type = "breakline"},
		
		--life size
		{type = "label", get = function() return "Health Bar:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.player.healthbar_enabled end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.player.healthbar_enabled = value
				Plater.RefreshDBUpvalues()
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_ENABLED",
			desc = "OPTIONS_PERSONAL_SHOW_HEALTHBAR",
		},
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.player.health[1] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.player.health[1] = value
				Plater.db.profile.plate_config.player.health_incombat[1] = value
				Plater.UpdateAllPlates (nil, true)
				Plater.UpdateSelfPlate()
			end,
			min = 50,
			max = 300,
			step = 1,
			name = "OPTIONS_WIDTH",
			desc = "OPTIONS_PERSONAL_HEALTHBAR_WIDTH",
		},
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.player.health[2] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.player.health[2] = value
				Plater.db.profile.plate_config.player.health_incombat[2] = value
				Plater.UpdateAllPlates (nil, true)
				Plater.UpdateSelfPlate()
			end,
			min = 1,
			max = 100,
			step = 1,
			name = "OPTIONS_HEIGHT",
			desc = "OPTIONS_PERSONAL_HEALTHBAR_HEIGHT",
		},
		
		--energy bar settings
		--{type = "blank"},
		{type = "label", get = function() return "Power Bar:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.player.power_enabled end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.player.power_enabled = value
				Plater.RefreshDBUpvalues()
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_ENABLED",
			desc = "OPTIONS_SHOW_POWERBAR",
		},
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.player.mana[1] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.player.mana[1] = value
				Plater.db.profile.plate_config.player.mana_incombat[1] = value
				Plater.UpdateAllPlates()
				Plater.UpdateSelfPlate()
			end,
			min = 50,
			max = 300,
			step = 1,
			name = "OPTIONS_WIDTH",
			desc = "OPTIONS_POWERBAR_WIDTH",
		},
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.player.mana[2] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.player.mana[2] = value
				Plater.db.profile.plate_config.player.mana_incombat[2] = value
				Plater.UpdateAllPlates()
				Plater.UpdateSelfPlate()
			end,
			min = 1,
			max = 100,
			step = 1,
			name = "OPTIONS_HEIGHT",
			desc = "OPTIONS_POWERBAR_HEIGHT",
		},
		
		--cast bar settings
		--{type = "blank"},
		{type = "label", get = function() return "Cast Bar:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.player.castbar_enabled end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.player.castbar_enabled = value
				Plater.RefreshDBUpvalues()
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_ENABLED",
			desc = "OPTIONS_SHOW_CASTBAR",
		},
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.player.cast[1] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.player.cast[1] = value
				Plater.db.profile.plate_config.player.cast_incombat[1] = value
				Plater.UpdateAllPlates()
				Plater.UpdateSelfPlate()
			end,
			min = 50,
			max = 300,
			step = 1,
			name = "OPTIONS_WIDTH",
			desc = "OPTIONS_CASTBAR_WIDTH",
		},
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.player.cast[2] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.player.cast[2] = value
				Plater.db.profile.plate_config.player.cast_incombat[2] = value
				Plater.UpdateAllPlates()
				Plater.UpdateSelfPlate()
			end,
			min = 1,
			max = 100,
			step = 1,
			name = "OPTIONS_HEIGHT",
			desc = "OPTIONS_CASTBAR_HEIGHT",
		},
		--x offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.player.castbar_offset_x end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.player.castbar_offset_x = value
				Plater.UpdateAllPlates()
			end,
			min = -128,
			max = 128,
			step = 1,
			usedecimals = true,
			name = "OPTIONS_XOFFSET",
			desc = "OPTIONS_XOFFSET_DESC",
		},
		--y offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.player.castbar_offset end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.player.castbar_offset = value
				Plater.UpdateAllPlates()
			end,
			min = -128,
			max = 128,
			step = 1,
			usedecimals = true,
			name = "OPTIONS_YOFFSET",
			desc = "OPTIONS_YOFFSET_DESC",
		},
		
		{type = "blank"},
		
		--cast text size
		{type = "label", get = function() return "Spell Name Text:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.player.spellname_text_size end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.player.spellname_text_size = value
				Plater.UpdateAllPlates()
			end,
			min = 6,
			max = 99,
			step = 1,
			name = "OPTIONS_SIZE",
			desc = "OPTIONS_TEXT_SIZE",
		},
		--cast text font
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.player.spellname_text_font end,
			values = function() return DF:BuildDropDownFontList (on_select_player_npccastname_font) end,
			name = "OPTIONS_FONT",
			desc = "OPTIONS_TEXT_FONT",
		},
		--cast text color
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.plate_config.player.spellname_text_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.plate_config.player.spellname_text_color
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_COLOR",
			desc = "OPTIONS_TEXT_COLOR",
		},

		--text outline options
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.player.spellname_text_outline end,
			values = function() return build_outline_modes_table ("player", "spellname_text_outline") end,
			name = "OPTIONS_OUTLINE",
			desc = "OPTIONS_OUTLINE",
		},
		
		--text shadow color
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.plate_config.player.spellname_text_shadow_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.plate_config.player.spellname_text_shadow_color
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_SHADOWCOLOR",
			desc = "OPTIONS_TOGGLE_TO_CHANGE",
		},
		
		--spell name text anchor
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.player.spellname_text_anchor.side end,
			values = function() return build_anchor_side_table ("player", "spellname_text_anchor") end,
			name = "OPTIONS_ANCHOR",
			desc = "OPTIONS_ANCHOR_TARGET_SIDE",
		},
		--spell name text anchor x offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.player.spellname_text_anchor.x end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.player.spellname_text_anchor.x = value
				Plater.UpdateAllPlates()
			end,
			min = -100,
			max = 100,
			step = 1,
			usedecimals = true,
			name = "OPTIONS_XOFFSET",
			desc = "OPTIONS_XOFFSET_DESC",
		},
		--spell name text anchor x offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.player.spellname_text_anchor.y end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.player.spellname_text_anchor.y = value
				Plater.UpdateAllPlates()
			end,
			min = -100,
			max = 100,
			step = 1,
			usedecimals = true,
			name = "OPTIONS_YOFFSET",
			desc = "OPTIONS_YOFFSET_DESC",
		},
		
		{type = "breakline"},

		{type = "label", get = function() return "Spell Cast Time Text:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.player.spellpercent_text_enabled end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.player.spellpercent_text_enabled = value
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_ENABLED",
			desc = "Show the cast time progress.",
		},
		--cast time text
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.player.spellpercent_text_size end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.player.spellpercent_text_size = value
				Plater.UpdateAllPlates()
			end,
			min = 6,
			max = 99,
			step = 1,
			name = "OPTIONS_SIZE",
			desc = "OPTIONS_TEXT_SIZE",
		},
		--cast time text font
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.player.spellpercent_text_font end,
			values = function() return DF:BuildDropDownFontList (on_select_player_spellpercent_text_font) end,
			name = "OPTIONS_FONT",
			desc = "OPTIONS_TEXT_FONT",
		},
		
		--text outline options
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.player.spellpercent_text_outline end,
			values = function() return build_outline_modes_table ("player", "spellpercent_text_outline") end,
			name = "OPTIONS_OUTLINE",
			desc = "OPTIONS_OUTLINE",
		},
		
		--text shadow color
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.plate_config.player.spellpercent_text_shadow_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.plate_config.player.spellpercent_text_shadow_color
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_SHADOWCOLOR",
			desc = "OPTIONS_TOGGLE_TO_CHANGE",
		},
		
		--cast time text color
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.plate_config.player.spellpercent_text_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.plate_config.player.spellpercent_text_color
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_COLOR",
			desc = "OPTIONS_TEXT_COLOR",
		},
		
		--cast time anchor
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.player.spellpercent_text_anchor.side end,
			values = function() return build_anchor_side_table ("player", "spellpercent_text_anchor") end,
			name = "OPTIONS_ANCHOR",
			desc = "OPTIONS_ANCHOR_TARGET_SIDE",
		},
		--cast time anchor x offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.player.spellpercent_text_anchor.x end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.player.spellpercent_text_anchor.x = value
				Plater.UpdateAllPlates()
			end,
			min = -100,
			max = 100,
			step = 1,
			usedecimals = true,
			name = "OPTIONS_XOFFSET",
			desc = "OPTIONS_XOFFSET_DESC",
		},
		--cast time anchor x offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.player.spellpercent_text_anchor.y end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.player.spellpercent_text_anchor.y = value
				Plater.UpdateAllPlates()
			end,
			min = -100,
			max = 100,
			step = 1,
			usedecimals = true,
			name = "OPTIONS_YOFFSET",
			desc = "OPTIONS_YOFFSET_DESC",
		},
		
		
		{type = "blank"},
		
		
		{type = "label", get = function() return "Power Percent Text:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		--enabled
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.player.power_percent_text_enabled end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.player.power_percent_text_enabled = value
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_ENABLED",
			desc = "Show the percent text.",
		},
		--percent text size
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.player.power_percent_text_size end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.player.power_percent_text_size = value
				Plater.UpdateAllPlates()
			end,
			min = 6,
			max = 99,
			step = 1,
			name = "OPTIONS_SIZE",
			desc = "OPTIONS_TEXT_SIZE",
		},
		--percent text font
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.player.power_percent_text_font end,
			values = function() return DF:BuildDropDownFontList (on_select_player_power_percent_text_font) end,
			name = "OPTIONS_FONT",
			desc = "OPTIONS_TEXT_FONT",
		},
		
		--[=[
		--show outline
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.player.power_percent_text_outline end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.player.power_percent_text_outline = value
				Plater.UpdateAllPlates()
			end,
			name = "Show Outline",
			desc = "If the text has a black outline.",
		},
		--]=]
		
		--text outline options
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.player.power_percent_text_outline end,
			values = function() return build_outline_modes_table ("player", "power_percent_text_outline") end,
			name = "OPTIONS_OUTLINE",
			desc = "OPTIONS_OUTLINE",
		},
		
		--text shadow color
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.plate_config.player.power_percent_text_shadow_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.plate_config.player.power_percent_text_shadow_color
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_SHADOWCOLOR",
			desc = "OPTIONS_TOGGLE_TO_CHANGE",
		},
		
		--pecent text color
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.plate_config.player.power_percent_text_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.plate_config.player.power_percent_text_color
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllPlates()
			end,
			name = "Text Color",
			desc = "OPTIONS_TEXT_COLOR",
		},
		--percent text alpha
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.player.power_percent_text_alpha end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.player.power_percent_text_alpha = value
				Plater.UpdateAllPlates()
			end,
			min = 0,
			max = 1,
			step = 0.1,
			name = "OPTIONS_ALPHA",
			desc = "Set the transparency of the text.",
			usedecimals = true,
		},
		--percent anchor
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.player.power_percent_text_anchor.side end,
			values = function() return build_anchor_side_table ("player", "power_percent_text_anchor") end,
			name = "OPTIONS_ANCHOR",
			desc = "OPTIONS_ANCHOR_TARGET_SIDE",
		},
		--percent anchor x offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.player.power_percent_text_anchor.x end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.player.power_percent_text_anchor.x = value
				Plater.UpdateAllPlates()
			end,
			min = -100,
			max = 100,
			step = 1,
			usedecimals = true,
			name = "OPTIONS_XOFFSET",
			desc = "OPTIONS_XOFFSET_DESC",
		},
		--percent anchor x offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.player.power_percent_text_anchor.y end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.player.power_percent_text_anchor.y = value
				Plater.UpdateAllPlates()
			end,
			min = -100,
			max = 100,
			step = 1,
			usedecimals = true,
			name = "OPTIONS_YOFFSET",
			desc = "OPTIONS_YOFFSET_DESC",
		},			
		
		{type = "breakline"},

		--percent text
		{type = "label", get = function() return "Health Information:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		--enabled
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.player.percent_text_enabled end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.player.percent_text_enabled = value
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_ENABLED",
			desc = "Show the percent text.",
		},
		
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.plate_config.player.healthbar_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.plate_config.player.healthbar_color
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_COLOR",
			desc = "Color",
		},
		
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.player.healthbar_color_by_hp end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.player.healthbar_color_by_hp = value
				Plater.UpdateSettingsCache()
				Plater.UpdateAllPlates()
			end,
			name = "Color by Health",
			desc = "Use the regular color when full health and change it to red as the health goes lower",
		},
		
		--out of combat
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.player.percent_text_ooc end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.player.percent_text_ooc = value
				Plater.UpdateSettingsCache()
				Plater.UpdateAllPlates()
			end,
			name = "Out of Combat",
			desc = "Show the percent even when isn't in combat.",
		},
		--percent amount
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.player.percent_show_percent end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.player.percent_show_percent = value
				Plater.UpdateAllPlates()
			end,
			name = "Show Percent Amount",
			desc = "Show Percent Amount",
		},		
		--health amount
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.player.percent_show_health end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.player.percent_show_health = value
				Plater.UpdateAllPlates()
			end,
			name = "Show Health Amount",
			desc = "Show Health Amount",
		},
		
		--health decimals
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.player.percent_text_show_decimals end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.player.percent_text_show_decimals = value
				Plater.UpdateAllPlates()
			end,
			name = "Show Decimals",
			desc = "Show Decimals",
		},			
		
		--percent text size
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.player.percent_text_size end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.player.percent_text_size = value
				Plater.UpdateAllPlates()
			end,
			min = 6,
			max = 99,
			step = 1,
			name = "OPTIONS_SIZE",
			desc = "OPTIONS_TEXT_SIZE",
		},
		--percent text font
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.player.percent_text_font end,
			values = function() return DF:BuildDropDownFontList (on_select_player_percent_text_font) end,
			name = "OPTIONS_FONT",
			desc = "OPTIONS_TEXT_FONT",
		},
		
		--text outline options
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.player.percent_text_outline end,
			values = function() return build_outline_modes_table ("player", "percent_text_outline") end,
			name = "OPTIONS_OUTLINE",
			desc = "OPTIONS_OUTLINE",
		},
		
		--text shadow color
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.plate_config.player.percent_text_shadow_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.plate_config.player.percent_text_shadow_color
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_SHADOWCOLOR",
			desc = "OPTIONS_TOGGLE_TO_CHANGE",
		},
		
		--pecent text color"
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.plate_config.player.percent_text_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.plate_config.player.percent_text_color
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_COLOR",
			desc = "OPTIONS_TEXT_COLOR",
		},
		--percent text alpha
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.player.percent_text_alpha end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.player.percent_text_alpha = value
				Plater.UpdateAllPlates()
			end,
			min = 0,
			max = 1,
			step = 0.1,
			name = "OPTIONS_ALPHA",
			desc = "Set the transparency of the text.",
			usedecimals = true,
		},
		--percent anchor
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.player.percent_text_anchor.side end,
			values = function() return build_anchor_side_table ("player", "percent_text_anchor") end,
			name = "OPTIONS_ANCHOR",
			desc = "OPTIONS_ANCHOR_TARGET_SIDE",
		},
		--percent anchor x offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.player.percent_text_anchor.x end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.player.percent_text_anchor.x = value
				Plater.UpdateAllPlates()
			end,
			min = -20,
			max = 20,
			step = 1,
			usedecimals = true,
			name = "OPTIONS_XOFFSET",
			desc = "OPTIONS_XOFFSET_DESC",
		},
		--percent anchor x offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.player.percent_text_anchor.y end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.player.percent_text_anchor.y = value
				Plater.UpdateAllPlates()
			end,
			min = -20,
			max = 20,
			step = 1,
			usedecimals = true,
			name = "OPTIONS_YOFFSET",
			desc = "OPTIONS_YOFFSET_DESC",
		},
		
		--class resources
		{type = "blank"},
		{type = "label", get = function() return "Resources:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		
		{
			type = "range",
			get = function() return Plater.db.profile.resources.alpha end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.resources.alpha = value
				Plater.UpdateAllPlates()
			end,
			min = 0,
			max = 1,
			step = 0.01,
			usedecimals = true,
			name = "OPTIONS_ALPHA",
			desc = "Resource Alpha",
		},
		
		{
			type = "range",
			get = function() return Plater.db.profile.resources.scale end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.resources.scale = value
				Plater.UpdateAllPlates()
			end,
			min = 0.25,
			max = 2,
			step = 0.01,
			usedecimals = true,
			nocombat = true,
			name = "Resource Scale",
			desc = "Resource Scale",
		},
		
		{
			type = "range",
			get = function() return Plater.db.profile.resources.y_offset end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.resources.y_offset = value
				Plater.UpdateAllPlates()
			end,
			min = -100,
			max = 100,
			step = 1,
			usedecimals = true,
			nocombat = true,
			name = "OPTIONS_YOFFSET",
			desc = "Y Offset when resource bar are anchored to your personal bar",
		},
		
		{
			type = "range",
			get = function() return Plater.db.profile.resources.y_offset_target end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.resources.y_offset_target = value
				Plater.UpdateAllPlates()
			end,
			min = -100,
			max = 100,
			step = 1,
			usedecimals = true,
			nocombat = true,
			name = "Y OffSet on Target",
			desc = "Y Offset when the resource are anchored on your current target",
		},	
		
		{
			type = "range",
			get = function() return Plater.db.profile.resources.y_offset_target_withauras end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.resources.y_offset_target_withauras = value
				Plater.UpdateAllPlates()
			end,
			min = -100,
			max = 100,
			step = 1,
			usedecimals = true,
			nocombat = true,
			name = "Offset if Buff is Shown",
			desc = "Add this to 'Y OffSet on Target' if there is buffs or debuffs shown in the nameplate",
		},			
		
	}
	
	if IS_WOW_PROJECT_NOT_MAINLINE then
		options_personal = {
			{type = "label", get = function() return "Not available in WoW Classic." end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		}
	end

	_G.C_Timer.After(1.3, function() --~delay
		options_personal.always_boxfirst = true
		options_personal.language_addonId = addonId
		options_personal.Name = "Personal Options"
		DF:BuildMenu (personalPlayerFrame, options_personal, startX, startY, heightSize, false, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template, globalCallback)
	end)
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------
--target options

local on_select_target_indicator = function (_, _, indicator)
	Plater.db.profile.target_indicator = indicator
	Plater.OnPlayerTargetChanged()
end
local indicator_table = {}
for name, indicatoirTable in pairs (Plater.TargetIndicators) do
	tinsert (indicator_table, {label = name, value = name, onclick = on_select_target_indicator, icon = indicatoirTable.path, texcoord = indicatoirTable.coords[1]})
end
local build_target_indicator_table = function()
	return indicator_table
end

local focus_indicator_texture_selected = function (self, capsule, value)
	Plater.db.profile.focus_texture = value
	Plater.OnPlayerTargetChanged()
end
local focus_indicator_texture_options = {}
for name, texturePath in pairs (textures) do 
	focus_indicator_texture_options [#focus_indicator_texture_options + 1] = {value = name, label = name, statusbar = texturePath, onclick = focus_indicator_texture_selected}
end
table.sort (focus_indicator_texture_options, function (t1, t2) return t1.label < t2.label end)

--targetFrame
local targetOptions = {
		{type = "label", get = function() return "Target:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		
		--target texture
		{
			type = "select",
			get = function() return Plater.db.profile.health_selection_overlay end,
			values = function() return health_selection_overlay_options end,
			name = "TARGET_OVERLAY_TEXTURE",
			desc = "TARGET_OVERLAY_TEXTURE_DESC",
		},
		{
			type = "range",
			get = function() return Plater.db.profile.health_selection_overlay_alpha end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.health_selection_overlay_alpha = value
				Plater.UpdateAllPlates()
			end,
			min = 0,
			max = 1,
			step = 0.1,
			name = "TARGET_OVERLAY_ALPHA",
			desc = "TARGET_OVERLAY_ALPHA",
			usedecimals = true,
		},
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.health_selection_overlay_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.health_selection_overlay_color
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.OnPlayerTargetChanged()
			end,
			name = L["OPTIONS_COLOR"],
			desc = "Focus Color",
		},

		{type = "blank"},
		
		{
			type = "toggle",
			get = function() return Plater.db.profile.target_highlight end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.target_highlight = value
				Plater.UpdateAllPlates()
			end,
			name = "TARGET_HIGHLIGHT",
			desc = "TARGET_HIGHLIGHT_DESC",
		},
		{
			type = "select",
			get = function() return Plater.db.profile.target_highlight_texture end,
			values = function() return target_selection_texture_selected_options end,
			name = "TARGET_HIGHLIGHT_TEXTURE",
			desc = "TARGET_HIGHLIGHT_TEXTURE",
		},
		{
			type = "range",
			get = function() return Plater.db.profile.target_highlight_alpha end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.target_highlight_alpha = value
				Plater.OnPlayerTargetChanged()
			end,
			min = 0,
			max = 1,
			step = 0.1,
			name = "TARGET_HIGHLIGHT_ALPHA",
			desc = "TARGET_HIGHLIGHT_ALPHA",
			usedecimals = true,
		},
		{
			type = "range",
			get = function() return Plater.db.profile.target_highlight_height end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.target_highlight_height = value
				Plater.UpdateAllPlates()
			end,
			min = 2,
			max = 60,
			step = 1,
			name = "TARGET_HIGHLIGHT_SIZE",
			desc = "TARGET_HIGHLIGHT_SIZE",
		},
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.target_highlight_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.target_highlight_color
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.OnPlayerTargetChanged()
			end,
			name = "TARGET_HIGHLIGHT_COLOR",
			desc = "TARGET_HIGHLIGHT_COLOR",
		},
		
		--target_highlight_texture
		
		{type = "blank"},
		
		{
			type = "toggle",
			get = function() return Plater.db.profile.hover_highlight end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.hover_highlight = value
				Plater.RefreshDBUpvalues()
				Plater.FullRefreshAllPlates()
			end,
			name = "HIGHLIGHT_HOVEROVER",
			desc = "HIGHLIGHT_HOVEROVER_DESC",
		},
		{
			type = "range",
			get = function() return Plater.db.profile.hover_highlight_alpha end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.hover_highlight_alpha = value
				Plater.UpdateAllPlates()
			end,
			min = 0,
			max = 1,
			step = 0.1,
			name = "HIGHLIGHT_HOVEROVER_ALPHA",
			desc = "HIGHLIGHT_HOVEROVER_ALPHA",
			usedecimals = true,
		},		
		
		{type = "blank"},
		
		{
			type = "select",
			get = function() return Plater.db.profile.target_indicator end,
			values = function() return build_target_indicator_table() end,
			name = "Target Bracket Indicator",
			desc = "Target Bracket Indicator",
		},
		
		{type = "blank"},
		
		--target alpha
		{
			type = "toggle",
			get = function() return Plater.db.profile.target_shady_enabled end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.target_shady_enabled = value
				Plater.RefreshDBUpvalues()
				Plater.OnPlayerTargetChanged()
				--update
			end,
			name = "Target Shading",
			desc = "Apply a layer of shadow above the nameplate when the unit is in range but isn't your current target.",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.target_shady_combat_only end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.target_shady_combat_only = value
				Plater.RefreshDBUpvalues()
				Plater.OnPlayerTargetChanged()
				--update
			end,
			name = "Target Shading Only in Combat",
			desc = "Apply target shading only when in combat.",
		},
		{
			type = "range",
			get = function() return Plater.db.profile.target_shady_alpha end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.target_shady_alpha = value
				Plater.RefreshDBUpvalues()
				Plater.OnPlayerTargetChanged()
				--update
			end,
			min = 0,
			max = 1,
			step = 0.1,
			name = "Target Shading Amount",
			desc = "Amount of shade to apply.",
			usedecimals = true,
		},		
		
		{type = "breakline"},
		
		{
			type = "toggle",
			get = function() return GetCVarBool ("nameplateTargetRadialPosition") end,
			set = function (self, fixedparam, value) 
				if (value) then
					SetCVar ("clampTargetNameplateToScreen", CVAR_ENABLED)
					SetCVar ("nameplateTargetRadialPosition", CVAR_ENABLED)
				else
					SetCVar ("clampTargetNameplateToScreen", CVAR_DISABLED)
					SetCVar ("nameplateTargetRadialPosition", CVAR_DISABLED)
				end
			end,
			nocombat = true,
			name = "TARGET_CVAR_ALWAYSONSCREEN",
			desc = "TARGET_CVAR_ALWAYSONSCREEN_DESC",
		},
		
		{
			type = "range",
			get = function() return tonumber (GetCVar ("nameplateOtherTopInset")) end,
			set = function (self, fixedparam, value) 
				if (not InCombatLockdown()) then
					if (value == 0) then
						SetCVar ("nameplateOtherTopInset", -1)
						SetCVar ("nameplateLargeTopInset", -1)
						
					else
						SetCVar ("nameplateOtherTopInset", value)
						SetCVar ("nameplateLargeTopInset", value)
						
					end
				else
					Plater:Msg (L["OPTIONS_ERROR_CVARMODIFY"])
				end
			end,
			min = 0.000,
			max = 0.1,
			step = 0.005,
			thumbscale = 1.7,
			usedecimals = true,
			name = "TARGET_CVAR_LOCKTOSCREEN",
			desc = "TARGET_CVAR_LOCKTOSCREEN_DESC",
			nocombat = true,
		},
		
		{
			type = "range",
			get = function() return tonumber (GetCVar ("nameplateOtherBottomInset")) end,
			set = function (self, fixedparam, value) 
				if (not InCombatLockdown()) then
					if (value == 0) then
						SetCVar ("nameplateOtherBottomInset", -1)
						SetCVar ("nameplateLargeBottomInset", -1)
						
					else
						SetCVar ("nameplateOtherBottomInset", value)
						SetCVar ("nameplateLargeBottomInset", value)
						
					end
				else
					Plater:Msg (L["OPTIONS_ERROR_CVARMODIFY"])
				end
			end,
			min = 0.000,
			max = 0.1,
			step = 0.005,
			thumbscale = 1.7,
			usedecimals = true,
			name = "Lock to Screen (Bottom Side)|cFFFF7700*|r",
			desc = "Min space between the nameplate and the bottom of the screen. Increase this if some part of the nameplate are going out of the screen.\n\n|cFFFFFFFFDefault: 0.065|r\n\n|cFFFFFF00 Important |r: if you're having issue, manually set using these macros:\n/run SetCVar ('nameplateOtherBottomInset', '0.1')\n/run SetCVar ('nameplateLargeBottomInset', '0.15')\n\n|cFFFFFF00 Important |r: setting to 0 disables this feature.\n\n|cFFFF7700[*]|r |cFFa0a0a0CVar, saved within Plater profile and restored when loading the profile.|r",
			nocombat = true,
		},
		
		{
			type = "range",
			get = function() return tonumber (GetCVar ("nameplateTargetBehindMaxDistance")) end,
			set = function (self, fixedparam, value) 
				if (not InCombatLockdown()) then
					SetCVar ("nameplateTargetBehindMaxDistance", value)
				else
					Plater:Msg (L["OPTIONS_ERROR_CVARMODIFY"])
				end
			end,
			min = 5,
			max = 50,
			step = 1,
			thumbscale = 1.7,
			name = "Target Behind You Distance" .. CVarIcon,
			desc = "Max distance to allow show the nameplate of your target when the unit is behind you and not shown in the screen.\n\n|cFFFFFFFFDefault: 15|r" .. CVarDesc,
			nocombat = true,
		},
		
		{
			type = "range",
			get = function() return tonumber (GetCVar ("nameplateSelectedScale")) end,
			set = function (self, fixedparam, value) 
				if (not InCombatLockdown()) then
					SetCVar ("nameplateSelectedScale", value)
				else
					Plater:Msg (L["OPTIONS_ERROR_CVARMODIFY"])
				end
			end,
			min = 0.75,
			max = 1.75,
			step = 0.1,
			thumbscale = 1.7,
			usedecimals = true,
			name = "Target Scale" .. CVarIcon,
			desc = "The nameplate size for the current target is multiplied by this value.\n\n|cFFFFFFFFDefault: 1|r\n\n|cFFFFFFFFRecommended: 1.15|r" .. CVarDesc,
			nocombat = true,
		},		
		
		{type = "breakline"},
		
		{type = "label", get = function() return "Focus:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		
		{
			type = "toggle",
			get = function() return Plater.db.profile.focus_indicator_enabled end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.focus_indicator_enabled = value
				Plater.OnPlayerTargetChanged()
			end,
			name = "Show Focus Overlay",
			desc = "Focus Indicator",
		},
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.focus_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.focus_color
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.OnPlayerTargetChanged()
			end,
			name = "OPTIONS_COLOR",
			desc = "Focus Color",
		},
		{
			type = "select",
			get = function() return Plater.db.profile.focus_texture end,
			values = function() return focus_indicator_texture_options end,
			name = "OPTIONS_TEXTURE",
			desc = "Focus Texture",
		},

		{type = "blank"},
		{type = "label", get = function() return "Raid Mark:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		
		{
			type = "range",
			get = function() return Plater.db.profile.indicator_raidmark_scale end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.indicator_raidmark_scale = value
				Plater.UpdateAllPlates()
			end,
			min = 0.2,
			max = 2,
			step = 0.1,
			usedecimals = true,
			name = "Scale",
			desc = "Scale",
		},
		
		--indicator icon anchor
		{
			type = "select",
			get = function() return Plater.db.profile.indicator_raidmark_anchor.side end,
			values = function() return build_anchor_side_table (nil, "indicator_raidmark_anchor") end,
			name = "OPTIONS_ANCHOR",
			desc = "OPTIONS_ANCHOR_TARGET_SIDE",
		},
		--indicator icon anchor x offset
		{
			type = "range",
			get = function() return Plater.db.profile.indicator_raidmark_anchor.x end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.indicator_raidmark_anchor.x = value
				Plater.UpdateAllPlates()
			end,
			min = -100,
			max = 100,
			step = 1,
			usedecimals = true,
			name = "OPTIONS_XOFFSET",
			desc = "Slightly move horizontally.",
		},
		--indicator icon anchor y offset
		{
			type = "range",
			get = function() return Plater.db.profile.indicator_raidmark_anchor.y end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.indicator_raidmark_anchor.y = value
				Plater.UpdateAllPlates()
			end,
			min = -100,
			max = 100,
			step = 1,
			usedecimals = true,
			name = "OPTIONS_YOFFSET",
			desc = "Slightly move vertically.",
		},
		
		{
			type = "toggle",
			get = function() return Plater.db.profile.indicator_extra_raidmark end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.indicator_extra_raidmark = value
				Plater.UpdateAllPlates()
				Plater.UpdateRaidMarkersOnAllNameplates()
			end,
			name = "Extra Raid Mark",
			desc = "Places an extra raid mark icon inside the health bar.",
		},

}

_G.C_Timer.After(1.20, function() --~delay
	targetOptions.always_boxfirst = true
	targetOptions.language_addonId = addonId
	targetOptions.Name = "Target Options"
	DF:BuildMenu (targetFrame, targetOptions, startX, startY, heightSize, false, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template, globalCallback)
end)
--------------------------------------------------------------------------------------------------------------------------------------------------------------

--coloca as op��es gerais no main menu logo abaixo dos 4 bot�es
--OP��ES NO PAINEL PRINCIPAL

function Plater.ChangeNpcRelavance (_, _, value)
	if (value == 1) then
		Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_NPC].only_names = false
		Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_NPC].all_names = false
		
	elseif (value == 2) then
		Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_NPC].only_names = false
		Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_NPC].all_names = true
		
	elseif (value == 3) then
		Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_NPC].only_names = true
		Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_NPC].all_names = false
		
	elseif (value == 4) then
		Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_NPC].only_names = true
		Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_NPC].all_names = true
	end
	
	Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_NPC].relevance_state = value
	
	Plater.UpdateAllPlates()
end
local relevance_options = {
	{label = "All Professions (Healthbars)", value = 1, onclick = Plater.ChangeNpcRelavance},
	{label = "All Npcs (Healthbars)", value = 2, onclick = Plater.ChangeNpcRelavance},
	{label = "All Professions (Name)", value = 3, onclick = Plater.ChangeNpcRelavance},
	{label = "All Npcs (Name)", value = 4, onclick = Plater.ChangeNpcRelavance},
}

--

	
	--menu 1 ~general ~geral
	local options_table1 = {

		{type = "label", get = function() return "Interface Options (from the client):" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "toggle",
			boxfirst = true,
			get = function() return GetCVarBool ("nameplateShowEnemies") end,
			set = function (self, fixedparam, value) 
				if (not InCombatLockdown()) then
					SetCVar ("nameplateShowEnemies", value and "1" or "0")
				else
					Plater:Msg (L["OPTIONS_ERROR_CVARMODIFY"])
					self:SetValue (GetCVarBool ("nameplateShowEnemies"))
				end
			end,
			name = "OPTIONS_NAMEPLATE_SHOW_ENEMY", --show enemy nameplates
			desc = "OPTIONS_NAMEPLATE_SHOW_ENEMY_DESC",
			nocombat = true,
		},
		
		{
			type = "toggle",
			boxfirst = true,
			get = function() return GetCVarBool ("nameplateShowFriends") end,
			set = function (self, fixedparam, value) 
				if (not InCombatLockdown()) then
					SetCVar ("nameplateShowFriends", value and "1" or "0")
				else
					Plater:Msg (L["OPTIONS_ERROR_CVARMODIFY"])
					self:SetValue (GetCVarBool ("nameplateShowFriends"))
				end
			end,
			name = "OPTIONS_NAMEPLATE_SHOW_FRIENDLY", --show friendly nameplates
			desc = "OPTIONS_NAMEPLATE_SHOW_FRIENDLY_DESC",
			nocombat = true,
		},
		
		{
			type = "toggle",
			boxfirst = true,
			get = function() return GetCVarBool ("nameplateShowOnlyNames") end,
			set = function (self, fixedparam, value) 
				if (not InCombatLockdown()) then
					SetCVar ("nameplateShowOnlyNames", value and "1" or "0")
				else
					Plater:Msg (L["OPTIONS_ERROR_CVARMODIFY"])
					self:SetValue (GetCVarBool ("nameplateShowOnlyNames"))
				end

				Plater.UpdateBaseNameplateOptions()
			end,
			name = "OPTIONS_NAMEPLATE_HIDE_FRIENDLY_HEALTH", --"Hide Blizzard Health Bars"
			desc = "OPTIONS_NAMEPLATE_HIDE_FRIENDLY_HEALTH_DESC",
			nocombat = true,
		},
		
		{
			type = "toggle",
			boxfirst = true,
			get = function() return GetCVar ("nameplateShowSelf") == CVAR_ENABLED end,
			set = function (self, fixedparam, value) 
				if (not InCombatLockdown()) then
					SetCVar ("nameplateShowSelf", math.abs (tonumber (GetCVar ("nameplateShowSelf") or 1)-1))
				else
					Plater:Msg (L["OPTIONS_ERROR_CVARMODIFY"])
					self:SetValue (GetCVar ("nameplateShowSelf") == CVAR_ENABLED)
				end
			end,
			name = "OPTIONS_CVAR_ENABLE_PERSONAL_BAR",
			desc = "OPTIONS_CVAR_ENABLE_PERSONAL_BAR_DESC",
			nocombat = true,
			hidden = IS_WOW_PROJECT_NOT_MAINLINE,
		},
		{
			type = "toggle",
			boxfirst = true,
			get = function() return PlaterDBChr.resources_on_target end,
			set = function (self, fixedparam, value) 
				PlaterDBChr.resources_on_target = value
				if value then
					Plater.db.profile.resources_settings.global_settings.show = false
				end
				if (not InCombatLockdown()) then
					SetCVar (CVAR_RESOURCEONTARGET, CVAR_DISABLED) -- reset this to false always, as it conflicts
				end
			end,
			name = "OPTIONS_RESOURCES_TARGET",
			desc = "OPTIONS_RESOURCES_TARGET_DESC",
			nocombat = true,
			hidden = IS_WOW_PROJECT_NOT_MAINLINE,
		},
		{
			type = "toggle",
			boxfirst = true,
			get = function() return GetCVar (CVAR_SHOWALL) == CVAR_ENABLED end,
			set = function (self, fixedparam, value) 
				if (not InCombatLockdown()) then
					SetCVar (CVAR_SHOWALL, math.abs (tonumber (GetCVar (CVAR_SHOWALL))-1))
				else
					Plater:Msg (L["OPTIONS_ERROR_CVARMODIFY"])
					self:SetValue (GetCVar (CVAR_SHOWALL) == CVAR_ENABLED)
				end
			end,
			name = "OPTIONS_CVAR_NAMEPLATES_ALWAYSSHOW",
			desc = "OPTIONS_CVAR_NAMEPLATES_ALWAYSSHOW_DESC",
			nocombat = true,
		},

		{
			type = "toggle",
			boxfirst = true,
			get = function() return Plater.db.profile.honor_blizzard_plate_alpha end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.honor_blizzard_plate_alpha = value
				Plater.UpdateAllPlates()
			end,
			name = "Use Blizzard's Nameplate Alpha",
			desc = "Use the 'occluded' and other blizzard nameplate alpha values from blizzard settings.\n\nThis setting only works with 'Use custom strata channels' enabled.",
			id = "transparency_blizzard_alpha",
		},
		{
			type = "range",
			get = function() return tonumber (GetCVar ("nameplateOccludedAlphaMult")) end,
			set = function (self, fixedparam, value) 
				if (not InCombatLockdown()) then
					SetCVar ("nameplateOccludedAlphaMult", value)
				else
					Plater:Msg (L["OPTIONS_ERROR_CVARMODIFY"])
				end
			end,
			min = 0,
			max = 1,
			step = 0.1,
			thumbscale = 1.7,
			usedecimals = true,
			name = "Occluded Alpha Multiplier" .. CVarIcon,
			desc = "Alpha multiplyer for 'occluded' plates (when they are not in line of sight)." .. CVarDesc,
			nocombat = true,
		},
		
		{type = "blank"},
		
		{
			type = "toggle",
			boxfirst = true,
			get = function() return GetCVarBool (CVAR_PLATEMOTION) end, --GetCVar (CVAR_PLATEMOTION) == CVAR_ENABLED
			set = function (self, fixedparam, value) 
				if (not InCombatLockdown()) then
					SetCVar (CVAR_PLATEMOTION, value and "1" or "0")
					Plater.db.profile.stacking_nameplates_enabled = value
				else
					Plater:Msg (L["OPTIONS_ERROR_CVARMODIFY"])
					self:SetValue (GetCVar (CVAR_PLATEMOTION) == CVAR_ENABLED)
				end
			end,
			name = "OPTIONS_NAMEPLATES_STACKING",
			desc = "OPTIONS_NAMEPLATES_STACKING_DESC",
			nocombat = true,
		},
		
		{
			type = "range",
			get = function() return tonumber (GetCVar ("nameplateOverlapV")) end,
			set = function (self, fixedparam, value) 
				if (not InCombatLockdown()) then
					SetCVar ("nameplateOverlapV", value)
				else
					Plater:Msg (L["OPTIONS_ERROR_CVARMODIFY"])
				end
			end,
			min = 0.2,
			max = 2.5,
			step = 0.05,
			thumbscale = 1.7,
			usedecimals = true,
			name = "OPTIONS_NAMEPLATES_OVERLAP",
			desc = "OPTIONS_NAMEPLATES_OVERLAP_DESC",
			nocombat = true,
		},
		
		{
			type = "range",
			get = function() return tonumber (GetCVar (CVAR_CULLINGDISTANCE)) end,
			set = function (self, fixedparam, value) 
				if (not InCombatLockdown()) then
					SetCVar (CVAR_CULLINGDISTANCE, value)
				else
					Plater:Msg (L["OPTIONS_ERROR_CVARMODIFY"])
				end
			end,
			min = IS_WOW_PROJECT_MAINLINE and 0 or 20, --20y for tbc and classic
			max = (IS_WOW_PROJECT_MAINLINE and 60) or ((IS_WOW_PROJECT_CLASSIC_TBC or IS_WOW_PROJECT_CLASSIC_WRATH) and 41) or 20, --41y for tbc, 20y for classic era
			step = 1,
			name = "View Distance" .. CVarIcon,
			desc = "How far you can see nameplates (in yards).\n\n|cFFFFFFFFCurrent limitations: Retail = 60y, TBC = 20-41y, Classic = 20y|r" .. CVarDesc,
			nocombat = true,
		},
		
		{
			type = "range",
			get = function() return tonumber (GetCVar ("nameplatePlayerMaxDistance")) or 0 end,
			set = function (self, fixedparam, value) 
				if (not InCombatLockdown()) then
					SetCVar ("nameplatePlayerMaxDistance", value)
				else
					Plater:Msg (L["OPTIONS_ERROR_CVARMODIFY"])
				end
			end,
			min = 0,
			max = (IS_WOW_PROJECT_MAINLINE and 60) or ((IS_WOW_PROJECT_CLASSIC_TBC or IS_WOW_PROJECT_CLASSIC_WRATH) and 0) or 0, --not available for classic/wrath
			step = 1,
			name = "Player View Distance" .. CVarIcon,
			desc = "How far you can see player nameplates (in yards).\n\n|cFFFFFFFFLimitations: Retail = 60y, TBC/Classic: not available|r" .. CVarDesc,
			nocombat = true,
		},

		{type = "blank"},

		{type = "label", get = function() return "OPTIONS_GENERALSETTINGS_HEALTHBAR_ANCHOR_TITLE" end, text_template = DF:GetTemplate("font", "ORANGE_FONT_TEMPLATE")},

		{
			type = "select",
			get = function() return Plater.db.profile.health_statusbar_texture end,
			values = function() return health_bar_texture_options end,
			name = "OPTIONS_GENERALSETTINGS_HEALTHBAR_TEXTURE", --health bar texture
			desc = "OPTIONS_GENERALSETTINGS_HEALTHBAR_TEXTURE",
		},
		{
			type = "select",
			get = function() return Plater.db.profile.health_statusbar_bgtexture end,
			values = function() return health_bar_bgtexture_options end,
			name = "OPTIONS_GENERALSETTINGS_HEALTHBAR_BGTEXTURE", --health bar background texture
			desc = "OPTIONS_GENERALSETTINGS_HEALTHBAR_BGTEXTURE",
		},
		{
			type = "color",
			boxfirst = true,
			get = function()
				local color = Plater.db.profile.health_statusbar_bgcolor
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.health_statusbar_bgcolor
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_GENERALSETTINGS_HEALTHBAR_BGCOLOR", --health bar background color
			desc = "OPTIONS_GENERALSETTINGS_HEALTHBAR_BGCOLOR",
		},

		{
			type = "color",
			boxfirst = true,
			get = function()
				local color = Plater.db.profile.border_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.border_color
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.RefreshDBUpvalues()
				Plater.UpdatePlateBorders()
			end,
			name = "OPTIONS_BORDER_COLOR",
			desc = "OPTIONS_BORDER_COLOR",
		},
		{
			type = "range",
			get = function() return Plater.db.profile.border_thickness end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.border_thickness = value
				Plater.RefreshDBUpvalues()
				Plater.UpdatePlateBorderThickness()
			end,
			min = 0.1,
			max = 3,
			step = 0.1,
			usedecimals = true,
			name = "OPTIONS_BORDER_THICKNESS",
			desc = "OPTIONS_BORDER_THICKNESS",
		},

		{type = "blank"},

		{ --global healthbar width
			type = "range",
			get = function() return Plater.db.profile.plate_config.global_health_width end,
			set = function (self, fixedparam, value) 

				local plateConfig = Plater.db.profile.plate_config

				plateConfig.global_health_width = value
				
				-- do not propagate during import or profile switch!
				if not PlaterOptionsPanelFrame:IsShown() or profilesFrame.IsImporting then
					return
				end

				--change the health bars
				plateConfig.friendlyplayer.health[1] = value
				plateConfig.friendlyplayer.health_incombat[1] = value

				plateConfig.enemyplayer.health[1] = value
				plateConfig.enemyplayer.health_incombat[1] = value

				plateConfig.friendlynpc.health[1] = value
				plateConfig.friendlynpc.health_incombat[1] = value

				plateConfig.enemynpc.health[1] = value
				plateConfig.enemynpc.health_incombat[1] = value

				--change the castbars
				plateConfig.friendlyplayer.cast[1] = value
				plateConfig.friendlyplayer.cast_incombat[1] = value

				plateConfig.enemyplayer.cast[1] = value
				plateConfig.enemyplayer.cast_incombat[1] = value

				plateConfig.friendlynpc.cast[1] = value
				plateConfig.friendlynpc.cast_incombat[1] = value

				plateConfig.enemynpc.cast[1] = value
				plateConfig.enemynpc.cast_incombat[1] = value

				Plater.RefreshDBUpvalues()
				Plater.UpdateAllPlates(nil, true)
				PlaterOptionsPanelFrame.RefreshOptionsFrame()
			end,
			min = 50,
			max = 300,
			step = 1,
			name = "OPTIONS_HEALTHBAR_WIDTH", --Health Bar Width
			desc = "OPTIONS_HEALTHBAR_SIZE_GLOBAL_DESC",
		},

		{ --global healthbar height
			type = "range",
			get = function() return Plater.db.profile.plate_config.global_health_height end,
			set = function (self, fixedparam, value) 

				local plateConfig = Plater.db.profile.plate_config

				plateConfig.global_health_height = value
				
				-- do not propagate during import or profile switch!
				if not PlaterOptionsPanelFrame:IsShown() or profilesFrame.IsImporting then
					return
				end

				plateConfig.friendlyplayer.health[2] = value
				plateConfig.friendlyplayer.health_incombat[2] = value

				plateConfig.enemyplayer.health[2] = value
				plateConfig.enemyplayer.health_incombat[2] = value

				plateConfig.friendlynpc.health[2] = value
				plateConfig.friendlynpc.health_incombat[2] = value

				plateConfig.enemynpc.health[2] = value
				plateConfig.enemynpc.health_incombat[2] = value

				Plater.RefreshDBUpvalues()
				Plater.UpdateAllPlates(nil, true)
				PlaterOptionsPanelFrame.RefreshOptionsFrame()
			end,
			min = 1,
			max = 100,
			step = 1,
			name = "OPTIONS_HEALTHBAR_HEIGHT",
			desc = "OPTIONS_HEALTHBAR_SIZE_GLOBAL_DESC",
		},

		{type = "breakline"},
		
		{type = "label", get = function() return "OPTIONS_GENERALSETTINGS_TRANSPARENCY_ANCHOR_TITLE" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "toggle",
			get = function() return Plater.db.profile.transparency_behavior == 0x1 end,
			set = function (self, fixedparam, value) 

				if (not value) then
					local checkBoxRangeCheck = generalOptionsAnchor:GetWidgetById("transparency_rangecheck")
					checkBoxRangeCheck:SetValue(true)
					return
				end

				Plater.db.profile.transparency_behavior = 0x1
				Plater.db.profile.range_check_enabled = true
				Plater.db.profile.non_targeted_alpha_enabled = false

				local checkBoxNonTargets = generalOptionsAnchor:GetWidgetById("transparency_nontargets")
				checkBoxNonTargets:SetValue(false)
				local checkBoxAll = generalOptionsAnchor:GetWidgetById("transparency_both")
				checkBoxAll:SetValue(false)		
				local checkBoxNone = generalOptionsAnchor:GetWidgetById("transparency_none")
				checkBoxNone:SetValue(false)
				local checkBoxFocusTargetAlpha = generalOptionsAnchor:GetWidgetById("focus_target_alpha")
				checkBoxFocusTargetAlpha:Disable()
				local checkBoxDivisionByTwo = generalOptionsAnchor:GetWidgetById("transparency_division")
				checkBoxDivisionByTwo:Disable()
				Plater.RefreshDBUpvalues()
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_RANGECHECK_OUTOFRANGE", --Units Out of Your Range
			desc = "OPTIONS_RANGECHECK_OUTOFRANGE_DESC",
			boxfirst = true,
			id = "transparency_rangecheck",
			novolatile = true,
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.transparency_behavior == 0x2 end,
			set = function (self, fixedparam, value) 

				if (not value) then
					local checkBoxNonTargets = generalOptionsAnchor:GetWidgetById("transparency_nontargets")
					checkBoxNonTargets:SetValue(true)
					return
				end

				Plater.db.profile.transparency_behavior = 0x2
				Plater.db.profile.range_check_enabled = false
				Plater.db.profile.non_targeted_alpha_enabled = true

				local checkBoxRangeCheck = generalOptionsAnchor:GetWidgetById("transparency_rangecheck")
				checkBoxRangeCheck:SetValue(false)
				local checkBoxAll = generalOptionsAnchor:GetWidgetById("transparency_both")
				checkBoxAll:SetValue(false)				
				local checkBoxNone = generalOptionsAnchor:GetWidgetById("transparency_none")
				checkBoxNone:SetValue(false)
				local checkBoxFocusTargetAlpha = generalOptionsAnchor:GetWidgetById("focus_target_alpha")
				checkBoxFocusTargetAlpha:Enable()
				local checkBoxDivisionByTwo = generalOptionsAnchor:GetWidgetById("transparency_division")
				checkBoxDivisionByTwo:Disable()
				Plater.RefreshDBUpvalues()
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_RANGECHECK_NOTMYTARGET", --When a nameplate isn't your current target, alpha is reduced
			desc = "OPTIONS_RANGECHECK_NOTMYTARGET_DESC",
			boxfirst = true,
			id = "transparency_nontargets",
			novolatile = true,
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.transparency_behavior == 0x3 end,
			set = function (self, fixedparam, value) 

				if (not value) then
					local checkBoxAll = generalOptionsAnchor:GetWidgetById("transparency_both")
					checkBoxAll:SetValue(true)	
					return
				end

				Plater.db.profile.transparency_behavior = 0x3
				Plater.db.profile.range_check_enabled = true
				Plater.db.profile.non_targeted_alpha_enabled = true

				local checkBoxRangeCheck = generalOptionsAnchor:GetWidgetById("transparency_rangecheck")
				checkBoxRangeCheck:SetValue(false)
				local checkBoxNonTargets = generalOptionsAnchor:GetWidgetById("transparency_nontargets")
				checkBoxNonTargets:SetValue(false)
				local checkBoxNone = generalOptionsAnchor:GetWidgetById("transparency_none")
				checkBoxNone:SetValue(false)
				local checkBoxFocusTargetAlpha = generalOptionsAnchor:GetWidgetById("focus_target_alpha")
				checkBoxFocusTargetAlpha:Enable()
				local checkBoxDivisionByTwo = generalOptionsAnchor:GetWidgetById("transparency_division")
				checkBoxDivisionByTwo:Enable()
				Plater.RefreshDBUpvalues()
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_RANGECHECK_NOTMYTARGETOUTOFRANGE", --Out of Range + Isn't Your Target
			desc = "OPTIONS_RANGECHECK_NOTMYTARGETOUTOFRANGE_DESC",
			boxfirst = true,
			id = "transparency_both",
			novolatile = true,
		},	
		{
			type = "toggle",
			get = function() return Plater.db.profile.transparency_behavior == 0x4 end,
			set = function (self, fixedparam, value) 

				if (not value) then
					local checkBoxNone = generalOptionsAnchor:GetWidgetById("transparency_none")
					checkBoxNone:SetValue(true)
				end

				Plater.db.profile.transparency_behavior = 0x4
				Plater.db.profile.range_check_enabled = false
				Plater.db.profile.non_targeted_alpha_enabled = false

				local checkBoxRangeCheck = generalOptionsAnchor:GetWidgetById("transparency_rangecheck")
				checkBoxRangeCheck:SetValue(false)
				local checkBoxNonTargets = generalOptionsAnchor:GetWidgetById("transparency_nontargets")
				checkBoxNonTargets:SetValue(false)
				local checkBoxAll = generalOptionsAnchor:GetWidgetById("transparency_both")
				checkBoxAll:SetValue(false)	
				local checkBoxFocusTargetAlpha = generalOptionsAnchor:GetWidgetById("focus_target_alpha")
				checkBoxFocusTargetAlpha:Disable()
				local checkBoxDivisionByTwo = generalOptionsAnchor:GetWidgetById("transparency_division")
				checkBoxDivisionByTwo:Disable()
				Plater.RefreshDBUpvalues()
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_RANGECHECK_NONE", --Nothing
			desc = "OPTIONS_RANGECHECK_NONE_DESC",
			boxfirst = true,
			id = "transparency_none",
			novolatile = true,
		},

		{type = "blank"},
		{type = "label", get = function() return "General:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "toggle",
			boxfirst = true,
			get = function() return Plater.db.profile.focus_as_target_alpha end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.focus_as_target_alpha = value
				Plater.UpdateAllPlates()
			end,
			name = "Focus Target Alpha",
			desc = "Use 'target alpha' for focus targets as well.",
			id = "focus_target_alpha",
		},
		{
			type = "toggle",
			boxfirst = true,
			get = function() return Plater.db.profile.transparency_behavior_use_division end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.transparency_behavior_use_division = value
				Plater.UpdateAllPlates()
			end,
			name = "Extra Contrast",
			desc = "When the unit is out of range and isn't your target, alpha is greatly reduced.",
			id = "transparency_division",
		},

		--no combat alpha
		{
			type = "toggle",
			boxfirst = true,
			get = function() return Plater.db.profile.not_affecting_combat_enabled end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.not_affecting_combat_enabled = value
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_NOCOMBATALPHA_ENABLED", --Use No Combat Alpha
			desc = "OPTIONS_NOCOMBATALPHA_ENABLED_DESC",
		},
		{
			type = "range",
			get = function() return Plater.db.profile.not_affecting_combat_alpha end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.not_affecting_combat_alpha = value
				Plater.UpdateAllPlates()
			end,
			min = 0,
			max = 1,
			step = 0.1,
			name = "OPTIONS_AMOUNT", --No Combat Alpha Amount
			desc = "OPTIONS_NOCOMBATALPHA_AMOUNT_DESC",
			usedecimals = true,
		},

		{type = "blank"},
		
		{type = "label", get = function() return "Range Check By Yards - Enemy" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},		
	}
	
	if IS_WOW_PROJECT_MAINLINE then
		local playerSpecs = Plater.SpecList [select (2, UnitClass ("player"))]
		for specID, _ in pairs (playerSpecs) do
			local specId, specName, specDescription, specIcon, specBackground, specRole, specClass = GetSpecializationInfoByID(specID)
			if specId then
				tinsert (options_table1, {
					type = "select",
					get = function() return PlaterDBChr.spellRangeCheckRangeEnemy [specID] end,
					values = function() 
						local onSelectFunc = function (_, _, range)
							PlaterDBChr.spellRangeCheckRangeEnemy [specID] = range
							PlaterDBChr.spellRangeCheckRangeEnemy [1444] = range -- workaround for "DAMAGER" (level 1-10) spec
							Plater.GetSpellForRangeCheck()
						end
						local t = {}
						local checkers = LibRangeCheck:GetHarmCheckers(true)
						for range, checker in checkers do
							tinsert (t, {label = range, onclick = onSelectFunc, value = range})
						end
						return t
					end,
					--the string between two '@' make the framework to consider it a PhraseID for the language system
					name = "|T" .. specIcon .. ":16:16|t " .. "@OPTIONS_GENERALSETTINGS_TRANSPARENCY_RANGECHECK@",
					desc = "OPTIONS_GENERALSETTINGS_TRANSPARENCY_RANGECHECK_SPEC_DESC",
				})
			end
		end
	else
		local playerClass = select (3, UnitClass ("player"))
		tinsert (options_table1, {
			type = "select",
			get = function() return PlaterDBChr.spellRangeCheckRangeEnemy [playerClass] end,
			values = function() 
				local onSelectFunc = function (_, _, range)
					PlaterDBChr.spellRangeCheckRangeEnemy [playerClass] = range
					Plater.GetSpellForRangeCheck()
				end
				local t = {}
				local checkers = LibRangeCheck:GetHarmCheckers(true)
				for range, checker in checkers do
					tinsert (t, {label = range, onclick = onSelectFunc, value = range})
				end
				return t
			end,
			name = "OPTIONS_GENERALSETTINGS_TRANSPARENCY_RANGECHECK",
			desc = "OPTIONS_GENERALSETTINGS_TRANSPARENCY_RANGECHECK_SPEC_DESC",
		})
	end
	
	local options_table1_continue1 = {
	
		{type = "blank"},
	
		{type = "label", get = function() return "Range Check By Yards - Friendly" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		
	}
	
	for _, t in ipairs (options_table1_continue1) do
		tinsert (options_table1, t)
	end
	
	if IS_WOW_PROJECT_MAINLINE then
		local playerSpecs = Plater.SpecList [select (2, UnitClass ("player"))]
		for specID, _ in pairs (playerSpecs) do
			local spec_id, spec_name, spec_description, spec_icon, spec_background, spec_role, spec_class = GetSpecializationInfoByID (specID)
			if spec_id then
				tinsert (options_table1, {
					type = "select",
					get = function() return PlaterDBChr.spellRangeCheckRangeFriendly [specID] end,
					values = function() 
						local onSelectFunc = function (_, _, range)
							PlaterDBChr.spellRangeCheckRangeFriendly [specID] = range
							PlaterDBChr.spellRangeCheckRangeFriendly [1444] = range -- workaround for "DAMAGER" (level 1-10) spec
							Plater.GetSpellForRangeCheck()
						end
						local t = {}
						local checkers = LibRangeCheck:GetFriendCheckers(true)
						for range, checker in checkers do
							tinsert (t, {label = range, onclick = onSelectFunc, value = range})
						end
						return t
					end,
					name = "|T" .. spec_icon .. ":16:16|t " .. "@OPTIONS_GENERALSETTINGS_TRANSPARENCY_RANGECHECK@",
					desc = "OPTIONS_GENERALSETTINGS_TRANSPARENCY_RANGECHECK_SPEC_DESC",
				})
			end
		end
	else
		local playerClass = select (3, UnitClass ("player"))
		tinsert (options_table1, {
			type = "select",
			get = function() return PlaterDBChr.spellRangeCheckRangeFriendly [playerClass] end,
			values = function() 
				local onSelectFunc = function (_, _, range)
					PlaterDBChr.spellRangeCheckRangeFriendly [playerClass] = range
					Plater.GetSpellForRangeCheck()
				end
				local t = {}
				local checkers = LibRangeCheck:GetFriendCheckers(true)
				for range, checker in checkers do
					tinsert (t, {label = range, onclick = onSelectFunc, value = range})
				end
				return t
			end,
			name = "OPTIONS_GENERALSETTINGS_TRANSPARENCY_RANGECHECK",
			desc = "OPTIONS_GENERALSETTINGS_TRANSPARENCY_RANGECHECK_SPEC_DESC",
		})
	end

	local options_table1_continue2 = {
	
		{type = "breakline"},
		--enemies
		
		{type = "label", get = function() return "OPTIONS_ALPHABYFRAME_TITLE_ENEMIES" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		
		{
			type = "toggle",
			boxfirst = true,
			get = function() return Plater.db.profile.transparency_behavior_on_enemies end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.transparency_behavior_on_enemies = value
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_ALPHABYFRAME_ENABLE_ENEMIES", --Enable for enemies
			desc = "OPTIONS_ALPHABYFRAME_ENABLE_ENEMIES_DESC",
		},
		
		{type = "break"},
		
		{
			type = "range",
			get = function() return Plater.db.profile.range_check_alpha end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.range_check_alpha = value
				Plater.RefreshDBUpvalues()
				Plater.UpdateAllPlates()
			end,
			min = 0,
			max = 1,
			step = 0.1,
			name = "OPTIONS_ALPHABYFRAME_DEFAULT", --default
			desc = "OPTIONS_ALPHABYFRAME_DEFAULT_DESC",
			usedecimals = true,
		},
		{
			type = "range",
			get = function() return Plater.db.profile.range_check_health_bar_alpha end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.range_check_health_bar_alpha = value
				Plater.RefreshDBUpvalues()
				Plater.UpdateAllPlates()
			end,
			min = 0,
			max = 1,
			step = 0.1,
			name = "OPTIONS_HEALTHBAR",
			desc = "OPTIONS_ALPHABYFRAME_ALPHAMULTIPLIER",
			usedecimals = true,
		},
		{
			type = "range",
			get = function() return Plater.db.profile.range_check_cast_bar_alpha end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.range_check_cast_bar_alpha = value
				Plater.RefreshDBUpvalues()
				Plater.UpdateAllPlates()
			end,
			min = 0,
			max = 1,
			step = 0.1,
			name = "OPTIONS_TABNAME_CASTBAR",
			desc = "OPTIONS_ALPHABYFRAME_ALPHAMULTIPLIER",
			usedecimals = true,
		},
		{
			type = "range",
			get = function() return Plater.db.profile.range_check_power_bar_alpha end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.range_check_power_bar_alpha = value
				Plater.RefreshDBUpvalues()
				Plater.UpdateAllPlates()
			end,
			min = 0,
			max = 1,
			step = 0.1,
			name = "OPTIONS_POWERBAR",
			desc = "OPTIONS_ALPHABYFRAME_ALPHAMULTIPLIER",
			usedecimals = true,
		},
		{
			type = "range",
			get = function() return Plater.db.profile.range_check_buffs_alpha end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.range_check_buffs_alpha = value
				Plater.RefreshDBUpvalues()
				Plater.UpdateAllPlates()
			end,
			min = 0,
			max = 1,
			step = 0.1,
			name = "OPTIONS_BUFFFRAMES",
			desc = "OPTIONS_ALPHABYFRAME_ALPHAMULTIPLIER",
			usedecimals = true,
		},
		{
			type = "range",
			get = function() return Plater.db.profile.range_check_in_range_or_target_alpha end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.range_check_in_range_or_target_alpha = value
				Plater.RefreshDBUpvalues()
				Plater.UpdateAllPlates()
			end,
			min = 0,
			max = 1,
			step = 0.1,
			name = "OPTIONS_ALPHABYFRAME_TARGET_INRANGE", --In-Range/Target alpha
			desc = "OPTIONS_ALPHABYFRAME_TARGET_INRANGE_DESC",
			usedecimals = true,
		},
		
		{type = "break"},
		--friendlies
		
		{type = "label", get = function() return "OPTIONS_ALPHABYFRAME_TITLE_FRIENDLY" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		
		{
			type = "toggle",
			boxfirst = true,
			get = function() return Plater.db.profile.transparency_behavior_on_friendlies end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.transparency_behavior_on_friendlies = value
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_ALPHABYFRAME_ENABLE_FRIENDLY", --Enable for friendlies
			desc = "OPTIONS_ALPHABYFRAME_ENABLE_FRIENDLY_DESC",
		},
		
		{type = "break"},
		
		{
			type = "range",
			get = function() return Plater.db.profile.range_check_alpha_friendlies end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.range_check_alpha_friendlies = value
				Plater.RefreshDBUpvalues()
				Plater.UpdateAllPlates()
			end,
			min = 0,
			max = 1,
			step = 0.1,
			name = "OPTIONS_ALPHABYFRAME_DEFAULT", --Overall
			desc = "OPTIONS_ALPHABYFRAME_DEFAULT_DESC",
			usedecimals = true,
		},
		{
			type = "range",
			get = function() return Plater.db.profile.range_check_health_bar_alpha_friendlies end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.range_check_health_bar_alpha_friendlies = value
				Plater.RefreshDBUpvalues()
				Plater.UpdateAllPlates()
			end,
			min = 0,
			max = 1,
			step = 0.1,
			name = "OPTIONS_HEALTHBAR",
			desc = "OPTIONS_ALPHABYFRAME_ALPHAMULTIPLIER",
			usedecimals = true,
		},
		{
			type = "range",
			get = function() return Plater.db.profile.range_check_cast_bar_alpha_friendlies end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.range_check_cast_bar_alpha_friendlies = value
				Plater.RefreshDBUpvalues()
				Plater.UpdateAllPlates()
			end,
			min = 0,
			max = 1,
			step = 0.1,
			name = "OPTIONS_TABNAME_CASTBAR",
			desc = "OPTIONS_ALPHABYFRAME_ALPHAMULTIPLIER",
			usedecimals = true,
		},
		{
			type = "range",
			get = function() return Plater.db.profile.range_check_power_bar_alpha_friendlies end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.range_check_power_bar_alpha_friendlies = value
				Plater.RefreshDBUpvalues()
				Plater.UpdateAllPlates()
			end,
			min = 0,
			max = 1,
			step = 0.1,
			name = "OPTIONS_POWERBAR",
			desc = "OPTIONS_ALPHABYFRAME_ALPHAMULTIPLIER",
			usedecimals = true,
		},
		{
			type = "range",
			get = function() return Plater.db.profile.range_check_buffs_alpha_friendlies end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.range_check_buffs_alpha_friendlies = value
				Plater.RefreshDBUpvalues()
				Plater.UpdateAllPlates()
			end,
			min = 0,
			max = 1,
			step = 0.1,
			name = "OPTIONS_BUFFFRAMES",
			desc = "OPTIONS_ALPHABYFRAME_ALPHAMULTIPLIER",
			usedecimals = true,
		},
		{
			type = "range",
			get = function() return Plater.db.profile.range_check_in_range_or_target_alpha_friendlies end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.range_check_in_range_or_target_alpha_friendlies = value
				Plater.RefreshDBUpvalues()
				Plater.UpdateAllPlates()
			end,
			min = 0,
			max = 1,
			step = 0.1,
			name = "OPTIONS_ALPHABYFRAME_TARGET_INRANGE",
			desc = "OPTIONS_ALPHABYFRAME_TARGET_INRANGE_DESC",
			usedecimals = true,
		},

		{type = "breakline"},

		{type = "label", get = function() return "OPTIONS_INDICATORS" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		
		{
			type = "toggle",
			boxfirst = true,
			get = function() return Plater.db.profile.indicator_pet end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.indicator_pet = value
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_ICON_PET",
			desc = "OPTIONS_ICON_PET",
		},

		{
			type = "toggle",
			boxfirst = true,
			get = function() return Plater.db.profile.indicator_shield end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.indicator_shield = value
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_SHIELD_BAR",
			desc = "OPTIONS_SHIELD_BAR",
		},
		
		{
			type = "toggle",
			boxfirst = true,
			get = function() return Plater.db.profile.health_cutoff end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.health_cutoff = value
				Plater.GetHealthCutoffValue()
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_EXECUTERANGE",
			desc = "OPTIONS_EXECUTERANGE_DESC",
		},
		
		{
			type = "toggle",
			boxfirst = true,
			get = function() return Plater.db.profile.health_cutoff_upper end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.health_cutoff_upper = value
				Plater.GetHealthCutoffValue()
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_EXECUTERANGE_HIGH_HEALTH",
			desc = "OPTIONS_EXECUTERANGE_HIGH_HEALTH_DESC",
			hidden = IS_WOW_PROJECT_NOT_MAINLINE,
		},
		
		{
			type = "toggle",
			get = function() return Plater.db.profile.health_cutoff_extra_glow end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.health_cutoff_extra_glow = value
				Plater.UpdateAllPlates()
			end,
			name = "Add Extra Glow to Execute Range",
			desc = "Add Extra Glow to Execute Range",
		},

		{
			type = "toggle",
			boxfirst = true,
			get = function() return Plater.db.profile.indicator_worldboss end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.indicator_worldboss = value
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_ICON_WORLDBOSS",
			desc = "OPTIONS_ICON_WORLDBOSS",
		},
		{
			type = "toggle",
			boxfirst = true,
			get = function() return Plater.db.profile.indicator_elite end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.indicator_elite = value
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_ICON_ELITE",
			desc = "OPTIONS_ICON_ELITE",
		},
		{
			type = "toggle",
			boxfirst = true,
			get = function() return Plater.db.profile.indicator_rare end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.indicator_rare = value
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_ICON_RARE",
			desc = "OPTIONS_ICON_RARE",
		},
		{
			type = "toggle",
			boxfirst = true,
			get = function() return Plater.db.profile.indicator_quest end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.indicator_quest = value
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_ICON_QUEST",
			desc = "OPTIONS_ICON_QUEST",
		},
		{
			type = "toggle",
			boxfirst = true,
			get = function() return Plater.db.profile.indicator_faction end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.indicator_faction = value
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_ICON_ENEMYFACTION",
			desc = "OPTIONS_ICON_ENEMYFACTION",
		},
		{
			type = "toggle",
			boxfirst = true,
			get = function() return Plater.db.profile.indicator_enemyclass end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.indicator_enemyclass = value
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_ICON_ENEMYCLASS",
			desc = "OPTIONS_ICON_ENEMYCLASS",
		},
		
		{
			type = "toggle",
			boxfirst = true,
			get = function() return Plater.db.profile.indicator_spec end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.indicator_spec = value
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_ICON_ENEMYSPEC",
			desc = "OPTIONS_ICON_ENEMYSPEC",
		},
		{
			type = "toggle",
			boxfirst = true,
			get = function() return Plater.db.profile.indicator_friendlyfaction end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.indicator_friendlyfaction = value
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_ICON_FRIENDLYFACTION",
			desc = "OPTIONS_ICON_FRIENDLYFACTION",
		},
		{
			type = "toggle",
			boxfirst = true,
			get = function() return Plater.db.profile.indicator_friendlyclass end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.indicator_friendlyclass = value
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_ICON_FRIENDLYCLASS",
			desc = "OPTIONS_ICON_FRIENDLYCLASS",
		},
		{
			type = "toggle",
			boxfirst = true,
			get = function() return Plater.db.profile.indicator_friendlyspec end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.indicator_friendlyspec = value
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_ICON_FRIENDLY_SPEC",
			desc = "OPTIONS_ICON_FRIENDLY_SPEC",
		},
		{
			type = "range",
			boxfirst = true,
			get = function() return Plater.db.profile.indicator_scale end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.indicator_scale = value
				Plater.UpdateAllPlates()
			end,
			min = 0.2,
			max = 3,
			step = 0.01,
			usedecimals = true,
			name = "OPTIONS_SCALE",
			desc = "OPTIONS_SCALE",
		},

		--indicator icon anchor
		{
			type = "select",
			get = function() return Plater.db.profile.indicator_anchor.side end,
			values = function() return build_anchor_side_table (nil, "indicator_anchor") end,
			name = "OPTIONS_ANCHOR",
			desc = "OPTIONS_ANCHOR_TARGET_SIDE",
		},
		--indicator icon anchor x offset
		{
			type = "range",
			get = function() return Plater.db.profile.indicator_anchor.x end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.indicator_anchor.x = value
				Plater.UpdateAllPlates()
			end,
			min = -100,
			max = 100,
			step = 1,
			usedecimals = true,
			name = "OPTIONS_XOFFSET",
			desc = "OPTIONS_MOVE_HORIZONTAL",
		},
		--indicator icon anchor y offset
		{
			type = "range",
			get = function() return Plater.db.profile.indicator_anchor.y end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.indicator_anchor.y = value
				Plater.UpdateAllPlates()
			end,
			min = -100,
			max = 100,
			step = 1,
			usedecimals = true,
			name = "OPTIONS_YOFFSET",
			desc = "OPTIONS_MOVE_VERTICAL",
		},
	}

	for _, t in ipairs (options_table1_continue2) do
		tinsert (options_table1, t)
	end
	options_table1.always_boxfirst = true
	options_table1.language_addonId = addonId
	options_table1.Name = "General Options"
	DF:BuildMenu (generalOptionsAnchor, options_table1, 0, 0, mainHeightSize, false, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template, globalCallback)

local checkBoxDivisionByTwo = generalOptionsAnchor:GetWidgetById("transparency_division")
if (Plater.db.profile.transparency_behavior == 0x3) then
	checkBoxDivisionByTwo:Enable()
else
	checkBoxDivisionByTwo:Disable()
end
local checkBoxBlizzPlateAlpha = generalOptionsAnchor:GetWidgetById("transparency_blizzard_alpha")
if (Plater.db.profile.use_ui_parent) then
	checkBoxBlizzPlateAlpha:Enable()
else
	checkBoxBlizzPlateAlpha:Disable()
end

frontPageFrame.RefreshOptionsOrig = frontPageFrame.RefreshOptionsOrig or frontPageFrame.RefreshOptions
frontPageFrame.RefreshOptions = function ()
	frontPageFrame:RefreshOptionsOrig()
	generalOptionsAnchor:RefreshOptions()
end
	
------------------------------------------------	
--order functions

	local on_select_friendlyplayer_order = function (_, _, value)
		Plater.db.profile.plate_config.friendlyplayer.order = value
		Plater.UpdateAllPlates()
	end
	local on_select_friendlynpc_order = function (_, _, value)
		Plater.db.profile.plate_config.friendlynpc.order = value
		Plater.UpdateAllPlates()
	end	
	local on_select_enemyplayer_order = function (_, _, value)
		Plater.db.profile.plate_config.enemyplayer.order = value
		Plater.UpdateAllPlates()
	end
	local on_select_enemynpc_order = function (_, _, value)
		Plater.db.profile.plate_config.enemynpc.order = value
		Plater.UpdateAllPlates()
	end
	
------------------------------------------------	
--FriendlyPC painel de op��es ~friendly ~friendlynpc
	
	local on_select_friendly_playername_font = function (_, _, value)
		Plater.db.profile.plate_config.friendlyplayer.actorname_text_font = value
		Plater.UpdateAllPlates()
	end
	local on_select_friendly_playercastname_font = function (_, _, value)
		Plater.db.profile.plate_config.friendlyplayer.spellname_text_font = value
		Plater.UpdateAllPlates()
	end
	local on_select_friendlyplayer_level_text_font = function (_, _, value)
		Plater.db.profile.plate_config.friendlyplayer.level_text_font = value
		Plater.UpdateAllPlates()
	end
	local on_select_friendlyplayer_percent_text_font = function (_, _, value)
		Plater.db.profile.plate_config.friendlyplayer.percent_text_font = value
		Plater.UpdateAllPlates()
	end
	local on_select_friendlyplayer_spellpercent_text_font = function (_, _, value)
		Plater.db.profile.plate_config.friendlyplayer.spellpercent_text_font = value
		Plater.UpdateAllPlates()
	end

	local options_table3 = {
	
	
		{type = "label", get = function() return "General Settings:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		
		{
			type = "select",
			get = function() return "player" end,
			values = function() return copy_settings_options end,
			name = "Copy",
			desc = "Copy settings from another tab.\n\nWhen selecting an option a confirmation box is shown to confirm the copy.",
		},
		
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.module_enabled end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.module_enabled = value
				ReloadUI()
			end,
			nocombat = true,
			name = "Module Enabled",
			desc = "Enable Plater nameplates for friendly players.\n\n" .. ImportantText .. "Forces a /reload on change.\nThis option is dependent on the client`s nameplate state (on/off)",
		},
		
		{
			type = "toggle",
			get = function() return Plater.db.profile.use_playerclass_color end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.use_playerclass_color = value
				Plater.UpdateAllPlates()
			end,
			name = "Use Class Colors",
			desc = "Player name plates uses the player class color",
		},
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_PLAYER].fixed_class_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_PLAYER].fixed_class_color
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllPlates()
			end,
			name = "Fixed Color",
			desc = "Use this color for health-bars and guild/friend text when not using class colors.\nGuild and friend colors for the name/guild texts can be overwritten with their respective color settings below.",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_PLAYER].only_damaged end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_PLAYER].only_damaged = value
				Plater.UpdateAllPlates()
			end,
			name = "Only Damaged Players",
			desc = "Hide the health bar when a friendly character has full health.",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_PLAYER].only_thename end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_PLAYER].only_thename = value
				Plater.UpdateAllPlates()
			end,
			name = "Only Show Player Name",
			desc = "Hide the health bar, only show the character name.\n\n" .. ImportantText .. "If 'Only Damaged Players' is selected and the player is damaged, this setting will be overwritten and the health bar will be shown.",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.show_guild_name end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.show_guild_name = value
				Plater.UpdateAllPlates (true)
			end,
			name = "Show Guild Name",
			desc = "Show Guild Name",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.click_through end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.click_through = value
				Plater.UpdatePlateClickSpace (nil, true)
			end,
			name = "Click Through",
			desc = "Friendly player nameplates won't receive mouse clicks.\n\n" .. ImportantText .. "also affects friendly npcs and can affect some neutral npcs too.",
		},		

		{type = "blank"},
		{type = "label", get = function() return "Aura Frame:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		--y offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.buff_frame_y_offset end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.buff_frame_y_offset = value
				Plater.UpdateAllPlates()
			end,
			min = -100,
			max = 100,
			step = 1,
			usedecimals = true,
			name = "OPTIONS_YOFFSET",
			desc = "OPTIONS_YOFFSET_DESC",
		},
		
		{type = "label", get = function() return "Cast Bar:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		--x offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.castbar_offset_x end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.castbar_offset_x = value
				Plater.UpdateAllPlates()
			end,
			min = -128,
			max = 128,
			step = 1,
			usedecimals = true,
			name = "OPTIONS_XOFFSET",
			desc = "OPTIONS_XOFFSET_DESC",
		},
		--y offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.castbar_offset end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.castbar_offset = value
				Plater.UpdateAllPlates()
			end,
			min = -128,
			max = 128,
			step = 1,
			usedecimals = true,
			name = "OPTIONS_YOFFSET",
			desc = "OPTIONS_YOFFSET_DESC",
		},
		
		{type = "blank"},
		{type = "label", get = function() return "Player Name Text Colors" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		--player name color
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_PLAYER].actorname_use_class_color end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_PLAYER].actorname_use_class_color = value
				Plater.UpdateAllPlates()
			end,
			name = "Use Class Colors",
			desc = "Player name/guild text uses the class color instead of the selected color. Guild or Friend colors will overwrite this, if used.",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_PLAYER].actorname_use_friends_color end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_PLAYER].actorname_use_friends_color = value
				Plater.UpdateAllPlates()
			end,
			name = "Use Friends Colors",
			desc = "Player name/guild text uses the selected friend color, if the player is on your friend list.",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_PLAYER].actorname_use_guild_color end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_PLAYER].actorname_use_guild_color = value
				Plater.UpdateAllPlates()
			end,
			name = "Use Guild Colors",
			desc = "Player name/guild text uses the selected guild color, if it is a guild mate.",
		},
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.plate_config.friendlyplayer.actorname_text_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.plate_config.friendlyplayer.actorname_text_color
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_COLOR",
			desc = "The color of the text, if neither class, friend or guild colors are used.",
		},
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_PLAYER].actorname_friend_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_PLAYER].actorname_friend_color
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllPlates()
			end,
			name = "Friend Color",
			desc = "Use this color for name/guild texts if the player is your friend.",
		},
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_PLAYER].actorname_guild_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_PLAYER].actorname_guild_color
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllPlates()
			end,
			name = "Guild Color",
			desc = "Use this color for name/guild texts if the player is in your guild.",
		},
		
		{type = "breakline"},
	
		--health bar size out of combat
		{type = "label", get = function() return "Health Bar Size out of Combat:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.health[1] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.health[1] = value
				Plater.UpdateAllPlates (nil, true)
			end,
			min = 50,
			max = 300,
			step = 1,
			name = "OPTIONS_WIDTH",
			desc = "Width of the health bar when out of combat.",
		},
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.health[2] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.health[2] = value
				Plater.UpdateAllPlates (nil, true)
			end,
			min = 1,
			max = 100,
			step = 1,
			name = "OPTIONS_HEIGHT",
			desc = "Height of the health bar when out of combat.",
		},
		
		--health bar size in combat
		{type = "label", get = function() return "Health Bar Size in Combat:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.health_incombat[1] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.health_incombat[1] = value
				Plater.UpdateAllPlates (nil, true)
			end,
			min = 50,
			max = 300,
			step = 1,
			name = "OPTIONS_WIDTH",
			desc = "Width of the health bar when in combat.",
		},
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.health_incombat[2] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.health_incombat[2] = value
				Plater.UpdateAllPlates (nil, true)
			end,
			min = 1,
			max = 100,
			step = 1,
			name = "OPTIONS_HEIGHT",
			desc = "Height of the health bar when in combat.",
		},
		
		{type = "blank"},
		
		--cast bar size out of combat
		{type = "label", get = function() return "Cast Bar Size out of Combat:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.cast[1] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.cast[1] = value
				Plater.UpdateAllPlates()
			end,
			min = 50,
			max = 300,
			step = 1,
			name = "OPTIONS_WIDTH",
			desc = "Width of the cast bar when out of combat.",
		},
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.cast[2] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.cast[2] = value
				Plater.UpdateAllPlates()
			end,
			min = 1,
			max = 100,
			step = 1,
			name = "OPTIONS_HEIGHT",
			desc = "Height of the cast bar when out of combat.",
		},
		--cast bar size out of combat
		{type = "label", get = function() return "Cast Bar Size in Combat:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.cast_incombat[1] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.cast_incombat[1] = value
				Plater.UpdateAllPlates()
			end,
			min = 50,
			max = 300,
			step = 1,
			name = "OPTIONS_WIDTH",
			desc = "Width of the cast bar when in combat.",
		},
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.cast_incombat[2] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.cast_incombat[2] = value
				Plater.UpdateAllPlates()
			end,
			min = 1,
			max = 100,
			step = 1,
			name = "OPTIONS_HEIGHT",
			desc = "Height of the cast bar when in combat.",
		},
		
		{type = "blank"},
		--player name size
		{type = "label", get = function() return "Player Name Text:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.actorname_text_size end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.actorname_text_size = value
				Plater.db.profile.plate_config.friendlyplayer.actorname_text_spacing = value-1
				Plater.UpdateAllPlates()
			end,
			min = 6,
			max = 99,
			step = 1,
			name = "OPTIONS_SIZE",
			desc = "OPTIONS_TEXT_SIZE",
		},
		--player name font
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.actorname_text_font end,
			values = function() return DF:BuildDropDownFontList (on_select_friendly_playername_font) end,
			name = "OPTIONS_FONT",
			desc = "OPTIONS_TEXT_FONT",
		},
		
		--text outline options
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.actorname_text_outline end,
			values = function() return build_outline_modes_table ("friendlyplayer", "actorname_text_outline") end,
			name = "OPTIONS_OUTLINE",
			desc = "OPTIONS_OUTLINE",
		},
		
		--text shadow color
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.plate_config.friendlyplayer.actorname_text_shadow_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.plate_config.friendlyplayer.actorname_text_shadow_color
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_SHADOWCOLOR",
			desc = "OPTIONS_TOGGLE_TO_CHANGE",
		},
		
		--npc name anchor
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.actorname_text_anchor.side end,
			values = function() return build_anchor_side_table ("friendlyplayer", "actorname_text_anchor") end,
			name = "OPTIONS_ANCHOR",
			desc = "OPTIONS_ANCHOR_TARGET_SIDE",
		},
		--npc name anchor x offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.actorname_text_anchor.x end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.actorname_text_anchor.x = value
				Plater.UpdateAllPlates()
			end,
			min = -100,
			max = 100,
			step = 1,
			usedecimals = true,
			name = "OPTIONS_XOFFSET",
			desc = "OPTIONS_XOFFSET_DESC",
		},
		--npc name anchor x offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.actorname_text_anchor.y end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.actorname_text_anchor.y = value
				Plater.UpdateAllPlates()
			end,
			min = -100,
			max = 100,
			step = 1,
			usedecimals = true,
			name = "OPTIONS_YOFFSET",
			desc = "OPTIONS_YOFFSET_DESC",
		},	
		
		--cast text size
		{type = "breakline"},
		
		--cast text size
		{type = "label", get = function() return "Spell Name Text:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.spellname_text_size end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.spellname_text_size = value
				Plater.UpdateAllPlates()
			end,
			min = 6,
			max = 99,
			step = 1,
			name = "OPTIONS_SIZE",
			desc = "OPTIONS_TEXT_SIZE",
		},
		--cast text font
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.spellname_text_font end,
			values = function() return DF:BuildDropDownFontList (on_select_friendly_playercastname_font) end,
			name = "OPTIONS_FONT",
			desc = "OPTIONS_TEXT_FONT",
		},
		--cast text color
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.plate_config.friendlyplayer.spellname_text_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.plate_config.friendlyplayer.spellname_text_color
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_COLOR",
			desc = "OPTIONS_TEXT_COLOR",
		},
		
		--text outline options
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.spellname_text_outline end,
			values = function() return build_outline_modes_table ("friendlyplayer", "spellname_text_outline") end,
			name = "OPTIONS_OUTLINE",
			desc = "OPTIONS_OUTLINE",
		},
		
		--text shadow color
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.plate_config.friendlyplayer.spellname_text_shadow_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.plate_config.friendlyplayer.spellname_text_shadow_color
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_SHADOWCOLOR",
			desc = "OPTIONS_TOGGLE_TO_CHANGE",
		},

		--spell name text anchor
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.spellname_text_anchor.side end,
			values = function() return build_anchor_side_table ("friendlyplayer", "spellname_text_anchor") end,
			name = "OPTIONS_ANCHOR",
			desc = "OPTIONS_ANCHOR_TARGET_SIDE",
		},
		--spell name text anchor x offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.spellname_text_anchor.x end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.spellname_text_anchor.x = value
				Plater.UpdateAllPlates()
			end,
			min = -100,
			max = 100,
			step = 1,
			usedecimals = true,
			name = "OPTIONS_XOFFSET",
			desc = "OPTIONS_XOFFSET_DESC",
		},
		--spell name text anchor x offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.spellname_text_anchor.y end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.spellname_text_anchor.y = value
				Plater.UpdateAllPlates()
			end,
			min = -100,
			max = 100,
			step = 1,
			usedecimals = true,
			name = "OPTIONS_YOFFSET",
			desc = "OPTIONS_YOFFSET_DESC",
		},
		
		
		{type = "blank"},
		{type = "label", get = function() return "Spell Cast Time Text:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.spellpercent_text_enabled end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.spellpercent_text_enabled = value
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_ENABLED",
			desc = "Show the cast time progress.",
		},
		--cast time text
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.spellpercent_text_size end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.spellpercent_text_size = value
				Plater.UpdateAllPlates()
			end,
			min = 6,
			max = 99,
			step = 1,
			name = "OPTIONS_SIZE",
			desc = "OPTIONS_TEXT_SIZE",
		},
		--cast time text font
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.spellpercent_text_font end,
			values = function() return DF:BuildDropDownFontList (on_select_friendlyplayer_spellpercent_text_font) end,
			name = "OPTIONS_FONT",
			desc = "OPTIONS_TEXT_FONT",
		},
		
		--text outline options
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.spellpercent_text_outline end,
			values = function() return build_outline_modes_table ("friendlyplayer", "spellpercent_text_outline") end,
			name = "OPTIONS_OUTLINE",
			desc = "OPTIONS_OUTLINE",
		},
		
		--text shadow color
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.plate_config.friendlyplayer.spellpercent_text_shadow_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.plate_config.friendlyplayer.spellpercent_text_shadow_color
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_SHADOWCOLOR",
			desc = "OPTIONS_TOGGLE_TO_CHANGE",
		},		
		
		--cast time text color
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.plate_config.friendlyplayer.spellpercent_text_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.plate_config.friendlyplayer.spellpercent_text_color
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_COLOR",
			desc = "OPTIONS_TEXT_COLOR",
		},
		
		--cast time anchor
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.spellpercent_text_anchor.side end,
			values = function() return build_anchor_side_table ("friendlyplayer", "spellpercent_text_anchor") end,
			name = "OPTIONS_ANCHOR",
			desc = "OPTIONS_ANCHOR_TARGET_SIDE",
		},
		--cast time anchor x offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.spellpercent_text_anchor.x end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.spellpercent_text_anchor.x = value
				Plater.UpdateAllPlates()
			end,
			min = -100,
			max = 100,
			step = 1,
			usedecimals = true,
			name = "OPTIONS_XOFFSET",
			desc = "OPTIONS_XOFFSET_DESC",
		},
		--cast time anchor x offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.spellpercent_text_anchor.y end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.spellpercent_text_anchor.y = value
				Plater.UpdateAllPlates()
			end,
			min = -100,
			max = 100,
			step = 1,
			usedecimals = true,
			name = "OPTIONS_YOFFSET",
			desc = "OPTIONS_YOFFSET_DESC",
		},		

		{type = "breakline"},
		
		--percent text
		{type = "label", get = function() return "Health Information:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		--enabled
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.percent_text_enabled end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.percent_text_enabled = value
				Plater.UpdateSettingsCache()
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_ENABLED",
			desc = "Show the percent text.",
		},
		--out of combat
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.percent_text_ooc end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.percent_text_ooc = value
				Plater.UpdateSettingsCache()
				Plater.UpdateAllPlates()
			end,
			name = "Out of Combat",
			desc = "Show the percent even when isn't in combat.",
		},
		--percent amount
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.percent_show_percent end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.percent_show_percent = value
				Plater.UpdateAllPlates()
			end,
			name = "Show Percent Amount",
			desc = "Show Percent Amount",
		},		
		--health amount
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.percent_show_health end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.percent_show_health = value
				Plater.UpdateAllPlates()
			end,
			name = "Show Health Amount",
			desc = "Show Health Amount",
		},
		--health decimals
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.percent_text_show_decimals end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.percent_text_show_decimals = value
				Plater.UpdateAllPlates()
			end,
			name = "Show Decimals",
			desc = "Show Decimals",
		},
		
		--percent text size
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.percent_text_size end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.percent_text_size = value
				Plater.UpdateAllPlates()
			end,
			min = 6,
			max = 99,
			step = 1,
			name = "OPTIONS_SIZE",
			desc = "OPTIONS_TEXT_SIZE",
		},
		--percent text font
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.percent_text_font end,
			values = function() return DF:BuildDropDownFontList (on_select_friendlyplayer_percent_text_font) end,
			name = "OPTIONS_FONT",
			desc = "OPTIONS_TEXT_FONT",
		},

		--text outline options
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.percent_text_outline end,
			values = function() return build_outline_modes_table ("friendlyplayer", "percent_text_outline") end,
			name = "OPTIONS_OUTLINE",
			desc = "OPTIONS_OUTLINE",
		},
		
		--text shadow color
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.plate_config.friendlyplayer.percent_text_shadow_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.plate_config.friendlyplayer.percent_text_shadow_color
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_SHADOWCOLOR",
			desc = "OPTIONS_TOGGLE_TO_CHANGE",
		},		
		
		--pecent text color
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.plate_config.friendlyplayer.percent_text_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.plate_config.friendlyplayer.percent_text_color
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_COLOR",
			desc = "OPTIONS_TEXT_COLOR",
		},
		--percent text alpha
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.percent_text_alpha end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.percent_text_alpha = value
				Plater.UpdateAllPlates()
			end,
			min = 0,
			max = 1,
			step = 0.1,
			name = "OPTIONS_ALPHA",
			desc = "Set the transparency of the text.",
			usedecimals = true,
		},
		--percent anchor
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.percent_text_anchor.side end,
			values = function() return build_anchor_side_table ("friendlyplayer", "percent_text_anchor") end,
			name = "OPTIONS_ANCHOR",
			desc = "OPTIONS_ANCHOR_TARGET_SIDE",
		},
		--percent anchor x offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.percent_text_anchor.x end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.percent_text_anchor.x = value
				Plater.UpdateAllPlates()
			end,
			min = -100,
			max = 100,
			step = 1,
			usedecimals = true,
			name = "OPTIONS_XOFFSET",
			desc = "OPTIONS_XOFFSET_DESC",
		},
		--percent anchor x offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.percent_text_anchor.y end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.percent_text_anchor.y = value
				Plater.UpdateAllPlates()
			end,
			min = -100,
			max = 100,
			step = 1,
			usedecimals = true,
			name = "OPTIONS_YOFFSET",
			desc = "OPTIONS_YOFFSET_DESC",
		},
		

		--level text settings
		{type = "breakline"},
		{type = "label", get = function() return "Level Text:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		--level enabled
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.level_text_enabled end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.level_text_enabled = value
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_ENABLED",
			desc = "Check this box to show the level of the actor.",
		},
		--level text size
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.level_text_size end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.level_text_size = value
				Plater.UpdateAllPlates()
			end,
			min = 6,
			max = 99,
			step = 1,
			name = "OPTIONS_SIZE",
			desc = "OPTIONS_TEXT_SIZE",
		},
		--level text font
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.level_text_font end,
			values = function() return DF:BuildDropDownFontList (on_select_friendlyplayer_level_text_font) end,
			name = "OPTIONS_FONT",
			desc = "OPTIONS_TEXT_FONT",
		},
		
		--text outline options
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.level_text_outline end,
			values = function() return build_outline_modes_table ("friendlyplayer", "level_text_outline") end,
			name = "OPTIONS_OUTLINE",
			desc = "OPTIONS_OUTLINE",
		},
		
		--text shadow color
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.plate_config.friendlyplayer.level_text_shadow_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.plate_config.friendlyplayer.level_text_shadow_color
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_SHADOWCOLOR",
			desc = "OPTIONS_TOGGLE_TO_CHANGE",
		},		
		
		--level text alpha
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.level_text_alpha end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.level_text_alpha = value
				Plater.UpdateAllPlates()
			end,
			min = 0,
			max = 1,
			step = 0.1,
			name = "OPTIONS_ALPHA",
			desc = "Set the transparency of the text.",
			usedecimals = true,
		},
		--level anchor
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.level_text_anchor.side end,
			values = function() return build_anchor_side_table ("friendlyplayer", "level_text_anchor") end,
			name = "OPTIONS_ANCHOR",
			desc = "OPTIONS_ANCHOR_TARGET_SIDE",
		},
		--level anchor x offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.level_text_anchor.x end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.level_text_anchor.x = value
				Plater.UpdateAllPlates()
			end,
			min = -100,
			max = 100,
			step = 1,
			usedecimals = true,
			name = "OPTIONS_XOFFSET",
			desc = "OPTIONS_XOFFSET_DESC",
		},
		--level anchor x offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.level_text_anchor.y end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlyplayer.level_text_anchor.y = value
				Plater.UpdateAllPlates()
			end,
			min = -100,
			max = 100,
			step = 1,
			usedecimals = true,
			name = "OPTIONS_YOFFSET",
			desc = "OPTIONS_YOFFSET_DESC",
		},
		
		

	}

	_G.C_Timer.After(1.420, function() --~delay
		options_table3.always_boxfirst = true
		options_table3.language_addonId = addonId
		options_table3.Name = "Friendly PCs Options"
		DF:BuildMenu (friendlyPCsFrame, options_table3, startX, startY, heightSize, false, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template, globalCallback)
	end)
--------------------------------
--Enemy Player painel de op��es ~enemy

	local on_select_enemy_playername_font = function (_, _, value)
		Plater.db.profile.plate_config.enemyplayer.actorname_text_font = value
		Plater.UpdateAllPlates()
	end
	local on_select_enemy_playercastname_font = function (_, _, value)
		Plater.db.profile.plate_config.enemyplayer.spellname_text_font = value
		Plater.UpdateAllPlates()
	end
	
	local on_select_enemyplayer_level_text_font = function (_, _, value)
		Plater.db.profile.plate_config.enemyplayer.level_text_font = value
		Plater.UpdateAllPlates()
	end
	local on_select_enemyplayer_percent_text_font = function (_, _, value)
		Plater.db.profile.plate_config.enemyplayer.percent_text_font = value
		Plater.UpdateAllPlates()
	end
	
	local on_select_enemyplayer_spellpercent_text_font = function (_, _, value)
		Plater.db.profile.plate_config.enemyplayer.spellpercent_text_font = value
		Plater.UpdateAllPlates()
	end	
	
	local options_table4 = {
	
		
		{type = "label", get = function() return "General Settings:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		
		{
			type = "select",
			get = function() return "player" end,
			values = function() return copy_settings_options end,
			name = "Copy",
			desc = "Copy settings from another tab.\n\nWhen selecting an option a confirmation box is shown to confirm the copy.",
		},
		
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.enemyplayer.module_enabled end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.module_enabled = value
				ReloadUI()
			end,
			nocombat = true,
			name = "Module Enabled",
			desc = "Enable Plater nameplates for enemy players.\n\n" .. ImportantText .. "Forces a /reload on change.\nThis option is dependent on the client`s nameplate state (on/off)",
		},
		
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.enemyplayer.use_playerclass_color end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.use_playerclass_color = value
				Plater.UpdateAllPlates (true)
			end,
			name = "Use Class Colors",
			desc = "Player name plates uses the player class color",
		},
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.plate_config.enemyplayer.fixed_class_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.plate_config.enemyplayer.fixed_class_color
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllPlates()
			end,
			name = "Fixed Color",
			desc = "Use this color when not using class colors.",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.enemyplayer.show_guild_name end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.show_guild_name = value
				Plater.UpdateAllPlates (true)
			end,
			name = "Show Guild Name",
			desc = "Show Guild Name",
		},
		
		{type = "blank"},
		
		{type = "label", get = function() return "Aura Frame:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		--y offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.enemyplayer.buff_frame_y_offset end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.buff_frame_y_offset = value
				Plater.UpdateAllPlates()
			end,
			min = -100,
			max = 100,
			step = 1,
			usedecimals = true,
			name = "OPTIONS_YOFFSET",
			desc = "OPTIONS_YOFFSET_DESC",
		},		
		
		{type = "label", get = function() return "Cast Bar:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		--x offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.enemyplayer.castbar_offset_x end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.castbar_offset_x = value
				Plater.UpdateAllPlates()
			end,
			min = -128,
			max = 128,
			step = 1,
			usedecimals = true,
			name = "OPTIONS_XOFFSET",
			desc = "OPTIONS_XOFFSET_DESC",
		},
		--y offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.enemyplayer.castbar_offset end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.castbar_offset = value
				Plater.UpdateAllPlates()
			end,
			min = -128,
			max = 128,
			step = 1,
			usedecimals = true,
			name = "OPTIONS_YOFFSET",
			desc = "OPTIONS_YOFFSET_DESC",
		},
		
		{type = "blank" },
		
		{type = "label", get = function() return "Player Name Text Colors" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		--player name color
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.enemyplayer.actorname_use_class_color end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.actorname_use_class_color = value
				Plater.UpdateAllPlates()
			end,
			name = "Use Class Colors",
			desc = "Player name text uses the class color instead of the selected color.",
		},
		--player name color
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.plate_config.enemyplayer.actorname_text_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.plate_config.enemyplayer.actorname_text_color
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_COLOR",
			desc = "OPTIONS_TEXT_COLOR",
		},
		
		{type = "breakline"},
	
		--health bar size out of combat
		{type = "label", get = function() return "Health Bar Size out of Combat:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.enemyplayer.health[1] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.health[1] = value
				Plater.UpdateAllPlates (nil, true)
			end,
			min = 50,
			max = 300,
			step = 1,
			name = "OPTIONS_WIDTH",
			desc = "Width of the health bar when out of combat.",
		},
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.enemyplayer.health[2] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.health[2] = value
				Plater.UpdateAllPlates (nil, true)
			end,
			min = 1,
			max = 100,
			step = 1,
			name = "OPTIONS_HEIGHT",
			desc = "Height of the health bar when out of combat.",
		},
		
		--health bar size in combat
		{type = "label", get = function() return "Health Bar Size in Combat:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.enemyplayer.health_incombat[1] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.health_incombat[1] = value
				Plater.UpdateAllPlates (nil, true)
			end,
			min = 50,
			max = 300,
			step = 1,
			name = "OPTIONS_WIDTH",
			desc = "Width of the health bar when in combat.",
		},
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.enemyplayer.health_incombat[2] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.health_incombat[2] = value
				Plater.UpdateAllPlates (nil, true)
			end,
			min = 1,
			max = 100,
			step = 1,
			name = "OPTIONS_HEIGHT",
			desc = "Height of the health bar when in combat.",
		},
		
		{type = "blank"},
		
		--cast bar size out of combat
		{type = "label", get = function() return "Cast Bar Size out of Combat:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.enemyplayer.cast[1] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.cast[1] = value
				Plater.UpdateAllPlates()
			end,
			min = 50,
			max = 300,
			step = 1,
			name = "OPTIONS_WIDTH",
			desc = "Width of the cast bar when out of combat.",
		},
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.enemyplayer.cast[2] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.cast[2] = value
				Plater.UpdateAllPlates()
			end,
			min = 1,
			max = 100,
			step = 1,
			name = "OPTIONS_HEIGHT",
			desc = "Height of the cast bar when out of combat.",
		},
		--cast bar size out of combat
		{type = "label", get = function() return "Cast Bar Size in Combat:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.enemyplayer.cast_incombat[1] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.cast_incombat[1] = value
				Plater.UpdateAllPlates()
			end,
			min = 50,
			max = 300,
			step = 1,
			name = "OPTIONS_WIDTH",
			desc = "Width of the cast bar when in combat.",
		},
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.enemyplayer.cast_incombat[2] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.cast_incombat[2] = value
				Plater.UpdateAllPlates()
			end,
			min = 1,
			max = 100,
			step = 1,
			name = "OPTIONS_HEIGHT",
			desc = "Height of the cast bar when in combat.",
		},

		{type = "blank"},
		
		--player name size
		{type = "label", get = function() return "Player Name Text:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.enemyplayer.actorname_text_size end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.actorname_text_size = value
				Plater.db.profile.plate_config.enemyplayer.actorname_text_spacing = value-1
				Plater.UpdateAllPlates()
			end,
			min = 6,
			max = 99,
			step = 1,
			name = "OPTIONS_SIZE",
			desc = "OPTIONS_TEXT_SIZE",
		},
		--player name font
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.enemyplayer.actorname_text_font end,
			values = function() return DF:BuildDropDownFontList (on_select_enemy_playername_font) end,
			name = "OPTIONS_FONT",
			desc = "OPTIONS_TEXT_FONT",
		},
		
		--text outline options
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.enemyplayer.actorname_text_outline end,
			values = function() return build_outline_modes_table ("enemyplayer", "actorname_text_outline") end,
			name = "OPTIONS_OUTLINE",
			desc = "OPTIONS_OUTLINE",
		},
		
		--text shadow color
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.plate_config.enemyplayer.actorname_text_shadow_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.plate_config.enemyplayer.actorname_text_shadow_color
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_SHADOWCOLOR",
			desc = "OPTIONS_TOGGLE_TO_CHANGE",
		},		
		
		--npc name anchor
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.enemyplayer.actorname_text_anchor.side end,
			values = function() return build_anchor_side_table ("enemyplayer", "actorname_text_anchor") end,
			name = "OPTIONS_ANCHOR",
			desc = "OPTIONS_ANCHOR_TARGET_SIDE",
		},
		--npc name anchor x offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.enemyplayer.actorname_text_anchor.x end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.actorname_text_anchor.x = value
				Plater.UpdateAllPlates()
			end,
			min = -100,
			max = 100,
			step = 1,
			usedecimals = true,
			name = "OPTIONS_XOFFSET",
			desc = "OPTIONS_XOFFSET_DESC",
		},
		--npc name anchor x offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.enemyplayer.actorname_text_anchor.y end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.actorname_text_anchor.y = value
				Plater.UpdateAllPlates()
			end,
			min = -100,
			max = 100,
			step = 1,
			usedecimals = true,
			name = "OPTIONS_YOFFSET",
			desc = "OPTIONS_YOFFSET_DESC",
		},	
		
		{type = "breakline"},
		
		--cast text size
		{type = "label", get = function() return "Spell Name Text:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.enemyplayer.spellname_text_size end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.spellname_text_size = value
				Plater.UpdateAllPlates()
			end,
			min = 6,
			max = 99,
			step = 1,
			name = "OPTIONS_SIZE",
			desc = "OPTIONS_TEXT_SIZE",
		},
		--cast text font
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.enemyplayer.spellname_text_font end,
			values = function() return DF:BuildDropDownFontList (on_select_enemy_playercastname_font) end,
			name = "OPTIONS_FONT",
			desc = "OPTIONS_TEXT_FONT",
		},
		--cast text color
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.plate_config.enemyplayer.spellname_text_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.plate_config.enemyplayer.spellname_text_color
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_COLOR",
			desc = "OPTIONS_TEXT_COLOR",
		},

		--text outline options
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.enemyplayer.spellname_text_outline end,
			values = function() return build_outline_modes_table ("enemyplayer", "spellname_text_outline") end,
			name = "OPTIONS_OUTLINE",
			desc = "OPTIONS_OUTLINE",
		},
		
		--text shadow color
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.plate_config.enemyplayer.spellname_text_shadow_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.plate_config.enemyplayer.spellname_text_shadow_color
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_SHADOWCOLOR",
			desc = "OPTIONS_TOGGLE_TO_CHANGE",
		},
		
		--spell name text anchor
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.enemyplayer.spellname_text_anchor.side end,
			values = function() return build_anchor_side_table ("enemyplayer", "spellname_text_anchor") end,
			name = "OPTIONS_ANCHOR",
			desc = "OPTIONS_ANCHOR_TARGET_SIDE",
		},
		--spell name text anchor x offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.enemyplayer.spellname_text_anchor.x end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.spellname_text_anchor.x = value
				Plater.UpdateAllPlates()
			end,
			min = -100,
			max = 100,
			step = 1,
			usedecimals = true,
			name = "OPTIONS_XOFFSET",
			desc = "OPTIONS_XOFFSET_DESC",
		},
		--spell name text anchor x offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.enemyplayer.spellname_text_anchor.y end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.spellname_text_anchor.y = value
				Plater.UpdateAllPlates()
			end,
			min = -100,
			max = 100,
			step = 1,
			usedecimals = true,
			name = "OPTIONS_YOFFSET",
			desc = "OPTIONS_YOFFSET_DESC",
		},
		
		--level text settings
		{type = "blank"},

		{type = "label", get = function() return "Spell Cast Time Text:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.enemyplayer.spellpercent_text_enabled end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.spellpercent_text_enabled = value
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_ENABLED",
			desc = "Show the cast time progress.",
		},
		--cast time text
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.enemyplayer.spellpercent_text_size end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.spellpercent_text_size = value
				Plater.UpdateAllPlates()
			end,
			min = 6,
			max = 99,
			step = 1,
			name = "OPTIONS_SIZE",
			desc = "OPTIONS_TEXT_SIZE",
		},
		--cast time text font
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.enemyplayer.spellpercent_text_font end,
			values = function() return DF:BuildDropDownFontList (on_select_enemyplayer_spellpercent_text_font) end,
			name = "OPTIONS_FONT",
			desc = "OPTIONS_TEXT_FONT",
		},
		
		--text outline options
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.enemyplayer.spellpercent_text_outline end,
			values = function() return build_outline_modes_table ("enemyplayer", "spellpercent_text_outline") end,
			name = "OPTIONS_OUTLINE",
			desc = "OPTIONS_OUTLINE",
		},
		
		--text shadow color
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.plate_config.enemyplayer.spellpercent_text_shadow_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.plate_config.enemyplayer.spellpercent_text_shadow_color
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_SHADOWCOLOR",
			desc = "OPTIONS_TOGGLE_TO_CHANGE",
		},
		
		--cast time text color
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.plate_config.enemyplayer.spellpercent_text_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.plate_config.enemyplayer.spellpercent_text_color
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_COLOR",
			desc = "OPTIONS_TEXT_COLOR",
		},
		
		--cast time anchor
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.enemyplayer.spellpercent_text_anchor.side end,
			values = function() return build_anchor_side_table ("enemyplayer", "spellpercent_text_anchor") end,
			name = "OPTIONS_ANCHOR",
			desc = "OPTIONS_ANCHOR_TARGET_SIDE",
		},
		--cast time anchor x offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.enemyplayer.spellpercent_text_anchor.x end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.spellpercent_text_anchor.x = value
				Plater.UpdateAllPlates()
			end,
			min = -100,
			max = 100,
			step = 1,
			usedecimals = true,
			name = "OPTIONS_XOFFSET",
			desc = "OPTIONS_XOFFSET_DESC",
		},
		--cast time anchor x offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.enemyplayer.spellpercent_text_anchor.y end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.spellpercent_text_anchor.y = value
				Plater.UpdateAllPlates()
			end,
			min = -100,
			max = 100,
			step = 1,
			usedecimals = true,
			name = "OPTIONS_YOFFSET",
			desc = "OPTIONS_YOFFSET_DESC",
		},

		{type = "breakline"},
		
		--percent text
		{type = "label", get = function() return "Health Information:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		--enabled
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.enemyplayer.percent_text_enabled end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.percent_text_enabled = value
				Plater.UpdateSettingsCache()
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_ENABLED",
			desc = "Show the percent text.",
		},
		--out of combat
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.enemyplayer.percent_text_ooc end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.percent_text_ooc = value
				Plater.UpdateSettingsCache()
				Plater.UpdateAllPlates()
			end,
			name = "Out of Combat",
			desc = "Show the percent even when isn't in combat.",
		},
		--percent amount
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.enemyplayer.percent_show_percent end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.percent_show_percent = value
				Plater.UpdateAllPlates()
			end,
			name = "Show Percent Amount",
			desc = "Show Percent Amount",
		},
		--health amount
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.enemyplayer.percent_show_health end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.percent_show_health = value
				Plater.UpdateAllPlates()
			end,
			name = "Show Health Amount",
			desc = "Show Health Amount",
		},
		
		--health decimals
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.enemyplayer.percent_text_show_decimals end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.percent_text_show_decimals = value
				Plater.UpdateAllPlates()
			end,
			name = "Show Decimals",
			desc = "Show Decimals",
		},
		
		--percent text size
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.enemyplayer.percent_text_size end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.percent_text_size = value
				Plater.UpdateAllPlates()
			end,
			min = 6,
			max = 99,
			step = 1,
			name = "OPTIONS_SIZE",
			desc = "OPTIONS_TEXT_SIZE",
		},
		--percent text font
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.enemyplayer.percent_text_font end,
			values = function() return DF:BuildDropDownFontList (on_select_enemyplayer_percent_text_font) end,
			name = "OPTIONS_FONT",
			desc = "OPTIONS_TEXT_FONT",
		},
		
		--text outline options
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.enemyplayer.percent_text_outline end,
			values = function() return build_outline_modes_table ("enemyplayer", "percent_text_outline") end,
			name = "OPTIONS_OUTLINE",
			desc = "OPTIONS_OUTLINE",
		},
		
		--text shadow color
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.plate_config.enemyplayer.percent_text_shadow_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.plate_config.enemyplayer.percent_text_shadow_color
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_SHADOWCOLOR",
			desc = "OPTIONS_TOGGLE_TO_CHANGE",
		},
		
		--pecent text color
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.plate_config.enemyplayer.percent_text_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.plate_config.enemyplayer.percent_text_color
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_COLOR",
			desc = "OPTIONS_TEXT_COLOR",
		},
		--percent text alpha
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.enemyplayer.percent_text_alpha end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.percent_text_alpha = value
				Plater.UpdateAllPlates()
			end,
			min = 0,
			max = 1,
			step = 0.1,
			name = "OPTIONS_ALPHA",
			desc = "Set the transparency of the text.",
			usedecimals = true,
		},
		--percent anchor
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.enemyplayer.percent_text_anchor.side end,
			values = function() return build_anchor_side_table ("enemyplayer", "percent_text_anchor") end,
			name = "OPTIONS_ANCHOR",
			desc = "OPTIONS_ANCHOR_TARGET_SIDE",
		},
		--percent anchor x offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.enemyplayer.percent_text_anchor.x end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.percent_text_anchor.x = value
				Plater.UpdateAllPlates()
			end,
			min = -100,
			max = 100,
			step = 1,
			usedecimals = true,
			name = "OPTIONS_XOFFSET",
			desc = "OPTIONS_XOFFSET_DESC",
		},
		--percent anchor x offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.enemyplayer.percent_text_anchor.y end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.percent_text_anchor.y = value
				Plater.UpdateAllPlates()
			end,
			min = -100,
			max = 100,
			step = 1,
			usedecimals = true,
			name = "OPTIONS_YOFFSET",
			desc = "OPTIONS_YOFFSET_DESC",
		},
		
		{type = "breakline"},
		
		{type = "label", get = function() return "Level Text:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		--level enabled
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.enemyplayer.level_text_enabled end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.level_text_enabled = value
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_ENABLED",
			desc = "Check this box to show the level of the actor.",
		},
		--level text size
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.enemyplayer.level_text_size end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.level_text_size = value
				Plater.UpdateAllPlates()
			end,
			min = 6,
			max = 99,
			step = 1,
			name = "OPTIONS_SIZE",
			desc = "OPTIONS_TEXT_SIZE",
		},
		--level text font
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.enemyplayer.level_text_font end,
			values = function() return DF:BuildDropDownFontList (on_select_enemyplayer_level_text_font) end,
			name = "OPTIONS_FONT",
			desc = "OPTIONS_TEXT_FONT",
		},
		
		--text outline options
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.enemyplayer.level_text_outline end,
			values = function() return build_outline_modes_table ("enemyplayer", "level_text_outline") end,
			name = "OPTIONS_OUTLINE",
			desc = "OPTIONS_OUTLINE",
		},
		
		--text shadow color
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.plate_config.enemyplayer.level_text_shadow_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.plate_config.enemyplayer.level_text_shadow_color
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_SHADOWCOLOR",
			desc = "OPTIONS_TOGGLE_TO_CHANGE",
		},
		
		
		--level text alpha
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.enemyplayer.level_text_alpha end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.level_text_alpha = value
				Plater.UpdateAllPlates()
			end,
			min = 0,
			max = 1,
			step = 0.1,
			name = "OPTIONS_ALPHA",
			desc = "Set the transparency of the text.",
			usedecimals = true,
		},
		--level anchor
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.enemyplayer.level_text_anchor.side end,
			values = function() return build_anchor_side_table ("enemyplayer", "level_text_anchor") end,
			name = "OPTIONS_ANCHOR",
			desc = "OPTIONS_ANCHOR_TARGET_SIDE",
		},
		--level anchor x offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.enemyplayer.level_text_anchor.x end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.level_text_anchor.x = value
				Plater.UpdateAllPlates()
			end,
			min = -100,
			max = 100,
			step = 1,
			usedecimals = true,
			name = "OPTIONS_XOFFSET",
			desc = "OPTIONS_XOFFSET_DESC",
		},
		--level anchor x offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.enemyplayer.level_text_anchor.y end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.enemyplayer.level_text_anchor.y = value
				Plater.UpdateAllPlates()
			end,
			min = -100,
			max = 100,
			step = 1,
			usedecimals = true,
			name = "OPTIONS_YOFFSET",
			desc = "OPTIONS_YOFFSET_DESC",
		},		

	}

	_G.C_Timer.After(0.720, function() --~delay
		options_table4.always_boxfirst = true
		options_table4.language_addonId = addonId
		options_table4.Name = "Enemy PCs Options"
		DF:BuildMenu (enemyPCsFrame, options_table4, startX, startY, heightSize, false, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template, globalCallback)
	end)
-----------------------------------------------	
--Friendly NPC painel de op��es ~friendly

	local on_select_friendly_npcname_font = function (_, _, value)
		Plater.db.profile.plate_config.friendlynpc.actorname_text_font = value
		Plater.UpdateAllPlates()
	end
	local on_select_friendly_npccastname_font = function (_, _, value)
		Plater.db.profile.plate_config.friendlynpc.spellname_text_font = value
		Plater.UpdateAllPlates()
	end
	
	local on_select_friendlynpc_level_text_font = function (_, _, value)
		Plater.db.profile.plate_config.friendlynpc.level_text_font = value
		Plater.UpdateAllPlates()
	end
	local on_select_friendlynpc_percent_text_font = function (_, _, value)
		Plater.db.profile.plate_config.friendlynpc.percent_text_font = value
		Plater.UpdateAllPlates()
	end	
	local on_select_friendlynpc_titletext_text_font = function (_, _, value)
		Plater.db.profile.plate_config.friendlynpc.big_actortitle_text_font = value
		Plater.UpdateAllPlates()
	end
	local on_select_friendlynpc_bignametext_text_font = function (_, _, value)
		Plater.db.profile.plate_config.friendlynpc.big_actorname_text_font = value
		Plater.UpdateAllPlates()
	end
	local on_select_friendlynpc_bigtitletext_text_font = function (_, _, value)
		Plater.db.profile.plate_config.friendlynpc.big_actortitle_text_font = value
		Plater.UpdateAllPlates()
	end
	
	local on_select_friendlynpc_spellpercent_text_font = function (_, _, value)
		Plater.db.profile.plate_config.friendlynpc.spellpercent_text_font = value
		Plater.UpdateAllPlates()
	end	
	
	local on_select_enemynpc_bigtitletext_text_font = function (_, _, value)
		Plater.db.profile.plate_config.enemynpc.big_actortitle_text_font = value
		Plater.UpdateAllPlates()
	end
	
	--menu 2
	local friendly_npc_options_table = {
	
		{type = "label", get = function() return "General Settings:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		
		{
			type = "select",
			get = function() return "player" end,
			values = function() return copy_settings_options end,
			name = "Copy",
			desc = "Copy settings from another tab.\n\nWhen selecting an option a confirmation box is shown to confirm the copy.",
		},
		{
			type = "toggle",
			get = function() return GetCVarBool ("nameplateShowFriendlyNPCs") end,
			set = function (self, fixedparam, value) 
				if (value) then
					SetCVar ("nameplateShowFriendlyNPCs", CVAR_ENABLED)
					Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_NPC].enabled = true
				else
					SetCVar ("nameplateShowFriendlyNPCs", CVAR_DISABLED)
					Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_NPC].enabled = false
				end
			end,
			nocombat = true,
			name = L["OPTIONS_ENABLED"] .. CVarIcon,
			desc = "Show nameplate for friendly npcs.\n\n" .. ImportantText .. "This option is dependent on the client`s nameplate state (on/off).\n\n" .. ImportantText .. "when disabled but enabled on the client through (" .. (GetBindingKey ("FRIENDNAMEPLATES") or "") .. ") the healthbar isn't visible but the nameplate is still clickable." .. CVarDesc,
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.friendlynpc.module_enabled end,
			set = function (self, fixedparam, value) 
				if (value) then
					--SetCVar ("nameplateShowFriendlyNPCs", CVAR_ENABLED)
					Plater.db.profile.plate_config.friendlynpc.module_enabled = true
				else
					--SetCVar ("nameplateShowFriendlyNPCs", CVAR_DISABLED)
					Plater.db.profile.plate_config.friendlynpc.module_enabled = false
				end
				ReloadUI()
			end,
			nocombat = true,
			name = "Module Enabled",
			desc = "Enable Plater nameplates for friendly NPCs.\n\n" .. ImportantText .. "Forces a /reload on change.\nThis option is dependent on the client`s nameplate state (on/off)",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.friendlynpc.follow_blizzard_npc_option end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.follow_blizzard_npc_option = value
			end,
			nocombat = true,
			name = "Follow Blizzard 'NPC Names' Option",
			desc = "Hides npc nameplates for untis that would not show a name according to blizzard UI settings.",
		},

		{
			type = "select",
			get = function() return Plater.db.profile.plate_config [ACTORTYPE_FRIENDLY_NPC].relevance_state end,
			values = function() return relevance_options end,
			name = "Show",
			desc = "Modify the way friendly npcs are shown.\n\n" .. ImportantText .. "This option is dependent on the client`s nameplate state (on/off).",
		},
		
		{type = "blank"},
		
		{type = "label", get = function() return "Aura Frame:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		--y offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlynpc.buff_frame_y_offset end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.buff_frame_y_offset = value
				Plater.UpdateAllPlates()
			end,
			min = -100,
			max = 100,
			step = 1,
			usedecimals = true,
			name = "OPTIONS_YOFFSET",
			desc = "OPTIONS_YOFFSET_DESC",
		},
		
		{type = "label", get = function() return "Cast Bar:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		--x offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlynpc.castbar_offset_x end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.castbar_offset_x = value
				Plater.UpdateAllPlates()
			end,
			min = -128,
			max = 128,
			step = 1,
			usedecimals = true,
			name = "OPTIONS_XOFFSET",
			desc = "OPTIONS_XOFFSET_DESC",
		},
		--y offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlynpc.castbar_offset end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.castbar_offset = value
				Plater.UpdateAllPlates()
			end,
			min = -128,
			max = 128,
			step = 1,
			usedecimals = true,
			name = "OPTIONS_YOFFSET",
			desc = "OPTIONS_YOFFSET_DESC",
		},

		{type = "breakline"},

		--health bar size out of combat
		{type = "label", get = function() return "Health Bar Size out of Combat:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlynpc.health[1] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.health[1] = value
				Plater.UpdateAllPlates (nil, true)
			end,
			min = 50,
			max = 300,
			step = 1,
			name = "OPTIONS_WIDTH",
			desc = "Width of the health bar when out of combat.",
		},
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlynpc.health[2] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.health[2] = value
				Plater.UpdateAllPlates (nil, true)
			end,
			min = 1,
			max = 100,
			step = 1,
			name = "OPTIONS_HEIGHT",
			desc = "Height of the health bar when out of combat.",
		},
		
		--health bar size in combat
		{type = "label", get = function() return "Health Bar Size in Combat:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlynpc.health_incombat[1] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.health_incombat[1] = value
				Plater.UpdateAllPlates (nil, true)
			end,
			min = 50,
			max = 300,
			step = 1,
			name = "OPTIONS_WIDTH",
			desc = "Width of the health bar when in combat.",
		},
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlynpc.health_incombat[2] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.health_incombat[2] = value
				Plater.UpdateAllPlates (nil, true)
			end,
			min = 1,
			max = 100,
			step = 1,
			name = "OPTIONS_HEIGHT",
			desc = "Height of the health bar when in combat.",
		},
		
		{type = "blank"},
		
		--cast bar size out of combat
		{type = "label", get = function() return "Cast Bar Size out of Combat:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlynpc.cast[1] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.cast[1] = value
				Plater.UpdateAllPlates()
			end,
			min = 50,
			max = 300,
			step = 1,
			name = "OPTIONS_WIDTH",
			desc = "Width of the cast bar when out of combat.",
		},
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlynpc.cast[2] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.cast[2] = value
				Plater.UpdateAllPlates()
			end,
			min = 1,
			max = 100,
			step = 1,
			name = "OPTIONS_HEIGHT",
			desc = "Height of the cast bar when out of combat.",
		},
		--cast bar size out of combat
		{type = "label", get = function() return "Cast Bar Size in Combat:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlynpc.cast_incombat[1] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.cast_incombat[1] = value
				Plater.UpdateAllPlates()
			end,
			min = 50,
			max = 300,
			step = 1,
			name = "OPTIONS_WIDTH",
			desc = "Width of the cast bar when in combat.",
		},
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlynpc.cast_incombat[2] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.cast_incombat[2] = value
				Plater.UpdateAllPlates()
			end,
			min = 1,
			max = 100,
			step = 1,
			name = "OPTIONS_HEIGHT",
			desc = "Height of the cast bar when in combat.",
		},
		
		--player name size
		{type = "blank"},
		
		{type = "label", get = function() return "Npc Name Text:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlynpc.actorname_text_size end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.actorname_text_size = value
				Plater.db.profile.plate_config.friendlynpc.actorname_text_spacing = value-1
				Plater.UpdateAllPlates()
			end,
			min = 6,
			max = 99,
			step = 1,
			name = "OPTIONS_SIZE",
			desc = "OPTIONS_TEXT_SIZE",
		},
		--player name font
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlynpc.actorname_text_font end,
			values = function() return DF:BuildDropDownFontList (on_select_friendly_npcname_font) end,
			name = "OPTIONS_FONT",
			desc = "OPTIONS_TEXT_FONT",
		},
		--player name color
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.plate_config.friendlynpc.actorname_text_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.plate_config.friendlynpc.actorname_text_color
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_COLOR",
			desc = "OPTIONS_TEXT_COLOR",
		},
		
		--text outline options
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlynpc.actorname_text_outline end,
			values = function() return build_outline_modes_table ("friendlynpc", "actorname_text_outline") end,
			name = "OPTIONS_OUTLINE",
			desc = "OPTIONS_OUTLINE",
		},
		
		--text shadow color
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.plate_config.friendlynpc.actorname_text_shadow_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.plate_config.friendlynpc.actorname_text_shadow_color
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_SHADOWCOLOR",
			desc = "OPTIONS_TOGGLE_TO_CHANGE",
		},
		
		--npc name anchor
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlynpc.actorname_text_anchor.side end,
			values = function() return build_anchor_side_table ("friendlynpc", "actorname_text_anchor") end,
			name = "OPTIONS_ANCHOR",
			desc = "OPTIONS_ANCHOR_TARGET_SIDE",
		},
		--npc name anchor x offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlynpc.actorname_text_anchor.x end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.actorname_text_anchor.x = value
				Plater.UpdateAllPlates()
			end,
			min = -100,
			max = 100,
			step = 1,
			usedecimals = true,
			name = "OPTIONS_XOFFSET",
			desc = "OPTIONS_XOFFSET_DESC",
		},
		--npc name anchor x offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlynpc.actorname_text_anchor.y end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.actorname_text_anchor.y = value
				Plater.UpdateAllPlates()
			end,
			min = -100,
			max = 100,
			step = 1,
			usedecimals = true,
			name = "OPTIONS_YOFFSET",
			desc = "OPTIONS_YOFFSET_DESC",
		},	
		
		{type = "breakline"},
		
		--cast text size
		{type = "label", get = function() return "Spell Name Text:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlynpc.spellname_text_size end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.spellname_text_size = value
				Plater.UpdateAllPlates()
			end,
			min = 6,
			max = 99,
			step = 1,
			name = "OPTIONS_SIZE",
			desc = "OPTIONS_TEXT_SIZE",
		},
		--cast text font
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlynpc.spellname_text_font end,
			values = function() return DF:BuildDropDownFontList (on_select_friendly_npccastname_font) end,
			name = "OPTIONS_FONT",
			desc = "OPTIONS_TEXT_FONT",
		},
		--cast text color
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.plate_config.friendlynpc.spellname_text_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.plate_config.friendlynpc.spellname_text_color
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_COLOR",
			desc = "OPTIONS_TEXT_COLOR",
		},
		
		--text outline options
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlynpc.spellname_text_outline end,
			values = function() return build_outline_modes_table ("friendlynpc", "spellname_text_outline") end,
			name = "OPTIONS_OUTLINE",
			desc = "OPTIONS_OUTLINE",
		},
		
		--text shadow color
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.plate_config.friendlynpc.spellname_text_shadow_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.plate_config.friendlynpc.spellname_text_shadow_color
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_SHADOWCOLOR",
			desc = "OPTIONS_TOGGLE_TO_CHANGE",
		},
	
		--spell name text anchor
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlynpc.spellname_text_anchor.side end,
			values = function() return build_anchor_side_table ("friendlynpc", "spellname_text_anchor") end,
			name = "OPTIONS_ANCHOR",
			desc = "OPTIONS_ANCHOR_TARGET_SIDE",
		},
		--spell name text anchor x offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlynpc.spellname_text_anchor.x end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.spellname_text_anchor.x = value
				Plater.UpdateAllPlates()
			end,
			min = -100,
			max = 100,
			step = 1,
			usedecimals = true,
			name = "OPTIONS_XOFFSET",
			desc = "OPTIONS_XOFFSET_DESC",
		},
		--spell name text anchor x offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlynpc.spellname_text_anchor.y end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.spellname_text_anchor.y = value
				Plater.UpdateAllPlates()
			end,
			min = -100,
			max = 100,
			step = 1,
			usedecimals = true,
			name = "OPTIONS_YOFFSET",
			desc = "OPTIONS_YOFFSET_DESC",
		},

		{type = "blank"},
		{type = "label", get = function() return "Spell Cast Time Text:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.friendlynpc.spellpercent_text_enabled end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.spellpercent_text_enabled = value
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_ENABLED",
			desc = "Show the cast time progress.",
		},
		--cast time text
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlynpc.spellpercent_text_size end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.spellpercent_text_size = value
				Plater.UpdateAllPlates()
			end,
			min = 6,
			max = 99,
			step = 1,
			name = "OPTIONS_SIZE",
			desc = "OPTIONS_TEXT_SIZE",
		},
		--cast time text font
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlynpc.spellpercent_text_font end,
			values = function() return DF:BuildDropDownFontList (on_select_friendlynpc_spellpercent_text_font) end,
			name = "OPTIONS_FONT",
			desc = "OPTIONS_TEXT_FONT",
		},
		
		--text outline options
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlynpc.spellpercent_text_outline end,
			values = function() return build_outline_modes_table ("friendlynpc", "spellpercent_text_outline") end,
			name = "OPTIONS_OUTLINE",
			desc = "OPTIONS_OUTLINE",
		},
		
		--text shadow color
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.plate_config.friendlynpc.spellpercent_text_shadow_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.plate_config.friendlynpc.spellpercent_text_shadow_color
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_SHADOWCOLOR",
			desc = "OPTIONS_TOGGLE_TO_CHANGE",
		},		
		
		--cast time text color
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.plate_config.friendlynpc.spellpercent_text_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.plate_config.friendlynpc.spellpercent_text_color
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_COLOR",
			desc = "OPTIONS_TEXT_COLOR",
		},
		--cast time anchor
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlynpc.spellpercent_text_anchor.side end,
			values = function() return build_anchor_side_table ("friendlynpc", "spellpercent_text_anchor") end,
			name = "OPTIONS_ANCHOR",
			desc = "OPTIONS_ANCHOR_TARGET_SIDE",
		},
		--cast time anchor x offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlynpc.spellpercent_text_anchor.x end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.spellpercent_text_anchor.x = value
				Plater.UpdateAllPlates()
			end,
			min = -100,
			max = 100,
			step = 1,
			usedecimals = true,
			name = "OPTIONS_XOFFSET",
			desc = "OPTIONS_XOFFSET_DESC",
		},
		--cast time anchor x offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlynpc.spellpercent_text_anchor.y end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.spellpercent_text_anchor.y = value
				Plater.UpdateAllPlates()
			end,
			min = -100,
			max = 100,
			step = 1,
			usedecimals = true,
			name = "OPTIONS_YOFFSET",
			desc = "OPTIONS_YOFFSET_DESC",
		},

		{type = "breakline"},
		
		--percent text
		{type = "label", get = function() return "Health Information:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		--enabled
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.friendlynpc.percent_text_enabled end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.percent_text_enabled = value
				Plater.UpdateSettingsCache()
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_ENABLED",
			desc = "Show the percent text.",
		},
		--out of combat
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.friendlynpc.percent_text_ooc end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.percent_text_ooc = value
				Plater.UpdateSettingsCache()
				Plater.UpdateAllPlates()
			end,
			name = "Out of Combat",
			desc = "Show the percent even when isn't in combat.",
		},
		--percent amount
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.friendlynpc.percent_show_percent end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.percent_show_percent = value
				Plater.UpdateAllPlates()
			end,
			name = "Show Percent Amount",
			desc = "Show Percent Amount",
		},
		--health amount
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.friendlynpc.percent_show_health end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.percent_show_health = value
				Plater.UpdateAllPlates()
			end,
			name = "Show Health Amount",
			desc = "Show Health Amount",
		},		
		
		--health decimals
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.friendlynpc.percent_text_show_decimals end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.percent_text_show_decimals = value
				Plater.UpdateAllPlates()
			end,
			name = "Show Decimals",
			desc = "Show Decimals",
		},
		
		--percent text size
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlynpc.percent_text_size end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.percent_text_size = value
				Plater.UpdateAllPlates()
			end,
			min = 6,
			max = 99,
			step = 1,
			name = "OPTIONS_SIZE",
			desc = "OPTIONS_TEXT_SIZE",
		},
		--percent text font
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlynpc.percent_text_font end,
			values = function() return DF:BuildDropDownFontList (on_select_friendlynpc_percent_text_font) end,
			name = "OPTIONS_FONT",
			desc = "OPTIONS_TEXT_FONT",
		},
		
		--text outline options
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlynpc.percent_text_outline end,
			values = function() return build_outline_modes_table ("friendlynpc", "percent_text_outline") end,
			name = "OPTIONS_OUTLINE",
			desc = "OPTIONS_OUTLINE",
		},
		
		--text shadow color
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.plate_config.friendlynpc.percent_text_shadow_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.plate_config.friendlynpc.percent_text_shadow_color
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_SHADOWCOLOR",
			desc = "OPTIONS_TOGGLE_TO_CHANGE",
		},		
		
		--pecent text color
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.plate_config.friendlynpc.percent_text_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.plate_config.friendlynpc.percent_text_color
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_COLOR",
			desc = "OPTIONS_TEXT_COLOR",
		},
		--percent text alpha
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlynpc.percent_text_alpha end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.percent_text_alpha = value
				Plater.UpdateAllPlates()
			end,
			min = 0,
			max = 1,
			step = 0.1,
			name = "OPTIONS_ALPHA",
			desc = "Set the transparency of the text.",
			usedecimals = true,
		},
		--percent anchor
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlynpc.percent_text_anchor.side end,
			values = function() return build_anchor_side_table ("friendlynpc", "percent_text_anchor") end,
			name = "OPTIONS_ANCHOR",
			desc = "OPTIONS_ANCHOR_TARGET_SIDE",
		},
		--percent anchor x offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlynpc.percent_text_anchor.x end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.percent_text_anchor.x = value
				Plater.UpdateAllPlates()
			end,
			min = -100,
			max = 100,
			step = 1,
			usedecimals = true,
			name = "OPTIONS_XOFFSET",
			desc = "OPTIONS_XOFFSET_DESC",
		},
		--percent anchor x offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlynpc.percent_text_anchor.y end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.percent_text_anchor.y = value
				Plater.UpdateAllPlates()
			end,
			min = -100,
			max = 100,
			step = 1,
			usedecimals = true,
			name = "OPTIONS_YOFFSET",
			desc = "OPTIONS_YOFFSET_DESC",
		},
		
		{type = "blank"},
		
		{type = "label", get = function() return "Npc Name Text When no Health Bar Shown:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		--text size
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlynpc.big_actorname_text_size end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.big_actorname_text_size = value
				Plater.UpdateAllPlates()
			end,
			min = 6,
			max = 99,
			step = 1,
			name = "OPTIONS_SIZE",
			desc = "OPTIONS_TEXT_SIZE",
		},
		--text font
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlynpc.big_actorname_text_font end,
			values = function() return DF:BuildDropDownFontList (on_select_friendlynpc_bignametext_text_font) end,
			name = "OPTIONS_FONT",
			desc = "OPTIONS_TEXT_FONT",
		},
		
		--text outline options
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlynpc.big_actorname_text_outline end,
			values = function() return build_outline_modes_table ("friendlynpc", "big_actorname_text_outline") end,
			name = "OPTIONS_OUTLINE",
			desc = "OPTIONS_OUTLINE",
		},
		
		--text shadow color
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.plate_config.friendlynpc.big_actorname_text_shadow_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.plate_config.friendlynpc.big_actorname_text_shadow_color
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_SHADOWCOLOR",
			desc = "OPTIONS_TOGGLE_TO_CHANGE",
		},
		
		--text color
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.plate_config.friendlynpc.big_actorname_text_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.plate_config.friendlynpc.big_actorname_text_color
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_COLOR",
			desc = "OPTIONS_TEXT_COLOR",
		},
	
		{type = "breakline"},
		
		--level text settings
		{type = "label", get = function() return "Level Text:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		--level enabled
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.friendlynpc.level_text_enabled end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.level_text_enabled = value
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_ENABLED",
			desc = "Check this box to show the level of the actor.",
		},
		--level text size
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlynpc.level_text_size end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.level_text_size = value
				Plater.UpdateAllPlates()
			end,
			min = 6,
			max = 99,
			step = 1,
			name = "OPTIONS_SIZE",
			desc = "OPTIONS_TEXT_SIZE",
		},
		--level text font
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlynpc.level_text_font end,
			values = function() return DF:BuildDropDownFontList (on_select_friendlynpc_level_text_font) end,
			name = "OPTIONS_FONT",
			desc = "OPTIONS_TEXT_FONT",
		},

		--text outline options
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlynpc.level_text_outline end,
			values = function() return build_outline_modes_table ("friendlynpc", "level_text_outline") end,
			name = "OPTIONS_OUTLINE",
			desc = "OPTIONS_OUTLINE",
		},
		
		--text shadow color
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.plate_config.friendlynpc.level_text_shadow_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.plate_config.friendlynpc.level_text_shadow_color
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_SHADOWCOLOR",
			desc = "OPTIONS_TOGGLE_TO_CHANGE",
		},		
		
		--level text alpha
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlynpc.level_text_alpha end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.level_text_alpha = value
				Plater.UpdateAllPlates()
			end,
			min = 0,
			max = 1,
			step = 0.1,
			name = "OPTIONS_ALPHA",
			desc = "Set the transparency of the text.",
			usedecimals = true,
		},
		--level anchor
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlynpc.level_text_anchor.side end,
			values = function() return build_anchor_side_table ("friendlynpc", "level_text_anchor") end,
			name = "OPTIONS_ANCHOR",
			desc = "OPTIONS_ANCHOR_TARGET_SIDE",
		},
		--level anchor x offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlynpc.level_text_anchor.x end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.level_text_anchor.x = value
				Plater.UpdateAllPlates()
			end,
			min = -100,
			max = 100,
			step = 1,
			usedecimals = true,
			name = "OPTIONS_XOFFSET",
			desc = "OPTIONS_XOFFSET_DESC",
		},
		--level anchor x offset
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlynpc.level_text_anchor.y end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.level_text_anchor.y = value
				Plater.UpdateAllPlates()
			end,
			min = -100,
			max = 100,
			step = 1,
			usedecimals = true,
			name = "OPTIONS_YOFFSET",
			desc = "OPTIONS_YOFFSET_DESC",
		},
		
		{type = "blank"},
		{type = "label", get = function() return "Quest Tracking Settings:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.friendlynpc.quest_enabled end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.quest_enabled = value
				-- this seems to be gone as of 18.12.2020
				--if value then
					--SetCVar("showQuestTrackingTooltips", 1)
				--end
				Plater.UpdateAllPlates()
			end,
			name = "Track Quests Progress",
			desc = "Track Quests Progress on enemy npc units.",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.plate_config.friendlynpc.quest_color_enabled end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.quest_color_enabled = value
				Plater.UpdateAllPlates()
			end,
			name = "Use Quest Color",
			desc = "Enemy npc units which are objective of a quest have a different color.\nRequries 'Track Quests Progress' to be active.",
		},
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.plate_config.friendlynpc.quest_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.plate_config.friendlynpc.quest_color
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllPlates()
			end,
			name = "Quest Color",
			desc = "Nameplate has this color when a friendly npc unit is a quest objective.",
		},
		
		{type = "blank"},
		{type = "label", get = function() return "Npc Title Text When no Health Bar Shown:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		--profession text size
		{
			type = "range",
			get = function() return Plater.db.profile.plate_config.friendlynpc.big_actortitle_text_size end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.plate_config.friendlynpc.big_actortitle_text_size = value
				Plater.UpdateAllPlates()
			end,
			min = 6,
			max = 99,
			step = 1,
			name = "OPTIONS_SIZE",
			desc = "OPTIONS_TEXT_SIZE",
		},
		--profession text font
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlynpc.big_actortitle_text_font end,
			values = function() return DF:BuildDropDownFontList (on_select_friendlynpc_bigtitletext_text_font) end,
			name = "OPTIONS_FONT",
			desc = "OPTIONS_TEXT_FONT",
		},
		
		--profession text outline options
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlynpc.big_actortitle_text_outline end,
			values = function() return build_outline_modes_table ("friendlynpc", "big_actortitle_text_outline") end,
			name = "OPTIONS_OUTLINE",
			desc = "OPTIONS_OUTLINE",
		},
		
		--profession text shadow color
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.plate_config.friendlynpc.big_actortitle_text_shadow_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.plate_config.friendlynpc.big_actortitle_text_shadow_color
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_SHADOWCOLOR",
			desc = "OPTIONS_TOGGLE_TO_CHANGE",
		},
		
		--profession text color
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.plate_config.friendlynpc.big_actortitle_text_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.plate_config.friendlynpc.big_actortitle_text_color
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllPlates()
			end,
			name = "Profession Text Color",
			desc = "The color of the profession text below the npc name.",
		},
		
	}
	
	_G.C_Timer.After(0.780, function() --~delay
		friendly_npc_options_table.always_boxfirst = true
		friendly_npc_options_table.language_addonId = addonId
		friendly_npc_options_table.Name = "Friendly NPCs Options"
		DF:BuildMenu (friendlyNPCsFrame, friendly_npc_options_table, startX, startY, heightSize, false, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template, globalCallback)
	end)

-----------------------------------------------	
--Enemy NPC painel de op��es ~enemy
	local options_table2
	
	do

		local on_select_enemy_npcname_font = function (_, _, value)
			Plater.db.profile.plate_config.enemynpc.actorname_text_font = value
			Plater.UpdateAllPlates()
		end
		local on_select_enemy_npccastname_font = function (_, _, value)
			Plater.db.profile.plate_config.enemynpc.spellname_text_font = value
			Plater.UpdateAllPlates()
		end
		local on_select_enemy_level_text_font = function (_, _, value)
			Plater.db.profile.plate_config.enemynpc.level_text_font = value
			Plater.UpdateAllPlates()
		end
		local on_select_enemy_percent_text_font = function (_, _, value)
			Plater.db.profile.plate_config.enemynpc.percent_text_font = value
			Plater.UpdateAllPlates()
		end

		local on_select_enemy_spellpercent_text_font = function (_, _, value)
			Plater.db.profile.plate_config.enemynpc.spellpercent_text_font = value
			Plater.UpdateAllPlates()
		end

		local on_select_enemynpc_bignametext_text_font = function (_, _, value)
			Plater.db.profile.plate_config.enemynpc.big_actorname_text_font = value
			Plater.db.profile.plate_config.enemynpc.big_actortitle_text_font = value
			Plater.UpdateAllPlates()
		end
		
		--menu 2 --enemy npc
		options_table2 = {
		
			{type = "label", get = function() return "General Settings:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
			
			{
				type = "select",
				get = function() return "player" end,
				values = function() return copy_settings_options end,
				name = "Copy",
				desc = "Copy settings from another tab.\n\nWhen selecting an option a confirmation box is shown to confirm the copy.",
			},
			
			{
				type = "toggle",
				get = function() return Plater.db.profile.plate_config.enemynpc.module_enabled end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.module_enabled = value
					ReloadUI()
				end,
				nocombat = true,
				name = "Module Enabled",
				desc = "Enable Plater nameplates for enemy NPCs.\n\n" .. ImportantText .. "Forces a /reload on change.\nThis option is dependent on the client`s nameplate state (on/off)",
			},
			
			{type = "blank"},
			{type = "label", get = function() return "Aura Frame:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
			--y offset
			{
				type = "range",
				get = function() return Plater.db.profile.plate_config.enemynpc.buff_frame_y_offset end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.buff_frame_y_offset = value
					Plater.UpdateAllPlates()
				end,
				min = -100,
				max = 100,
				step = 1,
				usedecimals = true,
				name = "OPTIONS_YOFFSET",
				desc = "OPTIONS_YOFFSET_DESC",
			},
			
			{type = "label", get = function() return "Cast Bar:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
			--x offset
			{
				type = "range",
				get = function() return Plater.db.profile.plate_config.enemynpc.castbar_offset_x end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.castbar_offset_x = value
					Plater.UpdateAllPlates()
				end,
				min = -128,
				max = 128,
				step = 1,
				usedecimals = true,
				name = "OPTIONS_XOFFSET",
				desc = "OPTIONS_XOFFSET_DESC",
			},
			--y offset
			{
				type = "range",
				get = function() return Plater.db.profile.plate_config.enemynpc.castbar_offset end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.castbar_offset = value
					Plater.UpdateAllPlates()
				end,
				min = -128,
				max = 128,
				step = 1,
				usedecimals = true,
				name = "OPTIONS_YOFFSET",
				desc = "OPTIONS_YOFFSET_DESC",
			},				
			
			{type = "blank"},
			
			{type = "label", get = function() return "Npc Name Text When no Health Bar Shown:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
			--profession text size
			{
				type = "range",
				get = function() return Plater.db.profile.plate_config.enemynpc.big_actorname_text_size end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.big_actorname_text_size = value
					--Plater.db.profile.plate_config.enemynpc.big_actortitle_text_size = value --why? there's a separate setting.
					Plater.UpdateAllPlates()
				end,
				min = 6,
				max = 99,
				step = 1,
				name = "OPTIONS_SIZE",
				desc = "OPTIONS_TEXT_SIZE",
			},
			--profession text font
			{
				type = "select",
				get = function() return Plater.db.profile.plate_config.enemynpc.big_actorname_text_font end,
				values = function() return DF:BuildDropDownFontList (on_select_enemynpc_bignametext_text_font) end,
				name = "OPTIONS_FONT",
				desc = "OPTIONS_TEXT_FONT",
			},
			
			--text outline options
			{
				type = "select",
				get = function() return Plater.db.profile.plate_config.enemynpc.big_actorname_text_outline end,
				values = function() return build_outline_modes_table ("enemynpc", "big_actorname_text_outline") end,
				name = "OPTIONS_OUTLINE",
				desc = "OPTIONS_OUTLINE",
			},
			
			--text shadow color
			{
				type = "color",
				get = function()
					local color = Plater.db.profile.plate_config.enemynpc.big_actorname_text_shadow_color
					return {color[1], color[2], color[3], color[4]}
				end,
				set = function (self, r, g, b, a) 
					local color = Plater.db.profile.plate_config.enemynpc.big_actorname_text_shadow_color
					color[1], color[2], color[3], color[4] = r, g, b, a
					Plater.UpdateAllPlates()
				end,
				name = "OPTIONS_SHADOWCOLOR",
				desc = "OPTIONS_TOGGLE_TO_CHANGE",
			},
			
			--[=[
			--profession text color
			{
				type = "color",
				get = function()
					local color = Plater.db.profile.plate_config.enemynpc.big_actorname_text_color
					return {color[1], color[2], color[3], color[4]}
				end,
				set = function (self, r, g, b, a) 
					local color = Plater.db.profile.plate_config.enemynpc.big_actorname_text_color
					color[1], color[2], color[3], color[4] = r, g, b, a
					Plater.UpdateAllPlates()
				end,
				name = "OPTIONS_COLOR",
				desc = "OPTIONS_TEXT_COLOR",
			},
			--profession text color
			{
				type = "color",
				get = function()
					local color = Plater.db.profile.plate_config.enemynpc.big_actortitle_text_color
					return {color[1], color[2], color[3], color[4]}
				end,
				set = function (self, r, g, b, a) 
					local color = Plater.db.profile.plate_config.enemynpc.big_actortitle_text_color
					color[1], color[2], color[3], color[4] = r, g, b, a
					Plater.UpdateAllPlates()
				end,
				name = "Profession Text Color",
				desc = "The color of the profession text below the npc name.",
			},
			--]=]
			
			{type = "blank"},
			{type = "label", get = function() return "Npc Title Text When no Health Bar Shown:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
			--profession text size
			{
				type = "range",
				get = function() return Plater.db.profile.plate_config.enemynpc.big_actortitle_text_size end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.big_actortitle_text_size = value
					Plater.UpdateAllPlates()
				end,
				min = 6,
				max = 99,
				step = 1,
				name = "OPTIONS_SIZE",
				desc = "OPTIONS_TEXT_SIZE",
			},
			--profession text font
			{
				type = "select",
				get = function() return Plater.db.profile.plate_config.enemynpc.big_actortitle_text_font end,
				values = function() return DF:BuildDropDownFontList (on_select_enemynpc_bigtitletext_text_font) end,
				name = "OPTIONS_FONT",
				desc = "OPTIONS_TEXT_FONT",
			},
			
			--profession text outline options
			{
				type = "select",
				get = function() return Plater.db.profile.plate_config.enemynpc.big_actortitle_text_outline end,
				values = function() return build_outline_modes_table ("enemynpc", "big_actortitle_text_outline") end,
				name = "OPTIONS_OUTLINE",
				desc = "OPTIONS_OUTLINE",
			},
			
			--profession text shadow color
			{
				type = "color",
				get = function()
					local color = Plater.db.profile.plate_config.enemynpc.big_actortitle_text_shadow_color
					return {color[1], color[2], color[3], color[4]}
				end,
				set = function (self, r, g, b, a) 
					local color = Plater.db.profile.plate_config.enemynpc.big_actortitle_text_shadow_color
					color[1], color[2], color[3], color[4] = r, g, b, a
					Plater.UpdateAllPlates()
				end,
				name = "OPTIONS_SHADOWCOLOR",
				desc = "OPTIONS_TOGGLE_TO_CHANGE",
			},
			
			--[[--profession text color
			{
				type = "color",
				get = function()
					local color = Plater.db.profile.plate_config.enemynpc.big_actortitle_text_color
					return {color[1], color[2], color[3], color[4]}
				end,
				set = function (self, r, g, b, a) 
					local color = Plater.db.profile.plate_config.enemynpc.big_actortitle_text_color
					color[1], color[2], color[3], color[4] = r, g, b, a
					Plater.UpdateAllPlates()
				end,
				name = "Profession Text Color",
				desc = "The color of the profession text below the npc name.",
			},]]--
			
			{type = "breakline"},
		
			--health bar size out of combat
			{type = "label", get = function() return "Health Bar Size out of Combat:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
			{
				type = "range",
				get = function() return Plater.db.profile.plate_config.enemynpc.health[1] end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.health[1] = value
					Plater.UpdateAllPlates (nil, true)
				end,
				min = 50,
				max = 300,
				step = 1,
				name = "OPTIONS_WIDTH",
				desc = "Width of the health bar when out of combat.",
			},
			{
				type = "range",
				get = function() return Plater.db.profile.plate_config.enemynpc.health[2] end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.health[2] = value
					Plater.UpdateAllPlates (nil, true)
				end,
				min = 1,
				max = 100,
				step = 1,
				name = "OPTIONS_HEIGHT",
				desc = "Height of the health bar when out of combat.",
			},
			
			--health bar size in combat
			{type = "label", get = function() return "Health Bar Size in Combat:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
			{
				type = "range",
				get = function() return Plater.db.profile.plate_config.enemynpc.health_incombat[1] end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.health_incombat[1] = value
					Plater.UpdateAllPlates (nil, true)
				end,
				min = 50,
				max = 300,
				step = 1,
				name = "OPTIONS_WIDTH",
				desc = "Width of the health bar when in combat.",
			},
			{
				type = "range",
				get = function() return Plater.db.profile.plate_config.enemynpc.health_incombat[2] end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.health_incombat[2] = value
					Plater.UpdateAllPlates (nil, true)
				end,
				min = 1,
				max = 100,
				step = 1,
				name = "OPTIONS_HEIGHT",
				desc = "Height of the health bar when in combat.",
			},
			{type = "blank"},
			--cast bar size out of combat
			{type = "label", get = function() return "Cast Bar Size out of Combat:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
			{
				type = "range",
				get = function() return Plater.db.profile.plate_config.enemynpc.cast[1] end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.cast[1] = value
					Plater.UpdateAllPlates()
				end,
				min = 50,
				max = 300,
				step = 1,
				name = "OPTIONS_WIDTH",
				desc = "Width of the cast bar when out of combat.",
			},
			{
				type = "range",
				get = function() return Plater.db.profile.plate_config.enemynpc.cast[2] end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.cast[2] = value
					Plater.UpdateAllPlates()
				end,
				min = 1,
				max = 100,
				step = 1,
				name = "OPTIONS_HEIGHT",
				desc = "Height of the cast bar when out of combat.",
			},
			--cast bar size out of combat
			{type = "label", get = function() return "Cast Bar Size in Combat:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
			{
				type = "range",
				get = function() return Plater.db.profile.plate_config.enemynpc.cast_incombat[1] end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.cast_incombat[1] = value
					Plater.UpdateAllPlates()
					Plater.UpdateMaxCastbarTextLength()
				end,
				min = 50,
				max = 300,
				step = 1,
				name = "OPTIONS_WIDTH",
				desc = "Width of the cast bar when in combat.",
			},
			{
				type = "range",
				get = function() return Plater.db.profile.plate_config.enemynpc.cast_incombat[2] end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.cast_incombat[2] = value
					Plater.UpdateAllPlates()
				end,
				min = 1,
				max = 100,
				step = 1,
				name = "OPTIONS_HEIGHT",
				desc = "Height of the cast bar when in combat.",
			},
			{type = "blank"},
			--player name size
			{type = "label", get = function() return "Npc Name Text:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
			{
				type = "range",
				get = function() return Plater.db.profile.plate_config.enemynpc.actorname_text_size end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.actorname_text_size = value
					Plater.db.profile.plate_config.enemynpc.actorname_text_spacing = value-1
					Plater.UpdateAllPlates()
				end,
				min = 6,
				max = 99,
				step = 1,
				name = "OPTIONS_SIZE",
				desc = "OPTIONS_TEXT_SIZE",
			},
			--player name font
			{
				type = "select",
				get = function() return Plater.db.profile.plate_config.enemynpc.actorname_text_font end,
				values = function() return DF:BuildDropDownFontList (on_select_enemy_npcname_font) end,
				name = "OPTIONS_FONT",
				desc = "OPTIONS_TEXT_FONT",
			},
			--player name color
			{
				type = "color",
				get = function()
					local color = Plater.db.profile.plate_config.enemynpc.actorname_text_color
					return {color[1], color[2], color[3], color[4]}
				end,
				set = function (self, r, g, b, a) 
					local color = Plater.db.profile.plate_config.enemynpc.actorname_text_color
					color[1], color[2], color[3], color[4] = r, g, b, a
					Plater.UpdateAllPlates()
				end,
				name = "OPTIONS_COLOR",
				desc = "OPTIONS_TEXT_COLOR",
			},
			
			--text outline options
			{
				type = "select",
				get = function() return Plater.db.profile.plate_config.enemynpc.actorname_text_outline end,
				values = function() return build_outline_modes_table ("enemynpc", "actorname_text_outline") end,
				name = "OPTIONS_OUTLINE",
				desc = "OPTIONS_OUTLINE",
			},
			
			--text shadow color
			{
				type = "color",
				get = function()
					local color = Plater.db.profile.plate_config.enemynpc.actorname_text_shadow_color
					return {color[1], color[2], color[3], color[4]}
				end,
				set = function (self, r, g, b, a) 
					local color = Plater.db.profile.plate_config.enemynpc.actorname_text_shadow_color
					color[1], color[2], color[3], color[4] = r, g, b, a
					Plater.UpdateAllPlates()
				end,
				name = "OPTIONS_SHADOWCOLOR",
				desc = "OPTIONS_TOGGLE_TO_CHANGE",
			},
			
			--npc name anchor
			{
				type = "select",
				get = function() return Plater.db.profile.plate_config.enemynpc.actorname_text_anchor.side end,
				values = function() return build_anchor_side_table ("enemynpc", "actorname_text_anchor") end,
				name = "OPTIONS_ANCHOR",
				desc = "OPTIONS_ANCHOR_TARGET_SIDE",
			},
			--npc name anchor x offset
			{
				type = "range",
				get = function() return Plater.db.profile.plate_config.enemynpc.actorname_text_anchor.x end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.actorname_text_anchor.x = value
					Plater.UpdateAllPlates()
				end,
				min = -100,
				max = 100,
				step = 1,
				usedecimals = true,
				name = "OPTIONS_XOFFSET",
				desc = "OPTIONS_XOFFSET_DESC",
			},
			--npc name anchor x offset
			{
				type = "range",
				get = function() return Plater.db.profile.plate_config.enemynpc.actorname_text_anchor.y end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.actorname_text_anchor.y = value
					Plater.UpdateAllPlates()
				end,
				min = -100,
				max = 100,
				step = 1,
				usedecimals = true,
				name = "OPTIONS_YOFFSET",
				desc = "OPTIONS_YOFFSET_DESC",
			},	
			
			{type = "breakline"},
			
			--cast text size
			{type = "label", get = function() return "Spell Name Text:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
			{
				type = "range",
				get = function() return Plater.db.profile.plate_config.enemynpc.spellname_text_size end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.spellname_text_size = value
					Plater.UpdateAllPlates()
				end,
				min = 6,
				max = 99,
				step = 1,
				name = "OPTIONS_SIZE",
				desc = "OPTIONS_TEXT_SIZE",
			},
			--cast text font
			{
				type = "select",
				get = function() return Plater.db.profile.plate_config.enemynpc.spellname_text_font end,
				values = function() return DF:BuildDropDownFontList (on_select_enemy_npccastname_font) end,
				name = "OPTIONS_FONT",
				desc = "OPTIONS_TEXT_FONT",
			},
			--cast text color
			{
				type = "color",
				get = function()
					local color = Plater.db.profile.plate_config.enemynpc.spellname_text_color
					return {color[1], color[2], color[3], color[4]}
				end,
				set = function (self, r, g, b, a) 
					local color = Plater.db.profile.plate_config.enemynpc.spellname_text_color
					color[1], color[2], color[3], color[4] = r, g, b, a
					Plater.UpdateAllPlates()
				end,
				name = "OPTIONS_COLOR",
				desc = "OPTIONS_TEXT_COLOR",
			},

			--text outline options
			{
				type = "select",
				get = function() return Plater.db.profile.plate_config.enemynpc.spellname_text_outline end,
				values = function() return build_outline_modes_table ("enemynpc", "spellname_text_outline") end,
				name = "OPTIONS_OUTLINE",
				desc = "OPTIONS_OUTLINE",
			},
			
			--text shadow color
			{
				type = "color",
				get = function()
					local color = Plater.db.profile.plate_config.enemynpc.spellname_text_shadow_color
					return {color[1], color[2], color[3], color[4]}
				end,
				set = function (self, r, g, b, a) 
					local color = Plater.db.profile.plate_config.enemynpc.spellname_text_shadow_color
					color[1], color[2], color[3], color[4] = r, g, b, a
					Plater.UpdateAllPlates()
				end,
				name = "OPTIONS_SHADOWCOLOR",
				desc = "OPTIONS_TOGGLE_TO_CHANGE",
			},
			
			--spell name text anchor
			{
				type = "select",
				get = function() return Plater.db.profile.plate_config.enemynpc.spellname_text_anchor.side end,
				values = function() return build_anchor_side_table ("enemynpc", "spellname_text_anchor") end,
				name = "OPTIONS_ANCHOR",
				desc = "OPTIONS_ANCHOR_TARGET_SIDE",
			},
			--spell name text anchor x offset
			{
				type = "range",
				get = function() return Plater.db.profile.plate_config.enemynpc.spellname_text_anchor.x end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.spellname_text_anchor.x = value
					Plater.UpdateAllPlates()
				end,
				min = -100,
				max = 100,
				step = 1,
				usedecimals = true,
				name = "OPTIONS_XOFFSET",
				desc = "OPTIONS_XOFFSET_DESC",
			},
			--spell name text anchor x offset
			{
				type = "range",
				get = function() return Plater.db.profile.plate_config.enemynpc.spellname_text_anchor.y end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.spellname_text_anchor.y = value
					Plater.UpdateAllPlates()
				end,
				min = -100,
				max = 100,
				step = 1,
				usedecimals = true,
				name = "OPTIONS_YOFFSET",
				desc = "OPTIONS_YOFFSET_DESC",
			},
			
			{type = "blank"},
			{type = "label", get = function() return "Spell Cast Time Text:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
			{
				type = "toggle",
				get = function() return Plater.db.profile.plate_config.enemynpc.spellpercent_text_enabled end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.spellpercent_text_enabled = value
					Plater.UpdateAllPlates()
				end,
				name = "OPTIONS_ENABLED",
				desc = "Show the cast time progress.",
			},
			--cast time text
			{
				type = "range",
				get = function() return Plater.db.profile.plate_config.enemynpc.spellpercent_text_size end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.spellpercent_text_size = value
					Plater.UpdateAllPlates()
				end,
				min = 6,
				max = 99,
				step = 1,
				name = "OPTIONS_SIZE",
				desc = "OPTIONS_TEXT_SIZE",
			},
			--cast time text font
			{
				type = "select",
				get = function() return Plater.db.profile.plate_config.enemynpc.spellpercent_text_font end,
				values = function() return DF:BuildDropDownFontList (on_select_enemy_spellpercent_text_font) end,
				name = "OPTIONS_FONT",
				desc = "OPTIONS_TEXT_FONT",
			},
			
			--text outline options
			{
				type = "select",
				get = function() return Plater.db.profile.plate_config.enemynpc.spellpercent_text_outline end,
				values = function() return build_outline_modes_table ("enemynpc", "spellpercent_text_outline") end,
				name = "OPTIONS_OUTLINE",
				desc = "OPTIONS_OUTLINE",
			},
			
			--text shadow color
			{
				type = "color",
				get = function()
					local color = Plater.db.profile.plate_config.enemynpc.spellpercent_text_shadow_color
					return {color[1], color[2], color[3], color[4]}
				end,
				set = function (self, r, g, b, a) 
					local color = Plater.db.profile.plate_config.enemynpc.spellpercent_text_shadow_color
					color[1], color[2], color[3], color[4] = r, g, b, a
					Plater.UpdateAllPlates()
				end,
				name = "OPTIONS_SHADOWCOLOR",
				desc = "OPTIONS_TOGGLE_TO_CHANGE",
			},
			
			
			--cast time text color
			{
				type = "color",
				get = function()
					local color = Plater.db.profile.plate_config.enemynpc.spellpercent_text_color
					return {color[1], color[2], color[3], color[4]}
				end,
				set = function (self, r, g, b, a) 
					local color = Plater.db.profile.plate_config.enemynpc.spellpercent_text_color
					color[1], color[2], color[3], color[4] = r, g, b, a
					Plater.UpdateAllPlates()
				end,
				name = "OPTIONS_COLOR",
				desc = "OPTIONS_TEXT_COLOR",
			},
			
			--cast time anchor
			{
				type = "select",
				get = function() return Plater.db.profile.plate_config.enemynpc.spellpercent_text_anchor.side end,
				values = function() return build_anchor_side_table ("enemynpc", "spellpercent_text_anchor") end,
				name = "OPTIONS_ANCHOR",
				desc = "OPTIONS_ANCHOR_TARGET_SIDE",
			},
			--cast time anchor x offset
			{
				type = "range",
				get = function() return Plater.db.profile.plate_config.enemynpc.spellpercent_text_anchor.x end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.spellpercent_text_anchor.x = value
					Plater.UpdateAllPlates()
				end,
				min = -100,
				max = 100,
				step = 1,
				usedecimals = true,
				name = "OPTIONS_XOFFSET",
				desc = "OPTIONS_XOFFSET_DESC",
			},
			--cast time anchor x offset
			{
				type = "range",
				get = function() return Plater.db.profile.plate_config.enemynpc.spellpercent_text_anchor.y end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.spellpercent_text_anchor.y = value
					Plater.UpdateAllPlates()
				end,
				min = -100,
				max = 100,
				step = 1,
				usedecimals = true,
				name = "OPTIONS_YOFFSET",
				desc = "OPTIONS_YOFFSET_DESC",
			},			
			
			{type = "breakline"},
			
			--percent text
			{type = "label", get = function() return "Health Information:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
			--enabled
			{
				type = "toggle",
				get = function() return Plater.db.profile.plate_config.enemynpc.percent_text_enabled end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.percent_text_enabled = value
					Plater.UpdateSettingsCache()
					Plater.UpdateAllPlates()
				end,
				name = "OPTIONS_ENABLED",
				desc = "Show the percent text.",
			},
			--out of combat
			{
				type = "toggle",
				get = function() return Plater.db.profile.plate_config.enemynpc.percent_text_ooc end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.percent_text_ooc = value
					Plater.UpdateSettingsCache()
					Plater.UpdateAllPlates()
				end,
				name = "Out of Combat",
				desc = "Show the percent even when isn't in combat.",
			},
			--percent amount
			{
				type = "toggle",
				get = function() return Plater.db.profile.plate_config.enemynpc.percent_show_percent end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.percent_show_percent = value
					Plater.UpdateAllPlates()
				end,
				name = "Show Percent Amount",
				desc = "Show Percent Amount",
			},
			--health amount
			{
				type = "toggle",
				get = function() return Plater.db.profile.plate_config.enemynpc.percent_show_health end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.percent_show_health = value
					Plater.UpdateAllPlates()
				end,
				name = "Show Health Amount",
				desc = "Show Health Amount",
			},
			
			--health decimals
			{
				type = "toggle",
				get = function() return Plater.db.profile.plate_config.enemynpc.percent_text_show_decimals end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.percent_text_show_decimals = value
					Plater.UpdateAllPlates()
				end,
				name = "Show Decimals",
				desc = "Show Decimals",
			},
			
			--percent text size
			{
				type = "range",
				get = function() return Plater.db.profile.plate_config.enemynpc.percent_text_size end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.percent_text_size = value
					Plater.UpdateAllPlates()
				end,
				min = 6,
				max = 99,
				step = 1,
				name = "OPTIONS_SIZE",
				desc = "OPTIONS_TEXT_SIZE",
			},
			--percent text font
			{
				type = "select",
				get = function() return Plater.db.profile.plate_config.enemynpc.percent_text_font end,
				values = function() return DF:BuildDropDownFontList (on_select_enemy_percent_text_font) end,
				name = "OPTIONS_FONT",
				desc = "OPTIONS_TEXT_FONT",
			},
			
			--text outline options
			{
				type = "select",
				get = function() return Plater.db.profile.plate_config.enemynpc.percent_text_outline end,
				values = function() return build_outline_modes_table ("enemynpc", "percent_text_outline") end,
				name = "OPTIONS_OUTLINE",
				desc = "OPTIONS_OUTLINE",
			},
			
			--text shadow color
			{
				type = "color",
				get = function()
					local color = Plater.db.profile.plate_config.enemynpc.percent_text_shadow_color
					return {color[1], color[2], color[3], color[4]}
				end,
				set = function (self, r, g, b, a) 
					local color = Plater.db.profile.plate_config.enemynpc.percent_text_shadow_color
					color[1], color[2], color[3], color[4] = r, g, b, a
					Plater.UpdateAllPlates()
				end,
				name = "OPTIONS_SHADOWCOLOR",
				desc = "OPTIONS_TOGGLE_TO_CHANGE",
			},
			
			
			--pecent text color
			{
				type = "color",
				get = function()
					local color = Plater.db.profile.plate_config.enemynpc.percent_text_color
					return {color[1], color[2], color[3], color[4]}
				end,
				set = function (self, r, g, b, a) 
					local color = Plater.db.profile.plate_config.enemynpc.percent_text_color
					color[1], color[2], color[3], color[4] = r, g, b, a
					Plater.UpdateAllPlates()
				end,
				name = "OPTIONS_COLOR",
				desc = "OPTIONS_TEXT_COLOR",
			},
			--percent text alpha
			{
				type = "range",
				get = function() return Plater.db.profile.plate_config.enemynpc.percent_text_alpha end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.percent_text_alpha = value
					Plater.UpdateAllPlates()
				end,
				min = 0,
				max = 1,
				step = 0.1,
				name = "OPTIONS_ALPHA",
				desc = "Set the transparency of the text.",
				usedecimals = true,
			},
			--percent anchor
			{
				type = "select",
				get = function() return Plater.db.profile.plate_config.enemynpc.percent_text_anchor.side end,
				values = function() return build_anchor_side_table ("enemynpc", "percent_text_anchor") end,
				name = "OPTIONS_ANCHOR",
				desc = "OPTIONS_ANCHOR_TARGET_SIDE",
			},
			--percent anchor x offset
			{
				type = "range",
				get = function() return Plater.db.profile.plate_config.enemynpc.percent_text_anchor.x end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.percent_text_anchor.x = value
					Plater.UpdateAllPlates()
				end,
				min = -100,
				max = 100,
				step = 1,
				usedecimals = true,
				name = "OPTIONS_XOFFSET",
				desc = "OPTIONS_XOFFSET_DESC",
			},
			--percent anchor x offset
			{
				type = "range",
				get = function() return Plater.db.profile.plate_config.enemynpc.percent_text_anchor.y end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.percent_text_anchor.y = value
					Plater.UpdateAllPlates()
				end,
				min = -100,
				max = 100,
				step = 1,
				usedecimals = true,
				name = "OPTIONS_YOFFSET",
				desc = "OPTIONS_YOFFSET_DESC",
			},

			--level text settings
			{type = "breakline"},
			{type = "label", get = function() return "Level Text:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
			--level enabled
			{
				type = "toggle",
				get = function() return Plater.db.profile.plate_config.enemynpc.level_text_enabled end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.level_text_enabled = value
					Plater.UpdateAllPlates()
				end,
				name = "OPTIONS_ENABLED",
				desc = "Check this box to show the level of the actor.",
			},
			--level text size
			{
				type = "range",
				get = function() return Plater.db.profile.plate_config.enemynpc.level_text_size end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.level_text_size = value
					Plater.UpdateAllPlates()
				end,
				min = 6,
				max = 99,
				step = 1,
				name = "OPTIONS_SIZE",
				desc = "OPTIONS_TEXT_SIZE",
			},
			--level text font
			{
				type = "select",
				get = function() return Plater.db.profile.plate_config.enemynpc.level_text_font end,
				values = function() return DF:BuildDropDownFontList (on_select_enemy_level_text_font) end,
				name = "OPTIONS_FONT",
				desc = "OPTIONS_TEXT_FONT",
			},
			
			--text outline options
			{
				type = "select",
				get = function() return Plater.db.profile.plate_config.enemynpc.level_text_outline end,
				values = function() return build_outline_modes_table ("enemynpc", "level_text_outline") end,
				name = "OPTIONS_OUTLINE",
				desc = "OPTIONS_OUTLINE",
			},
			
			--text shadow color
			{
				type = "color",
				get = function()
					local color = Plater.db.profile.plate_config.enemynpc.level_text_shadow_color
					return {color[1], color[2], color[3], color[4]}
				end,
				set = function (self, r, g, b, a) 
					local color = Plater.db.profile.plate_config.enemynpc.level_text_shadow_color
					color[1], color[2], color[3], color[4] = r, g, b, a
					Plater.UpdateAllPlates()
				end,
				name = "OPTIONS_SHADOWCOLOR",
				desc = "OPTIONS_TOGGLE_TO_CHANGE",
			},
			
			--level text alpha
			{
				type = "range",
				get = function() return Plater.db.profile.plate_config.enemynpc.level_text_alpha end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.level_text_alpha = value
					Plater.UpdateAllPlates()
				end,
				min = 0,
				max = 1,
				step = 0.1,
				name = "OPTIONS_ALPHA",
				desc = "Set the transparency of the text.",
				usedecimals = true,
			},
			--level anchor
			{
				type = "select",
				get = function() return Plater.db.profile.plate_config.enemynpc.level_text_anchor.side end,
				values = function() return build_anchor_side_table ("enemynpc", "level_text_anchor") end,
				name = "OPTIONS_ANCHOR",
				desc = "OPTIONS_ANCHOR_TARGET_SIDE",
			},
			--level anchor x offset
			{
				type = "range",
				get = function() return Plater.db.profile.plate_config.enemynpc.level_text_anchor.x end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.level_text_anchor.x = value
					Plater.UpdateAllPlates()
				end,
				min = -100,
				max = 100,
				step = 1,
				usedecimals = true,
				name = "OPTIONS_XOFFSET",
				desc = "OPTIONS_XOFFSET_DESC",
			},
			--level anchor x offset
			{
				type = "range",
				get = function() return Plater.db.profile.plate_config.enemynpc.level_text_anchor.y end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.level_text_anchor.y = value
					Plater.UpdateAllPlates()
				end,
				min = -100,
				max = 100,
				step = 1,
				usedecimals = true,
				name = "OPTIONS_YOFFSET",
				desc = "OPTIONS_YOFFSET_DESC",
			},
			
			{type = "blank"},
			{type = "label", get = function() return "Quest Tracking Settings:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
			{
				type = "toggle",
				get = function() return Plater.db.profile.plate_config.enemynpc.quest_enabled end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.quest_enabled = value
					-- this seems to be gone as of 18.12.2020
					--if value then
						--SetCVar("showQuestTrackingTooltips", 1)
					--end
					Plater.UpdateAllPlates()
				end,
				name = "Track Quests Progress",
				desc = "Track Quests Progress on enemy npc units.",
			},
			{
				type = "toggle",
				get = function() return Plater.db.profile.plate_config.enemynpc.quest_color_enabled end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.plate_config.enemynpc.quest_color_enabled = value
					Plater.UpdateAllPlates()
				end,
				name = "Use Quest Color",
				desc = "Enemy npc units which are objective of a quest have a different color.\nRequries 'Track Quests Progress' to be active.",
			},
			{
				type = "color",
				get = function()
					local color = Plater.db.profile.plate_config.enemynpc.quest_color_enemy
					return {color[1], color[2], color[3], color[4]}
				end,
				set = function (self, r, g, b, a) 
					local color = Plater.db.profile.plate_config.enemynpc.quest_color_enemy
					color[1], color[2], color[3], color[4] = r, g, b, a
					Plater.UpdateAllPlates()
				end,
				name = "Quest Color (hostile npc)",
				desc = "Nameplate has this color when a hostile mob is a quest objective.",
			},
			{
				type = "color",
				get = function()
					local color = Plater.db.profile.plate_config.enemynpc.quest_color_neutral
					return {color[1], color[2], color[3], color[4]}
				end,
				set = function (self, r, g, b, a) 
					local color = Plater.db.profile.plate_config.enemynpc.quest_color_neutral
					color[1], color[2], color[3], color[4] = r, g, b, a
					Plater.UpdateAllPlates()
				end,
				name = "Quest Color (neutral npc)",
				desc = "Nameplate has this color when a neutral mob is a quest objective.",
			},

		}

		_G.C_Timer.After(0.900, function() --~delay
			options_table2.always_boxfirst = true
			options_table2.language_addonId = addonId
			options_table2.Name = "Enemy NPCs Options"
			DF:BuildMenu (enemyNPCsFrame, options_table2, startX, startY, heightSize, false, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template, globalCallback)
		end)
	end
	
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> ~keybind ~bindings

	--[=[
	local keybind_changed_callback = function()
		local data = Plater.db.profile.keybinds [DF:GetCurrentSpec()]
		if (data) then
			local bind_string, bind_type_func, bind_macro_func = DF:BuildKeybindFunctions (data, "PL")
			if (bind_string) then
				for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
					DF:SetKeybindsOnProtectedFrame (plateFrame, bind_string, bind_type_func, bind_macro_func)
				end
			end
		end
	end
	
	local editKeybindFrame = DF:CreateKeybindBox (keybindsFrame, "PlaterKeybindSettings", Plater.db.profile.keybinds, keybind_changed_callback, 800, 600, 12, 20)
	editKeybindFrame:SetPoint ("topleft", keybindsFrame, 0, -110)
	editKeybindFrame:Hide()
	
	function keybindsFrame.RefreshOptions()
		editKeybindFrame:SetData (Plater.db.profile.keybinds)
	end
	--]=]
	
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> ~scripts ~scripting ~code �nimations ~animations
	Plater.CreateScriptingPanel()
	Plater.CreateHookingPanel()
	Plater.CreateWagoPanel() --wago_imports
	Plater.CreateSpellAnimationPanel()
	
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> experimental frame ~experimental

	--overlay frame to indicate the feature is disabled
	uiParentFeatureFrame.disabledOverlayFrame = CreateFrame ("frame", nil, uiParentFeatureFrame, BackdropTemplateMixin and "BackdropTemplate")
	uiParentFeatureFrame.disabledOverlayFrame:SetPoint ("topleft", uiParentFeatureFrame, "topleft", 1, -175)
	uiParentFeatureFrame.disabledOverlayFrame:SetPoint ("bottomright", uiParentFeatureFrame, "bottomright", -1, 21)
	uiParentFeatureFrame.disabledOverlayFrame:SetBackdrop ({bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
	uiParentFeatureFrame.disabledOverlayFrame:SetFrameLevel (uiParentFeatureFrame:GetFrameLevel() + 100)
	uiParentFeatureFrame.disabledOverlayFrame:SetBackdropColor (.1, .1, .1, 1)
	uiParentFeatureFrame.disabledOverlayFrame:EnableMouse (true)
	
	if (Plater.db.profile.use_ui_parent) then
		uiParentFeatureFrame.disabledOverlayFrame:Hide()
	end

	local on_select_strata_level = function (self, fixedParameter, value)
		Plater.db.profile.ui_parent_base_strata = value
		Plater.RefreshDBUpvalues()
		Plater.UpdateAllPlates()
	end

	local strataTable = {
		{value = "BACKGROUND", label = "Background", onclick = onStrataSelect, icon = [[Interface\Buttons\UI-MicroStream-Green]], iconcolor = {0, .5, 0, .8}, texcoord = nil}, --Interface\Buttons\UI-MicroStream-Green UI-MicroStream-Red UI-MicroStream-Yellow
		{value = "LOW", label = "Low", onclick = onStrataSelect, icon = [[Interface\Buttons\UI-MicroStream-Green]] , texcoord = nil}, --Interface\Buttons\UI-MicroStream-Green UI-MicroStream-Red UI-MicroStream-Yellow
		{value = "MEDIUM", label = "Medium", onclick = onStrataSelect, icon = [[Interface\Buttons\UI-MicroStream-Yellow]] , texcoord = nil}, --Interface\Buttons\UI-MicroStream-Green UI-MicroStream-Red UI-MicroStream-Yellow
		{value = "HIGH", label = "High", onclick = onStrataSelect, icon = [[Interface\Buttons\UI-MicroStream-Yellow]] , iconcolor = {1, .7, 0, 1}, texcoord = nil}, --Interface\Buttons\UI-MicroStream-Green UI-MicroStream-Red UI-MicroStream-Yellow
		{value = "DIALOG", label = "Dialog", onclick = onStrataSelect, icon = [[Interface\Buttons\UI-MicroStream-Red]] , iconcolor = {1, 0, 0, 1},  texcoord = nil}, --Interface\Buttons\UI-MicroStream-Green UI-MicroStream-Red UI-MicroStream-Yellow
	}
	
	--anchor table
	local frame_levels = {"BACKGROUND", "LOW", "MEDIUM", "HIGH", "DIALOG"}
	local build_framelevel_table = function (frame)
		local t = {}
		for i = 1, #frame_levels do
			tinsert (t, {
				label = frame_levels[i],
				value = frame_levels[i],
				onclick = function (_, _, value)
					Plater.db.profile [frame] = value
					Plater.RefreshDBUpvalues()
					Plater.UpdateAllPlates()
				end
			})
		end
		return t
	end

	local experimental_options = {
		
		{
			type = "toggle",
			get = function() return Plater.db.profile.use_ui_parent end,
			set = function (self, fixedparam, value) 
			
				if (value) then
					--user is enabling the feature
					DF:ShowPromptPanel ("Click okay to confirm using this feature (will force a /reload)", function()
					Plater.db.profile.use_ui_parent = true
					Plater.db.profile.use_ui_parent_just_enabled = true
					Plater.db.profile.reopoen_options_panel_on_tab = TAB_INDEX_UIPARENTING
					ReloadUI()
					end, function()
						PlaterOptionsPanelFrame.RefreshOptionsFrame()
					end)
				else
					Plater.db.profile.use_ui_parent = false
					Plater.db.profile.use_ui_parent_just_enabled = false
					Plater.db.profile.reopoen_options_panel_on_tab = TAB_INDEX_UIPARENTING
					--reset the scale fine tune, so next time the ui parent feature is enabled it can be recalculated
					Plater.db.profile.ui_parent_scale_tune = 0
					ReloadUI()
				end

				Plater:Msg ("this setting require a /reload to take effect.")
			end,
			name = "Use Custom Strata Channels",
			desc = "Allow nameplates to be placed in custom frame strata channels.\n\n" .. ImportantText .. "a /reload will be triggered on changing this setting.",
		},
		
		{type = "blank"},
		{type = "label", get = function() return "Strata Channels:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		
		{
			type = "select",
			get = function() return Plater.db.profile.ui_parent_target_strata end,
			values = function() return build_framelevel_table ("ui_parent_target_strata") end,
			name = "Current Target",
			desc = "Which strata the nameplate of the current target is placed in.",
		},
		
		{
			type = "select",
			get = function() return Plater.db.profile.ui_parent_base_strata end,
			values = function() return build_framelevel_table ("ui_parent_base_strata") end,
			name = "Health Bar",
			desc = "Which strata the unit frame will be placed in.",
		},
		
		{
			type = "select",
			get = function() return Plater.db.profile.ui_parent_cast_strata end,
			values = function() return build_framelevel_table ("ui_parent_cast_strata") end,
			name = "Cast Bar",
			desc = "Which strata the cast bar will be placed in.",
		},
		
		{
			type = "select",
			get = function() return Plater.db.profile.ui_parent_buff_strata end,
			values = function() return build_framelevel_table ("ui_parent_buff_strata") end,
			name = "Aura Frame 1",
			desc = "Which strata aura frame 1 will be placed in.",
		},
		
		{
			type = "select",
			get = function() return Plater.db.profile.ui_parent_buff2_strata end,
			values = function() return build_framelevel_table ("ui_parent_buff2_strata") end,
			name = "Aura Frame 2",
			desc = "Which strata aura frame 2 will be placed in.",
		},
		
		{
			type = "select",
			get = function() return Plater.db.profile.ui_parent_buff_special_strata end,
			values = function() return build_framelevel_table ("ui_parent_buff_special_strata") end,
			name = "Buff Special Frame",
			desc = "Which strata buff special frame frame will be placed in.",
		},
		
		{type = "blank"},
		{type = "label", get = function() return "Frame Levels:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		
		{
			type = "range",
			get = function() return Plater.db.profile.ui_parent_cast_level end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.ui_parent_cast_level = value
				Plater.RefreshDBUpvalues()
				Plater.UpdateAllPlates()
			end,
			min = -5000,
			max = 5000,
			step = 1,
			name = "Cast Bar",
			desc = "Move frames up or down within the strata channel.",
		},
		
		{
			type = "range",
			get = function() return Plater.db.profile.ui_parent_buff_level end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.ui_parent_buff_level = value
				Plater.RefreshDBUpvalues()
				Plater.UpdateAllPlates()
			end,
			min = -5000,
			max = 5000,
			step = 1,
			name = "Aura Frame 1",
			desc = "Move frames up or down within the strata channel.",
		},
		
		{
			type = "range",
			get = function() return Plater.db.profile.ui_parent_buff2_level end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.ui_parent_buff2_level = value
				Plater.RefreshDBUpvalues()
				Plater.UpdateAllPlates()
			end,
			min = -5000,
			max = 5000,
			step = 1,
			name = "Aura Frame 2",
			desc = "Move frames up or down within the strata channel.",
		},
		
		{
			type = "range",
			get = function() return Plater.db.profile.ui_parent_buff_special_level end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.ui_parent_buff_special_level = value
				Plater.RefreshDBUpvalues()
				Plater.UpdateAllPlates()
			end,
			min = -5000,
			max = 5000,
			step = 1,
			name = "Buff Special Frame",
			desc = "Move frames up or down within the strata channel.",
		},
		
		{type = "blank"},
		{type = "label", get = function() return "Scaling:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		
		{
			type = "range",
			get = function() return Plater.db.profile.ui_parent_scale_tune end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.ui_parent_scale_tune = value
				Plater.RefreshDBUpvalues()
				Plater.UpdateAllPlates()
			end,
			min = -2.5,
			max = 2.5,
			step = 0.01,
			usedecimals = true,
			name = "Fine Tune Scale",
			desc = "Slightly adjust the scale of the unit frame.",
		},
	}

	_G.C_Timer.After(1.5, function() --~delay
		experimental_options.always_boxfirst = true
		experimental_options.language_addonId = addonId
		experimental_options.Name = "UI Parent Options"
		DF:BuildMenu (uiParentFeatureFrame, experimental_options, startX, startY, heightSize, false, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template, globalCallback)	
	end)
	
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> ~auto ãuto

	--autoFrame
		
	local auto_options = {
		{type = "label", get = function() return "Auto Toggle Friendly Nameplates:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		
		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_toggle_friendly_enabled end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.auto_toggle_friendly_enabled = value
				
				Plater.RefreshDBUpvalues()
				Plater.UpdateAllPlates()
				Plater.RefreshAutoToggle()
			end,
			name = "OPTIONS_ENABLED",
			desc = "When enabled, Plater will enable or disable friendly plates based on the settings below.",
		},
		
		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_toggle_friendly ["party"] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.auto_toggle_friendly ["party"] = value
				Plater.RefreshAutoToggle()
			end,
			name = "In Dungeons",
			desc = "Show friendly nameplates when inside dungeons.",
		},	
		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_toggle_friendly ["raid"] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.auto_toggle_friendly ["raid"] = value
				Plater.RefreshAutoToggle()
			end,
			name = "In Raid",
			desc = "Show friendly nameplates when inside raids.",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_toggle_friendly ["arena"] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.auto_toggle_friendly ["arena"] = value
				Plater.RefreshAutoToggle()
			end,
			name = "In Arena / BG",
			desc = "Show friendly nameplates when inside arena or battleground.",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_toggle_friendly ["cities"] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.auto_toggle_friendly ["cities"] = value
				Plater.RefreshAutoToggle()
			end,
			name = "In Major Cities",
			desc = "Show friendly nameplates when inside a major city.",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_toggle_friendly ["world"] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.auto_toggle_friendly ["world"] = value
				Plater.RefreshAutoToggle()
			end,
			name = "In Open World",
			desc = "Show friendly nameplates when at any place not listed on the other options.",
		},
		
		{type = "blank"},
		
		{type = "label", get = function() return "Auto Toggle Enemy Nameplates:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		
		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_toggle_enemy_enabled end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.auto_toggle_enemy_enabled = value
				
				Plater.RefreshDBUpvalues()
				Plater.UpdateAllPlates()
				Plater.RefreshAutoToggle()
			end,
			name = L["OPTIONS_ENABLED"],
			desc = "When enabled, Plater will enable or disable enemy plates based on the settings below.",
		},
		
		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_toggle_enemy ["party"] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.auto_toggle_enemy ["party"] = value
				Plater.RefreshAutoToggle()
			end,
			name = "In Dungeons",
			desc = "Show enemy nameplates when inside dungeons.",
		},	
		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_toggle_enemy ["raid"] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.auto_toggle_enemy ["raid"] = value
				Plater.RefreshAutoToggle()
			end,
			name = "In Raid",
			desc = "Show enemy nameplates when inside raids.",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_toggle_enemy ["arena"] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.auto_toggle_enemy ["arena"] = value
				Plater.RefreshAutoToggle()
			end,
			name = "In Arena / BG",
			desc = "Show enemy nameplates when inside arena or battleground.",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_toggle_enemy ["cities"] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.auto_toggle_enemy ["cities"] = value
				Plater.RefreshAutoToggle()
			end,
			name = "In Major Cities",
			desc = "Show enemy nameplates when inside a major city.",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_toggle_enemy ["world"] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.auto_toggle_enemy ["world"] = value
				Plater.RefreshAutoToggle()
			end,
			name = "In Open World",
			desc = "Show enemy nameplates when at any place not listed on the other options.",
		},
		
		{type = "blank"},
		
		{type = "label", get = function() return "Combat toggle:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_toggle_combat_enabled end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.auto_toggle_combat_enabled = value
				
				Plater.RefreshDBUpvalues()
				Plater.UpdateAllPlates()
				Plater.RefreshAutoToggle()
			end,
			name = L["OPTIONS_ENABLED"],
			desc = "When enabled, Plater will enable or disable nameplates and healthbars based on the settings below, when the player enters or leaves combat.",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_toggle_combat.enemy_ic end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.auto_toggle_combat.enemy_ic = value
				Plater.RefreshAutoToggle()
			end,
			name = "Enemy Nameplates in combat",
			desc = "Automatically enable / disable enemy nameplates in combat.",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_toggle_combat.enemy_ooc end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.auto_toggle_combat.enemy_ooc = value
				Plater.RefreshAutoToggle()
			end,
			name = "Enemy Nameplates out of combat",
			desc = "Automatically enable / disable enemy nameplates out of combat.",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_toggle_combat.friendly_ic end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.auto_toggle_combat.friendly_ic = value
				Plater.RefreshAutoToggle()
			end,
			name = "Friendly Nameplates in combat",
			desc = "Automatically enable / disable friendly nameplates in combat.",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_toggle_combat.friendly_ooc end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.auto_toggle_combat.friendly_ooc = value
				Plater.RefreshAutoToggle()
			end,
			name = "Friendly Nameplates out of combat",
			desc = "Automatically enable / disable friendly nameplates out of combat.",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_toggle_combat.blizz_healthbar_ic end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.auto_toggle_combat.blizz_healthbar_ic = value
				Plater.RefreshAutoToggle()
			end,
			name = "Hide Blizzard Healthbars in combat",
			desc = "Automatically enable / disable showing blizzard nameplate healthbars in combat.",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_toggle_combat.blizz_healthbar_ooc end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.auto_toggle_combat.blizz_healthbar_ooc = value
				Plater.RefreshAutoToggle()
			end,
			name = "Hide Blizzard Healthbars out of combat",
			desc = "Automatically enable / disable showing blizzard nameplate healthbars out of combat.",
		},
		
		{type = "breakline"},
		{type = "breakline"},
		{type = "label", get = function() return "Auto Toggle Stacking Nameplates:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		
		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_toggle_stacking_enabled end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.auto_toggle_stacking_enabled = value
				
				Plater.RefreshDBUpvalues()
				Plater.UpdateAllPlates()
				Plater.RefreshAutoToggle()
			end,
			name = "OPTIONS_ENABLED",
			desc = "When enabled, Plater will enable or disable stacking nameplates based on the settings below.\n\n" .. ImportantText .. "only toggle on if 'Stacking Nameplates' is enabled in the General Settings tab.",
		},
		
		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_toggle_stacking ["party"] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.auto_toggle_stacking ["party"] = value
				Plater.RefreshAutoToggle()
			end,
			name = "In Dungeons",
			desc = "Set stacking on when inside dungeons.",
		},	
		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_toggle_stacking ["raid"] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.auto_toggle_stacking ["raid"] = value
				Plater.RefreshAutoToggle()
			end,
			name = "In Raid",
			desc = "Set stacking on when inside raids.",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_toggle_stacking ["arena"] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.auto_toggle_stacking ["arena"] = value
				Plater.RefreshAutoToggle()
			end,
			name = "In Arena / BG",
			desc = "Set stacking on when inside arena or battleground.",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_toggle_stacking ["cities"] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.auto_toggle_stacking ["cities"] = value
				Plater.RefreshAutoToggle()
			end,
			name = "In Major Cities",
			desc = "Set stacking on when inside a major city.",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_toggle_stacking ["world"] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.auto_toggle_stacking ["world"] = value
				Plater.RefreshAutoToggle()
			end,
			name = "In Open World",
			desc = "Set stacking on when at any place not listed on the other options.",
		},

		{type = "blank"},
		{type = "label", get = function() return "Raid and Party:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},

		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_inside_raid_dungeon.hide_enemy_player_pets end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.auto_inside_raid_dungeon.hide_enemy_player_pets = value
				Plater.RefreshAutoToggle()
			end,
			name = "Hide Enemy Pets",
			desc = "Disable show enemy pets within a raid or a dungeon.",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.auto_inside_raid_dungeon.hide_enemy_player_totems end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.auto_inside_raid_dungeon.hide_enemy_player_totems = value
				Plater.RefreshAutoToggle()
			end,
			name = "Hide Enemy Totems",
			desc = "Disable show enemy totems within a raid or a dungeon.",
		},
	}
	
	_G.C_Timer.After(1.2, function() --~delay
		auto_options.always_boxfirst = true
		auto_options.language_addonId = addonId
		auto_options.Name = "Auto Options"
		DF:BuildMenu (autoFrame, auto_options, startX, startY, heightSize, false, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template, globalCallback)	
	end)


--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> ~threat ~aggro
	

	local thread_options = {
	
		{type = "label", get = function() return "OPTIONS_THREAT_MODIFIERS_ANCHOR_TITLE" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
	
		{
			type = "toggle",
			get = function() return Plater.db.profile.aggro_modifies.health_bar_color end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.aggro_modifies.health_bar_color = value
				Plater.RefreshDBUpvalues()
				Plater.UpdateAllPlates()
				if (not value) then
					Plater.UpdateAllNameplateColors()
				end
			end,
			name = "OPTIONS_THREAT_MODIFIERS_HEALTHBARCOLOR",
			desc = "OPTIONS_THREAT_MODIFIERS_HEALTHBARCOLOR",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.aggro_modifies.border_color end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.aggro_modifies.border_color = value
				Plater.RefreshDBUpvalues()
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_THREAT_MODIFIERS_BORDERCOLOR",
			desc = "OPTIONS_THREAT_MODIFIERS_BORDERCOLOR",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.aggro_modifies.actor_name_color end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.aggro_modifies.actor_name_color = value
				Plater.RefreshDBUpvalues()
				Plater.UpdateAllPlates()
			end,
			name = "OPTIONS_THREAT_MODIFIERS_NAMECOLOR",
			desc = "OPTIONS_THREAT_MODIFIERS_NAMECOLOR",
		},

		{type = "blank"},
	
		{type = "label", get = function() return "OPTIONS_THREAT_COLOR_TANK_ANCHOR_TITLE" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.tank.colors.aggro
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.tank.colors.aggro
				color[1], color[2], color[3], color[4] = r, g, b, a
			end,
			name = "OPTIONS_THREAT_AGGROSTATE_ONYOU_SOLID",
			desc = "OPTIONS_THREAT_COLOR_TANK_ONYOU_SOLID_DESC",
		},
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.tank.colors.anothertank
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.tank.colors.anothertank
				color[1], color[2], color[3], color[4] = r, g, b, a
			end,
			name = "OPTIONS_THREAT_AGGROSTATE_ANOTHERTANK",
			desc = "OPTIONS_THREAT_COLOR_TANK_ANOTHERTANK_DESC",
		},
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.tank.colors.pulling
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.tank.colors.pulling
				color[1], color[2], color[3], color[4] = r, g, b, a
			end,
			name = "OPTIONS_THREAT_AGGROSTATE_ONYOU_LOWAGGRO",
			desc = "OPTIONS_THREAT_AGGROSTATE_ONYOU_LOWAGGRO_DESC",
		},
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.tank.colors.noaggro
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.tank.colors.noaggro
				color[1], color[2], color[3], color[4] = r, g, b, a
			end,
			name = "OPTIONS_THREAT_AGGROSTATE_NOAGGRO",
			desc = "OPTIONS_THREAT_COLOR_TANK_NOAGGRO_DESC",
		},
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.tank.colors.pulling_from_tank
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.tank.colors.pulling_from_tank
				color[1], color[2], color[3], color[4] = r, g, b, a
			end,
			name = "OPTIONS_THREAT_PULL_FROM_ANOTHER_TANK",
			desc = "OPTIONS_THREAT_PULL_FROM_ANOTHER_TANK_DESC",
		},
		
		{type = "blank"},
		{type = "label", get = function() return "OPTIONS_THREAT_COLOR_DPS_ANCHOR_TITLE" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},

		{
			type = "color",
			get = function()
				local color = Plater.db.profile.dps.colors.aggro
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.dps.colors.aggro
				color[1], color[2], color[3], color[4] = r, g, b, a
			end,
			name = "OPTIONS_THREAT_AGGROSTATE_ONYOU_SOLID",
			desc = "OPTIONS_THREAT_COLOR_DPS_ONYOU_SOLID_DESC",
		},
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.dps.colors.pulling
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.dps.colors.pulling
				color[1], color[2], color[3], color[4] = r, g, b, a
			end,
			name = "OPTIONS_THREAT_AGGROSTATE_HIGHTHREAT",
			desc = "OPTIONS_THREAT_COLOR_DPS_HIGHTHREAT_DESC",
		},
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.dps.colors.noaggro
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.dps.colors.noaggro
				color[1], color[2], color[3], color[4] = r, g, b, a
			end,
			name = "OPTIONS_THREAT_AGGROSTATE_NOAGGRO",
			desc = "OPTIONS_THREAT_COLOR_DPS_NOAGGRO_DESC",
		},
		
		{
			type = "toggle",
			get = function() return Plater.db.profile.dps.use_aggro_solo end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.dps.use_aggro_solo = value
			end,
			name = "OPTIONS_THREAT_USE_SOLO_COLOR_ENABLE",
			desc = "OPTIONS_THREAT_USE_SOLO_COLOR_DESC",
		},
		
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.dps.colors.solo
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.dps.colors.solo
				color[1], color[2], color[3], color[4] = r, g, b, a
			end,
			name = "OPTIONS_THREAT_USE_SOLO_COLOR",
			desc = "OPTIONS_THREAT_USE_SOLO_COLOR",
		},
		
		{type = "blank"},
		{
			type = "toggle",
			get = function() return Plater.db.profile.aggro_can_check_notank end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.aggro_can_check_notank = value
			end,
			name = "OPTIONS_THREAT_DPS_CANCHECKNOTANK",
			desc = "OPTIONS_THREAT_DPS_CANCHECKNOTANK_DESC",
		},
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.dps.colors.notontank
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.dps.colors.notontank
				color[1], color[2], color[3], color[4] = r, g, b, a
			end,
			name = "OPTIONS_THREAT_AGGROSTATE_NOTANK",
			desc = "OPTIONS_THREAT_COLOR_DPS_NOTANK_DESC",
		},		


		
		{type = "blank"},
		
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.tank.colors.nocombat
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.tank.colors.nocombat
				color[1], color[2], color[3], color[4] = r, g, b, a
			end,
			name = "OPTIONS_THREAT_AGGROSTATE_NOTINCOMBAT",
			desc = "OPTIONS_THREAT_COLOR_TANK_NOTINCOMBAT_DESC",
		},
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.tap_denied_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.tap_denied_color
				color[1], color[2], color[3], color[4] = r, g, b, a
			end,
			name = "OPTIONS_THREAT_AGGROSTATE_TAPPED",
			desc = "OPTIONS_THREAT_COLOR_TAPPED_DESC",
		},
		
		{type = "breakline"},
	
	}
	
	
	if IS_WOW_PROJECT_NOT_MAINLINE and not IS_WOW_PROJECT_CLASSIC_WRATH then
		local thread_options_tank = {
			{type = "label", get = function() return "Tank or DPS Colors:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
			
			{
				type = "toggle",
				get = function() return Plater.db.profile.tank_threat_colors end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.tank_threat_colors = value
					Plater.RefreshTankCache()
				end,
				name = "OPTIONS_THREAT_CLASSIC_USE_TANK_COLORS",
				desc = "OPTIONS_THREAT_CLASSIC_USE_TANK_COLORS",
			},
		
			{type = "blank"},
			
		}
		
		for _, t in ipairs (thread_options_tank) do
			tinsert (thread_options, t)
		end
	end
	
	local thread_options2 = {
		
		{type = "label", get = function() return "OPTIONS_THREAT_COLOR_OVERRIDE_ANCHOR_TITLE" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		
		{
			type = "toggle",
			get = function() return Plater.db.profile.color_override end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.color_override = value
				Plater.RefreshColorOverride()
			end,
			name = "OPTIONS_ENABLED",
			desc = "OPTIONS_THREAT_COLOR_OVERRIDE_DESC",
		},
		
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.color_override_colors [UNITREACTION_HOSTILE]
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.color_override_colors [UNITREACTION_HOSTILE]
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllNameplateColors()
			end,
			name = "OPTIONS_HOSTILE",
			desc = "OPTIONS_HOSTILE",
		},
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.color_override_colors [UNITREACTION_NEUTRAL]
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.color_override_colors [UNITREACTION_NEUTRAL]
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllNameplateColors()
			end,
			name = "OPTIONS_NEUTRAL",
			desc = "OPTIONS_NEUTRAL",
		},
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.color_override_colors [UNITREACTION_FRIENDLY]
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.color_override_colors [UNITREACTION_FRIENDLY]
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllNameplateColors()
			end,
			name = "OPTIONS_FRIENDLY",
			desc = "OPTIONS_FRIENDLY",
		},
		
		{type = "blank"},
		
		{type = "label", get = function() return "Misc" .. ":" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		
		{
			type = "toggle",
			get = function() return Plater.db.profile.show_aggro_flash end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.show_aggro_flash = value
			end,
			name = "OPTIONS_THREAT_USE_AGGRO_FLASH",
			desc = "OPTIONS_THREAT_USE_AGGRO_FLASH_DESC",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.show_aggro_glow end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.show_aggro_glow = value
			end,
			name = "OPTIONS_THREAT_USE_AGGRO_GLOW",
			desc = "OPTIONS_THREAT_USE_AGGRO_GLOW_DESC",
		},
		
	}
	
	for _, t in ipairs (thread_options2) do
		tinsert (thread_options, t)
	end
	
	_G.C_Timer.After(0.990, function() --~delay
		thread_options.always_boxfirst = true
		thread_options.language_addonId = addonId
		thread_options.Name = "Threat Options"
		DF:BuildMenu (threatFrame, thread_options, startX, startY, heightSize, false, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template, globalCallback)
	end)
	
	


	PlaterOptionsPanelFrame.AllSettingsTable = {
		--interface_options, -- general
		options_table1, -- general
		thread_options, -- threat & aggro
		targetOptions, -- target
		--castBar_options, -- cast bar (loaded on demand)
		experimental_options, --  level & strata
		options_personal, -- personal bar
		debuff_options, -- buff settings
		especial_aura_settings, -- buff special
		--ghost auras settings
		options_table2, -- enemy npc
		options_table4, -- enemy player
		options_table3, -- friendly player
		friendly_npc_options_table, -- friendly npc
		--spell feedback (animations)
		auto_options, -- auto
		advanced_options, -- advanced
		--resources
	}

	--
	Plater.CheckOptionsTab()

	--__benchmark() --~perf
end


--endd functiond
