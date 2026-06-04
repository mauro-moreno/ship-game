# Inspector Overlay

The Inspector Overlay is the `dev` Build Mode surface for answering two questions:

- What is the Simulation state right now?
- Which explicit Debug Command should change the investigation state next?

It reads from an `Inspector_Overlay_View`. It must not mutate Simulation directly; text input, panel controls, Scenario Browser actions, and object picking are normalized into Debug Commands through Inspector Overlay Control Routing.

## Reading The Header

`build=<mode> scenario=<id> seed=<seed> frame=<frame> status=<running|paused>`

- `build` tells you which Build Mode rules are active. The full overlay is expected in `dev`.
- `scenario` is the active Scenario. If behavior differs between a test and the window, confirm both use the same Scenario.
- `seed` is the Scenario seed used by Replay and Debug Dumps.
- `frame` is the current integer Frame Step. Use this when correlating Event Trace, Replay, State Snapshot, and Debug Dump data.
- `status` tells you whether time is advancing. Use `Pause` and `Step` when you need one-frame-at-a-time inspection.

## Selected Object

`selected Object ID=<id> speed=<current>/<max> pos=(<x>,<y>)`

`Object ID` is the stable identity for the currently inspected Simulation object. In the current skeleton this is the player Ship. The selected Object ID drives hitbox display, velocity vector display, State Snapshot diff focus, Event Trace filtering, and Debug Dump context.

Interpretation:

- `speed` near `0` means the Ship is stationary or inertia has settled.
- `speed` above `max` indicates a Simulation bug, because movement should clamp to max speed.
- `pos` is world-space position, not screen position. If screen position looks wrong but `pos` is plausible, investigate camera or Render Pass behavior.

## Ship Motion

`heading=<radians> velocity=(<x>,<y>) hitbox=(<half_width>,<half_height>)`

- `heading` is the Ship's facing direction in radians.
- `velocity` is world-space movement velocity.
- `hitbox` reports half-extents. The full hitbox size is twice these values.

Use this line to separate input, inertia, and rendering problems. If heading changes but velocity does not, inspect Control Intent and acceleration. If velocity changes but the Ship visual does not move, inspect Render Pipeline or camera.

## Camera

`camera target=(<x>,<y>) zoom=<zoom>`

The camera is outside Simulation. In the skeleton it follows the player Ship without smoothing.

Interpretation:

- If camera target matches Ship position, world-to-screen conversion should keep the Ship centered.
- If Simulation position changes but camera target does not, investigate camera view assembly.
- If zoom is unexpected, Render Passes may look correctly simulated but visually scaled wrong.

## Invariants

`invariants=<ok|failed> failures=<count>`

Invariants are rules that must remain true for valid Simulation state.

Interpretation:

- `ok` means no invariant failures were detected for the current view.
- `failed` means Simulation state is invalid or a test/dev guard found an impossible condition.
- `failures > 0` should usually pause investigation flow. Export a Debug Dump, then inspect the last Event Trace entries and State Snapshot diff.

## State Snapshot Diff

`snapshot selected_changed=<bool> pos=<bool> heading=<bool> velocity=<bool>`

This compares the selected object's previous and current State Snapshot.

Interpretation:

- `selected_changed=true` means you changed focus, so movement differences may reflect a different object rather than motion.
- `pos=true` means world position changed during the last inspected Frame Step.
- `heading=true` means orientation changed.
- `velocity=true` means inertia, acceleration, braking, or collision logic changed movement velocity.

When a Scenario expectation fails, this line tells you which state dimension moved first.

## Trace Filtering

`trace filter object=<id>(<enabled>) frame=<start>..<end>(<enabled>) kind=<kind>(<enabled>)`

Trace Filtering controls which Event Trace entries are shown in the filtered trace line.

Interpretation:

- Object filtering isolates events involving one Object ID.
- Frame filtering isolates a window of Frame Steps.
- Kind filtering isolates one Event Kind, currently useful for movement and invariant failures.
- A filter marked `false` is configured but inactive.

If the filtered trace count is unexpectedly zero, check whether the filter is too narrow before assuming no event was emitted.

## Filtered Trace

`trace tail filtered count=<count> last=<kind> frame=<frame> object=<id>`

This summarizes the current filtered Event Trace tail.

Interpretation:

- `count=0` means no current trace entry matches the active filters.
- `last` is the latest matching Event Kind.
- `frame` should line up with the header frame or a recent Frame Step.
- `object` should match the selected Object ID when object filtering is enabled.

Event Trace is the first place to answer "why did this happen?" State tells you what is true; Event Trace tells you what caused it.

## Frame Breakpoints

`breakpoint matched=<false>`

or:

`breakpoint matched reason=<reason> event=<kind> invariant_failures=<count>`

Frame Breakpoints pause the game when an Event Trace entry or invariant failure matches your condition.

Interpretation:

- `reason=Event_Kind` means a matching event appeared in the current step.
- `reason=Invariant_Failure` means invariant checks failed.
- When a breakpoint matches, inspect the filtered trace and State Snapshot diff before resuming.

## Performance Timing

`timing fps=<fps> frame=<ms>ms`

`timing sim=<us>us render=<us>us`

`pass <short>=<us>us ...`

`entities ships=<count> bullets=<count> gameplay=<count> trace=<count>`

Performance Timing is diagnostic context, not a benchmark.

Interpretation:

- `fps` and frame time describe the window frame.
- `sim` measures the Simulation step path.
- `render` measures total Render Pipeline work.
- `pass` timings come from the Render Pass Registry. A high pass time points to a rendering issue, not Simulation.
- `entities` explains load. If timings rise with entity counts, inspect spawning and cleanup logic.
- In `release`, timing can be minimized or unavailable by design.

## Render Pass Toggles

`passes 1:bg=<bool> 2:world=<bool> 3:debug=<bool> 4:inspector=<bool>`

Render Passes can be toggled to isolate visual problems:

- `bg`: background grid and reference marks.
- `world`: main Ship visual.
- `debug`: hitboxes and velocity vector.
- `inspector`: the overlay itself.

Use number keys `1` through `4` in `dev` to toggle the registered passes. If Simulation data is correct but the visual looks wrong, toggle passes until the incorrect layer is isolated.

## Panel Controls

The static overlay controls are registered as Debug Command targets:

- `Pause`: stop automatic advancement.
- `Resume`: continue automatic advancement.
- `Step`: advance one Frame Step and remain paused.
- `Dump`: request a Debug Dump export.
- `Hitbox`: toggle selected-object hitbox drawing.
- `Vector`: toggle selected-object velocity vector drawing.
- `Obj`: toggle Object ID Trace Filtering.
- `Frame`: toggle Frame Step range Trace Filtering.
- `Kind`: toggle Event Kind Trace Filtering for `Ship_Moved`.
- `Brk Move`: toggle breakpoint on `Ship_Moved`.
- `Brk Inv`: toggle breakpoint on invariant failure.

These controls do not mutate Simulation directly. They emit Debug Commands, which Replay can record.

## Scenario Browser

The Scenario Browser lists available Scenarios and exposes:

- `Run`: start the Scenario and let it advance normally.
- `Restart`: reset the Scenario and pause for inspection.

Use Scenario Browser when a headless Scenario test fails and you want to inspect the same setup visually.

## Text Command Console

The console accepts minimal text commands:

- `run player_moves_forward`
- `restart player_moves_forward`
- `select 1`
- `break event ship_moved`
- `break invariant`
- `dump`

Console feedback reports whether parsing succeeded. Invalid commands are readable no-ops and should not mutate state.

## Object Picking

Click outside the Inspector Overlay panel to select a visible Ship by Object ID. Picking uses the Render Debug View and current camera transform, so it is useful for investigating mismatches between world position, screen position, and selection.

If clicking a visible object does not select it:

- Confirm the click is outside the overlay panel.
- Confirm the `world` Render Pass shows the object where expected.
- Confirm camera target and zoom are plausible.
- Confirm hitbox data is not unexpectedly small.

## Debug Dump Export

Use `Dump` or `dump` when you need a portable artifact. The Debug Dump includes Build Mode, Scenario, seed, Frame Step, Replay stream, Event Trace tail, selected Object ID, State Snapshot diff, Frame Breakpoints, Render Pass toggles, camera, and Performance Timing.

Export after a breakpoint or invariant failure before changing filters or selection. That preserves the investigation state that led to the failure.
