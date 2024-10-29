#define SHEET_POINT_VALUE 33

/**********************Prisoners' Console**************************/

/obj/machinery/mineral/labor_claim_console
	name = "point claim console"
	desc = "A stacking console with an electromagnetic writer, used to track ore mined by prisoners."
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "console"
	density = FALSE
	/// Connected stacking machine
	var/obj/machinery/mineral/stacking_machine/laborstacker/stacking_machine
	/// Needed to send messages to sec radio
	var/obj/item/radio/security_radio

/obj/machinery/mineral/labor_claim_console/Initialize(mapload)
	. = ..()
	security_radio = new /obj/item/radio(src)
	security_radio.set_listening(FALSE)
	locate_stacking_machine()
	//If we can't find a stacking machine end it all ok?
	if(!stacking_machine)
		return INITIALIZE_HINT_QDEL

/obj/machinery/mineral/labor_claim_console/Destroy()
	QDEL_NULL(security_radio)
	if(stacking_machine)
		stacking_machine.labor_console = null
		stacking_machine = null
	return ..()

/proc/cmp_sheet_list(list/a, list/b)
	return a["value"] - b["value"]

/obj/machinery/mineral/labor_claim_console/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "LaborClaimConsole", name)
		ui.open()

/obj/machinery/mineral/labor_claim_console/ui_data(mob/user)
	var/list/data = list()
	var/can_go_home = FALSE

	if(obj_flags & EMAGGED)
		can_go_home = TRUE
	var/obj/item/card/id/worn_id
	if(isliving(user))
		var/mob/living/living_user = user
		worn_id = living_user.get_idcard(TRUE)
	if(istype(worn_id, /obj/item/card/id/advanced/prisoner))
		var/obj/item/card/id/advanced/prisoner/worn_prisoner_id = worn_id
		data["id_points"] = worn_prisoner_id.points
		if(!worn_prisoner_id.goal)
			data["status_info"] = "No goal set!"
		else if(worn_prisoner_id.points >= worn_prisoner_id.goal)
			can_go_home = TRUE
			data["status_info"] = "Goal met!"
		else
			data["status_info"] = "You are [(worn_prisoner_id.goal - worn_prisoner_id.points)] points away."
	else
		data["status_info"] = "No Prisoner ID detected."
		data["id_points"] = 0

	if(stacking_machine)
		data["unclaimed_points"] = stacking_machine.points

	data["can_go_home"] = can_go_home
	return data

/obj/machinery/mineral/labor_claim_console/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/mob/user_mob = usr

	switch(action)

		if("claim_points")
			var/obj/item/card/id/worn_id
			if(isliving(user_mob))
				var/mob/living/living_mob = user_mob
				worn_id = living_mob.get_idcard(TRUE)
			if(istype(worn_id, /obj/item/card/id/advanced/prisoner))
				var/obj/item/card/id/advanced/prisoner/worn_prisoner_id = worn_id
				worn_prisoner_id.points += stacking_machine.points
				stacking_machine.points = 0
				to_chat(user_mob, span_notice("Points transferred."))
				return TRUE
			else
				to_chat(user_mob, span_alert("No valid id for point transfer detected."))

		if("move_shuttle")
			if(!alone_in_area(get_area(src), user_mob))
				to_chat(user_mob, span_alert("Prisoners are only allowed to be released while alone."))
				return

			switch(SSshuttle.moveShuttle("laborcamp", "laborcamp_home", TRUE))
				if(1)
					to_chat(user_mob, span_alert("Shuttle not found."))
				if(2)
					to_chat(user_mob, span_alert("Shuttle already at station."))
				if(3)
					to_chat(user_mob, span_alert("No permission to dock could be granted."))
				else
					if(!(obj_flags & EMAGGED))
						security_radio.set_frequency(FREQ_SECURITY)
						var/datum/record/crew/target = find_record(user_mob.real_name)
						target?.wanted_status = WANTED_PAROLE

						security_radio.talk_into(src, "[user_mob.name] returned to the station. Minerals and Prisoner ID card ready for retrieval.", FREQ_SECURITY)
					user_mob.log_message("has completed their labor points goal and is now sending the gulag shuttle back to the station.", LOG_GAME)
					to_chat(user_mob, span_notice("Shuttle received message and will be sent shortly."))
					return TRUE

/obj/machinery/mineral/labor_claim_console/proc/locate_stacking_machine()
	stacking_machine = locate(/obj/machinery/mineral/stacking_machine) in dview(2, get_turf(src))
	if(stacking_machine)
		stacking_machine.labor_console = src

/obj/machinery/mineral/labor_claim_console/emag_act(mob/user, obj/item/card/emag/emag_card)
	if (obj_flags & EMAGGED)
		return FALSE

	obj_flags |= EMAGGED
	balloon_alert(user, "id authenticator short-circuited")
	visible_message(span_warning("[src] lets out a few sparks!"))
	do_sparks(2, TRUE, src)
	return TRUE

/**********************Prisoner Collection Unit**************************/

/obj/machinery/mineral/stacking_machine/laborstacker
	force_connect = TRUE
	damage_deflection = 21 //otherwise prisoners will destroy it
	///Idle points sitting in the machine left to be claimed.
	var/points = 0
	///Labor claim console synced to our stacking machine, set by the console.
	var/obj/machinery/mineral/labor_claim_console/labor_console

/obj/machinery/mineral/stacking_machine/laborstacker/Destroy()
	if(labor_console)
		labor_console.stacking_machine = null
		labor_console = null
	return ..()

/obj/machinery/mineral/stacking_machine/laborstacker/process_sheet(obj/item/stack/sheet/input)
	if (input.manufactured && input.gulag_valid)
		points += SHEET_POINT_VALUE * input.amount
	return ..()

/obj/machinery/mineral/stacking_machine/laborstacker/attackby(obj/item/weapon, mob/user, params)
	if(istype(weapon, /obj/item/stack/sheet))
		process_sheet(weapon)
		return
	return ..()

/**********************Point Lookup Console**************************/

/obj/machinery/mineral/labor_points_checker
	name = "points checking console"
	desc = "A console used by prisoners to check the progress on their quotas. Simply swipe a prisoner ID."
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "console"
	density = FALSE

/obj/machinery/mineral/labor_points_checker/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(. || user.is_blind())
		return
	user.examinate(src)

/obj/machinery/mineral/labor_points_checker/attackby(obj/item/weapon, mob/user, params)
	if(!istype(weapon, /obj/item/card/id/advanced/prisoner))
		return ..()
	var/obj/item/card/id/advanced/prisoner/prisoner_id = weapon
	if(!prisoner_id.goal) //no goal to reach
		say("No goal required for this ID.")
		return
	say("ID: [prisoner_id.registered_name].")
	say("Points Collected: [prisoner_id.points] / [prisoner_id.goal].")
	say("Collect points by bringing smelted minerals to the Labor Shuttle stacking machine. Reach your quota to earn your release.")

#undef SHEET_POINT_VALUE
