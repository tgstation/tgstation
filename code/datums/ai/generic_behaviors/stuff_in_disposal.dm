/// Grabs a downed target mob and stuffs them into a nearby disposal unit.
/datum/bt_node/ai_behavior/stuff_in_disposal
	time_between_perform = 2 SECONDS
	/// Blackboard key holding the mob to stuff.
	var/attack_target_key
	/// Blackboard key holding the disposal unit.
	var/disposal_target_key
	/// Set while stuff_mob_in's do_after is happening.
	VAR_PRIVATE/is_stuffing = FALSE
	/// TRUE once the async disposal stuffing has written its result.
	VAR_PRIVATE/async_stuff_done = FALSE
	/// Whether the stuff succeeded,d
	VAR_PRIVATE/async_stuff_succeeded = FALSE

/datum/bt_node/ai_behavior/stuff_in_disposal/perform(seconds_per_tick, datum/ai_controller/controller)
	if(is_stuffing)
		return AI_BEHAVIOR_DELAY

	if(async_stuff_done)
		return AI_BEHAVIOR_DELAY | (async_stuff_succeeded ? AI_BEHAVIOR_SUCCEEDED : AI_BEHAVIOR_FAILED)

	var/mob/living/target = controller.blackboard[attack_target_key]
	var/obj/machinery/disposal/disposal = controller.blackboard[disposal_target_key]
	var/mob/living/living_pawn = controller.pawn
	if(QDELETED(target) || QDELETED(disposal))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	if(!living_pawn.Adjacent(disposal))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	is_stuffing = TRUE
	INVOKE_ASYNC(src, PROC_REF(async_stuff), controller, target, disposal, living_pawn)
	return AI_BEHAVIOR_DELAY

/datum/bt_node/ai_behavior/stuff_in_disposal/proc/async_stuff(datum/ai_controller/controller, mob/living/target, obj/machinery/disposal/disposal, mob/living/living_pawn)
	var/stuffed = disposal.stuff_mob_in(target, living_pawn)
	if(!is_stuffing || QDELETED(living_pawn))
		return
	if(stuffed && !QDELETED(disposal))
		disposal.flush()
	async_stuff_succeeded = TRUE
	async_stuff_done = TRUE
	is_stuffing = FALSE

/datum/bt_node/ai_behavior/stuff_in_disposal/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	is_stuffing = FALSE
	async_stuff_done = FALSE
	async_stuff_succeeded = FALSE
	controller.clear_blackboard_key(attack_target_key)
	controller.clear_blackboard_key(disposal_target_key)
