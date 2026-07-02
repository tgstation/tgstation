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
	/// Weighted lists of turfs to replace the floor with.
	var/list/replace_floors = list(/turf/open/floor/material = 1)
	var/list/replace_com_floors = list()
	var/list/replace_sec_floors = list()
	var/list/replace_sci_floors = list()
	var/list/replace_med_floors = list()
	var/list/replace_eng_floors = list()
	var/list/replace_car_floors = list()
	var/list/replace_ser_floors = list()
	/// Weighted lists of carpets to replace other carpets with
	var/list/replace_carpets = list()
	var/list/replace_com_carpets = list()
	var/list/replace_sec_carpets = list()
	var/list/replace_sci_carpets = list()
	var/list/replace_med_carpets = list()
	var/list/replace_eng_carpets = list()
	var/list/replace_car_carpets = list()
	var/list/replace_ser_carpets = list()
	/// Typepath of turf to replace walls with.
	var/turf/replace_walls = /turf/closed/wall/material
	/// List of weighted lists for object replacement. Key is an original typepath, value is a weighted list of typepaths to replace it with.
	var/list/replace_objs = list(
		/obj/structure/chair = list(/obj/structure/chair/greyscale = 1),
		/obj/machinery/door/airlock = list(/obj/machinery/door/airlock/material = 1, /obj/machinery/door/airlock/material/glass = 1),
		/obj/structure/table = list(/obj/structure/table/greyscale = 1),
		/obj/structure/toilet = list(/obj/structure/toilet/greyscale = 1),
		/obj/structure/platform = list(/obj/structure/platform/material = 1),
	)
	/// List of random spawns to place in completely open turfs
	var/list/random_spawns
	/// Prob of placing a random spawn in a completely open turf
	var/random_spawn_chance = 0
	/// List of threats from the dimension. Dimensional rifts use this to defend themselves
	var/guardian = list()
	/// Typepath of full-size windows which will replace existing ones
	/// These need to be separate from replace_objs because we don't want to replace dir windows with full ones and they share typepath
	var/obj/structure/window/replace_window
	/// Colour to recolour windows with, replaced by material colour if material was specified.
	var/window_colour = "#ffffff"

/datum/dimension_theme/New()
	if (material)
		var/datum/material/using_mat = SSmaterials.get_material(material)
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
		if(istype(affected_turf, /turf/open/floor/carpet))
			return transform_floor(affected_turf)
		else
			return transform_carpet(affected_turf)

	if (!iswallturf(affected_turf))
		return FALSE
	if (isindestructiblewall(affected_turf))
		return FALSE
	affected_turf.ChangeTurf(replace_walls, flags = CHANGETURF_INHERIT_MOUNTS)
	return TRUE


/**
 * Checks what area the provided turf is in, and returns a shortening for it, so we can affect different departaments differently.
 *
 * Arguments
 * * affected_turf - Turf we are checking.
 */
/datum/dimension_theme/proc/area_short(turf/affected_turf)
	var/turf_area = get_area(affected_turf)

	if(istype(turf_area, /area/station/command))
		return "com"
	if(istype(turf_area, /area/station/engineering))
		return "eng"
	if(istype(turf_area, /area/station/security))
		return "sec"
	if(istype(turf_area, /area/station/science))
		return "sci"
	if(istype(turf_area, /area/station/medical))
		return "med"
	if(istype(turf_area, /area/station/cargo))
		return "car"
	if(istype(turf_area, /area/station/service))
		return "ser"
	return "nan"

/**
 * Replaces the provided floor turf with a different one.
 *
 * Arguments
 * * affected_floor - Floor turf to transform.
 */
/datum/dimension_theme/proc/transform_floor(turf/open/floor/affected_floor)
	PROTECTED_PROC(TRUE)
	var/list/floor_list = list()

	switch(area_short(affected_floor))
		if("com")
			floor_list = replace_com_floors
		if("eng")
			floor_list = replace_eng_floors
		if("sec")
			floor_list = replace_sec_floors
		if("sci")
			floor_list = replace_sci_floors
		if("med")
			floor_list = replace_med_floors
		if("car")
			floor_list = replace_car_floors
		if("ser")
			floor_list = replace_ser_floors
		else
			floor_list = replace_floors

	if (floor_list.len == 0)
		floor_list = replace_floors
		if (floor_list.len == 0)
			return FALSE

	affected_floor.replace_floor(pick_weight(replace_floors), flags = CHANGETURF_INHERIT_AIR | CHANGETURF_INHERIT_MOUNTS)
	return TRUE

/**
 * Literally the same as for the floor, but inputs changed to carpets.
 * Also falls back on floors, if carpet is undefined
 */
/datum/dimension_theme/proc/transform_carpet(turf/open/floor/affected_floor)
	PROTECTED_PROC(TRUE)
	var/list/carpet_list = list()
	switch(area_short(affected_floor))
		if("com")
			carpet_list = replace_com_carpets
		if("eng")
			carpet_list = replace_eng_carpets
		if("sec")
			carpet_list = replace_sec_carpets
		if("sci")
			carpet_list = replace_sci_carpets
		if("med")
			carpet_list = replace_med_carpets
		if("car")
			carpet_list = replace_car_carpets
		if("ser")
			carpet_list = replace_ser_carpets
		else
			carpet_list = replace_carpets

	if (carpet_list.len == 0)
		carpet_list = replace_carpets
		if (carpet_list.len == 0)
			return transform_floor(affected_floor)
	affected_floor.replace_floor(pick_weight(carpet_list), flags = CHANGETURF_INHERIT_AIR | CHANGETURF_INHERIT_MOUNTS)
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
		if(istype(new_object, /obj/machinery/door/airlock)) //carry over access-related and adjacent variables. The rest is not as important
			var/obj/machinery/door/airlock/airlock = object
			var/obj/machinery/door/airlock/new_airlock = new_object
			new_airlock.closeOtherId = airlock.closeOtherId
			new_airlock.unres_sides = airlock.unres_sides
			new_airlock.req_access = airlock.req_access?.Copy()
			new_airlock.req_one_access = airlock.req_one_access?.Copy()
			new_airlock.locked = airlock.locked
			new_airlock.emergency = airlock.emergency
			new_airlock.update_appearance()
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
	/obj/structure/sink, \
	/obj/structure/platform, \
)

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

	var/list/custom_materials = list(SSmaterials.get_material(material) = SHEET_MATERIAL_AMOUNT)

	if (istype(affected_turf, /turf/open/floor/material) || istype(affected_turf, /turf/closed/wall/material))
		affected_turf.set_custom_materials(custom_materials)
	for (var/obj/thing in affected_turf)
		if (!permit_replace_material(thing))
			continue
		thing.set_custom_materials(custom_materials)
		thing.update_appearance(updates = UPDATE_ICON)

#undef PERMITTED_MATERIAL_REPLACE_TYPES

/////////////////////

///Dimension where everyone is opulent and gaudy.
/datum/dimension_theme/gold
	name = "Gold"
	icon = 'icons/obj/stack_objects.dmi'
	icon_state = "sheet-gold_2"
	material = /datum/material/gold
	replace_carpets = list(/turf/open/floor/carpet/royalblack = 1)
	replace_com_carpets = list(/turf/open/floor/carpet/royalblue = 1)
	replace_objs = list(
		/obj/structure/chair = list(/obj/structure/chair/greyscale = 1),
		/obj/machinery/door/airlock = list(/obj/machinery/door/airlock/gold = 1, /obj/machinery/door/airlock/gold/glass = 1),
		/obj/structure/table = list(/obj/structure/table/greyscale = 1),
		/obj/structure/toilet = list(/obj/structure/toilet/greyscale = 1),
		/obj/structure/platform = list(/obj/structure/platform/gold = 1),
	)
	guardian = list(/mob/living/basic/trooper/clown = 10)

///Dimension where plasmamen overtook the world.
/datum/dimension_theme/plasma
	name = "Plasma"
	icon = 'icons/obj/clothing/masks.dmi'
	icon_state = "gas_alt"
	material = /datum/material/plasma
	replace_objs = list(
		/obj/item/tank/internals/oxygen = list(/obj/item/tank/internals/plasma = 1),
	)
	guardian = list(/mob/living/basic/skeleton/plasmaminer = 6, /mob/living/basic/skeleton/plasmaminer/jackhammer = 4)

///Dimension where earth and clown planet's roles are reversed.
/datum/dimension_theme/clown
	name = "Clown"
	icon = 'icons/obj/clothing/masks.dmi'
	icon_state = "clown"
	material = /datum/material/bananium
	sound = 'sound/items/bikehorn.ogg'
	guardian = list(/mob/living/basic/trooper/clown = 10)

///Dimension where roaches rule the world and made everything from uranium so no one gets in the way.
/datum/dimension_theme/radioactive
	name = "Radioactive"
	icon = 'icons/obj/ore.dmi'
	icon_state = "uranium"
	material = /datum/material/uranium
	sound = 'sound/items/tools/welder.ogg'
	guardian = list(/mob/living/basic/cockroach/glockroach/mobroach = 1,  /mob/living/basic/cockroach/glockroach/mobroach/goon = 4, /mob/living/basic/cockroach/glockroach = 10, /mob/living/basic/cockroach/hauberoach = 5)

///Dimension where the station was eaten by a giant space whale.
/datum/dimension_theme/meat
	name = "Meat"
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "meat"
	material = /datum/material/meat
	sound = 'sound/items/eatfood.ogg'
	guardian = list(/mob/living/basic/fleshblob = 2, /mob/living/basic/living_limb_flesh = 4, /mob/living/basic/flesh_spider = 4)

///Dimension where every structure has to be consumable.
/datum/dimension_theme/pizza
	name = "Pizza"
	icon = 'icons/obj/food/pizza.dmi'
	icon_state = "pizzamargherita"
	material = /datum/material/pizza
	sound = 'sound/items/eatfood.ogg'
	replace_objs = list(
		/obj/structure/chair = list(/obj/structure/chair/greyscale = 1),
		/obj/machinery/door/airlock = list(/obj/machinery/door/airlock/material = 1, /obj/machinery/door/airlock/material/glass = 1),
		/obj/structure/table = list(/obj/structure/table/greyscale = 1),
		/obj/structure/toilet = list(/obj/structure/toilet/greyscale = 1),
		/obj/structure/platform = list(/obj/structure/platform/pizza = 1),
	)
	guardian = list(/mob/living/basic/killer_tomato = 5, /mob/living/basic/trooper/angry_chef = 5)

///Dimension where humans live in harmony with nature. But then the garden gnome nation attacked.
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
		/obj/structure/platform = list(/obj/structure/platform/wood = 1),
		/obj/structure/railing = list(/obj/structure/railing/wooden_fence = 1),
		/obj/structure/railing/corner/end = list(/obj/structure/railing/corner/end/wooden_fence = 1),
	)
	guardian = list(/mob/living/basic/garden_gnome = 10)

///Dimension where origin countries of major corps are swapped, and Nanostrasen is japanese/chineese.
/datum/dimension_theme/bamboo
	name = "Bamboo"
	icon = 'icons/obj/service/hydroponics/harvest.dmi'
	icon_state = "bamboo"
	replace_floors = list(/turf/open/floor/bamboo/planks = 1)
	replace_com_floors = list(/turf/open/floor/bamboo/tatami/black = 1)
	replace_sec_floors = list(/turf/open/floor/bamboo/tatami/black = 1)
	replace_sci_floors = list(/turf/open/floor/bamboo/tatami/purple = 1)
	replace_med_floors = list(/turf/open/floor/bamboo = 1)
	replace_eng_floors = list(/turf/open/floor/bamboo = 1)
	replace_car_floors = list(/turf/open/floor/bamboo/tatami = 1)
	replace_ser_floors = list(/turf/open/floor/bamboo/tatami = 1)
	replace_walls = /turf/closed/wall/mineral/bamboo
	replace_window = /obj/structure/window/paperframe
	replace_objs = list(
		/obj/structure/chair = list(/obj/structure/chair/stool/bamboo = 1),
		/obj/machinery/door/airlock = list(/obj/machinery/door/airlock/wood = 1, /obj/machinery/door/airlock/wood/glass = 1),
		/obj/structure/table = list(/obj/structure/table/wood = 1),
		/obj/structure/platform = list(/obj/structure/platform/bamboo = 1),
		/obj/item/kirbyplants = list(/obj/item/kirbyplants/organic/plant4 = 1),
	)
	guardian = list(/mob/living/basic/trooper/spiderclan_mook = 10)

///Dimension where planets orbit stations and moons are built
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
	guardian = list(/mob/living/basic/mining/ice_whelp = 2, /mob/living/basic/mining/polarbear = 3, /mob/living/basic/mining/wolf = 5, /mob/living/basic/mining/legion/snow = 5, /mob/living/basic/mining/ice_demon = 5)

///Dimension where the station is just a village on the ice moon
/datum/dimension_theme/icebox/winter_cabin
	name = "Winter Cabin"
	icon = 'icons/obj/clothing/shoes.dmi'
	icon_state = "iceboots"
	replace_walls = /turf/closed/wall/mineral/wood
	replace_objs = list(
		/obj/structure/chair = list(/obj/structure/chair/wood = 1),
		/obj/machinery/door/airlock = list(/obj/machinery/door/airlock/wood = 1),
		/obj/structure/table = list(/obj/structure/table/wood = 1),
		/obj/structure/platform = list(/obj/structure/platform/wood = 1),
	)

///Dimension where stations orbit moons and planets are built
/datum/dimension_theme/lavaland
	name = "Lavaland"
	icon = 'icons/obj/stack_objects.dmi'
	icon_state = "goliath_hide"
	window_colour = "#860000"
	replace_floors = list(/turf/open/floor/fakebasalt = 5, /turf/open/floor/fakepit = 1)
	replace_walls = /turf/closed/wall/mineral/cult
	replace_objs = list(
		/obj/machinery/door/airlock = list(/obj/machinery/door/airlock/external/glass/ruin = 1),
		/obj/structure/platform = list(/obj/structure/platform/cult = 1),
	)
	random_spawns = list(/mob/living/basic/mining/goldgrub)
	random_spawn_chance = 1

	guardian = list(/mob/living/basic/mining/goliath = 2, /mob/living/basic/mining/legion = 6, /mob/living/basic/mining/watcher = 2)

///Dimension where the station is made to be 'disguised' as an asteroid.
/datum/dimension_theme/space
	name = "Space"
	icon = 'icons/effects/effects.dmi'
	icon_state = "blessed"
	window_colour = COLOR_BLACK
	material = /datum/material/glass
	replace_floors = list(/turf/open/floor/fakespace = 1)
	replace_walls = /turf/closed/wall/rock/porous
	replace_objs = list(/obj/machinery/door/airlock = list(/obj/machinery/door/airlock/external/glass/ruin = 1))
	guardian = list(/mob/living/basic/carp = 9, /mob/living/basic/carp/mega = 1)

///Dimension where the station is an observatory
/datum/dimension_theme/glass
	name = "Glass"
	icon = 'icons/obj/debris.dmi'
	icon_state = "small"
	material = /datum/material/glass
	replace_floors = list(/turf/open/floor/glass = 1)
	sound = SFX_SHATTER
	guardian = list(/mob/living/basic/eyeball = 7, /mob/living/basic/mining/watcher/glass = 3)

///Dimension where taxes are 5% less.
/datum/dimension_theme/fancy
	name = "Fancy"
	icon = 'icons/obj/clothing/head/costume.dmi'
	icon_state = "fancycrown"
	replace_floors = null
	replace_walls = /turf/closed/wall/mineral/wood/nonmetal
	replace_objs = list(
		/obj/structure/chair = list(/obj/structure/chair/comfy = 1),
		/obj/machinery/door/airlock = list(/obj/machinery/door/airlock/wood = 1, /obj/machinery/door/airlock/wood/glass = 1),
		/obj/structure/platform = list(/obj/structure/platform/paper = 1),
	)
	/// Cooldown for changing carpets, It's kinda dull to always use the same one, but we also can't make it too random.
	COOLDOWN_DECLARE(carpet_switch_cd)
	/// List of carpets we can pick from, set up in New
	var/list/valid_carpets
	/// List of tables we can pick from, set up in New
	var/list/valid_tables

	guardian = list(/mob/living/basic/trooper/pirate/ranged/irs = 10)

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

///Dimension where eighties never went out of fashion.
/datum/dimension_theme/disco
	name = "Disco"
	icon = 'icons/obj/lighting.dmi'
	icon_state = "lbulb"
	material = /datum/material/glass

	replace_floors = list(/turf/open/floor/light = 1)
	replace_sec_floors = list(/turf/open/floor/neo/red = 1)
	replace_sci_floors = list(/turf/open/floor/neo/purple = 1)
	replace_med_floors = list(/turf/open/floor/neo/cyan = 1)
	replace_eng_floors = list(/turf/open/floor/neo/orange = 1)

	replace_carpets = list(/obj/item/stack/tile/eighties = 1)
	replace_sec_carpets = list(/obj/item/stack/tile/eighties/red = 1)
	replace_ser_carpets = list(/obj/item/stack/tile/carpet/neon/simple = 1)

	replace_objs = list(
		/obj/structure/chair = list(/obj/structure/chair/wood = 1),
		/obj/machinery/door/airlock = list(/obj/machinery/door/airlock/wood = 1),
		/obj/structure/table = list(/obj/structure/table/wood = 1),
		/obj/structure/platform = list(/obj/structure/platform/wood = 1),
	)

	random_spawns = list(
		/obj/machinery/jukebox/disco,
		/obj/structure/etherealball,
	)
	random_spawn_chance = 1

	guardian = list(/mob/living/basic/zombie/rotten/disco = 10)

/datum/dimension_theme/disco/transform_floor(turf/open/floor/affected_floor)
	. = ..()
	if (!.)
		return
	var/turf/open/floor/light/disco_floor = affected_floor
	disco_floor.currentcolor = pick(disco_floor.coloredlights)
	disco_floor.update_appearance()


///Dimension where lavaland's madness and primitiveness effect works at higher range.
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
		/obj/structure/platform = list(/obj/structure/platform/wood = 1),
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

	guardian = list(/mob/living/basic/gorilla/hostile = 1, /mob/living/carbon/human/species/monkey/angry = 5, /mob/living/basic/trooper/caveman = 4)

///Dimension where ayys overtook humanity.
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
		/obj/structure/platform = list(/obj/structure/platform/uranium = 1),
	)

	guardian = list(/mob/living/basic/trooper/abductor/melee = 7, /mob/living/basic/trooper/abductor/ranged = 3)

///Dimension where Ratvar still lives and won over the station.
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
		/obj/structure/platform = list(/obj/structure/platform/bronze = 1),
	)
	sound = 'sound/effects/magic/clockwork/fellowship_armory.ogg'
	guardian = list(/mob/living/basic/trooper/clock_cultist = 10)
