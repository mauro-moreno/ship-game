# Expose Simulation through read-only views

The Simulation will expose read-only views for the Render Pipeline, Inspector Overlay, tests, and diagnostics instead of letting callers inspect or mutate raw Simulation state directly. This keeps gameplay invariants local to the Simulation while still giving humans the data needed to debug ships, bullets, particles, zone state, AI intent, cooldowns, health, shields, and victory conditions.

## Considered Options

- Let callers read raw Simulation state directly.
- Expose read-only views tailored to rendering, inspection, and tests.

## Consequences

- The Simulation needs explicit view shapes earlier.
- Render and debug code cannot accidentally depend on private mutation details.
- State representation can change without breaking every inspector or Render Pass.
