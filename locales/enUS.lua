do
    local addonId = ...
    local languageTable = DetailsFramework.Language.RegisterLanguage(addonId, "enUS")
    local L = languageTable

    --add to curseforge

L["OPTIONS_"] = ""

    L["OPTIONS_AUDIOCUE_COOLDOWN"] = "Audio Cooldown"
    L["OPTIONS_AUDIOCUE_COOLDOWN_DESC"] = "Amount of time in milliseconds to wait before playing the SAME audio again.\n\nPrevents loud sounds from playing when two or more casts are happening at the same time.\n\nSet to 0 to disable this feature."

    --on curseforge
    L["OPTIONS_CASTBAR_APPEARANCE"] = "Cast Bar Appearance"
    L["OPTIONS_CASTBAR_SPARK_SETTINGS"] = "Spark Settings"
    L["OPTIONS_CASTBAR_COLORS"] = "Cast Bar Colors"
    L["OPTIONS_CASTBAR_SPELLICON"] = "Spell Icon"
    L["OPTIONS_CASTBAR_BLIZZCASTBAR"] = "Blizzard Cast Bar"

    L["IMPORT_CAST_SOUNDS"] = "Import Sounds"
    L["EXPORT_CAST_SOUNDS"] = "Share Sounds"
    L["OPTIONS_NOTHING_TO_EXPORT"] = "There's nothing to export."
    L["IMPORT"] = "Import"
    L["EXPORT"] = "Export"
    L["IMPORT_CAST_COLORS"] = "Import Colors"
    L["EXPORT_CAST_COLORS"] = "Share Colors"
    L["OPTIONS_SHOWOPTIONS"] = "Show Options"
    L["OPTIONS_SHOWSCRIPTS"] = "Show Scripts"
    L["OPTIONS_CASTCOLORS_DISABLECOLORS"] = "Disable All Colors"
    L["OPTIONS_CASTCOLORS_DISABLECOLORS_CONFIRM"] = "Confirm disable all cast colors?"
    L["OPTIONS_CASTCOLORS_DISABLE_SOUNDS"] = "Remove All Sounds"
    L["OPTIONS_CASTCOLORS_DISABLE_SOUNDS_CONFIRM"] = "Are you sure you want to remove all configured cast sounds?"

    L["OPTIONS_NOESSENTIAL_TITLE"] = "Skip Non Essential Script Patches"
    L["OPTIONS_NOESSENTIAL_NAME"] = "Disable non-essential script updates during Plater version upgrades."
    L["OPTIONS_NOESSENTIAL_DESC"] = "On updating Plater, it is common for the new version to also update scripts from the scripts tab.\nThis may sometimes overwrite changes made by the creator of the profile. The option below prevents Plater from modifying scripts when the addon receives an update.\n\nNote: During major patches and bug fixes, Plater may still update scripts."
    L["OPTIONS_NOESSENTIAL_SKIP_ALERT"] = "Skipped non-essential patch:"

    L["OPTIONS_COLOR_BACKGROUND"] = "Background Color"

    L["OPTIONS_CASTBAR_SPARK_HIDE_INTERRUPT"] = "Hide Spark On Interrupt"
    L["OPTIONS_CASTBAR_SPARK_HALF"] = "Half Spark"
    L["OPTIONS_CASTBAR_SPARK_HALF_DESC"] = "Show only half of the spark texture."
    L["OPTIONS_CASTBAR_FADE_ANIM_ENABLED"] = "Enable Fade Animations"
    L["OPTIONS_CASTBAR_FADE_ANIM_ENABLED_DESC"] = "Enable fade animations when the cast starts and stop."
    L["OPTIONS_CASTBAR_FADE_ANIM_TIME_START"] = "On Start"
    L["OPTIONS_CASTBAR_FADE_ANIM_TIME_START_DESC"] = "When a cast starts, this is the amount of time the cast bar takes to go from zero transparency to full opaque."
    L["OPTIONS_CASTBAR_FADE_ANIM_TIME_END"] = "On Stop"
    L["OPTIONS_CASTBAR_FADE_ANIM_TIME_END_DESC"] = "When a cast ends, this is the amount of time the cast bar takes to go from 100% transparency to not be visible at all."

    L["OPTIONS_CAST_COLOR_REGULAR"] = "Regular"
    L["OPTIONS_CAST_COLOR_CHANNELING"] = "Channelled"
    L["OPTIONS_CAST_COLOR_UNINTERRUPTIBLE"] = "Uninterruptible"
    L["OPTIONS_CAST_COLOR_INTERRUPTED"] = "Interrupted"
    L["OPTIONS_CAST_COLOR_SUCCESS"] = "Success"

    L["OPTIONS_CAST_SHOW_TARGETNAME"] = "Show Target Name"
    L["OPTIONS_CAST_SHOW_TARGETNAME_DESC"] = "Show who is the target of the current cast (if the target exists)"
    L["OPTIONS_CAST_SHOW_TARGETNAME_TANK"] = "[Tank] Don't Show Your Name"
    L["OPTIONS_CAST_SHOW_TARGETNAME_TANK_DESC"] = "If you are a tank don't show the target name if the cast is on you."

    L["OPTIONS_THREAT_USE_SOLO_COLOR"] = "Solo Color"
    L["OPTIONS_THREAT_USE_SOLO_COLOR_ENABLE"] = "Use 'Solo' color"
    L["OPTIONS_THREAT_USE_SOLO_COLOR_DESC"] = "Use the 'Solo' color when not in a group."

    L["OPTIONS_THREAT_PULL_FROM_ANOTHER_TANK"] = "Pulling From Another Tank"
    L["OPTIONS_THREAT_PULL_FROM_ANOTHER_TANK_TANK"] = "The unit has aggro on another tank and you're about to pull it."

    L["OPTIONS_THREAT_CLASSIC_USE_TANK_COLORS"] = "Use Tank Threat Colors"

    L["OPTIONS_THREAT_USE_AGGRO_GLOW"] = "Enable aggro glow"
    L["OPTIONS_THREAT_USE_AGGRO_GLOW_DESC"] = "Enables the healthbar glow on the nameplates when gaining aggro as dps or losing aggro as tank."
    L["OPTIONS_THREAT_USE_AGGRO_FLASH"] = "Enable aggro flash"
    L["OPTIONS_THREAT_USE_AGGRO_FLASH_DESC"] = "Enables the -AGGRO- flash animation on the nameplates when gaining aggro as dps."
    
    L["OPTIONS_CASTBAR_ICON_CUSTOM_ENABLE"] = "Enable Icon Customization"
    L["OPTIONS_CASTBAR_ICON_CUSTOM_ENABLE_DESC"] = "If this option is disabled, Plater won't modify the spell icon, leaving it for scripts to do."
    L["OPTIONS_CASTBAR_NO_SPELLNAME_LIMIT"] = "No Spell Name Length Limitation"
    L["OPTIONS_CASTBAR_NO_SPELLNAME_LIMIT_DESC"] = "Spell name text won't be cut to fit within the cast bar width."
    L["OPTIONS_INTERRUPT_SHOW_AUTHOR"] = "Show Interrupt Author"
    L["OPTIONS_INTERRUPT_SHOW_ANIM"] = "Play Interrupt Animation"
    L["OPTIONS_INTERRUPT_FILLBAR"] = "Fill Cast Bar On Interrupt"
    L["OPTIONS_CASTBAR_QUICKHIDE"] = "Quick Hide Cast Bar"
    L["OPTIONS_CASTBAR_QUICKHIDE_DESC"] = "After the cast finishes, immediately hide the cast bar."
    L["OPTIONS_CASTBAR_HIDE_FRIENDLY"] = "Hide Friendly Cast Bar"
    L["OPTIONS_CASTBAR_HIDE_ENEMY"] = "Hide Enemy Cast Bar"
    L["OPTIONS_CASTBAR_TOGGLE_TEST"] = "Toggle Cast Bar Test"
    L["OPTIONS_CASTBAR_TOGGLE_TEST_DESC"] = "Start cast bar test, press again to stop."
    L["OPTIONS_ICON_SHOW"] = "Show Icon"
    L["OPTIONS_ICON_SIDE"] = "Show Side"
    L["OPTIONS_ICON_SIZE"] = "Show Size"
    L["OPTIONS_TEXTURE_BACKGROUND"] = "Background Texture"
    L["HIGHLIGHT_HOVEROVER"] = "Hover Over Highlight"
    L["HIGHLIGHT_HOVEROVER_ALPHA"] = "Hover Over Highlight Alpha"
    L["HIGHLIGHT_HOVEROVER_DESC"] = "Highlight effect when the mouse is over the nameplate."
    L["OPTIONS_ALPHA"] = "Alpha"
    L["OPTIONS_ALPHABYFRAME_ALPHAMULTIPLIER"] = "Transparency multiplier."
    L["OPTIONS_ALPHABYFRAME_DEFAULT"] = "Default Transparency"
    L["OPTIONS_ALPHABYFRAME_DEFAULT_DESC"] = "Amount of transparency applyed to all the components of a single nameplate."
    L["OPTIONS_ALPHABYFRAME_ENABLE_ENEMIES"] = "Enable For Enemies"
    L["OPTIONS_ALPHABYFRAME_ENABLE_ENEMIES_DESC"] = "Apply Transparency settings to enemy units."
    L["OPTIONS_ALPHABYFRAME_ENABLE_FRIENDLY"] = "Enable For Friendly"
    L["OPTIONS_ALPHABYFRAME_ENABLE_FRIENDLY_DESC"] = "Apply Transparency settings to friendly units."
    L["OPTIONS_ALPHABYFRAME_TARGET_INRANGE"] = "Target Alpha/In-Range"
    L["OPTIONS_ALPHABYFRAME_TARGET_INRANGE_DESC"] = "Transparency for targets or in-range units."
    L["OPTIONS_ALPHABYFRAME_TITLE_ENEMIES"] = "Transparency Amount Per Frame (enemies)"
    L["OPTIONS_ALPHABYFRAME_TITLE_FRIENDLY"] = "Transparency Amount Per Frame (friendly)"
    L["OPTIONS_AMOUNT"] = "Amount"
    L["OPTIONS_ANCHOR"] = "Anchor"
    L["OPTIONS_ANCHOR_BOTTOM"] = "Bottom"
    L["OPTIONS_ANCHOR_BOTTOMLEFT"] = "Bottom Left"
    L["OPTIONS_ANCHOR_BOTTOMRIGHT"] = "Bottom Right"
    L["OPTIONS_ANCHOR_CENTER"] = "Center"
    L["OPTIONS_ANCHOR_INNERBOTTOM"] = "Inner Bottom"
    L["OPTIONS_ANCHOR_INNERLEFT"] = "Inner Left"
    L["OPTIONS_ANCHOR_INNERRIGHT"] = "Inner Right"
    L["OPTIONS_ANCHOR_INNERTOP"] = "Inner Top"
    L["OPTIONS_ANCHOR_LEFT"] = "Left"
    L["OPTIONS_ANCHOR_RIGHT"] = "Right"
    L["OPTIONS_ANCHOR_TARGET_SIDE"] = "Which side this widget is attach to."
    L["OPTIONS_ANCHOR_TOP"] = "Top"
    L["OPTIONS_ANCHOR_TOPLEFT"] = "Top Left"
    L["OPTIONS_ANCHOR_TOPRIGHT"] = "Top Right"
    L["OPTIONS_AURA_DEBUFF_HEIGHT"] = "Debuff's icon height."
    L["OPTIONS_AURA_DEBUFF_WITH"] = "Debuff's icon width."
    L["OPTIONS_AURA_HEIGHT"] = "Debuff's icon height."
    L["OPTIONS_AURA_SHOW_BUFFS"] = "Show Buffs"
    L["OPTIONS_AURA_SHOW_BUFFS_DESC"] = "Show buffs on you on the Personal Bar."
    L["OPTIONS_AURA_SHOW_DEBUFFS"] = "Show Debuffs"
    L["OPTIONS_AURA_SHOW_DEBUFFS_DESC"] = "Show debuffs on you on the Personal Bar."
    L["OPTIONS_AURA_WIDTH"] = "Debuff's icon width."
    L["OPTIONS_AURAS_ENABLETEST"] = "Enable this to hide test auras shown when configuring."
    L["OPTIONS_AURAS_SORT"] = "Sort Auras"
    L["OPTIONS_AURAS_SORT_DESC"] = "Auras are sorted by time remaining (default)."
    L["OPTIONS_BACKGROUND_ALWAYSSHOW"] = "Always Show Background"
    L["OPTIONS_BACKGROUND_ALWAYSSHOW_DESC"] = "Enable a background showing the area of the clickable area."
    L["OPTIONS_BORDER_COLOR"] = "Border Color"
    L["OPTIONS_BORDER_THICKNESS"] = "Border Thickness"
    L["OPTIONS_BUFFFRAMES"] = "Buff Frames"
    L["OPTIONS_CANCEL"] = "Cancel"
    L["OPTIONS_CASTBAR_HEIGHT"] = "Height of the cast bar."
    L["OPTIONS_CASTBAR_HIDEBLIZZARD"] = "Hide Blizzard Player Cast Bar"
    L["OPTIONS_CASTBAR_WIDTH"] = "Width of the cast bar."
    L["OPTIONS_CLICK_SPACE_HEIGHT"] = "The height of the are area which accepts mouse clicks to select the target"
    L["OPTIONS_CLICK_SPACE_WIDTH"] = "The width of the are area which accepts mouse clicks to select the target"
    L["OPTIONS_COLOR"] = "Color"
    L["OPTIONS_CVAR_ENABLE_PERSONAL_BAR"] = "Personal Health and Mana Bars|cFFFF7700*|r"
    L["OPTIONS_CVAR_ENABLE_PERSONAL_BAR_DESC"] = [=[Shows a mini health and mana bars under your character.
    
    |cFFFF7700[*]|r |cFFa0a0a0CVar, saved within Plater profile and restored when loading the profile.|r]=]
    L["OPTIONS_CVAR_NAMEPLATES_ALWAYSSHOW"] = "Always Show Nameplates|cFFFF7700*|r"
    L["OPTIONS_CVAR_NAMEPLATES_ALWAYSSHOW_DESC"] = [=[Show nameplates for all units near you. If disabled only show relevant units when you are in combat.
    
    |cFFFF7700[*]|r |cFFa0a0a0CVar, saved within Plater profile and restored when loading the profile.|r]=]
    L["OPTIONS_ENABLED"] = "Enabled"
    L["OPTIONS_ERROR_CVARMODIFY"] = "cvars cannot be changed while in combat."
    L["OPTIONS_ERROR_EXPORTSTRINGERROR"] = "failed to export"
    L["OPTIONS_EXECUTERANGE"] = "Execute Range"
    L["OPTIONS_EXECUTERANGE_DESC"] = [=[Show an indicator when the target unit is in 'execute' range.
    
    If the detection does not work after a patch, communicate at Discord.]=]
    L["OPTIONS_EXECUTERANGE_HIGH_HEALTH"] = "Execute Range (high heal)"
    L["OPTIONS_EXECUTERANGE_HIGH_HEALTH_DESC"] = [=[Show the execute indicator for the high portion of the health.
    
    If the detection does not work after a patch, communicate at Discord.]=]
    L["OPTIONS_FONT"] = "Font"
    L["OPTIONS_FORMAT_NUMBER"] = "Number Format"
    L["OPTIONS_FRIENDLY"] = "Friendly"
    L["OPTIONS_GENERALSETTINGS_HEALTHBAR_ANCHOR_TITLE"] = "Health Bar Appearance"
    L["OPTIONS_GENERALSETTINGS_HEALTHBAR_BGCOLOR"] = "Health Bar Background Color and Alpha"
    L["OPTIONS_GENERALSETTINGS_HEALTHBAR_BGTEXTURE"] = "Health Bar Background Texture"
    L["OPTIONS_GENERALSETTINGS_HEALTHBAR_TEXTURE"] = "Health Bar Texture"
    L["OPTIONS_GENERALSETTINGS_TRANSPARENCY_ANCHOR_TITLE"] = "Transparency Is Used For"
    L["OPTIONS_GENERALSETTINGS_TRANSPARENCY_RANGECHECK"] = "Range Check"
    L["OPTIONS_GENERALSETTINGS_TRANSPARENCY_RANGECHECK_ALPHA"] = "Alpha"
    L["OPTIONS_GENERALSETTINGS_TRANSPARENCY_RANGECHECK_SPEC_DESC"] = "Spell to range check on this specializartion."
    L["OPTIONS_HEALTHBAR"] = "Health Bar"
    L["OPTIONS_HEALTHBAR_HEIGHT"] = "Health Bar Height"
    L["OPTIONS_HEALTHBAR_SIZE_GLOBAL_DESC"] = [=[Change the size of Enemy and Friendly nameplates for players and npcs in combat and out of combat.
    
    Each one of these options can be changed individually on Enemy Npc, Enemy Player tabs.]=]
    L["OPTIONS_HEALTHBAR_WIDTH"] = "Health Bar Width"
    L["OPTIONS_HEIGHT"] = "Height"
    L["OPTIONS_HOSTILE"] = "Hostile"
    L["OPTIONS_ICON_ELITE"] = "Elite Icon"
    L["OPTIONS_ICON_ENEMYCLASS"] = "Enemy Class Icon"
    L["OPTIONS_ICON_ENEMYFACTION"] = "Enemy Faction Icon"
    L["OPTIONS_ICON_ENEMYSPEC"] = "Enemy Spec Icon"
    L["OPTIONS_ICON_FRIENDLY_SPEC"] = "Friendly Spec Icon"
    L["OPTIONS_ICON_FRIENDLYCLASS"] = "Friendly Class"
    L["OPTIONS_ICON_FRIENDLYFACTION"] = "Friendly Faction Icon"
    L["OPTIONS_ICON_PET"] = "Pet Icon"
    L["OPTIONS_ICON_QUEST"] = "Quest Icon"
    L["OPTIONS_ICON_RARE"] = "Rare Icon"
    L["OPTIONS_ICON_WORLDBOSS"] = "World Boss Icon"
    L["OPTIONS_ICONROWSPACING"] = "Icon Row Spacing"
    L["OPTIONS_ICONSPACING"] = "Icon Spacing"
    L["OPTIONS_INDICATORS"] = "Indicators"
    L["OPTIONS_INTERACT_OBJECT_NAME_COLOR"] = "Game object name color"
    L["OPTIONS_INTERACT_OBJECT_NAME_COLOR_DESC"] = "Names on objects will get this color."
    L["OPTIONS_MINOR_SCALE_DESC"] = "Slightly adjust the size of nameplates when showing a minor unit (these units has a smaller nameplate by default)."
    L["OPTIONS_MINOR_SCALE_HEIGHT"] = "Minor Unit Height Scale"
    L["OPTIONS_MINOR_SCALE_WIDTH"] = "Minor Unit Width Scale"
    L["OPTIONS_MOVE_HORIZONTAL"] = "Move horizontally."
    L["OPTIONS_MOVE_VERTICAL"] = "Move vertically."
    L["OPTIONS_NAMEPLATE_HIDE_FRIENDLY_HEALTH"] = "Hide Blizzard Health Bars|cFFFF7700*|r"
    L["OPTIONS_NAMEPLATE_HIDE_FRIENDLY_HEALTH_DESC"] = [=[While in dungeons or raids, if friendly nameplates are enabled it'll show only the player name.
    If any Plater module is disabled, this will affect these nameplates as well.
    
    |cFFFF7700[*]|r |cFFa0a0a0CVar, saved within Plater profile and restored when loading the profile.|r
    
    |cFFFF2200[*]|r |cFFa0a0a0A /reload may be required to take effect.|r]=]
    L["OPTIONS_NAMEPLATE_OFFSET"] = "Slightly adjust the entire nameplate."
    L["OPTIONS_NAMEPLATE_SHOW_ENEMY"] = "Show Enemy Nameplates|cFFFF7700*|r"
    L["OPTIONS_NAMEPLATE_SHOW_ENEMY_DESC"] = [=[Show nameplate for enemy and neutral units.
    
    |cFFFF7700[*]|r |cFFa0a0a0CVar, saved within Plater profile and restored when loading the profile.|r]=]
    L["OPTIONS_NAMEPLATE_SHOW_FRIENDLY"] = "Show Friendly Nameplates|cFFFF7700*|r"
    L["OPTIONS_NAMEPLATE_SHOW_FRIENDLY_DESC"] = [=[Show nameplate for friendly players.
    
    |cFFFF7700[*]|r |cFFa0a0a0CVar, saved within Plater profile and restored when loading the profile.|r]=]
    L["OPTIONS_NAMEPLATES_OVERLAP"] = "Nameplate Overlap (V)|cFFFF7700*|r"
    L["OPTIONS_NAMEPLATES_OVERLAP_DESC"] = [=[The space between each nameplate vertically when stacking is enabled.
    
    |cFFFFFFFFDefault: 1.10|r
    
    |cFFFF7700[*]|r |cFFa0a0a0CVar, saved within Plater profile and restored when loading the profile.|r
    
    |cFFFFFF00Important |r: if you find issues with this setting, use:
    |cFFFFFFFF/run SetCVar ('nameplateOverlapV', '1.6')|r]=]
    L["OPTIONS_NAMEPLATES_STACKING"] = "Stacking Nameplates|cFFFF7700*|r"
    L["OPTIONS_NAMEPLATES_STACKING_DESC"] = [=[If enabled, nameplates won't overlap with each other.
    
    |cFFFF7700[*]|r |cFFa0a0a0CVar, saved within Plater profile and restored when loading the profile.|r
    
    |cFFFFFF00Important |r: to set the amount of space between each nameplate see '|cFFFFFFFFNameplate Vertical Padding|r' option below.
    Please check the Auto tab settings to setup automatic toggling of this option.]=]
    L["OPTIONS_NEUTRAL"] = "Neutral"
    L["OPTIONS_NOCOMBATALPHA_AMOUNT_DESC"] = "Amount of transparency for 'No Combat Alpha'."
    L["OPTIONS_NOCOMBATALPHA_ENABLED"] = "Use No Combat Alpha"
    L["OPTIONS_NOCOMBATALPHA_ENABLED_DESC"] = [=[Changes the nameplate alpha when you are in combat and the unit isn't.
    
    |cFFFFFF00 Important |r:If the unit isn't in combat, it overrides the alpha from the range check.]=]
    L["OPTIONS_OKAY"] = "Okay"
    L["OPTIONS_OUTLINE"] = "Outline"
    L["OPTIONS_PERSONAL_HEALTHBAR_HEIGHT"] = "Height of the health bar."
    L["OPTIONS_PERSONAL_HEALTHBAR_WIDTH"] = "Width of the health bar."
    L["OPTIONS_PERSONAL_SHOW_HEALTHBAR"] = "Show health bar."
    L["OPTIONS_PET_SCALE_DESC"] = "Slightly adjust the size of nameplates when showing a pet"
    L["OPTIONS_PET_SCALE_HEIGHT"] = "Pet Height Scale"
    L["OPTIONS_PET_SCALE_WIDTH"] = "Pet Width Scale"
    L["OPTIONS_PLEASEWAIT"] = "This may take only a few seconds"
    L["OPTIONS_POWERBAR"] = "Power Bar"
    L["OPTIONS_POWERBAR_HEIGHT"] = "Height of the power bar."
    L["OPTIONS_POWERBAR_WIDTH"] = "Width of the power bar."
    L["OPTIONS_PROFILE_CONFIG_EXPORTINGTASK"] = "Plater is exporting the current profile"
    L["OPTIONS_PROFILE_CONFIG_EXPORTPROFILE"] = "Share Profile"
    L["OPTIONS_PROFILE_CONFIG_IMPORTPROFILE"] = "Import Profile"
    L["OPTIONS_PROFILE_CONFIG_MOREPROFILES"] = "Get more profiles at Wago.io"
    L["OPTIONS_PROFILE_CONFIG_OPENSETTINGS"] = "Open Profile Settings"
    L["OPTIONS_PROFILE_CONFIG_PROFILENAME"] = "New Profile Name"
    L["OPTIONS_PROFILE_CONFIG_PROFILENAME_DESC"] = [=[A new profile is created with the imported string.
    
    Inserting the name of a profile that already exists will overwrite it.]=]
    L["OPTIONS_PROFILE_ERROR_PROFILENAME"] = "Invalid profile name"
    L["OPTIONS_PROFILE_ERROR_STRINGINVALID"] = "Invalid profile file."
    L["OPTIONS_PROFILE_ERROR_WRONGTAB"] = [=[Invalid profile data.
    
    Import scripts or mods at the scripting or modding tab.]=]
    L["OPTIONS_PROFILE_IMPORT_OVERWRITE"] = "Profile '%s' already exists, overwrite it?"
    L["OPTIONS_RANGECHECK_NONE"] = "Nothing"
    L["OPTIONS_RANGECHECK_NONE_DESC"] = "No alpha modifications is applyed."
    L["OPTIONS_RANGECHECK_NOTMYTARGET"] = "Units Which Isn't Your Target"
    L["OPTIONS_RANGECHECK_NOTMYTARGET_DESC"] = "When a nameplate isn't your current target, alpha is reduced."
    L["OPTIONS_RANGECHECK_NOTMYTARGETOUTOFRANGE"] = "Out of Range + Isn't Your Target"
    L["OPTIONS_RANGECHECK_NOTMYTARGETOUTOFRANGE_DESC"] = [=[Reduces the alpha of units which isn't your target.
    Reduces even more if the unit is out of range.]=]
    L["OPTIONS_RANGECHECK_OUTOFRANGE"] = "Units Out of Your Range"
    L["OPTIONS_RANGECHECK_OUTOFRANGE_DESC"] = "When a nameplate is out of range, alpha is reduced."
    L["OPTIONS_RESOURCES_TARGET"] = "Show Resources on Target"
    L["OPTIONS_RESOURCES_TARGET_DESC"] = [=[Shows your resource such as combo points above your current target.
    Uses Blizzard default resources and disables Platers own resources.
    
    Character specific setting!]=]
    L["OPTIONS_SCALE"] = "Scale"
    L["OPTIONS_SCRIPTING_REAPPLY"] = "Re-Apply Default Values"
    L["OPTIONS_SCRIPTING_ADDOPTION"] = "Select which option to add"
    L["OPTIONS_SETTINGS_COPIED"] = "settings copied."
    L["OPTIONS_SETTINGS_FAIL_COPIED"] = "failed to get the settings for the current selected tab."
    L["OPTIONS_SHADOWCOLOR"] = "Shadow Color"
    L["OPTIONS_SHIELD_BAR"] = "Shield Bar"
    L["OPTIONS_SHOW_CASTBAR"] = "Show cast bar"
    L["OPTIONS_SHOW_POWERBAR"] = "Show power bar"
    L["OPTIONS_SHOWTOOLTIP"] = "Show Tooltip"
    L["OPTIONS_SHOWTOOLTIP_DESC"] = "Show tooltip when hovering over the aura icon."
    L["OPTIONS_SIZE"] = "Size"
    L["OPTIONS_STACK_AURATIME"] = "Show shortest time of stacked auras"
    L["OPTIONS_STACK_AURATIME_DESC"] = "Show shortest time of stacked auras or the longes time, when disabled."
    L["OPTIONS_STACK_SIMILAR_AURAS"] = "Stack Similar Auras"
    L["OPTIONS_STACK_SIMILAR_AURAS_DESC"] = "Auras with the same name (e.g. warlock's unstable affliction debuff) get stacked together."
    L["OPTIONS_STATUSBAR_TEXT"] = "Import profiles, mods, scripts, animations and color tables from |cFFFFAA00http://wago.io|r"
    L["OPTIONS_TABNAME_ADVANCED"] = "Advanced"
    L["OPTIONS_TABNAME_ANIMATIONS"] = "Spell Feedback"
    L["OPTIONS_TABNAME_AUTO"] = "Auto"
    L["OPTIONS_TABNAME_BUFF_LIST"] = "Spell List"
    L["OPTIONS_TABNAME_BUFF_SETTINGS"] = "Buff Settings"
    L["OPTIONS_TABNAME_BUFF_SPECIAL"] = "Buff Special"
    L["OPTIONS_TABNAME_BUFF_TRACKING"] = "Buff Tracking"
    L["OPTIONS_TABNAME_CASTBAR"] = "Cast Bar"
    L["OPTIONS_TABNAME_CASTCOLORS"] = "Cast Colors and Names"
    L["OPTIONS_TABNAME_COMBOPOINTS"] = "Combo Points"
    L["OPTIONS_TABNAME_GENERALSETTINGS"] = "General Settings"
    L["OPTIONS_TABNAME_MODDING"] = "Modding"
    L["OPTIONS_TABNAME_NPC_COLORNAME"] = "Npc Colors and Names"
    L["OPTIONS_TABNAME_NPCENEMY"] = "Enemy Npc"
    L["OPTIONS_TABNAME_NPCFRIENDLY"] = "Friendly Npc"
    L["OPTIONS_TABNAME_PERSONAL"] = "Personal Bar"
    L["OPTIONS_TABNAME_PLAYERENEMY"] = "Enemy Player"
    L["OPTIONS_TABNAME_PLAYERFRIENDLY"] = "Friendly Player"
    L["OPTIONS_TABNAME_PROFILES"] = "Profiles"
    L["OPTIONS_TABNAME_SCRIPTING"] = "Scripting"
    L["OPTIONS_TABNAME_SEARCH"] = "Search"
    L["OPTIONS_TABNAME_STRATA"] = "Level & Strata"
    L["OPTIONS_TABNAME_TARGET"] = "Target"
    L["OPTIONS_TABNAME_THREAT"] = "Colors / Threat"
    L["OPTIONS_TEXT_COLOR"] = "The color of the text."
    L["OPTIONS_TEXT_FONT"] = "Font of the text."
    L["OPTIONS_TEXT_SIZE"] = "Size of the text."
    L["OPTIONS_TEXTURE"] = "Texture"
    L["OPTIONS_THREAT_AGGROSTATE_ANOTHERTANK"] = "Aggro on Another Tank"
    L["OPTIONS_THREAT_AGGROSTATE_HIGHTHREAT"] = "High Threat"
    L["OPTIONS_THREAT_AGGROSTATE_NOAGGRO"] = "No Aggro"
    L["OPTIONS_THREAT_AGGROSTATE_NOTANK"] = "No Tank Aggro"
    L["OPTIONS_THREAT_AGGROSTATE_NOTINCOMBAT"] = "Unit Not in Combat"
    L["OPTIONS_THREAT_AGGROSTATE_ONYOU_LOWAGGRO"] = "Aggro on You But is Low"
    L["OPTIONS_THREAT_AGGROSTATE_ONYOU_LOWAGGRO_DESC"] = "The unit is attacking you but others are about to pull the aggro."
    L["OPTIONS_THREAT_AGGROSTATE_ONYOU_SOLID"] = "Aggro on You"
    L["OPTIONS_THREAT_AGGROSTATE_TAPPED"] = "Unit Tapped"
    L["OPTIONS_THREAT_COLOR_DPS_ANCHOR_TITLE"] = "Color When Playing as DPS or HEALER"
    L["OPTIONS_THREAT_COLOR_DPS_HIGHTHREAT_DESC"] = "The unit is about to start attacking you."
    L["OPTIONS_THREAT_COLOR_DPS_NOAGGRO_DESC"] = "The unit isn't attacking you."
    L["OPTIONS_THREAT_COLOR_DPS_NOTANK_DESC"] = "The unit isn't attacking you or a tank and most likely is attacking another healer or dps from your group."
    L["OPTIONS_THREAT_COLOR_DPS_ONYOU_SOLID_DESC"] = "The unit is attacking you."
    L["OPTIONS_THREAT_COLOR_OVERRIDE_ANCHOR_TITLE"] = "Override Default Colors"
    L["OPTIONS_THREAT_COLOR_OVERRIDE_DESC"] = [=[Modify the default colors set by the game for neutral, hostile and friendly units.
    
    During combat, these colors will be override as well if threat colors are allowed to change health bar color.]=]
    L["OPTIONS_THREAT_COLOR_TANK_ANCHOR_TITLE"] = "Color When Playing as TANK"
    L["OPTIONS_THREAT_COLOR_TANK_ANOTHERTANK_DESC"] = "The unit is being tanked by another tank in your group."
    L["OPTIONS_THREAT_COLOR_TANK_NOAGGRO_DESC"] = "The unit does not have aggro on you."
    L["OPTIONS_THREAT_COLOR_TANK_NOTINCOMBAT_DESC"] = "The unit isn't in combat."
    L["OPTIONS_THREAT_COLOR_TANK_ONYOU_SOLID_DESC"] = "The unit is attacking you and you have solid aggro."
    L["OPTIONS_THREAT_COLOR_TAPPED_DESC"] = "When someone else has claimed the unit (when you don't receive experience or loot for killing it)."
    L["OPTIONS_THREAT_DPS_CANCHECKNOTANK"] = "Check for No Tank Aggro"
    L["OPTIONS_THREAT_DPS_CANCHECKNOTANK_DESC"] = "When you don't have aggro as healer or dps, check if the enemy is attacking another unit that isn't a tank."
    L["OPTIONS_THREAT_MODIFIERS_ANCHOR_TITLE"] = "Threat Modifies"
    L["OPTIONS_THREAT_MODIFIERS_BORDERCOLOR"] = "Border Color"
    L["OPTIONS_THREAT_MODIFIERS_HEALTHBARCOLOR"] = "Health Bar Color"
    L["OPTIONS_THREAT_MODIFIERS_NAMECOLOR"] = "Name Color"
    L["OPTIONS_TOGGLE_TO_CHANGE"] = "|cFFFFFF00 Important |r: hide and show nameplates to see changes."
    L["OPTIONS_WIDTH"] = "Width"
    L["OPTIONS_XOFFSET"] = "X Offset"
    L["OPTIONS_XOFFSET_DESC"] = [=[Adjust the position on the X axis.
    
    *right click to type the value.]=]
    L["OPTIONS_YOFFSET"] = "Y Offset"
    L["OPTIONS_YOFFSET_DESC"] = [=[Adjust the position on the Y axis.
    
    *right click to type the value.]=]
    L["TARGET_CVAR_ALWAYSONSCREEN"] = "Target Always on the Screen|cFFFF7700*|r"
    L["TARGET_CVAR_ALWAYSONSCREEN_DESC"] = [=[When enabled, the nameplate of your target is always shown even when the enemy isn't in the screen.
    
    |cFFFF7700[*]|r |cFFa0a0a0CVar, saved within Plater profile and restored when loading the profile.|r]=]
    L["TARGET_CVAR_LOCKTOSCREEN"] = "Lock to Screen (Top Side)|cFFFF7700*|r"
    L["TARGET_CVAR_LOCKTOSCREEN_DESC"] = [=[Min space between the nameplate and the top of the screen. Increase this if some part of the nameplate are going out of the screen.
    
    |cFFFFFFFFDefault: 0.065|r
    
    |cFFFFFF00 Important |r: if you're having issue, manually set using these macros:
    /run SetCVar ('nameplateOtherTopInset', '0.065')
    /run SetCVar ('nameplateLargeTopInset', '0.065')
    
    |cFFFFFF00 Important |r: setting to 0 disables this feature.
    
    |cFFFF7700[*]|r |cFFa0a0a0CVar, saved within Plater profile and restored when loading the profile.|r]=]
    L["TARGET_HIGHLIGHT"] = "Target Highlight"
    L["TARGET_HIGHLIGHT_ALPHA"] = "Target Highlight Alpha"
    L["TARGET_HIGHLIGHT_COLOR"] = "Target Highlight Color"
    L["TARGET_HIGHLIGHT_DESC"] = "Highlight effect on the nameplate of your current target."
    L["TARGET_HIGHLIGHT_SIZE"] = "Target Highlight Size"
    L["TARGET_HIGHLIGHT_TEXTURE"] = "Target Highlight Texture"
    L["TARGET_OVERLAY_ALPHA"] = "Target Overlay Alpha"
    L["TARGET_OVERLAY_TEXTURE"] = "Target Overlay Texture"
    L["TARGET_OVERLAY_TEXTURE_DESC"] = "Used above the health bar when it is the current target."


------------------------------------------------------------
--@localization(locale="enUS", format="lua_additive_table")@
end
