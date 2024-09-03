/datum/ai_controller/basic_controller/goldgrub
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
		BB_ORE_IGNORE_TYPES = list(/obj/item/stack/ore/iron, /obj/item/stack/ore/glass),
		BB_STORM_APPROACHING = FALSE,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk/less_walking
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/dig_away_from_danger,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/find_and_hunt_target/hunt_ores,
		/datum/ai_planning_subtree/find_and_hunt_target/break_boulders,
		/datum/ai_planning_subtree/find_and_hunt_target/harvest_vents,
		/datum/ai_planning_subtree/find_and_hunt_target/baby_egg,
		/datum/ai_planning_subtree/mine_walls,
	)

/datum/ai_controller/basic_controller/babygrub
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_ORE_IGNORE_TYPES = list(/obj/item/stack/ore/glass),
		BB_FIND_MOM_TYPES = list(/mob/living/basic/mining/goldgrub),
		BB_IGNORE_MOM_TYPES = list(/mob/living/basic/mining/goldgrub/baby),
		BB_STORM_APPROACHING = FALSE,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk/less_walking
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/dig_away_from_danger,
		/datum/ai_planning_subtree/find_and_hunt_target/hunt_ores,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/look_for_adult,
	)

///consume food!
/datum/ai_planning_subtree/find_and_hunt_target/hunt_ores
	target_key = BB_ORE_TARGET
	hunting_behavior = /datum/ai_behavior/hunt_target/interact_with_target/hunt_ores
	finding_behavior = /datum/ai_behavior/find_hunt_target/hunt_ores
	hunt_targets = list(/obj/item/stack/ore)
	hunt_chance = 90
	hunt_range = 9

/datum/ai_behavior/find_hunt_target/hunt_ores

/datum/ai_behavior/find_hunt_target/hunt_ores/valid_dinner(mob/living/basic/source, obj/item/stack/ore/target, radius)
	var/list/forbidden_ore = source.ai_controller.blackboard[BB_ORE_IGNORE_TYPES]

	if(is_type_in_list(target, forbidden_ore))
		return FALSE

	if(!isturf(target.loc))
		return FALSE

	var/obj/item/pet_target = source.ai_controller.blackboard[BB_CURRENT_PET_TARGET]
	if(target == pet_target) //we are currently fetching this ore for master, dont eat it!
		return FALSE

	return can_see(source, target, radius)

/datum/ai_behavior/hunt_target/interact_with_target/hunt_ores
	always_reset_target = TRUE

///break boulders so that we can find more food!
/datum/ai_planning_subtree/find_and_hunt_target/harvest_vents
	target_key = BB_VENT_TARGET
	hunting_behavior = /datum/ai_behavior/hunt_target/interact_with_target //We call the ore vent's produce_boulder() proc here to produce a single boulder.
	finding_behavior = /datum/ai_behavior/find_hunt_target/harvest_vents
	hunt_targets = list(/obj/structure/ore_vent)
	hunt_chance = 25
	hunt_range = 15

/datum/ai_behavior/find_hunt_target/harvest_vents

/datum/ai_behavior/find_hunt_target/harvest_vents/valid_dinner(mob/living/basic/source, obj/structure/target, radius)
	if(target in source)
		return FALSE

	var/turf/vent_turf = target.drop_location()
	var/counter = 0
	for(var/obj/item/boulder in vent_turf.contents)
		counter++
		if(counter > MAX_BOULDERS_PER_VENT) //Too many items currently on the vent
			return FALSE

	return can_see(source, target, radius)

///break boulders so that we can find more food!
/datum/ai_planning_subtree/find_and_hunt_target/break_boulders
	target_key = BB_BOULDER_TARGET
	hunting_behavior = /datum/ai_behavior/hunt_target/interact_with_target //We process boulders once every tap, so we dont need to do anything special here
	finding_behavior = /datum/ai_behavior/find_hunt_target/break_boulders
	hunt_targets = list(/obj/item/boulder)
	hunt_chance = 100 //If we can, we should always break boulders.
	hunt_range = 9

/datum/ai_behavior/find_hunt_target/break_boulders

/datum/ai_behavior/find_hunt_target/break_boulders/valid_dinner(mob/living/basic/source, obj/item/boulder/target, radius)
	if(target in source)
		return FALSE

	var/obj/item/pet_target = source.ai_controller.blackboard[BB_CURRENT_PET_TARGET]
	if(target == pet_target) //we are currently fetching this ore for master, dont eat it!
		return FALSE
	return can_see(source, target, radius)

///find our child's egg and pull it!
/datum/ai_planning_subtree/find_and_hunt_target/baby_egg
	target_key = BB_LOW_PRIORITY_HUNTING_TARGET
	hunting_behavior = /datum/ai_behavior/hunt_target/grub_egg
	finding_behavior = /datum/ai_behavior/find_hunt_target
	hunt_targets = list(/obj/item/food/egg/green/grub_egg)
	hunt_chance = 75
	hunt_range = 9

/datum/ai_planning_subtree/find_and_hunt_target/baby_egg

/datum/ai_planning_subtree/find_and_hunt_target/baby_egg/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/living_pawn = controller.pawn
	if(living_pawn.pulling) //we are already pulling something
		return
	return ..()

/datum/ai_behavior/hunt_target/grub_egg
	always_reset_target = TRUE

/datum/ai_behavior/hunt_target/grub_egg/target_caught(mob/living/hunter, obj/item/target)
	hunter.start_pulling(target)


///only dig away if storm is coming or if humans are around
/datum/ai_planning_subtree/dig_away_from_danger

/datum/ai_planning_subtree/dig_away_from_danger/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/currently_underground = is_jaunting(controller.pawn)
	var/storm_approaching = controller.blackboard[BB_STORM_APPROACHING]

	//dont do anything until the storm passes
	if(currently_underground && storm_approaching)
		return SUBTREE_RETURN_FINISH_PLANNING

	var/datum/action/cooldown/dig_ability = controller.blackboard[BB_BURROW_ABILITY]

	if(!dig_ability.IsAvailable())
		return

	var/has_target = controller.blackboard_key_exists(BB_BASIC_MOB_CURRENT_TARGET)

	//a storm is coming or someone is nearby, its time to escape
	if(currently_underground)
		if(has_target)
			return
		controller.queue_behavior(/datum/ai_behavior/use_mob_ability/burrow, BB_BURROW_ABILITY)
		return SUBTREE_RETURN_FINISH_PLANNING
	if(storm_approaching || has_target)
		controller.queue_behavior(/datum/ai_behavior/use_mob_ability/burrow, BB_BURROW_ABILITY)
		return SUBTREE_RETURN_FINISH_PLANNING

/datum/ai_behavior/use_mob_ability/burrow
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/pet_command/grub_spit
	command_name = "Spit"
	command_desc = "Ask your grub pet to spit out its ores."
	speech_commands = list("spit", "ores")

/datum/pet_command/grub_spit/execute_action(datum/ai_controller/controller)
	var/datum/action/cooldown/spit_ability = controller.blackboard[BB_SPIT_ABILITY]
	if(!spit_ability?.IsAvailable())
		return
	controller.queue_behavior(/datum/ai_behavior/use_mob_ability, BB_SPIT_ABILITY)
	controller.clear_blackboard_key(BB_ACTIVE_PET_COMMAND)
	return SUBTREE_RETURN_FINISH_PLANNING
