/// A tentacle which grabs you if you don't get away from it
/obj/effect/goliath_tentacle
	name = "goliath tentacle"
	icon = 'icons/mob/simple/lavaland/lavaland_monsters.dmi'
	icon_state = "goliath_tentacle_spawn"
	layer = BELOW_MOB_LAYER
	plane = GAME_PLANE
	anchored = TRUE
	/// Timer for our current action stage
	var/action_timer
	/// Time in which to grab people
	var/grapple_time = 10 SECONDS
	/// Lower bound of damage to inflict
	var/min_damage = 10
	/// Upper bound of damage to inflict
	var/max_damage =  15

/obj/effect/goliath_tentacle/Initialize(mapload)
	. = ..()
	if (ismineralturf(loc))
		var/turf/closed/mineral/floor = loc
		floor.gets_drilled()
	if (!isopenturf(loc) || is_space_or_openspace(loc))
		return INITIALIZE_HINT_QDEL
	for (var/obj/effect/goliath_tentacle/tentacle in loc)
		if (tentacle != src)
			return INITIALIZE_HINT_QDEL
	deltimer(action_timer)
	action_timer = addtimer(CALLBACK(src, PROC_REF(animate_grab)), 0.7 SECONDS, TIMER_STOPPABLE)

/obj/effect/goliath_tentacle/Destroy()
	deltimer(action_timer)
	return ..()

/// Change to next icon state and set up grapple
/obj/effect/goliath_tentacle/proc/animate_grab()
	icon_state = "goliath_tentacle_wiggle"
	deltimer(action_timer)
	addtimer(CALLBACK(src, PROC_REF(grab)), 0.3 SECONDS, TIMER_STOPPABLE)

/// Grab everyone we share space with. If it's nobody, go home.
/obj/effect/goliath_tentacle/proc/grab()
	for (var/mob/living/victim in loc)
		if (victim.stat == DEAD || HAS_TRAIT(victim, TRAIT_TENTACLE_IMMUNE))
			continue
		balloon_alert(victim, "grabbed")
		visible_message(span_danger("[src] grabs hold of [victim]!"))
		victim.adjustBruteLoss(rand(min_damage, max_damage))
		if (victim.apply_status_effect(/datum/status_effect/incapacitating/stun/goliath_tentacled, grapple_time, src))
			buckle_mob(victim, TRUE)
			SEND_SIGNAL(victim, COMSIG_GOLIATH_TENTACLED_GRABBED)
	for (var/obj/vehicle/sealed/mecha/mech in loc)
		mech.take_damage(rand(min_damage, max_damage), damage_type = BRUTE, damage_flag = MELEE, sound_effect = TRUE)
	if (!has_buckled_mobs())
		retract()
		return
	deltimer(action_timer)
	action_timer = addtimer(CALLBACK(src, PROC_REF(retract)), grapple_time, TIMER_STOPPABLE)

/// Play exit animation.
/obj/effect/goliath_tentacle/proc/retract()
	if (icon_state == "goliath_tentacle_retract")
		return // Already retracting
	SEND_SIGNAL(src, COMSIG_GOLIATH_TENTACLE_RETRACTING)
	unbuckle_all_mobs(force = TRUE)
	icon_state = "goliath_tentacle_retract"
	deltimer(action_timer)
	action_timer = QDEL_IN_STOPPABLE(src, 0.7 SECONDS)

/obj/effect/goliath_tentacle/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if (. || !has_buckled_mobs())
		return
	retract()
	return TRUE

/// Goliath tentacle stun with special removal conditions
/datum/status_effect/incapacitating/stun/goliath_tentacled
	id = "goliath_tentacled"
	duration = 10 SECONDS
	/// The tentacle that is tenderly holding us close
	var/obj/effect/goliath_tentacle/tentacle

/datum/status_effect/incapacitating/stun/goliath_tentacled/on_creation(mob/living/new_owner, set_duration, obj/effect/goliath_tentacle/tentacle)
	. = ..()
	if (!.)
		return
	src.tentacle = tentacle

/datum/status_effect/incapacitating/stun/goliath_tentacled/on_apply()
	. = ..()
	RegisterSignal(owner, COMSIG_CARBON_PRE_MISC_HELP, PROC_REF(on_helped))
	RegisterSignals(owner, list(SIGNAL_ADDTRAIT(TRAIT_TENTACLE_IMMUNE), COMSIG_BRIMDUST_EXPLOSION), PROC_REF(release))
	RegisterSignals(tentacle, list(COMSIG_QDELETING, COMSIG_GOLIATH_TENTACLE_RETRACTING), PROC_REF(on_tentacle_left))

/datum/status_effect/incapacitating/stun/goliath_tentacled/on_remove()
	. = ..()
	UnregisterSignal(owner, list(COMSIG_CARBON_PRE_MISC_HELP, SIGNAL_ADDTRAIT(TRAIT_TENTACLE_IMMUNE), COMSIG_BRIMDUST_EXPLOSION))
	if (isnull(tentacle))
		return
	UnregisterSignal(tentacle, list(COMSIG_QDELETING, COMSIG_GOLIATH_TENTACLE_RETRACTING))
	tentacle.retract()
	tentacle = null

/// Some kind soul has rescued us
/datum/status_effect/incapacitating/stun/goliath_tentacled/proc/on_helped(mob/source, mob/helping)
	SIGNAL_HANDLER
	release()
	source.visible_message(span_notice("[helping] rips [source] from the tentacle's grasp!"))
	return COMPONENT_BLOCK_MISC_HELP

/// Something happened to make the tentacle let go
/datum/status_effect/incapacitating/stun/goliath_tentacled/proc/release()
	SIGNAL_HANDLER
	owner.remove_status_effect(/datum/status_effect/incapacitating/stun/goliath_tentacled)

/// Something happened to our associated tentacle
/datum/status_effect/incapacitating/stun/goliath_tentacled/proc/on_tentacle_left()
	SIGNAL_HANDLER
	UnregisterSignal(tentacle, list(COMSIG_QDELETING, COMSIG_GOLIATH_TENTACLE_RETRACTING)) // No endless loops for us please
	tentacle = null
	release()
