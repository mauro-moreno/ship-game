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
