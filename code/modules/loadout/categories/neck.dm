// --- Loadout item datums for neck items ---

/// Neck Slot Items (Deletes overrided items)
/datum/loadout_category/neck
	category_name = "Neck"
	ui_title = "Neck Slot Items"
	type_to_generate = /datum/loadout_item/neck

/datum/loadout_item/neck
	abstract_type = /datum/loadout_item/neck

/datum/loadout_item/neck/insert_path_into_outfit(datum/outfit/outfit, mob/living/carbon/human/equipper, visuals_only = FALSE)
	outfit.neck = item_path

/datum/loadout_item/neck/scarf_greyscale
	name = "Greyscale Scarf"
	item_path = /obj/item/clothing/neck/scarf

/datum/loadout_item/neck/scarf_christmas
	name = "Christmas Scarf"
	item_path = /obj/item/clothing/neck/scarf/christmas

/datum/loadout_item/neck/scarf_zebra
	name = "Zebra Scarf"
	item_path = /obj/item/clothing/neck/scarf/zebra

/datum/loadout_item/neck/greyscale_large
	name = "Large Greyscale Scarf"
	item_path = /obj/item/clothing/neck/large_scarf

/datum/loadout_item/neck/scarf_blue_striped
	name = "Striped Blue Scarf"
	item_path = /obj/item/clothing/neck/large_scarf/blue

/datum/loadout_item/neck/scarf_green_striped
	name = "Striped Green Scarf"
	item_path = /obj/item/clothing/neck/large_scarf/green

/datum/loadout_item/neck/scarf_red_striped
	name = "Striped Red Scarf"
	item_path = /obj/item/clothing/neck/large_scarf/red

/datum/loadout_item/neck/greyscale_larger
	name = "Larger Greyscale Scarf"
	item_path = /obj/item/clothing/neck/infinity_scarf

/datum/loadout_item/neck/necktie
	name = "Greyscale Necktie"
	item_path = /obj/item/clothing/neck/tie

/datum/loadout_item/neck/necktie_disco
	name = "Horrific Necktie"
	item_path = /obj/item/clothing/neck/tie/horrible

/datum/loadout_item/neck/necktie_loose
	name = "Loose Necktie"
	item_path = /obj/item/clothing/neck/tie/detective
