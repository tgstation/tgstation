/datum/symptom/lizarditis
	name = "Skin mutation"
	max_stages = 7
	spread_text = "Contact"
	cure_text = "Sterilizine"
	cures = list("sterilizine")
	agent = "Verruca Bullous congenital ichthyosiform erythroderma"
	excluded_speciestypes = list(datum/species/lizard)
	desc = "This skin disorder disease clumps keratin filaments, creating blisters, and turning the infected into a lizard by undergoing biologically induced Atavism."
	severity = BIOHAZARD

/datum/disease/lizarditis/stage_act()
	..()
	var/mob/living/M = A.affected_mob
	if(M.dna.species.id != "lizard")
	switch(stage)
		if(1, 2)
			if(M.dna.species.id == "lizard")
				src.cure()
			M << "<span class='notice'>[pick("Your skin feels awfully itchy", "Something tries to stick out of your jumpsuit")]</span>"
		if(3)
			if(M.dna.species.id == "lizard")
				src.cure()
			M.say(pick("Hiss, Hiss?, Hiss!"))
			M << "<span class='notice'>[pick("You cannot resist the urge to hiss")]</span>"
		if(4)
			if(M.dna.species.id == "lizard")
				src.cure()
			M << "<span class='warning'>[pick("Your tailbone feels like it's going to burst!")]</span>"
 			M.adjustbruteloss(10)
 		if(5)
 			if(M.dna.species.id == "lizard")
				src.cure()
 			M << "<span class='userdanger'>[pick("Your skin violently blisters!")]</span>"
 			M.adjustbruteloss(10)
 		if(6)
 			if(M.dna.species.id == "lizard")
				src.cure()
 			M << "<span class='userdanger'>[pick("Your skin feels as rough as sandpaper!")]</span>"
 			M.adjustbruteloss(20)
 			M.reagents.add_reagent("itching_powder", 15)
		if(7)
			if(M.dna.species.id == "lizard")
				src.cure()
			if(ishuman(M) && M.dna && M.dna.species.id != "lizard")
				M.dna.species = new /datum/species/lizard()
				M.update_icons()
				M.update_body()
				M.update_hair()
			M.adjustCloneLoss(50)
			M << "<span class='danger'>You feel weak as your tailbone violently pops out of your jumpsuit and your blisters painfully dry up and harden into scales.</span>"
		else
	return