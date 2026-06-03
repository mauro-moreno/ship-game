package game

MAX_EVENT_TRACE_ENTRIES :: 32

Event_Kind :: enum {
	Scenario_Started,
	Control_Intent_Applied,
	Ship_Moved,
	Invariant_Failed,
}

Event_Trace_Entry :: struct {
	kind:        Event_Kind,
	frame:       Frame_Step_Index,
	object_id:   Object_ID,
	scenario_id: Scenario_Id,
	intent:      Control_Intent,
}

Event_Trace :: struct {
	entries: [MAX_EVENT_TRACE_ENTRIES]Event_Trace_Entry,
	count:   int,
}

Trace_Filter :: struct {
	use_frame_range: bool,
	frame_start:     Frame_Step_Index,
	frame_end:       Frame_Step_Index,
	use_object_id:   bool,
	object_id:       Object_ID,
	use_event_kind:  bool,
	event_kind:      Event_Kind,
}

trace_append :: proc(trace: ^Event_Trace, entry: Event_Trace_Entry) {
	assert(trace.count < MAX_EVENT_TRACE_ENTRIES)
	trace.entries[trace.count] = entry
	trace.count += 1
}

trace_append_all :: proc(trace: ^Event_Trace, other: Event_Trace) {
	for i in 0..<other.count {
		trace_append(trace, other.entries[i])
	}
}

trace_tail_append :: proc(trace: ^Event_Trace, entry: Event_Trace_Entry) {
	if trace.count == MAX_EVENT_TRACE_ENTRIES {
		for i in 1..<trace.count {
			trace.entries[i - 1] = trace.entries[i]
		}
		trace.count -= 1
	}

	trace_append(trace, entry)
}

trace_tail_append_all :: proc(trace: ^Event_Trace, other: Event_Trace) {
	for i in 0..<other.count {
		trace_tail_append(trace, other.entries[i])
	}
}

default_trace_filter :: proc() -> Trace_Filter {
	return {}
}

trace_filter_for_object :: proc(object_id: Object_ID) -> Trace_Filter {
	filter := default_trace_filter()
	filter.use_object_id = true
	filter.object_id = object_id
	return filter
}

trace_filter_for_object_kind_and_frame_range :: proc(object_id: Object_ID, kind: Event_Kind, frame_start, frame_end: Frame_Step_Index) -> Trace_Filter {
	filter := trace_filter_for_object(object_id)
	filter.use_event_kind = true
	filter.event_kind = kind
	filter.use_frame_range = true
	filter.frame_start = frame_start
	filter.frame_end = frame_end
	return filter
}

trace_filter :: proc(trace: Event_Trace, filter: Trace_Filter) -> Event_Trace {
	filtered: Event_Trace

	for i in 0..<trace.count {
		entry := trace.entries[i]
		if trace_entry_matches_filter(entry, filter) {
			trace_append(&filtered, entry)
		}
	}

	return filtered
}

trace_filter_by_object :: proc(trace: Event_Trace, object_id: Object_ID) -> Event_Trace {
	return trace_filter(trace, trace_filter_for_object(object_id))
}

trace_entry_matches_filter :: proc(entry: Event_Trace_Entry, filter: Trace_Filter) -> bool {
	if filter.use_frame_range && (entry.frame < filter.frame_start || entry.frame > filter.frame_end) {
		return false
	}
	if filter.use_object_id && entry.object_id != filter.object_id {
		return false
	}
	if filter.use_event_kind && entry.kind != filter.event_kind {
		return false
	}

	return true
}
