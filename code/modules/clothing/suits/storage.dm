/obj/item/clothing/suit/storage
	var/obj/item/weapon/storage/internal/pockets/pockets

/obj/item/clothing/suit/storage/New()
	..()
	pockets = new/obj/item/weapon/storage/internal/pockets(src, slots = 2, slot_size = 2) //two slots, fit only pocket sized items

/obj/item/clothing/suit/storage/Destroy()
	qdel(pockets)
	pockets = null
	return ..()

/obj/item/clothing/suit/storage/attack_hand(mob/user as mob)
	if (pockets.handle_attack_hand(user))
		..(user)

/obj/item/clothing/suit/storage/MouseDrop(obj/over_object as obj)
	if (pockets.handle_mousedrop(usr, over_object))
		..(over_object)

/obj/item/clothing/suit/storage/attackby(obj/item/W as obj, mob/user as mob)
	..()
	pockets.attackby(W, user)

/obj/item/clothing/suit/storage/emp_act(severity)
	pockets.emp_act(severity)
	..()