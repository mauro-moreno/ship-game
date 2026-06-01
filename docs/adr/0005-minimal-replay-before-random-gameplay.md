# Add minimal Replay before random gameplay complexity

The Odin Game will include a minimal Replay harness before implementing bots and combat behavior that depends on randomness. Replay only needs to capture the seed plus input and Debug Command stream at first, but it must be able to reproduce Frame Step results so AI, damage, zone, and victory bugs can be isolated after they appear.

## Considered Options

- Add Replay after the first playable build.
- Add minimal Replay before bots and combat introduce randomness-heavy behavior.

## Consequences

- Early input and Debug Command handling must be serializable.
- Simulation randomness must come from an explicit seeded source.
- Replay scope stays narrow until real debugging needs justify expanding it.
