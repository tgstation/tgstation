/obj/item/clothing/suit/jacket/straight_jacket
	name = "straight jacket"
	desc = "A suit that completely restrains the wearer. Manufactured by Antyphun Corp." //Straight jacket is antifun
	icon_state = "straight_jacket"
	inhand_icon_state = "straight_jacket"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS|HANDS
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	equip_delay_self = 50
	strip_delay = 60
	breakouttime = 5 MINUTES
	supports_variations_flags = CLOTHING_PONY_MASK
	pony_clothing_sample_pixels = null
	pony_icon_state = "straightjacket"
	pony_config_path = /datum/greyscale_config/pony_clothes_override

/obj/item/clothing/suit/jacket/straight_jacket/generate_pony_icons(icon/base_icon, greyscale_colors)
	var/icon/ponysuit = icon(SSgreyscale.GetColoredIconByType(pony_config_path, greyscale_colors), pony_icon_state)
	return ponysuit

/obj/item/clothing/suit/jacket/straight_jacket/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_DANGEROUS_OBJECT, INNATE_TRAIT)
