# Keep shaders in separate files

Shader code will live in separate shader source files rather than embedded Odin strings. Shader Passes are already harder to inspect than raylib primitive drawing, so keeping shader sources separate makes them easier to diff, reload in `dev` Build Mode, document with named uniforms, and isolate when a Render Pass behaves incorrectly.

## Considered Options

- Embed shader source as strings in Odin for packaging convenience.
- Keep shader source in separate files.

## Consequences

- Packaging must account for shader assets.
- `dev` Build Mode can support shader hot reload.
- Shader inputs, outputs, and uniforms can be reviewed without reading Odin render code.
