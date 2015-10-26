/datum/design/basic_cell
	name = "Basic Power Cell"
	desc = "A basic power cell that holds 1000 units of energy"
	id = "basic_cell"
	req_tech = list("powerstorage" = 1)
	build_type = PROTOLATHE | AUTOLATHE | MECHFAB | PODFAB
	materials = list(MAT_IRON = 700, MAT_GLASS = 50)
	build_path = /obj/item/weapon/cell
	category = "Engineering"

/datum/design/high_cell
	name = "High-Capacity Power Cell"
	desc = "A power cell that holds 10000 units of energy"
	id = "high_cell"
	req_tech = list("powerstorage" = 2)
	build_type = PROTOLATHE | AUTOLATHE | MECHFAB | PODFAB
	materials = list(MAT_IRON = 700, MAT_GLASS = 60)
	build_path = /obj/item/weapon/cell/high
	category = "Engineering"

/datum/design/super_cell
	name = "Super-Capacity Power Cell"
	desc = "A power cell that holds 20000 units of energy"
	id = "super_cell"
	req_tech = list("powerstorage" = 3, "materials" = 2)
	reliability_base = 75
	build_type = PROTOLATHE | MECHFAB | PODFAB
	materials = list(MAT_IRON = 700, MAT_GLASS = 70)
	build_path = /obj/item/weapon/cell/super
	category = "Engineering"

/datum/design/hyper_cell
	name = "Hyper-Capacity Power Cell"
	desc = "A power cell that holds 30000 units of energy"
	id = "hyper_cell"
	req_tech = list("powerstorage" = 5, "materials" = 4)
	reliability_base = 70
	build_type = PROTOLATHE | MECHFAB | PODFAB
	materials = list(MAT_IRON = 400, MAT_GOLD = 150, MAT_SILVER = 150, MAT_GLASS = 70)
	build_path = /obj/item/weapon/cell/hyper
	category = "Engineering"

/datum/design/light_replacer
	name = "Light Replacer"
	desc = "A device to automatically replace lights. Refill with working lightbulbs."
	id = "light_replacer"
	req_tech = list("magnets" = 3, "materials" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 1500, MAT_SILVER = 150, MAT_GLASS = 3000)
	category = "Engineering"
	build_path = /obj/item/device/lightreplacer

/datum/design/superior_welding_goggles
	name = "Superior Welding Goggles"
	desc = "Welding goggles made from more expensive materials, strangely smells like potatoes. Allows for better vision than normal goggles.."
	id = "superior_welding_goggles"
	req_tech = list("materials" = 3, "engineering" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 500, MAT_GLASS = 1500)
	category = "Engineering"
	build_path = /obj/item/clothing/glasses/welding/superior

/datum/design/night_vision_goggles
	name = "Night Vision Goggles"
	desc = "You can totally see in the dark now!."
	id = "night_vision_goggles"
	req_tech = list("materials" = 5, "engineering" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 700, MAT_GLASS = 2000, MAT_GOLD = 100)
	category = "Engineering"
	build_path = /obj/item/clothing/glasses/night

/datum/design/device_analyser
	name = "Device Analyser"
	desc = "A device for scanning other devices. Meta."
	id = "deviceanalyser"
	req_tech = list("magnets"=3, "engineering"=4, "materials"=4, "programming"=3)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 500, MAT_GLASS = 1000, MAT_GOLD = 200, MAT_SILVER = 200)
	category = "Engineering"
	build_path = /obj/item/device/device_analyser

//Sadly there is no file "trash.dm"
/*
/datum/design/component_exchanger
	name = "Rapid Machinery Component Exchanger"
	desc = "A device that allows to quickly replace machinery components, useful for upgrading."
	id = "componentexchanger"
	req_tech = list("engineering"=4, "materials"=4, "programming"=2)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 500, MAT_GLASS = 1000, MAT_GOLD = 200, MAT_SILVER = 200)
	category = "Engineering"
	build_path = /obj/item/weapon/storage/component_exchanger
*/

/datum/design/RPED
	name = "Rapid Part Exchange Device"
	desc = "Special mechanical module made to store, sort, and apply standard machine parts."
	id = "rped"
	req_tech = list("engineering" = 4, "materials" = 4, "programming" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 500, MAT_GLASS = 1000, MAT_PLASTIC = 20000)
	build_path = /obj/item/weapon/storage/bag/gadgets/part_replacer
	category = "Engineering"

/datum/design/mat_synth
	name = "Material Synthesizer"
	desc = "A device capable of producing very little rare material with a whole lot of investment."
	id = "mat_synth"
	req_tech = list("engineering" = 4, "materials" = 5, "powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list (MAT_IRON = 3000, MAT_GLASS = 1500, MAT_DIAMOND = 1000, MAT_URANIUM = 3000)
	category = "Engineering"
	build_path = /obj/item/device/material_synth

/datum/design/adv_silicate_sprayer
	name = "Advanced Silicate Sprayer"
	desc = "An advanced tool to repair and reinforce windows."
	id = "adv_silicate_sprayer"
	req_tech = list("engineering" = 3, "materials" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 700, MAT_GLASS = 50, MAT_SILVER = 50)
	build_path = /obj/item/device/silicate_sprayer/advanced/empty
	category = "Engineering"