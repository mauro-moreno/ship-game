# PRD: Single-Intent Movement Scenarios

## Problem Statement

The debuggable skeleton currently proves one movement behavior with `player_moves_forward`, but the Inspector Overlay cannot yet inspect the other basic ship-control directions as first-class Scenarios.

Without predefined Scenarios for backward thrust and turning, a developer has to reproduce these behaviors manually through live input. That weakens the investigation loop because tests, Replay, Event Trace, State Snapshot diff, Debug Dump export, and Scenario Browser inspection do not all start from the same known setup.

## Solution

Add predefined, compiled, test-backed Single-Intent Scenarios for the remaining basic movement controls and expose them through the Scenario Browser and exact text commands.

The next Scenario set should be:

1. `player_moves_forward`
2. `player_moves_backward`
3. `player_turns_left`
4. `player_turns_right`

Each new Scenario should apply one Control Intent for one Frame Step. Backward thrust should move the Ship backward along its current heading without changing heading. Turn-only Scenarios should change heading without changing position or velocity.

Add a Scenario Registry so Scenario Browser, text command parsing, tests, Replay setup, and Scenario lookup all use the same ordered catalog of predefined Scenarios.

## User Stories

1. As a developer, I want `player_moves_backward` available as a Scenario, so that I can inspect backward thrust without manual input.
2. As a developer, I want `player_turns_left` available as a Scenario, so that I can inspect left-turn heading behavior without combining it with thrust.
3. As a developer, I want `player_turns_right` available as a Scenario, so that I can inspect right-turn heading behavior without combining it with thrust.
4. As a developer, I want each movement Scenario to apply one Control Intent for one Frame Step, so that State Snapshot diff is easy to interpret.
5. As a developer, I want turn-only Scenarios to keep position unchanged, so that turning behavior is isolated from thrust and inertia.
6. As a developer, I want turn-only Scenarios to keep velocity unchanged, so that heading changes are not confused with acceleration.
7. As a developer, I want `player_turns_left` to produce negative heading movement from initial heading `0`, so that left-turn semantics are explicit.
8. As a developer, I want `player_turns_right` to produce positive heading movement from initial heading `0`, so that right-turn semantics are explicit.
9. As a developer, I want `player_moves_backward` to move along the reverse of the Ship's current facing direction, so that backward thrust is distinct from turning.
10. As a developer, I want `player_moves_backward` to keep heading unchanged, so that backward thrust can be inspected separately from rotation.
11. As a developer, I want `player_moves_backward` to update velocity and position, so that inertia is visible in the same way as forward thrust.
12. As a developer, I want all movement Scenarios to use the same deterministic initial Ship setup, so that differences come from Control Intent rather than setup drift.
13. As a developer, I want each movement Scenario to use a distinct seed, so that Replay, Debug Dump, and Scenario Browser rows are easy to distinguish.
14. As a developer, I want Scenario IDs to remain canonical behavior names, so that Debug Dumps, Replays, Event Trace entries, and text commands share one vocabulary.
15. As a developer, I want exact Scenario IDs in text commands, so that Replay records canonical Scenario identity without aliases.
16. As a developer, I want the Scenario Browser to list all four movement Scenarios, so that I can run or restart each probe visually.
17. As a developer, I want the Scenario Browser order to group thrust probes before turn probes, so that movement-control inspection is predictable.
18. As a developer, I want a Scenario Registry, so that Scenario Browser, lookup, text commands, tests, and Replay setup do not copy separate Scenario lists.
19. As a developer, I want the Scenario Registry to use builder procedures, so that every Scenario lookup creates a fresh deterministic setup.
20. As a developer, I want the Scenario Registry to avoid display names for now, so that the UI and debug artifacts use the same canonical IDs.
21. As a developer, I want every registered Scenario to be testable headlessly, so that Inspector Overlay behavior is backed by automated checks.
22. As a developer, I want every registered Scenario to be replayable to the same final state, so that movement investigations remain reproducible.
23. As a developer, I want Scenario Browser contents to be verified by tests, so that newly registered Scenarios are visible in the Inspector Overlay.
24. As a developer, I want movement Scenario tests to assert behavior-specific final state, so that failures point to the broken movement control.
25. As a developer, I want generic Event Trace behavior to remain covered without duplicating identical trace assertions for every movement Scenario, so that tests stay focused.

## Implementation Decisions

- Add three new Single-Intent Scenarios: `player_moves_backward`, `player_turns_left`, and `player_turns_right`.
- Keep `player_moves_forward` as the first Scenario and first item in the movement Scenario order.
- Use this Scenario Browser order: forward, backward, turn left, turn right.
- Use exact canonical Scenario IDs only. Do not add text-command aliases.
- Keep each new Scenario to one Frame Step and one Control Intent.
- Use initial heading `0` for all four movement Scenarios.
- Use distinct seeds: forward `1`, backward `2`, turn left `3`, turn right `4`.
- Define backward thrust as reverse movement along the current facing direction with unchanged heading.
- Define left turn as negative heading movement.
- Define right turn as positive heading movement.
- Define turn-only Scenarios as pure heading probes: no position change and no velocity change.
- Add a Scenario Registry as the ordered catalog of predefined Scenarios.
- The Scenario Registry should use builder procedures rather than shared concrete Scenario values.
- Scenario Browser should read from the Scenario Registry.
- Scenario lookup by ID should read from the Scenario Registry.
- Text command Scenario parsing should read from the Scenario Registry.
- Replay setup should continue to work from Scenario definitions produced by the registry.
- Do not add Scenario display names yet; canonical IDs are the display surface for this slice.
- Do not add Scenario Browser scrolling yet; the current four-item browser capacity is enough for this slice.
- Do not create an ADR for this slice; it follows existing Scenario, Inspector Overlay, Replay, and Control Intent decisions.

## Testing Decisions

- Test external behavior through Scenario, Scenario Registry, Replay, and Scenario Browser interfaces rather than implementation details.
- Add focused Scenario tests for each new Single-Intent Scenario.
- `player_moves_backward` should assert unchanged heading, negative x velocity, negative x position, zero y velocity, zero y position, and speed within max speed.
- `player_turns_left` should assert final heading is less than initial heading, with unchanged position and zero velocity.
- `player_turns_right` should assert final heading is greater than initial heading, with unchanged position and zero velocity.
- Add a shared test that every registered Scenario appears in the Scenario Browser in registry order.
- Add a shared test that every registered Scenario can be looked up by exact ID.
- Add a shared test that text command parsing accepts every exact Scenario ID for run and restart commands.
- Add a shared Replay test that every registered Scenario reproduces the same final Simulation state.
- Keep Event Trace assertions generic unless new movement-specific event categories are introduced.
- Use existing movement and replay tests as prior art for final-state and reproduction assertions.

## Out of Scope

- Runtime Scenario authoring in the Inspector Overlay.
- Saving, loading, or editing Scenario metadata.
- Scenario display names.
- Scenario Browser scrolling or pagination.
- Text-command aliases such as `forward`, `backward`, `left`, or `right`.
- Multi-step movement sequences such as `player_turns_left_then_moves_forward`.
- Combined turn-and-thrust Scenarios.
- Combat, bots, Zone behavior, weapons, shields, particles, audio, HUD polish, minimap, or Battle Royale flow.
- New Event Trace categories unless implementation reveals a concrete need.
- New ADRs for this slice.

## Further Notes

This slice should make the Inspector Overlay better at isolating the four basic ship-control directions before adding richer gameplay. Sequence Scenarios can come later once the Single-Intent Scenario set is stable and visible in the Scenario Browser.
