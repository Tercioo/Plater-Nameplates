
local detailsFramework = _G["DetailsFramework"]
if (not detailsFramework or not DetailsFrameworkCanLoad) then
	return
end

---@cast detailsFramework detailsframework

local CreateFrame = CreateFrame
local unpack = unpack
local wipe = table.wipe
local _

--[=[
    file description: this file has the code for the object editor
    the object editor itself is a frame and has a scrollframe as canvas showing another frame where there's the options for the editing object

--]=]


--the editor doesn't know which key in the profileTable holds the current value for an attribute, so it uses a map table to find it.
--the mapTable is a table with the attribute name as a key, and the value is the profile key. For example, {["size"] = "text_size"} means profileTable["text_size"] = 10.

---@class df_editor_attribute
---@field name string?
---@field label string?
---@field widget string
---@field default any?
---@field minvalue number?
---@field maxvalue number?
---@field step number?
---@field usedecimals boolean?
---@field subkey string?

--which object attributes are used to build the editor menu for each object type
local attributes = {
    ---@type df_editor_attribute[]
    FontString = {
        {
            name = "text",
            label = "Text",
            widget = "textentry",
            default = "font string text",
            setter = function(widget, value) widget:SetText(value) end,
        },
        {
            name = "size",
            label = "Size",
            widget = "range",
            minvalue = 5,
            maxvalue = 120,
            setter = function(widget, value) widget:SetFont(widget:GetFont(), value, select(3, widget:GetFont())) end
        },
        {
            name = "font",
            label = "Font",
            widget = "fontdropdown",
            setter = function(widget, value)
                local font = LibStub:GetLibrary("LibSharedMedia-3.0"):Fetch("font", value)
                widget:SetFont(font, select(2, widget:GetFont()))
            end
        },
        {
            name = "color",
            label = "Color",
            widget = "color",
            setter = function(widget, value) widget:SetTextColor(unpack(value)) end
        },
        {
            name = "alpha",
            label = "Alpha",
            widget = "range",
            setter = function(widget, value) widget:SetAlpha(value) end
        },
        {widget = "blank"},
        {
            name = "shadow",
            label = "Draw Shadow",
            widget = "toggle",
            setter = function(widget, value) widget:SetShadowColor(widget:GetShadowColor(), select(2, widget:GetShadowColor()), select(3, widget:GetShadowColor()), value and 0.5 or 0) end
        },
        {
            name = "shadowcolor",
            label = "Shadow Color",
            widget = "color",
            setter = function(widget, value) widget:SetShadowColor(unpack(value)) end
        },
        {
            name = "shadowoffsetx",
            label = "Shadow X Offset",
            widget = "range",
            minvalue = -10,
            maxvalue = 10,
            setter = function(widget, value) widget:SetShadowOffset(value, select(2, widget:GetShadowOffset())) end
        },
        {
            name = "shadowoffsety",
            label = "Shadow Y Offset",
            widget = "range",
            minvalue = -10,
            maxvalue = 10,
            setter = function(widget, value) widget:SetShadowOffset(widget:GetShadowOffset(), value) end
        },
        {
            name = "outline",
            label = "Outline",
            widget = "outlinedropdown",
            setter = function(widget, value) widget:SetFont(widget:GetFont(), select(2, widget:GetFont()), value) end
        },
        {widget = "blank"},
        {
            name = "anchor",
            label = "Anchor",
            widget = "anchordropdown",
            setter = function(widget, value) detailsFramework:SetAnchor(widget, value, widget:GetParent()) end
        },
        {
            name = "anchoroffsetx",
            label = "Anchor X Offset",
            widget = "range",
            minvalue = -100,
            maxvalue = 100,
            setter = function(widget, value) detailsFramework:SetAnchor(widget, value, widget:GetParent()) end
        },
        {
            name = "anchoroffsety",
            label = "Anchor Y Offset",
            widget = "range",
            minvalue = -100,
            maxvalue = 100,
            setter = function(widget, value) detailsFramework:SetAnchor(widget, value, widget:GetParent()) end
        },
        {
            name = "rotation",
            label = "Rotation",
            widget = "range",
            usedecimals = true,
            minvalue = 0,
            maxvalue = math.pi*2,
            setter = function(widget, value) widget:SetRotation(value) end
        },
    }
}

---@class df_editormixin : table
---@field GetEditingObject fun(self:df_editor):uiobject
---@field GetEditingOptions fun(self:df_editor):df_editobjectoptions
---@field GetExtraOptions fun(self:df_editor):table
---@field GetEditingProfile fun(self:df_editor):table, table
---@field GetOnEditCallback fun(self:df_editor):function
---@field GetOptionsFrame fun(self:df_editor):frame
---@field GetCanvasScrollBox fun(self:df_editor):df_canvasscrollbox
---@field EditObject fun(self:df_editor, object:uiobject, profileTable:table, profileKeyMap:table, extraOptions:table?, callback:function?, options:df_editobjectoptions?)
---@field PrepareObjectForEditing fun(self:df_editor)
---@field CreateMoverGuideLines fun(self:df_editor)
---@field GetOverTheTopFrame fun(self:df_editor):frame
---@field GetMoverFrame fun(self:df_editor):frame
---@field StartObjectMovement fun(self:df_editor, anchorSettings:df_anchor)
---@field StopObjectMovement fun(self:df_editor)

---@class df_editobjectoptions : table
---@field use_colon boolean if true a colon is shown after the option name
---@field can_move boolean if true the object can be moved
---@field use_guide_lines boolean if true guide lines are shown when the object is being moved

---@type df_editobjectoptions
local editObjectDefaultOptions = {
    use_colon = true,
    can_move = true,
    use_guide_lines = true,
}

local getParentTable = function(profileTable, profileKey)
    local parentPath
    if (profileKey:match("%]$")) then
        parentPath = profileKey:gsub("%s*%[.*%]%s*$", "")
    else
        parentPath = profileKey:gsub("%.[^.]*$", "")
    end

    local parentTable = detailsFramework.table.getfrompath(profileTable, parentPath)
    return parentTable
end

detailsFramework.EditorMixin = {
    ---@param self df_editor
    GetEditingObject = function(self)
        return self.editingObject
    end,

    ---@param self df_editor
    ---@return df_editobjectoptions
    GetEditingOptions = function(self)
        return self.editingOptions
    end,

    ---@param self df_editor
    ---@return table
    GetExtraOptions = function(self)
        return self.editingExtraOptions
    end,

    ---@param self df_editor
    ---@return table, table
    GetEditingProfile = function(self)
        return self.editingProfileTable, self.editingProfileMap
    end,

    ---@param self df_editor
    ---@return function
    GetOnEditCallback = function(self)
        return self.onEditCallback
    end,

    GetOptionsFrame = function(self)
        return self.optionsFrame
    end,

    GetOverTheTopFrame = function(self)
        return self.overTheTopFrame
    end,

    GetMoverFrame = function(self)
        return self.moverFrame
    end,

    GetCanvasScrollBox = function(self)
        return self.canvasScrollBox
    end,

    ---@param self df_editor
    ---@param object uiobject
    ---@param profileTable table
    ---@param profileKeyMap table
    ---@param extraOptions table? a way to add more options other than the default attributes for the object.
    ---@param callback function? calls when an attribute is changed with the payload: editingObject, optionName, newValue, profileTable, profileKey
    ---@param options df_editobjectoptions?
    EditObject = function(self, object, profileTable, profileKeyMap, extraOptions, callback, options)
        assert(type(object) == "table", "EditObject(object) expects an UIObject on first parameter.")
        assert(type(profileTable) == "table", "EditObject(object) expects a table on second parameter.")
        assert(object.GetObjectType, "EditObject(object) expects an UIObject on first parameter.")

        --clear previous values
        self.editingObject = nil
        self.editingProfileMap = nil
        self.editingProfileTable = nil
        self.editingOptions = nil
        self.editingExtraOptions = nil
        self.onEditCallback = nil

        --deploy the options table
        options = type(options) == "table" and options or {}
        detailsFramework.table.deploy(options, editObjectDefaultOptions)

        --as there's no other place which this members are set, there is no need to create setter functions
        self.editingObject = object
        self.editingProfileMap = profileKeyMap
        self.editingProfileTable = profileTable
        self.editingOptions = options
        self.editingExtraOptions = extraOptions or {}

        if (type(callback) == "function") then
            self.onEditCallback = callback
        elseif (callback) then
            error("EditObject(object) callback must be a function or nil.")
        end

        self:PrepareObjectForEditing()
    end,

    ---@param self df_editor
    CreateMoverGuideLines = function(self)
        local overTheTopFrame = self:GetOverTheTopFrame()
        local moverFrame = self:GetMoverFrame()

        self.moverGuideLines = {
            left = overTheTopFrame:CreateTexture(nil, "overlay"),
            right = overTheTopFrame:CreateTexture(nil, "overlay"),
            top = overTheTopFrame:CreateTexture(nil, "overlay"),
            bottom = overTheTopFrame:CreateTexture(nil, "overlay"),
        }

        for side, texture in pairs(self.moverGuideLines) do
            texture:SetColorTexture(.8, .8, .8, 0.1)
            texture:SetSize(1, 1)
            texture:SetDrawLayer("overlay", 7)
            texture:Hide()

            if (side == "left" or side == "right") then
                texture:SetHeight(1)
                texture:SetWidth(GetScreenWidth())
            else
                texture:SetWidth(1)
                texture:SetHeight(GetScreenHeight())
            end
        end
    end,

    UpdateGuideLinesAnchors = function(self)
        local object = self:GetEditingObject()

        for side, texture in pairs(self.moverGuideLines) do
            texture:ClearAllPoints()
            if (side == "left" or side == "right") then
                if (side == "left") then
                    texture:SetPoint("right", object, "left", -2, 0)
                else
                    texture:SetPoint("left", object, "right", 2, 0)
                end
            else
                if (side == "top") then
                    texture:SetPoint("bottom", object, "top", 0, 2)
                else
                    texture:SetPoint("top", object, "bottom", 0, -2)
                end
            end
        end
    end,

    PrepareObjectForEditing = function(self)
        --get the object and its profile table with the current values
        local object = self:GetEditingObject()
        local profileTable, profileMap = self:GetEditingProfile()
        profileMap = profileMap or {}

        if (not object or not profileTable) then
            return
        end

        --get the object type
        local objectType = object:GetObjectType()
        local attributeList

        --get options and extra options
        local editingOptions = self:GetEditingOptions()
        local extraOptions = self:GetExtraOptions()

        --get the attribute list for the object type
        if (objectType == "FontString") then
            ---@cast object fontstring
            attributeList = attributes[objectType]
        end

        --if there's extra options, add the attributeList to a new table and right after the extra options
        if (extraOptions and #extraOptions > 0) then
            local attributeListWithExtraOptions = {}

            for i = 1, #attributeList do
                attributeListWithExtraOptions[#attributeListWithExtraOptions+1] = attributeList[i]
            end

            attributeListWithExtraOptions[#attributeListWithExtraOptions+1] = {widget = "blank", default = true}

            for i = 1, #extraOptions do
                attributeListWithExtraOptions[#attributeListWithExtraOptions+1] = extraOptions[i]
            end

            attributeList = attributeListWithExtraOptions
        end

        local anchorSettings

        --table to use on DF:BuildMenu()
        local menuOptions = {}
        for i = 1, #attributeList do
            local option = attributeList[i]

            if (option.widget == "blank") then
                menuOptions[#menuOptions+1] = {type = "blank"}
            else
                --get the key to be used on profile table
                local profileKey = profileMap[option.name]
                local value

                --if the key contains a dot or a bracket, it means it's a table path, example: "text_settings[1].width"
                if (profileKey and (profileKey:match("%.") or profileKey:match("%["))) then
                    value = detailsFramework.table.getfrompath(profileTable, profileKey)
                else
                    value = profileTable[profileKey]
                end

                --if no value is found, attempt to get a default
                if (type(value) == "nil") then
                    value = option.default
                end

                local bHasValue = type(value) ~= "nil"

                local minValue = option.minvalue
                local maxValue = option.maxvalue

                if (option.name == "anchoroffsetx") then
                    minValue = -object:GetParent():GetWidth()/2
                    maxValue = object:GetParent():GetWidth()/2
                elseif (option.name == "anchoroffsety") then
                    minValue = -object:GetParent():GetHeight()/2
                    maxValue = object:GetParent():GetHeight()/2
                end

                if (option.name == "classcolor") then print("", value) end

                if (bHasValue) then
                    if (option.name == "classcolor") then print("HERE", value) end

                    local parentTable = getParentTable(profileTable, profileKey)

                    if (option.name == "anchor" or option.name == "anchoroffsetx" or option.name == "anchoroffsety") then
                        anchorSettings = parentTable
                    end

                    menuOptions[#menuOptions+1] = {
                        type = option.widget,
                        name = option.label,
                        get = function() return value end,
                        set = function(widget, fixedValue, newValue, ...)
                            --color is a table with 4 indexes for each color plus alpha
                            if (option.widget == "color") then
                                --calor callback sends the red color in the fixedParameter slot
                                local r, g, b, alpha = fixedValue, newValue, ...
                                --need to use the same table from the profile table
                                parentTable[1] = r
                                parentTable[2] = g
                                parentTable[3] = b
                                parentTable[4] = alpha

                                newValue = parentTable
                            else
                                detailsFramework.table.setfrompath(profileTable, profileKey, newValue)
                            end

                            if (self:GetOnEditCallback()) then
                                self:GetOnEditCallback()(object, option.name, newValue, profileTable, profileKey)
                            end

                            --update the widget visual
                            --anchoring uses SetAnchor() which require the anchorTable to be passed
                            if (option.name == "anchor" or option.name == "anchoroffsetx" or option.name == "anchoroffsety") then
                                anchorSettings = parentTable

                                if (option.name == "anchor") then
                                    anchorSettings.x = 0
                                    anchorSettings.y = 0
                                end

                                self:StopObjectMovement()

                                option.setter(object, parentTable)

                                if (editingOptions.can_move) then
                                    self:StartObjectMovement(anchorSettings)
                                end
                            else
                                option.setter(object, newValue)
                            end
                        end,
                        min = minValue,
                        max = maxValue,
                        step = option.step,
                        usedecimals = option.usedecimals,
                        id = option.name,
                    }
                end
            end
        end

        --at this point, the optionsTable is ready to be used on DF:BuildMenuVolatile()
        menuOptions.align_as_pairs = true
        menuOptions.align_as_pairs_length = 150
        menuOptions.widget_width = 180

        local optionsFrame = self:GetOptionsFrame()
        local canvasScrollBox = self:GetCanvasScrollBox()

        local bUseColon = editingOptions.use_colon

        local bSwitchIsCheckbox = true
        local maxHeight = 5000

        local amountOfOptions = #menuOptions
        local optionsFrameHeight = amountOfOptions * 20
        optionsFrame:SetHeight(optionsFrameHeight)

        --templates
        local options_text_template = detailsFramework:GetTemplate("font", "OPTIONS_FONT_TEMPLATE")
        local options_dropdown_template = detailsFramework:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE")
        local options_switch_template = detailsFramework:GetTemplate("switch", "OPTIONS_CHECKBOX_TEMPLATE")
        local options_slider_template = detailsFramework:GetTemplate("slider", "OPTIONS_SLIDER_TEMPLATE")
        local options_button_template = detailsFramework:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE")

        detailsFramework:BuildMenu(optionsFrame, menuOptions, 0, -2, maxHeight, bUseColon, options_text_template, options_dropdown_template, options_switch_template, bSwitchIsCheckbox, options_slider_template, options_button_template)

        if (editingOptions.can_move) then
            self:StartObjectMovement(anchorSettings)
        end
    end,

    ---@param self df_editor
    ---@param anchorSettings df_anchor
    StartObjectMovement = function(self, anchorSettings)
        local object = self:GetEditingObject()
        local moverFrame = self:GetMoverFrame()

        moverFrame:EnableMouse(true)
        moverFrame:SetMovable(true)
        moverFrame:ClearAllPoints()
        moverFrame:SetPoint("topleft", object, "topleft", -4, 4)
        moverFrame:SetPoint("bottomright", object, "bottomright", 4, -4)
        moverFrame:Show()

        --self:UpdateGuideLinesAnchors()

        --update the mover frame size to match the object size
        if (object:GetObjectType() == "FontString") then
            ---@cast object fontstring
            local width = object:GetStringWidth()
            local height = object:GetStringHeight()
            moverFrame:SetSize(width, height)
        else
            local width, height = object:GetSize()
            moverFrame:SetSize(width, height)
        end

        moverFrame:SetScript("OnMouseDown", function()
            moverFrame:StartMoving()
            moverFrame.bIsMoving = true
        end)

        moverFrame:SetScript("OnMouseUp", function()
            moverFrame:StopMovingOrSizing()
            moverFrame.bIsMoving = false
        end)

        --update guidelines
        if (self:GetEditingOptions().use_guide_lines) then
            --show all four guidelines
            for side, texture in pairs(self.moverGuideLines) do
                texture:Show()
            end
        end

        local optionsFrame = self:GetOptionsFrame()

        --record the current position of the moverFrame to check later if the frame has moved
        --if the moverFrame has moved, need to update the anchor settings x and y values
        local currentPosX, currentPosY = moverFrame:GetCenter()

        moverFrame:SetScript("OnUpdate", function()
            --if the object isn't moving, make the mover follow the object position
            if (moverFrame.bIsMoving) then
                --if the object is moving, check if the moverFrame has moved
                local newPosX, newPosY = moverFrame:GetCenter()

                --did the frame moved?
                if (newPosX ~= currentPosX or newPosY ~= currentPosY) then
                    --if the moverFrame has moved, update the anchor settings
                    local xOffset = newPosX - currentPosX
                    local yOffset = newPosY - currentPosY
                    anchorSettings.x = anchorSettings.x + xOffset
                    anchorSettings.y = anchorSettings.y + yOffset

                    --update the anchor x and y slider's shown value without calling the callback
                    local anchorXSlider = optionsFrame:GetWidgetById("anchoroffsetx")
                    anchorXSlider:SetValueNoCallback(anchorSettings.x)
                    local anchorYSlider = optionsFrame:GetWidgetById("anchoroffsety")
                    anchorYSlider:SetValueNoCallback(anchorSettings.y)

                    --update the object anchor
                    detailsFramework:SetAnchor(object, anchorSettings, object:GetParent())

                    --update the current position
                    currentPosX, currentPosY = newPosX, newPosY
                end
            else
                moverFrame:ClearAllPoints()
                moverFrame:SetPoint("topleft", object, "topleft", -4, 4)
                moverFrame:SetPoint("bottomright", object, "bottomright", 4, -4)
            end

            --update the mover frame size to match the object size
            if (object:GetObjectType() == "FontString") then
                ---@cast object fontstring
                local width = object:GetStringWidth()
                local height = object:GetStringHeight()
                moverFrame:SetSize(width, height)
            else
                local width, height = object:GetSize()
                moverFrame:SetSize(width, height)
            end
        end)
    end,

    ---@param self df_editor
    StopObjectMovement = function(self)
        local moverFrame = self:GetMoverFrame()

        moverFrame:EnableMouse(false)
        moverFrame:SetScript("OnUpdate", nil)

        --hide all four guidelines
        for side, texture in pairs(self.moverGuideLines) do
            texture:Hide()
        end

        moverFrame:Hide()
    end,
}

local editorDefaultOptions = {
    width = 400,
    height = 600,
}

---@class df_editor : frame, df_optionsmixin, df_editormixin
---@field options table
---@field editingObject uiobject
---@field editingProfileTable table
---@field editingProfileMap table
---@field editingOptions df_editobjectoptions
---@field editingExtraOptions table
---@field onEditCallback function
---@field optionsFrame frame
---@field overTheTopFrame frame
---@field moverFrame frame
---@field moverGuideLines table<string, texture>
---@field canvasScrollBox df_canvasscrollbox

function detailsFramework:CreateEditor(parent, name, options)
    name = name or ("DetailsFrameworkEditor" .. math.random(100000, 10000000))
    local editorFrame = CreateFrame("frame", name, parent, "BackdropTemplate")

    detailsFramework:Mixin(editorFrame, detailsFramework.EditorMixin)
    detailsFramework:Mixin(editorFrame, detailsFramework.OptionsFunctions)

    editorFrame:BuildOptionsTable(editorDefaultOptions, options)

    editorFrame:SetSize(editorFrame.options.width, editorFrame.options.height)

    --options frame is the frame that holds the options for the editing object, it is used as the parent frame for BuildMenuVolatile()
    local optionsFrame = CreateFrame("frame", name .. "OptionsFrame", editorFrame, "BackdropTemplate")
    optionsFrame:SetSize(editorFrame.options.width, 5000)

    local canvasFrame = detailsFramework:CreateCanvasScrollBox(editorFrame, optionsFrame, name .. "CanvasScrollBox")
    canvasFrame:SetAllPoints()

    --over the top frame is a frame that is always on top of everything else
    local OTTFrame = CreateFrame("frame", "$parentOTTFrame", UIParent)
    OTTFrame:SetFrameStrata("TOOLTIP")
    editorFrame.overTheTopFrame = OTTFrame

    --frame that is used to move the object
    local moverFrame = CreateFrame("frame", "$parentMoverFrame", OTTFrame, "BackdropTemplate")
    moverFrame:SetClampedToScreen(true)
    moverFrame:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    editorFrame.moverFrame = moverFrame

    editorFrame:CreateMoverGuideLines()

    editorFrame.optionsFrame = optionsFrame
    editorFrame.canvasScrollBox = canvasFrame

    return editorFrame
end
