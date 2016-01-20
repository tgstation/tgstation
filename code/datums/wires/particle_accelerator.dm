/datum/wires/particle_accelerator/control_box
	var/const/W_POWER = "power" // Toggles whether the PA is on or not.
	var/const/W_STRENGTH = "strength" // Determines the strength of the PA.
	var/const/W_LIMIT = "limit" // Determines how strong the PA can be.
	var/const/W_INTERFACE = "interface" // Determines the interface showing up.

	holder_type = /obj/machinery/particle_accelerator/control_box

/datum/wires/particle_accelerator/control_box/New(atom/holder)
	wires = list(
		W_POWER, W_STRENGTH, W_LIMIT,
		W_INTERFACE
	)
	add_duds(2)
	..()

/datum/wires/particle_accelerator/control_box/interactable(mob/user)
	var/obj/machinery/particle_accelerator/control_box/C = holder
	if(C.construction_state == 2)
		return TRUE

/datum/wires/particle_accelerator/control_box/on_pulse(wire)
	var/obj/machinery/particle_accelerator/control_box/C = holder
	switch(wire)
		if(W_POWER)
			C.toggle_power()
		if(W_STRENGTH)
			C.add_strength()
		if(W_INTERFACE)
			C.interface_control = !C.interface_control
		if(W_LIMIT)
			C.visible_message("\icon[C]<b>[C]</b> makes a large whirring noise.")

/datum/wires/particle_accelerator/control_box/on_cut(wire, mend)
	var/obj/machinery/particle_accelerator/control_box/C = holder
	switch(wire)
		if(W_POWER)
			if(C.active == !mend)
				C.toggle_power()
		if(W_STRENGTH)
			for(var/i = 1; i < 3; i++)
				C.remove_strength()
		if(W_INTERFACE)
			if(!mend)
				C.interface_control = FALSE
		if(W_LIMIT)
			C.strength_upper_limit = (mend ? 2 : 3)
			if(C.strength_upper_limit < C.strength)
				C.remove_strength()