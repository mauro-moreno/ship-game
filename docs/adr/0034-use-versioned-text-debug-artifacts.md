# Use versioned text debug artifacts

Replay, Event Trace, Debug Dump, and Scenario metadata will use simple versioned text formats initially. JSON is preferred for Debug Dump and Scenario metadata, and a line-oriented text format such as JSONL is preferred for Event Trace and Replay streams, because humans and agents need to diff, inspect, search, paste, and repair debugging artifacts without custom tooling.

## Considered Options

- Use compact binary formats for debug artifacts from the start.
- Use versioned text formats for debug artifacts initially.

## Consequences

- Debug artifacts are larger than binary equivalents.
- Format versions must be included from the start.
- Binary formats can be reconsidered only if size or speed becomes a demonstrated problem.
