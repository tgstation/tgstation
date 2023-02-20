/mob/living/simple_animal/hostile/nanotrasen
	name = "\improper Nanotrasen Private Security Officer"
	desc = "An officer part of Nanotrasen's private security force, he seems rather unpleased to meet you."
	icon = 'icons/mob/simple/simple_human.dmi'
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	sentience_type = SENTIENCE_HUMANOID
	speak_chance = 0
	turns_per_move = 5
	speed = 0
	stat_attack = HARD_CRIT
	robust_searching = 1
	maxHealth = 100
	health = 100
	harm_intent_damage = 5
	melee_damage_lower = 10
	melee_damage_upper = 15
	attack_verb_continuous = "punches"
	attack_verb_simple = "punch"
	attack_sound = 'sound/weapons/punch1.ogg'
	combat_mode = TRUE
	loot = list(/obj/effect/mob_spawn/corpse/human/nanotrasensoldier)
	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 7.5
	faction = list(ROLE_DEATHSQUAD)
	check_friendly_fire = TRUE
	status_flags = CANPUSH
	del_on_death = TRUE
	dodging = TRUE
	footstep_type = FOOTSTEP_MOB_SHOE
	/// Path of the mob spawner we base the mob's visuals off of.
	var/mob_spawner = /obj/effect/mob_spawn/corpse/human/nanotrasensoldier
	/// Path of the held item we give to the mob's visuals.
	var/held_item

/mob/living/simple_animal/hostile/nanotrasen/Initialize(mapload)
	. = ..()
	apply_dynamic_human_appearance(src, mob_spawn_path = mob_spawner, r_hand = held_item)

/mob/living/simple_animal/hostile/nanotrasen/screaming/Aggro()
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
	projectilesound = 'sound/weapons/gun/pistol/shot_alt.ogg'
	held_item = /obj/item/gun/ballistic/automatic/pistol/m1911

/mob/living/simple_animal/hostile/nanotrasen/ranged/smg
	icon_state = "nanotrasenrangedsmg"
	icon_living = "nanotrasenrangedsmg"
	rapid = 3
	casingtype = /obj/item/ammo_casing/c46x30mm
	projectilesound = 'sound/weapons/gun/smg/shot.ogg'
	held_item = /obj/item/gun/ballistic/automatic/wt550


/mob/living/simple_animal/hostile/retaliate/nanotrasenpeace
	name = "\improper Nanotrasen Private Security Officer"
	desc = "An officer part of Nanotrasen's private security force."
	icon = 'icons/mob/simple/simple_human.dmi'
	turns_per_move = 5
	speed = 0
	stat_attack = HARD_CRIT
	robust_searching = 1
	vision_range = 3
	maxHealth = 100
	health = 100
	harm_intent_damage = 5
	melee_damage_lower = 10
	melee_damage_upper = 15
	attack_verb_continuous = "punches"
	attack_verb_simple = "punch"
	attack_sound = 'sound/weapons/punch1.ogg'
	faction = list("nanotrasenprivate")
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	sentience_type = SENTIENCE_HUMANOID
	combat_mode = TRUE
	loot = list(/obj/effect/mob_spawn/corpse/human/nanotrasensoldier)
	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 7.5
	status_flags = CANPUSH
	search_objects = 1
	/// Path of the held item we give to the mob's visuals.
	var/held_item

/mob/living/simple_animal/hostile/retaliate/nanotrasenpeace/Initialize(mapload)
	. = ..()
	apply_dynamic_human_appearance(src, mob_spawn_path = /obj/effect/mob_spawn/corpse/human/nanotrasensoldier, r_hand = held_item)

/mob/living/simple_animal/hostile/retaliate/nanotrasenpeace/Aggro()
	..()
	summon_backup(15)
	say("411 in progress, requesting backup!")

/mob/living/simple_animal/hostile/retaliate/nanotrasenpeace/ranged
	vision_range = 9
	rapid = 3
	ranged = 1
	retreat_distance = 3
	minimum_distance = 5
	casingtype = /obj/item/ammo_casing/c46x30mm
	projectilesound = 'sound/weapons/gun/smg/shot.ogg'
	loot = list(/obj/item/gun/ballistic/automatic/wt550,
				/obj/effect/mob_spawn/corpse/human/nanotrasensoldier)
	held_item = /obj/item/gun/ballistic/automatic/wt550
