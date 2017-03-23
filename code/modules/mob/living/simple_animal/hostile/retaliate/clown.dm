/mob/living/simple_animal/hostile/retaliate/clown
	name = "Clown"
	desc = "A denizen of clown planet"
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "clown"
	icon_living = "clown"
	icon_dead = "clown_dead"
	icon_gib = "clown_gib"
	turns_per_move = 5
	response_help = "pokes"
	response_disarm = "gently pushes aside"
	response_harm = "robusts"
	speak = list("HONK", "Honk!", "Welcome to clown planet!")
	emote_see = list("honks", "squeaks")
	speak_chance = 1
	a_intent = INTENT_HARM
	maxHealth = 75
	health = 75
	speed = 0
	harm_intent_damage = 8
	melee_damage_lower = 10
	melee_damage_upper = 10
	attacktext = "attacks"
	attack_sound = 'sound/items/bikehorn.ogg'
	obj_damage = 0
	environment_smash = 0
	del_on_death = 1
	loot = list(/obj/effect/mob_spawn/human/clown/corpse)

	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 270
	maxbodytemp = 370
	unsuitable_atmos_damage = 10

/mob/living/simple_animal/hostile/retaliate/clown/handle_temperature_damage()
	if(bodytemperature < minbodytemp)
		adjustBruteLoss(10)
	else if(bodytemperature > maxbodytemp)
		adjustBruteLoss(15)

/mob/living/simple_animal/hostile/retaliate/clown/attack_hand(mob/living/carbon/human/M)
	..()
	playsound(src.loc, 'sound/items/bikehorn.ogg', 50, 1)
