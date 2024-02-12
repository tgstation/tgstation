/*
*	LOADOUT ITEM DATUMS FOR THE (EXO/OUTER)SUIT SLOT
*/

/// Exosuit / Outersuit Slot Items (Moves items to backpack)
GLOBAL_LIST_INIT(loadout_exosuits, generate_loadout_items(/datum/loadout_item/suit))

/datum/loadout_item/suit
	category = LOADOUT_ITEM_SUIT

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
/*
*	SUITS / SUIT JACKETS
*/

/datum/loadout_item/suit/black_suit_jacket
	name = "Black Suit Jacket"
	item_path = /obj/item/clothing/suit/toggle/lawyer/black

/datum/loadout_item/suit/blue_suit_jacket
	name = "Blue Suit Jacket"
	item_path = /obj/item/clothing/suit/toggle/lawyer

/datum/loadout_item/suit/purple_suit_jacket
	name = "Purple Suit Jacket"
	item_path = /obj/item/clothing/suit/toggle/lawyer/purple


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

/datum/loadout_item/suit/tailcoat
	name = "Recolorable Tailcoat"
	item_path = /obj/item/clothing/suit/jacket/tailcoat

/datum/loadout_item/suit/ethereal_raincoat
	name = "Ethereal Raincoat"
	item_path = /obj/item/clothing/suit/hooded/ethereal_raincoat

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

/datum/loadout_item/suit/wizard
	name = "Wizard Robe"
	item_path = /obj/item/clothing/suit/wizrobe/fake

/datum/loadout_item/suit/witch
	name = "Witch Robe"
	item_path = /obj/item/clothing/suit/wizrobe/marisa/fake

/*
*	MISC
*/

/datum/loadout_item/suit/purple_apron
	name = "Purple Apron"
	item_path = /obj/item/clothing/suit/apron/purple_bartender

/datum/loadout_item/suit/denim_overalls
	name = "Denim Overalls"
	item_path = /obj/item/clothing/suit/apron/overalls

/datum/loadout_item/suit/ianshirt
	name = "Ian Shirt"
	item_path = /obj/item/clothing/suit/costume/ianshirt


/*
*	HAWAIIAN
*/


/datum/loadout_item/suit/hawaiian_shirt
	name = "Hawaiian Shirt"
	item_path = /obj/item/clothing/suit/costume/hawaiian


/*
*	JOB-LOCKED
*/

// WINTER COATS
/datum/loadout_item/suit/coat_med
	name = "Medical Winter Coat"
	item_path = /obj/item/clothing/suit/hooded/wintercoat/medical
	restricted_roles = list(JOB_CHIEF_MEDICAL_OFFICER, JOB_MEDICAL_DOCTOR) // Reserved for Medical Doctors, Orderlies, and their boss, the Chief Medical Officer

/datum/loadout_item/suit/coat_paramedic
	name = "Paramedic Winter Coat"
	item_path = /obj/item/clothing/suit/hooded/wintercoat/medical/paramedic
	restricted_roles = list(JOB_CHIEF_MEDICAL_OFFICER, JOB_PARAMEDIC) // Reserved for Paramedics and their boss, the Chief Medical Officer

/datum/loadout_item/suit/coat_robotics
	name = "Robotics Winter Coat"
	item_path = /obj/item/clothing/suit/hooded/wintercoat/science/robotics
	restricted_roles = list(JOB_RESEARCH_DIRECTOR, JOB_ROBOTICIST)

/datum/loadout_item/suit/coat_sci
	name = "Science Winter Coat"
	item_path = /obj/item/clothing/suit/hooded/wintercoat/science
	restricted_roles = list(JOB_RESEARCH_DIRECTOR, JOB_SCIENTIST, JOB_ROBOTICIST) // Reserved for the Science Departement

/datum/loadout_item/suit/coat_eng
	name = "Engineering Winter Coat"
	item_path = /obj/item/clothing/suit/hooded/wintercoat/engineering
	restricted_roles = list(JOB_CHIEF_ENGINEER, JOB_STATION_ENGINEER) // Reserved for Station Engineers, Engineering Guards, and their boss, the Chief Engineer

/datum/loadout_item/suit/coat_atmos
	name = "Atmospherics Winter Coat"
	item_path = /obj/item/clothing/suit/hooded/wintercoat/engineering/atmos
	restricted_roles = list(JOB_CHIEF_ENGINEER, JOB_ATMOSPHERIC_TECHNICIAN) // Reserved for Atmos Techs and their boss, the Chief Engineer

/datum/loadout_item/suit/coat_hydro
	name = "Hydroponics Winter Coat"
	item_path = /obj/item/clothing/suit/hooded/wintercoat/hydro
	restricted_roles = list(JOB_HEAD_OF_PERSONNEL, JOB_BOTANIST) // Reserved for Botanists and their boss, the Head of Personnel

/datum/loadout_item/suit/coat_cargo
	name = "Cargo Winter Coat"
	item_path = /obj/item/clothing/suit/hooded/wintercoat/cargo
	restricted_roles = list(JOB_QUARTERMASTER, JOB_CARGO_TECHNICIAN) // Reserved for Cargo Techs, Customs Agents, and their boss, the Quartermaster

/datum/loadout_item/suit/coat_miner
	name = "Mining Winter Coat"
	item_path = /obj/item/clothing/suit/hooded/wintercoat/miner
	restricted_roles = list(JOB_QUARTERMASTER, JOB_SHAFT_MINER) // Reserved for Miners and their boss, the Quartermaster

// JACKETS

/datum/loadout_item/suit/tailcoat_bartender
	name = "Bartender's Tailcoat"
	item_path = /obj/item/clothing/suit/jacket/tailcoat/bartender
	restricted_roles = list(JOB_BARTENDER)

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

/datum/loadout_item/suit/winter_coat/cosmic
	name = "Cosmic Winter Coat"
	item_path = /obj/item/clothing/suit/hooded/wintercoat/cosmic

/datum/loadout_item/suit/winter_coat/ratvar
	name = "Ratvar Winter Coat"
	item_path = /obj/item/clothing/suit/hooded/wintercoat/ratvar

/datum/loadout_item/suit/winter_coat/narsie
	name = "Narsie Winter Coat"
	item_path = /obj/item/clothing/suit/hooded/wintercoat/narsie

/datum/loadout_item/suit/saints
	name = "Third Street Saints fur coat"
	item_path = /obj/item/clothing/suit/saints

/datum/loadout_item/suit/heartcoat
	name = "Heart coat"
	item_path = /obj/item/clothing/suit/heartcoat

/datum/loadout_item/suit/phantom
	name = "Phantom Thief Coat"
	item_path = /obj/item/clothing/suit/phantom

/datum/loadout_item/suit/morningstar
	name = "Morning Star Coat"
	item_path = /obj/item/clothing/suit/morningstar

/datum/loadout_item/suit/driscoll
	name = "driscoll poncho"
	item_path = /obj/item/clothing/suit/driscoll

/datum/loadout_item/suit/dinojammies
	name = "Dinosaur Pajamas"
	item_path = /obj/item/clothing/suit/hooded/dinojammies

/*
*	DONATOR
*/

/datum/loadout_item/suit/donator
	donator_only = TRUE
	requires_purchase = FALSE
