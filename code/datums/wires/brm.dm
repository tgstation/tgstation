/datum/wires/brm
	holder_type = /obj/machinery/brm
	proper_name = "Boulder Retrieval Matrix"

/datum/wires/brm/New(atom/holder)
	add_duds(1)
	return ..()

/datum/wires/brm/on_pulse(wire)
	var/obj/machinery/brm/brm_holder = holder
	if(brm_holder.panel_open)
		return
	brm_holder.toggle_auto_on()

