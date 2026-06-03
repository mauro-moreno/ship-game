package game

import "core:testing"

@(test)
test_player_moves_forward_scenario_has_reusable_setup :: proc(t: ^testing.T) {
	scenario := player_moves_forward_scenario()
	view := simulation_view(scenario.initial_state)
	intent := scenario_control_intent(scenario, 0)

	testing.expect_value(t, scenario.id, Scenario_Id("player_moves_forward"))
	testing.expect_value(t, scenario.seed, Scenario_Seed(1))
	testing.expect_value(t, scenario.initial_heading, f32(0))
	testing.expect_value(t, view.frame, Frame_Step_Index(0))
	testing.expect_value(t, view.player_ship.id, Object_ID(1))
	testing.expect_value(t, view.player_ship.heading, scenario.initial_heading)
	testing.expect(t, intent.forward_thrust)
	testing.expect(t, !intent.backward_thrust)
	testing.expect(t, !intent.turn_left)
	testing.expect(t, !intent.turn_right)
}

@(test)
test_player_moves_forward_scenario_moves_ship_in_facing_direction :: proc(t: ^testing.T) {
	scenario := player_moves_forward_scenario()
	final_state := run_scenario(scenario, .Test)
	final_view := simulation_view(final_state)

	testing.expect_value(t, final_view.frame, Frame_Step_Index(1))
	testing.expect(t, final_view.player_ship.velocity.x > 0)
	testing.expect_value(t, final_view.player_ship.velocity.y, f32(0))
	testing.expect(t, final_view.player_ship.position.x > 0)
	testing.expect_value(t, final_view.player_ship.position.y, f32(0))
	testing.expect_value(t, final_view.player_ship.heading, scenario.initial_heading)
	testing.expect(t, vec2_length(final_view.player_ship.velocity) <= final_view.player_ship.max_speed)
}
