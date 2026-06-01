# Make Event Trace normal Simulation output

The Simulation will always produce a compact Event Trace as part of each Frame Step, with verbose trace categories enabled only in debug and test Build Modes. We accept the small runtime and design cost because gameplay outcomes must be explainable without attaching a debugger, reading render state, or relying on the HUD kill feed as the source of truth.

## Considered Options

- Emit trace data only in debug and test builds.
- Treat Event Trace as normal Simulation output, with optional verbose categories.

## Consequences

- Tests can assert causes, not just final state.
- Replays can explain why ships moved, fired, took damage, shielded, died, or won.
- The HUD, Inspector Overlay, and diagnostics read from the same causal record.
