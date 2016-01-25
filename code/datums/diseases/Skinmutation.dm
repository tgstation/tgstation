/datum/symptom/skinmutation
	name = "Skin mutation"
	max_stages = 5
	spread_text = "Contact"
	cure_text = "Sterilizine"
	cures = list("sterilizine")
	agent = "Verruca Bullous congenital ichthyosiform erythroderma"
	excluded_speciestypes = list(datum/species/lizard)
	desc = "This skin disorder disease clumps keratin filaments, creating blisters, and turning the infected into a lizard by undergoing genetically induced Atavism."
	severity = BIOHAZARD

/datum/symptom/skinmutation/Activate(var/datum/disease/advance/A)
        ..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = A.affected_mob
			switch(A.stage)
				if(1, 2)
					if(prob(SYMPTOM_ACTIVATION_PROB))
 						M << "<span class='notice'>[pick("Your skin feels awfully itchy", "Something tries to stick out of your jumpsuit")]</span>"
				if(3)
					if(prob(SYMPTOM_ACTIVATION_PROB))
						M << A.affected_mob.say(pick("Hiss, Hiss?, Hiss!"))
						M << "<span class='notice'>[pick("You cannot resist the urge to hiss")]</span>"
				if(4)
					if(prob(SYMPTOM_ACTIVATION_PROB))
						M << "<span class='warning'>[pick("Your tailbone feels like it's going to burst!")]</span>"
						M.adjustFireLoss(5)
 						M.adjustbrute(5)
				if(5)
					if(ishuman(A.affected_mob))
						var/mob/living/carbon/human/human = A.affected_mob
							if(human.dna && human.dna.species.id != "lizard")
								human.dna.species = new /datum/species/lizard()
								human.update_icons()
								human.update_body()
								human.update_hair()
						M.adjustcloneLoss(20)
						M.adjustFireLoss(10)
 						M.adjustbrute(10)
 						M.overeatduration = max(M.overeatduration - 100, 0)
						M.nutrition = max(M.nutrition - 100, 0)
						M << "<span class='userdanger'>[pick("You feel weak as your tailbone violently pops out of your jumpsuit and your blisters painfully dry up and harden into scales.")]</span>"
						else
								return

		return