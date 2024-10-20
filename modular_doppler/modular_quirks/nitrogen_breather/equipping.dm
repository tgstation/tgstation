/datum/quirk/equipping
	abstract_parent_type = /datum/quirk/equipping
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_CHANGES_APPEARANCE
	icon = FA_ICON_BOX_OPEN
	/// the items that will be equipped, formatted in the way of [item_path = list of slots it can be equipped to], will not equip over nodrop items
	var/list/items = list()
	/// the items that will be forcefully equipped, formatted in the way of [item_path = list of slots it can be equipped to], will equip over nodrop items
	var/list/forced_items = list()
	/// did we force drop any items? if so, they're in this list. useful for transferring any applicable contents into new items on roundstart
	var/list/force_dropped_items = list()

/datum/quirk/equipping/add_unique(client/client_source)
	var/mob/living/carbon/carbon_holder = quirk_holder
	if (!items || !carbon_holder)
		return
	var/list/equipped_items = list()
	var/list/all_items = forced_items|items
	for (var/obj/item/item_path as anything in all_items)
		if (!ispath(item_path))
			continue
		var/item = new item_path(carbon_holder.loc)
		var/success = FALSE
		// Checking for nodrop and seeing if there's an empty slot
		for (var/slot as anything in all_items[item_path])
			success = force_equip_item(carbon_holder, item, slot, check_item = FALSE)
			if (success)
				break
		// Checking for nodrop
		for (var/slot as anything in all_items[item_path])
			success = force_equip_item(carbon_holder, item, slot)
			if (success)
				break

		if ((item_path in forced_items) && !success)
			// Checking for nodrop failed, shove it into the first available slot, even if it has nodrop
			for (var/slot as anything in all_items[item_path])
				success = force_equip_item(carbon_holder, item, slot, FALSE)
				if (success)
					break
		equipped_items[item] = success
	for (var/item as anything in equipped_items)
		on_equip_item(item, equipped_items[item])

/datum/quirk/equipping/proc/force_equip_item(mob/living/carbon/target, obj/item/item, slot, check_nodrop = TRUE, check_item = TRUE)
	var/obj/item/item_in_slot = target.get_item_by_slot(slot)
	if (check_item && item_in_slot)
		if (check_nodrop && HAS_TRAIT(item_in_slot, TRAIT_NODROP))
			return FALSE
		target.dropItemToGround(item_in_slot, force = TRUE)
		force_dropped_items += item_in_slot
		RegisterSignal(item_in_slot, COMSIG_QDELETING, PROC_REF(dropped_items_cleanup))

	return target.equip_to_slot_if_possible(item, slot, disable_warning = TRUE) // this should never not work tbh

/datum/quirk/equipping/proc/dropped_items_cleanup(obj/item/source)
	SIGNAL_HANDLER

	force_dropped_items -= source

/datum/quirk/equipping/proc/on_equip_item(obj/item/equipped, success)
	return
