/// Medical bay suits go here
//	Just the hospital gown for now
/obj/item/clothing/suit/toggle/labcoat/hospitalgown //Intended to keep patients modest while still allowing for surgeries
	name = "hospital gown"
	desc = "A complicated drapery with an assortment of velcros and strings, designed to keep a patient modest during medical stay and surgeries."
	icon_state = "hgown"
	icon = 'modular_doppler/modular_cosmetics/icons/obj/suit/labcoat.dmi'
	worn_icon = 'modular_doppler/modular_cosmetics/icons/mob/suit/labcoat.dmi'
	toggle_noun = "drapes"
	body_parts_covered = NONE //Allows surgeries despite wearing it; hiding genitals is handled in /datum/sprite_accessory/genital/is_hidden() (Only place it'd work sadly)
	armor_type = /datum/armor/none
	equip_delay_other = 8

/obj/item/clothing/suit/toggle/labcoat/lalunevest
	name = "sleeveless buttoned coat"
	desc = "A fashionable jacket bearing the La Lune insignia on the inside. It appears similar to a labcoat in design and materials, though the tag warns against it being a replacement for such."
	icon_state = "labcoat_lalunevest"
	icon = 'modular_doppler/modular_cosmetics/icons/obj/suit/labcoat.dmi'
	worn_icon = 'modular_doppler/modular_cosmetics/icons/mob/suit/labcoat.dmi'
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/suit/toggle/labcoat/medical
	name = "medical labcoat"
	desc = "A suit that protects against minor chemical spills. This one is greener than you'd typically expect."
	icon = 'modular_doppler/modular_cosmetics/icons/obj/suit/labcoat.dmi'
	worn_icon = 'modular_doppler/modular_cosmetics/icons/mob/suit/labcoat.dmi'
	icon_state = "labcoat_med"

/obj/item/clothing/suit/toggle/labcoat/medical/unbuttoned
	name = "unbuttoned medical labcoat"
	desc = "Someone has taken to the task of cutting the top few buttons off this labcoat. It's particularly slutty in just the way you'd expect."
	icon_state = "labcoat_opentop"
