package game

CONFIGURED_BUILD_MODE_NAME :: #config(SHIP_BUILD_MODE, "dev")

Build_Mode :: enum {
	Dev,
	Test,
	Release,
}

build_mode_from_name :: proc(name: string) -> (Build_Mode, bool) {
	switch name {
	case "dev":
		return .Dev, true
	case "test":
		return .Test, true
	case "release":
		return .Release, true
	}

	return .Dev, false
}

configured_build_mode :: proc() -> Build_Mode {
	mode, ok := build_mode_from_name(CONFIGURED_BUILD_MODE_NAME)
	assert(ok, "SHIP_BUILD_MODE must be dev, test, or release")
	return mode
}
