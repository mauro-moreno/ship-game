package game

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

write_scenario_failure_debug_dump :: proc(scenario: Scenario, result: Simulation_Run_Result) -> Debug_Dump_Write_Result {
	if !automatic_debug_dump_enabled(.Test, .Scenario_Test_Failure) {
		return {}
	}

	ctx := debug_dump_context_for_scenario_result(.Test, .Scenario_Test_Failure, scenario, result)
	return write_debug_dump(ctx)
}

debug_dump_context_for_scenario_result :: proc(mode: Build_Mode, reason: Debug_Dump_Reason, scenario: Scenario, result: Simulation_Run_Result) -> Debug_Dump_Context {
	selected_object_id := result.final_state.ship.id
	diff := diff_state_snapshots(
		capture_state_snapshot(scenario.initial_state, selected_object_id),
		capture_state_snapshot(result.final_state, selected_object_id),
	)
	invariant_report := validate_simulation_invariants(result.final_state)
	breakpoints := default_frame_breakpoints()
	breakpoint_match := frame_breakpoint_match(breakpoints, result.trace, invariant_report)
	view := simulation_view(result.final_state)
	timing := performance_timing_view_for_frame(mode, view, result.trace.count, 0, 0, initial_render_pass_timings(), 0, 0)
	overlay := inspector_overlay_view(Inspector_Overlay_View_Input {
		build_mode = mode,
		scenario = scenario,
		simulation = result.final_state,
		render_pass_toggles = default_render_pass_toggles(),
		paused = true,
		selected_object_id = selected_object_id,
		ship_debug_visuals = default_ship_debug_visual_toggles(),
		snapshot_diff = diff,
		trace_tail = result.trace,
		trace_filter = trace_filter_for_object(selected_object_id),
		invariant_report = invariant_report,
		frame_breakpoints = breakpoints,
		breakpoint_match = breakpoint_match,
		performance_timing = timing,
	})

	return debug_dump_context_from_overlay(reason, overlay, replay_from_scenario(scenario))
}
