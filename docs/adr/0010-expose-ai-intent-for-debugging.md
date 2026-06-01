# Expose AI intent for debugging

The Simulation will expose AI intent in debug and test views, and verbose Event Trace categories may record AI decisions when needed. Bot behavior should not be a black box: when a Ship retreats, attacks, roams, targets another Ship, or moves toward the Zone, humans need to inspect the intent that produced the movement and firing behavior.

## Considered Options

- Keep AI intent private inside bot behavior.
- Expose AI intent through debug/test views and verbose trace categories.

## Consequences

- AI code must name intent states explicitly.
- The Inspector Overlay can explain bot behavior without stepping through code.
- Release views can omit verbose AI intent unless needed for compact Event Trace causes.
