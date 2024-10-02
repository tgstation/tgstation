// Contains:
// Gavel Hammer
// Gavel Block

/obj/item/gavelhammer
	name = "gavel hammer"
	desc = "Order, order! No bombs in my courthouse."
	icon = 'icons/obj/weapons/hammer.dmi'
	icon_state = "gavelhammer"
	force = 5
	throwforce = 6
	w_class = WEIGHT_CLASS_SMALL
	attack_verb_continuous = list("bashes", "batters", "judges", "whacks")
	attack_verb_simple = list("bash", "batter", "judge", "whack")
	resistance_flags = FLAMMABLE

/obj/item/gavelhammer/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/kneejerk)

/obj/item/gavelhammer/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] has sentenced [user.p_them()]self to death with [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	PLAYSOUND(loc, 'sound/items/gavel.ogg').vary_frequency(TRUE).range(-1 + SOUND_RANGE).play()
	return BRUTELOSS

/obj/item/gavelblock
	name = "gavel block"
	desc = "Smack it with a gavel hammer when the assistants get rowdy."
	icon = 'icons/obj/weapons/hammer.dmi'
	icon_state = "gavelblock"
	force = 2
	throwforce = 2
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE

/obj/item/gavelblock/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/gavelhammer))
		PLAYSOUND(loc, 'sound/items/gavel.ogg').volume(100).vary_frequency(TRUE).play()
		user.visible_message(span_warning("[user] strikes [src] with [I]."))
		user.changeNext_move(CLICK_CD_MELEE)
	else
		return ..()
