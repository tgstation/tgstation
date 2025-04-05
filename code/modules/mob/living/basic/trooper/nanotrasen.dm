/// Nanotrasen Private Security forces
/mob/living/basic/trooper/nanotrasen
	name = "\improper Nanotrasen Private Security Officer"
	desc = "An officer of Nanotrasen's private security force. Seems rather unpleased to meet you."
	melee_damage_lower = 10
	melee_damage_upper = 15
	faction = list(ROLE_DEATHSQUAD)
	loot = list(/obj/effect/mob_spawn/corpse/human/nanotrasensoldier)
	mob_spawner = /obj/effect/mob_spawn/corpse/human/nanotrasensoldier

/mob/living/basic/trooper/nanotrasen/assess_threat(judgement_criteria, lasercolor, datum/callback/weaponcheck)
	return -10 // Respect our troops

/// A variant that calls for reinforcements on spotting a target
/mob/living/basic/trooper/nanotrasen/screaming
	ai_controller = /datum/ai_controller/basic_controller/trooper/calls_reinforcements

/mob/living/basic/trooper/nanotrasen/ranged
	ai_controller = /datum/ai_controller/basic_controller/trooper/ranged
	r_hand = /obj/item/gun/ballistic/automatic/pistol/m1911
	/// Type of bullet we use
	var/casingtype = /obj/item/ammo_casing/c45
	/// Sound to play when firing weapon
	var/projectilesound = 'sound/items/weapons/gun/pistol/shot_alt.ogg'
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
	if (ranged_cooldown <= 1 SECONDS)
		AddComponent(/datum/component/ranged_mob_full_auto)

/mob/living/basic/trooper/nanotrasen/ranged/smg
	ai_controller = /datum/ai_controller/basic_controller/trooper/ranged/burst
	casingtype = /obj/item/ammo_casing/c46x30mm
	projectilesound = 'sound/items/weapons/gun/smg/shot.ogg'
	r_hand = /obj/item/gun/ballistic/automatic/wt550
	burst_shots = 3
	ranged_cooldown = 3 SECONDS

/mob/living/basic/trooper/nanotrasen/ranged/assault
	name = "Nanotrasen Assault Officer"
	desc = "Nanotrasen Assault Officer. Contact CentCom if you saw him on your station. Prepare to die, if you've been found near Syndicate property."

	casingtype = /obj/item/ammo_casing/a223/weak
	burst_shots = 4
	ranged_cooldown = 3 SECONDS
	projectilesound = 'sound/items/weapons/gun/smg/shot.ogg'
	r_hand = /obj/item/gun/ballistic/automatic/ar
	loot = list(/obj/effect/mob_spawn/corpse/human/nanotrasenassaultsoldier)
	mob_spawner = /obj/effect/mob_spawn/corpse/human/nanotrasenassaultsoldier

/mob/living/basic/trooper/nanotrasen/ranged/elite
	name = "Nanotrasen Elite Assault Officer"
	desc = "Pray for your life, syndicate. Run while you can."
	maxHealth = 150
	health = 150
	habitable_atmos = null
	unsuitable_cold_damage = 0
	casingtype = /obj/item/ammo_casing/energy/laser
	burst_shots = 3
	projectilesound = 'sound/items/weapons/laser.ogg'
	ranged_cooldown = 5 SECONDS
	faction = list(ROLE_DEATHSQUAD)
	loot = list(/obj/effect/gibspawner/human)
	mob_spawner = /obj/effect/mob_spawn/corpse/human/nanotrasenelitesoldier
	r_hand = /obj/item/gun/energy/pulse/carbine/lethal

/// A more peaceful variant that will only attack when attacked, or when another Nanotrasen officer calls for help.
/mob/living/basic/trooper/nanotrasen/peaceful
	desc = "An officer of Nanotrasen's private security force."
	ai_controller = /datum/ai_controller/basic_controller/trooper/peaceful

/mob/living/basic/trooper/nanotrasen/peaceful/Initialize(mapload)
	. = ..()
	var/datum/callback/retaliate_callback = CALLBACK(src, PROC_REF(ai_retaliate_behaviour))
	AddComponent(/datum/component/ai_retaliate_advanced, retaliate_callback)

/mob/living/basic/trooper/nanotrasen/ranged/smg/peaceful
	desc = "An officer of Nanotrasen's private security force."
	ai_controller = /datum/ai_controller/basic_controller/trooper/ranged/burst/peaceful

/mob/living/basic/trooper/nanotrasen/ranged/smg/peaceful/Initialize(mapload)
	. = ..()
	var/datum/callback/retaliate_callback = CALLBACK(src, PROC_REF(ai_retaliate_behaviour))
	AddComponent(/datum/component/ai_retaliate_advanced, retaliate_callback)

/mob/living/basic/trooper/nanotrasen/proc/ai_retaliate_behaviour(mob/living/attacker)
	if (!istype(attacker))
		return
	for (var/mob/living/basic/trooper/nanotrasen/potential_trooper in oview(src, 7))
		potential_trooper.ai_controller.insert_blackboard_key_lazylist(BB_BASIC_MOB_RETALIATE_LIST, attacker)
