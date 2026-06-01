# Include the Inspector Overlay from day one

The first playable Odin Game will include a minimal Inspector Overlay rather than deferring debug tooling until the core game feels complete. The initial overlay only needs pause, Frame Step, selected Ship state, hitboxes, and an Event Trace tail, but it must exist early so gameplay behavior is investigated through explicit tools instead of temporary prints, code edits, or guesswork.

## Considered Options

- Build the game first and add the Inspector Overlay later.
- Include a minimal Inspector Overlay from the first playable build.

## Consequences

- Early feature work carries a small UI and command cost.
- The Simulation needs stable read-only views and Debug Commands earlier.
- Every gameplay feature can be inspected as it is introduced.
