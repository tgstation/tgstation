/datum/round_event_control/wizard/invincible //Boolet Proof
	name = "Invincibility"
	typepath = /datum/round_event/wizard/invincible/
	max_occurrences = 5

/datum/round_event/wizard/invincible/start()

	for(var/mob/living/carbon/human/H in living_mob_list)
		H.reagents.add_reagent("adminordrazine", 40) //100 ticks of absolute invinciblity (barring gibs)
		H << "<span class='notice'>You feel invincible, nothing can hurt you!</span>"