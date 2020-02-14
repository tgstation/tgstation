/datum/wires/nuke
	holder_type = /obj/machinery/nuclearbomb
	randomize = TRUE
	var/false_cooldown = 0
	var/locked = FALSE
	var/fucked_up_once = FALSE
	var/list/defused = list()

/datum/wires/nuke/New(atom/holder)
	wires = list(
		WIRE_NUKE_ADVANCETIMER,
		WIRE_NUKE_ALARM,
		WIRE_NUKE_ANCHOR,
		WIRE_NUKE_DEFUSE_1,
		WIRE_NUKE_DEFUSE_2,
		WIRE_NUKE_DEFUSE_3,
		WIRE_NUKE_STOP_TIMER,
		WIRE_NUKE_HINT,
		WIRE_NUKE_HINT_2,
		WIRE_NUKE_FUCKUP_1,
		WIRE_NUKE_FUCKUP_2
	)
	add_duds(4)
	. = ..()

/datum/wires/nuke/interactable(mob/user)
	if(locked)
		return FALSE
	var/datum/antagonist/nukeop/user_antag = user.mind.has_antag_datum(/datum/antagonist/nukeop, TRUE)
	if(user_antag)
		return FALSE
	var/obj/machinery/nuclearbomb/nuke = holder
	if(nuke.deconstruction_state == NUKESTATE_UNSCREWED)
		return TRUE

/datum/wires/nuke/on_pulse(wire, user)
	var/obj/machinery/nuclearbomb/nuke = holder
	switch(wire)
		if(WIRE_NUKE_ADVANCETIMER)
			nuke.detonation_timer -= 10 SECONDS
			playsound(src, 'sound/machines/nuke/angry_beep.ogg', 60)
			to_chat(user, "<span class='warning'>The console beeps menacingly!</span>")
		if(WIRE_NUKE_ALARM)
			if(false_cooldown < world.time)
				playsound(src, 'sound/machines/alarm.ogg', 100, FALSE)
				to_chat(user, "<span class='userdanger'>OH SHIT!</span>")
				false_cooldown = world.time + 20 SECONDS
		if(WIRE_NUKE_DEFUSE_1)
			to_chat(user, "<span class='warning'>The console buzzes reassuringly.</span>")
			playsound(src, 'sound/machines/nuke/confirm_beep.ogg', 80)
		if(WIRE_NUKE_ANCHOR)
			to_chat(user, "<span class='warning'>You hear a grinding noise from deep within the mechanism.</span>")
		if(WIRE_NUKE_HINT)
			to_chat(user, "<span class='notice'>A spark flies off of the [get_color_of_wire(WIRE_NUKE_FUCKUP_1)] wire.</span>")
		if(WIRE_NUKE_HINT_2)
			to_chat(user, "<span class='notice'>The various lights flicker briefly.</span>")

/datum/wires/nuke/on_cut(wire, mend, user)
	var/obj/machinery/nuclearbomb/nuke = holder
	switch(wire)
		if(WIRE_NUKE_ADVANCETIMER)
			nuke.detonation_timer -= 1 MINUTES
			playsound(src, 'sound/machines/nuke/angry_beep.ogg', 100)
			to_chat(user, "<span class='danger'>That doesn't seem good...</span>")
		if(WIRE_NUKE_ANCHOR)
			nuke.set_anchor()
		if(WIRE_NUKE_HINT)
			to_chat(user, "<span class='notice'>The [get_color_of_wire(WIRE_NUKE_FUCKUP_2)] wire briefly visibly heats up.</span>")
		if(WIRE_NUKE_HINT_2)
			to_chat(user, "<span class='notice'>A [get_color_of_wire(WIRE_NUKE_DEFUSE_2)] light turns on briefly</span>")
		if(WIRE_NUKE_DEFUSE_1)
			defuse(WIRE_NUKE_DEFUSE_1, mend)
		if(WIRE_NUKE_DEFUSE_2)
			defuse(WIRE_NUKE_DEFUSE_2, mend)
		if(WIRE_NUKE_DEFUSE_3)
			defuse(WIRE_NUKE_DEFUSE_3, mend)
		if(WIRE_NUKE_FUCKUP_1)
			fuckup()
		if(WIRE_NUKE_FUCKUP_2)
			fuckup()

/datum/wires/nuke/proc/defuse(source, mend)
	if(mend)
		(!(source in defused))
			return
		defused -= source
	else
		if(source in defused)
			return
		defused += source
	var/obj/machinery/nuclearbomb/nuke = holder
	if(length(defused) >= 3)
		nuke.set_active(defuse = TRUE)



/datum/wires/nuke/proc/fuckup()
	var/obj/machinery/nuclearbomb/nuke = holder
	if(fucked_up_once)
		nuke.visible_message("<span class='danger'>The panel explodes into a shower of sparks, completely frying the circuitry!</span>")
		nuke.visible_message("<span class='userdanger'>It's still ticking!!</span>")
		locked = TRUE
	else
		nuke.visible_message("span class='danger'>Never made that sound before...</span>")
		playsound(src, 'sound/machines/nuke/angry_beep.ogg', 100)
		playsound(src, 'sound/machines/nuke/confirm_beep.ogg', 100)
		var/to_be_halved = nuke.detonation_timer - world.time
		nuke.detonation_timer = world.time + (to_be_halved / 2)
		fucked_up_once = TRUE
