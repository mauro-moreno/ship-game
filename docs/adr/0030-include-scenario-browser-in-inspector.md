# Include a Scenario Browser in the Inspector Overlay

The first `dev` Build Mode Inspector Overlay will include a Scenario Browser that can list Scenarios, run one, restart it, show its seed, and expose a Debug Dump path when investigation needs to be shared. This keeps the test and visual-debug loop concrete: a Scenario can fail in tests, then be opened directly for Frame Step, Event Trace, hitbox, AI intent, Render Pass, and State Snapshot inspection.

## Considered Options

- Run Scenarios only through tests or text commands.
- Include a Scenario Browser in the Inspector Overlay.

## Consequences

- Scenario metadata must be available to the `dev` Build Mode.
- The Inspector Overlay needs a simple list/detail UI early.
- Failing Scenario investigations can move between test output and visual inspection without manual reconstruction.
