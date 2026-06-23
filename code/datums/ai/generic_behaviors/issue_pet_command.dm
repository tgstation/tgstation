/**
 * Issues a spoken pet command and points at the target.
 * Requires a blackboard key holding a list of /datum/pet_command instances.
 * Use a cooldown decorator in the tree  time_between_perform has no effect on one-shot behaviors.
 */
/datum/bt_node/ai_behavior/issue_pet_command
	/// Blackboard key holding a list of /datum/pet_command instances to search.
	var/command_list_key
	/// Typepath of the /datum/pet_command to locate in the list.
	var/command_type
	/// Blackboard key holding the target atom to point at.
	var/target_key
	/// If set, setup() requires at least one mob of this type within command_distance.
	var/commandable_mob_type
	/// Range to search for commandable mobs.
	var/command_distance = 5

/datum/bt_node/ai_behavior/issue_pet_command/setup(datum/ai_controller/controller)
	. = ..()
	if(!.)
		return FALSE
	if(commandable_mob_type)
		if(!locate(commandable_mob_type) in oview(command_distance, controller.pawn))
			return FALSE
	var/atom/target = controller.blackboard[target_key]
	return !QDELETED(target)

/datum/bt_node/ai_behavior/issue_pet_command/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/basic/living_pawn = controller.pawn
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	var/list/commands = controller.blackboard[command_list_key]
	if(!length(commands))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	var/datum/pet_command/cmd = locate(command_type) in commands
	if(isnull(cmd))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	INVOKE_ASYNC(living_pawn, TYPE_PROC_REF(/atom/movable, say), pick(cmd.speech_commands), forced = "controller")
	INVOKE_ASYNC(living_pawn, TYPE_PROC_REF(/mob, _pointed), target)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
