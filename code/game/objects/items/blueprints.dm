#define AREA_ERRNONE 0
#define AREA_STATION 1
#define AREA_SPACE 2
#define AREA_SPECIAL 3

#define BORDER_ERROR 0
#define BORDER_NONE 1
#define BORDER_BETWEEN 2
#define BORDER_2NDTILE 3
#define BORDER_SPACE 4

#define ROOM_ERR_LOLWAT 0
#define ROOM_ERR_SPACE 1
#define ROOM_ERR_TOOLARGE 2

/obj/item/areaeditor
	name = "area modification item"
	icon = 'icons/obj/items.dmi'
	icon_state = "blueprints"
	attack_verb = list("attacked", "bapped", "hit")
	var/fluffnotice = "Nobody's gonna read this stuff!"

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
			create_area(usr)
	updateUsrDialog()

//Station blueprints!!!
/obj/item/areaeditor/blueprints
	name = "station blueprints"
	desc = "Blueprints of the station. There is a \"Classified\" stamp and several coffee stains on it."
	icon = 'icons/obj/items.dmi'
	icon_state = "blueprints"
	fluffnotice = "Property of Nanotrasen. For heads of staff only. Store in high-secure storage."
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/list/image/showing = list()
	var/client/viewing
	var/legend = FALSE	//Viewing the wire legend


/obj/item/areaeditor/blueprints/Destroy()
	clear_viewer()
	return ..()


/obj/item/areaeditor/blueprints/attack_self(mob/user)
	. = ..()
	if(!legend)
		var/area/A = get_area()
		if(get_area_type() == AREA_STATION)
			. += "<p>According to \the [src], you are now in <b>\"[html_encode(A.name)]\"</b>.</p>"
			. += "<p>You may <a href='?src=\ref[src];edit_area=1'>make an amendment</a> to the drawing.</p>"
		. += "<p><a href='?src=\ref[src];view_legend=1'>View wire colour legend</a></p>"
		if(!viewing)
			. += "<p><a href='?src=\ref[src];view_blueprints=1'>View structural data</a></p>"
		else
			. += "<p><a href='?src=\ref[src];refresh=1'>Refresh structural data</a></p>"
			. += "<p><a href='?src=\ref[src];hide_blueprints=1'>Hide structural data</a></p>"
	else
		if(legend == TRUE)
			. += "<a href='?src=\ref[src];exit_legend=1'><< Back</a>"
			. += view_wire_devices(user);
		else
			//legend is a wireset
			. += "<a href='?src=\ref[src];view_legend=1'><< Back</a>"
			. += view_wire_set(user, legend)
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
	if(href_list["exit_legend"])
		legend = FALSE;
	if(href_list["view_legend"])
		legend = TRUE;
	if(href_list["view_wireset"])
		legend = href_list["view_wireset"];
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
	legend = FALSE


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

/obj/item/areaeditor/blueprints/proc/view_wire_devices(mob/user)
	var/message = "<br>You examine the wire legend.<br>"
	for(var/wireset in wire_color_directory)
		message += "<br><a href='?src=\ref[src];view_wireset=[wireset]'>[wire_name_directory[wireset]]</a>"
	message += "</p>"
	return message

/obj/item/areaeditor/blueprints/proc/view_wire_set(mob/user, wireset)
	//for some reason you can't use wireset directly as a derefencer so this is the next best :/
	for(var/device in wire_color_directory)
		if("[device]" == wireset)	//I know... don't change it...
			var/message = "<p><b>[wire_name_directory[device]]:</b>"
			for(var/Col in wire_color_directory[device])
				var/wire_name = wire_color_directory[device][Col]
				if(!findtext(wire_name, WIRE_DUD_PREFIX))	//don't show duds
					message += "<p><span style='color: [Col]'>[Col]</span>: [wire_name]</p>"
			message += "</p>"
			return message
	return ""

/proc/create_area(mob/living/creator)
	var/res = detect_room(get_turf(creator))
	if(!istype(res,/list))
		switch(res)
			if(ROOM_ERR_SPACE)
				creator << "<span class='warning'>The new area must be completely airtight.</span>"
				return
			if(ROOM_ERR_TOOLARGE)
				creator << "<span class='warning'>The new area is too large.</span>"
				return
			else
				creator << "<span class='warning'>Error! Please notify administration.</span>"
				return

	var/list/turfs = res
	var/str = trim(stripped_input(creator,"New area name:", "Blueprint Editing", "", MAX_NAME_LEN))
	if(!str || !length(str)) //cancel
		return
	if(length(str) > 50)
		creator << "<span class='warning'>The given name is too long.  The area remains undefined.</span>"
		return
	var/area/old = get_area(get_turf(creator))
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

	for(var/area/RA in old.related)
		if(RA.firedoors)
			for(var/D in RA.firedoors)
				var/obj/machinery/door/firedoor/FD = D
				FD.CalculateAffectingAreas()

	creator << "<span class='notice'>You have created a new area, named [str]. It is now weather proof, and constructing an APC will allow it to be powered.</span>"
	return 1

/obj/item/areaeditor/proc/edit_area()
	var/area/A = get_area()
	var/prevname = "[A.name]"
	var/str = trim(stripped_input(usr,"New area name:", "Area Creation", "", MAX_NAME_LEN))
	if(!str || !length(str) || str==prevname) //cancel
		return
	if(length(str) > 50)
		usr << "<span class='warning'>The given name is too long.  The area's name is unchanged.</span>"
		return
	set_area_machinery_title(A,str,prevname)
	for(var/area/RA in A.related)
		RA.name = str
		if(RA.firedoors)
			for(var/D in RA.firedoors)
				var/obj/machinery/door/firedoor/FD = D
				FD.CalculateAffectingAreas()
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


/turf/proc/check_tile_is_border()
	return BORDER_NONE

/turf/open/space/check_tile_is_border()
	return BORDER_SPACE

/turf/closed/check_tile_is_border()
	return BORDER_2NDTILE

/turf/open/check_tile_is_border()
	for(var/atom/movable/AM in src)
		if(!CANATMOSPASS(AM, src))
			return BORDER_2NDTILE

	return BORDER_NONE

/turf/closed/mineral/check_tile_is_border()
	return BORDER_NONE

/proc/detect_room(turf/first)
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

			switch(NT.check_tile_is_border())
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
			if(U.check_tile_is_border() == BORDER_2NDTILE)
				found += U
		found |= F
	return found



//Blueprint Subtypes

/obj/item/areaeditor/blueprints/cyborg
	name = "station schematics"
	desc = "A digital copy of the station blueprints stored in your memory."
	icon = 'icons/obj/items.dmi'
	icon_state = "blueprints"
	fluffnotice = "Intellectual Property of Nanotrasen. For use in engineering cyborgs only. Wipe from memory upon departure from the station."
