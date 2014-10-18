/obj/item/device/maracas
	name = "maracas"
	desc = "chick-chicky-boom, chick-chicky boom."
	icon = 'icons/obj/maracas.dmi'
	icon_state = "maracas"
	item_state = "maracas"
	w_class = 1.0
	flags = FPRINT | TABLEPASS | CONDUCT
	slot_flags = SLOT_BELT

	var/spam_flag = 0
	var/emagged = 0	//TODO

	var/mob/living/M = null
	var/orientation = 0

/obj/item/device/maracas/New()
	..()
	src.pixel_x = rand(-5.0, 5)
	src.pixel_y = rand(-5.0, 5)

/obj/item/device/maracas/pickup(mob/user)
	..()
	M = user
	spam_flag = world.timeofday
	chickchicky()
	spawn(0)
		dancin()

/obj/item/device/maracas/dropped(mob/user)
	..()
	spam_flag = world.timeofday
	chickchicky()
	M = null

/obj/item/device/maracas/proc/dancin()
	if(M)
		if(M.dir != orientation)
			chickchicky()
			orientation = M.dir
		sleep(2)
		dancin()

/obj/item/device/maracas/attack_self(mob/user as mob)
	if(spam_flag + 5 < world.timeofday)
		spam_flag = world.timeofday
		chickchicky()

/obj/item/device/maracas/proc/chickchicky()
	playsound(get_turf(src), 'sound/misc/maracas.ogg', 50, 1)