# Include minimal Debug Dump export

The first `dev` Build Mode will include a minimal Debug Dump export command. A Debug Dump should capture enough investigation context to reproduce or discuss a bug: Build Mode, Scenario name when present, seed, Frame Step, Replay stream, Event Trace tail, selected Ship state, active Frame Breakpoints, and Render Pass toggles.

## Considered Options

- Add debug export later after tools mature.
- Include minimal Debug Dump export in the first developer build.

## Consequences

- Debug state needs a serializable summary early.
- Humans and future agents can exchange reproducible bug reports.
- Export scope can grow only when real investigations need more data.
