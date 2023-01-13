/**
 * # Magicarp Bolt
 * Holder ability simply for "firing a projectile with a cooldown".
 * Probably won't do anything if assigned via VV unless you also VV in a projectile for it.
 */
/datum/action/cooldown/mob_cooldown/projectile_attack/magicarp_bolt
	name = "Magicarp Blast"
	desc = "Unleash a bolt of magical force at a target you click on."
	button_icon = 'icons/obj/weapons/guns/projectiles.dmi'
	button_icon_state = "arcane_barrage"
	cooldown_time = 5 SECONDS
	projectile_sound = 'sound/weapons/emitter.ogg'
	melee_cooldown_time = 0 SECONDS // Without this they become extremely hesitant to bite anyone ever
	shared_cooldown = MOB_SHARED_COOLDOWN_2

/datum/action/cooldown/mob_cooldown/projectile_attack/magicarp_bolt/chaos/attack_sequence(mob/living/firer, atom/target)
	playsound(get_turf(firer), projectile_sound, 100, vary = TRUE)
	return ..()

/// Chaos variant picks one from a list
/datum/action/cooldown/mob_cooldown/projectile_attack/magicarp_bolt/chaos
	/// List of things we can cast
	var/list/permitted_projectiles = list()

/datum/action/cooldown/mob_cooldown/projectile_attack/magicarp_bolt/chaos/attack_sequence(mob/living/firer, atom/target)
	if (!length(permitted_projectiles))
		return
	projectile_type = pick(permitted_projectiles)
	return ..()

/**
 * # Lesser Carp Rift
 * Teleport a short distance and leave a short-lived portal for people to follow through
 */
/datum/action/cooldown/mob_cooldown/lesser_carp_rift
	name = "Lesser Carp Rift"
	button_icon = 'icons/effects/effects.dmi'
	button_icon_state = "rift"
	desc = "Open a rift through the carp stream, allowing passage to somewhere close by."
	cooldown_time = 1 MINUTES
	melee_cooldown_time = 2 SECONDS
	/// How far away can you place a rift?
	var/max_range = 6

/datum/action/cooldown/mob_cooldown/lesser_carp_rift/Activate(atom/target_atom)
	if (!make_rift(target_atom))
		return FALSE
	StartCooldown()
	return TRUE

/datum/action/cooldown/mob_cooldown/lesser_carp_rift/proc/make_rift(atom/target_atom)
	if (owner.Adjacent(target_atom))
		owner.balloon_alert(owner, "too close!")
		return FALSE

	var/turf/owner_turf = get_turf(owner)
	var/turf/target_turf = get_turf(target_atom)
	if (!target_turf)
		return FALSE

	if (get_dist(owner_turf, target_turf) > max_range)
		owner.balloon_alert(owner, "too far!")
		return FALSE

	if (!target_turf)
		return FALSE

	var/list/open_exit_turfs = list()
	for (var/turf/potential_exit in orange(1, target_turf))
		if (potential_exit.is_blocked_turf(exclude_mobs = TRUE))
			continue
		open_exit_turfs += potential_exit

	if (!length(open_exit_turfs))
		owner.balloon_alert(owner, "no exit!")
		return FALSE
	if (!target_turf.is_blocked_turf(exclude_mobs = TRUE))
		open_exit_turfs += target_turf

	new /obj/effect/temp_visual/lesser_carp_rift/exit(target_turf)
	var/obj/effect/temp_visual/lesser_carp_rift/entrance/enter = new(owner_turf)
	enter.exit_locs = open_exit_turfs
	enter.on_entered(enter, owner)
	return TRUE

/// If you touch the entrance you are teleported to the exit, exit doesn't do anything
/obj/effect/temp_visual/lesser_carp_rift
	name = "lesser carp rift"
	icon_state = "rift"
	duration = 5 SECONDS
	/// Holds a reference to a timer until this gets deleted
	var/destroy_timer

/obj/effect/temp_visual/lesser_carp_rift/Initialize(mapload)
	destroy_timer = addtimer(CALLBACK(src, PROC_REF(animate_out)), duration - 1, TIMER_STOPPABLE)
	return ..()

/obj/effect/temp_visual/lesser_carp_rift/proc/animate_out()
	var/obj/effect/temp_visual/lesser_carp_rift_dissipating/animate_out = new(loc)
	animate_out.setup_animation(alpha)

/obj/effect/temp_visual/lesser_carp_rift/Destroy()
	. = ..()
	deltimer(destroy_timer)

/// If you touch this you are taken to the exit
/obj/effect/temp_visual/lesser_carp_rift/entrance
	/// Where you get teleported to
	var/list/exit_locs

/obj/effect/temp_visual/lesser_carp_rift/entrance/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/temp_visual/lesser_carp_rift/entrance/proc/on_entered(datum/source, atom/movable/entered_atom)
	SIGNAL_HANDLER

	if (!length(exit_locs))
		return
	if (!ismob(entered_atom) && !isobj(entered_atom))
		return
	if (entered_atom.anchored)
		return
	if(!entered_atom.loc)
		return
	if (isobserver(entered_atom))
		return

	var/turf/destination = pick(exit_locs)
	do_teleport(entered_atom, destination, channel = TELEPORT_CHANNEL_MAGIC)
	playsound(src, 'sound/magic/wand_teleport.ogg', 50)
	playsound(destination, 'sound/magic/wand_teleport.ogg', 50)

/// Doesn't actually do anything, just a visual marker
/obj/effect/temp_visual/lesser_carp_rift/exit
	alpha = 125

/// Just an animation
/obj/effect/temp_visual/lesser_carp_rift_dissipating
	name = "lesser carp rift"
	icon_state = "rift"
	duration = 1 SECONDS

/obj/effect/temp_visual/lesser_carp_rift_dissipating/proc/setup_animation(new_alpha)
	alpha = new_alpha
	animate(src, alpha = 0, time = duration - 1)
