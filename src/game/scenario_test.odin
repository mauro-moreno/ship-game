package game

import "core:testing"

@(test)
test_scenario_registry_exposes_movement_scenarios_in_inspection_order :: proc(t: ^testing.T) {
	testing.expect_value(t, scenario_count(), 3)

	forward, forward_ok := scenario_at(0)
	backward, backward_ok := scenario_at(1)
	turns_left, turns_left_ok := scenario_at(2)

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

	testing.expect(t, turns_left_ok)
	testing.expect_value(t, turns_left.id, PLAYER_TURNS_LEFT_ID)
	testing.expect_value(t, turns_left.seed, PLAYER_TURNS_LEFT_SEED)
	testing.expect_value(t, turns_left.initial_heading, PLAYER_TURNS_LEFT_INITIAL_HEADING)
	testing.expect(t, turns_left.first_intent.turn_left)
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

@(test)
test_player_turns_left_scenario_changes_heading_without_translation :: proc(t: ^testing.T) {
	scenario := player_turns_left_scenario()
	intent := scenario_control_intent(scenario, 0)
	final_state := run_scenario(scenario, .Test)
	final_view := simulation_view(final_state)

	testing.expect_value(t, scenario.id, Scenario_Id("player_turns_left"))
	testing.expect_value(t, scenario.seed, Scenario_Seed(3))
	testing.expect_value(t, scenario.initial_heading, f32(0))
	testing.expect(t, !intent.forward_thrust)
	testing.expect(t, !intent.backward_thrust)
	testing.expect(t, intent.turn_left)
	testing.expect(t, !intent.turn_right)
	testing.expect_value(t, final_view.frame, Frame_Step_Index(1))
	testing.expect(t, final_view.player_ship.heading < scenario.initial_heading)
	testing.expect_value(t, final_view.player_ship.position, Vec2{})
	testing.expect_value(t, final_view.player_ship.velocity, Vec2{})
}
