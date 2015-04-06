/obj/structure/coatrack
	name = "Coat Rack"
	desc = "For a detective to hang his coat and hat."
	icon = 'icons/obj/coatrack.dmi'
	icon_state = "coatrack0"
	density = 1
	anchored = 0
	pressure_resistance = ONE_ATMOSPHERE*5
	flags = FPRINT
	autoignition_temperature = AUTOIGNITION_WOOD
	fire_fuel = 3
	var/obj/item/clothing/suit/storage/det_suit/suit = null
	var/obj/item/clothing/head/det_hat/hat = null

/obj/structure/coatrack/attack_hand(mob/user)
	if(suit)
		user << "<span class='notice'>You pick up the [suit] from the [src]</span>"
		playsound(get_turf(src), "rustle", 50, 1, -5)
		suit.loc = get_turf(src)
		if(!user.get_active_hand())
			user.put_in_hands(suit)
		suit = null
		update_icon()
		return

	if(hat)
		user << "<span class='notice'>You pick up the [hat] from the [src]</span>"
		playsound(get_turf(src), "rustle", 50, 1, -5)
		hat.loc = get_turf(src)
		if(!user.get_active_hand())
			user.put_in_hands(hat)
		hat = null
		update_icon()
		return

/obj/structure/coatrack/attackby(obj/item/clothing/C, mob/user)
	if (istype(C, /obj/item/clothing/suit/storage/det_suit) && !suit)
		user << "<span class='notice'>You place your [C] on the [src]</span>"
		playsound(get_turf(src), "rustle", 50, 1, -5)
		user.drop_item(src)
		suit = C
		update_icon()

	else if (istype(C, /obj/item/clothing/head/det_hat) && !hat)
		user << "<span class='notice'>You place your [C] on the [src]</span>"
		playsound(get_turf(src), "rustle", 50, 1, -5)
		user.drop_item(src)
		hat = C
		update_icon()

	else
		return ..()

/obj/structure/coatrack/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				qdel(src)
				return
		if(3.0)
			if (prob(5))
				qdel(src)
				return

/obj/structure/coatrack/Destroy()
	if(loc)
		if(suit)
			suit.loc = loc
		if(hat)
			hat.loc = loc
	..()

/obj/structure/coatrack/update_icon()
	if(hat)
		if(suit)
			icon_state = "coatrack3"
		else
			icon_state = "coatrack1"
	else
		if(suit)
			icon_state = "coatrack2"
		else
			icon_state = "coatrack0"

/obj/structure/coatrack/full
	icon_state = "coatrack3"

/obj/structure/coatrack/full/New()
	..()
	suit = new(src)
	hat = new(src)
