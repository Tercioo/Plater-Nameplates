
local Plater = _G.Plater
local DF = _G.DetailsFramework
local _

--create an api table
--this is the same code from Details!
-- /details api
--when adding new functions, they may or may not be added here

Plater.API_Description = {
	addon = "Plater Nameplates",
	namespaces = {
		{
			name = "Plater",
			order = 1,
			api = {},
		}
	},
}

tinsert(Plater.API_Description.namespaces[1].api, {
	name = "IsCampaignQuest",
	desc = "Query if a quest is part of a campaign quest list.",
	parameters = {
        {
            name = "questName",
            type = "string",
            default = "",
            desc = "A quest name to query if the quest is part of a campaign quest.",
        },
    },
	returnValues = {
		{
			name = "isCampaignQuest",
			type = "boolean",
			desc = "true if the quest is a campaign quest.",
		}
	},
	type = 0,
})

function Plater.IsCampaignQuest(questName)
    return Plater.QuestCacheCampaign[questName]
end
