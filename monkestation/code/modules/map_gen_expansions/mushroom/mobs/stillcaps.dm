
/mob/living/basic/mining/stillcap
	name = "stillcap"
	desc = "A strange, elusive creature that always seems to come out of nowhere."
	icon = 'monkestation/code/modules/map_gen_expansions/icons/newfauna_wide.dmi'
	icon_state = "stillcap_red"
	icon_living = "stillcap_red"
	base_icon_state = "stillcap_red"
	icon_dead = "stillcap_red_dead"
	pixel_x = -12
	base_pixel_x = -12
	mob_biotypes = MOB_ORGANIC|MOB_BEAST

	maxHealth = 180
	health = 180
	speed = 5
	obj_damage = 15
	melee_damage_lower = 15
	melee_damage_upper = 15
	attack_vis_effect = ATTACK_EFFECT_BITE
	melee_attack_cooldown = 1.2 SECONDS

	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	death_message = "collapses in a muted thud."
	pass_flags_self = PASSMOB

	attack_sound = 'sound/weapons/bite.ogg'
	move_force = MOVE_FORCE_WEAK
	move_resist = MOVE_FORCE_WEAK
	pull_force = MOVE_FORCE_WEAK
	ai_controller = /datum/ai_controller/basic_controller/stillcap


/mob/living/basic/mining/stillcap/Initialize(mapload)
	. = ..()

	AddElement(/datum/element/can_hide/basic, list(/turf/open/misc/asteroid/forest/mushroom))
	AddElement(/datum/element/ai_flee_while_injured)
	AddElement(/datum/element/ai_retaliate)
	AddComponent(/datum/component/basic_mob_ability_telegraph)
	AddComponent(/datum/component/basic_mob_attack_telegraph, telegraph_duration = 0.6 SECONDS)


/mob/living/basic/mining/stillcap/red
	name = "red stillcap"
	desc = parent_type::desc + " This one appears to be red."
	icon_state = "stillcap_red"
	icon_living = "stillcap_red"
	base_icon_state = "stillcap_red"
	icon_dead = "stillcap_red_dead"


/mob/living/basic/mining/stillcap/blue
	name = "blue stillcap"
	desc = parent_type::desc + " This one appears to be blue."
	icon_state = "stillcap_blue"
	icon_living = "stillcap_blue"
	base_icon_state = "stillcap_blue"
	icon_dead = "stillcap_blue_dead"


/mob/living/basic/mining/stillcap/green
	name = "green stillcap"
	desc = parent_type::desc + " This one appears to be green."
	icon_state = "stillcap_green"
	icon_living = "stillcap_green"
	base_icon_state = "stillcap_green"
	icon_dead = "stillcap_green_dead"

/datum/ai_controller/basic_controller/stillcap
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/allow_items,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
		BB_BASIC_MOB_FLEE_DISTANCE = 25,
		BB_AGGRO_RANGE = 5,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
		BB_HIDING_HIDDEN = FALSE,
		BB_HIDING_AGGRO_RANGE = DEFAULT_HIDING_AGGRO_RANGE,
		BB_HIDING_COOLDOWN_MAXIMUM = 3 MINUTES,
		BB_HIDING_COOLDOWN_MINIMUM = 1 MINUTES,
		BB_HIDING_RANDOM_STOP_HIDING_CHANCE = 2,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk/hide

	planning_subtrees = list(
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/stop_hiding_if_target,
		/datum/ai_planning_subtree/simple_find_nearest_target_to_flee,
		/datum/ai_planning_subtree/stop_hiding_if_target,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/random_hiding,
		/datum/ai_planning_subtree/target_retaliate/check_faction/stop_hiding,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/stop_hiding_if_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)
