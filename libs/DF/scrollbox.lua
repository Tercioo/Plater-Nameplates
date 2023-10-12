
---@type detailsframework
local detailsFramework = _G["DetailsFramework"]
if (not detailsFramework or not DetailsFrameworkCanLoad) then
	return
end

local CreateFrame = CreateFrame

---@class df_gridscrollbox_options : table
---@field width number?
---@field height number?
---@field line_amount number?
---@field line_height number?
---@field columns_per_line number?
---@field auto_amount boolean?
---@field no_scroll boolean?
---@field vertical_padding number?
---@field no_backdrop boolean?

---@type df_gridscrollbox_options
local grid_scrollbox_options = {
	width = 600,
	height = 400,
	line_amount = 10,
	line_height = 30,
    columns_per_line = 4,
	auto_amount = false,
	no_scroll = false,
    vertical_padding = 1,
    no_backdrop = false,
}

---@class df_gridscrollbox : df_scrollbox

---create a scrollbox with a grid layout
---@param parent frame
---@param name string
---@param refreshFunc function
---@param data table
---@param createOptionFrameFunc function
---@param options df_gridscrollbox_options?
---@return unknown
function detailsFramework:CreateGridScrollBox(parent, name, refreshFunc, data, createOptionFrameFunc, options)
    options = options or {}

	local width = options.width or grid_scrollbox_options.width
	local height = options.height or grid_scrollbox_options.height
	local lineAmount = options.line_amount or grid_scrollbox_options.line_amount
	local lineHeight = options.line_height or grid_scrollbox_options.line_height
    local columnsPerLine = options.columns_per_line or grid_scrollbox_options.columns_per_line
	local autoAmount = options.auto_amount
	local noScroll = options.no_scroll
	local noBackdrop = options.no_backdrop
    local verticalPadding = options.vertical_padding or grid_scrollbox_options.vertical_padding

    local createLineFunc = function(scrollBox, lineIndex)
        local line = CreateFrame("frame", "$parentLine" .. lineIndex, scrollBox)
        line:SetSize(width, lineHeight)
        line:SetPoint("top", scrollBox, "top", 0, -((lineIndex-1) * (lineHeight + verticalPadding)))
        line.optionFrames = {}

        for columnIndex = 1, columnsPerLine do
            --dispatch payload: line, lineIndex, columnIndex
            local optionFrame = createOptionFrameFunc(line, lineIndex, columnIndex)
            line.optionFrames[columnIndex] = optionFrame
            optionFrame:SetPoint("left", line, "left", (columnIndex-1) * (width/columnsPerLine), 0)
        end

        return line
    end

    local onSetData = function(self, data)
        local newData = {}

        for i = 1, #data, columnsPerLine do
            local thisColumnData = {}

            for o = 1, columnsPerLine do
                local index = i + (o-1)
                local thisData = data[index]
                if (thisData) then
                    thisColumnData[#thisColumnData+1] = thisData
                end
            end
            newData[#newData+1] = thisColumnData
        end

        self.data = newData
    end

    local refreshGrid = function(scrollBox, thisData, offset, totalLines)
        for i = 1, totalLines do
            local index = i + offset
            local lineData = thisData[index]

            if (lineData) then
                local line = scrollBox:GetLine(i)
                for o = 1, columnsPerLine do
                    local optionFrame = line.optionFrames[o]
                    local data = lineData[o]
                    if (data) then
                        detailsFramework:Dispatch(refreshFunc, optionFrame, data)
                        optionFrame:Show()
                        line:Show()
                    else
                        optionFrame:Hide()
                    end
                end
            end
        end
    end

	local scrollBox = detailsFramework:CreateScrollBox(parent, name, refreshGrid, data, width, height, lineAmount, lineHeight, createLineFunc, autoAmount, noScroll, noBackdrop)
    scrollBox:CreateLines(createLineFunc, lineAmount)
    detailsFramework:ReskinSlider(scrollBox)
    scrollBox.OnSetData = onSetData
    onSetData(scrollBox, data)

	return scrollBox
end
