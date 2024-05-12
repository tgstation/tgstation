
/datum/computer_file/program/robocontrol
	filename = "botkeeper"
	filedesc = "BotKeeper"
	downloader_category = PROGRAM_CATEGORY_SCIENCE
	program_open_overlay = "robot"
	extended_desc = "A remote controller used for giving basic commands to non-sentient robots."
	program_flags = PROGRAM_ON_NTNET_STORE | PROGRAM_REQUIRES_NTNET
	size = 6
	tgui_id = "NtosRoboControl"
	program_icon = "robot"
	///Number of simple robots on-station.
	var/botcount = 0
	///Access granted by the used to summon robots.
	var/list/current_access = list()
	///List of all ping types you can annoy drones with.
	var/static/list/drone_ping_types = list(
		"Low",
		"Medium",
		"High",
		"Critical",
	)

/datum/computer_file/program/robocontrol/ui_data(mob/user)
	var/list/data = list()
	var/turf/current_turf = get_turf(computer.ui_host())
	var/list/botlist = list()
	var/list/mulelist = list()

	if(computer)
		data["id_owner"] = computer.computer_id_slot || ""

	botcount = 0

	for(var/mob/living/simple_animal/bot/simple_bot as anything in GLOB.bots_list)
		if(!is_valid_z_level(current_turf, get_turf(simple_bot)) || !(simple_bot.bot_mode_flags & BOT_MODE_REMOTE_ENABLED)) //Only non-emagged bots on the same Z-level are detected!
			continue
		if(!simple_bot.allowed(user) && !simple_bot.check_access(computer.computer_id_slot)) // Only check Bots we can access
			continue
		var/list/newbot = list(
			"name" = simple_bot.name,
			"mode" = simple_bot.get_mode_ui(),
			"model" = simple_bot.bot_type,
			"locat" = get_area(simple_bot),
			"bot_ref" = REF(simple_bot),
			"mule_check" = FALSE,
		)
		if(simple_bot.bot_type == MULE_BOT)
			var/mob/living/simple_animal/bot/mulebot/simple_mulebot = simple_bot
			mulelist += list(list(
				"name" = simple_mulebot.name,
				"id" = simple_mulebot.id,
				"dest" = simple_mulebot.destination,
				"power" = simple_mulebot.cell ? simple_mulebot.cell.percent() : 0,
				"home" = simple_mulebot.home_destination,
				"autoReturn" = simple_mulebot.auto_return,
				"autoPickup" = simple_mulebot.auto_pickup,
				"reportDelivery" = simple_mulebot.report_delivery,
				"mule_ref" = REF(simple_mulebot),
				"load" = simple_mulebot.get_load_name(),
			))
			newbot["mule_check"] = TRUE
		botlist += list(newbot)

	for(var/mob/living/basic/drone/all_drones as anything in GLOB.drones_list)
		if(all_drones.hacked)
			continue
		if(!is_valid_z_level(current_turf, get_turf(all_drones)))
			continue
		var/list/drone_data = list(
			"name" = all_drones.name,
			"status" = all_drones.stat,
			"drone_ref" = REF(all_drones),
		)
		data["drones"] += list(drone_data)


	data["bots"] = botlist
	data["mules"] = mulelist
	data["botcount"] = botlist.len
	data["droneaccess"] = GLOB.drone_machine_blacklist_enabled
	data["dronepingtypes"] = drone_ping_types

	return data

/datum/computer_file/program/robocontrol/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	var/mob/current_user = ui.user
	var/obj/item/card/id/id_card = computer?.computer_id_slot

	var/static/list/standard_actions = list(
		"patroloff",
		"patrolon",
		"ejectpai",
	)
	var/static/list/MULE_actions = list(
		"stop",
		"go",
		"home",
		"destination",
		"setid",
		"sethome",
		"unload",
		"autoret",
		"autopick",
		"report",
		"ejectpai",
	)
	var/mob/living/simple_animal/bot/simple_bot = locate(params["robot"]) in GLOB.bots_list
	if (action in standard_actions)
		simple_bot.bot_control(action, current_user, id_card?.GetAccess())
	if (action in MULE_actions)
		simple_bot.bot_control(action, current_user, id_card?.GetAccess(), TRUE)

	switch(action)
		if("summon")
			simple_bot.bot_control(action, current_user, id_card ? id_card.access : id_card?.GetAccess())
		if("ejectcard")
			if(!computer || !computer.computer_id_slot)
				return
			if(id_card)
				GLOB.manifest.modify(id_card.registered_name, id_card.assignment, id_card.get_trim_assignment())
				computer.RemoveID(usr)
			else
				playsound(get_turf(computer.ui_host()) , 'sound/machines/buzz-sigh.ogg', 25, FALSE)
		if("changedroneaccess")
			if(!computer || !computer.computer_id_slot || !id_card)
				to_chat(current_user, span_notice("No ID found, authorization failed."))
				return
			if(isdrone(current_user))
				to_chat(current_user, span_notice("You can't free yourself."))
				return
			if(!(ACCESS_CE in id_card.access))
				to_chat(current_user, span_notice("Required access not found on ID."))
				return
			GLOB.drone_machine_blacklist_enabled = !GLOB.drone_machine_blacklist_enabled
		if("ping_drones")
			if(!(params["ping_type"]) || !(params["ping_type"] in drone_ping_types))
				return
			var/area/current_area = get_area(current_user)
			if(!current_area || QDELETED(current_user))
				return
			var/msg = span_boldnotice("NON-DRONE PING: [current_user.name]: [params["ping_type"]] priority alert in [current_area.name]!")
			_alert_drones(msg, TRUE, current_user)
			to_chat(current_user, msg)
			playsound(src, 'sound/machines/terminal_success.ogg', 15, TRUE)
