# Split gameplay effects from visual particles

The Odin Game will separate gameplay-relevant effects from visual particles. Gameplay causes such as hits, shield absorption, kills, zone damage, and phase changes belong in Simulation state or Event Trace; visual particles belong on the render side and are derived from Event Trace or read-only views unless a future gameplay rule explicitly needs particle determinism.

## Considered Options

- Keep particles inside Simulation like the Reference Prototype.
- Split gameplay effects from visual particles.

## Consequences

- Simulation tests do not need to track cosmetic particle lifetimes.
- Render Pipeline can tune particles without changing gameplay replay.
- Event Trace becomes the bridge between gameplay causes and visual effects.
