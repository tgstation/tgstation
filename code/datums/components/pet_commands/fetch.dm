/**
 * # Pet Command: Fetch
 * Watch for someone throwing or pointing at something and then go get it and bring it back.
 * If it's food we might eat it instead.
 */
/datum/pet_command/point_targetting/fetch
	command_name = "Fetch"
	command_desc = "Command your pet to retrieve something you throw or point at."
	radial_icon = 'icons/mob/actions/actions_spells.dmi'
	radial_icon_state = "summons"
	speech_commands = list("fetch")
	command_feedback = "bounces"
	pointed_reaction = "with great interest"
	/// If true, this command will trigger if the pet sees a friend throw any item, if they're not doing anything else
	var/trigger_on_throw = TRUE
	/// If true, this is a poorly trained pet who will eat food you throw instead of bringing it back
	var/will_eat_targets = TRUE

/datum/pet_command/point_targetting/fetch/New(mob/living/parent)
	. = ..()
	parent.AddElement(/datum/element/ai_held_item) // We don't remove this on destroy because they might still be holding something

/datum/pet_command/point_targetting/fetch/add_new_friend(mob/living/tamer)
	. = ..()
	RegisterSignal(tamer, COMSIG_MOB_THROW, PROC_REF(listened_throw))

/datum/pet_command/point_targetting/fetch/remove_friend(mob/living/unfriended)
	. = ..()
	UnregisterSignal(unfriended, COMSIG_MOB_THROW)

/// A friend has thrown something, if we're listening or at least not busy then go get it
/datum/pet_command/point_targetting/fetch/proc/listened_throw(mob/living/carbon/thrower)
	SIGNAL_HANDLER

	var/mob/living/parent = weak_parent.resolve()
	if (!parent)
		return

	var/list/blackboard = parent.ai_controller.blackboard
	if (!trigger_on_throw && !blackboard[BB_ACTIVE_PET_COMMAND])
		return // We don't have a command and we only listen to commands
	if (blackboard[BB_ACTIVE_PET_COMMAND] && blackboard[BB_ACTIVE_PET_COMMAND] != WEAKREF(src))
		return // We have a command and it's not this one
	if (blackboard[BB_CURRENT_PET_TARGET] || blackboard[BB_FETCH_DELIVER_TO])
		return // We're already very fetching
	if (!can_see(parent, thrower, length = sense_radius))
		return // Can't see it

	var/obj/item/thrown_thing = thrower.get_active_held_item()
	if (!isitem(thrown_thing))
		return
	if (blackboard[BB_FETCH_IGNORE_LIST] && blackboard[BB_FETCH_IGNORE_LIST][WEAKREF(thrown_thing)])
		return // We're ignoring it already

	RegisterSignal(thrown_thing, COMSIG_MOVABLE_THROW_LANDED, PROC_REF(listen_throw_land))

/// A throw we were listening to has finished, see if it's in range for us to try grabbing it
/datum/pet_command/point_targetting/fetch/proc/listen_throw_land(obj/item/thrown_thing, datum/thrownthing/throwing_datum)
	SIGNAL_HANDLER

	UnregisterSignal(thrown_thing, COMSIG_MOVABLE_THROW_LANDED)
	var/mob/living/parent = weak_parent.resolve()
	if (!parent)
		return
	if (!isturf(thrown_thing.loc))
		return
	if (!can_see(parent, thrown_thing, length = sense_radius))
		return

	try_activate_command(throwing_datum.thrower)
	set_command_target(parent, thrown_thing)
	parent.ai_controller.blackboard[BB_FETCH_DELIVER_TO] = WEAKREF(throwing_datum.thrower)

// Don't try and fetch turfs or anchored objects if someone points at them
/datum/pet_command/point_targetting/fetch/look_for_target(mob/living/pointing_friend, obj/item/pointed_atom)
	if (!istype(pointed_atom))
		return FALSE
	if (pointed_atom.anchored)
		return FALSE
	. = ..()
	if (!.)
		return FALSE

	var/mob/living/parent = weak_parent.resolve()
	parent.ai_controller.blackboard[BB_FETCH_DELIVER_TO] = WEAKREF(pointing_friend)

// Finally, plan our actions
/datum/pet_command/point_targetting/fetch/execute_action(datum/ai_controller/controller)
	controller.queue_behavior(/datum/ai_behavior/forget_failed_fetches)

	var/datum/weakref/weak_target = controller.blackboard[BB_CURRENT_PET_TARGET]
	var/atom/target = weak_target?.resolve()
	// We got something to fetch so go fetch it
	if (target)
		if (get_dist(controller.pawn, target) > 1) // We're not there yet
			controller.queue_behavior(/datum/ai_behavior/fetch_seek, BB_CURRENT_PET_TARGET, BB_FETCH_DELIVER_TO)
			return SUBTREE_RETURN_FINISH_PLANNING
		// If mobs could attack food you would branch here to call `eat_fetched_snack`, however that's a task for the future
		controller.queue_behavior(/datum/ai_behavior/pick_up_item, BB_CURRENT_PET_TARGET, BB_SIMPLE_CARRY_ITEM)
		return SUBTREE_RETURN_FINISH_PLANNING

	var/datum/weakref/carried_ref = controller.blackboard[BB_SIMPLE_CARRY_ITEM]
	var/obj/item/carried_item = carried_ref?.resolve()
	if (!carried_item)
		return

	var/datum/weakref/delivery_ref = controller.blackboard[BB_FETCH_DELIVER_TO]
	var/atom/delivery_target = delivery_ref?.resolve()
	if (!delivery_target || !can_see(controller.pawn, delivery_target, sense_radius))
		// We don't know where to return this to so we're just going to keep it
		controller.blackboard[BB_ACTIVE_PET_COMMAND] = null
		return

	// We got something to deliver and someone to deliver it to
	controller.queue_behavior(/datum/ai_behavior/deliver_fetched_item, BB_FETCH_DELIVER_TO, BB_SIMPLE_CARRY_ITEM)
	return SUBTREE_RETURN_FINISH_PLANNING
