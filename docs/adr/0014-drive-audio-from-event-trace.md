# Drive audio from Event Trace outside Simulation

Audio will live outside the Simulation as an adapter that reacts to Event Trace entries and read-only views. Shots, hits, shield absorption, kills, zone warnings, victory, and defeat can produce sounds, but audio playback must not affect gameplay truth, Frame Step results, Replay, or headless tests.

## Considered Options

- Trigger audio directly from Simulation logic.
- Drive audio from Event Trace outside Simulation.

## Consequences

- Headless Simulation tests do not initialize raylib audio.
- Replay can reproduce gameplay without requiring sound playback.
- Audio bugs are isolated to the audio adapter and Event Trace mapping.
