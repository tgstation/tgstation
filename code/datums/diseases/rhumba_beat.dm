/datum/disease/rhumba_beat
	name = "The Rhumba Beat"
	max_stages = 5
	spread = "On contact"
	spread_type = CONTACT_GENERAL
	cure = "Chick Chicky Boom!"
	cure_id = list("plasma")
	agent = "Unknown"
	affected_species = list("Human")
	permeability_mod = 1

/datum/disease/rhumba_beat/stage_act()
	..()
	switch(stage)
		if(1)
			if(affected_mob.ckey == "rosham")
				src.cure()
		if(2)
			if(affected_mob.ckey == "rosham")
				src.cure()
			if(prob(45))
				affected_mob.adjustToxLoss(5)
				affected_mob.updatehealth()
			if(prob(1))
				affected_mob << "\red You feel strange..."
		if(3)
			if(affected_mob.ckey == "rosham")
				src.cure()
			if(prob(5))
				affected_mob << "\red You feel the urge to dance..."
			else if(prob(5))
				affected_mob.emote("gasp")
			else if(prob(10))
				affected_mob << "\red You feel the need to chick chicky boom..."
		if(4)
			if(affected_mob.ckey == "rosham")
				src.cure()
			if(prob(10))
				affected_mob.emote("gasp")
				affected_mob << "\red You feel a burning beat inside..."
			if(prob(20))
				affected_mob.adjustToxLoss(5)
				affected_mob.updatehealth()
		if(5)
			if(affected_mob.ckey == "rosham")
				src.cure()
			affected_mob << "\red Your body is unable to contain the Rhumba Beat..."
			if(prob(50))
				affected_mob.gib()
		else
			return