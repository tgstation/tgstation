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

/datum/controller/subsystem/power_bars/stat_entry(msg)
	return ..(enabled ? "ON": "OFF")
