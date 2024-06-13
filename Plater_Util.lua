
local _
local addonName, platerInternal = ...
local detailsFramework = _G.DetailsFramework

function platerInternal.NumberToHex(number)
    local hex = string.format("%x", number)
    if (#hex == 1) then
        hex = "0" .. hex
    end
    return hex
end

local colorHueCache = {}
for colorName, colorTable in pairs(detailsFramework:GetDefaultColorList()) do
    colorHueCache[colorName] = detailsFramework:GetColorHue(unpack(colorTable))
end

local function sortColors(t1, t2)
    return colorHueCache[t1[2]] > colorHueCache[t2[2]]
end

local ignoredColors = {
    ["transparent"] = true,
    ["black"] = true,
    ["none"] = true,
}

local colorNoValue = {1, 1, 1, 0.5}
local dropdownStatusBarTexture = platerInternal.Defaults.dropdownStatusBarTexture
local dropdownStatusBarColor = platerInternal.Defaults.dropdownStatusBarColor

function platerInternal.RefreshColorDropdown(frame, dropdown, dbColors, onSelectColorCallback, keyWithValue, enabledIndex, colorIndex)
    local currentValue = dropdown[keyWithValue]
    if (not currentValue) then
        return {}
    end

    local optionsTableToReturn

    if (not frame.cachedColorTable) then
        local colorList = {}
        local colorsAlreadyAdded = {}
        local dropdownOptions = {}

        --add, in the top of the list, colors that are already in use
        for _, colorTable in pairs(dbColors) do
            local bInEnabled
            if (enabledIndex) then
                bInEnabled = colorTable[enabledIndex]
            else
                bInEnabled = true
            end

            local color = colorTable[colorIndex]

            if (bInEnabled and not colorsAlreadyAdded[color]) then
                colorsAlreadyAdded[color] = true
                local r, g, b = detailsFramework:ParseColors(color)
                table.insert(colorList, {{r, g, b}, color})
            end
        end

        for index, colorTable in ipairs(colorList) do
            local colortable = colorTable[1]
            local colorname = colorTable[2]
            table.insert(dropdownOptions, {
                label = " " .. colorname,
                value = colorname,
                color = colortable,
                onclick = onSelectColorCallback,
                statusbar = dropdownStatusBarTexture,
                statusbarcolor = dropdownStatusBarColor,
                icon = [[Interface\AddOns\Plater\media\star_empty_64]],
                iconcolor = {1, 1, 1, .6},
                favorite = true,
            })
        end

        --all colors
        local allColors = {}
        for colorName, colorTable in pairs(detailsFramework:GetDefaultColorList()) do
            if (not colorsAlreadyAdded[colorName] and not ignoredColors[colorName]) then
                table.insert(allColors, {colorTable, colorName})
            end
        end
        table.sort(allColors, sortColors)

        for index, colorTable in ipairs(allColors) do
            local colortable = colorTable[1]
            local colorname = colorTable[2]

            table.insert(dropdownOptions, {
                label = colorname,
                value = colorname,
                color = colortable,
                onclick = onSelectColorCallback,
                statusbar = dropdownStatusBarTexture,
                statusbarcolor = dropdownStatusBarColor,
            })
        end

        table.insert(dropdownOptions, 1, {
            label = "no color",
            value = platerInternal.RemoveColor,
            color = colorNoValue,
            statusbar = dropdownStatusBarTexture,
            statusbarcolor = dropdownStatusBarColor,
            onclick = onSelectColorCallback
        })

        frame.cachedColorTable = dropdownOptions
        optionsTableToReturn = dropdownOptions
    else
        optionsTableToReturn = frame.cachedColorTable
    end

    local dropdownColorTableCurrentSelected = dbColors[currentValue]
    if (dropdownColorTableCurrentSelected) then
        local bColorIsEnabled = dropdownColorTableCurrentSelected[enabledIndex]
        local colorNameInUse = dropdownColorTableCurrentSelected[colorIndex]

        if (bColorIsEnabled) then
            for i = 1, #optionsTableToReturn do
                local option = optionsTableToReturn[i]
                if (option.value ~= platerInternal.NoColor) then
                    option.desc = "Hold Shift to change the color of all npcs with the color " .. detailsFramework:AddColorToText(colorNameInUse, colorNameInUse) .. " to " .. detailsFramework:AddColorToText(option.value, option.value) .. "."
                end
            end
        else
            for i = 1, #optionsTableToReturn do
                local option = optionsTableToReturn[i]
                option.desc = nil
            end
        end
    end

    return optionsTableToReturn
end
