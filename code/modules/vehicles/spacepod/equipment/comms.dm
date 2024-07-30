/obj/item/pod_equipment/comms
	slot = POD_SLOT_COMMS
	var/list/accesses = list(ACCESS_EXTERNAL_AIRLOCKS) //external airlocks == station hangar

/obj/item/pod_equipment/comms/create_occupant_actions(mob/occupant, flag = NONE)
	if(!(flag & VEHICLE_CONTROL_DRIVE))
		return FALSE

	var/datum/action/cooldown/pod_comms_ping/equipment_action = new(src)
	equipment_action.pod = pod
	equipment_action.comms = src
	return equipment_action
