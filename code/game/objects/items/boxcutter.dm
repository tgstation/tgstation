/obj/item/boxcutter
	name = "boxcutter"
	desc = "A cutting tool used for opening boxes."
	icon_state = "telebaton"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	inhand_icon_state = null
	attack_verb_continuous = list("cuts", "stabs", "slashes")
	attack_verb_simple = list("cut", "stab", "slash")
	worn_icon_state = "tele_baton"
	sharpness = SHARP_EDGED
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	item_flags = NONE
	force = 8
	bare_wound_bonus = 5
	active = FALSE

/obj/item/delivery/parcel/attackby(obj/item/boxcutter, mob/user)
	var/sound_file = 'sound/items/bikehorn.ogg'
