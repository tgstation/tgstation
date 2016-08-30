/mob/living/carbon/hitby(atom/movable/AM, skipcatch, hitpush = 1, blocked = 0)
	if(!skipcatch)	//ugly, but easy
		if(in_throw_mode && !get_active_hand())	//empty active hand and we're in throw mode
			if(canmove && !restrained())
				if(istype(AM, /obj/item))
					var/obj/item/I = AM
					if(isturf(I.loc))
						put_in_active_hand(I)
						visible_message("<span class='warning'>[src] catches [I]!</span>")
						throw_mode_off()
						return 1
	..()

/mob/living/carbon/throw_impact(atom/hit_atom)
	. = ..()
	if(hit_atom.density && isturf(hit_atom))
		Weaken(1)
		take_organ_damage(10)
	if(iscarbon(hit_atom))
		var/mob/living/carbon/victim = hit_atom
		victim.Weaken(1)
		Weaken(1)
		victim.take_organ_damage(10)
		take_organ_damage(10)
		visible_message("<span class='danger'>[src] crashes into [victim], knocking them both over!</span>", "<span class='userdanger'>You violently crash into [victim]!</span>")
		playsound(src,'sound/weapons/punch1.ogg',50,1)

/mob/living/carbon/attackby(obj/item/I, mob/user, params)
	if(lying && surgeries.len)
		if(user != src && user.a_intent == "help")
			for(var/datum/surgery/S in surgeries)
				if(S.next_step(user))
					return 1
	return ..()


/mob/living/carbon/attack_hand(mob/living/carbon/human/user)
	if(!iscarbon(user))
		return

	for(var/datum/disease/D in viruses)
		if(D.IsSpreadByTouch())
			user.ContractDisease(D)

	for(var/datum/disease/D in user.viruses)
		if(D.IsSpreadByTouch())
			ContractDisease(D)

	if(lying && surgeries.len)
		if(user.a_intent == "help")
			for(var/datum/surgery/S in surgeries)
				if(S.next_step(user))
					return 1
	return 0


/mob/living/carbon/attack_paw(mob/living/carbon/monkey/M)
	if(!istype(M, /mob/living/carbon))
		return 0

	for(var/datum/disease/D in viruses)
		if(D.IsSpreadByTouch())
			M.ContractDisease(D)

	for(var/datum/disease/D in M.viruses)
		if(D.IsSpreadByTouch())
			ContractDisease(D)

	if(M.a_intent == "help")
		help_shake_act(M)
		return 0

	if(..()) //successful monkey bite.
		for(var/datum/disease/D in M.viruses)
			ForceContractDisease(D)
		return 1


/mob/living/carbon/attack_slime(mob/living/simple_animal/slime/M)
	if(..()) //successful slime attack
		if(M.powerlevel > 0)
			var/stunprob = M.powerlevel * 7 + 10  // 17 at level 1, 80 at level 10
			if(prob(stunprob))
				M.powerlevel -= 3
				if(M.powerlevel < 0)
					M.powerlevel = 0

				visible_message("<span class='danger'>The [M.name] has shocked [src]!</span>", \
				"<span class='userdanger'>The [M.name] has shocked [src]!</span>")

				var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
				s.set_up(5, 1, src)
				s.start()
				var/power = M.powerlevel + rand(0,3)
				Weaken(power)
				if(stuttering < power)
					stuttering = power
				Stun(power)
				if (prob(stunprob) && M.powerlevel >= 8)
					adjustFireLoss(M.powerlevel * rand(6,10))
					updatehealth()
		return 1

/mob/living/carbon/proc/devour_mob(mob/living/carbon/C, devour_time = 130)
	C.visible_message("<span class='danger'>[src] is attempting to devour [C]!</span>", \
					"<span class='userdanger'>[src] is attempting to devour you!</span>")
	if(!do_mob(src, C, devour_time))
		return
	if(pulling && pulling == C && grab_state >= GRAB_AGGRESSIVE && a_intent == "grab")
		C.visible_message("<span class='danger'>[src] devours [C]!</span>", \
						"<span class='userdanger'>[src] devours you!</span>")
		C.forceMove(src)
		stomach_contents.Add(C)
		add_logs(src, C, "devoured")

/mob/living/carbon/proc/dismembering_strike(mob/living/attacker, dam_zone)
	if(!attacker.limb_destroyer || !has_limbs)
		return dam_zone
	var/obj/item/bodypart/affecting
	if(dam_zone && attacker.client)
		affecting = get_bodypart(ran_zone(dam_zone))
	else
		var/list/things_to_ruin = shuffle(bodyparts.Copy())
		for(var/B in things_to_ruin)
			var/obj/item/bodypart/bodypart = B
			if(bodypart.body_zone == "head" || bodypart.body_zone == "chest")
				continue
			if(!affecting || ((affecting.get_damage() / affecting.max_damage) < (bodypart.get_damage() / bodypart.max_damage)))
				affecting = bodypart
	if(affecting)
		dam_zone = affecting.body_zone
		if(affecting.get_damage() >= affecting.max_damage)
			affecting.dismember()
			return null
		return affecting.body_zone
	return dam_zone
