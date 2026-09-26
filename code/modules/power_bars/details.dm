/datum/power_bar_detail
	var/department
	var/tier
	var/exclusive_tier
	var/message

// Cargo
/datum/power_bar_detail/cargo_discounts
	department = POWER_BAR_DEPARTMENT_CARGO
	tier = 2
	message = "Cargo orders are cheaper."

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

// Medical
/datum/power_bar_detail/medibot_potency
	department = POWER_BAR_DEPARTMENT_MEDICAL
	tier = 2
	message = "Medibots heal faster."

/datum/power_bar_detail/pinpointer_proximity
	department = POWER_BAR_DEPARTMENT_MEDICAL
	exclusive_tier = 2
	message = "Pinpointers show proximity."

/datum/power_bar_detail/pinpointer_distance
	department = POWER_BAR_DEPARTMENT_MEDICAL
	tier = 3
	message = "Pinpointers show exact distance." // Not exact, but you won't try it if I don't say that

/datum/power_bar_detail/stasis_power_creep
	department = POWER_BAR_DEPARTMENT_MEDICAL
	tier = 3
	message = "Stasis beds have access to any researched surgery."

/datum/power_bar_detail/more_chems
	department = POWER_BAR_DEPARTMENT_MEDICAL
	tier = 3
	message = "Chemistry dispensers make more types of chemicals."

// Science
/datum/power_bar_detail/faster_points
	department = POWER_BAR_DEPARTMENT_SCIENCE
	tier = 2
	message = "Research points generate faster."

// Security
/datum/power_bar_detail/security_headset
	department = POWER_BAR_DEPARTMENT_SECURITY
	tier = 2
	message = "Security headsets can listen to all department channels."

/datum/power_bar_detail/beepsky
	department = POWER_BAR_DEPARTMENT_SECURITY
	tier = 2
	message = "Beepsky gets faster."

// Common
/datum/power_bar_detail/botany
	department = POWER_BAR_DEPARTMENT_COMMON
	tier = 2
	message = "Allows unlimited auto-grow for Hydroponics trays."

/datum/power_bar_detail/print_efficiency
	department = POWER_BAR_DEPARTMENT_COMMON
	tier = 2
	message = "Reduced mineral cost for printing research designs station-wide."
