/datum/game_mode/dynamic/generate_budgets()
	if (SSticker.totalPlayersReady < low_pop_player_threshold)
		round_start_budget = 0
		initial_round_start_budget = 0
		mid_round_budget = threat_level - 0
		threat_level = 0
		return
	. = ..()
