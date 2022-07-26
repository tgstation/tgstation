/datum/dimension_theme
	var/list/replace_floors = list()
	var/list/replace_walls = list()
	var/list/replace_windows = list()
	var/list/replace_full_windows = list()
	var/list/replace_objs = list()

/datum/dimension_theme/proc/get_random_theme()
	var/subtype = pick(subtypesof(/datum/dimension_theme))
	return new subtype()

/datum/dimension_theme/proc/apply_theme(turf/affected_turf)
	if (!replace_turf(affected_turf))
		return
	for (var/obj/object in affected_turf)
		replace_object(object)

/datum/dimension_theme/proc/can_convert(turf/affected_turf)
	if (isspaceturf(affected_turf))
		return FALSE
	if (isopenturf(affected_turf))
		if (isindestructiblefloor(affected_turf))
			return FALSE
		return replace_floors.len > 0
	if (isclosedturf(affected_turf))
		if (isindestructiblewall(affected_turf))
			return FALSE
		return replace_walls.len > 0
	return FALSE

/datum/dimension_theme/proc/replace_turf(turf/affected_turf)
	if (isopenturf(affected_turf) && !isindestructiblefloor(affected_turf))
		if (replace_floors.len == 0 || (affected_turf in replace_floors))
			return FALSE
		affected_turf.ChangeTurf(pick_weight(replace_floors), flags = CHANGETURF_INHERIT_AIR)
		return TRUE

	if (isclosedturf(affected_turf) && !isindestructiblewall(affected_turf))
		if (replace_walls.len == 0 || (affected_turf in replace_walls))
			return FALSE
		affected_turf.ChangeTurf(pick_weight(replace_walls))
		return TRUE

/datum/dimension_theme/proc/replace_object(obj/object)
	var/replace_path = get_replacement_object_typepath(object)
	if (!replace_path)
		return
	var/obj/new_object = new replace_path(object.loc)
	new_object.setDir(object.dir)
	qdel(object)

/datum/dimension_theme/proc/get_replacement_object_typepath(obj/object)
	if (istype(object, /obj/structure/window))
		return get_window_typepath(object)

	for (var/type in replace_objs)
		if (istype(object, type))
			return pick_weight(replace_objs[type])
	return

/datum/dimension_theme/proc/get_window_typepath(obj/structure/window/window)
	if (window.fulltile)
		return pick_weight(replace_full_windows)
	return pick_weight(replace_windows)

/////////////////////

/datum/dimension_theme/natural
	replace_floors = list(/turf/open/floor/grass = 1)
	replace_walls = list(/turf/closed/wall/mineral/wood/nonmetal = 1)
	replace_objs = list(\
		/obj/structure/chair = list(/obj/structure/chair/wood = 3, /obj/structure/chair/wood/wings = 1), \
		/obj/machinery/door/airlock = list(/obj/machinery/door/airlock/wood = 1), \
		/obj/structure/table = list(/obj/structure/table/wood = 5, /obj/structure/table/wood/fancy = 1))

/datum/dimension_theme/bamboo
	replace_floors = list(/turf/open/floor/bamboo = 1)
	replace_walls = list(/turf/closed/wall/mineral/bamboo = 1)
	replace_full_windows = list(/obj/structure/window/paperframe = 1)
	replace_objs = list(\
		/obj/structure/chair = list(/obj/structure/chair/stool/bamboo = 1), \
		/obj/machinery/door/airlock = list(/obj/machinery/door/airlock/wood = 1), \
		/obj/structure/table = list(/obj/structure/table/wood = 1))

/datum/dimension_theme/decadent
	replace_floors = list(/turf/open/floor/mineral/gold = 1)
	replace_walls = list(/turf/closed/wall/mineral/gold = 1)
	replace_objs = list(\
		/obj/structure/chair = list(/obj/structure/chair/comfy = 1), \
		/obj/machinery/door/airlock = list(/obj/machinery/door/airlock/gold = 1), \
		/obj/structure/table = list(\
			/obj/structure/table/wood/fancy/royalblue = 1, \
			/obj/structure/table/wood/fancy/red = 1, \
			/obj/structure/table/wood/fancy/purple = 1, \
			/obj/structure/table/wood/fancy = 1))

/datum/dimension_theme/plasma
	replace_floors = list(/turf/open/floor/mineral/plasma = 1)
	replace_walls = list(/turf/closed/wall/mineral/plasma = 1)
	replace_windows = list(/obj/structure/window/plasma = 1)
	replace_full_windows = list(/obj/structure/window/plasma/fulltile = 1)
	replace_objs = list(\
		/obj/machinery/door/airlock = list(/obj/machinery/door/airlock/plasma = 1), \
		/obj/structure/table = list(/obj/structure/table/glass/plasmaglass = 1))

/datum/dimension_theme/clown
	replace_floors = list(/turf/open/floor/mineral/bananium = 1)
	replace_walls = list(/turf/closed/wall/mineral/bananium = 1)
	replace_objs = list(\
		/obj/structure/chair = list(/obj/structure/chair/musical = 1), \
		/obj/machinery/door/airlock = list(/obj/machinery/door/airlock/bananium = 1), \
		/obj/structure/table = list(/obj/structure/table/wood/poker = 1))

/datum/dimension_theme/radioactive
	replace_floors = list(/turf/open/floor/mineral/uranium = 1)
	replace_walls = list(/turf/closed/wall/mineral/uranium = 1)
	replace_objs = list(\
		/obj/machinery/door/airlock = list(/obj/machinery/door/airlock/uranium = 1), \
		/obj/structure/table = list(/obj/structure/table/glass/plasmaglass = 1))

/datum/dimension_theme/icebox
	replace_floors = list(/turf/open/misc/snow/actually_safe = 10, /turf/open/misc/ice/coldroom = 1)
	replace_walls = list(/turf/closed/mineral/random/snow = 1)
	replace_objs = list(\
		/obj/structure/chair = list(/obj/structure/chair/wood = 1), \
		/obj/machinery/door/airlock = list(/obj/machinery/door/airlock/wood = 1), \
		/obj/structure/table = list(/obj/structure/table/wood = 1))

/datum/dimension_theme/lavaland
	replace_floors = list(/turf/open/floor/fakebasalt = 5, /turf/open/floor/fakepit = 1)
	replace_walls = list(/turf/closed/mineral = 1)
	replace_objs = list(\
		/obj/machinery/door/airlock = list(/obj/machinery/door/airlock/external/glass/ruin = 1))
