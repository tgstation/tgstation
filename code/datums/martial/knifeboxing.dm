/datum/martial_art/knifeboxing
	name = "Knife-boxing"

/datum/martial_art/knifeboxing/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	to_chat(A, span_warning("Can't disarm while knife-boxing!"))
	return TRUE

/datum/martial_art/knifeboxing/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	to_chat(A, span_warning("Can't grab while knife-boxing!"))
	return TRUE

/datum/martial_art/knifeboxing/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)

	A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)

	var/atk_verb = pick("left hook","right hook","straight punch")

	var/damage = rand(8, 12) + A.get_punchdamagehigh()
	if(!damage)
		playsound(D.loc, A.dna.species.miss_sound, 25, 1, -1)
		D.visible_message(span_warning("[A] has attempted to [atk_verb] [D]!"), \
			span_userdanger("[A] has attempted to [atk_verb] [D]!"), null, COMBAT_MESSAGE_RANGE)
		log_combat(A, D, "attempted to punch (knifeboxing)")
		return FALSE

	var/obj/item/bodypart/affecting = D.get_bodypart(ran_zone(A.zone_selected))
	var/armor_block = D.run_armor_check(affecting, MELEE)

	playsound(D.loc, A.dna.species.attack_sound, 25, 1, -1)

	D.visible_message(span_danger("[A] has [atk_verb]ed [D]!"), \
			span_userdanger("[A] has [atk_verb]ed [D]!"), null, COMBAT_MESSAGE_RANGE)

	D.apply_damage(damage, BRUTE, affecting, armor_block)
	log_combat(A, D, "punched (knifeboxing")
	return TRUE
