/**
 * # Pet Command
 * Set some AI blackboard commands in response to receiving instructions
 * This is abstract and should be extended for actual behaviour
 */
/datum/pet_command
	/// Weak reference to who follows this command
	var/datum/weakref/weak_parent
	/// Unique name used for radial selection, should not be shared with other commands on one mob
	var/command_name
	/// Description to display in radial menu
	var/command_desc
	/// If true, command will not appear in radial menu and can only be accessed through speech
	var/hidden = FALSE
	/// Icon to display in radial menu
	var/icon/radial_icon
	/// Icon state to display in radial menu
	var/radial_icon_state
	/// Speech strings to listen out for
	var/list/speech_commands = list()
	/// Callout that triggers this command
	var/callout_type
	/// Shown above the mob's head when it hears you
	var/command_feedback
	/// How close a mob needs to be to a target to respond to a command
	var/sense_radius = 7

/datum/pet_command/New(mob/living/parent)
	. = ..()
	weak_parent = WEAKREF(parent)

/// Register a new guy we want to listen to
/datum/pet_command/proc/add_new_friend(mob/living/tamer)
	RegisterSignal(tamer, COMSIG_MOB_SAY, PROC_REF(respond_to_command))
	RegisterSignal(tamer, COMSIG_MOB_AUTOMUTE_CHECK, PROC_REF(waive_automute))
	RegisterSignal(tamer, COMSIG_MOB_CREATED_CALLOUT, PROC_REF(respond_to_callout))

/// Stop listening to a guy
/datum/pet_command/proc/remove_friend(mob/living/unfriended)
	UnregisterSignal(unfriended, list(COMSIG_MOB_SAY, COMSIG_MOB_AUTOMUTE_CHECK, COMSIG_MOB_CREATED_CALLOUT))

/// Stop the automute from triggering for commands (unless the spoken text is suspiciously longer than the command)
/datum/pet_command/proc/waive_automute(mob/living/speaker, client/client, last_message, mute_type)
	SIGNAL_HANDLER
	if(mute_type == MUTE_IC && find_command_in_text(last_message, check_verbosity = TRUE))
		return WAIVE_AUTOMUTE_CHECK
	return NONE

/// Respond to something that one of our friends has asked us to do
/datum/pet_command/proc/respond_to_command(mob/living/speaker, speech_args)
	SIGNAL_HANDLER

	var/mob/living/parent = weak_parent.resolve()
	if (!parent)
		return
	if (!can_see(parent, speaker, sense_radius)) // Basically the same rules as hearing
		return

	var/spoken_text = speech_args[SPEECH_MESSAGE]
	if (!find_command_in_text(spoken_text))
		return

	try_activate_command(speaker)

/// Respond to a callout
/datum/pet_command/proc/respond_to_callout(mob/living/caller, datum/callout_option/callout, atom/target)
	SIGNAL_HANDLER

	if (isnull(callout_type) || !ispath(callout, callout_type))
		return

	var/mob/living/parent = weak_parent.resolve()
	if (!parent)
		return

	if (!valid_callout_target(caller, callout, target))
		var/found_new_target = FALSE
		for (var/atom/new_target in range(2, target))
			if (valid_callout_target(caller, callout, new_target))
				target = new_target
				found_new_target = TRUE

		if (!found_new_target)
			return

	if (try_activate_command(caller))
		look_for_target(parent, target)

/// Does this callout with this target trigger this command?
/datum/pet_command/proc/valid_callout_target(mob/living/caller, datum/callout_option/callout, atom/target)
	return TRUE

/**
 * Returns true if we find any of our spoken commands in the text.
 * if check_verbosity is true, skip the match if there spoken_text is way longer than the match
 */
/datum/pet_command/proc/find_command_in_text(spoken_text, check_verbosity = FALSE)
	for (var/command as anything in speech_commands)
		if (!findtext(spoken_text, command))
			continue
		if(check_verbosity && length(spoken_text) > length(command) + MAX_NAME_LEN)
			continue
		return TRUE
	return FALSE

/// Apply a command state if conditions are right, return command if successful
/datum/pet_command/proc/try_activate_command(mob/living/commander)
	var/mob/living/parent = weak_parent.resolve()
	if (!parent)
		return FALSE
	if (!parent.ai_controller) // We stopped having a brain at some point
		return FALSE
	if (IS_DEAD_OR_INCAP(parent)) // Probably can't hear them if we're dead
		return FALSE
	if (parent.ai_controller.blackboard[BB_ACTIVE_PET_COMMAND] == src) // We're already doing it
		return FALSE
	set_command_active(parent, commander)
	return TRUE

/// Target the pointed atom for actions
/datum/pet_command/proc/look_for_target(mob/living/friend, atom/pointed_atom)
	var/mob/living/parent = weak_parent.resolve()
	if (!parent)
		return FALSE
	if (!parent.ai_controller)
		return FALSE
	if (IS_DEAD_OR_INCAP(parent))
		return FALSE
	if (parent.ai_controller.blackboard[BB_ACTIVE_PET_COMMAND] != src) // We're not listening right now
		return FALSE
	if (parent.ai_controller.blackboard[BB_CURRENT_PET_TARGET] == pointed_atom) // That's already our target
		return FALSE
	if (!can_see(parent, pointed_atom, sense_radius))
		return FALSE

	parent.ai_controller.CancelActions()
	set_command_target(parent, pointed_atom)
	return TRUE

/// Activate the command, extend to add visible messages and the like
/datum/pet_command/proc/set_command_active(mob/living/parent, mob/living/commander)
	set_command_target(parent, null)

	parent.ai_controller.CancelActions() // Stop whatever you're doing and do this instead
	parent.ai_controller.set_blackboard_key(BB_ACTIVE_PET_COMMAND, src)
	if (command_feedback)
		parent.balloon_alert_to_viewers("[command_feedback]") // If we get a nicer runechat way to do this, refactor this

/// Store the target for the AI blackboard
/datum/pet_command/proc/set_command_target(mob/living/parent, atom/target)
	parent.ai_controller.set_blackboard_key(BB_CURRENT_PET_TARGET, target)
	return TRUE

/// Provide information about how to display this command in a radial menu
/datum/pet_command/proc/provide_radial_data()
	if (hidden)
		return
	var/datum/radial_menu_choice/choice = new()
	choice.name = command_name
	choice.image = icon(icon = radial_icon, icon_state = radial_icon_state)
	var/tooltip = command_desc
	if (length(speech_commands))
		tooltip += "<br>Speak this command with the words [speech_commands.Join(", ")]."
	choice.info = tooltip

	return list("[command_name]" = choice)

/**
 * Execute an AI action on the provided controller, what we should actually do when this command is active.
 * This should basically always be called from a planning subtree which passes its own controller.
 * Return SUBTREE_RETURN_FINISH_PLANNING to pass that instruction on to the controller, or don't if you don't want that.
 */
/datum/pet_command/proc/execute_action(datum/ai_controller/controller)
	SHOULD_CALL_PARENT(FALSE)
	CRASH("Pet command execute action not implemented.")

/**
 * # Point Targeting Pet Command
 * As above but also listens for you pointing at something and marks it as a target
 */
/datum/pet_command/point_targeting
	/// Text describing an action we perform upon receiving a new target
	var/pointed_reaction
	/// Blackboard key for targeting strategy, this is likely going to need it
	var/targeting_strategy_key = BB_PET_TARGETING_STRATEGY

/datum/pet_command/point_targeting/add_new_friend(mob/living/tamer)
	. = ..()
	RegisterSignal(tamer, COMSIG_MOB_POINTED, PROC_REF(on_point))

/datum/pet_command/point_targeting/remove_friend(mob/living/unfriended)
	. = ..()
	UnregisterSignal(unfriended, COMSIG_MOB_POINTED)

/// Target the pointed atom for actions
/datum/pet_command/point_targeting/proc/on_point(mob/living/friend, atom/pointed_atom)
	SIGNAL_HANDLER

	var/mob/living/parent = weak_parent.resolve()
	if (!parent)
		return FALSE

	parent.ai_controller.CancelActions()
	if (look_for_target(friend, pointed_atom) && set_command_target(parent, pointed_atom))
		parent.visible_message(span_warning("[parent] follows [friend]'s gesture towards [pointed_atom] [pointed_reaction]!"))
		return TRUE
	return FALSE
