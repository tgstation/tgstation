/// Computer which starts the experimental cloning process
/obj/machinery/computer/experimental_cloner
	name = "experimental cloner control console"
	desc = "It scans DNA structures."
	circuit = /obj/item/circuitboard/computer/experimental_cloner
	icon_screen = "crew"
	icon_keyboard = "med_key"
	light_color = LIGHT_COLOR_GREEN
	/// Our current stored cloning record
	var/datum/experimental_cloning_record/stored_record
	/// Scanner we save a test subject from
	var/obj/machinery/experimental_cloner_scanner/input
	/// Pod we print someone into
	var/obj/machinery/experimental_cloner/output

/obj/machinery/computer/experimental_cloner/Initialize(mapload, obj/item/circuitboard/circuit)
	. = ..()
	if (!mapload)
		return

	var/list/stuff_in_range = view(7, src)

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
		to_chat(user, span_notice("You link \the [multi_tool.buffer] with \the [src]."))
		return ITEM_INTERACT_SUCCESS
	if (istype(multi_tool.buffer, /obj/machinery/experimental_cloner))
		unlink_pod()
		link_pod(multi_tool.buffer)
		to_chat(user, span_notice("You link \the [multi_tool.buffer] with \the [src]."))
		return ITEM_INTERACT_SUCCESS

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
	output = null
