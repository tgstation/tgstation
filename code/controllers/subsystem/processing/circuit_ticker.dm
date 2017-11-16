PROCESSING_SUBSYSTEM_DEF(circuit_ticker)
	name = "Circuit Ticker"
	stat_tag = "CTS"
	priority = 25
	wait = 1
	flags = SS_NO_INIT | SS_KEEP_TIMING
	var/iteration = 1
	var/itermax = 120	//LCM of all integrated_circuit/time/ticker tick_delays.
	var/list/datum/iopulse/current_pulses = list()

/datum/controller/subsystem/processing/circuit_ticker/fire(resumed = FALSE)
	if(++iteration > itermax)
		iteration = 1
	. = ..()
	for(var/i in current_pulses)
		var/datum/iopulse/pulse = current_pulses[i]
		if(pulse.dereference_time > world.time)
			current_pulses -= pulse
			for(var/v in pulse.referencing)
				var/obj/item/integrated_circuit/I = pulse.referencing[v]
				if(I.last_iopulse == pulse)
					I.last_iopulse = null
				else
					stack_trace("Mismatched last pulse on [I.type]!")

/datum/controller/subsystem/processing/circuit_ticker/proc/get_iopulse()
	var/i = iteration
	if(!current_pulses["[i]"])
		current_pulses["[i]"] = new /datum/iopulse(i)
	return current_pulses["[i]"]
