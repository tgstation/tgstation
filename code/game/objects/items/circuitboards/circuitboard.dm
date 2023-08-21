//File with the circuitboard and circuitboard/machine class definitions and procs


// Circuitboard

/obj/item/circuitboard
	name = "circuit board"
	/// extension that is applied after the initial name AKA (Computer/Machine Board)
	var/name_extension = null
	icon = 'icons/obj/assemblies/module.dmi'
	icon_state = "circuit_map"
	inhand_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	custom_materials = list(/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT)
	w_class = WEIGHT_CLASS_SMALL
	grind_results = list(/datum/reagent/silicon = 20)
	greyscale_colors = CIRCUIT_COLOR_GENERIC
	var/build_path = null
	///determines if the circuit board originated from a vendor off station or not.
	var/onstation = TRUE
	///determines if the board requires specific levels of parts. (ie specifically a femto menipulator vs generic manipulator)
	var/specific_parts = FALSE

/obj/item/circuitboard/Initialize(mapload)
	if(name_extension)
		name = "[initial(name)] [name_extension]"
	if(icon_state == "circuit_map") // some circuitboards have cool custom sprites
		set_greyscale(new_config = /datum/greyscale_config/circuit)
	return ..()

/obj/item/circuitboard/proc/apply_default_parts(obj/machinery/machine)
	if(LAZYLEN(machine.component_parts))
		// This really shouldn't happen. If it somehow does, print out a stack trace and gracefully handle it.
		stack_trace("apply_defauly_parts called on machine that already had component_parts: [machine]")

		// Remove references of components so it doesn't trigger Exited logic and remove existing parts.
		for(var/obj/item/part as anything in machine.component_parts)
			machine.component_parts -= part
			qdel(part)

	// List of components always contains the circuit board used to build it.
	machine.component_parts = list(src)
	forceMove(machine)

	if(machine.circuit != src)
		// This really shouldn't happen. If it somehow does, print out a stack trace and gracefully handle it.
		stack_trace("apply_default_parts called from a circuit board that does not belong to machine: [machine]")

		QDEL_NULL(machine.circuit)
		machine.circuit = src

	return

/**
 * Used to allow the circuitboard to configure a machine in some way, shape or form.
 *
 * Arguments:
 * * machine - The machine to attempt to configure.
 */
/obj/item/circuitboard/proc/configure_machine(obj/machinery/machine)
	return

// Circuitboard/machine
/*Common Parts: Parts List: Ignitor, Timer, Infra-red laser, Infra-red sensor, t_scanner, Capacitor, Valve, sensor unit,
micro-manipulator, console screen, beaker, Microlaser, matter bin, power cells.
*/

/obj/item/circuitboard/machine
	name_extension = "(Machine Board)"
	var/needs_anchored = TRUE // Whether this machine must be anchored to be constructed.
	var/list/req_components // Components required by the machine.
							// Example: list(/obj/item/stock_parts/matter_bin = 5)

	var/list/def_components // Default replacements for req_components, to be used in apply_default_parts instead of req_components types
							// Example: list(/obj/item/stock_parts/matter_bin = /obj/item/stock_parts/matter_bin/super)

// Applies the default parts defined by the circuit board when the machine is created
/obj/item/circuitboard/machine/apply_default_parts(obj/machinery/machine)
	if(!req_components)
		return

	. = ..()

	for(var/comp_path in req_components)
		var/comp_amt = req_components[comp_path]
		if(!comp_amt)
			continue

		if(def_components && def_components[comp_path])
			comp_path = def_components[comp_path]

		if(ispath(comp_path, /obj/item/stack))
			continue
		else if (ispath(comp_path, /datum/stock_part))
			var/stock_part_datum = GLOB.stock_part_datums[comp_path]
			if (isnull(stock_part_datum))
				CRASH("[comp_path] didn't have a matching stock part datum")
			for (var/_ in 1 to comp_amt)
				machine.component_parts += stock_part_datum
		else
			for(var/component in 1 to comp_amt)
				machine.component_parts += new comp_path(machine)

	machine.RefreshParts()

/obj/item/circuitboard/machine/examine(mob/user)
	. = ..()
	if(!LAZYLEN(req_components))
		. += span_info("It requires no components.")
		return .

	var/list/nice_list = list()
	for(var/component_path in req_components)
		if(!ispath(component_path))
			continue

		var/component_name
		var/component_amount = req_components[component_path]

		if(ispath(component_path, /obj/item/stack))
			var/obj/item/stack/stack_path = component_path
			if(initial(stack_path.singular_name))
				component_name = initial(stack_path.singular_name) //e.g. "glass sheet" vs. "glass"
		else if(ispath(component_path, /obj/item/stock_parts) && !specific_parts)
			var/obj/item/stock_parts/stock_part = component_path
			component_name = initial(stock_part.base_name) || initial(stock_part.name)
		else if(ispath(component_path, /obj/item/stock_parts))
			var/obj/item/stock_parts/stock_part = component_path
			component_name = initial(stock_part.name)
		else if(ispath(component_path, /datum/stock_part))
			var/datum/stock_part/stock_part = component_path
			var/obj/item/stock_parts/physical_object_type = initial(stock_part.physical_object_type)
			component_name = initial(physical_object_type.base_name) || initial(physical_object_type.name)
		else if(ispath(component_path, /atom))
			var/atom/stock_part = component_path
			component_name = initial(stock_part.name)

		if (isnull(component_name))
			stack_trace("[component_path] was an invalid component")

		nice_list += list("[component_amount] [component_name]\s")

	. += span_info("It requires [english_list(nice_list)].")
