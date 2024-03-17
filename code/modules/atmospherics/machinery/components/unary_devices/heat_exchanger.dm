/obj/machinery/atmospherics/components/unary/heat_exchanger

	icon_state = "he1"

	name = "heat exchanger"
	desc = "Exchanges heat between two input gases. Set up for fast heat transfer."

	can_unwrench = TRUE
	shift_underlay_only = FALSE // not really used

	layer = LOW_OBJ_LAYER

	var/datum/weakref/partner_ref = null
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

/obj/machinery/atmospherics/components/unary/heat_exchanger/atmos_init()
	var/obj/machinery/atmospherics/components/unary/heat_exchanger/partner = partner_ref?.resolve()
	if(!partner)
		partner_ref = null
		var/partner_connect = REVERSE_DIR(dir)

		for(var/obj/machinery/atmospherics/components/unary/heat_exchanger/target in get_step(src,partner_connect))
			if(target.dir & get_dir(src,target))
				partner_ref = WEAKREF(target)
				target.partner_ref = WEAKREF(src)
				break

	. = ..()

/obj/machinery/atmospherics/components/unary/heat_exchanger/process_atmos()
	var/obj/machinery/atmospherics/components/unary/heat_exchanger/partner = partner_ref?.resolve()
	if(!partner)
		partner_ref = null
		return
	if(SSair.times_fired <= update_cycle)
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

	if(combined_heat_capacity > 0)
		var/combined_energy = partnerair_contents.temperature * other_air_heat_capacity + air_heat_capacity * air_contents.temperature

		var/new_temperature = combined_energy / combined_heat_capacity
		air_contents.temperature = new_temperature
		partnerair_contents.temperature = new_temperature

	if(abs(old_temperature - air_contents.temperature) > 1)
		update_parents()

	if(abs(other_old_temperature - partnerair_contents.temperature) > 1)
		partner.update_parents()
