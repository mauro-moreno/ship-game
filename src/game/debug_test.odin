package game

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

	overlay := inspector_overlay_view(.Dev, scenario, sim_view, toggles, true, Object_ID(1), visuals, diff, trace)

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
	testing.expect_value(t, overlay.selected_trace.count, 2)
}
