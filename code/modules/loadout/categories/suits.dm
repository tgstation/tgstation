/datum/loadout_category/suits
	category_name = "Suits"
	category_ui_icon = FA_ICON_USER_SECRET
	type_to_generate = /datum/loadout_item/suit
	tab_order = /datum/loadout_category/head::tab_order + 3

/datum/loadout_item/suit
	abstract_type = /datum/loadout_item/suit
	var/list/job_coat_paths

/datum/loadout_item/suit/proc/get_path(mob/living/carbon/human/wearer)
	if(job_coat_paths?.len)
		var/datum/job/job = SSjob.get_job(wearer.job)
		if(job && job_coat_paths[job.type])
			return job_coat_paths[job.type]
	return item_path

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

/datum/loadout_item/suit/hoodie_pullover
	name = "pullover"
	item_path = /obj/item/clothing/suit/hooded/wintercoat/pullover

/datum/loadout_item/suit/hoodie_zipup
	name = "zipup"
	item_path = /obj/item/clothing/suit/hooded/wintercoat/zipup

/datum/loadout_item/suit/wintercoat
	name = "Winter Coat (Department coats included!)"
	item_path = /obj/item/clothing/suit/hooded/wintercoat
	job_coat_paths = list(
		/datum/job/atmospheric_technician = /obj/item/clothing/suit/hooded/wintercoat/engineering/atmos,
		/datum/job/botanist = /obj/item/clothing/suit/hooded/wintercoat/hydro,
		/datum/job/captain = /obj/item/clothing/suit/hooded/wintercoat/captain,
		/datum/job/cargo_technician = /obj/item/clothing/suit/hooded/wintercoat/cargo,
		/datum/job/chemist = /obj/item/clothing/suit/hooded/wintercoat/medical/chemistry,
		/datum/job/chief_engineer = /obj/item/clothing/suit/hooded/wintercoat/engineering/ce,
		/datum/job/chief_medical_officer = /obj/item/clothing/suit/hooded/wintercoat/medical/cmo,
		/datum/job/coroner = /obj/item/clothing/suit/hooded/wintercoat/medical/coroner,
		/datum/job/geneticist = /obj/item/clothing/suit/hooded/wintercoat/science/genetics,
		/datum/job/head_of_personnel = /obj/item/clothing/suit/hooded/wintercoat/hop,
		/datum/job/head_of_security = /obj/item/clothing/suit/armor/hos/trenchcoat/winter,
		/datum/job/janitor = /obj/item/clothing/suit/hooded/wintercoat/janitor,
		/datum/job/doctor = /obj/item/clothing/suit/hooded/wintercoat/medical,
		/datum/job/paramedic = /obj/item/clothing/suit/hooded/wintercoat/medical/paramedic,
		/datum/job/quartermaster = /obj/item/clothing/suit/hooded/wintercoat/cargo/qm,
		/datum/job/research_director = /obj/item/clothing/suit/hooded/wintercoat/science/rd,
		/datum/job/roboticist = /obj/item/clothing/suit/hooded/wintercoat/science/robotics,
		/datum/job/scientist = /obj/item/clothing/suit/hooded/wintercoat/science,
		/datum/job/security_officer = /obj/item/clothing/suit/hooded/wintercoat/security,
		/datum/job/shaft_miner = /obj/item/clothing/suit/hooded/wintercoat/miner,
		/datum/job/station_engineer = /obj/item/clothing/suit/hooded/wintercoat/engineering,
		/datum/job/warden = /obj/item/clothing/suit/hooded/wintercoat/security,
	)

/datum/loadout_item/suit/wintercoat/insert_path_into_outfit(datum/outfit/outfit, mob/living/carbon/human/equipper, visuals_only = FALSE)
	. = ..()
	outfit.suit = get_path(equipper)
