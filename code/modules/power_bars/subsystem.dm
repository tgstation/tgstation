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

/datum/controller/subsystem/power_bars/stat_entry(msg)
	return enabled ? "ON": "OFF"

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
