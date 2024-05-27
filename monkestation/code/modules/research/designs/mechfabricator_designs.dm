/datum/design/borg_upgrade_uwu
	name = "Cyborg UwU-speak \"Upgrade\""
	id = "borg_upgrade_cringe"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/uwu
	materials = list(/datum/material/gold = 2000, /datum/material/diamond = 1000, /datum/material/bluespace = 500)
	construction_time = 12 SECONDS
	category = list(
		RND_CATEGORY_MECHFAB_CYBORG_MODULES + RND_SUBCATEGORY_MECHFAB_CYBORG_MODULES_ALL
	)

//IPC Parts//

/datum/design/ipc_part_head
	name = "IPC Replacement Head"
	id = "ipc_head"
	build_type = MECHFAB
	construction_time = 15 SECONDS
	materials = list(/datum/material/iron = 4000, /datum/material/glass = 500)
	build_path = /obj/item/bodypart/head/robot/ipc
	category = list(
		RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_ORGANS_MISC
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

/datum/design/ipc_part_chest
	name = "IPC Replacement Chest"
	id = "ipc_chest"
	build_type = MECHFAB
	construction_time = 15 SECONDS
	materials = list(/datum/material/iron = 5000)
	build_path = /obj/item/bodypart/chest/robot/ipc
	category = list(
		RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_ORGANS_MISC
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

/datum/design/ipc_part_arm_left
	name = "IPC Replacement Left Arm"
	id = "ipc_arm_left"
	build_type = MECHFAB
	construction_time = 15 SECONDS
	materials = list(/datum/material/iron = 2000)
	build_path = /obj/item/bodypart/arm/left/robot/ipc
	category = list(
		RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_ORGANS_MISC
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

/datum/design/ipc_part_arm_right
	name = "IPC Replacement Right Arm"
	id = "ipc_arm_right"
	build_type = MECHFAB
	construction_time = 15 SECONDS
	materials = list(/datum/material/iron = 2000)
	build_path = /obj/item/bodypart/arm/right/robot/ipc
	category = list(
		RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_ORGANS_MISC
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

/datum/design/ipc_part_leg_left
	name = "IPC Replacement Left Leg"
	id = "ipc_leg_left"
	build_type = MECHFAB
	construction_time = 15 SECONDS
	materials = list(/datum/material/iron = 2000)
	build_path = /obj/item/bodypart/leg/left/robot/ipc
	category = list(
		RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_ORGANS_MISC
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

/datum/design/ipc_part_leg_right
	name = "IPC Replacement Right Leg"
	id = "ipc_leg_right"
	build_type = MECHFAB
	construction_time = 15 SECONDS
	materials = list(/datum/material/iron = 2000)
	build_path = /obj/item/bodypart/leg/right/robot/ipc
	category = list(
		RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_ORGANS_MISC
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL
