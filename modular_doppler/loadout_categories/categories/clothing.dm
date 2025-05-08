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

/datum/loadout_item/suit/warm_coat
	name = "Warm Coat"
	item_path = /obj/item/clothing/suit/warm_coat

/*
*	SUITS / SUIT JACKETS
*/

/datum/loadout_item/suit/detective_black_short
	name = "Noir Suit Jacket"
	item_path = /obj/item/clothing/suit/jacket/det_suit/noir

/datum/loadout_item/suit/detective_brown
	name = "Trenchcoat"
	item_path = /obj/item/clothing/suit/jacket/det_suit

/datum/loadout_item/suit/its_pronounced_stow_ic_not_stoike
	name = "Disco Blazer"
	item_path = /obj/item/clothing/suit/jacket/det_suit/disco

/datum/loadout_item/suit/kim_possible
	name = "Aerostatic Bomber Jacket"
	item_path = /obj/item/clothing/suit/jacket/det_suit/kim

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
*	LABCOATS
*/

/datum/loadout_item/suit/labcoat
	name = "Labcoat"
	item_path = /obj/item/clothing/suit/toggle/labcoat

/datum/loadout_item/suit/labcoat_green
	name = "Green Labcoat"
	item_path = /obj/item/clothing/suit/toggle/labcoat/mad

/datum/loadout_item/suit/lalune_labcoat
	name = "Sleeveless Labcoat"
	item_path = /obj/item/clothing/suit/toggle/labcoat/lalunevest

/datum/loadout_item/suit/labocat_medical
	name = "Medical Labcoat"
	item_path = /obj/item/clothing/suit/toggle/labcoat/medical

/datum/loadout_item/suit/high_vis_labcoat
	name = "High-Vis Labcoat"
	item_path = /obj/item/clothing/suit/toggle/labcoat/high_vis

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

/datum/loadout_item/suit/da_gacket
	name = "Crop-top Jacket"
	item_path = /obj/item/clothing/suit/jacket/doppler/gacket

/*
*	COLONIST
*/

/datum/loadout_item/suit/frontier
	name = "Frontier Trenchcoat"
	item_path = /obj/item/clothing/suit/jacket/frontier_colonist

/datum/loadout_item/suit/frontier_short
	name = "Frontier Jacket"
	item_path = /obj/item/clothing/suit/jacket/frontier_colonist/short

/datum/loadout_item/suit/frontier_med
	name = "Frontier Medical Jacket"
	item_path = /obj/item/clothing/suit/jacket/frontier_colonist/medical

/*
*	MISC
*/

/datum/loadout_item/suit/recolorable_overalls
	name = "Recolorable Overalls"
	item_path = /obj/item/clothing/suit/apron/overalls

/datum/loadout_item/suit/wellwornshirt
	name = "Well-worn Shirt"
	item_path = /obj/item/clothing/suit/costume/wellworn_shirt

/datum/loadout_item/suit/wellworn_graphicshirt
	name = "Well-worn Graphic Shirt"
	item_path = /obj/item/clothing/suit/costume/wellworn_shirt/graphic

/datum/loadout_item/suit/ianshirt
	name = "Well-worn Ian Shirt"
	item_path = /obj/item/clothing/suit/costume/wellworn_shirt/graphic/ian

/datum/loadout_item/suit/wornoutshirt
	name = "Worn-out Shirt"
	item_path = /obj/item/clothing/suit/costume/wellworn_shirt/wornout

/datum/loadout_item/suit/wornout_graphicshirt
	name = "Worn-out graphic Shirt"
	item_path = /obj/item/clothing/suit/costume/wellworn_shirt/wornout/graphic

/datum/loadout_item/suit/wornout_ianshirt
	name = "Worn-out Ian Shirt"
	item_path = /obj/item/clothing/suit/costume/wellworn_shirt/wornout/graphic/ian

/datum/loadout_item/suit/messyshirt
	name = "Messy Shirt"
	item_path = /obj/item/clothing/suit/costume/wellworn_shirt/messy

/datum/loadout_item/suit/messy_graphicshirt
	name = "Messy Graphic Shirt"
	item_path = /obj/item/clothing/suit/costume/wellworn_shirt/messy/graphic

/datum/loadout_item/suit/messy_ianshirt
	name = "Messy Ian Shirt"
	item_path = /obj/item/clothing/suit/costume/wellworn_shirt/messy/graphic/ian

/datum/loadout_item/suit/dagger_mantle
	name = "'Dagger' Designer Mantle"
	item_path = /obj/item/clothing/suit/dagger_mantle

/*
*	HAWAIIAN
*/

/datum/loadout_item/suit/hawaiian_shirt
	name = "Hawaiian Shirt"
	item_path = /obj/item/clothing/suit/costume/hawaiian

/*
*	HOODIES
*/

/datum/loadout_item/suit/hoodie
	abstract_type = /datum/loadout_item/suit/hoodie

/datum/loadout_item/suit/hoodie/crop_cold_hoodie
	name = "Cropped Cold Shoulder Hoodie"
	item_path = /obj/item/clothing/suit/hooded/crop_cold_hoodie

/datum/loadout_item/suit/hoodie/big_hoodie
	name = "Big Hoodie"
	item_path = /obj/item/clothing/suit/hooded/big_hoodie

/datum/loadout_item/suit/hoodie/twee_hoodie
	name = "Disconcertingly Twee Hoodie"
	item_path = /obj/item/clothing/suit/hooded/twee_hoodie

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

/datum/loadout_item/suit/mantella
	name = "Mothic Mantella"
	item_path = /obj/item/clothing/suit/mothcoat/winter

// WINTER COATS

/datum/loadout_item/suit/coat_med
	name = "Medical Winter Coat"
	item_path = /obj/item/clothing/suit/hooded/wintercoat/medical

/datum/loadout_item/suit/coat_paramedic
	name = "Paramedic Winter Coat"
	item_path = /obj/item/clothing/suit/hooded/wintercoat/medical/paramedic

/datum/loadout_item/suit/coat_security
	name = "Security Winter Coat"
	item_path = /obj/item/clothing/suit/hooded/wintercoat/security

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

/datum/loadout_item/suit/med_dep_jacket
	name = "Medical Department Jacket"
	item_path = /obj/item/clothing/suit/jacket/doppler/departmental_jacket/med

/datum/loadout_item/suit/cargo_dep_jacket
	name = "Cargo Department Jacket"
	item_path = /obj/item/clothing/suit/jacket/doppler/departmental_jacket/supply

/datum/loadout_item/suit/sec_dep_jacket_red
	name = "Security Department Jacket"
	item_path = /obj/item/clothing/suit/jacket/doppler/departmental_jacket/sec/red

/datum/loadout_item/suit/peacekeeper_jacket
	name = "Peacekeeper Jacket"
	item_path = /obj/item/clothing/suit/jacket/doppler/peacekeeper_jacket

/datum/loadout_item/suit/peacekeeper_jacket_badged
	name = "Badged Peacekeeper Jacket"
	item_path = /obj/item/clothing/suit/jacket/doppler/peacekeeper_jacket/badged
