/mob/living/basic/trooper
	icon = 'icons/mob/simple/simple_human.dmi'
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	sentience_type = SENTIENCE_HUMANOID
	maxHealth = 100
	health = 100
	basic_mob_flags = DEL_ON_DEATH
	speed = 1.1
	melee_damage_lower = 10
	melee_damage_upper = 10
	attack_verb_continuous = "punches"
	attack_verb_simple = "punch"
	attack_sound = 'sound/weapons/punch1.ogg'
	melee_attack_cooldown = 1.2 SECONDS
	combat_mode = TRUE
	unsuitable_atmos_damage = 7.5
	unsuitable_cold_damage = 7.5
	unsuitable_heat_damage = 7.5
	ai_controller = /datum/ai_controller/basic_controller/trooper

	/// Loot this mob drops on death.
	var/loot = list(/obj/effect/mob_spawn/corpse/human)
	/// Path of the mob spawner we base the mob's visuals off of.
	var/mob_spawner = /obj/effect/mob_spawn/corpse/human
	/// Path of the right hand held item we give to the mob's visuals.
	var/r_hand
	/// Path of the left hand held item we give to the mob's visuals.
	var/l_hand

/mob/living/basic/trooper/Initialize(mapload)
	. = ..()
	apply_dynamic_human_appearance(src, mob_spawn_path = mob_spawner, r_hand = r_hand, l_hand = l_hand)
	if(LAZYLEN(loot))
		loot = string_list(loot)
		AddElement(/datum/element/death_drops, loot)
	AddElement(/datum/element/footstep, footstep_type = FOOTSTEP_MOB_SHOE)
