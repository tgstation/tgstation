/obj/item/pod_equipment/primary
	slot = POD_SLOT_PRIMARY
	var/flags_to_operate = VEHICLE_CONTROL_DRIVE
	var/action_key = "Space"
	var/cooldown_time = 1 SECONDS
	COOLDOWN_DECLARE(use_cooldown)

/obj/item/pod_equipment/primary/on_attach(mob/user)
	. = ..()
	RegisterSignal(pod, COMSIG_VEHICLE_OCCUPANT_ADDED, PROC_REF(occupant_added))
	RegisterSignal(pod, COMSIG_VEHICLE_OCCUPANT_REMOVED, PROC_REF(occupant_removed))
	for(var/occupant in pod.occupants)
		occupant_added(src, occupant, pod.occupants[occupant])

/obj/item/pod_equipment/primary/on_detach(mob/user)
	. = ..()
	UnregisterSignal(pod, list(COMSIG_VEHICLE_OCCUPANT_ADDED, COMSIG_VEHICLE_OCCUPANT_REMOVED))
	for(var/occupant in pod.occupants)
		occupant_removed(src, occupant)

/obj/item/pod_equipment/primary/proc/occupant_added(datum/source, mob/living/occupant, flags)
	SIGNAL_HANDLER
	if(!(flags & flags_to_operate))
		return FALSE
	RegisterSignal(occupant, COMSIG_MOB_KEYDOWN, PROC_REF(driver_keydown))

/obj/item/pod_equipment/primary/proc/occupant_removed(datum/source, mob/living/occupant, flags)
	SIGNAL_HANDLER
	UnregisterSignal(occupant, COMSIG_MOB_KEYDOWN)

/obj/item/pod_equipment/primary/proc/driver_keydown(mob/source, key, client, full_key)
	SIGNAL_HANDLER
	if(key != action_key)
		return
	if(!COOLDOWN_FINISHED(src, use_cooldown))
		return
	COOLDOWN_START(src, use_cooldown, cooldown_time)
	action(source)

/obj/item/pod_equipment/primary/proc/action(mob/user)
	return
