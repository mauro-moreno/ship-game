# Make every Render Pass inspectable

Every named Render Pass in the Odin Game must be individually toggleable or capturable in debug Build Modes, including Shader Passes. We accept the extra Render Pipeline structure because raylib drawing and shaders can otherwise make visual defects hard to attribute to background, zone, world, effects, HUD, minimap, or debug overlay code.

## Considered Options

- Make only major Render Passes inspectable.
- Make every named Render Pass inspectable, including Shader Passes.

## Consequences

- Render Passes need stable names and explicit ordering.
- Shader Passes need isolated inputs, outputs, and fallback inspection paths where practical.
- Visual debugging can narrow a defect to one pass before inspecting implementation details.
