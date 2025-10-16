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
		if(outfit.suit_store::w_class <= WEIGHT_CLASS_NORMAL)
			LAZYADD(outfit.backpack_contents, outfit.suit_store)
		else if((!outfit.belt || (outfit.belt::w_class <= WEIGHT_CLASS_NORMAL)) && (outfit.suit_store::slot_flags & ITEM_SLOT_BELT))
			if(outfit.belt)
				LAZYADD(outfit.backpack_contents, outfit.belt)
			outfit.belt = outfit.suit_store
		else if(!outfit.r_hand)
			outfit.r_hand = outfit.suit_store
		else if(!outfit.l_hand)
			outfit.l_hand = outfit.suit_store
		// no else condition - if every check failed, we just nuke whatever was there
		// which is fine, suitstore generally contains replaceable items like pens, tanks, or weapons
		outfit.suit_store = null

	outfit.suit = item_path

/datum/loadout_item/suit/overall
	name = "Overall"
	item_path = /obj/item/clothing/suit/apron/overalls
	loadout_flags = LOADOUT_FLAG_JOB_GREYSCALING
	job_greyscale_palettes = list(
		/datum/job/assistant = COLOR_JOB_DEFAULT,
		/datum/job/botanist = /obj/item/clothing/suit/apron/overalls::greyscale_colors,
		/datum/job/captain = COLOR_JOB_COMMAND_GENERIC,
		/datum/job/head_of_personnel = COLOR_JOB_COMMAND_GENERIC,
		/datum/job/head_of_security = COLOR_JOB_DEFAULT,
		/datum/job/paramedic = "#28324b",
		/datum/job/prisoner = "#ff8b00",
	)
