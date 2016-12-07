/mob/living/simple_animal/hostile/retaliate/spaceman
	name = "Spaceman"
	desc = "What in the actual hell..?"
	icon_state = "old"
	icon_living = "old"
	icon_dead = "old_dead"
	icon_gib = "clown_gib"
	gender = MALE
	turns_per_move = 5
	response_help = "pokes"
	response_disarm = "gently pushes aside"
	response_harm = "punches"
	a_intent = INTENT_HARM
	maxHealth = 100
	health = 100
	speed = 0
	harm_intent_damage = 8
	melee_damage_lower = 10
	melee_damage_upper = 10
	attacktext = "hits"
	attack_sound = 'sound/weapons/punch1.ogg'
	obj_damage = 0
	environment_smash = 0
	del_on_death = 0

