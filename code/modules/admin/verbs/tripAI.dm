/client/proc/triple_ai()
	set category = "Fun"
	set name = "Create AI Triumvirate"

	if(ticker.current_state > GAME_STATE_PREGAME)
		usr << "This option is currently only usable during pregame. This may change at a later date."
		return
	if (occupations["AI"] > 1)
		occupations["AI"] -= 2
		usr << "Only one AI will be spawned at round start."
		message_admins("\blue [key_name_admin(usr)] has toggled off triple AIs at round start.", 1)
	else
		occupations["AI"] += 2
		usr << "There will be an AI Triumvirate at round start."
		message_admins("\blue [key_name_admin(usr)] has toggled on triple AIs at round start.", 1)
	return
