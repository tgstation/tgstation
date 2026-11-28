/datum/keybinding/robot
	category = CATEGORY_ROBOT
	weight = WEIGHT_ROBOT

/datum/keybinding/robot/can_use(client/user)
	return iscyborg(user.mob)

/datum/keybinding/robot/select_module
	var/module_index = NONE

/datum/keybinding/robot/select_module/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return
	var/mob/living/silicon/robot/borgie = user.mob
	borgie.swap_hand(module_index)
	return TRUE

/datum/keybinding/robot/select_module/one
	hotkey_keys = list("1")
	name = "module_one"
	full_name = "Toggle module 1"
	keybind_signal = COMSIG_KB_SILICON_TOGGLEMODULEONE_DOWN
	module_index = 1

/datum/keybinding/robot/select_module/two
	hotkey_keys = list("2")
	name = "module_two"
	full_name = "Toggle module 2"
	keybind_signal = COMSIG_KB_SILICON_TOGGLEMODULETWO_DOWN
	module_index = 2

/datum/keybinding/robot/select_module/three
	hotkey_keys = list("3")
	name = "module_three"
	full_name = "Toggle module 3"
	keybind_signal = COMSIG_KB_SILICON_TOGGLEMODULETHREE_DOWN
	module_index = 3

/datum/keybinding/robot/undeploy
	category = CATEGORY_AI
	hotkey_keys = list("=")
	name = "undeploy"
	full_name = "Disconnect from shell"
	description = "Returns you to your AI core"
	keybind_signal = COMSIG_KB_SILION_UNDEPLOY_DOWN

/datum/keybinding/robot/undeploy/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return
	var/mob/living/silicon/robot/shell/our_shell = user.mob
	//We make sure our shell is actually a shell
	if(our_shell.shell == FALSE)
		return
	our_shell.undeploy()
	return TRUE
