
/obj/effect/anomaly/bioscrambler
	name = "bioscrambler anomaly"
	icon_state = "bioscrambler"
	aSignal = /obj/item/assembly/signaler/anomaly/bioscrambler
	immortal = TRUE
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE | PASSCLOSEDTURF | PASSMACHINE | PASSSTRUCTURE | PASSDOORS
	layer = ABOVE_MOB_LAYER
	/// Who are we moving towards?
	var/datum/weakref/pursuit_target
	/// Cooldown for every anomaly pulse
	COOLDOWN_DECLARE(pulse_cooldown)
	/// How many seconds between each anomaly pulses
	var/pulse_delay = 15 SECONDS
	/// Range of the anomaly pulse
	var/range = 5

/obj/effect/anomaly/bioscrambler/Initialize(mapload, new_lifespan, drops_core)
	. = ..()
	pursuit_target = WEAKREF(find_nearest_target())

/obj/effect/anomaly/bioscrambler/anomalyEffect(seconds_per_tick)
	. = ..()
	if(!COOLDOWN_FINISHED(src, pulse_cooldown))
		return

	COOLDOWN_START(src, pulse_cooldown, pulse_delay)
	for(var/mob/living/carbon/nearby in hearers(range, src))
		nearby.bioscramble(name)

/obj/effect/anomaly/bioscrambler/move_anomaly()
	var/mob/living/current_target = pursuit_target?.resolve()
	if (QDELETED(current_target))
		pursuit_target = null
	if (isnull(pursuit_target) || prob(20))
		var/mob/living/new_target = find_nearest_target()
		if (isnull(new_target))
			pursuit_target = null
		else if (new_target != current_target)
			current_target = new_target
			pursuit_target = WEAKREF(new_target)
			new_target.ominous_nosebleed()
	if (isnull(pursuit_target))
		return
	var/turf/step_turf = get_step(src, get_dir(src, current_target))
	if (!HAS_TRAIT(step_turf, TRAIT_CONTAINMENT_FIELD))
		Move(step_turf)

/// Returns the closest conscious carbon on our z level or null if there somehow isn't one
/obj/effect/anomaly/bioscrambler/proc/find_nearest_target()
	var/closest_distance = INFINITY
	var/mob/living/carbon/closest_target = null
	for(var/mob/living/carbon/target in GLOB.player_list)
		if (target.z != z)
			continue
		if (target.status_effects & GODMODE)
			continue	
		if (target.stat >= UNCONSCIOUS)
			continue // Don't just haunt a corpse
		var/distance_from_target = get_dist(src, target)
		if(distance_from_target >= closest_distance)
			continue
		closest_distance = distance_from_target
		closest_target = target

	return closest_target
