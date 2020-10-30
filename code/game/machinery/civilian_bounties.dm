///Pad for the Civilian Bounty Control.
/obj/machinery/piratepad/civilian
	name = "civilian bounty pad"
	desc = "A machine designed to send civilian bounty targets to centcom."
	layer = TABLE_LAYER
	resistance_flags = FIRE_PROOF
	circuit = /obj/item/circuitboard/machine/bountypad

///Computer for assigning new civilian bounties, and sending bounties for collection.
/obj/machinery/computer/piratepad_control/civilian
	name = "civilian bounty control terminal"
	desc = "A console for assigning civilian bounties to inserted ID cards, and for controlling the bounty pad for export."
	status_report = "Ready for delivery."
	icon_screen = "civ_bounty"
	icon_keyboard = "id_key"
	warmup_time = 3 SECONDS
	var/obj/item/card/id/inserted_scan_id
	circuit = /obj/item/circuitboard/computer/bountypad

/obj/machinery/computer/piratepad_control/civilian/Initialize()
	. = ..()
	pad = /obj/machinery/piratepad/civilian

/obj/machinery/computer/piratepad_control/civilian/attackby(obj/item/I, mob/living/user, params)
	if(isidcard(I))
		if(id_insert(user, I, inserted_scan_id))
			inserted_scan_id = I
			return TRUE
	return ..()

/obj/machinery/computer/piratepad_control/multitool_act(mob/living/user, obj/item/multitool/I)
	if(istype(I) && istype(I.buffer,/obj/machinery/piratepad/civilian))
		to_chat(user, "<span class='notice'>You link [src] with [I.buffer] in [I] buffer.</span>")
		pad = I.buffer
		return TRUE

/obj/machinery/computer/piratepad_control/civilian/LateInitialize()
	. = ..()
	if(cargo_hold_id)
		for(var/obj/machinery/piratepad/civilian/C in GLOB.machines)
			if(C.cargo_hold_id == cargo_hold_id)
				pad = C
				return
	else
		pad = locate() in range(4,src)

/obj/machinery/computer/piratepad_control/civilian/recalc()
	if(sending)
		return FALSE
	if(!inserted_scan_id)
		status_report = "Please insert your ID first."
		playsound(loc, 'sound/machines/synth_no.ogg', 30 , TRUE)
		return FALSE
	if(!inserted_scan_id.registered_account.civilian_bounty)
		status_report = "Please accept a new civilian bounty first."
		playsound(loc, 'sound/machines/synth_no.ogg', 30 , TRUE)
		return FALSE
	status_report = "Civilian Bounty: "
	for(var/atom/movable/AM in get_turf(pad))
		if(AM == pad)
			continue
		if(inserted_scan_id.registered_account.civilian_bounty.applies_to(AM))
			status_report += "Target Applicable."
			playsound(loc, 'sound/machines/synth_yes.ogg', 30 , TRUE)
			return
	status_report += "Not Applicable."
	playsound(loc, 'sound/machines/synth_no.ogg', 30 , TRUE)

/**
  * This fully rewrites base behavior in order to only check for bounty objects, and nothing else.
  */
/obj/machinery/computer/piratepad_control/civilian/send()
	playsound(loc, 'sound/machines/wewewew.ogg', 70, TRUE)
	if(!sending)
		return
	if(!inserted_scan_id)
		stop_sending()
		return FALSE
	if(!inserted_scan_id.registered_account.civilian_bounty)
		stop_sending()
		return FALSE
	var/datum/bounty/curr_bounty = inserted_scan_id.registered_account.civilian_bounty
	var/active_stack = 0
	for(var/atom/movable/AM in get_turf(pad))
		if(AM == pad)
			continue
		if(curr_bounty.applies_to(AM))
			active_stack ++
			curr_bounty.ship(AM)
			qdel(AM)
	if(active_stack >= 1)
		status_report += "Bounty Target Found x[active_stack]. "
	else
		status_report = "No applicable targets found. Aborting."
		stop_sending()
	if(curr_bounty.can_claim())
		//Pay for the bounty with the ID's department funds.
		status_report += "Bounty Completed! Please send your completed bounty cube to cargo for your automated payout shortly."
		inserted_scan_id.registered_account.reset_bounty()
		SSeconomy.civ_bounty_tracker++
		var/obj/item/bounty_cube/reward = new /obj/item/bounty_cube(drop_location())
		reward.bounty_value = curr_bounty.reward
		reward.AddComponent(/datum/component/pricetag, inserted_scan_id.registered_account, 10)
	pad.visible_message("<span class='notice'>[pad] activates!</span>")
	flick(pad.sending_state,pad)
	pad.icon_state = pad.idle_state
	playsound(loc, 'sound/machines/synth_yes.ogg', 30 , TRUE)
	sending = FALSE

/obj/machinery/computer/piratepad_control/civilian/AltClick(mob/user)
	. = ..()
	id_eject(user, inserted_scan_id)

/obj/machinery/computer/piratepad_control/civilian/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CivCargoHoldTerminal", name)
		ui.open()

/obj/machinery/computer/piratepad_control/civilian/ui_data(mob/user)
	var/list/data = list()
	data["points"] = points
	data["pad"] = pad ? TRUE : FALSE
	data["sending"] = sending
	data["status_report"] = status_report
	data["id_inserted"] = inserted_scan_id
	if(inserted_scan_id?.registered_account)
		data["id_bounty_info"] = inserted_scan_id.registered_account.bounty_text()
		data["id_bounty_num"] = inserted_scan_id.registered_account.bounty_num()
		data["id_bounty_value"] = inserted_scan_id.registered_account.bounty_value()
	return data

/obj/machinery/computer/piratepad_control/civilian/ui_act(action, params)
	. = ..()
	if(.)
		return
	if(!pad)
		return
	if(!usr.canUseTopic(src, BE_CLOSE) || (machine_stat & (NOPOWER|BROKEN)))
		return
	switch(action)
		if("recalc")
			recalc()
		if("send")
			start_sending()
		if("stop")
			stop_sending()
		if("bounty")
			//Here is where cargo bounties are added to the player's bank accounts, then adjusted and scaled into a civilian bounty.
			if(!inserted_scan_id || !inserted_scan_id.registered_account)
				return
			var/datum/bank_account/pot_acc = inserted_scan_id.registered_account
			if(pot_acc.civilian_bounty && ((world.time) < pot_acc.bounty_timer + 5 MINUTES))
				var/curr_time = round(((pot_acc.bounty_timer + (5 MINUTES))-world.time)/ (1 MINUTES), 0.01)
				to_chat(usr, "<span class='warning'>You already have an incomplete civilian bounty, try again in [curr_time] minutes to replace it!</span>")
				return FALSE
			if(!pot_acc.account_job)
				to_chat(usr, "<span class='warning'>The console smartly rejects your ID card, as it lacks a job assignment!</span>")
				return FALSE
			var/datum/bounty/crumbs = random_bounty(pot_acc.account_job.bounty_types) //It's a good scene from War Dogs (2016).
			pot_acc.bounty_timer = world.time
			pot_acc.civilian_bounty = crumbs
		if("eject")
			id_eject(usr, inserted_scan_id)
	. = TRUE

///Self explanitory, holds the ID card inthe console for bounty payout and manipulation.
/obj/machinery/computer/piratepad_control/civilian/proc/id_insert(mob/user, obj/item/inserting_item, obj/item/target)
	var/obj/item/card/id/card_to_insert = inserting_item
	var/holder_item = FALSE

	if(!isidcard(card_to_insert))
		card_to_insert = inserting_item.RemoveID()
		holder_item = TRUE

	if(!card_to_insert || !user.transferItemToLoc(card_to_insert, src))
		return FALSE

	if(target)
		if(holder_item && inserting_item.InsertID(target))
			playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, FALSE)
		else
			id_eject(user, target)

	user.visible_message("<span class='notice'>[user] inserts \the [card_to_insert] into \the [src].</span>",
						"<span class='notice'>You insert \the [card_to_insert] into \the [src].</span>")
	playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, FALSE)
	updateUsrDialog()
	return TRUE

///Removes A stored ID card.
/obj/machinery/computer/piratepad_control/civilian/proc/id_eject(mob/user, obj/target)
	if(!target)
		to_chat(user, "<span class='warning'>That slot is empty!</span>")
		return FALSE
	else
		target.forceMove(drop_location())
		if(!issilicon(user) && Adjacent(user))
			user.put_in_hands(target)
		user.visible_message("<span class='notice'>[user] gets \the [target] from \the [src].</span>", \
							"<span class='notice'>You get \the [target] from \the [src].</span>")
		playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, FALSE)
		inserted_scan_id = null
		updateUsrDialog()
		return TRUE

///Upon completion of a civilian bounty, one of these is created. It is sold to cargo to give the cargo budget bounty money, and the person who completed it cash.
/obj/item/bounty_cube
	name = "Bounty Cube"
	desc = "A bundle of compressed hardlight data, containing a completed bounty. Sell this on the cargo shuttle to claim it!"
	icon = 'icons/obj/economy.dmi'
	icon_state = "bounty_cube"
	///Value of the bounty that this bounty cube sells for.
	var/bounty_value = 0

///Beacon to launch a new bounty setup when activated.
/obj/item/civ_bounty_beacon
	name = "civilian bounty beacon"
	desc = "N.T. approved civilian bounty beacon, toss it down and you will have a bounty pad and computer delivered to you."
	icon = 'icons/obj/objects.dmi'
	icon_state = "floor_beacon"
	var/uses = 2

/obj/item/civ_bounty_beacon/attack_self()
	loc.visible_message("<span class='warning'>\The [src] begins to beep loudly!</span>")
	addtimer(CALLBACK(src, .proc/launch_payload), 1 SECONDS)

/obj/item/civ_bounty_beacon/proc/launch_payload()
	playsound(src, "sparks", 80, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	switch(uses)
		if(2)
			new /obj/machinery/piratepad/civilian(drop_location())
		if(1)
			new /obj/machinery/computer/piratepad_control/civilian(drop_location())
			qdel(src)
	uses--
