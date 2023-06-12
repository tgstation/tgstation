#define MEND_REPLACE_KEY_SOURCE "%SOURCE%"
#define MEND_REPLACE_KEY_TARGET "%TARGET%"

/**
 * # Healing Touch component
 *
 * A mob with this component will be able to heal certain targets by attacking them.
 * This intercepts the attack and starts a do_after if the target is in its allowed type list.
 */
/datum/component/healing_touch
	/// How much brute damage to heal
	var/heal_brute
	/// How much burn damage to heal
	var/heal_burn
	/// How much stamina damage to heal
	var/heal_stamina
	/// Interaction will use this key, and be blocked while this key is in use
	var/interaction_key
	/// Any extra conditions which need to be true to permit healing. Returning TRUE permits the healing, FALSE or null cancels it.
	var/datum/callback/extra_checks
	/// Time it takes to perform the healing action
	var/heal_time
	/// Typecache of mobs we can heal
	var/list/valid_targets_typecache
	/// How targetting yourself works, expects one of HEALING_TOUCH_ANYONE, HEALING_TOUCH_NOT_SELF, or HEALING_TOUCH_SELF_ONLY
	var/self_targetting
	/// Text to print when action starts, replaces %SOURCE% with healer and %TARGET% with healed mob
	var/action_text
	/// Text to print when action completes, replaces %SOURCE% with healer and %TARGET% with healed mob
	var/complete_text

/datum/component/healing_touch/Initialize(
	heal_brute = 20,
	heal_burn = 20,
	heal_stamina = 0,
	heal_time = 2 SECONDS,
	interaction_key = DOAFTER_SOURCE_HEAL_TOUCH,
	datum/callback/extra_checks = null,
	list/valid_targets_typecache = list(),
	self_targetting = HEALING_TOUCH_NOT_SELF,
	action_text = "%SOURCE% begins healing %TARGET%",
	complete_text = "%SOURCE% finishes healing %TARGET%",
)
	if (!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	src.heal_brute = heal_brute
	src.heal_burn = heal_burn
	src.heal_stamina = heal_stamina
	src.heal_time = heal_time
	src.interaction_key = interaction_key
	src.extra_checks = extra_checks
	src.valid_targets_typecache = valid_targets_typecache.Copy()
	src.self_targetting = self_targetting
	src.action_text = action_text
	src.complete_text = complete_text

	RegisterSignal(parent, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(try_healing)) // Players
	RegisterSignal(parent, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, PROC_REF(try_healing)) // NPCs

/datum/component/healing_touch/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_LIVING_UNARMED_ATTACK, COMSIG_HOSTILE_PRE_ATTACKINGTARGET))
	return ..()

/datum/component/healing_touch/Destroy(force, silent)
	QDEL_NULL(extra_checks)
	return ..()

/// Validate our target, and interrupt the attack chain to start healing it if it is allowed
/datum/component/healing_touch/proc/try_healing(mob/living/healer, atom/target)
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

	switch (self_targetting)
		if (HEALING_TOUCH_NOT_SELF)
			if (target == healer)
				healer.balloon_alert(healer, "can't heal yourself!")
				return COMPONENT_CANCEL_ATTACK_CHAIN
		if (HEALING_TOUCH_SELF_ONLY)
			if (target != healer)
				healer.balloon_alert(healer, "can only heal yourself!")
				return COMPONENT_CANCEL_ATTACK_CHAIN

	var/mob/living/living_target = target
	if (living_target.health >= living_target.maxHealth)
		target.balloon_alert(healer, "not hurt!")
		return COMPONENT_CANCEL_ATTACK_CHAIN

	if (!has_healable_damage(living_target))
		target.balloon_alert(healer, "can't heal that!")
		return COMPONENT_CANCEL_ATTACK_CHAIN

	if (living_target.stat == DEAD)
		target.balloon_alert(healer, "they're dead!")
		return COMPONENT_CANCEL_ATTACK_CHAIN

	INVOKE_ASYNC(src, PROC_REF(heal_target), healer, target)

	return COMPONENT_CANCEL_ATTACK_CHAIN

/// Returns true if the target has a kind of damage which we can heal
/datum/component/healing_touch/proc/has_healable_damage(mob/living/target)
	return (target.getBruteLoss() > 0 && heal_brute) || (target.getFireLoss() > 0 && heal_burn) || (target.getStaminaLoss() > 0 && heal_stamina)

/// Perform a do_after and then heal our target
/datum/component/healing_touch/proc/heal_target(mob/living/healer, mob/living/target)
	if (action_text)
		healer.visible_message(span_notice("[format_string(action_text, healer, target)]"))

	if (heal_time && !do_after(healer, heal_time, target = target, interaction_key = interaction_key))
		healer.balloon_alert(healer, "interrupted!")
		return

	if (complete_text)
		healer.visible_message(span_notice("[format_string(complete_text, healer, target)]"))

	target.heal_overall_damage(brute = heal_brute, burn = heal_burn, stamina = heal_stamina)
	new /obj/effect/temp_visual/heal(get_turf(target), COLOR_HEALING_CYAN)

/// Reformats the passed string with the replacetext keys
/datum/component/healing_touch/proc/format_string(string, atom/source, atom/target)
	var/final_message = replacetext(string, MEND_REPLACE_KEY_SOURCE, "[source]")
	final_message = replacetext(final_message, MEND_REPLACE_KEY_TARGET, "[target]")
	return final_message

#undef MEND_REPLACE_KEY_SOURCE
#undef MEND_REPLACE_KEY_TARGET
