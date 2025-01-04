/datum/export/epic_loot_electronics
	cost = PAYCHECK_COMMAND
	unit_name = "electronic salvage"
	export_types = list(
		/obj/item/epic_loot/device_fan,
		/obj/item/epic_loot/display_broken,
		/obj/item/epic_loot/civilian_circuit,
		/obj/item/epic_loot/processor,
		/obj/item/epic_loot/disk_drive,
	)

/datum/export/epic_loot_electronics_super
	cost = PAYCHECK_COMMAND * 2
	unit_name = "high value electronic salvage"
	export_types = list(
		/obj/item/epic_loot/display,
		/obj/item/epic_loot/graphics,
		/obj/item/epic_loot/military_circuit,
		/obj/item/epic_loot/power_supply,
	)

// Computer fans
/obj/item/epic_loot/device_fan
	name = "device fan"
	desc = "An electronics cooling fan, used to keep computers and the like at reasonable temperatures while working."
	icon_state = "device_fan"
	drop_sound = 'sound/items/handling/ammobox_drop.ogg'
	pickup_sound = 'sound/items/handling/ammobox_pickup.ogg'
	custom_materials = list(
		/datum/material/plastic = SMALL_MATERIAL_AMOUNT * 9,
		/datum/material/gold = SMALL_MATERIAL_AMOUNT,
	)

// A display of some sort, this one probably still works
/obj/item/epic_loot/display
	name = "display"
	desc = "An electronic display, used in any number of machines to display information to users."
	icon_state = "display"
	w_class = WEIGHT_CLASS_NORMAL
	drop_sound = 'sound/items/handling/ammobox_drop.ogg'
	pickup_sound = 'sound/items/handling/ammobox_pickup.ogg'
	custom_materials = list(
		/datum/material/plastic = SMALL_MATERIAL_AMOUNT * 5,
		/datum/material/glass = SMALL_MATERIAL_AMOUNT * 4,
		/datum/material/gold = SMALL_MATERIAL_AMOUNT,
	)

// A display of some sort, this one for sure does not work
/obj/item/epic_loot/display_broken
	name = "broken display"
	desc = "An electronic display, used in any number of machines to display information to users. This one is broken."
	icon_state = "display_broken"
	w_class = WEIGHT_CLASS_NORMAL
	drop_sound = 'sound/items/handling/ammobox_drop.ogg'
	pickup_sound = 'sound/items/handling/ammobox_pickup.ogg'
	custom_materials = list(
		/datum/material/plastic = SMALL_MATERIAL_AMOUNT * 5,
		/datum/material/glass = SMALL_MATERIAL_AMOUNT * 4,
		/datum/material/gold = SMALL_MATERIAL_AMOUNT,
	)

// Martian made very high quality no scam 质量非常高
/obj/item/epic_loot/graphics
	name = "graphics processor"
	desc = "A large processor card for the handling of computer generated graphics."
	icon_state = "graphics"
	w_class = WEIGHT_CLASS_NORMAL
	drop_sound = 'sound/items/handling/ammobox_drop.ogg'
	pickup_sound = 'sound/items/handling/ammobox_pickup.ogg'
	custom_materials = list(
		/datum/material/plastic = SMALL_MATERIAL_AMOUNT * 8,
		/datum/material/silver = SMALL_MATERIAL_AMOUNT * 2,
		/datum/material/gold = SMALL_MATERIAL_AMOUNT * 2,
	)

// A military general-use circuit board
/obj/item/epic_loot/military_circuit
	name = "military-grade circuit board"
	desc = "A small circuit board commonly seen used by military-grade electronics."
	icon_state = "circuit_military"
	drop_sound = 'sound/items/handling/component_drop.ogg'
	pickup_sound = 'sound/items/handling/component_pickup.ogg'
	custom_materials = list(
		/datum/material/plastic = SMALL_MATERIAL_AMOUNT * 6,
		/datum/material/titanium = SMALL_MATERIAL_AMOUNT * 2,
		/datum/material/silver = SMALL_MATERIAL_AMOUNT * 2,
		/datum/material/gold = SMALL_MATERIAL_AMOUNT * 2,
	)

// A civilian general-use circuit board
/obj/item/epic_loot/civilian_circuit
	name = "general-purpose circuit board"
	desc = "A small circuit board commonly seen used by general-purpose electronics."
	icon_state = "civilian_circuit"
	drop_sound = 'sound/items/handling/component_drop.ogg'
	pickup_sound = 'sound/items/handling/component_pickup.ogg'
	custom_materials = list(
		/datum/material/plastic = SMALL_MATERIAL_AMOUNT * 6,
		/datum/material/silver = SMALL_MATERIAL_AMOUNT * 2,
		/datum/material/gold = SMALL_MATERIAL_AMOUNT * 2,
	)

// A computer processor unit
/obj/item/epic_loot/processor
	name = "processor core"
	desc = "The processing core of a computer, the small chip responsible for all of the inner workings of most devices."
	icon_state = "processor"
	inhand_icon_state = "razor"
	drop_sound = 'sound/items/handling/component_drop.ogg'
	pickup_sound = 'sound/items/handling/component_pickup.ogg'
	custom_materials = list(
		/datum/material/plastic = SMALL_MATERIAL_AMOUNT * 3,
		/datum/material/silver = SMALL_MATERIAL_AMOUNT,
		/datum/material/gold = SMALL_MATERIAL_AMOUNT,
	)

// A computer power supply
/obj/item/epic_loot/power_supply
	name = "computer power supply"
	desc = "A computer power supply, used to provide regulated electric power to other components of a computer."
	icon_state = "psu"
	w_class = WEIGHT_CLASS_NORMAL
	drop_sound = 'sound/items/handling/ammobox_drop.ogg'
	pickup_sound = 'sound/items/handling/ammobox_pickup.ogg'
	custom_materials = list(
		/datum/material/plastic = SMALL_MATERIAL_AMOUNT * 8,
		/datum/material/silver = SMALL_MATERIAL_AMOUNT * 2,
		/datum/material/gold = SMALL_MATERIAL_AMOUNT * 2,
	)

// A drive for reading data from data disks in computers
/obj/item/epic_loot/disk_drive
	name = "hard-disk reader"
	desc = "A device for reading and writing data to hard-disks, one of the most common data storage media on the frontier."
	icon_state = "disk_drive"
	w_class = WEIGHT_CLASS_NORMAL
	drop_sound = 'sound/items/handling/ammobox_drop.ogg'
	pickup_sound = 'sound/items/handling/ammobox_pickup.ogg'
	custom_materials = list(
		/datum/material/plastic = SMALL_MATERIAL_AMOUNT * 8,
		/datum/material/silver = SMALL_MATERIAL_AMOUNT * 2,
		/datum/material/gold = SMALL_MATERIAL_AMOUNT * 2,
	)

/obj/item/computer_disk/all_of_them
	max_capacity = 128
	starting_programs = list(
		/datum/computer_file/program/arcade/eazy, // 6 GQ
		/datum/computer_file/program/radar/lifeline, // 5 GQ
		/datum/computer_file/program/radar/custodial_locator, // 2 GQ
		/datum/computer_file/program/supermatter_monitor, // 5 GQ
		/datum/computer_file/program/newscaster, // 2 GQ
		/datum/computer_file/program/secureye/syndicate, // 5 GQ
		/datum/computer_file/program/status, // 1 GQ
		/datum/computer_file/program/maintenance/phys_scanner, // 2 GQ
		/datum/computer_file/program/maintenance/camera, // 4 GQ
		/datum/computer_file/program/maintenance/modsuit_control, // 2 GQ
		/datum/computer_file/program/maintenance/spectre_meter, // 7 GQ
		/datum/computer_file/program/maintenance/cool_sword, // 1 GQ
		/datum/computer_file/program/maintenance/theme/cat, // 2 GQ
		/datum/computer_file/program/maintenance/theme/lightmode, // 2 GQ
		/datum/computer_file/program/maintenance/theme/spooky, // 2 GQ
		/datum/computer_file/program/ntnet_dos, // 20 GQ
		/datum/computer_file/program/revelation, // 13 GQ
		/datum/computer_file/program/ai_restorer, // 12 GQ
		/datum/computer_file/program/ntnetmonitor, // 12 GQ
	)
	/// List of random things that will be mentioned in the desc
	var/list/hackerman_bits = list(
		"Some Tunes",
		"钱",
		"Software Testing Prototype",
		"CLASSIFIED",
		"Free Download",
		"!! EVIL VIRUS !!",
		"📸",
		">;3",
		"@AOL.com",
		"$$$",
		"Comedy",
		"For Whom The Bell Tolls",
	)

/obj/item/computer_disk/all_of_them/Initialize(mapload)
	. = ..()
	desc = "Removable disk used to store data, with a paper label adhered to the side. \
		This one has '[pick(hackerman_bits)]' ominously written on it."
