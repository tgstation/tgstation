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
	var/icon/radial_icon = 'icons/hud/radial_pets.dmi'
	/// Icon state to display in radial menu
	var/radial_icon_state
	/// Speech strings to listen out for
	var/list/speech_commands = list()
	/// Callout that triggers this command
	var/callout_type
	/// How close a mob needs to be to a target to respond to a command
	var/sense_radius = 7
	/// does this pet command need a point to activate?
	var/requires_pointing = FALSE
	/// Blackboard key for targeting strategy, this is likely going to need it
	var/targeting_strategy_key = BB_PET_TARGETING_STRATEGY
	/// Friend currently selecting a target through this command's radial menu
	var/datum/weakref/radial_commander
	/// Mouse pointer in use before the radial target prompt
	var/old_mouse_override_icon

/datum/pet_command/New(mob/living/parent)
	. = ..()
	weak_parent = WEAKREF(parent)

/// Clear blackboard state shared by pet commands.
/datum/ai_controller/proc/clear_pet_command_blackboard()
	clear_blackboard_key(BB_ACTIVE_PET_COMMAND)
	clear_blackboard_key(BB_CURRENT_PET_TARGET)
	clear_blackboard_key(BB_FETCH_DELIVER_TO)
	clear_blackboard_key(BB_PET_ACTIVE_ABILITY)

/// Register a new guy we want to listen to
/datum/pet_command/proc/add_new_friend(mob/living/tamer)
	return

/// Stop listening to a guy
/datum/pet_command/proc/remove_friend(mob/living/unfriended)
	if(radial_commander?.resolve() == unfriended)
		clear_radial_selection()

/// Respond to something that one of our friends has asked us to do
/datum/pet_command/proc/respond_to_command(mob/living/speaker, speech_args, datum/weakref/command_point, has_command_point = FALSE)
	SIGNAL_HANDLER
	var/mob/living/parent = weak_parent.resolve()
	if (!parent)
		return
	if (!can_see(parent, speaker, sense_radius)) // Basically the same rules as hearing
		return

	var/spoken_text = speech_args[SPEECH_MESSAGE]
	if (!find_command_in_text(spoken_text))
		return
	try_activate_command(commander = speaker, radial_command = FALSE, command_point = command_point, has_command_point = has_command_point)

/// Respond to a callout
/datum/pet_command/proc/respond_to_callout(mob/living/speaker, datum/callout_option/callout, atom/target, datum/weakref/command_point, has_command_point = FALSE)
	SIGNAL_HANDLER

	if (isnull(callout_type) || !ispath(callout, callout_type))
		return

	var/mob/living/parent = weak_parent.resolve()
	if (!parent)
		return

	if (!valid_callout_target(speaker, callout, target))
		var/found_new_target = FALSE
		for (var/atom/new_target in range(2, target))
			if (valid_callout_target(speaker, callout, new_target))
				target = new_target
				found_new_target = TRUE

		if (!found_new_target)
			return

	try_activate_command(commander = speaker, radial_command = FALSE, command_point = command_point, has_command_point = has_command_point, initial_target = target)

/// Does this callout with this target trigger this command?
/datum/pet_command/proc/valid_callout_target(mob/living/speaker, datum/callout_option/callout, atom/target)
	return TRUE

/**
 * Returns true if we find any of our spoken commands in the text.
 * if check_verbosity is true, skip the match if there spoken_text is way longer than the match
 */
/datum/pet_command/proc/find_command_in_text(spoken_text, check_verbosity = FALSE)
	for (var/command in speech_commands)
		if (!findtext(spoken_text, command))
			continue
		if(check_verbosity && length(spoken_text) > length(command) + MAX_NAME_LEN)
			continue
		return TRUE
	return FALSE

/datum/pet_command/proc/pet_able_to_respond()
	var/mob/living/parent = weak_parent.resolve()
	if(isnull(parent) || isnull(parent.ai_controller))
		return FALSE
	if(parent.incapacitated) // Probably can't hear them if we're dead
		return FALSE
	return TRUE

/// Apply a command state if conditions are right, return command if successful
/datum/pet_command/proc/try_activate_command(mob/living/commander, radial_command, datum/weakref/command_point, has_command_point = FALSE, explicit_command = TRUE, atom/initial_target)
	if(!pet_able_to_respond())
		return FALSE
	var/mob/living/parent = weak_parent.resolve()
	set_command_active(parent, commander, radial_command, command_point, has_command_point, explicit_command, initial_target)
	return TRUE

/datum/pet_command/proc/generate_emote_command(atom/target)
	var/mob/living/living_pet = weak_parent?.resolve()
	return isnull(living_pet) ? null : retrieve_command_text(living_pet, target)

/datum/pet_command/proc/retrieve_command_text(atom/living_pet, atom/target)
	return "signals [living_pet] to spring into action!"

/// Target the pointed atom for actions
/datum/pet_command/proc/look_for_target(mob/living/friend, atom/potential_target)
	var/mob/living/parent = weak_parent.resolve()
	if(!pet_able_to_respond() || QDELETED(potential_target))
		return FALSE
	if (parent.ai_controller.blackboard[BB_CURRENT_PET_TARGET] == potential_target) // That's already our target
		return TRUE
	if (!can_see(parent, potential_target, sense_radius))
		return FALSE
	return set_command_target(parent, potential_target)

/// Activate the command, extend to add visible messages and the like
/datum/pet_command/proc/set_command_active(mob/living/parent, mob/living/commander, radial_command = FALSE, datum/weakref/command_point, has_command_point = FALSE, explicit_command = TRUE, atom/initial_target)
	var/datum/ai_controller/controller = parent.ai_controller
	var/signal_result = SEND_SIGNAL(parent, COMSIG_LIVING_PET_COMMAND_STARTING, src, commander)
	if(!(signal_result & COMPONENT_PET_COMMAND_HANDLED))
		var/datum/pet_command/previous = controller.blackboard[BB_ACTIVE_PET_COMMAND]
		if(previous)
			previous.command_ended(controller)
		else
			controller.set_behavior_tree_override(SUBPLAN_ID_PET_COMMAND, null)
		controller.clear_pet_command_blackboard()
	controller.set_blackboard_key(BB_ACTIVE_PET_COMMAND, src)

	var/atom/target_to_set
	var/has_target_to_set = FALSE
	if(requires_pointing && has_command_point)
		has_target_to_set = TRUE
		target_to_set = command_point?.resolve()
	else if(!isnull(initial_target))
		has_target_to_set = TRUE
		target_to_set = initial_target
	var/target_accepted = FALSE
	if(has_target_to_set)
		if(isnull(target_to_set) || QDELETED(target_to_set))
			refuse_target(parent, target_to_set)
		else
			target_accepted = on_target_set(commander, target_to_set)

	execute_action(controller) // Install the BT override subtree after applying any remembered target.

	if(explicit_command)
		if(!(has_target_to_set && !target_accepted) && requires_pointing && !target_accepted)
			emit_command_feedback(parent, PET_COMMAND_FEEDBACK_WAITING_FOR_TARGET, commander)
		else if(!has_target_to_set || target_accepted)
			emit_command_feedback(parent, PET_COMMAND_FEEDBACK_ACTIVATED, commander, explicit_command = TRUE)
	else
		emit_command_feedback(parent, PET_COMMAND_FEEDBACK_ACTIVATED, commander)

	if(!radial_command || !commander)
		return
	if(!requires_pointing)
		var/manual_emote_text = generate_emote_command()
		if(manual_emote_text)
			commander.manual_emote(manual_emote_text)
		return
	if(target_accepted)
		var/target_emote_text = generate_emote_command(target_to_set)
		if(target_emote_text)
			commander.manual_emote(target_emote_text)
		return
	radial_commander = WEAKREF(commander)
	old_mouse_override_icon = commander.client?.mouse_override_icon
	RegisterSignal(commander, COMSIG_MOB_CLICKON, PROC_REF(click_on_target))
	commander.client?.mouse_override_icon = 'icons/effects/mouse_pointers/pet_paw.dmi'
	commander.update_mouse_pointer()


/// Called when this command is replaced by another command or otherwise deactivated. Extend to add cleanup logic.
/datum/pet_command/proc/command_ended(datum/ai_controller/controller)
	controller.set_behavior_tree_override(SUBPLAN_ID_PET_COMMAND, null)
	controller.clear_blackboard_key(BB_CURRENT_PET_TARGET)
	clear_radial_selection()
	return

/// Report that an immediate command action has completed to the pet's command component.
/datum/pet_command/proc/finish_command(datum/ai_controller/controller)
	var/mob/living/parent = weak_parent.resolve()
	var/signal_result = SEND_SIGNAL(parent, COMSIG_LIVING_PET_COMMAND_FINISHED, src)
	if(signal_result & COMPONENT_PET_COMMAND_HANDLED)
		return TRUE
	command_ended(controller)
	controller.clear_pet_command_blackboard()
	return FALSE

/datum/pet_command/proc/clear_radial_selection()
	if(radial_commander)
		var/mob/living/commander = radial_commander.resolve()
		if(commander)
			UnregisterSignal(commander, COMSIG_MOB_CLICKON)
			commander.client?.mouse_override_icon = old_mouse_override_icon
			commander.update_mouse_pointer()
		radial_commander = null
		old_mouse_override_icon = null

/datum/pet_command/proc/click_on_target(mob/living/source, atom/target, list/modifiers)
	SIGNAL_HANDLER
	var/manual_emote_text = generate_emote_command(target)
	if(on_target_set(source, target) && !isnull(manual_emote_text))
		INVOKE_ASYNC(source, TYPE_PROC_REF(/atom, manual_emote), manual_emote_text)
	clear_radial_selection()
	return COMSIG_MOB_CANCEL_CLICKON

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
	return list("[command_name]" = choice)

/**
 * Execute an AI action on the provided controller, what we should actually do when this command is active.
 * This should basically always be called from a planning subtree which passes its own controller.
 * Return SUBTREE_RETURN_FINISH_PLANNING to pass that instruction on to the controller, or don't if you don't want that.
 */
/datum/pet_command/proc/execute_action(datum/ai_controller/controller)
	SHOULD_CALL_PARENT(FALSE)
	CRASH("Pet command execute action not implemented.")

/// Target the pointed atom for actions
/datum/pet_command/proc/on_target_set(mob/living/friend, atom/potential_target)
	var/mob/living/parent = weak_parent.resolve()
	if (!parent || isnull(potential_target))
		return FALSE
	if(!look_for_target(friend, potential_target))
		refuse_target(parent, potential_target)
		return FALSE
	parent.ai_controller.cancel_current_plan()
	emit_command_feedback(parent, PET_COMMAND_FEEDBACK_ACCEPTED_TARGET, friend, potential_target)
	return TRUE

/// Show a short balloon when a command rejects a supplied target.
/datum/pet_command/proc/refuse_target(mob/living/parent, atom/target)
	emit_command_feedback(parent, PET_COMMAND_FEEDBACK_REFUSED_TARGET, target = target)

/datum/pet_command/proc/get_feedback_message(mob/living/parent, feedback_type, mob/living/commander = null, atom/target = null, explicit_command = FALSE)
	switch(feedback_type)
		if(PET_COMMAND_FEEDBACK_ACTIVATED)
			return explicit_command ? "[parent] acknowledges" : null
		if(PET_COMMAND_FEEDBACK_WAITING_FOR_TARGET)
			return "[parent] waits for a target"
		if(PET_COMMAND_FEEDBACK_REFUSED_TARGET)
			return target ? "[parent] looks at [target] in confusion" : "[parent] looks confused"
		if(PET_COMMAND_FEEDBACK_ACCEPTED_TARGET)
			return null
		if(PET_COMMAND_FEEDBACK_MISSING_HIVE)
			return "[parent] can't find [parent.p_their()] hive"
		if(PET_COMMAND_FEEDBACK_UNAVAILABLE)
			return "[parent] can't do that"
		if(PET_COMMAND_FEEDBACK_NO_WALLS)
			return "[parent] sees no walls"
		if(PET_COMMAND_FEEDBACK_CANNOT_REPRODUCE)
			return "[parent] can't reproduce"

/datum/pet_command/proc/emit_command_feedback(mob/living/parent, feedback_type, mob/living/commander = null, atom/target = null, explicit_command = FALSE)
	var/message = get_feedback_message(parent, feedback_type, commander, target, explicit_command)
	if(isnull(message))
		return
	if(feedback_type == PET_COMMAND_FEEDBACK_ACCEPTED_TARGET)
		parent.visible_message(span_warning(message))
	else
		parent.balloon_alert_to_viewers(message)
