//Penguins

/mob/living/simple_animal/pet/penguin
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "bops"
	response_disarm_simple = "bop"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	speak = list("Gah Gah!", "NOOT NOOT!", "NOOT!", "Noot", "noot", "Prah!", "Grah!")
	speak_emote = list("squawks", "gakkers")
	emote_hear = list("squawk!", "gakkers!", "noots.","NOOTS!")
	emote_see = list("shakes its beak.", "flaps it's wings.","preens itself.")
	faction = list("penguin")
	minbodytemp = 0
	see_in_dark = 5
	speak_chance = 1
	turns_per_move = 10
	icon = 'icons/mob/penguins.dmi'
	butcher_results = list(/obj/item/organ/ears/penguin = 1, /obj/item/reagent_containers/food/snacks/meat/slab/penguin = 3)

	footstep_type = FOOTSTEP_MOB_BAREFOOT

/mob/living/simple_animal/pet/penguin/Initialize()
	. = ..()
	AddElement(/datum/element/waddling)

/mob/living/simple_animal/pet/penguin/emperor
	name = "Emperor penguin"
	real_name = "penguin"
	desc = "Emperor of all they survey."
	icon_state = "penguin"
	icon_living = "penguin"
	icon_dead = "penguin_dead"
	gold_core_spawnable = FRIENDLY_SPAWN
	butcher_results = list(/obj/item/organ/ears/penguin = 1, /obj/item/reagent_containers/food/snacks/meat/slab/penguin = 3)

/mob/living/simple_animal/pet/penguin/emperor/shamebrero
	name = "Shamebrero penguin"
	desc = "Shameful of all he surveys."
	icon_state = "penguin_shamebrero"
	icon_living = "penguin_shamebrero"
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE

/mob/living/simple_animal/pet/penguin/baby
	speak = list("gah", "noot noot", "noot!", "noot", "squeee!", "noo!")
	name = "Penguin chick"
	real_name = "penguin"
	desc = "Can't fly and barely waddles, yet the prince of all chicks."
	icon_state = "penguin_baby"
	icon_living = "penguin_baby"
	icon_dead = "penguin_baby_dead"
	density = FALSE
	pass_flags = PASSMOB
	mob_size = MOB_SIZE_SMALL
	butcher_results = list(/obj/item/organ/ears/penguin = 1, /obj/item/reagent_containers/food/snacks/meat/slab/penguin = 1)

/mob/living/simple_animal/pet/penguin/attack_hand(mob/living/carbon/human/M)
	. = ..()
	switch(M.a_intent)
		if("help")
			wuv(1,M)
		if("harm")
			wuv(-1,M)

/mob/living/simple_animal/pet/penguin/proc/wuv(change, mob/M)
	if(change)
		if(change > 0)
			if(M && stat != DEAD)
				new /obj/effect/temp_visual/heart(loc)
				emote("me", 1, "honks happily!")
				SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, src, /datum/mood_event/pet_animal, src)
		else
			if(M && stat != DEAD) // Same check here, even though emote checks it as well (poor form to check it only in the help case)
				emote("me", 1, "cries and flaps its wings!")
