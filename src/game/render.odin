package game

DEFAULT_CAMERA_ZOOM :: f32(1)

Render_Pass :: enum {
	Background,
	World,
	Debug,
	Inspector,
}

Render_Pass_Toggles :: struct {
	background: bool,
	world:      bool,
	debug:     bool,
	inspector: bool,
}

Camera_State :: struct {
	target: Vec2,
	zoom:   f32,
}

Render_Debug_Ship_View :: struct {
	id:       Object_ID,
	position: Vec2,
	heading:  f32,
	velocity: Vec2,
	hitbox:   Ship_Hitbox,
}

Render_Debug_View :: struct {
	frame:        Frame_Step_Index,
	camera:       Camera_State,
	player_ship:  Render_Debug_Ship_View,
	pass_toggles: Render_Pass_Toggles,
}

default_render_pass_toggles :: proc() -> Render_Pass_Toggles {
	return Render_Pass_Toggles {
		background = true,
		world = true,
		debug = true,
		inspector = true,
	}
}

render_pass_enabled :: proc(toggles: Render_Pass_Toggles, pass: Render_Pass) -> bool {
	switch pass {
	case .Background:
		return toggles.background
	case .World:
		return toggles.world
	case .Debug:
		return toggles.debug
	case .Inspector:
		return toggles.inspector
	}

	return false
}

set_render_pass_enabled :: proc(toggles: ^Render_Pass_Toggles, pass: Render_Pass, enabled: bool) {
	switch pass {
	case .Background:
		toggles.background = enabled
	case .World:
		toggles.world = enabled
	case .Debug:
		toggles.debug = enabled
	case .Inspector:
		toggles.inspector = enabled
	}
}

toggle_render_pass :: proc(toggles: ^Render_Pass_Toggles, pass: Render_Pass) {
	set_render_pass_enabled(toggles, pass, !render_pass_enabled(toggles^, pass))
}

camera_follow_player :: proc(view: Simulation_View) -> Camera_State {
	return Camera_State {
		target = view.player_ship.position,
		zoom = DEFAULT_CAMERA_ZOOM,
	}
}

render_debug_view :: proc(view: Simulation_View, toggles: Render_Pass_Toggles) -> Render_Debug_View {
	return Render_Debug_View {
		frame = view.frame,
		camera = camera_follow_player(view),
		player_ship = Render_Debug_Ship_View {
			id = view.player_ship.id,
			position = view.player_ship.position,
			heading = view.player_ship.heading,
			velocity = view.player_ship.velocity,
			hitbox = view.player_ship.hitbox,
		},
		pass_toggles = toggles,
	}
}
