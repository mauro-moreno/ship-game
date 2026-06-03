package game

Scenario_Id :: distinct string
Scenario_Seed :: distinct u64

Scenario :: struct {
	id:              Scenario_Id,
	seed:            Scenario_Seed,
	initial_heading: f32,
	initial_state:   Simulation_State,
	step_count:      int,
	first_intent:    Control_Intent,
}

PLAYER_MOVES_FORWARD_ID :: Scenario_Id("player_moves_forward")
PLAYER_MOVES_FORWARD_SEED :: Scenario_Seed(1)
PLAYER_MOVES_FORWARD_INITIAL_HEADING :: f32(0)

player_moves_forward_scenario :: proc() -> Scenario {
	initial_state := initial_simulation_state_with_heading(PLAYER_MOVES_FORWARD_INITIAL_HEADING)

	return Scenario {
		id = PLAYER_MOVES_FORWARD_ID,
		seed = PLAYER_MOVES_FORWARD_SEED,
		initial_heading = PLAYER_MOVES_FORWARD_INITIAL_HEADING,
		initial_state = initial_state,
		step_count = 1,
		first_intent = Control_Intent{forward_thrust = true},
	}
}

scenario_control_intent :: proc(scenario: Scenario, step_index: Frame_Step_Index) -> Control_Intent {
	if step_index == 0 {
		return scenario.first_intent
	}

	return {}
}

run_scenario :: proc(scenario: Scenario, mode: Build_Mode) -> Simulation_State {
	return run_simulation(simulation_run_from_scenario(scenario, mode)).final_state
}

run_scenario_with_trace :: proc(scenario: Scenario, mode: Build_Mode) -> Simulation_Run_Result {
	return run_simulation(simulation_run_from_scenario(scenario, mode))
}
