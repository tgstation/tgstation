/mob/living/simple_animal/puddi
	name = "Living Puddi"
	desc = "It's jigglier than usual!"
	icon_state = "livingpuddi"
	icon_living = "livingpuddi"
	icon_dead = "livingpuddi-dead"
	health = 30
	maxHealth = 30
	speak = list("Puddi!")
	speak_emote = list("shouts")
	emote_hear = list("shouts")
	emote_see = list("shouts")
	speak_chance = 1
	turns_per_move = 10
	response_help  = "pats"
	response_disarm = "squishes"
	response_harm   = "slaps"

	meat_type = null

/mob/living/simple_animal/puddi/happy
	icon_state = "livingpuddi-happy"
	icon_living = "livingpuddi-happy"
	icon_dead = "livingpuddi-happy-dead"
	turns_per_move = 5

/mob/living/simple_animal/puddi/anger
	icon_state = "livingpuddi-anger"
	icon_living = "livingpuddi-anger"
	icon_dead = "livingpuddi-anger-dead"
	speak = list("PUDDI!")
	response_harm   = "stomps"
	turns_per_move = 2