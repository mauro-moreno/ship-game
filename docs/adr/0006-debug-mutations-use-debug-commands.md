# Route debug mutations through Debug Commands

The Inspector Overlay and other debug tools may read Simulation views directly, but any debug action that changes Simulation state must go through an explicit Debug Command. This includes quick investigation tools such as spawning ships, damaging ships, teleporting, changing Zone phase, or forcing cooldowns, because Replay and Event Trace must account for every state-changing action.

## Considered Options

- Let debug tools mutate Simulation state directly for convenience.
- Require all debug mutations to enter through Debug Commands.

## Consequences

- Debug tools need slightly more plumbing for each action.
- Replay can reproduce investigations that used debug tools.
- Event Trace can explain state changes caused by humans as well as gameplay rules.
