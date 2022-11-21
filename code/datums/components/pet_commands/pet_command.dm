/**
 * # Pet Command
 * Set some AI blackboard commands in response to receiving instructions
 * This is abstract and should be extended for actual behaviour
 */
/datum/component/pet_command
	/// Key for command applied when you receive an order
	var/command_key = PET_COMMAND_NONE
	/// Speech strings to listen out for
	var/list/speech_commands
	/// People we care about listening to
	var/list/friends = list()
	/// Shown above the mob's head when it hears you
	var/command_feedback

/datum/component/pet_command/Initialize(list/speech_commands = list(), command_feedback)
	. = ..()
	if (!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	var/mob/living/living_parent = parent
	if (!living_parent.ai_controller)
		return COMPONENT_INCOMPATIBLE
	if (!length(speech_commands))
		CRASH("Didn't provide any instructions to listen to.")

	src.speech_commands = speech_commands
	src.command_feedback = command_feedback

/datum/component/pet_command/RegisterWithParent()
	RegisterSignal(parent, COMSIG_LIVING_TAMED, PROC_REF(new_friend))

/datum/component/pet_command/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_LIVING_TAMED))
	for (var/datum/weakref/weak_friend as anything in friends)
		var/mob/living/tamer = weak_friend.resolve()
		if (QDELETED(tamer))
			continue
		UnregisterSignal(tamer, COMSIG_MOB_SAY)
	return ..()

/// Register a new guy we want to listen to
/datum/component/pet_command/proc/new_friend(mob/living/source, mob/living/tamer)
	SIGNAL_HANDLER

	friends += WEAKREF(tamer)
	RegisterSignal(tamer, COMSIG_MOB_SAY, PROC_REF(listen_for_command))

/// Respond to something that one of our friends has asked us to do
/datum/component/pet_command/proc/listen_for_command(mob/living/speaker, speech_args)
	SIGNAL_HANDLER

	var/mob/living/living_parent = parent
	if (!living_parent.ai_controller) // We stopped having a brain at some point
		return
	if (IS_DEAD_OR_INCAP(living_parent)) // Probably can't hear them if we're dead
		return
	if(!can_see(living_parent, speaker)) // Basically the same rules as hearing
		return

	var/spoken_text = speech_args[SPEECH_MESSAGE]
	if (find_command_in_text(spoken_text))
		set_command_target(NONE)
		set_command_active(speaker)

/// Returns true if we find any of our spoken commands in the text
/datum/component/pet_command/proc/find_command_in_text(spoken_text)
	for (var/command as anything in speech_commands)
		if (!findtext(spoken_text, command))
			continue
		return TRUE
	return FALSE

/// Activate the command, extend to add visible messages and the like
/datum/component/pet_command/proc/set_command_active(mob/living/commander)
	var/mob/living/living_parent = parent
	living_parent.ai_controller.CancelActions() // Stop whatever you're doing and do this instead
	living_parent.ai_controller.blackboard[BB_ACTIVE_PET_COMMAND] = command_key
	if (command_feedback)
		living_parent.balloon_alert_to_viewers("[command_feedback]") // If we get a nicer runechat way to do this, refactor this

/// Store the target for the AI blackboard
/datum/component/pet_command/proc/set_command_target(atom/target)
	var/mob/living/living_parent = parent
	living_parent.ai_controller.blackboard[BB_CURRENT_PET_TARGET] = WEAKREF(target)

/**
 * # Point Targetting Pet Command
 * As above but also listens for you pointing at something and marks it as a target
 */
/datum/component/pet_command/point_targetting

/datum/component/pet_command/point_targetting/new_friend(mob/living/source, mob/living/tamer)
	. = ..()
	RegisterSignal(tamer, COMSIG_MOB_POINTED, PROC_REF(look_for_target))

/datum/component/pet_command/point_targetting/UnregisterFromParent()
	for (var/datum/weakref/weak_friend as anything in friends)
		var/mob/living/tamer = weak_friend.resolve()
		if (QDELETED(tamer))
			continue
		UnregisterSignal(tamer, COMSIG_MOB_POINTED)
	return ..()

/// Target the pointed atom for actions
/datum/component/pet_command/point_targetting/proc/look_for_target(mob/living/friend, atom/pointed_atom)
	var/mob/living/living_parent = parent
	if (!living_parent.ai_controller)
		return
	if (living_parent.ai_controller.blackboard[BB_ACTIVE_PET_COMMAND] != command_key) // We're not listening right now
		return
	if (IS_DEAD_OR_INCAP(living_parent))
		return
	if(!can_see(living_parent, pointed_atom))
		return

	living_parent.ai_controller.CancelActions()
	// Deciding if they can actually do anything with this is the behaviour's job
	set_command_target(pointed_atom)
