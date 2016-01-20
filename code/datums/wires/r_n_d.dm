/datum/wires/r_n_d
	var/const/W_HACK = "hack" // Hacks the machine.
	var/const/W_DISABLE = "disable" // Disables the machine.
	var/const/W_SHOCK = "shock" // Shocks the user, 50% chance

	holder_type = /obj/machinery/r_n_d
	randomize = 1

/datum/wires/r_n_d/New(atom/holder)
	wires = list(
		W_HACK, W_DISABLE,
		W_SHOCK
	)
	add_duds(5)
	..()

/datum/wires/r_n_d/interactable(mob/user)
	var/obj/machinery/r_n_d/R = holder
	if(R.panel_open)
		return TRUE

/datum/wires/r_n_d/get_status()
	var/obj/machinery/r_n_d/R = holder
	var/list/status = list()
	status.Add("The red light is [R.disabled ? "off" : "on"].")
	status.Add("The green light is [R.shocked ? "off" : "on"].")
	status.Add("The blue light is [R.hacked ? "off" : "on"].")
	return status

/datum/wires/r_n_d/on_pulse(wire)
	var/obj/machinery/r_n_d/R = holder
	switch(wire)
		if(W_HACK)
			R.hacked = !R.hacked
		if(W_DISABLE)
			R.disabled = !R.disabled
		if(W_SHOCK)
			R.shocked = TRUE
			spawn(100)
				if(R)
					R.shocked = FALSE

/datum/wires/r_n_d/on_cut(wire, mend)
	var/obj/machinery/r_n_d/R = holder
	switch(wire)
		if(W_HACK)
			R.hacked = !mend
		if(W_DISABLE)
			R.disabled = !mend
		if(W_SHOCK)
			R.shocked = !mend
