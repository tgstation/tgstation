#define MEND_REPLACE_KEY_SOURCE "%SOURCE%"
#define MEND_REPLACE_KEY_TARGET "%TARGET%"

/**
 * # Healing Touch element
 *
 * A mob with this element will be able to heal certain targets by attacking them.
 * This intercepts the attack and starts a do_after if the target is in its allowed type list.
 */
/datum/element/healing_touch
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// How much brute damage to heal
	var/heal_brute
	/// How much burn damage to heal
	var/heal_burn
	/// How much stamina damage to heal
	var/heal_stamina
	/// Interaction will use this key, and be blocked while this key is in use
	var/interaction_key
	/// Any extra conditions which need to be true to permit healing
	var/datum/callback/extra_checks
	/// Time it takes to perform the healing action
	var/heal_time
	/// Typecache of mobs we can heal
	var/list/valid_targets_typecache
	/// Can this be used on yourself?
	var/allow_self = FALSE
	/// Text to print when action starts
	var/action_text
	/// Text to print when action completes
	var/complete_text

/datum/element/healing_touch/Attach(datum/target, heal_brute = 20, heal_burn = 20, heal_stamina = 0, heal_time = 2 SECONDS, interaction_key = DOAFTER_SOURCE_HEAL_TOUCH, datum/callback/extra_checks = null, list/valid_targets_typecache = list(), allow_self = FALSE, action_text = "%SOURCE% begins healing %TARGET%", complete_text = "%SOURCE% finishes healing %TARGET%")
	. = ..()
	if (!isliving(target))
		return ELEMENT_INCOMPATIBLE

	src.heal_brute = heal_brute
	src.heal_burn = heal_burn
	src.heal_stamina = heal_stamina
	src.heal_time = heal_time
	src.interaction_key = interaction_key
	src.extra_checks = extra_checks
	src.valid_targets_typecache = valid_targets_typecache.Copy()
	src.allow_self = allow_self
	src.action_text = action_text
	src.complete_text = complete_text

	RegisterSignal(target, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(try_healing)) // Players
	RegisterSignal(target, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, PROC_REF(try_healing)) // NPCs

/datum/element/healing_touch/Detach(datum/source)
	UnregisterSignal(source, list(COMSIG_LIVING_UNARMED_ATTACK, COMSIG_HOSTILE_PRE_ATTACKINGTARGET))
	return ..()

/// Validate our target, and interrupt the attack chain to start healing it if it is allowed
/datum/element/healing_touch/proc/try_healing(mob/living/healer, atom/target)
	SIGNAL_HANDLER
	if (!isliving(target))
		return

	if (!is_type_in_typecache(target, valid_targets_typecache))
		return // Fall back to attacking it

	if (extra_checks && !extra_checks.Invoke(healer, target))
		return COMPONENT_CANCEL_ATTACK_CHAIN

	if (DOING_INTERACTION(healer, interaction_key))
		healer.balloon_alert(healer, "busy!")
		return COMPONENT_CANCEL_ATTACK_CHAIN

	if (!allow_self && target == healer)
		healer.balloon_alert(healer, "can't heal yourself!")
		return COMPONENT_CANCEL_ATTACK_CHAIN

	var/mob/living/living_target = target
	if (living_target.health >= living_target.maxHealth)
		target.balloon_alert(healer, "not hurt!")
		return COMPONENT_CANCEL_ATTACK_CHAIN

	if (living_target.stat == DEAD)
		target.balloon_alert(healer, "they're dead!")
		return COMPONENT_CANCEL_ATTACK_CHAIN

	INVOKE_ASYNC(src, PROC_REF(heal_target), healer, target)

	return COMPONENT_CANCEL_ATTACK_CHAIN

/// Perform a do_after and then heal our target
/datum/element/healing_touch/proc/heal_target(mob/living/healer, mob/living/target)
	if (action_text)
		healer.visible_message(span_notice("[format_string(action_text, healer, target)]"))

	if (!do_after(healer, heal_time, target = target, interaction_key = interaction_key))
		healer.balloon_alert(healer, "interrupted!")
		return

	if (complete_text)
		healer.visible_message(span_notice("[format_string(complete_text, healer, target)]"))

	target.heal_overall_damage(brute = heal_brute, burn = heal_burn, stamina = heal_stamina)
	new /obj/effect/temp_visual/heal(get_turf(target), COLOR_HEALING_CYAN)

/// Reformats the passed string with the replacetext keys
/datum/element/healing_touch/proc/format_string(string, atom/source, atom/target)
	var/final_message = replacetext(string, MEND_REPLACE_KEY_SOURCE, "[source]")
	final_message = replacetext(final_message, MEND_REPLACE_KEY_TARGET, "[target]")
	return final_message

#undef MEND_REPLACE_KEY_SOURCE
#undef MEND_REPLACE_KEY_TARGET
