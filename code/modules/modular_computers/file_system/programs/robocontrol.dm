
/datum/computer_file/program/robocontrol
	filename = "robocontrol"
	filedesc = "Bot Remote Controller"
	program_icon_state = "robot"
	extended_desc = "A remote controller used for giving basic commands to non-sentient robots."
	requires_ntnet = TRUE
	network_destination = "robotics control network"
	size = 12
	tgui_id = "ntos_robocontrol"
	ui_x = 450
	ui_y = 350
///Number of simple robots on-station.
	var/botcount = 0

	var/bot_access_flags = 0 //Bit flags. Selection: SEC_BOT | MULE_BOT | FLOOR_BOT | CLEAN_BOT | MED_BOT | FIRE_BOT



/datum/computer_file/program/robocontrol/ui_data(mob/user)
	var/list/data = get_header_data()
	var/turf/current_turf = get_turf(src)
	var/zlevel = current_turf.z

	var/list/botlist = list()

	for(var/B in GLOB.bots_list)
		var/mob/living/simple_animal/bot/Bot = B
		if(!Bot.on || Bot.z != zlevel || Bot.remote_disabled || !(bot_access_flags & Bot.bot_type)) //Only non-emagged bots on the same Z-level are detected!
			continue //Also, the PDA must have access to the bot type.
		botlist += list(list("name" = Bot.name, "mode" = Bot.get_mode(), "model" = Bot.model, "locat" = get_area(Bot)))
		botcount++

	data["bots"] = botlist
	data["botcount"] = botcount

	return data

/datum/computer_file/program/robocontrol/ui_act(action, list/params)
	if(..())
		return TRUE



