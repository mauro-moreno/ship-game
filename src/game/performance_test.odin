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
	testing.expect_value(t, timing.render_pass_count, render_pass_count())
	for i in 0..<render_pass_count() {
		pass, ok := render_pass_at(i)
		testing.expect(t, ok)
		testing.expect_value(t, timing.render_passes[i].pass, pass)
	}
	testing.expect_value(t, render_pass_timing_elapsed_us(timing, .Background), u64(120))
	testing.expect_value(t, render_pass_timing_elapsed_us(timing, .World), u64(340))
	testing.expect_value(t, render_pass_timing_elapsed_us(timing, .Debug), u64(45))
	testing.expect_value(t, render_pass_timing_elapsed_us(timing, .Inspector), u64(80))
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
