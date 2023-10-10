/// NanoTrasen Private Security forces
/mob/living/basic/trooper/nanotrasen
	name = "\improper Nanotrasen Private Security Officer"
	desc = "An officer of Nanotrasen's private security force. Seems rather unpleased to meet you."
	speed = 0
	melee_damage_lower = 10
	melee_damage_upper = 15
	combat_mode = TRUE
	loot = list(/obj/effect/mob_spawn/corpse/human/nanotrasensoldier)
	faction = list(ROLE_DEATHSQUAD)
	//dodging = TRUE
	mob_spawner = /obj/effect/mob_spawn/corpse/human/nanotrasensoldier

/mob/living/simple_animal/hostile/nanotrasen/screaming/Aggro()
	..()
	summon_backup(15)
	say("411 in progress, requesting backup!")

/mob/living/basic/trooper/nanotrasen/ranged
	ai_controller = /datum/ai_controller/basic_controller/trooper/ranged/avoid_friendly_fire
	r_hand = /obj/item/gun/ballistic/automatic/pistol/m1911
	/// Type of bullet we use
	var/casingtype = /obj/item/ammo_casing/c45
	/// Sound to play when firing weapon
	var/projectilesound = 'sound/weapons/gun/pistol/shot_alt.ogg'
	/// number of burst shots
	var/burst_shots
	/// Time between taking shots
	var/ranged_cooldown = 1 SECONDS

/mob/living/basic/trooper/nanotrasen/ranged/Initialize(mapload)
	. = ..()
	AddComponent(\
		/datum/component/ranged_attacks,\
		casing_type = casingtype,\
		projectile_sound = projectilesound,\
		cooldown_time = ranged_cooldown,\
		burst_shots = burst_shots,\
	)

/mob/living/basic/trooper/nanotrasen/ranged/smg
	casingtype = /obj/item/ammo_casing/c46x30mm
	projectilesound = 'sound/weapons/gun/smg/shot.ogg'
	r_hand = /obj/item/gun/ballistic/automatic/wt550
	burst_shots = 3
	ranged_cooldown = 3 SECONDS

/// Should use "retaliate" AI...
/mob/living/basic/trooper/nanotrasen/peaceful
	desc = "An officer of Nanotrasen's private security force."
	//vision_range = 3

/mob/living/simple_animal/hostile/retaliate/nanotrasenpeace/Aggro()
	..()
	summon_backup(15)
	say("411 in progress, requesting backup!")

/mob/living/basic/trooper/nanotrasen/peace/ranged
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
