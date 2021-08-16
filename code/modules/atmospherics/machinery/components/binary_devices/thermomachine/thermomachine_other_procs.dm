///Check if the temperature inside the machine is high enough to cause it to explode
/obj/machinery/atmospherics/components/binary/thermomachine/proc/check_explosion(temperature)
	if(temperature < THERMOMACHINE_SAFE_TEMPERATURE + 2000)
		return FALSE
	if(prob(log(6, temperature) * 10)) //75% at 500000, 100% at 1e8
		return TRUE

///Explode the machine and releases the gases
/obj/machinery/atmospherics/components/binary/thermomachine/proc/explode()
	explosion(loc, 0, 0, 3, 3, TRUE)
	var/datum/gas_mixture/main_port = airs[1]
	var/datum/gas_mixture/exchange_target = airs[2]
	if(main_port)
		loc.assume_air(main_port.remove_ratio(1))
	if(exchange_target)
		loc.assume_air(exchange_target.remove_ratio(1))
	qdel(src)
