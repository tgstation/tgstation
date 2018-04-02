/obj/effect/decal/cleanable/cbquote
	name = "graffiti"
	desc = "Graffiti. Damn kids."
	icon = 'icons/oldschool/objects.dmi'
	icon_state = "cbquote_1/3"

/obj/effect/decal/cleanable/cbquote/Initialize()
	. = ..()
	var/turf/T = loc
	var/number = 1
	for(var/i=2,i>0,i--)
		number++
		T = get_step(T,EAST)
		if(T)
			var/obj/effect/decal/cleanable/C = new(T)
			C.icon = icon
			C.icon_state = "cbquote_[number]/3"
			spawn(15)
				C.pixel_y = pixel_y

/*/obj/effect/decal/cleanable/crayon/randomgraffiti
	name = "graffiti"
	desc = "Graffiti. Damn kids."

/obj/effect/decal/cleanable/crayon/randomgraffiti/New()
	var/area/A = get_area(src)
	if(!A)
		return
	var/list/turflist = list()
	for(var/area/Arelated in A.related)
		for(var/turf/closed/wall/W in Arelated.contents)
			var/is_different = 0
			for(var/turf/T in range(1,W))
				if(T.x != W.x && T.y != W.y)
					continue
				var/area/A2 = get_area(T)
				if(A.type != A2.type)
					is_different = 1
					break
			for(var/obj/effect/decal/cleanable/C in W)
				is_different = 1
				continue
			if(is_different)
				continue
			if(!(W in turflist))
				turflist += W
	if(turflist.len)
		loc = pick(turflist)
	else
		qdel(src)
		return
	icon_state = pick(
		"cyka",
		"prolizard",
		"antilizard",
		"arrow",
		"Omni",
		"Newton",
		"Clandestine",
		"Prima",
		"Zero-G",
		"Osiron",
		"Psyke",
		"Diablo",
		"Blasto",
		"North",
		"Donk",
		"Sleeping Carp",
		"Gene",
		"Cyber",
		"Tunnel",
		"Sirius",
		"Waffle",
		"Max",
		"Gib")
	color = rgb(rand(50,205),rand(50,205),rand(50,205))*/

/*/obj/effect/randomgraffiti
	name = "randomgraffiti"
	var/decaltype = /obj/effect/decal/cleanable/crayon
	var/spawn_percentage = 0.2
	var/list/area_types = list(
		/area/maintenance)
	var/list/singletileicons = list(
		"cyka",
		"prolizard",
		"antilizard",
		"arrow",
		"Omni",
		"Newton",
		"Clandestine",
		"Prima",
		"Zero-G",
		"Osiron",
		"Psyke",
		"Diablo",
		"Blasto",
		"North",
		"Donk",
		"Sleeping Carp",
		"Gene",
		"Cyber",
		"Tunnel",
		"Sirius",
		"Waffle",
		"Max",
		"Gib")
	var/list/tripletileicons = list(
		"yiffhell",
		"secborg",
		"paint")
	var/tripletilechance = 25

/obj/effect/randomgraffiti/New()
	..()
	if(!(SSticker && SSticker.current_state >= GAME_STATE_PLAYING))
		populate_areas()
	qdel(src)

/obj/effect/randomgraffiti/proc/gather_areas()
	var/list/foundareatypes = list()
	var/list/foundareas = list()
	for(var/area/A in world)
		for(var/Apath in area_types)
			if(istype(A,Apath) && !(A.type in foundareatypes))
				foundareatypes += A.type
				foundareas += A
				break
	return foundareas

/obj/effect/randomgraffiti/proc/gather_area_turfs(area/A)
	if(!A)
		return list()
	var/list/turflist = list()
	for(var/area/Arelated in A.related)
		for(var/turf/closed/wall/W in Arelated.contents)
			var/skip = 0
			var/adjacentfloor = 0
			for(var/turf/T in orange(2,W))
				if(T.x != W.x && T.y != W.y)
					continue
				if(get_dist(T,W) <= 1)
					var/area/A2 = get_area(T)
					if((A.type != A2.type))
						skip = 1
						break
					if(!(T.density))
						adjacentfloor = 1
				if(T in turflist)
					skip = 1
					break
			for(var/obj/effect/decal/cleanable/C in W)
				skip = 1
				continue
			if(skip || !adjacentfloor)
				continue
			if(!(W in turflist))
				turflist += W
	return turflist

/obj/effect/randomgraffiti/proc/populate_areas()
	var/list/areas_to_populate = gather_areas()
	if(!areas_to_populate.len)
		return
	var/list/turflist = list()
	for(var/area/A in areas_to_populate)
		turflist.Add(gather_area_turfs(A))
	if(!turflist.len)
		return
	var/amount = round(turflist.len*spawn_percentage,1)
	var/list/addedturfs = list()
	for(var/i=amount,i>0,i--)
		var/turf/T = pick(turflist)
		if(!T)
			break
		if(T in addedturfs)
			continue
		var/list/side_turfs = list()
		var/turf/sideturf = T
		for(var/j=3,j<0,j--)
			if(!sideturf)
				break
			if(sideturf.density)
				side_turfs += sideturf
			else
				break
			sideturf = get_step(sideturf,EAST)
		var/has_floors = 0
		if(side_turfs.len >= 3)
			var/northcheck = 1
			var/southcheck = 1
			for(var/turf/checked in side_turfs)
				var/turf/step = get_step(checked,NORTH)
				if(step.density)
					northcheck = 0
					break
			for(var/turf/checked in side_turfs)
				var/turf/step = get_step(checked,SOUTH)
				if(step.density)
					southcheck = 0
					break
			if(northcheck || southcheck)
				has_floors = 1
		addedturfs += T
		turflist -= T
		var/atom/movable/AM = new decaltype()
		AM.name = "graffiti"
		AM.desc = "Graffiti. Damn kids."
		if(tripletilechance > 0 && side_turfs.len >= 3 && has_floors && prob(tripletilechance))
			AM.icon = 'icons/effects/96x32.dmi'
			AM.icon_state = pick(tripletileicons)
		else
			AM.icon_state = pick(singletileicons)
		AM.color = rgb(rand(50,205),rand(50,205),rand(50,205))
		AM.loc = T*/



