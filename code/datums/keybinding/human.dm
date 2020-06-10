/datum/keybinding/human
	category = CATEGORY_HUMAN
	weight = WEIGHT_MOB

/datum/keybinding/human/can_use(client/user)
	return ishuman(user.mob)

/datum/keybinding/human/quick_equip
	hotkey_keys = list("E")
	name = "quick_equip"
	full_name = "Quick Equip"
	description = "Quickly puts an item in the best slot available"

/datum/keybinding/human/quick_equip/down(client/user)
	var/mob/living/carbon/human/H = user.mob
	H.quick_equip()
	return TRUE

/datum/keybinding/human/quick_equipbelt
	hotkey_keys = list("ShiftE")
	name = "quick_equipbelt"
	full_name = "Quick equip belt"
	description = "Put held thing in belt or take out most recent thing from belt"

/datum/keybinding/human/quick_equipbelt/down(client/user)
	var/mob/living/carbon/human/H = user.mob
	H.smart_equipbelt()
	return TRUE

/datum/keybinding/human/bag_equip
	hotkey_keys = list("ShiftB")
	name = "bag_equip"
	full_name = "Bag equip"
	description = "Put held thing in backpack or take out most recent thing from backpack"

/datum/keybinding/human/bag_equip/down(client/user)
	var/mob/living/carbon/human/H = user.mob
	H.smart_equipbag()
	return TRUE

/datum/keybinding/human/equipment_swap
	hotkey_keys = list("V")
	name = "equipment_swap"
	full_name = "Equipment Swap"
	description = "Equip the currently held item by swapping it out with the already equipped item after a small delay"

/datum/keybinding/human/equipment_swap/down(client/user)
	var/mob/living/carbon/human/H = user.mob
	H.equipment_swap()
	return TRUE
