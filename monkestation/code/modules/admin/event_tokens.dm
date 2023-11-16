/client/proc/adjust_players_event_tokens()
	set category = "Admin.Fun"

	set name = "Adjust Event Tokens"
	set desc = "Adjust how many event tokens someone has."

	var/mob/chosen_player = tgui_input_list(src, "Choose a Player", "Player List", GLOB.player_list)
	if(!chosen_player)
		return

	var/client/chosen_client = chosen_player.client
	var/adjustment_amount = tgui_input_number(src, "How much should we adjust this users tokens by?", "Input Value", TRUE)
	if(!adjustment_amount || !chosen_client)
		return

	log_admin("[key_name(src)] adjusted the event tokens of [key_name(chosen_client)] by [adjustment_amount].")
	chosen_client.client_token_holder.adjust_event_tokens(adjustment_amount)
