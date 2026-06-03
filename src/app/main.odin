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
		advance_app_state(&app_state, intent, mode)

		debug_view := game.render_debug_view(game.simulation_view(app_state.simulation), app_state.pass_toggles)
		render_frame(mode, app_state.scenario.id, debug_view)
	}
}
