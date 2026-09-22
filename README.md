# Export Tools

Generate store and library images for publishing platforms. Steam is included; more platforms can be added through the platform registry.

## Run

1. Open this folder in Godot / Blazium **4.3+**
2. Press **Play** (F5)

No Inspector editing is required.

## Workflow

1. Choose a **Platform** (Steam today)
2. Select an **asset type** from the list
3. Optionally **Add / Replace Image** for that asset, or adjust branding colors / shared logo
4. Click **Export**
5. Use **Open Export Folder** to find the PNGs (`user://exported/<platform>/`)

## Image modes

- **Template branding** — procedural logo colors and built-in layout
- **Per-asset image** — your PNG/JPG/WebP/SVG replaces that asset’s output
- **Shared logo** — optional logo applied to logo-capable assets

## Extending platforms

Implement `ExportPlatform` under `src/platforms/`, then register it in `PlatformRegistry`. The UI reads platforms from the registry only.
