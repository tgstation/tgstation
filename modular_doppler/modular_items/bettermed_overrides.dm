/// == TOOL UPDATE ZONE ==
/obj/item/scalpel
	icon = 'modular_doppler/modular_items/icons/bettermed.dmi'

/obj/item/cautery
	icon = 'modular_doppler/modular_items/icons/bettermed.dmi'

/obj/item/retractor
	icon = 'modular_doppler/modular_items/icons/bettermed.dmi'

/obj/item/hemostat
	icon = 'modular_doppler/modular_items/icons/bettermed.dmi'

/obj/item/bonesetter
	icon = 'modular_doppler/modular_items/icons/bettermed.dmi'

/obj/item/blood_filter
	icon = 'modular_doppler/modular_items/icons/bettermed.dmi'

/obj/item/circular_saw
	icon = 'modular_doppler/modular_items/icons/bettermed.dmi'

/obj/item/surgicaldrill
	icon = 'modular_doppler/modular_items/icons/bettermed.dmi'

/obj/item/scalpel/advanced
	icon = 'modular_doppler/modular_items/icons/bettermed.dmi'
	light_color = "#AAFF00"
	light_range = 2
	lefthand_file = 'modular_doppler/modular_items/icons/bettermed_lh.dmi'
	righthand_file = 'modular_doppler/modular_items/icons/bettermed_rh.dmi'

/obj/item/scalpel/advanced/on_transform(obj/item/source, mob/user, active)
	. = ..()
	if(active)
		set_light_range(2)
		set_light_color("#FFAA00")
	else
		set_light_range(2)
		set_light_color("#AAFF00")

/obj/item/retractor/advanced
	icon = 'modular_doppler/modular_items/icons/bettermed.dmi'
	lefthand_file = 'modular_doppler/modular_items/icons/bettermed_lh.dmi'
	righthand_file = 'modular_doppler/modular_items/icons/bettermed_rh.dmi'

/obj/item/cautery/advanced
	icon = 'modular_doppler/modular_items/icons/bettermed.dmi'
	lefthand_file = 'modular_doppler/modular_items/icons/bettermed_lh.dmi'
	righthand_file = 'modular_doppler/modular_items/icons/bettermed_rh.dmi'
	light_color = "#AAFF00"

/obj/item/cautery/advanced/on_transform(obj/item/source, mob/user, active)
	. = ..()
	if(active)
		set_light_color("#FFAA00")
	else
		set_light_color("#AAFF00")

/obj/item/surgical_drapes
	icon = 'modular_doppler/modular_items/icons/bettermed.dmi'



/// == STORAGE UPDATE ZONE ==
/obj/item/surgery_tray
	icon = 'modular_doppler/modular_items/icons/bettermed_medcart.dmi'

/obj/item/storage/medkit
	icon = 'modular_doppler/modular_items/icons/bettermed.dmi'
	lefthand_file = 'modular_doppler/modular_items/icons/bettermed_lh.dmi'
	righthand_file = 'modular_doppler/modular_items/icons/bettermed_rh.dmi'

/obj/item/storage/medkit/coroner
	icon = 'modular_doppler/modular_items/icons/bettermed.dmi'

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

/obj/item/storage/medkit/ancient
	icon = 'modular_doppler/modular_items/icons/bettermed.dmi'
	lefthand_file = 'modular_doppler/modular_items/icons/bettermed_lh.dmi'
	righthand_file = 'modular_doppler/modular_items/icons/bettermed_rh.dmi'
	icon_state = "medkit_old"
	inhand_icon_state = "oldkit"

/obj/item/storage/medkit/buffs
	name = "support medkit"
	desc = "An empty medkit for creative chemists to fill with concoctions."
	icon_state = "medkit_buffs"
	inhand_icon_state = "medkit-buffs"
	damagetype_healed = HEAL_ALL_DAMAGE
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
