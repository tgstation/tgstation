#define GRAVITY_ENERGY 100000 JOULES

/obj/machinery/power/energy_accumulator/gravity_generator
	name = "gravity generator"
	desc = "This takes power from the gravitational pull of a singularity."
	icon = 'icons/obj/machines/engine/tesla_coil.dmi'
	icon_state = "coil0"
	var/input_power_multiplier = 1

/obj/machinery/power/energy_accumulator/gravity_generator/singularity_pull()
	stored_energy += GRAVITY_ENERGY * input_power_multiplier
	return

/obj/machinery/power/energy_accumulator/gravity_generator/RefreshParts()
	. = ..()

/obj/machinery/power/energy_accumulator/gravity_generator/RefreshParts()
	. = ..()
	var/power_multiplier = 0
	for(var/datum/stock_part/capacitor/capacitor in component_parts)
		power_multiplier += capacitor.tier
	input_power_multiplier = power_multiplier

/obj/machinery/power/energy_accumulator/gravity_generator/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += span_notice("The status display reads:<br>" + \
			"Stored <b>[display_energy(get_stored_joules())]</b>.<br>" + \
			"Processing <b>[display_power(processed_energy)]</b>.")
/obj/machinery/power/energy_accumulator/gravity_generator/anchored
	anchored = TRUE

/obj/machinery/power/energy_accumulator/gravity_generator/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/power/energy_accumulator/gravity_generator/attackby(obj/item/W, mob/user, params)
	if(default_deconstruction_screwdriver(user, "coil_open[anchored]", "coil[anchored]", W))
		return

	if(default_deconstruction_crowbar(W))
		return

	if(is_wire_tool(W) && panel_open)
		wires.interact(user)
		return

	return ..()
