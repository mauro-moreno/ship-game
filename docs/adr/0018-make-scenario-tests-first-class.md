# Make Scenario tests first-class

Gameplay tests will primarily use named Scenario tests: small Simulation setups that exercise concrete behavior such as Support shield absorption, Tank spread damage, Zone pressure, bot targeting, victory, and Replay reproduction. Scenario tests match how humans investigate gameplay and provide higher leverage than isolated helper tests alone.

## Considered Options

- Test mostly low-level helper functions.
- Make named Scenario tests the main gameplay test shape.

## Consequences

- Simulation setup helpers need clear names and defaults.
- Tests assert Event Trace entries as well as final state.
- Bugs can be turned into focused regression Scenarios.
