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
	///The last atom each friend pointed at, consumed by their next command
	var/list/pointed_targets = list()
	///Friend who gave the active command, if it came from a player
	var/datum/weakref/active_commander
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
	var/mob/living/living_parent = parent
	if(living_parent.ai_controller)
		end_active_command()
		for(var/mob/living/friend as anything in living_parent.ai_controller.blackboard[BB_FRIENDS_LIST])
			UnregisterSignal(friend, list(
				COMSIG_KB_LIVING_VIEW_PET_COMMANDS,
				DEACTIVATE_KEYBIND(COMSIG_KB_LIVING_VIEW_PET_COMMANDS),
				COMSIG_MOVABLE_POINTED,
				COMSIG_MOB_SAY,
				COMSIG_MOB_CREATED_CALLOUT,
			))
			for(var/command_name in available_commands)
				var/datum/pet_command/command = available_commands[command_name]
				command.remove_friend(friend)
	QDEL_LIST_ASSOC_VAL(available_commands)
	return ..()

/datum/component/obeys_commands/RegisterWithParent()
	RegisterSignal(parent, COMSIG_LIVING_BEFRIENDED, PROC_REF(add_friend))
	RegisterSignal(parent, COMSIG_LIVING_UNFRIENDED, PROC_REF(remove_friend))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_LIVING_PET_COMMAND_STARTING, PROC_REF(on_command_starting))
	RegisterSignal(parent, COMSIG_LIVING_PET_COMMAND_FINISHED, PROC_REF(on_command_finished))
	RegisterSignal(parent, COMSIG_LIVING_PET_COMMAND_RADIAL_SELECTED, PROC_REF(on_radial_command_selected))

/datum/component/obeys_commands/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_LIVING_BEFRIENDED,
		COMSIG_LIVING_UNFRIENDED,
		COMSIG_ATOM_EXAMINE,
		COMSIG_CLICK_ALT,
		COMSIG_LIVING_PET_COMMAND_STARTING,
		COMSIG_LIVING_PET_COMMAND_FINISHED,
		COMSIG_LIVING_PET_COMMAND_RADIAL_SELECTED,
	))

/// Add someone to our friends list
/datum/component/obeys_commands/proc/add_friend(datum/source, mob/living/new_friend)
	SIGNAL_HANDLER
	RegisterSignal(new_friend, COMSIG_KB_LIVING_VIEW_PET_COMMANDS, PROC_REF(on_key_pressed))
	RegisterSignal(new_friend, DEACTIVATE_KEYBIND(COMSIG_KB_LIVING_VIEW_PET_COMMANDS), PROC_REF(on_key_unpressed))
	RegisterSignal(new_friend, COMSIG_MOVABLE_POINTED, PROC_REF(on_friend_pointed))
	RegisterSignal(new_friend, COMSIG_MOB_SAY, PROC_REF(on_friend_say))
	RegisterSignal(new_friend, COMSIG_MOB_CREATED_CALLOUT, PROC_REF(on_friend_callout))
	for (var/command_name in available_commands)
		var/datum/pet_command/command = available_commands[command_name]
		INVOKE_ASYNC(command, TYPE_PROC_REF(/datum/pet_command, add_new_friend), new_friend)

/datum/component/obeys_commands/proc/on_key_unpressed(mob/living/source)
	SIGNAL_HANDLER
	UnregisterSignal(source, COMSIG_ATOM_MOUSE_ENTERED)
	remove_from_viewers(source)

/datum/component/obeys_commands/proc/remove_from_viewers(mob/living/source)
	radial_viewers -= REF(source)

/// Remove someone from our friends list
/datum/component/obeys_commands/proc/remove_friend(datum/source, mob/living/old_friend)
	SIGNAL_HANDLER
	UnregisterSignal(old_friend, list(
		COMSIG_KB_LIVING_VIEW_PET_COMMANDS,
		DEACTIVATE_KEYBIND(COMSIG_KB_LIVING_VIEW_PET_COMMANDS),
		COMSIG_MOVABLE_POINTED,
		COMSIG_MOB_SAY,
		COMSIG_MOB_CREATED_CALLOUT,
	))
	pointed_targets -= REF(old_friend)
	if(active_commander?.resolve() == old_friend)
		end_active_command()
	for (var/command_name in available_commands)
		var/datum/pet_command/command = available_commands[command_name]
		INVOKE_ASYNC(command, TYPE_PROC_REF(/datum/pet_command, remove_friend), old_friend)

/// Select the first available command matching a friend's speech
/datum/component/obeys_commands/proc/on_friend_say(mob/living/friend, speech_args)
	SIGNAL_HANDLER
	var/mob/living/living_parent = parent
	var/spoken_text = speech_args[SPEECH_MESSAGE]
	for(var/command_name in available_commands)
		var/datum/pet_command/command = available_commands[command_name]
		if(!command.find_command_in_text(spoken_text))
			continue
		if(!can_see(living_parent, friend, command.sense_radius))
			continue
		var/datum/weakref/pointed_target = consume_pointed_target(friend)
		command.respond_to_command(friend, speech_args, pointed_target, !isnull(pointed_target))
		return

/// send a callout to the first command registered for that callout type.
/datum/component/obeys_commands/proc/on_friend_callout(mob/living/friend, datum/callout_option/callout, atom/target)
	SIGNAL_HANDLER
	for(var/command_name in available_commands)
		var/datum/pet_command/command = available_commands[command_name]
		if(isnull(command.callout_type) || !ispath(callout, command.callout_type))
			continue
		var/datum/weakref/pointed_target = consume_pointed_target(friend)
		command.respond_to_callout(friend, callout, target, pointed_target, !isnull(pointed_target))
		return

/// Replace command state when a pet command datum announces activation.
/datum/component/obeys_commands/proc/on_command_starting(mob/living/source, datum/pet_command/command, mob/living/commander)
	SIGNAL_HANDLER
	end_active_command()
	active_commander = commander ? WEAKREF(commander) : null
	return COMPONENT_PET_COMMAND_HANDLED

/// Clear command state when its behavior tree or action reports completion.
/datum/component/obeys_commands/proc/on_command_finished(mob/living/source, datum/pet_command/finished_command)
	SIGNAL_HANDLER
	var/mob/living/living_parent = parent
	if(living_parent.ai_controller.blackboard[BB_ACTIVE_PET_COMMAND] == finished_command)
		end_active_command()
	return COMPONENT_PET_COMMAND_HANDLED

/// Apply a radial selection through the same target consumption
/datum/component/obeys_commands/proc/on_radial_command_selected(mob/living/source, mob/living/friend, datum/pet_command/selected_command)
	SIGNAL_HANDLER
	if(QDELETED(selected_command) || available_commands[selected_command.command_name] != selected_command)
		return COMPONENT_PET_COMMAND_HANDLED
	var/datum/weakref/pointed_target = consume_pointed_target(friend)
	selected_command.try_activate_command(friend, radial_command = TRUE, command_point = pointed_target, has_command_point = !isnull(pointed_target))
	return COMPONENT_PET_COMMAND_HANDLED

/// Remember points when no target command is active; otherwise send each point exclusively to that command.
/datum/component/obeys_commands/proc/on_friend_pointed(mob/living/friend, atom/pointed_atom)
	SIGNAL_HANDLER
	var/mob/living/living_parent = parent
	var/datum/pet_command/active_command = living_parent.ai_controller.blackboard[BB_ACTIVE_PET_COMMAND]
	if(active_command?.requires_pointing)
		active_command.on_target_set(friend, pointed_atom)
		return
	pointed_targets[REF(friend)] = WEAKREF(pointed_atom)

/// Remove and return one friend's pending point. A non-null weakref means a point was made, even if its target was deleted.
/datum/component/obeys_commands/proc/consume_pointed_target(mob/living/friend)
	var/datum/weakref/pointed_target = pointed_targets[REF(friend)]
	pointed_targets -= REF(friend)
	return pointed_target

/// Clear the active command through its cleanup hook, including target and behavior-tree state.
/datum/component/obeys_commands/proc/end_active_command()
	var/mob/living/living_parent = parent
	var/datum/ai_controller/controller = living_parent.ai_controller
	var/datum/pet_command/active_command = controller.blackboard[BB_ACTIVE_PET_COMMAND]
	if(active_command)
		active_command.command_ended(controller)
	else
		controller.set_behavior_tree_override(SUBPLAN_ID_PET_COMMAND, null)
	controller.clear_pet_command_blackboard()
	active_commander = null

/// Add a note about whether they will follow the instructions of the inspecting mob
/datum/component/obeys_commands/proc/on_examine(mob/living/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	if (source.incapacitated)
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

	var/mob/living/owner = parent
	if(isliving(mouse_hovered) && mouse_hovered.loc != owner.loc)
		remove_from_viewers(friend)

/// Displays a radial menu of commands
/datum/component/obeys_commands/proc/display_menu(mob/living/friend)

	var/mob/living/living_parent = parent
	if (living_parent.incapacitated || IS_UNCONSCIOUS_OR_CRIT(friend))
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
	for (var/command_name in available_commands)
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
	SEND_SIGNAL(parent, COMSIG_LIVING_PET_COMMAND_RADIAL_SELECTED, friend, picked_command)

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
