/obj/item/device/maracas
	name = "maracas"
	desc = "Chick-chicky-boom, chick-chicky boom."
	icon = 'icons/obj/maracas.dmi'
	icon_state = "maracas"
	item_state = "maracas"
	w_class = 1.0
	flags = FPRINT | TABLEPASS | CONDUCT
	slot_flags = SLOT_BELT

	var/emagged = 0//our maracas are different - Deity Link

/obj/item/device/maracas/New()
	..()
	src.pixel_x = rand(-5.0, 5)
	src.pixel_y = rand(-5.0, 5)

/obj/item/device/maracas/pickup(mob/user)
	user.callOnFace |= "\ref[src]"
	user.callOnFace["\ref[src]"] = "chickchicky"
	chickchicky()

/obj/item/device/maracas/throw_impact(atom/hit_atom)
	if(emagged)
		explosion(get_turf(src), -1 ,-1, 1)
		emagged = 0

/obj/item/device/maracas/dropped(mob/user)
	user.callOnFace -= "\ref[src]"
	spawn(3)
		chickchicky()

/obj/item/device/maracas/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/card/emag) && !emagged)
		user << "<span class='warning'>You're not sure why, but you could swear that you can hear the maracas ticking.</span>"
		emagged = 1
	return

/obj/item/device/maracas/attack_self(mob/user as mob)
	chickchicky()

/obj/item/device/maracas/proc/chickchicky()
	playsound(get_turf(src), 'sound/misc/maracas.ogg', 50, 1)