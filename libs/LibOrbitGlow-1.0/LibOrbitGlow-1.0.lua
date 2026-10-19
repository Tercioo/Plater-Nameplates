local MAJOR_VERSION = "LibOrbitGlow-1.0"
local MINOR_VERSION = 14
local lib = LibStub:NewLibrary(MAJOR_VERSION, MINOR_VERSION)
if not lib then
    return
end
lib.minorVersion = MINOR_VERSION
lib.Pixel, lib.Autocast = nil, nil

-- [ CONSTANTS ] ---------------------------------------------------------------
local GLOW_PARENT = UIParent
local DEFAULT_FRAME_LEVEL = 8
local SUBPIXEL_INSET = 0.05
local DEFAULT_FLIPBOOK_SCALE = 1.4
local DEFAULT_FLIPBOOK_ROWS = 6
local DEFAULT_FLIPBOOK_COLS = 5
local PROC_ROWS, PROC_COLS, PROC_FRAMES = 6, 5, 30 -- registered glow-pack atlases: 30-frame 5x6 flipbook (Blizzard layout, 30fps over a 1s loop)
local BUTTON_SCALE = 1.4
local BUTTON_OFFSET_RATIO = 0.2
local BUTTON_ANTS_RATIO = 0.85
local BUTTON_ANT_SHEET_SIZE = 256
local BUTTON_ANT_FRAME_SIZE = 48
local BUTTON_ANT_TOTAL_FRAMES = 22
local BUTTON_FREQ_SCALAR = 0.25
local BUTTON_DEFAULT_FREQ = 0.25
local BUTTON_DEFAULT_THROTTLE = 0.01
local BUTTON_GLOW_TEXTURES = { "spark", "innerGlow", "innerGlowOver", "outerGlow", "outerGlowOver", "ants" }
local THIN_ATLAS = "RotationHelper_Ants_Flipbook_2x"
local THICK_ATLAS = "RotationHelper-ProcLoopBlue-Flipbook-2x"
local MEDIUM_ATLAS = "UI-HUD-ActionBar-Proc-Loop-Flipbook"
local LIB_PATH =
    assert(debugstack(1, 1, 0):match("Interface.*LibOrbitGlow%-1%.0[\\/]"), "LibOrbitGlow: invalid runtime path")
local FALLBACK_TEXTURE = LIB_PATH .. "Textures\\dispel-tracer-25.tga"
local CLASSIC_TEXTURE = [[Interface\SpellActivationOverlay\IconAlert]]
local CLASSIC_ANTS_TEXTURE = [[Interface\SpellActivationOverlay\IconAlertAnts]]
local classicArtAvailable

local function HasClassicArt()
    if classicArtAvailable == nil then
        local probe = GLOW_PARENT:CreateTexture()
        classicArtAvailable = probe:SetTexture(CLASSIC_TEXTURE) ~= false
        classicArtAvailable = (probe:SetTexture(CLASSIC_ANTS_TEXTURE) ~= false) and classicArtAvailable
        probe:SetTexture(nil)
        probe:Hide()
    end
    return classicArtAvailable
end

-- [ UTILITIES ] ---------------------------------------------------------------
local function GetColorRGBA(colorTable)
    if not colorTable then
        return 1, 1, 1, 1
    end
    if type(colorTable) == "table" and colorTable.GetRGBA then
        return colorTable:GetRGBA()
    end
    if colorTable.r then
        return colorTable.r, colorTable.g, colorTable.b, colorTable.a or 1
    end
    return colorTable[1] or 1, colorTable[2] or 1, colorTable[3] or 1, colorTable[4] or 1
end

-- hostW/hostH let a caller supply the host rect: a host inside a secure aura hierarchy reads its dimensions
-- back secret even after an explicit SetSize, so measuring it here would throw on the padding arithmetic.
local function ApplyPaddedAnchors(f, parent, scale, offsetScale, padding, shiftX, shiftY, hostW, hostH)
    f:ClearAllPoints()
    local padX = (padding or 0) + (offsetScale or 0) + ((hostW or parent:GetWidth()) * (scale - 1) / 2)
    local padY = (padding or 0) + (offsetScale or 0) + ((hostH or parent:GetHeight()) * (scale - 1) / 2)
    shiftX = shiftX or 0
    shiftY = shiftY or 0
    f:SetPoint("TOPLEFT", parent, "TOPLEFT", -padX + shiftX, padY + shiftY)
    f:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", padX + shiftX, -padY + shiftY)
end

-- [ POOLS ] -------------------------------------------------------------------
local function TexPoolResetter(pool, tex)
    if tex.animGroup and tex.animGroup:IsPlaying() then
        tex.animGroup:Stop()
    end
    tex:Hide()
    tex:ClearAllPoints()
end
local GlowTexPool = CreateTexturePool(GLOW_PARENT, "ARTWORK", 7, nil, TexPoolResetter)

local function FramePoolResetter(framePool, frame)
    frame:SetScript("OnUpdate", nil)
    local parent = frame:GetParent()
    if frame.name and parent and parent[frame.name] then
        parent[frame.name] = nil
    end
    if frame.textures then
        for i = 1, #frame.textures do
            GlowTexPool:Release(frame.textures[i])
        end
        table.wipe(frame.textures)
    end
    frame.name = nil
    frame.sig = nil
    frame:Hide()
    frame:ClearAllPoints()
end
local GlowFramePool = CreateFramePool("Frame", GLOW_PARENT, nil, FramePoolResetter)

-- [ CORE INITIALIZER ] --------------------------------------------------------
-- `owned` builds the glow from objects created directly on the host instead of the shared pools. Required for
-- hosts inside a forbidden hierarchy (secure aura buttons): a pooled object reparented there becomes forbidden
-- and poisons every later consumer once released, and pool lineage cannot inherit the host's aspects.
local function AcquireFrameAndTex(parent, nameKey, N, isDesaturated, frameLevel, r, g, b, a, blendMode, owned)
    frameLevel = frameLevel or DEFAULT_FRAME_LEVEL
    if not parent[nameKey] then
        if owned then
            parent[nameKey] = CreateFrame("Frame", nil, parent)
            parent[nameKey].owned = true
        else
            parent[nameKey] = GlowFramePool:Acquire()
            parent[nameKey]:SetParent(parent)
        end
        parent[nameKey].name = nameKey
    end
    local f = parent[nameKey]
    f:SetFrameLevel(parent:GetFrameLevel() + frameLevel)
    f:SetPoint("TOPLEFT", parent, "TOPLEFT", SUBPIXEL_INSET, SUBPIXEL_INSET)
    f:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -SUBPIXEL_INSET, -SUBPIXEL_INSET)
    f:Show()
    f.parked = nil
    f.textures = f.textures or {}
    for i = 1, N do
        if not f.textures[i] then
            f.textures[i] = f.owned and f:CreateTexture(nil, "ARTWORK", nil, 7) or GlowTexPool:Acquire()
            if not f.owned then
                f.textures[i]:SetParent(f)
            end
            f.textures[i]:SetDrawLayer("ARTWORK", 7)
        end
        f.textures[i]:SetDesaturated(isDesaturated)
        f.textures[i]:SetVertexColor(r, g, b, a)
        if blendMode then
            f.textures[i]:SetBlendMode(blendMode)
        end
        f.textures[i]:Show()
    end
    while #f.textures > N do
        if f.owned then
            f.textures[#f.textures]:Hide()
        else
            GlowTexPool:Release(f.textures[#f.textures])
        end
        table.remove(f.textures)
    end
    return f
end

-- An owned host inherits a secret Shown aspect from the secure aura button it hangs off, so its live state is
-- tracked in a plain field: boolean-testing IsShown() on one throws.
local function IsGlowLive(f)
    if f.owned then
        return not f.parked
    end
    return f:IsShown()
end

-- [ FLIPBOOK / PROC GLOW ] ----------------------------------------------------
lib.Flipbook = {}

function lib.Flipbook:Show(frame, options)
    options = options or {}
    local atlas = options.atlas or MEDIUM_ATLAS
    local isTexture = options.isTexture or false
    local rows, cols, frames = options.rows, options.cols, options.frames
    if not isTexture then
        local info = C_Texture and C_Texture.GetAtlasInfo and C_Texture.GetAtlasInfo(atlas)
        if info then
            rows, cols, frames = rows or info.flipBookRows, cols or info.flipBookColumns, frames or info.flipBookFrames
        else
            atlas, isTexture = FALLBACK_TEXTURE, true
            rows, cols, frames = PROC_ROWS, PROC_COLS, PROC_FRAMES
        end
    end
    local r, g, b, a = GetColorRGBA(options.color)
    local nameKey = "_LibGlowFlipbook" .. (options.key or "Default")
    -- Visual signature excluding colour: a match on a live frame means a re-show only re-tints, so a glow can be re-driven every event with no teardown and animation restart.
    local sig = atlas
        .. "|"
        .. (isTexture and "T" or "A")
        .. "|"
        .. (rows or "")
        .. "|"
        .. (cols or "")
        .. "|"
        .. (frames or "")
        .. "|"
        .. (options.speed or "")
        .. "|"
        .. (options.blendMode or "")
        .. "|"
        .. (options.N or 1)
        .. "|"
        .. (options.scale or "")
        .. "|"
        .. (options.offsetScale or "")
        .. "|"
        .. (options.offsetX or "")
        .. "|"
        .. (options.offsetY or "")
        .. "|"
        .. (options.padding or "")
        .. "|"
        .. (options.desaturated == false and "0" or "1")
        .. "|"
        .. (options.frameLevel or "")
    local existing = frame[nameKey]
    if existing and IsGlowLive(existing) and existing.textures and existing.textures[1] then
        local tex1 = existing.textures[1]
        local isAnimating = (tex1.animGroup and tex1.animGroup:IsPlaying()) or existing:GetScript("OnUpdate")
        if isAnimating and existing.sig == sig and not options.force then
            ApplyPaddedAnchors(
                existing,
                frame,
                options.scale or DEFAULT_FLIPBOOK_SCALE,
                options.offsetScale,
                options.padding,
                options.offsetX,
                options.offsetY,
                options.hostWidth,
                options.hostHeight
            )
            for i = 1, #existing.textures do
                existing.textures[i]:SetVertexColor(r, g, b, a)
            end
            return
        end
    end
    local speed = options.speed or 1.0
    rows = rows or DEFAULT_FLIPBOOK_ROWS
    cols = cols or DEFAULT_FLIPBOOK_COLS
    frames = frames or (rows * cols)
    local N = options.N or 1
    local blendMode = options.blendMode or "BLEND"
    local f = AcquireFrameAndTex(frame, nameKey, N, true, options.frameLevel, r, g, b, a, blendMode, options.owned)
    f.sig = sig
    local scale = options.scale or DEFAULT_FLIPBOOK_SCALE
    ApplyPaddedAnchors(
        f,
        frame,
        scale,
        options.offsetScale,
        options.padding,
        options.offsetX,
        options.offsetY,
        options.hostWidth,
        options.hostHeight
    )
    for i = 1, N do
        local tex = f.textures[i]
        tex:SetTexCoord(0, 1, 0, 1)
        if isTexture then
            tex:SetTexture(atlas)
        else
            tex:SetAtlas(atlas)
        end
        tex:SetAllPoints(f)
        tex:SetDesaturated(options.desaturated ~= false)
        tex:SetVertexColor(r, g, b, a)
        tex:SetBlendMode(blendMode)
    end
    f:SetScript("OnUpdate", nil)
    local once = options.once or false
    for i = 1, N do
        local texLoop = f.textures[i]
        if not texLoop.animGroup then
            texLoop.animGroup = texLoop:CreateAnimationGroup()
            local fbAnim = texLoop.animGroup:CreateAnimation("FlipBook")
            fbAnim:SetOrder(1)
            texLoop.flipbookAnim = fbAnim
        end
        texLoop.animGroup:SetLooping(once and "NONE" or "REPEAT")
        texLoop.animGroup:SetScript("OnFinished", (once and i == 1) and options.onFinished or nil)
        texLoop.flipbookAnim:SetDuration(speed)
        texLoop.flipbookAnim:SetFlipBookRows(rows)
        texLoop.flipbookAnim:SetFlipBookColumns(cols)
        texLoop.flipbookAnim:SetFlipBookFrames(frames)
        texLoop.animGroup:Stop()
        texLoop.animGroup:Play()
    end
end

function lib.Flipbook:Hide(frame, key)
    local nameKey = "_LibGlowFlipbook" .. (key or "Default")
    local f = frame[nameKey]
    if not f then
        return
    end
    -- Owned glows are host-lifetime objects: park them instead of releasing, or they would enter the shared pool.
    if f.owned then
        for i = 1, #f.textures do
            local tex = f.textures[i]
            if tex.animGroup and tex.animGroup:IsPlaying() then
                tex.animGroup:Stop()
            end
            tex:Hide()
        end
        f:Hide()
        f.parked = true
        return
    end
    GlowFramePool:Release(f)
    frame[nameKey] = nil
end

-- [ GLOW REGISTRY ] -----------------------------------------------------------
lib.glows = lib.glows or {}
-- LibStub upgrades in place: remove retired entries inherited from an older embedded copy.
for name, def in pairs(lib.glows) do
    if def.engine == "Pixel" or def.engine == "Autocast" then
        lib.glows[name] = nil
    end
end
lib.defaultGlow = lib.defaultGlow or "blizzard"

function lib:RegisterGlow(name, def)
    if type(name) ~= "string" or type(def) ~= "table" then
        return false
    end
    if
        def.engine
        and def.engine ~= "Classic"
        and def.engine ~= "Thin"
        and def.engine ~= "Thick"
        and def.engine ~= "Medium"
    then
        return false
    end
    if not (def.path or def.resolve or def.atlas or def.engine) then
        if DEFAULT_CHAT_FRAME then
            DEFAULT_CHAT_FRAME:AddMessage(
                '|cffff8800LibOrbitGlow|r: RegisterGlow("'
                    .. name
                    .. '") ignored -- def needs one of path/resolve/atlas/engine.'
            )
        end
        return false
    end
    def.shapes = def.shapes or { square = true }
    def.source = def.source or "Unknown"
    if def.loopOnly then
        def.phases = def.phases or { loop = true }
    end
    local prev = lib.glows[name]
    if prev and prev.source ~= def.source and DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage(
            '|cffff8800LibOrbitGlow|r: glow "'
                .. name
                .. '" re-registered by "'
                .. def.source
                .. '" (was "'
                .. tostring(prev.source)
                .. '").'
        )
    end
    lib.glows[name] = def
    return true
end

function lib:UnregisterGlow(name)
    lib.glows[name] = nil
end

function lib:IsGlowRegistered(name)
    return lib.glows[name] ~= nil
end

function lib:GetGlowInfo(name)
    return lib.glows[name]
end

function lib:GetGlowList()
    local list = {}
    for name in pairs(lib.glows) do
        list[#list + 1] = name
    end
    table.sort(list)
    return list
end

-- [ PROC LIFECYCLE -- registry-resolved start -> loop -> end ] -----------------
-- A layered glow stacks a BLEND body and an ADD near-white core per phase, both recoloured via SetVertexColor; a single-atlas glow draws one desaturated vertex-tinted layer.
lib.Proc = {}

local function CoreColor(color)
    local r, g, b = GetColorRGBA(color)
    return { 0.6 + 0.4 * r, 0.6 + 0.4 * g, 0.6 + 0.4 * b, 1 }
end

local LAYER_BODY, LAYER_CORE, LAYER_CORE_KEY = "", "-core", "\1core"

local function ResolveShape(def, shape)
    local shapes = def.shapes
    if shape and shapes and shapes[shape] then
        return shape
    end
    if shapes then
        if shapes.square then
            return "square"
        end
        for s in pairs(shapes) do
            return s
        end
    end
    return "square"
end

-- Layers a path-based def draws: layered = tinted BLEND body + near-white ADD core (depth), else one tinted layer (def.blendMode, default ADD); def.core=false keeps the blends but drops the core art.
local function TextureLayers(def)
    if def.layered then
        local layers =
            { { suffix = LAYER_BODY, keySuffix = LAYER_BODY, blend = def.bodyBlend or "BLEND", core = false } }
        if def.core ~= false then
            layers[#layers + 1] =
                { suffix = LAYER_CORE, keySuffix = LAYER_CORE_KEY, blend = def.coreBlend or "ADD", core = true }
        end
        return layers
    end
    return { { suffix = LAYER_BODY, keySuffix = LAYER_BODY, blend = def.blendMode or "ADD", core = false } }
end

-- Default path contract is "<path>-<phase>[-<shape>]<layer><ext>"; nil means that combination does not exist and the caller skips it.
local function ResolvePath(def, phase, shape, suffix)
    if def.phases and not def.phases[phase] then
        return nil
    end
    if def.resolve then
        return def.resolve(phase, shape, suffix)
    end
    if not def.path then
        return nil
    end
    local s = def.path .. "-" .. phase
    if def.shaped ~= false and shape and shape ~= "" then
        s = s .. "-" .. shape
    end
    return s .. suffix .. (def.ext or ".tga")
end

local function LayerOptions(def, o, path, keySuffix, isCore, blendMode, color, once, duration, onFinished)
    return {
        key = (o.key or "proc") .. keySuffix,
        color = color,
        frameLevel = o.frameLevel and (o.frameLevel + (isCore and 1 or 0)) or nil,
        scale = o.scale or def.scale,
        padding = o.padding,
        offsetScale = o.offsetScale,
        offsetX = o.offsetX,
        offsetY = o.offsetY,
        isTexture = true,
        desaturated = false,
        blendMode = blendMode,
        atlas = path,
        rows = def.rows or PROC_ROWS,
        cols = def.cols or PROC_COLS,
        frames = def.frames or PROC_FRAMES,
        speed = duration,
        once = once,
        onFinished = onFinished,
        owned = o.owned,
        hostWidth = o.hostWidth,
        hostHeight = o.hostHeight,
    }
end

local function AtlasOptions(def, o, once, duration, onFinished)
    return {
        key = o.key or "proc",
        color = o.color,
        frameLevel = o.frameLevel,
        scale = o.scale or def.scale,
        padding = o.padding,
        offsetScale = o.offsetScale,
        offsetX = o.offsetX,
        offsetY = o.offsetY,
        isTexture = false,
        atlas = def.atlas,
        desaturated = def.desaturated ~= false,
        blendMode = def.blendMode or "ADD",
        rows = def.rows,
        cols = def.cols,
        frames = def.frames,
        speed = duration,
        once = once,
        onFinished = onFinished,
        owned = o.owned,
        hostWidth = o.hostWidth,
        hostHeight = o.hostHeight,
    }
end

-- True when the def supplies `phase` as a distinct one-shot (any layer resolves a path). Engines and single atlases never do.
local function HasPhase(def, phase, shape)
    if def.engine or def.atlas then
        return false
    end
    shape = ResolveShape(def, shape)
    for _, layer in ipairs(TextureLayers(def)) do
        if ResolvePath(def, phase, shape, layer.suffix) then
            return true
        end
    end
    return false
end

local function ShowProc(frame, def, o, phase, once, duration, onFinished)
    if def.engine then
        local opts = { key = o.key, color = o.color, frameLevel = o.frameLevel, scale = o.scale }
        if def.options then
            for k, v in pairs(def.options) do
                if opts[k] == nil then
                    opts[k] = v
                end
            end
        end
        lib.Show(frame, def.engine, opts)
        return
    end
    if def.atlas then
        lib.Flipbook:Show(frame, AtlasOptions(def, o, once, duration, onFinished))
        return
    end
    local shape = ResolveShape(def, o.shape)
    local handed = false
    for _, layer in ipairs(TextureLayers(def)) do
        local path = ResolvePath(def, phase, shape, layer.suffix)
        if path then
            if lib.DEBUG and DEFAULT_CHAT_FRAME then
                DEFAULT_CHAT_FRAME:AddMessage(
                    "|cff66ccffLibOrbitGlow|r " .. tostring(o.glow) .. " " .. phase .. " -> " .. path
                )
            end
            local color = layer.core and CoreColor(o.color) or o.color
            lib.Flipbook:Show(
                frame,
                LayerOptions(
                    def,
                    o,
                    path,
                    layer.keySuffix,
                    layer.core,
                    layer.blend,
                    color,
                    once,
                    duration,
                    (not handed) and onFinished or nil
                )
            )
            handed = true
        end
    end
end

local function ResolveGlow(o)
    return lib.glows[o.glow] or lib.glows[lib.defaultGlow]
end

function lib.Proc:Start(frame, options)
    options = options or {}
    local def = ResolveGlow(options)
    if not def then
        return
    end
    if HasPhase(def, "start", options.shape) then
        ShowProc(frame, def, options, "start", true, options.startDuration or 0.28, function()
            ShowProc(frame, def, options, "loop", false, options.loopDuration or 1.0)
        end)
    else
        ShowProc(frame, def, options, "loop", false, options.loopDuration or 1.0)
    end
end

function lib.Proc:Stop(frame, options)
    options = options or {}
    local def = ResolveGlow(options)
    if not def then
        return
    end
    if HasPhase(def, "end", options.shape) then
        ShowProc(frame, def, options, "end", true, options.endDuration or 0.20, function()
            lib.Proc:Clear(frame, options)
        end)
    else
        lib.Proc:Clear(frame, options)
    end
end

function lib.Proc:Loop(frame, options)
    options = options or {}
    local def = ResolveGlow(options)
    if not def then
        return
    end
    ShowProc(frame, def, options, "loop", false, options.loopDuration or 1.0)
end

function lib.Proc:Clear(frame, options)
    options = options or {}
    local def = ResolveGlow(options) -- same fallback Start/Stop/Loop use, so the engine-vs-flipbook teardown matches what was shown
    if def and def.engine then
        lib.Hide(frame, def.engine, options.key or "proc")
        return
    end
    lib.Flipbook:Hide(frame, options.key or "proc")
    lib.Flipbook:Hide(frame, (options.key or "proc") .. LAYER_CORE_KEY)
end

function lib:GetResolvedPaths(name, shape)
    local def = lib.glows[name]
    if not def then
        return nil
    end
    if def.engine then
        return { engine = def.engine }
    end
    if def.atlas then
        return { atlas = def.atlas }
    end
    shape = ResolveShape(def, shape)
    local out = {}
    for _, phase in ipairs({ "start", "loop", "end" }) do
        for _, layer in ipairs(TextureLayers(def)) do
            local p = ResolvePath(def, phase, shape, layer.suffix)
            if p then
                out[#out + 1] = p
            end
        end
    end
    return out
end

lib:RegisterGlow(
    "blizzard",
    { atlas = "UI-HUD-ActionBar-Proc-Loop-Flipbook", layered = false, blendMode = "ADD", source = "LibOrbitGlow" }
)
lib:RegisterGlow(
    "blizzardants",
    { atlas = "RotationHelper_Ants_Flipbook_2x", layered = false, blendMode = "ADD", source = "LibOrbitGlow" }
)
lib:RegisterGlow(
    "blizzardblue",
    { atlas = "RotationHelper-ProcLoopBlue-Flipbook-2x", layered = false, blendMode = "ADD", source = "LibOrbitGlow" }
)
lib:RegisterGlow("classic", { engine = "Classic", source = "LibOrbitGlow" })

-- [ BUTTON GLOW ] -------------------------------------------------------------
lib.Button = {}

local function CreateScaleAnim(group, target, order, duration, x, y, delay)
    local scale = group:CreateAnimation("Scale")
    scale:SetChildKey(target)
    scale:SetOrder(order)
    scale:SetDuration(duration)
    scale:SetScale(x, y)
    if delay then
        scale:SetStartDelay(delay)
    end
end

local function CreateAlphaAnim(group, target, order, duration, fromAlpha, toAlpha, delay, appear)
    local alpha = group:CreateAnimation("Alpha")
    alpha:SetChildKey(target)
    alpha:SetOrder(order)
    alpha:SetDuration(duration)
    alpha:SetFromAlpha(fromAlpha)
    alpha:SetToAlpha(toAlpha)
    if delay then
        alpha:SetStartDelay(delay)
    end
    if appear then
        tinsert(group.appear, alpha)
    else
        tinsert(group.fade, alpha)
    end
end

local function AnimIn_OnPlay(group)
    local frame = group:GetParent()
    local w, h = frame:GetSize()
    frame.spark:SetSize(w, h)
    frame.spark:SetAlpha(not frame.color and 1.0 or 0.3 * (frame.color[4] or 1))
    frame.innerGlow:SetSize(w / 2, h / 2)
    frame.innerGlow:SetAlpha(not frame.color and 1.0 or (frame.color[4] or 1))
    frame.innerGlowOver:SetAlpha(not frame.color and 1.0 or (frame.color[4] or 1))
    frame.outerGlow:SetSize(w * 2, h * 2)
    frame.outerGlow:SetAlpha(not frame.color and 1.0 or (frame.color[4] or 1))
    frame.outerGlowOver:SetAlpha(not frame.color and 1.0 or (frame.color[4] or 1))
    frame.ants:SetSize(w * BUTTON_ANTS_RATIO, h * BUTTON_ANTS_RATIO)
    frame.ants:SetAlpha(0)
    frame:Show()
end

local function AnimIn_OnFinished(group)
    local frame = group:GetParent()
    local w, h = frame:GetSize()
    frame.spark:SetAlpha(0)
    frame.innerGlow:SetAlpha(0)
    frame.innerGlow:SetSize(w, h)
    frame.innerGlowOver:SetAlpha(0.0)
    frame.outerGlow:SetSize(w, h)
    frame.outerGlowOver:SetAlpha(0.0)
    frame.outerGlowOver:SetSize(w, h)
    frame.ants:SetAlpha(not frame.color and 1.0 or (frame.color[4] or 1))
end

local function AnimIn_OnStop(group)
    local frame = group:GetParent()
    frame.spark:SetAlpha(0)
    frame.innerGlow:SetAlpha(0)
    frame.innerGlowOver:SetAlpha(0.0)
    frame.outerGlowOver:SetAlpha(0.0)
end

local function UpdateAlphaAnim(f, alpha)
    if f.animIn then
        for _, anim in ipairs(f.animIn.appear) do
            anim:SetToAlpha(alpha)
        end
        for _, anim in ipairs(f.animIn.fade) do
            anim:SetFromAlpha(alpha)
        end
    end
    if f.animOut then
        for _, anim in ipairs(f.animOut.appear) do
            anim:SetToAlpha(alpha)
        end
        for _, anim in ipairs(f.animOut.fade) do
            anim:SetFromAlpha(alpha)
        end
    end
end

local function ConfigureButtonGlow(f, alpha)
    f.spark = f:CreateTexture(nil, "BACKGROUND")
    f.spark:SetPoint("CENTER")
    f.spark:SetAlpha(0)
    f.spark:SetTexture([[Interface\SpellActivationOverlay\IconAlert]])
    f.spark:SetTexCoord(0.00781250, 0.61718750, 0.00390625, 0.26953125)
    f.innerGlow = f:CreateTexture(nil, "ARTWORK")
    f.innerGlow:SetPoint("CENTER")
    f.innerGlow:SetAlpha(0)
    f.innerGlow:SetTexture([[Interface\SpellActivationOverlay\IconAlert]])
    f.innerGlow:SetTexCoord(0.00781250, 0.50781250, 0.27734375, 0.52734375)
    f.innerGlowOver = f:CreateTexture(nil, "ARTWORK")
    f.innerGlowOver:SetPoint("TOPLEFT", f.innerGlow, "TOPLEFT")
    f.innerGlowOver:SetPoint("BOTTOMRIGHT", f.innerGlow, "BOTTOMRIGHT")
    f.innerGlowOver:SetAlpha(0)
    f.innerGlowOver:SetTexture([[Interface\SpellActivationOverlay\IconAlert]])
    f.innerGlowOver:SetTexCoord(0.00781250, 0.50781250, 0.53515625, 0.78515625)
    f.outerGlow = f:CreateTexture(nil, "ARTWORK")
    f.outerGlow:SetPoint("CENTER")
    f.outerGlow:SetAlpha(0)
    f.outerGlow:SetTexture([[Interface\SpellActivationOverlay\IconAlert]])
    f.outerGlow:SetTexCoord(0.00781250, 0.50781250, 0.27734375, 0.52734375)
    f.outerGlowOver = f:CreateTexture(nil, "ARTWORK")
    f.outerGlowOver:SetPoint("TOPLEFT", f.outerGlow, "TOPLEFT")
    f.outerGlowOver:SetPoint("BOTTOMRIGHT", f.outerGlow, "BOTTOMRIGHT")
    f.outerGlowOver:SetAlpha(0)
    f.outerGlowOver:SetTexture([[Interface\SpellActivationOverlay\IconAlert]])
    f.outerGlowOver:SetTexCoord(0.00781250, 0.50781250, 0.53515625, 0.78515625)
    f.ants = f:CreateTexture(nil, "OVERLAY")
    f.ants:SetPoint("CENTER")
    f.ants:SetAlpha(0)
    f.ants:SetTexture([[Interface\SpellActivationOverlay\IconAlertAnts]])
    f.animIn = f:CreateAnimationGroup()
    f.animIn.appear = {}
    f.animIn.fade = {}
    CreateScaleAnim(f.animIn, "spark", 1, 0.2, 1.5, 1.5)
    CreateAlphaAnim(f.animIn, "spark", 1, 0.2, 0, alpha, nil, true)
    CreateScaleAnim(f.animIn, "innerGlow", 1, 0.3, 2, 2)
    CreateScaleAnim(f.animIn, "innerGlowOver", 1, 0.3, 2, 2)
    CreateAlphaAnim(f.animIn, "innerGlowOver", 1, 0.3, alpha, 0, nil, false)
    CreateScaleAnim(f.animIn, "outerGlow", 1, 0.3, 0.5, 0.5)
    CreateScaleAnim(f.animIn, "outerGlowOver", 1, 0.3, 0.5, 0.5)
    CreateAlphaAnim(f.animIn, "outerGlowOver", 1, 0.3, alpha, 0, nil, false)
    CreateScaleAnim(f.animIn, "spark", 1, 0.2, 2 / 3, 2 / 3, 0.2)
    CreateAlphaAnim(f.animIn, "spark", 1, 0.2, alpha, 0, 0.2, false)
    CreateAlphaAnim(f.animIn, "innerGlow", 1, 0.2, alpha, 0, 0.3, false)
    CreateAlphaAnim(f.animIn, "ants", 1, 0.2, 0, alpha, 0.3, true)
    f.animIn:SetScript("OnPlay", AnimIn_OnPlay)
    f.animIn:SetScript("OnStop", AnimIn_OnStop)
    f.animIn:SetScript("OnFinished", AnimIn_OnFinished)
    f.animOut = f:CreateAnimationGroup()
    f.animOut.appear = {}
    f.animOut.fade = {}
    CreateAlphaAnim(f.animOut, "outerGlowOver", 1, 0.2, 0, alpha, nil, true)
    CreateAlphaAnim(f.animOut, "ants", 1, 0.2, alpha, 0, nil, false)
    CreateAlphaAnim(f.animOut, "outerGlowOver", 2, 0.2, alpha, 0, nil, false)
    CreateAlphaAnim(f.animOut, "outerGlow", 2, 0.2, alpha, 0, nil, false)
end

-- AnimateTexCoords was removed as a global in 12.1; inline Blizzard's sprite-sheet stepper.
local function AnimateTexCoords(
    texture,
    textureWidth,
    textureHeight,
    frameWidth,
    frameHeight,
    numFrames,
    elapsed,
    throttle
)
    if not texture.frame then
        texture.frame = 1
        texture.throttle = throttle
        texture.numColumns = math.floor(textureWidth / frameWidth)
        texture.numRows = math.floor(textureHeight / frameHeight)
        texture.columnWidth = frameWidth / textureWidth
        texture.rowHeight = frameHeight / textureHeight
    end
    local frame = texture.frame
    if not texture.throttle or texture.throttle > throttle then
        local framesToAdvance = math.floor(texture.throttle / throttle)
        while frame + framesToAdvance > numFrames do
            frame = frame - numFrames
        end
        frame = frame + framesToAdvance
        texture.throttle = 0
        local left = ((frame - 1) % texture.numColumns) * texture.columnWidth
        local right = left + texture.columnWidth
        local bottom = math.ceil(frame / texture.numColumns) * texture.rowHeight
        local top = bottom - texture.rowHeight
        texture:SetTexCoord(left, right, top, bottom)
        texture.frame = frame
    else
        texture.throttle = texture.throttle + elapsed
    end
end

local function ButtonForwardOnUpdate(self, elapsed)
    AnimateTexCoords(
        self.ants,
        BUTTON_ANT_SHEET_SIZE,
        BUTTON_ANT_SHEET_SIZE,
        BUTTON_ANT_FRAME_SIZE,
        BUTTON_ANT_FRAME_SIZE,
        BUTTON_ANT_TOTAL_FRAMES,
        elapsed,
        self.throttle
    )
end

local ButtonGlowPool = CreateFramePool("Frame", GLOW_PARENT, nil, function(pool, frame)
    frame:SetScript("OnUpdate", nil)
    local parent = frame:GetParent()
    if frame.name and parent and parent[frame.name] then
        parent[frame.name] = nil
    end
    frame.name = nil
    -- AnimateTexCoords only re-inits when texture.frame is nil; clear it so a reused frame restarts at frame one.
    if frame.ants then
        frame.ants.frame = nil
        frame.ants.throttle = nil
    end
    frame:Hide()
    frame:ClearAllPoints()
end)

local function ApplyButtonLayout(f, frame, frameLevel)
    local w, h = frame:GetSize()
    f:SetFrameLevel(frame:GetFrameLevel() + (frameLevel or DEFAULT_FRAME_LEVEL))
    f:SetSize(w * BUTTON_SCALE, h * BUTTON_SCALE)
    f:SetPoint("TOPLEFT", frame, "TOPLEFT", -w * BUTTON_OFFSET_RATIO, h * BUTTON_OFFSET_RATIO)
    f:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", w * BUTTON_OFFSET_RATIO, -h * BUTTON_OFFSET_RATIO)
    f.ants:SetSize(w * BUTTON_SCALE * BUTTON_ANTS_RATIO, h * BUTTON_SCALE * BUTTON_ANTS_RATIO)
end

function lib.Button:Show(frame, options)
    options = options or {}
    if options.owned or not HasClassicArt() then
        local fallback = {}
        for name, value in pairs(options) do
            fallback[name] = value
        end
        fallback.atlas, fallback.isTexture = FALLBACK_TEXTURE, true
        fallback.rows, fallback.cols, fallback.frames = PROC_ROWS, PROC_COLS, PROC_FRAMES
        fallback.key = "Classic:" .. (options.key or "Default")
        lib.Flipbook:Show(frame, fallback)
        return
    end
    local r, g, b, a = GetColorRGBA(options.color)
    local freq = options.frequency or BUTTON_DEFAULT_FREQ
    local throttle = (freq > 0) and (BUTTON_FREQ_SCALAR / freq * BUTTON_DEFAULT_THROTTLE) or BUTTON_DEFAULT_THROTTLE
    local nameKey = "_LibGlowButton" .. (options.key or "Default")
    if frame[nameKey] then
        local f = frame[nameKey]
        -- A re-show inside the fade-out window must cancel animOut or its OnFinished releases this still-owned frame back to the pool; Stop() fires OnStop, not OnFinished, so it won't release.
        if f.animOut and f.animOut:IsPlaying() then
            f.animOut:Stop()
            if f.animIn then
                f.animIn:Play()
            end
        end
        f.color = { r, g, b, a }
        for _, texName in ipairs(BUTTON_GLOW_TEXTURES) do
            f[texName]:SetVertexColor(r, g, b)
        end
        UpdateAlphaAnim(f, a)
    else
        local f, new = ButtonGlowPool:Acquire()
        if new then
            ConfigureButtonGlow(f, a)
            f.animOut:SetScript("OnFinished", function(self)
                ButtonGlowPool:Release(self:GetParent())
            end)
            f:SetScript("OnHide", function(self)
                if self.animOut:IsPlaying() then
                    self.animOut:Stop()
                    ButtonGlowPool:Release(self)
                end
            end)
        else
            UpdateAlphaAnim(f, a)
        end
        frame[nameKey] = f
        f.name = nameKey
        f:SetParent(frame)
        ApplyButtonLayout(f, frame, options.frameLevel)
        f.color = { r, g, b, a }
        for _, texName in ipairs(BUTTON_GLOW_TEXTURES) do
            f[texName]:SetDesaturated(1)
            f[texName]:SetVertexColor(r, g, b)
        end
        f.throttle = throttle
        f:SetScript("OnUpdate", ButtonForwardOnUpdate)
        if f.animIn then
            f.animIn:Play()
        end
    end
end

function lib.Button:Hide(frame, key)
    lib.Flipbook:Hide(frame, "Classic:" .. (key or "Default"))
    local nameKey = "_LibGlowButton" .. (key or "Default")
    if frame[nameKey] then
        if frame[nameKey].animIn and frame[nameKey].animIn:IsPlaying() then
            frame[nameKey].animIn:Stop()
            ButtonGlowPool:Release(frame[nameKey])
        elseif frame:IsVisible() then
            frame[nameKey].animOut:Play()
        else
            ButtonGlowPool:Release(frame[nameKey])
        end
    end
end

-- [ CORE API ] ----------------------------------------------------------------
local GLOW_TYPE_MAP = {
    Thin = function(frame, options)
        options.atlas = options.atlas or THIN_ATLAS
        options.scale = options.scale or DEFAULT_FLIPBOOK_SCALE
        options.offsetScale = 4
        lib.Flipbook:Show(frame, options)
    end,
    Thick = function(frame, options)
        options.atlas = options.atlas or THICK_ATLAS
        options.scale = options.scale or DEFAULT_FLIPBOOK_SCALE
        options.offsetScale = 1
        lib.Flipbook:Show(frame, options)
    end,
    Medium = function(frame, options)
        options.atlas = options.atlas or MEDIUM_ATLAS
        options.scale = options.scale or DEFAULT_FLIPBOOK_SCALE
        options.offsetScale = 1
        lib.Flipbook:Show(frame, options)
    end,
    Classic = function(frame, options)
        lib.Button:Show(frame, options)
    end,
}

local HIDE_TYPE_MAP = {
    Thin = function(frame, key)
        lib.Flipbook:Hide(frame, key)
    end,
    Thick = function(frame, key)
        lib.Flipbook:Hide(frame, key)
    end,
    Medium = function(frame, key)
        lib.Flipbook:Hide(frame, key)
    end,
    Classic = function(frame, key)
        lib.Button:Hide(frame, key)
    end,
}

local WARMUP_DUMMY_PARENT

function lib.Show(frame, glowType, options)
    local handler = GLOW_TYPE_MAP[glowType]
    if not handler then
        error(MAJOR_VERSION .. ": Unknown glowType '" .. tostring(glowType) .. "'")
    end
    handler(frame, options or {})
end

function lib.Hide(frame, glowType, key)
    local handler = HIDE_TYPE_MAP[glowType]
    if not handler then
        error(MAJOR_VERSION .. ": Unknown glowType '" .. tostring(glowType) .. "'")
    end
    handler(frame, key)
end

-- `id` is either an engine type or a registered glow name, so callers can pass one straight from a saved setting; registered names play the full proc lifecycle, engine types show directly.
function lib.Apply(frame, id, options)
    options = options or {}
    if lib.glows[id] then
        options.glow = id
        if options.loop then
            lib.Proc:Loop(frame, options)
        else
            lib.Proc:Start(frame, options)
        end
    else
        lib.Show(frame, id, options)
    end
end

function lib.Remove(frame, id, key)
    if type(key) == "table" then
        key = key.key
    end
    if lib.glows[id] then
        lib.Proc:Stop(frame, { glow = id, key = key })
    else
        lib.Hide(frame, id, key)
    end
end

function lib.PreLoad(glowType, count)
    local handler = GLOW_TYPE_MAP[glowType]
    if not handler then
        error(MAJOR_VERSION .. ": Unknown glowType '" .. tostring(glowType) .. "'")
    end
    if not WARMUP_DUMMY_PARENT then
        WARMUP_DUMMY_PARENT = CreateFrame("Frame", nil, UIParent)
        WARMUP_DUMMY_PARENT:SetSize(40, 40)
        WARMUP_DUMMY_PARENT:Hide()
    end

    local keys = {}
    for i = 1, count do
        local key = "_warmup_" .. i
        tinsert(keys, key)
        handler(WARMUP_DUMMY_PARENT, { key = key })
    end
    for _, key in ipairs(keys) do
        lib.Hide(WARMUP_DUMMY_PARENT, glowType, key)
    end
end
