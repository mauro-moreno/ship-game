package game

import "core:testing"

@(test)
test_control_input_state_maps_to_control_intent :: proc(t: ^testing.T) {
	intent := control_intent_from_input_state(Control_Input_State {
		forward_key_down = true,
		backward_key_down = true,
		turn_left_key_down = true,
		turn_right_key_down = true,
	})

	testing.expect(t, intent.forward_thrust)
	testing.expect(t, intent.backward_thrust)
	testing.expect(t, intent.turn_left)
	testing.expect(t, intent.turn_right)
}
