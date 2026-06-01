# Compile the Game Data Catalog initially

The initial Odin Game will keep the Game Data Catalog in Odin code rather than loading ship stats, palette values, Zone phases, or world constants from external JSON, TOML, or other data files. We choose type safety, simple invariants, and debugger-friendly definitions first; external data can be reconsidered later if balance iteration becomes more important than compile-time visibility.

## Considered Options

- Load gameplay and palette data from external files from the start.
- Compile the initial Game Data Catalog into Odin code.

## Consequences

- Data changes require recompilation at first.
- Odin tests can assert invariants close to the data.
- Early debugging avoids file parsing, schema drift, and asset pipeline questions.
