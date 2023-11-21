/datum/ai_controller/basic_controller/goldgrub
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic,
		BB_PET_TARGETTING_DATUM = new /datum/targetting_datum/not_friends,
		BB_ORE_IGNORE_TYPES = list(/obj/item/stack/ore/iron, /obj/item/stack/ore/glass),
		BB_BASIC_MOB_FLEEING = TRUE,
		BB_STORM_APPROACHING = FALSE,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk/less_walking
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/dig_away_from_danger,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/find_and_hunt_target/consume_ores,
		/datum/ai_planning_subtree/find_and_hunt_target/baby_egg,
		/datum/ai_planning_subtree/grub_mine,
	)

/datum/ai_controller/basic_controller/babygrub
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic,
		BB_ORE_IGNORE_TYPES = list(/obj/item/stack/ore/glass),
		BB_FIND_MOM_TYPES = list(/mob/living/basic/mining/goldgrub),
		BB_IGNORE_MOM_TYPES = list(/mob/living/basic/mining/goldgrub/baby),
		BB_BASIC_MOB_FLEEING = TRUE,
		BB_STORM_APPROACHING = FALSE,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk/less_walking
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/dig_away_from_danger,
		/datum/ai_planning_subtree/find_and_hunt_target/consume_ores,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/look_for_adult,
	)

///consume food!
/datum/ai_planning_subtree/find_and_hunt_target/consume_ores
	target_key = BB_ORE_TARGET
	hunting_behavior = /datum/ai_behavior/hunt_target/unarmed_attack_target/consume_ores
	finding_behavior = /datum/ai_behavior/find_hunt_target/consume_ores
	hunt_targets = list(/obj/item/stack/ore)
	hunt_chance = 75
	hunt_range = 9

/datum/ai_behavior/find_hunt_target/consume_ores

/datum/ai_behavior/find_hunt_target/consume_ores/valid_dinner(mob/living/basic/source, obj/item/stack/ore/target, radius)
	var/list/forbidden_ore = source.ai_controller.blackboard[BB_ORE_IGNORE_TYPES]

	if(is_type_in_list(target, forbidden_ore))
		return FALSE

	if(target in source)
		return FALSE

	var/obj/item/pet_target = source.ai_controller.blackboard[BB_CURRENT_PET_TARGET]
	if(target == pet_target) //we are currently fetching this ore for master, dont eat it!
		return FALSE

	return can_see(source, target, radius)

/datum/ai_behavior/hunt_target/unarmed_attack_target/consume_ores
	always_reset_target = TRUE

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

	var/mob/living/target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]

	//a storm is coming or someone is nearby, its time to escape
	if(currently_underground || !currently_underground && storm_approaching || !QDELETED(target))
		controller.queue_behavior(/datum/ai_behavior/use_mob_ability/burrow, BB_BURROW_ABILITY)
		return SUBTREE_RETURN_FINISH_PLANNING

/datum/ai_behavior/use_mob_ability/burrow
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

///mine walls to look for food!
/datum/ai_planning_subtree/grub_mine

/datum/ai_planning_subtree/grub_mine/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/turf/target_wall = controller.blackboard[BB_TARGET_MINERAL_WALL]

	if(QDELETED(target_wall))
		controller.queue_behavior(/datum/ai_behavior/find_mineral_wall, BB_TARGET_MINERAL_WALL)
		return

	controller.queue_behavior(/datum/ai_behavior/mine_wall, BB_TARGET_MINERAL_WALL)
	return SUBTREE_RETURN_FINISH_PLANNING


/datum/ai_behavior/find_mineral_wall

/datum/ai_behavior/find_mineral_wall/perform(seconds_per_tick, datum/ai_controller/controller, found_wall_key)
	. = ..()

	var/mob/living_pawn = controller.pawn

	for(var/turf/closed/mineral/potential_wall in oview(9, living_pawn))
		if(!check_if_mineable(living_pawn, potential_wall)) //check if its surrounded by walls
			continue
		controller.set_blackboard_key(found_wall_key, potential_wall) //closest wall first!
		finish_action(controller, TRUE)
		return

	finish_action(controller, FALSE)

/datum/ai_behavior/find_mineral_wall/proc/check_if_mineable(mob/living/source, turf/target_wall)
	var/direction_to_turf = get_dir(target_wall, source)
	if(!ISDIAGONALDIR(direction_to_turf))
		return TRUE
	var/list/directions_to_check = list()
	for(var/direction_check in GLOB.cardinals)
		if(direction_check & direction_to_turf)
			directions_to_check += direction_check

	for(var/direction in directions_to_check)
		var/turf/test_turf = get_step(target_wall, direction)
		if(isnull(test_turf))
			continue
		if(!test_turf.is_blocked_turf(ignore_atoms = list(source)))
			return TRUE
	return FALSE

/datum/ai_behavior/mine_wall
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION
	action_cooldown = 15 SECONDS

/datum/ai_behavior/mine_wall/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/turf/target = controller.blackboard[target_key]
	if(isnull(target))
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/mine_wall/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	. = ..()
	var/mob/living/basic/living_pawn = controller.pawn
	var/turf/closed/mineral/target = controller.blackboard[target_key]
	var/is_gibtonite_turf = istype(target, /turf/closed/mineral/gibtonite)
	if(QDELETED(target))
		finish_action(controller, FALSE, target_key)
		return
	living_pawn.melee_attack(target)
	if(is_gibtonite_turf)
		living_pawn.manual_emote("sighs...") //accept whats about to happen to us

	finish_action(controller, TRUE, target_key)
	return

/datum/ai_behavior/mine_wall/finish_action(datum/ai_controller/controller, success, target_key)
	. = ..()
	controller.clear_blackboard_key(target_key)

/datum/pet_command/grub_spit
	command_name = "Spit"
	command_desc = "Ask your grub pet to spit out its ores."
	speech_commands = list("spit", "ores")

/datum/pet_command/grub_spit/execute_action(datum/ai_controller/controller)
	var/datum/action/cooldown/spit_ability = controller.blackboard[BB_SPIT_ABILITY]
	if(QDELETED(spit_ability) || !spit_ability.IsAvailable())
		return
	controller.queue_behavior(/datum/ai_behavior/use_mob_ability, BB_SPIT_ABILITY)
	controller.clear_blackboard_key(BB_ACTIVE_PET_COMMAND)
	return SUBTREE_RETURN_FINISH_PLANNING
