// no parent type of its own, just set slot to misc
/obj/item/pod_equipment/warp_drive
	slot = POD_SLOT_MISC
	name = "Bluespace Warp Drive"
	desc = "A sensor suite for space pods, containing some tech doodads and a built-in GPS. Manufacted by Nanotrasen, and has weird labels like \"Not for infowar\" or manufacted on \"Tau Ceti IV\"."
	/// percentage of power needed to warp
	var/power_percentage_used = 60

/obj/item/pod_equipment/warp_drive/examine(mob/user)
	. = ..()
	. += span_notice("This will use [power_percentage_used]% of your power for a warp.")

/obj/item/pod_equipment/warp_drive/create_occupant_actions(mob/occupant, flag = NONE)
	if(!(flag & VEHICLE_CONTROL_DRIVE))
		return FALSE
	var/datum/action/vehicle/sealed/pod_warp/act = new(src)
	act.vehicle_entered_target = pod
	return act

/datum/action/vehicle/sealed/pod_warp
	name = "Warp"
	background_icon_state = "bg_tech"
	overlay_icon_state = "bg_tech_border"
	button_icon = 'icons/obj/anomaly.dmi'
	button_icon_state = "portal1"
	/// if true we cannot warp
	var/disrupted = FALSE

/datum/action/vehicle/sealed/pod_warp/Trigger(trigger_flags)
	. = ..()
	var/obj/item/pod_equipment/warp_drive/drive = target
	var/obj/vehicle/sealed/space_pod/pod = vehicle_entered_target
	var/obj/item/stock_parts/power_store/cell = pod.get_cell()
	if(isnull(cell))
		return
	var/necessary_power = cell.maxcharge / 100 * drive.power_percentage_used
	if(!pod.has_enough_power(necessary_power))
		pod.balloon_alert(owner, "need atleast [drive.power_percentage_used]% power!")
		return

	var/dest = tgui_input_list(owner, "Destination?", "Destination?", find_beacons())
	if(!dest || QDELING(pod) || !(owner in pod.occupants))
		return

	pod.balloon_alert_to_viewers("warping!")
	apply_wibbly_filters(pod)
	RegisterSignal(pod, COMSIG_ATOM_AFTER_ATTACKEDBY, PROC_REF(disrupted))
	ADD_TRAIT(pod, TRAIT_NO_TRANSFORM, REF(src))
	if(!do_after(owner, 10 SECONDS, pod, extra_checks = CALLBACK(src, PROC_REF(is_disrupted))))
		cancel_effects()
		return
	cancel_effects()
	if(!pod.use_power(necessary_power))
		return
	do_teleport(pod, dest, precision=1)

/datum/action/vehicle/sealed/pod_warp/proc/find_beacons()
	. = list()
	for(var/obj/machinery/spaceship_navigation_beacon/beacon as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/spaceship_navigation_beacon))
		if(beacon.locked)
			continue
		if(!istype(get_area(beacon), /area/space)) // dont use onstation stupid
			continue
		. += beacon
	if(!length(.))
		vehicle_entered_target.balloon_alert(owner, "no working beacons!")

/datum/action/vehicle/sealed/pod_warp/proc/is_disrupted()
	return !disrupted

/datum/action/vehicle/sealed/pod_warp/proc/disrupted(atom/source, obj/item/item, mob/living/user, params)
	SIGNAL_HANDLER
	if(!item.force)
		return
	source.balloon_alert_to_viewers("disrupted!")
	cancel_effects()
	disrupted = TRUE
	addtimer(VARSET_CALLBACK(src, disrupted, FALSE), 3 SECONDS)

/datum/action/vehicle/sealed/pod_warp/proc/cancel_effects()
	remove_wibbly_filters(src)
	REMOVE_TRAIT(vehicle_entered_target, TRAIT_NO_TRANSFORM, REF(src))
	UnregisterSignal(vehicle_entered_target, COMSIG_ATOM_AFTER_ATTACKEDBY)
