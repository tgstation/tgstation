/datum/design/gear_strap
	name = "Generic Equipment Strap"
	id = "generic_equipment_strap"
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(
		/datum/material/plastic = SHEET_MATERIAL_AMOUNT,
		/datum/material/titanium = HALF_SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/job_equipment_strap
	category = list(
		RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_MISC,
	)

/datum/design/gear_strap/service
	name = "Service Equipment Strap"
	id = "service_equipment_strap"
	build_type = PROTOLATHE
	build_path = /obj/item/job_equipment_strap/service
	category = list(
		RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_SERVICE,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SERVICE

/datum/design/gear_strap/medical
	name = "Medical Equipment Strap"
	id = "medical_equipment_strap"
	build_type = PROTOLATHE
	build_path = /obj/item/job_equipment_strap/medical
	category = list(
		RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_MEDICAL,
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

/datum/design/gear_strap/science
	name = "Science Equipment Strap"
	id = "science_equipment_strap"
	build_type = PROTOLATHE
	build_path = /obj/item/job_equipment_strap/science
	category = list(
		RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_SCIENCE,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/gear_strap/engineering
	name = "Engineering Equipment Strap"
	id = "engineering_equipment_strap"
	build_type = PROTOLATHE
	build_path = /obj/item/job_equipment_strap/engineering
	category = list(
		RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_ENGINEERING,
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/gear_strap/supply
	name = "Supply Equipment Strap"
	id = "supply_equipment_strap"
	build_type = PROTOLATHE
	build_path = /obj/item/job_equipment_strap/supply
	category = list(
		RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_MISC,
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO

/datum/design/gear_strap/security
	name = "Security Equipment Strap"
	id = "security_equipment_strap"
	build_type = PROTOLATHE
	build_path = /obj/item/job_equipment_strap/security
	category = list(
		RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_SECURITY,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/techweb_node/exp_tools/New()
	design_ids |= list(
		"security_equipment_strap",
		"supply_equipment_strap",
		"engineering_equipment_strap",
		"science_equipment_strap",
		"medical_equipment_strap",
		"service_equipment_strap",
		"generic_equipment_strap",
	)
	return ..()
