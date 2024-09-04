
local addonId, platerInternal = ...

local Plater = Plater
---@type detailsframework
local DF = DetailsFramework
local _

local TAB_INDEX_SEARCH = 26

function platerInternal.CreateSearchOptions()
    local searchFrame = PlaterOptionsPanelContainerSearchFrame
    local OTTFrame = PlaterNameplatesOverTheTopFrame
    local mainFrame = PlaterOptionsPanelContainer

    --before creating the search options, we need to create load all other tabs that has load on demand and did not load yet
    searchFrame.TabsToLoad_Funtions = {}
    local bHasLoadOnDemand = false

    for tabName, bLoadState in pairs(platerInternal.LoadOnDemand_IsLoaded) do
        if (not bLoadState) then
            if (platerInternal.CreateSearchOptions ~= platerInternal.LoadOnDemand_LoadFunc[tabName]) then
                table.insert(searchFrame.TabsToLoad_Funtions, platerInternal.LoadOnDemand_LoadFunc[tabName])
                bHasLoadOnDemand = true
            end
        end
    end

    --check if there's any tab to load and if it's not already loading
    if (bHasLoadOnDemand and not searchFrame.bIsLoadingOnDemand) then
        searchFrame.bIsLoadingOnDemand = true

        --execute the load function for each tab with a delay of 50ms
        local totalTabsToLoad = #searchFrame.TabsToLoad_Funtions
        for i = 1, totalTabsToLoad do
            local func = searchFrame.TabsToLoad_Funtions[i]
            if (i == 1) then
                C_Timer.After(0, func)
            else
                C_Timer.After(0.05 * i, func)
            end
        end

        if (not searchFrame.TimeBar) then
            local texture = [[Interface\AddOns\Plater\images\bar_skyline]]
            local timeBar = DF:CreateTimeBar(searchFrame, texture, 500, 30, 0, "timeBarLoadOnDemand", "$parentLoadOnDemandTimeBar")
            timeBar:SetPoint("center", 0, 0)
            timeBar:SetHook("OnTimerEnd", function()
                timeBar:Hide()
                platerInternal.CreateSearchOptions()
            end)
            searchFrame.TimeBar = timeBar
        end

        searchFrame.TimeBar:SetTimer((totalTabsToLoad + 1) * 0.05)
        return
    end

    if (bHasLoadOnDemand) then
        --there still some tabs to load, wait for them to load
        searchFrame.TimeBar:SetTimer(0.05)
        return
    end

    --already loaded? return
    if (platerInternal.LoadOnDemand_IsLoaded.SearchOptions) then
        return
    end

    local startX, startY, heightSize = 10, platerInternal.optionsYStart, 755
    local highlightColorLastCombat = {1, 1, .2, .25}

    --templates
    local options_text_template = DF:GetTemplate ("font", "OPTIONS_FONT_TEMPLATE")
    local options_dropdown_template = DF:GetTemplate ("dropdown", "OPTIONS_DROPDOWN_TEMPLATE")
    local options_switch_template = DF:GetTemplate ("switch", "OPTIONS_CHECKBOX_TEMPLATE")
    local options_slider_template = DF:GetTemplate ("slider", "OPTIONS_SLIDER_TEMPLATE")
    local options_button_template = DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE")    

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--~search panel
	local searchBox = DF:CreateTextEntry (searchFrame, function()end, 156, 20, "serachTextEntry", _, _, DF:GetTemplate ("dropdown", "PLATER_DROPDOWN_OPTIONS"))
	searchBox:SetAsSearchBox()
	searchBox:SetJustifyH("left")
	searchBox:SetPoint(10, -145)

	--create a search box in the main tab
	local mainSearchBox = DF:CreateTextEntry(OTTFrame, function()end, 156, 20, "mainSearchTextEntry", _, _, DF:GetTemplate("dropdown", "PLATER_DROPDOWN_OPTIONS"))
	mainSearchBox:SetAsSearchBox()
	mainSearchBox:SetJustifyH("left")
	mainSearchBox:SetPoint("topright", -220, 0)

	local optionsWildCardFrame = CreateFrame("frame", "$parentWildCardOptionsFrame", searchFrame, BackdropTemplateMixin and "BackdropTemplate")
	optionsWildCardFrame:SetAllPoints()

	--all settings tables
	local allTabSettings = PlaterOptionsPanelFrame.AllSettingsTable

	local allTabHeaders = { --~changeindex2
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
		--25 wago imports
		--26 search
		--27 plugins
		mainFrame.AllButtons [28].button.text:GetText(), -- bossmods
	}

	--this table will hold all options
	local allOptions = {}
	--start the fill process filling 'allOptions' with each individual option from each tab
	for i = 1, #allTabSettings do
		local tabSettings = allTabSettings[i]
		local lastLabel = nil
		for k, setting in pairs(tabSettings) do
			if (type(setting) == "table") then
				if (setting.type == "label") then
					lastLabel = setting
				end
				if (setting.name) then
					allOptions[#allOptions+1] = {setting = setting, label = lastLabel, header = allTabHeaders[i] }
				end
			end
		end
	end

	searchBox:SetHook("OnEnterPressed", function(self)
		local options = {}

		local searchingText = string.lower(searchBox.text)
		searchBox:SetFocus(false)

		local lastTab = nil
		local lastLabel = nil
		if searchingText and searchingText ~= "" then
			for i = 1, #allOptions do
				local optionData = allOptions[i]
				local optionName = string.lower(optionData.setting.name)
				if (optionName:find(searchingText)) then
					if optionData.header ~= lastTab then
						if lastTab ~= nil then
							options[#options+1] = {type = "label", get = function() return "" end, text_template = DF:GetTemplate("font", "OPTIONS_FONT_TEMPLATE")} -- blank
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
		end

		options.always_boxfirst = true
		options.language_addonId = addonId
		options.Name = "Plater Search Options"
		DF:BuildMenuVolatile(searchFrame, options, startX, startY-30, heightSize+40, false, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template, platerInternal.OptionsGlobalCallback)
	end)

	mainSearchBox:SetHook("OnEnterPressed", function(self)
		local searchText = mainSearchBox.text
		searchBox:SetText(searchText)
		searchBox:RunHooksForWidget("OnEnterPressed")
		_G["PlaterOptionsPanelContainer"]:SelectTabByIndex(TAB_INDEX_SEARCH)
	end)

    platerInternal.LoadOnDemand_IsLoaded.SearchOptions = true
	platerInternal.CreateSearchOptions = function() end
end