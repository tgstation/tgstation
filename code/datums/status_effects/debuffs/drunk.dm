// Defines for the ballmer peak.
#define BALLMER_PEAK_LOW_END 12.9
#define BALLMER_PEAK_HIGH_END 13.8
#define BALLMER_PEAK_WINDOWS_ME 26

/// The threshld which determine if someone is tipsy vs drunk
#define TIPSY_THRESHOLD 6

/**
 * The drunk status effect.
 * Slowly decreases in drunk_value over time, causing effects based on that value.
 */
/datum/status_effect/inebriated
	id = "drunk"
	tick_interval = 2 SECONDS
	status_type = STATUS_EFFECT_REPLACE
	remove_on_fullheal = TRUE
	alert_type = null
	/// The level of drunkness we are currently at.
	var/drunk_value = 0
	/// If TRUE, drunk_value will be capped at 51, preventing serious damage 
	var/iron_liver = FALSE 

/datum/status_effect/inebriated/on_creation(mob/living/new_owner, drunk_value = 0)
	. = ..()
	set_drunk_value(drunk_value)

/datum/status_effect/inebriated/get_examine_text()
	// Dead people don't look drunk
	if(owner.stat == DEAD || HAS_TRAIT(owner, TRAIT_FAKEDEATH))
		return null

	// Having your face covered conceals your drunkness
	if(iscarbon(owner))
		var/mob/living/carbon/carbon_owner = owner
		if(carbon_owner.obscured_slots & HIDEFACE)
			return null

	// .01s are used in case the drunk value ends up to be a small decimal.
	switch(drunk_value)
		if(11 to 21)
			return span_warning("[owner.p_They()] [owner.p_are()] slightly flushed.")
		if(21.01 to 41)
			return span_warning("[owner.p_They()] [owner.p_are()] flushed.")
		if(41.01 to 51)
			return span_warning("[owner.p_They()] [owner.p_are()] quite flushed and [owner.p_their()] breath smells of alcohol.")
		if(51.01 to 61)
			return span_warning("[owner.p_They()] [owner.p_are()] very flushed and [owner.p_their()] movements jerky, with breath reeking of alcohol.")
		if(61.01 to 91)
			return span_warning("[owner.p_They()] look[owner.p_s()] like a drunken mess.")
		if(91.01 to INFINITY)
			return span_warning("[owner.p_They()] [owner.p_are()] a shitfaced, slobbering wreck.")

	return null

/// Sets the drunk value to set_to, deleting if the value drops to 0 or lower
/datum/status_effect/inebriated/proc/set_drunk_value(set_to)
	if(!isnum(set_to))
		CRASH("[type] - invalid value passed to set_drunk_value. (Got: [set_to])")
	if(iron_liver)
		set_to = min(51, set_to)
	drunk_value = set_to
	if(drunk_value <= 0)
		qdel(src)

/datum/status_effect/inebriated/tick(seconds_between_ticks)
	// Drunk value does not decrease while dead or in stasis
	if(owner.stat == DEAD || HAS_TRAIT(owner, TRAIT_STASIS))
		return

	// Every tick, the drunk value decrases by
	// 4% the current drunk_value + 0.01
	// (until it reaches 0 and terminates)
	set_drunk_value(drunk_value - (0.01 + drunk_value * 0.04))
	if(QDELETED(src))
		return

	on_tick_effects()

/// Side effects done by this level of drunkness on tick.
/datum/status_effect/inebriated/proc/on_tick_effects()
	return

/**
 * Stage 1 of drunk, applied at drunk values between 0 and 6.
 * Basically is the "drunk but no side effects" stage.
 */
/datum/status_effect/inebriated/tipsy
	alert_type = null

/datum/status_effect/inebriated/tipsy/set_drunk_value(set_to)
	. = ..()
	if(QDELETED(src))
		return

	// Become fully drunk at over than 6 drunk value
	if(drunk_value >= TIPSY_THRESHOLD)
		owner.apply_status_effect(/datum/status_effect/inebriated/drunk, drunk_value)

/**
 * Stage 2 of being drunk, applied at drunk values between 6 and onward.
 * Has all the main side effects of being drunk, scaling up as they get more drunk.
 */
/datum/status_effect/inebriated/drunk
	alert_type = /atom/movable/screen/alert/status_effect/drunk

/datum/status_effect/inebriated/drunk/on_apply()
	. = ..()
	owner.sound_environment_override = SOUND_ENVIRONMENT_PSYCHOTIC
	owner.add_mood_event(id, /datum/mood_event/drunk, drunk_value)
	owner.clear_mood_event("[id]_after")
	RegisterSignal(owner, COMSIG_MOB_FIRED_GUN, PROC_REF(drunk_gun_fired))

/datum/status_effect/inebriated/drunk/on_remove()
	clear_effects()
	return ..()

// Going from "drunk" to "tipsy" should remove effects like on_remove
/datum/status_effect/inebriated/drunk/be_replaced()
	clear_effects()
	return ..()

/// Clears any side effects we set due to being drunk.
/datum/status_effect/inebriated/drunk/proc/clear_effects()
	owner.clear_mood_event(id)
	if(!QDELING(owner) && HAS_PERSONALITY(owner, /datum/personality/bibulous))
		owner.add_mood_event("[id]_after", /datum/mood_event/drunk_after)

	if(owner.sound_environment_override == SOUND_ENVIRONMENT_PSYCHOTIC)
		owner.sound_environment_override = SOUND_ENVIRONMENT_NONE

	UnregisterSignal(owner, COMSIG_MOB_FIRED_GUN)
	REMOVE_TRAIT(owner, TRAIT_FEARLESS, TRAIT_STATUS_EFFECT(id))

/datum/status_effect/inebriated/drunk/proc/drunk_gun_fired(datum/source, obj/item/gun/gun, atom/firing_at, params, zone, bonus_spread_values)
	SIGNAL_HANDLER

	// excusing the bartender, because shotgun
	if(HAS_TRAIT(owner, TRAIT_DRUNKEN_BRAWLER))
		return
	// what makes me a good demoman?
	if(istype(gun, /obj/item/gun/grenadelauncher) || istype(gun, /obj/item/gun/ballistic/revolver/grenadelauncher))
		return
	bonus_spread_values[MAX_BONUS_SPREAD_INDEX] += (drunk_value * 0.5)

/datum/status_effect/inebriated/drunk/set_drunk_value(set_to)
	. = ..()
	if(QDELETED(src))
		return
	// Return to "tipsyness" when we're below 6.
	if(drunk_value < TIPSY_THRESHOLD)
		owner.apply_status_effect(/datum/status_effect/inebriated/tipsy, drunk_value)
		return

	var/datum/mood_event/drunk/moodlet = owner.mob_mood.mood_events[id]
	if(istype(moodlet))
		moodlet.update_change(drunk_value)

/datum/status_effect/inebriated/drunk/on_tick_effects()
	// Handle the Ballmer Peak.
	// If our owner is a scientist (has the trait "TRAIT_BALLMER_SCIENTIST"), there's a 5% chance
	// that they'll say one of the special "ballmer message" lines, depending their drunk-ness level.
	var/obj/item/organ/liver/liver_organ = owner.get_organ_slot(ORGAN_SLOT_LIVER)
	if(liver_organ && HAS_TRAIT(liver_organ, TRAIT_BALLMER_SCIENTIST) && prob(5))
		if(drunk_value >= BALLMER_PEAK_LOW_END && drunk_value <= BALLMER_PEAK_HIGH_END)
			owner.say(pick_list_replacements(VISTA_FILE, "ballmer_good_msg"), forced = "ballmer")

		if(drunk_value > BALLMER_PEAK_WINDOWS_ME) // by this point you're into windows ME territory
			owner.say(pick_list_replacements(VISTA_FILE, "ballmer_windows_me_msg"), forced = "ballmer")

	// Drunk slurring scales in intensity based on how drunk we are -at 16 you will likely not even notice it,
	// but when we start to scale up you definitely will
	if(drunk_value >= 16)
		owner.adjust_timed_status_effect(4 SECONDS, /datum/status_effect/speech/slurring/drunk, max_duration = 20 SECONDS)

	// And drunk people will always lose jitteriness
	owner.adjust_jitter(-6 SECONDS)

	// Over 41, we have a 30% chance to gain confusion, and we will always have 20 seconds of dizziness.
	if(drunk_value >= 41)
		if(prob(30))
			owner.adjust_confusion(2 SECONDS)

		owner.set_dizzy_if_lower(20 SECONDS)

	// Over 51, we have a 3% chance to gain a lot of confusion and vomit, and we will always have 50 seconds of dizziness
	if(drunk_value >= 51)
		owner.set_dizzy_if_lower(50 SECONDS)
		if(prob(3))
			owner.adjust_confusion(15 SECONDS)
			if(iscarbon(owner))
				var/mob/living/carbon/carbon_owner = owner
				carbon_owner.vomit(VOMIT_CATEGORY_DEFAULT) // Vomiting clears toxloss - consider this a blessing
		ADD_TRAIT(owner, TRAIT_FEARLESS, TRAIT_STATUS_EFFECT(id))
	else
		REMOVE_TRAIT(owner, TRAIT_FEARLESS, TRAIT_STATUS_EFFECT(id))

	// Over 71, we will constantly have blurry eyes
	if(drunk_value >= 71)
		owner.set_eye_blur_if_lower((drunk_value * 2 SECONDS) - 140 SECONDS)

	// Over 81, we will gain constant toxloss
	if(drunk_value >= 81)
		owner.adjustToxLoss(1)
		if(owner.stat == CONSCIOUS && prob(5))
			to_chat(owner, span_warning("Maybe you should lie down for a bit..."))

	// Over 91, we gain even more toxloss, brain damage, and have a chance of dropping into a long sleep
	if(drunk_value >= 91)
		owner.adjustToxLoss(1)
		owner.adjustOrganLoss(ORGAN_SLOT_BRAIN, 0.4)
		if(owner.stat == CONSCIOUS)
			attempt_to_blackout()

	// And finally, over 100 - let's be honest, you shouldn't be alive by now.
	if(drunk_value >= 101)
		owner.adjustToxLoss(2)

/datum/status_effect/inebriated/drunk/proc/attempt_to_blackout()
	var/mob/living/carbon/drunkard = owner
	if(drunkard.has_trauma_type(/datum/brain_trauma/severe/split_personality/blackout))// prevent ping spamming
		if(prob(10))
			to_chat(owner, span_warning("You stumbled and fall over!"))
			owner.slip(1 SECONDS)
		return
	if(drunkard.gain_trauma(/datum/brain_trauma/severe/split_personality/blackout, TRAUMA_LIMIT_ABSOLUTE))
		drunk_value -= 70 //So that the drunk personality can spice things up without being killed by liver failure
		return
	if(SSshuttle.emergency.mode == SHUTTLE_DOCKED && is_station_level(owner.z))// Don't put us in a deep sleep if the shuttle's here. QoL, mainly.
		to_chat(owner, span_warning("You're so tired... but you can't miss that shuttle..."))
	else
		owner.Sleeping(90 SECONDS)

/// Status effect for being fully drunk (not tipsy).
/atom/movable/screen/alert/status_effect/drunk
	name = "Drunk"
	desc = "All that alcohol you've been drinking is impairing your speech, \
		motor skills, and mental cognition. Make sure to act like it."
	icon_state = "drunk"

#undef BALLMER_PEAK_LOW_END
#undef BALLMER_PEAK_HIGH_END
#undef BALLMER_PEAK_WINDOWS_ME

#undef TIPSY_THRESHOLD
