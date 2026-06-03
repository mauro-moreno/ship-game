package game

import "core:strconv"
import "core:strings"

MAX_SCENARIO_BROWSER_ITEMS :: 4

Debug_Artifacts :: struct {}

Debug_Command_Kind :: enum {
	None,
	Pause,
	Resume,
	Step_Frame,
	Run_Scenario,
	Restart_Scenario,
	Select_Object,
	Toggle_Selected_Hitbox,
	Toggle_Selected_Velocity_Vector,
	Toggle_Trace_Object_Filter,
	Toggle_Trace_Frame_Range_Filter,
	Toggle_Trace_Event_Kind_Filter,
	Toggle_Break_On_Event_Kind,
	Toggle_Break_On_Invariant_Failure,
	Export_Debug_Dump,
}

Debug_Command :: struct {
	kind:        Debug_Command_Kind,
	scenario_id: Scenario_Id,
	object_id:   Object_ID,
	event_kind:  Event_Kind,
}

Debug_Text_Command_Result :: struct {
	ok:       bool,
	command:  Debug_Command,
	feedback: string,
}

Frame_Breakpoint_Reason :: enum {
	None,
	Event_Kind,
	Invariant_Failure,
}

Frame_Breakpoints :: struct {
	pause_on_event_kind:        bool,
	event_kind:                 Event_Kind,
	pause_on_invariant_failure: bool,
}

Frame_Breakpoint_Match :: struct {
	matched:          bool,
	reason:           Frame_Breakpoint_Reason,
	event:            Event_Trace_Entry,
	invariant_report: Invariant_Report,
}

Scenario_Browser_Item :: struct {
	id:       Scenario_Id,
	seed:     Scenario_Seed,
	selected: bool,
}

Scenario_Browser_View :: struct {
	count: int,
	items: [MAX_SCENARIO_BROWSER_ITEMS]Scenario_Browser_Item,
}

Inspector_Overlay_View :: struct {
	build_mode:    Build_Mode,
	paused:        bool,
	scenario_id:   Scenario_Id,
	scenario_seed: Scenario_Seed,
	frame:         Frame_Step_Index,
	selected_object_id: Object_ID,
	render_debug:  Render_Debug_View,
	scenarios:     Scenario_Browser_View,
	snapshot_diff: State_Snapshot_Diff,
	trace_tail:    Event_Trace,
	selected_trace: Event_Trace,
	trace_filter:  Trace_Filter,
	filtered_trace: Event_Trace,
	invariant_report: Invariant_Report,
	frame_breakpoints: Frame_Breakpoints,
	breakpoint_match:  Frame_Breakpoint_Match,
	performance_timing: Performance_Timing_View,
}

NO_DEBUG_COMMAND :: Debug_Command{kind = .None}

debug_pause_command :: proc() -> Debug_Command {
	return Debug_Command{kind = .Pause}
}

debug_resume_command :: proc() -> Debug_Command {
	return Debug_Command{kind = .Resume}
}

debug_step_frame_command :: proc() -> Debug_Command {
	return Debug_Command{kind = .Step_Frame}
}

debug_run_scenario_command :: proc(id: Scenario_Id) -> Debug_Command {
	return Debug_Command{kind = .Run_Scenario, scenario_id = id}
}

debug_restart_scenario_command :: proc(id: Scenario_Id) -> Debug_Command {
	return Debug_Command{kind = .Restart_Scenario, scenario_id = id}
}

debug_select_object_command :: proc(id: Object_ID) -> Debug_Command {
	return Debug_Command{kind = .Select_Object, object_id = id}
}

debug_toggle_selected_hitbox_command :: proc() -> Debug_Command {
	return Debug_Command{kind = .Toggle_Selected_Hitbox}
}

debug_toggle_selected_velocity_vector_command :: proc() -> Debug_Command {
	return Debug_Command{kind = .Toggle_Selected_Velocity_Vector}
}

debug_toggle_trace_object_filter_command :: proc() -> Debug_Command {
	return Debug_Command{kind = .Toggle_Trace_Object_Filter}
}

debug_toggle_trace_frame_range_filter_command :: proc() -> Debug_Command {
	return Debug_Command{kind = .Toggle_Trace_Frame_Range_Filter}
}

debug_toggle_trace_event_kind_filter_command :: proc(kind: Event_Kind) -> Debug_Command {
	return Debug_Command{kind = .Toggle_Trace_Event_Kind_Filter, event_kind = kind}
}

debug_toggle_break_on_event_kind_command :: proc(kind: Event_Kind) -> Debug_Command {
	return Debug_Command{kind = .Toggle_Break_On_Event_Kind, event_kind = kind}
}

debug_toggle_break_on_invariant_failure_command :: proc() -> Debug_Command {
	return Debug_Command{kind = .Toggle_Break_On_Invariant_Failure}
}

debug_export_dump_command :: proc() -> Debug_Command {
	return Debug_Command{kind = .Export_Debug_Dump}
}

parse_debug_text_command :: proc(input: string) -> Debug_Text_Command_Result {
	trimmed := strings.trim_space(input)
	if len(trimmed) == 0 {
		return debug_text_error("Empty command")
	}

	parts := strings.fields(trimmed)
	defer delete(parts)

	if len(parts) == 0 {
		return debug_text_error("Empty command")
	}

	verb := parts[0]

	if strings.equal_fold(verb, "run") || strings.equal_fold(verb, "scenario") {
		if len(parts) != 2 {
			return debug_text_error("Usage: run player_moves_forward")
		}
		if scenario_id, ok := scenario_id_from_text(parts[1]); ok {
			return debug_text_ok(debug_run_scenario_command(scenario_id), "Running scenario")
		}
		return debug_text_error("Unknown scenario")
	}

	if strings.equal_fold(verb, "restart") {
		if len(parts) != 2 {
			return debug_text_error("Usage: restart player_moves_forward")
		}
		if scenario_id, ok := scenario_id_from_text(parts[1]); ok {
			return debug_text_ok(debug_restart_scenario_command(scenario_id), "Restarting scenario")
		}
		return debug_text_error("Unknown scenario")
	}

	if strings.equal_fold(verb, "select") {
		if len(parts) != 2 {
			return debug_text_error("Usage: select <Object ID>")
		}
		object_id, ok := strconv.parse_uint(parts[1])
		if !ok || object_id == 0 {
			return debug_text_error("Invalid Object ID")
		}
		return debug_text_ok(debug_select_object_command(Object_ID(object_id)), "Selected Object ID")
	}

	if strings.equal_fold(verb, "break") {
		if len(parts) == 2 && strings.equal_fold(parts[1], "invariant") {
			return debug_text_ok(debug_toggle_break_on_invariant_failure_command(), "Toggled invariant breakpoint")
		}
		if len(parts) == 3 && strings.equal_fold(parts[1], "event") {
			if kind, ok := event_kind_from_text(parts[2]); ok {
				return debug_text_ok(debug_toggle_break_on_event_kind_command(kind), "Toggled event breakpoint")
			}
			return debug_text_error("Unknown event kind")
		}
		return debug_text_error("Usage: break event ship_moved | break invariant")
	}

	if strings.equal_fold(verb, "dump") {
		if len(parts) != 1 {
			return debug_text_error("Usage: dump")
		}
		return debug_text_ok(debug_export_dump_command(), "Debug Dump export requested")
	}

	return debug_text_error("Unknown command")
}

debug_text_ok :: proc(command: Debug_Command, feedback: string) -> Debug_Text_Command_Result {
	return Debug_Text_Command_Result {
		ok = true,
		command = command,
		feedback = feedback,
	}
}

debug_text_error :: proc(feedback: string) -> Debug_Text_Command_Result {
	return Debug_Text_Command_Result {
		command = NO_DEBUG_COMMAND,
		feedback = feedback,
	}
}

scenario_id_from_text :: proc(text: string) -> (Scenario_Id, bool) {
	if strings.equal_fold(text, string(PLAYER_MOVES_FORWARD_ID)) {
		return PLAYER_MOVES_FORWARD_ID, true
	}

	return "", false
}

event_kind_from_text :: proc(text: string) -> (Event_Kind, bool) {
	if strings.equal_fold(text, "scenario_started") {
		return .Scenario_Started, true
	}
	if strings.equal_fold(text, "control_intent_applied") {
		return .Control_Intent_Applied, true
	}
	if strings.equal_fold(text, "ship_moved") {
		return .Ship_Moved, true
	}
	if strings.equal_fold(text, "invariant_failed") {
		return .Invariant_Failed, true
	}

	return .Scenario_Started, false
}

scenario_browser_view :: proc(active_id: Scenario_Id) -> Scenario_Browser_View {
	view: Scenario_Browser_View
	scenario := player_moves_forward_scenario()

	view.items[0] = Scenario_Browser_Item {
		id = scenario.id,
		seed = scenario.seed,
		selected = scenario.id == active_id,
	}
	view.count = 1

	return view
}

scenario_by_id :: proc(id: Scenario_Id) -> (Scenario, bool) {
	if id == PLAYER_MOVES_FORWARD_ID {
		return player_moves_forward_scenario(), true
	}

	return {}, false
}

inspector_overlay_view :: proc(
	mode: Build_Mode,
	scenario: Scenario,
	view: Simulation_View,
	toggles: Render_Pass_Toggles,
	paused: bool,
	selected_object_id: Object_ID,
	ship_debug_visuals: Ship_Debug_Visual_Toggles,
	snapshot_diff: State_Snapshot_Diff,
	trace: Event_Trace,
	filter: Trace_Filter,
	invariant_report: Invariant_Report,
	breakpoints: Frame_Breakpoints,
	breakpoint_match: Frame_Breakpoint_Match,
	performance_timing: Performance_Timing_View,
) -> Inspector_Overlay_View {
	return Inspector_Overlay_View {
		build_mode = mode,
		paused = paused,
		scenario_id = scenario.id,
		scenario_seed = scenario.seed,
		frame = view.frame,
		selected_object_id = selected_object_id,
		render_debug = render_debug_view_with_selection(view, toggles, selected_object_id, ship_debug_visuals),
		scenarios = scenario_browser_view(scenario.id),
		snapshot_diff = snapshot_diff,
		trace_tail = trace,
		selected_trace = trace_filter_by_object(trace, selected_object_id),
		trace_filter = filter,
		filtered_trace = trace_filter(trace, filter),
		invariant_report = invariant_report,
		frame_breakpoints = breakpoints,
		breakpoint_match = breakpoint_match,
		performance_timing = performance_timing,
	}
}

default_frame_breakpoints :: proc() -> Frame_Breakpoints {
	return Frame_Breakpoints{event_kind = .Ship_Moved}
}

toggle_frame_breakpoint_event_kind :: proc(breakpoints: ^Frame_Breakpoints, kind: Event_Kind) {
	if breakpoints.pause_on_event_kind && breakpoints.event_kind == kind {
		breakpoints.pause_on_event_kind = false
		return
	}

	breakpoints.pause_on_event_kind = true
	breakpoints.event_kind = kind
}

toggle_frame_breakpoint_invariant_failure :: proc(breakpoints: ^Frame_Breakpoints) {
	breakpoints.pause_on_invariant_failure = !breakpoints.pause_on_invariant_failure
}

frame_breakpoint_match :: proc(breakpoints: Frame_Breakpoints, trace: Event_Trace, invariant_report: Invariant_Report) -> Frame_Breakpoint_Match {
	if breakpoints.pause_on_invariant_failure && !invariant_report.ok {
		return Frame_Breakpoint_Match {
			matched = true,
			reason = .Invariant_Failure,
			invariant_report = invariant_report,
		}
	}

	if breakpoints.pause_on_event_kind {
		for i in 0..<trace.count {
			entry := trace.entries[i]
			if entry.kind == breakpoints.event_kind {
				return Frame_Breakpoint_Match {
					matched = true,
					reason = .Event_Kind,
					event = entry,
					invariant_report = invariant_report,
				}
			}
		}
	}

	return Frame_Breakpoint_Match {
		invariant_report = invariant_report,
	}
}

State_Snapshot :: struct {
	selected_object_id: Object_ID,
	view:               Simulation_View,
}

State_Snapshot_Diff :: struct {
	selected_object_id: Object_ID,
	selected_object_changed: bool,
	position_changed:   bool,
	heading_changed:    bool,
	velocity_changed:   bool,
	before_position:    Vec2,
	after_position:     Vec2,
	before_heading:     f32,
	after_heading:      f32,
	before_velocity:    Vec2,
	after_velocity:     Vec2,
}

capture_state_snapshot :: proc(state: Simulation_State, selected_object_id: Object_ID) -> State_Snapshot {
	return State_Snapshot {
		selected_object_id = selected_object_id,
		view = simulation_view(state),
	}
}

diff_state_snapshots :: proc(before, after: State_Snapshot) -> State_Snapshot_Diff {
	before_ship := before.view.player_ship
	after_ship := after.view.player_ship

	return State_Snapshot_Diff {
		selected_object_id = after.selected_object_id,
		selected_object_changed = before.selected_object_id != after.selected_object_id,
		position_changed = before_ship.position != after_ship.position,
		heading_changed = before_ship.heading != after_ship.heading,
		velocity_changed = before_ship.velocity != after_ship.velocity,
		before_position = before_ship.position,
		after_position = after_ship.position,
		before_heading = before_ship.heading,
		after_heading = after_ship.heading,
		before_velocity = before_ship.velocity,
		after_velocity = after_ship.velocity,
	}
}
