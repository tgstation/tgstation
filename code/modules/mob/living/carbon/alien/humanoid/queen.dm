
/mob/living/carbon/alien/humanoid/queen
	name = "alien queen"
	caste = "q"
	maxHealth = 250
	health = 250
	icon_state = "alienq_s"
	nopush = 1
	heal_rate = 10 // Let's regenerate more than our average underling.
	plasma_rate = 20


/mob/living/carbon/alien/humanoid/queen/New()
	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src

	//there should only be one queen
	for(var/mob/living/carbon/alien/humanoid/queen/Q in living_mob_list)
		if(Q == src)		continue
		if(Q.stat == DEAD)	continue
		if(Q.client)
			name = "alien princess ([rand(1, 999)])"	//if this is too cutesy feel free to change it/remove it.
			break

	real_name = src.name
	verbs.Add(/mob/living/carbon/alien/humanoid/proc/corrosive_acid,/mob/living/carbon/alien/humanoid/proc/neurotoxin,/mob/living/carbon/alien/humanoid/proc/resin)
	verbs -= /mob/living/carbon/alien/verb/ventcrawl
	..()

/mob/living/carbon/alien/humanoid/queen

	handle_regular_hud_updates()

		..() //-Yvarov

		if (src.healths)
			if (src.stat != 2)
				switch(health)
					if(250 to INFINITY)
						src.healths.icon_state = "health0"
					if(175 to 250)
						src.healths.icon_state = "health1"
					if(100 to 175)
						src.healths.icon_state = "health2"
					if(50 to 100)
						src.healths.icon_state = "health3"
					if(0 to 50)
						src.healths.icon_state = "health4"
					else
						src.healths.icon_state = "health5"
			else
				src.healths.icon_state = "health6"


//Queen verbs
/mob/living/carbon/alien/humanoid/queen/verb/lay_egg()

	set name = "Lay Egg (75)"
	set desc = "Lay an egg to produce huggers to impregnate prey with."
	set category = "Alien"

	if(locate(/obj/effect/alien/egg) in get_turf(src))
		src << "There's already an egg here."
		return

	if(powerc(75,1))//Can't plant eggs on spess tiles. That's silly.
		adjustToxLoss(-75)
		for(var/mob/O in viewers(src, null))
			O.show_message(text("\green <B>[src] has laid an egg!</B>"), 1)
		new /obj/effect/alien/egg(loc)
	return