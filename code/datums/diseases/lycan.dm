/datum/disease/lycan
	name = "Lycancoughy"
	max_stages = 4
	stage_prob = 1
	spread_text = "On contact"
	spread_flags = DISEASE_SPREAD_BLOOD | DISEASE_SPREAD_CONTACT_SKIN | DISEASE_SPREAD_CONTACT_FLUIDS
	cure_text = "Ethanol"
	cures = list(/datum/reagent/consumable/ethanol)
	agent = "Excess Snuggles"
	viable_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	desc = "If left untreated subject will regurgitate... doggos."
	severity = DISEASE_SEVERITY_MEDIUM
	var/barklimit = 0

/datum/disease/lycan/stage_act()
	..()

	switch(stage)
		if(2) //also changes say, see say.dm
			if(prob(5))
				to_chat(affected_mob, "<span class='notice'>You itch.</span>")
				affected_mob.emote("cough")
		if(3)
			if(prob(10))
				to_chat(affected_mob, "<span class='notice'>You hear faint barking.</span>")
			if(prob(5))
				to_chat(affected_mob, "<span class='notice'>You crave meat.</span>")
				affected_mob.emote("cough")
			if(prob(2))
				to_chat(affected_mob, "<span class='danger'>Your stomach growls!</span>")
		if(4)
			if(prob(10))
				to_chat(affected_mob, "<span class='danger'>Your stomach barks?!</span>")
			if(prob(5))
				affected_mob.visible_message("<span class='danger'>[affected_mob] awoos!</span>", \
												"<span class='userdanger'>You awoo!</span>")
				affected_mob.confused += (rand(6,8))
			if(prob(3) && barklimit <= 10)
				var/list/puppytype = list(/mob/living/simple_animal/pet/dog/corgi/puppy, /mob/living/simple_animal/pet/dog/pug, /mob/living/simple_animal/pet/dog/corgi/exoticcorgi, /mob/living/simple_animal/pet/dog/corgi/narsie, /mob/living/simple_animal/pet/dog/corgi/puppy/void )
				var/mob/living/puppypicked = pick(puppytype)
				affected_mob.visible_message("<span class='danger'>[affected_mob] coughs up [initial (puppypicked.name)]!</span>", \
												"<span class='userdanger'>You cough up [initial(puppypicked.name)]?!</span>")
				new puppypicked(affected_mob.loc)
				barklimit ++
	return