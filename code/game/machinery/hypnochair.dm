/obj/machinery/hypnochair
	name = "enhanced interrogation chamber"
	desc = "A device used to perform \"enhanced interrogation\" through invasive mental conditioning."
	icon = 'icons/obj/machines/implantchair.dmi'
	icon_state = "hypnochair"
	circuit = /obj/item/circuitboard/machine/hypnochair
	density = TRUE
	opacity = 0
	ui_x = 375
	ui_y = 280
	var/interrogating = FALSE ///Is the device currently interrogating someone?
	var/start_time = 0 ///Time when the interrogation was started, to calculate effect in case of interruption
	var/trigger_phrase = "" ///Trigger phrase to implant
	var/timerid = 0 ///Timer ID for interrogations

	var/message_cooldown = 0 ///Cooldown for breakout message

/obj/machinery/hypnochair/Initialize()
	. = ..()
	open_machine()
	update_icon()

/obj/machinery/hypnochair/attackby(obj/item/I, mob/user, params)
	if(!occupant && default_deconstruction_screwdriver(user, icon_state, icon_state, I))
		update_icon()
		return

	if(default_pry_open(I))
		return

	if(default_deconstruction_crowbar(I))
		return

	return ..()

/obj/machinery/hypnochair/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.notcontained_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "hypnochair", name, ui_x, ui_y, master_ui, state)
		ui.open()

/obj/machinery/hypnochair/ui_data()
	var/list/data = list()
	data["occupied"] = occupant ? 1 : 0
	data["open"] = state_open
	data["interrogating"] = interrogating

	data["occupant"] = list()
	if(occupant)
		var/mob/living/mob_occupant = occupant
		data["occupant"]["name"] = mob_occupant.name
		data["occupant"]["stat"] = mob_occupant.stat

	data["trigger"] = trigger_phrase

	return data

/obj/machinery/hypnochair/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("door")
			if(state_open)
				close_machine()
			else
				if(!interrogating)
					open_machine()
			. = TRUE
		if("set_phrase")
			set_phrase(params["phrase"])
			. = TRUE
		if("interrogate")
			if(!interrogating)
				interrogate()
			else
				interrupt_interrogation()
			. = TRUE

/obj/machinery/hypnochair/proc/set_phrase(phrase)
	trigger_phrase = phrase

/obj/machinery/hypnochair/proc/interrogate()
	if(!trigger_phrase)
		playsound(get_turf(src), 'sound/machines/buzz-sigh.ogg', 25, TRUE)
		return
	var/mob/living/carbon/C = occupant
	if(!istype(C))
		playsound(get_turf(src), 'sound/machines/buzz-sigh.ogg', 25, TRUE)
		return
	to_chat(C, "<span class='warning'>Strobing coloured lights assault you relentlessly! You're losing your ability to think straight!</span>")
	interrogating = TRUE
	start_time = world.time
	update_icon()
	timerid = addtimer(CALLBACK(src, .proc/finish_interrogation), 450, TIMER_STOPPABLE)

/obj/machinery/hypnochair/proc/finish_interrogation()
	interrogating = FALSE
	update_icon()
	var/temp_trigger = trigger_phrase
	trigger_phrase = "" //Erase evidence, in case the subject is able to look at the panel afterwards
	audible_message("<span class='notice'>[src] pings!</span>")
	playsound(src, 'sound/machines/ping.ogg', 30, TRUE)

	var/mob/living/carbon/C = occupant
	if(!istype(C))
		return
	C.cure_trauma_type(/datum/brain_trauma/severe/hypnotic_trigger, TRAUMA_RESILIENCE_SURGERY)
	if(prob(90))
		C.gain_trauma(new /datum/brain_trauma/severe/hypnotic_trigger(temp_trigger), TRAUMA_RESILIENCE_SURGERY)
	else
		C.gain_trauma(new /datum/brain_trauma/severe/hypnotic_stupor(), TRAUMA_RESILIENCE_SURGERY)

/obj/machinery/hypnochair/proc/interrupt_interrogation()
	deltimer(timerid)
	interrogating = FALSE
	update_icon()

	var/mob/living/carbon/C = occupant
	if(!istype(C))
		return
	var/time_diff = world.time - start_time
	switch(time_diff)
		if(0 to 100)
			C.confused += 10
			C.Dizzy(100)
			C.blur_eyes(5)
		if(101 to 200)
			C.confused += 15
			C.Dizzy(200)
			C.blur_eyes(10)
			if(prob(25))
				C.apply_status_effect(/datum/status_effect/trance, rand(50,150), FALSE)
		if(201 to INFINITY)
			C.confused += 20
			C.Dizzy(300)
			C.blur_eyes(15)
			if(prob(65))
				C.apply_status_effect(/datum/status_effect/trance, rand(50,150), FALSE)

/obj/machinery/hypnochair/update_icon_state()
	icon_state = initial(icon_state)
	if(state_open)
		icon_state += "_open"
	if(occupant)
		if(interrogating)
			icon_state += "_active"
		else
			icon_state += "_occupied"

/obj/machinery/hypnochair/container_resist(mob/living/user)
	user.changeNext_move(CLICK_CD_BREAKOUT)
	user.last_special = world.time + CLICK_CD_BREAKOUT
	user.visible_message("<span class='notice'>You see [user] kicking against the door of [src]!</span>", \
		"<span class='notice'>You lean on the back of [src] and start pushing the door open... (this will take about [DisplayTimeText(600)].)</span>", \
		"<span class='hear'>You hear a metallic creaking from [src].</span>")
	if(do_after(user,(600), target = src))
		if(!user || user.stat != CONSCIOUS || user.loc != src || state_open)
			return
		user.visible_message("<span class='warning'>[user] successfully broke out of [src]!</span>", \
			"<span class='notice'>You successfully break out of [src]!</span>")
		open_machine()

/obj/machinery/hypnochair/relaymove(mob/user)
	if(message_cooldown <= world.time)
		message_cooldown = world.time + 50
		to_chat(user, "<span class='warning'>[src]'s door won't budge!</span>")

/obj/machinery/hypnochair/MouseDrop_T(mob/target, mob/user)
	if(user.stat || !Adjacent(user) || !user.Adjacent(target) || !isliving(target) || !user.IsAdvancedToolUser())
		return
	if(isliving(user))
		var/mob/living/L = user
		if(!(L.mobility_flags & MOBILITY_STAND))
			return
	close_machine(target)

