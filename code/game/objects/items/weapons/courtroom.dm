// Contains:
// Gavel Hammer
// Gavel Block

/obj/item/weapon/gavelhammer
	name = "gavel hammer"
	desc = "Order, order! No bombs in my courthouse."
	icon = 'icons/obj/items.dmi'
	icon_state = "gavelhammer"
	force = 5
	throwforce = 6
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("bashed", "battered", "judged", "whacked")
	resistance_flags = FLAMMABLE

/obj/item/weapon/gavelhammer/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] has sentenced [user.p_them()]self to death with [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	playsound(loc, 'sound/items/gavel.ogg', 50, 1, -1)
	return (BRUTELOSS)

/obj/item/weapon/gavelblock
	name = "gavel block"
	desc = "Smack it with a gavel hammer when the assistants get rowdy."
	icon = 'icons/obj/items.dmi'
	icon_state = "gavelblock"
	force = 2
	throwforce = 2
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE

/obj/item/weapon/gavelblock/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/gavelhammer))
		playsound(loc, 'sound/items/gavel.ogg', 100, 1)
		user.visible_message("<span class='warning'>[user] strikes [src] with [I].</span>")
		user.changeNext_move(CLICK_CD_MELEE)
	else
		return ..()