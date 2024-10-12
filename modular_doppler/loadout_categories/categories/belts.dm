/datum/loadout_category/belt
	category_name = "Belt"
	category_ui_icon = FA_ICON_SCREWDRIVER_WRENCH
	type_to_generate = /datum/loadout_item/belts
	tab_order = /datum/loadout_category/accessories::tab_order + 1


/*
*	LOADOUT ITEM DATUMS FOR THE BELT SLOT
*/
/datum/loadout_item/belts
	abstract_type = /datum/loadout_item/belts

/datum/loadout_item/belts/insert_path_into_outfit(datum/outfit/outfit, mob/living/carbon/human/equipper, visuals_only = FALSE)
	if(outfit.belt)
		LAZYADD(outfit.backpack_contents, outfit.belt)
	outfit.belt = item_path


/datum/loadout_item/belts/fanny_pack_black
	name = "Black Fannypack"
	item_path = /obj/item/storage/belt/fannypack/black

/datum/loadout_item/belts/fanny_pack_blue
	name = "Blue Fannypack"
	item_path = /obj/item/storage/belt/fannypack/blue

/datum/loadout_item/belts/fanny_pack_brown
	name = "Brown Fannypack"
	item_path = /obj/item/storage/belt/fannypack

/datum/loadout_item/belts/fanny_pack_cyan
	name = "Cyan Fannypack"
	item_path = /obj/item/storage/belt/fannypack/cyan

/datum/loadout_item/belts/fanny_pack_green
	name = "Green Fannypack"
	item_path = /obj/item/storage/belt/fannypack/green

/datum/loadout_item/belts/fanny_pack_orange
	name = "Orange Fannypack"
	item_path = /obj/item/storage/belt/fannypack/orange

/datum/loadout_item/belts/fanny_pack_pink
	name = "Pink Fannypack"
	item_path = /obj/item/storage/belt/fannypack/pink

/datum/loadout_item/belts/fanny_pack_purple
	name = "Purple Fannypack"
	item_path = /obj/item/storage/belt/fannypack/purple

/datum/loadout_item/belts/fanny_pack_red
	name = "Red Fannypack"
	item_path = /obj/item/storage/belt/fannypack/red

/datum/loadout_item/belts/fanny_pack_yellow
	name = "Yellow Fannypack"
	item_path = /obj/item/storage/belt/fannypack/yellow

/datum/loadout_item/belts/fanny_pack_white
	name = "White Fannypack"
	item_path = /obj/item/storage/belt/fannypack/white

/datum/loadout_item/belts/fanny_pack_custom
	name = "Fannypack"
	item_path = /obj/item/storage/belt/fannypack/custom

/datum/loadout_item/belts/lantern
	name = "Lantern"
	item_path = /obj/item/flashlight/lantern

/datum/loadout_item/belts/candle_box
	name = "Candle Box"
	item_path = /obj/item/storage/fancy/candle_box

/datum/loadout_item/belts/champion
	name = "Champion's Belt"
	item_path = /obj/item/storage/belt/champion

// HOLSTERS

/datum/loadout_item/belts/holster_shoulders
	name = "Shoulder Holster"
	item_path = /obj/item/storage/belt/holster

// USEFUL BELTS

/datum/loadout_item/belts/medical
	name = "Medical Belt"
	item_path = /obj/item/storage/belt/medical

/datum/loadout_item/belts/medical/invisible
	name = "Compact Medical Belt"
	item_path = /obj/item/storage/belt/medical/invisible

/datum/loadout_item/belts/security
	name = "Security Belt"
	item_path = /obj/item/storage/belt/security

/datum/loadout_item/belts/utility
	name = "Utility Belt"
	item_path = /obj/item/storage/belt/utility

/datum/loadout_item/belts/utility/invisible
	name = "Compact Utility Belt"
	item_path = /obj/item/storage/belt/utility/invisible

/datum/loadout_item/belts/utility/chief
	name = "Chief Engineer's Utility Belt"
	item_path = /obj/item/storage/belt/utility/chief

/datum/loadout_item/belts/mining
	name = "Explorer's Webbing"
	item_path = /obj/item/storage/belt/mining

/datum/loadout_item/belts/boarding_rig
	name = "Chest Rig"
	item_path = /obj/item/storage/belt/military

/datum/loadout_item/belts/deforest_med
	name = "Satchel Med-kit"
	item_path = /obj/item/storage/backpack/duffelbag/deforest_medkit

/datum/loadout_item/belts/synth_repair
	name = "Android Repair Kit"
	item_path = /obj/item/storage/medkit/robotic_repair/stocked

/datum/loadout_item/belts/frontier_med
	name = "Frontier Med-kit"
	item_path = /obj/item/storage/medkit/frontier/stocked

/datum/loadout_item/belts/deforest_paramed
	name = "Satchel Tech-kit"
	item_path = /obj/item/storage/backpack/duffelbag/deforest_paramedic

/datum/loadout_item/belts/deforest_surgical
	name = "Firest Responder Med-kit"
	item_path = /obj/item/storage/backpack/duffelbag/deforest_surgical
