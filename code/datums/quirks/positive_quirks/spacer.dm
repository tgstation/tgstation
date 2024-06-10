#define LAST_STATE_PLANET "on_planet"
#define LAST_STATE_SPACE "in_space"

/datum/quirk/spacer_born
	name = "Spacer"
	desc = "You were born in space, and have never known the comfort of a planet's gravity. Your body has adapted to this. \
		You are more comfortable in zero and artifical gravity and are more resistant to the effects of space, \
		but travelling to a planet's surface for an extended period of time will make you feel sick."
	gain_text = span_notice("You feel at home in space.")
	lose_text = span_danger("You feel homesick.")
	icon = FA_ICON_USER_ASTRONAUT
	value = 7
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_CHANGES_APPEARANCE
	medical_record_text = "Patient is well-adapted to non-terrestrial environments."
	mail_goodies = list(
		/obj/item/storage/pill_bottle/ondansetron,
		/obj/item/reagent_containers/pill/gravitum,
	)
	/// How high spacers get bumped up to
	var/modded_height = HUMAN_HEIGHT_TALLER
	/// How long on a planet before we get averse effects
	var/planet_period = 3 MINUTES
	/// TimerID for time spend on a planet
	VAR_FINAL/planetside_timer
	/// How long in space before we get beneficial effects
	var/recover_period = 1 MINUTES
	/// TimerID for time spend in space
	VAR_FINAL/recovering_timer
	/// Determines the last state we were in ([LAST_STATE_PLANET] or [LAST_STATE_SPACE])
	VAR_FINAL/last_state

/datum/quirk/spacer_born/add(client/client_source)
	if(isdummy(quirk_holder))
		return

	// Using Z moved because we don't urgently need to check on every single turf movement for planetary status.
	// If you've arrived at a "planet", the entire Z is gonna be a "planet".
	// It won't really make sense to walk 3 feet and then suddenly gain / lose gravity sickness.
	// If I'm proven wrong, swap this to use Moved.
	RegisterSignal(quirk_holder, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(spacer_moved))

	// Yes, it's assumed for planetary maps that you start at gravity sickness.
	check_z(quirk_holder, skip_timers = TRUE)

	// drift slightly faster through zero G
	quirk_holder.inertia_move_delay *= 0.8

	var/mob/living/carbon/human/human_quirker = quirk_holder
	human_quirker.set_mob_height(modded_height)
	human_quirker.physiology.pressure_mod *= 0.8
	human_quirker.physiology.cold_mod *= 0.8

/datum/quirk/spacer_born/post_add()
	var/on_a_planet = SSmapping.is_planetary()
	var/planet_job = istype(quirk_holder.mind?.assigned_role, /datum/job/shaft_miner)
	if(!on_a_planet && !planet_job)
		return
	var/datum/bank_account/spacer_account = quirk_holder.get_bank_account()
	if(!isnull(spacer_account))
		spacer_account.payday_modifier *= 1.25
		to_chat(quirk_holder, span_info("Given your background as a Spacer, \
			you are awarded with a 25% hazard pay bonus due to your [on_a_planet ?  "station" : "occupational"] assignment."))

	// Supply them with some patches to help out on their new assignment
	var/obj/item/storage/pill_bottle/ondansetron/disgust_killers = new()
	disgust_killers.desc += " Best to take one when travelling to a planet's surface."
	if(quirk_holder.equip_to_slot_if_possible(disgust_killers, ITEM_SLOT_BACKPACK, qdel_on_fail = TRUE, initial = TRUE, indirect_action = TRUE))
		to_chat(quirk_holder, span_info("You have[isnull(spacer_account) ? " " : " also "]been given some anti-emetic patches to assist in adjusting to planetary gravity."))

/datum/quirk/spacer_born/remove()
	UnregisterSignal(quirk_holder, COMSIG_MOVABLE_Z_CHANGED)

	if(QDELING(quirk_holder))
		return

	quirk_holder.inertia_move_delay /= 0.8
	quirk_holder.clear_mood_event("spacer")
	quirk_holder.remove_movespeed_modifier(/datum/movespeed_modifier/spacer)
	quirk_holder.remove_status_effect(/datum/status_effect/spacer)

	var/mob/living/carbon/human/human_quirker = quirk_holder
	human_quirker.set_mob_height(HUMAN_HEIGHT_MEDIUM)
	human_quirker.physiology.pressure_mod /= 0.8
	human_quirker.physiology.cold_mod /= 0.8

/// Check on Z change whether we should start or stop timers
/datum/quirk/spacer_born/proc/spacer_moved(mob/living/source, turf/old_turf, turf/new_turf, same_z_layer)
	SIGNAL_HANDLER

	check_z(source)

/**
 * Used to check if we should start or stop timers based on the quirk holder's location.
 *
 * * afflicted - the mob arriving / same as quirk holder
 * * skip_timers - if TRUE, this is being done instantly / should not have feedback (such as in init)
 */
/datum/quirk/spacer_born/proc/check_z(mob/living/spacer, skip_timers = FALSE)
	if(is_on_a_planet(spacer))
		on_planet(spacer, skip_timers)
	else
		in_space(spacer, skip_timers)

// Going to a planet

/**
 * Ran when we arrive on a planet.
 *
 * * afflicted - the mob arriving / same as quirk holder
 * * skip_timers - if TRUE, this is being done instantly / should not have feedback (such as in init)
 */
/datum/quirk/spacer_born/proc/on_planet(mob/living/afflicted, skip_timers = FALSE)
	if(planetside_timer || last_state == LAST_STATE_PLANET)
		return
	if(recovering_timer)
		deltimer(recovering_timer)
		recovering_timer = null

	last_state = LAST_STATE_PLANET

	if(skip_timers)
		on_planet_for_too_long(afflicted, TRUE)
		return

	// Recently exercising lets us last longer under heavy strain
	var/exercise_bonus = afflicted.has_status_effect(/datum/status_effect/exercised) ? 2 : 1
	planetside_timer = addtimer(CALLBACK(src, PROC_REF(on_planet_for_too_long), afflicted), planet_period * exercise_bonus, TIMER_STOPPABLE)
	afflicted.add_mood_event("spacer", /datum/mood_event/spacer/on_planet)
	afflicted.add_movespeed_modifier(/datum/movespeed_modifier/spacer/on_planet)
	afflicted.remove_status_effect(/datum/status_effect/spacer) // removes the wellness effect.
	to_chat(afflicted, span_danger("You feel a bit sick under the gravity here."))

/**
 * Ran after remaining on a planet for too long.
 *
 * * afflicted - the mob arriving / same as quirk holder
 * * skip_timers - if TRUE, this is being done instantly / should not have feedback (such as in init)
 */
/datum/quirk/spacer_born/proc/on_planet_for_too_long(mob/living/afflicted, skip_timers = FALSE)
	if(QDELETED(src) || QDELETED(afflicted))
		return

	// Slightly reduced effects if we're on a planetary map to make it a bit more bearable
	var/nerfed_effects_because_planetary = SSmapping.is_planetary()
	var/moodlet_picked = nerfed_effects_because_planetary ? /datum/mood_event/spacer/on_planet/nerfed : /datum/mood_event/spacer/on_planet/too_long
	var/movespeed_mod_picked = nerfed_effects_because_planetary ? /datum/movespeed_modifier/spacer/on_planet/nerfed : /datum/movespeed_modifier/spacer/on_planet/too_long

	planetside_timer = null
	afflicted.apply_status_effect(/datum/status_effect/spacer/gravity_sickness)
	afflicted.add_mood_event("spacer", moodlet_picked)
	afflicted.add_movespeed_modifier(movespeed_mod_picked)

	if(!skip_timers)
		to_chat(afflicted, span_danger("You've been here for too long. The gravity really starts getting to you."))

// Going back into space

/**
 * Ran when returning to space / somewhere with low gravity.
 *
 * * afflicted - the mob arriving / same as quirk holder
 * * skip_timers - if TRUE, this is being done instantly / should not have feedback (such as in init)
 */
/datum/quirk/spacer_born/proc/in_space(mob/living/afflicted, skip_timers = FALSE)
	if(recovering_timer || last_state == LAST_STATE_SPACE)
		return
	if(planetside_timer)
		deltimer(planetside_timer)
		planetside_timer = null

	last_state = LAST_STATE_SPACE

	if(skip_timers)
		comfortably_in_space(afflicted, TRUE)
		return

	recovering_timer = addtimer(CALLBACK(src, PROC_REF(comfortably_in_space), afflicted), recover_period, TIMER_STOPPABLE)
	afflicted.remove_status_effect(/datum/status_effect/spacer)
	afflicted.clear_mood_event("spacer")
	// Does not remove the movement modifier yet, it lingers until you fully recover
	to_chat(afflicted, span_green("You start feeling better now that you're back in space."))

/**
 * Ran when living back in space for a long enough period.
 *
 * * afflicted - the mob arriving / same as quirk holder
 * * skip_timers - if TRUE, this is being done instantly / should not have feedback (such as in init)
 */
/datum/quirk/spacer_born/proc/comfortably_in_space(mob/living/afflicted, skip_timers = FALSE)
	if(QDELETED(src) || QDELETED(afflicted))
		return

	recovering_timer = null
	afflicted.apply_status_effect(/datum/status_effect/spacer/gravity_wellness)
	afflicted.add_mood_event("spacer", /datum/mood_event/spacer/in_space)
	afflicted.add_movespeed_modifier(/datum/movespeed_modifier/spacer/in_space)
	if(!skip_timers)
		to_chat(afflicted, span_green("You feel better."))

#undef LAST_STATE_PLANET
#undef LAST_STATE_SPACE
