/turf/open/deepwater
	gender = PLURAL
	name = "deep water"
	desc = "The currents are so incredibly powerful!"
	icon = 'icons/turf/floors.dmi'
	icon_state = "chasmwater_motion"
	baseturfs = /turf/open/water
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	planetary_atmos = TRUE
	slowdown = 10
	bullet_sizzle = TRUE
	bullet_bounce_sound = null //needs a splashing sound one day.

	footstep = FOOTSTEP_WATER
	barefootstep = FOOTSTEP_WATER
	clawfootstep = FOOTSTEP_WATER
	heavyfootstep = FOOTSTEP_WATER

/turf/open/deepwater/proc/wash_obj(obj/O)
	. = SEND_SIGNAL(O, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_WEAK)
	O.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)

turf/open/deepwater/Enter(mob/A)
	if(istype(A,/mob/living))
		var/mob/living/L = A
		if(!L.buckled)
			if(istype(L, /mob/living/simple_animal) || istype(L, /mob/living/carbon/monkey))
				return
			else
				return ..()
		else
			return ..()
	else
		return ..()

/turf/open/deepwater/Entered(atom/movable/A)
	. = ..()
	var/turf/open/closest = null
	var/closestdist = 9999
	for(var/turf/open/T in view(src,6))
		if(closestdist < get_dist(src, T))
			closest = T
			closestdist = get_dist(src, T)

	walk_to(A, closest)

/turf/open/deepwater/MakeSlippery(wet_setting, min_wet_time, wet_time_to_add, max_wet_time, permanent)
	return

/turf/open/deepwater/acid_act(acidpwr, acid_volume)
	return

/turf/open/deepwater/MakeDry(wet_setting = TURF_WET_WATER)
	return

/turf/open/deepwater/singularity_act()
	return

/turf/open/deepwater/singularity_pull(S, current_size)
	return