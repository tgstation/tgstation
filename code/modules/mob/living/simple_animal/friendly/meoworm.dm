/mob/living/simple_animal/meoworm
	name = "Meoworm"
	desc = "A tiny worm famous for it's obnoxiously loud mating call, which strikes fear into some spacefarers."
	icon_state = "meoworm"
	icon_living = "meoworm"
	icon_dead = "meoworm_dead"
	turns_per_move = 1
	response_help = "touches"
	response_disarm = "brushes aside"
	response_harm = "squashes"
	speak_emote = list("meows")
	maxHealth = 2
	health = 2
	harm_intent_damage = 1
	friendly = "nudges"
	density = FALSE
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	ventcrawler = VENTCRAWLER_ALWAYS
	mob_size = MOB_SIZE_TINY
	mob_biotypes = list(MOB_ORGANIC, MOB_BUG)
	gold_core_spawnable = FRIENDLY_SPAWN
	verb_say = "meows"
	verb_ask = "meows inquisitively"
	verb_exclaim = "meows intensely"
	verb_yell = "meows intensely"
	speak_chance = 30


/mob/living/simple_animal/meoworm/handle_automated_speech(override)
	if(speak_chance && (override || prob(speak_chance)))
		icon_state = "meoworm_roar"
		playsound(src, 'sound/creatures/loud_meow.ogg', 200)
		addtimer(CALLBACK(src, .proc/resetSprite), 15)
	..()

/mob/living/simple_animal/meoworm/proc/resetSprite()
	if(stat != DEAD)
		icon_state = initial(icon_state)
