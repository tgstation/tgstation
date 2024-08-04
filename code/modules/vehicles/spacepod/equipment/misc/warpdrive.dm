// no parent type of its own, just set slot to misc
/obj/item/pod_equipment/warp_drive
	slot = POD_SLOT_MISC
	name = "bluespace warp drive"
	desc = "Warp drive for space pods, used to warp to a Bluespace Navigation Gigabeacon, assuming it is functional and in space."
	icon_state = "warpdrive"
	interface_id = "WarpDrive"
	/// percentage of power needed to warp
	var/power_percentage_used = 50
	var/obj/machinery/spaceship_navigation_beacon/selected_beacon
	/// if true we cannot warp
	var/disrupted = FALSE

/obj/item/pod_equipment/warp_drive/on_detach(mob/user)
	. = ..()
	cancel_effects()

/obj/item/pod_equipment/warp_drive/examine(mob/user)
	. = ..()
	. += span_notice("This will use [power_percentage_used]% of your power for a warp. The better the cell, the faster the charge-up.")

/obj/item/pod_equipment/warp_drive/proc/is_valid_beacon(obj/machinery/spaceship_navigation_beacon/beacon)
	. = TRUE
	if(beacon.locked)
		return FALSE
	if(!istype(get_area(beacon), /area/space)) // dont use onstation stupid
		return FALSE

/obj/item/pod_equipment/warp_drive/proc/may_warp()
	var/obj/item/stock_parts/power_store/cell = pod.get_cell()
	return !isnull(selected_beacon) && !isnull(cell) && pod.has_enough_power(cell.maxcharge / 100 * power_percentage_used) && isnull(pod.drift_handler) && !disrupted

/obj/item/pod_equipment/warp_drive/ui_data(mob/user)
	. = list()
	.["mayWarp"] = may_warp()
	.["warpPercentage"] = power_percentage_used
	.["beacons"] = list()
	for(var/obj/machinery/spaceship_navigation_beacon/beacon as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/spaceship_navigation_beacon))
		if(!is_valid_beacon(beacon))
			continue
		.["beacons"] += list(list(
			"displayText" = beacon.name,
			"value" = REF(beacon),
		))
	if(selected_beacon)
		.["selectedBeacon"] = selected_beacon.name

/obj/item/pod_equipment/warp_drive/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("set_warp_target")
			. = TRUE
			var/obj/machinery/spaceship_navigation_beacon/beacon = locate(params["target"])
			if(isnull(beacon))
				return
			selected_beacon = beacon
		if("warp")
			. = TRUE
			try_warp(usr)

/obj/item/pod_equipment/warp_drive/proc/try_warp(mob/user)
	var/obj/item/stock_parts/power_store/cell = pod.get_cell()
	if(isnull(cell))
		return
	var/necessary_power = cell.maxcharge / 100 * power_percentage_used
	if(!pod.has_enough_power(necessary_power))
		pod.balloon_alert(user, "need atleast [power_percentage_used]% power!")
		return

	if(!istype(get_area(pod), /area/space)) // dont use onstation stupid
		pod.balloon_alert(user, "only in space!")
		return
	if(!isnull(pod.drift_handler))
		pod.balloon_alert(user, "must come to a halt!")
		return

	pod.balloon_alert_to_viewers("warping!")
	apply_wibbly_filters(pod)
	RegisterSignal(pod, COMSIG_ATOM_AFTER_ATTACKEDBY, PROC_REF(disrupted))
	var/duration = 2 SECONDS
	duration *= (/obj/item/stock_parts/power_store/battery/bluespace::maxcharge / cell.maxcharge) / 10
	if(!do_after(user, duration, pod, extra_checks = CALLBACK(src, PROC_REF(may_warp))))
		cancel_effects()
		return
	cancel_effects()
	var/list/good_locs = list()
	for(var/turf/potential_target as anything in get_teleport_turfs(selected_beacon, precision = 1))
		if(potential_target.is_blocked_turf_ignore_climbable())
			continue
		if(!ispodpassable(potential_target) || (potential_target.has_gravity() && !ispodpassable_nograv(potential_target)))
			continue
		good_locs += potential_target
	if(!length(good_locs))
		pod.balloon_alert(user, "target blocked!")
		return
	if(!pod.use_power(necessary_power))
		return
	playsound(pod.loc, SFX_PORTAL_ENTER, 80, TRUE)
	var/target = pick(good_locs)
	playsound(target, SFX_PORTAL_ENTER, 80, TRUE)
	do_teleport(pod, target)

/obj/item/pod_equipment/warp_drive/proc/disrupted(atom/source, obj/item/item, mob/living/user, params)
	SIGNAL_HANDLER
	if(!item.force)
		return
	source.balloon_alert_to_viewers("disrupted!")
	cancel_effects()
	disrupted = TRUE
	addtimer(VARSET_CALLBACK(src, disrupted, FALSE), 3 SECONDS)

/obj/item/pod_equipment/warp_drive/proc/cancel_effects()
	remove_wibbly_filters(pod)
	UnregisterSignal(pod, COMSIG_ATOM_AFTER_ATTACKEDBY)
