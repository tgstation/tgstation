/datum/attack_style/unarmed/generic_damage/boxing
	attack_type = STAMINA
	bonus_stamina_damage_modifier = 0

/datum/attack_style/unarmed/generic_damage/boxing/select_attack_verb(mob/living/attacker, mob/living/smacked, damage)
	return pick("left hook", "right hook", "straight punch")

/datum/attack_style/unarmed/generic_damage/boxing/actually_apply_damage(mob/living/attacker, mob/living/smacked, damage, affecting, armor_block)
	. = ..()
	var/smacked_stam = smacked.getStaminaLoss()
	if(smacked.stat == DEAD || smacked_stam <= 50)
		return
	if(!istype(smacked.mind?.martial_art, /datum/martial_art/boxing))
		return

	var/knockout_prob = smacked_stam + rand(-15, 15)
	if(prob(knockout_prob))
		smacked.visible_message(
			span_danger("[attacker] knocks [smacked] out with a haymaker!"),
			span_userdanger("You're knocked unconscious by [attacker]!"),
			span_hear("You hear a sickening sound of flesh hitting flesh!"),
			vision_distance = COMBAT_MESSAGE_RANGE,
			ignored_mobs = attacker,
		)
		to_chat(attacker, span_danger("You knock [smacked] out with a haymaker!"))
		smacked.apply_effect(20 SECONDS, EFFECT_KNOCKDOWN, armor_block)
		smacked.apply_effect(10 SECONDS, EFFECT_UNCONSCIOUS, armor_block)
		log_combat(attacker, smacked, "knocked out (boxing)")

/datum/martial_art/boxing
	name = "Boxing"
	id = MARTIALART_BOXING
	pacifist_style = TRUE

/datum/martial_art/boxing/disarm_act(mob/living/attacker, mob/living/defender)
	return MARTIAL_ATTACK_FAIL

/datum/martial_art/boxing/grab_act(mob/living/attacker, mob/living/defender)
	defender.balloon_alert(attacker, "can't grab while boxing!")
	return MARTIAL_ATTACK_FAIL

/datum/martial_art/boxing/harm_act(mob/living/attacker, mob/living/defender)
	var/datum/attack_style/unarmed/give_them_the_heat = GLOB.attack_styles[/datum/attack_style/unarmed/generic_damage/boxing]
	if(give_them_the_heat.process_attack(attacker, null, defender) & ATTACK_HIT)
		return MARTIAL_ATTACK_SUCCESS

	return MARTIAL_ATTACK_FAIL

/datum/martial_art/boxing/can_use(mob/living/owner)
	if(!ishuman(owner))
		return FALSE
	return ..()

/obj/item/clothing/gloves/boxing
	var/datum/martial_art/boxing/style = new

/obj/item/clothing/gloves/boxing/equipped(mob/user, slot)
	..()
	// boxing requires human
	if(!ishuman(user))
		return
	if(slot & ITEM_SLOT_GLOVES)
		var/mob/living/student = user
		style.teach(student, 1)

/obj/item/clothing/gloves/boxing/dropped(mob/user)
	..()
	if(!ishuman(user))
		return
	var/mob/living/owner = user
	style.remove(owner)
