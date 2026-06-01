# Include Frame Breakpoints and State Diff in the first developer build

The first `dev` Build Mode will include Frame Breakpoints and State Snapshot/Diff tools. A human must be able to pause when specific gameplay causes occur and compare Simulation state before and after a Frame Step, because those two tools answer the core debugging questions: "when did this happen?" and "what changed?"

## Considered Options

- Add Frame Breakpoints and State Diff after the game is playable.
- Include them in the first developer build.

## Consequences

- Frame Step execution must expose before/after state to debug tools.
- Event Trace categories and invariant failures can become breakpoint conditions.
- Debugging cost is paid early, before gameplay complexity compounds.
