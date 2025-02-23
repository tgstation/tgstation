/*Power cells are in code\modules\power\cell.dm

If you create T5+ please take a pass at mech_fabricator.dm. The parts being good enough allows it to go into minus values and create materials out of thin air when printing stuff.*/

/obj/item/stock_parts
	name = "stock part"
	desc = "What?"
	icon = 'icons/obj/devices/stock_parts.dmi'
	w_class = WEIGHT_CLASS_SMALL
	var/rating = 1
	///Used when a base part has a different name to higher tiers of part. For example, machine frames want any servo and not just a micro-servo.
	var/base_name
	var/energy_rating = 1
	///The generic category type that the stock part belongs to.  Generic objects that should not be instantiated should have the same type and abstract_type
	var/abstract_type = /obj/item/stock_parts

/obj/item/stock_parts/Initialize(mapload)
	. = ..()
	pixel_x = base_pixel_x + rand(-5, 5)
	pixel_y = base_pixel_y + rand(-5, 5)

/obj/item/stock_parts/get_part_rating()
	return rating

//Rating 1

/obj/item/stock_parts/capacitor
	name = "capacitor"
	desc = "A basic capacitor used in the construction of a variety of devices."
	icon_state = "capacitor"
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT*0.5, /datum/material/glass=SMALL_MATERIAL_AMOUNT*0.5)

/obj/item/stock_parts/scanning_module
	name = "scanning module"
	desc = "A compact, high resolution scanning module used in the construction of certain devices."
	icon_state = "scan_module"
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT*0.5, /datum/material/glass=SMALL_MATERIAL_AMOUNT*0.2)

/obj/item/stock_parts/servo
	name = "micro-servo"
	desc = "A tiny little servo motor used in the construction of certain devices."
	icon_state = "micro_servo"
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT*0.3)
	base_name = "servo"

/obj/item/stock_parts/micro_laser
	name = "micro-laser"
	desc = "A tiny laser used in certain devices."
	icon_state = "micro_laser"
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT*0.1, /datum/material/glass=SMALL_MATERIAL_AMOUNT*0.2)

/obj/item/stock_parts/matter_bin
	name = "matter bin"
	desc = "A container designed to hold compressed matter awaiting reconstruction."
	icon_state = "matter_bin"
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT*0.8)

//Rating 2

/obj/item/stock_parts/capacitor/adv
	name = "advanced capacitor"
	desc = "An advanced capacitor used in the construction of a variety of devices."
	icon_state = "adv_capacitor"
	rating = 2
	energy_rating = 3
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT*0.5, /datum/material/glass=SMALL_MATERIAL_AMOUNT*0.5)

/obj/item/stock_parts/scanning_module/adv
	name = "advanced scanning module"
	desc = "A compact, high resolution scanning module used in the construction of certain devices."
	icon_state = "adv_scan_module"
	rating = 2
	energy_rating = 3
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT*0.5, /datum/material/glass=SMALL_MATERIAL_AMOUNT*0.2)

/obj/item/stock_parts/servo/nano
	name = "nano-servo"
	desc = "A tiny little servo motor used in the construction of certain devices."
	icon_state = "nano_servo"
	rating = 2
	energy_rating = 3
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT*0.3)

/obj/item/stock_parts/micro_laser/high
	name = "high-power micro-laser"
	desc = "A tiny laser used in certain devices."
	icon_state = "high_micro_laser"
	rating = 2
	energy_rating = 3
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT*0.1, /datum/material/glass=SMALL_MATERIAL_AMOUNT*0.2)

/obj/item/stock_parts/matter_bin/adv
	name = "advanced matter bin"
	desc = "A container designed to hold compressed matter awaiting reconstruction."
	icon_state = "advanced_matter_bin"
	rating = 2
	energy_rating = 3
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT*0.8)

//Rating 3

/obj/item/stock_parts/capacitor/super
	name = "super capacitor"
	desc = "A super-high capacity capacitor used in the construction of a variety of devices."
	icon_state = "super_capacitor"
	rating = 3
	energy_rating = 5
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT*0.5, /datum/material/glass=SMALL_MATERIAL_AMOUNT*0.5)

/obj/item/stock_parts/scanning_module/phasic
	name = "phasic scanning module"
	desc = "A compact, high resolution phasic scanning module used in the construction of certain devices."
	icon_state = "super_scan_module"
	rating = 3
	energy_rating = 5
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT*0.5, /datum/material/glass=SMALL_MATERIAL_AMOUNT*0.2)

/obj/item/stock_parts/servo/pico
	name = "pico-servo"
	desc = "A tiny little servo motor used in the construction of certain devices."
	icon_state = "pico_servo"
	rating = 3
	energy_rating = 5
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT*0.3)

/obj/item/stock_parts/micro_laser/ultra
	name = "ultra-high-power micro-laser"
	icon_state = "ultra_high_micro_laser"
	desc = "A tiny laser used in certain devices."
	rating = 3
	energy_rating = 5
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT*0.1, /datum/material/glass=SMALL_MATERIAL_AMOUNT*0.2)

/obj/item/stock_parts/matter_bin/super
	name = "super matter bin"
	desc = "A container designed to hold compressed matter awaiting reconstruction."
	icon_state = "super_matter_bin"
	rating = 3
	energy_rating = 5
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT*0.8)

//Rating 4

/obj/item/stock_parts/capacitor/quadratic
	name = "quadratic capacitor"
	desc = "A capacity capacitor used in the construction of a variety of devices."
	icon_state = "quadratic_capacitor"
	rating = 4
	energy_rating = 10
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT*0.5, /datum/material/glass=SMALL_MATERIAL_AMOUNT*0.5)

/obj/item/stock_parts/scanning_module/triphasic
	name = "triphasic scanning module"
	desc = "A compact, ultra resolution triphasic scanning module used in the construction of certain devices."
	icon_state = "triphasic_scan_module"
	rating = 4
	energy_rating = 10
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT*0.5, /datum/material/glass=SMALL_MATERIAL_AMOUNT*0.2)

/obj/item/stock_parts/servo/femto
	name = "femto-servo"
	desc = "A tiny little servo motor used in the construction of certain devices."
	icon_state = "femto_servo"
	rating = 4
	energy_rating = 10
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT*0.3)

/obj/item/stock_parts/micro_laser/quadultra
	name = "quad-ultra micro-laser"
	icon_state = "quadultra_micro_laser"
	desc = "A tiny laser used in certain devices."
	rating = 4
	energy_rating = 10
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT*0.1, /datum/material/glass=SMALL_MATERIAL_AMOUNT*0.2)

/obj/item/stock_parts/matter_bin/bluespace
	name = "bluespace matter bin"
	desc = "A container designed to hold compressed matter awaiting reconstruction."
	icon_state = "bluespace_matter_bin"
	rating = 4
	energy_rating = 10
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT*0.8)

// Subspace stock parts

/obj/item/stock_parts/subspace
	name = "subspace stock part"
	desc = "What?"
	abstract_type = /obj/item/stock_parts/subspace

/obj/item/stock_parts/subspace/ansible
	name = "subspace ansible"
	icon_state = "subspace_ansible"
	desc = "A compact module capable of sensing extradimensional activity."
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT*0.3, /datum/material/glass=SMALL_MATERIAL_AMOUNT*0.1)

/obj/item/stock_parts/subspace/filter
	name = "hyperwave filter"
	icon_state = "hyperwave_filter"
	desc = "A tiny device capable of filtering and converting super-intense radio waves."
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT*0.3, /datum/material/glass=SMALL_MATERIAL_AMOUNT*0.1)

/obj/item/stock_parts/subspace/amplifier
	name = "subspace amplifier"
	icon_state = "subspace_amplifier"
	desc = "A compact micro-machine capable of amplifying weak subspace transmissions."
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT*0.3, /datum/material/glass=SMALL_MATERIAL_AMOUNT*0.1)

/obj/item/stock_parts/subspace/treatment
	name = "subspace treatment disk"
	icon_state = "treatment_disk"
	desc = "A compact micro-machine capable of stretching out hyper-compressed radio waves."
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT*0.3, /datum/material/glass=SMALL_MATERIAL_AMOUNT*0.1)

/obj/item/stock_parts/subspace/analyzer
	name = "subspace wavelength analyzer"
	icon_state = "wavelength_analyzer"
	desc = "A sophisticated analyzer capable of analyzing cryptic subspace wavelengths."
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT*0.3, /datum/material/glass=SMALL_MATERIAL_AMOUNT*0.1)

/obj/item/stock_parts/subspace/crystal
	name = "ansible crystal"
	icon_state = "ansible_crystal"
	desc = "A crystal made from pure glass used to transmit laser databursts to subspace."
	custom_materials = list(/datum/material/glass=SMALL_MATERIAL_AMOUNT*0.5)

/obj/item/stock_parts/subspace/transmitter
	name = "subspace transmitter"
	icon_state = "subspace_transmitter"
	desc = "A large piece of equipment used to open a window into the subspace dimension."
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT*0.5)

// Misc. Parts

/obj/item/stock_parts/card_reader
	name = "card reader"
	icon_state = "card_reader"
	desc = "A small magnetic card reader, used for devices that take and transmit holocredits."
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT*0.5, /datum/material/glass=SMALL_MATERIAL_AMOUNT*0.1)

/obj/item/stock_parts/water_recycler
	name = "water recycler"
	icon_state = "water_recycler"
	desc = "A chemical reclamation component, which serves to re-accumulate and filter water over time."
	custom_materials = list(/datum/material/plastic=SMALL_MATERIAL_AMOUNT * 2, /datum/material/iron=SMALL_MATERIAL_AMOUNT*0.5)

/obj/item/research//Makes testing much less of a pain -Sieve
	name = "research"
	icon = 'icons/obj/devices/stock_parts.dmi'
	icon_state = "capacitor"
	desc = "A debug item for research."
