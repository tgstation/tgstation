/datum/round_event_control/wizard/invincible //Boolet Proof
	name = "Invincibility"
	weight = 3
	typepath = /datum/round_event/wizard/invincible
	max_occurrences = 5
	earliest_start = 0 MINUTES

/datum/round_event/wizard/invincible/start()

	for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
<<<<<<< HEAD
		H.reagents.add_reagent(/datum/reagent/medicine/adminordrazine, 40) //100 ticks of absolute invinciblity (barring gibs)
=======
		H.reagents.add_reagent("adminordrazine", 40) //100 ticks of absolute invinciblity (barring gibs)
>>>>>>> Updated this old code to fork
		to_chat(H, "<span class='notice'>You feel invincible, nothing can hurt you!</span>")