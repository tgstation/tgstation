/obj/item/projectile/hivebotbullet
	damage = 10
	damage_type = BRUTE

/mob/living/simple_animal/hostile/hivebot
	name = "hivebot"
	desc = "A small robot."
	icon = 'icons/mob/hivebot.dmi'
	icon_state = "basic"
	icon_living = "basic"
	icon_dead = "basic"
	gender = NEUTER
	mob_biotypes = list(MOB_ROBOTIC)
	health = 15
	maxHealth = 15
	healable = 0
	melee_damage_lower = 2
	melee_damage_upper = 3
	attacktext = "claws"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	projectilesound = 'sound/weapons/gunshot.ogg'
	projectiletype = /obj/item/projectile/hivebotbullet
	faction = list("hivebot")
	check_friendly_fire = 1
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	verb_say = "states"
	verb_ask = "queries"
	verb_exclaim = "declares"
	verb_yell = "alarms"
	bubble_icon = "machine"
	speech_span = SPAN_ROBOT
	gold_core_spawnable = HOSTILE_SPAWN
	del_on_death = 1
	loot = list(/obj/effect/decal/cleanable/robot_debris)

	do_footstep = TRUE

/mob/living/simple_animal/hostile/hivebot/Initialize()
	. = ..()
	deathmessage = "[src] blows apart!"

/mob/living/simple_animal/hostile/hivebot/Aggro()
	. = ..()
	a_intent = INTENT_HARM
	update_icons()
	if(prob(5))
		say(pick("INTRUDER DETECTED!", "CODE 7-34.", "101010!!"), forced = type)

/mob/living/simple_animal/hostile/hivebot/LoseAggro()
	. = ..()
	a_intent = INTENT_HELP
	update_icons()

/mob/living/simple_animal/hostile/hivebot/verb/hivebot_intent()
	set name = "Change Alert Level"
	set category = "IC"
	if(a_intent != INTENT_HELP)
		a_intent = INTENT_HELP
	else
		a_intent = INTENT_HARM
	update_icons()

/mob/living/simple_animal/hostile/hivebot/update_icons()
	if(a_intent != INTENT_HELP)
		icon_state = "[initial(icon_state)]_attack"
	else
		icon_state = initial(icon_state)

/mob/living/simple_animal/hostile/hivebot/range
	name = "hivebot"
	desc = "A smallish robot, this one is armed!"
	icon_state = "ranged"
	icon_living = "ranged"
	icon_dead = "ranged"
	ranged = 1
	retreat_distance = 5
	minimum_distance = 5

/mob/living/simple_animal/hostile/hivebot/rapid
	icon_state = "ranged"
	icon_living = "ranged"
	icon_dead = "ranged"
	ranged = 1
	rapid = 3
	retreat_distance = 5
	minimum_distance = 5

/mob/living/simple_animal/hostile/hivebot/strong
	name = "strong hivebot"
	icon_state = "strong"
	icon_living = "strong"
	icon_dead = "strong"
	desc = "A robot, this one is armed and looks tough!"
	health = 80
	maxHealth = 80
	ranged = 1

/mob/living/simple_animal/hostile/hivebot/death(gibbed)
	do_sparks(3, TRUE, src)
	..(1)
