/obj/machinery/proc/refill_parts()
	ASSERT(SSpower_bars.enabled)

	var/list/created_parts = list()

	var/area/area = get_area(src)
	if (isnull(area))
		return


	var/stock_part_tier = SSpower_bars.stock_part_tier(SSpower_bars.power_bars_of_area(area))

	if (!(locate(/datum/stock_part) in component_parts) && no_stock_parts(component_parts))
		// We are rebuilding from a machine frame, maybe.
		var/obj/item/circuitboard/machine/machine_circuit = circuit

		if (istype(machine_circuit))
			for (var/component_path in machine_circuit.req_components)
				if (ispath(component_path, /datum/stock_part))
					component_parts += GLOB.stock_part_datums[component_path]
				else if (ispath(component_path, /obj/item/stock_parts))
					var/obj/item/stock_parts/stock_part = component_path
					if (ispath(stock_part, /obj/item/stock_parts/cell))
						continue

					component_parts += new stock_part(src, machine_circuit.req_components[component_path])

	for (var/datum/stock_part/stock_part in component_parts)
		component_parts -= stock_part

		for (var/datum/stock_part/stock_part_datum_type as anything in GLOB.stock_part_datums)
			if (initial(stock_part_datum_type.physical_object_base_type) != stock_part.physical_object_type)
				continue

			if (initial(stock_part_datum_type.tier) == stock_part_tier)
				created_parts += GLOB.stock_part_datums[stock_part_datum_type]
				break

	for (var/obj/item/stock_parts/stock_part in component_parts)
		if (istype(stock_part, /obj/item/stock_parts/cell))
			continue

		if (stock_part.rating == stock_part_tier)
			continue

		component_parts -= stock_part
		qdel(stock_part)

		var/obj/item/stock_parts/base = stock_part.type
		while (base.parent_type != /obj/item/stock_parts)
			base = base.parent_type

		for (var/obj/item/stock_parts/subtype as anything in typesof(base))
			if (initial(subtype.rating) != stock_part_tier)
				continue

			created_parts += new subtype(src)
			break

	component_parts += created_parts

/proc/no_stock_parts(list/component_parts)
	for (var/obj/item/stock_parts/stock_part in component_parts)
		if (istype(stock_part, /obj/item/stock_parts/cell))
			continue

		return FALSE

	return TRUE
