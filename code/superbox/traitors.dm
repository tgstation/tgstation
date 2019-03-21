//! Superbox's new traitor objectives.

// Put our homegrown objectives in the running.
/datum/antagonist/traitor/forge_single_objective()
	if (prob(80))
		return ..()

	var/datum/objective/sabotage/sabotage_objective = new
	sabotage_objective.owner = owner
	sabotage_objective.pick_target_machine()
	add_objective(sabotage_objective)
	owner.current.apply_status_effect(/datum/status_effect/sabotage_pinpointer)
	return 1

/// Traitor objective to destroy all of a certain kind of machine.
/datum/objective/sabotage
	martyr_compatible = TRUE

	var/atom/target_type

/datum/objective/sabotage/proc/pick_target_machine()
	target_type = pick(
		// general
		/obj/machinery/vending/tool,
		/obj/machinery/computer/slot_machine,
		/obj/machinery/photocopier,
		/obj/machinery/bookbinder,
		/obj/machinery/shower,
		// security
		// /obj/machinery/recharger, -- too hard, there's too many of them
		/obj/machinery/computer/security,
		/obj/machinery/computer/secure_data,
		/obj/machinery/door_timer,
		// engineering
		/obj/machinery/power/smes,
		/obj/machinery/power/port_gen/pacman,
		/obj/machinery/power/solar_control,
		/obj/machinery/power/tracker,
		/obj/machinery/power/emitter,
		/obj/machinery/portable_atmospherics/pump,
		/obj/machinery/portable_atmospherics/scrubber,
		/obj/machinery/atmospherics/components/unary/thermomachine/freezer,
		/obj/machinery/atmospherics/components/unary/thermomachine/heater,
		// medbay
		/obj/machinery/chem_heater,
		/obj/machinery/chem_master,
		/obj/machinery/chem_dispenser,
		/obj/machinery/sleeper,
		/obj/machinery/atmospherics/components/unary/cryo_cell,
		/obj/machinery/clonepod,
		/obj/machinery/computer/operating,
		// service
		/obj/machinery/hydroponics/constructable,
		/obj/machinery/microwave,
		/obj/machinery/chem_dispenser/drinks,
		/obj/machinery/chem_dispenser/drinks/beer,
		/obj/machinery/chem_master/condimaster,
		/obj/machinery/computer/cargo,
		/obj/machinery/gibber,
		// supply
		/obj/machinery/autolathe,
		/obj/machinery/mineral/equipment_vendor,
		/obj/machinery/mineral/ore_redemption,
		/obj/machinery/recycler,
		// command
		/obj/machinery/computer/upload/ai,
		/obj/machinery/computer/upload/borg,
		/obj/machinery/computer/crew,
		/obj/machinery/computer/card,
		/obj/machinery/computer/communications,
		/obj/machinery/blackbox_recorder,
		// science
		/obj/machinery/teleport/hub,
		/obj/machinery/rnd/destructive_analyzer,
		/obj/machinery/rnd/production/circuit_imprinter,
		/obj/machinery/mech_bay_recharge_port,
		/obj/machinery/mecha_part_fabricator,
		/obj/machinery/recharge_station,
		/obj/machinery/computer/camera_advanced/xenobio,
	)

	explanation_text = "Sabotage every [initial(target_type.name)] on the station."

/datum/objective/sabotage/proc/find_remaining()
	. = list()
	for (var/O in GLOB.machines)
		var/obj/machinery/M = O
		// must be the same thing or a child type with the same name
		if (!istype(M, target_type) || initial(M.name) != initial(target_type.name))
			continue

		var/turf/T = get_turf(M)
		// must be on a station level
		if (!T || !is_station_level(T.z))
			continue
		// must be on the station proper
		var/area/A = T.loc
		if (!A || !(A.type in GLOB.the_station_areas))
			continue

		// must still have integrity
		if (M.obj_integrity <= M.integrity_failure)
			continue
		// must not be emagged - acceptable sabotage method
		if (M.obj_flags & EMAGGED)
			continue

		. += M

/datum/objective/sabotage/check_completion()
	var/list/missed = find_remaining()
	return missed.len == 0

/datum/objective/sabotage/on

/// Sabotage pinpointer, based heavily on IAA pinpointer code.
/datum/status_effect/sabotage_pinpointer
	id = "sabotage_pinpointer"
	duration = -1
	tick_interval = 30 SECONDS
	alert_type = /obj/screen/alert/status_effect/sabotage_pinpointer
	var/range_mid = 8
	var/range_far = 16

/obj/screen/alert/status_effect/sabotage_pinpointer
	name = "Sabotage Integrated Pinpointer"
	desc = "Even stealthier than a normal implant."
	icon = 'icons/obj/device.dmi'
	icon_state = "pinon"

/datum/status_effect/sabotage_pinpointer/tick()
	if (QDELETED(owner))
		qdel(src)
		return
	var/turf/here = get_turf(owner)

	// put the pinpointer underneath graphic
	if (!linked_alert.underlays.len)
		linked_alert.underlays += "pinpointer"

	// scan for target
	var/atom/scan_target = null
	var/closest = INFINITY
	for(var/datum/objective/sabotage/S in owner.mind?.get_all_objectives())
		var/list/missed = S.find_remaining()
		for(var/atom/A in missed)
			var/turf/there = get_turf(A)
			var/dist = (there.x - here.x) ** 2 + (there.y - here.y) ** 2
			if (dist < closest)
				closest = dist
				scan_target = A

	// update pinpointer
	if (!scan_target)
		linked_alert.icon_state = ""
		linked_alert.desc = "No targets found. Excellent work."
		return
	var/turf/there = get_turf(scan_target)
	if (here.z != there.z)
		linked_alert.icon_state = "pinonnull"
		linked_alert.desc = "Failed to determine distance to target."
		return

	linked_alert.desc = "Tracking [scan_target] in [get_area_name(scan_target)]."
	linked_alert.setDir(get_dir(here, scan_target))
	if (closest == 0)
		linked_alert.icon_state = "pinondirect"
	else if (closest <= range_mid ** 2)
		linked_alert.icon_state = "pinonclose"
	else if (closest <= range_far ** 2)
		linked_alert.icon_state = "pinonmedium"
	else
		linked_alert.icon_state = "pinonfar"
