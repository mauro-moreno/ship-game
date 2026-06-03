package main

import game "ship:game"

export_debug_dump_if_requested :: proc(state: ^App_State, mode: game.Build_Mode) {
	if !state.debug_dump_requested {
		return
	}

	overlay := app_inspector_overlay_view(state^, mode)
	ctx := game.debug_dump_context_from_overlay(state.debug_dump_reason, overlay, state.replay)
	result := game.write_debug_dump(ctx)
	state.debug_dump_requested = false

	if result.ok {
		state.debug_console_feedback = "Debug Dump exported to build/debug-dumps"
		return
	}

	state.debug_console_feedback = "Debug Dump export failed"
}
