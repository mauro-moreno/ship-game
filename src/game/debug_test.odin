package game

import "core:strings"
import "core:testing"

@(test)
test_state_snapshot_diff_reports_movement_changes :: proc(t: ^testing.T) {
	before_state := initial_simulation_state()
	after_state := step_simulation(before_state, Control_Intent{forward_thrust = true})

	before := capture_state_snapshot(before_state, Object_ID(1))
	after := capture_state_snapshot(after_state, Object_ID(1))
	diff := diff_state_snapshots(before, after)

	testing.expect_value(t, diff.selected_object_id, Object_ID(1))
	testing.expect(t, diff.position_changed)
	testing.expect(t, diff.velocity_changed)
	testing.expect(t, !diff.heading_changed)
	testing.expect(t, !diff.selected_object_changed)
	testing.expect_value(t, diff.before_position, Vec2{})
	testing.expect(t, diff.after_position.x > diff.before_position.x)
	testing.expect_value(t, diff.before_heading, diff.after_heading)

	changed_selection := diff_state_snapshots(before, capture_state_snapshot(after_state, Object_ID(2)))
	testing.expect(t, changed_selection.selected_object_changed)
}

@(test)
test_debug_commands_are_explicit_simulation_mutation_requests :: proc(t: ^testing.T) {
	pause := debug_pause_command()
	resume := debug_resume_command()
	step := debug_step_frame_command()
	run := debug_run_scenario_command(PLAYER_MOVES_FORWARD_ID)
	restart := debug_restart_scenario_command(PLAYER_MOVES_FORWARD_ID)
	select_object := debug_select_object_command(Object_ID(1))
	toggle_hitbox := debug_toggle_selected_hitbox_command()
	toggle_velocity := debug_toggle_selected_velocity_vector_command()
	toggle_trace_object := debug_toggle_trace_object_filter_command()
	toggle_trace_frame := debug_toggle_trace_frame_range_filter_command()
	toggle_trace_kind := debug_toggle_trace_event_kind_filter_command(.Ship_Moved)
	toggle_break_event := debug_toggle_break_on_event_kind_command(.Ship_Moved)
	toggle_break_invariant := debug_toggle_break_on_invariant_failure_command()
	export_dump := debug_export_dump_command()

	testing.expect_value(t, pause.kind, Debug_Command_Kind.Pause)
	testing.expect_value(t, resume.kind, Debug_Command_Kind.Resume)
	testing.expect_value(t, step.kind, Debug_Command_Kind.Step_Frame)
	testing.expect_value(t, run.kind, Debug_Command_Kind.Run_Scenario)
	testing.expect_value(t, run.scenario_id, PLAYER_MOVES_FORWARD_ID)
	testing.expect_value(t, restart.kind, Debug_Command_Kind.Restart_Scenario)
	testing.expect_value(t, restart.scenario_id, PLAYER_MOVES_FORWARD_ID)
	testing.expect_value(t, select_object.kind, Debug_Command_Kind.Select_Object)
	testing.expect_value(t, select_object.object_id, Object_ID(1))
	testing.expect_value(t, toggle_hitbox.kind, Debug_Command_Kind.Toggle_Selected_Hitbox)
	testing.expect_value(t, toggle_velocity.kind, Debug_Command_Kind.Toggle_Selected_Velocity_Vector)
	testing.expect_value(t, toggle_trace_object.kind, Debug_Command_Kind.Toggle_Trace_Object_Filter)
	testing.expect_value(t, toggle_trace_frame.kind, Debug_Command_Kind.Toggle_Trace_Frame_Range_Filter)
	testing.expect_value(t, toggle_trace_kind.kind, Debug_Command_Kind.Toggle_Trace_Event_Kind_Filter)
	testing.expect_value(t, toggle_trace_kind.event_kind, Event_Kind.Ship_Moved)
	testing.expect_value(t, toggle_break_event.kind, Debug_Command_Kind.Toggle_Break_On_Event_Kind)
	testing.expect_value(t, toggle_break_event.event_kind, Event_Kind.Ship_Moved)
	testing.expect_value(t, toggle_break_invariant.kind, Debug_Command_Kind.Toggle_Break_On_Invariant_Failure)
	testing.expect_value(t, export_dump.kind, Debug_Command_Kind.Export_Debug_Dump)
	testing.expect_value(t, NO_DEBUG_COMMAND.kind, Debug_Command_Kind.None)
}

@(test)
test_scenario_browser_lists_player_moves_forward :: proc(t: ^testing.T) {
	browser := scenario_browser_view(PLAYER_MOVES_FORWARD_ID)

	testing.expect_value(t, browser.count, 1)
	testing.expect_value(t, browser.items[0].id, PLAYER_MOVES_FORWARD_ID)
	testing.expect_value(t, browser.items[0].seed, PLAYER_MOVES_FORWARD_SEED)
	testing.expect(t, browser.items[0].selected)

	scenario, ok := scenario_by_id(PLAYER_MOVES_FORWARD_ID)
	testing.expect(t, ok)
	testing.expect_value(t, scenario.id, PLAYER_MOVES_FORWARD_ID)
}

@(test)
test_inspector_overlay_view_uses_read_only_simulation_view :: proc(t: ^testing.T) {
	scenario := player_moves_forward_scenario()
	state := scenario.initial_state
	state.ship.position = Vec2{x = 5, y = 2}
	sim_view := simulation_view(state)
	toggles := default_render_pass_toggles()
	visuals := default_ship_debug_visual_toggles()
	before := capture_state_snapshot(scenario.initial_state, Object_ID(1))
	after := capture_state_snapshot(state, Object_ID(1))
	diff := diff_state_snapshots(before, after)
	trace := run_scenario_with_trace(scenario).trace
	trace_filter := trace_filter_for_object_kind_and_frame_range(Object_ID(1), .Ship_Moved, 0, 1)
	invariant_report := validate_simulation_invariants(state)
	breakpoints := default_frame_breakpoints()
	breakpoint_match := frame_breakpoint_match(breakpoints, trace, invariant_report)

	overlay := inspector_overlay_view(.Dev, scenario, sim_view, toggles, true, Object_ID(1), visuals, diff, trace, trace_filter, invariant_report, breakpoints, breakpoint_match)

	testing.expect_value(t, overlay.build_mode, Build_Mode.Dev)
	testing.expect(t, overlay.paused)
	testing.expect_value(t, overlay.scenario_id, scenario.id)
	testing.expect_value(t, overlay.scenario_seed, scenario.seed)
	testing.expect_value(t, overlay.frame, sim_view.frame)
	testing.expect_value(t, overlay.selected_object_id, Object_ID(1))
	testing.expect_value(t, overlay.snapshot_diff.selected_object_id, Object_ID(1))
	testing.expect(t, overlay.snapshot_diff.position_changed)
	testing.expect_value(t, overlay.render_debug.player_ship.id, sim_view.player_ship.id)
	testing.expect_value(t, overlay.render_debug.camera.target, sim_view.player_ship.position)
	testing.expect_value(t, overlay.render_debug.selected_object_id, Object_ID(1))
	testing.expect_value(t, overlay.render_debug.ship_debug_visuals, visuals)
	testing.expect_value(t, overlay.scenarios.count, 1)
	testing.expect(t, overlay.invariant_report.ok)
	testing.expect_value(t, overlay.trace_filter, trace_filter)
	testing.expect_value(t, overlay.filtered_trace.count, 1)
	testing.expect_value(t, overlay.filtered_trace.entries[0].kind, Event_Kind.Ship_Moved)
	testing.expect(t, !overlay.breakpoint_match.matched)
}

@(test)
test_frame_breakpoints_match_event_kind_and_invariant_failure :: proc(t: ^testing.T) {
	trace := run_scenario_with_trace(player_moves_forward_scenario()).trace

	breakpoints := default_frame_breakpoints()
	toggle_frame_breakpoint_event_kind(&breakpoints, .Ship_Moved)
	event_match := frame_breakpoint_match(breakpoints, trace, Invariant_Report{ok = true})

	testing.expect(t, event_match.matched)
	testing.expect_value(t, event_match.reason, Frame_Breakpoint_Reason.Event_Kind)
	testing.expect_value(t, event_match.event.kind, Event_Kind.Ship_Moved)

	invariant_breakpoints := default_frame_breakpoints()
	toggle_frame_breakpoint_invariant_failure(&invariant_breakpoints)
	invariant_match := frame_breakpoint_match(invariant_breakpoints, Event_Trace{}, Invariant_Report{ok = false, failure_count = 1})

	testing.expect(t, invariant_match.matched)
	testing.expect_value(t, invariant_match.reason, Frame_Breakpoint_Reason.Invariant_Failure)
	testing.expect_value(t, invariant_match.invariant_report.failure_count, 1)
}

@(test)
test_debug_text_commands_normalize_to_debug_commands :: proc(t: ^testing.T) {
	run := parse_debug_text_command("run player_moves_forward")
	restart := parse_debug_text_command("restart player_moves_forward")
	select_object := parse_debug_text_command("select 1")
	break_event := parse_debug_text_command("break event ship_moved")
	break_invariant := parse_debug_text_command("break invariant")
	dump := parse_debug_text_command("dump")

	testing.expect(t, run.ok)
	testing.expect_value(t, run.command.kind, Debug_Command_Kind.Run_Scenario)
	testing.expect_value(t, run.command.scenario_id, PLAYER_MOVES_FORWARD_ID)

	testing.expect(t, restart.ok)
	testing.expect_value(t, restart.command.kind, Debug_Command_Kind.Restart_Scenario)
	testing.expect_value(t, restart.command.scenario_id, PLAYER_MOVES_FORWARD_ID)

	testing.expect(t, select_object.ok)
	testing.expect_value(t, select_object.command.kind, Debug_Command_Kind.Select_Object)
	testing.expect_value(t, select_object.command.object_id, Object_ID(1))

	testing.expect(t, break_event.ok)
	testing.expect_value(t, break_event.command.kind, Debug_Command_Kind.Toggle_Break_On_Event_Kind)
	testing.expect_value(t, break_event.command.event_kind, Event_Kind.Ship_Moved)

	testing.expect(t, break_invariant.ok)
	testing.expect_value(t, break_invariant.command.kind, Debug_Command_Kind.Toggle_Break_On_Invariant_Failure)

	testing.expect(t, dump.ok)
	testing.expect_value(t, dump.command.kind, Debug_Command_Kind.Export_Debug_Dump)
}

@(test)
test_invalid_debug_text_command_is_readable_noop :: proc(t: ^testing.T) {
	invalid := parse_debug_text_command("warp 100")
	bad_scenario := parse_debug_text_command("restart missing_scenario")
	bad_object := parse_debug_text_command("select no")

	testing.expect(t, !invalid.ok)
	testing.expect_value(t, invalid.command.kind, Debug_Command_Kind.None)
	testing.expect(t, strings.contains(invalid.feedback, "Unknown"))

	testing.expect(t, !bad_scenario.ok)
	testing.expect_value(t, bad_scenario.command.kind, Debug_Command_Kind.None)
	testing.expect(t, strings.contains(bad_scenario.feedback, "scenario"))

	testing.expect(t, !bad_object.ok)
	testing.expect_value(t, bad_object.command.kind, Debug_Command_Kind.None)
	testing.expect(t, strings.contains(bad_object.feedback, "Object ID"))
}
