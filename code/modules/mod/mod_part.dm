/// Datum to handle interactions between a MODsuit and its parts.
/datum/mod_part
	/// The actual item we handle.
	var/obj/item/part_item = null
	/// Are we sealed?
	var/sealed = FALSE
	/// Message to user when unsealed.
	var/unsealed_message
	/// Message to user when sealed.
	var/sealed_message
	/// The layer the item will render on when unsealed.
	var/unsealed_layer
	/// The layer the item will render on when sealed.
	var/sealed_layer
	/// Can our part overslot over others?
	var/can_overslot = FALSE
	/// What are we overslotting over?
	var/obj/item/overslotting = null

/datum/mod_part/Destroy()
	part_item = null
	return ..()
