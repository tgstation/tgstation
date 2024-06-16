#define DRAKE_ENRAGED (as_living.health < as_living.maxHealth*0.5)
/datum/ai_controller/basic_controller/drake
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/megafauna,
		BB_TARGET_MINIMUM_STAT = DEAD,
		BB_ANGER_MODIFIER = 0,
		BB_DRAKE_SWOOPING = NONE,
		BB_AGGRO_RANGE = 5, //18 if aggroed
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/ranged_skirmish/drake,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/datum/ai_planning_subtree/ranged_skirmish/drake
	operational_datums = null // uses its RangedAttack proc for this
	min_range = 0
	attack_behavior = /datum/ai_behavior/ranged_skirmish/drake

/datum/ai_planning_subtree/ranged_skirmish/drake/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if (!istype(target))
		return
	if(target.stat != DEAD)
		return ..()

/datum/ai_behavior/ranged_skirmish/drake

/datum/ai_behavior/ranged_skirmish/drake/try_fire(seconds_per_tick, datum/ai_controller/controller, atom/target)
	. = TRUE
	if(controller.blackboard[BB_DRAKE_SWOOPING])
		return FALSE

	var/mob/living/as_living = controller.pawn

	var/anger_modifier = controller.blackboard[BB_ANGER_MODIFIER]
	var/datum/action/cooldown/lava_swoop = controller.blackboard[BB_DRAKE_LAVASWOOP]
	var/datum/action/cooldown/mass_fire = controller.blackboard[BB_DRAKE_MASSFIRE]
	var/datum/action/cooldown/fire_cone = controller.blackboard[BB_DRAKE_FIRECONE]
	var/datum/action/cooldown/meteors = controller.blackboard[BB_DRAKE_METEORS]
	if(prob(15 + anger_modifier))
		if(DRAKE_ENRAGED) // Lava Arena
			lava_swoop.Trigger(target = target)
		if(lava_swoop.Trigger(target = target)) // Lava Pools
			fire_cone.StartCooldown(0)
			fire_cone.Trigger(target = target)
			meteors.StartCooldown(0)
			meteors.Trigger(target = target)
	else if(prob(10+anger_modifier) && DRAKE_ENRAGED)
		mass_fire.Trigger(target = target)
	if(fire_cone.Trigger(target = target) && prob(50))
		meteors.StartCooldown(0)
		meteors.Trigger(target = target)

#undef DRAKE_ENRAGED
