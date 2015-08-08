/mob/living/carbon/alien/humanoid/queen
	name = "alien queen"
	caste = "q"
	maxHealth = 250
	health = 250
	icon_state = "alienq_s"
	status_flags = CANPARALYSE
	heal_rate = 5
	plasma_rate = 20
	ventcrawler = 0 //pull over that ass too fat


/mob/living/carbon/alien/humanoid/queen/New()
	create_reagents(100)

	//there should only be one queen
	for(var/mob/living/carbon/alien/humanoid/queen/Q in living_mob_list)
		if(Q == src)		continue
		if(Q.stat == DEAD)	continue
		if(Q.client)
			name = "alien princess ([rand(1, 999)])"	//if this is too cutesy feel free to change it/remove it.
			break

	real_name = src.name

	AddAbility(new/obj/effect/proc_holder/alien/acid(null))
	AddAbility(new/obj/effect/proc_holder/alien/neurotoxin(null))
	AddAbility(new/obj/effect/proc_holder/alien/resin(null))
	AddAbility(new/obj/effect/proc_holder/alien/lay_egg(null))

	..()

/mob/living/carbon/alien/humanoid/queen/handle_hud_icons_health()
	if (src.healths)
		if (src.stat != 2)
			switch(health)
				if(250 to INFINITY)
					src.healths.icon_state = "health0"
				if(200 to 250)
					src.healths.icon_state = "health1"
				if(150 to 200)
					src.healths.icon_state = "health2"
				if(100 to 150)
					src.healths.icon_state = "health3"
				if(50 to 100)
					src.healths.icon_state = "health4"
				if(0 to 50)
					src.healths.icon_state = "health5"
				else
					src.healths.icon_state = "health6"
		else
			src.healths.icon_state = "health7"

/mob/living/carbon/alien/humanoid/queen/movement_delay()
	. = ..()
	. += 5


//Queen verbs
/obj/effect/proc_holder/alien/lay_egg
	name = "Lay Egg"
	desc = "Lay an egg to produce huggers to impregnate prey with."
	plasma_cost = 75
	check_turf = 1

	action_icon_state = "alien_egg"

/obj/effect/proc_holder/alien/lay_egg/fire(mob/living/carbon/alien/user)
	if(locate(/obj/structure/alien/egg) in get_turf(user))
		user << "There's already an egg here."
		return 0
	user.visible_message("<span class='alertalien'>[user] has laid an egg!</span>")
	new /obj/structure/alien/egg(user.loc)
	return 1

/mob/living/carbon/alien/humanoid/queen/large
	icon = 'icons/mob/alienqueen.dmi'
	icon_state = "queen_s"
	pixel_x = -16
	mob_size = MOB_SIZE_LARGE

/mob/living/carbon/alien/humanoid/queen/large/update_icons()
	update_hud()		//TODO: remove the need for this to be here
	overlays.Cut()
	if(stat == DEAD)
		icon_state = "queen_dead"
	else if((stat == UNCONSCIOUS && !sleeping) || weakened)
		icon_state = "queen_l"
	else if(sleeping || lying || resting)
		icon_state = "queen_sleep"
	else
		icon_state = "queen_s"
	for(var/image/I in overlays_standing)
		overlays += I
