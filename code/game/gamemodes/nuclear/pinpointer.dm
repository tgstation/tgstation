/obj/item/weapon/pinpointer
	name = "pinpointer"
	desc = "A handheld tracking device that locks onto certain signals."
	icon = 'icons/obj/device.dmi'
	icon_state = "pinoff"
	flags = CONDUCT
	slot_flags = SLOT_BELT
	w_class = 2
	item_state = "electronic"
	throw_speed = 3
	throw_range = 7
	materials = list(MAT_METAL = 500, MAT_GLASS = 250)
	var/active = FALSE
	var/atom/movable/target = null //The thing we're searching for
	var/nuke_warning = FALSE // If we've set off a miniature alarm about an armed nuke
	var/mode = "nuclear" //What are we looking for?

/obj/item/weapon/pinpointer/New()
	..()
	pinpointer_list += src

/obj/item/weapon/pinpointer/Destroy()
	active = 0
	pinpointer_list -= src
	return ..()

/obj/item/weapon/pinpointer/attack_self(mob/living/user)
	active = !active
	user.visible_message("<span class='notice'>[user] [active ? "" : "de"]activates their pinpointer.</span>", "<span class='notice'>You [active ? "" : "de"]activate your pinpointer.</span>")
	playsound(user, 'sound/items/Screwdriver2.ogg', 50, 1)
	icon_state = "pin[active ? "onnull" : "off"]"
	if(active)
		START_PROCESSING(SSfastprocess, src)
	else
		target = null //Restarting the pinpointer forces a target reset
		STOP_PROCESSING(SSfastprocess, src)

/obj/item/weapon/pinpointer/examine(mob/user)
	..()
	switch(mode)
		if("nuclear")
			user << "Its tracking indicator reads \"nuclear_disk\"."
		if("malf_ai")
			user << "Its tracking indicator reads \"01000001 01001001\"."
		if("infiltrator")
			user << "Its tracking indicator reads \"vasvygengbefuvc\"."
		if("operative")
			user << "Its tracking indicator reads \"[target ? "Operative [target]" : "friends"]\"."
		else
			user << "Its tracking indicator is blank."
	for(var/obj/machinery/nuclearbomb/bomb in machines)
		if(bomb.timing)
			user << "Extreme danger.  Arming signal detected.   Time remaining: [bomb.timeleft]"

/obj/item/weapon/pinpointer/process()
	if(!active)
		STOP_PROCESSING(SSfastprocess, src)
		return
	scan_for_target()
	point_to_target()
	my_god_jc_a_bomb()

/obj/item/weapon/pinpointer/proc/scan_for_target() //Looks for whatever it's tracking
	if(target)
		if(isliving(target))
			var/mob/living/L = target
			if(L.stat == DEAD)
				target = null
		return
	switch(mode)
		if("nuclear") //We track the nuke disk, for protection or more nefarious purposes
			var/obj/item/weapon/disk/nuclear/N = locate()
			target = N
		if("malf_ai") //We track the AI, who wants to blow us all to smithereens
			for(var/mob/living/silicon/ai/A in ai_list)
				if(A.nuking)
					target = A
			for(var/obj/machinery/power/apc/A in apcs_list)
				if(A.malfhack && A.occupier)
					target = A
		if("infiltrator") //We track the Syndicate infiltrator, so we can find our way back
			target = SSshuttle.getShuttle("syndicate")
		if("operative")
			var/list/possible_targets = list()
			for(var/datum/mind/M in ticker.mode.syndicates)
				if(M.current && M.current.stat != DEAD && M.current.client)
					possible_targets |= M.current
			if(possible_targets.len)
				target = pick(possible_targets)

/obj/item/weapon/pinpointer/proc/point_to_target() //If we found what we're looking for, show the distance and direction
	if(!active)
		return
	var/turf/here = get_turf(src)
	var/turf/there
	if(target)
		there = get_turf(target)
	if(!target || here.z != there.z)
		icon_state = "pinon[nuke_warning ? "alert" : ""]null"
		return
	setDir(get_dir(here, there))
	if(here == there)
		icon_state = "pinon[nuke_warning ? "alert" : ""]direct"
	else
		switch(get_dist(here, there))
			if(1 to 8)
				icon_state = "pinon[nuke_warning ? "alert" : "close"]"
			if(9 to 16)
				icon_state = "pinon[nuke_warning ? "alert" : "medium"]"
			if(16 to INFINITY)
				icon_state = "pinon[nuke_warning ? "alert" : "far"]"

/obj/item/weapon/pinpointer/proc/my_god_jc_a_bomb() //If we should get the hell back to the ship
	for(var/obj/machinery/nuclearbomb/bomb in machines)
		if(bomb.timing)
			icon_state = "pinonalert"
			if(!nuke_warning)
				nuke_warning = TRUE
				playsound(src, 'sound/items/Nuke_toy_lowpower.ogg', 50, 0)
				if(isliving(loc))
					var/mob/living/L = loc
					L << "<span class='userdanger'>Your [name] vibrates and lets out a tinny alarm. Uh oh.</span>"

/obj/item/weapon/pinpointer/proc/switch_mode_to(new_mode)
	if(isliving(loc))
		var/mob/living/L = loc
		L << "<span class='userdanger'>Your [name] beeps as it reconfigures its tracking algorithms.</span>"
		playsound(L, 'sound/machines/triple_beep.ogg', 50, 1)
	mode = new_mode
	target = null //Switch modes so we can find the new target

/obj/item/weapon/pinpointer/syndicate //Syndicate pinpointers automatically point towards the infiltrator once the nuke is active.
	name = "syndicate pinpointer"
	desc = "A handheld tracking device that locks onto certain signals. It's configured to switch tracking modes once it detects the activation signal of a nuclear device."

/obj/item/weapon/pinpointer/syndicate/cyborg //Cyborg pinpointers just look for a random operative.
	name = "cyborg syndicate pinpointer"
	desc = "An integrated tracking device, jury-rigged to search for living Syndicate operatives."
	mode = "operative"
	flags = NODROP
