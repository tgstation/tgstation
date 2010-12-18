var/global/check_dem_trips = 0

/client/proc/triple_ai()
	set category = "Fun"
	set name = "Create AI Triumvirate"


	if(ticker.current_state < 2)
		if (check_dem_trips)
			occupations["AI"] -= 2
			usr << "Only one AI will be spawned at round start."
			message_admins("\blue [key_name_admin(usr)] has toggled off triple AIs at round start.", 1)
		else
			occupations["AI"] += 2
			usr << "There will be an AI Triumvirate at round start."
			message_admins("\blue [key_name_admin(usr)] has toggled on triple AIs at round start.", 1)
		check_dem_trips = !check_dem_trips
		return

	usr << "This option is currently only usable during pregame. This may change at a later date."