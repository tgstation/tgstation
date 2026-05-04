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
