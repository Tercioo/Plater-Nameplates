


local Plater = Plater
local _

function Plater.GetChangelogTable()
	if (not Plater.ChangeLogTable) then
		Plater.ChangeLogTable = {
		
			{1554222484,  "New Feature", "April 2, 2019", "Language localization has been started: https://wow.curseforge.com/projects/plater-nameplates/localization."},
			{1554222484,  "New Feature", "April 2, 2019", "Added Pet Indicator."},
			
			{1553180406,  "New Feature", "March 21, 2019", "Added Indicator Scale."},
			
			{1553016092,  "New Feature", "March 19, 2019", "Added Number System selector (western/east asia) at the Advanced tab."},
			{1552762100,  "New Feature", "March 16, 2019", "Added Show Interrupt Author option (enabled by default)."},
		
			{1551553169,  "New Feature", "March 02, 2019", "Npc Colors tab now offers an easy way to set colors to different npcs, works on dungeons and raids."},
			{1551553169,  "New Feature", "March 02, 2019", "Added an alpha slider for resources in the Personal Bar tab."},
			{1551553169,  "New Feature", "March 02, 2019", "Added 'No Spell Name Length Limitation' option."},
			
			{1550774255,  "New Feature", "February 21, 2019", "Added checkbox to disable the health bar in the Personal Bar. Now it is possible to use the Personal Bar as just a regular Cast Bar that follows your character."},
			{1550774255,  "Buf Fix", "February 21, 2019", "Fixed RefreshNameplateColor not applying the correct color when the unit is a quest mob."},
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