#define CLUMSY_ATTACK_SELF_CHANCE 50
#define EYESTAB_BLEEDING_THRESHOLD 10

/// An element that lets you stab people in the eyes when targeting them
/datum/element/eyestab
	element_flags = ELEMENT_BESPOKE | ELEMENT_DETACH
	id_arg_index = 2

	/// The amount of damage to do per eyestab
	var/damage = 7

/datum/element/eyestab/Attach(datum/target, damage)
	. = ..()

	if (!isitem(target))
		return ELEMENT_INCOMPATIBLE

	if (!isnull(damage))
		src.damage = damage

	RegisterSignal(target, COMSIG_ITEM_ATTACK, .proc/on_item_attack)

/datum/element/eyestab/Detach(datum/source, ...)
	. = ..()

	UnregisterSignal(source, COMSIG_ITEM_ATTACK)

/datum/element/eyestab/proc/on_item_attack(datum/source, mob/living/target, mob/living/user)
	SIGNAL_HANDLER

	if (user.zone_selected == BODY_ZONE_PRECISE_EYES)
		if (HAS_TRAIT(user, TRAIT_CLUMSY) && prob(CLUMSY_ATTACK_SELF_CHANCE))
			target = user

		perform_eyestab(source, target, user)

		return COMPONENT_SKIP_ATTACK

/datum/element/eyestab/proc/perform_eyestab(obj/item/item, mob/living/target, mob/living/user)
	var/obj/item/bodypart/target_limb = target.get_bodypart(BODY_ZONE_HEAD)

	if (ishuman(target) && isnull(target_limb))
		return

	if (target.is_eyes_covered())
		to_chat(user, span_warning("You failed to stab [target.p_their()] eyes, you need to remove [target.p_their()] eye protection first!"))
		return

	if (isalien(target))
		to_chat(user, span_warning("You cannot locate any eyes on this creature!"))
		return

	if (isbrain(target))
		to_chat(user, span_warning("You cannot locate any organic eyes on this brain!"))
		return

	item.add_fingerprint(user)

	playsound(item, item.hitsound, 30, TRUE, -1)

	user.do_attack_animation(target)

	if (target == user)
		user.visible_message(
			span_danger("[user] stabs [user.p_them()]self in the eyes with [item]!"),
			span_userdanger("You stab yourself in the eyes with [item]!"),
		)
	else
		target.visible_message(
			span_danger("[user] stabs [target] in the eye with [item]!"),
			span_userdanger("[user] stabs you in the eye with [item]!"),
		)

	if (target_limb)
		target.apply_damage(damage, BRUTE, target_limb)
	else
		target.take_bodypart_damage(damage)

	SEND_SIGNAL(target, COMSIG_ADD_MOOD_EVENT, "eye_stab", /datum/mood_event/eye_stab)

	log_combat(user, target, "attacked", "[item.name]", "(Combat mode: [user.combat_mode ? "On" : "Off"])")

	var/obj/item/organ/eyes/eyes = target.getorganslot(ORGAN_SLOT_EYES)
	if (!eyes)
		return

	target.adjust_blurriness(3)
	eyes.applyOrganDamage(rand(2,4))

	if(eyes.damage < EYESTAB_BLEEDING_THRESHOLD)
		return

	target.adjust_blurriness(15)
	if (target.stat != DEAD)
		to_chat(target, span_danger("Your eyes start to bleed profusely!"))

	if (!target.is_blind() && !HAS_TRAIT(target, TRAIT_NEARSIGHT))
		to_chat(target, span_danger("You become nearsighted!"))

	target.become_nearsighted(EYE_DAMAGE)

	if (prob(50))
		if (target.stat != DEAD && target.drop_all_held_items())
			to_chat(target, span_danger("You drop what you're holding and clutch at your eyes!"))
		target.adjust_blurriness(10)
		target.Unconscious(20)
		target.Paralyze(40)

	if (prob(eyes.damage - EYESTAB_BLEEDING_THRESHOLD + 1))
		target.become_blind(EYE_DAMAGE)
		to_chat(target, span_danger("You go blind!"))

#undef CLUMSY_ATTACK_SELF_CHANCE
#undef EYESTAB_BLEEDING_THRESHOLD
