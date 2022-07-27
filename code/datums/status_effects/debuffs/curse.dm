#define SEVERE_THRESHOLD 6

/**
 * The cursed status effect.
 * Increasingly worse effects are added as the heart is not pumped.
 * See drunk.dm for reference.
 */
/datum/status_effect/cursed
	id = "cursed"
	tick_interval = 2 SECONDS
	status_type = STATUS_EFFECT_REPLACE
	var/curse_value = 0

/datum/status_effect/cursed/on_creation(mob/living/new_owner, curse_value = 0)
	. = ..()
	set_curse_value(curse_value)

/datum/status_effect/cursed/on_apply()
	RegisterSignal(owner, COMSIG_LIVING_POST_FULLY_HEAL, .proc/clear_curse)
	return TRUE

/datum/status_effect/cursed/on_remove()
	UnregisterSignal(owner, COMSIG_LIVING_POST_FULLY_HEAL)

/datum/status_effect/cursed/get_examine_text()
	// Dead people don't seem cursed
	if(owner.stat == DEAD || HAS_TRAIT(owner, TRAIT_FAKEDEATH))
		return null

	switch(curse_value)
		if(11 to 21)
			return span_warning("[owner.p_they(TRUE)] [owner.p_are()] slightly pale.")
		if(21.01 to 41)
			return span_warning("[owner.p_they(TRUE)] [owner.p_are()] flushed, [owner.p_their()] eyes are glassy and vacant.")
		if(41.01 to 61)
			return span_warning("[owner.p_they(TRUE)][owner.p_s()] heart is practically beating out of [owner.p_their()] chest!")
		if(61.01 to 91)
			return span_warning("[owner.p_they(TRUE)] look[owner.p_s()] sick to [owner.p_their()] stomach with a black ooze running down their chin.")
		if(91.01 to INFINITY)
			return span_warning("[owner.p_they(TRUE)] [owner.p_are()] at the mercy of their curse.")

	return null

/// Removes all of our curse (self-deletes) on signal.
/datum/status_effect/cursed/proc/clear_curse(mob/living/source)
	SIGNAL_HANDLER

	qdel(src)

/// Sets the curse value to set_to, deleting if the value drops to 0 or lower
/datum/status_effect/cursed/proc/set_curse_value(set_to)
	if(!isnum(set_to))
		CRASH("[type] - invalid value passed to set_curse_value. (Got: [set_to])")

	curse_value = set_to
	if(curse_value <= 0)
		qdel(src)

/datum/status_effect/cursed/tick()
	// curse value does not decrease while dead
	if(owner.stat == DEAD)
		return

	// Every tick, the curse value decrases by
	// 4% the current curse_value + 0.01
	// (until it reaches 0 and terminates)
	set_curse_value(curse_value - (0.01 + curse_value * 0.04))
	if(QDELETED(src))
		return

	on_tick_effects()

/// Side effects done by this level of curse on tick.
/datum/status_effect/cursed/proc/on_tick_effects()
	return

/**
 * Stage 1 of cursed, applied at curse values between 0 and 6.
 * Basically is the "curse but no side effects" stage.
 */
/datum/status_effect/cursed/nauseous
	alert_type = null

/datum/status_effect/cursed/nauseous/set_curse_value(set_to)
	. = ..()
	if(QDELETED(src))
		return

	// Become fully cursed at over than 6 curse value
	if(curse_value >= SEVERE_THRESHOLD)
		owner.apply_status_effect(/datum/status_effect/cursed/severe, curse_value)

/**
 * Stage 2 of being curse, applied at curse values between 6 and onward.
 * Has all the main side effects of being curse, scaling up as they get more curse.
 */
/datum/status_effect/cursed/severe
	alert_type = /atom/movable/screen/alert/status_effect/cursed

/datum/status_effect/cursed/severe/on_apply()
	. = ..()
	owner.sound_environment_override = SOUND_ENVIRONMENT_PSYCHOTIC

/datum/status_effect/cursed/severe/on_remove()
	clear_effects()
	return ..()

// Going from "cursed" to "nauseous" should remove effects like on_remove
/datum/status_effect/cursed/severe/be_replaced()
	clear_effects()
	return ..()

/// Clears any side effects we set due to being cursed.
/datum/status_effect/cursed/severe/proc/clear_effects()
	SEND_SIGNAL(owner, COMSIG_CLEAR_MOOD_EVENT, id)

	if(owner.sound_environment_override == SOUND_ENVIRONMENT_PSYCHOTIC)
		owner.sound_environment_override = SOUND_ENVIRONMENT_NONE

/datum/status_effect/cursed/severe/set_curse_value(set_to)
	. = ..()
	if(QDELETED(src))
		return

	// Return to "tipsyness" when we're below 6.
	if(curse_value < SEVERE_THRESHOLD)
		owner.apply_status_effect(/datum/status_effect/cursed/nauseous, curse_value)

/datum/status_effect/cursed/severe/on_tick_effects()
	// There's always a 30% chance to jitter.
	if(prob(30))
		owner.adjust_timed_status_effect(3 SECONDS, /datum/status_effect/jitter)

	// Over 11, we will constantly gain slurring up to 10 seconds of slurring.
	if(curse_value >= 11)
		to_chat(owner, span_warning("You feel as if your heart it gnawing on itself!"))

	// Over 31, we have a 30% chance to gain confusion, and we will always have 20 seconds of dizziness.
	if(curse_value >= 31)
		if(prob(30))
			owner.adjust_timed_status_effect(2 SECONDS, /datum/status_effect/confusion)

		owner.set_timed_status_effect(20 SECONDS, /datum/status_effect/dizziness, only_if_higher = TRUE)

	// Over 51, we have a 3% chance to gain a lot of confusion and vomit, and we will always have 50 seconds of dizziness
	if(curse_value >= 51)
		owner.set_timed_status_effect(50 SECONDS, /datum/status_effect/dizziness, only_if_higher = TRUE)
		if(prob(4))
			owner.adjust_timed_status_effect(15 SECONDS, /datum/status_effect/confusion)
			if(iscarbon(owner))
				var/mob/living/carbon/carbon_owner = owner
				var/obj/item/organ/internal/heart/new_heart = carbon_owner
				// 20% chance the vomit will expell the curse.
				if(prob(20))
					carbon_owner.vomit(blood = TRUE, vomit_type = VOMIT_PURPLE)
					new_heart.Insert(carbon_owner, special = 0, drop_if_replaced = FALSE)
				else
					carbon_owner.vomit(blood = TRUE) // Vomiting clears toxloss - consider this a blessing

	// Over 71, we will constantly have blurry eyes
	if(curse_value >= 71)
		owner.blur_eyes(curse_value - 70)

	// Over 81, we will gain constant bloodloss
	if(curse_value >= 81)
		owner.blood_volume = max(owner.blood_volume - 5, 0)
		if(owner.stat == CONSCIOUS && prob(5))
			to_chat(owner, span_userdanger("You feel a strong stinging sensation in your chest!"))

	// Over 91, we gain even more toxloss, brain damage, and have a chance of dropping into a long sleep
	if(curse_value >= 91)
		owner.blood_volume = max(owner.blood_volume - 7, 0)
		owner.adjustOrganLoss(ORGAN_SLOT_BRAIN, 0.4)
		if(owner.stat == CONSCIOUS && prob(20))
				to_chat(owner, span_userdanger("You collapse as a black ooze glazes your eyes shut!"))
				owner.Sleeping(90 SECONDS)

	// And finally, over 100 - let's be honest, you shouldn't be alive by now.
	if(curse_value >= 101)
		owner.blood_volume = max(owner.blood_volume - 15, 0)

/// Status effect for having a severe curse.
/atom/movable/screen/alert/status_effect/cursed
	name = "Cursed"
	desc = "You feel a cool wave over your body as you forget the last time \
		your heart has beat. You should beat it before the curse worsens."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "cursedheart"


#undef SEVERE_THRESHOLD
