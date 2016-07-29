<<<<<<< HEAD
/datum/disease/beesease
	name = "Beesease"
	form = "Infection"
	max_stages = 4
	spread_text = "On contact"
	spread_flags = CONTACT_GENERAL
	cure_text = "Sugar"
	cures = list("sugar")
	agent = "Apidae Infection"
	viable_mobtypes = list(/mob/living/carbon/human,/mob/living/carbon/monkey)
	desc = "If left untreated subject will regurgitate bees."
	severity = DANGEROUS

/datum/disease/beesease/stage_act()
	..()
	switch(stage)
		if(2) //also changes say, see say.dm
			if(prob(2))
				affected_mob << "<span class='notice'>You taste honey in your mouth.</span>"
		if(3)
			if(prob(10))
				affected_mob << "<span class='notice'>Your stomach rumbles.</span>"
			if(prob(2))
				affected_mob << "<span class='danger'>Your stomach stings painfully.</span>"
				if(prob(20))
					affected_mob.adjustToxLoss(2)
					affected_mob.updatehealth()
		if(4)
			if(prob(10))
				affected_mob.visible_message("<span class='danger'>[affected_mob] buzzes.</span>", \
												"<span class='userdanger'>Your stomach buzzes violently!</span>")
			if(prob(5))
				affected_mob << "<span class='danger'>You feel something moving in your throat.</span>"
			if(prob(1))
				affected_mob.visible_message("<span class='danger'>[affected_mob] coughs up a swarm of bees!</span>", \
													"<span class='userdanger'>You cough up a swarm of bees!</span>")
				new /mob/living/simple_animal/hostile/poison/bees(affected_mob.loc)
		//if(5)
		//Plus if you die, you explode into bees
	return
=======
/*
/datum/disease/beesease
	name = "Beesease"
	max_stages = 5
	spread = "Contact" //ie shot bees
	cure = "???"
	cure_id = "???"
	agent = "Bees"
	affected_species = list("Human","Monkey")
	curable = 0

/datum/disease/beesease/stage_act()
	..()
	switch(stage)
		if(1)
			if(prob(2))
				to_chat(affected_mob, "<span class='warning'>You feel like something is moving inside of you</span>")
		if(2) //also changes say, see say.dm
			if(prob(2))
				to_chat(affected_mob, "<span class='warning'>You feel like something is moving inside of you</span>")
			if(prob(2))
				to_chat(affected_mob, "<span class='warning'>BZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ</span>")
		if(3)
		//Should give the bee spit verb
		if(4)
		//Plus bees now spit randomly
		if(5)
		//Plus if you die, you explode into bees
	return
*/
//Started working on it, but am too lazy to finish it today -- Urist
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
