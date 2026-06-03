package game

import "core:testing"

@(test)
test_player_moves_forward_emits_compact_event_trace :: proc(t: ^testing.T) {
	result := run_scenario_with_trace(player_moves_forward_scenario())
	trace := result.trace

	testing.expect_value(t, trace.count, 3)
	testing.expect_value(t, trace.entries[0].kind, Event_Kind.Scenario_Started)
	testing.expect_value(t, trace.entries[0].frame, Frame_Step_Index(0))
	testing.expect_value(t, trace.entries[0].scenario_id, PLAYER_MOVES_FORWARD_ID)

	testing.expect_value(t, trace.entries[1].kind, Event_Kind.Control_Intent_Applied)
	testing.expect_value(t, trace.entries[1].frame, Frame_Step_Index(0))
	testing.expect_value(t, trace.entries[1].object_id, Object_ID(1))
	testing.expect(t, trace.entries[1].intent.forward_thrust)

	testing.expect_value(t, trace.entries[2].kind, Event_Kind.Ship_Moved)
	testing.expect_value(t, trace.entries[2].frame, Frame_Step_Index(1))
	testing.expect_value(t, trace.entries[2].object_id, Object_ID(1))
}

@(test)
test_frame_step_trace_reports_invariant_failure :: proc(t: ^testing.T) {
	state := initial_simulation_state()
	state.ship.id = 0

	result := step_simulation_with_trace(state, Control_Intent{}, .Test)

	testing.expect_value(t, result.trace.count, 1)
	testing.expect_value(t, result.trace.entries[0].kind, Event_Kind.Invariant_Failed)
	testing.expect_value(t, result.trace.entries[0].frame, Frame_Step_Index(0))
}

@(test)
test_trace_can_be_filtered_by_selected_object_id :: proc(t: ^testing.T) {
	trace := run_scenario_with_trace(player_moves_forward_scenario()).trace
	selected := trace_filter_by_object(trace, Object_ID(1))
	missing := trace_filter_by_object(trace, Object_ID(2))

	testing.expect_value(t, selected.count, 2)
	testing.expect_value(t, selected.entries[0].kind, Event_Kind.Control_Intent_Applied)
	testing.expect_value(t, selected.entries[0].object_id, Object_ID(1))
	testing.expect_value(t, selected.entries[1].kind, Event_Kind.Ship_Moved)
	testing.expect_value(t, selected.entries[1].object_id, Object_ID(1))
	testing.expect_value(t, missing.count, 0)
}
