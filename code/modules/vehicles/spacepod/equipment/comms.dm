/obj/item/pod_equipment/comms
	name = "NT comms array"
	desc = "Standard suite of communication equipment for crew pods."
	slot = POD_SLOT_COMMS
	icon_state = "comms"
	// im not sure whether this is a good idea
	/// access of this comms array
	var/list/accesses = list(ACCESS_EXTERNAL_AIRLOCKS) //external airlocks == station hangar

/obj/item/pod_equipment/comms/create_occupant_actions(mob/occupant, flag = NONE)
	if(!(flag & VEHICLE_CONTROL_DRIVE))
		return FALSE
	return new /datum/action/cooldown/pod_comms_ping(src, TRUE, /* comms_array */ src)

/obj/item/pod_equipment/comms/debug
	name = "all access comms array"

/obj/item/pod_equipment/comms/debug/Initialize(mapload)
	. = ..()
	accesses = SSid_access.get_region_access_list(list(REGION_ALL_GLOBAL))
