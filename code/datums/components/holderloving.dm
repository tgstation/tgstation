/** Holder Loving Component
 *
 * This component is assigned to an [/obj/item], and also keeps track of a [holder].
 * The [parent] is 'bound' to [holder]. [parent] will be kept either directly
 * inside [holder], or in the inventory of a [/mob] that is itself holding [holder].
 *
 * If [parent] is placed in a [loc] that is not [holder] or [holder].[loc]
 * (if it's a mob), it is placed back inside [holder].
 *
 * This is intended for items that are a 'part' of another item.
 *
 * It can also delete [parent] when [holder] is deleted.
 *
 */
/datum/component/holderloving
	can_transfer = TRUE
	/** Item that parent is bound to.
	 * We try to keep parent either directly in holder, or in holder's loc if loc is a mob,
	 * and warp parent into holder if they go anywhere else.
	 */
	var/atom/holder
	/// If parent is deleted when the holder gets deleted
	var/del_parent_with_holder = FALSE

/datum/component/holderloving/Initialize(holder, del_parent_with_holder)
	if(!isitem(parent) || !holder)
		return COMPONENT_INCOMPATIBLE
	src.holder = holder
	if(del_parent_with_holder)
		src.del_parent_with_holder = del_parent_with_holder

/datum/component/holderloving/RegisterWithParent()
	RegisterSignal(holder, COMSIG_MOVABLE_MOVED, .proc/check_my_loc)
	RegisterSignal(holder, COMSIG_PARENT_QDELETING, .proc/holder_deleting)
	RegisterSignal(parent, list(
		COMSIG_ITEM_DROPPED,
		COMSIG_ITEM_EQUIPPED,
		COMSIG_ATOM_ENTERED,
		COMSIG_ATOM_EXITED,
	), .proc/check_my_loc)

/datum/component/holderloving/UnregisterFromParent()
	UnregisterSignal(holder, list(COMSIG_MOVABLE_MOVED, COMSIG_PARENT_QDELETING))
	UnregisterSignal(parent, list(
		COMSIG_ITEM_DROPPED,
		COMSIG_ITEM_EQUIPPED,
		COMSIG_ATOM_ENTERED,
		COMSIG_ATOM_EXITED,
	))

/datum/component/holderloving/PostTransfer()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/holderloving/InheritComponent(datum/component/holderloving/friend, i_am_original, list/arguments)
	if(i_am_original)
		holder = friend.holder

/datum/component/holderloving/proc/check_valid_loc(atom/location)
	return (location == holder || ( location == holder.loc && ismob(holder.loc) ))

/datum/component/holderloving/proc/holder_deleting(datum/source, force)
	SIGNAL_HANDLER
	if(del_parent_with_holder)
		qdel(parent)
	else
		qdel(src)

/datum/component/holderloving/proc/check_my_loc(datum/source)
	SIGNAL_HANDLER
	var/obj/item/item_parent = parent
	if(!check_valid_loc(item_parent.loc))
		item_parent.forceMove(holder)
