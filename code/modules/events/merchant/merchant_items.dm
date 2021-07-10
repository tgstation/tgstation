///This file is for merchant sold items that don't really have a better file to be in, or should be together to be found easier.

/**
 * ## silicon sentience chip!
 *
 * Only sold by the special robot trader, makes a robot sentient
 */
/obj/item/silicon_sentience
	name = "silicon sentience chip"
	desc = "Can be used to grant sentience to robots."
	icon_state = "sentience_chip"
	icon = 'icons/obj/module.dmi'

/obj/item/silicon_sentience/Initialize()
	. = ..()
	AddComponent(/datum/component/sentience_granter, SENTIENCE_ARTIFICIAL)

/**
 * ## LFLINE pack!
 *
 * Only sold by the special robot trader, LFLINE bulks you down but gives you the momento mori effect
 */
/obj/item/lfline
	name = "LFLINE pack"
	desc = "You wear this on your back, let it plug into your organs... and you're invincible! Allegedly."
	icon_state = "backpack"
	inhand_icon_state = "backpack"
	lefthand_file = 'icons/mob/inhands/equipment/backpack_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/backpack_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	resistance_flags = NONE
	max_integrity = 150
