


local Plater = Plater
local _

function Plater.GetChangelogTable()
	if (not Plater.ChangeLogTable) then
		Plater.ChangeLogTable = {
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