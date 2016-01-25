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
		viable_speciestypes = list(datum/species/lizard)

/datum/symptom/scalerot/Activate(var/datum/disease/advance/A)
	..()
			if(prob(SYMPTOM_ACTIVATION_PROB))
			var/mob/living/M = A.affected_mob
			switch(A.stage)
					if(1)
						M << "<span class='notice'>[pick("Your scales feels awfully itchy", "Your tail hurts")]</span>"
					if(2)
						M << "<span class='notice'>[pick("You claw at your scales", "Your claws feel strange")]</span>"
						M.adjustcloneLoss(15)
					if(3)
						M << A.affected_mob.say(pick("Hiss?"))
						M << "<span class='notice'>[pick("You painfully let out a hiss")]</span>"
						M.adjustcloneLoss(30)
					if(4)
						M << "<span class='notice'>[pick("Your scales rot away and reveal flesh")]</span>"
						M.adjustcloneLoss(45)
					if(5)
						if(ishuman(A.affected_mob))
							var/mob/living/carbon/human/human = A.affected_mob
							if(human.dna && human.dna.species.id != "lizard")
									human.dna.species = new /datum/species/human()
									human.update_icons()
									human.update_body()
									human.update_hair()
									M.adjustcloneLoss(200)
									M.adjustbruteLoss(200)
									M << "<span class='notice'>[pick("You tear at your scales and rip off your scaley skin!")]</span>"
			else
	return
