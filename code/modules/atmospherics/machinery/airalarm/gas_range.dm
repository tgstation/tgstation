/// Denotes a safe breathable range of a gas
/datum/gas_range
	/// The point at which the lack of the gas becomes harmful
	var/min_danger
	/// The point at which the lack of the gas becomes a concern
	var/min_warning
	/// The point at which the abundance of the gas becomes a concern
	var/max_warning
	/// The point at which the abundance of the gas becomes harmful
	var/max_danger

/datum/gas_range/New(min_danger as num, min_warning as num, max_warning as num, max_danger as num)
	if(min_danger) src.min_danger = min_danger
	if(min_warning) src.min_warning = min_warning
	if(max_warning) src.max_warning = max_warning
	if(max_danger) src.max_danger = max_danger

///TODO, don't merge
/datum/gas_range/proc/get_danger_level(val as num)
	if(max_danger >= 0 && val >= max_danger)
		return 2
	if(min_danger >= 0 && val <= min_danger)
		return 2
	if(max_warning >= 0 && val >= max_warning)
		return 1
	if(min_warning >= 0 && val <= min_warning)
		return 1
	return 0

/// A gas range for stuff we don't care about
/datum/gas_range/no_checks
	min_danger = -1
	min_warning = -1
	max_warning = -1
	max_danger = -1

/// A gas range for stuff we never want to breath
/datum/gas_range/dangerous
	min_danger = -1
	min_warning = -1
	max_warning = 0.2
	max_danger = 0.5
