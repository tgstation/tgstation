/**
 * # Obeys Commands Component
 * Manages a list of pet command datums, allowing you to boss it around
 * Creates a radial menu of pet commands when this creature is alt-clicked, if it has any
 */
/datum/component/obeys_commands
	/// List of commands you can give to the owner of this component
	var/list/available_commands = list()

/// The available_commands parameter should be passed as a list of typepaths
/datum/component/obeys_commands/Initialize(list/command_typepaths = list())
	. = ..()
	if (!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	var/mob/living/living_parent = parent
	if (!living_parent.ai_controller)
		return COMPONENT_INCOMPATIBLE
	if (!length(command_typepaths))
		CRASH("Initialised obedience component with no commands.")

	for (var/command_path in command_typepaths)
		var/datum/pet_command/new_command = new command_path(parent)
		available_commands[new_command.command_name] = new_command

/datum/component/obeys_commands/Destroy(force)
	. = ..()
	QDEL_NULL(available_commands)

/datum/component/obeys_commands/RegisterWithParent()
	RegisterSignal(parent, COMSIG_LIVING_BEFRIENDED, PROC_REF(add_friend))
	RegisterSignal(parent, COMSIG_LIVING_UNFRIENDED, PROC_REF(remove_friend))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_CLICK_ALT, PROC_REF(display_menu))

/datum/component/obeys_commands/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_LIVING_BEFRIENDED, COMSIG_LIVING_UNFRIENDED, COMSIG_ATOM_EXAMINE, COMSIG_CLICK_ALT))

/// Add someone to our friends list
/datum/component/obeys_commands/proc/add_friend(datum/source, mob/living/new_friend)
	SIGNAL_HANDLER

	for (var/command_name as anything in available_commands)
		var/datum/pet_command/command = available_commands[command_name]
		INVOKE_ASYNC(command, TYPE_PROC_REF(/datum/pet_command, add_new_friend), new_friend)

/// Remove someone from our friends list
/datum/component/obeys_commands/proc/remove_friend(datum/source, mob/living/old_friend)
	SIGNAL_HANDLER

	for (var/command_name as anything in available_commands)
		var/datum/pet_command/command = available_commands[command_name]
		INVOKE_ASYNC(command, TYPE_PROC_REF(/datum/pet_command, remove_friend), old_friend)

/// Add a note about whether they will follow the instructions of the inspecting mob
/datum/component/obeys_commands/proc/on_examine(mob/living/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	if (IS_DEAD_OR_INCAP(source))
		return
	if (!(user in source.ai_controller?.blackboard[BB_FRIENDS_LIST]))
		return
	examine_list += span_notice("[source.p_They()] seem[source.p_s()] happy to see you!")

/// Displays a radial menu of commands
/datum/component/obeys_commands/proc/display_menu(datum/source, mob/living/clicker)
	SIGNAL_HANDLER

	var/mob/living/living_parent = parent
	if (IS_DEAD_OR_INCAP(living_parent) || !clicker.can_perform_action(living_parent))
		return
	if (!(clicker in living_parent.ai_controller?.blackboard[BB_FRIENDS_LIST]))
		return // Not our friend, can't boss us around

	INVOKE_ASYNC(src, PROC_REF(display_radial_menu), clicker)
	return CLICK_ACTION_SUCCESS

/// Actually display the radial menu and then do something with the result
/datum/component/obeys_commands/proc/display_radial_menu(mob/living/clicker)
	var/list/radial_options = list()
	for (var/command_name as anything in available_commands)
		var/datum/pet_command/command = available_commands[command_name]
		var/datum/radial_menu_choice/choice = command.provide_radial_data()
		if (!choice)
			continue
		radial_options += choice

	var/pick = show_radial_menu(clicker, clicker, radial_options, tooltips = TRUE)
	if (!pick)
		return
	var/datum/pet_command/picked_command = available_commands[pick]
	picked_command.try_activate_command(clicker)
