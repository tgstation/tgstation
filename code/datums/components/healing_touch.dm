#define MEND_REPLACE_KEY_SOURCE "%SOURCE%"
#define MEND_REPLACE_KEY_TARGET "%TARGET%"

/**
 * # Healing Touch component
 *
 * A mob with this component will be able to heal certain targets by attacking them.
 * This intercepts the attack and starts a do_after if the target is in its allowed type list.
 */
/datum/component/healing_touch
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	/// How much brute damage to heal
	var/heal_brute
	/// How much burn damage to heal
	var/heal_burn
	/// How much toxin damage to heal
	var/heal_tox
	/// How much oxygen damage to heal
	var/heal_oxy
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
	/// Bitfield for biotypes of mobs we can heal
	var/valid_biotypes
	/// Which kinds of carbon limbs can we heal, has no effect on non-carbon mobs. Set to null if you don't care about excluding prosthetics.
	var/required_bodytype
	/// How targeting yourself works, expects one of HEALING_TOUCH_ANYONE, HEALING_TOUCH_NOT_SELF, or HEALING_TOUCH_SELF_ONLY
	var/self_targeting
	/// Text to print when action starts, replaces %SOURCE% with healer and %TARGET% with healed mob
	var/action_text
	/// Text to print when action completes, replaces %SOURCE% with healer and %TARGET% with healed mob
	var/complete_text
	/// Whether to print the target's remaining health after healing (for non-carbon targets only)
	var/show_health
	/// Color for the healing effect
	var/heal_color
	/// Optional click modifier required
	var/required_modifier
	/// Callback to run after healing a mob
	var/datum/callback/after_healed

/datum/component/healing_touch/Initialize(
	heal_brute = 20,
	heal_burn = 20,
	heal_tox = 0,
	heal_oxy = 0,
	heal_stamina = 0,
	heal_time = 2 SECONDS,
	interaction_key = DOAFTER_SOURCE_HEAL_TOUCH,
	datum/callback/extra_checks = null,
	list/valid_targets_typecache = list(),
	valid_biotypes = MOB_ORGANIC | MOB_MINERAL,
	required_bodytype = BODYTYPE_ORGANIC,
	self_targeting = HEALING_TOUCH_NOT_SELF,
	action_text = "%SOURCE% begins healing %TARGET%",
	complete_text = "%SOURCE% finishes healing %TARGET%",
	show_health = FALSE,
	heal_color = COLOR_HEALING_CYAN,
	required_modifier = null,
	datum/callback/after_healed = null,
)
	if (!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	src.heal_brute = heal_brute
	src.heal_burn = heal_burn
	src.heal_tox = heal_tox
	src.heal_oxy = heal_oxy
	src.heal_stamina = heal_stamina
	src.heal_time = heal_time
	src.interaction_key = interaction_key
	src.extra_checks = extra_checks
	src.valid_targets_typecache = valid_targets_typecache.Copy()
	src.valid_biotypes = valid_biotypes
	src.required_bodytype = required_bodytype
	src.self_targeting = self_targeting
	src.action_text = action_text
	src.complete_text = complete_text
	src.show_health = show_health
	src.heal_color = heal_color
	src.required_modifier = required_modifier
	src.after_healed = after_healed

	RegisterSignal(parent, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(try_healing)) // Players
	RegisterSignal(parent, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, PROC_REF(try_healing)) // NPCs
	var/mob/living/living_parent = parent
	living_parent.ai_controller?.set_blackboard_key(BB_BASIC_MOB_HEALER, TRUE)

// Let's populate this list as we actually use it, this thing has too many args
/datum/component/healing_touch/InheritComponent(
	datum/component/new_component,
	i_am_original,
	heal_color,
)
	src.heal_color = heal_color

/datum/component/healing_touch/UnregisterFromParent()
	var/mob/living/living_parent = parent
	living_parent.ai_controller?.set_blackboard_key(BB_BASIC_MOB_HEALER, FALSE)
	UnregisterSignal(parent, list(COMSIG_LIVING_UNARMED_ATTACK, COMSIG_HOSTILE_PRE_ATTACKINGTARGET))
	return ..()

/datum/component/healing_touch/Destroy(force)
	extra_checks = null
	return ..()

/// Validate our target, and interrupt the attack chain to start healing it if it is allowed
/datum/component/healing_touch/proc/try_healing(mob/living/healer, atom/target, proximity, modifiers)
	SIGNAL_HANDLER
	if (!isliving(target))
		return

	if (!isnull(required_modifier) && !LAZYACCESS(modifiers, required_modifier))
		return

	if (length(valid_targets_typecache) && !is_type_in_typecache(target, valid_targets_typecache))
		return // Fall back to attacking it

	if (extra_checks && !extra_checks.Invoke(healer, target))
		return COMPONENT_CANCEL_ATTACK_CHAIN

	if (DOING_INTERACTION(healer, interaction_key))
		healer.balloon_alert(healer, "busy!")
		return COMPONENT_CANCEL_ATTACK_CHAIN

	switch (self_targeting)
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
	if (!isnull(valid_biotypes) && !(valid_biotypes & target.mob_biotypes))
		return FALSE
	if (target.getStaminaLoss() > 0 && heal_stamina)
		return TRUE
	if (target.getOxyLoss() > 0 && heal_oxy)
		return TRUE
	if (target.getToxLoss() > 0 && heal_tox)
		return TRUE
	if (!iscarbon(target))
		return (target.getBruteLoss() > 0 && heal_brute) || (target.getFireLoss() > 0 && heal_burn)
	var/mob/living/carbon/carbon_target = target
	for (var/obj/item/bodypart/part in carbon_target.bodyparts)
		if (!(part.brute_dam && heal_brute) && !(part.burn_dam && heal_burn))
			continue
		if (!isnull(required_bodytype) && !(part.bodytype & required_bodytype))
			continue
		return TRUE
	return FALSE

/// Perform a do_after and then heal our target
/datum/component/healing_touch/proc/heal_target(mob/living/healer, mob/living/target)
	if (action_text)
		healer.visible_message(span_notice("[format_string(action_text, healer, target)]"))

	if (heal_time && !do_after(healer, heal_time, target = target, interaction_key = interaction_key))
		healer.balloon_alert(healer, "interrupted!")
		return

	if (complete_text)
		healer.visible_message(span_notice("[format_string(complete_text, healer, target)]"))

	var/healed = target.heal_overall_damage(
		brute = heal_brute,
		burn = heal_burn,
		stamina = heal_stamina,
		required_bodytype = required_bodytype,
		updating_health = FALSE,
	)
	healed += target.adjustOxyLoss(-heal_oxy, updating_health = FALSE, required_biotype = valid_biotypes)
	healed += target.adjustToxLoss(-heal_tox, updating_health = FALSE, required_biotype = valid_biotypes)
	if (healed <= 0)
		return

	target.updatehealth()
	new /obj/effect/temp_visual/heal(get_turf(target), heal_color)
	after_healed?.Invoke(target)

	if(!show_health)
		return
	var/formatted_string = format_string("%TARGET% now has <b>[health_percentage(target)] health.</b>", healer, target)
	to_chat(healer, span_danger(formatted_string))

/// Reformats the passed string with the replacetext keys
/datum/component/healing_touch/proc/format_string(string, atom/source, atom/target)
	var/final_message = replacetext(string, MEND_REPLACE_KEY_SOURCE, "[source]")
	final_message = replacetext(final_message, MEND_REPLACE_KEY_TARGET, "[target]")
	return final_message

#undef MEND_REPLACE_KEY_SOURCE
#undef MEND_REPLACE_KEY_TARGET
