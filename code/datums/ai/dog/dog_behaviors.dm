/datum/ai_behavior/battle_screech/dog
	screeches = list("barks","howls")

/datum/ai_behavior/dog_fetch
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT

///Called by the AI controller when this action is performed
/datum/ai_behavior/dog_fetch/perform(delta_time, datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn
	var/obj/item/fetch_thing = controller.blackboard[BB_DOG_FETCH_TARGET]

	if(fetch_thing.anchored) //Can't pick it up, so stop trying.
		finish_action(controller, FALSE)
		return

	if(in_range(living_pawn, fetch_thing))
		finish_action(controller, TRUE)
		return

	finish_action(controller, FALSE)

/datum/ai_behavior/dog_fetch/finish_action(datum/ai_controller/controller, success)
	. = ..()

	if(!success) //Don't try again on this item if we failed
		var/list/item_ignorelist = controller.blackboard[BB_DOG_FETCH_TARGET_IGNORE]
		var/obj/item/target = controller.blackboard[BB_DOG_FETCH_TARGET]

		item_ignorelist[target] = TRUE
	else
		controller.current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/dog_equip)

	controller.blackboard[BB_DOG_FETCHING] = FALSE


/datum/ai_behavior/dog_equip/perform(delta_time, datum/ai_controller/controller)
	var/obj/item/fetch_target = controller.blackboard[BB_DOG_FETCH_TARGET]
	if(in_range(controller.pawn, fetch_target))
		pickup_item(controller, fetch_target)
		finish_action(controller, TRUE)

/datum/ai_behavior/dog_equip/finish_action(datum/ai_controller/controller, success)
	. = ..()
	controller.blackboard[BB_DOG_FETCH_TARGET] = null

/datum/ai_behavior/dog_equip/proc/pickup_item(datum/ai_controller/controller, obj/item/target)
	var/atom/pawn = controller.pawn
	drop_item(controller)
	pawn.visible_message("<span class='notice'>[pawn] picks up [target] in [pawn.p_their()] mouth.</span>")
	target.forceMove(pawn)
	controller.blackboard[BB_DOG_CARRY_ITEM] = target
	return TRUE

/datum/ai_behavior/dog_equip/proc/drop_item(datum/ai_controller/controller)
	var/obj/item/carried_item = controller.blackboard[BB_DOG_CARRY_ITEM]
	if(!carried_item)
		return

	var/atom/pawn = controller.pawn
	pawn.visible_message("<span class='notice'>[pawn] drops [carried_item].</span>")
	carried_item.forceMove(get_turf(pawn))
	controller.blackboard[BB_DOG_CARRY_ITEM] = null
	return TRUE



/datum/ai_behavior/dog_deliver
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT

/datum/ai_behavior/dog_deliver/perform(delta_time, datum/ai_controller/controller)
	var/mob/living/return_target = controller.blackboard[BB_DOG_FETCH_THROWER]
	if(in_range(controller.pawn, return_target))
		deliver_item(controller)
		finish_action(controller, TRUE)

/datum/ai_behavior/dog_deliver/finish_action(datum/ai_controller/controller, success)
	. = ..()
	controller.blackboard[BB_DOG_FETCH_THROWER] = null
	controller.blackboard[BB_DOG_DELIVERING] = FALSE

/datum/ai_behavior/dog_deliver/proc/deliver_item(datum/ai_controller/controller)
	var/obj/item/carried_item = controller.blackboard[BB_DOG_CARRY_ITEM]
	var/mob/living/return_target = controller.blackboard[BB_DOG_FETCH_THROWER]
	if(!carried_item)
		return

	var/atom/pawn = controller.pawn
	pawn.visible_message("<span class='notice'>[pawn] delivers [carried_item] at [return_target]'s feet.</span>")
	carried_item.forceMove(get_turf(pawn))
	controller.blackboard[BB_DOG_CARRY_ITEM] = null
	return TRUE



/datum/ai_behavior/dog_sic
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT

/datum/ai_behavior/dog_deliver/perform(delta_time, datum/ai_controller/controller)
	var/mob/living/return_target = controller.blackboard[BB_DOG_FETCH_THROWER]
	if(in_range(controller.pawn, return_target))
		deliver_item(controller)
		finish_action(controller, TRUE)

/datum/ai_behavior/dog_deliver/finish_action(datum/ai_controller/controller, success)
	. = ..()
	controller.blackboard[BB_DOG_FETCH_THROWER] = null
	controller.blackboard[BB_DOG_DELIVERING] = FALSE

/datum/ai_behavior/dog_deliver/proc/deliver_item(datum/ai_controller/controller)
	var/obj/item/carried_item = controller.blackboard[BB_DOG_CARRY_ITEM]
	var/mob/living/return_target = controller.blackboard[BB_DOG_FETCH_THROWER]
	if(!carried_item)
		return

	var/atom/pawn = controller.pawn
	pawn.visible_message("<span class='notice'>[pawn] delivers [carried_item] at [return_target]'s feet.</span>")
	carried_item.forceMove(get_turf(pawn))
	controller.blackboard[BB_DOG_CARRY_ITEM] = null
	return TRUE


