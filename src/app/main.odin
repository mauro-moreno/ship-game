package main

import game "ship:game"
import rl "vendor:raylib"

main :: proc() {
	mode := game.configured_build_mode()

	rl.InitWindow(1280, 720, "SHIP GAME - Debuggable Skeleton")
	defer rl.CloseWindow()

	rl.SetTargetFPS(60)

	for !rl.WindowShouldClose() {
		intent := read_control_intent()
		render_frame(mode, intent)
	}
}
