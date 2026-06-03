package game

import "core:strings"
import "core:testing"

@(test)
test_replay_records_player_moves_forward_and_reproduces_final_state :: proc(t: ^testing.T) {
	scenario := player_moves_forward_scenario()
	replay := replay_from_scenario(scenario)
	text := replay_to_text(replay)

	testing.expect_value(t, replay.seed, scenario.seed)
	testing.expect_value(t, replay.intent_count, 1)
	testing.expect(t, replay.intents[0].forward_thrust)
	testing.expect(t, strings.contains(text, REPLAY_FORMAT_VERSION))
	testing.expect(t, strings.contains(text, "player_moves_forward"))
	testing.expect(t, strings.contains(text, "forward_thrust"))

	replayed_state := replay_simulation(replay, scenario.initial_state, .Test)
	expected_state := run_scenario(scenario, .Test)
	testing.expect_value(t, replayed_state, expected_state)
}

@(test)
test_replay_records_normalized_debug_commands :: proc(t: ^testing.T) {
	scenario := player_moves_forward_scenario()
	replay := replay_from_scenario(scenario)
	parsed := parse_debug_text_command("select 1")

	replay_record_debug_command(&replay, Frame_Step_Index(3), parsed.command)
	text := replay_to_text(replay)

	testing.expect(t, parsed.ok)
	testing.expect_value(t, replay.debug_command_count, 1)
	testing.expect_value(t, replay.debug_commands[0].frame, Frame_Step_Index(3))
	testing.expect_value(t, replay.debug_commands[0].command.kind, Debug_Command_Kind.Select_Object)
	testing.expect_value(t, replay.debug_commands[0].command.object_id, Object_ID(1))
	testing.expect(t, strings.contains(text, "debug_command"))
	testing.expect(t, strings.contains(text, "Select_Object"))
}
