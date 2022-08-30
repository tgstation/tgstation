#define MAX_BARRIERS 4
#define MIN_BARRIERS 2

/***
 * Datum describing a 'theme' which transforms a 3x3 area's turfs when applied.
 * It also creates a number of themed barriers in that area.
 */
/datum/armour_dimensional_theme
	var/datum/material/material
	var/turf/replace_floor = /turf/open/floor/material
	var/turf/replace_wall = /turf/closed/wall/material
	var/obj/barricade = /obj/structure/table/greyscale
	var/barricade_anchored = TRUE

/**
 * Applies a random dimensional theme effect centered around a provided point.
 * This will transform floors and walls, as well as creating some themed barriers in that area.
 *
 * Arguments
 * * source - The central turf to apply outwards from.
 * * dangerous - If true this will pick a 'dangerous' theme.
 */
/datum/armour_dimensional_theme/proc/apply_random(turf/source, dangerous = FALSE)
	var/theme_type
	if (dangerous)
		theme_type = pick(subtypesof(/datum/armour_dimensional_theme/dangerous))
	else
		theme_type = pick(subtypesof(/datum/armour_dimensional_theme/safe))
	var/datum/armour_dimensional_theme/theme = new theme_type()
	theme.apply(source)
	qdel(theme)

/**
 * Transforms turfs around a source point into a new themed material.
 * Also place some barriers in unoccupied areas.
 *
 * Arguments
 * * source - The central turf to apply outwards from.
*/
/datum/armour_dimensional_theme/proc/apply(turf/source)
	var/obj/effect/particle_effect/fluid/smoke/poof = new(source)
	poof.lifetime = 2 SECONDS
	var/list/target_area = get_target_area(source)
	for (var/turf/target in target_area)
		convert_turf(target)
	place_barriers(source, target_area)

/**
 * Returns a list of turfs which it is valid to apply changes to.
 *
 * Arguments
 * * source - The central turf to check outwards from.
 */
/datum/armour_dimensional_theme/proc/get_target_area(turf/source)
	var/list/target_area = RANGE_TURFS(1, source)
	for (var/turf/check_turf as anything in target_area)
		if (isspaceturf(check_turf))
			target_area -= check_turf
			continue
		if (isindestructiblefloor(check_turf))
			target_area -= check_turf
			continue
		if (isindestructiblewall(check_turf))
			target_area -= check_turf
			continue
		if (check_turf.holodeck_compatible)
			target_area -= check_turf
			continue

	return target_area

/**
 * Changes a turf into a different turf
 *
 * Arguments
 * * to_convert - Turf to convert.
 */
/datum/armour_dimensional_theme/proc/convert_turf(turf/to_convert)
	if (isfloorturf(to_convert))
		to_convert.ChangeTurf(replace_floor, flags = CHANGETURF_INHERIT_AIR)
	else if (iswallturf(to_convert))
		to_convert.ChangeTurf(replace_wall)

	if (material)
		var/list/custom_materials = list(GET_MATERIAL_REF(material) = MINERAL_MATERIAL_AMOUNT)
		to_convert.set_custom_materials(custom_materials)

/**
 * Places a random amount of themed barriers in unoccupied spaces adjacent to a source tile.
 *
 * Arguments
 * * source - Central tile to place barriers around.
 * * target_area - Tiles which have had their materials converted, needs further culling to remove dense tiles.
 */
/datum/armour_dimensional_theme/proc/place_barriers(turf/source, list/target_area)
	target_area -= source
	for (var/turf/check_turf as anything in target_area)
		if (!check_turf.is_blocked_turf(exclude_mobs = TRUE))
			continue
		target_area -= check_turf

	var/to_place = rand(MIN_BARRIERS, MAX_BARRIERS)
	var/list/custom_materials = list()
	if (material)
		custom_materials = list(GET_MATERIAL_REF(material) = MINERAL_MATERIAL_AMOUNT)

	while (target_area.len > 0 && to_place > 0)
		var/turf/place_turf = pick(target_area)
		place_barrier(place_turf, custom_materials)
		target_area -= place_turf
		to_place--

/**
 * Places a barrier at a specified turf.
 *
 * Arguments
 * * source - Tile to place barrier upon.
 * * materials - Custom material data to apply to the barrier.
 */
/datum/armour_dimensional_theme/proc/place_barrier(turf/source, list/materials)
	var/obj/placed_barricade = new barricade(source)
	if (barricade_anchored)
		placed_barricade.anchored = TRUE
	if (materials.len)
		placed_barricade.set_custom_materials(materials)

/// Themes which will largely be probably useful for the user
/datum/armour_dimensional_theme/safe

/datum/armour_dimensional_theme/safe/natural
	replace_wall = /turf/closed/wall/mineral/wood/nonmetal
	replace_floor = /turf/open/floor/grass
	barricade = /obj/structure/barricade/wooden

/datum/armour_dimensional_theme/safe/snow
	material = /datum/material/snow
	replace_wall = /turf/closed/wall/mineral/snow
	replace_floor = /turf/open/floor/fake_snow
	barricade = /obj/structure/statue/snow/snowman

/datum/armour_dimensional_theme/safe/space
	material = /datum/material/glass
	replace_wall = /turf/closed/wall/rock/porous
	replace_floor = /turf/open/floor/fakespace
	barricade = /obj/machinery/door/airlock/external/glass/ruin

/datum/armour_dimensional_theme/safe/glass
	material = /datum/material/glass
	replace_floor = /turf/open/floor/glass

/datum/armour_dimensional_theme/safe/secure
	replace_wall = /turf/closed/wall/mineral/plastitanium/nodiagonal
	replace_floor = /turf/open/floor/mineral/plastitanium
	barricade = /obj/structure/holosign/barrier

/datum/armour_dimensional_theme/safe/meat
	material = /datum/material/meat

/// Dangerous themes can potentially impede the user as much as people pursuing them
/datum/armour_dimensional_theme/dangerous

/datum/armour_dimensional_theme/dangerous/clown
	material = /datum/material/bananium
	barricade = /obj/item/restraints/legcuffs/beartrap/prearmed
	barricade_anchored = FALSE

/datum/armour_dimensional_theme/dangerous/radioactive
	material = /datum/material/uranium
	barricade = /obj/structure/statue/uranium/nuke

/datum/armour_dimensional_theme/dangerous/plasma
	material = /datum/material/plasma
	barricade = /obj/structure/statue/plasma/xeno

/datum/armour_dimensional_theme/dangerous/ice
	material = /datum/material/snow
	replace_wall = /turf/closed/wall/mineral/snow
	replace_floor = /turf/open/floor/fakeice/slippery
	barricade = /obj/structure/statue/snow/snowlegion

/datum/armour_dimensional_theme/dangerous/lavaland
	replace_floor = /turf/open/floor/fakebasalt
	replace_wall = /turf/closed/wall/mineral/cult

/// Replace the barrier spawning to instead create weak lava.
/datum/armour_dimensional_theme/dangerous/lavaland/place_barrier(turf/source, list/materials)
	source.ChangeTurf(/turf/open/lava/smooth/weak, flags = CHANGETURF_INHERIT_AIR)

#undef MAX_BARRIERS
#undef MIN_BARRIERS
