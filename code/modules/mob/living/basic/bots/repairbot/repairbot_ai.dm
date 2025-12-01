#define REPAIRBOT_SPEECH_TIMER 30 SECONDS

/datum/ai_controller/basic_controller/bot/repairbot
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity/pacifist,
		/datum/ai_planning_subtree/repairbot_speech,
		/datum/ai_planning_subtree/mug_robot,
		/datum/ai_planning_subtree/refill_materials,
		/datum/ai_planning_subtree/repairbot_deconstruction,
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
	minimum_distance = 1

///subtree to refill our stacks
/datum/ai_planning_subtree/refill_materials

/datum/ai_planning_subtree/refill_materials/SelectBehaviors(datum/ai_controller/basic_controller/bot/controller, seconds_per_tick)
	var/static/list/refillable_items = typecacheof(list(
		/obj/item/stack/sheet/iron,
		/obj/item/stack/sheet/glass,
		/obj/item/stack/tile,
	))
	if(!controller.blackboard_key_exists(BB_REFILLABLE_TARGET))
		controller.queue_behavior(/datum/ai_behavior/bot_search/refillable_target, BB_REFILLABLE_TARGET, refillable_items)
		return
	controller.queue_behavior(/datum/ai_behavior/bot_interact, BB_REFILLABLE_TARGET)
	return SUBTREE_RETURN_FINISH_PLANNING

/datum/ai_behavior/bot_search/refillable_target
	action_cooldown = 10 SECONDS

/datum/ai_behavior/bot_search/refillable_target/valid_target(datum/ai_controller/basic_controller/bot/controller, atom/my_target)
	var/static/list/desired_types = list(
		/obj/item/stack/sheet/iron,
		/obj/item/stack/sheet/glass,
		/obj/item/stack/tile,
	)
	for(var/object_type in desired_types)
		if(!istype(my_target, object_type))
			continue
		var/obj/item/stack/sheet_type = locate(object_type) in controller.pawn
		if(isnull(sheet_type))
			return TRUE //we dont have any of it!
		if(sheet_type.amount < sheet_type.max_amount && sheet_type.can_merge(my_target))
			return TRUE
	return FALSE

/datum/ai_planning_subtree/mug_robot

/datum/ai_planning_subtree/mug_robot/SelectBehaviors(datum/ai_controller/basic_controller/bot/controller, seconds_per_tick)
	var/mob/living/basic/bot/living_bot = controller.pawn
	if(!(living_bot.bot_access_flags & BOT_COVER_EMAGGED))
		return
	var/static/list/robot_targets = typecacheof(
		/mob/living/silicon/robot,
	)
	if(!controller.blackboard_key_exists(BB_ROBOT_TARGET))
		controller.queue_behavior(/datum/ai_behavior/bot_search/valid_robot, BB_ROBOT_TARGET, robot_targets)
		return
	if(!living_bot.pulling)
		controller.queue_behavior(/datum/ai_behavior/drag_target, BB_ROBOT_TARGET)
	else
		controller.queue_behavior(/datum/ai_behavior/bot_interact/tip_robot, BB_ROBOT_TARGET)
	return SUBTREE_RETURN_FINISH_PLANNING

/datum/ai_behavior/bot_search/valid_robot
	action_cooldown = 10 SECONDS

/datum/ai_behavior/bot_search/valid_robot/valid_target(datum/ai_controller/basic_controller/bot/controller, atom/my_target)
	return (!HAS_TRAIT(my_target, TRAIT_MOB_TIPPED)) && can_see(controller.pawn, my_target)

/datum/ai_behavior/bot_interact/tip_robot

/datum/ai_behavior/bot_interact/tip_robot/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()
	if(succeeded)
		var/mob/living/living_pawn = controller.pawn
		living_pawn.stop_pulling()

///subtree to deconstruct things when we're emagged
/datum/ai_planning_subtree/repairbot_deconstruction

/datum/ai_planning_subtree/repairbot_deconstruction/SelectBehaviors(datum/ai_controller/basic_controller/bot/controller, seconds_per_tick)
	var/mob/living/basic/bot/living_bot = controller.pawn
	if(!(living_bot.bot_access_flags & BOT_COVER_EMAGGED))
		return
	var/static/list/things_to_deconstruct = typecacheof(list(
		/obj/structure/window,
		/turf/open/floor,
		/turf/closed/wall,
	))
	if(!controller.blackboard_key_exists(BB_DECONSTRUCT_TARGET))
		controller.queue_behavior(/datum/ai_behavior/bot_search/deconstructable, BB_DECONSTRUCT_TARGET, things_to_deconstruct)
		return SUBTREE_RETURN_FINISH_PLANNING
	controller.queue_behavior(/datum/ai_behavior/bot_interact, BB_DECONSTRUCT_TARGET)
	return SUBTREE_RETURN_FINISH_PLANNING

/datum/ai_behavior/bot_search/deconstructable
	action_cooldown = 5 SECONDS

/datum/ai_behavior/bot_search/deconstructable/valid_target(datum/ai_controller/basic_controller/bot/controller, atom/my_target)
	return (!(my_target.resistance_flags & INDESTRUCTIBLE) && !isgroundlessturf(my_target))

///subtree to control bot speech
/datum/ai_planning_subtree/repairbot_speech

/datum/ai_planning_subtree/repairbot_speech/SelectBehaviors(datum/ai_controller/basic_controller/bot/controller, seconds_per_tick)
	if(controller.blackboard[BB_REPAIRBOT_SPEECH_COOLDOWN] > world.time)
		return
	var/static/list/keys_to_look = list(
		BB_WELDER_TARGET,
		BB_WINDOW_FRAMETARGET,
		BB_TILELESS_FLOOR,
		BB_BREACHED_FLOOR,
		BB_GIRDER_TO_WALL_TARGET,
		BB_GIRDER_TARGET,
		BB_DECONSTRUCT_TARGET,
	)
	for(var/key in keys_to_look)
		if(controller.blackboard_key_exists(key))
			controller.queue_behavior(/datum/ai_behavior/repairbot_speech, key)
			return

/datum/ai_behavior/repairbot_speech
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_behavior/repairbot_speech/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	var/datum/action/cooldown/bot_announcement/announcement = controller.blackboard[BB_ANNOUNCE_ABILITY]
	var/list/speech_to_pick_from = (target_key == BB_DECONSTRUCT_TARGET) ? controller.blackboard[BB_REPAIRBOT_EMAGGED_SPEECH] : controller.blackboard[BB_REPAIRBOT_NORMAL_SPEECH]
	if(!length(speech_to_pick_from))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	announcement.announce(pick(speech_to_pick_from))
	controller.set_blackboard_key(BB_REPAIRBOT_SPEECH_COOLDOWN, world.time + REPAIRBOT_SPEECH_TIMER)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

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
	action_cooldown = 5 SECONDS

/datum/ai_behavior/bot_search/valid_plateless_turf/valid_target(datum/ai_controller/basic_controller/bot/controller, turf/open/my_target)
	var/static/list/blacklist_objects = typecacheof(list(
		/obj/structure/window,
		/obj/structure/grille,
	))

	for(var/atom/possible_blacklisted in my_target.contents)
		if(is_type_in_typecache(possible_blacklisted, blacklist_objects))
			return FALSE

	if(istype(my_target, /turf/open/floor/plating) && !can_see(controller.pawn, my_target, 5))
		return FALSE

	var/static/list/blacklist_areas = typecacheof(list(
		/area/space,
		/area/station/maintenance,
	))
	var/turf_area = get_area(my_target)
	return !(is_type_in_typecache(turf_area, blacklist_areas))

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
		if(isspaceturf(possible_spaced_turf) && istype(get_area(possible_spaced_turf), /area/space))
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
	controller.clear_blackboard_key(target_key)

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
	var/static/list/searchable_grilles = typecacheof(list(/obj/structure/grille))
	controller.queue_behavior(/datum/ai_behavior/bot_search/valid_grille_target, BB_WINDOW_FRAMETARGET, searchable_grilles)

/datum/ai_behavior/bot_search/valid_grille_target/valid_target(datum/ai_controller/basic_controller/bot/controller, obj/structure/my_target)
	if(locate(/obj/structure/window) in get_turf(my_target))
		return FALSE
	return (!istype(get_area(my_target), /area/space))


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

/datum/ai_behavior/bot_search/valid_girder
	action_cooldown = 5 SECONDS

/datum/ai_behavior/bot_search/valid_girder/valid_target(datum/ai_controller/basic_controller/bot/controller, obj/my_target)
	return isfloorturf(my_target.loc)

///subtree to repair machines with welders
/datum/ai_planning_subtree/fix_window

/datum/ai_planning_subtree/fix_window/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if(controller.blackboard_key_exists(BB_WELDER_TARGET))
		controller.queue_behavior(/datum/ai_behavior/bot_interact, BB_WELDER_TARGET)
		return SUBTREE_RETURN_FINISH_PLANNING
	var/static/list/searchable_objects = typecacheof(list(/obj/structure/window))
	controller.queue_behavior(/datum/ai_behavior/bot_search/valid_window_fix, BB_WELDER_TARGET, searchable_objects)

/datum/ai_behavior/bot_search/valid_window_fix
	action_cooldown = 5 SECONDS

/datum/ai_behavior/bot_search/valid_window_fix/valid_target(datum/ai_controller/basic_controller/bot/controller, obj/my_target)
	return (my_target.get_integrity() < my_target.max_integrity || !my_target.anchored)

#undef REPAIRBOT_SPEECH_TIMER
