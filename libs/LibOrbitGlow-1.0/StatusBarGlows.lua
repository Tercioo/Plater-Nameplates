local lib = LibStub("LibOrbitGlow-1.0", true)
local VERSION = 14
if not lib or lib.minorVersion ~= VERSION or lib.statusBarMinor == VERSION then
    return
end
lib.statusBarMinor = VERSION

local LIB_PATH = debugstack(1, 1, 0):match("Interface.*LibOrbitGlow%-1%.0[\\/]")
local DEFAULT_GLOW = "tracer"
local DEFAULT_ROWS, DEFAULT_COLS, DEFAULT_FRAMES = 6, 5, 30
local DEFAULT_DURATION, DEFAULT_OVERHANG = 1, 0.125
local BODY_SUBLEVEL, CORE_SUBLEVEL = 5, 6
local DEFAULT_CORE_ALPHA = 0.85
local MAX_CORNER_FRACTION = 0.5
local CONTOUR_FIELDS = { rounded = "radius", chamfer = "cut", notch = "radius", blade = "cut" }
local CONTOUR_FRACTIONS =
    { rounded = "radiusFraction", chamfer = "cutFraction", notch = "radiusFraction", blade = "cutFraction" }
local EMPTY_CONTOURS = {}
local BLENDS = { ADD = true, BLEND = true, ALPHAKEY = true, MOD = true, DISABLE = true }

lib.statusBarGlows = lib.statusBarGlows or {}
lib.statusBarRevision = lib.statusBarRevision or 0
lib.StatusBar = lib.StatusBar or {}
local StatusBar = lib.StatusBar

local function IsNumber(value, minimum, integer)
    return type(value) == "number"
        and not issecretvalue(value)
        and value == value
        and value < math.huge
        and value >= minimum
        and (not integer or value % 1 == 0)
end

function lib:RegisterStatusBarGlow(name, definition)
    if type(name) ~= "string" or name == "" or type(definition) ~= "table" then
        return false
    end
    if type(definition.variants) ~= "table" or #definition.variants == 0 then
        return false
    end
    local def = {
        label = definition.label or name,
        source = definition.source or "Unknown",
        rows = definition.rows or DEFAULT_ROWS,
        cols = definition.cols or DEFAULT_COLS,
        frames = definition.frames or DEFAULT_FRAMES,
        duration = definition.duration or DEFAULT_DURATION,
        overhang = definition.overhang or DEFAULT_OVERHANG,
        core = definition.core ~= false,
        coreAlpha = definition.coreAlpha or DEFAULT_CORE_ALPHA,
        bodyBlend = definition.bodyBlend or "BLEND",
        coreBlend = definition.coreBlend or "ADD",
        ext = definition.ext or ".tga",
        shapes = {},
        contours = {},
        variants = {},
    }
    if
        type(def.label) ~= "string"
        or type(def.source) ~= "string"
        or type(def.ext) ~= "string"
        or not IsNumber(def.rows, 1, true)
        or not IsNumber(def.cols, 1, true)
        or not IsNumber(def.frames, 1, true)
        or def.frames > def.rows * def.cols
        or not IsNumber(def.duration, 0)
        or def.duration == 0
        or not IsNumber(def.overhang, 0)
        or not IsNumber(def.coreAlpha, 0)
        or def.coreAlpha > 1
        or not BLENDS[def.bodyBlend]
        or not BLENDS[def.coreBlend]
    then
        return false
    end
    local shapes = definition.shapes or { square = "" }
    if type(shapes) ~= "table" or type(shapes.square) ~= "string" then
        return false
    end
    for shape, suffix in pairs(shapes) do
        if type(shape) ~= "string" or type(suffix) ~= "string" then
            return false
        end
        def.shapes[shape] = suffix
    end
    local contours = definition.contours
    if issecretvalue(contours) then
        return false
    end
    if contours ~= nil then
        if type(contours) ~= "table" then
            return false
        end
        for shape, geometry in pairs(contours) do
            if
                issecretvalue(shape)
                or type(shape) ~= "string"
                or not def.shapes[shape]
                or issecretvalue(geometry)
                or type(geometry) ~= "table"
                or issecretvalue(geometry.kind)
            then
                return false
            end
            local kind = geometry.kind
            if kind == "square" then
                def.contours[shape] = { kind = kind }
            else
                local field = CONTOUR_FRACTIONS[kind]
                local fraction = field and geometry[field]
                if shape == "square" or not IsNumber(fraction, 0) or fraction > MAX_CORNER_FRACTION then
                    return false
                end
                def.contours[shape] = { kind = kind, [field] = fraction }
            end
        end
    end
    for _, variant in ipairs(definition.variants) do
        if
            type(variant) ~= "table"
            or not IsNumber(variant.ratio, 0)
            or variant.ratio == 0
            or type(variant.path) ~= "string"
            or variant.path == ""
        then
            return false
        end
        def.variants[#def.variants + 1] = { ratio = variant.ratio, path = variant.path }
    end
    lib.statusBarGlows[name] = def
    lib.statusBarRevision = lib.statusBarRevision + 1
    return true
end

function lib:UnregisterStatusBarGlow(name)
    if name == DEFAULT_GLOW then
        return false
    end
    lib.statusBarGlows[name] = nil
    lib.statusBarRevision = lib.statusBarRevision + 1
    return true
end

function lib:IsStatusBarGlowRegistered(name)
    return lib.statusBarGlows[name] ~= nil
end

function lib:GetStatusBarGlowInfo(name)
    return lib.statusBarGlows[name]
end

function lib:GetStatusBarGlowList()
    local list = {}
    for name in pairs(lib.statusBarGlows) do
        list[#list + 1] = name
    end
    table.sort(list)
    return list
end

local function ResolveShape(def, variant, width, height, shape, contour)
    if issecretvalue(shape) then
        return nil
    end
    if shape ~= nil then
        if type(shape) ~= "string" then
            return nil
        end
        return def.shapes[shape] and shape or "square"
    end
    if issecretvalue(contour) then
        return nil
    end
    if contour == nil then
        return "square"
    end
    if type(contour) ~= "table" or issecretvalue(contour.kind) then
        return nil
    end
    local kind = contour.kind
    if kind == "square" then
        return "square"
    end
    local field = CONTOUR_FIELDS[kind]
    local size = field and contour[field]
    if not IsNumber(size, 0) then
        return nil
    end
    if size == 0 then
        return "square"
    end
    size = math.min(size, math.min(width, height) * MAX_CORNER_FRACTION)
    local normalizer = math.max(width, height)
    local target = size / normalizer
    local best, bestFraction, bestDistance = "square", 0, 2 * target * target
    local sourceShortSide = math.min(variant.ratio, 1)
    local xScale = (sourceShortSide / variant.ratio) * (width / normalizer)
    local yScale = sourceShortSide * (height / normalizer)
    -- Compare both rendered corner axes: stretching a sheet also stretches its baked contour.
    for candidate, geometry in pairs(def.contours or EMPTY_CONTOURS) do
        if geometry.kind == kind then
            local fraction = geometry[CONTOUR_FRACTIONS[kind]]
            local dx, dy = fraction * xScale - target, fraction * yScale - target
            local distance = dx * dx + dy * dy
            if
                distance < bestDistance
                or (
                    distance == bestDistance
                    and (fraction > bestFraction or (fraction == bestFraction and candidate < best))
                )
            then
                best, bestFraction, bestDistance = candidate, fraction, distance
            end
        end
    end
    return best
end

-- Geometry is host configuration, never a secret status-bar fill width or aura-presence measurement.
function StatusBar:Resolve(name, width, height, shape, contour)
    if not IsNumber(width, 0) or not IsNumber(height, 0) or width == 0 or height == 0 then
        return nil
    end
    local def = lib.statusBarGlows[name] or lib.statusBarGlows[DEFAULT_GLOW]
    local logRatio = math.log(width) - math.log(height)
    local best, distance
    for _, variant in ipairs(def.variants) do
        local delta = math.abs(logRatio - math.log(variant.ratio))
        if not distance or delta < distance then
            best, distance = variant, delta
        end
    end
    local resolvedShape = ResolveShape(def, best, width, height, shape, contour)
    if not resolvedShape then
        return nil
    end
    return best.path .. def.shapes[resolvedShape] .. def.ext, def, resolvedShape
end

local function CreateLayer(host, sublevel)
    local texture = host:CreateTexture(nil, "OVERLAY", nil, sublevel)
    local group = texture:CreateAnimationGroup()
    group:SetLooping("REPEAT")
    local animation = group:CreateAnimation("FlipBook")
    animation:SetFlipBookFrameWidth(0)
    animation:SetFlipBookFrameHeight(0)
    return { texture = texture, group = group, animation = animation }
end

local function ColorChannel(value)
    if issecretvalue(value) or value ~= nil then
        return value
    end
    return 1
end

local function ColorRGBA(color)
    if not color then
        return 1, 1, 1, 1
    end
    if color.GetRGBA then
        return color:GetRGBA()
    end
    if issecretvalue(color.r) or color.r ~= nil then
        return ColorChannel(color.r), ColorChannel(color.g), ColorChannel(color.b), ColorChannel(color.a)
    end
    return ColorChannel(color[1]), ColorChannel(color[2]), ColorChannel(color[3]), ColorChannel(color[4])
end

local function ShowLayer(layer, host, path, def, duration, width, height, blend, alpha, r, g, b, a)
    local texture = layer.texture
    local changed = layer.path ~= path
        or layer.rows ~= def.rows
        or layer.cols ~= def.cols
        or layer.frames ~= def.frames
        or layer.duration ~= duration
    if changed then
        layer.group:Stop()
        texture:SetTexture(path)
        texture:SetTexCoord(0, 1, 0, 1)
        layer.animation:SetFlipBookRows(def.rows)
        layer.animation:SetFlipBookColumns(def.cols)
        layer.animation:SetFlipBookFrames(def.frames)
        layer.animation:SetDuration(duration)
        layer.path, layer.rows, layer.cols, layer.frames, layer.duration =
            path, def.rows, def.cols, def.frames, duration
    end
    local ox, oy = width * def.overhang, height * def.overhang
    texture:ClearAllPoints()
    texture:SetPoint("TOPLEFT", host, "TOPLEFT", -ox, oy)
    texture:SetPoint("BOTTOMRIGHT", host, "BOTTOMRIGHT", ox, -oy)
    texture:SetBlendMode(blend)
    texture:SetVertexColor(r, g, b, a)
    texture:SetAlpha(alpha)
    texture:Show()
    if changed or not layer.playing then
        layer.group:Play()
    end
    layer.playing = true
end

local function HideLayer(layer)
    layer.group:Stop()
    layer.texture:Hide()
    layer.playing = false
end

-- Textures stay on their creating host for its lifetime; no reparenting, scripts, or shared-pool lineage.
function StatusBar:Show(host, options)
    options = options or {}
    local width, height = options.width, options.height
    if width == nil then
        width = host:GetWidth()
    end
    if height == nil then
        height = host:GetHeight()
    end
    local path, def, shape = self:Resolve(options.glow, width, height, options.shape, options.contour)
    if not path then
        return nil
    end
    local duration = options.duration or def.duration
    if not IsNumber(duration, 0) or duration == 0 then
        return nil
    end
    local key = options.key or "Default"
    local states = host._LibOrbitStatusBarGlows
    if not states then
        states = {}
        host._LibOrbitStatusBarGlows = states
    end
    local state = states[key]
    if not state then
        state = { bodyLayer = CreateLayer(host, BODY_SUBLEVEL) }
        state.body = state.bodyLayer.texture
        states[key] = state
    end
    state.shape = shape
    local r, g, b, a = ColorRGBA(options.color)
    ShowLayer(state.bodyLayer, host, path, def, duration, width, height, def.bodyBlend, 1, r, g, b, a)
    if def.core then
        if not state.coreLayer then
            state.coreLayer = CreateLayer(host, CORE_SUBLEVEL)
            state.core = state.coreLayer.texture
        end
        ShowLayer(state.coreLayer, host, path, def, duration, width, height, def.coreBlend, def.coreAlpha, r, g, b, a)
    elseif state.coreLayer then
        HideLayer(state.coreLayer)
    end
    return state
end

function StatusBar:Hide(host, key)
    local states = host._LibOrbitStatusBarGlows
    local state = states and states[key or "Default"]
    if not state then
        return
    end
    HideLayer(state.bodyLayer)
    if state.coreLayer then
        HideLayer(state.coreLayer)
    end
end

local SHAPES = {
    square = "",
    ["soft-small"] = "-soft-small",
    soft = "-soft",
    ["soft-large"] = "-soft-large",
    softer = "-softer",
    round = "-round",
    ["round-large"] = "-round-large",
    ["chamfer-small"] = "-chamfer-small",
    chamfer = "-chamfer",
    ["chamfer-large"] = "-chamfer-large",
    ["notch-small"] = "-notch-small",
    notch = "-notch",
    ["notch-large"] = "-notch-large",
    ["blade-small"] = "-blade-small",
    blade = "-blade",
    ["blade-large"] = "-blade-large",
}
local CONTOURS = {
    ["soft-small"] = { kind = "rounded", radiusFraction = 0.0625 },
    soft = { kind = "rounded", radiusFraction = 0.125 },
    ["soft-large"] = { kind = "rounded", radiusFraction = 0.175 },
    softer = { kind = "rounded", radiusFraction = 0.25 },
    round = { kind = "rounded", radiusFraction = 0.35 },
    ["round-large"] = { kind = "rounded", radiusFraction = 0.5 },
    ["chamfer-small"] = { kind = "chamfer", cutFraction = 0.0625 },
    chamfer = { kind = "chamfer", cutFraction = 0.125 },
    ["chamfer-large"] = { kind = "chamfer", cutFraction = 0.25 },
    ["notch-small"] = { kind = "notch", radiusFraction = 0.0625 },
    notch = { kind = "notch", radiusFraction = 0.125 },
    ["notch-large"] = { kind = "notch", radiusFraction = 0.25 },
    ["blade-small"] = { kind = "blade", cutFraction = 0.0875 },
    blade = { kind = "blade", cutFraction = 0.175 },
    ["blade-large"] = { kind = "blade", cutFraction = 0.35 },
}
for _, baseline in ipairs({ { "tracer", "Tracer" }, { "pinneon", "Pin Neon" } }) do
    local name, label = baseline[1], baseline[2]
    local path = LIB_PATH .. "Textures\\dispel-" .. name
    lib:RegisterStatusBarGlow(name, {
        label = label,
        source = "LibOrbitGlow",
        shapes = SHAPES,
        contours = CONTOURS,
        variants = { { ratio = 4, path = path .. "-40" }, { ratio = 2.5, path = path .. "-25" } },
    })
end
