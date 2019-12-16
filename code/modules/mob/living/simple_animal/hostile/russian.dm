/mob/living/simple_animal/hostile/russian
	name = "Russian Comrade"
	desc = "For the Motherland!"
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "russianmelee"
	icon_living = "russianmelee"
	icon_dead = "russianmelee_dead"
	icon_gib = "syndicate_gib"
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	speak_chance = 0
	turns_per_move = 5
	speed = 0
	maxHealth = 100
	health = 100
	harm_intent_damage = 5
	melee_damage_lower = 15
	melee_damage_upper = 15
	attack_verb_continuous = "punches"
	attack_verb_simple = "punch"
	attack_sound = 'sound/weapons/punch1.ogg'
	a_intent = INTENT_HARM
	loot = list(/obj/effect/mob_spawn/human/corpse/russian,
				/obj/item/kitchen/knife)
	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 15
	faction = list("russian")
	weather_immunities = list("lava","ash")
	status_flags = CANPUSH
	del_on_death = 1
	footstep_type = FOOTSTEP_MOB_SHOE
	var/datum/goap_agent/goap_ai
	var/ai_type = /datum/goap_agent/russian_melee

/mob/living/simple_animal/hostile/russian/ranged
	icon_state = "russianranged"
	icon_living = "russianranged"
	loot = list(/obj/effect/mob_spawn/human/corpse/russian/ranged,
				/obj/item/gun/ballistic/revolver/nagant)
	ranged = TRUE
	check_friendly_fire = TRUE
	retreat_distance = 5
	minimum_distance = 5
	projectilesound = 'sound/weapons/gun/revolver/shot.ogg'
	casingtype = /obj/item/ammo_casing/n762
	var/ammo_left = 7
	var/max_ammo = 7
	var/reloads_left = 3
	var/grenades_left = 3
	var/grenade_to_throw = /obj/item/grenade/iedcasing
	ai_type = /datum/goap_agent/russian

/mob/living/simple_animal/hostile/russian/Initialize(mapload)
	. = ..()
	toggle_ai(AI_OFF) // they don't need to wander
	goap_ai = new ai_type
	goap_ai.agent = src
	goap_ai.movetype = MOVETYPE_FAKESTAR

/mob/living/simple_animal/hostile/russian/ranged/mosin
	loot = list(/obj/effect/mob_spawn/human/corpse/russian/ranged,
				/obj/item/gun/ballistic/rifle/boltaction)
	casingtype = /obj/item/ammo_casing/a762

/mob/living/simple_animal/hostile/russian/ranged/trooper
	icon_state = "russianrangedelite"
	icon_living = "russianrangedelite"
	maxHealth = 150
	health = 150
	casingtype = /obj/item/ammo_casing/shotgun/buckshot
	loot = list(/obj/effect/mob_spawn/human/corpse/russian/ranged/trooper,
				/obj/item/gun/ballistic/shotgun/lethal)

/mob/living/simple_animal/hostile/russian/ranged/officer
	name = "Russian Officer"
	icon_state = "russianofficer"
	icon_living = "russianofficer"
	maxHealth = 65
	health = 65
	rapid = 3
	casingtype = /obj/item/ammo_casing/c9mm
	loot = list(/obj/effect/mob_spawn/human/corpse/russian/ranged/officer,
				/obj/item/gun/ballistic/automatic/pistol/APS)
	casingtype = /obj/item/ammo_casing/a762
	harm_intent_damage = 5
	melee_damage_lower = 15
	melee_damage_upper = 15


/mob/living/simple_animal/hostile/russian/death()
	..()
	gib()

/mob/living/simple_animal/hostile/russian/ranged/medic
	name = "Russian Nechaev"
	icon_state = "russian_medic"
	icon_living = "russian_medic"
	casingtype = /obj/item/ammo_casing/a762
	grenade_to_throw = null
	ai_type = /datum/goap_agent/russian/medic

/mob/living/simple_animal/hostile/russian/ranged/engineer
	name = "Russian Kalashnikov" // i cant wait for the "WHY IS THERE A GUY NAMED AFTER A GUN???" comments
	icon_state = "russian_engineer"
	icon_living = "russian_engineer"
	ammo_left = 5
	max_ammo = 5
	casingtype = /obj/item/ammo_casing/shotgun
	grenade_to_throw = /obj/item/grenade/flashbang
	ai_type = /datum/goap_agent/russian/engineer

/mob/living/simple_animal/hostile/russian/ranged/sniper
	name = "Russian Zaytsev"
	icon_state = "russian_sniper"
	icon_living = "russian_sniper"
	ammo_left = 3
	max_ammo = 3
	casingtype = /obj/item/ammo_casing/a357
	grenade_to_throw = /obj/item/grenade/smokebomb
	ai_type = /datum/goap_agent/russian_sniper

