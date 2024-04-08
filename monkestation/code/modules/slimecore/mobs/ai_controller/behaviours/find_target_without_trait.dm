/datum/ai_behavior/find_potential_targets_without_trait
	action_cooldown = 2 SECONDS
	/// How far can we see stuff?
	var/vision_range = 9
	/// Blackboard key for aggro range, uses vision range if not specified
	var/aggro_range_key = BB_AGGRO_RANGE
	/// Static typecache list of potentially dangerous objs
	var/static/list/hostile_machines = typecacheof(list(/obj/machinery/porta_turret, /obj/vehicle/sealed/mecha))
	///our max size
	var/checks_size = FALSE

/datum/ai_behavior/find_potential_targets_without_trait/perform(seconds_per_tick, datum/ai_controller/controller, target_key, targeting_strategy_key, hiding_location_key, trait)
	. = ..()
	var/mob/living/living_mob = controller.pawn
	var/datum/targeting_strategy/targeting_strategy = GET_TARGETING_STRATEGY(controller.blackboard[targeting_strategy_key])

	if(!targeting_strategy)
		CRASH("No target datum was supplied in the blackboard for [controller.pawn]")

	var/atom/current_target = controller.blackboard[target_key]
	if (targeting_strategy.can_attack(living_mob, current_target, vision_range))
		finish_action(controller, succeeded = FALSE)
		return

	var/aggro_range = controller.blackboard[aggro_range_key] || vision_range

	controller.clear_blackboard_key(target_key)
	var/list/potential_targets = hearers(aggro_range, controller.pawn) - living_mob //Remove self, so we don't suicide

	for(var/HM in typecache_filter_list(range(aggro_range, living_mob), hostile_machines)) //Can we see any hostile machines?
		if(can_see(living_mob, HM, aggro_range))
			potential_targets += HM

	if(!potential_targets.len)
		finish_action(controller, succeeded = FALSE)
		return

	var/list/filtered_targets = list()

	for(var/mob/living/pot_target in potential_targets)
		if(HAS_TRAIT(pot_target, trait))
			continue

		if(SEND_SIGNAL(controller.pawn, COMSIG_FRIENDSHIP_CHECK_LEVEL, pot_target, FRIENDSHIP_FRIEND))
			continue

		if(pot_target.client && controller.blackboard[BB_WONT_TARGET_CLIENTS])
			continue

		if(checks_size && pot_target.mob_size >= living_mob.mob_size)///hello shitcode department?
			continue

		if(targeting_strategy.can_attack(living_mob, pot_target))//Can we attack it?
			filtered_targets += pot_target
			continue

	if(!filtered_targets.len)
		finish_action(controller, succeeded = FALSE)
		return

	var/atom/target = pick_final_target(controller, filtered_targets)
	controller.set_blackboard_key(target_key, target)

	var/atom/potential_hiding_location = targeting_strategy.find_hidden_mobs(living_mob, target)

	if(potential_hiding_location) //If they're hiding inside of something, we need to know so we can go for that instead initially.
		controller.set_blackboard_key(hiding_location_key, potential_hiding_location)

	finish_action(controller, succeeded = TRUE)

/datum/ai_behavior/find_potential_targets_without_trait/finish_action(datum/ai_controller/controller, succeeded, ...)
	. = ..()
	if (succeeded)
		controller.CancelActions() // On retarget cancel any further queued actions so that they will setup again with new target

/// Returns the desired final target from the filtered list of targets
/datum/ai_behavior/find_potential_targets_without_trait/proc/pick_final_target(datum/ai_controller/controller, list/filtered_targets)
	return pick(filtered_targets)


/datum/ai_behavior/find_potential_targets_without_trait/smaller
	checks_size = TRUE
