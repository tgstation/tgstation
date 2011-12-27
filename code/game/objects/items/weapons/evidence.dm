//CONTAINS:
//Evidence bags and stuff
///////////
//Shamelessly ripped from Mini's old code.

/obj/item/weapon/evidencebag
	name = "evidence bag"
	desc = "An empty evidence bag."
	icon = 'storage.dmi'
	icon_state = "evidenceobj"
	w_class = 1

/* buggy and stuff
/obj/item/weapon/evidencebag/attackby(obj/item/weapon/O, mob/user as mob)
	return src.afterattack(O, user)
*/

/obj/item/weapon/evidencebag/afterattack(obj/item/O, mob/user as mob)

//Now you can put it into a briefcase, if it is in your hand.  Otherwise, if it is evidence on the ground, it picks it up.
	if(istype(O, /obj/item/weapon/storage) && O in user)
		user << "You put the evidence bag into the [O]."
		return ..()
	if(!(O && istype(O)) || O.anchored == 1)
		user << "You can't put that inside the [src]!"
		return ..()
	if(O in user)
		user << "You are wearing that."
		return
	if(src.contents.len > 0)
		user << "The [src] already has something inside it."
		return ..()
	if(istype(O.loc, /obj/item/weapon/storage))
		user << "This is broke as hell."
		return
/*		var/obj/item/weapon/storage/U = O.loc
		w_class = O.w_class
		for(var/i, i < U.contents.len, i++)
			if(O in U.contents[i])
				U.contents[i] = null
				O.loc = src
				continue*/
	user << "You put the [O] inside the [src]."
	icon_state = "evidence"
	src.underlays += O
	desc = "An evidence bag containing \a [O]. [O.desc]"
	O.loc = src
	w_class = O.w_class
	return


/obj/item/weapon/evidencebag/attack_self(mob/user as mob)
	if (src.contents.len > 0)
		var/obj/item/I = src.contents[1]
		user << "You take the [I] out of the [src]."
		src.underlays -= I
		I.loc = get_turf(user.loc)
		w_class = 1
		src.icon_state = "evidenceobj"
		desc = "An empty evidence bag."
	else
		user << "[src] is empty."
		src.icon_state = "evidenceobj"
	return

/obj/item/weapon/storage/box/evidence
	name = "evidence bag box"
	desc = "A box claiming to contain evidence bags."
	New()
		new /obj/item/weapon/evidencebag(src)
		new /obj/item/weapon/evidencebag(src)
		new /obj/item/weapon/evidencebag(src)
		new /obj/item/weapon/evidencebag(src)
		new /obj/item/weapon/evidencebag(src)
		new /obj/item/weapon/f_card(src)
		new /obj/item/weapon/f_card(src)
		..()
		return