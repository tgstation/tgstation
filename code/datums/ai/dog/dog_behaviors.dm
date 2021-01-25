/datum/ai_behavior/battle_screech/dog
	screeches = list("barks","howls")

// Fetching makes the pawn chase after whatever it's targeting and pick it up when it's in range, with the dog_equip behavior
/datum/ai_behavior/fetch
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT

/datum/ai_behavior/fetch/perform(delta_time, datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn
	var/obj/item/fetch_thing = controller.blackboard[BB_FETCH_TARGET]

	if(fetch_thing.anchored || !isturf(fetch_thing.loc)) //Can't pick it up, so stop trying.
		finish_action(controller, FALSE)
		return

	if(in_range(living_pawn, fetch_thing))
		finish_action(controller, TRUE)
		return

	finish_action(controller, FALSE)

/datum/ai_behavior/fetch/finish_action(datum/ai_controller/controller, success)
	. = ..()

	if(!success) //Don't try again on this item if we failed
		var/list/item_ignorelist = controller.blackboard[BB_FETCH_IGNORE_LIST]
		var/obj/item/target = controller.blackboard[BB_FETCH_TARGET]
		item_ignorelist[target] = TRUE
		controller.blackboard[BB_FETCH_TARGET] = null
		controller.blackboard[BB_FETCH_THROWER] = null
	else
		// we've successfully made our way to the thing, now to get ready to bring it to someone
		controller.current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/simple_equip)

	controller.blackboard[BB_FETCHING] = FALSE


// This is simply a behaviour to pick up a fetch target
/datum/ai_behavior/simple_equip/perform(delta_time, datum/ai_controller/controller)
	var/obj/item/fetch_target = controller.blackboard[BB_FETCH_TARGET]
	if(!isturf(fetch_target?.loc)) // someone picked it up or something happened to it
		finish_action(controller, FALSE)
		return

	if(in_range(controller.pawn, fetch_target))
		pickup_item(controller, fetch_target)
		finish_action(controller, TRUE)
	else
		finish_action(controller, FALSE)

/datum/ai_behavior/simple_equip/finish_action(datum/ai_controller/controller, success)
	. = ..()
	controller.blackboard[BB_FETCH_TARGET] = null

/datum/ai_behavior/simple_equip/proc/pickup_item(datum/ai_controller/controller, obj/item/target)
	var/atom/pawn = controller.pawn
	drop_item(controller)
	pawn.visible_message("<span class='notice'>[pawn] picks up [target] in [pawn.p_their()] mouth.</span>")
	target.forceMove(pawn)
	controller.blackboard[BB_SIMPLE_CARRY_ITEM] = target
	return TRUE

/datum/ai_behavior/simple_equip/proc/drop_item(datum/ai_controller/controller)
	var/obj/item/carried_item = controller.blackboard[BB_SIMPLE_CARRY_ITEM]
	if(!carried_item)
		return

	var/atom/pawn = controller.pawn
	pawn.visible_message("<span class='notice'>[pawn] drops [carried_item].</span>")
	carried_item.forceMove(get_turf(pawn))
	controller.blackboard[BB_SIMPLE_CARRY_ITEM] = null
	return TRUE



// This behavior involves dropping off a carried item to a specified person (or place)
/datum/ai_behavior/deliver_item
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT

/datum/ai_behavior/deliver_item/perform(delta_time, datum/ai_controller/controller)
	var/mob/living/return_target = controller.blackboard[BB_FETCH_THROWER]
	if(!return_target)
		finish_action(controller, FALSE)
	if(in_range(controller.pawn, return_target))
		deliver_item(controller)
		finish_action(controller, TRUE)

/datum/ai_behavior/deliver_item/finish_action(datum/ai_controller/controller, success)
	. = ..()
	controller.blackboard[BB_FETCH_THROWER] = null
	controller.blackboard[BB_DELIVERING] = FALSE

/// Actually drop the fetched item to the target
/datum/ai_behavior/deliver_item/proc/deliver_item(datum/ai_controller/controller)
	var/obj/item/carried_item = controller.blackboard[BB_SIMPLE_CARRY_ITEM]
	var/atom/movable/return_target = controller.blackboard[BB_FETCH_THROWER]
	if(!carried_item)
		return

	if(ismob(return_target))
		controller.pawn.visible_message("<span class='notice'>[controller.pawn] delivers [carried_item] at [return_target]'s feet.</span>")
	else // not sure how to best phrase this
		controller.pawn.visible_message("<span class='notice'>[controller.pawn] delivers [carried_item] to [return_target].</span>")

	carried_item.forceMove(get_turf(return_target))
	controller.blackboard[BB_SIMPLE_CARRY_ITEM] = null
	return TRUE
