/datum/loadout_category/suits
	category_name = "Suits"
	category_ui_icon = FA_ICON_USER_SECRET
	type_to_generate = /datum/loadout_item/suit
	tab_order = /datum/loadout_category/head::tab_order + 3

/datum/loadout_item/suit
	abstract_type = /datum/loadout_item/suit

/datum/loadout_item/suit/insert_path_into_outfit(datum/outfit/outfit, mob/living/carbon/human/equipper, visuals_only = FALSE)
	if(outfit.suit)
		LAZYADD(outfit.backpack_contents, outfit.suit)
	if(outfit.suit_store)
		LAZYADD(outfit.backpack_contents, outfit.suit_store)
		outfit.suit_store = null

	outfit.suit = item_path

/datum/loadout_item/suit/coverall
	name = "Coverall"
	item_path = /obj/item/clothing/suit/apron/overalls
	can_be_greyscale = DONT_GREYSCALE

/datum/loadout_item/suit/coverall/on_equip_item(obj/item/equipped_item, list/item_details, mob/living/carbon/human/equipper, datum/outfit/job/outfit, visuals_only = FALSE)
	. = ..()
	if(!outfit.palette)
		return
	equipped_item.set_greyscale(outfit.palette)
