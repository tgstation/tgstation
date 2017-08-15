/obj/item/weapon/pinpointer/nuke
	var/mode = TRACK_NUKE_DISK

/obj/item/weapon/pinpointer/nuke/examine(mob/user)
	..()
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
	to_chat(user, msg)
	for(var/obj/machinery/nuclearbomb/bomb in GLOB.machines)
		if(bomb.timing)
			to_chat(user, "Extreme danger. Arming signal detected. Time remaining: [bomb.get_time_left()]")

/obj/item/weapon/pinpointer/nuke/process()
	..()
	if(active) // If shit's going down
		for(var/obj/machinery/nuclearbomb/bomb in GLOB.nuke_list)
			if(bomb.timing)
				if(!alert)
					alert = TRUE
					playsound(src, 'sound/items/nuke_toy_lowpower.ogg', 50, 0)
					if(isliving(loc))
						var/mob/living/L = loc
						to_chat(L, "<span class='userdanger'>Your [name] vibrates and lets out a tinny alarm. Uh oh.</span>")


/obj/item/weapon/pinpointer/nuke/scan_for_target()
	target = null
	switch(mode)
		if(TRACK_NUKE_DISK)
			var/obj/item/weapon/disk/nuclear/N = locate() in GLOB.poi_list
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

/obj/item/weapon/pinpointer/nuke/proc/switch_mode_to(new_mode)
	if(isliving(loc))
		var/mob/living/L = loc
		to_chat(L, "<span class='userdanger'>Your [name] beeps as it reconfigures its tracking algorithms.</span>")
		playsound(L, 'sound/machines/triple_beep.ogg', 50, 1)
	mode = new_mode
	scan_for_target()


/obj/item/weapon/pinpointer/nuke/syndicate // Syndicate pinpointers automatically point towards the infiltrator once the nuke is active.
	name = "syndicate pinpointer"
	desc = "A handheld tracking device that locks onto certain signals. It's configured to switch tracking modes once it detects the activation signal of a nuclear device."

/obj/item/weapon/pinpointer/syndicate_cyborg // Cyborg pinpointers just look for a random operative.
	name = "cyborg syndicate pinpointer"
	desc = "An integrated tracking device, jury-rigged to search for living Syndicate operatives."
	flags = NODROP

/obj/item/weapon/pinpointer/syndicate_cyborg/scan_for_target()
	target = null
	var/list/possible_targets = list()
	var/turf/here = get_turf(src)
	for(var/V in SSticker.mode.syndicates)
		var/datum/mind/M = V
		if(M.current && M.current.stat != DEAD)
			possible_targets |= M.current
	var/mob/living/closest_operative = get_closest_atom(/mob/living/carbon/human, possible_targets, here)
	if(closest_operative)
		target = closest_operative
	..()

/obj/item/weapon/pinpointer/crew
	name = "crew pinpointer"
	desc = "A handheld tracking device that points to crew suit sensors."
	icon_state = "pinpointer_crew"

/obj/item/weapon/pinpointer/crew/proc/trackable(mob/living/carbon/human/H)
	var/turf/here = get_turf(src)
	if((H.z == 0 || H.z == here.z) && istype(H.w_uniform, /obj/item/clothing/under))
		var/obj/item/clothing/under/U = H.w_uniform

		// Suit sensors must be on maximum.
		if(!U.has_sensor || U.sensor_mode < SENSOR_COORDS)
			return FALSE

		var/turf/there = get_turf(H)
		return (H.z != 0 || (there && there.z == H.z))

	return FALSE

/obj/item/weapon/pinpointer/crew/attack_self(mob/living/user)
	if(active)
		active = FALSE
		user.visible_message("<span class='notice'>[user] deactivates their pinpointer.</span>", "<span class='notice'>You deactivate your pinpointer.</span>")
		playsound(user, 'sound/items/screwdriver2.ogg', 50, 1)
		target = null //Restarting the pinpointer forces a target reset
		STOP_PROCESSING(SSfastprocess, src)
		update_pointer_overlay()
		return

	var/list/name_counts = list()
	var/list/names = list()

	for(var/mob/living/carbon/human/H in GLOB.mob_list)
		if(!trackable(H))
			continue

		var/name = "Unknown"
		if(H.wear_id)
			var/obj/item/weapon/card/id/I = H.wear_id.GetID()
			name = I.registered_name

		while(name in name_counts)
			name_counts[name]++
			name = text("[] ([])", name, name_counts[name])
		names[name] = H
		name_counts[name] = 1

	if(names.len == 0)
		user.visible_message("<span class='notice'>[user]'s pinpointer fails to detect a signal.</span>", "<span class='notice'>Your pinpointer fails to detect a signal.</span>")
		return

	var/A = input(user, "Person to track", "Pinpoint") in names
	if(!src || QDELETED(src) || !user || !user.is_holding(src) || user.incapacitated() || !A)
		return

	target = names[A]
	active = TRUE
	user.visible_message("<span class='notice'>[user] activates their pinpointer.</span>", "<span class='notice'>You activate your pinpointer.</span>")
	playsound(user, 'sound/items/screwdriver2.ogg', 50, 1)
	START_PROCESSING(SSfastprocess, src)
	update_pointer_overlay()

/obj/item/weapon/pinpointer/crew/scan_for_target()
	if(target)
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			if(!trackable(H))
				target = null
	if(!target)
		active = FALSE

/obj/item/weapon/pinpointer/process()
	if(!active)
		STOP_PROCESSING(SSfastprocess, src)
		return
	scan_for_target()
	update_pointer_overlay()
