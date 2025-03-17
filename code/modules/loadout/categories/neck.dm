/// Neck Slot Items (Deletes overrided items)
/datum/loadout_category/neck
	category_name = "Neck"
	category_ui_icon = FA_ICON_USER_TIE
	type_to_generate = /datum/loadout_item/neck
	tab_order = /datum/loadout_category/head::tab_order + 2

/datum/loadout_item/neck
	abstract_type = /datum/loadout_item/neck
/* DOPPLER EDIT START: ORIGINAL:
/datum/loadout_item/neck/insert_path_into_outfit(datum/outfit/outfit, mob/living/carbon/human/equipper, visuals_only = FALSE)
	outfit.neck = item_path
*/

/datum/loadout_item/neck/insert_path_into_outfit(datum/outfit/outfit, mob/living/carbon/human/equipper, visuals_only = FALSE, override_items = LOADOUT_OVERRIDE_BACKPACK)
	if(override_items == LOADOUT_OVERRIDE_BACKPACK && !visuals_only)
		if(outfit.neck)
			LAZYADD(outfit.backpack_contents, outfit.neck)
		outfit.neck = item_path
	else
		outfit.neck = item_path
// DOPPLER EDIT END

/datum/loadout_item/neck/scarf_greyscale
	name = "Scarf (Colorable)"
	item_path = /obj/item/clothing/neck/scarf

/datum/loadout_item/neck/greyscale_large
	name = "Scarf (Large, Colorable)"
	item_path = /obj/item/clothing/neck/large_scarf

/datum/loadout_item/neck/greyscale_larger
	name = "Scarf (Larger, Colorable)"
	item_path = /obj/item/clothing/neck/infinity_scarf

/datum/loadout_item/neck/necktie
	name = "Necktie (Colorable)"
	item_path = /obj/item/clothing/neck/tie

/datum/loadout_item/neck/necktie_disco
	name = "Necktie (Ugly)"
	item_path = /obj/item/clothing/neck/tie/horrible

/datum/loadout_item/neck/necktie_loose
	name = "Necktie (Loose)"
	item_path = /obj/item/clothing/neck/tie/detective
