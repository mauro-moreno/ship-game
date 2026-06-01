# Include minimal Ship inertia in the skeleton

The debuggable skeleton will include minimal Ship inertia instead of directly moving position from Control Intent. Ship state starts with heading, velocity, thrust acceleration, turn speed, damping, and max speed, because thrust-and-turn controls need visible momentum to feel like a Ship while still remaining simple enough for Frame Step, Replay, State Snapshot diff, and Scenario tests to inspect.

## Considered Options

- Move Ships kinematically with direct position changes.
- Include minimal inertia from the first skeleton.

## Consequences

- The first Scenario must assert velocity and position changes, not only position.
- State Snapshot diff must show heading, velocity, and position.
- Movement Invariants need max-speed and finite-number checks.
