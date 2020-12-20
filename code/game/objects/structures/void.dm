/obj/structure/void
	icon = 'icons/mob/void.dmi'
	max_integrity = 100

/obj/structure/void/run_obj_armor(damage_amount, damage_type, damage_flag = 0, attack_dir)
	if(damage_flag == MELEE)
		switch(damage_type)
			if(BRUTE)
				damage_amount *= 0.5
			if(BURN)
				damage_amount *= 2
	. = ..()

/obj/structure/void/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(loc, 'sound/effects/attackblob.ogg', 100, TRUE)
			else
				playsound(src, 'sound/weapons/tap.ogg', 50, TRUE)
		if(BURN)
			if(damage_amount)
				playsound(loc, 'sound/items/welder.ogg', 100, TRUE)


/*
 * Weeds
 */

#define NODERANGE 3

/obj/structure/void/weeds
	gender = PLURAL
	name = "void"
	desc = "A lightless floor. It feels like you're stepping on something, but there's nothing."
	anchored = TRUE
	density = FALSE
	layer = TURF_LAYER
	plane = FLOOR_PLANE
	icon_state = "weeds"
	max_integrity = 15
	smoothing_flags = SMOOTH_CORNERS
	smoothing_groups = list(SMOOTH_GROUP_VOID_WEEDS)
	canSmoothWith = list(SMOOTH_GROUP_VOID_WEEDS, SMOOTH_GROUP_WALLS)
	var/last_expand = 0 //last world.time this weed expanded
	var/growth_cooldown_low = 200
	var/growth_cooldown_high = 800
	var/static/list/blacklisted_turfs

/obj/structure/void/weeds/Initialize()
	pixel_x = -4
	pixel_y = -4 //so the sprites line up right in the map editor
	. = ..()

	if(!blacklisted_turfs)
		blacklisted_turfs = typecacheof(list(
			/turf/open/space,
			/turf/open/chasm,
			/turf/open/lava))


	last_expand = world.time + rand(growth_cooldown_low, growth_cooldown_high)
	if(icon == initial(icon))
		switch(rand(1,2))
			if(1)
				icon = 'icons/obj/smooth_structures/void/void2.dmi'
			if(2)
				icon = 'icons/obj/smooth_structures/void/void2.dmi'

/obj/structure/void/weeds/proc/expand()
	var/turf/U = get_turf(src)
	if(is_type_in_typecache(U, blacklisted_turfs))
		qdel(src)
		return FALSE

	for(var/turf/T in U.GetAtmosAdjacentTurfs())
		if(locate(/obj/structure/void/weeds) in T)
			continue

		if(is_type_in_typecache(T, blacklisted_turfs))
			continue

		new /obj/structure/void/weeds(T)
	return TRUE

/obj/structure/void/weeds/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		take_damage(5, BURN, 0, 0)

//Weed nodes
/obj/structure/void/weeds/node
	name = "voidsource"
	desc = "A single red light spreads the void around."
	icon_state = "voidnode"
	light_color = LIGHT_COLOR_BLOOD_MAGIC
	light_power = 0.5
	var/lon_range = 4
	var/node_range = NODERANGE

/obj/structure/void/weeds/node/Initialize()
	icon = 'icons/obj/smooth_structures/void/voidnode.dmi'
	. = ..()
	set_light(lon_range)
	var/obj/structure/void/weeds/W = locate(/obj/structure/void/weeds) in loc
	if(W && W != src)
		qdel(W)
	START_PROCESSING(SSobj, src)

/obj/structure/void/weeds/node/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/void/weeds/node/process()
	for(var/obj/structure/void/weeds/W in range(node_range, src))
		if(W.last_expand <= world.time)
			if(W.expand())
				W.last_expand = world.time + rand(growth_cooldown_low, growth_cooldown_high)

#undef NODERANGE
