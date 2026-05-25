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
	behavior_nodes = BT_SELECTOR(\
		BT_SUBTREE(/datum/bt_node/subtree/escape_captivity/pacifist),\
		BT_SUBTREE(/datum/bt_node/subtree/bot_respond_to_summon),\
		BT_LEAF(/datum/bt_node/ai_behavior/pet_planning),\
		BT_DECORATOR(/datum/bt_node/decorator/bot_is_emagged,\
			BT_PARALLEL(BT_PARALLEL_FAILURE_CHILD_ONE, BT_PARALLEL_SUCCESS_CHILD_ONE, TRUE, TRUE,\
				BT_SELECTOR(\
					BT_DECORATOR(/datum/bt_node/decorator/bb_key_set,\
						BT_SEQUENCE(\
							BT_LEAF(/datum/bt_node/ai_behavior/move_to_target, BB_CLEAN_TARGET, 0, TRUE),\
							BT_LEAF(/datum/bt_node/ai_behavior/execute_clean, BB_CLEAN_TARGET)\
						),\
						"observer_abort" = BT_ABORT_BOTH,\
						"key" = BB_CLEAN_TARGET\
					),\
					BT_SELECTOR(\
						BT_DECORATOR(/datum/bt_node/decorator/bb_key_set,\
							BT_SEQUENCE(\
								BT_LEAF(/datum/bt_node/ai_behavior/move_to_target, BB_FRIENDLY_JANITOR, 1, TRUE),\
								BT_LEAF(/datum/bt_node/ai_behavior/befriend_target, BB_FRIENDLY_JANITOR, BB_FRIENDLY_MESSAGE)\
							),\
							"key" = BB_FRIENDLY_JANITOR\
						),\
						BT_DECORATOR(/datum/bt_node/decorator/bb_key_set,\
							BT_LEAF(/datum/bt_node/ai_behavior/find_friendly_janitor, BB_FRIENDLY_JANITOR),\
							"invert" = TRUE,\
							"key" = BB_FRIENDLY_JANITOR\
						)\
					),\
					BT_LEAF(/datum/bt_node/ai_behavior/use_mob_ability, BB_CLEANBOT_FOAM),\
					BT_SUBTREE(/datum/bt_node/subtree/bot_salute_authority),\
					BT_DECORATOR(/datum/bt_node/decorator/bb_key_cooldown,\
						BT_SUBTREE(/datum/bt_node/subtree/bot_patrol),\
						"cooldown_key" = BB_POST_CLEAN_COOLDOWN\
					)\
				),\
				BT_DECORATOR(/datum/bt_node/decorator/bb_key_set,\
					BT_LEAF(/datum/bt_node/ai_behavior/find_clean_target, BB_CLEAN_TARGET),\
					"invert" = TRUE,\
					"key" = BB_CLEAN_TARGET\
				)\
			),\
			"invert" = TRUE\
		),\
		BT_DECORATOR(/datum/bt_node/decorator/bot_is_emagged,\
			BT_PARALLEL(BT_PARALLEL_FAILURE_CHILD_ONE, BT_PARALLEL_SUCCESS_CHILD_ONE, FALSE, FALSE,\
				BT_SELECTOR(\
					BT_DECORATOR(/datum/bt_node/decorator/bb_key_set,\
						BT_SEQUENCE(\
							BT_LEAF(/datum/bt_node/ai_behavior/move_to_target, BB_ACID_SPRAY_TARGET, 0, TRUE),\
							BT_LEAF(/datum/bt_node/ai_behavior/execute_clean, BB_ACID_SPRAY_TARGET)\
						),\
						"observer_abort" = BT_ABORT_BOTH,\
						"key" = BB_ACID_SPRAY_TARGET\
					),\
					BT_DECORATOR(/datum/bt_node/decorator/bb_key_cooldown,\
						BT_SUBTREE(/datum/bt_node/subtree/bot_patrol),\
						"cooldown_key" = BB_POST_CLEAN_COOLDOWN\
					)\
				),\
				BT_DECORATOR(/datum/bt_node/decorator/bb_key_set,\
					BT_LEAF(/datum/bt_node/ai_behavior/find_spray_target, BB_ACID_SPRAY_TARGET),\
					"invert" = TRUE,\
					"key" = BB_ACID_SPRAY_TARGET\
				)\
			)\
		)\
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

// =============================================================================
// Clean target search
// =============================================================================

/datum/bt_node/ai_behavior/find_clean_target
	action_cooldown = 3 SECONDS

/datum/bt_node/ai_behavior/find_clean_target/perform(seconds_per_tick, datum/ai_controller/basic_controller/bot/cleanbot/controller, target_key)
	var/list/final_hunt_list = list()
	final_hunt_list += controller.blackboard[BB_CLEANABLE_DECALS]
	var/list/flag_list = controller.clean_flags
	var/mob/living/basic/bot/cleanbot/bot_pawn = controller.pawn
	for(var/list_key in flag_list)
		if(!(bot_pawn.janitor_mode_flags & flag_list[list_key]))
			continue
		final_hunt_list += controller.blackboard[list_key]

	if(!length(final_hunt_list))
		EVLOG_TEXT(controller, EVLOG_CATEGORY_AI_BEHAVIORS, "[bot_pawn] find_clean_target: no cleanable types enabled (janitor_mode_flags=[bot_pawn.janitor_mode_flags])")
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/list/type_filter = typecacheof(final_hunt_list)
	var/list/found = typecache_filter_list(oview(5, controller.pawn), type_filter)
	var/list/ignore_list = controller.blackboard[BB_TEMPORARY_IGNORE_LIST]
	for(var/atom/found_item in found)
		if(QDELETED(controller.pawn))
			return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
		if(LAZYACCESS(ignore_list, found_item))
			continue
		if(get_turf(found_item) == get_turf(controller.pawn))
			EVLOG_MAPTEXT(controller, EVLOG_CATEGORY_AI_BEHAVIORS, "[bot_pawn] clean target (same turf): [found_item]", get_turf(found_item), "Clean")
			controller.set_blackboard_key(target_key, found_item)
			return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
		var/list/path = get_path_to(controller.pawn, found_item, max_distance = BOT_CLEAN_PATH_LIMIT, access = controller.get_access())
		if(!length(path))
			controller.add_to_blacklist(found_item)
			continue
		EVLOG_MAPTEXT(controller, EVLOG_CATEGORY_AI_BEHAVIORS, "[bot_pawn] clean target: [found_item]", get_turf(found_item), "Clean")
		EVLOG_LINES(controller, EVLOG_CATEGORY_AI_BEHAVIORS, "Clean path", get_turf(bot_pawn), get_turf(found_item))
		controller.set_blackboard_key(target_key, found_item)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	EVLOG_TEXT(controller, EVLOG_CATEGORY_AI_BEHAVIORS, "[bot_pawn] find_clean_target: no reachable clean target in range ([length(found)] candidates, [length(ignore_list)] ignored)")
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

// =============================================================================
// Execute clean
// =============================================================================

/datum/bt_node/ai_behavior/execute_clean

/datum/bt_node/ai_behavior/execute_clean/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	var/mob/living/basic/living_pawn = controller.pawn
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		EVLOG_TEXT(controller, EVLOG_CATEGORY_AI_BEHAVIORS, "[living_pawn] execute_clean: target deleted")
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	if(get_dist(living_pawn, target) > 0)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	EVLOG_MAPTEXT(controller, EVLOG_CATEGORY_AI_BEHAVIORS, "[living_pawn] cleaning [target]", get_turf(target), "Cleaning")
	living_pawn.UnarmedAttack(target, proximity_flag = TRUE)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/bt_node/ai_behavior/execute_clean/finish_action(datum/ai_controller/basic_controller/bot/controller, succeeded, target_key)
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
		if(!QDELETED(living_pawn))
			living_pawn.say(pick(speech_list), forced = "ai controller")
	controller.clear_blackboard_key(target_key)

// =============================================================================
// Acid spray target search (emagged)
// =============================================================================

/datum/bt_node/ai_behavior/find_spray_target
	action_cooldown = 30 SECONDS

/datum/bt_node/ai_behavior/find_spray_target/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	var/list/ignore_list = controller.blackboard[BB_TEMPORARY_IGNORE_LIST]
	for(var/mob/living/carbon/human/human_target in oview(5, controller.pawn))
		if(LAZYACCESS(ignore_list, human_target))
			continue
		if(human_target.stat != CONSCIOUS || isnull(human_target.mind))
			continue
		EVLOG_MAPTEXT(controller, EVLOG_CATEGORY_AI_BEHAVIORS, "[controller.pawn] acid spray target: [human_target]", get_turf(human_target), "Spray")
		EVLOG_LINES(controller, EVLOG_CATEGORY_AI_BEHAVIORS, "Spray target", get_turf(controller.pawn), get_turf(human_target))
		controller.set_blackboard_key(target_key, human_target)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	EVLOG_TEXT(controller, EVLOG_CATEGORY_AI_BEHAVIORS, "[controller.pawn] find_spray_target: no valid human in range")
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

// =============================================================================
// Friendly janitor search
// =============================================================================

/datum/bt_node/ai_behavior/find_friendly_janitor
	action_cooldown = 30 SECONDS

/datum/bt_node/ai_behavior/find_friendly_janitor/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	var/mob/living/living_pawn = controller.pawn
	for(var/mob/living/carbon/human/human_target in oview(5, living_pawn))
		if(human_target.stat != CONSCIOUS || isnull(human_target.mind))
			continue
		if(!HAS_TRAIT(human_target, TRAIT_CLEANBOT_WHISPERER))
			continue
		if(living_pawn.has_ally(REF(human_target)))
			continue
		controller.set_blackboard_key(target_key, human_target)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

// =============================================================================
// Pet command: clean
// =============================================================================

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
	var/atom/target = controller.blackboard[BB_CURRENT_PET_TARGET]
	if(QDELETED(target))
		controller.clear_blackboard_key(BB_ACTIVE_PET_COMMAND)
		return
	// Copy pet target into the cleaning blackboard key so the BT cleaning branch picks it up next tick
	controller.set_blackboard_key(BB_CLEAN_TARGET, target)
	controller.clear_blackboard_key(BB_ACTIVE_PET_COMMAND)

#undef BOT_CLEAN_PATH_LIMIT
#undef POST_CLEAN_COOLDOWN
