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
	loadout_flags = LOADOUT_FLAG_JOB_GREYSCALING
	job_greyscale_palettes = list(
		/datum/job/assistant = "#303030",
		/datum/job/botanist = /obj/item/clothing/suit/apron/overalls::greyscale_colors,
		/datum/job/captain = "#336699",
		/datum/job/head_of_personnel = "#336699",
		/datum/job/head_of_security = "#303030",
		/datum/job/paramedic = "#28324b",
		/datum/job/prisoner = "#ff8b00",
		/datum/job_department/engineering = "#ff6600",
		/datum/job_department/science = "#800080",
		/datum/job_department/security = "#a53228",
	)
