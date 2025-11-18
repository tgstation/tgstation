/obj/item/stack/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, amount)
	return .

/obj/machinery/ore_silo/on_object_saved(map_string, turf/current_loc)
	var/datum/component/material_container/material_holder = GetComponent(/datum/component/material_container)
	for(var/each in material_holder.materials)
		var/amount_in_stack = material_holder.materials[each] / 100
		if(amount_in_stack <= 0)
			continue

		var/datum/material/material_datum = each
		var/obj/item/stack/typepath = material_datum.sheet_type
		var/list/variables = list()
		TGM_ADD_TYPEPATH_VAR(variables, typepath, amount, amount_in_stack)
		TGM_MAP_BLOCK(map_string, typepath, generate_tgm_typepath_metadata(variables))

/obj/machinery/ore_silo/PersistentInitialize()
	. = ..()
	var/datum/component/material_container/silo_container = materials

	// transfer all mats to silo. whatever cannot be transfered is dumped out as sheets
	top_level:
		for(var/obj/item/stack/target_stack in loc)
			var/total_amount = 0
			for(var/mat_type, per_unit_amount in target_stack.mats_per_unit)
				if(!silo_container.can_hold_material(mat_type))
					continue top_level
				total_amount += (per_unit_amount * target_stack.amount)

			if(!silo_container.has_space(total_amount))
				continue top_level

			// yes, a double loop is really neccessary
			for(var/mat_type, per_unit_amount in target_stack.mats_per_unit)
				silo_container.materials[mat_type] += (per_unit_amount * target_stack.amount)

			qdel(target_stack)
