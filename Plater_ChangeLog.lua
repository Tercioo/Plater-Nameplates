


local Plater = Plater
local _

function Plater.GetChangelogTable()
	if (not Plater.ChangeLogTable) then
		Plater.ChangeLogTable = {
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