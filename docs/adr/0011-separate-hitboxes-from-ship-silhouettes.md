# Separate hitboxes from Ship silhouettes

The Odin Game will keep Ship hitboxes as Simulation truth and Ship silhouettes as Render Pipeline output, even when they visually overlap. The Reference Prototype already uses type-specific hitbox dimensions that do not equal the full drawn silhouette, and preserving that separation lets visual polish evolve without silently changing collision, damage, or debugging behavior.

## Considered Options

- Derive hitboxes from the rendered Ship silhouette.
- Keep hitboxes and Ship silhouettes separate.

## Consequences

- The Inspector Overlay must be able to draw hitboxes over silhouettes.
- Collision tests target Simulation hitboxes, not rendered art.
- Render changes cannot accidentally rebalance gameplay.
