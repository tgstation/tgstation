/**
 * # Pet Commands Menu
 * Creates a radial menu of pet commands when this creature is alt-clicked, if it has any
 */
/datum/component/pet_commands_menu

/datum/component/pet_commands_menu/Initialize()
	. = ..()
	if (!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	var/mob/living/living_parent = parent
	if (!living_parent.ai_controller)
		return COMPONENT_INCOMPATIBLE

/datum/component/pet_commands_menu/RegisterWithParent()
	RegisterSignal(parent, COMSIG_CLICK_ALT, PROC_REF(display_menu))

/datum/component/pet_commands_menu/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_CLICK_ALT)

/// Displays a radial menu of commands
/datum/component/pet_commands_menu/proc/display_menu(datum/source, mob/living/clicker)
	SIGNAL_HANDLER

	var/mob/living/living_parent = parent
	if (IS_DEAD_OR_INCAP(living_parent))
		return
	if (!living_parent.ai_controller)
		return
	var/list/friends_list = living_parent.ai_controller.blackboard[BB_PET_FRIENDS_LIST]
	if (!friends_list || !friends_list[WEAKREF(clicker)])
		return // Not our friend, can't boss us around

	var/list/radial_options = list()
	SEND_SIGNAL(parent, COMSIG_REQUESTING_PET_COMMAND_RADIAL, radial_options)
	if (!length(radial_options))
		return // Didn't get any command information, maybe you forgot to give them any?
	INVOKE_ASYNC(src, PROC_REF(display_radial_menu), clicker, radial_options)

/// Actually display the radial menu and then do something with the result
/datum/component/pet_commands_menu/proc/display_radial_menu(mob/living/clicker, list/radial_options)
	var/pick = show_radial_menu(clicker, clicker, radial_options, require_near = TRUE, tooltips = TRUE)
	if (!pick)
		return
	SEND_SIGNAL(parent, COMSIG_RADIAL_PET_COMMAND_SELECTED, pick, clicker)
