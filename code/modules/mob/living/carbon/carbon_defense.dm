/mob/living/carbon/hitby(atom/movable/AM, skip)
	if(!skip)	//ugly, but easy
		if(in_throw_mode && !get_active_hand())	//empty active hand and we're in throw mode
			if(canmove && !restrained())
				if(istype(AM, /obj/item))
					var/obj/item/I = AM
					if(isturf(I.loc))
						put_in_active_hand(I)
						visible_message("<span class='warning'>[src] catches [I]!</span>")
						throw_mode_off()
						return
	..()


/mob/living/carbon/attackby(obj/item/I, mob/user)
	if(lying || isslime(src))
		if(surgeries.len)
			if(user.a_intent == "help")
				for(var/datum/surgery/S in surgeries)
					if(S.next_step(user, src))
						return 1
	..()


/mob/living/carbon/attack_hand(mob/living/carbon/human/user)
	if(!iscarbon(user))
		return

	for(var/datum/disease/D in viruses)
		if(D.spread_by_touch())
			user.contract_disease(D, 0, 1, CONTACT_HANDS)

	for(var/datum/disease/D in user.viruses)
		if(D.spread_by_touch())
			contract_disease(D, 0, 1, CONTACT_HANDS)

	if(lying || isslime(src))
		if(user.a_intent == "help")
			if(surgeries.len)
				for(var/datum/surgery/S in surgeries)
					if(S.next_step(user, src))
						return 1
	if(..())
		switch(user.a_intent)
			if("help")
				help_shake_act(user)
			if("grab")
				grabbedby(user)

	return 0


/mob/living/carbon/attack_paw(mob/living/carbon/monkey/M as mob)
	if(!istype(M, /mob/living/carbon))
		return 0

	for(var/datum/disease/D in viruses)
		if(D.spread_by_touch())
			M.contract_disease(D, 0, 1, CONTACT_HANDS)

	for(var/datum/disease/D in M.viruses)
		if(D.spread_by_touch())
			contract_disease(D, 0, 1, CONTACT_HANDS)

	if(..())
		for(var/datum/disease/D in M.viruses)
			contract_disease(D,1,0)
		return 1

	if(M.a_intent == "help")
		help_shake_act(M)
	return 0


/mob/living/carbon/attack_slime(mob/living/carbon/slime/M)
	if(..())
		var/power = M.powerlevel + rand(0,3)
		Weaken(power)
		if (stuttering < power)
			stuttering = power
		Stun(power)
		var/stunprob = M.powerlevel * 7 + 10
		if (prob(stunprob) && M.powerlevel >= 8)
			adjustFireLoss(M.powerlevel * rand(6,10))
			updatehealth()
		return 1
