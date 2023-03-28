GLOBAL_LIST_INIT(store_ears, generate_store_items(/datum/store_item/ears))

/datum/store_item/ears
	category = LOADOUT_ITEM_EARS
	item_cost = 500

/datum/store_item/ears/headphones
	name = "Headphones"
	item_path = /obj/item/instrument/piano_synth/headphones

/datum/store_item/ears/earmuffs
	name = "Earmuffs"
	item_path = /obj/item/clothing/ears/earmuffs
