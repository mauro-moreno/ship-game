package game

import "core:strings"
import "core:testing"

@(test)
test_debuggable_skeleton_acceptance_loop :: proc(t: ^testing.T) {
	browser := scenario_browser_view(PLAYER_MOVES_FORWARD_ID)
	testing.expect_value(t, browser.count, 1)
	testing.expect_value(t, browser.items[0].id, PLAYER_MOVES_FORWARD_ID)

	scenario, scenario_ok := scenario_by_id(browser.items[0].id)
	testing.expect(t, scenario_ok)
	testing.expect_value(t, scenario.id, PLAYER_MOVES_FORWARD_ID)

	run := run_scenario_with_trace(scenario, .Test)
	view := simulation_view(run.final_state)
	replay := replay_from_scenario(scenario)
	replayed_state := replay_simulation(replay, scenario.initial_state, .Test)

	testing.expect_value(t, replayed_state, run.final_state)
	testing.expect_value(t, view.frame, Frame_Step_Index(1))
	testing.expect(t, view.player_ship.position.x > 0)
	testing.expect_value(t, view.player_ship.heading, scenario.initial_heading)
	testing.expect(t, view.player_ship.velocity.x > 0)
	testing.expect(t, view.player_ship.hitbox.half_width > 0)
	testing.expect(t, view.player_ship.hitbox.half_height > 0)

	before := capture_state_snapshot(scenario.initial_state, Object_ID(1))
	after := capture_state_snapshot(run.final_state, Object_ID(1))
	diff := diff_state_snapshots(before, after)
	testing.expect(t, diff.position_changed)
	testing.expect(t, diff.velocity_changed)

	filter := trace_filter_for_object_kind_and_frame_range(Object_ID(1), .Ship_Moved, Frame_Step_Index(1), Frame_Step_Index(1))
	filtered := trace_filter(run.trace, filter)
	testing.expect_value(t, filtered.count, 1)
	testing.expect_value(t, filtered.entries[0].kind, Event_Kind.Ship_Moved)
	testing.expect_value(t, filtered.entries[0].object_id, Object_ID(1))

	event_breakpoints := default_frame_breakpoints()
	toggle_frame_breakpoint_event_kind(&event_breakpoints, .Ship_Moved)
	event_match := frame_breakpoint_match(event_breakpoints, run.trace, Invariant_Report{ok = true})
	testing.expect(t, event_match.matched)
	testing.expect_value(t, event_match.reason, Frame_Breakpoint_Reason.Event_Kind)

	invariant_breakpoints := default_frame_breakpoints()
	toggle_frame_breakpoint_invariant_failure(&invariant_breakpoints)
	invariant_match := frame_breakpoint_match(invariant_breakpoints, run.trace, Invariant_Report{ok = false, failure_count = 1})
	testing.expect(t, invariant_match.matched)
	testing.expect_value(t, invariant_match.reason, Frame_Breakpoint_Reason.Invariant_Failure)

	expect_only_render_pass_enabled(t, .Background)
	expect_only_render_pass_enabled(t, .World)
	expect_only_render_pass_enabled(t, .Debug)
	expect_only_render_pass_enabled(t, .Inspector)

	pass_timings := initial_render_pass_timings()
	record_render_pass_timing(&pass_timings, .Background, 10)
	record_render_pass_timing(&pass_timings, .World, 20)
	record_render_pass_timing(&pass_timings, .Debug, 30)
	record_render_pass_timing(&pass_timings, .Inspector, 40)
	timing := performance_timing_view_for_frame(.Dev, view, run.trace.count, 100, 200, pass_timings, 60, 0.016)
	testing.expect(t, timing.available)
	testing.expect_value(t, timing.entity_counts.ships, 1)
	testing.expect_value(t, timing.render_pass_count, RENDER_PASS_TIMING_COUNT)

	overlay := inspector_overlay_view(Inspector_Overlay_View_Input {
		build_mode = .Dev,
		scenario = scenario,
		simulation = run.final_state,
		render_pass_toggles = default_render_pass_toggles(),
		paused = true,
		selected_object_id = Object_ID(1),
		ship_debug_visuals = default_ship_debug_visual_toggles(),
		snapshot_diff = diff,
		trace_tail = run.trace,
		trace_filter = filter,
		invariant_report = validate_simulation_invariants(run.final_state),
		frame_breakpoints = event_breakpoints,
		breakpoint_match = event_match,
		performance_timing = timing,
	})
	testing.expect(t, overlay.paused)
	testing.expect_value(t, overlay.selected_object_id, Object_ID(1))
	testing.expect_value(t, overlay.render_debug.player_ship.position, view.player_ship.position)
	testing.expect_value(t, overlay.render_debug.player_ship.heading, view.player_ship.heading)
	testing.expect_value(t, overlay.render_debug.player_ship.velocity, view.player_ship.velocity)
	testing.expect_value(t, overlay.render_debug.player_ship.hitbox, view.player_ship.hitbox)
	testing.expect_value(t, overlay.filtered_trace.count, 1)
	testing.expect_value(t, overlay.performance_timing.simulation_step_us, u64(100))

	manual_dump := debug_dump_to_text(debug_dump_context_from_overlay(.Manual_Export, overlay, replay))
	testing.expect(t, strings.contains(manual_dump, DEBUG_DUMP_FORMAT_VERSION))
	testing.expect(t, strings.contains(manual_dump, "\"reason\":\"Manual_Export\""))
	testing.expect(t, strings.contains(manual_dump, "\"replay_stream\""))
	testing.expect(t, strings.contains(manual_dump, "\"performance_timing\""))

	failure_dump := debug_dump_to_text(debug_dump_context_for_scenario_result(.Test, .Scenario_Test_Failure, scenario, run))
	testing.expect(t, strings.contains(failure_dump, "\"reason\":\"Scenario_Test_Failure\""))
	testing.expect(t, strings.contains(failure_dump, "\"build_mode\":\"Test\""))

	release_step := step_simulation_with_trace(scenario.initial_state, scenario_control_intent(scenario, 0), .Release)
	testing.expect_value(t, release_step.trace.count, 2)
	testing.expect(t, !automatic_debug_dump_enabled(.Release, .Scenario_Test_Failure))
}

expect_only_render_pass_enabled :: proc(t: ^testing.T, pass: Render_Pass) {
	toggles := Render_Pass_Toggles{}
	set_render_pass_enabled(&toggles, pass, true)

	for i in 0..<render_pass_count() {
		registered_pass, ok := render_pass_at(i)
		testing.expect(t, ok)
		testing.expect_value(t, render_pass_enabled(toggles, registered_pass), pass == registered_pass)
	}
}
