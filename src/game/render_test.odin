package game

import "core:testing"

@(test)
test_camera_follows_player_ship_without_smoothing :: proc(t: ^testing.T) {
	state := initial_simulation_state()
	state.ship.position = Vec2{x = 12.5, y = -3.25}

	view := simulation_view(state)
	camera := camera_follow_player(view)

	testing.expect_value(t, camera.target, view.player_ship.position)
	testing.expect_value(t, camera.zoom, DEFAULT_CAMERA_ZOOM)

	moved := step_simulation(state, Control_Intent{forward_thrust = true})
	moved_view := simulation_view(moved)
	moved_camera := camera_follow_player(moved_view)

	testing.expect_value(t, moved_camera.target, moved_view.player_ship.position)
}

@(test)
test_initial_render_passes_are_named_enabled_and_toggleable :: proc(t: ^testing.T) {
	toggles := default_render_pass_toggles()

	testing.expect(t, render_pass_enabled(toggles, .Background))
	testing.expect(t, render_pass_enabled(toggles, .World))
	testing.expect(t, render_pass_enabled(toggles, .Debug))
	testing.expect(t, render_pass_enabled(toggles, .Inspector))

	toggle_render_pass(&toggles, .Debug)
	testing.expect(t, !render_pass_enabled(toggles, .Debug))

	toggle_render_pass(&toggles, .Debug)
	testing.expect(t, render_pass_enabled(toggles, .Debug))
}

@(test)
test_render_debug_view_exposes_player_ship_inspection_data :: proc(t: ^testing.T) {
	state := initial_simulation_state()
	state.ship.position = Vec2{x = 4, y = 7}
	state.ship.heading = 1.25
	state.ship.velocity = Vec2{x = 0.5, y = -0.25}
	state.ship.hitbox = Ship_Hitbox{half_width = 9, half_height = 14}

	toggles := default_render_pass_toggles()
	debug_view := render_debug_view(simulation_view(state), toggles)

	testing.expect_value(t, debug_view.frame, state.frame)
	testing.expect_value(t, debug_view.camera.target, state.ship.position)
	testing.expect_value(t, debug_view.camera.zoom, DEFAULT_CAMERA_ZOOM)
	testing.expect_value(t, debug_view.player_ship.id, state.ship.id)
	testing.expect_value(t, debug_view.player_ship.position, state.ship.position)
	testing.expect_value(t, debug_view.player_ship.heading, state.ship.heading)
	testing.expect_value(t, debug_view.player_ship.velocity, state.ship.velocity)
	testing.expect_value(t, debug_view.player_ship.hitbox, state.ship.hitbox)
	testing.expect_value(t, debug_view.player_ship.speed, vec2_length(state.ship.velocity))
	testing.expect_value(t, debug_view.player_ship.max_speed, state.ship.movement.max_speed)
	testing.expect(t, render_pass_enabled(debug_view.pass_toggles, .World))
}

@(test)
test_ship_debug_visual_toggles_can_isolate_selected_hitbox_and_velocity :: proc(t: ^testing.T) {
	visuals := default_ship_debug_visual_toggles()

	testing.expect(t, visuals.hitbox)
	testing.expect(t, visuals.velocity_vector)

	toggle_ship_debug_hitbox(&visuals)
	testing.expect(t, !visuals.hitbox)

	toggle_ship_debug_velocity_vector(&visuals)
	testing.expect(t, !visuals.velocity_vector)
}

@(test)
test_render_debug_view_tracks_selected_object_id :: proc(t: ^testing.T) {
	state := initial_simulation_state()
	state.ship.velocity = Vec2{x = 3, y = 4}
	toggles := default_render_pass_toggles()
	visuals := default_ship_debug_visual_toggles()

	debug_view := render_debug_view_with_selection(simulation_view(state), toggles, Object_ID(1), visuals)

	testing.expect_value(t, debug_view.selected_object_id, Object_ID(1))
	testing.expect_value(t, debug_view.ship_debug_visuals, visuals)
	testing.expect_value(t, debug_view.player_ship.speed, f32(5))
}

@(test)
test_picking_visible_ship_uses_camera_world_to_screen_transform :: proc(t: ^testing.T) {
	state := initial_simulation_state()
	state.ship.position = Vec2{x = 5, y = -2}
	state.ship.hitbox = Ship_Hitbox{half_width = 9, half_height = 14}
	view := simulation_view(state)
	camera := Camera_State{target = Vec2{x = 1, y = -3}, zoom = 2}
	viewport := render_viewport(1280, 720)
	debug_view := render_debug_view_with_selection(view, default_render_pass_toggles(), Object_ID(1), default_ship_debug_visual_toggles())
	debug_view.camera = camera

	screen_position := render_world_to_screen(camera, viewport, state.ship.position)
	picked_id, picked := pick_ship_at_screen_point(debug_view, viewport, screen_position)
	missed_id, missed := pick_ship_at_screen_point(debug_view, viewport, Vec2{x = screen_position.x + 100, y = screen_position.y + 100})

	testing.expect(t, picked)
	testing.expect_value(t, picked_id, Object_ID(1))
	testing.expect(t, !missed)
	testing.expect_value(t, missed_id, Object_ID(0))
}
