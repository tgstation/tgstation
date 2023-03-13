/// An ability which makes spikes come out of the ground towards your target
/datum/action/cooldown/ground_spikes
	name = "ground spikes"
	desc = "Send a spiked subterranean tendril chasing after your target."
	button_icon = 'icons/obj/weapons/guns/projectiles.dmi'
	button_icon_state = "arcane_barrage"
	cooldown_time = 10 SECONDS
	click_to_activate = TRUE

/datum/action/cooldown/ground_spikes/Activate(atom/target)
	. = ..()
	new /obj/effect/temp_visual/spike_chaser(get_turf(owner), target)

/// An invisible effect which chases a target, spawning spikes every so often.
/obj/effect/temp_visual/spike_chaser
	name = "spike chaser"
	desc = "An invisible effect, how did you examine this?"
	icon = 'icons/mob/silicon/cameramob.dmi'
	icon_state = "marker"
	duration = 15 SECONDS
	invisibility = INVISIBILITY_ABSTRACT
	/// Speed at which we chase target
	var/move_speed = 2
	/// What are we chasing?
	var/datum/weakref/target
	/// Handles chasing the target
	var/datum/move_loop/movement

/obj/effect/temp_visual/spike_chaser/Initialize(mapload, atom/target)
	if (!target)
		return INITIALIZE_HINT_QDEL

	. = ..()
	AddComponent(/datum/component/spawner, spawn_types = list(/obj/effect/temp_visual/emerging_ground_spike), spawn_time = 0.5 SECONDS)
	src.target = WEAKREF(target)
	movement = SSmove_manager.move_towards(src, chasing = target, delay = move_speed, home = TRUE, timeout = duration, flags = MOVEMENT_LOOP_START_FAST)

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
	var/position_variance = 6
	/// Damage to deal on impale
	var/impale_damage = 15
	/// Typecache of types of mobs not to damage
	var/list/damage_blacklist_typecache = list(
		/mob/living/basic/meteor_heart,
	)

/obj/effect/temp_visual/emerging_ground_spike/Initialize(mapload)
	. = ..()
	damage_blacklist_typecache = typecacheof(damage_blacklist_typecache)
	pixel_x += rand(-position_variance, position_variance)
	pixel_y += rand(-position_variance, position_variance)
	addtimer(CALLBACK(src, PROC_REF(impale), harm_delay, TIMER_DELETE_ME))

/// Stab people who are stood on us after a delay in the shins
/obj/effect/temp_visual/emerging_ground_spike/proc/impale()
	if (!isturf(loc))
		return
	for(var/mob/living/attacked_living in loc)
		if (is_type_in_typecache(attacked_living, damage_blacklist_typecache))
			continue
		var/target_zone = attacked_living.resting ? BODY_ZONE_CHEST : pick(BODY_ZONE_R_LEG, BODY_ZONE_L_LEG)
		attacked_living.apply_damage(impale_damage, damagetype = BRUTE, def_zone = target_zone, sharpness = SHARP_POINTY)
