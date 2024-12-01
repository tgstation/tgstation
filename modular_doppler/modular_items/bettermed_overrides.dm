// Empty medkits

/obj/item/storage/medkit/empty
	empty = TRUE

/obj/item/storage/medkit/brute/empty
	empty = TRUE

/obj/item/storage/medkit/fire/empty
	empty = TRUE

/obj/item/storage/medkit/toxin/empty
	empty = TRUE

/obj/item/storage/medkit/o2/empty
	empty = TRUE

/obj/item/storage/medkit/surgery/empty
	empty = TRUE

/obj/item/storage/medkit/advanced/empty
	empty = TRUE

/// == RECIPE ADDITION ZONE ==
/datum/design/spare_medkit
	name = "Medkit"
	id = "medkit"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(
		/datum/material/plastic = SHEET_MATERIAL_AMOUNT * 5,
		/datum/material/iron = SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/storage/medkit/empty
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_MEDICAL,
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

/datum/design/spare_medkit/brute
	name = "Brute Medkit"
	id = "medkit_brute"
	build_path = /obj/item/storage/medkit/brute/empty

/datum/design/spare_medkit/burn
	name = "Burn Medkit"
	id = "medkit_burn"
	build_path = /obj/item/storage/medkit/fire/empty

/datum/design/spare_medkit/toxin
	name = "Toxin Medkit"
	id = "medkit_toxin"
	build_path = /obj/item/storage/medkit/toxin/empty

/datum/design/spare_medkit/o2
	name = "Oxyloss Medkit"
	id = "medkit_o2"
	build_path = /obj/item/storage/medkit/o2/empty

/datum/design/spare_medkit/buffs
	name = "Support Medkit"
	id = "medkit_buffs"
	build_path = /obj/item/storage/medkit/buffs

/datum/techweb_node/medbay_equip/New()
	design_ids += list(
		"medkit",
		"medkit_brute",
		"medkit_burn",
		"medkit_toxin",
		"medkit_o2",
		"medkit_buffs",
	)
	return ..()

/datum/design/spare_medkit_advanced
	name = "Advanced Medkit"
	id = "medkit_advanced"
	build_type = PROTOLATHE
	materials = list(
		/datum/material/plastic = SHEET_MATERIAL_AMOUNT * 5,
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 3,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT * 1,
	)
	build_path = /obj/item/storage/medkit/advanced/empty
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_MEDICAL,
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

/datum/design/spare_medkit_advanced/surgery
	name = "Surgical Medkit"
	id = "medkit_surgery"
	build_path = /obj/item/storage/medkit/surgery/empty

/datum/techweb_node/medbay_equip_adv/New()
	design_ids += list(
		"medkit_advanced",
		"medkit_surgery",
	)
	return ..()
