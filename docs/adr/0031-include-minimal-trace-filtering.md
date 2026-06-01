# Include minimal Trace Filtering in the Inspector Overlay

The first `dev` Build Mode Inspector Overlay will include minimal Trace Filtering by Frame Step range, Ship, and event kind. Event Trace is normal Simulation output, but it becomes noisy as soon as bots, bullets, shields, Zone damage, and victory checks interact, so filtering must exist early enough for humans to isolate a cause chain.

## Considered Options

- Show the raw Event Trace without filters until it becomes painful.
- Include minimal Trace Filtering in the first Inspector Overlay.

## Consequences

- Event Trace entries need stable event kinds and optional Ship references.
- The Inspector Overlay needs simple filter controls early.
- Debug Dumps can record active Trace Filtering when useful.
