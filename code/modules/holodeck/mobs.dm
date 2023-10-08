/*
	Mobs
*/

/mob/living/simple_animal/holodeck_monkey
	name = "monkey"
	desc = "A holographic creature fond of bananas."
	icon = 'icons/mob/human/human.dmi'
	icon_state = "monkey"
	icon_living = "monkey"
	icon_dead = "monkey_dead"
	speak_emote = list("chimpers")
	emote_hear = list("chimpers.")
	emote_see = list("scratches.", "looks around.")
	speak_chance = 1
	turns_per_move = 2
	butcher_results = list()
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "pushes aside"
	response_disarm_simple = "push aside"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
