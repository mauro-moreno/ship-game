package game

import "core:fmt"

REPLAY_FORMAT_VERSION :: "ship-replay-v1"
MAX_REPLAY_INTENTS :: 32

Replay_Stream :: struct {
	format_version: string,
	scenario_id:    Scenario_Id,
	seed:           Scenario_Seed,
	intents:        [MAX_REPLAY_INTENTS]Control_Intent,
	intent_count:   int,
}

replay_from_scenario :: proc(scenario: Scenario) -> Replay_Stream {
	replay := Replay_Stream {
		format_version = REPLAY_FORMAT_VERSION,
		scenario_id = scenario.id,
		seed = scenario.seed,
	}

	for step_index in 0..<scenario.step_count {
		assert(replay.intent_count < MAX_REPLAY_INTENTS)
		replay.intents[replay.intent_count] = scenario_control_intent(scenario, Frame_Step_Index(step_index))
		replay.intent_count += 1
	}

	return replay
}

replay_simulation :: proc(replay: Replay_Stream, initial_state: Simulation_State) -> Simulation_State {
	state := initial_state

	for i in 0..<replay.intent_count {
		state = step_simulation(state, replay.intents[i])
	}

	return state
}

replay_to_text :: proc(replay: Replay_Stream) -> string {
	first_intent := Control_Intent{}
	if replay.intent_count > 0 {
		first_intent = replay.intents[0]
	}

	return fmt.tprintf(
		"{\"version\":\"%s\",\"scenario\":\"%s\",\"seed\":%v}\n{\"frame\":0,\"forward_thrust\":%v,\"backward_thrust\":%v,\"turn_left\":%v,\"turn_right\":%v}",
		replay.format_version,
		string(replay.scenario_id),
		u64(replay.seed),
		first_intent.forward_thrust,
		first_intent.backward_thrust,
		first_intent.turn_left,
		first_intent.turn_right,
	)
}
