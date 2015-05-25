/obj/machinery/atmospherics/unary/heat_exchanger

	icon = 'icons/obj/atmospherics/heat_exchanger.dmi'
	icon_state = "intact"
	density = 1

	name = "heat exchanger"
	desc = "Exchanges heat between two input gases. Setup for fast heat transfer"

	can_unwrench = 1

	var/obj/machinery/atmospherics/unary/heat_exchanger/partner = null
	var/update_cycle

/obj/machinery/atmospherics/unary/heat_exchanger/update_icon()
	if(node)
		icon_state = "intact"
	else
		icon_state = "exposed"

	return

/obj/machinery/atmospherics/unary/heat_exchanger/atmosinit()
	if(!partner)
		var/partner_connect = turn(dir,180)

		for(var/obj/machinery/atmospherics/unary/heat_exchanger/target in get_step(src,partner_connect))
			if(target.dir & get_dir(src,target))
				partner = target
				partner.partner = src
				break

	..()

/obj/machinery/atmospherics/unary/heat_exchanger/process_atmos()
	..()
	if(!partner)
		return 0

	if(SSair.times_fired <= update_cycle)
		return 0

	update_cycle = SSair.times_fired
	partner.update_cycle = SSair.times_fired

	var/air_heat_capacity = air_contents.heat_capacity()
	var/other_air_heat_capacity = partner.air_contents.heat_capacity()
	var/combined_heat_capacity = other_air_heat_capacity + air_heat_capacity

	var/old_temperature = air_contents.temperature
	var/other_old_temperature = partner.air_contents.temperature

	if(combined_heat_capacity > 0)
		var/combined_energy = partner.air_contents.temperature*other_air_heat_capacity + air_heat_capacity*air_contents.temperature

		var/new_temperature = combined_energy/combined_heat_capacity
		air_contents.temperature = new_temperature
		partner.air_contents.temperature = new_temperature

	if(abs(old_temperature-air_contents.temperature) > 1)
		parent.update = 1

	if(abs(other_old_temperature-partner.air_contents.temperature) > 1)
		partner.parent.update = 1

	return 1
