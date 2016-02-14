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
		stage_speed = 2
		transmittable = 1
		level = 6
		severity = 5

/datum/symptom/scalerot/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/carbon/human/M = A.affected_mob
		if(M.dna.species.id == "lizard"||M.dna.species.id == "fly")
			switch(A.stage)
				if(1)
					if(M.dna.species.id == "lizard")
						M << "<span class='notice'>[pick("Your scales feels awfully itchy", "Your tail hurts")]</span>"
					if(M.dna.species.id == "fly")
						M << "<span class='notice'>[pick("Your chitin feels awfully soft", "Your proboscis hurts")]</span>"
				if(2)
					if(M.dna.species.id == "lizard")
						M << "<span class='warning'>[pick("You claw at your scales", "Your claws feel strange")]</span>"
					if(M.dna.species.id == "fly")
						M << "<span class='warning'>[pick("Your chitin feels sticky", "Your chitin leaks glucose")]</span>"
					M.adjustBruteLoss(5)
				if(3)
					if(M.dna.species.id == "lizard")
						M.say("Hiss?")
						M << "<span class='danger'>You painfully let out a hiss</span>"
					if(M.dna.species.id == "fly")
						M.say("Buzz?")
						M << "<span class='danger'>You make a pathetic attempt to buzz</span>"
					M.adjustCloneLoss(5)
					M.adjustBruteLoss(10)
				if(4)
					if(M.dna.species.id == "lizard")
						M << "<span class='danger'>Your scales rot away and reveal flesh</span>"
					if(M.dna.species.id == "fly")
						M << "<span class='danger'>Your chitin starts to leatherize and begins to crack</span>"
					M.adjustCloneLoss(10)
					M.adjustBruteLoss(15)
				if(5)
					M.adjustCloneLoss(15)
					M.adjustBruteLoss(20)
					if(M.dna.species.id == "lizard")
						M << "<span class='danger'>You tear at your scales and rip off some scales!</span>"
					if(M.dna.species.id == "fly")
						M << "<span class='danger'>You loosen some chitin and slough off some chitin!</span>"
					if(prob(16.6))
						M.set_species(/datum/species/human)
						M.update_icons()
						M.update_hair()
						if(M.dna.species.id == "lizard")
							M.visible_message("<span class='danger'>[M] rips away their rotting scales and writhes in pain!</span>")
						if(M.dna.species.id == "fly")
							M.visible_message("<span class='danger'>[M] rips away their sticky, leathery chitin and writhes in pain!</span>")
						M.adjustCloneLoss(35)
						M.sleeping += 10
		else
			A.stage = 1
	return