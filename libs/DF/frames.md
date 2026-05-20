# Rounded Corners Frame

Implementation file: `frames.lua`

A rounded corners frame is a standard World of Warcraft frame with rounded borders. It works by using a circle texture (`Interface\CHARACTERFRAME\TempPortraitAlphaMaskSmall`) which is split into four quadrants — each quadrant is placed at the corresponding corner of the frame. The space between the corners is filled with solid-color textures (top edge, bottom edge, and a center block) to complete the panel.

The frame automatically handles resizing: when the frame height drops below 32 pixels, corner textures are rescaled so the panel still renders correctly at small sizes.

---

## Entry Points

### `detailsFramework:CreateRoundedPanel(parent, name, optionsTable)`

Creates a new rounded corner frame from scratch.

**Parameters:**

| Parameter | Type | Description |
|---|---|---|
| `parent` | `frame` | The parent frame. |
| `name` | `string\|nil` | Global name for the frame, or `nil` for anonymous. |
| `optionsTable` | `table\|nil` | Options to override defaults (see Options Table below). |

**Returns:** `df_roundedpanel` — A new frame with rounded corners, border, title bar, and scale bar as configured.

**Example — Basic panel:**
```lua
local panel = DetailsFramework:CreateRoundedPanel(UIParent, "MyPanel", {
    width = 300,
    height = 200,
})
panel:SetPoint("center", UIParent, "center", 0, 0)
```

**Example — Panel with title bar and scale bar:**
```lua
local panel = DetailsFramework:CreateRoundedPanel(UIParent, "MyFancyPanel", {
    width = 400,
    height = 300,
    use_titlebar = true,
    use_scalebar = true,
    title = "My Window",
    scale = 1.0,
})
panel:SetPoint("center", UIParent, "center", 0, 0)
panel:SetColor(.1, .1, .1, 1)
panel:SetTitleBarColor(.2, .2, .2, .5)
panel:SetBorderCornerColor(.2, .2, .2, .5)
panel:SetRoundness(3)
```

---

### `detailsFramework:AddRoundedCornersToFrame(frame, preset)`

Adds rounded corners to an already existing frame. If the frame already has rounded corners (`__rcorners` flag), the call is ignored. If the frame has a visible backdrop border, a warning is printed since backdrop borders conflict with the rounded corner visuals.

**Parameters:**

| Parameter | Type | Description |
|---|---|---|
| `frame` | `frame` | An existing WoW frame (or a DetailsFramework widget with a `.widget` field). |
| `preset` | `df_roundedpanel_preset\|nil` | A preset table to configure appearance (see Preset Table below). If `nil`, a default preset is applied. |

**Returns:** Nothing. The frame is modified in place.

**Example — Using the default preset:**
```lua
local myFrame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
myFrame:SetSize(200, 100)
myFrame:SetPoint("center")
DetailsFramework:AddRoundedCornersToFrame(myFrame)
```

**Example — Using a custom preset:**
```lua
DetailsFramework:AddRoundedCornersToFrame(myFrame, {
    border_color = {0, 0, 0, 0.9},
    color = {0.15, 0.15, 0.15, 1},
    roundness = 5,
})
```

---

## Options Table

Used with `CreateRoundedPanel`. Any field not provided falls back to the default value.

| Key | Type | Default | Description |
|---|---|---|---|
| `width` | `number` | `200` | Width of the panel. |
| `height` | `number` | `200` | Height of the panel. |
| `use_titlebar` | `boolean` | `false` | Creates a title bar at the top of the panel. |
| `use_scalebar` | `boolean` | `false` | Creates a scale bar (requires a title bar or attaches to the panel). |
| `title` | `string` | `""` | Title text (used with the title bar). |
| `scale` | `number` | `1` | Initial scale of the panel (used with the scale bar). |
| `roundness` | `number` | `0` | How rounded the corners are. Higher values produce more rounded corners. |
| `color` | `table` | `{0.98, 0.98, 0.98, 1}` | Background color as `{r, g, b, a}`. |
| `border_color` | `table` | `{0.98, 0.98, 0.98, 1}` | Border color as `{r, g, b, a}`. |
| `corner_texture` | `string` | `Interface\CHARACTERFRAME\TempPortraitAlphaMaskSmall` | Texture used for the corner rounding. |

---

## Preset Table

Used with `AddRoundedCornersToFrame`. All fields are optional.

| Key | Type | Description |
|---|---|---|
| `border_color` | `table` | Border color as `{r, g, b, a}`. |
| `color` | `table` | Background color as `{r, g, b, a}`. |
| `roundness` | `number` | Corner roundness. If omitted, defaults to `1`. |
| `use_titlebar` | `boolean` | If `true`, creates a title bar on the frame. |
| `horizontal_border_size_offset` | `number` | Pixel offset added to horizontal border edges (for fine-tuning at small frame heights). |

**Default preset** (applied when no preset is passed to `AddRoundedCornersToFrame`):
```lua
{
    border_color = {.1, .1, .1, 0.834},
    color = {defaultRed, defaultGreen, defaultBlue}, -- DetailsFramework default backdrop color
    roundness = 3,
}
```

---

## Instance Methods

All methods below are available on a `df_roundedpanel` returned by `CreateRoundedPanel`, or on any frame after calling `AddRoundedCornersToFrame`.

### `panel:SetColor(red, green, blue, alpha)`

Sets the background color of the panel (corners and center fill). Color arguments can also be passed as a color table for the `red` parameter (any format accepted by `detailsFramework:ParseColors`).

When the panel has a border and alpha is below `0.98`, mask textures are shown on border corners to prevent overlapping alpha from producing a darker-than-expected appearance.

### `panel:SetBorderCornerColor(red, green, blue, alpha)`

Sets the color of the border (both corner textures and edge lines). If the border has not been created yet, it is created automatically on the first call.

### `panel:SetTitleBarColor(red, green, blue, alpha)`

Sets the color of the title bar. Does nothing if the panel has no title bar.

### `panel:SetRoundness(roundness)`

Sets how rounded the corners are. A value of `0` produces near-square corners; higher values increase roundness. This adjusts the size of the corner textures and recalculates border sizes. The corner texture base size is 16x16, so valid values generally range from `0` to about `15`.

### `panel:CreateTitleBar()`

Creates a title bar at the top of the panel. The title bar is itself a `df_roundedpanel` with a `Text` fontstring and a close button. The close button hides the parent panel when clicked.

**Returns:** `df_roundedpanel` — The title bar frame.

The title bar is stored at `panel.TitleBar`, and the title text fontstring is at `panel.TitleBar.Text`.

### `panel:CreateBorder()`

Creates the border around the panel. This is called automatically by `SetBorderCornerColor` if no border exists yet, so you typically don't need to call this directly.

The border consists of four corner textures (with mask textures for alpha blending) and four 1-pixel edge lines connecting the corners.

### `panel:GetCornerSize()`

**Returns:** `number, number` — The width and height of the corner textures.

### `panel:GetMaxFrameLevel()`

**Returns:** `number` — The highest frame level among all child frames of the panel.

### `panel:OnSizeChanged()`

Called automatically when the frame is resized. Recalculates corner texture sizes, border edge sizes, and title bar width. You don't need to call this manually — it is hooked into the frame's `OnSizeChanged` script.

### `panel:CalculateBorderEdgeSize(alignment)`

Calculates the length of a border edge line.

| Parameter | Type | Description |
|---|---|---|
| `alignment` | `"vertical"\|"horizontal"` | Which edge direction to calculate. |

**Returns:** `number` — The edge size in pixels.

---

## Internal Textures

These textures are accessible on the panel instance for advanced use cases:

| Field | Type | Description |
|---|---|---|
| `panel.CornerTextures` | `table` | Keyed by `"TopLeft"`, `"TopRight"`, `"BottomLeft"`, `"BottomRight"`. The corner textures. |
| `panel.CenterTextures` | `table` | Array containing the top horizontal edge, bottom horizontal edge, and center block. |
| `panel.BorderCornerTextures` | `table` | Keyed by corner name. Border corner textures (created by `CreateBorder`). |
| `panel.BorderEdgeTextures` | `table` | Keyed by `"Top"`, `"Left"`, `"Bottom"`, `"Right"`. The 1-pixel border edge lines. |
| `panel.TopHorizontalEdge` | `texture` | Fills the gap between the top-left and top-right corners. |
| `panel.BottomHorizontalEdge` | `texture` | Fills the gap between the bottom-left and bottom-right corners. |
| `panel.CenterBlock` | `texture` | Fills the center area between the top and bottom rows of corners. |
| `panel.TitleBar` | `df_roundedpanel` | The title bar frame (if created). |
| `panel.TitleBar.Text` | `fontstring` | The title bar's text fontstring. |

---

## How It Works

1. A circle texture is split into four quadrants using `SetTexCoord`. Each quadrant is placed at the corresponding corner of the frame.
2. Three solid-color textures fill the remaining space: one along the top edge (between the two top corners), one along the bottom edge, and one large block in the center.
3. An optional border is drawn using the same corner-splitting technique with an offset, plus four 1-pixel lines connecting the border corners.
4. When alpha is below `0.98` and a border exists, mask textures are enabled on border corners to prevent visual artifacts from overlapping semi-transparent textures.
5. When the frame height is less than 32 pixels, corner textures are scaled down and the center block is hidden so the panel remains visually correct.

---

# Snap System

Implementation file: `frames.lua`

Window-snapping behavior between movable frames, similar to the snapping found in UI editors. Frames are registered into a *snap group*. While a registered frame is being dragged, its edges are continuously checked against every other frame in the same group; when two edges come within a configurable distance, a glow appears on both connecting edges as a live preview. Releasing the drag anchors the frames together (`ClearAllPoints` + `SetPoint`) into a persistent chain — dragging any member of that chain afterwards moves the whole cluster together.

Frames in *different* groups never interact. Each call to `CreateSnapGroup` returns an isolated instance, so an addon may create as many groups as it needs.

---

## Entry Points

### `detailsFramework:CreateSnapGroup(groupName, profileTable, options)`

Creates a new snap group.

**Parameters:**

| Parameter | Type | Description |
|---|---|---|
| `groupName` | `string` | Identifies the group; also the key under which the group stores its data inside `profileTable`. |
| `profileTable` | `table\|nil` | Saved-variables table for persistence. The group's snap data lives at `profileTable[groupName]`. Pass `nil` for an in-memory-only group. |
| `options` | `table\|nil` | Overrides merged on top of the defaults (see Options Table below). |

**Returns:** `snapgroup` — A new isolated snap group instance.

**Example — Two draggable frames snapping together:**
```lua
local DF = DetailsFramework

local snapGroup = DF:CreateSnapGroup("MyWindows", MyAddonDB.snap, {snap_distance = 14})

local function makeWindow(name)
    local frame = CreateFrame("frame", name, UIParent, "BackdropTemplate")
    frame:SetSize(200, 150)
    frame:SetPoint("center")
    frame:SetBackdrop({bgFile = [[Interface\Tooltips\UI-Tooltip-Background]]})
    DF:MakeDraggable(frame)        --frame must be draggable BEFORE registering
    snapGroup:RegisterFrame(frame)
    return frame
end

local windowA = makeWindow("MyAddonWindowA")
local windowB = makeWindow("MyAddonWindowB")
```

Drag `windowB` close to `windowA`'s right edge: both edges glow gold. Release inside the preview range to snap them together. Drag `windowA` afterwards and `windowB` follows.

---

## Instance Methods

All methods below are available on a `snapgroup` returned by `CreateSnapGroup`.

### `snapGroup:RegisterFrame(frame[, id])`

Registers a frame into the group. The frame must already be set up for dragging (`SetMovable`, `EnableMouse`, `RegisterForDrag`, and an `OnDragStart` that calls `StartMoving` — `detailsFramework:MakeDraggable(frame)` does all of this). Its existing `OnDragStart`/`OnDragStop` scripts are *wrapped*, not replaced.

| Parameter | Type | Description |
|---|---|---|
| `frame` | `frame` | The frame (or a DetailsFramework widget with a `.widget` field) to register. |
| `id` | `string\|nil` | Stable identifier used for persistence. Required only when the frame has no name; if both a name and an `id` are present, the name wins. |

If the frame has no name and no `id` is provided, an assertion fires. If the frame is not movable, a warning is printed (snapping requires drag scripts to fire).

After registration, the group automatically attempts to restore any saved snap relationships involving this frame from `profileTable`, so registration order does not matter.

### `snapGroup:UnregisterFrame(frame)`

Removes a frame from the group: cuts all of its snap links, restores its original `OnDragStart`/`OnDragStop` scripts, and hides any leftover glow textures. The rest of its former cluster stays intact (each former neighbour becomes the root of whatever remains of its sub-cluster).

### `snapGroup:Unsnap(frame)`

Breaks every snap link of `frame`, leaving it free-standing at its current on-screen position. The frame stays registered in the group and can be re-snapped by dragging it again. This is the **only** way (besides `UnregisterFrame` / `Reset`) to detach a snapped frame — snap links never break implicitly during a drag.

### `snapGroup:SetProfileTable(newTable)`

Swaps the group's profile table at runtime and re-runs `TryRestore` against the new table. Use this when the addon switches between profiles that should share the same frame registrations.

### `snapGroup:SetOptionsTable(newOptionsTable)`

Replaces the group's options. The new table is merged on top of the snap defaults, so partial tables are valid.

### `snapGroup:Reset()`

Tears the group down to a blank, reusable state:
- every registered frame is unregistered (drag scripts restored, links cut, glow hidden);
- `profileTable` and `options` references are dropped (options are restored to the defaults);
- the current snap preview is cleared.

The data already written into the old profile table is **left untouched** — the caller owns that table. After `Reset`, the same `snapgroup` instance can be repopulated by calling `SetProfileTable`, `SetOptionsTable` and `RegisterFrame` again, which is what makes it appropriate for addon profile switches.

### `snapGroup:TryRestore()`

Recreates snap links and re-anchors cluster roots from the current `profileTable`. Safe to call repeatedly: links are only created when both frames involved are currently registered. `RegisterFrame` calls this automatically, but the addon may also call it explicitly once all of its frames have finished registering, for example after a delayed UI build.

### `snapGroup:Snap(frameData, candidate)` *(internal)*

Anchors `frameData` to a previewed candidate, merging the two clusters into one chain. Called by the wrapped `OnDragStop` when a valid preview exists on drop. Documented here because it appears as a method on the mixin; addons should not call it directly.

### `snapGroup:RemoveLink(frameData, side)` *(internal)*

Removes a single directed link (and its reciprocal on the other frame) on the given side. Returns the `snapframedata` of the frame that was on the other end of the removed link, or `nil` when there was no link. Use `Unsnap` from external code instead.

### `snapGroup:SavePersistent()` *(internal)*

Writes the group's current link graph and cluster-root positions into `profileTable[groupName]`. Called automatically after every structural change (snap, unsnap, register, unregister). No-op when the group has no profile table.

---

## Options Table

Used with `CreateSnapGroup` (and `SetOptionsTable`). Any field not provided falls back to the default value. Keys use `snake_case` because the table is exposed to the addon profile as user configuration.

| Key | Type | Default | Description |
|---|---|---|---|
| `snap_distance` | `number` | `12` | Maximum screen-pixel gap between two edges for them to be considered a snap candidate. |
| `perpendicular_align` | `boolean` | `true` | When `true`, edges within `snap_distance` on the perpendicular axis are aligned flush at drop time. When `false`, the perpendicular position at drop time is preserved verbatim. |
| `hysteresis` | `number` | `4` | A different candidate must be at least this many pixels closer than the currently previewed one to replace it. Prevents jitter when the cursor hovers between two edges. |
| `update_interval` | `number` | `0.015` | Seconds between proximity scans while a drag is active. Lower is more responsive but more CPU. |
| `glow_thickness` | `number` | `3` | Thickness (in pixels) of the edge highlight texture. |
| `glow_color` | `table` | `{1, 0.82, 0, 0.9}` | Edge highlight color as `{r, g, b, a}`. |
| `enabled_sides` | `table` | `{left=true, right=true, top=true, bottom=true}` | Which dragged-frame sides are allowed to snap. Disable individual sides to constrain how frames may attach. |

---

## Side Pairings

Sides are stored lowercase (`"left"`, `"right"`, `"top"`, `"bottom"`) so they can be passed straight to `frame:SetPoint` without conversion. The connecting axis is implicit:

| Dragged side | Target side | Connecting axis |
|---|---|---|
| `"left"` | `"right"` | x (horizontal touch) |
| `"right"` | `"left"` | x (horizontal touch) |
| `"top"` | `"bottom"` | y (vertical touch) |
| `"bottom"` | `"top"` | y (vertical touch) |

For a `left↔right` snap the resulting anchor is `draggedFrame:SetPoint("left", targetFrame, "right", 0, offsetY)`. The `offsetY` is `0` when the perpendicular top/bottom edges aligned flush, or the preserved drop-time offset otherwise.

---

## Persisted Format

When a `profileTable` is supplied, the group writes its data to `profileTable[groupName]`. The structure is documented here so the addon may inspect, migrate or hand-edit it if needed (but typically the addon never touches it directly):

```lua
profileTable[groupName] = {
    [frameId] = {
        --present only when this frame is the root of its cluster
        point = {x = number, y = number},   --absolute position in UIParent coordinate space

        --directed snap links emitted by this frame
        links = {
            [side] = {
                targetId = string,              --id of the frame on the other end
                mySide = string,                --this frame's side ("left"/"right"/"top"/"bottom")
                theirSide = string,             --target frame's side
                offsetX = number,               --SetPoint offset, this frame's coordinate space
                offsetY = number,
            },
            ...
        },
    },
    ...
}
```

Each link is stored in both directions (once on each frame), with the offsets negated on the reciprocal side. `Reset` does **not** wipe this table — it only drops the group's reference to it.

---

## How It Works

1. **Registration** — `RegisterFrame` wraps the frame's existing `OnDragStart`/`OnDragStop` scripts so the group can observe every drag without replacing the addon's own drag logic.
2. **Proximity scan** — While a drag is in progress, a dedicated per-group `UpdateFrame` runs `OnUpdate` throttled by `options.update_interval`. Each tick, every other frame in the group is evaluated against the dragged frame using simple O(1) edge-distance math. All measurements are converted to screen pixels via `GetEffectiveScale()`, so frames living under parents with different scales still compare correctly. The closest valid candidate wins.
3. **Preview** — When a candidate is found, two thin colored textures are positioned on the connecting edges of both frames. The preview stays on the same candidate from frame to frame unless another pairing becomes meaningfully closer (`options.hysteresis`), avoiding flicker. When no candidate exists, the glow is cleared immediately.
4. **Drop** — On `OnDragStop` with an active preview, the frames are anchored together via `ClearAllPoints` + `SetPoint`. The connecting axis is always flush. On the perpendicular axis, edges within `snap_distance` are aligned flush (`options.perpendicular_align`); otherwise the drop-time offset is preserved.
5. **Clusters** — A cluster is the connected component of frames joined by snap links, viewed as a spanning tree rooted at the one member anchored to `UIParent`. When a member is dragged, that member is temporarily promoted to the root for the duration of the drag, so the whole cluster follows the cursor through Blizzard's normal `StartMoving` behavior. On drop the cluster is rebuilt; links that would close a cycle are ignored for anchoring, which guarantees there are never recursive or broken point chains.
6. **Persistence** — After any structural change (snap, unsnap, register, unregister) the group writes its link graph and root positions to `profileTable[groupName]`. `TryRestore` runs after every `RegisterFrame` and idempotently creates links whose two frames are both currently registered, so the saved layout reassembles correctly regardless of registration order.

---

## Performance Notes

- Proximity scans run **only while a drag is active** and are throttled by `options.update_interval` — there is zero cost when no frame is being dragged.
- Each scan iterates only the frames registered in the same group, never a full-screen sweep. Splitting frames into several smaller groups further cuts the cost.
- Edge math uses simple O(1) distance and overlap comparisons; no allocations occur in the hot path beyond a single reused candidate table.
- Hysteresis keeps the chosen candidate stable, avoiding repeated glow texture re-anchoring while the cursor hovers between two edges.
- For very large groups, a spatial bucket / grid index over frame centers could replace the linear scan in the candidate-finder without changing the public API.

---

## Extensibility

The architecture is built so the snapping vocabulary can grow without disturbing existing behavior:

- **Corner snapping** — Add diagonal pairings (e.g. `topleft ↔ topleft`) to `SNAP_OPPOSITE` and `SNAP_AXIS`, plus a matching branch in the edge evaluator. The preview, anchor and persistence pipeline is already generic over side names.
- **Grid snapping** — Add an optional virtual grid target to the candidate finder (snap edges to the nearest grid line when no frame candidate is closer), reusing the existing offset math.
- **Same-side aligned snapping** — Already covered by `options.perpendicular_align`: when two frames are side-by-side, their top edges (or bottom edges, or left/right) auto-align flush if they are within `snap_distance`.
