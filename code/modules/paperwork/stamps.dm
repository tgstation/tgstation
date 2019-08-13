/obj/item/stamp
	name = "\improper GRANTED rubber stamp"
	desc = "A rubber stamp for stamping important documents."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "stamp-ok"
	item_state = "stamp"
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	materials = list(/datum/material/iron=60)
	pressure_resistance = 2
	attack_verb = list("stamped")

/obj/item/stamp/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] stamps 'VOID' on [user.p_their()] forehead, then promptly falls over, dead.</span>")
	return (OXYLOSS)

/obj/item/stamp/qm
	name = "quartermaster's rubber stamp"
	icon_state = "stamp-qm"

/obj/item/stamp/law
	name = "law office's rubber stamp"
	icon_state = "stamp-law"

/obj/item/stamp/captain
	name = "captain's rubber stamp"
	icon_state = "stamp-cap"

/obj/item/stamp/hop
	name = "head of personnel's rubber stamp"
	icon_state = "stamp-hop"

/obj/item/stamp/hos
	name = "head of security's rubber stamp"
	icon_state = "stamp-hos"

/obj/item/stamp/ce
	name = "chief engineer's rubber stamp"
	icon_state = "stamp-ce"

/obj/item/stamp/rd
	name = "research director's rubber stamp"
	icon_state = "stamp-rd"

/obj/item/stamp/cmo
	name = "chief medical officer's rubber stamp"
	icon_state = "stamp-cmo"

/obj/item/stamp/denied
	name = "\improper DENIED rubber stamp"
	icon_state = "stamp-deny"

/obj/item/stamp/clown
	name = "clown's rubber stamp"
	icon_state = "stamp-clown"

/obj/item/stamp/attack_paw(mob/user)
	return attack_hand(user)
