/datum/keybinding/human
	category = CATEGORY_HUMAN
	weight = WEIGHT_MOB

/datum/keybinding/human/can_use(client/user)
	return ishuman(user.mob)

/datum/keybinding/human/quick_equip
	hotkey_keys = list("E")
	name = "quick_equip"
	full_name = "Быстрое оснащение (экиперование)"
	description = "Быстро помещает предмет в лучшее из доступных мест (рук)"
	keybind_signal = COMSIG_KB_HUMAN_QUICKEQUIP_DOWN

/datum/keybinding/human/quick_equip/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/H = user.mob
	H.quick_equip()
	return TRUE

/datum/keybinding/human/quick_equip_belt
	hotkey_keys = list("ShiftE")
	name = "quick_equip_belt"
	full_name = "Быстро надеваемый ремень"
	description = "Положите удерживаемую вещь за пояс или достаньте из-за пояса самую свежую вещь (Быстро достать последний предмет, что положил в пояс)"
	///which slot are we trying to quickdraw from/quicksheathe into?
	var/slot_type = ITEM_SLOT_BELT
	///what we should call slot_type in messages (including failure messages)
	var/slot_item_name = "belt"
	keybind_signal = COMSIG_KB_HUMAN_QUICKEQUIPBELT_DOWN

/datum/keybinding/human/quick_equip_belt/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/H = user.mob
	H.smart_equip_targeted(slot_type, slot_item_name)
	return TRUE

/datum/keybinding/human/quick_equip_belt/quick_equip_bag
	hotkey_keys = list("ShiftB")
	name = "quick_equip_bag"
	full_name = "Быстро укомплектуйте сумку"
	description = "Положите удерживаемую вещь в рюкзак или достаньте из него самую свежую вещь (Быстро достать последний предмет, что положил в сумку)"
	slot_type = ITEM_SLOT_BACK
	slot_item_name = "backpack"
	keybind_signal = COMSIG_KB_HUMAN_BAGEQUIP_DOWN

/datum/keybinding/human/quick_equip_belt/quick_equip_suit_storage
	hotkey_keys = list("ShiftQ")
	name = "quick_equip_suit_storage"
	full_name = "Быстро оборудуйте место для хранения костюма"
	description = "Положите удерживаемую вещь в ячейку для хранения костюма или достаньте самую свежую вещь из ячейки для хранения костюма"
	slot_type = ITEM_SLOT_SUITSTORE
	slot_item_name = "suit storage slot item"
	keybind_signal = COMSIG_KB_HUMAN_SUITEQUIP_DOWN

/datum/keybinding/human/quick_equip_belt/quick_equip_lpocket
	hotkey_keys = list("Ctrl1")
	name = "quick_equip_lpocket"
	full_name = "Быстро положите в левый карман"
	description = "Положите или достаньте какой-нибудь предмет из левого кармана"
	slot_type = ITEM_SLOT_LPOCKET
	slot_item_name = "left pocket"
	keybind_signal = COMSIG_KB_HUMAN_LPOCKETEQUIP_DOWN

/datum/keybinding/human/quick_equip_belt/quick_equip_rpocket
	hotkey_keys = list("Ctrl2")
	name = "quick_equip_rpocket"
	full_name = "Быстро положите в правый карман"
	description = "Положите или достаньте какой-нибудь предмет из правого кармана"
	slot_type = ITEM_SLOT_RPOCKET
	slot_item_name = "right pocket"
	keybind_signal = COMSIG_KB_HUMAN_RPOCKETEQUIP_DOWN
