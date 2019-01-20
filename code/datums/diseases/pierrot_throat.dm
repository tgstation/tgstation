/datum/disease/pierrot_throat
	name = "Pierrot's Throat"
	max_stages = 4
	spread_text = "Airborne"
	cure_text = "Banana products, especially banana bread."
	cures = list("banana")
	cure_chance = 75
	agent = "H0NI<42 Virus"
	viable_mobtypes = list(/mob/living/carbon/human)
	permeability_mod = 0.75
	desc = "If left untreated the subject will probably drive others to insanity."
	severity = DISEASE_SEVERITY_MEDIUM

/datum/disease/pierrot_throat/stage_act()
	..()
	switch(stage)
		if(1)
			if(prob(10))
				to_chat(affected_mob, "<span class='danger'>You feel a little silly.</span>")
		if(2)
			if(prob(10))
				to_chat(affected_mob, "<span class='danger'>You start seeing rainbows.</span>")
		if(3)
			if(prob(10))
				to_chat(affected_mob, "<span class='danger'>Your thoughts are interrupted by a loud <b>HONK!</b></span>")
		if(4)
			if(prob(5))
				affected_mob.say( pick( list("HONK!", "Honk!", "Honk.", "Honk?", "Honk!!", "Honk?!", "Honk...") ) , forced = "pierrot's throat")
