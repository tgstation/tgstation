/obj/item/weapon/pinpointer
	name = "pinpointer"
	icon = 'device.dmi'
	icon_state = "pinoff"
	flags = FPRINT | TABLEPASS| CONDUCT | ONBELT
	w_class = 2.0
	item_state = "electronic"
	throw_speed = 4
	throw_range = 20
	m_amt = 500
	var/obj/item/weapon/disk/nuclear/the_disk = null
	var/active = 0


	attack_self()
		if(!active)
			active = 1
			workdisk()
			usr << "\blue You activate the pinpointer"
		else
			active = 0
			icon_state = "pinoff"
			usr << "\blue You deactivate the pinpointer"

	proc/workdisk()
		if(!active) return
		if(!the_disk)
			the_disk = locate()
			if(!the_disk)
				icon_state = "pinonnull"
				return
		src.dir = get_dir(src,the_disk)
		switch(get_dist(src,the_disk))
			if(0)
				icon_state = "pinondirect"
			if(1 to 8)
				icon_state = "pinonclose"
			if(9 to 16)
				icon_state = "pinonmedium"
			if(16 to INFINITY)
				icon_state = "pinonfar"
		spawn(5) .()

	examine()
		..()
		for(var/obj/machinery/nuclearbomb/bomb in world)
			if(bomb.timing)
				usr << "Extreme danger.  Arming signal detected.   Time remaining: [bomb.timeleft]"


/obj/item/weapon/pinpointer/advpinpointer
	name = "Advanced Pinpointer"
	icon = 'device.dmi'
	desc = "A larger version of the normal pinpointer, this unit features a helpful quantum entanglement detection system to locate various objects that do not broadcast a locator signal."
	var/mode = 0  // Mode 0 locates disk, mode 1 locates coordinates.
	var/turf/location = null
	var/obj/target = null

	attack_self()
		if(!active)
			active = 1
			if(mode == 0)
				workdisk()
			if(mode == 1)
				worklocation()
			if(mode == 2)
				workobj()
			usr << "\blue You activate the pinpointer"
		else
			active = 0
			icon_state = "pinoff"
			usr << "\blue You deactivate the pinpointer"


	proc/worklocation()
		if(!active)
			return
		if(!location)
			icon_state = "pinonnull"
			return
		src.dir = get_dir(src,location)
		switch(get_dist(src,location))
			if(0)
				icon_state = "pinondirect"
			if(1 to 8)
				icon_state = "pinonclose"
			if(9 to 16)
				icon_state = "pinonmedium"
			if(16 to INFINITY)
				icon_state = "pinonfar"
		spawn(5) .()


	proc/workobj()
		if(!active)
			return
		if(!target)
			icon_state = "pinonnull"
			return
		src.dir = get_dir(src,target)
		switch(get_dist(src,target))
			if(0)
				icon_state = "pinondirect"
			if(1 to 8)
				icon_state = "pinonclose"
			if(9 to 16)
				icon_state = "pinonmedium"
			if(16 to INFINITY)
				icon_state = "pinonfar"
		spawn(5) .()

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
			if(!locationx || !(usr in view(1,src)))
				return
			var/locationy = input(usr, "Please input the y coordinate to search for.", "Location?" , "") as num
			if(!locationy || !(usr in view(1,src)))
				return

			var/turf/Z = get_turf(src)

			location = locate(locationx,locationy,Z.z)

			usr << "You set the pinpointer to locate [locationx],[locationy]"


			return attack_self()

		if("Disk Recovery")
			mode = 0
			return attack_self()

		if("Other Signature")
			mode = 2
			switch(alert("Search for item signature or DNA fragment?" , "Signature Mode Select" , "" , "Item" , "DNA"))
				if("Item")
/*					var/datum/objective/steal/itemlist
					itemlist = itemlist // To supress a 'variable defined but not used' error.
					var/targetitem = input("Select item to search for.", "Item Mode Select","") as null|anything in itemlist.possible_items
					if(!targetitem)
						return
					target=locate(itemlist.possible_items[targetitem])
					if(!target)
						usr << "Failed to locate [targetitem]!"
						return
					usr << "You set the pinpointer to locate [targetitem]"*/
					usr << "This doesn't work yet."
				if("DNA")
					var/DNAstring = input("Input DNA string to search for." , "Please Enter String." , "")
					if(!DNAstring)
						return
					for(var/mob/living/carbon/M in world)
						if(!M.dna)
							continue
						if(M.dna.unique_enzymes == DNAstring)
							target = M
							break

			return attack_self()







/*/obj/item/weapon/pinpointer/New()
	. = ..()
	processing_objects.Add(src)

/obj/item/weapon/pinpointer/Del()
	processing_objects.Remove(src)
	. = ..()

/obj/item/weapon/pinpointer/attack_self(mob/user as mob)
	user.machine = src
	var/dat
	if (src.temp)
		dat = "[src.temp]<BR><BR><A href='byond://?src=\ref[src];temp=1'>Clear</A>"
	else
		dat = "<B>Nuclear Disk Pinpointer</B><HR>"
		dat += "<A href='byond://?src=\ref[src];refresh=1'>Refresh</A>"

	user << browse(dat, "window=radio")
	onclose(user, "radio")

/obj/item/weapon/pinpointer/process()
	/*
	//TODO: REWRITE
	set background = 1
	var/turf/sr = get_turf(src)

	if (sr)
		for(var/obj/item/weapon/disk/nuclear/W in world)
			var/turf/tr = get_turf(W)
			if (tr && tr.z == sr.z)
				src.dir = get_dir(sr, tr)
				break
	*/
/obj/item/weapon/pinpointer/Topic(href, href_list)
	..()

	if (usr.stat || usr.restrained())
		return

	if ((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))))
		usr.machine = src
		if (href_list["refresh"])
			src.temp = "<B>Nuclear Disk Pinpointer</B><HR>"
			var/turf/sr = get_turf(src)

			if (sr)
				src.temp += "<B>Located Disks:</B><BR>"

				for(var/obj/item/weapon/disk/nuclear/W in world)
					var/turf/tr = get_turf(W)
					if (tr && tr.z == sr.z)
						var/distance = max(abs(tr.x - sr.x), abs(tr.y - sr.y))
						var/strength = "unknown"
						var/directional = dir2text(get_dir(sr, tr));

						if (distance < 5)
							strength = "very strong"
						else if (distance < 10)
							strength = "strong"
						else if (distance < 15)
							strength = "weak"
						else if (distance < 20)
							strength = "very weak"
							directional = "unknown"
						else
							continue

						if (!directional)
							directional = "right on top of it"

						src.temp += "[directional]-[strength]<BR>"

				src.temp += "<B>You are at \[[sr.x],[sr.y],[sr.z]\]</B> in orbital coordinates.<BR><BR><A href='byond://?src=\ref[src];refresh=1'>Refresh</A><BR>"
			else
				src.temp += "<B><FONT color='red'>Processing Error:</FONT></B> Unable to locate orbital position.<BR>"
		else if (href_list["temp"])
			src.temp = null

		if (istype(src.loc, /mob))
			attack_self(src.loc)
		else
			for (var/mob/M in viewers(1, src))
				if (M.client)
					src.attack_self(M)
*/