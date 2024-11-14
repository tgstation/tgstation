/// Mask Slot Items (Deletes overrided items)
/datum/loadout_category/mask
	category_name = "Mask"
	category_ui_icon = FA_ICON_MASK
	type_to_generate = /datum/loadout_item/mask
	tab_order = /datum/loadout_category/head::tab_order + 2

/datum/loadout_item/mask
	abstract_type = /datum/loadout_item/mask

/datum/loadout_item/mask/insert_path_into_outfit(datum/outfit/outfit, mob/living/carbon/human/equipper, visuals_only = FALSE)
	if(equipper.dna?.species?.outfit_important_for_life)
		if(!visuals_only)
			to_chat(equipper, "Your loadout mask was not equipped directly due to your species outfit.")
			LAZYADD(outfit.backpack_contents, item_path)
	else
		outfit.mask = item_path

/datum/loadout_item/mask/moustache
	name = "Real Moustache"
	item_path = /obj/item/clothing/mask/fakemoustache

/datum/loadout_item/mask/moustache_italian
	name = "Italian Moustache"
	item_path = /obj/item/clothing/mask/fakemoustache/italian

/datum/loadout_item/mask/facescarf_greyscale
	name = "Facescarf (Colorable)"
	item_path = /obj/item/clothing/mask/facescarf

/datum/loadout_item/mask/bandana_skull
	name = "Skull Bandana (Colorable)"
	item_path = /obj/item/clothing/mask/bandana/skull

/datum/loadout_item/mask/bandana
	name = "Bandana (Colorable)"
	item_path = /obj/item/clothing/mask/bandana

/datum/loadout_item/mask/party_horn
	name = "Party Horn"
	item_path = /obj/item/clothing/mask/party_horn

/datum/loadout_item/mask/cigarette
	name = "Cigarette"
	item_path = /obj/item/cigarette

/datum/loadout_item/mask/cigarette_cigar
	name = "Cigar"
	item_path = /obj/item/cigarette/cigar

/datum/loadout_item/mask/cigarette_candy
	name = "Candy Cigarette"
	item_path = /obj/item/cigarette/candy

/datum/loadout_item/mask/swirl_lollipop
	name = "Large Lollipop"
	item_path = /obj/item/food/swirl_lollipop
