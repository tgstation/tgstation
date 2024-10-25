/obj/item/pod_equipment/sensors
	slot = POD_SLOT_SENSORS
	name = "sensor suite"
	desc = "A sensor suite for space pods, containing some tech doodads and a built-in GPS. Manufacted by Nanotrasen, and has weird labels like \"Not for infowar\" or \"manufacted on Tau Ceti IV\"."
	icon_state = "sensors"
	/// reference to our GPS component
	var/datum/component/gps/item/gps
	/// traits given to all passengers
	var/traits_given

/obj/item/pod_equipment/sensors/on_attach(mob/user)
	. = ..()
	gps = AddComponent(/datum/component/gps/item, "POD[rand(0,999)]", state = GLOB.in_vehicle_state, overlay_state = FALSE)
	gps.tracking = FALSE
	START_PROCESSING(SSobj, src)
	if(islist(traits_given))
		RegisterSignal(pod, COMSIG_VEHICLE_OCCUPANT_ADDED, PROC_REF(occupant_added))
		RegisterSignal(pod, COMSIG_VEHICLE_OCCUPANT_REMOVED, PROC_REF(occupant_removed))
		for(var/occupant in pod.occupants)
			occupant_added(occupant)

/obj/item/pod_equipment/sensors/on_detach(mob/user)
	. = ..()
	QDEL_NULL(gps)
	UnregisterSignal(pod, list(COMSIG_VEHICLE_OCCUPANT_ADDED, COMSIG_VEHICLE_OCCUPANT_REMOVED))
	if(islist(traits_given))
		for(var/occupant in pod.occupants)
			occupant_removed(occupant)

/// Adds sight traits to a new occupant, runs ONLY if traits_given is a list
/obj/item/pod_equipment/sensors/proc/occupant_added(datum/source, mob/living/carbon/occupant, flags)
	SIGNAL_HANDLER
	if(istype(occupant))
		occupant.add_traits(traits_given, REF(src))
		occupant.update_sight()

/// Removes sight traits from a former occupant, runs ONLY if traits_given is a list
/obj/item/pod_equipment/sensors/proc/occupant_removed(datum/source, mob/living/carbon/occupant, flags)
	SIGNAL_HANDLER
	if(istype(occupant))
		occupant.remove_traits(traits_given, REF(src))
		occupant.update_sight()

/obj/item/pod_equipment/sensors/create_occupant_actions(mob/occupant, flag = NONE)
	if(!(flag & VEHICLE_CONTROL_DRIVE))
		return FALSE
	return new /datum/action/vehicle/sealed/spacepod_equipment/sensor_gps(src, src)

/obj/item/pod_equipment/sensors/process()
	if(!gps?.tracking)
		return
	if(!length(pod.occupants))
		return
	if(pod.use_power(STANDARD_BATTERY_CHARGE / 100000))
		return
	SStgui.close_uis(gps)

/obj/item/pod_equipment/sensors/mesons
	name = "construction sensor suite"
	desc = "A pod sensor suite with built-in GPS and meson vision."
	icon_state = "sensorsmeson"
	traits_given = list(TRAIT_MESON_VISION, TRAIT_MADNESS_IMMUNE)

/obj/item/pod_equipment/sensors/nightvision
	name = "NV sensor suite"
	desc = "A pod sensor suite with built-in GPS and night vision."
	icon_state = "sensorsnv"
	traits_given = list(TRAIT_TRUE_NIGHT_VISION)
