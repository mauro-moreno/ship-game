# Use floating-point Simulation math initially

The Simulation will use floating-point math initially, combined with fixed Frame Steps, seeded randomness, invariant tests, and Replay checks. We are optimizing for practical human debugging on the development platform, not cross-platform bit-exact lockstep determinism, so fixed-point math is deferred until there is evidence that floating-point drift is blocking investigation.

## Considered Options

- Use fixed-point or integer math for stricter determinism.
- Use floating-point math initially with deterministic structure around it.

## Consequences

- Simulation code stays simpler and closer to the Reference Prototype's movement model.
- Replay is expected to be stable enough for local debugging, not guaranteed bit-exact forever across all platforms.
- If cross-platform deterministic Replay becomes required, math representation must be revisited.
