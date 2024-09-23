/obj/item/clothing/glasses/eyepatch/wrap
	name = "eye wrap"
	desc = "A glorified bandage. At least this one's actually made for your head..."
	icon = 'modular_doppler/modular_cosmetics/icons/obj/face/glasses.dmi'
	worn_icon = 'modular_doppler/modular_cosmetics/icons/mob/face/glasses.dmi'
	icon_state = "eyewrap"
	base_icon_state = "eyewrap"

/obj/item/clothing/glasses/eyepatch/white
	name = "white eyepatch"
	desc = "This is what happens when a pirate gets a PhD."
	icon = 'modular_doppler/modular_cosmetics/icons/obj/face/glasses.dmi'
	worn_icon = 'modular_doppler/modular_cosmetics/icons/mob/face/glasses.dmi'
	icon_state = "eyepatch_white"
	base_icon_state = "eyepatch_white"

/obj/item/clothing/glasses/examine(mob/user)
	. = ..()
	if(locate(/datum/action/item_action/flip) in actions)
		. += "Use in hands to wear it over your [icon_state == base_icon_state ? "left" : "right"] eye."

// /obj/item/clothing/glasses/hud/security/sunglasses/eyepatch/examine(mob/user)
// 	. = ..()
// 	. += "Use in hands to wear it over your [icon_state == base_icon_state ? "left" : "right"] eye."
