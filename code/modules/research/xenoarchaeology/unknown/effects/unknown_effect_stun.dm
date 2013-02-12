
/datum/artifact_effect/stun
	effecttype = "stun"

/datum/artifact_effect/stun/DoEffectTouch(var/mob/user)
	if(user)
		if (istype(user, /mob/living/carbon/))
			user << "\red A powerful force overwhelms your consciousness."
			user.weakened += 45
			user.stuttering += 45
			user.stunned += rand(1,10)
			return 1

/datum/artifact_effect/stun/DoEffectAura()
	if(holder)
		for (var/mob/living/carbon/M in range(src.effectrange,holder))
			if(ishuman(M) && istype(M:wear_suit,/obj/item/clothing/suit/bio_suit/anomaly) && istype(M:head,/obj/item/clothing/head/bio_hood/anomaly))
				continue
			if(prob(10)) M << "\red You feel numb."
			if(prob(20))
				M << "\red Your body goes numb for a moment."
				M.weakened += 2
				M.stuttering += 2
				if(prob(10))
					M.stunned += 1
		return 1

/datum/artifact_effect/stun/DoEffectPulse()
	if(holder)
		for (var/mob/living/carbon/M in range(src.effectrange,holder))
			if(ishuman(M) && istype(M:wear_suit,/obj/item/clothing/suit/bio_suit/anomaly) && istype(M:head,/obj/item/clothing/head/bio_hood/anomaly))
				continue
			M << "\red A wave of energy overwhelms your senses!"
			M.weakened += 4
			M.stuttering += 4
			if(prob(10))
				M.stunned += 1
		return 1
