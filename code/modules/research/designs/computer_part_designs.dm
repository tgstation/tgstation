////////////////////////////////////////
///////////Computer Parts///////////////
////////////////////////////////////////
// Data disks
/datum/design/portabledrive/basic
	name = "Data Disk"
	id = "portadrive_basic"
	build_type = IMPRINTER | AWAY_IMPRINTER
	materials = list(/datum/material/glass = 800)
	build_path = /obj/item/computer_disk
	category = list(
		RND_CATEGORY_MODULAR_COMPUTERS + RND_SUBCATEGORY_MODULAR_COMPUTERS_PARTS
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/portabledrive/advanced
	name = "Advanced Data Disk"
	id = "portadrive_advanced"
	build_type = IMPRINTER | AWAY_IMPRINTER
	materials = list(/datum/material/glass = 1600)
	build_path = /obj/item/computer_disk/advanced
	category = list(
		RND_CATEGORY_MODULAR_COMPUTERS + RND_SUBCATEGORY_MODULAR_COMPUTERS_PARTS
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/portabledrive/super
	name = "Super Data Disk"
	id = "portadrive_super"
	build_type = IMPRINTER | AWAY_IMPRINTER
	materials = list(/datum/material/glass = 3200)
	build_path = /obj/item/computer_disk/super
	category = list(
		RND_CATEGORY_MODULAR_COMPUTERS + RND_SUBCATEGORY_MODULAR_COMPUTERS_PARTS
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING
