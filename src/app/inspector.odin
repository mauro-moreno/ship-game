package main

import "core:c"
import "core:fmt"
import game "ship:game"
import rl "vendor:raylib"

draw_inspector_overlay :: proc(mode: game.Build_Mode, scenario_id: game.Scenario_Id, debug_view: game.Render_Debug_View) {
	toggles := debug_view.pass_toggles
	ship := debug_view.player_ship
	camera := debug_view.camera

	draw_inspector_line(fmt.ctprintf("build=%v scenario=%v frame=%v", mode, string(scenario_id), u64(debug_view.frame)), 58)
	draw_inspector_line(fmt.ctprintf("camera target=(%v,%v) zoom=%v", camera.target.x, camera.target.y, camera.zoom), 78)
	draw_inspector_line(fmt.ctprintf("ship id=%v pos=(%v,%v) heading=%v", u32(ship.id), ship.position.x, ship.position.y, ship.heading), 98)
	draw_inspector_line(fmt.ctprintf("velocity=(%v,%v) hitbox=(%v,%v)", ship.velocity.x, ship.velocity.y, ship.hitbox.half_width, ship.hitbox.half_height), 118)
	draw_inspector_line(fmt.ctprintf("passes 1:bg=%v 2:world=%v 3:debug=%v 4:inspector=%v", toggles.background, toggles.world, toggles.debug, toggles.inspector), 138)
}

draw_inspector_line :: proc(text: cstring, y: c.int) {
	rl.DrawText(text, 24, y, 16, rl.SKYBLUE)
}
