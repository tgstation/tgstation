/**
 * Traverse to a target with the intention of picking it up.
 * If we can't do that, add it to a list of ignored items.
 */
/datum/ai_behavior/fetch
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT
	/// If true, this is a poorly trained pet who will eat food you throw instead of bringing it back
	var/will_eat_targets = TRUE

/datum/ai_behavior/fetch/perform(delta_time, datum/ai_controller/controller, target_key, delivery_key)
	. = ..()
	var/datum/weakref/thing_ref = controller.blackboard[target_key]
	var/obj/item/fetch_thing = thing_ref?.resolve()

	// It stopped existing
	if (!fetch_thing)
		finish_action(controller, FALSE, target_key, delivery_key)
		return
	var/mob/living/living_pawn = controller.pawn
	// We can't pick this up
	if (fetch_thing.anchored || !isturf(fetch_thing.loc) || !living_pawn.CanReach(fetch_thing))
		finish_action(controller, FALSE, target_key, delivery_key)
		return
	// We'd rather eat it
	if (will_eat_targets && IS_EDIBLE(fetch_thing))
		finish_action(controller, TRUE, target_key, delivery_key)
		return

	finish_action(controller, TRUE)

/datum/ai_behavior/fetch/finish_action(datum/ai_controller/controller, success, target_key, delivery_key)
	. = ..()
	if (success)
		return
	// Blacklist item if we failed
	var/datum/weakref/thing_ref = controller.blackboard[target_key]
	var/obj/item/target = thing_ref?.resolve()
	if (target)
		controller.blackboard[BB_FETCH_IGNORE_LIST][thing_ref] = TRUE
	controller.blackboard[target_key] = null
	controller.blackboard[delivery_key] = null

/**
 * The second half of fetching, deliver the item to a target.
 */
/datum/ai_behavior/deliver_item
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT

/datum/ai_behavior/deliver_item/perform(delta_time, datum/ai_controller/controller, delivery_key, storage_key)
	. = ..()
	var/datum/weakref/return_ref = controller.blackboard[delivery_key]
	var/mob/living/return_target = return_ref?.resolve()
	if(!return_target)
		finish_action(controller, FALSE, delivery_key)
		return

	deliver_item(controller, return_target, storage_key)
	finish_action(controller, TRUE, delivery_key)

/datum/ai_behavior/deliver_item/finish_action(datum/ai_controller/controller, success, delivery_key)
	. = ..()
	controller.blackboard[delivery_key] = null

/// Actually deliver the fetched item to the target, if we still have it
/datum/ai_behavior/deliver_item/proc/deliver_item(datum/ai_controller/controller, return_target, storage_key)
	var/atom/pawn = controller.pawn
	var/datum/weakref/carried_ref = controller.blackboard[storage_key]
	var/obj/item/carried_item = carried_ref?.resolve()
	if(!carried_item || carried_item.loc !== pawn)
		pawn.visible_message(spawn_notice("[pawn] looks around as if [pawn.p_they] [pawn.p_have] lost something."))
		finish_action(controller, FALSE)
		return

	pawn.visible_message(span_notice("[pawn] delivers [carried_item] to [return_target]."))
	carried_item.forceMove(get_turf(return_target))
	controller.blackboard[storage_key] = null
	return TRUE

/**
 * The alternate second half of fetching, attack the item if we can eat it.
 */
/datum/ai_behavior/eat_snack
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT

/datum/ai_behavior/eat_snack/perform(delta_time, datum/ai_controller/controller, target_key, delivery_key)
	. = ..()
	var/datum/weakref/thing_ref = controller.blackboard[target_key]
	var/obj/item/snack = thing_ref?.resolve()

	if(!istype(snack) || !IS_EDIBLE(snack) || !(isturf(snack.loc) || ishuman(snack.loc)))
		finish_action(controller, FALSE) // This isn't food at all

	var/mob/living/living_pawn = controller.pawn
	if(!in_range(living_pawn, snack))
		return

	if(isturf(snack.loc))
		snack.attack_animal(living_pawn) // snack attack!
	else if(iscarbon(snack.loc) && DT_PROB(10, delta_time))
		living_pawn.manual_emote("Stares at [snack.loc]'s [snack.name] intently.")

	if(QDELETED(snack)) // we ate it!
		finish_action(controller, TRUE, target_key, delivery_key)

/datum/ai_behavior/eat_snack/finish_action(datum/ai_controller/controller, succeeded, target_key, delivery_key)
	. = ..()
	controller.blackboard[target_key] = null
	controller.blackboard[delivery_key] = null
