/**
 * Russian subtype of Syndicate troops
 * We're a subtype because we are nearly the same mob with a different Faction.
 */
/mob/living/basic/syndicate/russian
	name = "Russian Mobster"
	desc = "For the Motherland!"
	speed = 0
	melee_damage_lower = 15
	melee_damage_upper = 15
	unsuitable_cold_damage = 1
	unsuitable_heat_damage = 1
	faction = list(FACTION_RUSSIAN)

	mob_spawner = /obj/effect/mob_spawn/corpse/human/russian
	r_hand = /obj/item/knife/kitchen
	loot = list(
		/obj/effect/mob_spawn/corpse/human/russian,
		/obj/item/knife/kitchen,
	)

/mob/living/basic/syndicate/russian/ranged
	ai_controller = /datum/ai_controller/basic_controller/syndicate/ranged
	mob_spawner = /obj/effect/mob_spawn/corpse/human/russian/ranged
	r_hand = /obj/item/gun/ballistic/automatic/pistol
	loot = list(
		/obj/effect/mob_spawn/corpse/human/russian/ranged,
		/obj/item/gun/ballistic/revolver/nagant,
	)
	var/casingtype = /obj/item/ammo_casing/n762
	var/projectilesound = 'sound/weapons/gun/revolver/shot.ogg'

/mob/living/basic/syndicate/russian/ranged/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/ranged_attacks, casing_type = casingtype, projectile_sound = projectilesound, cooldown_time = 1 SECONDS)

/mob/living/basic/syndicate/russian/ranged/lootless
	loot = list()
