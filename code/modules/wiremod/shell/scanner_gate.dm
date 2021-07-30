
/obj/machinery/scanner_gate/circuit
	name = "circuit scanner gate"
	icon_state = "scangate_black"

/obj/machinery/scanner_gate/circuit/Initialize()
	. = ..()
	AddComponent(/datum/component/shell, list(
		new /obj/item/circuit_component/scanner_gate()
	), SHELL_CAPACITY_LARGE)

/obj/item/circuit_component/scanner_gate
	display_name = "Scanner Gate"
	display_desc = "A gate able to perform mid-depth scans on any organisms who pass under it."

	var/datum/port/output/scanned_mob

	///When it triggers and when it does not
	var/datum/port/output/scan_successfull
	var/datum/port/output/scan_not_successfull

	var/obj/machinery/scanner_gate/attached_gate

/obj/item/circuit_component/scanner_gate/Initialize()
	. = ..()
	scanned_mob = add_output_port("Scanned Mob", PORT_TYPE_ATOM)
	scan_successfull = add_output_port("On Found", PORT_TYPE_SIGNAL)
	scan_not_successfull = add_output_port("On Not Found", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/scanner_gate/register_shell(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/machinery/scanner_gate))
		attached_gate = shell
		RegisterSignal(attached_gate, COMSIG_SCANGATE_PASS_TRIGGER, .proc/on_trigger)
		RegisterSignal(attached_gate, COMSIG_SCANGATE_PASS_NO_TRIGGER, .proc/on_no_trigger)

/obj/item/circuit_component/scanner_gate/unregister_shell(atom/movable/shell)
	UnregisterSignal(attached_gate, list(COMSIG_SCANGATE_PASS_TRIGGER, COMSIG_SCANGATE_PASS_NO_TRIGGER))
	attached_gate = null
	return ..()

/obj/item/circuit_component/scanner_gate/proc/on_trigger(mob/target)
	SIGNAL_HANDLER

	scanned_mob.set_output(target)
	scan_successfull.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/scanner_gate/proc/on_no_trigger(mob/target)
	SIGNAL_HANDLER

	scanned_mob.set_output(target)
	scan_not_successfull.set_output(COMPONENT_SIGNAL)
