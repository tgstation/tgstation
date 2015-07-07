/obj/item/weapon/pinpointer
	name = "pinpointer"
	icon = 'icons/obj/device.dmi'
	icon_state = "pinoff"
	flags = CONDUCT
	slot_flags = SLOT_BELT
	w_class = 2.0
	item_state = "electronic"
	throw_speed = 3
	throw_range = 7
	materials = list(MAT_METAL=500)
	var/obj/item/weapon/disk/nuclear/the_disk = null
	var/active = 0

/obj/item/weapon/pinpointer/Destroy()
	active = 0
	..()

/obj/item/weapon/pinpointer/attack_self()
	if(!active)
		active = 1
		workdisk()
		usr << "<span class='notice'>You activate the pinpointer.</span>"
	else
		active = 0
		icon_state = "pinoff"
		usr << "<span class='notice'>You deactivate the pinpointer.</span>"

/obj/item/weapon/pinpointer/proc/scandisk()
	if(!the_disk)
		the_disk = locate()

/obj/item/weapon/pinpointer/proc/point_at(atom/target, spawnself = 1)
	if(!active)
		return
	if(!target)
		icon_state = "pinonnull"
		return

	var/turf/T = get_turf(target)
	var/turf/L = get_turf(src)

	if(T.z != L.z)
		icon_state = "pinonnull"
	else
		dir = get_dir(L, T)
		switch(get_dist(L, T))
			if(-1)
				icon_state = "pinondirect"
			if(1 to 8)
				icon_state = "pinonclose"
			if(9 to 16)
				icon_state = "pinonmedium"
			if(16 to INFINITY)
				icon_state = "pinonfar"
	if(spawnself)
		spawn(5)
			.()

/obj/item/weapon/pinpointer/proc/workdisk()
	scandisk()
	point_at(the_disk, 0)
	spawn(5)
		.()

/obj/item/weapon/pinpointer/examine(mob/user)
	..()
	for(var/obj/machinery/nuclearbomb/bomb in world)
		if(bomb.timing)
			user << "Extreme danger.  Arming signal detected.   Time remaining: [bomb.timeleft]"


/obj/item/weapon/pinpointer/advpinpointer
	name = "advanced pinpointer"
	icon = 'icons/obj/device.dmi'
	desc = "A larger version of the normal pinpointer, this unit features a helpful quantum entanglement detection system to locate various objects that do not broadcast a locator signal."
	var/mode = 0  // Mode 0 locates disk, mode 1 locates coordinates.
	var/turf/location = null
	var/obj/target = null

/obj/item/weapon/pinpointer/advpinpointer/attack_self()
	if(!active)
		active = 1
		if(mode == 0)
			workdisk()
		if(mode == 1)
			point_at(location)
		if(mode == 2)
			point_at(target)
		usr << "<span class='notice'>You activate the pinpointer.</span>"
	else
		active = 0
		icon_state = "pinoff"
		usr << "<span class='notice'>You deactivate the pinpointer.</span>"


/obj/item/weapon/pinpointer/advpinpointer/verb/toggle_mode()
	set category = "Object"
	set name = "Toggle Pinpointer Mode"
	set src in view(1)

	if(usr.stat || usr.restrained() || !usr.canmove)
		return

	active = 0
	icon_state = "pinoff"
	target=null
	location = null

	switch(alert("Please select the mode you want to put the pinpointer in.", "Pinpointer Mode Select", "Location", "Disk Recovery", "Other Signature"))
		if("Location")
			mode = 1

			var/locationx = input(usr, "Please input the x coordinate to search for.", "Location?" , "") as num
			if(!locationx || !(usr in view(1,src)))
				return
			var/locationy = input(usr, "Please input the y coordinate to search for.", "Location?" , "") as num
			if(!locationy || !(usr in view(1,src)))
				return

			var/turf/Z = get_turf(src)

			location = locate(locationx,locationy,Z.z)

			usr << "<span class='notice'>You set the pinpointer to locate [locationx],[locationy]</span>"


			return attack_self()

		if("Disk Recovery")
			mode = 0
			return attack_self()

		if("Other Signature")
			mode = 2
			switch(alert("Search for item signature or DNA fragment?" , "Signature Mode Select" , "" , "Item" , "DNA"))
				if("Item")
					var/targetitem = input("Select item to search for.", "Item Mode Select","") as null|anything in possible_items
					if(!targetitem)
						return
					target=locate(possible_items[targetitem])
					if(!target)
						usr << "<span class='warning'>Failed to locate [targetitem]!</span>"
						return
					usr << "<span class='notice'>You set the pinpointer to locate [targetitem].</span>"
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
	var/obj/docking_port/mobile/home


/obj/item/weapon/pinpointer/nukeop/attack_self(mob/user as mob)
	if(!active)
		active = 1
		var/mode_text = "Authentication Disk Locator mode"
		if(!mode)
			workdisk()
		else
			mode_text = "Shuttle Locator mode"
			worklocation()
		user << "<span class='notice'>You activate the pinpointer([mode_text]).</span>"
	else
		active = 0
		icon_state = "pinoff"
		user << "<span class='notice'>You deactivate the pinpointer.</span>"


/obj/item/weapon/pinpointer/nukeop/workdisk()
	if(!active) return
	if(mode)		//Check in case the mode changes while operating
		worklocation()
		return
	if(bomb_set)	//If the bomb is set, lead to the shuttle
		mode = 1	//Ensures worklocation() continues to work
		worklocation()
		playsound(loc, 'sound/machines/twobeep.ogg', 50, 1)	//Plays a beep
		visible_message("Shuttle Locator mode actived.")			//Lets the mob holding it know that the mode has changed
		return		//Get outta here
	scandisk()
	if(!the_disk)
		icon_state = "pinonnull"
		return
	dir = get_dir(src, the_disk)
	switch(get_dist(src, the_disk))
		if(0)
			icon_state = "pinondirect"
		if(1 to 8)
			icon_state = "pinonclose"
		if(9 to 16)
			icon_state = "pinonmedium"
		if(16 to INFINITY)
			icon_state = "pinonfar"

	spawn(5) .()


/obj/item/weapon/pinpointer/nukeop/proc/worklocation()
	if(!active)
		return
	if(!mode)
		workdisk()
		return
	if(!bomb_set)
		mode = 0
		workdisk()
		playsound(loc, 'sound/machines/twobeep.ogg', 50, 1)
		visible_message("<span class='notice'>Authentication Disk Locator mode actived.</span>")
		return
	if(!home)
		home = SSshuttle.getShuttle("syndicate")
		if(!home)
			icon_state = "pinonnull"
			return
	if(loc.z != home.z)	//If you are on a different z-level from the shuttle
		icon_state = "pinonnull"
	else
		dir = get_dir(src, home)
		switch(get_dist(src, home))
			if(0)
				icon_state = "pinondirect"
			if(1 to 8)
				icon_state = "pinonclose"
			if(9 to 16)
				icon_state = "pinonmedium"
			if(16 to INFINITY)
				icon_state = "pinonfar"

	spawn(5)
		.()

/obj/item/weapon/pinpointer/operative
	name = "operative pinpointer"
	icon = 'icons/obj/device.dmi'
	desc = "A pinpointer that leads to the first Syndicate operative detected."
	var/mob/living/carbon/nearest_op = null

/obj/item/weapon/pinpointer/operative/attack_self()
	if(!active)
		active = 1
		workop()
		usr << "<span class='notice'>You activate the pinpointer.</span>"
	else
		active = 0
		icon_state = "pinoff"
		usr << "<span class='notice'>You deactivate the pinpointer.</span>"

/obj/item/weapon/pinpointer/operative/proc/scan_for_ops()
	if(!nearest_op)
		for(var/mob/living/carbon/M in mob_list)
			if(M.mind in ticker.mode.syndicates)
				nearest_op = M

/obj/item/weapon/pinpointer/operative/proc/workop()
	scan_for_ops()
	point_at(nearest_op, 0)
	spawn(5)
		.()

/obj/item/weapon/pinpointer/operative/examine(mob/user)
	..()
	if(nearest_op != null)
		user << "Nearest operative: <b>[nearest_op]</b>."
	if(nearest_op == null && active)
		user << "No operatives detected within scanning range."
