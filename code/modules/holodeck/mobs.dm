/*
	Mobs
*/

/mob/living/simple_animal/holodeck_monkey
	name = "monkey"
	desc = "A holographic creature fond of bananas."
	icon = 'icons/mob/monkey.dmi'
	icon_state = "monkey1"
	icon_living = "monkey1"
	icon_dead = "monkey1_dead"
	speak_emote = list("chimpers")
	emote_hear = list("chimpers.")
	emote_see = list("scratches.", "looks around.")
	speak_chance = 1
	turns_per_move = 2
	butcher_results = list()
	response_help = "pets"
	response_disarm = "pushes aside"
	response_harm = "kicks"
