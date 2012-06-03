/obj/item/blueprints
	name = "station blueprints"
	desc = "Blueprints of the station. There's stamp \"Classified\" and several coffee stains on it.  Looks like you can edit the station's layout with these."
	icon = 'items.dmi'
	icon_state = "blueprints"

	var/list/image/helper_images = list()

	var/const/AREA_ERRNONE = 0
	var/const/AREA_STATION = 1
	var/const/AREA_SPACE =   2
	var/const/AREA_SPECIAL = 3

	var/const/BORDER_ERROR = 0
	var/const/BORDER_NONE = 1
	var/const/BORDER_BETWEEN =   2
	var/const/BORDER_2NDTILE = 3
	var/const/BORDER_SPACE = 4
	var/const/BORDER_AREA = 5

	var/const/ROOM_ERR_LOLWAT = 0
	var/const/ROOM_ERR_SPACE = -1
	var/const/ROOM_ERR_TOOLARGE = -2

/obj/item/blueprints/attack_self(mob/M as mob)
	if (!istype(M,/mob/living/carbon/human))
		M << "This is stack of useless pieces of heavy paper." //monkeys cannot into projecting
		return
	interact()
	return

/obj/item/blueprints/Topic(href, href_list)
	..()
	if ((usr.restrained() || usr.stat || usr.equipped() != src))
		return
	if (!href_list["action"])
		return
	switch(href_list["action"])
		if ("create_area")
			if (get_area_type()!=AREA_SPACE)
				interact()
				return
			spawn()
				create_area(usr.client)
				if(usr && usr.client)
					for(var/image/to_remove in helper_images)
						if(to_remove in usr.client.images)
							usr.client.images.Remove(to_remove)
							del(to_remove)
		if ("edit_area")
			if (get_area_type()!=AREA_STATION)
				interact()
				return
			spawn()
				edit_area(usr.client)
				if(usr && usr.client)
					for(var/image/to_remove in helper_images)
						if(to_remove in usr.client.images)
							usr.client.images.Remove(to_remove)
							del(to_remove)

/obj/item/blueprints/proc/interact()
	var/area/A = get_area()
	var/text = {"<HTML><head><title>[src]</title></head><BODY>
<h2>[station_name()] blueprints</h2>
<small>Property of Nanotrasen. For heads of staff only. Store in high-secure storage.</small><hr>
"}
	switch (get_area_type())
		if (AREA_SPACE)
			text += {"
<p>According \the [src] you are in <b>open space</b> now.</p>
<p><a href='?src=\ref[src];action=create_area'>Mark this place as a new area.</a></p>
"}
		if (AREA_STATION)
			text += {"
<p>According \the [src] you are in <b>\The [A]</b> now.</p>
<p>You may <a href='?src=\ref[src];action=edit_area'>
move an amendment</a> to the designs.</p>
"}
		if (AREA_SPECIAL)
			text += {"
<p>This place isn't noted on \the [src].</p>
"}
		else
			return
	text += "</BODY></HTML>"
	usr << browse(text, "window=blueprints")
	onclose(usr, "blueprints")

/obj/item/blueprints/proc/get_area_type(var/turf/T = get_turf(src))
	if(!T)
		return AREA_SPECIAL
	var/area/A = get_area(T)
	if (A.name == "Space")
		return AREA_SPACE
	var/list/SPECIALS = list(
		/area/shuttle,
		/area/admin,
		/area/arrival,
		/area/centcom,
		/area/asteroid,
		/area/tdome,
		/area/syndicate_station,
		/area/wizard_station,
		/area/prison
	)
	for (var/type in SPECIALS)
		if ( istype(A,type) )
			return AREA_SPECIAL
	return AREA_STATION

/obj/item/blueprints/proc/create_area(var/client/user)
	//world << "DEBUG: create_area"
	var/list/turf/turfs = detect_room(get_turf(user.mob),user)
	if(!istype(turfs))
		switch(turfs)
			if(ROOM_ERR_SPACE)
				usr << "\red The new area must be completly airtight!"
				return
			if(ROOM_ERR_TOOLARGE)
				usr << "\red The new area is too large!"
				return
			else
				usr << "\red Error! Please notify administration!"
				return
	var/choice = alert("Would you like to add this to an adjacent area, or make a brand new one?","Creating new area.","New Area", "Add to Area", "Cancel")
	switch(choice)

		if("New Area")
			var/list/turf/new_turfs = list()
			for(var/reference in turfs)
				if(turfs[reference] == "Space")
					var/turf/simulated/T = locate(reference) in world
					if(istype(T))
						new_turfs |= T
			if(!new_turfs.len)
				usr << "No aporpriate tiles found."
				return
			if(new_turfs.len > 500)
				usr << "\red Too big of an area!"
				return

			var/str = sanitize(trim(input(usr,"New area title","Blueprints editing") as null|text))
			if(!str || !length(str)) //cancel
				return
			if(length(str) > 50)
				usr << "\red Text too long."
				return
			var/area/A = new
			A.name = str
			A.tag="[A.type]_[md5(str)]" // without this dynamic light system ruin everithing
			A.power_equip = 0
			A.power_light = 0
			A.power_environ = 0
			A.contents |= new_turfs


		if("Add to Area")
			var/list/adjacent_areas = list()
			for(var/reference in turfs)
				adjacent_areas |= turfs[reference]


//POSSIBLE FUTURE CHANGE
			adjacent_areas.Remove("Space") //It's not something you want... or is it?  We can try this out later.


			var/decision = input("Which adjacent area do you want to combine with?","Blueprints Interface") as null|anything in adjacent_areas
			if(decision && decision in adjacent_areas)
				var/area/merge_target
				for(var/reference in turfs)
					if(turfs[reference] == decision)
						var/turf/simulated/T = locate(reference)
						if(istype(T))
							merge_target = get_area(T)
							break
				if(!merge_target)
					usr << "Something's gone badly wrong.  Sorry!"
					return

				var/list/turf/new_turfs = list()
				for(var/reference in turfs)
					if(turfs[reference] == "Space")
						var/turf/simulated/T = locate(reference) in world
						if(istype(T))
							new_turfs |= T
				merge_target.contents |= new_turfs
				spawn(2)
					merge_target.power_change()

			else
				return

		if("Cancel")
			return

	spawn(5)
		interact()
	return


/obj/item/blueprints/proc/edit_area(var/client/user)
	var/area/A = get_area(src)
	//world << "DEBUG: edit_area"
	var/choice = alert("Would you like to rename the area, or merge it with an adjacent one?", "Blueprint Interface", "Rename", "Merge", "Cancel")
	switch(choice)
		if("Rename")
			var/str = sanitize(trim(input(usr,"New area title","Blueprints editing",A.name) as null|text))
			if(!str || !length(str) || str==A.name) //cancel
				return
			if(length(str) > 50)
				usr << "\red Text too long."
				return
			var/old_name = A.name
			for(var/area/RA in A.related)
				RA.name = str
			A.name = str
			A.set_area_machinery_title(old_name)
			usr << "\blue You retitle the area '[A.name]' to '[str]'."


		if("Merge")
			var/list/turf/search_remaining_turfs = A.contents.Copy()
			var/list/turfs = list()
			for(var/turf/simulated/T in search_remaining_turfs)
				if(T.density || locate(/obj/machinery/door) in T || locate(/obj/machinery/door) in T)
					search_remaining_turfs.Remove(T)

			var/limiter = 50

			var/iteration = 0
			while(search_remaining_turfs.len > (A.contents.len)/10 )
				iteration++
				if(iteration > limiter)
					break
				var/turf/simulated/test_turf = pick(search_remaining_turfs)
				if(!istype(test_turf))
					continue
				var/list/turf/temp_turf_list = detect_room(test_turf,user)
				if(!istype(temp_turf_list))
					switch(temp_turf_list)
						if(ROOM_ERR_SPACE)
							usr << "\red \The [A] is not completly airtight!"
							return
						if(ROOM_ERR_TOOLARGE)
							usr << "\red \The [A] is too large to expand!"
							return
						else
							usr << "\red Error! Please notify administration!"
							return
				for(var/reference in temp_turf_list)
					var/turf/simulated/T = locate(reference)
					if(T)
						search_remaining_turfs.Remove(T)
				turfs |= temp_turf_list

			var/list/adjacent_areas = list()
			for(var/reference in turfs)
				adjacent_areas |= turfs[reference]
			adjacent_areas.Remove("[A]")

			var/decision = input("Which adjacent area do you want to merge with?","Blueprints Interface") as null|anything in adjacent_areas
			if(decision && decision in adjacent_areas)
				var/area/merge_target
				for(var/reference in turfs)
					if(turfs[reference] == decision)
						var/turf/simulated/T = locate(reference)
						if(istype(T))
							merge_target = get_area(T)
							break

				if(!merge_target)
					usr << "Something's gone badly wrong.  Sorry!"
					return

				search_remaining_turfs = merge_target.contents.Copy()
				for(var/turf/simulated/T in search_remaining_turfs)
					if(T.density || locate(/obj/machinery/door) in T || locate(/obj/machinery/door) in T)
						search_remaining_turfs.Remove(T)

				var/turf/simulated/T
				iteration = 0
				while(search_remaining_turfs.len > (merge_target.contents.len)/10 )
					T = pick(search_remaining_turfs)
					if(istype(T))
						var/list/turf_references = detect_room(T,user)
						if(!istype(turf_references))
							switch(turf_references)
								if(ROOM_ERR_SPACE)
									usr << "\red \The [merge_target] is not completly airtight!"
									return
								if(ROOM_ERR_TOOLARGE)
									usr << "\red \The [merge_target] is too large to expand!"
									return
								else
									usr << "\red Error! Please notify administration!"
									return
						for(var/reference in turf_references)
							T = locate(reference)
							if(T)
								search_remaining_turfs.Remove(T)
					iteration++
					if(iteration >= limiter)
						break

				var/area_master = alert("If this is approximately the right shape for the combined area, which should the new area be?", "Blueprint Interface", "\The [A]", "\The [merge_target]", "Looks Wrong/Cancel")
				if(area_master == "\The [A]")

					A.absorb(merge_target)

				else if(area_master == "\The [merge_target]")

					merge_target.absorb(A)

				else if(area_master == "Looks Wrong/Cancel")
					return

			else
				return

		if("Cancel")
			return

	spawn(5)
		interact()
	return



/obj/item/blueprints/proc/check_tile_is_border(var/turf/T2,var/dir)
	if (istype(T2, /turf/space))
		return BORDER_SPACE //omg hull breach we all going to die here
	if (istype(T2, /turf/simulated/shuttle))
		return BORDER_SPACE
	if (istype(T2, /turf/simulated/wall))
		return BORDER_2NDTILE
	if (!istype(T2, /turf/simulated))
		return BORDER_BETWEEN

	for (var/obj/structure/window/W in T2)
		if(turn(dir,180) == W.dir)
			return BORDER_BETWEEN
		if (W.dir in list(NORTHEAST,SOUTHEAST,NORTHWEST,SOUTHWEST))
			return BORDER_2NDTILE
	for(var/obj/machinery/door/window/D in T2)
		if(turn(dir,180) == D.dir)
			return BORDER_BETWEEN
	if (locate(/obj/machinery/door) in T2)
		return BORDER_2NDTILE
	if (locate(/obj/structure/falsewall) in T2)
		return BORDER_2NDTILE
	if (locate(/obj/structure/falserwall) in T2)
		return BORDER_2NDTILE


	if(get_area_type(T2) == AREA_SPECIAL)
		return BORDER_BETWEEN

	return BORDER_NONE

/obj/item/blueprints/proc/detect_room(var/turf/first, var/client/user)
	var/list/found = list()
	var/list/pending = list(first)
	var/area/B = get_area(first)
	var/list/areas = list(B.name)
	do
		if (found.len+pending.len > 800)
			return ROOM_ERR_TOOLARGE
		var/turf/T = pending[1]
		pending.Remove(T)
		B = get_area(T)
		for (var/dir in cardinal)
			var/skip = 0
			for (var/obj/structure/window/W in T)
				if(dir == W.dir || (W.dir in list(NORTHEAST,SOUTHEAST,NORTHWEST,SOUTHWEST)))
					skip = 1
					break
			if (skip)
				continue
			for(var/obj/machinery/door/window/D in T)
				if(dir == D.dir)
					skip = 1
					break
			if (skip)
				continue

			var/turf/NT = get_step(T,dir)

			if (!istype(NT))
				continue
			if("\ref[NT]" in found)
				continue
			if("\ref[NT]" in pending)
				continue

			switch(check_tile_is_border(NT,dir))
				if(BORDER_NONE)
					var/area/A = get_area(NT)
					if( ( A.name in areas || A.name == "Space" || B.name == "Space" ) &&\
					!( "\ref[NT]" in pending || "\ref[NT]" in found) )
						//If it is another area, and neither of them are space AND it is not in the list of adjacent areas, then do not add it.
						pending |= NT
						areas |= A.name
				if(BORDER_BETWEEN)
					found["\ref[NT]"] = "[get_area(NT)]"
					if(user && !locate(/image) in NT)
						var/image/Z = image('ULIcons.dmi',NT,"7-0-0",19)
						helper_images |= Z
						user.images += Z

				if(BORDER_2NDTILE)
					found["\ref[NT]"] = "[get_area(NT)]" //tile included to new area, but we dont seek more
					if(user && !locate(/image) in NT)
						var/image/Z = image('ULIcons.dmi',NT,"7-0-0",19)
						helper_images |= Z
						user.images += Z
				if(BORDER_SPACE)
					return ROOM_ERR_SPACE
		found["\ref[T]"] = "[get_area(T)]"
		if(user)
			for(var/image/I in user.images)
				if(I.loc == T)
					user.images.Remove(I)
					del(I)
			var/image/Z = image('ULIcons.dmi',T,"0-0-7",19)
			helper_images |= Z
			user.images += Z
	while(pending.len)
	return found

/*
/proc/check_apc(var/area/A)
	for(var/area/RA in A.related)
		for(var/obj/machinery/power/apc/FINDME in RA)
			return 1
	return 0

/proc/fuckingfreemachinery()
	for(var/obj/machinery/machine in machines)
		if (istype(machine,/obj/machinery/power/solar))
			continue
		var/area/A = machine.loc.loc		// make sure it's in an area
		if (istype(A,/area/tdome))
			continue
		if (istype(A,/area/shuttle))
			continue
		if(!A || !isarea(A))
			world << "DEBUG: @[machine.x],[machine.y],[machine.z] ([A.name]) machine \"[machine.name]\" ([machine.type]) hasnt area!"
			continue
		A = A.master
		if (A.name=="Space")
			world << "DEBUG: @[machine.x],[machine.y],[machine.z] ([A.name]) machine \"[machine.name]\" ([machine.type]) work in space!"
			continue
		if (!check_apc(A))
			world << "DEBUG: @[machine.x],[machine.y],[machine.z] ([A.name]) machine \"[machine.name]\" ([machine.type]) work without APC!"
	world << "\red END ====="

*/