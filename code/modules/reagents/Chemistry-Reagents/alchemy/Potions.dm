// it's magic i aint gotta explain shit

/datum/reagent/alchemy/bezerkers_rage
	name = "Bezerker's Rage"
	id = "bezerkers_rage"
	description = ""
	reagent_state = SOLID
	color = "#673910" // rgb: 103, 57, 16

/datum/reagent/alchemy/bezerkers_rage/on_mob_life(var/mob/living/M as mob)
	M.adjustFireLoss(0.1)
	if(isturf(M.loc) && !istype(M.loc, /turf/space))
		if(M.canmove)
			if(prob(30)) step(M, pick(cardinal))
	M.hallucination = max(M.hallucination, 5)
	M.druggy = max(M.druggy, 15) // TODO: REPLACE WITH RED ANGRY SCREEN OVERLAY
	M.status_flags |= INCREASEDAMAGE
	..()

/datum/reagent/alchemy/endurance_feat
	name = "Feat of Endurance"
	id = "endurance_feat"
	description = ""
	reagent_state = SOLID
	color = "#673910" // rgb: 103, 57, 16

/datum/reagent/alchemy/endurance_feat/on_mob_life(var/mob/living/M as mob)
	M.adjustToxLoss(1)
	M.adjustStaminaLoss(-5)
	M.status_flags |= GOTTAGOFAST
	..()
