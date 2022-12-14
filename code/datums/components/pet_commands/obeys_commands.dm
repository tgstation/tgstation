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

/datum/component/obeys_commands/Destroy(force, silent)
	. = ..()
	QDEL_NULL(available_commands)

/datum/component/obeys_commands/RegisterWithParent()
	RegisterSignal(parent, COMSIG_LIVING_BEFRIENDED, PROC_REF(add_friend))
	RegisterSignal(parent, COMSIG_CLICK_ALT, PROC_REF(display_menu))

/datum/component/obeys_commands/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_LIVING_BEFRIENDED, COMSIG_CLICK_ALT))

/datum/component/obeys_commands/proc/add_friend(datum/source, mob/living/new_friend)
	SIGNAL_HANDLER

	for (var/command_name as anything in available_commands)
		var/datum/pet_command/command = available_commands[command_name]
		INVOKE_ASYNC(command, TYPE_PROC_REF(/datum/pet_command, add_new_friend), new_friend)


/// Displays a radial menu of commands
/datum/component/obeys_commands/proc/display_menu(datum/source, mob/living/clicker)
	SIGNAL_HANDLER

	var/mob/living/living_parent = parent
	if (IS_DEAD_OR_INCAP(living_parent))
		return
	if (!living_parent.ai_controller)
		return
	var/list/friends_list = living_parent.ai_controller.blackboard[BB_FRIENDS_LIST]
	if (!friends_list || !friends_list[WEAKREF(clicker)])
		return // Not our friend, can't boss us around

	INVOKE_ASYNC(src, PROC_REF(display_radial_menu), clicker)

/// Actually display the radial menu and then do something with the result
/datum/component/obeys_commands/proc/display_radial_menu(mob/living/clicker)
	var/list/radial_options = list()
	for (var/command_name as anything in available_commands)
		var/datum/pet_command/command = available_commands[command_name]
		radial_options += command.provide_radial_data()

	var/pick = show_radial_menu(clicker, clicker, radial_options, require_near = TRUE, tooltips = TRUE)
	if (!pick)
		return
	var/datum/pet_command/picked_command = available_commands[pick]
	picked_command.try_activate_command(clicker)
