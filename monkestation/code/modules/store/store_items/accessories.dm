
GLOBAL_LIST_INIT(store_accessory, generate_store_items(/datum/store_item/accessory))


/datum/store_item/accessory
	category = LOADOUT_ITEM_ACCESSORY
	item_cost = 2500

/datum/store_item/accessory/maid_apron
	name = "Maid Apron"
	item_path = /obj/item/clothing/accessory/maidapron
	item_cost = 5000

/datum/store_item/accessory/waistcoat
	name = "Waistcoat"
	item_path = /obj/item/clothing/accessory/waistcoat

/datum/store_item/accessory/pocket_protector
	name = "Pocket Protector (Empty)"
	item_path = /obj/item/clothing/accessory/pocketprotector

/datum/store_item/accessory/full_pocket_protector
	name = "Pocket Protector (Filled)"
	item_path = /obj/item/clothing/accessory/pocketprotector/full

/datum/store_item/accessory/ribbon
	name = "Ribbon"
	item_path = /obj/item/clothing/accessory/medal/ribbon


/*
*	ARMBANDS
*/

/datum/store_item/accessory/armband_medblue
	name = "Medical Armband (blue stripe)"
	item_path = /obj/item/clothing/accessory/armband/medblue

/datum/store_item/accessory/armband_med
	name = "Medical Armband (white)"
	item_path = /obj/item/clothing/accessory/armband/med

/datum/store_item/accessory/armband_cargo
	name = "Cargo Armband"
	item_path = /obj/item/clothing/accessory/armband/cargo

/datum/store_item/accessory/armband_engineering
	name = "Engineering Armband"
	item_path = /obj/item/clothing/accessory/armband/engine

/datum/store_item/accessory/armband_science
	name = "Science Armband"
	item_path = /obj/item/clothing/accessory/armband/science
