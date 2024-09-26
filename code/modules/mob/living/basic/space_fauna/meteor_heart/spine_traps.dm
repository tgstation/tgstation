/// Marks several areas with thrusting spines which damage and slow people
/datum/action/cooldown/mob_cooldown/spine_traps
	name = "thrusting spines"
	desc = "Mark several nearby areas with thrusting spines, which will spring up when disturbed."
	button_icon = 'icons/mob/simple/meteor_heart.dmi'
	button_icon_state = "spikes_stabbing"
	cooldown_time = 15 SECONDS
	shared_cooldown = NONE
	click_to_activate = FALSE
	/// Create zones at most this far away
	var/range = 3
	/// Don't create zones within this radius
	var/min_range = 2
	/// Number of zones to place
	var/zones_to_create = 3

/datum/action/cooldown/mob_cooldown/spine_traps/Activate(atom/target)
	. = ..()

	playsound(owner, 'sound/effects/magic/demon_consume.ogg', vol = 100, falloff_exponent = 2, vary = TRUE, pressure_affected = FALSE)
	var/list/valid_turfs = list()
	var/turf/our_turf = get_turf(owner)
	for (var/turf/zone_turf in orange(range, our_turf))
		if (!is_valid_turf(zone_turf) || get_dist(zone_turf, our_turf) < min_range)
			continue
		valid_turfs += zone_turf

	var/created = 0
	while(length(valid_turfs) && created < zones_to_create)
		var/turf/place_turf = pick_n_take(valid_turfs)
		var/list/covered_turfs = place_zone(place_turf)
		valid_turfs -= covered_turfs
		created++

/// Returns true if we can place a trap at the specified location
/datum/action/cooldown/mob_cooldown/spine_traps/proc/is_valid_turf(turf/target_turf)
	return !target_turf.is_blocked_turf(exclude_mobs = TRUE) && !isspaceturf(target_turf) && !isopenspaceturf(target_turf)

/// Places a 3x3 area of spike traps around a central provided point, returns the list of now occupied turfs
/datum/action/cooldown/mob_cooldown/spine_traps/proc/place_zone(turf/target_turf)
	var/list/used_turfs = list()
	for (var/turf/zone_turf in range(1, target_turf))
		if (!is_valid_turf(zone_turf))
			continue
		new /obj/effect/temp_visual/thrusting_spines(zone_turf)
		used_turfs += zone_turf
	return used_turfs

/obj/effect/temp_visual/thrusting_spines
	icon = 'icons/mob/simple/meteor_heart.dmi'
	icon_state = "spikes_idle"
	desc = "Sharp spines lying in wait in the ground, you probably don't want to walk on those."
	duration = 10 SECONDS
	/// If this will trigger a trap when entered
	var/active = FALSE
	/// Damage to deal on activation
	var/impale_damage = 10
	/// Time between activations
	COOLDOWN_DECLARE(thrust_delay)
	/// Weighted list of body zones to target while standing
	var/static/list/standing_damage_zones = list(
		BODY_ZONE_CHEST = 1,
		BODY_ZONE_R_LEG = 3,
		BODY_ZONE_L_LEG = 3,
	)

/obj/effect/temp_visual/thrusting_spines/Initialize(mapload)
	. = ..()
	flick("spikes_emerge", src)
	addtimer(CALLBACK(src, PROC_REF(ready)), 1 SECONDS, TIMER_DELETE_ME)
	addtimer(CALLBACK(src, PROC_REF(retract)), duration - (0.5 SECONDS), TIMER_DELETE_ME)

	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/// Called when we're ready to start impaling people
/obj/effect/temp_visual/thrusting_spines/proc/ready()
	active = TRUE

/// Called when it is time to stop impaling people
/obj/effect/temp_visual/thrusting_spines/proc/retract()
	active = FALSE
	icon_state = "spikes_submerge"

/// Called when something enters our turf, if it is a non-flying mob then give it a stab
/obj/effect/temp_visual/thrusting_spines/proc/on_entered(datum/source, atom/movable/arrived)
	if (!active || !isliving(arrived) || (arrived.movement_type & MOVETYPES_NOT_TOUCHING_GROUND))
		return
	if (!COOLDOWN_FINISHED(src, thrust_delay))
		return

	COOLDOWN_START(src, thrust_delay, 0.7 SECONDS)
	playsound(src, 'sound/items/weapons/pierce.ogg', vol = 50, vary = TRUE, pressure_affected = FALSE)
	var/mob/living/victim = arrived
	flick("spikes_stabbing", src)
	var/target_zone = victim.resting ? BODY_ZONE_CHEST : pick_weight(standing_damage_zones)
	victim.apply_damage(impale_damage, damagetype = BRUTE, def_zone = target_zone, sharpness = SHARP_POINTY)
