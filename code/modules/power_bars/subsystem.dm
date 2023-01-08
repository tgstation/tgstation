SUBSYSTEM_DEF(power_bars)
	name = "Power Bars"
	flags = SS_NO_FIRE

	var/list/list/department_allocations = list(
		POWER_BAR_DEPARTMENT_COMMON = list(0),
		POWER_BAR_DEPARTMENT_CARGO = list(0),
		POWER_BAR_DEPARTMENT_ENGINEERING = list(0),
		POWER_BAR_DEPARTMENT_MEDICAL = list(0),
		POWER_BAR_DEPARTMENT_SCIENCE = list(0),
		POWER_BAR_DEPARTMENT_SECURITY = list(0),
	)

	var/list/areas_per_department = list()

	var/list/list/last_distributed_allocations
	var/next_distribution_timer_id
	var/time_to_distribute = 10 SECONDS

	// Without this, I would have to support every single map, which sucks ass
	var/enabled

	var/available_power_bars

	var/max_power_bars = 3

/datum/controller/subsystem/power_bars/Initialize()
	enabled = GLOB.singularity_computers.len > 0
	last_distributed_allocations = deep_copy_list(department_allocations)
	areas_per_department = areas_for_department()
	available_power_bars = department_allocations.len + 3 // MBTODO: Remove +3

	if (enabled)
		delete_redundant_designs()

	return SS_INIT_SUCCESS

/datum/controller/subsystem/power_bars/stat_entry(msg)
	return "[enabled ? "ON": "OFF"] ([debug_power_bar_distributions()])"

/datum/controller/subsystem/power_bars/proc/debug_power_bar_distributions()
	var/list/entries = list()
	for (var/department in department_allocations)
		var/current = last_distributed_allocations[department].len
		var/next = department_allocations[department].len

		entries += "[uppertext(copytext(department, 1, 4))]=[current == next ? current : "[current]->[next]"]"

	return "+[available_power_bars] [entries.Join(" / ")]"

/datum/controller/subsystem/power_bars/proc/delete_redundant_designs()
	var/stock_part_designs = list()

	for (var/design_id in SSresearch.techweb_designs)
		var/datum/design/design = SSresearch.techweb_design_by_id(design_id)
		if ( \
			(ispath(design.build_path, /obj/item/stock_parts) && !ispath(design.build_path, /obj/item/stock_parts/cell)) \
			|| ispath(design.build_path, /obj/item/storage/part_replacer) \
			|| ispath(design.build_path, /obj/item/rcd_upgrade) \
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
	var/department = department_from_area(area)
	if (isnull(department))
		return 1

	return power_bars_of_department(department)

/datum/controller/subsystem/power_bars/proc/power_bars_of_department(department)
	return allocations_after_limit(last_distributed_allocations)[department]

// Could cache
/datum/controller/subsystem/power_bars/proc/allocations_after_limit(list/allocations)
	PRIVATE_PROC(TRUE)
	RETURN_TYPE(/list)

	var/list/sorted_allocation_entries = list()
	for (var/department in allocations)
		for (var/time in allocations[department])
			sorted_allocation_entries += list(list(time, department))

	sorted_allocation_entries = sortTim(sorted_allocation_entries, GLOBAL_PROC_REF(cmp_list_first_index_asc))

	// Cut off latest entries
	sorted_allocation_entries.len = available_power_bars

	var/list/counts = list()

	for (var/list/entry in sorted_allocation_entries)
		counts[entry[2]] += 1

	return counts

/datum/controller/subsystem/power_bars/proc/department_from_area(area/area)
	if (istype(area, /area/station/medical))
		return POWER_BAR_DEPARTMENT_MEDICAL
	else if (istype(area, /area/station/cargo))
		return POWER_BAR_DEPARTMENT_CARGO
	else if (istype(area, /area/station/engineering))
		return POWER_BAR_DEPARTMENT_ENGINEERING
	else if (istype(area, /area/station/science))
		return POWER_BAR_DEPARTMENT_SCIENCE
	else if (istype(area, /area/station/security))
		return POWER_BAR_DEPARTMENT_SECURITY
	else if (istype(area, /area/station))
		return POWER_BAR_DEPARTMENT_COMMON
	else
		return null

/datum/controller/subsystem/power_bars/proc/areas_for_department()
	PRIVATE_PROC(TRUE)

	var/list/areas_for_department = list()

	areas_for_department[POWER_BAR_DEPARTMENT_MEDICAL] = typesof(/area/station/medical)
	areas_for_department[POWER_BAR_DEPARTMENT_CARGO] = typesof(/area/station/cargo)
	areas_for_department[POWER_BAR_DEPARTMENT_ENGINEERING] = typesof(/area/station/engineering)
	areas_for_department[POWER_BAR_DEPARTMENT_SCIENCE] = typesof(/area/station/science)
	areas_for_department[POWER_BAR_DEPARTMENT_SECURITY] = typesof(/area/station/security)

	var/list/all_other_areas = list()
	for (var/department in areas_for_department)
		all_other_areas += areas_for_department[department]

	areas_for_department[POWER_BAR_DEPARTMENT_COMMON] = typesof(/area/station) - all_other_areas
	ASSERT(!(/area/station/medical/storage in areas_for_department[POWER_BAR_DEPARTMENT_COMMON]))

	return areas_for_department

/datum/controller/subsystem/power_bars/proc/stock_part_tier(power_bars)
	switch (power_bars)
		if (0, 1)
			return 1
		if (2)
			return 2
		if (3)
			return 4

// MBTODO: Log, optional user arg
// MBTODO: Make the computer UI care about excess bars
/datum/controller/subsystem/power_bars/proc/reassign_power_bar(department, power_bars)
	ASSERT(SSpower_bars.enabled)

	if (!(department in department_allocations))
		CRASH("[department] is not a valid department")

	power_bars = clamp(round(power_bars), 0, max_power_bars)
	var/current_allocation = department_allocations[department].len

	if (power_bars == current_allocation)
		return

	if (power_bars > current_allocation)
		for (var/used in 1 to power_bars - current_allocation)
			department_allocations[department] += world.time
	else
		department_allocations[department].len = power_bars

	ASSERT(department_allocations[department].len == power_bars)

	if (isnull(next_distribution_timer_id))
		next_distribution_timer_id = addtimer(CALLBACK(src, PROC_REF(distribute_power_bars)), time_to_distribute, TIMER_STOPPABLE)

/datum/controller/subsystem/power_bars/proc/distribute_power_bars()
	ASSERT(SSpower_bars.enabled)

	var/list/departments_to_update = list()
	var/list/areas_to_update = list()

	var/list/department_locations_after_limit = allocations_after_limit(department_allocations)
	var/list/last_distributed_allocations_after_limit = allocations_after_limit(last_distributed_allocations)

	for (var/department in department_locations_after_limit)
		var/current = last_distributed_allocations_after_limit[department]
		var/next = department_locations_after_limit[department]
		if (current == next)
			continue

		areas_to_update += areas_per_department[department]
		departments_to_update[department] = current

	last_distributed_allocations = deep_copy_list(department_allocations)
	next_distribution_timer_id = null

	for (var/obj/machinery/machine as anything in GLOB.machines)
		var/area/area = get_area(machine)
		if (!(area?.type in areas_to_update))
			continue

		machine.RefreshParts()

	SEND_SIGNAL(src, COMSIG_POWER_BARS_UPDATED, departments_to_update)

/datum/controller/subsystem/power_bars/proc/remove_power_bars(power_bars)
	ASSERT(SSpower_bars.enabled)

	available_power_bars -= power_bars

	if (used_power_bars() > available_power_bars)
		distribute_power_bars()

/datum/controller/subsystem/power_bars/proc/used_power_bars()
	ASSERT(SSpower_bars.enabled)

	var/sum = 0

	for (var/department in department_allocations)
		sum += department_allocations[department].len

	return sum

// APCs charge themselves
// MBTODO: Has to be connected to the computer
/datum/controller/subsystem/power_bars/proc/surplus_power(obj/machinery/power/source)
	ASSERT(SSpower_bars.enabled)

	var/area/area = get_area(source)
	if (!istype(area, /area/station))
		return clamp(source.powernet.avail - source.powernet.load, 0, source.powernet.avail)

	if (available_power_bars <= department_allocations.len)
		return 0

	return 1000000 WATTS
