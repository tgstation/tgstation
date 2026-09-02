SUBSYSTEM_DEF(power_bars)
	name = "Power Bars"
	ss_flags = SS_NO_FIRE

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
	var/enabled = FALSE
	var/list/datum/power_bar_allocation/available_power_bars

	var/max_power_bars = 3

/datum/controller/subsystem/power_bars/Initialize()
	enabled = GLOB.singularity_computers.len > 0
	last_distributed_allocations = deep_copy_list(department_allocations)
	areas_per_department = areas_for_department()

	available_power_bars = list(
		new /datum/power_bar_allocation("Base charge", department_allocations.len),
	)

	if (enabled)
		delete_redundant_designs()

	return SS_INIT_SUCCESS

/datum/controller/subsystem/power_bars/stat_entry(msg)
	return "[enabled ? "ON": "OFF"] ([debug_power_bar_distributions()])"

#define POWER_BAR_PR_LINK "https://github.com/tgstation/tgstation/pull/12345"

/datum/controller/subsystem/power_bars/proc/motd()
	if (!enabled)
		return ""

	return {"
		<div style='color: purple; border: 1px dotted'>
			<h1><a href="[POWER_BAR_PR_LINK]">Power Bars + Singularity Concept</a></h1>
			<p>As part of an experiment on the future of power, all rounds on MetaStation will feature <b>the concept of power bars</b>, and <b>replace the supermatter</b> with an engine styled around <b>the singularity</b>.</p>
			<p>Engineering can distribute power bars to other departments. More power bars = better equipment. Cargo will get faster shuttles, stasis beds will access surgeries, security gets x-ray cameras, etc.</p>
			<p>Please give your feedback or learn more on the <a href="[POWER_BAR_PR_LINK]">pull request</a>.</p>
		</div>
	"}

/datum/controller/subsystem/power_bars/proc/debug_power_bar_distributions()
	var/list/entries = list()
	for (var/department in department_allocations)
		var/current = last_distributed_allocations[department].len
		var/next = department_allocations[department].len

		entries += "[uppertext(copytext(department, 1, 4))]=[current == next ? current : "[current]->[next]"]"

	return "+[available_power_bars()] [entries.Join(" / ")]"

/datum/controller/subsystem/power_bars/proc/delete_redundant_designs()
	var/list/stock_part_designs = list()

	for (var/design_typepath in SSresearch.techweb_designs)
		var/datum/design/design = SSresearch.techweb_designs[design_typepath]
		if (!allowed_stockpart(design.build_path) || ispath(design.build_path, /obj/item/storage/part_replacer))
			stock_part_designs += design_typepath
			design.departmental_flags = NONE

	for (var/node_path in SSresearch.techweb_nodes)
		var/datum/techweb_node/node = SSresearch.techweb_nodes[node_path]
		for (var/design_path in node.unlocked_designs)
			if (!(design_path in stock_part_designs))
				continue

			// node.prune_design_id(design_path) // melbert todo
			node.unlocked_designs -= design_path

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
	sorted_allocation_entries.len = available_power_bars()

	var/list/counts = list()

	for (var/list/entry in sorted_allocation_entries)
		counts[entry[2]] += 1

	for (var/department in department_allocations)
		if (department in counts)
			continue

		counts[department] = 0

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

	var/list/common_areas = list()

	for (var/area/area_type as anything in typesof(/area))
		if (initial(area_type.protected_from_power_bars))
			continue

		if (area_type in all_other_areas)
			continue

		common_areas += area_type

	areas_for_department[POWER_BAR_DEPARTMENT_COMMON] = common_areas
	ASSERT(!(/area/station/medical/storage in areas_for_department[POWER_BAR_DEPARTMENT_COMMON]))

	return areas_for_department

/datum/controller/subsystem/power_bars/proc/radio_channels_for_department(department)
	RETURN_TYPE(/list)

	ASSERT(department in department_allocations)

	switch (department)
		if (POWER_BAR_DEPARTMENT_CARGO)
			return list(RADIO_CHANNEL_SUPPLY)
		if (POWER_BAR_DEPARTMENT_ENGINEERING)
			return list(RADIO_CHANNEL_ENGINEERING)
		if (POWER_BAR_DEPARTMENT_MEDICAL)
			return list(RADIO_CHANNEL_MEDICAL)
		if (POWER_BAR_DEPARTMENT_SCIENCE)
			return list(RADIO_CHANNEL_SCIENCE)
		if (POWER_BAR_DEPARTMENT_SECURITY)
			return list(RADIO_CHANNEL_SECURITY)
		if (POWER_BAR_DEPARTMENT_COMMON)
			return list(RADIO_CHANNEL_COMMAND, RADIO_CHANNEL_SERVICE)

/datum/controller/subsystem/power_bars/proc/stock_part_tier(power_bars)
	switch (power_bars)
		if (0, 1)
			return 1
		if (2)
			return 2
		if (3)
			return 4

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

	var/list/department_allocations_after_limit = allocations_after_limit(department_allocations)
	var/list/last_distributed_allocations_after_limit = allocations_after_limit(last_distributed_allocations)

	for (var/department in department_allocations_after_limit)
		var/current = last_distributed_allocations_after_limit[department]
		var/next = department_allocations_after_limit[department]
		if (current == next)
			continue

		areas_to_update += areas_per_department[department]
		departments_to_update[department] = current

	last_distributed_allocations = deep_copy_list(department_allocations)
	next_distribution_timer_id = null

	for (var/obj/machinery/machine as anything in SSmachines.get_all_machines())
		var/area/area = get_area(machine)
		if (!(area?.type in areas_to_update))
			continue

		machine.update_for_power_bars()

	// Do it here instead of signal so we don't do it more than once
	for (var/obj/machinery/computer/power_distribution/power_distribution_console as anything in GLOB.power_distribution_consoles)
		if (power_distribution_console.send_power_bar_update_message(department_allocations_after_limit, last_distributed_allocations_after_limit))
			break

	SEND_SIGNAL(src, COMSIG_POWER_BARS_UPDATED, departments_to_update)

/datum/controller/subsystem/power_bars/proc/give_power_bars(datum/power_bar_allocation/power_bar_allocation)
	ASSERT(SSpower_bars.enabled)
	ASSERT(!(power_bar_allocation in available_power_bars))

	var/previous_available_power_bars = available_power_bars()
	var/previous_used_power_bars = used_power_bars()

	update_available_power_bars(available_power_bars + power_bar_allocation)

	if (previous_used_power_bars > previous_available_power_bars)
		distribute_power_bars()

/datum/controller/subsystem/power_bars/proc/remove_power_bars(datum/power_bar_allocation/power_bar_allocation)
	ASSERT(SSpower_bars.enabled)
	ASSERT(power_bar_allocation in available_power_bars)

	update_available_power_bars(available_power_bars - power_bar_allocation)

	if (used_power_bars() > available_power_bars())
		distribute_power_bars()

/datum/controller/subsystem/power_bars/proc/used_power_bars()
	ASSERT(SSpower_bars.enabled)

	var/sum = 0

	for (var/department in department_allocations)
		sum += department_allocations[department].len

	return sum

// APCs charge themselves
/datum/controller/subsystem/power_bars/proc/surplus_power(obj/machinery/power/source)
	ASSERT(SSpower_bars.enabled)

	var/obj/machinery/power/apc/apc_source = source
	if (!istype(apc_source))
		apc_source = null

	var/area/source_area = get_area(source)
	if (source_area.protected_from_power_bars)
		return clamp(source.powernet.avail - source.powernet.load, 0, source.powernet.avail)

	if (available_power_bars() <= department_allocations.len)
		return 0 WATTS

	if (power_bars_of_area(source_area) == 0)
		return 0 WATTS

	// Outside of a prototype, this would ideally be like, a big battery or something.
	// I would've done that now, but if it's a Big Battery and we still have a separate computer (which we might not need),
	// then it would also intuit that the computer would need to be connected to Big Battery, which I don't want to bother with right now.
	var/list/valid_powernet = FALSE

	for (var/obj/machinery/power_distribution_console as anything in GLOB.power_distribution_consoles)
		var/area/console_area = get_area(power_distribution_console)
		var/apc_powernet = console_area?.apc?.terminal?.powernet

		if (isnull(apc_powernet))
			continue

		if (apc_powernet == source.powernet)
			valid_powernet = TRUE
			continue

		if (istype(apc_source) && apc_powernet == apc_source.terminal?.powernet)
			valid_powernet = TRUE
			continue

	if (!valid_powernet)
		return 0 WATTS

	return 1000000 WATTS

/datum/controller/subsystem/power_bars/proc/available_power_bars()
	var/sum = 0
	for (var/datum/power_bar_allocation/power_bar_allocation as anything in available_power_bars)
		sum += power_bar_allocation.amount
	return sum

/datum/controller/subsystem/power_bars/proc/details_of_upgrade(department, to_tier, from_tier)
	RETURN_TYPE(/list)

	ASSERT(department in department_allocations)

	var/list/details = list()

	for (var/datum/power_bar_detail/detail as anything in subtypesof(/datum/power_bar_detail))
		if (initial(detail.department) != department)
			continue

		var/tier = initial(detail.tier)
		if (isnull(tier))
			var/exclusive_tier = initial(detail.exclusive_tier)
			ASSERT(!isnull(exclusive_tier))
			if (to_tier != exclusive_tier)
				continue
		else if (tier <= from_tier || tier > to_tier)
			continue

		details += initial(detail.message)

	return details

/datum/controller/subsystem/power_bars/proc/update_available_power_bars(list/available_power_bars)
	var/previous_available_power_bars = src.available_power_bars
	var/previous_available_power_count = available_power_bars()
	src.available_power_bars = available_power_bars
	ASSERT(previous_available_power_bars != available_power_bars) // Do not mutate

	// Do it here instead of signal so we don't do it more than once
	for (var/obj/machinery/computer/power_distribution/power_distribution_console as anything in GLOB.power_distribution_consoles)
		if (power_distribution_console.send_power_bar_availability_changes(available_power_bars, previous_available_power_bars))
			break

	SEND_SIGNAL(src, COMSIG_POWER_BAR_AVAILABILITY_UPDATED, available_power_bars(), previous_available_power_count)

/datum/power_bar_allocation
	var/source
	var/amount

/datum/power_bar_allocation/New(source, amount)
	ASSERT(istext(source))
	ASSERT(isnum(amount))

	src.source = source
	src.amount = amount

/datum/power_bar_allocation/Destroy()
	SSpower_bars.available_power_bars -= src
	return ..()
