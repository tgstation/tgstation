# define AREA_ERRNONE 0
# define AREA_STATION 1
# define AREA_SPACE   2
# define AREA_SPECIAL 3

# define BORDER_ERROR   0
# define BORDER_NONE    1
# define BORDER_BETWEEN 2
# define BORDER_2NDTILE 3
# define BORDER_SPACE   4

# define ROOM_ERR_LOLWAT    0
# define ROOM_ERR_SPACE    -1
# define ROOM_ERR_TOOLARGE -2

/obj/item/blueprints
	name = "station blueprints"
	desc = "Blueprints of the station. There is a \"Classified\" stamp and several coffee stains on it."
	icon = 'icons/obj/items.dmi'
	icon_state = "blueprints"
	attack_verb = list("attacked", "bapped", "hit")

/obj/item/blueprints/attack_self(mob/M as mob)
	if (!istype(M,/mob/living/carbon/human))
		M << "This stack of blue paper means nothing to you." //monkeys cannot into projecting
		return
	interact()
	return

/obj/item/blueprints/Topic(href, href_list)
	. = ..()
	if(.)
		return

	switch(href_list["action"])
		if ("create_area")
			if (get_area_type()!=AREA_SPACE)
				interact()
				return 1
			create_area()
		if ("edit_area")
			if (get_area_type()!=AREA_STATION)
				interact()
				return 1
			edit_area()

/obj/item/blueprints/interact()
	var/area/A = get_area()
	var/text = {"<HTML><head><title>[src]</title></head><BODY>
<h2>[station_name()] blueprints</h2>
<small>Property of Nanotrasen. For heads of staff only. Store in high-secure storage.</small><hr>
"}
	switch (get_area_type())
		if (AREA_SPACE)
			text += {"
<p>According the blueprints, you are now in <b>outer space</b>.  Hold your breath.</p>
<p><a href='?src=\ref[src];action=create_area'>Mark this place as new area.</a></p>
"}
		if (AREA_STATION)
			text += {"
<p>According the blueprints, you are now in <b>\"[A.name]\"</b>.</p>
<p>You may <a href='?src=\ref[src];action=edit_area'>
move an amendment</a> to the drawing.</p>
"}
		if (AREA_SPECIAL)
			text += {"
<p>This place isn't noted on the blueprint.</p>
"}
		else
			return
	text += "</BODY></HTML>"
	usr << browse(text, "window=blueprints")
	onclose(usr, "blueprints")


/obj/item/blueprints/proc/get_area()
	var/turf/T = get_turf(usr)
	var/area/A = get_area_master(T)
	return A

/obj/item/blueprints/proc/get_area_type(var/area/A = get_area())
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
		// /area/derelict //commented out, all hail derelict-rebuilders!
	)
	for (var/type in SPECIALS)
		if ( istype(A,type) )
			return AREA_SPECIAL
	return AREA_STATION

/obj/item/blueprints/proc/create_area()
	//world << "DEBUG: create_area"
	var/res = detect_room(get_turf(usr))
	if(!istype(res,/list))
		switch(res)
			if(ROOM_ERR_SPACE)
				usr << "<span class='warning'>The new area must be completely airtight!</span>"
				return
			if(ROOM_ERR_TOOLARGE)
				usr << "<span class='warning'>The new area too large!</span>"
				return
			else
				usr << "<span class='warning'>Error! Please notify administration!</span>"
				return
	var/list/turf/turfs = res
	var/str = trim(stripped_input(usr,"New area name:","Blueprint Editing", "", MAX_NAME_LEN))
	if(!str || !length(str)) //cancel
		return
	if(length(str) > 50)
		usr << "<span class='warning'>Name too long.</span>"
		return
	var/area/newarea = new
	var/area/oldarea = get_area(usr)
	newarea.name = str
	newarea.tag = "[newarea.type]/[md5(str)]"
	newarea.power_equip = 0
	newarea.power_light = 0
	newarea.power_environ = 0
	newarea.always_unpowered = 0
	newarea.lighting_use_dynamic = 1
	newarea.contents.Add(turfs)
	for(var/turf/T in turfs)
		T.change_area(oldarea,newarea)
		for(var/atom/allthings in T.contents)
			allthings.change_area(oldarea,newarea)
	newarea.addSorted()

	sleep(5)
	interact()

/obj/item/blueprints/proc/edit_area()
	var/area/areachanged = get_area()
	//world << "DEBUG: edit_area"
	var/prevname = "[areachanged.name]"
	var/str = trim(stripped_input(usr,"New area name:","Blueprint Editing", prevname, MAX_NAME_LEN))
	if(!str || !length(str) || str==prevname) //cancel
		return
	if(length(str) > 50)
		usr << "<span class='warning'>Text too long.</span>"
		return
	areachanged.name = str
	for(var/atom/allthings in areachanged.contents)
		allthings.change_area(prevname,areachanged)
	usr << "<span class='notice'>You set the area '[prevname]' title to '[str]'.</span>"
	interact()

/obj/item/blueprints/proc/check_tile_is_border(var/turf/T2,var/dir)
	if (istype(T2, /turf/space))
		return BORDER_SPACE //omg hull breach we all going to die here
	if (istype(T2, /turf/simulated/shuttle))
		return BORDER_SPACE
	if (get_area_type(T2.loc)!=AREA_SPACE)
		return BORDER_BETWEEN
	if (istype(T2, /turf/simulated/wall))
		return BORDER_2NDTILE
	if (!istype(T2, /turf/simulated))
		return BORDER_BETWEEN

	for (var/obj/structure/window/W in T2)
		if(turn(dir,180) == W.dir)
			return BORDER_BETWEEN
		if (W.is_fulltile())
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

	return BORDER_NONE

/obj/item/blueprints/proc/detect_room(var/turf/first)
	var/list/turf/found = new
	var/list/turf/pending = list(first)
	while(pending.len)
		if (found.len+pending.len > 300)
			return ROOM_ERR_TOOLARGE
		var/turf/T = pending[1] //why byond havent list::pop()?
		pending -= T
		for (var/dir in cardinal)
			var/skip = 0
			for (var/obj/structure/window/W in T)
				if(dir == W.dir || (W.is_fulltile()))
					skip = 1; break
			if (skip) continue
			for(var/obj/machinery/door/window/D in T)
				if(dir == D.dir)
					skip = 1; break
			if (skip) continue

			var/turf/NT = get_step(T,dir)
			if (!isturf(NT) || (NT in found) || (NT in pending))
				continue

			switch(check_tile_is_border(NT,dir))
				if(BORDER_NONE)
					pending+=NT
				if(BORDER_BETWEEN)
					//do nothing, may be later i'll add 'rejected' list as optimization
				if(BORDER_2NDTILE)
					found+=NT //tile included to new area, but we dont seek more
				if(BORDER_SPACE)
					return ROOM_ERR_SPACE
		found+=T
	return found
