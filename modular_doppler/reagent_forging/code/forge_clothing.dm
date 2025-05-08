// Vests
/obj/item/clothing/suit/armor/forging_plate_armor
	name = "reagent plate vest"
	desc = "An armor vest made of hammered, interlocking plates."
	icon = 'modular_doppler/reagent_forging/icons/obj/forge_clothing.dmi'
	worn_icon = 'modular_doppler/reagent_forging/icons/mob/clothing/forge_clothing.dmi'
	icon_state = "plate_vest"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	resistance_flags = FIRE_PROOF
	obj_flags_doppler = ANVIL_REPAIR
	armor_type = /datum/armor/armor_forging_plate_armor
	material_flags = MATERIAL_EFFECTS | MATERIAL_ADD_PREFIX | MATERIAL_COLOR

/datum/armor/armor_forging_plate_armor
	melee = 40
	bullet = 40
	fire = 50
	wound = 30

/obj/item/clothing/suit/armor/forging_plate_armor/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/armor_plate, 4)
	AddComponent(/datum/component/reagent_clothing, ITEM_SLOT_OCLOTHING)

	allowed += /obj/item/forging/reagent_weapon

// Gloves
/obj/item/clothing/gloves/forging_plate_gloves
	name = "reagent plate gloves"
	desc = "A set of leather gloves with protective armor plates connected to the wrists."
	icon = 'modular_doppler/reagent_forging/icons/obj/forge_clothing.dmi'
	worn_icon = 'modular_doppler/reagent_forging/icons/mob/clothing/forge_clothing.dmi'
	icon_state = "plate_gloves"
	resistance_flags = FIRE_PROOF
	obj_flags_doppler = ANVIL_REPAIR
	armor_type = /datum/armor/gloves_forging_plate_gloves
	material_flags = MATERIAL_EFFECTS | MATERIAL_ADD_PREFIX | MATERIAL_COLOR
	body_parts_covered = HANDS|ARMS

/datum/armor/gloves_forging_plate_gloves
	melee = 40
	bullet = 40
	fire = 50
	wound = 30

/obj/item/clothing/gloves/forging_plate_gloves/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/armor_plate, 4)
	AddComponent(/datum/component/reagent_clothing, ITEM_SLOT_GLOVES)

// Helmets
/obj/item/clothing/head/helmet/forging_plate_helmet
	name = "reagent plate helmet"
	desc = "A helmet out of hammered plates with a leather neck guard and chin strap."
	icon = 'modular_doppler/reagent_forging/icons/obj/forge_clothing.dmi'
	worn_icon = 'modular_doppler/reagent_forging/icons/mob/clothing/forge_clothing.dmi'
	icon_state = "plate_helmet"
	resistance_flags = FIRE_PROOF
	flags_inv = null
	obj_flags_doppler = ANVIL_REPAIR
	armor_type = /datum/armor/helmet_forging_plate_helmet
	material_flags = MATERIAL_EFFECTS | MATERIAL_ADD_PREFIX | MATERIAL_COLOR

/datum/armor/helmet_forging_plate_helmet
	melee = 40
	bullet = 40
	fire = 50
	wound = 30

/obj/item/clothing/head/helmet/forging_plate_helmet/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/armor_plate, 4)
	AddComponent(/datum/component/reagent_clothing, ITEM_SLOT_HEAD)

// Boots
/obj/item/clothing/shoes/forging_plate_boots
	name = "reagent plate boots"
	desc = "A pair of leather boots with protective armor plates over the shins and toes."
	icon = 'modular_doppler/reagent_forging/icons/obj/forge_clothing.dmi'
	worn_icon = 'modular_doppler/reagent_forging/icons/mob/clothing/forge_clothing.dmi'
	supported_bodyshapes = list(BODYSHAPE_HUMANOID, BODYSHAPE_DIGITIGRADE)
	bodyshape_icon_files = list(BODYSHAPE_HUMANOID_T = 'modular_doppler/reagent_forging/icons/mob/clothing/forge_clothing.dmi',
		BODYSHAPE_DIGITIGRADE_T = 'modular_doppler/reagent_forging/icons/mob/clothing/forge_clothing_digi.dmi')
	icon_state = "plate_boots"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION
	armor_type = /datum/armor/shoes_forging_plate_boots
	material_flags = MATERIAL_EFFECTS | MATERIAL_ADD_PREFIX | MATERIAL_COLOR
	resistance_flags = FIRE_PROOF
	obj_flags_doppler = ANVIL_REPAIR
	fastening_type = SHOES_STRAPS
	body_parts_covered = FEET|LEGS

/datum/armor/shoes_forging_plate_boots
	melee = 20
	bullet = 20

/obj/item/clothing/shoes/forging_plate_boots/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/armor_plate, 2)
	AddComponent(/datum/component/reagent_clothing, ITEM_SLOT_FEET)

// Misc
/obj/item/clothing/gloves/ring/reagent_clothing
	name = "reagent ring"
	desc = "A tiny ring, sized to wrap around a finger."
	icon_state = "ringsilver"
	worn_icon_state = "sring"
	inhand_icon_state = "ringsilver"
	material_flags = MATERIAL_EFFECTS | MATERIAL_ADD_PREFIX | MATERIAL_COLOR
	obj_flags_doppler = ANVIL_REPAIR

/obj/item/clothing/gloves/ring/reagent_clothing/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/reagent_clothing, ITEM_SLOT_GLOVES)

/obj/item/clothing/neck/collar/reagent_clothing
	name = "reagent collar"
	desc = "A collar that is ready to be worn for certain individuals."
	icon = 'modular_doppler/reagent_forging/icons/obj/forge_clothing.dmi'
	worn_icon = 'modular_doppler/reagent_forging/icons/mob/clothing/forge_clothing.dmi'
	icon_state = "collar"
	inhand_icon_state = null
	body_parts_covered = NECK
	slot_flags = ITEM_SLOT_NECK
	w_class = WEIGHT_CLASS_SMALL
	material_flags = MATERIAL_EFFECTS | MATERIAL_ADD_PREFIX | MATERIAL_COLOR
	obj_flags_doppler = ANVIL_REPAIR

/obj/item/clothing/neck/collar/reagent_clothing/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/reagent_clothing, ITEM_SLOT_NECK)

/obj/item/restraints/handcuffs/reagent_clothing
	name = "reagent handcuffs"
	desc = "A pair of handcuffs that are ready to keep someone captive."
	material_flags = MATERIAL_EFFECTS | MATERIAL_ADD_PREFIX | MATERIAL_COLOR
	obj_flags_doppler = ANVIL_REPAIR

/obj/item/restraints/handcuffs/reagent_clothing/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/reagent_clothing, ITEM_SLOT_HANDCUFFED)
