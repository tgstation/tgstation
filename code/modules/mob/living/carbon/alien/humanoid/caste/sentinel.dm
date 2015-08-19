/mob/living/carbon/alien/humanoid/sentinel
	name = "alien sentinel"
	caste = "s"
	maxHealth = 125
	health = 125
	icon_state = "aliens_s"


/mob/living/carbon/alien/humanoid/sentinel/New()
	internal_organs += new /obj/item/organ/internal/alien/plasmavessel
	internal_organs += new /obj/item/organ/internal/alien/acid
	internal_organs += new /obj/item/organ/internal/alien/neurotoxin
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