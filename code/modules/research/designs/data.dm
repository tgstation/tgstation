/datum/design/intellicard
	name = "Intellicard AI Transportation System"
	desc = "Allows for the construction of an intellicard."
	id = "intellicard"
	req_tech = list("programming" = 4, "materials" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_GLASS = 1000, MAT_GOLD = 200)
	category = "Data"
	build_path = /obj/item/device/aicard

/datum/design/paicard
	name = "Personal Artificial Intelligence Card"
	desc = "Allows for the construction of a pAI Card"
	id = "paicard"
	req_tech = list("programming" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_GLASS = 500, MAT_IRON = 500)
	category = "Data"
	build_path = /obj/item/device/paicard

/datum/design/np_dispenser
	name = "Nano Paper Dispenser"
	desc = "A machine to create Nano Paper"
	id = "np_dispenser"
	req_tech = list("programming" = 2, "materials" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_GLASS = 500, MAT_IRON = 1000, MAT_GOLD = 500)
	category = "Data"
	build_path = /obj/item/weapon/paper_bin/nano

/datum/design/design_disk
	name = "Design Storage Disk"
	desc = "Produce additional disks for storing device designs."
	id = "design_disk"
	req_tech = list("programming" = 1)
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(MAT_IRON = 30, MAT_GLASS = 10)
	category = "Data"
	build_path = /obj/item/weapon/disk/design_disk

/datum/design/tech_disk
	name = "Technology Data Storage Disk"
	desc = "Produce additional disks for storing technology data."
	id = "tech_disk"
	req_tech = list("programming" = 1)
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(MAT_IRON = 30, MAT_GLASS = 10)
	category = "Data"
	build_path = /obj/item/weapon/disk/tech_disk
