/obj/item/cowbell
	name = "Golden cowbell"
	desc = "You feel like you need MORE of this"
	resistance_flags = FLAMMABLE
	max_integrity = 100
	icon = 'modular_event/cowbell/musician.dmi'
	icon_state = "cowbell"
	hitsound = null
	lefthand_file = 'icons/mob/inhands/equipment/horns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/horns_righthand.dmi'
	inhand_icon_state = "gold_horn"
	attack_verb_continuous = list("cowbells")
	attack_verb_simple = list("cowbells")
	w_class = WEIGHT_CLASS_TINY
	force = 0
	throw_speed = 3
	throw_range = 15

/obj/item/cowbell/Initialize()
	. = ..()
	AddComponent(/datum/component/squeak, list('modular_event/cowbell/cowbell.ogg'=1), 50)
