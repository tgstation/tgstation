/obj/structure/chemical_input
	name = "remote chemical input tank"
	desc = "A chemical tank that can be remotely connected to the chemical manufacturer to send chemicals."

	max_integrity = 2500

	icon = 'monkestation/code/modules/wiremod_chem/icons/structures.dmi'
	icon_state = "tank_input"

	density = TRUE
	var/obj/item/circuit_component/chem/input/linked_input
	var/reagent_flags = TRANSPARENT | REFILLABLE | DRAINABLE
	var/buffer = 500
	var/component_name = "Tank Input"

/obj/structure/chemical_tank/attackby(obj/item/attacking_item, mob/user, params)
	if(attacking_item.tool_behaviour == TOOL_WRENCH)
		if(attacking_item.use_tool(src, user, 40, volume=75))
			to_chat(user, span_notice("You [anchored ? "un" : ""]secure [src]."))
			set_anchored(!anchored)
			return
	. = ..()

/obj/structure/chemical_input/Initialize(mapload)
	. = ..()
	create_reagents(buffer, reagent_flags)

/obj/structure/chemical_input/plunger_act(obj/item/plunger/P, mob/living/user, reinforced)
	to_chat(user, span_notice("You start furiously plunging [name]."))
	if(do_after(user, 30, target = src))
		to_chat(user, span_notice("You finish plunging the [name]."))
		reagents.expose(get_turf(src), TOUCH) //splash on the floor
		reagents.clear_reagents()

/obj/structure/chemical_input/AltClick(mob/user)
	. = ..()
	if(!linked_input)
		linked_input = new(src.loc)
		linked_input.linked_input = src
		linked_input.name = component_name

/obj/structure/chemical_input/examine(mob/user)
	. = ..()
	. += span_notice("The maximum volume display reads: <b>[reagents.maximum_volume] units</b>.")
	if(linked_input)
		. += span_notice("Is connected to an input device.")

/obj/item/circuit_component/chem/input
	display_name = "Tank Input"
	desc = "Linked to a physical object, pulls the chemicals from the tank."

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL

	var/datum/port/output/chemical_output
	/// The heat read from the input device
	var/datum/port/output/chem_heat
	///our linked input we check if we can send signals from here
	var/obj/structure/chemical_input/linked_input
	///our input that dictates how much we pull out
	var/datum/port/input/units

	var/datum/reagents/reagent_holder


/obj/item/circuit_component/chem/input/populate_ports()
	chemical_output = add_output_port("Chemical Output", PORT_TYPE_CHEMICAL_LIST)
	chem_heat = add_output_port("Chemical Heat", PORT_TYPE_NUMBER)
	units = add_input_port("Units", PORT_TYPE_NUMBER)

/obj/item/circuit_component/chem/input/input_received(datum/port/input/port, list/return_values)
	if(!reagent_holder)
		reagent_holder = new(10000)
		reagent_holder.my_atom = src

	if(!linked_input || !linked_input.reagents.total_volume)
		return
	if(!units.value)
		return

	var/read_heat = linked_input.reagents.chem_temp

	linked_input.reagents.trans_to(reagent_holder, units.value)

	var/list/built_output = list()
	for(var/datum/reagent/reagent as anything in reagent_holder.reagent_list)
		built_output += reagent.type
		built_output[reagent.type] += reagent.volume

	chemical_output.set_output(built_output)
	chem_heat.set_output(read_heat)
	reagent_holder.remove_all(10000)

/obj/item/circuit_component/chem/input/after_work_call()
	clear_all_temp_ports()

/obj/item/circuit_component/chem/input/clear_all_temp_ports()
	chemical_output.value = null
	chem_heat.value = null
