//PORTABLE REFRIGERATOR: Allows storage of hivelord cores to prevent them from decaying.
/obj/item/device/hivelord_fridge
	name = "portable refrigerator"
	desc = "A heavy cube used to store hivelord cores for later use. Will indefinitely prevent them from becoming inert."
	w_class = 3
	icon = 'icons/obj/mining.dmi'
	icon_state = "fridge0"
	item_state = "electronic"
	throw_speed = 1
	throw_range = 2
	slot_flags = SLOT_BELT
	var/obj/item/asteroid/hivelord_core/stored_core = null
	var/emagged = 0

/obj/item/device/hivelord_fridge/attack_self(mob/user)
	if(!stored_core)
		return
	user.visible_message("<span class='notice'>[user] removes [stored_core] from [src].</span>", \
						 "<span class='notice'>\icon[src]You pop open [src] and remove [stored_core].</span>")
	if(!user.put_in_hands(stored_core))
		stored_core.loc = get_turf(user)
	stored_core.preserved = 0
	stored_core = null
	icon_state = "fridge0"
	..()

/obj/item/device/hivelord_fridge/examine(mob/user)
	..()
	if(stored_core)
		user << "<span class='notice'>It has\icon [stored_core][stored_core] loaded.</span>"
	else
		user << "<span class='notice'>Nothing is loaded.</span>"

/obj/item/device/hivelord_fridge/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/asteroid/hivelord_core) && !stored_core)
		var/obj/item/asteroid/hivelord_core/H = W
		user.visible_message("<span class='notice'>[user] places [H] into [src].</span>", \
							 "\icon[src]<span class='notice'>You place [H] into [src] and close it with a hiss of cold air.</span>")
		user.drop_item()
		H.loc = src
		icon_state = "fridge1[emagged]"
		playsound(src, 'sound/machines/hiss.ogg', 50, 1, 5)
		H.preserved = 1
		stored_core = H
		return
	..()