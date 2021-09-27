/obj/item/pinpointer/nuke
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/mode = TRACK_NUKE_DISK

/obj/item/pinpointer/nuke/examine(mob/user)
	. = ..()
	var/msg = "Its tracking indicator reads "
	switch(mode)
		if(TRACK_NUKE_DISK)
			msg += "\"nuclear_disk\"."
		if(TRACK_MALF_AI)
			msg += "\"01000001 01001001\"."
		if(TRACK_INFILTRATOR)
			msg += "\"vasvygengbefuvc\"."
		else
			msg = "Its tracking indicator is blank."
	. += msg
	for(var/obj/machinery/nuclearbomb/bomb in GLOB.machines)
		if(bomb.timing)
			. += "Extreme danger. Arming signal detected. Time remaining: [bomb.get_time_left()]."

/obj/item/pinpointer/nuke/process(delta_time)
	..()
	if(!active || alert)
		return
	for(var/obj/machinery/nuclearbomb/bomb as anything in GLOB.nuke_list)
		if(!bomb.timing)
			continue
		alert = TRUE
		playsound(src, 'sound/items/nuke_toy_lowpower.ogg', 50, FALSE)
		if(isliving(loc))
			var/mob/living/alerted_holder = loc
			to_chat(alerted_holder, span_userdanger("Your [name] vibrates and lets out an ominous alarm. Uh oh."))
		return

/obj/item/pinpointer/nuke/scan_for_target()
	target = null
	switch(mode)
		if(TRACK_NUKE_DISK)
			var/obj/item/disk/nuclear/N = locate() in SSpoints_of_interest.real_nuclear_disks
			target = N
		if(TRACK_MALF_AI)
			for(var/V in GLOB.ai_list)
				var/mob/living/silicon/ai/A = V
				if(A.nuking)
					target = A
			for(var/V in GLOB.apcs_list)
				var/obj/machinery/power/apc/A = V
				if(A.malfhack && A.occupier)
					target = A
		if(TRACK_INFILTRATOR)
			target = SSshuttle.getShuttle("syndicate")
	..()

/obj/item/pinpointer/nuke/proc/switch_mode_to(new_mode)
	if(isliving(loc))
		var/mob/living/L = loc
		to_chat(L, span_userdanger("Your [name] beeps as it reconfigures it's tracking algorithms."))
		playsound(L, 'sound/machines/triple_beep.ogg', 50, TRUE)
	mode = new_mode
	scan_for_target()

/obj/item/pinpointer/nuke/syndicate // Syndicate pinpointers automatically point towards the infiltrator once the nuke is active.
	name = "syndicate pinpointer"
	desc = "A handheld tracking device that locks onto certain signals. It's configured to switch tracking modes once it detects the activation signal of a nuclear device."
	icon_state = "pinpointer_syndicate"
	worn_icon_state = "pinpointer_black"

/obj/item/pinpointer/syndicate_cyborg // Cyborg pinpointers just look for a random operative.
	name = "cyborg syndicate pinpointer"
	desc = "An integrated tracking device, jury-rigged to search for living Syndicate operatives."
	flags_1 = NONE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/item/pinpointer/syndicate_cyborg/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CYBORG_ITEM_TRAIT)

/obj/item/pinpointer/syndicate_cyborg/cyborg_unequip(mob/user)
	if(!active)
		return
	toggle_on()

/obj/item/pinpointer/syndicate_cyborg/scan_for_target()
	target = null
	var/list/possible_targets = list()
	var/turf/here = get_turf(src)
	for(var/V in get_antag_minds(/datum/antagonist/nukeop))
		var/datum/mind/M = V
		if(ishuman(M.current) && M.current.stat != DEAD)
			possible_targets |= M.current
	var/mob/living/closest_operative = get_closest_atom(/mob/living/carbon/human, possible_targets, here)
	if(closest_operative)
		target = closest_operative
	..()
