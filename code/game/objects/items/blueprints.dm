/obj/item/areaeditor
	name = "area modification item"
	icon = 'icons/obj/items.dmi'
	icon_state = "blueprints"
	attack_verb = list("attacked", "bapped", "hit")
	var/fluffnotice = "Nobody's gonna read this stuff!"

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


/obj/item/areaeditor/attack_self(mob/user as mob)
	add_fingerprint(user)
	var/text = "<BODY><HTML><head><title>[src]</title></head> \
				<h2>[station_name()] [src.name]</h2> \
				<small>[fluffnotice]</small><hr>"
	switch(get_area_type())
		if(AREA_SPACE)
			text += "<p>According to the [src.name], you are now in <b>outer space</b>.  Hold your breath.</p> \
			<p><a href='?src=\ref[src];create_area=1'>Mark this place as new area.</a></p>"
		if(AREA_SPECIAL)
			text += "<p>This place is not noted on the [src.name].</p>"
	return text


/obj/item/areaeditor/Topic(href, href_list)
	if(..())
		return
	if(href_list["create_area"])
		if(get_area_type()==AREA_SPACE)
			create_area()
	updateUsrDialog()


//One-use area creation permits.
/obj/item/areaeditor/permit
	name = "construction permit"
	icon_state = "permit"
	desc = "This is a one-use permit that allows the user to offically declare a built room as new addition to the station."
	fluffnotice = "Nanotrasen Engineering requires all on-station construction projects to be approved by a head of staff, as detailed in Nanotrasen Company Regulation 512-C (Mid-Shift Modifications to Company Property). \
						By submitting this form, you accept any fines, fees, or personal injury/death that may occur during construction."
	w_class = 1


/obj/item/areaeditor/permit/attack_self(mob/user as mob)
	. = ..()
	var/area/A = get_area()
	if(get_area_type() == AREA_STATION)
		. += "<p>According to \the [src], you are now in <b>\"[strip_html_properly(A.name)]\"</b>.</p>"
	var/datum/browser/popup = new(user, "blueprints", "[src]", 700, 500)
	popup.set_content(.)
	popup.open()
	onclose(usr, "blueprints")


/obj/item/areaeditor/permit/create_area()
	..()
	qdel(src)


//Station blueprints!!!
/obj/item/areaeditor/blueprints
	name = "station blueprints"
	desc = "Blueprints of the station. There is a \"Classified\" stamp and several coffee stains on it."
	icon = 'icons/obj/items.dmi'
	icon_state = "blueprints"
	fluffnotice = "Property of Nanotrasen. For heads of staff only. Store in high-secure storage."


/obj/item/areaeditor/blueprints/attack_self(mob/user as mob)
	. = ..()
	var/area/A = get_area()
	if(get_area_type() == AREA_STATION)
		. += "<p>According to \the [src], you are now in <b>\"[strip_html_properly(A.name)]\"</b>.</p>"
		. += "<p>You may <a href='?src=\ref[src];edit_area=1'> move an amendment</a> to the drawing.</p>"
	var/datum/browser/popup = new(user, "blueprints", "[src]", 700, 500)
	popup.set_content(.)
	popup.open()
	onclose(user, "blueprints")


/obj/item/areaeditor/blueprints/Topic(href, href_list)
	..()
	if(href_list["edit_area"])
		if(get_area_type()!=AREA_STATION)
			return
		edit_area()
	updateUsrDialog()


/obj/item/areaeditor/proc/get_area()
	var/turf/T = get_turf(usr)
	var/area/A = T.loc
	A = A.master
	return A


/obj/item/areaeditor/proc/get_area_type(var/area/A = get_area())
	if (istype(A,/area/space))
		return AREA_SPACE
	var/list/SPECIALS = list(
		/area/shuttle,
		/area/admin,
		/area/arrival,
		/area/centcom,
		/area/asteroid,
		/area/tdome,
		/area/wizard_station,
		/area/prison
	)
	for (var/type in SPECIALS)
		if ( istype(A,type) )
			return AREA_SPECIAL
	return AREA_STATION


/obj/item/areaeditor/proc/create_area()
	var/res = detect_room(get_turf(usr))
	if(!istype(res,/list))
		switch(res)
			if(ROOM_ERR_SPACE)
				usr << "<span class='warning'>The new area must be completely airtight.</span>"
				return
			if(ROOM_ERR_TOOLARGE)
				usr << "<span class='warning'>The new area is too large.</span>"
				return
			else
				usr << "<span class='warning'>Error! Please notify administration.</span>"
				return
	var/list/turf/turfs = res
	var/str = trim(stripped_input(usr,"New area name:", "Blueprint Editing", "", MAX_NAME_LEN))
	if(!str || !length(str)) //cancel
		return
	if(length(str) > 50)
		usr << "<span class='warning'>The given name is too long.  The area remains undefined.</span>"
		return
	var/area/A = new
	A.name = str
	//var/ma
	//ma = A.master ? "[A.master]" : "(null)"
	//world << "DEBUG: create_area: <br>A.name=[A.name]<br>A.tag=[A.tag]<br>A.master=[ma]"
	A.power_equip = 0
	A.power_light = 0
	A.power_environ = 0
	A.always_unpowered = 0
	A.valid_territory = 0
	move_turfs_to_area(turfs, A)
	A.SetDynamicLighting()

	A.addSorted()

	interact()
	return


/obj/item/areaeditor/proc/move_turfs_to_area(var/list/turf/turfs, var/area/A)
	A.contents.Add(turfs)


/obj/item/areaeditor/proc/edit_area()
	var/area/A = get_area()
	var/prevname = "[A.name]"
	var/str = trim(stripped_input(usr,"New area name:", "Blueprint Editing", "", MAX_NAME_LEN))
	if(!str || !length(str) || str==prevname) //cancel
		return
	if(length(str) > 50)
		usr << "<span class='warning'>The given name is too long.  The area's name is unchanged.</span>"
		return
	set_area_machinery_title(A,str,prevname)
	for(var/area/RA in A.related)
		RA.name = str
	usr << "<span class='notice'>You rename the '[prevname]' to '[str]'.</span>"
	interact()
	return


/obj/item/areaeditor/proc/set_area_machinery_title(var/area/A,var/title,var/oldtitle)
	if (!oldtitle) // or replacetext goes to infinite loop
		return
	for(var/area/RA in A.related)
		for(var/obj/machinery/alarm/M in RA)
			M.name = replacetext(M.name,oldtitle,title)
		for(var/obj/machinery/power/apc/M in RA)
			M.name = replacetext(M.name,oldtitle,title)
		for(var/obj/machinery/atmospherics/unary/vent_scrubber/M in RA)
			M.name = replacetext(M.name,oldtitle,title)
		for(var/obj/machinery/atmospherics/unary/vent_pump/M in RA)
			M.name = replacetext(M.name,oldtitle,title)
		for(var/obj/machinery/door/M in RA)
			M.name = replacetext(M.name,oldtitle,title)
	//TODO: much much more. Unnamed airlocks, cameras, etc.


/obj/item/areaeditor/proc/check_tile_is_border(var/turf/T2,var/dir)
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

	return BORDER_NONE


/obj/item/areaeditor/proc/detect_room(var/turf/first)
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
