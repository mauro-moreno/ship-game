# Ship Game Context

This context defines the project language for porting the `index.html` reference into Odin with raylib. The priority is human debuggability: every gameplay and visual question should be isolatable through deterministic state, traceable events, named render passes, and explicit inspection tools.

## Language

**Reference Prototype**:
The existing `index.html` game used as the visual, interaction, and gameplay reference. It is a reference for behavior and feel, not the architecture to copy.
_Avoid_: web version, JavaScript source of truth

**Odin Game**:
The native implementation of Ship Game built in Odin with raylib. It should preserve the Reference Prototype's feel while using an architecture designed for inspection and debugging.
_Avoid_: port, rewrite

**Battle Royale**:
The full match loop where one player and bots fight inside a shrinking danger zone until one ship remains.
_Avoid_: arena mode, deathmatch

**World**:
The large square gameplay space in which ships, bullets, particles, the zone, and the camera exist.
_Avoid_: map, level

**Ship**:
A playable or AI-controlled combat craft with type-specific stats, movement, weapons, hitbox dimensions, health, and optional shield state.
_Avoid_: entity, unit

**Object ID**:
A stable project-owned identifier for a traceable Simulation object such as a Ship or bullet.
_Avoid_: array index, handle

**Tank**:
A slow, high-health ship with a rectangular hitbox and spread cannons.
_Avoid_: heavy, cruiser

**Support**:
A balanced ship with a square hitbox and a temporary shield burst.
_Avoid_: healer, guardian class

**Striker**:
A fast, fragile ship with a triangular visual identity, high damage, and rapid fire.
_Avoid_: DPS, damage class

**Zone**:
The shrinking safe area that pressures ships inward and damages ships outside it.
_Avoid_: storm, circle, gas

**Void**:
The dangerous space outside the Zone. The UI may call this out to the player, but code should treat it as zone damage.
_Avoid_: storm damage, out-of-bounds

**Simulation**:
The renderer-free gameplay state and rules for movement, AI, bullets, shields, damage, particles, zone progression, victory, and defeat.
_Avoid_: game loop, update blob

**Frame Step**:
One deterministic advancement of the Simulation from a prior state plus explicit input/debug commands.
_Avoid_: tick, update call

**Simulation Run**:
A deterministic execution of one or more Frame Steps from an initial Simulation state, explicit Build Mode, and a source of Control Intent and recorded Debug Commands. It produces final Simulation state plus Event Trace.
_Avoid_: scenario runner, replay runner

**Frame Breakpoint**:
A debug condition that pauses execution at a specific Frame Step or when a specific Event Trace entry, invariant failure, Ship, or Scenario condition appears.
_Avoid_: watchpoint, conditional pause

**State Snapshot**:
A captured read-only view of Simulation state before or after a Frame Step, used for comparison and debugging.
_Avoid_: dump, save state

**Invariant**:
A rule that must remain true for valid Simulation state, checked during Scenario tests and debug Frame Steps.
_Avoid_: assertion, sanity check

**Event Trace**:
The structured record of important Simulation causes and outcomes, such as shots fired, shield absorption, zone damage, kills, phase changes, and game over.
_Avoid_: log, kill feed

**Replay**:
A recorded seed plus input/debug command stream that can reproduce a Simulation run.
_Avoid_: recording, demo

**Scenario**:
A named, minimal Simulation setup used to reproduce or verify one gameplay behavior.
_Avoid_: fixture, test case

**Render Pipeline**:
The ordered set of raylib drawing passes that turn Simulation views into the final frame.
_Avoid_: draw function, renderer blob

**Render Pass**:
A named slice of the Render Pipeline, such as background, zone, world, effects, HUD, minimap, or debug overlay.
_Avoid_: draw section, layer

**Render Pass Registry**:
The single ordered catalog of Render Pass identity, labels, artifact keys, default enabled state, and Build Mode visibility.
_Avoid_: pass list, toggle list

**Performance Timing**:
Diagnostic timing information for Frame Steps, Render Pipeline work, Render Passes, entity counts, FPS, and frame time.
_Avoid_: profiler, benchmark

**Shader Pass**:
A Render Pass backed by a shader because raylib primitives are not enough for the visual effect or inspection need.
_Avoid_: shader effect, GPU magic

**Inspector Overlay**:
The in-game debug interface for selecting ships, showing hitboxes, viewing AI intent, reading Event Trace entries, toggling Render Passes, and issuing explicit debug commands.
_Avoid_: dev UI, debug menu

**Inspector Overlay View Assembly**:
The pure construction step that turns Simulation, Scenario, Trace, Render Pass, Frame Breakpoint, State Snapshot, and Performance Timing facts into one read-only Inspector Overlay View.
_Avoid_: overlay constructor, draw setup

**Inspector Overlay Control Routing**:
The single path that normalizes Inspector Overlay text console input, registered panel controls, Scenario Browser actions, and object picking into Debug Commands.
_Avoid_: button handler chain, input branches

**Debug Command**:
An explicit command that changes Simulation or debug-tool state during investigation, such as pausing, stepping, selecting a ship, spawning a scenario, or toggling a visualization.
_Avoid_: hotkey side effect, debug hack

**Control Intent**:
Project-owned player intent produced by the input adapter before Simulation, such as forward thrust, backward thrust, turn left, turn right, fire, or shield.
_Avoid_: raw input, key state

**Debug Dump**:
A serialized investigation artifact containing enough Build Mode, Scenario, Replay, Event Trace, State Snapshot, Frame Breakpoint, and Render Pass information to reproduce or discuss a bug.
_Avoid_: bug report, dump file

**Debug Dump Format**:
The versioned text representation of a Debug Dump. It serializes investigation context and does not choose file paths, create directories, or write storage.
_Avoid_: dump writer, exporter

**Debug Dump File Output**:
The adapter that writes a formatted Debug Dump document to disk. It owns output directory and filename concerns, not serialized content.
_Avoid_: formatter, serializer

**Game Data Catalog**:
The centralized source for ship stats, palette values, zone phases, world constants, and invariants that define the game.
_Avoid_: constants file, config dump

**Build Mode**:
A named way to build or run the Odin Game, with known assertions, logging, debug tools, and optimization behavior.
_Avoid_: flags, command variant

## Debuggability Rules

- The Simulation owns gameplay mutation and must not depend on raylib.
- Frame Step behavior should be deterministic for a known seed and input stream.
- Event Trace is the source for "why did this happen?" questions.
- Render Passes must be individually toggleable or inspectable in debug builds.
- Shader Passes need a non-shader fallback or an isolated inspection path when practical.
- The Inspector Overlay reads Simulation views and writes only explicit Debug Commands.
- The Game Data Catalog should carry invariants close to the data.
- Build Modes should be named and repeatable so a human can reproduce an investigation.
