/obj/item/clothing/mask/gas/slasher
	name = "slasher's gas mask"
	desc = "A close-fitting sealed gas mask, this one seems to be protruding some kind of dark aura."

	icon = 'icons/obj/clothing/head/utility.dmi'
	worn_icon = 'icons/mob/clothing/head/utility.dmi'
	icon_state = "welding"
	inhand_icon_state = "welding"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	slowdown = 1

/obj/item/clothing/mask/gas/slasher/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, "slasher")

/obj/item/clothing/mask/gas/slasher/adjustmask()
	return
