/datum/disease/scarabas
	name = "Scarabas affliction"
	form = "Infection"
	max_stages = 4
	spread_text = "On contact"
	spread_flags = CONTACT_GENERAL
	cure_text = "Embalming fluids such as Formaldehyde, Phenol, or Sterilizine"
	cures = list("formaldehyde", "phenol", "sterilizine")
	needs_all_cures = FALSE
	agent = "Necrotizing fasciitis Sarcoptes Scarabaeus sacer"
	viable_mobtypes = list(/mob/living/carbon/human,/mob/living/carbon/monkey)
	desc = "If left untreated subject will be torn apart by Scarabs tearing their body apart."
	severity = DANGEROUS

/datum/disease/scarabas/stage_act()
	..()
	if(affected_mob.dna.species.id != "scarabite")
		switch(stage)
			if(2)
				affected_mob.faction = list("scarab")
				affected_mob << "<span class='notice'>You feel something crawl under your skin.</span>"
			if(3)
				if(affected_mob.dna.species.id == "scarabite")
					affected_mob.faction = list("scarab")
					affected_mob.visible_message("<span class='danger'>[affected_mob] releases cockroaches!</span>")
					new /mob/living/simple_animal/hostile/poison/giant_spider/scarab(affected_mob.loc)
				else
					if(prob(30))
						affected_mob << "<span class='notice'>You feel tiny bugs crawl around your body.</span>"
					if(prob(10))
						affected_mob << "<span class='danger'>You feel a sharp pain stabbing in your back.</span>"
						if(prob(20))
							affected_mob.adjustBruteLoss(10)
			if(4)
				if(prob(10))
					affected_mob.visible_message("<span class='danger'>[affected_mob] chitters.</span>")
				if(prob(5))
					affected_mob << "<span class='danger'>You feel things bite your back.</span>"
					affected_mob.adjustBruteLoss(10)
				if(prob(1))
					affected_mob.visible_message("<span class='danger'>A scarabite tears itself out of [affected_mob] and lands on the floor!</span>")
					affected_mob.adjustBruteLoss(15)
					new /mob/living/simple_animal/hostile/poison/giant_spider/scarab(affected_mob.loc)
	else
		stage = 3
		return
