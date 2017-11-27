/datum/disease/fluxitus
	name = "Fluctuating Screaming Syndrome"
	max_stages = 5
	stage_prob = 5 //Faster than normal
	spread_text = "Airborne"
	cure_text = "Constantly changing"
	cures = list("clf3") //KILL IT WITH FIRE!! this will change early in the diseases lifespan but if some madman is quick with the hot stuff they get to be cured.
	agent = "Brain damaging prions"
	viable_mobtypes = list(/mob/living/carbon/human)
	cure_chance = 15
	desc = "This disease constantly changes and shifts in the host and causes a build-up of oxygen depriving chemicals that damage the brain and cause the body to reflexively scream in a desperate attempt to gain more oxygen."
	severity = VIRUS_SEVERITY_BIOHAZARD
	var/new_scream = list('hippiestation/sound/misc/oof.ogg')
	var/alternate_cures = list("mannitol", "synaptizine", "cryoxadone", "salbutamol", "perfluorodecalin", "morphine", "oculine", "epinephrine", "mutadone", "antihol", "gold")
	var/new_cure = list("mannitol")

/datum/disease/fluxitus/stage_act()
	..()
	affected_mob.add_screams(src.new_scream)
	switch(stage)
		if(1)
			new_cure = list(pick(alternate_cures))
			cures = new_cure
			cure_text = pick(new_cure)
			if(prob(2))
				to_chat(affected_mob, "<span class='danger'>You feel a little out of breath.</span>")
			if(prob(2))
				to_chat(affected_mob, "<span class='danger'>Your head feels a little light.</span>")
			if(prob(1))
				affected_mob.adjustOxyLoss(1)
				affected_mob.updatehealth()
		if(2)
			if(prob(1))
				affected_mob.emote("scream")
			if(prob(2))
				affected_mob.adjustOxyLoss(2)
				affected_mob.updatehealth()
				to_chat(affected_mob, "<span class='danger'>Your lungs feel weak.</span>")
			if(prob(3))
				affected_mob.Jitter(30)
				to_chat(affected_mob, "<span class='danger'>You feel wobbly.</span>")
			if(prob(3) && affected_mob.getBrainLoss()<=98)
				affected_mob.adjustBrainLoss(3)
				affected_mob.updatehealth()
				to_chat(affected_mob, "<span class='danger'>Your head hurts.</span>")
		if(3)
			if(prob(5))
				affected_mob.emote("scream")
			if(prob(5))
				affected_mob.adjustOxyLoss(2)
				affected_mob.updatehealth()
				to_chat(affected_mob, "<span class='danger'>Your chest feels tight.</span>")
			if(prob(5))
				affected_mob.Jitter(30)
				to_chat(affected_mob, "<span class='danger'>You shake uncontrollably!</span>")
			if(prob(5) && affected_mob.getBrainLoss()<=98)
				affected_mob.adjustBrainLoss(5)
				affected_mob.updatehealth()
				to_chat(affected_mob, "<span class='danger'>Your head really hurts.</span>")
		if(4)
			if(prob(10))
				to_chat(affected_mob, "<span class='danger'>You can't breathe!</span>")
				affected_mob.losebreath += 5
			if(prob(20))
				affected_mob.emote("scream")
			if(prob(10) && affected_mob.getBrainLoss()<=98)
				affected_mob.adjustBrainLoss(5)
				affected_mob.updatehealth()
				to_chat(affected_mob, "<span class='danger'>Your head hurts a lot!</span>")
			if(prob(3))
				affected_mob.Jitter(30)
				affected_mob.Knockdown(30)
				to_chat(affected_mob, "<span class='danger'>You thrash around madly!</span>")

		if(5) //Better have an epipen to hand or you is a ded boi
			if(prob(50))
				affected_mob.emote("scream")
			if(prob(30) && affected_mob.getBrainLoss()<=98)
				affected_mob.adjustBrainLoss(10)
				affected_mob.updatehealth()
				to_chat(affected_mob, "<span class='danger'>You feel like your brain is dribbling out your ears!</span>")
			if(prob(10))
				affected_mob.Jitter(30)
				affected_mob.Knockdown(30)
				to_chat(affected_mob, "<span class='danger'>You suddenly go into spasms!</span>")
			if(prob(25))
				to_chat(affected_mob, "<span class='danger'>You can't breathe!</span>")
				affected_mob.losebreath += 5

/datum/disease/fluxitus/cure()
	affected_mob.reindex_screams()
	..()
