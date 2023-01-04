#define BEFRIEND_REPLACE_KEY_SOURCE "%SOURCE%"
#define BEFRIEND_REPLACE_KEY_TARGET "%TARGET%"

/**
 * # Befriend Petting
 *
 * Element which makes a mob befriend you if you pet it enough, and unfriend you if you hurt it.
 */
/datum/element/befriend_petting
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// Chance of success per interaction.
	var/befriend_chance
	/// Message to print if we gain a friend. String %SOURCE% and %TARGET% are replaced by names if present.
	var/tamed_reaction
	/// Message to print if we remove a friend. String %SOURCE% and %TARGET% are replaced by names if present.
	var/untamed_reaction

/datum/element/befriend_petting/Attach(datum/target, befriend_chance = AI_DOG_PET_FRIEND_PROB, tamed_reaction, untamed_reaction)
	. = ..()
	if (!isliving(target))
		return ELEMENT_INCOMPATIBLE

	src.befriend_chance = befriend_chance
	src.tamed_reaction = tamed_reaction
	src.untamed_reaction = untamed_reaction
	target.AddElement(/datum/element/ai_retaliate)
	RegisterSignal(target, COMSIG_ATOM_ATTACK_HAND, PROC_REF(on_click))
	RegisterSignal(target, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(on_hurt))

/datum/element/befriend_petting/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, list(COMSIG_ATOM_ATTACK_HAND, COMSIG_ATOM_WAS_ATTACKED))

/// If it's a nice touch make friends
/datum/element/befriend_petting/proc/on_click(mob/living/owner, mob/living/user)
	SIGNAL_HANDLER

	if (!istype(user))
		return
	if (user.combat_mode)
		return // We'll deal with this later
	if (owner.stat == DEAD)
		var/additional_text = HAS_TRAIT(user, TRAIT_NAIVE) || HAS_TRAIT(user.mind, TRAIT_NAIVE) ? "It looks like [owner.p_theyre()] sleeping." : "[owner.p_they(capitalized = TRUE)] seem[owner.p_s()] to be dead."
		to_chat(user, span_warning("[owner] feels cold to the touch. [additional_text]"))
		return
	if (owner.stat != CONSCIOUS)
		return
	if (!prob(befriend_chance))
		return
	if (!owner.befriend(user))
		return
	if (!tamed_reaction)
		return
	var/display_message = replacetext(tamed_reaction, BEFRIEND_REPLACE_KEY_SOURCE, "[owner]")
	display_message = replacetext(display_message, BEFRIEND_REPLACE_KEY_TARGET, "[user]")
	owner.visible_message(span_notice(display_message))

/// If it's a bad touch make enemies
/datum/element/befriend_petting/proc/on_hurt(mob/living/owner, atom/attacker)
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
	var/display_message = replacetext(untamed_reaction, BEFRIEND_REPLACE_KEY_SOURCE, "[owner]")
	display_message = replacetext(display_message, BEFRIEND_REPLACE_KEY_TARGET, "[attacker]")
	owner.visible_message(span_notice(display_message))

#undef BEFRIEND_REPLACE_KEY_SOURCE
#undef BEFRIEND_REPLACE_KEY_TARGET
