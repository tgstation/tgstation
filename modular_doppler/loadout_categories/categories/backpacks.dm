/datum/loadout_category/backpack
	category_name = "Back"
	category_ui_icon = FA_ICON_ARCHIVE
	type_to_generate = /datum/loadout_item/backpack
	tab_order = /datum/loadout_category/belt::tab_order + 1


/*
*	LOADOUT ITEM DATUMS FOR THE BACK SLOT
*/
/datum/loadout_item/backpack
	abstract_type = /datum/loadout_item/backpack

/datum/loadout_item/backpack/insert_path_into_outfit(datum/outfit/outfit, mob/living/carbon/human/equipper, visuals_only = FALSE)
	if(outfit.back)
		LAZYADD(outfit.backpack_contents, outfit.back)
	outfit.back = item_path



/datum/loadout_item/backpack
	name = "Custom Backpack"
	item_path = /obj/item/storage/backpack/custom

/datum/loadout_item/backpack/industrial
	name = "Custom Industrial Backpack"
	item_path = /obj/item/storage/backpack/industrial/custom

/datum/loadout_item/backpack/satchel
	name = "Custom Satchel"
	item_path = /obj/item/storage/backpack/satchel/custom

/datum/loadout_item/backpack/satchel/industrial
	name = "Custom Industrial Satchel"
	item_path = /obj/item/storage/backpack/satchel/eng/custom

/datum/loadout_item/backpack/duffel
	name = "Custom Duffelbag"
	item_path = /obj/item/storage/backpack/duffelbag/custom

/datum/loadout_item/backpack/adventurer
	name = "Adventurer's Bandolier"
	item_path = /obj/item/storage/backpack/satchel/crusader

/datum/loadout_item/backpack/duffel/industrial
	name = "Custom Industrial Duffelbag"
	item_path = /obj/item/storage/backpack/duffelbag/engineering/custom

/datum/loadout_item/backpack/messenger
	name = "Custom Messenger Bag"
	item_path = /obj/item/storage/backpack/messenger/custom

/datum/loadout_item/backpack/messenger/industrial
	name = "Custom Industrial Messenger Bag"
	item_path = /obj/item/storage/backpack/messenger/eng/custom
