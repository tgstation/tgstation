/obj/structure/chemical_manufacturer
	name = "chemical manufacturer"
	desc = "A state of the art machine that utilizes chemical precursors as well as circuitry to mix chemicals."

	icon = 'monkestation/code/modules/wiremod_chem/icons/structures.dmi'
	icon_state = "manufacturer"

	max_integrity = 2500

	density = TRUE

	///the tank we pull chemicals from
	var/obj/item/precursor_tank/connected_tank

	var/obj/item/circuit_component/chem/output_manufacturer/linked_output
	var/reagent_flags = TRANSPARENT | DRAINABLE
	var/buffer = 500
	var/recharge_counter = 0

/obj/structure/chemical_manufacturer/attackby(obj/item/attacking_item, mob/user, params)
	if(attacking_item.tool_behaviour == TOOL_WRENCH)
		if(attacking_item.use_tool(src, user, 40, volume=75))
			to_chat(user, span_notice("You [anchored ? "un" : ""]secure [src]."))
			set_anchored(!anchored)
			return
	. = ..()

/obj/structure/chemical_manufacturer/process(seconds_per_tick)
	var/obj/item/integrated_circuit/attached_circuit = locate(/obj/item/integrated_circuit) in contents
	if(!attached_circuit || !attached_circuit?.cell)
		return
	if (recharge_counter >= 2)
		var/usedpower = attached_circuit.cell.give(attached_circuit.cell.maxcharge - attached_circuit.cell.charge) // we refill every process this goes hard af
		if(usedpower)
			var/amount = max(usedpower, 0) // make sure we don't use negative power
			var/area/A = get_area(src) // make sure it's in an area
			A?.use_power(amount, AREA_USAGE_EQUIP)
		recharge_counter = 0
		return
	recharge_counter += seconds_per_tick

/obj/structure/chemical_manufacturer/Initialize(mapload)
	. = ..()
	create_reagents(buffer, reagent_flags)
	START_PROCESSING(SSmachines, src)
	AddComponent( \
		/datum/component/shell, \
		unremovable_circuit_components = list(new /obj/item/circuit_component/chem/output_manufacturer), \
		capacity = SHELL_CAPACITY_VERY_LARGE, \
		shell_flags = SHELL_FLAG_USB_PORT, \
	)

/obj/structure/chemical_manufacturer/proc/has_precursor(amount)
	if(!connected_tank)
		return FALSE
	if(connected_tank.stored_precursor < amount)
		return FALSE
	return TRUE

/obj/structure/chemical_manufacturer/proc/process_precursor(amount)
	if(!connected_tank)
		return FALSE
	connected_tank.stored_precursor -= min(connected_tank.stored_precursor, amount)

/obj/structure/chemical_manufacturer/proc/remove_tank()
	if(!connected_tank)
		return
	connected_tank.forceMove(src.loc)
	connected_tank = null

/obj/structure/chemical_manufacturer/proc/replace_tank(obj/item/precursor_tank/incoming_tank, mob/user)
	remove_tank()
	user.dropItemToGround(incoming_tank)
	incoming_tank.forceMove(src)
	connected_tank = incoming_tank

/obj/structure/chemical_manufacturer/attackby(obj/item/attacking_item, mob/user, params)
	if(istype(attacking_item, /obj/item/precursor_tank))
		replace_tank(attacking_item, user)
		return
	return ..()

/obj/structure/chemical_manufacturer/AltClick(mob/user)
	. = ..()
	remove_tank()

/obj/structure/chemical_manufacturer/plunger_act(obj/item/plunger/P, mob/living/user, reinforced)
	to_chat(user, span_notice("You start furiously plunging [name]."))
	if(do_after(user, 30, target = src))
		to_chat(user, span_notice("You finish plunging the [name]."))
		reagents.expose(get_turf(src), TOUCH) //splash on the floor
		reagents.clear_reagents()

/obj/item/circuit_component/chem/output_manufacturer
	display_name = "Manufacturer Output"
	desc = "Linked to a physical object, sends the chemicals to the tank."

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL
	ui_buttons = list(
		"plus" = "add",
		"minus" = "remove"
	)

	var/list/chemical_inputs
	var/datum/port/input/heat_input

	var/obj/structure/chemical_manufacturer/chemical_tank

/obj/item/circuit_component/chem/output_manufacturer/populate_ports()
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


/obj/item/circuit_component/chem/output_manufacturer/input_received(datum/port/input/port, list/return_values)
	if(heat_input.value == 0)
		heat_input.value = 275

	if(!chemical_tank)
		chemical_tank = parent.shell
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

/obj/item/circuit_component/chem/output_manufacturer/after_work_call()
	clear_all_temp_ports()

/obj/item/circuit_component/chem/output_manufacturer/clear_all_temp_ports()
	for(var/datum/port/input/input as anything in chemical_inputs)
		input.value = null
