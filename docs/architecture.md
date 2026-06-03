# Architecture Overview

The Odin Game is built around debuggability. Gameplay truth lives in a deterministic, raylib-free Simulation; raylib is used by adapters around input, rendering, audio, and the application shell.

## Main Modules

**Simulation**

Owns gameplay state and mutation: Ships, bullets, health, shields, AI intent, Zone progression, damage, victory, defeat, Object IDs, Invariants, and Event Trace production. Simulation advances by integer Frame Step and receives normalized player input, Debug Commands, and seeded randomness.

**Simulation Run**

Runs one or more Simulation Frame Steps from an initial state, explicit Build Mode, and either a Scenario or Replay source. It returns the final Simulation state plus Event Trace, so Scenario and Replay execution share the same deterministic path.

**Input Adapter**

Reads raylib keyboard and mouse state and normalizes it into project-owned player input commands before Simulation or Replay sees it.

**Replay**

Records and replays seed, normalized input, and Debug Command streams. Replay exists to reproduce Simulation behavior, not camera, audio, or rendering details.

**Event Trace**

Records compact causal gameplay events from every Frame Step, with verbose categories available in `dev` and `test` Build Modes. HUD, Inspector Overlay, audio, particles, Replay diagnostics, and tests read the same causal record.

**Render Pipeline**

Turns read-only Simulation views into the final frame through named Render Passes. Every Render Pass is toggleable or capturable in debug builds. Shader Passes use separate shader files and can support hot reload in `dev`.

**Render Pass Registry**

Defines Render Pass order, labels, artifact keys, default enabled state, and Build Mode visibility in one place. Render loop ordering, keyboard toggles, Performance Timing, Inspector Overlay summaries, and Debug Dump fields read from the registry.

**Inspector Overlay**

The raylib-drawn debug interface in `dev` Build Mode. It provides Scenario Browser, object picking, hitboxes, AI intent, Event Trace filtering, State Snapshot diff, Frame Breakpoints, Debug Commands, Render Pass controls, Performance Timing, and Debug Dump export.

**Inspector Overlay View Assembly**

Builds the read-only Inspector Overlay View from a single input bundle. It derives render debug view, Scenario Browser state, selected Event Trace, and filtered Event Trace locally so app and Debug Dump callers do not duplicate assembly details.

**Inspector Overlay Control Routing**

Routes text console input, registered panel controls, Scenario Browser clicks, and object picking through one overlay command path. Static panel controls are registered in game code as Debug Command targets; raylib only supplies click and text input adapters.

**Debug Dump Format**

Serializes Debug Dump context into a versioned text document without any file path, directory, or storage behavior.

**Debug Dump File Output**

Writes preformatted Debug Dump documents to disk. File output is an adapter around the format, so tests and tools can inspect formatted Debug Dumps without touching storage.

**Audio Adapter**

Plays sounds from Event Trace and read-only views. Audio never changes Simulation state.

**Visual Effects**

Render-side particles and presentation effects are derived from Event Trace and read-only views. Gameplay-relevant effects stay in Simulation or Event Trace.

**Game Data Catalog**

Compiled Odin definitions for ship stats, palette values, Zone phases, world constants, and related Invariants. External data loading is deferred.

## Build Modes

**dev**

Runs the playable game with Inspector Overlay, Debug Commands, Scenario Browser, Replay capture, Render Pass inspection, shader hot reload, verbose Event Trace categories, continuous Invariant checks, Frame Breakpoints, State Snapshot diff, Performance Timing, and Debug Dump export.

**test**

Runs headless Simulation tests, Scenario tests, Replay checks, Event Trace assertions, and continuous Invariant checks. Failing tests write Debug Dumps when possible.

**release**

Runs the playable game without debug tools. Compact Event Trace remains available; only minimal checks are retained.

## Data Flow

```text
raylib input / Scenario / Replay
  -> Input Adapter
  -> normalized input + Debug Commands
  -> Simulation Run
  -> Simulation Frame Step
  -> next Simulation state + Event Trace + read-only views
  -> Render Pipeline / Inspector Overlay / Audio Adapter / Replay diagnostics
```

## Debugging Flow

```text
Scenario or normal Battle Royale
  -> pause or Frame Step
  -> object pick by Object ID
  -> inspect State Snapshot diff
  -> filter Event Trace
  -> toggle Render Passes
  -> export Debug Dump
```

## Non-Goals For The First Implementation

- External Game Data Catalog files.
- Binary debug artifact formats.
- UI library for the Inspector Overlay.
- Automated visual regression tests.
- Cross-platform bit-exact deterministic math.
