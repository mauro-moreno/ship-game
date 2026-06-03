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
