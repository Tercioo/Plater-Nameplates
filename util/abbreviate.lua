
--> details! framework
---@type detailsframework
local DF = _G ["DetailsFramework"]
if (not DF) then
	print ("|cFFFFAA00Plater: framework not found, if you just installed or updated the addon, please restart your client.|r")
	return
end

local _ = nil
local addonId, platerInternal = ...
local Plater = _G.Plater

--> regional format numbers
do
    local eastAsiaMyriads_1k, eastAsiaMyriads_10k, eastAsiaMyriads_1B
    if (GetLocale() == "koKR") then
        eastAsiaMyriads_1k, eastAsiaMyriads_10k, eastAsiaMyriads_1B = "천", "만", "억"

    elseif (GetLocale() == "zhCN") then
        eastAsiaMyriads_1k, eastAsiaMyriads_10k, eastAsiaMyriads_1B = "千", "万", "亿"

    elseif (GetLocale() == "zhTW") then
        eastAsiaMyriads_1k, eastAsiaMyriads_10k, eastAsiaMyriads_1B = "千", "萬", "億"

    else
        eastAsiaMyriads_1k, eastAsiaMyriads_10k, eastAsiaMyriads_1B = "천", "만", "억"
    end

    platerInternal.abbreviateConfig = C_StringUtil and C_StringUtil.GetDefaultAbbreviationBreakpoints and C_StringUtil.GetDefaultAbbreviationBreakpoints(GetLocale()) -- default it
    platerInternal.ReBuildAbbreviateConfig = function()
        if not platerInternal.abbreviateConfig then return end -- if it could not be defaulted, skip this.
        local myriadK, myriadM, myriadB, myriadT
        if DB_NUMBER_REGION_EAST_ASIA then
            -- use the easter locale
            myriadM, myriadB = eastAsiaMyriads_10k, eastAsiaMyriads_1B
            platerInternal.abbreviateConfig = {
                breakpointData = {
                    {
                        breakpoint=1000000000,
                        significandDivisor=100000000,
                        fractionDivisor=1,
                        abbreviationIsGlobal=false,
                        abbreviation=myriadB
                    },
                    {
                        breakpoint=100000000,
                        significandDivisor=10000000,
                        fractionDivisor=10,
                        abbreviationIsGlobal=false,
                        abbreviation=myriadB
                    },
                    {
                        breakpoint=100000,
                        significandDivisor=10000,
                        fractionDivisor=1,
                        abbreviationIsGlobal=false,
                        abbreviation=myriadM
                    },
                    {
                        breakpoint=10000,
                        significandDivisor=1000,
                        fractionDivisor=10,
                        abbreviationIsGlobal=false,
                        abbreviation=myriadM
                    }
                }
            }
        else
            -- default to eastern locale
            myriadK, myriadM, myriadB, myriadT = "K", "M", "B", "T"
            platerInternal.abbreviateConfig = {
                breakpointData = {
                    {
                        breakpoint=10000000000000,
                        significandDivisor=1000000000000,
                        fractionDivisor=1,
                        abbreviationIsGlobal=false,
                        abbreviation=myriadT
                    },
                    {
                        breakpoint=1000000000000,
                        significandDivisor=100000000000,
                        fractionDivisor=10,
                        abbreviationIsGlobal=false,
                        abbreviation=myriadT
                    },
                    {
                        breakpoint=10000000000,
                        significandDivisor=1000000000,
                        fractionDivisor=1,
                        abbreviationIsGlobal=false,
                        abbreviation=myriadB
                    },
                    {
                        breakpoint=1000000000,
                        significandDivisor=100000000,
                        fractionDivisor=10,
                        abbreviationIsGlobal=false,
                        abbreviation=myriadB
                    },
                    {
                        breakpoint=10000000,
                        significandDivisor=1000000,
                        fractionDivisor=1,
                        abbreviationIsGlobal=false,
                        abbreviation=myriadM
                    },
                    {
                        breakpoint=1000000,
                        significandDivisor=100000,
                        fractionDivisor=10,
                        abbreviationIsGlobal=false,
                        abbreviation=myriadM
                    },
                    {
                        breakpoint=10000,
                        significandDivisor=1000,
                        fractionDivisor=1,
                        abbreviationIsGlobal=false,
                        abbreviation=myriadK
                    },
                    {
                        breakpoint=1000,
                        significandDivisor=100,
                        fractionDivisor=10,
                        abbreviationIsGlobal=false,
                        abbreviation=myriadK
                    }
                }
            }
        end
    end

    if CreateAbbreviateConfig then
        local abbreviateSettings = CreateAbbreviateConfig(platerInternal.abbreviateConfig)
        abbreviateSettings = {config = abbreviateSettings}
        platerInternal.abbreviateConfig = abbreviateSettings
    end

    Plater.GetAbbreviateConfig = function ()
        return platerInternal.abbreviateConfig
    end

    function Plater.FormatNumber (number)
        if (DB_NUMBER_REGION_EAST_ASIA) then
            if (number > 99999999) then
                return format ("%.2f", number/100000000) .. eastAsiaMyriads_1B

            elseif (number > 999999) then
                return format ("%.2f", number/10000) .. eastAsiaMyriads_10k

            elseif (number > 99999) then
                return floor (number/10000) .. eastAsiaMyriads_10k

            elseif (number > 9999) then
                return format ("%.1f", (number/10000)) .. eastAsiaMyriads_10k

            elseif (number > 999) then
                return format ("%.1f", (number/1000)) .. eastAsiaMyriads_1k

            end

            return format ("%.1f", number)
        else
            if (number > 999999999) then
                return format ("%.2fB", number/1000000000)

            elseif (number > 999999) then
                return format ("%.2fM", number/1000000)

            elseif (number > 99999) then
                return floor (number/1000) .. "K"

            elseif (number > 999) then
                return format ("%.1fK", (number/1000))

            end

            return floor (number)
        end
    end

end