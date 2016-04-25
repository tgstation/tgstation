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

/mob/living/carbon/attackby(obj/item/I, mob/user, params)
	if(lying)
		if(surgeries.len)
			if(user != src && user.a_intent == "help")
				for(var/datum/surgery/S in surgeries)
					if(S.next_step(user, src))
						return 1
	..()


/mob/living/carbon/attack_hand(mob/living/carbon/human/user)
	if(!iscarbon(user))
		return

	for(var/datum/disease/D in viruses)
		if(D.IsSpreadByTouch())
			user.ContractDisease(D)

	for(var/datum/disease/D in user.viruses)
		if(D.IsSpreadByTouch())
			ContractDisease(D)

	if(lying)
		if(user.a_intent == "help")
			if(surgeries.len)
				for(var/datum/surgery/S in surgeries)
					if(S.next_step(user, src))
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

/mob/living/carbon/Stun(amount, updating_canmove = 1)
	if(dna && dna.features["wings"])
		if((dna.features["wings"] == "Angel") && flying)
			flyslip(src)
			amount *= 2
	..()


/mob/living/carbon/proc/flyslip(mob/living/carbon/C)
	var/obj/buckled_obj
	if(C.buckled)
		buckled_obj = C.buckled

	C << "<span class='notice'>Your wings spazz out and launch you!</span>"

	playsound(C.loc, 'sound/misc/slip.ogg', 50, 1, -3)

	C.accident(C.l_hand)
	C.accident(C.r_hand)

	var/olddir = C.dir

	C.stop_pulling()
	if(buckled_obj)
		buckled_obj.unbuckle_mob(C)
		step(buckled_obj, olddir)
	else
		for(var/i=1, i<5, i++)
			spawn (i)
				step(C, olddir)
				C.spin(1,1)
	return 1