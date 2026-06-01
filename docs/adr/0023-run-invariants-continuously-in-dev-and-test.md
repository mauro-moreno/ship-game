# Run invariants continuously in dev and test

Invariant checks will run continuously during Frame Steps in `dev` and `test` Build Modes, with only minimal checks retained in `release`. Invalid Simulation state should pause or fail at the Frame Step where it appears, because delayed symptoms make debugging much harder than immediate invariant failure.

## Considered Options

- Run invariants only in tests or explicit debug actions.
- Run invariants continuously in `dev` and `test`, with minimal `release` checks.

## Consequences

- Frame Step execution in `dev` and `test` carries invariant-check cost.
- Invariant failures can feed Frame Breakpoints and Event Trace diagnostics.
- Release behavior avoids heavy debug overhead while retaining essential safety checks.
