/datum/loadout_category/face
	category_name = "Face"
	category_ui_icon = FA_ICON_MASK
	type_to_generate = /datum/loadout_item/mask
	tab_order = /datum/loadout_category/glasses::tab_order + 1

/*
*	LOADOUT ITEM DATUMS FOR THE MASK SLOT
*/
/datum/loadout_item/mask/pre_equip_item(datum/outfit/outfit, datum/outfit/outfit_important_for_life, mob/living/carbon/human/equipper, visuals_only = FALSE)
	if(initial(outfit_important_for_life.mask))
		..()
		return TRUE

/datum/loadout_item/mask
	abstract_type = /datum/loadout_item/mask

/datum/loadout_item/mask/insert_path_into_outfit(datum/outfit/outfit, mob/living/carbon/human/equipper, visuals_only = FALSE, override_items = LOADOUT_OVERRIDE_BACKPACK)
	if(override_items == LOADOUT_OVERRIDE_BACKPACK && !visuals_only)
		if(outfit.mask)
			LAZYADD(outfit.backpack_contents, outfit.mask)
		outfit.mask = item_path
	else
		outfit.mask = item_path

/datum/loadout_item/mask/face_mask
	name = "Face Mask"
	item_path = /obj/item/clothing/mask/breath

/datum/loadout_item/mask/gas
	name = "Gas Mask"
	item_path = /obj/item/clothing/mask/gas

/datum/loadout_item/mask/clown
	name = "Clown Mask"
	item_path = /obj/item/clothing/mask/gas/clown_hat

/datum/loadout_item/mask/balaclava
	name = "Balaclava"
	item_path = /obj/item/clothing/mask/balaclava

/datum/loadout_item/mask/gas/atmos
	name = "Atmos Gas Mask"
	item_path = /obj/item/clothing/mask/gas/atmos

/datum/loadout_item/mask/gas/explorer
	name = "Explorer Gas Mask"
	item_path = /obj/item/clothing/mask/gas/explorer

/datum/loadout_item/mask/whistle
	name = "Whistle"
	item_path = /obj/item/clothing/mask/whistle

/datum/loadout_item/mask/fakemoustache
	name = "Fake Moustache"
	item_path = /obj/item/clothing/mask/fakemoustache

/datum/loadout_item/mask/surgical
	name = "Surgical Mask"
	item_path = /obj/item/clothing/mask/surgical

/datum/loadout_item/mask/frontier
	name = "Frontier Gas Mask"
	item_path = /obj/item/clothing/mask/gas/atmos/frontier_colonist

/datum/loadout_item/mask/gas_cooler
	name = "Alternate Gas Mask"
	item_path = /obj/item/clothing/mask/gas/breach

/datum/loadout_item/mask/bandana
	name = "Bandana"
	item_path = /obj/item/clothing/mask/bandana

/datum/loadout_item/mask/bandana_stripe
	name = "Bandana (Stripe)"
	item_path = /obj/item/clothing/mask/bandana/striped

/datum/loadout_item/mask/bandana_skull
	name = "Bandana (Skull)"
	item_path = /obj/item/clothing/mask/bandana/skull

/datum/loadout_item/mask/neck_gaiter
	name = "Neck Gaiter"
	item_path = /obj/item/clothing/mask/neck_gaiter

/datum/loadout_item/mask/paper
	name = "Paper Mask"
	item_path = /obj/item/clothing/mask/paper

/datum/loadout_item/mask/kitsune
	name = "Kitsune Mask"
	item_path = /obj/item/clothing/mask/kitsune

/datum/loadout_item/mask/respirator
	name = "Half-Mask Respirator"
	item_path = /obj/item/clothing/mask/gas/respirator

/datum/loadout_item/mask/mantis
	name = "Composite Gas Mask"
	item_path = /obj/item/clothing/mask/gas/mantis

/datum/loadout_item/mask/half_face
	name = "Half-Face Rebreather"
	item_path = /obj/item/clothing/mask/gas/nightlight
