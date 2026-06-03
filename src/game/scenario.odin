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

Scenario_Run_Result :: struct {
	final_state: Simulation_State,
	trace:       Event_Trace,
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

run_scenario :: proc(scenario: Scenario) -> Simulation_State {
	state := scenario.initial_state

	for step_index in 0..<scenario.step_count {
		state = step_simulation(state, scenario_control_intent(scenario, Frame_Step_Index(step_index)))
	}

	return state
}

run_scenario_with_trace :: proc(scenario: Scenario) -> Scenario_Run_Result {
	trace: Event_Trace
	state := scenario.initial_state

	trace_append(&trace, Event_Trace_Entry {
		kind = .Scenario_Started,
		frame = state.frame,
		scenario_id = scenario.id,
	})

	for step_index in 0..<scenario.step_count {
		intent := scenario_control_intent(scenario, Frame_Step_Index(step_index))
		step_result := step_simulation_with_trace(state, intent, .Test)
		trace_append_all(&trace, step_result.trace)
		state = step_result.state
	}

	return Scenario_Run_Result{final_state = state, trace = trace}
}
