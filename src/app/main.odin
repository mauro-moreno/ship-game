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
		command := read_inspector_overlay_control_command(&app_state, pre_step_overlay)

		simulation_start := f64(0)
		when game.CONFIGURED_BUILD_MODE_NAME != "release" {
			simulation_start = timing_now_seconds()
		}
		apply_app_debug_command(&app_state, command, intent, mode)
		advance_app_state(&app_state, intent, mode)
		simulation_step_us := u64(0)
		fps := i32(0)
		frame_time_seconds := f64(0)
		when game.CONFIGURED_BUILD_MODE_NAME != "release" {
			simulation_step_us = elapsed_us_since(simulation_start)
			fps = i32(rl.GetFPS())
			frame_time_seconds = f64(rl.GetFrameTime())
		}
		record_app_simulation_timing(&app_state, mode, simulation_step_us, fps, frame_time_seconds)

		overlay_view := app_inspector_overlay_view(app_state, mode)
		render_timing := render_frame(overlay_view, debug_console_text(&app_state), app_state.debug_console_feedback)
		record_app_render_timing(&app_state, mode, render_timing, fps, frame_time_seconds)
		export_debug_dump_if_requested(&app_state, mode)
	}
}
