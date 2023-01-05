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

	var/list/last_distributed_allocations
	var/next_distribution_timer_id
	var/time_to_distribute = 10 SECONDS

	// Without this, I would have to support every single map, which sucks ass
	var/enabled

	var/excess_power_bars = 1 // MBTODO: 0
	var/max_power_bars = 3

/datum/controller/subsystem/power_bars/Initialize()
	enabled = GLOB.singularity_computers.len > 0
	last_distributed_allocations = department_allocations.Copy()
	delete_stock_part_designs()
	return SS_INIT_SUCCESS

/datum/controller/subsystem/power_bars/stat_entry(msg)
	var/list/entries = list()
	for (var/department in department_allocations)
		var/current = last_distributed_allocations[department]
		var/next = department_allocations[department]

		entries += "[uppertext(copytext(department, 1, 4))]=[current == next ? current : "[current]->[next]"]"

	return "[enabled ? "ON": "OFF"] (+[excess_power_bars]) [entries.Join(" / ")]"

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
		return last_distributed_allocations[POWER_BAR_DEPARTMENT_MEDICAL]
	else if (istype(area, /area/station/cargo))
		return last_distributed_allocations[POWER_BAR_DEPARTMENT_CARGO]
	else if (istype(area, /area/station/engineering))
		return last_distributed_allocations[POWER_BAR_DEPARTMENT_ENGINEERING]
	else if (istype(area, /area/station/science))
		return last_distributed_allocations[POWER_BAR_DEPARTMENT_SCIENCE]
	else if (istype(area, /area/station/security))
		return last_distributed_allocations[POWER_BAR_DEPARTMENT_SECURITY]
	else
		return last_distributed_allocations[POWER_BAR_DEPARTMENT_COMMON]

/datum/controller/subsystem/power_bars/proc/stock_part_tier(power_bars)
	switch (power_bars)
		if (1)
			return 1
		if (2)
			return 2
		if (3)
			return 4

/datum/controller/subsystem/power_bars/proc/reassign_power_bar(department, power_bars)
	if (!(department in department_allocations))
		CRASH("[department] is not a valid department")

	power_bars = clamp(round(power_bars), 0, max_power_bars)
	var/current_allocation = department_allocations[department]

	if (power_bars == current_allocation)
		return

	if (power_bars > current_allocation)
		if (excess_power_bars < power_bars - current_allocation)
			return

		excess_power_bars -= power_bars - current_allocation
	else
		excess_power_bars += current_allocation - power_bars

	department_allocations[department] = power_bars

	if (isnull(next_distribution_timer_id))
		next_distribution_timer_id = addtimer(CALLBACK(src, PROC_REF(distribute_power_bars)), time_to_distribute, TIMER_STOPPABLE)

/datum/controller/subsystem/power_bars/proc/distribute_power_bars()
	last_distributed_allocations = department_allocations.Copy()
	next_distribution_timer_id = null
