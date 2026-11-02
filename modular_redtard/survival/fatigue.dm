// Ratwood's night fatigue (code/controllers/subsystem/nightshift.dm advance_sleep_depravation(), remove_sleep_depravation();
// datums/status_effects/rogue/debuff.dm sleepytime; datums/stress/negative_events.dm sleepytime): every nightfall leaves one who
// has not slept a step more tired, up to three - Tired, Fatigued, Exhausted. The steps are counted by the dream bank of
// crafting/experience.dm (/datum/component/rogue_dreams tiredness), whose dreams take them away one by one; here every step shows
// as its status with Ratwood's stress as a mood event, the third slows the feet, and onlookers see it on examine. A night owl
// tires by day instead and is not troubled by it; one with fatal insomnia never tires. Tiredness makes one fall asleep sooner and
// the exhausted sleep even in armour (survival/sleep.dm). Coffee and tea (survival/soups.dm caffeine) give the Vigorized buff and
// lift the fatigue.

/// The status icons of the steps (Ratwood icons/mob/screen_alert.dmi: sleepy, sleepy2, sleepy3).
#define FATIGUE_ICON 'modular_redtard/survival/icons/fatigue.dmi'
/// The most steps of fatigue (Ratwood sleepytime/t3).
#define FATIGUE_MAX 3
/// The mood category the steps share: the stress of a new step replaces the last one's.
#define FATIGUE_MOOD "rogue_fatigue"
#define FATIGUE_OWL_MOOD "rogue_night_owl"
// Numbers of config/redtard/mechanics/values/survival.txt.
#define FATIGUE_SLOWDOWN rogue_value("survival_exhausted_slowdown")
#define COFFEE_LIFTS_FATIGUED rogue_value("survival_coffee_fatigued")
#define COFFEE_LIFTS_EXHAUSTED rogue_value("survival_coffee_exhausted")
#define COFFEE_POINTS_TIRED rogue_value("survival_coffee_points_tired")
#define COFFEE_POINTS_FATIGUED rogue_value("survival_coffee_points_fatigued")
#define COFFEE_POINTS_EXHAUSTED rogue_value("survival_coffee_points_exhausted")

/// The status of each step of fatigue, first to third.
GLOBAL_LIST_INIT(rogue_fatigue_stages, list(
	/datum/status_effect/rogue_fatigue,
	/datum/status_effect/rogue_fatigue/fatigued,
	/datum/status_effect/rogue_fatigue/exhausted,
))

/// Ratwood sleepytime, t2 and t3: one status for every step, each replacing the last (they share an id), with the step's stress
/// as a mood event (none for a night owl) and, on the third step, Ratwood's movement slowdown. A replaced status is not removed
/// (TG be_replaced()), so every step sets the mood and the slowdown for itself.
/datum/status_effect/rogue_fatigue
	id = "rogue_fatigue"
	status_type = STATUS_EFFECT_REPLACE
	duration = STATUS_EFFECT_PERMANENT
	tick_interval = STATUS_EFFECT_NO_TICK
	alert_type = /atom/movable/screen/alert/status_effect/rogue_fatigue
	/// The step of fatigue, 1-3 (Ratwood's tier).
	var/stage = 1
	/// Ratwood's stress of the step.
	var/mood = /datum/mood_event/rogue_fatigue
	/// How tired onlookers see one look (Ratwood human examine()).
	var/look = "a little tired"
	/// The step slows the feet (Ratwood SLEEP_TIER3).
	var/slows = FALSE

/datum/status_effect/rogue_fatigue/on_apply()
	if(HAS_TRAIT(owner, TRAIT_NIGHT_OWL))
		owner.clear_mood_event(FATIGUE_MOOD)
	else
		owner.add_mood_event(FATIGUE_MOOD, mood)
	if(slows)
		owner.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/rogue_exhausted, multiplicative_slowdown = FATIGUE_SLOWDOWN)
	else
		owner.remove_movespeed_modifier(/datum/movespeed_modifier/rogue_exhausted)
	return TRUE

/datum/status_effect/rogue_fatigue/on_remove()
	owner.clear_mood_event(FATIGUE_MOOD)
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/rogue_exhausted)
	return ..()

/// Ratwood examine(): awake with the eyes open, one looks as tired as one is.
/datum/status_effect/rogue_fatigue/get_examine_text(mob/examiner)
	if(owner.stat != STABLE || owner.IsSleeping() || owner.rogue_eyes_closed)
		return null
	return span_notice("[owner.p_They()] [owner.p_are()] looking [look].")

/datum/status_effect/rogue_fatigue/fatigued
	stage = 2
	alert_type = /atom/movable/screen/alert/status_effect/rogue_fatigue/fatigued
	mood = /datum/mood_event/rogue_fatigue/fatigued
	look = "pretty tired"

/datum/status_effect/rogue_fatigue/exhausted
	stage = 3
	alert_type = /atom/movable/screen/alert/status_effect/rogue_fatigue/exhausted
	mood = /datum/mood_event/rogue_fatigue/exhausted
	look = "ridiculously tired"
	slows = TRUE

/atom/movable/screen/alert/status_effect/rogue_fatigue
	name = "Tired"
	desc = "I should get some rest."
	icon = FATIGUE_ICON
	icon_state = "sleepy"

/atom/movable/screen/alert/status_effect/rogue_fatigue/fatigued
	name = "Fatigued"
	desc = "When was the last time I even slept...?"
	icon_state = "sleepy2"

/atom/movable/screen/alert/status_effect/rogue_fatigue/exhausted
	name = "Exhausted"
	desc = "Just... one little quick nap... five minute rest... please..."
	icon_state = "sleepy3"

/// Ratwood SLEEP_TIER3 (multiplicative_slowdown 1.25); the number is survival_exhausted_slowdown.
/datum/movespeed_modifier/rogue_exhausted
	variable = TRUE

// Ratwood stress events of fatigue (40 minutes each) and the night owl's peace (20 minutes).

/datum/mood_event/rogue_fatigue
	description = "I'm tired."
	mood_change = -2 * ROGUE_STRESS_TO_MOOD
	timeout = 40 MINUTES

/datum/mood_event/rogue_fatigue/fatigued
	description = "I'm REALLY tired."
	mood_change = -3 * ROGUE_STRESS_TO_MOOD

/datum/mood_event/rogue_fatigue/exhausted
	description = "I'm RIDICULOUSLY tired."
	mood_change = -4 * ROGUE_STRESS_TO_MOOD

/datum/mood_event/rogue_night_owl
	description = "The night is so relaxing and peaceful."
	mood_change = 3 * ROGUE_STRESS_TO_MOOD
	timeout = 20 MINUTES

/// The step of night fatigue one is at: 0 rested, 3 exhausted.
/mob/living/proc/rogue_fatigue_stage()
	var/datum/status_effect/rogue_fatigue/fatigue = has_status_effect(/datum/status_effect/rogue_fatigue)
	return fatigue ? fatigue.stage : 0

// The dream bank (crafting/experience.dm) counts the steps; its status follows every change.

/// Ratwood advance_sleep_depravation() at nightfall: one with fatal insomnia never tires (TRAIT_NOSLEEP); a night owl does not
/// tire at night but finds it peaceful (Ratwood night_owl stress), and tires by day instead (rogue_owl_tires()).
/datum/component/rogue_dreams/grow_tired()
	var/mob/living/sleeper = parent
	if(HAS_TRAIT(sleeper, TRAIT_NOSLEEP))
		return
	if(HAS_TRAIT(sleeper, TRAIT_NIGHT_OWL))
		sleeper.add_mood_event(FATIGUE_OWL_MOOD, /datum/mood_event/rogue_night_owl)
		return
	. = ..()
	rogue_sync_fatigue()

/// Ratwood update_tod() "day": the night owl tires at daybreak as others do at nightfall.
/datum/component/rogue_dreams/proc/rogue_owl_tires()
	var/mob/living/sleeper = parent
	if(!HAS_TRAIT(sleeper, TRAIT_NIGHT_OWL) || HAS_TRAIT(sleeper, TRAIT_NOSLEEP))
		return
	tiredness = min(tiredness + 1, FATIGUE_MAX)
	rogue_sync_fatigue()

/// A dream takes a step of tiredness away.
/datum/component/rogue_dreams/dream_tick()
	. = ..()
	rogue_sync_fatigue()

/datum/component/rogue_dreams/UnregisterFromParent()
	var/mob/living/sleeper = parent
	sleeper.remove_status_effect(/datum/status_effect/rogue_fatigue)
	return ..()

/// Shows the bank's tiredness as the status of its step.
/datum/component/rogue_dreams/proc/rogue_sync_fatigue()
	var/mob/living/sleeper = parent
	var/stage = clamp(tiredness, 0, FATIGUE_MAX)
	if(sleeper.rogue_fatigue_stage() == stage)
		return
	if(!stage)
		sleeper.remove_status_effect(/datum/status_effect/rogue_fatigue)
		return
	sleeper.apply_status_effect(GLOB.rogue_fatigue_stages[stage])

/// Ratwood remove_sleep_depravation() by coffee: steps of fatigue go, and each lift is a dream with extra dream points
/// (sleep_adv_points, advance_cycle()).
/datum/component/rogue_dreams/proc/rogue_lift_fatigue(steps, bonus_points)
	tiredness = max(tiredness - steps, 0)
	points += bonus_points
	advance_cycle()
	rogue_sync_fatigue()

/datum/controller/subsystem/rogue_dreams/on_time_of_day(datum/source, datum/rockhill_clock_step/phase/old_phase, datum/rockhill_clock_step/phase/new_phase)
	. = ..()
	if(new_phase?.name != ROCKHILL_DAY)
		return
	for(var/datum/component/rogue_dreams/dreams as anything in dreamers)
		dreams.rogue_owl_tires()

/// Ratwood caffeine on_mob_life(): what went down lifts the night fatigue - the first sip a night's tiredness, twenty units two
/// nights', forty units three (Ratwood checks the second step twice there; the third is meant) - and every lift is a dream.
/mob/living/proc/rogue_coffee_wakes(taken, first_sip)
	var/datum/component/rogue_dreams/dreams = GetComponent(/datum/component/rogue_dreams)
	if(!dreams?.tiredness)
		return
	switch(dreams.tiredness)
		if(1)
			if(taken < first_sip)
				return
			visible_message(span_info("[src] gains a look of focus in [p_their()] eyes, the weary expression lifting from [p_them()]."), span_green("I feel more focused from that coffee!"))
			dreams.rogue_lift_fatigue(1, COFFEE_POINTS_TIRED)
		if(2)
			if(taken < COFFEE_LIFTS_FATIGUED)
				return
			visible_message(span_info("[src] visibly wakes up, [p_their()] eyes opening fully and the weary tired expression lifting from [p_them()]."), span_green("I feel SO much more focused from that coffee!"))
			dreams.rogue_lift_fatigue(FATIGUE_MAX, COFFEE_POINTS_FATIGUED)
		else
			if(taken < COFFEE_LIFTS_EXHAUSTED)
				return
			visible_message(span_info("[src] suddenly looks like [p_they()] [p_are()]n't about to collapse anymore, blinking a couple of times as some consciousness comes back to [p_them()]."), span_green("That coffee hit the spot, I can think and move again without my eyelids weighing the same as my entire body."))
			dreams.rogue_lift_fatigue(FATIGUE_MAX, COFFEE_POINTS_EXHAUSTED)

/// Ratwood vigorized (roguebuff.dm): caffeine quickens and sharpens for ten minutes, renewed by every sip.
/datum/status_effect/rogue_vigorized
	id = "rogue_vigorized"
	status_type = STATUS_EFFECT_REFRESH
	duration = 10 MINUTES
	alert_type = /atom/movable/screen/alert/status_effect/rogue_vigorized
	/// Ratwood effectedstats.
	var/list/stats = list(ROGUE_STAT_SPEED = 1, ROGUE_STAT_INTELLIGENCE = 1)

/datum/status_effect/rogue_vigorized/on_apply()
	owner.attributes?.set_variable_attribute_modifier(id, stats.Copy())
	to_chat(owner, span_warning("I feel a surge of energy inside me!"))
	return TRUE

/datum/status_effect/rogue_vigorized/on_remove()
	owner.attributes?.remove_attribute_modifier(id)
	to_chat(owner, span_warning("The surge of energy inside me fades..."))
	return ..()

/atom/movable/screen/alert/status_effect/rogue_vigorized
	name = "Vigorized"
	desc = "I feel a surge of energy inside, quickening my speed and sharpening my focus."
	icon = ROGUE_COMBAT_ALERTS_ICON
	icon_state = "drunk"

#undef FATIGUE_ICON
#undef FATIGUE_MAX
#undef FATIGUE_MOOD
#undef FATIGUE_OWL_MOOD
#undef FATIGUE_SLOWDOWN
#undef COFFEE_LIFTS_FATIGUED
#undef COFFEE_LIFTS_EXHAUSTED
#undef COFFEE_POINTS_TIRED
#undef COFFEE_POINTS_FATIGUED
#undef COFFEE_POINTS_EXHAUSTED
