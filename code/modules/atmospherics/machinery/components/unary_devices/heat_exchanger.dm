/obj/machinery/atmospherics/components/unary/heat_exchanger

	icon_state = "he1"

	name = "heat exchanger"
	desc = "Exchanges heat between two input gases. Set up for fast heat transfer."

	can_unwrench = TRUE
	shift_underlay_only = FALSE // not really used

	layer = LOW_OBJ_LAYER

	var/obj/machinery/atmospherics/components/unary/heat_exchanger/partner = null
	var/update_cycle

	pipe_state = "heunary"

/obj/machinery/atmospherics/components/unary/heat_exchanger/layer2
	piping_layer = 2
	icon_state = "he_map-2"

/obj/machinery/atmospherics/components/unary/heat_exchanger/layer4
	piping_layer = 4
	icon_state = "he_map-4"

/obj/machinery/atmospherics/components/unary/heat_exchanger/update_icon_state()
	icon_state = "he[nodes[1] ? 1 : 0]"
	return ..()

/obj/machinery/atmospherics/components/unary/heat_exchanger/update_icon()
	. = ..()
	if(nodes[1])
		var/obj/machinery/atmospherics/node = nodes[1]
		add_atom_colour(node.color, FIXED_COLOUR_PRIORITY)
	PIPING_LAYER_SHIFT(src, piping_layer)

/obj/machinery/atmospherics/components/unary/heat_exchanger/atmosinit()
	if(!partner)
		var/partner_connect = turn(dir,180)

		for(var/obj/machinery/atmospherics/components/unary/heat_exchanger/target in get_step(src,partner_connect))
			if(target.dir & get_dir(src,target))
				partner = target
				partner.partner = src
				break

	..()

/obj/machinery/atmospherics/components/unary/heat_exchanger/process_atmos()
	..()
	if(!partner || SSair.times_fired <= update_cycle)
		return

	update_cycle = SSair.times_fired
	partner.update_cycle = SSair.times_fired

	var/datum/gas_mixture/air_contents = airs[1]
	var/datum/gas_mixture/partnerair_contents = partner.airs[1]

	var/air_heat_capacity = air_contents.heat_capacity()
	var/other_air_heat_capacity = partnerair_contents.heat_capacity()
	var/combined_heat_capacity = other_air_heat_capacity + air_heat_capacity

	var/old_temperature = air_contents.temperature
	var/other_old_temperature = partnerair_contents.temperature

	if(old_temperature > 1e7)
		if(try_to_melt(old_temperature))
			melt()
			return PROCESS_KILL //we melting anyway, let's stop processing

	if(combined_heat_capacity > 0)
		var/combined_energy = partnerair_contents.temperature*other_air_heat_capacity + air_heat_capacity*air_contents.temperature

		var/new_temperature = combined_energy/combined_heat_capacity
		air_contents.temperature = new_temperature
		partnerair_contents.temperature = new_temperature

	if(abs(old_temperature-air_contents.temperature) > 1)
		update_parents()

	if(abs(other_old_temperature-partnerair_contents.temperature) > 1)
		partner.update_parents()

///Check if the exchanger can melt under the heat
/obj/machinery/atmospherics/components/unary/heat_exchanger/proc/try_to_melt(temperature)
	if(prob(log(6, temperature) * 10)) //~80% at 1e7, 100% at 1e8
		return TRUE
	return FALSE

///Releases the gases stored inside and delete the object
/obj/machinery/atmospherics/components/unary/heat_exchanger/proc/melt()
	var/datum/gas_mixture/internal_gas = airs[1]
	if(internal_gas)
		loc.assume_air(internal_gas.remove_ratio(1))
	qdel(src)
