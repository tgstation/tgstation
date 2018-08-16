
//VG rip

/obj/item/clothing/glasses/sunglasses/purple
	desc = "Strangely ancient technology used to help provide rudimentary eye cover. Enhanced shielding blocks many flashes, and the colored lenses let you see the world in purple."
	name = "purple sunglasses"
	icon_state = "sun_purple"
	icon = 'modular_citadel/icons/obj/clothing/vg_clothes.dmi'
	icon_override = 'modular_citadel/icons/mob/citadel/glasses.dmi'

/obj/item/clothing/glasses/sunglasses/star
	name = "star-shaped sunglasses"
	desc = "Novelty sunglasses, both lenses are in the shape of a star."
	icon_state = "sun_star"
	icon = 'modular_citadel/icons/obj/clothing/vg_clothes.dmi'
	icon_override = 'modular_citadel/icons/mob/citadel/glasses.dmi'

/obj/item/clothing/glasses/sunglasses/rockstar
	name = "red star-shaped sunglasses"
	desc = "Novelty sunglasses with a fancy silver frame and two red-tinted star-shaped lenses. You should probably stomp on them and get a pair of normal ones."
	icon_state = "sun_star_silver"
	icon = 'modular_citadel/icons/obj/clothing/vg_clothes.dmi'
	icon_override = 'modular_citadel/icons/mob/citadel/glasses.dmi'

/obj/item/clothing/glasses/gglasses
	name = "Green Glasses"
	desc = "Forest green glasses, like the kind you'd wear when hatching a nasty scheme."
	icon_state = "gglasses"
	item_state = "gglasses"
	icon = 'modular_citadel/icons/obj/clothing/vg_clothes.dmi'
	icon_override = 'modular_citadel/icons/mob/citadel/glasses.dmi'

/obj/item/clothing/glasses/welding/superior
	name = "superior welding goggles"
	desc = "Welding goggles made from more expensive materials, strangely smells like potatoes. Allows for better vision than normal goggles.."
	icon_state = "rwelding-g"
	item_state = "rwelding-g"
	icon = 'modular_citadel/icons/obj/clothing/vg_clothes.dmi'
	icon_override = 'modular_citadel/icons/mob/citadel/glasses.dmi'
	actions_types = list(/datum/action/item_action/toggle)
	flash_protect = 2
	tint = 1
	visor_vars_to_toggle = VISOR_FLASHPROTECT | VISOR_TINT
	flags_cover = GLASSESCOVERSEYES
	visor_flags_inv = HIDEEYES
	glass_colour_type = /datum/client_colour/glass_colour/green