/mob/living/simple_animal/butterfly
	name = "butterfly"
	desc = "A colorful butterfly, how'd it get up here?"
	icon_state = "butterfly"
	icon_living = "butterfly"
	icon_dead = "butterfly_dead"
	turns_per_move = 1
	emote_see = list("flutters")
	response_help = "shoos"
	response_disarm = "brushes aside"
	response_harm = "squashes"
	speak_chance = 0
	maxHealth = 2
	health = 2
	harm_intent_damage = 1
	friendly = "nudges"
	density = 0
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	ventcrawler = 2
	mob_size = MOB_SIZE_TINY

/mob/living/simple_animal/butterfly/New()
	..()
	color = rgb(rand(0, 255), rand(0, 255), rand(0, 255))