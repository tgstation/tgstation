/datum/disease/cluwnification
	name = "Anomalous Clown Retrovirus"
	form = "Infection"
	max_stages = 5
	stage_prob = 2
	cure_text = "A small mix of nothing" // heh
	cures = list("nothing")
	agent = "Fury from the circus of hell itself."
	viable_mobtypes = list(/mob/living/carbon/human)
	desc = "Subject will become dizzy, confused and steadily more retarded before being turned into a cluwne!"
	severity = DISEASE_SEVERITY_BIOHAZARD
	bypasses_immunity = TRUE

/datum/disease/cluwnification/stage_act()
	..()
	switch(stage)
		if(1)
			if(prob(2))
				to_chat(affected_mob, "<span class='danger'>You feel a little silly.</span>")
			if(prob(2))
				to_chat(affected_mob, "<span class='danger'>Your head feels funny.</span>")
		if(2)
			if(prob(2))
				to_chat(affected_mob, "<span class='danger'>You hear honking.</span>")
				playsound(affected_mob, 'sound/items/bikehorn.ogg', 30, FALSE)
			if(prob(2))
				to_chat(affected_mob, "<span class='danger'>Your head starts to spin.</span>")
				affected_mob.confused += 5

		if(3)
			if(prob(5))
				to_chat(affected_mob, "<span class='danger'>Your mind starts to slip.</span>")
				affected_mob.set_drugginess(5)
			if(prob(2))
				to_chat(affected_mob, "<span class='danger'>Your can feel your brain startng to break down.</span>")
				affected_mob.adjustBrainLoss(3)
				affected_mob.updatehealth()
			if(prob(5))
				to_chat(affected_mob, "<span class='danger'>Your head starts to spin.</span>")
				affected_mob.confused += 5
		if(4)
			if(prob(10))
				to_chat(affected_mob, "<span class='danger'>OH GOD THE HONKING!!</span>")
				playsound(affected_mob, 'sound/items/bikehorn.ogg', 50, FALSE)
			if(prob(10))
				to_chat(affected_mob, "<span class='danger'>Your brain feels like its being ripped apart.</span>")
				affected_mob.adjustBrainLoss(10)
				affected_mob.updatehealth()
			if(prob(15))
				affected_mob.say( pick( list("HONK!", "Honk!", "Honk.", "Honk?", "Honk!!", "Honk?!", "Honk...") ) )
			if(prob(10))
				to_chat(affected_mob, "<span class='danger'>You fail to form any kind of coherent thought</span>")
				affected_mob.set_drugginess(10)
				affected_mob.confused += 10
		if(5)
			if(prob(30))
				if (!(affected_mob.dna.check_mutation(CLUWNEMUT)))
					to_chat(affected_mob, "<span class='userdanger'>IT HURTS!!</span>")
					var/mob/living/carbon/human/H = affected_mob
					H.cluwneify()