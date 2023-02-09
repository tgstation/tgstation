
/**
 * Datum which describes a theme and replaces turfs and objects in specified locations to match that theme
 */
/datum/dimension_theme
	/// An icon to display to represent the theme
	var/icon/icon
	/// Icon state to use to represent the theme
	var/icon_state
	/// Typepath of custom material to use for objects.
	var/datum/material/material
	/// Sound to play when transforming a tile
	var/sound = 'sound/magic/blind.ogg'
	/// Weighted list of turfs to replace the floor with.
	var/list/replace_floors = list(/turf/open/floor/material = 1)
	/// Typepath of turf to replace walls with.
	var/turf/replace_walls = /turf/closed/wall/material
	/// List of weighted lists for object replacement. Key is an original typepath, value is a weighted list of typepaths to replace it with.
	var/list/replace_objs = list(\
		/obj/structure/chair = list(/obj/structure/chair/greyscale = 1), \
		/obj/machinery/door/airlock = list(/obj/machinery/door/airlock/material = 1, /obj/machinery/door/airlock/material/glass = 1), \
		/obj/structure/table = list(/obj/structure/table/greyscale = 1), \
		/obj/structure/toilet = list(/obj/structure/toilet/greyscale = 1),)
	/// Typepath of full-size windows which will replace existing ones
	/// These need to be separate from replace_objs because we don't want to replace dir windows with full ones and they share typepath
	var/obj/structure/window/replace_window
	/// Colour to recolour windows with, replaced by material colour if material was specified.
	var/window_colour = "#ffffff"

/datum/dimension_theme/New()
	if (material)
		var/datum/material/using_mat = GET_MATERIAL_REF(material)
		window_colour = using_mat.greyscale_colors

/**
 * Returns a subtype of dimensional theme.
 */
/datum/dimension_theme/proc/get_random_theme()
	var/subtype = pick(subtypesof(/datum/dimension_theme))
	return new subtype()

/**
 * Applies themed transformation to the provided turf.
 *
 * Arguments
 * * affected_turf - Turf to transform.
 */
/datum/dimension_theme/proc/apply_theme(turf/affected_turf)
	if (!replace_turf(affected_turf))
		return
	playsound(affected_turf, sound, 100, TRUE)
	for (var/obj/object in affected_turf)
		replace_object(object)
	if (material)
		apply_materials(affected_turf)

/**
 * Returns true if you actually can transform the provided turf.
 *
 * Arguments
 * * affected_turf - Turf to transform.
 */
/datum/dimension_theme/proc/can_convert(turf/affected_turf)
	if (isspaceturf(affected_turf))
		return FALSE
	if (isfloorturf(affected_turf))
		if (isindestructiblefloor(affected_turf))
			return FALSE
		if (affected_turf.holodeck_compatible)
			return FALSE
		return replace_floors.len > 0
	if (iswallturf(affected_turf))
		if (isindestructiblewall(affected_turf))
			return FALSE
		return TRUE
	return FALSE

/**
 * Replaces the provided turf with a different one.
 *
 * Arguments
 * * affected_turf - Turf to transform.
 */
/datum/dimension_theme/proc/replace_turf(turf/affected_turf)
	if (isfloorturf(affected_turf))
		if (isindestructiblefloor(affected_turf))
			return FALSE
		if (affected_turf.holodeck_compatible)
			return FALSE
		return transform_floor(affected_turf)

	if (!iswallturf(affected_turf))
		return FALSE
	if (isindestructiblewall(affected_turf))
		return FALSE
	affected_turf.ChangeTurf(replace_walls)
	return TRUE

/**
 * Replaces the provided floor turf with a different one.
 *
 * Arguments
 * * affected_floor - Floor turf to transform.
 */
/datum/dimension_theme/proc/transform_floor(turf/open/floor/affected_floor)
	if (replace_floors.len == 0)
		return FALSE
	affected_floor.ChangeTurf(pick_weight(replace_floors), flags = CHANGETURF_INHERIT_AIR)
	return TRUE

/**
 * Replaces the provided object with a different one.
 *
 * Arguments
 * * object - Object to replace.
 */
/datum/dimension_theme/proc/replace_object(obj/object)
	if (istype(object, /obj/structure/window))
		transform_window(object)
		return

	var/replace_path = get_replacement_object_typepath(object)
	if (!replace_path)
		return
	var/obj/new_object = new replace_path(object.loc)
	new_object.setDir(object.dir)
	qdel(object)

/**
 * Returns the typepath of an object to replace the provided object.
 *
 * Arguments
 * * object - Object to transform.
 */
/datum/dimension_theme/proc/get_replacement_object_typepath(obj/object)
	for (var/type in replace_objs)
		if (istype(object, type))
			return pick_weight(replace_objs[type])
	return

/**
 * Replaces a window with a different window and recolours it.
 * This needs its own function because we only want to replace full tile windows.
 *
 * Arguments
 * * object - Object to transform.
 */
/datum/dimension_theme/proc/transform_window(obj/structure/window/window)
	if (!window.fulltile)
		return
	if (!replace_window)
		window.add_atom_colour(window_colour, FIXED_COLOUR_PRIORITY)
		return

	var/obj/structure/window/new_window = new replace_window(window.loc)
	new_window.add_atom_colour(window_colour, FIXED_COLOUR_PRIORITY)
	qdel(window)

#define PERMITTED_MATERIAL_REPLACE_TYPES list(\
	/obj/structure/chair, \
	/obj/machinery/door/airlock, \
	/obj/structure/table, \
	/obj/structure/toilet, \
	/obj/structure/window, \
	/obj/structure/sink,)

/**
 * Returns true if the provided object can have its material modified.
 *
 * Arguments
 * * object - Object to transform.
 */
/datum/dimension_theme/proc/permit_replace_material(obj/object)
	for (var/type in PERMITTED_MATERIAL_REPLACE_TYPES)
		if (istype(object, type))
			return TRUE
	return FALSE

/**
 * Applies a new custom material to the contents of a provided turf.
 *
 * Arguments
 * * affected_turf - Turf to transform.
 */
/datum/dimension_theme/proc/apply_materials(turf/affected_turf)
	var/list/custom_materials = list(GET_MATERIAL_REF(material) = MINERAL_MATERIAL_AMOUNT)

	if (istype(affected_turf, /turf/open/floor/material) || istype(affected_turf, /turf/closed/wall/material))
		affected_turf.set_custom_materials(custom_materials)
	for (var/obj/thing in affected_turf)
		if (!permit_replace_material(thing))
			continue
		thing.set_custom_materials(custom_materials)

#undef PERMITTED_MATERIAL_REPLACE_TYPES

/////////////////////

/datum/dimension_theme/gold
	icon = 'icons/obj/stack_objects.dmi'
	icon_state = "sheet-gold_2"
	material = /datum/material/gold

/datum/dimension_theme/plasma
	icon = 'icons/obj/clothing/masks.dmi'
	icon_state = "gas_alt"
	material = /datum/material/plasma

/datum/dimension_theme/clown
	icon = 'icons/obj/clothing/masks.dmi'
	icon_state = "clown"
	material = /datum/material/bananium
	sound = 'sound/items/bikehorn.ogg'

/datum/dimension_theme/radioactive
	icon = 'icons/obj/ore.dmi'
	icon_state = "Uranium ore"
	material = /datum/material/uranium
	sound = 'sound/items/welder.ogg'

/datum/dimension_theme/meat
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "meat"
	material = /datum/material/meat
	sound = 'sound/items/eatfood.ogg'

/datum/dimension_theme/pizza
	icon = 'icons/obj/food/pizza.dmi'
	icon_state = "pizzamargherita"
	material = /datum/material/pizza
	sound = 'sound/items/eatfood.ogg'

/datum/dimension_theme/natural
	icon = 'icons/obj/hydroponics/harvest.dmi'
	icon_state = "map_flower"
	window_colour = "#00f7ff"
	replace_floors = list(/turf/open/floor/grass = 1)
	replace_walls = /turf/closed/wall/mineral/wood/nonmetal
	replace_objs = list(\
		/obj/structure/chair = list(/obj/structure/chair/wood = 3, /obj/structure/chair/wood/wings = 1), \
		/obj/machinery/door/airlock = list(/obj/machinery/door/airlock/wood = 1, /obj/machinery/door/airlock/wood/glass = 1), \
		/obj/structure/table = list(/obj/structure/table/wood = 5, /obj/structure/table/wood/fancy = 1),)

/datum/dimension_theme/bamboo
	icon = 'icons/obj/hydroponics/harvest.dmi'
	icon_state = "bamboo"
	replace_floors = list(/turf/open/floor/bamboo = 1)
	replace_walls = /turf/closed/wall/mineral/bamboo
	replace_window = /obj/structure/window/paperframe
	replace_objs = list(\
		/obj/structure/chair = list(/obj/structure/chair/stool/bamboo = 1), \
		/obj/machinery/door/airlock = list(/obj/machinery/door/airlock/wood = 1, /obj/machinery/door/airlock/wood/glass = 1), \
		/obj/structure/table = list(/obj/structure/table/wood = 1),)

/datum/dimension_theme/icebox
	icon = 'icons/obj/clothing/shoes.dmi'
	icon_state = "iceboots"
	window_colour = "#00f7ff"
	material = /datum/material/snow
	replace_floors = list(/turf/open/floor/fake_snow = 10, /turf/open/floor/fakeice/slippery = 1)
	replace_walls = /turf/closed/wall/mineral/snow

/datum/dimension_theme/lavaland
	icon = 'icons/obj/stack_objects.dmi'
	icon_state = "goliath_hide"
	window_colour = "#860000"
	replace_floors = list(/turf/open/floor/fakebasalt = 5, /turf/open/floor/fakepit = 1)
	replace_walls = /turf/closed/wall/mineral/cult
	replace_objs = list(\
		/obj/machinery/door/airlock = list(/obj/machinery/door/airlock/external/glass/ruin = 1))

/datum/dimension_theme/space
	icon = 'icons/effects/effects.dmi'
	icon_state = "blessed"
	window_colour = "#000000"
	material = /datum/material/glass
	replace_floors = list(/turf/open/floor/fakespace = 1)
	replace_walls = /turf/closed/wall/rock/porous
	replace_objs = list(/obj/machinery/door/airlock = list(/obj/machinery/door/airlock/external/glass/ruin = 1))

/datum/dimension_theme/glass
	icon = 'icons/obj/shards.dmi'
	icon_state = "small"
	material = /datum/material/glass
	replace_floors = list(/turf/open/floor/glass = 1)
	sound = SFX_SHATTER

/datum/dimension_theme/fancy
	icon = 'icons/obj/clothing/head/costume.dmi'
	icon_state = "fancycrown"
	replace_walls = /turf/closed/wall/mineral/wood/nonmetal

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
	icon = 'icons/obj/lighting.dmi'
	icon_state = "lbulb"
	material = /datum/material/glass
	replace_floors = list(/turf/open/floor/light = 1)

/datum/dimension_theme/disco/transform_floor(turf/open/floor/affected_floor)
	. = ..()
	if (!.)
		return
	var/turf/open/floor/light/disco_floor = affected_floor
	disco_floor.currentcolor = pick(disco_floor.coloredlights)
	disco_floor.update_appearance()
