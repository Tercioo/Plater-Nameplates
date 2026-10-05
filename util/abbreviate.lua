
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

local DB_NUMBER_REGION_EAST_ASIA

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

    local defaultBreakpoints = C_StringUtil and C_StringUtil.GetDefaultAbbreviationBreakpoints and C_StringUtil.GetDefaultAbbreviationBreakpoints(GetLocale())
    platerInternal.abbreviateConfig = defaultBreakpoints -- default it

    --AbbreviateNumbers() reads every field of every entry of 'breakpointData' on each call,
    --and those entries are addon created tables, so each read taints secure execution and
    --writes a taint log line: with the lists below that is 40 lines per nameplate health
    --update. blizzard documents 'config' as the path for repeated calls with the same
    --options, and reading it costs a single field access instead.
    local buildAbbreviateConfig = function(breakpointData)
        if (CreateAbbreviateConfig and breakpointData) then
            --CreateAbbreviateConfig raises on breakpoints it rejects, so never call it
            --unguarded; keep the old slow path as the fallback.
            local okay, config = pcall(CreateAbbreviateConfig, breakpointData)
            if (okay and config) then
                return {config = config}
            end
        end
        return {breakpointData = breakpointData}
    end

    --isEastAsia is an optional override; omitted, the region comes from the profile.
    --the cached value lives in this file so Plater.FormatNumber reads it as an upvalue
    --instead of the nil global it used to find here.
    platerInternal.ReBuildAbbreviateConfig = function(isEastAsia)
        if (isEastAsia == nil) then
            isEastAsia = Plater.db.profile.number_region == "eastasia"
        end
        DB_NUMBER_REGION_EAST_ASIA = isEastAsia

        if not platerInternal.abbreviateConfig then return end -- if it could not be defaulted, skip this.

        local myriadK, myriadM, myriadB, myriadT
        if isEastAsia then
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

        --convert the list just built into a cached config object, otherwise every
        --AbbreviateNumbers() call walks the raw entries again.
        platerInternal.abbreviateConfig = buildAbbreviateConfig(platerInternal.abbreviateConfig.breakpointData)
    end

    --ReBuildAbbreviateConfig only runs once the profile is loaded, so convert the
    --locale defaults too for the calls that happen before that.
    if (defaultBreakpoints) then
        platerInternal.abbreviateConfig = buildAbbreviateConfig(defaultBreakpoints)
    end

    Plater.GetAbbreviateConfig = function ()
        return platerInternal.abbreviateConfig
    end

    --isEastAsia is optional: omitted, it falls back to the region cached from the profile,
    --so existing Plater.FormatNumber(number) callers and user scripts keep working.
    function Plater.FormatNumber (number, isEastAsia)
        if (isEastAsia == nil) then
            isEastAsia = DB_NUMBER_REGION_EAST_ASIA
        end

        if (isEastAsia) then
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