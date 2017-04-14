

/mob/living/simple_animal/hostile/carp/eyeball
	name = "eyeball"
	desc = "An odd looking creature, it won't stop staring..."
	icon_state = "eyeball"
	icon_living = "eyeball"
	icon_gib = ""
	gender = NEUTER
	response_help = "pets"
	response_disarm = "gently pushes aside"
	response_harm = "hits"
	emote_taunt = list("glares")
	taunt_chance = 25
	maxHealth = 45
	health = 45
	speak_emote = list("telepathically cries")

	harm_intent_damage = 15
	obj_damage = 60
	melee_damage_lower = 20
	melee_damage_upper = 25
	attacktext = "blinks at"
	attack_sound = 'sound/weapons/pierce.ogg'
	movement_type = FLYING

	faction = list("spooky")
	del_on_death = 1