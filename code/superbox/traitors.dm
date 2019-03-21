//! Superbox's new traitor objectives.

// Put our homegrown objectives in the running.
/datum/antagonist/traitor/forge_single_objective()
	if (prob(30) && !(locate(/datum/objective/sabotage) in objectives))
		var/datum/objective/sabotage/sabotage_objective = new
		sabotage_objective.owner = owner
		sabotage_objective.pick_target_machine()
		add_objective(sabotage_objective)
		return 1

	return ..()

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
		/obj/machinery/rnd/production/protolathe,
		/obj/machinery/rnd/production/circuit_imprinter,
		/obj/machinery/mech_bay_recharge_port,
		/obj/machinery/mecha_part_fabricator,
		/obj/machinery/recharge_station,
		/obj/machinery/computer/camera_advanced/xenobio,
	)

	explanation_text = "Sabotage every [initial(target_type.name)] on the station."

/datum/objective/sabotage/check_completion()
	. = TRUE
	var/list/missed = list()
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

		missed += "[M] [ADMIN_COORDJMP(T)] [ADMIN_VV(M)]"
		. = FALSE

	if (!.)
		message_admins("[key_name_admin(owner.current)] did not sabotage:\n[missed.Join("\n")]")
