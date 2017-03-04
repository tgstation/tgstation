/mob/living/simple_animal/hostile/nanotrasen
	name = "Nanotrasen Private Security Officer"
	desc = "An officer part of Nanotrasen's private security force, he seems rather unpleased to meet you."
	icon_state = "nanotrasen"
	icon_living = "nanotrasen"
	icon_dead = null
	icon_gib = "syndicate_gib"
	speak_chance = 12
	turns_per_move = 5
	response_help = "pokes"
	response_disarm = "shoves"
	response_harm = "hits"
	speed = 0
	stat_attack = 1
	robust_searching = 1
	maxHealth = 100
	health = 100
	harm_intent_damage = 5
	melee_damage_lower = 10
	melee_damage_upper = 15
	attacktext = "punches"
	attack_sound = 'sound/weapons/punch1.ogg'
	a_intent = INTENT_HARM
	loot = list(/obj/effect/mob_spawn/human/corpse/nanotrasensoldier)
	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 15
	faction = list("nanotrasenprivate")
	status_flags = CANPUSH
	speak = list("Stop resisting!", "I AM THE LAW!", "Face the wrath of the golden bolt!", "Stop breaking the law, asshole!")
	search_objects = 1


/mob/living/simple_animal/hostile/nanotrasen/Aggro()
	..()
	summon_backup(15)
	say("411 in progress, requesting backup!")


/mob/living/simple_animal/hostile/nanotrasen/ranged
	icon_state = "nanotrasenranged"
	icon_living = "nanotrasenranged"
	ranged = 1
	retreat_distance = 3
	minimum_distance = 5
	casingtype = /obj/item/ammo_casing/c45
	projectilesound = 'sound/weapons/Gunshot.ogg'
	loot = list(/obj/item/weapon/gun/ballistic/automatic/pistol/m1911,
				/obj/effect/mob_spawn/human/corpse/nanotrasensoldier)


/mob/living/simple_animal/hostile/nanotrasen/ranged/smg
	icon_state = "nanotrasenrangedsmg"
	icon_living = "nanotrasenrangedsmg"
	rapid = 1
	casingtype = /obj/item/ammo_casing/c46x30mm
	projectilesound = 'sound/weapons/Gunshot_smg.ogg'
	loot = list(/obj/item/weapon/gun/ballistic/automatic/wt550,
				/obj/effect/mob_spawn/human/corpse/nanotrasensoldier)