# Support minimal debug text commands

The Inspector Overlay will support a minimal text command console for Debug Commands that are too specific or rare to expose as buttons. Common actions can still use hotkeys and UI controls, but commands such as selecting a Scenario, adding a Frame Breakpoint, damaging a Ship, forcing a Zone phase, exporting a Debug Dump, or selecting a Ship should also be expressible as text commands.

## Considered Options

- Drive Debug Commands only through buttons and hotkeys.
- Add a minimal text command console for Debug Commands.

## Consequences

- Debug Command parsing needs a small, inspectable grammar.
- Replay can record text-command-derived Debug Commands after normalization.
- The Inspector Overlay can stay compact while still exposing precise investigation actions.
