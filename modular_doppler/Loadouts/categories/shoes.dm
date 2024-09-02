/datum/loadout_category/feet
	category_name = "Feet"
	category_ui_icon = FA_ICON_SHOE_PRINTS
	type_to_generate = /datum/loadout_item/shoes
	tab_order = /datum/loadout_category/glasses::tab_order + 1

/*
*	LOADOUT ITEM DATUMS FOR THE SHOE SLOT
*/
/datum/loadout_item/shoes
	abstract_type = /datum/loadout_item/shoes


/datum/loadout_item/shoes/insert_path_into_outfit(datum/outfit/outfit, mob/living/carbon/human/equipper, visuals_only = FALSE)
	if(outfit.shoes)
		LAZYADD(outfit.backpack_contents, outfit.shoes)
	outfit.shoes = item_path

/datum/loadout_item/shoes/jackboots
	name = "Jackboots"
	item_path = /obj/item/clothing/shoes/jackboots

/datum/loadout_item/shoes/sneakers/white
	name = "White Sneakers"
	item_path = /obj/item/clothing/shoes/sneakers/white

/datum/loadout_item/shoes/sneakers/rainbow
	name = "Rainbow Sneakers"
	item_path = /obj/item/clothing/shoes/sneakers/rainbow

/datum/loadout_item/shoes/workboots
	name = "Work Boots"
	item_path = /obj/item/clothing/shoes/workboots

/datum/loadout_item/shoes/workboots/mining
	name = "Mining Boots"
	item_path = /obj/item/clothing/shoes/workboots/mining

/datum/loadout_item/shoes/laceup
	name = "Lace-Up Shoes"
	item_path = /obj/item/clothing/shoes/laceup

/datum/loadout_item/shoes/sandal
	name = "Sandals"
	item_path = /obj/item/clothing/shoes/sandal

/datum/loadout_item/shoes/magboots
	name = "Magboots"
	item_path = /obj/item/clothing/shoes/magboots

/datum/loadout_item/shoes/winterboots
	name = "Winter Boots"
	item_path = /obj/item/clothing/shoes/winterboots

/datum/loadout_item/shoes/clown_shoes
	name = "Clown Shoes"
	item_path = /obj/item/clothing/shoes/clown_shoes

/datum/loadout_item/shoes/jester_shoes
	name = "Jester Shoes"
	item_path = /obj/item/clothing/shoes/jester_shoes

/datum/loadout_item/shoes/ducky_shoes
	name = "Ducky Shoes"
	item_path = /obj/item/clothing/shoes/ducky_shoes

/datum/loadout_item/shoes/wheelys
	name = "Wheelys"
	item_path = /obj/item/clothing/shoes/wheelys

/datum/loadout_item/shoes/cowboy
	name = "Cowboy Boots"
	item_path = /obj/item/clothing/shoes/cowboy

/datum/loadout_item/shoes/cowboy/lizard
	name = "Lizard Cowboy Boots"
	item_path = /obj/item/clothing/shoes/cowboy/lizard

/datum/loadout_item/shoes/russian
	name = "Russian Boots"
	item_path = /obj/item/clothing/shoes/russian

/datum/loadout_item/shoes/pirate
	name = "Pirate Boots"
	item_path = /obj/item/clothing/shoes/pirate


