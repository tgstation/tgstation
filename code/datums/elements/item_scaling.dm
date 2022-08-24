/**
 * Element for scaling item appearances in the overworld or in inventory/storage.
 *
 * This bespoke element allows for items to have varying sizes depending on their location.
 * The overworld simply refers to items being on a turf.  Inventory includes HUD item slots,
 * and storage is anywhere a storage component is used.
 * Scaling should affect the item's icon and all attached overlays (such as blood decals).
 *
 */
/datum/element/item_scaling
	element_flags = ELEMENT_BESPOKE
	id_arg_index = 2
	/// Scaling value when the attached item is in the overworld (on a turf).
	var/overworld_scaling
	/// Scaling value when the attached item is in a storage component or inventory slot.
	var/storage_scaling

/**
 * Attach proc for the item_scaling element
 *
 * The proc checks the target's type before attaching.  It then initializes
 * the target to overworld scaling.  The target should then rescale if it is placed
 * in inventory/storage on initialization.  Relevant signals are registered to listen
 * for pickup/drop or storage events.  Scaling values of 1 will result in items
 * returning to their original size.
 * Arguments:
 * * target - Datum to attach the element to.
 * * overworld_scaling - Integer or float to scale the item in the overworld.
 * * storage_scaling - Integer or float to scale the item in storage/inventory.
 */
/datum/element/item_scaling/Attach(atom/target, overworld_scaling, storage_scaling)
	. = ..()
	if(!isatom(target))
		return ELEMENT_INCOMPATIBLE

	// Initial scaling set to overworld_scaling when item is spawned.
	scale(target, overworld_scaling)

	src.overworld_scaling = overworld_scaling
	src.storage_scaling = storage_scaling

	// Make sure overlays also inherit the scaling.
	ADD_KEEP_TOGETHER(target, ITEM_SCALING_TRAIT)

	// Object scaled when dropped/thrown OR when exiting a storage object.
	RegisterSignal(target, list(COMSIG_ITEM_DROPPED, COMSIG_ATOM_EXITED), .proc/scale_overworld)
	// Object scaled when placed in an inventory slot OR when entering a storage component.
	RegisterSignal(target, list(COMSIG_ITEM_EQUIPPED, COMSIG_ATOM_ENTERED), .proc/scale_storage)

/**
 * Detach proc for the item_scaling element.
 *
 * All registered signals are unregistered, and the attached element is removed from the target datum.
 * Arguments:
 * * target - Datum which the element is attached to.
 */
/datum/element/item_scaling/Detach(atom/target)
	UnregisterSignal(target, list(
		COMSIG_ITEM_PICKUP,
		COMSIG_ITEM_DROPPED,
		COMSIG_ATOM_ENTERED,
		COMSIG_ATOM_EXITED,
	))

	REMOVE_KEEP_TOGETHER(target, ITEM_SCALING_TRAIT)

	return ..()

/**
 * Scales the attached item's matrix.
 *
 * The proc first narrows the type of the source to (datums do not have a transform matrix).
 * It then creates an identity matrix, M, which is transformed by the scaling value.
 * The object's transform variable (matrix) is then set to the resulting value of M.
 * Arguments:
 * * source - Source datum which sent the signal.
 * * scaling - Integer or float to scale the item's matrix.
 */
/datum/element/item_scaling/proc/scale(datum/source, scaling)
	var/atom/scalable_object = source
	var/matrix/M = matrix()
	scalable_object.transform = M.Scale(scaling)

/**
 * Signal handler for COMSIG_ITEM_DROPPED or COMSIG_ATOM_EXITED
 *
 * Longer detailed paragraph about the proc
 * including any relevant detail
 * Arguments:
 * * source - Source datum which sent the signal.
 */
/datum/element/item_scaling/proc/scale_overworld(datum/source)
	SIGNAL_HANDLER

	scale(source, overworld_scaling)

/**
 * Signal handler for COMSIG_ITEM_EQUIPPED or COMSIG_ATOM_ENTERED.
 *
 * Longer detailed paragraph about the proc
 * including any relevant detail
 * Arguments:
 * * source - Source datum which sent the signal.
 */
/datum/element/item_scaling/proc/scale_storage(datum/source)
	SIGNAL_HANDLER

	scale(source, storage_scaling)
