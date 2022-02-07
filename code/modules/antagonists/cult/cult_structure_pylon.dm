// Cult pylon. Heals nearby cultists and converts turfs to cult turfs.
/obj/structure/destructible/cult/pylon
	name = "pylon"
	desc = "A floating crystal that slowly heals those faithful to Nar'Sie."
	icon_state = "pylon"
	light_range = 1.5
	light_color = COLOR_SOFT_RED
	break_sound = 'sound/effects/glassbr2.ogg'
	break_message = "<span class='warning'>The blood-red crystal falls to the floor and shatters!</span>"
	/// Length of the cooldown in between tile corruptions. Doubled if no turfs are found.
	var/corruption_cooldown_duration = 5 SECONDS
	/// The cooldown for corruptions.
	COOLDOWN_DECLARE(corruption_cooldown)

/obj/structure/destructible/cult/pylon/Initialize(mapload)
	. = ..()

	AddComponent( \
		/datum/component/aura_healing, \
		range = 5, \
		brute_heal = 0.4, \
		burn_heal = 0.4, \
		blood_heal = 0.4, \
		simple_heal = 1.2, \
		requires_visibility = FALSE, \
		limit_to_trait = TRAIT_HEALS_FROM_CULT_PYLONS, \
		healing_color = COLOR_CULT_RED, \
	)

	START_PROCESSING(SSfastprocess, src)

/obj/structure/destructible/cult/pylon/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/obj/structure/destructible/cult/pylon/process()
	if(!anchored)
		return
	if(!COOLDOWN_FINISHED(src, corruption_cooldown))
		return

	var/list/validturfs = list()
	var/list/cultturfs = list()
	for(var/nearby_turf in circle_view_turfs(src, 5))
		if(istype(nearby_turf, /turf/open/floor/engine/cult))
			cultturfs |= nearby_turf
			continue
		var/static/list/blacklisted_pylon_turfs = typecacheof(list(
			/turf/closed,
			/turf/open/floor/engine/cult,
			/turf/open/space,
			/turf/open/lava,
			/turf/open/chasm))
		if(is_type_in_typecache(nearby_turf, blacklisted_pylon_turfs))
			continue
		validturfs |= nearby_turf

	if(length(validturfs))
		var/turf/converted_turf = pick(validturfs)
		if(istype(converted_turf, /turf/open/floor/plating))
			converted_turf.PlaceOnTop(/turf/open/floor/engine/cult, flags = CHANGETURF_INHERIT_AIR)
		else
			converted_turf.ChangeTurf(/turf/open/floor/engine/cult, flags = CHANGETURF_INHERIT_AIR)

	else if (length(cultturfs))
		var/turf/open/floor/engine/cult/cult_turf = pick(cultturfs)
		new /obj/effect/temp_visual/cult/turf/floor(cult_turf)

	else
		// Are we in space or something? No cult turfs or convertable turfs? Double the cooldown
		COOLDOWN_START(src, corruption_cooldown, corruption_cooldown_duration * 2)
		return

	COOLDOWN_START(src, corruption_cooldown, corruption_cooldown_duration)

/obj/structure/destructible/cult/pylon/conceal()
	. = ..()
	STOP_PROCESSING(SSfastprocess, src)

/obj/structure/destructible/cult/pylon/reveal()
	. = ..()
	START_PROCESSING(SSfastprocess, src)
