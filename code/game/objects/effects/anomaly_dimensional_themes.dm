
/**
 * Datum which describes a theme and replaces turfs and objects in specified locations to match that theme
 */
/datum/dimension_theme
	/// Typepath of custom material to use for objects.
	var/material
	/// Weighted list of turfs to replace the floor with.
	var/list/replace_floors = list(/turf/open/floor/material = 1)
	/// Weighted list of turfs to replace walls with.
	var/list/replace_walls = list(/turf/closed/wall/material = 1)
	/// List of weighted lists for object replacement. Key is an original typepath, value is a weighted list of typepaths to replace it with.
	var/list/replace_objs = list(\
		/obj/structure/chair = list(/obj/structure/chair/greyscale = 1), \
		/obj/machinery/door/airlock = list(/obj/machinery/door/airlock/material = 1, /obj/machinery/door/airlock/material/glass = 1), \
		/obj/structure/table = list(/obj/structure/table/greyscale = 1), \
		/obj/structure/toilet = list(/obj/structure/toilet/greyscale = 1),)
	/// Weighted list of directional windows which will replace existing ones
	var/list/replace_windows = list()
	/// Weighted list of full-size windows which will replace existing ones
	/// These need to be separate from replace_objs because we don't want to replace dir windows with full ones and they share typepath
	var/list/replace_full_windows = list()

/datum/dimension_theme/proc/get_random_theme()
	var/subtype = pick(subtypesof(/datum/dimension_theme))
	return new subtype()

/datum/dimension_theme/proc/apply_theme(turf/affected_turf)
	if (!replace_turf(affected_turf))
		return
	for (var/obj/object in affected_turf)
		replace_object(object)
	if (material)
		apply_materials(affected_turf)

/datum/dimension_theme/proc/can_convert(turf/affected_turf)
	if (isspaceturf(affected_turf))
		return FALSE
	if (isfloorturf(affected_turf))
		if (isindestructiblefloor(affected_turf))
			return FALSE
		return replace_floors.len > 0
	if (iswallturf(affected_turf))
		if (isindestructiblewall(affected_turf))
			return FALSE
		return replace_walls.len > 0
	return FALSE

/datum/dimension_theme/proc/replace_turf(turf/affected_turf)
	if (isfloorturf(affected_turf))
		if (isindestructiblefloor(affected_turf))
			return FALSE
		return transform_floor(affected_turf)

	if (!iswallturf(affected_turf))
		return FALSE
	if (isindestructiblewall(affected_turf))
		return FALSE
	return transform_wall(affected_turf)

/datum/dimension_theme/proc/transform_floor(turf/open/floor/affected_floor)
	if (replace_floors.len == 0 || (affected_floor in replace_floors))
		return FALSE
	affected_floor.ChangeTurf(pick_weight(replace_floors), flags = CHANGETURF_INHERIT_AIR)
	return TRUE

/datum/dimension_theme/proc/transform_wall(turf/closed/wall/affected_wall)
	if (replace_walls.len == 0 || (affected_wall in replace_walls))
		return FALSE
	affected_wall.ChangeTurf(pick_weight(replace_walls))
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

#define PERMITTED_MATERIAL_REPLACE_TYPES list(\
	/obj/structure/chair, \
	/obj/machinery/door/airlock, \
	/obj/structure/table, \
	/obj/structure/toilet, \
	/obj/structure/window, \
	/obj/structure/sink,)

/datum/dimension_theme/proc/permit_replace_material(var/obj/object)
	for (var/type in PERMITTED_MATERIAL_REPLACE_TYPES)
		if (istype(object, type))
			return TRUE
	return FALSE

/datum/dimension_theme/proc/apply_materials(turf/affected_turf)
	var/list/custom_materials = list(GET_MATERIAL_REF(material) = 1)

	if (istype(affected_turf, /turf/open/floor/material) || istype(affected_turf, /turf/closed/wall/material))
		affected_turf.set_custom_materials(custom_materials)
	for (var/obj/thing in affected_turf)
		if (!permit_replace_material(thing))
			continue
		thing.set_custom_materials(custom_materials)

#undef PERMITTED_MATERIAL_REPLACE_TYPES

/////////////////////

/datum/dimension_theme/gold
	material = /datum/material/gold

/datum/dimension_theme/plasma
	material = /datum/material/plasma

/datum/dimension_theme/clown
	material = /datum/material/bananium

/datum/dimension_theme/radioactive
	material = /datum/material/uranium

/datum/dimension_theme/meat
	material = /datum/material/meat

/datum/dimension_theme/pizza
	material = /datum/material/pizza

/datum/dimension_theme/natural
	replace_floors = list(/turf/open/floor/grass = 1)
	replace_walls = list(/turf/closed/wall/mineral/wood/nonmetal = 1)
	replace_objs = list(\
		/obj/structure/chair = list(/obj/structure/chair/wood = 3, /obj/structure/chair/wood/wings = 1), \
		/obj/machinery/door/airlock = list(/obj/machinery/door/airlock/wood = 1, /obj/machinery/door/airlock/wood/glass = 1), \
		/obj/structure/table = list(/obj/structure/table/wood = 5, /obj/structure/table/wood/fancy = 1),)

/datum/dimension_theme/bamboo
	replace_floors = list(/turf/open/floor/bamboo = 1)
	replace_walls = list(/turf/closed/wall/mineral/bamboo = 1)
	replace_full_windows = list(/obj/structure/window/paperframe = 1)
	replace_objs = list(\
		/obj/structure/chair = list(/obj/structure/chair/stool/bamboo = 1), \
		/obj/machinery/door/airlock = list(/obj/machinery/door/airlock/wood = 1, /obj/machinery/door/airlock/wood/glass = 1), \
		/obj/structure/table = list(/obj/structure/table/wood = 1),)

/datum/dimension_theme/icebox
	material = /datum/material/snow
	replace_floors = list(/turf/open/floor/fake_snow = 10, /turf/open/floor/fakeice/slippery = 1)
	replace_walls = list(/turf/closed/wall/mineral/snow = 1)

/datum/dimension_theme/lavaland
	replace_floors = list(/turf/open/floor/fakebasalt = 5, /turf/open/floor/fakepit = 1)
	replace_walls = list(/turf/closed/wall/mineral/cult = 1)
	replace_objs = list(\
		/obj/machinery/door/airlock = list(/obj/machinery/door/airlock/external/glass/ruin = 1))

/datum/dimension_theme/space
	material = /datum/material/glass
	replace_floors = list(/turf/open/floor/fakespace = 1)
	replace_walls = list(/turf/closed/wall/rock/porous = 1)
	replace_objs = list(/obj/machinery/door/airlock = list(/obj/machinery/door/airlock/external/glass/ruin = 1))

/datum/dimension_theme/glass
	material = /datum/material/glass
	replace_floors = list(/turf/open/floor/glass = 1)
	replace_walls = list(/turf/open/floor/glass = 1)

/datum/dimension_theme/glass/transform_wall(turf/closed/wall/affected_wall)
	affected_wall.ChangeTurf(/turf/open/floor/glass)
	new /obj/structure/window/fulltile(affected_wall)
	return TRUE

/datum/dimension_theme/fancy
	replace_walls = list(/turf/closed/wall/mineral/wood/nonmetal = 1)

#define FANCY_CARPETS list(\
	/turf/open/floor/eighties, \
	/turf/open/floor/eighties/red, \
	/turf/open/floor/carpet/lone/star, \
	/turf/open/floor/carpet/black, \
	/turf/open/floor/carpet/blue, \
	/turf/open/floor/carpet/cyan, \
	/turf/open/floor/carpet/green, \
	/turf/open/floor/carpet/orange, \
	/turf/open/floor/carpet/purple, \
	/turf/open/floor/carpet/red, \
	/turf/open/floor/carpet/royalblack, \
	/turf/open/floor/carpet/royalblue,)

/datum/dimension_theme/fancy/New()
	replace_floors = list(pick(FANCY_CARPETS) = 1)
	replace_objs = list(\
		/obj/structure/chair = list(/obj/structure/chair/comfy = 1), \
		/obj/machinery/door/airlock = list(/obj/machinery/door/airlock/wood = 1, /obj/machinery/door/airlock/wood/glass = 1), \
		/obj/structure/table/wood = list(pick(subtypesof(/obj/structure/table/wood/fancy)) = 1),)

#undef FANCY_CARPETS

/datum/dimension_theme/disco
	material = /datum/material/glass
	replace_floors = list(/turf/open/floor/light = 1)
	replace_walls = list(/turf/closed/wall = 1)

/datum/dimension_theme/disco/transform_floor(turf/open/floor/affected_floor)
	. = ..()
	if (!.)
		return
	var/turf/open/floor/light/disco_floor = affected_floor
	disco_floor.currentcolor = pick(disco_floor.coloredlights)
	disco_floor.update_appearance()
