/*
//////////////////////////////////////
scalerot
	Increases resistance.
	Increases stage speed.
	Little transmittable.
	high level
	other races can be carriers
Bonus
	Rots away lizards and flies (chitinous scales) and reverts them to a fleshy form
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
		var/mob/living/carbon/human/M = A.affected_mob
		if(M.dna.species.id == "lizard"||M.dna.species.id == "fly")
			switch(A.stage)
				if(2)
					M << "<span class='notice'>[pick("Your scales feels awfully itchy", "Your tail hurts")]</span>"
				if(3)
					M << "<span class='notice'>[pick("You claw at your scales", "Your claws feel strange")]</span>"
					M.adjustCloneLoss(10)
				if(4)
					M << M.say(pick("Hiss?"))
					M << "<span class='danger'>[pick("You painfully let out a hiss")]</span>"
					M.adjustCloneLoss(15)
				if(5)
					M << "<span class='danger'>[pick("Your scales rot away and reveal flesh")]</span>"
					M.adjustCloneLoss(20)
				if(6)
					M.adjustCloneLoss(25)
					M << "<span class='danger'>[pick("You tear at your scales and rip off your scaley skin!")]</span>"
					if(M.stat == DEAD)
						M.set_species(/datum/species/human)
						M.update_icons()
						M.update_hair()
						M.visible_message("<span class='danger'>[M] rips away their rotting scales and writhes in pain!</span>")
						M.adjustCloneLoss(35)
		else
			stage = 1
	return