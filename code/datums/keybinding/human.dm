/datum/keybinding/human
    category = CATEGORY_HUMAN
    weight = WEIGHT_MOB


/datum/keybinding/human/quick_equip
	key = "E"
	name = "quick_equip"
	full_name = "Quick Equip"
	description = "Quickly puts an item in the best slot available"

/datum/keybinding/human/quick_equip/down(client/user)
    var/mob/living/carbon/human/H = user.mob
    H.quick_equip()
    return TRUE

/datum/keybinding/human/quick_equipbelt
    key = "Shift-E"
    name = "quick_equipbelt"
    full_name = "Quick equip belt"
    description = "Put held thing in belt or take out most recent thing from belt"

/datum/keybinding/human/quick_equipbelt/down(client/user)
    var/mob/living/carbon/human/H = user.mob
    H.smart_equipbelt()
    return TRUE

/datum/keybinding/human/bag_equip
	key = "Shift-B"
	name = "bag_equip"
	full_name = "Bag equip"
	description = "Put held thing in backpack or take out most recent thing from backpack"

/datum/keybinding/human/bag_equip/down(client/user)
    var/mob/living/carbon/human/H = user.mob
    H.smart_equipbag()
    return TRUE
