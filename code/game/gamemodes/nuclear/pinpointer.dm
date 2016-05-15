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
