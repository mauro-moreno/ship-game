# Write Debug Dumps on dev and test failures

`dev` and `test` Build Modes will automatically write a Debug Dump when an invariant failure or crash is detected. In `dev`, the game should pause and export the dump when possible; in `test`, the dump should be written alongside the failing test output. `release` will not write automatic Debug Dumps unless explicitly enabled.

## Considered Options

- Require humans to export Debug Dumps manually.
- Automatically write Debug Dumps for `dev` and `test` failures.

## Consequences

- Failure handling needs access to current Scenario, Replay, Event Trace, State Snapshot, Frame Breakpoint, and Render Pass context.
- Failing tests become easier to reproduce in the Inspector Overlay.
- Release builds avoid unexpected file output by default.
