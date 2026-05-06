GLOBAL_LIST_INIT(inventory_slot_datums, initialize_inventory_slots())

/proc/initialize_inventory_slots()
	var/list/slot_types = list()
	for (var/slot_type in valid_subtypesof(/datum/inventory_slot))
		slot_types[slot_type] = new slot_type()
	return slot_types

/// Inventory slot datum (singleton) which holds data about an inventory screen element
/datum/inventory_slot
	abstract_type = /datum/inventory_slot
	/// Name assigned to the screen element
	var/name = "error"
	/// Should the slot inherit HUD's ui_style?
	var/inherit_style = TRUE
	/// Slot ID of the element
	var/slot_id = NONE
	/// Icon state of the element with nothing in it/unassigned icon_full
	var/icon_state = "template"
	/// Icon state of the element when it has an item in it
	var/icon_full = "template"
	/// Location of the element
	var/screen_loc = null
	/// Screen group to which the element is assigned
	var/screen_group = HUD_GROUP_STATIC
	/// Typepath of the screen element
	var/screen_type = /atom/movable/screen/inventory

/datum/inventory_slot/proc/create_element(datum/hud/hud)
	var/atom/movable/screen/inventory/inv_box = hud.add_screen_object(screen_type, HUD_KEY_ITEM_SLOT(slot_id), screen_group, inherit_style ? hud.ui_style : null, screen_loc)
	inv_box.name = name
	inv_box.icon_state = icon_state
	inv_box.icon_full = icon_full
	inv_box.slot_id = slot_id
	return inv_box

/// Returns the item held in this slot by hud's mymob
/datum/inventory_slot/proc/get_slot_item(mob/owner)
	return

/// Returns a screen object for this slot for a particular hud datum
/datum/inventory_slot/proc/get_screen_slot(datum/hud/hud)
	return hud.screen_objects[HUD_KEY_ITEM_SLOT(slot_id)]

/// Update inventory slot visuals
/datum/inventory_slot/proc/update_inventory_slot(datum/hud/hud, mob/owner)
	var/atom/movable/screen/inventory/slot = get_screen_slot(hud)
	if (!slot)
		return

	var/obj/item/slot_item = get_slot_item(owner)
	slot.update_icon()
	if (!slot_item)
		slot.vis_contents.Cut()
		return

	if (slot_item in slot.vis_contents)
		return

	// Reset pixel offsets in order to make it fit the box
	slot_item.pixel_x = slot_item.base_pixel_x
	slot_item.pixel_y = slot_item.base_pixel_y
	slot.vis_contents += slot_item

// Not a real inventory slot, but this is used as a generic abstraction for hand slot UI behaviors
/datum/inventory_slot/hands
	slot_id = ITEM_SLOT_HANDS

/datum/inventory_slot/hands/create_element(datum/hud/hud)
	CRASH("[hud] attempted to call create_element on a behavior-only hands inventory slot datum!")

/datum/inventory_slot/hands/get_slot_item(mob/owner, hand_index = 1)
	return owner.held_items[hand_index]

/datum/inventory_slot/hands/get_screen_slot(datum/hud/hud, hand_index = 1)
	return hud.screen_objects[HUD_KEY_HAND_SLOT(hand_index)]

/datum/inventory_slot/hands/update_inventory_slot(datum/hud/hud, mob/owner, hand_index = null)
	// If no index was passed, update all hand slots
	if (isnull(hand_index))
		for (var/i in 1 to length(owner.held_items))
			update_inventory_slot(hud, owner, i)
		return

	var/atom/movable/screen/inventory/slot = get_screen_slot(hud, hand_index)
	if (!slot)
		return

	var/obj/item/slot_item = get_slot_item(owner, hand_index)
	slot.update_icon()
	if (!slot_item)
		slot.vis_contents.Cut()
		return

	if (slot_item in slot.vis_contents)
		return

	// Reset pixel offsets in order to make it fit the box
	slot_item.pixel_x = slot_item.base_pixel_x
	slot_item.pixel_y = slot_item.base_pixel_y
	slot.vis_contents += slot_item
