/obj/item/device/maracas
	name = "maracas"
	desc = "chick-chicky-boom, chick-chicky boom. (hold down CTRL and press the arrow keys)"
	icon = 'icons/obj/maracas.dmi'
	icon_state = "maracas"
	item_state = "maracas"
	w_class = 1.0
	flags = FPRINT | TABLEPASS | CONDUCT
	slot_flags = SLOT_BELT

	var/emagged = 0	//TODO

/obj/item/device/maracas/New()
	..()
	src.pixel_x = rand(-5.0, 5)
	src.pixel_y = rand(-5.0, 5)

/obj/item/device/maracas/pickup(mob/user)
	..()
	user.AddCanShake(src)
	chickchicky()

/obj/item/device/maracas/dropped(mob/user)
	..()
	user.RemoveCanShake(src)
	spawn(3)
		chickchicky()

/obj/item/device/maracas/attack_self(mob/user as mob)
	chickchicky()

/obj/item/device/maracas/proc/chickchicky()
	playsound(get_turf(src), 'sound/misc/maracas.ogg', 50, 1)