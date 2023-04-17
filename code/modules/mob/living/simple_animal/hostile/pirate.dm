/mob/living/simple_animal/hostile/pirate
	name = "Pirate"
	desc = "Does what he wants cause a pirate is free."
	icon = 'icons/mob/simple/simple_human.dmi'
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	sentience_type = SENTIENCE_HUMANOID
	speak_chance = 0
	turns_per_move = 5
	response_help_continuous = "pushes"
	response_help_simple = "push"
	speed = 0
	maxHealth = 100
	health = 100
	harm_intent_damage = 5
	melee_damage_lower = 10
	melee_damage_upper = 10
	attack_verb_continuous = "punches"
	attack_verb_simple = "punch"
	attack_sound = 'sound/weapons/punch1.ogg'
	combat_mode = TRUE
	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 7.5
	speak_emote = list("yarrs")
	loot = list(/obj/effect/mob_spawn/corpse/human/pirate)
	del_on_death = TRUE
	faction = list(FACTION_PIRATE)
	/// Path of the mob spawner we base the mob's visuals off of.
	var/mob_spawner = /obj/effect/mob_spawn/corpse/human/pirate
	/// Path of the held item we give to the mob's visuals.
	var/held_item

/mob/living/simple_animal/hostile/pirate/Initialize(mapload)
	. = ..()
	apply_dynamic_human_appearance(src, mob_spawn_path = mob_spawner, r_hand = held_item)

/mob/living/simple_animal/hostile/pirate/melee
	name = "Pirate Swashbuckler"
	melee_damage_lower = 30
	melee_damage_upper = 30
	armour_penetration = 35
	attack_verb_continuous = "slashes"
	attack_verb_simple = "slash"
	attack_sound = 'sound/weapons/blade1.ogg'
	attack_vis_effect = ATTACK_EFFECT_SLASH
	loot = list(/obj/effect/mob_spawn/corpse/human/pirate/melee)
	light_range = 2
	light_power = 2.5
	light_color = COLOR_SOFT_RED
	footstep_type = FOOTSTEP_MOB_SHOE
	loot = list(
		/obj/effect/mob_spawn/corpse/human/pirate/melee,
		/obj/item/melee/energy/sword/pirate,
	)
	mob_spawner = /obj/effect/mob_spawn/corpse/human/pirate/melee
	held_item = /obj/item/melee/energy/sword/pirate

/mob/living/simple_animal/hostile/pirate/melee/space
	name = "Space Pirate Swashbuckler"
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	speed = 1
	mob_spawner = /obj/effect/mob_spawn/corpse/human/pirate/melee/space

/mob/living/simple_animal/hostile/pirate/melee/space/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)

/mob/living/simple_animal/hostile/pirate/ranged
	name = "Pirate Gunner"
	projectilesound = 'sound/weapons/laser.ogg'
	ranged = 1
	rapid = 2
	rapid_fire_delay = 6
	retreat_distance = 5
	minimum_distance = 5
	projectiletype = /obj/projectile/beam/laser
	loot = list(/obj/effect/mob_spawn/corpse/human/pirate/ranged)
	mob_spawner = /obj/effect/mob_spawn/corpse/human/pirate/ranged
	held_item = /obj/item/gun/energy/laser

/mob/living/simple_animal/hostile/pirate/ranged/space
	name = "Space Pirate Gunner"
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	speed = 1
	mob_spawner = /obj/effect/mob_spawn/corpse/human/pirate/ranged/space
	held_item = /obj/item/gun/energy/e_gun/lethal

/mob/living/simple_animal/hostile/pirate/ranged/space/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)
