package game

Control_Input_State :: struct {
	forward_key_down:  bool,
	backward_key_down: bool,
	turn_left_key_down: bool,
	turn_right_key_down: bool,
}

Control_Intent :: struct {
	forward_thrust:  bool,
	backward_thrust: bool,
	turn_left:      bool,
	turn_right:     bool,
}

control_intent_from_input_state :: proc(input: Control_Input_State) -> Control_Intent {
	return Control_Intent {
		forward_thrust = input.forward_key_down,
		backward_thrust = input.backward_key_down,
		turn_left = input.turn_left_key_down,
		turn_right = input.turn_right_key_down,
	}
}
