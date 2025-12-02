// Mask skins
/datum/atom_skin/joy_mask
	abstract_type = /datum/atom_skin/joy_mask
	change_base_icon_state = TRUE

/datum/atom_skin/joy_mask/joy
	preview_name = "Joy"
	new_icon_state = "joy"

/datum/atom_skin/joy_mask/flushed
	preview_name = "Flushed"
	new_icon_state = "flushed"

/datum/atom_skin/joy_mask/pensive
	preview_name = "Pensive"
	new_icon_state = "pensive"

/datum/atom_skin/joy_mask/angry
	preview_name = "Angry"
	new_icon_state = "angry"

/datum/atom_skin/joy_mask/pleading
	preview_name = "Pleading"
	new_icon_state = "pleading"

/obj/item/clothing/mask/joy
	name = "emotion mask"
	desc = "Express your happiness or hide your sorrows with this cultured cutout."
	icon_state = "joy"
	base_icon_state = "joy"
	clothing_flags = MASKINTERNALS
	flags_inv = HIDESNOUT

/obj/item/clothing/mask/joy/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/reskinable_item, /datum/atom_skin/joy_mask, infinite = TRUE)

/obj/item/clothing/mask/mummy
	name = "mummy mask"
	desc = "Ancient bandages."
	icon_state = "mummy_mask"
	inhand_icon_state = null
	flags_inv = HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT

/obj/item/clothing/mask/scarecrow
	name = "sack mask"
	desc = "A burlap sack with eyeholes."
	icon_state = "scarecrow_sack"
	inhand_icon_state = null
	flags_inv = HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT

/obj/item/clothing/mask/kitsune
	name = "kitsune mask"
	desc = "Porcelain mask made in the style of the Sol-3 region. It is painted to look like a kitsune."
	inhand_icon_state = null
	w_class = WEIGHT_CLASS_SMALL
	adjusted_flags = ITEM_SLOT_HEAD
	flags_inv = HIDEFACE|HIDEFACIALHAIR
	custom_price = PAYCHECK_CREW
	greyscale_colors = "#EEEEEE#AA0000"
	icon = 'icons/map_icons/clothing/mask.dmi'
	icon_state = "/obj/item/clothing/mask/kitsune"
	post_init_icon_state = "kitsune"
	greyscale_config = /datum/greyscale_config/kitsune
	greyscale_config_worn = /datum/greyscale_config/kitsune/worn
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/mask/kitsune/examine(mob/user)
	. = ..()
	if(up)
		. += "Use in-hand to wear as a mask!"
		return
	else
		. += "Use in-hand to wear as a hat!"

/obj/item/clothing/mask/kitsune/attack_self(mob/user)
	adjust_visor(user)
	alternate_worn_layer = up ? ABOVE_BODY_FRONT_HEAD_LAYER : null

/obj/item/clothing/mask/rebellion
	name = "rebellion mask"
	desc = "Mask that is usually used during rebellions by insurgents. It covers the entire face and makes you unrecognizable."
	inhand_icon_state = null
	w_class = WEIGHT_CLASS_SMALL
	flags_inv = HIDEFACE|HIDEFACIALHAIR|HIDESNOUT
	custom_price = PAYCHECK_CREW
	visor_flags = MASKINTERNALS
	greyscale_colors = COLOR_VERY_LIGHT_GRAY
	alternate_worn_layer = BENEATH_HAIR_LAYER
	icon = 'icons/map_icons/clothing/mask.dmi'
	icon_state = "/obj/item/clothing/mask/rebellion"
	post_init_icon_state = "rebellion_mask"
	greyscale_config = /datum/greyscale_config/rebellion_mask
	greyscale_config_worn = /datum/greyscale_config/rebellion_mask/worn
	flags_1 = IS_PLAYER_COLORABLE_1
	custom_materials = list(/datum/material/plastic = SHEET_MATERIAL_AMOUNT)
