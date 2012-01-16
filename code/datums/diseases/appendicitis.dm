/datum/disease/appendicitis
	form = "Condition"
	name = "Appendicitis"
	max_stages = 3
	spread = "Acute"
	cure = "Surgery"
	agent = "Shitty Appendix"
	affected_species = list("Human")
	permeability_mod = 1
	contagious_period = 9001 //slightly hacky, but hey! whatever works, right?
	desc = "If left untreated the subject will become very weak, and may vomit often."
	severity = "Medium"
	longevity = 1000
	hidden = list(0, 1)

/datum/disease/appendicitis/stage_act()
	..()
	switch(stage)
		if(1)
			if(prob(5)) affected_mob.emote("cough")
		if(2)
			if(prob(3))
				affected_mob << "\red You feel a stabbing pain in your abdomen!"
				affected_mob.Stun(rand(2,3))
				affected_mob.adjustToxLoss(1)
		if(3)
			if(prob(1))
				if (affected_mob.nutrition > 100)
					affected_mob.Stun(rand(4,6))
					for(var/mob/O in viewers(world.view, affected_mob))
						O.show_message(text("<b>\red [] throws up!</b>", affected_mob), 1)
					playsound(affected_mob.loc, 'splat.ogg', 50, 1)
					var/turf/location = affected_mob.loc
					if (istype(location, /turf/simulated))
						location.add_vomit_floor(affected_mob)
					affected_mob.nutrition -= 95
					affected_mob.adjustToxLoss(-1)
				else
					affected_mob << "\red You gag as you want to throw up, but there's nothing in your stomach!"
					affected_mob.Weaken(10)
					affected_mob.adjustToxLoss(3)