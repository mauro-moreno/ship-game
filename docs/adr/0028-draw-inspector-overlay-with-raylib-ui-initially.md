# Draw the Inspector Overlay with raylib UI initially

The initial Inspector Overlay will be drawn directly with raylib in an immediate-mode style rather than introducing a UI library. Simple panels, lists, toggles, selected Ship state, Event Trace tail, Render Pass controls, Frame Breakpoints, State Snapshot diff, Scenario browser, Debug Dump export, and Performance Timing should be built with project-owned UI code until the overlay's needs justify another dependency.

## Considered Options

- Introduce a UI library for the Inspector Overlay.
- Draw the initial Inspector Overlay directly with raylib.

## Consequences

- Overlay UI implementation stays simple and local.
- The project avoids an early dependency and another debugging surface.
- A UI library can be reconsidered if the Inspector Overlay becomes complex enough to justify it.
