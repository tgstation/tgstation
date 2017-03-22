/datum/round_event_control/wizard/invincible //Boolet Proof
	name = "Invincibility"
	weight = 3
	typepath = /datum/round_event/wizard/invincible
	max_occurrences = 5
	earliest_start = 0

/datum/round_event/wizard/invincible/start()

	for(var/mob/living/carbon/human/H in GLOB.living_mob_list)
		H.reagents.add_reagent("adminordrazine", 40) //100 ticks of absolute invinciblity (barring gibs)
		to_chat(H, "<span class='notice'>You feel invincible, nothing can hurt you!</span>")