/**
 * # Young Spider
 *
 * A mob which can be created by spiderlings/spider eggs.
 * The basic type is the guard, which is slow but sturdy and outputs good damage.
 * All spiders can produce webbing.
 */
/mob/living/basic/spider/growing/young
	name = "young spider"
	desc = "Furry and black, it makes you shudder to look at it. This one has deep red eyes."
	icon_state = "young_guard"
	icon_living = "young_guard"
	icon_dead = "young_guard_dead"
	butcher_results = list(/obj/item/food/meat/slab/spider = 1)
	speed = 1
	maxHealth = 60
	health = 60
	obj_damage = 10
	melee_damage_lower = 8
	melee_damage_upper = 12
	ai_controller = /datum/ai_controller/basic_controller/young_spider
	player_speed_modifier = -1

/mob/living/basic/spider/growing/young/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ai_retaliate)
	AddElement(/datum/element/ai_flee_while_injured)

/// Used by all young spiders if they ever appear.
/datum/ai_controller/basic_controller/young_spider
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic(),
	)

	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk

	planning_subtrees = list(
		/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/random_speech/insect,
		/datum/ai_planning_subtree/find_unwebbed_turf,
		/datum/ai_planning_subtree/spin_web,
	)

/datum/ai_behavior/run_away_from_target/young_spider
	run_distance = 6
