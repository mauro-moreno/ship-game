package game

SKELETON_MODULE_NAMES :: [?]string {
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

skeleton_has_module :: proc(name: string) -> bool {
	for module_name in SKELETON_MODULE_NAMES {
		if module_name == name {
			return true
		}
	}

	return false
}
