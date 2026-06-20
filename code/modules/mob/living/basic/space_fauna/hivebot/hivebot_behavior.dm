/// Says a random binary string to a hive partner. Movement to the partner is handled
/// in the tree via a move_to_target leaf; the target key is cleared by a clear_bb_key leaf.
/datum/bt_node/ai_behavior/relay_message
	/// Blackboard key holding the hive partner to talk at.
	var/target_key
	/// Number of bits in the message we relay.
	var/length_of_message = 4

/datum/bt_node/ai_behavior/relay_message/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/target = controller.blackboard[target_key]
	var/mob/living/living_pawn = controller.pawn

	if(QDELETED(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	var/message_relayed = ""
	for(var/i in 1 to length_of_message)
		message_relayed += prob(50) ? "1" : "0"
	living_pawn.say(message_relayed, forced = "AI Controller")
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/// Repairs a damaged machine once in range. Finding the machine is a separate
/// acquire_target leaf; movement is a move_to_target leaf.
/datum/bt_node/ai_behavior/hunt_target/repair_machines
	always_reset_target = TRUE

/datum/bt_node/ai_behavior/hunt_target/repair_machines/target_caught(mob/living/basic/hivebot/mechanic/hunter, obj/machinery/repair_target)
	hunter.repair_machine(repair_target)
