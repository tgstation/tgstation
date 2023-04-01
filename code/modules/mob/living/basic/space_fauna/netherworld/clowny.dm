/mob/living/basic/clowny
	name = "clowny"
	desc = "It just wants a hug."
	icon = 'icons/mob/simple/clowny.dmi'
	icon_state = "clowny"
	icon_living = "clowny"
	icon_dead = "clowny_dead"
	health = 80
	maxHealth = 80
	obj_damage = 10
	melee_damage_lower = 2
	melee_damage_upper = 2
	speed = 2.5
	attack_verb_continuous = "honks"
	attack_verb_simple = "honks"
	gold_core_spawnable = FRIENDLY_SPAWN
	attack_sound = 'sound/weapons/squeakytoy.ogg'
	attack_vis_effect = ATTACK_EFFECT_SLASH
	faction = list(FACTION_CLOWN)
	speak_emote = list("honks")
	death_message = "why did you kill me?!!"
	death_sound = 'sound/misc/clap1.ogg'
	unsuitable_atmos_damage = 0
	unsuitable_cold_damage = 0
	unsuitable_heat_damage = 0
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	mob_size = MOB_SIZE_TINY
	can_be_held = TRUE
	held_w_class = WEIGHT_CLASS_TINY
	worn_slot_flags = ITEM_SLOT_HEAD
	head_icon = 'icons/mob/clothing/head/clowny_head.dmi'

	ai_controller = /datum/ai_controller/basic_controller/clowny

/mob/living/basic/migo/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ai_retaliate)
	AddElement(/datum/element/venomous, /datum/reagent/consumable/superlaughter, 3)
	AddComponent(/datum/component/regenerator, outline_colour = COLOR_RED)
	AddComponent(
		/datum/component/health_scaling_effects,\
		min_health_attack_modifier_lower = 2,\
		min_health_attack_modifier_upper = 20,\
		min_health_slowdown = -2.5,\
	)

/datum/ai_controller/basic_controller/clowny
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic(),
	)

	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/average_speed,
	)
