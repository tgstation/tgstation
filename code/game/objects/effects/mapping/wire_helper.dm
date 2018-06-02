/obj/effect/mapping/wire_helper
	name = "Wire Helper"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "wire_helper_1"
	var/allow_diagonals = FALSE
	var/place_node = FALSE
	var/id = "DEFAULT"
	var/wire_color = "red"

/obj/effect/mapping/wire_helper/main
	id = "MAIN"
	icon_state = "wire_helper_1"

/obj/effect/mapping/wire_helper/node
	place_node = TRUE

/obj/effect/mapping/wire_helper/node/main
	id = "MAIN"
	icon_state = "wire_helper_1"

/obj/effect/mapping/wire_helper/Initialize(mapload)
	if(!isturf(loc))
		return INITIALIZE_HINT_QDEL
	for(var/obj/effect/mapping/wire_helper/WH in loc)
		if(WH == src)
			continue
		if(WH.id == id)
			qdel(WH)
			if(mapload)
				stack_trace("Extraneous wire helper with the same ID erased at [COORD(src)].")
	if(mapload)
		activate_mapload()
	else			//Adminspawn
		GLOB.inactive_mapping_helpers += src
		activate_adminspawn()

/obj/effect/mapping/wire_helper/proc/activate_adminspawn(list/propagation)
	LAZYINITLIST(propagation)
	propagation[src] = TRUE
	var/list/dirs = allow_diagonals? GLOB.alldirs : GLOB.cardinals
	var/list/targets = list()
	for(var/i in dirs)
		var/turf/T = get_step(src, i)
		for(var/obj/effect/mapping/wire_helper/WH in T)
			if(WH.id == id)
				targets[WH] = i

	if(targets.len == 1)
		dir_place_node(targets[targets[1]])
	else
		var/last
		for(var/i in targets)
			var/dir = targets[i]
			if(place_node)
				dir_place_node(dir)
			else
				if(!last)
					last = i
					continue
				else
					dir_place_cable(dir, last)
			last = i
	for(var/i in targets)
		var/obj/effect/mapping/wire_helper/WH = i
		if(propagation[WH])
			continue
		WH.activate_adminspawn(propagation)

/obj/effect/mapping/wire_helper/proc/activate_mapload()
	var/list/dirs = allow_diagonals? GLOB.alldirs : GLOB.cardinals
	var/list/targets = list()
	for(var/i in dirs)
		var/turf/T = get_step(src, i)
		for(var/obj/effect/mapping/wire_helper/WH in T)
			if(WH.id == id)
				targets[WH] = i

	if(targets.len == 1)
		dir_place_node(targets[targets[1]])
	else
		var/last
		for(var/i in targets)
			var/dir = targets[i]
			if(place_node)
				dir_place_node(dir)
			else
				if(!last)
					last = i
					continue
				else
					dir_place_cable(dir, last)
			last = i

	qdel(src)

/obj/effect/mapping/wire_helper/proc/dir_place_cable(dir, obj/structure/cable/last)
	var/dir2 = get_dir(src, last)
	new /obj/structure/cable(loc, wire_color, dir, dir2, TRUE)

/obj/effect/mapping/wire_helper/proc/dir_place_node(dir)
	new /obj/structure/cable(loc, wire_color, 0, dir, TRUE)
