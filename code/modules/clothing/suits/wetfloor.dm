/obj/item/clothing/suit/caution
	name = "wet floor sign"
	desc = "Caution! Wet Floor!"
	icon_state = "caution"
	worn_icon = 'icons/mob/clothing/suits/utility.dmi'
	lefthand_file = 'icons/mob/inhands/equipment/custodial_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/custodial_righthand.dmi'
	force = 1
	throwforce = 3
	throw_speed = 2
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	body_parts_covered = CHEST|GROIN
	attack_verb_continuous = list("warns", "cautions", "smashes")
	attack_verb_simple = list("warn", "caution", "smash")
	armor = list(MELEE = 5, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)
	species_exception = list(/datum/species/golem)
