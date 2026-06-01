# Use debug shapes before polished Ship silhouettes

The debuggable skeleton will render Ships as simple debug shapes before porting polished Ship silhouettes from the Reference Prototype. The first Ship view should show heading, Object ID, velocity vector, and hitbox when enabled, because the initial Render Pipeline must prove inspection and correctness before visual polish.

## Considered Options

- Start by porting polished Ship silhouettes.
- Start with simple debug shapes.

## Consequences

- The first playable build will look deliberately plain.
- Render Passes and Inspector Overlay can validate orientation, movement, Object IDs, and hitboxes early.
- Polished silhouettes can be added later without changing Simulation movement truth.
