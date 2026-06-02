package game

import "core:math"

Object_ID :: distinct u32
Frame_Step_Index :: distinct u64

Vec2 :: struct {
	x: f32,
	y: f32,
}

Ship_Hitbox :: struct {
	half_width:  f32,
	half_height: f32,
}

Ship_Movement :: struct {
	thrust_acceleration: f32,
	reverse_acceleration: f32,
	turn_speed:          f32,
	damping:             f32,
	max_speed:           f32,
}

Ship_State :: struct {
	id:       Object_ID,
	position: Vec2,
	heading:  f32,
	velocity: Vec2,
	hitbox:   Ship_Hitbox,
	movement: Ship_Movement,
}

Simulation_State :: struct {
	frame: Frame_Step_Index,
	ship:  Ship_State,
}

Ship_View :: struct {
	id:        Object_ID,
	position:  Vec2,
	heading:   f32,
	velocity:  Vec2,
	hitbox:    Ship_Hitbox,
	max_speed: f32,
}

Simulation_View :: struct {
	frame:       Frame_Step_Index,
	player_ship: Ship_View,
}

Invariant_Report :: struct {
	ok:            bool,
	failure_count: int,
}

DEFAULT_SHIP_MOVEMENT :: Ship_Movement {
	thrust_acceleration = 0.25,
	reverse_acceleration = 0.12,
	turn_speed = 0.08,
	damping = 0.96,
	max_speed = 5.0,
}

initial_simulation_state :: proc() -> Simulation_State {
	return Simulation_State {
		frame = 0,
		ship = Ship_State {
			id = 1,
			position = {},
			heading = 0,
			velocity = {},
			hitbox = {half_width = 18, half_height = 28},
			movement = DEFAULT_SHIP_MOVEMENT,
		},
	}
}

simulation_view :: proc(state: Simulation_State) -> Simulation_View {
	return Simulation_View {
		frame = state.frame,
		player_ship = Ship_View {
			id = state.ship.id,
			position = state.ship.position,
			heading = state.ship.heading,
			velocity = state.ship.velocity,
			hitbox = state.ship.hitbox,
			max_speed = state.ship.movement.max_speed,
		},
	}
}

step_simulation :: proc(state: Simulation_State, intent: Control_Intent) -> Simulation_State {
	next := state
	next.frame = state.frame + 1

	if intent.turn_left {
		next.ship.heading -= next.ship.movement.turn_speed
	}
	if intent.turn_right {
		next.ship.heading += next.ship.movement.turn_speed
	}

	facing := Vec2 {
		x = math.cos(next.ship.heading),
		y = math.sin(next.ship.heading),
	}

	if intent.forward_thrust {
		next.ship.velocity.x += facing.x * next.ship.movement.thrust_acceleration
		next.ship.velocity.y += facing.y * next.ship.movement.thrust_acceleration
	}
	if intent.backward_thrust {
		next.ship.velocity.x -= facing.x * next.ship.movement.reverse_acceleration
		next.ship.velocity.y -= facing.y * next.ship.movement.reverse_acceleration
	}

	next.ship.velocity = vec2_clamp_length(next.ship.velocity, next.ship.movement.max_speed)
	next.ship.position.x += next.ship.velocity.x
	next.ship.position.y += next.ship.velocity.y
	next.ship.velocity.x *= next.ship.movement.damping
	next.ship.velocity.y *= next.ship.movement.damping

	return next
}

vec2_length :: proc(v: Vec2) -> f32 {
	return math.sqrt(v.x * v.x + v.y * v.y)
}

vec2_clamp_length :: proc(v: Vec2, max_length: f32) -> Vec2 {
	length := vec2_length(v)
	if length <= max_length || length == 0 {
		return v
	}

	scale := max_length / length
	return Vec2{x = v.x * scale, y = v.y * scale}
}

validate_simulation_invariants :: proc(state: Simulation_State) -> Invariant_Report {
	failures := 0

	if state.ship.id == 0 {
		failures += 1
	}
	if !vec2_is_finite(state.ship.position) || !vec2_is_finite(state.ship.velocity) || !f32_is_finite(state.ship.heading) {
		failures += 1
	}
	if state.ship.hitbox.half_width <= 0 || state.ship.hitbox.half_height <= 0 {
		failures += 1
	}
	if state.ship.movement.thrust_acceleration <= 0 ||
	   state.ship.movement.reverse_acceleration <= 0 ||
	   state.ship.movement.turn_speed <= 0 ||
	   state.ship.movement.damping < 0 ||
	   state.ship.movement.damping > 1 ||
	   state.ship.movement.max_speed <= 0 {
		failures += 1
	}
	if vec2_length(state.ship.velocity) > state.ship.movement.max_speed {
		failures += 1
	}

	return Invariant_Report{ok = failures == 0, failure_count = failures}
}

continuous_invariants_enabled :: proc(mode: Build_Mode) -> bool {
	return mode == .Dev || mode == .Test
}

vec2_is_finite :: proc(v: Vec2) -> bool {
	return f32_is_finite(v.x) && f32_is_finite(v.y)
}

f32_is_finite :: proc(v: f32) -> bool {
	return !math.is_nan(v) && !math.is_inf(v)
}
