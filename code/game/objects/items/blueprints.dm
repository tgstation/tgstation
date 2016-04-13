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


/obj/item/areaeditor/attack_self(mob/user)
	add_fingerprint(user)
	var/text = "<BODY><HTML><head><title>[src]</title></head> \
				<h2>[station_name()] [src.name]</h2> \
				<small>[fluffnotice]</small><hr>"
	switch(get_area_type())
		if(AREA_SPACE)
			text += "<p>According to the [src.name], you are now in an unclaimed territory.</p> \
			<p><a href='?src=\ref[src];create_area=1'>Mark this place as new area.</a></p>"
		if(AREA_SPECIAL)
			text += "<p>This place is not noted on the [src.name].</p>"
	return text


/obj/item/areaeditor/Topic(href, href_list)
	if(..())
		return
	if(!usr.canUseTopic(src))
		usr << browse(null, "window=blueprints")
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


/obj/item/areaeditor/permit/attack_self(mob/user)
	. = ..()
	var/area/A = get_area()
	if(get_area_type() == AREA_STATION)
		. += "<p>According to \the [src], you are now in <b>\"[html_encode(A.name)]\"</b>.</p>"
	var/datum/browser/popup = new(user, "blueprints", "[src]", 700, 500)
	popup.set_content(.)
	popup.open()
	onclose(usr, "blueprints")


/obj/item/areaeditor/permit/create_area()
	var/success = ..()
	if(success)
		qdel(src)


//Station blueprints!!!
/obj/item/areaeditor/blueprints
	name = "station blueprints"
	desc = "Blueprints of the station. There is a \"Classified\" stamp and several coffee stains on it."
	icon = 'icons/obj/items.dmi'
	icon_state = "blueprints"
	fluffnotice = "Property of Nanotrasen. For heads of staff only. Store in high-secure storage."
	var/list/image/showing = list()
	var/client/viewing


/obj/item/areaeditor/blueprints/Destroy()
	clear_viewer()

	return ..()


/obj/item/areaeditor/blueprints/attack_self(mob/user)
	. = ..()
	var/area/A = get_area()
	if(get_area_type() == AREA_STATION)
		. += "<p>According to \the [src], you are now in <b>\"[html_encode(A.name)]\"</b>.</p>"
		. += "<p>You may <a href='?src=\ref[src];edit_area=1'>make an amendment</a> to the drawing.</p>"
	if(!viewing)
		. += "<p><a href='?src=\ref[src];view_blueprints=1'>View structural data</a></p>"
	else
		. += "<p><a href='?src=\ref[src];refresh=1'>Refresh structural data</a></p>"
		. += "<p><a href='?src=\ref[src];hide_blueprints=1'>Hide structural data</a></p>"
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
	if(href_list["view_blueprints"])
		set_viewer(usr, "<span class='notice'>You flip the blueprints over to view the complex information diagram.</span>")
	if(href_list["hide_blueprints"])
		clear_viewer(usr,"<span class='notice'>You flip the blueprints over to view the simple information diagram.</span>")
	if(href_list["refresh"])
		clear_viewer(usr)
		set_viewer(usr)

	attack_self(usr) //this is not the proper way, but neither of the old update procs work! it's too ancient and I'm tired shush.

/obj/item/areaeditor/blueprints/proc/get_images(turf/T, viewsize)
	. = list()
	for(var/tt in RANGE_TURFS(viewsize, T))
		var/turf/TT = tt
		if(TT.blueprint_data)
			. += TT.blueprint_data

/obj/item/areaeditor/blueprints/proc/set_viewer(mob/user, message = "")
	if(user && user.client)
		if(viewing)
			clear_viewer()
		viewing = user.client
		showing = get_images(get_turf(user), viewing.view)
		viewing.images |= showing
		if(message)
			user << message

/obj/item/areaeditor/blueprints/proc/clear_viewer(mob/user, message = "")
	if(viewing)
		viewing.images -= showing
		viewing = null
	showing.Cut()
	if(message)
		user << message

/obj/item/areaeditor/blueprints/dropped(mob/user)
	..()
	clear_viewer()


/obj/item/areaeditor/proc/get_area()
	var/turf/T = get_turf(usr)
	var/area/A = T.loc
	A = A.master
	return A


/obj/item/areaeditor/proc/get_area_type(area/A = get_area())
	if(A.outdoors)
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

	var/list/turfs = res
	var/str = trim(stripped_input(usr,"New area name:", "Blueprint Editing", "", MAX_NAME_LEN))
	if(!str || !length(str)) //cancel
		return
	if(length(str) > 50)
		usr << "<span class='warning'>The given name is too long.  The area remains undefined.</span>"
		return
	var/area/old = get_area(get_turf(src))
	var/old_gravity = old.has_gravity

	var/area/A
	for(var/key in turfs)
		if(key == str)
			A = turfs[key]
		if(turfs[key])
			turfs -= turfs[key]
			turfs -= key
	if(A)
		A.contents += turfs
		A.SetDynamicLighting()
	else
		A = new
		A.setup(str)
		A.contents += turfs
		A.SetDynamicLighting()
	A.has_gravity = old_gravity
	interact()
	return 1


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
	return 1


/obj/item/areaeditor/proc/set_area_machinery_title(area/A,title,oldtitle)
	if(!oldtitle) // or replacetext goes to infinite loop
		return
	for(var/area/RA in A.related)
		for(var/obj/machinery/airalarm/M in RA)
			M.name = replacetext(M.name,oldtitle,title)
		for(var/obj/machinery/power/apc/M in RA)
			M.name = replacetext(M.name,oldtitle,title)
		for(var/obj/machinery/atmospherics/components/unary/vent_scrubber/M in RA)
			M.name = replacetext(M.name,oldtitle,title)
		for(var/obj/machinery/atmospherics/components/unary/vent_pump/M in RA)
			M.name = replacetext(M.name,oldtitle,title)
		for(var/obj/machinery/door/M in RA)
			M.name = replacetext(M.name,oldtitle,title)
	//TODO: much much more. Unnamed airlocks, cameras, etc.


/obj/item/areaeditor/proc/check_tile_is_border(turf/T2,dir)
	if (istype(T2, /turf/open/space))
		return BORDER_SPACE //omg hull breach we all going to die here
	if (get_area_type(T2.loc)!=AREA_SPACE)
		return BORDER_BETWEEN
	if (istype(T2, /turf/closed/wall))
		return BORDER_2NDTILE
	if (!istype(T2, /turf))
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


/obj/item/areaeditor/proc/detect_room(turf/first)
	var/list/turf/found = new
	var/list/turf/pending = list(first)
	var/list/border = list()
	while(pending.len)
		if (found.len+pending.len > 300)
			return ROOM_ERR_TOOLARGE
		var/turf/T = pending[1] //why byond havent list::pop()?
		pending -= T
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
			if (!isturf(NT) || (NT in found) || (NT in pending))
				continue

			switch(check_tile_is_border(NT,dir))
				if(BORDER_NONE)
					pending+=NT
				if(BORDER_BETWEEN)
					var/area/A = NT.loc
					if(!found[A.name])
						found[A.name] = NT.loc
				if(BORDER_2NDTILE)
					border[NT] += dir
				if(BORDER_SPACE)
					return ROOM_ERR_SPACE
		found+=T

	for(var/V in border) //lazy but works
		var/turf/F = V
		for(var/direction in cardinal)
			if(direction == border[F])
				continue //don't want to grab turfs from outside the border
			var/turf/U = get_step(F, direction)
			if((U in border) || (U in found))
				continue
			if(check_tile_is_border(U, direction) == BORDER_2NDTILE)
				found += U
		found |= F
	return found
