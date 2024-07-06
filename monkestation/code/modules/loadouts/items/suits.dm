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


/// EVERYTHING NOVA RELATED


/*
*	WINTER COATS
*/

/datum/loadout_item/suit/aformal
	name = "Assistant's Formal Winter Coat"
	item_path = /obj/item/clothing/suit/hooded/wintercoat/nova
	restricted_roles = list(JOB_ASSISTANT, JOB_SECURITY_ASSISTANT) //funny
	requires_purchase = FALSE

/datum/loadout_item/suit/korea
	name = "Eastern Winter Coat"
	item_path = /obj/item/clothing/suit/koreacoat

/datum/loadout_item/suit/czech
	name = "Czech Winter Coat"
	item_path = /obj/item/clothing/suit/modernwintercoatthing

/datum/loadout_item/suit/mantella
	name = "Mothic Mantella"
	item_path = /obj/item/clothing/suit/mothcoat/winter

/*
*	SUITS / SUIT JACKETS
*/

/datum/loadout_item/suit/white_suit_jacket
	name = "White Formal Suit Jacket"
	item_path = /obj/item/clothing/suit/toggle/lawyer/white

/datum/loadout_item/suit/suitblackbetter
	name = "Light Black Formal Suit Jacket"
	item_path = /obj/item/clothing/suit/toggle/lawyer/black/better

/datum/loadout_item/suit/suitwhite
	name = "Texan Suit Jacket"
	item_path = /obj/item/clothing/suit/texas

/*
*	JACKETS
*/

/datum/loadout_item/suit/leather_jacket/hooded
	name = "Leather Jacket with a Hoodie"
	item_path = /obj/item/clothing/suit/hooded/leather

/datum/loadout_item/suit/tailored_jacket
	name = "Recolorable Tailored Jacket"
	item_path = /obj/item/clothing/suit/tailored_jacket

/datum/loadout_item/suit/tailored_short_jacket
	name = "Recolorable Tailored Short Jacket"
	item_path = /obj/item/clothing/suit/tailored_jacket/short

/datum/loadout_item/suit/mothcoat
	name = "Mothic Flightsuit"
	item_path = /obj/item/clothing/suit/mothcoat

/*
*	VARSITY JACKET
*/

/datum/loadout_item/suit/varsity
	name = "Varsity Jacket"
	item_path = /obj/item/clothing/suit/varsity

/*
*	COSTUMES
*/

/datum/loadout_item/suit/shark_costume
	name = "Shark Costume"
	item_path = /obj/item/clothing/suit/hooded/shark_costume

/*
*	MISC
*/

/datum/loadout_item/suit/recolorable_apron
	name = "Recolorable Apron"
	item_path = /obj/item/clothing/suit/apron/chef/colorable_apron

/datum/loadout_item/suit/redhood
	name = "Red cloak"
	item_path = /obj/item/clothing/suit/hooded/cloak/david

/datum/loadout_item/suit/wornshirt
	name = "Worn Shirt"
	item_path = /obj/item/clothing/suit/wornshirt

/datum/loadout_item/suit/duster
	name = "Colorable Duster"
	item_path = /obj/item/clothing/suit/duster

/datum/loadout_item/suit/peacoat
	name = "Colorable Peacoat"
	item_path = /obj/item/clothing/suit/toggle/peacoat

/datum/loadout_item/suit/trackjacket
	name = "Track Jacket"
	item_path = /obj/item/clothing/suit/toggle/trackjacket

/datum/loadout_item/suit/croptop
	name = "Crop Top Turtleneck"
	item_path = /obj/item/clothing/suit/jacket/croptop

/*
*	FLANNELS
*/

/datum/loadout_item/suit/flannel_gags
	name = "Flannel Shirt"
	item_path = /obj/item/clothing/suit/toggle/jacket/flannel/gags

/datum/loadout_item/suit/flannel_black
	name = "Black Flannel"
	item_path = /obj/item/clothing/suit/toggle/jacket/flannel

/datum/loadout_item/suit/flannel_red
	name = "Red Flannel"
	item_path = /obj/item/clothing/suit/toggle/jacket/flannel/red

/datum/loadout_item/suit/flannel_aqua
	name = "Aqua Flannel"
	item_path = /obj/item/clothing/suit/toggle/jacket/flannel/aqua

/datum/loadout_item/suit/flannel_brown
	name = "Brown Flannel"
	item_path = /obj/item/clothing/suit/toggle/jacket/flannel/brown

/*
*	MISC
*/

/datum/loadout_item/suit/frenchtrench
	name = "Blue Trenchcoat"
	item_path = /obj/item/clothing/suit/frenchtrench

/datum/loadout_item/suit/frontiertrench
	name = "Frontier Trenchcoat"
	item_path = /obj/item/clothing/suit/jacket/frontier_colonist

/datum/loadout_item/suit/cossak
	name = "Ukrainian Coat"
	item_path = /obj/item/clothing/suit/cossack

/datum/loadout_item/suit/parka
	name = "Falls Parka"
	item_path = /obj/item/clothing/suit/fallsparka

/datum/loadout_item/suit/urban
	name = "Urban Coat"
	item_path = /obj/item/clothing/suit/urban

/datum/loadout_item/suit/maxson
	name = "Fancy Brown Coat"
	item_path = /obj/item/clothing/suit/brownbattlecoat

/datum/loadout_item/suit/bossu
	name = "Fancy Black Coat"
	item_path = /obj/item/clothing/suit/blackfurrich

/datum/loadout_item/suit/dutchjacket
	name = "Western Jacket"
	item_path = /obj/item/clothing/suit/dutchjacketsr

/datum/loadout_item/suit/caretaker
	name = "Caretaker Jacket"
	item_path = /obj/item/clothing/suit/victoriantailcoatbutler

/datum/loadout_item/suit/colourable_leather_jacket
	name = "Colourable Leather Jacket"
	item_path = /obj/item/clothing/suit/jacket/leather/colourable

/datum/loadout_item/suit/frontierjacket/short
	name = "Frontier Jacket (Short)"
	item_path = /obj/item/clothing/suit/jacket/frontier_colonist/short

/datum/loadout_item/suit/frontierjacket/short/medical
	name = "Frontier Medical Jacket (Short)"
	item_path = /obj/item/clothing/suit/jacket/frontier_colonist/medical

/datum/loadout_item/suit/woolcoat
	name = "Leather Overcoat"
	item_path = /obj/item/clothing/suit/woolcoat

/datum/loadout_item/suit/flakjack
	name = "Flak Jacket"
	item_path = /obj/item/clothing/suit/flakjack

/datum/loadout_item/suit/deckard
	name = "Runner Coat"
	item_path = /obj/item/clothing/suit/toggle/deckard
	restricted_roles = list(JOB_DETECTIVE)
	requires_purchase = FALSE

/datum/loadout_item/suit/bltrench
	name = "Black Trenchcoat"
	item_path = /obj/item/clothing/suit/trenchblack

/datum/loadout_item/suit/brtrench
	name = "Brown Trenchcoat"
	item_path = /obj/item/clothing/suit/trenchbrown

/datum/loadout_item/suit/discojacket
	name = "Disco Ass Blazer"
	item_path = /obj/item/clothing/suit/discoblazer

/datum/loadout_item/suit/kimjacket
	name = "Aerostatic Bomber Jacket"
	item_path = /obj/item/clothing/suit/kimjacket

/datum/loadout_item/suit/cardigan
	name = "Cardigan"
	item_path = /obj/item/clothing/suit/toggle/jacket/cardigan

/*
*	HOODIES
*/

/datum/loadout_item/suit/hoodie/greyscale
	name = "Greyscale Hoodie"
	item_path = /obj/item/clothing/suit/toggle/jacket/hoodie

/datum/loadout_item/suit/hoodie/greyscale_trim
	name = "Greyscale Trimmed Hoodie"
	item_path = /obj/item/clothing/suit/toggle/jacket/hoodie/trim

/datum/loadout_item/suit/hoodie/greyscale_trim_alt
	name = "Greyscale Trimmed Hoodie (Alt)"
	item_path = /obj/item/clothing/suit/toggle/jacket/hoodie/trim/alt

/datum/loadout_item/suit/hoodie/black
	name = "Black Hoodie"
	item_path = /obj/item/clothing/suit/toggle/jacket/hoodie/black

/datum/loadout_item/suit/hoodie/red
	name = "Red Hoodie"
	item_path = /obj/item/clothing/suit/toggle/jacket/hoodie/red

/datum/loadout_item/suit/hoodie/blue
	name = "Blue Hoodie"
	item_path = /obj/item/clothing/suit/toggle/jacket/hoodie/blue

/datum/loadout_item/suit/hoodie/green
	name = "Green Hoodie"
	item_path = /obj/item/clothing/suit/toggle/jacket/hoodie/green

/datum/loadout_item/suit/hoodie/orange
	name = "Orange Hoodie"
	item_path = /obj/item/clothing/suit/toggle/jacket/hoodie/orange

/datum/loadout_item/suit/hoodie/yellow
	name = "Yellow Hoodie"
	item_path = /obj/item/clothing/suit/toggle/jacket/hoodie/yellow

/datum/loadout_item/suit/hoodie/grey
	name = "Grey Hoodie"
	item_path = /obj/item/clothing/suit/toggle/jacket/hoodie/grey

/datum/loadout_item/suit/hoodie/nt
	name = "NT Hoodie"
	item_path = /obj/item/clothing/suit/toggle/jacket/hoodie/branded

/datum/loadout_item/suit/hoodie/smw
	name = "SMW Hoodie"
	item_path = /obj/item/clothing/suit/toggle/jacket/hoodie/branded/smw

/datum/loadout_item/suit/hoodie/nrti
	name = "NRTI Hoodie"
	item_path = /obj/item/clothing/suit/toggle/jacket/hoodie/branded/nrti

/datum/loadout_item/suit/hoodie/cti
	name = "CTI Hoodie"
	item_path = /obj/item/clothing/suit/toggle/jacket/hoodie/branded/cti

/datum/loadout_item/suit/hoodie/mu
	name = "Mojave University Hoodie"
	item_path = /obj/item/clothing/suit/toggle/jacket/hoodie/branded/mu

/*
*	JOB-LOCKED
*/

// JACKETS
/datum/loadout_item/suit/navybluejacketofficer
	name = "Security Officer's Navy Blue Formal Jacket"
	item_path = /obj/item/clothing/suit/jacket/officer/blue
	restricted_roles = list(JOB_WARDEN, JOB_DETECTIVE, JOB_SECURITY_OFFICER, JOB_HEAD_OF_SECURITY, JOB_SECURITY_ASSISTANT, JOB_BRIG_PHYSICIAN)
	requires_purchase = FALSE

/datum/loadout_item/suit/navybluejacketwarden
	name = "Warden's Navy Blue Formal Jacket"
	item_path = /obj/item/clothing/suit/jacket/warden/blue
	restricted_roles = list(JOB_WARDEN)
	requires_purchase = FALSE

/datum/loadout_item/suit/navybluejackethos
	name = "Head of Security's Navy Blue Formal Jacket"
	item_path = /obj/item/clothing/suit/jacket/hos/blue
	restricted_roles = list(JOB_HEAD_OF_SECURITY)
	requires_purchase = FALSE

/datum/loadout_item/suit/security_jacket
	name = "Security Jacket"
	item_path = /obj/item/clothing/suit/toggle/jacket/sec
	restricted_roles = list(JOB_WARDEN, JOB_DETECTIVE, JOB_SECURITY_OFFICER, JOB_HEAD_OF_SECURITY, JOB_SECURITY_ASSISTANT, JOB_BRIG_PHYSICIAN)
	requires_purchase = FALSE

/datum/loadout_item/suit/brit
	name = "High Vis Armored Vest"
	item_path = /obj/item/clothing/suit/armor/vest/peacekeeper/brit
	restricted_roles = list(JOB_HEAD_OF_SECURITY, JOB_SECURITY_OFFICER, JOB_WARDEN, JOB_DETECTIVE,  JOB_SECURITY_ASSISTANT, JOB_BRIG_PHYSICIAN)
	requires_purchase = FALSE

/datum/loadout_item/suit/british_jacket
	name = "Peacekeeper Officer Coat"
	item_path = /obj/item/clothing/suit/british_officer
	restricted_roles = list(JOB_WARDEN, JOB_DETECTIVE, JOB_SECURITY_OFFICER, JOB_HEAD_OF_SECURITY,  JOB_SECURITY_ASSISTANT, JOB_BRIG_PHYSICIAN)
	requires_purchase = FALSE

/datum/loadout_item/suit/peacekeeper_jacket
	name = "Peacekeeper Jacket"
	item_path = /obj/item/clothing/suit/armor/vest/peacekeeper/jacket
	restricted_roles = list(JOB_WARDEN, JOB_DETECTIVE, JOB_SECURITY_OFFICER, JOB_HEAD_OF_SECURITY,  JOB_SECURITY_ASSISTANT, JOB_BRIG_PHYSICIAN)
	requires_purchase = FALSE

/datum/loadout_item/suit/peacekeeper_jacket/badge
	name = "Badged Peacekeeper Jacket"
	item_path = /obj/item/clothing/suit/armor/vest/peacekeeper/jacket/badge

/datum/loadout_item/suit/offdep_jacket
	name = "Off-Department Jacket"
	item_path = /obj/item/clothing/suit/toggle/jacket/assistant

/datum/loadout_item/suit/engi_jacket
	name = "Engineering Jacket"
	item_path = /obj/item/clothing/suit/toggle/jacket/engi
	restricted_roles = list(JOB_STATION_ENGINEER, JOB_ATMOSPHERIC_TECHNICIAN, JOB_CHIEF_ENGINEER)
	requires_purchase = FALSE

/datum/loadout_item/suit/sci_jacket
	name = "Science Jacket"
	item_path = /obj/item/clothing/suit/toggle/jacket/sci
	restricted_roles = list(JOB_SCIENTIST, JOB_GENETICIST, JOB_ROBOTICIST, JOB_RESEARCH_DIRECTOR)
	requires_purchase = FALSE

/datum/loadout_item/suit/med_jacket
	name = "Medbay Jacket"
	item_path = /obj/item/clothing/suit/toggle/jacket/med
	restricted_roles = list(JOB_PARAMEDIC, JOB_MEDICAL_DOCTOR, JOB_CHEMIST, JOB_VIROLOGIST, JOB_CHIEF_MEDICAL_OFFICER)
	requires_purchase = FALSE

/datum/loadout_item/suit/supply_jacket
	name = "Supply Jacket"
	item_path = /obj/item/clothing/suit/toggle/jacket/supply
	restricted_roles = list(JOB_CARGO_TECHNICIAN, JOB_SHAFT_MINER, JOB_QUARTERMASTER)
	requires_purchase = FALSE

/datum/loadout_item/suit/digicoat_glitched //Public donator reward for Razurath.
	name = "Glitched Digicoat"
	item_path = /obj/item/clothing/suit/toggle/digicoat/glitched

/datum/loadout_item/suit/warm_coat
	name = "Colourable Warm Coat"
	item_path = /obj/item/clothing/suit/warm_coat

/datum/loadout_item/suit/warm_sweater
	name = "Colourable Warm Sweater"
	item_path = /obj/item/clothing/suit/warm_sweater

/datum/loadout_item/suit/heart_sweater
	name = "Colourable Heart Sweater"
	item_path = /obj/item/clothing/suit/heart_sweater

/datum/loadout_item/suit/crop_jacket
	name = "Colourable Crop-Top Jacket"
	item_path = /obj/item/clothing/suit/crop_jacket

/datum/loadout_item/suit/sleeveless_crop_jacket
	name = "Colourable Sleeveless Crop-Top Jacket"
	item_path = /obj/item/clothing/suit/crop_jacket/sleeveless

/*
*	CHAPLAIN
*/

/datum/loadout_item/suit/chap_nun
	name = "Nun's Habit"
	item_path = /obj/item/clothing/suit/chaplainsuit/nun
	restricted_roles = list(JOB_CHAPLAIN)
	requires_purchase = FALSE

/datum/loadout_item/suit/chap_holiday
	name = "Chaplain's Holiday Robe"
	item_path = /obj/item/clothing/suit/chaplainsuit/holidaypriest
	restricted_roles = list(JOB_CHAPLAIN)
	requires_purchase = FALSE

/datum/loadout_item/suit/chap_brownmonk
	name = "Monk's Brown Habit"
	item_path = /obj/item/clothing/suit/hooded/chaplainsuit/monkhabit
	restricted_roles = list(JOB_CHAPLAIN)
	requires_purchase = FALSE

/datum/loadout_item/suit/chap_eastmonk
	name = "Eastern Monk's Robe"
	item_path = /obj/item/clothing/suit/chaplainsuit/monkrobeeast
	restricted_roles = list(JOB_CHAPLAIN)
	requires_purchase = FALSE

/datum/loadout_item/suit/chap_shrinehand
	name = "Shrinehand Robe"
	item_path = /obj/item/clothing/suit/chaplainsuit/shrinehand
	restricted_roles = list(JOB_CHAPLAIN)
	requires_purchase = FALSE

