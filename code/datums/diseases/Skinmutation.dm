/datum/symptom/skinmutation
	name = "Skin mutation"
	max_stages = 7
	spread_text = "Contact"
	cure_text = "Sterilizine"
	cures = list("sterilizine")
	agent = "Verruca Bullous congenital ichthyosiform erythroderma"
	excluded_speciestypes = list(datum/species/lizard)
	desc = "This skin disorder disease clumps keratin filaments, creating blisters, and turning the infected into a lizard by undergoing biologically induced Atavism."
	severity = BIOHAZARD

/datum/disease/skinmutation/stage_act()
	..()
	switch(stage)
	if(human.dna.species.id != "lizard")
		if(1, 2)
			affected_mob << "<span class='notice'>[pick("Your skin feels awfully itchy", "Something tries to stick out of your jumpsuit")]</span>"
		if(3)
			affected_mob << A.affected_mob.say(pick("Hiss, Hiss?, Hiss!"))
			affected_mob << "<span class='notice'>[pick("You cannot resist the urge to hiss")]</span>"
		if(4)
			affected_mob << "<span class='warning'>[pick("Your tailbone feels like it's going to burst!")]</span>"
 			affected_mob.adjustbruteloss(10)
 		if(5)
 			affected_mob << "<span class='userdanger'>[pick("Your skin violently blisters!")]</span>"
 			affected_mob.adjustbruteloss(10)
 		if(6)
 			affected_mob << "<span class='userdanger'>[pick("Your skin feels as rough as sandpaper!")]</span>"
 			affected_mob.adjustbruteloss(20)
 			affected_mob.reagents.add_reagent("itching_powder", 15)
		if(7)
			if(ishuman(A.affected_mob))
				var/mob/living/carbon/human/human = A.affected_mob
					if(human.dna && human.dna.species.id != "lizard")
						human.dna.species = new /datum/species/lizard()
						human.update_icons()
						human.update_body()
						human.update_hair()
				affected_mob.adjustCloneLoss(40)
 				affected_mob.overeatduration = max(affected_mob.overeatduration - 100, 0)
				affected_mob.nutrition = max(affected_mob.nutrition - 100, 0)
				affected_mob << "<span class='userdanger'>[pick("You feel weak as your tailbone violently pops out of your jumpsuit and your blisters painfully dry up and harden into scales.")]</span>"
		else
	return