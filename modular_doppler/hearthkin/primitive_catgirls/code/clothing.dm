// The naming of every path in this file is going to be awful :smiling_imp:

// Outfit Datum

/datum/outfit/primitive_catgirl
	name = "Icemoon Dweller"

	uniform = /obj/item/clothing/under/dress/skirt/primitive_catgirl_body_wraps
	shoes = /obj/item/clothing/shoes/winterboots/ice_boots/primitive_catgirl_boots
	gloves = /obj/item/clothing/gloves/fingerless/primitive_catgirl_armwraps
	suit = /obj/item/clothing/suit/jacket/primitive_catgirl_coat
	neck = /obj/item/clothing/neck/scarf/primitive_catgirl_scarf

	back = /obj/item/forging/reagent_weapon/axe/fake_copper

// Under

/obj/item/clothing/under/dress/skirt/primitive_catgirl_body_wraps
	name = "body wraps"
	desc = "Some pretty simple wraps to cover up your lower bits."
	icon_state = "wraps"
	icon = 'modular_doppler/hearthkin/primitive_catgirls/icons/clothing_greyscale.dmi'
	worn_icon = 'modular_doppler/hearthkin/primitive_catgirls/icons/clothing_greyscale.dmi'
	body_parts_covered = GROIN
	greyscale_config = /datum/greyscale_config/primitive_catgirl_wraps
	greyscale_config_worn = /datum/greyscale_config/primitive_catgirl_wraps/worn
	greyscale_colors = "#cec8bf#364660"
	flags_1 = IS_PLAYER_COLORABLE_1
	has_sensor = FALSE

/obj/item/clothing/under/dress/skirt/primitive_catgirl_tailored_dress
	name = "tailored dress"
	desc = "A handmade dress, tailored to fit perfectly to its wearer's body measurements."
	icon_state = "tailored_dress"
	icon = 'modular_doppler/hearthkin/primitive_catgirls/icons/clothing_greyscale.dmi'
	worn_icon = 'modular_doppler/hearthkin/primitive_catgirls/icons/clothing_greyscale.dmi'
	body_parts_covered = GROIN|CHEST
	greyscale_config = /datum/greyscale_config/primitive_catgirl_tailored_dress
	greyscale_config_worn = /datum/greyscale_config/primitive_catgirl_tailored_dress/worn
	greyscale_colors = "#cec8bf#364660"
	flags_1 = IS_PLAYER_COLORABLE_1
	has_sensor = FALSE

/obj/item/clothing/under/dress/skirt/primitive_catgirl_tunic
	name = "handmade tunic"
	desc = "A simple garment that reaches from the shoulders to above the knee. This one has a belt to secure it."
	icon_state = "tunic"
	icon = 'modular_doppler/hearthkin/primitive_catgirls/icons/clothing_greyscale.dmi'
	worn_icon = 'modular_doppler/hearthkin/primitive_catgirls/icons/clothing_greyscale.dmi'
	body_parts_covered = GROIN|CHEST
	greyscale_config = /datum/greyscale_config/primitive_catgirl_tunic
	greyscale_config_worn = /datum/greyscale_config/primitive_catgirl_tunic/worn
	greyscale_colors = "#cec8bf#faece4#594032"
	flags_1 = IS_PLAYER_COLORABLE_1
	has_sensor = FALSE

/obj/item/clothing/under/dress/skirt/loincloth
	name = "loincloth"
	desc = "A simple elegant cloth, to use wrapped around your waist and groin."
	icon_state = "loincloth"
	icon = 'modular_doppler/hearthkin/primitive_catgirls/icons/loincloth.dmi'
	worn_icon = 'modular_doppler/hearthkin/primitive_catgirls/icons/loincloth.dmi'
	greyscale_config = /datum/greyscale_config/loincloth
	greyscale_config_worn = /datum/greyscale_config/loincloth/worn
	greyscale_colors = "#413069"
	flags_1 = IS_PLAYER_COLORABLE_1
	body_parts_covered = GROIN|LEGS
	has_sensor = NO_SENSORS
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/dress/skirt/loincloth/loincloth_alt
	name = "shorter loincloth"
	desc = "A simple elegant cloth, to use wrapped around your waist and groin. This one uses a shorter cloth."
	icon_state = "loincloth_alt"
	greyscale_config = /datum/greyscale_config/loincloth_alt
	greyscale_config_worn = /datum/greyscale_config/loincloth_alt/worn

// Hands

/obj/item/clothing/gloves/fingerless/primitive_catgirl_armwraps
	name = "arm wraps"
	desc = "Simple cloth to wrap around one's arms."
	icon_state = "armwraps"
	icon = 'modular_doppler/hearthkin/primitive_catgirls/icons/clothing_greyscale.dmi'
	worn_icon = 'modular_doppler/hearthkin/primitive_catgirls/icons/clothing_greyscale.dmi'
	greyscale_config = /datum/greyscale_config/primitive_catgirl_armwraps
	greyscale_config_worn = /datum/greyscale_config/primitive_catgirl_armwraps/worn
	greyscale_colors = "#cec8bf"
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/gloves/fingerless/primitive_catgirl_gauntlets
	name = "gauntlets"
	desc = "Simple cloth arm wraps with overlying metal protection."
	icon_state = "gauntlets"
	icon = 'modular_doppler/hearthkin/primitive_catgirls/icons/clothing_greyscale.dmi'
	worn_icon = 'modular_doppler/hearthkin/primitive_catgirls/icons/clothing_greyscale.dmi'
	greyscale_config = /datum/greyscale_config/primitive_catgirl_gauntlets
	greyscale_config_worn = /datum/greyscale_config/primitive_catgirl_gauntlets/worn
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_colors = "#cec8bf#c55a1d"
	flags_1 = IS_PLAYER_COLORABLE_1

// Suit

/obj/item/clothing/suit/jacket/primitive_catgirl_coat
	name = "primitive fur coat"
	desc = "A large piece of animal hide stuffed with fur, likely from the same animal."
	icon_state = "coat"
	icon = 'modular_doppler/hearthkin/primitive_catgirls/icons/clothing_greyscale.dmi'
	worn_icon = 'modular_doppler/hearthkin/primitive_catgirls/icons/clothing_greyscale.dmi'
	body_parts_covered = CHEST
	cold_protection = CHEST
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	greyscale_config = /datum/greyscale_config/primitive_catgirl_coat
	greyscale_config_worn = /datum/greyscale_config/primitive_catgirl_coat/worn
	greyscale_colors = "#594032#cec8bf"
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/suit/apron/chef/colorable_apron/primitive_catgirl_leather
	greyscale_colors = "#594032"

// Shoes

/obj/item/clothing/shoes/winterboots/ice_boots/primitive_catgirl_boots
	name = "primitive hiking boots"
	desc = "A pair of heavy boots lined with fur and with soles special built to prevent slipping on ice."
	icon_state = "boots"
	icon = 'modular_doppler/hearthkin/primitive_catgirls/icons/clothing_greyscale.dmi'
	worn_icon = 'modular_doppler/hearthkin/primitive_catgirls/icons/clothing_greyscale.dmi'
	greyscale_config = /datum/greyscale_config/primitive_catgirl_boots
	greyscale_config_worn = /datum/greyscale_config/primitive_catgirl_boots/worn
	greyscale_colors = "#594032#cec8bf"
	flags_1 = IS_PLAYER_COLORABLE_1

// Neck

/obj/item/clothing/neck/scarf/primitive_catgirl_scarf
	greyscale_colors = "#cec8bf#cec8bf"

/obj/item/clothing/neck/large_scarf/primitive_catgirl_off_white
	greyscale_colors = "#cec8bf#cec8bf"

/obj/item/clothing/neck/infinity_scarf/primitive_catgirl_blue
	greyscale_colors = "#364660"

/obj/item/clothing/neck/mantle/recolorable/primitive_catgirl_off_white
	greyscale_colors = "#cec8bf"

/obj/item/clothing/neck/ranger_poncho/primitive_catgirl_leather
	greyscale_colors = "#594032#594032"

// Masks

/obj/item/clothing/mask/neck_gaiter/primitive_catgirl_gaiter
	greyscale_colors = "#364660"

// Head

/obj/item/clothing/head/standalone_hood/primitive_catgirl_colors
	greyscale_colors = "#594032#364660"

/obj/item/clothing/head/primitive_catgirl_ferroniere
	name = "Ferroniere"
	desc = "A style of headband that encircles the wearer's forehead, with a small jewel suspended in the centre."
	icon_state = "ferroniere"
	icon = 'modular_doppler/hearthkin/primitive_catgirls/icons/clothing_greyscale.dmi'
	worn_icon = 'modular_doppler/hearthkin/primitive_catgirls/icons/clothing_greyscale.dmi'
	greyscale_config = /datum/greyscale_config/primitive_catgirl_ferroniere
	greyscale_config_worn = /datum/greyscale_config/primitive_catgirl_ferroniere/worn
	greyscale_colors = "#f1f6ff#364660"
	w_class = WEIGHT_CLASS_TINY
	flags_1 = IS_PLAYER_COLORABLE_1

// Misc Items

/obj/item/forging/reagent_weapon/axe/fake_copper
	custom_materials = list(/datum/material/copporcitite = SHEET_MATERIAL_AMOUNT)

/obj/item/clothing/suit/armor/forging_plate_armor/hearthkin
	name = "handcrafted hearthkin armor"
	desc = "An armor obviously crafted by the expertise of a hearthkin. It has leather shoulder pads and a chain mail underneath."
	icon_state = "chained_leather_armor"
	icon = 'modular_doppler/hearthkin/primitive_catgirls/icons/objects.dmi'
	worn_icon = 'modular_doppler/hearthkin/primitive_catgirls/icons/clothing_greyscale.dmi'
	body_parts_covered = GROIN|CHEST

/datum/crafting_recipe/handcrafted_hearthkin_armor
	name = "Handcrafted Hearthkin Armor"
	category = CAT_CLOTHING

	//recipe given to icecats as part of their spawner/team setting
	crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_MUST_BE_LEARNED

	reqs = list(
		/obj/item/forging/complete/chain = 4,
		/obj/item/stack/sheet/leather = 2,
	)

	result = /obj/item/clothing/suit/armor/forging_plate_armor/hearthkin

//Pelts
/obj/item/clothing/head/pelt
	icon = 'modular_doppler/hearthkin/primitive_catgirls/icons/pelt.dmi'
	worn_icon = 'modular_doppler/hearthkin/primitive_catgirls/icons/pelt_worn.dmi'
	name = "bear pelt"
	desc = "A luxurious bear pelt, good to keep warm in winter. Or to sleep through it."
	icon_state = "bearpelt_brown"
	inhand_icon_state = "cowboy_hat_brown"
	cold_protection = CHEST|HEAD
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT

/obj/item/clothing/head/pelt/black
	icon_state = "bearpelt_black"
	inhand_icon_state = "cowboy_hat_black"

/obj/item/clothing/head/pelt/white
	icon_state = "bearpelt_white"
	inhand_icon_state = "cowboy_hat_white"

/obj/item/clothing/head/pelt/tiger
	name = "shiny tiger pelt"
	desc = "A vibrant tiger pelt, particularly fabulous."
	icon_state = "tigerpelt_shiny"
	inhand_icon_state = "cowboy_hat_grey"

/obj/item/clothing/head/pelt/snow_tiger
	name = "snow tiger pelt"
	desc = "A pelt of a less vibrant tiger, but rather warm."
	icon_state = "tigerpelt_snow"
	inhand_icon_state = "cowboy_hat_white"

/obj/item/clothing/head/pelt/pink_tiger
	name = "pink tiger pelt"
	desc = "A particularly vibrant tiger pelt, for those who want to be the most fabulous at parties."
	icon_state = "tigerpelt_pink"
	inhand_icon_state = "cowboy_hat_red"

/obj/item/clothing/head/pelt/wolf
	name = "wolf pelt"
	desc = "A fuzzy wolf pelt that demands respect as a hunter... assuming it wasn't just purchased, that is, for all the glory but none of the credit."
	worn_icon = 'modular_doppler/hearthkin/primitive_catgirls/icons/pelt_big.dmi'
	icon_state = "wolfpelt_brown"

/obj/item/clothing/head/pelt/wolf/black
	icon_state = "wolfpelt_gray"
	inhand_icon_state = "cowboy_hat_grey"

/obj/item/clothing/head/pelt/wolf/white
	icon_state = "wolfpelt_white"
	inhand_icon_state = "cowboy_hat_white"
//End Pelts
