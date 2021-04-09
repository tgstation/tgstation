/// Prevents items from leaving their storage or whoever is holding their storage (does not need to have a storage component)
/datum/component/holderloving
	can_transfer = TRUE
	/// Item that is kept track of
	var/obj/item/holder
	/// If we delete our parent when the holder gets deleted
	var/del_parent_with_holder = FALSE

/datum/component/holderloving/Initialize(_holder, _del_parent_with_holder)
	if(!isitem(parent) || !_holder)
		return COMPONENT_INCOMPATIBLE
	holder = _holder
	del_parent_with_holder = (_del_parent_with_holder || FALSE)

/datum/component/holderloving/RegisterWithParent()
	RegisterSignal(holder, COMSIG_MOVABLE_MOVED, .proc/check_my_loc)
	RegisterSignal(holder, COMSIG_PARENT_QDELETING, .proc/holder_deleting)
	RegisterSignal(parent, list(
		COMSIG_ITEM_DROPPED,
		COMSIG_ITEM_EQUIPPED,
		COMSIG_STORAGE_ENTERED,
		COMSIG_STORAGE_EXITED,
	), .proc/check_my_loc)

/datum/component/holderloving/UnregisterFromParent()
	UnregisterSignal(holder, list(COMSIG_MOVABLE_MOVED, COMSIG_PARENT_QDELETING))
	UnregisterSignal(parent, list(
		COMSIG_ITEM_DROPPED,
		COMSIG_ITEM_EQUIPPED,
		COMSIG_STORAGE_ENTERED,
		COMSIG_STORAGE_EXITED,
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
	var/obj/item/Iparent = parent
	if(!check_valid_loc(Iparent.loc))
		Iparent.forceMove(holder)
