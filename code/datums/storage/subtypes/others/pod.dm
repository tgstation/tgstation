/datum/storage/pod
	max_slots = 14
	max_total_storage = WEIGHT_CLASS_BULKY * 14
	allow_big_nesting = TRUE
	/// If TRUE, we unlock regardless of security level
	var/always_unlocked = FALSE

/datum/storage/pod/open_storage(mob/to_show)
	if(isliving(to_show) && SSsecurity_level.get_current_level_as_number() < SEC_LEVEL_RED)
		to_chat(to_show, span_warning("The storage unit will only unlock during a Red or Delta security alert."))
		return FALSE
	return ..()

/datum/storage/pod/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()
	// all of these are a type below what actually spawn with
	// (IE all space suits instead of just the emergency ones)
	// because an enterprising traitor might be able to hide things,
	// like their syndicate toolbox or softsuit. may be fun?
	set_holdable(exception_hold_list = list(
		/obj/item/clothing/suit/space,
		/obj/item/pickaxe,
		/obj/item/storage/toolbox,
	))

	RegisterSignal(SSsecurity_level, COMSIG_SECURITY_LEVEL_CHANGED, PROC_REF(update_lock))
	update_lock(new_level = SSsecurity_level.get_current_level_as_number())

/datum/storage/pod/set_parent(atom/new_parent)
	. = ..()
	RegisterSignal(parent, COMSIG_ATOM_AFTER_SHUTTLE_MOVE, PROC_REF(pod_launch))

/datum/storage/pod/proc/update_lock(datum/source, new_level)
	SIGNAL_HANDLER
	if(always_unlocked)
		return

	locked = (new_level < SEC_LEVEL_RED) ? STORAGE_FULLY_LOCKED : STORAGE_NOT_LOCKED
	parent.update_appearance(UPDATE_ICON_STATE)
	if(locked) // future todo : make `locked` a setter so this behavior can be built in (avoids exploits)
		close_all()

/datum/storage/pod/proc/pod_launch(datum/source, turf/old_turf)
	SIGNAL_HANDLER
	// This check is to ignore the movement of the shuttle from the transit level to the station as it is loaded in.
	if(old_turf && is_reserved_level(old_turf.z))
		return
	// If the pod was launched, the storage will always open.
	always_unlocked = TRUE
	locked = STORAGE_NOT_LOCKED
	parent.update_appearance(UPDATE_ICON_STATE)
