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

/// Stop listening to a guy
/datum/pet_command/proc/remove_friend(mob/living/unfriended)
	UnregisterSignal(unfriended, COMSIG_MOB_SAY)

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

/// Returns true if we find any of our spoken commands in the text
/datum/pet_command/proc/find_command_in_text(spoken_text)
	for (var/command as anything in speech_commands)
		if (!findtext(spoken_text, command))
			continue
		return TRUE
	return FALSE

/// Apply a command state if conditions are right, return command if successful
/datum/pet_command/proc/try_activate_command(mob/living/commander)
	var/mob/living/parent = weak_parent.resolve()
	if (!parent)
		return
	if (!parent.ai_controller) // We stopped having a brain at some point
		return
	if (IS_DEAD_OR_INCAP(parent)) // Probably can't hear them if we're dead
		return
	if (parent.ai_controller.blackboard[BB_ACTIVE_PET_COMMAND] == src) // We're already doing it
		return
	set_command_active(parent, commander)

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
 * # Point Targetting Pet Command
 * As above but also listens for you pointing at something and marks it as a target
 */
/datum/pet_command/point_targetting
	/// Text describing an action we perform upon receiving a new target
	var/pointed_reaction
	/// Blackboard key for targetting datum, this is likely going to need it
	var/targetting_datum_key = BB_PET_TARGETTING_DATUM

/datum/pet_command/point_targetting/add_new_friend(mob/living/tamer)
	. = ..()
	RegisterSignal(tamer, COMSIG_MOB_POINTED, PROC_REF(look_for_target))

/datum/pet_command/point_targetting/remove_friend(mob/living/unfriended)
	. = ..()
	UnregisterSignal(unfriended, COMSIG_MOB_POINTED)

/// Target the pointed atom for actions
/datum/pet_command/point_targetting/proc/look_for_target(mob/living/friend, atom/pointed_atom)
	SIGNAL_HANDLER

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
	// Deciding if they can actually do anything with this target is the behaviour's job
	set_command_target(parent, pointed_atom)
	// These are usually hostile actions so should have a record in chat
	parent.visible_message(span_warning("[parent] follows [friend]'s gesture towards [pointed_atom] [pointed_reaction]!"))
	return TRUE
