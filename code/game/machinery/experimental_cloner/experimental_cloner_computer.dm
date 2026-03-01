/// Computer which starts the experimental cloning process
/obj/machinery/computer/experimental_cloner
	name = "experimental cloner control console"
	desc = "It scans DNA structures."
	circuit = /obj/item/circuitboard/computer/experimental_cloner
	icon_screen = "crew"
	icon_keyboard = "med_key"
	light_color = LIGHT_COLOR_GREEN
	interaction_flags_click = ALLOW_SILICON_REACH
	/// Our current stored cloning record
	var/datum/experimental_cloning_record/stored_record
	/// Scanner we save a test subject from
	var/obj/machinery/experimental_cloner_scanner/input
	/// Pod we print someone into
	var/obj/machinery/experimental_cloner/output
	/// Whether we should automatically try to connect to nearby machines
	var/find_connections = FALSE

/obj/machinery/computer/experimental_cloner/Initialize(mapload, obj/item/circuitboard/circuit)
	. = ..()
	find_connections = mapload

/obj/machinery/computer/experimental_cloner/post_machine_initialize()
	. = ..()
	if (find_connections)
		connect_nearby_machines()

/// Find nearby associated machinery and link up
/obj/machinery/computer/experimental_cloner/proc/connect_nearby_machines()
	var/list/stuff_in_range = range(5, src)

	var/obj/machinery/experimental_cloner_scanner/scanner = locate() in stuff_in_range
	if (!isnull(scanner))
		link_scanner(scanner)
	var/obj/machinery/experimental_cloner/pod = locate() in stuff_in_range
	if (!isnull(pod))
		link_pod(pod)

/obj/machinery/computer/experimental_cloner/multitool_act(mob/living/user, obj/item/multitool/multi_tool)
	. = NONE
	if (machine_stat & BROKEN || isnull(multi_tool.buffer))
		return

	if (istype(multi_tool.buffer, /obj/machinery/experimental_cloner_scanner))
		unlink_scanner()
		link_scanner(multi_tool.buffer)
		balloon_alert(user, "scanner linked")
		to_chat(user, span_notice("You link \the [multi_tool.buffer] with \the [src]."))
		return ITEM_INTERACT_SUCCESS
	if (istype(multi_tool.buffer, /obj/machinery/experimental_cloner))
		unlink_pod()
		link_pod(multi_tool.buffer)
		balloon_alert(user, "pod linked")
		to_chat(user, span_notice("You link \the [multi_tool.buffer] with \the [src]."))
		return ITEM_INTERACT_SUCCESS

/obj/machinery/computer/experimental_cloner/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ExperimentalCloner")
		ui.open()

/// Link up with a scanner to scan people
/obj/machinery/computer/experimental_cloner/proc/link_scanner(obj/machinery/experimental_cloner_scanner/scanner)
	RegisterSignal(scanner, COMSIG_QDELETING, PROC_REF(unlink_scanner))
	RegisterSignal(scanner, COMSIG_CLONER_SCAN_SUCCESSFUL, PROC_REF(on_scan_complete))
	input = scanner

/// Store the record made by scanning someone
/obj/machinery/computer/experimental_cloner/proc/on_scan_complete(obj/machinery/experimental_cloner_scanner/scanner, datum/experimental_cloning_record/record)
	SIGNAL_HANDLER
	stored_record = record

/// Release held references on deletion
/obj/machinery/computer/experimental_cloner/proc/unlink_scanner()
	SIGNAL_HANDLER
	if (!input)
		return
	UnregisterSignal(input, list(COMSIG_CLONER_SCAN_SUCCESSFUL, COMSIG_QDELETING))
	input = null

/// Link up with a pod to print people
/obj/machinery/computer/experimental_cloner/proc/link_pod(obj/machinery/experimental_cloner/pod)
	RegisterSignal(pod, COMSIG_QDELETING, PROC_REF(unlink_pod))
	output = pod

/// Release held references on deletion
/obj/machinery/computer/experimental_cloner/proc/unlink_pod()
	SIGNAL_HANDLER
	if (!output)
		return
	UnregisterSignal(output, COMSIG_QDELETING)
	output = null

/obj/machinery/computer/experimental_cloner/ui_data(mob/user)
	var/list/data = list()

	var/mob/living/carbon/human/scanner_occupant = input?.occupant
	var/cloning_time_left = !output || output.awaiting_ghost ? 0 : timeleft(output.running_timer)

	data["record_name"] = stored_record?.name
	data["record_species"] = stored_record?.dna.species?.name
	data["linked_scanner"] = !!input
	data["scanner_occupant"] = scanner_occupant?.name
	data["scanner_species"] = scanner_occupant?.dna?.species?.name
	data["is_scanning"] = !!input?.scanning
	data["linked_pod"] = !!output
	data["is_cloning"] = !!output?.running
	data["cloning_name"] = output?.loaded_record?.name
	data["cloning_species"] = output?.loaded_record?.dna?.species?.name
	data["cloning_progress"] = output? ((output.cloning_time - cloning_time_left) / output.cloning_time) * 100 : 0

	return data

/obj/machinery/computer/experimental_cloner/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if ("clear_record")
			if (isnull(stored_record))
				return TRUE
			stored_record = null
			playsound(src, 'sound/machines/ping.ogg', vol = 100)
			return TRUE
		if ("start_scan")
			if (isnull(input))
				balloon_alert(ui.user, "no linked scanner!")
				playsound(src, 'sound/machines/buzz/buzz-two.ogg', 50, TRUE)
				return TRUE
			if (isnull(input.occupant))
				balloon_alert(ui.user, "scanner empty!")
				playsound(src, 'sound/machines/buzz/buzz-two.ogg', 50, TRUE)
				return TRUE
			if (!iscarbon(input.occupant))
				balloon_alert(ui.user, "invalid subject!")
				playsound(src, 'sound/machines/buzz/buzz-two.ogg', 50, TRUE)
				return TRUE
			var/mob/living/carbon/carbon_occupant = input.occupant
			if (!carbon_occupant.has_dna())
				balloon_alert(ui.user, "invalid subject!")
				playsound(src, 'sound/machines/buzz/buzz-two.ogg', 50, TRUE)
				return TRUE
			if (input.scanning)
				balloon_alert(ui.user, "scanner busy!")
				playsound(src, 'sound/machines/buzz/buzz-two.ogg', 50, TRUE)
				return TRUE

			log_combat(ui.user, input.occupant, "irradiated via experimental clone scan")
			input.start_scan()
			return TRUE
		if ("start_clone")
			if (isnull(output))
				balloon_alert(ui.user, "no linked pod!")
				playsound(src, 'sound/machines/buzz/buzz-two.ogg', 50, TRUE)
				return TRUE
			if (output.running)
				balloon_alert(ui.user, "pod busy!")
				playsound(src, 'sound/machines/buzz/buzz-two.ogg', 50, TRUE)
				return TRUE
			if (isnull(stored_record))
				balloon_alert(ui.user, "no stored DNA!")
				playsound(src, 'sound/machines/buzz/buzz-two.ogg', 50, TRUE)
				return TRUE

			ui.user.log_message("began growing an experimental clone of [stored_record.name]", LOG_GAME, log_globally = TRUE)
			output.start_cloning(stored_record)
			return TRUE
