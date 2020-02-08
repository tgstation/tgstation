/obj/machinery/hypnochair
	name = "enhanced interrogation chamber"
	desc = "A device used to perform \"enhanced interrogation\" through invasive mental conditioning."
	icon = 'icons/obj/machines/implantchair.dmi'
	icon_state = "hypnochair"
	circuit = /obj/item/circuitboard/machine/hypnochair
	density = TRUE
	opacity = 0
	ui_x = 375
	ui_y = 480
	var/mob/living/carbon/victim = null ///Keeps track of the victim to apply effects if it teleports away
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
	victim = C
	if(!(C.get_eye_protection() > 0))
		to_chat(C, "<span class='warning'>Strobing coloured lights assault you relentlessly! You're losing your ability to think straight!</span>")
		C.become_blind("hypnochair")
		ADD_TRAIT(C, TRAIT_DEAF, "hypnochair")
	interrogating = TRUE
	START_PROCESSING(SSobj, src)
	start_time = world.time
	update_icon()
	timerid = addtimer(CALLBACK(src, .proc/finish_interrogation), 450, TIMER_STOPPABLE)

/obj/machinery/hypnochair/process()
	var/mob/living/carbon/C = occupant
	if(!istype(C) || C != victim)
		interrupt_interrogation()
		return
	if(prob(10) && !(C.get_eye_protection() > 0))
		to_chat(C, "<span class='hypnophrase'>[pick(\
			"...blue... red... green... blue, red, green, blueredgreen<span class='small'>blueredgreen</span>",\
			"...pretty colors...",\
			"...you keep hearing words, but you can't seem to understand them...",\
			"...so peaceful...",\
			"...an annoying buzz in your ears..."\
		)]</span>")

/obj/machinery/hypnochair/proc/finish_interrogation()
	interrogating = FALSE
	STOP_PROCESSING(SSobj, src)
	update_icon()
	var/temp_trigger = trigger_phrase
	trigger_phrase = "" //Erase evidence, in case the subject is able to look at the panel afterwards
	audible_message("<span class='notice'>[src] pings!</span>")
	playsound(src, 'sound/machines/ping.ogg', 30, TRUE)

	if(QDELETED(victim) || victim != occupant)
		victim = null
		return
	victim.cure_blind("hypnochair")
	REMOVE_TRAIT(victim, TRAIT_DEAF, "hypnochair")
	if(!(victim.get_eye_protection() > 0))
		victim.cure_trauma_type(/datum/brain_trauma/severe/hypnotic_trigger, TRAUMA_RESILIENCE_SURGERY)
		if(prob(90))
			victim.gain_trauma(new /datum/brain_trauma/severe/hypnotic_trigger(temp_trigger), TRAUMA_RESILIENCE_SURGERY)
		else
			victim.gain_trauma(new /datum/brain_trauma/severe/hypnotic_stupor(), TRAUMA_RESILIENCE_SURGERY)
	victim = null

/obj/machinery/hypnochair/proc/interrupt_interrogation()
	deltimer(timerid)
	interrogating = FALSE
	STOP_PROCESSING(SSobj, src)
	update_icon()

	if(QDELETED(victim))
		victim = null
		return
	victim.cure_blind("hypnochair")
	REMOVE_TRAIT(victim, TRAIT_DEAF, "hypnochair")
	if(!(victim.get_eye_protection() > 0))
		var/time_diff = world.time - start_time
		switch(time_diff)
			if(0 to 100)
				victim.confused += 10
				victim.Dizzy(100)
				victim.blur_eyes(5)
			if(101 to 200)
				victim.confused += 15
				victim.Dizzy(200)
				victim.blur_eyes(10)
				if(prob(25))
					victim.apply_status_effect(/datum/status_effect/trance, rand(50,150), FALSE)
			if(201 to INFINITY)
				victim.confused += 20
				victim.Dizzy(300)
				victim.blur_eyes(15)
				if(prob(65))
					victim.apply_status_effect(/datum/status_effect/trance, rand(50,150), FALSE)
	victim = null

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

