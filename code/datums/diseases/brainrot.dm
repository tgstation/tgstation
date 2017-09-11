/datum/disease/brainrot
	name = "Brainrot"
	max_stages = 4
	spread_text = "On contact"
	spread_flags = CONTACT_GENERAL
	cure_text = "Mannitol"
	cures = list("mannitol")
	agent = "Cryptococcus Cosmosis"
	viable_mobtypes = list(/mob/living/carbon/human)
	cure_chance = 15//higher chance to cure, since two reagents are required
	desc = "This disease destroys the braincells, causing brain fever, brain necrosis and general intoxication."
	required_organs = list(/obj/item/organ/brain)
	severity = DANGEROUS

/datum/disease/brainrot/stage_act() //Removed toxloss because damaging diseases are pretty horrible. Last round it killed the entire station because the cure didn't work -- Urist -ACTUALLY Removed rather than commented out, I don't see it returning - RR
	..()

	switch(stage)
		if(2)
			if(SSrng.probability(2))
				affected_mob.emote("blink")
			if(SSrng.probability(2))
				affected_mob.emote("yawn")
			if(SSrng.probability(2))
				to_chat(affected_mob, "<span class='danger'>You don't feel like yourself.</span>")
			if(SSrng.probability(5))
				affected_mob.adjustBrainLoss(1)
				affected_mob.updatehealth()
		if(3)
			if(SSrng.probability(2))
				affected_mob.emote("stare")
			if(SSrng.probability(2))
				affected_mob.emote("drool")
			if(SSrng.probability(10) && affected_mob.getBrainLoss()<=98)//shouldn't retard you to death now
				affected_mob.adjustBrainLoss(2)
				affected_mob.updatehealth()
				if(SSrng.probability(2))
					to_chat(affected_mob, "<span class='danger'>Your try to remember something important...but can't.</span>")

		if(4)
			if(SSrng.probability(2))
				affected_mob.emote("stare")
			if(SSrng.probability(2))
				affected_mob.emote("drool")
			if(SSrng.probability(15) && affected_mob.getBrainLoss()<=98) //shouldn't retard you to death now
				affected_mob.adjustBrainLoss(3)
				affected_mob.updatehealth()
				if(SSrng.probability(2))
					to_chat(affected_mob, "<span class='danger'>Strange buzzing fills your head, removing all thoughts.</span>")
			if(SSrng.probability(3))
				to_chat(affected_mob, "<span class='danger'>You lose consciousness...</span>")
				affected_mob.visible_message("<span class='warning'>[affected_mob] suddenly collapses</span>")
				affected_mob.Unconscious(SSrng.random(100,200))
				if(SSrng.probability(1))
					affected_mob.emote("snore")
			if(SSrng.probability(15))
				affected_mob.stuttering += 3

	return
