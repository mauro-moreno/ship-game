package main

import "core:c"
import "core:fmt"
import "core:math"
import game "ship:game"
import rl "vendor:raylib"

WORLD_PIXELS_PER_UNIT :: f32(32)
SHIP_FORWARD_LENGTH_PIXELS :: f32(34)
SHIP_REAR_LENGTH_PIXELS :: f32(18)
SHIP_HALF_WIDTH_PIXELS :: f32(16)
VELOCITY_VECTOR_SCALE_PIXELS :: f32(52)

render_frame :: proc(overlay_view: game.Inspector_Overlay_View) {
	debug_view := overlay_view.render_debug

	rl.BeginDrawing()
	defer rl.EndDrawing()

	rl.ClearBackground(rl.BLACK)

	if game.render_pass_enabled(debug_view.pass_toggles, .Background) {
		draw_background_pass(debug_view.camera)
	}
	if game.render_pass_enabled(debug_view.pass_toggles, .World) {
		draw_world_pass(debug_view)
	}
	if game.render_pass_enabled(debug_view.pass_toggles, .Debug) {
		draw_debug_pass(debug_view)
	}

	when game.CONFIGURED_BUILD_MODE_NAME == "dev" {
		if overlay_view.build_mode == .Dev && game.render_pass_enabled(debug_view.pass_toggles, .Inspector) {
			draw_inspector_overlay(overlay_view)
		}
	}
}

draw_background_pass :: proc(camera: game.Camera_State) {
	center := screen_center()
	grid_color := rl.DARKGRAY

	for offset in -24..<25 {
		world_x := camera.target.x + f32(offset)
		start := world_to_screen(camera, game.Vec2{x = world_x, y = camera.target.y - 24})
		end := world_to_screen(camera, game.Vec2{x = world_x, y = camera.target.y + 24})
		draw_line(start, end, grid_color)
	}

	for offset in -16..<17 {
		world_y := camera.target.y + f32(offset)
		start := world_to_screen(camera, game.Vec2{x = camera.target.x - 24, y = world_y})
		end := world_to_screen(camera, game.Vec2{x = camera.target.x + 24, y = world_y})
		draw_line(start, end, grid_color)
	}

	rl.DrawText("SHIP GAME - Debuggable Skeleton", 24, 24, 24, rl.RAYWHITE)
	draw_line(game.Vec2{x = center.x - 10, y = center.y}, game.Vec2{x = center.x + 10, y = center.y}, rl.GRAY)
	draw_line(game.Vec2{x = center.x, y = center.y - 10}, game.Vec2{x = center.x, y = center.y + 10}, rl.GRAY)
}

draw_world_pass :: proc(debug_view: game.Render_Debug_View) {
	ship := debug_view.player_ship
	center := world_to_screen(debug_view.camera, ship.position)
	forward := game.Vec2{x = math.cos(ship.heading), y = math.sin(ship.heading)}
	side := game.Vec2{x = -forward.y, y = forward.x}

	tip := vec2_add(center, vec2_scale(forward, SHIP_FORWARD_LENGTH_PIXELS))
	rear := vec2_add(center, vec2_scale(forward, -SHIP_REAR_LENGTH_PIXELS))
	left := vec2_add(rear, vec2_scale(side, SHIP_HALF_WIDTH_PIXELS))
	right := vec2_add(rear, vec2_scale(side, -SHIP_HALF_WIDTH_PIXELS))

	rl.DrawTriangle(to_rl_vec2(tip), to_rl_vec2(right), to_rl_vec2(left), rl.SKYBLUE)
	rl.DrawTriangleLines(to_rl_vec2(tip), to_rl_vec2(right), to_rl_vec2(left), rl.RAYWHITE)

	label_pos := vec2_add(center, game.Vec2{x = 22, y = -38})
	rl.DrawText(fmt.ctprintf("Object %v", u32(ship.id)), c.int(label_pos.x), c.int(label_pos.y), 16, rl.RAYWHITE)
}

draw_debug_pass :: proc(debug_view: game.Render_Debug_View) {
	ship := debug_view.player_ship
	center := world_to_screen(debug_view.camera, ship.position)

	hitbox_width := ship.hitbox.half_width * 2
	hitbox_height := ship.hitbox.half_height * 2
	rl.DrawRectangleLines(
		c.int(center.x - ship.hitbox.half_width),
		c.int(center.y - ship.hitbox.half_height),
		c.int(hitbox_width),
		c.int(hitbox_height),
		rl.YELLOW,
	)

	velocity_end := vec2_add(center, vec2_scale(ship.velocity, VELOCITY_VECTOR_SCALE_PIXELS * debug_view.camera.zoom))
	draw_line(center, velocity_end, rl.GREEN)
	rl.DrawText("velocity", c.int(velocity_end.x + 6), c.int(velocity_end.y - 8), 12, rl.GREEN)
}

world_to_screen :: proc(camera: game.Camera_State, world: game.Vec2) -> game.Vec2 {
	center := screen_center()
	scale := WORLD_PIXELS_PER_UNIT * camera.zoom

	return game.Vec2 {
		x = center.x + (world.x - camera.target.x) * scale,
		y = center.y + (world.y - camera.target.y) * scale,
	}
}

screen_center :: proc() -> game.Vec2 {
	return game.Vec2 {
		x = f32(rl.GetScreenWidth()) * 0.5,
		y = f32(rl.GetScreenHeight()) * 0.5,
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
