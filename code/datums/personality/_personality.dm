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

// /datum/personality/morbid
// 	name = "Morbid"
// 	desc = "I am interested in more macabre things."
// 	pos_gameplay_desc = "You receive positive moodlets from abnormal and macabre things, such as death and blood."
// 	personality_trait = TRAIT_MORBID

// /datum/personality/evil
// 	name = "Evil"
// 	desc = "I'm a bad person."
// 	pos_gameplay_desc = "You receive positive moodlets from hurting people, and negative moodlets from helping them."

// /datum/personality/greedy
// 	savefile_key = "greedy"
// 	name = "Greedy"
// 	desc = "Everything is mine, all mine!"
// 	neg_gameplay_desc = "Dislikes spending or giving away money"

// /datum/personality/prideful
// 	savefile_key = "prideful"
// 	name = "Prideful"
// 	desc = "I am proud of who I am."
// 	pos_gameplay_desc = "Likes success"
// 	neg_gameplay_desc = "Dislikes failure"

// /datum/personality/humble
// 	savefile_key = "humble"
// 	name = "Humble"
// 	desc = "I'm just doing my job."
// 	neut_gameplay_desc = "Success or failure affects your mood less"

// /datum/personality/authoritarian
// 	savefile_key = "authoritarian"
// 	name = "Authoritarian"
// 	desc = "Order and discipline are the only things keeping this station running."
// 	pos_gameplay_desc = "Likes being around heads of staff"
// 	neut_gameplay_desc = "Prefers to work in positions of authority, such as a head of staff or security"

// /datum/personality/egalitarian
// 	savefile_key = "egalitarian"
// 	name = "Egalitarian"
// 	desc = "Everyone should have equal say. We are all in this together."
// 	neg_gameplay_desc = "Dislikes being around heads of staff"

// /datum/personality/reckless
// 	savefile_key = "reckless"
// 	name = "Reckless"
// 	desc = "What is life without a little danger?"
// 	pos_gameplay_desc = "Likes doing risky things"

// /datum/personality/cautious
// 	savefile_key = "cautious"
// 	name = "Cautious"
// 	desc = "Risks are foolish on a station as deadly as this."
// 	neg_gameplay_desc = "Dislikes doing risky things"
