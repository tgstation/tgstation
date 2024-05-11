/**
 * Element for scaling item appearances in the overworld or in inventory/storage.
 *
 * This bespoke element allows for items to have varying sizes depending on their location.
 * The overworld simply refers to items being on a turf.  Inventory includes HUD item slots,
 * and storage is anywhere a storage component is used.
 * Scaling should affect the item's icon and all attached overlays (such as blood decals).
 *
 */
/datum/element/item_storage_state
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// String with the name of the icon in the .dmi file that the item will use while in players inventory
	var/storage_state
	var/original_state

/datum/element/item_storage_state/Attach(atom/target, storage_state)
	. = ..()
	if(!isatom(target))
		return ELEMENT_INCOMPATIBLE

	src.storage_state = storage_state
	src.original_state = original_state
	original_state = target.icon_state

	sprite_by_loc(target)

	RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(sprite_by_loc))


/datum/element/item_storage_state/proc/sprite_by_loc(atom/target)
	if(isturf(target.loc))
		target.icon_state = "[original_state]"
	else
		target.icon_state = "[storage_state]"
	target.update_appearance()
