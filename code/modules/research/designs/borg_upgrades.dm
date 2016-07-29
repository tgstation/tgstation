/datum/design/borg_syndicate_module
	name = "Borg Illegal Weapons Upgrade"
	desc = "Allows for the construction of illegal upgrades for cyborgs"
	id = "borg_syndicate_module"
	build_type = MECHFAB
	req_tech = list("combat" = 4, "syndicate" = 3)
	build_path = /obj/item/borg/upgrade/syndicate
	category = "Robotic_Upgrade_Modules"
	materials = list(MAT_IRON=10000,MAT_GLASS=15000,MAT_DIAMOND = 10000)

/datum/design/borg_engineer_upgrade
	name = "engineering module board"
	desc = "Used to give an engineering cyborg more materials."
	id = "borg_engineer_module"
	build_type = MECHFAB
	req_tech = list("engineering" = 1)
	build_path = /obj/item/borg/upgrade/engineering
	category = "Robotic_Upgrade_Modules"
	materials = list(MAT_IRON=10000,MAT_GLASS=10000,MAT_PLASMA=5000)

/datum/design/medical_module_surgery
	name = "medical module board"
	desc = "Used to give a medical cyborg surgery tools."
	id = "medical_module_surgery"
	req_tech = list("biotech" = 3, "engineering" = 3)
	build_type = MECHFAB
	materials = list(MAT_IRON = 80000, MAT_GLASS = 20000)
	build_path = /obj/item/borg/upgrade/medical/surgery
	category = "Robotic_Upgrade_Modules"

/datum/design/borg_service_upgrade
	name = "service module board"
	desc = "Used to give a service cyborg cooking tools."
	id = "borg_service_module"
	req_tech = list("biotech" = 2, "engineering" = 3, "programming" = 2)
	build_type = MECHFAB
	materials = list(MAT_IRON = 60000, MAT_GLASS = 10000)
	build_path = /obj/item/borg/upgrade/service
	category = "Robotic_Upgrade_Modules"

/datum/design/borg_reset_board
	name = "cyborg reset module"
	desc = "Used to reset cyborgs to their default module."
	id = "borg_reset_board"
	req_tech = list("engineering" = 1)
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/reset
	category = "Robotic_Upgrade_Modules"
	materials = list(MAT_IRON=10000)

/datum/design/borg_rename_board
	name = "cyborg rename module"
	desc = "Used to rename cyborgs."
	id = "borg_rename_board"
	req_tech = list("engineering" = 1)
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/rename
	category = "Robotic_Upgrade_Modules"
	materials = list(MAT_IRON=35000)

/datum/design/borg_restart_board
	name = "cyborg restart module"
	desc = "Used to restart cyborgs."
	id = "borg_restart_board"
	req_tech = list("engineering" = 1)
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/restart
	category = "Robotic_Upgrade_Modules"
	materials = list(MAT_IRON=60000 , MAT_GLASS=5000)

/datum/design/borg_vtec_board
	name = "cyborg VTEC module"
	desc = "Used to upgrade a borg's speed."
	id = "borg_vtec_board"
	req_tech = list("engineering" = 1)
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/vtec
	category = "Robotic_Upgrade_Modules"
	materials = list(MAT_IRON=80000, MAT_GLASS=6000, MAT_GOLD= 5000)

/datum/design/borg_tasercooler_board
	name = "cyborg taser cooling module"
	desc = "Used to upgrade cyborg taser cooling."
	id = "borg_tasercooler_board"
	req_tech = list("combat" = 1)
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/tasercooler
	category = "Robotic_Upgrade_Modules"
	materials = list(MAT_IRON=80000 , MAT_GLASS=6000 , MAT_GOLD= 2000, MAT_DIAMOND = 500)

/datum/design/borg_jetpack_board
	name = "cyborg jetpack module"
	desc = "Used to give cyborgs a jetpack."
	id = "borg_jetpack_board"
	req_tech = list("engineering" = 1)
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/jetpack
	category = "Robotic_Upgrade_Modules"
	materials = list(MAT_IRON=10000,MAT_PLASMA=15000,MAT_URANIUM = 20000)
