/datum/martial_art/boxing
	name = "Boxing"
	id = MARTIALART_BOXING
	pacifist_style = TRUE

/datum/martial_art/boxing/disarm_act(mob/living/A, mob/living/D)
	to_chat(A, span_warning("Can't disarm while boxing!"))
	return TRUE

/datum/martial_art/boxing/grab_act(mob/living/A, mob/living/D)
	to_chat(A, span_warning("Can't grab while boxing!"))
	return TRUE

/datum/martial_art/boxing/harm_act(mob/living/A, mob/living/D)

	var/mob/living/carbon/human/attacker_human = A
	var/obj/item/bodypart/arm/active_arm = attacker_human.get_active_hand()

	A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)

	var/atk_verb = pick("left hook","right hook","straight punch")

	var/damage = rand(5, 8) + active_arm.unarmed_damage_low
	if(!damage)
		playsound(D.loc, active_arm.unarmed_miss_sound, 25, TRUE, -1)
		D.visible_message(span_warning("[A]'s [atk_verb] misses [D]!"), \
						span_danger("You avoid [A]'s [atk_verb]!"), span_hear("You hear a swoosh!"), COMBAT_MESSAGE_RANGE, A)
		to_chat(A, span_warning("Your [atk_verb] misses [D]!"))
		log_combat(A, D, "attempted to hit", atk_verb)
		return FALSE


	var/obj/item/bodypart/affecting = D.get_bodypart(D.get_random_valid_zone(A.zone_selected))
	var/armor_block = D.run_armor_check(affecting, MELEE)

	playsound(D.loc, active_arm.unarmed_attack_sound, 25, TRUE, -1)

	D.visible_message(span_danger("[A] [atk_verb]ed [D]!"), \
					span_userdanger("You're [atk_verb]ed by [A]!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), COMBAT_MESSAGE_RANGE, A)
	to_chat(A, span_danger("You [atk_verb]ed [D]!"))

	D.apply_damage(damage, STAMINA, affecting, armor_block)
	log_combat(A, D, "punched (boxing) ")
	if(D.getStaminaLoss() > 50 && istype(D.mind?.martial_art, /datum/martial_art/boxing))
		var/knockout_prob = D.getStaminaLoss() + rand(-15,15)
		if((D.stat != DEAD) && prob(knockout_prob))
			D.visible_message(span_danger("[A] knocks [D] out with a haymaker!"), \
							span_userdanger("You're knocked unconscious by [A]!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), COMBAT_MESSAGE_RANGE, A)
			to_chat(A, span_danger("You knock [D] out with a haymaker!"))
			D.apply_effect(20 SECONDS,EFFECT_KNOCKDOWN,armor_block)
			D.SetSleeping(10 SECONDS)
			log_combat(A, D, "knocked out (boxing) ")
	return TRUE

/datum/martial_art/boxing/can_use(mob/living/owner)
	if (!ishuman(owner))
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
