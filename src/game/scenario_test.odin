package game

import "core:testing"

@(test)
test_scenario_registry_exposes_player_moves_forward_as_first_registered_scenario :: proc(t: ^testing.T) {
	testing.expect_value(t, scenario_count(), 2)

	forward, forward_ok := scenario_at(0)
	backward, backward_ok := scenario_at(1)

	testing.expect(t, forward_ok)
	testing.expect_value(t, forward.id, PLAYER_MOVES_FORWARD_ID)
	testing.expect_value(t, forward.seed, PLAYER_MOVES_FORWARD_SEED)
	testing.expect_value(t, forward.initial_heading, PLAYER_MOVES_FORWARD_INITIAL_HEADING)
	testing.expect(t, forward.first_intent.forward_thrust)

	testing.expect(t, backward_ok)
	testing.expect_value(t, backward.id, PLAYER_MOVES_BACKWARD_ID)
	testing.expect_value(t, backward.seed, PLAYER_MOVES_BACKWARD_SEED)
	testing.expect_value(t, backward.initial_heading, PLAYER_MOVES_BACKWARD_INITIAL_HEADING)
	testing.expect(t, backward.first_intent.backward_thrust)
}

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

@(test)
test_player_moves_backward_scenario_moves_ship_against_facing_direction :: proc(t: ^testing.T) {
	scenario := player_moves_backward_scenario()
	intent := scenario_control_intent(scenario, 0)
	final_state := run_scenario(scenario, .Test)
	final_view := simulation_view(final_state)

	testing.expect_value(t, scenario.id, Scenario_Id("player_moves_backward"))
	testing.expect_value(t, scenario.seed, Scenario_Seed(2))
	testing.expect_value(t, scenario.initial_heading, f32(0))
	testing.expect(t, !intent.forward_thrust)
	testing.expect(t, intent.backward_thrust)
	testing.expect(t, !intent.turn_left)
	testing.expect(t, !intent.turn_right)
	testing.expect_value(t, final_view.frame, Frame_Step_Index(1))
	testing.expect(t, final_view.player_ship.velocity.x < 0)
	testing.expect_value(t, final_view.player_ship.velocity.y, f32(0))
	testing.expect(t, final_view.player_ship.position.x < 0)
	testing.expect_value(t, final_view.player_ship.position.y, f32(0))
	testing.expect_value(t, final_view.player_ship.heading, scenario.initial_heading)
	testing.expect(t, vec2_length(final_view.player_ship.velocity) <= final_view.player_ship.max_speed)
}
