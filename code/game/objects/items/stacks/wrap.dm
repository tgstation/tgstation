

/*
 * Wrapping Paper
 */

/obj/item/stack/wrapping_paper
	name = "wrapping paper"
	desc = "You can use this to wrap items in."
	icon = 'icons/obj/items.dmi'
	icon_state = "wrap_paper"
	flags = NOBLUDGEON
	amount = 25
	max_amount = 25
	burn_state = FLAMMABLE

/obj/item/stack/wrapping_paper/attack_self(mob/user)
	user << "<span class='warning'>You need to use it on a package that has already been wrapped!</span>"

/obj/item/stack/wrapping_paper/Destroy()
	if(!amount)
		new /obj/item/weapon/c_tube(get_turf(src))
	return ..()


/*
 * Package Wrap
 */

/obj/item/stack/packageWrap
	name = "package wrapper"
	icon = 'icons/obj/items.dmi'
	icon_state = "deliveryPaper"
	flags = NOBLUDGEON
	amount = 25
	max_amount = 25
	burn_state = FLAMMABLE


/obj/item/stack/packageWrap/afterattack(obj/target, mob/user, proximity)
	if(!proximity)
		return
	if(!istype(target))
		return
	if(istype(target, /obj/item/smallDelivery))
		return
	if(!isturf(target.loc))
		user << "<span class='warning'>You can't wrap something that isn't on the ground.</span>"
		return
	if(target.anchored)
		return

	if(istype(target, /obj/item))
		var/obj/item/I = target
		if(use(1))
			var/obj/item/smallDelivery/P = new /obj/item/smallDelivery(get_turf(I.loc))
			I.loc = P
			var/size = round(I.w_class)
			P.w_class = size
			size = min(size, 5)
			P.icon_state = "deliverypackage[size]"
			P.add_fingerprint(user)
			I.add_fingerprint(user)

	else if(istype (target, /obj/structure/closet))
		var/obj/structure/closet/O = target
		if(O.opened)
			return
		if(!O.density) //can't wrap non dense closets (e.g. body bags)
			user << "<span class='warning'>You can't wrap this!</span>"
			return
		if(use(3))
			var/obj/structure/bigDelivery/P = new /obj/structure/bigDelivery(get_turf(O.loc))
			if(O.horizontal)
				P.icon_state = "deliverycrate"
			O.loc = P
			P.add_fingerprint(user)
			O.add_fingerprint(user)
		else
			user << "<span class='warning'>You need more paper!</span>"
			return
	else
		user << "<span class='warning'>The object you are trying to wrap is unsuitable for the sorting machinery!</span>"
		return

	user.visible_message("<span class='notice'>[user] wraps [target].</span>")
	user.attack_log += text("\[[time_stamp()]\] <font color='blue'>Has used [name] on [target]</font>")

/obj/item/stack/packageWrap/Destroy()
	if(!amount)
		new /obj/item/weapon/c_tube(get_turf(src))
	return ..()

/obj/item/weapon/c_tube
	name = "cardboard tube"
	desc = "A tube... of cardboard."
	icon = 'icons/obj/items.dmi'
	icon_state = "c_tube"
	throwforce = 0
	w_class = 1
	throw_speed = 3
	throw_range = 5