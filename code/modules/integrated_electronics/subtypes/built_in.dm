/obj/item/integrated_circuit/built_in
	name = "integrated circuit"
	desc = "It's a tiny chip!  This one doesn't seem to do much, however."
	icon = 'icons/obj/electronic_assemblies.dmi'
	icon_state = "template"
	size = -1
	w_class = WEIGHT_CLASS_TINY
	removable = FALSE 			// Determines if a circuit is removable from the assembly.

/obj/item/integrated_circuit/built_in/device_input
	name = "assembly input"
	desc = "A built in chip for handling pulses from attached assembly items."
	complexity = 0 				//This acts as a limitation on building machines, more resource-intensive components cost more 'space'.
	activators = list("on pulsed" = IC_PINTYPE_PULSE_OUT)

/obj/item/integrated_circuit/built_in/device_input/do_work()
	activate_pin(1)

/obj/item/integrated_circuit/built_in/device_output
	name = "assembly out"
	desc = "A built in chip for pulsing attached assembly items."
	complexity = 0 				//This acts as a limitation on building machines, more resource-intensive components cost more 'space'.
	activators = list("pulse attached" = IC_PINTYPE_PULSE_IN)

/obj/item/integrated_circuit/built_in/device_output/do_work()
	if(istype(assembly, /obj/item/device/electronic_assembly/device))
		var/obj/item/device/electronic_assembly/device/device = assembly
		device.holder.pulse()