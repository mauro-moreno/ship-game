# Include a minimal camera in the skeleton

The debuggable skeleton will include a minimal camera outside Simulation rather than rendering the World directly in screen coordinates. The first camera can simply follow the player Ship without smoothing, but it must expose position and zoom to the Inspector Overlay so world-to-screen behavior is debuggable before more Render Passes and polished visuals arrive.

## Considered Options

- Render the initial World directly in screen coordinates.
- Include a minimal outside-Simulation camera from the skeleton.

## Consequences

- Render Pipeline starts with real world-to-screen transforms.
- Camera bugs stay separate from Simulation bugs.
- Inspector Overlay can show camera state early.
