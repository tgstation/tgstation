
/obj/effect/anomaly/bluespace
	name = "bluespace anomaly"
	icon = 'icons/obj/weapons/guns/projectiles.dmi'
	icon_state = "bluespace"
	density = TRUE
	anomaly_core = /obj/item/assembly/signaler/anomaly/bluespace
	///range from which we can teleport someone
	var/teleport_range = 1
	///Distance we can teleport someone passively
	var/teleport_distance = 4

/obj/effect/anomaly/bluespace/Initialize(mapload, new_lifespan)
	. = ..()
	apply_wibbly_filters(src)

/obj/effect/anomaly/bluespace/anomalyEffect()
	..()
	for(var/mob/living/M in range(teleport_range,src))
		do_teleport(M, locate(M.x, M.y, M.z), teleport_distance, channel = TELEPORT_CHANNEL_BLUESPACE)

/obj/effect/anomaly/bluespace/Bumped(atom/movable/AM)
	if(isliving(AM))
		do_teleport(AM, locate(AM.x, AM.y, AM.z), 8, channel = TELEPORT_CHANNEL_BLUESPACE)

/obj/effect/anomaly/bluespace/detonate()
	new /obj/effect/temp_visual/circle_wave/bluespace(get_turf(src))
	playsound(src, 'sound/effects/magic/cosmic_energy.ogg', vol = 50)

	var/turf/impact_turf = pick(get_area_turfs(impact_area))
	if(!impact_turf)
		return

	// Calculate new position (searches through beacons in world)
	var/obj/item/beacon/chosen
	var/list/possible = list()
	for(var/obj/item/beacon/beacon in GLOB.teleportbeacons)
		var/turf/turf = get_turf(beacon)
		if(!turf)
			continue
		if(is_centcom_level(turf.z) || is_away_level(turf.z))
			continue
		if(!check_teleport_valid(src, turf))
			continue
		possible += beacon

	if(possible.len > 0)
		chosen = pick(possible)

	if(!chosen)
		return

	// Calculate previous position for transition
	var/turf/beacon_turf = get_turf(chosen) // the turf of origin we're travelling TO

	playsound(beacon_turf, 'sound/effects/phasein.ogg', 100, TRUE)
	priority_announce("Зафиксирован массивный выброс блюспейс энергии.", "Обнаружена аномалия")

	var/list/flashers = list()
	for(var/mob/living/living in viewers(beacon_turf, null))
		if(living.flash_act(affect_silicon = TRUE, visual = TRUE, type = /atom/movable/screen/fullscreen/bluespace_sparkle, length = 2 SECONDS))
			flashers += living

	var/y_distance = beacon_turf.y - impact_turf.y
	var/x_distance = beacon_turf.x - impact_turf.x
	var/list/available_turfs = RANGE_TURFS(12, beacon_turf)
	for (var/atom/movable/movable in urange(12, impact_turf )) // iterate thru list of mobs in the area
		if(istype(movable, /obj/item/beacon) || iseffect(movable) || iseyemob(movable))
			continue // Don't mess with beacons, effects or camera mobs (blob, AI eye etc...)
		if(movable.anchored)
			continue // do_teleport doesn't check if the item is anchored or not.

		var/turf/newloc = locate(movable.x + x_distance, movable.y + y_distance, beacon_turf.z) || pick(available_turfs) // calculate the new place, or pick a random one as fallback
		do_teleport(movable, newloc, no_effects = TRUE)

		if(isliving(movable) && !(movable in flashers)) // don't flash if we're already doing an effect
			var/mob/living/give_sparkles = movable
			give_sparkles.flash_act(affect_silicon = TRUE, visual = TRUE, type = /atom/movable/screen/fullscreen/bluespace_sparkle, length = 2 SECONDS)

/obj/effect/anomaly/bluespace/stabilize(anchor, has_core)
	. = ..()

	teleport_range = 0 //bumping already teleports, so this just prevents people from being teleported when they don't expect it when interacting with stable bsanoms

///Bigger, meaner, immortal bluespace anomaly
/obj/effect/anomaly/bluespace/big
	immortal = TRUE
	teleport_range = 2
	teleport_distance = 12
	anomaly_core = null

/obj/effect/anomaly/bluespace/big/Initialize(mapload, new_lifespan)
	. = ..()

	transform *= 3

/obj/effect/anomaly/bluespace/big/Bumped(atom/movable/bumpee)
	if(iscarbon(bumpee))
		var/mob/living/carbon/carbon = bumpee
		carbon.reagents?.add_reagent(/datum/reagent/bluespace, 20)

	if(!isliving(bumpee))
		return ..()

	var/mob/living/living = bumpee
	living.apply_status_effect(/datum/status_effect/teleport_madness)

/obj/effect/temp_visual/circle_wave/bluespace
	color = COLOR_BLUE_LIGHT
	duration = 1 SECONDS
	amount_to_scale = 5
