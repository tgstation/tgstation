#define UNFRIEND_REPLACE_KEY_SOURCE "%SOURCE%"
#define UNFRIEND_REPLACE_KEY_TARGET "%TARGET%"

/**
 * # Unfriend Attacker
 *
 * Element which makes a mob remove you from its friends list you if you hurt it.
 * Doesn't make a callout post because we don't have twitter integration.
 */
/datum/element/unfriend_attacker
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// Message to print if we remove a friend. String %SOURCE% and %TARGET% are replaced by names if present.
	var/untamed_reaction

/datum/element/unfriend_attacker/Attach(datum/target, untamed_reaction)
	. = ..()
	if (!isliving(target))
		return ELEMENT_INCOMPATIBLE

	src.untamed_reaction = untamed_reaction
	target.AddElement(/datum/element/ai_retaliate)
	RegisterSignal(target, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(on_hurt))

/datum/element/unfriend_attacker/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, COMSIG_ATOM_WAS_ATTACKED)

/// If it's a bad touch make enemies
/datum/element/unfriend_attacker/proc/on_hurt(mob/living/owner, atom/attacker)
	SIGNAL_HANDLER

	if (owner.stat != CONSCIOUS)
		return
	if (!isliving(attacker))
		return
	var/mob/living/living_attacker = attacker
	if (!owner.unfriend(living_attacker))
		return
	if (!untamed_reaction)
		return
	var/display_message = replacetext(untamed_reaction, UNFRIEND_REPLACE_KEY_SOURCE, "[owner]")
	display_message = replacetext(display_message, UNFRIEND_REPLACE_KEY_TARGET, "[attacker]")
	owner.visible_message(span_notice(display_message))

#undef UNFRIEND_REPLACE_KEY_SOURCE
#undef UNFRIEND_REPLACE_KEY_TARGET
