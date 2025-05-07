/*
*	LOADOUT ITEM DATUMS FOR THE HAND SLOT
*/

/datum/loadout_category/hands
	category_name = "Hands"
	category_ui_icon = FA_ICON_HAND
	type_to_generate = /datum/loadout_item/gloves
	tab_order = /datum/loadout_category/shoes::tab_order + 1

/datum/loadout_item/gloves
	abstract_type = /datum/loadout_item/gloves

/datum/loadout_item/gloves/insert_path_into_outfit(datum/outfit/outfit, mob/living/carbon/human/equipper, visuals_only = FALSE, override_items = LOADOUT_OVERRIDE_BACKPACK)
	if(override_items == LOADOUT_OVERRIDE_BACKPACK && !visuals_only)
		if(outfit.gloves)
			LAZYADD(outfit.backpack_contents, outfit.gloves)
		outfit.gloves = item_path
	else
		outfit.gloves = item_path

/datum/loadout_item/gloves/fingerless
	name = "Fingerless Gloves"
	item_path = /obj/item/clothing/gloves/fingerless

/datum/loadout_item/gloves/black
	name = "Black Gloves"
	item_path = /obj/item/clothing/gloves/color/black

/datum/loadout_item/gloves/blue
	name = "Blue Gloves"
	item_path = /obj/item/clothing/gloves/color/blue

/datum/loadout_item/gloves/brown
	name = "Brown Gloves"
	item_path = /obj/item/clothing/gloves/color/brown

/datum/loadout_item/gloves/green
	name = "Green Gloves"
	item_path = /obj/item/clothing/gloves/color/green

/datum/loadout_item/gloves/grey
	name = "Grey Gloves"
	item_path = /obj/item/clothing/gloves/color/grey

/datum/loadout_item/gloves/light_brown
	name = "Light Brown Gloves"
	item_path = /obj/item/clothing/gloves/color/light_brown

/datum/loadout_item/gloves/orange
	name = "Orange Gloves"
	item_path = /obj/item/clothing/gloves/color/orange

/datum/loadout_item/gloves/purple
	name = "Purple Gloves"
	item_path = /obj/item/clothing/gloves/color/purple

/datum/loadout_item/gloves/red
	name = "Red Gloves"
	item_path = /obj/item/clothing/gloves/color/red

/datum/loadout_item/gloves/white
	name = "White Gloves"
	item_path = /obj/item/clothing/gloves/color/white

/datum/loadout_item/gloves/rainbow
	name = "Rainbow Gloves"
	item_path = /obj/item/clothing/gloves/color/rainbow

/datum/loadout_item/gloves/latex
	name = "Latex Gloves"
	item_path = /obj/item/clothing/gloves/latex

/datum/loadout_item/gloves/nitrile
	name = "Nitrile Gloves"
	item_path = /obj/item/clothing/gloves/latex/nitrile

/datum/loadout_item/gloves/translationgloves
	name = "Translation Gloves"
	item_path = /obj/item/clothing/gloves/radio

/datum/loadout_item/gloves/maid_arm_covers
	name = "Maid Arm Covers"
	item_path = /obj/item/clothing/gloves/maid_arm_covers

/datum/loadout_item/gloves/lalune_gloves
	name = "Elbow Gloves"
	item_path = /obj/item/clothing/gloves/lalune_long

/datum/loadout_item/gloves/cloth_armwraps
	name = "Cloth Armwraps"
	item_path = /obj/item/clothing/gloves/bracer/wraps

/datum/loadout_item/gloves/frontier_gloves
	name = "Frontier Gloves"
	item_path = /obj/item/clothing/gloves/frontier_colonist

/datum/loadout_item/gloves/aerostatic
	name = "Aerostatic Gloves"
	item_path = /obj/item/clothing/gloves/kim
