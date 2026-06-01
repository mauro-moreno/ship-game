# Normalize input before Simulation and Replay

Input from raylib will be normalized into project-owned player input commands before it reaches Simulation or Replay. Replay stores gameplay intent such as movement vector, aim point or direction, fire, shield, and Debug Commands rather than raw key, mouse, or raylib state.

## Considered Options

- Store raw raylib input state in Replay and pass it toward Simulation.
- Normalize input into project-owned commands before Simulation and Replay.

## Consequences

- Raylib remains an input adapter, not gameplay infrastructure.
- Replay stays stable if key bindings or mouse handling change.
- Tests can construct player input commands without a window.
