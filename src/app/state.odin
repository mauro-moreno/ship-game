package main

import game "ship:game"

App_State :: struct {
	scenario:            game.Scenario,
	simulation:          game.Simulation_State,
	pass_toggles:        game.Render_Pass_Toggles,
	paused:              bool,
	scenario_step_index: game.Frame_Step_Index,
}

initial_app_state :: proc() -> App_State {
	scenario := game.player_moves_forward_scenario()

	return App_State {
		scenario = scenario,
		simulation = scenario.initial_state,
		pass_toggles = game.default_render_pass_toggles(),
		paused = false,
		scenario_step_index = 0,
	}
}

advance_app_state :: proc(state: ^App_State, intent: game.Control_Intent, mode: game.Build_Mode) {
	if state.paused {
		return
	}

	advance_app_state_one_frame(state, intent, mode)
}

apply_app_debug_command :: proc(state: ^App_State, command: game.Debug_Command, intent: game.Control_Intent, mode: game.Build_Mode) {
	switch command.kind {
	case .None:
	case .Pause:
		state.paused = true
	case .Resume:
		state.paused = false
	case .Step_Frame:
		advance_app_state_one_frame(state, intent, mode)
		state.paused = true
	case .Run_Scenario:
		if scenario, ok := game.scenario_by_id(command.scenario_id); ok {
			start_scenario(state, scenario, false)
		}
	case .Restart_Scenario:
		if scenario, ok := game.scenario_by_id(command.scenario_id); ok {
			start_scenario(state, scenario, true)
		}
	}
}

advance_app_state_one_frame :: proc(state: ^App_State, live_intent: game.Control_Intent, mode: game.Build_Mode) {
	intent := live_intent
	if state.scenario_step_index < game.Frame_Step_Index(state.scenario.step_count) {
		intent = game.scenario_control_intent(state.scenario, state.scenario_step_index)
		state.scenario_step_index += 1
	}

	step := game.step_simulation_with_trace(state.simulation, intent, mode)
	state.simulation = step.state
}

start_scenario :: proc(state: ^App_State, scenario: game.Scenario, paused: bool) {
	state.scenario = scenario
	state.simulation = scenario.initial_state
	state.scenario_step_index = 0
	state.paused = paused
}
