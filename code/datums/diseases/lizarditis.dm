/datum/disease/lizarditis
	name = "Skin mutation"
	max_stages = 8
	spread_text = "On contact"
	spread_flags = CONTACT_GENERAL
	cure_text = "Sterilizine"
	cure_chance = 33
	cures = list("sterilizine")
	agent = "Verruca Bullous congenital ichthyosiform erythroderma"
	viable_mobtypes = list(/mob/living/carbon/human)
	desc = "This skin disorder disease clumps keratin filaments, creating blisters, and turning the infected into a lizard by undergoing biologically induced Atavism."
	severity = BIOHAZARD

/datum/disease/lizarditis/stage_act()
	..()
	if(affected_mob.dna.species.id != "lizard")
		switch(stage)
			if(1, 2)
				affected_mob << "<span class='notice'>[pick("Your skin feels awfully itchy", "Something tries to stick out of your jumpsuit")]</span>"
			if(3)
				affected_mob.say(pick("Hiss, Hiss?, Hiss!"))
				affected_mob << "<span class='notice'>[pick("You cannot resist the urge to hiss")]</span>"
			if(4)
				affected_mob << "<span class='warning'>[pick("Your tailbone feels like it's going to burst!")]</span>"
				affected_mob.adjustBruteLoss(10)
			if(5)
				affected_mob << "<span class='userdanger'>[pick("Your skin violently blisters!")]</span>"
				affected_mob.adjustBruteLoss(10)
			if(6)
				affected_mob << "<span class='userdanger'>[pick("Your skin feels as rough as sandpaper!")]</span>"
				affected_mob.adjustBruteLoss(10)
				affected_mob.reagents.add_reagent("itching_powder", 15)
			if(8)
				affected_mob.set_species(/datum/species/lizard)
				affected_mob.update_icons()
				affected_mob.update_hair()
				affected_mob.adjustCloneLoss(25)
				affected_mob << "<span class='danger'>You feel weak as your tailbone violently pops out of your jumpsuit and your blisters painfully dry up and harden into scales.</span>"
	else
		cure()
