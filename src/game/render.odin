package game

DEFAULT_CAMERA_ZOOM :: f32(1)
DEFAULT_WORLD_PIXELS_PER_UNIT :: f32(32)
RENDER_PASS_COUNT :: 4

Render_Pass :: enum {
	Background,
	World,
	Debug,
	Inspector,
}

Render_Pass_Registration :: struct {
	pass:            Render_Pass,
	label:           string,
	short_label:     string,
	artifact_key:    string,
	default_enabled: bool,
	dev_only:        bool,
}

render_pass_registry :: proc() -> [RENDER_PASS_COUNT]Render_Pass_Registration {
	return [RENDER_PASS_COUNT]Render_Pass_Registration {
		Render_Pass_Registration{pass = .Background, label = "Background", short_label = "bg", artifact_key = "background", default_enabled = true},
		Render_Pass_Registration{pass = .World, label = "World", short_label = "world", artifact_key = "world", default_enabled = true},
		Render_Pass_Registration{pass = .Debug, label = "Debug", short_label = "debug", artifact_key = "debug", default_enabled = true},
		Render_Pass_Registration{pass = .Inspector, label = "Inspector", short_label = "inspector", artifact_key = "inspector", default_enabled = true, dev_only = true},
	}
}

Render_Pass_Toggles :: struct {
	enabled: [RENDER_PASS_COUNT]bool,
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
	toggles: Render_Pass_Toggles
	registry := render_pass_registry()
	for i in 0..<RENDER_PASS_COUNT {
		toggles.enabled[i] = registry[i].default_enabled
	}

	return toggles
}

default_ship_debug_visual_toggles :: proc() -> Ship_Debug_Visual_Toggles {
	return Ship_Debug_Visual_Toggles {
		hitbox = true,
		velocity_vector = true,
	}
}

render_pass_enabled :: proc(toggles: Render_Pass_Toggles, pass: Render_Pass) -> bool {
	if index, ok := render_pass_index(pass); ok {
		return toggles.enabled[index]
	}

	return false
}

set_render_pass_enabled :: proc(toggles: ^Render_Pass_Toggles, pass: Render_Pass, enabled: bool) {
	if index, ok := render_pass_index(pass); ok {
		toggles.enabled[index] = enabled
	}
}

toggle_render_pass :: proc(toggles: ^Render_Pass_Toggles, pass: Render_Pass) {
	set_render_pass_enabled(toggles, pass, !render_pass_enabled(toggles^, pass))
}

toggle_render_pass_by_index :: proc(toggles: ^Render_Pass_Toggles, index: int) {
	if pass, ok := render_pass_at(index); ok {
		toggle_render_pass(toggles, pass)
	}
}

render_pass_count :: proc() -> int {
	return RENDER_PASS_COUNT
}

render_pass_at :: proc(index: int) -> (Render_Pass, bool) {
	if registration, ok := render_pass_registration_at(index); ok {
		return registration.pass, true
	}

	return .Background, false
}

render_pass_registration_at :: proc(index: int) -> (Render_Pass_Registration, bool) {
	if index < 0 || index >= RENDER_PASS_COUNT {
		return {}, false
	}

	registry := render_pass_registry()
	return registry[index], true
}

render_pass_registration :: proc(pass: Render_Pass) -> (Render_Pass_Registration, bool) {
	registry := render_pass_registry()
	for i in 0..<RENDER_PASS_COUNT {
		registration := registry[i]
		if registration.pass == pass {
			return registration, true
		}
	}

	return {}, false
}

render_pass_index :: proc(pass: Render_Pass) -> (int, bool) {
	registry := render_pass_registry()
	for i in 0..<RENDER_PASS_COUNT {
		if registry[i].pass == pass {
			return i, true
		}
	}

	return 0, false
}

render_pass_label :: proc(pass: Render_Pass) -> string {
	if registration, ok := render_pass_registration(pass); ok {
		return registration.label
	}

	return ""
}

render_pass_short_label :: proc(pass: Render_Pass) -> string {
	if registration, ok := render_pass_registration(pass); ok {
		return registration.short_label
	}

	return ""
}

render_pass_artifact_key :: proc(pass: Render_Pass) -> string {
	if registration, ok := render_pass_registration(pass); ok {
		return registration.artifact_key
	}

	return ""
}

render_pass_default_enabled :: proc(pass: Render_Pass) -> bool {
	if registration, ok := render_pass_registration(pass); ok {
		return registration.default_enabled
	}

	return false
}

render_pass_available_in_build_mode :: proc(pass: Render_Pass, mode: Build_Mode) -> bool {
	if registration, ok := render_pass_registration(pass); ok {
		return !registration.dev_only || mode == .Dev
	}

	return false
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
