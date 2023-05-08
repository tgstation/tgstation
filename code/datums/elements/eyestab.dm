/// What's the probability a clumsy person stabs themselves in the eyes?
#define CLUMSY_ATTACK_SELF_CHANCE 50
/// The damage threshold (of the victim's eyes) after which they start taking more serious effects
#define EYESTAB_BLEEDING_THRESHOLD 10
/// How much blur we can apply
#define EYESTAB_MAX_BLUR (4 MINUTES)

/// An element that lets you stab people in the eyes when targeting them
/datum/element/eyestab
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2

	/// The amount of damage to do per eyestab
	var/damage = 7

/datum/element/eyestab/Attach(datum/target, damage)
	. = ..()

	if (!isitem(target))
		return ELEMENT_INCOMPATIBLE

	if (!isnull(damage))
		src.damage = damage

	RegisterSignal(target, COMSIG_ITEM_ATTACK, PROC_REF(on_item_attack))

/datum/element/eyestab/Detach(datum/source, ...)
	. = ..()

	UnregisterSignal(source, COMSIG_ITEM_ATTACK)

/datum/element/eyestab/proc/on_item_attack(datum/source, mob/living/target, mob/living/user)
	SIGNAL_HANDLER

	if (user.zone_selected != BODY_ZONE_PRECISE_EYES)
		return

	if (HAS_TRAIT(user, TRAIT_PACIFISM))
		return

	if (HAS_TRAIT(user, TRAIT_CLUMSY) && prob(CLUMSY_ATTACK_SELF_CHANCE))
		target = user

	if (target.is_eyes_covered() || isalien(target) || isbrain(target))
		return

	perform_eyestab(source, target, user)

	return COMPONENT_SKIP_ATTACK

/datum/element/eyestab/proc/perform_eyestab(obj/item/item, mob/living/target, mob/living/user)
	var/obj/item/bodypart/target_limb = target.get_bodypart(BODY_ZONE_HEAD)
	if (ishuman(target) && isnull(target_limb))
		return

	item.add_fingerprint(user)
	playsound(item, item.hitsound, 30, TRUE, -1)
	user.do_attack_animation(target)
	if (target == user)
		user.visible_message(
			span_danger("[user] stabs [user.p_them()]self in the eye with [item]!"),
			span_userdanger("You stab yourself in the eye with [item]!"),
		)
	else
		target.visible_message(
			span_danger("[user] stabs [target] in the eye with [item]!"),
			span_userdanger("[user] stabs you in the eye with [item]!"),
		)

	if (target_limb)
		target.apply_damage(damage, BRUTE, target_limb, attacking_item = item)
	else
		target.take_bodypart_damage(damage)

	target.add_mood_event("eye_stab", /datum/mood_event/eye_stab)
	log_combat(user, target, "attacked", "[item.name]", "(Combat mode: [user.combat_mode ? "On" : "Off"])")

	var/obj/item/organ/internal/eyes/eyes = target.get_organ_slot(ORGAN_SLOT_EYES)
	if (!eyes)
		return

	target.adjust_eye_blur_up_to(6 SECONDS, EYESTAB_MAX_BLUR)
	eyes.apply_organ_damage(rand(2, 4))
	if(eyes.damage < EYESTAB_BLEEDING_THRESHOLD)
		return

	// At over 10 damage we apply a lot of eye blur
	target.adjust_eye_blur_up_to(30 SECONDS, EYESTAB_MAX_BLUR)
	if (target.stat != DEAD)
		to_chat(target, span_danger("Your eyes start to bleed profusely!"))

	// At over 10 damage, we cause at least enough eye damage to force nearsightedness
	if (!target.is_nearsighted_from(EYE_DAMAGE) && eyes.damage <= eyes.low_threshold)
		eyes.set_organ_damage(eyes.low_threshold)

	// At over 10 damage, there is a 50% chance they drop all their items
	if (prob(50))
		if (target.stat != DEAD && target.drop_all_held_items())
			to_chat(target, span_danger("You drop what you're holding and clutch at your eyes!"))
		target.adjust_eye_blur_up_to(20 SECONDS, EYESTAB_MAX_BLUR)
		target.Unconscious(2 SECONDS)
		target.Paralyze(4 SECONDS)

	// At over 10 damage, there is a chance (based on eye damage) of going blind
	if (prob(eyes.damage - eyes.low_threshold + 1))
		if (!target.is_blind_from(EYE_DAMAGE))
			eyes.set_organ_damage(eyes.maxHealth)
		// Also cause some temp blindness, so that they're still blind even if they get healed
		target.adjust_temp_blindness_up_to(20 SECONDS, 1 MINUTES)

#undef CLUMSY_ATTACK_SELF_CHANCE
#undef EYESTAB_BLEEDING_THRESHOLD
#undef EYESTAB_MAX_BLUR
