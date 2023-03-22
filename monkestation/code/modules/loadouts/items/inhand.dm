/*
*	LOADOUT ITEM DATUMS FOR BOTH HAND SLOTS
*/

/// Inhand items (Moves overrided items to backpack)
GLOBAL_LIST_INIT(loadout_inhand_items, generate_loadout_items(/datum/loadout_item/inhand))

/datum/loadout_item/inhand
	category = LOADOUT_ITEM_INHAND

/datum/loadout_item/inhand/pre_equip_item(datum/outfit/outfit, datum/outfit/outfit_important_for_life, mob/living/carbon/human/equipper, visuals_only = FALSE)
	// if no hands are available then put in backpack
	if(initial(outfit_important_for_life.r_hand) && initial(outfit_important_for_life.l_hand))
		if(!visuals_only)
			LAZYADD(outfit.backpack_contents, item_path)
		return TRUE

/datum/loadout_item/inhand/insert_path_into_outfit(datum/outfit/outfit, mob/living/carbon/human/equipper, visuals_only = FALSE, override_items = LOADOUT_OVERRIDE_BACKPACK)
	if(outfit.l_hand && !outfit.r_hand)
		outfit.r_hand = item_path
	else
		if(outfit.l_hand)
			LAZYADD(outfit.backpack_contents, outfit.l_hand)
		outfit.l_hand = item_path

/datum/loadout_item/inhand/cane
	name = "Cane"
	item_path = /obj/item/cane

/datum/loadout_item/inhand/cane/white
	name = "White Cane"
	item_path = /obj/item/cane/white

/datum/loadout_item/inhand/briefcase
	name = "Briefcase"
	item_path = /obj/item/storage/briefcase

/datum/loadout_item/inhand/briefcase_secure
	name = "Secure Briefcase"
	item_path = /obj/item/storage/secure/briefcase

/datum/loadout_item/inhand/skub
	name = "Skub"
	item_path = /obj/item/skub

/datum/loadout_item/inhand/skateboard
	name = "Skateboard"
	item_path = /obj/item/melee/skateboard

/datum/loadout_item/inhand/bouquet_mixed
	name = "Mixed Bouquet"
	item_path = /obj/item/bouquet

/datum/loadout_item/inhand/bouquet_sunflower
	name = "Sunflower Bouquet"
	item_path = /obj/item/bouquet/sunflower

/datum/loadout_item/inhand/bouquet_poppy
	name = "Poppy Bouquet"
	item_path = /obj/item/bouquet/poppy

/datum/loadout_item/inhand/bouquet_rose
	name = "Rose Bouquet"
	item_path = /obj/item/bouquet/rose

/datum/loadout_item/inhand/smokingpipe
	name = "Smoking Pipe"
	item_path = /obj/item/clothing/mask/cigarette/pipe
