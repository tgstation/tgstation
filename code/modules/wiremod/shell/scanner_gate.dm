/obj/structure/scanner_gate_shell
	name = "circuit scanner gate"
	desc = "A gate able to perform mid-depth scans on any organisms who pass under it."
	icon = 'icons/obj/machines/scangate.dmi'
	icon_state = "scangate_black"
	var/locked = FALSE

/obj/structure/scanner_gate_shell/Initialize(mapload)
	. = ..()
	set_scanline("passive")
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_entered,
	)
	AddElement(/datum/element/connect_loc, loc_connections)

	AddComponent(/datum/component/shell, list(
		new /obj/item/circuit_component/scanner_gate()
	), SHELL_CAPACITY_LARGE, SHELL_FLAG_REQUIRE_ANCHOR)

/obj/structure/scanner_gate_shell/wrench_act(mob/living/user, obj/item/tool)
	if(locked)
		return
	set_anchored(!anchored)
	tool.play_tool_sound(src)
	balloon_alert(user, "You [anchored?"secure":"unsecure"] [src].")
	return TRUE

/obj/structure/scanner_gate_shell/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	set_scanline("scanning", 10)
	SEND_SIGNAL(src, COMSIG_SCANGATE_SHELL_PASS, AM)

/obj/structure/scanner_gate_shell/proc/set_scanline(type, duration)
	cut_overlays()
	add_overlay(type)
	if(duration)
		addtimer(CALLBACK(src, .proc/set_scanline, "passive"), duration, TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_STOPPABLE)

/obj/item/circuit_component/scanner_gate
	display_name = "Scanner Gate"
	desc = "A gate able to perform mid-depth scans on any object that pass through it."

	var/datum/port/output/scanned

	var/obj/structure/scanner_gate_shell/attached_gate

/obj/item/circuit_component/scanner_gate/populate_ports()
	scanned = add_output_port("Scanned Object", PORT_TYPE_ATOM)
	trigger_output = add_output_port("Triggered", PORT_TYPE_SIGNAL, order = 2)

/obj/item/circuit_component/scanner_gate/register_shell(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/structure/scanner_gate_shell))
		attached_gate = shell
		RegisterSignal(attached_gate, COMSIG_SCANGATE_SHELL_PASS, .proc/on_trigger)
		RegisterSignal(parent, COMSIG_CIRCUIT_SET_LOCKED, .proc/on_set_locked)
		attached_gate.locked = parent.locked

/obj/item/circuit_component/scanner_gate/unregister_shell(atom/movable/shell)
	UnregisterSignal(attached_gate, COMSIG_SCANGATE_SHELL_PASS)
	if(attached_gate)
		attached_gate.locked = FALSE
		UnregisterSignal(parent, COMSIG_CIRCUIT_SET_LOCKED)
	attached_gate = null
	return ..()

/obj/item/circuit_component/scanner_gate/proc/on_trigger(datum/source, atom/movable/passed)
	SIGNAL_HANDLER
	scanned.set_output(passed)
	trigger_output.set_output(COMPONENT_SIGNAL)

/**
 * Locks the attached bot when the circuit is locked.
 *
 * Arguments:
 * * new_value - A boolean that determines if the circuit is locked or not.
 **/
/obj/item/circuit_component/scanner_gate/proc/on_set_locked(datum/source, new_value)
	SIGNAL_HANDLER
	attached_gate.locked = new_value
