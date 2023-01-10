/obj/machinery/plumbing/disposer
	name = "chemical disposer"
	desc = "Breaks down chemicals and annihilates them."
	icon_state = "disposal"
	pass_flags_self = PASSMACHINE | LETPASSTHROW // Small
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 2
	///category for plumbing RCD
	category="Synthesizers"

	///we remove 5 reagents per second
	var/disposal_rate = 5

/obj/machinery/plumbing/disposer/Initialize(mapload, bolt, layer)
	. = ..()
	AddComponent(/datum/component/plumbing/simple_demand, bolt, layer)

/obj/machinery/plumbing/disposer/process(delta_time)
	if(machine_stat & NOPOWER)
		return
	if(reagents.total_volume)
		if(icon_state != initial(icon_state) + "_working") //threw it here instead of update icon since it only has two states
			icon_state = initial(icon_state) + "_working"
		reagents.remove_any(disposal_rate * delta_time)
		use_power(active_power_usage * delta_time)
	else
		if(icon_state != initial(icon_state))
			icon_state = initial(icon_state)

