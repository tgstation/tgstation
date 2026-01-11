/**
 * ## Personality Singleton
 *
 * Contains information about a personaility.
 *
 * A personality is designed to be a small modifier to the way a mob reacts to moodlets or world events.
 *
 * For example, a mob with the Callous personality would not receive a positive moodlet for saving someone's life.
 *
 * They're not meant to be full blown quirks that hold state and such.
 * If you NEED state, consider making a quirk, or moving your behavior into a component the personality applies.
 */
/datum/personality
	/// Required: Name of the personality
	var/name
	/// Required: Description of the personality.
	/// Phrased to be "In character" - i.e. "I like to help people!"
	/// Rather than OOC 0 i.e. "When helping people, I get a positive moodlet."
	var/desc
	/// Optional: Short blurb on what positive effects this personality has on gameplay, for ui
	var/pos_gameplay_desc
	/// Optional: Short blurb on what negative effects this personality has on gameplay, for ui
	var/neg_gameplay_desc
	/// Optional: Short blurb on what neutral effects this personality has on gameplay, for ui
	var/neut_gameplay_desc
	/// Easy way to apply a trait as a part of a personality.
	var/personality_trait
	/// Required: The key to use when saving this personality to a savefile.
	/// Don't change it once it's set unless you want to write migration code
	var/savefile_key
	/// What groups does this personality belong to?
	/// Personalities in the same group are mutually exclusive.
	var/list/groups
	/// Does this personality need to process every tick?
	/// If true, you'll need to override on_tick() with logic
	var/processes = FALSE

/datum/personality/New()
	. = ..()
	if(processes)
		SSpersonalities.processing_personalities[src] = list()
		START_PROCESSING(SSpersonalities, src)

/datum/personality/Destroy(force)
	if(force)
		STOP_PROCESSING(SSpersonalities, src)
		SSpersonalities.processing_personalities -= src
		SSpersonalities.personalities_by_type -= type
		SSpersonalities.personalities_by_key -= savefile_key
		return ..()

	stack_trace("qdel called on a personality singleton!")
	return QDEL_HINT_LETMELIVE

/**
 * Called when applying this personality to a mob.
 *
 * * who - The mob to apply this personality to.
 * This mob is asserted to have `mob_mood`.
 */
/datum/personality/proc/apply_to_mob(mob/living/who)
	SHOULD_CALL_PARENT(TRUE)
	if(personality_trait)
		ADD_TRAIT(who, personality_trait, PERSONALITY_TRAIT)
	LAZYSET(who.personalities, type, TRUE)
	if(processes)
		SSpersonalities.processing_personalities[src] += who

/**
 * Called when removing this personality from a mob.
 *
 * This is not called as a part of the mob being deleted.
 *
 * * who - The mob to remove this personality from.
 * This mob is asserted to have `mob_mood`.
 */
/datum/personality/proc/remove_from_mob(mob/living/who)
	SHOULD_CALL_PARENT(TRUE)
	if(personality_trait)
		REMOVE_TRAIT(who, personality_trait, PERSONALITY_TRAIT)
	LAZYREMOVE(who.personalities, type)
	if(processes)
		SSpersonalities.processing_personalities[src] -= who

/datum/personality/process(seconds_per_tick)
	for(var/mob/living/subject as anything in SSpersonalities.processing_personalities[src])
		if(subject.stat >= UNCONSCIOUS || HAS_TRAIT(subject, TRAIT_NO_TRANSFORM))
			continue
		if(on_tick(subject, seconds_per_tick) != PROCESS_KILL)
			continue
		stack_trace("Personality [type] processed but did not override on_tick().")
		SSpersonalities.processing_personalities -= src // stop tracking if we're done processing
		return PROCESS_KILL

	return null

/// Called every SSpersonality tick if `processes` is TRUE.
/// Don't call parent if you override this, that's for error checking
/datum/personality/proc/on_tick(mob/living/subject, seconds_per_tick)
	return PROCESS_KILL
