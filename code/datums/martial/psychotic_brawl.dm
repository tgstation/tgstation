/datum/martial_art/psychotic_brawling
	name = "Psychotic Brawling"
	id = MARTIALART_PSYCHOBRAWL

/datum/martial_art/psychotic_brawling/disarm_act(mob/living/A, mob/living/D)
	return psycho_attack(A,D)

/datum/martial_art/psychotic_brawling/grab_act(mob/living/A, mob/living/D)
	return psycho_attack(A,D, TRUE)

/datum/martial_art/psychotic_brawling/harm_act(mob/living/A, mob/living/D)
	return psycho_attack(A,D)

/datum/martial_art/psychotic_brawling/proc/psycho_attack(mob/living/A, mob/living/D, grab_attack)
	var/atk_verb
	switch(rand(1,8))
		if(1)
			if (iscarbon(D) && iscarbon(A))
				var/mob/living/carbon/defender = D
				defender.help_shake_act(A)
			atk_verb = "helped"
		if(2)
			A.emote("cry")
			A.Stun(20)
			atk_verb = "cried looking at"
		if(3)
			if(A.grab_state >= GRAB_AGGRESSIVE)
				D.grabbedby(A, 1)
			else
				A.start_pulling(D, supress_message = TRUE)
				if(A.pulling)
					D.drop_all_held_items()
					D.stop_pulling()
					if(grab_attack)
						log_combat(A, D, "grabbed", addition="aggressively")
						D.visible_message(span_warning("[A] violently grabs [D]!"), \
										span_userdanger("You're violently grabbed by [A]!"), span_hear("You hear sounds of aggressive fondling!"), null, A)
						to_chat(A, span_danger("You violently grab [D]!"))
						A.setGrabState(GRAB_AGGRESSIVE) //Instant aggressive grab
					else
						log_combat(A, D, "grabbed", addition="passively")
						A.setGrabState(GRAB_PASSIVE)
		if(4)
			A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
			atk_verb = "headbutt"
			D.visible_message(span_danger("[A] [atk_verb]s [D]!"), \
							span_userdanger("You're [atk_verb]ed by [A]!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), null, A)
			to_chat(A, span_danger("You [atk_verb] [D]!"))
			playsound(get_turf(D), 'sound/weapons/punch1.ogg', 40, TRUE, -1)
			D.apply_damage(rand(5,10), A.get_attack_type(), BODY_ZONE_HEAD)
			A.apply_damage(rand(5,10), A.get_attack_type(), BODY_ZONE_HEAD)
			if (iscarbon(D))
				var/mob/living/carbon/defender = D
				if(!istype(defender.head,/obj/item/clothing/head/helmet/) && !istype(defender.head,/obj/item/clothing/head/utility/hardhat))
					defender.adjustOrganLoss(ORGAN_SLOT_BRAIN, 5)
			A.Stun(rand(10,45))
			D.Stun(rand(5,30))
		if(5,6)
			A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
			atk_verb = pick("kick", "hit", "slam")
			D.visible_message(span_danger("[A] [atk_verb]s [D] with such inhuman strength that it sends [D.p_them()] flying backwards!"), \
							span_userdanger("You're [atk_verb]ed by [A] with such inhuman strength that it sends you flying backwards!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), null, A)
			to_chat(A, span_danger("You [atk_verb] [D] with such inhuman strength that it sends [D.p_them()] flying backwards!"))
			D.apply_damage(rand(15,30), A.get_attack_type())
			playsound(get_turf(D), 'sound/effects/meteorimpact.ogg', 25, TRUE, -1)
			var/throwtarget = get_edge_target_turf(A, get_dir(A, get_step_away(D, A)))
			D.throw_at(throwtarget, 4, 2, A)//So stuff gets tossed around at the same time.
			D.Paralyze(60)
		if(7,8)
			return FALSE //Resume default behaviour

	if(atk_verb)
		log_combat(A, D, "[atk_verb] (Psychotic Brawling)")
	return TRUE
