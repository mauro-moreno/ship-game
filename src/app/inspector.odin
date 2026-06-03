package main

import "core:c"
import "core:fmt"
import game "ship:game"
import rl "vendor:raylib"

INSPECTOR_X :: f32(16)
INSPECTOR_Y :: f32(54)
INSPECTOR_WIDTH :: f32(760)
INSPECTOR_HEIGHT :: f32(420)
INSPECTOR_PADDING :: f32(12)
INSPECTOR_ROW_HEIGHT :: f32(26)
INSPECTOR_BUTTON_WIDTH :: f32(86)
INSPECTOR_BUTTON_HEIGHT :: f32(24)
INSPECTOR_BUTTON_GAP :: f32(8)

read_inspector_overlay_command :: proc(view: game.Inspector_Overlay_View) -> game.Debug_Command {
	if view.build_mode != .Dev || !game.render_pass_enabled(view.render_debug.pass_toggles, .Inspector) {
		return game.NO_DEBUG_COMMAND
	}
	if !rl.IsMouseButtonPressed(.LEFT) {
		return game.NO_DEBUG_COMMAND
	}

	mouse := rl.GetMousePosition()

	if point_hits(mouse, pause_button_rect()) {
		return game.debug_pause_command()
	}
	if point_hits(mouse, resume_button_rect()) {
		return game.debug_resume_command()
	}
	if point_hits(mouse, step_button_rect()) {
		return game.debug_step_frame_command()
	}
	if point_hits(mouse, hitbox_button_rect()) {
		return game.debug_toggle_selected_hitbox_command()
	}
	if point_hits(mouse, velocity_button_rect()) {
		return game.debug_toggle_selected_velocity_vector_command()
	}
	if point_hits(mouse, trace_object_filter_button_rect()) {
		return game.debug_toggle_trace_object_filter_command()
	}
	if point_hits(mouse, trace_frame_filter_button_rect()) {
		return game.debug_toggle_trace_frame_range_filter_command()
	}
	if point_hits(mouse, trace_kind_filter_button_rect()) {
		return game.debug_toggle_trace_event_kind_filter_command(.Ship_Moved)
	}
	if point_hits(mouse, breakpoint_event_button_rect()) {
		return game.debug_toggle_break_on_event_kind_command(.Ship_Moved)
	}
	if point_hits(mouse, breakpoint_invariant_button_rect()) {
		return game.debug_toggle_break_on_invariant_failure_command()
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

draw_inspector_overlay :: proc(view: game.Inspector_Overlay_View) {
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
	draw_inspector_line(fmt.ctprintf("passes 1:bg=%v 2:world=%v 3:debug=%v 4:inspector=%v", toggles.background, toggles.world, toggles.debug, toggles.inspector), 264)

	draw_button(pause_button_rect(), "Pause")
	draw_button(resume_button_rect(), "Resume")
	draw_button(step_button_rect(), "Step")
	draw_button(hitbox_button_rect(), fmt.ctprintf("Hitbox %s", on_off_text(debug_view.ship_debug_visuals.hitbox)))
	draw_button(velocity_button_rect(), fmt.ctprintf("Vector %s", on_off_text(debug_view.ship_debug_visuals.velocity_vector)))
	draw_button(trace_object_filter_button_rect(), fmt.ctprintf("Obj %s", on_off_text(view.trace_filter.use_object_id)))
	draw_button(trace_frame_filter_button_rect(), fmt.ctprintf("Frame %s", on_off_text(view.trace_filter.use_frame_range)))
	draw_button(trace_kind_filter_button_rect(), fmt.ctprintf("Kind %s", on_off_text(view.trace_filter.use_event_kind)))
	draw_button(breakpoint_event_button_rect(), fmt.ctprintf("Brk Move %s", on_off_text(view.frame_breakpoints.pause_on_event_kind)))
	draw_button(breakpoint_invariant_button_rect(), fmt.ctprintf("Brk Inv %s", on_off_text(view.frame_breakpoints.pause_on_invariant_failure)))

	rl.DrawText("Scenario Browser", c.int(INSPECTOR_X + INSPECTOR_PADDING), 392, 16, rl.RAYWHITE)
	for index in 0..<view.scenarios.count {
		draw_scenario_browser_row(view.scenarios.items[index], index)
	}
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

pause_button_rect :: proc() -> rl.Rectangle {
	return inspector_button_rect(0, 288)
}

resume_button_rect :: proc() -> rl.Rectangle {
	return inspector_button_rect(1, 288)
}

step_button_rect :: proc() -> rl.Rectangle {
	return inspector_button_rect(2, 288)
}

hitbox_button_rect :: proc() -> rl.Rectangle {
	return inspector_button_rect(0, 318)
}

velocity_button_rect :: proc() -> rl.Rectangle {
	return inspector_button_rect(1, 318)
}

trace_object_filter_button_rect :: proc() -> rl.Rectangle {
	return inspector_button_rect(0, 348)
}

trace_frame_filter_button_rect :: proc() -> rl.Rectangle {
	return inspector_button_rect(1, 348)
}

trace_kind_filter_button_rect :: proc() -> rl.Rectangle {
	return inspector_button_rect(2, 348)
}

breakpoint_event_button_rect :: proc() -> rl.Rectangle {
	return inspector_button_rect(3, 348)
}

breakpoint_invariant_button_rect :: proc() -> rl.Rectangle {
	return inspector_button_rect(4, 348)
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
	return 416 + f32(index) * INSPECTOR_ROW_HEIGHT
}

on_off_text :: proc(enabled: bool) -> cstring {
	if enabled {
		return "on"
	}

	return "off"
}
