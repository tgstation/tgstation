/obj/item/clothing/suit/jacket/doppler
	icon = 'modular_doppler/modular_cosmetics/icons/obj/suit/jacket.dmi'
	worn_icon = 'modular_doppler/modular_cosmetics/icons/mob/suit/jacket.dmi'
	slot_flags = ITEM_SLOT_OCLOTHING|ITEM_SLOT_NECK

/obj/item/clothing/suit/jacket/doppler/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/pockets/jacket)

/obj/item/clothing/suit/hooded/doppler
	icon = 'modular_doppler/modular_cosmetics/icons/obj/suit/jacket.dmi'
	worn_icon = 'modular_doppler/modular_cosmetics/icons/mob/suit/jacket.dmi'
	slot_flags = ITEM_SLOT_OCLOTHING|ITEM_SLOT_NECK

/obj/item/clothing/suit/hooded/doppler/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/pockets/jacket)

/datum/armor/jacket_armor //because our jackets can go in the neck slot, they should have little to no armor
	melee = 0
	bullet = 0
	laser = 0
	energy = 0
	bomb = 0
	bio = 10
	fire = 0
	acid = 10
	wound = 5

////////////////////////
//DEPARTMENTAL JACKETS//
////////////////////////

/obj/item/clothing/suit/jacket/doppler/departmental_jacket
	name = "work jacket"
	desc = "A simple and practical jacket for labor with a center front zipper closure, two handwarmer pockets, \
	and two interior pockets. A venerable old design in cutting edge textile fiber."
	icon_state = "off_dep_jacket"
	allowed = list(
		/obj/item/flashlight,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/tank/internals/plasmaman,
		/obj/item/toy,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/lighter,
		/obj/item/radio,
		)
	body_parts_covered = CHEST|ARMS|GROIN
	cold_protection = CHEST|ARMS|GROIN
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT

/obj/item/clothing/suit/jacket/doppler/departmental_jacket/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/toggle_icon, "zipper")

/obj/item/clothing/suit/jacket/doppler/departmental_jacket/engi
	name = "engineering department jacket"
	desc = "A simple jacket emblazoned with the ship's engineering team insignia, it features tape-welded seams \
	and expanded pockets."
	icon_state = "engi_dep_jacket"
	armor_type = /datum/armor/jacket_armor
	allowed = list(
		/obj/item/flashlight,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/tank/internals/plasmaman,
		/obj/item/t_scanner,
		/obj/item/construction/rcd,
		/obj/item/pipe_dispenser,
		/obj/item/toy,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/lighter,
		)

/obj/item/clothing/suit/jacket/doppler/departmental_jacket/engi/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/toggle_icon, "zipper")
	create_storage(storage_type = /datum/storage/pockets/jacket/jumbo)

/obj/item/clothing/suit/jacket/doppler/departmental_jacket/sci
	name = "science department jacket"
	desc = "A spill-proof Harrington style jacket denoting employment in the R&D division."
	icon_state = "sci_dep_jacket"
	armor_type = /datum/armor/jacket_armor

/obj/item/clothing/suit/jacket/doppler/departmental_jacket/med
	name = "medical department jacket"
	desc = "A basic Harrington style jacket in stain-resistant and washable hyperpoly fibers. It isn't \
	apparent from looking at it, but this style is cut with wider sleeves and relaxed cuffs, to better \
	allow for pushing them up past the elbows."
	icon_state = "med_dep_jacket"
	armor_type = /datum/armor/jacket_armor

/obj/item/clothing/suit/jacket/doppler/departmental_jacket/supply
	name = "cargo department jacket"
	desc = "A hardwearing jacket for chilly warehouses and cargo holds. By popular and incessant request \
	these are fitted with extra large pockets."
	icon_state = "supply_dep_jacket"

/obj/item/clothing/suit/jacket/doppler/departmental_jacket/supply/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/toggle_icon, "zipper")
	create_storage(storage_type = /datum/storage/pockets/jacket/jumbo)

/obj/item/clothing/suit/jacket/doppler/departmental_jacket/sec
	name = "blue security department jacket"
	desc = "A basic style of jacket cut just so to ensure that the plate carrier beneath it doesn't imprint \
	on the shell, and to readily accomodate a holstered weapon."
	icon_state = "sec_dep_jacket"
	armor_type = /datum/armor/jacket_armor

/obj/item/clothing/suit/jacket/doppler/departmental_jacket/sec/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/toggle_icon, "zipper")
	allowed = GLOB.security_vest_allowed
	create_storage(storage_type = /datum/storage/pockets/jacket/jumbo)

/obj/item/clothing/suit/jacket/doppler/departmental_jacket/sec/red
	name = "red security department jacket"
	desc = "A basic style of jacket cut just so to ensure that the plate carrier beneath it doesn't imprint \
	on the shell, and to readily accomodate a holstered weapon."
	icon_state = "sec_dep_jacket_old"

/obj/item/clothing/suit/jacket/doppler/sec_medic
	name = "security medic jacket"
	desc = "A tight synthetic knit protects the wearer from errant needlestabs, though the sleeves are often rolled \
	away from the forarm. Its pockets are very generous."
	icon_state = "secmed_labcoat_blue"

/obj/item/clothing/suit/jacket/doppler/sec_medic/Initialize(mapload)
	. = ..()
	allowed = GLOB.security_vest_allowed
	create_storage(storage_type = /datum/storage/pockets/jacket/jumbo)

////////////////////
//MORE SEC JACKETS//
////////////////////

/obj/item/clothing/suit/jacket/doppler/peacekeeper_jacket
	name = "peacekeeper jacket"
	desc = "A slightly vintage canvas and aramid jacket; hi-vis checkers included. Armored and stylish? Implausible."
	icon_state = "peacekeeper_jacket"
	body_parts_covered = CHEST|GROIN|ARMS
	cold_protection = CHEST|GROIN|ARMS
	heat_protection = CHEST|GROIN|ARMS
	armor_type = /datum/armor/jacket_armor

/obj/item/clothing/suit/jacket/doppler/peacekeeper_jacket/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/toggle_icon, "zipper")
	allowed = GLOB.security_vest_allowed
	create_storage(storage_type = /datum/storage/pockets/jacket/jumbo)

/obj/item/clothing/suit/jacket/doppler/peacekeeper_jacket/badged
	name = "badged peacekeeper jacket"
	desc = "A slightly vintage canvas and aramid jacket; hi-vis checkers and chevron badge included. Armored and stylish? Implausible."
	icon_state = "peacekeeper_jacket_badge"

/obj/item/clothing/suit/jacket/doppler/peacekeeper_jacket/hazard
	name = "security hazard vest"
	desc = "Strips of retroreflective tape bind dayglo mesh into a visually protective vest."
	icon_state = "hazardbg"

/obj/item/clothing/suit/jacket/doppler/runner_coat
	name = "runner coat"
	desc = "A weighty coat of thick synthshearling still bears the patternmaking concessions to the limited size \
	of pre-printed sheepskin. What was once a style of necessity has become a matter of authenticity."
	icon_state = "runner_coat"
	armor_type = /datum/armor/jacket_armor

/obj/item/clothing/suit/jacket/doppler/runner_coat/Initialize(mapload)
	. = ..()
	allowed = GLOB.security_vest_allowed
	create_storage(storage_type = /datum/storage/pockets/jacket/jumbo)

////////////////
//MORE JACKETS//
////////////////

/obj/item/clothing/suit/jacket/doppler/field_jacket
	name = "venerable old field jacket"
	desc = "Something like this style of gabardine jacket has been in and out of style for military forces for \
	centuries. Simple drab is sometimes used where camoflauge would be irrelevant even now."
	icon_state = "field_jacket"

/obj/item/clothing/suit/jacket/doppler/field_jacket/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/toggle_icon, "zipper")
	create_storage(storage_type = /datum/storage/pockets/jacket/jumbo)

/obj/item/clothing/suit/jacket/doppler/field_jacket/tan
	name = "venerable old tan jacket"
	desc = "A lightened field jacket with ample pockets, intended for arid deployments some decades now and now \
	serving a second life as a fashion item."
	icon_state = "tan_field_jacket"

/obj/item/clothing/suit/hooded/doppler/leather_hoodie
	name = "leather jacket with hoodie"
	desc = ""
	icon_state = "leatherhoodie"
	body_parts_covered = CHEST|GROIN|ARMS
	hoodtype = /obj/item/clothing/head/hooded/leather

/obj/item/clothing/head/hooded/leather
	name = "sweatshirt hood"
	desc = "A hood attached to a hoodie, nothing special."
	icon_state = "leatherhood"
	icon = 'modular_doppler/modular_cosmetics/icons/obj/head/hoods.dmi'
	worn_icon = 'modular_doppler/modular_cosmetics/icons/mob/head/hoods.dmi'
	flags_inv = HIDEHAIR
	armor_type = /datum/armor/jacket_armor

/////////
//COATS//
/////////

/obj/item/clothing/suit/jacket/doppler/fur_coat
	name = "rugged fur coat"
	desc = "Even in an age where any large mammal can be grown in situ at industrial levels some insist on having \
	the pelts of 'real' creatures to wear. The unnecessary suffering gives this coat a grim aura."
	icon_state = "winter_coat"
	armor_type = /datum/armor/jacket_armor

/obj/item/clothing/suit/jacket/doppler/wrap_coat
	name = "chic wrap coat"
	desc = "A jacket possessed of measured asymmetry, its fly-front closure conceals its fasteners as if the single \
	wide belt is all that holds it closed. Surprisingly warm."
	icon_state = "modern_winter"

/obj/item/clothing/suit/jacket/doppler/red_trench
	name = "Marsian PLA trenchcoat by Alpha Atelier"
	desc = "An exhaustive and expensive reproduction of trenchcoats favored by the vanguards of a Marsian revolutionary \
	movement who would likely shoot its wearer if they were alive to see the price tag."
	icon_state = "red_trench"
	armor_type = /datum/armor/jacket_armor

/obj/item/clothing/suit/jacket/doppler/red_trench/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/pockets/jacket/jumbo)
