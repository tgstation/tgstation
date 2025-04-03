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
	armor_type = /datum/armor/cosmetic_sec

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
	armor_type = /datum/armor/cosmetic_sec

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
	desc = "A lightened field jacket with ample pockets, intended for arid deployments some decades ago and now \
	serving a second life as a fashion item."
	icon_state = "tan_field_jacket"

/obj/item/clothing/suit/hooded/doppler/leather_hoodie
	name = "leather jacket with hoodie"
	desc = "The leather jacket itself takes after workwear stylings for denim and canvas chore coats, looking \
	something like a fetishistic rock take on blue collar. The hoodie? That's just a hoodie."
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

/obj/item/clothing/suit/jacket/doppler/long_suit_jacket
	name = "long severe suit jacket"
	desc = "A severe jacket with built up shoulders and an aggressively suppressed waistline that features a dramatic, \
	coatlike length. The synthwoolen blended fabric is smooth and soft while preserving a dense worsted pile."
	icon_state = "long_suit_jacket"

/obj/item/clothing/suit/jacket/doppler/long_suit_jacket/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/toggle_icon, "button")

/obj/item/clothing/suit/jacket/doppler/short_suit_jacket
	name = "severe suit jacket"
	desc = "A severe suit jacket with tall shoulders and a slim silhoutte. Over the years single button jackets like this \
	one have prevailed over two and three button jackets."
	icon_state = "suit_jacket"

/obj/item/clothing/suit/jacket/doppler/short_suit_jacket/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/toggle_icon, "button")

/obj/item/clothing/suit/jacket/doppler/big_jacket
	name = "\improper Alpha Atelier pilot jacket"
	desc = "An exacting reproduction of the pilot jackets worn in the infancy of faster than light travel, \
		right down the precise tension of thread spun on the precisely correct looms. The pilots it pays homage \
		to worked in small ships and in close proximity to their supercooled drives and needed extreme insulation, \
		hence the bulk."
	icon_state = "big_jacket"
	greyscale_config = /datum/greyscale_config/big_jacket
	greyscale_config_worn = /datum/greyscale_config/big_jacket/worn
	greyscale_colors = "#666633#333300#666633"
	flags_1 = IS_PLAYER_COLORABLE_1
	body_parts_covered = CHEST|ARMS
	cold_protection = CHEST|ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT

/obj/item/clothing/suit/jacket/doppler/gacket
	name = "crop-top jacket"
	desc = "A remarkably fancy-looking two-tone cropped jacket with a nice gold trim, and a golden middle finger on the back."
	icon_state = "gacket"
	worn_icon_state = "gacket"

/////////
//COATS//
/////////

/obj/item/clothing/suit/jacket/doppler/chokha
	name = "\improper Iseurian chokha"
	desc = "A ceremonial woolen coat sporting a high neck and decorative gunpowder cases on the breast. The label on this one bears the Iseurian Revolutionary flag."
	icon_state = "chokha"
	greyscale_config = /datum/greyscale_config/chokha
	greyscale_config_worn = /datum/greyscale_config/chokha/worn
	greyscale_colors = "#1c1c1c#491618#1c1c1c#491618"
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/suit/jacket/doppler/fur_coat
	name = "rugged fur coat"
	desc = "Even in an age where any large mammal can be grown in situ at industrial levels some insist on having \
	the pelts of 'real' creatures to wear. The unnecessary suffering gives this coat a grim aura."
	icon_state = "fur_coat"
	armor_type = /datum/armor/jacket_armor

/obj/item/clothing/suit/jacket/doppler/wrap_coat
	name = "chic wrap coat"
	desc = "A jacket possessed of measured asymmetry, its fly-front closure conceals its fasteners as if the single \
	wide belt is all that holds it closed. Surprisingly warm."
	icon_state = "wrap_coat"

/obj/item/clothing/suit/jacket/doppler/red_trench
	name = "Marsian PLA trenchcoat by Alpha Atelier"
	desc = "An exhaustive and expensive reproduction of trenchcoats favored by the vanguards of a Marsian revolutionary \
	movement who would likely shoot its wearer if they were alive to see the price tag."
	icon_state = "red_trench"
	armor_type = /datum/armor/jacket_armor

/obj/item/clothing/suit/jacket/doppler/red_trench/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/pockets/jacket/jumbo)

/obj/item/clothing/suit/warm_coat
	name = "warm coat"
	desc = "A long insulated coat with fur, it looks quite comfortable."
	icon_state = "warm_coat"
	greyscale_config = /datum/greyscale_config/warm_coat
	greyscale_config_worn = /datum/greyscale_config/warm_coat/worn
	greyscale_colors = "#7a5f4f#d9cec7"
	flags_1 = IS_PLAYER_COLORABLE_1
	cold_protection = CHEST|GROIN|ARMS
	body_parts_covered = CHEST|GROIN|ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT

/obj/item/clothing/suit/hooded/crop_cold_hoodie
	name = "cropped cold shoulder hoodie"
	desc = "Ringspun sweatshirt fleece has been hemmed raw at elbow height and left to roll upon itself, and \
	the patternmaker took the time to ensure the cutout shoulders lay just so."
	icon_state = "crop_cold_hoodie"
	greyscale_config = /datum/greyscale_config/crop_cold_hoodie
	greyscale_config_worn = /datum/greyscale_config/crop_cold_hoodie/worn
	greyscale_colors = "#4fc5c9"
	hoodtype = /obj/item/clothing/head/hooded/crop_cold_hoodie_hood
	flags_1 = IS_PLAYER_COLORABLE_1
	body_parts_covered = CHEST|ARMS

/obj/item/clothing/head/hooded/crop_cold_hoodie_hood
	name = "cropped cold shoulder hood"
	desc = "A fleece hood with jersey lining. It's surprisingly warm in spite of the garment that it is \
	attached to."
	icon_state = "crop_cold_hoodie_hood"
	body_parts_covered = HEAD
	cold_protection = HEAD
	flags_inv = HIDEEARS|HIDEHAIR
	flags_1 = IS_PLAYER_COLORABLE_1
	hair_mask = HAIR_MASK_HIDE_WINTERHOOD
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	greyscale_config = /datum/greyscale_config/crop_cold_hoodie_hood
	greyscale_config_worn = /datum/greyscale_config/crop_cold_hoodie_hood/worn
	greyscale_colors = "#4fc5c9"

/obj/item/clothing/suit/hooded/crop_cold_hoodie/set_greyscale(list/colors, new_config, new_worn_config, new_inhand_left, new_inhand_right)
	. = ..()
	if(!hood)
		return
	var/list/hoodie_colors = SSgreyscale.ParseColorString(greyscale_colors)
	var/list/new_hoodie_colors = hoodie_colors.Copy(1)
	hood.set_greyscale(new_hoodie_colors)
	hood.update_slot_icon()

/obj/item/clothing/suit/hooded/crop_cold_hoodie/on_hood_created(obj/item/clothing/head/hooded/hood)
	. = ..()
	var/list/hoodie_colors = (SSgreyscale.ParseColorString(greyscale_colors))
	var/list/new_hoodie_colors = hoodie_colors.Copy(1)
	hood.set_greyscale(new_hoodie_colors)

/obj/item/clothing/suit/hooded/big_hoodie
	name = "oversized hoodie"
	desc = "Cotton fibres grown in vertical aeroponic farming systems were ringspun and knit into a continuous loop fleece with \
	a soft pile and little stretch. This fabric was cut oversized with soft sloping shoulders and cuffs that fall right at the first knuckle."
	icon_state = "big_hoodie"
	greyscale_config = /datum/greyscale_config/big_hoodie
	greyscale_config_worn = /datum/greyscale_config/big_hoodie/worn
	greyscale_colors = "#5d6161"
	hoodtype = /obj/item/clothing/head/hooded/big_hoodie_hood
	flags_1 = IS_PLAYER_COLORABLE_1
	body_parts_covered = CHEST|GROIN|ARMS
	cold_protection = CHEST|GROIN|ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT

/obj/item/clothing/head/hooded/big_hoodie_hood
	name = "oversized hood"
	desc = "Cotton fibres grown in vertical aeroponic farming systems were ringspun and knit into a continuous loop fleece with \
	a soft pile and little stretch. The hood was cut comfortably oversized."
	icon_state = "big_hoodie_hood"
	body_parts_covered = HEAD
	cold_protection = HEAD
	flags_inv = HIDEEARS|HIDEHAIR
	flags_1 = IS_PLAYER_COLORABLE_1
	hair_mask = HAIR_MASK_HIDE_WINTERHOOD
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	greyscale_config = /datum/greyscale_config/big_hoodie_hood
	greyscale_config_worn = /datum/greyscale_config/big_hoodie_hood/worn
	greyscale_colors = "#5d6161"

/obj/item/clothing/suit/hooded/big_hoodie/set_greyscale(list/colors, new_config, new_worn_config, new_inhand_left, new_inhand_right)
	. = ..()
	if(!hood)
		return
	var/list/hoodie_colors = SSgreyscale.ParseColorString(greyscale_colors)
	var/list/new_hoodie_colors = hoodie_colors.Copy(1)
	hood.set_greyscale(new_hoodie_colors)
	hood.update_slot_icon()

/obj/item/clothing/suit/hooded/big_hoodie/on_hood_created(obj/item/clothing/head/hooded/hood)
	. = ..()
	var/list/hoodie_colors = (SSgreyscale.ParseColorString(greyscale_colors))
	var/list/new_hoodie_colors = hoodie_colors.Copy(1)
	hood.set_greyscale(new_hoodie_colors)

/obj/item/clothing/suit/hooded/big_hoodie/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/pockets/jacket/)

/obj/item/clothing/suit/hooded/twee_hoodie
	name = "disconcertingly twee hoodie"
	desc = "A sweatshirt of heavy and soft ringspun fleece has been adorned with a fabric simulation of ears."
	icon_state = "twee_hoodie"
	greyscale_config = /datum/greyscale_config/twee_hoodie
	greyscale_config_worn = /datum/greyscale_config/twee_hoodie/worn
	greyscale_colors = "#dbc0e0"
	hoodtype = /obj/item/clothing/head/hooded/twee_hoodie_hood
	flags_1 = IS_PLAYER_COLORABLE_1
	body_parts_covered = CHEST|GROIN|ARMS
	cold_protection = CHEST|GROIN|ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT

/obj/item/clothing/head/hooded/twee_hoodie_hood
	name = "disconcertingly twee hood"
	desc = "A hood of heavy and soft ringspun fleece has been adorned with a fabric simulation of ears."
	icon_state = "twee_hoodie_hood"
	body_parts_covered = HEAD
	cold_protection = HEAD
	flags_inv = HIDEEARS|HIDEHAIR
	flags_1 = IS_PLAYER_COLORABLE_1
	hair_mask = HAIR_MASK_HIDE_WINTERHOOD
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	greyscale_config = /datum/greyscale_config/twee_hoodie_hood
	greyscale_config_worn = /datum/greyscale_config/twee_hoodie_hood/worn
	greyscale_colors = "#dbc0e0"

/obj/item/clothing/suit/hooded/twee_hoodie/set_greyscale(list/colors, new_config, new_worn_config, new_inhand_left, new_inhand_right)
	. = ..()
	if(!hood)
		return
	var/list/hoodie_colors = SSgreyscale.ParseColorString(greyscale_colors)
	var/list/new_hoodie_colors = hoodie_colors.Copy(1,2)
	hood.set_greyscale(new_hoodie_colors)
	hood.update_slot_icon()

/obj/item/clothing/suit/hooded/twee_hoodie/on_hood_created(obj/item/clothing/head/hooded/hood)
	. = ..()
	var/list/hoodie_colors = (SSgreyscale.ParseColorString(greyscale_colors))
	var/list/new_hoodie_colors = hoodie_colors.Copy(1,2)
	hood.set_greyscale(new_hoodie_colors)

/obj/item/clothing/suit/hooded/twee_hoodie/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/pockets/jacket/)
