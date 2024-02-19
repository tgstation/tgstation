///A simple component that replacess the user's appearance with that of the parent item when equipped.
/datum/component/tactical
	///The allowed slot(s) for the effect.
	var/allowed_slot
	///A cached of where the item is currently equipped.
	var/current_slot

/datum/component/tactical/Initialize(allowed_slot)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	src.allowed_slot = allowed_slot

/datum/component/tactical/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(modify))
	var/obj/item/item = parent
	if(ismob(item.loc))
		var/mob/holder = item.loc
		modify(item, holder, holder.get_slot_by_item(item))

/datum/component/tactical/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_ITEM_EQUIPPED,
	))
	unmodify()

/datum/component/tactical/Destroy()
	unmodify()
	return ..()

/datum/component/tactical/proc/modify(obj/item/source, mob/user, slot)
	SIGNAL_HANDLER

	if(allowed_slot && !(slot & allowed_slot))
		if(current_slot)
			unmodify(source, user)
		return

	RegisterSignal(parent, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(tactical_update))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(unmodify))
	RegisterSignal(parent, COMSIG_ATOM_UPDATED_ICON, PROC_REF(tactical_update))
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))

	current_slot = slot

	var/obj/item/master = parent
	var/image/image = image(master, loc = user)
	image.copy_overlays(master)
	image.override = TRUE
	image.layer = ABOVE_MOB_LAYER
	image.plane = FLOAT_PLANE
	source.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/everyone, "sneaking_mission[REF(src)]", image)

/datum/component/tactical/proc/unmodify(obj/item/source, mob/user)
	SIGNAL_HANDLER

	if(!user)
		user = source.loc
	if(!istype(user))
		return

	user.remove_alt_appearance("sneaking_mission[REF(src)]")
	current_slot = null
	UnregisterSignal(parent, list(COMSIG_MOVABLE_Z_CHANGED, COMSIG_ITEM_DROPPED, COMSIG_ATOM_UPDATED_ICON, COMSIG_MOVABLE_MOVED))

/datum/component/tactical/proc/tactical_update(obj/item/source)
	SIGNAL_HANDLER
	if(!ismob(source.loc))
		return
	modify(source, source.loc, current_slot)

///We really want to make sure that, if things ever slightly breaks, that the alt appearance will be removed anyway.
/datum/component/tactical/proc/on_moved(obj/item/source, atom/oldloc, direction, forced)
	SIGNAL_HANDLER
	unmodify(source, oldloc)
