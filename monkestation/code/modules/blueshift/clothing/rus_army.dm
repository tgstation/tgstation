// THESE WILL (MOSTLY) SPAWN WITH A RANDOM 'CAMO' COLOR WHEN ORDERED THROUGH CARGO
// THE STANDARD COLORS FOR USE WILL BE BELOW

#define CIN_WINTER_COLORS "#bbbbc9"
#define CIN_MOUNTAIN_DESERT_COLORS "#aa6d4c"
#define CIN_FOREST_COLORS "#6D6D51"
#define CIN_MARINE_COLORS "#51517b"
#define CIN_EVIL_COLORS "#5d5d66"

#define CIN_WINTER_COLORS_COMPLIMENT "#838392"
#define CIN_MOUNTAIN_DESERT_COLORS_COMPLIMENT "#a37e45"
#define CIN_FOREST_COLORS_COMPLIMENT "#474734"
#define CIN_MARINE_COLORS_COMPLIMENT "#39394d"
#define CIN_EVIL_COLORS_COMPLIMENT "#3d3d46"

#define HELMET_NO_ACCESSORIES "plain"
#define HELMET_CHINSTRAP "strap"
#define HELMET_GLASS_VISOR "glass"
#define HELMET_BOTH_OF_THE_ABOVE "both"

// Shared Armor Datum
// CIN armor is decently tough against bullets and wounding, but flounders when lasers enter the play, because it wasn't designed to protect against those much

/datum/armor/cin_surplus_armor
	melee = 30
	bullet = 40
	laser = 10
	energy = 10
	bomb = 40
	fire = 50
	acid = 50
	wound = 20

// Hats

/obj/item/clothing/head/helmet/cin_surplus_helmet
	name = "\improper GZ-03 combat helmet"
	desc = "An outdated service helmet previously used by CIN military forces. The design dates back to the years leading up to CIN - SolFed border war, and was in service until the advent of VOSKHOD powered armor becoming standard issue."
	icon = 'monkestation/code/modules/blueshift/icons/surplus_armor/surplus_armor.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/surplus_armor/surplus_armor_object.dmi'
	icon_state = "helmet_plain"
	greyscale_config = /datum/greyscale_config/cin_surplus_helmet/object
	greyscale_config_worn = /datum/greyscale_config/cin_surplus_helmet
	greyscale_colors = CIN_WINTER_COLORS
	armor_type = /datum/armor/cin_surplus_armor

	/// Controls what helmet accessories will be present in a weighted format
	var/static/list/accessories_weighted_list = list(
		HELMET_NO_ACCESSORIES = 15,
		HELMET_CHINSTRAP = 10,
		HELMET_GLASS_VISOR = 10,
		HELMET_BOTH_OF_THE_ABOVE = 5,
	)

/obj/item/clothing/head/helmet/cin_surplus_helmet/Initialize(mapload)
	. = ..()

	generate_random_accessories()

/// Takes accessories_weighted_list and picks what icon_state suffix to use
/obj/item/clothing/head/helmet/cin_surplus_helmet/proc/generate_random_accessories()
	var/chosen_accessories = pick_weight(accessories_weighted_list)

	icon_state = "helmet_[chosen_accessories]"

	if(chosen_accessories == (HELMET_GLASS_VISOR || HELMET_BOTH_OF_THE_ABOVE))
		flags_cover = HEADCOVERSEYES
	else
		flags_cover = NONE

	update_appearance()

/obj/item/clothing/head/helmet/cin_surplus_helmet/examine_more(mob/user)
	. = ..()

	. += "The GZ-03 series of coalition armor was a collaborative project between the NRI and TransOrbital \
		to develop a frontline soldier's armor set that could withstand attacks from the Solar Federation's \
		then relatively new pulse ballistics. The design itself is based upon a far older pattern \
		of armor originally developed by SolFed themselves, which was the standard pattern of armor design \
		granted to the first colony ships leaving Sol. Armor older than any of the CIN member states, \
		upgraded with modern technology. This helmet in particular encloses the entire head save for \
		the face, and should come with a glass visor and relatively comfortable internal padding. Should, \
		anyways, surplus units such as this are infamous for arriving with several missing accessories."

	return .

/obj/item/clothing/head/helmet/cin_surplus_helmet/desert
	greyscale_colors = CIN_MOUNTAIN_DESERT_COLORS

/obj/item/clothing/head/helmet/cin_surplus_helmet/forest
	greyscale_colors = CIN_FOREST_COLORS

/obj/item/clothing/head/helmet/cin_surplus_helmet/marine
	greyscale_colors = CIN_MARINE_COLORS

/obj/item/clothing/head/helmet/cin_surplus_helmet/random_color
	/// The different colors this helmet can choose from when initializing
	var/static/list/possible_spawning_colors = list(
		CIN_WINTER_COLORS,
		CIN_MOUNTAIN_DESERT_COLORS,
		CIN_FOREST_COLORS,
		CIN_MARINE_COLORS,
		CIN_EVIL_COLORS,
	)

/obj/item/clothing/head/helmet/cin_surplus_helmet/random_color/Initialize(mapload)
	greyscale_colors = pick(possible_spawning_colors)

	. = ..()

// Undersuits

/obj/item/clothing/under/syndicate/rus_army/cin_surplus
	name = "\improper CIN combat uniform"
	desc = "A CIN designed combat uniform that can come in any number of camouflauge variations. Despite this particular design being developed in the years leading up to the CIN-SolFed border war, the uniform is still in use by many member states to this day."
	icon = 'monkestation/code/modules/blueshift/icons/surplus_armor/surplus_armor.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/surplus_armor/surplus_armor_object.dmi'
	icon_state = "undersuit_greyscale"
	greyscale_config = /datum/greyscale_config/cin_surplus_undersuit/object
	greyscale_config_worn = /datum/greyscale_config/cin_surplus_undersuit
	greyscale_config_worn_digitigrade = /datum/greyscale_config/cin_surplus_undersuit/digi
	greyscale_colors = "#bbbbc9#bbbbc9#34343a"

/obj/item/clothing/under/syndicate/rus_army/cin_surplus/desert
	greyscale_colors = "#aa6d4c#aa6d4c#34343a"

/obj/item/clothing/under/syndicate/rus_army/cin_surplus/forest
	greyscale_colors = "#6D6D51#6D6D51#34343a"

/obj/item/clothing/under/syndicate/rus_army/cin_surplus/marine
	greyscale_colors = "#51517b#51517b#34343a"

/obj/item/clothing/under/syndicate/rus_army/cin_surplus/random_color
	/// What colors the jumpsuit can spawn with (only does the arms and legs of it)
	var/static/list/possible_limb_colors = list(
		CIN_WINTER_COLORS,
		CIN_MOUNTAIN_DESERT_COLORS,
		CIN_FOREST_COLORS,
		CIN_MARINE_COLORS,
	)

/obj/item/clothing/under/syndicate/rus_army/cin_surplus/random_color/Initialize(mapload)
	greyscale_colors = "[pick(possible_limb_colors)][pick(possible_limb_colors)][CIN_EVIL_COLORS]"

	. = ..()

// Vests

/obj/item/clothing/suit/armor/vest/cin_surplus_vest
	name = "\improper GZ-03 armor vest"
	desc = "An outdated armor vest previously used by CIN military forces. The design dates back to the years leading up to CIN - SolFed border war, and was in service until the advent of VOSKHOD powered armor becoming standard issue."
	worn_icon = 'monkestation/code/modules/blueshift/icons/surplus_armor/surplus_armor.dmi'
	icon = 'monkestation/code/modules/blueshift/icons/surplus_armor/surplus_armor_object.dmi'
	icon_state = "vest_basic"
	armor_type = /datum/armor/cin_surplus_armor
	supports_variations_flags = CLOTHING_NO_VARIATION

/obj/item/clothing/suit/armor/vest/cin_surplus_vest/Initialize(mapload)
	. = ..()

	generate_random_accessories()

/// Decides if the armor vest should have its extra plates or not
/obj/item/clothing/suit/armor/vest/cin_surplus_vest/proc/generate_random_accessories()
	if(prob(30))
		icon_state = "vest_extra"
		body_parts_covered = CHEST|GROIN // In reality this does like nothing at all but flavor you know
	else
		icon_state = "vest_basic"
		body_parts_covered = CHEST

	update_appearance()

/obj/item/clothing/suit/armor/vest/cin_surplus_vest/examine_more(mob/user)
	. = ..()

	. += "The GZ-03 series of coalition armor was a collaborative project between the NRI and TransOrbital \
		to develop a frontline soldier's armor set that could withstand attacks from the Solar Federation's \
		then relatively new pulse ballistics. The design itself is based upon a far older pattern \
		of armor originally developed by SolFed themselves, which was the standard pattern of armor design \
		granted to the first colony ships leaving Sol. Armor older than any of the CIN member states, \
		upgraded with modern technology. This vest in particular is made up of several large, dense plates \
		front and back. While vests like this were also produced with extra plating to protect the groin, many \
		surplus vests are missing them due to the popularity of removing the plates and using them as seating \
		during wartime."

	return .

// Chest Rig

/obj/item/storage/belt/military/cin_surplus
	desc = "A tactical webbing often used by the CIN's military forces."
	icon = 'monkestation/code/modules/blueshift/icons/surplus_armor/surplus_armor.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/surplus_armor/surplus_armor_object.dmi'
	icon_state = "chestrig"
	worn_icon_state = "chestrig"
	greyscale_config = /datum/greyscale_config/cin_surplus_chestrig/object
	greyscale_config_worn = /datum/greyscale_config/cin_surplus_chestrig
	greyscale_colors = CIN_WINTER_COLORS_COMPLIMENT

/obj/item/storage/belt/military/cin_surplus/desert
	greyscale_colors = CIN_MOUNTAIN_DESERT_COLORS_COMPLIMENT

/obj/item/storage/belt/military/cin_surplus/forest
	greyscale_colors = CIN_FOREST_COLORS_COMPLIMENT

/obj/item/storage/belt/military/cin_surplus/marine
	greyscale_colors = CIN_MARINE_COLORS_COMPLIMENT

/obj/item/storage/belt/military/cin_surplus/random_color
	/// The different colors this can choose from when initializing
	var/static/list/possible_spawning_colors = list(
		CIN_WINTER_COLORS_COMPLIMENT,
		CIN_MOUNTAIN_DESERT_COLORS_COMPLIMENT,
		CIN_FOREST_COLORS_COMPLIMENT,
		CIN_MARINE_COLORS_COMPLIMENT,
		CIN_EVIL_COLORS_COMPLIMENT,
	)

/obj/item/storage/belt/military/cin_surplus/random_color/Initialize(mapload)
	greyscale_colors = pick(possible_spawning_colors)

	. = ..()

// Backpack

/obj/item/storage/backpack/industrial/cin_surplus
	name = "\improper CIN military backpack"
	desc = "A rugged backpack often used by the CIN's military forces."
	icon = 'monkestation/code/modules/blueshift/icons/surplus_armor/surplus_armor.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/surplus_armor/surplus_armor_object.dmi'
	icon_state = "backpack"
	greyscale_config = /datum/greyscale_config/cin_surplus_backpack/object
	greyscale_config_worn = /datum/greyscale_config/cin_surplus_backpack
	greyscale_colors = CIN_WINTER_COLORS_COMPLIMENT

/obj/item/storage/backpack/industrial/cin_surplus/desert
	greyscale_colors = CIN_MOUNTAIN_DESERT_COLORS_COMPLIMENT

/obj/item/storage/backpack/industrial/cin_surplus/forest
	greyscale_colors = CIN_FOREST_COLORS_COMPLIMENT

/obj/item/storage/backpack/industrial/cin_surplus/marine
	greyscale_colors = CIN_MARINE_COLORS_COMPLIMENT

/obj/item/storage/backpack/industrial/cin_surplus/random_color
	/// The different colors this can choose from when initializing
	var/static/list/possible_spawning_colors = list(
		CIN_WINTER_COLORS_COMPLIMENT,
		CIN_MOUNTAIN_DESERT_COLORS_COMPLIMENT,
		CIN_FOREST_COLORS_COMPLIMENT,
		CIN_MARINE_COLORS_COMPLIMENT,
		CIN_EVIL_COLORS_COMPLIMENT,
	)

/obj/item/storage/backpack/industrial/cin_surplus/random_color/Initialize(mapload)
	greyscale_colors = pick(possible_spawning_colors)

	. = ..()

#undef CIN_WINTER_COLORS
#undef CIN_MOUNTAIN_DESERT_COLORS
#undef CIN_FOREST_COLORS
#undef CIN_MARINE_COLORS
#undef CIN_EVIL_COLORS

#undef CIN_WINTER_COLORS_COMPLIMENT
#undef CIN_MOUNTAIN_DESERT_COLORS_COMPLIMENT
#undef CIN_FOREST_COLORS_COMPLIMENT
#undef CIN_MARINE_COLORS_COMPLIMENT
#undef CIN_EVIL_COLORS_COMPLIMENT
