/client/proc/spawn_pollution()
	set category = "Admin.Fun"
	set name = "Spawn Pollution"
	set desc = "Spawns an amount of chosen pollutant at your current location."

	var/list/singleton_list = SSpollution.singletons
	var/choice = tgui_input_list(usr, "What type of pollutant would you like to spawn?", "Spawn Pollution", singleton_list)
	if(!choice)
		return
	var/amount_choice = input("Amount of pollution:") as null|num
	if(!amount_choice)
		return
	var/turf/epicenter = get_turf(mob)
	epicenter.pollute_turf(choice, amount_choice)
	message_admins("[ADMIN_LOOKUPFLW(usr)] spawned pollution at [epicenter.loc] ([choice] - [amount_choice]).")
	log_admin("[key_name(usr)] spawned pollution at [epicenter.loc] ([choice] - [amount_choice]).")
