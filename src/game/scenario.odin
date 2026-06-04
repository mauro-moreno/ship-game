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

PLAYER_MOVES_BACKWARD_ID :: Scenario_Id("player_moves_backward")
PLAYER_MOVES_BACKWARD_SEED :: Scenario_Seed(2)
PLAYER_MOVES_BACKWARD_INITIAL_HEADING :: f32(0)

PLAYER_TURNS_LEFT_ID :: Scenario_Id("player_turns_left")
PLAYER_TURNS_LEFT_SEED :: Scenario_Seed(3)
PLAYER_TURNS_LEFT_INITIAL_HEADING :: f32(0)

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

player_moves_backward_scenario :: proc() -> Scenario {
	initial_state := initial_simulation_state_with_heading(PLAYER_MOVES_BACKWARD_INITIAL_HEADING)

	return Scenario {
		id = PLAYER_MOVES_BACKWARD_ID,
		seed = PLAYER_MOVES_BACKWARD_SEED,
		initial_heading = PLAYER_MOVES_BACKWARD_INITIAL_HEADING,
		initial_state = initial_state,
		step_count = 1,
		first_intent = Control_Intent{backward_thrust = true},
	}
}

player_turns_left_scenario :: proc() -> Scenario {
	initial_state := initial_simulation_state_with_heading(PLAYER_TURNS_LEFT_INITIAL_HEADING)

	return Scenario {
		id = PLAYER_TURNS_LEFT_ID,
		seed = PLAYER_TURNS_LEFT_SEED,
		initial_heading = PLAYER_TURNS_LEFT_INITIAL_HEADING,
		initial_state = initial_state,
		step_count = 1,
		first_intent = Control_Intent{turn_left = true},
	}
}

SCENARIO_REGISTRY_COUNT :: 3

Scenario_Builder :: proc() -> Scenario

Scenario_Registry_Entry :: struct {
	id:      Scenario_Id,
	seed:    Scenario_Seed,
	builder: Scenario_Builder,
}

scenario_registry :: proc() -> [SCENARIO_REGISTRY_COUNT]Scenario_Registry_Entry {
	return [SCENARIO_REGISTRY_COUNT]Scenario_Registry_Entry {
		Scenario_Registry_Entry {
			id = PLAYER_MOVES_FORWARD_ID,
			seed = PLAYER_MOVES_FORWARD_SEED,
			builder = player_moves_forward_scenario,
		},
		Scenario_Registry_Entry {
			id = PLAYER_MOVES_BACKWARD_ID,
			seed = PLAYER_MOVES_BACKWARD_SEED,
			builder = player_moves_backward_scenario,
		},
		Scenario_Registry_Entry {
			id = PLAYER_TURNS_LEFT_ID,
			seed = PLAYER_TURNS_LEFT_SEED,
			builder = player_turns_left_scenario,
		},
	}
}

scenario_count :: proc() -> int {
	return SCENARIO_REGISTRY_COUNT
}

scenario_registry_entry_at :: proc(index: int) -> (Scenario_Registry_Entry, bool) {
	if index < 0 || index >= SCENARIO_REGISTRY_COUNT {
		return {}, false
	}

	entries := scenario_registry()
	return entries[index], true
}

scenario_at :: proc(index: int) -> (Scenario, bool) {
	if entry, ok := scenario_registry_entry_at(index); ok {
		return entry.builder(), true
	}

	return {}, false
}

scenario_by_id :: proc(id: Scenario_Id) -> (Scenario, bool) {
	entries := scenario_registry()
	for index in 0..<SCENARIO_REGISTRY_COUNT {
		entry := entries[index]
		if entry.id == id {
			return entry.builder(), true
		}
	}

	return {}, false
}

scenario_id_from_text :: proc(text: string) -> (Scenario_Id, bool) {
	entries := scenario_registry()
	for index in 0..<SCENARIO_REGISTRY_COUNT {
		entry := entries[index]
		if text == string(entry.id) {
			return entry.id, true
		}
	}

	return "", false
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
