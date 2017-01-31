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
	projectilesound = 'sound/weapons/Gunshot.ogg'
	projectiletype = /obj/item/projectile/hivebotbullet
	faction = list("hivebot")
	check_friendly_fire = 1
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	speak_emote = list("states")
	gold_core_spawnable = 1
	del_on_death = 1
	loot = list(/obj/effect/decal/cleanable/robot_debris)

/mob/living/simple_animal/hostile/hivebot/New()
	..()
	deathmessage = "[src] blows apart!"

/mob/living/simple_animal/hostile/hivebot/range
	name = "hivebot"
	desc = "A smallish robot, this one is armed!"
	ranged = 1
	retreat_distance = 5
	minimum_distance = 5

/mob/living/simple_animal/hostile/hivebot/rapid
	ranged = 1
	rapid = 1
	retreat_distance = 5
	minimum_distance = 5

/mob/living/simple_animal/hostile/hivebot/strong
	name = "strong hivebot"
	desc = "A robot, this one is armed and looks tough!"
	health = 80
	maxHealth = 80
	ranged = 1

/mob/living/simple_animal/hostile/hivebot/worker
	name = "worker hivebot"
	desc = "A cute little yellow robot. It has tiny little tools on its arms."
	icon_state = "EngBot"
	health = 100
	maxHealth = 100
	healable = 1 //pet magic!
	faction = list("hivebot", "neutral")
	gold_core_spawnable = 0
	wander = 0
	var/obj/item/device/hivebot_crux/parent //The parent crux for this worker

/mob/living/simple_animal/hostile/hivebot/worker/New()
	..()
	if(prob(1) && name == initial(name)) //Only rename if we don't have a custom name
		name = "bee hive bot"
		desc = "According to all known laws of aviation..."

/mob/living/simple_animal/hostile/hivebot/worker/Life()
	..()
	if(loc != get_turf(parent) && parent.current_orders == HIVEBOT_CRUX_IDLE)
		visible_message("<span class='warning'>[src] warps away!</span>")
		qdel(src)

/mob/living/simple_animal/hostile/hivebot/death(gibbed)
	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(3, 1, src)
	s.start()
	..(1)