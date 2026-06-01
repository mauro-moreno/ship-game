# Use stable debuggable IDs

Simulation objects that appear in Event Trace, Replay, State Snapshot diff, Debug Dump, Trace Filtering, AI intent, or Inspector Overlay selection will use stable project-owned IDs rather than transient array indexes. Stable IDs make it possible to follow the same Ship, bullet, or other tracked object across Frame Steps and reproduced runs.

## Considered Options

- Use transient array indexes as object identifiers.
- Use stable project-owned IDs for debuggable Simulation objects.

## Consequences

- Simulation allocation needs ID assignment.
- Debug artifacts can reference objects consistently.
- Data structures can change without breaking Event Trace or Inspector selection semantics.
