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
//Batteries

/datum/export/modular_part/battery/advanced
	cost = CARGO_CRATE_VALUE * 0.6
	unit_name = "advanced computer battery"
	export_types = list(/obj/item/stock_parts/cell/computer/advanced)
	include_subtypes = FALSE

/datum/export/modular_part/battery/super
	cost = CARGO_CRATE_VALUE * 0.8
	unit_name = "super computer battery"
	export_types = list(/obj/item/stock_parts/cell/computer/super)
	include_subtypes = FALSE

/datum/export/modular_part/battery/micro
	cost = CARGO_CRATE_VALUE * 0.2
	unit_name = "micro computer battery"
	export_types = list(/obj/item/stock_parts/cell/computer/micro)
	include_subtypes = FALSE

/datum/export/modular_part/battery/nano
	cost = CARGO_CRATE_VALUE * 0.1
	unit_name = "nano computer battery"
	export_types = list(/obj/item/stock_parts/cell/computer/nano)
	include_subtypes = FALSE

/datum/export/modular_part/battery/standard
	cost = CARGO_CRATE_VALUE * 0.4
	unit_name = "computer battery"
	export_types = list(/obj/item/stock_parts/cell/computer)
	include_subtypes = TRUE

//Other Power Parts

/datum/export/modular_part/apc_link
	cost = CARGO_CRATE_VALUE * 0.5
	unit_name = "area power connector"
	export_types = list(/obj/item/computer_hardware/recharger/apc_recharger)
	include_subtypes = TRUE

/datum/export/modular_part/controller
	cost = CARGO_CRATE_VALUE * 0.1
	unit_name = "power cell controller"
	export_types = list(/obj/item/computer_hardware/battery)
	include_subtypes = TRUE

//Data Disks

/datum/export/modular_part/portabledrive/advanced
	cost = CARGO_CRATE_VALUE * 0.4
	unit_name = "advanced data disk"
	export_types = list(/obj/item/computer_hardware/hard_drive/portable/advanced)
	include_subtypes = FALSE

/datum/export/modular_part/portabledrive/super
	cost = CARGO_CRATE_VALUE * 0.6
	unit_name = "super data disk"
	export_types = list(/obj/item/computer_hardware/hard_drive/portable/super)
	include_subtypes = FALSE

/datum/export/modular_part/portabledrive/standard
	cost = CARGO_CRATE_VALUE * 0.2
	unit_name = "data disk"
	export_types = list(/obj/item/computer_hardware/hard_drive/portable)
	include_subtypes = TRUE

//Hard Drives

/datum/export/modular_part/harddrive/advanced
	cost = CARGO_CRATE_VALUE * 0.6
	unit_name = "advanced hard disk drive"
	export_types = list(/obj/item/computer_hardware/hard_drive/advanced)
	include_subtypes = FALSE

/datum/export/modular_part/harddrive/super
	cost = CARGO_CRATE_VALUE * 0.8
	unit_name = "super hard disk drive"
	export_types = list(/obj/item/computer_hardware/hard_drive/super)
	include_subtypes = FALSE

/datum/export/modular_part/harddrive/cluster
	cost = CARGO_CRATE_VALUE * 1
	unit_name = "cluster hard disk drive"
	export_types = list(/obj/item/computer_hardware/hard_drive/cluster)
	include_subtypes = FALSE

/datum/export/modular_part/harddrive/small
	cost = CARGO_CRATE_VALUE * 0.2
	unit_name = "solid state drive"
	export_types = list(/obj/item/computer_hardware/hard_drive/small)
	include_subtypes = FALSE

/datum/export/modular_part/harddrive/micro
	cost = CARGO_CRATE_VALUE * 0.1
	unit_name = "micro solid state drive"
	export_types = list(/obj/item/computer_hardware/hard_drive/micro)
	include_subtypes = FALSE

/datum/export/modular_part/harddrive/standard
	cost = CARGO_CRATE_VALUE * 0.4
	unit_name = "hard disk drive"
	export_types = list(/obj/item/computer_hardware/hard_drive)
	include_subtypes = TRUE

//Networking Parts

/datum/export/modular_part/networkcard/advanced
	cost = CARGO_CRATE_VALUE * 0.5
	unit_name = "advanced network card"
	export_types = list(/obj/item/computer_hardware/network_card/advanced)
	include_subtypes = FALSE

/datum/export/modular_part/networkcard/wired
	cost = CARGO_CRATE_VALUE
	unit_name = "wired network card"
	export_types = list(/obj/item/computer_hardware/network_card/wired)
	include_subtypes = FALSE

/datum/export/modular_part/networkcard/standard
	cost = CARGO_CRATE_VALUE * 0.25
	unit_name = "network card"
	export_types = list(/obj/item/computer_hardware/network_card)
	include_subtypes = TRUE

//Miscellaneous Parts

/datum/export/modular_part/idcard
	cost = CARGO_CRATE_VALUE * 0.2
	unit_name = "computer ID card slot"
	export_types = list(/obj/item/computer_hardware/card_slot)
	include_subtypes = TRUE

/datum/export/modular_part/intellicard
	cost = CARGO_CRATE_VALUE * 0.2
	unit_name = "computer intellicard slot"
	export_types = list(/obj/item/computer_hardware/ai_slot)
	include_subtypes = TRUE

/datum/export/modular_part/miniprinter
	cost = CARGO_CRATE_VALUE * 0.2
	unit_name = "miniprinter"
	export_types = list(/obj/item/computer_hardware/printer/mini)
	include_subtypes = TRUE

/datum/export/modular_part/misc
	cost = CARGO_CRATE_VALUE * 0.1
	unit_name = "miscellaneous computer part"
	export_types = list(/obj/item/computer_hardware)
	include_subtypes = TRUE
