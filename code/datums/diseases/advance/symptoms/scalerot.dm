/*
//////////////////////////////////////
scalerot
	Increases resistance.
	Increases stage speed.
	Little transmittable.
	high level
Bonus
	Rots away lizards and reverts them to a fleshy form
//////////////////////////////////////
*/

/datum/symptom/scalerot

		name = "Scale rot"
		stealth = 2
		resistance = 3
		stage_speed = 3
		transmittable = 0
		level = 6
		severity = 5

/datum/symptom/scalerot/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = A.affected_mob
		if(human.dna.species.id == "lizard")//this is scale rot. literally no other race has scales, please contact me if more scaled species are added in
		switch(A.stage)
			if(1)
				if(M.dna.species.id != "lizard")
					stage = 6
				M << "<span class='notice'>[pick("Your scales feels awfully itchy", "Your tail hurts")]</span>"
			if(2)
				if(M.dna.species.id != "lizard")
					stage = 6
				M << "<span class='notice'>[pick("You claw at your scales", "Your claws feel strange")]</span>"
				M.adjustcloneLoss(15)
			if(3)
				if(M.dna.species.id != "lizard")
					stage = 6
				M << A.affected_mob.say(pick("Hiss?"))
				M << "<span class='notice'>[pick("You painfully let out a hiss")]</span>"
				M.adjustcloneLoss(30)
			if(4)
				if(M.dna.species.id != "lizard")
					stage = 6
				M << "<span class='notice'>[pick("Your scales rot away and reveal flesh")]</span>"
				M.adjustcloneLoss(45)
			if(5)
				if(M.dna.species.id != "lizard")
					stage = 6
				if(ishuman(M)
					var/mob/living/carbon/human/human = M
					if(human.dna && human.dna.species.id != "lizard")
						human.dna.species = new /datum/species/human()
						human.update_icons()
						human.update_body()
						human.update_hair()
						M.adjustcloneLoss(200)
						M.adjustbruteLoss(200)
						M << "<span class='notice'>[pick("You tear at your scales and rip off your scaley skin!")]</span>"
			if(6)
				M.emote("cough")
	return
