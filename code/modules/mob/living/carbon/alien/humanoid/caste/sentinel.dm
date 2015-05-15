/mob/living/carbon/alien/humanoid/sentinel
	name = "alien sentinel"
	caste = "s"
	maxHealth = 125
	health = 125
	storedPlasma = 100
	max_plasma = 250
	icon_state = "aliens_s"
	plasma_rate = 10


/mob/living/carbon/alien/humanoid/sentinel/New()
	create_reagents(100)
	if(name == "alien sentinel")
		name = text("alien sentinel ([rand(1, 1000)])")
	real_name = name

	AddAbility(new/obj/effect/proc_holder/alien/acid(null))
	AddAbility(new/obj/effect/proc_holder/alien/neurotoxin(null))

	..()

/mob/living/carbon/alien/humanoid/sentinel/handle_hud_icons_health()
	if (healths)
		if (stat != 2)
			switch(health)
				if(125 to INFINITY)
					healths.icon_state = "health0"
				if(100 to 125)
					healths.icon_state = "health1"
				if(75 to 100)
					healths.icon_state = "health2"
				if(50 to 75)
					healths.icon_state = "health3"
				if(25 to 50)
					healths.icon_state = "health4"
				if(0 to 25)
					healths.icon_state = "health5"
				else
					healths.icon_state = "health6"
		else
			healths.icon_state = "health7"

/mob/living/carbon/alien/humanoid/sentinel/movement_delay()
	. = ..()
	. += 1