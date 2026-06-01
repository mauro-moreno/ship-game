package main

import game "ship:game"
import rl "vendor:raylib"

draw_inspector_overlay :: proc(mode: game.Build_Mode) {
	rl.DrawText("dev Build Mode", 24, 58, 16, rl.SKYBLUE)
	_ = mode
}
