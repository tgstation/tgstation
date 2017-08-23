/datum/disease/gbs
	name = "GBS"
	max_stages = 5
	spread_text = "On contact"
	spread_flags = CONTACT_GENERAL
	cure_text = "Synaptizine & Sulfur"
	cures = list("synaptizine","sulfur")
	cure_chance = 15//higher chance to cure, since two reagents are required
	agent = "Gravitokinetic Bipotential SADS+"
	viable_mobtypes = list(/mob/living/carbon/human)
	disease_flags = CAN_CARRY|CAN_RESIST|CURABLE
	permeability_mod = 1
	severity = BIOHAZARD

/datum/disease/gbs/stage_act()
	..()
	switch(stage)
		if(2)
			if(SSrng.probability(45))
				affected_mob.adjustToxLoss(5)
				affected_mob.updatehealth()
			if(SSrng.probability(1))
				affected_mob.emote("sneeze")
		if(3)
			if(SSrng.probability(5))
				affected_mob.emote("cough")
			else if(SSrng.probability(5))
				affected_mob.emote("gasp")
			if(SSrng.probability(10))
				to_chat(affected_mob, "<span class='danger'>You're starting to feel very weak...</span>")
		if(4)
			if(SSrng.probability(10))
				affected_mob.emote("cough")
			affected_mob.adjustToxLoss(5)
			affected_mob.updatehealth()
		if(5)
			to_chat(affected_mob, "<span class='danger'>Your body feels as if it's trying to rip itself open...</span>")
			if(SSrng.probability(50))
				affected_mob.gib()
		else
			return