# Keep the Simulation deterministic and raylib-free

The Odin Game will keep the Simulation independent from raylib: a Frame Step takes prior Simulation state, explicit input, Debug Commands, and seeded randomness, then produces next state plus an Event Trace. This rejects the convenience of using raylib types, input polling, timing, rendering, audio, or shaders inside gameplay code because the project priority is that a human can replay, test, step, and inspect gameplay without a window or GPU.

## Considered Options

- Put raylib types and timing directly in gameplay code for faster initial implementation.
- Keep raylib behind adapters and make the Simulation depend only on project-owned data.

## Consequences

- Raylib remains in the Render Pipeline, input adapter, audio adapter, and application shell.
- Simulation tests can run headlessly through Odin's test runner.
- Replay and Event Trace can explain gameplay outcomes without rendering a frame.
