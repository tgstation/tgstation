/mob/living/carbon/alien/humanoid/queen
	name = "alien queen" //The alien queen, not Alien Queen. Even if there's only one at a time
	caste = "q"
	maxHealth = 300
	health = 300
	icon_state = "alienq_s"
	status_flags = CANPARALYSE
	heal_rate = 5
	plasma_rate = 20

/mob/living/carbon/alien/humanoid/queen/movement_delay()
	return (5 + move_delay_add + config.alien_delay) //Queens are slow as fuck

/mob/living/carbon/alien/humanoid/queen/New()
	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src

	//there should only be one queen
	for(var/mob/living/carbon/alien/humanoid/queen/Q in living_mob_list)
		if(Q == src)
			continue
		if(Q.stat == DEAD)
			continue
		if(Q.client)
			name = "alien princess ([rand(1, 999)])"	//if this is too cutesy feel free to change it/remove it.
			break

	real_name = src.name
	verbs.Add(/mob/living/carbon/alien/humanoid/proc/corrosive_acid,/mob/living/carbon/alien/humanoid/proc/neurotoxin,/mob/living/carbon/alien/humanoid/proc/resin)
	..()
	verbs -= /mob/living/carbon/alien/verb/alien_ventcrawl

/mob/living/carbon/alien/humanoid/queen

	handle_regular_hud_updates()

		..() //-Yvarov

		if(src.healths)
			if(src.stat != 2)
				switch(health)
					if(300 to INFINITY)
						src.healths.icon_state = "health0"
					if(200 to 300)
						src.healths.icon_state = "health1"
					if(125 to 200)
						src.healths.icon_state = "health2"
					if(75 to 125)
						src.healths.icon_state = "health3"
					if(0 to 75)
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
		src << "<span class='warning'>There's already an egg here.</span>"
		return

	if(powerc(75, 1))//Can't plant eggs on spess tiles. That's silly.
		adjustToxLoss(-75)
		visible_message("\green <B>[src] has laid an egg!</B>")
		new /obj/effect/alien/egg(loc)
	return


/mob/living/carbon/alien/humanoid/queen/large
	icon = 'icons/mob/alienqueen.dmi'
	icon_state = "queen_s"
	pixel_x = -16

/mob/living/carbon/alien/humanoid/queen/large/update_icons()
	lying_prev = lying	//so we don't update overlays for lying/standing unless our stance changes again
	update_hud()		//TODO: remove the need for this to be here
	overlays.Cut()
	if(lying)
		if(resting)					icon_state = "queen_sleep"
		else						icon_state = "queen_l"
		for(var/image/I in overlays_lying)
			overlays += I
	else
		icon_state = "queen_s"
		for(var/image/I in overlays_standing)
			overlays += I