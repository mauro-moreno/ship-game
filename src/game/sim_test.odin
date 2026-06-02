package game

import "core:math"
import "core:testing"

@(test)
test_initial_simulation_has_one_stable_ship_view :: proc(t: ^testing.T) {
	state := initial_simulation_state()
	view := simulation_view(state)

	testing.expect_value(t, view.frame, Frame_Step_Index(0))
	testing.expect_value(t, view.player_ship.id, Object_ID(1))
	testing.expect_value(t, view.player_ship.position, Vec2{})
	testing.expect_value(t, view.player_ship.velocity, Vec2{})
	testing.expect_value(t, view.player_ship.heading, f32(0))
	testing.expect(t, view.player_ship.hitbox.half_width > 0)
	testing.expect(t, view.player_ship.hitbox.half_height > 0)
}

@(test)
test_frame_step_applies_forward_thrust_with_inertia :: proc(t: ^testing.T) {
	state := initial_simulation_state()
	next := step_simulation(state, Control_Intent{forward_thrust = true})
	view := simulation_view(next)

	testing.expect_value(t, view.frame, Frame_Step_Index(1))
	testing.expect(t, view.player_ship.velocity.x > 0)
	testing.expect_value(t, view.player_ship.velocity.y, f32(0))
	testing.expect(t, view.player_ship.position.x > 0)
	testing.expect_value(t, view.player_ship.position.y, f32(0))
	testing.expect_value(t, view.player_ship.heading, f32(0))
	testing.expect(t, vec2_length(view.player_ship.velocity) <= view.player_ship.max_speed)
}

@(test)
test_frame_step_applies_turning_and_backward_thrust :: proc(t: ^testing.T) {
	state := initial_simulation_state()

	turned := step_simulation(state, Control_Intent{turn_right = true})
	turned_view := simulation_view(turned)
	testing.expect(t, turned_view.player_ship.heading > 0)
	testing.expect_value(t, turned_view.player_ship.position, Vec2{})

	reversed := step_simulation(state, Control_Intent{backward_thrust = true})
	reversed_view := simulation_view(reversed)
	testing.expect(t, reversed_view.player_ship.velocity.x < 0)
	testing.expect_value(t, reversed_view.player_ship.velocity.y, f32(0))
	testing.expect(t, reversed_view.player_ship.position.x < 0)
}

@(test)
test_simulation_invariants_report_invalid_ship_state :: proc(t: ^testing.T) {
	valid := initial_simulation_state()
	testing.expect(t, validate_simulation_invariants(valid).ok)

	invalid_id := valid
	invalid_id.ship.id = 0
	testing.expect(t, !validate_simulation_invariants(invalid_id).ok)

	invalid_speed := valid
	invalid_speed.ship.velocity.x = valid.ship.movement.max_speed + 1
	testing.expect(t, !validate_simulation_invariants(invalid_speed).ok)

	invalid_number := valid
	invalid_number.ship.position.x = math.inf_f32(1)
	testing.expect(t, !validate_simulation_invariants(invalid_number).ok)
}

@(test)
test_continuous_invariants_are_enabled_for_dev_and_test_modes :: proc(t: ^testing.T) {
	testing.expect(t, continuous_invariants_enabled(.Dev))
	testing.expect(t, continuous_invariants_enabled(.Test))
	testing.expect(t, !continuous_invariants_enabled(.Release))
}
