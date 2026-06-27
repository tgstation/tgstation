/datum/mutation/aoe_moodlet
	name = "Extremely Unsightly"
	desc = "The subject's body - and especially face - is unnaturally unsightly, causing a negative reaction from those around them. \
		Wearing a mask will dampen the effect."
	quality = NEGATIVE
	instability = NEGATIVE_STABILITY_MINOR
	text_gain_indication = span_warning("You feel pretty in your own way.")
	text_lose_indication = span_notice("You feel less self-conscious.")
	difficulty = 12

/datum/mutation/aoe_moodlet/on_acquiring(mob/living/carbon/human/acquirer)
	. = ..()
	if(!.)
		return
	RegisterSignal(acquirer, COMSIG_ATOM_EXAMINE, PROC_REF(on_examined))
	RegisterSignal(acquirer, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))

/datum/mutation/aoe_moodlet/on_losing(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return
	UnregisterSignal(owner, COMSIG_ATOM_EXAMINE)
	UnregisterSignal(owner, COMSIG_MOVABLE_MOVED)

/datum/mutation/aoe_moodlet/proc/on_examined(datum/source, mob/examiner, ...)
	SIGNAL_HANDLER

	if(examiner == owner || !isliving(examiner) || HAS_TRAIT(owner, TRAIT_FACE_COVERED))
		return
	apply_other_moodlet(examiner)

/datum/mutation/aoe_moodlet/proc/on_moved(datum/source, ...)
	SIGNAL_HANDLER

	var/obj/structure/mirror/mirror = locate() in owner.loc
	if(isnull(mirror))
		return
	apply_own_moodlet()

/datum/mutation/aoe_moodlet/on_life(seconds_per_tick)
	if(HAS_TRAIT(owner, TRAIT_FACE_COVERED))
		return // this is applied by newspapers, and i think it would be funny if newspapers specifically blocked 100% of the effect.

	for(var/mob/living/nearby in viewers(3, owner))
		if(nearby == owner)
			continue
		apply_other_moodlet(nearby)

/datum/mutation/aoe_moodlet/proc/apply_own_moodlet()
	owner.add_mood_event(type, /datum/mood_event/seen_ugly_mutation/self, owner)

/datum/mutation/aoe_moodlet/proc/apply_other_moodlet(mob/living/other)
	other.add_mood_event(type, get_moodlet(), owner)

/datum/mutation/aoe_moodlet/proc/get_moodlet()
	return (owner.obscured_slots & HIDEFACE) ? /datum/mood_event/seen_ugly_mutation/weak : /datum/mood_event/seen_ugly_mutation

/datum/mutation/aoe_moodlet/positive
	name = "Extremely Comely"
	desc = "The subject's body - and especially face - is unnaturally comely, causing a positive reaction from those around them. \
		Wearing a mask will dampen the effect."
	quality = POSITIVE
	instability = POSITIVE_INSTABILITY_MINOR
	text_gain_indication = span_notice("You feel pretty in your own way.")
	text_lose_indication = span_notice("You feel less self-conscious.")
	difficulty = 12

/datum/mutation/aoe_moodlet/positive/apply_own_moodlet()
	owner.add_mood_event(type, /datum/mood_event/seen_pretty_mutation/self, owner)

/datum/mutation/aoe_moodlet/positive/get_moodlet()
	return (owner.obscured_slots & HIDEFACE) ? /datum/mood_event/seen_pretty_mutation/weak : /datum/mood_event/seen_pretty_mutation

// Negative version
/datum/mood_event/seen_ugly_mutation
	description = "Something is seriously wrong with that guy!"
	mood_change = -3
	timeout = 2 MINUTES

/datum/mood_event/seen_ugly_mutation/can_effect_mob(datum/mood/home, mob/living/who, ...)
	if(HAS_PERSONALITY(who, /datum/personality/compassionate) || HAS_PERSONALITY(who, /datum/personality/empathetic))
		return FALSE

	return ..()

/datum/mood_event/seen_ugly_mutation/add_effects(mob/mutant)
	description = "Something is seriously wrong with [mutant || "that guy"]!"

/datum/mood_event/seen_ugly_mutation/weak
	description = "Something looks wrong about that guy."
	mood_change = -1

/datum/mood_event/seen_ugly_mutation/weak/add_effects(mob/mutant)
	description = "Something looks wrong about [mutant || "that guy"]."

/datum/mood_event/seen_ugly_mutation/self
	description = "...Is THAT what I look like?!"
	mood_change = -2
	timeout = 5 MINUTES

// Positive version
/datum/mood_event/seen_pretty_mutation
	description = "That person looks pretty good - must be a new haircut or something."
	mood_change = 3
	timeout = 2 MINUTES

/datum/mood_event/seen_pretty_mutation/can_effect_mob(datum/mood/home, mob/living/who, ...)
	if(HAS_PERSONALITY(who, /datum/personality/misanthropic) || HAS_PERSONALITY(who, /datum/personality/callous))
		return FALSE

	return ..()

/datum/mood_event/seen_pretty_mutation/add_effects(mob/mutant)
	description = "[mutant || "That person"] looks pretty good - must be a new haircut or something."

/datum/mood_event/seen_pretty_mutation/weak
	description = "That person looks alright - it must be the lighting in here."
	mood_change = 1

/datum/mood_event/seen_pretty_mutation/weak/add_effects(mob/mutant)
	description = "[mutant || "That person"] looks alright - it must be the lighting in here."

/datum/mood_event/seen_pretty_mutation/self
	description = "I look pretty good!"
	mood_change = 2
	timeout = 5 MINUTES
