SUBSYSTEM_DEF(power_bars)
	name = "Power Bars"
	flags = SS_NO_FIRE

	var/list/department_allocations = list(
		POWER_BAR_DEPARTMENT_COMMON = 1,
		POWER_BAR_DEPARTMENT_CARGO = 1,
		POWER_BAR_DEPARTMENT_ENGINEERING = 1,
		POWER_BAR_DEPARTMENT_MEDICAL = 1,
		POWER_BAR_DEPARTMENT_SCIENCE = 1,
		POWER_BAR_DEPARTMENT_SECURITY = 1,
	)

	// Without this, I would have to support every single map, which sucks ass
	var/enabled

/datum/controller/subsystem/power_bars/Initialize()
	enabled = GLOB.singularity_computers.len > 0
	delete_stock_part_designs()
	return SS_INIT_SUCCESS

/datum/controller/subsystem/power_bars/stat_entry(msg)
	var/list/entries = list()
	for (var/department in department_allocations)
		entries += "[uppertext(copytext(department, 1, 4))]=[department_allocations[department]]"

	return "[enabled ? "ON": "OFF"] - [entries.Join(" / ")]"

/datum/controller/subsystem/power_bars/proc/delete_stock_part_designs()
	var/stock_part_designs = list()

	for (var/design_id in SSresearch.techweb_designs)
		var/datum/design/design = SSresearch.techweb_design_by_id(design_id)
		if ( \
			(ispath(design.build_path, /obj/item/stock_parts) && !ispath(design.build_path, /obj/item/stock_parts/cell)) \
			|| ispath(design.build_path, /obj/item/storage/part_replacer) \
		)
			stock_part_designs += design_id
			design.departmental_flags = NONE

	for (var/node_id in SSresearch.techweb_nodes)
		var/datum/techweb_node/node = SSresearch.techweb_nodes[node_id]
		for (var/design_id in node.design_ids)
			if (!(design_id in stock_part_designs))
				continue

			node.prune_design_id(design_id)

/datum/controller/subsystem/power_bars/proc/power_bars_of_area(area/area)
	if (istype(area, /area/station/medical))
		return department_allocations[POWER_BAR_DEPARTMENT_MEDICAL]
	else if (istype(area, /area/station/cargo))
		return department_allocations[POWER_BAR_DEPARTMENT_CARGO]
	else if (istype(area, /area/station/engineering))
		return department_allocations[POWER_BAR_DEPARTMENT_ENGINEERING]
	else if (istype(area, /area/station/science))
		return department_allocations[POWER_BAR_DEPARTMENT_SCIENCE]
	else if (istype(area, /area/station/security))
		return department_allocations[POWER_BAR_DEPARTMENT_SECURITY]
	else
		return department_allocations[POWER_BAR_DEPARTMENT_COMMON]

/datum/controller/subsystem/power_bars/proc/stock_part_tier(power_bars)
	switch (power_bars)
		if (1)
			return 1
		if (2)
			return 2
		if (3)
			return 4
