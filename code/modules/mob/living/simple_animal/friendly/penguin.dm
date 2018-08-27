//Penguins

/mob/living/simple_animal/pet/penguin
	response_help  = "pets"
	response_disarm = "bops"
	response_harm   = "kicks"
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

	do_footstep = TRUE

/mob/living/simple_animal/pet/penguin/emperor
	name = "Emperor penguin"
	real_name = "penguin"
	desc = "Emperor of all they survey."
	icon_state = "penguin"
	icon_living = "penguin"
	icon_dead = "penguin_dead"
	butcher_results = list()
	gold_core_spawnable = FRIENDLY_SPAWN

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
