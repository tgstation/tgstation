/obj/machinery/proc/refill_parts()
	ASSERT(SSpower_bars.enabled)

	var/list/created_parts = list()

	var/area/area = get_area(src)
	if (isnull(area))
		return

	var/stock_part_tier = SSpower_bars.stock_part_tier(SSpower_bars.power_bars_of_area(area))

	if (!(locate(/datum/stock_part) in component_parts))
		// We are rebuilding from a machine frame, maybe.
		var/obj/item/circuitboard/machine/machine_circuit = circuit

		if (istype(machine_circuit))
			for (var/component_path, component_count in machine_circuit.req_components)
				for(var/i in 1 to component_count)
					if (ispath(component_path, /datum/stock_part))
						component_parts += GLOB.stock_part_datums[component_path]

					else if (ispath(component_path, /obj/item/stock_parts))
						var/obj/item/stock_parts/stock_part = component_path
						if (ispath(stock_part, /obj/item/stock_parts/power_store))
							continue

						component_parts += new stock_part(src, machine_circuit.req_components[component_path])

	for (var/datum/stock_part/stock_part in component_parts)
		component_parts -= stock_part

		for (var/datum/stock_part/stock_part_datum_type as anything in GLOB.stock_part_datums)
			if (initial(stock_part_datum_type.physical_object_base_type) != stock_part.physical_object_base_type)
				continue

			if (initial(stock_part_datum_type.tier) == stock_part_tier)
				created_parts += GLOB.stock_part_datums[stock_part_datum_type]
				break

	component_parts += created_parts
