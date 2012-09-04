/obj/item/blueprints
	name = "station blueprints"
	desc = "Blueprints of the station. There's stamp \"Classified\" and several coffee stains on it."
	icon = 'icons/obj/items.dmi'
	icon_state = "blueprints"
	attack_verb = list("attacked", "bapped", "hit")
	var/const/AREA_ERRNONE = 0
	var/const/AREA_STATION = 1
	var/const/AREA_SPACE =   2
	var/const/AREA_SPECIAL = 3

	var/const/BORDER_ERROR = 0
	var/const/BORDER_NONE = 1
	var/const/BORDER_BETWEEN =   2
	var/const/BORDER_2NDTILE = 3
	var/const/BORDER_SPACE = 4

	var/const/ROOM_ERR_LOLWAT = 0
	var/const/ROOM_ERR_SPACE = -1
	var/const/ROOM_ERR_TOOLARGE = -2

/obj/item/blueprints/attack_self(mob/M as mob)
	if (!istype(M,/mob/living/carbon/human))
		M << "This is stack of useless pieces of harsh paper." //monkeys cannot into projecting
		return
	interact()
	return

/obj/item/blueprints/Topic(href, href_list)
	..()
	if ((usr.restrained() || usr.stat || usr.get_active_hand() != src))
		return
	if (!href_list["action"])
		return
	switch(href_list["action"])
		if ("create_area")
			if (get_area_type()!=AREA_SPACE)
				interact()
				return
			create_area()
		if ("edit_area")
			if (get_area_type()!=AREA_STATION)
				interact()
				return
			edit_area()

/obj/item/blueprints/proc/interact()
	var/area/A = get_area()
	var/text = {"<HTML><head><title>[src]</title></head><BODY>
<h2>[station_name()] blueprints</h2>
<small>Property of Nanotrasen. For heads of staff only. Store in high-secure storage.</small><hr>
"}
	switch (get_area_type())
		if (AREA_SPACE)
			text += {"
<p>According this blueprints you are in <b>open space</b> now.</p>
<p><a href='?src=\ref[src];action=create_area'>Mark this place as new area.</a></p>
"}
		if (AREA_STATION)
			text += {"
<p>According this blueprints you are in <b>[A.name]</b> now.</p>
<p>You may <a href='?src=\ref[src];action=edit_area'>
move an amendment</a> to the drawing.</p>
"}
		if (AREA_SPECIAL)
			text += {"
<p>This place doesn't noted on this blueprints.</p>
"}
		else
			return
	text += "</BODY></HTML>"
	usr << browse(text, "window=blueprints")
	onclose(usr, "blueprints")


/obj/item/blueprints/proc/get_area()
	var/turf/T = get_turf_loc(usr)
	var/area/A = T.loc
	A = A.master
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
	var/res = detect_room(get_turf_loc(usr))
	if(!istype(res,/list))
		switch(res)
			if(ROOM_ERR_SPACE)
				usr << "\red New area must be complete airtight!"
				return
			if(ROOM_ERR_TOOLARGE)
				usr << "\red New area too large!"
				return
			else
				usr << "\red Error! Please notify administration!"
				return
	var/list/turf/turfs = res
	var/str = sanitize(trim(input(usr,"New area title","Blueprints editing")))
	if(!str || !length(str)) //cancel
		return
	if(length(str) > 50)
		usr << "\red Text too long."
		return
	var/area/A = new
	A.name = str
	A.tag="[A.type]_[md5(str)]" // without this dynamic light system ruin everithing
	//var/ma
	//ma = A.master ? "[A.master]" : "(null)"
	//world << "DEBUG: create_area: <br>A.name=[A.name]<br>A.tag=[A.tag]<br>A.master=[ma]"
	A.power_equip = 0
	A.power_light = 0
	A.power_environ = 0
	move_turfs_to_area(turfs, A)
	spawn(5)
		//ma = A.master ? "[A.master]" : "(null)"
		//world << "DEBUG: create_area(5): <br>A.name=[A.name]<br>A.tag=[A.tag]<br>A.master=[ma]"
		interact()
	return


/obj/item/blueprints/proc/move_turfs_to_area(var/list/turf/turfs, var/area/A)
	A.contents.Add(turfs)
		//oldarea.contents.Remove(usr.loc) // not needed
		//T.loc = A //error: cannot change constant value


/obj/item/blueprints/proc/edit_area()
	var/area/A = get_area()
	//world << "DEBUG: edit_area"
	var/prevname = A.name
	var/str = sanitize(trim(input(usr,"New area title","Blueprints editing",prevname)))
	if(!str || !length(str) || str==prevname) //cancel
		return
	if(length(str) > 50)
		usr << "\red Text too long."
		return
	set_area_machinery_title(A,str,prevname)
	for(var/area/RA in A.related)
		RA.name = str
	usr << "\blue You set the area '[prevname]' title to '[str]'."
	interact()
	return



/obj/item/blueprints/proc/set_area_machinery_title(var/area/A,var/title,var/oldtitle)
	if (!oldtitle) // or dd_replacetext goes to infinite loop
		return
	for(var/area/RA in A.related)
		for(var/obj/machinery/alarm/M in RA)
			M.name = dd_replacetext(M.name,oldtitle,title)
		for(var/obj/machinery/power/apc/M in RA)
			M.name = dd_replacetext(M.name,oldtitle,title)
		for(var/obj/machinery/atmospherics/unary/vent_scrubber/M in RA)
			M.name = dd_replacetext(M.name,oldtitle,title)
		for(var/obj/machinery/atmospherics/unary/vent_pump/M in RA)
			M.name = dd_replacetext(M.name,oldtitle,title)
		for(var/obj/machinery/door/M in RA)
			M.name = dd_replacetext(M.name,oldtitle,title)
	//TODO: much much more. Unnamed airlocks, cameras, etc.

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
				if(dir == W.dir || (W.dir in list(NORTHEAST,SOUTHEAST,NORTHWEST,SOUTHWEST)))
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