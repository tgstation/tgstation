/// Russian trooper subtype
/mob/living/basic/trooper/russian
	name = "Russian Mobster"
	desc = "For the Motherland!"
	speed = 1.2
	melee_damage_lower = 15
	melee_damage_upper = 15
	unsuitable_cold_damage = 1
	unsuitable_heat_damage = 1
	faction = list(FACTION_RUSSIAN)
	attack_verb_continuous = "slashes"
	attack_verb_simple = "slash"
	attack_sound = 'sound/items/weapons/bladeslice.ogg'
	attack_vis_effect = ATTACK_EFFECT_SLASH
	initial_language_holder = /datum/language_holder/spinwarder_exclusive

	mob_spawner = /obj/effect/mob_spawn/corpse/human/russian
	r_hand = /obj/item/knife/kitchen
	corpse = /obj/effect/mob_spawn/corpse/human/russian
	loot = list(/obj/item/knife/kitchen)

/mob/living/basic/trooper/russian/ranged
	ai_controller = /datum/ai_controller/basic_controller/trooper/ranged
	mob_spawner = /obj/effect/mob_spawn/corpse/human/russian/ranged
	r_hand = /obj/item/gun/ballistic/automatic/pistol
	corpse = /obj/effect/mob_spawn/corpse/human/russian/ranged
	loot = list(/obj/item/gun/ballistic/revolver/nagant)
	var/casingtype = /obj/item/ammo_casing/n762
	var/projectilesound = 'sound/items/weapons/gun/revolver/shot.ogg'

/mob/living/basic/trooper/russian/ranged/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/ranged_attacks, casing_type = casingtype, projectile_sound = projectilesound, cooldown_time = 1 SECONDS)

/mob/living/basic/trooper/russian/ranged/lootless
	loot = null
