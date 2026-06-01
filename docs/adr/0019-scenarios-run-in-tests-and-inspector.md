# Run Scenarios in tests and the Inspector Overlay

Scenarios will be reusable by both headless tests and the Inspector Overlay in `dev` Build Mode. A Scenario should be able to verify behavior automatically and also launch visually so a human can inspect the same setup through hitboxes, AI intent, Render Passes, Event Trace, and Frame Step controls.

## Considered Options

- Keep Scenario setup only inside tests.
- Let tests and the Inspector Overlay run the same Scenarios.

## Consequences

- Scenario definitions must avoid test-runner-only assumptions.
- Visual investigation and automated regression tests share setup language.
- A failing gameplay test can become an inspectable dev session without recreating state manually.
