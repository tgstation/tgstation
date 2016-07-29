<<<<<<< HEAD
//Pinpointers are used to track atoms from a distance as long as they're on the same z-level. The captain and nuke ops have ones that track the nuclear authentication disk.
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
	var/atom/movable/constant_target = null //The thing we're always focused on, if we're in the right mode
	var/target_x = 0 //The target coordinates if we're tracking those
	var/target_y = 0
	var/nuke_warning = FALSE // If we've set off a miniature alarm about an armed nuke
	var/mode = TRACK_NUKE_DISK //What are we looking for?

/obj/item/weapon/pinpointer/New()
	..()
	pinpointer_list += src

/obj/item/weapon/pinpointer/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
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

/obj/item/weapon/pinpointer/attackby(obj/item/I, mob/living/user, params)
	if(mode != TRACK_ATOM)
		return ..()
	user.visible_message("<span class='notice'>[user] tunes [src] to [I].</span>", "<span class='notice'>You fine-tune [src]'s tracking to track [I].</span>")
	playsound(src, 'sound/machines/click.ogg', 50, 1)
	constant_target = I

/obj/item/weapon/pinpointer/examine(mob/user)
	..()
	var/msg = "Its tracking indicator reads "
	switch(mode)
		if(TRACK_NUKE_DISK)
			msg += "\"nuclear_disk\"."
		if(TRACK_MALF_AI)
			msg += "\"01000001 01001001\"."
		if(TRACK_INFILTRATOR)
			msg += "\"vasvygengbefuvc\"."
		if(TRACK_OPERATIVES)
			msg += "\"[target ? "Operative [target]" : "friends"]\"."
		if(TRACK_ATOM)
			msg += "\"[initial(constant_target.name)]\"."
		if(TRACK_COORDINATES)
			msg += "\"([target_x], [target_y])\"."
		else
			msg = "Its tracking indicator is blank."
	user << msg
	for(var/obj/machinery/nuclearbomb/bomb in machines)
		if(bomb.timing)
			user << "Extreme danger. Arming signal detected. Time remaining: [bomb.get_time_left()]"

/obj/item/weapon/pinpointer/process()
	if(!active)
		STOP_PROCESSING(SSfastprocess, src)
		return
	scan_for_target()
	point_to_target()
	my_god_jc_a_bomb()
	addtimer(src, "refresh_target", 50, TRUE)

/obj/item/weapon/pinpointer/proc/scan_for_target() //Looks for whatever it's tracking
	if(target)
		if(isliving(target))
			var/mob/living/L = target
			if(L.stat == DEAD)
				target = null
		return
	switch(mode)
		if(TRACK_NUKE_DISK)
			var/obj/item/weapon/disk/nuclear/N = locate()
			target = N
		if(TRACK_MALF_AI)
			for(var/V in ai_list)
				var/mob/living/silicon/ai/A = V
				if(A.nuking)
					target = A
			for(var/V in apcs_list)
				var/obj/machinery/power/apc/A = V
				if(A.malfhack && A.occupier)
					target = A
		if(TRACK_INFILTRATOR)
			target = SSshuttle.getShuttle("syndicate")
		if(TRACK_OPERATIVES)
			var/list/possible_targets = list()
			var/turf/here = get_turf(src)
			for(var/V in ticker.mode.syndicates)
				var/datum/mind/M = V
				if(M.current && M.current.stat != DEAD)
					possible_targets |= M.current
			var/mob/living/closest_operative = get_closest_atom(/mob/living/carbon/human, possible_targets, here)
			if(closest_operative)
				target = closest_operative
		if(TRACK_ATOM)
			if(constant_target)
				target = constant_target
		if(TRACK_COORDINATES)
			var/turf/T = get_turf(src)
			target = locate(target_x, target_y, T.z)

/obj/item/weapon/pinpointer/proc/point_to_target() //If we found what we're looking for, show the distance and direction
	if(!active)
		return
	if(!target || (mode == TRACK_ATOM && !constant_target))
		icon_state = "pinon[nuke_warning ? "alert" : ""]null"
		return
	var/turf/here = get_turf(src)
	var/turf/there = get_turf(target)
	if(here.z != there.z)
		icon_state = "pinon[nuke_warning ? "alert" : ""]null"
		return
	if(here == there)
		icon_state = "pinon[nuke_warning ? "alert" : ""]direct"
	else
		setDir(get_dir(here, there))
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
			if(!nuke_warning)
				nuke_warning = TRUE
				playsound(src, 'sound/items/Nuke_toy_lowpower.ogg', 50, 0)
				if(isliving(loc))
					var/mob/living/L = loc
					L << "<span class='userdanger'>Your [name] vibrates and lets out a tinny alarm. Uh oh.</span>"

/obj/item/weapon/pinpointer/proc/switch_mode_to(new_mode) //If we shouldn't be tracking what we are
	if(isliving(loc))
		var/mob/living/L = loc
		L << "<span class='userdanger'>Your [name] beeps as it reconfigures its tracking algorithms.</span>"
		playsound(L, 'sound/machines/triple_beep.ogg', 50, 1)
	mode = new_mode
	target = null //Switch modes so we can find the new target

/obj/item/weapon/pinpointer/proc/refresh_target() //Periodically removes the target to allow the pinpointer to update (i.e. malf AI shunts, an operative dies)
	target = null

/obj/item/weapon/pinpointer/syndicate //Syndicate pinpointers automatically point towards the infiltrator once the nuke is active.
	name = "syndicate pinpointer"
	desc = "A handheld tracking device that locks onto certain signals. It's configured to switch tracking modes once it detects the activation signal of a nuclear device."

/obj/item/weapon/pinpointer/syndicate/cyborg //Cyborg pinpointers just look for a random operative.
	name = "cyborg syndicate pinpointer"
	desc = "An integrated tracking device, jury-rigged to search for living Syndicate operatives."
	mode = TRACK_OPERATIVES
	flags = NODROP
=======
/obj/item/weapon/pinpointer
	name = "pinpointer"
	icon = 'icons/obj/device.dmi'
	icon_state = "pinoff"
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BELT
	w_class = W_CLASS_SMALL
	item_state = "electronic"
	throw_speed = 4
	throw_range = 20
	starting_materials = list(MAT_IRON = 500)
	w_type = RECYK_ELECTRONIC
	melt_temperature = MELTPOINT_STEEL
	var/obj/item/weapon/disk/nuclear/the_disk = null
	var/active = 0
	var/watches_nuke = 1

/obj/item/weapon/pinpointer/Destroy()
	..()
	processing_objects -= src

/obj/item/weapon/pinpointer/attack_self()
	if(!active)
		active = 1
		workdisk()
		to_chat(usr,"<span class='notice'>You activate \the [src]</span>")
		playsound(get_turf(src), 'sound/items/healthanalyzer.ogg', 30, 1)
		processing_objects += src
	else
		active = 0
		icon_state = "pinoff"
		to_chat(usr,"<span class='notice'>You deactivate \the [src]</span>")
		processing_objects -= src

/obj/item/weapon/pinpointer/proc/workdisk()
	if(!the_disk)
		the_disk = locate()
		the_disk.watched_by += src
	process()

/obj/item/weapon/pinpointer/process()
	point_at(the_disk)

/obj/item/weapon/pinpointer/proc/point_at(atom/target)
	if(!active)
		return
	if(!target)
		icon_state = "pinonnull"
		return

	var/turf/T = get_turf(target)
	var/turf/L = get_turf(src)
	update_icon(L,T)

/obj/item/weapon/pinpointer/update_icon(turf/location,turf/target)
	if(!target || !location)
		icon_state = "pinonnull"
		return
	if(target.z != location.z)
		icon_state = "pinonnull"
	else
		dir = get_dir(location,target)
		switch(get_dist(location,target))
			if(-1)
				icon_state = "pinondirect"
			if(1 to 8)
				icon_state = "pinonclose"
			if(9 to 16)
				icon_state = "pinonmedium"
			if(16 to INFINITY)
				icon_state = "pinonfar"

/obj/item/weapon/pinpointer/examine(mob/user)
	..()
	if(watches_nuke)
		var/bomb_timeleft
		for(var/obj/machinery/nuclearbomb/bomb in machines)
			if(bomb.timing)
				bomb_timeleft = bomb.timeleft
		if(bomb_timeleft)
			to_chat(user,"<span class='danger'>Extreme danger. Arming signal detected. Time remaining: [bomb_timeleft]</span>")
		else
			to_chat(user,"<span class='info'>No active nuclear devices detected.</span>")

/obj/item/weapon/pinpointer/advpinpointer
	name = "Advanced Pinpointer"
	icon = 'icons/obj/device.dmi'
	desc = "A larger version of the normal pinpointer, this unit features a helpful quantum entanglement detection system to locate various objects that do not broadcast a locator signal."
	var/mode = 0  // Mode 0 locates disk, mode 1 locates coordinates.
	var/turf/location = null
	var/obj/target = null
	watches_nuke = 0

/obj/item/weapon/pinpointer/advpinpointer/attack_self()
	if(!active)
		active = 1
		processing_objects += src
		process()
		to_chat(usr,"<span class='notice'>You activate the pinpointer</span>")
	else
		processing_objects -= src
		active = 0
		icon_state = "pinoff"
		to_chat(usr,"<span class='notice'>You deactivate the pinpointer</span>")

/obj/item/weapon/pinpointer/advpinpointer/process()
	switch(mode)
		if(0)
			workdisk()
		if(1)
			point_at(location)
		if(2)
			point_at(target)

/obj/item/weapon/pinpointer/advpinpointer/verb/toggle_mode()
	set category = "Object"
	set name = "Toggle Pinpointer Mode"
	set src in view(1)

	active = 0
	icon_state = "pinoff"
	target=null
	location = null

	switch(alert("Please select the mode you want to put the pinpointer in.", "Pinpointer Mode Select", "Location", "Disk Recovery", "Other Signature"))
		if("Location")
			mode = 1

			var/locationx = input(usr, "Please input the x coordinate to search for.", "Location?" , "") as num
			if(!locationx || !Adjacent(usr))
				return
			var/locationy = input(usr, "Please input the y coordinate to search for.", "Location?" , "") as num
			if(!locationy || !!Adjacent(usr))
				return

			var/turf/Z = get_turf(src)

			location = locate(locationx,locationy,Z.z)

			to_chat(usr,"You set the pinpointer to locate [locationx],[locationy]")


			return attack_self()

		if("Disk Recovery")
			mode = 0
			return attack_self()

		if("Other Signature")
			mode = 2
			switch(alert("Search for item signature or DNA fragment?" , "Signature Mode Select" , "" , "Item" , "DNA"))
				if("Item")
					var/list/item_names[0]
					var/list/item_paths[0]
					for(var/typepath in potential_theft_objectives)
						var/obj/item/tmp_object=new typepath
						var/n="[tmp_object]"
						item_names+=n
						item_paths[n]=typepath
						qdel(tmp_object)
					var/targetitem = input("Select item to search for.", "Item Mode Select","") as null|anything in potential_theft_objectives
					if(!targetitem)
						return
					target=locate(item_paths[targetitem])
					if(!target)
						to_chat(usr,"Failed to locate [targetitem]!")
						return
					to_chat(usr,"You set the pinpointer to locate [targetitem]")
				if("DNA")
					var/DNAstring = input("Input DNA string to search for." , "Please Enter String." , "")
					if(!DNAstring)
						return
					for(var/mob/living/carbon/M in mob_list)
						if(!M.dna)
							continue
						if(M.dna.unique_enzymes == DNAstring)
							target = M
							break

			return attack_self()


///////////////////////
//nuke op pinpointers//
///////////////////////


/obj/item/weapon/pinpointer/nukeop
	var/mode = 0	//Mode 0 locates disk, mode 1 locates the shuttle
	var/obj/machinery/computer/shuttle_control/syndicate/home = null


/obj/item/weapon/pinpointer/nukeop/attack_self(mob/user as mob)
	if(!active)
		active = 1
		if(!mode)
			to_chat(user,"<span class='notice'>Authentication Disk Locator active.</span>")
		else
			to_chat(user,"<span class='notice'>Shuttle Locator active.</span>")
		process()
		processing_objects += src
	else
		active = 0
		icon_state = "pinoff"
		to_chat(user,"<span class='notice'>You deactivate the pinpointer.</span>")
		processing_objects -= src


/obj/item/weapon/pinpointer/nukeop/process()
	if(mode)		//Check in case the mode changes while operating
		worklocation()
	else
		workdisk()

/obj/item/weapon/pinpointer/nukeop/workdisk()
	if(bomb_set)	//If the bomb is set, lead to the shuttle
		mode = 1	//Ensures worklocation() continues to work
		worklocation()
		playsound(loc, 'sound/machines/twobeep.ogg', 50, 1)	//Plays a beep
		visible_message("Shuttle Locator active.")			//Lets the mob holding it know that the mode has changed
		return		//Get outta here
	if(!the_disk)
		the_disk = locate()
		the_disk.watched_by += src
		if(!the_disk)
			icon_state = "pinonnull"
			return
	point_at(the_disk)


/obj/item/weapon/pinpointer/nukeop/proc/worklocation()
	if(!bomb_set)
		mode = 0
		workdisk()
		playsound(loc, 'sound/machines/twobeep.ogg', 50, 1)
		visible_message("<span class='notice'>Authentication Disk Locator active.</span>")
		return
	if(!home)
		home = locate()
		if(!home)
			icon_state = "pinonnull"
			return
	point_at(home)

/obj/item/weapon/pinpointer/pdapinpointer
	name = "pda pinpointer"
	desc = "A pinpointer that has been illegally modified to track the PDA of a crewmember for malicious reasons."
	var/obj/target = null
	var/used = 0
	watches_nuke = 0

/obj/item/weapon/pinpointer/pdapinpointer/attack_self()
	if(!active)
		active = 1
		process()
		processing_objects += src
		to_chat(usr,"<span class='notice'>You activate the pinpointer</span>")
	else
		active = 0
		processing_objects -= src
		icon_state = "pinoff"
		to_chat(usr,"<span class='notice'>You deactivate the pinpointer</span>")

/obj/item/weapon/pinpointer/pdapinpointer/process()
	point_at(target)

/obj/item/weapon/pinpointer/pdapinpointer/verb/select_pda()
	set category = "Object"
	set name = "Select pinpointer target"
	set src in view(1)

	if(used)
		to_chat(usr,"Target has already been set!")
		return

	var/list/L = list()
	L["Cancel"] = "Cancel"
	var/length = 1
	for (var/obj/item/device/pda/P in world)
		if(P.name != "\improper PDA")
			L[text("([length]) [P.name]")] = P
			length++

	var/t = input("Select pinpointer target. WARNING: Can only set once.") as null|anything in L
	if(t == "Cancel")
		return
	target = L[t]
	if(!target)
		to_chat(usr,"Failed to locate [target]!")
		return
	active = 1
	point_at(target)
	to_chat(usr,"You set the pinpointer to locate [target]")
	used = 1


/obj/item/weapon/pinpointer/pdapinpointer/examine(mob/user)
	..()
	if (target)
		to_chat(user,"<span class='notice'>Tracking [target]</span>")
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
