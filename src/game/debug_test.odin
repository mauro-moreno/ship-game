package game

import "core:testing"

@(test)
test_state_snapshot_diff_reports_movement_changes :: proc(t: ^testing.T) {
	before_state := initial_simulation_state()
	after_state := step_simulation(before_state, Control_Intent{forward_thrust = true})

	before := capture_state_snapshot(before_state, Object_ID(1))
	after := capture_state_snapshot(after_state, Object_ID(1))
	diff := diff_state_snapshots(before, after)

	testing.expect_value(t, diff.selected_object_id, Object_ID(1))
	testing.expect(t, diff.position_changed)
	testing.expect(t, diff.velocity_changed)
	testing.expect(t, !diff.heading_changed)
	testing.expect(t, !diff.selected_object_changed)
	testing.expect_value(t, diff.before_position, Vec2{})
	testing.expect(t, diff.after_position.x > diff.before_position.x)
	testing.expect_value(t, diff.before_heading, diff.after_heading)

	changed_selection := diff_state_snapshots(before, capture_state_snapshot(after_state, Object_ID(2)))
	testing.expect(t, changed_selection.selected_object_changed)
}
