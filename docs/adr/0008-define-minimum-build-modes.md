# Define the minimum Build Modes now

The Odin Game will start with three named Build Modes: `dev`, `test`, and `release`. `dev` includes the Inspector Overlay, Debug Commands, Render Pass inspection, Replay capture, and verbose trace categories; `test` runs headless Simulation, Replay, Event Trace, and invariant checks; `release` strips debug tools but keeps compact Event Trace so shipped behavior still has a causal record.

## Considered Options

- Let build commands and compile-time flags evolve organically.
- Define the minimum Build Modes before implementation starts.

## Consequences

- Build scripts must encode the mode names early.
- Debug-only code has a clear home.
- Humans can reproduce investigations by naming the same Build Mode.
