/mob/living/simple_animal/hostile/pirate
	name = "Pirate"
	desc = "Does what he wants cause a pirate is free."
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "piratemelee"
	icon_living = "piratemelee"
	icon_dead = "piratemelee_dead"
	speak_chance = 0
	turns_per_move = 5
	response_help = "pushes"
	response_disarm = "shoves"
	response_harm = "hits"
	speed = 0
	maxHealth = 100
	health = 100

	harm_intent_damage = 5
	obj_damage = 60
	melee_damage_lower = 30
	melee_damage_upper = 30
	attacktext = "slashes"
	attack_sound = 'sound/weapons/bladeslice.ogg'

	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 15
	speak_emote = list("yarrs")
	loot = list(/obj/effect/mob_spawn/human/corpse/pirate,
			/obj/item/weapon/melee/energy/sword/pirate)
	del_on_death = 1
	faction = list("pirate")

/mob/living/simple_animal/hostile/pirate/ranged
	name = "Pirate Gunner"
	icon_state = "pirateranged"
	icon_living = "pirateranged"
	icon_dead = "piratemelee_dead"
	projectilesound = 'sound/weapons/laser.ogg'
	ranged = 1
	rapid = 1
	retreat_distance = 5
	minimum_distance = 5
	projectiletype = /obj/item/projectile/beam/laser
	loot = list(/obj/effect/mob_spawn/human/corpse/pirate/ranged,
			/obj/item/weapon/gun/energy/laser)

/mob/living/simple_animal/hostile/pirate/space
	name = "Space Pirate"
	icon_state = "piratespace"
	icon_living = "piratespace"
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	speed = 1

/mob/living/simple_animal/hostile/pirate/space/ranged
	name = "Space Pirate Gunner"
	icon_state = "piratespaceranged"
	icon_living = "piratespaceranged"
	projectilesound = 'sound/weapons/laser.ogg'
	ranged = 1
	rapid = 1
	retreat_distance = 5
	minimum_distance = 5
	projectiletype = /obj/item/projectile/beam/laser
	loot = list(/obj/effect/mob_spawn/human/corpse/pirate/ranged,
			/obj/item/weapon/gun/energy/laser)

/mob/living/simple_animal/hostile/pirate/space/Process_Spacemove(movement_dir = 0)
	return 1
