/datum/component/tactical
	var/allowed_slot
	var/current_slot

/datum/component/tactical/Initialize(allowed_slot)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	src.allowed_slot = allowed_slot

/datum/component/tactical/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(modify))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(unmodify))

/datum/component/tactical/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED))
	unmodify()

/datum/component/tactical/Destroy()
	unmodify()
	return ..()

/datum/component/tactical/proc/on_z_move(datum/source)
	SIGNAL_HANDLER
	var/obj/item/master = parent
	if(!ismob(master.loc))
		return
	var/old_slot = current_slot
	unmodify(master, master.loc)
	modify(master, master.loc, old_slot)

/datum/component/tactical/proc/modify(obj/item/source, mob/user, slot)
	SIGNAL_HANDLER

	if(allowed_slot && !(slot & allowed_slot))
		unmodify()
		return

	current_slot = slot

	var/obj/item/master = parent
	var/image/I = image(icon = master.icon, icon_state = master.icon_state, loc = user)
	SET_PLANE_EXPLICIT(I, GAME_PLANE_FOV_HIDDEN, master)
	I.copy_overlays(master)
	I.override = TRUE
	source.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/everyone, "sneaking_mission", I)
	I.layer = ABOVE_MOB_LAYER
	RegisterSignal(parent, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(on_z_move))

/datum/component/tactical/proc/unmodify(obj/item/source, mob/user)
	SIGNAL_HANDLER

	var/obj/item/master = source || parent
	if(!user)
		if(!ismob(master.loc))
			return
		user = master.loc

	user.remove_alt_appearance("sneaking_mission")
	current_slot = null
	UnregisterSignal(parent, COMSIG_MOVABLE_Z_CHANGED)
