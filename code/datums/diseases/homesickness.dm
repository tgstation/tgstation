/datum/disease/homesickness
	name = "Homesickness"
	max_stages = 5
	spread_text = "None"
	spread_flags = NON_CONTAGIOUS
	cure_text = "A trip home."
	agent = "Saudade"
	viable_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	desc = "The patient is longing for their homeland, interfering with their ability to fight."
	severity = MEDIUM
	stage_prob = 5
	visibility_flags = HIDDEN_PANDEMIC
	disease_flags = null
	var/message_shown = 0

/datum/disease/homesickness/stage_act()
	if(prob(stage_prob))
		switch(stage)
			if(1)
				affected_mob << "<span class='notice'>You feel like it's been a little too long since you've seen the wastes.</span>"
			if(2)
				affected_mob << "<span class='notice'>You wonder how the village is doing without you...</span>"
			if(3)
				affected_mob << "<span class='danger'>You miss home. This place sucks. Not enough lava.</span>"
				get_sad(stage)
			if(4)
				affected_mob << "<span class='danger'>You feel numb. What is all this? What are you even doing here?</span>"
				get_sad(stage)
			if(5)
				affected_mob << "<span class='danger'>You need to get out of here!</span>"
				get_sad(stage)
		stage = min(stage + 1,max_stages)
	check_surroundings()

/datum/disease/homesickness/proc/get_sad(stage)
	if(prob(50))
		affected_mob.visible_message("<span class='notice'>[affected_mob] stops and sighs loudly.</span>","<span class='notice'>You stop and sigh loudly.</span>")
		affected_mob.Stun(1)
	else
		affected_mob << "<span class='notice'>You feel very tense.</span>"
		affected_mob.jitteriness += rand(2,4)
	if(stage >= 4)
		if(prob(50))
			affected_mob.visible_message("<span class='notice'>[affected_mob] looks shellshocked.</span>","<span class='danger'>Your mind goes blank for a moment, lost in thought.</span>")
			affected_mob.Stun(5)
	if(stage == 5)
		affected_mob.jitteriness += 10
		if(prob(50))
			affected_mob.visible_message("<span class='notice'>[affected_mob] falls to the floor in tears!</span>","<span class='userdanger'>You can't take this!</span>")
			affected_mob.Paralyse(10)
		else
			affected_mob.visible_message("<span class='notice'>[affected_mob] looks profoundly uncomfortable.</span>","<span class='danger'>You can't take much more of this!</span>")

/datum/disease/homesickness/proc/check_surroundings()
	if(istype(get_area(affected_mob),/area/lavaland))
		affected_mob << "<span class='notice'>You take a deep breath of the acrid air of your homeland. It's good to be back!</span>"
		cure()