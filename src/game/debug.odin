package game

MAX_SCENARIO_BROWSER_ITEMS :: 4

Debug_Artifacts :: struct {}

Debug_Command_Kind :: enum {
	None,
	Pause,
	Resume,
	Step_Frame,
	Run_Scenario,
	Restart_Scenario,
	Select_Object,
	Toggle_Selected_Hitbox,
	Toggle_Selected_Velocity_Vector,
}

Debug_Command :: struct {
	kind:        Debug_Command_Kind,
	scenario_id: Scenario_Id,
	object_id:   Object_ID,
}

Scenario_Browser_Item :: struct {
	id:       Scenario_Id,
	seed:     Scenario_Seed,
	selected: bool,
}

Scenario_Browser_View :: struct {
	count: int,
	items: [MAX_SCENARIO_BROWSER_ITEMS]Scenario_Browser_Item,
}

Inspector_Overlay_View :: struct {
	build_mode:    Build_Mode,
	paused:        bool,
	scenario_id:   Scenario_Id,
	scenario_seed: Scenario_Seed,
	frame:         Frame_Step_Index,
	selected_object_id: Object_ID,
	render_debug:  Render_Debug_View,
	scenarios:     Scenario_Browser_View,
	snapshot_diff: State_Snapshot_Diff,
	selected_trace: Event_Trace,
}

NO_DEBUG_COMMAND :: Debug_Command{kind = .None}

debug_pause_command :: proc() -> Debug_Command {
	return Debug_Command{kind = .Pause}
}

debug_resume_command :: proc() -> Debug_Command {
	return Debug_Command{kind = .Resume}
}

debug_step_frame_command :: proc() -> Debug_Command {
	return Debug_Command{kind = .Step_Frame}
}

debug_run_scenario_command :: proc(id: Scenario_Id) -> Debug_Command {
	return Debug_Command{kind = .Run_Scenario, scenario_id = id}
}

debug_restart_scenario_command :: proc(id: Scenario_Id) -> Debug_Command {
	return Debug_Command{kind = .Restart_Scenario, scenario_id = id}
}

debug_select_object_command :: proc(id: Object_ID) -> Debug_Command {
	return Debug_Command{kind = .Select_Object, object_id = id}
}

debug_toggle_selected_hitbox_command :: proc() -> Debug_Command {
	return Debug_Command{kind = .Toggle_Selected_Hitbox}
}

debug_toggle_selected_velocity_vector_command :: proc() -> Debug_Command {
	return Debug_Command{kind = .Toggle_Selected_Velocity_Vector}
}

scenario_browser_view :: proc(active_id: Scenario_Id) -> Scenario_Browser_View {
	view: Scenario_Browser_View
	scenario := player_moves_forward_scenario()

	view.items[0] = Scenario_Browser_Item {
		id = scenario.id,
		seed = scenario.seed,
		selected = scenario.id == active_id,
	}
	view.count = 1

	return view
}

scenario_by_id :: proc(id: Scenario_Id) -> (Scenario, bool) {
	if id == PLAYER_MOVES_FORWARD_ID {
		return player_moves_forward_scenario(), true
	}

	return {}, false
}

inspector_overlay_view :: proc(
	mode: Build_Mode,
	scenario: Scenario,
	view: Simulation_View,
	toggles: Render_Pass_Toggles,
	paused: bool,
	selected_object_id: Object_ID,
	ship_debug_visuals: Ship_Debug_Visual_Toggles,
	snapshot_diff: State_Snapshot_Diff,
	trace: Event_Trace,
) -> Inspector_Overlay_View {
	return Inspector_Overlay_View {
		build_mode = mode,
		paused = paused,
		scenario_id = scenario.id,
		scenario_seed = scenario.seed,
		frame = view.frame,
		selected_object_id = selected_object_id,
		render_debug = render_debug_view_with_selection(view, toggles, selected_object_id, ship_debug_visuals),
		scenarios = scenario_browser_view(scenario.id),
		snapshot_diff = snapshot_diff,
		selected_trace = trace_filter_by_object(trace, selected_object_id),
	}
}

State_Snapshot :: struct {
	selected_object_id: Object_ID,
	view:               Simulation_View,
}

State_Snapshot_Diff :: struct {
	selected_object_id: Object_ID,
	selected_object_changed: bool,
	position_changed:   bool,
	heading_changed:    bool,
	velocity_changed:   bool,
	before_position:    Vec2,
	after_position:     Vec2,
	before_heading:     f32,
	after_heading:      f32,
	before_velocity:    Vec2,
	after_velocity:     Vec2,
}

capture_state_snapshot :: proc(state: Simulation_State, selected_object_id: Object_ID) -> State_Snapshot {
	return State_Snapshot {
		selected_object_id = selected_object_id,
		view = simulation_view(state),
	}
}

diff_state_snapshots :: proc(before, after: State_Snapshot) -> State_Snapshot_Diff {
	before_ship := before.view.player_ship
	after_ship := after.view.player_ship

	return State_Snapshot_Diff {
		selected_object_id = after.selected_object_id,
		selected_object_changed = before.selected_object_id != after.selected_object_id,
		position_changed = before_ship.position != after_ship.position,
		heading_changed = before_ship.heading != after_ship.heading,
		velocity_changed = before_ship.velocity != after_ship.velocity,
		before_position = before_ship.position,
		after_position = after_ship.position,
		before_heading = before_ship.heading,
		after_heading = after_ship.heading,
		before_velocity = before_ship.velocity,
		after_velocity = after_ship.velocity,
	}
}
