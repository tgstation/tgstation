//Gondolas

/mob/living/simple_animal/pet/gondola
	name = "gondola"
	real_name = "gondola"
	desc = "Gondola is the silent walker. Having no hands he embodies the Taoist principle of wu-wei (non-action) while his smiling facial expression shows his utter and complete acceptance of the world as it is. Its hide is extremely valuable."
	response_help  = "pets"
	response_disarm = "bops"
	response_harm   = "kicks"
	emote_see = list("watches.", "stares off into the distance.","contemplates.")
	faction = list("gondola")
	see_in_dark = 5
	speak_chance = 1
	turns_per_move = 10
	icon = 'icons/mob/gondolas.dmi'
	icon_state = "gondola"
	icon_living = "gondola"
	icon_dead = "gondola_dead"
	butcher_results = list(/obj/item/stack/sheet/animalhide/gondola = 1)
	//Gondolas aren't affected by cold.
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 1500

/mob/living/simple_animal/pet/gondola/IsVocal() //Gondolas are the silent walker.
	return 0

/mob/living/simple_animal/pet/gondola/emote()
	return