/datum/keybinding/human
	category = CATEGORY_HUMAN
	weight = WEIGHT_MOB

/datum/keybinding/human/can_use(client/user)
	return ishuman(user.mob)

/datum/keybinding/human/quick_equip
	hotkey_keys = list("E")
	name = "quick_equip"
	full_name = "Экипировать вещь"
	description = "Быстро экипирует предмет в любой подходящий слот"
	keybind_signal = COMSIG_KB_HUMAN_QUICKEQUIP_DOWN

/datum/keybinding/human/quick_equip/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/H = user.mob
	H.quick_equip()
	return TRUE

/datum/keybinding/human/quick_equip_belt
	hotkey_keys = list("ShiftE")
	name = "quick_equip_belt"
	full_name = "Быстрая экипировка пояса"
	description = "Положить предмет из руки в пояс или вытащить последний предмет из него"
	///which slot are we trying to quickdraw from/quicksheathe into?
	var/slot_type = ITEM_SLOT_BELT
	///what we should call slot_type in messages (including failure messages)
	var/slot_item_name = "пояса"
	keybind_signal = COMSIG_KB_HUMAN_QUICKEQUIPBELT_DOWN

/datum/keybinding/human/quick_equip_belt/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/H = user.mob
	H.smart_equip_targeted(slot_type, slot_item_name)
	return TRUE

/datum/keybinding/human/quick_equip_belt/quick_equip_bag
	hotkey_keys = list("ShiftV") // BANDASTATION EDIT
	name = "quick_equip_bag"
	full_name = "Быстрая экипировка в сумку"
	description = "Положить предмет из руки в сумку или вытащить последний предмет из нее"
	slot_type = ITEM_SLOT_BACK
	slot_item_name = "сумки"
	keybind_signal = COMSIG_KB_HUMAN_BAGEQUIP_DOWN

/datum/keybinding/human/quick_equip_belt/quick_equip_suit_storage
	hotkey_keys = list("ShiftQ")
	name = "quick_equip_suit_storage"
	full_name = "Быстрая экипировка в хранилище костюма"
	description = "Положить предмет из руки в костюм или вытащить последний предмет из него"
	slot_type = ITEM_SLOT_SUITSTORE
	slot_item_name = "из хранилища костюма"
	keybind_signal = COMSIG_KB_HUMAN_SUITEQUIP_DOWN

/datum/keybinding/human/quick_equip_belt/quick_equip_lpocket
	hotkey_keys = list("Alt1") // BANDASTATION EDIT
	name = "quick_equip_lpocket"
	full_name = "Быстрая экипировка левого кармана"
	description = "Положить предмет из руки в левый карман или последний предмет из него"
	slot_type = ITEM_SLOT_LPOCKET
	slot_item_name = "левого кармана"
	keybind_signal = COMSIG_KB_HUMAN_LPOCKETEQUIP_DOWN

/datum/keybinding/human/quick_equip_belt/quick_equip_rpocket
	hotkey_keys = list("Alt2") // BANDASTATION EDIT
	name = "quick_equip_rpocket"
	full_name = "Быстрая экипировка правого кармана"
	description = "Положить предмет из руки в правый карман или последний предмет из него"
	slot_type = ITEM_SLOT_RPOCKET
	slot_item_name = "правого кармана"
	keybind_signal = COMSIG_KB_HUMAN_RPOCKETEQUIP_DOWN

/datum/keybinding/human/quick_accessory_draw
	hotkey_keys = list("ShiftF")
	name = "quick_accessory_draw"
	full_name = "Быстро достать предмет из аксессуара"
	description = "Достать предмет из первого слота хранилища аксессуара"
	keybind_signal = COMSIG_KB_HUMAN_QUICK_ACCESSORY_DRAW_DOWN
