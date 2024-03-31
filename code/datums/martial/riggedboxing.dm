/datum/martial_art/riggedboxing
	name = "Rigged-boxing"

/datum/martial_art/riggedboxing/disarm_act(mob/living/carbon/human/attacker, mob/living/defender)
	return

/datum/martial_art/riggedboxing/grab_act(mob/living/carbon/human/attacker, mob/living/defender)
	return

/datum/martial_art/riggedboxing/harm_act(mob/living/carbon/human/attacker, mob/living/defender)
	var/obj/item/bodypart/arm/active_arm = attacker.get_active_hand()
	attacker.do_attack_animation(defender, ATTACK_EFFECT_PUNCH)

	var/damage = rand(10, 20) + active_arm.unarmed_damage_low
	var/atk_verb = pick("left hook", "right hook", "straight punch")
	if(damage <= 0)
		playsound(defender, active_arm.unarmed_miss_sound, 25, TRUE, -1)
		defender.visible_message(
			span_warning("[attacker]'s [atk_verb] misses [defender]!"),
			span_danger("You avoid [attacker]'s [atk_verb]!"),
			span_hear("You hear a swoosh!"),
			COMBAT_MESSAGE_RANGE,
			attacker,
		)
		to_chat(attacker, span_warning("Your [atk_verb] misses [defender]!"))
		log_combat(attacker, defender, "attempted to hit", atk_verb)
		return MARTIAL_ATTACK_FAIL

	if(defender.check_block(attacker, damage, "[attacker]'s [atk_verb]", UNARMED_ATTACK))
		return MARTIAL_ATTACK_FAIL

	var/obj/item/bodypart/affecting = defender.get_bodypart(defender.get_random_valid_zone(attacker.zone_selected))
	var/armor_block = defender.run_armor_check(affecting, MELEE)

	playsound(defender, active_arm.unarmed_attack_sound, 25, TRUE, -1)
	defender.visible_message(
		span_danger("[attacker] [atk_verb]ed [defender]!"),
		span_userdanger("You're [atk_verb]ed by [attacker]!"),
		span_hear("You hear a sickening sound of flesh hitting flesh!"),
		COMBAT_MESSAGE_RANGE,
		attacker,
	)
	to_chat(attacker, span_danger("You [atk_verb]ed [defender]!"))
	defender.apply_damage(damage, STAMINA, affecting, armor_block)
	log_combat(attacker, defender, "punched (riggedboxing) ")
	if(defender.getStaminaLoss() > 50 && (istype(defender.mind?.martial_art, /datum/martial_art/boxing) || istype(defender.mind?.martial_art, /datum/martial_art/riggedboxing)))
		var/knockout_prob = defender.getStaminaLoss() + rand(-15, 15)
		if(defender.stat != DEAD && prob(knockout_prob))
			defender.visible_message(
				span_danger("[attacker] knocks [defender] out with a haymaker!"),
				span_userdanger("You're knocked unconscious by [attacker]!"),
				span_hear("You hear a sickening sound of flesh hitting flesh!"),
				COMBAT_MESSAGE_RANGE,
				attacker,
			)
			to_chat(attacker, span_danger("You knock [defender] out with a haymaker!"))
			defender.apply_effect(20 SECONDS, EFFECT_KNOCKDOWN, armor_block)
			defender.SetSleeping(10 SECONDS)
			log_combat(attacker, defender, "knocked out (riggedboxing) ")
	return MARTIAL_ATTACK_SUCCESS

/datum/martial_art/riggedboxing/can_use(mob/living/martial_artist)
	if(!ishuman(martial_artist))
		return FALSE
	return ..()