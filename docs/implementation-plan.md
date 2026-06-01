# Implementation Plan

This plan starts with the debuggable skeleton. The first goal is not a full Battle Royale; it is an end-to-end loop that proves the architecture can isolate and investigate gameplay behavior.

## Phase 1: Project Skeleton And Build Modes

Create the Odin/raylib application shell and minimum Build Modes.

Modules/files should match the intended seams from day one:

- `main` / app shell: window, loop, Build Mode wiring.
- `sim`: Simulation state, Frame Step, Invariants, read-only views.
- `catalog`: compiled Game Data Catalog.
- `input`: raylib input adapter to Control Intent.
- `scenario`: named Scenarios, starting with `player_moves_forward`.
- `replay`: seed plus Control Intent and Debug Command stream.
- `trace`: Event Trace types and buffer.
- `render`: Render Pipeline and first Render Passes.
- `inspector`: raylib UI overlay.
- `debug`: State Snapshot diff, Frame Breakpoints, Debug Dump, Performance Timing.

Acceptance checks:

- `dev`, `test`, and `release` Build Modes exist.
- `dev` opens a raylib window.
- `test` can run headless Simulation checks.
- `release` can build without debug-only UI.

## Phase 2: Deterministic Simulation Slice

Implement the first Simulation slice around one player Ship.

Scope:

- World state with one Ship.
- Stable Object ID for the Ship.
- Ship position, heading, velocity, hitbox, and movement constants.
- Integer Frame Step time.
- Floating-point movement math.
- Minimal inertia: forward/backward thrust, turn speed, damping, max speed.
- Invariants for finite values, valid Object ID, speed limit, and valid Ship state.
- Read-only views for render/debug/test callers.

Acceptance checks:

- Simulation does not import raylib.
- Frame Step takes prior state, Control Intent, Debug Commands, and seeded randomness.
- Frame Step returns next state and Event Trace.
- Invariants run continuously in `dev` and `test`.

## Phase 3: Control Intent And First Scenario

Normalize raylib input and create the first Scenario.

Scope:

- Control Intent values: forward thrust, backward thrust, turn left, turn right.
- Input adapter maps keys to Control Intent.
- Scenario `player_moves_forward`.
- Scenario can run in tests and in `dev`.

`player_moves_forward` should assert:

- Initial Ship heading is explicit.
- Forward thrust changes velocity in the facing direction.
- Position changes after integration.
- Heading does not change.
- Speed remains under max speed.
- Event Trace records movement.
- State Snapshot diff includes position and velocity changes.
- Replay produces the same final state.

Acceptance checks:

- `odin test` or the repo test command runs the Scenario headlessly.
- Scenario setup is reusable outside the test runner.

## Phase 4: Event Trace, Replay, And State Snapshot

Make the first debugging artifacts real.

Scope:

- Compact Event Trace output from every Frame Step.
- Event kinds for Scenario start, Control Intent applied, Ship moved, Invariant failure.
- Replay stream using a versioned text format.
- State Snapshot capture before and after Frame Step.
- State Snapshot diff for Ship position, heading, velocity, and selected Object ID.

Acceptance checks:

- Replay of `player_moves_forward` reaches the same final state.
- Event Trace can be filtered by Frame Step and Object ID in code.
- State Snapshot diff can explain what changed during a Frame Step.

## Phase 5: Render Pipeline And Minimal Camera

Render the Simulation through named Render Passes.

Initial Render Passes:

- `background`: flat dark background or simple grid.
- `world`: Ship debug shape, Object ID, velocity vector.
- `debug`: hitbox, selected Object ID, Snapshot diff markers.
- `inspector`: overlay panels and controls.

Scope:

- Minimal camera outside Simulation.
- Camera follows player Ship without smoothing.
- Render Pass toggles in `dev`.
- Simple debug Ship shape, not polished Reference Prototype silhouette.

Acceptance checks:

- Every initial Render Pass can be toggled.
- Camera position and zoom are visible in the Inspector Overlay.
- Hitbox and velocity vector can be shown.
- No polished silhouettes, shaders, particles, audio, bots, combat, Zone, or minimap yet.

## Phase 6: Inspector Overlay

Build the first raylib-drawn Inspector Overlay.

Scope:

- Pause and resume.
- Manual Frame Step.
- Selected Object ID.
- Object picking for Ships.
- Scenario Browser with `player_moves_forward`.
- Event Trace tail.
- Minimal Trace Filtering by Frame Step, Object ID, and event kind.
- State Snapshot diff panel.
- Invariant status panel.
- Frame Breakpoints for event kind and Invariant failure.
- Minimal text command console for Debug Commands.
- Performance Timing: Simulation step, Render Pipeline total, per Render Pass, entity counts, FPS, frame time.
- Debug Dump export command.

Acceptance checks:

- A developer can run `player_moves_forward`, pause, step, inspect movement, and export a Debug Dump.
- Debug Commands are the only Inspector Overlay path that mutates Simulation state.
- Inspector Overlay reads Simulation through read-only views.

## Phase 7: Debug Dump And Failure Handling

Make failures portable.

Scope:

- Debug Dump JSON with format version.
- Include Build Mode, Scenario name, seed, Frame Step, Replay stream, Event Trace tail, selected Object ID, State Snapshot diff, active Frame Breakpoints, Render Pass toggles, camera state, and Performance Timing.
- Automatic Debug Dump on `dev` and `test` Invariant failure when possible.

Acceptance checks:

- Manual Debug Dump export works in `dev`.
- A failing Scenario test writes a Debug Dump.
- Debug Dump is text-readable and contains enough data to reproduce `player_moves_forward`.

## Phase 8: Next Gameplay Slices

Only after the skeleton is proven, add gameplay in small debuggable slices.

Likely order:

1. Ship turning Scenario: `player_turns_left`.
2. Backward thrust Scenario: `player_moves_backward`.
3. Bullet firing without damage.
4. Hitbox collision and damage.
5. Support shield.
6. Zone pressure.
7. One bot with exposed AI intent.
8. Multiple bots.
9. Polished Ship silhouettes.
10. Shader Passes and shader hot reload.
11. Audio and visual particles from Event Trace.
12. Minimap, HUD polish, and Battle Royale loop.

Each slice must add or update:

- Scenario tests.
- Event Trace entries.
- Invariants.
- Inspector Overlay visibility.
- Replay coverage.
- Render Pass inspection where visuals are involved.
