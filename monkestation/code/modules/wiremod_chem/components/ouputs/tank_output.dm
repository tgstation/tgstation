/obj/structure/chemical_tank
	name = "remote chemical tank"
	desc = "A chemical tank that can be remotely connected to the chemical manufacturer."

	max_integrity = 2500

	icon = 'monkestation/code/modules/wiremod_chem/icons/structures.dmi'
	icon_state = "tank_output"

	density = TRUE
	var/obj/item/circuit_component/chem/output/linked_output
	var/reagent_flags = TRANSPARENT | DRAINABLE
	var/buffer = 500
	var/component_name = "Tank Output"

/obj/structure/chemical_tank/attackby(obj/item/attacking_item, mob/user, params)
	if(attacking_item.tool_behaviour == TOOL_WRENCH)
		if(attacking_item.use_tool(src, user, 40, volume=75))
			to_chat(user, span_notice("You [anchored ? "un" : ""]secure [src]."))
			set_anchored(!anchored)
			return
	. = ..()

/obj/structure/chemical_tank/Initialize(mapload)
	. = ..()
	create_reagents(buffer, reagent_flags)

/obj/structure/chemical_tank/examine(mob/user)
	. = ..()
	. += span_notice("The maximum volume display reads: <b>[reagents.maximum_volume] units</b>.")
	if(linked_output)
		. += span_notice("Is connected to an output device.")

/obj/structure/chemical_tank/AltClick(mob/user)
	. = ..()
	if(!linked_output)
		linked_output = new(src.loc)
		linked_output.chemical_tank = src
		linked_output.name = component_name
		linked_output.display_name = component_name

/obj/structure/chemical_tank/proc/after_reagent_add()
	return

/obj/structure/chemical_tank/plunger_act(obj/item/plunger/P, mob/living/user, reinforced)
	to_chat(user, span_notice("You start furiously plunging [name]."))
	if(do_after(user, 30, target = src))
		to_chat(user, span_notice("You finish plunging the [name]."))
		reagents.expose(get_turf(src), TOUCH) //splash on the floor
		reagents.clear_reagents()

/obj/item/circuit_component/chem/output
	display_name = "Tank Output"
	desc = "Linked to a physical object, sends the chemicals to the tank."

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL
	ui_buttons = list(
		"plus" = "add",
		"minus" = "remove"
	)

	var/list/chemical_inputs
	var/datum/port/input/heat_input

	var/obj/structure/chemical_tank/chemical_tank

/obj/item/circuit_component/chem/output/populate_ports()
	chemical_inputs = list()
	AddComponent(/datum/component/circuit_component_add_port, \
		port_list = chemical_inputs, \
		add_action = "add", \
		remove_action = "remove", \
		port_type = PORT_TYPE_CHEMICAL_LIST, \
		prefix = "Chemical Input", \
		minimum_amount = 2 \
	)
	heat_input = add_input_port("Desired Heat", PORT_TYPE_NUMBER, default = 275)


/obj/item/circuit_component/chem/output/input_received(datum/port/input/port, list/return_values)
	if(!chemical_tank)
		return

	var/list/ports = chemical_inputs.Copy()
	var/list/chemical_list = list()
	var/sane_heat = clamp(heat_input.value, 4, 1000)

	for(var/datum/port/input/input_port as anything in ports)
		if(isnull(input_port.value))
			continue
		chemical_list += input_port.value

	chemical_tank.reagents.add_reagent_list(chemical_list, temperature = sane_heat)
	chemical_tank.after_reagent_add()

/obj/item/circuit_component/chem/output/after_work_call()
	clear_all_temp_ports()

/obj/item/circuit_component/chem/output/clear_all_temp_ports()
	for(var/datum/port/input/input as anything in chemical_inputs)
		input.value = null

