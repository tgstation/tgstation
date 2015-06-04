

/mob/living/simple_animal/hostile/carp/eyeball
	name = "eyeball"
	desc = "An odd looking creature, it won't stop staring..."
	icon_state = "eyeball"
	icon_living = "eyeball"
	icon_gib = ""
	response_help = "pets"
	response_disarm = "gently pushes aside"
	response_harm = "hits"
	maxHealth = 45
	health = 45
	speak_emote = list("telepathically cries")

	harm_intent_damage = 15
	melee_damage_lower = 20
	melee_damage_upper = 25
	attacktext = "blinks at"
	attack_sound = 'sound/weapons/pierce.ogg'
	flying = 1

	faction = list("spooky")


/mob/living/simple_animal/hostile/carp/eyeball/FindTarget()
	. = ..()
	if(.)
		emote("me", 1, "glares at [.]")

/mob/living/simple_animal/hostile/carp/eyeball/death()
	..(1)
	ghostize()
	qdel(src)
