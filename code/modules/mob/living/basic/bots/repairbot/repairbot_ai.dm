/datum/ai_controller/basic_controller/bot/repairbot
	planning_subtrees = list(
		/datum/ai_planning_subtree/manage_unreachable_list,
		/datum/ai_planning_subtree/respond_to_summon,
		/datum/ai_planning_subtree/replace_floors/breaches,
		/datum/ai_planning_subtree/wall_girder,
		/datum/ai_planning_subtree/build_girder,
		/datum/ai_planning_subtree/replace_window,
		/datum/ai_planning_subtree/replace_floors,
		/datum/ai_planning_subtree/fix_window,
		/datum/ai_planning_subtree/salute_authority,
		/datum/ai_planning_subtree/find_patrol_beacon,
	)
	reset_keys = list(
		BB_TILELESS_FLOOR,
		BB_GIRDER_TARGET,
		BB_GIRDER_TO_WALL_TARGET,
		BB_BEACON_TARGET,
		BB_PREVIOUS_BEACON_TARGET,
		BB_WELDER_TARGET,
		BB_WINDOW_FRAMETARGET,
	)
	ai_traits = PAUSE_DURING_DO_AFTER


///subtree to replace iron platings
/datum/ai_planning_subtree/replace_floors
	///flag we check before executing
	var/required_flag = REPAIRBOT_REPLACE_TILES
	///key of our floor target
	var/floor_key = BB_TILELESS_FLOOR
	///type of tile we need to replace floors
	var/needed_tile_type = /obj/item/stack/tile
	///type of floors we can replace
	var/list/type_of_turf = list(/turf/open/floor/plating)
	///our searching behavior
	var/search_behavior = /datum/ai_behavior/bot_search/valid_plateless_turf

/datum/ai_planning_subtree/replace_floors/New()
	. = ..()
	type_of_turf = typecacheof(type_of_turf)

/datum/ai_planning_subtree/replace_floors/SelectBehaviors(datum/ai_controller/basic_controller/bot/controller, seconds_per_tick)
	var/mob/living/basic/bot/repairbot/bot_pawn = controller.pawn
	if(!(bot_pawn.repairbot_flags & required_flag))
		return
	if(!locate(needed_tile_type) in bot_pawn)
		return
	if(controller.blackboard_key_exists(floor_key))
		controller.queue_behavior(/datum/ai_behavior/bot_interact, floor_key)
		return SUBTREE_RETURN_FINISH_PLANNING

	controller.queue_behavior(search_behavior, floor_key, type_of_turf, 5, 10, FALSE, TRUE)

/datum/ai_behavior/bot_search/valid_plateless_turf

/datum/ai_behavior/bot_search/valid_plateless_turf/valid_target(datum/ai_controller/basic_controller/bot/controller, turf/open/my_target)
	var/static/list/blacklist_objects = typecacheof(list(
		/obj/structure/window,
		/obj/structure/grille,
	))
	for(var/atom/possible_blacklisted as anything in my_target)
		if(is_type_in_typecache(possible_blacklisted, blacklist_objects))
			return FALSE
	return !istype(get_area(my_target), /area/space) && can_see(controller.pawn, my_target, 5)


///subtree to fix hull breaches
/datum/ai_planning_subtree/replace_floors/breaches
	floor_key = BB_BREACHED_FLOOR
	needed_tile_type = /obj/item/stack/tile/iron
	type_of_turf = list(/turf/open/space)
	required_flag = REPAIRBOT_FIX_BREACHES
	search_behavior = /datum/ai_behavior/bot_search/valid_plateless_turf/breached

///exists as to not conflict with the base turf searching behavior cause of how the queue system works...
/datum/ai_behavior/bot_search/valid_plateless_turf/breached

///subtree to build girders
/datum/ai_planning_subtree/build_girder

/datum/ai_planning_subtree/build_girder/SelectBehaviors(datum/ai_controller/basic_controller/bot/controller, seconds_per_tick)
	var/mob/living/basic/bot/repairbot/bot_pawn = controller.pawn
	if(!(bot_pawn.repairbot_flags & REPAIRBOT_BUILD_GIRDERS))
		return
	var/obj/item/stack/rods/my_rods = locate() in bot_pawn
	if(isnull(my_rods) || my_rods.amount < 2)
		return
	var/datum/action/cooldown/ability = controller.blackboard[BB_GIRDER_BUILD_ABILITY]
	if(!ability?.IsAvailable())
		return
	if(controller.blackboard_key_exists(BB_GIRDER_TARGET))
		controller.queue_behavior(/datum/ai_behavior/targeted_mob_ability/build_girder, BB_GIRDER_BUILD_ABILITY, BB_GIRDER_TARGET)
		return SUBTREE_RETURN_FINISH_PLANNING

	var/static/list/searchable_turfs = typecacheof(list(/turf/open))
	controller.queue_behavior(/datum/ai_behavior/bot_search/valid_wall_target, BB_GIRDER_TARGET, searchable_turfs, 5, 10, FALSE, TRUE)

/datum/ai_behavior/bot_search/valid_wall_target
	action_cooldown = 5 SECONDS

/datum/ai_behavior/bot_search/valid_wall_target/valid_target(datum/ai_controller/basic_controller/bot/controller, turf/my_target)
	if(istype(get_area(my_target), /area/space) || isgroundlessturf(my_target) || my_target.is_blocked_turf())
		return FALSE
	var/static/list/blacklist_objects = list(
		/obj/machinery/door,
		/obj/structure/grille,
	)

	for(var/atom/contents in my_target)
		if(is_type_in_typecache(contents, blacklist_objects))
			return FALSE

	var/turf/adjacent_turfs = get_adjacent_open_turfs(my_target)
	for(var/turf/possible_spaced_turf as anything in adjacent_turfs)
		if(isspaceturf(possible_spaced_turf) && istype(get_area(possible_spaced_turf), /area/space) && can_see(controller.pawn, my_target, 5))
			return TRUE
	return FALSE

/datum/ai_behavior/targeted_mob_ability/build_girder
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_behavior/targeted_mob_ability/build_girder/setup(datum/ai_controller/controller, ability_key, target_key)
	. = ..()
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/targeted_mob_ability/build_girder/finish_action(datum/ai_controller/controller, succeeded, ability_key, target_key)
	. = ..()
	var/atom/target = controller.blackboard[target_key]
	controller.clear_blackboard_key(target_key)
	if(!succeeded && !isnull(target))
		controller.set_blackboard_key_assoc_lazylist(BB_TEMPORARY_IGNORE_LIST, target, TRUE)


///subtree to place glass on windows
/datum/ai_planning_subtree/replace_window

/datum/ai_planning_subtree/replace_window/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/basic/bot/repairbot/living_pawn = controller.pawn
	if(!(living_pawn.repairbot_flags & REPAIRBOT_REPLACE_WINDOWS))
		return
	if(!locate(/obj/item/stack/sheet/glass) in living_pawn)
		return
	if(controller.blackboard_key_exists(BB_WINDOW_FRAMETARGET))
		controller.queue_behavior(/datum/ai_behavior/bot_interact, BB_WINDOW_FRAMETARGET)
		return SUBTREE_RETURN_FINISH_PLANNING
	var/static/list/searchable_grilles = typecacheof(list(/obj/structure/grille, /obj/structure/window_frame))
	controller.queue_behavior(/datum/ai_behavior/bot_search/valid_grille_target, BB_WINDOW_FRAMETARGET, searchable_grilles)

/datum/ai_behavior/bot_search/valid_grille_target/valid_target(datum/ai_controller/basic_controller/bot/controller, obj/structure/my_target)
	if(locate(/obj/structure/window) in get_turf(my_target))
		return FALSE
	return (!istype(get_area(my_target), /area/space) && can_see(controller.pawn, my_target, 5))


///subtree to place iron on girders
/datum/ai_planning_subtree/wall_girder

/datum/ai_planning_subtree/wall_girder/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/basic/bot/repairbot/living_pawn = controller.pawn
	if(!(living_pawn.repairbot_flags & REPAIRBOT_FIX_GIRDERS))
		return
	var/obj/item/stack/sheet/iron/my_iron = locate() in living_pawn
	if(isnull(my_iron) || my_iron.amount < 2)
		return
	if(controller.blackboard_key_exists(BB_GIRDER_TO_WALL_TARGET))
		controller.queue_behavior(/datum/ai_behavior/bot_interact, BB_GIRDER_TO_WALL_TARGET)
		return SUBTREE_RETURN_FINISH_PLANNING
	var/static/list/searchable_girder = typecacheof(list(/obj/structure/girder))
	controller.queue_behavior(/datum/ai_behavior/bot_search/valid_girder, BB_GIRDER_TO_WALL_TARGET, searchable_girder)

/datum/ai_behavior/bot_search/valid_girder/valid_target(datum/ai_controller/basic_controller/bot/controller, obj/my_target)
	return isfloorturf(my_target.loc) && can_see(controller.pawn, my_target, 5)

///subtree to repair machines with welders
/datum/ai_planning_subtree/fix_window

/datum/ai_planning_subtree/fix_window/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if(controller.blackboard_key_exists(BB_WELDER_TARGET))
		controller.queue_behavior(/datum/ai_behavior/bot_interact, BB_WELDER_TARGET)
		return SUBTREE_RETURN_FINISH_PLANNING
	var/static/list/searchable_objects = typecacheof(list(/obj/structure/window))
	controller.queue_behavior(/datum/ai_behavior/bot_search/valid_window_fix, BB_WELDER_TARGET, searchable_objects)

/datum/ai_behavior/bot_search/valid_window_fix

/datum/ai_behavior/bot_search/valid_window_fix/valid_target(datum/ai_controller/basic_controller/bot/controller, obj/my_target)

	if(my_target.get_integrity() >= my_target.max_integrity && my_target.anchored)
		return FALSE
	return can_see(controller.pawn, my_target, 5)

