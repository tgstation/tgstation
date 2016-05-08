/datum/disease/berserker
	name = "Berserker"
	max_stages = 2
	spread_text = "Non-Contagious"
	spread_flags = SPECIAL
	cure_text = "Anti-Psychotics"
	cures = list("haloperidol")
	agent = "Anger."
	viable_mobtypes = list(/mob/living/carbon/human,/mob/living/carbon/monkey)
	desc = "Swearing, shouting, attacking nearby crew members uncontrollably."
	severity = DANGEROUS
	disease_flags = CURABLE
	spread_flags = NON_CONTAGIOUS

/datum/disease/berserker/stage_act()
	..()
	var/mob/living/M = affected_mob
	switch(stage)
		if(1)
			if(prob(5))
				M.emote(pick("twitch", "grumble"))
			if(prob(5))
				var/speak = pick("Grr...", "Fuck...", "Fucking...", "Fuck this fucking.. fuck..")
				M.say(speak)
		if(2)
			if(prob(5))
				M.emote(pick("twitch", "scream"))
			if(prob(5))
				var/speak = pick("AAARRGGHHH!!!!", "GRR!!!", "FUCK!! FUUUUUUCK!!!", "FUCKING SHITCOCK!!", "WROOAAAGHHH!!")
				M.say(speak)
			if(prob(15))
				M.drop_item()
				M.visible_message("<span class = 'danger><b>[M] twitches violently!</b></span>")
			if(prob(33))
				for(var/mob/living/carbon/MA in range(1,M))
					M.visible_message("<span class = 'danger><b>[M] thrashes around violently!</b></span>")
					if(MA == M)
						continue
					var/damage = rand(1,5)
					if(prob(80))
						playsound(M.loc, "punch", 25, 1, -1)
						M.visible_message("<span class = 'danger><b>[M] hits [MA] with their thrashing!</b></span>")
						MA.adjustBruteLoss(damage)
					else
						playsound(affected_mob.loc, "sound/weapons/punchmiss.ogg", 25, 1, -1)
						M.visible_message("<span class = 'danger><b>[M] fails to hit [MA] with their thrashing!</b></span>")
						return

	return