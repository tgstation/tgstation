/datum/loadout_category/suit
	category_name = "Suit"
	category_ui_icon = FA_ICON_VEST
	type_to_generate = /datum/loadout_item/suit
	tab_order = /datum/loadout_category/neck::tab_order + 1

/*
*	LOADOUT ITEM DATUMS FOR THE (EXO/OUTER)SUIT SLOT
*/

/datum/loadout_item/suit
	abstract_type = /datum/loadout_item/suit

/datum/loadout_item/suit/pre_equip_item(datum/outfit/outfit, datum/outfit/outfit_important_for_life, mob/living/carbon/human/equipper, visuals_only = FALSE) // don't bother storing in backpack, can't fit
	if(initial(outfit_important_for_life.suit))
		return TRUE

/datum/loadout_item/suit/insert_path_into_outfit(datum/outfit/outfit, mob/living/carbon/human/equipper, visuals_only = FALSE, override_items = LOADOUT_OVERRIDE_BACKPACK)
	if(override_items == LOADOUT_OVERRIDE_BACKPACK && !visuals_only)
		if(outfit.suit)
			LAZYADD(outfit.backpack_contents, outfit.suit)
		outfit.suit = item_path
	else
		outfit.suit = item_path

/*
*	WINTER COATS
*/

/datum/loadout_item/suit/winter_coat
	name = "Winter Coat"
	item_path = /obj/item/clothing/suit/hooded/wintercoat

/datum/loadout_item/suit/winter_coat_greyscale
	name = "Greyscale Winter Coat"
	item_path = /obj/item/clothing/suit/hooded/wintercoat/custom

/datum/loadout_item/suit/fur_coat
	name = "Rugged Fur Coat"
	item_path = /obj/item/clothing/suit/jacket/doppler/fur_coat

/datum/loadout_item/suit/wrap_coat
	name = "Wrap Coat"
	item_path = /obj/item/clothing/suit/jacket/doppler/wrap_coat

/datum/loadout_item/suit/red_coat
	name = "Marsian PLA Trenchcoat"
	item_path = /obj/item/clothing/suit/jacket/doppler/red_trench

/*
*	SUITS / SUIT JACKETS
*/

/datum/loadout_item/suit/recolorable
	name = "Recolorable Formal Suit Jacket"
	item_path = /obj/item/clothing/suit/toggle/lawyer/greyscale

/datum/loadout_item/suit/black_suit_jacket
	name = "Black Formal Suit Jacket"
	item_path = /obj/item/clothing/suit/toggle/lawyer/black

/datum/loadout_item/suit/blue_suit_jacket
	name = "Blue Formal Suit Jacket"
	item_path = /obj/item/clothing/suit/toggle/lawyer

/datum/loadout_item/suit/purple_suit_jacket
	name = "Purple Formal Suit Jacket"
	item_path = /obj/item/clothing/suit/toggle/lawyer/purple

/datum/loadout_item/suit/long_suit_jacket
	name = "Long Suit Jacket"
	item_path = /obj/item/clothing/suit/jacket/doppler/long_suit_jacket

/datum/loadout_item/suit/short_suit_jacket
	name = "Short Suit Jacket"
	item_path = /obj/item/clothing/suit/jacket/doppler/short_suit_jacket

/*
*	SUSPENDERS
*/

/datum/loadout_item/suit/suspenders
	name = "Recolorable Suspenders"
	item_path = /obj/item/clothing/suit/toggle/suspenders

/*
*	DRESSES
*/

/datum/loadout_item/suit/white_dress
	name = "White Dress"
	item_path = /obj/item/clothing/suit/costume/whitedress

/*
*	LABCOATS
*/

/datum/loadout_item/suit/labcoat
	name = "Labcoat"
	item_path = /obj/item/clothing/suit/toggle/labcoat

/datum/loadout_item/suit/labcoat_green
	name = "Green Labcoat"
	item_path = /obj/item/clothing/suit/toggle/labcoat/mad

/*
*	PONCHOS
*/

/datum/loadout_item/suit/poncho
	name = "Poncho"
	item_path = /obj/item/clothing/suit/costume/poncho

/datum/loadout_item/suit/poncho_green
	name = "Green Poncho"
	item_path = /obj/item/clothing/suit/costume/poncho/green

/datum/loadout_item/suit/poncho_red
	name = "Red Poncho"
	item_path = /obj/item/clothing/suit/costume/poncho/red

/*
*	JACKETS
*/

/datum/loadout_item/suit/bomber_jacket
	name = "Bomber Jacket"
	item_path = /obj/item/clothing/suit/jacket/bomber

/datum/loadout_item/suit/military_jacket
	name = "Military Jacket"
	item_path = /obj/item/clothing/suit/jacket/miljacket

/datum/loadout_item/suit/puffer_jacket
	name = "Puffer Jacket"
	item_path = /obj/item/clothing/suit/jacket/puffer

/datum/loadout_item/suit/puffer_vest
	name = "Puffer Vest"
	item_path = /obj/item/clothing/suit/jacket/puffer/vest

/datum/loadout_item/suit/leather_jacket
	name = "Leather Jacket"
	item_path = /obj/item/clothing/suit/jacket/leather

/datum/loadout_item/suit/leather_jacket/biker
	name = "Biker Jacket"
	item_path = /obj/item/clothing/suit/jacket/leather/biker

/datum/loadout_item/suit/jacket_sweater
	name = "Recolorable Sweater Jacket"
	item_path = /obj/item/clothing/suit/toggle/jacket/sweater

/datum/loadout_item/suit/jacket_oversized
	name = "Recolorable Oversized Jacket"
	item_path = /obj/item/clothing/suit/jacket/oversized

/datum/loadout_item/suit/jacket_fancy
	name = "Recolorable Fancy Fur Coat"
	item_path = /obj/item/clothing/suit/jacket/fancy

/datum/loadout_item/suit/ethereal_raincoat
	name = "Ethereal Raincoat"
	item_path = /obj/item/clothing/suit/hooded/ethereal_raincoat

/datum/loadout_item/suit/big_jacket
	name = "Alpha Atelier Pilot Jacket"
	item_path = /obj/item/clothing/suit/jacket/doppler/big_jacket

/datum/loadout_item/suit/chokha
	name = "Chokha Coat"
	item_path = /obj/item/clothing/suit/jacket/doppler/chokha

/datum/loadout_item/suit/field_jacket
	name = "Field Jacket"
	item_path = /obj/item/clothing/suit/jacket/doppler/field_jacket

/datum/loadout_item/suit/tan_field_jacket
	name = "Tan Field Jacket"
	item_path = /obj/item/clothing/suit/jacket/doppler/field_jacket/tan

/datum/loadout_item/suit/leather_hoodie
	name = "Leather Jacket with Hoodie"
	item_path = /obj/item/clothing/suit/hooded/doppler/leather_hoodie

/*
*	COSTUMES
*/

/datum/loadout_item/suit/owl
	name = "Owl Cloak"
	item_path = /obj/item/clothing/suit/toggle/owlwings

/datum/loadout_item/suit/griffin
	name = "Griffon Cloak"
	item_path = /obj/item/clothing/suit/toggle/owlwings/griffinwings

/datum/loadout_item/suit/syndi
	name = "Black And Red Space Suit Replica"
	item_path = /obj/item/clothing/suit/syndicatefake

/datum/loadout_item/suit/bee
	name = "Bee Outfit"
	item_path = /obj/item/clothing/suit/hooded/bee_costume

/datum/loadout_item/suit/plague_doctor
	name = "Plague Doctor Suit"
	item_path = /obj/item/clothing/suit/bio_suit/plaguedoctorsuit

/datum/loadout_item/suit/snowman
	name = "Snowman Outfit"
	item_path = /obj/item/clothing/suit/costume/snowman

/datum/loadout_item/suit/chicken
	name = "Chicken Suit"
	item_path = /obj/item/clothing/suit/costume/chickensuit

/datum/loadout_item/suit/monkey
	name = "Monkey Suit"
	item_path = /obj/item/clothing/suit/costume/monkeysuit

/datum/loadout_item/suit/cardborg
	name = "Cardborg Suit"
	item_path = /obj/item/clothing/suit/costume/cardborg

/datum/loadout_item/suit/xenos
	name = "Xenos Suit"
	item_path = /obj/item/clothing/suit/costume/xenos

/datum/loadout_item/suit/ian_costume
	name = "Corgi Costume"
	item_path = /obj/item/clothing/suit/hooded/ian_costume

/datum/loadout_item/suit/carp_costume
	name = "Carp Costume"
	item_path = /obj/item/clothing/suit/hooded/carp_costume

/datum/loadout_item/suit/shark_costume
	name = "Shark Costume"
	item_path = /obj/item/clothing/suit/hooded/shark_costume

/datum/loadout_item/suit/shork_costume
	name = "Shork Costume"
	item_path = /obj/item/clothing/suit/hooded/shork_costume

/datum/loadout_item/suit/wizard
	name = "Wizard Robe"
	item_path = /obj/item/clothing/suit/wizrobe/fake

/datum/loadout_item/suit/witch
	name = "Witch Robe"
	item_path = /obj/item/clothing/suit/wizrobe/marisa/fake

/*
*	MISC
*/

/datum/loadout_item/suit/recolorable_overalls
	name = "Recolorable Overalls"
	item_path = /obj/item/clothing/suit/apron/overalls

/*
*	HAWAIIAN
*/

/datum/loadout_item/suit/hawaiian_shirt
	name = "Hawaiian Shirt"
	item_path = /obj/item/clothing/suit/costume/hawaiian

/*
*	MISC
*/

/datum/loadout_item/suit/frontierjacket
	abstract_type = /datum/loadout_item/suit/frontierjacket

/*
*	HOODIES
*/
/datum/loadout_item/suit/hoodie
	abstract_type = /datum/loadout_item/suit/hoodie

/*
*	JOB-LOCKED
*/

// WINTER COATS
/datum/loadout_item/suit/coat_med
	name = "Medical Winter Coat"
	item_path = /obj/item/clothing/suit/hooded/wintercoat/medical

/datum/loadout_item/suit/coat_paramedic
	name = "Paramedic Winter Coat"
	item_path = /obj/item/clothing/suit/hooded/wintercoat/medical/paramedic

/datum/loadout_item/suit/coat_robotics
	name = "Robotics Winter Coat"
	item_path = /obj/item/clothing/suit/hooded/wintercoat/science/robotics

/datum/loadout_item/suit/coat_sci
	name = "Science Winter Coat"
	item_path = /obj/item/clothing/suit/hooded/wintercoat/science

/datum/loadout_item/suit/coat_eng
	name = "Engineering Winter Coat"
	item_path = /obj/item/clothing/suit/hooded/wintercoat/engineering

/datum/loadout_item/suit/coat_atmos
	name = "Atmospherics Winter Coat"
	item_path = /obj/item/clothing/suit/hooded/wintercoat/engineering/atmos

/datum/loadout_item/suit/coat_hydro
	name = "Hydroponics Winter Coat"
	item_path = /obj/item/clothing/suit/hooded/wintercoat/hydro

/datum/loadout_item/suit/coat_cargo
	name = "Cargo Winter Coat"
	item_path = /obj/item/clothing/suit/hooded/wintercoat/cargo

/datum/loadout_item/suit/coat_miner
	name = "Mining Winter Coat"
	item_path = /obj/item/clothing/suit/hooded/wintercoat/miner

// JACKETS
/datum/loadout_item/suit/navybluejacketofficer
	name = "Security Officer's Navy Blue Formal Jacket"
	item_path = /obj/item/clothing/suit/jacket/officer/blue
	restricted_roles = list(JOB_WARDEN, JOB_DETECTIVE, JOB_SECURITY_OFFICER, JOB_HEAD_OF_SECURITY)

/datum/loadout_item/suit/navybluejacketwarden
	name = "Warden's Navy Blue Formal Jacket"
	item_path = /obj/item/clothing/suit/jacket/warden/blue
	restricted_roles = list(JOB_WARDEN)

/datum/loadout_item/suit/navybluejackethos
	name = "Head of Security's Navy Blue Formal Jacket"
	item_path = /obj/item/clothing/suit/jacket/hos/blue
	restricted_roles = list(JOB_HEAD_OF_SECURITY)

/datum/loadout_item/suit/qm_jacket
	name = "Quartermaster's Overcoat"
	item_path = /obj/item/clothing/suit/jacket/quartermaster
	restricted_roles = list(JOB_QUARTERMASTER)

/datum/loadout_item/suit/departmental_jacket
	name = "Work Jacket"
	item_path = /obj/item/clothing/suit/jacket/doppler/departmental_jacket

/datum/loadout_item/suit/engi_dep_jacket
	name = "Engineering Department Jacket"
	item_path = /obj/item/clothing/suit/jacket/doppler/departmental_jacket/engi
	restricted_roles = list(
		JOB_CHIEF_ENGINEER,
		JOB_STATION_ENGINEER,
		JOB_ATMOSPHERIC_TECHNICIAN,
		)

/datum/loadout_item/suit/med_dep_jacket
	name = "Medical Department Jacket"
	item_path = /obj/item/clothing/suit/jacket/doppler/departmental_jacket/med
	restricted_roles = list(
		JOB_CHIEF_MEDICAL_OFFICER,
		JOB_MEDICAL_DOCTOR,
		JOB_CHEMIST,
		JOB_PSYCHOLOGIST,
	)

/datum/loadout_item/suit/cargo_dep_jacket
	name = "Cargo Department Jacket"
	item_path = /obj/item/clothing/suit/jacket/doppler/departmental_jacket/supply
	restricted_roles = list(
		JOB_QUARTERMASTER,
		JOB_CARGO_TECHNICIAN,
		JOB_SHAFT_MINER,
	)

/datum/loadout_item/suit/sec_dep_jacket_blu
	name = "Blue Security Department Jacket"
	item_path = /obj/item/clothing/suit/jacket/doppler/departmental_jacket/sec
	restricted_roles = list(
		JOB_HEAD_OF_SECURITY,
		JOB_SECURITY_OFFICER,
		JOB_WARDEN,
		JOB_DETECTIVE,
	)

/datum/loadout_item/suit/sec_dep_jacket_red
	name = "Red Security Department Jacket"
	item_path = /obj/item/clothing/suit/jacket/doppler/departmental_jacket/sec/red
	restricted_roles = list(
		JOB_HEAD_OF_SECURITY,
		JOB_SECURITY_OFFICER,
		JOB_WARDEN,
		JOB_DETECTIVE,
	)

/datum/loadout_item/suit/sec_dep_jacket_red
	name = "Security Medic Jacket"
	item_path = /obj/item/clothing/suit/jacket/doppler/sec_medic
	restricted_roles = list(
		JOB_HEAD_OF_SECURITY,
		JOB_SECURITY_OFFICER,
		JOB_WARDEN,
		JOB_DETECTIVE,
	)

/*
*	FAMILIES
*/

/datum/loadout_item/suit/tmc
	name = "TMC Coat"
	item_path = /obj/item/clothing/suit/costume/tmc

/datum/loadout_item/suit/pg
	name = "PG Coat"
	item_path = /obj/item/clothing/suit/costume/pg

/datum/loadout_item/suit/deckers
	name = "Deckers Hoodie"
	item_path = /obj/item/clothing/suit/costume/deckers

/datum/loadout_item/suit/soviet
	name = "Soviet Coat"
	item_path = /obj/item/clothing/suit/costume/soviet

/datum/loadout_item/suit/yuri
	name = "Yuri Coat"
	item_path = /obj/item/clothing/suit/costume/yuri

/*
*	CHAPLAIN
*/

/datum/loadout_item/suit/chap_nun
	name = "Nun's Habit"
	item_path = /obj/item/clothing/suit/chaplainsuit/nun

/datum/loadout_item/suit/chap_holiday
	name = "Chaplain's Holiday Robe"
	item_path = /obj/item/clothing/suit/chaplainsuit/holidaypriest

/datum/loadout_item/suit/chap_brownmonk
	name = "Monk's Brown Habit"
	item_path = /obj/item/clothing/suit/hooded/chaplainsuit/monkhabit

/datum/loadout_item/suit/chap_eastmonk
	name = "Eastern Monk's Robe"
	item_path = /obj/item/clothing/suit/chaplainsuit/monkrobeeast

/datum/loadout_item/suit/chap_shrinehand
	name = "Shrinehand Robe"
	item_path = /obj/item/clothing/suit/chaplainsuit/shrinehand

/datum/loadout_item/suit/chap_blackmonk
	name = "Monk's Black Habit"
	item_path = /obj/item/clothing/suit/chaplainsuit/habit
