


local Plater = Plater
local _

function Plater.GetChangelogTable()
	if (not Plater.ChangeLogTable) then
		Plater.ChangeLogTable = {
			{"New Feature: Hook Scripts", "October 16, 2018", "Added new tab for creating hook scripts. These scripts can run on all nameplates after certain events and should be use to a more deep costumization of nameplates."},
			{"New Feature: Import and Export Profile", "October 16, 2018", "Profile tab now has options to export and import profiles."},
			{"New Feature: Animations", "October 16, 2018", "Animations for spell can now be edited, added or disabled at the animations tab."},
			{"Target Tab", "October 16, 2018", "Targetting optons has been moved to its own tab."},
			{"Personal Bar", "October 16, 2018", "Added options to Show health, health amount and health percent."},
			{"Health Percent", "October 16, 2018", "All nameplate types got the option to disable percent decimals."},
			{"Buff Settings", "October 16, 2018", "Added font option for buff timer and buff stack amount."},
			{"Buff Tracking", "October 16, 2018", "Now shows all spells it's tracking when hovering over a spell line."},
			{"Buff Special", "October 16, 2018", "Added the option to only track the aura if it has been casted by the player."},
			{"", "October 16, 2018", ""},
		}
	end
	
	return Plater.ChangeLogTable
end