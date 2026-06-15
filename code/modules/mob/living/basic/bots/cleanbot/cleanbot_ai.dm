#define BOT_CLEAN_PATH_LIMIT 15
#define POST_CLEAN_COOLDOWN 5 SECONDS

/datum/ai_controller/basic_controller/bot/cleanbot
	behavior_tree_json = "code/modules/mob/living/basic/bots/cleanbot/cleanbot.bt.json"
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
	reset_keys = list(
		BB_ACTIVE_PET_COMMAND,
		BB_CURRENT_TARGET,
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


/// Gathers nearby cleanable atoms: decals plus whatever types the cleanbot's currently enabled janitor mode flags allow.
/datum/target_source/cleanbot_cleanables

/datum/target_source/cleanbot_cleanables/collect_candidates(mob/living/pawn, datum/ai_controller/basic_controller/bot/cleanbot/controller, range)
	var/list/final_hunt_list = list()
	final_hunt_list += controller.blackboard[BB_CLEANABLE_DECALS]
	var/mob/living/basic/bot/cleanbot/bot_pawn = pawn
	for(var/list_key in controller.clean_flags)
		if(!(bot_pawn.janitor_mode_flags & controller.clean_flags[list_key]))
			continue
		final_hunt_list += controller.blackboard[list_key]
	if(!length(final_hunt_list))
		return list()
	var/list/type_filter = typecacheof(final_hunt_list)
	return typecache_filter_list(oview(range, pawn), type_filter)

///clean that shit bro fr fr 67
/datum/bt_node/ai_behavior/execute_clean
	var/target_key

/datum/bt_node/ai_behavior/execute_clean/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/basic/living_pawn = controller.pawn
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		EVLOG_TEXT(controller, EVLOG_CATEGORY_AI_BEHAVIORS, "[living_pawn] execute_clean: target deleted")
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	if(get_dist(living_pawn, target) > 1)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	EVLOG_MAPTEXT(controller, EVLOG_CATEGORY_AI_BEHAVIORS, "[living_pawn] cleaning [target]", get_turf(target), "Cleaning")
	living_pawn.UnarmedAttack(target, proximity_flag = TRUE)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/bt_node/ai_behavior/execute_clean/finish_action(datum/ai_controller/basic_controller/bot/controller, succeeded)
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


/// Valid if the target is a conscious human janitor-whisperer the cleanbot hasn't already befriended.
/datum/targeting_strategy/conscious_human/cleanbot_whisperer/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	. = ..()
	if(!.)
		return FALSE
	if(!HAS_TRAIT(target, TRAIT_CLEANBOT_WHISPERER))
		return FALSE
	return !living_mob.has_ally(REF(target))


/datum/bt_node/subtree/clean_pet_target
	behavior_tree_json = "clean_pet_target.bt.json"

///Tells the cleanbot to go clean a target
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
	controller.set_behavior_tree_override(SUBPLAN_ID_PET_COMMAND, /datum/bt_node/subtree/clean_pet_target)

#undef BOT_CLEAN_PATH_LIMIT
#undef POST_CLEAN_COOLDOWN
