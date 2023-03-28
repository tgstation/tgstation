/obj/item/clothing/mask/kitsuneblack
	name = "Black Kitsune Mask"
	desc = "An oriental styled porcelain mask, this one is black and gold."
	icon = 'monkestation/icons/obj/clothing/masks.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/mask.dmi'
	icon_state = "blackkitsunemask"
	w_class = WEIGHT_CLASS_TINY
	flags_cover = MASKCOVERSMOUTH
	flags_inv = HIDEFACE|HIDEFACIALHAIR
	visor_flags_inv = HIDEFACE|HIDEFACIALHAIR
	visor_flags_cover = MASKCOVERSMOUTH
	slot_flags = ITEM_SLOT_MASK

/obj/item/clothing/mask/kitsuneblack/attack_self(mob/user)
    adjustmask(user)

/obj/item/clothing/mask/kitsuneblack/AltClick(mob/user)
    . = ..()
    adjustmask(user)
    return TRUE

/obj/item/clothing/mask/kitsunewhite
	name = "White Kitsune Mask"
	desc = "An oriental styled porcelain mask, this one is white and red."
	icon = 'monkestation/icons/obj/clothing/masks.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/mask.dmi'
	icon_state = "whitekitsunemask"
	w_class = WEIGHT_CLASS_TINY
	flags_cover = MASKCOVERSMOUTH
	flags_inv = HIDEFACE|HIDEFACIALHAIR
	visor_flags_inv = HIDEFACE|HIDEFACIALHAIR
	visor_flags_cover = MASKCOVERSMOUTH
	slot_flags = ITEM_SLOT_MASK

/obj/item/clothing/mask/kitsunewhite/attack_self(mob/user)
    adjustmask(user)

/obj/item/clothing/mask/kitsunewhite/AltClick(mob/user)
    . = ..()
    adjustmask(user)
    return TRUE
