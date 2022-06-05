

local Plater = Plater
local DF = DetailsFramework
local LibSharedMedia = LibStub:GetLibrary ("LibSharedMedia-3.0")
local LibRangeCheck = LibStub:GetLibrary ("LibRangeCheck-2.0")
local _

local IS_WOW_PROJECT_MAINLINE = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
local IS_WOW_PROJECT_NOT_MAINLINE = WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE
local IS_WOW_PROJECT_CLASSIC_ERA = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
local IS_WOW_PROJECT_CLASSIC_TBC = WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC

local PixelUtil = PixelUtil or DFPixelUtil

--localization
local L = LibStub ("AceLocale-3.0"):GetLocale ("PlaterNameplates", true)

--credits text -- ~todo - take colaborators character names?
local creditsText = [=[
Space reserved to castbar options
]=]

--templates
local options_text_template = DF:GetTemplate ("font", "OPTIONS_FONT_TEMPLATE")
local options_dropdown_template = DF:GetTemplate ("dropdown", "OPTIONS_DROPDOWN_TEMPLATE")
local options_switch_template = DF:GetTemplate ("switch", "OPTIONS_CHECKBOX_TEMPLATE")
local options_slider_template = DF:GetTemplate ("slider", "OPTIONS_SLIDER_TEMPLATE")
local options_button_template = DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE")

--configs
local startX, startY, heightSize = 10, -130, 710
local optionsWidth, optionsHeight = 1100, 650
local mainHeightSize = 800

local IMPORT_EXPORT_EDIT_MAX_BYTES = 0 --1024000*4 -- 0 appears to be "no limit"
local IMPORT_EXPORT_EDIT_MAX_LETTERS = 0 --128000*4 -- 0 appears to be "no limit"

local highlightColorLastCombat = {1, 1, .2, .25}

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

--db upvalues
local DB_CAPTURED_SPELLS
local DB_NPCID_CACHE
local DB_NPCID_COLORS
local DB_AURA_ALPHA
local DB_AURA_ENABLED
local DB_AURA_SEPARATE_BUFFS

local on_refresh_db = function()
	local profile = Plater.db.profile
	DB_CAPTURED_SPELLS = PlaterDB.captured_spells
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
	local scriptButton		= mainFrame.AllButtons [6]
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
			PlaterOptionsPanelContainer:SelectIndex (Plater, 12)
		end
	end
	update_wago_update_icons()
end

local TAB_INDEX_UIPARENTING = 5
local TAB_INDEX_PROFILES = 22

-- ~options �ptions
function Plater.OpenOptionsPanel()
	
	if (PlaterOptionsPanelFrame) then
		PlaterOptionsPanelFrame:Show()
		Plater.CheckOptionsTab()
		return true
	end
	
	Plater.db.profile.OptionsPanelDB = Plater.db.profile.OptionsPanelDB or {}
	
	--controi o menu principal
	local f = DF:CreateSimplePanel (UIParent, optionsWidth, optionsHeight, "Plater: professional nameplate addon for hardcore gamers", "PlaterOptionsPanelFrame", {UseScaleBar = true}, Plater.db.profile.OptionsPanelDB)
	f.Title:SetAlpha (.75)
	f:SetFrameStrata ("HIGH")
	DF:ApplyStandardBackdrop (f)
	f:ClearAllPoints()
	PixelUtil.SetPoint (f, "center", UIParent, "center", 2, 2, 1, 1)
	
	-- version text
	local versionText = DF:CreateLabel (f, Plater.versionString, 11, "white")
	versionText:SetPoint ("topright", f, "topright", -25, -7)
	versionText:SetAlpha(0.75)

	local profile = Plater.db.profile
	
	--local CVarDesc = "\n\n|cFFFF7700[*]|r |cFFa0a0a0CVar, not saved within Plater profile and is a Per-Character setting.|r"
	local CVarDesc = "\n\n|cFFFF7700[*]|r |cFFa0a0a0CVar, saved within Plater profile and restored when loading the profile.|r"
	local CVarIcon = "|cFFFF7700*|r"
	local CVarNeedReload = "\n\n|cFFFF2200[*]|r |cFFa0a0a0A /reload may be required to take effect.|r"
	local ImportantText = "|cFFFFFF00" .. "Important" .."|r: "
	local SliderRightClickDesc = "\n\n" .. ImportantText .. "right click to type the value."
	
	local frame_options = {
		y_offset = 0,
		button_width = 101,
		button_height = 20,
		button_x = 210,
		button_y = 1,
		button_text_size = 10,
		right_click_y = 5,
		rightbutton_always_close = true,
		close_text_alpha = 0.4,
	}

	local hookList = {
		OnSelectIndex = function(mainFrame, tabButton)
			if (not tabButton.leftSelectionIndicator) then
				return
			end

			for index, frame in ipairs(mainFrame.AllFrames) do
				local tabButton = mainFrame.AllButtons[index]
				tabButton.leftSelectionIndicator:SetColorTexture(.4, .4, .4)
			end

			tabButton.leftSelectionIndicator:SetColorTexture(1, 1, 0)
			tabButton.selectedUnderlineGlow:Hide()
		end,
	}
	
	-- mainFrame � um frame vazio para sustentrar todos os demais frames, este frame sempre ser� mostrado
	local mainFrame = DF:CreateTabContainer (f, "Plater Options", "PlaterOptionsPanelContainer", 
	{
		--when chaging these indexes also need to change the function f.CopySettings
		{name = "FrontPage",				title = L["OPTIONS_TABNAME_GENERALSETTINGS"]},
		{name = "ThreatConfig",				title = L["OPTIONS_TABNAME_THREAT"]},
		{name = "TargetConfig",				title = L["OPTIONS_TABNAME_TARGET"]},
		{name = "CastBarConfig",			title = L["OPTIONS_TABNAME_CASTBAR"]},
		{name = "LevelStrataConfig",		title = L["OPTIONS_TABNAME_STRATA"]},
		{name = "Scripting",				title = L["OPTIONS_TABNAME_SCRIPTING"]},
		{name = "AutoRunCode",				title = L["OPTIONS_TABNAME_MODDING"]},
		{name = "PersonalBar",				title = L["OPTIONS_TABNAME_PERSONAL"]},
		
		{name = "DebuffConfig",				title = L["OPTIONS_TABNAME_BUFF_SETTINGS"]},
		{name = "DebuffBlacklist",			title = L["OPTIONS_TABNAME_BUFF_TRACKING"]},
		{name = "DebuffSpecialContainer",	title = L["OPTIONS_TABNAME_BUFF_SPECIAL"]},
		{name = "GhostAurasFrame",			title = "Ghost Auras"}, --localize-me
		{name = "EnemyNpc",					title = L["OPTIONS_TABNAME_NPCENEMY"]},
		{name = "EnemyPlayer",				title = L["OPTIONS_TABNAME_PLAYERENEMY"]},
		{name = "FriendlyNpc",				title = L["OPTIONS_TABNAME_NPCFRIENDLY"]},
		{name = "FriendlyPlayer",			title = L["OPTIONS_TABNAME_PLAYERFRIENDLY"]},

		{name = "ColorManagement",			title = L["OPTIONS_TABNAME_NPC_COLORNAME"]},
		{name = "CastColorManagement",		title = L["OPTIONS_TABNAME_CASTCOLORS"]},
		{name = "DebuffLastEvent",			title = L["OPTIONS_TABNAME_BUFF_LIST"]},
		{name = "AnimationPanel",			title = L["OPTIONS_TABNAME_ANIMATIONS"]},
		{name = "Automation",				title = L["OPTIONS_TABNAME_AUTO"]},
		{name = "ProfileManagement",		title = L["OPTIONS_TABNAME_PROFILES"]},
		{name = "AdvancedConfig",			title = L["OPTIONS_TABNAME_ADVANCED"]},
		{name = "resourceFrame",			title = L["OPTIONS_TABNAME_COMBOPOINTS"]},

		{name = "WagoIo", title = "Wago Imports"}, --wago_imports --localize-me
		{name = "SearchFrame", title = L["OPTIONS_TABNAME_SEARCH"]},
		
	}, 
	frame_options, hookList)

	--> when any setting is changed, call this function
	local globalCallback = function()
		Plater.IncreaseRefreshID()
		Plater.RefreshDBUpvalues()
		Plater.UpdateAllPlates()
	end

	--make the tab button's text be aligned to left and fit the button's area
	for index, frame in ipairs(mainFrame.AllFrames) do

		--DF:ApplyStandardBackdrop(frame)
		local frameBackgroundTexture = frame:CreateTexture(nil, "artwork")
		frameBackgroundTexture:SetPoint("topleft", frame, "topleft", 1, -120)
		frameBackgroundTexture:SetPoint("bottomright", frame, "bottomright", -1, 20)
		frameBackgroundTexture:SetColorTexture (0.2317647, 0.2317647, 0.2317647)
		frameBackgroundTexture:SetVertexColor (0.27, 0.27, 0.27)
		frameBackgroundTexture:SetAlpha (0.5)

		--divisor shown above the background (create above)
		local frameBackgroundTextureTopLine = frame:CreateTexture(nil, "artwork")
		frameBackgroundTextureTopLine:SetPoint("bottomleft", frameBackgroundTexture, "topleft", 0, 0)
		frameBackgroundTextureTopLine:SetPoint("bottomright", frame, "topright", -1, 0)
		frameBackgroundTextureTopLine:SetHeight(1)
		frameBackgroundTextureTopLine:SetColorTexture (0.1317647, 0.1317647, 0.1317647)
		frameBackgroundTextureTopLine:SetAlpha (0.3)

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
	local castBarFrame			= mainFrame.AllFrames [4]
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
	local colorsFrame			= mainFrame.AllFrames [17]
	local castColorsFrame		= mainFrame.AllFrames [18]
	local auraLastEventFrame	= mainFrame.AllFrames [19]
	local animationFrame		= mainFrame.AllFrames [20] --need to change the index on Plater_AnimationEditor.lua
	local autoFrame				= mainFrame.AllFrames [21]
	local profilesFrame			= mainFrame.AllFrames [22]
	local advancedFrame			= mainFrame.AllFrames [23]
	local resourceFrame			= mainFrame.AllFrames [24]

	--4th row
	local wagoIoFrame 			= mainFrame.AllFrames [25] --wago_imports
	local searchFrame			= mainFrame.AllFrames [26]

	local scriptButton		= mainFrame.AllButtons [6] --also need update on line 115 and 13818
	local modButton		 	= mainFrame.AllButtons [7]
	local profileButton		= mainFrame.AllButtons [22]
	local ghostAurasButton	= mainFrame.AllButtons [12]

	if (time() + 60*60*24*15 > 1647542962) then
		ghostAuras.newTexture = ghostAurasButton:CreateTexture(nil, "overlay", nil, 7)
		ghostAuras.newTexture:SetTexture([[Interface\AddOns\Plater\images\new]])
		ghostAuras.newTexture:SetPoint("right", ghostAurasButton.widget, "right", 4, -9)
		ghostAuras.newTexture:SetSize(35, 35)
		ghostAuras.newTexture:SetAlpha(0.88)
	end

	Plater.Resources.BuildResourceOptionsTab(resourceFrame)
	Plater.Auras.BuildGhostAurasOptionsTab(ghostAuras)
	Plater.CreateCastColorOptionsFrame(castColorsFrame)
	
	local generalOptionsAnchor = CreateFrame ("frame", "$parentOptionsAnchor", frontPageFrame, BackdropTemplateMixin and "BackdropTemplate")
	generalOptionsAnchor:SetSize (1, 1)
	generalOptionsAnchor:SetPoint ("topleft", frontPageFrame, "topleft", startX, startY)
	
	local statusBar = CreateFrame ("frame", nil, f, BackdropTemplateMixin and "BackdropTemplate")
	statusBar:SetPoint ("bottomleft", f, "bottomleft")
	statusBar:SetPoint ("bottomright", f, "bottomright")
	statusBar:SetHeight (20)
	DF:ApplyStandardBackdrop (statusBar)
	statusBar:SetAlpha (0.8)
	
	DF:BuildStatusbarAuthorInfo (statusBar, "Plater is Maintained by ", "Ariani | Terciob")
	
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
					--do not export cache data, these data can be rebuild at run time
					local captured_spells = Plater.db.profile.captured_spells
					local aura_cache_by_name = Plater.db.profile.aura_cache_by_name
					local captured_casts = Plater.db.profile.captured_casts -- ? local DB ?
					local npc_cache = Plater.db.profile.npc_cache
					local cvars_caller_cache = Plater.db.profile.saved_cvars_last_change

					Plater.db.profile.captured_spells = {}
					Plater.db.profile.aura_cache_by_name = {}
					Plater.db.profile.captured_casts = {}
					Plater.db.profile.npc_cache = {}
					Plater.db.profile.saved_cvars_last_change = {}
					
					--retain npc_cache for set npc_colors
					for npcID, _ in pairs (Plater.db.profile.npc_colors) do
						Plater.db.profile.npc_cache [npcID] = npc_cache [npcID]
					end
					--retain npc_cache for set npc_colors
					for npcID, _ in pairs (Plater.db.profile.npcs_renamed) do
						Plater.db.profile.npc_cache [npcID] = npc_cache [npcID]
					end
					
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
					
					--export to string
					profilesFrame.ImportStringField:SetText (Plater.ExportProfileToString() or L["OPTIONS_ERROR_EXPORTSTRINGERROR"])
					
					--set back again the cache data
					Plater.db.profile.captured_spells = captured_spells
					Plater.db.profile.aura_cache_by_name = aura_cache_by_name
					Plater.db.profile.captured_casts = captured_casts
					Plater.db.profile.npc_cache = npc_cache
					Plater.db.profile.saved_cvars_last_change = cvars_caller_cache
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
						if (wagoProfile and type (wagoProfile == "table")) then
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
				
				if (profile and type (profile == "table")) then
				
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
			
			function profilesFrame.DoProfileImport(profileName, profile, isUpdate, keepModsNotInUpdate)
				profilesFrame.HideStringField()
				
				profile.profile_name = nil --no need to import
				
				local wasUsingUIParent = Plater.db.profile.use_ui_parent
				
				local script_data_backup = (isUpdate or keepModsNotInUpdate) and DF.table.copy ({}, Plater.db.profile.script_data) or {}
				local hook_data_backup = (isUpdate or keepModsNotInUpdate) and DF.table.copy ({}, Plater.db.profile.hook_data) or {}
				
				-- switch to profile
				Plater.db:SetProfile (profileName)
				
				-- cleanup profile -> reset to defaults
				Plater.db:ResetProfile(false, true)
				
				-- import new profile settings
				DF.table.copy (Plater.db.profile, profile)
				
				--make the option reopen after the reload
				Plater.db.profile.reopoen_options_panel_on_tab = TAB_INDEX_PROFILES
								
				--check if parent to UIParent is enabled and calculate the new scale
				if (Plater.db.profile.use_ui_parent) then
					if not isUpdate or not wasUsingUIParent then -- only update if necessary
						Plater.db.profile.ui_parent_scale_tune = 1 / UIParent:GetEffectiveScale()
					end
				else
					Plater.db.profile.ui_parent_scale_tune = 0
				end
				
				if isUpdate or keepModsNotInUpdate then
					-- copy user settings for mods/scripts and keep mods/scripts which are not part of the profile
					for index, oldScriptObject in ipairs(script_data_backup) do
						local scriptDB = Plater.db.profile.script_data or {}
						local found = false
						for i = 1, #scriptDB do
							local scriptObject = scriptDB [i]
							if (scriptObject.Name == oldScriptObject.Name) then
								if isUpdate then
									Plater.UpdateOptionsForModScriptImport(scriptObject, oldScriptObject)
								end
								found = true
								break
							end
						end
						if not found and keepModsNotInUpdate then
							tinsert (scriptDB, oldScriptObject)
						end
					end
					
					for index, oldScriptObject in ipairs(hook_data_backup) do
						local scriptDB = Plater.db.profile.hook_data or {}
						local found = false
						for i = 1, #scriptDB do
							local scriptObject = scriptDB [i]
							if (scriptObject.Name == oldScriptObject.Name) then
								if isUpdate then
									Plater.UpdateOptionsForModScriptImport(scriptObject, oldScriptObject)
								end
								found = true
								break
							end
						end
						if not found and keepModsNotInUpdate then
							tinsert (scriptDB, oldScriptObject)
						end
					end
				end
				
				-- cleanup NPC cache/colors
				local cache = Plater.db.profile.npc_cache
				local cacheTemp = DetailsFramework.table.copy({},cache)
				for n, v in pairs(cacheTemp) do
					if tonumber(n) then 
						cache[n] = nil
						cache[tonumber(n)] = v 
					end
				end
				
				local colors = Plater.db.profile.npc_colors
				local colorsTemp = DetailsFramework.table.copy({},colors)
				for n, v in pairs(colorsTemp) do
					if tonumber(n) then 
						colors[n] = nil
						colors[tonumber(n)] = v 
					end
				end
				
				--restore CVars of the profile
				Plater.RestoreProfileCVars()
				
				--automatically reload the user UI
				ReloadUI()
			end
			
			function profilesFrame.OpenProfileManagement()
				f:Hide()
				Plater:OpenInterfaceProfile()
				C_Timer.After (.5, function()
					mainFrame:SetIndex (1)
					mainFrame:SelectIndex (_, 1)
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
					if (wagoProfile and type (wagoProfile == "table") and wagoProfile.plate_config) then
				
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
	local anchor_names = {
		L["OPTIONS_ANCHOR_TOPLEFT"],
		L["OPTIONS_ANCHOR_LEFT"],
		L["OPTIONS_ANCHOR_BOTTOMLEFT"],
		L["OPTIONS_ANCHOR_BOTTOM"],
		L["OPTIONS_ANCHOR_BOTTOMRIGHT"],
		L["OPTIONS_ANCHOR_RIGHT"],
		L["OPTIONS_ANCHOR_TOPRIGHT"],
		L["OPTIONS_ANCHOR_TOP"],
		L["OPTIONS_ANCHOR_CENTER"],
		L["OPTIONS_ANCHOR_INNERLEFT"],
		L["OPTIONS_ANCHOR_INNERRIGHT"],
		L["OPTIONS_ANCHOR_INNERTOP"],
		L["OPTIONS_ANCHOR_INNERBOTTOM"],
	}
	
	local build_anchor_side_table = function (actorType, member)
		local t = {}
		for i = 1, 13 do
			tinsert (t, {
				label = anchor_names[i], 
				value = i, 
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
		return t
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
	--
	local cast_bar_texture_selected = function (self, capsule, value)
		Plater.db.profile.cast_statusbar_texture = value
		Plater.RefreshDBUpvalues()
		Plater.UpdateAllPlates()
	end
	local cast_bar_texture_options = {}
	for name, texturePath in pairs (textures) do
		cast_bar_texture_options [#cast_bar_texture_options + 1] = {value = name, label = name, statusbar = texturePath, onclick = cast_bar_texture_selected}
	end
	table.sort (cast_bar_texture_options, function (t1, t2) return t1.label < t2.label end)
	--
	local cast_bar_bgtexture_selected = function (self, capsule, value)
		Plater.db.profile.cast_statusbar_bgtexture = value
		Plater.RefreshDBUpvalues()
		Plater.UpdateAllPlates()
	end
	local cast_bar_bgtexture_options = {}
	for name, texturePath in pairs (textures) do
		cast_bar_bgtexture_options [#cast_bar_bgtexture_options + 1] = {value = name, label = name, statusbar = texturePath, onclick = cast_bar_bgtexture_selected}
	end
	table.sort (cast_bar_bgtexture_options, function (t1, t2) return t1.label < t2.label end)
	--
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
	local cast_spark_texture_selected = function (self, capsule, value)
		Plater.db.profile.cast_statusbar_spark_texture = value
		Plater.UpdateAllPlates()
	end
	local cast_spark_texture_selected_options = {}
	for index, texturePath in ipairs (Plater.SparkTextures) do
		cast_spark_texture_selected_options [#cast_spark_texture_selected_options + 1] = {value = texturePath, label = "Texture " .. index, statusbar = texturePath, onclick = cast_spark_texture_selected}
	end
	
	
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
local nameplate_anchor_options = {
	{label = "Head", value = 0, onclick = Plater.ChangeNameplateAnchor, desc = "All nameplates are placed above the character."},
	{label = "Head/Feet", value = 1, onclick = Plater.ChangeNameplateAnchor, desc = "Friendly and neutral has the nameplate on their head, enemies below the feet."},
	{label = "Feet", value = 2, onclick = Plater.ChangeNameplateAnchor, desc = "All nameplates are placed below the character."},
}

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

DF:BuildMenu (frontPageFrame, interface_options, startX, startY-20, 300 + 60, true, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template, globalCallback)

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
	
	local labelgoToTab = DF:CreateLabel(goToTab, text, 12, "orange")
	labelgoToTab.width = 230
	labelgoToTab.height = 50
	labelgoToTab.valign = "center"
	labelgoToTab.align = "center"
	labelgoToTab:SetPoint("topleft", goToTab, "topleft", 3, -3)

	local goTo = function()
		PlaterOptionsPanelContainer:SelectIndex (Plater, index)
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


local build_number_format_options = function()
	local number_format_options = {"Western (1K - 1KK)"}
	local number_format_options_config = {"western", "eastasia"}

	local eastAsiaMyriads_1k, eastAsiaMyriads_10k, eastAsiaMyriads_1B
	if (GetLocale() == "koKR") then
		tinsert (number_format_options, "East Asia (1천 - 1만)")
	elseif (GetLocale() == "zhCN") then
		tinsert (number_format_options, "East Asia (1千 - 1万)")
	elseif (GetLocale() == "zhTW") then
		tinsert (number_format_options, "East Asia (1千 - 1萬)")
	else
		tinsert (number_format_options, "East Asia (1천 - 1만)")
	end

	local t = {}
	for i = 1, #number_format_options do
		tinsert (t, {
			label = number_format_options [i], 
			value = number_format_options_config [i],
			onclick = function (_, _, value)
				Plater.db.profile.number_region = value
				Plater.RefreshDBUpvalues()
				Plater.UpdateAllPlates()
			end
		})
	end
	return t
end

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
		get = function() return Plater.DisableAuraTest and true or false end,
		set = function (self, fixedparam, value) 
			Plater.DisableAuraTest = value
			if (value) then
				auraOptionsFrame.DisableAuraTest()
			else
				auraOptionsFrame.EnableAuraTest()
			end
		end,
		name = "|TInterface\\GossipFrame\\AvailableQuestIcon:0|tDisable Testing Auras",
		desc = "Enable this to hide test auras shown when configuring.",
	},
	
	{type = "blank"},
	
	{type = "label", get = function() return "General Settings:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},	
	{
		type = "toggle",
		get = function() return Plater.db.profile.aura_enabled end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.aura_enabled = value
			Plater.RefreshDBUpvalues()
			Plater.UpdateAllPlates()
			
			if (not value) then
				for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
					for _, frame in ipairs (plateFrame.unitFrame.BuffFrame.PlaterBuffList) do
						frame:Hide()
					end
					for _, frame in ipairs (plateFrame.unitFrame.BuffFrame2.PlaterBuffList) do
						frame:Hide()
					end
				end
			end
		end,
		name = L["OPTIONS_ENABLED"],
		desc = "Enabled",
	},
	
	{
		type = "toggle",
		get = function() return Plater.db.profile.aura_show_tooltip end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.aura_show_tooltip = value
			Plater.UpdateAllPlates()
		end,
		name = "Show Tooltip",
		desc = "Show tooltip when hovering over the aura icon.",
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
		name = L["OPTIONS_ALPHA"],
		desc = "Alpha",
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
		name = "Icon Spacing",
		desc = "Icon Spacing",
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
		name = "Icon Row Spacing",
		desc = "Icon Row Spacing",
	},
	
	{
		type = "toggle",
		get = function() return Plater.db.profile.aura_consolidate end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.aura_consolidate = value
			Plater.UpdateAllPlates()
		end,
		name = "Stack Similar Auras",
		desc = "Auras with the same name (e.g. warlock's unstable affliction debuff) get stacked together.",
	},
	{
		type = "toggle",
		get = function() return Plater.db.profile.aura_consolidate_timeleft_lower end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.aura_consolidate_timeleft_lower = value
			Plater.UpdateAllPlates()
		end,
		name = "Show shortest time of stacked auras",
		desc = "Show shortest time of stacked auras or the longes time, when disabled.",
	},
	
	{type = "blank"},
	
	{
		type = "toggle",
		get = function() return Plater.db.profile.aura_sort end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.aura_sort = value
			Plater.UpdateAllPlates()
		end,
		name = "Sort Auras",
		desc = "Auras are sorted by time remaining (default).",
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
		name = "Width",
		desc = "Debuff's icon width.",
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
		name = "Height",
		desc = "Debuff's icon height.",
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
		name = "Width",
		desc = "Debuff's icon width.",
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
		name = "Height",
		desc = "Debuff's icon height.",
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
		name = L["OPTIONS_ANCHOR"],
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
		name = L["OPTIONS_XOFFSET"],
		desc = "X Offset",
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
		name = L["OPTIONS_YOFFSET"],
		desc = "Y Offset",
	},
	
	{type = "blank"},
	{type = "label", get = function() return "Aura Frame 2:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
	
	{
		type = "toggle",
		get = function() return Plater.db.profile.buffs_on_aura2 end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.buffs_on_aura2 = value
			Plater.RefreshDBUpvalues()
			Plater.UpdateAllPlates()
		end,
		name = L["OPTIONS_ENABLED"],
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
		name = L["OPTIONS_ANCHOR"],
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
		name = L["OPTIONS_XOFFSET"],
		desc = "X Offset",
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
		name = L["OPTIONS_YOFFSET"],
		desc = "Y Offset",
	},
	
	{type = "blank"},

	{type = "label", get = function() return "Stack Counter:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},

	{
		type = "select",
		get = function() return Plater.db.profile.aura_stack_font end,
		values = function() return DF:BuildDropDownFontList (on_select_stack_text_font) end,
		name = L["OPTIONS_FONT"],
		desc = "Font of the text.",
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
		name = L["OPTIONS_SIZE"],
		desc = "Size",
	},
	
	--text outline options
	{
		type = "select",
		get = function() return Plater.db.profile.aura_stack_outline end,
		values = function() return build_outline_modes_table (nil, "aura_stack_outline") end,
		name = L["OPTIONS_OUTLINE"],
		desc = "Outline",
	},
	
	--text shadow color
	{
		type = "color",
		get = function()
			local color = Plater.db.profile.aura_stack_shadow_color
			return {color[1], color[2], color[3], color[4]}
		end,
		set = function (self, r, g, b, a) 
			local color = Plater.db.profile.aura_stack_shadow_color
			color[1], color[2], color[3], color[4] = r, g, b, a
			Plater.UpdateAllPlates()
		end,
		name = L["OPTIONS_SHADOWCOLOR"],
		desc = ImportantText .. "hide and show nameplates to see changes.",
	},

	{
		type = "color",
		get = function()
			local color = Plater.db.profile.aura_stack_color
			return {color[1], color[2], color[3], color[4]}
		end,
		set = function (self, r, g, b, a) 
			local color = Plater.db.profile.aura_stack_color
			color[1], color[2], color[3], color[4] = r, g, b, a
			Plater.UpdateAllPlates()
		end,
		name = L["OPTIONS_COLOR"],
		desc = "Color",
	},
	{
		type = "select",
		get = function() return Plater.db.profile.aura_stack_anchor.side end,
		values = function() return build_anchor_side_table (nil, "aura_stack_anchor") end,
		name = L["OPTIONS_ANCHOR"],
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
		name = L["OPTIONS_XOFFSET"],
		desc = "Adjust the position on the X axis." .. SliderRightClickDesc,
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
		name = L["OPTIONS_YOFFSET"],
		desc = "Adjust the position on the Y axis." .. SliderRightClickDesc,
	},
	
	{type = "breakline"},
	
	{type = "label", get = function() return "Auras per Row:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
	{
		type = "toggle",
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
		get = function() return Plater.db.profile.aura_timer end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.aura_timer = value
			Plater.RefreshAuras()
			Plater.UpdateAllPlates()
		end,
		name = L["OPTIONS_ENABLED"],
		desc = "Time left on buff or debuff.",
	},
	
	{
		type = "toggle",
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
		name = L["OPTIONS_FONT"],
		desc = "Font of the text.",
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
		name = L["OPTIONS_SIZE"],
		desc = "Size",
	},
	
	--text outline options
	{
		type = "select",
		get = function() return Plater.db.profile.aura_timer_text_outline end,
		values = function() return build_outline_modes_table (nil, "aura_timer_text_outline") end,
		name = L["OPTIONS_OUTLINE"],
		desc = "Outline",
	},
	
	--text shadow color
	{
		type = "color",
		get = function()
			local color = Plater.db.profile.aura_timer_text_shadow_color
			return {color[1], color[2], color[3], color[4]}
		end,
		set = function (self, r, g, b, a) 
			local color = Plater.db.profile.aura_timer_text_shadow_color
			color[1], color[2], color[3], color[4] = r, g, b, a
			Plater.UpdateAllPlates()
		end,
		name = L["OPTIONS_SHADOWCOLOR"],
		desc = ImportantText .. "hide and show nameplates to see changes.",
	},

	
	{
		type = "color",
		get = function()
			local color = Plater.db.profile.aura_timer_text_color
			return {color[1], color[2], color[3], color[4]}
		end,
		set = function (self, r, g, b, a) 
			local color = Plater.db.profile.aura_timer_text_color
			color[1], color[2], color[3], color[4] = r, g, b, a
			Plater.UpdateAllPlates()
		end,
		name = L["OPTIONS_COLOR"],
		desc = "Color",
	},
	{
		type = "select",
		get = function() return Plater.db.profile.aura_timer_text_anchor.side end,
		values = function() return build_anchor_side_table (nil, "aura_timer_text_anchor") end,
		name = L["OPTIONS_ANCHOR"],
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
		name = L["OPTIONS_XOFFSET"],
		desc = "Adjust the position on the X axis." .. SliderRightClickDesc,
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
		name = L["OPTIONS_YOFFSET"],
		desc = "Adjust the position on the Y axis." .. SliderRightClickDesc,
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
		get = function() return Plater.db.profile.aura_cooldown_reverse end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.aura_cooldown_reverse = value
			Plater.IncreaseRefreshID()
			Plater.UpdateAllPlates()
		end,
		name = "Swipe Closure Inverted",
		desc = "If enabled the swipe closure texture is applied as the swipe moves instead.",
	},
	
	{type = "breakline"},

	{type = "label", get = function() return "Automatic Aura Tracking:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},

	{
		type = "toggle",
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
		get = function() return Plater.db.profile.aura_show_defensive_cd end,
		set = function (self, fixedparam, value) 
			Plater.db.profile.aura_show_defensive_cd = value
			Plater.RefreshDBUpvalues()
			Plater.UpdateAllPlates()
		end,
		name = "Show defensive player CDs",
		desc = "Show defensive CDs on enemy/friendly players.",
	},
	
	{type = "blank"},

	{type = "label", get = function() return "Aura Border Colors:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
	{
		type = "color",
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
	
	{
		type = "toggle",
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

}

_G.C_Timer.After(0.850, function() --~delay
	DF:BuildMenu (auraOptionsFrame, debuff_options, startX, startY, heightSize, true, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template, globalCallback)
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
		height = 330, 
		row_height = 16,
		width = 200,
		button_text_template = "PLATER_BUTTON", --text template
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


--------------------------------------------------------------------------------------------------------------------------------------------------------------
--> unit color ~colors ñpccolor ~npccolor ~npc ñpc
--for import and export functions see ~importcolor ~exportcolor

	do
		if (true) then
			--options
			local scroll_width = 1050
			local scroll_height = 442
			local scroll_lines = 20
			local scroll_line_height = 20
			local backdrop_color = {.2, .2, .2, 0.2}
			local backdrop_color_on_enter = {.8, .8, .8, 0.4}
			local y = startY
			local headerY = y - 20
			local scrollY = headerY - 20
		
			--header
			local headerTable = {
				{text = "Enabled", width = 50},
				{text = "Scripts Only", width = 80},
				{text = "Npc ID", width = 64},
				{text = "Npc Name", width = 162},
				{text = "Rename To", width = 140},
				{text = "Zone Name", width = 142},
				{text = "", width = 110},
				{text = "", width = 270}, --filler
			}
			local headerOptions = {
				padding = 2,
			}
			
			colorsFrame.Header = DF:CreateHeader (colorsFrame, headerTable, headerOptions)
			colorsFrame.Header:SetPoint ("topleft", colorsFrame, "topleft", 10, headerY)
			
			colorsFrame.ModelFrame = CreateFrame ("PlayerModel", nil, colorsFrame, "ModelWithControlsTemplate, BackdropTemplate")
			colorsFrame.ModelFrame:SetSize (199, 440)
			colorsFrame.ModelFrame:EnableMouse (true)
			colorsFrame.ModelFrame:SetPoint ("topleft", colorsFrame.Header, "topright", -202, -scroll_line_height - 1)
			colorsFrame.ModelFrame:SetBackdrop ({bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
			colorsFrame.ModelFrame:SetBackdropColor (.4, .4, .4, 1)

			colorsFrame.ModelFrame:SetScript ("OnEnter", nil)
			--colorsFrame.ModelFrame:SetScript ("OnMouseWheel", nil)
			colorsFrame.ModelFrame.zoomLevel = 0.1
			colorsFrame.ModelFrame.minZoom = 0.01
			colorsFrame.ModelFrame.maxZoom = 1
			
			--store npcID = checkbox object
			--this is used when selecting the color from the dropdown, it'll automatically enable the color and need to set the checkbox to checked for feedback
			colorsFrame.CheckBoxCache = {}
			
			--line scripts
			local line_onenter = function (self)
				if (self.hasHighlight) then
					local r, g, b, a = unpack(highlightColorLastCombat)
					self:SetBackdropColor(r, g, b, a+0.2)
				else
					self:SetBackdropColor (unpack (backdrop_color_on_enter))
				end

				if (self.npcID) then
					colorsFrame.ModelFrame:SetCreature (self.npcID)
				end
			end
			local line_onleave = function (self)
				if (self.hasHighlight) then
					self:SetBackdropColor (unpack(highlightColorLastCombat))
				else
					self:SetBackdropColor (unpack (self.backdrop_color))
				end

				GameTooltip:Hide()
				colorsFrame.ModelFrame:SetCreature (1)
			end
			
			local widget_onenter = function (self)
				local line = self:GetParent()
				line:GetScript ("OnEnter")(line)
			end
			local widget_onleave = function (self)
				local line = self:GetParent()
				line:GetScript ("OnLeave")(line)
			end
			
			local oneditfocusgained_spellid = function (self, capsule)
				self:HighlightText (0)
			end
			
			local refresh_line_color = function (self, color)
				color = color or backdrop_color
				local r, g, b = DF:ParseColors (color)
				local a = 0.2
				self:SetBackdropColor (r, g, b, a)
				self.backdrop_color = self.backdrop_color or {}
				self.backdrop_color[1] = r
				self.backdrop_color[2] = g
				self.backdrop_color[3] = b
				self.backdrop_color[4] = a
				
				self.ColorDropdown:Select (color)
			end
			
			local onToggleEnabled = function (self, npcID, state)
				if (not DB_NPCID_COLORS [npcID]) then
					DB_NPCID_COLORS [npcID] = {false, false, "blue"}
				end
				DB_NPCID_COLORS [npcID][1] = state
				
				if (state) then
					self:GetParent():RefreshColor (DB_NPCID_COLORS [npcID][3])
				else
					self:GetParent():RefreshColor()
					--disable only for scripts
					DB_NPCID_COLORS [npcID][2] = false
					self:GetParent().ForScriptsCheckbox:SetValue (false)
				end
				
				Plater.RefreshDBLists()
				Plater.UpdateAllNameplateColors()
				Plater.ForceTickOnAllNameplates()
				
				colorsFrame.RefreshDropdowns()
			end
			
			local onToggleForScripts = function (self, npcID, state)
				if (not DB_NPCID_COLORS [npcID]) then
					DB_NPCID_COLORS [npcID] = {true, false, "blue"}
				end
				
				DB_NPCID_COLORS [npcID][2] = state
				
				if (state) then
					local checkBox = colorsFrame.CheckBoxCache [npcID]
					if (checkBox) then
						checkBox:SetValue (true)
					end
					
					DB_NPCID_COLORS [npcID][1] = true
					self:GetParent():RefreshColor (DB_NPCID_COLORS [npcID][3])
				end
				
				if (not DB_NPCID_COLORS [npcID][1]) then
					self:GetParent():RefreshColor()
				end
				
				Plater.RefreshDBLists()
				Plater.UpdateAllNameplateColors()
				Plater.ForceTickOnAllNameplates()
				
				colorsFrame.RefreshDropdowns()
			end
			
			local line_select_color_dropdown = function (self, npcID, color)
				if (not DB_NPCID_COLORS [npcID]) then
					DB_NPCID_COLORS [npcID] = {true, false, "blue"}
				end
				
				DB_NPCID_COLORS [npcID][1] = true
				DB_NPCID_COLORS [npcID][3] = color
				
				local checkBox = colorsFrame.CheckBoxCache [npcID]
				if (checkBox) then
					checkBox:SetValue (true)
				end
				
				self:GetParent():RefreshColor (color)
				
				Plater.RefreshDBLists()
				Plater.ForceTickOnAllNameplates()
				
				colorsFrame.cachedColorTable = nil
				colorsFrame.cachedColorTableNameplate = nil
				colorsFrame.RefreshDropdowns()
			end
			
			local function hex (num)
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
			
			local function sort_color (t1, t2)
				return t1[1][3] > t2[1][3]
			end
			
			local line_refresh_color_dropdown = function (self)
				if (not self.npcID) then
					return {}
				end
				
				if (not colorsFrame.cachedColorTable) then
					local colorsAdded = {}
					local colorsAddedT = {}
					local t = {}
					
					--add colors already in use first
					--get colors that are already in use and pull them to be the first colors in the dropdown
					for npcID, npcColorTable in pairs (DB_NPCID_COLORS) do
						local color = npcColorTable [3]
						if (not colorsAdded [color]) then
							colorsAdded [color] = true
							local r, g, b = DF:ParseColors (color)
							tinsert (colorsAddedT, {{r, g, b}, color, hex (r * 255) .. hex (g * 255) .. hex (b * 255)})
						end
					end
					--table.sort (colorsAddedT, sort_color)
					
					for index, colorTable in ipairs (colorsAddedT) do
						local colortable = colorTable [1]
						local colorname = colorTable [2]
						tinsert (t, {label = " " .. colorname, value = colorname, color = colortable, onclick = line_select_color_dropdown, 
						statusbar = [[Interface\Tooltips\UI-Tooltip-Background]],
						icon = [[Interface\AddOns\Plater\media\star_empty_64]],
						iconcolor = {1, 1, 1, .6},
						})
					end
				
					--all colors
					local allColors = {}
					for colorName, colorTable in pairs (DF:GetDefaultColorList()) do
						if (not colorsAdded [colorName]) then
							tinsert (allColors, {colorTable, colorName, hex (colorTable[1]*255) .. hex (colorTable[2]*255) .. hex (colorTable[3]*255)})
						end
					end
					--table.sort (allColors, sort_color)
					
					for index, colorTable in ipairs (allColors) do
						local colortable = colorTable [1]
						local colorname = colorTable [2]
						tinsert (t, {label = colorname, value = colorname, color = colortable, onclick = line_select_color_dropdown})
					end
					
					colorsFrame.cachedColorTable = t
					return t
				else
					return colorsFrame.cachedColorTable
				end
			end

			--line
			local scroll_createline = function (self, index)
			
				local line = CreateFrame ("button", "$parentLine" .. index, self, BackdropTemplateMixin and "BackdropTemplate")
				line:SetPoint ("topleft", self, "topleft", 1, -((index-1)*(scroll_line_height+1)) - 1)
				line:SetSize (scroll_width - 3 - colorsFrame.ModelFrame:GetWidth(), scroll_line_height)
				line:SetScript ("OnEnter", line_onenter)
				line:SetScript ("OnLeave", line_onleave)
				
				line.RefreshColor = refresh_line_color
				
				line:SetBackdrop ({bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
				line:SetBackdropColor (unpack (backdrop_color))
				
				DF:Mixin (line, DF.HeaderFunctions)
				
				--enabled check box
				local enabledCheckBox = DF:CreateSwitch (line, onToggleEnabled, true, _, _, _, _, "EnabledCheckbox", "$parentEnabledToggle" .. index, _, _, _, nil, DF:GetTemplate ("switch", "OPTIONS_CHECKBOX_BRIGHT_TEMPLATE"))
				enabledCheckBox:SetAsCheckBox()
				
				--bypass checkbox
				local forScriptCheckBox = DF:CreateSwitch (line, onToggleForScripts, true, _, _, _, _, "ForScriptsCheckbox", "$parentForScriptsToggle" .. index, _, _, _, nil, DF:GetTemplate ("switch", "OPTIONS_CHECKBOX_BRIGHT_TEMPLATE"))
				forScriptCheckBox:SetAsCheckBox()
				
				--npc ID
				local npcIDEntry = DF:CreateTextEntry (line, function()end, headerTable[3].width, 20, "NpcIDEntry", nil, nil, DF:GetTemplate ("dropdown", "PLATER_DROPDOWN_OPTIONS"))
				npcIDEntry:SetHook ("OnEditFocusGained", oneditfocusgained_spellid)			
				npcIDEntry:SetJustifyH("left")
				
				--npc Name
				local npcNameEntry = DF:CreateTextEntry(line, function()end, headerTable[4].width, 20, "NpcNameEntry", nil, nil, DF:GetTemplate ("dropdown", "PLATER_DROPDOWN_OPTIONS"))
				npcNameEntry:SetHook("OnEditFocusGained", oneditfocusgained_spellid)
				npcNameEntry:SetJustifyH("left")
				
				--rename box
				local npcRenameEntry = DF:CreateTextEntry(line, function()end, headerTable[5].width, 20, "NpcRenameEntry", nil, nil, DF:GetTemplate ("dropdown", "PLATER_DROPDOWN_OPTIONS"))
				npcRenameEntry:SetHook("OnEditFocusGained", oneditfocusgained_spellid)
				npcRenameEntry:SetJustifyH("left")

				npcRenameEntry:SetHook("OnEditFocusLost", function(widget, capsule, text)
					local npcsRenamed = Plater.db.profile.npcs_renamed
					local npcID = capsule.npcID
					capsule.text = npcsRenamed[npcID] or ""
				end)

				npcRenameEntry:SetHook("OnEnterPressed", function(widget, capsule, text)
					local npcsRenamed = Plater.db.profile.npcs_renamed
					local npcID = capsule.npcID
					if (text == "") then
						npcsRenamed[npcID] = nil
					else
						npcsRenamed[npcID] = text
					end

					Plater.UpdateAllPlates()
				end)

				--zone name
				local zoneNameLabel = DF:CreateLabel (line, "", 10, "white", nil, "ZoneNameLabel")
				
				--color
				local colorDropdown = DF:CreateDropDown (line, line_refresh_color_dropdown, 1, headerTable[7].width + 68, 20, "ColorDropdown", nil, DF:GetTemplate ("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))
				
				enabledCheckBox:SetHook ("OnEnter", widget_onenter)
				enabledCheckBox:SetHook ("OnLeave", widget_onleave)
				forScriptCheckBox:SetHook ("OnEnter", widget_onenter)
				forScriptCheckBox:SetHook ("OnLeave", widget_onleave)
				npcIDEntry:SetHook ("OnEnter", widget_onenter)
				npcIDEntry:SetHook ("OnLeave", widget_onleave)
				npcNameEntry:SetHook ("OnEnter", widget_onenter)
				npcNameEntry:SetHook ("OnLeave", widget_onleave)
				npcRenameEntry:SetHook ("OnEnter", widget_onenter)
				npcRenameEntry:SetHook ("OnLeave", widget_onleave)
				colorDropdown:SetHook ("OnEnter", widget_onenter)
				colorDropdown:SetHook ("OnLeave", widget_onleave)
				
				line:AddFrameToHeaderAlignment (enabledCheckBox)
				line:AddFrameToHeaderAlignment (forScriptCheckBox)
				line:AddFrameToHeaderAlignment (npcIDEntry)
				line:AddFrameToHeaderAlignment (npcNameEntry)
				line:AddFrameToHeaderAlignment (npcRenameEntry)
				line:AddFrameToHeaderAlignment (zoneNameLabel)
				line:AddFrameToHeaderAlignment (colorDropdown)
				
				line:AlignWithHeader (colorsFrame.Header, "left")
				
				return line
			end
			
			local sort_enabled_colors = function (t1, t2)
				if (t1[2] < t2[2]) then --color
					return true
					
				elseif (t1[2] > t2[2]) then --color
					return false
					
				else
					return t1[3] < t2[3] --alphabetical
				end
			end
			
			--refresh scroll
			local IsSearchingFor
			local scroll_refresh = function (self, data, offset, total_lines)
			
				--data has all npcIDs from dungeons
			
				local dataInOrder = {}

				local canSortByLastCombat = false
				local lastCombatNpcs = Plater.LastCombat.npcNames
				if (next(lastCombatNpcs)) then
					canSortByLastCombat = true
				end

				if (IsSearchingFor and IsSearchingFor ~= "") then
					if (self.SearchCachedTable and IsSearchingFor == self.SearchCachedTable.SearchTerm) then
						dataInOrder = self.SearchCachedTable
					else
					
						local enabledTable = {}
					
						for i = 1, #data do
							local npcID = data [i][1]
							local npcName = data [i][2] or "UNKNOWN"
							local zoneName = data [i][3] or "UNKNOWN"
							local color = DB_NPCID_COLORS [npcID] and DB_NPCID_COLORS [npcID][1] and DB_NPCID_COLORS [npcID][3] or "white" --has | is enabled | color
						
							if (npcName:lower():find (IsSearchingFor) or zoneName:lower():find (IsSearchingFor)) then
								if (DB_NPCID_COLORS [npcID] and DB_NPCID_COLORS [npcID][1]) then
									enabledTable [#enabledTable+1] = {1, color, npcName, zoneName, npcID}
								else
									dataInOrder [#dataInOrder+1] = {0, color, npcName, zoneName, npcID}
								end
							end
						end

						table.sort (enabledTable, sort_enabled_colors)
						table.sort (dataInOrder, DF.SortOrder3R) --npc name
						
						for i = #enabledTable, 1, -1 do
							tinsert (dataInOrder, 1, enabledTable[i])
						end
						
						self.SearchCachedTable = dataInOrder
						self.SearchCachedTable.SearchTerm = IsSearchingFor
					end
				else
					if (not self.CachedTable) then
						local enabledTable = {}
						local lastCombatNpcsList = {}
					
						for i = 1, #data do
							local npcID = data [i][1]
							local npcName = data [i][2]
							local zoneName = data [i][3]
							local color = DB_NPCID_COLORS [npcID] and DB_NPCID_COLORS [npcID][1] and DB_NPCID_COLORS [npcID][3] or "white" --has | is enabled | color
							
							if (canSortByLastCombat and lastCombatNpcs[npcName]) then
								lastCombatNpcsList [#lastCombatNpcsList+1] = {2, color, npcName, zoneName, npcID}

							elseif (DB_NPCID_COLORS [npcID] and DB_NPCID_COLORS [npcID][1]) then
								enabledTable [#enabledTable+1] = {1, color, npcName, zoneName, npcID}

							else
								dataInOrder [#dataInOrder+1] = {0, color, npcName, zoneName, npcID}
							end
						end
						
						self.CachedTable = dataInOrder
						
						table.sort (enabledTable, sort_enabled_colors)
						table.sort (dataInOrder, DF.SortOrder3R) --npc name

						--add enabled
						for i = #enabledTable, 1, -1 do
							tinsert (dataInOrder, 1, enabledTable[i])
						end
						--add from last combat
						for i = #lastCombatNpcsList, 1, -1 do
							tinsert (dataInOrder, 1, lastCombatNpcsList[i])
						end
					end
					
					dataInOrder = self.CachedTable
				end
				
				if (#dataInOrder > 6) then
					colorsFrame.EmptyText:Hide()
				end
				--
				
				data = dataInOrder

				local npcsRenamed = Plater.db.profile.npcs_renamed

				for i = 1, total_lines do
					local index = i + offset
					local npcTable = data [index]
					
					if (npcTable) then
						local line = self:GetLine (i)
						local npcID = npcTable [5]
						local npcName = npcTable [3]
						local zoneName = npcTable [4]
						local isFromLastCombat = npcTable[1] == 2
						
						line.value = npcTable
						line.npcID = nil
						
						if (npcName) then
							local colorOption = DB_NPCID_COLORS [npcID]
						
							line.npcID = npcID
						
							line.ColorDropdown.npcID = npcID
							line.ColorDropdown:SetFixedParameter (npcID)
						
							line.NpcIDEntry:SetText (npcID)
							line.NpcNameEntry:SetText (npcName)
							line.NpcRenameEntry:SetText(npcsRenamed[npcID] or "")
							line.NpcRenameEntry.npcID = npcID
							line.ZoneNameLabel:SetText (zoneName)
							line.hasHighlight = nil
							
							colorsFrame.CheckBoxCache [npcID] = line.EnabledCheckbox
					
							if (colorOption) then
								--causing lag in the scroll - might be an issue with dropdown:Select
								--Select: is calling a dispatch making it to rebuild the entire color table, may be caching the color table might save performance
								line.EnabledCheckbox:SetValue (colorOption [1])
								line.ForScriptsCheckbox:SetValue (colorOption [2])
								line.ColorDropdown:Select (colorOption [3])
								
								if (colorOption [1]) then
									line:RefreshColor (colorOption [3])
								else
									line:RefreshColor()
								end
							else
								line.EnabledCheckbox:SetValue (false)
								line.ForScriptsCheckbox:SetValue (false)
								line.ColorDropdown:Select ("white")
								
								line:RefreshColor()

								if (isFromLastCombat) then
									line.hasHighlight = true
									line:SetBackdropColor(unpack(highlightColorLastCombat))
								end
							end
							
							line.EnabledCheckbox:SetFixedParameter (npcID)
							line.ForScriptsCheckbox:SetFixedParameter (npcID)

						else
							line:Hide()
						end
					end
				end
			end
			
			--create scroll
			local spells_scroll = DF:CreateScrollBox (colorsFrame, "$parentColorsScroll", scroll_refresh, {}, scroll_width, scroll_height, scroll_lines, scroll_line_height)
			DF:ReskinSlider (spells_scroll)
			spells_scroll:SetPoint ("topleft", colorsFrame, "topleft", 10, scrollY)
			
			colorsFrame.ModelFrame:SetFrameLevel (spells_scroll:GetFrameLevel() + 20)
			
			spells_scroll:SetScript ("OnShow", function (self)
				if (self.LastRefresh and self.LastRefresh+0.5 > GetTime()) then
					return
				end
				self.LastRefresh = GetTime()
			
				local newData = {}
				
				for npcID, npcIDTable in pairs (DB_NPCID_CACHE) do
					tinsert (newData, {
						npcID, 
						npcIDTable [1], --name
						npcIDTable [2], --zone
					})
				end
				
				self.CachedTable = nil
				self.SearchCachedTable = nil
				
				self:SetData (newData)
				self:Refresh()
			end)
			
			--create lines
			for i = 1, scroll_lines do 
				spells_scroll:CreateLine (scroll_createline)
			end
			
			--create search box
				function colorsFrame.OnSearchBoxTextChanged()
					local text = colorsFrame.AuraSearchTextEntry:GetText()
					if (text and string.len (text) > 0) then
						IsSearchingFor = text:lower()
					else
						IsSearchingFor = nil
					end
					spells_scroll:Refresh()
				end

				local aura_search_textentry = DF:CreateTextEntry (colorsFrame, function()end, 150, 20, "AuraSearchTextEntry", _, _, options_dropdown_template)
				aura_search_textentry:SetPoint ("bottomright", colorsFrame.ModelFrame, "topright", 0, 1)
				aura_search_textentry:SetHook ("OnChar",		colorsFrame.OnSearchBoxTextChanged)
				aura_search_textentry:SetHook ("OnTextChanged", 	colorsFrame.OnSearchBoxTextChanged)
				local aura_search_label = DF:CreateLabel (aura_search_textentry, "search", DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"))
				aura_search_label:SetPoint ("left", aura_search_textentry, "left", 4, 0)
				aura_search_label.fontcolor = "gray"
				aura_search_label.color = {.5, .5, .5, .3}
				aura_search_textentry.tooltip = "|cFFFFFF00Npc Name|r or |cFFFFFF00Zone Name|r"
				aura_search_textentry:SetFrameLevel (colorsFrame.Header:GetFrameLevel() + 20)
				
				--clear search button
				local clear_search_button = DF:CreateButton (colorsFrame, function() aura_search_textentry:SetText(""); aura_search_textentry:ClearFocus() end, 20, 20, "", -1)
				clear_search_button:SetPoint ("right", aura_search_textentry, "right", 5, 0)
				clear_search_button:SetAlpha (.7)
				clear_search_button:SetIcon ([[Interface\Glues\LOGIN\Glues-CheckBox-Check]])
				clear_search_button.icon:SetDesaturated (true)
				clear_search_button:SetFrameLevel (colorsFrame.Header:GetFrameLevel() + 21)
			
				function colorsFrame.RefreshScroll (refreshSpeed)
					spells_scroll:Hide() 
					C_Timer.After (refreshSpeed or .01, function() spells_scroll:Show() end)
				end

			--help button
				local help_button = DF:CreateButton (colorsFrame, function()end, 70, 20, "help", -1, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
				help_button:SetPoint ("right", aura_search_textentry, "left", -2, 0)
				help_button.tooltip = "|cFFFFFF00Help:|r\n\n- Run dungeons and raids to fill the npc list.\n\n- |cFFFFEE00Scripts Only|r aren't automatically applied, scripts can import the color set here using |cFFFFEE00local colorTable = Plater.GetNpcColor (unitFrame)|r.\n\n- Colors set here override threat colors.\n\n- Colors set in scripts override colors set here.\n\n- |TInterface\\AddOns\\Plater\\media\\star_empty_64:16:16|t icon indicates the color is favorite, so you can use it across dungeons to keep color consistency."                                               
				help_button:SetFrameLevel (colorsFrame.Header:GetFrameLevel() + 20)
				
			--refresh button
				local refresh_button = DF:CreateButton (colorsFrame, function() colorsFrame.RefreshScroll() end, 70, 20, "refresh", -1, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
				refresh_button:SetPoint ("right", help_button, "left", -2, 0)
				refresh_button.tooltip = "refresh the list the npcs"
				refresh_button:SetFrameLevel (colorsFrame.Header:GetFrameLevel() + 20)
			 
				local create_import_box = function (parent, mainFrame)
					--import and export string text editor
					
					local edit_script_size = {620, 431}
					--text editor
					local luaeditor_backdrop_color = {.2, .2, .2, .5}
					local luaeditor_border_color = {0, 0, 0, 1}
					local edit_script_size = {620, 431}
					local buttons_size = {120, 20}

					local import_text_editor = DF:NewSpecialLuaEditorEntry (parent, edit_script_size[1], edit_script_size[2], "ImportEditor", "$parentImportEditor", true)
					import_text_editor:SetBackdrop ({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
					import_text_editor:SetBackdropBorderColor (unpack (luaeditor_border_color))
					import_text_editor:SetBackdropColor (.3, .3, .3, 1)
					import_text_editor:Hide()
					import_text_editor:SetFrameLevel (parent:GetFrameLevel()+100)
					DF:ReskinSlider (import_text_editor.scroll)
					
					local bg = import_text_editor:CreateTexture (nil, "background")
					bg:SetColorTexture (0.1, 0.1, 0.1, .9)
					bg:SetAllPoints()
					
					local block_mouse_frame = CreateFrame ("frame", nil, import_text_editor, BackdropTemplateMixin and "BackdropTemplate")
					block_mouse_frame:SetFrameLevel (block_mouse_frame:GetFrameLevel()-5)
					block_mouse_frame:SetAllPoints()
					block_mouse_frame:SetScript ("OnMouseDown", function()
						import_text_editor:SetFocus (true)
					end)
					
					--hide the code editor when the import text editor is shown
					import_text_editor:SetScript ("OnShow", function()
						--mainFrame.CodeEditorLuaEntry:Hide()
					end)
					
					--show the code editor when the import text editor is hide
					import_text_editor:SetScript ("OnHide", function()
						--mainFrame.CodeEditorLuaEntry:Show()
					end)
					
					mainFrame.ImportTextEditor = import_text_editor
					
					--import info
					local info_import_label = DF:CreateLabel (import_text_editor, "", DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"))
					info_import_label:SetPoint ("bottomleft", import_text_editor, "topleft", 0, 2)
					mainFrame.ImportTextEditor.TextInfo = info_import_label
					
					--import button
					local okay_import_button = DF:CreateButton (import_text_editor, mainFrame.ImportColors, buttons_size[1], buttons_size[2], "Okay", -1, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
					okay_import_button:SetIcon ([[Interface\BUTTONS\UI-Panel-BiggerButton-Up]], 20, 20, "overlay", {0.1, .9, 0.1, .9})
					okay_import_button:SetPoint ("topright", import_text_editor, "bottomright", 0, 1)
					
					--cancel button
					local cancel_import_button = DF:CreateButton (import_text_editor, function() mainFrame.ImportTextEditor:Hide() end, buttons_size[1], buttons_size[2], "Cancel", -1, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
					cancel_import_button:SetIcon ([[Interface\BUTTONS\UI-Panel-MinimizeButton-Up]], 20, 20, "overlay", {0.1, .9, 0.1, .9})
					cancel_import_button:SetPoint ("right", okay_import_button, "left", -2, 0)
					
					import_text_editor.OkayButton = okay_import_button
					import_text_editor.CancelButton = cancel_import_button
				end			 
				
				-- ~importcolor
				function colorsFrame.ImportColors()
					--get the colors from the text field and code it to import

					if (colorsFrame.IsImporting) then
						local text = colorsFrame.ImportEditor:GetText()
						text = DF:Trim (text)
						local colorData = Plater.DecompressData (text, "print")
					
						--exported npc colors has this member to identify the exported data
						if (colorData and colorData.NpcColor) then
							--store which npcs has a color enabled
							local dbColors = Plater.db.profile.npc_colors
							--table storing all npcs already detected inside dungeons and raids
							local allNpcsDetectedTable = Plater.db.profile.npc_cache
							local allNpcsRenamed = Plater.db.profile.npcs_renamed

							--the uncompressed table is a numeric table of tables
							for i, colorTable in pairs (colorData) do
								--check integrity
								if (type (colorTable) == "table") then
									local npcID, scriptOnly, colorID, npcName, zoneName, renamedName = unpack (colorTable)
									if (npcID and colorID and npcName and zoneName) then
										if (type (colorID) == "string" and type (npcName) == "string" and type (zoneName) == "string") then
											if (type (npcID) == "number" and type (scriptOnly) == "boolean") then
												dbColors [npcID] = dbColors [npcID] or {}
												dbColors [npcID] [1] = true --the color for the npc is enabled
												dbColors [npcID] [2] = scriptOnly --the color is only used in scripts
												dbColors [npcID] [3] = colorID --string with the color name
												
												--add this npcs in the npcs detected table as well
												allNpcsDetectedTable [npcID] = allNpcsDetectedTable [npcID] or {}
												allNpcsDetectedTable [npcID] [1] = npcName
												allNpcsDetectedTable [npcID] [2] = zoneName
												
												allNpcsRenamed [npcID] = renamedName
											end
										end
									end
								end
							end
							
							colorsFrame.RefreshScroll()
							Plater:Msg ("npc colors imported.")

						else
							Plater.SendScriptTypeErrorMsg(colorData)
						end
					end
					
					colorsFrame.ImportEditor:Hide()
					
				end
			 
			--import and export buttons
				local import_func = function()
					if (not colorsFrame.ImportEditor) then
						create_import_box (colorsFrame, colorsFrame)
					end
					
					colorsFrame.IsExporting = nil
					colorsFrame.IsImporting = true
					
					colorsFrame.ImportEditor:Show()
					colorsFrame.ImportEditor:SetPoint ("topleft", colorsFrame.Header, "topleft")
					colorsFrame.ImportEditor:SetPoint ("bottomright", colorsFrame, "bottomright", -17, 37)
					
					colorsFrame.ImportEditor:SetText ("")
					C_Timer.After (.1, function()
						colorsFrame.ImportEditor.editbox:HighlightText()
						colorsFrame.ImportEditor.editbox:SetFocus (true)
					end)
				end
				local import_button = DF:CreateButton (colorsFrame, import_func, 70, 20, "import", -1, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
				import_button:SetPoint ("right", refresh_button, "left", -2, 0)
				import_button:SetFrameLevel (colorsFrame.Header:GetFrameLevel() + 20)
				
				local export_func = function()
					if (not colorsFrame.ImportEditor) then
						create_import_box (colorsFrame, colorsFrame)
					end
					
					--build the list of colors to be exported
					--~exportcolor ~export color table to string
					--this is the table which will be compress with libdeflate
					local exportedTable = {
						NpcColor = true, --identify this table as a npc color table
					}
					
					--check if the user is searching npcs, build the export table only using the npcs shown in the result
					if (IsSearchingFor and IsSearchingFor ~= "" and spells_scroll.SearchCachedTable) then
						local dbColors = Plater.db.profile.npc_colors
						
						for i, searchResult in ipairs (spells_scroll.SearchCachedTable) do
						
							local _, _, npcName, zoneName, npcID = unpack (searchResult)
							local infoTable = dbColors [npcID]

							if (infoTable) then
								local enabled1 = infoTable [1] --boolean, this is the overall enabled
								local enabled2 = infoTable [2] --boolean, if this is true, this color is only used for scripts
								local colorID = infoTable [3] --string, the color name

								--build a table to store one the npc and insert the table inside the main table which will be compressed
								--only add the npc if it is enabled in the color panel
								if (enabled1) then
									local renamedName = Plater.db.profile.npcs_renamed [npcID]
															--number| boolean |string  |string  |string   |string
									tinsert (exportedTable, {npcID, enabled2, colorID, npcName, zoneName, renamedName})
								end
							end
						end
					
					else
						--table storing all npcs already detected inside dungeons and raids, need it to get the zone name
						local allNpcsDetectedTable = Plater.db.profile.npc_cache
						
						--make the list
						for npcID, infoTable in pairs (Plater.db.profile.npc_colors) do
							local enabled1 = infoTable [1] --boolean, this is the overall enabled
							local enabled2 = infoTable [2] --boolean, if this is true, this color is only used for scripts
							local colorID = infoTable [3] --string, the color name
							
							local npcName = allNpcsDetectedTable [npcID] and allNpcsDetectedTable [npcID] [1]
							local zoneName = allNpcsDetectedTable [npcID] and allNpcsDetectedTable [npcID] [2]

							--build a table to store one the npc and insert the table inside the main table which will be compressed
							--only add the npc if it is enabled in the color panel
							if (enabled1 and npcName and zoneName) then
								local renamedName = Plater.db.profile.npcs_renamed [npcID]
															--number| boolean |string  |string  |string   |string
									tinsert (exportedTable, {npcID, enabled2, colorID, npcName, zoneName, renamedName})
							end
						end
					end
					
					--check if there's at least 1 npc
					if (#exportedTable < 1) then
						Plater:Msg ("There's nothing to export.")
						return
					end
					
					colorsFrame.IsExporting = true
					colorsFrame.IsImporting = nil
					
					colorsFrame.ImportEditor:Show()
					colorsFrame.ImportEditor:SetPoint ("topleft", colorsFrame.Header, "topleft")
					colorsFrame.ImportEditor:SetPoint ("bottomright", colorsFrame, "bottomright", -17, 37)
					
					--compress data and show it in the text editor
					local data = Plater.CompressData (exportedTable, "print")
					colorsFrame.ImportEditor:SetText (data or "failed to export color table")
					
					C_Timer.After (.1, function()
						colorsFrame.ImportEditor.editbox:HighlightText()
						colorsFrame.ImportEditor.editbox:SetFocus (true)
					end)
				end
				
				local export_button = DF:CreateButton (colorsFrame, export_func, 70, 20, "export", -1, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
				export_button:SetPoint ("right", import_button, "left", -2, 0)
				export_button:SetFrameLevel (colorsFrame.Header:GetFrameLevel() + 20)
			
			--disable all button
				local disableAllColors = function()
					for npcId, colorTable in pairs (Plater.db.profile.npc_colors) do
						colorTable[1] = false
						colorTable[2] = false
					end
					colorsFrame.RefreshScroll()
				end
				local disableall_button = DF:CreateButton (colorsFrame, disableAllColors, 140, 20, "Disable All Colors", -1, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
				disableall_button:SetPoint ("bottomleft", spells_scroll, "bottomleft", 1, 0)
				disableall_button:SetFrameLevel (colorsFrame.Header:GetFrameLevel() + 20)
			
			--set all scripts only
				local setAllAsScriptOnly = function()
					for npcId, colorTable in pairs (Plater.db.profile.npc_colors) do
						if (colorTable[1]) then
							colorTable[2] = true
						end
					end
					colorsFrame.RefreshScroll()
				end
				local scriptsall_button = DF:CreateButton (colorsFrame, setAllAsScriptOnly, 200, 20, "Set All Enabled as 'Scripts Only'", -1, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
				scriptsall_button:SetPoint ("left", disableall_button, "right", 0, 0)
				scriptsall_button:SetFrameLevel (colorsFrame.Header:GetFrameLevel() + 20)
				
				local addnpc_text = DF:CreateLabel (scriptsall_button, "Use '/plater addnpc' to add a npc in open world.")
				addnpc_text.fontsize = 12
				addnpc_text.fontcolor = "gray"
				addnpc_text:SetPoint ("left", scriptsall_button, "right", 10, 0)
			
			-- buttons backdrop
				local backdropFoot = CreateFrame ("frame", nil, spells_scroll, BackdropTemplateMixin and "BackdropTemplate")
				backdropFoot:SetHeight (20)
				backdropFoot:SetPoint ("bottomleft", spells_scroll, "bottomleft", 0, 0)
				backdropFoot:SetPoint ("bottomright", colorsFrame.ModelFrame, "bottomleft", -3, 0)
				backdropFoot:SetBackdrop ({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
				backdropFoot:SetBackdropColor (.52, .52, .52, .7)
				backdropFoot:SetBackdropBorderColor (0, 0, 0, 1)
				backdropFoot:SetFrameLevel (colorsFrame.Header:GetFrameLevel() + 19)
			
			--empty label
				local empty_text = DF:CreateLabel (colorsFrame, "this list is automatically filled when\nyou see enemies inside a dungeon or raid\n\nthen you may select colors here or directly\nin the dropdown below the nameplate")
				empty_text.fontsize = 24
				empty_text.align = "|"
				empty_text:SetPoint ("center", spells_scroll, "center", -colorsFrame.ModelFrame:GetWidth() / 2, 0)
				colorsFrame.EmptyText = empty_text
			 
			--create the description
			colorsFrame.TitleDescText = Plater:CreateLabel (colorsFrame, "For raid and dungeon npcs, they are added into the list after you see them for the first time", 10, "silver")
			colorsFrame.TitleDescText:SetPoint ("bottomleft", spells_scroll, "topleft", 0, 26)
			
			colorsFrame:SetScript ("OnShow", function()
				
				local refresh_all_dropdowns = function()
				
					colorsFrame.cachedColorTable = nil
					colorsFrame.cachedColorTableNameplate = nil
				
					for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
						if (plateFrame.unitFrame.colorSelectionDropdown) then
							--if (Plater.ZoneInstanceType ~= "party" and Plater.ZoneInstanceType ~= "raid") then
							--	plateFrame.unitFrame.colorSelectionDropdown:Hide()
							--else
								local npcID = plateFrame.unitFrame.colorSelectionDropdown:GetParent() [MEMBER_NPCID]
								plateFrame.unitFrame.colorSelectionDropdown:Select (DB_NPCID_COLORS [npcID] and DB_NPCID_COLORS [npcID][1] and DB_NPCID_COLORS [npcID][3] or "white")
								plateFrame.unitFrame.colorSelectionDropdown:Show()
							--end
						end
					end
				end
				
				colorsFrame.RefreshDropdowns = refresh_all_dropdowns
				
				local function hex (num)
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
				
				local function sort_color (t1, t2)
					return t1[1][3] > t2[1][3]
				end
				
				local make_dropdown = function (plateFrame)
					local line_select_color_dropdown = function (self, npcID, color)
					
						local unitFrame = self:GetParent()
						local npcID = unitFrame [MEMBER_NPCID]
						
						if (npcID) then
							if (not DB_NPCID_CACHE [npcID]) then
								DB_NPCID_CACHE [npcID] = {unitFrame.PlateFrame [MEMBER_NAME], Plater.ZoneName}
								
								if (PlaterOptionsPanelFrame and PlaterOptionsPanelFrame:IsShown()) then
									PlaterOptionsPanelContainerColorManagementColorsScroll:Hide()
									C_Timer.After (.2, function()
										PlaterOptionsPanelContainerColorManagementColorsScroll:Show()
									end)
								end
								
							end
							if (not DB_NPCID_COLORS [npcID]) then
								DB_NPCID_COLORS [npcID] = {true, false, "blue"}
							end
							
							DB_NPCID_COLORS [npcID][1] = true
							DB_NPCID_COLORS [npcID][3] = color
							
							local checkBox = colorsFrame.CheckBoxCache [npcID]
							if (checkBox) then
								checkBox:SetValue (true)
								checkBox:GetParent():RefreshColor (color)
							end
							
							Plater.RefreshDBLists()
							Plater.ForceTickOnAllNameplates()
							
							refresh_all_dropdowns()
							
							colorsFrame.RefreshScroll()
						end
					end

					local line_refresh_color_dropdown = function (self)
						if (not self:GetParent() [MEMBER_NPCID]) then
							return {}
						end
						
						if (not colorsFrame.cachedColorTableNameplate) then
							local colorsAdded = {}
							local colorsAddedT = {}
							local t = {}
							
							--add colors already in use first
							--get colors that are already in use and pull them to be the first colors in the dropdown
							for npcID, npcColorTable in pairs (DB_NPCID_COLORS) do
								local color = npcColorTable [3]
								if (not colorsAdded [color]) then
									colorsAdded [color] = true
									local r, g, b = DF:ParseColors (color)
									tinsert (colorsAddedT, {{r, g, b}, color, hex (r * 255) .. hex (g * 255) .. hex (b * 255)})
								end
							end
							--table.sort (colorsAddedT, sort_color)
							
							for index, colorTable in ipairs (colorsAddedT) do
								local colortable = colorTable [1]
								local colorname = colorTable [2]
								tinsert (t, {label = " " .. colorname, value = colorname, color = colortable, onclick = line_select_color_dropdown, 
								statusbar = [[Interface\Tooltips\UI-Tooltip-Background]],
								icon = [[Interface\AddOns\Plater\media\star_empty_64]],
								iconcolor = {1, 1, 1, .6},
								})
							end
						
							--all colors
							local allColors = {}
							for colorName, colorTable in pairs (DF:GetDefaultColorList()) do
								if (not colorsAdded [colorName]) then
									tinsert (allColors, {colorTable, colorName, hex (colorTable[1]*255) .. hex (colorTable[2]*255) .. hex (colorTable[3]*255)})
								end
							end
							--table.sort (allColors, sort_color)
							
							for index, colorTable in ipairs (allColors) do
								local colortable = colorTable [1]
								local colorname = colorTable [2]
								tinsert (t, {label = colorname, value = colorname, color = colortable, onclick = line_select_color_dropdown})
							end
							
							colorsFrame.cachedColorTableNameplate = t
							return t
						else
							return colorsFrame.cachedColorTableNameplate
						end

					end

					local dropdown = DF:CreateDropDown (plateFrame.unitFrame, line_refresh_color_dropdown, 1, headerTable[6].width, 20, nil, nil, DF:GetTemplate ("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))
					dropdown:SetHeight (14)
					dropdown.widget.arrowTexture:SetSize (22, 22)
					dropdown.widget.arrowTexture2:Hide()
					
					plateFrame.unitFrame.colorSelectionDropdown = dropdown
					
					dropdown:SetPoint ("topleft", plateFrame.unitFrame, "bottomleft", 0, 0)
					dropdown:SetPoint ("topright", plateFrame.unitFrame, "bottomright", 0, 0)
					
					dropdown:SetHook ("OnShow", function()
						C_Timer.After (0.1, function()
							local npcID = dropdown:GetParent() [MEMBER_NPCID]
							dropdown:Select (DB_NPCID_COLORS [npcID] and DB_NPCID_COLORS [npcID][1] and DB_NPCID_COLORS [npcID][3] or "white")
						end)
					end)
					
					local npcID = dropdown:GetParent() [MEMBER_NPCID]
					dropdown:Select (DB_NPCID_COLORS [npcID] and DB_NPCID_COLORS [npcID][1] and DB_NPCID_COLORS [npcID][3] or "white")
					
					if (Plater.ZoneInstanceType ~= "party" and Plater.ZoneInstanceType ~= "raid") then
						--dropdown:Hide()
					end
					
					--reset button
					local reset = function()
						local npcID = dropdown:GetParent()[MEMBER_NPCID]
						if (DB_NPCID_COLORS [npcID]) then
							
							local checkBox = colorsFrame.CheckBoxCache [npcID]
							if (checkBox) then
								checkBox:SetValue (false)
								checkBox:GetParent().ForScriptsCheckbox:SetValue (false)
								checkBox:GetParent():RefreshColor()
							end
							
							DB_NPCID_COLORS [npcID] [1] = false
							DB_NPCID_COLORS [npcID] [2] = false
							
							Plater.RefreshDBLists()
							Plater.ForceTickOnAllNameplates()
							Plater.UpdateAllNameplateColors()
							
							refresh_all_dropdowns()
							
							dropdown:Select ("white")
							
							colorsFrame.RefreshScroll()
						end
					end
					
					local clear_color_button = DF:CreateButton (dropdown, function() reset() end, 20, 20, "", -1)
					clear_color_button:SetPoint ("left", dropdown, "right", 0, 0)
					clear_color_button:SetAlpha (.8)
					clear_color_button:SetIcon ([[Interface\Glues\LOGIN\Glues-CheckBox-Check]])
				end
				
				for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
					if (not plateFrame.unitFrame.colorSelectionDropdown) then
						make_dropdown (plateFrame)
					end
				end
				
				refresh_all_dropdowns()
				
				colorsFrame:SetScript ("OnEvent", function (self, event, unitBarId)
					local plateFrame = C_NamePlate.GetNamePlateForUnit (unitBarId)
					if (not plateFrame) then
						return
					end
				
					if (event == "NAME_PLATE_UNIT_REMOVED") then
						if (plateFrame.unitFrame.colorSelectionDropdown) then
							plateFrame.unitFrame.colorSelectionDropdown:Hide()
						end
					
					elseif (event == "NAME_PLATE_UNIT_ADDED") then
					
						if (Plater.ZoneInstanceType ~= "party" and Plater.ZoneInstanceType ~= "raid") then
							--return
						end
					
						local dropdown = plateFrame.unitFrame.colorSelectionDropdown
						if (not dropdown) then
							make_dropdown (plateFrame)
							dropdown = plateFrame.unitFrame.colorSelectionDropdown
						end
						
						C_Timer.After (0.1, function()
							local npcID = dropdown:GetParent() [MEMBER_NPCID]
							dropdown:Select (DB_NPCID_COLORS [npcID] and DB_NPCID_COLORS [npcID][1] and DB_NPCID_COLORS [npcID][3] or "white")
						end)
						
						dropdown:Show()
					end
				end)
				
				colorsFrame:RegisterEvent ("NAME_PLATE_UNIT_ADDED")
				colorsFrame:RegisterEvent ("NAME_PLATE_UNIT_REMOVED")
			end)
			
			colorsFrame:SetScript ("OnHide", function()
				colorsFrame:UnregisterEvent ("NAME_PLATE_UNIT_ADDED")
				colorsFrame:UnregisterEvent ("NAME_PLATE_UNIT_REMOVED")
				
				if (colorsFrame.ImportEditor) then
					colorsFrame.ImportEditor:Hide()
					colorsFrame.ImportEditor.IsExporting = nil
					colorsFrame.ImportEditor.IsImporting = nil
				end
				
				for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
					if (plateFrame.unitFrame.colorSelectionDropdown) then
						plateFrame.unitFrame.colorSelectionDropdown:Hide()
					end
				end
			end)
		end
	
	end	
	
--------------------------------------------------------------------------------------------------------------------------------------------------------------
--> last event auras ~listbuff ~bufflist 

	do
		--options
		local scroll_width = 1050
		local scroll_height = 442
		local scroll_lines = 21
		local scroll_line_height = 20
		local backdrop_color = {.2, .2, .2, 0.2}
		local backdrop_color_on_enter = {.8, .8, .8, 0.4}
		local y = startY
		local headerY = y - 20
		local scrollY = headerY - 20
	
		--header
		local headerTable = {
			{text = "Icon", width = 32},
			{text = "Spell ID", width = 74},
			{text = "Spell Name", width = 162},
			{text = "Source", width = 130},
			{text = "Spell Type", width = 70},
			{text = "Add to Tracklist", width = 100},
			{text = "Add to Blacklist", width = 100},
			{text = "Add to Special Auras", width = 120},
			{text = "Add to Script", width = 120},
			{text = "From Last Combat", width = 120}, --, icon = _G.WeakAuras and [[Interface\AddOns\WeakAuras\Media\Textures\icon]] or ""
		}
		local headerOptions = {
			padding = 2,
		}
		
		auraLastEventFrame.Header = DF:CreateHeader (auraLastEventFrame, headerTable, headerOptions)
		auraLastEventFrame.Header:SetPoint ("topleft", auraLastEventFrame, "topleft", 10, headerY)

		--line scripts
		local line_onenter = function (self)
			if (self.hasHighlight) then
				local r, g, b, a = unpack(highlightColorLastCombat)
				self:SetBackdropColor(r, g, b, a+0.2)
			else
				self:SetBackdropColor (unpack (backdrop_color_on_enter))
			end

			if (self.SpellID) then
				GameTooltip:SetOwner (self, "ANCHOR_TOPLEFT")
				GameTooltip:SetSpellByID (self.SpellID)
				GameTooltip:AddLine (" ")
				GameTooltip:Show()
			end
		end
		
		local line_onleave = function (self)
			if (self.hasHighlight) then
				self:SetBackdropColor(unpack(highlightColorLastCombat))
			else
				self:SetBackdropColor(unpack(backdrop_color))
			end
			GameTooltip:Hide()
		end
		
		local widget_onenter = function (self)
			local line = self:GetParent()
			line:GetScript ("OnEnter")(line)
		end
		local widget_onleave = function (self)
			local line = self:GetParent()
			line:GetScript ("OnLeave")(line)
		end
		
		local line_add_tracklist = function (self)
			self = self:GetCapsule()

			if (self.AuraType == "BUFF") then
				if (Plater.db.profile.aura_tracker.track_method == 0x1) then
					Plater.db.profile.aura_tracker.buff_tracked [self.SpellID] = true
					Plater:Msg ("Aura added to buff tracking.")
					
				elseif (Plater.db.profile.aura_tracker.track_method == 0x2) then
					local added = DF.table.addunique (Plater.db.profile.aura_tracker.buff, self.SpellID)
					if (added) then
						Plater:Msg ("Aura added to manual buff tracking.")
					else
						Plater:Msg ("Aura not added: already on track.")
					end
					
				end
			
			elseif (self.AuraType == "DEBUFF") then
				if (Plater.db.profile.aura_tracker.track_method == 0x1) then
					Plater.db.profile.aura_tracker.debuff_tracked [self.SpellID] = true
					Plater:Msg ("Aura added to debuff tracking.")
					
				elseif (Plater.db.profile.aura_tracker.track_method == 0x2) then
					local added = DF.table.addunique (Plater.db.profile.aura_tracker.debuff, self.SpellID)
					if (added) then
						Plater:Msg ("Aura added to manual debuff tracking.")
					else
						Plater:Msg ("Aura not added: already on track.")
					end
					
				end
			end
		end
		
		local line_add_ignorelist = function (self)
			self = self:GetCapsule()
			
			if (self.AuraType == "BUFF") then
				if (Plater.db.profile.aura_tracker.track_method == 0x1) then
					Plater.db.profile.aura_tracker.buff_banned [self.SpellID] = true
					Plater:Msg ("Aura added to buff blacklist.")
				end
			
			elseif (self.AuraType == "DEBUFF") then
				if (Plater.db.profile.aura_tracker.track_method == 0x1) then
					Plater.db.profile.aura_tracker.debuff_banned [self.SpellID] = true
					Plater:Msg ("Aura added to debuff blacklist.")
				end
			end
		end
		
		local line_add_special = function (self)
			self = self:GetCapsule()
			
			local added = DF.table.addunique (Plater.db.profile.extra_icon_auras, self.SpellID)
			if (added) then
				Plater:Msg ("Aura added to the special aura container.")
			else
				Plater:Msg ("Aura not added: already on the special container.")
			end
		end
		
		local line_onclick_trigger_dropdown = function (self, fixedValue, scriptID)
			local scriptObject = Plater.GetScriptObject (scriptID, "script")
			local spellName = GetSpellInfo (self.SpellID)
			
			if (scriptObject and spellName) then
				if (scriptObject.ScriptType == 1 or scriptObject.ScriptType == 2) then
					--add the trigger
					local added = DF.table.addunique (scriptObject.SpellIds, self.SpellID)
					if (added) then
						--reload all scripts
						Plater.WipeAndRecompileAllScripts ("script")
						Plater:Msg ("Trigger added to script.")
					else
						Plater:Msg ("Script already have this trigger.")
					end
					
					--refresh and select no option
					self:Refresh()
					self:Select (0, true)
				end
			end
		end
		
		local line_refresh_trigger_dropdown = function (self)
			if (not self.SpellID) then
				return {}
			end
			
			local t = {}
			local spellName = GetSpellInfo (self.SpellID)

			local scripts = Plater.GetAllScripts ("script")
			for i = 1, #scripts do
				local scriptObject = scripts [i]
				if (scriptObject.ScriptType == 1 or scriptObject.ScriptType == 2) then
					tinsert (t, {0, 0, scriptObject.Name, scriptObject.Enabled and 1 or 0, 0, label = scriptObject.Name, value = i, color = scriptObject.Enabled and "white" or "red", onclick = line_onclick_trigger_dropdown, desc = scriptObject.Desc})
				end
			end
			
			table.sort (t, Plater.SortScripts)
			return t
		end
		
		local line_create_aura = function (self)
			self = self:GetCapsule()
			
			if (Details) then
				local spellName, _, spellIcon = GetSpellInfo (self.SpellID)
				local encounterID = self.EncounterID
				
				Details:OpenAuraPanel (self.SpellID, spellName, spellIcon, encounterID, self.AuraType == "BUFF" and 5 or self.AuraType == "DEBUFF" and 1 or self.IsCast and 7 or 2, 1)
				PlaterOptionsPanelFrame:Hide()
			else
				Plater:Msg ("Details! Damage Meter not found, install it from the Twitch App!")
			end
		end
	
		local oneditfocusgained_spellid = function (self, capsule)
			self:HighlightText (0)
		end
	
		--line
		local scroll_createline = function (self, index)
		
			local line = CreateFrame ("button", "$parentLine" .. index, self, BackdropTemplateMixin and "BackdropTemplate")
			line:SetPoint ("topleft", self, "topleft", 1, -((index-1)*(scroll_line_height+1)) - 1)
			line:SetSize (scroll_width - 2, scroll_line_height)
			line:SetScript ("OnEnter", line_onenter)
			line:SetScript ("OnLeave", line_onleave)
			
			line:SetBackdrop ({bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
			line:SetBackdropColor (unpack (backdrop_color))
			
			DF:Mixin (line, DF.HeaderFunctions)
			
			local icon = line:CreateTexture ("$parentSpellIcon", "overlay")
			icon:SetSize (scroll_line_height - 2, scroll_line_height - 2)
			
			local spell_id = DF:CreateTextEntry (line, function()end, headerTable[2].width, 20, nil, nil, nil, DF:GetTemplate ("dropdown", "PLATER_DROPDOWN_OPTIONS"))
			spell_id:SetHook ("OnEditFocusGained", oneditfocusgained_spellid)
			spell_id:SetJustifyH("left")
	
			local spell_name = DF:CreateLabel (line, "", DF:GetTemplate ("font", "PLATER_SCRIPTS_NAME"))
			local source_name = DF:CreateLabel (line, "", DF:GetTemplate ("font", "PLATER_SCRIPTS_NAME"))
			local spell_type = DF:CreateLabel (line, "", DF:GetTemplate ("font", "PLATER_SCRIPTS_NAME"))

			local add_tracklist = DF:CreateButton (line, line_add_tracklist, headerTable[6].width, 20, "Add", -1, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
			local add_ignorelist = DF:CreateButton (line, line_add_ignorelist, headerTable[7].width, 20, "Add", -1, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
			local add_special = DF:CreateButton (line, line_add_special, headerTable[8].width, 20, "Add", -1, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
			
			local add_script_trigger = DF:CreateDropDown (line, line_refresh_trigger_dropdown, 1, headerTable[9].width, 20, nil, nil, DF:GetTemplate ("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))
			
			local create_aura = DF:CreateButton (line, line_create_aura, headerTable[10].width, 20, "Create", -1, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
			
			local fromLastCombat = DF:CreateLabel (line, "", DF:GetTemplate ("font", "PLATER_SCRIPTS_NAME"))

			spell_id:SetHook ("OnEnter", widget_onenter)
			spell_id:SetHook ("OnLeave", widget_onleave)
			
			add_tracklist:SetHook ("OnEnter", widget_onenter)
			add_tracklist:SetHook ("OnLeave", widget_onleave)
			
			add_ignorelist:SetHook ("OnEnter", widget_onenter)
			add_ignorelist:SetHook ("OnLeave", widget_onleave)
			
			add_special:SetHook ("OnEnter", widget_onenter)
			add_special:SetHook ("OnLeave", widget_onleave)
			
			add_script_trigger:SetHook ("OnEnter", widget_onenter)
			add_script_trigger:SetHook ("OnLeave", widget_onleave)
			
			create_aura:SetHook ("OnEnter", widget_onenter)
			create_aura:SetHook ("OnLeave", widget_onleave)
			
			line:AddFrameToHeaderAlignment (icon)
			line:AddFrameToHeaderAlignment (spell_id)
			line:AddFrameToHeaderAlignment (spell_name)
			line:AddFrameToHeaderAlignment (source_name)
			line:AddFrameToHeaderAlignment (spell_type)
			line:AddFrameToHeaderAlignment (add_tracklist)
			line:AddFrameToHeaderAlignment (add_ignorelist)
			line:AddFrameToHeaderAlignment (add_special)
			line:AddFrameToHeaderAlignment (add_script_trigger)
			line:AddFrameToHeaderAlignment (fromLastCombat)
			--line:AddFrameToHeaderAlignment (create_aura)
			
			line:AlignWithHeader (auraLastEventFrame.Header, "left")
			
			line.Icon = icon
			line.SpellIDEntry = spell_id
			line.SpellName = spell_name
			line.SourceName = source_name
			line.SpellType = spell_type
			line.AddTrackList = add_tracklist
			line.AddIgnoreList = add_ignorelist
			line.AddSpecial = add_special
			line.AddTrigger = add_script_trigger
			line.CreateAura = create_aura
			line.FromLastCombat = fromLastCombat
			
			return line
		end
		
		--refresh scroll

		local sortOrder4 = function(t1, t2)
			return t1[4] > t2[4]
		end

		local IsSearchingFor
		local scroll_refresh = function (self, data, offset, total_lines)
		
			local dataInOrder = {}
			--buff list tab
			local lastCombatNpcs = Plater.LastCombat.npcNames or {}
			
			if (IsSearchingFor and IsSearchingFor ~= "") then
				if (self.SearchCachedTable and IsSearchingFor == self.SearchCachedTable.SearchTerm) then
					dataInOrder = self.SearchCachedTable
				else
					for i = 1, #data do
						local spellID = data[i] [1]
						local spellName, _, spellIcon = GetSpellInfo (spellID)
						local spellTable = data[i][2]
						if (spellName) then
							if (spellName:lower():find (IsSearchingFor)) then
								dataInOrder [#dataInOrder+1] = {i, data[i], spellName, lastCombatNpcs[spellTable.source] and 2 or 0}
							end
						end
					end

					self.SearchCachedTable = dataInOrder
					self.SearchCachedTable.SearchTerm = IsSearchingFor
				end
			else
				if (not self.CachedTable) then
					for i = 1, #data do
						local spellID = data[i] [1]
						local spellName, _, spellIcon = GetSpellInfo (spellID)
						local spellTable = data[i][2]
						if (spellName) then
							dataInOrder [#dataInOrder+1] = {i, data[i], spellName, lastCombatNpcs[spellTable.source] and 2 or 0}
						end
					end
					self.CachedTable = dataInOrder
				end
				
				dataInOrder = self.CachedTable
			end

			table.sort (dataInOrder, DF.SortOrder3R)
			table.sort (dataInOrder, sortOrder4)

			data = dataInOrder
		
			for i = 1, total_lines do
				local index = i + offset
				local spellTable = data [index] and data [index] [2]
				
				if (spellTable) then
					local line = self:GetLine (i)
					local spellID = spellTable [1]
					local spellData = spellTable [2]
					
					local spellName, _, spellIcon = GetSpellInfo (spellID)

					local fullData = data[index]
					local isFromLastSegment = fullData[4] == 2
					line.hasHighlight = isFromLastSegment

					if (line.hasHighlight) then
						line:SetBackdropColor(unpack(highlightColorLastCombat))
						line.FromLastCombat.text = "       YES"
					else
						line:SetBackdropColor(unpack(backdrop_color))
						line.FromLastCombat.text = ""
					end
					
					line.value = spellTable
					
					if (spellName) then
						line.Icon:SetTexture (spellIcon)
						line.Icon:SetTexCoord (.1, .9, .1, .9)
						
						line.SpellName:SetTextTruncated (spellName, headerTable [3].width)
						line.SourceName:SetTextTruncated (spellData.source, headerTable [4].width)
						
						local isCast = spellData.event == "SPELL_CAST_START" or spellData.event == "SPELL_CAST_SUCCESS"

						if (spellData.type == "BUFF") then
							line.SpellType.color = "PLATER_BUFF"
							
						elseif (spellData.type == "DEBUFF") then
							line.SpellType.color = "PLATER_DEBUFF"
							
						elseif (isCast) then
							line.SpellType.color = "PLATER_CAST"
							
						end
						
						line.SpellID = spellID
						
						line.SpellIDEntry:SetText (spellID)

						--{event = token, source = sourceName, type = auraType, npcID = Plater:GetNpcIdFromGuid (sourceGUID or "")}
						line.SpellType:SetText (isCast and "Spell Cast" or spellData.event == "SPELL_AURA_APPLIED" and spellData.type)
						
						line.AddTrackList.SpellID = spellID
						line.AddTrackList.AuraType = spellData.type
						line.AddTrackList.EncounterID = spellData.encounterID
						
						line.AddIgnoreList.SpellID = spellID
						line.AddIgnoreList.AuraType = spellData.type
						line.AddIgnoreList.EncounterID = spellData.encounterID
						
						line.AddSpecial.SpellID = spellID
						line.AddSpecial.AuraType = spellData.type
						line.AddSpecial.EncounterID = spellData.encounterID
						
						if (spellData.type) then
							line.AddTrackList:Enable()
							line.AddIgnoreList:Enable()
							line.AddSpecial:Enable()
						else
							line.AddTrackList:Disable()
							line.AddIgnoreList:Disable()
							line.AddSpecial:Disable()
						end
						
						line.CreateAura.SpellID = spellID
						line.CreateAura.AuraType = spellData.type
						line.CreateAura.IsCast = spellData.event == "SPELL_CAST_START"
						line.CreateAura.EncounterID = spellData.encounterID
						
						line.AddTrigger.SpellID = spellID
						line.AddTrigger:Refresh()
						
						--manual tracking doesn't have a black list
						if (Plater.db.profile.aura_tracker.track_method == 0x1) then
							if (spellData.type) then
								line.AddIgnoreList:Enable()
							end
							
						elseif (Plater.db.profile.aura_tracker.track_method == 0x2) then
							line.AddIgnoreList:Disable()
							
						end
						
					else
						line:Hide()
					end
				end
			end
		end
		
		--create scroll
		local spells_scroll = DF:CreateScrollBox (auraLastEventFrame, "$parentSpellScroll", scroll_refresh, {}, scroll_width, scroll_height, scroll_lines, scroll_line_height)
		DF:ReskinSlider (spells_scroll)
		spells_scroll:SetPoint ("topleft", auraLastEventFrame, "topleft", 10, scrollY)
		
		spells_scroll:SetScript ("OnShow", function (self)
			if (self.LastRefresh and self.LastRefresh+0.5 > GetTime()) then
				return
			end
			self.LastRefresh = GetTime()
		
			local newData = {}
			
			for spellID, spellTable in pairs (DB_CAPTURED_SPELLS) do
				tinsert (newData, {spellID, spellTable})
			end
			
			self.CachedTable = nil
			self.SearchCachedTable = nil
			
			self:SetData (newData)
			self:Refresh()
		end)
		
		--create lines
		for i = 1, scroll_lines do 
			spells_scroll:CreateLine (scroll_createline)
		end

		--create button to open spell list on Details!
		local openDetailsSpellList = function()
			if (Details) then
				Details.OpenForge()
				PlaterOptionsPanelFrame:Hide()
				--select all spells in the details! all spells panel
				if (DetailsForgePanel and DetailsForgePanel.SelectModule) then
					-- module 2 is the All Spells
					DetailsForgePanel.SelectModule (_, _, 1)
				end
			else
				Plater:Msg ("Details! Damage Meter is required and isn't installed, get it on Twitch App!")
			end
		end
		
		local open_spell_list_button = DF:CreateButton (auraLastEventFrame, openDetailsSpellList, 160, 20, "Open Full Spell List", -1, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
		open_spell_list_button:SetPoint ("bottomright", spells_scroll, "topright", 0, 24)

		--create the clean list button
			local wipe_spell_list = function()
				wipe (DB_CAPTURED_SPELLS)
				spells_scroll:Hide()
				C_Timer.After (0.016, function() spells_scroll:Show(); spells_scroll:Refresh() end)
			end
			local clear_list_button = DF:CreateButton (auraLastEventFrame, wipe_spell_list, 160, 20, "Clear List", -1, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate ("font", "PLATER_BUTTON"))
			clear_list_button:SetPoint ("right", open_spell_list_button, "left", -6, 0)
		
		--create search box
			function auraLastEventFrame.OnSearchBoxTextChanged()
				local text = auraLastEventFrame.AuraSearchTextEntry:GetText()
				if (text and string.len (text) > 0) then
					IsSearchingFor = text:lower()
				else
					IsSearchingFor = nil
				end
				spells_scroll:Refresh()
			end

			local aura_search_textentry = DF:CreateTextEntry (auraLastEventFrame, function()end, 160, 20, "AuraSearchTextEntry", _, _, options_dropdown_template)
			aura_search_textentry:SetPoint ("right", clear_list_button, "left", -6, 0)
			aura_search_textentry:SetHook ("OnChar",		auraLastEventFrame.OnSearchBoxTextChanged)
			aura_search_textentry:SetHook ("OnTextChanged", 	auraLastEventFrame.OnSearchBoxTextChanged)
			local aura_search_label = DF:CreateLabel (auraLastEventFrame, "Search:", DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"))
			aura_search_label:SetPoint ("right", aura_search_textentry, "left", -2, 0)
		
		--create the description
		auraLastEventFrame.TitleDescText = Plater:CreateLabel (auraLastEventFrame, "Quick way to manage auras from a recent raid boss or dungeon run", 10, "silver")
		auraLastEventFrame.TitleDescText:SetPoint ("bottomleft", spells_scroll, "topleft", 0, 26)
		
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
		
		local LoadGameSpellsCalled = false
		function specialAuraFrame.LoadGameSpells()
			if (not next (Plater.SpellHashTable) and not LoadGameSpellsCalled) then
				--load all spells in the game
				DF:LoadAllSpells (Plater.SpellHashTable, Plater.SpellIndexTable)
				LoadGameSpellsCalled = true
				return true
			end
		end
		
		local scroll_width = 280
		local scroll_height = 442
		local scroll_lines = 21
		local scroll_line_height = 20
		local backdrop_color = {.8, .8, .8, 0.2}
		local backdrop_color_on_enter = {.8, .8, .8, 0.4}
		local y = startY
		
		local showSpellWithSameName = function (self, spellID) 
			local spellName = GetSpellInfo (spellID)
			if (spellName) then
				local spellsWithSameName = Plater.db.profile.aura_cache_by_name [lower (spellName)]
				if (not spellsWithSameName) then
					DF.AddSpellWithSameName (spellID, Plater.db.profile.aura_cache_by_name)
					spellsWithSameName = Plater.db.profile.aura_cache_by_name [lower (spellName)]
				end
				
				if (spellsWithSameName) then
					GameCooltip2:Preset (2)
					GameCooltip2:SetOwner (self, "left", "right", 2, 0)
					GameCooltip2:SetOption ("TextSize", 10)
					
					for i, spellID in ipairs (spellsWithSameName) do
						local spellName, _, spellIcon = GetSpellInfo (spellID)
						if (spellName) then
							GameCooltip2:AddLine (spellName .. " (" .. spellID .. ")")
							GameCooltip2:AddIcon (spellIcon, 1, 1, 14, 14, .1, .9, .1, .9)
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

						if (not next (Plater.SpellHashTable)) then
							local loaded = specialAuraFrame.LoadGameSpells()
							if loaded then
								DF.LoadingAuraAlertFrame:HookScript("OnHide", function() self:Refresh() end)
							end
							--C_Timer.After (1, function() self:Refresh() end)
						end
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
					end
				end
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
			specialAuraFrame.LoadGameSpells()
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
			{type = "blank"},
			{type = "blank"},
			{type = "label", get = function() return "Icon Settings:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
			--anchor
			{
				type = "select",
				get = function() return Plater.db.profile.extra_icon_anchor.side end,
				values = function() return build_anchor_side_table (false, "extra_icon_anchor") end,
				name = L["OPTIONS_ANCHOR"],
				desc = "Which side of the nameplate this widget is attach to.",
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
				name = L["OPTIONS_XOFFSET"],
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
				name = L["OPTIONS_YOFFSET"],
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
				name = "Width",
				desc = "Width",
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
				name = "Height",
				desc = "Height",
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
				name = L["OPTIONS_FONT"],
				desc = "Font of the text.",
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
				name = L["OPTIONS_SIZE"],
				desc = "Size of the text.",
			},
			--text outline options
			{
				type = "select",
				get = function() return Plater.db.profile.extra_icon_timer_outline end,
				values = function() return build_outline_modes_table (nil, "extra_icon_timer_outline") end,
				name = L["OPTIONS_OUTLINE"],
				desc = "Outline",
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
				name = L["OPTIONS_FONT"],
				desc = "Font of the text.",
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
				name = L["OPTIONS_SIZE"],
				desc = "Size of the text.",
			},
			--text outline options
			{
				type = "select",
				get = function() return Plater.db.profile.extra_icon_caster_outline end,
				values = function() return build_outline_modes_table (nil, "extra_icon_caster_outline") end,
				name = L["OPTIONS_OUTLINE"],
				desc = "Outline",
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
				name = L["OPTIONS_FONT"],
				desc = "Font of the text.",
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
				name = L["OPTIONS_SIZE"],
				desc = "Size of the text.",
			},
			--text outline options
			{
				type = "select",
				get = function() return Plater.db.profile.extra_icon_stack_outline end,
				values = function() return build_outline_modes_table (nil, "extra_icon_stack_outline") end,
				name = L["OPTIONS_OUTLINE"],
				desc = "Outline",
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
			{type = "blank"},
			{type = "label", get = function() return "DBM / BigWigs Icon-Support:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},

			{
				type = "toggle",
				get = function() return Plater.db.profile.bossmod_support_enabled end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.bossmod_support_enabled = value
					Plater.UpdateAllPlates()
				end,
				name = L["OPTIONS_ENABLED"],
				desc = "Enable the boss mod icon support for BigWigs and DBM.",
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
				name = "Width",
				desc = "Width",
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
				name = "Height",
				desc = "Height",
			},
			
			--anchor
			{
			type = "select",
			get = function() return Plater.db.profile.bossmod_icons_anchor.side end,
			values = function() return build_anchor_side_table (nil, "bossmod_icons_anchor") end,
			name = L["OPTIONS_ANCHOR"],
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
				name = L["OPTIONS_XOFFSET"],
				desc = "Adjust the position on the X axis." .. SliderRightClickDesc,
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
				name = L["OPTIONS_YOFFSET"],
				desc = "Adjust the position on the Y axis." .. SliderRightClickDesc,
			},
			
			{type = "blank"},
			
			{type = "label", get = function() return "Cooldown Text:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
			{
				type = "toggle",
				get = function() return Plater.db.profile.bossmod_cooldown_text_enabled end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.bossmod_cooldown_text_enabled = value
					Plater.UpdateAllPlates()
				end,
				name = L["OPTIONS_ENABLED"],
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
				name = L["OPTIONS_SIZE"],
				desc = "Size",
			},
		}
		
		auraSpecialFrame.ExampleImageDesc = DF:CreateLabel (auraSpecialFrame, "Special auras look like this:", 14)
		auraSpecialFrame.ExampleImageDesc:SetPoint (330, -220)
		auraSpecialFrame.ExampleImage = DF:CreateImage (auraSpecialFrame, [[Interface\AddOns\Plater\images\extra_icon_example]], 256*0.8, 128*0.8)
		auraSpecialFrame.ExampleImage:SetPoint (330, -234)
		auraSpecialFrame.ExampleImage:SetAlpha (.834)
		
		local fff = CreateFrame ("frame", "$parentExtraIconsSettings", auraSpecialFrame, BackdropTemplateMixin and "BackdropTemplate")
		fff:SetAllPoints()

		_G.C_Timer.After(0.6, function() --~delay
			DF:BuildMenu (fff, especial_aura_settings, 330, startY - 27, heightSize, true, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template, globalCallback)
		end)

		--when the profile has changed
		function auraSpecialFrame:RefreshOptions()
			--update the script data for the scroll and refresh
			special_auras_added:SetData (Plater.db.profile.extra_icon_auras)
			special_auras_added:Refresh()
		end
		
		specialAuraFrame:SetScript ("OnShow", function()
			special_auras_added:Refresh()
			
			--not working properly, auras stay "flying" in the screen
			
			--[=[
			fff:SetScript ("OnUpdate", function()
				
				for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
					plateFrame.unitFrame.ExtraIconFrame:ClearIcons()
					plateFrame.unitFrame.ExtraIconFrame:SetIcon (248441, false, GetTime() - 2, 8)
					plateFrame.unitFrame.ExtraIconFrame:SetIcon (273769, false, GetTime() - 3, 12)
					plateFrame.unitFrame.ExtraIconFrame:SetIcon (206589, false, GetTime() - 6, 16)
					plateFrame.unitFrame.ExtraIconFrame:SetIcon (279565, false, GetTime() - 180, 360)

					local spellName, _, spellIcon = GetSpellInfo (248441)
					local auraIconFrame = Plater.GetAuraIcon (plateFrame.unitFrame.BuffFrame, 1)
					Plater.AddAura (auraIconFrame, 1, spellName, spellIcon, 1, "BUFF", 8, GetTime()+5, "player", false, false, 248441, false, false, false, false)
					auraIconFrame.InUse = true
					
					local spellName, _, spellIcon = GetSpellInfo (273769)
					local auraIconFrame = Plater.GetAuraIcon (plateFrame.unitFrame.BuffFrame, 1)
					Plater.AddAura (auraIconFrame, 2, spellName, spellIcon, 1, "BUFF", 12, GetTime()+2, "player", false, false, 273769, false, false, false, false)
					auraIconFrame.InUse = true
				end
			end)
			--]=]
		end)
		
		specialAuraFrame:SetScript ("OnHide", function()
			--[=[
			fff:SetScript ("OnUpdate", nil)
			
			
			for _, plateFrame in ipairs (Plater.GetAllShownPlates()) do
				plateFrame.unitFrame.ExtraIconFrame:ClearIcons()
				hide_non_used_auraFrames (plateFrame.unitFrame.BuffFrame, 1)
			end
			--]=]
			
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
			name = "Show Buffs",
			desc = "Show buffs on you on the Personal Bar.",
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
			name = "Show Debuffs",
			desc = "Show debuffs on you on the Personal Bar.",
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
			name = "Width",
			desc = "Debuff's icon width.",
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
			name = "Height",
			desc = "Debuff's icon height.",
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
			name = L["OPTIONS_YOFFSET"],
			desc = "Adjust the position on the Y axis." .. SliderRightClickDesc,
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
		
		{type = "blank"},
		{type = "label", get = function() return "Blizzard Cast Bar:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		
		--hide castbar from blizzard
		{
			type = "toggle",
			get = function() return Plater.db.profile.hide_blizzard_castbar end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.hide_blizzard_castbar = value
			end,
			name = "Hide Blizzard Player Cast Bar",
			desc = "Hide Blizzard Player Cast Bar",
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
			name = L["OPTIONS_ENABLED"],
			desc = "Show health bar",
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
			name = "Width",
			desc = "Width of the health bar.",
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
			name = "Height",
			desc = "Height of the health bar.",
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
			name = L["OPTIONS_ENABLED"],
			desc = "Show power bar",
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
			name = "Width",
			desc = "Width of the power bar.",
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
			name = "Height",
			desc = "Height of the power bar.",
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
			name = L["OPTIONS_ENABLED"],
			desc = "Show cast bar",
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
			name = "Width",
			desc = "Width of the cast bar.",
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
			name = "Height",
			desc = "Height of the cast bar.",
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
			name = L["OPTIONS_XOFFSET"],
			desc = "Adjust the position on the X axis." .. SliderRightClickDesc,
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
			name = L["OPTIONS_YOFFSET"],
			desc = "Adjust the position on the Y axis." .. SliderRightClickDesc,
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
			name = L["OPTIONS_SIZE"],
			desc = "Size of the text.",
		},
		--cast text font
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.player.spellname_text_font end,
			values = function() return DF:BuildDropDownFontList (on_select_player_npccastname_font) end,
			name = L["OPTIONS_FONT"],
			desc = "Font of the text.",
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
			name = L["OPTIONS_COLOR"],
			desc = "The color of the text.",
		},

		--text outline options
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.player.spellname_text_outline end,
			values = function() return build_outline_modes_table ("player", "spellname_text_outline") end,
			name = L["OPTIONS_OUTLINE"],
			desc = "Outline",
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
			name = L["OPTIONS_SHADOWCOLOR"],
			desc = ImportantText .. "hide and show nameplates to see changes.",
		},
		
		--spell name text anchor
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.player.spellname_text_anchor.side end,
			values = function() return build_anchor_side_table ("player", "spellname_text_anchor") end,
			name = L["OPTIONS_ANCHOR"],
			desc = "Which side of the nameplate this widget is attach to.",
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
			name = L["OPTIONS_XOFFSET"],
			desc = "Adjust the position on the X axis." .. SliderRightClickDesc,
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
			name = L["OPTIONS_YOFFSET"],
			desc = "Adjust the position on the Y axis." .. SliderRightClickDesc,
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
			name = L["OPTIONS_ENABLED"],
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
			name = L["OPTIONS_SIZE"],
			desc = "Size of the text.",
		},
		--cast time text font
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.player.spellpercent_text_font end,
			values = function() return DF:BuildDropDownFontList (on_select_player_spellpercent_text_font) end,
			name = L["OPTIONS_FONT"],
			desc = "Font of the text.",
		},
		
		--text outline options
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.player.spellpercent_text_outline end,
			values = function() return build_outline_modes_table ("player", "spellpercent_text_outline") end,
			name = L["OPTIONS_OUTLINE"],
			desc = "Outline",
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
			name = L["OPTIONS_SHADOWCOLOR"],
			desc = ImportantText .. "hide and show nameplates to see changes.",
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
			name = L["OPTIONS_COLOR"],
			desc = "The color of the text.",
		},
		
		--cast time anchor
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.player.spellpercent_text_anchor.side end,
			values = function() return build_anchor_side_table ("player", "spellpercent_text_anchor") end,
			name = L["OPTIONS_ANCHOR"],
			desc = "Which side of the nameplate this widget is attach to.",
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
			name = L["OPTIONS_XOFFSET"],
			desc = "Adjust the position on the X axis." .. SliderRightClickDesc,
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
			name = L["OPTIONS_YOFFSET"],
			desc = "Adjust the position on the Y axis." .. SliderRightClickDesc,
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
			name = L["OPTIONS_ENABLED"],
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
			name = L["OPTIONS_SIZE"],
			desc = "Size of the text.",
		},
		--percent text font
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.player.power_percent_text_font end,
			values = function() return DF:BuildDropDownFontList (on_select_player_power_percent_text_font) end,
			name = L["OPTIONS_FONT"],
			desc = "Font of the text.",
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
			name = L["OPTIONS_OUTLINE"],
			desc = "Outline",
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
			name = L["OPTIONS_SHADOWCOLOR"],
			desc = ImportantText .. "hide and show nameplates to see changes.",
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
			desc = "The color of the text.",
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
			name = L["OPTIONS_ALPHA"],
			desc = "Set the transparency of the text.",
			usedecimals = true,
		},
		--percent anchor
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.player.power_percent_text_anchor.side end,
			values = function() return build_anchor_side_table ("player", "power_percent_text_anchor") end,
			name = L["OPTIONS_ANCHOR"],
			desc = "Which side of the nameplate this widget is attach to.",
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
			name = L["OPTIONS_XOFFSET"],
			desc = "Adjust the position on the X axis." .. SliderRightClickDesc,
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
			name = L["OPTIONS_YOFFSET"],
			desc = "Adjust the position on the Y axis." .. SliderRightClickDesc,
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
			name = L["OPTIONS_ENABLED"],
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
			name = L["OPTIONS_COLOR"],
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
			name = L["OPTIONS_SIZE"],
			desc = "Size of the text.",
		},
		--percent text font
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.player.percent_text_font end,
			values = function() return DF:BuildDropDownFontList (on_select_player_percent_text_font) end,
			name = L["OPTIONS_FONT"],
			desc = "Font of the text.",
		},
		
		--text outline options
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.player.percent_text_outline end,
			values = function() return build_outline_modes_table ("player", "percent_text_outline") end,
			name = L["OPTIONS_OUTLINE"],
			desc = "Outline",
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
			name = L["OPTIONS_SHADOWCOLOR"],
			desc = ImportantText .. "hide and show nameplates to see changes.",
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
			name = L["OPTIONS_COLOR"],
			desc = "The color of the text.",
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
			name = L["OPTIONS_ALPHA"],
			desc = "Set the transparency of the text.",
			usedecimals = true,
		},
		--percent anchor
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.player.percent_text_anchor.side end,
			values = function() return build_anchor_side_table ("player", "percent_text_anchor") end,
			name = L["OPTIONS_ANCHOR"],
			desc = "Which side of the nameplate this widget is attach to.",
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
			name = L["OPTIONS_XOFFSET"],
			desc = "Adjust the position on the X axis." .. SliderRightClickDesc,
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
			name = L["OPTIONS_YOFFSET"],
			desc = "Adjust the position on the Y axis." .. SliderRightClickDesc,
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
			name = L["OPTIONS_ALPHA"],
			desc = "Resource Alpha",
		},
		
		{
			type = "range",
			get = function() return Plater.db.profile.resources.scale end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.resources.scale = value
				Plater.UpdateAllPlates()
			end,
			min = 0.65,
			max = 3,
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
			name = L["OPTIONS_YOFFSET"],
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
		DF:BuildMenu (personalPlayerFrame, options_personal, startX, startY, heightSize, true, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template, globalCallback)
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
			name = "Target Overlay Texture",
			desc = "Used above the health bar when it is the current target.",
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
			name = "Target Overlay Alpha",
			desc = "Target Overlay Alpha",
			usedecimals = true,
		},

		{type = "blank"},
		
		{
			type = "toggle",
			get = function() return Plater.db.profile.target_highlight end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.target_highlight = value
				Plater.UpdateAllPlates()
			end,
			name = "Target Highlight",
			desc = "Highlight effect on the nameplate of your current target.",
		},
		{
			type = "select",
			get = function() return Plater.db.profile.target_highlight_texture end,
			values = function() return target_selection_texture_selected_options end,
			name = "Target Highlight Texture",
			desc = "Target Highlight Texture.",
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
			name = "Target Highlight Alpha",
			desc = "Target Highlight Alpha.",
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
			name = "Target Highlight Size",
			desc = "Target Highlight Size",
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
			name = "Target Highlight Color",
			desc = "Target Highlight Color",
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
			name = "Hover Over Highlight",
			desc = "Highlight effect when the mouse is over the nameplate.\n\n" .. ImportantText .. "for enemies only (players and npcs).",
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
			name = "Hover Over Highlight Alpha",
			desc = "Hover Over Highlight Alpha",
			usedecimals = true,
		},		
		
		{type = "blank"},
		
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
			name = "Target Always on the Screen" .. CVarIcon,
			desc = "When enabled, the nameplate of your target is always shown even when the enemy isn't in the screen." .. CVarDesc,
			nocombat = true,
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
			name = "Lock to Screen (Top Side)" .. CVarIcon,
			desc = "Min space between the nameplate and the top of the screen. Increase this if some part of the nameplate are going out of the screen.\n\n|cFFFFFFFFDefault: 0.065|r\n\n" .. ImportantText .. "if you're having issue, manually set using these macros:\n/run SetCVar ('nameplateOtherTopInset', '0.065')\n/run SetCVar ('nameplateLargeTopInset', '0.065')\n\n" .. ImportantText .. "setting to 0 disables this feature." .. CVarDesc,
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
			name = L["OPTIONS_COLOR"],
			desc = "Focus Color",
		},
		{
			type = "select",
			get = function() return Plater.db.profile.focus_texture end,
			values = function() return focus_indicator_texture_options end,
			name = L["OPTIONS_TEXTURE"],
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
			name = L["OPTIONS_ANCHOR"],
			desc = "Which side of the nameplate this widget is attach to.",
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
			name = L["OPTIONS_XOFFSET"],
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
			name = L["OPTIONS_YOFFSET"],
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
	DF:BuildMenu (targetFrame, targetOptions, startX, startY, heightSize, true, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template, globalCallback)
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
	local on_select_castbar_target_font = function (_, _, value)
		Plater.db.profile.castbar_target_font = value
		Plater.UpdateAllPlates()
	end
	
	--menu 1 ~general ~geral
	local options_table1 = {

		{type = "label", get = function() return "Interface Options (from the client):" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "toggle",
			get = function() return GetCVar ("nameplateShowSelf") == CVAR_ENABLED end,
			set = function (self, fixedparam, value) 
				if (not InCombatLockdown()) then
					SetCVar ("nameplateShowSelf", math.abs (tonumber (GetCVar ("nameplateShowSelf") or 1)-1))
				else
					Plater:Msg (L["OPTIONS_ERROR_CVARMODIFY"])
					self:SetValue (GetCVar ("nameplateShowSelf") == CVAR_ENABLED)
				end
			end,
			name = "Personal Health and Mana Bars" .. CVarIcon,
			desc = "Shows a mini health and mana bars under your character." .. CVarDesc,
			nocombat = true,
			hidden = IS_WOW_PROJECT_NOT_MAINLINE,
		},
		{
			type = "toggle",
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
			name = "Show Resources on Target",
			desc = "Shows your resource such as combo points above your current target.\nUses Blizzard default resources and disables Platers own resources.\n\nCharacter specific setting!",
			nocombat = true,
			hidden = IS_WOW_PROJECT_NOT_MAINLINE,
		},
		{
			type = "toggle",
			get = function() return GetCVar (CVAR_SHOWALL) == CVAR_ENABLED end,
			set = function (self, fixedparam, value) 
				if (not InCombatLockdown()) then
					SetCVar (CVAR_SHOWALL, math.abs (tonumber (GetCVar (CVAR_SHOWALL))-1))
				else
					Plater:Msg (L["OPTIONS_ERROR_CVARMODIFY"])
					self:SetValue (GetCVar (CVAR_SHOWALL) == CVAR_ENABLED)
				end
			end,
			name = "Always Show Nameplates" .. CVarIcon,
			desc = "Show nameplates for all units near you. If disabled only show relevant units when you are in combat." .. CVarDesc,
			nocombat = true,
		},

		{
			type = "toggle",
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
			name = "Stacking Nameplates" .. CVarIcon,
			desc = "If enabled, nameplates won't overlap each other." .. CVarDesc .. "\n\n" .. ImportantText .. "to set the amount of space between each nameplate see '|cFFFFFFFFNameplate Vertical Padding|r' option below.\nPlease check the Auto tab settings to setup automatic toggling of this option.",
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
			name = "Nameplate Overlap (V)" .. CVarIcon,
			desc = "The space between each nameplate vertically when stacking is enabled.\n\n|cFFFFFFFFDefault: 1.10|r" .. CVarDesc .. "\n\n" .. ImportantText .. "if you find issues with this setting, use:\n|cFFFFFFFF/run SetCVar ('nameplateOverlapV', '1.6')|r",
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
			min = IS_WOW_PROJECT_MAINLINE and 60 or 20, --20y for tbc and classic
			max = (IS_WOW_PROJECT_MAINLINE and 60) or (IS_WOW_PROJECT_CLASSIC_TBC and 41) or 20, --41y for tbc, 20y for classic era
			step = 1,
			name = "View Distance" .. CVarIcon,
			desc = "How far you can see nameplates (in yards).\n\n|cFFFFFFFFCurrent limitations: Retail = 60y, TBC = 20-41y, Classic = 20y|r" .. CVarDesc,
			nocombat = true,
		},
	
		{type = "blank"},
		
		{
			type = "toggle",
			get = function() return GetCVarBool ("nameplateShowEnemies") end,
			set = function (self, fixedparam, value) 
				if (not InCombatLockdown()) then
					SetCVar ("nameplateShowEnemies", value and "1" or "0")
				else
					Plater:Msg (L["OPTIONS_ERROR_CVARMODIFY"])
					self:SetValue (GetCVarBool ("nameplateShowEnemies"))
				end
			end,
			name = "Show Enemy Nameplates" .. CVarIcon,
			desc = "Show nameplate for enemy and neutral units." .. CVarDesc,
			nocombat = true,
		},
		
		{
			type = "toggle",
			get = function() return GetCVarBool ("nameplateShowFriends") end,
			set = function (self, fixedparam, value) 
				if (not InCombatLockdown()) then
					SetCVar ("nameplateShowFriends", value and "1" or "0")
				else
					Plater:Msg (L["OPTIONS_ERROR_CVARMODIFY"])
					self:SetValue (GetCVarBool ("nameplateShowFriends"))
				end
			end,
			name = "Show Friendly Nameplates" .. CVarIcon,
			desc = "Show nameplate for friendly players." .. CVarDesc,
			nocombat = true,
		},
		
		{
			type = "toggle",
			get = function() return GetCVarBool ("nameplateShowOnlyNames") end,
			set = function (self, fixedparam, value) 
				if (not InCombatLockdown()) then
					SetCVar ("nameplateShowOnlyNames", value and "1" or "0")
				else
					Plater:Msg (L["OPTIONS_ERROR_CVARMODIFY"])
					self:SetValue (GetCVarBool ("nameplateShowOnlyNames"))
				end
			end,
			name = "Hide Blizzard Health Bars" .. CVarIcon,
			desc = "While in dungeons or raids, if friendly nameplates are enabled it'll show only the player name.\nIf any Plater module is disabled, this will affect these nameplates as well." .. CVarDesc .. CVarNeedReload,
			nocombat = true,
		},

		{type = "blank"},

		{type = "label", get = function() return L["OPTIONS_GENERALSETTINGS_HEALTHBAR_ANCHOR_TITLE"] end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "select",
			get = function() return Plater.db.profile.health_statusbar_texture end,
			values = function() return health_bar_texture_options end,
			name = L["OPTIONS_GENERALSETTINGS_HEALTHBAR_TEXTURE"],
			desc = L["OPTIONS_GENERALSETTINGS_HEALTHBAR_TEXTURE"],
		},
		{
			type = "select",
			get = function() return Plater.db.profile.health_statusbar_bgtexture end,
			values = function() return health_bar_bgtexture_options end,
			name = L["OPTIONS_GENERALSETTINGS_HEALTHBAR_BGTEXTURE"],
			desc = L["OPTIONS_GENERALSETTINGS_HEALTHBAR_BGTEXTURE"],
		},
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.health_statusbar_bgcolor
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.health_statusbar_bgcolor
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllPlates()
			end,
			name = L["OPTIONS_GENERALSETTINGS_HEALTHBAR_BGCOLOR"],
			desc = L["OPTIONS_GENERALSETTINGS_HEALTHBAR_BGCOLOR"],
		},

		{
			type = "color",
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
			name = "Border Color",
			desc = "Color of the plate border.",
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
			name = "Border Thickness",
			desc = "How thick the border should be.\n\n" .. ImportantText .. "right click the slider to manually type the value.",
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
			name = "Health Bar Width",
			desc = "Change the width of Enemy and Friendly nameplates for players and npcs in combat and out of combat.\n\nEach one of these options can be changed individually on Enemy Npc, Enemy Player tabs.",
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
			name = "Health Bar Height",
			desc = "Change the height of Enemy and Friendly nameplates for players and npcs in combat and out of combat.\n\nEach one of these options can be changed individually on Enemy Npc, Enemy Player tabs.",
		},

		{type = "breakline"},
		
		{type = "label", get = function() return L["OPTIONS_GENERALSETTINGS_TRANSPARENCY_ANCHOR_TITLE"] end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
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
			name = "Units Out of Your Range",
			desc = "When a nameplate is out of range, alpha is reduced.",
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
			name = "Units Which Isn't Your Target",
			desc = "When a nameplate isn't your current target, alpha is reduced.",
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
			name = "Out of Range + Isn't Your Target",
			desc = "Reduces the alpha of units which isn't your target.\nReduces even more if the unit is out of range.",
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
			name = "Nothing",
			desc = "No alpha modifications is applyed.",
			boxfirst = true,
			id = "transparency_none",
			novolatile = true,
		},

		{type = "blank"},
		{type = "label", get = function() return "General:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "toggle",
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
			get = function() return Plater.db.profile.not_affecting_combat_enabled end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.not_affecting_combat_enabled = value
				Plater.UpdateAllPlates()
			end,
			name = "Use No Combat Alpha",
			desc = "Changes the nameplate alpha when you are in combat and the unit isn't.\n\n" .. ImportantText .. "If the unit isn't in combat, it overrides the alpha from the range check.",
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
			name = "No Combat Alpha",
			desc = "Amount of transparency to apply for 'No Combat' feature.",
			usedecimals = true,
		},

		{type = "blank"},
		
		{type = "label", get = function() return "Range Check By Yards - Enemy" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},		
	}
	
	if IS_WOW_PROJECT_MAINLINE then
		local playerSpecs = Plater.SpecList [select (2, UnitClass ("player"))]
		for specID, _ in pairs (playerSpecs) do
			local spec_id, spec_name, spec_description, spec_icon, spec_background, spec_role, spec_class = GetSpecializationInfoByID (specID)
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
					local checkers = LibRangeCheck:GetHarmCheckers()
					for range, checker in checkers do
						tinsert (t, {label = range, onclick = onSelectFunc, value = range})
					end
					return t
				end,
				name = "|T" .. spec_icon .. ":16:16|t " .. L["OPTIONS_GENERALSETTINGS_TRANSPARENCY_RANGECHECK"],
				desc = L["OPTIONS_GENERALSETTINGS_TRANSPARENCY_RANGECHECK_SPEC_DESC"],
			})
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
				local checkers = LibRangeCheck:GetHarmCheckers()
				for range, checker in checkers do
					tinsert (t, {label = range, onclick = onSelectFunc, value = range})
				end
				return t
			end,
			name = L["OPTIONS_GENERALSETTINGS_TRANSPARENCY_RANGECHECK"],
			desc = L["OPTIONS_GENERALSETTINGS_TRANSPARENCY_RANGECHECK_SPEC_DESC"],
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
					local checkers = LibRangeCheck:GetFriendCheckers()
					for range, checker in checkers do
						tinsert (t, {label = range, onclick = onSelectFunc, value = range})
					end
					return t
				end,
				name = "|T" .. spec_icon .. ":16:16|t " .. L["OPTIONS_GENERALSETTINGS_TRANSPARENCY_RANGECHECK"],
				desc = L["OPTIONS_GENERALSETTINGS_TRANSPARENCY_RANGECHECK_SPEC_DESC"],
			})
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
				local checkers = LibRangeCheck:GetFriendCheckers()
				for range, checker in checkers do
					tinsert (t, {label = range, onclick = onSelectFunc, value = range})
				end
				return t
			end,
			name = L["OPTIONS_GENERALSETTINGS_TRANSPARENCY_RANGECHECK"],
			desc = L["OPTIONS_GENERALSETTINGS_TRANSPARENCY_RANGECHECK_SPEC_DESC"],
		})
	end

	local options_table1_continue2 = {
	
		{type = "breakline"},
		--enemies
		
		{type = "label", get = function() return "Alpha Amount by Frame - Enemy" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		
		{
			type = "toggle",
			get = function() return Plater.db.profile.transparency_behavior_on_enemies end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.transparency_behavior_on_enemies = value
				Plater.UpdateAllPlates()
			end,
			name = "Enable for enemies",
			desc = "Apply alpha settings to enemy units.",
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
			name = "Overall",
			desc = "Overall frame alpha.",
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
			name = "Health Bar",
			desc = "Health Bar alpha multiplier.",
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
			name = "Cast Bar",
			desc = "Cast Bar alpha multiplier.",
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
			name = "Power Bar",
			desc = "Power Bar alpha multiplier.",
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
			name = "Buff Frames",
			desc = "Buff Frames alpha multiplier.",
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
			name = "In-Range/Target alpha",
			desc = "Frame alpha for targets or in-range units.",
			usedecimals = true,
		},
		
		{type = "break"},
		--friendlies
		
		{type = "label", get = function() return "Alpha Amount by Frame - Friendly" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		
		{
			type = "toggle",
			get = function() return Plater.db.profile.transparency_behavior_on_friendlies end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.transparency_behavior_on_friendlies = value
				Plater.UpdateAllPlates()
			end,
			name = "Enable for friendlies",
			desc = "Apply alpha settings to friendly units.",
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
			name = "Overall",
			desc = "Overall frame alpha.",
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
			name = "Health Bar",
			desc = "Health Bar alpha multiplier.",
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
			name = "Cast Bar",
			desc = "Cast Bar alpha multiplier.",
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
			name = "Power Bar",
			desc = "Power Bar alpha multiplier.",
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
			name = "Buff Frames",
			desc = "Buff Frames alpha multiplier.",
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
			name = "In-Range/Target alpha",
			desc = "Frame alpha for targets or in-range units.",
			usedecimals = true,
		},

		{type = "breakline"},

		{type = "label", get = function() return "Indicators:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		
		{
			type = "toggle",
			get = function() return Plater.db.profile.indicator_pet end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.indicator_pet = value
				Plater.UpdateAllPlates()
			end,
			name = "Pet Icon",
			desc = "Pet Icon",
		},

		{
			type = "toggle",
			get = function() return Plater.db.profile.indicator_shield end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.indicator_shield = value
				Plater.UpdateAllPlates()
			end,
			name = "Shield Bar",
			desc = "Shield Bar",
		},
		
		{
			type = "toggle",
			get = function() return Plater.db.profile.health_cutoff end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.health_cutoff = value
				Plater.GetHealthCutoffValue()
				Plater.UpdateAllPlates()
			end,
			name = "Execute Range",
			desc = "Show an indicator when the unit is in execute range.\n\nPlater auto detects execute range for:\n\n|cFFFFFF00Hunter|r\n\n|cFFFFFF00Warrior|r\n\n|cFFFFFF00Priest|r\n\n|cFFFFFF00Paladin|r\n\n|cFFFFFF00Monk|r\n\n|cFFFFFF00Mage|r: Fire spec with Searing Touch talent.\n\n|cFFFFFF00Warlock|r: Destruction spec with Shadowburn talent.\nAffliction with Drain Soul talent.\n\n|cFFFFFF00Rogue|r: Assassination spec with Blindside talent.",
		},
		
		{
			type = "toggle",
			get = function() return Plater.db.profile.health_cutoff_upper end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.health_cutoff_upper = value
				Plater.GetHealthCutoffValue()
				Plater.UpdateAllPlates()
			end,
			name = "Upper Execute Range",
			desc = "Show an indicator when the unit is in the upper execute range.\nPlater auto detects execute range for:\n\n|cFFFFFF00Hunter|r: Careful Aim talented.\n\n|cFFFFFF00Warrior|r: Condemn (Venthyr Covenant).\n\n|cFFFFFF00Mage|r: Fire spec with Firestarter talented.",
			hidden = IS_WOW_PROJECT_NOT_MAINLINE,
		},

		{
			type = "toggle",
			get = function() return Plater.db.profile.indicator_worldboss end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.indicator_worldboss = value
				Plater.UpdateAllPlates()
			end,
			name = "Worldboss Icon",
			desc = "Show when the actor is elite.",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.indicator_elite end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.indicator_elite = value
				Plater.UpdateAllPlates()
			end,
			name = "Elite Icon",
			desc = "Show when the actor is elite.",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.indicator_rare end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.indicator_rare = value
				Plater.UpdateAllPlates()
			end,
			name = "Rare Icon",
			desc = "Show when the actor is rare.",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.indicator_quest end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.indicator_quest = value
				Plater.UpdateAllPlates()
			end,
			name = "Quest Icon",
			desc = "Show when the actor is a boss for a quest.",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.indicator_faction end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.indicator_faction = value
				Plater.UpdateAllPlates()
			end,
			name = "Enemy Faction Icon",
			desc = "Show horde or alliance icon.",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.indicator_enemyclass end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.indicator_enemyclass = value
				Plater.UpdateAllPlates()
			end,
			name = "Enemy Class",
			desc = "Enemy player class icon.",
		},
		
		{
			type = "toggle",
			get = function() return Plater.db.profile.indicator_spec end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.indicator_spec = value
				Plater.UpdateAllPlates()
			end,
			name = "Enemy Spec",
			desc = "Enemy player spec icon.\n\n" .. ImportantText .. "must have Details! Damage Meter installed to work outside of BG/Arena.",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.indicator_friendlyfaction end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.indicator_friendlyfaction = value
				Plater.UpdateAllPlates()
			end,
			name = "Friendly Faction Icon",
			desc = "Show horde or alliance icon.",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.indicator_friendlyclass end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.indicator_friendlyclass = value
				Plater.UpdateAllPlates()
			end,
			name = "Friendly Class",
			desc = "Friendly player class icon.",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.indicator_friendlyspec end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.indicator_friendlyspec = value
				Plater.UpdateAllPlates()
			end,
			name = "Friendly Spec",
			desc = "Friendly player spec icon.\n\n" .. ImportantText .. "must have Details! Damage Meter installed to work outside of BG/Arena.",
		},
		{
			type = "range",
			get = function() return Plater.db.profile.indicator_scale end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.indicator_scale = value
				Plater.UpdateAllPlates()
			end,
			min = 0.2,
			max = 3,
			step = 0.01,
			usedecimals = true,
			name = "Scale",
			desc = "Scale",
		},

		--indicator icon anchor
		{
			type = "select",
			get = function() return Plater.db.profile.indicator_anchor.side end,
			values = function() return build_anchor_side_table (nil, "indicator_anchor") end,
			name = L["OPTIONS_ANCHOR"],
			desc = "Which side of the nameplate this widget is attach to.",
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
			name = L["OPTIONS_XOFFSET"],
			desc = "Slightly move horizontally.",
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
			name = L["OPTIONS_YOFFSET"],
			desc = "Slightly move vertically.",
		},
	}

	for _, t in ipairs (options_table1_continue2) do
		tinsert (options_table1, t)
	end
	
	DF:BuildMenu (generalOptionsAnchor, options_table1, 0, 0, mainHeightSize, true, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template, globalCallback)

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
			name = L["OPTIONS_YOFFSET"],
			desc = "Adjust the position on the Y axis." .. SliderRightClickDesc,
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
			name = L["OPTIONS_XOFFSET"],
			desc = "Adjust the position on the X axis." .. SliderRightClickDesc,
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
			name = L["OPTIONS_YOFFSET"],
			desc = "Adjust the position on the Y axis." .. SliderRightClickDesc,
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
			name = L["OPTIONS_COLOR"],
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
			name = "Width",
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
			name = "Height",
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
			name = "Width",
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
			name = "Height",
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
			name = "Width",
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
			name = "Height",
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
			name = "Width",
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
			name = "Height",
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
			name = L["OPTIONS_SIZE"],
			desc = "Size of the text.",
		},
		--player name font
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.actorname_text_font end,
			values = function() return DF:BuildDropDownFontList (on_select_friendly_playername_font) end,
			name = L["OPTIONS_FONT"],
			desc = "Font of the text.",
		},
		
		--text outline options
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.actorname_text_outline end,
			values = function() return build_outline_modes_table ("friendlyplayer", "actorname_text_outline") end,
			name = L["OPTIONS_OUTLINE"],
			desc = "Outline",
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
			name = L["OPTIONS_SHADOWCOLOR"],
			desc = ImportantText .. "hide and show nameplates to see changes.",
		},
		
		--npc name anchor
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.actorname_text_anchor.side end,
			values = function() return build_anchor_side_table ("friendlyplayer", "actorname_text_anchor") end,
			name = L["OPTIONS_ANCHOR"],
			desc = "Which side of the nameplate this widget is attach to.",
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
			name = L["OPTIONS_XOFFSET"],
			desc = "Adjust the position on the X axis." .. SliderRightClickDesc,
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
			name = L["OPTIONS_YOFFSET"],
			desc = "Adjust the position on the Y axis." .. SliderRightClickDesc,
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
			name = L["OPTIONS_SIZE"],
			desc = "Size of the text.",
		},
		--cast text font
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.spellname_text_font end,
			values = function() return DF:BuildDropDownFontList (on_select_friendly_playercastname_font) end,
			name = L["OPTIONS_FONT"],
			desc = "Font of the text.",
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
			name = L["OPTIONS_COLOR"],
			desc = "The color of the text.",
		},
		
		--text outline options
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.spellname_text_outline end,
			values = function() return build_outline_modes_table ("friendlyplayer", "spellname_text_outline") end,
			name = L["OPTIONS_OUTLINE"],
			desc = "Outline",
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
			name = L["OPTIONS_SHADOWCOLOR"],
			desc = ImportantText .. "hide and show nameplates to see changes.",
		},

		--spell name text anchor
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.spellname_text_anchor.side end,
			values = function() return build_anchor_side_table ("friendlyplayer", "spellname_text_anchor") end,
			name = L["OPTIONS_ANCHOR"],
			desc = "Which side of the nameplate this widget is attach to.",
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
			name = L["OPTIONS_XOFFSET"],
			desc = "Adjust the position on the X axis." .. SliderRightClickDesc,
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
			name = L["OPTIONS_YOFFSET"],
			desc = "Adjust the position on the Y axis." .. SliderRightClickDesc,
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
			name = L["OPTIONS_ENABLED"],
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
			name = L["OPTIONS_SIZE"],
			desc = "Size of the text.",
		},
		--cast time text font
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.spellpercent_text_font end,
			values = function() return DF:BuildDropDownFontList (on_select_friendlyplayer_spellpercent_text_font) end,
			name = L["OPTIONS_FONT"],
			desc = "Font of the text.",
		},
		
		--text outline options
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.spellpercent_text_outline end,
			values = function() return build_outline_modes_table ("friendlyplayer", "spellpercent_text_outline") end,
			name = L["OPTIONS_OUTLINE"],
			desc = "Outline",
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
			name = L["OPTIONS_SHADOWCOLOR"],
			desc = ImportantText .. "hide and show nameplates to see changes.",
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
			name = L["OPTIONS_COLOR"],
			desc = "The color of the text.",
		},
		
		--cast time anchor
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.spellpercent_text_anchor.side end,
			values = function() return build_anchor_side_table ("friendlyplayer", "spellpercent_text_anchor") end,
			name = L["OPTIONS_ANCHOR"],
			desc = "Which side of the nameplate this widget is attach to.",
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
			name = L["OPTIONS_XOFFSET"],
			desc = "Adjust the position on the X axis." .. SliderRightClickDesc,
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
			name = L["OPTIONS_YOFFSET"],
			desc = "Adjust the position on the Y axis." .. SliderRightClickDesc,
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
			name = L["OPTIONS_ENABLED"],
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
			name = L["OPTIONS_SIZE"],
			desc = "Size of the text.",
		},
		--percent text font
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.percent_text_font end,
			values = function() return DF:BuildDropDownFontList (on_select_friendlyplayer_percent_text_font) end,
			name = L["OPTIONS_FONT"],
			desc = "Font of the text.",
		},

		--text outline options
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.percent_text_outline end,
			values = function() return build_outline_modes_table ("friendlyplayer", "percent_text_outline") end,
			name = L["OPTIONS_OUTLINE"],
			desc = "Outline",
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
			name = L["OPTIONS_SHADOWCOLOR"],
			desc = ImportantText .. "hide and show nameplates to see changes.",
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
			name = L["OPTIONS_COLOR"],
			desc = "The color of the text.",
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
			name = L["OPTIONS_ALPHA"],
			desc = "Set the transparency of the text.",
			usedecimals = true,
		},
		--percent anchor
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.percent_text_anchor.side end,
			values = function() return build_anchor_side_table ("friendlyplayer", "percent_text_anchor") end,
			name = L["OPTIONS_ANCHOR"],
			desc = "Which side of the nameplate this widget is attach to.",
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
			name = L["OPTIONS_XOFFSET"],
			desc = "Adjust the position on the X axis." .. SliderRightClickDesc,
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
			name = L["OPTIONS_YOFFSET"],
			desc = "Adjust the position on the Y axis." .. SliderRightClickDesc,
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
			name = L["OPTIONS_ENABLED"],
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
			name = L["OPTIONS_SIZE"],
			desc = "Size of the text.",
		},
		--level text font
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.level_text_font end,
			values = function() return DF:BuildDropDownFontList (on_select_friendlyplayer_level_text_font) end,
			name = L["OPTIONS_FONT"],
			desc = "Font of the text.",
		},
		
		--text outline options
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.level_text_outline end,
			values = function() return build_outline_modes_table ("friendlyplayer", "level_text_outline") end,
			name = L["OPTIONS_OUTLINE"],
			desc = "Outline",
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
			name = L["OPTIONS_SHADOWCOLOR"],
			desc = ImportantText .. "hide and show nameplates to see changes.",
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
			name = L["OPTIONS_ALPHA"],
			desc = "Set the transparency of the text.",
			usedecimals = true,
		},
		--level anchor
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlyplayer.level_text_anchor.side end,
			values = function() return build_anchor_side_table ("friendlyplayer", "level_text_anchor") end,
			name = L["OPTIONS_ANCHOR"],
			desc = "Which side of the nameplate this widget is attach to.",
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
			name = L["OPTIONS_XOFFSET"],
			desc = "Adjust the position on the X axis." .. SliderRightClickDesc,
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
			name = L["OPTIONS_YOFFSET"],
			desc = "Adjust the position on the Y axis." .. SliderRightClickDesc,
		},
		
		

	}

	_G.C_Timer.After(1.420, function() --~delay
		DF:BuildMenu (friendlyPCsFrame, options_table3, startX, startY, heightSize, true, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template, globalCallback)
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
			name = L["OPTIONS_YOFFSET"],
			desc = "Adjust the position on the Y axis." .. SliderRightClickDesc,
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
			name = L["OPTIONS_XOFFSET"],
			desc = "Adjust the position on the X axis." .. SliderRightClickDesc,
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
			name = L["OPTIONS_YOFFSET"],
			desc = "Adjust the position on the Y axis." .. SliderRightClickDesc,
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
			name = L["OPTIONS_COLOR"],
			desc = "The color of the text.",
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
			name = "Width",
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
			name = "Height",
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
			name = "Width",
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
			name = "Height",
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
			name = "Width",
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
			name = "Height",
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
			name = "Width",
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
			name = "Height",
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
			name = L["OPTIONS_SIZE"],
			desc = "Size of the text.",
		},
		--player name font
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.enemyplayer.actorname_text_font end,
			values = function() return DF:BuildDropDownFontList (on_select_enemy_playername_font) end,
			name = L["OPTIONS_FONT"],
			desc = "Font of the text.",
		},
		
		--text outline options
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.enemyplayer.actorname_text_outline end,
			values = function() return build_outline_modes_table ("enemyplayer", "actorname_text_outline") end,
			name = L["OPTIONS_OUTLINE"],
			desc = "Outline",
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
			name = L["OPTIONS_SHADOWCOLOR"],
			desc = ImportantText .. "hide and show nameplates to see changes.",
		},		
		
		--npc name anchor
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.enemyplayer.actorname_text_anchor.side end,
			values = function() return build_anchor_side_table ("enemyplayer", "actorname_text_anchor") end,
			name = L["OPTIONS_ANCHOR"],
			desc = "Which side of the nameplate this widget is attach to.",
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
			name = L["OPTIONS_XOFFSET"],
			desc = "Adjust the position on the X axis." .. SliderRightClickDesc,
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
			name = L["OPTIONS_YOFFSET"],
			desc = "Adjust the position on the Y axis." .. SliderRightClickDesc,
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
			name = L["OPTIONS_SIZE"],
			desc = "Size of the text.",
		},
		--cast text font
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.enemyplayer.spellname_text_font end,
			values = function() return DF:BuildDropDownFontList (on_select_enemy_playercastname_font) end,
			name = L["OPTIONS_FONT"],
			desc = "Font of the text.",
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
			name = L["OPTIONS_COLOR"],
			desc = "The color of the text.",
		},

		--text outline options
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.enemyplayer.spellname_text_outline end,
			values = function() return build_outline_modes_table ("enemyplayer", "spellname_text_outline") end,
			name = L["OPTIONS_OUTLINE"],
			desc = "Outline",
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
			name = L["OPTIONS_SHADOWCOLOR"],
			desc = ImportantText .. "hide and show nameplates to see changes.",
		},
		
		--spell name text anchor
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.enemyplayer.spellname_text_anchor.side end,
			values = function() return build_anchor_side_table ("enemyplayer", "spellname_text_anchor") end,
			name = L["OPTIONS_ANCHOR"],
			desc = "Which side of the nameplate this widget is attach to.",
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
			name = L["OPTIONS_XOFFSET"],
			desc = "Adjust the position on the X axis." .. SliderRightClickDesc,
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
			name = L["OPTIONS_YOFFSET"],
			desc = "Adjust the position on the Y axis." .. SliderRightClickDesc,
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
			name = L["OPTIONS_ENABLED"],
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
			name = L["OPTIONS_SIZE"],
			desc = "Size of the text.",
		},
		--cast time text font
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.enemyplayer.spellpercent_text_font end,
			values = function() return DF:BuildDropDownFontList (on_select_enemyplayer_spellpercent_text_font) end,
			name = L["OPTIONS_FONT"],
			desc = "Font of the text.",
		},
		
		--text outline options
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.enemyplayer.spellpercent_text_outline end,
			values = function() return build_outline_modes_table ("enemyplayer", "spellpercent_text_outline") end,
			name = L["OPTIONS_OUTLINE"],
			desc = "Outline",
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
			name = L["OPTIONS_SHADOWCOLOR"],
			desc = ImportantText .. "hide and show nameplates to see changes.",
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
			name = L["OPTIONS_COLOR"],
			desc = "The color of the text.",
		},
		
		--cast time anchor
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.enemyplayer.spellpercent_text_anchor.side end,
			values = function() return build_anchor_side_table ("enemyplayer", "spellpercent_text_anchor") end,
			name = L["OPTIONS_ANCHOR"],
			desc = "Which side of the nameplate this widget is attach to.",
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
			name = L["OPTIONS_XOFFSET"],
			desc = "Adjust the position on the X axis." .. SliderRightClickDesc,
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
			name = L["OPTIONS_YOFFSET"],
			desc = "Adjust the position on the Y axis." .. SliderRightClickDesc,
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
			name = L["OPTIONS_ENABLED"],
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
			name = L["OPTIONS_SIZE"],
			desc = "Size of the text.",
		},
		--percent text font
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.enemyplayer.percent_text_font end,
			values = function() return DF:BuildDropDownFontList (on_select_enemyplayer_percent_text_font) end,
			name = L["OPTIONS_FONT"],
			desc = "Font of the text.",
		},
		
		--text outline options
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.enemyplayer.percent_text_outline end,
			values = function() return build_outline_modes_table ("enemyplayer", "percent_text_outline") end,
			name = L["OPTIONS_OUTLINE"],
			desc = "Outline",
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
			name = L["OPTIONS_SHADOWCOLOR"],
			desc = ImportantText .. "hide and show nameplates to see changes.",
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
			name = L["OPTIONS_COLOR"],
			desc = "The color of the text.",
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
			name = L["OPTIONS_ALPHA"],
			desc = "Set the transparency of the text.",
			usedecimals = true,
		},
		--percent anchor
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.enemyplayer.percent_text_anchor.side end,
			values = function() return build_anchor_side_table ("enemyplayer", "percent_text_anchor") end,
			name = L["OPTIONS_ANCHOR"],
			desc = "Which side of the nameplate this widget is attach to.",
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
			name = L["OPTIONS_XOFFSET"],
			desc = "Adjust the position on the X axis." .. SliderRightClickDesc,
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
			name = L["OPTIONS_YOFFSET"],
			desc = "Adjust the position on the Y axis." .. SliderRightClickDesc,
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
			name = L["OPTIONS_ENABLED"],
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
			name = L["OPTIONS_SIZE"],
			desc = "Size of the text.",
		},
		--level text font
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.enemyplayer.level_text_font end,
			values = function() return DF:BuildDropDownFontList (on_select_enemyplayer_level_text_font) end,
			name = L["OPTIONS_FONT"],
			desc = "Font of the text.",
		},
		
		--text outline options
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.enemyplayer.level_text_outline end,
			values = function() return build_outline_modes_table ("enemyplayer", "level_text_outline") end,
			name = L["OPTIONS_OUTLINE"],
			desc = "Outline",
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
			name = L["OPTIONS_SHADOWCOLOR"],
			desc = ImportantText .. "hide and show nameplates to see changes.",
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
			name = L["OPTIONS_ALPHA"],
			desc = "Set the transparency of the text.",
			usedecimals = true,
		},
		--level anchor
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.enemyplayer.level_text_anchor.side end,
			values = function() return build_anchor_side_table ("enemyplayer", "level_text_anchor") end,
			name = L["OPTIONS_ANCHOR"],
			desc = "Which side of the nameplate this widget is attach to.",
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
			name = L["OPTIONS_XOFFSET"],
			desc = "Adjust the position on the X axis." .. SliderRightClickDesc,
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
			name = L["OPTIONS_YOFFSET"],
			desc = "Adjust the position on the Y axis." .. SliderRightClickDesc,
		},		

	}

	_G.C_Timer.After(0.720, function() --~delay
		DF:BuildMenu (enemyPCsFrame, options_table4, startX, startY, heightSize, true, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template, globalCallback)
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
			name = L["OPTIONS_YOFFSET"],
			desc = "Adjust the position on the Y axis." .. SliderRightClickDesc,
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
			name = L["OPTIONS_XOFFSET"],
			desc = "Adjust the position on the X axis." .. SliderRightClickDesc,
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
			name = L["OPTIONS_YOFFSET"],
			desc = "Adjust the position on the Y axis." .. SliderRightClickDesc,
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
			name = "Width",
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
			name = "Height",
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
			name = "Width",
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
			name = "Height",
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
			name = "Width",
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
			name = "Height",
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
			name = "Width",
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
			name = "Height",
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
			name = L["OPTIONS_SIZE"],
			desc = "Size of the text.",
		},
		--player name font
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlynpc.actorname_text_font end,
			values = function() return DF:BuildDropDownFontList (on_select_friendly_npcname_font) end,
			name = L["OPTIONS_FONT"],
			desc = "Font of the text.",
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
			name = L["OPTIONS_COLOR"],
			desc = "The color of the text.",
		},
		
		--text outline options
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlynpc.actorname_text_outline end,
			values = function() return build_outline_modes_table ("friendlynpc", "actorname_text_outline") end,
			name = L["OPTIONS_OUTLINE"],
			desc = "Outline",
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
			name = L["OPTIONS_SHADOWCOLOR"],
			desc = ImportantText .. "hide and show nameplates to see changes.",
		},
		
		--npc name anchor
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlynpc.actorname_text_anchor.side end,
			values = function() return build_anchor_side_table ("friendlynpc", "actorname_text_anchor") end,
			name = L["OPTIONS_ANCHOR"],
			desc = "Which side of the nameplate this widget is attach to.",
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
			name = L["OPTIONS_XOFFSET"],
			desc = "Adjust the position on the X axis." .. SliderRightClickDesc,
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
			name = L["OPTIONS_YOFFSET"],
			desc = "Adjust the position on the Y axis." .. SliderRightClickDesc,
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
			name = L["OPTIONS_SIZE"],
			desc = "Size of the text.",
		},
		--cast text font
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlynpc.spellname_text_font end,
			values = function() return DF:BuildDropDownFontList (on_select_friendly_npccastname_font) end,
			name = L["OPTIONS_FONT"],
			desc = "Font of the text.",
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
			name = L["OPTIONS_COLOR"],
			desc = "The color of the text.",
		},
		
		--text outline options
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlynpc.spellname_text_outline end,
			values = function() return build_outline_modes_table ("friendlynpc", "spellname_text_outline") end,
			name = L["OPTIONS_OUTLINE"],
			desc = "Outline",
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
			name = L["OPTIONS_SHADOWCOLOR"],
			desc = ImportantText .. "hide and show nameplates to see changes.",
		},
	
		--spell name text anchor
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlynpc.spellname_text_anchor.side end,
			values = function() return build_anchor_side_table ("friendlynpc", "spellname_text_anchor") end,
			name = L["OPTIONS_ANCHOR"],
			desc = "Which side of the nameplate this widget is attach to.",
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
			name = L["OPTIONS_XOFFSET"],
			desc = "Adjust the position on the X axis." .. SliderRightClickDesc,
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
			name = L["OPTIONS_YOFFSET"],
			desc = "Adjust the position on the Y axis." .. SliderRightClickDesc,
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
			name = L["OPTIONS_ENABLED"],
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
			name = L["OPTIONS_SIZE"],
			desc = "Size of the text.",
		},
		--cast time text font
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlynpc.spellpercent_text_font end,
			values = function() return DF:BuildDropDownFontList (on_select_friendlynpc_spellpercent_text_font) end,
			name = L["OPTIONS_FONT"],
			desc = "Font of the text.",
		},
		
		--text outline options
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlynpc.spellpercent_text_outline end,
			values = function() return build_outline_modes_table ("friendlynpc", "spellpercent_text_outline") end,
			name = L["OPTIONS_OUTLINE"],
			desc = "Outline",
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
			name = L["OPTIONS_SHADOWCOLOR"],
			desc = ImportantText .. "hide and show nameplates to see changes.",
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
			name = L["OPTIONS_COLOR"],
			desc = "The color of the text.",
		},
		--cast time anchor
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlynpc.spellpercent_text_anchor.side end,
			values = function() return build_anchor_side_table ("friendlynpc", "spellpercent_text_anchor") end,
			name = L["OPTIONS_ANCHOR"],
			desc = "Which side of the nameplate this widget is attach to.",
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
			name = L["OPTIONS_XOFFSET"],
			desc = "Adjust the position on the X axis." .. SliderRightClickDesc,
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
			name = L["OPTIONS_YOFFSET"],
			desc = "Adjust the position on the Y axis." .. SliderRightClickDesc,
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
			name = L["OPTIONS_ENABLED"],
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
			name = L["OPTIONS_SIZE"],
			desc = "Size of the text.",
		},
		--percent text font
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlynpc.percent_text_font end,
			values = function() return DF:BuildDropDownFontList (on_select_friendlynpc_percent_text_font) end,
			name = L["OPTIONS_FONT"],
			desc = "Font of the text.",
		},
		
		--text outline options
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlynpc.percent_text_outline end,
			values = function() return build_outline_modes_table ("friendlynpc", "percent_text_outline") end,
			name = L["OPTIONS_OUTLINE"],
			desc = "Outline",
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
			name = L["OPTIONS_SHADOWCOLOR"],
			desc = ImportantText .. "hide and show nameplates to see changes.",
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
			name = L["OPTIONS_COLOR"],
			desc = "The color of the text.",
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
			name = L["OPTIONS_ALPHA"],
			desc = "Set the transparency of the text.",
			usedecimals = true,
		},
		--percent anchor
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlynpc.percent_text_anchor.side end,
			values = function() return build_anchor_side_table ("friendlynpc", "percent_text_anchor") end,
			name = L["OPTIONS_ANCHOR"],
			desc = "Which side of the nameplate this widget is attach to.",
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
			name = L["OPTIONS_XOFFSET"],
			desc = "Adjust the position on the X axis." .. SliderRightClickDesc,
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
			name = L["OPTIONS_YOFFSET"],
			desc = "Adjust the position on the Y axis." .. SliderRightClickDesc,
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
			name = L["OPTIONS_SIZE"],
			desc = "Size of the text.",
		},
		--text font
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlynpc.big_actorname_text_font end,
			values = function() return DF:BuildDropDownFontList (on_select_friendlynpc_bignametext_text_font) end,
			name = L["OPTIONS_FONT"],
			desc = "Font of the text.",
		},
		
		--text outline options
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlynpc.big_actorname_text_outline end,
			values = function() return build_outline_modes_table ("friendlynpc", "big_actorname_text_outline") end,
			name = L["OPTIONS_OUTLINE"],
			desc = "Outline",
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
			name = L["OPTIONS_SHADOWCOLOR"],
			desc = ImportantText .. "hide and show nameplates to see changes.",
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
			name = L["OPTIONS_COLOR"],
			desc = "The color of the text.",
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
			name = L["OPTIONS_ENABLED"],
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
			name = L["OPTIONS_SIZE"],
			desc = "Size of the text.",
		},
		--level text font
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlynpc.level_text_font end,
			values = function() return DF:BuildDropDownFontList (on_select_friendlynpc_level_text_font) end,
			name = L["OPTIONS_FONT"],
			desc = "Font of the text.",
		},

		--text outline options
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlynpc.level_text_outline end,
			values = function() return build_outline_modes_table ("friendlynpc", "level_text_outline") end,
			name = L["OPTIONS_OUTLINE"],
			desc = "Outline",
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
			name = L["OPTIONS_SHADOWCOLOR"],
			desc = ImportantText .. "hide and show nameplates to see changes.",
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
			name = L["OPTIONS_ALPHA"],
			desc = "Set the transparency of the text.",
			usedecimals = true,
		},
		--level anchor
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlynpc.level_text_anchor.side end,
			values = function() return build_anchor_side_table ("friendlynpc", "level_text_anchor") end,
			name = L["OPTIONS_ANCHOR"],
			desc = "Which side of the nameplate this widget is attach to.",
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
			name = L["OPTIONS_XOFFSET"],
			desc = "Adjust the position on the X axis." .. SliderRightClickDesc,
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
			name = L["OPTIONS_YOFFSET"],
			desc = "Adjust the position on the Y axis." .. SliderRightClickDesc,
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
			name = L["OPTIONS_SIZE"],
			desc = "Size of the text.",
		},
		--profession text font
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlynpc.big_actortitle_text_font end,
			values = function() return DF:BuildDropDownFontList (on_select_friendlynpc_bigtitletext_text_font) end,
			name = L["OPTIONS_FONT"],
			desc = "Font of the text.",
		},
		
		--profession text outline options
		{
			type = "select",
			get = function() return Plater.db.profile.plate_config.friendlynpc.big_actortitle_text_outline end,
			values = function() return build_outline_modes_table ("friendlynpc", "big_actortitle_text_outline") end,
			name = L["OPTIONS_OUTLINE"],
			desc = "Outline",
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
			name = L["OPTIONS_SHADOWCOLOR"],
			desc = ImportantText .. "hide and show nameplates to see changes.",
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
		DF:BuildMenu (friendlyNPCsFrame, friendly_npc_options_table, startX, startY, heightSize, true, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template, globalCallback)
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
				name = L["OPTIONS_YOFFSET"],
				desc = "Adjust the position on the Y axis." .. SliderRightClickDesc,
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
				name = L["OPTIONS_XOFFSET"],
				desc = "Adjust the position on the X axis." .. SliderRightClickDesc,
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
				name = L["OPTIONS_YOFFSET"],
				desc = "Adjust the position on the Y axis." .. SliderRightClickDesc,
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
				name = L["OPTIONS_SIZE"],
				desc = "Size of the text.",
			},
			--profession text font
			{
				type = "select",
				get = function() return Plater.db.profile.plate_config.enemynpc.big_actorname_text_font end,
				values = function() return DF:BuildDropDownFontList (on_select_enemynpc_bignametext_text_font) end,
				name = L["OPTIONS_FONT"],
				desc = "Font of the text.",
			},
			
			--text outline options
			{
				type = "select",
				get = function() return Plater.db.profile.plate_config.enemynpc.big_actorname_text_outline end,
				values = function() return build_outline_modes_table ("enemynpc", "big_actorname_text_outline") end,
				name = L["OPTIONS_OUTLINE"],
				desc = "Outline",
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
				name = L["OPTIONS_SHADOWCOLOR"],
				desc = ImportantText .. "hide and show nameplates to see changes.",
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
				name = L["OPTIONS_COLOR"],
				desc = "The color of the text.",
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
				name = L["OPTIONS_SIZE"],
				desc = "Size of the text.",
			},
			--profession text font
			{
				type = "select",
				get = function() return Plater.db.profile.plate_config.enemynpc.big_actortitle_text_font end,
				values = function() return DF:BuildDropDownFontList (on_select_enemynpc_bigtitletext_text_font) end,
				name = L["OPTIONS_FONT"],
				desc = "Font of the text.",
			},
			
			--profession text outline options
			{
				type = "select",
				get = function() return Plater.db.profile.plate_config.enemynpc.big_actortitle_text_outline end,
				values = function() return build_outline_modes_table ("enemynpc", "big_actortitle_text_outline") end,
				name = L["OPTIONS_OUTLINE"],
				desc = "Outline",
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
				name = L["OPTIONS_SHADOWCOLOR"],
				desc = ImportantText .. "hide and show nameplates to see changes.",
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
				name = "Width",
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
				name = "Height",
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
				name = "Width",
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
				name = "Height",
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
				name = "Width",
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
				name = "Height",
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
				name = "Width",
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
				name = "Height",
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
				name = L["OPTIONS_SIZE"],
				desc = "Size of the text.",
			},
			--player name font
			{
				type = "select",
				get = function() return Plater.db.profile.plate_config.enemynpc.actorname_text_font end,
				values = function() return DF:BuildDropDownFontList (on_select_enemy_npcname_font) end,
				name = L["OPTIONS_FONT"],
				desc = "Font of the text.",
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
				name = L["OPTIONS_COLOR"],
				desc = "The color of the text.",
			},
			
			--text outline options
			{
				type = "select",
				get = function() return Plater.db.profile.plate_config.enemynpc.actorname_text_outline end,
				values = function() return build_outline_modes_table ("enemynpc", "actorname_text_outline") end,
				name = L["OPTIONS_OUTLINE"],
				desc = "Outline",
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
				name = L["OPTIONS_SHADOWCOLOR"],
				desc = ImportantText .. "hide and show nameplates to see changes.",
			},
			
			--npc name anchor
			{
				type = "select",
				get = function() return Plater.db.profile.plate_config.enemynpc.actorname_text_anchor.side end,
				values = function() return build_anchor_side_table ("enemynpc", "actorname_text_anchor") end,
				name = L["OPTIONS_ANCHOR"],
				desc = "Which side of the nameplate this widget is attach to.",
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
				name = L["OPTIONS_XOFFSET"],
				desc = "Adjust the position on the X axis." .. SliderRightClickDesc,
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
				name = L["OPTIONS_YOFFSET"],
				desc = "Adjust the position on the Y axis." .. SliderRightClickDesc,
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
				name = L["OPTIONS_SIZE"],
				desc = "Size of the text.",
			},
			--cast text font
			{
				type = "select",
				get = function() return Plater.db.profile.plate_config.enemynpc.spellname_text_font end,
				values = function() return DF:BuildDropDownFontList (on_select_enemy_npccastname_font) end,
				name = L["OPTIONS_FONT"],
				desc = "Font of the text.",
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
				name = L["OPTIONS_COLOR"],
				desc = "The color of the text.",
			},

			--text outline options
			{
				type = "select",
				get = function() return Plater.db.profile.plate_config.enemynpc.spellname_text_outline end,
				values = function() return build_outline_modes_table ("enemynpc", "spellname_text_outline") end,
				name = L["OPTIONS_OUTLINE"],
				desc = "Outline",
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
				name = L["OPTIONS_SHADOWCOLOR"],
				desc = ImportantText .. "hide and show nameplates to see changes.",
			},
			
			--spell name text anchor
			{
				type = "select",
				get = function() return Plater.db.profile.plate_config.enemynpc.spellname_text_anchor.side end,
				values = function() return build_anchor_side_table ("enemynpc", "spellname_text_anchor") end,
				name = L["OPTIONS_ANCHOR"],
				desc = "Which side of the nameplate this widget is attach to.",
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
				name = L["OPTIONS_XOFFSET"],
				desc = "Adjust the position on the X axis." .. SliderRightClickDesc,
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
				name = L["OPTIONS_YOFFSET"],
				desc = "Adjust the position on the Y axis." .. SliderRightClickDesc,
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
				name = L["OPTIONS_ENABLED"],
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
				name = L["OPTIONS_SIZE"],
				desc = "Size of the text.",
			},
			--cast time text font
			{
				type = "select",
				get = function() return Plater.db.profile.plate_config.enemynpc.spellpercent_text_font end,
				values = function() return DF:BuildDropDownFontList (on_select_enemy_spellpercent_text_font) end,
				name = L["OPTIONS_FONT"],
				desc = "Font of the text.",
			},
			
			--text outline options
			{
				type = "select",
				get = function() return Plater.db.profile.plate_config.enemynpc.spellpercent_text_outline end,
				values = function() return build_outline_modes_table ("enemynpc", "spellpercent_text_outline") end,
				name = L["OPTIONS_OUTLINE"],
				desc = "Outline",
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
				name = L["OPTIONS_SHADOWCOLOR"],
				desc = ImportantText .. "hide and show nameplates to see changes.",
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
				name = L["OPTIONS_COLOR"],
				desc = "The color of the text.",
			},
			
			--cast time anchor
			{
				type = "select",
				get = function() return Plater.db.profile.plate_config.enemynpc.spellpercent_text_anchor.side end,
				values = function() return build_anchor_side_table ("enemynpc", "spellpercent_text_anchor") end,
				name = L["OPTIONS_ANCHOR"],
				desc = "Which side of the nameplate this widget is attach to.",
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
				name = L["OPTIONS_XOFFSET"],
				desc = "Adjust the position on the X axis." .. SliderRightClickDesc,
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
				name = L["OPTIONS_YOFFSET"],
				desc = "Adjust the position on the Y axis." .. SliderRightClickDesc,
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
				name = L["OPTIONS_ENABLED"],
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
				name = L["OPTIONS_SIZE"],
				desc = "Size of the text.",
			},
			--percent text font
			{
				type = "select",
				get = function() return Plater.db.profile.plate_config.enemynpc.percent_text_font end,
				values = function() return DF:BuildDropDownFontList (on_select_enemy_percent_text_font) end,
				name = L["OPTIONS_FONT"],
				desc = "Font of the text.",
			},
			
			--text outline options
			{
				type = "select",
				get = function() return Plater.db.profile.plate_config.enemynpc.percent_text_outline end,
				values = function() return build_outline_modes_table ("enemynpc", "percent_text_outline") end,
				name = L["OPTIONS_OUTLINE"],
				desc = "Outline",
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
				name = L["OPTIONS_SHADOWCOLOR"],
				desc = ImportantText .. "hide and show nameplates to see changes.",
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
				name = L["OPTIONS_COLOR"],
				desc = "The color of the text.",
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
				name = L["OPTIONS_ALPHA"],
				desc = "Set the transparency of the text.",
				usedecimals = true,
			},
			--percent anchor
			{
				type = "select",
				get = function() return Plater.db.profile.plate_config.enemynpc.percent_text_anchor.side end,
				values = function() return build_anchor_side_table ("enemynpc", "percent_text_anchor") end,
				name = L["OPTIONS_ANCHOR"],
				desc = "Which side of the nameplate this widget is attach to.",
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
				name = L["OPTIONS_XOFFSET"],
				desc = "Adjust the position on the X axis." .. SliderRightClickDesc,
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
				name = L["OPTIONS_YOFFSET"],
				desc = "Adjust the position on the Y axis." .. SliderRightClickDesc,
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
				name = L["OPTIONS_ENABLED"],
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
				name = L["OPTIONS_SIZE"],
				desc = "Size of the text.",
			},
			--level text font
			{
				type = "select",
				get = function() return Plater.db.profile.plate_config.enemynpc.level_text_font end,
				values = function() return DF:BuildDropDownFontList (on_select_enemy_level_text_font) end,
				name = L["OPTIONS_FONT"],
				desc = "Font of the text.",
			},
			
			--text outline options
			{
				type = "select",
				get = function() return Plater.db.profile.plate_config.enemynpc.level_text_outline end,
				values = function() return build_outline_modes_table ("enemynpc", "level_text_outline") end,
				name = L["OPTIONS_OUTLINE"],
				desc = "Outline",
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
				name = L["OPTIONS_SHADOWCOLOR"],
				desc = ImportantText .. "hide and show nameplates to see changes.",
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
				name = L["OPTIONS_ALPHA"],
				desc = "Set the transparency of the text.",
				usedecimals = true,
			},
			--level anchor
			{
				type = "select",
				get = function() return Plater.db.profile.plate_config.enemynpc.level_text_anchor.side end,
				values = function() return build_anchor_side_table ("enemynpc", "level_text_anchor") end,
				name = L["OPTIONS_ANCHOR"],
				desc = "Which side of the nameplate this widget is attach to.",
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
				name = L["OPTIONS_XOFFSET"],
				desc = "Adjust the position on the X axis." .. SliderRightClickDesc,
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
				name = L["OPTIONS_YOFFSET"],
				desc = "Adjust the position on the Y axis." .. SliderRightClickDesc,
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
			DF:BuildMenu (enemyNPCsFrame, options_table2, startX, startY, heightSize, true, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template, globalCallback)
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
	uiParentFeatureFrame.disabledOverlayFrame:SetPoint ("topleft", uiParentFeatureFrame, "topleft", 1, -155)
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
		DF:BuildMenu (uiParentFeatureFrame, experimental_options, startX, startY, heightSize, true, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template, globalCallback)	
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
			name = L["OPTIONS_ENABLED"],
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
			name = L["OPTIONS_ENABLED"],
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
		DF:BuildMenu (autoFrame, auto_options, startX, startY, heightSize, true, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template, globalCallback)	
	end)
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> castbar options

	local onSelectCastBarIconSideAttach = function(_a, _b, value)
		Plater.db.profile.castbar_icon_attach_to_side = value
		Plater.RefreshDBUpvalues()
		Plater.UpdateAllPlates()
	end
	local castbar_icon_attach_to_side_options = {
		{value = "left", label = "Left", onclick = onSelectCastBarIconSideAttach},
		{value = "right", label = "Right", onclick = onSelectCastBarIconSideAttach},
	}

	local onSelectCastBarSize = function(_, _, value)
		Plater.db.profile.castbar_icon_size = value
		Plater.RefreshDBUpvalues()
		Plater.UpdateAllPlates()
	end
	local castbar_icon_size_options = {
		{value = "same as castbar", label = "Castbar Size", onclick = onSelectCastBarSize},
		{value = "same as castbar plus healthbar", label = "Castbar + Healthbar Size", onclick = onSelectCastBarSize},
	}

	local castBar_options = {
		--cast bar options
		{type = "breakline"},
		{type = "label", get = function() return "Cast Bar Appearance:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		
		{
			type = "select",
			get = function() return Plater.db.profile.cast_statusbar_texture end,
			values = function() return cast_bar_texture_options end,
			name = "Cast Bar Texture",
			desc = "Texture used on the cast bar",
		},
		{
			type = "select",
			get = function() return Plater.db.profile.cast_statusbar_bgtexture end,
			values = function() return cast_bar_bgtexture_options end,
			name = "Cast Bar Background Texture",
			desc = "Texture used on the cast bar background.",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.no_spellname_length_limit end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.no_spellname_length_limit = value
				Plater.UpdateMaxCastbarTextLength()
				Plater.UpdateAllPlates()
			end,
			name = "No Spell Name Length Limitation",
			desc = "Spell name text won't be cut to fit within the cast bar width.",
		},

		{
			type = "toggle",
			get = function() return Plater.db.profile.show_interrupt_author end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.show_interrupt_author = value
				Plater.RefreshDBUpvalues()
			end,
			name = "Show Interrupt Author",
			desc = "Show Interrupt Author",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.hide_friendly_castbars end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.hide_friendly_castbars = value
				Plater.RefreshDBUpvalues()
			end,
			name = "Hide Friendly Cast Bar",
			desc = "Hide Friendly Cast Bar",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.hide_enemy_castbars end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.hide_enemy_castbars = value
				Plater.RefreshDBUpvalues()
			end,
			name = "Hide Enemy Cast Bar",
			desc = "Hide Enemy Cast Bar",
		},

		{type = "blank"},
		
		{
			type = "execute",
			func = function() 
				if (Plater.IsShowingCastBarTest) then
					Plater.StopCastBarTest()
					Plater:Msg ("Test loop for cast bar stopped.")
				else
					Plater.StartCastBarTest()
				end
			end,
			desc = "Start cast bar test, press again to stop.",
			name = "Toggle Cast Bar Test",
		},
		
		{type = "blank"},
		
		{
			type = "select",
			get = function() return Plater.db.profile.cast_statusbar_spark_texture end,
			values = function() return cast_spark_texture_selected_options end,
			name = "Spark Texture",
			desc = "Spark Texture",
		},
		{
			type = "range",
			get = function() return Plater.db.profile.cast_statusbar_spark_width end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.cast_statusbar_spark_width = value
				Plater.UpdateAllPlates()
			end,
			min = 4,
			max = 32,
			step = 1,
			name = "Spark Width",
			desc = "Spark Width",
		},
		{
			type = "range",
			get = function() return Plater.db.profile.cast_statusbar_spark_offset end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.cast_statusbar_spark_offset = value
				Plater.UpdateAllPlates()
			end,
			min = -32,
			max = 32,
			step = 1,
			name = "Spark Offset",
			desc = "Spark Offset",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.cast_statusbar_spark_half end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.cast_statusbar_spark_half = value
				Plater.UpdateAllPlates()
			end,
			name = "Spark Half",
			desc = "Show only half of the spark texture.",
		},
		{
			type = "range",
			get = function() return Plater.db.profile.cast_statusbar_spark_alpha end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.cast_statusbar_spark_alpha = value
				Plater.UpdateAllPlates()
			end,
			min = 0,
			max = 1,
			step = 0.1,
			usedecimals = true,
			name = "Spark Alpha",
			desc = "Spark Alpha",
		},
		
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.cast_statusbar_spark_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.cast_statusbar_spark_color
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllPlates()
			end,
			name = "Spark Color",
			desc = "Spark Color",
		},
		
		{type = "blank"},
		{
			type = "toggle",
			get = function() return Plater.db.profile.cast_statusbar_use_fade_effects end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.cast_statusbar_use_fade_effects = value
				Plater.UpdateAllPlates()
			end,
			name = "Use Fade Animations",
			desc = "Show a fade in and fade out animations when the cast starts and end.",
		},
		
		{
			type = "range",
			get = function() return Plater.db.profile.cast_statusbar_fadein_time end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.cast_statusbar_fadein_time = value
				Plater.UpdateAllPlates()
			end,
			min = 0.01,
			max = 1,
			step = 0.01,
			usedecimals = true,
			name = "Fade In Time",
			desc = "When a cast starts, this is the amount of time the cast bar takes to go from zero transparency to full opaque.",
		},
		{
			type = "range",
			get = function() return Plater.db.profile.cast_statusbar_fadeout_time end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.cast_statusbar_fadeout_time = value
				Plater.UpdateAllPlates()
			end,
			min = 0.01,
			max = 2,
			step = 0.01,
			usedecimals = true,
			name = "Fade Out Time",
			desc = "When a cast ends, this is the amount of time the cast bar takes to go from 100% transparency to not be visible at all.",
		},

		{type = "breakline"},
		
		{type = "label", get = function() return "Cast Bar Colors:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.cast_statusbar_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.cast_statusbar_color
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllPlates()
				Plater.DoCastBarTest()
			end,
			name = "Regular Cast",
			desc = "Regular Cast",
		},
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.cast_statusbar_color_channeling
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.cast_statusbar_color_channeling
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllPlates()
				Plater.DoCastBarTest()
			end,
			name = "Channelled Cast",
			desc = "Channelled Cast",
		},
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.cast_statusbar_color_nointerrupt
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.cast_statusbar_color_nointerrupt
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllPlates()
				Plater.DoCastBarTest (true)
			end,
			name = "Can't Interrupt Cast",
			desc = "Can't Interrupt Cast",
		},
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.cast_statusbar_color_interrupted
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.cast_statusbar_color_interrupted
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllPlates()
				Plater.DoCastBarTest()
			end,
			name = "Interrupted Cast",
			desc = "When the cast is interrupted, tint the castbar with this color.",
		},
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.cast_statusbar_color_finished
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.cast_statusbar_color_finished
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllPlates()
				Plater.DoCastBarTest()
			end,
			name = "Success Cast",
			desc = "When the cast is successfully completed.",
		},

		{
			type = "color",
			get = function()
				local color = Plater.db.profile.cast_statusbar_bgcolor
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.cast_statusbar_bgcolor
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllPlates()
				Plater.DoCastBarTest()
			end,
			name = "Background Color",
			desc = "Color used to paint the cast bar background.",
		},
		
		{type = "blank"},
		--toggle cast bar target
		{type = "label", get = function() return "Cast Bar Target Name:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "toggle",
			get = function() return Plater.db.profile.castbar_target_show end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.castbar_target_show = value
				Plater.RefreshDBUpvalues()
			end,
			name = "Show Target Name",
			desc = "Show who is the target of the current cast (if the target exists)",
		},

		{
			type = "toggle",
			get = function() return Plater.db.profile.castbar_target_notank end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.castbar_target_notank = value
				Plater.RefreshDBUpvalues()
			end,
			name = "[Tank] Don't Show Your Name",
			desc = "If you are a tank don't show the target name if the cast is on you.",
		},
		
		{
			type = "range",
			get = function() return Plater.db.profile.castbar_target_text_size end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.castbar_target_text_size = value
				Plater.UpdateAllPlates()
			end,
			min = 6,
			max = 99,
			step = 1,
			name = L["OPTIONS_SIZE"],
			desc = "Size",
		},
		--text font
		{
			type = "select",
			get = function() return Plater.db.profile.castbar_target_font end,
			values = function() return DF:BuildDropDownFontList (on_select_castbar_target_font) end,
			name = L["OPTIONS_FONT"],
			desc = "Font",
		},
		--cast text color
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.castbar_target_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.castbar_target_color
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllPlates()
			end,
			name = L["OPTIONS_COLOR"],
			desc = L["OPTIONS_COLOR"],
		},
		
		--text outline options
		{
			type = "select",
			get = function() return Plater.db.profile.castbar_target_outline end,
			values = function() return build_outline_modes_table (nil, "castbar_target_outline") end,
			name = L["OPTIONS_OUTLINE"],
			desc = "Outline",
		},
		
		--text shadow color
		{
			type = "color",
			get = function()
				local color = Plater.db.profile.castbar_target_shadow_color
				return {color[1], color[2], color[3], color[4]}
			end,
			set = function (self, r, g, b, a) 
				local color = Plater.db.profile.castbar_target_shadow_color
				color[1], color[2], color[3], color[4] = r, g, b, a
				Plater.UpdateAllPlates()
			end,
			name = L["OPTIONS_SHADOWCOLOR"],
			desc = ImportantText .. "hide and show nameplates to see changes.",
		},		
		
		{
			type = "select",
			get = function() return Plater.db.profile.castbar_target_anchor.side end,
			values = function() return build_anchor_side_table (nil, "castbar_target_anchor") end,
			name = L["OPTIONS_ANCHOR"],
			desc = "Which side of the cast bar this widget is attach to.",
		},
		{
			type = "range",
			get = function() return Plater.db.profile.castbar_target_anchor.x end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.castbar_target_anchor.x = value
				Plater.UpdateAllPlates()
			end,
			min = -100,
			max = 100,
			step = 1,
			usedecimals = true,
			name = L["OPTIONS_XOFFSET"],
			desc = "X Offset",
		},
		{
			type = "range",
			get = function() return Plater.db.profile.castbar_target_anchor.y end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.castbar_target_anchor.y = value
				Plater.UpdateAllPlates()
			end,
			min = -100,
			max = 100,
			step = 1,
			usedecimals = true,
			name = L["OPTIONS_YOFFSET"],
			desc = "Y Offset",
		},

		{type = "breakline"},
		--toggle cast bar target
		{type = "label", get = function() return "Spell Icon:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "toggle",
			get = function() return Plater.db.profile.castbar_icon_customization_enabled end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.castbar_icon_customization_enabled = value
				Plater.RefreshDBUpvalues()
			end,
			name = "Icon Customization Enabled",
			desc = "If this option is disabled, Plater won't modify the spell icon, leaving it for scripts to do.",
		},

		{
			type = "toggle",
			get = function() return Plater.db.profile.castbar_icon_show end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.castbar_icon_show = value
				Plater.RefreshDBUpvalues()
			end,
			name = "Show Icon",
			desc = "Show Icon",
		},

		{
			type = "select",
			get = function() return Plater.db.profile.castbar_icon_attach_to_side end,
			values = function() return castbar_icon_attach_to_side_options end,
			name = "Icon Side",
			desc = "Icon Side",
		},

		{
			type = "select",
			get = function() return Plater.db.profile.castbar_icon_size end,
			values = function() return castbar_icon_size_options end,
			name = "Icon Size",
			desc = "Icon Size",
		},

		{
			type = "range",
			get = function() return Plater.db.profile.castbar_icon_x_offset end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.castbar_icon_x_offset = value
				Plater.UpdateAllPlates()
			end,
			min = -20,
			max = 20,
			step = 1,
			name = L["OPTIONS_XOFFSET"],
			desc = L["OPTIONS_XOFFSET"],
		},
		
		{type = "blank"},
		{type = "label", get = function() return "Blizzard Cast Bar:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		
		--hide castbar from blizzard
		{
			type = "toggle",
			get = function() return Plater.db.profile.hide_blizzard_castbar end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.hide_blizzard_castbar = value
			end,
			name = "Hide Blizzard Player Cast Bar",
			desc = "Hide Blizzard Player Cast Bar",
		},
	}

	_G.C_Timer.After(0.800, function() --~delay
		--the -30 is to fix an annomaly where the options for castbars starts 30 pixels to the right, dunno why (tercio)
		DF:BuildMenu (castBarFrame, castBar_options, startX - 30, startY, heightSize, true, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template, globalCallback)	
	end)

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> ~threat ~aggro
	

	local thread_options = {
	
		{type = "label", get = function() return L["OPTIONS_THREAT_MODIFIERS_ANCHOR_TITLE"] .. ":" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
	
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
			name = L["OPTIONS_THREAT_MODIFIERS_HEALTHBARCOLOR"],
			desc = L["OPTIONS_THREAT_MODIFIERS_HEALTHBARCOLOR"],
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.aggro_modifies.border_color end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.aggro_modifies.border_color = value
				Plater.RefreshDBUpvalues()
				Plater.UpdateAllPlates()
			end,
			name = L["OPTIONS_THREAT_MODIFIERS_BORDERCOLOR"],
			desc = L["OPTIONS_THREAT_MODIFIERS_BORDERCOLOR"],
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.aggro_modifies.actor_name_color end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.aggro_modifies.actor_name_color = value
				Plater.RefreshDBUpvalues()
				Plater.UpdateAllPlates()
			end,
			name = L["OPTIONS_THREAT_MODIFIERS_NAMECOLOR"],
			desc = L["OPTIONS_THREAT_MODIFIERS_NAMECOLOR"],
		},

		{type = "blank"},
	
		{type = "label", get = function() return L["OPTIONS_THREAT_COLOR_TANK_ANCHOR_TITLE"] .. ":" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
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
			name = L["OPTIONS_THREAT_AGGROSTATE_ONYOU_SOLID"],
			desc =  L["OPTIONS_THREAT_COLOR_TANK_ONYOU_SOLID_DESC"],
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
			name = L["OPTIONS_THREAT_AGGROSTATE_ANOTHERTANK"],
			desc =  L["OPTIONS_THREAT_COLOR_TANK_ANOTHERTANK_DESC"],
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
			name = L["OPTIONS_THREAT_AGGROSTATE_ONYOU_LOWAGGRO"],
			desc = L["OPTIONS_THREAT_AGGROSTATE_ONYOU_LOWAGGRO_DESC"],
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
			name = L["OPTIONS_THREAT_AGGROSTATE_NOAGGRO"],
			desc = L["OPTIONS_THREAT_COLOR_TANK_NOAGGRO_DESC"],
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
			name = "Pulling From Another Tank",
			desc = "The unit has aggro on another tank and you're about to pull it.",
		},
		
		{type = "blank"},
		{type = "label", get = function() return L["OPTIONS_THREAT_COLOR_DPS_ANCHOR_TITLE"] .. ":" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},

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
			name = L["OPTIONS_THREAT_AGGROSTATE_ONYOU_SOLID"],
			desc = L["OPTIONS_THREAT_COLOR_DPS_ONYOU_SOLID_DESC"],
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
			name = L["OPTIONS_THREAT_AGGROSTATE_HIGHTHREAT"],
			desc = L["OPTIONS_THREAT_COLOR_DPS_HIGHTHREAT_DESC"],
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
			name = L["OPTIONS_THREAT_AGGROSTATE_NOAGGRO"],
			desc = L["OPTIONS_THREAT_COLOR_DPS_NOAGGRO_DESC"],
		},
		
		{
			type = "toggle",
			get = function() return Plater.db.profile.dps.use_aggro_solo end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.dps.use_aggro_solo = value
			end,
			name = "Use 'Solo' color",
			desc = "Use the 'Solo' color when not in a group.",
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
			name = "Solo",
			desc = "If enabled, always use this color when not in a group.",
		},
		
		{type = "blank"},
		{
			type = "toggle",
			get = function() return Plater.db.profile.aggro_can_check_notank end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.aggro_can_check_notank = value
			end,
			name = L["OPTIONS_THREAT_DPS_CANCHECKNOTANK"],
			desc = L["OPTIONS_THREAT_DPS_CANCHECKNOTANK_DESC"],
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
			name = L["OPTIONS_THREAT_AGGROSTATE_NOTANK"],
			desc = L["OPTIONS_THREAT_COLOR_DPS_NOTANK_DESC"],
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
			name = L["OPTIONS_THREAT_AGGROSTATE_NOTINCOMBAT"],
			desc = L["OPTIONS_THREAT_COLOR_TANK_NOTINCOMBAT_DESC"],
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
			name = L["OPTIONS_THREAT_AGGROSTATE_TAPPED"],
			desc = L["OPTIONS_THREAT_COLOR_TAPPED_DESC"],
		},
		
		{type = "breakline"},
	
	}
	
	
	if IS_WOW_PROJECT_NOT_MAINLINE then
		local thread_options_tank = {
			{type = "label", get = function() return "Tank or DPS Colors:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
			
			{
				type = "toggle",
				get = function() return Plater.db.profile.tank_threat_colors end,
				set = function (self, fixedparam, value) 
					Plater.db.profile.tank_threat_colors = value
					Plater.RefreshTankCache()
				end,
				name = "Use Tank Threat Colors",
				desc = "Use Tank Threat Colors",
			},
		
			{type = "blank"},
			
		}
		
		for _, t in ipairs (thread_options_tank) do
			tinsert (thread_options, t)
		end
	end
	
	local thread_options2 = {
		
		{type = "label", get = function() return L["OPTIONS_THREAT_COLOR_OVERRIDE_ANCHOR_TITLE"] .. ":" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		
		{
			type = "toggle",
			get = function() return Plater.db.profile.color_override end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.color_override = value
				Plater.RefreshColorOverride()
			end,
			name = L["OPTIONS_ENABLED"],
			desc = L["OPTIONS_THREAT_COLOR_OVERRIDE_DESC"],
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
			name = L["OPTIONS_HOSTILE"],
			desc = L["OPTIONS_HOSTILE"],
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
			name = L["OPTIONS_NEUTRAL"],
			desc = L["OPTIONS_NEUTRAL"],
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
			name = L["OPTIONS_FRIENDLY"],
			desc = L["OPTIONS_FRIENDLY"],
		},
		
		{type = "blank"},
		
		{type = "label", get = function() return "Misc" .. ":" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		
		{
			type = "toggle",
			get = function() return Plater.db.profile.show_aggro_flash end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.show_aggro_flash = value
			end,
			name = "Enable aggro flash",
			desc = "Enables the -AGGRO- flash animation on the nameplates when gaining aggro as dps.",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.show_aggro_glow end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.show_aggro_glow = value
			end,
			name = "Enable aggro glow",
			desc = "Enables the healthbar glow on the nameplates when gaining aggro as dps or losing aggro as tank.",
		},
		
	}
	
	for _, t in ipairs (thread_options2) do
		tinsert (thread_options, t)
	end
	
	_G.C_Timer.After(0.990, function() --~delay
		DF:BuildMenu (threatFrame, thread_options, startX, startY, heightSize, true, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template, globalCallback)
	end)
	
	
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> ~advanced ãdvanced
	

	local advanced_options = {
	
		{type = "label", get = function() return "General Settings:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		
		{
			type = "range",
			get = function() return Plater.db.profile.update_throttle end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.update_throttle = value
				Plater.RefreshDBUpvalues()
			end,
			min = 0.050,
			max = 0.500,
			step = 0.050,
			name = "Update Interval",
			usedecimals = true,
			desc = "Time interval in seconds between each update on the nameplate.\n\n|cFFFFFFFFDefault: 0.25|r (4 updates every second).",
		},
		
		{
			type = "toggle",
			get = function() return Plater.db.profile.quick_hide end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.quick_hide = value
				if (value) then
					SetCVar ("nameplateRemovalAnimation", CVAR_DISABLED)
				else
					SetCVar ("nameplateRemovalAnimation", CVAR_ENABLED)
				end
				Plater.UpdateAllPlates()
			end,
			nocombat = true,
			name = (IS_WOW_PROJECT_MAINLINE) and "Quick Hide on Death" or "Quick Hide Nameplates",
			desc = "When the unit dies, immediately hide the nameplates without playing the shrink animation.",
		},
		
		{
			type = "toggle",
			get = function() return Plater.db.profile.show_healthbars_on_not_attackable end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.show_healthbars_on_not_attackable = value
				Plater.UpdateAllPlates()
			end,
			name = "Show healthbars on not attackable units",
			desc = "Show Healthbars on not attackable units instead of defaulting to 'name only'.",
		},
		
		{type = "blank"},
		
		{type = "label", get = function() return "Client Settings (CVars):" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
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
			name = "Lock to Screen (Top Side)" .. CVarIcon,
			desc = "Min space between the nameplate and the top of the screen. Increase this if some part of the nameplate are going out of the screen.\n\n|cFFFFFFFFDefault: 0.065|r\n\n" .. ImportantText .. "if you're having issue, manually set using these macros:\n/run SetCVar ('nameplateOtherTopInset', '0.065')\n/run SetCVar ('nameplateLargeTopInset', '0.065')\n\n" .. ImportantText .. "setting to 0 disables this feature." .. CVarDesc,
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
			name = "Nameplate Overlap (V)" .. CVarIcon,
			desc = "The space between each nameplate vertically when stacking is enabled.\n\n|cFFFFFFFFDefault: 1.10|r" .. CVarDesc .. "\n\n" .. ImportantText .. "if you find issues with this setting, use:\n|cFFFFFFFF/run SetCVar ('nameplateOverlapV', '1.6')|r",
			nocombat = true,
		},
		{
			type = "range",
			get = function() return tonumber (GetCVar ("nameplateOverlapH")) end,
			set = function (self, fixedparam, value) 
				if (not InCombatLockdown()) then
					SetCVar ("nameplateOverlapH", value)
				else
					Plater:Msg (L["OPTIONS_ERROR_CVARMODIFY"])
				end
			end,
			min = 0.2,
			max = 2.5,
			step = 0.05,
			thumbscale = 1.7,
			usedecimals = true,
			name = "Nameplate Overlap (H)" .. CVarIcon,
			desc = "The space between each nameplate horizontally when stacking is enabled.\n\n|cFFFFFFFFDefault: 0.8|r" .. CVarDesc .. "\n\n" .. ImportantText .. "if you find issues with this setting, use:\n|cFFFFFFFF/run SetCVar ('nameplateOverlapH', '0.8')|r",
			nocombat = true,
		},
		
		{
			type = "range",
			get = function() return tonumber (GetCVar (CVAR_MOVEMENT_SPEED)) end,
			set = function (self, fixedparam, value) 
				if (not InCombatLockdown()) then
					SetCVar (CVAR_MOVEMENT_SPEED, value)
				else
					Plater:Msg (L["OPTIONS_ERROR_CVARMODIFY"])
				end
			end,
			min = 0.02,
			max = 0.2,
			step = 0.005,
			thumbscale = 1.7,
			usedecimals = true,
			name = "Movement Speed" .. CVarIcon,
			desc = "How fast the nameplate moves (when stacking is enabled).\n\n|cFFFFFFFFDefault: 0.025|r\n\n|cFFFFFFFFRecommended: 0.05|r" .. CVarDesc,
			nocombat = true,
		},
		{
			type = "range",
			get = function() return tonumber (GetCVar ("nameplateGlobalScale")) end,
			set = function (self, fixedparam, value) 
				if (not InCombatLockdown()) then
					SetCVar ("nameplateGlobalScale", value)
				else
					Plater:Msg (L["OPTIONS_ERROR_CVARMODIFY"])
				end
			end,
			min = 0.75,
			max = 2,
			step = 0.1,
			thumbscale = 1.7,
			usedecimals = true,
			name = "Global Scale" .. CVarIcon,
			desc = "Scale all nameplates.\n\n|cFFFFFFFFDefault: 1|r" .. CVarDesc,
			nocombat = true,
		},
		
		{
			type = "range",
			get = function() return tonumber (GetCVar ("nameplateMinScale")) end,
			set = function (self, fixedparam, value) 
				if (not InCombatLockdown()) then
					SetCVar ("nameplateMinScale", value)
				else
					Plater:Msg (L["OPTIONS_ERROR_CVARMODIFY"])
				end
			end,
			min = 0.3,
			max = 2,
			step = 0.1,
			thumbscale = 1.7,
			usedecimals = true,
			name = "Min Scale" .. CVarIcon,
			desc = "Scale applied when the nameplate is far away from the camera.\n\n" .. ImportantText .. "is the distance from the camera and |cFFFF4444not|r the distance from your character.\n\n|cFFFFFFFFDefault: 0.8|r" .. CVarDesc,
			nocombat = true,
		},

		{
			type = "select",
			get = function() return tonumber (GetCVar ("nameplateOtherAtBase")) end,
			values = function() return nameplate_anchor_options end,
			name = "Anchor Point" .. CVarIcon,
			desc = "Where the nameplate is anchored to.\n\n|cFFFFFFFFDefault: Head|r" .. CVarDesc,
			nocombat = true,
		},
		{
			type = "toggle",
			get = function() return GetCVarBool ("nameplateShowDebuffsOnFriendly") end,
			set = function (self, fixedparam, value) 
				if (not InCombatLockdown()) then
					SetCVar ("nameplateShowDebuffsOnFriendly", value and "1" or "0")
				else
					Plater:Msg (L["OPTIONS_ERROR_CVARMODIFY"])
					self:SetValue (GetCVarBool ("nameplateShowDebuffsOnFriendly"))
				end
			end,
			name = "Show Debuffs on Blizzard Health Bars" .. CVarIcon,
			desc = "While in dungeons or raids, if friendly nameplates are enabled it won't show debuffs on them.\nIf any Plater module is disabled, this will affect these nameplates as well." .. CVarDesc .. CVarNeedReload,
			nocombat = true,
		},
		
		{type = "breakline"},
		{type = "label", get = function() return "Unit types:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		
		{
			type = "toggle",
			get = function() return GetCVar ("nameplateShowEnemyGuardians") == CVAR_ENABLED end,
			set = function (self, fixedparam, value) 
				if (not InCombatLockdown()) then
					SetCVar ("nameplateShowEnemyGuardians", math.abs (tonumber (GetCVar ("nameplateShowEnemyGuardians"))-1))
				else
					Plater:Msg (L["OPTIONS_ERROR_CVARMODIFY"])
					self:SetValue (GetCVar ("nameplateShowEnemyGuardians") == CVAR_ENABLED)
				end
			end,
			name = "Show Enemy Guardians" .. CVarIcon,
			desc = "Show nameplates for enemies pets considered as guardian" .. CVarDesc,
			nocombat = true,
		},
		
		{
			type = "toggle",
			get = function() return GetCVar ("nameplateShowEnemyMinions") == CVAR_ENABLED end,
			set = function (self, fixedparam, value) 
				if (not InCombatLockdown()) then
					SetCVar ("nameplateShowEnemyMinions", math.abs (tonumber (GetCVar ("nameplateShowEnemyMinions"))-1))
				else
					Plater:Msg (L["OPTIONS_ERROR_CVARMODIFY"])
					self:SetValue (GetCVar ("nameplateShowEnemyMinions") == CVAR_ENABLED)
				end
			end,
			name = "Show Enemy Minions" .. CVarIcon,
			desc = "Show nameplates for enemies considered as minions" .. CVarDesc,
			nocombat = true,
		},
		
		{
			type = "toggle",
			get = function() return GetCVar ("nameplateShowEnemyMinus") == CVAR_ENABLED end,
			set = function (self, fixedparam, value) 
				if (not InCombatLockdown()) then
					SetCVar ("nameplateShowEnemyMinus", math.abs (tonumber (GetCVar ("nameplateShowEnemyMinus"))-1))
				else
					Plater:Msg (L["OPTIONS_ERROR_CVARMODIFY"])
					self:SetValue (GetCVar ("nameplateShowEnemyMinus") == CVAR_ENABLED)
				end
			end,
			name = "Show Enemy Minor Units" .. CVarIcon,
			desc = "Show nameplates of small units (usually they are units with max level but low health)" .. CVarDesc,
			nocombat = true,
		},

		{
			type = "toggle",
			get = function() return GetCVar ("nameplateShowEnemyPets") == CVAR_ENABLED end,
			set = function (self, fixedparam, value) 
				if (not InCombatLockdown()) then
					SetCVar ("nameplateShowEnemyPets", math.abs (tonumber (GetCVar ("nameplateShowEnemyPets"))-1))
				else
					Plater:Msg (L["OPTIONS_ERROR_CVARMODIFY"])
					self:SetValue (GetCVar ("nameplateShowEnemyPets") == CVAR_ENABLED)
				end
			end,
			name = "Show Enemy Pets" .. CVarIcon,
			desc = "Show nameplates for enemy pets" .. CVarDesc,
			nocombat = true,
		},

		{
			type = "toggle",
			get = function() return GetCVar ("nameplateShowEnemyTotems") == CVAR_ENABLED end,
			set = function (self, fixedparam, value) 
				if (not InCombatLockdown()) then
					SetCVar ("nameplateShowEnemyTotems", math.abs (tonumber (GetCVar ("nameplateShowEnemyTotems"))-1))
				else
					Plater:Msg (L["OPTIONS_ERROR_CVARMODIFY"])
					self:SetValue (GetCVar ("nameplateShowEnemyTotems") == CVAR_ENABLED)
				end
			end,
			name = "Show Enemy Totems" .. CVarIcon,
			desc = "Show enemy totems" .. CVarDesc,
			nocombat = true,
		},

		{type = "blank"},
		
		{
			type = "toggle",
			get = function() return GetCVar ("nameplateShowFriendlyNPCs") == CVAR_ENABLED end,
			set = function (self, fixedparam, value) 
				if (not InCombatLockdown()) then
					SetCVar ("nameplateShowFriendlyNPCs", math.abs (tonumber (GetCVar ("nameplateShowFriendlyNPCs"))-1))
				else
					Plater:Msg (L["OPTIONS_ERROR_CVARMODIFY"])
					self:SetValue (GetCVar ("nameplateShowFriendlyNPCs") == CVAR_ENABLED)
				end
			end,
			name = "Show Friendly Npcs" .. CVarIcon,
			desc = "Show nameplates for friendly npcs" .. CVarDesc,
			nocombat = true,
		},
		
		{
			type = "toggle",
			get = function() return GetCVar ("nameplateShowFriendlyGuardians") == CVAR_ENABLED end,
			set = function (self, fixedparam, value) 
				if (not InCombatLockdown()) then
					SetCVar ("nameplateShowFriendlyGuardians", math.abs (tonumber (GetCVar ("nameplateShowFriendlyGuardians"))-1))
				else
					Plater:Msg (L["OPTIONS_ERROR_CVARMODIFY"])
					self:SetValue (GetCVar ("nameplateShowFriendlyGuardians") == CVAR_ENABLED)
				end
			end,
			name = "Show Friendly Guardians" .. CVarIcon,
			desc = "Show nameplates for friendly pets considered as guardian" .. CVarDesc,
			nocombat = true,
		},

		{
			type = "toggle",
			get = function() return GetCVar ("nameplateShowFriendlyMinions") == CVAR_ENABLED end,
			set = function (self, fixedparam, value) 
				if (not InCombatLockdown()) then
					SetCVar ("nameplateShowFriendlyMinions", math.abs (tonumber (GetCVar ("nameplateShowFriendlyMinions"))-1))
				else
					Plater:Msg (L["OPTIONS_ERROR_CVARMODIFY"])
					self:SetValue (GetCVar ("nameplateShowFriendlyMinions") == CVAR_ENABLED)
				end
			end,
			name = "Show Friendly Minions" .. CVarIcon,
			desc = "Show nameplates for friendly units considered minions" .. CVarDesc,
			nocombat = true,
		},

		{
			type = "toggle",
			get = function() return GetCVar ("nameplateShowFriendlyPets") == CVAR_ENABLED end,
			set = function (self, fixedparam, value) 
				if (not InCombatLockdown()) then
					SetCVar ("nameplateShowFriendlyPets", math.abs (tonumber (GetCVar ("nameplateShowFriendlyPets"))-1))
				else
					Plater:Msg (L["OPTIONS_ERROR_CVARMODIFY"])
					self:SetValue (GetCVar ("nameplateShowFriendlyPets") == CVAR_ENABLED)
				end
			end,
			name = "Show Friendly Pets" .. CVarIcon,
			desc = "Show nameplates for friendly pets" .. CVarDesc,
			nocombat = true,
		},

		{
			type = "toggle",
			get = function() return GetCVar ("nameplateShowFriendlyTotems") == CVAR_ENABLED end,
			set = function (self, fixedparam, value) 
				if (not InCombatLockdown()) then
					SetCVar ("nameplateShowFriendlyTotems", math.abs (tonumber (GetCVar ("nameplateShowFriendlyTotems"))-1))
				else
					Plater:Msg (L["OPTIONS_ERROR_CVARMODIFY"])
					self:SetValue (GetCVar ("nameplateShowFriendlyTotems") == CVAR_ENABLED)
				end
			end,
			name = "Show Friendly Totems" .. CVarIcon,
			desc = "Show friendly totems" .. CVarDesc,
			nocombat = true,
		},

		{type = "breakline"},
	
		{type = "label", get = function() return "Enemy Box Selection Space:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "range",
			get = function() return Plater.db.profile.click_space[1] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.click_space[1] = value
				Plater.UpdatePlateClickSpace (nil, true)
			end,
			min = 1,
			max = 300,
			step = 1,
			name = "Width",
			nocombat = true,
			desc = "How large are area which accepts mouse clicks to select the target",
		},
		
		{
			type = "range",
			get = function() return Plater.db.profile.click_space[2] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.click_space[2] = value
				Plater.UpdatePlateClickSpace (nil, true)
			end,
			min = 1,
			max = 100,
			step = 1,
			name = "Height",
			nocombat = true,
			desc = "The height of the are area which accepts mouse clicks to select the target",
		},
		
		{type = "blank"},
		
		{type = "label", get = function() return "Friendly Box Selection Space:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "range",
			get = function() return Plater.db.profile.click_space_friendly[1] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.click_space_friendly[1] = value
				Plater.UpdatePlateClickSpace (nil, true)
			end,
			min = 1,
			max = 300,
			step = 1,
			name = "Width",
			nocombat = true,
			desc = "How large are area which accepts mouse clicks to select the target",
		},
		
		{
			type = "range",
			get = function() return Plater.db.profile.click_space_friendly[2] end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.click_space_friendly[2] = value
				Plater.UpdatePlateClickSpace (nil, true)
			end,
			min = 1,
			max = 100,
			step = 1,
			name = "Height",
			nocombat = true,
			desc = "The height of the are area which accepts mouse clicks to select the target",
		},		
		
		{type = "blank"},
		
		{
			type = "toggle",
			get = function() return Plater.db.profile.click_space_always_show end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.click_space_always_show = value
				Plater.UpdateAllPlates()
			end,
			nocombat = true,
			name = "Always Show Background",
			desc = "Enable a background showing the area of the clickable area.",
		},
		
		{type = "blank"},
		
		--can't go up to 100 pixels deviation due to the clicable space from the plateFrame
		--if it goes more than the plateFrame area it generates areas where isn't clicable
		{type = "label", get = function() return "Global OffSet:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		{
			type = "range",
			get = function() return Plater.db.profile.global_offset_x end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.global_offset_x = value
				Plater.UpdateAllPlates()
				Plater.UpdatePlateClickSpace (nil, true)
			end,
			min = -20,
			max = 20,
			step = 1,
			usedecimals = true,
			name = L["OPTIONS_XOFFSET"],
			desc = "Slightly adjust the entire nameplate.",
		},
		{
			type = "range",
			get = function() return Plater.db.profile.global_offset_y end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.global_offset_y = value
				Plater.UpdateAllPlates()
				Plater.UpdatePlateClickSpace (nil, true)
			end,
			min = -20,
			max = 20,
			step = 1,
			usedecimals = true,
			name = L["OPTIONS_YOFFSET"],
			desc = "Slightly adjust the entire nameplate.",
		},
		
		{type = "blank"},

		{type = "label", get = function() return "Special Units:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
	
		{
			type = "range",
			get = function() return Plater.db.profile.pet_width_scale end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.pet_width_scale = value
				Plater.UpdateAllPlates()
			end,
			min = 0.2,
			max = 2,
			step = 0.1,
			name = "Pet Width Scale",
			desc = "Slightly adjust the size of nameplates when showing a pet",
			usedecimals = true,
		},
		{
			type = "range",
			get = function() return Plater.db.profile.pet_height_scale end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.pet_height_scale = value
				Plater.UpdateAllPlates()
			end,
			min = 0.2,
			max = 2,
			step = 0.1,
			name = "Pet Height Scale",
			desc = "Slightly adjust the size of nameplates when showing a pet",
			usedecimals = true,
		},
		{
			type = "range",
			get = function() return Plater.db.profile.minor_width_scale end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.minor_width_scale = value
				Plater.UpdateAllPlates()
			end,
			min = 0.2,
			max = 2,
			step = 0.1,
			name = "Minor Unit Width Scale",
			desc = "Slightly adjust the size of nameplates when showing a minor unit (these units has a smaller nameplate by default).",
			usedecimals = true,
		},
		{
			type = "range",
			get = function() return Plater.db.profile.minor_height_scale end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.minor_height_scale = value
				Plater.UpdateAllPlates()
			end,
			min = 0.2,
			max = 2,
			step = 0.1,
			name = "Minor Unit Height Scale",
			desc = "Slightly adjust the size of nameplates when showing a minor unit (these units has a smaller nameplate by default).",
			usedecimals = true,
		},
		
		{type = "blank"},
		{type = "label", get = function() return "Region:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		
		{
			type = "select",
			get = function() return Plater.db.profile.number_region end,
			values = function() return build_number_format_options() end,
			name = "Number Format",
			desc = "Number format",
		},
		
		{type = "breakline"},
		{type = "label", get = function() return "Misc:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		
		{
			type = "toggle",
			get = function() return Plater.db.profile.show_health_prediction end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.show_health_prediction = value
			end,
			name = "Show Health Prediction/Absorption",
			desc = "Show an extra bar for health prediction and heal absorption.",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.show_shield_prediction end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.show_shield_prediction = value
			end,
			name = "Show Shield Prediction",
			desc = "Show an extra bar for shields (e.g. Power Word: Shield from priests) absorption.",
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
			get = function() return Plater.db.profile.enable_masque_support end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.enable_masque_support = value
				Plater:Msg ("this setting require a /reload to take effect.")
			end,
			name = "Masque Support",
			desc = "If the Masque addon is installed, enabling this will make Plater to use Masque borders.\n\n" .. ImportantText .. "require /reload after changing this setting.",
		},
		
		{
			type = "toggle",
			get = function() return Plater.db.profile.use_name_translit end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.use_name_translit = value
				Plater.RefreshDBUpvalues()
				Plater.FullRefreshAllPlates()
			end,
			name = "Name translit",
			desc = "Use LibTranslit to translit names. Changed names will be tagged with a '*'",
		},
		
		{
			type = "toggle",
			get = function() return Plater.db.profile.use_player_combat_state end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.use_player_combat_state = value
			end,
			name = "In/Out of Combat Settings - Use Player Combat State",
			desc = "Use the players combat state instead of the units when applying settings for In/Out of Combat.",
		},
	
		{type = "blank"},
		{type = "label", get = function() return "Personal Bar Custom Position:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"), hidden = IS_WOW_PROJECT_NOT_MAINLINE},
		{
			type = "range",
			get = function() return tonumber (GetCVar ("nameplateSelfTopInset")*100) end,
			set = function (self, fixedparam, value) 
				--Plater.db.profile.plate_config.player.y_position_offset = value

				if (InCombatLockdown()) then
					Plater:Msg (L["OPTIONS_ERROR_CVARMODIFY"])
					self:SetValue (tonumber (GetCVar ("nameplateSelfTopInset")*100))
					return
				end

				--SetCVar ("nameplateSelfBottomInset", value / 100)
				SetCVar ("nameplateSelfTopInset", abs (value - 99) / 100)
				
				if (not Plater.PersonalAdjustLocationTop) then
					Plater.PersonalAdjustLocationTop = CreateFrame ("frame", "PlaterPersonalBarLocation", UIParent, BackdropTemplateMixin and "BackdropTemplate")
					local frame = Plater.PersonalAdjustLocationTop
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
					frame.Text:SetText ("Plater: Top Constraint")
					frame.Text:SetPoint ("center")
					
					frame.HideAnimation = DF:CreateAnimationHub (frame, nil, function() frame:Hide() end)
					DF:CreateAnimation (frame.HideAnimation, "Alpha", 1, 1, 1, 0)
					
					frame.CancelFunction = function()
						frame.HideAnimation:Play()
					end
				end
				
				if (Plater.PersonalAdjustLocationTop.HideAnimation:IsPlaying()) then
					Plater.PersonalAdjustLocationTop.HideAnimation:Stop()
					Plater.PersonalAdjustLocationTop:SetAlpha (1)
				end
				Plater.PersonalAdjustLocationTop:Show()
				
				local percentValue = GetScreenHeight()/100
				Plater.PersonalAdjustLocationTop:SetPoint ("bottom", UIParent, "bottom", 0, percentValue * value)
				
				if (Plater.PersonalAdjustLocationTop.Timer) then
					Plater.PersonalAdjustLocationTop.Timer:Cancel()
				end
				Plater.PersonalAdjustLocationTop.Timer = C_Timer.NewTimer (10, Plater.PersonalAdjustLocationTop.CancelFunction)
				
				Plater.UpdateAllPlates()
				Plater.UpdateSelfPlate()
			end,
			min = 2,
			max = 51,
			step = 1,
			nocombat = true,
			name = "Top Constrain" .. CVarIcon,
			desc = "Adjust the top constrain position where the personal bar cannot pass.\n\n|cFFFFFFFFDefault: 50|r" .. CVarDesc,
			hidden = IS_WOW_PROJECT_NOT_MAINLINE,
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

				SetCVar ("nameplateSelfBottomInset", value / 100)
				--SetCVar ("nameplateSelfTopInset", value / 100)
				
				if (not Plater.PersonalAdjustLocationBottom) then
					Plater.PersonalAdjustLocationBottom = CreateFrame ("frame", "PlaterPersonalBarLocation", UIParent, BackdropTemplateMixin and "BackdropTemplate")
					local frame = Plater.PersonalAdjustLocationBottom
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
					frame.Text:SetText ("Plater: Bottom Constraint")
					frame.Text:SetPoint ("center")
					
					frame.HideAnimation = DF:CreateAnimationHub (frame, nil, function() frame:Hide() end)
					DF:CreateAnimation (frame.HideAnimation, "Alpha", 1, 1, 1, 0)
					
					frame.CancelFunction = function()
						frame.HideAnimation:Play()
					end
				end
				
				if (Plater.PersonalAdjustLocationBottom.HideAnimation:IsPlaying()) then
					Plater.PersonalAdjustLocationBottom.HideAnimation:Stop()
					Plater.PersonalAdjustLocationBottom:SetAlpha (1)
				end
				Plater.PersonalAdjustLocationBottom:Show()
				
				local percentValue = GetScreenHeight()/100
				Plater.PersonalAdjustLocationBottom:SetPoint ("bottom", UIParent, "bottom", 0, percentValue * value)
				
				if (Plater.PersonalAdjustLocationBottom.Timer) then
					Plater.PersonalAdjustLocationBottom.Timer:Cancel()
				end
				Plater.PersonalAdjustLocationBottom.Timer = C_Timer.NewTimer (10, Plater.PersonalAdjustLocationBottom.CancelFunction)
				
				Plater.UpdateAllPlates()
				Plater.UpdateSelfPlate()
			end,
			min = 2,
			max = 51,
			step = 1,
			nocombat = true,
			name = "Bottom Constrain" .. CVarIcon,
			desc = "Adjust the bottom constrain position where the personal bar cannot pass.\n\n|cFFFFFFFFDefault: 20|r" .. CVarDesc,
			hidden = IS_WOW_PROJECT_NOT_MAINLINE,
		},	
		
		{type = "blank"},
		{type = "label", get = function() return "Animations:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
		
		{
			type = "toggle",
			get = function() return Plater.db.profile.use_health_animation end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.use_health_animation = value
				Plater.RefreshDBUpvalues()
				Plater.UpdateAllPlates()
			end,
			name = "Animate Health Bar",
			desc = "Do a smooth animation when the nameplate's health value changes.",
		},
		{
			type = "toggle",
			get = function() return Plater.db.profile.use_color_lerp end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.use_color_lerp = value
				Plater.RefreshDBUpvalues()
				Plater.UpdateAllPlates()
			end,
			name = "Animate Color Transitions",
			desc = "Color changes does a smooth transition between the old and the new color.",
		},
		{
			type = "range",
			get = function() return Plater.db.profile.health_animation_time_dilatation end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.health_animation_time_dilatation = value
				Plater.RefreshDBUpvalues()
				Plater.DebugHealthAnimation()
			end,
			min = 0.35,
			max = 5,
			step = 0.1,
			usedecimals = true,
			thumbscale = 1.7,
			name = "Health Bar Animation Speed",
			desc = "How fast is the animation.",
		},	
		{
			type = "range",
			get = function() return Plater.db.profile.color_lerp_speed end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.color_lerp_speed = value
				Plater.RefreshDBUpvalues()
				Plater.DebugColorAnimation()
			end,
			min = 1,
			max = 50,
			step = 1,
			name = "Color Animation Speed",
			desc = "How fast is the animation.",
		},

		{type = "blank"},

		{type = "label", get = function() return "Unit Widget Bars:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"), hidden = IS_WOW_PROJECT_NOT_MAINLINE},
		{
			type = "toggle",
			get = function() return Plater.db.profile.usePlaterWidget end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.usePlaterWidget = value
			end,
			name = L["OPTIONS_ENABLED"],
			desc = "Enabled",
			hidden = IS_WOW_PROJECT_NOT_MAINLINE,
		},
		{
			type = "range",
			get = function() return Plater.db.profile.widget_bar_scale end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.widget_bar_scale = value
				Plater.UpdateAllPlates()
			end,
			min = 0.2,
			max = 2,
			step = 0.1,
			name = "Scale",
			desc = "Slightly adjust the size of widget bars.",
			usedecimals = true,
			hidden = IS_WOW_PROJECT_NOT_MAINLINE,
		},
		{
			type = "select",
			get = function() return Plater.db.profile.widget_bar_anchor.side end,
			values = function() return build_anchor_side_table (nil, "widget_bar_anchor") end,
			name = L["OPTIONS_ANCHOR"],
			desc = "Which side of the nameplate the widget bar should attach to.",
			hidden = IS_WOW_PROJECT_NOT_MAINLINE,
		},
		{
			type = "range",
			get = function() return Plater.db.profile.widget_bar_anchor.x end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.widget_bar_anchor.x = value
				Plater.UpdateAllPlates()
			end,
			min = -20,
			max = 20,
			step = 1,
			usedecimals = true,
			name = L["OPTIONS_XOFFSET"],
			desc = "Adjust the position on the X axis." .. SliderRightClickDesc,
			hidden = IS_WOW_PROJECT_NOT_MAINLINE,
		},
		{
			type = "range",
			get = function() return Plater.db.profile.widget_bar_anchor.y end,
			set = function (self, fixedparam, value) 
				Plater.db.profile.widget_bar_anchor.y = value
				Plater.UpdateAllPlates()
			end,
			min = -20,
			max = 20,
			step = 1,
			usedecimals = true,
			name = L["OPTIONS_YOFFSET"],
			desc = "Adjust the position on the Y axis." .. SliderRightClickDesc,
			hidden = IS_WOW_PROJECT_NOT_MAINLINE,
		},
		
	}
	
	_G.C_Timer.After(1.4, function() --~delay
		DF:BuildMenu (advancedFrame, advanced_options, startX, startY, heightSize, true, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template, globalCallback)
	end)



--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--~search panel
	local searchLabel = DF:CreateLabel(searchFrame, "Search:")
	local searchBox = DF:CreateTextEntry (searchFrame, function()end, 156, 20, "serachTextEntry", _, _, DF:GetTemplate ("dropdown", "PLATER_DROPDOWN_OPTIONS"))
	searchBox:SetJustifyH("left")

	searchLabel:SetPoint(10, -130)
	searchBox:SetPoint(10, -140)

	local optionsWildCardFrame = CreateFrame("frame", "$parentWildCardOptionsFrame", searchFrame, BackdropTemplateMixin and "BackdropTemplate")
	optionsWildCardFrame:SetAllPoints()
	
	--all settings tables
	local allTabSettings = {
		--interface_options, -- general
		options_table1, -- general
		thread_options, -- threat & aggro
		targetOptions, -- target
		castBar_options, -- cast bar
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
	
	local allTabHeaders = {
		mainFrame.AllButtons [1].button.text:GetText(), -- general
		mainFrame.AllButtons [2].button.text:GetText(), -- threat & aggro
		mainFrame.AllButtons [3].button.text:GetText(), -- target
		mainFrame.AllButtons [4].button.text:GetText(), -- cast bar
		mainFrame.AllButtons [5].button.text:GetText(), -- level & strata
		mainFrame.AllButtons [8].button.text:GetText(), -- personal bar
		mainFrame.AllButtons [9].button.text:GetText(), -- buff settings
		--10 aura filter
		mainFrame.AllButtons [11].button.text:GetText(), -- buff special
		--mainFrame.AllButtons [12].button.text:GetText(), -- ghost auras
		mainFrame.AllButtons [13].button.text:GetText(), -- enemy npc
		mainFrame.AllButtons [14].button.text:GetText(), -- enemy player
		mainFrame.AllButtons [15].button.text:GetText(), -- friendly npc
		mainFrame.AllButtons [16].button.text:GetText(), -- friendly player
		--17 18 19 has no options (npc colors, cast colors, aura list)
		--mainFrame.AllButtons [20].button.text:GetText(), -- spell feedback (animations)
		mainFrame.AllButtons [21].button.text:GetText(), -- auto
		--22 profiles
		mainFrame.AllButtons [23].button.text:GetText(), -- advanced
		--mainFrame.AllButtons [24].button.text:GetText(), -- resources
		--25 search
	}

	--this table will hold all options
	local allOptions = {}
	--start the fill process filling 'allOptions' with each individual option from each tab
	for i = 1, #allTabSettings do
		local tabSettings = allTabSettings[i]
		local lastLabel = nil
		for k, setting in pairs(tabSettings) do
			if (setting.type == "label") then
				lastLabel = setting
			end
			if (setting.name) then
				allOptions[#allOptions+1] = {setting = setting, label = lastLabel, header = allTabHeaders[i] }
			end
		end
	end

	searchBox:SetHook("OnEnterPressed", function(self)
		local options = {}

		local searchingText = string.lower(searchBox.text)
		searchBox:SetFocus(false)

		local lastTab = nil
		local lastLabel = nil
		for i = 1, #allOptions do
			local optionData = allOptions[i]
			local optionName = string.lower(optionData.setting.name)
			if (optionName:find(searchingText)) then
				if optionData.header ~= lastTab then
					if lastTab ~= nil then
						options[#options+1] = {type = "label", get = function() return "" end, text_template = DF:GetTemplate ("font", "OPTIONS_FONT_TEMPLATE")} -- blank
					end
					options[#options+1] = {type = "label", get = function() return optionData.header end, text_template = {color = "gold", size = 14, font = DF:GetBestFontForLanguage()}}
					lastTab = optionData.header
					lastLabel = nil
				end
				if optionData.label ~= lastLabel then
					options[#options+1] = optionData.label
					lastLabel = optionData.label
				end
				options[#options+1] = optionData.setting
			end
		end

		DF:BuildMenuVolatile (searchFrame, options, startX, startY-30, heightSize+40, true, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template, globalCallback)

		--[=[
		if (searchFrame.widget_list) then
			for i = 1, #searchFrame.widget_list do
				searchFrame.widget_list[i]:Hide()
				if (searchFrame.widget_list[i].hasLabel) then
					searchFrame.widget_list[i].hasLabel:Hide()
				end
			end
			wipe(searchFrame.widget_list)
			searchFrame.widget_list = nil
		end

		if (searchFrame.widgetids) then
			wipe(searchFrame.widgetids)
			searchFrame.widgetids = nil
		end

		DF:BuildMenu (searchFrame, options, startX, startY-30, heightSize+40, true, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template, globalCallback)
		--]=]
	end)



	--
	Plater.CheckOptionsTab()
end


--endd functiond