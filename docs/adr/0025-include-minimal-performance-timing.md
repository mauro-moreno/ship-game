# Include minimal performance timing from day one

The first `dev` Build Mode Inspector Overlay will show minimal performance timing: Simulation step time, Render Pipeline total time, per Render Pass time, entity counts, FPS, and frame time. This is diagnostic context rather than optimization work, and it helps humans distinguish gameplay bugs, render stalls, Shader Pass cost, and entity-count problems early.

## Considered Options

- Add performance timing after the game is feature-complete.
- Include minimal performance timing from day one.

## Consequences

- Render Passes and Frame Steps need timing hooks early.
- Performance readings can be included in Debug Dumps when useful.
- Early investigations can separate correctness problems from frame pacing problems.
