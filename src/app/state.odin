package main

import game "ship:game"

App_State :: struct {
	scenario:            game.Scenario,
	simulation:          game.Simulation_State,
	pass_toggles:        game.Render_Pass_Toggles,
	paused:              bool,
	scenario_step_index: game.Frame_Step_Index,
	selected_object_id:  game.Object_ID,
	ship_debug_visuals: game.Ship_Debug_Visual_Toggles,
	last_snapshot_diff: game.State_Snapshot_Diff,
	last_trace:          game.Event_Trace,
}

initial_app_state :: proc() -> App_State {
	scenario := game.player_moves_forward_scenario()
	selected_object_id := scenario.initial_state.ship.id

	return App_State {
		scenario = scenario,
		simulation = scenario.initial_state,
		pass_toggles = game.default_render_pass_toggles(),
		paused = false,
		scenario_step_index = 0,
		selected_object_id = selected_object_id,
		ship_debug_visuals = game.default_ship_debug_visual_toggles(),
		last_snapshot_diff = snapshot_diff_for_current_state(scenario.initial_state, selected_object_id),
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
	case .Select_Object:
		if command.object_id == state.simulation.ship.id {
			state.selected_object_id = command.object_id
			state.last_snapshot_diff = snapshot_diff_for_current_state(state.simulation, state.selected_object_id)
		}
	case .Toggle_Selected_Hitbox:
		game.toggle_ship_debug_hitbox(&state.ship_debug_visuals)
	case .Toggle_Selected_Velocity_Vector:
		game.toggle_ship_debug_velocity_vector(&state.ship_debug_visuals)
	}
}

advance_app_state_one_frame :: proc(state: ^App_State, live_intent: game.Control_Intent, mode: game.Build_Mode) {
	intent := live_intent
	if state.scenario_step_index < game.Frame_Step_Index(state.scenario.step_count) {
		intent = game.scenario_control_intent(state.scenario, state.scenario_step_index)
		state.scenario_step_index += 1
	}

	before := game.capture_state_snapshot(state.simulation, state.selected_object_id)
	step := game.step_simulation_with_trace(state.simulation, intent, mode)
	state.simulation = step.state
	after := game.capture_state_snapshot(state.simulation, state.selected_object_id)
	state.last_snapshot_diff = game.diff_state_snapshots(before, after)
	state.last_trace = step.trace
}

start_scenario :: proc(state: ^App_State, scenario: game.Scenario, paused: bool) {
	state.scenario = scenario
	state.simulation = scenario.initial_state
	state.scenario_step_index = 0
	state.paused = paused
	state.selected_object_id = scenario.initial_state.ship.id
	state.last_snapshot_diff = snapshot_diff_for_current_state(state.simulation, state.selected_object_id)
	state.last_trace = {}
}

app_inspector_overlay_view :: proc(state: App_State, mode: game.Build_Mode) -> game.Inspector_Overlay_View {
	view := game.simulation_view(state.simulation)

	return game.inspector_overlay_view(
		mode,
		state.scenario,
		view,
		state.pass_toggles,
		state.paused,
		state.selected_object_id,
		state.ship_debug_visuals,
		state.last_snapshot_diff,
		state.last_trace,
	)
}

snapshot_diff_for_current_state :: proc(state: game.Simulation_State, selected_object_id: game.Object_ID) -> game.State_Snapshot_Diff {
	snapshot := game.capture_state_snapshot(state, selected_object_id)
	return game.diff_state_snapshots(snapshot, snapshot)
}
