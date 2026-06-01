# Keep camera state outside Simulation

Camera state will live outside the Simulation as application and Render Pipeline state derived from Simulation views, usually the player Ship position. Camera smoothing, viewport framing, and screen-space transforms affect presentation rather than gameplay truth, so they should be inspectable render inputs without becoming part of deterministic combat, AI, zone, or victory behavior.

## Considered Options

- Store camera state inside Simulation.
- Keep camera state outside Simulation and derive it from read-only views.

## Consequences

- Replay focuses on gameplay state rather than viewport state.
- Render Pipeline tests and debug views can still inspect camera inputs.
- Camera bugs are isolated from Simulation bugs.
