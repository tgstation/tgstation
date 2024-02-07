/*
*	LOADOUT ITEM DATUMS FOR THE NECK SLOT
*/

/// Neck Slot Items (Deletes overrided items)
GLOBAL_LIST_INIT(loadout_necks, generate_loadout_items(/datum/loadout_item/neck))

/datum/loadout_item/neck
	category = LOADOUT_ITEM_NECK

/datum/loadout_item/neck/pre_equip_item(datum/outfit/outfit, datum/outfit/outfit_important_for_life, mob/living/carbon/human/equipper, visuals_only = FALSE)
	if(initial(outfit_important_for_life.neck))
		.. ()
		return TRUE

/datum/loadout_item/neck/insert_path_into_outfit(datum/outfit/outfit, mob/living/carbon/human/equipper, visuals_only = FALSE, override_items = LOADOUT_OVERRIDE_BACKPACK)
	if(override_items == LOADOUT_OVERRIDE_BACKPACK)
		if(outfit.neck)
			LAZYADD(outfit.backpack_contents, outfit.neck && !visuals_only)
		outfit.neck = item_path
	else
		outfit.neck = item_path


/*
*	SCARVES
*/

/datum/loadout_item/neck/scarf_black
	name = "Black Scarf"
	item_path = /obj/item/clothing/neck/scarf/black

/datum/loadout_item/neck/scarf_christmas
	name = "Christmas Scarf"
	item_path = /obj/item/clothing/neck/scarf/christmas

/datum/loadout_item/neck/scarf_cyan
	name = "Cyan Scarf"
	item_path = /obj/item/clothing/neck/scarf/cyan

/datum/loadout_item/neck/scarf_dark_blue
	name = "Dark Blue Scarf"
	item_path = /obj/item/clothing/neck/scarf/darkblue

/datum/loadout_item/neck/scarf_green
	name = "Green Scarf"
	item_path = /obj/item/clothing/neck/scarf/green

/datum/loadout_item/neck/scarf_pink
	name = "Pink Scarf"
	item_path = /obj/item/clothing/neck/scarf/pink

/datum/loadout_item/neck/scarf_purple
	name = "Purple Scarf"
	item_path = /obj/item/clothing/neck/scarf/purple

/datum/loadout_item/neck/scarf_red
	name = "Red Scarf"
	item_path = /obj/item/clothing/neck/scarf/red

/datum/loadout_item/neck/scarf_orange
	name = "Orange Scarf"
	item_path = /obj/item/clothing/neck/scarf/orange

/datum/loadout_item/neck/scarf_yellow
	name = "Yellow Scarf"
	item_path = /obj/item/clothing/neck/scarf/yellow

/datum/loadout_item/neck/scarf_white
	name = "White Scarf"
	item_path = /obj/item/clothing/neck/scarf

/datum/loadout_item/neck/scarf_red_striped
	name = "Striped Red Scarf"
	item_path = /obj/item/clothing/neck/large_scarf/red

/datum/loadout_item/neck/scarf_blue_striped
	name = "Striped Blue Scarf"
	item_path = /obj/item/clothing/neck/large_scarf/blue

/datum/loadout_item/neck/scarf_green_striped
	name = "Striped Green Scarf"
	item_path = /obj/item/clothing/neck/large_scarf/green

/datum/loadout_item/neck/scarf_zebra
	name = "Zebra Scarf"
	item_path = /obj/item/clothing/neck/scarf/zebra

/datum/loadout_item/neck/scarf_infinity
	name = "Infinity Scarf"
	item_path = /obj/item/clothing/neck/infinity_scarf

/datum/loadout_item/neck/ascot
	name = "Ascot"
	item_path = /obj/item/clothing/neck/ascot
	requires_purchase = FALSE

/*
*	NECKTIES
*/

/datum/loadout_item/neck/necktie_black
	name = "Black Necktie"
	item_path = /obj/item/clothing/neck/tie/black

/datum/loadout_item/neck/necktie_blue
	name = "Blue Necktie"
	item_path = /obj/item/clothing/neck/tie/blue

/datum/loadout_item/neck/necktie_disco
	name = "Horrific Necktie"
	item_path = /obj/item/clothing/neck/tie/horrible

/datum/loadout_item/neck/necktie_loose
	name = "Loose Necktie"
	item_path = /obj/item/clothing/neck/tie/detective

/datum/loadout_item/neck/necktie_red
	name = "Red Necktie"
	item_path = /obj/item/clothing/neck/tie/red

/datum/loadout_item/neck/discoproper
	name = "Horrible Necktie"
	item_path = /obj/item/clothing/neck/tie/disco
	restricted_roles = list(JOB_DETECTIVE)

/*
*	MISC
*/

/datum/loadout_item/neck/stethoscope
	name = "Stethoscope"
	item_path = /obj/item/clothing/neck/stethoscope
	restricted_roles = list(JOB_MEDICAL_DOCTOR, JOB_CHIEF_MEDICAL_OFFICER)

/datum/loadout_item/neck/maid
	name = "Maid Neck Cover"
	item_path = /obj/item/clothing/neck/maid

/datum/loadout_item/neck/bowtie_collar
	name = "Colorable Bowtie Collar"
	item_path = /obj/item/clothing/neck/tie/bunnytie/tied

/datum/loadout_item/neck/boatcloak
	name = "Boat cloak"
	item_path = /obj/item/clothing/neck/boatcloak

/datum/loadout_item/neck/polycloak
	name = "Poly cloak"
	item_path = /obj/item/clothing/neck/polycloak


/datum/loadout_item/neck/trans
	name = "Trans Pride Cloak"
	item_path = /obj/item/clothing/neck/trans

/datum/loadout_item/neck/pan
	name = "Pansexual Pride Cloak"
	item_path = /obj/item/clothing/neck/pan

/datum/loadout_item/neck/les
	name = "Lesbian Pride Cloak"
	item_path = /obj/item/clothing/neck/les

/datum/loadout_item/neck/intersex
	name = "Intersex Pride Cloak"
	item_path = /obj/item/clothing/neck/intersex

/datum/loadout_item/neck/gay
	name = "Gay Pride Cloak"
	item_path = /obj/item/clothing/neck/gay

/datum/loadout_item/neck/enby
	name = "Nonbinary Pride Cloak"
	item_path = /obj/item/clothing/neck/enby

/datum/loadout_item/neck/bi
	name = "Bisexual Pride Cloak"
	item_path = /obj/item/clothing/neck/bi

/datum/loadout_item/neck/aro
	name = "Aro Pride Cloak"
	item_path = /obj/item/clothing/neck/aro

/datum/loadout_item/neck/ace
	name = "Asexual Pride Cloak"
	item_path = /obj/item/clothing/neck/ace

/*
*	DONATOR
*/

/datum/loadout_item/neck/donator
	donator_only = TRUE
	requires_purchase = FALSE

/datum/loadout_item/neck/donator/knight_cloak
	name = "Knight Cloak"
	restricted_roles = list(JOB_MIME)
	item_path = /obj/item/clothing/neck/knightcloak

/datum/loadout_item/neck/donator/hornet_cloak
	name = "Hornet Cloak"
	item_path = /obj/item/clothing/neck/hornetcloak

