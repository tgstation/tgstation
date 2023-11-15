/client/proc/set_players_event_tokens()
	set category = "Admin.Fun"
//due to the fact that these reset each month im just making this directly this this value instead of add or subtract
	set name = "Set Event Tokens"
	set desc = "Set how many event tokens someone has."

	var/mob/chosen_player = tgui_input_list(src, "Choose a Player", "Player List", GLOB.player_list)
	if(!chosen_player)
		return

	var/client/chosen_client = chosen_player.client
	var/adjustment_amount = tgui_input_number(src, "What should we set this users tokens to?", "Input Value", TRUE)
	if(!adjustment_amount || !chosen_client || !chosen_client.patreon)
		return

	check_event_tokens(chosen_client)
	chosen_client.prefs.event_tokens = adjustment_amount
