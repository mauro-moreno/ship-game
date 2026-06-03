package game

import "core:strings"
import "core:testing"
import "core:os"

@(test)
test_debug_dump_text_includes_minimum_portable_investigation_context :: proc(t: ^testing.T) {
	ctx := debug_dump_test_context(.Manual_Export)
	text := debug_dump_to_text(ctx)

	testing.expect(t, strings.contains(text, DEBUG_DUMP_FORMAT_VERSION))
	testing.expect(t, strings.contains(text, "\"build_mode\":\"Dev\""))
	testing.expect(t, strings.contains(text, "\"scenario\":\"player_moves_forward\""))
	testing.expect(t, strings.contains(text, "\"seed\":1"))
	testing.expect(t, strings.contains(text, "\"frame\":1"))
	testing.expect(t, strings.contains(text, "\"replay_stream\""))
	testing.expect(t, strings.contains(text, REPLAY_FORMAT_VERSION))
	testing.expect(t, strings.contains(text, "\"event_trace_tail\""))
	testing.expect(t, strings.contains(text, "\"Ship_Moved\""))
	testing.expect(t, strings.contains(text, "\"selected_object_id\":1"))
	testing.expect(t, strings.contains(text, "\"state_snapshot_diff\""))
	testing.expect(t, strings.contains(text, "\"frame_breakpoints\""))
	testing.expect(t, strings.contains(text, "\"render_pass_toggles\""))
	testing.expect(t, strings.contains(text, "\"camera\""))
	testing.expect(t, strings.contains(text, "\"performance_timing\""))
	testing.expect(t, strings.contains(text, "\"simulation_step_us\":100"))
}

debug_dump_test_context :: proc(reason: Debug_Dump_Reason) -> Debug_Dump_Context {
	scenario := player_moves_forward_scenario()
	result := run_scenario_with_trace(scenario)
	view := simulation_view(result.final_state)
	pass_timings := initial_render_pass_timings()
	record_render_pass_timing(&pass_timings, .World, 240)
	performance_timing := performance_timing_view_for_frame(.Dev, view, result.trace.count, 100, 400, pass_timings, 60, 0.016)
	diff := diff_state_snapshots(
		capture_state_snapshot(scenario.initial_state, scenario.initial_state.ship.id),
		capture_state_snapshot(result.final_state, result.final_state.ship.id),
	)
	breakpoints := default_frame_breakpoints()
	toggle_frame_breakpoint_event_kind(&breakpoints, .Ship_Moved)
	overlay := inspector_overlay_view(
		.Dev,
		scenario,
		view,
		default_render_pass_toggles(),
		true,
		result.final_state.ship.id,
		default_ship_debug_visual_toggles(),
		diff,
		result.trace,
		trace_filter_for_object(result.final_state.ship.id),
		validate_simulation_invariants(result.final_state),
		breakpoints,
		frame_breakpoint_match(breakpoints, result.trace, validate_simulation_invariants(result.final_state)),
		performance_timing,
	)
	replay := replay_from_scenario(scenario)

	return debug_dump_context_from_overlay(reason, overlay, replay)
}

@(test)
test_automatic_debug_dump_policy_allows_dev_and_test_failures_but_not_release :: proc(t: ^testing.T) {
	testing.expect(t, automatic_debug_dump_enabled(.Dev, .Dev_Invariant_Failure))
	testing.expect(t, automatic_debug_dump_enabled(.Test, .Scenario_Test_Failure))
	testing.expect(t, !automatic_debug_dump_enabled(.Release, .Dev_Invariant_Failure))
	testing.expect(t, !automatic_debug_dump_enabled(.Release, .Scenario_Test_Failure))
}

@(test)
test_debug_dump_export_writes_versioned_text_file :: proc(t: ^testing.T) {
	ctx := debug_dump_test_context(.Manual_Export)

	result := write_debug_dump(ctx)

	testing.expect(t, result.ok)
	testing.expect(t, strings.contains(result.path, DEBUG_DUMP_OUTPUT_DIRECTORY))
	testing.expect(t, os.exists(result.path))

	data, read_ok := os.read_entire_file_from_filename(result.path, context.temp_allocator)
	testing.expect(t, read_ok)
	text := string(data)
	testing.expect(t, strings.contains(text, DEBUG_DUMP_FORMAT_VERSION))
	testing.expect(t, strings.contains(text, "\"reason\":\"Manual_Export\""))
}

@(test)
test_scenario_failure_debug_dump_writes_test_failure_context :: proc(t: ^testing.T) {
	scenario := player_moves_forward_scenario()
	run := run_scenario_with_trace(scenario)

	result := write_scenario_failure_debug_dump(scenario, run)

	testing.expect(t, result.ok)
	testing.expect(t, os.exists(result.path))

	data, read_ok := os.read_entire_file_from_filename(result.path, context.temp_allocator)
	testing.expect(t, read_ok)
	text := string(data)
	testing.expect(t, strings.contains(text, "\"reason\":\"Scenario_Test_Failure\""))
	testing.expect(t, strings.contains(text, "\"build_mode\":\"Test\""))
	testing.expect(t, strings.contains(text, "\"scenario\":\"player_moves_forward\""))
}
