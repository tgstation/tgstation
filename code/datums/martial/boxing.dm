/datum/martial_art/boxing
	name = "Boxing"
	id = MARTIALART_BOXING

/datum/martial_art/boxing/disarm_act(mob/living/A, mob/living/D)
	to_chat(A, "<span class='warning'>Can't disarm while boxing!</span>")
	return TRUE

/datum/martial_art/boxing/grab_act(mob/living/A, mob/living/D)
	to_chat(A, "<span class='warning'>Can't grab while boxing!</span>")
	return TRUE

/datum/martial_art/boxing/harm_act(mob/living/A, mob/living/D)

	var/mob/living/carbon/human/attacker_human = A
	var/datum/species/species = attacker_human.dna.species

	A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)

	var/atk_verb = pick("left hook","right hook","straight punch")

	var/damage = rand(5, 8) + species.punchdamagelow
	if(!damage)
		playsound(D.loc, species.miss_sound, 25, TRUE, -1)
		D.visible_message("<span class='warning'>[A]'s [atk_verb] misses [D]!</span>", \
						"<span class='danger'>You avoid [A]'s [atk_verb]!</span>", "<span class='hear'>You hear a swoosh!</span>", COMBAT_MESSAGE_RANGE, A)
		to_chat(A, "<span class='warning'>Your [atk_verb] misses [D]!</span>")
		log_combat(A, D, "attempted to hit", atk_verb)
		return FALSE


	var/obj/item/bodypart/affecting = D.get_bodypart(ran_zone(A.zone_selected))
	var/armor_block = D.run_armor_check(affecting, MELEE)

	playsound(D.loc, species.attack_sound, 25, TRUE, -1)

	D.visible_message("<span class='danger'>[A] [atk_verb]ed [D]!</span>", \
					"<span class='userdanger'>You're [atk_verb]ed by [A]!</span>", "<span class='hear'>You hear a sickening sound of flesh hitting flesh!</span>", COMBAT_MESSAGE_RANGE, A)
	to_chat(A, "<span class='danger'>You [atk_verb]ed [D]!</span>")

	D.apply_damage(damage, STAMINA, affecting, armor_block)
	log_combat(A, D, "punched (boxing) ")
	if(D.getStaminaLoss() > 50 && istype(D.mind?.martial_art, /datum/martial_art/boxing))
		var/knockout_prob = D.getStaminaLoss() + rand(-15,15)
		if((D.stat != DEAD) && prob(knockout_prob))
			D.visible_message("<span class='danger'>[A] knocks [D] out with a haymaker!</span>", \
							"<span class='userdanger'>You're knocked unconscious by [A]!</span>", "<span class='hear'>You hear a sickening sound of flesh hitting flesh!</span>", COMBAT_MESSAGE_RANGE, A)
			to_chat(A, "<span class='danger'>You knock [D] out with a haymaker!</span>")
			D.apply_effect(200,EFFECT_KNOCKDOWN,armor_block)
			D.SetSleeping(100)
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
	if(slot == ITEM_SLOT_GLOVES)
		var/mob/living/student = user
		style.teach(student, 1)

/obj/item/clothing/gloves/boxing/dropped(mob/user)
	..()
	if(!ishuman(user))
		return
	var/mob/living/owner = user
	style.remove(owner)
