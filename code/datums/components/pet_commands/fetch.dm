/**
 * # Pet Command: Fetch
 * Watch for someone throwing or pointing at something and then go get it and bring it back.
 * If it's food we might eat it instead.
 */
/datum/pet_command/fetch
	command_name = "Fetch"
	command_desc = "Command your pet to retrieve something you throw or point at."
	radial_icon_state = "fetch"
	requires_pointing = TRUE
	speech_commands = list("fetch")
	command_feedback = "bounces"
	pointed_reaction = "with great interest"
	/// If true, this command will trigger if the pet sees a friend throw any item, if they're not doing anything else
	var/trigger_on_throw = TRUE
	/// If true, this is a poorly trained pet who will eat food you throw instead of bringing it back
	var/will_eat_targets = TRUE

/datum/pet_command/fetch/New(mob/living/parent)
	. = ..()
	if(isnull(parent))
		return
	parent.AddElement(/datum/element/ai_held_item) // We don't remove this on destroy because they might still be holding something

/datum/pet_command/fetch/add_new_friend(mob/living/tamer)
	. = ..()
	RegisterSignal(tamer, COMSIG_MOB_THROW, PROC_REF(listened_throw))

/datum/pet_command/fetch/remove_friend(mob/living/unfriended)
	. = ..()
	UnregisterSignal(unfriended, COMSIG_MOB_THROW)

/datum/pet_command/fetch/retrieve_command_text(atom/living_pet, atom/target)
	return isnull(target) ? null : "signals [living_pet] to fetch [target]!"

/// A friend has thrown something, if we're listening or at least not busy then go get it
/datum/pet_command/fetch/proc/listened_throw(mob/living/carbon/thrower)
	SIGNAL_HANDLER

	var/mob/living/parent = weak_parent.resolve()
	if (!parent)
		return

	var/list/blackboard = parent.ai_controller.blackboard
	if (!trigger_on_throw && !blackboard[BB_ACTIVE_PET_COMMAND])
		return // We don't have a command and we only listen to commands
	if (blackboard[BB_ACTIVE_PET_COMMAND] && blackboard[BB_ACTIVE_PET_COMMAND] != src)
		return // We have a command and it's not this one
	if (blackboard[BB_CURRENT_PET_TARGET] || blackboard[BB_FETCH_DELIVER_TO])
		return // We're already very fetching
	if (!can_see(parent, thrower, length = sense_radius))
		return // Can't see it

	var/obj/item/thrown_thing = thrower.get_active_held_item()
	if (!isitem(thrown_thing))
		return
	if (blackboard[BB_FETCH_IGNORE_LIST]?[thrown_thing])
		return // We're ignoring it already

	RegisterSignal(thrown_thing, COMSIG_MOVABLE_THROW_LANDED, PROC_REF(listen_throw_land))

/// A throw we were listening to has finished, see if it's in range for us to try grabbing it
/datum/pet_command/fetch/proc/listen_throw_land(obj/item/thrown_thing, datum/thrownthing/throwingdatum)
	SIGNAL_HANDLER

	UnregisterSignal(thrown_thing, COMSIG_MOVABLE_THROW_LANDED)
	var/mob/living/parent = weak_parent.resolve()
	if (!parent)
		return
	if (!isturf(thrown_thing.loc))
		return
	if (!can_see(parent, thrown_thing, length = sense_radius))
		return

	var/mob/thrower = throwingdatum?.get_thrower()
	if(!istype(thrower))
		return
	try_activate_command(thrower)
	set_command_target(parent, thrown_thing)
	parent.ai_controller.set_blackboard_key(BB_FETCH_DELIVER_TO, thrower)

// Don't try and fetch turfs or anchored objects if someone points at them
/datum/pet_command/fetch/look_for_target(mob/living/pointing_friend, obj/item/pointed_atom)
	if (!istype(pointed_atom))
		return FALSE
	if (pointed_atom.anchored)
		return FALSE
	. = ..()
	if (!.)
		return FALSE

	var/mob/living/parent = weak_parent.resolve()
	parent.ai_controller.set_blackboard_key(BB_FETCH_DELIVER_TO, pointing_friend)

// Install the fetch BT subtree. The subtree itself handles all phases (seek → pick up → deliver).
/datum/pet_command/fetch/execute_action(datum/ai_controller/controller)
	controller.set_behavior_tree_override(SUBPLAN_ID_PET_COMMAND, /datum/bt_node/subtree/pet_command/fetch)
