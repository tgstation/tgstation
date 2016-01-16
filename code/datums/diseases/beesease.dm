/*
/datum/disease/beesease
	name = "Beesease"
	max_stages = 5
	spread = "Contact" //ie shot bees
	cure = "???"
	cure_id = "???"
	agent = "Bees"
	affected_species = list("Human","Monkey")
	curable = 0

/datum/disease/beesease/stage_act()
	..()
	switch(stage)
		if(1)
			if(prob(2))
				to_chat(affected_mob, "<span class='warning'>You feel like something is moving inside of you</span>")
		if(2) //also changes say, see say.dm
			if(prob(2))
				to_chat(affected_mob, "<span class='warning'>You feel like something is moving inside of you</span>")
			if(prob(2))
				to_chat(affected_mob, "<span class='warning'>BZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ</span>")
		if(3)
		//Should give the bee spit verb
		if(4)
		//Plus bees now spit randomly
		if(5)
		//Plus if you die, you explode into bees
	return
*/
//Started working on it, but am too lazy to finish it today -- Urist