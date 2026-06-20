#define MAXIMUM_GUTLUNCH_POP 20
/datum/ai_controller/basic_controller/gutlunch
	ai_movement = /datum/ai_movement/basic_avoidance

/datum/ai_controller/basic_controller/gutlunch/gutlunch_warrior
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
		BB_BABIES_PARTNER_TYPES = list(/mob/living/basic/mining/gutlunch/milk),
		BB_BABIES_CHILD_TYPES = list(/mob/living/basic/mining/gutlunch/grub),
		BB_MAX_CHILDREN = 5,
		BB_FUCKS = TRUE,
	)
	behavior_tree_json = "code/modules/mob/living/basic/lavaland/gutlunchers/gutlunch_warrior.bt.json"

/datum/ai_controller/basic_controller/gutlunch/gutlunch_baby
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_FIND_MOM_TYPES = list(/mob/living/basic/mining/gutlunch/milk),
	)
	behavior_tree_json = "code/modules/mob/living/basic/lavaland/gutlunchers/gutlunch_baby.bt.json"

/datum/ai_controller/basic_controller/gutlunch/gutlunch_milk
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)
	behavior_tree_json = "code/modules/mob/living/basic/lavaland/gutlunchers/gutlunch_milk.bt.json"

/datum/pet_command/mine_walls
	command_name = "Mine"
	radial_icon_state = "mine"
	command_desc = "Command your pet to mine down walls."
	speech_commands = list("mine", "smash")

/datum/pet_command/mine_walls/try_activate_command(mob/living/commander, radial_command)
	var/mob/living/parent = weak_parent.resolve()
	if(isnull(parent))
		return
	//no walls for us to mine
	var/target_in_vicinity = locate(/turf/closed/mineral) in oview(9, parent)
	if(isnull(target_in_vicinity))
		return
	return ..()

/datum/pet_command/mine_walls/execute_action(datum/ai_controller/controller)
	controller.set_behavior_tree_override(SUBPLAN_ID_PET_COMMAND, /datum/bt_node/subtree/pet_command/mine_walls)

/datum/pet_command/mine_walls/retrieve_command_text(atom/living_pet, atom/target)
	return "signals [living_pet] to start mining!"

//pet commands
/datum/pet_command/breed/gutlunch

/datum/pet_command/breed/gutlunch/set_command_target(mob/living/parent, atom/target)
	if(GLOB.gutlunch_count >= MAXIMUM_GUTLUNCH_POP)
		parent.balloon_alert_to_viewers("can't reproduce anymore!")
		return FALSE
	return ..()

/// Interacts with the food trough to eat ore, then clears the hungry flag.
/datum/bt_node/ai_behavior/hunt_target/interact_with_target/food_trough
	always_reset_target = TRUE
	behavior_combat_mode = FALSE

/datum/bt_node/ai_behavior/hunt_target/interact_with_target/food_trough/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	if(succeeded)
		controller.clear_blackboard_key(BB_CHECK_HUNGRY)

///Find nearby ashwalkers. we love lizards.
/datum/bt_node/ai_behavior/befriend_ashwalkers
	time_between_perform = 5 SECONDS
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/bt_node/ai_behavior/befriend_ashwalkers/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn
	for(var/mob/living/potential_friend in oview(9, living_pawn))
		if(!isashwalker(potential_friend) || living_pawn.has_ally(REF(potential_friend)))
			continue
		living_pawn.befriend(potential_friend)
		to_chat(potential_friend, span_nicegreen("[living_pawn] looks at you with endearing eyes!"))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED


/// Searches for and moves to a parent mob (of types in BB_FIND_MOM_TYPES), sets BB_FOUND_MOM.
/datum/bt_node/ai_behavior/find_parent
	var/mom_types_key
	var/found_mom_key

/datum/bt_node/ai_behavior/find_parent/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living_pawn = controller.pawn
	var/list/mom_types = controller.blackboard[mom_types_key]
	if(!length(mom_types))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	for(var/mob/mother in oview(7, living_pawn))
		if(!is_type_in_list(mother, mom_types))
			continue
		controller.set_blackboard_key(found_mom_key, mother)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

//

/// Mine walls pet command subtree: find mineral wall -> move to it -> mine it -> clear command.
/datum/bt_node/subtree/pet_command/mine_walls
	behavior_tree_json = "code/datums/ai/basic_mobs/pet_commands/pet_command_mine_walls.bt.json"


#undef MAXIMUM_GUTLUNCH_POP
