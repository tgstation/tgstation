//Pad & Pad Terminal
/obj/machinery/piratepad/civilian
	name = "civilian bounty pad"
	icon = 'icons/obj/telescience.dmi'
	icon_state = "lpad-idle-o"
	idle_state = "lpad-idle-o"
	warmup_state = "lpad-idle"
	sending_state = "lpad-beam"

/obj/machinery/computer/piratepad_control/civilian
	name = "civilian bounty control terminal"
	ui_x = 600
	ui_y = 230
	status_report = "Ready for delivery."
	var/obj/item/card/id/inserted_scan_id

/obj/machinery/computer/piratepad_control/civilian/Initialize()
	. = ..()
	pad = /obj/machinery/piratepad/civilian

/obj/machinery/computer/piratepad_control/civilian/attackby(obj/item/I, mob/living/user, params)
	. = ..()
	if(isidcard(I))
		if(id_insert(user, I, inserted_scan_id))
			inserted_scan_id = I

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
		return FALSE
	if(!inserted_scan_id.registered_account.civilian_bounty)
		return FALSE
	status_report = "Civilian Bounty: "
	for(var/atom/movable/AM in get_turf(pad))
		if(AM == pad)
			continue
		if(inserted_scan_id.registered_account.civilian_bounty.applies_to(AM))
			status_report += "Target Applicable."
			return
	status_report += "Not Applicable."

/obj/machinery/computer/piratepad_control/civilian/send()
	if(!sending)
		return
	if(!inserted_scan_id)
		return FALSE
	if(!inserted_scan_id.registered_account.civilian_bounty)
		return FALSE
	var/datum/bounty/curr_bounty = inserted_scan_id.registered_account.civilian_bounty
	for(var/atom/movable/AM in get_turf(pad))
		if(AM == pad)
			continue
		if(curr_bounty.applies_to(AM))
			status_report += "Bounty Target Found. "
			curr_bounty.ship(AM)
			qdel(AM)
	if(curr_bounty.can_claim())
		//Pay for the bounty with the ID's department funds.
		inserted_scan_id.registered_account.transfer_money(SSeconomy.get_dep_account(inserted_scan_id.registered_account.account_job.paycheck_department), curr_bounty.reward)
		status_report += "Bounty Completed! [curr_bounty.reward] credits have been paid out. "
		inserted_scan_id.registered_account.reset_bounty()
	pad.visible_message("<span class='notice'>[pad] activates!</span>")
	flick(pad.sending_state,pad)
	pad.icon_state = pad.idle_state
	sending = FALSE

/obj/machinery/computer/piratepad_control/civilian/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
									datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "CivCargoHoldTerminal", name, ui_x, ui_y, master_ui, state)
		ui.open()

/obj/machinery/computer/piratepad_control/civilian/ui_data(mob/user)
	var/list/data = list()
	data["points"] = points
	data["pad"] = pad ? TRUE : FALSE
	data["sending"] = sending
	data["status_report"] = status_report
	data["id_inserted"] = inserted_scan_id
	if(inserted_scan_id && inserted_scan_id.registered_account)
		data["id_bounty_info"] = inserted_scan_id.registered_account.bounty_text()
		data["id_bounty_value"] = inserted_scan_id.registered_account.bounty_value()
	return data

/obj/machinery/computer/piratepad_control/civilian/ui_act(action, params)
	if(..())
		return
	if(!pad)
		return
	switch(action)
		if("recalc")
			recalc()
		if("send")
			start_sending()
		if("stop")
			stop_sending()
		if("bounty")
			if(!inserted_scan_id || !inserted_scan_id.registered_account)
				return
			var/datum/bank_account/pot_acc = inserted_scan_id.registered_account
			if(pot_acc.civilian_bounty && ((world.time) < pot_acc.bounty_timer + 5 MINUTES))
				to_chat(usr, "<span class='warning'>You already have a civilian bounty, try again in [(pot_acc.bounty_timer + 5 MINUTES)-world.time]!</span>")
				return FALSE
			var/datum/bounty/crumbs = random_bounty() //It's a good scene from War Dogs (2016).
			crumbs.reward = (crumbs.reward/ (rand(2,4)))
			pot_acc.bounty_timer = world.time
			pot_acc.civilian_bounty = crumbs
		if("eject")
			id_eject(usr, inserted_scan_id)
	. = TRUE


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


///Beacon to launch a new bounty setup when activated.
/obj/item/civ_bounty_beacon
	name = "civilian bounty beacon"
	desc = "N.T. approved civilian bounty beacon, toss it down and you will have a bounty pad and computer delivered to you."
	icon = 'icons/obj/objects.dmi'
	icon_state = "floor_beacon"
	var/uses = 2

/obj/item/civ_bounty_beacon/attack_self()
	loc.visible_message("<span class='warning'>\The [src] begins to beep loudly!</span>")
	addtimer(CALLBACK(src, .proc/launch_payload), 40)
	if(uses <= 0)
		qdel()

/obj/item/civ_bounty_beacon/proc/launch_payload()
	switch(uses)
		if(2)
			new /obj/machinery/piratepad/civilian(drop_location())
		if(1)
			new /obj/machinery/computer/piratepad_control/civilian(drop_location())
	uses = uses - 1
