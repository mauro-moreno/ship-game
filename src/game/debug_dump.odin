package game

import "core:fmt"
import "core:os"
import "core:strings"

DEBUG_DUMP_FORMAT_VERSION :: "ship-debug-dump-v1"
DEBUG_DUMP_OUTPUT_DIRECTORY :: "build/debug-dumps"

Debug_Dump_Reason :: enum {
	Manual_Export,
	Scenario_Test_Failure,
	Dev_Invariant_Failure,
}

Debug_Dump_Context :: struct {
	reason:             Debug_Dump_Reason,
	build_mode:         Build_Mode,
	scenario_id:        Scenario_Id,
	seed:               Scenario_Seed,
	frame:              Frame_Step_Index,
	replay:             Replay_Stream,
	trace_tail:         Event_Trace,
	selected_object_id: Object_ID,
	snapshot_diff:      State_Snapshot_Diff,
	frame_breakpoints:  Frame_Breakpoints,
	render_pass_toggles: Render_Pass_Toggles,
	camera:             Camera_State,
	performance_timing: Performance_Timing_View,
}

Debug_Dump_Write_Result :: struct {
	ok:   bool,
	path: string,
}

debug_dump_context_from_overlay :: proc(reason: Debug_Dump_Reason, overlay: Inspector_Overlay_View, replay: Replay_Stream) -> Debug_Dump_Context {
	return Debug_Dump_Context {
		reason = reason,
		build_mode = overlay.build_mode,
		scenario_id = overlay.scenario_id,
		seed = overlay.scenario_seed,
		frame = overlay.frame,
		replay = replay,
		trace_tail = overlay.trace_tail,
		selected_object_id = overlay.selected_object_id,
		snapshot_diff = overlay.snapshot_diff,
		frame_breakpoints = overlay.frame_breakpoints,
		render_pass_toggles = overlay.render_debug.pass_toggles,
		camera = overlay.render_debug.camera,
		performance_timing = overlay.performance_timing,
	}
}

automatic_debug_dump_enabled :: proc(mode: Build_Mode, reason: Debug_Dump_Reason) -> bool {
	switch mode {
	case .Dev:
		return reason == .Dev_Invariant_Failure || reason == .Scenario_Test_Failure
	case .Test:
		return reason == .Scenario_Test_Failure || reason == .Dev_Invariant_Failure
	case .Release:
		return false
	}

	return false
}

write_debug_dump :: proc(ctx: Debug_Dump_Context) -> Debug_Dump_Write_Result {
	file_name := debug_dump_file_name(ctx)
	path := fmt.tprintf("%s/%s", DEBUG_DUMP_OUTPUT_DIRECTORY, file_name)
	if !ensure_debug_dump_output_directory() {
		return Debug_Dump_Write_Result{path = path}
	}

	text := debug_dump_to_text(ctx)
	ok := os.write_entire_file(path, transmute([]byte)text)
	return Debug_Dump_Write_Result {
		ok = ok,
		path = path,
	}
}

debug_dump_file_name :: proc(ctx: Debug_Dump_Context) -> string {
	return fmt.tprintf(
		"ship-debug-dump-%s-frame-%v-%v.txt",
		string(ctx.scenario_id),
		u64(ctx.frame),
		ctx.reason,
	)
}

ensure_debug_dump_output_directory :: proc() -> bool {
	if !os.exists("build") {
		if os.make_directory("build") != nil {
			return false
		}
	}

	if !os.exists(DEBUG_DUMP_OUTPUT_DIRECTORY) {
		if os.make_directory(DEBUG_DUMP_OUTPUT_DIRECTORY) != nil {
			return false
		}
	}

	return true
}

write_scenario_failure_debug_dump :: proc(scenario: Scenario, result: Scenario_Run_Result) -> Debug_Dump_Write_Result {
	if !automatic_debug_dump_enabled(.Test, .Scenario_Test_Failure) {
		return {}
	}

	ctx := debug_dump_context_for_scenario_result(.Test, .Scenario_Test_Failure, scenario, result)
	return write_debug_dump(ctx)
}

debug_dump_context_for_scenario_result :: proc(mode: Build_Mode, reason: Debug_Dump_Reason, scenario: Scenario, result: Scenario_Run_Result) -> Debug_Dump_Context {
	view := simulation_view(result.final_state)
	selected_object_id := result.final_state.ship.id
	diff := diff_state_snapshots(
		capture_state_snapshot(scenario.initial_state, selected_object_id),
		capture_state_snapshot(result.final_state, selected_object_id),
	)
	invariant_report := validate_simulation_invariants(result.final_state)
	breakpoints := default_frame_breakpoints()
	breakpoint_match := frame_breakpoint_match(breakpoints, result.trace, invariant_report)
	timing := performance_timing_view_for_frame(mode, view, result.trace.count, 0, 0, initial_render_pass_timings(), 0, 0)
	overlay := inspector_overlay_view(
		mode,
		scenario,
		view,
		default_render_pass_toggles(),
		true,
		selected_object_id,
		default_ship_debug_visual_toggles(),
		diff,
		result.trace,
		trace_filter_for_object(selected_object_id),
		invariant_report,
		breakpoints,
		breakpoint_match,
		timing,
	)

	return debug_dump_context_from_overlay(reason, overlay, replay_from_scenario(scenario))
}

debug_dump_to_text :: proc(ctx: Debug_Dump_Context) -> string {
	builder := strings.builder_make(context.temp_allocator)

	fmt.sbprintf(
		&builder,
		"\"version\":\"%s\",\"reason\":\"%v\",\"build_mode\":\"%v\",\"scenario\":\"%s\",\"seed\":%v,\"frame\":%v",
		DEBUG_DUMP_FORMAT_VERSION,
		ctx.reason,
		ctx.build_mode,
		string(ctx.scenario_id),
		u64(ctx.seed),
		u64(ctx.frame),
	)

	fmt.sbprintf(
		&builder,
		"\n\"selected_object_id\":%v",
		u32(ctx.selected_object_id),
	)

	diff := ctx.snapshot_diff
	fmt.sbprintf(
		&builder,
		"\n\"state_snapshot_diff\",\"selected_object_id\":%v,\"selected_object_changed\":%v,\"position_changed\":%v,\"heading_changed\":%v,\"velocity_changed\":%v,\"before_position_x\":%v,\"before_position_y\":%v,\"after_position_x\":%v,\"after_position_y\":%v,\"before_heading\":%v,\"after_heading\":%v,\"before_velocity_x\":%v,\"before_velocity_y\":%v,\"after_velocity_x\":%v,\"after_velocity_y\":%v",
		u32(diff.selected_object_id),
		diff.selected_object_changed,
		diff.position_changed,
		diff.heading_changed,
		diff.velocity_changed,
		diff.before_position.x,
		diff.before_position.y,
		diff.after_position.x,
		diff.after_position.y,
		diff.before_heading,
		diff.after_heading,
		diff.before_velocity.x,
		diff.before_velocity.y,
		diff.after_velocity.x,
		diff.after_velocity.y,
	)

	breakpoints := ctx.frame_breakpoints
	fmt.sbprintf(
		&builder,
		"\n\"frame_breakpoints\",\"pause_on_event_kind\":%v,\"event_kind\":\"%v\",\"pause_on_invariant_failure\":%v",
		breakpoints.pause_on_event_kind,
		breakpoints.event_kind,
		breakpoints.pause_on_invariant_failure,
	)

	toggles := ctx.render_pass_toggles
	fmt.sbprintf(
		&builder,
		"\n\"render_pass_toggles\",\"background\":%v,\"world\":%v,\"debug\":%v,\"inspector\":%v",
		toggles.background,
		toggles.world,
		toggles.debug,
		toggles.inspector,
	)

	camera := ctx.camera
	fmt.sbprintf(
		&builder,
		"\n\"camera\",\"target_x\":%v,\"target_y\":%v,\"zoom\":%v",
		camera.target.x,
		camera.target.y,
		camera.zoom,
	)

	timing := ctx.performance_timing
	entities := timing.entity_counts
	fmt.sbprintf(
		&builder,
		"\n\"performance_timing\",\"available\":%v,\"simulation_step_us\":%v,\"render_pipeline_us\":%v,\"fps\":%v,\"frame_time_ms\":%v,\"ships\":%v,\"bullets\":%v,\"gameplay_objects\":%v,\"trace_entries\":%v,\"background_us\":%v,\"world_us\":%v,\"debug_us\":%v,\"inspector_us\":%v",
		timing.available,
		timing.simulation_step_us,
		timing.render_pipeline_us,
		timing.fps,
		timing.frame_time_ms,
		entities.ships,
		entities.bullets,
		entities.gameplay_objects,
		entities.trace_entries,
		debug_dump_render_pass_us(timing, .Background),
		debug_dump_render_pass_us(timing, .World),
		debug_dump_render_pass_us(timing, .Debug),
		debug_dump_render_pass_us(timing, .Inspector),
	)

	fmt.sbprintf(&builder, "\n\"replay_stream\":true")
	fmt.sbprintf(&builder, "\n%s", replay_to_text(ctx.replay))
	fmt.sbprintf(&builder, "\n\"event_trace_tail\",\"count\":%v", ctx.trace_tail.count)

	for i in 0..<ctx.trace_tail.count {
		entry := ctx.trace_tail.entries[i]
		fmt.sbprintf(
			&builder,
			"\n\"event_trace_tail_entry\",\"kind\":\"%v\",\"frame\":%v,\"object_id\":%v,\"scenario\":\"%s\",\"forward_thrust\":%v,\"backward_thrust\":%v,\"turn_left\":%v,\"turn_right\":%v",
			entry.kind,
			u64(entry.frame),
			u32(entry.object_id),
			string(entry.scenario_id),
			entry.intent.forward_thrust,
			entry.intent.backward_thrust,
			entry.intent.turn_left,
			entry.intent.turn_right,
		)
	}

	return strings.to_string(builder)
}

debug_dump_render_pass_us :: proc(timing: Performance_Timing_View, pass: Render_Pass) -> u64 {
	for i in 0..<timing.render_pass_count {
		if timing.render_passes[i].pass == pass {
			return timing.render_passes[i].elapsed_us
		}
	}

	return 0
}
