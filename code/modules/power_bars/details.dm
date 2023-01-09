/datum/power_bar_detail
	var/department
	var/tier
	var/message

// Cargo
/datum/power_bar_detail/cargo_discounts
	department = POWER_BAR_DEPARTMENT_CARGO
	tier = 2
	message = "Packs made cheaper."

/datum/power_bar_detail/cargo_shuttles
	department = POWER_BAR_DEPARTMENT_CARGO
	tier = 2
	message = "Shuttle speeds increased."

// Engineering
/datum/power_bar_detail/rcd
	department = POWER_BAR_DEPARTMENT_ENGINEERING
	tier = 2
	message = "RCDs upgraded, and speed increased."

/datum/power_bar_detail/rcd_silo_link
	department = POWER_BAR_DEPARTMENT_ENGINEERING
	tier = 3
	message = "RCDs link to silo."
