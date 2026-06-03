package main

import rl "vendor:raylib"

timing_now_seconds :: proc() -> f64 {
	return rl.GetTime()
}

elapsed_us_since :: proc(start_seconds: f64) -> u64 {
	return seconds_to_us(timing_now_seconds() - start_seconds)
}

seconds_to_us :: proc(seconds: f64) -> u64 {
	if seconds <= 0 {
		return 0
	}

	return u64(seconds * 1000000.0)
}
