/datum/disease/shock
	name = "Shock"
	form = "Serious medical complication"
	max_stages = 4
	stage_prob = 1
	spread_text = "Medical complication"
	spread_flags = NON_CONTAGIOUS
	cure_text = "Epinephrine and restoring blood count"
	cures = list("salglu_solution")
	agent = ""
	viable_mobtypes = list(/mob/living/carbon/human,/mob/living/carbon/monkey)
	desc = "The patient has been subjected to extreme pain, substantial bloodloss, or acutely traumatic events. Their condition will rapidly deteriorate unless treated quickly."
	severity = DANGEROUS
	disease_flags = CURABLE|CAN_CARRY


/datum/disease/shock/stage_act()
	var/cure = has_cure()
	var/blood_level = 560

	stage = min(stage, max_stages)

	if(istype(affected_mob, /mob/living/carbon))
		var/mob/living/carbon/C = affected_mob
		if(istype(affected_mob, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = C
			blood_level = H.vessel.get_reagent_amount("blood")

	if(!cure)
		if(prob((560-blood_level)/35))
			stage = min(stage + 1,max_stages)
			affected_mob << "You are now in stage [stage] shock."
	else
		if(prob(cure_chance))
			stage = max(stage - 1, 1)

	if(disease_flags & CURABLE)
		if(cure && prob(cure_chance))
			cure()


	affected_mob << "Odds to descend levels is [(560-blood_level)/35]."
	if(blood_level > 520)
		affected_mob << "<span class='notice'>You feel better now.</span>"
		cure()
		return


	switch(stage)
		if(1)
			if(prob(5))
				affected_mob.emote("pale")
			if(prob(3))
				affected_mob << "<span class='warning'>You feel numb...</span>"
			if((affected_mob.lying || affected_mob.reagents.has_reagent("epinephrine")) && prob(10))
				affected_mob << "<span class='notice'>You feel better now.</span>"
				cure()
				return
		if(2)
			if(prob(5))
				affected_mob.emote("pale")
			if((affected_mob.lying || affected_mob.reagents.has_reagent("epinephrine")) && prob(10))
				affected_mob << "<span class='notice'>You feel a little better now.</span>"
				stage--
			if(prob(3))
				affected_mob << "<span class='warning'>You feel numb...</span>"
			if(prob(3))
				affected_mob.visible_message("<span class='danger'>[affected_mob] stumbles around dizzily.</span>", \
								"<span class='userdanger'>Your head spins as you try to stay on your feet.</span>")
				affected_mob.confused = 5
				affected_mob.Jitter(8)
		if(3)
			if(prob(5))
				affected_mob.emote("pale", "sway")
			if(affected_mob.reagents.has_reagent("epinephrine") && prob(10))
				affected_mob << "<span class='notice'>You feel a little better now.</span>"
				stage--
			if(prob(7))
				affected_mob << "<span class='warning'>You can't feel anything...</span>"
			if(prob(4))
				affected_mob << "<span class='danger'>You can't breathe!</span>"
				affected_mob.losebreath += 6
				affected_mob.updatehealth()
			if(prob(3) && !affected_mob.reagents.has_reagent("epinephrine"))
				affected_mob.visible_message("<span class='danger'>[affected_mob] passes out!</span>", \
												"<span class='userdanger'>You pass out!</span>")
				affected_mob.Sleeping(rand(6, 10))
			if(prob(5))
				affected_mob.visible_message("<span class='danger'>[affected_mob] stumbles around dizzily.</span>", \
								"<span class='userdanger'>Your head spins wildly as you try to stay on your feet.</span>")
				affected_mob.confused = 8
				affected_mob.Jitter(8)
		if(4)
			if(prob(5))
				affected_mob.emote("pale", "sway")
			if(affected_mob.reagents.has_reagent("epinephrine") && prob(10))
				affected_mob << "<span class='notice'>You feel a little better now.</span>"
				stage--
			if(prob(5) && !affected_mob.reagents.has_reagent("epinephrine"))
				affected_mob.visible_message("<span class='danger'>[affected_mob] passes out!</span>", \
												"<span class='userdanger'>You pass out!</span>")
				affected_mob.Sleeping(rand(6,10))
			if(prob(5))
				affected_mob << "<span class='danger'>You can't breathe!</span>"
				affected_mob.losebreath += 8
				affected_mob.adjustOxyLoss(8)
				affected_mob.updatehealth()
			if(prob(1))
				affected_mob.visible_message("<span class='danger'>[affected_mob] clutches at their chest!</span>", \
													"<span class='userdanger'>You feel a sharp pain in your chest!</span>")
				affected_mob.losebreath += 10 //lol how 2 heart attak
				affected_mob.adjustOxyLoss(20)
				affected_mob.updatehealth()
	return

