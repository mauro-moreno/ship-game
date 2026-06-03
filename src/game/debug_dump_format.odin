package game

import "core:fmt"
import "core:strings"

DEBUG_DUMP_FORMAT_VERSION :: "ship-debug-dump-v1"

Debug_Dump_Document :: struct {
	version: string,
	text:    string,
}

format_debug_dump :: proc(ctx: Debug_Dump_Context) -> Debug_Dump_Document {
	builder := strings.builder_make(context.temp_allocator)

	fmt.sbprintf(
		&builder,
		"\"version\":\"%s\",\"reason\":\"%v\",\"build_mode\":\"%v\",\"scenario\":\"%s\",\"seed\":%v,\"frame\":%v",
		DEBUG_DUMP_FORMAT_VERSION,
		ctx.reason,
		ctx.build_mode,
		string(ctx.scenario_id),
		u64(ctx.seed),
		u64(ctx.frame),
	)

	fmt.sbprintf(
		&builder,
		"\n\"selected_object_id\":%v",
		u32(ctx.selected_object_id),
	)

	diff := ctx.snapshot_diff
	fmt.sbprintf(
		&builder,
		"\n\"state_snapshot_diff\",\"selected_object_id\":%v,\"selected_object_changed\":%v,\"position_changed\":%v,\"heading_changed\":%v,\"velocity_changed\":%v,\"before_position_x\":%v,\"before_position_y\":%v,\"after_position_x\":%v,\"after_position_y\":%v,\"before_heading\":%v,\"after_heading\":%v,\"before_velocity_x\":%v,\"before_velocity_y\":%v,\"after_velocity_x\":%v,\"after_velocity_y\":%v",
		u32(diff.selected_object_id),
		diff.selected_object_changed,
		diff.position_changed,
		diff.heading_changed,
		diff.velocity_changed,
		diff.before_position.x,
		diff.before_position.y,
		diff.after_position.x,
		diff.after_position.y,
		diff.before_heading,
		diff.after_heading,
		diff.before_velocity.x,
		diff.before_velocity.y,
		diff.after_velocity.x,
		diff.after_velocity.y,
	)

	breakpoints := ctx.frame_breakpoints
	fmt.sbprintf(
		&builder,
		"\n\"frame_breakpoints\",\"pause_on_event_kind\":%v,\"event_kind\":\"%v\",\"pause_on_invariant_failure\":%v",
		breakpoints.pause_on_event_kind,
		breakpoints.event_kind,
		breakpoints.pause_on_invariant_failure,
	)

	toggles := ctx.render_pass_toggles
	fmt.sbprintf(&builder, "\n\"render_pass_toggles\"")
	for i in 0..<render_pass_count() {
		pass, ok := render_pass_at(i)
		if ok {
			fmt.sbprintf(&builder, ",\"%s\":%v", render_pass_artifact_key(pass), render_pass_enabled(toggles, pass))
		}
	}

	camera := ctx.camera
	fmt.sbprintf(
		&builder,
		"\n\"camera\",\"target_x\":%v,\"target_y\":%v,\"zoom\":%v",
		camera.target.x,
		camera.target.y,
		camera.zoom,
	)

	timing := ctx.performance_timing
	entities := timing.entity_counts
	fmt.sbprintf(
		&builder,
		"\n\"performance_timing\",\"available\":%v,\"simulation_step_us\":%v,\"render_pipeline_us\":%v,\"fps\":%v,\"frame_time_ms\":%v,\"ships\":%v,\"bullets\":%v,\"gameplay_objects\":%v,\"trace_entries\":%v",
		timing.available,
		timing.simulation_step_us,
		timing.render_pipeline_us,
		timing.fps,
		timing.frame_time_ms,
		entities.ships,
		entities.bullets,
		entities.gameplay_objects,
		entities.trace_entries,
	)
	for i in 0..<render_pass_count() {
		pass, ok := render_pass_at(i)
		if ok {
			fmt.sbprintf(&builder, ",\"%s_us\":%v", render_pass_artifact_key(pass), render_pass_timing_elapsed_us(timing, pass))
		}
	}

	fmt.sbprintf(&builder, "\n\"replay_stream\":true")
	fmt.sbprintf(&builder, "\n%s", replay_to_text(ctx.replay))
	fmt.sbprintf(&builder, "\n\"event_trace_tail\",\"count\":%v", ctx.trace_tail.count)

	for i in 0..<ctx.trace_tail.count {
		entry := ctx.trace_tail.entries[i]
		fmt.sbprintf(
			&builder,
			"\n\"event_trace_tail_entry\",\"kind\":\"%v\",\"frame\":%v,\"object_id\":%v,\"scenario\":\"%s\",\"forward_thrust\":%v,\"backward_thrust\":%v,\"turn_left\":%v,\"turn_right\":%v",
			entry.kind,
			u64(entry.frame),
			u32(entry.object_id),
			string(entry.scenario_id),
			entry.intent.forward_thrust,
			entry.intent.backward_thrust,
			entry.intent.turn_left,
			entry.intent.turn_right,
		)
	}

	return Debug_Dump_Document {
		version = DEBUG_DUMP_FORMAT_VERSION,
		text = strings.to_string(builder),
	}
}

debug_dump_to_text :: proc(ctx: Debug_Dump_Context) -> string {
	return format_debug_dump(ctx).text
}
