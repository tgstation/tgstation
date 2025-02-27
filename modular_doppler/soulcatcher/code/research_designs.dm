/datum/design/soulcatcher_device
	name = "Evoker-Type RSD"
	desc = "An RSD instrument that lets the user pull the consciousness from a body and store it virtually."
	id = "soulcatcher_device"
	build_type = PROTOLATHE | AWAY_LATHE
	build_path = /obj/item/handheld_soulcatcher
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 3,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT,
		/datum/material/bluespace = SHEET_MATERIAL_AMOUNT,
	)
	category = list(
		RND_CATEGORY_TOOLS + RND_SUBCATEGORY_EQUIPMENT_MEDICAL,
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL | DEPARTMENT_BITFLAG_SCIENCE

/datum/design/mini_soulcatcher
	name = "Poltergeist-Type RSD"
	desc = "A miniature version of a Soulcatcher that can be attached to various objects."
	id = "mini_soulcatcher"
	build_type = PROTOLATHE | AWAY_LATHE
	build_path = /obj/item/attachable_soulcatcher
	materials = list(
		/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT,
	)
	category = list(
		RND_CATEGORY_AI + RND_SUBCATEGORY_AI_MISC,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_SERVICE | DEPARTMENT_BITFLAG_MEDICAL

/datum/design/rsd_interface
	name = "RSD Phylactery"
	desc = "A brain interface that allows for transfer of Resonance from a handheld RSD, such as the Evoker model."
	id = "rsd_interface"
	build_type = PROTOLATHE | AWAY_LATHE
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL | DEPARTMENT_BITFLAG_SCIENCE
	category = list(
		RND_CATEGORY_EQUIPMENT,
	)
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 0.5,
		/datum/material/gold = SHEET_MATERIAL_AMOUNT,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/rsd_interface
