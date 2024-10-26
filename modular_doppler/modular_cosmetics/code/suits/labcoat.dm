/// Medical bay suits go here
//	Just the hospital gown for now
/obj/item/clothing/suit/toggle/labcoat/hospitalgown //Intended to keep patients modest while still allowing for surgeries
	name = "hospital gown"
	desc = "A complicated drapery with an assortment of velcros and strings, designed to keep a patient modest during medical stay and surgeries."
	icon_state = "hgown"
	inhand_icon_state = "hgown"
	icon = 'modular_doppler/modular_cosmetics/icons/obj/suit/labcoat.dmi'
	worn_icon = 'modular_doppler/modular_cosmetics/icons/mob/suit/labcoat.dmi'
	toggle_noun = "drapes"
	body_parts_covered = NONE //Allows surgeries despite wearing it; hiding genitals is handled in /datum/sprite_accessory/genital/is_hidden() (Only place it'd work sadly)
	armor_type = /datum/armor/none
	equip_delay_other = 8
