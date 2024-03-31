/datum/martial_art/knifeboxing
	name = "Knife-boxing"

/datum/martial_art/knifeboxing/teach(mob/living/new_holder, make_temporary)
	if(!ishuman(new_holder))
		return FALSE
	return ..()

/datum/martial_art/knifeboxing/disarm_act(mob/living/carbon/human/attacker, mob/living/defender)
	to_chat(attacker, span_warning("Can't disarm while knife-boxing!"))
	return MARTIAL_ATTACK_FAIL

/datum/martial_art/knifeboxing/grab_act(mob/living/carbon/human/attacker, mob/living/defender)
	to_chat(attacker, span_warning("Can't grab while knife-boxing!"))
	return MARTIAL_ATTACK_FAIL

/datum/martial_art/knifeboxing/harm_act(mob/living/carbon/human/attacker, mob/living/defender)

	attacker.do_attack_animation(defender, ATTACK_EFFECT_PUNCH)
	var/obj/item/bodypart/arm/active_arm = attacker.get_active_hand()

	var/atk_verb = pick("left hook","right hook","straight punch")

	var/damage = rand(8, 12) + active_arm.unarmed_damage_low
	if(!damage)
		playsound(defender.loc, active_arm.unarmed_miss_sound, 25, 1, -1)
		defender.visible_message(span_warning("[attacker] has attempted to [atk_verb] [defender]!"), \
			span_userdanger("[attacker] has attempted to [atk_verb] [defender]!"), null, COMBAT_MESSAGE_RANGE)
		log_combat(attacker, defender, "attempted to punch (knifeboxing)")
		return FALSE

	var/obj/item/bodypart/affecting = defender.get_bodypart(ran_zone(attacker.zone_selected))
	var/armor_block = defender.run_armor_check(affecting, MELEE)

	playsound(defender.loc, active_arm.unarmed_attack_sound, 25, 1, -1)

	defender.visible_message(span_danger("[attacker] has [atk_verb]ed [defender]!"), \
			span_userdanger("[attacker] has [atk_verb]ed [defender]!"), null, COMBAT_MESSAGE_RANGE)

	defender.apply_damage(damage, BRUTE, affecting, armor_block)
	log_combat(attacker, defender, "punched (knifeboxing")
	return TRUE
