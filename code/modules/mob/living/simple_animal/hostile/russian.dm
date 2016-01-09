/mob/living/simple_animal/hostile/russian
	name = "Russian"
	desc = "For the Motherland!"
	icon_state = "russianmelee"
	icon_living = "russianmelee"
	icon_dead = "russianmelee_dead"
	icon_gib = "syndicate_gib"
	speak_chance = 0
	turns_per_move = 5
	response_help = "pokes"
	response_disarm = "shoves"
	response_harm = "hits"
	speed = 0
	maxHealth = 100
	health = 100
	harm_intent_damage = 5
	melee_damage_lower = 15
	melee_damage_upper = 15
	attacktext = "punches"
	attack_sound = 'sound/weapons/punch1.ogg'
	a_intent = "harm"
	loot = list(/obj/effect/landmark/mobcorpse/russian,
				/obj/item/weapon/kitchen/knife)
	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 15
	faction = list("russian")
	status_flags = CANPUSH
	del_on_death = 1


/mob/living/simple_animal/hostile/russian/ranged
	icon_state = "russianranged"
	icon_living = "russianranged"
	loot = list(/obj/effect/landmark/mobcorpse/russian/ranged,
				/obj/item/weapon/gun/projectile/revolver/mateba)
	ranged = 1
	retreat_distance = 5
	minimum_distance = 5
	projectilesound = 'sound/weapons/Gunshot.ogg'
	casingtype = /obj/item/ammo_casing/a357

/mob/living/simple_animal/hostile/russian/ranged/New()
	var/obj/item/weapon/gun/projectile/revolver/mateba/M
	if(prob(50) && is_type_in_list(M, loot)) //to preserve varedits
		loot = list(/obj/effect/landmark/mobcorpse/russian/ranged,
					/obj/item/weapon/gun/projectile/shotgun/boltaction)
		casingtype = /obj/item/ammo_casing/a762
	..()
