package game

RENDER_PASS_TIMING_COUNT :: RENDER_PASS_COUNT

Entity_Counts :: struct {
	ships:            int,
	bullets:          int,
	gameplay_objects: int,
	trace_entries:    int,
}

Render_Pass_Timing :: struct {
	pass:       Render_Pass,
	elapsed_us: u64,
}

Render_Pass_Timings :: struct {
	count:  int,
	passes: [RENDER_PASS_TIMING_COUNT]Render_Pass_Timing,
}

Performance_Timing_View :: struct {
	available:           bool,
	simulation_step_us:  u64,
	render_pipeline_us:  u64,
	render_pass_count:   int,
	render_passes:       [RENDER_PASS_TIMING_COUNT]Render_Pass_Timing,
	entity_counts:       Entity_Counts,
	fps:                 i32,
	frame_time_ms:       f32,
}

initial_render_pass_timings :: proc() -> Render_Pass_Timings {
	timings: Render_Pass_Timings
	timings.count = render_pass_count()
	for i in 0..<render_pass_count() {
		pass, _ := render_pass_at(i)
		timings.passes[i] = Render_Pass_Timing{pass = pass}
	}

	return timings
}

record_render_pass_timing :: proc(timings: ^Render_Pass_Timings, pass: Render_Pass, elapsed_us: u64) {
	for i in 0..<timings.count {
		if timings.passes[i].pass == pass {
			timings.passes[i].elapsed_us = elapsed_us
			return
		}
	}
}

render_pass_timing_elapsed_us :: proc(timing: Performance_Timing_View, pass: Render_Pass) -> u64 {
	for i in 0..<timing.render_pass_count {
		if timing.render_passes[i].pass == pass {
			return timing.render_passes[i].elapsed_us
		}
	}

	return 0
}

performance_timing_collection_enabled :: proc(mode: Build_Mode) -> bool {
	return mode != .Release
}

performance_timing_view_for_frame :: proc(
	mode: Build_Mode,
	view: Simulation_View,
	trace_entry_count: int,
	simulation_step_us: u64,
	render_pipeline_us: u64,
	pass_timings: Render_Pass_Timings,
	fps: i32,
	frame_time_seconds: f64,
) -> Performance_Timing_View {
	if !performance_timing_collection_enabled(mode) {
		return {}
	}

	frame_time_ms := frame_time_seconds * 1000
	if frame_time_ms < 0 {
		frame_time_ms = 0
	}

	entity_counts := entity_counts_for_simulation_view(view, trace_entry_count)

	return Performance_Timing_View {
		available = true,
		simulation_step_us = simulation_step_us,
		render_pipeline_us = render_pipeline_us,
		render_pass_count = pass_timings.count,
		render_passes = pass_timings.passes,
		entity_counts = entity_counts,
		fps = fps,
		frame_time_ms = f32(frame_time_ms),
	}
}

entity_counts_for_simulation_view :: proc(view: Simulation_View, trace_entry_count: int) -> Entity_Counts {
	ship_count := 0
	if view.player_ship.id != 0 {
		ship_count = 1
	}

	return Entity_Counts {
		ships = ship_count,
		bullets = 0,
		gameplay_objects = ship_count,
		trace_entries = trace_entry_count,
	}
}
