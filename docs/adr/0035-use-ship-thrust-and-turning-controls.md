# Use ship thrust and turning controls

The Odin Game will use ship-like controls: forward thrust, backward thrust, turn left, and turn right. This intentionally diverges from the Reference Prototype's WASD movement plus mouse aim model because the native version should make Ship orientation and movement direction part of the Simulation, Replay, Scenarios, Event Trace, State Snapshot diff, and Inspector Overlay from the first debuggable skeleton.

## Considered Options

- Keep the Reference Prototype's directional movement plus mouse aiming.
- Use forward/backward thrust and left/right turning controls.

## Consequences

- The first Scenario becomes `player_moves_forward`.
- Normalized input uses thrust and turn intent instead of screen-direction movement.
- Ship orientation is Simulation state and must be visible in read-only views.
