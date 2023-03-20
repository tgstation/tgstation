/// An ability which makes spikes come out of the ground towards your target
/datum/action/cooldown/chasing_spikes
	name = "impaling tendril"
	desc = "Send a spiked subterranean tendril chasing after your target."
	button_icon = 'icons/mob/simple/meteor_heart.dmi'
	button_icon_state = "spike"
	cooldown_time = 10 SECONDS
	click_to_activate = TRUE
	/// Lazy list of references to spike trails
	var/list/active_chasers

/datum/action/cooldown/chasing_spikes/Activate(atom/target)
	. = ..()
	playsound(owner, 'sound/magic/demon_attack1.ogg', vol = 100, vary = TRUE, pressure_affected = FALSE)
	var/obj/effect/temp_visual/spike_chaser/chaser = new(get_turf(owner), target)
	LAZYADD(active_chasers, WEAKREF(chaser))
	RegisterSignal(chaser, COMSIG_PARENT_QDELETING, PROC_REF(on_chaser_destroyed))

/// Remove a spike trail from our list of active trails
/datum/action/cooldown/chasing_spikes/proc/on_chaser_destroyed(atom/chaser)
	SIGNAL_HANDLER
	LAZYREMOVE(active_chasers, WEAKREF(chaser))

// Clean up after ourselves
/datum/action/cooldown/chasing_spikes/Remove(mob/removed_from)
	QDEL_LIST(active_chasers)
	return ..()

/// An invisible effect which chases a target, spawning spikes every so often.
/obj/effect/temp_visual/spike_chaser
	name = "spike chaser"
	desc = "An invisible effect, how did you examine this?"
	icon = 'icons/mob/silicon/cameramob.dmi'
	icon_state = "marker"
	duration = 15 SECONDS
	invisibility = INVISIBILITY_ABSTRACT
	/// Speed at which we chase target
	var/move_speed = 3
	/// What are we chasing?
	var/datum/weakref/target
	/// Handles chasing the target
	var/datum/move_loop/movement

/obj/effect/temp_visual/spike_chaser/Initialize(mapload, atom/target)
	. = ..()
	if (!target)
		return INITIALIZE_HINT_QDEL

	AddElement(/datum/element/floor_loving)
	AddComponent(/datum/component/spawner, spawn_types = list(/obj/effect/temp_visual/emerging_ground_spike), spawn_time = 0.5 SECONDS)
	src.target = WEAKREF(target)
	movement = SSmove_manager.move_towards(src, chasing = target, delay = move_speed, home = TRUE, timeout = duration, flags = MOVEMENT_LOOP_START_FAST)

	RegisterSignal(target, COMSIG_PARENT_QDELETING, PROC_REF(on_target_invalid))
	if (isliving(target))
		RegisterSignal(target, COMSIG_LIVING_DEATH, PROC_REF(on_target_invalid))

/// Destroy ourselves if the target is no longer valid
/obj/effect/temp_visual/spike_chaser/proc/on_target_invalid()
	SIGNAL_HANDLER
	qdel(src)

/obj/effect/temp_visual/spike_chaser/Destroy()
	QDEL_NULL(movement)
	return ..()

/// A spike comes out of the ground, dealing damage after a short delay
/obj/effect/temp_visual/emerging_ground_spike
	name = "bone spike"
	desc = "A sharp spur of bone erupting from the ground!"
	icon = 'icons/mob/simple/meteor_heart.dmi'
	icon_state = "spike"
	duration = 1 SECONDS
	/// Time until we hurt people stood on us
	var/harm_delay = 0.3 SECONDS
	/// Amount by which to vary our position on spawn
	var/position_variance = 8
	/// Damage to deal on impale
	var/impale_damage = 15
	/// Typecache of types of mobs not to damage
	var/list/damage_blacklist_typecache = list(
		/mob/living/basic/meteor_heart,
	)
	/// Weighted list of body zones to target while standing
	var/static/list/standing_damage_zones = list(
		BODY_ZONE_CHEST = 1,
		BODY_ZONE_R_LEG = 3,
		BODY_ZONE_L_LEG = 3,
	)

/obj/effect/temp_visual/emerging_ground_spike/Initialize(mapload)
	. = ..()
	damage_blacklist_typecache = typecacheof(damage_blacklist_typecache)
	pixel_x += rand(-position_variance, position_variance)
	pixel_y += rand(-position_variance, position_variance)
	addtimer(CALLBACK(src, PROC_REF(impale)), harm_delay, TIMER_DELETE_ME)

/// Stab people who are stood on us after a delay in the shins
/obj/effect/temp_visual/emerging_ground_spike/proc/impale()
	if (!isturf(loc))
		return
	var/hit_someone = FALSE
	for(var/mob/living/victim in loc)
		if (is_type_in_typecache(victim, damage_blacklist_typecache))
			continue
		hit_someone = TRUE
		var/target_zone = victim.resting ? BODY_ZONE_CHEST : pick_weight(standing_damage_zones)
		victim.apply_damage(impale_damage, damagetype = BRUTE, def_zone = target_zone, sharpness = SHARP_POINTY)
	if (hit_someone)
		playsound(src, 'sound/weapons/slice.ogg', vol = 50, vary = TRUE, pressure_affected = FALSE)
	else
		playsound(src, 'sound/misc/splort.ogg', vol = 25, vary = TRUE, pressure_affected = FALSE)
