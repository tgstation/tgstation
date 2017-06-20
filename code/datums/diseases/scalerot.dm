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
	longevity = 650

/datum/disease/scalerot/stage_act()
	..()
	if(affected_mob.dna.species.id == "lizard"||affected_mob.dna.species.id == "fly") //Non-scaled species are not affected by the virus and merely carry it.
		switch(stage)
			if(1)
				if(prob(40))
					if(affected_mob.dna.species.id == "lizard")
						to_chat(affected_mob << "<span class='notice'>[pick("Your scales feels awfully itchy", "Your tail hurts")]</span>")
					if(affected_mob.dna.species.id == "fly")
						to_chat(affected_mob << "<span class='notice'>[pick("Your chitin feels awfully soft", "Your proboscis hurts")]</span>")
			if(2)
				if(prob(10))
					if(affected_mob.dna.species.id == "lizard")
						to_chat(affected_mob << "<span class='warning'>[pick("You claw at your scales", "Your claws feel strange")]</span>")
					if(affected_mob.dna.species.id == "fly")
						to_chat(affected_mob << "<span class='warning'>[pick("Your chitin feels sticky", "Your chitin leaks glucose")]</span>")
				if(prob(10))
					affected_mob.adjustStaminaLoss(15)
			if(3)
				if(prob(10))
					if(affected_mob.dna.species.id == "lizard")
						to_chat(affected_mob.say("hs?"))
						to_chat(affected_mob << "<span class='danger'>You painfully let out a hiss.</span>")
					if(affected_mob.dna.species.id == "fly")
						to_chat(affected_mob.say("buz?"))
						to_chat(affected_mob << "<span class='danger'>You make a pathetic attempt to buzz, painfully.</span>")
				if(prob(70))
					affected_mob.adjustBruteLoss(2)
				if(prob(10))
					affected_mob.adjustStaminaLoss(20)
			if(4)
				if(prob(10))
					if(affected_mob.dna.species.id == "lizard")
						affected_mob << "<span class='danger'>Your scales rot away and reveal sores</span>"
					if(affected_mob.dna.species.id == "fly")
						to_chat(affected_mob << "<span class='danger'>Your chitin starts to leatherize and begins to crack</span>")
				if(prob(70))
					affected_mob.adjustBruteLoss(3)
				if(prob(10))
					affected_mob.adjustStaminaLoss(25)
			if(5)
				reduce_health()
				remove_tail()
				if(prob(10))
					affected_mob.adjustStaminaLoss(25)
				if(prob(5))
					affected_mob.Weaken(2)
				if(prob(5))
					affected_mob.adjustBruteLoss(3)
		if(affected_mob.reagents.get_reagent_amount(("ethanol") > 15)||("sterilizine" > 1 ))
			proper_cure()
	else
		stage = 1
	return

/datum/disease/scalerot/proc/reduce_health()
	if(affected_mob.getCloneLoss() < 25)
		affected_mob.setCloneLoss(25)
		if(affected_mob.dna.species.id == "lizard")
			to_chat(affected_mob << "<span class='danger'>You tear some scales!</span>")
		if(affected_mob.dna.species.id == "fly")
			to_chat(affected_mob << "<span class='danger'>Some chitin sloughs off!</span>")

/datum/disease/scalerot/proc/remove_tail()
	if("tail_lizard"||"waggingtail_lizard" in affected_mob.dna.species.mutant_bodyparts)
		affected_mob.dna.species.mutant_bodyparts -= "tail_lizard"
		new /obj/item/severedtail(get_turf(affected_mob))
		to_chat(affected_mob.visible_message("[affected_mob]'s tail rots off and flops to the ground.</span>")) //rekt
		affected_mob.update_body()
		affected_mob.adjustBruteLoss(25)
		affected_mob.Weaken(5)
		affected_mob.bleed(35)

/datum/disease/scalerot/proc/proper_cure()
	if(5)
		affected_mob.adjustCloneLoss(-25)
		if(affected_mob.dna.species.id == "lizard")
			to_chat(affected_mob << "<span class='notice'>Your scales are cleansed of the rot.</span>")
		if(affected_mob.dna.species.id == "fly")
			to_chat(affected_mob << "<span class='notice'>Your chitin feels healthier after the anti-biotic cleansing.</span>")
	cure()