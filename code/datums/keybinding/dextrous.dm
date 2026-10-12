/**
 * Dextrous just refers to anything that uses hands,
 * which is generally carbons but can also be silicons and some basics.
 */
/datum/keybinding/dextrous
	category = CATEGORY_DEXTROUS
	weight = WEIGHT_MOB

/datum/keybinding/dextrous/swap_hands
	var/dir
	var/climb = FALSE

/datum/keybinding/dextrous/swap_hands/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return
	var/mob/user_mob = user.mob
	user_mob.cycle_hand(dir, climb)
	return TRUE

/datum/keybinding/dextrous/swap_hands/row
	hotkey_keys = list("X")
	name = "swap_hands_row"
	full_name = "Swap Hands (Horizontal)"
	description = "Switch between the hands on the currently selected row (left/right)"
	keybind_signal = COMSIG_KB_MOB_SWAPHANDSROW_DOWN

	dir = WEST

/datum/keybinding/dextrous/swap_hands/column
	hotkey_keys = list("ShiftX")
	name = "swap_hands_column"
	full_name = "Swap Hands (Vertical)"
	description = "Switch between the hands on the currently selected column (up/down)"
	keybind_signal = COMSIG_KB_MOB_SWAPHANDSCOLUMN_DOWN

	dir = NORTH

/datum/keybinding/dextrous/swap_hands/cycle
	hotkey_keys = list(UNBOUND_KEY)
	name = "swap_hands_cycle"
	full_name = "Cycle Hands"
	description = "Cycles through all hands (right to left, bottom to top)"
	keybind_signal = COMSIG_KB_MOB_SWAPHANDSCYCLE_DOWN

	dir = WEST
	climb = TRUE

/datum/keybinding/dextrous/select_hand
	var/hand_index = NONE

/datum/keybinding/dextrous/select_hand/right
	hotkey_keys = list(UNBOUND_KEY)
	name = "select_right_hand"
	full_name = "Swap to Right Hand"
	keybind_signal = COMSIG_KB_MOB_SELECTRIGHTHAND_DOWN
	hand_index = RIGHT_HANDS

/datum/keybinding/dextrous/select_hand/left
	hotkey_keys = list(UNBOUND_KEY)
	name = "select_left_hand"
	full_name = "Swap to Left Hand"
	keybind_signal = COMSIG_KB_MOB_SELECTLEFTHAND_DOWN
	hand_index = LEFT_HANDS

/datum/keybinding/dextrous/select_hand/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return

	var/mob/user_mob = user.mob
	if(user_mob.active_hand_index % RIGHT_HANDS == hand_index % RIGHT_HANDS) // we're just cycling rows
		user_mob.cycle_hand(NORTH, climb = FALSE)
	else // we have to swap columns
		var/working_index
		var/inactive_hand_index = user_mob.get_inactive_hand_index()
		if(inactive_hand_index == hand_index)
			working_index = user_mob.get_num_hand_slots() - (RIGHT_HANDS - hand_index)
		else
			working_index = inactive_hand_index - 2
		user_mob.cycle_hand(NORTH, climb = FALSE, initial_index = working_index)

	return TRUE

/datum/keybinding/dextrous/activate_inhand
	hotkey_keys = list("Z")
	name = "activate_inhand"
	full_name = "Activate in-hand"
	description = "Uses whatever item you have inhand"
	keybind_signal = COMSIG_KB_MOB_ACTIVATEINHAND_DOWN

/datum/keybinding/dextrous/activate_inhand/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return
	var/mob/M = user.mob
	M.mode()
	return TRUE

/datum/keybinding/dextrous/drop_item
	hotkey_keys = list("Q")
	name = "drop_item"
	full_name = "Drop Item"
	description = "Drops the item in your active hand to the ground."
	keybind_signal = COMSIG_KB_MOB_DROPITEM_DOWN

/datum/keybinding/dextrous/drop_item/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return
	if(iscyborg(user.mob)) //cyborgs can't drop items
		return FALSE
	var/mob/user_mob = user.mob
	var/obj/item/item_dropped = user_mob.get_active_held_item()
	if(!item_dropped)
		to_chat(user, span_warning("You have nothing to drop in your hand!"))
		return TRUE
	user.mob.dropItemToGround(item_dropped)
	return TRUE

/datum/keybinding/dextrous/drop_item_specific
	hotkey_keys = list("CtrlQ")
	name = "drop_item_specific"
	full_name = "Drop Item (Specific)"
	description = "Drops the item in your active where your mouse cursor is, if in range."
	keybind_signal = COMSIG_KB_MOB_DROPITEM_DOWN

/datum/keybinding/dextrous/drop_item_specific/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return
	if(iscyborg(user.mob)) //cyborgs can't drop items
		return FALSE
	var/mob/user_mob = user.mob
	var/obj/item/item_dropped = user_mob.get_active_held_item()
	if(!item_dropped)
		to_chat(user, span_warning("You have nothing to drop in your hand!"))
		return TRUE
	if(!user_mob.Adjacent(target) || target.is_blocked_turf(source_atom = item_dropped))
		return TRUE
	var/x_value = (mousepos_x >= 0) ? mousepos_x - ICON_SIZE_X / 2 : mousepos_x + ICON_SIZE_X / 2
	var/y_value = (mousepos_y >= 0) ? mousepos_y - ICON_SIZE_Y / 2 : mousepos_y + ICON_SIZE_Y / 2
	user_mob.transfer_item_to_turf(item_dropped, target, x_value, y_value)
	return TRUE
