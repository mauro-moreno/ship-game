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
	testing.expect(t, render_pass_enabled(debug_view.pass_toggles, .World))
}
