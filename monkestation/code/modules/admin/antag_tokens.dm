/client/proc/adjust_players_antag_tokens()
	set category = "Admin.Fun"

	set name = "Adjust Antag Tokens"
	set desc = "You can modifiy a targets metacoin balance by adding or subtracting."

	var/mob/chosen_player = tgui_input_list(src, "Choose a Player", "Player List", GLOB.player_list)
	if(!chosen_player)
		return

	var/client/chosen_client = chosen_player.client
	var/adjustment_amount = tgui_input_number(src, "How much should we adjust this users antag tokens by?", "Input Value", TRUE, 10, -10)
	if(!adjustment_amount || !chosen_client)
		return
	var/tier = tgui_input_list(src, "Choose a tier for the token", "Tier list", list(HIGH_THREAT, MEDIUM_THREAT, LOW_THREAT))
	if(!tier)
		return

	chosen_client.client_saved_tokens.adjust_tokens(tier, adjustment_amount)
