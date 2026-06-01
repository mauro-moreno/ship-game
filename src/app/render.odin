package main

import game "ship:game"
import rl "vendor:raylib"

render_frame :: proc(mode: game.Build_Mode) {
	rl.BeginDrawing()
	defer rl.EndDrawing()

	rl.ClearBackground(rl.BLACK)
	rl.DrawText("SHIP GAME - Debuggable Skeleton", 24, 24, 24, rl.RAYWHITE)

	when game.CONFIGURED_BUILD_MODE_NAME == "dev" {
		draw_inspector_overlay(mode)
	}
}
