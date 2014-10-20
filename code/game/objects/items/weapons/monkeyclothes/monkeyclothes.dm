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

/obj/item/weapon/monkeyclothes/attack(mob/living/carbon/C as mob, mob/user as mob)	//I thought I'd give people a fast way to put clothes on monkey.
	if(ismonkey(C))																	//They can do it by opening the monkey's "show inventory" like you'd do for an human as well.
		var/mob/living/carbon/monkey/M = C
		if(M.canWearClothes)
			M.wearclothes(src)

/obj/item/weapon/monkeyclothes/cultrobes
	name = "size S cult robes"
	desc = "Adorably crazy."
	icon_state = "cult_icon"
	item_state = "cult_item"