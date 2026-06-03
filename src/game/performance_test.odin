package game

import "core:testing"

@(test)
test_performance_timing_view_exposes_minimal_frame_metrics :: proc(t: ^testing.T) {
	state := initial_simulation_state()
	view := simulation_view(state)
	pass_timings := initial_render_pass_timings()
	record_render_pass_timing(&pass_timings, .Background, 120)
	record_render_pass_timing(&pass_timings, .World, 340)
	record_render_pass_timing(&pass_timings, .Debug, 45)
	record_render_pass_timing(&pass_timings, .Inspector, 80)

	timing := performance_timing_view_for_frame(.Dev, view, 2, 510, 600, pass_timings, 59, 0.0169)

	testing.expect(t, timing.available)
	testing.expect_value(t, timing.simulation_step_us, u64(510))
	testing.expect_value(t, timing.render_pipeline_us, u64(600))
	testing.expect_value(t, timing.render_pass_count, RENDER_PASS_TIMING_COUNT)
	testing.expect_value(t, timing.render_passes[0].pass, Render_Pass.Background)
	testing.expect_value(t, timing.render_passes[0].elapsed_us, u64(120))
	testing.expect_value(t, timing.render_passes[1].pass, Render_Pass.World)
	testing.expect_value(t, timing.render_passes[1].elapsed_us, u64(340))
	testing.expect_value(t, timing.render_passes[2].pass, Render_Pass.Debug)
	testing.expect_value(t, timing.render_passes[2].elapsed_us, u64(45))
	testing.expect_value(t, timing.render_passes[3].pass, Render_Pass.Inspector)
	testing.expect_value(t, timing.render_passes[3].elapsed_us, u64(80))
	testing.expect_value(t, timing.entity_counts.ships, 1)
	testing.expect_value(t, timing.entity_counts.bullets, 0)
	testing.expect_value(t, timing.entity_counts.gameplay_objects, 1)
	testing.expect_value(t, timing.entity_counts.trace_entries, 2)
	testing.expect_value(t, timing.fps, i32(59))
	testing.expect_value(t, timing.frame_time_ms, f32(16.9))
}

@(test)
test_performance_timing_is_minimized_in_release :: proc(t: ^testing.T) {
	view := simulation_view(initial_simulation_state())
	pass_timings := initial_render_pass_timings()
	record_render_pass_timing(&pass_timings, .World, 400)

	timing := performance_timing_view_for_frame(.Release, view, 2, 100, 400, pass_timings, 60, 0.016)

	testing.expect(t, !timing.available)
	testing.expect_value(t, timing.simulation_step_us, u64(0))
	testing.expect_value(t, timing.render_pipeline_us, u64(0))
	testing.expect_value(t, timing.render_pass_count, 0)
	testing.expect_value(t, timing.fps, i32(0))
	testing.expect_value(t, timing.frame_time_ms, f32(0))
}
