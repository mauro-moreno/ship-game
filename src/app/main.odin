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
		pre_step_overlay := app_inspector_overlay_view(app_state, mode)
		command := update_debug_text_console(&app_state)
		if command.kind == .None {
			command = read_inspector_overlay_command(pre_step_overlay)
		}
		if command.kind == .None {
			command = read_object_picking_command(pre_step_overlay)
		}

		apply_app_debug_command(&app_state, command, intent, mode)
		advance_app_state(&app_state, intent, mode)

		overlay_view := app_inspector_overlay_view(app_state, mode)
		render_frame(overlay_view, debug_console_text(&app_state), app_state.debug_console_feedback)
	}
}
