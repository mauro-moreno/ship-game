package game

MAX_SIMULATION_RUN_INTENTS :: 32
MAX_SIMULATION_RUN_DEBUG_COMMANDS :: 32

Simulation_Run_Debug_Command_Record :: struct {
	frame:   Frame_Step_Index,
	command: Debug_Command,
}

Simulation_Run :: struct {
	mode:                Build_Mode,
	scenario_id:         Scenario_Id,
	initial_state:       Simulation_State,
	intents:             [MAX_SIMULATION_RUN_INTENTS]Control_Intent,
	intent_count:        int,
	debug_commands:      [MAX_SIMULATION_RUN_DEBUG_COMMANDS]Simulation_Run_Debug_Command_Record,
	debug_command_count: int,
}

Simulation_Run_Result :: struct {
	final_state: Simulation_State,
	trace:       Event_Trace,
}

simulation_run_from_scenario :: proc(scenario: Scenario, mode: Build_Mode) -> Simulation_Run {
	run := Simulation_Run {
		mode = mode,
		scenario_id = scenario.id,
		initial_state = scenario.initial_state,
	}

	for step_index in 0..<scenario.step_count {
		assert(run.intent_count < MAX_SIMULATION_RUN_INTENTS)
		run.intents[run.intent_count] = scenario_control_intent(scenario, Frame_Step_Index(step_index))
		run.intent_count += 1
	}

	return run
}

simulation_run_from_replay :: proc(replay: Replay_Stream, initial_state: Simulation_State, mode: Build_Mode) -> Simulation_Run {
	run := Simulation_Run {
		mode = mode,
		scenario_id = replay.scenario_id,
		initial_state = initial_state,
	}

	for i in 0..<replay.intent_count {
		assert(run.intent_count < MAX_SIMULATION_RUN_INTENTS)
		run.intents[run.intent_count] = replay.intents[i]
		run.intent_count += 1
	}

	for i in 0..<replay.debug_command_count {
		assert(run.debug_command_count < MAX_SIMULATION_RUN_DEBUG_COMMANDS)
		record := replay.debug_commands[i]
		// Replay Debug Commands are kept as investigation context until one is allowed to mutate Simulation.
		run.debug_commands[run.debug_command_count] = Simulation_Run_Debug_Command_Record {
			frame = record.frame,
			command = record.command,
		}
		run.debug_command_count += 1
	}

	return run
}

run_simulation :: proc(run: Simulation_Run) -> Simulation_Run_Result {
	trace: Event_Trace
	state := run.initial_state

	if string(run.scenario_id) != "" {
		trace_append(&trace, Event_Trace_Entry {
			kind = .Scenario_Started,
			frame = state.frame,
			scenario_id = run.scenario_id,
		})
	}

	for step_index in 0..<run.intent_count {
		step_result := step_simulation_with_trace(state, run.intents[step_index], run.mode)
		trace_append_all(&trace, step_result.trace)
		state = step_result.state
	}

	return Simulation_Run_Result {
		final_state = state,
		trace = trace,
	}
}
