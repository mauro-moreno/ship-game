package main

import game "ship:game"
import rl "vendor:raylib"

read_control_intent :: proc() -> game.Control_Intent {
	input := game.Control_Input_State {
		forward_key_down = rl.IsKeyDown(.W) || rl.IsKeyDown(.UP),
		backward_key_down = rl.IsKeyDown(.S) || rl.IsKeyDown(.DOWN),
		turn_left_key_down = rl.IsKeyDown(.A) || rl.IsKeyDown(.LEFT),
		turn_right_key_down = rl.IsKeyDown(.D) || rl.IsKeyDown(.RIGHT),
	}

	return game.control_intent_from_input_state(input)
}

handle_dev_render_pass_toggles :: proc(mode: game.Build_Mode, toggles: ^game.Render_Pass_Toggles) {
	if mode != .Dev {
		return
	}

	if rl.IsKeyPressed(.ONE) {
		game.toggle_render_pass(toggles, .Background)
	}
	if rl.IsKeyPressed(.TWO) {
		game.toggle_render_pass(toggles, .World)
	}
	if rl.IsKeyPressed(.THREE) {
		game.toggle_render_pass(toggles, .Debug)
	}
	if rl.IsKeyPressed(.FOUR) {
		game.toggle_render_pass(toggles, .Inspector)
	}
}
