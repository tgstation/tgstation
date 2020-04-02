
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
	var/current_user
	///Access granted by the used to summon robots.
	var/list/current_access = list()

/datum/computer_file/program/robocontrol/ui_data(mob/user)
	var/list/data = get_header_data()
	var/turf/current_turf = get_turf(ui_host())
	var/zlevel = current_turf.z
	var/list/botlist = list()
	var/list/mulelist = list()
	var/mule_check

	var/obj/item/computer_hardware/card_slot/card_slot

	if(computer)
		card_slot = computer.all_components[MC_CARD]

	if(computer)
		data["have_id_slot"] = !!card_slot
	else
		data["have_id_slot"] = FALSE

	if(computer)
		var/obj/item/card/id/id_card
		if(card_slot)
			id_card = card_slot.stored_card
		data["has_id"] = !!id_card
		data["id_owner"] = "No Card Inserted."
		if(id_card)
			data["access_on_card"] = id_card.access
			data["id_owner"] = id_card.registered_name

	botcount = 0
	current_user = user

	for(var/B in GLOB.bots_list)
		mule_check = FALSE
		var/mob/living/simple_animal/bot/Bot = B
		if(!Bot.on || Bot.z != zlevel || Bot.remote_disabled) //Only non-emagged bots on the same Z-level are detected!
			continue //Also, the PDA must have access to the bot type.

		if(Bot.bot_type == MULE_BOT)
			var/mob/living/simple_animal/bot/mulebot/MULE = Bot
			mulelist += list(list("name" = MULE.name,"load" = MULE.load, "destination" = MULE.destination, "power" = MULE.cell, "home" = MULE.home_destination, "mule_ref" = REF(MULE)))
			data["autoReturn"] = MULE.auto_return
			data["autoPickup"] = MULE.auto_pickup
			data["reportDelivery"] = MULE.report_delivery
			mule_check = TRUE

		botlist += list(list("name" = Bot.name, "mode" = Bot.get_mode_ui(), "model" = Bot.model, "locat" = get_area(Bot), "bot_ref" = REF(Bot), "mule_check" = mule_check))
		botcount++

	data["bots"] = botlist
	data["mules"] = mulelist
	data["botcount"] = botcount

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

	var/mob/living/simple_animal/bot/Bot = locate(params["robot"]) in GLOB.bots_list
	switch(action)
		if("patroloff")
			Bot.bot_control(action, current_user, current_access)
		if("patrolon")
			Bot.bot_control(action, current_user, current_access)
		if("summon")
			if(id_card)
				current_access = id_card.access
			Bot.bot_control(action, current_user, current_access)
		if("ejectpai")
			Bot.bot_control(action, current_user, current_access)
		//Mule Commands
		if("stop")
			Bot.bot_control(action, current_user, current_access, TRUE)
		if("go")
			Bot.bot_control(action, current_user, current_access, TRUE)
		if("home")
			Bot.bot_control(action, current_user, current_access, TRUE)
		if("destination")
			Bot.bot_control(action, current_user, current_access, TRUE)
		if("setid")
			Bot.bot_control(action, current_user, current_access, TRUE)
		if("sethome")
			Bot.bot_control(action, current_user, current_access, TRUE)
		if("unload")
			Bot.bot_control(action, current_user, current_access, TRUE)
		if("autoret")
			Bot.bot_control(action, current_user, current_access, TRUE)
		if("autopick")
			Bot.bot_control(action, current_user, current_access, TRUE)
		if("report")
			Bot.bot_control(action, current_user, current_access, TRUE)
		if("ejectpai")
			Bot.bot_control(action, current_user, current_access, TRUE)

		if("ejectcard")
			if(!computer || !card_slot)
				return
			if(id_card)
				GLOB.data_core.manifest_modify(id_card.registered_name, id_card.assignment)
				card_slot.try_eject(TRUE, current_user)
			else
				playsound(get_turf(ui_host()) , 'sound/machines/buzz-sigh.ogg', 25, FALSE)
	return
