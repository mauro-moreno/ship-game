package game

import "core:testing"

@(test)
test_build_mode_names_are_stable :: proc(t: ^testing.T) {
	dev, dev_ok := build_mode_from_name("dev")
	testing.expect(t, dev_ok)
	testing.expect_value(t, dev, Build_Mode.Dev)

	test, test_ok := build_mode_from_name("test")
	testing.expect(t, test_ok)
	testing.expect_value(t, test, Build_Mode.Test)

	release, release_ok := build_mode_from_name("release")
	testing.expect(t, release_ok)
	testing.expect_value(t, release, Build_Mode.Release)
}

@(test)
test_skeleton_declares_debuggable_modules :: proc(t: ^testing.T) {
	required_modules := [?]string {
		"app_shell",
		"simulation",
		"game_data_catalog",
		"input_adapter",
		"scenario",
		"replay",
		"event_trace",
		"render_pipeline",
		"inspector_overlay",
		"debug_artifacts",
	}

	for name in required_modules {
		testing.expect(t, skeleton_has_module(name), name)
	}
}
