/** Holder Loving Component
 *
 * When you drop an object onto a turf it gets moved back into its parent holder
 *
 * Prevents you from force moving the object into any other location that isn't its parent holder
 */
/datum/component/holderloving
	/** Item that parent is bound to.
	 * We try to keep parent either directly in holder, or in holder's loc if loc is a mob,
	 * and warp parent into holder if they go anywhere else.
	 */
	var/atom/holder

/datum/component/holderloving/Initialize(holder)
	if(!isitem(parent) || !holder)
		return COMPONENT_INCOMPATIBLE
	src.holder = holder

/datum/component/holderloving/RegisterWithParent()
	RegisterSignal(holder, COMSIG_QDELETING, PROC_REF(holder_deleting))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(check_my_loc))
	RegisterSignal(parent, COMSIG_ITEM_PRE_UNEQUIP, PROC_REF(can_be_moved))

/datum/component/holderloving/UnregisterFromParent()
	UnregisterSignal(holder, list(COMSIG_QDELETING))
	UnregisterSignal(parent, list(COMSIG_ITEM_DROPPED, COMSIG_ITEM_PRE_UNEQUIP))

/datum/component/holderloving/proc/holder_deleting(datum/source, force)
	SIGNAL_HANDLER

	qdel(parent)

/datum/component/holderloving/proc/is_valid_location(atom/location)
	SHOULD_BE_PURE(TRUE)

	if(location == holder || ( location == holder.loc && ismob(holder.loc)))
		return TRUE

	return FALSE

/datum/component/holderloving/proc/check_my_loc(datum/source)
	SIGNAL_HANDLER

	var/obj/item/item_parent = parent
	if(!is_valid_location(item_parent.loc))
		item_parent.forceMove(holder)

/datum/component/holderloving/proc/can_be_moved(obj/item/I, force, atom/newloc, no_move, invdrop, silent)
	SIGNAL_HANDLER

	//allow the item to be dropped on the turf so it can be later moved back into the holder as a convinience tool
	if(isturf(newloc) || is_valid_location(newloc))
		return NONE

	//prevent this item from being moved anywhere else
	return COMPONENT_ITEM_BLOCK_UNEQUIP
