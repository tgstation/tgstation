/**
 * # Obeys Commands Component
 * Manages a list of pet command datums, allowing you to boss it around
 * Creates a radial menu of pet commands when this creature is alt-clicked, if it has any
 */
#define DEFAULT_RADIAL_VIEWING_DISTANCE 9
/datum/component/obeys_commands
	/// List of commands you can give to the owner of this component
	var/list/available_commands = list()
	///Users currently viewing our radial options
	var/list/radial_viewers = list()
	///radius of our radial menu
	var/radial_menu_radius = 48
	///after how long we shutdown radial menus
	var/radial_menu_lifetime = 7 SECONDS
	///offset to display the radial menu
	var/list/radial_menu_offset
	///should the commands move with the pet owner's screen?
	var/radial_relative_to_user

/// The available_commands parameter should be passed as a list of typepaths
/datum/component/obeys_commands/Initialize(list/command_typepaths = list(), list/radial_menu_offset = list(0, 0), radial_menu_lifetime = 7 SECONDS, radial_relative_to_user = FALSE)
	. = ..()
	if (!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	var/mob/living/living_parent = parent
	if (!living_parent.ai_controller)
		return COMPONENT_INCOMPATIBLE
	if (!length(command_typepaths))
		CRASH("Initialised obedience component with no commands.")
	src.radial_menu_offset = radial_menu_offset
	src.radial_relative_to_user = radial_relative_to_user
	src.radial_menu_lifetime = radial_menu_lifetime
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

/datum/component/obeys_commands/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_LIVING_BEFRIENDED, COMSIG_LIVING_UNFRIENDED, COMSIG_ATOM_EXAMINE, COMSIG_CLICK_ALT))

/// Add someone to our friends list
/datum/component/obeys_commands/proc/add_friend(datum/source, mob/living/new_friend)
	SIGNAL_HANDLER
	RegisterSignal(new_friend, COMSIG_KB_LIVING_VIEW_PET_COMMANDS, PROC_REF(on_key_pressed))
	RegisterSignal(new_friend, DEACTIVATE_KEYBIND(COMSIG_KB_LIVING_VIEW_PET_COMMANDS), PROC_REF(on_key_unpressed))
	for (var/command_name as anything in available_commands)
		var/datum/pet_command/command = available_commands[command_name]
		INVOKE_ASYNC(command, TYPE_PROC_REF(/datum/pet_command, add_new_friend), new_friend)

/datum/component/obeys_commands/proc/on_key_unpressed(mob/living/source)
	SIGNAL_HANDLER
	UnregisterSignal(source, COMSIG_ATOM_MOUSE_ENTERED)

/datum/component/obeys_commands/proc/remove_from_viewers(mob/living/source)
	radial_viewers -= REF(source)

/// Remove someone from our friends list
/datum/component/obeys_commands/proc/remove_friend(datum/source, mob/living/old_friend)
	SIGNAL_HANDLER
	UnregisterSignal(old_friend, list(
		COMSIG_KB_LIVING_VIEW_PET_COMMANDS,
		DEACTIVATE_KEYBIND(COMSIG_KB_LIVING_VIEW_PET_COMMANDS),
	))
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

/datum/component/obeys_commands/proc/on_key_pressed(mob/living/friend)
	SIGNAL_HANDLER
	RegisterSignal(friend, COMSIG_ATOM_MOUSE_ENTERED, PROC_REF(on_mouse_hover))

/datum/component/obeys_commands/proc/on_mouse_hover(mob/living/friend, atom/mouse_hovered)
	SIGNAL_HANDLER
	if(mouse_hovered == parent)
		display_menu(friend)
		return
	if(isliving(mouse_hovered))
		remove_from_viewers(friend)

/// Displays a radial menu of commands
/datum/component/obeys_commands/proc/display_menu(mob/living/friend)

	var/mob/living/living_parent = parent
	if (IS_DEAD_OR_INCAP(living_parent) || friend.stat != CONSCIOUS)
		return
	if (!(friend in living_parent.ai_controller?.blackboard[BB_FRIENDS_LIST]))
		return // Not our friend, can't boss us around
	if(radial_viewers[REF(friend)])
		return
	if(!can_see(friend, parent, DEFAULT_RADIAL_VIEWING_DISTANCE))
		return
	INVOKE_ASYNC(src, PROC_REF(display_radial_menu), friend)

/// Actually display the radial menu and then do something with the result
/datum/component/obeys_commands/proc/display_radial_menu(mob/living/friend)
	var/list/radial_options = list()
	for (var/command_name as anything in available_commands)
		var/datum/pet_command/command = available_commands[command_name]
		var/datum/radial_menu_choice/choice = command.provide_radial_data()
		if (!choice)
			continue
		radial_options += choice
	radial_viewers[REF(friend)] = world.time + radial_menu_lifetime
	var/pick = show_radial_menu(friend, parent, radial_options, radius = radial_menu_radius, button_animation_flags = BUTTON_FADE_IN | BUTTON_FADE_OUT, custom_check = CALLBACK(src, PROC_REF(check_menu_viewer), friend), check_delay = 0.15 SECONDS, display_close_button = FALSE, radial_menu_offset = radial_menu_offset, user_space = radial_relative_to_user)
	remove_from_viewers(friend)
	if(!pick)
		return
	var/datum/pet_command/picked_command = available_commands[pick]
	picked_command.try_activate_command(friend, radial_command = TRUE)

/datum/component/obeys_commands/proc/check_menu_viewer(mob/living/user)
	if(QDELETED(user) || !radial_viewers[REF(user)])
		return FALSE
	if(world.time > radial_viewers[REF(user)])
		return FALSE
	var/viewing_distance = DEFAULT_RADIAL_VIEWING_DISTANCE
	if(!can_see(user, parent, viewing_distance))
		return FALSE
	return TRUE

#undef DEFAULT_RADIAL_VIEWING_DISTANCE
