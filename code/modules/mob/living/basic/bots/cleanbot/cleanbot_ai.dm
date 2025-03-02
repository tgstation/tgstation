#define BOT_CLEAN_PATH_LIMIT 15
#define POST_CLEAN_COOLDOWN 5 SECONDS

/datum/ai_controller/basic_controller/bot/cleanbot
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/allow_items,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
		BB_UNREACHABLE_LIST_COOLDOWN = 3 MINUTES,
		BB_SALUTE_MESSAGES = list(
			"salutes",
			"nods in appreciation towards",
			"mops the dirt away in the path of",
		),
		BB_FRIENDLY_MESSAGE = "empathetically acknowledges your hardwork and tough circumstances",
	)
	planning_subtrees = list(
		/datum/ai_planning_subtree/respond_to_summon,
		/datum/ai_planning_subtree/pet_planning/cleanbot,
		/datum/ai_planning_subtree/cleaning_subtree,
		/datum/ai_planning_subtree/befriend_janitors,
		/datum/ai_planning_subtree/acid_spray,
		/datum/ai_planning_subtree/use_mob_ability/foam_area,
		/datum/ai_planning_subtree/salute_authority,
		/datum/ai_planning_subtree/find_patrol_beacon/cleanbot,
	)
	reset_keys = list(
		BB_ACTIVE_PET_COMMAND,
		BB_CLEAN_TARGET,
		BB_BEACON_TARGET,
		BB_PREVIOUS_BEACON_TARGET,
		BB_BOT_SUMMON_TARGET,
	)
	///list that ties each flag to its list key
	var/static/list/clean_flags = list(
		BB_CLEANABLE_BLOOD = CLEANBOT_CLEAN_BLOOD,
		BB_HUNTABLE_PESTS = CLEANBOT_CLEAN_PESTS,
		BB_CLEANABLE_DRAWINGS = CLEANBOT_CLEAN_DRAWINGS,
		BB_HUNTABLE_TRASH = CLEANBOT_CLEAN_TRASH,
	)
	ai_traits = PAUSE_DURING_DO_AFTER

/datum/ai_planning_subtree/pet_planning/cleanbot/SelectBehaviors(datum/ai_controller/basic_controller/bot/controller, seconds_per_tick)
	var/mob/living/basic/bot/bot_pawn = controller.pawn
	//we are DONE listening to orders
	if(bot_pawn.bot_access_flags & BOT_COVER_EMAGGED)
		return
	return ..()


/datum/ai_planning_subtree/cleaning_subtree

/datum/ai_planning_subtree/cleaning_subtree/SelectBehaviors(datum/ai_controller/basic_controller/bot/cleanbot/controller, seconds_per_tick)
	if(controller.blackboard_key_exists(BB_CLEAN_TARGET))
		controller.queue_behavior(/datum/ai_behavior/execute_clean, BB_CLEAN_TARGET)
		return SUBTREE_RETURN_FINISH_PLANNING

	var/list/final_hunt_list = list()

	final_hunt_list += controller.blackboard[BB_CLEANABLE_DECALS]
	var/list/flag_list = controller.clean_flags
	var/mob/living/basic/bot/cleanbot/bot_pawn = controller.pawn
	for(var/list_key in flag_list)
		if(!(bot_pawn.janitor_mode_flags & flag_list[list_key]))
			continue
		final_hunt_list += controller.blackboard[list_key]

	controller.queue_behavior(/datum/ai_behavior/find_and_set/in_list/clean_targets, BB_CLEAN_TARGET, final_hunt_list)

/datum/ai_behavior/find_and_set/in_list/clean_targets
	action_cooldown = 3 SECONDS

/datum/ai_behavior/find_and_set/in_list/clean_targets/search_tactic(datum/ai_controller/basic_controller/bot/controller, locate_paths, search_range)
	var/list/found = typecache_filter_list(oview(search_range, controller.pawn), locate_paths)
	var/list/ignore_list = controller.blackboard[BB_TEMPORARY_IGNORE_LIST]
	for(var/atom/found_item in found)
		if(QDELETED(controller.pawn))
			break
		if(LAZYACCESS(ignore_list, found_item))
			continue
		if(get_turf(found_item) == get_turf(controller.pawn))
			return found_item
		var/list/path = get_path_to(controller.pawn, found_item, max_distance = BOT_CLEAN_PATH_LIMIT, access = controller.get_access())
		if(!length(path))
			controller.add_to_blacklist(found_item)
			continue
		return found_item

/datum/ai_planning_subtree/acid_spray

/datum/ai_planning_subtree/acid_spray/SelectBehaviors(datum/ai_controller/basic_controller/bot/controller, seconds_per_tick)
	var/mob/living/basic/bot/cleanbot/bot_pawn = controller.pawn
	if(!(bot_pawn.bot_access_flags & BOT_COVER_EMAGGED))
		return
	if(controller.blackboard_key_exists(BB_ACID_SPRAY_TARGET))
		controller.queue_behavior(/datum/ai_behavior/execute_clean, BB_ACID_SPRAY_TARGET)
		return SUBTREE_RETURN_FINISH_PLANNING

	controller.queue_behavior(/datum/ai_behavior/find_and_set/spray_target, BB_ACID_SPRAY_TARGET, /mob/living/carbon/human, 5)

/datum/ai_behavior/find_and_set/spray_target
	action_cooldown = 30 SECONDS
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_behavior/find_and_set/spray_target/search_tactic(datum/ai_controller/controller, locate_path, search_range)
	var/list/ignore_list = controller.blackboard[BB_TEMPORARY_IGNORE_LIST]
	for(var/mob/living/carbon/human/human_target in oview(search_range, controller.pawn))
		if(LAZYACCESS(ignore_list, human_target))
			continue
		if(human_target.stat != CONSCIOUS || isnull(human_target.mind))
			continue
		return human_target
	return null

/datum/ai_behavior/execute_clean
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION | AI_BEHAVIOR_REQUIRE_REACH

/datum/ai_behavior/execute_clean/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/turf/target = controller.blackboard[target_key]
	if(isnull(target))
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/execute_clean/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	var/mob/living/basic/living_pawn = controller.pawn
	var/atom/target = controller.blackboard[target_key]

	if(QDELETED(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	living_pawn.UnarmedAttack(target, proximity_flag = TRUE)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/execute_clean/finish_action(datum/ai_controller/basic_controller/bot/controller, succeeded, target_key, targeting_strategy_key, hiding_location_key)
	. = ..()
	controller.set_blackboard_key(BB_POST_CLEAN_COOLDOWN, POST_CLEAN_COOLDOWN + world.time)
	var/atom/target = controller.blackboard[target_key]
	if(!succeeded && !isnull(target))
		controller.clear_blackboard_key(target_key)
		controller.add_to_blacklist(target)
		return
	if(QDELETED(target) || is_type_in_typecache(target, controller.blackboard[BB_HUNTABLE_TRASH]))
		return
	if(!iscarbon(target))
		controller.clear_blackboard_key(target_key)
		return
	var/list/speech_list = controller.blackboard[BB_CLEANBOT_EMAGGED_PHRASES]
	if(length(speech_list))
		var/mob/living/living_pawn = controller.pawn
		if(!QDELETED(living_pawn)) // pawn can be null at this point
			living_pawn.say(pick(speech_list), forced = "ai controller")
	controller.clear_blackboard_key(target_key)

/datum/ai_planning_subtree/use_mob_ability/foam_area
	ability_key = BB_CLEANBOT_FOAM
	finish_planning = FALSE

/datum/ai_planning_subtree/use_mob_ability/foam_area/SelectBehaviors(datum/ai_controller/basic_controller/bot/controller, seconds_per_tick)
	var/mob/living/basic/bot/bot_pawn = controller.pawn
	if(!(bot_pawn.bot_access_flags & BOT_COVER_EMAGGED))
		return
	return ..()

/datum/ai_planning_subtree/befriend_janitors

/datum/ai_planning_subtree/befriend_janitors/SelectBehaviors(datum/ai_controller/basic_controller/bot/controller, seconds_per_tick)
	var/mob/living/basic/bot/bot_pawn = controller.pawn
	//we are now evil. dont befriend the janitors
	if(bot_pawn.bot_access_flags & BOT_COVER_EMAGGED)
		return
	if(controller.blackboard_key_exists(BB_FRIENDLY_JANITOR))
		controller.queue_behavior(/datum/ai_behavior/befriend_target, BB_FRIENDLY_JANITOR, BB_FRIENDLY_MESSAGE)
		return SUBTREE_RETURN_FINISH_PLANNING

	controller.queue_behavior(/datum/ai_behavior/find_and_set/friendly_janitor, BB_FRIENDLY_JANITOR, /mob/living/carbon/human, 5)

/datum/ai_behavior/find_and_set/friendly_janitor
	action_cooldown = 30 SECONDS
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_behavior/find_and_set/friendly_janitor/search_tactic(datum/ai_controller/controller, locate_path, search_range)
	var/mob/living/living_pawn = controller.pawn
	for(var/mob/living/carbon/human/human_target in oview(search_range, living_pawn))
		if(human_target.stat != CONSCIOUS || isnull(human_target.mind))
			continue
		if(!HAS_TRAIT(human_target, TRAIT_CLEANBOT_WHISPERER))
			continue
		if((living_pawn.faction.Find(REF(human_target))))
			continue
		return human_target
	return null

/datum/ai_planning_subtree/find_patrol_beacon/cleanbot

/datum/ai_planning_subtree/find_patrol_beacon/cleanbot/SelectBehaviors(datum/ai_controller/basic_controller/bot/controller, seconds_per_tick)
	if(controller.blackboard[BB_POST_CLEAN_COOLDOWN] >= world.time)
		return
	return ..()

/datum/pet_command/clean
	command_name = "Clean"
	command_desc = "Command a cleanbot to clean the mess."
	requires_pointing = TRUE
	radial_icon = 'icons/obj/service/janitor.dmi'
	radial_icon_state = "mop"
	speech_commands = list("clean", "mop")

/datum/pet_command/clean/set_command_target(mob/living/parent, atom/target)
	if(isnull(target) || !istype(target, /obj/effect/decal/cleanable))
		return FALSE
	if(isnull(parent.ai_controller))
		return FALSE
	if(LAZYACCESS(parent.ai_controller.blackboard[BB_TEMPORARY_IGNORE_LIST], target))
		return FALSE
	return ..()

/datum/pet_command/clean/execute_action(datum/ai_controller/basic_controller/bot/controller)
	if(controller.blackboard_key_exists(BB_CURRENT_PET_TARGET))
		controller.queue_behavior(/datum/ai_behavior/execute_clean, BB_CURRENT_PET_TARGET)
		return SUBTREE_RETURN_FINISH_PLANNING

	controller.clear_blackboard_key(BB_ACTIVE_PET_COMMAND)

#undef BOT_CLEAN_PATH_LIMIT
#undef POST_CLEAN_COOLDOWN
