package main

import game "ship:game"
import rl "vendor:raylib"

main :: proc() {
	mode := game.configured_build_mode()

	rl.InitWindow(1280, 720, "SHIP GAME - Debuggable Skeleton")
	defer rl.CloseWindow()

	rl.SetTargetFPS(60)

	for !rl.WindowShouldClose() {
		render_frame(mode)
	}
}
