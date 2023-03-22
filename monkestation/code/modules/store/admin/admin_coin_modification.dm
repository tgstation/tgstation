/client/proc/adjust_players_metacoins()
	set category = "Admin.Fun"
	set name = "Adjust Metacoins"
	set desc = "You can modifiy a targets metacoin balance by adding or subtracting."

	var/mob/chosen_player
	chosen_player = tgui_input_list(src, "Choose a Player", "Player List", GLOB.player_list)
	if(!chosen_player)
		return
	var/client/chosen_client = chosen_player.client

	var/adjustment_amount = tgui_input_number(src, "How much should we adjust this users metacoins by?", "Input Value", TRUE, 1000000, -100000)
	if(!adjustment_amount)
		return

	if(adjustment_amount + chosen_client.prefs.metacoins < 0)
		adjustment_amount = chosen_client.prefs.metacoins

	chosen_client.prefs.adjust_metacoins(chosen_client.ckey, adjustment_amount, null, TRUE)

/client/proc/mass_add_metacoins()
	set category = "Admin.Fun"
	set name = "Mass Add Coins"
	set desc = "You give everyone some metacoins"


	var/adjustment_amount = tgui_input_number(src, "How much should we adjust this users metacoins by?", "Input Value", TRUE, 10000, 0)
	if(!adjustment_amount)
		return

	for(var/mob/player in GLOB.player_list)
		if(!player.client)
			continue
		if(!player.client.prefs)
			continue
		player.client.prefs.adjust_metacoins(player.client.ckey, adjustment_amount, "You have been gifted some coins from the staff.", TRUE)
