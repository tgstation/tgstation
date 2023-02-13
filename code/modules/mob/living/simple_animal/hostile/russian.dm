/mob/living/simple_animal/hostile/russian
	name = "Russian"
	desc = "For the Motherland!"
	icon = 'icons/mob/simple/simple_human.dmi'
	icon_state = "russianmelee"
	icon_living = "russianmelee"
	icon_dead = "russianmelee_dead"
	icon_gib = "syndicate_gib"
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	sentience_type = SENTIENCE_HUMANOID
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
	combat_mode = TRUE
	loot = list(/obj/effect/mob_spawn/corpse/human/russian,
				/obj/item/knife/kitchen)
	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 7.5
	faction = list("russian")
	status_flags = CANPUSH
	footstep_type = FOOTSTEP_MOB_SHOE
	del_on_death = TRUE
	/// The mob spawner we base the icon off of.
	var/mob_spawner = /obj/effect/mob_spawn/corpse/human/russian
	/// The item the icon will hold.
	var/held_item = /obj/item/knife/kitchen

/mob/living/simple_animal/hostile/russian/Initialize(mapload)
	. = ..()
	apply_dynamic_human_icon(src, mob_spawn_path = mob_spawner, r_hand = held_item)

/mob/living/simple_animal/hostile/russian/ranged
	icon_state = "russianranged"
	icon_living = "russianranged"
	loot = list(/obj/effect/mob_spawn/corpse/human/russian/ranged,
				/obj/item/gun/ballistic/revolver/nagant)
	ranged = TRUE
	retreat_distance = 5
	minimum_distance = 5
	projectilesound = 'sound/weapons/gun/revolver/shot.ogg'
	casingtype = /obj/item/ammo_casing/n762
	mob_spawner = /obj/effect/mob_spawn/corpse/human/russian/ranged
	held_item = /obj/item/gun/ballistic/revolver/nagant

/mob/living/simple_animal/hostile/russian/ranged/mosin
	loot = list(/obj/effect/mob_spawn/corpse/human/russian/ranged,
				/obj/item/gun/ballistic/rifle/boltaction)
	casingtype = /obj/item/ammo_casing/a762
	held_item = /obj/item/gun/ballistic/rifle/boltaction

/mob/living/simple_animal/hostile/russian/ranged/trooper
	icon_state = "russianrangedelite"
	icon_living = "russianrangedelite"
	maxHealth = 150
	health = 150
	casingtype = /obj/item/ammo_casing/shotgun/buckshot
	loot = list(/obj/effect/mob_spawn/corpse/human/russian/ranged/trooper,
				/obj/item/gun/ballistic/shotgun/lethal)
	mob_spawner = /obj/effect/mob_spawn/corpse/human/russian/ranged/trooper
	held_item = /obj/item/gun/ballistic/shotgun/lethal

/mob/living/simple_animal/hostile/russian/ranged/officer
	name = "Russian Officer"
	icon_state = "russianofficer"
	icon_living = "russianofficer"
	maxHealth = 65
	health = 65
	rapid = 3
	casingtype = /obj/item/ammo_casing/c9mm
	loot = list(/obj/effect/mob_spawn/corpse/human/russian/ranged/officer,
				/obj/item/gun/ballistic/automatic/pistol/aps)
	mob_spawner = /obj/effect/mob_spawn/corpse/human/russian/ranged/officer
	held_item = /obj/item/gun/ballistic/automatic/pistol/aps

/mob/living/simple_animal/hostile/russian/ranged/officer/Aggro()
	..()
	summon_backup(15)
	say("V BOJ!!")
