package main

import "core:c"
import "core:fmt"
import "core:math"
import game "ship:game"
import rl "vendor:raylib"

SHIP_FORWARD_LENGTH_PIXELS :: f32(34)
SHIP_REAR_LENGTH_PIXELS :: f32(18)
SHIP_HALF_WIDTH_PIXELS :: f32(16)
VELOCITY_VECTOR_SCALE_PIXELS :: f32(52)

App_Render_Timing :: struct {
	pipeline_us:  u64,
	pass_timings: game.Render_Pass_Timings,
}

render_frame :: proc(overlay_view: game.Inspector_Overlay_View, console_text, console_feedback: string) -> App_Render_Timing {
	debug_view := overlay_view.render_debug
	timing := App_Render_Timing {
		pass_timings = game.initial_render_pass_timings(),
	}
	pipeline_start := f64(0)
	when game.CONFIGURED_BUILD_MODE_NAME != "release" {
		pipeline_start = timing_now_seconds()
	}

	rl.BeginDrawing()

	rl.ClearBackground(rl.BLACK)

	if game.render_pass_enabled(debug_view.pass_toggles, .Background) {
		pass_start := f64(0)
		when game.CONFIGURED_BUILD_MODE_NAME != "release" {
			pass_start = timing_now_seconds()
		}
		draw_background_pass(debug_view.camera)
		when game.CONFIGURED_BUILD_MODE_NAME != "release" {
			game.record_render_pass_timing(&timing.pass_timings, .Background, elapsed_us_since(pass_start))
		}
	}
	if game.render_pass_enabled(debug_view.pass_toggles, .World) {
		pass_start := f64(0)
		when game.CONFIGURED_BUILD_MODE_NAME != "release" {
			pass_start = timing_now_seconds()
		}
		draw_world_pass(debug_view)
		when game.CONFIGURED_BUILD_MODE_NAME != "release" {
			game.record_render_pass_timing(&timing.pass_timings, .World, elapsed_us_since(pass_start))
		}
	}
	if game.render_pass_enabled(debug_view.pass_toggles, .Debug) {
		pass_start := f64(0)
		when game.CONFIGURED_BUILD_MODE_NAME != "release" {
			pass_start = timing_now_seconds()
		}
		draw_debug_pass(debug_view)
		when game.CONFIGURED_BUILD_MODE_NAME != "release" {
			game.record_render_pass_timing(&timing.pass_timings, .Debug, elapsed_us_since(pass_start))
		}
	}

	when game.CONFIGURED_BUILD_MODE_NAME == "dev" {
		if overlay_view.build_mode == .Dev && game.render_pass_enabled(debug_view.pass_toggles, .Inspector) {
			pass_start := timing_now_seconds()
			draw_inspector_overlay(overlay_view, console_text, console_feedback)
			game.record_render_pass_timing(&timing.pass_timings, .Inspector, elapsed_us_since(pass_start))
		}
	}

	rl.EndDrawing()

	when game.CONFIGURED_BUILD_MODE_NAME != "release" {
		timing.pipeline_us = elapsed_us_since(pipeline_start)
	}

	return timing
}

draw_background_pass :: proc(camera: game.Camera_State) {
	viewport := current_render_viewport()
	center := game.render_viewport_center(viewport)
	grid_color := rl.DARKGRAY

	for offset in -24..<25 {
		world_x := camera.target.x + f32(offset)
		start := game.render_world_to_screen(camera, viewport, game.Vec2{x = world_x, y = camera.target.y - 24})
		end := game.render_world_to_screen(camera, viewport, game.Vec2{x = world_x, y = camera.target.y + 24})
		draw_line(start, end, grid_color)
	}

	for offset in -16..<17 {
		world_y := camera.target.y + f32(offset)
		start := game.render_world_to_screen(camera, viewport, game.Vec2{x = camera.target.x - 24, y = world_y})
		end := game.render_world_to_screen(camera, viewport, game.Vec2{x = camera.target.x + 24, y = world_y})
		draw_line(start, end, grid_color)
	}

	rl.DrawText("SHIP GAME - Debuggable Skeleton", 24, 24, 24, rl.RAYWHITE)
	draw_line(game.Vec2{x = center.x - 10, y = center.y}, game.Vec2{x = center.x + 10, y = center.y}, rl.GRAY)
	draw_line(game.Vec2{x = center.x, y = center.y - 10}, game.Vec2{x = center.x, y = center.y + 10}, rl.GRAY)
}

draw_world_pass :: proc(debug_view: game.Render_Debug_View) {
	ship := debug_view.player_ship
	viewport := current_render_viewport()
	center := game.render_world_to_screen(debug_view.camera, viewport, ship.position)
	forward := game.Vec2{x = math.cos(ship.heading), y = math.sin(ship.heading)}
	side := game.Vec2{x = -forward.y, y = forward.x}

	tip := vec2_add(center, vec2_scale(forward, SHIP_FORWARD_LENGTH_PIXELS))
	rear := vec2_add(center, vec2_scale(forward, -SHIP_REAR_LENGTH_PIXELS))
	left := vec2_add(rear, vec2_scale(side, SHIP_HALF_WIDTH_PIXELS))
	right := vec2_add(rear, vec2_scale(side, -SHIP_HALF_WIDTH_PIXELS))

	rl.DrawTriangle(to_rl_vec2(tip), to_rl_vec2(right), to_rl_vec2(left), rl.SKYBLUE)
	outline_color := rl.RAYWHITE
	label := fmt.ctprintf("Object %v", u32(ship.id))
	if ship.id == debug_view.selected_object_id {
		outline_color = rl.YELLOW
		label = fmt.ctprintf("Object %v selected", u32(ship.id))
	}
	rl.DrawTriangleLines(to_rl_vec2(tip), to_rl_vec2(right), to_rl_vec2(left), outline_color)

	label_pos := vec2_add(center, game.Vec2{x = 22, y = -38})
	rl.DrawText(label, c.int(label_pos.x), c.int(label_pos.y), 16, outline_color)
}

draw_debug_pass :: proc(debug_view: game.Render_Debug_View) {
	ship := debug_view.player_ship
	if ship.id != debug_view.selected_object_id {
		return
	}

	viewport := current_render_viewport()
	center := game.render_world_to_screen(debug_view.camera, viewport, ship.position)

	if debug_view.ship_debug_visuals.hitbox {
		hitbox_width := ship.hitbox.half_width * 2
		hitbox_height := ship.hitbox.half_height * 2
		rl.DrawRectangleLines(
			c.int(center.x - ship.hitbox.half_width),
			c.int(center.y - ship.hitbox.half_height),
			c.int(hitbox_width),
			c.int(hitbox_height),
			rl.YELLOW,
		)
	}

	if debug_view.ship_debug_visuals.velocity_vector {
		velocity_end := vec2_add(center, vec2_scale(ship.velocity, VELOCITY_VECTOR_SCALE_PIXELS * debug_view.camera.zoom))
		draw_line(center, velocity_end, rl.GREEN)
		rl.DrawText("velocity", c.int(velocity_end.x + 6), c.int(velocity_end.y - 8), 12, rl.GREEN)
	}
}

vec2_add :: proc(a, b: game.Vec2) -> game.Vec2 {
	return game.Vec2{x = a.x + b.x, y = a.y + b.y}
}

vec2_scale :: proc(v: game.Vec2, scale: f32) -> game.Vec2 {
	return game.Vec2{x = v.x * scale, y = v.y * scale}
}

draw_line :: proc(start, end: game.Vec2, color: rl.Color) {
	rl.DrawLine(c.int(start.x), c.int(start.y), c.int(end.x), c.int(end.y), color)
}

to_rl_vec2 :: proc(v: game.Vec2) -> rl.Vector2 {
	return rl.Vector2{v.x, v.y}
}

current_render_viewport :: proc() -> game.Render_Viewport {
	return game.render_viewport(f32(rl.GetScreenWidth()), f32(rl.GetScreenHeight()))
}
