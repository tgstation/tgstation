/datum/disease/scalerot
	name = "Scale rot"
	max_stages = 5
	spread_text = "On contact"
	spread_flags = CONTACT_GENERAL
	cure_text = "Alcohol based anti-septics or vitamin superdoses."
	cures = list("vitamin")
	agent = "Reptilian Necrotizing Dermatitis"
	viable_mobtypes = list(/mob/living/carbon/human)
	cure_chance = 10//scalerot, generally speaking, is not easy to cure, and requires lengthy decontamination procedures, and vitamin megadoses are pseudoscience.
	desc = "A lethal bacteria that affects only scale based skin surfaces. Rots away scales. Commonly carried by various races, and naturally occurs on scaled races experiencing poor hygiene, moist skin, or excess humidty or moisture."
	severity = DANGEROUS
	longevity = 400

/datum/disease/scalerot/stage_act()
	..()
	if(affected_mob.dna.species.id == "lizard"||affected_mob.dna.species.id == "fly") //Non-scaled species are not affected by the virus and merely carry it.
		switch(stage)
			if(1)
				if(affected_mob.dna.species.id == "lizard")
					affected_mob << "<span class='notice'>[pick("Your scales feels awfully itchy", "Your tail hurts")]</span>"
				if(affected_mob.dna.species.id == "fly")
					affected_mob << "<span class='notice'>[pick("Your chitin feels awfully soft", "Your proboscis hurts")]</span>"
			if(2)
				if(affected_mob.dna.species.id == "lizard")
					affected_mob << "<span class='warning'>[pick("You claw at your scales", "Your claws feel strange")]</span>"
				if(affected_mob.dna.species.id == "fly")
					affected_mob << "<span class='warning'>[pick("Your chitin feels sticky", "Your chitin leaks glucose")]</span>"
				if(prob(10))
					affected_mob.adjustStaminaLoss(15)
			if(3)
				if(affected_mob.dna.species.id == "lizard")
					affected_mob.say("hs?")
					affected_mob << "<span class='danger'>You painfully let out a hiss.</span>"
				if(affected_mob.dna.species.id == "fly")
					affected_mob.say("buz?")
					affected_mob << "<span class='danger'>You make a pathetic attempt to buzz, painfully.</span>"
				affected_mob.adjustBruteLoss(1)
				if(prob(10))
					affected_mob.adjustStaminaLoss(20)
			if(4)
				if(affected_mob.dna.species.id == "lizard")
					affected_mob << "<span class='danger'>Your scales rot away and reveal flesh</span>"
				if(affected_mob.dna.species.id == "fly")
					affected_mob << "<span class='danger'>Your chitin starts to leatherize and begins to crack</span>"
				affected_mob.adjustBruteLoss(2)
				if(prob(10))
					affected_mob.adjustStaminaLoss(25)
			if(5)
				affected_mob.adjustBruteLoss(3)
				if(prob(10))
					affected_mob.adjustStaminaLoss(20)
				if(prob(5))
					affected_mob.Weaken(2)
				if(affected_mob.dna.species.id == "lizard")
					affected_mob << "<span class='danger'>You tear at your scales and rip off some scales!</span>"
				if(affected_mob.dna.species.id == "fly")
					affected_mob << "<span class='danger'>You loosen some chitin and slough off some chitin!</span>"
				if(prob(15))
					if("tail_lizard"||"waggingtail_lizard" in affected_mob.dna.species.mutant_bodyparts)
						affected_mob.dna.species.mutant_bodyparts -= "tail_lizard"
						new /obj/item/severedtail(get_turf(affected_mob))
						affected_mob.visible_message("[affected_mob]'s tail rots off and flops to the ground.</span>")
						affected_mob.update_body()
						affected_mob.adjustBruteLoss(25)
						affected_mob.adjustStaminaLoss(100)
						affected_mob.bleed(35)
		if(affected_mob.reagents.get_reagent_amount(("ethanol") > 15)||("sterilizine">1))
			cure()
	else
		stage = 1
	return
