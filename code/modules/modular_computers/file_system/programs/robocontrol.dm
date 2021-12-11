
/datum/computer_file/program/robocontrol
	filename = "botkeeper"
	filedesc = "BotKeeper"
	category = PROGRAM_CATEGORY_ROBO
	program_icon_state = "robot"
	extended_desc = "A remote controller used for giving basic commands to non-sentient robots."
	transfer_access = null
	requires_ntnet = TRUE
	size = 12
	tgui_id = "NtosRoboControl"
	program_icon = "robot"
	///Number of simple robots on-station.
	var/botcount = 0
	///Used to find the location of the user for the purposes of summoning robots.
	var/mob/current_user
	///Access granted by the used to summon robots.
	var/list/current_access = list()

/datum/computer_file/program/robocontrol/ui_data(mob/user)
	var/list/data = get_header_data()
	var/turf/current_turf = get_turf(ui_host())
	var/zlevel = current_turf.z
	var/list/botlist = list()
	var/list/mulelist = list()

	var/obj/item/computer_hardware/card_slot/card_slot = computer ? computer.all_components[MC_CARD] : null
	data["have_id_slot"] = !!card_slot
	if(computer)
		var/obj/item/card/id/id_card = card_slot ? card_slot.stored_card : null
		data["has_id"] = !!id_card
		data["id_owner"] = id_card ? id_card.registered_name : "No Card Inserted."
		data["access_on_card"] = id_card ? id_card.access : null

	botcount = 0
	current_user = user

	for(var/mob/living/simple_animal/bot/simple_bot as anything in GLOB.bots_list)
		if(simple_bot.z != zlevel || !(simple_bot.bot_mode_flags & BOT_MODE_REMOTE_ENABLED)) //Only non-emagged bots on the same Z-level are detected!
			continue
		if(computer && !simple_bot.check_access(current_user)) // Only check Bots we can access)
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
				"dest" = simple_mulebot.destination,
				"power" = simple_mulebot.cell ? simple_mulebot.cell.percent() : 0,
				"home" = simple_mulebot.home_destination,
				"autoReturn" = simple_mulebot.auto_return,
				"autoPickup" = simple_mulebot.auto_pickup,
				"reportDelivery" = simple_mulebot.report_delivery,
				"mule_ref" = REF(simple_mulebot),
			))
			if(simple_mulebot.load)
				data["load"] = simple_mulebot.load.name
			newbot["mule_check"] = TRUE
		botlist += list(newbot)

	data["bots"] = botlist
	data["mules"] = mulelist
	data["botcount"] = botlist.len

	return data

/datum/computer_file/program/robocontrol/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	var/obj/item/computer_hardware/card_slot/card_slot
	var/obj/item/card/id/id_card
	if(computer)
		card_slot = computer.all_components[MC_CARD]
		if(card_slot)
			id_card = card_slot.stored_card

	var/list/standard_actions = list(
		"patroloff",
		"patrolon",
		"ejectpai",
	)
	var/list/MULE_actions = list(
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
		simple_bot.bot_control(action, current_user, current_access)
	if (action in MULE_actions)
		simple_bot.bot_control(action, current_user, current_access, TRUE)

	switch(action)
		if("summon")
			simple_bot.bot_control(action, current_user, id_card ? id_card.access : current_access)
		if("ejectcard")
			if(!computer || !card_slot)
				return
			if(id_card)
				GLOB.data_core.manifest_modify(id_card.registered_name, id_card.assignment, id_card.get_trim_assignment())
				card_slot.try_eject(current_user)
			else
				playsound(get_turf(ui_host()) , 'sound/machines/buzz-sigh.ogg', 25, FALSE)
	return
