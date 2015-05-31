//PORTABLE REFRIGERATOR: Allows storage of hivelord cores to prevent them from decaying.
/obj/item/device/hivelordFridge
	name = "portable refrigerator"
	desc = "A heavy cube used to store hivelord cores for later use. Will indefinitely prevent them from becoming inert."
	w_class = 3
	icon = 'icons/obj/mining.dmi'
	icon_state = "fridgeOff"
	item_state = "electronic"
	throw_speed = 1
	throw_range = 2
	slot_flags = SLOT_BELT
	var/obj/item/asteroid/hivelord_core/storedCore = null

/obj/item/device/hivelordFridge/attack_self(mob/user)
	if(!storedCore)
		return
	user.visible_message("<span class='notice'>[user] removes [storedCore] from [src].</span>", \
						 "<span class='notice'>\icon[src]You pop open [src] and remove [storedCore].</span>")
	if(!user.put_in_hands(storedCore))
		storedCore.loc = get_turf(user)
	storedCore.preserved = 0
	storedCore = null
	icon_state = "fridgeOff"
	..()

/obj/item/device/hivelordFridge/examine(mob/user)
	..()
	if(storedCore)
		user << "<span class='notice'>It has\icon [storedCore][storedCore] loaded.</span>"
	else
		user << "<span class='notice'>Nothing is loaded.</span>"

/obj/item/device/hivelordFridge/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/asteroid/hivelord_core) && !storedCore)
		var/obj/item/asteroid/hivelord_core/H = W
		user.visible_message("<span class='notice'>[user] places [H] into [src].</span>", \
							 "\icon[src]<span class='notice'>You place [H] into [src] and close it with a hiss of cold air.</span>")
		user.drop_item()
		H.loc = src
		icon_state = "fridgeOn"
		playsound(src, 'sound/machines/hiss.ogg', 50, 0, 0)
		H.preserved = 1
		storedCore = H
		return
	..()
