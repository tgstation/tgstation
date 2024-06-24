
/**
 * OPFOR EQUIPMENT DATUM
 *
 * The OPFOR subsystem will gather all of these on initialisation and populate a list, which is then passed
 * into the OPFOR UI, which can be selected by the user.
 *
 * The User will be equipped with whatever they have selected if the approving admin authorises it.
 */


/datum/opposing_force_equipment
	/// The name of the equipment used in the listing, if not set, it will use the items name.
	var/name
	/// The description of the equipment used in the listing, if not set, it will use the items description.
	var/description
	/// The item path that we refer to when equipping.
	var/obj/item_type
	/// Category of the item. See opposing_force_defines.dm for a list of categories.
	var/category = ""
	/// Note to admins, useful if the item is extraordinarily strong
	var/admin_note
	/// How many at most can we order of a specific item?
	var/max_amount = OPFOR_EQUIPMENT_COUNT_LIMIT
