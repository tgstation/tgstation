/mob/living/simple_animal/hostile/carp/eyeball
	name = "eyeball"
	desc = "An odd looking creature, it won't stop staring..."
	icon_state = "eyeball"
	icon_living = "eyeball"
	icon_gib = ""
	gender = NEUTER
	mob_biotypes = MOB_ORGANIC
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	emote_taunt = list("glares")
	taunt_chance = 25
	maxHealth = 45
	health = 45
	speak_emote = list("telepathically cries")

	harm_intent_damage = 15
	obj_damage = 60
	melee_damage_lower = 20
	melee_damage_upper = 25
	attack_verb_continuous = "blinks at"
	attack_verb_simple = "blink at"
	attack_sound = 'sound/weapons/pierce.ogg'
	movement_type = FLYING

	faction = list("spooky")
	del_on_death = 1
	random_color = FALSE
