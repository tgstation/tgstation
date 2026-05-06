/**
 * USB wiremod interface for emitter machines
 */
/obj/item/circuit_component/emitter
	display_name = "Emitter"
	desc = "Allows you to manually fire and get the ready status of an emitter. Must be unlocked to use fired signal."

	///Manually trigger the emitter
	var/datum/port/input/fire

	///Send a signal when the emitter is turned on
	var/datum/port/output/turned_on
	///Send a signal when the emitter is turned off
	var/datum/port/output/turned_off
	///Send a signal when the emitter has fired
	var/datum/port/output/has_fired

	///The component parent object
	var/obj/machinery/power/emitter/attached_emitter

/obj/item/circuit_component/emitter/populate_ports()
	fire = add_input_port("Fire", PORT_TYPE_SIGNAL, trigger = PROC_REF(fire_emitter))

	turned_on = add_output_port("Turned On", PORT_TYPE_SIGNAL)
	turned_off = add_output_port("Turned Off", PORT_TYPE_SIGNAL)
	has_fired = add_output_port("Has Fired", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/emitter/register_usb_parent(atom/movable/parent)
	. = ..()
	if(istype(parent, /obj/machinery/power/emitter))
		attached_emitter = parent
		RegisterSignal(attached_emitter, COMSIG_EMITTER_MACHINE_SET_ON, PROC_REF(handle_emitter_activation))
		RegisterSignal(attached_emitter, COMSIG_EMITTER_MACHINE_ON_FIRE, PROC_REF(handle_emitter_on_fire))

/obj/item/circuit_component/emitter/unregister_usb_parent(atom/movable/parent)
	UnregisterSignal(attached_emitter, COMSIG_EMITTER_MACHINE_SET_ON)
	UnregisterSignal(attached_emitter, COMSIG_EMITTER_MACHINE_ON_FIRE)
	attached_emitter = null
	return ..()

/obj/item/circuit_component/emitter/proc/handle_emitter_activation(datum/source, active)
	SIGNAL_HANDLER
	if(active)
		turned_on.set_output(COMPONENT_SIGNAL)
	else
		turned_off.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/emitter/proc/handle_emitter_on_fire(datum/source, active)
	SIGNAL_HANDLER
	has_fired.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/emitter/proc/fire_emitter()
	CIRCUIT_TRIGGER
	if(!attached_emitter)
		return
	if(attached_emitter.locked) // do not fire if emitter is locked
		return
	attached_emitter.fire_beam_pulse()
