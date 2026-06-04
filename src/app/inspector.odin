package main

import "core:c"
import "core:fmt"
import "core:strings"
import game "ship:game"
import rl "vendor:raylib"

INSPECTOR_X :: f32(16)
INSPECTOR_Y :: f32(54)
INSPECTOR_WIDTH :: f32(760)
INSPECTOR_HEIGHT :: f32(600)
INSPECTOR_PADDING :: f32(12)
INSPECTOR_ROW_HEIGHT :: f32(26)
INSPECTOR_BUTTON_WIDTH :: f32(86)
INSPECTOR_BUTTON_HEIGHT :: f32(24)
INSPECTOR_BUTTON_GAP :: f32(8)
INSPECTOR_CONTROL_START_Y :: f32(398)
INSPECTOR_CONTROL_ROW_GAP :: f32(30)

update_debug_text_console :: proc(state: ^App_State) -> game.Debug_Command {
	when game.CONFIGURED_BUILD_MODE_NAME != "dev" {
		return game.NO_DEBUG_COMMAND
	}

	for {
		ch := rl.GetCharPressed()
		if ch == 0 {
			break
		}

		if ch >= 32 && ch <= 126 && state.debug_console_length < DEBUG_CONSOLE_INPUT_CAPACITY {
			state.debug_console_input[state.debug_console_length] = u8(ch)
			state.debug_console_length += 1
		}
	}

	if rl.IsKeyPressed(.BACKSPACE) && state.debug_console_length > 0 {
		state.debug_console_length -= 1
		state.debug_console_input[state.debug_console_length] = 0
	}

	if rl.IsKeyPressed(.ENTER) || rl.IsKeyPressed(.KP_ENTER) {
		result := game.parse_debug_text_command(debug_console_text(state))
		state.debug_console_feedback = result.feedback
		clear_debug_console(state)
		return result.command
	}

	return game.NO_DEBUG_COMMAND
}

read_inspector_overlay_control_command :: proc(state: ^App_State, view: game.Inspector_Overlay_View) -> game.Debug_Command {
	command := update_debug_text_console(state)
	if command.kind != .None {
		return command
	}

	command = read_inspector_overlay_panel_command(view)
	if command.kind != .None {
		return command
	}

	return read_object_picking_command(view)
}

read_inspector_overlay_panel_command :: proc(view: game.Inspector_Overlay_View) -> game.Debug_Command {
	if view.build_mode != .Dev || !game.render_pass_enabled(view.render_debug.pass_toggles, .Inspector) {
		return game.NO_DEBUG_COMMAND
	}
	if !rl.IsMouseButtonPressed(.LEFT) {
		return game.NO_DEBUG_COMMAND
	}

	mouse := rl.GetMousePosition()

	for control_index in 0..<game.inspector_overlay_control_count() {
		control, ok := game.inspector_overlay_control_at(control_index)
		if ok && point_hits(mouse, inspector_control_button_rect(control)) {
			return game.inspector_overlay_control_command(control.id)
		}
	}

	for index in 0..<view.scenarios.count {
		item := view.scenarios.items[index]
		if point_hits(mouse, scenario_run_button_rect(index)) {
			return game.debug_run_scenario_command(item.id)
		}
		if point_hits(mouse, scenario_restart_button_rect(index)) {
			return game.debug_restart_scenario_command(item.id)
		}
	}

	return game.NO_DEBUG_COMMAND
}

read_object_picking_command :: proc(view: game.Inspector_Overlay_View) -> game.Debug_Command {
	if view.build_mode != .Dev || !rl.IsMouseButtonPressed(.LEFT) {
		return game.NO_DEBUG_COMMAND
	}

	mouse := rl.GetMousePosition()
	if point_hits(mouse, inspector_panel_rect()) {
		return game.NO_DEBUG_COMMAND
	}

	screen_point := game.Vec2{x = mouse[0], y = mouse[1]}
	if picked_id, picked := game.pick_ship_at_screen_point(view.render_debug, current_render_viewport(), screen_point); picked {
		return game.debug_select_object_command(picked_id)
	}

	return game.NO_DEBUG_COMMAND
}

draw_inspector_overlay :: proc(view: game.Inspector_Overlay_View, console_text, console_feedback: string) {
	debug_view := view.render_debug
	toggles := debug_view.pass_toggles
	ship := debug_view.player_ship
	camera := debug_view.camera

	panel := inspector_panel_rect()
	rl.DrawRectangleRec(panel, rl.Fade(rl.BLACK, 0.82))
	rl.DrawRectangleLines(c.int(panel.x), c.int(panel.y), c.int(panel.width), c.int(panel.height), rl.DARKGRAY)

	draw_inspector_line(fmt.ctprintf("build=%v scenario=%v seed=%v frame=%v status=%s", view.build_mode, string(view.scenario_id), u64(view.scenario_seed), u64(view.frame), runtime_status_text(view.paused)), 66)
	draw_inspector_line(fmt.ctprintf("selected Object ID=%v speed=%v/%v pos=(%v,%v)", u32(view.selected_object_id), ship.speed, ship.max_speed, ship.position.x, ship.position.y), 88)
	draw_inspector_line(fmt.ctprintf("heading=%v velocity=(%v,%v) hitbox=(%v,%v)", ship.heading, ship.velocity.x, ship.velocity.y, ship.hitbox.half_width, ship.hitbox.half_height), 110)
	draw_inspector_line(fmt.ctprintf("camera target=(%v,%v) zoom=%v", camera.target.x, camera.target.y, camera.zoom), 132)
	draw_invariant_line(view)
	draw_inspector_line(fmt.ctprintf("snapshot selected_changed=%v pos=%v heading=%v velocity=%v", view.snapshot_diff.selected_object_changed, view.snapshot_diff.position_changed, view.snapshot_diff.heading_changed, view.snapshot_diff.velocity_changed), 176)
	draw_trace_filter_line(view)
	draw_filtered_trace_line(view)
	draw_breakpoint_line(view)
	draw_performance_timing_lines(view)
	draw_render_pass_toggle_line(toggles, 374)

	draw_inspector_overlay_controls(view)

	rl.DrawText("Scenario Browser", c.int(INSPECTOR_X + INSPECTOR_PADDING), 500, 16, rl.RAYWHITE)
	for index in 0..<view.scenarios.count {
		draw_scenario_browser_row(view.scenarios.items[index], index)
	}

	draw_debug_console(console_text, console_feedback, view)
}

draw_invariant_line :: proc(view: game.Inspector_Overlay_View) {
	status := "ok"
	if !view.invariant_report.ok {
		status = "failed"
	}

	draw_inspector_line(fmt.ctprintf("invariants=%s failures=%v", status, view.invariant_report.failure_count), 154)
}

draw_trace_filter_line :: proc(view: game.Inspector_Overlay_View) {
	filter := view.trace_filter
	draw_inspector_line(fmt.ctprintf("trace filter object=%v(%v) frame=%v..%v(%v) kind=%v(%v)", u32(filter.object_id), filter.use_object_id, u64(filter.frame_start), u64(filter.frame_end), filter.use_frame_range, filter.event_kind, filter.use_event_kind), 198)
}

draw_filtered_trace_line :: proc(view: game.Inspector_Overlay_View) {
	if view.filtered_trace.count == 0 {
		draw_inspector_line("trace tail filtered count=0", 220)
		return
	}

	last := view.filtered_trace.entries[view.filtered_trace.count - 1]
	draw_inspector_line(fmt.ctprintf("trace tail filtered count=%v last=%v frame=%v object=%v", view.filtered_trace.count, last.kind, u64(last.frame), u32(last.object_id)), 220)
}

draw_breakpoint_line :: proc(view: game.Inspector_Overlay_View) {
	if view.breakpoint_match.matched {
		draw_inspector_line(fmt.ctprintf("breakpoint matched reason=%v event=%v invariant_failures=%v", view.breakpoint_match.reason, view.breakpoint_match.event.kind, view.breakpoint_match.invariant_report.failure_count), 242)
		return
	}

	draw_inspector_line("breakpoint matched=false", 242)
}

draw_performance_timing_lines :: proc(view: game.Inspector_Overlay_View) {
	timing := view.performance_timing
	if !timing.available {
		draw_inspector_line("timing unavailable", 264)
		return
	}

	entities := timing.entity_counts

	draw_inspector_line(fmt.ctprintf("timing fps=%v frame=%vms", timing.fps, timing.frame_time_ms), 264)
	draw_inspector_line(fmt.ctprintf("timing sim=%vus render=%vus", timing.simulation_step_us, timing.render_pipeline_us), 286)
	render_pass_rows := draw_render_pass_timing_lines(timing, 308)
	entities_y := 308 + render_pass_rows * 22
	draw_inspector_line(fmt.ctprintf("entities ships=%v bullets=%v gameplay=%v trace=%v", entities.ships, entities.bullets, entities.gameplay_objects, entities.trace_entries), c.int(entities_y))
}

draw_render_pass_toggle_line :: proc(toggles: game.Render_Pass_Toggles, y: c.int) {
	builder := strings.builder_make(context.temp_allocator)
	fmt.sbprintf(&builder, "passes")

	for i in 0..<game.render_pass_count() {
		pass, ok := game.render_pass_at(i)
		if !ok {
			continue
		}

		fmt.sbprintf(&builder, " %v:%s=%v", i + 1, game.render_pass_short_label(pass), game.render_pass_enabled(toggles, pass))
	}

	draw_inspector_line(fmt.ctprintf("%s", strings.to_string(builder)), y)
}

draw_render_pass_timing_lines :: proc(timing: game.Performance_Timing_View, first_y: int) -> int {
	row_count := (game.render_pass_count() + 1) / 2

	for row in 0..<row_count {
		left_index := row * 2
		right_index := left_index + 1
		left_pass, left_ok := game.render_pass_at(left_index)
		right_pass, right_ok := game.render_pass_at(right_index)
		y := c.int(first_y + row * 22)

		if left_ok && right_ok {
			draw_inspector_line(
				fmt.ctprintf(
					"pass %s=%vus %s=%vus",
					game.render_pass_short_label(left_pass),
					game.render_pass_timing_elapsed_us(timing, left_pass),
					game.render_pass_short_label(right_pass),
					game.render_pass_timing_elapsed_us(timing, right_pass),
				),
				y,
			)
		} else if left_ok {
			draw_inspector_line(
				fmt.ctprintf(
					"pass %s=%vus",
					game.render_pass_short_label(left_pass),
					game.render_pass_timing_elapsed_us(timing, left_pass),
				),
				y,
			)
		}
	}

	return row_count
}

draw_inspector_overlay_controls :: proc(view: game.Inspector_Overlay_View) {
	for control_index in 0..<game.inspector_overlay_control_count() {
		control, ok := game.inspector_overlay_control_at(control_index)
		if ok {
			draw_button(inspector_control_button_rect(control), inspector_control_button_label(control, view))
		}
	}
}

inspector_control_button_label :: proc(control: game.Inspector_Overlay_Control, view: game.Inspector_Overlay_View) -> cstring {
	switch control.id {
	case .Toggle_Selected_Hitbox:
		return fmt.ctprintf("%s %s", control.label, on_off_text(view.render_debug.ship_debug_visuals.hitbox))
	case .Toggle_Selected_Velocity_Vector:
		return fmt.ctprintf("%s %s", control.label, on_off_text(view.render_debug.ship_debug_visuals.velocity_vector))
	case .Toggle_Trace_Object_Filter:
		return fmt.ctprintf("%s %s", control.label, on_off_text(view.trace_filter.use_object_id))
	case .Toggle_Trace_Frame_Range_Filter:
		return fmt.ctprintf("%s %s", control.label, on_off_text(view.trace_filter.use_frame_range))
	case .Toggle_Trace_Event_Kind_Filter:
		return fmt.ctprintf("%s %s", control.label, on_off_text(view.trace_filter.use_event_kind))
	case .Toggle_Break_On_Event_Kind:
		return fmt.ctprintf("%s %s", control.label, on_off_text(view.frame_breakpoints.pause_on_event_kind))
	case .Toggle_Break_On_Invariant_Failure:
		return fmt.ctprintf("%s %s", control.label, on_off_text(view.frame_breakpoints.pause_on_invariant_failure))
	case .Pause, .Resume, .Step_Frame, .Export_Debug_Dump:
		return fmt.ctprintf("%s", control.label)
	}

	return fmt.ctprintf("%s", control.label)
}

draw_scenario_browser_row :: proc(item: game.Scenario_Browser_Item, index: int) {
	y := scenario_row_y(index)
	marker := " "
	if item.selected {
		marker = "*"
	}

	rl.DrawText(fmt.ctprintf("%s %v seed=%v", marker, string(item.id), u64(item.seed)), c.int(INSPECTOR_X + INSPECTOR_PADDING), c.int(y + 5), 15, rl.SKYBLUE)
	draw_button(scenario_run_button_rect(index), "Run")
	draw_button(scenario_restart_button_rect(index), "Restart")
}

draw_debug_console :: proc(console_text, feedback: string, view: game.Inspector_Overlay_View) {
	rl.DrawText("Text Command Console", c.int(INSPECTOR_X + INSPECTOR_PADDING), 558, 16, rl.RAYWHITE)
	draw_inspector_line(fmt.ctprintf("> %s", console_text), 582)
	draw_inspector_line(fmt.ctprintf("feedback: %s", feedback), 604)

	if view.build_mode == .Dev && view.breakpoint_match.matched {
		draw_inspector_line("commands: run/restart <scenario_id>, select 1, break event ship_moved, break invariant, dump", 626)
	}
}

draw_button :: proc(rect: rl.Rectangle, label: cstring) {
	fill := rl.Fade(rl.DARKGRAY, 0.92)
	if point_hits(rl.GetMousePosition(), rect) {
		fill = rl.Fade(rl.GRAY, 0.92)
	}

	rl.DrawRectangleRec(rect, fill)
	rl.DrawRectangleLines(c.int(rect.x), c.int(rect.y), c.int(rect.width), c.int(rect.height), rl.RAYWHITE)

	text_width := rl.MeasureText(label, 14)
	text_x := rect.x + (rect.width - f32(text_width)) * 0.5
	text_y := rect.y + (rect.height - 14) * 0.5
	rl.DrawText(label, c.int(text_x), c.int(text_y), 14, rl.RAYWHITE)
}

draw_inspector_line :: proc(text: cstring, y: c.int) {
	rl.DrawText(text, c.int(INSPECTOR_X + INSPECTOR_PADDING), y, 15, rl.SKYBLUE)
}

point_hits :: proc(point: rl.Vector2, rect: rl.Rectangle) -> bool {
	return rl.CheckCollisionPointRec(point, rect)
}

runtime_status_text :: proc(paused: bool) -> cstring {
	if paused {
		return "paused"
	}

	return "running"
}

inspector_panel_rect :: proc() -> rl.Rectangle {
	return rl.Rectangle {
		x = INSPECTOR_X,
		y = INSPECTOR_Y,
		width = INSPECTOR_WIDTH,
		height = INSPECTOR_HEIGHT,
	}
}

inspector_control_button_rect :: proc(control: game.Inspector_Overlay_Control) -> rl.Rectangle {
	return inspector_button_rect(
		control.button_column,
		INSPECTOR_CONTROL_START_Y + f32(control.button_row) * INSPECTOR_CONTROL_ROW_GAP,
	)
}

scenario_run_button_rect :: proc(index: int) -> rl.Rectangle {
	return rl.Rectangle {
		x = INSPECTOR_X + INSPECTOR_WIDTH - INSPECTOR_PADDING - INSPECTOR_BUTTON_WIDTH * 2 - INSPECTOR_BUTTON_GAP,
		y = scenario_row_y(index),
		width = INSPECTOR_BUTTON_WIDTH,
		height = INSPECTOR_BUTTON_HEIGHT,
	}
}

scenario_restart_button_rect :: proc(index: int) -> rl.Rectangle {
	return rl.Rectangle {
		x = INSPECTOR_X + INSPECTOR_WIDTH - INSPECTOR_PADDING - INSPECTOR_BUTTON_WIDTH,
		y = scenario_row_y(index),
		width = INSPECTOR_BUTTON_WIDTH,
		height = INSPECTOR_BUTTON_HEIGHT,
	}
}

inspector_button_rect :: proc(column: int, y: f32) -> rl.Rectangle {
	return rl.Rectangle {
		x = INSPECTOR_X + INSPECTOR_PADDING + f32(column) * (INSPECTOR_BUTTON_WIDTH + INSPECTOR_BUTTON_GAP),
		y = y,
		width = INSPECTOR_BUTTON_WIDTH,
		height = INSPECTOR_BUTTON_HEIGHT,
	}
}

scenario_row_y :: proc(index: int) -> f32 {
	return 524 + f32(index) * INSPECTOR_ROW_HEIGHT
}

on_off_text :: proc(enabled: bool) -> cstring {
	if enabled {
		return "on"
	}

	return "off"
}

clear_debug_console :: proc(state: ^App_State) {
	for i in 0..<state.debug_console_length {
		state.debug_console_input[i] = 0
	}
	state.debug_console_length = 0
}
