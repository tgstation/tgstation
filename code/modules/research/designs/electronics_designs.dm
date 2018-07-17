
///////////////////////////////////
/////Non-Board Computer Stuff//////
///////////////////////////////////

/datum/design/intellicard
	name = "Intellicard AI Transportation System"
	desc = "Allows for the construction of an intellicard."
	id = "intellicard"
	build_type = PROTOLATHE
	materials = list(MAT_GLASS = 1000, MAT_GOLD = 200)
	build_path = /obj/item/aicard
	category = list("Electronics")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/paicard
	name = "Personal Artificial Intelligence Card"
	desc = "Allows for the construction of a pAI Card."
	id = "paicard"
	build_type = PROTOLATHE
	materials = list(MAT_GLASS = 500, MAT_METAL = 500)
	build_path = /obj/item/paicard
	category = list("Electronics")
	departmental_flags = DEPARTMENTAL_FLAG_ALL

////////////////////////////////////////
//////////Disk Construction Disks///////
////////////////////////////////////////
/datum/design/design_disk
	name = "Design Storage Disk"
	desc = "Produce additional disks for storing device designs."
	id = "design_disk"
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(MAT_METAL = 300, MAT_GLASS = 100)
	build_path = /obj/item/disk/design_disk
	category = list("Electronics")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/design_disk_adv
	name = "Advanced Design Storage Disk"
	desc = "Produce additional disks for storing device designs."
	id = "design_disk_adv"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 300, MAT_GLASS = 100, MAT_SILVER=50)
	build_path = /obj/item/disk/design_disk/adv
	category = list("Electronics")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/tech_disk
	name = "Technology Data Storage Disk"
	desc = "Produce additional disks for storing technology data."
	id = "tech_disk"
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(MAT_METAL = 300, MAT_GLASS = 100)
	build_path = /obj/item/disk/tech_disk
	category = list("Electronics")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/integrated_printer
	name = "Integrated circuit printer"
	desc = "This machine provides all necessary things for circuitry."
	id = "icprinter"
	build_type = PROTOLATHE
	materials = list(MAT_GLASS = 5000, MAT_METAL = 10000)
	build_path = /obj/item/integrated_circuit_printer
	category = list("Electronics")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/IC_printer_upgrade_advanced
	name = "Integrated circuit printer upgrade: Advanced Designs"
	desc = "This disk allows for integrated circuit printers to print advanced circuitry designs."
	id = "icupgadv"
	build_type = PROTOLATHE
	materials = list(MAT_GLASS = 10000, MAT_METAL = 10000)
	build_path = /obj/item/disk/integrated_circuit/upgrade/advanced
	category = list("Electronics")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/IC_printer_upgrade_clone
	name = "Integrated circuit printer upgrade: Instant Cloning"
	desc = "This disk allows for integrated circuit printers to clone designs instantaneously."
	id = "icupgclo"
	build_type = PROTOLATHE
	materials = list(MAT_GLASS = 10000, MAT_METAL = 10000)
	build_path = /obj/item/disk/integrated_circuit/upgrade/clone
	category = list("Electronics")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE
