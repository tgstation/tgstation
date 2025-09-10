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
	/// Rather than OOC- i.e. "When helping people, I get a positive moodlet."
	var/desc
	/// Optional: What positive effects this personality has on gameplay.
	var/pos_gameplay_desc
	/// Optional: What negative effects this personality has on gameplay.
	var/neg_gameplay_desc
	/// Optional: What neutral effects this personality has on gameplay.
	var/neut_gameplay_desc
	/// Easy way to apply a trait as a part of a personality.
	var/personality_trait
	/// Required: The key to use when saving this personality to a savefile.
	/// Don't change it once it's set unless you want to write migration code
	var/savefile_key
	/// Does this process?
	var/processes = FALSE

/datum/personality/Destroy(force)
	if(force)
		return ..()
	stack_trace("qdel called on a personality singleton!")
	return QDEL_HINT_LETMELIVE

/// Trait source for personality traits
#define PERSONALITY_TRAIT "personality_trait"

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
		SSpersonalities.processing_personalities[type] += who

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
		SSpersonalities.processing_personalities[type] -= who

#undef PERSONALITY_TRAIT

/// Called every SSpersonality tick if `processes` is TRUE
/datum/personality/proc/on_tick(mob/living/subject, seconds_per_tick)
	CRASH("Personality [type] processed but did not override on_tick().")
