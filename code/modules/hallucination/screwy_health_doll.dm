///Causes the target to see incorrect health damages on the healthdoll
/datum/hallucination/fake_health_doll
	random_hallucination_weight = 12

	/// The duration of the hallucination
	var/duration
	/// Assoc list of [ref to bodyparts] to [severity]
	var/list/bodyparts = list()
	/// Timer ID for when we're deleted
	var/del_timer_id

/datum/hallucination/fake_health_doll/New(mob/living/hallucinator, duration = 50 SECONDS)
	src.duration = duration
	return ..()

// So that the associated addition proc cleans it up correctly
/datum/hallucination/fake_health_doll/Destroy()
	if(del_timer_id)
		deltimer(del_timer_id)

	for(var/obj/item/bodypart/limb as anything in bodyparts)
		remove_bodypart(limb)

	hallucinator.update_health_hud()
	return ..()

/datum/hallucination/fake_health_doll/start()
	if(!ishuman(hallucinator))
		return FALSE

	add_fake_limb()
	del_timer_id = QDEL_IN(src, duration)
	return TRUE

/// Increments the severity of the damage seen on all the limbs we are already tracking.
/datum/hallucination/fake_health_doll/proc/increment_fake_damage()

	for(var/obj/item/bodypart/limb as anything in bodyparts)
		bodyparts[limb] = clamp(bodyparts[limb] + 1, 1, 5)

	hallucinator.update_health_hud()

/**
 * Adds a fake limb to the effect.
 *
 * specific_limb - optional, the specific limb to apply the effect to. If not passed, picks a random limb
 * seveirty - optional, the specific severity level to apply the effect. Clamped from 1 to 5. If not passed, picks a random number.
 */
/datum/hallucination/fake_health_doll/proc/add_fake_limb(obj/item/bodypart/specific_limb, severity)
	var/mob/living/carbon/human/human_mob = hallucinator

	var/obj/item/bodypart/picked = specific_limb || pick(human_mob.bodyparts)
	if(!(picked in bodyparts))
		RegisterSignals(picked, list(COMSIG_PARENT_QDELETING, COMSIG_BODYPART_REMOVED), PROC_REF(remove_bodypart))
		RegisterSignal(picked, COMSIG_BODYPART_UPDATING_HEALTH_HUD, PROC_REF(on_bodypart_hud_update))
		RegisterSignal(picked, COMSIG_BODYPART_CHECKED_FOR_INJURY, PROC_REF(on_bodypart_checked))

	bodyparts[picked] = clamp(severity || rand(1, 5), 1, 5)
	hallucinator.update_health_hud()

/// Remove a bodypart from our list, unregistering all associated signals and handling the reference
/datum/hallucination/fake_health_doll/proc/remove_bodypart(obj/item/bodypart/source)
	SIGNAL_HANDLER

	UnregisterSignal(source, list(COMSIG_PARENT_QDELETING, COMSIG_BODYPART_REMOVED, COMSIG_BODYPART_UPDATING_HEALTH_HUD, COMSIG_BODYPART_CHECKED_FOR_INJURY))
	bodyparts -= source

/// Whenever a bodypart we're tracking has their health hud updated, override it with our fake overlay
/datum/hallucination/fake_health_doll/proc/on_bodypart_hud_update(obj/item/bodypart/source, mob/living/carbon/human/owner)
	SIGNAL_HANDLER

	var/mutable_appearance/fake_overlay = mutable_appearance('icons/hud/screen_gen.dmi', "[source.body_zone][bodyparts[source]]")
	owner.hud_used.healthdoll.add_overlay(fake_overlay)
	return COMPONENT_OVERRIDE_BODYPART_HEALTH_HUD

/// Signal proc for [COMSIG_BODYPART_CHECKED_FOR_INJURY]. Our bodyparts look a lot more wounded than they actually are.
/datum/hallucination/fake_health_doll/proc/on_bodypart_checked(obj/item/bodypart/source, mob/living/carbon/examiner, list/check_list, list/limb_damage)
	SIGNAL_HANDLER

	limb_damage[BRUTE] = bodyparts[source] * 0.2 * source.max_damage
