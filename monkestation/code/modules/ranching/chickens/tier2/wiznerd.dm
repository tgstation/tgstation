/mob/living/basic/chicken/wiznerd //No matter what you say Zanden this is staying as wiznerd
	icon_suffix = "wiznerd"

	maxHealth = 150
	melee_damage_upper = 7
	melee_damage_lower
	obj_damage = 5
	ai_controller = /datum/ai_controller/chicken/retaliate

	breed_name_female = "Witchen"
	breed_name_male = "Wizter"

	egg_type = /obj/item/food/egg/wiznerd
	mutation_list = list()

	projectile_type = /obj/projectile/magic/magic_missle_weak
	ranged_cooldown = 1.5 SECONDS

	book_desc = "It seems the Wizard's Federation has spread its influence into the local chicken population, Nano-Transen higher ups will look into this."
/obj/item/food/egg/wiznerd
	name = "Bewitching Egg"
	icon_state = "wiznerd"

	layer_hen_type = /mob/living/basic/chicken/wiznerd

/obj/item/ammo_casing/magic/magic_missle_weak
	projectile_type = /obj/projectile/magic/magic_missle_weak

/obj/projectile/magic/magic_missle_weak
	name = "magic missile"
	icon_state = "ion"
	damage = 5
	damage_type = BRUTE
