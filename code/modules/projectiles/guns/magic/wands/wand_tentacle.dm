#define RETRACT_TIME (0.7 SECONDS)

/**
 * Immobilises people with tentacles. It's not a fetish.
 */
/obj/item/gun/magic/wand/tentacles
	name = "restraining rod"
	desc = "This wriggling wand binds its victims in a place for a time, although it doesn't stop them from shooting back."
	school = SCHOOL_CONJURATION
	ammo_type = /obj/item/ammo_casing/magic/tentacle
	icon_state = "tentawand"
	base_icon_state = "tentawand"
	fire_sound = 'sound/effects/splat.ogg'
	max_charges = 10

/obj/item/gun/magic/wand/tentacles/zap_self(mob/living/user, suicide)
	. = ..()
	var/tentacle_type = suicide ? /obj/effect/wizard_tentacle/suicide : /obj/effect/wizard_tentacle
	var/turf/target_turf = get_turf(user)
	if (!(locate(/obj/effect/wizard_tentacle) in target_turf))
		new tentacle_type(target_turf, user)

/obj/item/gun/magic/wand/tentacles/do_suicide(mob/living/user)
	. = ..()
	return user.has_status_effect(/datum/status_effect/incapacitating/immobilized/wizard_tentacle/suicide) ? MANUAL_SUICIDE : SHAME

/obj/item/ammo_casing/magic/tentacle
	projectile_type = /obj/projectile/magic/tentacle

/// Grabs the target for a while in an unwanted hug
/obj/projectile/magic/tentacle
	name = "bolt of binding"
	icon_state = "tentacle_end"

/obj/projectile/magic/tentacle/on_hit(mob/living/target, blocked = 0, pierce_hit)
	. = ..()
	if (. == BULLET_ACT_BLOCK || !istype(target) || blocked >= 100)
		return
	var/turf/target_turf = get_turf(target)
	if (!(locate(/obj/effect/wizard_tentacle) in target_turf))
		new /obj/effect/wizard_tentacle(get_turf(target), target)

/// Different enough from the goliath tentacle to just be its own subtype
/obj/effect/wizard_tentacle
	name = "tentacle"
	icon = 'icons/mob/simple/lavaland/lavaland_monsters.dmi'
	icon_state = "goliath_tentacle_wiggle"
	layer = BELOW_MOB_LAYER
	plane = GAME_PLANE
	anchored = TRUE
	/// How long do we get grabbed?
	var/grab_time = 20 SECONDS
	/// Status effect we apply to victims
	var/status_applied = /datum/status_effect/incapacitating/immobilized/wizard_tentacle

/obj/effect/wizard_tentacle/Initialize(mapload, mob/living/victim)
	. = ..()
	if (isgroundlessturf(loc) || isnull(victim))
		return INITIALIZE_HINT_QDEL
	flick("goliath_tentacle_spawn", src)

	if (victim.stat != DEAD && !HAS_TRAIT(victim, TRAIT_TENTACLE_IMMUNE))
		balloon_alert(victim, "grabbed")
		visible_message(span_danger("[src] grabs hold of [victim]!"))
		victim.apply_damage(15, BRUTE)
		if (victim.apply_status_effect(status_applied, grab_time, src))
			buckle_mob(victim, TRUE)

	if (has_buckled_mobs())
		addtimer(CALLBACK(src, PROC_REF(retract)), grab_time, TIMER_DELETE_ME)
	else
		retract()

/obj/effect/wizard_tentacle/user_unbuckle_mob(mob/living/buckled_mob, mob/user)
	if (buckled_mob == user)
		balloon_alert(user, "can't reach!")
		return
	return ..()

/// We're done now
/obj/effect/wizard_tentacle/proc/retract()
	if (icon_state == "goliath_tentacle_retract")
		return // Already retracting
	icon_state = "goliath_tentacle_retract"
	unbuckle_all_mobs(force = TRUE)
	QDEL_IN(src, RETRACT_TIME)

/// This one kills you
/obj/effect/wizard_tentacle/suicide
	grab_time = 3 SECONDS // Something worse is going to happen
	status_applied = /datum/status_effect/incapacitating/immobilized/wizard_tentacle/suicide

/// Subtype of immobilise which is linked to a tentacle
/datum/status_effect/incapacitating/immobilized/wizard_tentacle
	id = "tentacle_immobilized"
	/// The tentacle that is tenderly holding us close
	var/obj/effect/wizard_tentacle/tentacle
	/// Can someone else help us out?
	var/removable = TRUE

/datum/status_effect/incapacitating/immobilized/wizard_tentacle/on_creation(mob/living/new_owner, set_duration, obj/effect/wizard_tentacle/tentacle)
	. = ..()
	if (!.)
		return
	src.tentacle = tentacle

/datum/status_effect/incapacitating/immobilized/wizard_tentacle/on_apply()
	. = ..()
	if (removable)
		RegisterSignal(owner, COMSIG_CARBON_PRE_MISC_HELP, PROC_REF(on_helped))
	RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_TENTACLE_IMMUNE), PROC_REF(release))
	RegisterSignal(tentacle, COMSIG_QDELETING, PROC_REF(on_tentacle_left))

/datum/status_effect/incapacitating/immobilized/wizard_tentacle/on_remove()
	. = ..()
	UnregisterSignal(owner, list(COMSIG_CARBON_PRE_MISC_HELP, SIGNAL_ADDTRAIT(TRAIT_TENTACLE_IMMUNE)))
	if (isnull(tentacle))
		return
	UnregisterSignal(tentacle, COMSIG_QDELETING)
	tentacle.retract()
	tentacle = null

/// Some kind soul has rescued us
/datum/status_effect/incapacitating/immobilized/wizard_tentacle/proc/on_helped(mob/source, mob/helping)
	SIGNAL_HANDLER
	if (helping == owner)
		owner.balloon_alert(owner, "can't reach!")
		return
	source.visible_message(span_notice("[helping] rips [source] from the tentacle's grasp!"))
	release()
	return COMPONENT_BLOCK_MISC_HELP

/// Something happened to make the tentacle let go
/datum/status_effect/incapacitating/immobilized/wizard_tentacle/proc/release()
	SIGNAL_HANDLER
	owner.remove_status_effect(/datum/status_effect/incapacitating/immobilized/wizard_tentacle)

/// Something happened to our associated tentacle
/datum/status_effect/incapacitating/immobilized/wizard_tentacle/proc/on_tentacle_left()
	SIGNAL_HANDLER
	UnregisterSignal(tentacle, COMSIG_QDELETING)
	tentacle = null
	release()

/// This one kills you
/datum/status_effect/incapacitating/immobilized/wizard_tentacle/suicide
	removable = FALSE

/datum/status_effect/incapacitating/immobilized/wizard_tentacle/suicide/on_apply()
	. = ..()
	owner.Stun(6 SECONDS, ignore_canstun = TRUE)

/datum/status_effect/incapacitating/immobilized/wizard_tentacle/suicide/on_remove()
	var/had_tentacle = !!tentacle
	. = ..()
	if (!owner || !had_tentacle)
		return
	owner.visible_message(span_suicide("The tentacle drags [owner] directly to hell!"))
	owner.unequip_everything()
	animate(owner, transform = matrix() * 0, time = RETRACT_TIME)
	animate(owner, pixel_y = -12, time = RETRACT_TIME, flags = ANIMATION_PARALLEL)
	addtimer(CALLBACK(owner, TYPE_PROC_REF(/mob, ghostize)), RETRACT_TIME - 1)
	QDEL_IN(owner, RETRACT_TIME)

#undef RETRACT_TIME
