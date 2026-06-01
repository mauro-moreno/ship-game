# Debugging Guide

This project treats debugging as part of the game architecture. The goal is that a human can isolate and investigate gameplay and rendering behavior without editing code or guessing from visuals.

## Investigation Loop

1. Run the Odin Game in `dev` Build Mode.
2. Open the Inspector Overlay.
3. Choose a Scenario or start a normal Battle Royale.
4. Use pause and Frame Step to control time.
5. Select a Ship or other traceable object by Object ID.
6. Inspect State Snapshot before/after data for the selected Frame Step.
7. Filter Event Trace by Frame Step, Object ID, Ship, or event kind.
8. Toggle or capture Render Passes to isolate visual behavior.
9. Use Frame Breakpoints to pause on specific causes.
10. Export a Debug Dump when an issue needs to be shared or reproduced.

## First Tools

- Inspector Overlay in `dev` Build Mode.
- Scenario Browser for running named Scenarios visually.
- Minimal Replay using seed plus input and Debug Command stream.
- Compact Event Trace in all Build Modes, with verbose categories in `dev` and `test`.
- Frame Breakpoints and State Snapshot diff in `dev`.
- Continuous Invariant checks in `dev` and `test`.
- Render Pass toggles and captures for every named Render Pass.
- Shader hot reload for separate shader files.
- Minimal Performance Timing in the Inspector Overlay.
- Debug Dump export and automatic dumps on `dev` and `test` failures.

## Debug Artifact Formats

Debug artifacts should be versioned text formats first:

- Debug Dump: JSON.
- Scenario metadata: JSON.
- Event Trace stream: line-oriented text such as JSONL.
- Replay stream: line-oriented text such as JSONL.

Use binary formats only after size or speed becomes a demonstrated problem.

## Boundaries

- Simulation is deterministic and raylib-free.
- Raylib input is normalized before Simulation and Replay.
- Audio and visual particles are derived outside Simulation from Event Trace and read-only views.
- Camera state is outside Simulation.
- Game Data Catalog is compiled into Odin initially.
- Debug Commands are the only way debug tools mutate Simulation state.
