# Include object picking in the Inspector Overlay

The first `dev` Build Mode Inspector Overlay will support object picking by clicking visible Simulation objects, starting with Ships and extending to bullets once combat exists. Picking selects the object's Object ID and uses it to focus State Snapshot views, Event Trace filtering, AI intent, hitboxes, Debug Commands, and Debug Dump context.

## Considered Options

- Select objects only through lists or text commands.
- Include click-based object picking in the Inspector Overlay.

## Consequences

- Render and debug views need screen-to-world picking helpers.
- The Inspector Overlay depends on stable Object IDs.
- Human investigations can start from the visible problem on screen.
