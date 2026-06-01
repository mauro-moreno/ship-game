# PRD: Debuggable Odin Skeleton

## Problem Statement

The project needs to recreate the Reference Prototype as an Odin Game using raylib, but the highest priority is not immediate feature completeness. The highest priority is that a human developer can isolate and investigate every part of gameplay and rendering as the game evolves.

Without a debuggable skeleton first, the Odin Game risks becoming a native version of the Reference Prototype's one-file loop: playable, but hard to replay, inspect, test, or explain when movement, AI, combat, Zone behavior, shaders, HUD, and effects start interacting.

## Solution

Build the first Odin implementation as a thin vertical slice that proves the debugging architecture end to end. The skeleton should open a raylib window in `dev` Build Mode, normalize input into Control Intent, advance a deterministic raylib-free Simulation by integer Frame Step, emit Event Trace, expose read-only views, render a simple debug Ship shape through named Render Passes, and provide an Inspector Overlay with Scenario execution, Replay, State Snapshot diff, Frame Breakpoints, Invariants, Performance Timing, and Debug Dump export.

The first gameplay Scenario is `player_moves_forward`: one Ship with a stable Object ID, ship-like thrust-and-turn controls, minimal inertia, fixed heading, and reproducible movement under forward thrust. This slice intentionally excludes bots, combat, Zone, polished silhouettes, shaders, audio, particles, minimap, and Battle Royale flow until the debugging foundation is proven.

## User Stories

1. As a developer, I want the Odin Game to run in a `dev` Build Mode, so that I can inspect gameplay while it is running.
2. As a developer, I want the Simulation to run without raylib, so that I can test gameplay headlessly.
3. As a developer, I want Simulation time to use integer Frame Steps, so that I can reproduce exact investigation points.
4. As a developer, I want raylib input normalized into Control Intent, so that gameplay does not depend on raw key or mouse state.
5. As a developer, I want Control Intent to include forward thrust, backward thrust, turn left, and turn right, so that the Odin Game uses ship-like controls.
6. As a developer, I want the first Ship to have heading, velocity, damping, turn speed, thrust acceleration, and max speed, so that movement has inspectable inertia.
7. As a developer, I want every traceable Simulation object to have a stable Object ID, so that I can follow it across Frame Steps, Replay, Event Trace, and Debug Dumps.
8. As a developer, I want a `player_moves_forward` Scenario, so that the first movement behavior is reproducible and testable.
9. As a developer, I want Scenarios to run in tests and in the Inspector Overlay, so that a failing automated setup can be inspected visually.
10. As a developer, I want Replay to record seed, Control Intent, and Debug Commands, so that I can reproduce a Simulation run.
11. As a developer, I want compact Event Trace emitted from every Frame Step, so that gameplay causes are visible without reading render state.
12. As a developer, I want verbose Event Trace categories in `dev` and `test`, so that deeper investigations can capture more context when needed.
13. As a developer, I want Event Trace entries to reference Frame Step and Object ID where relevant, so that I can filter cause chains.
14. As a developer, I want State Snapshot capture before and after a Frame Step, so that I can see exactly what changed.
15. As a developer, I want State Snapshot diff to show Ship position, heading, velocity, and selected Object ID changes, so that movement bugs are easy to isolate.
16. As a developer, I want Invariants to run continuously in `dev` and `test`, so that invalid Simulation state is caught at the frame where it appears.
17. As a developer, I want Invariant failures to feed Event Trace and Frame Breakpoints, so that failures are both visible and reproducible.
18. As a developer, I want a minimal camera outside Simulation, so that world-to-screen behavior is debuggable without becoming gameplay truth.
19. As a developer, I want the first Render Pipeline to use named Render Passes, so that visual output can be isolated by pass.
20. As a developer, I want the first Render Passes to include background, world, debug, and inspector, so that the skeleton has real pass toggles without visual overreach.
21. As a developer, I want every initial Render Pass to be toggleable in `dev`, so that I can isolate rendering defects.
22. As a developer, I want the first Ship rendered as a simple debug shape, so that heading, velocity, Object ID, and hitbox are readable before polished silhouettes exist.
23. As a developer, I want the Inspector Overlay available from the first playable build, so that debugging tools are built alongside gameplay.
24. As a developer, I want the Inspector Overlay to pause, resume, and manually Frame Step, so that I can inspect behavior at my pace.
25. As a developer, I want click-based object picking for Ships, so that I can start an investigation from what I see on screen.
26. As a developer, I want the Inspector Overlay to show selected Object ID state, so that I can inspect a specific Ship.
27. As a developer, I want hitbox and velocity vector overlays, so that collision truth and movement direction are visible.
28. As a developer, I want a Scenario Browser, so that I can run and restart known Scenarios without text commands.
29. As a developer, I want minimal Trace Filtering by Frame Step, Object ID, and event kind, so that Event Trace remains usable as activity grows.
30. As a developer, I want Frame Breakpoints, so that the game pauses automatically on event kinds or Invariant failures.
31. As a developer, I want a minimal text command console for Debug Commands, so that precise debug actions do not require new buttons.
32. As a developer, I want Debug Commands to be the only way debug tools mutate Simulation state, so that Replay can account for human investigation actions.
33. As a developer, I want Performance Timing in the Inspector Overlay, so that I can separate Simulation, Render Pipeline, Render Pass, and frame pacing problems.
34. As a developer, I want Debug Dump export, so that I can share a reproducible investigation artifact.
35. As a developer, I want Debug Dumps written automatically on `dev` and `test` failures, so that failures have context even when I did not manually export.
36. As a developer, I want debug artifacts to use versioned text formats, so that humans and agents can diff, search, paste, and repair them.
37. As a developer, I want `test` Build Mode to run headless Scenario and Replay checks, so that gameplay behavior is verified without a window.
38. As a developer, I want `release` Build Mode to strip debug tools while keeping compact Event Trace, so that shipped behavior still has a causal record.
39. As a developer, I want the Game Data Catalog compiled into Odin initially, so that movement constants and Invariants stay type-safe and easy to inspect.
40. As a developer, I want module locations to be stable from day one, so that future contributors know where to investigate Simulation, Replay, Event Trace, Render Pipeline, Inspector Overlay, and Debug Dump behavior.

## Implementation Decisions

- Build the debuggable skeleton before expanding gameplay richness.
- Keep Simulation deterministic and independent from raylib.
- Use integer Frame Step time inside Simulation.
- Use floating-point Simulation math initially, with deterministic structure around it.
- Use ship-like Control Intent: forward thrust, backward thrust, turn left, and turn right.
- Include minimal Ship inertia in the skeleton.
- Use `player_moves_forward` as the first Scenario.
- Keep camera state outside Simulation.
- Expose Simulation through read-only views instead of raw mutable state.
- Use stable Object IDs for traceable Simulation objects.
- Emit compact Event Trace as normal Simulation output.
- Keep verbose Event Trace categories limited to `dev` and `test`.
- Make Replay minimal first: seed plus Control Intent and Debug Command stream.
- Use versioned text debug artifacts.
- Compile the initial Game Data Catalog into Odin code.
- Include an Inspector Overlay from the first developer build.
- Draw the initial Inspector Overlay directly with raylib in an immediate-mode style.
- Route all debug mutations through Debug Commands.
- Support a minimal text command console for Debug Commands.
- Include Frame Breakpoints and State Snapshot diff in the first developer build.
- Include a Scenario Browser in the Inspector Overlay.
- Include minimal Trace Filtering in the Inspector Overlay.
- Include click-based object picking for Ships.
- Include minimal Performance Timing from day one.
- Include manual Debug Dump export and automatic Debug Dumps on `dev` and `test` failures.
- Use named Render Passes from the skeleton.
- Make every named Render Pass inspectable in debug builds.
- Start with simple debug Ship shapes instead of polished Reference Prototype silhouettes.
- Defer Shader Passes until after the skeleton, then keep shaders in separate files with shader-only hot reload.
- Split gameplay effects from visual particles when effects are introduced.
- Drive audio from Event Trace outside Simulation when audio is introduced.
- Keep module boundaries stable from day one: application shell, Simulation, Game Data Catalog, input adapter, Scenario, Replay, Event Trace, Render Pipeline, Inspector Overlay, and debug artifacts.

## Testing Decisions

- Test external behavior through module interfaces rather than implementation details.
- The Simulation is the primary headless test surface.
- Scenario tests are first-class and should be named after gameplay behavior.
- `player_moves_forward` is the first Scenario test.
- Scenario tests should assert final state and Event Trace causes.
- Replay tests should verify that the same seed and Control Intent stream reproduce the same final state.
- Invariant checks should run continuously in `dev` and `test`.
- State Snapshot diff should be tested through visible changes in read-only views.
- Debug Commands should be tested as normalized actions, not as UI clicks or raw key input.
- Render Pipeline automation is not required in the first implementation; human Render Pass inspection comes first.
- Debug Dump export should be validated as versioned text containing the required investigation context.
- No prior Odin tests exist in the repo; these tests will establish the initial testing patterns.

## Out of Scope

- Full Battle Royale gameplay.
- Bots and AI behavior.
- Combat, bullets, damage, shields, and kills.
- Zone pressure and shrinking phases.
- Polished Ship silhouettes from the Reference Prototype.
- Shader Passes and shader hot reload in the first skeleton.
- Audio.
- Visual particles.
- Minimap.
- HUD polish.
- Ship selection menu.
- Automated visual regression tests.
- External Game Data Catalog files.
- Binary Replay, Event Trace, Scenario, or Debug Dump formats.
- Cross-platform bit-exact deterministic math.
- UI library for the Inspector Overlay.

## Further Notes

The Reference Prototype remains the visual and gameplay-feel reference, but it is not the architecture to copy. The Odin Game should evolve through small debuggable slices after the skeleton proves the full investigation loop.

Every later gameplay slice should add or update Scenario tests, Event Trace entries, Invariants, Inspector Overlay visibility, Replay coverage, and Render Pass inspection where visuals are involved.
