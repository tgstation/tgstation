/datum/mood_event
	/// Description of the mood event
	var/description
	/// An integer value that affects overall sanity over time
	var/mood_change = 0
	/// How long this mood event should last
	var/timeout = 0
	/// Is this mood event hidden on examine
	var/hidden = FALSE
	/**
	 * A category to put multiple mood events. If one of the mood events in the category
	 * is active while another mood event (from the same category) is triggered it will remove
	 * the effects of the current mood event and replace it with the new one
	 */
	VAR_FINAL/category
	/// Flags that determine what kind of event this is
	/// For example, you might have a "EVENT_FEAR" flag that denotes this mood event relates to being afraid of something
	var/event_flags = NONE
	/// Icon state of the unique mood event icon, if applicable
	var/special_screen_obj
	/// if false, it will be an overlay instead
	var/special_screen_replace = TRUE
	/// Owner of this mood event
	var/mob/living/owner
	/// List of required jobs for this mood event
	var/list/required_job

/datum/mood_event/New(category)
	src.category = category

/datum/mood_event/Destroy()
	if(owner)
		remove_effects()
		owner = null
	return ..()

/**
 * Called when this datum is created, checks if the passed mob can experience this mood event
 *
 * * who - the mob to check
 *
 * Return TRUE if the mob can experience this mood event
 * Return FALSE if the mob should be unaffected
 */
/datum/mood_event/proc/can_effect_mob(datum/mood/home, mob/living/who, ...)
	SHOULD_CALL_PARENT(TRUE)
	if(LAZYLEN(required_job) && !is_type_in_list(who.mind?.assigned_role, required_job))
		return FALSE

	if((event_flags & MOOD_EVENT_WHIMSY))
		// Whimsical people get positive whimsical moodlets
		// Non-whimsical people get negative whimsical moodlets
		var/is_whimsical = HAS_PERSONALITY(who, /datum/personality/whimsical)
		if(mood_change >= 0 && !is_whimsical)
			return FALSE
		if(mood_change < 0 && is_whimsical)
			return FALSE

	if((event_flags & MOOD_EVENT_ART) && HAS_PERSONALITY(who, /datum/personality/unimaginative))
		return FALSE

	if((event_flags & MOOD_EVENT_PAIN) && HAS_TRAIT(who, TRAIT_ANALGESIA))
		return FALSE

	return TRUE

/**
 * Wrapper for the mood event being added to a mob
 */
/datum/mood_event/proc/on_add(datum/mood/home, mob/living/who, list/mood_args)
	SHOULD_NOT_OVERRIDE(TRUE)

	owner = who

	if((event_flags & MOOD_EVENT_ART) && HAS_PERSONALITY(who, /datum/personality/creative))
		mood_change *= 1.2

	if((event_flags & MOOD_EVENT_SPIRITUAL) && !HAS_TRAIT(who, TRAIT_SPIRITUAL))
		mood_change *= 0.2

	if(event_flags & MOOD_EVENT_FOOD)
		if(HAS_PERSONALITY(owner, /datum/personality/ascetic))
			mood_change *= 0.75
		if(HAS_PERSONALITY(owner, /datum/personality/gourmand))
			mood_change *= 1.25

	if(event_flags & MOOD_EVENT_FEAR)
		if(HAS_PERSONALITY(owner, /datum/personality/cowardly))
			mood_change *= 1.25
		if(HAS_PERSONALITY(owner, /datum/personality/brave))
			mood_change *= 0.75

	add_effects(arglist(mood_args))

	mood_change = floor(mood_change)

	timeout *= max((mood_change > 0) ? home.positive_moodlet_length_modifier : home.negative_moodlet_length_modifier, 0.1)
	if(timeout)
		addtimer(CALLBACK(home, TYPE_PROC_REF(/datum/mood, clear_mood_event), category), timeout, (TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_NO_HASH_WAIT))

/**
 * Called when added to a mob
 *
 * * ... - Any arguments passed to add_mood_event after the typepath are passed here
 */
/datum/mood_event/proc/add_effects(...)
	return

/**
 * Called when the event is cleared from a mob
 */
/datum/mood_event/proc/remove_effects()
	return

/**
 * Called when we get added to a mood datum, but a mood of our type in our category already
 *
 * * home - the mood datum we are being added to
 * * ... - any other arguments that are passed to the mood event
 *
 * Return BLOCK_NEW_MOOD to stop the new mood event from being added
 * Return ALLOW_NEW_MOOD to allow the new mood event to be added - note this implicitly deletes [src]
 */
/datum/mood_event/proc/be_refreshed(datum/mood/home, ...)
	// Base behavior is refresh the timer
	if(timeout)
		addtimer(CALLBACK(home, TYPE_PROC_REF(/datum/mood, clear_mood_event), category), timeout, (TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_NO_HASH_WAIT))
	return BLOCK_NEW_MOOD

/**
 * Called when we get added to a mood datum, but a mood of a different type is in our category
 *
 * * home - the mood datum we are being added to
 * * new_event - the new mood event that is being added
 * * ... - any other arguments that are passed to the mood event
 *
 * Return BLOCK_NEW_MOOD to stop the new mood event from being added
 * Return ALLOW_NEW_MOOD to allow the new mood event to be added - note this implicitly deletes [src]
 */
/datum/mood_event/proc/be_replaced(datum/mood/home, datum/mood_event/new_event, ...)
	return ALLOW_NEW_MOOD
