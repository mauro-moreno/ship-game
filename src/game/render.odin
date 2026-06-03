package game

DEFAULT_CAMERA_ZOOM :: f32(1)
DEFAULT_WORLD_PIXELS_PER_UNIT :: f32(32)

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

Ship_Debug_Visual_Toggles :: struct {
	hitbox:          bool,
	velocity_vector: bool,
}

Camera_State :: struct {
	target: Vec2,
	zoom:   f32,
}

Render_Viewport :: struct {
	width:           f32,
	height:          f32,
	pixels_per_unit: f32,
}

Render_Debug_Ship_View :: struct {
	id:       Object_ID,
	position: Vec2,
	heading:  f32,
	velocity: Vec2,
	hitbox:   Ship_Hitbox,
	speed:    f32,
	max_speed: f32,
}

Render_Debug_View :: struct {
	frame:              Frame_Step_Index,
	camera:             Camera_State,
	player_ship:        Render_Debug_Ship_View,
	selected_object_id: Object_ID,
	pass_toggles:       Render_Pass_Toggles,
	ship_debug_visuals: Ship_Debug_Visual_Toggles,
}

default_render_pass_toggles :: proc() -> Render_Pass_Toggles {
	return Render_Pass_Toggles {
		background = true,
		world = true,
		debug = true,
		inspector = true,
	}
}

default_ship_debug_visual_toggles :: proc() -> Ship_Debug_Visual_Toggles {
	return Ship_Debug_Visual_Toggles {
		hitbox = true,
		velocity_vector = true,
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

toggle_ship_debug_hitbox :: proc(toggles: ^Ship_Debug_Visual_Toggles) {
	toggles.hitbox = !toggles.hitbox
}

toggle_ship_debug_velocity_vector :: proc(toggles: ^Ship_Debug_Visual_Toggles) {
	toggles.velocity_vector = !toggles.velocity_vector
}

camera_follow_player :: proc(view: Simulation_View) -> Camera_State {
	return Camera_State {
		target = view.player_ship.position,
		zoom = DEFAULT_CAMERA_ZOOM,
	}
}

render_viewport :: proc(width, height: f32) -> Render_Viewport {
	return Render_Viewport {
		width = width,
		height = height,
		pixels_per_unit = DEFAULT_WORLD_PIXELS_PER_UNIT,
	}
}

render_viewport_center :: proc(viewport: Render_Viewport) -> Vec2 {
	return Vec2{x = viewport.width * 0.5, y = viewport.height * 0.5}
}

render_world_to_screen :: proc(camera: Camera_State, viewport: Render_Viewport, world: Vec2) -> Vec2 {
	center := render_viewport_center(viewport)
	scale := viewport.pixels_per_unit * camera.zoom

	return Vec2 {
		x = center.x + (world.x - camera.target.x) * scale,
		y = center.y + (world.y - camera.target.y) * scale,
	}
}

pick_ship_at_screen_point :: proc(debug_view: Render_Debug_View, viewport: Render_Viewport, screen_point: Vec2) -> (Object_ID, bool) {
	ship := debug_view.player_ship
	center := render_world_to_screen(debug_view.camera, viewport, ship.position)

	if screen_point.x >= center.x - ship.hitbox.half_width &&
	   screen_point.x <= center.x + ship.hitbox.half_width &&
	   screen_point.y >= center.y - ship.hitbox.half_height &&
	   screen_point.y <= center.y + ship.hitbox.half_height {
		return ship.id, true
	}

	return Object_ID(0), false
}

render_debug_view :: proc(view: Simulation_View, toggles: Render_Pass_Toggles) -> Render_Debug_View {
	return render_debug_view_with_selection(view, toggles, view.player_ship.id, default_ship_debug_visual_toggles())
}

render_debug_view_with_selection :: proc(
	view: Simulation_View,
	toggles: Render_Pass_Toggles,
	selected_object_id: Object_ID,
	ship_debug_visuals: Ship_Debug_Visual_Toggles,
) -> Render_Debug_View {
	return Render_Debug_View {
		frame = view.frame,
		camera = camera_follow_player(view),
		player_ship = Render_Debug_Ship_View {
			id = view.player_ship.id,
			position = view.player_ship.position,
			heading = view.player_ship.heading,
			velocity = view.player_ship.velocity,
			hitbox = view.player_ship.hitbox,
			speed = vec2_length(view.player_ship.velocity),
			max_speed = view.player_ship.max_speed,
		},
		selected_object_id = selected_object_id,
		pass_toggles = toggles,
		ship_debug_visuals = ship_debug_visuals,
	}
}
