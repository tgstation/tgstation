/obj/machinery/atmospherics/components/unary/heat_exchanger

	icon_state = "he_intact"

	name = "heat exchanger"
	desc = "Exchanges heat between two input gases. Setup for fast heat transfer"

	can_unwrench = 1

	layer = LOW_OBJ_LAYER

	var/obj/machinery/atmospherics/components/unary/heat_exchanger/partner = null
	var/update_cycle

/obj/machinery/atmospherics/components/unary/heat_exchanger/update_icon()
	if(NODE1)
		icon_state = "he_intact"
		var/obj/machinery/atmospherics/node = NODE1
		add_atom_colour(node.color, FIXED_COLOUR_PRIORITY)
	else
		icon_state = "he_exposed"

	return

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
	if(!partner)
		return 0

	if(SSair.times_fired <= update_cycle)
		return 0

	update_cycle = SSair.times_fired
	partner.update_cycle = SSair.times_fired

	var/datum/gas_mixture/air_contents = AIR1
	var/datum/gas_mixture/partner_air_contents = partner.AIR1

	var/air_heat_capacity = air_contents.heat_capacity()
	var/other_air_heat_capacity = partner_air_contents.heat_capacity()
	var/combined_heat_capacity = other_air_heat_capacity + air_heat_capacity

	var/old_temperature = air_contents.temperature
	var/other_old_temperature = partner_air_contents.temperature

	if(combined_heat_capacity > 0)
		var/combined_energy = partner_air_contents.temperature*other_air_heat_capacity + air_heat_capacity*air_contents.temperature

		var/new_temperature = combined_energy/combined_heat_capacity
		air_contents.temperature = new_temperature
		partner_air_contents.temperature = new_temperature

	if(abs(old_temperature-air_contents.temperature) > 1)
		update_parents()

	if(abs(other_old_temperature-partner_air_contents.temperature) > 1)
		partner.update_parents()

	return 1
