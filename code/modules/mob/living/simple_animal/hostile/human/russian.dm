/mob/living/simple_animal/hostile/humanoid/russian
	name = "Russian"
	desc = "For the Motherland!"
	icon_state = "russianmelee"
	icon_living = "russianmelee"
	icon_dead = "russianmelee_dead"
	icon_gib = "syndicate_gib"
	speak_chance = 0

	melee_damage_lower = 15
	melee_damage_upper = 15

	corpse = /obj/effect/landmark/corpse/russian
	items_to_drop = list(/obj/item/weapon/kitchen/utensil/knife/large)

	faction = "russian"


/mob/living/simple_animal/hostile/humanoid/russian/ranged
	icon_state = "russianranged"
	icon_living = "russianranged"

	corpse = /obj/effect/landmark/corpse/russian/ranged
	items_to_drop = list(/obj/item/weapon/gun/projectile/mateba)

	melee_damage_lower = 5
	melee_damage_upper = 5

	ranged = 1
	retreat_distance = 5
	minimum_distance = 5
	projectiletype = /obj/item/projectile/bullet
	projectilesound = 'sound/weapons/Gunshot.ogg'
	casingtype = /obj/item/ammo_casing/a357
