// Circuit boards, spare parts, etc.

/datum/export/solar/assembly
	cost = CARGO_CRATE_VALUE * 0.25
	unit_name = "solar panel assembly"
	export_types = list(/obj/item/solar_assembly)

/datum/export/solar/tracker_board
	cost = CARGO_CRATE_VALUE * 0.5
	unit_name = "solar tracker board"
	export_types = list(/obj/item/electronics/tracker)

/datum/export/solar/control_board
	cost = CARGO_CRATE_VALUE * 0.75
	unit_name = "solar panel control board"
	export_types = list(/obj/item/circuitboard/computer/solar_control)

// Computer and Tablet Parts
/datum/export/modular_part/idcard
	cost = CARGO_CRATE_VALUE * 0.2
	unit_name = "computer ID card slot"
	export_types = list(/obj/item/computer_hardware/card_slot)
	include_subtypes = TRUE

/datum/export/modular_part/misc
	cost = CARGO_CRATE_VALUE * 0.1
	unit_name = "miscellaneous computer part"
	export_types = list(/obj/item/computer_hardware)
	include_subtypes = TRUE

//Data Disks
/datum/export/modular_part/portabledrive/advanced
	cost = CARGO_CRATE_VALUE * 0.4
	unit_name = "advanced data disk"
	export_types = list(/obj/item/computer_disk/advanced)
	include_subtypes = FALSE

/datum/export/modular_part/portabledrive/super
	cost = CARGO_CRATE_VALUE * 0.6
	unit_name = "super data disk"
	export_types = list(/obj/item/computer_disk/super)
	include_subtypes = FALSE

/datum/export/modular_part/portabledrive/standard
	cost = CARGO_CRATE_VALUE * 0.2
	unit_name = "data disk"
	export_types = list(/obj/item/computer_disk)
	include_subtypes = TRUE
