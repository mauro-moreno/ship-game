# Use integer Frame Step time for Simulation

Simulation time will be represented by integer Frame Step count rather than floating delta time. The Render Pipeline and application shell may use real time for presentation, smoothing, interpolation, and effects, but gameplay rules use fixed Frame Steps so Replay, Event Trace, and tests avoid timing drift.

## Considered Options

- Drive Simulation with floating delta time.
- Drive Simulation with integer Frame Step count.

## Consequences

- Gameplay speed is tied to fixed Simulation stepping.
- Slow frames require the application shell to run catch-up steps or pause deliberately.
- Replay comparisons can use exact Frame Step indexes.
