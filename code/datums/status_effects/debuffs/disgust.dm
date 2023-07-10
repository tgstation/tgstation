/**
 * The disgust status effect.
 * Slowly decreases in disgust_value over time, causing effects based on that value.
 * Uses a lot of copypaste from the drunk status effect.
 */
/datum/status_effect/disgust
	id = "disgust"
	tick_interval = 2 SECONDS
	status_type = STATUS_EFFECT_UNIQUE
	remove_on_fullheal = TRUE
	/// The level of disgust we are currently at.
	var/disgust_value = 0

/datum/status_effect/disgust/on_creation(mob/living/new_owner, disgust_value = 0)
	. = ..()
	set_disgust_value(disgust_value)
	RegisterSignal(new_owner, COMSIG_LIVING_DEATH, PROC_REF(you_are_dead))

/datum/status_effect/disgust/on_apply()
	//doesn't make sense if you don't feel hunger
	if(HAS_TRAIT(owner, TRAIT_NOHUNGER))
		return FALSE
	//doesn't make sense if you are dead
	if(owner.stat >= DEAD)
		return FALSE
	//this is pointless for non-carbons, they can't puke
	if(!iscarbon(owner))
		return FALSE
	return TRUE

/datum/status_effect/disgust/on_remove()
	UnregisterSignal(owner, COMSIG_LIVING_DEATH)
	owner.clear_alert(ALERT_DISGUST)
	owner.clear_mood_event("disgust")

/datum/status_effect/disgust/get_examine_text()
	// Dead people don't look disgusted
	if(owner.stat == DEAD || HAS_TRAIT(owner, TRAIT_FAKEDEATH))
		return null

	switch(disgust_value)
		if(DISGUST_LEVEL_GROSS to DISGUST_LEVEL_VERYGROSS)
			return span_warning("[owner.p_they(TRUE)]  look[owner.p_s()] a bit grossed out.")
		if(DISGUST_LEVEL_VERYGROSS to DISGUST_LEVEL_DISGUSTED)
			return span_warning("[owner.p_they(TRUE)]  look[owner.p_s()] really grossed out.")
		if(DISGUST_LEVEL_DISGUSTED to INFINITY)
			return span_warning("[owner.p_they(TRUE)]  look[owner.p_s()] extremely disgusted.")

	return null

/// Sets the disgust value to set_to, deleting if the value drops to 0 or lower
/datum/status_effect/disgust/proc/set_disgust_value(set_to)
	if(!isnum(set_to))
		CRASH("[type] - invalid value passed to set_disgust_value. (Got: [set_to])")

	var/old_disgust = disgust_value
	disgust_value = set_to
	if(disgust_value <= 0)
		qdel(src)
		return

	if(old_disgust == disgust_value)
		return

	switch(disgust_value)
		if(0 to DISGUST_LEVEL_GROSS)
			owner.clear_alert(ALERT_DISGUST)
			owner.clear_mood_event("disgust")
		if(DISGUST_LEVEL_GROSS to DISGUST_LEVEL_VERYGROSS)
			owner.throw_alert(ALERT_DISGUST, /atom/movable/screen/alert/gross)
			owner.add_mood_event("disgust", /datum/mood_event/gross)
		if(DISGUST_LEVEL_VERYGROSS to DISGUST_LEVEL_DISGUSTED)
			owner.throw_alert(ALERT_DISGUST, /atom/movable/screen/alert/verygross)
			owner.add_mood_event("disgust", /datum/mood_event/verygross)
		if(DISGUST_LEVEL_DISGUSTED to INFINITY)
			owner.throw_alert(ALERT_DISGUST, /atom/movable/screen/alert/disgusted)
			owner.add_mood_event("disgust", /datum/mood_event/disgusted)

/datum/status_effect/disgust/tick(seconds_per_tick, times_fired)
	// Disgust value does not decrease while in stasis
	if(IS_IN_STASIS(owner))
		return

	var/mob/living/carbon/carbon_owner = owner
	if(disgust_value >= DISGUST_LEVEL_GROSS)
		if(SPT_PROB(5, seconds_per_tick))
			carbon_owner.adjust_stutter(2 SECONDS)
			carbon_owner.adjust_confusion(2 SECONDS)
		if(SPT_PROB(5, seconds_per_tick) && (carbon_owner.stat == CONSCIOUS))
			to_chat(carbon_owner, span_warning("You feel kind of iffy..."))
		carbon_owner.adjust_jitter(6 SECONDS)
	if(disgust_value >= DISGUST_LEVEL_VERYGROSS)
		var/pukeprob = 2.5 + (0.025 * disgust_value)
		if(SPT_PROB(pukeprob, seconds_per_tick))
			carbon_owner.adjust_confusion(2.5 SECONDS)
			carbon_owner.adjust_stutter(2 SECONDS)
			carbon_owner.vomit(10, distance = 0, vomit_type = NONE)
		carbon_owner.set_dizzy_if_lower(10 SECONDS)
	if(disgust_value >= DISGUST_LEVEL_DISGUSTED)
		if(SPT_PROB(13, seconds_per_tick))
			carbon_owner.set_eye_blur_if_lower(6 SECONDS)

	var/obj/item/organ/internal/stomach/stomach = carbon_owner.get_organ_slot(ORGAN_SLOT_STOMACH_AID)
	var/disgust_decrease = 0.25 * seconds_per_tick
	if(stomach && !(stomach.organ_flags & ORGAN_FAILING))
		disgust_decrease *= stomach.disgust_metabolism
	else
		disgust_decrease *= 0.5 //halved disgust decrease without a stomach, honestly very lenient
	set_disgust_value(disgust_value - disgust_decrease)

/// Disgust goes away once you die, personally I think this is stupid, but it's legacy behavior and we're keeping it
/datum/status_effect/disgust/proc/you_are_dead(mob/living/source, gibbed)
	SIGNAL_HANDLER

	qdel(src)
