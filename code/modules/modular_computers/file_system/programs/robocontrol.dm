
/datum/computer_file/program/robocontrol
	filename = "robocontrol"
	filedesc = "Bot Remote Controller"
	program_icon_state = "robot"
	extended_desc = "A remote controller used for giving basic commands to non-sentient robots."
	transfer_access = ACCESS_ROBOTICS
	requires_ntnet = TRUE
	network_destination = "robotics control network"
	size = 12
	tgui_id = "ntos_robocontrol"
	ui_x = 550
	ui_y = 550
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

	for(var/B in GLOB.bots_list)
		var/mob/living/simple_animal/bot/Bot = B
		if(!Bot.on || Bot.z != zlevel || Bot.remote_disabled) //Only non-emagged bots on the same Z-level are detected!
			continue //Also, the PDA must have access to the bot type.
		var/list/newbot = list("name" = Bot.name, "mode" = Bot.get_mode_ui(), "model" = Bot.model, "locat" = get_area(Bot), "bot_ref" = REF(Bot), "mule_check" = FALSE)
		if(Bot.bot_type == MULE_BOT)
			var/mob/living/simple_animal/bot/mulebot/MULE = Bot
			mulelist += list(list("name" = MULE.name, "dest" = MULE.destination, "power" = MULE.cell ? MULE.cell.percent() : 0, "home" = MULE.home_destination, "autoReturn" = MULE.auto_return, "autoPickup" = MULE.auto_pickup, "reportDelivery" = MULE.report_delivery, "mule_ref" = REF(MULE)))
			if(MULE.load)
				data["load"] = MULE.load.name
			newbot["mule_check"] = TRUE
		botlist += list(newbot)

	data["bots"] = botlist
	data["mules"] = mulelist
	data["botcount"] = botlist.len

	return data

/datum/computer_file/program/robocontrol/ui_act(action, list/params)
	if(..())
		return TRUE
	var/obj/item/computer_hardware/card_slot/card_slot
	var/obj/item/card/id/id_card
	if(computer)
		card_slot = computer.all_components[MC_CARD]
		if(card_slot)
			id_card = card_slot.stored_card

	var/list/standard_actions = list("patroloff", "patrolon", "ejectpai")
	var/list/MULE_actions = list("stop", "go", "home", "destination", "setid", "sethome", "unload", "autoret", "autopick", "report", "ejectpai")
	var/mob/living/simple_animal/bot/Bot = locate(params["robot"]) in GLOB.bots_list
	if (action in standard_actions)
		Bot.bot_control(action, current_user, current_access)
	if (action in MULE_actions)
		Bot.bot_control(action, current_user, current_access, TRUE)
	switch(action)
		if("summon")
			Bot.bot_control(action, current_user, id_card ? id_card.access : current_access)
		if("ejectcard")
			if(!computer || !card_slot)
				return
			if(id_card)
				GLOB.data_core.manifest_modify(id_card.registered_name, id_card.assignment)
				card_slot.try_eject(TRUE, current_user)
			else
				playsound(get_turf(ui_host()) , 'sound/machines/buzz-sigh.ogg', 25, FALSE)
	return
