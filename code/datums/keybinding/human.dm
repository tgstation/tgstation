/datum/keybinding/human
	category = CATEGORY_HUMAN
	weight = WEIGHT_MOB

/datum/keybinding/human/can_use(client/user)
	return ishuman(user.mob)

/datum/keybinding/human/quick_equip
	hotkey_keys = list("R")
	name = "quick_equip"
	full_name = "Quick equip"
	description = "Quickly puts an item in the best slot available"
	keybind_signal = COMSIG_KB_HUMAN_QUICKEQUIP_DOWN

/datum/keybinding/human/quick_equip/down(client/user, turf/target)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/H = user.mob
	H.quick_equip()
	return TRUE

/datum/keybinding/human/quick_equip_belt
	hotkey_keys = list("ShiftR")
	name = "quick_equip_belt"
	full_name = "Quick equip belt"
	description = "Put held thing in belt or take out most recent thing from belt"
	///which slot are we trying to quickdraw from/quicksheathe into?
	var/slot_type = ITEM_SLOT_BELT
	///what we should call slot_type in messages (including failure messages)
	var/slot_item_name = "belt"
	keybind_signal = COMSIG_KB_HUMAN_QUICKEQUIPBELT_DOWN

/datum/keybinding/human/quick_equip_belt/down(client/user, turf/target)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/H = user.mob
	H.smart_equip_targeted(slot_type, slot_item_name)
	return TRUE

/datum/keybinding/human/quick_equip_belt/quick_equip_bag
	hotkey_keys = list("ShiftB")
	name = "quick_equip_bag"
	full_name = "Quick equip bag"
	description = "Put held thing in backpack or take out most recent thing from backpack"
	slot_type = ITEM_SLOT_BACK
	slot_item_name = "backpack"
	keybind_signal = COMSIG_KB_HUMAN_BAGEQUIP_DOWN

/datum/keybinding/human/quick_equip_belt/quick_equip_suit_storage
	hotkey_keys = list("ShiftQ")
	name = "quick_equip_suit_storage"
	full_name = "Quick equip suit storage slot"
	description = "Put held thing in suit storage slot item or take out most recent thing from suit storage slot item"
	slot_type = ITEM_SLOT_SUITSTORE
	slot_item_name = "suit storage slot item"
	keybind_signal = COMSIG_KB_HUMAN_SUITEQUIP_DOWN

/datum/keybinding/human/quick_equip_belt/quick_equip_lpocket
	hotkey_keys = list("Ctrl1")
	name = "quick_equip_lpocket"
	full_name = "Quick equip left pocket"
	description = "Put in or take out an item in left pocket"
	slot_type = ITEM_SLOT_LPOCKET
	slot_item_name = "left pocket"
	keybind_signal = COMSIG_KB_HUMAN_LPOCKETEQUIP_DOWN

/datum/keybinding/human/quick_equip_belt/quick_equip_rpocket
	hotkey_keys = list("Ctrl2")
	name = "quick_equip_rpocket"
	full_name = "Quick equip right pocket"
	description = "Put in or take out an item in right pocket"
	slot_type = ITEM_SLOT_RPOCKET
	slot_item_name = "right pocket"
	keybind_signal = COMSIG_KB_HUMAN_RPOCKETEQUIP_DOWN
