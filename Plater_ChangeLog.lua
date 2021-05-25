


local Plater = Plater or {} -- for build execution
local _

function Plater.GetChangelogTable()
	if (not Plater.ChangeLogTable) then
		Plater.ChangeLogTable = {
		
			{1621969166,  "Bug Fix", "May 25th, 2021", "Updating 'Attacking Specific Unit' mod with Cardboard Assassin NPC.", "michaelbull"},
			
			{1621935367,  "Bug Fix", "May 25th, 2021", "Alpha of non-targets should now work correctly again.", "cont1nuity"},
			{1621935367,  "Backend Change", "May 25th, 2021", "Enabling execute range indicator for warriors in TBC.", "cont1nuity"},
			{1621935367,  "Bug Fix", "May 25th, 2021", "'Combo Points' mod now handles targeted combo points correctly in TBC.", "cont1nuity"},
			
			{1621880868,  "Bug Fix", "May 24th, 2021", "Hiding unavailable options on TBC client.", "Terciob"},
			{1621880868,  "Backend Change", "May 23rd, 2021", "'Target always on screen' will now keep it on screen on top side as well.", "cont1nuity"},
			{1621880868,  "New Feature", "May 20th, 2021", "Adding option to show healthbars for not attackable units (npcs and players).", "cont1nuity"},
			{1621880868,  "Bug Fix", "May 20th, 2021", "Hiding 'Personal Bar' options in classic.", "cont1nuity"},
			{1621880868,  "Bug Fix", "May 19th, 2021", "Fixing mod load conditions and 'Combo Points [Plater]' mod.", "cont1nuity"},
			{1621880868,  "Backend Change", "May 19th, 2021", "Adding support for Questie quest tracking.", "cont1nuity"},
			{1621880868,  "Backend Change", "May 19th, 2021", "Support for 'nameplateNotSelectedAlpha' (defaults to 1 for compatibility).", "cont1nuity"},
			{1621880868,  "Backend Change", "May 18th, 2021", "Support for Burning Crusade Classic client.", "cont1nuity"},
			{1621880868,  "Bug Fix", "May 17th, 2021", "Fixing wrong frame alignment of version text in the options panel.", "cont1nuity"},
			{1621880868,  "Bug Fix", "May 12th, 2021", "Fixing non-existant tanks leading to erros during threat checks.", "cont1nuity"},
			{1621880868,  "New Feature", "May 10th, 2021", "Adding option to show either shortest or longest duration of stacked aura.", "cont1nuity"},
			{1621880868,  "Bug Fix", "May 10th, 2021", "Consolidate similar auras by texture and name instead of texture only.", "cont1nuity"},
			{1621880868,  "Backend Change", "May 7th, 2021", "Keeping default mod/script enabled state after updates.", "cont1nuity"},
			{1621880868,  "Bug Fix", "May 7th, 2021", "Updating 'Attacking Specific Unit' mod with color resets, border coloring and options.", "cont1nuity"},
			{1621880868,  "New Feature", "May 5th, 2021", "Allowing to enable/disable specific Actor Types and chose between Plater or Blizzard nameplates.", "cont1nuity"},
			{1621880868,  "Backend Change", "May 2nd, 2021", "Buff Special tracking is now working with aura names.", "cont1nuity"},
			
			{1619548649,  "Backend Change", "April 26th, 2021", "Adding 'namePlateThreatOffTankIsTanking' and 'namePlateThreatOffTankName' fields.", "cont1nuity"},
			{1619548649,  "Backend Change", "April 23rd, 2021", "Code cleanup for BG/Arena player information.", "cont1nuity"},
			{1619548649,  "Bug Fix", "April 21st, 2021", "Fixing several default script visual effects.", "cont1nuity"},
			{1619548649,  "Backend Change", "April 21st, 2021", "Updating locked API.", "cont1nuity"},
			{1619548649,  "Backend Change", "April 21st, 2021", "Profiling is now correctly disabled.", "cont1nuity"},
			{1619548649,  "Backend Change", "April 21st, 2021", "Fixing global leak.", "cont1nuity"},
			{1619548649,  "Backend Change", "April 11th, 2021", "Allowing 'UpdateLevelTextAndColor' again.", "cont1nuity"},
		
			{1617654022,  "Bug Fix", "April 2nd, 2021", "Fixing non-existing tanks during threat checks.", "cont1nuity"},
			{1617654022,  "Bug Fix", "Arpil 1st, 2021", "Fixing default friendly range check ranges for low level chars.", "cont1nuity"},
			{1617654022,  "Bug Fix", "March 29th, 2021", "Ensure personal bar color is updated properly.", "cont1nuity"},
			{1617654022,  "New Feature", "March 25th, 2021", "Adding profiling actions to LDB-Icon.", "cont1nuity"},
			{1617654022,  "Bug Fix", "March 25th, 2021", "Sanity checks for profiling data.", "cont1nuity"},
			{1617654022,  "Bug Fix", "March 25th, 2021", "Fixing profiling for range check.", "cont1nuity"},
			{1617654022,  "Bug Fix", "March 24th, 2021", "Fixing BG player role info cache.", "xeropresence"},
			{1617654022,  "Backend Changes", "March 23rd, 2021", "Adjusting frame levels to allow better overlapping of different nameplates.", "cont1nuity"},
			{1617654022,  "Bug Fix", "March 23rd, 2021", "Fixing the 'Pins' indicator size.", "cont1nuity"},
			{1617654022,  "Backend Changes", "March 23rd, 2021", "Adjusted the health-/castbar border draw layers.", "cont1nuity"},
			{1617654022,  "Backend Changes", "March 22nd, 2021", "Changed the mod/script code restrictions.", "cont1nuity"},
			
			{1616411319,  "Backend Changes", "March 21st, 2021", "Adjust healthbar / castbar border frame levels."},
			{1616411319,  "Backend Changes", "March 19th, 2021", "Get spec-information in arena and BG."},
			{1616411319,  "Bug Fix", "March 18th, 2021", "Fixing an issue with aura consolidation disabled not showing all auras properly."},
			{1616411319,  "Bug Fix", "March 17th, 2021", "Fixing perfomance logging for health update."},
			{1616411319,  "Backend Changes", "March 15th, 2021", "Resetting colors upon nameplate added."},
			{1616411319,  "Bug Fix", "March 10th, 2021", "Fixing tracking/untracking via spellID."},
			{1616411319,  "Backend Changes", "March 9th, 2021", "Toc update."},
			{1616411319,  "Backend Changes", "March 8rd, 2021", "Updating target indicators to better scale with bars."},
			{1616411319,  "Backend Changes", "March 1st, 2021", "Hide list options scroll frame if unused."},
			{1616411319,  "Backend Changes", "February 27th, 2021", "Add 'Plater.GetUnitBGInfo(unit)' to access BG player score board information. (xeropresence)"},
		
			{1614264576,  "Bug Fix", "February 25th, 2021", "Fixing minimap icon right-click menu."},
			{1614264576,  "Backend Changes", "February 25th, 2021", "Changed the way aura icon border colors are priotized."},
			{1614264576,  "Bug Fix", "February 25th, 2021", "Fixing Buff Special icon border not showing properly for offensive and devensive CDs."},
			
			{1614089754,  "Backend Changes", "February 21st, 2021", "Plater options menu now opens on higher layer."},
			{1614089754,  "Bug Fix", "February 21st, 2021", "Fixing aura icon row offset for bottom anchors."},
			{1614089754,  "Options Changes", "February 20th, 2021", "New text outline options: 'Monochrome Outline' and 'Monochrome Thick Outline'."},
			{1614089754,  "New Feature", "February 9th, 2021", "Adding 'List' type options for mods/scripts."},
			{1614089754,  "Bug Fix", "February 9th, 2021", "Quest color setting should now be applied more thorough."},
			{1614089754,  "New Feature", "February 8th, 2021", "Buff Tracking now accepts spellID and names for dedicated or global buff/debuff track- and blocklists in auto-mode."},
			{1614089754,  "Backend Changes", "February 7th, 2021", "Hide names in 'Widget Only' mode."},
			{1614089754,  "Backend Changes", "February 6th, 2021", "Less frequent updates to hide healthbars to mitigate unwanted side-effects."},
			{1614089754,  "Bug Fix", "February 3rd, 2021", "'NameplateInRange' works properly with internal range checking now."},
			{1614089754,  "Options Changes", "February 2nd, 2021", "When configuring cast icon to be on the side, show a shield icon instead of border texture."},
			{1614089754,  "New Feature", "February 2nd, 2021", "Adding Button to open Plater options panel from interface options menu."},
			{1614089754,  "New Feature", "February 2nd, 2021", "Adding '/plater' command usage output."},
			{1614089754,  "New Feature", "February 2nd, 2021", "Adding support for LDB and LDBIcon with Minimap-Icon to open Plater options menu."},
			
			{1612172218,  "Bug Fix", "January 12th, 2021", "Fixing an issue with the Blink Time Left script glow feature."},
			{1612172218,  "Revamp", "January 12th, 2021", "Update for the M+ Spiteful script."},
			{1612172218,  "Options Changes", "January 12th, 2021", "Quest Tracking and Quest Coloring are now separated."},
			{1612172218,  "Bug Fix", "January 12th, 2021", "Fixing CCs not showing for auto-tracking."},
			{1612172218,  "Backend Changes", "January 12th, 2021", "Updated / fixed Plater Profiling"},
			{1612172218,  "Options Changes", "January 12th, 2021", "Adding Level & Strata options for Buff Special"},
			{1612172218,  "Options Changes", "January 12th, 2021", "Adding class/spec/faction indicators for friendly units."},
			{1612172218,  "Bug Fix", "January 12th, 2021", "Global healthbar size settings won't be reset when importing or switching profiles."},
			{1612172218,  "Backend Changes", "January 10th, 2021", "Fetching Class/Spec Icon indicators from BG/Arena info if available."},
			
			{1610229480,  "Options Changes", "January 8th, 2021", "Adding option for horizontal nameplate overlap and renaming options."},
			{1610229480,  "Bug Fix", "January 8th, 2021", "Fixing an issue with mod/script load conditions not tracking spec properly."},
			{1610229480,  "Bug Fix", "January 8th, 2021", "Fixing an issue with Buff Special stacks not showing under some conditions."},
			{1610229480,  "Bug Fix", "January 7th, 2021", "Adding glyphed Hex spells to CC (@Freddy090909)."},
			{1610229480,  "Bug Fix", "January 6th, 2021", "Updating clickable area sizes when closing game menus."},
			{1610229480,  "Bug Fix", "January 4th, 2021", "Fixing aura show animation breaking timer and stack text size."},
			{1610229480,  "Bug Fix", "January 2nd, 2021", "Fixing an issue with mod/script options when duplicating mods/scripts."},
			{1610229480,  "Bug Fix", "January 1st, 2021", "Fixing some typos."},
			{1610229480,  "Bug Fix", "December 31th, 2020", "Another round of fixes for nameplate widgets."},
			{1610229480,  "Bug Fix", "December 31th, 2020", "CCs should now be probably tracked again with auto-tracking."},
			{1610229480,  "New Feature", "December 30th, 2020", "Update to 'Spiteful' script."},
			{1610229480,  "Bug Fix", "December 30th, 2020", "Fixing leftover execute indicators on friendly units."},
		
			{1608853110,  "New Feature", "December 24th, 2020", "Added a time to die to Spiteful affix units."},
			{1608853110,  "Revamp", "December 24th, 2020", "Aura reorder mod has been refreshed."},

			{1608659820,  "Bug Fix", "December 17th, 2020", "Updating texts after nameplate size updates to ensure proper length."},
			{1608659820,  "Bug Fix", "December 12th, 2020", "Ensure proper size of the execute indicator."},
			{1608659820,  "Backend Changes", "December 9th, 2020", "Not showing execute indicator on not attackable units."},
			{1608659820,  "Bug Fix", "December 8th, 2020", "Fixing issue with double Buff Special."},
			{1608659820,  "Options Changes", "December 4th, 2020", "Adding 'Auras per Row' option for Buff Frame 2."},
			{1608659820,  "Backend Changes", "December 4th, 2020", "Reworked CVar re-/storing."},
			{1608659820,  "Bug Fix", "December 4th, 2020", "Global width/height settings are stored and adjusted separately."},
			{1608659820,  "Bug Fix", "December 1st, 2020", "Honoring Personal Bar buff tracking settings."},

			{1606569932,  "Bug Fix", "November 28th, 2020", "Fixing Condemn (Venthyr) execute for warriors."},
			{1606569932,  "Bug Fix", "November 27th, 2020", "Fixing 'Unit - Health Markers' script."},
			{1606569932,  "Bug Fix", "November 26th, 2020", "Enabling Focus Alpha now behaves properly with no targets."},
			{1606569932,  "Bug Fix", "November 25th, 2020", "Fixing nameplate widgets."},
			{1606569932,  "Bug Fix", "November 25th, 2020", "Fixing error around UnitMaxHealth."},
			
			
			{1605897389,  "New Feature", "November 20th, 2020", "Adding '/plater profstart|profstop|profprint' commands for mod/script profiling."},
			{1605897389,  "Backend Changes", "November 18th, 2020", "Changes to mod/script execution environment."},
			{1605897389,  "New Feature", "November 17th, 2020", "Adding '/plater rare' command to blink taskbar icon on rare spawn."},
			{1605897389,  "Bug Fix", "November 16th, 2020", "Fixing several issues around consistent mod/script code execution."},
			{1605897389,  "New Feature", "November 16th, 2020", "Adding option to use LibTranslit to translit russian names."},
			{1605897389,  "Backend Changes", "November 15th, 2020", "Adding Soul Reaper (DK talent) to execute indicator."},
			{1605897389,  "Bug Fix", "November 14th, 2020", "Fixing an issue with health text options not applying properly."},

			{1605124078,  "Backend Changes", "November 10th, 2020", "Adding missing textures."},
			{1605124078,  "Backend Changes", "November 10th, 2020", "Small fixes on aura animations."},
			{1605124078,  "Options Changes", "November 10th, 2020", "Adding 'auras per row' overwrite option."},
			{1605124078,  "Backend Changes", "November 10th, 2020", "Regression fix for not correctly loaded scripts."},
			{1605124078,  "Backend Changes", "November 10th, 2020", "Make aura rows grow in the proper directions according to the selected anchor position."},
			{1605124078,  "Backend Changes", "November 10th, 2020", "Enable tooltips on buff special."},
			{1605124078,  "Backend Changes", "November 10th, 2020", "Supress blizzard timers on buff special."},
			{1605124078,  "Options Changes", "November 10th, 2020", "Adding buff special text outline options."},
			{1605124078,  "Options Changes", "November 10th, 2020", "Adding font options for buff special timer, stack and caster texts."},
			
			{1605124078,  "Options Changes", "November 6th, 2020", "Update on Scripts to support 9.0 dungeons. Scripts overwritten by this update are moved to trash."},
			{1605124078,  "Options Changes", "November 5th, 2020", "Nameplate color dropdown now works on any map."},
			{1605124078,  "Options Changes", "November 5th, 2020", "Added class color option to Enemy Player."},
			{1605124078,  "Bug Fix", "November 5th, 2020", "Fixed aura show animation not playing at the right times + scale reset."},
			{1605124078,  "Bug Fix", "November 5th, 2020", "Properly set cast bar icon according to settings."},
			{1605124078,  "Backend Changes", "November 5th, 2020", "Fixed aura test blink."},
			{1605124078,  "Options Changes", "November 5th, 2020", "Global health bar resizer now also resize the cast bar width."},
			{1605124078,  "Options Changes", "November 5th, 2020", "Health bar animation option renamed from 'Use Smooth Health Transition' to 'Animate Health Bar'."},
			{1605124078,  "Backend Changes", "November 5th, 2020", "Added Breath of the Coldheart to default buff ignored list, this a persistent buff on units in Torghast."},
			{1605124078,  "Options Changes", "November 5th, 2020", "Adding an option to not show the cast target if the player is a tank."},
			{1605124078,  "Backend Changes", "November 4th, 2020", "Backend changes on aura tracking."},
			{1605124078,  "Options Changes", "November 3rd, 2020", "Adding option to enable/disable upper execute range."},
			{1605124078,  "Options Changes", "November 3rd, 2020", "Execute detection updated to 9.0."},
			
			{1604404314,  "Bachend Changes", "November 2nd, 2020", "Externalized all aura code."},
			{1604404314,  "Bug Fix", "November 2nd, 2020", "Execute range indicator overlay is back to its lower alpha value."},
			{1604404314,  "Bachend Changes", "November 2nd, 2020", "Sorting consolidated auras properly."},
			{1604404314,  "Bachend Changes", "November 1st, 2020", "Support for all low-level specs."},
			{1604404314,  "Bug Fix", "November 1st, 2020", "'Searing Touch' is a 30% execute."},
			{1604404314,  "Options Changes", "November 1st, 2020", "Adding option to use target alpha settings for focus target as well."},
			{1604404314,  "Options Changes", "November 1st, 2020", "Adding option to disable Aggro-Glow."},
			{1604404314,  "Bug Fix", "October 31st, 2020", "Adding 'Careful Aim' to execute indicator."},
			{1604404314,  "Bachend Changes", "October 31st, 2020", "Shortening names should now work properly on all non-latin charsets."},
			
			{1604093806,  "New Feature", "October 30th, 2020", "New function to duplicate or copy mod/script options to other mods/scripts."},
			{1604093806,  "Bug Fix", "October 29th, 2020", "Fixing issue with npc colors import not working."},
			{1604093806,  "Bachend Changes", "October 29th, 2020", "Enabling battle-pet healthbars in pet battles (friendly NPC options apply)."},
			{1604093806,  "Options Changes", "October 27th, 2020", "Adding an option to disable the '-AGGRO-' flash (off by default)."},
			{1604093806,  "Bug Fix", "October 26th, 2020", "Ensure mods/scripts are saved properly before exporting a profile."},
			{1604093806,  "Bug Fix", "October 26th, 2020", "Shortening spell-names in Russian locale now should work properly."},
			{1604093806,  "Bachend Changes", "October 25th, 2020", "'IsSelf' is now more consistent across the members."},
			{1604093806,  "Bachend Changes", "October 25th, 2020", "Proper alpha checks for the personal bar."},
			{1604093806,  "Bachend Changes", "October 25th, 2020", "Refresh settings tab when selecting it."},
			{1604093806,  "Bug Fix", "October 25th, 2020", "Stopping nameplate flash animations on nameplate removal."},
			{1604093806,  "Bug Fix", "October 24th, 2020", "Fixing an issue with internal aura sorting making auras too 'jumpy'."},
			{1604093806,  "Bug Fix", "October 24th, 2020", "Fixing an issue with LibCustomGlow implementation not recognizing the key properly in certain cases."},
			{1604093806,  "Bug Fix", "October 24th, 2020", "Fixing an issue with the Combo Points mod."},
			
			{1604093806,  "Bug Fix", "October 22nd, 2020", "Regression fixes for aura anchors and IsFocus."},
			{1604093806,  "Backend Changes", "October 22nd, 2020", "Adding 'upper range' execute ranges. (e.g. 100% to 80% for Warrior Condemn or 100% to 90% for Mage Firestarter)"},
			{1604093806,  "Backend Changes", "October 22nd, 2020", "Adding additional execute spells for WL, Rogue and Warriors."},
			{1604093806,  "Bug Fix", "October 21st, 2020", "Fixing 'Only Damaged Players' option."},
			
			{1603223454,  "Bug Fix", "October 20th, 2020", "Fixing issue with no-combat alpha and coloring."},
			{1603223454,  "Bug Fix", "October 20th, 2020", "Adjusting execute settings tooltip and adding Shadowburn (WL, Destro) talent."},
			{1603223454,  "Bug Fix", "October 20th, 2020", "Adding sanity checks for range-checking to omit unwanted errors."},
			{1603223454,  "Bug Fix", "October 19th, 2020", "Fixing an issue with scripts/mods not being re-compiled properly."},

			{1603047531,  "Bug Fix", "October 18th, 2020", "Execute spells are now checked for being available."},
			{1603047531,  "Bug Fix", "October 18th, 2020", "Execute Glow effect now scales properly with healthbar size."},
			{1603047531,  "Bug Fix", "October 17th, 2020", "Fixing an issue with overwritten modTable/scriptTable for mods/scripts with the same name."},
			{1603047531,  "Bug Fix", "October 17th, 2020", "Destructor Hooks now are called again."},
			{1603047531,  "Bug Fix", "October 16th, 2020", "Fixing range check for low-level characters without a talent spec."},
			{1603047531,  "Bug Fix", "October 16th, 2020", "Adding an option to switch back to player combat state recognition instead of unit state. (Thanks Jaden for the initial work on this)"},
			{1603047531,  "Bug Fix", "October 16th, 2020", "Fixing 'combat state' recognition for certain options."},
			{1603047531,  "Bug Fix", "October 15th, 2020", "CVars should now be stored and restored more consistently when changed through Plater."},
			{1603047531,  "Bug Fix", "October 15th, 2020", "Selecting Profile Import text box is now easier."},
			{1603047531,  "Backend Changes", "October 15th, 2020", "Adding missing execute spells."},
			{1603047531,  "Bug Fix", "October 15th, 2020", "Fixing an issue with importing profiles."},
			
			{1602710092,  "Bug Fix", "October 14th, 2020", "Adding Warrior, Paladin and Monk execute spells as baseline."},
			{1602710092,  "Bug Fix", "October 14th, 2020", "Fixed range check for low-level characters."},
			{1602710092,  "Bug Fix", "October 14th, 2020", "Fixing issue with plate sizes not updating properly when entering combat."},
			{1602710092,  "Bug Fix", "October 14th, 2020", "Fixing npc title recognition."},
			
			{1602538221,  "Options Changes", "October 13th, 2020", "New global nameplate width and height options for easier setup."},
			{1602538221,  "Backend Changes", "October 13th, 2020", "'In Combat' config now applies according to combat state of the unit."},
			{1602538221,  "New Feature", "October 13th, 2020", "Adding overwritable aura sort function 'Plater.AuraIconsSortFunction(aura1, aura2)' and options to enable/disable sorting. Default: time remaining."},
			{1602538221,  "New Feature", "October 13th, 2020", "Quest mobs now have additional information available: 'QuestInfo'-list, containing all active quests with name, text, states and more information."},
			{1602538221,  "Backend Changes", "October 13th, 2020", "CVars from Options are now stored and re-stored with the profile."},
			{1602538221,  "Backend Changes", "October 13th, 2020", "Improvements on Nameplate Widgets."},
			{1602538221,  "New Feature", "October 13th, 2020", "Range check now uses LibRangeCheck and let you select specific ranges instead of spells."},
			{1602538221,  "New Feature", "October 13th, 2020", "Range check now has separate settings for friendly and enemy units."},
			{1602538221,  "Backend Changes", "October 13th, 2020", "Adjustments for Shadowlands / 9.0 API changes."},
			
			{1602538221,  "Bug Fix", "October 7th, 2020", "Fixing Health % 'Out of Combat' option."},
		
			{1602021262,  "Bug Fix", "September 22nd, 2020", "Fixing a re-scaling issue with the target highlight glows."},
			{1602021262,  "Bug Fix", "September 15th, 2020", "Cast bar alpha will not be changed for range/target when already fading."},
			{1602021262,  "Backend Changes", "September 14th, 2020", "'Stacking' and 'Friendly' nameplates auto toggle (Auto tab) now apply in PVP zones as well."},
		
			{1599216958,  "Backend Changes", "August 16th, 2020", "Configuration for minor and pet nameplates should now prefer minor over pet."},
			{1599216958,  "Bug Fix", "August 11th, 2020", "Bugfix to 'Cast Bar Icon Config' mod."},
			
			{1596791967,  "Bug Fix", "August 7th, 2020", "Buff Frame Anchors behave consistent with grow direction and anchor position now."},
			
			{1596672621,  "New Feature", "August 6th, 2020", "New Mod added: 'Cast Bar Icon Settings [P]', this is a new mod to deal with the cast bar icon at ease. It can be enabled at the Modding tab."},
			
			{1594844798,  "Bug Fix", "August 5th, 2020", "Metamorphosis CC should no longer cause the Player Buff to be shown automatically."},
			{1594844798,  "Backend Changes", "August 4th, 2020", "Adding cache value 'unitFrame.IsFocus' for usage in mods/scripts."},
			{1594844798,  "Backend Changes", "July 30th, 2020", "Range/Target Alpha options should behave more consistent now."},
			{1596627316,  "Options Changes", "July 29th, 2020", "Adding anchor options for Buff Frames. Important: this requires offset migration, which is attempted automatically, but you might need to setup Buff Frame anchors and offsets again."},
			{1596627316,  "Options Changes", "July 29th, 2020", "Adding icon size options for Buff Frame 2."},
			{1596627316,  "Options Changes", "July 29th, 2020", "Adding option to ignore duration filtering on personal bar buffs."},
			{1596627316,  "Options Changes", "July 29th, 2020", "Adding options for 'Big Actor Title' on enemy npcs to better support 'name only' mode in mods."},
			
			{1594844798,  "Bug Fix", "July 15th, 2020", "The event code buttons now show the correct code."},
			{1594844798,  "Backend Changes", "July 15th, 2020", "'Hide OmniCC' now surpresses tullaCC as well. Option available for Boss-Mod-Auras as well."},
			
			{1592230039,  "Bug Fix", "June 21st, 2020", "Fixing an issue with reputation standing showing on friendly NPCs instead of the unit title when color blind mode is enabled."},
			{1592230039,  "New Feature", "June 15th, 2020", "Introducing 'Custom Options' for Mods and Scripts as per profile settings for the mod/script."},
			{1592230039,  "New Feature", "June 15th, 2020", "Profile updates from wago.io through the companion app will now keep additionally imported mods/scripts which were not part of the profile."},
			{1592230039,  "Bug Fix", "June 15th, 2020", "Fixing buff special tracking being case sensitive and auto-suggest being all lower-case."},
			
			{1591436231,  "Bug Fix", "June 6th, 2020", "Fixing an issue with profiles not being editable without WA-Companion addon."},
			
			{1591387261,  "New Feature", "June 5th, 2020", "Adding options to skip or ignore profile updates."},
			{1591387261,  "New Feature", "June 3rd, 2020", "Adding options to skip or ignore a mod/script updates."},
			{1591387261,  "New Feature", "June 2nd, 2020", "Wago-Icons on Mods/Scripts are now clickable to update."},
			{1591387261,  "Bug Fix", "June 2nd, 2020", "Range/Target alpha should now update properly."},
			{1591387261,  "Bug Fix", "May 23rd, 2020", "Fixing visibility of nameplate 'widgets', e.g. Nazjatar followers or hatchling."},
			
			{1588949935,  "New Feature", "May 7th, 2020", "Adding 'Plater.GetVersionInfo(<printOut - bool>)' function to get current version information."},
			{1588949935,  "Bug Fix", "May 7th, 2020", "Spell names are now truncated properly accordingly to the nameplate size."},
			{1588949935,  "Bug Fix", "Apr 29th, 2020", "Shield Absorb indicators are now updated properly when showing the plate for the first time."},
			{1588949935,  "New Feature", "Apr 28th, 2020", "Supporting whole Plater profiles to be updated from wago.io via WA-Companion app."},
			{1588949935,  "New Feature", "Apr 28th, 2020", "Available Wago.io updates will now be indicated by small wago icons on the tabs."},
			
			{1587858181,  "Bug Fix", "Apr 25th, 2020", "Fixing 'copy wago url' action not updating the URL properly."},
			{1587038093,  "Bug Fix", "Apr 16th, 2020", "Pet recognition is working for russian clients as intended now."},
			
			{1586982107,  "Bug Fix", "Apr 7th, 2020", "Do not clean up NPC titles."},
			{1586982107,  "Backend Changes", "Mar 29th, 2020", "'Consolidate Auras' now uses the icon instead of the name for uniqueness."},
			{1586982107,  "Backend Changes", "Mar 29th, 2020", "Pets and Minions should now be recognized better."},
			{1586982107,  "New Feature", "Mar 27th, 2020", "Adding options to track offensive and defensive player CDs in Buffs and Buff Special."},
			{1586982107,  "Bug Fix", "Mar 27th, 2020", "Alternate Power should now show properly on the personal bar if using UIParent."},
			{1586982107,  "Backend Changes", "Mar 27th, 2020", "Failsafe for NPC-Colors imports: warning messages are shown if used on the wrong tab."},
			{1586982107,  "New Feature", "Mar 25th, 2020", "Adding Blizzard default nameplate widgets (e.g. nameplate xp bars)."},
			{1586982107,  "Bug Fix", "Mar 16th, 2020", "Ensure Boss Mod Icons are unique and not duplicated."},
			{1586982107,  "Bug Fix", "Mar 16th, 2020", "Ensure cast bars stay hidden according to settings for friendly / enemy units with both enabled."},
			{1586982107,  "New Feature", "Mar 16th, 2020", "New scripts/mods imported from wago.io now show the URL, Version and Revision. Plus you can copy the url through the right mouse button menu."},
			{1586982107,  "Backend Changes", "Mar 16th, 2020", "Imports for Mods/Scripts now prompt to overwrite if one with the same name already exist."},
			{1586982107,  "Backend Changes", "Mar 14th, 2020", "Imports on wrong tabs are now handled better and show propper error messages."},

			{1583878613,  "New Feature", "Mar 10th, 2020", "Adding unit aura caching which covers all auras on the unit, even if they are not visible. -> Plater.UnitHasAura(unitFrame)"},
			{1583878613,  "Bug Fix", "Mar 6th, 2020", "Consolidate auras by spellId instead of name."},
			{1583878613,  "New Feature", "Mar 6th, 2020", "Adding a search tab to the options menu to lookup settings."},
			{1583878613,  "Bug Fix", "Mar 1st, 2020", "Ensure nameplates are updated properly when a unit becomes hostile."},
			{1583878613,  "Bug Fix", "Feb 27th, 2020", "Fixing an issue with cast bars not updating properly with different versions of DF library."},
			{1583878613,  "New Feature", "Feb 27th, 2020", "Adding support for DBM and BigWigs Nameplate Icon feature. Settings are on the Buff Special tab."},
			{1583878613,  "New Feature", "Feb 24th, 2020", "Adding line numbering to scripting frames."},
			{1583878613,  "Bug Fix", "Feb 21st, 2020", "Ensure nameplates are updated fully when being added to screen."},
			{1583878613,  "Options Changes", "Feb 18th, 2020", "Adding Cast-Bar offset setting to friendly units."},
			{1583878613,  "New Feature", "Feb 3rd, 2020", "Mods now have 'modTable' as a mod-global table shared about all nameplates the mod runs on. Same for scripts with 'scriptTable'. The new 'Initialization' function for mods and scripts can be used to initialize the global env table."},
			{1583878613,  "", "Jan 20th, 2020", "Added cooldown text size setting for Buff Especial."},
			{1583878613,  "Bug Fix", "Jan 20th, 2020", "Fixing rare nil-error with UNITIDs."},
			{1583878613,  "Options Changes", "Jan 17th, 2020", "Added options to set alpha for each frame individually on transparency settings."},
			{1583878613,  "New Feature", "Jan 19th, 2020", "Added some GoTo buttons in the options frame to help new users find the basic tabs to setup."},
			{1583878613,  "Options Changes", "Jan 18th, 2020", "Many default textures has changed plus health and shield prediction are enabled by default."},
			
			{1579261831,  "Options Changes", "Jan 17th, 2020", "Adding native support to 'Non Target Alpha' called now 'Units Which Isn't Your Target' in the General Settings Page."},
			{1579261831,  "New Feature", "Jan 21st, 2020", "Alpha for range check and non target units can now be set individualy for each frame: health, cast, power, buff bars."},
			{1579261831,  "Backend Changes", "Jan 21st, 2020", "Entry for scripts 'namePlateAlpha' has been removed."},
			{1579261831,  "Bug Fix", "Jan 17th, 2020", "Updating OmniCC integration for 8.3 changes in OmniCC."},
			{1579261831,  "Bug Fix", "Jan 7th, 2020", "Ensuring BuffFrame2 is shown/hidden properly."},
			{1579261831,  "Backend Changes", "Jan 4th, 2020", "Buff-Special enhancement: Adding Stack info and more public information for modding / scripting."},
			{1579261831,  "New Feature", "Dec 31st, 2019", "Introducing run priority for mods and scripts."},
			
			{1577547573,  "Bug Fix", "Dec 28th, 2019", "Ensuring personal resources on target use the correct draw layer."},
			{1577547573,  "Bug Fix", "Dec 28th, 2019", "Fixing error with Raid Marks."},
			{1577547573,  "Backend Changes", "Dec 28th, 2019", "Updating Masque integration."},
			{1577547573,  "Bug Fix", "Dec 28th, 2019", "Ensure raid target frames to be above healthbar."},
			{1577547573,  "Bug Fix", "Dec 23rd, 2019", "Fixing color and castBar updates on 'no healthbar' mode."},
			{1577547573,  "Options Changes", "Dec 23rd, 2019", "Bringing back 'Hide Enemy Cast Bar' option."},
			{1577547573,  "Options Changes", "Dec 19th, 2019", "Changing the default range check spell for Affl. WLs to something available at lvl 1."},

			{1575627153,  "Bug Fix / Options Changes", "Dec 6th, 2019", "'Resource on target' change: Plater setting instead of CVar. Fixing 'forbidden' resource frame by not showing on protected plates anymore (e.g. friendlies in dungeons/instances/raids). This keeps the frame moveable."},
			{1575627153,  "Bug Fix", "Nov 25th, 2019", "Fixing 'Cast by Player' debuff recognition if the caster is a player totem."},
			{1575627153,  "Options Changes", "Nov 19th, 2019", "Adding text options for the npc title."},
			{1575627153,  "Bug Fix", "Oct 30th, 2019", "Fixing spell cast push-back hiding the castbar in some cases."},
			{1575627153,  "Bug Fix", "Oct 23rd, 2019", "Fixing bug with spell-animation settings when importing older profiles."},
			{1575627153,  "Bug Fix", "Oct 1st, 2019", "Fixing an issue with 'broken' Plater profiles when Plater-Classic was installed by accident. (Thanks Twitch...)"},
			{1575627153,  "Bug Fix", "Sep 26th, 2019", "'Import Profile' should no longer cause broken mods."},
			{1575627153,  "New Feature", "Sep 26th, 2019", "'Import Profile' is now asking to overwrite an existing profile."},
			{1575627153,  "New Feature", "Aug 29th, 2019", "Adding a 'solo' color setting for DPS which can be toggled on to overwrite all other threat state colors when not in a group."},
			{1575627153,  "Bug Fix", "Aug 22nd, 2019", "Fixing the 'Global Offset' setting when using 'Use Custom Strata Channels' option."},
			{1575627153,  "Bug Fix", "Aug 22nd, 2019", "Adding IsProtected function to Plater namepaltes to properly support addons like MoveAnything."},
			{1575627153,  "Bug Fix", "Aug 22nd, 2019", "Fix 'unknown aura' in Buff Special list."},
			{1575627153,  "Bug Fix", "Aug 17th, 2019", "On exporting a profile, do not export the trashcan for scripts and mods"},
			{1575627153,  "Options Changes", "Aug 9th, 2019", "Adding option for aura icon row spacing."},
			{1575627153,  "New Feature", "Aug 4th, 2019", "Adding LibCustomGlow-1.0 and Plater functions to create glow effects on frames based on the lib."},
			{1575627153,  "Bug Fix", "July 30th, 2019", "Quest recognition updated to properly recognize multiple quests."},
			{1575627153,  "Bug Fix", "July 21st, 2019", "Quest recognition updated"},
			{1575627153,  "New Feature", "July 11th, 2019", "Added '/plater addnpc' to add npcs into the Npc Colors tab."},
			{1575627153,  "Bug Fix", "July 8th, 2019", "Fixing an error with enemy npcs turning friendly npcs."},
			{1575627153,  "Bug Fix", "July 5th, 2019", "Include pets in the name or plate configuration."},
			{1575627153,  "Options Changes", "July 5th, 2019", "Reworked the buff special filtering to accept either names or spellIDs."},
			{1575627153,  "Bug Fix", "July 4th, 2019", "Hover hover highlight fixed."},
			{1575627153,  "Options Changes", "July 3rd, 2019", "Adding options to show healthbars the same way as name only options: for profession npcs only or all npcs."},
			
			{1562097297,  "Bug Fix", "July 2nd, 2019", "Fixed spell animations."},
			{1562097297,  "Bug Fix", "July 2nd, 2019", "Fixed script errors which was spamming in the chat."},
			{1562097297,  "Bug Fix", "July 2nd, 2019", "Fixed buffs sometimes not showing in the aura frame 2."},
			{1562097297,  "Bug Fix", "July 2nd, 2019", "Fixed more bugs with quest mobs detection."},
			{1562097297,  "Bug Fix", "July 2nd, 2019", "Unit Highlight is now placed below the unit name and unit health."},
			
			{1557674970,  "New Feature", "May 12, 2019", "Added an option to stack auras with the same name."},
			{1557674970,  "New Feature", "May 12, 2019", "Added an option to change the space between each aura icon."},
			{1557674970,  "New Feature", "May 12, 2019", "Added an option to hide the nameplate when the unit dies."},
			{1557674970,  "New Feature", "May 12, 2019", "Added an option to automatically track enrage effects."},
			{1557674970,  "New Feature", "May 12, 2019", "Experimental tab got renamed to 'Level and Statra'."},
			
			{1554737982,  "Buf Fix", "April 8, 2019", "Fixed 'Only Show Player Name' not overriding the 'Only Damaged Players' setting."},
			{1554737982,  "Buf Fix", "April 8, 2019", "Fixed Paladin's Hammer of Wrath execute range."},
			{1554222484,  "Buf Fix", "April 4, 2019", "Fixed an issue with NameplateHasAura() API not checking Special Auras."},
			{1554222484,  "New Feature", "April 2, 2019", "Language localization has been started: https://wow.curseforge.com/projects/plater-nameplates/localization."},
			{1554222484,  "New Feature", "April 2, 2019", "Added Pet Indicator."},
			
			{1553180406,  "New Feature", "March 21, 2019", "Added Indicator Scale."},
			
			{1553016092,  "New Feature", "March 19, 2019", "Added Number System selector (western/east asia) at the Advanced tab."},
			{1552762100,  "New Feature", "March 16, 2019", "Added Show Interrupt Author option (enabled by default)."},
		
			{1551553169,  "New Feature", "March 02, 2019", "Npc Colors tab now offers an easy way to set colors to different npcs, works on dungeons and raids."},
			{1551553169,  "New Feature", "March 02, 2019", "Added an alpha slider for resources in the Personal Bar tab."},
			{1551553169,  "New Feature", "March 02, 2019", "Added 'No Spell Name Length Limitation' option."},
			
			{1550774255,  "New Feature", "February 21, 2019", "Added checkbox to disable the health bar in the Personal Bar. Now it is possible to use the Personal Bar as just a regular Cast Bar that follows your character."},
			{1550774255,  "Bug Fix", "February 21, 2019", "Fixed RefreshNameplateColor not applying the correct color when the unit is a quest mob."},
			{1550410653,  "Scripting", "February 17, 2019", "Added 'M+ Bwonsamdi Reaping' (enabled by default) hook script for the mobs from the affix without aggro tables."},
			{1550410653,  "Scripting", "February 17, 2019", "Added 'Dont Have Aura' hook script."},
			{1550410653,  "Bug Fix", "February 17, 2019", "Fixed cast bar border sometimes showing as white color above the spell name cast."},
			{1550410653,  "Bug Fix", "February 17, 2019", "Fixed border color by aggro reported to not be working correctly as it should."},
			{1550410653,  "Bug Fix", "February 17, 2019", "Fixed health animation and color transition animations."},
			{1550410653,  "Bug Fix", "February 17, 2019", "Fixed health percent text calling :Show() every time the health gets an update."},
			{1550410653,  "Bug Fix", "February 17, 2019", "Fixed resource anchor not correctly adjusting its offset when the personal health bar isn't shown."},
			{1550410653,  "Bug Fix", "February 17, 2019", "Fixed the neutral nameplate color."},
			{1550410653,  "Bug Fix", "February 17, 2019", "Fixed the channeling color sometimes using the finished cast color."},
			{1550410653,  "Bug Fix", "February 17, 2019", "Fixed hook script load conditions not showing reaping affix."},
			{1550410653,  "Bug Fix", "February 17, 2019", "Fixed some issue with the npc name glitching its size when anchoring the name inside the nameplate."},
			{1550410653,  "Bug Fix", "February 17, 2019", "Fixed an issue with quest state not being exposed to scripts."},
			{1550410653,  "Options Changes", "February 17, 2019", "Added a check box to enable Masque support, default disabled."},
			{1550410653,  "Options Changes", "February 17, 2019", "Added options to change the spell name anchor."},
			{1550410653,  "Options Changes", "February 17, 2019", "Added option 'Offset if Buff is Shown' for resource at the Personal Bar tab."},
			{1550410653,  "Scripting", "February 17, 2019", "Added 'Health Changed' hook event."},
			{1550410653,  "Scripting", "February 17, 2019", "Added unitFrame.InCombat, this member is true when the unit is in combat with any other unit."},
			{1550410653,  "Scripting", "February 17, 2019", "Added Plater.GetConfig (unitFrame) for scripts to have access to the nameplate settings."},
			{1550410653,  "Scripting", "February 17, 2019", "Added Plater:GetPlayerRole() which returns the name of the current role the player is in (TANK DAMAGER, HEALER, NONE)."},
			{1550410653,  "Scripting", "February 17, 2019", "Added Plater.SetExecuteRange (isEnabled, range)"},
			{1550410653,  "Scripting", "February 17, 2019", "Added Plater.IsInOpenWorld()"},
			{1550410653,  "Scripting", "February 17, 2019", "Added Plater.IsUnitInFriendsList (unitFrame)"},
			{1550410653,  "Scripting", "February 17, 2019", "Added Plater.IsUnitTapped (unitFrame)"},
			{1550410653,  "Scripting", "February 17, 2019", "Added Plater.GetUnitGuildName (unitFrame)"},
			{1550410653,  "Scripting", "February 17, 2019", "Added Plater.IsUnitTank (unitFrame)"},
			{1550410653,  "Scripting", "February 17, 2019", "Added Plater.GetTanks()"},
		
			{1548612692,  "New Feature", "January 27, 2019", "Added an option to test cast bars."},
			{1548612692,  "New Feature", "January 27, 2019", "Added options to customize the cast bar Spark."},
			{1548612692,  "New Feature", "January 27, 2019", "Added options to show the unit heal prediction and shield absorbs."},
			{1548612692,  "New Feature", "January 27, 2019", "Added options for cast bar fade animations."},
			{1548612692,  "New Feature", "January 27, 2019", "Added options to adjust the cast bar color when the cast is interrupted or successful."},
			{1548612692,  "Scripting", "January 27, 2019", "Update for Player Targeting Amount and Combo Points hook scripts."},
			{1548612692,  "Bug Fix", "January 27, 2019", "Fixed target indicator 'Ornament' which was a dew pixels inside the nameplate."},
			{1548612692,  "Bug Fix", "January 27, 2019", "Fixed the unit name which sometimes was 10 pixels below where it should be."},
			{1548612692,  "Bug Fix", "January 27, 2019", "Fixed the unit name showing ... instead when the option to show guild names enabled."},
			{1548612692,  "Bug Fix", "January 27, 2019", "Fixed the personal bar sometimes showing the player name."},
			{1548612692,  "Bug Fix", "January 27, 2019", "Fixed special auras still being tracked after deleting an aura from the track list."},
			{1548612692,  "Bug Fix", "January 27, 2019", "Fixed special auras not being tracked if the aura is in the regular debuff blacklist."},
		
			{1548117317, "Scripting", "January 21, 2019", "Added new hooking scripts for Jaina and Blockade encounters on Battle of Dazar'alor."},
			{1548006299, "Scripting", "January 20, 2019", "Added new hooking script: Aura Reorder. Added a new script for Blink by Time Left."},
			{1548006299, "Settings", "January 20, 2019", "Cast bar now have an offset settings for most of the nameplate types."},
			{1548006299, "Settings", "January 20, 2019", "Added 'No Tank Aggro' color for DPS, which color the namepalte when an unit isn't attacking you or the tank."},
			
			{1547411718, "Scripting", "January 13, 2019", "Added 3 new hooking scripts: Color Automation, Attacking Specific Unit and Execute Range."},
			{1547411718, "Scripting", "January 13, 2019", "Plater.SetBorderColor (unitFrame, 'color') now accept any format of color."},
			
			{1547239726, "Back End Changes", "January 11, 2019", "Plater now uses its own unit frame instead of recycling the Blizzard nameplate frame. This fixes a xit ton of problems and unlock more customizations."},
			{1547239726, "Options Changes", "January 11, 2019", "Removed shadow toggles, added outline mode selection and shadow color selection."},
			{1547239726, "Options Changes", "January 11, 2019", "Personal nameplate now have a cast bar for the player."},
			{1547239726, "Options Changes", "January 11, 2019", "Override colors are now enabled by default and it won't override player class colors."},
			{1547239726, "Options Changes", "January 11, 2019", "Added the following options for target highlight: texture, alpha, size and color."},
			{1547239726, "Options Changes", "January 11, 2019", "Added global offset to slightly adjust the nameplate up and down."},
			
			{1543680969, "Script Changes", "December 1, 2018", "'Added 'Aura Border Color' script (disabled by default)."},
			{1543248430, "Script Changes", "November 26, 2018", "'Fixate on You' Spawn of G'huun triggers only for the mythic raid version of this mob."},
			{1543248430, "Script Changes", "November 26, 2018", "Added script 'Color Change' with the mythic dungeon version of Spawn of G'huun, settings for it on its constructor script."},
			{1543248430, "Script Changes", "November 26, 2018", "Added hook script 'Combo Points' (disabled by default), show combo points for rogue and feral druid."},
			{1543248430, "Script Changes", "November 26, 2018", "Added hook script 'Extra Border' (disabled by default), adds an extra border in the health bar."},
			{1543248430, "Script Changes", "November 26, 2018", "Added hook script 'Reorder Nameplate' (disabled by default), simple reorder for the health and cast bars."},
			
			{1542811859, "Script Changes", "November 21, 2018", "Added hook script 'Players Targeting a Target' (disabled by default), show the amount of players currently targeting a unit."},
			{1542811859, "Level Text", "November 21, 2018", "Fixed level text always showing the level of the unit as 120."},
			
			{1542475895, "Target Shading", "November 17, 2018", "Target Shading won't apply it's effect in the Personal Bar."},
			{1542475895, "Console Variables", "November 17, 2018", "Renamed some options and added several options for CVars in the advanced tab."},
			{1542475895, "Auras", "November 17, 2018", "When using aura grow direction to left or right, auras will grow in a second line if the total size of the icons passes the size of the nameplate."},
			{1542475895, "Scripting", "November 17, 2018", "unitFrame.InExecuteRange is true if the unit is within your character execute range."},
			{1542475895, "Scripting", "November 17, 2018", "unitFrame.IsSelf is true if the nameplate is the Personal Bar."},
			
			{1542475895, "Cast Bar", "November 08, 2018", "Added cast Bar Offset for enemy player and enemy npc."},
			{1541001993, "New Feature: Masque Support", "October 31, 2018", "Buff icons now uses masque skins. A Plater group has been added into /masque options where you can setup or disable them."},
			{1541001993, "New Feature: Hook Scripts", "October 16, 2018", "Added new tab for creating hook scripts. These scripts can run on all nameplates after certain events and should be use to a more deep costumization of nameplates."},
			{1541001993, "New Feature: Import and Export Profile", "October 16, 2018", "Profile tab now has options to export and import profiles."},
			{1541001993, "New Feature: Animations", "October 16, 2018", "Animations for spell can now be edited, added or disabled at the animations tab."},
			{1541001993, "Target Tab", "October 16, 2018", "Targetting optons has been moved to its own tab."},
			{1541001993, "Personal Bar", "October 16, 2018", "Added options to Show health, health amount and health percent."},
			{1541001993, "Health Percent", "October 16, 2018", "All nameplate types got the option to disable percent decimals."},
			{1541001993, "Buff Settings", "October 16, 2018", "Added font option for buff timer and buff stack amount."},
			{1541001993, "Buff Tracking", "October 16, 2018", "Now shows all spells it's tracking when hovering over a spell line."},
			{1541001993, "Buff Special", "October 16, 2018", "Added the option to only track the aura if it has been casted by the player."},
			--{1541001993, "", "October 16, 2018", ""},
		}
	end
	
	return Plater.ChangeLogTable
end

function Plater.GetChangeLogText(requiredInfo)
	if not requiredInfo then return end
	
	local changeLogTable = Plater.GetChangelogTable()
	-- build printable table
	local timestamp
	local clByAuthor = {}
	for _, entry in ipairs(changeLogTable) do
		
		if not timestamp or (requiredInfo and requiredInfo == "all") then
			timestamp = entry[1]
		end
	
		if timestamp == entry[1] then
			local author = entry[5] or "Unknown Author"
			if not clByAuthor[author] then
				clByAuthor[author] = {}
				clByAuthor[author].data = {}
				clByAuthor[author].entries = 0
			end

			clByAuthor[author].entries = clByAuthor[author].entries + 1
			clByAuthor[author].data[clByAuthor[author].entries] = entry
		end
	end
	
	-- build text
	local text
	for author, entry in pairs(clByAuthor) do
		text = (text and (text .. "\n") or "") .. "@" .. author .. ":\n"
		
		for _, data in ipairs(entry.data) do
			text = text .. "- " .. data[4] .. "\n"
		end
		
	end
	
	return text
end

if arg and arg[1] then
	local requiredInfo
	if arg[1] == "all" or arg[1] == "latest" then
		requiredInfo = arg[1]
	else
		return
	end
	
	print(Plater.GetChangeLogText(requiredInfo))
end
