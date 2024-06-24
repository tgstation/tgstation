/*
*	The hoodies and attached sprites [WERE ORIGINALLY FROM] https://github.com/Citadel-Station-13/Citadel-Station-13-RP before GAGSification
*	Respective datums can be found in modular_nova/modules/customization/datums/greyscale/hoodies
*	These are now a subtype of toggle/jacket too, so it properly toggles and isnt the unused 'storage' type
*/

/obj/item/clothing/suit/toggle/jacket/hoodie
	name = "hoodie"
	desc = "A warm hoodie. you cant help but mess with the zipper..."
	icon_state = "hoodie"
	greyscale_config = /datum/greyscale_config/hoodie
	greyscale_config_worn = /datum/greyscale_config/hoodie/worn
	greyscale_colors = "#FFFFFF"
	flags_1 = IS_PLAYER_COLORABLE_1
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	min_cold_protection_temperature = T0C - 20	//Not as good as the base jacket

/obj/item/clothing/suit/toggle/jacket/hoodie/trim
	icon_state = "hoodie_trim"
	greyscale_config = /datum/greyscale_config/hoodie_trim
	greyscale_config_worn = /datum/greyscale_config/hoodie_trim/worn
	greyscale_colors = "#ffffff#313131"
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/suit/toggle/jacket/hoodie/trim/alt
	icon_state = "hoodie_trim_alt"
	greyscale_colors = "#ffffff#313131"
	flags_1 = IS_PLAYER_COLORABLE_1

/*
*	PRESET GREYSCALES & BRANDED
*/

/obj/item/clothing/suit/toggle/jacket/hoodie/grey
	greyscale_colors = "#a8a8a8"

/obj/item/clothing/suit/toggle/jacket/hoodie/black
	greyscale_colors = "#313131"

/obj/item/clothing/suit/toggle/jacket/hoodie/red
	greyscale_colors = "#D13838"

/obj/item/clothing/suit/toggle/jacket/hoodie/blue
	greyscale_colors = "#034A8D"

/obj/item/clothing/suit/toggle/jacket/hoodie/green
	greyscale_colors = "#1DA103"

/obj/item/clothing/suit/toggle/jacket/hoodie/orange
	greyscale_colors = "#F79305"

/obj/item/clothing/suit/toggle/jacket/hoodie/yellow
	greyscale_colors = "#F0D655"

/obj/item/clothing/suit/toggle/jacket/hoodie/branded
	name = "NT hoodie"
	desc = "A warm, blue sweatshirt.  It proudly bears the silver Nanotrasen insignia lettering on the back.  The edges are trimmed with silver."
	icon_state = "hoodie_NT"
	greyscale_config = /datum/greyscale_config/hoodie_branded
	greyscale_config_worn = /datum/greyscale_config/hoodie_branded/worn
	greyscale_colors = "#02519A#ffffff"	//white to prevent changing the actual color of the icon. I've no clue why it REQUIRES two inputs despite being set otherwise.
	flags_1 = NONE

/obj/item/clothing/suit/toggle/jacket/hoodie/branded/nrti
	name = "New Reykjavik Technical Institute hoodie"
	desc = "A warm, gray sweatshirt. It bears the letters NRT on the back, in reference to Sif's premiere technical institute."
	icon_state = "hoodie_NRTI"
	greyscale_colors = "#747474#a83232"

/obj/item/clothing/suit/toggle/jacket/hoodie/branded/mu
	name = "mojave university hoodie"
	desc = "A warm, gray sweatshirt.  It bears the letters MU on the front, a lettering to the well-known public college, Mojave University."
	icon_state = "hoodie_MU"
	greyscale_colors = "#747474#ffffff"


/obj/item/clothing/suit/toggle/jacket/hoodie/branded/cti
	name = "CTI hoodie"
	desc = "A warm, black sweatshirt.  It bears the letters CTI on the back, a lettering to the prestigious university in Tau Ceti, Ceti Technical Institute.  There is a blue supernova embroidered on the front, the emblem of CTI."
	icon_state = "hoodie_CTI"
	greyscale_colors = "#313131#ffffff"

/obj/item/clothing/suit/toggle/jacket/hoodie/branded/smw
	name = "Space Mountain Wind hoodie"
	desc = "A warm, black sweatshirt.  It has the logo for the popular softdrink Space Mountain Wind on both the front and the back."
	icon_state = "hoodie_SMW"
	greyscale_colors = "#313131#ffffff"


/obj/item/clothing/under/suit/fancy
	name = "fancy suit"
	desc = "A fancy suit and jacket with an elegant shirt."
	icon_state = "fancy_suit"
	greyscale_config = /datum/greyscale_config/fancy_suit
	greyscale_config_worn = /datum/greyscale_config/fancy_suit/worn
	greyscale_colors = "#FFFFFA#0075C4#7C787D"
	flags_1 = IS_PLAYER_COLORABLE_1
	supports_variations_flags = NONE


// Modular Overwrites
/obj/item/clothing/under/suit
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY

/obj/item/clothing/under/suit/white/skirt
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY

/obj/item/clothing/under/suit/black/skirt
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY

/obj/item/clothing/under/suit/black_really/skirt
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY

//Heister kit
/obj/item/clothing/suit/jacket/det_suit/noir/heister
	name = "armored suit jacket"
	desc = "A professional suit jacket, it feels much heavier than a regular jacket. A label on the inside reads \"Nanite-based Self-repairing Kevlar weave\"."
	armor_type = /datum/armor/heister
	/// How many hits we can take before the armor breaks, PAYDAY style
	var/armor_stacks = 2

/datum/armor/heister
	melee = 35
	bullet = 30
	laser = 30
	energy = 40
	bomb = 25
	fire = 50
	acid = 50
	wound = 10

/obj/item/clothing/suit/jacket/det_suit/noir/heister/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/shielded/suit, max_charges = armor_stacks, recharge_start_delay = 8 SECONDS, charge_increment_delay = 1 SECONDS, \
	charge_recovery = armor_stacks, lose_multiple_charges = FALSE, starting_charges = armor_stacks, shield_icon_file = null, shield_icon = null)

/obj/item/clothing/gloves/latex/nitrile/heister
	desc = "Pricy sterile gloves that are thicker than latex. Perfect for hiding fingerprints."
	clothing_traits = null
	siemens_coefficient = 0
