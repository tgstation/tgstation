/obj/item/weapon/monkeyclothes
	name = "monkey-sized waiter suit"
	desc = "Adorable."
	icon = 'icons/mob/monkey.dmi'
	icon_state = "punpunsuit_icon"
	item_state = "punpunsuit_item"
	force = 0
	throwforce = 0
	throw_speed = 2
	throw_range = 5
	w_class = 3.0
	flags = FPRINT | TABLEPASS
	attack_verb = list("tries to cloth")
	var/itemtype = /obj/item/weapon/monkeyclothes

/obj/item/weapon/monkeyclothes/attack(mob/living/carbon/C as mob, mob/user as mob)
	if(ismonkey(C))
		var/mob/living/carbon/monkey/M = C
		M.wearclothes(src)
