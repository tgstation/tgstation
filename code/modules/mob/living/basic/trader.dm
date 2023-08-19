/mob/living/basic/trader
	name = "Trader"
	desc = "Come buy some!"
	unique_name = TRUE
	icon = 'icons/mob/simple/simple_human.dmi'
	maxHealth = 200
	health = 200
	melee_damage_lower = 10
	melee_damage_upper = 10
	attack_verb_continuous = "punches"
	attack_verb_simple = "punch"
	attack_sound = 'sound/weapons/punch1.ogg'
	basic_mob_flags = DEL_ON_DEATH
	habitable_atmos = list("min_oxy" = 3, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 15, "min_co2" = 0, "max_co2" = 15, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 2.5
	combat_mode = TRUE
	move_resist = MOVE_FORCE_STRONG
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	sentience_type = SENTIENCE_HUMANOID
	speed = 0
	///TODO: remove this, use component to intercept clicks
	interaction_flags_atom = INTERACT_ATOM_NO_FINGERPRINT_ATTACK_HAND|INTERACT_ATOM_ATTACK_HAND|INTERACT_ATOM_NO_FINGERPRINT_INTERACT

	ai_controller = /datum/ai_controller/basic_controller/trader

	///Sound used when item sold/bought
	var/sell_sound = 'sound/effects/cashregister.ogg'
	///The spawner we use to create our look
	var/spawner_path = /obj/effect/mob_spawn/corpse/human/generic_assistant
	///Our species to create our look
	var/species_path = /datum/species/human
	///The loot we drop when we die
	var/loot = list(/obj/effect/mob_spawn/corpse/human/generic_assistant)

/mob/living/basic/trader/Initialize(mapload)
	. = ..()
	apply_dynamic_human_appearance(src, species_path = species_path, mob_spawn_path = spawner_path)
	AddElement(/datum/element/ai_retaliate)
	AddComponent(/datum/component/ranged_attacks, casing_type = /obj/item/ammo_casing/shotgun/buckshot, projectile_sound = 'sound/weapons/gun/pistol/shot.ogg', cooldown_time = 3 SECONDS)
	if(LAZYLEN(loot))
		loot = string_list(loot)
		AddElement(/datum/element/death_drops, loot)

/datum/ai_controller/basic_controller/trader
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic(),
		BB_PET_TARGETTING_DATUM = new /datum/targetting_datum/basic(),
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/mob/living/basic/trader/mrbones
	name = "Mr. Bones"
	desc = "A skeleton merchant, he seems very humerus."
	speak_emote = list("rattles")
	speech_span = SPAN_SANS
	mob_biotypes = MOB_UNDEAD|MOB_HUMANOID
	icon_state = "mrbones"
	gender = MALE

	sell_sound = 'sound/voice/hiss2.ogg'
	species_path = /datum/species/skeleton
	spawner_path = /obj/effect/mob_spawn/corpse/human/skeleton/mrbones
	loot = list(/obj/effect/decal/remains/human)

/obj/effect/mob_spawn/corpse/human/skeleton/mrbones
	mob_species = /datum/species/skeleton
	outfit = /datum/outfit/mrbonescorpse

/datum/outfit/mrbonescorpse
	name = "Mr Bones' Corpse"
	head = /obj/item/clothing/head/hats/tophat

