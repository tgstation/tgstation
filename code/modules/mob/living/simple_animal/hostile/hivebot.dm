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
	speak_emote = list("states")
	gold_core_spawnable = 1
	del_on_death = 1
	loot = list(/obj/effect/decal/cleanable/robot_debris)

/mob/living/simple_animal/hostile/hivebot/Initialize()
	..()
	deathmessage = "[src] blows apart!"

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
	rapid = 1
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

/mob/living/simple_animal/hostile/hivebot/engineer
	name = "engineer hivebot"
	desc = "A little robot with a tiny welder on its arm."
	icon_state = "EngBot"
	health = 25
	maxHealth = 25
	melee_damage_lower = 0
	melee_damage_upper = 0
	ranged = 1
	retreat_distance = 2
	minimum_distance = 2

/mob/living/simple_animal/hostile/hivebot/engineer/handle_automated_action()
	..()
	for(var/obj/machinery/hivebot_swarm_core/C in view(5, src))
		if(C.obj_integrity < C.max_integrity)
			if(!Adjacent(C))
				Goto(C, 5)
			else
				visible_message("<span class='warning'>[src] welds some of the dents on [C]!</span>")
				playsound(C, 'sound/items/Welder.ogg', 50, 1)
				C.obj_integrity = min(C.obj_integrity + 20, C.max_integrity)
			break

/mob/living/simple_animal/hostile/hivebot/death(gibbed)
	do_sparks(3, TRUE, src)
	..(1)