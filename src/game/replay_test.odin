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

	replayed_state := replay_simulation(replay, scenario.initial_state)
	expected_state := run_scenario(scenario)
	testing.expect_value(t, replayed_state, expected_state)
}
