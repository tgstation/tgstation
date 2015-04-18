//oo oo ah ah
/mob/living/simple_animal/gorilla
	name = "Space Gorilla"
	desc = "A space gorilla."
	icon_state = "spacegoriilla"
	icon_living = "spacegorilla"
	icon_dead = "deadgorilla"
	gender = MALE
	speak = list("OOH OOH AH AH!", "BANANA")
	speak_emote = list("chimpers")
	emote_hear = list("chimpers", "grunts")
	emote_see = list("pounds his chest", "grunts OOH OOH AH AH")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	species = /mob/living/simple_animal/gorilla
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat
	response_help  = "pats"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"