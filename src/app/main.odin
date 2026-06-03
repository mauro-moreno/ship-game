package main

import game "ship:game"
import rl "vendor:raylib"

main :: proc() {
	mode := game.configured_build_mode()
	app_state := initial_app_state()

	rl.InitWindow(1280, 720, "SHIP GAME - Debuggable Skeleton")
	defer rl.CloseWindow()

	rl.SetTargetFPS(60)

	for !rl.WindowShouldClose() {
		intent := read_control_intent()
		handle_dev_render_pass_toggles(mode, &app_state.pass_toggles)
		pre_step_view := game.simulation_view(app_state.simulation)
		pre_step_overlay := game.inspector_overlay_view(mode, app_state.scenario, pre_step_view, app_state.pass_toggles, app_state.paused)
		command := read_inspector_overlay_command(pre_step_overlay)

		apply_app_debug_command(&app_state, command, intent, mode)
		advance_app_state(&app_state, intent, mode)

		view := game.simulation_view(app_state.simulation)
		overlay_view := game.inspector_overlay_view(mode, app_state.scenario, view, app_state.pass_toggles, app_state.paused)
		render_frame(overlay_view)
	}
}
