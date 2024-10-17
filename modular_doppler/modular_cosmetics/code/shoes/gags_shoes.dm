/obj/item/clothing/shoes/colorable_laceups
	name = "laceup shoes"
	desc = "These don't seem to come pre-polished, how saddening."
	icon = 'modular_doppler/modular_cosmetics/icons/obj/shoes/casual.dmi'
	worn_icon = 'modular_doppler/modular_cosmetics/icons/mob/shoes/casual.dmi'
	icon_state = "laceups"
	greyscale_colors = "#2b2b2b"
	greyscale_config = /datum/greyscale_config/casualshoes
	greyscale_config_worn = /datum/greyscale_config/casualshoes/worn
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/shoes/colorable_laceups/Initialize(mapload)
	. = ..()
	greyscale_config_worn_bodyshapes = list()
	greyscale_config_worn_bodyshapes["[BODYSHAPE_HUMANOID]"] = /datum/greyscale_config/casualshoes/worn
	greyscale_config_worn_bodyshapes["[BODYSHAPE_DIGITIGRADE]"] = /datum/greyscale_config/casualshoes/worn/digi
	set_greyscale(colors = greyscale_colors)

/obj/item/clothing/shoes/colorable_sandals
	name = "sandals"
	desc = "Rumor has it that wearing these with socks puts you on a no entry list in several sectors."
	icon = 'modular_doppler/modular_cosmetics/icons/obj/shoes/casual.dmi'
	worn_icon = 'modular_doppler/modular_cosmetics/icons/mob/shoes/casual.dmi'
	icon_state = "sandals"
	greyscale_colors = "#AA0000"
	greyscale_config = /datum/greyscale_config/casualshoes
	greyscale_config_worn = /datum/greyscale_config/casualshoes/worn
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/shoes/colorable_sandals/Initialize(mapload)
	. = ..()
	greyscale_config_worn_bodyshapes = list()
	greyscale_config_worn_bodyshapes["[BODYSHAPE_HUMANOID]"] = /datum/greyscale_config/casualshoes/worn
	greyscale_config_worn_bodyshapes["[BODYSHAPE_DIGITIGRADE]"] = /datum/greyscale_config/casualshoes/worn/digi
	set_greyscale(colors = greyscale_colors)

/obj/item/clothing/shoes/jackboots/recolorable
	icon = 'modular_doppler/modular_cosmetics/icons/obj/shoes/casual.dmi'
	worn_icon = 'modular_doppler/modular_cosmetics/icons/mob/shoes/casual.dmi'
	icon_state = "boots"
	greyscale_colors = "#2b2b2b"
	greyscale_config = /datum/greyscale_config/boots
	greyscale_config_worn = /datum/greyscale_config/boots/worn
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/shoes/jackboots/recolorable/Initialize(mapload)
	. = ..()
	greyscale_config_worn_bodyshapes = list()
	greyscale_config_worn_bodyshapes["[BODYSHAPE_HUMANOID]"] = /datum/greyscale_config/boots/worn
	greyscale_config_worn_bodyshapes["[BODYSHAPE_DIGITIGRADE]"] = /datum/greyscale_config/boots/worn/digi
	set_greyscale(colors = greyscale_colors)

/obj/item/clothing/shoes/wraps
	name = "cloth foot wraps"
	desc = "Simple cloth footwraps, suitable for padding the heels."
	icon = 'modular_doppler/modular_cosmetics/icons/obj/shoes/casual.dmi'
	icon_state = "wrap"
	worn_icon = 'modular_doppler/modular_cosmetics/icons/mob/shoes/casual.dmi'
	greyscale_config = /datum/greyscale_config/legwraps
	greyscale_config_worn = /datum/greyscale_config/legwraps/worn
	greyscale_colors = "#FFFFFF"
	body_parts_covered = FALSE
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/shoes/wraps/Initialize(mapload)
	. = ..()
	greyscale_config_worn_bodyshapes = list()
	greyscale_config_worn_bodyshapes["[BODYSHAPE_HUMANOID]"] = /datum/greyscale_config/legwraps/worn
	greyscale_config_worn_bodyshapes["[BODYSHAPE_DIGITIGRADE]"] = /datum/greyscale_config/legwraps/worn/digi
	set_greyscale(colors = greyscale_colors)

/obj/item/clothing/shoes/wraps/leggy
	name = "cloth leg wraps"
	desc = "Simple cloth legwraps, for when socks aren't good enough."
	icon_state = "legwrap"

/obj/item/clothing/shoes/jackboots/colonial/greyscale
	icon = 'modular_doppler/modular_cosmetics/icons/obj/shoes/casual.dmi'
	worn_icon = 'modular_doppler/modular_cosmetics/icons/mob/shoes/casual.dmi'
	icon_state = "boots_colonial"
	greyscale_colors = "#2b2b2b"
	greyscale_config = /datum/greyscale_config/boots
	greyscale_config_worn = /datum/greyscale_config/boots/worn
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/shoes/jackboots/colonial/greyscale/Initialize(mapload)
	. = ..()
	greyscale_config_worn_bodyshapes = list()
	greyscale_config_worn_bodyshapes["[BODYSHAPE_HUMANOID]"] = /datum/greyscale_config/boots/worn
	greyscale_config_worn_bodyshapes["[BODYSHAPE_DIGITIGRADE]"] = /datum/greyscale_config/boots/worn/digi
	set_greyscale(colors = greyscale_colors)
