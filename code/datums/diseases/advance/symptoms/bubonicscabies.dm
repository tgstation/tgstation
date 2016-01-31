/datum/disease/bubonicscabies
	name = "Scabiei gangrenosum bubo"
	max_stages = 7
	spread_text = "On contact"
	spread_flags = CONTACT_GENERAL
	cure_text = "Sterilizine or Space cleaner"
	cure_chance = 33
	cures = list("cleaner")
	cures = list("sterilizine")
	agent = "Cosmic Sarcoptes scabiei bubonicus"
	viable_mobtypes = list(/mob/living/carbon/human, /mob/living/simple_animal/mouse)
	desc = "This contagious human skin infestation is caused by a gangrenous variety of the Scabies mite. Causes pimple breakout, severe itching, and unintentional self inflicted injury."
	severity = BIOHAZARD

/datum/disease/bubonicscabies/stage_act()
	..()
	if(affected_mob.dna.species.id == "human")
		switch(stage)
			if(1, 2)
				affected_mob << "<span class='notice'>[pick("Your skin feels really itchy", "You scratch at a few spots")]</span>"
			if(3)
				affected_mob << "<span class='warning'>[pick("You notice outbreaks of pimples on your arm!", "A few sore patches start developing on your leg.")]</span>"
			if(4)
				affected_mob << "<span class='warning'>[pick("You scratch and burst some pimples, spreading pus and bleeding.")]</span>"
				affected_mob.adjustBruteLoss(5)
				affected_mob.reagents.add_reagent("itching_powder", 5)
 			if(5)
	 			affected_mob << "<span class='danger'>[pick("You scratch at some sores and pimples.")]</span>"
 				affected_mob.adjustBruteLoss(10)
 				affected_mob.reagents.add_reagent("itching_powder", 10)
	 		if(6)
 				affected_mob << "<span class='danger'>[pick("Your sores and pores begin getting extremely painful and look infected!")]</span>"
 				affected_mob.adjustBruteLoss(15)
 				affected_mob.reagents.add_reagent("itching_powder", 15)
			if(7)
				affected_mob << "<span class='userdanger'>You tear at the infected pores and sores on your body!</span>"
				affected_mob.adjustCloneLoss(5)
				affected_mob.adjustBruteLoss(10)
	else
		cure()