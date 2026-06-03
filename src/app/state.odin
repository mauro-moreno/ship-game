package main

import game "ship:game"

App_State :: struct {
	scenario:     game.Scenario,
	simulation:   game.Simulation_State,
	pass_toggles: game.Render_Pass_Toggles,
}

initial_app_state :: proc() -> App_State {
	scenario := game.player_moves_forward_scenario()

	return App_State {
		scenario = scenario,
		simulation = game.run_scenario(scenario),
		pass_toggles = game.default_render_pass_toggles(),
	}
}

advance_app_state :: proc(state: ^App_State, intent: game.Control_Intent, mode: game.Build_Mode) {
	step := game.step_simulation_with_trace(state.simulation, intent, mode)
	state.simulation = step.state
}
