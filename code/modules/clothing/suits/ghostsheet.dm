/obj/item/clothing/suit/costume/ghost_sheet
	name = "ghost sheet"
	desc = "The hands float by themselves, so it's extra spooky."
	icon_state = "ghost_sheet"
	inhand_icon_state = null
	throwforce = 0
	throw_speed = 1
	throw_range = 2
	w_class = WEIGHT_CLASS_TINY
	flags_inv = HIDEGLOVES|HIDEEARS|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT
	alternate_worn_layer = UNDER_HEAD_LAYER
	species_exception = list(/datum/species/golem)
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/suit/costume/ghost_sheet/Initialize(mapload)
	. = ..()
	if(check_holidays(HALLOWEEN))
		update_icon(UPDATE_OVERLAYS)

/obj/item/clothing/suit/costume/ghost_sheet/worn_overlays(mutable_appearance/standing, isinhands, icon_file)
	. = ..()
	if(!isinhands && check_holidays(HALLOWEEN))
		. += emissive_appearance('icons/mob/simple/mob.dmi', "ghost", offset_spokesman = src, alpha = src.alpha)
