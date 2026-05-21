/**
 * Request Emergency Temporary Access - RETA - Config
 * code\modules\reta\reta_system.dm
 */

/// RETA system is enabled
/datum/config_entry/flag/reta_enabled
	default = TRUE

/// Duration for how long temporary access lasts (default: 5 minutes)
/datum/config_entry/number/reta_duration_ds
	default = 3000
	min_val = 300
	integer = FALSE

/// Cooldown  between RETA calls from the same origin to the same target department (default: 15 seconds)
/datum/config_entry/number/reta_dept_cooldown_ds
	default = 150
	min_val = 0
	integer = FALSE
