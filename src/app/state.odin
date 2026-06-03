package main

import game "ship:game"

DEBUG_CONSOLE_INPUT_CAPACITY :: 96

App_State :: struct {
	scenario:            game.Scenario,
	simulation:          game.Simulation_State,
	pass_toggles:        game.Render_Pass_Toggles,
	paused:              bool,
	scenario_step_index: game.Frame_Step_Index,
	selected_object_id:  game.Object_ID,
	ship_debug_visuals: game.Ship_Debug_Visual_Toggles,
	last_snapshot_diff: game.State_Snapshot_Diff,
	trace_tail:          game.Event_Trace,
	trace_filter:        game.Trace_Filter,
	invariant_report:    game.Invariant_Report,
	frame_breakpoints:   game.Frame_Breakpoints,
	breakpoint_match:    game.Frame_Breakpoint_Match,
	replay:              game.Replay_Stream,
	performance_timing:  game.Performance_Timing_View,
	last_simulation_step_us: u64,
	last_render_pipeline_us: u64,
	last_render_pass_timings: game.Render_Pass_Timings,
	last_fps:            i32,
	last_frame_time_seconds: f64,
	debug_console_input: [DEBUG_CONSOLE_INPUT_CAPACITY]u8,
	debug_console_length: int,
	debug_console_feedback: string,
	debug_dump_requested: bool,
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
		trace_filter = game.trace_filter_for_object(selected_object_id),
		invariant_report = game.validate_simulation_invariants(scenario.initial_state),
		frame_breakpoints = game.default_frame_breakpoints(),
		replay = game.replay_from_scenario(scenario),
		last_render_pass_timings = game.initial_render_pass_timings(),
		performance_timing = game.performance_timing_view_for_frame(.Dev, game.simulation_view(scenario.initial_state), 0, 0, 0, game.initial_render_pass_timings(), 0, 0),
		debug_console_feedback = "ready",
	}
}

advance_app_state :: proc(state: ^App_State, intent: game.Control_Intent, mode: game.Build_Mode) {
	if state.paused {
		return
	}

	advance_app_state_one_frame(state, intent, mode)
}

apply_app_debug_command :: proc(state: ^App_State, command: game.Debug_Command, intent: game.Control_Intent, mode: game.Build_Mode) {
	if command.kind != .None {
		game.replay_record_debug_command(&state.replay, state.simulation.frame, command)
	}

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
			if state.trace_filter.use_object_id {
				state.trace_filter.object_id = state.selected_object_id
			}
		}
	case .Toggle_Selected_Hitbox:
		game.toggle_ship_debug_hitbox(&state.ship_debug_visuals)
	case .Toggle_Selected_Velocity_Vector:
		game.toggle_ship_debug_velocity_vector(&state.ship_debug_visuals)
	case .Toggle_Trace_Object_Filter:
		state.trace_filter.use_object_id = !state.trace_filter.use_object_id
		state.trace_filter.object_id = state.selected_object_id
	case .Toggle_Trace_Frame_Range_Filter:
		state.trace_filter.use_frame_range = !state.trace_filter.use_frame_range
		update_trace_filter_frame_range(state)
	case .Toggle_Trace_Event_Kind_Filter:
		if state.trace_filter.use_event_kind && state.trace_filter.event_kind == command.event_kind {
			state.trace_filter.use_event_kind = false
		} else {
			state.trace_filter.use_event_kind = true
			state.trace_filter.event_kind = command.event_kind
		}
	case .Toggle_Break_On_Event_Kind:
		game.toggle_frame_breakpoint_event_kind(&state.frame_breakpoints, command.event_kind)
	case .Toggle_Break_On_Invariant_Failure:
		game.toggle_frame_breakpoint_invariant_failure(&state.frame_breakpoints)
	case .Export_Debug_Dump:
		state.debug_dump_requested = true
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
	game.trace_tail_append_all(&state.trace_tail, step.trace)
	state.invariant_report = game.validate_simulation_invariants(state.simulation)
	state.breakpoint_match = game.frame_breakpoint_match(state.frame_breakpoints, step.trace, state.invariant_report)
	if state.breakpoint_match.matched {
		state.paused = true
	}
	update_trace_filter_frame_range(state)
}

start_scenario :: proc(state: ^App_State, scenario: game.Scenario, paused: bool) {
	state.scenario = scenario
	state.simulation = scenario.initial_state
	state.scenario_step_index = 0
	state.paused = paused
	state.selected_object_id = scenario.initial_state.ship.id
	state.last_snapshot_diff = snapshot_diff_for_current_state(state.simulation, state.selected_object_id)
	state.trace_tail = {}
	state.trace_filter = game.trace_filter_for_object(state.selected_object_id)
	state.invariant_report = game.validate_simulation_invariants(state.simulation)
	state.breakpoint_match = {}
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
		state.trace_tail,
		state.trace_filter,
		state.invariant_report,
		state.frame_breakpoints,
		state.breakpoint_match,
		state.performance_timing,
	)
}

debug_console_text :: proc(state: ^App_State) -> string {
	return string(state.debug_console_input[:state.debug_console_length])
}

record_app_simulation_timing :: proc(state: ^App_State, mode: game.Build_Mode, simulation_step_us: u64, fps: i32, frame_time_seconds: f64) {
	state.last_simulation_step_us = simulation_step_us
	state.last_fps = fps
	state.last_frame_time_seconds = frame_time_seconds
	refresh_app_performance_timing(state, mode)
}

record_app_render_timing :: proc(state: ^App_State, mode: game.Build_Mode, render_timing: App_Render_Timing, fps: i32, frame_time_seconds: f64) {
	state.last_render_pipeline_us = render_timing.pipeline_us
	state.last_render_pass_timings = render_timing.pass_timings
	state.last_fps = fps
	state.last_frame_time_seconds = frame_time_seconds
	refresh_app_performance_timing(state, mode)
}

refresh_app_performance_timing :: proc(state: ^App_State, mode: game.Build_Mode) {
	state.performance_timing = game.performance_timing_view_for_frame(
		mode,
		game.simulation_view(state.simulation),
		state.trace_tail.count,
		state.last_simulation_step_us,
		state.last_render_pipeline_us,
		state.last_render_pass_timings,
		state.last_fps,
		state.last_frame_time_seconds,
	)
}

snapshot_diff_for_current_state :: proc(state: game.Simulation_State, selected_object_id: game.Object_ID) -> game.State_Snapshot_Diff {
	snapshot := game.capture_state_snapshot(state, selected_object_id)
	return game.diff_state_snapshots(snapshot, snapshot)
}

update_trace_filter_frame_range :: proc(state: ^App_State) {
	if !state.trace_filter.use_frame_range {
		return
	}

	frame := state.simulation.frame
	state.trace_filter.frame_end = frame
	if frame > 5 {
		state.trace_filter.frame_start = frame - 5
	} else {
		state.trace_filter.frame_start = 0
	}
}
