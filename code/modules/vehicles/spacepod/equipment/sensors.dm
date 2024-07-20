/obj/item/pod_equipment/sensors
	slot = POD_SLOT_SENSORS
	name = "NT Sensor Suite"
	desc = "A sensor suite for space pods, containing some tech doodads and a built-in GPS. Manufacted by Nanotrasen, and has weird labels like \"Not for infowar\" or manufacted on \"Tau Ceti IV\"."
	var/datum/component/gps/item/gps

/obj/item/pod_equipment/sensors/on_attach(mob/user)
	. = ..()
	gps = AddComponent(/datum/component/gps/item, "POD[rand(0,999)]", state = GLOB.not_incapacitated_state, overlay_state = FALSE)

/obj/item/pod_equipment/sensors/on_detach(mob/user)
	. = ..()
	QDEL_NULL(gps)

/obj/item/pod_equipment/sensors/grant_occupant_action(mob/occupant, flag = NONE)
	if(!(flag & VEHICLE_CONTROL_DRIVE))
		return FALSE

	var/datum/action/vehicle/sealed/spacepod_equipment/equipment_action = new(src)
	equipment_action.callback_on_click = CALLBACK(src, PROC_REF(on_use))
	equipment_action.name = name
	return equipment_action

/obj/item/pod_equipment/sensors/proc/on_use(mob/user)
	gps.interact(user = user)
