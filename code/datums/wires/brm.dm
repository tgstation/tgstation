/datum/wires/brm
	holder_type = /obj/machinery/bouldertech/brm
	proper_name = "Boulder Retrieval Matrix"

/datum/wires/brm/New(atom/holder)
	add_duds(1)
	..()

/datum/wires/brm/on_pulse(wire)
	var/obj/machinery/bouldertech/brm/brm_holder = holder
	if(brm_holder.panel_open)
		return
	brm_holder.toggle_auto_on()

/datum/wires/brm/interactable(mob/user)
	if(!..())
		return FALSE
	return TRUE
