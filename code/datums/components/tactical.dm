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
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(unmodify))
	RegisterSignals(parent, list(COMSIG_ATOM_UPDATED_ICON, COMSIG_CARDBOARD_CUTOUT_APPLY_APPEARANCE), PROC_REF(tactical_update))
	var/obj/item/item = parent
	if(ismob(item.loc))
		var/mob/holder = item.loc
		modify(item, holder, holder.get_slot_by_item(item))

/datum/component/tactical/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_ITEM_EQUIPPED,
		COMSIG_ITEM_DROPPED,
		COMSIG_ATOM_UPDATED_ICON,
		COMSIG_CARDBOARD_CUTOUT_APPLY_APPEARANCE,
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

	if(current_slot) //If the current slot is set, this means the icon was updated or the item changed z-levels.
		user.remove_alt_appearance("sneaking_mission[REF(src)]")
	else
		RegisterSignal(parent, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(tactical_update))

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

	var/obj/item/master = parent
	if(!user)
		if(!ismob(master.loc))
			return
		user = master.loc

	user.remove_alt_appearance("sneaking_mission[REF(src)]")
	current_slot = null
	UnregisterSignal(parent, COMSIG_MOVABLE_Z_CHANGED)

/datum/component/tactical/proc/tactical_update(datum/source)
	SIGNAL_HANDLER
	var/obj/item/master = parent
	if(!ismob(master.loc))
		return
	modify(master, master.loc, current_slot)
