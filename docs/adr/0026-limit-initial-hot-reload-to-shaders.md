# Limit initial hot reload to shaders

Initial hot reload support will be limited to separate shader files in `dev` Build Mode. The Game Data Catalog remains compiled into Odin code, so hot reloading gameplay data is deferred until there is evidence that balance iteration needs it more than type safety, invariant checks, and simple debugging.

## Considered Options

- Hot reload shaders and Game Data Catalog values from the start.
- Limit initial hot reload to shader files.

## Consequences

- Shader Pass iteration can happen without restarting the game.
- Gameplay data changes still require recompilation.
- External data schemas are not introduced during the first debuggable implementation.
