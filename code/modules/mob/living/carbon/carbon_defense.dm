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