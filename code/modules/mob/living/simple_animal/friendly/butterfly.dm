/mob/living/simple_animal/butterfly
	name = "butterfly"
	desc = "A colorful butterfly, how'd it get up here?"
	icon_state = "butterfly"
	icon_living = "butterfly"
	icon_dead = "butterfly_dead"
	turns_per_move = 1
	response_help = "shoos"
	response_disarm = "brushes aside"
	response_harm = "squashes"
	speak_emote = list("flutters")
	maxHealth = 2
	health = 2
	harm_intent_damage = 1
	friendly = "nudges"
	density = FALSE
	movement_type = FLYING
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	ventcrawler = VENTCRAWLER_ALWAYS
	mob_size = MOB_SIZE_TINY
	gold_core_spawnable = FRIENDLY_SPAWN
	verb_say = "flutters"
	verb_ask = "flutters inquisitively"
	verb_exclaim = "flutters intensely"
	verb_yell = "flutters intensely"

/mob/living/simple_animal/butterfly/Initialize()
	. = ..()
	var/newcolor = rgb(rand(0, 255), rand(0, 255), rand(0, 255))
	add_atom_colour(newcolor, FIXED_COLOUR_PRIORITY)

/mob/living/simple_animal/butterfly/bee_friendly()
	return TRUE //treaty signed at the Beeneeva convention

/mob/living/simple_animal/fly
	name = "swarm of flies"
	desc = "You're the worst if you unironically swat other people."
	icon_state = "fly-10"
	icon_living = "fly-10"
	icon_dead = "fly_dead"
	turns_per_move = 1
	response_help = "shoos"
	response_disarm = "shoos"
	response_harm = "splats"
	speak_emote = list("buzzes")
	maxHealth = 10 //it's a swarm!!
	health = 10
	harm_intent_damage = 3 //you can only kill one of the flies in the swarm at a time
	friendly = "nudges"
	density = FALSE
	movement_type = FLYING
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	ventcrawler = VENTCRAWLER_ALWAYS
	mob_size = MOB_SIZE_TINY
	gold_core_spawnable = FRIENDLY_SPAWN
	verb_say = "buzzes"
	verb_ask = "buzzes inquisitively"
	verb_exclaim = "buzzes intensely"
	verb_yell = "buzzes intensely"

/mob/living/simple_animal/fly/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	health --
	visible_message("the fly stops moving...")
	icon_state = "fly-[health]"
	maxHealth = health //can't revive flies.

/mob/living/simple_animal/fly/time
	name = "swarm of time flies"
