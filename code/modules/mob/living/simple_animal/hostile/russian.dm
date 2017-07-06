/mob/living/simple_animal/hostile/russian
	name = "Russian Comrade"
	desc = "For the Motherland!"
	icon = 'icons/mob/russians.dmi'
	icon_state = "russian_grunt"
	icon_living = "russian_grunt"
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
	a_intent = INTENT_HARM
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 15
	faction = list("russian")
	status_flags = CANPUSH
	del_on_death = 1

	var/ammo_left = 7
	var/max_ammo = 7
	var/reloads_left = 3

	casingtype = /obj/item/ammo_casing/n762
	harm_intent_damage = 5
	melee_damage_lower = 15
	melee_damage_upper = 15

	var/grenades_left = 3
	var/grenade_to_throw = /obj/item/weapon/grenade/syndieminibomb/concussion/frag

	ai_type = /datum/goap_agent/russian


/mob/living/simple_animal/hostile/russian/death()
	..()
	gib()

/mob/living/simple_animal/hostile/russian/medic
	name = "Russian Nechaev"
	icon_state = "russian_medic"
	icon_living = "russian_medic"
	casingtype = /obj/item/ammo_casing/n762
	grenade_to_throw = null
	ai_type = /datum/goap_agent/russian/medic

/mob/living/simple_animal/hostile/russian/engineer
	name = "Russian Kalashnikov" // i cant wait for the "WHY IS THERE A GUY NAMED AFTER A GUN???" comments
	icon_state = "russian_engineer"
	icon_living = "russian_engineer"
	ammo_left = 5
	max_ammo = 5
	casingtype = /obj/item/ammo_casing/shotgun
	grenade_to_throw = /obj/item/weapon/grenade/flashbang
	ai_type = /datum/goap_agent/russian/engineer

/mob/living/simple_animal/hostile/russian/sniper
	name = "Russian Zaytsev"
	icon_state = "russian_sniper"
	icon_living = "russian_sniper"
	ammo_left = 3
	max_ammo = 3
	casingtype = /obj/item/ammo_casing/point50
	grenade_to_throw = /obj/item/weapon/grenade/smokebomb
	ai_type = /datum/goap_agent/russian_sniper

