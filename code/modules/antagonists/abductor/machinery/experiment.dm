/obj/machinery/abductor/experiment
	name = "experimentation machine"
	desc = "A large man-sized tube sporting a complex array of surgical machinery."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "experiment-open"
	density = FALSE
	state_open = TRUE
	var/points = 0
	var/credits = 0
	var/list/history
	var/list/abductee_minds
	/// Machine feedback message
	var/flash = "Awaiting subject."
	var/obj/machinery/abductor/console/console
	var/message_cooldown = 0
	var/breakout_time = 450

/obj/machinery/abductor/experiment/Destroy()
	if(console)
		console.experiment = null
		console = null
	return ..()

/obj/machinery/abductor/experiment/MouseDrop_T(mob/target, mob/user)
	if(user.stat != CONSCIOUS || HAS_TRAIT(user, TRAIT_UI_BLOCKED) || !Adjacent(user) || !target.Adjacent(user) || !ishuman(target))
		return
	if(isabductor(target))
		return
	close_machine(target)

/obj/machinery/abductor/experiment/open_machine()
	if(!state_open && !panel_open)
		..()

/obj/machinery/abductor/experiment/close_machine(mob/target)
	for(var/A in loc)
		if(isabductor(A))
			return
	if(state_open && !panel_open)
		..(target)

/obj/machinery/abductor/experiment/relaymove(mob/living/user, direction)
	if(user.stat != CONSCIOUS)
		return
	if(message_cooldown <= world.time)
		message_cooldown = world.time + 50
		to_chat(user, span_warning("[src]'s door won't budge!"))

/obj/machinery/abductor/experiment/container_resist_act(mob/living/user)
	user.changeNext_move(CLICK_CD_BREAKOUT)
	user.last_special = world.time + CLICK_CD_BREAKOUT
	user.visible_message(span_notice("You see [user] kicking against the door of [src]!"), \
		span_notice("You lean on the back of [src] and start pushing the door open... (this will take about [DisplayTimeText(breakout_time)].)"), \
		span_hear("You hear a metallic creaking from [src]."))
	if(do_after(user,(breakout_time), target = src))
		if(!user || user.stat != CONSCIOUS || user.loc != src || state_open)
			return
		user.visible_message(span_warning("[user] successfully broke out of [src]!"), \
			span_notice("You successfully break out of [src]!"))
		open_machine()

/obj/machinery/abductor/experiment/ui_status(mob/user)
	if(user == occupant)
		return UI_CLOSE
	return ..()

/obj/machinery/abductor/experiment/ui_state(mob/user)
	return GLOB.physical_state

/obj/machinery/abductor/experiment/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ProbingConsole", name)
		ui.open()

/obj/machinery/abductor/experiment/ui_data(mob/user)
	var/list/data = list()
	data["open"] = state_open
	data["feedback"] = flash
	data["occupant"] = occupant ? TRUE : FALSE
	data["occupant_name"] = null
	data["occupant_status"] = null
	if(occupant)
		var/mob/living/mob_occupant = occupant
		data["occupant_name"] = mob_occupant.name
		data["occupant_status"] = mob_occupant.stat
	return data

/obj/machinery/abductor/experiment/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		if("door")
			if(state_open)
				close_machine()
				return TRUE
			else
				open_machine()
				return TRUE
		if("experiment")
			if(!occupant)
				return
			var/mob/living/mob_occupant = occupant
			if(mob_occupant.stat == DEAD)
				return
			flash = experiment(mob_occupant, params["experiment_type"], usr)
			return TRUE

/**
 * experiment: Performs selected experiment on occupant mob, resulting in a point reward on success
 *
 * Arguments:
 * * occupant The mob inside the machine
 * * type The type of experiment to be performed
 * * user The mob starting the experiment
 */
/obj/machinery/abductor/experiment/proc/experiment(mob/occupant, type, mob/user)
	LAZYINITLIST(history)
	var/mob/living/carbon/human/H = occupant

	var/datum/antagonist/abductor/user_abductor = user.mind.has_antag_datum(/datum/antagonist/abductor)
	if(!user_abductor)
		return "Authorization failure. Contact mothership immediately."

	var/point_reward = 0
	if(!H)
		return "Invalid or missing specimen."
	if(H in history)
		return "Specimen already in database."
	if(H.stat == DEAD)
		say("Specimen deceased - please provide fresh sample.")
		return "Specimen deceased."
	var/obj/item/organ/internal/heart/gland/GlandTest = locate() in H.internal_organs
	if(!GlandTest)
		say("Experimental dissection not detected!")
		return "No glands detected!"
	if(H.mind != null && H.ckey != null)
		LAZYINITLIST(abductee_minds)
		LAZYADD(history, H)
		LAZYADD(abductee_minds, H.mind)
		say("Processing specimen...")
		sleep(0.5 SECONDS)
		switch(text2num(type))
			if(1)
				to_chat(H, span_warning("You feel violated."))
			if(2)
				to_chat(H, span_warning("You feel yourself being sliced apart and put back together."))
			if(3)
				to_chat(H, span_warning("You feel intensely watched."))
		sleep(0.5 SECONDS)
		user_abductor.team.abductees += H.mind
		H.mind.add_antag_datum(/datum/antagonist/abductee)

		for(var/obj/item/organ/internal/heart/gland/G in H.internal_organs)
			G.Start()
			point_reward++
		if(point_reward > 0)
			open_machine()
			send_back(H)
			playsound(src.loc, 'sound/machines/ding.ogg', 50, TRUE)
			points += point_reward
			credits += point_reward
			return "Experiment successful! [point_reward] new data-points collected."
		else
			playsound(src.loc, 'sound/machines/buzz-sigh.ogg', 50, TRUE)
			return "Experiment failed! No replacement organ detected."
	else
		say("Brain activity nonexistent - disposing sample...")
		open_machine()
		send_back(H)
		return "Specimen braindead - disposed."

/**
 * send_back: Sends a mob back to a selected teleport location if safe
 *
 * Arguments:
 * * H The human mob to be sent back
 */
/obj/machinery/abductor/experiment/proc/send_back(mob/living/carbon/human/H)
	H.Sleeping(160)
	H.uncuff()
	if(console && console.pad && console.pad.teleport_target)
		H.forceMove(console.pad.teleport_target)
		return
	//Area not chosen / It's not safe area - teleport to arrivals
	SSjob.SendToLateJoin(H, FALSE)
	return

/obj/machinery/abductor/experiment/update_icon_state()
	icon_state = "experiment[state_open ? "-open" : null]"
	return ..()
