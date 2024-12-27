///This behavior is for obj/items, it is used to free themselves out of the hands of whoever is holding them
/datum/ai_behavior/item_escape_grasp

/datum/ai_behavior/item_escape_grasp/perform(seconds_per_tick, datum/ai_controller/controller)
	var/obj/item/item_pawn = controller.pawn
	var/mob/item_holder = item_pawn.loc
	if(!istype(item_holder))
		//We're no longer being held. abort abort!!
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	item_pawn.visible_message(span_warning("[item_pawn] slips out of the hands of [item_holder]!"))
	item_holder.dropItemToGround(item_pawn, TRUE)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED


///This behavior is for obj/items, it is used to move closer to a target and throw themselves towards them.
/datum/ai_behavior/item_move_close_and_attack
	required_distance = 3
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT
	action_cooldown = 20
	///Sound to use
	var/attack_sound
	///Max attemps to make
	var/max_attempts = 3

/datum/ai_behavior/item_move_close_and_attack/setup(datum/ai_controller/controller, target_key, throw_count_key)
	. = ..()
	var/atom/target = controller.blackboard[target_key]
	if (isnull(target))
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/item_move_close_and_attack/perform(seconds_per_tick, datum/ai_controller/controller, target_key, throw_count_key)
	var/obj/item/item_pawn = controller.pawn
	var/atom/throw_target = controller.blackboard[target_key]

	item_pawn.visible_message(span_warning("[item_pawn] hurls towards [throw_target]!"))
	item_pawn.throw_at(throw_target, rand(4,5), 9)
	playsound(item_pawn.loc, attack_sound, 100, TRUE)
	controller.add_blackboard_key(throw_count_key, 1)
	if(controller.blackboard[throw_count_key] >= max_attempts)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_DELAY

/datum/ai_behavior/item_move_close_and_attack/finish_action(datum/ai_controller/controller, succeeded, target_key, throw_count_key)
	. = ..()
	reset_blackboard(controller, succeeded, target_key, throw_count_key)

/datum/ai_behavior/item_move_close_and_attack/proc/reset_blackboard(datum/ai_controller/controller, succeeded, target_key, throw_count_key)
	controller.clear_blackboard_key(target_key)
	controller.set_blackboard_key(throw_count_key, 0)

/datum/ai_behavior/item_move_close_and_attack/ghostly
	attack_sound = 'sound/items/haunted/ghostitemattack.ogg'
	max_attempts = 4

/datum/ai_behavior/item_move_close_and_attack/ghostly/haunted

/datum/ai_behavior/item_move_close_and_attack/ghostly/haunted/finish_action(datum/ai_controller/controller, succeeded, target_key, throw_count_key)
	controller.add_blackboard_key_assoc(BB_TO_HAUNT_LIST, controller.blackboard[target_key], -1)
	return ..()
