/**
 * Datum which describes a theme and replaces turfs and objects in specified locations to match that theme
 */
/datum/dimension_theme
	/// Human readable name of the theme
	var/name = "Unnamed Theme"
	/// An icon to display to represent the theme
	var/icon/icon
	/// Icon state to use to represent the theme
	var/icon_state
	/// Typepath of custom material to use for objects.
	var/datum/material/material
	/// Sound to play when transforming a tile
	var/sound = 'sound/effects/magic/blind.ogg'
	/// Weighted list of turfs to replace the floor with.
	var/list/replace_floors = list(/turf/open/floor/material = 1)
	/// Typepath of turf to replace walls with.
	var/turf/replace_walls = /turf/closed/wall/material
	/// List of weighted lists for object replacement. Key is an original typepath, value is a weighted list of typepaths to replace it with.
	var/list/replace_objs = list(
		/obj/structure/chair = list(/obj/structure/chair/greyscale = 1),
		/obj/machinery/door/airlock = list(/obj/machinery/door/airlock/material = 1, /obj/machinery/door/airlock/material/glass = 1),
		/obj/structure/table = list(/obj/structure/table/greyscale = 1),
		/obj/structure/toilet = list(/obj/structure/toilet/greyscale = 1),
	)
	/// List of random spawns to place in completely open turfs
	var/list/random_spawns
	/// Prob of placing a random spawn in a completely open turf
	var/random_spawn_chance = 0
	/// Typepath of full-size windows which will replace existing ones
	/// These need to be separate from replace_objs because we don't want to replace dir windows with full ones and they share typepath
	var/obj/structure/window/replace_window
	/// Colour to recolour windows with, replaced by material colour if material was specified.
	var/window_colour = "#ffffff"

/datum/dimension_theme/New()
	if (material)
		var/datum/material/using_mat = GET_MATERIAL_REF(material)
		window_colour = using_mat.color

/**
 * Applies themed transformation to the provided turf.
 *
 * Arguments
 * * affected_turf - Turf to transform.
 * * skip_sound - If the sound shouldn't be played.
 * * show_effect - if the temp visual effect should be shown.
 */
/datum/dimension_theme/proc/apply_theme(turf/affected_turf, skip_sound = FALSE, show_effect = FALSE)
	if (!replace_turf(affected_turf))
		return
	if (!skip_sound)
		playsound(affected_turf, sound, 100, TRUE)
	if(show_effect)
		new /obj/effect/temp_visual/transmute_tile_flash(affected_turf)
	for (var/obj/object in affected_turf)
		replace_object(object)
	if (length(random_spawns) && prob(random_spawn_chance) && !affected_turf.is_blocked_turf(exclude_mobs = TRUE))
		var/random_spawn_picked = pick(random_spawns)
		new random_spawn_picked(affected_turf)
	if (material)
		apply_materials(affected_turf)

/**
 * Applies the transformation to a list of turfs, ensuring a sound is only played every few turfs to reduce noice spam
 *
 * Arguments
 * * list/turf/all_turfs - List of turfs to transform.
 */
/datum/dimension_theme/proc/apply_theme_to_list_of_turfs(list/turf/all_turfs)
	var/every_nth_turf = 0
	for (var/turf/turf as anything in all_turfs)
		if(can_convert(turf))
			apply_theme(turf, skip_sound = (every_nth_turf % 7 != 0))
			every_nth_turf++
		CHECK_TICK

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
	PROTECTED_PROC(TRUE)

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
	PROTECTED_PROC(TRUE)

	if (replace_floors.len == 0)
		return FALSE
	affected_floor.replace_floor(pick_weight(replace_floors), flags = CHANGETURF_INHERIT_AIR)
	return TRUE

/**
 * Replaces the provided object with a different one.
 *
 * Arguments
 * * object - Object to replace.
 */
/datum/dimension_theme/proc/replace_object(obj/object)
	PROTECTED_PROC(TRUE)

	if (istype(object, /obj/structure/window))
		transform_window(object)
		return

	var/replace_path = get_replacement_object_typepath(object)
	if (!replace_path)
		return
	var/obj/new_object = new replace_path(object.loc)
	new_object.setDir(object.dir)
	if(istype(object, /obj/machinery/door/airlock))
		new_object.name = object.name
	qdel(object)

/**
 * Returns the typepath of an object to replace the provided object.
 *
 * Arguments
 * * object - Object to transform.
 */
/datum/dimension_theme/proc/get_replacement_object_typepath(obj/object)
	PROTECTED_PROC(TRUE)

	for (var/type in replace_objs)
		if (istype(object, type))
			return pick_weight(replace_objs[type])

/**
 * Replaces a window with a different window and recolours it.
 * This needs its own function because we only want to replace full tile windows.
 *
 * Arguments
 * * object - Object to transform.
 */
/datum/dimension_theme/proc/transform_window(obj/structure/window/window)
	PROTECTED_PROC(TRUE)

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
	PROTECTED_PROC(TRUE)

	return is_type_in_list(object, PERMITTED_MATERIAL_REPLACE_TYPES)


/**
 * Applies a new custom material to the contents of a provided turf.
 *
 * Arguments
 * * affected_turf - Turf to transform.
 */
/datum/dimension_theme/proc/apply_materials(turf/affected_turf)
	PROTECTED_PROC(TRUE)

	var/list/custom_materials = list(GET_MATERIAL_REF(material) = SHEET_MATERIAL_AMOUNT)

	if (istype(affected_turf, /turf/open/floor/material) || istype(affected_turf, /turf/closed/wall/material))
		affected_turf.set_custom_materials(custom_materials)
	for (var/obj/thing in affected_turf)
		if (!permit_replace_material(thing))
			continue
		thing.set_custom_materials(custom_materials)
		thing.update_appearance(updates = UPDATE_ICON)

#undef PERMITTED_MATERIAL_REPLACE_TYPES

/////////////////////

/datum/dimension_theme/gold
	name = "Gold"
	icon = 'icons/obj/stack_objects.dmi'
	icon_state = "sheet-gold_2"
	material = /datum/material/gold

/datum/dimension_theme/plasma
	name = "Plasma"
	icon = 'icons/obj/clothing/masks.dmi'
	icon_state = "gas_alt"
	material = /datum/material/plasma

/datum/dimension_theme/clown
	name = "Clown"
	icon = 'icons/obj/clothing/masks.dmi'
	icon_state = "clown"
	material = /datum/material/bananium
	sound = 'sound/items/bikehorn.ogg'

/datum/dimension_theme/radioactive
	name = "Radioactive"
	icon = 'icons/obj/ore.dmi'
	icon_state = "uranium"
	material = /datum/material/uranium
	sound = 'sound/items/tools/welder.ogg'

/datum/dimension_theme/meat
	name = "Meat"
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "meat"
	material = /datum/material/meat
	sound = 'sound/items/eatfood.ogg'

/datum/dimension_theme/pizza
	name = "Pizza"
	icon = 'icons/obj/food/pizza.dmi'
	icon_state = "pizzamargherita"
	material = /datum/material/pizza
	sound = 'sound/items/eatfood.ogg'

/datum/dimension_theme/natural
	name = "Natural"
	icon = 'icons/obj/service/hydroponics/harvest.dmi'
	icon_state = "map_flower"
	window_colour = "#00f7ff"
	replace_floors = list(/turf/open/floor/grass = 1)
	replace_walls = /turf/closed/wall/mineral/wood/nonmetal
	replace_objs = list(
		/obj/structure/chair = list(/obj/structure/chair/wood = 3, /obj/structure/chair/wood/wings = 1),
		/obj/machinery/door/airlock = list(/obj/machinery/door/airlock/wood = 1, /obj/machinery/door/airlock/wood/glass = 1),
		/obj/structure/table = list(/obj/structure/table/wood = 5, /obj/structure/table/wood/fancy = 1),
	)

/datum/dimension_theme/bamboo
	name = "Bamboo"
	icon = 'icons/obj/service/hydroponics/harvest.dmi'
	icon_state = "bamboo"
	replace_floors = list(/turf/open/floor/bamboo = 1)
	replace_walls = /turf/closed/wall/mineral/bamboo
	replace_window = /obj/structure/window/paperframe
	replace_objs = list(
		/obj/structure/chair = list(/obj/structure/chair/stool/bamboo = 1),
		/obj/machinery/door/airlock = list(/obj/machinery/door/airlock/wood = 1, /obj/machinery/door/airlock/wood/glass = 1),
		/obj/structure/table = list(/obj/structure/table/wood = 1),
	)

/datum/dimension_theme/icebox
	name = "Winter"
	icon = 'icons/obj/clothing/head/costume.dmi'
	icon_state = "snowman_h"
	window_colour = "#00f7ff"
	material = /datum/material/snow
	replace_floors = list(/turf/open/floor/fake_snow = 10, /turf/open/floor/fakeice/slippery = 1)
	replace_walls = /turf/closed/wall/mineral/snow
	random_spawns = list(
		/obj/structure/flora/grass/both/style_random,
		/obj/structure/flora/grass/brown/style_random,
		/obj/structure/flora/grass/green/style_random,
	)
	random_spawn_chance = 8

/datum/dimension_theme/icebox/winter_cabin
	name = "Winter Cabin"
	icon = 'icons/obj/clothing/shoes.dmi'
	icon_state = "iceboots"
	replace_walls = /turf/closed/wall/mineral/wood
	replace_objs = list(
		/obj/structure/chair = list(/obj/structure/chair/wood = 1),
		/obj/machinery/door/airlock = list(/obj/machinery/door/airlock/wood = 1),
		/obj/structure/table = list(/obj/structure/table/wood = 1),
	)

/datum/dimension_theme/lavaland
	name = "Lavaland"
	icon = 'icons/obj/stack_objects.dmi'
	icon_state = "goliath_hide"
	window_colour = "#860000"
	replace_floors = list(/turf/open/floor/fakebasalt = 5, /turf/open/floor/fakepit = 1)
	replace_walls = /turf/closed/wall/mineral/cult
	replace_objs = list(/obj/machinery/door/airlock = list(/obj/machinery/door/airlock/external/glass/ruin = 1))
	random_spawns = list(/mob/living/basic/mining/goldgrub)
	random_spawn_chance = 1

/datum/dimension_theme/space
	name = "Space"
	icon = 'icons/effects/effects.dmi'
	icon_state = "blessed"
	window_colour = COLOR_BLACK
	material = /datum/material/glass
	replace_floors = list(/turf/open/floor/fakespace = 1)
	replace_walls = /turf/closed/wall/rock/porous
	replace_objs = list(/obj/machinery/door/airlock = list(/obj/machinery/door/airlock/external/glass/ruin = 1))

/datum/dimension_theme/glass
	name = "Glass"
	icon = 'icons/obj/debris.dmi'
	icon_state = "small"
	material = /datum/material/glass
	replace_floors = list(/turf/open/floor/glass = 1)
	sound = SFX_SHATTER

/datum/dimension_theme/fancy
	name = "Fancy"
	icon = 'icons/obj/clothing/head/costume.dmi'
	icon_state = "fancycrown"
	replace_floors = null
	replace_walls = /turf/closed/wall/mineral/wood/nonmetal
	replace_objs = list(
		/obj/structure/chair = list(/obj/structure/chair/comfy = 1),
		/obj/machinery/door/airlock = list(/obj/machinery/door/airlock/wood = 1, /obj/machinery/door/airlock/wood/glass = 1),
	)
	/// Cooldown for changing carpets, It's kinda dull to always use the same one, but we also can't make it too random.
	COOLDOWN_DECLARE(carpet_switch_cd)
	/// List of carpets we can pick from, set up in New
	var/list/valid_carpets
	/// List of tables we can pick from, set up in New
	var/list/valid_tables

/datum/dimension_theme/fancy/New()
	. = ..()
	valid_carpets = list(
		/turf/open/floor/carpet/black,
		/turf/open/floor/carpet/blue,
		/turf/open/floor/carpet/cyan,
		/turf/open/floor/carpet/green,
		/turf/open/floor/carpet/lone/star,
		/turf/open/floor/carpet/orange,
		/turf/open/floor/carpet/purple,
		/turf/open/floor/carpet/red,
		/turf/open/floor/carpet/royalblack,
		/turf/open/floor/carpet/royalblue,
		/turf/open/floor/eighties,
		/turf/open/floor/eighties/red,
	)
	valid_tables = subtypesof(/obj/structure/table/wood/fancy)
	randomize_theme()

/datum/dimension_theme/fancy/proc/randomize_theme()
	replace_floors = list(pick(valid_carpets) = 1)
	replace_objs[/obj/structure/table/wood] = list(pick(valid_tables) = 1)

/datum/dimension_theme/fancy/apply_theme(turf/affected_turf, skip_sound = FALSE, show_effect = FALSE)
	if(COOLDOWN_FINISHED(src, carpet_switch_cd))
		randomize_theme()
		COOLDOWN_START(src, carpet_switch_cd, 90 SECONDS)
	return ..()

/datum/dimension_theme/disco
	name = "Disco"
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

/datum/dimension_theme/jungle
	name = "Jungle"
	icon = 'icons/obj/tiles.dmi'
	icon_state = "tile_grass"
	sound = SFX_CRUNCHY_BUSH_WHACK
	replace_floors = list(/turf/open/floor/grass = 1)
	replace_walls = /turf/closed/wall/mineral/wood
	replace_objs = list(
		/obj/structure/chair = list(/obj/structure/chair/wood = 1),
		/obj/machinery/door/airlock = list(/obj/machinery/door/airlock/wood = 1),
		/obj/structure/table = list(/obj/structure/table/wood = 1),
	)
	random_spawns = list(
		/mob/living/carbon/human/species/monkey,
		/obj/structure/flora/bush/ferny/style_random,
		/obj/structure/flora/bush/grassy/style_random,
		/obj/structure/flora/bush/leavy/style_random,
		/obj/structure/flora/tree/palm/style_random,
		/obj/structure/flora/bush/sparsegrass/style_random,
		/obj/structure/flora/bush/sunny/style_random,
	)
	random_spawn_chance = 20

/datum/dimension_theme/ayylmao
	name = "Alien"
	icon = 'icons/obj/antags/abductor.dmi'
	icon_state = "sheet-abductor"
	material = /datum/material/alloy/alien
	replace_walls = /turf/closed/wall/mineral/abductor
	replace_floors = list(/turf/open/floor/mineral/abductor = 1)
	replace_objs = list(
		/obj/structure/chair = list(/obj/structure/chair/greyscale = 9, /obj/structure/bed/abductor = 1),
		/obj/machinery/door/airlock = list(/obj/machinery/door/airlock/material = 1, /obj/machinery/door/airlock/material/glass = 2),
		/obj/structure/table = list(/obj/structure/table/greyscale = 9, /obj/structure/table/abductor = 1),
		/obj/structure/toilet = list(/obj/structure/toilet/greyscale = 1),
	)

/datum/dimension_theme/bronze
	name = "Bronze"
	icon = 'icons/obj/weapons/spear.dmi'
	icon_state = "ratvarian_spear"
	material = /datum/material/bronze
	replace_walls = /turf/closed/wall/mineral/bronze
	replace_floors = list(/turf/open/floor/bronze = 1, /turf/open/floor/bronze/flat = 1, /turf/open/floor/bronze/filled = 1)
	replace_objs = list(
		/obj/structure/girder = list(/obj/structure/girder/bronze = 1),
		/obj/structure/window/fulltile = list(/obj/structure/window/bronze/fulltile = 1),
		/obj/structure/window = list(/obj/structure/window/bronze = 1),
		/obj/structure/statue = list(/obj/structure/statue/bronze/marx = 1), // karl marx was a servant of ratvar
		/obj/structure/table = list(/obj/structure/table/bronze = 1),
		/obj/structure/toilet = list(/obj/structure/toilet/greyscale = 1),
		/obj/structure/chair = list(/obj/structure/chair/bronze = 1),
		/obj/item/reagent_containers/cup/glass/trophy = list(/obj/item/reagent_containers/cup/glass/trophy/bronze_cup = 1),
		/obj/machinery/door/airlock = list(/obj/machinery/door/airlock/bronze = 1),
	)
	sound = 'sound/effects/magic/clockwork/fellowship_armory.ogg'
