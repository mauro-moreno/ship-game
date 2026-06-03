package game

import "core:testing"

@(test)
test_simulation_run_executes_scenario_with_explicit_build_mode :: proc(t: ^testing.T) {
	scenario := player_moves_forward_scenario()
	invalid_scenario := scenario
	invalid_scenario.initial_state.ship.id = 0

	test_run := simulation_run_from_scenario(invalid_scenario, .Test)
	test_result := run_simulation(test_run)

	release_run := simulation_run_from_scenario(invalid_scenario, .Release)
	release_result := run_simulation(release_run)

	testing.expect_value(t, test_result.final_state.frame, Frame_Step_Index(0))
	testing.expect_value(t, test_result.trace.count, 2)
	testing.expect_value(t, test_result.trace.entries[0].kind, Event_Kind.Scenario_Started)
	testing.expect_value(t, test_result.trace.entries[1].kind, Event_Kind.Invariant_Failed)

	testing.expect_value(t, release_result.final_state.frame, Frame_Step_Index(1))
	testing.expect_value(t, release_result.trace.count, 3)
	testing.expect_value(t, release_result.trace.entries[0].kind, Event_Kind.Scenario_Started)
	testing.expect_value(t, release_result.trace.entries[1].kind, Event_Kind.Control_Intent_Applied)
	testing.expect_value(t, release_result.trace.entries[2].kind, Event_Kind.Ship_Moved)
}

@(test)
test_simulation_run_is_shared_by_scenario_and_replay :: proc(t: ^testing.T) {
	scenario := player_moves_forward_scenario()
	replay := replay_from_scenario(scenario)
	select_command := debug_select_object_command(Object_ID(1))
	replay_record_debug_command(&replay, Frame_Step_Index(0), select_command)

	scenario_result := run_simulation(simulation_run_from_scenario(scenario, .Test))
	replay_run := simulation_run_from_replay(replay, scenario.initial_state, .Test)
	replay_result := run_simulation(replay_run)

	testing.expect_value(t, replay_run.debug_command_count, 1)
	testing.expect_value(t, replay_run.debug_commands[0].command.kind, Debug_Command_Kind.Select_Object)
	testing.expect_value(t, replay_result.final_state, scenario_result.final_state)
	testing.expect_value(t, replay_simulation(replay, scenario.initial_state, .Test), scenario_result.final_state)
}
